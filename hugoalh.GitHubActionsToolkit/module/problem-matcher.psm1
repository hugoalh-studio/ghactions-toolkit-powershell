#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'command.psm1') -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Problem Matcher
.DESCRIPTION
Problem matchers are a way to scan the output of actions for a specified regular expression pattern and automatically surface that information prominently in the user interface, both annotations and log file decorations are created when a match is detected. For more information, please visit https://github.com/actions/toolkit/blob/main/docs/problem-matchers.md.
.PARAMETER Path
Relative path to the JSON file problem matcher.
.PARAMETER LiteralPath
Relative literal path to the JSON file problem matcher.
.OUTPUTS
Void
#>
function Add-GitHubActionsProblemMatcher {
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
				[string[]](Resolve-Path -Path $Path -Relative) | ForEach-Object -Process {
					return Write-GitHubActionsCommand -Command 'add-matcher' -Message ($_ -replace '^\.[\\\/]', '' -replace '\\', '/')
				}
				break
			}
			'literal-path' {
				$LiteralPath | ForEach-Object -Process {
					return Write-GitHubActionsCommand -Command 'add-matcher' -Message ($_ -replace '^\.[\\\/]', '' -replace '\\', '/')
				}
				break
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Add-GHActionsProblemMatcher' -Value 'Add-GitHubActionsProblemMatcher' -Option 'ReadOnly' -Scope 'Local'
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
function Remove-GitHubActionsProblemMatcher {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_remove-githubactionsproblemmatcher#Remove-GitHubActionsProblemMatcher')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Owner` must be in single line string!')][Alias('Identifies', 'Identify', 'Identifier', 'Identifiers', 'Key', 'Keys', 'Name', 'Names', 'Owners')][string[]]$Owner
	)
	begin {}
	process {
		$Owner | ForEach-Object -Process {
			return Write-GitHubActionsCommand -Command 'remove-matcher' -Property @{ 'owner' = $_ }
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Remove-GHActionsProblemMatcher' -Value 'Remove-GitHubActionsProblemMatcher' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Add-GitHubActionsProblemMatcher',
	'Remove-GitHubActionsProblemMatcher'
) -Alias @(
	'Add-GHActionsProblemMatcher',
	'Remove-GHActionsProblemMatcher'
)
