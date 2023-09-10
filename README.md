# GitHub Actions Toolkit (PowerShell)

[⚖️ MIT](./LICENSE.md)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/ghactions-toolkit-powershell?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square "CodeFactor Grade")](https://www.codefactor.io/repository/github/hugoalh-studio/ghactions-toolkit-powershell)

|  | **Heat** | **Release - Latest** | **Release - Pre** |
|:-:|:-:|:-:|:-:|
| [![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=ffffff&style=flat-square "GitHub")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell) | [![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/ghactions-toolkit-powershell?label=&logoColor=ffffff&style=flat-square "GitHub Stars")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/stargazers) \| ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/ghactions-toolkit-powershell/total?label=&style=flat-square "GitHub Total Downloads") | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&label=&style=flat-square "GitHub Latest Release Version") (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Release Date")) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?include_prereleases&sort=semver&label=&style=flat-square "GitHub Latest Pre-Release Version") (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/ghactions-toolkit-powershell?label=&style=flat-square "GitHub Latest Pre-Release Date")) |
| [![PowerShell Gallery](https://img.shields.io/badge/PowerShell%20Gallery-0072C6?logo=powershell&logoColor=ffffff&style=flat-square "PowerShell Gallery")](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit) | ![PowerShell Gallery Total Downloads](https://img.shields.io/powershellgallery/dt/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Total Downloads") | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?label=&style=flat-square "PowerShell Gallery Latest Release Version") | ![PowerShell Gallery Latest Pre-Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?include_prereleases&label=&style=flat-square "PowerShell Gallery Latest Pre-Release Version") |

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.

## 📥 Install

### PowerShell

- **Target Version:** >= v7.2.0, &:
  - GitHub Actions Runner >= v2.308.0
  - NodeJS >= v16.13.0 (only for NodeJS wrapper API)
- **Domain/Registry:**
  - **[PowerShell Gallery](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit):**
    ```ps1
    Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense
    ```

## 🧩 API (Excerpt)

> **ℹ️ Notice:** Documentation is included inside the script file, can view it via:
>
> - [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki)

### Function

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
- `Expand-GitHubActionsToolCacheCompressedFile`
- `Export-GitHubActionsArtifact`
- `Find-GitHubActionsToolCache`
- `Get-GitHubActionsDebugStatus`
- `Get-GitHubActionsInput`
- `Get-GitHubActionsOpenIdConnectToken`
- `Get-GitHubActionsState`
- `Get-GitHubActionsStepSummary`
- `Get-GitHubActionsWebhookEventPayload`
- `Get-GitHubActionsWorkflowRunUri`
- `Import-GitHubActionsArtifact`
- `Invoke-GitHubActionsToolCacheToolDownloader`
- `Register-GitHubActionsToolCacheDirectory`
- `Register-GitHubActionsToolCacheFile`
- `Remove-GitHubActionsProblemMatcher`
- `Restore-GitHubActionsCache`
- `Save-GitHubActionsCache`
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

## ✍️ Example

- ```ps1
  Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'

  Set-GitHubActionsOutput -Name 'foo' -Value 'bar'

  Write-GitHubActionNotice -Message 'Hello, world!'
  ```

## 🔗 Other Edition

- Go
  - [actions-go/toolkit](https://github.com/actions-go/toolkit)
  - [haya14busa/go-actions-toolkit](https://github.com/haya14busa/go-actions-toolkit)
- NodeJS
  - [actions/toolkit](https://github.com/actions/toolkit) *\[Official\]*
    - [@actions/artifact](https://www.npmjs.com/package/@actions/artifact)
    - [@actions/cache](https://www.npmjs.com/package/@actions/cache)
    - [@actions/core](https://www.npmjs.com/package/@actions/core)
    - [@actions/exec](https://www.npmjs.com/package/@actions/exec)
    - [@actions/github](https://www.npmjs.com/package/@actions/github)
    - [@actions/glob](https://www.npmjs.com/package/@actions/glob)
    - [@actions/http-client](https://www.npmjs.com/package/@actions/http-client)
    - [@actions/io](https://www.npmjs.com/package/@actions/io)
    - [@actions/tool-cache](https://www.npmjs.com/package/@actions/tool-cache)
  - JasonEtco/actions-toolkit ([GitHub](https://github.com/JasonEtco/actions-toolkit))([NPM](https://www.npmjs.com/package/actions-toolkit))
- Python
  - [boschglobal/action.toolkit](https://github.com/boschglobal/action.toolkit)
