<p align="center"><img src="assets/icon.png" width="128" alt="SebRadio"></p>

# SebRadio

**PL** · [EN](#english)

Prosty odtwarzacz radia internetowego dla Windows: wklejasz link do stacji, radio gra, a okno pokazuje informacje o strumieniu. Wbudowane rozpoznawanie utworów (Shazam). Interfejs po polsku i angielsku.

## Funkcje

- Odtwarzanie strumieni **MP3, AAC/AAC+, HLS (`.m3u8`)** oraz playlist **`.pls` / `.m3u`** - silnik [BASS](https://www.un4seen.com/), niezależny od odtwarzacza Windows.
- Szybki start (bufor ok. 1,25 s) i pomiar **czasu startu**.
- Informacje o strumieniu: aktualny utwór, stacja, opis, gatunek, strona WWW, format/kodek, bitrate, częstotliwość, kanały, serwer, czas słuchania. Dwuklik kopiuje wartość.
- **Rozpoznawanie utworu (Shazam)** z ostatnich 12 s dźwięku - osobno wykonawca i tytuł, przyciski kopiowania, wyszukiwanie w **YouTube** i **Apple Music**.
- **Mini odtwarzacz** na wierzchu (play/stop i nazwa stacji, przeciąganie myszą) oraz ikona w **zasobniku obok zegara** z menu; opcjonalnie przycisk X chowa program do zasobnika zamiast go zamykać.
- **Zapisane stacje**: lista „Moje stacje”, przycisk Zapisz, okno Stacje (zmiana nazwy, kolejność, usuwanie, import z `.m3u` / `.pls` / `.txt`). Plik `%AppData%\SebRadio\stacje.txt` w formacie `Nazwa = link` można edytować ręcznie - zmiany są wczytywane automatycznie.
- **Historia utworów**: rozpoznane (Shazam) i podawane przez stację tytuły zapisują się z datą, stacją i linkami do YouTube / Apple Music / Shazam; okno Historia z wyszukiwaniem; plik `%AppData%\SebRadio\historia.csv` (Excel).
- **Wyszukiwarka stacji** w otwartej bazie [radio-browser.info](https://www.radio-browser.info/) (nazwa, kraj).
- **Automatyczne wznawianie** po zerwaniu połączenia i **wyłącznik czasowy** (15-120 min, z wyciszaniem).
- Zapamiętuje ostatni link i głośność. Okno Ustawienia: X do zasobnika, wznawianie, język PL / EN, kolory (akcent, wykończenie, tło).
- Ciemny motyw z niebieskimi przyciskami i pomarańczowymi obramowaniami (od wersji 3.3).

## Instalacja

Pobierz `SebRadio-Setup.exe` z [Releases](../../releases) i uruchom (bez uprawnień administratora). Instalator pozwala wybrać język, folder i skróty, pobiera biblioteki BASS i dodaje wpis w *Zainstalowanych aplikacjach* z deinstalatorem.

Tryb cichy: `SebRadio-Setup.exe -Silent [-Target <folder>] [-Lang pl|en]`

## Wymagania

Windows 10/11 64-bit, PowerShell 5.1 (wbudowany), internet.

## Budowanie

1. `build\version.txt` - numer wersji.
2. `build\Build.cmd` - [ps2exe](https://github.com/MScholtes/PS2EXE) kompiluje `SebRadio.exe`, `Make-Installer.ps1` osadza pliki w instalatorze, ps2exe kompiluje `SebRadio-Setup.exe` (opcjonalnie podpis własnym certyfikatem).

## Uwagi

- Rozpoznawanie korzysta z **nieoficjalnego** API Shazam (to samo, którego używa aplikacja). Może przestać działać po zmianach po stronie Shazam.
- BASS jest darmowy tylko do użytku **niekomercyjnego**; biblioteki nie są w repozytorium - pobiera je instalator lub program przy pierwszym uruchomieniu.

---

## English

A simple internet radio player for Windows: paste a station link, it plays, and the window shows stream details. Built-in song recognition (Shazam). Polish and English UI.

### Features

- Plays **MP3, AAC/AAC+, HLS (`.m3u8`)** streams and **`.pls` / `.m3u`** playlists - [BASS](https://www.un4seen.com/) engine, independent of Windows media components.
- Fast start (~1.25 s buffer) with a **start time** readout.
- Stream info: now playing, station, description, genre, website, format/codec, bitrate, sample rate, channels, server, listening time. Double-click copies a value.
- **Song recognition (Shazam)** from the last 12 s of audio - artist and title separately, copy buttons, search on **YouTube** and **Apple Music**.
- Always-on-top **mini player** (play/stop and station name, drag to move) and a **tray icon** next to the clock with a menu; optionally the X button hides the app to the tray instead of closing it.
- **Saved stations**: "My stations" list, Save button, Stations window (rename, reorder, delete, import from `.m3u` / `.pls` / `.txt`). The file `%AppData%\SebRadio\stacje.txt` (`Name = link`) can be edited by hand - changes are picked up automatically.
- **Song history**: recognized (Shazam) and station-sent titles are saved with date, station and YouTube / Apple Music / Shazam links; History window with search; file `%AppData%\SebRadio\historia.csv` (Excel).
- **Station search** in the open [radio-browser.info](https://www.radio-browser.info/) database (name, country).
- **Automatic reconnect** when the connection drops and a **sleep timer** (15-120 min, with fade-out).
- Remembers the last link and volume. Settings window: X to tray, reconnect, PL / EN language, colors (accent, trim, background).
- Dark theme with blue buttons and orange borders (since version 3.3).

### Install

Download `SebRadio-Setup.exe` from [Releases](../../releases) and run it (no admin rights needed). The installer lets you pick the language, folder and shortcuts, downloads the BASS libraries and adds an *Installed apps* entry with an uninstaller.

Silent mode: `SebRadio-Setup.exe -Silent [-Target <folder>] [-Lang pl|en]`

### Notes

- Recognition uses the **unofficial** Shazam API (the one the app uses). It may stop working if Shazam changes it.
- BASS is free for **non-commercial** use only; the libraries are not in this repository - the installer or the app downloads them on first run.

## Licencja / License

[MIT](LICENSE). Kod sygnatury Shazam przeniesiony z / Shazam signature code ported from [shazam-for-real](https://github.com/AlekseyMartynov/shazam-for-real) (ISC, Copyright (c) Aleksey Martynov) - see [src/LICENSE-shazam-for-real.txt](src/LICENSE-shazam-for-real.txt). BASS © Un4seen Developments.
