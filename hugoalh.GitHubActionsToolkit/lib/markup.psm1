#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Convert From CSVM
.DESCRIPTION
Convert from a CSVM-formatted string.
.PARAMETER InputObject
CSVM string that need to convert from.
.PARAMETER AsHashtable
Whether to output as a collection of hashtables instead of a collection of objects.
.OUTPUTS
[Hashtable[]] Result as hashtables.
[PSCustomObject[]] Result as objects.
#>
Function ConvertFrom-CsvM {
	[CmdletBinding(DefaultParameterSetName = 'PSCustomObject', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_convertfromgithubactionscsvm')]
	[OutputType([Hashtable[]], ParameterSetName = 'Hashtable')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'PSCustomObject')]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object')][String]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Hashtable')][Alias('ToHashtable')][Switch]$AsHashtable
	)
	Process {
		$InputObject -isplit '\r?\n' |
			ForEach-Object -Process {
				$Null = $_ -imatch ','
				[Hashtable]$Result = (ConvertFrom-Csv -InputObject $_ -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
					Join-String -Separator "`n" |
					ConvertFrom-StringData
				($PSCmdlet.ParameterSetName -ieq 'Hashtable') ? $Result : ([PSCustomObject]$Result) |
					Write-Output
			} |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Convert From CSVS
.DESCRIPTION
Convert from a CSVS-formatted string.
.PARAMETER InputObject
CSVS string that need to convert from.
.PARAMETER AsHashtable
Whether to output as a collection of hashtables instead of a collection of objects.
.OUTPUTS
[Hashtable[]] Result as hashtables.
[PSCustomObject[]] Result as objects.
#>
Function ConvertFrom-CsvS {
	[CmdletBinding(DefaultParameterSetName = 'PSCustomObject', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_convertfromgithubactionscsvs')]
	[OutputType([Hashtable[]], ParameterSetName = 'Hashtable')]
	[OutputType([PSCustomObject[]], ParameterSetName = 'PSCustomObject')]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object')][String]$InputObject,
		[Parameter(Mandatory = $True, ParameterSetName = 'Hashtable')][Alias('ToHashtable')][Switch]$AsHashtable
	)
	Process {
		$Null = $InputObject -imatch ';'
		(ConvertFrom-Csv -InputObject $InputObject -Delimiter ';' -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
			Join-String -Separator "`n" |
			ConvertFrom-CsvM -AsHashtable:($PSCmdlet.ParameterSetName -ieq 'Hashtable') |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Format Markdown
.DESCRIPTION
Format Markdown.
.PARAMETER InputObject
Value.
.OUTPUTS
[String] A formatted Markdown.
#>
Function Format-Markdown {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_formatgithubactionsmarkdown')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -ireplace '\r?\n', '<br />' -ireplace '\\', '\\' -ireplace '`', '\`' -ireplace '\*', '\*' -ireplace '_', '\_' -ireplace '\{', '\{' -ireplace '\}', '\}' -ireplace '\[', '\[' -ireplace '\]', '\]' -ireplace '<', '\<' -ireplace '>', '\>' -ireplace '\(', '\(' -ireplace '\)', '\)' -ireplace '#', '\#' -ireplace '\+', '\+' -ireplace '-', '\-' -ireplace '\.', '\.' -ireplace '!', '\!' -ireplace '\|', '\|' |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'ConvertFrom-CsvM',
	'ConvertFrom-CsvS',
	'Format-Markdown'
)
