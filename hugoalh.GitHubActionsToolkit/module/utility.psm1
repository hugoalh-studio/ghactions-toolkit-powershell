#Requires -PSEdition Core
#Requires -Version 7.2
Import-Module -Name (
	@(
		'command-base',
		'log'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret get masked from the log.
.PARAMETER Value
A secret that need to get masked from the log.
.PARAMETER WithChunks
Whether to split a secret into chunks to well make a secret get masked from the log.
.OUTPUTS
[Void]
#>
Function Add-SecretMask {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionssecretmask')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][Alias('Key', 'Secret', 'Token')][String]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Advance', 'Advanced', 'Chunk', 'Chunks', 'WithChunk')][Switch]$WithChunks
	)
	Process {
		If ($Value.Length -igt 0) {
			Write-GitHubActionsCommand -Command 'add-mask' -Value $Value
			If ($WithChunks.IsPresent) {
				$Value -isplit '[\b\n\r\s\t\\/_-]+' |
					Where-Object -FilterScript { $_.Length -ige 4 -and $_ -ine $Value } |
					ForEach-Object -Process { Write-GitHubActionsCommand -Command 'add-mask' -Value $_ }
			}
		}
	}
}
Set-Alias -Name 'Add-Mask' -Value 'Add-SecretMask' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Add-Secret' -Value 'Add-SecretMask' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Debug Status
.DESCRIPTION
Get the debug status of the runner.
.OUTPUTS
[Boolean] Debug status.
#>
Function Get-IsDebug {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsisdebug')]
	[OutputType([Boolean])]
	Param ()
	(
		$Env:RUNNER_DEBUG -ieq '1' -or
		$Env:RUNNER_DEBUG -ieq 'true'
	) |
		Write-Output
}
<#
.SYNOPSIS
GitHub Actions - Get Webhook Event Payload
.DESCRIPTION
Get the complete webhook event payload.
.PARAMETER AsHashtable
Whether to output as hashtable instead of object.
.OUTPUTS
[Hashtable] Webhook event payload as hashtable.
[PSCustomObject] Webhook event payload as object.
#>
Function Get-WebhookEventPayload {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionswebhookeventpayload')]
	[OutputType(([Hashtable], [PSCustomObject]))]
	Param (
		[Alias('ToHashtable')][Switch]$AsHashtable,
		[UInt16]$Depth,# Deprecated, keep as legacy.
		[Switch]$NoEnumerate# Deprecated, keep as legacy.
	)
	If (!(Test-Environment)) {
		Write-Error -Message 'Unable to get GitHub Actions resources!' -Category 'ResourceUnavailable'
		Return
	}
	Get-Content -LiteralPath $Env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' |
		ConvertFrom-Json -AsHashtable:$AsHashtable.IsPresent -Depth 100 -NoEnumerate |
		Write-Output
}
Set-Alias -Name 'Get-Event' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-Payload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookEvent' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-WebhookPayload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Workflow Run URI
.DESCRIPTION
Get the URI of the workflow run.
.OUTPUTS
[String] URI of the workflow run.
#>
Function Get-WorkflowRunUri {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsworkflowrunuri')]
	[OutputType([String])]
	Param ()
	If (!(Test-Environment)) {
		Write-Error -Message 'Unable to get GitHub Actions resources!' -Category 'ResourceUnavailable'
		Return
	}
	Write-Output -InputObject "$Env:GITHUB_SERVER_URL/$Env:GITHUB_REPOSITORY/actions/runs/$Env:GITHUB_RUN_ID"
}
Set-Alias -Name 'Get-WorkflowRunUrl' -Value 'Get-WorkflowRunUri' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Test Environment
.DESCRIPTION
Test the current process whether is executing inside the GitHub Actions environment.
.PARAMETER Artifact
Also test whether has artifact resources.
.PARAMETER Cache
Also test whether has cache resources.
.PARAMETER OpenIdConnect
Also test whether has OpenID Connect (OIDC) resources.
.PARAMETER StepSummary
Also test whether has step summary resources.
.PARAMETER ToolCache
Also test whether has tool cache resources.
.PARAMETER Mandatory
Whether the requirement is mandatory; If mandatory but not fulfill, will throw an error.
.PARAMETER MandatoryMessage
Message when the requirement is mandatory but not fulfill.
.OUTPUTS
[Boolean] Test result when the requirement is not mandatory.
[Void] Nothing when the requirement is mandatory.
#>
Function Test-Environment {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_testgithubactionsenvironment')]
	[OutputType(([Boolean], [Void]))]
	Param (
		[Switch]$Artifact,
		[Switch]$Cache,
		[Alias('Oidc')][Switch]$OpenIdConnect,
		[Switch]$StepSummary,
		[Switch]$ToolCache,
		[Alias('Require', 'Required')][Switch]$Mandatory,
		[Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'This process requires to invoke inside the GitHub Actions environment!'
	)
	If (# Some conditions are disabled to provide compatibility, will enable those when with runner version requirement.
		($Env:CI -ine 'true') -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_ACTION) -or
		($Env:GITHUB_ACTIONS -ine 'true') -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_ACTOR) -or
		# [String]::IsNullOrWhiteSpace($Env:GITHUB_ACTOR_ID) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_API_URL) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_ENV) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_EVENT_NAME) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_EVENT_PATH) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_GRAPHQL_URL) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_JOB) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_PATH) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_REF_NAME) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_REF_PROTECTED) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_REF_TYPE) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_REPOSITORY) -or
		# [String]::IsNullOrWhiteSpace($Env:GITHUB_REPOSITORY_ID) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_REPOSITORY_OWNER) -or
		# [String]::IsNullOrWhiteSpace($Env:GITHUB_REPOSITORY_OWNER_ID) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_RUN_ATTEMPT) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_RUN_ID) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_RUN_NUMBER) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_SERVER_URL) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_SHA) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_WORKFLOW) -or
		# [String]::IsNullOrWhiteSpace($Env:GITHUB_WORKFLOW_REF) -or
		# [String]::IsNullOrWhiteSpace($Env:GITHUB_WORKFLOW_SHA) -or
		[String]::IsNullOrWhiteSpace($Env:GITHUB_WORKSPACE) -or
		[String]::IsNullOrWhiteSpace($Env:RUNNER_ARCH) -or
		[String]::IsNullOrWhiteSpace($Env:RUNNER_NAME) -or
		[String]::IsNullOrWhiteSpace($Env:RUNNER_OS) -or
		[String]::IsNullOrWhiteSpace($Env:RUNNER_TEMP) -or
		((
			$Artifact.IsPresent -or
			$Cache.IsPresent
		) -and [String]::IsNullOrWhiteSpace($Env:ACTIONS_RUNTIME_TOKEN)) -or
		($Artifact.IsPresent -and [String]::IsNullOrWhiteSpace($Env:ACTIONS_RUNTIME_URL)) -or
		($Artifact.IsPresent -and [String]::IsNullOrWhiteSpace($Env:GITHUB_RETENTION_DAYS)) -or
		($Cache.IsPresent -and [String]::IsNullOrWhiteSpace($Env:ACTIONS_CACHE_URL)) -or
		($OpenIdConnect.IsPresent -and [String]::IsNullOrWhiteSpace($Env:ACTIONS_ID_TOKEN_REQUEST_TOKEN)) -or
		($OpenIdConnect.IsPresent -and [String]::IsNullOrWhiteSpace($Env:ACTIONS_ID_TOKEN_REQUEST_URL)) -or
		($StepSummary.IsPresent -and [String]::IsNullOrWhiteSpace($Env:GITHUB_STEP_SUMMARY)) -or
		($ToolCache.IsPresent -and [String]::IsNullOrWhiteSpace($Env:RUNNER_TOOL_CACHE))
	) {
		If ($Mandatory.IsPresent) {
			Write-GitHubActionsFail -Message $MandatoryMessage
			Throw
		}
		Write-Output -InputObject $False
		Return
	}
	If (!$Mandatory.IsPresent) {
		Write-Output -InputObject $True
	}
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
