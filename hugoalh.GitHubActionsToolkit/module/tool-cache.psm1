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
`7zr` path, for long path support (only when parameter `Method` is `7z`).

Most `.7z` archives do not have this problem, if `.7z` archive contains very long path, pass the path to `7zr` which will gracefully handle long paths, by default `7zdec` is used because it is a very small program and is bundled with the GitHub Actions NodeJS toolkit, however it does not support long paths, `7zr` is the reduced command line interface, it is smaller than the full command line interface, and it does support long paths, at the time of this writing, it is freely available from the LZMA SDK that is available on the 7-Zip website, be sure to check the current license agreement, if `7zr` is bundled with your action, then the path to `7zr` can be pass to this function.
.PARAMETER Flag
Flag to use for expand (only when parameter `Method` is `Tar` or `Xar`).
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
GitHub Actions - Find Tool Cache
.DESCRIPTION
Find the path of a tool in the local installed tool cache.
.PARAMETER Name
Tool name.
.PARAMETER Version
Tool version, by Semantic Versioning (SemVer).
.PARAMETER Architecture
Tool architecture.
.OUTPUTS
[String] Path of a version of a tool.
[String[]] Paths of all versions of a tool.
#>
Function Find-ToolCache {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_find-githubactionstoolcache#Find-GitHubActionsToolCache')]
	[OutputType(([String], [String[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('ToolName')][String]$Name,
		[Alias('Ver')][String]$Version = '*',
		[Alias('Arch')][String]$Architecture
	)
	If (!(Test-GitHubActionsEnvironment -ToolCache)) {
		Return (Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable')
	}
	[Hashtable]$InputObject = @{
		Name = $Name
	}
	[Boolean]$IsFindAll = $False
	If ($Version -ieq '*') {
		$IsFindAll = $True
	} ElseIf ($Version.Length -igt 0) {
		$InputObject.Version = $Version
	}
	If ($Architecture.Length -igt 0) {
		$InputObject.Architecture = $Architecture
	}
	$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\find$($IsFindAll ? '-all-versions' : '').js" -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
	If ($ResultRaw -ieq $False) {
		Return
	}
	[PSCUstomObject]$Result = ($ResultRaw | ConvertFrom-Json -Depth 100)
	Return ($IsFindAll ? $Result.Paths : $Result.Path)
}
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
			Try {
				$UriObject = $_ -as [System.Uri]
			} Catch {
				Return $False
			}
			Return (($Null -ine $UriObject.AbsoluteUri) -and ($_.Scheme -imatch '^https?$'))
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
<#
.SYNOPSIS
GitHub Actions - Register Tool Cache Directory
.DESCRIPTION
Register a tool directory to cache and install in the tool cache.
.PARAMETER Source
Tool directory.
.PARAMETER Name
Tool name.
.PARAMETER Version
Tool version, by Semantic Versioning (SemVer).
.PARAMETER Architecture
Tool architecture.
.OUTPUTS
[String] Tool cached path.
#>
Function Register-ToolCacheDirectory {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_register-githubactionstoolcachedirectory#Register-GitHubActionsToolCacheDirectory')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('SourceDirectory')]$Source,
		[Parameter(Mandatory = $True, Position = 1)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 2)][Alias('Ver')][String]$Version,
		[Alias('Arch')][String]$Architecture
	)
	If (!(Test-GitHubActionsEnvironment -ToolCache)) {
		Return (Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable')
	}
	[Hashtable]$InputObject = @{
		Source = $Source
		Name = $Name
		Version = $Version
	}
	If ($Architecture.Length -igt 0) {
		$InputObject.Architecture = $Architecture
	}
	$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\cache-directory.js" -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
	If ($ResultRaw -ieq $False) {
		Return
	}
	Return ($ResultRaw | ConvertFrom-Json -Depth 100).Path
}
<#
.SYNOPSIS
GitHub Actions - Register Tool Cache File
.DESCRIPTION
Register a tool file to cache and install in the tool cache.
.PARAMETER Source
Tool file.
.PARAMETER Target
Tool file in the tool cache.
.PARAMETER Name
Tool name.
.PARAMETER Version
Tool version, by Semantic Versioning (SemVer).
.PARAMETER Architecture
Tool architecture.
.OUTPUTS
[String] Tool cached path.
#>
Function Register-ToolCacheFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_register-githubactionstoolcachefile#Register-GitHubActionsToolCacheFile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('SourceFile')]$Source,
		[Parameter(Mandatory = $True, Position = 0)][Alias('TargetFile')]$Target,
		[Parameter(Mandatory = $True, Position = 1)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 2)][Alias('Ver')][String]$Version,
		[Alias('Arch')][String]$Architecture
	)
	If (!(Test-GitHubActionsEnvironment -ToolCache)) {
		Return (Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable')
	}
	[Hashtable]$InputObject = @{
		Source = $Source
		Target = $Target
		Name = $Name
		Version = $Version
	}
	If ($Architecture.Length -igt 0) {
		$InputObject.Architecture = $Architecture
	}
	$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\cache-file.js" -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
	If ($ResultRaw -ieq $False) {
		Return
	}
	Return ($ResultRaw | ConvertFrom-Json -Depth 100).Path
}
Export-ModuleMember -Function @(
	'Expand-ToolCacheCompressedFile',
	'Find-ToolCache',
	'Invoke-ToolCacheToolDownloader',
	'Register-ToolCacheDirectory',
	'Register-ToolCacheFile'
) -Alias @(
	'Expand-ToolCacheArchive',
	'Expand-ToolCacheCompressedArchive',
	'Expand-ToolCacheFile'
)
