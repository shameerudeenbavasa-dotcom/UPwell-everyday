<p align="center"><img src="icons/icon.png" width="160" alt="Upwell Everyday icon"></p>

# Upwell Everyday

A new 4K (3840×2160) wallpaper with a motivational quote on your desktop every day, for macOS and Windows.

- Every 7 days it downloads a fresh set of 7 photos from [Picsum](https://picsum.photos) (Unsplash photography) and adds a quote to each.
- It changes the wallpaper every morning at 07:00 and each time you log in.
- It cycles through 35 built-in quotes without repeating until all have been used.

## Download

Get the latest installers from the [Releases page](https://github.com/shameerudeenbavasa-dotcom/UPwell-everyday/releases/latest):

- **Windows:** `UpwellEveryday-Setup.exe`. Double-click it; no Python needed. If SmartScreen appears, click **More info → Run anyway**.
- **macOS:** `UpwellEveryday-AppleSilicon.dmg` (M1/M2/M3/M4 Macs) or `UpwellEveryday-Intel.dmg` (older Intel Macs). Not sure which? Apple menu → **About This Mac**: "Chip: Apple…" means Apple Silicon, "Processor: Intel…" means Intel.
  1. Open the DMG and drag **Upwell Everyday** into **Applications**.
  2. The first time, right-click the app in Applications and choose **Open**, then **Open** again (it isn't signed by an Apple-registered developer).
  3. Allow it to control **System Events** when asked. Today's wallpaper appears, and it updates every morning by itself.
  4. To remove it, drag the app to the Trash (it stops running once the app is gone).

## Install from source

### macOS
Needs Python 3 (included with macOS Command Line Tools).
```bash
cd mac
./install_mac.sh
```
On first run, allow the prompt to control **System Events**; that is how the wallpaper is set.

### Windows
Needs Python 3 from [python.org](https://www.python.org/downloads/) (tick "Add to PATH").
Open the `windows` folder and double-click `install_windows.bat`.

## Use
- Get a new set of 7 wallpapers now: run `upwell_everyday.py --refresh` with the installed Python.
- Files live in `~/Library/Application Support/UpwellEveryday` (macOS) or `%APPDATA%\UpwellEveryday` (Windows).

## Uninstall
Run `mac/uninstall_mac.sh` or `windows/uninstall_windows.bat`.
