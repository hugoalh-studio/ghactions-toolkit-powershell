#Requires -PSEdition Core -Version 7.2
<#
.SYNOPSIS
GitHub Actions - Internal - New Random Token
.DESCRIPTION
Generate a new random token.
.PARAMETER Length
Length of the random token.
.PARAMETER NoLowerCase
Whether to disallow lower case.
.PARAMETER NoNumber
Whether to disallow number.
.PARAMETER NoUpperCase
Whether to disallow upper case.
.OUTPUTS
[String] A new random token.
#>
Function New-RandomToken {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateRange(1, [Int32]::MaxValue)][Int32]$Length = 32,
		[Switch]$NoLowerCase,
		[Switch]$NoNumber,
		[Switch]$NoUpperCase
	)
	[Char[]]$PoolRaw = @()
	If (!$NoLowerCase.IsPresent) {
		$PoolRaw += [Char[]]@(97..122)
	}
	If (!$NoNumber.IsPresent) {
		$PoolRaw += [String[]]@(0..9)
	}
	If (!$NoUpperCase.IsPresent) {
		$PoolRaw += [Char[]]@(65..90)
	}
	[Char[]]$PoolCurrent = $PoolRaw |
		Get-Random -Shuffle
	@(1..$Length) |
		ForEach-Object -Process {
			$PoolCurrent |
				Get-Random -Count 1
		} |
		Join-String -Separator '' |
		Write-Output
}
Export-ModuleMember -Function @(
	'New-RandomToken'
)
