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
[![License](https://img.shields.io/static/v1?label=License&message=MIT&color=brightgreen&style=flat-square)](./LICENSE.md)

| **Release** | **Latest** (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/ghactions-toolkit-powershell?label=%20&style=flat-square)) | **Pre** (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/ghactions-toolkit-powershell?label=%20&style=flat-square)) |
|:-:|:-:|:-:|
| [**GitHub**](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/releases) ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/ghactions-toolkit-powershell/total?label=%20&style=flat-square) | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?sort=semver&label=%20&style=flat-square) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/ghactions-toolkit-powershell?include_prereleases&sort=semver&label=%20&style=flat-square) |
| [**PowerShell Gallery**](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsToolkit) ![PowerShell Gallery Total Downloads](https://img.shields.io/powershellgallery/dt/hugoalh.GitHubActionsToolkit?label=%20&style=flat-square) | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?label=%20&style=flat-square) | ![PowerShell Gallery Latest Release Version](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsToolkit?include_prereleases&label=%20&style=flat-square) |

## 📝 Description

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner machine.

## 📚 Documentation

*For the official documentation, please visit [GitHub Repository Wiki](https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki).*

### Getting Started (Excerpt)

#### Install

PowerShell (>= v7.2.0):

```ps1
Install-Module -Name 'hugoalh.GitHubActionsToolkit'
```

#### Use

```ps1
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope Local
```

### Function (Excerpt)

- `Add-GitHubActionsEnvironmentVariable`
- `Add-GitHubActionsPATH`
- `Add-GitHubActionsProblemMatcher`
- `Add-GitHubActionsSecretMask`
- `Disable-GitHubActionsEchoCommand`
- `Disable-GitHubActionsProcessingCommand`
- `Enable-GitHubActionsEchoCommand`
- `Enable-GitHubActionsProcessingCommand`
- `Enter-GitHubActionsLogGroup`
- `Exit-GitHubActionsLogGroup`
- `Get-GitHubActionsInput`
- `Get-GitHubActionsIsDebug`
- `Get-GitHubActionsState`
- `Get-GitHubActionsWebhookEventPayload`
- `Remove-GitHubActionsProblemMatcher`
- `Set-GitHubActionsOutput`
- `Set-GitHubActionsState`
- `Test-GitHubActionsEnvironment`
- `Write-GitHubActionsAnnotation`
- `Write-GitHubActionsCommand`
- `Write-GitHubActionsDebug`
- `Write-GitHubActionsError`
- `Write-GitHubActionsFail`
- `Write-GitHubActionsNotice`
- `Write-GitHubActionsWarning`

### Example (Excerpt)

```ps1
Set-GitHubActionsOutput -Name 'foo' -Value 'bar'
#=> ::set-output name=foo::bar
```
