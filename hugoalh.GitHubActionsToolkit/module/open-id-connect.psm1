#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'log.psm1',
		'nodejs-invoke.psm1',
		'utility.psm1'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath $_ }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get OpenID Connect Token
.DESCRIPTION
Interact with the GitHub OpenID Connect (OIDC) provider and get a JSON Web Token (JWT) ID token which would help to get access token from third party cloud providers.
.PARAMETER Audience
Audience.
.PARAMETER UseNodeJsWrapper
Whether to use NodeJS wrapper edition instead of PowerShell edition.
.OUTPUTS
[String] A JSON Web Token (JWT) ID token.
#>
Function Get-OpenIdConnectToken {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsopenidconnecttoken#Get-GitHubActionsOpenIdConnectToken')]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][String]$Audience,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('NodeJs', 'NodeJsWrapper', 'UseNodeJs')][Switch]$UseNodeJsWrapper
	)
	Begin {
		[Boolean]$NoOperation = !(Test-GitHubActionsEnvironment -OpenIDConnect)# When the requirements are not fulfill, only stop this function but not others.
		If ($NoOperation) {
			Write-Error -Message 'Unable to get GitHub Actions OpenID Connect (OIDC) resources!' -Category 'ResourceUnavailable'
		}
	}
	Process {
		If ($NoOperation) {
			Return
		}
		If ($UseNodeJsWrapper.IsPresent) {
			[Hashtable]$InputObject = @{}
			If ($Audience.Length -igt 0) {
				$InputObject.Audience = $Audience
			}
			(Invoke-GitHubActionsNodeJsWrapper -Path 'open-id-connect\get-token.js' -InputObject ([PSCustomObject]$InputObject))?.Token |
				Write-Output
			Return
		}
		[String]$RequestToken = $Env:ACTIONS_ID_TOKEN_REQUEST_TOKEN
		[String]$RequestUri = $Env:ACTIONS_ID_TOKEN_REQUEST_URL
		Add-GitHubActionsSecretMask -Value $RequestToken
		If ($Audience.Length -igt 0) {
			$RequestUri += "&audience=$([System.Web.HttpUtility]::UrlEncode($Audience))"
		}
		Write-GitHubActionsDebug -Message "OpenID Connect Token Request URI: $RequestUri"
		Try {
			[PSCustomObject]$Response = Invoke-WebRequest -Uri $RequestUri -UseBasicParsing -UserAgent 'actions/oidc-client' -Headers @{ Authorization = "Bearer $RequestToken" } -MaximumRedirection 1 -MaximumRetryCount 10 -RetryIntervalSec 10 -Method 'Get'
			[ValidateNotNullOrEmpty()][String]$OidcToken = (ConvertFrom-Json -InputObject $Response.Content -Depth 100).value
			Add-GitHubActionsSecretMask -Value $OidcToken
			Write-Output -InputObject $OidcToken
		}
		Catch {
			Write-Error @_
		}
	}
}
Set-Alias -Name 'Get-OidcToken' -Value 'Get-OpenIdConnectToken' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Get-OpenIdConnectToken'
) -Alias @(
	'Get-OidcToken'
)
