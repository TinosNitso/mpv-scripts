----AUTO-LOADER FOR OTHER SCRIPTS (IF THEY AREN'T ALREADY LOADED). MAY ALSO SET CONFIG OPTIONS. PUT ALL SCRIPTS IN THE SAME FOLDER, & LIST THEM HERE. TOGGLE THEM WITH TYPOS. INSTEAD OF ALL SCRIPTS LAUNCHING EACH OTHER WITH THE SAME CODES, ONE SCRIPT LAUNCHES THEM ALL.
----IN SMPLAYER'S ADVANCED mpv PREFERENCES ENTER --script=autoloader.lua (WINDOWS smplayer.exe FOLDER).  LINUX MAYBE: --script=/home/user/Desktop/SMPLAYER/autoloader.lua  MACOS: --script=/Users/user/Desktop/SMPLAYER/autoloader.lua
local options={ --ALL OPTIONAL & CAN BE REMOVED.
    scripts={"aspeed.lua",    --CLOCK & TITLE. ALSO AUDIO DEVICES SPEED RANDOMIZATION OVER SEVERAL HOURS (astats METRIC). CONVERTS MONO TO (RANDOMIZED) SURROUND SOUND. MY FAVOURITE OVERALL.
             "autocrop.lua",     --CROPS BLACK BARS BEFORE MASK, BUT AFTER SPECTRAL OVERLAY.
             "autocomplex.lua",  --ANIMATED AUDIO SPECTRUM, VOLUME BARS, FPS LIMITER. LAVFI-COMPLEX OVERLAY. EVERY SCRIPT CONTROLS 1 GRAPH EACH. 
             "automask.lua",     --ANIMATED FILTERS (MOVING BINOCULARS, ETC). LENS FORMULA MAY NEGATE BRIGHTNESS.
            },
    
    loop_limit=10,  --SECONDS MINIMUM. INFINITE loop GIF & SHORT MP4 (IN SMPLAYER TOO). STOPS MPV SNAPPING. ALL SCRIPTS NEED IT, SO IT FITS IN WITH autoloader.
    config ={
             'osd-duration 5000','osd-bar no',  --DEFAULTS 1000,yes  (MILLISECONDS,BOOL) TAKES TIME TO READ osd, BUT bar GETS IN THE WAY.
             -- 'ytdl no','osc  no',            --DISABLE DEFAULT YOUTUBE-DOWNLOAD,ON-SCREEN-CONTROLLER SCRIPTS?
            },   
}
local o,utils = options,require 'mp.utils' --ABBREV.
if o.config then for _,option in pairs(o.config) do mp.command('no-osd set '..option) end end  --APPLY config BEFORE scripts.

local directory=utils.split_path(mp.get_property('scripts'))    --split FROM WHATEVER THE USER ENTERED.   ALTERNATIVE mp.get_script_directory() HAS BUG.
if o.scripts then for _,script in pairs(o.scripts) do local scripts,CscriptC = mp.get_property('scripts'),'"'..script..'"'  --TRY LOAD ALL scripts IF NOT ALREADY LOADED. '/' WORKS IN BOTH WINDOWS & LINUX. CscriptC="script"
        if not scripts:upper():find(CscriptC:upper(),1,true) and not scripts:upper():find(script:upper()..',',1,true) --EITHER '"script"' OR 'script,' MAY BE ANNOUNCED.    1,true=STARTING-INDEX,EXACT-MATCH. upper() MEANS NOT CASE-SENSITIVE. "' ," MAYBE IN FILENAMES.
        then mp.set_property('scripts',scripts..','..CscriptC)   -- ANNOUNCE NEW script, AFTER CHECKING CURRENT LIST.
            mp.commandv('load-script', utils.join_path(directory,script)) end end end    --commandv FOR FILENAMES.     THE IDEA IS TO split_path FROM WHATEVER THE USER TYPED IN, & THEN join_path TO ALL OTHER scripts.
mp.register_event('file-loaded', function() if o.loop_limit and o.loop_limit>mp.get_property_number('duration') then mp.command('no-osd set loop inf') end end)     --loop GIF.


----COMMENT SECTION. ALL SCRIPTS WORK IN MACOS-CATALINA, WIN10 & DEBIAN-MATE USING snap, flatpak & SMPlayer-23.6.0-x86_64.AppImage  MPV v0.36 & v0.35
----aspect_none reset_zoom  ARE STARTING SMPLAYER actions (ADVANCED PREFERENCES).
----https://apt.fruit.je/ubuntu/jammy/mpv/ https://smplayer.info/en/download-linux  FOR LINUX MPV & SMPLAYER DOWNLOADS.
----sudo apt install snapd flatpak smplayer mpv     FOR RELEVANT LINUX INSTALLS.
----snap run smplayer   flatpak run info.smplayer.SMPlayer      FOR TESTING.
----LINUX snap WON'T WORK WITH SOME FILTERS THE SAME WAY, LIKE shuffleplanes & negate=y. ALL SCRIPTS MUST PASS snap INSPECTION.



