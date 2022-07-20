#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-base.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
[Flags()] Enum GitHubActionsEnvironmentVariableScopes {
	Current = 1
	Subsequent = 2
}
<#
.SYNOPSIS
GitHub Actions - Add PATH
.DESCRIPTION
Add PATH to current step and all subsequent steps in the current job.
.PARAMETER Path
Path.
.PARAMETER NoValidator
Do not check the PATH whether is valid.
.PARAMETER Scope
Scope of PATH.
.OUTPUTS
[Void]
#>
Function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][String[]]$Path,
		[Alias('NoValidate', 'SkipValidate', 'SkipValidator')][Switch]$NoValidator,
		[GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[String[]]$Result = @()
	}
	Process {
		ForEach ($Item In ($Path | Select-Object -Unique)) {
			If (!$NoValidator.IsPresent -and !(Test-Path -Path $Item -PathType 'Container' -IsValid)) {
				Write-Error -Message "``$Item`` is not a valid PATH!" -Category 'SyntaxError'
				Continue
			}
			$Result += $Item
		}
	}
	End {
		If ($Result.Count -igt 0) {
			Switch -Exact ($Scope.ToString() -isplit ', ') {
				'Current' {
					[System.Environment]::SetEnvironmentVariable('PATH', ((([System.Environment]::GetEnvironmentVariable('PATH') -isplit [System.IO.Path]::PathSeparator) + $Result) -join [System.IO.Path]::PathSeparator)) | Out-Null
				}
				'Subsequent' {
					If ([String]::IsNullOrWhiteSpace($Env:GITHUB_PATH)) {
						$Result | ForEach-Object -Process {
							Write-GitHubActionsCommand -Command 'add-path' -Value $_
						}
					} Else {
						Add-Content -LiteralPath $Env:GITHUB_PATH -Value ($Result -join "`n") -Confirm:$False -Encoding 'UTF8NoBOM'
					}
				}
			}
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Set Environment Variable
.DESCRIPTION
Set environment variable to current step and all subsequent steps in the current job.
.PARAMETER InputObject
Environment variables.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
.PARAMETER NoToUpper
Do not format environment variable name to uppercase.
.PARAMETER Scope
Scope of environment variable.
.OUTPUTS
[Void]
#>
Function Set-EnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsenvironmentvariable#Set-GitHubActionsEnvironmentVariable')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Return (Test-EnvironmentVariableName -InputObject $_) }, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Value` must be in single line string!')][String]$Value,
		[Alias('NoToUppercase')][Switch]$NoToUpper,
		[GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Hashtable]$Result = @{}
	}
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				ForEach ($Item In $InputObject.GetEnumerator()) {
					If ($Item.Name.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						Continue
					}
					If (!(Test-EnvironmentVariableName -InputObject $Item.Name)) {
						Write-Error -Message "``$($Item.Name)`` is not a valid environment variable name!" -Category 'SyntaxError'
						Continue
					}
					If ($Item.Value.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						Continue
					}
					If ($Item.Value -inotmatch '^.+$') {
						Write-Error -Message 'Parameter `Value` must be in single line string!' -Category 'SyntaxError'
						Continue
					}
					$Result[$NoToUpper.IsPresent ? $Item.Name : $Item.Name.ToUpper()] = $Item.Value
				}
			}
			'Single' {
				$Result[$NoToUpper.IsPresent ? $Name : $Name.ToUpper()] = $Value
			}
		}
	}
	End {
		If ($Result.Count -igt 0) {
			Switch -Exact ($Scope.ToString() -isplit ', ') {
				'Current' {
					$Result.GetEnumerator() | ForEach-Object -Process {
						[System.Environment]::SetEnvironmentVariable($_.Name, $_.Value) | Out-Null
					}
				}
				'Subsequent' {
					If ([String]::IsNullOrWhiteSpace($Env:GITHUB_ENV)) {
						$Result.GetEnumerator() | ForEach-Object -Process {
							Write-GitHubActionsCommand -Command 'set-env' -Parameter @{ 'name' = $_.Name } -Value $_.Value
						}
					} Else {
						Add-Content -LiteralPath $Env:GITHUB_ENV -Value (($Result.GetEnumerator() | ForEach-Object -Process {
							Return "$($_.Name)=$($_.Value)"
						}) -join "`n") -Confirm:$False -Encoding 'UTF8NoBOM'
					}
				}
			}
		}
	}
}
Set-Alias -Name 'Set-Env' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Set-Environment' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Environment Variable Name
.DESCRIPTION
Test environment variable name whether is valid.
.PARAMETER InputObject
Environment variable name that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-EnvironmentVariableName {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Begin {}
	Process {
		Return ($InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject -inotmatch '^(?:CI|PATH)$' -and $InputObject -inotmatch '^(?:ACTIONS|GITHUB|RUNNER)_')
	}
	End {}
}
Export-ModuleMember -Function @(
	'Add-PATH',
	'Set-EnvironmentVariable'
) -Alias @(
	'Set-Env',
	'Set-Environment'
)
