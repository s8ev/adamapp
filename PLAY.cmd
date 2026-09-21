@echo off
setlocal
if not exist "%~dp0.tools\godot\Godot_v4.5.2-stable_win64.exe" (
    echo Godot 4.5.2 is not installed in this folder.
    echo Run: powershell -ExecutionPolicy Bypass -File tools\setup.ps1
    pause
    exit /b 1
)
start "" "%~dp0.tools\godot\Godot_v4.5.2-stable_win64.exe" --path "%~dp0."
