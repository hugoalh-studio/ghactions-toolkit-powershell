# GitHub Actions Toolkit (PowerShell)

![License](https://img.shields.io/static/v1?label=License&message=MIT&style=flat-square "License")
[![GitHub Repository](https://img.shields.io/badge/Repository-181717?logo=github&logoColor=ffffff&style=flat-square "GitHub Repository")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell)
[![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/ghactions-toolkit-powershell?label=Stars&logo=github&logoColor=ffffff&style=flat-square "GitHub Stars")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/stargazers)
[![GitHub Contributors](https://img.shields.io/github/contributors/hugoalh-studio/ghactions-toolkit-powershell?label=Contributors&logo=github&logoColor=ffffff&style=flat-square "GitHub Contributors")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues-raw/hugoalh-studio/ghactions-toolkit-powershell?label=Issues&logo=github&logoColor=ffffff&style=flat-square "GitHub Issues")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/hugoalh-studio/ghactions-toolkit-powershell?label=Pull%20Requests&logo=github&logoColor=ffffff&style=flat-square "GitHub Pull Requests")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/hugoalh-studio/ghactions-toolkit-powershell?label=Discussions&logo=github&logoColor=ffffff&style=flat-square "GitHub Discussions")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/discussions)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/ghactions-toolkit-powershell?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square "CodeFactor Grade")](https://www.codefactor.io/repository/github/hugoalh-studio/ghactions-toolkit-powershell)

| **Releases** | **Latest** (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Release Date")) | **Pre** (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Pre-Release Date")) |
|:-:|:-:|:-:|
| [![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=ffffff&style=flat-square "GitHub")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/releases) ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/ghactions-toolkit-powershell/total?label=&style=flat-square "GitHub Total Downloads") | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&label=&style=flat-square "GitHub Latest Release Version") | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?include_prereleases&sort=semver&label=&style=flat-square "GitHub Latest Pre-Release Version") |
| [![PowerShell Gallery](https://img.shields.io/badge/PowerShell%20Gallery-0072C6?logo=powershell&logoColor=ffffff&style=flat-square "PowerShell Gallery")](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit) ![PowerShell Gallery Total Downloads](https://img.shields.io/powershellgallery/dt/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Total Downloads") | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Latest Release Version") | ![PowerShell Gallery Latest Pre-Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?include_prereleases&label=&style=flat-square "PowerShell Gallery Latest Pre-Release Version") |

## 📝 Description

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.

## 📚 Documentation (Excerpt)

For the full documentation, please visit the [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki).

### Getting Started

- GitHub Actions Runner >= v2.303.0
  - PowerShell >= v7.2.0
  - NodeJS >= v14.15.0 (only for NodeJS wrapper API)
  - NPM >= v6.14.8 (only for NodeJS wrapper API) **\***

**\*:** Only apply to some of the versions, please visit "Supported Versions" in the Security Policy (file: `SECURITY.md`).

```ps1
Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense
```

```ps1
<# Either #>
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'# Recommend
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Prefix 'GitHubActions' -Scope 'Local'# Changeable Prefix
```

### API

> | **Legend** | **Description** |
> |:-:|:--|
> | 🔘 | **NodeJS Wrapper:** This dependents and requires NodeJS to invoke. |

#### Function

- `Add-GitHubActionsPATH`
- `Add-GitHubActionsProblemMatcher`
- `Add-GitHubActionsSecretMask`
- `Add-GitHubActionsStepSummary`
- `Add-GitHubActionsStepSummaryHeader`
- `Add-GitHubActionsStepSummaryImage`
- `Add-GitHubActionsStepSummaryLink`
- `Add-GitHubActionsStepSummarySubscriptText`
- `Add-GitHubActionsStepSummarySuperscriptText`
- `Disable-GitHubActionsEchoingCommands`
- `Disable-GitHubActionsProcessingCommands`
- `Enable-GitHubActionsEchoingCommands`
- `Enable-GitHubActionsProcessingCommands`
- `Enter-GitHubActionsLogGroup`
- `Exit-GitHubActionsLogGroup`
- `Expand-GitHubActionsToolCacheCompressedFile` 🔘
- `Export-GitHubActionsArtifact` 🔘
- `Find-GitHubActionsToolCache` 🔘
- `Get-GitHubActionsInput`
- `Get-GitHubActionsIsDebug`
- `Get-GitHubActionsOpenIdConnectToken` 🔘
- `Get-GitHubActionsState`
- `Get-GitHubActionsStepSummary`
- `Get-GitHubActionsWebhookEventPayload`
- `Get-GitHubActionsWorkflowRunUri`
- `Import-GitHubActionsArtifact` 🔘
- `Invoke-GitHubActionsToolCacheToolDownloader` 🔘
- `Register-GitHubActionsToolCacheDirectory` 🔘
- `Register-GitHubActionsToolCacheFile` 🔘
- `Remove-GitHubActionsProblemMatcher`
- `Remove-GitHubActionsStepSummary`
- `Restore-GitHubActionsCache` 🔘
- `Save-GitHubActionsCache` 🔘
- `Set-GitHubActionsEnvironmentVariable`
- `Set-GitHubActionsOutput`
- `Set-GitHubActionsState`
- `Set-GitHubActionsStepSummary`
- `Test-GitHubActionsEnvironment`
- `Test-GitHubActionsNodeJsEnvironment`
- `Write-GitHubActionsAnnotation`
- `Write-GitHubActionsDebug`
- `Write-GitHubActionsError`
- `Write-GitHubActionsFail`
- `Write-GitHubActionsNotice`
- `Write-GitHubActionsRaw`
- `Write-GitHubActionsWarning`
