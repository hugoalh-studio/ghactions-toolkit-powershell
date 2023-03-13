#Requires -PSEdition Core
#Requires -Version 7.2
[String[]]$ModulesNames = @(
	'command-base',
	'artifact',
	'cache',
	'command-control',
	'environment-variable',
	'log',
	'nodejs-wrapper',
	'open-id-connect',
	'parameter',
	'problem-matcher',
	'step-summary',
	'tool-cache',
	'utility'
)
Import-Module -Name (
	$ModulesNames |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath 'module' -AdditionalChildPath "$_.psm1" }
) -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module $ModulesNames -ListImported
[String[]]$PackageCommandsFunctions = $PackageCommands |
	Where-Object -FilterScript { $_.CommandType -ieq 'Function' } |
	Select-Object -ExpandProperty 'Name'
[String[]]$PackageCommandsAliases = $PackageCommands |
	Where-Object -FilterScript { $_.CommandType -ieq 'Alias' } |
	Select-Object -ExpandProperty 'Name'
Export-ModuleMember -Function $PackageCommandsFunctions -Alias $PackageCommandsAliases
