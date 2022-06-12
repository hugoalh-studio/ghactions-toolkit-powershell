#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'command.psm1') -Scope 'Local'
enum GitHubActionsAnnotationType {
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
	param (
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
	param (
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
		switch ($Type.GetHashCode()) {
			0 {
				$TypeRaw = 'notice'
				break
			}
			1 {
				$TypeRaw = 'warning'
				break
			}
			2 {
				$TypeRaw = 'error'
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
	param (
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
	'Add-GitHubActionsSecretMask',
	'Enter-GitHubActionsLogGroup',
	'Exit-GitHubActionsLogGroup',
	'Write-GitHubActionsAnnotation',
	'Write-GitHubActionsDebug',
	'Write-GitHubActionsError',
	'Write-GitHubActionsFail',
	'Write-GitHubActionsNotice',
	'Write-GitHubActionsWarning'
) -Alias @(
	'Add-GHActionsMask',
	'Add-GHActionsSecret',
	'Add-GitHubActionsMask',
	'Add-GitHubActionsSecret',
	'Enter-GHActionsGroup',
	'Enter-GHActionsLogGroup',
	'Enter-GitHubActionsGroup',
	'Exit-GHActionsGroup',
	'Exit-GHActionsLogGroup',
	'Exit-GitHubActionsGroup',
	'Write-GHActionsAnnotation',
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
