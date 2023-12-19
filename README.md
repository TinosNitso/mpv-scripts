# mpv-scripts
Video clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

To use on YouTube select Open→URL in SMPlayer. All toggle instantly if you disable the autocomplex `toggle_on_double_mute` option. The mask vanishes or re-appears, along with black-bars, & the audio switches btwn random & normal. MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

## Installation
In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` folder. Then in SMPlayer Advanced Preferences enter 

`--script=autoloader.lua`

Then hit OK & play. Overall I consider playback smoother than VLC. [autoloader](autoloader.lua) is itself a README (in LUA). In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. Then in SMPlayer enter

`--script=~/Desktop/mpv-scripts/autoloader.lua`

In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also fully compatible with `.snap` & `.flatpak` releases. `~/` means home folder in Linux & MacOS.

## Safety Inspection
Before running scripts it's safer to first check them in Notepad++. Search for & highlight `os.execute` (operating system), `io.popen` (input output process) & `mp.command*` (media player). Safe commands include `expand-path` `frame-step` `seek` `stop` `quit` `af*` `vf*`, but `load-script` `run` `subprocess*` may be unsafe. To inspect a script check potentially unsafe commands. Ignore all comments (anything following `--`).

## Advanced (mpv)
To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder & rename it `TEST.CMD`. Also copy in `TEST.MP4`. Then right-click on `TEST.CMD` & click `Edit`. In Notepad copy/paste:

`CMD /K MPV\MPV TEST.MP4 --script=autoloader.lua`

Then Save it & double-click it. The command line shows warnings, etc. MPV pauses when text in CMD is selected. All these scripts can be individually run from CMD, PowerShell, etc. They do nothing but deliver scripted commands to MPV. But most ppl prefer an interface like SMPlayer. In MacOS go to Launchpad→Other→Terminal. Then the exact `zsh` command is:

`/Applications/SMPlayer.app/Contents/MacOS/mpv ~/Desktop/mpv-scripts/TEST.MP4 --script=~/Desktop/mpv-scripts/autoloader.lua`

That uses the MPV bundled with SMPlayer. Only good builds make it into `SMPlayer.app/Contents`. FFmpeg version: 5.1.2, but the latest is v6, hence graphs require more filter/s for backwards compatibility.

## Latest Updates
Next release delayed for more testing & improved spells. Above updates include fixed YouTube title (`aspeed`), fixed MacOS YouTube (`autoloader`), many bugfixes & improved codes. `autocomplex` double-normalizer & better shoe color. Improved `automask` code. Need some recording/s before next release. 

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
