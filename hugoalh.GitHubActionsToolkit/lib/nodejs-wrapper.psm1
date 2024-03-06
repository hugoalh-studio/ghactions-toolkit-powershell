#Requires -PSEdition Core -Version 7.2
[SemVer]$NodeJsVersionMinimum = [SemVer]::Parse('16.13.0')
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\nodejs-wrapper'
[String]$WrapperPackageMetaFilePath = Join-Path -Path $WrapperRoot -ChildPath 'package.json'
[String]$WrapperScriptFilePath = Join-Path -Path $WrapperRoot -ChildPath 'main.js'
<#
.DESCRIPTION
Invoke NodeJS wrapper.
.PARAMETER Name
Name of the NodeJS wrapper.
.PARAMETER Argument
Arguments of the NodeJS wrapper.
.OUTPUTS
[PSCustomObject] Result of the NodeJS wrapper.
[PSCustomObject[]] Result of the NodeJS wrapper.
[String] Result of the NodeJS wrapper.
[String[]] Result of the NodeJS wrapper.
[UInt64] Result of the NodeJS wrapper.
#>
Function Invoke-NodeJsWrapper {
	[CmdletBinding()]
	[OutputType([PSCustomObject], [PSCustomObject[]], [String], [String[]], [UInt64])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][String]$Name,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Arguments')][Hashtable]$Argument
	)
	Try {
		If ($Null -eq (Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'SilentlyContinue')) {
			Throw 'NodeJS is not exist, accessible, or usable!'
		}
		Try {
			[SemVer]$NodeJsVersionCurrent = [SemVer]::Parse((
				node --no-deprecation --no-warnings '--eval=console.log(process.versions.node);' *>&1 |
					Join-String -Separator "`n"
			))
		}
		Catch {
			Throw 'unable to get NodeJS version!'
		}
		If ($NodeJsVersionMinimum -gt $NodeJsVersionCurrent) {
			Throw "NodeJS version is not fulfill the requirement! Current: $($NodeJsVersionCurrent.ToString()); Expect: >=$($NodeJsVersionMinimum.ToString())"
		}
		If (!(Test-Path -LiteralPath $WrapperPackageMetaFilePath -PathType 'Leaf')) {
			Throw "NodeJS wrapper package meta file ($WrapperPackageMetaFilePath) is missing!"
		}
		If (!(Test-Path -LiteralPath $WrapperScriptFilePath -PathType 'Leaf')) {
			Throw "NodeJS wrapper script file ($WrapperScriptFilePath) is missing!"
		}
	}
	Catch {
		Write-Error -Message "This function depends and requires to invoke with the compatible NodeJS environment, but $_" -Category 'ResourceUnavailable'
		Return
	}
	[String]$ArgumentStringify = $Argument |
		ConvertTo-Json -Depth 100 -Compress
	[String]$Token = (New-Guid).Guid.ToLower() -ireplace '-', ''
	Try {
		[String]$StdOut = node --no-deprecation --no-warnings $WrapperScriptFilePath $Name $ArgumentStringify $Token *>&1 |
			Where-Object -FilterScript {
				If ($_ -imatch '^::.+?::.*$') {
					Write-Host -Object $_
					Return $False
				}
				Return $True
			} |
			Join-String -Separator "`n"
		If ($LASTEXITCODE -ne 0) {
			Throw "[Exit Code $LASTEXITCODE] $StdOut"
		}
		If ($StdOut -inotmatch "(?<=$($Token)\r?\n)(?:.|\r?\n)*?(?=\r?\n$($Token))") {
			Throw 'No data return.'
		}
		[PSCustomObject]$Result = $Matches[0] |
			ConvertFrom-Json -Depth 100
		If (!$Result.IsSuccess) {
			Throw $Result.Reason
		}
		Write-Output -InputObject $Result.Result
	}
	Catch {
		Write-Error -Message "Unable to successfully invoke the NodeJS wrapper ``$Name``: $_" -Category 'InvalidData'
	}
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper'
)
