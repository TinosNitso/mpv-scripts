----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER OPTION  --script=~/Desktop/mpv-scripts/  OR  --script=.  FROM WINDOWS smplayer.exe FOLDER.  LINUX snap: --script=/home/user/Desktop/mpv-scripts/    ASSUMING mpv-scripts IS PLACED ON Desktop.

options={  --ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.  autocomplex & automask HAVE osd_on_toggle WHICH DISPLAYS VERSION NUMBERS & FILTERGRAPHS.
        "aspeed.lua",      --CLOCK & AUDIO DEVICES SPEED RANDOMIZATION, FOR 10 HOURS. INSTA-TOGGLE. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND.  MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO A METAPHORICAL MOCKING-BIRD.
        "autocrop.lua",    --CROP OFF BLACK BARS BEFORE automask, BUT AFTER autocomplex. INSTA-TOGGLE.
        -- "autocrop-smooth.lua",  --SMOOTH VERSION. MAY BE INCOMPATIBLE WITH autocomplex DUE TO EXCESSIVE CPU USAGE.  MAY PERFORM BETTER WITHOUT FREE/CHEAP GPU? CAN ROLL BACK DRIVER IN DEVICE MANAGER → DISPLAY ADAPTERS.
        "autocomplex.lua", --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. TOGGLE INTERRUPTS PLAYBACK.  MY FAV FOR RELIGION (A PRIEST'S VOICE IS LIKE WINGS OF BIRD). 
        "automask.lua",    --ANIMATED FILTERS (MOVING LENSES, ETC). INSTA-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE VISOR + BUTTERFLY=automask2.lua, 300MB RAM EACH).
    },
    ytdl={    --YOUTUBE DOWNLOAD. PLACE ALONGSIDE main.lua.  LIST ALL POSSIBLE EXECUTABLE FILENAMES, IN PREFERRED ORDER. NO ";" ALLOWED.  https://github.com/yt-dlp/yt-dlp/releases/tag/2024.03.10  RUMBLE & ODYSSEY ALSO.
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", --CAN SET SMPLAYER Preferences→Network TO USE mpv INSTEAD OF auto. 
    },
    
    title         ='{\\fs55\\bord3\\shad1}',  --REMOVE TO REMOVE title.  \\,fs,bord,shad = \,FONTSIZE,BORDER,SHADOW (PIXELS)  THIS STYLE CODE SETS THE osd.  b1,i1,u1,s1,be1,fn,c = BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME,COLOR  WITHOUT BOLD, FONT MAY BE LARGER.  cFF=RED,cFF0000=BLUE,ETC
    title_duration= 5, --SECONDS, DEFAULT=0. COUNTS FROM PLAYBACK-START.  title CAN BE MOVED TO aspeed.lua IF DOUBLE-MUTE TOGGLE IS NEEDED.
    clear_osd     =.2, --SECONDS, DEFAULT=0. CLEAR osd (BEHIND title) COUNTING FROM PLAYBACK START.
    loop_limit    =10, --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO) IF duration IS LESS. STOPS MPV SNAPPING.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    options       =''  --FREE FORM  ' opt1 val1  opt2=val2  --opt3=val3 '...  main SETS NON-CRITICAL options MORE EASILY.
        ..'     ytdl-format=bestvideo[height<1080]+bestaudio/best'  --"/best" FOR RUMBLE.  720p SEEKS BETTER SOMETIMES. EXAMPLE: https://youtu.be/8cor7ygb1ms?t=60
        ..'      keepaspect=no                sid=auto  msg-level=ffmpeg/demuxer=error'  --FREE aspect IF MPV HAS ITS OWN WINDOW.  sid=SUBTITLE ID  error SETTING AVOIDS SPURIOUS WARNINGS.
        ..' osd-border-size=1 osd-scale-by-window=no osd-duration 5000 --osd-bar=no' --DEFAULTS 3,yes,1000,yes  (PIXELS,BOOL,MILLISECONDS,BOOL)  1p FOR LITTLE TEXT. SAME font-size WITH LITTLE WINDOW. TAKES A FEW SECS TO READ/SCREENSHOT osd. bar GETS IN THE WAY (SMPLAYER).
    ,
}
o        =options  --ABBREV.
for opt,val in pairs({scripts={},ytdl={},title_duration=0,clear_osd=0,options=''})
do o[opt]=o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options=(o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true 
do   opt =o.options()  
     find=opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val =find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt =find and (opt):sub(0,find-1) or opt
     if not (opt and val) then break end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

scripts,script_opts   = mp.get_property_native('scripts'),mp.get_property_native('script-opts')  --get_property_native FOR FILENAMES.
directory             = require 'mp.utils'.split_path(scripts[1])  --split FROM WHATEVER THE USER ENTERED.  UTILITIES SHOULD BE AVOIDED & POTENTIALLY NOT FUTURE COMPATIBLE. HOWEVER CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory,hook        = mp.command_native({'expand-path',directory}),'ytdl_hook-ytdl_path'     --yt-dlp REQUIRES ~ EXPANDED. command_native RETURNS. hook SPECIFIES yt-dlp EXECUTABLE.
COLON                 = mp.get_property('platform')=='windows' and ';' or ':' --FILE LIST SEPARATOR.  WINDOWS=;  UNIX=:
for _,ytdl in pairs(o.ytdl) 
do  ytdl              = directory..'/'..ytdl  --'/' FOR WINDOWS & UNIX.
    script_opts[hook] = script_opts[hook] and script_opts[hook]..COLON..ytdl or ytdl end  --APPEND ALL ytdl.
mp.set_property_native('script-opts',script_opts) --EMPLACE hook.  ALTERNATIVE change-list WON'T ALLOW BOTH " " & "'" IN THE FILENAMES.

for _,script in pairs(o.scripts) do is_present=false   
    for _,val in pairs(scripts) do if (script):lower()==(val):lower() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
        break end end    
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script',directory..'/'..script) end end  --commandv FOR FILENAMES. join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)   --ANNOUNCE scripts.

function file_loaded() 
    osd_level=mp.get_property_number('osd-level')  --ACTS AS SWITCH FOR FIRST playback-restart.
    duration =mp.get_property_number('duration') or 0  --JPEG = nil,0 @file-loaded,@playback-restart. nil & 0 MAY INTERCHANGE.  MPV MAY NOT ACTUALLY DEDUCE TRUE duration DUE TO 3RD PARTY FILTERS.
    if o.clear_osd+0>0 then mp.set_property_number('osd-level',0) end 
    if o.loop_limit and duration<o.loop_limit+0 then mp.set_property('loop','inf') end  --loop GIF. +0 CONVERTS→number & IS EASIER TO READ THAN RE-ARRANGING INEQUALITIES.
end
mp.register_event('file-loaded',file_loaded)

title=mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.
function playback_restart()  --title WAITS FOR PLAYBACK START, OR IT'S PREMATURE. clock GOES IN FIRST (TO TIME LOADS).
    if not osd_level then return end  --osd_level=nil EQUIVALENT TO UNREGISTERING playback_restart.  ALTERNATIVE SWITCH CAN BE playback_started=true 
    title.data=o.title and o.title..mp.get_property_osd('media-title') or ''
    title:update()  --DISPLAY title.
    mp.add_timeout(o.title_duration,function() title:remove() end)
    mp.add_timeout(o.clear_osd,set_osd_level)
end
mp.register_event('playback-restart',playback_restart)
    
function set_osd_level()  --RETURN osd-level, AFTER timeout.
    if osd_level then mp.set_property_number('osd-level',osd_level) end
    osd_level=nil 
end 


----mpv TERMINAL COMMANDS:
----WINDOWS   CMD: MPV\MPV --script=. *.MP4      (PLACE scripts & AN MP4 INSIDE smplayer.exe FOLDER)
----LINUX      sh: mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"
----MACOS     zsh: /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"      
----MACOS mpv.app: /Applications/mpv.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/ "https://youtu.be/5qm8PH4xAss"        (DRAG & DROP mpv.app ONTO Applications. IT USES AN OLD LUA.)

----SAFETY INSPECTION: LUA SCRIPTS CAN BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path seek playlist-next playlist-play-index stop quit af* vf* ARE ALL SAFE. set IS SAFE EXCEPT FOR script-opts WHICH MAY hook AN UNSAFE EXECUTABLE INTO A DIFFERENT SCRIPT, LIKE youtube-dl.
----MPV v0.38.0 (.7z .exe v3) v0.37.0 (.app?) v0.36.0 (.exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED. 
----FFmpeg v6.0(.7z .exe .flatpak)  v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS ACTUALLY BUILT WITH FFmpeg v4, v5 & v6 (ALL 3), WHICH CHANGES HOW THE GRAPHS ARE WRITTEN (FOR COMPATIBILITY).
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----aspect_none reset_zoom  SMPLAYER ACTIONS CAN START EACH FILE (ADVANCED PREFERENCES). MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO volume. seek WITH GRAPHS IS TOO SLOW, BUT zoom & volume INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu]. 
----THIS SCRIPT HAS NO TOGGLE. INSTEAD OF ALL scripts LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. DECLARING local VARIABLES HELPS WITH HIGHLIGHTING & COLORS, BUT UNNECESSARY. IT'S LIKE THE FAT ON MUSCLE.
----35%CPU+25%GPU USAGE (5%+20% WITHOUT scripts). ~75%@30FPS (OR 55%@25FPS) CPU USAGE @FULLSCREEN WITHOUT GPU DRIVERS. REDUCING fps FROM 30→25 DROPS IT BY 15%.  ARGUABLY SMOOTHER THAN VLC, DEPENDING ON VIDEO (SENSITIVE TO HUMAN FACE SMOOTHNESS).  FREE/CHEAP GPU MAY ACTUALLY REDUCE PERFORMANCE?
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFMPEG-FILTERS. THEY'RE ALL <300 LINES LONG, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.  ULTIMATELY TELEVISION FIRMWARE (1GB) SHOULD BE CAPABLE OF CROPPING, MASK & SPECTRAL OVERLAYS. IT'S NOT THE CONTENT PROVIDER'S JOB. MPV CAN ACT LIKE TV FIRMWARE.
----NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE, UPPERCASE, lowercase, COMMENTARY TOGGLES, & MULTI-LINE ALT-EDITING. AIDS RAPID GRAPH TESTING.  MPV HAS LUA, JS & JSON (JAVA SCRIPT OBJECT NOTATION).  NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK CAN DO ALMOST ANYTHING WITH A 1MB .exe, WITH 1 SECOND REPRODUCIBLE BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB. MACOS LIMITED TO 3MB VIDEO MEMORY. CAN ALSO SWITCH AROUND Command & Control(^) MODIFIER KEYS.  "C:\Program Files\Oracle\VirtualBox\VBoxManage" setextradata macOS_11 VBoxInternal/Devices/smc/0/Config/DeviceKey ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

----BUG: RARE YT VIDEOS LOAD no-vid. EXAMPLE: https://youtu.be/y9YhWjhhK-U
----BUG: CAN'T seek WITH TWITTER.    EXAMPLE: https://twitter.com/i/status/1696643892253466712

----https://sourceforge.net/projects/mpv-player-windows/files/release/ FOR NEW MPV WINDOWS BUILDS.
----sudo apt install smplayer flatpak snapd mpv     FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak install *.flatpak  snap install *.snap  FOR INSTALLS, AFTER cd TO RELEASES. MUST BE ON INTERNET, EVEN FOR snap. .AppImage IS OFFLINE.
----flatpak run info.smplayer.SMPlayer  snap run smplayer  FOR flatpak & snap TESTING. 
----snap DOESN'T WORK WITH "~/", BLOCKS SYSTEM COMMANDS, & WORKS DIFFERENTLY WITH SOME FILTERS LIKE showfreqs (FFmpeg-v4.4).

----o.options DUMP (FREE FORM). NICER WITHOUT "=". TO DEBUG TRY TOGGLE ALL THESE SIMULTANEOUSLY, & ISOLATE WHICH LINE FIXED THE BUG. BUT THAT CAN HAVE UNINTENDED CONSEQUENCES.
        -- ..' framedrop decoder+vo  video-sync desync  vd-lavc-dropframe nonref  vd-lavc-skipframe nonref'  --frame=none default nonref bidir  CAN SKIP NON-REFERENCE OR B-FRAMES.  video-sync=display-resample & display-tempo GLITCHED. 
        -- ..' vo gpu  hr-seek always  index recreate  wayland-content-type none  background color  alpha blend'
        -- ..' video-latency-hacks yes  hr-seek-framedrop yes  access-references yes  ordered-chapters no  stop-playback-on-init-failure yes'
        -- ..' osc no  ytdl yes  cache yes  cache-pause no  cache-pause-initial no  initial-audio-sync yes  gapless-audio no  keepaspect-window no  force-seekable yes  vd-queue-enable yes  ad-queue-enable yes'
        -- ..' demuxer-lavf-hacks yes  demuxer-lavf-linearize-timestamps no  demuxer-seekable-cache yes  demuxer-cache-wait no  demuxer-donate-buffer yes  demuxer-thread yes'
        -- ..' cache-pause-wait 0  video-timing-offset 1  hr-seek-demuxer-offset 1  audio-buffer 10'
        -- ..' demuxer-lavf-analyzeduration 1024  demuxer-termination-timeout 1024  cache-secs 1024  vd-queue-max-secs 1024  ad-queue-max-secs 1024  demuxer-readahead-secs 1024  audio-backward-overlap 1024  video-backward-overlap 1024  audio-backward-batch 1024  video-backward-batch 1024'
        -- ..' demuxer-lavf-buffersize 1000000  stream-buffer-size 1000000  audio-reversal-buffer 1000000  video-reversal-buffer 1000000'
        -- ..' vd-queue-max-samples 1000000  ad-queue-max-samples 1000000  chapter-seek-threshold 1000000  demuxer-backward-playback-step 1000000'
        -- ..' demuxer-max-bytes 1000000000  demuxer-max-back-bytes 1000000000  vd-queue-max-bytes 1000000000  ad-queue-max-bytes 1000000000'
        


