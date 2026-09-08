# Copyright 2026 The MathWorks, Inc.
# install-global-skills.ps1 — Create symlinks/junctions for Polyspace skills in ~/.agents/skills/
# Usage: powershell -ExecutionPolicy Bypass -File scripts\install-global-skills.ps1 [group ...]
#   With no arguments, links every skill group in skills-catalog\.
#   With one or more group names (e.g. polyspace-core polyspace-code-prover),
#   links only those groups so users install only the skills they need.

param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Groups = @())

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

# Warn about any requested group that does not exist in the catalog (likely a typo).
foreach ($g in $Groups) {
    if (-not (Test-Path (Join-Path $SkillsCatalog $g))) {
        Write-Host "Warning: requested group '$g' not found in $SkillsCatalog — skipping"
    }
}

# Create flat per-skill symlinks so that each SKILL.md is at depth */SKILL.md
# (Gemini CLI discovers skills with a one-level-deep glob only).
foreach ($GroupDir in Get-ChildItem -Path $SkillsCatalog -Directory) {
    # Skip groups not in the allow-list (empty allow-list = all groups).
    if ($Groups.Count -gt 0 -and $Groups -notcontains $GroupDir.Name) { continue }

    # If the group itself has a SKILL.md, link it directly
    $DirectSkill = Join-Path $GroupDir.FullName "SKILL.md"
    if (Test-Path $DirectSkill) {
        $LinkName = $GroupDir.Name
        $LinkPath = Join-Path $SkillsDir $LinkName
        if (Test-Path $LinkPath) { Remove-Item $LinkPath -Force -Recurse }
        try {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $GroupDir.FullName | Out-Null
        } catch {
            cmd /c mklink /J "$LinkPath" "$($GroupDir.FullName)" | Out-Null
        }
        Write-Host "  Linked: $LinkName -> $($GroupDir.FullName)"
    }

    # Link each sub-skill individually
    foreach ($SkillDir in Get-ChildItem -Path $GroupDir.FullName -Directory) {
        $SkillFile = Join-Path $SkillDir.FullName "SKILL.md"
        if (-not (Test-Path $SkillFile)) { continue }
        $LinkName = $SkillDir.Name
        $LinkPath = Join-Path $SkillsDir $LinkName
        if (Test-Path $LinkPath) { Remove-Item $LinkPath -Force -Recurse }
        try {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $SkillDir.FullName | Out-Null
        } catch {
            cmd /c mklink /J "$LinkPath" "$($SkillDir.FullName)" | Out-Null
        }
        Write-Host "  Linked: $LinkName -> $($SkillDir.FullName)"
    }
}

Write-Host "Done. Skills installed to $SkillsDir"
