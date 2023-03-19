#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'command-base',
		'internal\test-parameter-input-object',
		'log'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
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
.PARAMETER EmptyStringAsNull
Whether to assume empty string value of the input(s) as `$Null`.
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
		[Alias('AssumeEmptyStringAsNull')][Switch]$EmptyStringAsNull,
		[Switch]$Trim
	)
	[Hashtable]$OutputObject = @{}
	Switch ($PSCmdlet.ParameterSetName) {
		'All' {
			ForEach ($Item In (Get-ChildItem -Path 'Env:\INPUT_*')) {
				$OutputObject[$Item.Name -ireplace '^INPUT_', ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
		'One' {
			$InputValueRaw = Get-Content -LiteralPath "Env:\INPUT_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
			[String]$InputValue = $Trim.IsPresent ? ${InputValueRaw}?.Trim() : $InputValueRaw
			If (
				$Null -ieq $InputValueRaw -or
				($EmptyStringAsNull.IsPresent -and [String]::IsNullOrEmpty($InputValue))
			) {
				If ($Mandatory.IsPresent) {
					Write-GitHubActionsFail -Message ($MandatoryMessage -f $Name)
					Throw
				}
				Return
			}
			Write-Output -InputObject $InputValue
			Return
		}
		'Prefix' {
			[RegEx]$InputNameReplaceRegEx = "^INPUT_$([RegEx]::Escape($NamePrefix))"
			ForEach ($Item In (Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*")) {
				$OutputObject[$Item.Name -ireplace $InputNameReplaceRegEx, ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
		'Suffix' {
			[RegEx]$InputNameReplaceRegEx = "^INPUT_|$([RegEx]::Escape($NameSuffix))$"
			ForEach ($Item In (Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())")) {
				$OutputObject[$Item.Name -ireplace $InputNameReplaceRegEx, ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
	}
	Write-Output -InputObject $OutputObject
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
.PARAMETER EmptyStringAsNull
Whether to assume empty string value of the state(s) as `$Null`.
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
		[Alias('AssumeEmptyStringAsNull')][Switch]$EmptyStringAsNull,
		[Switch]$Trim
	)
	[Hashtable]$OutputObject = @{}
	Switch ($PSCmdlet.ParameterSetName) {
		'All' {
			ForEach ($Item In (Get-ChildItem -Path 'Env:\STATE_*')) {
				$OutputObject[$Item.Name -ireplace '^STATE_', ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
		'One' {
			$StateValueRaw = Get-Content -LiteralPath "Env:\STATE_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
			[String]$StateValue = $Trim.IsPresent ? ${StateValueRaw}?.Trim() : $StateValueRaw
			If (
				$Null -ieq $StateValueRaw -or
				($EmptyStringAsNull.IsPresent -and [String]::IsNullOrEmpty($StateValue))
			) {
				Return
			}
			Write-Output -InputObject $StateValue
			Return
		}
		'Prefix' {
			[RegEx]$StateNameReplaceRegEx = "^STATE_$([RegEx]::Escape($NamePrefix))"
			ForEach ($Item In (Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*")) {
				$OutputObject[$Item.Name -ireplace $StateNameReplaceRegEx, ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
		'Suffix' {
			[RegEx]$StateNameReplaceRegEx = "^STATE_|$([RegEx]::Escape($NameSuffix))$"
			ForEach ($Item In (Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())")) {
				$OutputObject[$Item.Name -ireplace $StateNameReplaceRegEx, ''] = $Trim.IsPresent ? ($Item.Value)?.Trim() : $Item.Value
			}
		}
	}
	Write-Output -InputObject $OutputObject
}
Set-Alias -Name 'Restore-State' -Value 'Get-State' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set Output
.DESCRIPTION
Set output.
.PARAMETER InputObject
Outputs.
.PARAMETER Name
Name of the output.
.PARAMETER Value
Value of the output.
.OUTPUTS
[Void]
#>
Function Set-Output {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsoutput')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][ValidateScript({ Test-GitHubActionsParameterInputObject -InputObject $_ })][Alias('Input', 'Object')]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions output name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][String]$Value
	)
	Begin {
		[Boolean]$UseLegacyMethod = [String]::IsNullOrWhiteSpace($Env:GITHUB_OUTPUT)
	}
	Process {
		If ($PSCmdlet.ParameterSetName -ieq 'Multiple') {
			If (
				$InputObject -is [Hashtable] -or
				$InputObject -is [System.Collections.Specialized.OrderedDictionary]
			) {
				$InputObject.GetEnumerator() |
					Set-Output
				Return
			}
			$InputObject |
				Set-Output
			Return
		}
		If ($UseLegacyMethod) {
			Write-GitHubActionsCommand -Command 'set-output' -Parameter @{ 'name' = $Name } -Value $Value
		}
		Else {
			Write-GitHubActionsFileCommand -LiteralPath $Env:GITHUB_OUTPUT -Name $Name -Value $Value
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Set State
.DESCRIPTION
Set state.
.PARAMETER InputObject
States.
.PARAMETER Name
Name of the state.
.PARAMETER Value
Value of the state.
.OUTPUTS
[Void]
#>
Function Set-State {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsstate')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][ValidateScript({ Test-GitHubActionsParameterInputObject -InputObject $_ })][Alias('Input', 'Object')]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][String]$Value
	)
	Begin {
		[Boolean]$UseLegacyMethod = [String]::IsNullOrWhiteSpace($Env:GITHUB_STATE)
	}
	Process {
		If ($PSCmdlet.ParameterSetName -ieq 'Multiple') {
			If (
				$InputObject -is [Hashtable] -or
				$InputObject -is [System.Collections.Specialized.OrderedDictionary]
			) {
				$InputObject.GetEnumerator() |
					Set-State
				Return
			}
			$InputObject |
				Set-State
			Return
		}
		If ($UseLegacyMethod) {
			Write-GitHubActionsCommand -Command 'save-state' -Parameter @{ 'name' = $Name } -Value $Value
		}
		Else {
			Write-GitHubActionsFileCommand -LiteralPath $Env:GITHUB_STATE -Name $Name -Value $Value
		}
	}
}
Set-Alias -Name 'Save-State' -Value 'Set-State' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Get-Input',
	'Get-State',
	'Set-Output',
	'Set-State'
) -Alias @(
	'Restore-State',
	'Save-State'
)
