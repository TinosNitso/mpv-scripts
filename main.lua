----WINDOWS    :  --script=.                                  IN SMPLAYER'S ADVANCED mpv PREFERENCES.  PLACE ALL scripts WITH smplayer.exe
----LINUX/MACOS:  --script=~/Desktop/mpv-scripts/             IN SMPLAYER.  PLACE mpv-scripts ON Desktop.  LINUX snap: --script=/home/user/Desktop/mpv-scripts/
----ANDROID    :    script=/sdcard/Android/media/is.xyz.mpv/  IN ADVANCED SETTING Edit mpv.conf.  PLACE ALL SCRIPTS IN THIS EXACT FOLDER IN INTERNAL MAIN STORAGE. OTHER FOLDERS DON'T WORK IN ANDROID-v11+.  ENABLE MPV MEDIA-ACCESS USING ITS FILE-PICKER.  'sdcard'~='SD card'(EXTERNAL)  CAN ALSO INSTALL cx-file-explorer & 920 (.APK).  920 CAN HANDLE WORDWRAP & WHITESPACE.
----https://GITHUB.COM/yt-dlp/yt-dlp/releases/tag/2024.03.10  FOR YOUTUBE STREAMING.  RUMBLE, ODYSSEY & REDTUBE ALSO.  CAN RE-ASSIGN open_url IN SMPLAYER (EXAMPLE: CTRL+U & SHIFT+TAB).  twitter.com/i/... WORKS WITHOUT seeking & autocomplex.lua.

options     = {                
    scripts = {                   --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE.  CAN TOGGLE THEM USING TYPOS/RENAME.  REPETITION BLOCKED.  SPACES & '' ALLOWED.
        "aspeed.lua"            , --EXTRA AUDIO DEVICES SPEED RANDOMIZATION, + SYNCED CLOCKS. INSTA-TOGGLE (DOUBLE-MUTE).  CAN CONVERT MONO TO (RANDOMIZED) SURROUND SOUND, FOR 10 HOURS.  MY FAVOURITE OVERALL. CONVERTS SPEAKERS INTO METAPHORICAL MOCKING-BIRDS.  NOT FULLY ANDROID-COMPATIBLE.
        "autocrop.lua"          , --CROPS BLACK BARS. TOGGLES FOR BOTH CROPPING & EXTRA PADDING (SMOOTHLY). DOUBLE-MUTE TOGGLES.  ALSO SUPPORTS start & end TIME-CROP SUBCLIPS, & CROPS IMAGES & THROUGH TRANSPARENCY.
        -- "autocrop-smooth.lua", --SMOOTH CROPPING & PADDING. NOT UP TO DATE & NOT FOR ANDROID.  DISABLE autocomplex.lua DUE TO EXCESSIVE CPU USAGE. INCOMPATIBLE WITH .AppImage (FFMPEG-v4.2).
        "autocomplex.lua"       , --NOT FOR SMARTPHONE (LAG).  ANIMATED AUDIO SPECTRUMS, VOLUME BARS, FPS LIMITER. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE CAN BE LIKE WINGS OF BIRD).  TWITTER INCOMPATIBLE.
        "automask.lua"          , --ANIMATED FILTERS (MOVING LENSES, ETC). SMOOTH-TOGGLE (DOUBLE-MUTE).  CAN SPEED-LOAD MONACLE/PENTAGON ON SMARTPHONE.  LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE TRIANGLE_SPIN=automask2.lua, 500MB RAM EACH, +UNIQUE KEYBINDS).
    },
    ytdl = {            --YOUTUBE DOWNLOAD. PLACE EXECUTABLE ALONGSIDE main.lua.  LIST ALL POSSIBLE FILENAMES TO HOOK, IN PREFERRED ORDER. NO ";" ALLOWED.  CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto.  NOT ANDROID-COMPATIBLE.
        "yt-dlp"      , --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.  REMOVE THESE TO SHORTEN script-opts.  
        "yt-dlp_macos", 
    },
    options = {                                                         --COULD BE RENAMED config.
        'ytdl-format     bv[height<1080]+ba/best','profile       fast', --bv,ba = bestvideo,bestaudio  "/best" FOR RUMBLE.  fast FOR MPV.APP (COLORED TRANSPARENCY).  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://YOUTU.BE/8cor7ygb1ms?t=60
        'sub-border-size  2','sub-font-size   32',  --DEFAULTS auto,3,55   sub=sid=auto BEFORE YOUTUBE LOADS.  SIZES OVERRIDE SMPLAYER. SUBS DRAWN @720p.
        'osd-level        0','osd-bar         no','osd-border-size  1','osd-duration  5000','osd-font "COURIER NEW"','osd-bold yes',  --DEFAULTS 3,yes,3,1000,sans-serif,no   osd-level=0 PREVENTS UNWANTED MESSAGES @load-script.  SMPLAYER ALREADY HAS bar. READABLE FONT ON SMALL WINDOW. 1p BORDER FOR LITTLE TEXT.  1000 MILLISECONDS ISN'T ENOUGH TO READ/SCREENSHOT osd.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS IS PROPRIETARY & INVALID ON MACOS.
    },
    title             = '{\\fs40\\bord2}${media-title}',  --REMOVE FOR NO title.  STYLE OVERRIDES: \\,b1,fs##,bord# = \,BOLD,FONTSIZE(p),BORDER(p)  MORE: alpha##,an#,c######,shad#,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = TRANSPARENCY,ALIGNMENT-NUMPAD,COLOR,SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  cFF=RED,cFF0000=BLUE,ETC  title HAS NO TOGGLE.
    title_duration    =  5 , --SECONDS.
    autoloop_duration = 10 , --SECONDS.  0 MEANS NO AUTO-loop.  MAX duration TO ACTIVATE INFINITE loop, FOR GIF & SHORT MP4.  NOT FOR JPEG (MIN>0).  BASED ON https://GITHUB.COM/zc62/mpv-scripts/blob/master/autoloop.lua
    options_delay     = .3 , --SECONDS, FROM playback_start. title ON SAME DELAY.
    options_delayed   = {    --@playback_started+options_delay, FOR EVERY FILE.
        'osd-level 1',       --DEFAULT=3.  RETURN osd-level. 
        -- 'sid    1','secondary-sid 1',  --UNCOMMENT FOR SUBTITLE TRACK ID OVERRIDE.  USEFUL FOR YOUTUBE + lavfi-complex. sid=1 BUGS OUT DUE TO sub-create-cc-track.
    },
    android     = {  
        options = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"'},  --options ARE SPECIAL & APPEND, NOT REPLACE.
    },
    windows     = {}, linux = {}, darwin = {},  --platform OVERRIDES.
}
o,o2,p,timers = options,{},{},{} --TABLES.  p=PROPERTIES.  timers={playback_start,title} TRIGGER ONCE PER file
for opt,val in pairs(o)          --o2=oCLONE  LUA DOESN'T SUPPORT COPYING TABLES.
do o2[opt] = val end 
require 'mp.options'.read_options(o)  --mp=MEDIA_PLAYER  READS IN STRINGS, SUCH AS FROM GUI INTERFACE. USER MAY ENTER 1+1 INSTEAD OF 2, ETC.

for  opt,val in pairs(o)
do o[opt]      = type(val)=='string' and type(o2[opt])~='string' and loadstring('return '..val)() or val end  --NATIVE TYPECAST.  load INVALID ON MPV.APP.  NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  ALTERNATIVE loadstring('return {%s}') CAN DO THEM ALL IN 1 table.
gp             = mp.get_property_native
for  property in ('platform scripts script-opts'):gmatch('[^ ]+') --string TABLES.  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME LUA _VERSION, DIFFERENT BUILD).
do p[property] = gp(property) end

for _,opt in pairs((o[p.platform] or {}).options or {}) do table.insert(o.options,opt) end  --APPEND TO o.options.
for _,opt in pairs(o.options)
do  command                   = ('%s no-osd set %s;'):format(command or '',opt) end
command                       = command and mp.command(command) --ALL SETS IN 1.
for opt,val in pairs(o[p.platform] or {})                       --platform OVERRIDE.
do o[opt]                     = val end
directory                     = require 'mp.utils'.split_path(p.scripts[1]) --ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  UTILITIES CAN BE AVOIDED, BUT CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
for _,script  in pairs(o.scripts) 
do script_lower,script_loaded = script:lower(),nil
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

function playback_restart()  --ALSO @on_pause
    playback_restarted = true
    if playback_started or p.pause then return end  --AWAIT UNPAUSE, IF PAUSED.  PROCEED ONCE ONLY, PER file.
    
    playback_started,p.duration = true,gp('duration')                                            --ONLY AFTER UNPAUSE.
    set_loop = p.duration>0 and p.duration<o.autoloop_duration and mp.set_property('loop','inf') --autoloop BEFORE DELAY.
    timers.playback_start:resume()
end
mp.register_event('end-file',function() playback_restarted,playback_started = set_loop and mp.set_property('loop','no' ) and nil end) --CLEAR SWITCHES FOR NEXT FILE.  UNDO-set_loop.
mp.register_event('playback-restart',playback_restart)  --AT LEAST 4 STAGES: load-script start-file file-loaded playback-restart  

function on_pause(_,  paused)                
    p.pause     =     paused
    try_restart = not paused and playback_restarted and playback_restart()  --UNPAUSE MAY BE A FIFTH STAGE AFTER playback-restart.
end 
mp.observe_property('pause','bool',on_pause)

function title_update()  --@timers.playback_start  DELAY REQUIRED TO SUPPRESS UNWANTED MESSAGES DUE TO SMPLAYER.
    command    = ''
    for _,opt in pairs(o.options_delayed)  --PLAYBACK OVERRIDES.
    do command = ('%s no-osd set %s;'):format(command,opt) end
    command    = command~=''   and mp.command(command)
    title.data = mp.command_native({'expand-text',o.title}) 
    
    title:update()  --AWAITS UNPAUSE (PLAYING MESSAGE).  ALSO AWAITS TIMEOUT, OR ELSE OLD MPV COULD HANG UNDER EXCESSIVE LAG.
    timers.title:resume()
end 

timers.playback_start = mp.add_periodic_timer(o.options_delay ,          title_update     )
timers.title          = mp.add_periodic_timer(o.title_duration,function()title:remove()end)
for _,timer in pairs(timers) 
do    timer.oneshot   = 1  --ALL 1SHOT.
      timer:kill() end


----mpv TERMINAL COMMANDS:
----WINDOWS   CMD:  MPV\MPV --script=. TEST.MP4      (PLACE scripts & TEST.MP4 INSIDE smplayer.exe FOLDER. THEN COPY/PASTE COMMAND INTO NOTEPAD & SAVE AS TEST.CMD, & DOUBLE-CLICK IT.)
----LINUX      sh:  mpv --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss"
----MACOS MPV.APP:  /Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications.  MACOS MAYBE CASE-SENSITIVE.)
---- SMPLAYER.APP:  /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss"      

----https://SOURCEFORGE.NET/projects/mpv-player-windows/files/release               FOR NEW MPV WINDOWS BUILDS. CAN REPLACE mpv.exe IN SMPLAYER.
----https://laboratory.STOLENDATA.NET/~djinn/mpv_osx                                FOR NEW MPV MACOS   BUILDS.  https://BRACKETS.IO FOR TEXT-EDITOR.  THESE BUILDS WORK FINE BUT '%g' (PATTERN) & Δ (GREEK) ARE INVALID.  
----https://GITHUB.COM/mpv-android/mpv-android/releases                             FOR NEW MPV ANDROID BUILDS.  https://CXFILEEXPLORERAPK.NET
----https://SMPLAYER.INFO/en/download-linux & https://apt.FRUIT.JE/ubuntu/jammy/mpv FOR LINUX SMPLAYER & MPV.   OFFLINE LINUX ALL-IN-ONE: SMPlayer-24.5.0-x86_64.AppImage  BUT IT HAS POOR PERFORMANCE (NO SMOOTH-PAD OR TRANSPARENCY).

----SAFETY INSPECTION: LUA & JS SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path expand-text show-text seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE.  set* SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE.
----MPV  v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED.  v0.34 INCOMPATIBLE WITH yt-dlp.
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS  windows linux darwin(Lua 5.1) android(Lua 5.2) ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  ANDROID HAS NO ytdl & WON'T OPEN IMAGES (JPEG/PNG).
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----~100 LINES & ~2000 WORDS.  SPACE-COMMAS FOR SMARTPHONE. SOME TEXT EDITORS DON'T HAVE LEFT/RIGHT KEYS.  LEADING COMMAS ON EACH LINE ARE AVOIDED.  
----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----50%CPU+20%GPU USAGE (5%+15% WITHOUT scripts).  ~75%@30FPS (OR 55%@25FPS) WITHOUT GPU DRIVERS, @FULLSCREEN.  ARGUABLY SMOOTHER THAN VLC, DEPENDING (SENSITIVITY TO HUMAN FACE SMOOTHNESS).  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE (CAN CHECK BY ROLLING BACK DISPLAY DRIVER IN DEVICE MANAGER). FREE GPU IMPROVES MULTI-TASKING.
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. MOST TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS.  ULTIMATELY TV FIRMWARE (1GB) COULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. 
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK PRODUCES 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  BRACKETS FOR TEXT-EDITING (WORD-WRAP).  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc
----DECLARING local VARIABLES MAY IMPROVE HIGHLIGHTING/COLORING, BUT UNNECESSARY.
----correct-pts ESSENTIAL (SET BY SMPLAYER).

----BUG: SOME YT VIDEOS GLITCH @START (PAUSING).  EXAMPLE: https://YOUTU.BE/D22CenDEs40
----BUG: RARE YT VIDEOS SUFFER no-vid.            EXAMPLE: https://YOUTU.BE/y9YhWjhhK-U
----BUG: NO seeking WITH TWITTER.                 EXAMPLE: https://TWITTER.COM/i/status/1696643892253466712  X.COM NO STREAMING.  NO lavfi-complex.
----BUG: SMPlayer.app yuvj444p albumart-format NOT WORKING.  current-vo=shm (SHARED MEMORY).

----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----sudo apt install smplayer flatpak snapd mpv            FOR RELEVANT LINUX INSTALLS. 
----flatpak install *.flatpak  snap install *.snap         FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap.
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFMPEG-v4.4).

