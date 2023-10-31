#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'internal\nodejs-wrapper.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Restore Cache
.DESCRIPTION
Restore cache that shared from the past jobs.
.PARAMETER Path
Paths of the cache, support Glob.
.PARAMETER Key
Keys of the cache.
.PARAMETER ConcurrencyBlobDownload
Whether to use GitHub Actions NodeJS toolkit HttpClient with concurrency for Azure Blob Storage.
.PARAMETER LookUp
Weather to not restore the cache, and only check if a matching cache entry exists and return the cache key if it does.
.PARAMETER SegmentTimeout
Maximum time for each segment download request of the cache, by milliseconds; This allows the segment download to get aborted and hence allow the job to proceed with a cache miss.
.PARAMETER DownloadConcurrency
Number of parallel downloads of the cache (only for Azure SDK).
.PARAMETER Timeout
Maximum time for each download request of the cache, by milliseconds (only for Azure SDK).
.PARAMETER NoAzureSdk
Whether to not use Azure Blob SDK to download the cache that stored on the Azure Blob Storage, this maybe affect the reliability and performance.
.OUTPUTS
[String] The key of the cache hit.
#>
Function Restore-Cache {
	[CmdletBinding(DefaultParameterSetName = 'AzureSdk', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_restoregithubactionscache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Keys', 'Name', 'Names')][String[]]$Key,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$ConcurrencyBlobDownload,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$LookUp,
		[Parameter(ValueFromPipelineByPropertyName = $True)][UInt32]$SegmentTimeout,
		[Parameter(ParameterSetName = 'AzureSdk', ValueFromPipelineByPropertyName = $True)][Alias('Concurrency')][Byte]$DownloadConcurrency,
		[Parameter(ParameterSetName = 'AzureSdk', ValueFromPipelineByPropertyName = $True)][UInt32]$Timeout,
		[Parameter(Mandatory = $True, ParameterSetName = 'NoAzureSdk',ValueFromPipelineByPropertyName = $True)][Switch]$NoAzureSdk
	)
	Process {
		[Hashtable]$Argument = @{
			'paths' = $Path
			'primaryKey' = $Key[0]
			'restoreKeys' = @(
				$Key |
					Select-Object -SkipIndex @(0)
			)
			'concurrencyBlobDownload' = $ConcurrencyBlobDownload.IsPresent
			'lookup' = $LookUp.IsPresent
			'useAzureSdk' = $PSCmdlet.ParameterSetName -ieq 'AzureSdk'
		}
		If ($SegmentTimeout -gt 0) {
			$Argument.('segmentTimeout') = $SegmentTimeout
		}
		If ($PSCmdlet.ParameterSetName -ieq 'AzureSdk' -and $DownloadConcurrency -gt 0) {
			$Argument.('downloadConcurrency') = $DownloadConcurrency
		}
		If ($PSCmdlet.ParameterSetName -ieq 'AzureSdk' -and $Timeout -gt 0) {
			$Argument.('timeout') = $Timeout
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
Save cache to share with the future jobs.
.PARAMETER Path
Paths of the cache, support Glob.
.PARAMETER Key
Key of the cache.
.PARAMETER UploadChunkSize
Maximum chunk size for upload the cache, by byte.
.PARAMETER UploadConcurrency
Number of parallel uploads of the cache.
.OUTPUTS
[UInt64] ID of the cache.
#>
Function Save-Cache {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_savegithubactionscache')]
	[OutputType([UInt64])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Name')][String]$Key,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ChunkSize')][UInt32]$UploadChunkSize,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Concurrency')][Byte]$UploadConcurrency
	)
	Process {
		[Hashtable]$Argument = @{
			'paths' = $Path
			'key' = $Key
		}
		If ($UploadChunkSize -gt 0) {
			$Argument.('uploadChunkSize') = $UploadChunkSize
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
