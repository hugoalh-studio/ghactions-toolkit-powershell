#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-invoke.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
Function Expand-ToolCacheCompressedFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_expand-githubactionstoolcachecompressedfile#Expand-GitHubActionsToolCacheCompressedFile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Source')][String]$File,
		[Alias('Target')][String]$Destination,
		[ValidateSet('7z', 'A', 'Auto', 'Automatic', 'Automatically', 'Tar', 'Xar', 'Zip')][String]$Method = 'Automatically',
		[String]$7zrPath,
		[Alias('Flags')][String]$Flag
	)
	If (!(Test-Path -LiteralPath $File -PathType 'Leaf')) {
		Return (Write-Error -Message "``$File`` is not a valid file path!" -Category 'SyntaxError')
	}
	If ($Method -imatch '^A(?:uto(?:matic(?:ally)?)?)?$') {
		Switch -RegEx ($File) {
			'\.7z$' {
				$Method = '7z'
				Break
			}
			'\.pkg$' {
				$Method = 'Xar'
				Break
			}
			'\.tar$' {
				$Method = 'Tar'
				Break
			}
			'\.tar\.gz$' {
				$Method = 'Tar'
				Break
			}
			'\.zip$' {
				$Method = 'Zip'
				Break
			}
			Default {
				$Method = '7z'
				Break
			}
		}
	}
	[Hashtable]$InputObject = @{
		File = $File
	}
	If ($Destination.Length -igt 0) {
		$InputObject.Destination = $Destination
	}
	If ($7zrPath.Length -igt 0) {
		$InputObject['7zrPath'] = $7zrPath
	}
	If ($Flag.Length -igt 0) {
		$InputObject.Flag = $Flag
	}
	$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\extract-$($Method.ToLower()).js" -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
	If ($ResultRaw -ieq $False) {
		Return
	}
	Return ($ResultRaw | ConvertFrom-Json -Depth 100).Path
}
Set-Alias -Name 'Expand-ToolCacheFile' -Value 'Expand-ToolCacheCompressedFile' -Option 'ReadOnly' -Scope 'Local'
