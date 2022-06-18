#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'log.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'utility.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get OpenID Connect Token
.DESCRIPTION
Interact with the GitHub OpenID Connect (OIDC) provider and get a JSON Web Token (JWT) ID token which would help to get access token from third party cloud providers.
.PARAMETER Audience
Audience.
.OUTPUTS
String
#>
function Get-OpenIdConnectToken {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsopenidconnecttoken#Get-GitHubActionsOpenIdConnectToken')]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][String]$Audience
	)
	if (!(Test-GitHubActionsEnvironment -OpenIDConnect)) {
		return Write-Error -Message 'Unable to get GitHub Actions OpenID Connect (OIDC) resources!' -Category 'ResourceUnavailable'
	}
	[String]$RequestToken = $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN
	[String]$RequestUri = $env:ACTIONS_ID_TOKEN_REQUEST_URL
	Add-GitHubActionsSecretMask -Value $RequestToken
	if ($Audience.Length -igt 0) {
		$RequestUri += "&audience=$([System.Web.HttpUtility]::UrlEncode($Audience))"
	}
	Write-GitHubActionsDebug -Message "OpenID Connect Token Request URI: $RequestUri"
	try {
		[PSCustomObject]$Response = Invoke-WebRequest -Uri $RequestUri -UseBasicParsing -UserAgent 'actions/oidc-client' -Headers @{ Authorization = "Bearer $RequestToken" } -MaximumRedirection 1 -MaximumRetryCount 10 -RetryIntervalSec 10 -Method 'Get'
		[ValidateNotNullOrEmpty()][String]$OidcToken = (ConvertFrom-Json -InputObject $Response.Content -Depth 100).value
		Add-GitHubActionsSecretMask -Value $OidcToken
		return $OidcToken
	} catch {
		return Write-Error @_
	}
}
Set-Alias -Name 'Get-OidcToken' -Value 'Get-OpenIdConnectToken' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Get-OpenIdConnectToken'
) -Alias @(
	'Get-OidcToken'
)
