# GitHub Actions Toolkit (PowerShell)

[**⚖️** MIT](./LICENSE.md)

**🗂️**
[![GitHub: hugoalh-studio/ghactions-toolkit-powershell](https://img.shields.io/badge/hugoalh--studio/ghactions--toolkit--powershell-181717?logo=github&logoColor=ffffff&style=flat "GitHub: hugoalh-studio/ghactions-toolkit-powershell")](https://github.com/hugoalh-studio/ghactions-toolkit-powershell)
[![PowerShell Gallery: hugoalh.GitHubActionsToolkit](https://img.shields.io/badge/hugoalh.GitHubActionsToolkit-0072C6?logo=powershell&logoColor=ffffff&style=flat "PowerShell Gallery: hugoalh.GitHubActionsToolkit")](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit)

**🆙** ![Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&color=2187C0&label=&style=flat "Latest Release Version") (![Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?color=2187C0&label=&style=flat "Latest Release Date"))

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine, and the toolkit for developing GitHub Actions in PowerShell.

## 🎯 Target

- PowerShell >= v7.2.0
  > **💽 Require Software**
  >
  > - GitHub Actions Runner
  > - NodeJS >= v16.13.0 *(Optional, for NodeJS based wrapper API)*

### 🔗 Other Edition

- NodeJS
  - [actions/toolkit](https://github.com/actions/toolkit)
    - [@actions/artifact](https://www.npmjs.com/package/@actions/artifact)
    - [@actions/cache](https://www.npmjs.com/package/@actions/cache)
    - [@actions/core](https://www.npmjs.com/package/@actions/core)
    - [@actions/exec](https://www.npmjs.com/package/@actions/exec)
    - [@actions/github](https://www.npmjs.com/package/@actions/github)
    - [@actions/glob](https://www.npmjs.com/package/@actions/glob)
    - [@actions/http-client](https://www.npmjs.com/package/@actions/http-client)
    - [@actions/io](https://www.npmjs.com/package/@actions/io)
    - [@actions/tool-cache](https://www.npmjs.com/package/@actions/tool-cache)

## 🔰 Usage

1. Install via PowerShell:
    ```pwsh
    Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense
    ```
2. Import at the script (`<ScriptName>.ps1`):
    ```ps1
    Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'
    ```

## 🧩 API (Excerpt)

> **ℹ️ Note**
>
> For the prettier documentation, can visit via:
>
> - [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki)

### Function

- `Add-GitHubActionsPATH`
- `Add-GitHubActionsProblemMatcher`
- `Add-GitHubActionsSecretMask`
- `Add-GitHubActionsSummary`
- `Add-GitHubActionsSummaryHeader`
- `Add-GitHubActionsSummaryImage`
- `Add-GitHubActionsSummaryLink`
- `Add-GitHubActionsSummarySubscriptText`
- `Add-GitHubActionsSummarySuperscriptText`
- `Disable-GitHubActionsStdOutCommandEcho`
- `Disable-GitHubActionsStdOutCommandProcess`
- `Enable-GitHubActionsStdOutCommandEcho`
- `Enable-GitHubActionsStdOutCommandProcess`
- `Enter-GitHubActionsLogGroup`
- `Exit-GitHubActionsLogGroup`
- `Expand-GitHubActionsToolCacheCompressedFile`
- `Export-GitHubActionsArtifact`
- `Find-GitHubActionsToolCache`
- `Get-GitHubActionsArtifact`
- `Get-GitHubActionsDebugStatus`
- `Get-GitHubActionsInput`
- `Get-GitHubActionsOpenIdConnectToken`
- `Get-GitHubActionsState`
- `Get-GitHubActionsSummary`
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
- `Set-GitHubActionsSummary`
- `Test-GitHubActionsEnvironment`
- `Write-GitHubActionsDebug`
- `Write-GitHubActionsError`
- `Write-GitHubActionsFail`
- `Write-GitHubActionsNotice`
- `Write-GitHubActionsWarning`

## ✍️ Example

- ```ps1
  Set-GitHubActionsOutput -Name 'foo' -Value 'bar'
  ```
- ```ps1
  Write-GitHubActionNotice -Message 'Hello, world!'
  ```
