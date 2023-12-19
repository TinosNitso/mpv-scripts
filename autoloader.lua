----AUTO-LOADER FOR OTHER SCRIPTS (IF THEY AREN'T ALREADY LOADED). MAY ALSO SET CONFIG OPTIONS. PUT ALL SCRIPTS IN THE SAME FOLDER AS THIS, & LIST THEIR NAMES HERE. TOGGLE THEM ON/OFF WITH TYPOS (THEY ALSO COME WITH DOUBLE-mute TOGGLES).
----INSTEAD OF ALL SCRIPTS LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. THEY ARE ALL ~200 LINES, WITH MANY PARTS COPY/PASTED FROM EACH OTHER.
----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER  --script=autoloader.lua  (WINDOWS smplayer.exe FOLDER).   MACOS: --script=~/Desktop/mpv-scripts/autoloader.lua     LINUX: --script=/home/user/Desktop/mpv-scripts/autoloader.lua  

options={ --ALL OPTIONAL & CAN BE REMOVED.
    scripts={"aspeed.lua",     --CLOCK, TITLE & AUDIO DEVICES SPEED RANDOMIZATION, FOR UP TO 10 HOURS. INSTA-TOGGLE. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND. MY FAVOURITE OVERALL. CONVERTS A SPEAKER INTO A METAPHORICAL MOCKING-BIRD.
             "autocomplex.lua",--ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. DUAL lavfi-complex OVERLAY. SLOW TOGGLE (INTERRUPTS PLAYBACK).
             "autocrop.lua",   --CROP OFF BLACK BARS BEFORE MASK, BUT AFTER SPECTRAL OVERLAY. INSTA-TOGGLE. autocrop-smooth.lua FOR SMOOTH VERSION (TOO MUCH CPU WHEN COMBINED).
             "automask.lua",   --ANIMATED FILTERS (MOVING LENSES, ETC). INSTA-TOGGLE. LENS FORMULA ADDS GLOW TO DARKNESS. LOAD 2 FOR 2 MASKS (LIKE VISOR + BUTTERFLY).
            },
    
    loop_limit=10,  --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO). STOPS MPV SNAPPING. ALL MY SCRIPTS NEED IT, SO IT FITS IN WITH autoloader.    BASED ON https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua
  --  ytdl_path ='~/Desktop/yt-dlp_macos', --YOUTUBE DOWNLOAD. NEEDED IN MACOS. WON'T CONTRADICT EXISTING INSTALLATION.  COPY/PASTE "yt-dlp_macos" (~25MiB) TO MACOS Desktop. EXTRACTING FROM .zip MAY PRODUCE FASTER EXECUTABLE.
    
    config={
        'osd-duration 5000','osd-bar no',  --DEFAULTS 1000,yes  (MILLISECONDS,BOOL)  TAKES TIME TO READ osd. SMPLAYER ALREADY HAS A seek BAR.
    },   
}
o,utils = options,require 'mp.utils' --ABBREV.
if o.config then for _,option in pairs(o.config) do mp.command('no-osd set '..option) end end  --APPLY config BEFORE scripts.

if o.ytdl_path then script_opts,ytdl_path = mp.get_property('script-opts'),mp.command_native({'expand-path',o.ytdl_path}) --yt-dlp REQUIRES expand-path.
    if script_opts~='' then script_opts=script_opts..',' end    --APPEND BECAUSE ytdl_path MAY CONTAIN ","  
    mp.set_property('script-opts',script_opts..'ytdl_hook-ytdl_path='..ytdl_path) end  

directory=utils.split_path(mp.get_property('scripts'))    --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
if o.scripts then for _,script in pairs(o.scripts) do is_present,scripts = false,mp.get_property_native('scripts')  --native FOR FILENAMES.  
        for _,find in pairs(scripts) do if script:upper()==find:upper() then is_present=true --SEARCH NOT CASE SENSITIVE. CHECK IF is_present (ALREADY LOADED).
            break end end    

        if not is_present then table.insert(scripts,script)
            mp.set_property_native('scripts',scripts)   -- ANNOUNCE NEW script, AFTER CHECKING CURRENT LIST.
            mp.commandv('load-script', utils.join_path(directory,script)) end end end    --commandv FOR FILENAMES.     CONCEPT IS TO split_path FROM WHATEVER THE USER TYPED IN, & THEN join_path TO ALL OTHER scripts.
mp.register_event('file-loaded', function() if o.loop_limit>mp.get_property_number('duration') then mp.command('no-osd set loop inf') end end)     --loop GIF. no-osd.  


----SAFETY INSPECTION: LUA SCRIPTS SHOULD BE CHECKED FOR os.execute io.popen mp.command* utils.subprocess*    load-script subprocess* run COMMANDS MAY BE UNSAFE, BUT expand-path frame-step seek stop quit af* vf* ARE ALL SAFE. 
----A FUTURE VERSION SHOULD CREATE A RECYCLE BIN FOR STREAMING. STREAM-DUMP ALL YOUTUBE VIDEOS, IN AUTO, UP TO 1GB.
----ALL SCRIPTS TESTED IN WIN10, LINUX (DEBIAN-MATE) & MACOS-CATALINA, USING MPV v0.36 & v0.35. TESTED SMPLAYER RELEASES .7z .exe .dmg .AppImage .flatpak .snap  ALL SCRIPTS NOW PASS snap INSPECTION. TESTED WITH FFMPEG VERSIONS 4.3.2 → 6.0  EACH SCRIPT PREPS & CONTROLS GRAPH/S OF FFmpeg-filters. 
----"autoload.lua" NAME IS ALREADY TAKEN BY A PLAYLIST SCRIPT WHICH LOADS ALL VIDEO FILES IN FOLDER. autoloader MAY LOAD SCRIPTS INSTEAD.
----SMPLAYER ACTIONS  aspect_none reset_zoom  CAN START EACH FILE (ADVANCED PREFERENCES). IT MAY CONTROL FINAL GPU WINDOW. MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO zoom. seek WITH GRAPHS IS TOO SLOW, BUT zoom INSTANT. FINAL video-zoom CONTROLLED BY SMPLAYER→[gpu].
----TOTAL CPU USAGE ~50% @FULL SCREEN. UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF, & SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM, audio RANDOMIZATION & CROPS ARE NOTHING BUT MPV COMMANDS. ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. 
----DECLARING local VARIABLES HELPS WITH HIGHLIGHTING, BUT UNNECESSARY. NOTEPAD++ HAS KEYBOARD SHORTCUTS FOR LINE DUPLICATION, DELETION & COMMENTARY TOGGLES, FOR RAPID GRAPH TESTING, + MULTI-LINE EDITING. MPV HAS LUA, LIKE HOW NOTEPAD++ HAS SCINTILLA, GIMP HAS SCM (SCHEME), SCIENCE HAS PYTHON, PDF HAS LATEX, MATH HAS OCTAVE/MATLAB, STATS HAS R, WEB HAS JAVASCRIPT/HTML, & WINDOWS HAS AUTOHOTKEY (AHK), ETC.  AHK CAN DO ALMOST ANYTHING WITH A 1MB .exe, WITH 1 SECOND BUILD TIME.   
----MACOS zsh:  /Applications/SMPlayer.app/Contents/MacOS/mpv ~/Desktop/mpv-scripts/TEST.MP4 --script=~/Desktop/mpv-scripts/autoloader.lua       EXACT TERMINAL COMMAND
----https://github.com/yt-dlp/yt-dlp/releases/tag/2023.11.14  FOR yt-dlp_macos (YOUTUBE). 

----LINUX BUILDS ADD MORE VARIETY, DEPENDING ON deb, AppImage, flatpak, snap & rpm. VIDEO SCRIPTING FOR LINUX CAN BE TRICKY, BECAUSE IDEALLY ALL SCRIPTS SHOULD WORK WITH ALL POSSIBLE BUILDS.
----yt-dlp youtube-dl ytdl NOT WORKING IN LINUX. BUT DIRECT .MP4 STREAMING WORKS.
----sudo apt install smplayer flatpak mpv snapd      FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak run info.smplayer.SMPlayer      snap run smplayer       FOR LINUX TESTING.
----sudo snap install *.snap  TO OFFLINE-INSTALL smplayer*.snap     BUT IT WON'T WORK WITH "~/", NOR SOME FILTERS THE EXACT SAME WAY, LIKE shuffleplanes,negate=y,scale=flags:eval. IT ALSO BLOCKS SYSTEM COMMANDS.


