# mpv-scripts
CLOCK, MULTI-STEREO AUDIO-SPEED RANDOMIZATION ([aspeed](aspeed.lua)), MASK ANIME ([automask](automask.lua)), SPECTRUM ([autocomplex](autocomplex.lua)) & SMOOTH CROPPING ([autocrop](autocrop.lua)) FOR [SMPLAYER](https://smplayer.info) & [MPV](https://mpv.io)! TOGGLE ALL THE SCRIPTS BY DOUBLE-CLICKING ON MUTE IN SMPLAYER. ALL PICTURES & VIDEOS CAN BE DRAG & DROPPED ONTO SMPLAYER, TO LIGHT THEM UP.

EXAMPLE INSTALLATION: IN WINDOWS COPY/PASTE THESE .lua SCRIPTS INTO smplayer-portable FOLDER & ENTER 

`--script=autoloader.lua`

IN SMPLAYER ADVANCED PREFERENCES. IN LINUX & MACOS EXTRACT TO Desktop FOLDER mpv-scripts THEN ENTER

`--script=~/Desktop/mpv-scripts/autoloader.lua`

IN LINUX DON'T USE snap. TRY `sudo apt install smplayer` OR `.AppImage` OR `flatpak`. THE SCRIPTS CAN BE OPENED & OPTIONS EDITED IN NOTEPAD (NO WORD WRAP). I USE [NOTEPAD++](https://notepad-plus-plus.org/downloads/) ON WINDOWS, & BRACKETS ON MACOS. ALL FREE FOR WINDOWS, LINUX & MACOS. 🙂

THE automask ABOVE HAS INSTANT TOGGLE ON & OFF! THE autocrop ABOVE IS SMOOTHER THAN v1.2, & USES ONLY vf-command. NO GRAPHS ARE EVER REPLACED, EXCEPT FOR JPEG CROP. THE autocrop v1.2 HAS A FIDGET-TO-THE-RIGHT BUG BECAUSE I MISTOOK 1/a+1/b FOR 1/(a+b). autocomplex ABOVE USES MUCH LESS RAM FOR MP3.

![alt text](https://github.com/TinosNitso/mpv-scripts/blob/main/SCREENSHOT.PNG)
