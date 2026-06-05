# 🐦️ Rob-Bin

Hi, my name is Robert and this is my `/bin`.

Personal Linux scripts, ready to take flight for some quick one-off tasks and various workflow automations. Highly specific to my setup but some of these may be useful for you too.

## Setup

```bash
git clone https://github.com/uhs-robert/rob-bin.git
cd rob-bin
chmod +x bin/*
```

Add `bin/` to your `PATH`, then scripts are available anywhere:

```zsh
export PATH="$PATH:$HOME/your-path-to/rob-bin/bin/"
```

## Library

- **`lib/ui.sh`**: terminal color/formatting functions sourced by bash scripts
- **`lib/functions.sh`**: shell utility functions (`fzfopen`, `fzfcd`, `getip`, etc.), sourced by `~/.zshrc`
- **`lib/terminal_style.rb`**: terminal styling for Ruby scripts

---

## Scripts

### arch_news_check

Uses `paru -Pw`, or `yay -Pw` to fetch unread [Arch Linux news](https://archlinux.org/news/) relative to your system and blocks until the user acknowledges. Designed as a topgrade `pre_run` hook to prevent upgrades when there are breaking news items requiring manual intervention.

On fetch failure, prompts to open the news page manually before proceeding. If neither `paru` nor `yay` is found, same fallback applies.

**Requires:** `paru` or `yay`, `xdg-open`

**Args:** `--yolo` = warn and continue instead of blocking when you skip reading (don't say I didn't warn you...)

**Prompt options:** `y` = acknowledge, `b` = open in browser and acknowledge, `n` = abort (or continue if `--yolo`)

**topgrade setup** — add to `~/.config/topgrade.toml`:

```toml
[pre_run]
"Check Arch News" = "arch-news-check"
```

> The script must be on your `$PATH` as `arch-news-check` (symlink or rename).

### 2pdf

Converts document formats to PDF via LibreOffice. Supports `.doc`, `.docx`, `.odt`, `.rtf`, `.txt`, `.html`.

**Requires:** `libreoffice`

### add_font

Downloads and installs a font from a URL (zip format). Extracts to `~/.local/share/fonts` and refreshes the font cache.

**Requires:** `wget`, `unzip`, `fc-cache`

**Usage:** `add_font <url>`

### add2emu

Moves files from the current directory to an emulator ROM folder on external media at `/run/media/$USER/SHARE`. Built around [Batocera's folder structure](https://wiki.batocera.org/add_games_bios) but works with any emulator using the same layout.

**Requires:** `pv` (tries to auto-install if missing)

**Usage:** `add2emu <emulator_name> [rom|music]`

### clean_empty_dirs

Recursively finds and deletes empty directories. Prompts for confirmation before deletion. Defaults to current directory.

**Usage:** `clean_empty_dirs [directory]`

### compress_files

Compresses files in a directory using a chosen archive format. Optionally deletes originals after compression.

**Formats:** `zip`, `7z`, `rar`, `tar`, `tar.gz`, `tar.bz2`

**Usage:** `compress_files [OPTIONS] [directory]`

### git_bulk_clone

Interactively clones repos from a GitHub org/user. Prompts per repo, skips already-cloned ones.

**Requires:** `gh` (GitHub CLI, authenticated)

**Usage:** `git_bulk_clone [owner] [target_dir]`

Defaults: owner=`uhs-robert`, dir=`~/Development`

### org_files_by_date

Organizes files in a directory into `YYYY/MM` subdirectories based on modification time. Supports copy mode and deletion of old files.

**Usage:** `org_files_by_date [OPTIONS] [directory]`

Options: `-c` (copy instead of move), `-d DAYS` (delete files older than N days)

### sync_to_drive

Syncs `~/Documents` and `~/Pictures` to `GoogleDrive:HomeBackup` via rclone. Logs to `~/.log/cron/`.

**Requires:** `rclone` configured with a `GoogleDrive` remote

### xtract

Extracts compressed files in the current directory. Optionally extracts each archive into its own named subdirectory.

**Formats:** `.zip`, `.tar`, `.gz`, `.bz2`, `.7z`, `.rar`, and more

**Usage:** `xtract [OPTIONS]`

### yazi-lazygit-cd

Opens `lazygit` from within `yazi` and CDs into the most recently active repo on exit.

**Requires:** `lazygit`, `yazi`

Add to `~/.config/yazi/keymap.toml`:

```toml
{ on = ["g", "l"], run = "shell '~/.local/bin/yazi-lazygit-cd' --block --confirm=false", desc = "Lazygit" }
```

### yt2mp3

Downloads audio from YouTube URLs (single URL, playlist, or file of URLs) as MP3 with embedded thumbnail.

**Requires:** `yt-dlp`

**Usage:** `yt2mp3 [-o output_dir] [file|URL]`
