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
GitHub Actions - Export Artifact
.DESCRIPTION
Export artifact to persist data and/or share with future job in the same workflow.
.PARAMETER Name
Name of the artifact.
.PARAMETER Path
Paths to the files that need to export as artifact.
.PARAMETER LiteralPath
Literal paths to the files that need to export as artifact.
.PARAMETER BaseRoot
Absolute literal path of the base root directory of the files for control files structure.
.PARAMETER ContinueOnIssue
Whether the export should continue in the event of files fail to export; If not set and issue is encountered, export will stop and queued files will not export; The partial artifact availables which include files up until the issue; If set and issue is encountered, the issue file will ignore and skip, and queued files will still export; The partial artifact availables which include everything but exclude issue files.
.PARAMETER RetentionTime
Duration of the artifact become expire, by days.
.OUTPUTS
[PSCustomObject] Metadata of the exported artifact.
#>
Function Export-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_export-githubactionsartifact#Export-GitHubActionsArtifact')]
	[OutputType([PSCustomObject])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Root')][String]$BaseRoot = $Env:GITHUB_WORKSPACE,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ContinueOnError')][Switch]$ContinueOnIssue,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('RetentionDay')][Byte]$RetentionTime
	)
	Begin {
		[Boolean]$NoOperation = !(Test-GitHubActionsEnvironment -Artifact)# When the requirements are not fulfill, only stop this function but not others.
		If ($NoOperation) {
			Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable'
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		[Hashtable]$InputObject = @{
			Name = $Name
			Path = ($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? (
				$LiteralPath |
					ForEach-Object -Process { [WildcardPattern]::Escape($_) }
			) : $Path
			BaseRoot = $BaseRoot
			ContinueOnIssue = $ContinueOnIssue.IsPresent
		}
		If ($RetentionTime -igt 0) {
			$InputObject.RetentionTIme = $RetentionTime
		}
		Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\upload.js' -InputObject ([PSCustomObject]$InputObject) |
			Write-Output
	}
}
Set-Alias -Name 'Save-Artifact' -Value 'Export-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Import Artifact
.DESCRIPTION
Import artifact that shared data from past job in the same workflow.
.PARAMETER Name
Name of the artifact.
.PARAMETER CreateSubfolder
Whether to create a subfolder with artifact name and put data into here.
.PARAMETER All
Import all of the artifacts that shared data from past job in the same workflow; Always create subfolders.
.PARAMETER Destination
Absolute literal path(s) of the destination of the artifact(s).
.OUTPUTS
[PSCustomObject] Metadata of the imported artifact.
[PSCustomObject[]] Metadata of the imported artifacts.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_import-githubactionsartifact#Import-GitHubActionsArtifact')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	[OutputType([PSCustomObject], ParameterSetName = 'Single')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(ParameterSetName = 'Single', ValueFromPipelineByPropertyName = $True)][Switch]$CreateSubfolder,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Dest', 'Target')][String]$Destination = $Env:GITHUB_WORKSPACE
	)
	Begin {
		[Boolean]$NoOperation = !(Test-GitHubActionsEnvironment -Artifact)# When the requirements are not fulfill, only stop this function but not others.
		If ($NoOperation) {
			Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable'
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download-all.js' -InputObject ([PSCustomObject]@{
					Destination = $Destination
				}) |
					Write-Output
			}
			'Single' {
				Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download.js' -InputObject ([PSCustomObject]@{
					Name = $Name
					Destination = $Destination
					CreateSubfolder = $CreateSubfolder.IsPresent
				}) |
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
