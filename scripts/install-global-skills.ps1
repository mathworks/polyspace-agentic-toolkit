# install-global-skills.ps1 — Create symlinks/junctions for Polyspace skills in ~/.agents/skills/
# Usage: powershell -ExecutionPolicy Bypass -File scripts\install-global-skills.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillsCatalog = Join-Path $RepoRoot "skills-catalog"

if (-not (Test-Path $SkillsCatalog)) {
    Write-Error "Error: skills-catalog not found at $SkillsCatalog"
    exit 1
}

# Try ~/.agents/skills/ first, fall back to ~/.copilot/skills/
$SkillsDir = Join-Path $HOME ".agents" "skills"
try {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
} catch {
    $SkillsDir = Join-Path $HOME ".copilot" "skills"
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

Write-Host "Installing Polyspace skills to $SkillsDir"

# Create symlinks/junctions for each skill group
foreach ($GroupDir in Get-ChildItem -Path $SkillsCatalog -Directory) {
    $GroupName = $GroupDir.Name
    $LinkName = "polyspace-$GroupName"
    $LinkPath = Join-Path $SkillsDir $LinkName

    if (Test-Path $LinkPath) {
        Remove-Item $LinkPath -Force -Recurse
    }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $GroupDir.FullName | Out-Null
    } catch {
        # Fall back to junction if symlink requires admin
        cmd /c mklink /J "$LinkPath" "$($GroupDir.FullName)" | Out-Null
    }
    Write-Host "  Linked: $LinkName -> $($GroupDir.FullName)"
}

Write-Host "Done. Skills installed to $SkillsDir"
