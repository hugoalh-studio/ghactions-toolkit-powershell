#Requires -PSEdition Core
#Requires -Version 7.2
enum PowerShellEnvironmentVariableScope {
	Process = 0
	P = 0
	User = 1
	U = 1
	System = 2
	S = 2
}
<#
.SYNOPSIS
GitHub Actions (Internal) - Add Local Environment Variable
.DESCRIPTION
Add local environment variable.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
.PARAMETER NoClobber
Prevent to add environment variables that exist in the current step.
.PARAMETER Scope
Scope to add environment variables.
.OUTPUTS
Void
#>
function Add-LocalEnvironmentVariable {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][string]$Value,
		[Alias('NoOverride', 'NoOverwrite')][switch]$NoClobber,
		[PowerShellEnvironmentVariableScope]$Scope = 'Process'
	)
	[string]$NameUpper = $Name.ToUpper()
	if ($NoClobber -and $null -ne (Get-ChildItem -LiteralPath "Env:\$NameUpper" -ErrorAction 'SilentlyContinue')) {
		return Write-Error -Message "Environment variable ``$Name`` is exists in current step (no clobber)!" -Category 'ResourceExists'
	}
	switch ($Scope.GetHashCode()) {
		0 {
			return [System.Environment]::SetEnvironmentVariable($NameUpper, $Value, 'Process')
		}
		1 {
			return [System.Environment]::SetEnvironmentVariable($NameUpper, $Value, 'User')
		}
		2 {
			return [System.Environment]::SetEnvironmentVariable($NameUpper, $Value, 'Machine')
		}
	}
}
Set-Alias -Name 'Add-LocalEnv' -Value 'Add-LocalEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-LocalEnvironment' -Value 'Add-LocalEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Add Local PATH
.DESCRIPTION
Add local PATH.
.PARAMETER Path
Path.
.PARAMETER Scope
Scope to add PATH.
.OUTPUTS
Void
#>
function Add-LocalPATH {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][Alias('Paths')][string[]]$Path,
		[PowerShellEnvironmentVariableScope]$Scope = 'Process'
	)
	[string]$PATHOriginalRaw = ''
	switch ($Scope.GetHashCode()) {
		0 {
			$PATHOriginalRaw = [System.Environment]::GetEnvironmentVariable('PATH', 'Process')
		}
		1 {
			$PATHOriginalRaw = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
		}
		2 {
			$PATHOriginalRaw = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')
		}
	}
	[string[]]$PATHOriginal = $PATHOriginalRaw -split [System.IO.Path]::PathSeparator
	[string[]]$PATHNew = @()
	foreach($Item in $Path) {
		if ($Item -inotin $PATHOriginal) {
			$PATHNew += $Item
		}
	}
	return Add-LocalEnvironmentVariable -Name 'PATH' -Value (($PATHNew + $PATHOriginal) -join [System.IO.Path]::PathSeparator) -Scope $Scope
}
<#
.SYNOPSIS
GitHub Actions - Add Environment Variable
.DESCRIPTION
Add environment variable to all subsequent steps in the current job.
.PARAMETER InputObject
Environment variables.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
.PARAMETER NoClobber
Prevent to add environment variables that exist in the current step, or all subsequent steps in the current job.
.PARAMETER WithLocal
Also add to the current step.
.PARAMETER LocalScope
Local scope to add environment variables.
.OUTPUTS
Void
#>
function Add-EnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsenvironmentvariable#Add-GitHubActionsEnvironmentVariable')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Value` must be in single line string!')][string]$Value,
		[Alias('NoOverride', 'NoOverwrite')][switch]$NoClobber,
		[Alias('WithCurrent')][switch]$WithLocal,
		[Alias('LocalEnvironmentVariableScope')][PowerShellEnvironmentVariableScope]$LocalScope = 'Process'
	)
	begin {
		[hashtable]$Original = ConvertFrom-StringData -StringData (Get-Content -LiteralPath $env:GITHUB_ENV -Raw -Encoding 'UTF8NoBOM')
		[hashtable]$Result = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($Item.Name)`` is not a valid environment variable name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Value -notmatch '^.+$') {
						Write-Error -Message 'Parameter `Value` must be in single line string!' -Category 'SyntaxError'
						continue
					}
					[string]$ItemNameUpper = $Item.Name.ToUpper()
					if ($NoClobber -and $null -ne $Original[$ItemNameUpper]) {
						Write-Error -Message "Environment variable ``$($Item.Name)`` is exists in all subsequent steps (no clobber)!" -Category 'ResourceExists'
					} else {
						$Result[$ItemNameUpper] = $Item.Value
					}
					if ($WithLocal) {
						Add-LocalEnvironmentVariable -Name $ItemNameUpper -Value $Item.Value -NoClobber:$NoClobber -LocalScope $LocalScope
					}
				}
				break
			}
			'single' {
				[string]$NameUpper = $Name.ToUpper()
				if ($NoClobber -and $null -ne $Original[$NameUpper]) {
					Write-Error -Message "Environment variable ``$Name`` is exists in all subsequent steps (no clobber)!" -Category 'ResourceExists'
				} else {
					$Result[$NameUpper] = $Value
				}
				if ($WithLocal) {
					Add-LocalEnvironmentVariable -Name $NameUpper -Value $Value -NoClobber:$NoClobber -LocalScope $LocalScope
				}
				break
			}
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_ENV -Value (($Result.GetEnumerator() | ForEach-Object -Process {
				return "$($_.Name)=$($_.Value)"
			}) -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Add-Env' -Value 'Add-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-Environment' -Value 'Add-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add PATH
.DESCRIPTION
Add PATH to all subsequent steps in the current job.
.PARAMETER Path
Path.
.PARAMETER NoValidator
Disable validator to not check the path is valid or not.
.PARAMETER WithLocal
Also add to the current step.
.PARAMETER LocalScope
Local scope to add PATH.
.OUTPUTS
Void
#>
function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][string[]]$Path,
		[Alias('NoValidate', 'SkipValidate', 'SkipValidator')][switch]$NoValidator,
		[Alias('WithCurrent')][switch]$WithLocal,
		[Alias('LocalPATHScope')][PowerShellEnvironmentVariableScope]$LocalScope = 'Process'
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		foreach ($Item in $Path) {
			if ($Item -inotin $Result) {
				if (
					$NoValidator -or
					(Test-Path -Path $Item -PathType 'Container' -IsValid)
				) {
					$Result += $Item
				} else {
					Write-Error -Message "``$Item`` is not a valid PATH!" -Category 'SyntaxError'
				}
			}
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_PATH -Value ($Result -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Export-ModuleMember -Function @(
	'Add-EnvironmentVariable',
	'Add-PATH'
) -Alias @(
	'Add-Env',
	'Add-Environment'
)
