#Requires -PSEdition Core
#Requires -Version 7.2
enum GHActionsAnnotationType {
	Notice = 0
	N = 0
	Note = 0
	Warning = 1
	W = 1
	Warn = 1
	Error = 2
	E = 2
}
<#
.SYNOPSIS
GitHub Actions - Internal - Format Command
.DESCRIPTION
An internal function to escape command characters that could cause issues.
.PARAMETER InputObject
String that need to escape command characters.
.PARAMETER Property
Also escape command property characters.
.OUTPUTS
String
#>
function Format-GHActionsCommand {
	[CmdletBinding()][OutputType([string])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyString()][Alias('Input', 'Object')][string]$InputObject,
		[switch]$Property
	)
	begin {}
	process {
		[string]$Result = $InputObject -replace '%', '%25' -replace "`n", '%0A' -replace "`r", '%0D'
		if ($Property) {
			$Result = $Result -replace ',', '%2C' -replace ':', '%3A'
		}
		return $Result
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Internal - Test Environment Variable
.DESCRIPTION
An internal function to validate environment variable.
.PARAMETER InputObject
Environment variable that need to validate.
.OUTPUTS
Boolean
#>
function Test-GHActionsEnvironmentVariable {
	[CmdletBinding()][OutputType([bool])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')][string]$InputObject
	)
	begin {}
	process {
		if (($InputObject -match '^[\da-z_]+=.+$') -and (($InputObject -split '=').Count -eq 2)) {
			return $true
		}
		Write-Error -Message "Input `"$InputObject`" is not match the require environment variable pattern!" -Category SyntaxError
		return $false
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Internal - Write Workflow Command
.DESCRIPTION
An internal function to write workflow command.
.PARAMETER Command
Workflow command.
.PARAMETER Message
Message.
.PARAMETER Property
Workflow command property.
.OUTPUTS
Void
#>
function Write-GHActionsCommand {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][string]$Command,
		[Parameter(Mandatory = $true, Position = 1)][AllowEmptyString()][string]$Message,
		[Parameter(Position = 2)][Alias('Properties')][hashtable]$Property = @{}
	)
	[string]$Result = "::$Command"
	if ($Property.Count -gt 0) {
		$Result += " $($($Property.GetEnumerator() | ForEach-Object -Process {
			return "$($_.Name)=$(Format-GHActionsCommand -InputObject $_.Value -Property)"
		}) -join ',')"
	}
	$Result += "::$(Format-GHActionsCommand -InputObject $Message)"
	Write-Host -Object $Result
}
<#
.SYNOPSIS
GitHub Actions - Add Environment Variable
.DESCRIPTION
Add environment variable to the system environment variables and automatically makes it available to all subsequent actions in the current job; The currently running action cannot access the updated environment variables.
.PARAMETER InputObject
Environment variable.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
.OUTPUTS
Void
#>
function Add-GHActionsEnvironmentVariable {
	[CmdletBinding(DefaultParameterSetName = '1')][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = '1', Position = 0, ValueFromPipeline = $true)][Alias('Input', 'Object')]$InputObject,
		[Parameter(Mandatory = $true, ParameterSetName = '2', Position = 0)][ValidatePattern('^[\da-z_]+$')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, ParameterSetName = '2', Position = 1)][ValidatePattern('^.+$')][string]$Value
	)
	begin {
		[hashtable]$Result = @{}
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'1' {
				switch ($InputObject.GetType().Name) {
					'Hashtable' {
						$InputObject.GetEnumerator() | ForEach-Object -Process {
							if (Test-GHActionsEnvironmentVariable -InputObject "$($_.Name)=$($_.Value)") {
								$Result[$_.Name] = $_.Value
							}
						}
					}
					'String' {
						if (Test-GHActionsEnvironmentVariable -InputObject $InputObject) {
							[string[]]$InputObjectSplit = $InputObject.Split('=')
							$Result[$InputObjectSplit[0]] = $InputObjectSplit[1]
						}
					}
					default {
						Write-Error -Message 'Parameter `InputObject` must be hashtable or string!' -Category InvalidType
					}
				}
			}
			'2' {
				$Result[$Name] = $Value
			}
		}
	}
	end {
		Add-Content -Path $env:GITHUB_ENV -Value "$($($Result.GetEnumerator() | ForEach-Object -Process {
			return "$($_.Name)=$($_.Value)"
		}) -join "`n")" -Encoding utf8NoBOM
	}
}
Set-Alias -Name 'Add-GHActionsEnv' -Value 'Add-GHActionsEnvironmentVariable' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add PATH
.DESCRIPTION
Add directory to the system `PATH` variable and automatically makes it available to all subsequent actions in the current job; The currently running action cannot access the updated path variable.
.PARAMETER Path
System path.
.OUTPUTS
Void
#>
function Add-GHActionsPATH {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('Paths')][string[]]$Path
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		$Path | ForEach-Object -Process {
			if (Test-Path -Path $_ -IsValid) {
				$Result += $_
			} else {
				Write-Error -Message "Input `"$_`" is not match the require path pattern!" -Category SyntaxError
			}
		}
	}
	end {
		Add-Content -Path $env:GITHUB_PATH -Value "$($Result -join "`n")" -Encoding utf8NoBOM
	}
}
<#
.SYNOPSIS
GitHub Actions - Add Problem Matcher
.DESCRIPTION
Problem matchers are a way to scan the output of actions for a specified regular expression pattern and automatically surface that information prominently in the user interface, both GitHub Annotations and log file decorations are created when a match is detected. For more information, please visit https://github.com/actions/toolkit/blob/main/docs/problem-matchers.md.
.PARAMETER Path
Relative path to the JSON file problem matcher.
.OUTPUTS
Void
#>
function Add-GHActionsProblemMatcher {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][SupportsWildcards()][Alias('File', 'Files', 'Paths', 'PSPath', 'PSPaths')][string[]]$Path
	)
	begin {}
	process {
		Resolve-Path -Path $Path -Relative | ForEach-Object -Process {
			if ((Test-Path -Path $_ -PathType Leaf) -and ((Split-Path -Path $_ -Extension) -eq '.json')) {
				Write-GHActionsCommand -Command 'add-matcher' -Message ($_ -replace '^\.\\', '' -replace '\\', '/')
			} else {
				Write-Error -Message "Path `"$_`" is not exist or match the require path pattern!" -Category SyntaxError
			}
		}
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret will get masked from the log.
.PARAMETER Value
The secret.
.OUTPUTS
Void
#>
function Add-GHActionsSecretMask {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Key', 'Token')][string]$Value
	)
	begin {}
	process {
		Write-GHActionsCommand -Command 'add-mask' -Message $Value
	}
	end {}
}
Set-Alias -Name 'Add-GHActionsMask' -Value 'Add-GHActionsSecretMask' -Option ReadOnly -Scope 'Local'
Set-Alias -Name 'Add-GHActionsSecret' -Value 'Add-GHActionsSecretMask' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Echo Command
.DESCRIPTION
Disable echoing of workflow commands, the workflow run's log will not show the command itself; A workflow command is echoed if there are any errors processing the command; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Disable-GHActionsEchoCommand {
	[CmdletBinding()][OutputType([void])]
	param()
	Write-GHActionsCommand -Command 'echo' -Message 'off'
}
Set-Alias -Name 'Disable-GHActionsCommandEcho' -Value 'Disable-GHActionsEchoCommand' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable Processing Command
.DESCRIPTION
Stop processing any workflow commands to allow log anything without accidentally running workflow commands.
.OUTPUTS
String
#>
function Disable-GHActionsProcessingCommand {
	[CmdletBinding()][OutputType([string])]
	param(
		[Parameter(Position = 0)][ValidatePattern('^.+$')][Alias('Key', 'Token', 'Value')][string]$EndToken = (New-Guid).Guid
	)
	Write-GHActionsCommand -Command 'stop-commands' -Message $EndToken
	return $EndToken
}
Set-Alias -Name 'Disable-GHActionsCommandProcessing' -Value 'Disable-GHActionsProcessingCommand' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Echo Command
.DESCRIPTION
Enable echoing of workflow commands, the workflow run's log will show the command itself; The `add-mask`, `debug`, `warning`, and `error` commands do not support echoing because their outputs are already echoed to the log; Secret `ACTIONS_STEP_DEBUG` will ignore this.
.OUTPUTS
Void
#>
function Enable-GHActionsEchoCommand {
	[CmdletBinding()][OutputType([void])]
	param()
	Write-GHActionsCommand -Command 'echo' -Message 'on'
}
Set-Alias -Name 'Enable-GHActionsCommandEcho' -Value 'Enable-GHActionsEchoCommand' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable Processing Command
.DESCRIPTION
Resume processing any workflow commands to allow running workflow commands.
.PARAMETER EndToken
Token from `Disable-GHActionsProcessingCommand`.
.OUTPUTS
Void
#>
function Enable-GHActionsProcessingCommand {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][Alias('Key', 'Token', 'Value')][string]$EndToken
	)
	Write-GHActionsCommand -Command $EndToken -Message ''
}
Set-Alias -Name 'Enable-GHActionsCommandProcessing' -Value 'Enable-GHActionsProcessingCommand' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enter Log Group
.DESCRIPTION
Create an expandable group in the log; Anything write to the log between `Enter-GHActionsLogGroup` and `Exit-GHActionsLogGroup` commands are inside an expandable group in the log.
.PARAMETER Title
Title of the log group.
.OUTPUTS
Void
#>
function Enter-GHActionsLogGroup {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][Alias('Header', 'Message')][string]$Title
	)
	Write-GHActionsCommand -Command 'group' -Message $Title
}
Set-Alias -Name 'Enter-GHActionsGroup' -Value 'Enter-GHActionsLogGroup' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Exit Log Group
.DESCRIPTION
End an expandable group in the log.
.OUTPUTS
Void
#>
function Exit-GHActionsLogGroup {
	[CmdletBinding()][OutputType([void])]
	param ()
	Write-GHActionsCommand -Command 'endgroup' -Message ''
}
Set-Alias -Name 'Exit-GHActionsGroup' -Value 'Exit-GHActionsLogGroup' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get input.
.PARAMETER Name
Name of the input.
.PARAMETER Require
Whether the input is require. If required and not present, will throw an error.
.PARAMETER Trim
Trim the input's value.
.OUTPUTS
Hashtable | String
#>
function Get-GHActionsInput {
	[CmdletBinding()][OutputType([hashtable], [string])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Key', 'Keys', 'Names')][string[]]$Name,
		[Alias('Required')][switch]$Require,
		[switch]$Trim
	)
	begin {
		[hashtable]$Result = @{}
	}
	process {
		$Name | ForEach-Object -Process {
			$InputValue = Get-ChildItem -Path "Env:\INPUT_$($_.ToUpper() -replace '[ \n\r\s\t]+','_')" -ErrorAction SilentlyContinue
			if ($null -eq $InputValue) {
				if ($Require) {
					throw "Input ``$_`` is not defined!"
				}
				$Result[$_] = $InputValue
			} else {
				if ($Trim) {
					$Result[$_] = $InputValue.Value.Trim()
				} else {
					$Result[$_] = $InputValue.Value
				}
			}
		}
	}
	end {
		if ($Result.Count -eq 1) {
			return $Result.Values[0]
		}
		return $Result
	}
}
<#
.SYNOPSIS
GitHub Actions - Get Debug Status
.DESCRIPTION
Get debug status.
.OUTPUTS
Boolean
#>
function Get-GHActionsIsDebug {
	[CmdletBinding()][OutputType([bool])]
	param ()
	if ($env:RUNNER_DEBUG -eq 'true') {
		return $true
	}
	return $false
}
<#
.SYNOPSIS
GitHub Actions - Get State
.DESCRIPTION
Get state.
.PARAMETER Name
Name of the state.
.PARAMETER Trim
Trim the state's value.
.OUTPUTS
Hashtable | String
#>
function Get-GHActionsState {
	[CmdletBinding()][OutputType([hashtable], [string])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Key', 'Keys', 'Names')][string[]]$Name,
		[switch]$Trim
	)
	begin {
		[hashtable]$Result = @{}
	}
	process {
		$Name | ForEach-Object -Process {
			$StateValue = Get-ChildItem -Path "Env:\STATE_$($_.ToUpper() -replace '[ \n\r\s\t]+','_')" -ErrorAction SilentlyContinue
			if ($null -eq $StateValue) {
				$Result[$_] = $StateValue
			} else {
				if ($Trim) {
					$Result[$_] = $StateValue.Value.Trim()
				} else {
					$Result[$_] = $StateValue.Value
				}
			}
		}
	}
	end {
		if ($Result.Count -eq 1) {
			return $Result.Values[0]
		}
		return $Result
	}
}
Set-Alias -Name 'Restore-GHActionsState' -Value 'Get-GHActionsState' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Webhook Event Payload
.DESCRIPTION
Get the complete webhook event payload.
.PARAMETER AsHashTable
Output as hashtable instead of object.
.OUTPUTS
Hashtable | PSCustomObject
#>
function Get-GHActionsWebhookEventPayload {
	[CmdletBinding()][OutputType([hashtable], [pscustomobject])]
	param (
		[Alias('ToHashTable')][switch]$AsHashTable
	)
	return (Get-Content -Path $env:GITHUB_EVENT_PATH -Raw -Encoding utf8NoBOM | ConvertFrom-Json -AsHashtable:$AsHashTable)
}
Set-Alias -Name 'Get-GHActionsEvent' -Value 'Get-GHActionsWebhookEventPayload' -Option ReadOnly -Scope 'Local'
Set-Alias -Name 'Get-GHActionsPayload' -Value 'Get-GHActionsWebhookEventPayload' -Option ReadOnly -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Remove Problem Matcher
.DESCRIPTION
Remove problem matcher.
.PARAMETER Owner
Owner of the problem matcher.
.OUTPUTS
Void
#>
function Remove-GHActionsProblemMatcher {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Identifies', 'Identify', 'Identifier', 'Identifiers', 'Key', 'Keys', 'Name', 'Names', 'Owners')][string[]]$Owner
	)
	begin {}
	process {
		$Owner | ForEach-Object -Process {
			Write-GHActionsCommand -Command 'remove-matcher' -Message '' -Property @{ 'owner' = $_ }
		}
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Set Output
.DESCRIPTION
Set output.
.PARAMETER Name
Name of the output.
.PARAMETER Value
Value of the output.
.OUTPUTS
Void
#>
function Set-GHActionsOutput {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][string]$Value
	)
	Write-GHActionsCommand -Command 'set-output' -Message $Value -Property @{ 'name' = $Name }
}
<#
.SYNOPSIS
GitHub Actions - Set State
.DESCRIPTION
Set state.
.PARAMETER Name
Name of the state.
.PARAMETER Value
Value of the state.
.OUTPUTS
Void
#>
function Set-GHActionsState {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][Alias('Key')][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][string]$Value
	)
	Write-GHActionsCommand -Command 'save-state' -Message $Value -Property @{ 'name' = $Name }
}
Set-Alias -Name 'Save-GHActionsState' -Value 'Set-GHActionsState' -Option ReadOnly -Scope 'Local'
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
function Write-GHActionsAnnotation {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][GHActionsAnnotationType]$Type,
		[Parameter(Mandatory = $true, Position = 1)][string]$Message,
		[Parameter()][ValidatePattern('^.*$')][Alias('Path')][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][Alias('Col')][uint]$Column,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][ValidatePattern('^.*$')][Alias('Header')][string]$Title
	)
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
	Write-GHActionsCommand -Command $Type.ToString().ToLower() -Message $Message -Property $Property
}
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
function Write-GHActionsDebug {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message
	)
	begin {}
	process {
		Write-GHActionsCommand -Command 'debug' -Message $Message
	}
	end {}
}
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
function Write-GHActionsError {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][string]$Message,
		[Parameter()][ValidatePattern('^.*$')][Alias('Path')][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][Alias('Col')][uint]$Column,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][ValidatePattern('^.*$')][Alias('Header')][string]$Title
	)
	Write-GHActionsAnnotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
}
<#
.SYNOPSIS
GitHub Actions - Write Fail
.DESCRIPTION
Prints an error message to the log and end the process.
.PARAMETER Message
Message that need to log at error level.
.OUTPUTS
Void
#>
function Write-GHActionsFail {
	[CmdletBinding()][OutputType([void])]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message
	)
	Write-GHActionsAnnotation -Type 'Error' -Message $Message
	exit 1
}
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
function Write-GHActionsNotice {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][string]$Message,
		[Parameter()][ValidatePattern('^.*$')][Alias('Path')][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][Alias('Col')][uint]$Column,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][ValidatePattern('^.*$')][Alias('Header')][string]$Title
	)
	Write-GHActionsAnnotation -Type 'Notice' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
}
Set-Alias -Name 'Write-GHActionsNote' -Value 'Write-GHActionsNotice' -Option ReadOnly -Scope 'Local'
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
function Write-GHActionsWarning {
	[CmdletBinding()][OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][string]$Message,
		[Parameter()][ValidatePattern('^.*$')][Alias('Path')][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][Alias('Col')][uint]$Column,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][ValidatePattern('^.*$')][Alias('Header')][string]$Title
	)
	Write-GHActionsAnnotation -Type 'Warning' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
}
Set-Alias -Name 'Write-GHActionsWarn' -Value 'Write-GHActionsWarning' -Option ReadOnly -Scope 'Local'
Export-ModuleMember -Function @(
	'Add-GHActionsEnvironmentVariable',
	'Add-GHActionsPATH',
	'Add-GHActionsProblemMatcher',
	'Add-GHActionsSecretMask',
	'Disable-GHActionsEchoCommand',
	'Disable-GHActionsProcessingCommand',
	'Enable-GHActionsEchoCommand',
	'Enable-GHActionsProcessingCommand',
	'Enter-GHActionsLogGroup',
	'Exit-GHActionsLogGroup',
	'Get-GHActionsInput',
	'Get-GHActionsIsDebug',
	'Get-GHActionsState',
	'Get-GHActionsWebhookEventPayload',
	'Remove-GHActionsProblemMatcher',
	'Set-GHActionsOutput',
	'Set-GHActionsState',
	'Write-GHActionsAnnotation',
	'Write-GHActionsDebug',
	'Write-GHActionsError',
	'Write-GHActionsFail',
	'Write-GHActionsNotice',
	'Write-GHActionsWarning'
) -Alias @(
	'Add-GHActionsEnv',
	'Add-GHActionsMask',
	'Add-GHActionsSecret',
	'Disable-GHActionsCommandEcho',
	'Disable-GHActionsCommandProcessing',
	'Enable-GHActionsCommandEcho',
	'Enable-GHActionsCommandProcessing',
	'Enter-GHActionsGroup',
	'Exit-GHActionsGroup',
	'Get-GHActionsEvent',
	'Get-GHActionsPayload',
	'Restore-GHActionsState',
	'Save-GHActionsState',
	'Write-GHActionsNote',
	'Write-GHActionsWarn'
)
