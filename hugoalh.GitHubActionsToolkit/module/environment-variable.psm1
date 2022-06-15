#Requires -PSEdition Core
#Requires -Version 7.2
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
.OUTPUTS
Void
#>
function Add-EnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsenvironmentvariable#Add-GitHubActionsEnvironmentVariable')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidateScript({
			return ($_ -match '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $_ -notmatch '^PATH$')
		}, ErrorMessage = '`{0}` is not a valid environment variable name!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Value` must be in single line string!')][string]$Value
	)
	begin {
		[hashtable]$Result = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				foreach ($Item in $InputObject.GetEnumerator()) {
					if ($Item.Name.GetType().Name -ne 'String') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
						continue
					}
					if (
						$Item.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -or
						$Item.Name -match '^PATH$'
					) {
						Write-Error -Message "``$($Item.Name)`` is not a valid environment variable name!" -Category 'SyntaxError'
						continue
					}
					if ($Item.Value.GetType().Name -ne 'String') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
						continue
					}
					if ($Item.Value -notmatch '^.+$') {
						Write-Error -Message 'Parameter `Value` must be in single line string!' -Category 'SyntaxError'
						continue
					}
					$Result[$Item.Name.ToUpper()] = $Item.Value
				}
				break
			}
			'single' {
				$Result[$Name.ToUpper()] = $Value
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
.OUTPUTS
Void
#>
function Add-PATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][string[]]$Path,
		[Alias('NoValidate', 'SkipValidate', 'SkipValidator')][switch]$NoValidator
	)
	begin {
		[string[]]$Result = @()
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
