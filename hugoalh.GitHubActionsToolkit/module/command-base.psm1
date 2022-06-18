#Requires -PSEdition Core
#Requires -Version 7.2
<#
.SYNOPSIS
GitHub Actions (Internal) - Format Command Parameter
.DESCRIPTION
Format command parameter characters that can cause issues.
.PARAMETER InputObject
String that need to format command parameter characters.
.OUTPUTS
String
#>
function Format-CommandParameter {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $true, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	return (Format-CommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A'
}
Set-Alias -Name 'Format-CommandProperty' -Value 'Format-CommandParameter' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Format Command Value
.DESCRIPTION
Format command value characters that can cause issues.
.PARAMETER InputObject
String that need to format command value characters.
.OUTPUTS
String
#>
function Format-CommandValue {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $true, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	return $InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D'
}
Set-Alias -Name 'Format-CommandContent' -Value 'Format-CommandValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-CommandMessage' -Value 'Format-CommandValue' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Command
.DESCRIPTION
Write command to communicate with the runner machine.
.PARAMETER Command
Command.
.PARAMETER Value
Command value.
.PARAMETER Parameter
Command parameter.
.OUTPUTS
Void
#>
function Write-Command {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionscommand#Write-GitHubActionsCommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid command!')][String]$Command,
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content', 'Message')][String]$Value = '',
		[Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)][Alias('Parameters', 'Property', 'Properties')][Hashtable]$Parameter = @{}
	)
	begin {}
	process {
		Write-Host -Object "::$Command$(($Parameter.Count -igt 0) ? " $(($Parameter.GetEnumerator() | Sort-Object -Property 'Name' | ForEach-Object -Process {
			return "$($_.Name)=$(Format-CommandParameter -InputObject $_.Value)"
		}) -join ',')" : '')::$(Format-CommandValue -InputObject $Value)"
	}
	end {
		return
	}
}
Export-ModuleMember -Function @(
	'Write-Command'
)
