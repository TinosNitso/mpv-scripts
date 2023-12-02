----AUTO-LOADER FOR OTHER SCRIPTS (IF THEY AREN'T ALREADY LOADED). MAY ALSO SET CONFIG OPTIONS. PUT ALL SCRIPTS IN THE SAME FOLDER AS THIS, & LIST THEM HERE. TOGGLE THEM ON/OFF WITH TYPOS (THEY ALSO COME WITH DOUBLE-mute TOGGLES).
----INSTEAD OF ALL SCRIPTS LAUNCHING EACH OTHER WITH THE SAME CODE, THIS SCRIPT LAUNCHES THEM ALL. THEY ARE ALL ~200 LINES LONG (LIKE HOW DIFFERENT FRUIT TREES HAVE THE SAME HEIGHT, & HAVE COPY-PASTED PARTS FROM EACH OTHER). SOME SCRIPTS ARE MORE LIKE SHRUBS, THOUGH, LIKE THIS ONE, WHICH SPREADS THE OTHERS' SEED. A GRAPH MAY LITERALLY BE A SWAYING FRUIT TREE, WITH ON/OFF TOGGLE.
----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER  --script=autoloader.lua  (WINDOWS smplayer.exe FOLDER).   MACOS: --script=~/Desktop/mpv-scripts/autoloader.lua     LINUX: --script=/home/user/Desktop/mpv-scripts/autoloader.lua  

options={ --ALL OPTIONAL & CAN BE REMOVED.
    scripts={"aspeed.lua",      --CLOCK, TITLE & AUDIO DEVICES SPEED RANDOMIZATION FOR 10 HOURS. CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND. MY FAVOURITE OVERALL.
             "autocrop.lua",    --CROPS BLACK BARS BEFORE MASK, BUT AFTER SPECTRAL OVERLAY.     ON LINUX DON'T USE snap (BREAKS FRAME-BY-FRAME SCALING).
             "autocomplex.lua", --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. LAVFI-COMPLEX OVERLAY.
             "automask.lua",    --ANIMATED FILTERS (MOVING BINOCULARS, ETC). LENS FORMULA MAY NEGATE BRIGHTNESS.
            },
    
    loop_limit=10,  --SECONDS (MAX). INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO). STOPS MPV SNAPPING. ALL MY SCRIPTS NEED IT, SO IT FITS IN WITH autoloader.    BASED ON autoloop.lua.
    config ={
             'osd-duration 5000','osd-bar no',  --DEFAULTS 1000,yes  (MILLISECONDS,BOOL)  TAKES TIME TO READ osd, BUT bar GETS IN THE WAY.
             -- 'ytdl no','osc  no',            --DISABLE DEFAULT YOUTUBE-DOWNLOAD,ON-SCREEN-CONTROLLER SCRIPTS?
            },   
}
o,utils = options,require 'mp.utils' --ABBREV.
if o.config then for _,option in pairs(o.config) do mp.command('no-osd set '..option) end end  --APPLY config BEFORE scripts.

directory=utils.split_path(mp.get_property('scripts'))    --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
if o.scripts then for _,script in pairs(o.scripts) do is_present,CscriptC,scripts = false,'"'..script..'"',mp.get_property('scripts')  --CscriptC="script" ("'" & "," MAY BE IN FILENAMES). TRY LOAD ALL scripts IF NOT ALREADY LOADED (is_present).
        SCRIPTSU,SCRIPTU = scripts:upper(),script:upper()    --SEARCH NOT CASE SENSITIVE. CHECK IF ALREADY LAUNCHED.
        for _,find in pairs({ CscriptC:upper() , SCRIPTU..',' , ','..SCRIPTU }) --EITHER '"script"' OR 'script,' OR ',script' MAY BE ANNOUNCED. 
        do if SCRIPTSU:find(find,1,true) then is_present=true   -- 1,true = STARTING-INDEX,EXACT-MATCH  
            break end end    
        if not is_present then mp.set_property('scripts',scripts..','..CscriptC)   -- ANNOUNCE NEW script, AFTER CHECKING CURRENT LIST.
             mp.commandv('load-script', utils.join_path(directory,script)) end end end    --commandv FOR FILENAMES.     THE IDEA IS TO split_path FROM WHATEVER THE USER TYPED IN, & THEN join_path TO ALL OTHER scripts.
mp.register_event('file-loaded', function() if o.loop_limit>mp.get_property_number('duration') then mp.command('no-osd set loop inf') end end)     --loop GIF. CAN CAUSE SCRIPT TO exit IF number=nil   no-osd


----3 KINDS OF COMMENTS: THE TOP (INTRO), LINE-BY-LINE EXPLANATION, & END (MISC.). ALSO BLURBS ON WEB. CAPS-LOCK IS MOSTLY COMMENTARY. lavfi GRAPHS REQUIRE AN EXTRA ENTIRE MIDDLE SECTION FOR SPECS.
----ALL SCRIPTS WORK IN WIN10, LINUX (DEBIAN-MATE) & MACOS-CATALINA, USING MPV v0.36 & v0.35.    FULLY TESTED SMPLAYER .7z .exe .dmg .flatpak .AppImage    
----SMPLAYER ACTIONS  aspect_none reset_zoom  CAN START EACH FILE (ADVANCED PREFERENCES). IT MAY CONTROL FINAL GPU WINDOW. MOUSE WHEEL FUNCTION CAN BE SWITCHED FROM seek TO zoom. seeking WITH GRAPHS IS TOO SLOW, BUT zoom INSTANT.
----THESE SCRIPTS CAN PROBABLY BE RE-WRITTEN IN PYTHON (.py). EACH PREPS & CONTROLS GRAPH/S OF ffmpeg-filters. LIKE HOW GIMP HAS SCM (SCHEME), NOTEPAD++ HAS SCINTILLA, MATH HAS OCTAVE/MATLAB, STATS HAS R, ELECTRUM HAS PYTHON, WINDOWS HAS AUTOHOTKEY (AHK), WEB HAS JAVASCRIPT, MPV HAS LUA. 
----UNLIKE A PLUGIN THE ONLY BINARY IS MPV ITSELF. THE SCRIPTS COMMAND IT. MOVING MASK, SPECTRUM & audio RANDOMIZATION ARE NOTHING BUT MPV COMMANDS. HOWEVER THE FEWER COMMANDS THE BETTER - ALMOST ALL TIME DEPENDENCE IS BAKED INTO GRAPH FILTERS. 
----EVEN WITH ALL 4 SCRIPTS I THINK PLAYBACK IS SMOOTHER THAN VLC. BUT VLC DOESN'T HAVE THE 10 HOUR BACKWARD-SEEK BUG.

----LINUX BUILDS ADD MORE VARIETY, DEPENDING ON deb, AppImage, flatpak, snap & rpm. SO video SCRIPTING FOR LINUX CAN BE TRICKY, BECAUSE IDEALLY THEY SHOULD WORK WITH ALL POSSIBLE BUILDS.
----sudo apt install smplayer flatpak mpv snapd      FOR RELEVANT LINUX INSTALLS. OFFLINE LINUX ALL-IN-ONE: SMPlayer-23.6.0-x86_64.AppImage
----https://smplayer.info/en/download-linux & https://apt.fruit.je/ubuntu/jammy/mpv/ FOR LINUX SMPLAYER & MPV.
----flatpak run info.smplayer.SMPlayer      snap run smplayer       FOR LINUX TESTING.
----sudo snap install *.snap  TO OFFLINE-INSTALL smplayer*.snap     BUT IT WON'T WORK WITH autocrop, "~/", NOR SOME FILTERS THE EXACT SAME WAY, LIKE shuffleplanes,negate=y,scale=flags:eval. IT ALSO BLOCKS SYSTEM COMMANDS.



