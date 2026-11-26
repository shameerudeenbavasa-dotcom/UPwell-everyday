# Upwell Everyday

A new 4K (3840×2160) wallpaper with a motivational quote on your desktop every day, for macOS and Windows.

- Every 7 days it downloads a fresh set of 7 photos from [Picsum](https://picsum.photos) (Unsplash photography) and adds a quote to each.
- It changes the wallpaper every morning at 07:00 and each time you log in.
- It cycles through 35 built-in quotes without repeating until all have been used.

## Install

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
