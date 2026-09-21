param([string]$Version = '4.5.2')
$ErrorActionPreference = 'Stop'
if ($Version -ne '4.5.2') { throw 'This project is validated on Godot 4.5.2. Change the pin through a reviewed upgrade.' }
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskTools = Join-Path $taskRoot '.tools/godot'
New-Item -ItemType Directory -Force -Path $taskTools | Out-Null
$taskName = "Godot_v$Version-stable_win64.exe.zip"
$taskRelease = "https://github.com/godotengine/godot-builds/releases/download/$Version-stable"
$taskArchive = Join-Path $taskTools $taskName
Invoke-WebRequest -UseBasicParsing -Uri "$taskRelease/SHA512-SUMS.txt" -OutFile (Join-Path $taskTools 'SHA512-SUMS.txt')
Invoke-WebRequest -UseBasicParsing -Uri "$taskRelease/$taskName" -OutFile $taskArchive
$taskHash = (Get-FileHash -Algorithm SHA512 -LiteralPath $taskArchive).Hash.ToLower()
$taskManifest = Get-Content -LiteralPath (Join-Path $taskTools 'SHA512-SUMS.txt')
$taskExpected = (($taskManifest | Where-Object { $_ -match ('\s' + [regex]::Escape($taskName) + '$') }) -split '\s+')[0]
if (!$taskExpected -or $taskHash -ne $taskExpected) { throw 'SHA512 verification failed. Archive was not extracted.' }
Expand-Archive -LiteralPath $taskArchive -DestinationPath $taskTools -Force
New-Item -ItemType File -Force -Path (Join-Path $taskTools '_sc_') | Out-Null
Write-Output "Godot $Version installed and SHA512 verified. Run tools/run.ps1."

