#Requires -PSEdition Core
#Requires -Version 7.2
[Boolean]$EnvironmentResult = $False
[Boolean]$EnvironmentTested = $False
[SemVer]$NodeJsMinimumVersion = [SemVer]::Parse('14.15.0')
[RegEx]$SemVerRegEx = '^v?\d+\.\d+\.\d+$'
<#
.SYNOPSIS
GitHub Actions - Test NodeJS Environment
.DESCRIPTION
Test the current machine whether has compatible NodeJS environment; Test result always cache for reuse.
.PARAMETER Retest
Whether to redo this test by ignore the cached test result.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-NodeJsEnvironment {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Alias('Reinstall', 'ReinstallDependency', 'ReinstallPackage', 'ReinstallPackages')][Switch]$ReinstallDependencies,# Deprecated, keep as legacy.
		[Alias('Redo')][Switch]$Retest
	)
	If ($EnvironmentTested -and !$Retest.IsPresent) {
		Write-Verbose -Message 'Previously tested NodeJS environment; Return previous result.'
		Write-Output -InputObject $EnvironmentResult
		Return
	}
	$Script:EnvironmentResult = $False
	$Script:EnvironmentTested = $False
	Try {
		Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'Stop' |# `Get-Command` will throw error when nothing is found.
			Out-Null# No need the result.
		[String]$ExpressionNodeJsVersionResult = node --no-deprecation --no-warnings --version |
			Join-String -Separator "`n"
		If (
			$ExpressionNodeJsVersionResult -inotmatch $SemVerRegEx -or
			$NodeJsMinimumVersion -igt [SemVer]::Parse(($ExpressionNodeJsVersionResult -ireplace '^v', ''))
		) {
			Throw
		}
	}
	Catch {
		$Script:EnvironmentResult = $False
		$Script:EnvironmentTested = $True
		Write-Output -InputObject $EnvironmentResult
		Return
	}
	$Script:EnvironmentResult = $True
	$Script:EnvironmentTested = $True
	Write-Output -InputObject $EnvironmentResult
}
Export-ModuleMember -Function @(
	'Test-NodeJsEnvironment'
)
