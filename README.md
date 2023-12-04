# mpv-scripts
Clock, multi-stereo audio-speed randomization ([aspeed](aspeed.lua)), mask anime ([automask](automask.lua)), dual floating spectrum ([autocomplex](autocomplex.lua)) & insta-cropping ([autocrop](autocrop.lua)) for [SMPlayer](https://smplayer.info) & [MPV](https://mpv.io)! Newest scripts in `mpv-scripts.zip` on GitHub. Toggle them by double-clicking on mute (m&m). Pictures, videos & audio can be drag & dropped onto smplayer, to light them up. The scripts can be opened & options edited in Notepad (no word wrap). I use [Notepad++](https://notepad-plus-plus.org/downloads/) on Windows, & Brackets on MacOS. All free for Windows, Linux & MacOS. 🙂

Example installation: In Windows extract all `.lua` scripts from `.zip` & copy/paste them into `smplayer-portable` folder. Then in SMPlayer Advanced Preferences enter 

`--script=autoloader.lua`

Then hit OK & play. Overall I consider playback smoother than VLC. In Linux & MacOS create folder `mpv-scripts` on Desktop. Then extract all scripts into it. Then enter

`--script=~/Desktop/mpv-scripts/autoloader.lua`

In Linux try `sudo apt install smplayer` or double-click the `.AppImage`. All scripts also fully compatible with `.snap` & `.flatpak` releases (`autoloader.lua` has more details). `~/` means home folder in Linux & MacOS.

Advanced: To run in Windows from Command Prompt, create a New Text Document in SMPlayer folder, along with `TEST.MP4`. Then in Notepad enter:

`CMD /K MPV\MPV TEST.MP4 --script=autoloader.lua`

Rename the document `TEST.CMD`. Then double-click it. The command line shows every warning, etc. Linux & MacOS are similar. All these scripts can be run directly from CMD, PowerShell, shell, etc. They do nothing but deliver scripted commands to MPV. But most ppl prefer an interface like SMPlayer. The ideal interface depends on OS, so interface design is a different job.

autocomplex now has dual complex & `freqs_win_func` options. aspeed now has insta-toggle, along with autocrop & automask, but not autocomplex. aspeed also has option for left channel primary. Smooth-cropping no longer supported (too much lag with the dual complex). What's smoother overall is an insta-crop.

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.JPG)
