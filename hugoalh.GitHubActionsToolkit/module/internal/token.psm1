[Char[]]$TokenPool = [String[]]@(0..9) + [Char[]]@(97..122)
<#
.SYNOPSIS
GitHub Actions - Internal - New Random Token
.DESCRIPTION
Get a new random token.
.PARAMETER Length
Token length.
.OUTPUTS
[String] A new random token.
#>
Function New-RandomToken {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateRange(1, [UInt32]::MaxValue)][UInt32]$Length = 8
	)
	@(1..$Length) |
		ForEach-Object -Process {
			$TokenPool |
				Get-Random -Count 1 |
				Write-Output
		} |
		Join-String -Separator '' |
		Write-Output
}
Export-ModuleMember -Function @(
	'New-RandomToken'
)
