#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-invoke.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Export Artifact
.DESCRIPTION
Export artifact to persist data and/or share with another job in the same workflow.
.PARAMETER Name
Artifact name.
.PARAMETER Path
Absolute and/or relative path to the file that need to export as artifact.
.PARAMETER LiteralPath
Absolute and/or relative literal path to the file that need to export as artifact.
.PARAMETER BaseRoot
A (literal) path that denote the base root directory of the files for control files structure.
.PARAMETER ContinueOnIssue
Whether the export should continue in the event of files fail to export; If not set and issue is encountered, export will stop and queued files will not export; The partial artifact availables which include files up until the issue; If set and issue is encountered, the issue file will ignore and skip, and queued files will still export; The partial artifact availables which include everything but exclude issue files.
.PARAMETER RetentionTime
Duration of artifact expire, by days.
.OUTPUTS
[PSCustomObject] Exported artifact's metadata.
#>
Function Export-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_export-githubactionsartifact#Export-GitHubActionsArtifact')]
	[OutputType([PSCustomObject])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Return (Test-ArtifactName -InputObject $_) }, ErrorMessage = '`{0}` is not a valid GitHub Actions artifact name!')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateScript({ Return ([System.IO.Path]::IsPathRooted($_) -and (Test-Path -LiteralPath $_ -PathType 'Container')) }, ErrorMessage = '`{0}` is not an exist and valid GitHub Actions artifact base root!')][Alias('Root')][String]$BaseRoot = $Env:GITHUB_WORKSPACE,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ContinueOnError')][Switch]$ContinueOnIssue,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateRange(1, 90)][Alias('RetentionDay')][Byte]$RetentionTime
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -Artifact)) {
			Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		Switch ($PSCmdlet.ParameterSetName) {
			'LiteralPath' {
				[String[]]$PathsProceed = ($LiteralPath | ForEach-Object -Process {
					Return ([System.IO.Path]::IsPathRooted($_) ? $_ : (Join-Path -Path $BaseRoot -ChildPath $_))
				})
			}
			'Path' {
				[String[]]$PathsProceed = @()
				ForEach ($Item In $Path) {
					Try {
						$PathsProceed += Resolve-Path -Path ([System.IO.Path]::IsPathRooted($Item) ? $Item : (Join-Path -Path $BaseRoot -ChildPath $Item))
					} Catch {
						$PathsProceed += $Item
					}
				}
			}
		}
		[Hashtable]$InputObject = @{
			Name = $Name
			Path = $PathsProceed
			BaseRoot = $BaseRoot
			ContinueOnIssue = $ContinueOnIssue.IsPresent
		}
		If ($RetentionTime -igt 0) {
			$InputObject.RetentionTIme = $RetentionTime
		}
		Return (Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\upload.js' -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress))
	}
	End {}
}
Set-Alias -Name 'Save-Artifact' -Value 'Export-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Import Artifact
.DESCRIPTION
Import artifact that shared data from previous job in the same workflow.
.PARAMETER Name
Artifact name.
.PARAMETER CreateSubfolder
Create a subfolder with artifact name and put data into here.
.PARAMETER All
Import all artifacts that shared data from previous job in the same workflow; Always create subfolder.
.PARAMETER Destination
Artifact destination.
.OUTPUTS
[PSCustomObject] Imported artifact's metadata.
[PSCustomObject[]] Imported artifacts' metadata.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Single', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_import-githubactionsartifact#Import-GitHubActionsArtifact')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'All')]
	[OutputType([PSCustomObject], ParameterSetName = 'Single')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Single', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidateScript({ Return (Test-ArtifactName -InputObject $_) }, ErrorMessage = '`{0}` is not a valid GitHub Actions artifact name!')][String]$Name,
		[Parameter(ParameterSetName = 'Single', ValueFromPipelineByPropertyName = $True)][Switch]$CreateSubfolder,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Dest', 'Target')][String]$Destination = $Env:GITHUB_WORKSPACE
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -Artifact)) {
			Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				Return (Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download-all.js' -InputObject ([PSCustomObject]@{
					Destination = $Destination
				} | ConvertTo-Json -Depth 100 -Compress))
			}
			'Single' {
				Return (Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download.js' -InputObject ([PSCustomObject]@{
					Name = $Name
					Destination = $Destination
					CreateSubfolder = $CreateSubfolder.IsPresent
				} | ConvertTo-Json -Depth 100 -Compress))
			}
		}
	}
	End {}
}
Set-Alias -Name 'Restore-Artifact' -Value 'Import-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Artifact Name
.DESCRIPTION
Test GitHub Actions artifact name whether is valid.
.PARAMETER InputObject
GitHub Actions artifact name that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ArtifactName {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Begin {}
	Process {
		Return ((Test-ArtifactPath -InputObject $InputObject) -and $InputObject -imatch '^[^\\/]+$')
	}
	End {}
}
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Artifact Path
.DESCRIPTION
Test GitHub Actions artifact path whether is valid.
.PARAMETER InputObject
GitHub Actions artifact path that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ArtifactPath {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Begin {}
	Process {
		Return ($InputObject -imatch '^[^":<>|*?\n\r\t]+$')
	}
	End {}
}
Export-ModuleMember -Function @(
	'Export-Artifact',
	'Import-Artifact'
) -Alias @(
	'Restore-Artifact',
	'Save-Artifact'
)
