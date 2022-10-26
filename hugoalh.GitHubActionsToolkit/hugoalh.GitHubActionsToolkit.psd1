@{
	# Script module or binary module file associated with this manifest.
	RootModule = 'hugoalh.GitHubActionsToolkit.psm1'

	# Version number of this module.
	ModuleVersion = '1.1.1'

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
	Description = 'Provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.'

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
		'Add-PATH',
		'Add-ProblemMatcher',
		'Add-SecretMask',
		'Add-StepSummary',
		'Add-StepSummaryHeader',
		'Add-StepSummaryImage',
		'Add-StepSummaryLink',
		'Add-StepSummarySubscriptText',
		'Add-StepSummarySuperscriptText',
		'Clear-FileCommand',
		'Disable-EchoingCommands',
		'Disable-ProcessingCommands',
		'Enable-EchoingCommands',
		'Enable-ProcessingCommands',
		'Enter-LogGroup',
		'Exit-LogGroup',
		'Expand-ToolCacheCompressedFile',
		'Export-Artifact',
		'Find-ToolCache',
		'Get-Input',
		'Get-IsDebug',
		'Get-OpenIdConnectToken',
		'Get-State',
		'Get-StepSummary',
		'Get-WebhookEventPayload',
		'Get-WorkflowRunUri',
		'Import-Artifact',
		'Invoke-ToolCacheToolDownloader',
		'Register-ToolCacheDirectory',
		'Register-ToolCacheFile',
		'Remove-ProblemMatcher',
		'Remove-StepSummary',
		'Restore-Cache',
		'Save-Cache',
		'Set-EnvironmentVariable',
		'Set-Output',
		'Set-State',
		'Set-StepSummary',
		'Test-Environment',
		'Test-NodeJsEnvironment',
		'Write-Annotation',
		'Write-Command',
		'Write-Debug',
		'Write-Error',
		'Write-Fail',
		'Write-Notice',
		'Write-Raw',
		'Write-Warning'
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module
	VariablesToExport = @()

	# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport = @(
		'Add-Mask',
		'Add-Secret',
		'Add-StepSummaryHyperlink',
		'Add-StepSummaryPicture',
		'Add-StepSummaryRaw',
		'Add-StepSummarySubscript',
		'Add-StepSummarySuperscript',
		'Disable-CommandEcho',
		'Disable-CommandEchoing',
		'Disable-CommandProcess',
		'Disable-CommandProcessing',
		'Disable-CommandsEcho',
		'Disable-CommandsEchoing',
		'Disable-CommandsProcess',
		'Disable-CommandsProcessing',
		'Disable-EchoCommand',
		'Disable-EchoCommands',
		'Disable-EchoingCommand',
		'Disable-ProcessCommand',
		'Disable-ProcessCommands',
		'Disable-ProcessingCommand',
		'Enable-CommandEcho',
		'Enable-CommandEchoing',
		'Enable-CommandProcess',
		'Enable-CommandProcessing',
		'Enable-CommandsEcho',
		'Enable-CommandsEchoing',
		'Enable-CommandsProcess',
		'Enable-CommandsProcessing',
		'Enable-EchoCommand',
		'Enable-EchoCommands',
		'Enable-EchoingCommand',
		'Enable-ProcessCommand',
		'Enable-ProcessCommands',
		'Enable-ProcessingCommand',
		'Enter-Group',
		'Exit-Group',
		'Expand-ToolCacheArchive',
		'Expand-ToolCacheCompressedArchive',
		'Expand-ToolCacheFile',
		'Export-Cache',
		'Get-Event',
		'Get-OidcToken',
		'Get-Payload',
		'Get-WebhookEvent',
		'Get-WebhookPayload',
		'Get-WorkflowRunUrl',
		'Import-Cache',
		'Restore-Artifact',
		'Restore-State',
		'Save-Artifact',
		'Save-State',
		'Set-Env',
		'Set-Environment',
		'Start-CommandEcho',
		'Start-CommandEchoing',
		'Start-CommandProcess',
		'Start-CommandProcessing',
		'Start-CommandsEcho',
		'Start-CommandsEchoing',
		'Start-CommandsProcess',
		'Start-CommandsProcessing',
		'Start-EchoCommand',
		'Start-EchoCommands',
		'Start-EchoingCommand',
		'Start-EchoingCommands',
		'Start-ProcessCommand',
		'Start-ProcessCommands',
		'Start-ProcessingCommand',
		'Start-ProcessingCommands',
		'Stop-CommandEcho',
		'Stop-CommandEchoing',
		'Stop-CommandProcess',
		'Stop-CommandProcessing',
		'Stop-CommandsEcho',
		'Stop-CommandsEchoing',
		'Stop-CommandsProcess',
		'Stop-CommandsProcessing',
		'Stop-EchoCommand',
		'Stop-EchoCommands',
		'Stop-EchoingCommand',
		'Stop-EchoingCommands',
		'Stop-ProcessCommand',
		'Stop-ProcessCommands',
		'Stop-ProcessingCommand',
		'Stop-ProcessingCommands',
		'Write-Note',
		'Write-Warn'
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

			# A literal path to the license for this module.
			License = '.\LICENSE.md'

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/blob/main/LICENSE.md'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell'

			# A literal path to an icon representing this module.
			Icon = '.\icon.png'

			# A URL to an icon representing this module.
			IconUri = 'https://i.imgur.com/6qM8z4w.png'

			# ReleaseNotes of this module
			ReleaseNotes = '(Please visit https://github.com/hugoalh-studio/ghactions-toolkit-powershell/releases.)'

			# Prerelease string of this module
			# Prerelease = ''

			# Flag to indicate whether the module requires explicit user acceptance for install/update/save
			RequireLicenseAcceptance = $False

			# External dependent modules of this module
			# ExternalModuleDependencies = @()
		}
	}

	# HelpInfo URI of this module
	HelpInfoURI = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki'

	# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
	DefaultCommandPrefix = 'GitHubActions'
}
