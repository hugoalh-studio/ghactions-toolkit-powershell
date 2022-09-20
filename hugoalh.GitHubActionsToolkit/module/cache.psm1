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
GitHub Actions - Restore Cache
.DESCRIPTION
Restore cache that shared data from previous job in the same workflow.
.PARAMETER Key
Cache key.
.PARAMETER Path
Cache destination path.
.PARAMETER LiteralPath
Cache destination literal path.
.PARAMETER NotUseAzureSdk
Do not use Azure Blob SDK to download caches that are stored on Azure Blob Storage, this maybe affect reliability and performance.
.PARAMETER DownloadConcurrency
Number of parallel downloads (only for Azure SDK).
.PARAMETER Timeout
Maximum time for each download request, by seconds (only for Azure SDK).
.OUTPUTS
[String] The key of the cache hit.
#>
Function Restore-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_restore-githubactionscache#Restore-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Test-CacheKey -InputObject $_ }, ErrorMessage = '`{0}` is not a valid GitHub Actions cache key, and/or more than 512 characters!')][Alias('Keys', 'Name', 'Names')][String[]]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NoAzureSdk')][Switch]$NotUseAzureSdk,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$DownloadConcurrency,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(5, 900)][UInt16]$Timeout
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -Cache)) {
			Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[String[]]$KeysProceed = @()
		If ($Key.Count -igt 10) {
			Write-Warning -Message 'Keys are limit to maximum count of 10! Only first 10 keys will be use.'
			$KeysProceed += $Key |
				Select-Object -First 10
		}
		Else {
			$KeysProceed += $Key
		}
		[Hashtable]$InputObject = @{
			PrimaryKey = $KeysProceed[0]
			RestoreKey = $KeysProceed |
				Select-Object -SkipIndex 0
			Path = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
			UseAzureSdk = !$NotUseAzureSdk.IsPresent
		}
		If (!$NotUseAzureSdk.IsPresent) {
			If ($DownloadConcurrency -igt 0) {
				$InputObject.DownloadConcurrency = $DownloadConcurrency
			}
			If ($Timeout -igt 0) {
				$InputObject.Timeout = $Timeout * 1000
			}
		}
		(Invoke-GitHubActionsNodeJsWrapper -Path 'cache\restore.js' -InputObject ([PSCustomObject]$InputObject))?.CacheKey |
			Write-Output
	}
}
Set-Alias -Name 'Import-Cache' -Value 'Restore-Cache' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Save cache
.DESCRIPTION
Save cache to persist data and/or share with another job in the same workflow.
.PARAMETER Key
Cache key.
.PARAMETER Path
Cache path.
.PARAMETER LiteralPath
Cache literal path.
.PARAMETER UploadChunkSizes
Maximum chunk size, by KB.
.PARAMETER UploadConcurrency
Number of parallel uploads.
.OUTPUTS
[String] Cache ID.
#>
Function Save-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_save-githubactionscache#Save-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Test-CacheKey -InputObject $_ }, ErrorMessage = '`{0}` is not a valid GitHub Actions cache key, and/or more than 512 characters!')][Alias('Name')][String]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 1MB)][Alias('ChunkSize', 'ChunkSizes', 'UploadChunkSize')][UInt32]$UploadChunkSizes,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 16)][Alias('Concurrency')][Byte]$UploadConcurrency
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -Cache)) {
			Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
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
		(Invoke-GitHubActionsNodeJsWrapper -Path 'cache\save.js' -InputObject ([PSCustomObject]$InputObject))?.CacheId |
			Write-Output
	}
}
Set-Alias -Name 'Export-Cache' -Value 'Save-Cache' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Private) - Test Cache Key
.DESCRIPTION
Test GitHub Actions cache key whether is valid.
.PARAMETER InputObject
GitHub Actions cache key that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-CacheKey {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject.Length -ile 512 -and $InputObject -imatch '^[^,\n\r]+$' |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'Restore-Cache',
	'Save-Cache'
) -Alias @(
	'Export-Cache',
	'Import-Cache'
)
