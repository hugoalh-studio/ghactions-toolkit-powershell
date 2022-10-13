#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base.psm1',
		'command-control.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
Enum GitHubActionsAnnotationType {
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
Create an expandable group in the log; Anything write to the log between functions `Enter-GitHubActionsLogGroup` and `Exit-GitHubActionsLogGroup` are inside this expandable group in the log.
.PARAMETER Title
Title of the log group.
.OUTPUTS
[Void]
#>
Function Enter-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_enter-githubactionsloggroup#Enter-GitHubActionsLogGroup')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header', 'Summary')][String]$Title
	)
	Write-GitHubActionsCommand -Command 'group' -Value $Title
}
Set-Alias -Name 'Enter-Group' -Value 'Enter-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Exit Log Group
.DESCRIPTION
End an expandable group in the log.
.OUTPUTS
[Void]
#>
Function Exit-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exit-githubactionsloggroup#Exit-GitHubActionsLogGroup')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsCommand -Command 'endgroup'
}
Set-Alias -Name 'Exit-Group' -Value 'Exit-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Annotation
.DESCRIPTION
Print an annotation message to the log.
.PARAMETER Type
Type of the annotation.
.PARAMETER Message
Message of the annotation.
.PARAMETER File
Path of the issue file of the annotation.
.PARAMETER Line
Line start of the issue file of the annotation.
.PARAMETER Column
Column start of the issue file of the annotation.
.PARAMETER EndLine
Line end of the issue file of the annotation.
.PARAMETER EndColumn
Column end of the issue file of the annotation.
.PARAMETER Title
Title of the annotation.
.OUTPUTS
[Void]
#>
Function Write-Annotation {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsannotation#Write-GitHubActionsAnnotation')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][GitHubActionsAnnotationType]$Type,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Process {
		Switch ($Type.GetHashCode()) {
			0 {
				[String]$TypeRaw = 'notice'
				Break
			}
			1 {
				[String]$TypeRaw = 'warning'
				Break
			}
			2 {
				[String]$TypeRaw = 'error'
				Break
			}
		}
		[Hashtable]$Property = @{}
		If ($File.Length -igt 0) {
			$Property['file'] = $File
		}
		If ($Line -igt 0) {
			$Property['line'] = $Line
		}
		If ($Column -igt 0) {
			$Property['col'] = $Column
		}
		If ($EndLine -igt 0) {
			$Property['endLine'] = $EndLine
		}
		If ($EndColumn -igt 0) {
			$Property['endColumn'] = $EndColumn
		}
		If ($Title.Length -igt 0) {
			$Property['title'] = $Title
		}
		Write-GitHubActionsCommand -Command $TypeRaw -Parameter $Property -Value $Message
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
[Void]
#>
Function Write-Debug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsdebug#Write-GitHubActionsDebug')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Content')][String]$Message
	)
	Process {
		Write-GitHubActionsCommand -Command 'debug' -Value $Message
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
Path of the issue file of the annotation.
.PARAMETER Line
Line start of the issue file of the annotation.
.PARAMETER Column
Column start of the issue file of the annotation.
.PARAMETER EndLine
Line end of the issue file of the annotation.
.PARAMETER EndColumn
Column end of the issue file of the annotation.
.PARAMETER Title
Title of the error message.
.OUTPUTS
[Void]
#>
Function Write-Error {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionserror#Write-GitHubActionsError')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Process {
		Write-Annotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
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
Path of the issue file of the annotation.
.PARAMETER Line
Line start of the issue file of the annotation.
.PARAMETER Column
Column start of the issue file of the annotation.
.PARAMETER EndLine
Line end of the issue file of the annotation.
.PARAMETER EndColumn
Column end of the issue file of the annotation.
.PARAMETER Title
Title of the error message.
.OUTPUTS
[Void]
#>
Function Write-Fail {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsfail#Write-GitHubActionsFail')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Content')][String]$Message,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Alias('LineEnd')][UInt32]$EndLine,
		[Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Write-Annotation -Type 'Error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	Exit 1
}
<#
.SYNOPSIS
GitHub Actions - Write Notice
.DESCRIPTION
Print a notice message to the log.
.PARAMETER Message
Message that need to log at notice level.
.PARAMETER File
Path of the issue file of the annotation.
.PARAMETER Line
Line start of the issue file of the annotation.
.PARAMETER Column
Column start of the issue file of the annotation.
.PARAMETER EndLine
Line end of the issue file of the annotation.
.PARAMETER EndColumn
Column end of the issue file of the annotation.
.PARAMETER Title
Title of the notice message.
.OUTPUTS
[Void]
#>
Function Write-Notice {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsnotice#Write-GitHubActionsNotice')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Process {
		Write-Annotation -Type 'Notice' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
	}
}
Set-Alias -Name 'Write-Note' -Value 'Write-Notice' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write Raw
.DESCRIPTION
Print anything to the log without accidentally execute any commands.
.PARAMETER InputObject
Item that need to log.
.PARAMETER GroupTitle
Title of the log group; This creates an expandable group in the log, and anything are inside this expandable group in the log.
.OUTPUTS
[Void]
#>
Function Write-Raw {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionsraw#Write-GitHubActionsRaw')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content', 'Input', 'Message', 'Object')]$InputObject,
		[Alias('GroupHeader', 'Header', 'Title')][String]$GroupTitle
	)
	Begin {
		If ($GroupTitle.Length -igt 0) {
			Enter-LogGroup -Title $GroupTitle
		}
		[String]$EndToken = Disable-GitHubActionsProcessingCommands
	}
	Process {
		Write-Host -Object $InputObject
	}
	End {
		Enable-GitHubActionsProcessingCommands -EndToken $EndToken
		If ($GroupTitle.Length -igt 0) {
			Exit-LogGroup
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Warning
.DESCRIPTION
Print a warning message to the log.
.PARAMETER Message
Message that need to log at warning level.
.PARAMETER File
Path of the issue file of the annotation.
.PARAMETER Line
Line start of the issue file of the annotation.
.PARAMETER Column
Column start of the issue file of the annotation.
.PARAMETER EndLine
Line end of the issue file of the annotation.
.PARAMETER EndColumn
Column end of the issue file of the annotation.
.PARAMETER Title
Title of the warning message.
.OUTPUTS
[Void]
#>
Function Write-Warning {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_write-githubactionswarning#Write-GitHubActionsWarning')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `File` must be in single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.*$', ErrorMessage = 'Parameter `Title` must be in single line string!')][Alias('Header')][String]$Title
	)
	Process {
		Write-Annotation -Type 'Warning' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title
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
	'Write-Raw',
	'Write-Warning'
) -Alias @(
	'Enter-Group',
	'Exit-Group',
	'Write-Note',
	'Write-Warn'
)
