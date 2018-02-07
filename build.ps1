$ScriptRoot = $PSScriptRoot

$ModuleToBuild = @{
    Name = 'AutomaTD'
    Directory = Join-Path -Path $ScriptRoot -ChildPath .\source
    Fullname = Join-Path -Path $ScriptRoot -ChildPath .\source\AutomaTD.psd1
}

# Make sure we have the latest version of the module loaded in memory
Get-Module $ModuleToBuild.Name | Remove-Module -Force
Import-Module $ModuleToBuild.FullName -Verbose:$false
$ModuleInfo = Get-Module $ModuleToBuild.Name


Write-Output "Preparing $($ModuleInfo.Name)..."

$PreparedModulePath = Join-Path -Path $ScriptRoot -ChildPath "Release\$($ModuleToBuild.Name)"

if (Test-Path $PreparedModulePath) {
    Remove-Item $PreparedModulePath -Recurse -Force
}

$null = New-Item -Path $PreparedModulePath -ItemType Directory -Force

Get-ChildItem -Path $ModuleToBuild.Directory | Copy-Item -Destination $PreparedModulePath -Force -Recurse
    
$ModuleFile = Get-ChildItem -Path $PreparedModulePath -Include *.psm1 -Recurse

$FunctionFiles = @( Get-ChildItem -Path "$($ModuleToBuild.Directory)\Private\*.ps1" -ErrorAction Stop)
$FunctionFiles += Get-ChildItem -Path "$($ModuleToBuild.Directory)\Public\*.ps1" -ErrorAction Stop

$ModuleCode = $FunctionFiles | Get-Content

[System.IO.File]::WriteAllLines($ModuleFile.FullName, $ModuleCode)

Get-ChildItem -Path $PreparedModulePath -Recurse | Where-Object { $_.FullName -match '\\Tests|\\Public|\\Private|\\TestResources'} | Remove-Item -Force -Recurse

$ZipArhive = Join-Path -Path $ScriptRoot -ChildPath "Release\$($ModuleToBuild.Name).$($ModuleInfo.Version).zip"

Compress-Archive -Path $PreparedModulePath -DestinationPath $ZipArhive -Force

Remove-Item -Path $PreparedModulePath -Force -Recurse
