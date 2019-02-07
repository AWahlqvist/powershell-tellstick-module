<#
    To publish after build:
    Publish-Module -Path $FullPublishPath -NuGetApiKey $NuGetApiKey -Repository PSGallery
#>

$ScriptRoot = $PSScriptRoot

$ReleaseNotes = "New functions for getting schedules/events, a generic function to call any endpoint and a function that can take a backup. Other various enhancements."
$ModuleName = 'AutomaTD'
$ModuleVersion = '1.4.0'
$CompatiblePSEditions = @('Core', 'Desktop')
$PowerShellVersion = '5.1'
$ModuleGuid = '7acb0966-268a-4bd9-8ce8-c546db8aa696'
$Author = 'Anders Wahlqvist'
$CompanyName = 'DollarUnderscore'
$Description = 'A module that can interact Telldus Live!'
$ProjectUri = 'https://github.com/AWahlqvist/powershell-tellstick-module'
$LicenseUri = 'https://github.com/AWahlqvist/powershell-tellstick-module/blob/master/LICENSE.txt'

$ModuleToBuild = @{
    Name = $ModuleName
    Directory = Join-Path -Path $ScriptRoot -ChildPath .\source
    Fullname = Join-Path -Path $ScriptRoot -ChildPath ".\source\$ModuleName.psd1"
}

$ManifestExportPath = ''

# Make sure we have the latest version of the module loaded in memory
Get-Module $ModuleToBuild.Name | Remove-Module -Force
Import-Module $ModuleToBuild.FullName -Verbose:$false


Write-Output "Preparing $ModuleName..."

$PreparedModulePath = Join-Path -Path $ScriptRoot -ChildPath "Release\$($ModuleToBuild.Name)"
$PublishModulePath = Join-Path -Path $ScriptRoot -ChildPath "Publish\"

if (Test-Path $PreparedModulePath) {
    Remove-Item $PreparedModulePath -Recurse -Force
}

$null = New-Item -Path $PreparedModulePath -ItemType Directory -Force
$null = New-Item -Path $PublishModulePath -ItemType Directory -Force

Get-ChildItem -Path $ModuleToBuild.Directory | Copy-Item -Destination $PreparedModulePath -Force -Recurse
    
$ModuleFile = Get-ChildItem -Path $PreparedModulePath -Include *.psm1 -Recurse
$ManifestFile = Get-ChildItem -Path $PreparedModulePath -Include *.psd1 -Recurse

$FunctionFiles = @( Get-ChildItem -Path "$($ModuleToBuild.Directory)\Private\*.ps1" -ErrorAction Stop)
$PublicFunctions = Get-ChildItem -Path "$($ModuleToBuild.Directory)\Public\*.ps1" -ErrorAction Stop
$FunctionFiles += $PublicFunctions

$ModuleCode = $FunctionFiles | Get-Content

[System.IO.File]::WriteAllLines($ModuleFile.FullName, $ModuleCode)

$ManifestCreationParams = @{
    RootModule = "$ModuleName.psm1"
    ModuleVersion = $ModuleVersion
    CompatiblePSEditions = $CompatiblePSEditions
    Guid = $ModuleGuid
    Author = $Author
    Description = $Description
    CompanyName = $CompanyName
    Copyright = "(c) $((Get-Date).Year) $Author. All rights reserved."
    PowerShellVersion = $PowerShellVersion
    FunctionsToExport = $PublicFunctions.BaseName
    ReleaseNotes = $ReleaseNotes
    ProjectUri = $ProjectUri
    LicenseUri = $LicenseUri
    Path = $ManifestFile.FullName
}

New-ModuleManifest @ManifestCreationParams

Get-ChildItem -Path $PreparedModulePath -Recurse | Where-Object { $_.FullName -match '\\Tests|\\Public|\\Private|\\TestResources'} | Remove-Item -Force -Recurse

Get-ChildItem -Path $PublishModulePath -Recurse | Remove-Item -Force -Recurse

Copy-Item -Path $PreparedModulePath -Destination $PublishModulePath -Recurse

$ZipArhive = Join-Path -Path $ScriptRoot -ChildPath "Release\$($ModuleToBuild.Name).$ModuleVersion.zip"

Compress-Archive -Path $PreparedModulePath -DestinationPath $ZipArhive -Force

Remove-Item -Path $PreparedModulePath -Force -Recurse

$ModuleToPublish = Join-Path -Path $PublishModulePath -ChildPath $ModuleName

$FullPublishPath = Join-Path -Path $PublishModulePath -ChildPath $ModuleName