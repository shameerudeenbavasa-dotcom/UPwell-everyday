@echo off
REM Installs Upwell Everyday on Windows (runs at logon + every day at 07:00).
set "DIR=%APPDATA%\UpwellEveryday"
if not exist "%DIR%" mkdir "%DIR%"
copy /Y "%~dp0upwell_everyday.py" "%DIR%\" >nul
py -3 -m venv "%DIR%\venv" || python -m venv "%DIR%\venv"
"%DIR%\venv\Scripts\pip.exe" install -q --upgrade pip pillow
set "CMD=\"%DIR%\venv\Scripts\pythonw.exe\" \"%DIR%\upwell_everyday.py\""
schtasks /Create /F /TN "UpwellEveryday" /SC DAILY /ST 07:00 /TR "%CMD%" >nul
schtasks /Create /F /TN "UpwellEverydayLogon" /SC ONLOGON /TR "%CMD%" >nul
echo Installed. Fetching this week's wallpapers now...
"%DIR%\venv\Scripts\python.exe" "%DIR%\upwell_everyday.py"
pause
