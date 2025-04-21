@echo off
echo Window Jumper - Run Script
echo -------------------------------

:: Set the path to your solution file
set SOLUTION_FILE="Window Jumper.sln"

:: Check if NuGet exists
where nuget >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo NuGet command not found. Attempting to download NuGet.exe...
    powershell -Command "Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile nuget.exe"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to download NuGet.exe. Please download it manually.
        echo Visit: https://www.nuget.org/downloads
        pause
        exit /b 1
    )
    echo NuGet.exe downloaded successfully.
)

:: Restore NuGet packages
echo Restoring NuGet packages...
if exist nuget.exe (
    .\nuget.exe restore %SOLUTION_FILE%
) else (
    nuget restore %SOLUTION_FILE%
)

if %ERRORLEVEL% NEQ 0 (
    echo Failed to restore NuGet packages.
    echo Try opening the solution in Visual Studio and restoring packages there.
    pause
    exit /b 1
)

:: Build the solution
echo Building solution...
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" %SOLUTION_FILE% /p:Configuration=Release
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" %SOLUTION_FILE% /p:Configuration=Release
) else (
    echo MSBuild not found. Please build the solution in Visual Studio.
    pause
    exit /b 1
)

if %ERRORLEVEL% NEQ 0 (
    echo Build failed.
    pause
    exit /b 1
)

:: Run the application
echo Starting Window Jumper...
if exist "bin\Release\Window Jumper.exe" (
    start "" "bin\Release\Window Jumper.exe"
) else if exist "bin\Debug\Window Jumper.exe" (
    start "" "bin\Debug\Window Jumper.exe"
) else (
    echo Application executable not found.
    echo Check if the build was successful.
    pause
    exit /b 1
)

echo Done!
exit /b 0