#Requires -PSEdition Core -Version 7.2
[String[]]$ModulesName = @(
	'artifact',
	'cache',
	'command-base',
	'command-control',
	'environment-variable',
	'log',
	'markup',
	'nodejs-wrapper',
	'open-id-connect',
	'parameter',
	'problem-matcher',
	'step-summary',
	'tool-cache',
	'utility'
)
Import-Module -Name (
	$ModulesName |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath 'module' -AdditionalChildPath "$_.psm1" }
) -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module $ModulesName -ListImported
[String[]]$PackageFunctions = $PackageCommands |
	Where-Object -FilterScript { $_.CommandType -ieq 'Function' } |
	Select-Object -ExpandProperty 'Name'
[String[]]$PackageAliases = $PackageCommands |
	Where-Object -FilterScript { $_.CommandType -ieq 'Alias' } |
	Select-Object -ExpandProperty 'Name'
Export-ModuleMember -Function $PackageFunctions -Alias $PackageAliases
