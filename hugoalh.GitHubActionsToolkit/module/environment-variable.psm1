#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
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
		[Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Boolean]$Legacy = [String]::IsNullOrWhiteSpace($Env:GITHUB_PATH)
		[String[]]$ScopeArray = $Scope.ToString() -isplit ', '
	}
	Process {
		ForEach ($Item In (
			$Path |
				Select-Object -Unique
		)) {
			If (!$NoValidator.IsPresent -and !(Test-Path -Path $Item -PathType 'Container' -IsValid)) {
				Write-Error -Message "``$Item`` is not a valid PATH!" -Category 'SyntaxError'
				Continue
			}
			Switch -Exact ($ScopeArray) {
				'Current' {
					Add-Content -LiteralPath $Env:PATH -Value "$([System.IO.Path]::PathSeparator)$Item" -Confirm:$False -NoNewLine
				}
				'Subsequent' {
					If ($Legacy) {
						Write-GitHubActionsCommand -Command 'add-path' -Value $Item
					}
					Else {
						Add-Content -LiteralPath $Env:GITHUB_PATH -Value $Item -Confirm:$False -Encoding 'UTF8NoBOM'
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
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Test-EnvironmentVariableName -InputObject $_ }, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][String]$Value,
		[Alias('NoToUppercase')][Switch]$NoToUpper,
		[Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Boolean]$Legacy = [String]::IsNullOrWhiteSpace($Env:GITHUB_ENV)
		[String[]]$ScopeArray = $Scope.ToString() -isplit ', '
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
					[String]$ItemName = $NoToUpper.IsPresent ? $Item.Name : $Item.Name.ToUpper()
					[String]$ItemValue = $Item.Value
				}
			}
			'Single' {
				[String]$ItemName = $NoToUpper.IsPresent ? $Name : $Name.ToUpper()
				[String]$ItemValue = $Value
			}
		}
		Switch -Exact ($ScopeArray) {
			'Current' {
				[System.Environment]::SetEnvironmentVariable($ItemName, $ItemValue) |
					Out-Null
			}
			'Subsequent' {
				If ($Legacy) {
					Write-GitHubActionsCommand -Command 'set-env' -Parameter @{ 'name' = $ItemName } -Value $ItemValue
				}
				Else {
					Write-GitHubActionsFileCommand -LiteralPath $Env:GITHUB_ENV -Name $ItemName -Value $ItemValue
				}
			}
		}
	}
}
Set-Alias -Name 'Set-Env' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Set-Environment' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Private) - Test Environment Variable Name
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
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject -inotmatch '^(?:CI|PATH)$|^(?:ACTIONS|GITHUB|RUNNER)_' |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'Add-PATH',
	'Set-EnvironmentVariable'
) -Alias @(
	'Set-Env',
	'Set-Environment'
)
