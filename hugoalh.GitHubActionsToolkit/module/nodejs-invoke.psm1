#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'internal\new-random-token',
		'nodejs-test'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
[String]$WrapperPath = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper' -AdditionalChildPath @('dist', 'main.js')
<#
.SYNOPSIS
GitHub Actions - Invoke NodeJS Wrapper
.DESCRIPTION
Invoke NodeJS wrapper.
.PARAMETER Name
Name of the NodeJS wrapper.
.PARAMETER InputObject
Arguments of the NodeJS wrapper.
.OUTPUTS
[PSCustomObject] Result of the NodeJS wrapper.
[PSCustomObject[]] Result of the NodeJS wrapper.
#>
Function Invoke-NodeJsWrapper {
	[CmdletBinding()]
	[OutputType(([PSCustomObject], [PSCustomObject[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Name,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Argument', 'Arguments', 'Input', 'Object', 'Parameter', 'Parameters')][Hashtable]$InputObject
	)
	If (!(Test-GitHubActionsNodeJsEnvironment)) {
		Write-Error -Message 'This function requires to invoke with the compatible NodeJS environment!' -Category 'ResourceUnavailable'
		Return
	}
	If (!(Test-Path -LiteralPath $WrapperPath -PathType 'Leaf')) {
		Write-Error -Message 'Wrapper is missing!' -Category 'ResourceUnavailable'
		Return
	}
	[String]$ResultSeparator = "=====$(New-GitHubActionsRandomToken -Length 32)====="
	Try {
		[String[]]$Result = Invoke-Expression -Command "node --no-deprecation --no-warnings `"$WrapperPath`" `"$Name`" `"$([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((
			$InputObject |
				ConvertTo-Json -Depth 100 -Compress
		))))`" `"$ResultSeparator`""
		[UInt32[]]$ResultSkipIndex = @()
		For ([UInt32]$ResultIndex = 0; $ResultIndex -ilt $Result.Count; $ResultIndex++) {
			[String]$Item = $Result[$ResultIndex]
			If ($Item -imatch '^::.+?::.*$') {
				Write-Host -Object $Item
				$ResultSkipIndex += $ResultIndex
			}
		}
		If ($LASTEXITCODE -ine 0) {
			Throw "Unexpected exit code ``$LASTEXITCODE``! $(
				$Result |
					Select-Object -SkipIndex $ResultSkipIndex |
					Join-String -Separator "`n"
			)"
		}
		[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Result[$Result.IndexOf($ResultSeparator) + 1])) |
			ConvertFrom-Json -Depth 100 |
			Write-Output
	}
	Catch {
		Write-Error -Message "Unable to successfully invoke NodeJS wrapper ``$Name``: $_" -Category 'InvalidData'
	}
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper'
)
