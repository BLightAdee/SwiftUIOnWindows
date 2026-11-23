<#
.SYNOPSIS
    Automated Build & Run script for SwiftUI on Windows
.DESCRIPTION
    Detects Visual Studio Build Tools, Swift Toolchain, handles network drive staging,
    compiles the SwiftUIOnWindows demo executable, and launches the native Win32 app.
#>

param(
    [switch]$Run = $true,
    [switch]$Clean = $false
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       SwiftUI on Windows - Automated Build & Run         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Locate Visual Studio Environment
$vsPaths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1",
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Launch-VsDevShell.ps1",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1"
)

$vsDevShell = $vsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $vsDevShell) {
    Write-Error "Visual Studio 2022 Build Tools not found! Please install 'Desktop development with C++'."
    exit 1
}

Write-Host "[1/5] Initializing Visual Studio Build Environment..." -ForegroundColor Yellow
& $vsDevShell -Arch amd64 -HostArch amd64 | Out-Null

# 2. Locate Swift Toolchain & Runtimes
$swiftBase = "$env:LOCALAPPDATA\Programs\Swift"
if (-not (Test-Path $swiftBase)) {
    $swiftBase = "C:\Program Files\Swift"
}

$toolchains = Get-ChildItem -Path "$swiftBase\Toolchains" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
$runtimes = Get-ChildItem -Path "$swiftBase\Runtimes" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
$platforms = Get-ChildItem -Path "$swiftBase\Platforms" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending

if (-not $toolchains -or -not $runtimes) {
    Write-Error "Swift toolchain not found under $swiftBase! Please install Swift 6.0+ for Windows."
    exit 1
}

$swiftBin = "$($toolchains[0].FullName)\usr\bin"
$runtimeBin = "$($runtimes[0].FullName)\usr\bin"
$manifestBin = "$($toolchains[0].FullName)\usr\lib\swift\pm\ManifestAPI"
$sdk = "$($platforms[0].FullName)\Windows.platform\Developer\SDKs\Windows.sdk"

$env:SDKROOT = $sdk
$env:Path = "$swiftBin;$runtimeBin;$manifestBin;$env:Path"

Write-Host "[2/5] Configured Swift Toolchain ($($toolchains[0].Name))." -ForegroundColor Yellow

# 3. Check for Network Drive / UNC path
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) { $scriptRoot = Get-Location }

$isNetworkDrive = $scriptRoot.StartsWith("\\") -or (Get-PSDrive ($scriptRoot.Substring(0,1))).DisplayRoot
$localWorkDir = $scriptRoot

if ($isNetworkDrive) {
    Write-Host "[3/5] Network Drive detected ($scriptRoot)." -ForegroundColor Magenta
    Write-Host "      Swift compiler requires local filesystem to prevent silent hangs." -ForegroundColor Magenta
    $localWorkDir = "$env:USERPROFILE\swiftOnWindows"
    Write-Host "      Staging sources locally to: $localWorkDir" -ForegroundColor Magenta
    
    if (-not (Test-Path $localWorkDir)) {
        New-Item -ItemType Directory -Path $localWorkDir -Force | Out-Null
    }
    
    Copy-Item -Path "$scriptRoot\Package.swift" -Destination $localWorkDir -Force
    Copy-Item -Path "$scriptRoot\Sources" -Destination $localWorkDir -Recurse -Force
} else {
    Write-Host "[3/5] Building directly on local drive ($scriptRoot)..." -ForegroundColor Yellow
}

# 4. Compile with Swift Build
Write-Host "[4/5] Compiling SwiftUIOnWindows (SwiftUIDemo.exe)..." -ForegroundColor Yellow
Push-Location $localWorkDir

if ($Clean -and (Test-Path ".build")) {
    Remove-Item -Recurse -Force ".build"
}

& "$swiftBin\swift.exe" build -c debug
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

$exePath = Join-Path $localWorkDir ".build\out\Products\Debug-windows-x86_64\SwiftUIDemo.exe"
if (-not (Test-Path $exePath)) {
    # Fallback search
    $exeFound = Get-ChildItem -Path "$localWorkDir\.build" -Filter "SwiftUIDemo.exe" -Recurse | Select-Object -First 1
    if ($exeFound) { $exePath = $exeFound.FullName }
}

Pop-Location

# Copy binary to convenient local bin/ directory
$outputBinDir = Join-Path $scriptRoot "bin"
if (-not (Test-Path $outputBinDir)) { New-Item -ItemType Directory -Path $outputBinDir -Force | Out-Null }
$targetExe = Join-Path $outputBinDir "SwiftUIDemo.exe"
Copy-Item -Path $exePath -Destination $targetExe -Force

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host " Executable: $targetExe" -ForegroundColor Green
Write-Host " Size: $([math]::Round((Get-Item $targetExe).Length / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "----------------------------------------------------------" -ForegroundColor Green

# 5. Launch App
if ($Run) {
    Write-Host "[5/5] Launching SwiftUIDemo.exe..." -ForegroundColor Cyan
    $env:Path = "$runtimeBin;$env:Path"
    Start-Process -FilePath $targetExe
}
