#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'internal\nodejs-wrapper.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Export Artifact
.DESCRIPTION
Export artifact to share with all of the subsequent jobs in the same workflow, and/or persist the data.
.PARAMETER Name
Name of the artifact.
.PARAMETER Path
Path of the files that need to export as artifact.
.PARAMETER LiteralPath
Literal path of the files that need to export as artifact.
.PARAMETER RootDirectory
Absolute literal path of the root directory of the files for control files structure.
.PARAMETER RetentionDays
Retention days of the artifact, override the default value.
.PARAMETER FailFast
Whether to stop export artifact if any of file fail to export due to any of error.

By default, the failed files will skip and ignore, and all of the queued files will still export; The partial artifact will have all of the files except the failed files.

When enable, export will stop, include all of the queued files; The partial artifact will have files up until the failure.

A partial artifact will always associate and available at the end, and the size reported will be the amount of storage that the organization or user will charge for this partial artifact.
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
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('RetentionDay', 'RetentionTime')][UInt16]$RetentionDays,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$FailFast
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
			'continueOnError' = !$FailFast.IsPresent
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
GitHub Actions - Import Artifact
.DESCRIPTION
Import artifact that shared from the past jobs in the same workflow.
.PARAMETER Name
Name of the artifact.
.PARAMETER Destination
Absolute literal path of the destination of the artifact(s).
.PARAMETER CreateSubDirectory
Whether to create a sub-directory with artifact name and put the data into there.
.PARAMETER All
Whether to import all of the artifacts that shared from the past jobs in the same workflow; Always create sub-directories.
.OUTPUTS
[PSCustomObject] Metadata of the imported artifact.
[PSCustomObject[]] Metadata of the imported artifacts.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_importgithubactionsartifact')]
	[OutputType([PSCustomObject], ParameterSetName = 'Single')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][String]$Name,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Dest', 'Path', 'Target')][String]$Destination,
		[Parameter(ParameterSetName = 'Single', ValueFromPipelineByPropertyName = $True)][Switch]$CreateSubDirectory,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All
	)
	Process {
		[Hashtable]$Argument = @{}
		If ($Destination.Length -gt 0) {
			$Argument.('destination') = $Destination
		}
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download-all' -Argument $Argument |
					Write-Output -NoEnumerate
			}
			'Single' {
				$Argument.('name') = $Name
				$Argument.('createSubDirectory') = $CreateSubDirectory.IsPresent
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download' -Argument $Argument |
					Write-Output
			}
		}
	}
}
Set-Alias -Name 'Restore-Artifact' -Value 'Import-Artifact' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Export-Artifact',
	'Import-Artifact'
) -Alias @(
	'Restore-Artifact',
	'Save-Artifact'
)
