#Requires -PSEdition Core -Version 7.2
[SemVer]$NodeJsVersionMinimum = [SemVer]::Parse('14.15.0')
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
[String]$WrapperPackageFilePath = Join-Path -Path $WrapperRoot -ChildPath 'package.json'
[String]$WrapperScriptFilePath = Join-Path -Path $WrapperRoot -ChildPath 'main.js'
[Boolean]$EnvironmentTested = $False
[Boolean]$EnvironmentResult = $False
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
Result of the NodeJS wrapper.
#>
Function Invoke-NodeJsWrapper {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Name,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Arguments')][Hashtable]$Argument
	)
	Begin {
		[Boolean]$ShouldProceed = $True
		If (!(Test-NodeJsEnvironment)) {
			Write-Error -Message 'This function depends and requires to invoke with the compatible NodeJS environment!' -Category 'ResourceUnavailable'
			$ShouldProceed = $False
		}
		ForEach ($FilePath In @($WrapperPackageFilePath, $WrapperScriptFilePath)) {
			If (!(Test-Path -LiteralPath $FilePath -PathType 'Leaf')) {
				Write-Error -Message "Unable to invoke the NodeJS wrapper: Wrapper resource `"$FilePath`" is missing!" -Category 'ResourceUnavailable'
				$ShouldProceed = $False
			}
		}
		[String]$ExchangeFilePath = Join-Path -Path $Env:RUNNER_TEMP -ChildPath ([System.IO.Path]::GetRandomFileName())
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		[Hashtable]$ExchangeInput = @{ 'wrapperName' = $Name } + $Argument
		[String]$ExchangeInputRaw = $ExchangeInput |
			ConvertTo-Json -Depth 100 -Compress
		Set-Content -LiteralPath $ExchangeFilePath -Value $ExchangeInputRaw -Confirm:$False -Encoding 'UTF8NoBOM'
		Try {
			[String[]]$StdOut = Invoke-Expression -Command "node --no-deprecation --no-warnings `"$WrapperScriptFilePath`" `"$ExchangeFilePath`"" |
				Where-Object -FilterScript {
					If ($_ -imatch '^::.+?::.*$') {
						Write-Host -Object $_
						Write-Output -InputObject $False
					}
					Else {
						Write-Output -InputObject $True
					}
				}
			If ($LASTEXITCODE -ne 0) {
				Throw "Unexpected exit code ``$LASTEXITCODE``! $(
					$StdOut |
						Join-String -Separator "`n"
				)"
			}
			[PSCustomObject]$Result = Get-Content -LiteralPath $ExchangeFilePath -Raw -Encoding 'UTF8NoBOM' |
				ConvertFrom-Json -Depth 100
			If (!$Result.IsSuccess) {
				Throw $Result.Reason
			}
			$Result.Result |
				Write-Output
		}
		Catch {
			Write-Error -Message "Unable to successfully invoke the NodeJS wrapper (``$Name``): $_" -Category 'InvalidData'
		}
	}
	End {
		If ($ShouldProceed) {
			Remove-Item -LiteralPath $ExchangeFilePath -Force -Confirm:$False -ErrorAction 'Continue'
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Test NodeJS Environment
.DESCRIPTION
Test the current machine whether has compatible NodeJS environment; Test result always cache for reuse.
.PARAMETER Retest
Whether to redo this test by ignore the cached test result.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-NodeJsEnvironment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_testgithubactionsnodejsenvironment')]
	[OutputType([Boolean])]
	Param (
		[Alias('Redo')][Switch]$Retest,
		[Alias('Reinstall', 'ReinstallDependency', 'ReinstallPackage', 'ReinstallPackages')][Switch]$ReinstallDependencies# Deprecated.
	)
	If ($PSBoundParameters.ContainsKey('ReinstallDependencies')) {
		Write-Warning -Message 'Parameter `ReinstallDependencies` is deprecated and will remove in the future version!'
	}
	If ($EnvironmentTested -and !$Retest.IsPresent) {
		Write-Verbose -Message 'Previously tested the NodeJS environment; Return the previous result.'
		Write-Output -InputObject $EnvironmentResult
		Return
	}
	$Script:EnvironmentTested = $False
	$Script:EnvironmentResult = $False
	Try {
		Try {
			$Null = Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'Stop'# `Get-Command` will throw error when nothing is found.
		}
		Catch {
			Throw 'Unable to find NodeJS!'
		}
		If ($NodeJsVersionMinimum -gt [SemVer]::Parse((
			node --no-deprecation --no-warnings --eval='console.log(JSON.stringify(process.versions));' |
				Join-String -Separator "`n" |
				ConvertFrom-Json -Depth 100 |
				Select-Object -ExpandProperty 'node'
		))) {
			Throw 'NodeJS is not match the requirement!'
		}
	}
	Catch {
		Write-Verbose -Message $_
		$Script:EnvironmentTested = $True
		$Script:EnvironmentResult = $False
		Write-Output -InputObject $EnvironmentResult
		Return
	}
	$Script:EnvironmentTested = $True
	$Script:EnvironmentResult = $True
	Write-Output -InputObject $EnvironmentResult
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper',
	'Test-NodeJsEnvironment'
)
