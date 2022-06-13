#Requires -PSEdition Core
#Requires -Version 7.2
[string]$ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath 'module'
[string[]]$ModulesName = @(
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
[string[]]$ModulesFullName = $ModulesName | ForEach-Object -Process {
	return Join-Path -Path $ModuleRoot -ChildPath "$_.psm1"
}
Import-Module -Name $ModulesFullName -Scope 'Local'
[pscustomobject[]]$ModulesCommands = Get-Command -Module $ModulesName -ListImported
[string[]]$ModulesCommandsFunctions = ($ModulesCommands | Where-Object -FilterScript {
	return ($_.CommandType -eq 'Function')
}).Name
[string[]]$ModulesCommandsAliases = ($ModulesCommands | Where-Object -FilterScript {
	return ($_.CommandType -eq 'Alias')
}).Name
Export-ModuleMember -Function $ModulesCommandsFunctions -Alias $ModulesCommandsAliases
