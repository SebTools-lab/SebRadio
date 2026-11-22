# Tworzy build\Install-SebRadio.ps1: szablon + pliki programu zakodowane w Base64.
# Creates build\Install-SebRadio.ps1: template + program files encoded as Base64.
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$src     = Join-Path (Split-Path -Parent $here) 'src'
$version = ([IO.File]::ReadAllText((Join-Path $here 'version.txt'))).Trim()
$files   = [ordered]@{
    'SebRadio.exe'                = Join-Path $here 'SebRadio.exe'
    'SebRadio.ico'                = Join-Path $src 'SebRadio.ico'
    'Uninstall.ps1'               = Join-Path $src 'Uninstall.ps1'
    'LICENSE-shazam-for-real.txt' = Join-Path $src 'LICENSE-shazam-for-real.txt'
}
$lines = foreach ($k in $files.Keys) {
    $p = $files[$k]
    if (-not (Test-Path -LiteralPath $p)) { throw "Brak pliku / missing file: $p" }
    "    '$k' = '" + [Convert]::ToBase64String([IO.File]::ReadAllBytes($p)) + "'"
}
$t   = [IO.File]::ReadAllText((Join-Path $here 'Install-SebRadio.template.ps1'))
$out = $t.Replace('__FILES__', ($lines -join "`r`n")).Replace('__VERSION__', $version)
[IO.File]::WriteAllText((Join-Path $here 'Install-SebRadio.ps1'), $out, (New-Object System.Text.UTF8Encoding $true))
Write-Host "Install-SebRadio.ps1 $version - OK" -ForegroundColor Green
