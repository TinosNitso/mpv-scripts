----ADD CLOCK TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. CLOCK TICKS WITH SYSTEM, & MAY BE COLORED & STYLED. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PRIORITY, PATH, AID & LAG APPLY TO ALL DETACHED SUBPROCESSES. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER. A SMALLER STEREO ADDS MORE TREBLE (BIG CHEAP STEREOS HAVE TOO MUCH BASS).  USB→3.5mm SOUND CARDS COST AS LITTLE AS $3 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES A NEW mpv IN TASK MANAGER (1% CPU, + 40MB RAM).  EVERY SPEAKER BOX (EXCEPT PRIMARY) GETS ITS OWN YOUTUBE STREAM, ETC. ALSO FULLY WORKS IN VIRTUALBOX. 
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.

options={  --ALL OPTIONAL & MAY BE REMOVED.
    key_bindings             = 'Ctrl+C Ctrl+c',  --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO filterchain.  C IS autocrop.lua, NOT CLOCK.
    toggle_on_double_mute    = .5,  --SECONDS TIMEOUT FOR DOUBLE-MUTE-TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.  IN GENERAL COULD BE RENAMED double_mute_timeout.
    extra_devices_index_list = {},  --TRY {3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS. REPETITION IGNORED.  1=auto  2=NORMAL DEVICE.  WRONG INDEX CAN OVERLAP AUDIO TO PRIMARY DEVICE. EACH CHANNEL FROM EACH device IS A SEPARATE SUBPROCESS. 

    filterchain='anull,'  --CAN REPLACE anull WITH EXTRA FILTERS (vibrato highpass aresample ETC).
              ..'dynaudnorm=g=5:p=1:m=100', --DEFAULT=...:31:.95:10  DYNAMIC AUDIO NORMALIZER.  ALL SUBPROCESSES USE THIS. GRAPH COMMENTARY HAS MORE DETAILS.
    mpv={  --REMOVE FOR NO SUBPROCESSES OVERRIDE (CLOCK+filterchain ONLY). LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE. USED BY ALL SUBPROCESSES. A COMMAND MAY NOT BE A PATH.  
        "mpv",   --LINUX & SMPLAYER (WINDOWS)
        "./mpv", --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv",       --     mpv.app
        "/Applications/SMPlayer.app/Contents/MacOS/mpv",  --SMPlayer.app
    },
    timeouts           = {quit=15,pause=5},  --DEFAULT={10,5}  SUBPROCESSES ALL quit OR pause IF CONTROLLER BREAKS FOR THIS LONG.  THEY pause INSTANTLY ON STOP.
    max_speed_ratio    = 1.15,  --DEFAULT=1.2          speed IS BOUNDED BY [SPEED/max,SPEED*max], WITH SPEED FROM CONTROLLER.  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    max_random_percent =   10,  --DEFAULT=  0 %        MAX random % DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND.  EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L & R TO DRIFT RELATIVELY, DUE TO HALF SECOND RANDOM WALKS BTWN speed UPDATES (CAN VERIFY WITH MONO→STEREO SCREEN RECORDING).
    seek_limit         =   .5,  --DEFAULT= .5 SECONDS  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    resync_delay       =   30,  --DEFAULT= 60 SECONDS  os_sync RESYNC WITH THIS DELAY.   mp.get_time() & os.clock() MAY BE BASED ON CPU TIME, WHICH GOES OFF WITH RANDOM LAG.
    auto_delay         =  .25,  --DEFAULT= .5 SECONDS  subprocess RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    os_sync_delay      =  .01,  --DEFAULT=.01 SECONDS  ACCURACY FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    min_samples_time   =   20,  --DEFAULT= 20 SECONDS  SAMPLE COUNT USUALLY STABILIZES WITHIN 10 SECONDS (EXCEPT ON YOUTUBE+lavfi-complex).  IT'S ALWAYS A HALF-INTEGER @MEASUREMENT.  THIS OPTION SHOULD BE REMOVED IN A FUTURE VERSION (MPV-v0.38 DOESN'T NEED IT).
    -- meta_osd        =    1,  --SECONDS TO DISPLAY astats METADATA, PER OBSERVATION. UNCOMMENT FOR STATS.  IRONICALLY astats (audio STATISTICS) DOESN'T KNOW ANYTHING ABOUT TIME ITSELF, YET IT'S THE BASIS FOR TEN HOUR SYNCHRONY.
    -- mutelr          = 'muter', --DEFAULT='mutel'    UNCOMMENT TO SWITCH PRIMARY CONTROLLER CHANNEL TO LEFT. PRIMARY device HAS 1 CHANNEL IN NORMAL SYNC TO video.  HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    options=''       --FREE FORM  ' opt1 val1  opt2=val2  --opt3=val3 '  
          ..' image-display-duration=inf         '           --JPEG clock.
          ..'    osd-scale-by-window=no  osd-font=Consolas ' --DEFAULT=yes,sans-serif  SCALING 720p CAUSES Day MISALIGNMENT. DISABLING IT IS THE LAZY SOLUTION COMPARED TO SETTING CLOCK res_x,res_y.  THIS FONT IS DEFAULT, WITHOUT STYLE OVERRIDE (LIKE A FRENCH FONT FOR FRANCE, ETC).
       -- ..'       osd-border-color=.5/.5/.5/.5 '           --CONTROLS clock FONT OUTLINE. DEFAULT=0=0/1=y/a=BRIGHTNESS/ALPHA (OPAQUENESS).  RED=1/0/0/1, BLUE=0/0/1/1, ETC
       -- ..' audio-pitch-correction=no          '           --UNCOMMENT FOR CHIPMUNK MODE (ON ALL BUT PRIMARY CHANNEL). WORKS OK WITH SPEECH & COMICAL MUSIC. DEFAULT=yes APPLIES scaletempo2(?) FILTER. 
    ,
    clocks             = {  --TOGGLE LINES TO INCLUDE/EXCLUDE VARIOUS STYLES FROM THE LIST.  REPETITION VALID.  CLOCKS REQUIRE VIDEO.  A SIMPLE LIST OF STRINGS IS EASY TO RE-ORDER & DUPLICATE.  
        duration       = 2, --SECONDS, INTEGER.  TIME PER CLOCK STYLE (CYCLE DURATION).  2 TICKS PER FLAG, EVERY SECOND SECOND.  BUT MAYBE IT TAKES LONGER TO COMFORTABLY RECOGNIZE EACH & EVERY COUNTRY. 
        offset         = 0, --SECONDS, INTEGER.  CHANGE STYLE ON EVENS OR ODDS? 0=EVEN.  ALL SMPLAYER INSTANCES HAVE SAME CLOCK @SAME TIME.
        -- DIRECTIVES_OVERRIDE = true,  --UNCOMMENT TO DISPLAY ALL os.date DIRECTIVE CODES & THEIR CURRENT VALUES (SPECIAL CLOCK).  EXAMPLES: %I,%M,%S,%a,%n = HRS(12),MINS,SECS,Day,RETURN  %n & \\N ARE DIFFERENT.  %n ENABLES NEW NUMPAD ALIGNMENT, WHICH COULD HELP WITH A MADAGASCAR STYLE.
    ----FUTURE VERSION SHOULD HAVE upper,lower & NO-LOCALES OPTIONS. LOCALES START WITH Sun.  IF SOMEONE WANTS ONLY ARABIC, COPY/PASTE THE ARABIC OVER ALL THE OTHERS!
    ----STYLE CODES:  \\,alpha##,an#,fs#,bord#,c######,b1 = \,TRANSPARENCY,ALIGNMENT-NUMPAD,FONT-SIZE(p),BORDER(p),COLOR,BOLD  (DEFAULT an0=an7=TOPLEFT)    MORE: shad#,be1,i1,u1,s1,fn*,fr##,fscx##,fscy## = SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEX(%),FONTSCALEY(%)  EXAMPLES: USE {\\alpha80} FOR TRANSPARENCY. USE {\\fscx130} FOR +30% IN HORIZONTAL.  A TRANSPARENT clock CAN BE TWICE AS BIG. be ACTS LIKE SEMI-BOLD.  
    ----"COUNTRY                     HOUR     MINUTE   SECOND  POPULATION       [ABDAYS]         {\\STYLE OVERRIDES}%DIRECTIVES",  { REQUIRED, & EVERYTHING BEFORE IT IS REMOVED. {} REMOVES LEADING 0 FOLLOWING IT. " "~=" " IS A MAGIC SPACEBAR, FOR POSITIONING LOTE.  https://lh.2xlibre.net/locales/ FOR ABBREVIATED DAYS IN ARABIC, ETC.  (I RANDOMLY PICKED ONE FROM MANY SPACE CHARS - 2 OR 3 BYTES.)
        "BELGIUM      BELGIË         BLACK    YELLOW   RED      12M  [Zo  Ma  Di  Wo  Do  Vr  Za ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c0     \\fs55\\bord1}%I{\\c24DAFD\\bord3} %M{\\c4033EF         } %S",  --BLACK PRIMARY (THIN BORDER), LIKE GERMANY.  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  CAN RECITE COUNTRIES (BELGIUM CAPITAL).  SECS ARE THE CORNERSTONE (ANCHOR).  CAN USE ":" OR " " BTWN DIGITS, BUT CODES LONGER & LESS SYMMETRIC WITH VERTICALS.
        "ROMANIA      ROMÂNIA        BLUE     YELLOW   RED      19M  [Du  Lu  Ma  Mi  Jo  Vi  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c7F2B00\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE         } %S",  --CHAD SIMILAR.  MOLDOVA & ANDORRA SIMILAR BUT CHARGED. 
        "MALI                        GREEN    YELLOW   RED      21M  [Aca Etl Tal Arb Kam Gum Sab]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c3AB514\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE         } %S",  --SENEGAL SIMILAR BUT CHARGED.  IDEAL COLOR LIST MIXES AFRO & EURO FLAGS. 
        "GUINEA       GUINÉE         RED      YELLOW   GREEN    14M  [Dim Lun Mar Mer Jeu Ven Sam]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c2611CE\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c609400         } %S",  --RED IS RIGHT, EXCEPT FOR GUINEA!  REVERSE OF MALI, SIMILAR TO ROMANIA.  
        "NIGERIA                     GREEN    WHITE    GREEN   231M  [Sun Mon Tue Wed Thu Fri Sat]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c008000\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c008000         } %S",  --BICOLOR TRIBAND.  WHITE ALWAYS IN THE MIDDLE. ORDER ALIGNS WHITES & REDS.
        "IVORY COAST  CÔTE D'IVOIRE  ORANGE   WHITE    GREEN    31M  [Dim Lun Mar Mer Jeu Ven Sam]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c0082FF\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c449A00         } %S", 
        "IRELAND      ÉIREANN        GREEN    WHITE    ORANGE    7M  [Dom Lua Mái Céa Déa Aoi Sat]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c629B16\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3E88FF         } %S",
        "ITALY        ITALIA         GREEN    WHITE    RED      59M  [Dom Lun Mar Mer Gio Ven Sab]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c458C00\\fs55\\bord3}%I{\\cF0F5F4       } %M{\\c2A21CD         } %S",  --MEXICO SIMILAR BUT CHARGED. CATHOLIC, LIKE IRELAND.
        "FRANCE                      BLUE     WHITE    RED      68M  [Dim Lun Mar Mer Jeu Ven Sam]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\cA45500\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3541EF         } %S", 
        "PERU         PERÚ           RED      WHITE    RED      34M  [Do  Lu  Ma  Mi  Ju  Vi  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c2310D9\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c2310D9         } %S",  --BICOLOR.  CANADA MIGHT BE SIMILAR BUT WITH REDUCED HRS & SECS fs.
        "AUSTRIA      ÖSTERREICH     RED    ◙ WHITE  ◙ RED       9M  [So  Mo  Di  Mi  Do  Fr  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c2E10C8\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c2E10C8       }\\N%S",  --BICOLOR. HORIZONTAL TRICOLOR (VERTICAL TAB).  LIKE A TAB FROM THE FLAG.  Black BEST POSITIONED ON SCREEN EDGE, BUT NOT CORNER.  {\\fr-90} IS ANOTHER OPTION.
        "HUNGARY      MAGYARORSZÁG   RED    ◙ WHITE  ◙ GREEN    10M  [V   H   K   Sze Cs  P   Szo]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c3929CE\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c507047       }\\N%S",
        "LUXEMBOURG   LËTZEBUERG     RED    ◙ WHITE  ◙ CYAN     <1M  [So  Mo  Di  Mi  Do  Fr  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c4033EF\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\cE0A300       }\\N%S",
        "NETHERLANDS  NEDERLAND      RED    ◙ WHITE  ◙ BLUE     18M  [Zo  Ma  Di  Wo  Do  Vr  Za ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c251DAD\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c85471E       }\\N%S",  --PARAGUAY & CROATIA SIMILAR BUT CHARGED.  YUGOSLAVIA WAS CHARGED REVERSE.
        "YEMEN        اليمن           RED    ◙ WHITE  ◙ BLACK    34M    [    ح    ن    ث    ر    خ    ج    س]   {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c2611CE\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c0     \\bord1}\\N%S", --ABDAYS BACK-TO-FRONT.  " " FOR SCREEN SPACING, " " FOR CODE SPACING.
        "BOLIVIA                     RED    ◙ YELLOW ◙ GREEN    12M  [Do  Lu  Ma  Mi  Ju  Vi  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c1C29DA\\fs55\\bord3}%I{\\c00E4F4     }\\N%M{\\c337A00       }\\N%S",
        "ARMENIA      ՀԱՅԱՍՏԱՆ       RED    ◙ BLUE   ◙ ORANGE    3M  [Կրկ Երկ Երք Չրք Հնգ Ուր Շբթ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c1200D9\\fs55\\bord3}%I{\\cA03300     }\\N%M{\\c00A8F2       }\\N%S",
        "RUSSIA       РОССИЯ         WHITE  ◙ BLUE   ◙ RED     147M  [Вс  Пн  Вт  Ср  Чт  Пт  Сб ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\cFFFFFF\\fs55\\bord3}%I{\\cA73600     }\\N%M{\\c1827D6       }\\N%S",  --SLOVENIA SIMILAR, BUT CHARGED. SERBIA IS CHARGED REVERSE.  
        "BULGARIA     БЪЛГАРИЯ       WHITE  ◙ GREEN  ◙ RED       6M  [Вс  Пн  Вт  Ср  Чт  Пт  Сб ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\cFFFFFF\\fs55\\bord3}%I{\\c009900     }\\N%M{\\c0000CC       }\\N%S",
        "LITHUANIA    LIETUVA        YELLOW ◙ GREEN  ◙ RED       3M  [Sk  Pr  An  Tr  Kt  Pn  Št ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c13B9FD\\fs55\\bord3}%I{\\c446A00     }\\N%M{\\c2D27C1       }\\N%S",
        "ESTONIA      EESTI          BLUE   ◙ BLACK  ◙ WHITE     1M  [P   E   T   K   N   R   L  ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\cCE7200\\fs55\\bord3}%I{\\c0   \\bord1}\\N%M{\\cFFFFFF\\bord3}\\N%S",
        "GERMANY      DEUTSCHLAND    BLACK  ◙ RED    ◙ GOLD     85M  [So  Mo  Di  Mi  Do  Fr  Sa ]  {\\an3\\b1\\c0\\fs37\\bord0}%a\\N{\\c0     \\fs55\\bord1}%I{\\cFF  \\bord3}\\N%M{\\c00CCFF       }\\N%S",
        -- "Wedge                    BIG    : MEDium : Little  tiny                                 {\\an3                            \\fs70\\bord2       }{}%I{         \\fs42 }:%M{\\fs25 }:%S{\\fs15} %a",  --''  RATIO=.6  MY FAV.  SOME COUNTRY MIGHT HAVE A DIAGONAL PATTERN.
    },
} 
o,label   = options,mp.get_script_name()  --label=aspeed
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,extra_devices_index_list={},filterchain='anull',mpv={},clocks={},timeouts={},max_random_percent=0,max_speed_ratio=1.2,seek_limit=.5,auto_delay=.5,resync_delay=60,os_sync_delay=.01,min_samples_time=20,mutelr='mutel',options=''})
do o[opt] = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA USED BY mpv.app.  
while 1 
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not val then break    end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR txtfile.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

for opt in ('seek_limit resync_delay min_samples_time'):gmatch('[^ ]+') 
do o[opt]         = o[opt]+0 end  --CONVERSION→number  (FOR INEQUALITIES).
directory         = require 'mp.utils'.split_path(mp.get_property_native('scripts')[1]) --SCRIPT FOLDER. UTILITIES SHOULD BE AVOIDED & POTENTIALLY NOT FUTURE COMPATIBLE. HOWEVER CODING A split WHICH ALWAYS WORKS ON EVERY SYSTEM MAY BE TEDIOUS. mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
directory         = mp.command_native({'expand-path',directory})   --command_native EXPANDS ~/
devices           = {mp.get_property('audio-device')}  --LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device).  "wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).  IT DOESN'T GIVE THE SAMPLERATES NOR CHANNEL-COUNTS. RANDOMIZING EACH CHANNEL COULD REQUIRE SUBPROCESSES TO START THEIR OWN SUBPROCESSES (LIKE A BRANCHING TREE).
p                 = {pid=mp.get_property('pid'),['script-opts']=mp.get_property_native('script-opts'),['audio-device-list']=mp.get_property_native('audio-device-list')}  --PROPERTIES table.
txt               = {pid=p['script-opts'].pid or p.pid}  --txt = txtfile-TABLE
is_controller     = not  p['script-opts'].pid  --ALL SUBPROCESSES KNOW CONTROLLER PID.
auto_delay        = is_controller and .5 or o.auto_delay  --CONTROLLER auto_delay EXISTS TO STOP timeout.
o.clocks.duration =  o.clocks.duration and o.clocks.duration+0>0 and o.clocks.duration  --duration=nil IF 0.  THESE ARE CLOCK CYCLE PARAMETERS.
o.clocks.offset   =  o.clocks.offset  or 0  --DEFAULT=0
o.timeouts.quit   = (o.timeouts.quit  or o.timeouts[1] or 10)+0  --DEFAULT=10
o.timeouts.pause  = (o.timeouts.pause or o.timeouts[2] or  5)+0  --DEFAULT= 5 
txtpath           = ('%s/%s-PID%d.txt'):format(directory,label,txt.pid)  --"/" FOR WINDOWS & UNIX. txtfile INSTEAD OF PIPES. CREATED FOR RAW JPEG ALSO, TO HANDLE playlist-next.
mutelr            = p['script-opts'].mutel and 'mutel' or p['script-opts'].muter and 'muter' or o.mutelr  --mutelr IS A GRAPH INSERT.
map,key           = 1,'lavfi.astats.Overall.Number_of_samples' --map CHANGES ONLY FOR CONTROLLER.  key=LOCATION OF astats SAMPLE COUNT.  TESTED @OVER 1 BILLION.
for _,command in pairs(o.mpv) do if is_controller and mp.command_native({'subprocess',command}).error_string~='init'  --CONTROLLER command LOOP (NULL-OPS). error=init IF INCORRECT COMMAND.  subprocess RETURNS (NOT run).
    then mpv      = command
        break end end  --break ON FIRST MATCH.
m,clocks,Days,DICTIONARIES = {},{},{},{}  --m=MEMORY FOR map GRAPH SWITCH.  DICTIONARIES FOR CLOCK DAYS.

for Day in ('Sun Mon Tue Wed Thu Fri Sat'):gmatch('[^ ]+') do table.insert(Days,Day) end  --ENGLISH DEFAULT.
for  _,clock in pairs(o.clocks) 
do DICT,clock        = {},tostring(clock)
    S2S              = (clock):gsub('.*%[','',1):gsub('%].*','',1) or '' --Sun→Sat
    S2S              = S2S==clock and '' or S2S   --NO LOCALE.
    clock,gmatch     = (clock):gsub('[^{]*','',1),(S2S):gmatch('[^ ]+') --* MAY ELIMINATE NOTHING BEFORE LEADING {. ONCE ONLY.  tostring(true)=true
    if clock        ~= '' then for _,Day in pairs(Days)  --NON-TRIVIAL ONLY.
        do DICT[Day] = gmatch() or Day end  --OR DEFAULT
        table.insert(DICTIONARIES,DICT)    
        table.insert(clocks,clock) end end
if o.clocks.DIRECTIVES_OVERRIDE  --OVERRIDE BLOCKS EVERYTHING EXCEPT DIRECTIVES, BELOW.
then clocks             = {''} 
    for N               = 0,128  --LOOP OVER ALL POSSIBLE BYTECODE FROM 0→0x80.
    do char             = string.char(N)  --A=0x41=65 & a=0x61=97  
       N                =        char=='a' and '\n' or ''  --INTRODUCE NEWLINE FOR a.
       DIRECTIVE        =   '%'..char
       clocks[1]        = os.date(DIRECTIVE):sub(1,1)=='%' and clocks[1]  --os.date RETURNS %char IF INVALID (SKIP). 
                          or ('%s%s%%%s="%s"  '):format(clocks[1],N,DIRECTIVE,DIRECTIVE) end end
clock                   = is_controller and o.clocks[1] and mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.  AT LEAST 1 CLOCK NEEDED.  COULD SET res_x & res_y FOR BETTER THAN 720p.
for _,index in pairs(o.extra_devices_index_list)  --ESTABLISHES devices, TO ACTIVATE.
do  is_present          = nil
    device_candidate    = (p['audio-device-list'][index] or {}).name
    for  _,device in pairs(devices) 
    do  if device       == device_candidate 
        then is_present = 1  --SEARCH FOR DUPLICATES BEFORE INSERTION. SIMILAR TO main.lua
            break end end
    if not is_present then table.insert(devices,device_candidate) end end

if not is_controller then math.randomseed(p.pid)  --UNIQUE randomseed, OTHERWISE TEMPO MAY BE SAME OR PREDICTABLE, BTWN SUBPROCESSES.
    mp.command('set vid no;set geometry 25%;set keep-open yes;set pause yes;set msg-level all=no;set terminal no;set ytdl-format bestaudio/best') end  --STARTING PAUSED PREVENTS RARE YOUTUBE GLITCH.  keep-open FOR seek NEAR end-file.  all=no STOPS CONTROLLER LOG FROM FILLING UP. SOMEHOW SUBPROCESSES PIPE BACK, IN WINDOWS.  THEY REPORT A fatal ERROR FOR JPEG - BUT IT'S ~FATAL.


lavfi=is_controller 
      and ('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d'):format(o.filterchain,mutelr)
      or  ('stereotools=%s=1,astats=.5:1,%s'):format(mutelr,o.filterchain)  --(MAYBE) LESS CPU USAGE WITHOUT asplit.

----lavfi         = [graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT. 
----stereotools   = ...:mutel:muter (BOOLS)  DEFAULT=...:0:0  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED stereo FOR RELIABILITY. ALSO MUTES EITHER SIDE. FFMPEG-v4 INCOMPATIBLE WITH softclip.
----dynaudnorm    = ...:g:p:m                DEFAULT=...:31:.95:10  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). A 2 STAGE PROCESS MIGHT BE IDEAL (SMALL g → BIG g).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. IT'S USED SEVERAL TIMES SIMULTANEOUSLY: EACH SPEAKER + lavfi-complex + VARIOUS GRAPHICS.
----astats        = length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT IS BASIS FOR 10 HOUR SYNC. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. USING THIS AS PRIMARY METRIC AVOIDS MESSING WITH MPV/SMPLAYER SETTINGS TO ACHIEVE 10 HOUR SYNC.  MPV-v0.38 CAN SYNC ON ITS OWN WITHOUT astats (BUT NOT v0.36).
----astreamselect = inputs:map  IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH. SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.
----anull           PLACEHOLDER.
----asplit          [ao]→[0][1]=[NOmutelr][mutelr]


lavfi=not o.mpv[1] and o.filterchain or lavfi  --OVERRIDE (NO SUBPROCESSES).

function start_file()  --LAUNCH INSTANTLY, FOR YOUTUBE. AT LEAST 4 STAGES: LOAD-SCRIPT start-file file-loaded playback-restart
    p.path,p['script-opts'] = mp.get_property('path'),mp.get_property('script-opts')  --ytdl_hook SCRIPT-OPT POTENTIALLY UNSAFE & ONLY EVER DECLARED ONCE (SEE TASK MANAGER).
    if not mpv then return end  --OVERRIDE, ALREADY LAUNCHED, OR ~is_controller. CONTROLLER ONLY BELOW.  ALSO LAUNCH ON JPEG, FOR MPV PLAYLIST.
    script=('%s/%s.lua'):format(directory,label)  --COULD SWITCH .lua TO .js FOR JAVASCRIPT.   
    for N,device in pairs(devices) do for mutelr in ('mutel muter'):gmatch('[^ ]+') do if not (N==1 and mutelr==o.mutelr) --DON'T LAUNCH ON PRIMARY device CHANNEL (INTERFERENCE). 
            then mp.command_native({name='subprocess',playback_only=false,capture_stdout=false,capture_stderr=false,detach=true,  --EXTRA FLAGS FOR UNIX RELIABILITY, & BACKWARDS COMPATIBILITY.  script-opts COULD BE REPLACED BY env (ENVIRONMENTAL VARIABLES FOR EACH MPV).
                        args={mpv,'--idle','--script='..script,('--script-opts=%s=1,pid=%d,%s'):format(mutelr,p.pid,p['script-opts']),'--audio-device='..device}}) end end end  --mutelr & audio-device VARY.
    mpv=nil
end
mp.register_event('start-file',start_file) 

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
    if not (p.path and is_controller) then return  --NOT STARTED YET.
    elseif property and not timers.mute:is_enabled() then timers.mute:resume() --START TIMER OR ELSE TOGGLE.  DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute IF seeking.
    else OFF,map = not OFF,1-map --TOGGLE:  1,0 = ON,OFF 
        if OFF then mp.add_timeout(.4,function() txt.mute=OFF end) --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command! THE EXACT timeout COULD BE A NEW option.  GRAPH REPLACEMENT INTERRUPTS PLAYBACK.
        else                                     txt.mute=OFF end  --INSTANT UNMUTE.
        
        if not target then _,error_input = mp.command(('af-command %s map %d astreamselect'):format(label,map)) end  --NULL-OP TO ACQUIRE target.
        target=target or     error_input and '' or 'astreamselect'   --OLD MPV OR NEW. v0.37.0+ SUPPORTS TARGETED COMMANDS.
        
        mp.command(('af-command %s map %d %s'):format(label,map,target))  --NO unpause_on_toggle.
        clock_update() end --INSTANT clock_update, OR IT WAITS TO SYNC.
end
for key in (o.key_bindings):gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_aspeed_'..key, on_toggle)  end 

function clock_update()                        
    if clock then if OFF then clock:remove() --OFF SWITCH.  COULD ALSO BE MADE SMOOTH BY VARYING {\\alpha##} IN o.clock.
        else timers.osd:resume()  --KILLED @os_sync.
             clock_index = o.clocks.duration and round((os.time()+o.clocks.offset+1)/o.clocks.duration)%#clocks+1 or 1  --BTWN 1 & #clocks.  SMOOTH TRANSITIONS (& SMOOTH TOGGLE) BTWN STYLES SEEMS TOO DIFFICULT. 
             clock.data  = os.date(clocks[clock_index]):gsub('{}0','{}')  --REMOVE LEADING 0 AFTER "{}" NULL-OP STYLE CODE.  
             for _,Day in pairs(Days) do clock.data=(clock.data):gsub(Day,DICTIONARIES[clock_index][Day]) end
             clock:update() end end
end

timers  ={  --CARRY OVER IN MPV PLAYLIST.
    mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end ),   --mute TIMER TIMES. 0s ALSO VALID. 
    osd =mp.add_periodic_timer(1,clock_update),  --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS USUALLY IRRELEVANT TO audio.
}
timers.mute.oneshot=1
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

function property_handler(property,val)  --CONTROLLER WRITES TO txtfile, & SUBPROCESSES READ FROM IT.  ONLY EVER pcall, FOR RELIABLE INSTANT write/SIMULTANEOUS io.remove.
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
        if not o.mpv[1] or not p.path or not property and txt.speed>0 and p.a then return  --return CONDITIONS.  OVERRIDE: NO SUBPROCESSES.  OR NOT STARTED YET.  OR ELSE IT'S THE auto IDLER, TO STOP timeout WHEN SPEED=0 (UNLESS JPEG). THE IDLER SHOULD ALWAYS BE RUNNING FOR RELIABILITY. PURE JPEG MAYBE PART OF A PLAYLIST (INTERMISSION BTWN FILES).
        elseif o.meta_osd and samples_time then mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    \t'),o.meta_osd) end   --TAB EACH STAT (TOO MANY LINES), FOR osd.  samples_time CORRESPONDS TO NEW OBSERVATION.
        
        txtfile=io.open(txtpath,'w+')  --w+=ERASE+WRITE  w ALSO WORKS.  MACOS-11 (DIFFERENT LUA VERSION) REQUIRES txtfile BE WELL-DEFINED.
        txtfile:write( ('%s\n%d\n%d\n%s\n%s\n%s\n%s\n'):format(  --CONTROLLER REPORT.  SECURITY PRECAUTION: NO property NAMES, OR ELSE AN ARBITRARY set COULD HOOK A YOUTUBE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.  
            p.path,
            p.a and p.a.id or 1,  --id=1 BEFORE YOUTUBE LOADS. a.id MAYBE MORE RELIABLE THAN aid (lavfi-complex BUG). 
            (txt.mute or p.mute) and 0 or p.volume or 0,  --RANGE [0,100]. OFF-SWITCH & mute.  " or 0" FOR 32-BIT RELIABILITY.
            txt.speed,
            round(os_time ,.001), --MILLISECOND PRECISION LIMITER.
            round(time_pos,.001), 
            p.priority or '' ) )  --'' FOR UNIX.
        txtfile:close()  --EITHER flush() OR close(). 
        return end  --CONTROLLER ENDS HERE.  SUBPROCESSES BELOW.
        
    txt.os_time=txt.os_time or os_time  --INITIALIZATION. SUBPROCESSES WILL quit IF txtfile NEVER COMES INTO EXISTENCE.
    Dos_time,txtfile = os_time-txt.os_time,io.open(txtpath)  --'r' MODE, 'r+' ALSO WORKS.  ALTERNATIVE io.lines RAISES ERROR.  Δ INCOMPATIBLE WITH mpv.app.
    if Dos_time>o.timeouts.quit  then mp.command('quit') end --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout.  txtfile CAN'T TELL WHEN TO quit, BECAUSE SOME SUBPROCESSES WOULD quit WITHOUT THE OTHERS.
    if Dos_time>o.timeouts.pause or not txtfile then mp.set_property_bool('pause' ,1) end  --INSTEAD OF EXITING, MERELY MUTE.
    if not txtfile then return end  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.
    
    lines    = txtfile:lines() --ITERATOR RETURNS 0 OR 7 LINES, AS function. 
    txt.path = lines()         --LINE1=path
    if not txt.path then txtfile:close()  --SOMETIMES BLANK.  close MAY BE NEEDED FOR RELIABILITY.
        return 
    elseif txt.path~=p.path then mp.commandv('loadfile',txt.path) end  --commandv FOR FILENAMES.  FLAGS INCOMPATIBLE WITH MPV-v0.34.
    
    for line in ('aid volume speed os_time time_pos'):gmatch('[^ ]+') do txt[line]=lines()+0 end  --LINES 2→6
    Dos_time,txt.priority = os_time-txt.os_time,lines()  --RECOMPUTE Dos_time.  LINE7=priority
    txt.speed   = (txt.path~=p.path or  Dos_time>o.timeouts.pause) and 0 or txt.speed  --loadfile PAUSED. 0 MEANS PAUSE.
    target_pos  = txt.time_pos+Dos_time*txt.speed  --=Δtime_pos=Δos_time*speed
    time_gained = time_pos-target_pos  
    txtfile:close()  --close NEEDED, BUT RARELY (SUDDEN LAG MAY CAUSE FAILURE).
    
    if p.a.id     ~= txt.aid        then mp.set_property_number('aid'   ,txt.aid   ) end  --UNTESTED. MAY REQUIRE GRAPH REPLACEMENT?
    if p.volume   ~= txt.volume     then mp.set_property_number('volume',txt.volume) end
    if p.pause    ~= (txt.speed==0) then mp.set_property_bool('pause' ,txt.speed==0) end
    if p.priority ~= txt.priority   then mp.set_property('priority',txt.priority   ) end  --priority FOR WINDOWS.  PROPAGATING VIA TASK MANAGER NOT SUPPORTED BECAUSE MPV DOESN'T KNOW ITS OWN priority.
    
    if math.abs(time_gained)>o.seek_limit then mp.command(('seek %s absolute exact'):format(target_pos))  --absolute MORE RELIABLE.  SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN JERK ITS SPEED).  ANOTHER LINE OF CODE MAY BE NEEDED TO IMPROVE INITIAL DRUM-ROLL (FROM --idle TRIGGER).
        time_gained=0 end
    if txt.speed==0 or not (mp2os_time and samples_time) then return end --BELOW REQUIRES NON-0 TARGET speed, & ACCURATE os_time & time_pos.  auto TIMER ENDS HERE BECAUSE IT DOESN'T KNOW samples_time.
    
    speed=txt.speed*(1-time_gained/.5)*(1+math.random(-o.max_random_percent,o.max_random_percent)/100)  --time_gained→0 OVER NEXT .5 SECONDS IN time-pos (astats UPDATE TIME). +-RANDOM EXTRA.  RANDOM BOUNDS [.9,1.1] MAYBE SHOULD BE [1/1.1,1.1]=[.91,1.1]. 1% SKEWED TOWARDS SLOWING IT DOWN.
    speed=math.min(math.max( speed , txt.speed/o.max_speed_ratio ), txt.speed*o.max_speed_ratio )  --speed LIMIT RELATIVE TO CONTROLLER.  LUA DOESN'T SUPPORT math.clip(#,min,max)=math.min(math.max(#,min),max)
    mp.set_property_number('speed',speed)
end
for property in ('mute pause seeking volume speed priority current-tracks/audio af-metadata/'..label):gmatch('[^ ]+')        --INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall.  BOOLS, NUMBERS, string & TABLES.
    do mp.observe_property(property,          'native',function(property,val) pcall(property_handler,property,val)  end) end --TRIGGERS INSTANTLY.  astats TRIGGERS EVERY HALF A SECOND, ON playback-restart, frame-drop-count & shutdown.
timers.auto=mp.add_periodic_timer(auto_delay,          function(            ) pcall(property_handler             )  end)     --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.
mp.observe_property('audio-params/samplerate','number',function(property,val) p.samplerate,initial_time_pos = val,nil end)   --samplerate MAY DEPEND ON lavfi-complex.  ALSO RESET SAMPLE COUNT.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----SCRIPT WRITTEN TO TRIGGER AN ERROR ON PURPOSE ON OLD MPV. MORE RELIABLE THAN USING VERSION NUMBERS INSTEAD.
----BUG: SUBPROCESSES TOO SLOW TO seek THROUGH LONG YOUTUBE VIDEOS. FEEDBACK COULD BE USED TO TOGGLE OFF (CHILDREN COULD ALSO WRITE TO txtfile). 
----autospeed.lua IS A DIFFERENT SCRIPT FOR VIDEO speed, NOT AUDIO. "autotempo.lua" OR "atempo.lua" MIGHT BE GOOD NAMES.
----A FUTURE SMOOTH TOGGLE COULD WORK USING volume & amix INSTEAD OF astreamselect.  astats SHOULDN'T EVEN BE THERE IN MPV-v0.38...
----GRAND-CHILD SUBPROCESSES COULD WORK FOR SURROUND SOUND. EACH CHILD LAUNCHES ITS OWN CHILDREN TO COVER ALL device CHANNELS.  BUT STEREOS ARE CHEAPER!  CODING FOR A SURROUND SOUND SOURCE SIGNAL IS EVEN MORE COMPLICATED. 
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY MAY BE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET. I HAVE A PIPE VERSION OF THIS SCRIPT BUT PREFER txtfile.  INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----loudnorm = I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----volume   = volume:...:eval  (DEFAULT 1:once)  POSSIBLE TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.  COULD BE USED FOR SMOOTH TOGGLE (ALTERNATIVE TO astreamselect), BECAUSE IT CAN VARY volume WITHIN amix.
----aformat  = sample_fmts:sample_rates  [u8 s16 s64]:Hz  OPTIONAL ALTERNATIVE TO aresample.  OUTPUTS CONSTANT samplerate → astats.  s16=SGN+15BIT (-32k→32k), CD. u8 CAUSES HISSING.  
----acompressor      SMPLAYER DEFAULT NORMALIZER.
----firequalizer OLD SMPLAYER DEFAULT NORMALIZER.
----aresample    (Hz)  OPTIONAL.  OUTPUTS CONSTANT samplerate → astats.

----SIERRA LEONE, GABON, CHAD & COLOMBIA MISSING.  THE FORMER 2 ARE SIMILAR: SIMPLE TRICOLOR TRIBARS.  
----MORE CLOCK STYLES.  TOO MANY CHARGED FLAGS, SO PURE TRICOLORS OR BICOLORS ONLY.  MISSISSIPPI STATE FLAG MIGHT WORK TOO (1 MISSISSIPPI | 2 MISSISSIPPI | 3 MISSISSIPPI).  A SEPARATE "clock.lua" SCRIPT COULD GET THEM ALL EXACTLY RIGHT. RESYNCING THE EXACT TICK EVERY 30s USES 0% CPU.  AN UKRAINIAN/POLISH STYLE MIGHT REQUIRE VERTICALLY SPLITTING THE OSD IN HALF, TO COLOR IT.
        -- "OSSETIA           WHITE ◙ RED    ◙ GOLD  <1M  {\\an3\\b1\\fs37\\bord0\\c0}%a\\N{\\fs55\\bord3\\cFFFFFF}%I{     \\c2000C1}\\N%M{\\c00D7FF}\\N%S',  --REPUBLIC INSIDE RUSSIA.
        -- "FRANCE            BLUE  : WHITE  : RED   68M  {\\an3\\b1\\fs37\\bord0\\c0}%a\\N{\\fs55\\bord3\\cA45500}%I{\\bord0\\c0}:{\\bord3\\cFFFFFF}%M{\\bord0\\c0}:{\\bord3\\c3541EF}%S",  --BLACK : INSTEAD OF SPACEBARS.  ALTERNATIVE DESIGN INTERFERES WITH COLORS.
        -- "RUSSIA            WHITE ◙ BLUE   ◙ RED  147M  {\\an3\\b1\\fs55\\bord3\\cFFFFFF}%I\\N{\\cA73600}%M\\N{\\fs37\\bord0\\c0}%a {\\fs55\\bord3\\c1827D6}%S",  --Day ON BOTTOM-LEFT, INSTEAD OF ON-TOP. (Day & SECS OPPOSITE WAY AROUND.)
        -- "BELGIUM   BELGIË  BLACK   YELLOW   RED   12M  {\\an3\\b1                        \\fs55\\bord1\\c0     }%I{\\c24DAFD\\bord3} %M{       \\c4033EF  } %S",  --BLACK PRIMARY (THIN BORDER), LIKE GERMANY.  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  CAN RECITE COUNTRIES (BELGIUM CAPITAL).  SECS ARE THE CORNERSTONE (ANCHOR).  CAN USE ":" OR " " BTWN DIGITS, BUT CODES LONGER & LESS SYMMETRIC WITH VERTICALS.
        -- "GERMANY           BLACK ◙ RED    ◙ GOLD  85M  {\\an3\\b1                        \\fs55\\bord1\\c0     }%I{\\bord3\\c00FF}\\N%M{\\c00CCFF  }\\N%S",  --WITHOUT Day.
        -- "MEXICO            GREEN : WHITE  : RED        {\\an3\\fs55\\bord2\\c476800}%I{\\bord0\\c0}:{\\bord2\\cFFFFFF  }%M{\\bord0\\c0}:{\\bord2\\c2511CE}%S{\\fs33\\bord0\\c0\\be1} %a", --ITALY SIMILAR. Day ON RIGHT.
        -- "ALGERIA           GREEN : WHITE               {\\an3\\fs55\\bord3\\c336600}%I{\\bord0\\c0}:{\\bord3\\cFFFFFF}%M{\\fs33\\bord0\\c0\\b1} %p",  --BIBAND.                          
        -- "ANDORRA           BLUE  : YELLOW : RED        {\\an3\\fs55\\bord2\\c9F0610}%I{\\bord0\\c0}:{\\bord2\\c00DDFE  }%M{\\bord0\\c0}:{\\bord2\\c3200D5}%S{\\fs33\\bord0\\c0\\be1} %a", 
        -- "BARBADOS          BLUE  : YEL    : BLUE       {\\an3\\fs55\\bord3\\c7F2600}%I{\\bord0\\c0}:{\\bord3\\c26C7FF}{}%M{\\bord0\\c0}:{\\bord3\\c7F2600}%S{\\fs33\\bord0\\c0\\b1 } %a", --SINGLE DIGIT MINUTES FOR THIN MIDDLE-BAND?
        
