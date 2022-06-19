#Requires -PSEdition Core
#Requires -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Add Step Summary (Raw)
.DESCRIPTION
Add some GitHub flavored Markdown for step so that it will display on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures. When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
Void
#>
Function Add-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummary#Add-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyCollection()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[String[]]$Result = @()
	}
	Process {
		If ($Value.Count -igt 0) {
			$Result += $Value -join "`n"
		}
	}
	End {
		If ($Result.Count -igt 0) {
			Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$False -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		Return
	}
}
Set-Alias -Name 'Add-StepSummaryRaw' -Value 'Add-StepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Image
.DESCRIPTION
Add some GitHub flavored Markdown image for step so that it will display on the summary page of a run.
IMPORTANT: No support reference image!
.PARAMETER Uri
Image URI.
.PARAMETER Title
Image title.
.PARAMETER AlternativeText
Image alternative text.
.PARAMETER Width
Image width.
.PARAMETER Height
Image height.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
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
		[String]$ResultHtml = "<img src=`"$Uri`""
		If ($Title.Length -igt 0) {
			$ResultHtml += " title=`"$Title`""
		}
		If ($AlternativeText.Length -igt 0) {
			$ResultHtml += " alt=`"$AlternativeText`""
		}
		If ($Width -igt -1) {
			$ResultHtml += " width=`"$Width`""
		}
		If ($Height -igt -1) {
			$ResultHtml += " height=`"$Height`""
		}
		$ResultHtml += '>'
		Return (Add-StepSummary -Value $ResultHtml -NoNewLine:$NoNewLine)
	}
	[String]$ResultMarkdown = "![$AlternativeText]($Uri"
	If ($Title.Length -igt 0) {
		$ResultMarkdown += " `"$Title`""
	}
	$ResultMarkdown += ')'
	Return (Add-StepSummary -Value $ResultMarkdown -NoNewLine:$NoNewLine)
}
Set-Alias -Name 'Add-StepSummaryPicture' -Value 'Add-StepSummaryImage' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Step Summary Link
.DESCRIPTION
Add some GitHub flavored Markdown link for step so that it will display on the summary page of a run.
IMPORTANT: No support reference link!
.PARAMETER Uri
Image URI.
.PARAMETER Title
Image title.
.PARAMETER AlternativeText
Image alternative text.
.PARAMETER Width
Image width.
.PARAMETER Height
Image height.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
#>
Function Add-StepSummaryLink {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummarylink#Add-GitHubActionsStepSummaryLink')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Text,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Url')][String]$Uri,
		[String]$Title
	)
	[String]$ResultMarkdown = "[$Text]($Uri"
	If ($Title.Length -igt 0) {
		$ResultMarkdown += " `"$Title`""
	}
	$ResultMarkdown += ')'
	Return (Add-StepSummary -Value $ResultMarkdown -NoNewLine:$NoNewLine)
}
Set-Alias -Name 'Add-StepSummaryHyperlink' -Value 'Add-StepSummaryLink' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Step Summary
.DESCRIPTION
Get step summary that previously added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.PARAMETER Raw
Ignore newline characters and return the entire contents of a file in one string with the newlines preserved. By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Sizes
Get step summary sizes instead of the content.
.OUTPUTS
String | String[] | UInt32
#>
Function Get-StepSummary {
	[CmdletBinding(DefaultParameterSetName = 'Content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstepsummary#Get-GitHubActionsStepSummary')]
	[OutputType(([String], [String[]]), ParameterSetName = 'Content')]
	[OutputType([UInt32], ParameterSetName = 'Sizes')]
	Param (
		[Parameter(ParameterSetName = 'Content')][Switch]$Raw,
		[Parameter(Mandatory = $True, ParameterSetName = 'Sizes')][Alias('Size')][Switch]$Sizes
	)
	Switch ($PSCmdlet.ParameterSetName) {
		'Content' {
			Return (Get-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Raw:$Raw -Encoding 'UTF8NoBOM')
		}
		'Sizes' {
			Return (Get-Item -LiteralPath $env:GITHUB_STEP_SUMMARY).Length
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Remove Step Summary
.DESCRIPTION
Remove step summary that previously added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.OUTPUTS
Void
#>
Function Remove-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsstepsummary#Remove-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param ()
	Return (Remove-Item -LiteralPath $env:GITHUB_STEP_SUMMARY -Confirm:$False)
}
<#
.SYNOPSIS
GitHub Actions - Set Step Summary
.DESCRIPTION
Set some GitHub flavored Markdown for step so that it will display on the summary page of a run; Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures. When a run's job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Content.
.PARAMETER NoNewLine
Do not add a new line or carriage return to the content, the string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
Void
#>
Function Set-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstepsummary#Set-GitHubActionsStepSummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyCollection()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[String[]]$Result = @()
	}
	Process {
		If ($Value.Count -igt 0) {
			$Result += $Value -join "`n"
		}
	}
	End {
		If ($Result.Count -igt 0) {
			Set-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$False -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		Return
	}
}
Export-ModuleMember -Function @(
	'Add-StepSummary',
	'Add-StepSummaryImage',
	'Add-StepSummaryLink',
	'Get-StepSummary',
	'Remove-StepSummary',
	'Set-StepSummary'
) -Alias @(
	'Add-StepSummaryHyperlink',
	'Add-StepSummaryPicture',
	'Add-StepSummaryRaw'
)
