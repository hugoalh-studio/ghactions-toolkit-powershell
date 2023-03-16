#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'internal\new-random-token'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
[Boolean]$IsTested = $False
[Boolean]$ResultDependencies = $False
[Boolean]$ResultEnvironment = $False
[SemVer]$NodeJsMinimumVersion = [SemVer]::Parse('14.15.0')
[SemVer]$NpmMinimumVersion = [SemVer]::Parse('6.14.8')
[SemVer]$PnpmMinimumVersion = [SemVer]::Parse('7.28.0')
[RegEx]$SemVerRegEx = 'v?\d+\.\d+\.\d+'
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
[String]$WrapperMetaPath = Join-Path -Path $WrapperRoot -ChildPath 'package.json'
[String]$WrapperScriptPath = Join-Path -Path $WrapperRoot -ChildPath 'unbundled.js'
<#
.SYNOPSIS
GitHub Actions - Internal - Convert From Base64 String To Utf8 String
.PARAMETER InputObject
String that need decode from base64.
.OUTPUTS
[String] An decoded string.
#>
Function Convert-FromBase64StringToUtf8String {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($InputObject)) |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Internal - Convert From Utf8 String To Base64 String
.PARAMETER InputObject
String that need encode to base64.
.OUTPUTS
[String] An encoded string.
#>
Function Convert-FromUtf8StringToBase64String {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($InputObject)) |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Invoke NodeJS Wrapper
.DESCRIPTION
Invoke NodeJS wrapper.
.PARAMETER Name
Name of the NodeJS wrapper.
.PARAMETER Argument
Arguments of the NodeJS wrapper.
.OUTPUTS
[PSCustomObject] Result of the NodeJS wrapper.
[PSCustomObject[]] Result of the NodeJS wrapper.
#>
Function Invoke-NodeJsWrapper {
	[CmdletBinding()]
	[OutputType(([PSCustomObject], [PSCustomObject[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Name,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Arguments')][Hashtable]$Argument,
		[Alias('Debug')][Switch]$LocalDebug
	)
	If (!$LocalDebug.IsPresent) {
		If (!(Test-NodeJsEnvironment)) {
			Write-Error -Message 'This function depends and requires to invoke with the compatible NodeJS environment!' -Category 'ResourceUnavailable'
			Return
		}
		If (!(Test-Path -LiteralPath $WrapperMetaPath -PathType 'Leaf')) {
			Write-Error -Message 'Wrapper meta is missing!' -Category 'ResourceUnavailable'
			Return
		}
		If (!(Test-Path -LiteralPath $WrapperScriptPath -PathType 'Leaf')) {
			Write-Error -Message 'Wrapper script is missing!' -Category 'ResourceUnavailable'
			Return
		}
	}
	[String]$ResultSeparator = "=====$(New-GitHubActionsRandomToken)====="
	Try {
		[String[]]$Result = Invoke-Expression -Command "node --no-deprecation --no-warnings `"$WrapperScriptPath`" $(Convert-FromUtf8StringToBase64String -InputObject $Name) $(
			$Argument |
				ConvertTo-Json -Depth 100 -Compress |
				Convert-FromUtf8StringToBase64String
		) $(Convert-FromUtf8StringToBase64String -InputObject $ResultSeparator)"
		[UInt32[]]$ResultSkipIndexes = @()
		For ([UInt32]$ResultIndex = 0; $ResultIndex -ilt $Result.Count; $ResultIndex++) {
			[String]$ResultLine = $Result[$ResultIndex]
			If ($ResultLine -imatch '^::.+?::.*$') {
				Write-Host -Object $ResultLine
				$ResultSkipIndexes += $ResultIndex
			}
			If ($ResultLine -ieq $ResultSeparator) {
				$ResultSkipIndexes += @($ResultIndex..($Result.Count - 1))
				Break
			}
		}
		If ($LASTEXITCODE -ine 0) {
			Throw "Unexpected exit code ``$LASTEXITCODE``! $(
				$Result |
					Select-Object -SkipIndex $ResultSkipIndexes |
					Join-String -Separator "`n"
			)"
		}
		$Result[$Result.Count - 1] |
			Convert-FromBase64StringToUtf8String |
			ConvertFrom-Json -Depth 100 |
			Write-Output
	}
	Catch {
		Write-Error -Message "Unable to successfully invoke NodeJS wrapper (``$Name``): $_" -Category 'InvalidData'
	}
}
<#
.SYNOPSIS
GitHub Actions - Test NodeJS Environment
.DESCRIPTION
Test the current machine whether has compatible NodeJS environment; Test result always cache for reuse.
.PARAMETER Retest
Whether to redo this test by ignore the cached test result.
.PARAMETER ReinstallDependencies
Whether to force reinstall dependencies even though available.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-NodeJsEnvironment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_testgithubactionsnodejsenvironment')]
	[OutputType([Boolean])]
	Param (
		[Alias('Redo')][Switch]$Retest,
		[Alias('Reinstall', 'ReinstallDependency', 'ReinstallPackage', 'ReinstallPackages')][Switch]$ReinstallDependencies
	)
	If ($IsTested -and !$Retest.IsPresent -and !$ReinstallDependencies.IsPresent) {
		Write-Verbose -Message 'Previously tested NodeJS environment; Return previous result.'
		Write-Output -InputObject ($ResultDependencies -and $ResultEnvironment)
		Return
	}
	$Script:IsTested = $False
	If ($ReinstallDependencies.IsPresent) {
		$Script:ResultDependencies = $False
	}
	If ($Retest.IsPresent) {
		$Script:ResultEnvironment = $False
	}
	If (!$ResultEnvironment) {
		Try {
			Try {
				$Null = Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'Stop'# `Get-Command` will throw error when nothing is found.
			}
			Catch {
				Throw 'Unable to find NodeJS!'
			}
			Try {
				[String]$NodeJsVersionStdOut = node --no-deprecation --no-warnings --version |
					Join-String -Separator "`n"
				If (
					$NodeJsVersionStdOut -inotmatch $SemVerRegEx -or
					$NodeJsMinimumVersion -igt [SemVer]::Parse(($Matches[0] -ireplace '^v', ''))
				) {
					Throw
				}
			}
			Catch {
				Throw 'NodeJS is not match the requirement!'
			}
			Try {
				$Null = Get-Command -Name 'npm' -CommandType 'Application' -ErrorAction 'Stop'# `Get-Command` will throw error when nothing is found.
			}
			Catch {
				Throw 'Unable to find NPM!'
			}
			Try {
				[String]$NpmVersionStdOut = npm --version |
					Join-String -Separator "`n"
				If (
					$NpmVersionStdOut -inotmatch $SemVerRegEx -or
					$NpmMinimumVersion -igt [SemVer]::Parse(($Matches[0] -ireplace '^v', ''))
				) {
					Throw
				}
			}
			Catch {
				Throw 'NPM is not match the requirement!'
			}
		}
		Catch {
			Write-Verbose -Message $_
			$Script:IsTested = $True
			$Script:ResultEnvironment = $False
			Write-Output -InputObject ($ResultDependencies -and $ResultEnvironment)
			Return
		}
	}
	$Script:ResultEnvironment = $True
	If (!$ResultDependencies) {
		Try {
			Try {
				$Null = Get-Command -Name 'pnpm' -CommandType 'Application' -ErrorAction 'Stop'# `Get-Command` will throw error when nothing is found.
				[String]$PnpmVersionStdOut = pnpm --version |
					Join-String -Separator "`n"
				If (
					$PnpmVersionStdOut -inotmatch $SemVerRegEx -or
					$PnpmMinimumVersion -igt [SemVer]::Parse(($Matches[0] -ireplace '^v', ''))
				) {
					Throw
				}
			}
			Catch {
				Try {
					$Null = npm install --global pnpm@latest
				}
				Catch {
					Throw 'Unable to install PNPM!'
				}
			}
			Try {
				$CurrentWorkingDirectory = Get-Location
				$Null = Set-Location -LiteralPath $WrapperRoot
				Try {
					$Null = pnpm install
				}
				Catch {
					Throw 'Unable to install NodeJS wrapper API dependencies!'
				}
				Finally {
					Set-Location -LiteralPath $CurrentWorkingDirectory.Path
				}
			}
			Catch {
				Throw $_
			}
		}
		Catch {
			Write-Verbose -Message $_
			$Script:IsTested = $True
			$Script:ResultDependencies = $False
			Write-Output -InputObject ($ResultDependencies -and $ResultEnvironment)
			Return
		}
	}
	$Script:IsTested = $True
	$Script:ResultDependencies = $True
	Write-Output -InputObject ($ResultDependencies -and $ResultEnvironment)
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper',
	'Test-NodeJsEnvironment'
)
