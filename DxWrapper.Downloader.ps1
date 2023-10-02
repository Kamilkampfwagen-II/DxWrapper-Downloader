$mainRepo = 'elishacloud/dxwrapper'
$workflow = 'ci'
$branch = 'master'
$fileName = 'Release binaries' # %20

$itemTable = @{
    './temp/Build/Stub' = '.' # directory
    './temp/Build/dxwrapper.dll' = './dxwrapper.dll'
    './temp/Build/AllSettings.ini' = './dxwrapper.ini'
}


$ErrorActionPreference = 'Inquire'

Write-Host 'DxWrapper Downloader'
Write-Host 'This script is dependant on the nightly.link project by oprypin'
Write-Host 'This script is not affiliated with the DxWrapper project by elishacloud' -ForegroundColor Red
Write-Host ''


New-Item -Path "$PSScriptRoot/dxwrapper/temp" -ItemType Directory -Force | Out-Null
Set-Location "$PSScriptRoot/dxwrapper"


# Remove any possible leftovers to prevent stupid Powershell cmdlets from failing
Remove-Item -Path './temp/*' -Recurse -Force -ErrorAction Ignore


$currentRun = Get-Content './version.txt' -ErrorAction Ignore
Write-Host 'Fetching the latest build info..'
$progressPreference = 'SilentlyContinue'
$nightlyInfo = Invoke-WebRequest -Uri "https://nightly.link/$mainRepo/workflows/$workflow/$branch/$fileName" -UseBasicParsing
$progressPreference = 'Continue'
$latestRun = $nightlyInfo.Links[2].href.Split('/')[7]
if ($currentRun -eq $latestRun) {
    Write-Host 'Up to date!' -ForegroundColor Green
    Read-Host -Prompt 'Press enter to open up the DxWrapper folder'
    & explorer.exe .
    exit
} else {
    Write-Host 'A new build is available: ' -NoNewline
    Write-Host $latestRun -ForegroundColor Blue
}


Write-Host 'Downloading the latest build from ' -NoNewline
Write-Host 'elishacloud/dxwrapper' -ForegroundColor Blue
$progressPreference = 'SilentlyContinue'
$dxwrapperNightly = "https://nightly.link/$mainRepo/workflows/$workflow/$branch/$fileName.zip"
Invoke-WebRequest -Uri $dxwrapperNightly -OutFile './temp/dxwrapper.zip' -UseBasicParsing
$progressPreference = 'Continue'


Write-Host 'Extracting the archive..'
Add-Type -Assembly 'System.IO.Compression.Filesystem'
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PSScriptRoot/dxwrapper/temp/dxwrapper.zip", "$PSScriptRoot/dxwrapper/temp")


Remove-Item -Path './Stub' -Recurse -Force -ErrorAction Ignore
foreach ($key in $itemTable.Keys) {
    Write-Host "Moving $key to $($itemTable[$key])"
    Move-Item -Path $key -Destination $itemTable[$key] -Force
}


Write-Host 'Updating version info..'
Set-Content -Path './version.txt' -Value $latestRun -Force


Write-Host 'Cleaning up..'
Remove-Item -Path './temp' -Recurse -Force


Write-Host 'Done!' -ForegroundColor Green
Read-Host -Prompt 'Press enter to open up the dxwrapper folder'
& explorer.exe .