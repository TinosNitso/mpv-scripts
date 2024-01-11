----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER  --script=~/Desktop/mpv-scripts/    OR    --script=.    FROM WINDOWS smplayer.exe FOLDER  (USE "" FOR DRIVE LETTERS)   LINUX snap: --script=/home/user/Desktop/mpv-scripts/
----YOUTUBE: https://github.com/yt-dlp/yt-dlp/releases/tag/2023.11.14  EXTRACTING FROM .zip MAY YIELD FASTER EXECUTABLE.

o={ --options  ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF. automask & autocomplex HAVE osd_on_toggle WHICH DISPLAYS VERSION NUMBERS & FILTERGRAPHS. (OTHERWISE main.lua ALSO NEEDS DOUBLE-MUTE TOGGLE.)
        "aspeed.lua",     --CLOCK, TITLE & AUDIO DEVICES SPEED RANDOMIZATION, FOR UP TO 10 HOURS. INSTA-TOGGLE. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND.  MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO A METAPHORICAL MOCKING-BIRD.
        "autocrop.lua",   --CROP OFF BLACK BARS BEFORE mask, BUT AFTER SPECTRAL OVERLAY. INSTA-TOGGLE.  autocrop-smooth.lua FOR SMOOTH VERSION (TOO MUCH CPU WHEN COMBINED → META-LAG).
        "autocomplex.lua",--ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. SLOW TOGGLE (INTERRUPTS PLAYBACK).   MY FAV FOR RELIGION (A PRIEST'S VOICE IS LIKE WINGS OF BIRD). 
        "automask.lua",   --ANIMATED FILTERS (MOVING LENSES, ETC). INSTA-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE VISOR + BUTTERFLY=automask2.lua, 300MB RAM EACH).
    },
    ytdl={    --YOUTUBE DOWNLOAD.  PLACE ALONGSIDE main.lua. LIST ALL POSSIBLE EXECUTABLE FILENAMES. NO ";" ALLOWED. 
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", --CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto. 
    },
    title='{\\fs55\\bord3\\shad1}',--REMOVE TO REMOVE title.  \\,fs,bord,shad = \,FONTSIZE,BORDER,SHADOW (PIXELS)  THIS STYLE CODE SETS THE osd.  b1,i1,u1,s1,be1,fn,c = BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME,COLOR  WITHOUT BOLD, FONT MAY BE LARGER.  cFF=RED,cFF0000=BLUE,ETC
    title_duration=5,              --SECONDS. DEFAULT→NO title (0).
    loop_limit    =10,             --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO) IF duration IS LESS. STOPS MPV SNAPPING.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    
    io_write=' ',--DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY OBSERVATION OF af vf lavfi-complex. PREVENTS EMBEDDED MPV FROM SNAPPING BY COMMUNICATING WITH ITS PARENT APP @GRAPH REPLACEMENT. NEEDED BY autocrop & automask, BUT IT'S AN EMBEDDING ISSUE (MPV IN SMPLAYER OR FIREFOX).
    options =''  --'opt1 val1 opt2 val2 '... FREE FORM.
        ..' osd-border-size 1  osd-scale-by-window no  osd-duration 5000  osd-bar no ' --DEFAULTS 3,yes,1000,yes  (PIXELS,BOOL,MILLISECONDS,BOOL)  1p FOR LITTLE TEXT. SAME font-size WITH LITTLE WINDOW. TAKES A FEW SECS TO READ/SCREENSHOT osd. bar GETS IN THE WAY (SMPLAYER).
        ..' keepaspect no ' --FREE aspect IF MPV HAS ITS OWN WINDOW.
        ..' ytdl-format bestvideo[height<=1080]+bestaudio '  --CAN DROP FROM 4K.
}
for opt,val in pairs({scripts={},ytdl={},title_duration=0,loop_limit=0,io_write='',options=''})
do o[opt]=o[opt] or val end  --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('[^ ]+') --GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) DIDN'T EXIST IN AN OLD LUA VERSION, USED BY mpv.app ON MACOS.
while   val do mp.set_property(opt,val)   --('','') → NULL-set
    opt,val = o.options(),o.options() end --nil @END
for property in ('vf lavfi-complex af'):gmatch('[^ ]+') do mp.observe_property(property,'native',function() io.write(o.io_write) end) end --EMBEDDED PLAYLISTS STILL SNAP (CHANGE IN path).

utils,os =require 'mp.utils',os.getenv('os')           --nil ON MACOS.
directory=utils.split_path(mp.get_property('scripts')) --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
directory=mp.command_native({'expand-path',directory}) --os= yt-dlp REQUIRES ~ EXPANDED. command_native RETURNS.
COLON=os and os:lower():find('windows') and ';' or ':' --FILE LIST SEPARATOR.  WINDOWS=;  UNIX=:

hook,script_opts,scripts = 'ytdl_hook-ytdl_path',mp.get_property_native('script-opts'),mp.get_property_native('scripts')  --hook SCRIPT-OPT SPECIFIES yt-dlp EXECUTABLE. 
for _,ytdl in pairs(o.ytdl) do ytdl=utils.join_path(directory,ytdl)  --join AFTER split.
    script_opts[hook]=script_opts[hook] and script_opts[hook]..COLON..ytdl or ytdl end  --APPEND ALL ytdl.
mp.set_property_native('script-opts',script_opts) --EMPLACE hook.

for _,script in pairs(o.scripts) do is_present=false   
    for _,find in pairs(scripts) do if script:lower()==find:lower() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
        break end end    
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script', utils.join_path(directory,script)) end end  --commandv FOR FILENAMES. join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)   --ANNOUNCE scripts.

function playback_start()   
    mp.unregister_event(playback_start) --1 start PER file (OR STREAM). 
    duration,osd_level = mp.get_property_number('duration'),mp.get_property_number('osd-level') 
    if duration and o.loop_limit>duration then mp.set_property('loop','inf') end   --loop GIF.  

    mp.set_property_number('osd-level',0)   --STOP osd INTERFERENCE FROM SMPLAYER, WITH OR WITHOUT title.
    mp.add_timeout(.1,function() mp.set_property_number('osd-level',osd_level) end) --RETURN osd-level. 
    
    if o.title then title=mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.
         title.data=o.title..mp.get_property_osd('media-title') 
         title:update()  --DISPLAY title.
         mp.add_timeout(o.title_duration,title_remove) end
end
mp.register_event('file-loaded',function() mp.register_event('playback-restart',playback_start) end)

function title_remove()  --remove title ON timeout. BUT ALSO title→nil
    title:remove()
    title=nil  --BUGFIX: title MAY NOT remove IF IT ISN'T SENT TO nil.
end

----mpv TERMINAL COMMANDS:
----WINDOWS   CMD: MPV\MPV --script=. *.MP4      (PLACE scripts & AN MP4 INSIDE smplayer.exe FOLDER)
----LINUX      sh: mpv --script=~/Desktop/mpv-scripts/ https://youtu.be/5qm8PH4xAss
----MACOS     zsh: /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"      
----MACOS mpv.app: /Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications. IT USES AN OLD LUA.)

----SAFETY INSPECTION: LUA SCRIPTS SHOULD BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path frame-step seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE. set IS SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV v0.36.0 (.7z .exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED.  v0.37.0 WORKS WITH 3 OUT OF 5 SCRIPTS, BUT automask & autocomplex FAILED ON WINDOWS & GAVE UNACCEPTABLE PERFORMANCE ON MACOS-11. (v0.36 & OLDER ONLY.)
----FFmpeg v6.0(.7z .exe .flatpak)  v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS ACTUALLY BUILT WITH FFmpeg v4, v5 & v6 (ALL 3), WHICH CHANGES HOW THE GRAPHS ARE WRITTEN (FOR COMPATIBILITY).
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). CAN USE v23.6 (JUNE RELEASE) INSTEAD, OR GIVE MPV ITS OWN WINDOW. SMPLAYER NOW COUPLES A seek-0 WITH pause. IDEALLY IT SHOULD BE AN OPT-OUT PREFERENCE BECAUSE SOME GRAPHS WORK BETTER WITH OR WITHOUT RESET ON PAUSE. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 
----BUG: YOUTUBE PLAYLISTS DON'T LOAD NEXT URL.  CAN USE 2 SMPLAYERS TO PRE-LOAD NEXT URL.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO zoom. seek WITH GRAPHS IS TOO SLOW, BUT zoom INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. FRAME-DROPS MAY CAUSE AUDIO DESYNC UNDER EXCESSIVE LAG.
----A FUTURE VERSION COULD CREATE A RECYCLE BIN FOR STREAMING, UP TO 1GB. CAN STREAM-DUMP ALL YOUTUBE VIDEOS, IN AUTO.
----INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORS, BUT UNNECESSARY. 
----~40%CPU+30%GPU USAGE @FULLSCREEN, WITH PROPRIETARY GRAPHICS DRIVERS. 4%+22% USAGE WITHOUT ANY scripts. @HALF-SCREEN GPU USAGE DROPS TO 20%. WITHOUT DRIVERS TOTAL ~70% CPU USAGE (LITERALLY CPU+GPU→CPU). ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO (SENSITIVE TO HUMAN FACE SMOOTHNESS). WRITING SCRIPTS WITHOUT DRIVERS MAY HELP OPTIMIZE THE GRAPHS THEMSELVES.  
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFmpeg-filters. THEY'RE ALL ~200 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  MPV HAS LUA, JS & JSON (JAVA SCRIPT OBJECT NOTATION).  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK CAN DO ALMOST ANYTHING WITH A 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----sudo apt install smplayer flatpak snapd mpv     FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak install *.flatpak  snap install *.snap  FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap. .AppImage IS OFFLINE.
----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFmpeg-v4.4). THE autocomplex (& MAYBE automask) CODE IS WRITTEN DIFFERENTLY FOR snap COMPATIBILITY.

----o.options DUMP (FREE FORM). TO DEBUG TRY TOGGLE ALL THESE SIMULTANEOUSLY. THEN ISOLATE WHICH LINE FIXED THE BUG. BUT THAT CAN HAVE UNINTENDED CONSEQUENCES.
-- ..' video-timing-offset 1  video-sync display-resample' --MAY FIX STUTTER @vf-command (COMBO LAG WITH OTHER SCRIPTS). CAN ALTER AUDIO samplerate TO MATCH LAG. "display-tempo" GLITCHED.
-- ..' hr-seek-demuxer-offset 1  cache-pause-wait 0  vd-lavc-dropframe nonref  vd-lavc-skipframe nonref'    --BOTH display-resample & display-tempo TRIGGER BUGS.  FRAME TYPES: none default nonref(SKIPnonref) bidir(SKIPBFRAMES) 
-- ..' msg-level ffmpeg/demuxer=error  hr-seek always  index recreate  wayland-content-type none  background red  alpha blend'
-- ..' stream-buffer-size 100000000  demuxer-lavf-buffersize 100000000  audio-reversal-buffer 100000000  video-reversal-buffer 100000000  audio-buffer 100000000'
-- ..' chapter-seek-threshold 100000000  vd-queue-max-samples 100000000  ad-queue-max-samples 100000000  demuxer-max-bytes 100000000  vd-queue-max-bytes 100000000  ad-queue-max-bytes 100000000  demuxer-max-back-bytes 100000000'
-- ..' demuxer-lavf-analyzeduration 100000000  demuxer-termination-timeout 100000000  cache-secs 100000000  vd-queue-max-secs 100000000  ad-queue-max-secs 100000000  demuxer-readahead-secs 100000000' 
-- ..' demuxer-backward-playback-step 100000000  video-backward-overlap 100000000  audio-backward-overlap 100000000  audio-backward-batch 100000000  video-backward-batch 100000000'
-- ..' hr-seek-framedrop yes  access-references yes  ordered-chapters no  stop-playback-on-init-failure yes'
-- ..' osc no  ytdl yes  vd-queue-enable yes  ad-queue-enable yes  cache-pause-initial no  cache-pause no  demuxer-seekable-cache yes  cache yes  demuxer-cache-wait no'
-- ..' video-latency-hacks no  demuxer-lavf-hacks yes  framedrop no  force-window yes  keepaspect-window no  initial-audio-sync no  gapless-audio no  demuxer-donate-buffer yes  demuxer-thread yes  demuxer-seekable-cache yes  force-seekable yes  demuxer-lavf-linearize-timestamps no'



