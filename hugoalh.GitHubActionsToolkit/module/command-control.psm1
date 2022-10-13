#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base.psm1',
		'internal\token.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
[String[]]$GitHubActionsCommands = @(
	'add-mask',
	'add-matcher',
	'add-path',# Legacy
	'debug',
	'echo',
	'endgroup',
	'error',
	'group',
	'notice',
	'remove-matcher',
	'save-state',# Legacy
	'set-env',# Legacy
	'set-output',# Legacy
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
@(
	'Disable-CommandEcho',
	'Disable-CommandEchoing',
	'Disable-CommandsEcho',
	'Disable-CommandsEchoing',
	'Disable-EchoCommand',
	'Disable-EchoCommands',
	'Disable-EchoingCommand',
	'Stop-CommandEcho',
	'Stop-CommandEchoing',
	'Stop-CommandsEcho',
	'Stop-CommandsEchoing',
	'Stop-EchoCommand',
	'Stop-EchoCommands',
	'Stop-EchoingCommand',
	'Stop-EchoingCommands'
) |
	Set-Alias -Value 'Disable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Processing Commands
.DESCRIPTION
Disable processing any commands, to allow log anything without accidentally execute any commands.
.PARAMETER EndToken
An end token for the function `Enable-GitHubActionsProcessingCommands`.
.OUTPUTS
[String] An end token for the function `Enable-GitHubActionsProcessingCommands`.
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
@(
	'Disable-CommandProcess',
	'Disable-CommandProcessing',
	'Disable-CommandsProcess',
	'Disable-CommandsProcessing',
	'Disable-ProcessCommand',
	'Disable-ProcessCommands',
	'Disable-ProcessingCommand',
	'Stop-CommandProcess',
	'Stop-CommandProcessing',
	'Stop-CommandsProcess',
	'Stop-CommandsProcessing',
	'Stop-ProcessCommand',
	'Stop-ProcessCommands',
	'Stop-ProcessingCommand',
	'Stop-ProcessingCommands'
) |
	Set-Alias -Value 'Disable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
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
@(
	'Enable-CommandEcho',
	'Enable-CommandEchoing',
	'Enable-CommandsEcho',
	'Enable-CommandsEchoing',
	'Enable-EchoCommand',
	'Enable-EchoCommands',
	'Enable-EchoingCommand',
	'Start-CommandEcho',
	'Start-CommandEchoing',
	'Start-CommandsEcho',
	'Start-CommandsEchoing',
	'Start-EchoCommand',
	'Start-EchoCommands',
	'Start-EchoingCommand',
	'Start-EchoingCommands'
) |
	Set-Alias -Value 'Enable-EchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Processing Commands
.DESCRIPTION
Enable processing any commands, to allow execute any commands.
.PARAMETER EndToken
An end token from the function `Disable-GitHubActionsProcessingCommands`.
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
@(
	'Enable-CommandProcess',
	'Enable-CommandProcessing',
	'Enable-CommandsProcess',
	'Enable-CommandsProcessing',
	'Enable-ProcessCommand',
	'Enable-ProcessCommands',
	'Enable-ProcessingCommand',
	'Start-CommandProcess',
	'Start-CommandProcessing',
	'Start-CommandsProcess',
	'Start-CommandsProcessing',
	'Start-ProcessCommand',
	'Start-ProcessCommands',
	'Start-ProcessingCommand',
	'Start-ProcessingCommands'
) |
	Set-Alias -Value 'Enable-ProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Private) - New Commands End Token
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
		[String]$Result = New-GitHubActionsRandomToken -Length 64
	}
	While ( $Result -iin $GitHubActionsCommandsEndTokensUsed )
	$Script:GitHubActionsCommandsEndTokensUsed += $Result
	Write-Output -InputObject $Result
}
<#
.SYNOPSIS
GitHub Actions (Private) - Test Processing Commands End Token
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
