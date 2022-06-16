#Requires -PSEdition Core
#Requires -Version 7.2
[String]$ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath 'module'
[String[]]$ModulesName = @(
	'command-base',
	'command-control',
	'environment-variable',
	'log',
	'oidc',
	'parameter',
	'problem-matcher',
	'step-summary',
	'utility'
)
[String[]]$ModulesFullName = $ModulesName | ForEach-Object -Process {
	return Join-Path -Path $ModuleRoot -ChildPath "$_.psm1"
}
Import-Module -Name $ModulesFullName -Scope 'Local'
[PSCustomObject[]]$ModulesCommands = Get-Command -Module $ModulesName -ListImported
[String[]]$ModulesCommandsFunctions = ($ModulesCommands | Where-Object -FilterScript {
	return ($_.CommandType -ieq 'Function')
}).Name
[String[]]$ModulesCommandsAliases = ($ModulesCommands | Where-Object -FilterScript {
	return ($_.CommandType -ieq 'Alias')
}).Name
Export-ModuleMember -Function $ModulesCommandsFunctions -Alias $ModulesCommandsAliases
