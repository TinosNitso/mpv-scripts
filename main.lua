----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER OPTION  --script=~/Desktop/mpv-scripts/  OR ELSE  --script=.  (FROM WINDOWS smplayer.exe FOLDER).  LINUX snap: --script=/home/user/Desktop/mpv-scripts/    ASSUMING mpv-scripts FOLDER IS PLACED ON Desktop.
----https://github.com/yt-dlp/yt-dlp/releases/tag/2024.03.10  FOR YOUTUBE STREAMING.  RUMBLE, ODYSSEY & REDTUBE ALSO.  CAN RE-ASSIGN open_url IN SMPLAYER (EXAMPLE: CTRL+U & SHIFT+TAB).  twitter.com/i/... WORKS WITHOUT seeking & autocomplex.lua.

options     = {
    scripts = { --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.  REPETITION BLOCKED.  SPACES & '' ALLOWED.
        "aspeed.lua"     ,        --EXTRA AUDIO DEVICES SPEED RANDOMIZATION, + SYNCED CLOCKS. INSTA-TOGGLE.  CAN CONVERT MONO TO (RANDOMIZED) SURROUND SOUND, FOR 10 HOURS.  MY FAVOURITE OVERALL. CONVERTS SPEAKERS INTO METAPHORICAL MOCKING-BIRDS.
        "autocrop.lua"   ,        --CROPS BLACK BARS BEFORE automask, BUT AFTER autocomplex. SMOOTH-TOGGLES FOR BOTH CROPPING & EXTRA PADDING. ALSO SUPPORTS start & end TIMES (TIME-CROP SUBCLIPS), & CROPS IMAGES & THROUGH TRANSPARENCY.
        -- "autocrop-smooth.lua", --SMOOTH CROPPING & PADDING. NOT UP TO DATE.  DISABLE autocomplex.lua DUE TO EXCESSIVE CPU USAGE. INCOMPATIBLE WITH .AppImage (FFMPEG-v4.2).
        "autocomplex.lua",        --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE CAN BE LIKE WINGS OF BIRD).  TWITTER INCOMPATIBLE.
        "automask.lua"   ,        --ANIMATED FILTERS (MOVING LENSES, ETC). SMOOTH-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE TRIANGLE_SPIN=automask2.lua, 500MB RAM EACH, +UNIQUE KEYBINDS).
    },
    ytdl = {            --YOUTUBE DOWNLOAD. PLACE EXECUTABLE ALONGSIDE main.lua.  LIST ALL POSSIBLE FILENAMES TO HOOK, IN PREFERRED ORDER. NO ";" ALLOWED.  REMOVE UNIX TO SHORTEN script-opts.  CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto. 
        "yt-dlp"      , --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.  
        "yt-dlp_macos",
    },
    options = { 
        'ytdl-format bv[height<1080]+ba/best    ','      profile fast', --bv,ba = bestvideo,bestaudio  "/best" FOR RUMBLE.  fast FOR MPV.APP (COLORED TRANSPARENCY).  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://youtu.be/8cor7ygb1ms?t=60
        ' keepaspect no  ','keepaspect-window no',                      --DEFAULTS yes,yes  IF MPV HAS ITS OWN WINDOW no,no ALLOWS FREE-SIZING.  keepaspect-window=no FOR MPV.APP.
        '        sub auto','  sub-border-size 2 ','sub-font-size 32  ', --DEFAULTS auto,3,55   sub=sid=auto BEFORE YOUTUBE LOADS.  SIZES OVERRIDE SMPLAYER. SUBS DRAWN @720p.
        '    osd-bar no  ','  osd-border-size 1 ',' osd-duration 5000', --DEFAULTS yes ,3,1000 MILLISECONDS SMPLAYER ALREADY HAS bar. READABLE FONT ON SMALL WINDOW. 1p BORDER FOR LITTLE TEXT. TAKES A FEW SECS TO READ/SCREENSHOT osd.
        '  osd-level 0   ', --PREVENTS UNWANTED MESSAGES @load-script.
    },
    title             = '{\\fs40\\bord2}${media-title}',  --REMOVE FOR NO title.  STYLE OVERRIDES: \\,b1,fs##,bord# = \,BOLD,FONTSIZE(p),BORDER(p)  MORE: alpha##,an#,c######,shad#,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = TRANSPARENCY,ALIGNMENT-NUMPAD,COLOR,SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  cFF=RED,cFF0000=BLUE,ETC  title HAS NO TOGGLE.
    title_duration    =  5, --SECONDS.
    autoloop_duration = 10, --SECONDS.  0 MEANS NO AUTO-loop.  MAX duration TO ACTIVATE INFINITE loop, FOR GIF & SHORT MP4.  NOT FOR JPEG (MIN>0).  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    options_delay     = .3, --SECONDS, FROM playback_start. title ON SAME DELAY.
    options_delayed   = {   --@playback_started+options_delay
        '  osd-level 1',    --RETURN osd-level. DEFAULT=3
        -- '     sid 1','secondary-sid 1',  --UNCOMMENT FOR SUBTITLE TRACK ID OVERRIDE.  auto & 1 NEEDED BEFORE & AFTER lavfi-complex, FOR YOUTUBE.
    },  
}
o,p,timers                    = options,{},{} --p=PROPERTIES  timers={playback_start,title} TRIGGER ONCE PER file
require 'mp.options'.read_options(o)          --mp=MEDIA_PLAYER  ALL options WELL-DEFINED & COMPULSORY.
for   opt in ('autoloop_duration title_duration options_delay'):gmatch('[^ ]+')                          --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME LUA _VERSION, BUILT DIFFERENT).
do  o[opt]                    = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end --string→number: '1+1'→2  load INVALID ON MPV.APP.  ALTERNATIVE loadstring('return {%s}') CAN DO THEM ALL IN 1 table.
for _,opt in pairs(o.options)
do command                    = ('%s no-osd set %s;'):format(command or '',opt) end
command                       = command and mp.command(command)   --ALL SETS IN 1.
for  property in ('platform scripts script-opts'):gmatch('[^ ]+') --string LIST table.
do p[property]                = mp.get_property_native(property) end
directory                     = require 'mp.utils'.split_path(p.scripts[1]) --ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  UTILITIES CAN BE AVOIDED, BUT CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
for _,script  in pairs(o.scripts) 
do script_lower,script_loaded = script:lower()
    for _,val in pairs(p.scripts) 
    do script_loaded          =     script_loaded or  val:lower()==script_lower end  --SEARCH NOT CASE SENSITIVE.  CODE NOT FULLY RIGOROUS.
    commandv                  = not script_loaded and mp.commandv('load-script',('%s/%s'):format(directory,script)) and table.insert(p.scripts,script) end  --commandv FOR FILENAMES. '/' FOR windows & UNIX.
mp.set_property_native('scripts',p.scripts)  --DECLARE scripts (OPTIONAL)
directory,title               = mp.command_native({'expand-path',directory}),mp.create_osd_overlay('ass-events') --command_native EXPANDS '~/' FOR yt-dlp.  ass-events IS THE ONLY FORMAT. title GETS ITS OWN osd.
COLON                         = p.platform=='windows' and ';' or ':' --FILE LIST SEPARATOR.  windows=;  UNIX=:
opt                           = 'ytdl_hook-ytdl_path'                --ABBREV.
for _,ytdl in pairs(o.ytdl) 
do  ytdl                      = directory..'/'..ytdl                                                     --'/' FOR WINDOWS & UNIX.
    p['script-opts'][opt]     = p['script-opts'][opt] and p['script-opts'][opt]..COLON..ytdl or ytdl end --APPEND ALL ytdl AFTER SMPLAYER'S!
mp.set_property_native('script-opts',p['script-opts'])                                                   --EMPLACE ALL ytdl.

function playback_restart()  --ALSO @property_handler
    playback_restarted = true
    if playback_started or p.pause then return end  --AWAIT UNPAUSE, IF PAUSED.  PROCEED ONCE ONLY, PER file.
    playback_started   = true
    set_loop           = p.duration>0 and p.duration<o.autoloop_duration and mp.set_property('loop','inf')  --autoloop BEFORE DELAY. 
    timers.playback_start:resume()
end
mp.register_event('playback-restart',playback_restart)  --AT LEAST 4 STAGES: load-script start-file file-loaded playback-restart  

function property_handler(property,val)                
    p[property] = val
    restart     = not p.pause and playback_restarted  and playback_restart()  --UNPAUSE MAY BE A FIFTH STAGE AFTER playback-restart.
    if property=='path' and not val then playback_started,playback_restarted = set_loop and mp.set_property('loop','no') and nil end  --end-file: loop=no FOR NEXT FILE.  nil RE-ACTIVATES SWITCHES.
end 
for property in ('pause duration loop path'):gmatch('[^ ]+')  --boolean number STRINGS
do mp.observe_property(property,'native',property_handler) end

function after_playback_start()  --@timers.playback_start  DELAY REQUIRED TO SUPPRESS UNWANTED MESSAGES DUE TO SMPLAYER.
    command    = ''
    for _,opt in pairs(o.options_delayed)  --PLAYBACK OVERRIDES.
    do command = ('%s no-osd set %s;'):format(command,opt) end
    command    = command~='' and   mp.command(command)
    title.data = mp.command_native({'expand-text',o.title}) 
    
    title:update()  --AWAITS UNPAUSE (PLAYING MESSAGE).  ALSO AWAITS TIMEOUT, OR ELSE OLD MPV COULD HANG UNDER EXCESSIVE LAG.
    timers.title:resume()
end 

timers.playback_start = mp.add_periodic_timer(o.options_delay ,after_playback_start       )
timers.title          = mp.add_periodic_timer(o.title_duration,function()title:remove()end)
for _,timer in pairs(timers) 
do    timer.oneshot   = 1  --ALL 1SHOT.
      timer:kill() end


----mpv TERMINAL COMMANDS:
----WINDOWS   CMD:  MPV\MPV  --script=.  TEST.MP4      (PLACE scripts & TEST.MP4 INSIDE smplayer.exe FOLDER. THEN COPY/PASTE COMMAND INTO NOTEPAD & SAVE AS TEST.CMD, & DOUBLE-CLICK IT.)
----LINUX      sh:  mpv  --script=~/Desktop/mpv-scripts/  "https://YOUTU.BE/5qm8PH4xAss"
----MACOS MPV.APP:  /Applications/mpv.app/Contents/MacOS/mpv  --script=~/Desktop/mpv-scripts/  "https://YOUTU.BE/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications.  MACOS MAYBE CASE-SENSITIVE.)
---- SMPlayer.app:  /Applications/SMPlayer.app/Contents/MacOS/mpv  --script=~/Desktop/mpv-scripts/  "https://YOUTU.BE/5qm8PH4xAss"      

----https://sourceforge.net/projects/mpv-player-windows/files/release/               FOR NEW MPV WINDOWS BUILDS. CAN REPLACE mpv.exe IN SMPLAYER.
----https://laboratory.stolendata.net/~djinn/mpv_osx/                                FOR NEW MPV MACOS BUILDS.   THESE BUILDS WORK FINE BUT THEIR LUA DOESN'T RECOGNIZE '%g' PATTERN, NOR GREEK (Δ).
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.   OFFLINE LINUX ALL-IN-ONE: SMPlayer-24.5.0-x86_64.AppImage  BUT IT HAS POOR PERFORMANCE (NO SMOOTH-PAD OR TRANSPARENCY).

----SAFETY INSPECTION: LUA & JS SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE.  set* & change-list SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED.  v0.34 INCOMPATIBLE WITH yt-dlp.
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS  windows linux darwin.  Lua 5.1 ONLY!  WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED. 
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----THIS SCRIPT HAS NO TOGGLE.  osd_on_toggle FROM autocomplex & automask COULD BE MOVED HERE, BUT WOULD REQUIRE MORE CODE.  INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL.  DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORING, BUT UNNECESSARY.
----45%CPU+15%GPU USAGE (5%+15% WITHOUT scripts).  ~75%@30FPS (OR 55%@25FPS) WITHOUT GPU DRIVERS, @FULLSCREEN.  ARGUABLY SMOOTHER THAN VLC, DEPENDING (SENSITIVITY TO HUMAN FACE SMOOTHNESS).  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE (CAN CHECK BY ROLLING BACK DISPLAY DRIVER IN DEVICE MANAGER). FREE GPU IMPROVES MULTI-TASKING.
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. MOST TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS. THEY'RE <400 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.  ULTIMATELY TV FIRMWARE (1GB) COULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. 
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK PRODUCES 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----BUG: RARE YT VIDEOS SUFFER no-vid. EXAMPLE: https://youtu.be/y9YhWjhhK-U
----BUG: NO seeking WITH TWITTER.      EXAMPLE: https://twitter.com/i/status/1696643892253466712  x.com ~STREAMING.  NO lavfi-complex.
----BUG: SMPlayer.app yuvj444p IMAGE FORMAT NOT WORKING.  current-vo=shm (SHARED MEMORY) .

----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----sudo apt install smplayer flatpak snapd mpv     FOR RELEVANT LINUX INSTALLS. 
----flatpak install *.flatpak  snap install *.snap  FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap.
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFMPEG-v4.4).

----o.options DUMP. FOR DEBUG CAN TRY TOGGLE ALL THESE SIMULTANEOUSLY.  correct-pts IS ESSENTIAL.
    -- 'correct-pts no','profile fast','vo gpu-next','msg-level all=error','hr-seek always','index recreate','wayland-content-type none','background color','alpha blend',
    -- 'video-latency-hacks yes','hr-seek-framedrop yes','access-references yes','ordered-chapters no','stop-playback-on-init-failure yes',
    -- 'demuxer-lavf-hacks yes','demuxer-lavf-linearize-timestamps no','demuxer-seekable-cache yes','demuxer-cache-wait no','demuxer-donate-buffer yes','demuxer-thread yes',
    -- 'cache yes','cache-pause no','cache-pause-initial no','initial-audio-sync yes','gapless-audio no','force-seekable yes','vd-queue-enable yes','ad-queue-enable yes',
    -- 'framedrop decoder+vo','video-sync desync','vd-lavc-dropframe nonref','vd-lavc-skipframe nonref',  --frame=none default nonref bidir  CAN SKIP NON-REFERENCE OR B-FRAMES.  video-sync=display-resample & display-tempo GLITCHED. 
    -- 'audio-delay 0','cache-pause-wait 0','video-timing-offset 1','hr-seek-demuxer-offset 1','audio-buffer 10',
    -- 'demuxer-lavf-analyzeduration 1024','demuxer-termination-timeout 1024','cache-secs 1024','vd-queue-max-secs 1024','ad-queue-max-secs 1024','demuxer-readahead-secs 1024','audio-backward-overlap 1024','video-backward-overlap 1024','audio-backward-batch 1024','video-backward-batch 1024',
    -- 'demuxer-lavf-buffersize 1000000','stream-buffer-size 1000000','audio-reversal-buffer 1000000','video-reversal-buffer 1000000',
    -- 'vd-queue-max-samples 1000000','ad-queue-max-samples 1000000','chapter-seek-threshold 1000000','demuxer-backward-playback-step 1000000',
    -- 'demuxer-max-bytes 1000000000','demuxer-max-back-bytes 1000000000','vd-queue-max-bytes 1000000000','ad-queue-max-bytes 1000000000',

