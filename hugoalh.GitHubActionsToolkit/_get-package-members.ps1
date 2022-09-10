#Requires -PSEdition Core
#Requires -Version 7.2
<#
This script is help for copy members to the file `hugoalh.GitHubActionsToolkit.psd1` for best performance, and use for debug.
#>
[String]$PackageName = 'hugoalh.GitHubActionsToolkit'
@(
	"$PackageName.psm1"
) |
	ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ } |
	Import-Module -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module $PackageName -ListImported
ForEach ($CommandType In @('Function', 'Alias')) {
	$PackageCommands |
		Where-Object -FilterScript { $_.CommandType -ieq $CommandType } |
		Select-Object -ExpandProperty 'Name' |
		Sort-Object |
		Join-String -Separator ",`n" -SingleQuote |
		Set-Clipboard -Confirm
}