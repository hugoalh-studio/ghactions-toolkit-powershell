#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'nodejs-invoke',
		'utility'
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
.OUTPUTS
[String] The key of the cache hit.
#>
Function Restore-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_restore-githubactionscache#Restore-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('Keys', 'Name', 'Names')][String[]]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoAzureSdk')][Switch]$NotUseAzureSdk,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$DownloadConcurrency,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(5, 900)][UInt16]$Timeout,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 360)][UInt16]$SegmentTimeout = 60
	)
	Begin {
		[Boolean]$NoOperation = !(Test-GitHubActionsEnvironment -Cache)# When the requirements are not fulfill, only stop this function but not others.
		If ($NoOperation) {
			Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable'
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			PrimaryKey = $Key[0]
			Path = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
			UseAzureSdk = !$NotUseAzureSdk.IsPresent
		}
		[String[]]$RestoreKey = $Key |
			Select-Object -SkipIndex 0
		If ($RestoreKey.Count -igt 0) {
			$InputObject.RestoreKey = $RestoreKey
		}
		If (!$NotUseAzureSdk.IsPresent) {
			If ($DownloadConcurrency -igt 0) {
				$InputObject.DownloadConcurrency = $DownloadConcurrency
			}
			If ($Timeout -igt 0) {
				$InputObject.Timeout = $Timeout * 1000
			}
		}
		[System.Environment]::SetEnvironmentVariable('SEGMENT_DOWNLOAD_TIMEOUT_MINS', $SegmentTimeout) |
			Out-Null
		(Invoke-GitHubActionsNodeJsWrapper -Name 'cache/restore' -InputObject ([PSCustomObject]$InputObject))?.CacheKey |
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
.PARAMETER UploadChunkSizes
Maximum chunk size of the cache, by KB.
.PARAMETER UploadConcurrency
Number of parallel uploads of the cache.
.OUTPUTS
[String] ID of the cache.
#>
Function Save-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_save-githubactionscache#Save-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('Name')][String]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 1MB)][Alias('ChunkSize', 'ChunkSizes', 'UploadChunkSize')][UInt32]$UploadChunkSizes,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$UploadConcurrency
	)
	Begin {
		[Boolean]$NoOperation = !(Test-GitHubActionsEnvironment -Cache)# When the requirements are not fulfill, only stop this function but not others.
		If ($NoOperation) {
			Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable'
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			Key = $Key
			Path = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
		}
		If ($UploadChunkSizes -igt 0) {
			$InputObject.UploadChunkSizes = $UploadChunkSizes * 1KB
		}
		If ($UploadConcurrency -igt 0) {
			$InputObject.UploadConcurrency = $UploadConcurrency
		}
		(Invoke-GitHubActionsNodeJsWrapper -Name 'cache/save' -InputObject ([PSCustomObject]$InputObject))?.CacheId |
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
