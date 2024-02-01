#Requires -PSEdition Core -Version 7.2
<#
This script is help for build package.
#>
Param (
	[Switch]$SkipNodeJSModules
)
$ErrorActionPreference = 'Stop'
[String]$PackageRoot = Join-Path -Path $PSScriptRoot -ChildPath 'hugoalh.GitHubActionsToolkit'
[String]$PackageWrapperRoot = Join-Path -Path $PackageRoot -ChildPath 'nodejs-wrapper'
$OriginalLocation = Get-Location
Set-Location -LiteralPath $PSScriptRoot
npm run wrapper-transform
@(
	@{
		Destination = 'LICENSE.md'
		Source = 'LICENSE.md'
	},
	@{
		Destination = Join-Path -Path 'nodejs-wrapper' -ChildPath 'package-lock.json'
		Source = 'package-lock.json'
	},
	@{
		Destination = Join-Path -Path 'nodejs-wrapper' -ChildPath 'package.json'
		Source = 'package.json'
	}
) |
	ForEach-Object -Process {
		Copy-Item -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath $_.Source) -Destination (Join-Path -Path $PackageRoot -ChildPath $_.Destination) -Recurse -Confirm:$False
	}
If (!$SkipNodeJSModules.IsPresent) {
	Set-Location -LiteralPath $PackageWrapperRoot
	npm install --ignore-scripts --omit dev
}
Set-Location -LiteralPath $OriginalLocation
