#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'internal\new-random-token'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
[SemVer]$NodeJsVersionMinimum = [SemVer]::Parse('14.15.0')
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath 'nodejs-wrapper'
[String]$WrapperPackageFilePath = Join-Path -Path $WrapperRoot -ChildPath 'package.json'
[String]$WrapperScriptFilePath = Join-Path -Path $WrapperRoot -ChildPath 'main.js'
[Boolean]$EnvironmentTested = $False
[Boolean]$EnvironmentResult = $False
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
		[Parameter(Mandatory = $True, Position = 1)][Alias('Arguments')][Hashtable]$Argument
	)
	If (!(Test-NodeJsEnvironment)) {
		Write-Error -Message 'This function depends and requires to invoke with the compatible NodeJS environment!' -Category 'ResourceUnavailable'
		Return
	}
	ForEach ($Item In @($WrapperPackageFilePath, $WrapperScriptFilePath)) {
		If (!(Test-Path -LiteralPath $Item -PathType 'Leaf')) {
			Write-Error -Message "Unable to invoke the NodeJS wrapper: Wrapper resource `"$Item`" is missing!" -Category 'ResourceUnavailable'
			Return
		}
	}
	Try {
		[String]$ResultSeparator = "=====$(New-GitHubActionsRandomToken)====="
		[String]$Base64Name = Convert-FromUtf8StringToBase64String -InputObject $Name
		[String]$Base64Argument = $Argument |
			ConvertTo-Json -Depth 100 -Compress |
			Convert-FromUtf8StringToBase64String
		[String]$Base64ResultSeparator = Convert-FromUtf8StringToBase64String -InputObject $ResultSeparator
		[String[]]$Result = Invoke-Expression -Command "node --no-deprecation --no-warnings `"$WrapperScriptFilePath`" $Base64Name $Base64Argument $Base64ResultSeparator"
		[UInt64[]]$ResultSkipIndexes = @()
		For ([UInt64]$ResultIndex = 0; $ResultIndex -lt $Result.Count; $ResultIndex += 1) {
			[String]$ResultLine = $Result[$ResultIndex]
			If ($ResultLine -imatch '^::.+?::.*$') {
				Write-Host -Object $ResultLine
				$ResultSkipIndexes += $ResultIndex
				Continue
			}
			If ($ResultLine -ieq $ResultSeparator) {
				$ResultSkipIndexes += @($ResultIndex..($Result.Count - 1))
				Break
			}
		}
		If ($LASTEXITCODE -ne 0) {
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
		Write-Error -Message "Unable to successfully invoke the NodeJS wrapper (``$Name``): $_" -Category 'InvalidData'
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
		Try {
			If ($NodeJsVersionMinimum -gt [SemVer]::Parse((
				node --no-deprecation --no-warnings --eval='console.log(JSON.stringify(process.versions));' |
					Join-String -Separator "`n" |
					ConvertFrom-Json -Depth 100 |
					Select-Object -ExpandProperty 'node'
			))) {
				Throw
			}
		}
		Catch {
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
