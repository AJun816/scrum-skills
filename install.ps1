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
  $knownAgents = @(".claude", ".codex", ".warp", ".cursor", ".windsurf", ".cline", ".continue")
  $targetBase = ""

  foreach ($knownAgent in $knownAgents) {
    $agentPath = Join-Path $homeDir $knownAgent
    if ($scriptDir.StartsWith($agentPath, [System.StringComparison]::OrdinalIgnoreCase)) {
      $targetBase = $agentPath
      break
    }
  }

  if (-not $targetBase) {
    $agentName = $Agent.TrimStart(".")
    if (-not $agentName) { $agentName = "claude" }
    $targetBase = Join-Path $homeDir ".$agentName"
  }
}

$skillsSrc = Join-Path $scriptDir "skills"
$settingsSrc = Join-Path $scriptDir ".claude\settings.json"
$skillsDst = Join-Path $targetBase "skills"
$settingsDst = Join-Path $targetBase "settings.json"
$hooksDstUnix = ((Join-Path $targetBase "skills\hooks") -replace "\\", "/")
$targetKind = Split-Path -Leaf $targetBase
$supportsClaudeSettings = $targetKind -eq ".claude"

if (-not (Test-Path $skillsSrc)) {
  throw "skills directory not found: $skillsSrc"
}

Write-Host ""
Write-Host "=== Scrum Skills Installer (Windows) ==="
Write-Host "Source : $scriptDir"
Write-Host "Target : $targetBase"
Write-Host "Agent  : $($targetKind.TrimStart('.'))"
Write-Host ""

New-Item -ItemType Directory -Force -Path $targetBase | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null

Copy-Item -Path (Join-Path $skillsSrc "*") -Destination $skillsDst -Recurse -Force
Remove-Item -Path (Join-Path $skillsDst ".cache") -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $skillsDst -Filter ".DS_Store" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host "[OK] skills installed: $skillsDst"

if ($supportsClaudeSettings -and (Test-Path $settingsSrc)) {
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
} else {
  Write-Host "[INFO] skip settings.json deployment for $($targetKind.TrimStart('.')) target"
  Write-Host "       Claude hooks are only auto-configured when installing to ~/.claude"
}

Write-Host ""
Write-Host "[OK] Installation complete."
Write-Host "No extra environment required."
Write-Host ""
if ($supportsClaudeSettings) {
  Write-Host "Next:"
  Write-Host "  Open your project with Claude Code and use /0-emperor or /0-scrum-master"
} else {
  Write-Host "Next:"
  Write-Host "  Open your project with your agent and invoke 0-emperor / 0-scrum-master from the installed skill pack"
}
Write-Host "Optional:"
Write-Host "  For project harness init / repo-map in a repository:"
$hooksSetupPath = ((Join-Path $targetBase "skills\hooks\setup.sh") -replace "\\", "/")
Write-Host "  sh $hooksSetupPath --project-root=/path/to/repo"
Write-Host ""
