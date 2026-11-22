Add-Type -AssemblyName System.Windows.Forms
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$lang = 'en'
try { $lang = [string](Get-Content (Join-Path $root 'install.json') -Raw -ErrorAction Stop | ConvertFrom-Json).Language } catch {}
$pl = ($lang -eq 'pl')

$q = if ($pl) { "Odinstalować SebRadio?`n`nZostaną usunięte skróty i wpis w Zainstalowanych aplikacjach." } else { "Uninstall SebRadio?`n`nShortcuts and the Installed apps entry will be removed." }
if ([System.Windows.Forms.MessageBox]::Show($q, 'SebRadio', 'YesNo', 'Question') -ne 'Yes') { exit }

Get-Process SebRadio -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path -like (Join-Path $root '*') } | Stop-Process -Force
foreach ($p in @(
    (Join-Path ([Environment]::GetFolderPath('Programs')) 'SebRadio.lnk'),
    (Join-Path ([Environment]::GetFolderPath('Desktop')) 'SebRadio.lnk'),
    (Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'SebRadio.lnk'))) {
    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }
}
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\SebRadio' -Recurse -Force -ErrorAction SilentlyContinue

$q2 = if ($pl) { "Usunąć też folder programu i ustawienia (ostatni link, głośność, zapisane stacje, historia utworów)?`n`n$root`n$env:APPDATA\SebRadio" } else { "Also delete the program folder and settings (last link, volume, saved stations, song history)?`n`n$root`n$env:APPDATA\SebRadio" }
if ([System.Windows.Forms.MessageBox]::Show($q2, 'SebRadio', 'YesNo', 'Question') -eq 'Yes') {
    Remove-Item (Join-Path $env:APPDATA 'SebRadio') -Recurse -Force -ErrorAction SilentlyContinue
    # folder kasuje osobny proces po zamknięciu tego skryptu / folder is removed by a separate process after this script ends
    Start-Process cmd.exe -ArgumentList "/c timeout /t 2 /nobreak >nul & rmdir /s /q `"$root`"" -WindowStyle Hidden
}
$done = if ($pl) { 'SebRadio odinstalowany.' } else { 'SebRadio has been uninstalled.' }
[void][System.Windows.Forms.MessageBox]::Show($done, 'SebRadio', 'OK', 'Information')
