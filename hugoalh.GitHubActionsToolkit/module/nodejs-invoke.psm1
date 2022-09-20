#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'internal\token.psm1',
		'nodejs-test.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
<#
.SYNOPSIS
GitHub Actions (Private) - Invoke NodeJS Wrapper
.DESCRIPTION
Invoke NodeJS wrapper.
.PARAMETER Path
NodeJS wrapper path.
.PARAMETER InputObject
NodeJS wrapper parameters.
.OUTPUTS
[PSCustomObject] Wrapper result.
[PSCustomObject[]] Wrapper result.
#>
Function Invoke-NodeJsWrapper {
	[CmdletBinding()]
	[OutputType(([PSCustomObject], [PSCustomObject[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Path,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Input', 'Object', 'Parameter', 'Parameters')][PSCustomObject]$InputObject
	)
	If (!(Test-GitHubActionsNodeJsEnvironment)) {
		Write-Error -Message 'This function requires to invoke with the compatible NodeJS and NPM environment!' -Category 'ResourceUnavailable'
		Return
	}
	[String]$WrapperFullName = Join-Path -Path $WrapperRoot -ChildPath $Path
	If (!(Test-Path -LiteralPath $WrapperFullName -PathType 'Leaf')) {
		Write-Error -Message "``$Path`` is not an exist and valid NodeJS wrapper path! Most likely some of the files are missing." -Category 'ResourceUnavailable'
		Return
	}
	[String]$ResultSeparator = "=====$(New-GitHubActionsRandomToken -Length 32)====="
	Try {
		[String[]]$Result = node --no-deprecation --no-warnings "$($WrapperFullName -ireplace '\\', '/')" "$(
			$InputObject |
				ConvertTo-Json -Depth 100 -Compress
		)" "$ResultSeparator"
		[UInt32]$ResultSkipIndex = @()
		For ([UInt32]$ResultIndex = 0; $ResultIndex -ilt $Result.Count; $ResultIndex++) {
			[String]$Item = $Result[$ResultIndex]
			If ($Item -imatch '^::.+$') {
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
		$Result[($Result.IndexOf($ResultSeparator) + 1)..($Result.Count - 1)] |
			Join-String -Separator "`n" |
			ConvertFrom-Json -Depth 100 |
			Write-Output
	}
	Catch {
		Write-Error -Message "Unable to successfully invoke NodeJS wrapper ``$Path``! $_" -Category 'InvalidData'
	}
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper'
)
