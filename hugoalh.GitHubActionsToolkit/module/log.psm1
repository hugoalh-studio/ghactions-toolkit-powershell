#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-stdout.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
[UInt64]$AnnotationMessageLengthMaximum = 4096
<#
.SYNOPSIS
GitHub Actions - Enter Log Group
.DESCRIPTION
Create a foldable group in the log; Anything write to the log are inside this foldable group in the log.
.PARAMETER Title
Title of the foldable group.
.OUTPUTS
[Void]
#>
Function Enter-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_entergithubactionsloggroup')]
	[OutputType([Void])]
	Param (
		[Parameter(Position = 0)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header', 'Label', 'Summary')][String]$Title
	)
	Write-GitHubActionsStdOutCommand -StdOutCommand 'group' -Value $Title
}
Set-Alias -Name 'Enter-Group' -Value 'Enter-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Exit Log Group
.DESCRIPTION
End an foldable group in the log.
.OUTPUTS
[Void]
#>
Function Exit-LogGroup {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_exitgithubactionsloggroup')]
	[OutputType([Void])]
	Param ()
	Write-GitHubActionsStdOutCommand -StdOutCommand 'endgroup'
}
Set-Alias -Name 'Exit-Group' -Value 'Exit-LogGroup' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Internal - Write Annotation
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
.PARAMETER Summary
Summary of the message when it is too large to display.
.OUTPUTS
[Void]
#>
Function Write-Annotation {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsannotation')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidateSet('error', 'notice', 'warning')][String]$Type,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header')][String]$Title,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Summary
	)
	Process {
		[Hashtable]$Parameter = @{}
		If ($File.Length -gt 0) {
			$Parameter.('file') = $File
		}
		If ($Line -gt 0) {
			$Parameter.('line') = $Line
		}
		If ($Column -gt 0) {
			$Parameter.('col') = $Column
		}
		If ($EndLine -gt 0) {
			$Parameter.('endLine') = $EndLine
		}
		If ($EndColumn -gt 0) {
			$Parameter.('endColumn') = $EndColumn
		}
		If ($Title.Length -gt 0) {
			$Parameter.('title') = $Title
		}
		If ($Message.Length -gt $AnnotationMessageLengthMaximum -and $Summary.Length -gt 0) {
			Write-Host -Object $Message
			Write-GitHubActionsStdOutCommand -StdOutCommand $Type -Parameter $Parameter -Value $Summary
		}
		Else {
			Write-GitHubActionsStdOutCommand -StdOutCommand $Type -Parameter $Parameter -Value $Message
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Write Debug
.DESCRIPTION
Print a debug message to the log.
.PARAMETER Message
Message that need to log at debug level.
.PARAMETER SkipEmptyMessage
Whether to skip empty message.
.PARAMETER PassThru
Return the message. By default, this function does not generate any output.
.OUTPUTS
[String] When use the parameter `PassThru`, this function return the message.
[Void] By default, this function does not generate any output.
#>
Function Write-Debug {
	[CmdletBinding(DefaultParameterSetName = 'Void', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsdebug')]
	[OutputType([String], ParameterSetName = 'PassThru')]
	[OutputType([Void], ParameterSetName = 'Void')]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][Alias('Content')][String]$Message,
		[Alias('SkipEmpty')][Switch]$SkipEmptyMessage,
		[Parameter(Mandatory = $True, ParameterSetName = 'PassThru')][Switch]$PassThru
	)
	Process {
		If (
			!$SkipEmptyMessage.IsPresent -or
			($SkipEmptyMessage.IsPresent -and $Message.Length -gt 0)
		) {
			Write-GitHubActionsStdOutCommand -StdOutCommand 'debug' -Value $Message
		}
		If ($PSCmdlet.ParameterSetName -ieq 'PassThru') {
			$Message |
				Write-Output
		}
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
.PARAMETER Summary
Summary of the message when it is too large to display.
.OUTPUTS
[Void]
#>
Function Write-Error {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionserror')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header')][String]$Title,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Summary
	)
	Process {
		Write-Annotation -Type 'error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title -Summary $Summary
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
.PARAMETER Summary
Summary of the message when it is too large to display.
.PARAMETER Finally
A script block to invoke before end the process, use to free any resources that are no longer needed.
.PARAMETER ExitCode
Exit code of the process.
.OUTPUTS
[Void]
#>
Function Write-Fail {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsfail')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Content')][String]$Message,
		[AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Path')][String]$File,
		[Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Alias('LineEnd')][UInt32]$EndLine,
		[Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header')][String]$Title,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Summary,
		[ScriptBlock]$Finally = {},
		[Int16]$ExitCode = 1
	)
	Write-Annotation -Type 'error' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title -Summary $Summary
	Invoke-Command -ScriptBlock $Finally -ErrorAction 'Continue'
	Exit $ExitCode
	Exit 1# Fallback exit for safety.
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
.PARAMETER Summary
Summary of the message when it is too large to display.
.OUTPUTS
[Void]
#>
Function Write-Notice {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsnotice')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header')][String]$Title,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Summary
	)
	Process {
		Write-Annotation -Type 'notice' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title -Summary $Summary
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
.PARAMETER Summary
Summary of the message when it is too large to display.
.OUTPUTS
[Void]
#>
Function Write-Warning {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionswarning')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][Alias('Content')][String]$Message,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Path')][String]$File,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineStart', 'StartLine')][UInt32]$Line,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Col', 'ColStart', 'ColumnStart', 'StartCol', 'StartColumn')][UInt32]$Column,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('LineEnd')][UInt32]$EndLine,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('ColEnd', 'ColumnEnd', 'EndCol')][UInt32]$EndColumn,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][ValidatePattern('^.*$', ErrorMessage = 'Value is not a single line string!')][Alias('Header')][String]$Title,
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Summary
	)
	Process {
		Write-Annotation -Type 'warning' -Message $Message -File $File -Line $Line -Column $Column -EndLine $EndLine -EndColumn $EndColumn -Title $Title -Summary $Summary
	}
}
Set-Alias -Name 'Write-Warn' -Value 'Write-Warning' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Enter-LogGroup',
	'Exit-LogGroup',
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
