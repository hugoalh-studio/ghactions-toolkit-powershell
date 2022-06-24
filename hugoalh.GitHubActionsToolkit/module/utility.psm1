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
[Void]
#>
Function Add-SecretMask {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_add-githubactionssecretmask#Add-GitHubActionsSecretMask')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][Alias('Key', 'Secret', 'Token')][String]$Value,
		[Alias('Chunk', 'Chunks', 'WithChunk')][Switch]$WithChunks
	)
	Begin {}
	Process {
		If ($Value.Length -igt 0) {
			Write-GitHubActionsCommand -Command 'add-mask' -Value $Value
		}
		If ($WithChunks.IsPresent) {
			ForEach ($Item In [String[]]($Value -isplit '[\b\n\r\s\t_-]+')) {
				If ($Item.Length -ige 4) {
					Write-GitHubActionsCommand -Command 'add-mask' -Value $Item
				}
			}
		}
	}
	End {
		Return
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
[Boolean] Debug status.
#>
Function Get-IsDebug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsisdebug#Get-GitHubActionsIsDebug')]
	[OutputType([Boolean])]
	Param ()
	If (
		$Env:RUNNER_DEBUG -ieq 'true' -or
		$Env:RUNNER_DEBUG -ieq '1'
	) {
		Return $True
	}
	Return $False
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
[Hashtable] Webhook event payload as hashtable.
[PSCustomObject] Webhook event payload as custom object.
#>
Function Get-WebhookEventPayload {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionswebhookeventpayload#Get-GitHubActionsWebhookEventPayload')]
	[OutputType(([Hashtable], [PSCustomObject]))]
	Param (
		[Alias('ToHashtable')][Switch]$AsHashtable,
		[UInt16]$Depth = 1024,
		[Switch]$NoEnumerate
	)
	Return (Get-Content -LiteralPath $Env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' | ConvertFrom-Json -AsHashtable:$AsHashtable.IsPresent -Depth $Depth -NoEnumerate:$NoEnumerate.IsPresent)
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
[String] Workflow run's URI.
#>
Function Get-WorkflowRunUri {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_get-githubactionsworkflowrunuri#Get-GitHubActionsWorkflowRunUri')]
	[OutputType([String])]
	Param ()
	Return "$Env:GITHUB_SERVER_URL/$Env:GITHUB_REPOSITORY/actions/runs/$Env:GITHUB_RUN_ID"
}
Set-Alias -Name 'Get-WorkflowRunUrl' -Value 'Get-WorkflowRunUri' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test Environment
.DESCRIPTION
Test the current process whether is executing inside the GitHub Actions environment.
.PARAMETER Artifact
Also test the current process whether has GitHub Actions artifact resources.
.PARAMETER Cache
Also test the current process whether has GitHub Actions cache resources.
.PARAMETER OpenIdConnect
Also test the current process whether has GitHub Actions OpenID Connect (OIDC) resources.
.PARAMETER StepSummary
Also test the current process whether has GitHub Actions step summary resources.
.PARAMETER ToolCache
Also test the current process whether has GitHub Actions tool cache resources.
.PARAMETER Mandatory
The requirement whether is mandatory; If mandatory but not fulfill, will throw an error.
.PARAMETER MandatoryMessage
Message when the requirement is mandatory but not fulfill.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-Environment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_test-githubactionsenvironment#Test-GitHubActionsEnvironment')]
	[OutputType([Boolean])]
	Param (
		[Switch]$Artifact,
		[Switch]$Cache,
		[Alias('Oidc')][Switch]$OpenIdConnect,
		[Alias('Summary')][Switch]$StepSummary,
		[Switch]$ToolCache,
		[Alias('Force', 'Forced', 'Require', 'Required')][Switch]$Mandatory,
		[Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'This process require to execute inside the GitHub Actions environment!'
	)
	If (
		$Env:CI -ine 'true' -or
		$Null -ieq $Env:GITHUB_ACTION -or
		$Null -ieq $Env:GITHUB_ACTION_REPOSITORY -or
		$Null -ieq $Env:GITHUB_ACTIONS -or
		$Null -ieq $Env:GITHUB_ACTOR -or
		$Null -ieq $Env:GITHUB_API_URL -or
		$Null -ieq $Env:GITHUB_ENV -or
		$Null -ieq $Env:GITHUB_EVENT_NAME -or
		$Null -ieq $Env:GITHUB_EVENT_PATH -or
		$Null -ieq $Env:GITHUB_GRAPHQL_URL -or
		$Null -ieq $Env:GITHUB_JOB -or
		$Null -ieq $Env:GITHUB_PATH -or
		$Null -ieq $Env:GITHUB_REF_NAME -or
		$Null -ieq $Env:GITHUB_REF_PROTECTED -or
		$Null -ieq $Env:GITHUB_REF_TYPE -or
		$Null -ieq $Env:GITHUB_REPOSITORY -or
		$Null -ieq $Env:GITHUB_REPOSITORY_OWNER -or
		$Null -ieq $Env:GITHUB_RUN_ATTEMPT -or
		$Null -ieq $Env:GITHUB_RUN_ID -or
		$Null -ieq $Env:GITHUB_RUN_NUMBER -or
		$Null -ieq $Env:GITHUB_SERVER_URL -or
		$Null -ieq $Env:GITHUB_SHA -or
		$Null -ieq $Env:GITHUB_WORKFLOW -or
		$Null -ieq $Env:GITHUB_WORKSPACE -or
		$Null -ieq $Env:RUNNER_ARCH -or
		$Null -ieq $Env:RUNNER_NAME -or
		$Null -ieq $Env:RUNNER_OS -or
		$Null -ieq $Env:RUNNER_TEMP -or
		((
			$Artifact.IsPresent -or
			$Cache.IsPresent
		) -and $Null -ieq $Env:ACTIONS_RUNTIME_TOKEN) -or
		($Artifact.IsPresent -and $Null -ieq $Env:ACTIONS_RUNTIME_URL) -or
		($Artifact.IsPresent -and $Null -ieq $Env:GITHUB_RETENTION_DAYS) -or
		($Cache.IsPresent -and $Null -ieq $Env:ACTIONS_CACHE_URL) -or
		($OpenIdConnect.IsPresent -and $Null -ieq $Env:ACTIONS_ID_TOKEN_REQUEST_TOKEN) -or
		($OpenIdConnect.IsPresent -and $Null -ieq $Env:ACTIONS_ID_TOKEN_REQUEST_URL) -or
		($StepSummary.IsPresent -and $Null -ieq $Env:GITHUB_STEP_SUMMARY) -or
		($ToolCache.IsPresent -and $Null -ieq $Env:RUNNER_TOOL_CACHE)
	) {
		If ($Mandatory.IsPresent) {
			Return (Write-GitHubActionsFail -Message $MandatoryMessage)
		}
		Return $False
	}
	Return $True
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
