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
.PARAMETER MandatoryMessage
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
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsinput#Get-GitHubActionsInput')]
	[OutputType([String], ParameterSetName = 'One')]
	[OutputType([Hashtable], ParameterSetName = ('All', 'Prefix', 'Suffix'))]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'One', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name!')][Alias('Key')][String]$Name,
		[Parameter(ParameterSetName = 'One')][Alias('Require', 'Required')][Switch]$Mandatory,
		[Parameter(ParameterSetName = 'One')][Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'Input `{0}` is not defined!',
		[Parameter(Mandatory = $true, ParameterSetName = 'Prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][String]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'Suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions input name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][String]$NameSuffix,
		[Parameter(ParameterSetName = 'All')][Switch]$All,
		[Alias('AssumeEmptyStringAsNull')][Switch]$EmptyStringAsNull,
		[Switch]$Trim
	)
	begin {
		[Hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'All' {
				foreach ($Item in (Get-ChildItem -Path 'Env:\INPUT_*')) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace '^INPUT_', ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
			'One' {
				$InputValueRaw = Get-Content -LiteralPath "Env:\INPUT_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -ieq $InputValueRaw) {
					if ($Mandatory) {
						return Write-GitHubActionsFail -Message ($MandatoryMessage -f $Name)
					}
					return $null
				}
				[String]$InputValue = $Trim ? $InputValueRaw.Trim() : $InputValueRaw
				if ($EmptyStringAsNull -and $InputValue.Length -ieq 0) {
					if ($Mandatory) {
						return Write-GitHubActionsFail -Message ($MandatoryMessage -f $Name)
					}
					return $null
				}
				return $InputValue
			}
			'Prefix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*")) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace "^INPUT_$([RegEx]::Escape($NamePrefix))", ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
			'Suffix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())")) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace "^INPUT_|$([RegEx]::Escape($NameSuffix))$", ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -iin @('All', 'Prefix', 'Suffix')) {
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
	[CmdletBinding(DefaultParameterSetName = 'One', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstate#Get-GitHubActionsState')]
	[OutputType([String], ParameterSetName = 'One')]
	[OutputType([Hashtable], ParameterSetName = ('All', 'Prefix', 'Suffix'))]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'One', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'Prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name prefix!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][String]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'Suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name suffix!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][String]$NameSuffix,
		[Parameter(ParameterSetName = 'All')][Switch]$All,
		[Alias('AssumeEmptyStringAsNull')][Switch]$EmptyStringAsNull,
		[Switch]$Trim
	)
	begin {
		[Hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'All' {
				foreach ($Item in (Get-ChildItem -Path 'Env:\STATE_*')) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace '^STATE_', ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
			'One' {
				$StateValueRaw = Get-Content -LiteralPath "Env:\STATE_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -ieq $StateValueRaw) {
					return $null
				}
				[String]$StateValue = $Trim ? $StateValueRaw.Trim() : $StateValueRaw
				if ($EmptyStringAsNull -and $StateValue.Length -ieq 0) {
					return $null
				}
				return $StateValue
			}
			'Prefix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*")) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace "^STATE_$([RegEx]::Escape($NamePrefix))", ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
			'Suffix' {
				foreach ($Item in (Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())")) {
					if ($null -ieq $Item.Value) {
						continue
					}
					[String]$ItemValue = $Trim ? $Item.Value.Trim() : $Item.Value
					if ($EmptyStringAsNull -and $ItemValue.Length -ieq 0) {
						continue
					}
					[String]$ItemName = $Item.Name -ireplace "^STATE_|$([RegEx]::Escape($NameSuffix))$", ''
					$OutputObject[$ItemName] = $ItemValue
				}
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -iin @('All', 'Prefix', 'Suffix')) {
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
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsoutput#Set-GitHubActionsOutput')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions output name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][String]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Name -inotmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($Item.Name)`` is not a valid GitHub Actions output name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					Write-GitHubActionsCommand -Command 'set-output' -Value $Item.Value -Parameter @{ 'name' = $Item.Name }
				}
			}
			'Single' {
				Write-GitHubActionsCommand -Command 'set-output' -Value $Value -Parameter @{ 'name' = $Name }
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
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstate#Set-GitHubActionsState')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions state name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][String]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Name -inotmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($Item.Name)`` is not a valid GitHub Actions state name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					Write-GitHubActionsCommand -Command 'save-state' -Value $Item.Value -Parameter @{ 'name' = $Item.Name }
				}
			}
			'Single' {
				Write-GitHubActionsCommand -Command 'save-state' -Value $Value -Parameter @{ 'name' = $Name }
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
