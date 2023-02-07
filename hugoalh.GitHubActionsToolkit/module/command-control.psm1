#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base',
		'internal\new-random-token'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
[String[]]$GitHubActionsCommands = @(
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
[String[]]$GitHubActionsCommandsEndTokensUsed = @()
<#
.SYNOPSIS
GitHub Actions - Disable Echoing Commands
.DESCRIPTION
Disable echoing most of the commands, the log will not show the command itself; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting; When processing a command, it will still echo if there has any issues.
.OUTPUTS
[Void]
#>
Function Disable-EchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsechoingcommands#Disable-GitHubActionsEchoingCommands')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsCommand -Command 'echo' -Value 'off'
}
Set-Alias -Name 'Disable-CommandEcho' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandEchoing' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandsEcho' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandsEchoing' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-EchoCommand' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-EchoCommands' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-EchoingCommand' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandEcho' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandEchoing' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandsEcho' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandsEchoing' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-EchoCommand' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-EchoCommands' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-EchoingCommand' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-EchoingCommands' -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Processing Commands
.DESCRIPTION
Disable processing any commands, to allow log anything without accidentally execute any commands.
.PARAMETER EndToken
An end token for re-enable processing commands.
.OUTPUTS
[String] An end token for re-enable processing commands.
#>
Function Disable-ProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsprocessingcommands#Disable-GitHubActionsProcessingCommands')]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateScript({ Test-ProcessingCommandsEndToken -InputObject $_ }, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, not match any GitHub Actions commands, and unique!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken = (New-CommandsEndToken)
	)
	Write-GitHubActionsCommand -Command 'stop-commands' -Value $EndToken
	Write-Output -InputObject $EndToken
}
Set-Alias -Name 'Disable-CommandProcess' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandProcessing' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandsProcess' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-CommandsProcessing' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-ProcessCommand' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-ProcessCommands' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-ProcessingCommand' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandProcess' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandProcessing' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandsProcess' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandsProcessing' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-ProcessCommand' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-ProcessCommands' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-ProcessingCommand' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-ProcessingCommands' -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Echoing Commands
.DESCRIPTION
Enable echoing most of the commands, the log will show the command itself; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
[Void]
#>
Function Enable-EchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsechoingcommands#Enable-GitHubActionsEchoingCommands')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsCommand -Command 'echo' -Value 'on'
}
Set-Alias -Name 'Enable-CommandEcho' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandEchoing' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandsEcho' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandsEchoing' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-EchoCommand' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-EchoCommands' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-EchoingCommand' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandEcho' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandEchoing' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandsEcho' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandsEchoing' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-EchoCommand' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-EchoCommands' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-EchoingCommand' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-EchoingCommands' -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Processing Commands
.DESCRIPTION
Enable processing any commands, to allow execute any commands.
.PARAMETER EndToken
An end token from disable processing commands.
.OUTPUTS
[Void]
#>
Function Enable-ProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsprocessingcommands#Enable-GitHubActionsProcessingCommands')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({ Test-ProcessingCommandsEndToken -InputObject $_ }, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	Write-GitHubActionsCommand -Command $EndToken
}
Set-Alias -Name 'Enable-CommandProcess' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandProcessing' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandsProcess' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-CommandsProcessing' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-ProcessCommand' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-ProcessCommands' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-ProcessingCommand' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandProcess' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandProcessing' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandsProcess' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandsProcessing' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-ProcessCommand' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-ProcessCommands' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-ProcessingCommand' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-ProcessingCommands' -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - New Commands End Token
.DESCRIPTION
Generate a new GitHub Actions commands end token.
.OUTPUTS
[String] A new GitHub Actions commands end token.
#>
Function New-CommandsEndToken {
	[CmdletBinding()]
	[OutputType([String])]
	Param ()
	Do {
		[String]$Result = New-GitHubActionsRandomToken
	}
	While ( $Result -iin $GitHubActionsCommandsEndTokensUsed )
	$Script:GitHubActionsCommandsEndTokensUsed += $Result
	Write-Output -InputObject $Result
}
<#
.SYNOPSIS
GitHub Actions - Test Processing Commands End Token
.DESCRIPTION
Test the GitHub Actions processing commands end token whether is valid.
.PARAMETER InputObject
GitHub Actions processing commands end token that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ProcessingCommandsEndToken {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject.Length -ige 4 -and $InputObject -inotin $GitHubActionsCommands |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'Disable-EchoingCommands',
	'Disable-ProcessingCommands',
	'Enable-EchoingCommands',
	'Enable-ProcessingCommands'
) -Alias @(
	'Disable-CommandEcho',
	'Disable-CommandEchoing',
	'Disable-CommandProcess',
	'Disable-CommandProcessing',
	'Disable-CommandsEcho',
	'Disable-CommandsEchoing',
	'Disable-CommandsProcess',
	'Disable-CommandsProcessing',
	'Disable-EchoCommand',
	'Disable-EchoCommands',
	'Disable-EchoingCommand',
	'Disable-ProcessCommand',
	'Disable-ProcessCommands',
	'Disable-ProcessingCommand',
	'Enable-CommandEcho',
	'Enable-CommandEchoing',
	'Enable-CommandProcess',
	'Enable-CommandProcessing',
	'Enable-CommandsEcho',
	'Enable-CommandsEchoing',
	'Enable-CommandsProcess',
	'Enable-CommandsProcessing',
	'Enable-EchoCommand',
	'Enable-EchoCommands',
	'Enable-EchoingCommand',
	'Enable-ProcessCommand',
	'Enable-ProcessCommands',
	'Enable-ProcessingCommand',
	'Start-CommandEcho',
	'Start-CommandEchoing',
	'Start-CommandProcess',
	'Start-CommandProcessing',
	'Start-CommandsEcho',
	'Start-CommandsEchoing',
	'Start-CommandsProcess',
	'Start-CommandsProcessing',
	'Start-EchoCommand',
	'Start-EchoCommands',
	'Start-EchoingCommand',
	'Start-EchoingCommands',
	'Start-ProcessCommand',
	'Start-ProcessCommands',
	'Start-ProcessingCommand',
	'Start-ProcessingCommands',
	'Stop-CommandEcho',
	'Stop-CommandEchoing',
	'Stop-CommandProcess',
	'Stop-CommandProcessing',
	'Stop-CommandsEcho',
	'Stop-CommandsEchoing',
	'Stop-CommandsProcess',
	'Stop-CommandsProcessing',
	'Stop-EchoCommand',
	'Stop-EchoCommands',
	'Stop-EchoingCommand',
	'Stop-EchoingCommands',
	'Stop-ProcessCommand',
	'Stop-ProcessCommands',
	'Stop-ProcessingCommand',
	'Stop-ProcessingCommands'
)
