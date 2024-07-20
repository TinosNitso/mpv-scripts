# mpv-scripts
- [Installation](#installation)
- [Standalone mpv](#standalone-mpv-mpvconf)
- [App Versions](#app-versions)
- [Safety Inspection](#safety-inspection)
- [Terminal Commands](#terminal-commands)
- [Console Commands](#console-commands)
- [Latest Updates](#latest-updates)

Video clocks, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [mpv](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad. Disable word-wrap for these scripts! [main](main.lua) has much more info, & options for which scripts & subtitles load, & ytdl. I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & [Brackets](https://BRACKETS.IO) on MacOS.  All free for Windows, Linux, MacOS & Android. But Android has no extra-device randomization & no YouTube.

To use on YouTube select Open→URL in SMPlayer. Rumble, Odyssey & RedTube also compatible. Double-clicking mute makes the mask smoothly vanish or re-appear, along with black-bars (smooth padding), & the audio switches btwn randomized & normal. aspeed.lua options can activate chipmunk mode on left-channel (in sync), as well as tri-color clocks! autocrop handles transparent input, too, along with a track-list with start & end times. mpv has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if mpv has its own window (SMPlayer preference).

See [doc](doc) folder for pdf manuals.

## Installation
In Windows extract all `.lua` scripts from the `.zip` & copy/paste them into `smplayer-portable` (or smplayer) folder. Then in SMPlayer Advanced Preferences enter 

`--script=.`

`.` is the directory containing `main.lua`. Then hit OK & play. Overall I consider playback smoother than VLC. [main](main.lua) is also a README, but in lua, & has more details. For YouTube also extract [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases) into the same folder. Don't forget to update yt-dlp!

If not portable, or in Linux & MacOS, create folder `mpv-scripts` on Desktop. Then extract all scripts into it.  Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/`

`~/` means home folder. In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also compatible with `.snap` & `.flatpak` releases. 

On Android, go to mpv→SETTINGS→Advanced→Edit mpv.conf, then enter

`script=/sdcard/Android/media/is.xyz.mpv/`

Then copy scripts in to that exact folder, in internal main storage. However leave out autocomplex.lua (lags on smartphone).  `sdcard` is internal, unlike `SD card`.  Then use mpv file-picker to open an MP4 to give mpv media read-permission. In Android-11 media-apps can't normally run scripts from outside a media folder.  aspeed.lua struggles primarily because Android apps are singletons who can't spawn subprocesses.  I use [cx-file-explorer](https://cxfileexplorerapk.net) as explorer, 920 for text-editing, & chromium for browsing. [SNAPDROP.NET](https://SNAPDROP.NET) for lua transfer to smartphone.  

![](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)

## Standalone mpv (`mpv.conf`)
It's also possible to double-click on `mpv.exe` or `mpv.app` & then drag & drop files & URLs directly on mpv, with all scripts fully active! This requires editing `mpv.conf`, like with Android. In Linux edit `~/.config/mpv/mpv.conf`. In MacOS go mpv→Preferences... & use only 1 line:

`script=~/Desktop/mpv-scripts/`

In Windows + SMPlayer: Create New Text Document `smplayer-portable\mpv\mpv\mpv.conf` with Notepad, containing only the 1 line `script=../`. Then double-click `smplayer-portable\mpv\mpv.exe` & drag/drop files/URLs. Simpler than terminal commands!

## App Versions

mpv versions 0.38.0, 0.37.0, 0.36.0, 0.35.1 & 0.34.0 supported. v0.37+ preferred. mpv.exe can be [replaced](https://sourceforge.net/projects/mpv-player-windows/files/release/), within smplayer-portable. New MacOS builds are [here](https://laboratory.stolendata.net/~djinn/mpv_osx/), & Android is [here](https://github.com/mpv-android/mpv-android/releases).

SMPlayer-24.5.0 supported.  Releases tested include .7z .exe .app .AppImage .flatpak & .snap.

FFmpeg versions 6.1 (.deb), 6.0 (.exe .flatpak), 5.1.3, 5.1.2 (.app), 4.4.2 (.snap) & 4.3.2 (.AppImage) supported.

Lua versions 5.1 & 5.2 supported.

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `expand-text` `show-text` `seek` `playlist-next` `playlist-play-index` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. `set*` are safe except for `script-opts` which may hook an unsafe executable. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`). 

## Terminal Commands
To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder & rename it `TEST.CMD`. Also copy in `TEST.MP4`. Then right-click on `TEST.CMD` & click `Edit`. In Notepad copy/paste:

`MPV\MPV --no-config --script=. TEST.MP4`

Then Save it & double-click it. The command line shows warnings, etc. mpv pauses when text in CMD is selected. Most ppl prefer an interface like SMPlayer.

In MacOS go to *Launchpad*→*Other*→*Terminal*. Then the exact `zsh` command is:

- `/Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"`

That uses the mpv bundled with SMPlayer. In Linux the exact command to load YouTube from terminal is:

- `mpv --no-config --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"`

MacOS users can also drag & drop `mpv.app` onto Applications. Then the zsh command is:

- `/Applications/mpv.app/Contents/MacOS/mpv --no-config --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"` 

## Console Commands
Give mpv its own window then press ` & then enter any of these commands (but with proper inputs). The bottom of every script has exact examples, like how to replace black pads with white pads.

- `script-binding toggle_aspeed `
- `script-binding toggle_crop   `
- `script-binding toggle_pad    `
- `script-binding toggle_mask   `
- `script-binding toggle_complex`
- `script-message cleanup       `
- `script-message astreamselect <map>      `
- `script-message detect_crop   <show_text>`
- `script-message apply_aspect  <aspect>   `
- `script-message apply_crop    <meta>     `
- `script-message apply_pad     <pad_options> <pad_scale_flags>`
- `script-message-to automask apply_eq <brightness> <toggle_duration> <toggle_t_delay> <toggle_expr>`

## Latest Updates
Above scripts in `mpv-scripts.zip` haven't been properly released yet.  I still have to test smartphone handling, & improve script-messaging.
- Added `o.android`, `o.windows`, `o.linux` & `o.darwin` platform overrides to all scripts.  Smartphones work better with different options, like binacles.
- Added `o.toggle_command` to all scripts except main.  All toggles can activate any command. Replaces `o.osd_on_toggle` for graph inspections.  
- Added `o.double_aid_timeout` to aspeed, autocrop & automask. Double-aid is similar to double-mute, due to Android (laggy trigger).  A new `playback_restarted` timer blocks all double-tap timers from misfiring. 
- Added `o.double_sid_timeout` to all scripts except main. Best smartphone toggle mechanism. `sub-create-cc-track` is artificially added.
- Added `o.msg_level` to main & autocrop.
- Added `o.script_opts` to main.lua, for `osc-` settings.  Also Improved `ytdl_path` code. More elegant codes.
- Added `function gp` (Get Property) to all scripts.  All script-opt types now well-defined.  A GUI like SMPlayer could hook in various preferences using `--script-opts`.
- Added `function event_handler` to all scripts except main.
- Added `function cleanup()` to all scripts.
- Added remove_filter/s functions to aspeed, autocrop & automask.
- Added `function re_pause()` to autocrop/automask.
- Added script-messages to all scripts, to control them via console/GUI. Every control comes with native type-casting, & an example.
- Improved `script-binding` names for all scripts but main.
- `android-surface-area` W,H computation for automask, autocrop & autocomplex. Binacles are perfect circles on smartphone! Improved examples take portrait/landscape into account.  Graphs all reload on fullscreen rotation.
- Removed `\\,` from all graphs.
- All scripts may now `load` *after* `file-loaded`.
- autocrop.lua: `o.limits` now searches `media-title` as well as `path`.  Replaced `o.pad_color` with `o.pad_options` (`x:y:color`). Improved JPEG reliability & `o.meta_osd`.  Removed `function start_file` - now uses `seek` instead of `set start`.
- automask.lua: Returned `o.fps`. If produced @30fps, film must also be 30fps.  Improved `o.rotations` padding.  Bugfix for examples (I broke half of them in the last release).  Added examples, `SPINNING_TRIANGLES` & `SPINNING_SQUARES_DUAL` (opposing twirls). Removed use of `between`.  More examples which load fast.
- aspeed.lua: `o.speed` now set every half-second in real-time, not film-time.  `--no-config` bugfix for standalone mpv. Removed `o.clocks.no_locales` flag.  Improved AbDays (more accurate, more lowercase).  No-Armenian override for Android.  Faster YouTube load by always loading path - then the controller blocks JPEG using a `block_path` switch.  Enabled `graph` randomization @file-loaded. Improved feedback reliability by checking `samplerate`.  Resync `on_toggle`. Improved event-handling.
- autocomplex.lua: Bugfix for `aid` off/on. It toggles off & on with only one `aid`-click.
- autocrop/automask: `insta_pause` removed from `start-file` function, so can pause during YouTube load.

