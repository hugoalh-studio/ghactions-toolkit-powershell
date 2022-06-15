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
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][string]$InputObject
	)
	return (Format-CommandValue -InputObject $InputObject) -replace ',', '%2C' -replace ':', '%3A' -replace '=', '%3D'
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
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][string]$InputObject
	)
	return $InputObject -replace '%', '%25' -replace '\n', '%0A' -replace '\r', '%0D'
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
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Command` must be in single line string!')][string]$Command,
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content', 'Message')][string]$Value = '',
		[Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)][Alias('Parameters', 'Property', 'Properties')][hashtable]$Parameter = @{}
	)
	begin {}
	process {
		Write-Host -Object "::$Command$(($Parameter.Count -gt 0) ? " $(($Parameter.GetEnumerator() | Sort-Object -Property 'Name' | ForEach-Object -Process {
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
