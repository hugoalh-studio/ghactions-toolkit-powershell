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
Paths of the files that need to export as artifact.
.PARAMETER LiteralPath
Literal paths of the files that need to export as artifact.
.PARAMETER BaseRoot
Absolute literal path of the base root directory of the files for control files structure.
.PARAMETER ContinueOnIssue
Whether the export should continue in the event of files fail to export; If not set and issue is encountered, export will stop and queued files will not export, the partial artifact availables which include files up until the issue; If set and issue is encountered, the issue file will ignore and skip, and queued files will still export, the partial artifact availables which include everything but exclude issue files.
.PARAMETER RetentionTime
Retention time of the artifact, by days.
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
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateScript({ [System.IO.Path]::IsPathRooted($_) -and (Test-Path -LiteralPath $_ -PathType 'Container') }, ErrorMessage = '`{0}` is not an exist and valid directory!')][Alias('Root')][String]$BaseRoot = $Env:GITHUB_WORKSPACE,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ContinueOnError')][Switch]$ContinueOnIssue,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('RetentionDay')][UInt16]$RetentionTime
	)
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				[String[]]$PathsProceed = $LiteralPath |
					ForEach-Object -Process { [System.IO.Path]::IsPathRooted($_) ? $_ : (Join-Path -Path $BaseRoot -ChildPath $_) }
			}
			'Path' {
				[String[]]$PathsProceed = @()
				ForEach ($Item In $Path) {
					Try {
						$PathsProceed += Resolve-Path -Path ([System.IO.Path]::IsPathRooted($Item) ? $Item : (Join-Path -Path $BaseRoot -ChildPath $Item))
					}
					Catch {
						$PathsProceed += $Item
					}
				}
			}
		}
		[Hashtable]$Argument = @{
			Name = $Name
			Path = $PathsProceed
			BaseRoot = $BaseRoot
			ContinueOnIssue = $ContinueOnIssue.IsPresent
		}
		If ($RetentionTime -gt 0) {
			$Argument.RetentionTIme = $RetentionTime
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
					Destination = $Destination
				} |
					Write-Output
			}
			'Single' {
				Invoke-GitHubActionsNodeJsWrapper -Name 'artifact/download' -Argument @{
					Name = $Name
					Destination = $Destination
					CreateSubfolder = $CreateSubfolder.IsPresent
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
