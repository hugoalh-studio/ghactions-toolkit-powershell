#Requires -PSEdition Core
#Requires -Version 7.2
enum GitHubActionsAnnotationType {
	E
	Error
	N
	Note
	Notice
	W
	Warn
	Warning
}
<#
.SYNOPSIS
GitHub Actions - Internal - Format Command
.DESCRIPTION
An internal function to escape command characters that can cause issues.
.PARAMETER InputObject
String that need to escape command characters.
.PARAMETER Property
Also escape command property characters.
.OUTPUTS
String
#>
function Format-GitHubActionsCommand {
	[CmdletBinding()]
	[OutputType([string])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyString()][Alias('Input', 'Object')][string]$InputObject,
		[Alias('Properties')][switch]$Property
	)
	begin {}
	process {
		[string]$OutputObject = $InputObject -replace '%', '%25' -replace '\n', '%0A' -replace '\r', '%0D'
		if ($Property) {
			$OutputObject = $OutputObject -replace ',', '%2C' -replace ':', '%3A'
		}
		return $OutputObject
	}
	end {}
}
Set-Alias -Name 'Format-GHActionsCommand' -Value 'Format-GitHubActionsCommand' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Command
.DESCRIPTION
Write command to communicate with the runner machine.
.PARAMETER Command
Command.
.PARAMETER Message
Message.
.PARAMETER Property
Command property.
.OUTPUTS
Void
#>
function Write-GitHubActionsCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionscommand#Write-GitHubActionsCommand')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Command` must be in single line string!')][string]$Command,
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message = '',
		[Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)][Alias('Properties')][hashtable]$Property = @{}
	)
	begin {}
	process {
		[string[]]$PropertyResult = $Property.GetEnumerator() | Sort-Object -Property 'Name' | ForEach-Object -Process {
			return "$($_.Name)=$(Format-GitHubActionsCommand -InputObject $_.Value -Property)"
		}
		Write-Host -Object "::$Command$(($PropertyResult.Count -gt 0) ? " $($PropertyResult -join ',')" : '')::$(Format-GitHubActionsCommand -InputObject $Message)"
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsCommand' -Value 'Write-GitHubActionsCommand' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Environment Variable
.DESCRIPTION
Add environment variable to the system environment variables and automatically makes it available to all subsequent actions in the current job; The currently running action cannot access the updated environment variables.
.PARAMETER InputObject
Environment variables.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
.OUTPUTS
Void
#>
function Add-GitHubActionsEnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsenvironmentvariable#Add-GitHubActionsEnvironmentVariable')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not match the require environment variable name pattern!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Value` must be in single line string!')][string]$Value
	)
	begin {
		[hashtable]$Result = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if ($_.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category 'InvalidType'
					} elseif ($_.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($_.Name)`` is not match the require environment variable name pattern!" -Category 'SyntaxError'
					} elseif ($_.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category 'InvalidType'
					} elseif ($_.Value -notmatch '^.+$') {
						Write-Error -Message 'Parameter `Value` must be in single line string!' -Category 'SyntaxError'
					} else {
						$Result[$_.Name] = $_.Value
					}
				}
				break
			}
			'single' {
				$Result[$Name] = $Value
				break
			}
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_ENV -Value (($Result.GetEnumerator() | ForEach-Object -Process {
				return "$($_.Name)=$($_.Value)"
			}) -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Add-GHActionsEnv' -Value 'Add-GitHubActionsEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GHActionsEnvironment' -Value 'Add-GitHubActionsEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GHActionsEnvironmentVariable' -Value 'Add-GitHubActionsEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GitHubActionsEnv' -Value 'Add-GitHubActionsEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GitHubActionsEnvironment' -Value 'Add-GitHubActionsEnvironmentVariable' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add PATH
.DESCRIPTION
Add directory to the system `PATH` variable and automatically makes it available to all subsequent actions in the current job; The currently running action cannot access the updated path variables.
.PARAMETER Path
System path.
.PARAMETER NoValidator
Disable validator to not check the path is valid or not.
.OUTPUTS
Void
#>
function Add-GitHubActionsPATH {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionspath#Add-GitHubActionsPATH')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('Paths')][string[]]$Path,
		[Alias('NoValidate', 'SkipValidate', 'SkipValidator')][switch]$NoValidator
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		$Path | ForEach-Object -Process {
			if (
				$NoValidator -or
				(Test-Path -Path $_ -PathType 'Container' -IsValid)
			) {
				$Result += $_
			} else {
				Write-Error -Message "``$_`` is not match the require PATH pattern!" -Category 'SyntaxError'
			}
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_PATH -Value ($Result -join "`n") -Confirm:$false -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Add-GHActionsPATH' -Value 'Add-GitHubActionsPATH' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Problem Matcher
.DESCRIPTION
Problem matchers are a way to scan the output of actions for a specified regular expression pattern and automatically surface that information prominently in the user interface, both annotations and log file decorations are created when a match is detected. For more information, please visit https://github.com/actions/toolkit/blob/main/docs/problem-matchers.md.
.PARAMETER Path
Relative path to the JSON file problem matcher.
.PARAMETER LiteralPath
Relative literal path to the JSON file problem matcher.
.OUTPUTS
Void
#>
function Add-GitHubActionsProblemMatcher {
	[CmdletBinding(DefaultParameterSetName = 'path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsproblemmatcher#Add-GitHubActionsProblemMatcher')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'path', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][SupportsWildcards()][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('File', 'Files', 'Paths')][string[]]$Path,
		[Parameter(Mandatory = $true, ParameterSetName = 'literal-path', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `LiteralPath` must be in single line string!')][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][string[]]$LiteralPath
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'path' {
				$Path | ForEach-Object -Process {
					return ([string[]](Resolve-Path -Path $_ -Relative) | Where-Object -FilterScript {
						return ($null -ne $_ -and $_.Length -gt 0)
					} | ForEach-Object -Process {
						return Write-GitHubActionsCommand -Command 'add-matcher' -Message ($_ -replace '^\.[\\\/]', '' -replace '\\', '/')
					})
				}
				break
			}
			'literal-path' {
				$LiteralPath | ForEach-Object -Process {
					return Write-GitHubActionsCommand -Command 'add-matcher' -Message ($_ -replace '^\.[\\\/]', '' -replace '\\', '/')
				}
				break
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Add-GHActionsProblemMatcher' -Value 'Add-GitHubActionsProblemMatcher' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret will get masked from the log.
.PARAMETER Value
The secret.
.PARAMETER WithChunks
Split the secret to chunks to well make a secret will get masked from the log.
.OUTPUTS
Void
#>
function Add-GitHubActionsSecretMask {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionssecretmask#Add-GitHubActionsSecretMask')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][Alias('Key', 'Secret', 'Token')][string]$Value,
		[Alias('WithChunk')][switch]$WithChunks
	)
	begin {}
	process {
		if ($Value.Length -gt 0) {
			Write-GitHubActionsCommand -Command 'add-mask' -Message $Value
		}
		if ($WithChunks) {
			[string[]]($Value -split '[\b\n\r\s\t_-]+') | ForEach-Object -Process {
				if ($_ -ne $Value -and $_.Length -gt 2) {
					Write-GitHubActionsCommand -Command 'add-mask' -Message $_
				}
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Add-GHActionsMask' -Value 'Add-GitHubActionsSecretMask' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GHActionsSecret' -Value 'Add-GitHubActionsSecretMask' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GitHubActionsMask' -Value 'Add-GitHubActionsSecretMask' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-GitHubActionsSecret' -Value 'Add-GitHubActionsSecretMask' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary
.DESCRIPTION
Add some GitHub flavored Markdown for step so that it will be displayed on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures. When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
Void
#>
function Add-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummary#Add-GitHubActionsStepSummary')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][string[]]$Value,
		[switch]$NoNewLine
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		if ($Value.Count -gt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Add-GHActionsStepSummary' -Value 'Add-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Echoing Commands
.DESCRIPTION
Disable echoing of commands, the run's log will not show the command itself; A command is echoed if there are any errors processing the command; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Disable-GitHubActionsEchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsechoingcommands#Disable-GitHubActionsEchoingCommands')]
	[OutputType([void])]
	param()
	return Write-GitHubActionsCommand -Command 'echo' -Message 'off'
}
Set-Alias -Name 'Disable-GHActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsEcho' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsEchoing' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoingCommand' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsEchoingCommands' -Value 'Disable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Processing Commands
.DESCRIPTION
Stop processing any commands to allow log anything without accidentally running commands.
.PARAMETER EndToken
An end token for function `Enable-GitHubActionsProcessingCommands`.
.OUTPUTS
String
#>
function Disable-GitHubActionsProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_disable-githubactionsprocessingcommands#Disable-GitHubActionsProcessingCommands')]
	[OutputType([string])]
	param(
		[Parameter(Position = 0)][ValidateScript({
			return ($_ -match '^.+$' -and $_.Length -ge 4 -and $_ -inotin @(
				'add-mask',
				'add-matcher',
				'debug',
				'echo',
				'endgroup',
				'error',
				'group',
				'notice',
				'remove-matcher',
				'save-state',
				'set-output',
				'warning'
			))
		}, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, not match any GitHub Actions commands, and unique!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][string]$EndToken = ((New-Guid).Guid -replace '-', '')
	)
	Write-GitHubActionsCommand -Command 'stop-commands' -Message $EndToken
	return $EndToken
}
Set-Alias -Name 'Disable-GHActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GHActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Disable-GitHubActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GHActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsProcess' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsCommandsProcessing' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessingCommand' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-GitHubActionsProcessingCommands' -Value 'Disable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Echoing Commands
.DESCRIPTION
Enable echoing of commands, the run's log will show the command itself; Commands `add-mask`, `debug`, `warning`, and `error` do not support echoing because their outputs are already echoed to the log; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Enable-GitHubActionsEchoingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsechoingcommands#Enable-GitHubActionsEchoingCommands')]
	[OutputType([void])]
	param()
	return Write-GitHubActionsCommand -Command 'echo' -Message 'on'
}
Set-Alias -Name 'Enable-GHActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsEcho' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsEchoing' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoingCommand' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsEchoingCommands' -Value 'Enable-GitHubActionsEchoingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Processing Commands
.DESCRIPTION
Resume processing any commands to allow running commands.
.PARAMETER EndToken
An end token from function `Disable-GitHubActionsProcessingCommands`.
.OUTPUTS
Void
#>
function Enable-GitHubActionsProcessingCommands {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enable-githubactionsprocessingcommands#Enable-GitHubActionsProcessingCommands')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidateScript({
			return ($_ -match '^.+$' -and $_.Length -ge 4 -and $_ -inotin @(
				'add-mask',
				'add-matcher',
				'debug',
				'echo',
				'endgroup',
				'error',
				'group',
				'notice',
				'remove-matcher',
				'save-state',
				'set-output',
				'warning'
			))
		}, ErrorMessage = 'Parameter `EndToken` must be in single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][string]$EndToken
	)
	return Write-GitHubActionsCommand -Command $EndToken
}
Set-Alias -Name 'Enable-GHActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GHActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enable-GitHubActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GHActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsProcess' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsCommandsProcessing' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessingCommand' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-GitHubActionsProcessingCommands' -Value 'Enable-GitHubActionsProcessingCommands' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enter Log Group
.DESCRIPTION
Create an expandable group in the log; Anything write to the log between functions `Enter-GitHubActionsLogGroup` and `Exit-GitHubActionsLogGroup` are inside an expandable group in the log.
.PARAMETER Title
Title of the log group.
.OUTPUTS
Void
#>
function Enter-GitHubActionsLogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enter-githubactionsloggroup#Enter-GitHubActionsLogGroup')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header', 'Message')][string]$Title
	)
	return Write-GitHubActionsCommand -Command 'group' -Message $Title
}
Set-Alias -Name 'Enter-GHActionsGroup' -Value 'Enter-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enter-GHActionsLogGroup' -Value 'Enter-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Enter-GitHubActionsGroup' -Value 'Enter-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Exit Log Group
.DESCRIPTION
End an expandable group in the log.
.OUTPUTS
Void
#>
function Exit-GitHubActionsLogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exit-githubactionsloggroup#Exit-GitHubActionsLogGroup')]
	[OutputType([void])]
	param ()
	return Write-GitHubActionsCommand -Command 'endgroup'
}
Set-Alias -Name 'Exit-GHActionsGroup' -Value 'Exit-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Exit-GHActionsLogGroup' -Value 'Exit-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Exit-GitHubActionsGroup' -Value 'Exit-GitHubActionsLogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get input.
.PARAMETER Name
Name of the input.
.PARAMETER Require
Whether the input is require; If required and not present, will throw an error.
.PARAMETER NamePrefix
Name of the inputs start with.
.PARAMETER NameSuffix
Name of the inputs end with.
.PARAMETER All
Get all of the inputs.
.PARAMETER Trim
Trim the input's value.
.OUTPUTS
Hashtable | String
#>
function Get-GitHubActionsInput {
	[CmdletBinding(DefaultParameterSetName = 'one', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsinput#Get-GitHubActionsInput')]
	[OutputType([string], ParameterSetName = 'one')]
	[OutputType([hashtable], ParameterSetName = ('all', 'prefix', 'suffix'))]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'one', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions input name pattern!')][Alias('Key')][string]$Name,
		[Parameter(ParameterSetName = 'one')][Alias('Force', 'Forced', 'Required')][switch]$Require,
		[Parameter(Mandatory = $true, ParameterSetName = 'prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not match the require GitHub Actions input name prefix pattern!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][string]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions input name suffix pattern!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][string]$NameSuffix,
		[Parameter(ParameterSetName = 'all')][switch]$All,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				Get-ChildItem -Path 'Env:\INPUT_*' | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace '^INPUT_', ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
			'one' {
				$InputValue = Get-ChildItem -LiteralPath "Env:\INPUT_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $InputValue) {
					if ($Require) {
						return Write-GitHubActionsFail -Message "Input ``$Name`` is not defined!"
					}
					return $null
				}
				if ($Trim) {
					return $InputValue.Value.Trim()
				}
				return $InputValue.Value
			}
			'prefix' {
				Get-ChildItem -Path "Env:\INPUT_$($NamePrefix.ToUpper())*" | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace "^INPUT_$([regex]::Escape($NamePrefix))", ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
			'suffix' {
				Get-ChildItem -Path "Env:\INPUT_*$($NameSuffix.ToUpper())" | ForEach-Object -Process {
					[string]$InputKey = $_.Name -replace "^INPUT_|$([regex]::Escape($NameSuffix))$", ''
					if ($Trim) {
						$OutputObject[$InputKey] = $_.Value.Trim()
					} else {
						$OutputObject[$InputKey] = $_.Value
					}
				}
				break
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -in @('all', 'prefix', 'suffix')) {
			return $OutputObject
		}
	}
}
Set-Alias -Name 'Get-GHActionsInput' -Value 'Get-GitHubActionsInput' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Debug Status
.DESCRIPTION
Get debug status.
.OUTPUTS
Boolean
#>
function Get-GitHubActionsIsDebug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsisdebug#Get-GitHubActionsIsDebug')]
	[OutputType([bool])]
	param ()
	if ($env:RUNNER_DEBUG -eq 'true') {
		return $true
	}
	return $false
}
Set-Alias -Name 'Get-GHActionsIsDebug' -Value 'Get-GitHubActionsIsDebug' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get OIDC Token
.DESCRIPTION
Interact with the GitHub OIDC provider and get a JWT ID token which would help to get access token from third party cloud providers.
.PARAMETER Audience
Audience.
.OUTPUTS
String
#>
function Get-GitHubActionsOidcToken {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsoidctoken#Get-GitHubActionsOidcToken')]
	[OutputType([string])]
	param (
		[Parameter(Position = 0)][AllowNull()][string]$Audience
	)
	[string]$OidcTokenRequestToken = $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN
	[string]$OidcTokenRequestURL = $env:ACTIONS_ID_TOKEN_REQUEST_URL
	if (
		$null -eq $OidcTokenRequestToken -or
		$OidcTokenRequestToken.Length -eq 0
	) {
		return Write-Error -Message 'Unable to get GitHub Actions OIDC token request token!' -Category 'ResourceUnavailable'
	}
	Add-GitHubActionsSecretMask -Value $OidcTokenRequestToken
	if (
		$null -eq $OidcTokenRequestURL -or
		$OidcTokenRequestURL.Length -eq 0
	) {
		return Write-Error -Message 'Unable to get GitHub Actions OIDC token request URL!' -Category 'ResourceUnavailable'
	}
	if ($null -ne $Audience -and $Audience.Length -gt 0) {
		Add-GitHubActionsSecretMask -Value $Audience
		[string]$AudienceEncode = [System.Web.HttpUtility]::UrlEncode($Audience)
		Add-GitHubActionsSecretMask -Value $AudienceEncode
		$OidcTokenRequestURL += "&audience=$AudienceEncode"
	}
	try {
		[pscustomobject]$Response = Invoke-WebRequest -Uri $OidcTokenRequestURL -UseBasicParsing -UserAgent 'actions/oidc-client' -Headers @{
			Authorization = "Bearer $OidcTokenRequestToken"
		} -MaximumRedirection 1 -MaximumRetryCount 10 -RetryIntervalSec 10 -Method 'Get'
		[ValidateNotNullOrEmpty()][string]$OidcToken = (ConvertFrom-Json -InputObject $Response.Content -Depth 100).value
		Add-GitHubActionsSecretMask -Value $OidcToken
		return $OidcToken
	} catch {
		return Write-Error @_
	}
}
Set-Alias -Name 'Get-GHActionsOidcToken' -Value 'Get-GitHubActionsOidcToken' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get State
.DESCRIPTION
Get state.
.PARAMETER Name
Name of the state.
.PARAMETER NamePrefix
Name of the states start with.
.PARAMETER NameSuffix
Name of the states end with.
.PARAMETER All
Get all of the states.
.PARAMETER Trim
Trim the state's value.
.OUTPUTS
Hashtable | String
#>
function Get-GitHubActionsState {
	[CmdletBinding(DefaultParameterSetName = 'one', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstate#Get-GitHubActionsState')]
	[OutputType([string], ParameterSetName = 'one')]
	[OutputType([hashtable], ParameterSetName = ('all', 'prefix', 'suffix'))]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'one', Position = 0, ValueFromPipeline = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions state name pattern!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'prefix')][ValidatePattern('^[\da-z][\da-z_-]*$', ErrorMessage = '`{0}` is not match the require GitHub Actions state name prefix pattern!')][Alias('KeyPrefix', 'KeyStartWith', 'NameStartWith', 'Prefix', 'PrefixKey', 'PrefixName', 'StartWith', 'StartWithKey', 'StartWithName')][string]$NamePrefix,
		[Parameter(Mandatory = $true, ParameterSetName = 'suffix')][ValidatePattern('^[\da-z_-]*[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions state name suffix pattern!')][Alias('EndWith', 'EndWithKey', 'EndWithName', 'KeyEndWith', 'KeySuffix', 'NameEndWith', 'Suffix', 'SuffixKey', 'SuffixName')][string]$NameSuffix,
		[Parameter(ParameterSetName = 'all')][switch]$All,
		[switch]$Trim
	)
	begin {
		[hashtable]$OutputObject = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'all' {
				Get-ChildItem -Path 'Env:\STATE_*' | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace '^STATE_', ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
			'one' {
				$StateValue = Get-ChildItem -LiteralPath "Env:\STATE_$($Name.ToUpper())" -ErrorAction 'SilentlyContinue'
				if ($null -eq $StateValue) {
					return $null
				}
				if ($Trim) {
					return $StateValue.Value.Trim()
				}
				return $StateValue.Value
			}
			'prefix' {
				Get-ChildItem -Path "Env:\STATE_$($NamePrefix.ToUpper())*" | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace "^STATE_$([regex]::Escape($NamePrefix))", ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
			'suffix' {
				Get-ChildItem -Path "Env:\STATE_*$($NameSuffix.ToUpper())" | ForEach-Object -Process {
					[string]$StateKey = $_.Name -replace "^STATE_|$([regex]::Escape($NameSuffix))$", ''
					if ($Trim) {
						$OutputObject[$StateKey] = $_.Value.Trim()
					} else {
						$OutputObject[$StateKey] = $_.Value
					}
				}
				break
			}
		}
	}
	end {
		if ($PSCmdlet.ParameterSetName -in @('all', 'prefix', 'suffix')) {
			return $OutputObject
		}
	}
}
Set-Alias -Name 'Get-GHActionsState' -Value 'Get-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Restore-GHActionsState' -Value 'Get-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Restore-GitHubActionsState' -Value 'Get-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Step Summary
.DESCRIPTION
Get step summary that added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.PARAMETER Raw
Ignore newline characters and return the entire contents of a file in one string with the newlines preserved. By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Sizes
Get step summary sizes instead of the content.
.OUTPUTS
String | String[] | UInt
#>
function Get-GitHubActionsStepSummary {
	[CmdletBinding(DefaultParameterSetName = 'content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstepsummary#Get-GitHubActionsStepSummary')]
	[OutputType(([string], [string[]]), ParameterSetName = 'content')]
	[OutputType([uint], ParameterSetName = 'sizes')]
	param (
		[Parameter(ParameterSetName = 'content')][switch]$Raw,
		[Parameter(Mandatory = $true, ParameterSetName = 'sizes')][Alias('Size')][switch]$Sizes
	)
	switch ($PSCmdlet.ParameterSetName) {
		'content' {
			return Get-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Raw:$Raw -Encoding 'UTF8NoBOM'
		}
		'sizes' {
			return (Get-ChildItem -LiteralPath $env:GITHUB_STEP_SUMMARY).Length
		}
	}
}
Set-Alias -Name 'Get-GHActionsStepSummary' -Value 'Get-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Webhook Event Payload
.DESCRIPTION
Get the complete webhook event payload.
.PARAMETER AsHashtable
Output as hashtable instead of object.
.PARAMETER Depth
Set the maximum depth the JSON input is allowed to have.
.PARAMETER NoEnumerate
Specify that output is not enumerated; Setting this parameter causes arrays to be sent as a single object instead of sending every element separately, this guarantees that JSON can be round-tripped via Cmdlet `ConvertTo-Json`.
.OUTPUTS
Hashtable | PSCustomObject
#>
function Get-GitHubActionsWebhookEventPayload {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionswebhookeventpayload#Get-GitHubActionsWebhookEventPayload')]
	[OutputType(([hashtable], [pscustomobject]))]
	param (
		[Alias('ToHashtable')][switch]$AsHashtable,
		[int]$Depth = 1024,
		[switch]$NoEnumerate
	)
	return (Get-Content -LiteralPath $env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' | ConvertFrom-Json -AsHashtable:$AsHashtable -Depth $Depth -NoEnumerate:$NoEnumerate)
}
Set-Alias -Name 'Get-GHActionsEvent' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GHActionsPayload' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GHActionsWebhookEvent' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GHActionsWebhookEventPayload' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GHActionsWebhookPayload' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GitHubActionsEvent' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GitHubActionsPayload' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GitHubActionsWebhookEvent' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-GitHubActionsWebhookPayload' -Value 'Get-GitHubActionsWebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Remove Problem Matcher
.DESCRIPTION
Remove problem matcher that previously added from function `Add-GitHubActionsProblemMatcher`.
.PARAMETER Owner
Owner of the problem matcher that previously added from function `Add-GitHubActionsProblemMatcher`.
.OUTPUTS
Void
#>
function Remove-GitHubActionsProblemMatcher {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsproblemmatcher#Remove-GitHubActionsProblemMatcher')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Owner` must be in single line string!')][Alias('Identifies', 'Identify', 'Identifier', 'Identifiers', 'Key', 'Keys', 'Name', 'Names', 'Owners')][string[]]$Owner
	)
	begin {}
	process {
		$Owner | ForEach-Object -Process {
			return Write-GitHubActionsCommand -Command 'remove-matcher' -Property @{ 'owner' = $_ }
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Remove-GHActionsProblemMatcher' -Value 'Remove-GitHubActionsProblemMatcher' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Remove Step Summary
.DESCRIPTION
Remove step summary that added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.OUTPUTS
Void
#>
function Remove-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsstepsummary#Remove-GitHubActionsStepSummary')]
	[OutputType([void])]
	param ()
	return Remove-Item -LiteralPath $env:GITHUB_STEP_SUMMARY -Confirm:$false
}
Set-Alias -Name 'Remove-GHActionsStepSummary' -Value 'Remove-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set Output
.DESCRIPTION
Set output.
.PARAMETER InputObject
Outputs.
.PARAMETER Name
Name of the output.
.PARAMETER Value
Value of the output.
.OUTPUTS
Void
#>
function Set-GitHubActionsOutput {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsoutput#Set-GitHubActionsOutput')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions output name pattern!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][string]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if ($_.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category InvalidType
					} elseif ($_.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($_.Name)`` is not match the require GitHub Actions output name pattern!" -Category SyntaxError
					} elseif ($_.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category InvalidType
					} else {
						Write-GitHubActionsCommand -Command 'set-output' -Message $_.Value -Property @{ 'name' = $_.Name }
					}
				}
				break
			}
			'single' {
				Write-GitHubActionsCommand -Command 'set-output' -Message $Value -Property @{ 'name' = $Name }
				break
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Set-GHActionsOutput' -Value 'Set-GitHubActionsOutput' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set State
.DESCRIPTION
Set state.
.PARAMETER InputObject
States.
.PARAMETER Name
Name of the state.
.PARAMETER Value
Value of the state.
.OUTPUTS
Void
#>
function Set-GitHubActionsState {
	[CmdletBinding(DefaultParameterSetName = 'multiple', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstate#Set-GitHubActionsState')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'multiple', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][hashtable]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 0, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not match the require GitHub Actions state name pattern!')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = 'single', Position = 1, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][string]$Value
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'multiple' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if ($_.Name.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Name` must be type of string!' -Category InvalidType
					} elseif ($_.Name -notmatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$') {
						Write-Error -Message "``$($_.Name)`` is not match the require GitHub Actions state name pattern!" -Category SyntaxError
					} elseif ($_.Value.GetType().Name -ne 'string') {
						Write-Error -Message 'Parameter `Value` must be type of string!' -Category InvalidType
					} else {
						Write-GitHubActionsCommand -Command 'save-state' -Message $_.Value -Property @{ 'name' = $_.Name }
					}
				}
				break
			}
			'single' {
				Write-GitHubActionsCommand -Command 'save-state' -Message $Value -Property @{ 'name' = $Name }
				break
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Save-GHActionsState' -Value 'Set-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Save-GitHubActionsState' -Value 'Set-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Set-GHActionsState' -Value 'Set-GitHubActionsState' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Set Step Summary
.DESCRIPTION
Set some GitHub flavored Markdown for step so that it will be displayed on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures. When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
Void
#>
function Set-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstepsummary#Set-GitHubActionsStepSummary')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][string[]]$Value,
		[switch]$NoNewLine
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		if ($Value.Count -gt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Set-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Set-GHActionsStepSummary' -Value 'Set-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test Environment
.DESCRIPTION
Test the current process is executing inside the GitHub Actions environment.
.PARAMETER Require
Whether the requirement is require; If required and not fulfill, will throw an error.
#>
function Test-GitHubActionsEnvironment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_test-githubactionsenvironment#Test-GitHubActionsEnvironment')]
	[OutputType([bool])]
	param (
		[Alias('Force', 'Forced', 'Required')][switch]$Require
	)
	if (
		$env:CI -ne 'true' -or
		$null -eq $env:GITHUB_ACTION_REPOSITORY -or
		$null -eq $env:GITHUB_ACTION -or
		$null -eq $env:GITHUB_ACTIONS -or
		$null -eq $env:GITHUB_ACTOR -or
		$null -eq $env:GITHUB_API_URL -or
		$null -eq $env:GITHUB_ENV -or
		$null -eq $env:GITHUB_EVENT_NAME -or
		$null -eq $env:GITHUB_EVENT_PATH -or
		$null -eq $env:GITHUB_GRAPHQL_URL -or
		$null -eq $env:GITHUB_JOB -or
		$null -eq $env:GITHUB_PATH -or
		$null -eq $env:GITHUB_REF_NAME -or
		$null -eq $env:GITHUB_REF_PROTECTED -or
		$null -eq $env:GITHUB_REF_TYPE -or
		$null -eq $env:GITHUB_REPOSITORY_OWNER -or
		$null -eq $env:GITHUB_REPOSITORY -or
		$null -eq $env:GITHUB_RETENTION_DAYS -or
		$null -eq $env:GITHUB_RUN_ATTEMPT -or
		$null -eq $env:GITHUB_RUN_ID -or
		$null -eq $env:GITHUB_RUN_NUMBER -or
		$null -eq $env:GITHUB_SERVER_URL -or
		$null -eq $env:GITHUB_SHA -or
		$null -eq $env:GITHUB_STEP_SUMMARY -or
		$null -eq $env:GITHUB_WORKFLOW -or
		$null -eq $env:GITHUB_WORKSPACE -or
		$null -eq $env:RUNNER_ARCH -or
		$null -eq $env:RUNNER_NAME -or
		$null -eq $env:RUNNER_OS -or
		$null -eq $env:RUNNER_TEMP -or
		$null -eq $env:RUNNER_TOOL_CACHE
	) {
		if ($Require) {
			return Write-GitHubActionsFail -Message 'This process require to execute inside the GitHub Actions environment!'
		}
		return $false
	}
	return $true
}
Set-Alias -Name 'Test-GHActionsEnvironment' -Value 'Test-GitHubActionsEnvironment' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Annotation
.DESCRIPTION
Prints an annotation message to the log.
.PARAMETER Type
Annotation type.
.PARAMETER Message
Message that need to log at annotation.
.PARAMETER File
Issue file path.
.PARAMETER Line
Issue file line start.
.PARAMETER Column
Issue file column start.
.PARAMETER EndLine
Issue file line end.
.PARAMETER EndColumn
Issue file column end.
.PARAMETER Title
Issue title.
.OUTPUTS
Void
#>
function Write-GitHubActionsAnnotation {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsannotation#Write-GitHubActionsAnnotation')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][GitHubActionsAnnotationType]$Type,
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][string]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][uint]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][uint]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][uint]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][uint]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][string]$Title
	)
	begin {}
	process {
		[string]$TypeRaw = ''
		switch ($Type) {
			{$_ -match '^e(?:rror)?$'} {
				$TypeRaw = 'error'
				break
			}
			{$_ -match '^n(?:ot(?:ic)?e)?$'} {
				$TypeRaw = 'notice'
				break
			}
			{$_ -match '^w(?:arn(?:ing)?)?$'} {
				$TypeRaw = 'warning'
				break
			}
		}
		[hashtable]$Property = @{}
		if ($File.Length -gt 0) {
			$Property.'file' = $File
		}
		if ($Line -gt 0) {
			$Property.'line' = $Line
		}
		if ($Column -gt 0) {
			$Property.'col' = $Column
		}
		if ($EndLine -gt 0) {
			$Property.'endLine' = $EndLine
		}
		if ($EndColumn -gt 0) {
			$Property.'endColumn' = $EndColumn
		}
		if ($Title.Length -gt 0) {
			$Property.'title' = $Title
		}
		Write-GitHubActionsCommand -Command $TypeRaw -Message $Message -Property $Property
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsAnnotation' -Value 'Write-GitHubActionsAnnotation' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Debug
.DESCRIPTION
Prints a debug message to the log.
.PARAMETER Message
Message that need to log at debug level.
.OUTPUTS
Void
#>
function Write-GitHubActionsDebug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsdebug#Write-GitHubActionsDebug')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Content')][string]$Message
	)
	begin {}
	process {
		Write-GitHubActionsCommand -Command 'debug' -Message $Message
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsDebug' -Value 'Write-GitHubActionsDebug' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Error
.DESCRIPTION
Prints an error message to the log.
.PARAMETER Message
Message that need to log at error level.
.PARAMETER File
Issue file path.
.PARAMETER Line
Issue file line start.
.PARAMETER Col
Issue file column start.
.PARAMETER EndLine
Issue file line end.
.PARAMETER EndColumn
Issue file column end.
.PARAMETER Title
Issue title.
.OUTPUTS
Void
#>
function Write-GitHubActionsError {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionserror#Write-GitHubActionsError')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][string]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][uint]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][uint]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][uint]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][uint]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][string]$Title
	)
	begin {}
	process {
		Write-GitHubActionsAnnotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsError' -Value 'Write-GitHubActionsError' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Fail
.DESCRIPTION
Prints an error message to the log and end the process.
.PARAMETER Message
Message that need to log at error level.
.PARAMETER File
Issue file path.
.PARAMETER Line
Issue file line start.
.PARAMETER Col
Issue file column start.
.PARAMETER EndLine
Issue file line end.
.PARAMETER EndColumn
Issue file column end.
.PARAMETER Title
Issue title.
.OUTPUTS
Void
#>
function Write-GitHubActionsFail {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsfail#Write-GitHubActionsFail')]
	[OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][Alias('Content')][string]$Message,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][string]$File,
		[Alias('LineStart', 'StartLine')][uint]$Line,
		[Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][uint]$Column,
		[Alias('LineEnd')][uint]$EndLine,
		[Alias('ColEnd', 'ColumnEnd', 'EndCol')][uint]$EndColumn,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][string]$Title
	)
	Write-GitHubActionsAnnotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	exit 1
}
Set-Alias -Name 'Write-GHActionsFail' -Value 'Write-GitHubActionsFail' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Notice
.DESCRIPTION
Prints a notice message to the log.
.PARAMETER Message
Message that need to log at notice level.
.PARAMETER File
Issue file path.
.PARAMETER Line
Issue file line start.
.PARAMETER Col
Issue file column start.
.PARAMETER EndLine
Issue file line end.
.PARAMETER EndColumn
Issue file column end.
.PARAMETER Title
Issue title.
.OUTPUTS
Void
#>
function Write-GitHubActionsNotice {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsnotice#Write-GitHubActionsNotice')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][string]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][uint]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][uint]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][uint]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][uint]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][string]$Title
	)
	begin {}
	process {
		Write-GitHubActionsAnnotation -Type 'Notice' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsNote' -Value 'Write-GitHubActionsNotice' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Write-GHActionsNotice' -Value 'Write-GitHubActionsNotice' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Write-GitHubActionsNote' -Value 'Write-GitHubActionsNotice' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Warning
.DESCRIPTION
Prints a warning message to the log.
.PARAMETER Message
Message that need to log at warning level.
.PARAMETER File
Issue file path.
.PARAMETER Line
Issue file line start.
.PARAMETER Col
Issue file column start.
.PARAMETER EndLine
Issue file line end.
.PARAMETER EndColumn
Issue file column end.
.PARAMETER Title
Issue title.
.OUTPUTS
Void
#>
function Write-GitHubActionsWarning {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionswarning#Write-GitHubActionsWarning')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][string]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][string]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][uint]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][uint]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][uint]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][uint]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][string]$Title
	)
	begin {}
	process {
		Write-GitHubActionsAnnotation -Type 'Warning' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-GHActionsWarn' -Value 'Write-GitHubActionsWarning' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Write-GHActionsWarning' -Value 'Write-GitHubActionsWarning' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Write-GitHubActionsWarn' -Value 'Write-GitHubActionsWarning' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Add-GitHubActionsEnvironmentVariable',
	'Add-GitHubActionsPATH',
	'Add-GitHubActionsProblemMatcher',
	'Add-GitHubActionsSecretMask',
	'Add-GitHubActionsStepSummary',
	'Disable-GitHubActionsEchoingCommands',
	'Disable-GitHubActionsProcessingCommands',
	'Enable-GitHubActionsEchoingCommands',
	'Enable-GitHubActionsProcessingCommands',
	'Enter-GitHubActionsLogGroup',
	'Exit-GitHubActionsLogGroup',
	'Get-GitHubActionsInput',
	'Get-GitHubActionsIsDebug',
	'Get-GitHubActionsOidcToken,'
	'Get-GitHubActionsState',
	'Get-GitHubActionsStepSummary',
	'Get-GitHubActionsWebhookEventPayload',
	'Remove-GitHubActionsProblemMatcher',
	'Remove-GitHubActionsStepSummary',
	'Set-GitHubActionsOutput',
	'Set-GitHubActionsState',
	'Set-GitHubActionsStepSummary',
	'Test-GitHubActionsEnvironment',
	'Write-GitHubActionsAnnotation',
	'Write-GitHubActionsCommand',
	'Write-GitHubActionsDebug',
	'Write-GitHubActionsError',
	'Write-GitHubActionsFail',
	'Write-GitHubActionsNotice',
	'Write-GitHubActionsWarning'
) -Alias @(
	'Add-GHActionsEnv',
	'Add-GHActionsEnvironment',
	'Add-GHActionsEnvironmentVariable',
	'Add-GHActionsMask',
	'Add-GHActionsPATH',
	'Add-GHActionsProblemMatcher',
	'Add-GHActionsSecret',
	'Add-GHActionsStepSummary',
	'Add-GitHubActionsEnv',
	'Add-GitHubActionsEnvironment',
	'Add-GitHubActionsMask',
	'Add-GitHubActionsSecret',
	'Disable-GHActionsCommandEcho',
	'Disable-GHActionsCommandEchoing',
	'Disable-GHActionsCommandProcess',
	'Disable-GHActionsCommandProcessing',
	'Disable-GHActionsCommandsEcho',
	'Disable-GHActionsCommandsEchoing',
	'Disable-GHActionsCommandsProcess',
	'Disable-GHActionsCommandsProcessing',
	'Disable-GHActionsEchoCommand',
	'Disable-GHActionsEchoCommands',
	'Disable-GHActionsEchoingCommand',
	'Disable-GHActionsEchoingCommands',
	'Disable-GHActionsProcessCommand',
	'Disable-GHActionsProcessCommands',
	'Disable-GHActionsProcessingCommand',
	'Disable-GHActionsProcessingCommands',
	'Disable-GitHubActionsCommandEcho',
	'Disable-GitHubActionsCommandEchoing',
	'Disable-GitHubActionsCommandProcess',
	'Disable-GitHubActionsCommandProcessing',
	'Disable-GitHubActionsCommandsEcho',
	'Disable-GitHubActionsCommandsEchoing',
	'Disable-GitHubActionsCommandsProcess',
	'Disable-GitHubActionsCommandsProcessing',
	'Disable-GitHubActionsEchoCommand',
	'Disable-GitHubActionsEchoCommands',
	'Disable-GitHubActionsEchoingCommand',
	'Disable-GitHubActionsProcessCommand',
	'Disable-GitHubActionsProcessCommands',
	'Disable-GitHubActionsProcessingCommand',
	'Enable-GHActionsCommandEcho',
	'Enable-GHActionsCommandEchoing',
	'Enable-GHActionsCommandProcess',
	'Enable-GHActionsCommandProcessing',
	'Enable-GHActionsCommandsEcho',
	'Enable-GHActionsCommandsEchoing',
	'Enable-GHActionsCommandsProcess',
	'Enable-GHActionsCommandsProcessing',
	'Enable-GHActionsEchoCommand',
	'Enable-GHActionsEchoCommands',
	'Enable-GHActionsEchoingCommand',
	'Enable-GHActionsEchoingCommands',
	'Enable-GHActionsProcessCommand',
	'Enable-GHActionsProcessCommands',
	'Enable-GHActionsProcessingCommand',
	'Enable-GHActionsProcessingCommands',
	'Enable-GitHubActionsCommandEcho',
	'Enable-GitHubActionsCommandEchoing',
	'Enable-GitHubActionsCommandProcess',
	'Enable-GitHubActionsCommandProcessing',
	'Enable-GitHubActionsCommandsEcho',
	'Enable-GitHubActionsCommandsEchoing',
	'Enable-GitHubActionsCommandsProcess',
	'Enable-GitHubActionsCommandsProcessing',
	'Enable-GitHubActionsEchoCommand',
	'Enable-GitHubActionsEchoCommands',
	'Enable-GitHubActionsEchoingCommand',
	'Enable-GitHubActionsProcessCommand',
	'Enable-GitHubActionsProcessCommands',
	'Enable-GitHubActionsProcessingCommand',
	'Enter-GHActionsGroup',
	'Enter-GHActionsLogGroup',
	'Enter-GitHubActionsGroup',
	'Exit-GHActionsGroup',
	'Exit-GHActionsLogGroup',
	'Exit-GitHubActionsGroup',
	'Get-GHActionsEvent',
	'Get-GHActionsInput',
	'Get-GHActionsIsDebug',
	'Get-GHActionsOidcToken',
	'Get-GHActionsPayload',
	'Get-GHActionsState',
	'Get-GHActionsStepSummary',
	'Get-GHActionsWebhookEvent',
	'Get-GHActionsWebhookEventPayload',
	'Get-GHActionsWebhookPayload',
	'Get-GitHubActionsEvent',
	'Get-GitHubActionsPayload',
	'Get-GitHubActionsWebhookEvent',
	'Get-GitHubActionsWebhookPayload',
	'Remove-GHActionsProblemMatcher',
	'Remove-GHActionsStepSummary',
	'Restore-GHActionsState',
	'Restore-GitHubActionsState',
	'Save-GHActionsState',
	'Save-GitHubActionsState',
	'Set-GHActionsOutput',
	'Set-GHActionsState',
	'Set-GHActionsStepSummary',
	'Start-GHActionsCommandEcho',
	'Start-GHActionsCommandEchoing',
	'Start-GHActionsCommandProcess',
	'Start-GHActionsCommandProcessing',
	'Start-GHActionsCommandsEcho',
	'Start-GHActionsCommandsEchoing',
	'Start-GHActionsCommandsProcess',
	'Start-GHActionsCommandsProcessing',
	'Start-GHActionsEchoCommand',
	'Start-GHActionsEchoCommands',
	'Start-GHActionsEchoingCommand',
	'Start-GHActionsEchoingCommands',
	'Start-GHActionsProcessCommand',
	'Start-GHActionsProcessCommands',
	'Start-GHActionsProcessingCommand',
	'Start-GHActionsProcessingCommands',
	'Start-GitHubActionsCommandEcho',
	'Start-GitHubActionsCommandEchoing',
	'Start-GitHubActionsCommandProcess',
	'Start-GitHubActionsCommandProcessing',
	'Start-GitHubActionsCommandsEcho',
	'Start-GitHubActionsCommandsEchoing',
	'Start-GitHubActionsCommandsProcess',
	'Start-GitHubActionsCommandsProcessing',
	'Start-GitHubActionsEchoCommand',
	'Start-GitHubActionsEchoCommands',
	'Start-GitHubActionsEchoingCommand',
	'Start-GitHubActionsEchoingCommands',
	'Start-GitHubActionsProcessCommand',
	'Start-GitHubActionsProcessCommands',
	'Start-GitHubActionsProcessingCommand',
	'Start-GitHubActionsProcessingCommands',
	'Stop-GHActionsCommandEcho',
	'Stop-GHActionsCommandEchoing',
	'Stop-GHActionsCommandProcess',
	'Stop-GHActionsCommandProcessing',
	'Stop-GHActionsCommandsEcho',
	'Stop-GHActionsCommandsEchoing',
	'Stop-GHActionsCommandsProcess',
	'Stop-GHActionsCommandsProcessing',
	'Stop-GHActionsEchoCommand',
	'Stop-GHActionsEchoCommands',
	'Stop-GHActionsEchoingCommand',
	'Stop-GHActionsEchoingCommands',
	'Stop-GHActionsProcessCommand',
	'Stop-GHActionsProcessCommands',
	'Stop-GHActionsProcessingCommand',
	'Stop-GHActionsProcessingCommands',
	'Stop-GitHubActionsCommandEcho',
	'Stop-GitHubActionsCommandEchoing',
	'Stop-GitHubActionsCommandProcess',
	'Stop-GitHubActionsCommandProcessing',
	'Stop-GitHubActionsCommandsEcho',
	'Stop-GitHubActionsCommandsEchoing',
	'Stop-GitHubActionsCommandsProcess',
	'Stop-GitHubActionsCommandsProcessing',
	'Stop-GitHubActionsEchoCommand',
	'Stop-GitHubActionsEchoCommands',
	'Stop-GitHubActionsEchoingCommand',
	'Stop-GitHubActionsEchoingCommands',
	'Stop-GitHubActionsProcessCommand',
	'Stop-GitHubActionsProcessCommands',
	'Stop-GitHubActionsProcessingCommand',
	'Stop-GitHubActionsProcessingCommands',
	'Test-GHActionsEnvironment',
	'Write-GHActionsAnnotation',
	'Write-GHActionsCommand',
	'Write-GHActionsDebug',
	'Write-GHActionsError',
	'Write-GHActionsFail',
	'Write-GHActionsNote',
	'Write-GHActionsNotice',
	'Write-GHActionsWarn',
	'Write-GHActionsWarning',
	'Write-GitHubActionsNote',
	'Write-GitHubActionsWarn'
)
