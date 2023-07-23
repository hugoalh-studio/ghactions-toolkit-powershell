#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'nodejs-wrapper'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Restore Cache
.DESCRIPTION
Restore cache that shared the data from the past jobs in the same workflow.
.PARAMETER Key
Keys of the cache.
.PARAMETER Path
Paths of the cache.
.PARAMETER LiteralPath
Literal paths of the cache.
.PARAMETER NotUseAzureSdk
Whether to not use Azure Blob SDK to download the cache that stored on the Azure Blob Storage, this maybe affect the reliability and performance.
.PARAMETER DownloadConcurrency
Number of parallel downloads of the cache (only for Azure SDK).
.PARAMETER Timeout
Maximum time for each download request of the cache, by seconds (only for Azure SDK).
.PARAMETER SegmentTimeout
Maximum time for each segment download request of the cache, by minutes; This allows the segment download to get aborted and hence allow the job to proceed with a cache miss.
.PARAMETER LookUp
Weather to skip downloading the cache entry, and only check if a matching cache entry exists and return the cache key if it does.
.OUTPUTS
[String] The key of the cache hit.
#>
Function Restore-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_restoregithubactionscache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('Keys', 'Name', 'Names')][String[]]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoAzureSdk')][Switch]$NotUseAzureSdk,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$DownloadConcurrency,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(5, 7200)][UInt16]$Timeout,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(5, 7200)][UInt16]$SegmentTimeout,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$LookUp
	)
	Process {
		[Hashtable]$Argument = @{
			'primaryKey' = $Key[0]
			'restoreKeys' = (
				$Key |
					Select-Object -SkipIndex 0
			) ?? @()
			'paths' = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
			'useAzureSdk' = !$NotUseAzureSdk.IsPresent
			'lookup' = $LookUp.IsPresent
		}
		If ($DownloadConcurrency -gt 0) {
			$Argument.('downloadConcurrency') = $DownloadConcurrency
		}
		If ($SegmentTimeout -gt 0) {
			$Argument.('segmentTimeout') = $SegmentTimeout * 1000
		}
		If ($Timeout -gt 0) {
			$Argument.('timeout') = $Timeout * 1000
		}
		Invoke-GitHubActionsNodeJsWrapper -Name 'cache/restore' -Argument $Argument |
			Write-Output
	}
}
Set-Alias -Name 'Import-Cache' -Value 'Restore-Cache' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Save cache
.DESCRIPTION
Save cache to persist the data and/or share with the future jobs in the same workflow.
.PARAMETER Key
Key of the cache.
.PARAMETER Path
Paths of the cache.
.PARAMETER LiteralPath
Literal paths of the cache.
.PARAMETER UploadChunkSize
Upload chunk size of the cache, by KB.
.PARAMETER UploadConcurrency
Number of parallel uploads of the cache.
.OUTPUTS
[UInt64] ID of the cache.
#>
Function Save-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_savegithubactionscache')]
	[OutputType([UInt64])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('Name')][String]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 1MB)][Alias('ChunkSize', 'ChunkSizes', 'UploadChunkSizes')][UInt32]$UploadChunkSize,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$UploadConcurrency
	)
	Process {
		[Hashtable]$Argument = @{
			'key' = $Key
			'paths' = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
		}
		If ($UploadChunkSize -gt 0) {
			$Argument.('uploadChunkSize') = $UploadChunkSize * 1KB
		}
		If ($UploadConcurrency -gt 0) {
			$Argument.('uploadConcurrency') = $UploadConcurrency
		}
		Invoke-GitHubActionsNodeJsWrapper -Name 'cache/save' -Argument $Argument |
			Write-Output
	}
}
Set-Alias -Name 'Export-Cache' -Value 'Save-Cache' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Restore-Cache',
	'Save-Cache'
) -Alias @(
	'Export-Cache',
	'Import-Cache'
)
