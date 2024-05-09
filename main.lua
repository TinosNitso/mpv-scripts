----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER OPTION  --script=~/Desktop/mpv-scripts/  OR  --script=.  FROM WINDOWS smplayer.exe FOLDER.  LINUX snap: --script=/home/user/Desktop/mpv-scripts/    ASSUMING mpv-scripts FOLDER IS PLACED ON Desktop.
----https://github.com/yt-dlp/yt-dlp/releases/tag/2024.03.10  FOR YOUTUBE STREAMING.  RUMBLE, ODYSSEY & REDTUBE ALSO.

options={     --ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.  autocomplex & automask HAVE osd_on_toggle WHICH DISPLAYS VERSION NUMBERS & FILTERGRAPHS.  A DIFFERENT VERSION COULD LOAD DIFFERENT SCRIPTS FOR IMAGES/albumart.
        "aspeed.lua",      --EXTRA AUDIO DEVICES SPEED RANDOMIZATION, + SYNCED CLOCKS. INSTA-TOGGLE.  CAN CONVERT MONO TO (RANDOMIZED) SURROUND SOUND, FOR 10 HOURS.  MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO SOMETHING LIKE A MOCKING-BIRD.
        "autocrop.lua",    --CROPS OFF BLACK BARS BEFORE automask, BUT AFTER autocomplex. SMOOTH-TOGGLE. ALSO SUPPORTS START & END TIMES (TIME-CROP SUBCLIPS), & CROPS THROUGH TRANSPARENCY.
        -- "autocrop-smooth.lua",  --SMOOTH CROPPING & PADDING. DISABLE autocomplex DUE TO EXCESSIVE CPU USAGE.
        "autocomplex.lua", --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE IS LIKE WINGS OF BIRD). 
        "automask.lua",    --ANIMATED FILTERS (MOVING LENSES, ETC). SMOOTH-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE VISOR + BUTTERFLY=automask2.lua, 300MB RAM EACH).
    },
    ytdl={    --YOUTUBE DOWNLOAD. PLACE ALONGSIDE main.lua.  LIST ALL POSSIBLE EXECUTABLE FILENAMES, IN PREFERRED ORDER. NO ";" ALLOWED.  
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", --CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto. 
    },
    
    title          = '{\\fs55\\bord3}',  --REMOVE TO REMOVE title.  \\,fs,bord = \,FONTSIZE,BORDER (PIXELS)  THIS STYLE CODE SETS THE osd.  shad1,b1,i1,u1,s1,be1,fn,c = SHADOW,BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME,COLOR  WITHOUT BOLD, FONT MAY BE LARGER.  cFF=RED,cFF0000=BLUE,ETC
    title_duration =  5, --SECONDS, DEFAULT=0. COUNTS FROM PLAYBACK-START.  title CAN BE MOVED TO aspeed.lua IF DOUBLE-MUTE TOGGLE IS NEEDED.
    clear_osd      = .2, --SECONDS TO CLEAR osd, BEHIND title. TIMED FROM playback-START.
    loop_limit     = 10, --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 IF duration IS LESS. STOPS MPV SNAPPING.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    -- sid         =  1, --UNCOMMENT FOR SUBTITLE TRACK ID OVERRIDE, @PLAYBACK-START. (ALSO secondary-sid.)  BY TRIAL & ERROR, auto & 1 NEEDED BEFORE & AFTER lavfi-complex, FOR YOUTUBE.
    options        = ''  --FREE FORM  ' opt1 val1  opt2=val2  --opt3=val3 '...  main SETS NON-CRITICAL options MORE EASILY.
        ..' ytdl-format=bv[height<1080]+ba/best '  -- bv,ba = bestvideo,bestaudio  "/best" FOR RUMBLE.  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://youtu.be/8cor7ygb1ms?t=60
        ..'   msg-level=ffmpeg/demuxer=error               keepaspect=no      profile=fast '  --error SETTING AVOIDS SPURIOUS WARNINGS.  FREE aspect IF MPV HAS ITS OWN WINDOW.  profile=fast MAY HELP WITH EXCESSIVE LAG (VIRTUALBOX-MACOS). 
        ..'         sub=auto      sub-font-size=32  sub-border-size=2 '  --DEFAULTS no,55,3  (BOOL,PIXELS,PIXELS)  sub=sid=auto BEFORE YOUTUBE LOADS.  size & font (ACCIDENTALLY) OVERRIDE SMPLAYER. SUBS DRAWN @720p.
        ..'     osd-bar=no  osd-scale-by-window=no  osd-border-size=2  --osd-duration=5000  osd-font CONSOLAS'  --DEFAULTS yes,yes,3,1000,sans-serif  (BOOL,BOOL,PIXELS,MILLISECONDS,string)  SMPLAYER ALREADY HAS bar. READABLE FONT ON SMALL WINDOW. 1p BORDER FOR LITTLE TEXT. TAKES A FEW SECS TO READ/SCREENSHOT osd. 
    ,
}  
o         = options  --ABBREV.
for opt,val in pairs({scripts={},ytdl={},title_duration=0,options=''})
do o[opt] = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION USED BY mpv.app-v0.37 ON MACOS.  
while true 
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not val then break    end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

scripts,script_opts   = mp.get_property_native('scripts'),mp.get_property_native('script-opts')  --get_property_native FOR FILENAMES.
directory             = require 'mp.utils'.split_path(scripts[1])  --split FROM WHATEVER THE USER ENTERED.  UTILITIES SHOULD BE AVOIDED & POTENTIALLY NOT FUTURE COMPATIBLE. HOWEVER CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory,hook        = mp.command_native({'expand-path',directory}),'ytdl_hook-ytdl_path'     --yt-dlp REQUIRES ~/ EXPANDED. command_native RETURNS. hook SPECIFIES yt-dlp EXECUTABLE.
COLON                 = mp.get_property('platform')=='windows' and ';' or ':' --FILE LIST SEPARATOR.  WINDOWS=;  UNIX=:
for _,ytdl in pairs(o.ytdl) 
do  ytdl              = directory..'/'..ytdl  --'/' FOR WINDOWS & UNIX.
    script_opts[hook] = script_opts[hook] and script_opts[hook]..COLON..ytdl or ytdl end  --APPEND ALL ytdl.
mp.set_property_native('script-opts',script_opts)  --EMPLACE hook.  ALTERNATIVE change-list WON'T ALLOW BOTH " " & "'" IN THE FILENAMES.

for _,script in pairs(o.scripts) do is_present=false   
    for _,val in pairs(scripts) do if (script):lower()==(val):lower() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
            break end end    
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script',directory..'/'..script) end end  --commandv FOR FILENAMES. join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)  --ANNOUNCE scripts.

function file_loaded() 
    osd_level,duration = mp.get_property_number('osd-level'),mp.get_property_number('duration') --osd_level ACTS AS SWITCH FOR FIRST playback-restart.  JPEG duration = (nil & 0) @ (file-loaded & playback-restart). nil & 0 MAY INTERCHANGE.  MPV MAY NOT ACTUALLY DEDUCE TRUE duration DUE TO 3RD PARTY FILTERS.
    if o.clear_osd  and o.clear_osd+0>0 and osd_level>0 then mp.set_property_number('osd-level',0) end 
    if o.loop_limit and  (duration or 0)<o.loop_limit+0 then mp.set_property('loop','inf') end  --loop GIF. +0 CONVERTS→number.
end
mp.register_event('file-loaded',file_loaded)

title=mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.
function playback_restart()       --title WAITS FOR PLAYBACK START, OR IT'S PREMATURE.
    if not osd_level then return  --~osd_level EQUIVALENT TO UNREGISTERING playback_restart.
    elseif o.sid then mp.set_property(          'sid',o.sid)     --OVERRIDE INTERFERENCE 
                      mp.set_property('secondary-sid',o.sid) end --ALSO NEEDED SOMETIMES (lavfi-complex).
    
    title.data=o.title and o.title..mp.get_property_osd('media-title') or ''
    title:update()  --UNDER EXCESSIVE LAG (& WITHOUT profile=fast), INSTANT title DISPLAY CAN CAUSE STREAM TO HANG. timeout MAYBE SAFER IN VIRTUALBOX-MACOS.
    mp.add_timeout(o.title_duration,function() title:remove() end)
    mp.add_timeout(o.clear_osd or 0,set_osd_level)
end
mp.register_event('playback-restart',playback_restart)

function set_osd_level()  --RETURN osd-level, AFTER timeout.
    if o.clear_osd and osd_level and osd_level>0 then mp.set_property_number('osd-level',osd_level) end
    osd_level=nil 
end 


----mpv TERMINAL COMMANDS:
----WINDOWS   CMD: MPV\MPV --script=. TEST.MP4      (PLACE scripts & TEST.MP4 INSIDE smplayer.exe FOLDER)
----LINUX      sh: mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"
----MACOS mpv.app: /Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications.)
---- SMPlayer.app: /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"      

----https://sourceforge.net/projects/mpv-player-windows/files/release/ FOR NEW MPV WINDOWS BUILDS.  CAN REPLACE mpv.exe IN SMPLAYER.
----https://laboratory.stolendata.net/~djinn/mpv_osx/ FOR NEW MPV MACOS BUILDS.
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.  OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.12.0-x86_64.AppImage

----SAFETY INSPECTION: LUA & JS SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE.  set* & change-list SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV v0.38.0(.7z .exe v3) v0.37.0(.app) v0.36.0(.exe .app .flatpak .snap v3) v0.35.1(.AppImage)  ALL TESTED. 
----FFMPEG v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS OFTEN BUILT WITH FFMPEG v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap  ALL TESTED.  v23.6 MAYBE PREFERRED.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----THIS SCRIPT HAS NO TOGGLE. INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORING, BUT UNNECESSARY.
----50%CPU+20%GPU USAGE (5%+20% WITHOUT scripts).  ~75%@30FPS (OR 55%@25FPS) WITHOUT GPU DRIVERS, @FULLSCREEN.  ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO (SENSITIVITY TO HUMAN FACE SMOOTHNESS).  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE (CAN CHECK BY ROLLING BACK DISPLAY DRIVER IN DEVICE MANAGER).
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. MOST TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS. THEY'RE ALL <300 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.  ULTIMATELY TELEVISION FIRMWARE (1GB) SHOULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. IT'S NOT THE CONTENT PROVIDER'S JOB. MPV CAN ACT LIKE TV FIRMWARE.
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK PRODUCES 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----BUG: RARE YT VIDEOS LOAD no-vid. EXAMPLE: https://youtu.be/y9YhWjhhK-U
----BUG: CAN'T seek WITH TWITTER.    EXAMPLE: https://twitter.com/i/status/1696643892253466712

----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----sudo apt install smplayer flatpak snapd mpv     FOR RELEVANT LINUX INSTALLS. 
----flatpak install *.flatpak  snap install *.snap  FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap.
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFmpeg-v4.4).

----o.options DUMP (FREE FORM). NICER WITHOUT "=". FOR DEBUG CAN TRY TOGGLE ALL THESE SIMULTANEOUSLY.
        -- ..' framedrop decoder+vo  video-sync desync  vd-lavc-dropframe nonref  vd-lavc-skipframe nonref'  --frame=none default nonref bidir  CAN SKIP NON-REFERENCE OR B-FRAMES.  video-sync=display-resample & display-tempo GLITCHED. 
        -- ..' vo gpu  hr-seek always  index recreate  wayland-content-type none  background color  alpha blend'
        -- ..' video-latency-hacks yes  hr-seek-framedrop yes  access-references yes  ordered-chapters no  stop-playback-on-init-failure yes'
        -- ..' osc no  ytdl yes  cache yes  cache-pause no  cache-pause-initial no  initial-audio-sync yes  gapless-audio no  keepaspect-window no  force-seekable yes  vd-queue-enable yes  ad-queue-enable yes'
        -- ..' demuxer-lavf-hacks yes  demuxer-lavf-linearize-timestamps no  demuxer-seekable-cache yes  demuxer-cache-wait no  demuxer-donate-buffer yes  demuxer-thread yes'
        -- ..' audio-delay 0  cache-pause-wait 0  video-timing-offset 1  hr-seek-demuxer-offset 1  audio-buffer 10'
        -- ..' demuxer-lavf-analyzeduration 1024  demuxer-termination-timeout 1024  cache-secs 1024  vd-queue-max-secs 1024  ad-queue-max-secs 1024  demuxer-readahead-secs 1024  audio-backward-overlap 1024  video-backward-overlap 1024  audio-backward-batch 1024  video-backward-batch 1024'
        -- ..' demuxer-lavf-buffersize 1000000  stream-buffer-size 1000000  audio-reversal-buffer 1000000  video-reversal-buffer 1000000'
        -- ..' vd-queue-max-samples 1000000  ad-queue-max-samples 1000000  chapter-seek-threshold 1000000  demuxer-backward-playback-step 1000000'
        -- ..' demuxer-max-bytes 1000000000  demuxer-max-back-bytes 1000000000  vd-queue-max-bytes 1000000000  ad-queue-max-bytes 1000000000'
        


