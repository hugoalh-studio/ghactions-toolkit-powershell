# GitHub Actions Toolkit (PowerShell)

[⚖️ MIT](./LICENSE.md)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/ghactions-toolkit-powershell?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square "CodeFactor Grade")](https://www.codefactor.io/repository/github/hugoalh-studio/ghactions-toolkit-powershell)

|  | **Heat** | **Release - Latest** | **Release - Pre** |
|:-:|:-:|:-:|:-:|
| [![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=ffffff&style=flat-square "GitHub")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell) | [![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/ghactions-toolkit-powershell?label=&logoColor=ffffff&style=flat-square "GitHub Stars")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/stargazers) \| ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/ghactions-toolkit-powershell/total?label=&style=flat-square "GitHub Total Downloads") | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&label=&style=flat-square "GitHub Latest Release Version") (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Release Date")) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?include_prereleases&sort=semver&label=&style=flat-square "GitHub Latest Pre-Release Version") (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Pre-Release Date")) |
| [![PowerShell Gallery](https://img.shields.io/badge/PowerShell%20Gallery-0072C6?logo=powershell&logoColor=ffffff&style=flat-square "PowerShell Gallery")](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit) | ![PowerShell Gallery Total Downloads](https://img.shields.io/powershellgallery/dt/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Total Downloads") | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Latest Release Version") | ![PowerShell Gallery Latest Pre-Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?include_prereleases&label=&style=flat-square "PowerShell Gallery Latest Pre-Release Version") |

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.

## 📓 Documentation (Excerpt)

For the full documentation, please visit the [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki).

### Getting Started

- GitHub Actions Runner >= v2.303.0
  - PowerShell >= v7.2.0
  - NodeJS >= v14.15.0 (only for NodeJS wrapper API)

```ps1
Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense
```

```ps1
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Prefix 'GitHubActions' -Scope 'Local'
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
- `Disable-GitHubActionsStdOutCommandEcho`
- `Disable-GitHubActionsStdOutCommandProcess`
- `Enable-GitHubActionsStdOutCommandEcho`
- `Enable-GitHubActionsStdOutCommandProcess`
- `Enter-GitHubActionsLogGroup`
- `Exit-GitHubActionsLogGroup`
- `Expand-GitHubActionsToolCacheCompressedFile` 🔘
- `Export-GitHubActionsArtifact` 🔘
- `Find-GitHubActionsToolCache` 🔘
- `Get-GitHubActionsDebugStatus`
- `Get-GitHubActionsInput`
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

### Example

- ```ps1
  Set-GitHubActionsOutput -Name 'foo' -Value 'bar'
  ```
- ```ps1
  Write-GitHubActionNotice -Message 'Hello, world!'
  ```
  ![Result of `Write-GitHubActionNotice -Message 'Hello, world!'`](./_asset/example_notice.png "Result of `Write-GitHubActionNotice -Message 'Hello, world!'`")
