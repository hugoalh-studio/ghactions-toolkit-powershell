# GitHub Actions Toolkit (PowerShell)

[`GitHubActionsToolkit.PowerShell`](https://github.com/hugoalh-studio/ghactions-toolkit-powershell)
[![GitHub Contributors](https://img.shields.io/github/contributors/hugoalh-studio/ghactions-toolkit-powershell?label=Contributors&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues-raw/hugoalh-studio/ghactions-toolkit-powershell?label=Issues&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/hugoalh-studio/ghactions-toolkit-powershell?label=Pull%20Requests&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/hugoalh-studio/ghactions-toolkit-powershell?label=Discussions&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/discussions)
[![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/ghactions-toolkit-powershell?label=Stars&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hugoalh-studio/ghactions-toolkit-powershell?label=Forks&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/network/members)
![GitHub Languages](https://img.shields.io/github/languages/count/hugoalh-studio/ghactions-toolkit-powershell?label=Languages&logo=github&logoColor=ffffff&style=flat-square)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/ghactions-toolkit-powershell?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square)](https://www.codefactor.io/repository/github/hugoalh-studio/ghactions-toolkit-powershell)
[![License](https://img.shields.io/static/v1?label=License&message=MIT&style=flat-square)](./LICENSE.md)

| **Release** | **Latest** (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?label=%20&style=flat-square)) | **Pre** (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/ghactions-toolkit-powershell?label=%20&style=flat-square)) |
|:-:|:-:|:-:|
| [**GitHub**](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/releases) ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/ghactions-toolkit-powershell/total?label=%20&style=flat-square) | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&label=%20&style=flat-square) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?include_prereleases&sort=semver&label=%20&style=flat-square) |
| [**PowerShell Gallery**](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit) ![PowerShell Gallery Total Downloads](https://img.shields.io/powershellgallery/dt/hugoalh.GitHubActionsToolkit?label=%20&style=flat-square) | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?label=%20&style=flat-square) | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?include_prereleases&label=%20&style=flat-square) |

## ???? Description

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.

## ???? Documentation

*For the official documentation, please visit [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki).*

### Getting Started (Excerpt)

#### Install

- PowerShell >= v7.2.0
- NodeJS >= v14.15.0 (only for NodeJS wrapper API)
- NPM >= v6.14.8 (only for NodeJS wrapper API)

```ps1
Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense
```

#### Use

```ps1
<# Either #>
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'# Recommend
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Prefix 'GitHubActions' -Scope 'Local'# (>= v0.5.0) Changeable Prefix
```

### API (Excerpt)

| **Legend** | **Description** |
|:-:|:--|
| ???? | **Experimental:** This is in testing, maybe available in the latest version and/or future version. |
| ???? | **NodeJS Wrapper:** This dependents and requires NodeJS to invoke. |

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
- `Expand-GitHubActionsToolCacheCompressedFile` ????????
- `Export-GitHubActionsArtifact` ????????
- `Find-GitHubActionsToolCache` ????????
- `Get-GitHubActionsInput`
- `Get-GitHubActionsIsDebug`
- `Get-GitHubActionsOpenIdConnectToken` ????
- `Get-GitHubActionsState`
- `Get-GitHubActionsStepSummary`
- `Get-GitHubActionsWebhookEventPayload`
- `Get-GitHubActionsWorkflowRunUri`
- `Import-GitHubActionsArtifact` ????????
- `Invoke-GitHubActionsToolCacheToolDownloader` ????????
- `Register-GitHubActionsToolCacheDirectory` ????????
- `Register-GitHubActionsToolCacheFile` ????????
- `Remove-GitHubActionsProblemMatcher`
- `Remove-GitHubActionsStepSummary`
- `Restore-GitHubActionsCache` ????????
- `Save-GitHubActionsCache` ????????
- `Set-GitHubActionsEnvironmentVariable`
- `Set-GitHubActionsOutput`
- `Set-GitHubActionsState`
- `Set-GitHubActionsStepSummary`
- `Test-GitHubActionsEnvironment`
- `Test-GitHubActionsNodeJsEnvironment` ????
- `Write-GitHubActionsAnnotation`
- `Write-GitHubActionsCommand`
- `Write-GitHubActionsDebug`
- `Write-GitHubActionsError`
- `Write-GitHubActionsFail`
- `Write-GitHubActionsNotice`
- `Write-GitHubActionsRaw`
- `Write-GitHubActionsWarning`

### Example (Excerpt)

```ps1
Set-GitHubActionsOutput -Name 'foo' -Value 'bar'
#=> ::set-output name=foo::bar
```
