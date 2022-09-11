#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'nodejs-invoke.psm1',
		'utility.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
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
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Source')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Target')][String]$Destination,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateSet('7z', 'Auto', 'Automatic', 'Automatically', 'Tar', 'Xar', 'Zip')][String]$Method = 'Automatically',
		[String]$7zrPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Flags')][String]$Flag
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		If (!(Test-Path -LiteralPath $File -PathType 'Leaf')) {
			Write-Error -Message "``$File`` is not a valid file path!" -Category 'SyntaxError'
			Return
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
		(Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\extract-$($Method.ToLower()).js" -InputObject ([PSCustomObject]$InputObject))?.Path |
			Write-Output
	}
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
Tool version, by Semantic Versioning (SemVer); Default to all versions.
.PARAMETER Architecture
Tool architecture; Default to current machine architecture.
.OUTPUTS
[String] Path of a version of a tool.
[String[]] Paths of all versions of a tool.
#>
Function Find-ToolCache {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_find-githubactionstoolcache#Find-GitHubActionsToolCache')]
	[OutputType(([String], [String[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Ver')][String]$Version = '*',
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			Name = $Name
		}
		[Boolean]$IsFindAll = $False
		If ($Version -ieq '*') {
			$IsFindAll = $True
		}
		ElseIf ($Version.Length -igt 0) {
			$InputObject.Version = $Version
		}
		If ($Architecture.Length -igt 0) {
			$InputObject.Architecture = $Architecture
		}
		$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path "tool-cache\find$($IsFindAll ? '-all-versions' : '').js" -InputObject ([PSCustomObject]$InputObject)
		Write-Output -InputObject ($IsFindAll ? ${ResultRaw}?.Paths : ${ResultRaw}?.Path)
	}
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
[String] Path of the downloaded tool.
#>
Function Invoke-ToolCacheToolDownloader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_invoke-githubactionstoolcachetooldownloader#Invoke-GitHubActionsToolCacheToolDownloader')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidateScript({ ($Null -ine $_.AbsoluteUri) -and ($_.Scheme -imatch '^https?$') }, ErrorMessage = '`{0}` is not a valid URI!')][Alias('Source', 'Url')][Uri]$Uri,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Target')][String]$Destination,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Auth')][String]$Authorization,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Headers')][Hashtable]$Header
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			Uri = $Uri.ToString()
		}
		If ($Destination.Length -igt 0) {
			$InputObject.Destination = $Destination
		}
		If ($Authorization.Length -igt 0) {
			$InputObject.Authorization = $Authorization
		}
		If ($Header.Count -igt 0) {
			$InputObject.Header = [PSCustomObject]$Header
		}
		(Invoke-GitHubActionsNodeJsWrapper -Path 'tool-cache\download-tool.js' -InputObject ([PSCustomObject]$InputObject))?.Path |
			Write-Output
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
Tool architecture; Default to current machine architecture.
.OUTPUTS
[String] Tool cached path.
#>
Function Register-ToolCacheDirectory {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_register-githubactionstoolcachedirectory#Register-GitHubActionsToolCacheDirectory')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('SourceDirectory')][String]$Source,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][Alias('Ver')][String]$Version,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			Source = $Source
			Name = $Name
			Version = $Version
		}
		If ($Architecture.Length -igt 0) {
			$InputObject.Architecture = $Architecture
		}
		(Invoke-GitHubActionsNodeJsWrapper -Path 'tool-cache\cache-directory.js' -InputObject ([PSCustomObject]$InputObject))?.Path |
			Write-Output
	}
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
Tool architecture; Default to current machine architecture.
.OUTPUTS
[String] Tool cached path.
#>
Function Register-ToolCacheFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_register-githubactionstoolcachefile#Register-GitHubActionsToolCacheFile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('SourceFile')][String]$Source,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('TargetFile')][String]$Target,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 3, ValueFromPipelineByPropertyName = $True)][Alias('Ver')][String]$Version,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -ToolCache)) {
			Write-Error -Message 'Unable to get GitHub Actions tool cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
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
		(Invoke-GitHubActionsNodeJsWrapper -Path 'tool-cache\cache-file.js' -InputObject ([PSCustomObject]$InputObject))?.Path |
			Write-Output
	}
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
