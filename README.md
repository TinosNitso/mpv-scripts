# mpv-scripts
Video clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

To use on YouTube select Open→URL in SMPlayer. All toggle instantly if you disable the autocomplex `toggle_on_double_mute` option. The mask vanishes or re-appears, along with black-bars, & the audio switches btwn random & normal. MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

## Installation
In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` (or smplayer) folder. Then in SMPlayer Advanced Preferences enter 

`--script=autoloader.lua`

If using `main.lua`, use `--script=.` instead.

Then hit OK & play. Overall I consider playback smoother than VLC. [autoloader](autoloader.lua) is itself a README (in LUA). In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. For YouTube also extract [yt-dlp_linux](https://github.com/yt-dlp/yt-dlp/releases) and/or *yt-dlp_macos* into the same folder. Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/autoloader.lua`

In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also fully compatible with `.snap` & `.flatpak` releases. `~/` means home folder in Linux & MacOS.

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `frame-step` `seek` `playlist-next` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. `set` is safe except for `script-opts` which may hook an unsafe executable. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`). 

## Terminal Commands
To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder & rename it `TEST.CMD`. Also copy in `TEST.MP4`. Then right-click on `TEST.CMD` & click `Edit`. In Notepad copy/paste:

`CMD /K MPV\MPV --script=autoloader.lua *.MP4`

Then Save it & double-click it. The command line shows warnings, etc. MPV pauses when text in CMD is selected. All these scripts can be individually run from CMD, PowerShell, zsh, etc. They only deliver scripted commands to MPV. But most ppl prefer an interface like SMPlayer.

In MacOS go to *Launchpad*→*Other*→*Terminal*. Then the exact `zsh` command is:

`/Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/autoloader.lua "https://youtu.be/5qm8PH4xAss"`

That uses the MPV bundled with SMPlayer. Only good builds make it into `SMPlayer.app/Contents`. In Linux the exact command to load YouTube from terminal is:

`mpv --script=~/Desktop/mpv-scripts/autoloader.lua https://youtu.be/5qm8PH4xAss`

MacOS users can drag & drop mpv.app onto Applications. The following commands assume `main.lua` is present (unreleased, but in above .zip).

`/Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"` 

In Linux to use flatpak & snap versions of MPV the commands are:

`cd /var/lib/flatpak/app/info.smplayer.SMPlayer/current/active/files/bin & mpv --script=~/Desktop/mpv-scripts/ https://youtu.be/5qm8PH4xAss`

`cd /snap/smplayer/current/usr/bin & mpv --script=~/Desktop/mpv-scripts/ https://youtu.be/5qm8PH4xAss`

## Versions

Scripts incompatible with MPV v0.37.0 (all builds). *v0.36* & older only! v0.36.0 & v0.35.1 successful. Maybe 2 or 3 out of 5 scripts work with v0.37. Hopefully the next version is better!

SMPlayer *v23.6.0* & v23.12.0 successful. v23.12 has an annoying `no-osd seek 0 relative exact` accompanying every `set pause yes`. Releases tested include .7z .exe .app .AppImage .flatpak & .snap.

Fmpeg versions *v6.0* & v4.3.2 (.AppImage) successfully tested.

## Latest Updates
Above code & `.zip` is unreleased properly, but passes all my tests so far. I just have to do a couple more Linux tests (.snap & .flatpak updates).
- All scripts now work with `mpv.app` on MACOS-11. It uses an older LUA version, back when the `%g` pattern didn't exist.
- YouTube bugfix `--ytdl-format=[ext!=webm]`. webm is currently incompatible with `lavfi-complex`. It ruined only some videos.
- `autoloader.lua` is replaced by `main.lua`, in which case `--script=.` (directory). title moved from aspeed to main.
- automask now has perfect circles using `geq` (any formula). Also has `o.format` option. Also bugfix (by factor of 2) for how `o.RES_SAFETY` works.
- autocrop now has true aspect toggle. It returns double-black bars properly when you double-click mute.
- autocomplex more efficient code juggling 12.5, 25 & 30 fps. 30 fps for film & automask. `o.freqs_fps_image`, `o.freqs_interpolation` (like fade for freqs) & `o.feet_lutrgb` options added. Proprietary drivers almost halve CPU usage, but it also works fine with FOSS drivers. Somehow shuffling planes is more efficient than mixing colors.
- aspeed improved response time (`o.auto_delay`), & `o.mpv` options. echo to socket isn't allowed on Linux without installing a dependency, so I re-wrote it using only txtfile.
- Many code improvements, like setsar=par, not 1.

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
