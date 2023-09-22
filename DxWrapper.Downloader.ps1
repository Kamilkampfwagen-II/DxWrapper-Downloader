$mainRepo = 'elishacloud/dxwrapper'
$workflow = 'ci'
$branch = 'master'
$fileName = 'Release binaries.zip' # '%20

$items = @(
    './temp/Build/Stub' # directory
    './temp/Build/dxwrapper.dll'
    './temp/Build/AllSettings.ini'
)

$ErrorActionPreference = 'Stop'

Write-Host 'DxWrapper Downloader'
Write-Host 'This script is not affiliated with the DxWrapper project by elishacloud' -ForegroundColor Red
Write-Host ''

New-Item -Path "$PSScriptRoot/dxwrapper/temp" -ItemType Directory -Force | Out-Null
Set-Location "$PSScriptRoot/dxwrapper"

Write-Host 'Downloading latest artifact from ' -NoNewline
Write-Host 'elishacloud/dxwrapper' -ForegroundColor Blue
$progressPreference = 'SilentlyContinue'
$dxwrapperNightly = "https://nightly.link/$mainRepo/workflows/$workflow/$branch/$fileName"
Invoke-WebRequest -Uri $dxwrapperNightly -OutFile './temp/dxwrapper.zip' -UseBasicParsing
$progressPreference = 'Continue'

Write-Host 'Extracting the archive..'
Expand-Archive -Path './temp/dxwrapper.zip' -DestinationPath './temp' -Force

Write-Host 'Moving files around..'
Move-Item -Path $items -Destination '.' -Force
Rename-Item -Path './AllSettings.ini' -NewName './dxwrapper.ini' -Force

Write-Host 'Cleaning up..'
Remove-Item -Path './temp' -Recurse -Force

Write-Host 'Done!' -ForegroundColor Green
Read-Host -Prompt 'Press enter to open up the dxwrapper folder'
& explorer.exe .