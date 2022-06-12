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
function Add-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsstepsummary#Add-GitHubActionsStepSummary')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][string[]]$Value,
		[switch]$NoNewLine
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		if ($Value.Count -gt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Add-GHActionsStepSummary' -Value 'Add-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Step Summary
.DESCRIPTION
Get step summary that added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.PARAMETER Raw
Ignore newline characters and return the entire contents of a file in one string with the newlines preserved. By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Sizes
Get step summary sizes instead of the content.
.OUTPUTS
String | String[] | UInt
#>
function Get-GitHubActionsStepSummary {
	[CmdletBinding(DefaultParameterSetName = 'content', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsstepsummary#Get-GitHubActionsStepSummary')]
	[OutputType(([string], [string[]]), ParameterSetName = 'content')]
	[OutputType([uint], ParameterSetName = 'sizes')]
	param (
		[Parameter(ParameterSetName = 'content')][switch]$Raw,
		[Parameter(Mandatory = $true, ParameterSetName = 'sizes')][Alias('Size')][switch]$Sizes
	)
	switch ($PSCmdlet.ParameterSetName) {
		'content' {
			return Get-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Raw:$Raw -Encoding 'UTF8NoBOM'
		}
		'sizes' {
			return (Get-ChildItem -LiteralPath $env:GITHUB_STEP_SUMMARY).Length
		}
	}
}
Set-Alias -Name 'Get-GHActionsStepSummary' -Value 'Get-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Remove Step Summary
.DESCRIPTION
Remove step summary that added/setted from functions `Add-GitHubActionsStepSummary` and `Set-GitHubActionsStepSummary`.
.OUTPUTS
Void
#>
function Remove-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsstepsummary#Remove-GitHubActionsStepSummary')]
	[OutputType([void])]
	param ()
	return Remove-Item -LiteralPath $env:GITHUB_STEP_SUMMARY -Confirm:$false
}
Set-Alias -Name 'Remove-GHActionsStepSummary' -Value 'Remove-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
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
function Set-GitHubActionsStepSummary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_set-githubactionsstepsummary#Set-GitHubActionsStepSummary')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][AllowEmptyCollection()][Alias('Content')][string[]]$Value,
		[switch]$NoNewLine
	)
	begin {
		[string[]]$Result = @()
	}
	process {
		if ($Value.Count -gt 0) {
			$Result += $Value -join "`n"
		}
	}
	end {
		if ($Result.Count -gt 0) {
			Set-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($Result -join "`n") -Confirm:$false -NoNewline:$NoNewLine -Encoding 'UTF8NoBOM'
		}
		return
	}
}
Set-Alias -Name 'Set-GHActionsStepSummary' -Value 'Set-GitHubActionsStepSummary' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Add-GitHubActionsStepSummary',
	'Get-GitHubActionsStepSummary',
	'Remove-GitHubActionsStepSummary',
	'Set-GitHubActionsStepSummary'
) -Alias @(
	'Add-GHActionsStepSummary',
	'Get-GHActionsStepSummary',
	'Remove-GHActionsStepSummary',
	'Set-GHActionsStepSummary'
)
