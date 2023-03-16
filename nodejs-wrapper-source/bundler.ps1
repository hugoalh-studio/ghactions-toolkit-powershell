[String]$WrapperInputRoot = $PSScriptRoot
[String]$WrapperInputPackageFileName = 'package.json'
[String]$WrapperInputPackageLockFileName = 'pnpm-lock.yaml'
[String]$WrapperInputScriptFileName = 'main.js'
[String]$WrapperOutputRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\hugoalh.GitHubActionsToolkit\module\nodejs-wrapper'
[String]$WrapperOutputBundledFileName = 'bundled.js'
[String]$WrapperOutputUnbundledFileName = 'unbundled.js'

<# Clean up or initialize output directory. #>
If (Test-Path -LiteralPath $WrapperOutputRoot -PathType 'Container') {
	Get-ChildItem -LiteralPath $WrapperOutputRoot -Recurse |
		Remove-Item -Confirm
}
Else {
	$Null = New-Item -Path $WrapperOutputRoot -ItemType 'Directory'
}

<# Create bundled wrapper. #>
[String]$CurrentWorkingRoot = Get-Location |
	Select-Object -ExpandProperty 'Path'
[String]$WrapperOutputRootResolve = $WrapperOutputRoot |
	Resolve-Path |
	Select-Object -ExpandProperty 'Path' -First 1
Set-Location -LiteralPath $WrapperInputRoot
Try {
	Invoke-Expression -Command ".\node_modules\.bin\ncc.ps1 build main.js --out `"$WrapperOutputRootResolve`" --no-cache --no-source-map-register --target es2020"
}
Catch {
	Write-Error -Message $_
}
Finally {
	Set-Location -LiteralPath $CurrentWorkingRoot
}

<# Resolve bundler rubbish. #>
ForEach ($Item In (Get-ChildItem -LiteralPath $WrapperOutputRoot -Recurse)) {
	If ($Item.Name -ieq 'index.js') {
		Rename-Item -LiteralPath $Item.FullName -NewName (Join-Path -Path $Item.Directory -ChildPath $WrapperOutputBundledFileName) -Confirm
	}
	Else {
		$Item |
			Remove-Item -Confirm
	}
}

<# Create unbundled wrapper. #>
Copy-Item -LiteralPath (Join-Path -Path $WrapperInputRoot -ChildPath $WrapperInputScriptFileName) -Destination (Join-Path -Path $WrapperOutputRoot -ChildPath $WrapperOutputUnbundledFileName) -Confirm
Copy-Item -LiteralPath (Join-Path -Path $WrapperInputRoot -ChildPath $WrapperInputPackageLockFileName) -Destination (Join-Path -Path $WrapperOutputRoot -ChildPath $WrapperInputPackageLockFileName) -Confirm
[Hashtable]$PackageMeta = Get-Content -LiteralPath (Join-Path -Path $WrapperInputRoot -ChildPath $WrapperInputPackageFileName) |
	ConvertFrom-Json -AsHashtable -Depth 100 -NoEnumerate
$PackageMeta.Remove('devDependencies')
$PackageMeta.name = "$($PackageMeta.name)-distribution"
Set-Content -LiteralPath (Join-Path -Path $WrapperOutputRoot -ChildPath $WrapperInputPackageFileName) -Value (
	$PackageMeta |
		ConvertTo-Json -Depth 100 -Compress
) -Confirm
