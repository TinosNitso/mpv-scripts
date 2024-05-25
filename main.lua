----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER OPTION  --script=~/Desktop/mpv-scripts/  OR ELSE  --script=.  (FROM WINDOWS smplayer.exe FOLDER).  LINUX snap: --script=/home/user/Desktop/mpv-scripts/    ASSUMING mpv-scripts FOLDER IS PLACED ON Desktop.
----https://github.com/yt-dlp/yt-dlp/releases/tag/2024.03.10  FOR YOUTUBE STREAMING.  RUMBLE, ODYSSEY & REDTUBE ALSO.  CAN RE-ASSIGN open_url IN SMPLAYER (EXAMPLE: CTRL+U & SHIFT+TAB).  twitter.com/i/... WORKS WITHOUT seeking & autocomplex.lua.

options={     --ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.  autocomplex & automask HAVE osd_on_toggle WHICH DISPLAYS VERSION NUMBERS & FILTERGRAPHS.
        "aspeed.lua",             --EXTRA AUDIO DEVICES SPEED RANDOMIZATION, + SYNCED CLOCKS. INSTA-TOGGLE.  CAN CONVERT MONO TO (RANDOMIZED) SURROUND SOUND, FOR 10 HOURS.  MY FAVOURITE OVERALL. CONVERTS SPEAKERS INTO METAPHORICAL MOCKING-BIRDS.
        "autocrop.lua",           --CROPS OFF BLACK BARS BEFORE automask, BUT AFTER autocomplex. SMOOTH-TOGGLE. ALSO SUPPORTS START & END TIMES (TIME-CROP SUBCLIPS), & CROPS THROUGH TRANSPARENCY.
        -- "autocrop-smooth.lua", --SMOOTH CROPPING & PADDING. NOT UP TO DATE.  DISABLE autocomplex.lua DUE TO EXCESSIVE CPU USAGE. INCOMPATIBLE WITH .AppImage (FFMPEG-v4.2).
        "autocomplex.lua",        --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE CAN BE LIKE WINGS OF BIRD).  TWITTER INCOMPATIBLE.
        "automask.lua",           --ANIMATED FILTERS (MOVING LENSES, ETC). SMOOTH-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE TRIANGLE_SPIN=automask2.lua, 500MB RAM EACH WITH UNIQUE KEYBINDS).
    },
    ytdl={    --YOUTUBE DOWNLOAD. PLACE ALONGSIDE main.lua.  LIST ALL POSSIBLE EXECUTABLE FILENAMES, IN PREFERRED ORDER. NO ";" ALLOWED.  
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", --CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto. 
    },
    title             = '{\\fs55\\bord3}',  --REMOVE TO REMOVE title.  STYLE OVERRIDES: \\,fs##,bord# = \,FONTSIZE(p),BORDER(p)  MORE: alpha##,an#,c######,b1,shad#,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = TRANSPARENCY,ALIGNMENT-NUMPAD,COLOR,BOLDSHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  cFF=RED,cFF0000=BLUE,ETC  title HAS NO TOGGLE.
    title_duration    =  5, --DEFAULT=0 SECONDS.  COUNTS FROM PLAYBACK-START.
    autoloop_duration = 10, --SECONDS. MAX duration FOR INFINITE loop.  FOR GIF & SHORT MP4.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    options           = { 
        'ytdl-format bv[height<1080]+ba/best    ',  --bv,ba = bestvideo,bestaudio  "/best" FOR RUMBLE.  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://youtu.be/8cor7ygb1ms?t=60
        'keepaspect  no  ','        profile fast',  --FREE aspect IF MPV HAS ITS OWN WINDOW.  profile=fast MAY HELP WITH EXCESSIVE LAG (VIRTUALBOX-MACOS). 
        '       sub  auto','sub-border-size 2   ','sub-font-size 32  ',  --DEFAULTS no ,3,55    (BOOL,PIXELS,PIXELS)  sub=sid=auto BEFORE YOUTUBE LOADS.  SIZES OVERRIDE SMPLAYER. SUBS DRAWN @720p.
        '   osd-bar  no  ','osd-border-size 2   ',' osd-duration 5000',  --DEFAULTS yes,3,1000  (BOOL,PIXELS,ms    )  SMPLAYER ALREADY HAS bar. READABLE FONT ON SMALL WINDOW. 1p BORDER FOR LITTLE TEXT. TAKES A FEW SECS TO READ/SCREENSHOT osd. 
        -- 'osd-level 0  ', --UNCOMMENT TO PREVENT SPURIOUS WARNINGS @LOAD (OLD SMPLAYER).
    },
    options_playback_start={
        -- 'sid       1','secondary-sid 1',  --UNCOMMENT FOR SUBTITLE TRACK ID OVERRIDE, @PLAYBACK-START. (ALSO secondary-sid.)  BY TRIAL & ERROR, auto & 1 NEEDED BEFORE & AFTER lavfi-complex, FOR YOUTUBE.
        -- 'osd-level 1',  --UNCOMMENT TO RETURN OSD.
    },
}  
o                     = options  --ABBREVIATION.
for   opt in ('title_duration autoloop_duration'):gmatch('[^ ]+')  --CONVERSION TO NUMBERS IF NEEDED ('1+1'→2).  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID FOR mpv.app (SAME VERSION LUA, BUILT DIFFERENT).
do  o[opt]            = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end  --string→number.  load INVALID ON mpv.app.  ALTERNATIVE loadstring('return {%s}') CAN DO THEM ALL IN 1 table.
for _,opt in pairs(o.options or {})
do command            = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
if command then mp.command(command) end  --mp=MEDIA-PLAYER
script_opts,scripts   = mp.get_property_native('script-opts'),mp.get_property_native('scripts')  --get_property_native FOR FILENAMES.
directory             = require 'mp.utils'.split_path(scripts[1])    --ASSUME PRIMARY DIRECTORY.  split FROM WHATEVER THE USER ENTERED.  UTILITIES CAN BE AVOIDED, BUT CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory             = mp.command_native({'expand-path',directory}) --yt-dlp REQUIRES ~/ EXPANDED. command_native RETURNS. hook SPECIFIES yt-dlp EXECUTABLE.
COLON                 = mp.get_property('platform')=='windows' and ';' or ':'     --FILE LIST SEPARATOR.  WINDOWS=;  UNIX=:
hook,title            = 'ytdl_hook-ytdl_path',mp.create_osd_overlay('ass-events') --ass-events IS THE ONLY FORMAT.
for _,ytdl in pairs(o.ytdl or {}) 
do  ytdl              = directory..'/'..ytdl  --'/' FOR WINDOWS & UNIX.
    script_opts[hook] = script_opts[hook] and script_opts[hook]..COLON..ytdl or ytdl end  --APPEND ALL ytdl.
mp.set_property_native('script-opts',script_opts)  --EMPLACE hook.  ALTERNATIVE change-list WON'T ALLOW BOTH " " & "'" IN THE FILENAMES.

for _,script  in pairs(o.scripts or {}) do is_present=false   
    for _,val in pairs(  scripts      ) do is_present=is_present or script:lower()==val:lower() end  --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).  COULD ALSO USE string.find.
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script',directory..'/'..script) end end  --commandv FOR FILENAMES. join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)  --ANNOUNCE scripts.  SHOULD PROBABLY BE DONE WITH directory..'/'

function playback_start()               --title WAITS FOR PLAYBACK START.
    if playback_started then return end --ONLY ONCE, PER LOAD.
    playback_started,duration = 1,mp.get_property_number('duration')  --JPEG duration = nil&0 @file-loaded&playback-restart. MAY NOT BE TRUE DURATION DUE TO FILTERS.
    loop        = duration<(o.autoloop_duration or 0) and mp.get_property('loop')
    command     = loop and 'no-osd set loop inf;' or ''
    for _,opt in pairs(o.options_playback_start or {})  --PLAYBACK OVERRIDES.
    do command  = ('%s no-osd set %s;'):format(command,opt) end
    if command ~='' then mp.command(command) end 
    
    if o.title 
    then title.data = o.title..mp.get_property_osd('media-title')
         title:update()  --CAN CAUSE STREAM TO HANG UNDER EXCESSIVE LAG (& WITHOUT profile=fast, IN VIRTUALBOX-MACOS.)
         mp.add_timeout(o.title_duration or 0,function()title:remove()end) end
end
mp.register_event('playback-restart',playback_start)

function end_file()
    playback_started=nil  --RE-REGISTERS playback_start.
    if loop then mp.set_property('loop',loop) end  --RETURN WHATEVER IT WAS.
end
mp.register_event('end-file',end_file)


----mpv TERMINAL COMMANDS:
----WINDOWS   CMD: MPV\MPV --script=. TEST.MP4      (PLACE scripts & TEST.MP4 INSIDE smplayer.exe FOLDER. THEN COPY/PASTE COMMAND INTO NOTEPAD & SAVE AS TEST.CMD, & DOUBLE-CLICK IT.)
----LINUX      sh: mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"
----MACOS mpv.app: /Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications.)
---- SMPlayer.app: /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"      

----https://sourceforge.net/projects/mpv-player-windows/files/release/               FOR NEW MPV WINDOWS BUILDS. CAN REPLACE mpv.exe IN SMPLAYER.
----https://laboratory.stolendata.net/~djinn/mpv_osx/                                FOR NEW MPV MACOS BUILDS.   THESE BUILDS WORK FINE BUT THEIR LUA DOESN'T RECOGNIZE '%g', NOR GREEK (Δ).
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.   OFFLINE LINUX ALL-IN-ONE: SMPlayer-24.5.0-x86_64.AppImage  BUT IT HAS POOR PERFORMANCE.

----SAFETY INSPECTION: LUA & JS SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE.  set* & change-list SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED.  v0.34 INCOMPATIBLE WITH yt-dlp_x86.
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----THIS SCRIPT HAS NO TOGGLE. INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORING, BUT UNNECESSARY.
----45%CPU+20%GPU USAGE (5%+20% WITHOUT scripts).  ~75%@30FPS (OR 55%@25FPS) WITHOUT GPU DRIVERS, @FULLSCREEN.  ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO (SENSITIVITY TO HUMAN FACE SMOOTHNESS).  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE (CAN CHECK BY ROLLING BACK DISPLAY DRIVER IN DEVICE MANAGER).
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. MOST TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS. THEY'RE ALL <300 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.  ULTIMATELY TV FIRMWARE (1GB) COULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. 
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK PRODUCES 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----BUG: RARE YT VIDEOS LOAD no-vid. EXAMPLE: https://youtu.be/y9YhWjhhK-U
----BUG: NO seeking WITH TWITTER.    EXAMPLE: https://twitter.com/i/status/1696643892253466712  x.com NO STREAMING.  NO lavfi-complex.

----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----sudo apt install smplayer flatpak snapd mpv     FOR RELEVANT LINUX INSTALLS. 
----flatpak install *.flatpak  snap install *.snap  FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap.
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFMPEG-v4.4).

----o.options DUMP. FOR DEBUG CAN TRY TOGGLE ALL THESE SIMULTANEOUSLY.
    -- 'framedrop decoder+vo','video-sync desync','vd-lavc-dropframe nonref','vd-lavc-skipframe nonref',  --frame=none default nonref bidir  CAN SKIP NON-REFERENCE OR B-FRAMES.  video-sync=display-resample & display-tempo GLITCHED. 
    -- 'vo libmpv','msg-level ffmpeg/demuxer=error','hr-seek always','index recreate','wayland-content-type none','background color','alpha blend',
    -- 'video-latency-hacks yes','hr-seek-framedrop yes','access-references yes','ordered-chapters no','stop-playback-on-init-failure yes',
    -- 'osc no','ytdl yes','cache yes','cache-pause no','cache-pause-initial no','initial-audio-sync yes','gapless-audio no','keepaspect-window no','force-seekable yes','vd-queue-enable yes','ad-queue-enable yes',
    -- 'demuxer-lavf-hacks yes','demuxer-lavf-linearize-timestamps no','demuxer-seekable-cache yes','demuxer-cache-wait no','demuxer-donate-buffer yes','demuxer-thread yes',
    -- 'audio-delay 0','cache-pause-wait 0','video-timing-offset 1','hr-seek-demuxer-offset 1','audio-buffer 10',
    -- 'demuxer-lavf-analyzeduration 1024','demuxer-termination-timeout 1024','cache-secs 1024','vd-queue-max-secs 1024','ad-queue-max-secs 1024','demuxer-readahead-secs 1024','audio-backward-overlap 1024','video-backward-overlap 1024','audio-backward-batch 1024','video-backward-batch 1024',
    -- 'demuxer-lavf-buffersize 1000000','stream-buffer-size 1000000','audio-reversal-buffer 1000000','video-reversal-buffer 1000000',
    -- 'vd-queue-max-samples 1000000','ad-queue-max-samples 1000000','chapter-seek-threshold 1000000','demuxer-backward-playback-step 1000000',
    -- 'demuxer-max-bytes 1000000000','demuxer-max-back-bytes 1000000000','vd-queue-max-bytes 1000000000','ad-queue-max-bytes 1000000000',

