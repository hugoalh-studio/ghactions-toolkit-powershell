#Requires -PSEdition Core
#Requires -Version 7.2
[Boolean]$EnvironmentResult = $False
[Boolean]$EnvironmentTested = $False
[SemVer]$NodeJsMinimumVersion = [SemVer]::Parse('14.15.0')
[SemVer]$NpmMinimumVersion = [SemVer]::Parse('6.14.8')
[RegEx]$SemVerRegEx = '^v?\d+\.\d+\.\d+$'
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
<#
.SYNOPSIS
GitHub Actions - Test NodeJS Environment
.DESCRIPTION
Test the current machine whether has compatible NodeJS and NPM environment, and has dependencies ready; Test result always cache for reuse.
.PARAMETER ReinstallDependencies
Force to reinstall dependencies even though available.
.PARAMETER Retest
Redo this test, ignore the cached test result.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-NodeJsEnvironment {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Alias('Reinstall', 'ReinstallDependency', 'ReinstallPackage', 'ReinstallPackages')][Switch]$ReinstallDependencies,
		[Alias('Redo')][Switch]$Retest
	)
	If ($EnvironmentTested -and !$ReinstallDependencies.IsPresent -and !$Retest.IsPresent) {
		Write-Verbose -Message 'Previously tested NodeJS environment; Return previous result.'
		Return $EnvironmentResult
	}
	$Script:EnvironmentTested = $False
	Try {
		Write-Verbose -Message 'Test NodeJS.'
		Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'Stop' | Out-Null# `Get-Command` will throw error when nothing is found.
		[String]$GetNodeJsVersionRawResult = (Invoke-Expression -Command 'node --no-deprecation --no-warnings --version' | Join-String -Separator "`n").Trim()
		If (
			$GetNodeJsVersionRawResult -inotmatch $SemVerRegEx -or
			$NodeJsMinimumVersion -igt [SemVer]::Parse(($GetNodeJsVersionRawResult -ireplace '^v', ''))
		) {
			Throw
		}
		Write-Verbose -Message 'Test NPM.'
		Get-Command -Name 'npm' -CommandType 'Application' -ErrorAction 'Stop' | Out-Null# `Get-Command` will throw error when nothing is found.
		[String[]]$GetNpmVersionRawResult = Invoke-Expression -Command 'npm --version'# NPM sometimes display other useless things which unable to suppress.
		If (
			$GetNpmVersionRawResult -inotmatch $SemVerRegEx -or
			$NpmMinimumVersion -igt [SemVer]::Parse(($Matches[0] -ireplace '^v', ''))
		) {
			Throw
		}
	} Catch {
		$Script:EnvironmentTested = $True
		$Script:EnvironmentResult = $False
		Return $EnvironmentResult
	}
	[String]$OriginalWorkingDirectory = (Get-Location).Path
	Write-Verbose -Message 'Test NodeJS dependencies.'
	Set-Location -LiteralPath $WrapperRoot
	Try {
		[String[]]$GetNpmPackageStatusResult = Invoke-Expression -Command 'npm outdated'
		If (
			$ReinstallDependencies.IsPresent -or
			$GetNpmPackageStatusResult -cmatch 'MISSING'
		) {
			Write-Verbose -Message 'Install/Reinstall dependencies.'
			Invoke-Expression -Command 'npm ci' | Out-Null
			If ($LASTEXITCODE -ine 0) {
				Throw
			}
		}
	} Catch {
		Set-Location -LiteralPath $OriginalWorkingDirectory
		$Script:EnvironmentTested = $True
		$Script:EnvironmentResult = $False
		Return $EnvironmentResult
	}
	Set-Location -LiteralPath $OriginalWorkingDirectory
	$Script:EnvironmentTested = $True
	$Script:EnvironmentResult = $True
	Return $EnvironmentResult
}
Export-ModuleMember -Function @(
	'Test-NodeJsEnvironment'
)
