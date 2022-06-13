#Requires -PSEdition Core
#Requires -Version 7.2
<#
This script is use for debug, and help to copy commands to hugoalh.GitHubActionsToolkit.psd1 file (for best performance).
#>
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'hugoalh.GitHubActionsToolkit.psm1') -Scope 'Local'
Get-Command -Module 'hugoalh.GitHubActionsToolkit' -ListImported
