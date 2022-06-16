#Requires -PSEdition Core
#Requires -Version 7.2
[Flags()] enum GitHubActionsEnvironmentVariableScopes {
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
Disable validator to not check the PATH is valid or not.
.PARAMETER Scope
Scope of PATH.
.OUTPUTS
Void
#>
function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][String[]]$Path,
		[Alias('NoValidate', 'SkipValidate', 'SkipValidator')][Switch]$NoValidator,
		[GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	begin {
		[String[]]$Result = @()
	}
	process {
		foreach ($Item in ($Path | Select-Object -Unique)) {
			if (!$NoValidator -and !(Test-Path -Path $Item -PathType 'Container' -IsValid)) {
				Write-Error -Message "``$Item`` is not a valid PATH!" -Category 'SyntaxError'
				continue
			}
			$Result += $Item
		}
	}
	end {
		if ($Result.Count -gt 0) {
			switch ($Scope -isplit ', ') {
				{ $_ -icontains 'Current' } {
					[String[]]$PATHRaw = [System.Environment]::GetEnvironmentVariable('PATH') -isplit [System.IO.Path]::PathSeparator
					$PATHRaw += $Result
					[System.Environment]::SetEnvironmentVariable('PATH', ($PATHRaw -join [System.IO.Path]::PathSeparator))
				}
				{ $_ -icontains 'Subsequent' } {
					Add-Content -LiteralPath $env:GITHUB_PATH -Value ($Result -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
				}
			}
		}
		return
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
Will not format environment variable name to uppercase.
.PARAMETER Scope
Scope of environment variable.
.OUTPUTS
Void
#>
function Set-EnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'Multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsenvironmentvariable#Set-GitHubActionsEnvironmentVariable')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][Hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidateScript({
			return ($_ -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $_ -inotmatch '^(?:CI|PATH)$' -and $_ -inotmatch '^(?:ACTIONS|GITHUB|RUNNER)_')
		}, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][String]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 1, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Value` must be in single line string!')][String]$Value,
		[Alias('NoToUppercase')][Switch]$NoToUpper,
		[GitHubActionsEnvironmentVariableScopes]$Scope = [GitHubActionsEnvironmentVariableScopes]3
	)
	begin {
		[Hashtable]$Result = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'Multiple' {
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if (
						$Item.Name -inotmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -or
						$Item.Name -imatch '^(?:CI|PATH)$' -or
						$Item.Name -imatch '^(?:ACTIONS|GITHUB|RUNNER)_'
					) {
						Write-Error -Message "``$($Item.Name)`` is not a valid environment variable name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ine 'String') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Value -inotmatch '^.+$') {
						Write-Error -Message 'Parameter `Value` must be in single line string!' -Category 'SyntaxError'
						continue
					}
					$Result[$NoToUpper ? $Item.Name : $Item.Name.ToUpper()] = $Item.Value
				}
			}
			'Single' {
				$Result[$NoToUpper ? $Name : $Name.ToUpper()] = $Value
			}
		}
	}
	end {
		if ($Result.Count -gt 0) {
			[PSCustomObject[]]$ResultEnumerator = $Result.GetEnumerator()
			switch ($Scope -isplit ', ') {
				{ $_ -icontains 'Current' } {
					foreach ($Item in $ResultEnumerator) {
						[System.Environment]::SetEnvironmentVariable($Item.Name, $Item.Value)
					}
				}
				{ $_ -icontains 'Subsequent' } {
					Add-Content -LiteralPath $env:GITHUB_ENV -Value (($ResultEnumerator | ForEach-Object -Process {
						return "$($_.Name)=$($_.Value)"
					}) -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
				}
			}
		}
		return
	}
}
Set-Alias -Name 'Set-Env' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Set-Environment' -Value 'Set-EnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Add-PATH',
	'Set-EnvironmentVariable'
) -Alias @(
	'Set-Env',
	'Set-Environment'
)
