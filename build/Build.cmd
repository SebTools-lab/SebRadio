@echo off
rem SebRadio: kompilacja programu i instalatora / builds the program and the installer
cd /d "%~dp0"
set /p VER=<"%~dp0version.txt"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-Module -ListAvailable ps2exe)) { Install-Module ps2exe -Scope CurrentUser -Force }"
rem 1) SebRadio.exe
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-ps2exe -inputFile '%~dp0..\src\SebRadio.ps1' -outputFile '%~dp0SebRadio.exe' -iconFile '%~dp0..\src\SebRadio.ico' -noConsole -STA -x64 -title 'SebRadio' -product 'SebRadio' -company 'Sebarkh' -description 'Internet radio player' -version '%VER%.0.0'"
if errorlevel 1 goto :end
if exist "E:\SebarkhCert\Sign.ps1" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "E:\SebarkhCert\Sign.ps1" "%~dp0SebRadio.exe"
rem 2) instalator / installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Make-Installer.ps1"
if errorlevel 1 goto :end
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-ps2exe -inputFile '%~dp0Install-SebRadio.ps1' -outputFile '%~dp0SebRadio-Setup.exe' -iconFile '%~dp0..\src\SebRadio.ico' -noConsole -STA -x64 -title 'SebRadio Setup' -product 'SebRadio' -company 'Sebarkh' -description 'SebRadio Setup' -version '%VER%.0.0'"
if exist "E:\SebarkhCert\Sign.ps1" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "E:\SebarkhCert\Sign.ps1" "%~dp0SebRadio-Setup.exe"
:end
if /i not "%1"=="nopause" pause
