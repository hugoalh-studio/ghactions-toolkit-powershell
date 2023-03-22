#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'command-base'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Problem Matcher
.DESCRIPTION
Add problem matcher to scan the logs by specified regular expression patterns and automatically surface that information prominently in the user interface, both annotation and log decoration will create when a match is detected. For more information, please visit https://github.com/actions/toolkit/blob/main/docs/problem-matchers.md.
.PARAMETER Path
Paths of the JSON problem matcher files.
.PARAMETER LiteralPath
Literal paths of the JSON problem matcher files.
.OUTPUTS
[Void]
#>
Function Add-ProblemMatcher {
	[CmdletBinding(DefaultParameterSetName = 'Path', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionsproblemmatcher')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Path', Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][SupportsWildcards()][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Path` must be in single line string!')][Alias('File', 'Files', 'Paths')][String[]]$Path,
		[Parameter(Mandatory = $True, ParameterSetName = 'LiteralPath', ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `LiteralPath` must be in single line string!')][Alias('LiteralFile', 'LiteralFiles', 'LiteralPaths', 'LP', 'PSPath', 'PSPaths')][String[]]$LiteralPath
	)
	Process {
		($PSCmdlet.ParameterSetName -ieq 'LiteralPath') ? $LiteralPath : (
			Resolve-Path -Path $Path |
				Select-Object -ExpandProperty 'Path'
		) |
			ForEach-Object -Process { Write-GitHubActionsStdOutCommand -StdOutCommand 'add-matcher' -Value ($_ -ireplace '^\.[\\/]', '' -ireplace '\\', '/') }
	}
}
<#
.SYNOPSIS
GitHub Actions - Remove Problem Matcher
.DESCRIPTION
Remove problem matcher.
.PARAMETER Owner
Owners of the problem matchers.
.OUTPUTS
[Void]
#>
Function Remove-ProblemMatcher {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_removegithubactionsproblemmatcher')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^.+$', ErrorMessage = 'Parameter `Owner` must be in single line string!')][Alias('Identifies', 'Identify', 'Identifier', 'Identifiers', 'Key', 'Keys', 'Name', 'Names', 'Owners')][String[]]$Owner
	)
	Process {
		$Owner |
			ForEach-Object -Process { Write-GitHubActionsStdOutCommand -StdOutCommand 'remove-matcher' -Parameter @{ 'owner' = $_ } }
	}
}
Export-ModuleMember -Function @(
	'Add-ProblemMatcher',
	'Remove-ProblemMatcher'
)
