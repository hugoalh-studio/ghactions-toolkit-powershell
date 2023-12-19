#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'internal\nodejs-wrapper.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Export Artifact
.DESCRIPTION
Export artifact to share with all of the subsequent jobs in the current workflow run, and/or store it.
.PARAMETER Name
Name of the artifact.
.PARAMETER Path
Path of the files that need to export as artifact.
.PARAMETER LiteralPath
Literal path of the files that need to export as artifact.
.PARAMETER RootDirectory
Absolute literal path of the root directory of the files for control files structure.
.PARAMETER CompressionLevel
Level of compression for Zlib to be applied to the artifact archive. The value can range from 0 to 9.

- 0: No compression
- 1: Best speed
- 6: Default compression (same as GNU Gzip)
- 9: Best compression

Higher levels will result in better compression, but will take longer to complete. For large files that are not easily compressed, a value of 0 is recommended for significantly faster uploads.
.PARAMETER RetentionDays
Retention days of the artifact, override the default value.
.OUTPUTS
[PSCustomObject] Metadata of the exported artifact.
#>
Function Export-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exportgithubactionsartifact')]
	[OutputType([PSCustomObject])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('BaseRoot', 'Root')][String]$RootDirectory = $Env:GITHUB_WORKSPACE,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(0,9, ErrorMessage = 'Value is not a valid compression level!')][Int16]$CompressionLevel = -1,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('RetentionDay', 'RetentionTime')][UInt16]$RetentionDays,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$FailFast# Deprecated.
	)
	Process {
		If ($RootDirectory -inotmatch '^.+$') {
			Write-Error -Message 'Parameter `RootDirectory` is not a single line string!' -Category 'SyntaxError'
			Return
		}
		If (!([System.IO.Path]::IsPathFullyQualified($RootDirectory) -and (Test-Path -LiteralPath $RootDirectory -PathType 'Container'))) {
			Write-Error -Message "``$RootDirectory`` is not a valid and exist directory!" -Category 'ResourceUnavailable'
			Return
		}
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				[String[]]$Items = $LiteralPath
			}
			'Path' {
				[String[]]$Items = @()
				ForEach ($P In $Path) {
					If ([WildcardPattern]::ContainsWildcardCharacters($P)) {
						Try {
							$Items += Resolve-Path -Path ([System.IO.Path]::IsPathFullyQualified($P) ? $P : (Join-Path -Path $RootDirectory -ChildPath $P)) |
								Select-Object -ExpandProperty 'Path'
						}
						Catch {
							$Items += $P
						}
					}
					Else {
						$Items += $P
					}
				}
			}
		}
		[Hashtable]$Argument = @{
			'name' = $Name
			'items' = $Items
			'rootDirectory' = $RootDirectory
		}
		If ($CompressionLevel -gt -1) {
			$Argument.('compressionLevel') = $CompressionLevel
		}
		If ($RetentionDays -gt 0) {
			$Argument.('retentionDays') = $RetentionDays
		}
		Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/upload' -Argument $Argument |
			Write-Output
	}
}
Set-Alias -Name 'Save-Artifact' -Value 'Export-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Artifact
.DESCRIPTION
Get artifact that shared from the previous jobs in the current workflow run.
.PARAMETER Name
Name of the artifact.
.PARAMETER All
Whether to get all of the artifacts that shared from the previous jobs in the current workflow run.
.PARAMETER Latest
Whether to filter the workflow run's artifacts to the latest by name. In the case of reruns, this can be useful to avoid duplicates.
.OUTPUTS
[PSCustomObject] Metadata of the artifact.
[PSCustomObject[]] Metadata of the artifacts.
#>
Function Get-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsartifact')]
	[OutputType([PSCustomObject], ParameterSetName = 'Single')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(ParameterSetName = 'All')][Switch]$Latest
	)
	Process {
		[Hashtable]$Argument = @{}
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				$Argument.('latest') = $Latest.IsPresent
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/list' -Argument $Argument |
					Write-Output
			}
			'Single' {
				$Argument.('name') = $Name
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/get' -Argument $Argument |
					Write-Output
			}
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Import Artifact
.DESCRIPTION
Import artifact that shared from the previous jobs in the current workflow run.
.PARAMETER Id
ID of the artifact.
.PARAMETER Name
Name of the artifact.
.PARAMETER Destination
Absolute literal path of the destination of the artifact(s).
.PARAMETER All
Whether to import all of the artifacts that shared from the previous jobs in the current workflow run; Always create sub-directories.
.OUTPUTS
[PSCustomObject] Metadata of the imported artifact.
[PSCustomObject[]] Metadata of the imported artifacts.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'SingleId', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_importgithubactionsartifact')]
	[OutputType([PSCustomObject], ParameterSetName = ('SingleId', 'SingleName'))]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'SingleId', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][UInt64]$Id,
		[Parameter(Mandatory = $True, ParameterSetName = 'SingleName', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][String]$Name,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Dest', 'Path', 'Target')][String]$Destination,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$CreateSubDirectory# Deprecated.
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				Get-Artifact -All -Latest |
					ForEach-Object -Process {
						Import-Artifact -Id $_.id -Destination "$Destination/$($_.name)"
					} |
					Write-Output
			}
			'SingleId' {
				[Hashtable]$Argument = @{
					'id' = $Id
				}
				If ($Destination.Length -gt 0) {
					$Argument.('path') = $Destination
				}
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download' -Argument $Argument |
					Write-Output
			}
			'SingleName' {
				[PSCustomObject]$ArtifactMeta = Get-Artifact -Name $Name
				Import-Artifact -Id $ArtifactMeta.id -Destination $Destination |
					Write-Output
			}
		}
	}
}
Set-Alias -Name 'Restore-Artifact' -Value 'Import-Artifact' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Export-Artifact',
	'Get-Artifact',
	'Import-Artifact'
) -Alias @(
	'Restore-Artifact',
	'Save-Artifact'
)
