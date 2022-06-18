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
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][AllowEmptyString()][Alias('Key', 'Secret', 'Token')][String]$Value,
		[Alias('WithChunk')][Switch]$WithChunks
	)
	begin {}
	process {
		if ($Value.Length -igt 0) {
			Write-GitHubActionsCommand -Command 'add-mask' -Value $Value
		}
		if ($WithChunks) {
			foreach ($Item in [String[]]($Value -isplit '[\b\n\r\s\t_-]+')) {
				if ($Item.Length -ige 4) {
					Write-GitHubActionsCommand -Command 'add-mask' -Value $Item
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
	[OutputType([Boolean])]
	Param ()
	if (
		$env:RUNNER_DEBUG -ieq 'true' -or
		$env:RUNNER_DEBUG -ieq '1'
	) {
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
	[OutputType(([Hashtable], [PSCustomObject]))]
	Param (
		[Alias('ToHashtable')][Switch]$AsHashtable,
		[UInt16]$Depth = 1024,
		[Switch]$NoEnumerate
	)
	return (Get-Content -LiteralPath $env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' | ConvertFrom-Json -AsHashtable:$AsHashtable -Depth $Depth -NoEnumerate:$NoEnumerate)
}
Set-Alias -Name 'Get-Event' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-Payload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookEvent' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookPayload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Workflow Run URI
.DESCRIPTION
Get the workflow run's URI.
.OUTPUTS
String
#>
function Get-WorkflowRunUri {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsworkflowrunuri#Get-GitHubActionsWorkflowRunUri')]
	[OutputType([String])]
	Param ()
	return "$env:GITHUB_SERVER_URL/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID"
}
Set-Alias -Name 'Get-WorkflowRunUrl' -Value 'Get-WorkflowRunUri' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test Environment
.DESCRIPTION
Test the current process whether is executing inside the GitHub Actions environment.
.PARAMETER OpenIdConnect
Also test the current process whether has GitHub Actions OpenID Connect (OIDC) resources.
.PARAMETER Mandatory
The requirement whether is mandatory; If mandatory but not fulfill, will throw an error.
.PARAMETER MandatoryMessage
Message when the requirement is mandatory but not fulfill.
#>
function Test-Environment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_test-githubactionsenvironment#Test-GitHubActionsEnvironment')]
	[OutputType([Boolean])]
	Param (
		[Alias('Oidc')][Switch]$OpenIdConnect,
		[Alias('Force', 'Forced', 'Require', 'Required')][Switch]$Mandatory,
		[Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'This process require to execute inside the GitHub Actions environment!'
	)
	if (
		$env:CI -ine 'true' -or
		$null -ieq $env:GITHUB_ACTION_REPOSITORY -or
		$null -ieq $env:GITHUB_ACTION -or
		$null -ieq $env:GITHUB_ACTIONS -or
		$null -ieq $env:GITHUB_ACTOR -or
		$null -ieq $env:GITHUB_API_URL -or
		$null -ieq $env:GITHUB_ENV -or
		$null -ieq $env:GITHUB_EVENT_NAME -or
		$null -ieq $env:GITHUB_EVENT_PATH -or
		$null -ieq $env:GITHUB_GRAPHQL_URL -or
		$null -ieq $env:GITHUB_JOB -or
		$null -ieq $env:GITHUB_PATH -or
		$null -ieq $env:GITHUB_REF_NAME -or
		$null -ieq $env:GITHUB_REF_PROTECTED -or
		$null -ieq $env:GITHUB_REF_TYPE -or
		$null -ieq $env:GITHUB_REPOSITORY_OWNER -or
		$null -ieq $env:GITHUB_REPOSITORY -or
		$null -ieq $env:GITHUB_RETENTION_DAYS -or
		$null -ieq $env:GITHUB_RUN_ATTEMPT -or
		$null -ieq $env:GITHUB_RUN_ID -or
		$null -ieq $env:GITHUB_RUN_NUMBER -or
		$null -ieq $env:GITHUB_SERVER_URL -or
		$null -ieq $env:GITHUB_SHA -or
		$null -ieq $env:GITHUB_STEP_SUMMARY -or
		$null -ieq $env:GITHUB_WORKFLOW -or
		$null -ieq $env:GITHUB_WORKSPACE -or
		$null -ieq $env:RUNNER_ARCH -or
		$null -ieq $env:RUNNER_NAME -or
		$null -ieq $env:RUNNER_OS -or
		$null -ieq $env:RUNNER_TEMP -or
		$null -ieq $env:RUNNER_TOOL_CACHE -or
		($OpenIdConnect -and $null -ieq $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN) -or
		($OpenIdConnect -and $null -ieq $env:ACTIONS_ID_TOKEN_REQUEST_URL)
	) {
		if ($Mandatory) {
			return Write-GitHubActionsFail -Message $MandatoryMessage
		}
		return $false
	}
	return $true
}
Export-ModuleMember -Function @(
	'Add-SecretMask',
	'Get-IsDebug',
	'Get-WebhookEventPayload',
	'Get-WorkflowRunUri',
	'Test-Environment'
) -Alias @(
	'Add-Mask',
	'Add-Secret',
	'Get-Event',
	'Get-Payload',
	'Get-WebhookEvent',
	'Get-WebhookPayload',
	'Get-WorkflowRunUrl'
)
