#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'command-base'
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
		If ($Value.Length -gt 0) {
			Write-GitHubActionsStdOutCommand -StdOutCommand 'add-mask' -Value $Value
			If ($WithChunks.IsPresent) {
				$Value -isplit '[\b\n\r\s\t -/:-@\[-`{-~]+' |
					Where-Object -FilterScript { $_.Length -ge 4 -and $_ -ine $Value } |
					ForEach-Object -Process { Write-GitHubActionsStdOutCommand -StdOutCommand 'add-mask' -Value $_ }
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
Function Get-DebugStatus {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionsdebugstatus')]
	[OutputType([Boolean])]
	Param ()
	$Env:RUNNER_DEBUG -iin @('1', 'True') |
		Write-Output
}
Set-Alias -Name 'Get-IsDebug' -Value 'Get-DebugStatus' -Option 'ReadOnly' -Scope 'Local'
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
		[Alias('ToHashtable')][Switch]$AsHashtable
	)
	If (!([System.IO.Path]::IsPathFullyQualified($Env:GITHUB_EVENT_PATH) -and (Test-Path -LiteralPath $Env:GITHUB_EVENT_PATH -PathType 'Leaf'))) {
		Write-Error -Message 'Unable to get the GitHub Actions webhook event payload: Environment path `GITHUB_EVENT_PATH` is not defined or not contain a valid file path, or file is not exist!' -Category 'ResourceUnavailable'
		Return
	}
	Get-Content -LiteralPath $Env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' |
		ConvertFrom-Json -AsHashtable:($AsHashtable.IsPresent) -Depth 100 -NoEnumerate |
		Write-Output
}
Set-Alias -Name 'Get-Event' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Get-EventPayload' -Value 'Get-WebhookEventPayload' -Option 'ReadOnly' -Scope 'Local'
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
	ForEach ($Item In @('GITHUB_SERVER_URL', 'GITHUB_REPOSITORY', 'GITHUB_RUN_ID')) {
		If ([String]::IsNullOrEmpty((Get-Content -LiteralPath "Env:\$Item" -ErrorAction 'SilentlyContinue'))) {
			Write-Error -Message "Unable to get the GitHub Actions workflow run URI: Environment path ``$Item`` is not defined!" -Category 'ResourceUnavailable'
			Return
		}
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
Also test whether have artifact resources.
.PARAMETER Cache
Also test whether have cache resources.
.PARAMETER OpenIdConnect
Also test whether have OpenID Connect (OIDC) resources.
.PARAMETER ToolCache
Also test whether have tool cache resources.
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
		[Switch]$ToolCache,
		[Alias('Require', 'Required')][Switch]$Mandatory,
		[Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'This process requires to invoke inside the GitHub Actions environment!'
	)
	[Hashtable[]]$Items = @(
		@{ NeedTest = $True; Name = 'CI'; ExpectValue = 'true' },
		@{ NeedTest = $True; Name = 'GITHUB_ACTION'; },
		@{ NeedTest = $True; Name = 'GITHUB_ACTIONS'; ExpectValue = 'true' },
		@{ NeedTest = $True; Name = 'GITHUB_ACTOR'; },
		@{ NeedTest = $True; Name = 'GITHUB_ACTOR_ID'; },
		@{ NeedTest = $True; Name = 'GITHUB_API_URL'; },
		@{ NeedTest = $True; Name = 'GITHUB_ENV'; },
		@{ NeedTest = $True; Name = 'GITHUB_EVENT_NAME'; },
		@{ NeedTest = $True; Name = 'GITHUB_EVENT_PATH'; },
		@{ NeedTest = $True; Name = 'GITHUB_GRAPHQL_URL'; },
		@{ NeedTest = $True; Name = 'GITHUB_JOB'; },
		@{ NeedTest = $True; Name = 'GITHUB_OUTPUT'; },
		@{ NeedTest = $True; Name = 'GITHUB_PATH'; },
		@{ NeedTest = $True; Name = 'GITHUB_REF_NAME'; },
		@{ NeedTest = $True; Name = 'GITHUB_REF_TYPE'; },
		@{ NeedTest = $True; Name = 'GITHUB_REPOSITORY'; },
		@{ NeedTest = $True; Name = 'GITHUB_REPOSITORY_ID'; },
		@{ NeedTest = $True; Name = 'GITHUB_REPOSITORY_OWNER'; },
		@{ NeedTest = $True; Name = 'GITHUB_REPOSITORY_OWNER_ID'; },
		@{ NeedTest = $True; Name = 'GITHUB_RETENTION_DAYS'; },
		@{ NeedTest = $True; Name = 'GITHUB_RUN_ATTEMPT'; },
		@{ NeedTest = $True; Name = 'GITHUB_RUN_ID'; },
		@{ NeedTest = $True; Name = 'GITHUB_RUN_NUMBER'; },
		@{ NeedTest = $True; Name = 'GITHUB_SERVER_URL'; },
		@{ NeedTest = $True; Name = 'GITHUB_SHA'; },
		@{ NeedTest = $True; Name = 'GITHUB_STEP_SUMMARY'; },
		@{ NeedTest = $True; Name = 'GITHUB_WORKFLOW'; },
		@{ NeedTest = $True; Name = 'GITHUB_WORKFLOW_REF'; },
		@{ NeedTest = $True; Name = 'GITHUB_WORKFLOW_SHA'; },
		@{ NeedTest = $True; Name = 'GITHUB_WORKSPACE'; },
		@{ NeedTest = $True; Name = 'RUNNER_ARCH'; },
		@{ NeedTest = $True; Name = 'RUNNER_NAME'; },
		@{ NeedTest = $True; Name = 'RUNNER_OS'; },
		@{ NeedTest = $True; Name = 'RUNNER_TEMP'; },
		@{ NeedTest = $True; Name = 'RUNNER_TOOL_CACHE'; },
		@{ NeedTest = $Artifact.IsPresent -or $Cache.IsPresent; Name = 'ACTIONS_RUNTIME_TOKEN'; },
		@{ NeedTest = $Artifact.IsPresent; Name = 'ACTIONS_RUNTIME_URL'; },
		@{ NeedTest = $Cache.IsPresent; Name = 'ACTIONS_CACHE_URL'; },
		@{ NeedTest = $OpenIdConnect.IsPresent; Name = 'ACTIONS_ID_TOKEN_REQUEST_TOKEN'; },
		@{ NeedTest = $OpenIdConnect.IsPresent; Name = 'ACTIONS_ID_TOKEN_REQUEST_URL'; }
	)
	[Boolean]$Failed = $False
	ForEach ($Item In $Items) {
		If ($Item.NeedTest) {
			If ($Null -ieq $Item.ExpectValue) {
				If ([String]::IsNullOrEmpty((Get-Content -LiteralPath "Env:\$($Item.Name)" -ErrorAction 'SilentlyContinue'))) {
					$Failed = $True
					Write-Warning -Message "Unable to get the GitHub Actions resources: Environment path ``$($Item.Name)`` is not defined!"
				}
			}
			Else {
				If ((Get-Content -LiteralPath "Env:\$($Item.Name)" -ErrorAction 'SilentlyContinue') -ine $Item.ExpectValue) {
					$Failed = $True
					Write-Warning -Message "Unable to get the GitHub Actions resources: Environment path ``$($Item.Name)`` is not defined or not equal to expect value!"
				}
			}
		}
	}
	If ($Failed) {
		If ($Mandatory.IsPresent) {
			Write-Error -Message $MandatoryMessage -Category 'InvalidOperation' -ErrorAction 'Stop'
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
	'Get-DebugStatus',
	'Get-WebhookEventPayload',
	'Get-WorkflowRunUri',
	'Test-Environment'
) -Alias @(
	'Add-Mask',
	'Add-Secret',
	'Get-Event',
	'Get-EventPayload',
	'Get-IsDebug',
	'Get-Payload',
	'Get-WebhookEvent',
	'Get-WebhookPayload',
	'Get-WorkflowRunUrl'
)
