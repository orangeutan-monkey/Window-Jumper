param (
    [switch]$Release = $false,
    [switch]$Installer = $false,
    [switch]$Clean = $false
)

# Configuration
$projectName = "Window Jumper"
$configuration = if ($Release) { "Release" } else { "Debug" }
$frameworkVersion = "net472" # Using .NET Framework 4.7.2 based on App.config
$webView2InstallerUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
$webView2InstallerPath = ".\Installer\MicrosoftEdgeWebView2Setup.exe"
$wixToolsetPath = "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin"

# Display build info
Write-Host "Window Jumper Build Script" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan
Write-Host "Configuration: $configuration" -ForegroundColor Cyan
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning project..." -ForegroundColor Yellow
    
    if (Test-Path ".\bin") {
        Remove-Item -Path ".\bin" -Recurse -Force
    }
    
    if (Test-Path ".\obj") {
        Remove-Item -Path ".\obj" -Recurse -Force
    }
    
    Write-Host "Clean completed." -ForegroundColor Green
}

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow

# Check if MSBuild is available
$msBuildPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path $msBuildPath)) {
    $msBuildPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
}
if (-not (Test-Path $msBuildPath)) {
    $msBuildPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
}
if (-not (Test-Path $msBuildPath)) {
    $msBuildPath = "MSBuild.exe" # Try to use MSBuild from PATH
}

# Restore NuGet packages
Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
nuget restore "$projectName.sln"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Package restoration failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Build the solution
& $msBuildPath "$projectName.sln" /p:Configuration=$configuration /p:Platform="Any CPU" /t:Rebuild

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Build completed successfully." -ForegroundColor Green

# Check for WebView2 installer if building installer
if ($Installer -and $Release) {
    if (-not (Test-Path $webView2InstallerPath)) {
        Write-Host "Downloading WebView2 Bootstrapper..." -ForegroundColor Yellow
        
        # Create Installer directory if it doesn't exist
        if (-not (Test-Path ".\Installer")) {
            New-Item -ItemType Directory -Path ".\Installer" | Out-Null
        }
        
        # Download the installer
        try {
            Invoke-WebRequest -Uri $webView2InstallerUrl -OutFile $webView2InstallerPath -UseBasicParsing
        }
        catch {
            Write-Host "Failed to download WebView2 installer: $_" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "WebView2 Bootstrapper downloaded successfully." -ForegroundColor Green
    }
}

# Create installer if requested
if ($Installer -and $Release) {
    Write-Host "Building WiX installer..." -ForegroundColor Yellow
    
    # Check if WiX tools are installed
    if (-not (Test-Path $wixToolsetPath)) {
        Write-Host "WiX Toolset not found at expected location: $wixToolsetPath" -ForegroundColor Red
        Write-Host "Please install WiX Toolset v3.11 or ensure it's in your PATH." -ForegroundColor Red
        exit 1
    }
    
    # Add WiX to PATH temporarily
    $env:PATH = "$wixToolsetPath;$env:PATH"
    
    # Check for banner and dialog images
    if (-not (Test-Path ".\Resources\banner.bmp") -or -not (Test-Path ".\Resources\dialog.bmp")) {
        Write-Host "Creating placeholder installer images..." -ForegroundColor Yellow
        
        # Create Resources directory if it doesn't exist
        if (-not (Test-Path ".\Resources")) {
            New-Item -ItemType Directory -Path ".\Resources" | Out-Null
        }
        
        # Create placeholder images if not present
        if (-not (Test-Path ".\Resources\banner.bmp")) {
            # Create a simple 493×58 bitmap for the banner
            try {
                # Load System.Drawing assembly for bitmap creation
                Add-Type -AssemblyName System.Drawing
                
                $bannerBmp = New-Object System.Drawing.Bitmap 493, 58
                $graphics = [System.Drawing.Graphics]::FromImage($bannerBmp)
                $graphics.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::LightGray)), 0, 0, 493, 58)
                $font = New-Object System.Drawing.Font("Arial", 16)
                $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
                $graphics.DrawString("Window Jumper", $font, $brush, 10, 15)
                $bannerBmp.Save(".\Resources\banner.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
                $graphics.Dispose()
                $bannerBmp.Dispose()
            }
            catch {
                Write-Host "Failed to create banner image: $_" -ForegroundColor Yellow
                Write-Host "Please create banner.bmp (493×58) manually in the Resources folder." -ForegroundColor Yellow
            }
        }
        
        if (-not (Test-Path ".\Resources\dialog.bmp")) {
            # Create a simple 493×312 bitmap for the dialog
            try {
                $dialogBmp = New-Object System.Drawing.Bitmap 493, 312
                $graphics = [System.Drawing.Graphics]::FromImage($dialogBmp)
                $graphics.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::LightGray)), 0, 0, 493, 312)
                $font = New-Object System.Drawing.Font("Arial", 20)
                $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
                $graphics.DrawString("Window Jumper", $font, $brush, 20, 40)
                $font = New-Object System.Drawing.Font("Arial", 12)
                $graphics.DrawString("A lightweight hidden web browser for Windows", $font, $brush, 20, 80)
                $dialogBmp.Save(".\Resources\dialog.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
                $graphics.Dispose()
                $dialogBmp.Dispose()
            }
            catch {
                Write-Host "Failed to create dialog image: $_" -ForegroundColor Yellow
                Write-Host "Please create dialog.bmp (493×312) manually in the Resources folder." -ForegroundColor Yellow
            }
        }
    }
    
    # Check for License.rtf
    if (-not (Test-Path ".\Installer\License.rtf")) {
        Write-Host "Creating license file..." -ForegroundColor Yellow
        
        # Create Installer directory if it doesn't exist
        if (-not (Test-Path ".\Installer")) {
            New-Item -ItemType Directory -Path ".\Installer" | Out-Null
        }
        
        # Create a simple license file
        $licenseContent = @'
{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}
{\*\generator Riched20 10.0.19041}\viewkind4\uc1 
\pard\sa200\sl276\slmult1\qc\b\f0\fs28\lang9 WINDOW JUMPER LICENSE AGREEMENT\par
\pard\sa200\sl276\slmult1\b0\fs22 MIT License\par
\par
Copyright (c) 2025 Your Name\par
\par
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\par
\par
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\par
\par
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\par
\par
\b DISCLAIMER\b0\par
\par
This application is for educational purposes only. Some exam proctoring software may consider this type of application to be against their terms of service. Use responsibly and at your own risk.\par
\par
By installing this software, you acknowledge that you have read and understood this license agreement and disclaimer, and you agree to be bound by their terms.\par
}
'@
        Set-Content -Path ".\Installer\License.rtf" -Value $licenseContent
    }
    
    # Create a simple README.md if it doesn't exist
    if (-not (Test-Path ".\README.md")) {
        Write-Host "Creating README file..." -ForegroundColor Yellow
        
        $readmeContent = @'
# Window Jumper

A lightweight background web browser for Windows that can be toggled with customizable keyboard shortcuts.

## Features

- Runs as a background process with minimal UI
- Can be hidden and shown with keyboard shortcuts (default: Ctrl+Alt+J)
- Includes system tray integration
- Persists user settings between sessions

## Requirements

- Windows 10 or later
- .NET Framework 4.7.2
- Microsoft Edge WebView2 Runtime

## Usage

Press Ctrl+Alt+J (or your custom hotkey) to show/hide the browser window.

## Settings

Access the settings through the gear icon in the browser or the system tray menu to customize:
- Homepage
- Window size
- Toggle keyboard shortcut
- Startup behavior
'@
        Set-Content -Path ".\README.md" -Value $readmeContent
    }
    
    # Create the WiX source files
    Write-Host "Compiling WiX source..." -ForegroundColor Yellow
    candle.exe -nologo .\Installer\WindowJumper.wxs `
        -dConfiguration=$configuration `
        -dProjectDir=. `
        -out .\bin\$configuration\WindowJumper.wixobj
        
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WiX compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
    # Create the installer
    Write-Host "Creating MSI installer..." -ForegroundColor Yellow
    light.exe -nologo .\bin\$configuration\WindowJumper.wixobj `
        -out .\bin\$configuration\WindowJumper.msi `
        -ext WixUIExtension
        
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WiX linking failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
    Write-Host "Installer created at: .\bin\$configuration\WindowJumper.msi" -ForegroundColor Green
}

Write-Host "Build process completed successfully!" -ForegroundColor Green

# Launch the application if in Debug mode and not building installer
if (-not $Release -and -not $Installer) {
    Write-Host "Launching application..." -ForegroundColor Yellow
    Start-Process ".\bin\$configuration\$projectName.exe"
}