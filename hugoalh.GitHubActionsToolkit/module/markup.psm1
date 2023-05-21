#Requires -PSEdition Core -Version 7.2
Function ConvertFrom-CsvM {
	[CmdletBinding()]
	[OutputType([PSCustomObject[]])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -isplit '\r?\n' |
			ForEach-Object -Process {
				$Null = $_ -imatch ','
				[PSCustomObject](
					(ConvertFrom-Csv -InputObject $_ -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
					Join-String -Separator "`n" |
					ConvertFrom-StringData
				) |
					Write-Output
			} |
			Write-Output
	}
}
Function ConvertFrom-CsvS {
	[CmdletBinding()]
	[OutputType([PSCustomObject[]])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$Null = $InputObject -imatch ';'
		(ConvertFrom-Csv -InputObject $InputObject -Delimiter ';' -Header @(0..($Matches.Count + 1))).PSObject.Properties.Value |
			Join-String -Separator "`n" |
			ConvertFrom-CsvM |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'ConvertFrom-CsvM'
	'ConvertFrom-CsvS'
)
