#Requires -PSEdition Core
#Requires -Version 7.2
[String]$ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath 'module'
[String[]]$ModulesNames = @(
	'command-base',
	'artifact',
	'cache',
	'command-control',
	'environment-variable',
	'log',
	'nodejs-test',
	'open-id-connect',
	'parameter',
	'problem-matcher',
	'step-summary',
	'tool-cache',
	'utility'
)
Import-Module -Name ($ModulesNames | ForEach-Object -Process {
	Return (Join-Path -Path $ModuleRoot -ChildPath "$_.psm1")
}) -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module $ModulesNames -ListImported
[String[]]$PackageCommandsFunctions = ($PackageCommands | Where-Object -FilterScript { Return ($_.CommandType -ieq 'Function') }).Name
[String[]]$PackageCommandsAliases = ($PackageCommands | Where-Object -FilterScript { Return ($_.CommandType -ieq 'Alias') }).Name
Export-ModuleMember -Function $PackageCommandsFunctions -Alias $PackageCommandsAliases
