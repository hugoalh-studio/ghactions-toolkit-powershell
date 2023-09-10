#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'new-random-token'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath 'internal' -AdditionalChildPath @("$_.psm1") }
) -Scope 'Local'
Import-Module -Name (
	@(
		'command-base'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
[String[]]$GitHubActionsStdOutCommands = @(
	'add-mask',
	'add-matcher',
	'add-path',# Legacy.
	'debug',
	'echo',
	'endgroup',
	'error',
	'group',
	'notice',
	'remove-matcher',
	'save-state',# Legacy.
	'set-env',# Legacy.
	'set-output',# Legacy.
	'stop-commands'
	'warning'
)
[String[]]$GitHubActionsStdOutCommandTokenUsed = @()
<#
.SYNOPSIS
GitHub Actions - Disable StdOut Command Echo
.DESCRIPTION
Disable echo most of the stdout commands, the log will not show the stdout command itself; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting; When process stdout command, it will still echo if there has any issues.
.OUTPUTS
[Void]
#>
Function Disable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disablegithubactionsstdoutcommandecho')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsStdOutCommand -StdOutCommand 'echo' -Value 'off'
}
Set-Alias -Name 'Disable-CommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-StdOutCommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable StdOut Command Process
.DESCRIPTION
Disable process all of the stdout commands, to allow log anything without accidentally execute any stdout command.
.PARAMETER EndToken
An end token for re-enable stdout command process.
.OUTPUTS
[String] An end token for re-enable stdout command process.
#>
Function Disable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disablegithubactionsstdoutcommandprocess')]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateScript({ Test-StdOutCommandToken -InputObject $_ }, ErrorMessage = 'Parameter `EndToken` is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	If ($EndToken.Length -eq 0) {
		Do {
			$EndToken = New-RandomToken
		}
		While ($EndToken -iin $GitHubActionsStdOutCommandTokenUsed)
	}
	$Script:GitHubActionsStdOutCommandTokenUsed += $EndToken
	Write-GitHubActionsStdOutCommand -StdOutCommand 'stop-commands' -Value $EndToken
	Write-Output -InputObject $EndToken
}
Set-Alias -Name 'Disable-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Suspend-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Suspend-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable StdOut Command Echo
.DESCRIPTION
Enable echo most of the stdout commands, the log will show the stdout command itself; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
[Void]
#>
Function Enable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enablegithubactionsstdoutcommandecho')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsStdOutCommand -StdOutCommand 'echo' -Value 'on'
}
Set-Alias -Name 'Enable-CommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-StdOutCommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable StdOut Command Process
.DESCRIPTION
Enable process all of the stdout commands, to allow execute any stdout command.
.PARAMETER EndToken
An end token from disable stdout command process.
.OUTPUTS
[Void]
#>
Function Enable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enablegithubactionsstdoutcommandprocess')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({ Test-StdOutCommandToken -InputObject $_ }, ErrorMessage = 'Parameter `EndToken` is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	Write-GitHubActionsStdOutCommand -StdOutCommand $EndToken
}
Set-Alias -Name 'Enable-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Resume-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Resume-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test StdOut Command Token
.DESCRIPTION
Test the GitHub Actions stdout command token whether is valid.
.PARAMETER InputObject
GitHub Actions stdout command token that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-StdOutCommandToken {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject.Length -ge 4 -and $InputObject -inotin $GitHubActionsStdOutCommands |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'Disable-StdOutCommandEcho',
	'Disable-StdOutCommandProcess',
	'Enable-StdOutCommandEcho',
	'Enable-StdOutCommandProcess'
) -Alias @(
	'Disable-CommandEcho',
	'Disable-CommandProcess',
	'Enable-CommandEcho',
	'Enable-CommandProcess',
	'Resume-CommandProcess',
	'Resume-StdOutCommandProcess',
	'Start-CommandEcho',
	'Start-CommandProcess',
	'Start-StdOutCommandEcho',
	'Start-StdOutCommandProcess',
	'Stop-CommandEcho',
	'Stop-CommandProcess',
	'Stop-StdOutCommandEcho',
	'Stop-StdOutCommandProcess',
	'Suspend-CommandProcess',
	'Suspend-StdOutCommandProcess'
)
