#Requires -PSEdition Core -Version 7.2
[SemVer]$RequireVersionMinimum = [SemVer]::Parse('16.13.0')
[String]$WrapperRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\nodejs-wrapper'
[String]$WrapperPackageMetaFilePath = Join-Path -Path $WrapperRoot -ChildPath 'package.json'
[String]$WrapperScriptFilePath = Join-Path -Path $WrapperRoot -ChildPath 'main.js'
<#
.SYNOPSIS
GitHub Actions - Internal - Invoke NodeJS Wrapper
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
	Begin {
		[Boolean]$ShouldProceed = $True
		Try {
			$CommandMeta = Get-Command -Name 'node' -CommandType 'Application' -ErrorAction 'SilentlyContinue'
			If ($Null -ieq $CommandMeta) {
				Throw 'NodeJS is not exist, or not accessible and usable!'
			}
			Try {
				[PSCustomObject]$VersionsTable = node --no-deprecation --no-warnings '--eval=console.log(JSON.stringify(process.versions));' *>&1 |
					Join-String -Separator "`n" |
					ConvertFrom-Json -Depth 100
				[SemVer]$CurrentVersion = [SemVer]::Parse($VersionsTable.node)
			}
			Catch {
				Throw 'NodeJS versions table is not parsable!'
			}
			If ($RequireVersionMinimum -gt $CurrentVersion) {
				Throw 'NodeJS is not fulfill the requirement!'
			}
			ForEach ($FilePath In @($WrapperPackageMetaFilePath, $WrapperScriptFilePath)) {
				If (!(Test-Path -LiteralPath $FilePath -PathType 'Leaf')) {
					Throw "wrapper resource `"$FilePath`" is missing!"
				}
			}
			If ([String]::IsNullOrEmpty($Env:RUNNER_TEMP)) {
				Throw 'environment variable `RUNNER_TEMP` is not defined!'
			}
			If (![System.IO.Path]::IsPathFullyQualified($Env:RUNNER_TEMP)) {
				Throw "``$Env:RUNNER_TEMP`` (environment variable ``RUNNER_TEMP``) is not a valid absolute path!"
			}
			If (!(Test-Path -LiteralPath $Env:RUNNER_TEMP -PathType 'Container')) {
				Throw "path ``$Env:RUNNER_TEMP`` is not initialized!"
			}
		}
		Catch {
			$ShouldProceed = $False
			Write-Error -Message "This function depends and requires to invoke with the compatible NodeJS environment, but $_" -Category 'ResourceUnavailable'
		}
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		Do {
			[String]$ExchangeFilePath = Join-Path -Path $Env:RUNNER_TEMP -ChildPath ([System.IO.Path]::GetRandomFileName())
		}
		While (Test-Path -LiteralPath $ExchangeFilePath -PathType 'Leaf')
		Try {
			@{ '$name' = $Name } + $Argument |
				ConvertTo-Json -Depth 100 -Compress |
				Set-Content -LiteralPath $ExchangeFilePath -Confirm:$False -Encoding 'UTF8NoBOM'
			[String]$StdOut = node --no-deprecation --no-warnings $WrapperScriptFilePath $ExchangeFilePath *>&1 |
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
			[PSCustomObject]$Result = Get-Content -LiteralPath $ExchangeFilePath -Raw -Encoding 'UTF8NoBOM' |
				ConvertFrom-Json -Depth 100
			If (!$Result.IsSuccess) {
				Throw $Result.Reason
			}
			$Result.Result |
				Write-Output
		}
		Catch {
			Write-Error -Message "Unable to successfully invoke the NodeJS wrapper ``$Name``: $_" -Category 'InvalidData'
		}
	}
	End {
		If (Test-Path -LiteralPath $ExchangeFilePath -PathType 'Leaf') {
			Remove-Item -LiteralPath $ExchangeFilePath -Force -Confirm:$False -ErrorAction 'Continue'
		}
	}
}
Export-ModuleMember -Function @(
	'Invoke-NodeJsWrapper'
)
