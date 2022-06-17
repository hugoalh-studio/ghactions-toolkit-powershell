#Requires -PSEdition Core
#Requires -Version 7.2
<#
This script is use for debug, and help to copy commands to hugoalh.GitHubActionsToolkit.psd1 file (for best performance).
#>
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'hugoalh.GitHubActionsToolkit.psm1') -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module 'hugoalh.GitHubActionsToolkit' -ListImported
foreach ($CommandType in @('Function', 'Alias')) {
	Set-Clipboard -Value "'$(($PackageCommands | Where-Object -FilterScript {
		return ($_.CommandType -ieq $CommandType)
	} | Sort-Object -Property 'Name').Name -join "',`n'")'" -Confirm
}
