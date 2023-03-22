#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Internal - Test Environment Path
.DESCRIPTION
Test the environment path whether is valid.
.PARAMETER InputObject
Environment path that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-EnvironmentPath {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][Alias('Input', 'Object')][AllowEmptyString()][AllowNull()][String]$InputObject
	)
	Process {
		![String]::IsNullOrEmpty($InputObject) -and [System.IO.Path]::IsPathFullyQualified($InputObject) |
			Write-Output
	}
}
Export-ModuleMember -Function @(
	'Test-EnvironmentPath'
)
