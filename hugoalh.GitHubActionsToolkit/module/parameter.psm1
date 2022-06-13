#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-base.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'log.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get input.
.PARAMETER Name
Name of the input.
.PARAMETER Require
Whether the input is require; If required and not present, will throw an error.
.PARAMETER RequireFailMessage
The error message when the input is required and not present.
.PARAMETER NamePrefix
Name of the inputs start with.
.PARAMETER NameSuffix
Name of the inputs end with.
.PARAMETER All
Get all of the inputs.
.PARAMETER Trim
Trim the input's value.
.OUTPUTS
Hashtable | String
#>
function Get-Input {
	[CmdletBinding(DefaultParameterSetName = 'one', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsinput#Get-GitHubActionsInput')]
	[OutputType([string], ParameterSetName = 'one')]
	[OutputType([hashtable], ParameterSetName = ('all', 'prefix', 'suffix'))]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'one', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name!')][Alias('Key')][string]$Name,
		[Parameter(ParameterSetName = 'one')][Alias('Force', 'Forced', 'Required')][switch]$Require,
		[Parameter(ParameterSetName = 'one')][Alias('ErrorMessage', 'FailMessage', 'RequireErrorMessage')][string]$RequireFailMessage = 'Input `{0}` is not defined!',
		[Parameter(Mandatory = $true, ParameterSetName = 'prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][string]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][string]$NameSuffix,
		[Parameter(ParameterSetName = 'all')][switch]$All,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				Get-ChildItem -Path 'Env:\INPUT_*' | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace '^INPUT_', ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
			'one' {
				$InputValue = Get-ChildItem -LiteralPath "Env:\INPUT_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $InputValue) {
					if ($Require) {
						return Write-GitHubActionsFail -Message ($RequireFailMessage -f $Name)
					}
					return $null
				}
				if ($Trim) {
					return $InputValue.Value.Trim()
				}
				return $InputValue.Value
			}
			'prefix' {
				Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*" | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace "^INPUT_$([regex]::Escape($NamePrefix))", ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
			'suffix' {
				Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())" | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace "^INPUT_|$([regex]::Escape($NameSuffix))$", ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -iin @('all', 'prefix', 'suffix')) {
			return $OutputObject
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
Get all of the states.
.PARAMETER Trim
Trim the state's value.
.OUTPUTS
Hashtable | String
#>
function Get-State {
	[CmdletBinding(DefaultParameterSetName = 'one', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstate#Get-GitHubActionsState')]
	[OutputType([string], ParameterSetName = 'one')]
	[OutputType([hashtable], ParameterSetName = ('all', 'prefix', 'suffix'))]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'one', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][string]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][string]$NameSuffix,
		[Parameter(ParameterSetName = 'all')][switch]$All,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				Get-ChildItem -Path 'Env:\STATE_*' | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace '^STATE_', ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
			'one' {
				$StateValue = Get-ChildItem -LiteralPath "Env:\STATE_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $StateValue) {
					return $null
				}
				if ($Trim) {
					return $StateValue.Value.Trim()
				}
				return $StateValue.Value
			}
			'prefix' {
				Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*" | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace "^STATE_$([regex]::Escape($NamePrefix))", ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
			'suffix' {
				Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())" | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace "^STATE_|$([regex]::Escape($NameSuffix))$", ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -iin @('all', 'prefix', 'suffix')) {
			return $OutputObject
		}
	}
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
Void
#>
function Set-Output {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsoutput#Set-GitHubActionsOutput')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions output name!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][string]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if ($_.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
					} elseif ($_.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($_.Name)`` is not a valid GitHub Actions output name!" -Category 'SyntaxError'
					} elseif ($_.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
					} else {
						Write-GitHubActionsCommand -Command 'set-output' -Message $_.Value -Property @{ 'name' = $_.Name }
					}
				}
				break
			}
			'single' {
				Write-GitHubActionsCommand -Command 'set-output' -Message $Value -Property @{ 'name' = $Name }
				break
			}
		}
	}
	end {
		return
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
Void
#>
function Set-State {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstate#Set-GitHubActionsState')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][string]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if ($_.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
					} elseif ($_.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($_.Name)`` is not a valid GitHub Actions state name!" -Category 'SyntaxError'
					} elseif ($_.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
					} else {
						Write-GitHubActionsCommand -Command 'save-state' -Message $_.Value -Property @{ 'name' = $_.Name }
					}
				}
				break
			}
			'single' {
				Write-GitHubActionsCommand -Command 'save-state' -Message $Value -Property @{ 'name' = $Name }
				break
			}
		}
	}
	end {
		return
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
