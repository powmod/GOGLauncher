@echo off
setlocal

:: Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

:: Change to script directory to ensure query.sql is found
cd /d "%SCRIPT_DIR%"

:: Check if sqlite3.exe exists in script directory
if exist "%SCRIPT_DIR%sqlite3.exe" (
    "%SCRIPT_DIR%sqlite3.exe" "%~1" < "%SCRIPT_DIR%query.sql" > "%SCRIPT_DIR%GameData.txt"
) else (
    :: Try system PATH
    sqlite3.exe "%~1" < "%SCRIPT_DIR%query.sql" > "%SCRIPT_DIR%GameData.txt"
)

endlocal