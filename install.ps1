param(
  [string]$Agent = "claude",
  [string]$Target = "",
  [switch]$KeepSettings
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { $HOME }
if (-not $homeDir) { throw "Cannot determine home directory." }

if ($Target) {
  $targetBase = $Target
} else {
  $agentName = $Agent.TrimStart(".")
  if (-not $agentName) { $agentName = "claude" }
  $targetBase = Join-Path $homeDir ".$agentName"
}

$skillsSrc = Join-Path $scriptDir "skills"
$settingsSrc = Join-Path $scriptDir ".claude\settings.json"
$skillsDst = Join-Path $targetBase "skills"
$settingsDst = Join-Path $targetBase "settings.json"
$hooksDstUnix = ((Join-Path $targetBase "skills\hooks") -replace "\\", "/")

if (-not (Test-Path $skillsSrc)) {
  throw "skills directory not found: $skillsSrc"
}

Write-Host ""
Write-Host "=== Scrum Skills Installer (Windows) ==="
Write-Host "Source : $scriptDir"
Write-Host "Target : $targetBase"
Write-Host ""

New-Item -ItemType Directory -Force -Path $targetBase | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null

Copy-Item -Path (Join-Path $skillsSrc "*") -Destination $skillsDst -Recurse -Force
Write-Host "[OK] skills installed: $skillsDst"

if (Test-Path $settingsSrc) {
  if ((Test-Path $settingsDst) -and $KeepSettings.IsPresent) {
    Write-Host "[WARN] keep existing settings: $settingsDst"
    Write-Host "       existing hook paths are not rewritten in KeepSettings mode."
  } else {
    if (Test-Path $settingsDst) {
      $ts = Get-Date -Format "yyyyMMddHHmmss"
      $backup = "$settingsDst.$ts.bak"
      Copy-Item -Path $settingsDst -Destination $backup -Force
      Write-Host "[INFO] settings backup: $backup"
    }
    $settingsContent = Get-Content -Raw -Path $settingsSrc
    $settingsContent = $settingsContent.Replace(".claude/skills/hooks", $hooksDstUnix)
    Set-Content -Path $settingsDst -Value $settingsContent -Encoding UTF8
    Write-Host "[OK] settings installed: $settingsDst"
  }
}

Write-Host ""
Write-Host "[OK] Installation complete."
Write-Host "No extra environment required."
Write-Host ""
Write-Host "Optional:"
Write-Host "  For git commit-msg hook in a repository:"
$hooksSetupPath = ((Join-Path $targetBase "skills\hooks\setup.sh") -replace "\\", "/")
Write-Host "  sh $hooksSetupPath --project-root=/path/to/repo"
Write-Host ""
