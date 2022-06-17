#Requires -PSEdition Core
#Requires -Version 7.2
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
function Add-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummary#Add-GitHubActionsStepSummary')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	begin {
		[String[]]$Result = @()
	}
	process {
		if ($Value.Count -igt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -igt 0) {
			Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
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
function Get-StepSummary {
	[CmdletBinding(DefaultParameterSetName = 'Content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstepsummary#Get-GitHubActionsStepSummary')]
	[OutputType(([String], [String[]]), ParameterSetName = 'Content')]
	[OutputType([UInt32], ParameterSetName = 'Sizes')]
	param (
		[Parameter(ParameterSetName = 'Content')][Switch]$Raw,
		[Parameter(Mandatory = $true, ParameterSetName = 'Sizes')][Alias('Size')][Switch]$Sizes
	)
	switch ($PSCmdlet.ParameterSetName) {
		'Content' {
			return Get-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Raw:$Raw -Encoding 'UTF8NoBOM'
		}
		'Sizes' {
			return (Get-Item -LiteralPath $env:GITHUB_STEP_SUMMARY).Length
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
function Remove-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsstepsummary#Remove-GitHubActionsStepSummary')]
	[OutputType([Void])]
	param ()
	return Remove-Item -LiteralPath $env:GITHUB_STEP_SUMMARY -Confirm:$false
}
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
function Set-StepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstepsummary#Set-GitHubActionsStepSummary')]
	[OutputType([Void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	begin {
		[String[]]$Result = @()
	}
	process {
		if ($Value.Count -igt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -igt 0) {
			Set-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Export-ModuleMember -Function @(
	'Add-StepSummary',
	'Get-StepSummary',
	'Remove-StepSummary',
	'Set-StepSummary'
)
