#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-base.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Problem Matcher
.DESCRIPTION
Add problem matcher, a way to scan the output of actions for a specified regular expression pattern and automatically surface that information prominently in the user interface, both annotation and log decoration are created when a match is detected. For more information, please visit https://github.com/actions/toolkit/blob/main/docs/problem-matchers.md.
.PARAMETER Path
Relative path to the JSON file problem matcher.
.PARAMETER LiteralPath
Relative literal path to the JSON file problem matcher.
.OUTPUTS
Void
#>
function Add-ProblemMatcher {
	[CmdletBinding(DefaultParameterSetName = 'path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionsproblemmatcher#Add-GitHubActionsProblemMatcher')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'path', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][SupportsWildcards()][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('File', 'Files', 'Paths')][string[]]$Path,
		[Parameter(Mandatory = $true, ParameterSetName = 'literal-path', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `LiteralPath` must be in single line string!')][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][string[]]$LiteralPath
	)
	begin {}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'path' {
				foreach ($Item in [string[]](Resolve-Path -Path $Path -Relative)) {
					Write-GitHubActionsCommand -Command 'add-matcher' -Value ($Item -replace '^\.[\\\/]', '' -replace '\\', '/')
				}
				break
			}
			'literal-path' {
				foreach ($Item in $LiteralPath) {
					Write-GitHubActionsCommand -Command 'add-matcher' -Value ($Item -replace '^\.[\\\/]', '' -replace '\\', '/')
				}
				break
			}
		}
	}
	end {
		return
	}
}
<#
.SYNOPSIS
GitHub Actions - Remove Problem Matcher
.DESCRIPTION
Remove problem matcher that previously added from function `Add-GitHubActionsProblemMatcher`.
.PARAMETER Owner
Owner of the problem matcher that previously added from function `Add-GitHubActionsProblemMatcher`.
.OUTPUTS
Void
#>
function Remove-ProblemMatcher {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsproblemmatcher#Remove-GitHubActionsProblemMatcher')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Owner` must be in single line string!')][Alias('Identifies', 'Identify', 'Identifier', 'Identifiers', 'Key', 'Keys', 'Name', 'Names', 'Owners')][string[]]$Owner
	)
	begin {}
	process {
		foreach ($Item in $Owner) {
			Write-GitHubActionsCommand -Command 'remove-matcher' -Parameter @{ 'owner' = $Item }
		}
	}
	end {
		return
	}
}
Export-ModuleMember -Function @(
	'Add-ProblemMatcher',
	'Remove-ProblemMatcher'
)
