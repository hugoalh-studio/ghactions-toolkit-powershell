#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-file.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'log.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Clear Output
.DESCRIPTION
Clear output that set in the current step.
.OUTPUTS
[Void]
#>
Function Clear-Output {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_cleargithubactionsoutput')]
	[OutputType([Void])]
	Param ()
	Clear-GitHubActionsFileCommand -FileCommand 'GITHUB_OUTPUT'
}
Set-Alias -Name 'Remove-Output' -Value 'Clear-Output' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Clear State
.DESCRIPTION
Clear state that set in the current step.
.OUTPUTS
[Void]
#>
Function Clear-State {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_cleargithubactionsstate')]
	[OutputType([Void])]
	Param ()
	Clear-GitHubActionsFileCommand -FileCommand 'GITHUB_STATE'
}
Set-Alias -Name 'Remove-State' -Value 'Clear-State' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get input.
.PARAMETER Name
Name of the input.
.PARAMETER Mandatory
Whether the input is mandatory; If mandatory but not exist, will throw an error.
.PARAMETER MandatoryMessage
Message when the input is mandatory but not exist.
.PARAMETER NamePrefix
Name of the inputs start with.
.PARAMETER NameSuffix
Name of the inputs end with.
.PARAMETER All
Whether to get all of the inputs.
.PARAMETER Trim
Whether to trim the value of the input(s).
.OUTPUTS
[Hashtable] Inputs.
[String] Value of the input.
#>
Function Get-Input {
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsinput')]
	[OutputType([String], ParameterSetName = 'One')]
	[OutputType([Hashtable], ParameterSetName = ('All', 'Prefix', 'Suffix'))]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'One', Position = 0)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name!')][Alias('Key')][String]$Name,
		[Parameter(ParameterSetName = 'One')][Alias('Require', 'Required')][Switch]$Mandatory,
		[Parameter(ParameterSetName = 'One')][Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'Input `{0}` is not defined!',
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(Mandatory = $True, ParameterSetName = 'Prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][String]$NamePrefix,
		[Parameter(Mandatory = $True, ParameterSetName = 'Suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][String]$NameSuffix,
		[Switch]$Trim
	)
	Switch ($PSCmdlet.ParameterSetName) {
		'All' {
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path 'Env:\INPUT_*')) {
				$Result.($Item.Name -ireplace '^INPUT_', '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
		'One' {
			$InputValueRaw = [System.Environment]::GetEnvironmentVariable("INPUT_$($Name.ToUpper())")
			[AllowEmptyString()][AllowNull()][String]$InputValue = $Trim.IsPresent ? ($InputValueRaw)?.Trim() : $InputValueRaw
			If ([String]::IsNullOrEmpty($InputValue)) {
				If ($Mandatory.IsPresent) {
					Write-GitHubActionsFail -Message ($MandatoryMessage -f $Name)
					Throw
				}
				Return
			}
			$InputValue |
				Write-Output
			Return
		}
		'Prefix' {
			[String]$InputNameReplaceRegEx = "^INPUT_$([RegEx]::Escape($NamePrefix.ToUpper()))"
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*")) {
				$Result.($Item.Name -ireplace $InputNameReplaceRegEx, '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
		'Suffix' {
			[String]$InputNameReplaceRegEx = "^INPUT_|$([RegEx]::Escape($NameSuffix.ToUpper()))$"
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())")) {
				$Result.($Item.Name -ireplace $InputNameReplaceRegEx, '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Get State
.DESCRIPTION
Get state.
.PARAMETER Name
Name of the state.
.PARAMETER NamePrefix
Name of the states start with.
.PARAMETER NameSuffix
Name of the states end with.
.PARAMETER All
Whether to get all of the states.
.PARAMETER Trim
Whether to trim the value of the state(s).
.OUTPUTS
[Hashtable] States.
[String] Value of the state.
#>
Function Get-State {
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsstate')]
	[OutputType([String], ParameterSetName = 'One')]
	[OutputType([Hashtable], ParameterSetName = ('All', 'Prefix', 'Suffix'))]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'One', Position = 0)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(Mandatory = $True, ParameterSetName = 'Prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][String]$NamePrefix,
		[Parameter(Mandatory = $True, ParameterSetName = 'Suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][String]$NameSuffix,
		[Switch]$Trim
	)
	Switch ($PSCmdlet.ParameterSetName) {
		'All' {
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path 'Env:\STATE_*')) {
				$Result.($Item.Name -ireplace '^STATE_', '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
		'One' {
			$StateValueRaw = [System.Environment]::GetEnvironmentVariable("STATE_$($Name.ToUpper())")
			$Trim.IsPresent ? ($StateValueRaw)?.Trim() : $StateValueRaw |
				Write-Output
			Return
		}
		'Prefix' {
			[String]$StateNameReplaceRegEx = "^STATE_$([RegEx]::Escape($NamePrefix.ToUpper()))"
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*")) {
				$Result.($Item.Name -ireplace $StateNameReplaceRegEx, '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
		'Suffix' {
			[String]$StateNameReplaceRegEx = "^STATE_|$([RegEx]::Escape($NameSuffix.ToUpper()))$"
			[Hashtable]$Result = @{}
			ForEach ($Item In (Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())")) {
				$Result.($Item.Name -ireplace $StateNameReplaceRegEx, '') = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
			$Result |
				Write-Output
			Return
		}
	}
}
Set-Alias -Name 'Restore-State' -Value 'Get-State' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set Output
.DESCRIPTION
Set output.
.PARAMETER Name
Name of the output.
.PARAMETER Value
Value of the output.
.PARAMETER Optimize
Whether to have an optimize operation by replace exist command instead of add command directly.
.OUTPUTS
[Void]
#>
Function Set-Output {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsoutput')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions output name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$Optimize
	)
	Process {
		Write-GitHubActionsFileCommand -FileCommand 'GITHUB_OUTPUT' -Name $Name -Value $Value -Optimize:($Optimize.IsPresent)
	}
}
<#
.SYNOPSIS
GitHub Actions - Set State
.DESCRIPTION
Set state.
.PARAMETER Name
Name of the state.
.PARAMETER Value
Value of the state.
.PARAMETER Optimize
Whether to have an optimize operation by replace exist command instead of add command directly.
.OUTPUTS
[Void]
#>
Function Set-State {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsstate')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$Optimize
	)
	Process {
		Write-GitHubActionsFileCommand -FileCommand 'GITHUB_STATE' -Name $Name -Value $Value -Optimize:($Optimize.IsPresent)
	}
}
Set-Alias -Name 'Save-State' -Value 'Set-State' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Clear-Output',
	'Clear-State',
	'Get-Input',
	'Get-State',
	'Set-Output',
	'Set-State'
) -Alias @(
	'Remove-Output',
	'Remove-State',
	'Restore-State',
	'Save-State'
)
