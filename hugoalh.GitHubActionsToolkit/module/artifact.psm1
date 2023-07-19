#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'nodejs-wrapper'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Export Artifact
.DESCRIPTION
Export artifact to persist the data and/or share with the future jobs in the same workflow.
.PARAMETER Name
Name of the artifact.
.PARAMETER Path
Path of the files that need to export as artifact.
.PARAMETER LiteralPath
Literal path of the files that need to export as artifact.
.PARAMETER RootDirectory
Absolute literal path of the root directory of the files for control files structure.
.PARAMETER ContinueOnError
Whether the export should continue in the event of files fail to export; If not set and issue is encountered, export will stop and queued files will not export, the partial artifact availables which include files up until the issue; If set and issue is encountered, the issue file will ignore and skip, and queued files will still export, the partial artifact availables which include everything but exclude issue files.
.PARAMETER RetentionDays
Retention days of the artifact.
.OUTPUTS
[PSCustomObject] Metadata of the exported artifact.
#>
Function Export-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exportgithubactionsartifact')]
	[OutputType([PSCustomObject])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateScript({ [System.IO.Path]::IsPathRooted($_) -and (Test-Path -LiteralPath $_ -PathType 'Container') }, ErrorMessage = '`{0}` is not an exist and valid directory!')][Alias('BaseRoot', 'Root')][String]$RootDirectory = $Env:GITHUB_WORKSPACE,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ContinueOnIssue')][Switch]$ContinueOnError,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, [Int16]::MaxValue)][Alias('RetentionDay', 'RetentionTime')][Int16]$RetentionDays
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				[String[]]$Items = $LiteralPath |
					ForEach-Object -Process { [System.IO.Path]::IsPathRooted($_) ? $_ : (Join-Path -Path $RootDirectory -ChildPath $_) }
			}
			'Path' {
				[String[]]$Items = $Path |
					ForEach-Object -Process {
						Try {
							Resolve-Path -Path ([System.IO.Path]::IsPathRooted($_) ? $_ : (Join-Path -Path $RootDirectory -ChildPath $_)) |
								Write-Output
						}
						Catch {
							$_ |
								Write-Output
						}
					}
			}
		}
		[Hashtable]$Argument = @{
			'name' = $Name
			'items' = $Items
			'rootDirectory' = $RootDirectory
			'continueOnError' = $ContinueOnError.IsPresent
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
Import artifact that shared the data from the past jobs in the same workflow.
.PARAMETER Name
Name of the artifact.
.PARAMETER CreateSubfolder
Whether to create a subfolder with artifact name and put the data into there.
.PARAMETER All
Whether to import all of the artifacts that shared the data from the past jobs in the same workflow; Always create subfolders.
.PARAMETER Destination
Absolute literal path of the destination of the artifact(s).
.OUTPUTS
[PSCustomObject] Metadata of the imported artifact.
[PSCustomObject[]] Metadata of the imported artifacts.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_importgithubactionsartifact')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	[OutputType([PSCustomObject], ParameterSetName = 'Single')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(ParameterSetName = 'Single', ValueFromPipelineByPropertyName = $True)][Switch]$CreateSubfolder,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Dest', 'Path', 'Target')][String]$Destination = $Env:GITHUB_WORKSPACE
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download-all' -Argument @{
					'destination' = $Destination
				} |
					Write-Output
			}
			'Single' {
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download' -Argument @{
					'name' = $Name
					'destination' = $Destination
					'createSubfolder' = $CreateSubfolder.IsPresent
				} |
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
