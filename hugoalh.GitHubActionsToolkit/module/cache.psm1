#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-invoke.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
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
Maximum time for each download request by seconds (only for Azure SDK).
.OUTPUTS
[String] The key of the cache hit.
#>
Function Restore-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_restore-githubactionscache#Restore-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({
			Return (Test-CacheKey -InputObject $_)
		}, ErrorMessage = '`{0}` is not a valid GitHub Actions cache key, and/or more than 512 characters!')][Alias('Keys', 'Name', 'Names')][String[]]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Alias('NoAzureSdk')][Switch]$NotUseAzureSdk,
		[ValidateRange(1, 16)][AllowNull()][Byte]$DownloadConcurrency = $Null,
		[ValidateRange(5, 900)][AllowNull()][UInt16]$Timeout = $Null
	)
	Begin {
		If (!(Test-GitHubActionsEnvironment -Cache)) {
			Return (Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable')
			Break# This is the best way to early terminate this function without terminate caller/invoker process.
		}
		[String[]]$PathsProceed = @()
	}
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				$PathsProceed += ($LiteralPath | ForEach-Object -Process {
					Return [WildcardPattern]::Escape($_)
				})
			}
			'Path' {
				$PathsProceed += $Path
			}
		}
	}
	End {
		[String[]]$KeysProceed = @()
		If ($Key.Count -igt 10) {
			Write-Warning -Message "Keys are limit to maximum count of 10! Only first 10 keys will use."
			$KeysProceed += ($Key | Select-Object -First 10)
		} Else {
			$KeysProceed += $Key
		}
		If ($PathsProceed.Count -ieq 0) {
			Return (Write-Error -Message 'No valid path is defined!' -Category 'NotSpecified')
		}
		[Hashtable]$InputObject = @{
			Path = $PathsProceed
			PrimaryKey = $KeysProceed[0]
			RestoreKey = ($KeysProceed | Select-Object -SkipIndex 0)
			UseAzureSdk = !$NotUseAzureSdk.IsPresent
		}
		If (!$NotUseAzureSdk.IsPresent) {
			If ($Null -ine $DownloadConcurrency) {
				$InputObject.DownloadConcurrency = $DownloadConcurrency
			}
			If ($Null -ine $Timeout) {
				$InputObject.Timeout = $Timeout * 1000
			}
		}
		$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'cache\restore.js' -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
		If ($ResultRaw -ieq $False) {
			Return
		}
		Return ($ResultRaw | ConvertFrom-Json -Depth 100).CacheKey
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
Maximum chunk size by bytes.
.PARAMETER UploadConcurrency
Number of parallel uploads.
.OUTPUTS
[String] Cache ID.
#>
Function Save-Cache {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_save-githubactionscache#Save-GitHubActionsCache')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({
			Return (Test-CacheKey -InputObject $_)
		}, ErrorMessage = '`{0}` is not a valid GitHub Actions cache key, and/or more than 512 characters!')][Alias('Name')][String]$Key,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[ValidateRange(1KB, 1GB)][AllowNull()][UInt32]$UploadChunkSizes = $Null,
		[ValidateRange(1, 16)][AllowNull()][Byte]$UploadConcurrency = $Null
	)
	Begin {
		If (!(Test-GitHubActionsEnvironment -Cache)) {
			Return (Write-Error -Message 'Unable to get GitHub Actions cache resources!' -Category 'ResourceUnavailable')
			Break# This is the best way to early terminate this function without terminate caller/invoker process.
		}
		[String[]]$PathsProceed = @()
	}
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				$PathsProceed += ($LiteralPath | ForEach-Object -Process {
					Return [WildcardPattern]::Escape($_)
				})
			}
			'Path' {
				$PathsProceed += $Path
			}
		}
	}
	End {
		If ($PathsProceed.Count -ieq 0) {
			Return (Write-Error -Message 'No valid path is defined!' -Category 'NotSpecified')
		}
		[Hashtable]$InputObject = @{
			Key = $Key
			Path = $PathsProceed
		}
		If ($Null -ine $UploadChunkSizes) {
			$InputObject.UploadChunkSizes = $UploadChunkSizes
		}
		If ($Null -ine $UploadConcurrency) {
			$InputObject.UploadConcurrency = $UploadConcurrency
		}
		$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'cache\save.js' -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
		If ($ResultRaw -ieq $False) {
			Return
		}
		Return ($ResultRaw | ConvertFrom-Json -Depth 100).CacheId
	}
}
Set-Alias -Name 'Export-Cache' -Value 'Save-Cache' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Cache Key
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
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Return ($InputObject.Length -ile 512 -and $InputObject -imatch '^[^,\n\r]+$')
}
Export-ModuleMember -Function @(
	'Restore-Cache',
	'Save-Cache'
) -Alias @(
	'Export-Cache',
	'Import-Cache'
)
