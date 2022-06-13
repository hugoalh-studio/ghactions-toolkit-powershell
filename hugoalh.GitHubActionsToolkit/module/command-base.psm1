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
function Format-Command {
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
function Write-Command {
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
			return "$($_.Name)=$(Format-Command -InputObject $_.Value -Property)"
		}) -join ',')" : '')::$(Format-Command -InputObject $Message)"
	}
	end {
		return
	}
}
Export-ModuleMember -Function @(
	'Write-Command'
)
