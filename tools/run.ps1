param([string]$Godot = '', [switch]$Editor)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
if (!$Godot) { $Godot = Join-Path $taskRoot '.tools/godot/Godot_v4.5.2-stable_win64.exe' }
if (!(Test-Path -LiteralPath $Godot)) { throw 'Godot not found. Run tools/setup.ps1 or pass -Godot with an executable path.' }
$taskArgs = @('--path', $taskRoot)
if ($Editor) { $taskArgs += '--editor' }
& $Godot @taskArgs

