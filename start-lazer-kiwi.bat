@echo off
set "PROJECT_DIR=%~dp0"
set "PORT=5173"
set "URL=http://localhost:%PORT%"

:: Check if the dev server is already running
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%PORT% ^| findstr LISTENING') do (
  for /f "tokens=1" %%b in ('tasklist /FI "PID eq %%a" /NH') do (
    if not "%%b"=="INFO:" (
      echo Dev server already running on port %PORT%
      start "" "%URL%"
      exit /b
    )
  )
)

:: Not running — start it
echo Starting dev server...
cd /d "%PROJECT_DIR%"
start "" cmd /k "npm run dev"
timeout /t 2 > nul
start "" "%URL%"
