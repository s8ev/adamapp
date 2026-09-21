param([string]$Godot = '')
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
if (!$Godot) { $Godot = Join-Path $taskRoot '.tools/godot/Godot_v4.5.2-stable_win64_console.exe' }
if (!(Test-Path -LiteralPath $Godot)) { throw 'Run tools/setup.ps1 first, or supply -Godot.' }
$taskVersion = & $Godot --version
if ($taskVersion -notmatch '^4\.5\.2\.stable') { throw "Unexpected engine: $taskVersion" }
New-Item -ItemType Directory -Force -Path (Join-Path $taskRoot 'artifacts/qa') | Out-Null
$taskChecks = @(
    @{ Name = 'import'; Args = @('--headless', '--path', $taskRoot, '--editor', '--import', '--quit') },
    @{ Name = 'foundation'; Args = @('--headless', '--path', $taskRoot, '--script', 'res://tests/test_foundation.gd', '--', '--qa-isolation') },
    @{ Name = 'boot'; Args = @('--headless', '--path', $taskRoot, '--', '--smoke', '--qa-isolation') }
)
foreach ($taskCheck in $taskChecks) {
    $taskArgs = $taskCheck.Args
    $taskOutput = & $Godot @taskArgs 2>&1
    $taskCode = $LASTEXITCODE
    $taskOutput | Out-File -LiteralPath (Join-Path $taskRoot ('artifacts/qa/' + $taskCheck.Name + '.log')) -Encoding utf8
    $taskOutput | Write-Output
    if ($taskCode -ne 0 -or ($taskOutput -join "`n") -match '(SCRIPT ERROR:|ERROR:|FAIL:)') { throw "Failed: $($taskCheck.Name)" }
}
Write-Output 'PASS: All foundation checks.'

