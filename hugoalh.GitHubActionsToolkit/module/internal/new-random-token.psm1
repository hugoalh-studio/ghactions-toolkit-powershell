#Requires -PSEdition Core -Version 7.2
[Char[]]$Pool = [String[]]@(0..9) + [Char[]]@(65..90) + [Char[]]@(97..122)
<#
.SYNOPSIS
GitHub Actions - Internal - New Random Token
.DESCRIPTION
Generate a new random token.
.PARAMETER Length
Length of the random token.
.OUTPUTS
[String] A new random token.
#>
Function New-RandomToken {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateRange(1, [Int32]::MaxValue)][Int32]$Length = 32
	)
	[Char[]]$PoolCurrent = $Pool |
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
