#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'internal\token.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Private) - Format Command Parameter Value
.DESCRIPTION
Format the command parameter value characters that can cause issues.
.PARAMETER InputObject
String that need to format the command parameter value characters.
.OUTPUTS
[String] A string that formatted the command parameter value characters.
#>
Function Format-CommandParameterValue {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		(Format-CommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A' |
			Write-Output
	}
}
Set-Alias -Name 'Format-CommandPropertyValue' -Value 'Format-CommandParameterValue' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Private) - Format Command Value
.DESCRIPTION
Format the command value characters that can cause issues.
.PARAMETER InputObject
String that need to format the command value characters.
.OUTPUTS
[String] A string that formatted the command value characters.
#>
Function Format-CommandValue {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D' |
			Write-Output
	}
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
.PARAMETER Parameter
Parameters of the command.
.PARAMETER Value
Value of the command.
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
	Process {
		Write-Host -Object "::$Command$(($Parameter.Count -igt 0) ? " $(
			$Parameter.GetEnumerator() |
				Sort-Object -Property 'Name' |
				ForEach-Object -Process { "$($_.Name)=$(Format-CommandParameterValue -InputObject $_.Value)" } |
				Join-String -Separator ','
		)" : '')::$(Format-CommandValue -InputObject $Value)"
	}
}
<#
.SYNOPSIS
GitHub Actions (Private) - Write File Command
.DESCRIPTION
Write file command to communicate with the runner machine.
.PARAMETER LiteralPath
Literal path of the file command.
.PARAMETER Name
Name.
.PARAMETER Value
Value.
.OUTPUTS
[Void]
#>
Function Write-FileCommand {
	[CmdletBinding()]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][String]$LiteralPath,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][String]$Value
	)
	Process {
		If ($Value -imatch '^.+$') {
			Add-Content -LiteralPath $LiteralPath -Value "$Name=$Value" -Confirm:$False -Encoding 'UTF8NoBOM'
		}
		Else {
			[String]$ItemRaw = "$Name=$Value" -ireplace '\r?\n', ''
			Do {
				[String]$Token = New-GitHubActionsRandomToken -Length 16
			}
			While ( $ItemRaw -imatch [RegEx]::Escape($Token) )
			@(
				"$Name<<$Token",
				$Value -ireplace '\r?\n', "`n",
				$Token
			) |
				Add-Content -LiteralPath $LiteralPath -Confirm:$False -Encoding 'UTF8NoBOM'
		}
	}
}
Export-ModuleMember -Function @(
	'Write-Command',
	'Write-FileCommand'
)
