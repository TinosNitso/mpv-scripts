----ADD clock TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. clock TICKS WITH SYSTEM, & MAY BE COLORFUL. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PRIORITY, PATH, AID & LAG APPLY TO ALL DETACHED subprocesses. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER. CHANGING samplerate REQUIRES STOP & PLAY.    USB→3.5mm SOUND CARDS COST AS LITTLE AS $2 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW mpv IN TASK MANAGER. VIRTUALBOX USB SUPPORT ENABLES MANY AUDIO OUTPUTS.
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.

options={  --ALL OPTIONAL & MAY BE REMOVED.
    key_bindings         ='F3', --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m. 'F3 F4' FOR 2 KEYS. F1 & F2 MIGHT BE autocomplex & automask. s=SCREENSHOT (NOT SPEED NOR SPECTRUM). C IS CROP, NOT CLOCK.
    toggle_on_double_mute=.5,   --SECONDS TIMEOUT FOR DOUBLE-MUTE-TOGGLE. LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute.  TOGGLE DOESN'T SWITCH OFF dynaudnorm (FRAME-TIMING ISSUE).
    
    clock='{\\fs71\\bord2\\an3}{}%I{\\fs50}:%M{\\fs35}:%S{\\fs25} %p', --REMOVE TO remove clock. {} REMOVES LEADING 0 FOLLOWING IT.  fs,bord,an,%I,%M,%S,%p = FONT-SIZE,BORDER,ALIGNMENT-NUMPAD,HRS(12),MINS,SECS,P/AM  (DEFAULT an0=an7=TOPLEFT)  BIG:MEDium:Little:tiny, RATIO=SQRT(.5)=.71  FORMATTERS: a A b B c d H I M m p S w x X Y y  shad1,b1,i1,u1,s1,be1,fn = SHADOW,BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME  REQUIRES [vo] TO BE SEEN (NOT RAW MP3).  main.lua HAS title, WITHOUT TOGGLE.
    -- clock='{\\fs55\\bord2\\an3\\cFF4C00}%I{\\c0}:{\\cFFFFFF}%M{\\c0}:{\\cFF}%S{\\fs39\\c0\\bord0} %p', --UNCOMMENT FOR COLORED clock. "BLUE:WHITE:RED black", LIKE A TRIBAR FLAG (TRI-COLOR clock).  COLOR=\cFF4C00 IS A BRIGHTER SHADE OF BLUE (HEX ORDERED BGR).  AN UNUSED BIG SCREEN TV CAN BE A BIG clock WITH BACKGROUND VIDEO.
    
    filterchain='anull,'  --CAN REPLACE anull WITH EXTRA FILTERS (highpass aresample vibrato ...).
              ..'dynaudnorm=500:5:1:100', --DEFAULT=500:31:.95:10='f:g:p:m'  DYNAMIC AUDIO NORMALIZER.  ALL subprocesses USE THIS NORMALIZER. GRAPH COMMENTARY HAS MORE DETAILS.
    mpv={  --REMOVE FOR clock ONLY OVERRIDE (+filterchain). LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE. USED BY ALL subprocesses. A COMMAND MAY NOT BE A PATH.  INSTEAD OF COPY/PASTING THE clock INTO OTHER SCRIPT/S, THIS SCRIPT SYNCS IT TO SYSTEM TICK.
        "mpv",   --LINUX & SMPLAYER (WINDOWS)
        "./mpv", --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv",       --     mpv.app
        "/Applications/SMPlayer.app/Contents/MacOS/mpv",  --SMPlayer.app
    },
    
    -- extra_devices_index_list={3,4}, --TRY {2,3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. REPETITION IGNORED. 1=auto WHICH MAY DOUBLE-OVERLAP AUDIO TO PRIMARY DEVICE. 3=VIRTUALBOX USB STEREO. EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS.  EACH MPV USES APPROX 1% CPU, + 40MB RAM.
    max_random_percent      =  10,  --DEFAULT=0   %        MAX random % DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND. EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L & R TO DRIFT RELATIVELY, DUE TO HALF SECOND RANDOM WALKS BTWN speed UPDATES (CAN VERIFY WITH MONO→STEREO SCREEN RECORDING).
    max_speed_ratio         =1.15,  --DEFAULT=1.2          speed IS BOUNDED BY [SPEED/max,SPEED*max], WITH SPEED FROM CONTROLLER.  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    seek_limit              =  .5,  --DEFAULT=.5  SECONDS  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    auto_delay              = .25,  --DEFAULT=.5  SECONDS  subprocess RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    resync_delay            =  30,  --DEFAULT=60  SECONDS  os_sync RESYNC WITH THIS DELAY.   mp.get_time() & os.clock() MAY BE BASED ON CPU TIME, WHICH GOES OFF WITH RANDOM LAG.
    os_sync_delay           = .01,  --DEFAULT=.01 SECONDS  ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    samples_time_min        =  20,  --DEFAULT=10  SECONDS  SAMPLE COUNT STABILIZES WITHIN 10 SECONDS. SOMETIMES IT COUNTS 5.5s OF SAMPLES JUST TO PERFORM A seek, DUE TO lavfi-complex. IT'S ALWAYS A HALF-INTEGER.
    timeout                 =  10,  --DEFAULT=5   SECONDS  subprocesses ALL quit IF CONTROLLER STOPS FOR THIS LONG. 
    timeout_mute            =   2,  --DEFAULT=2   SECONDS  subprocesses ALL MUTE IF CONTROLLER HARD BREAKS FOR THIS LONG. THEY MUTE INSTANTLY ON STOP.
    -- meta_osd             =   1,  --SECONDS TO DISPLAY astats METADATA, PER OBSERVATION.  IRONICALLY astats (audio STATISTICS) DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    mutelr                  ='mutel', --DEFAULT='mutel'  'muter' SWITCHES PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN NORMAL SYNC TO video. HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    options                 =''       --FREE FORM ' opt1 val1  opt2=val2  --opt3=val3 '...
          ..' audio-delay=0  image-display-duration=inf'  --NON-0 delay COULD BE SMPLAYER ACCIDENTAL +- KEYTAP. inf GIVES JPEG A clock.
       -- ..' audio-pitch-correction=no'                 --UNCOMMENT FOR CHIPMUNK MODE. WORKS OK WITH SPEECH BUT NOT MUSIC. DEFAULT=yes APPLIES scaletempo2(?) FILTER.
       -- ..'   osd-color=1/.5    osd-border-color=0/.5' --UNCOMMENT FOR TRANSPARENT clock. DEFAULTS 1/1 & 0/1. y/a = brightness/alpha (OPAQUENESS).  A TRANSPARENT clock CAN BE TWICE AS BIG. RED=1/0/0/1, BLUE=0/0/1/1, ETC
    ,
}
o        =options  --ABBREV.
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,filterchain='anull',mpv={},extra_devices_index_list={},max_random_percent=0,max_speed_ratio=1.2,seek_limit=.5,auto_delay=.5,resync_delay=60,os_sync_delay=.01,samples_time_min=10,timeout=5,timeout_mute=2,mutelr='mutel',options=''})
do o[opt]=o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options=(o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true 
do   opt =o.options()  
     find=opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val =find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt =find and (opt):sub(0,find-1) or opt
     if not (opt and val) then break end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

directory=require 'mp.utils'.split_path(mp.get_property_native('scripts')[1])  --SCRIPT FOLDER. UTILITIES SHOULD BE AVOIDED & POTENTIALLY NOT FUTURE COMPATIBLE. HOWEVER CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory=mp.command_native({'expand-path',directory}) --command_native EXPANDS ~/
label,pid,script_opts = mp.get_script_name(),mp.get_property('pid'),mp.get_property_native('script-opts')  --label=aspeed
mutelr   =script_opts.mutel and 'mutel' or script_opts.muter and 'muter' --mutelr IS A GRAPH INSERT.

if mutelr then math.randomseed(pid)  --UNIQUE randomseed FOR ALL subprocesses. OTHERWISE TEMPO MAY BE PREDICTABLE OR SAME.
    mp.set_property_bool('vid'      ,false)
    mp.set_property_bool('keep-open',true )  --FOR seek NEAR end-file. STOPS MPV FROM IDLING.
    mp.set_property('msg-level'  ,'all=no')  --STOPS CONTROLLER LOG FROM FILLING UP.   
    mp.set_property('ytdl-format','bestaudio/best')  --OPTIONAL?
else is_controller,o.auto_delay,mutelr,script_opts.pid = true,.5,o.mutelr,pid  --CONTROLLER.  ..'' CONVERTS→string (script-opts ARE STRINGS). auto_delay EXISTS ONLY TO STOP timeout. ALL txtfile WRITES INSTANT.
    audio_device_list,devices = mp.get_property_native('audio-device-list'),{mp.get_property('audio-device')}  --devices IS LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device). audio_device_list IS COMPLETE LIST.  "wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).  IT DOESN'T GIVE THE SAMPLERATES NOR CHANNEL-COUNTS. RANDOMIZING EACH CHANNEL WOULD REQUIRE subprocesses TO START THEIR OWN subprocesses (LIKE A BRANCHING TREE).
    clock=o.clock and mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.   
    
    for _,command in pairs(o.mpv) do if mp.command_native({'subprocess',command}).error_string~='init' then mpv=command  --error=init IF INCORRECT COMMAND. OTHERWISE error USUALLY killed, BUT ALWAYS RETURNED. subprocess RETURNS, NOT run.
            break end end 
    for _,index in pairs(o.extra_devices_index_list) do if index<=#audio_device_list then is_present,device = false,audio_device_list[index].name
            for _,find in pairs(devices) do if device==find then is_present=true  --SEARCH FOR DUPLICATES BEFORE INSERTION. SIMILAR TO main.lua
                    break end end
            if not is_present then table.insert(devices,device) end end end end
txtpath=('%s/%s-PID%d.txt'):format(directory,label,script_opts.pid)  --"/" FOR WINDOWS & UNIX. txtfile INSTEAD OF PIPES. CREATED FOR RAW JPEG ALSO, TO HANDLE playlist-next.
if mpv then io.open(txtpath,'w+') end  --subprocesses quit IF THIS FILE DOESN'T EXIST. SIMPLER TO open IN ADVANCE. 


lavfi=('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d')
    :format(                  o.filterchain,             mutelr)

----lavfi        =[graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  EACH LUA SCRIPT MAY CONTROL GRAPH/S, LIKE HOW A CELL CONTROLS DNA. aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT.  PLACING FILTER/S BEFORE astats REQUIRES SEVERAL HOURS TESTING, BECAUSE THEIR OUTPUT SAMPLE COUNT MAY NOT BE DETERMINISTIC.
----stereotools  =...:mutel:muter (BOOLS)  DEFAULTS 0:0  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED stereo FOR RELIABILITY. ALSO MUTES EITHER SIDE. ffmpeg-v4 INCOMPATIBLE WITH softclip.
----astats       =length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC. 
----anull         PLACEHOLDER.
----dynaudnorm   =f:g:p:m  DEFAULT=500:31:.95:10=FRAME(MILLISECONDS):GAUSSIAN_WIN_SIZE(ODD_INTEGER):PEAK_TARGET[0,1]:MAX_GAIN[1,100]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). A 2 STAGE PROCESS MIGHT BE IDEAL (SMALL g → BIG g).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. p=1 MEANS 1-IN→1-OUT. dynaudnorm IS SIMULTANEOUSLY USED SEVERAL TIMES: EACH SPEAKER + lavfi-complex + VARIOUS GRAPHICS.
----asplit        [ao]→[NOmutelr][mutelr]=[0][1]
----astreamselect=inputs:map  IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH (CAN VERIFY BY TOGGLING NORMALIZER IN SMPLAYER). SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.


lavfi=not o.mpv[1] and o.filterchain or lavfi  --OVERRIDE (NO subprocesses).

function start_file()  --LAUNCH INSTANTLY, FOR YOUTUBE. AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart
    path=mp.get_property('path')
    if not mpv then return end  --OVERRIDE, ALREADY LAUNCHED, OR ~is_controller. CONTROLLER ONLY BELOW.  ALSO LAUNCH ON JPEG, FOR MPV PLAYLIST.
    script,script_opts = ('%s/%s.lua'):format(directory,label),mp.get_property('script-opts')  --ytdl_hook POTENTIALLY UNSAFE & ONLY EVER DECLARED ONCE (SEE TASK MANAGER).  COULD SWITCH .lua TO .js FOR JAVASCRIPT.   
    for N,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('[^ ]+') do if not (N==1 and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY device CHANNEL.  'mutel muter' FOR SIMPLICITY BECAUSE IF LOOPING OVER ALL CHANNELS THEIR GEOMETRY IS UNKNOWN.
            then mp.command_native({name='subprocess',playback_only=false,capture_stdout=false,capture_stderr=false,detach=true,  --EXTRA FLAGS FOR UNIX RELIABILITY, & OLD MPV COMPATIBILITY. 
                        args={mpv,'--idle','--script='..script,('--script-opts=%s=1,pid=%d,%s'):format(mutelr,pid,script_opts),'--audio-device='..device}}) end end end  --mutelr & audio-device VARY.
    mpv=nil
end
mp.register_event('start-file',start_file) 

map=1  --GRAPH SWITCH. CHANGES ONLY FOR CONTROLLER. BUT m=MEMORY FOR IT. ONLY REPLACE GRAPH IF IT CHANGES.
function file_loaded() 
    mp.command(("no-osd af pre '@%s:lavfi=[%s]'"):format(label,lavfi):format(map))   --GRAPH INSERTS HERE. astats USES SOURCE samplerate.  "''" FOR SPACEBARS IN filterchain.
end
mp.register_event('file-loaded',file_loaded)  --TRIGGERS BEFORE samplerate OBSERVATION. RISKY TO INSERT GRAPH SOONER (DEPENDING ON FFmpeg VERSION).  HARDWARE samplerate UNKNOWN.
mp.register_event('seek'       ,file_loaded)  --LIKE automask, SAFER TO REPLACE GRAPH @seek IF map CHANGES.

function playback_restart() --ALSO @frame-drop-count.  
    if not target then _,error_string = mp.command(('af-command %s map %d astreamselect'):format(label,map))  --NULL-OP AWAITS playback-restart.
                       target         = error_string and '' or           'astreamselect' end  --OLD MPV OR NEW. v0.37.0+ SUPPORTS TARGETED COMMANDS.
    mp.command(('af-command %s map %d %s'):format(label,map,target))  --path IMPLIES LOADED.  LIKE automask, COVERS SPECIAL CASE OF TOGGLE DURING seeking, BUT AFTER seek.
    on_frame_drop()  --RESET SAMPLE COUNT.
    for N=1,4 do mp.add_timeout(2^N,os_sync) end   --RESYNC ON EXPONENTIAL TIMEOUTS, DUE TO HDD LAG. 0 2 4 8 16 SECONDS.
end  
mp.register_event('playback-restart',playback_restart)
mp.register_event('shutdown',function() os.remove(txtpath) end)

function on_frame_drop()  --BUGFIX FOR EXCESSIVE LAG: RESET SAMPLE COUNT.
    initial_time_pos=nil
    os_sync()  
end
mp.observe_property('frame-drop-count','number',on_frame_drop)

function on_toggle(property)  --CONTROLLER ONLY. INSTA-TOGGLE (SWITCH), NOT PROPER FULL toggle. (PERHAPS A DOUBLE-TAP key_bind COULD TRIGGER FULL TOGGLE.)  subprocesses MAINTAIN SYNC WHEN OFF.
    if not (path and is_controller) then return  --NOT STARTED YET.
    elseif property and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.  DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute IF seeking.
    else OFF,map = not OFF,1-map --TOGGLE:  1,0 = ON,OFF 
        if OFF then mp.add_timeout(.25,function() txt.mute=OFF end)  --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command! THE EXACT timeout COULD BE A NEW option.  GRAPH REPLACEMENT INTERRUPTS PLAYBACK.
        else txt.mute=OFF end    --INSTANT UNMUTE.
        mp.command(('af-command %s map %d %s'):format(label,map,target))  --PAUSED DOESN'T REQUIRE frame-step.
        clock_update() end --INSTANT clock_update, OR IT WAITS TO SYNC.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_aspeed_'..key, on_toggle)  end 

function clock_update()                        
    if clock then if OFF then clock:remove() --OFF SWITCH.
        else timers.osd:resume() 
             clock.data=os.date(o.clock):gsub('{}0','{} ') --REMOVE LEADING 0 AFTER "{}" NULL-OP STYLE CODE.
             clock:update() end end
end

timers  ={
    osd =mp.add_periodic_timer(1,clock_update),  --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS IRRELEVANT TO audio SYNC.
    mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end ),   --FOR on_toggle. 0 SECONDS VALID. CARRY OVER IN MPV PLAYLIST.
}
timers.mute.oneshot=true  
timers.mute:kill()
clock_update()  --INSTANT clock.

function os_sync()  --RUN 10ms LOOP UNTIL SYSTEM CLOCK TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC time-pos WITH subprocesses. 
    if not time1 then time1=os.time()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH). COULD BE RENAMED "time_syncing".
        timers.os_sync:resume() 
        return end
    
    sync_time=os.time()  --INTEGER SECONDS FROM 1970, @EXACT TICK OF CLOCK.
    if sync_time>time1 then time1,mp2os_time = nil,sync_time-mp.get_time()   --time1 ACTS AS A SWITCH. mp2os_time=os_time_relative_to_mp_time IS THE CONSTANT TO ADD TO MPVTIME TO GET TIMEFROM1970 TO WITHIN 10ms.  mp.get_time()=os.clock()+CONSTANT (GIVE SAME NET RESULT).
        timers.os_sync:kill()
        timers.osd    :kill()  --SYNC clock TICK TO SYSTEM. 
        clock_update() end
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil. PRECISION LIMITER FOR txtfile.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

p,txt,key = {},{},'lavfi.astats.Overall.Number_of_samples' --p=PROPERTIES(CONTROLLER).  txt=PROPERTIES(txtfile).  key=LOCATION OF astats SAMPLE COUNT.  TESTED @OVER 1 BILLION.
function property_handler(property,val)     --CONTROLLER WRITES TO txtfile, & subprocesses READ FROM IT.  ONLY EVER pcall, FOR RELIABLE INSTANT write/SIMULTANEOUS io.remove.
    os_time     =mp2os_time and mp2os_time+mp.get_time() or os.time()  --os_time=TIMEFROM1970  PRECISE TO 10ms.
    samples_time=type(val)=='table' and val[key] and samplerate and val[key]/samplerate --ALWAYS A HALF INTEGER, OR nil.  TIME=sample#/samplerate  string[key] BUGS OUT ON 32-BIT.
    time_pos    =mp.get_property_number('time-pos') or 0     --0 DURING YOUTUBE LOAD TO STOP timeout. 
    
    if sync_time and os_time-sync_time>o.resync_delay+0 then os_sync() end  --RESYNC EVERY 30s. +0 CONVERTS→number & IS EASIER TO READ THAN RE-ARRANGING INEQUALITIES.
    if samples_time and samples_time>o.samples_time_min+0 
    then initial_time_pos=initial_time_pos or time_pos-samples_time  --initial_time_pos=initial_time_pos_relative_to_samples_time  INITIALIZE AFTER CHECKING samples_time. THIS # STAYS THE SAME FOR THE NEXT 10 HOURS.  LIKE HOW YOGHURT GOES OFF, 20 HRS LATER THE SPEAKERS MAY BE OFF (astats ISSUE).
         time_pos        =initial_time_pos+samples_time end  --NEW METRIC WHOSE CHANGE IS BASED ON astats (METRIC SWITCH). REMOVE THESE 2 LINES TO PROVE MPV CAN'T SYNC WITHOUT astats, EVEN WITH autosync (UP TO mpv-v0.36). BOTH MP4 & MP3 LAG BEHIND THE subprocesses.  time-pos, playback-time & audio-pts WORK WELL OVER 1 MINUTE, BUT NOT 1 HOUR.
    
    if is_controller then if property=='current-tracks/audio' then property='a'  --a←→current-tracks/audio
        elseif property=='mute' then on_toggle(property)     end  --FOR DOUBLE mute TOGGLE.
        if     property         then         p[property]=val end
        txt.speed  =(not p.a or p.pause or p.seeking) and 0 or p.speed or 0  --seeking→pause FIXES A YOUTUBE STARTING GLITCH.
        
        if not o.mpv[1] or not path or not property and txt.speed>0 and p.a.id then return  --return CONDITIONS.  OVERRIDE: NO subprocesses.  OR NOT STARTED YET.  OR ELSE IT'S THE auto IDLER, TO STOP timeout WHEN SPEED=0 (UNLESS JPEG). THE IDLER SHOULD ALWAYS BE RUNNING FOR RELIABILITY.
        elseif o.meta_osd and samples_time then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t'),o.meta_osd) end   --TAB EACH STAT (TOO MANY LINES), FOR osd.  samples_time CORRESPONDS TO NEW OBSERVATION.
        
        txtfile=io.open(txtpath,'w+')  --w+=ERASE+WRITE  w ALSO WORKS.  MACOS-11 (DIFFERENT LUA VERSION) REQUIRES txtfile BE WELL-DEFINED.
        txtfile:write( ('%s\n%d\n%d\n%s\n%s\n%s\n%s\n'):format(  --CONTROLLER REPORT. SECURITY PRECAUTION: NO property NAMES, OR ELSE AN ARBITRARY set COULD HOOK A YOUTUBE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.  
            path,
            p.a and p.a.id or 1,  --id=1 BEFORE YOUTUBE LOADS. a.id MORE RELIABLE THAN aid (lavfi-complex BUG). 
            (txt.mute or p.mute) and 0 or p.volume or 0,  --RANGE [0,100]. OFF-SWITCH & mute.  " or 0" FOR 32-BIT RELIABILITY.
            txt.speed,
            round(os_time ,.001), --MILLISECOND PRECISION LIMITER.
            round(time_pos,.001), 
            p.priority or '' ) )  --'' FOR UNIX.
        txtfile:close()  --EITHER flush() OR close(). 
        return end  --CONTROLLER ENDS HERE.  subprocesses BELOW.
    if     txt.os_time and os_time-txt.os_time>o.timeout+0      then mp.command('quit')   --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout. 
    elseif txt.os_time and os_time-txt.os_time>o.timeout_mute+0 then mp.set_property('volume',0) end
    
    txtfile=io.open(txtpath)  --'r' MODE, 'r+' ALSO WORKS.  
    if not txtfile then mp.set_property_number('volume',0)  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.
        return end  
    
    lines   =txtfile:lines()            --lines ITERATOR RETURNS 0 OR 7 LINES, AS function.  ALTERNATIVE io.lines RAISES ERROR.
    txt.path=lines()                    --LINE1=path
    if txt.path=='' then mp.set_property_number('volume',0) end         --BLANK SOMETIMES.
    if not txt.path then return         --BLANK SOMETIMES.
    elseif txt.path~=path then mp.commandv('loadfile',txt.path) end  --commandv FOR FILENAMES. CAN ALSO INSERT FLAGS, LIKE "start=".
    
    mp.set_property('aid'     ,lines()) --LINE2=aid  UNTESTED. MAY REQUIRE GRAPH REPLACEMENT, LIKE automask.
    mp.set_property('volume'  ,lines()) --LINE3=volume
    txt.speed,txt.os_time,txt.time_pos = lines()+0,lines()+0,lines()+0  --LINES 4,5,6 = speed,os_time,time_pos
    mp.set_property('priority',lines()) --LINE7=priority  (OR ''=NULL-OP FOR UNIX).  PROPAGATING VIA TASK MANAGER NOT SUPPORTED BECAUSE MPV MAY NOT KNOW ITS OWN priority.
    
    time_gained=time_pos-txt.time_pos-(os_time-txt.os_time) --SUBTRACT TIME_FROM_WRITE FROM DIFFERENCE BTWN POSITIONS. 
    txt.speed  =txt.path~=path and 0 or txt.speed  --loadfile PAUSED.  (IT SHOULD ALREADY BE 0 IN THAT CASE.)
    mp.set_property_bool('pause',txt.speed==0)  
    
    if txt.speed==0 or os_time-txt.os_time>o.timeout_mute+0 then mp.set_property_number('volume',0) end
    -- if txt.speed==0 then mp.command(('seek %s absolute exact'):format(txt.time_pos)) end --MAYBE seek WHEN PAUSED. POSSIBLE BUGFIX FOR INITIAL DRUMROLL TRIGGER FROM idle? BUT THIS CAUSES INFINITE LOOP WHEN PAUSED (BUG).
    if txt.speed==0 or not (mp2os_time and samples_time) then return     --BELOW REQUIRES ACCURACY IN BOTH os_time & time_pos. auto TIMER ENDS HERE BECAUSE IT DOESN'T KNOW samples_time.
    elseif o.seek_limit and math.abs(time_gained)>o.seek_limit+0         
    then mp.command(('seek %s exact'):format(-time_gained))     --SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED).
        time_gained=0 end
    
    speed=(txt.speed-time_gained/.5)*(1+math.random(-o.max_random_percent,o.max_random_percent)/100) --time_gained→0 OVER NEXT .5 SECONDS (astats UPDATE TIME), EXCEPT FOR RANDOM EXTRA.  TECHNICALLY RANDOM BOUNDS [.9,1.1] SHOULD BE [1/1.1,1.1]=[.91,1.1]. 1% SKEWED TOWARDS SLOWING IT DOWN.
    speed=math.min(math.max( speed , txt.speed/o.max_speed_ratio ), txt.speed*o.max_speed_ratio )    --speed LIMIT RELATIVE TO CONTROLLER.  LUA DOESN'T SUPPORT math.clip(#,min,max)=math.min(math.max(#,min),max)
    mp.set_property_number('speed',speed)
end
if is_controller then for property in ('current-tracks/audio mute volume pause seeking speed priority'):gmatch('[^ ]+')     --INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall.
    do mp.observe_property(property      ,'native',function(property,val) pcall(property_handler,property,val) end) end end --TRIGGER INSTANTLY.
mp.observe_property('af-metadata/'..label,'native',function(property,val) pcall(property_handler,property,val) end)  --TRIGGERS EVERY HALF A SECOND, ON playback-restart, frame-drop-count & shutdown. pcall FOR SIMULTANEOUS io.remove.
timers.auto=mp.add_periodic_timer(o.auto_delay    ,function(            ) pcall(property_handler             ) end)  --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.
mp.observe_property('audio-params/samplerate','number',function(   _,val) samplerate,initial_time_pos = val,nil end) --samplerate MAY DEPEND ON lavfi-complex.  ALSO RESET SAMPLE COUNT.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0 (.7z .exe v3) v0.37.0 (.app?) v0.36.0 (.exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED. 
----FFmpeg v6.0(.7z .exe .flatpak)  v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS ACTUALLY BUILT WITH FFmpeg v4, v5 & v6 (ALL 3), WHICH CHANGES HOW THE GRAPHS ARE WRITTEN (FOR COMPATIBILITY).
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----"autospeed.lua" IS A DIFFERENT SCRIPT FOR VIDEO speed, NOT AUDIO. "autotempo.lua" MIGHT BE A BETTER NAME (I DIDN'T THINK OF IT).
----GRAND-CHILD subprocesses ARE REQUIRED FOR SURROUND SOUND. EACH DEVICE LAUNCHES ITS OWN SECONDARIES TO COVER ALL CHANNELS. HOWEVER IT DOES SO AT A (MUTED) DELAY (DELAYED TRIGGER).  GREAT-GRAND-CHILDREN MAY BE NEEDED TO SELECT FOR EACH TWEETER INSIDE A SPEAKER BOX (EACH TWEETER CAN HAVE A MIND OF ITS OWN).  HOWEVER CODING FOR A SURROUND SOUND SOURCE SIGNAL IS EVEN MORE COMPLICATED. POOR PEOPLE MAY HAVE ONLY STEREOS!
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY MAY BE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET. I HAVE A PIPE VERSION OF THIS SCRIPT BUT PREFER txtfile. MAYBE MORE LIKELY TO WORK, & SAFER, ON ANDROID. INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----acompressor      SMPLAYER DEFAULT NORMALIZER.
----firequalizer OLD SMPLAYER DEFAULT NORMALIZER.
----loudnorm=I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----aresample     (Hz)  OPTIONAL.  OUTPUTS CONSTANT samplerate → astats.
----aformat =sample_fmts:sample_rates  [u8 s16 s64]:Hz  OPTIONAL ALTERNATIVE TO aresample.  OUTPUTS CONSTANT samplerate → astats.  s16=SGN+15BIT (-32k→32k), CD. u8 CAUSES HISSING.  
----volume  =volume:...:eval  (DEFAULT 1:once)  TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.



