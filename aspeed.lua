----ADD CLOCK & TITLE TO video & JPEG, WITH DOUBLE-mute TOGGLE, + audio AUTO speed SCRIPT. clock TICKS WITH SYSTEM. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON PRIMARY RIGHT). ADDS AMBIENCE WITH RANDOMIZATION. PAUSE, STOP, PLAY, SEEK, MUTE & VOLUME APPLY TO ALL INSTANCES, AFTER THEY CHECK THE TEMPORARY txtfile. ALL audio PLAYERS ADJUST TO video LAG, BUT ARE FULLY DETACHED.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER.    USB→3.5mm SOUND CARDS COST AS LITTLE AS $2 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW "wasapi/" DEVICE (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX), WHICH CAN BE SEEN IN TASK MANAGER. "coreaudio/" IS MACOS. VIRTUALBOX USB SUPPORT ENABLES MANY audio OUTPUTS INSIDE VM.
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.     YOUTUBE (ytdl) UNTESTED. CHANGE aid UNTESTED (MAY NEED TO STOP & PLAY IN SMPLAYER).

options={ --ALL OPTIONAL & MAY BE REMOVED.
    title_duration=5, --DEFAULT=5 SECONDS.  AN audio SCRIPT MAY CONTROL title & clock, UNLESS THEY ARE FANCY & DANCING AROUND (video).
    title='{\\fs71\\bord3\\shad1}', --DEFAULT='' (NO clock)  \\,fs,bord,shad = \,FONTSIZE,BORDER,SHADOW (PIXELS)  REMOVE TO REMOVE title. THIS STYLE CODE SETS THE osd. NO-BOLD MEANS BIGGER FONT.   b1=BOLD i1=ITALIC u1=UNDERLINE s1=STRIKE be1=BLUREDGE fn=FONTNAME c=COLOR
    clock='{\\fs71\\bord2\\shad1\\an3}%I{\\fs50}:%M{\\fs35}:%S{\\fs25} %p', --DEFAULT='' (NO clock)  an,%I,%M,%S,%p = ALIGNMENT-NUMPAD,HRS(12),MINS,SECS,P/AM  (DEFAULT an0=an7=TOPLEFT)  REMOVE TO remove clock.  BIG:MEDIUM:LITTLE:tiny, RATIO=SQRT(.5)=.71     FORMATTERS: a A b B c d H I M m p S w x X Y y  REQUIRES [vo] TO BE SEEN (NOT RAW MP3).  AN UNUSED BIG SCREEN TV CAN BE A BIG clock WITH BACKGROUND video. 
    
    FILTERS='dynaudnorm=p=1:m=100:c=1'  --DYNAMIC AUDIO NORMALIZER DEFAULTS 0.95:10:0 (PEAK-TARGET:MAX-GAIN:CORRECTION-DC-BOOL). ALL INSTANCES USE THIS NORMALIZER. ALTERNATIVES INCLUDE loudnorm & acompressor.
         ..',anull', --CAN REPLACE anull WITH EXTRA FILTERS (E.G. vibrato). SIMILAR SETUP TO automask.
    -- title_clock_only=true,   --& FILTERS. OVERRIDE: NO audio INSTANCES. HOWEVER FILTERS STILL ACTIVE.   THIS option MEANS THE clock DOESN'T HAVE TO BE COPY/PASTED INTO OTHER SCRIPT/S (THIS SCRIPT CAN CONTROL IT).
    
    -- extra_devices_index_list={2},--EXTRA DEVICES. TRY {2,3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. 1=auto WHICH MAY DOUBLE-OVERLAP audio TO PRIMARY DEVICE. 3=VIRTUALBOX USB STEREO. EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS.     EACH MPV USES APPROX 1% CPU, + 40MB RAM.
    -- mutelr='muter',           --DEFAULT='mutel'  UNCOMMENT TO SWITCH PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN PERFECT SYNC TO video. HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    
    start=.7, --DEFAULT=.7 SECONDS  APPROX: .5=SSD .7=AUTOCOMPLEX 1=VIRTUALBOX 2=HDD.  INITIAL HEADSTART OF audio INSTANCES. EACH mpv TAKES TIME TO LOAD, & THEY AREN'T LAUNCHED UNTIL AFTER playback_start (WHICH WORKS FINE ON SSD).
    DELAY=.5, --DEFAULT=.5 SECONDS. INITIAL MUTE OF CONTROLLER volume (SUPPORTS FORMULAIC TIMELINE SWITCH). <start BECAUSE GRAPH INSERTION TAKES .2s. NOT STRICTLY "adelay" NOR "audio-delay", HENCE "DELAY" (NOT CHANGING TIMESTAMPS).   INSERTING SILENCE @START SEEMS TOO COMPLICATED (TIMESTAMP ISSUE), SO INITIAL HALF-SECOND audio IS LOST.
    
    max_random_percent=10, --DEFAULT=0. MAX random % DEVIATION FROM PROPER speed. speed UPDATES EVERY HALF A SECOND. E.G. 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.
    max_percent       =20, --DEFAULT=20. SPEED NEVER CHANGES BY MORE. E.G. speed BOUNDED WITHIN [0.8,1.2].
    
    seek_limit   =  2, --DEFAULT=2   SECONDS. SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.)
    resync_delay = 30, --DEFAULT=30  SECONDS. RANGE [1,60]. RESYNC WITH THIS DELAY, COUNTING FROM 0s ON clock.     mp.get_time() LAGS MAYBE 100ms OVER A MINUTE.   mp.get_time() MAY BE BASED ON os.clock(), WHICH IS BASED ON CPU TIME.
    os_sync_delay=.01, --DEFAULT=.01 SECONDS. ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    time_needed  =  2, --DEFAULT=2   SECONDS. NO RANDOMIZATION WITHIN 5 SECS OF file-loaded & end-file (STRONG FINISH). ALSO WAITS THIS LONG FOR astats TO STABILIZE SAMPLE COUNT.
    timeout      = 10, --DEFAULT=10  SECONDS. audio INSTANCES ALL shutdown IF CONTROLLER HARD BREAKS FOR THIS LONG.
    -- meta_osd=true,  --DISPLAY astats METADATA (audio STATISTICS). IRONICALLY astats DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    
    key_bindings         ='F3', --DEFAULT='' (NO TOGGLE). CASE SENSITIVE. m IS MUTE SO CAN DOUBLE-PRESS m. key_bindings DON'T WORK INSIDE SMPLAYER. 'F3 F4' FOR 2 KEYS. F1 & F2 MIGHT BE autocomplex & automask. s=SCREENSHOT (NOT SPEED NOR SPECTRUM). C IS CROP, NOT CLOCK.
    toggle_on_double_mute=.5,   --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute.
    
    config={
            'audio-delay 0',    --OVERRIDE SMPLAYER (NON-0 COULD BE ACCIDENT).
            'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',   --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
            'image-display-duration inf', --STOPS IMAGES FROM SNAPPING MPV.
            'hwdec auto-copy','vd-lavc-threads 0',    --IMPROVED PERFORMANCE FOR LINUX .AppImage.  hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
            -- 'audio-pitch-correction no' --DEFAULT=yes  no=CHIPMUNK MODE, DISABLES scaletempo2(?) FILTER. SCALING TEMPO IS FUNDAMENTAL TO RANDOMIZATION.
            -- 'osd-color 1/.5','osd-border-color 0/.5',  --DEFAULTS 1/1,0/1. OPTIONAL: FOR clock. y/a = brightness/alpha (a=OPAQUENESS). A TRANSPARENT clock CAN BE TWICE AS BIG.
           
            'osd-level 0',  --RETURNS osd-level AFTER BLOCKING INTERFERENCE WITH title (DUE TO SMPLAYER).
           },
}
o,utils,osd_level = options,require 'mp.utils',mp.get_property('osd-level') --ABBREV.
label,directory = mp.get_script_name(),utils.split_path(mp.get_property('scripts'))   --label=aspeed     FROM smplayer.exe FOLDER, directory=".". IN LINUX IT COULD BE "/home/user/Desktop/SMPLAYER".   mp.get_script_directory() HAS BUG.
directory=mp.command_native({'expand-path',directory})   --BUGFIX FOR "~" LUA io (INPUT OUTPUT). command_native RETURNS.

for key,val in pairs({title_duration=5,title='',clock='',FILTERS='anull',extra_devices_index_list={},mutelr='mutel',start=.7,DELAY=.5,max_random_percent=0,seek_limit=2,resync_delay=30,os_sync_delay=.01,time_needed=2,timeout=10,key_bindings='',toggle_on_double_mute=0,config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 
for _,option in pairs(o.config) do mp.command('no-osd set '..option) end 

mpv,devices = 'mpv',{mp.get_property('audio-device')} --mpv MAY BE ADDRESSED AS EITHER "mpv" OR "./mpv" IN EVERY SYSTEM. LINUX snap ALLOWS IT TO RUN ITSELF.  devices IS LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device). 
mutelr,pid = mp.get_opt('mutelr'),mp.get_opt('pid')   --THESE script-opts FOR audio INSTANCES.

if not (mutelr and pid) then is_controller,pid,mutelr = true,utils.getpid(),o.mutelr  --CONTROLLER MUTES LEFT.
    if utils.subprocess({args={mpv}}).error:upper()=='INIT' then mpv='./mpv' end --error=init FOR INCORRECT COMMAND.  EITHER mpv (WINDOWS & LINUX) OR ./mpv (MACOS & LINUX .AppImage)    OTHERWISE error=killed (NULL CMD). CAN SCAN OVER ALL POSSIBLE COMMANDS.  MACOS working-directory=/Applications/SMPlayer.app/Contents/MacOS
    device_list=mp.get_property_native('audio-device-list') --device_list IS COMPLETE LIST. CHECK EVERY ENTRY FROM OPTION.
    for _,index in pairs(o.extra_devices_index_list) do device=device_list[index].name
        if not table.concat(devices):find(device,1,true) then table.insert(devices,device) end end  --1,true=EXACT FROM 1    concat find DOES SEARCH FOR DUPLICATES, BEFORE INSERTION.
else o.DELAY=0   --ONLY CONTROLLER DELAYS volume.
     mp.command('set loop inf') end --STOP audio INSTANCES FROM EXITING, WITHOUT apad. USER MAY BACKWARDS seek NEAR end-file. 

lavfi=('stereotools,aformat=s16:44100,astats=.5:1,%s,volume=gte(t-startt\\,%s):eval=frame,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:1')
    :format(o.FILTERS,o.DELAY,mutelr)
 
----lavfi        =[graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTER LIST. EACH .LUA SCRIPT MAY CONTROL A GRAPH, LIKE HOW A CELL CONTROLS DNA. aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT.     CHANGING GRAPH NEEDS A FEW HRS FOR TESTING.
----dynaudnorm   =...:p:m:...:c  →s64  DEFAULTS .95:10:0:0 (PEAK TARGET [0,1] : MAX GAIN [1,100] : CORRECTION (DC,0Hz)) INSERTS AFTER astats BECAUSE IT SLIGHTLY CHANGES SAMPLE COUNT OVER 10 HOURS (NORMALIZER MAY NOT BE DETERMINISTIC).  ALTERNATIVE NORMALIZERS (loudnorm & acompressor) AREN'T AS GOOD IN MY OPINION.
----anull         PLACEHOLDER
----stereotools  =...:mutel:muter (BOOLS) CONVERTS MONO & SURROUND SOUND TO STEREO, & MUTES EITHER SIDE. INSERTS BEFORE astats WHICH NEEDS stereo FOR RELIABILITY, & BEFORE aformat BECAUSE IT'S BETTER AT CONVERSION→stereo. softclip OPTION MAY CAUSE A BUG IN LINUX .AppImage. 
----aformat      =sample_fmts  (u8 s16 s64 ETC)  →44.1 kHz BEFORE astats, IRRESPECTIVE OF lavfi-complex. ITS OUTPUT MUST BE DETERMINISTIC OVER 10 HRS.  s16=SGN+15BIT (-32k→32k). u8 CAUSES HISSING.   OTHERWISE MUST CHECK audio-params/samplerate OR current-tracks/audio/demux-samplerate      
----astats       =length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. USES APPROX 0% OF CPU. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC. MPV autosync WON'T WORK (MAYBE A FUTURE VERSION, BUT CURRENTLY INCOMPATIBLE).
----volume       =volume:...:eval  (DEFAULT 1:once)  TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.
----asplit        [ao]→[2CHANNELS][1CHANNEL]  
----astreamselect=inputs:map  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". ANY ATTEMPT TO DOUBLE CHANGE GRAPHS OR DO A FULL TOGGLE CAUSES CONTROLLER GLITCH (CAN VERIFY BY TOGGLING NORMALIZER IN SMPLAYER). SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY REMOTE CONTROL (af-command 0 OR 1). ON=1 BY DEFAULT.


if o.title_clock_only then lavfi=o.FILTERS end  --OVERRIDE: o.FILTERS ONLY (& clock).
mp.command(('no-osd af append @%s:lavfi=[%s]'):format(label,lavfi))     --LINUX snap MAY REQUIRE THIS BE DELAYED TO playback_start DUE TO INTERFERENCE FROM OTHER SCRIPTS. IT DEPENDS ON audio SPLIT TIMING (autocomplex).

timers,txtpath = {},utils.join_path(directory,('%s-PID%d.txt'):format(label,pid))  --SETTING UP A PIPE INSTEAD OF txtfile COULD GIVE INSTANT RESPONSE, BUT COULD ALSO TRIGGER BUGS WITH OTHER SCRIPTS & SMPLAYER. USING .txt INSTEAD OF PIPE IS LIKE PUTTING PLUMBING THROUGH THE FRONT DOOR.
title,clock = mp.create_osd_overlay('ass-events'),mp.create_osd_overlay('ass-events')   --ass-events IS THE ONLY VALID OPTION, FOR TITLE & clock.

function playback_start(_,seeking)  --ONLY EVER CALLED VIA OBSERVATION.
    if seeking then return end  --WAIT UNTIL seeking IS COMPLETE. SOME SUB-CLIP VIDEOS START WITH OFF INITIAL TIMESTAMP. time-pos=0 @file-loaded BUT time-pos=2 INSTANTY AFTER INITIAL seek.
    mp.unobserve_property(playback_start) --BELOW RUNS ONLY ONCE (BEFORE TOGGLING).
    
    timers.auto:resume()    --THIS & astats MAY TRIGGER set_speed.
    os_sync()
    mp.add_timeout(2, os_sync)   --get_time() (CPU TIME) LOSES TIME IF SIMULTANEOUSLY TOGGLING GRAPHS, & HDD LAG.  RESYNC ON timeout REQUIRED FOR audio INSTANCES TOO.
    mp.add_timeout(4, os_sync)
    mp.add_timeout(8, os_sync)
    if not is_controller then return end    --CONTROLLER ONLY, BELOW.
    
    title.data=o.title..mp.get_property_osd('media-title')   
    title:update()  --DISPLAY title.
    mp.add_timeout(o.title_duration, function() title:remove() end) --remove title ON timeout.
    if OFF==nil then mp.add_timeout(.05, function() mp.command('no-osd set osd-level '..osd_level) end) end   --OFF=nil MEANS NEVER TOGGLED (INITIAL LOAD). RETURN osd-level AFTER 50ms. no-osd.
    
    clock_update()  --DISPLAY clock AFTER playback_start OR ELSE LINUX .AppImage RANDOMLY FAILS. (IN WINDOWS THE clock MAY STUTTER IF IT GOES IN EARLIER.)
    if o.title_clock_only then return end    --LAUNCH audio INSTANCES & txtfile BELOW.
    
    priority,aid = mp.get_property('priority'),mp.get_property_number('current-tracks/audio/id') 
    if not aid then return end   --id IS nil or INTEGER. NO audio: DO NOTHING.
    io.open(txtpath,'w+') --w+ ERASES ALL PRIOR DATA. audio INSTANCES quit IF THIS FILE DOESN'T EXIST.
    
    if priority then priority='--priority='..priority   --WINDOWS. ASSUME PRIORITY DOESN'T CHANGE UNTIL NEXT FILE OR stop.
    else             priority='--speed=1' end           --LINUX (NULL OP: priority NOT SUPPORTED). ALTERNATIVE TO BUILDING args table.
    
    for _,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('%g+') do if not (device==devices[1] and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY RIGHT CHANNEL. IF MPV CAN'T BE FOUND, title & clock ONLY.
            then utils.subprocess({detach=true,playback_only=false,capture_stdout=false,capture_stderr=false,   --FLAGS OPTIONAL BUT MAY BE NEEDED IN SOME LINUX BUILD.  SET CHILD "msg-level=all=no" OR ELSE PARENT LOG FILLS UP.     run & subprocess_detached ALSO CREATE DETACHED SUBPROCESSES, BUT THEY AREN'T FULLY DETACHED & CAN CAUSE A BUG INSIDE SMPLAYER. command_native DIDN'T WORK.
                 args={mpv,'--no-vid','--msg-level=all=no',priority,'--start='..o.start+mp.get_property_number('time-pos'),'--volume='..mp.get_property_number('volume'),'--aid='..aid,('--script-opts=mutelr=%s,pid=%d'):format(mutelr,pid),'--script='..utils.join_path(directory,label..'.lua'),'--audio-device='..device,mp.get_property('path')}}) end end end 
end 
mp.register_event('file-loaded',function() mp.observe_property('seeking','bool',playback_start) end)   --AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart  (restart & START TOGETHER)  ALL audio PLAYERS stop & THEN ALL NEW ONES START IF file CHANGES, OR USER TOGGLES.
mp.register_event('shutdown'   ,function() os.remove(txtpath) end)  --NO RECYCLE BIN. audio INSTANCES quit.
mp.register_event('end-file'   ,function() mp.command('set pause yes') end)  --ALTERNATIVE event=end-file       NO RECYCLE BIN. audio INSTANCES quit.

timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end )  --mute timer. VALID EVEN FOR 0 TIME (DISABLED).
timers.mute.oneshot=true

function on_toggle(mute)   --TOGGLE clock & audio INSTANCES. IDEAL INSTA-TOGGLE DOES ALMOST NOTHING, UNLIKE FULL TOGGLE. (PERHAPS A DOUBLE-TAP key_bind COULD TRIGGER FULL TOGGLE.)
    if mute=='mute' and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.
        return end
    
    OFF,initial_time_pos = not OFF,nil   --OFF=SWITCH MEMORY. FORCE initial_time_pos RESET.
    if not OFF then map=1     --TOGGLE ON 
    else            map=0 end --TOGGLE OFF
    
    mp.observe_property('seeking','bool',function() mp.command(('af-command %s map %d'):format(label,map)) end)  --TRIGGERS INSTANTLY, & ON seeking BECAUSE THAT RESETS GRAPH STATE. UNLIKE automask, DOESN'T REQUIRE frame-step WHEN PAUSED.
    clock_update() 
end
mp.observe_property('mute','bool',on_toggle)
for key in (o.key_bindings):gmatch('%g+') do mp.add_key_binding(key, 'toggle_speed_'..key, on_toggle)  end 

function clock_update() 
    if OFF or not o.clock then clock:remove()   --OFF SWITCH.
        return end
    clock.data=os.date(o.clock):gsub('}0','} ') --REMOVE LEADING 0 AFTER "}" STYLE CODE.
    clock:update()
    timers.osd:resume() 
end
timers.osd=mp.add_periodic_timer(1, clock_update)   --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS IRRELEVANT TO audio SYNC.

function os_sync()  --RUN 10ms LOOP UNTIL clock TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC time-pos WITH OTHER MPV INSTANCES. 
    if not time1 and not mp.get_property_bool('seeking') then time1=os.time()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH)
        timers.os_sync:resume()
        timers. resync:resume() 
    elseif not time1 then return end
    
    time2=os.time()  --THIS IS THE NUMBER OF SECONDS FROM 1970.
    if time1>=time2 then return end --NO TICK YET, WAIT.
    
    timers.os_sync:kill()
    time1,sync_time = nil,time2-mp.get_time()   --time1 ACTS AS A SWITCH. sync_time IS THE CONSTANT TO ADD TO mp TIME TO GET TIMEFROM1970.      mp.get_time()=os.clock()+CONSTANT (GIVE SAME NET RESULT).

    timers.osd:kill()   --SYNC clock TICK TO SYSTEM. 
    clock_update() 
end
timers. resync=mp.add_periodic_timer(o. resync_delay,os_sync)   --(periodic_timer LAGS os.time). clock SHOULD TICK WITH WINDOWS' clock. IT COULD KEEP CHECKING EVERY 10ms, BUT THIS IS A WAY TO CHECK timer ACCURACY.
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)

function set_speed(property)    --property='af-metadata/aspeed' OR nil     THIS IS THE MAIN FUNCTION. CONTROLLER WRITES TO txtfile, OR audio INSTANCES READ FROM IT. BY TRIAL & ERROR SHOULD ONLY EVER BE PCALLED IN CASE OF SUDDEN STOP (SIMULTANEOUS io.remove & io.write).
    paused=mp.get_property_bool('pause')
    if not paused and not property or mp.get_property_bool('seeking') then return end    --DO NOTHING IF PLAYING BUT NOT property. auto timer ONLY EXISTS FOR WHEN paused (NO astats UPDATE).
    
    time_pos,TIMEFROM1970,samples_time = mp.get_property_number('time-pos'),os.time(),mp.get_property_native('af-metadata/'..label)['lavfi.astats.Overall.Number_of_samples']/44100  --samplerate TIME = #SAMPLES/SR         time-pos, playback-time & audio-pts WORK WELL OVER 1 MINUTE, BUT NOT 1 HOUR. autosync WON'T FIX THIS. SO USE astats samples COUNT INSTEAD.  
    if sync_time then TIMEFROM1970=sync_time+mp.get_time()  --PRECISE TO 10ms. BEFORE SYNC, pause OVERRIDE STILL APPLIES.
        if samples_time>o.time_needed then if not initial_time_pos then initial_time_pos=time_pos-samples_time end  --INITIALIZE, WITH ENOUGH DATA. THIS # STAYS THE SAME FOR THE NEXT 10 HOURS.   LIKE HOW YOGHURT GOES OFF, PERHAPS 20 HRS LATER THE SPEAKERS WILL BE OFF (astats ISSUE). DISJOINT STEREO SEEMS LIKE YOGHURT DISJOINT FROM CREAM.         SET "not initial_time_pos"→"true" TO PROVE MPV CAN'T SYNC WITHOUT astats.
            time_pos=initial_time_pos+samples_time end end   --NEW METRIC WHOSE CHANGE IS BASED ON astats. IT'S A TIME METRIC-SWITCH TRICK.
        
    if is_controller then txtfile,volume = io.open(txtpath,'w+'),mp.get_property_number('volume')   --volume IN [0,100]
        if OFF or mp.get_property_bool('mute') then volume=0  end --INSTA-TOGGLE REQUIRES volume=0
        if paused                              then volume=-1 end  --NEGATIVE INSTRUCTS audio INSTANCES TO pause. 
        
        txtfile:write(('%s\n%d\n%d\n%s\n%s'):format(mp.get_property('path'),volume,mp.get_property_number('current-tracks/audio/id'),TIMEFROM1970,time_pos))   --%s,%d = string,DECIMAL-INTEGERS. CONTROLLER REPORT. EITHER flush() OR close().  LINES 1,2,3,4,5 = path,volume,aid,time,POSITION   THE LAST 2 COULD BE COMBINED.
        txtfile:close() --write & close CAN USUALLY BE COMBINED ON 1 LINE, BUT NOT ON SLOW DARWIN (MACOS CATALINA VIRTUALBOX). IT DOESN'T RETURN PROPERLY. 
        
        if o.meta_osd then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t')) end   --TAB EACH STAT (TOO MANY LINES).
        return end   --CONTROLLER ENDS HERE. IRONICALLY IT DOESN'T SET SPEED, BECAUSE EACH audio INSTANCE HAS A MIND OF ITS OWN AND PLAYS FASTER OR SLOWER WHENEVER IT WANTS TO.
    
    pcode,lines = pcall(io.lines,txtpath)  --io.lines RAISES ERROR AFTER FILE REMOVED. lines ITERATOR RETURNS 0 OR 5 LINES.     THIS IS A pcall INSIDE ANOTHER pcall.
    if not pcode then mp.command('quit') end    --EXIT & DELETE. NO txtfile MEANS CONTROLLER HAS STOPPED. 'stop' INCOMPATIBLE WITH LINUX .AppImage ('quit' INSTEAD).
    
    path=lines()  --LINE1=path  
    if not path then return end --SOMETIMES txtfile IS BLANK (@TIME OF write).
    if path~=mp.get_property('path') then mp.command('quit') end    --EXIT. DIFFERENT FILE (E.G. PLAYLIST).
    
    volume=0+lines()    --LINE2=volume    0+ CONVERTS tonumber
    if volume<0 then mp.command('set pause yes')
        return end
    
    mp.command('set pause no'         )
    mp.command('set volume  '..volume ) 
    mp.command('set aid     '..lines()) --LINE3=aid     TIMES GO LAST, AFTER path & volume OVERRIDES. 
    
    if not sync_time then return end    --DON'T CHANGE speed BEFORE INITIAL SYNC. 
    time_from_write=TIMEFROM1970-lines()  --LINE4=TIME OF WRITE (CONTROLLER TIME @MEASUREMENT).
    if time_from_write>o.timeout then mp.command('quit') end    --EXIT. CONTROLLER HARD BREAK - DELETE FILE. THIS IS THE REASON LINES 4 & 5 ARE SEPARATE. ONLY THEIR DIFFERENCE REALLY MATTERS (TIMEFROM1970TO0).
    
    time_gained=time_pos-lines()-time_from_write  --LINE5=POS     SUBTRACT time_from_write FROM DIFFERENCE BTWN POSITIONS.
    if o.seek_limit and math.abs(time_gained)>o.seek_limit then mp.command(('seek %s exact'):format(-time_gained)) --INSTANT SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED - LIKE SCRATCHING A RECORD).
        time_gained=0 end   
    
    if not randomseed then randomseed=TIMEFROM1970  --INITIALIZE random # GENERATOR. WITHOUT seed THE NUMBERS ARE EASY TO PREDICT.
        math.randomseed(randomseed) end  
    
    speed=1-time_gained/.5    --time_gained→0 OVER NEXT .5 SECONDS (astats UPDATE TIME)
    if samples_time>o.time_needed and mp.get_property_number('time-remaining')>o.time_needed   --DON'T RANDOMIZE BEFORE samples_time STABILIZES, NOR NEAR end-file. 
    then speed=speed+math.random(-o.max_random_percent,o.max_random_percent)/100 end 
    if o.max_percent then    speed=math.max( 1-o.max_percent/100 , math.min(1+o.max_percent/100, speed) ) end  --speed LIMIT. LUA DOESN'T HAVE math.clip
    mp.command('set speed '..speed)
end
timers.auto=mp.add_periodic_timer(.5 , function() pcall(set_speed) end)   --timer KEEPS CHECKING txtfile WHEN PAUSED, WITHOUT astats OBSERVATION.
for _,timer in pairs(timers) do timer:kill() end    --kill timers. THEY CARRY OVER TO NEXT FILE IN MPV PLAYLIST.

mp.observe_property('af-metadata/'..label,'native',function(property) pcall(set_speed,property) end)   --TRIGGERS EVERY HALF A SECOND. pcall SIMPLIFIES set_speed.
mp.observe_property('seeking'            ,'bool'  ,function() initial_time_pos=nil end) --RESET SAMPLE COUNT WHENEVER seeking.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY. 
----SERIOUS  BUG: EXCESSIVE LAG ALONG WITH autocomplex. IN CASE OF DESYNC MUST STOP & PLAY (RESET).     IT COULD BE DUE TO asplit IN lavfi-complex. autosync DOESN'T HELP.
----POSSIBLE BUG: aid TRACK CHANGE UNTESTED. MAY NEED on_aid_change FUNCTION, SINCE BOTH automask & autocrop NEED on_vid FUNCTIONS FOR PROPER TRACK CHANGES.

----apad  (SIMPLER TO USE loop=inf)     APPENDS SILENCE TO audio INSTANCES, SO THEY NEVER stop UNLESS THE CONTROLLER DOES. INSERTS BEFORE astats OR ELSE astats FAILS TO UPDATE MAIN FUNCTION. 



