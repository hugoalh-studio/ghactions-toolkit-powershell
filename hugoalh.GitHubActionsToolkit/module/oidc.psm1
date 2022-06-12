#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'log.psm1') -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get OIDC Token
.DESCRIPTION
Interact with the GitHub OIDC provider and get a JWT ID token which would help to get access token from third party cloud providers.
.PARAMETER Audience
Audience.
.OUTPUTS
String
#>
function Get-GitHubActionsOidcToken {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsoidctoken#Get-GitHubActionsOidcToken')]
	[OutputType([string])]
	param (
		[Parameter(Position = 0)][string]$Audience
	)
	[string]$OidcTokenRequestToken = $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN
	[string]$OidcTokenRequestURL = $env:ACTIONS_ID_TOKEN_REQUEST_URL
	if ($OidcTokenRequestToken.Length -eq 0) {
		return Write-Error -Message 'Unable to get GitHub Actions OIDC token request token!' -Category 'ResourceUnavailable'
	}
	Add-GitHubActionsSecretMask -Value $OidcTokenRequestToken
	if ($OidcTokenRequestURL.Length -eq 0) {
		return Write-Error -Message 'Unable to get GitHub Actions OIDC token request URL!' -Category 'ResourceUnavailable'
	}
	if ($Audience.Length -gt 0) {
		Add-GitHubActionsSecretMask -Value $Audience
		[string]$AudienceEncode = [System.Web.HttpUtility]::UrlEncode($Audience)
		Add-GitHubActionsSecretMask -Value $AudienceEncode
		$OidcTokenRequestURL += "&audience=$AudienceEncode"
	}
	try {
		[pscustomobject]$Response = Invoke-WebRequest -Uri $OidcTokenRequestURL -UseBasicParsing -UserAgent 'actions/oidc-client' -Headers @{
			Authorization = "Bearer $OidcTokenRequestToken"
		} -MaximumRedirection 1 -MaximumRetryCount 10 -RetryIntervalSec 10 -Method 'Get'
		[ValidateNotNullOrEmpty()][string]$OidcToken = (ConvertFrom-Json -InputObject $Response.Content -Depth 100).value
		Add-GitHubActionsSecretMask -Value $OidcToken
		return $OidcToken
	} catch {
		return Write-Error @_
	}
}
Set-Alias -Name 'Get-GHActionsOidcToken' -Value 'Get-GitHubActionsOidcToken' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Get-GitHubActionsOidcToken'
) -Alias @(
	'Get-GHActionsOidcToken'
)
