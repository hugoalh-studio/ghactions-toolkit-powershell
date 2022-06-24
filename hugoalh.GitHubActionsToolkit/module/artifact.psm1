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
Export artifact to persist data after a job has completed, and share that data with another job in the same workflow.
.PARAMETER Name
Artifact name.
.PARAMETER Path
Absolute and/or relative path to the file that need to export as artifact.
.PARAMETER LiteralPath
Absolute and/or relative literal path to the file that need to export as artifact.
.PARAMETER BaseRoot
A (literal) path that denote the base root directory of the files for control files structure.
.PARAMETER IgnoreIssuePaths
Whether the export should continue in the event of files fail to export; If set to `$False` and issue is encountered, export will stop and queued files will not export; The partial artifact availables which include files up until the issue; If set to `$True` and issue is encountered, the issue file will ignore and skip, and queued files will still export; The partial artifact availables which include everything but exclude issue files.
.PARAMETER RetentionTime
Duration of artifact expire by days.
.OUTPUTS
[PSCustomObject] Exported artifact's metadata.
#>
Function Export-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_export-githubactionsartifact#Export-GitHubActionsArtifact')]
	[OutputType([PSCustomObject])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({
			Return (Test-ArtifactName -InputObject $_)
		}, ErrorMessage = '`{0}` is not a valid GitHub Actions artifact name!')][String]$Name,
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath,
		[Alias('Root')][String]$BaseRoot = $Env:GITHUB_WORKSPACE,
		[Alias('ContinueOnError', 'ContinueOnIssue', 'ContinueOnIssues', 'IgnoreIssuePath')][Switch]$IgnoreIssuePaths,
		[Alias('RetentionDay')][ValidateRange(1, 90)][Byte]$RetentionTime
	)
	Begin {
		If (
			![System.IO.Path]::IsPathRooted($BaseRoot) -or
			!(Test-Path -LiteralPath $BaseRoot -PathType 'Container')
		) {
			Return (Write-Error -Message "``$BaseRoot`` is not an exist and valid GitHub Actions artifact base root!" -Category 'SyntaxError')
			Break# This is the best way to early terminate this function without terminate caller/invoker process.
		}
		[String]$BaseRootRegularExpression = "^$([RegEx]::Escape((Resolve-Path -LiteralPath $BaseRoot)))"
		[String[]]$PathsValid = @()
		[String[]]$PathsInvalid = @()
	}
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'Path' {
				ForEach ($ItemPath In $Path) {
					Try {
						ForEach ($ItemResolve In [String[]](Resolve-Path -Path ([System.IO.Path]::IsPathRooted($ItemPath) ? $ItemPath : (Join-Path -Path $BaseRoot -ChildPath $ItemPath)))) {
							If (!(Test-Path -LiteralPath $ItemResolve -PathType 'Leaf')) {
								Continue
							}
							If (
								$ItemResolve -inotmatch $BaseRootRegularExpression -or
								!(Test-ArtifactPath -InputObject $ItemResolve)
							) {
								$PathsInvalid += $ItemResolve
								Continue
							}
							$PathsValid += $ItemResolve
						}
					} Catch {
						$PathsInvalid += $ItemPath
					}
				}
			}
			'LiteralPath' {
				ForEach ($ItemLiteralPath In $LiteralPath) {
					Try {
						ForEach ($ItemResolve In [String[]](Resolve-Path -LiteralPath ([System.IO.Path]::IsPathRooted($ItemLiteralPath) ? $ItemLiteralPath : (Join-Path -Path $BaseRoot -ChildPath $ItemLiteralPath)))) {
							If (!(Test-Path -LiteralPath $ItemResolve -PathType 'Leaf')) {
								Continue
							}
							If (
								$ItemResolve -inotmatch $BaseRootRegularExpression -or
								!(Test-ArtifactPath -InputObject $ItemResolve)
							) {
								$PathsInvalid += $ItemResolve
								Continue
							}
							$PathsValid += $ItemResolve
						}
					} Catch {
						$PathsInvalid += $ItemLiteralPath
					}
				}
			}
		}
	}
	End {
		If (!(Test-GitHubActionsEnvironment -Artifact)) {
			Return (Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable')
		}
		If ($PathsInvalid.Count -igt 0 -and !$IgnoreIssuePaths.IsPresent) {
			Return ($PathsInvalid | ForEach-Object -Process {
				Return (Write-Error -Message "``$_`` is not an exist and valid file path!" -Category 'SyntaxError')
			})
		}
		If ($PathsValid.Count -ieq 0) {
			Return (Write-Error -Message 'No valid path is defined!' -Category 'NotSpecified')
		}
		[Hashtable]$InputObject = @{
			Name = $Name
			Path = ($PathsValid | ForEach-Object -Process {
				Return ($_ -ireplace $BaseRootRegularExpression, '' -ireplace '\\', '/')
			})
			BaseRoot = $BaseRoot
			IgnoreIssuePaths = $IgnoreIssuePaths.IsPresent
		}
		If ($Null -ine $RetentionTime) {
			$InputObject.RetentionTIme = $RetentionTime
		}
		$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\upload.js' -InputObject ([PSCustomObject]$InputObject | ConvertTo-Json -Depth 100 -Compress)
		If ($ResultRaw -ieq $False) {
			Return
		}
		[Hashtable]$Result = ($ResultRaw | ConvertFrom-Json -AsHashtable -Depth 100)
		$Result.FailedItem += $PathsInvalid
		$Result.FailedItems += $PathsInvalid
		Return [PSCustomObject]$Result
	}
}
Set-Alias -Name 'Save-Artifact' -Value 'Export-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Import Artifact
.DESCRIPTION
Import artifact that shared data from previous job in the same workflow.
.PARAMETER Name
Artifact name.
.PARAMETER Destination
Artifact destination.
.PARAMETER CreateSubfolder
Create a subfolder with artifact name and put data into here.
.PARAMETER All
Import all artifacts that shared data from previous job in the same workflow.
.OUTPUTS
[PSCustomObject[]] Imported artifacts' metadata.
#>
Function Import-Artifact {
	[CmdletBinding(DefaultParameterSetName = 'Select', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_import-githubactionsartifact#Import-GitHubActionsArtifact')]
	[OutputType([PSCustomObject[]])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Select', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][String[]]$Name,
		[Parameter(ParameterSetName = 'Select')][Switch]$CreateSubfolder,
		[Parameter(Mandatory = $True, ParameterSetName = 'All')][Switch]$All,
		[String]$Destination = $Env:GITHUB_WORKSPACE
	)
	Begin {
		If (!(Test-GitHubActionsEnvironment -Artifact)) {
			Return (Write-Error -Message 'Unable to get GitHub Actions artifact resources!' -Category 'ResourceUnavailable')
			Break# This is the best way to early terminate this function without terminate caller/invoker process.
		}
		[PSCustomObject[]]$OutputObject = @()
	}
	Process {
		Switch ($PSCmdlet.ParameterSetName) {
			'All' {
				$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download-all.js' -InputObject ([PSCustomObject]@{
					Destination = $Destination
				} | ConvertTo-Json -Depth 100 -Compress)
				If ($ResultRaw -ieq $False) {
					Continue
				}
				$OutputObject = ($ResultRaw | ConvertFrom-Json -Depth 100)
			}
			'Select' {
				ForEach ($Item In $Name) {
					$ResultRaw = Invoke-GitHubActionsNodeJsWrapper -Path 'artifact\download.js' -InputObject ([PSCustomObject]@{
						Name = $Item
						Destination = $Destination
						CreateSubfolder = $CreateSubfolder.IsPresent
					} | ConvertTo-Json -Depth 100 -Compress)
					If ($ResultRaw -ieq $False) {
						Continue
					}
					$OutputObject += ($ResultRaw | ConvertFrom-Json -Depth 100)
				}
			}
		}
	}
	End {
		Return $OutputObject
	}
}
Set-Alias -Name 'Restore-Artifact' -Value 'Import-Artifact' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Artifact Name
.DESCRIPTION
Test artifact name whether is valid.
.PARAMETER InputObject
Artifact name that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ArtifactName {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'Object')][String]$InputObject
	)
	Return ((Test-ArtifactPath -InputObject $InputObject) -and $InputObject -imatch '^[^\\/]+$')
}
<#
.SYNOPSIS
GitHub Actions (Internal) - Test Artifact Path
.DESCRIPTION
Test artifact path whether is valid.
.PARAMETER InputObject
Artifact path that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ArtifactPath {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'Object')][String]$InputObject
	)
	Return ($InputObject -imatch '^[^":<>|*?\n\r\t]+$')
}
Export-ModuleMember -Function @(
	'Export-Artifact',
	'Import-Artifact'
) -Alias @(
	'Restore-Artifact',
	'Save-Artifact'
)
