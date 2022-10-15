#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base.psm1',
		'internal\test-parameter-input-object.psm1'
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
Add PATH to the current step and/or all of the subsequent steps in the current job.
.PARAMETER Path
Absolute paths.
.PARAMETER NoValidator
Whether to not check the paths are valid.
.PARAMETER Scope
Scope of the PATHs.
.OUTPUTS
[Void]
#>
Function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][String[]]$Path,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoValidate', 'SkipValidate', 'SkipValidator')][Switch]$NoValidator,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Boolean]$Legacy = [String]::IsNullOrWhiteSpace($Env:GITHUB_PATH)
	}
	Process {
		[String[]]$ScopeArray = $Scope.ToString() -isplit ', '
		ForEach ($Item In (
			$Path |
				Select-Object -Unique
		)) {
			If (!$NoValidator.IsPresent -and ![System.IO.Path]::IsPathRooted($Item) -and !(Test-Path -Path $Item -PathType 'Container' -IsValid)) {
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
Set environment variable to the current step and/or all of the subsequent steps in the current job.
.PARAMETER InputObject
Environment variables.
.PARAMETER Name
Name of the environment variable.
.PARAMETER Value
Value of the environment variable.
.PARAMETER NoToUpper
Whether to not format names of the environment variable to the upper case.
.PARAMETER Scope
Scope of the environment variables.
.OUTPUTS
[Void]
#>
Function Set-EnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsenvironmentvariable#Set-GitHubActionsEnvironmentVariable')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][ValidateScript({ Test-GitHubActionsParameterInputObject -InputObject $_ })][Alias('Input', 'Object')]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Test-EnvironmentVariableName -InputObject $_ }, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][String]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoToUpperCase')][Switch]$NoToUpper,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Boolean]$Legacy = [String]::IsNullOrWhiteSpace($Env:GITHUB_ENV)
	}
	Process {
		If ($PSCmdlet.ParameterSetName -ieq 'Multiple') {
			If (
				$InputObject -is [Hashtable] -or
				$InputObject -is [System.Collections.Specialized.OrderedDictionary]
			) {
				$InputObject.GetEnumerator() |
					Set-EnvironmentVariable -NoToUpper:$NoToUpper.IsPresent -Scope $Scope
				Return
			}
			$InputObject |
				Set-EnvironmentVariable -NoToUpper:$NoToUpper.IsPresent -Scope $Scope
			Return
		}
		Switch -Exact ($Scope.ToString() -isplit ', ') {
			'Current' {
				[System.Environment]::SetEnvironmentVariable($Name, $Value) |
					Out-Null
			}
			'Subsequent' {
				If ($Legacy) {
					Write-GitHubActionsCommand -Command 'set-env' -Parameter @{ 'name' = $Name } -Value $Value
				}
				Else {
					Write-GitHubActionsFileCommand -LiteralPath $Env:GITHUB_ENV -Name $Name -Value $Value
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
Test the name of the environment variable whether is valid.
.PARAMETER InputObject
Name of the environment variable that need to test.
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
