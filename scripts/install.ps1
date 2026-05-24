$ErrorActionPreference = "Stop"

$Editor = if ($env:FUSION_SETTING_EDITOR) {
    $env:FUSION_SETTING_EDITOR
} else {
    Write-Host "Choose an editor:"
    Write-Host "  1) VS Code"
    Write-Host "  2) Cursor"
    Write-Host "  3) Windsurf"
    Write-Host "  4) Antigravity"
    $Choice = Read-Host "Enter a number [1-4]"

    switch ($Choice) {
        "1" { "vscode" }
        "2" { "cursor" }
        "3" { "windsurf" }
        "4" { "antigravity" }
        default { throw "Invalid choice: $Choice" }
    }
}

$RepoUrl = if ($env:FUSION_SETTING_REPO_URL) {
    $env:FUSION_SETTING_REPO_URL
} else {
    "https://github.com/tmoroney/fusion-setting-highlighter"
}

$Ref = if ($env:FUSION_SETTING_REF) {
    $env:FUSION_SETTING_REF
} else {
    "master"
}

$ExtensionDirName = "fusion-setting"

if (@("vscode", "cursor", "windsurf", "antigravity") -notcontains $Editor) {
    throw "Unknown editor: $Editor. Use vscode, cursor, windsurf, or antigravity."
}

$InstallDir = switch ($Editor) {
    "vscode" { Join-Path $env:USERPROFILE ".vscode\extensions\$ExtensionDirName" }
    "cursor" { Join-Path $env:USERPROFILE ".cursor\extensions\$ExtensionDirName" }
    "windsurf" { Join-Path $env:USERPROFILE ".windsurf\extensions\$ExtensionDirName" }
    "antigravity" { Join-Path $env:APPDATA "Antigravity\extensions\$ExtensionDirName" }
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("fusion-setting-" + [System.Guid]::NewGuid())
$ArchivePath = Join-Path $TempDir "source.zip"
$ArchiveUrl = "$RepoUrl/archive/refs/heads/$Ref.zip"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Write-Host "Downloading $ArchiveUrl"
    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ArchivePath

    Expand-Archive -Path $ArchivePath -DestinationPath $TempDir -Force
    $SourceDir = Get-ChildItem -Path $TempDir -Directory | Select-Object -First 1

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Copy-Item -Path (Join-Path $SourceDir.FullName "package.json") -Destination (Join-Path $InstallDir "package.json") -Force
    Copy-Item -Path (Join-Path $SourceDir.FullName "language-configuration.json") -Destination (Join-Path $InstallDir "language-configuration.json") -Force

    $SyntaxesDir = Join-Path $InstallDir "syntaxes"
    if (Test-Path $SyntaxesDir) {
        Remove-Item -Path $SyntaxesDir -Recurse -Force
    }
    Copy-Item -Path (Join-Path $SourceDir.FullName "syntaxes") -Destination $SyntaxesDir -Recurse -Force

    Write-Host "Installed Fusion Setting to $InstallDir"
    Write-Host "Restart your editor, then open a .setting file."
} finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}
