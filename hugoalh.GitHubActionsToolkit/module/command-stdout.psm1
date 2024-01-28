#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'internal\token.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
[String[]]$StdOutCommandsType = @(
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
	'stop-commands',
	'warning'
)
[String[]]$StdOutCommandTokensUsed = @()
<#
.SYNOPSIS
GitHub Actions - Disable StdOut Command Echo
.DESCRIPTION
Disable echo most of the stdout commands, the log will not show the stdout command itself unless there has any issues; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
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
		[Parameter(Position = 0)][ValidateScript({ Test-StdOutCommandToken -InputObject $_ }, ErrorMessage = 'Value is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	If ($EndToken.Length -eq 0) {
		Do {
			$EndToken = New-GitHubActionsRandomToken -NoUpperCase
		}
		While ($EndToken -iin $Script:StdOutCommandTokensUsed)
	}
	$Script:StdOutCommandTokensUsed += $EndToken
	Write-GitHubActionsStdOutCommand -StdOutCommand 'stop-commands' -Value $EndToken
	$EndToken |
		Write-Output
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
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({ Test-StdOutCommandToken -InputObject $_ }, ErrorMessage = 'Value is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
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
GitHub Actions - Internal - Format StdOut Command Value
.DESCRIPTION
Format GitHub Actions stdout command value.
.PARAMETER InputObject
Value.
.OUTPUTS
[String] A formatted GitHub Actions stdout command value.
#>
Function Format-StdOutCommandValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object', 'Value')][String]$InputObject
	)
	Return (($InputObject ?? '') -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D')
}
<#
.SYNOPSIS
GitHub Actions - Internal - Format StdOut Command Parameter Value
.DESCRIPTION
Format GitHub Actions stdout command parameter value.
.PARAMETER InputObject
Value.
.OUTPUTS
[String] A formatted GitHub Actions stdout command parameter value.
#>
Function Format-StdOutCommandParameterValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object', 'Value')][String]$InputObject
	)
	Return ((Format-StdOutCommandValue ($InputObject ?? '')) -ireplace ',', '%2C' -ireplace ':', '%3A')
}
<#
.SYNOPSIS
GitHub Actions - Internal - Test StdOut Command Token
.DESCRIPTION
Test the GitHub Actions stdout command token whether is valid.
.PARAMETER InputObject
GitHub Actions stdout command token that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-StdOutCommandToken {
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('EndKey', 'EndValue', 'Input', 'Key', 'Object', 'Token', 'Value')][String]$InputObject
	)
	Return ($InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject.Length -ge 4 -and $InputObject -inotin $StdOutCommandsType)
}
<#
.SYNOPSIS
GitHub Actions - Write StdOut Command
.DESCRIPTION
Write stdout command to communicate with the runner machine.
.PARAMETER StdOutCommand
StdOut command.
.PARAMETER Parameter
Parameters of the stdout command.
.PARAMETER Value
Value of the stdout command.
.OUTPUTS
[Void]
#>
Function Write-StdOutCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsstdoutcommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions stdout command!')][Alias('Command')][String]$StdOutCommand,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateScript({ $_ -is [Hashtable] -or $_ -is [PSCustomObject] -or $_ -is [Ordered] }, ErrorMessage = 'Value is not a Hashtable, PSCustomObject, or OrderedDictionary')][Alias('Parameters', 'Properties', 'Property')]$Parameter = @{},
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][Alias('Content', 'Message')][String]$Value
	)
	Process {
		[String[]]$ParameterNames = ([PSCustomObject]$Parameter).PSObject.Properties.Name
		Write-Host -Object "::$StdOutCommand$(($ParameterNames.Count -gt 0) ? " $(
			$ParameterNames |
				ForEach-Object -Process { "$_=$(Format-StdOutCommandParameterValue ($Parameter.($_) ?? ''))" } |
				Join-String -Separator ','
		)" : '')::$(Format-StdOutCommandValue ($Value ?? ''))"
	}
}
Set-Alias -Name 'Write-Command' -Value 'Write-StdOutCommand' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Disable-StdOutCommandEcho',
	'Disable-StdOutCommandProcess',
	'Enable-StdOutCommandEcho',
	'Enable-StdOutCommandProcess',
	'Write-StdOutCommand'
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
	'Suspend-StdOutCommandProcess',
	'Write-Command'
)
