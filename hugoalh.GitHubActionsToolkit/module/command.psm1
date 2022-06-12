#Requires -PSEdition Core
#Requires -Version 7.2
<#
.SYNOPSIS
GitHub Actions (Internal) - Format Command
.DESCRIPTION
Escape command characters that can cause issues.
.PARAMETER InputObject
String that need to escape command characters.
.PARAMETER Property
Also escape command property characters.
.OUTPUTS
String
#>
function Format-GitHubActionsCommand {
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][string]$InputObject,
		[Alias('Properties')][switch]$Property
	)
	[string]$OutputObject = $InputObject -replace '%', '%25' -replace '\n', '%0A' -replace '\r', '%0D'
	if ($Property) {
		$OutputObject = $OutputObject -replace ',', '%2C' -replace ':', '%3A' -replace '=', '%3D'
	}
	return $OutputObject
}
Set-Alias -Name 'Format-GHActionsCommand' -Value 'Format-GitHubActionsCommand' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Command
.DESCRIPTION
Write command to communicate with the runner machine.
.PARAMETER Command
Command.
.PARAMETER Message
Message.
.PARAMETER Property
Command property.
.OUTPUTS
Void
#>
function Write-GitHubActionsCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionscommand#Write-GitHubActionsCommand')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Command` must be in single line string!')][string]$Command,
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message = '',
		[Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)][Alias('Properties')][hashtable]$Property = @{}
	)
	begin {}
	process {
		Write-Host -Object "::$Command$(($Property.Count -gt 0) ? " $(($Property.GetEnumerator() | Sort-Object -Property 'Name' | ForEach-Object -Process {
			return "$($_.Name)=$(Format-GitHubActionsCommand -InputObject $_.Value -Property)"
		}) -join ',')" : '')::$(Format-GitHubActionsCommand -InputObject $Message)"
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsCommand' -Value 'Write-GitHubActionsCommand' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Echoing Commands
.DESCRIPTION
Disable echoing of commands, the run's log will not show the command itself; A command is echoed if there are any errors processing the command; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Disable-GitHubActionsEchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsechoingcommands#Disable-GitHubActionsEchoingCommands')]
	[OutputType([void])]
	param ()
	return Write-GitHubActionsCommand -Command 'echo' -Message 'off'
}
Set-Alias -Name 'Disable-GHActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Processing Commands
.DESCRIPTION
Stop processing any commands to allow log anything without accidentally running commands.
.PARAMETER EndToken
An end token for function `Enable-GitHubActionsProcessingCommands`.
.OUTPUTS
String
#>
function Disable-GitHubActionsProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsprocessingcommands#Disable-GitHubActionsProcessingCommands')]
	[OutputType([string])]
	param (
		[Parameter(Position = 0)][ValidateScript({
			return ($_ -match '^.+$' -and $_.Length -ge 4 -and $_ -inotin @(
				'add-mask',
				'add-matcher',
				'debug',
				'echo',
				'endgroup',
				'error',
				'group',
				'notice',
				'remove-matcher',
				'save-state',
				'set-output',
				'warning'
			))
		}, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, not match any GitHub Actions commands, and unique!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][string]$EndToken = ((New-Guid).Guid -replace '-', '')
	)
	Write-GitHubActionsCommand -Command 'stop-commands' -Message $EndToken
	return $EndToken
}
Set-Alias -Name 'Disable-GHActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Echoing Commands
.DESCRIPTION
Enable echoing of commands, the run's log will show the command itself; Commands `add-mask`, `debug`, `warning`, and `error` do not support echoing because their outputs are already echoed to the log; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Enable-GitHubActionsEchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsechoingcommands#Enable-GitHubActionsEchoingCommands')]
	[OutputType([void])]
	param ()
	return Write-GitHubActionsCommand -Command 'echo' -Message 'on'
}
Set-Alias -Name 'Enable-GHActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Processing Commands
.DESCRIPTION
Resume processing any commands to allow running commands.
.PARAMETER EndToken
An end token from function `Disable-GitHubActionsProcessingCommands`.
.OUTPUTS
Void
#>
function Enable-GitHubActionsProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsprocessingcommands#Enable-GitHubActionsProcessingCommands')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][ValidateScript({
			return ($_ -match '^.+$' -and $_.Length -ge 4 -and $_ -inotin @(
				'add-mask',
				'add-matcher',
				'debug',
				'echo',
				'endgroup',
				'error',
				'group',
				'notice',
				'remove-matcher',
				'save-state',
				'set-output',
				'warning'
			))
		}, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][string]$EndToken
	)
	return Write-GitHubActionsCommand -Command $EndToken
}
Set-Alias -Name 'Enable-GHActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Disable-GitHubActionsEchoingCommands',
	'Disable-GitHubActionsProcessingCommands',
	'Enable-GitHubActionsEchoingCommands',
	'Enable-GitHubActionsProcessingCommands',
	'Write-GitHubActionsCommand'
) -Alias @(
	'Disable-GHActionsCommandEcho',
	'Disable-GHActionsCommandEchoing',
	'Disable-GHActionsCommandProcess',
	'Disable-GHActionsCommandProcessing',
	'Disable-GHActionsCommandsEcho',
	'Disable-GHActionsCommandsEchoing',
	'Disable-GHActionsCommandsProcess',
	'Disable-GHActionsCommandsProcessing',
	'Disable-GHActionsEchoCommand',
	'Disable-GHActionsEchoCommands',
	'Disable-GHActionsEchoingCommand',
	'Disable-GHActionsEchoingCommands',
	'Disable-GHActionsProcessCommand',
	'Disable-GHActionsProcessCommands',
	'Disable-GHActionsProcessingCommand',
	'Disable-GHActionsProcessingCommands',
	'Disable-GitHubActionsCommandEcho',
	'Disable-GitHubActionsCommandEchoing',
	'Disable-GitHubActionsCommandProcess',
	'Disable-GitHubActionsCommandProcessing',
	'Disable-GitHubActionsCommandsEcho',
	'Disable-GitHubActionsCommandsEchoing',
	'Disable-GitHubActionsCommandsProcess',
	'Disable-GitHubActionsCommandsProcessing',
	'Disable-GitHubActionsEchoCommand',
	'Disable-GitHubActionsEchoCommands',
	'Disable-GitHubActionsEchoingCommand',
	'Disable-GitHubActionsProcessCommand',
	'Disable-GitHubActionsProcessCommands',
	'Disable-GitHubActionsProcessingCommand',
	'Enable-GHActionsCommandEcho',
	'Enable-GHActionsCommandEchoing',
	'Enable-GHActionsCommandProcess',
	'Enable-GHActionsCommandProcessing',
	'Enable-GHActionsCommandsEcho',
	'Enable-GHActionsCommandsEchoing',
	'Enable-GHActionsCommandsProcess',
	'Enable-GHActionsCommandsProcessing',
	'Enable-GHActionsEchoCommand',
	'Enable-GHActionsEchoCommands',
	'Enable-GHActionsEchoingCommand',
	'Enable-GHActionsEchoingCommands',
	'Enable-GHActionsProcessCommand',
	'Enable-GHActionsProcessCommands',
	'Enable-GHActionsProcessingCommand',
	'Enable-GHActionsProcessingCommands',
	'Enable-GitHubActionsCommandEcho',
	'Enable-GitHubActionsCommandEchoing',
	'Enable-GitHubActionsCommandProcess',
	'Enable-GitHubActionsCommandProcessing',
	'Enable-GitHubActionsCommandsEcho',
	'Enable-GitHubActionsCommandsEchoing',
	'Enable-GitHubActionsCommandsProcess',
	'Enable-GitHubActionsCommandsProcessing',
	'Enable-GitHubActionsEchoCommand',
	'Enable-GitHubActionsEchoCommands',
	'Enable-GitHubActionsEchoingCommand',
	'Enable-GitHubActionsProcessCommand',
	'Enable-GitHubActionsProcessCommands',
	'Enable-GitHubActionsProcessingCommand',
	'Start-GHActionsCommandEcho',
	'Start-GHActionsCommandEchoing',
	'Start-GHActionsCommandProcess',
	'Start-GHActionsCommandProcessing',
	'Start-GHActionsCommandsEcho',
	'Start-GHActionsCommandsEchoing',
	'Start-GHActionsCommandsProcess',
	'Start-GHActionsCommandsProcessing',
	'Start-GHActionsEchoCommand',
	'Start-GHActionsEchoCommands',
	'Start-GHActionsEchoingCommand',
	'Start-GHActionsEchoingCommands',
	'Start-GHActionsProcessCommand',
	'Start-GHActionsProcessCommands',
	'Start-GHActionsProcessingCommand',
	'Start-GHActionsProcessingCommands',
	'Start-GitHubActionsCommandEcho',
	'Start-GitHubActionsCommandEchoing',
	'Start-GitHubActionsCommandProcess',
	'Start-GitHubActionsCommandProcessing',
	'Start-GitHubActionsCommandsEcho',
	'Start-GitHubActionsCommandsEchoing',
	'Start-GitHubActionsCommandsProcess',
	'Start-GitHubActionsCommandsProcessing',
	'Start-GitHubActionsEchoCommand',
	'Start-GitHubActionsEchoCommands',
	'Start-GitHubActionsEchoingCommand',
	'Start-GitHubActionsEchoingCommands',
	'Start-GitHubActionsProcessCommand',
	'Start-GitHubActionsProcessCommands',
	'Start-GitHubActionsProcessingCommand',
	'Start-GitHubActionsProcessingCommands',
	'Stop-GHActionsCommandEcho',
	'Stop-GHActionsCommandEchoing',
	'Stop-GHActionsCommandProcess',
	'Stop-GHActionsCommandProcessing',
	'Stop-GHActionsCommandsEcho',
	'Stop-GHActionsCommandsEchoing',
	'Stop-GHActionsCommandsProcess',
	'Stop-GHActionsCommandsProcessing',
	'Stop-GHActionsEchoCommand',
	'Stop-GHActionsEchoCommands',
	'Stop-GHActionsEchoingCommand',
	'Stop-GHActionsEchoingCommands',
	'Stop-GHActionsProcessCommand',
	'Stop-GHActionsProcessCommands',
	'Stop-GHActionsProcessingCommand',
	'Stop-GHActionsProcessingCommands',
	'Stop-GitHubActionsCommandEcho',
	'Stop-GitHubActionsCommandEchoing',
	'Stop-GitHubActionsCommandProcess',
	'Stop-GitHubActionsCommandProcessing',
	'Stop-GitHubActionsCommandsEcho',
	'Stop-GitHubActionsCommandsEchoing',
	'Stop-GitHubActionsCommandsProcess',
	'Stop-GitHubActionsCommandsProcessing',
	'Stop-GitHubActionsEchoCommand',
	'Stop-GitHubActionsEchoCommands',
	'Stop-GitHubActionsEchoingCommand',
	'Stop-GitHubActionsEchoingCommands',
	'Stop-GitHubActionsProcessCommand',
	'Stop-GitHubActionsProcessCommands',
	'Stop-GitHubActionsProcessingCommand',
	'Stop-GitHubActionsProcessingCommands',
	'Write-GHActionsCommand'
)
