#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-file.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
[Flags()] Enum GitHubActionsEnvironmentVariableScopes {
	Current = 1
	Subsequent = 2
}
<#
.SYNOPSIS
GitHub Actions - Add PATH
.DESCRIPTION
Add PATH for the current step and/or all of the subsequent steps in the current job.
.PARAMETER Path
Absolute paths.
.PARAMETER Scope
Scope of the PATHs.
.OUTPUTS
[Void]
#>
Function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionspath')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidateScript({ [System.IO.Path]::IsPathFullyQualified($_) }, ErrorMessage = '`{0}` is not a valid absolute path!')][Alias('Paths')][String[]]$Path,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	Begin {
		[Boolean]$ShouldProceed = $True
		Try {
			If ([String]::IsNullOrEmpty($Env:GITHUB_PATH)) {
				Throw 'Environment path `GITHUB_PATH` is not defined!'
			}
			If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_PATH)) {
				Throw "``$Env:GITHUB_PATH`` (environment path ``GITHUB_PATH``) is not a valid absolute path!"
			}
			If (!(Test-Path -LiteralPath $FileCommandPath -PathType 'Leaf')) {
				Throw 'File is not exist!'
			}
		}
		Catch {
			$ShouldProceed = $False
			Write-Error -Message "Unable to add the GitHub Actions PATH: $_" -Category 'ResourceUnavailable'
		}
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		If (($Scope -band ([GitHubActionsEnvironmentVariableScopes]::Current)) -ieq ([GitHubActionsEnvironmentVariableScopes]::Current)) {
			$Null = [System.Environment]::SetEnvironmentVariable('PATH', (
				($Env:PATH -isplit ([System.IO.Path]::PathSeparator)) + $Path |
					Select-Object -Unique |
					Join-String -Separator ([System.IO.Path]::PathSeparator)
			))
		}
		If (($Scope -band ([GitHubActionsEnvironmentVariableScopes]::Subsequent)) -ieq ([GitHubActionsEnvironmentVariableScopes]::Subsequent)) {
			Try {
				(Get-Content -LiteralPath $Env:GITHUB_PATH -Encoding 'UTF8NoBOM') + $Path |
					Select-Object -Unique |
					Add-Content -LiteralPath $Env:GITHUB_PATH -Confirm:$False -Encoding 'UTF8NoBOM'
			}
			Catch {
				Write-Error -Message "Unable to add the GitHub Actions PATH: $_" -Category (($_)?.CategoryInfo.Category ?? 'OperationStopped')
			}
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Clear Environment Variable
.DESCRIPTION
Clear environment variable that set in the current step.
.OUTPUTS
[Void]
#>
Function Clear-EnvironmentVariable {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_cleargithubactionsenvironmentvariable')]
	[OutputType([Void])]
	Param ()
	Clear-GitHubActionsFileCommand -FileCommand 'GITHUB_ENV'
}
Set-Alias -Name 'Clear-Env' -Value 'Clear-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Remove-Env' -Value 'Clear-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Remove-EnvironmentVariable' -Value 'Clear-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Clear PATH
.DESCRIPTION
Clear PATH that set in the current step.
.OUTPUTS
[Void]
#>
Function Clear-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_cleargithubactionspath')]
	[OutputType([Void])]
	Param ()
	Clear-GitHubActionsFileCommand -FileCommand 'GITHUB_PATH'
}
Set-Alias -Name 'Remove-PATH' -Value 'Clear-PATH' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set Environment Variable
.DESCRIPTION
Set environment variable for the current step and/or all of the subsequent steps in the current job.
.PARAMETER Name
Name of the environment variable.
.PARAMETER Value
Value of the environment variable.
.PARAMETER NoToUpper
Whether to not format names of the environment variable to the upper case.
.PARAMETER Scope
Scope of the environment variable.
.PARAMETER Optimize
Whether to have an optimize operation by replace exist command instead of add command directly.
.OUTPUTS
[Void]
#>
Function Set-EnvironmentVariable {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsenvironmentvariable')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Test-EnvironmentVariableName -InputObject $_ }, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][String]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoToUpperCase')][Switch]$NoToUpper,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Scopes')][GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$Optimize
	)
	Process {
		If (($Scope -band ([GitHubActionsEnvironmentVariableScopes]::Current)) -ieq ([GitHubActionsEnvironmentVariableScopes]::Current)) {
			$Null = [System.Environment]::SetEnvironmentVariable($Name, $Value)
		}
		If (($Scope -band ([GitHubActionsEnvironmentVariableScopes]::Subsequent)) -ieq ([GitHubActionsEnvironmentVariableScopes]::Subsequent)) {
			Write-GitHubActionsFileCommand -FileCommand 'GITHUB_ENV' -Name $Name -Value $Value -Optimize:($Optimize.IsPresent)
		}
	}
}
Set-Alias -Name 'Set-Env' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Internal - Test Environment Variable Name
.DESCRIPTION
Test the name of the environment variable whether is valid.
.PARAMETER InputObject
Name of the environment variable that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-EnvironmentVariableName {
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'Object')][String]$InputObject
	)
	Return ($InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject -inotmatch '^(?:CI|PATH)$|^(?:ACTIONS|GITHUB|RUNNER)_')
}
Export-ModuleMember -Function @(
	'Add-PATH',
	'Clear-EnvironmentVariable',
	'Clear-PATH',
	'Set-EnvironmentVariable'
) -Alias @(
	'Clear-Env',
	'Remove-Env',
	'Remove-EnvironmentVariable',
	'Remove-PATH',
	'Set-Env'
)
