# mpv-scripts
- [Installation](#installation)
- [Safety Inspection](#safety-inspection)
- [Terminal Commands](#terminal-commands)
- [Versions](#versions)
- [Latest Updates](#latest-updates)

Video clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). main.lua has much more information, & decides which scripts are loaded. I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

To use on YouTube select Open→URL in SMPlayer. Rumble, Odyssey & RedTube also directly compatible. Double-clicking mute makes the mask vanish or re-appear, along with black-bars, & the audio switches btwn random & normal. aspeed.lua options can activate chipmunk mode on left-channel (in sync), as well as tri-color clock! MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

## Installation
In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` (or smplayer) folder. Then in SMPlayer Advanced Preferences enter 

`--script=.`

`.` is the directory containing `main.lua`. Then hit OK & play. Overall I consider playback smoother than VLC. [main](main.lua) is like a README (in LUA). 

In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. For YouTube also extract [yt-dlp_linux](https://github.com/yt-dlp/yt-dlp/releases) or *yt-dlp_macos* into the same folder. Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/`

In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also fully compatible with `.snap` & `.flatpak` releases. `~` means home folder.

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `frame-step` `seek` `playlist-next` `playlist-play-index` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. `set` is safe except for `script-opts` which may hook an unsafe executable. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`). 

## Terminal Commands
To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder & rename it `TEST.CMD`. Also copy in `TEST.MP4`. Then right-click on `TEST.CMD` & click `Edit`. In Notepad copy/paste:

`CMD /K MPV\MPV --script=. *.MP4`

Then Save it & double-click it. The command line shows warnings, etc. MPV pauses when text in CMD is selected. All these scripts can be individually run via CMD, PowerShell, zsh, sh, etc. They only deliver scripted commands to MPV. But most ppl prefer an interface like SMPlayer.

In MacOS go to *Launchpad*→*Other*→*Terminal*. Then the exact `zsh` command is:

`/Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"`

That uses the MPV bundled with SMPlayer. In Linux the exact command to load YouTube from terminal is:

`mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"`

MacOS users can also drag & drop `mpv.app` onto Applications. Then the zsh command is:

`/Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"` 

## Versions

MPV-v0.36 & older only for the latest release! v0.36.0 & v0.35.1 tested. v0.38.0 & v0.37.0 work with all the scripts above which aren't in a proper release yet.

SMPlayer *v23.6.0* & v23.12.0 successful. v23.12 has an annoying `no-osd seek 0 relative exact` accompanying every `set pause yes` (user hits spacebar). Releases tested include .7z .exe .app .AppImage .flatpak & .snap.

FFmpeg versions v6.1 (.deb), v6.0 (.exe .flatpak), v5.1.3, v5.1.2 (.app), v4.4.2 (.snap) & v4.3.2 (.AppImage) successfully tested.

## Latest Updates
Above scripts (`mpv-scripts.zip`) haven't been properly released, but have many new features. Further MacOS testing needed.
- All scripts now work with the latest mpv, versions 0.38.0 & 0.37.0.  Rumble, Odyssey & RedTube also stream, like YouTube.
- autocrop & autocrop-smooth are now spacetime croppers! Support track list with start & end crop times, like sub-clips which remove credits.  Can also crop transparent input.  Added `o.pad_color` & `o.no_vid`. 
- `o.toggle_duration` added to autocrop, automask & autocrop-smooth. They now have smooth toggles using vf-command! autocrop has smooth padding. autocrop & aspeed optimized by only performing commands or sets when needed.
- `o.sid` added to main.lua for subtitle overrides. 
- Targeted vf-commands for autocrop, automask & aspeed. Backwards compatible.
- aspeed improved reliability & toggle. Observes samplerate (removed the option). Subprocesses start in `--idle` mode (removed `o.start` but trigger isn't perfect). Added `o.timeout_mute`. 
- autocomplex can now repeatedly change vid track. "Invalid timestamp" & "100 buffers queued" warnings resolved. Improved avgblur=planes setting. Added `o.filterchain` & `o.dual_filterchain` options. However the toggle's slow. v0.38.0 needs even dimensions! Better code alignment. 
- Removed `o.format` & `o.io_write` & par from autocrop, automask & autocomplex. Removed `select` filter from automask & autocomplex. Removed all use of utilities except for `split_path`. 

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
