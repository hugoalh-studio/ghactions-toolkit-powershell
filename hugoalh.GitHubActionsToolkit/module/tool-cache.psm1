#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'nodejs-wrapper'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Expand Tool Cache Compressed File
.DESCRIPTION
Expand a compressed archive/file.
.PARAMETER File
Path of the compressed archive/file.
.PARAMETER Destination
Path for the expand destination.
.PARAMETER Method
Method to expand compressed archive/file; Define this parameter will enforce to use defined method.
.PARAMETER 7zrPath
Literal path of the 7zr application, for long path support (only when parameter `Method` is `7z`).

Most `.7z` archives do not have this problem, if `.7z` archive contains very long path, pass the path to 7zr which will gracefully handle long paths, by default 7zdec is used because it is a very small program and is bundled with the GitHub Actions NodeJS toolkit, however it does not support long paths, 7zr is the reduced command line interface, it is smaller than the full command line interface, and it does support long paths, at the time of this writing, it is freely available from the LZMA SDK that is available on the 7-Zip website, be sure to check the current license agreement, if 7zr is bundled with your action, then the path to 7zr can be pass to this function.
.PARAMETER Flag
Flag to use for expand (only when parameter `Method` is `Tar` or `Xar`).
.OUTPUTS
[String] Absolute path of the expand destination.
#>
Function Expand-ToolCacheCompressedFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_expandgithubactionstoolcachecompressedfile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Source')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Target')][String]$Destination,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateSet('7z', 'Tar', 'Xar', 'Zip')][String]$Method,
		[String]$7zrPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Flags')][String]$Flag
	)
	Process {
		If (!(Test-Path -LiteralPath $File -PathType 'Leaf')) {
			Write-Error -Message "``$File`` is not a valid file path!" -Category 'SyntaxError'
			Return
		}
		If ($Method.Length -eq 0) {
			Switch -RegEx ($File) {
				'\.7z$' {
					$Method = '7z'
					Break
				}
				'\.pkg$' {
					$Method = 'Xar'
					Break
				}
				'\.t(?:ar(?:\.gz)?|gz)$' {
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
		[Hashtable]$Argument = @{
			File = $File
		}
		If ($Destination.Length -gt 0) {
			$Argument.Destination = $Destination
		}
		If ($7zrPath.Length -gt 0) {
			$Argument['7zrPath'] = $7zrPath
		}
		If ($Flag.Length -gt 0) {
			$Argument.Flag = $Flag
		}
		(Invoke-GitHubActionsNodeJsWrapper -Name "tool-cache/extract-$($Method.ToLower())" -Argument $Argument)?.Path |
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
Name of the tool.
.PARAMETER Version
Version of the tool, by Semantic Versioning (SemVer); Default to all of the versions.
.PARAMETER Architecture
Architecture of the tool; Default to the architecture of the current machine.
.OUTPUTS
[String] Absolute path of a version of a tool.
[String[]] Absolute paths of all of the versions of a tool.
#>
Function Find-ToolCache {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_findgithubactionstoolcache')]
	[OutputType(([String], [String[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('V', 'Ver')][String]$Version,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Process {
		[Hashtable]$Argument = @{
			Name = $Name
		}
		[Boolean]$IsFindAll = $Version.Length -eq 0
		If (!$IsFindAll) {
			$Argument.Version = $Version
		}
		If ($Architecture.Length -gt 0) {
			$Argument.Architecture = $Architecture
		}
		$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Name "tool-cache/find$($IsFindAll ? '-all-versions' : '')" -Argument $Argument
		Write-Output -InputObject ($IsFindAll ? ${ResultRaw}?.Paths : ${ResultRaw}?.Path)
	}
}
<#
.SYNOPSIS
GitHub Actions - Invoke Tool Cache Tool Downloader
.DESCRIPTION
Download a tool from URI and stream it into a file.
.PARAMETER Uri
URI of the tool.
.PARAMETER Destination
Path for the tool destination.
.PARAMETER Authorization
Authorization of the URI request.
.PARAMETER Header
Header of the URI request.
.OUTPUTS
[String] Absolute path of the downloaded tool.
#>
Function Invoke-ToolCacheToolDownloader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_invokegithubactionstoolcachetooldownloader')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidateScript({ ($Null -ine $_.AbsoluteUri) -and ($_.Scheme -imatch '^https?$') }, ErrorMessage = '`{0}` is not a valid URI!')][Alias('Source', 'Url')][Uri]$Uri,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Target')][String]$Destination,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Auth')][String]$Authorization,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Headers')][Hashtable]$Header
	)
	Process {
		[Hashtable]$Argument = @{
			Uri = $Uri.ToString()
		}
		If ($Destination.Length -gt 0) {
			$Argument.Destination = $Destination
		}
		If ($Authorization.Length -gt 0) {
			$Argument.Authorization = $Authorization
		}
		If ($Header.Count -gt 0) {
			$Argument.Header = $Header
		}
		(Invoke-GitHubActionsNodeJsWrapper -Name 'tool-cache/download-tool' -Argument $Argument)?.Path |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Register Tool Cache Directory
.DESCRIPTION
Register a tool directory to cache and install in the tool cache.
.PARAMETER Source
Path of the tool directory.
.PARAMETER Name
Name for the tool.
.PARAMETER Version
Version for the tool, by Semantic Versioning (SemVer).
.PARAMETER Architecture
Architecture for the tool; Default to the architecture of the current machine.
.OUTPUTS
[String] Absolute path of the tool cached.
#>
Function Register-ToolCacheDirectory {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_registergithubactionstoolcachedirectory')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('SourceDirectory')][String]$Source,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][Alias('V', 'Ver')][String]$Version,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Process {
		[Hashtable]$Argument = @{
			Source = $Source
			Name = $Name
			Version = $Version
		}
		If ($Architecture.Length -gt 0) {
			$Argument.Architecture = $Architecture
		}
		(Invoke-GitHubActionsNodeJsWrapper -Name 'tool-cache/cache-directory' -Argument $Argument)?.Path |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Register Tool Cache File
.DESCRIPTION
Register a tool file to cache and install in the tool cache.
.PARAMETER Source
Path of the tool file.
.PARAMETER Target
Path for the tool file in the tool cache.
.PARAMETER Name
Name for the tool.
.PARAMETER Version
Version for the tool, by Semantic Versioning (SemVer).
.PARAMETER Architecture
Architecture for the tool; Default to the architecture of the current machine.
.OUTPUTS
[String] Absolute path of the tool cached.
#>
Function Register-ToolCacheFile {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_registergithubactionstoolcachefile')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('SourceFile')][String]$Source,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('TargetFile')][String]$Target,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][Alias('ToolName')][String]$Name,
		[Parameter(Mandatory = $True, Position = 3, ValueFromPipelineByPropertyName = $True)][Alias('V', 'Ver')][String]$Version,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Arch')][String]$Architecture
	)
	Process {
		[Hashtable]$Argument = @{
			Source = $Source
			Target = $Target
			Name = $Name
			Version = $Version
		}
		If ($Architecture.Length -gt 0) {
			$Argument.Architecture = $Architecture
		}
		(Invoke-GitHubActionsNodeJsWrapper -Name 'tool-cache/cache-file' -Argument $Argument)?.Path |
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
