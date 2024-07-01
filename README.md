# mpv-scripts
- [Installation](#installation)
- [Safety Inspection](#safety-inspection)
- [Terminal Commands](#terminal-commands)
- [Versions](#versions)
- [Latest Updates](#latest-updates)

Video clocks, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). [main](main.lua) has much more info, & options for which scripts & subtitles load, & ytdl. I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS.  All free for Windows, Linux, MacOS & Android. But Android has no extra-device randomization, & only sans-serif font (no Armenian), & no ytdl.

To use on YouTube select Open→URL in SMPlayer. Rumble, Odyssey & RedTube also compatible. Double-clicking mute makes the mask smoothly vanish or re-appear, along with black-bars (smooth padding), & the audio switches btwn randomized & normal. aspeed.lua options can activate chipmunk mode on left-channel (in sync), as well as tri-color clocks! autocrop handles transparent input, too, along with a track-list with start & end times. MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

See GitHub `doc` folder for pdf manuals.

## Installation
In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` (or smplayer) folder. Then in SMPlayer Advanced Preferences enter 

`--script=.`

`.` is the directory containing `main.lua`. Then hit OK & play. Overall I consider playback smoother than VLC. [main](main.lua) is like a README (in LUA). 

In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. For YouTube also extract [yt-dlp_linux](https://github.com/yt-dlp/yt-dlp/releases) or *yt-dlp_macos* into the same folder. Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/`

`~/` means home folder. In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also compatible with `.snap` & `.flatpak` releases. 

On Android, go to mpv→SETTINGS→Advanced→Edit mpv.conf, then enter

`script=/sdcard/Android/media/is.xyz.mpv/`

Then copy all scripts in to that exact folder, in internal main storage. `sdcard` is internal, unlike SD card.  Then use MPV file-picker to open an MP4 to give it media read-permission. In Android-v11+ media-apps can't run scripts from outside a media folder.  aspeed.lua struggles primarily because Android apps are singletons who can't spawn subprocesses.  I recommend [cx-file-explorer](https://cxfileexplorerapk.net/) as explorer, & 920 for text-editing.  

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `show-text` `seek` `playlist-next` `playlist-play-index` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. `set*` are safe except for `script-opts` which may hook an unsafe executable. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`). 

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

## App Versions

MPV v0.38.0, v0.37.0, v0.36.0 & v0.35.1 fully supported. v0.37+ preferred. mpv.exe can be [replaced](https://sourceforge.net/projects/mpv-player-windows/files/release/), within smplayer-portable. New MacOS builds are [here](https://laboratory.stolendata.net/~djinn/mpv_osx/), & Android is [here](https://github.com/mpv-android/mpv-android/releases).

SMPlayer v24.5.0 supported. v23.12 had an annoying pause/seek issue. Releases tested include .7z .exe .app .AppImage .flatpak & .snap.

FFmpeg versions v6.1 (.deb), v6.0 (.exe .flatpak), v5.1.3, v5.1.2 (.app), v4.4.2 (.snap) & v4.3.2 (.AppImage) supported.

Lua versions v5.1 & v5.2(Android) supported.

## Latest Updates
- main.lua/aspeed.lua: Added `o.options_android`, for Droid Sans Mono.  All scripts working on Android except for aspeed.lua (no subprocesses & no Armenian). `o.speed` works.  But no YouTube.  However autocomplex.lua is too slow on cheap smartphone.  Automask isn't giving perfect circles without manual override (w,h) option.
- Double-mute toggles valid on Android, using its audio-track selector button.  Smartphone could also use better mechanism in future.
- aspeed.lua: Removed Irish.  Longer & improved AbDays. Many lowercase for better symmetry.  Improved child-feedback reliability.  YouTube bugfix where it reloads, without JPEG ever loading (removed reload-blocking).
- autocrop.lua: Removed `o.msg_level`.
- autocomplex.lua: Added `o.gsubs_passes` & `o.gsubs`. Formulas now abbreviated.  Improved automask gsubs.  Improved codes.
- autocomplex/automask: Added `(rand)` gsub for randomization @file-loaded.  Enables unique positioning & mask on each load.

