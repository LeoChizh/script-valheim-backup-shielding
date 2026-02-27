@echo off
REM Run Valheim backup script with timestamp

set SCRIPT_PATH=C:\Path\To\get_valheim_backup.ps1
set LOG_FILE=C:\ValheimBackups\backup.log

REM Add entry with timestamp at the BEGINNING of the file
(
    echo ===== %date% %time% =====
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
    echo.
) > "%LOG_FILE%.tmp" 2>&1

REM Append old log content after new entry
type "%LOG_FILE%" >> "%LOG_FILE%.tmp" 2>nul

REM Replace old log with new one
move /y "%LOG_FILE%.tmp" "%LOG_FILE%" >nul
