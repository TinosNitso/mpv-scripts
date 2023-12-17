----ADD CLOCK & TITLE TO video & JPEG, WITH DOUBLE-mute TOGGLE, + audio AUTO speed SCRIPT. clock TICKS WITH SYSTEM. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON PRIMARY RIGHT). ADDS AMBIENCE WITH RANDOMIZATION. PAUSE, STOP, PLAY, SEEK, MUTE & VOLUME APPLY TO ALL INSTANCES, AFTER THEY CHECK THE TEMPORARY txtfile. ALL audio PLAYERS ADJUST TO video LAG, BUT ARE FULLY DETACHED.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER.    USB→3.5mm SOUND CARDS COST AS LITTLE AS $2 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW "wasapi/" DEVICE (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX), WHICH CAN BE SEEN IN TASK MANAGER. "coreaudio/" IS MACOS. VIRTUALBOX USB SUPPORT ENABLES MANY audio OUTPUTS INSIDE VM.
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH YOUTUBE (ytdl).    CHANGING aid UNTESTED (MAY NEED TO STOP & PLAY IN SMPLAYER).

options={ --ALL OPTIONAL & MAY BE REMOVED.
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-mute-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute.
    key_bindings         ='F3',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m. 'F3 F4' FOR 2 KEYS. F1 & F2 MIGHT BE autocomplex & automask. s=SCREENSHOT (NOT SPEED NOR SPECTRUM). C IS CROP, NOT CLOCK.
    
    title_duration=5,  --DEFAULT=5 SECONDS.  AN audio SCRIPT MAY CONTROL title & clock, UNLESS THEY'RE FANCY & DANCE AROUND.
    title='{\\fs55\\bord3\\shad1}', --DEFAULT='' (NO title)  \\,fs,bord,shad = \,FONTSIZE,BORDER,SHADOW (PIXELS)  REMOVE TO REMOVE title. THIS STYLE CODE SETS THE osd. NO-BOLD MEANS BIGGER FONT.   b1=BOLD i1=ITALIC u1=UNDERLINE s1=STRIKE be1=BLUREDGE fn=FONTNAME c=COLOR
    clock='{\\fs71\\bord2\\shad1\\an3}%I{\\fs50}:%M{\\fs35}:%S{\\fs25} %p', --DEFAULT='' (NO clock)  an,%I,%M,%S,%p = ALIGNMENT-NUMPAD,HRS(12),MINS,SECS,P/AM  (DEFAULT an0=an7=TOPLEFT)  REMOVE TO remove clock.  BIG:MEDIUM:LITTLE:tiny, RATIO=SQRT(.5)=.71     FORMATTERS: a A b B c d H I M m p S w x X Y y  REQUIRES [vo] TO BE SEEN (NOT RAW MP3).  AN UNUSED BIG SCREEN TV CAN BE A BIG clock WITH BACKGROUND video. 
    
    filters='anull,'                        --CAN REPLACE anull WITH EXTRA FILTERS (highpass aresample vibrato ...). 
          ..'dynaudnorm=250:11:1:100:0:0:1',--DEFAULT=500:31:.95:10:0:1:0=f:g:p:m:r:n:c  DYNAMIC AUDIO NORMALIZER. ALL INSTANCES USE THIS NORMALIZER. GRAPH COMMENTARY HAS MORE DETAILS.
    -- title_clock_only=true,   --OVERRIDE, WITH filters. NO audio INSTANCES. HOWEVER filters STILL ACTIVE.   THIS option MEANS THE clock DOESN'T HAVE TO BE COPY/PASTED INTO OTHER SCRIPT/S (THIS SCRIPT CAN CONTROL IT).
    
    -- extra_devices_index_list={2},--EXTRA DEVICES. TRY {2,3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. 1=auto WHICH MAY DOUBLE-OVERLAP audio TO PRIMARY DEVICE. 3=VIRTUALBOX USB STEREO. EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS.     EACH MPV USES APPROX 1% CPU, + 40MB RAM.
    -- mutelr='muter',           --DEFAULT='mutel'  UNCOMMENT TO SWITCH PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN PERFECT SYNC TO video. HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    
    max_random_percent=10, --DEFAULT=0. MAX random % DEVIATION FROM PROPER speed. speed UPDATES EVERY HALF A SECOND. E.G. 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.
    max_percent       =15, --DEFAULT=15. SPEED NEVER CHANGES BY MORE. E.G. speed BOUNDED WITHIN [.8,1.2].    1.2 SOUNDS OK, BUT MAYBE NOT .8.
    
    start        = .3, --DEFAULT=.3 SECONDS. APPROX:  .3=SSD  2=HDD.  INITIAL HEADSTART OF audio INSTANCES, EXCEPT ON YOUTUBE. EACH mpv TAKES TIME TO LOAD, & FOR MP4 THEY AREN'T LAUNCHED UNTIL AFTER INITIAL seeking (WHICH WORKS FINE ON SSD).
    seek_limit   =  1, --DEFAULT=1   SECONDS. SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    resync_delay = 30, --DEFAULT=60  SECONDS. os_sync RESYNC WITH THIS DELAY.   mp.get_time() & os.clock() MAY BE BASED ON CPU TIME, WHICH GOES OFF WITH RANDOM LAG.
    os_sync_delay=.01, --DEFAULT=.01 SECONDS. ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    time_needed  =  5, --DEFAULT=5   SECONDS. NO RANDOMIZATION WITHIN 5 SECS OF end-file (STRONG FINISH) & GRAPH INSERTION. ALSO WAITS THIS LONG FOR astats TO STABILIZE SAMPLE COUNT.
    timeout      = 10, --DEFAULT=10  SECONDS. audio INSTANCES ALL shutdown IF CONTROLLER HARD BREAKS FOR THIS LONG.
    
    samplerate=44100, --DEFAULT=44100 Hz. IDEAL SETTING (MAYBE 48 kHz) DEPENDS ON wasapi ETC.
    -- meta_osd=true, --DISPLAY astats METADATA (audio STATISTICS). IRONICALLY astats DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    
    config={
        'audio-delay 0',    --OVERRIDE SMPLAYER (NON-0 COULD BE ACCIDENT).
        'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',   --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
        'image-display-duration inf','vd-lavc-threads 0',    --inf STOPS JPEG FROM SNAPPING MPV.  0=AUTO, vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO.
        -- 'osd-color 1/.5','osd-border-color 0/.5',  --DEFAULTS 1/1,0/1. OPTIONAL: FOR clock. y/a = brightness/alpha (a=OPAQUENESS). A TRANSPARENT clock CAN BE TWICE AS BIG.
        -- 'audio-pitch-correction no', --UNCOMMENT FOR CHIPMUNK MODE. DEFAULT=yes APPLIES scaletempo2(?) FILTER. SCALING TEMPO IS FUNDAMENTAL TO RANDOMIZATION.
    },
}
o,utils = options,require 'mp.utils' --ABBREV.
label,directory = mp.get_script_name(),utils.split_path(mp.get_property('scripts'))   --label=aspeed     FROM smplayer.exe FOLDER, directory=".". IN LINUX IT COULD BE "/home/user/Desktop/SMPLAYER".   mp.get_script_directory() HAS BUG.

for key,val in pairs({key_bindings='',title_duration=5,clock='',filters='anull',extra_devices_index_list={},mutelr='mutel',start=.3,max_random_percent=0,max_percent=15,seek_limit=1,resync_delay=60,os_sync_delay=.01,time_needed=5,timeout=10,toggle_on_double_mute=0,samplerate=44100,config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 
for _,option in pairs(o.config) do mp.command('no-osd set '..option) end --set config

mpv,directory = 'mpv',mp.command_native({'expand-path',directory}) --mpv MAY BE ADDRESSED AS EITHER "mpv" OR "./mpv" IN EVERY SYSTEM. LINUX snap ALLOWS IT TO RUN ITSELF.  command_native RETURNS ~ EXPANDED.
devices,device_list = {mp.get_property('audio-device')},mp.get_property_native('audio-device-list') --devices IS LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device). device_list IS COMPLETE LIST.
mutelr,pid = mp.get_opt('mutelr'),mp.get_opt('pid')   --THESE script-opts FOR audio INSTANCES.

if not (mutelr and pid) then is_controller,pid,mutelr = true,utils.getpid(),o.mutelr  --CONTROLLER MUTES LEFT.
    if utils.subprocess({args={mpv}}).error=='init' then mpv='./mpv' end --error=init FOR INCORRECT COMMAND.  EITHER mpv (WINDOWS & LINUX) OR ./mpv (MACOS & LINUX .AppImage)    OTHERWISE error=killed (NULL CMD). CAN SCAN OVER ALL POSSIBLE COMMANDS.  MACOS working-directory=/Applications/SMPlayer.app/Contents/MacOS
    for _,index in pairs(o.extra_devices_index_list) do is_present,device = false,device_list[index].name
        for _,find in pairs(devices) do if device:upper()==find:upper() then is_present=true    --SEARCH FOR DUPLICATES BEFORE INSERTION. SIMILAR LOGIC TO autoloader.
            return end end
        if not is_present then table.insert(devices,device) end end
else mp.command('no-osd set keep-open yes') end --STOP audio INSTANCES FROM EXITING, WITHOUT apad NOR loop=inf. USER MAY BACKWARDS seek NEAR end-file. 

lavfi=('aformat=s16:%d:stereo,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:1')
    :format(o.samplerate,o.filters,mutelr)
 
----lavfi        =[graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTER LIST.  EACH .LUA SCRIPT MAY CONTROL A GRAPH, LIKE HOW A CELL CONTROLS DNA. aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT.     CHANGING GRAPH NEEDS A FEW HRS FOR TESTING.
----anull         PLACEHOLDER.
----dynaudnorm   =f:g:p:m:r:n:c →s64  DEFAULTS 500:31:.95:10:0:1:0    FRAME(MILLISECONDS):GAUSSIAN_WIN_SIZE(ODD INTEGER):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:CORRECTION_DC(BOOL)   DYNAMIC AUDIO NORMALIZER. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g GIVES FASTER RESPONSE. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. 
----aformat      =sample_fmts:sample_rates:channel_layouts  (u8 s16 s64 ETC)  GIVES astats CONSTANT samplerate. CONVERTS MONO & SURROUND SOUND TO stereo BECAUSE astats NEEDS stereo FOR RELIABILITY. ITS OUTPUT MUST BE DETERMINISTIC OVER 10 HRS (UNLIKE OTHER FILTERS).  s16=SGN+15BIT (-32k→32k). u8 CAUSES HISSING.  
----astats       =length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. USES APPROX 0% OF CPU. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC. MPV autosync WON'T WORK (MAYBE A FUTURE VERSION, BUT CURRENTLY INCOMPATIBLE).
----asplit        [ao]→[NOmutelr][mutelr]
----stereotools  =...:mutel:muter (BOOLS) MUTES EITHER SIDE. softclip OPTION MAY CAUSE A BUG IN LINUX .AppImage. MAY NOT BE DETERMINISTIC OVER 10 HRS?
----astreamselect=inputs:map  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". ANY ATTEMPT TO DOUBLE CHANGE GRAPHS OR DO A FULL TOGGLE CAUSES CONTROLLER GLITCH (CAN VERIFY BY TOGGLING NORMALIZER IN SMPLAYER). SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY REMOTE CONTROL (af-command 0 OR 1). ON=1 BY DEFAULT.


if o.title_clock_only then lavfi=o.filters end  --OVERRIDE
mp.command(('no-osd af append @%s:lavfi=[%s]'):format(label,lavfi))

map,timers,txtpath = 1,{},utils.join_path(directory,('%s-PID%d.txt'):format(label,pid))  --map IS GRAPH SWITCH. SETTING UP A PIPE INSTEAD OF txtfile COULD GIVE INSTANT RESPONSE, BUT COULD ALSO TRIGGER BUGS.  USING .txt INSTEAD OF PIPE IS LIKE PUTTING PLUMBING THROUGH FRONT DOOR.
mp.register_event('shutdown',function() os.remove(txtpath) end)  --NO RECYCLE BIN. audio INSTANCES quit.

function start_file()  --CONTROLLER ONLY. YOUTUBE LAUNCHES INSTANTLY.  AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart  ALL audio PLAYERS quit & THEN ALL NEW ONES START IF file CHANGES.
    priority,pause,start,path,osd_level = nil,nil,nil,mp.get_property('path'),mp.get_property('osd-level')  --priority ACTS AS LAUNCHED-SWITCH. osd_level RETURNS osd-level, AFTER BLOCKING SMPLAYER INTERFERENCE WITH title.
    if o.title then title=mp.create_osd_overlay('ass-events') end
    
    mp.command('no-osd set osd-level 0')
    if not utils.file_info(path) then pause,start = 'yes',mp.get_property('start') --YOUTUBE. LAUNCHES ytdl INSTANTLY TO THE NEAREST SECOND, PAUSED.
        subprocesses() end 
end 

function subprocesses(_,seeking)    --CONTROLLER ONLY. 
    if seeking or o.title_clock_only or priority then return end  --ONLY EVER LAUNCH ONCE/file (priority SWITCH). MP4 WAITS FOR INITIAL seeking TO FINISH. ALSO OVERRIDE→return.
    if not start then start=mp.get_property_number('time-pos')+o.start end --MP4
    if not pause then pause=mp.get_property       ('pause')            end
    
    priority=mp.get_property('priority')
    if priority then priority='--priority='..priority --WINDOWS
    else             priority='--speed=1' end         --LINUX NULL OP. priority NOT SUPPORTED.  ALTERNATIVE IS BUILDING args table.
    
    io.open(txtpath,'w+') --w+ ERASES ALL PRIOR DATA. CREATE FILE IN ADVANCE BECAUSE audio INSTANCES quit WITHOUT IT.
    for _,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('%g+') do if not (device==devices[1] and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY device CHANNEL.
            then utils.subprocess({detach=true,playback_only=false,capture_stdout=false,capture_stderr=false,   --FLAGS OPTIONAL BUT MAY BE NEEDED IN SOME LINUX BUILD.  SET CHILD "msg-level=all=no" OR ELSE PARENT LOG FILLS UP. --aid=CAUSES BUG.    run & subprocess_detached ALSO CREATE DETACHED SUBPROCESSES, BUT THEY AREN'T FULLY DETACHED & CAN CAUSE A BUG INSIDE SMPLAYER. command_native DIDN'T WORK.
                    args={mpv,priority,'--no-vid','--msg-level=all=no','--pause='..pause,'--start='..start,'--volume='..mp.get_property('volume'),('--script-opts=mutelr=%s,pid=%d'):format(mutelr,pid),'--audio-device='..device,'--script='..utils.join_path(directory,label..'.lua'),path}}) end end end 
end
if is_controller then mp.register_event('start-file',start_file)
                      mp.register_event('file-loaded',function() mp.observe_property('seeking','bool',subprocesses) end) end  --OBSERVING seeking MAY BE SLIGHTLY BETTER THAN REGISTERING TO playback-restart (EQUIVALENT).
    
function playback_restart() --playback-restart RESETS GRAPH. 
    initial_time_pos = nil  --RESET SAMPLE COUNT.
    mp.add_timeout(.1,set_osd_level)  --RETURN osd-level IF NECESSARY. timeout TO OVERRIDE SMPLAYER.
    
    if title then title.data=o.title..mp.get_property_osd('media-title') --LINUX .AppImage (VIRTUALBOX) BUGS OUT IF clock OR title INSERT SOONER.
                  title:update()  --DISPLAY title.
                  mp.add_timeout(o.title_duration,title_remove) end --remove title ON timeout.
    
    mp.command(('af-command %s map %d'):format(label,map)) --UNLIKE automask, DOESN'T REQUIRE frame-step WHEN PAUSED.
    timers.auto:resume()       --STARTING timer SOONER CAUSED RARE BUG.
    os_sync()
    mp.add_timeout( 2,os_sync) --RESYNC ON TIMEOUTS, DUE TO HDD LAG.
    mp.add_timeout( 4,os_sync)
    mp.add_timeout( 8,os_sync)
    mp.add_timeout(16,os_sync)
end  
mp.register_event('playback-restart',playback_restart) 

function title_remove() --SENDS title→nil ON timeout.
    if title then title:remove() end
    title=nil 
end 

function on_toggle(mute)   --INSTA-TOGGLE (SWITCH), NOT PROPER FULL toggle. (PERHAPS A DOUBLE-TAP key_bind COULD TRIGGER FULL TOGGLE.)  audio INSTANCES MAINTAIN SYNC WHEN OFF.
    if not start or not is_controller then return end  --NOT STARTED YET.
    if mute and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.
        return end
    
    OFF,map = not OFF,1-map   -- 1,0 = ON,OFF 
    playback_restart()  
    clock_update()  --INSTANT clock, OR IT WAITS TO SYNC.
end
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_speed_'..key, on_toggle)  end 
mp.observe_property('mute','bool',on_toggle)

timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end )  --mute timer. VALID EVEN FOR 0 TIME (DISABLED).
timers.mute.oneshot,clock = true,mp.create_osd_overlay('ass-events')   --ass-events IS THE ONLY VALID OPTION, FOR title & clock.

function clock_update() 
    if OFF or not o.clock then clock:remove()   --OFF SWITCH.
        return end
    clock.data=os.date(o.clock):gsub('}0','} ') --REMOVE LEADING 0 AFTER "}" STYLE CODE.
    clock:update()
    timers.osd:resume() 
end
timers.osd=mp.add_periodic_timer(1, clock_update)   --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS IRRELEVANT TO audio SYNC.

function os_sync()  --RUN 10ms LOOP UNTIL clock TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC time-pos WITH OTHER MPV INSTANCES. 
    if not time1 then time1=os.time()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH)
        timers. resync:kill() 
        timers. resync:resume() 
        timers.os_sync:resume() 
        return end
    
    time2=os.time()  --INTEGER SECONDS FROM 1970.
    if time2<=time1 then return end --NO TICK YET, WAIT.
    
    timers.os_sync:kill()
    time1,sync_time = nil,time2-mp.get_time()   --time1 ACTS AS A SWITCH. sync_time IS THE CONSTANT TO ADD TO mp TIME TO GET TIMEFROM1970.      mp.get_time()=os.clock()+CONSTANT (GIVE SAME NET RESULT).

    timers.osd:kill()   --SYNC clock TICK TO SYSTEM. 
    clock_update() 
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)
timers. resync=mp.add_periodic_timer(o. resync_delay,os_sync) --KEEP RESYNCING EVERY 2s FOR 20s. CPU TIME LOSES TIME IF SIMULTANEOUSLY TOGGLING GRAPHS, & HDD LAG.  RESYNC ON timeout REQUIRED FOR audio INSTANCES TOO.
for _,timer in pairs(timers) do timer:kill() end    --kill timers. THEY CARRY OVER TO NEXT FILE IN MPV PLAYLIST.

function set_osd_level()
    if osd_level then mp.command('no-osd set osd-level '..osd_level) end    --no-osd (RETURN)
    osd_level=nil
end

function set_speed(property)    --property='af-metadata/aspeed' OR nil     THIS IS THE MAIN FUNCTION. CONTROLLER WRITES TO txtfile, OR audio INSTANCES READ FROM IT. BY TRIAL & ERROR SHOULD ONLY EVER BE PCALLED IN CASE OF SUDDEN STOP (SIMULTANEOUS io.remove & io.write).
    samples_time,os_time = nil,os.time()   --nil WHEN seeking
    paused,time_pos,meta = mp.get_property_bool('pause'),mp.get_property_number('time-pos'),mp.get_property_native('af-metadata/'..label)
    if meta then samples_time=meta['lavfi.astats.Overall.Number_of_samples']/o.samplerate end    --#samples/samplerate          time-pos, playback-time & audio-pts WORK WELL OVER 1 MINUTE, BUT NOT 1 HOUR. autosync WON'T FIX THIS. SO USE astats INSTEAD.  
    
    if sync_time then os_time=sync_time+mp.get_time()  --PRECISE TO 10ms. BEFORE SYNC, pause OVERRIDE STILL APPLIES.
        if samples_time and samples_time>o.time_needed then if not initial_time_pos and property    --INITIALIZE, WITH ENOUGH DATA & IF TRIGGERED BY astats.
            then initial_time_pos=time_pos-samples_time end  -- THIS # STAYS THE SAME FOR THE NEXT 10 HOURS.   LIKE HOW YOGHURT GOES OFF, PERHAPS 20 HRS LATER THE SPEAKERS WILL BE OFF (astats ISSUE). DISJOINT STEREO SEEMS LIKE YOGHURT DISJOINT FROM CREAM.         REPLACE "not initial_time_pos"→"true" TO PROVE MPV CAN'T SYNC WITHOUT astats.
            if initial_time_pos then time_pos=initial_time_pos+samples_time end end end   --NEW METRIC WHOSE CHANGE IS BASED ON astats. IT'S A TIME METRIC-SWITCH TRICK.
    
    if is_controller then if not paused and not property then return end    --ONLY WRITE DOWN TIMES @astats OBSERVATION, NOT auto timer.
        txtfile,volume = io.open(txtpath,'w+'),mp.get_property_number('volume')   --volume IN [0,100]
        if OFF    or mp.get_property_bool('mute')    then volume=0  end --INSTA-TOGGLE REQUIRES volume=0
        if paused or mp.get_property_bool('seeking') then volume=-1 end --NEGATIVE INSTRUCTS audio INSTANCES TO pause. 

        txtfile:write(('%s\n%d\n%d\n%s\n%s'):format(mp.get_property('path'),mp.get_property_number('current-tracks/audio/id'),volume,os_time,time_pos))   --%s,%d = string,DECIMAL-INTEGERS. CONTROLLER REPORT. EITHER flush() OR close().  LINES 1,2,3,4,5 = path,aid,volume,time,POSITION   THE LAST 2 lines COULD BE COMBINED (TIMEFROM1970TO0=DIFFERENCE).
        txtfile:close() --write & close CAN USUALLY BE COMBINED ON 1 LINE, BUT NOT ON SLOW DARWIN (MACOS-CATALINA VIRTUALBOX). IT DOESN'T RETURN PROPERLY. 
        
        if o.meta_osd then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t')) end   --TAB EACH STAT (TOO MANY LINES).
        return end   --CONTROLLER ENDS HERE.  IRONICALLY IT DOESN'T SET SPEED, BECAUSE EACH audio INSTANCE HAS A MIND OF ITS OWN.
    
    if txt_time and os_time-txt_time>o.timeout then mp.command('quit') end    --EXIT - CONTROLLER HARD BREAKED LONG AGO.
    pcode,lines = pcall(io.lines,txtpath)    --lines ITERATOR RETURNS ERROR OR 0 OR 5 LINES.     THIS IS A pcall INSIDE ANOTHER pcall.
    if not pcode then mp.command('quit') end --EXIT & DELETE. NO txtfile MEANS CONTROLLER HAS STOPPED. 'stop' INCOMPATIBLE WITH LINUX .AppImage ('quit' INSTEAD).
    
    path=lines()  --LINE1=path  
    if not path then return end --SOMETIMES txtfile IS BLANK (@TIME OF write).
    if path~=mp.get_property('path') and sync_time then mp.command('quit') end --EXIT. DIFFERENT FILE (E.G. PLAYLIST). RARE BUG-FIX: ONLY quit AFTER SYNC.
    mp.command('set aid '..lines()) --LINE2=aid   UNTESTED  
    
    volume,txt_time = 0+lines(),lines()    --LINES 3,4 = volume,TIME_OF_WRITE    0+ CONVERTS tonumber
    if volume<0 then mp.command('set pause yes')
        return end
    mp.command('set pause no')
    mp.command('set volume '..volume) 
    if not sync_time or not paused and not property then return end     --DON'T CHANGE speed BEFORE INITIAL SYNC OR IF PLAYING BUT NOT property. 
    
    time_gained=time_pos-lines()-(os_time-txt_time)  --LINE5=POS     SUBTRACT TIME_FROM_WRITE FROM DIFFERENCE BTWN POSITIONS.
    if o.seek_limit and math.abs(time_gained)>o.seek_limit then mp.command(('seek %s exact'):format(-time_gained)) --INSTANT SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED - LIKE SCRATCHING A RECORD).
        return end   
    
    if not randomseed then randomseed=os_time  --INITIALIZE random # GENERATOR. WITHOUT randomseed THE NUMBERS ARE EASY TO PREDICT.
        math.randomseed(randomseed) end  
    
    speed=1-time_gained/.5    --time_gained→0 OVER NEXT .5 SECONDS (astats UPDATE TIME).
    if samples_time>o.time_needed and mp.get_property_number('time-remaining')>o.time_needed   --DON'T RANDOMIZE BEFORE samples_time STABILIZES, NOR NEAR end-file. 
    then speed=speed+math.random(-o.max_random_percent,o.max_random_percent)/100 end 
    
    speed=math.max( 1-o.max_percent/100 , math.min(1+o.max_percent/100, speed) )    --speed LIMIT. LUA DOESN'T SUPPORT math.clip
    mp.command('set speed '..speed)
end
mp.observe_property('af-metadata/'..label,'native',function(property) pcall(set_speed,property) end) --TRIGGERS EVERY HALF A SECOND. pcall SIMPLIFIES set_speed.
timers.auto=mp.add_periodic_timer(              .5,function()         pcall(set_speed)          end) --timer KEEPS CHECKING txtfile WHEN PAUSED, WITHOUT astats OBSERVATION.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----"autospeed.lua" IS A DIFFERENT SCRIPT FOR video speed, NOT audio. 
----BUG: EXCESSIVE LAG ALONG WITH autocomplex. IN CASE OF DESYNC MUST STOP & PLAY (RESET).  autosync DOESN'T HELP.

----ALTERNATIVE FILTERS:
----apad     (SIMPLER TO USE keep-open=yes)     APPENDS SILENCE TO audio INSTANCES, SO THEY NEVER stop UNLESS THE CONTROLLER DOES. INSERTS BEFORE astats OR ELSE astats FAILS TO UPDATE MAIN FUNCTION. 
----volume =volume:...:eval  (DEFAULT 1:once)  TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.
----atrim  =start (SECONDS) TO MATCH lavfi-complex. UNNECESSARY.
----asetpts=expr            TO MATCH lavfi-complex.

----audio-params/samplerate current-tracks/audio/demux-samplerate PROPERTIES GIVE samplerate, BUT BETTER TO SET IT IN GRAPH.



