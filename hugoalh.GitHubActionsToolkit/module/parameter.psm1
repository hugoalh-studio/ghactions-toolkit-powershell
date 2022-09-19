#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base.psm1',
		'log.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get input.
.PARAMETER Name
Name of the input.
.PARAMETER Mandatory
The input whether is mandatory; If mandatory but not exist, will throw an error.
.PARAMETER MandatoryMessage
Message when the input is mandatory but not exist.
.PARAMETER NamePrefix
Name of the inputs start with.
.PARAMETER NameSuffix
Name of the inputs end with.
.PARAMETER All
Get all of the inputs.
.PARAMETER EmptyStringAsNull
Assume empty string of input's value as `$Null`.
.PARAMETER Trim
Trim the input's value.
.OUTPUTS
[Hashtable] Inputs.
[String] Input value.
#>
Function Get-Input {
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsinput#Get-GitHubActionsInput')]
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
				$OutputObject[$Item.Name -ireplace '^INPUT_', ''] = $Item.Value
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
				$OutputObject[$Item.Name -ireplace $InputNameReplaceRegEx, ''] = $Item.Value
			}
		}
		'Suffix' {
			[RegEx]$InputNameReplaceRegEx = "^INPUT_|$([RegEx]::Escape($NameSuffix))$"
			ForEach ($Item In (Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())")) {
				$OutputObject[$Item.Name -ireplace $InputNameReplaceRegEx, ''] = $Item.Value
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
Get all of the states.
.PARAMETER EmptyStringAsNull
Assume empty string of state's value as `$Null`.
.PARAMETER Trim
Trim the state's value.
.OUTPUTS
[Hashtable] States.
[String] State value.
#>
Function Get-State {
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstate#Get-GitHubActionsState')]
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
				$OutputObject[$Item.Name -ireplace '^STATE_', ''] = $Item.Value
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
				$OutputObject[$Item.Name -ireplace $StateNameReplaceRegEx, ''] = $Item.Value
			}
		}
		'Suffix' {
			[RegEx]$StateNameReplaceRegEx = "^STATE_|$([RegEx]::Escape($NameSuffix))$"
			ForEach ($Item In (Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())")) {
				$OutputObject[$Item.Name -ireplace $StateNameReplaceRegEx, ''] = $Item.Value
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
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsoutput#Set-GitHubActionsOutput')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions output name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][String]$Value
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				$InputObject.GetEnumerator() |
					ForEach-Object -Process {
						If ($_.Name.GetType().Name -ine 'String') {
							Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
							Return
						}
						If ($_.Name -inotmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
							Write-Error -Message "``$($_.Name)`` is not a valid GitHub Actions output name!" -Category 'SyntaxError'
							Return
						}
						If ($_.Value.GetType().Name -ine 'String') {
							Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
							Return
						}
						Write-GitHubActionsCommand -Command 'set-output' -Parameter @{ 'name' = $_.Name } -Value $_.Value
					}
			}
			'Single' {
				Write-GitHubActionsCommand -Command 'set-output' -Parameter @{ 'name' = $Name } -Value $Value
			}
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
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstate#Set-GitHubActionsState')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][String]$Value
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				$InputObject.GetEnumerator() |
					ForEach-Object -Process {
						If ($_.Name.GetType().Name -ine 'String') {
							Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
							Return
						}
						If ($_.Name -inotmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
							Write-Error -Message "``$($_.Name)`` is not a valid GitHub Actions state name!" -Category 'SyntaxError'
							Return
						}
						If ($_.Value.GetType().Name -ine 'String') {
							Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
							Return
						}
						Write-GitHubActionsCommand -Command 'save-state' -Parameter @{ 'name' = $_.Name } -Value $_.Value
					}
			}
			'Single' {
				Write-GitHubActionsCommand -Command 'save-state' -Parameter @{ 'name' = $Name } -Value $Value
			}
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
