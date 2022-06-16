#Requires -PSEdition Core
#Requires -Version 7.2
<#
This script is use for debug, and help to copy commands to hugoalh.GitHubActionsToolkit.psd1 file (for best performance).
#>
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'hugoalh.GitHubActionsToolkit.psm1') -Scope 'Local'
[PSCustomObject[]]$ModulesCommands = Get-Command -Module 'hugoalh.GitHubActionsToolkit' -ListImported
foreach ($Type in @('Function', 'Alias')) {
	Set-Clipboard -Value "'$(($ModulesCommands | Where-Object -FilterScript {
		return ($_.CommandType -ieq $Type)
	} | Sort-Object -Property 'Name').Name -join "',`n'")'" -Confirm
}
