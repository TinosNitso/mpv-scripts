----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER  --script=~/Desktop/mpv-scripts/    OR    --script=.    FROM WINDOWS smplayer.exe FOLDER  (USE "" FOR DRIVE LETTERS)  FULL PATH FOR LINUX snap: --script=/home/user/Desktop/mpv-scripts/
----YOUTUBE: https://github.com/yt-dlp/yt-dlp/releases/tag/2023.11.14  EXTRACTING FROM .zip MAY YIELD FASTER EXECUTABLE.

o={ --options  ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.
        "aspeed.lua",     --CLOCK, TITLE & AUDIO DEVICES SPEED RANDOMIZATION, FOR UP TO 10 HOURS. INSTA-TOGGLE. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND.  MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO A METAPHORICAL MOCKING-BIRD.
        "autocrop.lua",   --CROP OFF BLACK BARS BEFORE mask, BUT AFTER SPECTRAL OVERLAY. INSTA-TOGGLE.  autocrop-smooth.lua FOR SMOOTH VERSION (TOO MUCH CPU WHEN COMBINED → META-LAG).
        "autocomplex.lua",--ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. SLOW TOGGLE (INTERRUPTS PLAYBACK).   MY FAV FOR RELIGION (A PRIEST'S VOICE IS LIKE WINGS OF BIRD). 
        "automask.lua",   --ANIMATED FILTERS (MOVING LENSES, ETC). INSTA-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE VISOR + BUTTERFLY=automask2.lua, 300MB RAM EACH).
    },
    ytdl={    --YOUTUBE DOWNLOAD.  PLACE ALONGSIDE main.lua. LIST ALL POSSIBLE EXECUTABLE FILENAMES. NO ";" ALLOWED. 
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", --CAN SET SMPLAYER TO USE mpv INSTEAD OF auto.
    },
    title='{\\fs55\\bord3\\shad1}',  --REMOVE TO remove title.  \\,fs,bord,shad = \,FONTSIZE,BORDER,SHADOW (PIXELS)  REMOVE TO REMOVE title. THIS STYLE CODE SETS THE osd.  b1,i1,u1,s1,be1,fn,c = BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME,COLOR  WITHOUT b1, fs MAY BE LARGER.  cFF=RED,cFF0000=BLUE,ETC
    title_duration=5,  --SECONDS. DEFAULT→NO title (0).
    loop_limit    =10, --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO) IF duration IS LESS. STOPS MPV SNAPPING.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    io_write      =' ',--DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY OBSERVATION OF vf lavfi-complex af. PREVENTS EMBEDDED MPV FROM SNAPPING ON IMAGES, BY COMMUNICATING WITH ITS PARENT APP @POINT OF GRAPH INSERTION.
    
    options=''  --'opt1 val1 opt2 val2 '... FREE FORM.
        ..' ytdl-format bestvideo[height<=1080]+bestaudio ' --LIMIT ytdl DOWN FROM 4K. OVERRIDES SMPLAYER. AN ALTERNATIVE IS TO CHECK FIRST.
        ..' osd-font-size 16  osd-border-size 1  osd-scale-by-window no  osd-duration 5000  osd-bar no ' --DEFAULTS 55,3,yes,1000,yes  (PIXELS,PIXELS,BOOL,MILLISECONDS,BOOL)  16p,1p FITS ALL TEXT, WITHOUT SCALING LITTLE. TAKES A FEW SECS TO READ/SCREENSHOT osd. bar GETS IN THE WAY (SMPLAYER).
        ..' keepaspect no  geometry 50% ' --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL DEFAULT SIZE.
}
for opt,val in pairs({scripts={},ytdl={},title_duration=0,loop_limit=0,io_write='',options=''})
do if not o[opt] then o[opt]=val end end --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('%g+') --%g+=GLOBAL MATCH ITERATOR, LONGEST TO SPACEBAR.  '','' → NULL-SET
while   val do mp.set_property(opt,val) 
    opt,val = o.options(),o.options() end --nil @END
for property in ('vf lavfi-complex af'):gmatch('%g+') do mp.observe_property(property,'native',function() io.write(o.io_write) end) end

utils    =require 'mp.utils'
directory=utils.split_path(mp.get_property('scripts')) --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
directory=mp.command_native({'expand-path',directory}) --yt-dlp REQUIRES ~ EXPANDED. command_native RETURNS.

COLON,OS,hook = ':',os.getenv('OS'),'ytdl_hook-ytdl_path'      --: FOR UNIX OPERATING SYSTEMS. FILE LIST SEPARATOR.  hook SCRIPT-OPT SPECIFIES yt-dlp EXECUTABLE. 
if OS and OS:upper():find('WINDOWS',1,true) then COLON=';' end --; FOR WINDOWS.  1,true = STARTING_INDEX,EXACT_MATCH  

script_opts,scripts,title = mp.get_property_native('script-opts'),mp.get_property_native('scripts'),mp.create_osd_overlay('ass-events') --native FOR FILENAMES.  ass-events IS THE ONLY VALID OPTION.
for _,ytdl in pairs(o.ytdl) do ytdl=utils.join_path(directory,ytdl) --join AFTER split.
    if not script_opts[hook] then script_opts[hook]=ytdl 
    else   script_opts[hook]=script_opts[hook]..COLON..ytdl end end --APPEND ALL ytdl.
mp.set_property_native('script-opts',script_opts) --EMPLACE hook.

for _,script in pairs(o.scripts) do is_present=false   
    for _,find in pairs(scripts) do if script:lower()==find:lower() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
        break end end    
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script', utils.join_path(directory,script)) end end  --commandv FOR FILENAMES. join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)   --ANNOUNCE scripts.

function playback_start()   
    mp.unregister_event(playback_start) --1 start PER file. title_duration COUNTS FROM playback.
    duration,osd_level = mp.get_property_number('duration'),mp.get_property_number('osd-level') 
    if duration and o.loop_limit>duration then mp.set_property('loop','inf') end   --loop GIF.  
    if not o.title then return end  --title BELOW.
    
    mp.set_property_number('osd-level',0)   --STOP osd INTERFERENCE FROM SMPLAYER.
    title.data=o.title..mp.get_property_osd('media-title') 
    title:update()  --DISPLAY title.
    
    mp.add_timeout(.1,function() mp.set_property_number('osd-level',osd_level) end) --RETURN osd-level.
    mp.add_timeout(o.title_duration,function() title:remove() end)  --remove title ON timeout.
end
mp.register_event('file-loaded',function() mp.register_event('playback-restart',playback_start) end)


----mpv TERMINAL COMMANDS:
----WINDOWS CMD:  MPV\MPV --script=. *.MP4       (PLACE scripts & AN MP4 INSIDE smplayer.exe FOLDER)
----LINUX:        mpv --script=~/Desktop/mpv-scripts/ https://youtu.be/5qm8PH4xAss
----MACOS zsh:    /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"

----SAFETY INSPECTION: LUA SCRIPTS SHOULD BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path frame-step seek playlist-next quit af* vf* ARE ALL SAFE.  set IS SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV v0.36.0 (INCL. v3) v0.35.0 (.7z) v0.35.1 (.flatpak)  TESTED.
----FFmpeg v5.1.2 v5.1.3(MACOS) v4.3.2(LINUX .AppImage) v6.0(LINUX) TESTED.
----WIN10 MACOS-11 LINUX-DEBIAN-MATE  (ALL 64-BIT)           TESTED. ALL SCRIPTS PASS snap+ytdl INSPECTION.  
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. 

----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). FIX: CAN USE v23.6 (JUNE RELEASE) INSTEAD, OR GIVE MPV ITS OWN WINDOW. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 
----BUG: YOUTUBE PLAYLISTS DON'T LOAD NEXT URL.  CAN USE 2 SMPLAYERS TO PRE-LOAD NEXT URL.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO zoom. seek WITH GRAPHS IS TOO SLOW, BUT zoom INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. FRAME-DROPS MAY CAUSE AUDIO DESYNC UNDER EXCESSIVE LAG.
----A FUTURE VERSION COULD CREATE A RECYCLE BIN FOR STREAMING, UP TO 1GB. CAN STREAM-DUMP ALL YOUTUBE VIDEOS, IN AUTO.
----INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORS, BUT UNNECESSARY. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFmpeg-filters. THEY'RE ALL ~200 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  MPV HAS LUA, JS & JSON (JAVA SCRIPT OBJECT NOTATION).  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK CAN DO ALMOST ANYTHING WITH A 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----~40% CPU USAGE @FULLSCREEN, WITH PROPER DRIVERS. WITHOUT DRIVERS UP TO DOUBLE.  UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO & CPU/GPU. 
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----LINUX BUILDS ADD MORE VARIETY: AppImage, flatpak, snap, deb & rpm. VIDEO SCRIPTING FOR LINUX CAN BE TRICKY, BECAUSE IDEALLY ALL scripts SHOULD WORK WITH ALL BUILDS.
----sudo apt install smplayer flatpak mpv snapd  FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR LINUX TESTING. .AppImage IS MOST FUNDAMENTAL.
----flatpak install *.flatpak  FOR flatpak.
----sudo snap install --dangerous *.snap  TO OFFLINE-INSTALL smplayer*.snap WITHOUT ALL SIGNATURES.  IT DOESN'T WORK WITH "~/", NOR SOME FILTERS THE EXACT SAME WAY, LIKE shuffleplanes,negate=y,scale=flags:eval. IT ALSO BLOCKS SYSTEM COMMANDS.

----o.options DUMP: FREE FORM. TO DEBUG TRY TOGGLE ALL THESE SIMULTANEOUSLY. THEN ISOLATE WHICH LINE FIXED THE BUG. BUT THAT CAN HAVE UNINTENDED CONSEQUENCES.
-- ..' video-timing-offset .5  video-sync display-resample' --MAY FIX STUTTER @vf-command (COMBO LAG WITH OTHER SCRIPTS). CAN ALTER AUDIO samplerate TO MATCH LAG. "display-tempo" GLITCHED.
-- ..' hr-seek-demuxer-offset 1  cache-pause-wait 0  vd-lavc-dropframe nonref  vd-lavc-skipframe nonref'    --BOTH display-resample & display-tempo TRIGGER BUGS.  FRAME TYPES: none default nonref(SKIPnonref) bidir(SKIPBFRAMES) 
-- ..' msg-level ffmpeg/demuxer=error  hr-seek always  index recreate  wayland-content-type none  background red  alpha blend'
-- ..' stream-buffer-size 1e9  demuxer-lavf-buffersize 1e9  audio-reversal-buffer 1e9  video-reversal-buffer 1e9  audio-buffer 1e9'
-- ..' chapter-seek-threshold 1e9  vd-queue-max-samples 1e9  ad-queue-max-samples 1e9  demuxer-max-bytes 1e9  vd-queue-max-bytes 1e9  ad-queue-max-bytes 1e9  demuxer-max-back-bytes 1e9'
-- ..' demuxer-lavf-analyzeduration 1e9  demuxer-termination-timeout 1e9  cache-secs 1e9  vd-queue-max-secs 1e9  ad-queue-max-secs 1e9  demuxer-readahead-secs 1e9' 
-- ..' demuxer-backward-playback-step 1e9  video-backward-overlap 1e9  audio-backward-overlap 1e9  audio-backward-batch 1e9  video-backward-batch 1e9'
-- ..' hr-seek-framedrop yes  access-references yes  ordered-chapters no  stop-playback-on-init-failure yes'
-- ..' osc no  ytdl yes  vd-queue-enable yes  ad-queue-enable yes  cache-pause-initial no  cache-pause no  demuxer-seekable-cache yes  cache yes  demuxer-cache-wait no'
-- ..' framedrop no  force-window yes  keepaspect-window no  initial-audio-sync no  video-latency-hacks yes  demuxer-lavf-hacks yes  gapless-audio no  demuxer-donate-buffer yes  demuxer-thread yes  demuxer-seekable-cache yes  force-seekable yes  demuxer-lavf-linearize-timestamps no'



