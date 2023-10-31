#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-stdout.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
[PSCustomObject[]]$EnvironmentMandatoryTests = @(
	[PSCustomObject]@{ Name = 'CI'; ExpectValue = 'true' },
	[PSCustomObject]@{ Name = 'GITHUB_ACTION' },
	[PSCustomObject]@{ Name = 'GITHUB_ACTIONS'; ExpectValue = 'true' },
	[PSCustomObject]@{ Name = 'GITHUB_ACTOR' },
	[PSCustomObject]@{ Name = 'GITHUB_ACTOR_ID' },
	[PSCustomObject]@{ Name = 'GITHUB_API_URL' },
	[PSCustomObject]@{ Name = 'GITHUB_ENV' },
	[PSCustomObject]@{ Name = 'GITHUB_EVENT_NAME' },
	[PSCustomObject]@{ Name = 'GITHUB_EVENT_PATH' },
	[PSCustomObject]@{ Name = 'GITHUB_GRAPHQL_URL' },
	[PSCustomObject]@{ Name = 'GITHUB_JOB' },
	[PSCustomObject]@{ Name = 'GITHUB_OUTPUT' },
	[PSCustomObject]@{ Name = 'GITHUB_PATH' },
	[PSCustomObject]@{ Name = 'GITHUB_REF_NAME' },
	[PSCustomObject]@{ Name = 'GITHUB_REF_TYPE' },
	[PSCustomObject]@{ Name = 'GITHUB_REPOSITORY' },
	[PSCustomObject]@{ Name = 'GITHUB_REPOSITORY_ID' },
	[PSCustomObject]@{ Name = 'GITHUB_REPOSITORY_OWNER' },
	[PSCustomObject]@{ Name = 'GITHUB_REPOSITORY_OWNER_ID' },
	[PSCustomObject]@{ Name = 'GITHUB_RETENTION_DAYS' },
	[PSCustomObject]@{ Name = 'GITHUB_RUN_ATTEMPT' },
	[PSCustomObject]@{ Name = 'GITHUB_RUN_ID' },
	[PSCustomObject]@{ Name = 'GITHUB_RUN_NUMBER' },
	[PSCustomObject]@{ Name = 'GITHUB_SERVER_URL' },
	[PSCustomObject]@{ Name = 'GITHUB_SHA' },
	[PSCustomObject]@{ Name = 'GITHUB_STATE' },
	[PSCustomObject]@{ Name = 'GITHUB_STEP_SUMMARY' },
	[PSCustomObject]@{ Name = 'GITHUB_WORKFLOW' },
	[PSCustomObject]@{ Name = 'GITHUB_WORKFLOW_REF' },
	[PSCustomObject]@{ Name = 'GITHUB_WORKFLOW_SHA' },
	[PSCustomObject]@{ Name = 'GITHUB_WORKSPACE' },
	[PSCustomObject]@{ Name = 'RUNNER_ARCH' },
	[PSCustomObject]@{ Name = 'RUNNER_NAME' },
	[PSCustomObject]@{ Name = 'RUNNER_OS' },
	[PSCustomObject]@{ Name = 'RUNNER_TEMP' },
	[PSCustomObject]@{ Name = 'RUNNER_TOOL_CACHE' }
)
<#
.SYNOPSIS
GitHub Actions - Add Secret Mask
.DESCRIPTION
Make a secret get masked from the log.
.PARAMETER Value
A secret that need to get masked from the log.
.OUTPUTS
[Void]
#>
Function Add-SecretMask {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_addgithubactionssecretmask')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][Alias('Input', 'InputObject', 'Key', 'Object', 'Secret', 'Token')][String]$Value
	)
	Process {
		If ($Value.Length -gt 0) {
			Write-GitHubActionsStdOutCommand -StdOutCommand 'add-mask' -Value $Value
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
	$Env:RUNNER_DEBUG -ieq '1' |
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
	[CmdletBinding(DefaultParameterSetName = 'PSCustomObject', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_getgithubactionswebhookeventpayload')]
	[OutputType([Hashtable], ParameterSetName = 'Hashtable')]
	[OutputType([PSCustomObject], ParameterSetName = 'PSCustomObject')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'Hashtable')][Alias('ToHashtable')][Switch]$AsHashtable
	)
	Try {
		If ([String]::IsNullOrEmpty($Env:GITHUB_EVENT_PATH)) {
			Throw 'Environment path `GITHUB_EVENT_PATH` is not defined!'
		}
		If (!([System.IO.Path]::IsPathFullyQualified($Env:GITHUB_EVENT_PATH))) {
			Throw "``$Env:GITHUB_EVENT_PATH`` (environment path ``GITHUB_EVENT_PATH``) is not a valid absolute path!"
		}
		If (!(Test-Path -LiteralPath $Env:GITHUB_EVENT_PATH -PathType 'Leaf')) {
			Throw 'File is not exist!'
		}
		Get-Content -LiteralPath $Env:GITHUB_EVENT_PATH -Raw -Encoding 'UTF8NoBOM' |
			ConvertFrom-Json -AsHashtable:($PSCmdlet.ParameterSetName -ieq 'Hashtable') -Depth 100
	}
	Catch {
		Write-Error -Message "Unable to get the GitHub Actions webhook event payload: $_" -Category 'ResourceUnavailable'
	}
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
		If ([String]::IsNullOrEmpty([System.Environment]::GetEnvironmentVariable($Item))) {
			Write-Error -Message "Unable to get the GitHub Actions workflow run URI: Environment variable ``$Item`` is not defined!" -Category 'ResourceUnavailable'
			Return
		}
	}
	"$Env:GITHUB_SERVER_URL/$Env:GITHUB_REPOSITORY/actions/runs/$Env:GITHUB_RUN_ID" |
		Write-Output
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
	[CmdletBinding(DefaultParameterSetName = 'Optional', HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_testgithubactionsenvironment')]
	[OutputType([Boolean], ParameterSetName = 'Optional')]
	[OutputType([Void], ParameterSetName = 'Mandatory')]
	Param (
		[Switch]$Artifact,
		[Switch]$Cache,
		[Alias('Oidc')][Switch]$OpenIdConnect,
		[Switch]$ToolCache,
		[Parameter(Mandatory = $True, ParameterSetName = 'Mandatory')][Alias('Require', 'Required')][Switch]$Mandatory,
		[Parameter(ParameterSetName = 'Mandatory')][Alias('RequiredMessage', 'RequireMessage')][String]$MandatoryMessage = 'This process requires to invoke inside the GitHub Actions environment!'
	)
	[PSCustomObject[]]$Tests = $EnvironmentMandatoryTests + @(
		[PSCustomObject]@{ Need = $Artifact.IsPresent -or $Cache.IsPresent; Name = 'ACTIONS_RUNTIME_TOKEN' },
		[PSCustomObject]@{ Need = $Artifact.IsPresent; Name = 'ACTIONS_RUNTIME_URL' },
		[PSCustomObject]@{ Need = $Cache.IsPresent; Name = 'ACTIONS_CACHE_URL' },
		[PSCustomObject]@{ Need = $OpenIdConnect.IsPresent; Name = 'ACTIONS_ID_TOKEN_REQUEST_TOKEN' },
		[PSCustomObject]@{ Need = $OpenIdConnect.IsPresent; Name = 'ACTIONS_ID_TOKEN_REQUEST_URL' }
	)
	[Boolean]$IsSuccess = $True
	ForEach ($Test In $Tests) {
		If ($Test.Need -ine $False) {
			[AllowEmptyString()][AllowNull()][String]$Value = [System.Environment]::GetEnvironmentVariable($Test.Name)
			Try {
				If ([String]::IsNullOrEmpty($Value)) {
					Throw "Environment variable ``$($Test.Name)`` is not defined!"
				}
				If ($Null -ine $Test.ExpectValue -and $Value -ine $Test.ExpectValue) {
					Throw "Environment variable ``$($Test.Name)`` is not contain an expected value!"
				}
			}
			Catch {
				$IsSuccess = $False
				Write-Warning -Message "Unable to get the GitHub Actions resources: $_"
			}
		}
	}
	If ($PSCmdlet.ParameterSetName -ieq 'Mandatory') {
		If (!$IsSuccess) {
			Write-Error -Message $MandatoryMessage -Category 'InvalidOperation' -ErrorAction 'Stop'
		}
	}
	Else {
		$IsSuccess |
			Write-Output
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
