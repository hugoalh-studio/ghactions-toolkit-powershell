#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-base.psm1'),
	(Join-Path -Path $PSScriptRoot -ChildPath 'log.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret will get masked from the log.
.PARAMETER Value
The secret.
.PARAMETER WithChunks
Split the secret to chunks to well make a secret will get masked from the log.
.OUTPUTS
Void
#>
function Add-SecretMask {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionssecretmask#Add-GitHubActionsSecretMask')]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][Alias('Key', 'Secret', 'Token')][string]$Value,
		[Alias('WithChunk')][switch]$WithChunks
	)
	begin {}
	process {
		if ($Value.Length -gt 0) {
			Write-GitHubActionsCommand -Command 'add-mask' -Message $Value
		}
		if ($WithChunks) {
			foreach ($Item in [string[]]($Value -split '[\b\n\r\s\t_-]+')) {
				if ($Item -ne $Value -and $Item.Length -gt 2) {
					Write-GitHubActionsCommand -Command 'add-mask' -Message $Item
				}
			}
		}
	}
	end {
		return
	}
}
Set-Alias -Name 'Add-Mask' -Value 'Add-SecretMask' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-Secret' -Value 'Add-SecretMask' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Debug Status
.DESCRIPTION
Get debug status.
.OUTPUTS
Boolean
#>
function Get-IsDebug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsisdebug#Get-GitHubActionsIsDebug')]
	[OutputType([bool])]
	param ()
	if ($env:RUNNER_DEBUG -eq 'true') {
		return $true
	}
	return $false
}
<#
.SYNOPSIS
GitHub Actions - Get Webhook Event Payload
.DESCRIPTION
Get the complete webhook event payload.
.PARAMETER AsHashtable
Output as hashtable instead of object.
.PARAMETER Depth
Set the maximum depth the JSON input is allowed to have.
.PARAMETER NoEnumerate
Specify that output is not enumerated; Setting this parameter causes arrays to be sent as a single object instead of sending every element separately, this guarantees that JSON can be round-tripped via Cmdlet `ConvertTo-Json`.
.OUTPUTS
Hashtable | PSCustomObject
#>
function Get-WebhookEventPayload {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionswebhookeventpayload#Get-GitHubActionsWebhookEventPayload')]
	[OutputType(([hashtable], [pscustomobject]))]
	param (
		[Alias('ToHashtable')][switch]$AsHashtable,
		[int]$Depth = 1024,
		[switch]$NoEnumerate
	)
	return (Get-Content -LiteralPath $env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' | ConvertFrom-Json -AsHashtable:$AsHashtable -Depth $Depth -NoEnumerate:$NoEnumerate)
}
Set-Alias -Name 'Get-Event' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-Payload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookEvent' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookPayload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test Environment
.DESCRIPTION
Test the current process is executing inside the GitHub Actions environment.
.PARAMETER Require
Whether the requirement is require; If required and not fulfill, will throw an error.
#>
function Test-Environment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_test-githubactionsenvironment#Test-GitHubActionsEnvironment')]
	[OutputType([bool])]
	param (
		[Alias('Force', 'Forced', 'Required')][switch]$Require
	)
	if (
		$env:CI -ne 'true' -or
		$null -eq $env:GITHUB_ACTION_REPOSITORY -or
		$null -eq $env:GITHUB_ACTION -or
		$null -eq $env:GITHUB_ACTIONS -or
		$null -eq $env:GITHUB_ACTOR -or
		$null -eq $env:GITHUB_API_URL -or
		$null -eq $env:GITHUB_ENV -or
		$null -eq $env:GITHUB_EVENT_NAME -or
		$null -eq $env:GITHUB_EVENT_PATH -or
		$null -eq $env:GITHUB_GRAPHQL_URL -or
		$null -eq $env:GITHUB_JOB -or
		$null -eq $env:GITHUB_PATH -or
		$null -eq $env:GITHUB_REF_NAME -or
		$null -eq $env:GITHUB_REF_PROTECTED -or
		$null -eq $env:GITHUB_REF_TYPE -or
		$null -eq $env:GITHUB_REPOSITORY_OWNER -or
		$null -eq $env:GITHUB_REPOSITORY -or
		$null -eq $env:GITHUB_RETENTION_DAYS -or
		$null -eq $env:GITHUB_RUN_ATTEMPT -or
		$null -eq $env:GITHUB_RUN_ID -or
		$null -eq $env:GITHUB_RUN_NUMBER -or
		$null -eq $env:GITHUB_SERVER_URL -or
		$null -eq $env:GITHUB_SHA -or
		$null -eq $env:GITHUB_STEP_SUMMARY -or
		$null -eq $env:GITHUB_WORKFLOW -or
		$null -eq $env:GITHUB_WORKSPACE -or
		$null -eq $env:RUNNER_ARCH -or
		$null -eq $env:RUNNER_NAME -or
		$null -eq $env:RUNNER_OS -or
		$null -eq $env:RUNNER_TEMP -or
		$null -eq $env:RUNNER_TOOL_CACHE
	) {
		if ($Require) {
			return Write-GitHubActionsFail -Message 'This process require to execute inside the GitHub Actions environment!'
		}
		return $false
	}
	return $true
}
Export-ModuleMember -Function @(
	'Add-SecretMask',
	'Get-IsDebug',
	'Get-WebhookEventPayload',
	'Test-Environment'
) -Alias @(
	'Add-Mask',
	'Add-Secret',
	'Get-Event',
	'Get-Payload',
	'Get-WebhookEvent',
	'Get-WebhookPayload'
)
