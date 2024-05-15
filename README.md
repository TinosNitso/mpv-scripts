# mpv-scripts
- [Installation](#installation)
- [Safety Inspection](#safety-inspection)
- [Terminal Commands](#terminal-commands)
- [Versions](#versions)
- [Latest Updates](#latest-updates)

Video clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). [main](main.lua) has much more info, & options for which scripts & subtitles load, & ytdl. I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

To use on YouTube select Open→URL in SMPlayer. Rumble, Odyssey & RedTube also compatible. Double-clicking mute makes the mask smoothly vanish or re-appear, along with black-bars (smooth padding), & the audio switches btwn randomized & normal. aspeed.lua options can activate chipmunk mode on left-channel (in sync), as well as tri-color clock! autocrop handles transparent input, too, along with a track-list with start & end times. MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

See GitHub `doc` folder for pdf manuals.

## Installation
In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` (or smplayer) folder. Then in SMPlayer Advanced Preferences enter 

`--script=.`

`.` is the directory containing `main.lua`. Then hit OK & play. Overall I consider playback smoother than VLC. [main](main.lua) is like a README (in LUA). 

In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. For YouTube also extract [yt-dlp_linux](https://github.com/yt-dlp/yt-dlp/releases) or *yt-dlp_macos* into the same folder. Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/`

`~/` means home folder. In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also compatible with `.snap` & `.flatpak` releases. 

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `frame-step` `seek` `playlist-next` `playlist-play-index` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. `set*` & `change-list` are safe except for `script-opts` which may hook an unsafe executable. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`). 

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

MPV v0.38.0, v0.37.0, v0.36.0 & v0.35.1 fully supported. v0.37+ preferred. mpv.exe can be [replaced](https://sourceforge.net/projects/mpv-player-windows/files/release/), within smplayer-portable. New MacOS builds are [here](https://laboratory.stolendata.net/~djinn/mpv_osx/).

SMPlayer v24.5.0 supported. v23.12 has an annoying pause issue: `no-osd seek 0 relative exact` accompanying every `set pause yes`. Releases tested include .7z .exe .app .AppImage .flatpak & .snap.

FFmpeg versions v6.1 (.deb), v6.0 (.exe .flatpak), v5.1.3, v5.1.2 (.app), v4.4.2 (.snap) & v4.3.2 (.AppImage) supported.

## Latest Updates
Newest scripts haven't been properly released yet, nor fully tested on Linux. There's a couple more issues to resolve before next release, like an infinite recurring decimal when fast-loading the monacle.
- SMPlayer-24.5...AppImage now supported. It uses FFmpeg-v4.2 - the oldest I've tested! New MPV can be built with any FFmpeg. It needs more rigorous codes, like extra gbrap vs bgra formatting.
- aspeed: Combined `o.timeout` & `o.timeout_pause` with `o.timeouts`. Replaced `o.clock` with `o.clocks`, which includes `duration`, `offset` & `DIRECTIVES_OVERRIDE` sub-options. Added 16 clock examples which cycle btwn each other, including French & Russian (horizontal & vertical tricolors). The OVERRIDE is a clear list of all `os.date` format directives. Improved reliability: should close txtfile & start subprocesses paused. Named filter options. 
- automask has smoother toggle, using only a single `vf-command`. It uses a time-dependent equalizer. Also added a few more examples: PENTAGON_HOUSE, SQUARE_SPIN, TRIANGLE_SPIN & DIAMOND_EYES. Bugfix for FP (frames/period) being off-by-1 (must round, not take floor). Have added `o.fps_mask` to speed up load time for monacle & pentagon (only 2 frames are needed for on/off). So FP has to be exact!
- autocrop `start` (>0) & `end` (<0) time limits implemented better. Added `o.keybinds_pad` for padding toggle, `o.format` for transparent bars. Rapid pad-toggling now smooth, using pad_time corrections. Can now handle odd output dimensions, & smooth padding for raw JPEG. Replaced `o.detector_image`, `o.detect_limit_image` & `o.detect_min_ratio_image` with `o.options_image`. Combined `o.TOLERANCE` options, too. Pad-on or off state now preserved btwn tracks. Improved SMPlayer.app support (shared memory requires removing alpha). 
- autocomplex: Combined `o.freqs_mode`, `o.freqs_win_size`, `o.freqs_win_func` & `o.freqs_averaging` into `o.freqs_options`. Combined `o.volume_fade` & `o.volume_dm` into `o.volume_options`. Combined `o.volume_highpass` & `o.volume_dynaudnorm` into `o.volume_filterchain`. Combined `o.volume_width` & `o.volume_height` into `o.volume_scale` options. Removed `o.freqs_alpha` & `o.gb`. Safe zoompan for shrunk primary (it can zoom little without clipping). Improved codes & commentary.
- automask & autocrop both have `o.toggle_clip` formula for non-linear toggle transition. They also have `osd-par` observations (or par override in `o.dimensions`), for displays with non-square pixels. autocrop also takes the source par into account. They also have terminal gaps for insta_unpause (bugfix for SMPlayer-v24.5).


![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
