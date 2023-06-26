#Requires -PSEdition Core -Version 7.2
Class GitHubActionsStepSummary {# Unstable, not in use yet.
	Static [Hashtable[]]EscapeMarkdownCharactersList() {
		Return @(
			@{ Pattern = '\\'; To = '\\' },
			@{ Pattern = '`'; To = '\`' },
			@{ Pattern = '\*'; To = '\*' },
			@{ Pattern = '_'; To = '\_' },
			@{ Pattern = '\{'; To = '\{' },
			@{ Pattern = '\}'; To = '\}' },
			@{ Pattern = '\['; To = '\[' },
			@{ Pattern = '\]'; To = '\]' },
			@{ Pattern = '<'; To = '\<' },
			@{ Pattern = '>'; To = '\>' },
			@{ Pattern = '\('; To = '\(' },
			@{ Pattern = '\)'; To = '\)' },
			@{ Pattern = '#'; To = '\#' },
			@{ Pattern = '\+'; To = '\+' },
			@{ Pattern = '-'; To = '\-' },
			@{ Pattern = '\.'; To = '\.' },
			@{ Pattern = '!'; To = '\!' },
			@{ Pattern = '\|'; To = '\|' },
			@{ Pattern = '\r?\n'; To = '<br />' }
		)
	}
	Static [String]EscapeMarkdown($InputObject) {
		If ($Null -ieq $InputObject) {
			Return ''
		}
		If ($InputObject.GetType().BaseType -ieq [System.Array]) {
			[String]$Result = "{$(Join-String -InputObject $InputObject -Separator ', ')}"
		}
		ElseIf (
			$InputObject.GetType() -ieq [System.Collections.ArrayList] -or
			$InputObject.GetType().ToString().StartsWith("System.Collections.Generic.List")
		) {
			[String]$Result = "{$(Join-String -InputObject $InputObject.ToArray() -Separator ', ')}"
		}
		Else {
			[String]$Result = ($InputObject)?.ToString() ?? ''
		}
		ForEach ($ReplaceGroup In [GitHubActionsStepSummary]::EscapeMarkdownCharactersList()) {
			$Result = $Result -ireplace $ReplaceGroup.Pattern, $ReplaceGroup.To
		}
		Return $Result
	}
}
<#
.SYNOPSIS
GitHub Actions - Add Step Summary (Raw)
.DESCRIPTION
Add some GitHub flavored Markdown for the step to display on the summary page of a run.

Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finished, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Contents of the step summary.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content')][Object[]]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$NoNewLine
	)
	Process {
		If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
			Write-Error -Message 'Unable to write the GitHub Actions step summary: Environment path `GITHUB_STEP_SUMMARY` is not defined or not contain a valid file path!' -Category 'ResourceUnavailable'
			Return
		}
		If ($Value.Count -gt 0) {
			Add-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Value $Value -Confirm:$False -NoNewline:($NoNewLine.IsPresent) -Encoding 'UTF8NoBOM'
		}
	}
}
Set-Alias -Name 'Add-StepSummaryRaw' -Value 'Add-StepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Header
.DESCRIPTION
Add header for the step to display on the summary page of a run.
.PARAMETER Level
Level of the header.
.PARAMETER Header
Title of the header.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryHeader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummaryheader')]
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
Add image for the step to display on the summary page of a run.

IMPORTANT: Not support reference image!
.PARAMETER Uri
URI of the image.
.PARAMETER Title
Title of the image.
.PARAMETER AlternativeText
Alternative text of the image.
.PARAMETER Width
Width of the image, by pixels (px).
.PARAMETER Height
Height of the image, by pixels (px).
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryImage {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummaryimage')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Url')][String]$Uri,
		[String]$Title,
		[Alias('Alt', 'AltText')][String]$AlternativeText,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Width = -1,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Height = -1,
		[Switch]$NoNewLine
	)
	If (
		$Width -gt -1 -or
		$Height -gt -1
	) {
		[String]$ResultHtml = "<img src=`"$([Uri]::EscapeUriString($Uri))`""
		If ($Title.Length -gt 0) {
			$ResultHtml += " title=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		If ($AlternativeText.Length -gt 0) {
			$ResultHtml += " alt=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))`""
		}
		If ($Width -gt -1) {
			$ResultHtml += " width=`"$Width`""
		}
		If ($Height -gt -1) {
			$ResultHtml += " height=`"$Height`""
		}
		$ResultHtml += ' />'
		Add-StepSummary -Value $ResultHtml -NoNewLine:($NoNewLine.IsPresent)
	}
	Else {
		[String]$ResultMarkdown = "![$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))]($([Uri]::EscapeUriString($Uri))"
		If ($Title.Length -gt 0) {
			$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		$ResultMarkdown += ')'
		Add-StepSummary -Value $ResultMarkdown -NoNewLine:($NoNewLine.IsPresent)
	}
}
Set-Alias -Name 'Add-StepSummaryPicture' -Value 'Add-StepSummaryImage' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Link
.DESCRIPTION
Add link for the step to display on the summary page of a run.

IMPORTANT: Not support reference link!
.PARAMETER Text
Text of the link.
.PARAMETER Uri
URI of the link.
.PARAMETER Title
Title of the link.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummaryLink {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummarylink')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Text,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Url')][String]$Uri,
		[String]$Title,
		[Switch]$NoNewLine
	)
	[String]$ResultMarkdown = "[$([System.Web.HttpUtility]::HtmlAttributeEncode($Text))]($([Uri]::EscapeUriString($Uri))"
	If ($Title.Length -gt 0) {
		$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
	}
	$ResultMarkdown += ')'
	Add-StepSummary -Value $ResultMarkdown -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-StepSummaryHyperlink' -Value 'Add-StepSummaryLink' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Subscript Text
.DESCRIPTION
Add subscript text for the step to display on the summary page of a run.
.PARAMETER Text
A string that need to subscript text.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummarySubscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummarysubscripttext')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-StepSummary -Value "<sub>$([System.Web.HttpUtility]::HtmlEncode($Text))</sub>" -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-StepSummarySubscript' -Value 'Add-StepSummarySubscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Superscript Text
.DESCRIPTION
Add superscript text for the step to display on the summary page of a run.
.PARAMETER Text
A string that need to superscript text.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-StepSummarySuperscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsstepsummarysuperscripttext')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-StepSummary -Value "<sup>$([System.Web.HttpUtility]::HtmlEncode($Text))</sup>" -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-StepSummarySuperscript' -Value 'Add-StepSummarySuperscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Step Summary
.DESCRIPTION
Get the step summary.
.PARAMETER Raw
Whether to ignore newline characters and output the entire contents of a file in one string with the newlines preserved; By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Sizes
Whether to get the sizes of the step summary instead of the contents of the step summary.
.OUTPUTS
[String] Step summary with the entire contents in one string.
[String[]] Step summary with the entire contents in multiple strings separated by newline characters.
[UInt32] Sizes of the step summary.
#>
Function Get-StepSummary {
	[CmdletBinding(DefaultParameterSetName = 'Content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsstepsummary')]
	[OutputType(([String], [String[]]), ParameterSetName = 'Content')]
	[OutputType([UInt32], ParameterSetName = 'Sizes')]
	Param (
		[Parameter(ParameterSetName = 'Content')][Switch]$Raw,
		[Parameter(Mandatory = $True, ParameterSetName = 'Sizes')][Alias('Size')][Switch]$Sizes
	)
	If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
		Write-Error -Message 'Unable to get the GitHub Actions step summary: Environment path `GITHUB_STEP_SUMMARY` is not defined or not contain a valid file path!' -Category 'ResourceUnavailable'
		Return
	}
	Switch ($PSCmdlet.ParameterSetName) {
		'Content' {
			(Get-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Raw:($Raw.IsPresent) -Encoding 'UTF8NoBOM' -ErrorAction 'Continue') ?? '' |
				Write-Output
		}
		'Sizes' {
			(
				Get-Item -LiteralPath $Env:GITHUB_STEP_SUMMARY -ErrorAction 'Continue' |
					Select-Object -ExpandProperty 'Length' -ErrorAction 'Continue'
			) ?? 0 |
				Write-Output
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Remove Step Summary
.DESCRIPTION
Remove the step summary.
.OUTPUTS
[Void]
#>
Function Remove-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_removegithubactionsstepsummary')]
	[OutputType([Void])]
	Param ()
	If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
		Write-Error -Message 'Unable to remove the GitHub Actions step summary: Environment path `GITHUB_STEP_SUMMARY` is not defined or not contain a valid file path!' -Category 'ResourceUnavailable'
		Return
	}
	Remove-Item -LiteralPath $Env:GITHUB_STEP_SUMMARY -Confirm:$False -ErrorAction 'Continue'
}
<#
.SYNOPSIS
GitHub Actions - Set Step Summary
.DESCRIPTION
Set some GitHub flavored Markdown for the step to display on the summary page of a run.

Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finished, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Contents of the step summary.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Set-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_setgithubactionsstepsummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[String[]]$Result = @()
	}
	Process {
		If ($Value.Count -gt 0) {
			$Result += $Value |
				Join-String -Separator "`n"
		}
	}
	End {
		If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
			Write-Error -Message 'Unable to write the GitHub Actions step summary: Environment path `GITHUB_STEP_SUMMARY` is not defined or not contain a valid file path!' -Category 'ResourceUnavailable'
			Return
		}
		If ($Result.Count -gt 0) {
			Set-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Value (
				$Result |
					Join-String -Separator "`n"
			) -Confirm:$False -NoNewline:($NoNewLine.IsPresent) -Encoding 'UTF8NoBOM'
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
