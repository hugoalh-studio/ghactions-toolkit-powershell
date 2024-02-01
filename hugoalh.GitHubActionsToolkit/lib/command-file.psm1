#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Internal - Add File Command
.DESCRIPTION
Add file command for the current step.
.PARAMETER FileCommandPath
File command path.
.PARAMETER Name
Name.
.PARAMETER Value
Value.
.OUTPUTS
[Void]
#>
Function Add-FileCommand {
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('CommandPath')][String]$FileCommandPath,
		[Parameter(Mandatory = $True, Position = 1)][String]$Name,
		[Parameter(Mandatory = $True, Position = 2)][AllowEmptyString()][AllowNull()][String]$Value
	)
	If ($Value -imatch '^.*$') {
		[String]$Content = "$Name=$Value"
	}
	Else {
		Do {
			[String]$Token = (New-Guid).Guid.ToLower() -ireplace '-', ''
		}
		While (
			$Name -imatch $Token -or
			$Value -imatch $Token
		)
		[String]$Content = "$Name<<$Token`n$($Value -ireplace '\r?\n', "`n")`n$Token"
	}
	Add-Content -LiteralPath $FileCommandPath -Value $Content -Confirm:$False -Encoding 'UTF8NoBOM'
}
<#
.SYNOPSIS
GitHub Actions - Clear File Command
.DESCRIPTION
Clear the file command that set in the current step.
.PARAMETER FileCommand
File command.
.OUTPUTS
[Void]
#>
Function Clear-FileCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_cleargithubactionsfilecommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Command', 'Commands', 'FileCommands')][String[]]$FileCommand
	)
	ForEach ($FC In $FileCommand) {
		Try {
			Set-Content -LiteralPath (Resolve-FileCommandPath -FileCommand $FC) -Value '' -Confirm:$False -Encoding 'UTF8NoBOM'
		}
		Catch {
			Write-Error -Message "Unable to clear the GitHub Actions file command: $_" -Category (($_)?.CategoryInfo.Category ?? 'OperationStopped')
		}
	}
}
Set-Alias -Name 'Remove-FileCommand' -Value 'Clear-FileCommand' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Internal - Get File Command
.DESCRIPTION
Get file command that set in the current step.
.PARAMETER FileCommandPath
File command path.
.OUTPUTS
[PSCustomObject[]]
#>
Function Get-FileCommand {
	[OutputType([PSCustomObject[]])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('CommandPath')][String]$FileCommandPath
	)
	[String[]]$FileCommandRaw = Get-Content -LiteralPath $FileCommandPath -Encoding 'UTF8NoBOM'
	[PSCustomObject[]]$Result = @()
	For ([UInt64]$Index = 0; $Index -lt $FileCommandRaw.Count; $Index += 1) {
		[String]$CurrentLine = $FileCommandRaw[$Index]
		If ($CurrentLine.Length -eq 0) {
			Continue
		}
		If ($CurrentLine -imatch '^.+<<.+?$') {
			[String[]]$CurrentLineSplit = $CurrentLine -isplit '<<'
			[String]$Name = $CurrentLineSplit |
				Select-Object -SkipLast 1 |
				Join-String -Separator '<<'
			[String]$Delimiter = $CurrentLineSplit |
				Select-Object -Last 1
			[String[]]$Value = @()
			[UInt64]$IndexOffset = $Index
			While ($True) {
				$IndexOffset += 1
				If ($IndexOffset -ge $FileCommandRaw.Count) {
					Throw "``$CurrentLine`` is missing pair delimiter in the file command content!"
				}
				[String]$CurrentLineOffset = $FileCommandRaw[$IndexOffset]
				If ($CurrentLineOffset -ceq $Delimiter) {
					Break
				}
				$Value += $CurrentLineOffset
			}
			$Result += [PSCustomObject]@{
				Name = $Name
				Value = $Value |
					Join-String -Separator "`n"
				Raw = @($CurrentLine) + $Value + @($Delimiter)
			}
			$Index = $IndexOffset
			Continue
		}
		If ($CurrentLine -imatch '^.+?=.+$') {
			[String[]]$CurrentLineSplit = $CurrentLine -isplit '='
			[String]$Name = $CurrentLineSplit |
				Select-Object -Index @(0)
			[String]$Value = $CurrentLineSplit |
				Select-Object -SkipIndex @(0) |
				Join-String -Separator '='
			$Result += [PSCustomObject]@{
				Name = $Name
				Value = $Value
				Raw = @($CurrentLine)
			}
			Continue
		}
		Throw "``$CurrentLine`` is not a valid file command content!"
	}
	$Result |
		Write-Output
}
<#
.SYNOPSIS
GitHub Actions - Internal - Remove File Command
.DESCRIPTION
Remove file command that set in the current step.
.PARAMETER FileCommandPath
File command path.
.PARAMETER Raw
Raw.
.OUTPUTS
[Void]
#>
Function Remove-FileCommand {
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('CommandPath')][String]$FileCommandPath,
		[Parameter(Mandatory = $True, Position = 1)][String[]]$Raw
	)
	[String]$FileCommandRaw = Get-Content -LiteralPath $FileCommandPath -Raw -Encoding 'UTF8NoBOM'
	[String]$RawReplace = $Raw |
		ForEach-Object -Process { [RegEx]::Escape($_) } |
		Join-String -Separator '\r?\n' -OutputPrefix '(?:^|\r?\n)' -OutputSuffix '(?:$|\r?\n)'
	Set-Content -LiteralPath $FileCommandPath -Value ($FileCommandRaw -ireplace $RawReplace, "`n") -Confirm:$False -Encoding 'UTF8NoBOM'
}
<#
.SYNOPSIS
GitHub Actions - Internal - Resolve File Command Path
.DESCRIPTION
Resolve file command path.
.PARAMETER FileCommand
File command.
.OUTPUTS
[String] File command path.
#>
Function Resolve-FileCommandPath {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions file command!')][Alias('Command')][String]$FileCommand
	)
	[String]$FileCommandToUpper = $FileCommand.ToUpper()
	[AllowEmptyString()][AllowNull()][String]$FileCommandPath = [System.Environment]::GetEnvironmentVariable($FileCommandToUpper)
	If ([String]::IsNullOrEmpty($FileCommandPath)) {
		Throw "Environment path ``$FileCommandToUpper`` is not defined!"
	}
	If (![System.IO.Path]::IsPathFullyQualified($FileCommandPath)) {
		Throw "``$FileCommandPath`` (environment path ``$FileCommandToUpper``) is not a valid absolute path!"
	}
	If (!(Test-Path -LiteralPath $FileCommandPath -PathType 'Leaf')) {
		Throw "Environment path ``$FileCommandToUpper`` is not exist!"
	}
	Return $FileCommandPath
}
<#
.SYNOPSIS
GitHub Actions - Write File Command
.DESCRIPTION
Write file command for the current step.
.PARAMETER FileCommand
File command.
.PARAMETER Name
Name.
.PARAMETER Value
Value.
.PARAMETER Optimize
Whether to have an optimize operation by replace exist command instead of add command directly.
.OUTPUTS
[Void]
#>
Function Write-FileCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsfilecommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Command')][String]$FileCommand,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = 'Value is not a valid GitHub Actions file command property name!')][String]$Name,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Value,
		[Switch]$Optimize
	)
	Begin {
		[Boolean]$ShouldProceed = $True
		Try {
			[String]$FileCommandPath = Resolve-FileCommandPath -FileCommand $FileCommand
		}
		Catch {
			$ShouldProceed = $False
			Write-Error -Message "Unable to write the GitHub Actions file command: $_" -Category 'ResourceUnavailable'
		}
		If ($Optimize.IsPresent) {
			Try {
				[PSCustomObject[]]$FileCommandContent = Get-FileCommand -FileCommandPath $FileCommandPath
			}
			Catch {
				Write-Warning -Message "Unable to get the GitHub Actions file command: $_"
			}
		}
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		Try {
			If ($Optimize.IsPresent -and $Null -ine $FileCommandContent -and $FileCommandContent.Name -icontains $Name) {
				Try {
					Remove-FileCommand -FileCommandPath $FileCommandPath -Raw (
						$FileCommandContent |
							Where-Object -FilterScript { $_.Name -ieq $Name }
					).Raw
					$FileCommandContent = $FileCommandContent |
						Where-Object -FilterScript { $_.Name -ine $Name }
				}
				Catch {
					Write-Warning -Message "Unable to remove the GitHub Actions file command: $_"
				}
			}
			Add-FileCommand -FileCommandPath $FileCommandPath -Name $Name -Value $Value
		}
		Catch {
			Write-Error -Message "Unable to write the GitHub Actions file command: $_" -Category (($_)?.CategoryInfo.Category ?? 'OperationStopped')
		}
	}
}
Export-ModuleMember -Function @(
	'Clear-FileCommand',
	'Write-FileCommand'
) -Alias @(
	'Remove-FileCommand'
)
