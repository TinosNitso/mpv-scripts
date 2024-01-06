----ADD clock TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO speed SCRIPT. clock TICKS WITH SYSTEM. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, LAG, STOP, PRIORITY, PATH, SCRIPT-OPTS & AID APPLY TO ALL DETACHED subprocesses, VIA 1 pipe EACH.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER.    USB→3.5mm SOUND CARDS COST AS LITTLE AS $2 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW "wasapi/" DEVICE (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX), WHICH CAN BE SEEN IN TASK MANAGER. "coreaudio/" IS MACOS. VIRTUALBOX USB SUPPORT ENABLES MANY audio OUTPUTS.
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH WAV, MP3, MP4 & YOUTUBE.

o={ --options  ALL OPTIONAL & MAY BE REMOVED.
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-MUTE-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute.  TOGGLE DOESN'T SWITCH OFF dynaudnorm (FRAME-TIMING ISSUE).
    key_bindings         ='F3',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m. 'F3 F4' FOR 2 KEYS. F1 & F2 MIGHT BE autocomplex & automask. s=SCREENSHOT (NOT SPEED NOR SPECTRUM). C IS CROP, NOT CLOCK.
    clock='{\\fs71\\bord2\\shad1\\an3}%I{\\fs50}:%M{\\fs35}:%S{\\fs25} %p', --REMOVE TO remove clock.  an,%I,%M,%S,%p = ALIGNMENT-NUMPAD,HRS(12),MINS,SECS,P/AM  (DEFAULT an0=an7=TOPLEFT)  BIG:MEDium:Little:tiny, RATIO=SQRT(.5)=.71  FORMATTERS: a A b B c d H I M m p S w x X Y y  b1,i1,u1,s1,be1,fn,c = BOLD,ITALIC,UNDERLINE,STRIKE,BLUREDGE,FONTNAME,COLOR  REQUIRES [vo] TO BE SEEN (NOT RAW MP3).
    -- clock='{\\fs71\\bord2\\shad1\\an3}%I{\\fs50\\cFF4C00}:%M{\\fs35\\cFF}:%S{\\fs25\\c0\\bord0} %p', --UNCOMMENT FOR COLORED clock. "WHITE:BLUE:Red black", LIKE A TRIBAR FLAG.  \cFF4C00 IS A BRIGHTER SHADE OF BLUE (ORDERED BGR, AS HEX NUMERAL).  AN UNUSED BIG SCREEN TV CAN BE A BIG clock WITH BACKGROUND VIDEO.
    
    filterchain='anull,'  --CAN REPLACE anull WITH EXTRA FILTERS (highpass aresample vibrato ...).
              ..'dynaudnorm=500:5:1:100', --f:g:p:m DEFAULT=500:31:.95:10:0:1:0  DYNAMIC AUDIO NORMALIZER. ALL subprocesses USE THIS NORMALIZER. GRAPH COMMENTARY HAS MORE DETAILS.
    mpv       ={'mpv',   --REMOVE THESE 3 LINES FOR clock ONLY OVERRIDE (+filterchain). LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE. THE FIRST SUCCESSFUL COMMAND WILL BE USED FOR ALL subprocesses.  INSTEAD OF COPY/PASTING THE clock INTO OTHER SCRIPT/S, THIS SCRIPT SYNCS IT TO SYSTEM TICK.
                './mpv', --SMPLAYER LINUX & MACOS.
                '/Applications/mpv.app/Contents/MacOS/mpv'},  --MACOS mpv.app
    
    -- extra_devices_index_list={2},--TRY {2,3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. 1=auto WHICH MAY DOUBLE-OVERLAP AUDIO TO PRIMARY DEVICE. 3=VIRTUALBOX USB STEREO. EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS.     EACH MPV USES APPROX 1% CPU, + 40MB RAM.
    -- mutelr='muter',           --DEFAULT='mutel'  UNCOMMENT TO SWITCH PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN PERFECT SYNC TO video. HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    
    max_random_percent=10,   --DEFAULT=0     MAX random % DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND. EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.
    max_speed_ratio   =1.15, --DEFAULT=1.25  speed IS BOUNDED BY [SPEED/max,SPEED*max], WITH SPEED FROM CONTROLLER.  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    
    start        = .3, --DEFAULT=.3  SECONDS  APPROX:  .3=SSD  2=HDD  INITIAL HEADSTART OF subprocesses, EXCEPT ON YOUTUBE. EACH mpv TAKES TIME TO LOAD, & FOR MP4 THEY AREN'T LAUNCHED UNTIL AFTER INITIAL seeking (WHICH WORKS FINE ON SSD).
    seek_limit   =  1, --DEFAULT=1   SECONDS  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    resync_delay = 30, --DEFAULT=60  SECONDS  os_sync RESYNC WITH THIS DELAY.   mp.get_time() & os.clock() MAY BE BASED ON CPU TIME, WHICH GOES OFF WITH RANDOM LAG.
    os_sync_delay=.01, --DEFAULT=.01 SECONDS  ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    auto_delay   =.25, --DEFAULT=.5  SECONDS  subprocess RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    time_needed  =  5, --DEFAULT=5   SECONDS  NO RANDOMIZATION WITHIN 5s OF end-file (SYNCED FINISH). ALSO TIME TO STABILIZE SAMPLE COUNT.
    timeout      = 10, --DEFAULT=10  SECONDS  subprocesses ALL quit IF CONTROLLER HARD BREAKS FOR THIS LONG. 
    
    samplerate=44100, --DEFAULT=44100 Hz  48000 Hz ALSO POPULAR.  HARDWARE samplerate UNKNOWN @file-loaded.
    -- meta_osd=true, --DISPLAY astats METADATA (audio STATISTICS). IRONICALLY astats DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    
    options='' --'opt1 val1 opt2 val2 '... FREE FORM.
        -- ..' audio-pitch-correction no '              --UNCOMMENT FOR CHIPMUNK MODE. DEFAULT=yes APPLIES scaletempo2(?) FILTER.
        -- ..' osd-color 1/.5  osd-border-color 0/.5 '  --UNCOMMENT FOR TRANSPARENT clock. DEFAULTS 1/1 0/1. y/a = brightness/alpha (OPAQUENESS).  A TRANSPARENT clock CAN BE TWICE AS BIG. RED=1/0/0/1
        ..' audio-delay 0  image-display-duration inf ' --NON-0 delay COULD BE SMPLAYER ACCIDENTAL +- KEYTAP. aspeed GIVES JPEG A clock.
}
for key,val in pairs({toggle_on_double_mute=0,key_bindings='',filterchain='anull',mpv={},extra_devices_index_list={},mutelr='mutel',start=.3,max_random_percent=0,max_speed_ratio=1.25,seek_limit=1,resync_delay=60,os_sync_delay=.01,auto_delay=.5,time_needed=5,timeout=10,samplerate=44100,options=''})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('[^ ]+') --GLOBAL MATCH ITERATOR. [^ ] MEANS COMPLEMENT SET TO " ". + MEANS LONGEST (FULL WORD MATCHES). '%g+' (GLOBAL) IS INCOMPATIBLE WITH mpv.app WHICH USES AN OLD LUA VERSION. THE SYMBOL FOR EXCLUDING SPACES, TABS & NEWLINES CAME IN A NEWER VERSION.
while   val do mp.set_property(opt,val)   --('','') → NULL-SET
    opt,val = o.options(),o.options() end --nil @END

utils,label,script_opts = require 'mp.utils',mp.get_script_name(),mp.get_property_native('script-opts')  --subprocesses GET pid FROM script-opts
if     script_opts.mutel then mutelr,o.clock = 'mutel',false  --mutelr IS A GRAPH INSERT. NO clock FOR subprocesses.
elseif script_opts.muter then mutelr,o.clock = 'muter',false
else is_controller,mutelr,o.auto_delay,script_opts.pid = true,o.mutelr,.5,utils.getpid()..''  --CONTROLLER. ..'' CONVERTS→string  script_opts MUST BE STRINGS.
    mp.set_property_native('script-opts',script_opts)

    for _,command in pairs(o.mpv) do if utils.subprocess({args={command}}).error~='init' then mpv=command  --error=init IF INCORRECT COMMAND. OTHERWISE error USUALLY killed.
            break end end 
    devices,device_list = {mp.get_property('audio-device')},mp.get_property_native('audio-device-list')  --devices IS LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device). device_list IS COMPLETE LIST.  
    for _,index in pairs(o.extra_devices_index_list) do is_present,device = false,device_list[index].name
        for _,find in pairs(devices) do if device==find then is_present=true    --SEARCH FOR DUPLICATES BEFORE INSERTION. SIMILAR TO main.lua
            break end end
        if not is_present then table.insert(devices,device) end end end

lavfi=('aformat=s16:%d:stereo,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:1')
    :format(o.samplerate,               o.filterchain,             mutelr)
 
----lavfi        =[graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  %s,%d = string,DECIMAL-INTEGERS  EACH LUA SCRIPT MAY CONTROL A GRAPH, LIKE HOW A CELL CONTROLS DNA. aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT.     CHANGING GRAPH NEEDS A FEW HRS FOR TESTING.
----aformat      =sample_fmts:sample_rates:channel_layouts  IS THE START.  u8,s16,s64:Hz:stereo,mono  GIVES astats CONSTANT samplerate. CONVERTS MONO & SURROUND SOUND TO stereo FOR astats RELIABILITY. ITS OUTPUT MUST BE DETERMINISTIC OVER 10 HRS (UNLIKE OTHER FILTERS).  s16=SGN+15BIT (-32k→32k), CD. u8 CAUSES HISSING.  
----astats       =length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. USES APPROX 0% OF CPU. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC. 
----anull         PLACEHOLDER.
----dynaudnorm   =f:g:p:m →s64  DEFAULTS 500:31:.95:10  FRAME(MILLISECONDS):GAUSSIAN_WIN_SIZE(ODD INTEGER):PEAK_TARGET[0,1]:MAX_GAIN[1,100]   DYNAMIC AUDIO NORMALIZER. INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). A 2 STAGE PROCESS MIGHT BE IDEAL (SMALL g → BIG g).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. s64 SHOWS UP AS [wasapi] float IN MPV LOG.
----asplit        [ao]→[NOmutelr][mutelr]=[0][1]
----stereotools  =...:mutel:muter (BOOLS) MUTES EITHER SIDE. softclip OPTION MAY CAUSE A BUG IN LINUX .AppImage. MAY NOT BE DETERMINISTIC OVER 10 HRS?
----astreamselect=inputs:map  IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH (CAN VERIFY BY TOGGLING NORMALIZER IN SMPLAYER). SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY REMOTE CONTROL (af-command 0 OR 1). ON=1 BY DEFAULT.


if not o.mpv[1] then lavfi=o.filterchain end  --OVERRIDE (NO subprocesses).
mp.command(('no-osd af append @%s:lavfi=[%s]'):format(label,lavfi)) --MACOS/LINUX: CHECK IF DELAY IS NEEED.

function start_file()  --AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart
    path=mp.get_property('path')
    if is_controller and not utils.file_info(path) then subprocesses() end  --YOUTUBE LAUNCHES INSTANTLY.
end 
mp.register_event('start-file',start_file) 

map,timers = 1,{}  --map IS GRAPH SWITCH. ONLY CHANGES FOR CONTROLLER. 
function playback_restart(arg) --playback-restart RESETS GRAPH. astats RE-INSERTS. RESET SAMPLE COUNT.
    if not path then return    --HAVEN'T STARTED YET.
    elseif arg.event and is_controller then subprocesses() end  --MP4 LAUNCH WAITS FOR INITIAL seeking TO FINISH. 
    mp.command(('af-command %s map %d'):format(label,map))
    initial_time_pos=nil
    for timeout in ('0 2 4 8 16'):gmatch('[^ ]+') do mp.add_timeout(timeout,os_sync) end --RESYNC ON TIMEOUTS, DUE TO HDD LAG. GEOMETRIC/EXPONENTIAL.
end  
mp.register_event  ('playback-restart'         ,playback_restart)
mp.observe_property('frame-drop-count','number',playback_restart) --BUGFIX FOR EXCESSIVE LAG: RESET SAMPLE COUNT.

directory=utils.split_path(mp.get_property('scripts')) --SCRIPT FOLDER.
directory=mp.command_native({'expand-path',directory}) --command_native EXPANDS ~
txtpath=utils.join_path(directory,('%s-PID%s.txt'):format(label,script_opts.pid)) 
mp.register_event('shutdown',function() os.remove(txtpath) end)

function on_toggle(mute)  --CONTROLLER ONLY. INSTA-TOGGLE (SWITCH), NOT PROPER FULL toggle. (PERHAPS A DOUBLE-TAP key_bind COULD TRIGGER FULL TOGGLE.)  subprocesses MAINTAIN SYNC WHEN OFF.
    if not path or not is_controller then return   --NOT STARTED YET.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.
        return end
    
    OFF,map = not OFF,1-map   -- 1,0 = ON,OFF 
    mp.command(('af-command %s map %d'):format(label,map))  --UNLIKE automask, PAUSED DOESN'T REQUIRE frame-step.
    clock_update()  --INSTANT clock_update, OR IT WAITS TO SYNC.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_aspeed_'..key, on_toggle)  end 
timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end ) --mute timer. VALID EVEN FOR 0 TIME (DISABLED).
timers.mute.oneshot=true  

clock=mp.create_osd_overlay('ass-events')       --ass-events IS THE ONLY VALID OPTION.   
function clock_update()                         
    if OFF or not o.clock then clock:remove()   --OFF SWITCH.
        return end
    timers.osd:resume() 
    clock.data=os.date(o.clock):gsub('}0','} ') --REMOVE LEADING 0 AFTER "}" STYLE CODE.
    clock:update()
end
timers.osd=mp.add_periodic_timer(1, clock_update)  --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS IRRELEVANT TO audio SYNC.

function os_sync()  --RUN 10ms LOOP UNTIL clock TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC time-pos WITH subprocesses. 
    if not time1 then time1=os.time()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH)
        timers.os_sync:resume() 
        return end
    time2=os.time()  --INTEGER SECONDS FROM 1970.
    if time2<=time1 then return end --NO TICK YET, WAIT.
    
    time1,sync_time = nil,time2-mp.get_time()   --time1 ACTS AS A SWITCH. sync_time IS THE CONSTANT TO ADD TO MPVTIME TO GET TIMEFROM1970 TO WITHIN 10ms.  mp.get_time()=os.clock()+CONSTANT (GIVE SAME NET RESULT).
    timers.os_sync:kill()
    timers.osd    :kill()   --SYNC clock TICK TO SYSTEM. 
    clock_update() 
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)
for _,timer in pairs(timers) do timer:kill() end    --kill timers. THEY CARRY OVER IN MPV PLAYLIST.
timers.resync =mp.add_periodic_timer(o. resync_delay,os_sync)

function subprocesses()    --CONTROLLER ONLY. 
    priority,time_pos,start = mp.get_property('priority'),mp.get_property_number('time-pos'),mp.get_property('start')  --start=string, ~number. 
    if not mpv then return --OVERRIDE, OR ALREADY LAUNCHED.
    elseif  priority then priority='--priority='..priority --WINDOWS.  PROPAGATING CHANGE IN priority VIA TASK MANAGER NOT SUPPORTED. 
    else                  priority='--no-vid' end    --NULL-OP: LINUX.
    if  time_pos then start   ='--start='..math.floor((time_pos+o.start)*100)/100  --FILE: LIMIT PRECISION TO 10ms.
    elseif start then start   ='--start='..start --YOUTUBE.
    else              start   ='--no-vid' end    --NULL-OP: YOUTUBE & NO --start.
    
    io.open(txtpath,'w')  --w=WRITE MODE. subprocesses quit IF THIS FILE DOESN'T EXIST. BUT property_handler SHOULD WAIT FOR path OR THERE'S A CASCADE @INITIALIZATION. 
    script,script_opts = utils.join_path(directory,label..'.lua'),mp.get_property('script-opts')  --script-opts HOOK ytdl. COULD SWITCH .lua TO .js FOR JAVASCRIPT. 
    for N,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('[^ ]+') do if not (N==1 and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY device CHANNEL.
            then utils.subprocess({detach=true,playback_only=false,capture_stdout=false,capture_stderr=false,  --EXTRA FLAGS FOR LINUX.  COMMAND TOO LONG IN TASK MANAGER. TO SHORTEN IT, TARGETED ECHOES ARE MOST ELEGANT, BUT THAT'S A DIFFERENT DESIGN.    run & subprocess_detached ALSO CREATE DETACHED SUBPROCESSES, BUT THEY AREN'T FULLY DETACHED & CAN CAUSE SOME BUG INSIDE SMPLAYER.     
                    args={mpv,start,priority,'--no-vid','--keep-open=yes','--msg-level=all=no','--ytdl-format=bestaudio','--script='..script,path,('--script-opts=%s=1,%s'):format(mutelr,script_opts),'--audio-device='..device}}) end end end  --msg-level=all=no OR ELSE PARENT LOG FILLS UP. keep-open FOR seek NEAR end-file. bestaudio TO STOP ytdl RE-DOWNLOADING VIDEO STREAM.  SOME options STAY CONSTANT. AN ALTERNATIVE DESIGN MAY START IN --idle & loadfile IN property_handler.
    mpv=nil
end

function property_handler(property,meta)  --CONTROLLER WRITES TO txtpath, & subprocesses READ FROM IT.  THIS FUNCTION SHOULD ONLY EVER BE PCALLED FOR RELIABILITY. BY TRIAL & ERROR SOLVES SIMULTANEOUS write & remove @SUDDEN STOP.
    samples_time,os_time,time_pos = nil,os.time(),mp.get_property_number('time-pos')  --os_time=TIMEFROM1970 (SECONDS)
    if     not path     then return     --NOT STARTED YET.
    elseif not time_pos then time_pos=0 --time_pos MUST BE WELL-DEFINED DURING YOUTUBE LOAD (CAN CHECK txtfile). 
    elseif meta         then samples_time=meta['lavfi.astats.Overall.Number_of_samples'] end  --OFTEN nil.
    if samples_time     then samples_time=samples_time/o.samplerate end  --TIME=sample#/samplerate  
    
    if sync_time then os_time=sync_time+mp.get_time()      --PRECISE TO 10ms. BEFORE SYNC, pause OVERRIDE STILL APPLIES.
        if samples_time and samples_time>o.time_needed then if not initial_time_pos then initial_time_pos=time_pos-samples_time end  --initial_time_pos=initial_time_pos_relative_to_samples_time  INITIALIZE AFTER CHECKING samples_time. THIS # STAYS THE SAME FOR THE NEXT 10 HOURS.  LIKE HOW YOGHURT GOES OFF, 20 HRS LATER THE SPEAKERS MAY BE OFF (astats ISSUE).
            time_pos=samples_time+initial_time_pos end end --NEW METRIC WHOSE CHANGE IS BASED ON astats. IT'S A TIME METRIC-SWITCH TRICK. REMOVE IT TO PROVE MPV CAN'T SYNC WITHOUT astats, EVEN WITH autosync ETC.  time-pos, playback-time & audio-pts WORK WELL OVER 1 MINUTE, BUT NOT 1 HOUR.
    
    if is_controller then if o.meta_osd then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t')) end   --TAB EACH STAT (TOO MANY LINES), FOR osd.
        if property=='mute' then on_toggle(property) end  --FOR DOUBLE mute TOGGLE.
        
        volume,speed,aid = mp.get_property_number('volume'),mp.get_property_number('speed'),mp.get_property_number('current-tracks/audio/id')  --id=nil DURING YOUTUBE LOAD. volume RANGE [0,100]. get_property_number REMOVES TRAILING ZEROS. 
        if OFF or mp.get_property_bool('mute') then volume=0  end --OFF & mute.
        if not aid or mp.get_property_bool('pause') or mp.get_property_bool('seeking') then speed=0
             timers.auto:resume()    --IDLER (DON'T timeout).
        else timers.auto:kill() end
        if not aid then aid=1   end  --DURING YOUTUBE LOAD.
        
        txtfile=io.open(txtpath,'w')  --MACOS-11 REQUIRES txtfile BE WELL-DEFINED. WINDOWS & LINUX DON'T. IT DEPENDS ON THE EXACT LUA VERSION, HOW io WORKS.
        txtfile:write(('%s\n%d\n%d\n%s\n%s\n%s'):format(mp.get_property('path'),aid,volume,speed,os_time,time_pos))  --CONTROLLER REPORT. SECURITY PRECAUTION: NO property NAMES, OR ELSE A HACKER CAN DO AN ARBITRARY set (EXAMPLE: YOUTUBE HOOK), SIMILAR TO PIPING TO A SOCKET. MORE LINES MIGHT REQUIRE SECURITY OVERRIDES.  USE id NOT aid. aid WON'T ALWAYS WORK DUE TO lavfi-complex (LOCK BUG). 
        txtfile:flush() --EITHER flush() OR close(). 
        return end      --CONTROLLER ENDS HERE.  subprocesses BELOW.
    
    pcode,lines = pcall(io.lines,txtpath)    --lines ITERATOR RETURNS ERROR OR nil OR 6 LINES.  THIS IS A pcall INSIDE ANOTHER pcall.
    if not pcode then mp.command('quit') end --EXIT. NO lines MEANS CONTROLLER HAS STOPPED, AFTER samples_time IS COMPUTABLE. 'quit' NOT 'stop' BECAUSE SOME BUILDS idle. (LINUX .AppImage) 
    
    txt_path=lines()
    if not txt_path then return  --txtfile MAY BE BLANK (nil).
    elseif txt_path~=mp.get_property('path') then mp.commandv('loadfile',txt_path) end  --FOR MPV PLAYLISTS. commandv FOR FILENAMES. CAN INSERT FLAGS, TOO (LIKE --start).
    mp.set_property('aid'   ,lines())
    mp.set_property('volume',lines())
    
    txt_speed,txt_time,txt_pos = lines()+0,lines()+0,lines()+0  --+0 CONVERTS→number
    mp.set_property_bool('pause',txt_speed==0)
    if os_time-txt_time>o.timeout then mp.command('quit')  --EXIT - CONTROLLER HARD BREAKED LONG AGO.
    elseif not samples_time then return end  --auto TIMER ENDS HERE. IT SETS PROPERTIES OTHER THAN speed.
    
    time_gained=time_pos-txt_pos-(os_time-txt_time) --SUBTRACT time_from_write FROM DIFFERENCE BTWN POSITIONS.
    if o.seek_limit and math.abs(time_gained)>o.seek_limit then mp.command(('seek %s exact'):format(-time_gained)) --INSTANT SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED - LIKE SCRATCHING A RECORD).
        return end   
    if not randomseed then randomseed=os_time  
        math.randomseed(randomseed) end  --INITIALIZE random # GENERATOR. WITHOUT randomseed THE NUMBERS ARE EASY TO PREDICT.
    
    speed=txt_speed-time_gained/.5  --time_gained→0 OVER NEXT .5 SECONDS (astats UPDATE TIME).
    if mp.get_property_number('time-remaining')>o.time_needed then speed=speed*(1+math.random(-o.max_random_percent,o.max_random_percent)/100) end  --DON'T RANDOMIZE NEAR end-file. 
    speed=math.max( txt_speed/o.max_speed_ratio , math.min( txt_speed*o.max_speed_ratio , speed ) )  --speed LIMIT RELATIVE TO CONTROLLER.  LUA DOESN'T SUPPORT math.clip
    mp.set_property_number('speed',speed)
end
mp.observe_property('af-metadata/'..label,'native',function(property,meta) pcall(property_handler,property,meta) end) --TRIGGERS EVERY HALF A SECOND, & INSTANTLY ON seek.
if is_controller then for property in ('path current-tracks/audio/id volume mute pause seeking'):gmatch('[^ ]+')      --INSTANT write TO txtfile.
    do mp.observe_property(      property,'native',function(property)      pcall(property_handler,property)      end) end end  --TRIGGERS INSTANTLY.
timers.auto=mp.add_periodic_timer(    o.auto_delay,function()              pcall(property_handler)               end) --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.36.0 (INCL. v3) v0.35.0 (.7z) v0.35.1 (.flatpak)  TESTED.
----FFmpeg v5.1.2(MACOS) v4.3.2(LINUX .AppImage) v6.0(LINUX) TESTED.
----WIN10 MACOS-11 LINUX-DEBIAN-MATE  (ALL 64-BIT)           TESTED. ALL SCRIPTS PASS snap+ytdl INSPECTION.  
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. 

----"autospeed.lua" IS A DIFFERENT SCRIPT FOR video speed, NOT audio. "autotempo.lua" MIGHT BE A BETTER NAME (I DIDN'T THINK OF IT).
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MEANING "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY MAY BE A SECURITY THREAT. A FUTURE MPV VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET. I HAVE A PIPE VERSION OF THIS SCRIPT BUT PREFER txtfile.,  txtfile METHOD MAY BE MORE LIKELY TO WORK, & SAFER, ON ANDROID.
----audio-params/samplerate current-tracks/audio/demux-samplerate PROPERTIES GIVE samplerate, BUT BETTER TO SET IT IN GRAPH.

----ALTERNATIVE FILTERS:
----acompressor      SMPLAYER DEFAULT NORMALIZER.
----firequalizer OLD SMPLAYER DEFAULT NORMALIZER.
----loudnorm=I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.
----volume  =volume:...:eval  (DEFAULT 1:once)  TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.
----atrim   =start (SECONDS) TO MATCH lavfi-complex. UNNECESSARY.
----asetpts =expr            TO MATCH lavfi-complex.
----apad      ALTERNATIVE TO keep-open & loop=inf, FOR seek NEAR end-file.



