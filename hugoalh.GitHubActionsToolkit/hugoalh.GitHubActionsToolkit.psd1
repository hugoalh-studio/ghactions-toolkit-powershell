@{
	# Script module or binary module file associated with this manifest.
	RootModule = 'hugoalh.GitHubActionsToolkit.psm1'

	# Version number of this module.
	ModuleVersion = '0.3.0'

	# Supported PSEditions
	# CompatiblePSEditions = @()

	# ID used to uniquely identify this module
	GUID = 'df24369f-3475-47f7-9eb3-e024afc48440'

	# Author of this module
	Author = 'hugoalh'

	# Company or vendor of this module
	CompanyName = 'hugoalh Studio'

	# Copyright statement for this module
	Copyright = 'MIT © 2021~2022 hugoalh Studio'

	# Description of the functionality provided by this module
	Description = 'Provide a better and easier way for GitHub Actions to communicate with the runner machine.'

	# Minimum version of the PowerShell engine required by this module
	PowerShellVersion = '7.2'

	# Name of the PowerShell host required by this module
	# PowerShellHostName = ''

	# Minimum version of the PowerShell host required by this module
	# PowerShellHostVersion = ''

	# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
	# DotNetFrameworkVersion = ''

	# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
	# ClrVersion = ''

	# Processor architecture (None, X86, Amd64) required by this module
	# ProcessorArchitecture = ''

	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @()

	# Script files (.ps1) that are run in the caller's environment prior to importing this module.
	# ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @()

	# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
	# NestedModules = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
	FunctionsToExport = @(
		'Add-GitHubActionsEnvironmentVariable',
		'Add-GitHubActionsPATH',
		'Add-GitHubActionsProblemMatcher',
		'Add-GitHubActionsSecretMask',
		'Add-GitHubActionsStepSummary',
		'Disable-GitHubActionsEchoingCommands',
		'Disable-GitHubActionsProcessingCommands',
		'Enable-GitHubActionsEchoingCommands',
		'Enable-GitHubActionsProcessingCommands',
		'Enter-GitHubActionsLogGroup',
		'Exit-GitHubActionsLogGroup',
		'Get-GitHubActionsInput',
		'Get-GitHubActionsIsDebug',
		'Get-GitHubActionsState',
		'Get-GitHubActionsWebhookEventPayload',
		'Remove-GitHubActionsProblemMatcher',
		'Remove-GitHubActionsStepSummary',
		'Set-GitHubActionsOutput',
		'Set-GitHubActionsState',
		'Set-GitHubActionsStepSummary',
		'Test-GitHubActionsEnvironment',
		'Write-GitHubActionsAnnotation',
		'Write-GitHubActionsCommand',
		'Write-GitHubActionsDebug',
		'Write-GitHubActionsError',
		'Write-GitHubActionsFail',
		'Write-GitHubActionsNotice',
		'Write-GitHubActionsWarning'
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module
	VariablesToExport = @()

	# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport = @(
		'Add-GHActionsEnv',
		'Add-GHActionsEnvironment',
		'Add-GHActionsEnvironmentVariable',
		'Add-GHActionsMask',
		'Add-GHActionsPATH',
		'Add-GHActionsProblemMatcher',
		'Add-GHActionsSecret',
		'Add-GHActionsStepSummary',
		'Add-GitHubActionsEnv',
		'Add-GitHubActionsEnvironment',
		'Add-GitHubActionsMask',
		'Add-GitHubActionsSecret',
		'Disable-GHActionsCommandEcho',
		'Disable-GHActionsCommandEchoing',
		'Disable-GHActionsCommandProcess',
		'Disable-GHActionsCommandProcessing',
		'Disable-GHActionsCommandsEcho',
		'Disable-GHActionsCommandsEchoing',
		'Disable-GHActionsCommandsProcess',
		'Disable-GHActionsCommandsProcessing',
		'Disable-GHActionsEchoCommand',
		'Disable-GHActionsEchoCommands',
		'Disable-GHActionsEchoingCommand',
		'Disable-GHActionsEchoingCommands',
		'Disable-GHActionsProcessCommand',
		'Disable-GHActionsProcessCommands',
		'Disable-GHActionsProcessingCommand',
		'Disable-GHActionsProcessingCommands',
		'Disable-GitHubActionsCommandEcho',
		'Disable-GitHubActionsCommandEchoing',
		'Disable-GitHubActionsCommandProcess',
		'Disable-GitHubActionsCommandProcessing',
		'Disable-GitHubActionsCommandsEcho',
		'Disable-GitHubActionsCommandsEchoing',
		'Disable-GitHubActionsCommandsProcess',
		'Disable-GitHubActionsCommandsProcessing',
		'Disable-GitHubActionsEchoCommand',
		'Disable-GitHubActionsEchoCommands',
		'Disable-GitHubActionsEchoingCommand',
		'Disable-GitHubActionsProcessCommand',
		'Disable-GitHubActionsProcessCommands',
		'Disable-GitHubActionsProcessingCommand',
		'Enable-GHActionsCommandEcho',
		'Enable-GHActionsCommandEchoing',
		'Enable-GHActionsCommandProcess',
		'Enable-GHActionsCommandProcessing',
		'Enable-GHActionsCommandsEcho',
		'Enable-GHActionsCommandsEchoing',
		'Enable-GHActionsCommandsProcess',
		'Enable-GHActionsCommandsProcessing',
		'Enable-GHActionsEchoCommand',
		'Enable-GHActionsEchoCommands',
		'Enable-GHActionsEchoingCommand',
		'Enable-GHActionsEchoingCommands',
		'Enable-GHActionsProcessCommand',
		'Enable-GHActionsProcessCommands',
		'Enable-GHActionsProcessingCommand',
		'Enable-GHActionsProcessingCommands',
		'Enable-GitHubActionsCommandEcho',
		'Enable-GitHubActionsCommandEchoing',
		'Enable-GitHubActionsCommandProcess',
		'Enable-GitHubActionsCommandProcessing',
		'Enable-GitHubActionsCommandsEcho',
		'Enable-GitHubActionsCommandsEchoing',
		'Enable-GitHubActionsCommandsProcess',
		'Enable-GitHubActionsCommandsProcessing',
		'Enable-GitHubActionsEchoCommand',
		'Enable-GitHubActionsEchoCommands',
		'Enable-GitHubActionsEchoingCommand',
		'Enable-GitHubActionsProcessCommand',
		'Enable-GitHubActionsProcessCommands',
		'Enable-GitHubActionsProcessingCommand',
		'Enter-GHActionsGroup',
		'Enter-GHActionsLogGroup',
		'Enter-GitHubActionsGroup',
		'Exit-GHActionsGroup',
		'Exit-GHActionsLogGroup',
		'Exit-GitHubActionsGroup',
		'Get-GHActionsEvent',
		'Get-GHActionsInput',
		'Get-GHActionsIsDebug',
		'Get-GHActionsPayload',
		'Get-GHActionsState',
		'Get-GHActionsWebhookEvent',
		'Get-GHActionsWebhookEventPayload',
		'Get-GHActionsWebhookPayload',
		'Get-GitHubActionsEvent',
		'Get-GitHubActionsPayload',
		'Get-GitHubActionsWebhookEvent',
		'Get-GitHubActionsWebhookPayload',
		'Remove-GHActionsProblemMatcher',
		'Remove-GHActionsStepSummary',
		'Restore-GHActionsState',
		'Restore-GitHubActionsState',
		'Save-GHActionsState',
		'Save-GitHubActionsState',
		'Set-GHActionsOutput',
		'Set-GHActionsState',
		'Set-GHActionsStepSummary',
		'Start-GHActionsCommandEcho',
		'Start-GHActionsCommandEchoing',
		'Start-GHActionsCommandProcess',
		'Start-GHActionsCommandProcessing',
		'Start-GHActionsCommandsEcho',
		'Start-GHActionsCommandsEchoing',
		'Start-GHActionsCommandsProcess',
		'Start-GHActionsCommandsProcessing',
		'Start-GHActionsEchoCommand',
		'Start-GHActionsEchoCommands',
		'Start-GHActionsEchoingCommand',
		'Start-GHActionsEchoingCommands',
		'Start-GHActionsProcessCommand',
		'Start-GHActionsProcessCommands',
		'Start-GHActionsProcessingCommand',
		'Start-GHActionsProcessingCommands',
		'Start-GitHubActionsCommandEcho',
		'Start-GitHubActionsCommandEchoing',
		'Start-GitHubActionsCommandProcess',
		'Start-GitHubActionsCommandProcessing',
		'Start-GitHubActionsCommandsEcho',
		'Start-GitHubActionsCommandsEchoing',
		'Start-GitHubActionsCommandsProcess',
		'Start-GitHubActionsCommandsProcessing',
		'Start-GitHubActionsEchoCommand',
		'Start-GitHubActionsEchoCommands',
		'Start-GitHubActionsEchoingCommand',
		'Start-GitHubActionsEchoingCommands',
		'Start-GitHubActionsProcessCommand',
		'Start-GitHubActionsProcessCommands',
		'Start-GitHubActionsProcessingCommand',
		'Start-GitHubActionsProcessingCommands',
		'Stop-GHActionsCommandEcho',
		'Stop-GHActionsCommandEchoing',
		'Stop-GHActionsCommandProcess',
		'Stop-GHActionsCommandProcessing',
		'Stop-GHActionsCommandsEcho',
		'Stop-GHActionsCommandsEchoing',
		'Stop-GHActionsCommandsProcess',
		'Stop-GHActionsCommandsProcessing',
		'Stop-GHActionsEchoCommand',
		'Stop-GHActionsEchoCommands',
		'Stop-GHActionsEchoingCommand',
		'Stop-GHActionsEchoingCommands',
		'Stop-GHActionsProcessCommand',
		'Stop-GHActionsProcessCommands',
		'Stop-GHActionsProcessingCommand',
		'Stop-GHActionsProcessingCommands',
		'Stop-GitHubActionsCommandEcho',
		'Stop-GitHubActionsCommandEchoing',
		'Stop-GitHubActionsCommandProcess',
		'Stop-GitHubActionsCommandProcessing',
		'Stop-GitHubActionsCommandsEcho',
		'Stop-GitHubActionsCommandsEchoing',
		'Stop-GitHubActionsCommandsProcess',
		'Stop-GitHubActionsCommandsProcessing',
		'Stop-GitHubActionsEchoCommand',
		'Stop-GitHubActionsEchoCommands',
		'Stop-GitHubActionsEchoingCommand',
		'Stop-GitHubActionsEchoingCommands',
		'Stop-GitHubActionsProcessCommand',
		'Stop-GitHubActionsProcessCommands',
		'Stop-GitHubActionsProcessingCommand',
		'Stop-GitHubActionsProcessingCommands',
		'Test-GHActionsEnvironment',
		'Write-GHActionsAnnotation',
		'Write-GHActionsCommand',
		'Write-GHActionsDebug',
		'Write-GHActionsError',
		'Write-GHActionsFail',
		'Write-GHActionsNote',
		'Write-GHActionsNotice',
		'Write-GHActionsWarn',
		'Write-GHActionsWarning',
		'Write-GitHubActionsNote',
		'Write-GitHubActionsWarn'
	)

	# DSC resources to export from this module
	# DscResourcesToExport = @()

	# List of all modules packaged with this module
	# ModuleList = @()

	# List of all files packaged with this module
	# FileList = @()

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		PSData = @{
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @(
				'gh-actions',
				'ghactions',
				'github-actions',
				'PSEdition_Core',
				'toolkit'
			)

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/blob/main/LICENSE.md'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell'

			# A URL to an icon representing this module.
			IconUri = 'https://i.imgur.com/knmLbFg.png'

			# ReleaseNotes of this module
			ReleaseNotes = '(Please visit https://github.com/hugoalh-studio/ghactions-toolkit-powershell/releases.)'

			# Prerelease string of this module
			# Prerelease = ''

			# Flag to indicate whether the module requires explicit user acceptance for install/update/save
			RequireLicenseAcceptance = $false

			# External dependent modules of this module
			# ExternalModuleDependencies = @()
		}
	}

	# HelpInfo URI of this module
	HelpInfoURI = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki'

	# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ''
}
