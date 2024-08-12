----NO-WORD-WRAP FOR THIS SCRIPT.  https://GITHUB.COM/yt-dlp/yt-dlp/releases  FOR YOUTUBE STREAMING.  CHECK FOR UPDATED BUILDS OR ELSE SOME NEW UPLOADS AREN'T SUPPORTED.  RUMBLE, ODYSSEY, REDTUBE & RUTUBE.RU ALSO.  CAN RE-ASSIGN open_url IN SMPLAYER (EXAMPLE: CTRL+U & SHIFT+TAB).  X.COM NOT seeking.
----WINDOWS    :  --script=.                       IN SMPLAYER  &/OR  script=../                     IN mpv.conf.  PLACE ALL scripts WITH smplayer.exe & ENTER ITS ADVANCED mpv PREFERENCES.  CAN ALSO CREATE 1-LINE TEXT-FILE  mpv\mpv\mpv.conf  INSIDE smplayer-portable.  mpv.conf ENABLES DOUBLE-CLICKING mpv.exe & DRAG & DROP OF FILES & YOUTUBE URL, IN LINUX/MACOS TOO.  IF NOT PORTABLE, SET-UP IS LIKE FOR LINUX: --script=~/Desktop/mpv-scripts/  
----LINUX/MACOS:  --script=~/Desktop/mpv-scripts/  IN SMPLAYER  &/OR  script=~/Desktop/mpv-scripts/  IN mpv.conf.  PLACE mpv-scripts ON Desktop.  EDIT ~/.config/mpv/mpv.conf TO DRAG & DROP DIRECTLY ONTO MPV. IN LINUX CAN RIGHT-CLICK ON AN MP4 & OPEN-WITH-MPV.  LINUX snap: --script=/home/user/Desktop/mpv-scripts/
----ANDROID    :    script=/sdcard/Android/media/is.xyz.mpv/          IN ADVANCED SETTINGS:        Edit mpv.conf.  PLACE ALL SCRIPTS IN THIS FOLDER IN INTERNAL MAIN STORAGE. OTHER FOLDERS DON'T WORK.  ENABLE MPV MEDIA-ACCESS USING ITS FILE-PICKER, & SET BACKGROUND-PLAYBACK TO ALWAYS (GENERAL SETTING).  'sdcard'~='SD card'(EXTERNAL)  CAN ALSO INSTALL cx-file-explorer & 920 (.APK).  920 CAN HANDLE WORDWRAP & WHITESPACE.  https://SNAPDROP.NET CAN TRANSFER TO /sdcard/Android/media/is.xyz.mpv/

options     = {                
    scripts = {                   --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE.  CAN TOGGLE THEM USING TYPOS/RENAME.  REPETITION BLOCKED.  SPACES & '' ALLOWED.
        "aspeed.lua"            , --EXTRA AUDIO DEVICES SPEED RANDOMIZATION, + SYNCED CLOCKS. INSTA-TOGGLE (DOUBLE-MUTE).  CAN CONVERT MONO TO (RANDOMIZED) SURROUND SOUND, FOR 10 HOURS.  MY FAVOURITE OVERALL. CONVERTS SPEAKERS INTO METAPHORICAL MOCKING-BIRDS.  NOT FULLY ANDROID-COMPATIBLE.
        "autocrop.lua"          , --CROPS BLACK BARS. TOGGLES FOR BOTH CROPPING & EXTRA PADDING (SMOOTHLY). DOUBLE-MUTE TOGGLES.  ALSO SUPPORTS start/end TIME-LIMITS, CROPS IMAGES & CROPS THROUGH TRANSPARENCY.  meta_osd DISPLAYS ALL version PROPERTIES.
        -- "autocrop-smooth.lua", --SMOOTH CROPPING & PADDING. NOT UP TO DATE & NOT FOR ANDROID.  DISABLE autocomplex.lua DUE TO EXCESSIVE CPU USAGE. INCOMPATIBLE WITH .AppImage (FFMPEG-v4.2).
        "autocomplex.lua"       , --NOT FOR CHEAP SMARTPHONE.  ANIMATED AUDIO SPECTRUMS, VOLUME BARS, FPS LIMITER. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE CAN BE LIKE WINGS OF BIRD).  DISABLE FOR TWITTER, & SOMETIMES TO seek THROUGH YOUTUBE VIDEOS.
        "automask.lua"          , --ANIMATED FILTERS (MOVING LENSES, ETC). SMOOTH-TOGGLE (DOUBLE-MUTE).  CAN SPEED-LOAD MONACLE/PENTAGON ON SMARTPHONE.  LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (UNIQUE KEYBINDS).
    },
    ytdl = {            --YOUTUBE DOWNLOAD. PLACE EXECUTABLE WITH main.lua.  LIST ALL POSSIBLE FILENAMES TO HOOK, IN PREFERRED ORDER.  EXISTING HOOK APPENDS. NO ";" ALLOWED.  CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto.  NOT FOR ANDROID OR LINUX snap.
        "yt-dlp"      , --.exe
        "yt-dlp_x86"  , --win32  REMOVE THESE TO SHORTEN script-opts.  WILDCARDS INVALID.  
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp TO REMOVE OLD VERSION.  
        "yt-dlp_macos", 
    },
    script_opts              = {        --THESE APPEND/REPLACE EXISTING script-opts.
    ----['script-opt'      ] =  'val',
        ['osc-timetotal'   ] =  'yes',  --DEFAULT=no      (ON-SCREEN-CONTROLLER SETTINGS. DISABLED INSIDE SMPLAYER.)
        ['osc-timems'      ] =  'yes',  --DEFAULT=no
        ['osc-fadeduration'] =  '0'  ,  --DEFAULT=200 ms
    },
    msg_level                = {        --THESE APPEND/REPLACE TO EXISTING msg-level.
    ----['module'        ]   = 'level', 
        ['ffmpeg/demuxer']   = 'error', --DEFAULT=status
    },
    options = {                         --COULD BE RENAMED config.
        'ytdl-format  bv[height<1080]+ba/best','profile      fast', --bv,ba = bestvideo,bestaudio  "/best" FOR RUMBLE.  fast FOR MPV.APP (COLORED TRANSPARENCY).  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://YOUTU.BE/8cor7ygb1ms?t=60
        'osd-border-size 1','osd-font-size 16','osd-duration 5000','osd-bar no','osd-bold yes','osd-font "COURIER NEW"',  --DEFAULTS 3,55,1000,yes,no,sans-serif   border=1p FOR LITTLE TEXT.  1000 MILLISECONDS ISN'T ENOUGH TO READ ON-SCREEN-DISPLAY.  SMPLAYER ALREADY HAS A BAR.  55p MAY NOT FIT GRAPHS.  COURIER NEW IS MONOSPACE & NEEDS bold (FANCY).  CONSOLAS PROPRIETARY & INVALID ON MACOS.
        'sub-border-size 2','sub-font-size 32',  --DEFAULTS=3,55   SIZES OVERRIDE SMPLAYER. SUBS DRAWN @720p.
        'osd-level       0','osc           no',  --DEFAULTS=3,yes  osd-level=0 PREVENTS UNWANTED MESSAGES @load-script.  osc AWAITS ITS CONFIG.  SOME THINGS MUST BE SWITCHED OFF/ON.  
    },
    title                  = '{\\fs40\\bord2}${media-title}',  --REMOVE FOR NO title.  $ FOR PROPERTIES.  STYLE OVERRIDES: \\,fs##,bord# = \,FONTSIZE(p),BORDER(p)  MORE: alpha##,an#,c######,shad#,b1,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = TRANSPARENCY,ALIGNMENT-NUMPAD,COLOR,SHADOW(p),BOLD,BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  cFF=RED,cFF0000=BLUE,ETC  title HAS NO TOGGLE.
    title_duration         =  6 , --SECONDS.
    autoloop_duration      =  6 , --SECONDS.  0 MEANS NO AUTO-loop.  MAX duration TO ACTIVATE INFINITE loop, FOR GIF & SHORT MP4.  NOT FOR JPEG (MIN>0).  BASED ON https://GITHUB.COM/zc62/mpv-scripts/blob/master/autoloop.lua
    options_delay          = .3 , --SECONDS, FROM playback_start.  title ALSO TRIGGERS THEN.
    options_delayed        = {    --@playback_started+options_delay, FOR EVERY FILE.
        'osd-level 1','osc yes',  --RETURNS osd & osc.
        -- SUBTITLE_OVERRIDE; 'sid 1','secondary-sid 1',  --UNCOMMENT FOR SUBTITLE-TRACK-ID OVERRIDE.  USEFUL FOR YOUTUBE + sub-create-cc-track. sid=1 BUGS OUT @file-loaded.
    },
    windows     = {}, linux = {}, darwin = {},  --OPTIONAL platform OVERRIDES.
    android     = {                                                             
        options = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',},  --options APPEND, NOT REPLACE. 
    },
}

o,p,timers = {},{},{}  --o,p=options,PROPERTIES.  timers={playback_start,title} TRIGGER ONCE PER file.
abs,max,min,random = math.abs,math.max,math.min,math.random  --ABBREV.
math.randomseed(os.time()+mp.get_time())  --os,mp=OPERATING-SYSTEM,MEDIA-PLAYER.  os.time()=INTEGER SECONDS FROM 1970.  mp.get_time()=μs IS MORE RANDOM THAN os.clock()=ms.  os.getenv('RANDOM')=nil  BUT COULD ECHO BACK %RANDOM% OR $RANDOM USING A subprocess. 

function pexpand(arg)  --ALSO @print_arg, @show & @title_update.  PROTECTED/PROPERTY EXPANSION.  '${speed}+2'=3.  COULD BE RENAMED ppexpand.
    if type(arg)~='string' then return arg end
    pcode, pval  = pcall(loadstring('return '..mp.command_native({'expand-text',arg})))  --''→nil.  load INVALID ON MPV.APP.  PROTECTED-CALL.
    if pcode then return pval end  --OTHERWISE pval=error-string.
end

function  gp(property) --ALSO @playback-restart.  GET-PROPERTY.
    p       [property]=mp.get_property_native(property)  
    return p[property]
end

p  .platform  = gp('platform') or os.getenv('OS') and 'windows' or 'linux' --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = {}                                                         --DEFAULT={}
for  opt,val in pairs(options)                                             
do o[opt]     = val end               --CLONE
require 'mp.options'.read_options(o)  --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.  GUI USER MAY ENTER RAW TABLES & 1+1 INSTEAD OF 2, ETC.
for opt,val in pairs(o) do if type(options[opt])~='string' then o[opt]=pexpand(val) end end  --NATIVE TYPECAST ENFORCES ORIGINAL TYPES.

for _,opt in pairs(o[p.platform].options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(o.options)
do  command        = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command            = command and mp.command(command)
for opt,val in pairs(o[p.platform]) 
do o[opt]          = val end                                      --platform OVERRIDE.  
utils              = require 'mp.utils'                           --@pexpand_to_string.
playback_restarted = gp('time-pos')                               --FILE ALREADY LOADED.
directory          = utils.split_path(gp('scripts')[1])           --ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory_expanded = mp.command_native({'expand-path',directory}) --command_native EXPANDS '~/' FOR ytdl_hook.  
title              = mp.create_osd_overlay('ass-events')          --ass-events IS THE ONLY FORMAT. title GETS ITS OWN osd.
COLON              = p.platform=='windows' and ';' or ':'         --windows=;  UNIX=:  FILE LIST SEPARATOR.  
for _,ytdl in pairs(o.ytdl)   
do    ytdl_path    = ('%s%s/%s%s'):format(ytdl_path or '',directory_expanded,ytdl,COLON) end --'/' FOR WINDOWS & UNIX.  "\/" & "//" VALID.  TRAILING COLON ALLOWED.

gp('script-opts')
for script_opt,val in pairs(o.script_opts)
do p['script-opts'][ script_opt          ] = val end 
p   ['script-opts']['ytdl_hook-ytdl_path'] = ytdl_path..(p['script-opts']['ytdl_hook-ytdl_path'] or '')  --APPEND EXISTING HOOK FROM SMPLAYER AS FALLBACK.  PREPENDING IT FAILED FOR .AppImage. 
mp.set_property_native('script-opts',p['script-opts'])

gp('msg-level')
for module,level in pairs(o.msg_level)
do p['msg-level'][module] = level end  --msg-level BEFORE scripts.
mp.set_property_native('msg-level',p['msg-level']) 

for _,script  in pairs(o.scripts) 
do script_lower,script_loaded = script:lower(),nil --SEARCH NOT CASE SENSITIVE. 
    for _,val in pairs(p.scripts) 
    do  _,val                 = utils.split_path(val)    --SEARCH NAMES ONLY. 
        script_loaded         = script_loaded or val:lower()==script_lower end  
    script                    = ('%s/%s'):format(directory,script)
    load_script               = not script_loaded and mp.commandv('load-script',script) and table.insert(p.scripts,script) end  --commandv FOR FILENAMES.
mp.set_property_native('scripts',p.scripts) --OPTIONAL: DECLARE scripts.

function playback_restart()  --ALSO @on_pause
    playback_restarted = true
    if playback_started or p.pause then return end --AWAIT UNPAUSE, IF PAUSED.  PROCEED ONCE ONLY, PER file.
    playback_started   = true                      --ONLY AFTER UNPAUSE.
    set_loop           = gp('duration')>0 and p.duration<o.autoloop_duration and mp.set_property('loop','inf') --autoloop BEFORE DELAY.
    timers.playback_start:resume()
end
mp.register_event('playback-restart',   playback_restart)  
mp.register_event('end-file',function() playback_restarted,playback_started = set_loop and mp.set_property('loop','no') and nil end)  --CLEAR SWITCHES FOR NEXT FILE.  UNDO-set_loop.

function on_pause(_,  paused)                
    p.pause     =     paused
    return not paused and playback_restarted and playback_restart()  --UNPAUSE MAY BE A FIFTH STAGE AFTER playback-restart.
end 
mp.observe_property('pause','bool',on_pause)

function title_update(data,title_duration)  --@script-message & @timers.playback_start.  DELAY REQUIRED TO SUPPRESS UNWANTED MESSAGES DUE TO SMPLAYER.
    command              = ''
    for _,opt in pairs(o.options_delayed)  --PLAYBACK (TITULAR) OVERRIDES.  osc RE-ACTIVATES HERE.
    do command           = ('%s no-osd set %s;'):format(command,opt) end
    command              = command~='' and mp.command  (command)
    timers.title.timeout = pexpand(title_duration)               or o.title_duration
    title.data           = mp.command_native({'expand-text',data or o.title})
    title:update()  --AWAITS UNPAUSE (PLAYING MESSAGE).  ALSO AWAITS TIMEOUT, OR ELSE OLD MPV COULD HANG UNDER EXCESSIVE LAG.
    timers.title:kill()
    timers.title:resume()
end 
function title_remove() title:remove() end  --@script-message & @timers.title.

timers.playback_start = mp.add_periodic_timer(o.options_delay,title_update)
timers.title          = mp.add_periodic_timer(0              ,title_remove)  --timeout CONTROLLED LATER.
for _,timer in pairs(timers) 
do    timer.oneshot   = 1 --ALL 1SHOT.
      timer:kill() end    --FOR OLD MPV. IT CAN'T START timers DISABLED.

function pexpand_to_string(string)  --@pprint & @show.  RETURNS string/nil, UNLIKE pexpand.
    val = pexpand(string)
    return type(val)=='string' and val or val and utils.to_string(val)
end 

function show(string,duration)  --@script-message. 
    string = pexpand_to_string(string)
    return string and mp.osd_message(string,pexpand(duration))
end

function set(script_opt ,val)  --@script-message IN FUTURE VERSION.  ULTIMATELY A GUI COULD CONTROL ALL SCRIPTS BY SENDING HUNDRED/S OF set COMMANDS. SIMPLER THAN SETTING script-opts. THE ORIGINAL options ARE ONLY AN EXAMPLE.
    o       [script_opt]=val
end

function callstring(string) loadstring(string)()             end  --@script-message.  CAN REPLACE ANY OTHER.  IRONICALLY GOOD EXAMPLES GET THEIR OWN NAMES.  IF pcall, COULD BE RENAMED ploadstring. OR scall (STRING-CALL). 
function pprint    (string) print(pexpand_to_string(string)) end  --@script-message.  PROTECTED PRINT. 
function exit      (      ) mp.keep_running = false          end  --@script-message.  false FLAG EXIT: COMBINES overlay-remove, unregister_event, unregister_script_message, unobserve_property & timers.*:kill().
for message,fn in pairs({loadstring=callstring,print=pprint,show=show,exit=exit,quit=exit,title=title_update,title_remove=title_remove})  --SCRIPT CONTROLS.
do mp.register_script_message(message,fn)  end

----SCRIPT-COMMANDS & EXAMPLES:
----script-message-to _ loadstring <string>
----script-message      loadstring math.randomseed(365)
----script-message      print      <string>
----script-message      print      _VERSION
----script-message      show       <string>       <duration>
----script-message      show       _VERSION       6*random()
----script-message-to _ exit
----script-message-to _ quit
----script-message      title      <data>         <title_duration>
----script-message      title      ${media-title} 6*random()
----script-message      title_remove

----mpv TERMINAL COMMAND EXAMPLES:
----WINDOWS   CMD:  MPV\MPV --no-config --script=. TEST.MP4    (PLACE scripts & TEST.MP4 INSIDE smplayer.exe FOLDER. THEN COPY/PASTE COMMAND INTO NOTEPAD & SAVE AS TEST.CMD, & DOUBLE-CLICK IT.)
----LINUX      sh:  mpv --no-config --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss" 
----SMPLAYER.APP :  /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss"      
----MACOS MPV.APP:  /Applications/mpv.app/Contents/MacOS/mpv --no-config --script=~/Desktop/mpv-scripts/ "https://YOUTU.BE/5qm8PH4xAss"    (DRAG & DROP mpv.app ONTO Applications.  MACOS MAY BE CASE-SENSITIVE.  URLs DRAG & DROP WITHOUT "".)

----https://SOURCEFORGE.NET/projects/mpv-player-windows/files/release               FOR NEW MPV WINDOWS BUILDS. CAN REPLACE mpv.exe IN SMPLAYER.
----https://laboratory.STOLENDATA.NET/~djinn/mpv_osx                                FOR NEW MPV MACOS   BUILDS.  https://BRACKETS.IO FOR TEXT-EDITOR.  THESE BUILDS WORK FINE BUT '%g' (PATTERN) & Δ (GREEK) ARE INVALID.  
----https://GITHUB.COM/mpv-android/mpv-android/releases                             FOR NEW MPV ANDROID BUILDS.  https://CXFILEEXPLORERAPK.NET  &  https://BROMITE.ORG FOR CHROMIUM.
----https://SMPLAYER.INFO/en/download-linux & https://apt.FRUIT.JE/ubuntu/jammy/mpv FOR LINUX SMPLAYER & MPV.   OFFLINE LINUX ALL-IN-ONE: SMPlayer-24.5.0-x86_64.AppImage  BUT IT HAS POOR PERFORMANCE (NO SMOOTH-PAD).

----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED.
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS: windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  ON ANDROID, WON'T OPEN JPEG OR YOUTUBE.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----~200 LINES & ~2000 WORDS.  SPACE-COMMAS FOR SMARTPHONE. SOME TEXT EDITORS DON'T HAVE LEFT/RIGHT KEYS.  LEADING COMMAS ON EACH LINE ARE AVOIDED.  
----SAFETY INSPECTION: LUA SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path expand-text show-text seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE.  set* SAFE EXCEPT FOR script-opts WHICH MAY HOOK AN UNSAFE EXECUTABLE.
----FUTURE VERSION SHOULD ALSO HAVE o.double_pause_timeout=0 (p&p DOUBLE-TAP).  BUT NOT WHEN PAUSED.  NEEDED FOR android albumart.
----FUTURE VERSION SHOULD HAVE script-message set TO CHANGE o ON THE FLY.  OR RESPOND TO CHANGING script-opts (function on_update).
----FUTURE VERSION COULD  HAVE o.double_mute_timeout, o.double_aid_timeout, o.double_sid_timeout, o.double_mute_command, o.double_aid_command & o.double_sid_command.


----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES).  correct-pts ESSENTIAL.  MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----DECLARING local VARIABLES MAY IMPROVE HIGHLIGHTING/COLORING, BUT UNNECESSARY.
----50%CPU+25%GPU USAGE (5%+15% WITHOUT scripts).  ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO/VERSION, DUE TO SENSITIVITY TO STEADY-CAM + HUMAN FACE.  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE (CAN CHECK BY ROLLING BACK DISPLAY DRIVER IN DEVICE MANAGER). FREE GPU IMPROVES MULTI-TASKING.
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. MOST TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS.  ULTIMATELY TV FIRMWARE (1GB) COULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. 
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, TAB-L/R & MULTI-LINE CTRL-EDITING. ENABLES QUICK GRAPH TESTING.  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK PRODUCES 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VMWARE MACOS: SWITCH  Command(⌘) & Control(^)‎  MODIFIER KEYS.  FOR DVORAK CAN SET:  Select All,Save,Undo,Cut,Copy,Paste = ‎⌥A,⌥O,⌥;,⌥J,⌥K,⌥Q‎  &  Redo,Open Recent... = ‎⌥⇧;,⌥⇧O‎  IN  Keyboard→Shortcuts→App Shortcuts→All Applications→+.  VIRTUALBOX DOESN'T HAVE THIS PROBLEM (DIRECT HARDWARE CAPTURE). BUT UNLOCKED VMWARE PERFORMS BETTER.

----BUG: SOME YT VIDEOS GLITCH/STUTTER @START (PAUSING). EXAMPLE: https://YOUTU.BE/D22CenDEs40
----BUG: RARE YT VIDEOS SUFFER no-vid.                   EXAMPLE: https://YOUTU.BE/y9YhWjhhK-U
----BUG: NO seeking OR lavfi-complex WITH X.COM.         EXAMPLE: https://X.COM/i/status/1696643892253466712 
----BUG: SMPlayer.app yuvj444p albumart NOT WORKING.     current-vo=shm (SHARED MEMORY).

----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----sudo apt install smplayer flatpak snapd mpv            FOR RELEVANT LINUX INSTALLS. 
----flatpak install *.flatpak  snap install *.snap         FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap.
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, YOUTUBE, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (OLD FFMPEG).

