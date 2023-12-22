----AUTO-LOADER FOR OTHER SCRIPTS (IF THEY AREN'T ALREADY LOADED), & yt-dlp. ALSO SETS options. 
----INSTEAD OF ALL SCRIPTS LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. THEY ARE ALL ~200 LINES, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.
----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER  --script=autoloader.lua  (WINDOWS smplayer.exe FOLDER).   MACOS: --script=~/Desktop/mpv-scripts/autoloader.lua     LINUX snap: --script=/home/user/Desktop/mpv-scripts/autoloader.lua  
----YOUTUBE: https://github.com/yt-dlp/yt-dlp/releases/tag/2023.11.14  EXTRACTING FROM .zip MAY YIELD FASTER EXECUTABLE.

o={ --options  ALL OPTIONAL & CAN BE REMOVED.
    scripts={ --PLACE ALL scripts IN THE SAME FOLDER AS autoloader.lua, & LIST THEIR NAMES HERE. TYPOS CAN TOGGLE THEM ON & OFF.
        "aspeed.lua",     --CLOCK, TITLE & AUDIO DEVICES SPEED RANDOMIZATION, FOR UP TO 10 HOURS. INSTA-TOGGLE. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND.  MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO A METAPHORICAL MOCKING-BIRD.
        "autocrop.lua",   --CROP OFF BLACK BARS BEFORE mask, BUT AFTER SPECTRAL OVERLAY. INSTA-TOGGLE.  autocrop-smooth.lua FOR SMOOTH VERSION (TOO MUCH CPU WHEN COMBINED → META-LAG).
        "autocomplex.lua",--ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. SLOW TOGGLE (INTERRUPTS PLAYBACK).   MY FAV FOR RELIGION (THE WINGS OF A PRIEST IS HIS VOICE). 
        "automask.lua",   --ANIMATED FILTERS (MOVING LENSES, ETC). INSTA-TOGGLE. LENS FORMULA MAY ADD GLOW TO DARKNESS.  CAN LOAD AN EXTRA COPY FOR 2 MASKS (LIKE VISOR + BUTTERFLY=automask2.lua, 300MB RAM EACH).
    },
    ytdl={    --YOUTUBE DOWNLOAD, LOCATED ALONGSIDE autoloader.lua. LIST ALL POSSIBLE EXECUTABLE FILENAMES. NO ";" ALLOWED. 
        "yt-dlp",       --.exe
        "yt-dlp_linux", --CASE SENSITIVE.  sudo apt remove yt-dlp  TO REMOVE OLD VERSION.
        "yt-dlp_macos", 
    },
    
    loop_limit=10, --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO). STOPS MPV SNAPPING.  BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
    options   =''  --FREE FORM.
        ..' ytdl-format bestvideo[height<=1080]+bestaudio ' --LIMIT ytdl DOWN FROM 4K. AN ALTERNATIVE IS TO CHECK WITH SMPLAYER FIRST, BEFORE OVERRIDE.
        ..' osd-duration 5000  osd-bar no ' --DEFAULTS 1000,yes  (MILLISECONDS,BOOL)  TAKES TIME TO READ osd. SMPLAYER ALREADY HAS A seek BAR.
}
for opt,val in pairs({scripts={},ytdl={},loop_limit=0,set={}})
do if not o[opt] then o[opt]=val end end --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('%g+') --%g+=LONGEST GLOBAL MATCH TO SPACEBAR. RETURNS ITERATOR.  '',''→NULL-SET
while   val do mp.set_property(opt,val) 
    opt,val = o.options(),o.options() end --nil @END

utils    =require 'mp.utils'
directory=utils.split_path(mp.get_property('scripts')) --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
directory=mp.command_native({'expand-path',directory}) --yt-dlp REQUIRES ~ EXPANDED. command_native RETURNS.

COLON,hook,OS = ':','ytdl_hook-ytdl_path',os.getenv('OS')  -- : FOR UNIX. FILE LIST SEPARATOR.  hook SCRIPT-OPT SPECIFIES yt-dlp EXECUTABLE. 
if OS and OS:upper():find('WINDOWS',1,true) then COLON=';' end -- ; FOR WINDOWS.  1,true = STARTING_INDEX,EXACT_MATCH  

script_opts,scripts = mp.get_property_native('script-opts'),mp.get_property_native('scripts') --native FOR FILENAMES.  
for _,ytdl in pairs(o.ytdl) do ytdl=utils.join_path(directory,ytdl) --join AFTER split.
    if not script_opts[hook] then script_opts[hook]=ytdl 
    else   script_opts[hook]=script_opts[hook]..COLON..ytdl end end --APPEND ALL HOOKS.
mp.set_property_native('script-opts',script_opts) --EMPLACE hook.

for _,script in pairs(o.scripts) do is_present=false   
    for _,find in pairs(scripts) do if script:lower()==find:lower() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
        break end end    
    if not is_present then table.insert(scripts,script)
        mp.commandv('load-script', utils.join_path(directory,script)) end end  --commandv FOR FILENAMES.    CONCEPT IS TO join_path AFTER split_path FROM WHATEVER THE USER TYPED IN.
mp.set_property_native('scripts',scripts)   --ANNOUNCE scripts.
mp.register_event('file-loaded', function() if o.loop_limit>mp.get_property_number('duration') then mp.set_property('loop','inf') end end)  --loop GIF.  


----EXACT TERMINAL COMMANDS:
----WINDOWS CMD:  MPV\MPV --script=autoloader.lua TEST.MP4  (FROM INSIDE smplayer-portable)
----LINUX:        mpv --script=~/Desktop/mpv-scripts/autoloader.lua https://youtu.be/5qm8PH4xAss
----MACOS zsh:    /Applications/SMPlayer.app/Contents/MacOS/mpv --script=~/Desktop/mpv-scripts/autoloader.lua "https://youtu.be/5qm8PH4xAss"

----SAFETY INSPECTION: LUA SCRIPTS SHOULD BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path frame-step seek stop quit set af* vf* ARE ALL SAFE. 
----ALL scripts TESTED IN WIN10, LINUX (DEBIAN-MATE) & MACOS-CATALINA, USING MPV v0.36 & v0.35. TESTED SMPLAYER RELEASES .7z .exe .dmg .AppImage .flatpak .snap  ALL SCRIPTS PASS snap+ytdl INSPECTION.  TESTED FFMPEG VERSIONS 4.3.2→6.0  EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFmpeg-filters. NO hwdec: CPU ONLY.
----SMPLAYER ACTIONS  aspect_none reset_zoom  CAN START EACH FILE (ADVANCED PREFERENCES). IT MAY CONTROL FINAL GPU WINDOW. MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO zoom. seek WITH GRAPHS IS TOO SLOW, BUT zoom INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu].
----BUG: YOUTUBE PLAYLISTS DON'T LOAD NEXT URL. (CAN USE 2 INSTANCES TO PRE-LOAD NEXT 1.)
----A FUTURE VERSION SHOULD CREATE A RECYCLE BIN FOR STREAMING, UP TO 1GB. CAN STREAM-DUMP ALL YOUTUBE VIDEOS, IN AUTO.
----TOTAL CPU USAGE ~50% @FULL SCREEN. UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. 
----DECLARING local VARIABLES HELPS WITH HIGHLIGHTING, BUT UNNECESSARY. NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINEDUPLICATE, LINEDELETE & COMMENTARY TOGGLES, FOR RAPID GRAPH TESTING, + MULTI-LINE EDITING.  MPV HAS LUA, JS & JSON (JAVA SCRIPT OBJECT NOTATION). NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), PDF HAS LaTeX & WINDOWS HAS AUTOHOTKEY (AHK).  AHK CAN DO ALMOST ANYTHING WITH A 1MB .exe, WITH 1 SECOND BUILD TIME.   
----VIRTUALBOX: CAN INCREASE VRAMSize FROM 128→256 MB, FOR TESTING VIDEO SCRIPTS IN LINUX & MACOS. HOWEVER MACOS IS LIMITED TO 3MB.
----"autoload.lua" NAME IS ALREADY TAKEN BY A PLAYLIST SCRIPT WHICH LOADS ALL VIDEO FILES IN FOLDER. autoloader MAY LOAD scripts INSTEAD. IT'S DESIGNED FOR SMPLAYER, WHICH ALREADY HANDLES PLAYLISTS SEPARATELY.

----LINUX BUILDS ADD MORE VARIETY, DEPENDING ON deb, AppImage, flatpak, snap & rpm. VIDEO SCRIPTING FOR LINUX CAN BE TRICKY, BECAUSE IDEALLY ALL scripts SHOULD WORK WITH ALL BUILDS.
----yt-dlp youtube-dl ytdl NOT WORKING IN LINUX. BUT DIRECT .MP4 STREAMING WORKS.
----sudo apt install smplayer flatpak mpv snapd      FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak run info.smplayer.SMPlayer      snap run smplayer    FOR LINUX TESTING. .AppImage IS MOST FUNDAMENTAL.
----sudo snap install *.snap  TO OFFLINE-INSTALL smplayer*.snap  BUT IT WON'T WORK WITH "~/", NOR SOME FILTERS THE EXACT SAME WAY, LIKE shuffleplanes,negate=y,scale=flags:eval. IT ALSO BLOCKS SYSTEM COMMANDS.



