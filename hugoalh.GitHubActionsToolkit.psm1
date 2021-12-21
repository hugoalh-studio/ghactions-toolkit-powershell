<#
.SYNOPSIS
GitHub Actions - Internal - Escape Command Properties Characters
.DESCRIPTION
An internal function to escape command properties characters that could cause issues.
.PARAMETER InputObject
#>
function Format-GHActionsEscapeCommandPropertiesCharacters {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyString()][string]$InputObject
	)
	begin {}
	process {
		return $InputObject -replace '%', '%25' -replace "`n", '%0A' -replace "`r", '%0D' -replace ',', '%2C' -replace ':', '%3A'
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Internal - Escape New Line Characters
.DESCRIPTION
An internal function to escape new line characters that could cause issues.
.PARAMETER InputObject
#>
function Format-GHActionsEscapeDataCharacters {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyString()][string]$InputObject
	)
	begin {}
	process {
		return $InputObject -replace '%', '%25' -replace "`n", '%0A' -replace "`r", '%0D'
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
.PARAMETER Properties
Workflow command properties.
#>
function Write-GHActionsCommand {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)][string]$Command,
		[Parameter(Mandatory = $true, Position = 1)][AllowEmptyString()][string]$Message,
		[Parameter(Position = 2)][hashtable]$Properties = @{}
	)
	$Result = "::$Command"
	if ($Properties.Count -gt 0) {
		$Result += " $($($Properties.GetEnumerator() | ForEach-Object -Process {
			"$($_.Name)=$(Format-GHActionsEscapeCommandPropertiesCharacters -InputObject $_.Value)"
		}) -join ',')"
	}
	$Result += "::$(Format-GHActionsEscapeDataCharacters -InputObject $Message)"
	Write-Host -Object $Result
}
<#
.SYNOPSIS
GitHub Actions - Add Environment Variable
.DESCRIPTION
Add an environment variable to the system environment variables and automatically makes it available to all subsequent actions in the current job; The currently running action cannot access the updated environment variables.
.PARAMETER Name
Environment variable name.
.PARAMETER Value
Environment variable value.
#>
function Add-GHActionsEnvironmentVariable {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$')][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][ValidatePattern('^.+$')][string]$Value
	)
	Add-Content -Encoding utf8NoBOM -Path $env:GITHUB_ENV -Value "$Name=$Value"
}
<#
.SYNOPSIS
GitHub Actions - Add Environment Variables
.DESCRIPTION
Add environment variables to the system environment variables and automatically makes these available to all subsequent actions in the current job; The currently running action cannot access the updated environment variables.
.PARAMETER InputObject
Environment variables.
#>
function Add-GHActionsEnvironmentVariables {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]$InputObject
	)
	begin {
		$Result = @{}
	}
	process {
		switch ($InputObject.GetType().FullName) {
			'System.Collections.Hashtable' {
				$InputObject.GetEnumerator() | ForEach-Object -Process {
					if (($_.Name -match '^.+$') -and ($_.Value -match '^.+$')) {
						$Result[$_.Name] = $_.Value
					} else {
						Write-Error -Message "Input `"$($_.Name)=$($_.Value)`" is not match the require environment variable pattern." -Category SyntaxError
					}
				}
			}
			'System.Management.Automation.PSCustomObject' {
				$InputObject.PSObject.Properties | ForEach-Object -Process {
					if (($_.Name -match '^.+$') -and ($_.Value -match '^.+$')) {
						$Result[$_.Name] = $_.Value
					} else {
						Write-Error -Message "Input `"$($_.Name)=$($_.Value)`" is not match the require environment variable pattern." -Category SyntaxError
					}
				}
			}
			'System.String' {
				if (($InputObject -match '^.+=.+$') -and (($InputObject -split '=').Count -eq 2)) {
					$InputObjectSplit = $InputObject.Split('=')
					$Result[$InputObjectSplit[0]] = $InputObjectSplit[1]
				} else {
					Write-Error -Message "Input `"$InputObject`" is not match the require environment variable pattern." -Category SyntaxError
				}
			}
			default {
				Write-Error -Message 'Parameter `InputObject` must be custom object, hashtable, or string!' -Category InvalidType
			}
		}
	}
	end {
		Add-Content -Encoding utf8NoBOM -Path $env:GITHUB_ENV -Value "$($($Result.GetEnumerator() | ForEach-Object -Process {
			"$($_.Name)=$($_.Value)"
		}) -join "`n")"
	}
}
<#
.SYNOPSIS
GitHub Actions - Add PATHs
.DESCRIPTION
Add directories to the system `PATH` variable and automatically makes these available to all subsequent actions in the current job; The currently running action cannot access the updated path variable.
.PARAMETER Path
System path.
.EXAMPLE
Add-GHActionsPATH -Path "$($env:HOME)/.local/bin"
#>
function Add-GHActionsPATHs {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Path
	)
	begin {
		$Result = @()
	}
	process {
		$Result += $Path
	}
	end {
		Add-Content -Encoding utf8NoBOM -Path $env:GITHUB_PATH -Value "$($Result -join "`n")"
	}
}
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret will get masked from the log.
.PARAMETER Value
The secret.
#>
function Add-GHActionsSecretMask {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Value
	)
	begin {}
	process {
		Write-GHActionsCommand -Command 'add-mask' -Message $Value
	}
	end {}
}
<#
.SYNOPSIS
GitHub Actions - Get Debug Status
.DESCRIPTION
Get debug status.
#>
function Get-GHActionsIsDebug {
	[CmdletBinding()]
	param ()
	if ($env:RUNNER_DEBUG -eq 'true') {
		return $true
	}
	return $false
}
<#
.SYNOPSIS
GitHub Actions - Get Input
.DESCRIPTION
Get an input.
.PARAMETER Name
Name of the input.
.PARAMETER Required
Whether the input is required. If required and not present, will throw an error.
.PARAMETER Trim
Trim the input's value.
#>
function Get-GHActionsInput {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Name,
		[switch]$Required,
		[switch]$Trim
	)
	begin {}
	process {
		$Result = Get-ChildItem -Path "Env:\INPUT_$($Name.ToUpper() -replace ' ','_')" -ErrorAction SilentlyContinue
		$Value = $null
		if ($Result -eq $null) {
			if ($Required -eq $true) {
				throw "Input ``$Name`` is not defined!"
			}
			return $Result
		}
		$Value = $Result.Value
		if ($Trim -eq $true) {
			return $Value.Trim()
		}
		return $Value
	}
	end {}
}
<#
.SYNOPSIS
Get a state.
.DESCRIPTION
Get a state.
.PARAMETER Name
Name of the state.
.PARAMETER Trim
Trim the state's value.
#>
function Get-GHActionsState {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidatePattern('^.+$')][string]$Name,
		[switch]$Trim
	)
	begin {}
	process {
		$Result = Get-ChildItem -Path "Env:\STATE_$($Name.ToUpper() -replace ' ','_')" -ErrorAction SilentlyContinue
		$Value = $null
		if ($Result -eq $null) {
			return $Result
		}
		$Value = $Result.Value
		if ($Trim -eq $true) {
			return $Value.Trim()
		}
		return $Value
	}
	end {}
}
<#
.SYNOPSIS
Set an output.
.PARAMETER Name
Name of the output.
.PARAMETER Value
Value of the output.
#>
function Set-GHActionsOutput {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][string]$Value
	)
	Write-GHActionsCommand -Command 'set-output' -Message $Value -Properties @{'name' = $Name }
}
function Save-GHActionsState {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][string]$Name,
		[Parameter(Mandatory = $true, Position = 1)][string]$Value
	)
	Write-GHActionsCommand -Command 'save-state' -Message $Value -Properties @{'name' = $Name }
}
function Disable-GHActionsCommandEcho {
	[CmdletBinding()]
	param()
	Write-GHActionsCommand -Command 'echo' -Message 'off'
}
function Disable-GHActionsProcessingCommand {
	[CmdletBinding()]
	param()
	$EndToken = (New-Guid).Guid
	Write-GHActionsCommand -Command 'stop-commands' -Message $EndToken
	return $EndToken
}
function Enable-GHActionsCommandEcho {
	[CmdletBinding()]
	param()
	Write-GHActionsCommand -Command 'echo' -Message 'on'
}
function Enable-GHActionsProcessingCommand {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][string]$EndToken
	)
	Write-GHActionsCommand -Command $EndToken -Message ''
}
<#
.SYNOPSIS
Create an expandable group in the log.
.DESCRIPTION
Anything write to the log between `Enter-GHActionsLogGroup` and `Exit-GHActionsLogGroup` commands are inside an expandable group in the log.
.PARAMETER Title
Title of the log group.
#>
function Enter-GHActionsLogGroup {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][string]$Title
	)
	Send-GHActionsCommand -Command 'group' -Message $Title
}
<#
.SYNOPSIS
End an output group.
#>
function Exit-GHActionsLogGroup {
	[CmdletBinding()]
	param ()
	Send-GHActionsCommand -Command 'endgroup' -Message ''
}
<#
.SYNOPSIS
Execute script block in a log group.
.PARAMETER Title
Title of the log group.
.PARAMETER ScriptBlock
Script block to execute in the log group.
#>
function Invoke-GHActionsScriptGroup {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)][string]$Title,
		[Parameter(Mandatory = $true, Position = 1)][scriptblock]$ScriptBlock
	)
	Enter-GHActionsLogGroup -Title $Title
	try {
		return $ScriptBlock.Invoke()
	}
 finally {
		Exit-GHActionsLogGroup
	}
}
function Write-GHActionsDebug {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message
	)
	begin {}
	process {
		Write-GHActionsCommand -Command 'debug' -Message $Message
	}
	end {}
}
function Write-GHActionsError {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message,
		[Parameter()][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][uint]$Col,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][string]$Title
	)
	begin {}
	process {
		$Properties = @{}
		if ($File.Length -gt 0) {
			$Properties.'file' = $File
		}
		if ($Line -gt 0) {
			$Properties.'line' = $Line
		}
		if ($Col -gt 0) {
			$Properties.'col' = $Col
		}
		if ($EndLine -gt 0) {
			$Properties.'endLine' = $EndLine
		}
		if ($EndColumn -gt 0) {
			$Properties.'endColumn' = $EndColumn
		}
		if ($Title.Length -gt 0) {
			$Properties.'title' = $Title
		}
		Write-GHActionsCommand -Command 'error' -Message $Message -Properties $Properties
	}
	end {}
}
function Write-GHActionsFail {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)][string]$Message = ''
	)
	Write-GHActionsCommand -Command 'error' -Message $Message
	exit 1
}
function Write-GHActionsNotice {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message,
		[Parameter()][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][uint]$Col,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][string]$Title
	)
	begin {}
	process {
		$Properties = @{}
		if ($File.Length -gt 0) {
			$Properties.'file' = $File
		}
		if ($Line -gt 0) {
			$Properties.'line' = $Line
		}
		if ($Col -gt 0) {
			$Properties.'col' = $Col
		}
		if ($EndLine -gt 0) {
			$Properties.'endLine' = $EndLine
		}
		if ($EndColumn -gt 0) {
			$Properties.'endColumn' = $EndColumn
		}
		if ($Title.Length -gt 0) {
			$Properties.'title' = $Title
		}
		Write-GHActionsCommand -Command 'notice' -Message $Message -Properties $Properties
	}
	end {}
}
function Write-GHActionsWarning {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message,
		[Parameter()][string]$File,
		[Parameter()][uint]$Line,
		[Parameter()][uint]$Col,
		[Parameter()][uint]$EndLine,
		[Parameter()][uint]$EndColumn,
		[Parameter()][string]$Title
	)
	begin {}
	process {
		$Properties = @{}
		if ($File.Length -gt 0) {
			$Properties.'file' = $File
		}
		if ($Line -gt 0) {
			$Properties.'line' = $Line
		}
		if ($Col -gt 0) {
			$Properties.'col' = $Col
		}
		if ($EndLine -gt 0) {
			$Properties.'endLine' = $EndLine
		}
		if ($EndColumn -gt 0) {
			$Properties.'endColumn' = $EndColumn
		}
		if ($Title.Length -gt 0) {
			$Properties.'title' = $Title
		}
		Write-GHActionsCommand -Command 'warning' -Message $Message -Properties $Properties
	}
	end {}
}
Export-ModuleMember -Function Add-GHActionsEnvironmentVariable, Add-GHActionsEnvironmentVariables, Add-GHActionsPATHs, Add-GHActionsSecretMask, Disable-GHActionsCommandEcho, Disable-GHActionsProcessingCommand, Enable-GHActionsCommandEcho, Enable-GHActionsProcessingCommand, Enter-GHActionsLogGroup, Exit-GHActionsLogGroup, Get-GHActionsInput, Get-GHActionsIsDebug, Get-GHActionsState, Invoke-GHActionsScriptGroup, Set-GHActionsOutput, Write-GHActionsDebug, Write-GHActionsError, Write-GHActionsFail, Write-GHActionsNotice, Write-GHActionsWarning
