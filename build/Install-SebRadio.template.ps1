param([switch]$Silent, [string]$Target, [ValidateSet('', 'pl', 'en')][string]$Lang = '')
# SebRadio - instalator / installer (szablon / template).
# Build.cmd -> Make-Installer.ps1 wstawia pliki programu (Base64), potem ps2exe kompiluje SebRadio-Setup.exe.
# -Silent [-Target <folder>] [-Lang pl|en] : instalacja bez okien / unattended install.
$Version = '__VERSION__'
$Files = @{
__FILES__
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TT = @{
pl = @{
    Title = "SebRadio $Version - instalator"
    Header = 'SebRadio - odtwarzacz radia internetowego z rozpoznawaniem utworów (Shazam).'
    Language = 'Język / Language:'
    Options = 'Opcje instalacji'; Folder = 'Folder:'; Browse = 'Zmień...'
    StartMenu = 'Skrót w menu Start'; Desktop = 'Skrót na pulpicie'
    Bass = 'Pobierz biblioteki BASS z un4seen.com (wymagane; darmowe do użytku niekomercyjnego)'
    Launch = 'Uruchom SebRadio po instalacji'
    Install = 'Zainstaluj'; Close = 'Zamknij'; Finish = 'Zakończ'
    FolderDesc = 'Folder instalacji SebRadio'
    LFolder = 'Folder: '; LFile = '  plik: '; LBass = 'Pobieranie bibliotek BASS...'; LBassOk = '  pobrano: '; LBassHave = '  już jest: '
    LBassErr = '  BŁĄD pobierania: '; LShort = 'Skróty...'; LReg = 'Wpis w Zainstalowanych aplikacjach...'; LDone = 'Gotowe.'; LErr = 'BŁĄD: '
    LStop = 'Zamykanie działającego SebRadio...'
    Done = 'SebRadio jest zainstalowany. Uruchomisz go z menu Start.'
    DoneNoBass = "SebRadio jest zainstalowany.`n`nBiblioteki BASS nie zostały pobrane - SebRadio zaproponuje ich pobranie przy pierwszym uruchomieniu."
    Desc = 'Odtwarzacz radia internetowego'
}
en = @{
    Title = "SebRadio $Version - setup"
    Header = 'SebRadio - internet radio player with song recognition (Shazam).'
    Language = 'Język / Language:'
    Options = 'Install options'; Folder = 'Folder:'; Browse = 'Change...'
    StartMenu = 'Start menu shortcut'; Desktop = 'Desktop shortcut'
    Bass = 'Download the BASS libraries from un4seen.com (required; free for non-commercial use)'
    Launch = 'Launch SebRadio after installation'
    Install = 'Install'; Close = 'Close'; Finish = 'Finish'
    FolderDesc = 'SebRadio install folder'
    LFolder = 'Folder: '; LFile = '  file: '; LBass = 'Downloading BASS libraries...'; LBassOk = '  downloaded: '; LBassHave = '  already present: '
    LBassErr = '  download ERROR: '; LShort = 'Shortcuts...'; LReg = 'Installed apps entry...'; LDone = 'Done.'; LErr = 'ERROR: '
    LStop = 'Closing running SebRadio...'
    Done = 'SebRadio is installed. Start it from the Start menu.'
    DoneNoBass = "SebRadio is installed.`n`nThe BASS libraries were not downloaded - SebRadio will offer to download them on first launch."
    Desc = 'Internet radio player'
}
}

$RegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\SebRadio'

function Get-DefaultTarget {
    if ($Target) { return $Target }
    $loc = (Get-ItemProperty $RegKey -ErrorAction SilentlyContinue).InstallLocation
    if ($loc) { return $loc }
    if (Test-Path 'E:\Programs') { return 'E:\Programs\SebRadio' }
    Join-Path $env:LOCALAPPDATA 'Programs\SebRadio'
}

function Get-DefaultLang {
    if ($Lang) { return $Lang }
    try { $l = (Get-Content (Join-Path $env:APPDATA 'SebRadio\lang.txt') -Raw -ErrorAction Stop).Trim(); if ($l -in 'pl', 'en') { return $l } } catch {}
    if ([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq 'pl') { 'pl' } else { 'en' }
}

function New-Shortcut([string]$Path, [string]$Exe, [string]$Desc) {
    $sh = New-Object -ComObject WScript.Shell
    $s = $sh.CreateShortcut($Path)
    $s.TargetPath = $Exe
    $s.WorkingDirectory = Split-Path $Exe
    $s.IconLocation = "$Exe,0"
    $s.Description = $Desc
    $s.Save()
}

function Install-App([string]$Dir, [string]$L, [bool]$Start, [bool]$Desk, [bool]$Bass, [scriptblock]$Log) {
    $T = $TT[$L]
    & $Log ($T.LFolder + $Dir)
    $running = Get-Process SebRadio -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path -like (Join-Path $Dir '*') }
    if ($running) { & $Log $T.LStop; $running | Stop-Process -Force; Start-Sleep -Milliseconds 700 }

    New-Item -ItemType Directory -Path $Dir, (Join-Path $Dir 'lib') -Force | Out-Null
    foreach ($rel in $Files.Keys) {
        [IO.File]::WriteAllBytes((Join-Path $Dir $rel), [Convert]::FromBase64String($Files[$rel]))
        & $Log ($T.LFile + $rel)
    }
    @{ Language = $L; Version = $Version; StartMenu = $Start; Desktop = $Desk } | ConvertTo-Json |
        Set-Content -LiteralPath (Join-Path $Dir 'install.json') -Encoding UTF8
    $cfg = Join-Path $env:APPDATA 'SebRadio'
    New-Item -ItemType Directory -Path $cfg -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $cfg 'lang.txt') -Value $L -Encoding ASCII

    $bassOk = $true
    if ($Bass) {
        & $Log $T.LBass
        $pk = [ordered]@{
            'bass.dll'     = 'https://www.un4seen.com/files/bass24.zip'
            'bass_aac.dll' = 'https://www.un4seen.com/files/z/2/bass_aac24.zip'
            'basshls.dll'  = 'https://www.un4seen.com/files/basshls24.zip'
        }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        foreach ($dll in $pk.Keys) {
            $out = Join-Path $Dir "lib\$dll"
            if (Test-Path -LiteralPath $out) { & $Log ($T.LBassHave + $dll); continue }
            $tmp = Join-Path $env:TEMP ('SebRadioSetup_' + [guid]::NewGuid().ToString('N'))
            try {
                New-Item -ItemType Directory -Path $tmp -Force | Out-Null
                $zip = Join-Path $tmp 'p.zip'
                (New-Object Net.WebClient).DownloadFile($pk[$dll], $zip)
                [IO.Compression.ZipFile]::ExtractToDirectory($zip, (Join-Path $tmp 'x'))
                $f = Get-ChildItem (Join-Path $tmp 'x') -Recurse -Filter $dll | Where-Object { $_.DirectoryName -match '\\x64$' } | Select-Object -First 1
                if (-not $f) { throw "x64 $dll ?" }
                Copy-Item $f.FullName $out -Force
                & $Log ($T.LBassOk + $dll)
            }
            catch { $bassOk = $false; & $Log ($T.LBassErr + "$dll - $($_.Exception.Message)") }
            finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
        }
    } else { $bassOk = $false }

    & $Log $T.LShort
    $exe = Join-Path $Dir 'SebRadio.exe'
    $startLnk = Join-Path ([Environment]::GetFolderPath('Programs')) 'SebRadio.lnk'
    $deskLnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'SebRadio.lnk'
    $commonLnk = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'SebRadio.lnk'
    if (Test-Path -LiteralPath $commonLnk) { Remove-Item -LiteralPath $commonLnk -Force -ErrorAction SilentlyContinue }
    if ($Start) { New-Shortcut $startLnk $exe $T.Desc } elseif (Test-Path $startLnk) { Remove-Item $startLnk -Force }
    if ($Desk) { New-Shortcut $deskLnk $exe $T.Desc } elseif (Test-Path $deskLnk) { Remove-Item $deskLnk -Force }

    & $Log $T.LReg
    New-Item -Path $RegKey -Force | Out-Null
    $un = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $Dir 'Uninstall.ps1') + '"'
    $size = [int]((Get-ChildItem $Dir -Recurse -File | Measure-Object Length -Sum).Sum / 1KB)
    $props = @{ DisplayName = 'SebRadio'; DisplayVersion = $Version; Publisher = 'Sebarkh'; DisplayIcon = "$exe,0"
                InstallLocation = $Dir; UninstallString = $un; URLInfoAbout = 'https://github.com/SebTools-lab/SebRadio' }
    foreach ($k in $props.Keys) { Set-ItemProperty -Path $RegKey -Name $k -Value $props[$k] }
    Set-ItemProperty -Path $RegKey -Name EstimatedSize -Value $size -Type DWord
    Set-ItemProperty -Path $RegKey -Name NoModify -Value 1 -Type DWord
    Set-ItemProperty -Path $RegKey -Name NoRepair -Value 1 -Type DWord
    & $Log $T.LDone
    $bassOk
}

# ---------------------------------------------------------------- tryb cichy / silent
if ($Silent) {
    $dir = Get-DefaultTarget
    $o = @{ StartMenu = $true; Desktop = $false }
    try { $j = Get-Content (Join-Path $dir 'install.json') -Raw -ErrorAction Stop | ConvertFrom-Json; foreach ($k in 'StartMenu', 'Desktop') { if ($null -ne $j.$k) { $o[$k] = [bool]$j.$k } } } catch {}
    $L = Get-DefaultLang
    $logFile = Join-Path $env:TEMP 'SebRadio-install.log'
    [void](Install-App $dir $L $o.StartMenu $o.Desktop $true { param($m) Add-Content -LiteralPath $logFile -Value $m -Encoding UTF8 })
    exit 0
}

# ---------------------------------------------------------------- okno / window
$script:L = Get-DefaultLang
$f = New-Object System.Windows.Forms.Form
$f.Font = New-Object System.Drawing.Font('Segoe UI', 9)
try { $f.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) } catch {}
$f.ClientSize = New-Object System.Drawing.Size(600, 470)
$f.StartPosition = 'CenterScreen'; $f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false

$hdr = New-Object System.Windows.Forms.Label
$hdr.Location = New-Object System.Drawing.Point(15, 14); $hdr.Size = New-Object System.Drawing.Size(570, 20)

$lLang = New-Object System.Windows.Forms.Label
$lLang.Location = New-Object System.Drawing.Point(15, 46); $lLang.AutoSize = $true
$cLang = New-Object System.Windows.Forms.ComboBox
$cLang.DropDownStyle = 'DropDownList'; $cLang.Location = New-Object System.Drawing.Point(130, 42); $cLang.Width = 140
[void]$cLang.Items.AddRange(@('Polski', 'English'))

$gOpt = New-Object System.Windows.Forms.GroupBox
$gOpt.Location = New-Object System.Drawing.Point(15, 76); $gOpt.Size = New-Object System.Drawing.Size(570, 165)
$lDir = New-Object System.Windows.Forms.Label; $lDir.Location = New-Object System.Drawing.Point(12, 28); $lDir.Size = New-Object System.Drawing.Size(55, 20)
$tDir = New-Object System.Windows.Forms.TextBox; $tDir.Location = New-Object System.Drawing.Point(70, 25); $tDir.Size = New-Object System.Drawing.Size(380, 24); $tDir.Text = Get-DefaultTarget
$bDir = New-Object System.Windows.Forms.Button; $bDir.Location = New-Object System.Drawing.Point(460, 23); $bDir.Size = New-Object System.Drawing.Size(98, 28)
$cStart = New-Object System.Windows.Forms.CheckBox; $cStart.Location = New-Object System.Drawing.Point(12, 60); $cStart.Size = New-Object System.Drawing.Size(545, 24); $cStart.Checked = $true
$cDesk = New-Object System.Windows.Forms.CheckBox; $cDesk.Location = New-Object System.Drawing.Point(12, 84); $cDesk.Size = New-Object System.Drawing.Size(545, 24)
$cBass = New-Object System.Windows.Forms.CheckBox; $cBass.Location = New-Object System.Drawing.Point(12, 108); $cBass.Size = New-Object System.Drawing.Size(545, 24); $cBass.Checked = $true
$cRun = New-Object System.Windows.Forms.CheckBox; $cRun.Location = New-Object System.Drawing.Point(12, 132); $cRun.Size = New-Object System.Drawing.Size(545, 24); $cRun.Checked = $true
$gOpt.Controls.AddRange(@($lDir, $tDir, $bDir, $cStart, $cDesk, $cBass, $cRun))

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true; $logBox.ReadOnly = $true; $logBox.ScrollBars = 'Vertical'
$logBox.Location = New-Object System.Drawing.Point(15, 250); $logBox.Size = New-Object System.Drawing.Size(570, 165); $logBox.Font = New-Object System.Drawing.Font('Consolas', 9)

$bInst = New-Object System.Windows.Forms.Button; $bInst.Location = New-Object System.Drawing.Point(375, 425); $bInst.Size = New-Object System.Drawing.Size(100, 32)
$bInst.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$bCancel = New-Object System.Windows.Forms.Button; $bCancel.Location = New-Object System.Drawing.Point(485, 425); $bCancel.Size = New-Object System.Drawing.Size(100, 32)
$f.Controls.AddRange(@($hdr, $lLang, $cLang, $gOpt, $logBox, $bInst, $bCancel))

function Set-Texts {
    $T = $TT[$script:L]
    $f.Text = $T.Title; $hdr.Text = $T.Header; $lLang.Text = $T.Language; $gOpt.Text = $T.Options
    $lDir.Text = $T.Folder; $bDir.Text = $T.Browse; $cStart.Text = $T.StartMenu; $cDesk.Text = $T.Desktop
    $cBass.Text = $T.Bass; $cRun.Text = $T.Launch; $bInst.Text = $T.Install
    if ($bCancel.Tag -eq 'done') { $bCancel.Text = $T.Finish } else { $bCancel.Text = $T.Close }
}
$cLang.SelectedIndex = $(if ($script:L -eq 'pl') { 0 } else { 1 })
$cLang.Add_SelectedIndexChanged({ $script:L = $(if ($cLang.SelectedIndex -eq 0) { 'pl' } else { 'en' }); Set-Texts })
Set-Texts

$LogFn = { param($m) $logBox.AppendText("$m`r`n"); [System.Windows.Forms.Application]::DoEvents() }
$bDir.Add_Click({
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    $d.Description = $TT[$script:L].FolderDesc
    if (Test-Path $tDir.Text) { $d.SelectedPath = $tDir.Text }
    if ($d.ShowDialog($f) -eq 'OK') {
        $p = $d.SelectedPath
        if ((Split-Path $p -Leaf) -ne 'SebRadio') { $p = Join-Path $p 'SebRadio' }
        $tDir.Text = $p
    }
})
$bCancel.Add_Click({ $f.Close() })
$bInst.Add_Click({
    $bInst.Enabled = $false; $gOpt.Enabled = $false; $cLang.Enabled = $false; $f.UseWaitCursor = $true
    $T = $TT[$script:L]
    $ok = $false; $bassOk = $false
    try { $bassOk = Install-App $tDir.Text $script:L $cStart.Checked $cDesk.Checked $cBass.Checked $LogFn; $ok = $true }
    catch { & $LogFn ($T.LErr + $_.Exception.Message) }
    $f.UseWaitCursor = $false
    $bCancel.Tag = 'done'; $bCancel.Text = $T.Finish
    if ($ok) {
        $msg = if ($bassOk) { $T.Done } else { $T.DoneNoBass }
        [void][System.Windows.Forms.MessageBox]::Show($f, $msg, 'SebRadio', 'OK', 'Information')
        if ($cRun.Checked) { Start-Process (Join-Path $tDir.Text 'SebRadio.exe'); $f.Close() }
    }
})
[void]$f.ShowDialog()
