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
.PARAMETER Mandatory
Whether the input is mandatory; If mandatory but not exist, will throw an error.
.PARAMETER MandatoryNotExistMessage
Message when the input is mandatory but not exist.
.PARAMETER NamePrefix
Name of the inputs start with.
.PARAMETER NameSuffix
Name of the inputs end with.
.PARAMETER All
Get all of the inputs.
.PARAMETER EmptyStringAsNull
Assume empty string of input's string as `$null`.
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
		[Parameter(ParameterSetName = 'one')][Alias('Require', 'Required')][switch]$Mandatory,
		[Parameter(ParameterSetName = 'one')][Alias('RequiredMessage', 'RequiredNotExistMessage', 'RequireMessage', 'RequireNotExistMessage')][string]$MandatoryNotExistMessage = 'Input `{0}` is not defined!',
		[Parameter(Mandatory = $true, ParameterSetName = 'prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][string]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][string]$NameSuffix,
		[Parameter(ParameterSetName = 'all')][switch]$All,
		[Alias('AssumeEmptyStringAsNull')][switch]$EmptyStringAsNull,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				foreach ($Item in (Get-ChildItem -Path 'Env:\INPUT_*')) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace '^INPUT_', ''
					$OutputObject[$ItemName] = $ItemValue
				}
				break
			}
			'one' {
				$InputValueRaw = Get-ChildItem -LiteralPath "Env:\INPUT_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $InputValueRaw) {
					if ($Mandatory) {
						return Write-GitHubActionsFail -Message ($MandatoryNotExistMessage -f $Name)
					}
					return $null
				}
				[string]$InputValue = $Trim ? $InputValueRaw.Value.Trim() : $InputValueRaw.Value
				if ($EmptyStringAsNull -and $InputValue.Length -eq 0) {
					if ($Mandatory) {
						return Write-GitHubActionsFail -Message ($MandatoryNotExistMessage -f $Name)
					}
					return $null
				}
				return $InputValue
			}
			'prefix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*")) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace "^INPUT_$([regex]::Escape($NamePrefix))", ''
					$OutputObject[$ItemName] = $ItemValue
				}
				break
			}
			'suffix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())")) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace "^INPUT_|$([regex]::Escape($NameSuffix))$", ''
					$OutputObject[$ItemName] = $ItemValue
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
.PARAMETER EmptyStringAsNull
Assume empty string of state's value as `$null`.
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
		[Alias('AssumeEmptyStringAsNull')][switch]$EmptyStringAsNull,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				foreach ($Item in (Get-ChildItem -Path 'Env:\STATE_*')) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace '^STATE_', ''
					$OutputObject[$ItemName] = $ItemValue
				}
				break
			}
			'one' {
				$StateValueRaw = Get-ChildItem -LiteralPath "Env:\STATE_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $StateValueRaw) {
					return $null
				}
				[string]$StateValue = $Trim ? $StateValueRaw.Value.Trim() : $StateValueRaw.Value
				if ($EmptyStringAsNull -and $StateValue.Length -eq 0) {
					return $null
				}
				return $StateValue
			}
			'prefix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*")) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace "^STATE_$([regex]::Escape($NamePrefix))", ''
					$OutputObject[$ItemName] = $ItemValue
				}
				break
			}
			'suffix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())")) {
					if ($null -eq $Item.Value) {
						continue
					}
					[string]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -eq 0) {
						continue
					}
					[string]$ItemName = $Item.Name -replace "^STATE_|$([regex]::Escape($NameSuffix))$", ''
					$OutputObject[$ItemName] = $ItemValue
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
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($Item.Name)`` is not a valid GitHub Actions output name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					Write-GitHubActionsCommand -Command 'set-output' -Message $Item.Value -Property @{ 'name' = $Item.Name }
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
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($Item.Name)`` is not a valid GitHub Actions state name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					Write-GitHubActionsCommand -Command 'save-state' -Message $Item.Value -Property @{ 'name' = $Item.Name }
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
