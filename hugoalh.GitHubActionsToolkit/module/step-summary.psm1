#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary (Raw)
.DESCRIPTION
Add some GitHub flavored Markdown for step so that it will display on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummary#Add-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -StepSummary)) {
			Write-Error -Message 'Unable to get GitHub Actions step summary resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
		[String[]]$Result = @()
	}
	Process {
		If ($NoOperation) {
			Return
		}
		If ($Value.Count -igt 0) {
			$Result += ($Value | Join-String -Separator "`n")
		}
	}
	End {
		If ($NoOperation) {
			Return
		}
		If ($Result.Count -igt 0) {
			Add-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Value ($Result | Join-String -Separator "`n") -Confirm:$False -NoNewline:$NoNewLine.IsPresent -Encoding 'UTF8NoBOM'
		}
	}
}
Set-Alias -Name 'Add-StepSummaryRaw' -Value 'Add-StepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Header
.DESCRIPTION
Add header for step so that it will display on the summary page of a run.
.PARAMETER Level
Header level
.PARAMETER Header
Header title.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryHeader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummaryheader#Add-GitHubActionsStepSummaryHeader')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateRange(1, 6)][Byte]$Level,
		[Parameter(Mandatory = $True, Position = 1)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Header` must be in single line string!')][Alias('Title', 'Value')][String]$Header
	)
	Add-StepSummary -Value "$('#' * $Level) $Header"
}
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Image
.DESCRIPTION
Add image for step so that it will display on the summary page of a run.

IMPORTANT: Not support reference image!
.PARAMETER Uri
Image URI.
.PARAMETER Title
Image title.
.PARAMETER AlternativeText
Image alternative text.
.PARAMETER Width
Image width, by pixels (px).
.PARAMETER Height
Image height, by pixels (px).
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryImage {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummaryimage#Add-GitHubActionsStepSummaryImage')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Url')][String]$Uri,
		[String]$Title,
		[Alias('AltText')][String]$AlternativeText,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Width = -1,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Height = -1,
		[Switch]$NoNewLine
	)
	If (
		$Width -igt -1 -or
		$Height -igt -1
	) {
		[String]$ResultHtml = "<img src=`"$([Uri]::EscapeUriString($Uri))`""
		If ($Title.Length -igt 0) {
			$ResultHtml += " title=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		If ($AlternativeText.Length -igt 0) {
			$ResultHtml += " alt=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))`""
		}
		If ($Width -igt -1) {
			$ResultHtml += " width=`"$Width`""
		}
		If ($Height -igt -1) {
			$ResultHtml += " height=`"$Height`""
		}
		$ResultHtml += ' />'
		Add-StepSummary -Value $ResultHtml -NoNewLine:$NoNewLine.IsPresent
	} Else {
		[String]$ResultMarkdown = "![$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))]($([Uri]::EscapeUriString($Uri))"
		If ($Title.Length -igt 0) {
			$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		$ResultMarkdown += ')'
		Add-StepSummary -Value $ResultMarkdown -NoNewLine:$NoNewLine.IsPresent
	}
}
Set-Alias -Name 'Add-StepSummaryPicture' -Value 'Add-StepSummaryImage' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Link
.DESCRIPTION
Add link for step so that it will display on the summary page of a run.

IMPORTANT: Not support reference link!
.PARAMETER Text
Link text.
.PARAMETER Uri
Link URI.
.PARAMETER Title
Link title.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryLink {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummarylink#Add-GitHubActionsStepSummaryLink')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Text,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Url')][String]$Uri,
		[String]$Title,
		[Switch]$NoNewLine
	)
	[String]$ResultMarkdown = "[$([System.Web.HttpUtility]::HtmlAttributeEncode($Text))]($([Uri]::EscapeUriString($Uri))"
	If ($Title.Length -igt 0) {
		$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
	}
	$ResultMarkdown += ')'
	Add-StepSummary -Value $ResultMarkdown -NoNewLine:$NoNewLine.IsPresent
}
Set-Alias -Name 'Add-StepSummaryHyperlink' -Value 'Add-StepSummaryLink' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Subscript Text
.DESCRIPTION
Add subscript text for step so that it will display on the summary page of a run.
.PARAMETER Text
Text that need to subscript.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummarySubscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummarysubscripttext#Add-GitHubActionsStepSummarySubscriptText')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-StepSummary -Value "<sub>$([System.Web.HttpUtility]::HtmlEncode($Text))</sub>" -NoNewLine:$NoNewLine.IsPresent
}
Set-Alias -Name 'Add-StepSummarySubscript' -Value 'Add-StepSummarySubscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Superscript Text
.DESCRIPTION
Add superscript text for step so that it will display on the summary page of a run.
.PARAMETER Text
Text that need to superscript.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummarySuperscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummarysuperscripttext#Add-GitHubActionsStepSummarySuperscriptText')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-StepSummary -Value "<sup>$([System.Web.HttpUtility]::HtmlEncode($Text))</sup>" -NoNewLine:$NoNewLine.IsPresent
}
Set-Alias -Name 'Add-StepSummarySuperscript' -Value 'Add-StepSummarySuperscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Step Summary
.DESCRIPTION
Get step summary that previously added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.PARAMETER Raw
Ignore newline characters and return the entire contents of a file in one string with the newlines preserved; By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Sizes
Get step summary sizes instead of the content.
.OUTPUTS
[String] Step summary with the entire contents in one string.
[String[]] Step summary with separate contents in multiple string by newline characters.
[UInt32] Step summary sizes.
#>
Function Get-StepSummary {
	[CmdletBinding(DefaultParameterSetName = 'Content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstepsummary#Get-GitHubActionsStepSummary')]
	[OutputType(([String], [String[]]), ParameterSetName = 'Content')]
	[OutputType([UInt32], ParameterSetName = 'Sizes')]
	Param (
		[Parameter(ParameterSetName = 'Content')][Switch]$Raw,
		[Parameter(Mandatory = $True, ParameterSetName = 'Sizes')][Alias('Size')][Switch]$Sizes
	)
	If (!(Test-GitHubActionsEnvironment -StepSummary)) {
		Write-Error -Message 'Unable to get GitHub Actions step summary resources!' -Category 'ResourceUnavailable'
		Return
	}
	Switch ($PSCmdlet.ParameterSetName) {
		'Content' {
			Return (Get-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Raw:$Raw.IsPresent -Encoding 'UTF8NoBOM')
		}
		'Sizes' {
			Return (Get-Item -LiteralPath $Env:GITHUB_STEP_SUMMARY).Length
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Remove Step Summary
.DESCRIPTION
Remove step summary that previously added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.OUTPUTS
[Void]
#>
Function Remove-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsstepsummary#Remove-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param ()
	If (!(Test-GitHubActionsEnvironment -StepSummary)) {
		Write-Error -Message 'Unable to get GitHub Actions step summary resources!' -Category 'ResourceUnavailable'
		Return
	}
	Remove-Item -LiteralPath $Env:GITHUB_STEP_SUMMARY -Confirm:$False
}
<#
.SYNOPSIS
GitHub Actions - Set Step Summary
.DESCRIPTION
Set some GitHub flavored Markdown for step so that it will display on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Set-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstepsummary#Set-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyCollection()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[Boolean]$NoOperation = $False# When the requirements are not fulfill, only stop this function but not others.
		If (!(Test-GitHubActionsEnvironment -StepSummary)) {
			Write-Error -Message 'Unable to get GitHub Actions step summary resources!' -Category 'ResourceUnavailable'
			$NoOperation = $True
		}
		[String[]]$Result = @()
	}
	Process {
		If ($NoOperation) {
			Return
		}
		If ($Value.Count -igt 0) {
			$Result += ($Value | Join-String -Separator "`n")
		}
	}
	End {
		If ($NoOperation) {
			Return
		}
		If ($Result.Count -igt 0) {
			Set-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Value ($Result | Join-String -Separator "`n") -Confirm:$False -NoNewline:$NoNewLine.IsPresent -Encoding 'UTF8NoBOM'
		}
	}
}
Export-ModuleMember -Function @(
	'Add-StepSummary',
	'Add-StepSummaryHeader',
	'Add-StepSummaryImage',
	'Add-StepSummaryLink',
	'Add-StepSummarySubscriptText'
	'Add-StepSummarySuperscriptText'
	'Get-StepSummary',
	'Remove-StepSummary',
	'Set-StepSummary'
) -Alias @(
	'Add-StepSummaryHyperlink',
	'Add-StepSummaryPicture',
	'Add-StepSummaryRaw',
	'Add-StepSummarySubscript',
	'Add-StepSummarySuperscript'
)
