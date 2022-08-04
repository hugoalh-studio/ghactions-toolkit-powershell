#Requires -PSEdition Core
#Requires -Version 7.2
Class GitHubActionsCommand {
	Static [String]EscapeContent([String]$InputObject) {
		Return [GitHubActionsCommand]::EscapeValue($InputObject)
	}
	Static [String]EscapeMessage([String]$InputObject) {
		Return [GitHubActionsCommand]::EscapeValue($InputObject)
	}
	Static [String]EscapeParameterValue([String]$InputObject) {
		Return ([GitHubActionsCommand]::EscapeValue($InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A')
	}
	Static [String]EscapePropertyValue([String]$InputObject) {
		Return [GitHubActionsCommand]::EscapeParameterValue($InputObject)
	}
	Static [String]EscapeValue([String]$InputObject) {
		Return ($InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D')
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Command
.DESCRIPTION
Write command to communicate with the runner machine.
.PARAMETER Command
Command.
.PARAMETER Parameter
Command parameter.
.PARAMETER Value
Command value.
.OUTPUTS
[Void]
#>
Function Write-Command {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionscommand#Write-GitHubActionsCommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions command!')][String]$Command,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Parameters', 'Properties', 'Property')][Hashtable]$Parameter,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Content', 'Message')][String]$Value
	)
	Begin {}
	Process {
		Write-Host -Object "::$Command$(($Parameter.Count -igt 0) ? " $($Parameter.GetEnumerator() | Sort-Object -Property 'Name' | ForEach-Object -Process {
			Return "$($_.Name)=$([GitHubActionsCommand]::EscapeParameterValue($_.Value))"
		} | Join-String -Separator ',')" : '')::$([GitHubActionsCommand]::EscapeValue($Value))"
	}
	End {}
}
Export-ModuleMember -Function @(
	'Write-Command'
)
