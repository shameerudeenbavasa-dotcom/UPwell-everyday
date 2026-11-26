@echo off
schtasks /Delete /F /TN "UpwellEveryday"
schtasks /Delete /F /TN "UpwellEverydayLogon"
rmdir /S /Q "%APPDATA%\UpwellEveryday"
echo Uninstalled.
pause
