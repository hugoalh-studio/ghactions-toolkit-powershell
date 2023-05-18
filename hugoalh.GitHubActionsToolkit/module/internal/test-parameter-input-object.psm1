#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Internal - Test Parameter Input Object
.DESCRIPTION
Test the parameter input object whether is valid.
.PARAMETER InputObject
Parameter input object that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-ParameterInputObject {
	[CmdletBinding()]
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'Object')]$InputObject
	)
	Write-Output -InputObject (
		$InputObject -is [Hashtable] -or
		$InputObject -is [Object[]] -or
		$InputObject -is [System.Collections.Specialized.OrderedDictionary]
	)
}
Export-ModuleMember -Function @(
	'Test-ParameterInputObject'
)
