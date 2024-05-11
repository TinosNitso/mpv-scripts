----ADD clock TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. clock TICKS WITH SYSTEM, & MAY BE COLORED & STYLED. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PRIORITY, PATH, AID & LAG APPLY TO ALL DETACHED SUBPROCESSES. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER. A SMALLER STEREO ADDS MORE TREBLE (BIG CHEAP STEREOS HAVE TOO MUCH BASS).  USB→3.5mm SOUND CARDS COST AS LITTLE AS $3 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW mpv IN TASK MANAGER. ALSO WORKS IN VIRTUALBOX. 
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.

options={  --ALL OPTIONAL & MAY BE REMOVED.
    key_bindings             = 'CTRL+C CTRL+c',  --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO filterchain.  C IS autocrop.lua, NOT CLOCK.
    toggle_on_double_mute    =   .5,  --SECONDS TIMEOUT FOR DOUBLE-MUTE-TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.  IN GENERAL COULD BE RENAMED double_mute_timeout.
    extra_devices_index_list =   {},  --TRY {3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. REPETITION IGNORED.  1=auto  2=NORMAL DEVICE.  WRONG INDEX CAN OVERLAP AUDIO TO PRIMARY DEVICE. EACH CHANNEL FROM EACH device IS A SEPARATE SUBPROCESS.  EACH MPV USES APPROX 1% CPU, + 40MB RAM. EVERY SPEAKER BOX GETS ITS OWN YOUTUBE STREAM, ETC. 
    
    filterchain='anull,'  --CAN REPLACE anull WITH EXTRA FILTERS (vibrato highpass aresample ETC).
              ..'dynaudnorm=g=5:p=1:m=100', --DEFAULT=...:31:.95:10  DYNAMIC AUDIO NORMALIZER.  ALL SUBPROCESSES USE THIS. GRAPH COMMENTARY HAS MORE DETAILS.
    mpv={  --REMOVE FOR NO SUBPROCESSES OVERRIDE (clock+filterchain ONLY). LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE. USED BY ALL SUBPROCESSES. A COMMAND MAY NOT BE A PATH.  
        "mpv",   --LINUX & SMPLAYER (WINDOWS)
        "./mpv", --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv",       --     mpv.app
        "/Applications/SMPlayer.app/Contents/MacOS/mpv",  --SMPlayer.app
    },
    
    
    ----CLOCKS (VARIOUS STYLES).  UNCOMMENT A LINE TO ACTIVATE IT.  {} REMOVES LEADING 0 FOLLOWING IT.  STYLE CODES: \\,alpha##,an#,fs#,bord#,c######,b1 = \,TRANSPARENCY,ALIGNMENT-NUMPAD,FONT-SIZE(p),BORDER(p),COLOR,BOLD  (DEFAULT an0=an7=TOPLEFT)    MORE:  shad#,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  REQUIRES VIDEO TO BE SEEN.  EXAMPLES: USE {\\alpha80} FOR TRANSPARENCY. USE {\\fscx130} FOR +30% IN HORIZONTAL.  A TRANSPARENT clock CAN BE TWICE AS BIG. be ACTS LIKE SEMI-BOLD. 
    -- LIST        , clock=true,  --DISPLAYS ALL os.date DIRECTIVE CODES & THEIR CURRENT VALUES.  EXAMPLES: %I,%M,%S,%a,%p = HRS(12),MINS,SECS,Day,A/PM
       DIAGONAL    , clock='{\\an3\\fs70\\bord2}{}%I{\\fs42}:%M{\\fs25}:%S{\\fs15} %a',  --REMOVE TO remove clock.  'BIG:MEDium:Little tiny'  RATIO=.6
    -- FRANCE      , clock='{\\an3\\fs55\\bord3\\cA45500}%I{\\bord0\\c0\\b1}:{\\bord3\\cFFFFFF}%M{\\bord0\\c0\\b1}:{\\bord3\\c3541EF}%S{\\fs33\\bord0\\c0\\b1} %a',  --BLUE :WHITE :RED    Black,  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  BLACK BOLD MAY LOOK BETTER THAN BLACK ON BLACK BORDER.
    -- ROMANIA     , clock='{\\an3\\fs55\\bord3\\c7F2B00}%I{\\bord0\\c0\\b1}:{\\bord3\\c16D1FC}%M{\\bord0\\c0\\b1}:{\\bord3\\c2611CE}%S{\\fs33\\bord0\\c0\\b1} %a',  --BLUE :YELLOW:RED    Black,  MOLDOVA, ANDORRA & CHAD ARE SIMILAR.
    -- ITALY       , clock='{\\an3\\fs55\\bord3\\c458C00}%I{\\bord0\\c0\\b1}:{\\bord3\\cF0F5F4}%M{\\bord0\\c0\\b1}:{\\bord3\\c2A21CD}%S{\\fs33\\bord0\\c0\\b1} %a',  --GREEN:WHITE :RED    Black,  MEXICO & SENEGAL ARE SIMILAR.
    -- MALI        , clock='{\\an3\\fs55\\bord3\\c3AB514}%I{\\bord0\\c0\\b1}:{\\bord3\\c16D1FC}%M{\\bord0\\c0\\b1}:{\\bord3\\c2611CE}%S{\\fs33\\bord0\\c0\\b1} %a',  --GREEN:YELLOW:RED    Black,  GUINEA IS SIMILAR.
    -- IRELAND     , clock='{\\an3\\fs55\\bord3\\c629B16}%I{\\bord0\\c0\\b1}:{\\bord3\\cFFFFFF}%M{\\bord0\\c0\\b1}:{\\bord3\\c3E88FF}%S{\\fs33\\bord0\\c0\\b1} %a',  --GREEN:WHITE :ORANGE Black
    -- NIGERIA     , clock='{\\an3\\fs55\\bord3\\c008000}%I{\\bord0\\c0\\b1}:{\\bord3\\cFFFFFF}%M{\\bord0\\c0\\b1}:{\\bord3\\c008000}%S{\\fs33\\bord0\\c0\\b1} %a',  --GREEN:WHITE :GREEN  Black,  BICOLOR TRIBANDS.  
    -- PERU        , clock='{\\an3\\fs55\\bord3\\c2310D9}%I{\\bord0\\c0\\b1}:{\\bord3\\cFFFFFF}%M{\\bord0\\c0\\b1}:{\\bord3\\c2310D9}%S{\\fs33\\bord0\\c0\\b1} %a',  --RED  :WHITE :RED    Black,  CANADA MIGHT BE SIMILAR BUT WITH HALF fs HRS & SECS.
    -- BELGIUM     , clock='{\\an3\\fs55\\bord1\\c0}%I{\\bord3\\c24DAFD}%M{\\c4033EF}%S',  --BLACKYELLOWRED,  BLACK PRIMARY (THIN BORDER).  SMALL COUNTRY, SMALL CLOCK?
    -- GERMANY     , clock='{\\an3\\fs55\\bord1\\c0}%I{\\bord3\\cFF}\\N%M{\\cCCFF}\\N%S',  --BLACK \N RED \N GOLD
    -- RUSSIA      , clock='{\\an3\\fs55\\bord3\\cFFFFFF}%I{\\cA73600}\\N%M{\\c1827D6}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- WHITE \N BLUE  \N RED    \N Black,  HORIZONTAL TRICOLOR (VERTICAL TAB).  LIKE A TAB FROM THE FLAG.  Day LINES UP @1680x1050.
    -- BULGARIA    , clock='{\\an3\\fs55\\bord3\\cFFFFFF}%I{\\c009900}\\N%M{\\c0000CC}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- WHITE \N GREEN \N RED    \N Black
    -- ARMENIA     , clock='{\\an3\\fs55\\bord3\\c1200D9}%I{\\cA03300}\\N%M{\\c00A8F2}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- RED   \N BLUE  \N ORANGE \N Black
    -- NETHERLANDS , clock='{\\an3\\fs55\\bord3\\c251DAD}%I{\\cFFFFFF}\\N%M{\\c85471E}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- RED   \N WHITE \N BLUE   \N Black,  CROATIA IS SIMILAR.
    -- HUNGARY     , clock='{\\an3\\fs55\\bord3\\c3929CE}%I{\\cFFFFFF}\\N%M{\\c507047}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- RED   \N WHITE \N GREEN  \N Black
    -- AUSTRIA     , clock='{\\an3\\fs55\\bord3\\c2E10C8}%I{\\cFFFFFF}\\N%M{\\c2E10C8}\\N%S{\\fs35\\bord0\\c0\\b1}\\N%a',  -- RED   \N WHITE \N RED    \N Black,  BICOLOR TRIBAND.
    
    
    max_speed_ratio    = 1.15,  --DEFAULT=1.2          speed IS BOUNDED BY [SPEED/max,SPEED*max], WITH SPEED FROM CONTROLLER.  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    max_random_percent =   10,  --DEFAULT=  0 %        MAX random % DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND.  EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L & R TO DRIFT RELATIVELY, DUE TO HALF SECOND RANDOM WALKS BTWN speed UPDATES (CAN VERIFY WITH MONO→STEREO SCREEN RECORDING).
    seek_limit         =   .5,  --DEFAULT= .5 SECONDS  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    resync_delay       =   30,  --DEFAULT= 60 SECONDS  os_sync RESYNC WITH THIS DELAY.   mp.get_time() & os.clock() MAY BE BASED ON CPU TIME, WHICH GOES OFF WITH RANDOM LAG.
    auto_delay         =  .25,  --DEFAULT= .5 SECONDS  subprocess RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    os_sync_delay      =  .01,  --DEFAULT=.01 SECONDS  ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    min_samples_time   =   20,  --DEFAULT= 15 SECONDS  SAMPLE COUNT STABILIZES WITHIN 10 SECONDS (EXCEPT MAYBE ON YOUTUBE+lavfi-complex).  IT'S ALWAYS A HALF-INTEGER @MEASUREMENT.
    timeout            =   10,  --DEFAULT=  5 SECONDS  SUBPROCESSES ALL quit  IF CONTROLLER STOPS       FOR THIS LONG. 
    timeout_pause      =    5,  --DEFAULT=  2 SECONDS  SUBPROCESSES ALL pause IF CONTROLLER HARD BREAKS FOR THIS LONG. THEY pause INSTANTLY ON STOP.
    -- meta_osd        =    1,  --SECONDS TO DISPLAY astats METADATA, PER OBSERVATION. UNCOMMENT FOR STATS.  IRONICALLY astats (audio STATISTICS) DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    -- mutelr          = 'muter', --DEFAULT='mutel'    UNCOMMENT TO SWITCH PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN NORMAL SYNC TO video.  HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    options            = ''       --FREE FORM  ' opt1 val1  opt2=val2  --opt3=val3 '  
          ..' image-display-duration=inf         '  --JPEG clock.
       -- ..'       osd-border-color=.5/.5/.5/.5 '  --CONTROLS clock FONT OUTLINE. DEFAULT=0=0/1=y/a=BRIGHTNESS/ALPHA (OPAQUENESS).  RED=1/0/0, BLUE=0/0/1, ETC
       -- ..' audio-pitch-correction=no          '  --UNCOMMENT FOR CHIPMUNK MODE (ON ALL BUT PRIMARY CHANNEL). WORKS OK WITH SPEECH & COMICAL MUSIC. DEFAULT=yes APPLIES scaletempo2(?) FILTER. 
    ,
} 
o         = options  --ABBREV.
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,filterchain='anull',mpv={},extra_devices_index_list={},max_random_percent=0,max_speed_ratio=1.2,seek_limit=.5,auto_delay=.5,resync_delay=60,os_sync_delay=.01,min_samples_time=15,timeout=10,timeout_pause=1,mutelr='mutel',options=''})
do o[opt] = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true 
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not val then break    end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

for opt in ('seek_limit resync_delay min_samples_time timeout timeout_pause'):gmatch('[^ ]+') 
do o[opt] = o[opt]+0 end  --CONVERSION →number
directory = require 'mp.utils'.split_path(mp.get_property_native('scripts')[1])  --SCRIPT FOLDER. UTILITIES SHOULD BE AVOIDED & POTENTIALLY NOT FUTURE COMPATIBLE. HOWEVER CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory = mp.command_native({'expand-path',directory}) --command_native EXPANDS ~/
label,pid,script_opts = mp.get_script_name(),mp.get_property('pid'),mp.get_property_native('script-opts')  --label=aspeed
mutelr    = script_opts.mutel and 'mutel' or script_opts.muter and 'muter' --mutelr IS A GRAPH INSERT.
if mutelr then math.randomseed(pid)  --UNIQUE randomseed FOR ALL SUBPROCESSES. OTHERWISE TEMPO MAY BE SAME OR PREDICTABLE.
    pid   = script_opts.pid  --pid FOR txtpath. COULD BE MOVED → txt.pid.
    
    mp.set_property_bool('vid'      ,false)
    mp.set_property_bool('keep-open',true )  --FOR seek NEAR end-file. STOPS MPV FROM IDLING.
    mp.set_property('msg-level'  ,'all=no')  --STOPS CONTROLLER LOG FROM FILLING UP. SOMEHOW SUBPROCESSES PIPE BACK, IN WINDOWS.  THEY REPORT A fatal ERROR FOR JPEG - BUT IT'S ~FATAL.
    mp.set_property('ytdl-format','bestaudio/best')

else is_controller,o.auto_delay,mutelr = true,.5,o.mutelr  --CONTROLLER auto_delay EXISTS TO STOP timeout.
    audio_device_list,devices = mp.get_property_native('audio-device-list'),{mp.get_property('audio-device')}  --devices IS LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device). audio_device_list IS COMPLETE LIST.  "wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).  IT DOESN'T GIVE THE SAMPLERATES NOR CHANNEL-COUNTS. RANDOMIZING EACH CHANNEL WOULD REQUIRE SUBPROCESSES TO START THEIR OWN SUBPROCESSES (LIKE A BRANCHING TREE).
    clock          = o.clock and mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.   
    if   o  .clock and type(o.clock)~='string'  --ASSUME FLAG FOR ALL FORMAT CODES.
    then o  .clock = ''
        for key in ('a A b B c d H I j m M p S U w W x X y Y Z'):gmatch('[^ ]') 
        do o.clock = ('%s\n%%%%%s=%%%s'):format(o.clock,key,key) end  --MONOSPACE FONT PREFERRED.
        o   .clock = (o.clock):sub(2) end  --REMOVE LEADING \n.
    for _,command in pairs(o.mpv) do if mp.command_native({'subprocess',command}).error_string~='init'  --error=init IF INCORRECT COMMAND.  subprocess (NOT run) RETURNS.
        then mpv   = command
            break end end 
    
    for _,index in pairs(o.extra_devices_index_list) 
    do is_present = false
        device    = (audio_device_list[index] or {}).name
            for _,find in pairs(devices) do if device==find then is_present=true  --SEARCH FOR DUPLICATES BEFORE INSERTION. SIMILAR TO main.lua
                    break end end
            if not is_present then table.insert(devices,device) end end end
txtpath=('%s/%s-PID%d.txt'):format(directory,label,pid)  --"/" FOR WINDOWS & UNIX. txtfile INSTEAD OF PIPES. CREATED FOR RAW JPEG ALSO, TO HANDLE playlist-next.

if is_controller then lavfi=('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d'):format(o.filterchain,mutelr)
else                  lavfi=('stereotools,astats=.5:1,%s,stereotools=%s=1'                                       ):format(o.filterchain,mutelr) end  --(MAYBE) LESS CPU USAGE WITHOUT asplit.

----lavfi         = [graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT. 
----stereotools   = ...:mutel:muter (BOOLS)  DEFAULT=...:0:0  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED stereo FOR RELIABILITY. ALSO MUTES EITHER SIDE. FFMPEG-v4 INCOMPATIBLE WITH softclip.
----astats        = length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC.  MPV-v0.38 CAN SYNC ON ITS OWN WITHOUT astats (BUT NOT v0.36).
----dynaudnorm    = ...:g:p:m  DEFAULT=...:31:.95:10  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). A 2 STAGE PROCESS MIGHT BE IDEAL (SMALL g → BIG g).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. IT'S USED SEVERAL TIMES SIMULTANEOUSLY: EACH SPEAKER + lavfi-complex + VARIOUS GRAPHICS.
----astreamselect = inputs:map  IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH (CAN VERIFY BY TOGGLING NORMALIZER IN SMPLAYER). SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.
----anull           PLACEHOLDER.
----asplit          [ao]→[0][1]=[NOmutelr][mutelr]


lavfi=not o.mpv[1] and o.filterchain or lavfi  --OVERRIDE (NO SUBPROCESSES).

function start_file()  --LAUNCH INSTANTLY, FOR YOUTUBE. AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart
    path=mp.get_property('path')
    if not mpv then return end  --OVERRIDE, ALREADY LAUNCHED, OR ~is_controller. CONTROLLER ONLY BELOW.  ALSO LAUNCH ON JPEG, FOR MPV PLAYLIST.
    script,script_opts = ('%s/%s.lua'):format(directory,label),mp.get_property('script-opts')  --ytdl_hook SCRIPT-OPT POTENTIALLY UNSAFE & ONLY EVER DECLARED ONCE (SEE TASK MANAGER).  COULD SWITCH .lua TO .js FOR JAVASCRIPT.   
    for N,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('[^ ]+') do if not (N==1 and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY device CHANNEL (INTERFERENCE). 
            then mp.command_native({name='subprocess',playback_only=false,capture_stdout=false,capture_stderr=false,detach=true,  --EXTRA FLAGS FOR UNIX RELIABILITY, & BACKWARDS COMPATIBILITY.  script-opts COULD BE REPLACED BY env (ENVIRONMENTAL VARIABLES FOR EACH MPV).
                        args={mpv,'--idle','--script='..script,('--script-opts=%s=1,pid=%d,%s'):format(mutelr,pid,script_opts),'--audio-device='..device}}) end end end  --mutelr & audio-device VARY.
    mpv=nil
end
mp.register_event('start-file',start_file) 

map,m = 1,{}  --GRAPH SWITCH & ITS MEMORY. CHANGES ONLY FOR CONTROLLER. ONLY REPLACE GRAPH IF IT CHANGES.
function file_loaded() 
    if m.map ~= map then mp.command(("no-osd af pre '@%s:lavfi=[%s]'"):format(label,lavfi):format(map)) end  --GRAPH INSERTION. "''" FOR SPACEBARS IN filterchain.  astats USES SOURCE samplerate.  
    m   .map  = map
end
mp.register_event('file-loaded',file_loaded)  --RISKY TO INSERT GRAPH SOONER (DEPENDING ON FFMPEG VERSION).  HARDWARE samplerate UNKNOWN @file-loaded.
mp.register_event('seek'       ,file_loaded)  --RELOAD @seek.
mp.register_event('shutdown'   ,function() os.remove(txtpath) end)

function playback_restart() 
    if m.map~=map then mp.command(('af-command %s map %d %s'):format(label,map,target)) end  --FOR TOGGLE DURING seeking, BUT AFTER seek (ALREADY RELOADED).
    on_frame_drop()  --RESET SAMPLE COUNT.
    for N=1,4 do mp.add_timeout(2^N,os_sync) end   --RESYNC ON EXPONENTIAL TIMEOUTS, DUE TO HDD LAG. 0 2 4 8 16 SECONDS.
end  
mp.register_event('playback-restart',playback_restart)

function on_frame_drop()  --ALSO @playback-restart.  
    initial_time_pos=nil  
    os_sync()  
end
mp.observe_property('frame-drop-count','number',on_frame_drop)  --BUGFIX FOR EXCESSIVE LAG: RESET SAMPLE COUNT & RESYNC clock.

function on_toggle(property)  --CONTROLLER ONLY. INSTA-TOGGLE (SWITCH). SUBPROCESSES MAINTAIN SYNC WHEN OFF.
    if not (path and is_controller) then return  --NOT STARTED YET.
    elseif property and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.  DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute IF seeking.
    else OFF,map = not OFF,1-map --TOGGLE:  1,0 = ON,OFF 
        if OFF then mp.add_timeout(.4,function() txt.mute=OFF end) --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command! THE EXACT timeout COULD BE A NEW option.  GRAPH REPLACEMENT INTERRUPTS PLAYBACK.
        else                                     txt.mute=OFF end  --INSTANT UNMUTE.
        
        if not target then _,error_input = mp.command(('af-command %s map %d astreamselect'):format(label,map)) end  --NULL-OP TO ACQUIRE target.
        target=target or error_input and '' or 'astreamselect'   --OLD MPV OR NEW. v0.37.0+ SUPPORTS TARGETED COMMANDS.
        
        mp.command(('af-command %s map %d %s'):format(label,map,target))  --NO unpause_on_toggle.
        clock_update() end --INSTANT clock_update, OR IT WAITS TO SYNC.
end
for key in (o.key_bindings):gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_aspeed_'..key, on_toggle)  end 

function clock_update()                        
    if clock then if OFF then clock:remove() --OFF SWITCH.  COULD ALSO BE MADE SMOOTH BY VARYING {\\alpha##} IN o.clock.
        else timers.osd:resume() 
             clock.data=os.date(o.clock):gsub('{}0','{}') --REMOVE LEADING 0 AFTER "{}" NULL-OP STYLE CODE.
             clock:update() end end
end

timers  ={  --CARRY OVER IN MPV PLAYLIST.
    osd =mp.add_periodic_timer(1,clock_update),  --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS IRRELEVANT TO audio SYNC.
    mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end ),   --FOR on_toggle. 0 SECONDS VALID. 
}
timers.mute.oneshot=true  
timers.mute:kill()
clock_update()  --INSTANT clock.

function os_sync()  --RUN 10ms LOOP UNTIL SYSTEM CLOCK TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC time-pos WITH SUBPROCESSES. 
    if not time1 then time1=os.time()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH). COULD BE RENAMED "time_syncing".
        timers.os_sync:resume() 
        return end
    
    sync_time=os.time()  --INTEGER SECONDS FROM 1970, @EXACT TICK OF CLOCK.
    if sync_time>time1 then time1,mp2os_time = nil,sync_time-mp.get_time()   --time1 ACTS AS A SWITCH. mp2os_time=os_time_relative_to_mp_time IS THE CONSTANT TO ADD TO MPVTIME TO GET TIMEFROM1970 TO WITHIN 10ms.  mp.get_time()=os.clock()+CONSTANT (GIVES SAME NET RESULT).
        timers.os_sync:kill()
        timers.osd    :kill()  --SYNC clock TICK TO SYSTEM. 
        clock_update() end
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR txtfile.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

p,txt,key = {},{},'lavfi.astats.Overall.Number_of_samples' --p=PROPERTIES(CONTROLLER)  txt=PROPERTIES(txtfile)  key=LOCATION OF astats SAMPLE COUNT.  TESTED @OVER 1 BILLION.
function property_handler(property,val)     --CONTROLLER WRITES TO txtfile, & SUBPROCESSES READ FROM IT.  ONLY EVER pcall, FOR RELIABLE INSTANT write/SIMULTANEOUS io.remove.
    if property=='current-tracks/audio' then property='a' end  --a=current-tracks/audio  
    if property then p[property]=val 
        if property~='af-metadata/'..label and not is_controller then return end end  --OBSERVING SUBPROCESSES END HERE, EXCEPT ON astats TRIGGER. CONTROLLER PROCEEDS.
    
    os_time      = mp2os_time and mp2os_time+mp.get_time() or os.time()  --os_time=TIMEFROM1970  PRECISE TO 10ms.
    samples_time = type(val)=='table' and val[key] and p.samplerate and val[key]/p.samplerate  --ALWAYS A HALF INTEGER, OR nil.  TIME=sample#/samplerate  string[key] BUGS OUT ON 32-BIT.
    time_pos     = mp.get_property_number('time-pos') or 0  --0 DURING YOUTUBE LOAD TO STOP timeout. 
    
    if sync_time and os_time-sync_time>o.resync_delay then os_sync() end  --RESYNC EVERY 30s.
    if samples_time and samples_time>o.min_samples_time  --THESE 3 LINES ARE FOR BACKWARDS COMPATIBILITY. MPV-v0.36 (& MAYBE v0.37) CAN'T SYNC WITHOUT astats. BOTH MP4 & MP3 LAG BEHIND THE SUBPROCESSES.  time-pos, playback-time & audio-pts WORKED WELL OVER 1 MINUTE, BUT NOT 1 HOUR.
    then initial_time_pos = initial_time_pos or time_pos-samples_time  --initial_time_pos=initial_time_pos_relative_to_samples_time  INITIALIZE AFTER CHECKING samples_time. THIS # STAYS THE SAME FOR THE NEXT 10 HOURS. 
         time_pos         = initial_time_pos+samples_time end  --NEW METRIC WHOSE CHANGE IS BASED ON astats (METRIC SWITCH). 
    
    if is_controller then if property=='mute' then on_toggle('mute') end  --FOR DOUBLE mute TOGGLE.
        txt.speed=(not p.a or p.pause or p.seeking) and 0 or p.speed or 0 --seeking→pause FIXES A YOUTUBE STARTING GLITCH.
        if not o.mpv[1] or not path or not property and txt.speed>0 and p.a then return  --return CONDITIONS.  OVERRIDE: NO SUBPROCESSES.  OR NOT STARTED YET.  OR ELSE IT'S THE auto IDLER, TO STOP timeout WHEN SPEED=0 (UNLESS JPEG). THE IDLER SHOULD ALWAYS BE RUNNING FOR RELIABILITY. PURE JPEG MAYBE PART OF A PLAYLIST (INTERMISSION BTWN FILES).
        elseif o.meta_osd and samples_time then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t'),o.meta_osd) end   --TAB EACH STAT (TOO MANY LINES), FOR osd.  samples_time CORRESPONDS TO NEW OBSERVATION.
        
        txtfile=io.open(txtpath,'w+')  --w+=ERASE+WRITE  w ALSO WORKS.  MACOS-11 (DIFFERENT LUA VERSION) REQUIRES txtfile BE WELL-DEFINED.
        txtfile:write( ('%s\n%d\n%d\n%s\n%s\n%s\n%s\n'):format(  --CONTROLLER REPORT.  SECURITY PRECAUTION: NO property NAMES, OR ELSE AN ARBITRARY set COULD HOOK A YOUTUBE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.  
            path,
            p.a and p.a.id or 1,  --id=1 BEFORE YOUTUBE LOADS. a.id MAYBE MORE RELIABLE THAN aid (lavfi-complex BUG). 
            (txt.mute or p.mute) and 0 or p.volume or 0,  --RANGE [0,100]. OFF-SWITCH & mute.  " or 0" FOR 32-BIT RELIABILITY.
            txt.speed,
            round(os_time ,.001), --MILLISECOND PRECISION LIMITER.
            round(time_pos,.001), 
            p.priority or '' ) )  --'' FOR UNIX.
        txtfile:close()  --EITHER flush() OR close(). 
        return end  --CONTROLLER ENDS HERE.  SUBPROCESSES BELOW.
        
    txt.os_time=txt.os_time or os_time  --INITIALIZATION. SUBPROCESSES WILL quit IF txtfile NEVER COMES INTO EXISTENCE.
    time_from_write,txtfile = os_time-txt.os_time,io.open(txtpath)  --'r' MODE, 'r+' ALSO WORKS.  ALTERNATIVE io.lines RAISES ERROR.
    if time_from_write>o.timeout then mp.command('quit') end  --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout.  txtfile CAN'T TELL WHEN TO quit, BECAUSE SOME SUBPROCESSES WOULD quit WITHOUT THE OTHERS.
    if time_from_write>o.timeout_pause or not txtfile then mp.set_property_bool('pause' ,true) end  --INSTEAD OF EXITING, MERELY MUTE.
    if not txtfile then return end  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.
    
    lines    = txtfile:lines()  --ITERATOR RETURNS 0 OR 7 LINES, AS function. 
    txt.path = lines()          --LINE1=path
    if not txt.path then txtfile:close()  --SOMETIMES BLANK.  close MAY BE NEEDED FOR RELIABILITY.
        return 
    elseif txt.path~=path then mp.commandv('loadfile',txt.path) end  --commandv FOR FILENAMES. CAN ALSO INSERT FLAGS, LIKE "start=".
    
    for line in ('aid volume speed os_time time_pos'):gmatch('[^ ]+') do txt[line]=lines()+0 end  --LINES 2→6
    time_from_write,txt.priority = os_time-txt.os_time,lines()  --RECOMPUTE time_from_write.  LINE7=priority
    txt.speed   = (txt.path~=path or    time_from_write>o.timeout_pause) and 0 or txt.speed  --loadfile PAUSED. 0 MEANS PAUSE.
    time_gained = time_pos-txt.time_pos-time_from_write*txt.speed  --=Δtime_pos-Δos_time*speed
    txtfile:close()  --close NEEDED, BUT RARELY (SUDDEN LAG MAY CAUSE FAILURE).
    
    if p.a.id     ~= txt.aid        then mp.set_property_number('aid'   ,txt.aid   ) end  --UNTESTED. MAY REQUIRE GRAPH REPLACEMENT?
    if p.volume   ~= txt.volume     then mp.set_property_number('volume',txt.volume) end
    if p.pause    ~= (txt.speed==0) then mp.set_property_bool('pause' ,txt.speed==0) end
    if p.priority ~= txt.priority   then mp.set_property('priority',txt.priority   ) end  --~priority FOR UNIX.  PROPAGATING VIA TASK MANAGER NOT SUPPORTED BECAUSE MPV DOESN'T KNOW ITS OWN priority.
    
    if math.abs(time_gained)>o.seek_limit then mp.command(('seek %s exact'):format(-time_gained))     --SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED).  ANOTHER LINE OF CODE MAY BE NEEDED TO IMPROVE INITIAL DRUM-ROLL (--idle TRIGGER).
        time_gained=0 end
    if txt.speed==0 or not (mp2os_time and samples_time) then return end --BELOW REQUIRES NON-0 TARGET speed, & ACCURATE os_time & time_pos.  auto TIMER ENDS HERE BECAUSE IT DOESN'T KNOW samples_time.
    
    speed=txt.speed*(1-time_gained/.5)*(1+math.random(-o.max_random_percent,o.max_random_percent)/100)  --time_gained→0 OVER NEXT .5 SECONDS IN time-pos (astats UPDATE TIME). +-RANDOM EXTRA.  RANDOM BOUNDS [.9,1.1] MAYBE SHOULD BE [1/1.1,1.1]=[.91,1.1]. 1% SKEWED TOWARDS SLOWING IT DOWN.
    speed=math.min(math.max( speed , txt.speed/o.max_speed_ratio ), txt.speed*o.max_speed_ratio )  --speed LIMIT RELATIVE TO CONTROLLER.  LUA DOESN'T SUPPORT math.clip(#,min,max)=math.min(math.max(#,min),max)
    mp.set_property_number('speed',speed)
end
for property in ('mute pause seeking volume speed priority current-tracks/audio af-metadata/'..label):gmatch('[^ ]+')        --INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall.  BOOLS, NUMBERS, string & TABLES.
    do mp.observe_property(property,          'native',function(property,val) pcall(property_handler,property,val)  end) end --TRIGGERS INSTANTLY.  astats TRIGGERS EVERY HALF A SECOND, ON playback-restart, frame-drop-count & shutdown.
timers.auto=mp.add_periodic_timer(o.auto_delay,        function(            ) pcall(property_handler             )  end)     --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.
mp.observe_property('audio-params/samplerate','number',function(property,val) p.samplerate,initial_time_pos = val,nil end)   --samplerate MAY DEPEND ON lavfi-complex.  ALSO RESET SAMPLE COUNT.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0(.7z .exe v3) v0.37.0(.app) v0.36.0(.exe .app .flatpak .snap v3) v0.35.1(.AppImage)  ALL TESTED. 
----FFMPEG v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS OFTEN BUILT WITH FFMPEG v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----BUG: SUBPROCESSES TOO SLOW TO seek THROUGH LONG YOUTUBE VIDEOS. FEEDBACK COULD BE USED TO TOGGLE OFF (CHILDREN COULD ALSO WRITE TO txtfile). 
----autospeed.lua IS A DIFFERENT SCRIPT FOR VIDEO speed, NOT AUDIO. "autotempo.lua" OR "atempo.lua" MIGHT BE GOOD NAMES.
----A FUTURE SMOOTH TOGGLE COULD WORK USING volume & amix INSTEAD OF astreamselect.  astats SHOULDN'T EVEN BE THERE IN MPV-v0.38...
----GRAND-CHILD SUBPROCESSES COULD WORK FOR SURROUND SOUND. EACH CHILD LAUNCHES ITS OWN CHILDREN TO COVER ALL device CHANNELS.  BUT STEREOS ARE CHEAPER!  CODING FOR A SURROUND SOUND SOURCE SIGNAL IS EVEN MORE COMPLICATED. 
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY MAY BE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET. I HAVE A PIPE VERSION OF THIS SCRIPT BUT PREFER txtfile.  INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----acompressor      SMPLAYER DEFAULT NORMALIZER.
----firequalizer OLD SMPLAYER DEFAULT NORMALIZER.
----loudnorm=I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----volume  =volume:...:eval  (DEFAULT 1:once)  POSSIBLE TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.  COULD BE USED FOR SMOOTH TOGGLE (ALTERNATIVE TO astreamselect), BECAUSE IT CAN VARY volume WITHIN amix.
----aresample     (Hz)  OPTIONAL.  OUTPUTS CONSTANT samplerate → astats.
----aformat =sample_fmts:sample_rates  [u8 s16 s64]:Hz  OPTIONAL ALTERNATIVE TO aresample.  OUTPUTS CONSTANT samplerate → astats.  s16=SGN+15BIT (-32k→32k), CD. u8 CAUSES HISSING.  

----MORE CLOCKS. TOO MANY FLAGS WITH EMBLEMS, SO PURE TRICOLORS OR BICOLORS ONLY. MISSISSIPPI STATE FLAG LOOKS GOOD, TOO (1 MISSISSIPPI, 2 MISSISSIPPI, 3 MISSISSIPPI).  A SEPARATE "clock.lua" SCRIPT COULD GET THEM ALL EXACTLY RIGHT. RESYNCING THE EXACT TICK EVERY 30s USES 0% CPU.
    -- BARBADOS , clock='{\\an3\\fs55\\bord3\\c7F2600}%I{\\bord0\\c0}:{\\bord3\\c26C7FF}{}%M{\\bord0\\c0}:{\\bord3\\c7F2600}%S{\\fs33\\bord0\\c0\\b1} %a',  --BLUE :YEL   :BLUE Black,  SINGLE DIGIT MINUTES.
    -- ANDORRA  , clock='{\\an3\\fs55\\bord2\\c9F0610}%I{\\bord0\\c0}:{\\bord2\\c00DDFE}%M{\\bord0\\c0}:{\\bord2\\c3200D5}%S{\\fs33\\bord0\\c0\\be1} %a' ,  --BLUE :YELLOW:RED  Black
    -- MEXICO   , clock='{\\an3\\fs55\\bord2\\c476800}%I{\\bord0\\c0}:{\\bord2\\cFFFFFF}%M{\\bord0\\c0}:{\\bord2\\c2511CE}%S{\\fs33\\bord0\\c0\\be1} %a' ,  --GREEN:WHITE :RED  Black,  AN ITALIAN TRICOLOR IS CLOSE TO MEXICAN (LATINO CATHOLIC).  
    -- ALGERIA  , clock='{\\an3\\fs55\\bord3\\c336600}%I{\\bord0\\c0}:{\\bord3\\cFFFFFF}%M{\\fs33\\bord0\\c0\\b1} %p',  --GREEN:WHITE BLACK,  BIBAR.                          
    
