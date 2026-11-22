# SebRadio 3.2 - prosty odtwarzacz radia internetowego / simple internet radio player (silnik/engine: BASS)
# Rozpoznawanie utworów: algorytm sygnatury Shazam przeniesiony z shazam-for-real (ISC License, Copyright (c) Aleksey Martynov)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) { $base = $PSScriptRoot } else { $base = Split-Path ([Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }
$lib = Join-Path $base 'lib'
$selfPath = $PSCommandPath
$cfgDir = Join-Path $env:APPDATA 'SebRadio'
$cfgFile = Join-Path $cfgDir 'ostatni.txt'
$volFile = Join-Path $cfgDir 'glosnosc.txt'
$trayFile = Join-Path $cfgDir 'zasobnik.txt'
$miniFile = Join-Path $cfgDir 'mini.txt'
$idFile = Join-Path $cfgDir 'shazam-id.txt'
$langFile = Join-Path $cfgDir 'lang.txt'
$stFile = Join-Path $cfgDir 'stacje.txt'
$ctFile = Join-Path $cfgDir 'kraje.txt'
$recFile = Join-Path $cfgDir 'wznawianie.txt'
$histFile = Join-Path $cfgDir 'historia.csv'
$histOptFile = Join-Path $cfgDir 'historia-stacje.txt'

# ---------- język / language ----------
$lang = ''
try { if (Test-Path $langFile) { $lang = (Get-Content $langFile -Raw).Trim().ToLower() } } catch {}
if (-not $lang) { try { $lang = [string](Get-Content (Join-Path $base 'install.json') -Raw -ErrorAction Stop | ConvertFrom-Json).Language } catch {} }
if ($lang -notin 'pl', 'en') { if ([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq 'pl') { $lang = 'pl' } else { $lang = 'en' } }
$TT = @{
pl = @{
    BassAsk = "SebRadio potrzebuje bibliotek BASS (un4seen.com, darmowe do użytku niekomercyjnego).`n`nBrakuje: {0}`n`nPobrać je teraz do folderu:`n{1} ?"
    BassFail = 'Nie udało się pobrać bibliotek BASS: '
    BassNo64 = 'W archiwum brak 64-bitowego pliku '
    LoadFail = 'Nie można załadować '
    InitFail = 'BASS_Init nie powiódł się, kod '
    E1 = 'brak pamięci'; E2 = 'nie można otworzyć adresu'; E8 = 'BASS nie zainicjowany'; E10 = 'brak obsługi HTTPS'
    E32 = 'brak połączenia z serwerem'; E40 = 'przekroczony czas połączenia'; E41 = 'nieobsługiwany format'
    E44 = 'brak kodeka dla tego formatu'; E48 = 'nieobsługiwany protokół'; ECode = 'kod'
    NoPlaylistUrl = 'Nie znaleziono adresu strumienia w playliście.'
    f_Status = 'Status'; f_Now = 'Teraz gra'; f_Station = 'Stacja'; f_Desc = 'Opis'; f_Genre = 'Gatunek'; f_Web = 'Strona WWW'
    f_Format = 'Format'; f_Bitrate = 'Bitrate'; f_Rate = 'Częstotliwość'; f_Chans = 'Kanały'; f_Server = 'Serwer'
    f_Url = 'Adres strumienia'; f_Start = 'Czas startu'; f_Time = 'Czas słuchania'
    NoTitle = '(stacja nie wysyła tytułów)'; NoTitleHls = '(strumień HLS nie podaje tytułów)'; Empty = '(brak)'
    Mono = 'mono'; Stereo = 'stereo'
    Stopped = 'Zatrzymany'; Connecting = 'Łączenie...'; ConnectingT = 'Łączenie... {0:N1} s'; Error = 'Błąd: '
    Playing = 'Gra'; Buffering = 'Buforowanie'; Paused = 'Pauza'; Ended = 'Zatrzymany (koniec strumienia lub zerwane połączenie)'; Ready = 'Gotowy'
    LinkLabel = 'Link do radia (strumień, .m3u8, .pls lub .m3u):'; PastePlay = 'Wklej i graj'; Play = 'Graj'; Stop = 'Stop'; Volume = 'Głośność:'
    ColInfo = 'Informacja'; ColValue = 'Wartość (dwuklik = kopiuj)'; Engine = 'Silnik'
    RecGroup = 'Rozpoznawanie utworu (Shazam)'; Recognize = 'Rozpoznaj utwór'; RecHint = 'Kliknij, gdy gra muzyka.'
    Artist = 'Wykonawca:'; Title = 'Tytuł:'; Copy = 'Kopiuj'; CopyAll = 'Kopiuj wykonawcę i tytuł'
    Copied = 'Skopiowano: '; TurnOn = 'Najpierw włącz radio.'; TooShort = 'Za mało dźwięku ({0:N0} s), poczekaj chwilę.'
    Recognizing = 'Rozpoznawanie...'; Recognized = 'Rozpoznano'; NotRecognized = 'Nie rozpoznano. Spróbuj za kilka sekund.'; Track = 'utwór'
    Mini = 'Mini odtwarzacz'; ToTray = 'Przycisk X chowa program do zasobnika (obok zegara)'; InTray = 'SebRadio działa dalej w zasobniku. Zamkniesz go prawym klikiem na ikonie -> Zamknij.'
    TrayShow = 'Pokaż SebRadio'; TrayExit = 'Zamknij'; MiniFull = 'Pełne okno'; MiniClose = 'Zamknij mini odtwarzacz'; NoStation = '(brak nazwy stacji)'
    OtherLang = 'English'; LangRestart = 'Język zostanie zmieniony po ponownym uruchomieniu SebRadio. Uruchomić ponownie teraz?'
    Stations = 'Moje stacje:'; Save = 'Zapisz'; Manage = 'Stacje...'; StationsMenu = 'Stacje'; NoStations = '(brak zapisanych stacji)'; ChooseStation = '(wybierz stację)'
    SaveTitle = 'Zapisz stację'; SavePrompt = 'Nazwa stacji:'; RenameTitle = 'Zmień nazwę'; AlreadySaved = 'Ta stacja jest już zapisana jako: '; NoUrl = 'Najpierw wpisz albo wklej link do stacji.'
    OK = 'OK'; Cancel = 'Anuluj'; Close = 'Zamknij'
    TabMine = 'Moje stacje'; TabSearch = 'Szukaj w internecie'; ColName = 'Nazwa'; ColLink = 'Link'
    PlaySel = 'Graj'; Rename = 'Zmień nazwę'; Delete = 'Usuń'; Up = 'W górę'; Down = 'W dół'; Import = 'Importuj...'; EditFile = 'Otwórz plik'
    DelAsk = 'Usunąć stację "{0}"?'; ImportDone = 'Dodano stacji: {0}. Pominięto (już zapisane): {1}.'
    ImportFilter = 'Listy stacji (*.m3u;*.m3u8;*.pls;*.txt)|*.m3u;*.m3u8;*.pls;*.txt|Wszystkie pliki (*.*)|*.*'
    SearchName = 'Nazwa:'; SearchCountry = 'Kraj:'; Search = 'Szukaj'; Searching = 'Szukanie...'; Found = 'Znaleziono: {0}'; NothingFound = 'Nic nie znaleziono.'; SearchErr = 'Błąd wyszukiwania: '
    SearchHint = 'Źródło: radio-browser.info (otwarta baza stacji). Dwuklik = posłuchaj.'; ColCountry = 'Kraj'; ColCodec = 'Format'; ColKbps = 'kbps'; ColTags = 'Tagi'
    Listen = 'Posłuchaj'; AddMine = 'Do moich stacji'; AddedMine = 'Zapisano: '
    Settings = 'Ustawienia...'; SetTitle = 'Ustawienia'; AutoReconnect = 'Automatycznie wznawiaj po zerwaniu połączenia'; LangLbl = 'Język:'; OpenCfg = 'Otwórz folder ustawień'
    Reconnecting = 'Ponowne łączenie za {0} s (próba {1})...'
    History = 'Historia...'; HistTitle = 'Historia utworów'; TrayHist = 'Historia utworów'; HSearch = 'Szukaj:'; HAll = 'Wszystkie'; HSrcShazam = 'Shazam'; HSrcStream = 'Ze stacji'
    HColTime = 'Kiedy'; HColArtist = 'Wykonawca'; HColTitle = 'Tytuł'; HColStation = 'Stacja'; HColSource = 'Źródło'; HCount = 'Pozycji: {0}'
    HCopy = 'Kopiuj'; HDelete = 'Usuń'; HClear = 'Wyczyść...'; HOpen = 'Otwórz w Excelu'; HClearAsk = 'Usunąć całą historię ({0} pozycji)?'; HDelAsk = 'Usunąć zaznaczone pozycje ({0})?'
    HLogStream = 'Zapisuj w historii tytuły podawane przez stację (nie tylko z Shazama)'; HHint = 'Dwuklik = YouTube. Plik: %AppData%\SebRadio\historia.csv'
    Sleep = 'Wyłącznik czasowy'; SleepLeft = 'Wyłącznik: {0}'; SleepOff = 'Wyłączony'; SleepMin = '{0} min'; SleepEnd = 'Wyłącznik czasowy zatrzymał radio.'
    FileHeader = @('# SebRadio - zapisane stacje', '# Jedna stacja w linii:  Nazwa = link', '# Możesz dopisać wiele stacji naraz i zapisać plik - SebRadio wczyta je samo.', '# Linie zaczynające się od # są pomijane. Program zapisuje ten plik na nowo przy zmianach w oknie Stacje.')
}
en = @{
    BassAsk = "SebRadio needs the BASS audio libraries (un4seen.com, free for non-commercial use).`n`nMissing: {0}`n`nDownload them now to:`n{1} ?"
    BassFail = 'Could not download the BASS libraries: '
    BassNo64 = 'The archive has no 64-bit '
    LoadFail = 'Cannot load '
    InitFail = 'BASS_Init failed, code '
    E1 = 'out of memory'; E2 = 'cannot open the address'; E8 = 'BASS not initialized'; E10 = 'HTTPS not supported'
    E32 = 'cannot connect to the server'; E40 = 'connection timed out'; E41 = 'unsupported format'
    E44 = 'no codec for this format'; E48 = 'unsupported protocol'; ECode = 'code'
    NoPlaylistUrl = 'No stream address found in the playlist.'
    f_Status = 'Status'; f_Now = 'Now playing'; f_Station = 'Station'; f_Desc = 'Description'; f_Genre = 'Genre'; f_Web = 'Website'
    f_Format = 'Format'; f_Bitrate = 'Bitrate'; f_Rate = 'Sample rate'; f_Chans = 'Channels'; f_Server = 'Server'
    f_Url = 'Stream address'; f_Start = 'Start time'; f_Time = 'Listening time'
    NoTitle = '(station sends no titles)'; NoTitleHls = '(HLS stream sends no titles)'; Empty = '(none)'
    Mono = 'mono'; Stereo = 'stereo'
    Stopped = 'Stopped'; Connecting = 'Connecting...'; ConnectingT = 'Connecting... {0:N1} s'; Error = 'Error: '
    Playing = 'Playing'; Buffering = 'Buffering'; Paused = 'Paused'; Ended = 'Stopped (end of stream or connection lost)'; Ready = 'Ready'
    LinkLabel = 'Radio link (stream, .m3u8, .pls or .m3u):'; PastePlay = 'Paste && play'; Play = 'Play'; Stop = 'Stop'; Volume = 'Volume:'
    ColInfo = 'Info'; ColValue = 'Value (double-click = copy)'; Engine = 'Engine'
    RecGroup = 'Song recognition (Shazam)'; Recognize = 'Recognize song'; RecHint = 'Click while music is playing.'
    Artist = 'Artist:'; Title = 'Title:'; Copy = 'Copy'; CopyAll = 'Copy artist and title'
    Copied = 'Copied: '; TurnOn = 'Start the radio first.'; TooShort = 'Not enough audio yet ({0:N0} s), wait a moment.'
    Recognizing = 'Recognizing...'; Recognized = 'Recognized'; NotRecognized = 'Not recognized. Try again in a few seconds.'; Track = 'track'
    Mini = 'Mini player'; ToTray = 'The X button hides the app to the tray (next to the clock)'; InTray = 'SebRadio keeps running in the tray. Right-click the icon -> Exit to quit.'
    TrayShow = 'Show SebRadio'; TrayExit = 'Exit'; MiniFull = 'Full window'; MiniClose = 'Close mini player'; NoStation = '(no station name)'
    OtherLang = 'Polski'; LangRestart = 'The language will change after SebRadio restarts. Restart now?'
    Stations = 'My stations:'; Save = 'Save'; Manage = 'Stations...'; StationsMenu = 'Stations'; NoStations = '(no saved stations)'; ChooseStation = '(choose a station)'
    SaveTitle = 'Save station'; SavePrompt = 'Station name:'; RenameTitle = 'Rename'; AlreadySaved = 'This station is already saved as: '; NoUrl = 'Type or paste a station link first.'
    OK = 'OK'; Cancel = 'Cancel'; Close = 'Close'
    TabMine = 'My stations'; TabSearch = 'Search the internet'; ColName = 'Name'; ColLink = 'Link'
    PlaySel = 'Play'; Rename = 'Rename'; Delete = 'Delete'; Up = 'Move up'; Down = 'Move down'; Import = 'Import...'; EditFile = 'Open file'
    DelAsk = 'Delete station "{0}"?'; ImportDone = 'Stations added: {0}. Skipped (already saved): {1}.'
    ImportFilter = 'Station lists (*.m3u;*.m3u8;*.pls;*.txt)|*.m3u;*.m3u8;*.pls;*.txt|All files (*.*)|*.*'
    SearchName = 'Name:'; SearchCountry = 'Country:'; Search = 'Search'; Searching = 'Searching...'; Found = 'Found: {0}'; NothingFound = 'Nothing found.'; SearchErr = 'Search error: '
    SearchHint = 'Source: radio-browser.info (open station database). Double-click = listen.'; ColCountry = 'Country'; ColCodec = 'Format'; ColKbps = 'kbps'; ColTags = 'Tags'
    Listen = 'Listen'; AddMine = 'Add to my stations'; AddedMine = 'Saved: '
    Settings = 'Settings...'; SetTitle = 'Settings'; AutoReconnect = 'Reconnect automatically when the connection drops'; LangLbl = 'Language:'; OpenCfg = 'Open settings folder'
    Reconnecting = 'Reconnecting in {0} s (attempt {1})...'
    History = 'History...'; HistTitle = 'Song history'; TrayHist = 'Song history'; HSearch = 'Search:'; HAll = 'All'; HSrcShazam = 'Shazam'; HSrcStream = 'Station'
    HColTime = 'When'; HColArtist = 'Artist'; HColTitle = 'Title'; HColStation = 'Station'; HColSource = 'Source'; HCount = 'Entries: {0}'
    HCopy = 'Copy'; HDelete = 'Delete'; HClear = 'Clear...'; HOpen = 'Open in Excel'; HClearAsk = 'Delete the whole history ({0} entries)?'; HDelAsk = 'Delete the selected entries ({0})?'
    HLogStream = 'Save song titles sent by the station to the history (not only Shazam)'; HHint = 'Double-click = YouTube. File: %AppData%\SebRadio\historia.csv'
    Sleep = 'Sleep timer'; SleepLeft = 'Sleep timer: {0}'; SleepOff = 'Off'; SleepMin = '{0} min'; SleepEnd = 'The sleep timer stopped the radio.'
    FileHeader = @('# SebRadio - saved stations', '# One station per line:  Name = link', '# You can add many stations at once and save the file - SebRadio picks them up automatically.', '# Lines starting with # are ignored. The program rewrites this file when you change stations in the Stations window.')
}
}
$T = $TT[$lang]
$F = @{ 'Status' = $T.f_Status; 'Teraz gra' = $T.f_Now; 'Stacja' = $T.f_Station; 'Opis' = $T.f_Desc; 'Gatunek' = $T.f_Genre; 'Strona WWW' = $T.f_Web
        'Format' = $T.f_Format; 'Bitrate' = $T.f_Bitrate; 'Częstotliwość' = $T.f_Rate; 'Kanały' = $T.f_Chans; 'Serwer' = $T.f_Server
        'Adres strumienia' = $T.f_Url; 'Czas startu' = $T.f_Start; 'Czas słuchania' = $T.f_Time }

function Show-Fatal([string]$msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, 'SebRadio', 'OK', 'Error') | Out-Null
    exit 1
}

$bassPkgs = [ordered]@{
    'bass.dll'     = 'https://www.un4seen.com/files/bass24.zip'
    'bass_aac.dll' = 'https://www.un4seen.com/files/z/2/bass_aac24.zip'
    'basshls.dll'  = 'https://www.un4seen.com/files/basshls24.zip'
}
$missing = @($bassPkgs.Keys | Where-Object { -not (Test-Path (Join-Path $lib $_)) })
if ($missing.Count -gt 0) {
    $msg = $T.BassAsk -f ($missing -join ', '), $lib
    $ans = [System.Windows.Forms.MessageBox]::Show($msg, 'SebRadio', 'YesNo', 'Question')
    if ($ans -ne 'Yes') { if ($missing -contains 'bass.dll') { exit 1 } }
    else {
        try {
            $tmp = Join-Path $env:TEMP ('SebRadio_bass_' + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Force $lib, $tmp | Out-Null
            foreach ($dll in $missing) {
                $zip = Join-Path $tmp ($dll + '.zip')
                $dst = Join-Path $tmp ($dll + '_x')
                (New-Object Net.WebClient).DownloadFile($bassPkgs[$dll], $zip)
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [IO.Compression.ZipFile]::ExtractToDirectory($zip, $dst)
                $f = Get-ChildItem $dst -Recurse -Filter $dll | Where-Object { $_.DirectoryName -match '\\x64$' } | Select-Object -First 1
                if (-not $f) { throw ($T.BassNo64 + $dll) }
                Copy-Item $f.FullName (Join-Path $lib $dll) -Force
            }
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
        catch { Show-Fatal ($T.BassFail + $_.Exception.Message) }
    }
}

if (-not ('SebShazam' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.IO;

[StructLayout(LayoutKind.Sequential)]
public struct BASS_CHANNELINFO {
    public int freq; public int chans; public int flags; public int ctype;
    public int origres; public int plugin; public int sample; public IntPtr filename;
}

public static class SebGeo {
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate bool GeoEnumProc(int geoId);
    [DllImport("kernel32.dll")] static extern bool EnumSystemGeoID(int geoClass, int parentGeoId, GeoEnumProc proc);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)] static extern int GetGeoInfo(int location, int geoType, StringBuilder data, int cch, int langId);
    static List<int> ids;
    static bool Collect(int id) { ids.Add(id); return true; }
    static string Info(int id, int type) {
        StringBuilder sb = new StringBuilder(256);
        int n = GetGeoInfo(id, type, sb, sb.Capacity, 0);
        return n > 0 ? sb.ToString() : null;
    }
    // [ISO2, nazwa w języku Windows / name in the Windows UI language]
    public static string[][] Countries() {
        ids = new List<int>();
        GeoEnumProc p = Collect;
        EnumSystemGeoID(16, 0, p);
        GC.KeepAlive(p);
        List<string[]> r = new List<string[]>();
        foreach (int id in ids) {
            string iso = Info(id, 4), name = Info(id, 8);
            if (!string.IsNullOrEmpty(iso) && iso.Length == 2 && !string.IsNullOrEmpty(name)) r.Add(new string[] { iso, name });
        }
        return r.ToArray();
    }
}

public static class SebWin {
    [DllImport("user32.dll")] public static extern bool ReleaseCapture();
    [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);
    public static void Drag(IntPtr hWnd) { ReleaseCapture(); SendMessage(hWnd, 0xA1, (IntPtr)2, IntPtr.Zero); }
}

public static class SebBass {
    [DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr LoadLibrary(string path);

    [DllImport("bass.dll")] public static extern bool BASS_Init(int device, int freq, int flags, IntPtr win, IntPtr guid);
    [DllImport("bass.dll")] public static extern bool BASS_Free();
    [DllImport("bass.dll")] public static extern int BASS_GetVersion();
    [DllImport("bass.dll")] public static extern bool BASS_SetConfig(int option, int value);
    [DllImport("bass.dll", CharSet = CharSet.Unicode)] public static extern bool BASS_SetConfigPtr(int option, string value);
    [DllImport("bass.dll", CharSet = CharSet.Unicode)] public static extern int BASS_PluginLoad(string file, int flags);
    [DllImport("bass.dll", CharSet = CharSet.Unicode)] public static extern int BASS_StreamCreateURL(string url, int offset, int flags, IntPtr proc, IntPtr user);
    [DllImport("bass.dll")] public static extern bool BASS_StreamFree(int handle);
    [DllImport("bass.dll")] public static extern long BASS_StreamGetFilePosition(int handle, int mode);
    [DllImport("bass.dll")] public static extern bool BASS_ChannelPlay(int handle, bool restart);
    [DllImport("bass.dll")] public static extern int BASS_ChannelIsActive(int handle);
    [DllImport("bass.dll")] public static extern bool BASS_ChannelSetAttribute(int handle, int attrib, float value);
    [DllImport("bass.dll")] public static extern bool BASS_ChannelGetAttribute(int handle, int attrib, out float value);
    [DllImport("bass.dll")] public static extern bool BASS_ChannelGetInfo(int handle, out BASS_CHANNELINFO info);
    [DllImport("bass.dll")] public static extern IntPtr BASS_ChannelGetTags(int handle, int tags);
    [DllImport("bass.dll")] public static extern int BASS_ErrorGetCode();

    static string Decode(byte[] b) {
        try { return new UTF8Encoding(false, true).GetString(b); }
        catch { return Encoding.GetEncoding(1250).GetString(b); }
    }
    static string ReadZ(IntPtr p, int offset, out int len) {
        int n = 0;
        while (Marshal.ReadByte(p, offset + n) != 0) n++;
        byte[] b = new byte[n];
        Marshal.Copy(IntPtr.Add(p, offset), b, 0, n);
        len = n;
        return Decode(b);
    }
    public static string GetTag(int handle, int tag) {
        IntPtr p = BASS_ChannelGetTags(handle, tag);
        if (p == IntPtr.Zero) return null;
        int n;
        return ReadZ(p, 0, out n);
    }
    public static string[] GetTagList(int handle, int tag) {
        List<string> l = new List<string>();
        IntPtr p = BASS_ChannelGetTags(handle, tag);
        if (p == IntPtr.Zero) return l.ToArray();
        int off = 0;
        while (Marshal.ReadByte(p, off) != 0 && off < 65536) {
            int n;
            l.Add(ReadZ(p, off, out n));
            off += n + 1;
        }
        return l.ToArray();
    }
}
// Port (C# 5 / .NET Framework) of the signature code from shazam-for-real
// https://github.com/AlekseyMartynov/shazam-for-real  (ISC License, Copyright (c) Aleksey Martynov)

public class SebPeak {
    public int StripeIndex;
    public float InterpolatedBin;
    public float LogMagnitude;
    public SebPeak(int s, float b, float m) { StripeIndex = s; InterpolatedBin = b; LogMagnitude = m; }
}

public static class SebShazam {
    public const int SAMPLE_RATE = 16000;
    const int CHUNK_SIZE = 128;
    const int WINDOW_SIZE = 2048;
    const int BIN_COUNT = WINDOW_SIZE / 2 + 1;
    const int H_STRIPE_DIST = 45, H_BIN_DIST = 1, V_STRIPE_DIST = 3, V_BIN_DIST = 10;
    static readonly int[] BAND_FREQS = { 250, 520, 1450, 3500, 5500 };
    static readonly float MIN_MAGN_SQUARED = 1f / 512 / 512;
    static readonly float LOG_MIN_MAGN_SQUARED = (float)Math.Log(1.0 / 512 / 512);

    static float[] hann;
    static int[] bitrev;
    static double[] cosT, sinT;

    static void Init() {
        if (hann != null) return;
        var h = new float[WINDOW_SIZE];
        for (int i = 0; i < WINDOW_SIZE; i++) h[i] = (float)(0.5 - 0.5 * Math.Cos(2 * Math.PI * i / (WINDOW_SIZE - 1)));
        int bits = 11;
        var br = new int[WINDOW_SIZE];
        for (int i = 0; i < WINDOW_SIZE; i++) {
            int r = 0, x = i;
            for (int b = 0; b < bits; b++) { r = (r << 1) | (x & 1); x >>= 1; }
            br[i] = r;
        }
        cosT = new double[WINDOW_SIZE / 2];
        sinT = new double[WINDOW_SIZE / 2];
        for (int i = 0; i < WINDOW_SIZE / 2; i++) {
            cosT[i] = Math.Cos(-2 * Math.PI * i / WINDOW_SIZE);
            sinT[i] = Math.Sin(-2 * Math.PI * i / WINDOW_SIZE);
        }
        bitrev = br;
        hann = h;
    }

    static void Fft(double[] re, double[] im) {
        int n = WINDOW_SIZE;
        for (int i = 0; i < n; i++) {
            int j = bitrev[i];
            if (j > i) {
                double t = re[i]; re[i] = re[j]; re[j] = t;
                t = im[i]; im[i] = im[j]; im[j] = t;
            }
        }
        for (int size = 2; size <= n; size <<= 1) {
            int half = size >> 1, step = n / size;
            for (int start = 0; start < n; start += size) {
                for (int k = 0; k < half; k++) {
                    double wr = cosT[k * step], wi = sinT[k * step];
                    int a = start + k, b = a + half;
                    double xr = re[b] * wr - im[b] * wi;
                    double xi = re[b] * wi + im[b] * wr;
                    re[b] = re[a] - xr; im[b] = im[a] - xi;
                    re[a] += xr; im[a] += xi;
                }
            }
        }
    }

    static int FreqToBin(float f) { return Convert.ToInt32(f * WINDOW_SIZE / SAMPLE_RATE); }
    static float BinToFreq(float bin) { return bin * SAMPLE_RATE / WINDOW_SIZE; }

    // samples: mono, 16000 Hz, range -1..1
    public static byte[] CreateSignature(float[] samples, out int sampleCount) {
        Init();
        int chunks = samples.Length / CHUNK_SIZE;
        sampleCount = chunks * CHUNK_SIZE;

        var stripes = new List<float[]>(chunks);
        var ring = new float[WINDOW_SIZE];
        var re = new double[WINDOW_SIZE];
        var im = new double[WINDOW_SIZE];
        int processed = 0;

        var bands = new List<SebPeak>[BAND_FREQS.Length - 1];
        for (int i = 0; i < bands.Length; i++) bands[i] = new List<SebPeak>();
        int minBin = Math.Max(FreqToBin(BAND_FREQS[0]), V_BIN_DIST);
        int maxBin = Math.Min(FreqToBin(BAND_FREQS[BAND_FREQS.Length - 1]), BIN_COUNT - V_BIN_DIST);

        for (int c = 0; c < chunks; c++) {
            int pos = processed % WINDOW_SIZE;
            Array.Copy(samples, c * CHUNK_SIZE, ring, pos, CHUNK_SIZE);
            processed += CHUNK_SIZE;
            if (processed < WINDOW_SIZE) continue;

            int ringPos = processed % WINDOW_SIZE;
            for (int i = 0; i < WINDOW_SIZE; i++) {
                re[i] = ring[(ringPos + i) % WINDOW_SIZE] * hann[i];
                im[i] = 0;
            }
            Fft(re, im);
            var stripe = new float[BIN_COUNT];
            for (int bin = 0; bin < BIN_COUNT; bin++)
                stripe[bin] = (float)(2 * (re[bin] * re[bin] + im[bin] * im[bin]));
            stripes.Add(stripe);

            if (stripes.Count > 2 * H_STRIPE_DIST) {
                int s = stripes.Count - H_STRIPE_DIST - 1;
                for (int bin = minBin; bin < maxBin; bin++) {
                    float center = stripes[s][bin];
                    if (center < MIN_MAGN_SQUARED) continue;
                    if (!IsPeak(stripes, s, bin, H_STRIPE_DIST, H_BIN_DIST, center)) continue;
                    if (!IsPeak(stripes, s, bin, V_STRIPE_DIST, V_BIN_DIST, center)) continue;

                    float alpha = LogMagn(stripes[s][bin - 1]);
                    float beta = LogMagn(center);
                    float gamma = LogMagn(stripes[s][bin + 1]);
                    float p = (alpha - gamma) / (alpha - 2 * beta + gamma) / 2;
                    if (float.IsNaN(p) || float.IsInfinity(p)) p = 0;
                    var peak = new SebPeak(s, bin + p, beta);

                    float freq = BinToFreq(peak.InterpolatedBin);
                    int band = -1;
                    if (freq >= BAND_FREQS[0]) {
                        for (int i = 1; i < BAND_FREQS.Length; i++) {
                            if (freq < BAND_FREQS[i]) { band = i - 1; break; }
                        }
                    }
                    if (band >= 0) bands[band].Add(peak);
                }
            }
        }

        // rate limit
        int allowed = 12 + stripes.Count / 12;
        foreach (var list in bands) {
            if (list.Count <= allowed) continue;
            list.Sort(delegate (SebPeak x, SebPeak y) { return -x.LogMagnitude.CompareTo(y.LogMagnitude); });
            list.RemoveRange(allowed, list.Count - allowed);
            list.Sort(delegate (SebPeak x, SebPeak y) { return x.StripeIndex.CompareTo(y.StripeIndex); });
        }

        return WriteSig(SAMPLE_RATE, sampleCount, bands);
    }

    static bool IsPeak(List<float[]> stripes, int stripe, int bin, int sd, int bd, float center) {
        for (int s = -sd; s <= sd; s++) {
            float[] row = stripes[stripe + s];
            for (int b = -bd; b <= bd; b++) {
                if (s == 0 && b == 0) continue;
                if (row[bin + b] >= center) return false;
            }
        }
        return true;
    }

    static float LogMagn(float m) {
        return 18 * 1024 * (1 - (float)Math.Log(m) / LOG_MIN_MAGN_SQUARED);
    }

    static byte[] WriteSig(int sampleRate, int sampleCount, List<SebPeak>[] bands) {
        using (var mem = new MemoryStream())
        using (var w = new BinaryWriter(mem)) {
            w.Write(0xCAFE2580);
            w.Write(-1);
            w.Write(-1);
            w.Write(VersionCode());
            w.Write(0); w.Write(0); w.Write(0);
            w.Write(3 << 27);   // 16000 Hz
            w.Write(0); w.Write(0);
            w.Write(sampleCount);
            w.Write(0x007C0000);
            w.Write(0x40000000);
            w.Write(-1);
            for (int i = 0; i < bands.Length; i++) {
                byte[] d = BandData(bands[i]);
                w.Write(0x60030040 + i);
                w.Write(d.Length);
                w.Write(d);
            }
            w.Flush();
            int total = (int)mem.Length;
            int contentLen = total - 48;
            foreach (int i in new int[] { 2, 13 }) {
                mem.Position = i * 4;
                w.Write(contentLen);
            }
            w.Flush();
            uint crc = Crc32(mem.GetBuffer(), 8, total - 8);
            mem.Position = 4;
            w.Write(crc);
            w.Flush();
            return mem.ToArray();
        }
    }

    static byte[] BandData(List<SebPeak> peaks) {
        using (var mem = new MemoryStream())
        using (var w = new BinaryWriter(mem)) {
            int si = 0;
            foreach (var p in peaks) {
                if (p.StripeIndex - si >= 100) {
                    si = p.StripeIndex;
                    w.Write((byte)255);
                    w.Write(si);
                }
                w.Write(Convert.ToByte(p.StripeIndex - si));
                w.Write(Convert.ToUInt16(Math.Max(0f, Math.Min(65535f, p.LogMagnitude))));
                w.Write(Convert.ToUInt16(Math.Max(0f, Math.Min(65535f, 64 * p.InterpolatedBin))));
                si = p.StripeIndex;
            }
            w.Flush();
            while (mem.Length % 4 != 0) { w.Write((byte)0); w.Flush(); }
            return mem.ToArray();
        }
    }

    static uint VersionCode() {
        int r = (10 << 25) + (1 << 20) + (3 << 15) + (7 << 10);
        return (uint)r ^ 0x80000000;
    }

    static uint[] crcTable;
    static uint Crc32(byte[] data, int offset, int count) {
        if (crcTable == null) {
            var t = new uint[256];
            for (uint i = 0; i < 256; i++) {
                uint c = i;
                for (int k = 0; k < 8; k++) c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
                t[i] = c;
            }
            crcTable = t;
        }
        uint crc = 0xFFFFFFFF;
        for (int i = offset; i < offset + count; i++) crc = crcTable[(crc ^ data[i]) & 0xFF] ^ (crc >> 8);
        return crc ^ 0xFFFFFFFF;
    }

    // ---------- resampling to 16 kHz (low-pass FIR + linear interpolation) ----------
    public static float[] ResampleTo16k(float[] src, int srcRate) {
        if (srcRate == SAMPLE_RATE) return (float[])src.Clone();
        float[] x = src;
        if (srcRate > SAMPLE_RATE) {
            const int taps = 63;
            double fc = 7200.0 / srcRate;
            var h = new double[taps];
            double sum = 0;
            for (int i = 0; i < taps; i++) {
                int m = i - taps / 2;
                double sinc = m == 0 ? 2 * fc : Math.Sin(2 * Math.PI * fc * m) / (Math.PI * m);
                double win = 0.42 - 0.5 * Math.Cos(2 * Math.PI * i / (taps - 1)) + 0.08 * Math.Cos(4 * Math.PI * i / (taps - 1));
                h[i] = sinc * win;
                sum += h[i];
            }
            for (int i = 0; i < taps; i++) h[i] /= sum;
            x = new float[src.Length];
            for (int n = 0; n < src.Length; n++) {
                double acc = 0;
                for (int k = 0; k < taps; k++) {
                    int idx = n + k - taps / 2;
                    if (idx >= 0 && idx < src.Length) acc += src[idx] * h[k];
                }
                x[n] = (float)acc;
            }
        }
        long outLen = (long)x.Length * SAMPLE_RATE / srcRate;
        var y = new float[outLen];
        double ratio = (double)srcRate / SAMPLE_RATE;
        for (long j = 0; j < outLen; j++) {
            double pos = j * ratio;
            long i0 = (long)pos;
            double f = pos - i0;
            float a = x[i0];
            float b = i0 + 1 < x.Length ? x[i0 + 1] : a;
            y[j] = (float)(a + (b - a) * f);
        }
        return y;
    }
}

// ---------- capture of the decoded audio via a BASS DSP callback ----------
public static class SebCapture {
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    public delegate void DSPPROC(int handle, int channel, IntPtr buffer, int length, IntPtr user);

    [DllImport("bass.dll")]
    static extern int BASS_ChannelSetDSP(int handle, DSPPROC proc, IntPtr user, int priority);
    [DllImport("bass.dll")]
    static extern bool BASS_ChannelRemoveDSP(int handle, int dsp);

    static readonly DSPPROC proc = OnDsp;   // kept alive for the whole process
    static readonly object sync = new object();
    static float[] ring;
    static int ringPos, ringFilled, chans, rate;

    public static int Rate { get { return rate; } }
    public static double BufferedSeconds { get { lock (sync) { return rate > 0 ? (double)ringFilled / rate : 0; } } }

    // float samples expected (stream created with BASS_SAMPLE_FLOAT)
    public static int Attach(int handle, int freq, int channels, int seconds) {
        lock (sync) {
            rate = freq; chans = Math.Max(1, channels);
            ring = new float[freq * seconds];
            ringPos = 0; ringFilled = 0;
        }
        return BASS_ChannelSetDSP(handle, proc, IntPtr.Zero, 0);
    }

    public static void Reset() {
        lock (sync) { ringPos = 0; ringFilled = 0; }
    }

    static void OnDsp(int handle, int channel, IntPtr buffer, int length, IntPtr user) {
        int count = length / 4;
        if (count <= 0) return;
        var tmp = new float[count];
        Marshal.Copy(buffer, tmp, 0, count);
        lock (sync) {
            if (ring == null) return;
            int frames = count / chans;
            for (int f = 0; f < frames; f++) {
                float s = 0;
                for (int c = 0; c < chans; c++) s += tmp[f * chans + c];
                ring[ringPos] = s / chans;
                ringPos = (ringPos + 1) % ring.Length;
                if (ringFilled < ring.Length) ringFilled++;
            }
        }
    }

    public static float[] GetLast(double seconds) {
        lock (sync) {
            if (ring == null) return new float[0];
            int n = (int)Math.Min(ringFilled, seconds * rate);
            var r = new float[n];
            int start = (ringPos - n + ring.Length) % ring.Length;
            for (int i = 0; i < n; i++) r[i] = ring[(start + i) % ring.Length];
            return r;
        }
    }
}
'@
}

$BASS_UNICODE = [int]::MinValue   # 0x80000000
if ([SebBass]::LoadLibrary((Join-Path $lib 'bass.dll')) -eq [IntPtr]::Zero) { Show-Fatal ($T.LoadFail + "$lib\bass.dll") }
if (-not [SebBass]::BASS_Init(-1, 44100, 0, [IntPtr]::Zero, [IntPtr]::Zero)) { Show-Fatal ($T.InitFail + [SebBass]::BASS_ErrorGetCode()) }

$plugins = @()
foreach ($p in 'bass_aac.dll', 'basshls.dll') {
    $pp = Join-Path $lib $p
    if ((Test-Path $pp) -and [SebBass]::BASS_PluginLoad($pp, $BASS_UNICODE) -ne 0) { $plugins += $p }
}

[void][SebBass]::BASS_SetConfig(11, 10000)     # NET_TIMEOUT 10 s
[void][SebBass]::BASS_SetConfig(12, 5000)      # NET_BUFFER 5 s
[void][SebBass]::BASS_SetConfig(15, 25)        # NET_PREBUF 25% bufora przed startem
[void][SebBass]::BASS_SetConfig(60, 0)         # NET_PREBUF_WAIT wyłączone (buforowanie w tle)
[void][SebBass]::BASS_SetConfig(21, 0)         # NET_PLAYLIST - playlisty obsługuje SebRadio
[void][SebBass]::BASS_SetConfigPtr(16 -bor $BASS_UNICODE, 'SebRadio/2.0')   # NET_AGENT

$sync = [hashtable]::Synchronized(@{ Session = 0; Handle = 0; Error = 0; Done = $false })
$script:handle = 0
$script:clickTime = $null
$script:startTime = $null
$script:wasPlaying = $false
$script:isHls = $false
$script:tick = 0
$script:stationName = ''
$script:miniPlaced = $false
$script:shazamBusy = $false
$script:shazamUrl = ''
$script:appleId = ''
$sync.ShazamDone = $false; $sync.ShazamText = ''; $sync.ShazamUrl = ''; $sync.ShazamArtist = ''; $sync.ShazamTitle = ''; $sync.ShazamApple = ''

$installId = ''
try { if (Test-Path $idFile) { $installId = (Get-Content $idFile -Raw).Trim() } } catch {}
if (-not $installId) {
    $installId = [guid]::NewGuid().ToString()
    try { if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }; Set-Content -Path $idFile -Value $installId -Encoding ASCII } catch {}
}

$shazamWorker = {
    param($sync, [float[]]$samples, $rate, $installId, $T)
    try {
        $r16 = [SebShazam]::ResampleTo16k($samples, $rate)
        $n = 0
        $sig = [SebShazam]::CreateSignature($r16, [ref]$n)
        $ms = [int]($n * 1000 / 16000)
        $body = '{"signatures":[{"uri":"data:audio/vnd.shazam.sig;base64,' + [Convert]::ToBase64String($sig) + '","samplems":' + $ms + '}],"timezone":"GMT"}'
        $url = "https://amp.shazam.com/match/v1/en/US/android/$installId/$([guid]::NewGuid())"
        $wc = New-Object Net.WebClient
        $wc.Encoding = [Text.Encoding]::UTF8
        $wc.Headers['User-Agent'] = 'curl/7'
        $wc.Headers['Content-Type'] = 'application/json'
        $j = $wc.UploadString($url, 'POST', $body) | ConvertFrom-Json
        $id = $null
        if ($j.results -and $j.results.matches) { $m = @($j.results.matches); if ($m.Count -gt 0) { $id = $m[0].id } }
        if ($id) {
            $song = $j.resources.'shazam-songs'.$id
            $a = $song.attributes
            $sync.ShazamApple = ''
            try { $ad = @($song.relationships.songs.data); if ($ad.Count -gt 0 -and $ad[0].id) { $sync.ShazamApple = [string]$ad[0].id } } catch {}
            $link = [string]$a.webUrl
            if (-not $link) { $link = "https://www.shazam.com/track/$id" }
            $sync.ShazamArtist = [string]$a.artist
            $sync.ShazamTitle = [string]$a.title
            $sync.ShazamUrl = ($link -split '\?')[0]
            $sync.ShazamText = $T.Recognized + ' (' + (Get-Date).ToString('HH:mm:ss') + ')'
        } else {
            $sync.ShazamArtist = ''; $sync.ShazamTitle = ''; $sync.ShazamUrl = ''
            $sync.ShazamText = $T.NotRecognized
        }
    }
    catch {
        $sync.ShazamArtist = ''; $sync.ShazamTitle = ''; $sync.ShazamUrl = ''
        $sync.ShazamText = $T.Error + $_.Exception.Message
    }
    $sync.ShazamDone = $true
}
$script:streamUrl = ''

$errText = @{
    2 = $T.E2; 10 = $T.E10; 32 = $T.E32
    40 = $T.E40; 41 = $T.E41; 44 = $T.E44
    48 = $T.E48; 1 = $T.E1; 8 = $T.E8
}

$createWorker = {
    param($sync, $url, $id, $flags)
    $h = [SebBass]::BASS_StreamCreateURL($url, 0, $flags, [IntPtr]::Zero, [IntPtr]::Zero)
    if ($sync.Session -ne $id) { if ($h -ne 0) { [void][SebBass]::BASS_StreamFree($h) }; return }
    if ($h -eq 0) { $sync.Error = [SebBass]::BASS_ErrorGetCode() } else { $sync.Handle = $h }
    $sync.Done = $true
}

# ---------- funkcje ----------
function Resolve-Playlist([string]$url) {
    $path = ([Uri]$url).AbsolutePath.ToLower()
    if ($path -notmatch '\.(pls|m3u|asx|xspf)$') { return $url }
    $wc = New-Object Net.WebClient
    $wc.Headers.Add('User-Agent', 'SebRadio/2.0')
    $txt = $wc.DownloadString($url)
    if ($txt -match '#EXT-X-') { return $url }
    $m = [regex]::Match($txt, '(?i)(https?://[^\s"<>]+)')
    if ($m.Success) { return $m.Groups[1].Value }
    throw $T.NoPlaylistUrl
}

$fields = 'Status', 'Teraz gra', 'Stacja', 'Opis', 'Gatunek', 'Strona WWW', 'Format', 'Bitrate', 'Częstotliwość', 'Kanały', 'Serwer', 'Adres strumienia', 'Czas startu', 'Czas słuchania'

function Set-Info([string]$name, $value) {
    $v = [string]$value
    if (-not $v) { $v = '-' }
    $item = $lv.Items[$name]
    if ($item -and $item.SubItems[1].Text -ne $v) { $item.SubItems[1].Text = $v }
}

function Clear-Info { foreach ($f in $fields) { Set-Info $f '' } }

function Get-Headers([int]$h) {
    $hd = @{}
    foreach ($t in 3, 4) {
        foreach ($l in [SebBass]::GetTagList($h, $t)) {
            $i = $l.IndexOf(':')
            if ($i -gt 0) { $hd[$l.Substring(0, $i).Trim().ToLower()] = $l.Substring($i + 1).Trim() }
        }
    }
    return $hd
}

function Get-Title([int]$h) {
    $meta = [SebBass]::GetTag($h, 5)
    if ($meta) {
        $m = [regex]::Match($meta, "StreamTitle='(.*?)';")
        if ($m.Success) { $t = $m.Groups[1].Value.Trim(); if ($t) { return $t } else { return $T.Empty } }
    }
    $ogg = [SebBass]::GetTagList($h, 2)
    if ($ogg.Count -gt 0) {
        $o = @{}
        foreach ($l in $ogg) { $kv = $l -split '=', 2; if ($kv.Count -eq 2) { $o[$kv[0].ToUpper()] = $kv[1] } }
        $t = (@($o['ARTIST'], $o['TITLE']) | Where-Object { $_ }) -join ' - '
        if ($t) { return $t }
    }
    $ext = [SebBass]::GetTag($h, 0x14000)
    if ($ext) {
        $i = $ext.IndexOf(',')
        if ($i -ge 0) {
            $t = $ext.Substring($i + 1).Trim()
            $tm = [regex]::Match($t, 'title="([^"]*)"')
            if ($tm.Success) { $t = $tm.Groups[1].Value }
            if ($t) { return $t }
        }
    }
    if ($script:isHls) { return $T.NoTitleHls }
    return $T.NoTitle
}

function Update-StreamInfo([int]$h) {
    $hd = Get-Headers $h
    Set-Info 'Stacja' $hd['icy-name']
    Set-Info 'Opis' $hd['icy-description']
    Set-Info 'Gatunek' $hd['icy-genre']
    Set-Info 'Strona WWW' $hd['icy-url']
    $srv = $hd['server']; if (-not $srv) { $srv = $hd['icy-notice2'] }
    if (-not $srv -and $script:streamUrl -match '^https?://') { $srv = ([Uri]$script:streamUrl).Host }
    Set-Info 'Serwer' ($srv -replace '<br\s*/?>', '')
    if ($hd['icy-name']) { $form.Text = "SebRadio - $($hd['icy-name'])"; $script:stationName = $hd['icy-name'] }

    $info = New-Object BASS_CHANNELINFO
    if ([SebBass]::BASS_ChannelGetInfo($h, [ref]$info)) {
        $fmt = switch ($info.ctype) {
            0x10005 { 'MP3' }
            0x10004 { 'MP2' }
            0x10003 { 'MP1' }
            0x10002 { 'OGG Vorbis' }
            0x10b00 { 'AAC' }
            0x10b01 { 'AAC (MP4)' }
            0x10008 { 'Media Foundation' }
            default { '0x{0:X}' -f $info.ctype }
        }
        $sinf = [SebBass]::GetTag($h, 0x14001)
        if ($script:isHls -or $sinf) {
            $script:isHls = $true
            $fmt = "HLS, $fmt"
            $cm = [regex]::Match([string]$sinf, 'CODECS="([^"]+)"')
            if ($cm.Success) { $fmt += " [$($cm.Groups[1].Value)]" }
        }
        Set-Info 'Format' $fmt
        Set-Info 'Częstotliwość' "$($info.freq) Hz"
        $ch = switch ($info.chans) { 1 { $T.Mono } 2 { $T.Stereo } default { "$($info.chans)" } }
        Set-Info 'Kanały' $ch
    }
    $br = $hd['icy-br']
    if (-not $br) {
        $f = [float]0
        if ([SebBass]::BASS_ChannelGetAttribute($h, 12, [ref]$f) -and $f -gt 0) { $br = [math]::Round($f) }
    }
    if ($br) { Set-Info 'Bitrate' ((([string]$br) -split ',')[0] + ' kbps') }
    $nowTitle = Get-Title $h
    Set-Info 'Teraz gra' $nowTitle
    Log-StreamTitle $nowTitle
}

function Stop-Radio([switch]$Keep) {
    $sync.Session++
    if ($script:handle -ne 0) { [void][SebBass]::BASS_StreamFree($script:handle); $script:handle = 0 }
    $sync.Handle = 0; $sync.Error = 0; $sync.Done = $false
    [SebCapture]::Reset()
    $script:clickTime = $null
    $script:startTime = $null
    $script:wasPlaying = $false
    Clear-Info
    if ($Keep) { return }
    $script:recAt = $null
    $script:recAttempt = 0
    $form.Text = 'SebRadio'
    $script:stationName = ''
    $script:lastStreamTitle = ''
    Set-Info 'Status' $T.Stopped
    Mark-Current
}

function Schedule-Reconnect {
    $script:recAttempt++
    $delay = [math]::Min(2 + 3 * ($script:recAttempt - 1), 30)
    Stop-Radio -Keep
    $script:recAt = (Get-Date).AddSeconds($delay)
}

function Start-Radio([switch]$Reconnect) {
    if ($Reconnect) { $url = $script:curUrl } else { $url = $txtUrl.Text.Trim() }
    if (-not $url) { return }
    if ($Reconnect) { Stop-Radio -Keep; $script:recAt = $null } else { Stop-Radio }
    if ($url -notmatch '^[a-z]+://') { $url = 'http://' + $url; $txtUrl.Text = $url }
    $script:curUrl = $url
    try { if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }; Set-Content -Path $cfgFile -Value $url -Encoding UTF8 } catch {}
    $script:clickTime = Get-Date
    Set-Info 'Status' $T.Connecting
    Mark-Current
    [System.Windows.Forms.Application]::DoEvents()
    try { $stream = Resolve-Playlist $url }
    catch {
        Set-Info 'Status' ($T.Error + $_.Exception.Message); $script:clickTime = $null
        if ($script:autoRec -and $script:recAttempt -gt 0) { Schedule-Reconnect }
        return
    }
    $script:streamUrl = $stream
    $script:isHls = ($stream -match '\.m3u8(\?|$)')
    Set-Info 'Adres strumienia' $stream
    $id = $sync.Session
    $ps = [PowerShell]::Create()
    [void]$ps.AddScript($createWorker).AddArgument($sync).AddArgument($stream).AddArgument($id).AddArgument($BASS_UNICODE -bor 0x100)
    [void]$ps.BeginInvoke()
}

# ---------- zapisane stacje / saved stations ----------
$script:stations = New-Object System.Collections.ArrayList
$script:stStamp = [datetime]::MinValue
$script:curUrl = ''
$script:suppressCombo = $false
$script:recAt = $null
$script:recAttempt = 0
$script:autoRec = $true
$script:toTray = $false
$script:sleepAt = $null
$script:sleepMin = 0
$script:tick2 = 0

function Get-HostName([string]$u) { try { return ([Uri]$u).Host } catch { return $u } }
function Clean-Name([string]$n) { return (($n -replace '[\r\n]', ' ') -replace '=', '-').Trim() }
function Show-Msg($owner, [string]$text, [string]$icon = 'Information') {
    [void][Windows.Forms.MessageBox]::Show($owner, $text, 'SebRadio', 'OK', $icon)
}

function Read-StationText([string]$text) {
    $list = New-Object System.Collections.ArrayList
    if ($text -match '#EXT-X-') { return ,$list }
    $pending = ''
    $pls = @{}
    foreach ($raw in ($text -split "`r?`n")) {
        $l = $raw.Trim()
        if (-not $l) { continue }
        if ($l -match '^#EXTINF:[^,]*,(.*)$') { $pending = $matches[1].Trim(); continue }
        if ($l -match '^(File|Title)(\d+)\s*=\s*(.*)$') {
            $k = [int]$matches[2]
            if (-not $pls.ContainsKey($k)) { $pls[$k] = @{} }
            $pls[$k][$matches[1].ToLower()] = $matches[3].Trim()
            continue
        }
        if ($l.StartsWith('#') -or $l.StartsWith(';') -or $l.StartsWith('[')) { continue }
        $m = [regex]::Match($l, '^(.*?)\s*=\s*([a-zA-Z][a-zA-Z0-9+.-]*://\S+)$')
        if ($m.Success -and $m.Groups[1].Value.Trim()) {
            [void]$list.Add([pscustomobject]@{ Name = (Clean-Name $m.Groups[1].Value); Url = $m.Groups[2].Value })
            $pending = ''
            continue
        }
        $m = [regex]::Match($l, '^([a-zA-Z][a-zA-Z0-9+.-]*://\S+)$')
        if ($m.Success) {
            $n = $pending; if (-not $n) { $n = Get-HostName $m.Groups[1].Value }
            [void]$list.Add([pscustomobject]@{ Name = (Clean-Name $n); Url = $m.Groups[1].Value })
            $pending = ''
        }
    }
    foreach ($k in ($pls.Keys | Sort-Object)) {
        $e = $pls[$k]
        if ([string]$e['file'] -match '://') {
            $n = $e['title']; if (-not $n) { $n = Get-HostName $e['file'] }
            [void]$list.Add([pscustomobject]@{ Name = (Clean-Name $n); Url = $e['file'] })
        }
    }
    return ,$list
}

function Find-StationIndex([string]$url) {
    if (-not $url) { return -1 }
    for ($i = 0; $i -lt $script:stations.Count; $i++) { if ($script:stations[$i].Url -eq $url) { return $i } }
    return -1
}

function Save-Stations {
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($h in $T.FileHeader) { $lines.Add($h) }
    $lines.Add('')
    foreach ($s in $script:stations) { $lines.Add(('{0} = {1}' -f $s.Name, $s.Url)) }
    try {
        if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }
        [IO.File]::WriteAllLines($stFile, $lines, (New-Object Text.UTF8Encoding $true))
        $script:stStamp = (Get-Item -LiteralPath $stFile).LastWriteTimeUtc
    } catch {}
    Refresh-StationUI
}

function Load-Stations {
    if (-not (Test-Path -LiteralPath $stFile)) { Save-Stations; return }
    try {
        $stamp = (Get-Item -LiteralPath $stFile).LastWriteTimeUtc
        $parsed = Read-StationText ([IO.File]::ReadAllText($stFile))
    } catch { return }
    $script:stations.Clear()
    foreach ($s in $parsed) { if ((Find-StationIndex $s.Url) -lt 0) { [void]$script:stations.Add($s) } }
    $script:stStamp = $stamp
    Refresh-StationUI
}

function Add-StationItems($items) {
    if ($script:stations.Count -eq 0) {
        $e = New-Object Windows.Forms.ToolStripMenuItem($T.NoStations); $e.Enabled = $false
        [void]$items.Add($e); return
    }
    foreach ($s in $script:stations) {
        $mi = New-Object Windows.Forms.ToolStripMenuItem(([string]$s.Name).Replace('&', '&&'))
        $mi.Tag = $s.Url
        $mi.Add_Click({ param($sender, $e) Play-Url ([string]$sender.Tag) })
        [void]$items.Add($mi)
    }
}

function Refresh-StationUI {
    $script:suppressCombo = $true
    $cmbSt.BeginUpdate()
    $cmbSt.Items.Clear()
    if ($script:stations.Count -eq 0) { [void]$cmbSt.Items.Add($T.NoStations) }
    else { [void]$cmbSt.Items.Add($T.ChooseStation); foreach ($s in $script:stations) { [void]$cmbSt.Items.Add($s.Name) } }
    $cmbSt.EndUpdate()
    $script:suppressCombo = $false
    $miStations.DropDownItems.Clear()
    Add-StationItems $miStations.DropDownItems
    $miniMenu.Items.Clear()
    Add-StationItems $miniMenu.Items
    [void]$miniMenu.Items.Add((New-Object Windows.Forms.ToolStripSeparator))
    $mf = $miniMenu.Items.Add($T.MiniFull)
    $mf.Add_Click({ Show-Main })
    if ($mgr.Visible) { Fill-Mine }
    Mark-Current
}

function Mark-Current {
    $playing = Test-Playing
    foreach ($coll in @($miStations.DropDownItems, $miniMenu.Items)) {
        foreach ($it in $coll) {
            if ($it -is [Windows.Forms.ToolStripMenuItem] -and $it.Tag) { $it.Checked = ($playing -and [string]$it.Tag -eq $script:curUrl) }
        }
    }
    $i = Find-StationIndex $script:curUrl
    $script:suppressCombo = $true
    if ($i -ge 0) { $cmbSt.SelectedIndex = $i + 1 } elseif ($cmbSt.Items.Count -gt 0) { $cmbSt.SelectedIndex = 0 }
    $script:suppressCombo = $false
}

function Play-Url([string]$u) {
    if (-not $u) { return }
    $txtUrl.Text = $u
    Start-Radio
}

# ---------- historia utworów / song history ----------
# plik historia.csv: średnik, UTF-8 z BOM (otwiera się poprawnie w Excelu) / semicolon CSV, UTF-8 BOM (Excel-friendly)
$script:hist = New-Object System.Collections.ArrayList
$script:logStream = $true
$script:lastStreamTitle = ''
$histMax = 5000

function Get-YouTubeLink([string]$a, [string]$t) {
    $q = (@($a, $t) | Where-Object { $_ }) -join ' '
    return 'https://www.youtube.com/results?search_query=' + [Uri]::EscapeDataString($q)
}
function Get-AppleLink([string]$id, [string]$a, [string]$t) {
    if ($id) { return "https://music.apple.com/song/$id" }
    $q = (@($a, $t) | Where-Object { $_ }) -join ' '
    return 'https://music.apple.com/search?term=' + [Uri]::EscapeDataString($q)
}
function ConvertTo-HistLines($items) {
    return @($items | Select-Object Time, Source, Artist, Title, Station, Shazam, AppleMusic, YouTube | ConvertTo-Csv -Delimiter ';' -NoTypeInformation)
}
function Save-History {
    try {
        if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }
        $lines = ConvertTo-HistLines $script:hist
        if ($lines.Count -eq 0) { $lines = @('"Time";"Source";"Artist";"Title";"Station";"Shazam";"AppleMusic";"YouTube"') }
        [IO.File]::WriteAllText($histFile, (($lines -join "`r`n") + "`r`n"), (New-Object Text.UTF8Encoding $true))
    } catch {}
}
function Load-History {
    $script:hist.Clear()
    if (-not (Test-Path -LiteralPath $histFile)) { return }
    try {
        foreach ($r in (Import-Csv -LiteralPath $histFile -Delimiter ';' -Encoding UTF8)) {
            if ($r.Title -or $r.Artist) { [void]$script:hist.Add($r) }
        }
        if ($script:hist.Count -gt $histMax) { $script:hist.RemoveRange(0, $script:hist.Count - $histMax); Save-History }
    } catch {}
}
function Get-StationLabel {
    if ($script:stationName) { return $script:stationName }
    $i = Find-StationIndex $script:curUrl
    if ($i -ge 0) { return [string]$script:stations[$i].Name }
    if ($script:curUrl) { return (Get-HostName $script:curUrl) }
    return ''
}
function Add-History([string]$src, [string]$artist, [string]$title, [string]$shazamUrl, [string]$appleId) {
    $artist = ([string]$artist).Trim(); $title = ([string]$title).Trim()
    if (-not $artist -and -not $title) { return }
    if ($script:hist.Count -gt 0) {
        $last = $script:hist[$script:hist.Count - 1]
        if ($last.Source -eq $src -and $last.Artist -eq $artist -and $last.Title -eq $title) { return }
    }
    $e = [pscustomobject]@{
        Time = (Get-Date).ToString('yyyy-MM-dd HH:mm'); Source = $src; Artist = $artist; Title = $title; Station = (Get-StationLabel)
        Shazam = [string]$shazamUrl; AppleMusic = (Get-AppleLink $appleId $artist $title); YouTube = (Get-YouTubeLink $artist $title)
    }
    [void]$script:hist.Add($e)
    if ($script:hist.Count -gt $histMax) { $script:hist.RemoveRange(0, $script:hist.Count - $histMax); Save-History }
    elseif (-not (Test-Path -LiteralPath $histFile)) { Save-History }
    else {
        try { [IO.File]::AppendAllText($histFile, ((ConvertTo-HistLines @($e))[1] + "`r`n"), (New-Object Text.UTF8Encoding $false)) } catch {}
    }
    if ($script:histOpen) { Fill-History }
}
function Log-StreamTitle([string]$t) {
    if (-not $script:logStream) { return }
    if (-not $t -or $t -eq '-' -or $t.StartsWith('(')) { return }
    if ($t -eq $script:lastStreamTitle) { return }
    $script:lastStreamTitle = $t
    $i = $t.IndexOf(' - ')
    if ($i -gt 0) { Add-History 'stream' $t.Substring(0, $i) $t.Substring($i + 3) '' '' }
    else { Add-History 'stream' '' $t '' '' }
}

# ---------- wyłącznik czasowy / sleep timer ----------
function Add-SleepItems($items) {
    foreach ($m in 0, 15, 30, 45, 60, 90, 120) {
        $txt = if ($m -eq 0) { $T.SleepOff } else { $T.SleepMin -f $m }
        $mi = New-Object Windows.Forms.ToolStripMenuItem($txt)
        $mi.Tag = $m
        $mi.Add_Click({ param($sender, $e) Set-Sleep ([int]$sender.Tag) })
        [void]$items.Add($mi)
    }
}

function Set-Sleep([int]$m) {
    $script:sleepMin = $m
    if ($m -le 0) {
        $script:sleepAt = $null
        if ($script:handle -ne 0) { [void][SebBass]::BASS_ChannelSetAttribute($script:handle, 2, [float]($trkVol.Value / 100)) }
    } else { $script:sleepAt = (Get-Date).AddMinutes($m) }
    foreach ($coll in @($sleepMenu.Items, $miSleep.DropDownItems)) {
        foreach ($it in $coll) { $it.Checked = ([int]$it.Tag -eq $m) }
    }
    Update-SleepText
}

function Update-SleepText {
    if ($script:sleepAt) {
        $left = $script:sleepAt - (Get-Date)
        if ($left.TotalSeconds -lt 0) { $left = [TimeSpan]::Zero }
        $t = $T.SleepLeft -f $left.ToString($(if ($left.TotalHours -ge 1) { 'h\:mm\:ss' } else { 'mm\:ss' }))
    } else { $t = $T.Sleep }
    if ($btnSleep.Text -ne $t) { $btnSleep.Text = $t; $miSleep.Text = $t }
}

function Restart-App {
    $me = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if ($me -match 'powershell(\.exe)?$') { Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$selfPath`"" }
    else { Start-Process $me }
    $script:reallyExit = $true
    $form.Close()
}

# ---------- okno ----------
$form = New-Object Windows.Forms.Form
$form.Text = 'SebRadio'
$form.ClientSize = New-Object Drawing.Size(520, 666)
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object Drawing.Font('Segoe UI', 9)

$lblUrl = New-Object Windows.Forms.Label
$lblUrl.Text = $T.LinkLabel
$lblUrl.Location = New-Object Drawing.Point(10, 10); $lblUrl.AutoSize = $true

$txtUrl = New-Object Windows.Forms.TextBox
$txtUrl.Location = New-Object Drawing.Point(10, 30); $txtUrl.Width = 410

$btnPaste = New-Object Windows.Forms.Button
$btnPaste.Text = $T.PastePlay; $btnPaste.Location = New-Object Drawing.Point(425, 29); $btnPaste.Width = 85

$lblSt = New-Object Windows.Forms.Label
$lblSt.Text = $T.Stations; $lblSt.Location = New-Object Drawing.Point(10, 66); $lblSt.AutoSize = $true

$cmbSt = New-Object Windows.Forms.ComboBox
$cmbSt.DropDownStyle = 'DropDownList'; $cmbSt.Location = New-Object Drawing.Point(95, 62); $cmbSt.Width = 235; $cmbSt.MaxDropDownItems = 20

$btnSave = New-Object Windows.Forms.Button
$btnSave.Text = $T.Save; $btnSave.Location = New-Object Drawing.Point(335, 61); $btnSave.Width = 85

$btnManage = New-Object Windows.Forms.Button
$btnManage.Text = $T.Manage; $btnManage.Location = New-Object Drawing.Point(425, 61); $btnManage.Width = 85

$btnPlay = New-Object Windows.Forms.Button
$btnPlay.Text = $T.Play; $btnPlay.Location = New-Object Drawing.Point(10, 96); $btnPlay.Width = 80

$btnStop = New-Object Windows.Forms.Button
$btnStop.Text = $T.Stop; $btnStop.Location = New-Object Drawing.Point(95, 96); $btnStop.Width = 80

$lblVol = New-Object Windows.Forms.Label
$lblVol.Text = $T.Volume; $lblVol.Location = New-Object Drawing.Point(200, 101); $lblVol.AutoSize = $true

$trkVol = New-Object Windows.Forms.TrackBar
$trkVol.Location = New-Object Drawing.Point(265, 92); $trkVol.Width = 200
$trkVol.Minimum = 0; $trkVol.Maximum = 100; $trkVol.TickFrequency = 10; $trkVol.Value = 50

$lblVolVal = New-Object Windows.Forms.Label
$lblVolVal.Text = '50%'; $lblVolVal.Location = New-Object Drawing.Point(470, 101); $lblVolVal.AutoSize = $true

$lv = New-Object Windows.Forms.ListView
$lv.Location = New-Object Drawing.Point(10, 139); $lv.Size = New-Object Drawing.Size(500, 278)
$lv.View = 'Details'; $lv.FullRowSelect = $true; $lv.GridLines = $true
$lv.HeaderStyle = 'Nonclickable'
[void]$lv.Columns.Add($T.ColInfo, 130)
[void]$lv.Columns.Add($T.ColValue, 345)
foreach ($f in $fields) {
    $it = New-Object Windows.Forms.ListViewItem($F[$f])
    $it.Name = $f
    [void]$it.SubItems.Add('-')
    [void]$lv.Items.Add($it)
}

$lblEngine = New-Object Windows.Forms.Label
$v = [SebBass]::BASS_GetVersion()
$lblEngine.Text = $T.Engine + ': BASS {0}.{1}.{2}.{3}' -f (($v -shr 24) -band 255), (($v -shr 16) -band 255), (($v -shr 8) -band 255), ($v -band 255)
if ($plugins.Count) { $lblEngine.Text += '  +  ' + ($plugins -join ', ') }
$lblEngine.Location = New-Object Drawing.Point(10, 646); $lblEngine.AutoSize = $true
$lblEngine.ForeColor = [Drawing.Color]::Gray

# ---------- panel rozpoznawania ----------
$grpRec = New-Object Windows.Forms.GroupBox
$grpRec.Text = $T.RecGroup
$grpRec.Location = New-Object Drawing.Point(10, 426); $grpRec.Size = New-Object Drawing.Size(500, 180)

$btnShazam = New-Object Windows.Forms.Button
$btnShazam.Text = $T.Recognize; $btnShazam.Location = New-Object Drawing.Point(10, 24); $btnShazam.Size = New-Object Drawing.Size(130, 28)

$lblRec = New-Object Windows.Forms.Label
$lblRec.Text = $T.RecHint; $lblRec.Location = New-Object Drawing.Point(150, 30); $lblRec.Size = New-Object Drawing.Size(340, 20)
$lblRec.ForeColor = [Drawing.Color]::DimGray

$lblArtist = New-Object Windows.Forms.Label
$lblArtist.Text = $T.Artist; $lblArtist.Location = New-Object Drawing.Point(10, 68); $lblArtist.AutoSize = $true
$txtArtist = New-Object Windows.Forms.TextBox
$txtArtist.Location = New-Object Drawing.Point(85, 65); $txtArtist.Width = 300; $txtArtist.ReadOnly = $true
$btnCopyArtist = New-Object Windows.Forms.Button
$btnCopyArtist.Text = $T.Copy; $btnCopyArtist.Location = New-Object Drawing.Point(395, 63); $btnCopyArtist.Width = 95; $btnCopyArtist.Enabled = $false

$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text = $T.Title; $lblTitle.Location = New-Object Drawing.Point(10, 101); $lblTitle.AutoSize = $true
$txtTitle = New-Object Windows.Forms.TextBox
$txtTitle.Location = New-Object Drawing.Point(85, 98); $txtTitle.Width = 300; $txtTitle.ReadOnly = $true
$btnCopyTitle = New-Object Windows.Forms.Button
$btnCopyTitle.Text = $T.Copy; $btnCopyTitle.Location = New-Object Drawing.Point(395, 96); $btnCopyTitle.Width = 95; $btnCopyTitle.Enabled = $false

$btnCopyAll = New-Object Windows.Forms.Button
$btnCopyAll.Text = $T.CopyAll; $btnCopyAll.Location = New-Object Drawing.Point(85, 136); $btnCopyAll.Size = New-Object Drawing.Size(180, 28); $btnCopyAll.Enabled = $false
$btnYouTube = New-Object Windows.Forms.Button
$btnYouTube.Text = 'YouTube'; $btnYouTube.Location = New-Object Drawing.Point(275, 136); $btnYouTube.Size = New-Object Drawing.Size(100, 28); $btnYouTube.Enabled = $false
$btnApple = New-Object Windows.Forms.Button
$btnApple.Text = 'Apple Music'; $btnApple.Location = New-Object Drawing.Point(385, 136); $btnApple.Size = New-Object Drawing.Size(105, 28); $btnApple.Enabled = $false

$grpRec.Controls.AddRange(@($btnShazam, $lblRec, $lblArtist, $txtArtist, $btnCopyArtist, $lblTitle, $txtTitle, $btnCopyTitle, $btnCopyAll, $btnYouTube, $btnApple))

function Copy-Text([string]$t) {
    if ($t) { [Windows.Forms.Clipboard]::SetText($t); $lblRec.Text = $T.Copied + $t }
}

$btnMini = New-Object Windows.Forms.Button
$btnMini.Text = $T.Mini; $btnMini.Location = New-Object Drawing.Point(10, 612); $btnMini.Size = New-Object Drawing.Size(110, 26)
$btnSleep = New-Object Windows.Forms.Button
$btnSleep.Text = $T.Sleep; $btnSleep.Location = New-Object Drawing.Point(126, 612); $btnSleep.Size = New-Object Drawing.Size(150, 26)
$btnHist = New-Object Windows.Forms.Button
$btnHist.Text = $T.History; $btnHist.Location = New-Object Drawing.Point(282, 612); $btnHist.Size = New-Object Drawing.Size(110, 26)
$btnSettings = New-Object Windows.Forms.Button
$btnSettings.Text = $T.Settings; $btnSettings.Location = New-Object Drawing.Point(398, 612); $btnSettings.Size = New-Object Drawing.Size(112, 26)
$sleepMenu = New-Object Windows.Forms.ContextMenuStrip

# ---------- ikona w zasobniku / tray icon ----------
$appIcon = $null
try { if (Test-Path (Join-Path $base 'SebRadio.ico')) { $appIcon = New-Object Drawing.Icon (Join-Path $base 'SebRadio.ico') } } catch {}
if (-not $appIcon) { try { $appIcon = [Drawing.Icon]::ExtractAssociatedIcon([Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) } catch {} }
if ($appIcon) { $form.Icon = $appIcon }
$tray = New-Object Windows.Forms.NotifyIcon
$tray.Icon = $appIcon; $tray.Text = 'SebRadio'; $tray.Visible = $true
$trayMenu = New-Object Windows.Forms.ContextMenuStrip
$miShow = $trayMenu.Items.Add($T.TrayShow)
$miShow.Font = New-Object Drawing.Font($miShow.Font, [Drawing.FontStyle]::Bold)
$miMini = $trayMenu.Items.Add($T.Mini)
$miPlay = $trayMenu.Items.Add($T.Play)
$miStations = New-Object Windows.Forms.ToolStripMenuItem($T.StationsMenu)
[void]$trayMenu.Items.Add($miStations)
$miSleep = New-Object Windows.Forms.ToolStripMenuItem($T.Sleep)
[void]$trayMenu.Items.Add($miSleep)
$miHist = $trayMenu.Items.Add($T.TrayHist)
Add-SleepItems $sleepMenu.Items
Add-SleepItems $miSleep.DropDownItems
[void]$trayMenu.Items.Add((New-Object Windows.Forms.ToolStripSeparator))
$miExit = $trayMenu.Items.Add($T.TrayExit)
$tray.ContextMenuStrip = $trayMenu

# ---------- mini odtwarzacz / mini player ----------
$mini = New-Object Windows.Forms.Form
$mini.FormBorderStyle = 'None'; $mini.TopMost = $true; $mini.ShowInTaskbar = $false
$mini.StartPosition = 'Manual'; $mini.ClientSize = New-Object Drawing.Size(300, 40)
$mini.BackColor = [Drawing.Color]::FromArgb(27, 30, 34)
if ($appIcon) { $mini.Icon = $appIcon }
$mBtn = New-Object Windows.Forms.Button
$mBtn.FlatStyle = 'Flat'; $mBtn.FlatAppearance.BorderSize = 0
$mBtn.Font = New-Object Drawing.Font('Segoe UI Symbol', 12)
$mBtn.ForeColor = [Drawing.Color]::FromArgb(57, 217, 138)
$mBtn.Location = New-Object Drawing.Point(4, 4); $mBtn.Size = New-Object Drawing.Size(34, 32)
$mName = New-Object Windows.Forms.Label
$mName.ForeColor = [Drawing.Color]::White; $mName.Font = New-Object Drawing.Font('Segoe UI', 9.5)
$mName.AutoEllipsis = $true; $mName.TextAlign = 'MiddleLeft'
$mName.Location = New-Object Drawing.Point(42, 4); $mName.Size = New-Object Drawing.Size(196, 32)
$mFull = New-Object Windows.Forms.Button
$mFull.FlatStyle = 'Flat'; $mFull.FlatAppearance.BorderSize = 0; $mFull.Text = [char]0x2922
$mFull.Font = New-Object Drawing.Font('Segoe UI Symbol', 10); $mFull.ForeColor = [Drawing.Color]::Silver
$mFull.Location = New-Object Drawing.Point(240, 6); $mFull.Size = New-Object Drawing.Size(28, 28)
$mClose = New-Object Windows.Forms.Button
$mClose.FlatStyle = 'Flat'; $mClose.FlatAppearance.BorderSize = 0; $mClose.Text = [char]0x2715
$mClose.Font = New-Object Drawing.Font('Segoe UI Symbol', 9); $mClose.ForeColor = [Drawing.Color]::Silver
$mClose.Location = New-Object Drawing.Point(268, 6); $mClose.Size = New-Object Drawing.Size(28, 28)
$tip = New-Object Windows.Forms.ToolTip
$tip.SetToolTip($mFull, $T.MiniFull); $tip.SetToolTip($mClose, $T.MiniClose)
$mini.Controls.AddRange(@($mBtn, $mName, $mFull, $mClose))
$miniMenu = New-Object Windows.Forms.ContextMenuStrip
$mini.ContextMenuStrip = $miniMenu
$mName.ContextMenuStrip = $miniMenu

function Test-Playing { return ($script:clickTime -ne $null -or $script:recAt -ne $null) }
function Show-Main {
    $mini.Hide()
    $form.Show(); $form.WindowState = 'Normal'; $form.ShowInTaskbar = $true; $form.Activate()
}
function Show-Mini {
    if (-not $script:miniPlaced) {
        $script:miniPlaced = $true
        $wa = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $x = $wa.Right - $mini.Width - 12; $y = $wa.Bottom - $mini.Height - 12
        try {
            if (Test-Path $miniFile) {
                $xy = (Get-Content $miniFile -Raw).Trim() -split ','
                $pt = New-Object Drawing.Point([int]$xy[0], [int]$xy[1])
                if ([Windows.Forms.Screen]::AllScreens | Where-Object { $_.WorkingArea.Contains($pt) }) { $x = $pt.X; $y = $pt.Y }
            }
        } catch {}
        $mini.Location = New-Object Drawing.Point($x, $y)
    }
    $form.Hide()
    $mini.Show(); $mini.Activate()
    Update-MiniTray
}
function Toggle-Play { if (Test-Playing) { Stop-Radio } else { Start-Radio } }
function Update-MiniTray {
    $playing = Test-Playing
    $name = $script:stationName
    if (-not $name -and $playing -and $script:streamUrl -match '^https?://') { $name = ([Uri]$script:streamUrl).Host }
    if (-not $name) { $name = $(if ($playing) { $T.NoStation } else { 'SebRadio' }) }
    $sym = if ($playing) { [string][char]0x25A0 } else { [string][char]0x25B6 }
    if ($mBtn.Text -ne $sym) { $mBtn.Text = $sym }
    if ($mName.Text -ne $name) { $mName.Text = $name; $tip.SetToolTip($mName, $name) }
    $miPlay.Text = $(if ($playing) { $T.Stop } else { $T.Play })
    $now = $lv.Items['Teraz gra'].SubItems[1].Text
    $tt = 'SebRadio'
    if ($playing) { $tt = $name; if ($now -and $now -ne '-' -and $now -notmatch '^\(') { $tt = "$name - $now" } }
    if ($tt.Length -gt 63) { $tt = $tt.Substring(0, 60) + '...' }
    if ($tray.Text -ne $tt) { $tray.Text = $tt }
}

$mBtn.Add_Click({ Toggle-Play; Update-MiniTray })
$mFull.Add_Click({ Show-Main })
$mClose.Add_Click({ Show-Main })
$dragHandler = { param($sender, $e) if ($e.Button -eq 'Left') { [SebWin]::Drag($mini.Handle) } }
$mName.Add_MouseDown($dragHandler)
$mini.Add_MouseDown($dragHandler)
$mName.Add_DoubleClick({ Show-Main })
$mini.Add_LocationChanged({ if ($mini.Visible) { try { Set-Content -Path $miniFile -Value ("{0},{1}" -f $mini.Left, $mini.Top) -Encoding ASCII } catch {} } })

$btnMini.Add_Click({ Show-Mini })
$miShow.Add_Click({ Show-Main })
$miMini.Add_Click({ Show-Mini })
$miPlay.Add_Click({ Toggle-Play; Update-MiniTray })
$miExit.Add_Click({ $script:reallyExit = $true; $form.Close() })
$tray.Add_MouseClick({ param($sender, $e) if ($e.Button -eq 'Left') { if ($form.Visible -and $form.WindowState -ne 'Minimized') { $form.WindowState = 'Minimized' } else { Show-Main } } })
$script:reallyExit = $false
$script:trayTipShown = $false

function New-Dialog([string]$title, [int]$w, [int]$h) {
    $d = New-Object Windows.Forms.Form
    $d.Text = $title; $d.ClientSize = New-Object Drawing.Size($w, $h)
    $d.FormBorderStyle = 'FixedDialog'; $d.MaximizeBox = $false; $d.MinimizeBox = $false
    $d.ShowInTaskbar = $false; $d.StartPosition = 'CenterParent'; $d.Font = $form.Font
    if ($appIcon) { $d.Icon = $appIcon }
    return $d
}
function New-Btn([string]$text, [int]$x, [int]$y, [int]$w) {
    $b = New-Object Windows.Forms.Button
    $b.Text = $text; $b.Location = New-Object Drawing.Point($x, $y); $b.Size = New-Object Drawing.Size($w, 26)
    return $b
}

# ---------- okno: pole tekstowe / input dialog ----------
$inp = New-Dialog '' 380 104
$inpLbl = New-Object Windows.Forms.Label
$inpLbl.Location = New-Object Drawing.Point(12, 12); $inpLbl.AutoSize = $true
$inpTxt = New-Object Windows.Forms.TextBox
$inpTxt.Location = New-Object Drawing.Point(12, 32); $inpTxt.Width = 356
$inpOk = New-Btn $T.OK 212 68 75; $inpOk.DialogResult = 'OK'
$inpCancel = New-Btn $T.Cancel 293 68 75; $inpCancel.DialogResult = 'Cancel'
$inp.AcceptButton = $inpOk; $inp.CancelButton = $inpCancel
$inp.Controls.AddRange(@($inpLbl, $inpTxt, $inpOk, $inpCancel))

function Show-Input($owner, [string]$title, [string]$prompt, [string]$default) {
    $inp.Text = $title; $inpLbl.Text = $prompt; $inpTxt.Text = $default
    $inpTxt.SelectAll(); $inp.ActiveControl = $inpTxt
    if ($inp.ShowDialog($owner) -ne 'OK') { return $null }
    $v = Clean-Name $inpTxt.Text
    if ($v) { return $v }
    return $null
}

# ---------- okno: ustawienia / settings dialog ----------
$set = New-Dialog $T.SetTitle 430 204
$chkTray = New-Object Windows.Forms.CheckBox
$chkTray.Text = $T.ToTray; $chkTray.Location = New-Object Drawing.Point(14, 14); $chkTray.Size = New-Object Drawing.Size(405, 22)
$chkRec = New-Object Windows.Forms.CheckBox
$chkRec.Text = $T.AutoReconnect; $chkRec.Location = New-Object Drawing.Point(14, 42); $chkRec.Size = New-Object Drawing.Size(405, 22)
$chkHist = New-Object Windows.Forms.CheckBox
$chkHist.Text = $T.HLogStream; $chkHist.Location = New-Object Drawing.Point(14, 70); $chkHist.Size = New-Object Drawing.Size(405, 22)
$lblLang = New-Object Windows.Forms.Label
$lblLang.Text = $T.LangLbl; $lblLang.Location = New-Object Drawing.Point(14, 109); $lblLang.AutoSize = $true
$cmbLang = New-Object Windows.Forms.ComboBox
$cmbLang.DropDownStyle = 'DropDownList'; $cmbLang.Location = New-Object Drawing.Point(90, 105); $cmbLang.Width = 140
[void]$cmbLang.Items.AddRange(@('Polski', 'English'))
$lnkCfg = New-Object Windows.Forms.LinkLabel
$lnkCfg.Text = $T.OpenCfg; $lnkCfg.Location = New-Object Drawing.Point(14, 140); $lnkCfg.AutoSize = $true
$lnkCfg.Add_LinkClicked({ if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }; Start-Process explorer.exe $cfgDir })
$setOk = New-Btn $T.OK 262 168 75; $setOk.DialogResult = 'OK'
$setCancel = New-Btn $T.Cancel 343 168 75; $setCancel.DialogResult = 'Cancel'
$set.AcceptButton = $setOk; $set.CancelButton = $setCancel
$set.Controls.AddRange(@($chkTray, $chkRec, $chkHist, $lblLang, $cmbLang, $lnkCfg, $setOk, $setCancel))

$btnSettings.Add_Click({
    $chkTray.Checked = $script:toTray
    $chkRec.Checked = $script:autoRec
    $chkHist.Checked = $script:logStream
    $cmbLang.SelectedIndex = $(if ($lang -eq 'pl') { 0 } else { 1 })
    if ($set.ShowDialog($form) -ne 'OK') { return }
    $script:toTray = $chkTray.Checked
    $script:autoRec = $chkRec.Checked
    $script:logStream = $chkHist.Checked
    if (-not $script:autoRec) { $script:recAttempt = 0; if ($script:recAt) { Stop-Radio } }
    try {
        if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }
        Set-Content -Path $trayFile -Value ([int]$script:toTray) -Encoding ASCII
        Set-Content -Path $recFile -Value ([int]$script:autoRec) -Encoding ASCII
        Set-Content -Path $histOptFile -Value ([int]$script:logStream) -Encoding ASCII
    } catch {}
    $new = if ($cmbLang.SelectedIndex -eq 0) { 'pl' } else { 'en' }
    if ($new -ne $lang) {
        try { Set-Content -Path $langFile -Value $new -Encoding ASCII } catch {}
        $q = [Windows.Forms.MessageBox]::Show($form, $TT[$new].LangRestart, 'SebRadio', 'YesNo', 'Question')
        if ($q -eq 'Yes') { Restart-App }
    }
})

# ---------- okno: historia / history dialog ----------
$histDlg = New-Dialog $T.HistTitle 720 452
$hdLblS = New-Object Windows.Forms.Label
$hdLblS.Text = $T.HSearch; $hdLblS.Location = New-Object Drawing.Point(10, 14); $hdLblS.AutoSize = $true
$hdTxt = New-Object Windows.Forms.TextBox
$hdTxt.Location = New-Object Drawing.Point(70, 10); $hdTxt.Width = 300
$hdSrc = New-Object Windows.Forms.ComboBox
$hdSrc.DropDownStyle = 'DropDownList'; $hdSrc.Location = New-Object Drawing.Point(380, 10); $hdSrc.Width = 130
[void]$hdSrc.Items.AddRange(@($T.HAll, $T.HSrcShazam, $T.HSrcStream)); $hdSrc.SelectedIndex = 0
$hdCount = New-Object Windows.Forms.Label
$hdCount.Location = New-Object Drawing.Point(520, 14); $hdCount.Size = New-Object Drawing.Size(190, 20); $hdCount.TextAlign = 'TopRight'
$hdLv = New-Object Windows.Forms.ListView
$hdLv.Location = New-Object Drawing.Point(10, 42); $hdLv.Size = New-Object Drawing.Size(700, 330)
$hdLv.View = 'Details'; $hdLv.FullRowSelect = $true; $hdLv.GridLines = $true; $hdLv.HideSelection = $false; $hdLv.MultiSelect = $true
[void]$hdLv.Columns.Add($T.HColTime, 110)
[void]$hdLv.Columns.Add($T.HColArtist, 170)
[void]$hdLv.Columns.Add($T.HColTitle, 210)
[void]$hdLv.Columns.Add($T.HColStation, 120)
[void]$hdLv.Columns.Add($T.HColSource, 70)
$hdYt = New-Btn 'YouTube' 10 380 90
$hdAm = New-Btn 'Apple Music' 104 380 100
$hdSz = New-Btn 'Shazam' 208 380 80
$hdCopy = New-Btn $T.HCopy 292 380 80
$hdDel = New-Btn $T.HDelete 376 380 80
$hdClear = New-Btn $T.HClear 460 380 90
$hdOpen = New-Btn $T.HOpen 10 414 140
$hdHint = New-Object Windows.Forms.Label
$hdHint.Text = $T.HHint; $hdHint.Location = New-Object Drawing.Point(158, 420); $hdHint.Size = New-Object Drawing.Size(460, 20); $hdHint.ForeColor = [Drawing.Color]::DimGray
$hdClose = New-Btn $T.Close 625 414 85; $hdClose.DialogResult = 'Cancel'
$histDlg.CancelButton = $hdClose
$histDlg.Controls.AddRange(@($hdLblS, $hdTxt, $hdSrc, $hdCount, $hdLv, $hdYt, $hdAm, $hdSz, $hdCopy, $hdDel, $hdClear, $hdOpen, $hdHint, $hdClose))
$script:histOpen = $false

function Fill-History {
    $q = $hdTxt.Text.Trim()
    $want = switch ($hdSrc.SelectedIndex) { 1 { 'shazam' } 2 { 'stream' } default { '' } }
    $hdLv.BeginUpdate()
    $hdLv.Items.Clear()
    for ($i = $script:hist.Count - 1; $i -ge 0; $i--) {
        $e = $script:hist[$i]
        if ($want -and $e.Source -ne $want) { continue }
        if ($q -and -not ("$($e.Artist) $($e.Title) $($e.Station)" -like "*$q*")) { continue }
        $it = New-Object Windows.Forms.ListViewItem([string]$e.Time)
        [void]$it.SubItems.Add([string]$e.Artist)
        [void]$it.SubItems.Add([string]$e.Title)
        [void]$it.SubItems.Add([string]$e.Station)
        [void]$it.SubItems.Add($(if ($e.Source -eq 'shazam') { $T.HSrcShazam } else { $T.HSrcStream }))
        $it.Tag = $e
        [void]$hdLv.Items.Add($it)
    }
    $hdLv.EndUpdate()
    $hdCount.Text = $T.HCount -f $hdLv.Items.Count
    Update-HistButtons
}
function Get-HistSel { return @($hdLv.SelectedItems | ForEach-Object { $_.Tag }) }
function Update-HistButtons {
    $sel = @(Get-HistSel)
    $one = ($sel.Count -ge 1)
    $hdYt.Enabled = $one; $hdAm.Enabled = $one; $hdCopy.Enabled = $one; $hdDel.Enabled = $one
    $hdSz.Enabled = ($one -and [bool]$sel[0].Shazam)
    $hdClear.Enabled = ($script:hist.Count -gt 0)
}
$hdTxt.Add_TextChanged({ Fill-History })
$hdSrc.Add_SelectedIndexChanged({ Fill-History })
$hdLv.Add_SelectedIndexChanged({ Update-HistButtons })
$hdYt.Add_Click({ $s = @(Get-HistSel); if ($s.Count) { Start-Process $s[0].YouTube } })
$hdLv.Add_DoubleClick({ $s = @(Get-HistSel); if ($s.Count) { Start-Process $s[0].YouTube } })
$hdAm.Add_Click({ $s = @(Get-HistSel); if ($s.Count) { Start-Process $s[0].AppleMusic } })
$hdSz.Add_Click({ $s = @(Get-HistSel); if ($s.Count -and $s[0].Shazam) { Start-Process $s[0].Shazam } })
$hdCopy.Add_Click({
    $s = @(Get-HistSel)
    if ($s.Count) { [Windows.Forms.Clipboard]::SetText((($s | ForEach-Object { (@($_.Artist, $_.Title) | Where-Object { $_ }) -join ' - ' }) -join "`r`n")) }
})
$hdDel.Add_Click({
    $s = @(Get-HistSel)
    if (-not $s.Count) { return }
    if ([Windows.Forms.MessageBox]::Show($histDlg, ($T.HDelAsk -f $s.Count), 'SebRadio', 'YesNo', 'Question') -ne 'Yes') { return }
    foreach ($e in $s) { $script:hist.Remove($e) }
    Save-History
    Fill-History
})
$hdClear.Add_Click({
    if ([Windows.Forms.MessageBox]::Show($histDlg, ($T.HClearAsk -f $script:hist.Count), 'SebRadio', 'YesNo', 'Warning') -ne 'Yes') { return }
    $script:hist.Clear()
    Save-History
    Fill-History
})
$hdOpen.Add_Click({ if (-not (Test-Path -LiteralPath $histFile)) { Save-History }; Start-Process $histFile })
function Show-History {
    $hdTxt.Text = ''
    $hdSrc.SelectedIndex = 0
    $script:histOpen = $true
    Fill-History
    if ($form.Visible) { [void]$histDlg.ShowDialog($form) } else { [void]$histDlg.ShowDialog() }
    $script:histOpen = $false
}
$btnHist.Add_Click({ Show-History })
$miHist.Add_Click({ Show-History })

# ---------- okno: stacje / stations dialog ----------
$mgr = New-Dialog ($T.Manage -replace '\.+$', '') 600 420
$tabs = New-Object Windows.Forms.TabControl
$tabs.Location = New-Object Drawing.Point(8, 8); $tabs.Size = New-Object Drawing.Size(584, 370)
$tabMine = New-Object Windows.Forms.TabPage($T.TabMine)
$tabSearch = New-Object Windows.Forms.TabPage($T.TabSearch)
$tabs.TabPages.AddRange(@($tabMine, $tabSearch))
$mgrClose = New-Btn $T.Close 507 386 85; $mgrClose.DialogResult = 'Cancel'
$mgr.CancelButton = $mgrClose
$mgr.Controls.AddRange(@($tabs, $mgrClose))

# zakładka: moje stacje / tab: my stations
$lvMine = New-Object Windows.Forms.ListView
$lvMine.Location = New-Object Drawing.Point(6, 6); $lvMine.Size = New-Object Drawing.Size(456, 330)
$lvMine.View = 'Details'; $lvMine.FullRowSelect = $true; $lvMine.GridLines = $true; $lvMine.HideSelection = $false; $lvMine.MultiSelect = $false
[void]$lvMine.Columns.Add($T.ColName, 170)
[void]$lvMine.Columns.Add($T.ColLink, 262)
$bmPlay = New-Btn $T.PlaySel 468 6 100
$bmRename = New-Btn $T.Rename 468 38 100
$bmDelete = New-Btn $T.Delete 468 70 100
$bmUp = New-Btn $T.Up 468 112 100
$bmDown = New-Btn $T.Down 468 144 100
$bmImport = New-Btn $T.Import 468 186 100
$bmFile = New-Btn $T.EditFile 468 218 100
$tabMine.Controls.AddRange(@($lvMine, $bmPlay, $bmRename, $bmDelete, $bmUp, $bmDown, $bmImport, $bmFile))

function Fill-Mine([int]$select = -1) {
    if ($select -lt 0 -and $lvMine.SelectedIndices.Count -gt 0) { $select = $lvMine.SelectedIndices[0] }
    $lvMine.BeginUpdate()
    $lvMine.Items.Clear()
    foreach ($s in $script:stations) {
        $it = New-Object Windows.Forms.ListViewItem([string]$s.Name)
        [void]$it.SubItems.Add([string]$s.Url)
        [void]$lvMine.Items.Add($it)
    }
    $lvMine.EndUpdate()
    if ($lvMine.Items.Count -gt 0 -and $select -ge 0) {
        $select = [math]::Min($select, $lvMine.Items.Count - 1)
        $lvMine.Items[$select].Selected = $true; $lvMine.Items[$select].Focused = $true
        $lvMine.EnsureVisible($select)
    }
}
function Get-MineIndex { if ($lvMine.SelectedIndices.Count -gt 0) { return $lvMine.SelectedIndices[0] }; return -1 }
function Move-Station([int]$d) {
    $i = Get-MineIndex; $j = $i + $d
    if ($i -lt 0 -or $j -lt 0 -or $j -ge $script:stations.Count) { return }
    $tmp = $script:stations[$i]; $script:stations[$i] = $script:stations[$j]; $script:stations[$j] = $tmp
    Save-Stations
    Fill-Mine $j
}

$bmPlay.Add_Click({ $i = Get-MineIndex; if ($i -ge 0) { Play-Url $script:stations[$i].Url } })
$lvMine.Add_DoubleClick({ $i = Get-MineIndex; if ($i -ge 0) { Play-Url $script:stations[$i].Url } })
$bmRename.Add_Click({
    $i = Get-MineIndex; if ($i -lt 0) { return }
    $n = Show-Input $mgr $T.RenameTitle $T.SavePrompt $script:stations[$i].Name
    if (-not $n) { return }
    $script:stations[$i].Name = $n
    Save-Stations
    Fill-Mine $i
})
$bmDelete.Add_Click({
    $i = Get-MineIndex; if ($i -lt 0) { return }
    $q = [Windows.Forms.MessageBox]::Show($mgr, ($T.DelAsk -f $script:stations[$i].Name), 'SebRadio', 'YesNo', 'Question')
    if ($q -ne 'Yes') { return }
    $script:stations.RemoveAt($i)
    Save-Stations
    Fill-Mine $i
})
$lvMine.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Delete') { $bmDelete.PerformClick() } })
$bmUp.Add_Click({ Move-Station -1 })
$bmDown.Add_Click({ Move-Station 1 })
$bmImport.Add_Click({
    $ofd = New-Object Windows.Forms.OpenFileDialog
    $ofd.Filter = $T.ImportFilter; $ofd.Multiselect = $true
    if ($ofd.ShowDialog($mgr) -ne 'OK') { return }
    $added = 0; $skipped = 0
    foreach ($f in $ofd.FileNames) {
        try { $found = Read-StationText ([IO.File]::ReadAllText($f)) } catch { Show-Msg $mgr ($T.Error + $_.Exception.Message) 'Error'; continue }
        foreach ($s in $found) {
            if ((Find-StationIndex $s.Url) -ge 0) { $skipped++ } else { [void]$script:stations.Add($s); $added++ }
        }
    }
    if ($added -gt 0) { Save-Stations; Fill-Mine ($script:stations.Count - 1) }
    Show-Msg $mgr ($T.ImportDone -f $added, $skipped)
})
$bmFile.Add_Click({
    if (-not (Test-Path -LiteralPath $stFile)) { Save-Stations }
    Start-Process notepad.exe -ArgumentList "`"$stFile`""
})

# zakładka: szukaj w internecie / tab: internet search
$lblQ = New-Object Windows.Forms.Label
$lblQ.Text = $T.SearchName; $lblQ.Location = New-Object Drawing.Point(6, 12); $lblQ.AutoSize = $true
$txtQ = New-Object Windows.Forms.TextBox
$txtQ.Location = New-Object Drawing.Point(62, 9); $txtQ.Width = 220
$lblCountry = New-Object Windows.Forms.Label
$lblCountry.Text = $T.SearchCountry; $lblCountry.Location = New-Object Drawing.Point(292, 12); $lblCountry.AutoSize = $true
$cmbCountry = New-Object Windows.Forms.ComboBox
$cmbCountry.DropDownStyle = 'DropDown'; $cmbCountry.Location = New-Object Drawing.Point(345, 9); $cmbCountry.Width = 120
$cmbCountry.AutoCompleteMode = 'SuggestAppend'; $cmbCountry.AutoCompleteSource = 'ListItems'

# kraje: brak listy domyślnej - podpowiadane są tylko kraje, których już użyłeś (kraje.txt)
# countries: no default list - only countries you have used before are suggested (kraje.txt)
$script:countries = New-Object System.Collections.ArrayList
$script:geoMap = $null
function Load-Countries {
    $script:countries.Clear()
    try { if (Test-Path -LiteralPath $ctFile) { foreach ($l in (Get-Content -LiteralPath $ctFile -Encoding UTF8)) { $l = $l.Trim(); if ($l) { [void]$script:countries.Add($l) } } } } catch {}
    $cmbCountry.Items.Clear()
    foreach ($c in $script:countries) { [void]$cmbCountry.Items.Add($c) }
}
function Remember-Country([string]$c) {
    $c = $c.Trim()
    if (-not $c) { return }
    for ($i = $script:countries.Count - 1; $i -ge 0; $i--) { if ($script:countries[$i] -eq $c) { $script:countries.RemoveAt($i) } }
    $script:countries.Insert(0, $c)
    while ($script:countries.Count -gt 30) { $script:countries.RemoveAt($script:countries.Count - 1) }
    try {
        if (-not (Test-Path $cfgDir)) { [void](New-Item -ItemType Directory $cfgDir) }
        [IO.File]::WriteAllLines($ctFile, [string[]]$script:countries, (New-Object Text.UTF8Encoding $true))
    } catch {}
    $txt = $cmbCountry.Text
    $cmbCountry.Items.Clear()
    foreach ($x in $script:countries) { [void]$cmbCountry.Items.Add($x) }
    $cmbCountry.Text = $txt
}
function Resolve-CountryCode([string]$c) {
    $c = $c.Trim()
    if (-not $c) { return '' }
    if ($c -match '^[A-Za-z]{2}$') { return $c.ToUpper() }
    if (-not $script:geoMap) {
        $script:geoMap = @{}
        try { foreach ($g in [SebGeo]::Countries()) { $script:geoMap[$g[1].ToLower()] = $g[0] } } catch {}
        foreach ($ci in [Globalization.CultureInfo]::GetCultures('SpecificCultures')) {
            try {
                $ri = New-Object Globalization.RegionInfo $ci.Name
                foreach ($n in $ri.EnglishName, $ri.NativeName, $ri.DisplayName) { if ($n -and -not $script:geoMap.ContainsKey($n.ToLower())) { $script:geoMap[$n.ToLower()] = $ri.TwoLetterISORegionName } }
            } catch {}
        }
    }
    $k = $c.ToLower()
    if ($script:geoMap.ContainsKey($k)) { return $script:geoMap[$k] }
    $hits = @($script:geoMap.Keys | Where-Object { $_.StartsWith($k) } | ForEach-Object { $script:geoMap[$_] } | Select-Object -Unique)
    if ($hits.Count -eq 1) { return $hits[0] }
    return $null
}
Load-Countries
$bsSearch = New-Btn $T.Search 472 7 96
$lvRes = New-Object Windows.Forms.ListView
$lvRes.Location = New-Object Drawing.Point(6, 40); $lvRes.Size = New-Object Drawing.Size(562, 260)
$lvRes.View = 'Details'; $lvRes.FullRowSelect = $true; $lvRes.GridLines = $true; $lvRes.HideSelection = $false; $lvRes.MultiSelect = $false
[void]$lvRes.Columns.Add($T.ColName, 210)
[void]$lvRes.Columns.Add($T.ColCountry, 55)
[void]$lvRes.Columns.Add($T.ColCodec, 60)
[void]$lvRes.Columns.Add($T.ColKbps, 45)
[void]$lvRes.Columns.Add($T.ColTags, 170)
$lblSr = New-Object Windows.Forms.Label
$lblSr.Text = $T.SearchHint; $lblSr.Location = New-Object Drawing.Point(6, 306); $lblSr.Size = New-Object Drawing.Size(330, 32)
$lblSr.ForeColor = [Drawing.Color]::DimGray
$bsListen = New-Btn $T.Listen 342 308 96
$bsAdd = New-Btn $T.AddMine 444 308 124
$tabSearch.Controls.AddRange(@($lblQ, $txtQ, $lblCountry, $cmbCountry, $bsSearch, $lvRes, $lblSr, $bsListen, $bsAdd))

function Search-Stations {
    $q = $txtQ.Text.Trim()
    $ctry = $cmbCountry.Text.Trim()
    if (-not $q -and -not $ctry) { $txtQ.Focus(); return }
    $qs = 'limit=300&hidebroken=true&order=clickcount&reverse=true'
    if ($q) { $qs += '&name=' + [Uri]::EscapeDataString($q) }
    if ($ctry) {
        $cc = Resolve-CountryCode $ctry
        if ($cc) { $qs += '&countrycode=' + $cc } else { $qs += '&country=' + [Uri]::EscapeDataString($ctry) }
    }
    $lblSr.Text = $T.Searching
    $lvRes.Items.Clear()
    $mgr.UseWaitCursor = $true; $bsSearch.Enabled = $false
    [Windows.Forms.Application]::DoEvents()
    $res = $null; $ok = $false; $err = ''
    foreach ($h in 'all.api.radio-browser.info', 'de1.api.radio-browser.info', 'de2.api.radio-browser.info', 'fi1.api.radio-browser.info', 'nl1.api.radio-browser.info') {
        try {
            $wc = New-Object Net.WebClient
            $wc.Encoding = [Text.Encoding]::UTF8
            $wc.Headers['User-Agent'] = 'SebRadio/3.2'
            $res = $wc.DownloadString("https://$h/json/stations/search?$qs") | ConvertFrom-Json
            $ok = $true
            break
        } catch { $err = $_.Exception.Message }
    }
    $mgr.UseWaitCursor = $false; $bsSearch.Enabled = $true
    if (-not $ok) { $lblSr.Text = $T.SearchErr + $err; return }
    $lvRes.BeginUpdate()
    foreach ($r in @($res)) {
        if (-not $r) { continue }
        $u = [string]$r.url_resolved; if (-not $u) { $u = [string]$r.url }
        if (-not $u) { continue }
        $n = ([string]$r.name).Trim(); if (-not $n) { $n = Get-HostName $u }
        $it = New-Object Windows.Forms.ListViewItem($n)
        [void]$it.SubItems.Add([string]$r.countrycode)
        [void]$it.SubItems.Add([string]$r.codec)
        [void]$it.SubItems.Add($(if ([int]$r.bitrate -gt 0) { [string]$r.bitrate } else { '' }))
        [void]$it.SubItems.Add(((([string]$r.tags) -replace ',', ', ')))
        $it.Tag = $u
        [void]$lvRes.Items.Add($it)
    }
    $lvRes.EndUpdate()
    $lblSr.Text = $(if ($lvRes.Items.Count -gt 0) { $T.Found -f $lvRes.Items.Count } else { $T.NothingFound })
    if ($ctry -and $lvRes.Items.Count -gt 0) { Remember-Country $ctry }
}
function Get-ResItem { if ($lvRes.SelectedItems.Count -gt 0) { return $lvRes.SelectedItems[0] }; return $null }

$bsSearch.Add_Click({ Search-Stations })
$txtQ.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Enter') { $e.SuppressKeyPress = $true; Search-Stations } })
$cmbCountry.Add_KeyDown({ param($sender, $e) if ($e.KeyCode -eq 'Enter' -and -not $cmbCountry.DroppedDown) { $e.SuppressKeyPress = $true; Search-Stations } })
$bsListen.Add_Click({ $it = Get-ResItem; if ($it) { Play-Url ([string]$it.Tag) } })
$lvRes.Add_DoubleClick({ $it = Get-ResItem; if ($it) { Play-Url ([string]$it.Tag) } })
$bsAdd.Add_Click({
    $it = Get-ResItem; if (-not $it) { return }
    $u = [string]$it.Tag
    $i = Find-StationIndex $u
    if ($i -ge 0) { Show-Msg $mgr ($T.AlreadySaved + $script:stations[$i].Name); return }
    $n = Show-Input $mgr $T.SaveTitle $T.SavePrompt $it.Text
    if (-not $n) { return }
    [void]$script:stations.Add([pscustomobject]@{ Name = $n; Url = $u })
    Save-Stations
    $lblSr.Text = $T.AddedMine + $n
})

$btnManage.Add_Click({
    Fill-Mine (Find-StationIndex $script:curUrl)
    [void]$mgr.ShowDialog($form)
})

# ---------- zapisz / save ----------
$btnSave.Add_Click({
    $url = $txtUrl.Text.Trim()
    if (-not $url) { Show-Msg $form $T.NoUrl; return }
    if ($url -notmatch '^[a-z]+://') { $url = 'http://' + $url; $txtUrl.Text = $url }
    $i = Find-StationIndex $url
    if ($i -ge 0) { Show-Msg $form ($T.AlreadySaved + $script:stations[$i].Name); return }
    $def = ''
    if ((Test-Playing) -and $script:curUrl -eq $url) { $def = $script:stationName }
    if (-not $def) { $def = Get-HostName $url }
    $n = Show-Input $form $T.SaveTitle $T.SavePrompt $def
    if (-not $n) { return }
    [void]$script:stations.Add([pscustomobject]@{ Name = $n; Url = $url })
    Save-Stations
})
$cmbSt.Add_SelectedIndexChanged({
    if ($script:suppressCombo) { return }
    $i = $cmbSt.SelectedIndex - 1
    if ($i -ge 0 -and $i -lt $script:stations.Count) { Play-Url $script:stations[$i].Url }
})
$btnSleep.Add_Click({ $sleepMenu.Show($btnSleep, 0, $btnSleep.Height) })

$form.Controls.AddRange(@($lblSt, $cmbSt, $btnSave, $btnManage, $btnMini, $btnSleep, $btnHist, $btnSettings, $grpRec, $lblUrl, $txtUrl, $btnPaste, $btnPlay, $btnStop, $lblVol, $trkVol, $lblVolVal, $lv, $lblEngine))
$form.AcceptButton = $btnPlay

$btnPlay.Add_Click({ Start-Radio })
$btnStop.Add_Click({ Stop-Radio })
$btnShazam.Add_Click({
    if ($script:shazamBusy) { return }
    if ($script:handle -eq 0) { $lblRec.Text = $T.TurnOn; return }
    $sec = [SebCapture]::BufferedSeconds
    if ($sec -lt 5) { $lblRec.Text = ($T.TooShort -f $sec); return }
    $samples = [SebCapture]::GetLast(12)
    $script:shazamBusy = $true
    $btnShazam.Enabled = $false
    $sync.ShazamDone = $false
    $lblRec.Text = $T.Recognizing
    $ps2 = [PowerShell]::Create()
    [void]$ps2.AddScript($shazamWorker).AddArgument($sync).AddArgument($samples).AddArgument([SebCapture]::Rate).AddArgument($installId).AddArgument($T)
    [void]$ps2.BeginInvoke()
})
$btnPaste.Add_Click({
    $c = [Windows.Forms.Clipboard]::GetText().Trim()
    if ($c) { $txtUrl.Text = $c; Start-Radio }
})
$btnCopyArtist.Add_Click({ Copy-Text $txtArtist.Text })
$btnCopyTitle.Add_Click({ Copy-Text $txtTitle.Text })
$btnCopyAll.Add_Click({ Copy-Text ((@($txtArtist.Text, $txtTitle.Text) | Where-Object { $_ }) -join ' - ') })
function Get-Query { (@($txtArtist.Text, $txtTitle.Text) | Where-Object { $_ }) -join ' ' }
$btnYouTube.Add_Click({
    $q = Get-Query
    if ($q) { Start-Process ('https://www.youtube.com/results?search_query=' + [Uri]::EscapeDataString($q)) }
})
$btnApple.Add_Click({
    if ($script:appleId) { Start-Process "https://music.apple.com/song/$($script:appleId)"; return }
    $q = Get-Query
    if ($q) { Start-Process ('https://music.apple.com/search?term=' + [Uri]::EscapeDataString($q)) }
})
$trkVol.Add_Scroll({
    try { Set-Content -Path $volFile -Value $trkVol.Value -Encoding ASCII } catch {}
    if ($script:handle -ne 0) { [void][SebBass]::BASS_ChannelSetAttribute($script:handle, 2, [float]($trkVol.Value / 100)) }
    $lblVolVal.Text = "$($trkVol.Value)%"
})
$lv.Add_DoubleClick({
    if ($lv.SelectedItems.Count -gt 0) {
        $v = $lv.SelectedItems[0].SubItems[1].Text
        if ($v -and $v -ne '-') {
            [Windows.Forms.Clipboard]::SetText($v)
        }
    }
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 250
$timer.Add_Tick({
    if ($mini.Visible -or $tray.Visible) { Update-MiniTray }
    if ($script:shazamBusy -and $sync.ShazamDone) {
        $script:shazamBusy = $false
        $btnShazam.Enabled = $true
        $lblRec.Text = $sync.ShazamText
        $ok = [bool]($sync.ShazamArtist -or $sync.ShazamTitle)
        if ($ok) {
            $txtArtist.Text = $sync.ShazamArtist
            $txtTitle.Text = $sync.ShazamTitle
            $script:shazamUrl = $sync.ShazamUrl
            $script:appleId = $sync.ShazamApple
            Add-History 'shazam' $sync.ShazamArtist $sync.ShazamTitle $sync.ShazamUrl $sync.ShazamApple
        }
        $btnCopyArtist.Enabled = [bool]$txtArtist.Text
        $btnCopyTitle.Enabled = [bool]$txtTitle.Text
        $btnCopyAll.Enabled = [bool]($txtArtist.Text -or $txtTitle.Text)
        $btnYouTube.Enabled = $btnCopyAll.Enabled
        $btnApple.Enabled = $btnCopyAll.Enabled
    }
    $script:tick2++
    if ($script:tick2 % 8 -eq 0) {
        try { if ((Test-Path -LiteralPath $stFile) -and (Get-Item -LiteralPath $stFile).LastWriteTimeUtc -ne $script:stStamp) { Load-Stations } } catch {}
    }
    if ($script:sleepAt) {
        $left = ($script:sleepAt - (Get-Date)).TotalSeconds
        if ($left -le 0) {
            Stop-Radio
            Set-Sleep 0
            $tray.ShowBalloonTip(4000, 'SebRadio', $T.SleepEnd, 'Info')
        } else {
            if ($left -lt 10 -and $script:handle -ne 0) { [void][SebBass]::BASS_ChannelSetAttribute($script:handle, 2, [float]($trkVol.Value / 100 * $left / 10)) }
            Update-SleepText
        }
    }
    if ($script:recAt) {
        $left = ($script:recAt - (Get-Date)).TotalSeconds
        if ($left -le 0) { Start-Radio -Reconnect }
        else { Set-Info 'Status' ($T.Reconnecting -f [math]::Ceiling($left), $script:recAttempt); return }
    }
    if (-not $script:clickTime) { return }
    if ($script:handle -eq 0) {
        if (-not $sync.Done) { Set-Info 'Status' ($T.ConnectingT -f ((Get-Date) - $script:clickTime).TotalSeconds); return }
        if ($sync.Handle -eq 0) {
            $c = [int]$sync.Error
            $t = $errText[$c]; if (-not $t) { $t = "$($T.ECode) $c" }
            if ($script:autoRec -and $script:recAttempt -gt 0) { Schedule-Reconnect; return }
            Set-Info 'Status' ($T.Error + $t)
            $script:clickTime = $null
            Mark-Current
            return
        }
        $script:handle = $sync.Handle
        [void][SebBass]::BASS_ChannelSetAttribute($script:handle, 2, [float]($trkVol.Value / 100))
        [void][SebBass]::BASS_ChannelPlay($script:handle, $false)
        $ci = New-Object BASS_CHANNELINFO
        if ([SebBass]::BASS_ChannelGetInfo($script:handle, [ref]$ci)) { [void][SebCapture]::Attach($script:handle, $ci.freq, $ci.chans, 15) }
        Update-StreamInfo $script:handle
    }
    $h = $script:handle
    $act = [SebBass]::BASS_ChannelIsActive($h)
    switch ($act) {
        1 {
            if (-not $script:wasPlaying) {
                $script:wasPlaying = $true
                $script:recAttempt = 0
                $script:startTime = Get-Date
                Set-Info 'Czas startu' ('{0:N1} s' -f ($script:startTime - $script:clickTime).TotalSeconds)
            }
            Set-Info 'Status' $T.Playing
        }
        2 {
            $b = [SebBass]::BASS_StreamGetFilePosition($h, 9)
            if ($b -ge 0 -and $b -le 100) { Set-Info 'Status' "$($T.Buffering) $b%" } else { Set-Info 'Status' ($T.Buffering + '...') }
        }
        3 { Set-Info 'Status' $T.Paused }
        default {
            if ($script:autoRec -and ($script:wasPlaying -or $script:recAttempt -gt 0)) { Schedule-Reconnect; return }
            Set-Info 'Status' $T.Ended
        }
    }
    if ($script:startTime) { Set-Info 'Czas słuchania' ((Get-Date) - $script:startTime).ToString('hh\:mm\:ss') }
    $script:tick++
    if ($script:tick % 4 -eq 0) { Update-StreamInfo $h }
})

$form.Add_Shown({
    if (Test-Path $cfgFile) { $txtUrl.Text = (Get-Content $cfgFile -Raw).Trim() }
    try {
        if (Test-Path $volFile) {
            $vol = [int](Get-Content $volFile -Raw).Trim()
            if ($vol -ge 0 -and $vol -le 100) { $trkVol.Value = $vol; $lblVolVal.Text = "$vol%" }
        }
    } catch {}
    try { if (Test-Path $trayFile) { $script:toTray = ((Get-Content $trayFile -Raw).Trim() -eq '1') } } catch {}
    try { if (Test-Path $recFile) { $script:autoRec = ((Get-Content $recFile -Raw).Trim() -ne '0') } } catch {}
    try { if (Test-Path $histOptFile) { $script:logStream = ((Get-Content $histOptFile -Raw).Trim() -ne '0') } } catch {}
    Load-History
    Load-Stations
    Set-Sleep 0
    Set-Info 'Status' $T.Ready
    $timer.Start()
})
$form.Add_FormClosing({
    param($sender, $e)
    if ($script:toTray -and -not $script:reallyExit -and $e.CloseReason -eq 'UserClosing') {
        $e.Cancel = $true
        $form.Hide()
        if (-not $script:trayTipShown) { $script:trayTipShown = $true; $tray.ShowBalloonTip(4000, 'SebRadio', $T.InTray, 'Info') }
        return
    }
    $timer.Stop()
    Stop-Radio
    $script:sleepAt = $null
    $tray.Visible = $false; $tray.Dispose()
    try { $mini.Close() } catch {}
    [void][SebBass]::BASS_Free()
})

[System.Windows.Forms.Application]::Run($form)
