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
[Boolean]$ResultTest = $False
[SemVer]$NodeJsMinimumVersion = [SemVer]::Parse('14.15.0')
[SemVer]$NpmMinimumVersion = [SemVer]::Parse('6.14.8')
[RegEx]$SemVerRegEx = 'v?\d+\.\d+\.\d+'
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
[String]$WrapperPath = Join-Path -Path $WrapperRoot -ChildPath 'lib' -AdditionalChildPath @('main.js')
<#
.SYNOPSIS
GitHub Actions - Invoke NodeJS Wrapper
.DESCRIPTION
Invoke NodeJS wrapper.
.PARAMETER Name
Name of the NodeJS wrapper.
.PARAMETER InputObject
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
		[Parameter(Mandatory = $True, Position = 1)][Alias('Argument', 'Arguments', 'Input', 'Object', 'Parameter', 'Parameters')][Hashtable]$InputObject
	)
	If (!(Test-NodeJsEnvironment)) {
		Write-Error -Message 'This function requires to invoke with the compatible NodeJS environment!' -Category 'ResourceUnavailable'
		Return
	}
	If (!(Test-Path -LiteralPath $WrapperPath -PathType 'Leaf')) {
		Write-Error -Message 'Wrapper is missing!' -Category 'ResourceUnavailable'
		Return
	}
	[String]$ResultSeparator = "=====$(New-GitHubActionsRandomToken -Length 32)====="
	Try {
		[String[]]$Result = Invoke-Expression -Command "node --no-deprecation --no-warnings `"$WrapperPath`" `"$Name`" `"$([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((
			$InputObject |
				ConvertTo-Json -Depth 100 -Compress
		))))`" `"$ResultSeparator`""
		[UInt32[]]$ResultSkipIndexes = @()
		For ([UInt32]$ResultIndex = 0; $ResultIndex -ilt $Result.Count; $ResultIndex++) {
			[String]$Item = $Result[$ResultIndex]
			If ($Item -imatch '^::.+?::.*$') {
				Write-Host -Object $Item
				$ResultSkipIndexes += $ResultIndex
			}
			If ($Item -ieq $ResultSeparator) {
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
		[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Result[$Result.IndexOf($ResultSeparator) + 1])) |
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
		Write-Output -InputObject ($ResultDependencies -and $ResultTest)
		Return
	}
	$Script:IsTested = $False
	If ($ReinstallDependencies.IsPresent) {
		$Script:ResultDependencies = $False
	}
	If ($Retest.IsPresent) {
		$Script:ResultTest = $False
	}
	If (!$ResultTest) {
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
			$Script:ResultTest = $False
			Write-Output -InputObject ($ResultDependencies -and $ResultTest)
			Return
		}
	}
	$Script:ResultTest = $True
	If (!$ResultDependencies) {
		Try {
			Try {
				$Null = Get-Command -Name 'pnpm' -CommandType 'Application' -ErrorAction 'Stop'# `Get-Command` will throw error when nothing is found.
			}
			Catch {
				Try {
					$Null = npm install --global pnpm
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
			Write-Output -InputObject ($ResultDependencies -and $ResultTest)
			Return
		}
	}
	$Script:IsTested = $True
	$Script:ResultDependencies = $True
	Write-Output -InputObject ($ResultDependencies -and $ResultTest)
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper',
	'Test-NodeJsEnvironment'
)
