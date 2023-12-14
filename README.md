# mpv-scripts
Video clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), animated mask generator ([automask](automask.lua)), dual animated spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto SMPlayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

To use on YouTube select Open→URL in SMPlayer. All toggle instantly if you disable the `autocomplex.lua` toggle_on_double_mute option. The mask vanishes or re-appears, along with black-bars & audio switches btwn random & normal. MPV has instant zoom, but unfortunately no scroll bar (to pan around with mouse, etc). Keyboard shortcuts only work if MPV has its own window (SMPlayer preference).

Example installation: In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` folder. Then in SMPlayer Advanced Preferences enter 

`--script=autoloader.lua`

Then hit OK & play. Overall I consider playback smoother than VLC. In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. Then enter

`--script=~/Desktop/mpv-scripts/autoloader.lua`

In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also fully compatible with `.snap` & `.flatpak` releases (`autoloader.lua` has more details). `~/` means home folder in Linux & MacOS.

**Advanced**: To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder & rename it `TEST.CMD`. Also copy in `TEST.MP4`. Then right-click on `TEST.CMD` & click `Edit`. In Notepad copy/paste:

`CMD /K MPV\MPV TEST.MP4 --script=autoloader.lua`

Then Save it & double-click it. The command line shows warnings, etc. MPV pauses when text in CMD is selected. Linux & MacOS are similar. All these scripts can be run from CMD, PowerShell, etc. They do nothing but deliver scripted commands to MPV. But most ppl prefer an interface like SMPlayer.

Before running scripts it's safer to first check them in Notepad++. Ignore all comments (lines starting with `--`). Any code containing `mp.command` (media player), `commandv`, `command_native`, `os.execute` (operating system), `io.popen` (input output process), `subprocess`, etc, can do almost anything, in Windows. To inspect a script highlight those words.

`autocomplex` zoompan now has perfect sync (important bugfix), on YouTube too. `aspeed` now faster on YouTube, with many speakers/devices. Added options `dual_colormix`, `dual_alpha`, `dual_scale`, `dual_overlay`, `feet_threshold_h`, `SHOE_COLOR` & `gb` for neutral blue shade. Also extra 5% for Nyquist. Can also change video/audio track once inside SMPlayer. `CALIBRATION` waves mix into [ao]. Improved options & codes (e.g. `ROUND_SQUARE` in `automask`). Bugfix for `automask` MP3 cover art insta-toggle. `autocrop` now only uses 1 graph. 🙂

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
