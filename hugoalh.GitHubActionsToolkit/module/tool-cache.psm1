#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-invoke.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Expand Tool Cache Compressed File
.DESCRIPTION
Expand a compressed archive/file.
.PARAMETER File
Compressed archive/file path.
.PARAMETER Destination
Expand destination path.
.PARAMETER Method
Method to expand compressed archive/file; Define this value will enforce to use defined method.
.PARAMETER 7zrPath
`7zr` path, for long path support (only for expand method is `7z`); Most `.7z` archives do not have this problem, if `.7z` archive contains very long path, pass the path to `7zr` which will gracefully handle long paths, by default `7zdec` is used because it is a very small program and is bundled with the GitHub Actions NodeJS toolkit, however it does not support long paths, `7zr` is the reduced command line interface, it is smaller than the full command line interface, and it does support long paths, at the time of this writing, it is freely available from the LZMA SDK that is available on the 7-Zip website, be sure to check the current license agreement, if `7zr` is bundled with your action, then the path to `7zr` can be pass to this function.
.PARAMETER Flag
Flag for expand method is `Tar` or `Xar`, to use for extraction.
.OUTPUTS
[String] Expand destination path.
#>
Function Expand-ToolCacheCompressedFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_expand-githubactionstoolcachecompressedfile#Expand-GitHubActionsToolCacheCompressedFile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Source')][String]$File,
		[Alias('Target')][String]$Destination,
		[ValidateSet('7z', 'Auto', 'Automatic', 'Automatically', 'Tar', 'Xar', 'Zip')][String]$Method = 'Automatically',
		[String]$7zrPath,
		[Alias('Flags')][String]$Flag
	)
	If (!(Test-GitHubActionsEnvironment -ToolCache)) {
		Return (Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable')
	}
	If (!(Test-Path -LiteralPath $File -PathType 'Leaf')) {
		Return (Write-Error -Message "``$File`` is not a valid file path!" -Category 'SyntaxError')
	}
	If ($Method -imatch '^Auto(?:matic(?:ally)?)?$') {
		Switch -RegEx ($File) {
			'\.7z$' {
				$Method = '7z'
				Break
			}
			'\.pkg$' {
				$Method = 'Xar'
				Break
			}
			'\.tar(?:\.gz)?$' {
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
Set-Alias -Name 'Expand-ToolCacheArchive' -Value 'Expand-ToolCacheCompressedFile' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Expand-ToolCacheCompressedArchive' -Value 'Expand-ToolCacheCompressedFile' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Expand-ToolCacheFile' -Value 'Expand-ToolCacheCompressedFile' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Invoke Tool Cache Tool Downloader
.DESCRIPTION
Download a tool from URI and stream it into a file.
.PARAMETER Uri
Tool URI.
.PARAMETER Destination
Tool destination path.
.PARAMETER Authorization
Tool URI request authorization.
.PARAMETER Header
Tool URI request header.
.OUTPUTS
[String[]] Path of the downloaded tool.
#>
Function Invoke-ToolCacheToolDownloader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_invoke-githubactionstoolcachetooldownloader#Invoke-GitHubActionsToolCacheToolDownloader')]
	[OutputType([String[]])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidateScript({
			$URIObject = $_ -as [System.URI]
			Return (($Null -ine $URIObject.AbsoluteURI) -and ($_ -imatch '^https?:\/\/'))
		}, ErrorMessage = '`{0}` is not a valid URI!')][Alias('Url')][String[]]$Uri,
		[Alias('Target')][String]$Destination,
		[Alias('Auth')][String]$Authorization,
		[Alias('Headers')][Hashtable]$Header
	)
	Begin {
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Return (Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable')
			Break# This is the best way to early terminate this function without terminate caller/invoker process.
		}
		[String[]]$OutputObject = @()
	}
	Process {
		ForEach ($Item In $Uri) {
			[Hashtable]$InputObject = @{
				Uri = $Item
			}
			If ($Destination.Length -igt 0) {
				$InputObject.Destination = $Destination
			}
			If ($Authorization.Length -igt 0) {
				$InputObject.Authorization = $Authorization
			}
			If ($Header.Count -igt 0) {
				$InputObject.Header = ([PSCustomObject]$Header | ConvertTo-Json -Depth 100 -Compress)
			}
			$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'tool-cache\download-tool.js' -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
			If ($ResultRaw -ieq $False) {
				Continue
			}
			$OutputObject += ($ResultRaw | ConvertFrom-Json -Depth 100).Path
		}
	}
	End {
		Return $OutputObject
	}
}
Export-ModuleMember -Function @(
	'Expand-ToolCacheCompressedFile',
	'Invoke-ToolCacheToolDownloader'
) -Alias @(
	'Expand-ToolCacheArchive',
	'Expand-ToolCacheCompressedArchive',
	'Expand-ToolCacheFile'
)
