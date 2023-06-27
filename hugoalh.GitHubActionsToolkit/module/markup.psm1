#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Convert From CSVM
.DESCRIPTION
Convert a CSVM-formatted string to a collection of custom objects or a collection of hashtables.
.PARAMETER InputObject
CSVM string that need to convert from.
.PARAMETER AsHashtable
Whether to output as a collection of hashtables instead of a collection of objects.
.OUTPUTS
[Hashtable[]] Result as hashtable.
[PSCustomObject[]] Result as object.
#>
Function ConvertFrom-CsvM {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_convertfromgithubactionscsvm')]
	[OutputType(([Hashtable[]], [PSCustomObject[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object')][String]$InputObject,
		[Alias('ToHashtable')][Switch]$AsHashtable
	)
	Process {
		$InputObject -isplit '\r?\n' |
			ForEach-Object -Process {
				$Null = $_ -imatch ','
				[Hashtable]$Result = (ConvertFrom-Csv -InputObject $_ -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
					Join-String -Separator "`n" |
					ConvertFrom-StringData
				Write-Output -InputObject ($AsHashtable.IsPresent ? $Result : ([PSCustomObject]$Result))
			} |
			Write-Output
	}
}
<#
.SYNOPSIS
GitHub Actions - Convert From CSVS
.DESCRIPTION
Convert a CSVS-formatted string to a collection of custom objects or a collection of hashtables.
.PARAMETER InputObject
CSVS string that need to convert from.
.PARAMETER AsHashtable
Whether to output as a collection of hashtables instead of a collection of objects.
.OUTPUTS
[Hashtable[]] Result as hashtable.
[PSCustomObject[]] Result as object.
#>
Function ConvertFrom-CsvS {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_convertfromgithubactionscsvs')]
	[OutputType(([Hashtable[]], [PSCustomObject[]]))]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object')][String]$InputObject,
		[Alias('ToHashtable')][Switch]$AsHashtable
	)
	Process {
		$Null = $InputObject -imatch ';'
		(ConvertFrom-Csv -InputObject $InputObject -Delimiter ';' -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
			Join-String -Separator "`n" |
			ConvertFrom-CsvM -AsHashtable:($AsHashtable.IsPresent) |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'ConvertFrom-CsvM'
	'ConvertFrom-CsvS'
)
