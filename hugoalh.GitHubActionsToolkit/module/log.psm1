#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-base.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
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
GitHub Actions - Enter Log Group
.DESCRIPTION
Create an expandable group in the log; Anything write to the log between functions `Enter-GitHubActionsLogGroup` and `Exit-GitHubActionsLogGroup` are inside an expandable group in the log.
.PARAMETER Title
Title of the log group.
.OUTPUTS
Void
#>
function Enter-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enter-githubactionsloggroup#Enter-GitHubActionsLogGroup')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header', 'Message')][String]$Title
	)
	return Write-GitHubActionsCommand -Command 'group' -Value $Title
}
Set-Alias -Name 'Enter-Group' -Value 'Enter-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Exit Log Group
.DESCRIPTION
End an expandable group in the log.
.OUTPUTS
Void
#>
function Exit-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exit-githubactionsloggroup#Exit-GitHubActionsLogGroup')]
	[OutputType([Void])]
	param ()
	return Write-GitHubActionsCommand -Command 'endgroup'
}
Set-Alias -Name 'Exit-Group' -Value 'Exit-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Annotation
.DESCRIPTION
Print an annotation message to the log.
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
function Write-Annotation {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsannotation#Write-GitHubActionsAnnotation')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][GitHubActionsAnnotationType]$Type,
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	begin {}
	process {
		[String]$TypeRaw = ''
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
		[Hashtable]$Property = @{}
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
		Write-GitHubActionsCommand -Command $TypeRaw -Value $Message -Parameter $Property
	}
	end {
		return
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Debug
.DESCRIPTION
Print a debug message to the log.
.PARAMETER Message
Message that need to log at debug level.
.OUTPUTS
Void
#>
function Write-Debug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsdebug#Write-GitHubActionsDebug')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][Alias('Content')][String]$Message
	)
	begin {}
	process {
		Write-GitHubActionsCommand -Command 'debug' -Value $Message
	}
	end {
		return
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Error
.DESCRIPTION
Print an error message to the log.
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
function Write-Error {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionserror#Write-GitHubActionsError')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	begin {}
	process {
		Write-Annotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Fail
.DESCRIPTION
Print an error message to the log and end the process.
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
function Write-Fail {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsfail#Write-GitHubActionsFail')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0)][Alias('Content')][String]$Message,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Alias('LineEnd')][UInt32]$EndLine,
		[Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Write-Annotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	exit 1
}
<#
.SYNOPSIS
GitHub Actions - Write Notice
.DESCRIPTION
Print a notice message to the log.
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
function Write-Notice {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsnotice#Write-GitHubActionsNotice')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	begin {}
	process {
		Write-Annotation -Type 'Notice' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-Note' -Value 'Write-Notice' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Warning
.DESCRIPTION
Print a warning message to the log.
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
function Write-Warning {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionswarning#Write-GitHubActionsWarning')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $true)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	begin {}
	process {
		Write-Annotation -Type 'Warning' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
	end {
		return
	}
}
Set-Alias -Name 'Write-Warn' -Value 'Write-Warning' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Enter-LogGroup',
	'Exit-LogGroup',
	'Write-Annotation',
	'Write-Debug',
	'Write-Error',
	'Write-Fail',
	'Write-Notice',
	'Write-Warning'
) -Alias @(
	'Enter-Group',
	'Exit-Group',
	'Write-Note',
	'Write-Warn'
)
