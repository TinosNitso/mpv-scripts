----ADD CLOCK TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. CLOCK TICKS WITH SYSTEM, & MAY BE COLORED & STYLED. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PATH, AID & LAG APPLY TO ALL CHILDREN. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).     ORIGINAL CONCEPT WAS TO SYNC MULTIPLE VIDEOS, BUT ONE BIG video IS SIMPLER. PRIMARY GOAL IS 10 HOUR SYNC WITH RANDOMIZATION.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER. A SMALLER STEREO ADDS MORE TREBLE (BIG CHEAP STEREOS HAVE TOO MUCH BASS).  USB→3.5mm SOUND CARDS COST AS LITTLE AS $3 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES 2*mpv.exe IN TASK MANAGER (2*2% CPU, + 50MB RAM).  EVERY SPEAKER BOX (EXCEPT PRIMARY) GETS ITS OWN YOUTUBE STREAM, ETC. ALSO FULLY WORKS IN VIRTUALBOX. 
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.

options                      = {
    key_bindings             = 'Ctrl+C F1',  --CASE SENSITIVE (Ctrl+Shift+c). DON'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO filterchain.  C IS autocrop.lua, NOT CLOCK.  Ctrl+c BREAKS.
    double_mute_timeout      = .5,  --SECONDS FOR DOUBLE-MUTE-TOGGLE (m&m DOUBLE-TAP).  0 MEANS INACTIVE.  TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    extra_devices_index_list = {},  --TRY {3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS.  1=auto  2=NORMAL DEVICE.  EITHER 1 OR 2 OVERLAPS ECHO-STYLE (AVOID).  EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS & STREAM.  INTERNAL PC SPEAKERS USUALLY COUNT AS 2.
    speed                    =      '${speed}'                             ,  --EXPRESSION FOR DYNAMIC speed CONTROL, set EVERY HALF-SECOND.  CAN USE ANY MPV PROPERTY (LIKE ${percent-pos}) IN ANY LUA FORMULA.  '${speed}' IS A NULL-OP.  TOGGLES WITH DOUBLE-mute!
    -- speed                 =      '${speed}<1.2 and ${speed}+.01 or 1'   ,  --UNCOMMENT TO CYCLE speed BTWN 1 & 1.2 OVER 10s.  PRESS BACKSPACE TO RESET BACK TO 1.  REPLACE 1.2 & 1 FOR DIFFERENT BOUNDS.
    -- speed                 = 'clip(${speed}+math.random(-1,1)/100,1,1.2)',  --UNCOMMENT TO RANDOMIZE VIDEO speed, USING A BOUNDED RANDOM WALK.  -1%,+0%,+1% EVERY HALF-SECOND, RECURSIVELY. +2% TO ADD DRIFT.
    suppress_osd             =                                         true,  --REMOVE TO VERIFY speed.  APPLIES ALSO TO CHILDREN.
    mpv                      = {  --LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE.  REMOVE THEM FOR NO CHILDREN OVERRIDE (clocks, filterchain & speed ONLY).  NO CHILDREN ON ANDROID.  A COMMAND MAY NOT BE A PATH.  FIRST MATCH SPAWNS ALL CHILDREN.  
        "mpv"                                          ,  --LINUX & SMPLAYER (WINDOWS)
        "./mpv"                                        ,  --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv"     ,  --     mpv.app     (MAY BE CASE-SENSITIVE.)
        "/Applications/SMPlayer.app/Contents/MacOS/mpv",  --SMPlayer.app     (USING TERMINAL.)
    },
    filterchain        = 'anull,dynaudnorm=g=5:p=1:m=100',  --DEFAULT=g=31:p=.95:m=10=DYNAMIC-AUDIO-NORMALIZER.  GRAPH COMMENTARY HAS MORE DETAILS.  CAN REPLACE anull WITH EXTRA FILTERS, LIKE vibrato highpass aresample.
    resync_delay       =      60,  --SECONDS. RESYNC WITH THIS DELAY.  CPU TIME GOES OFF WITH RANDOM LAG.
    os_sync_delay      =     .01,  --SECONDS. PRECISION FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    timeouts           = {quit=15,pause=5},  --CHILDREN ONLY.  DEFAULT={10,5} SECONDS   quit OR pause IF CONTROLLER BREAKS FOR THIS LONG.  THEY pause INSTANTLY ON STOP.  COULD BE RENAMED child_timeouts.  {quit,MUTE} MIGHT BE MORE ELEGANT, BUT I PREFER {quit,pause}.
    seek_limit         =     .5 ,  --SECONDS.  CHILDREN ONLY.  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    auto_delay         =     .25,  --SECONDS.  CHILDREN ONLY.  RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    max_speed_ratio    =    1.15,  --          CHILDREN ONLY.  speed IS BOUNDED BY [txt.speed/max,txt.speed*max]  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    max_random_percent =      10,  --          CHILDREN ONLY.  DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND.  EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L/R DRIFT, DUE TO LAG & HALF SECOND RANDOM WALKS BTWN SPEEDS.
    mutelr             = 'mutel',  --mutel/muter  CONTROLLER ONLY.  PRIMARY CHANNEL HAS NORMAL SYNC TO VIDEO.  HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    metadata_osd       =   false,  --true FOR audio STATISTICS (astats METADATA).  CONTROLLER ONLY.  SHOULD BE REMOVED IN FUTURE VERSION. MPV-v0.37+ SYNC PROPERLY WITHOUT IT. (IT WAS NECESSARY FOR OLD MPV.)
    options            = {         --CONTROLLER ONLY.
        'image-display-duration inf',  --DEFAULT=1  BUT inf FOR JPEG clock.
        'osd-scale-by-window    no ','osd-font "COURIER NEW"','osd-bold yes',  --DEFAULT=yes,sans-serif,no  osd-scale CAUSES ABDAY MISALIGNMENT.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS IS PROPRIETARY & INVALID ON MACOS.  BOTH FONTS INVALID ON ANDROID.
        -- 'osd-border-color   0/.5', --DEFAULT=#FF000000  UNCOMMENT FOR TRANSPARENT CLOCK FONT OUTLINE.  RED=1/0/0/1, BLUE=0/0/1/1, ETC
    },
    options_children = {
        -- 'audio-pitch-correction       no         ',  --DEFAULT=yes  UNCOMMENT FOR CHIPMUNK MODE (NO scaletempo# FILTER). WORKS OK WITH SPEECH & COMICAL MUSIC.  REDUCES CPU CONSUMPTION BY AT LEAST 5%=5*1%.  ACTIVE INDEPENDENT TEMPO SCALING FOR SEVERAL SPEAKERS USES CPU.
        'vid       no       ','vo        null       ','osc      no ','ytdl-format ba/best',  --VIDEO-ID(DEFAULT=auto) & ON-SCREEN-CONTROLLER(DEFAULT=yes)  no REDUCES CPU CONSUMPTION.  VIDEO-OUT=null BLOCKS NEW WINDOWS.  ba=bestaudio  /best FOR RUMBLE.  REMOVE THIS LINE TO SEE ALL CHILDREN. THIS SCRIPT OVERRIDES ANY ATTEMPT TO CONTROL THEM.
        'sid       no       ','keep-open yes        ','geometry 25%',  --no SUBTITLE-ID.  keep-open BECAUSE RELOADING IS BLOCKED.  geometry LIMITS CHILDREN.
        'msg-level all=error','priority  abovenormal',  --DEFAULTS all=status,normal.  BY DEFAULT SMPLAYER LOGS ALL speed CHANGES VIA CHILD terminal.  priority ONLY VALID ON WINDOWS.  
    },
    clocks       = {  --TOGGLE LINES TO INCLUDE/EXCLUDE VARIOUS STYLES FROM THE LIST.  REPETITION VALID.  CLOCKS REQUIRE VIDEO OR image.  A SIMPLE LIST OF STRINGS IS EASY TO RE-ORDER & DUPLICATE, LIKE REPEATING Yemen FOR THE ARABIC.
        duration = 2, --SECONDS, INTEGER.  0/nil MEANS NO CLOCK.  TIME PER CLOCK STYLE THROUGHOUT CYCLE.  STYLE TICKS OVER EVERY SECOND SECOND. (ON THE DOUBLE.)
        offset   = 0, --SECONDS, INTEGER.  CHANGE STYLE ON EVENS OR ODDS? 0=EVEN.  ALL SMPLAYER INSTANCES HAVE SAME CLOCK @SAME TIME.
        -- no_locales          = true,  --UNCOMMENT FOR English ONLY.  REPLACE [AbDays] WITH [ABDAYS] FOR UPPERCASE, OR [abdays] FOR LOWERCASE. EACH CLOCK CAN DICTATE ITS OWN AbDays.  VERTICAL SPELLING ALSO, LIKE Sun→S◙u◙n.
        -- DIRECTIVES_OVERRIDE = true,  --UNCOMMENT TO DISPLAY ALL os.date DIRECTIVE CODES & THEIR CURRENT VALUES (SPECIAL CLOCK). MAY DEPEND ON LUA VERSION.  EXAMPLES: %I,%M,%S,%a,%p,%H,%n = HRS(12),MINS,SECS,Day,A/PM,HRS,RETURN  %n(♪) & \\N(◙) ARE DIFFERENT.  %n ENABLES NEW NUMPAD ALIGNMENT, WHICH COULD HELP WITH A MADAGASCAR STYLE.
----    "        COUNTRY             HOUR     MINUTE   SECOND  POPULATION  [    AbDays            '-'=HALF-SPACE ]  {\\STYLE OVERRIDES}              ◙              ↓↓(CLOCK SIZE)                 %DIRECTIVES              ",  --"{" REQUIRED, & EVERYTHING BEFORE IT IS REMOVED.  {} ALONE REMOVES LEADING 0 FOLLOWING IT.  AbDays (ABBREVIATED DAYS) LOCALES START WITH Sun (BUT Mon IN REALITY), & CAN BE REPLACED WITH ANYTHING (1 LOTE CAN BE COPIED OVER ALL THE OTHERS).  https://lh.2xlibre.net/locales/ FOR LOCALES, BUT GOOGLE TRANSLATE ALSO.  HALF-SPACE FAILS ON ANDROID, AS DOES FONT.
        "    BELGIUM  BELGIË         BLACK    YELLOW      RED   12M  [ Zon   Maa   Din    Woe   Don   Vri   Zat ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c     0\\fs55\\bord1}%I{\\c24DAFD\\bord3} %M{\\c4033EF         } %S",  --37=55*2/3  BLACK PRIMARY (THIN BORDER), LIKE GERMANY.  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  CAN RECITE COUNTRIES (BELGIUM CAPITAL).  %S ARE THE CORNERSTONE (ANCHOR).  CAN USE ":" OR " " BTWN DIGITS.  %a COULD GO ONTOP OF MINUTES INSTEAD OF SECONDS.  
        "    ROMANIA  ROMÂNIA        BLUE     YELLOW      RED   19M  [-Du-   Lun   Mar   -Mi-   Joi  -Vi-  -Sb- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c7F2B00\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE         } %S",  --MOLDOVA & ANDORRA ALSO SIMILAR, BUT CHARGED.  Vi=FRIDAY  
        "       CHAD  TCHAD          BLUE      GOLD       RED   19M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c642600\\fs55\\bord3}%I{\\c  CBFE       } %M{\\c300CC6         } %S",  --GOLD HAS SLIGHTLY LESS GREEN.  IDEAL COLOR LIST MIXES AFRO & EURO FLAGS. 
        "          MALI              GREEN    YELLOW      RED   21M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c3AB514\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE         } %S",  --SENEGAL SIMILAR BUT CHARGED.  
        "     GUINEA  GUINÉE         RED      YELLOW    GREEN   14M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c2611CE\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c609400         } %S",  --RED IS RIGHT, EXCEPT FOR GUINEA!
        "         NIGERIA            GREEN    WHITE     GREEN  231M  [ Sun   Mon   Tue    Wed   Thu   Fri   Sat ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c  8000\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c  8000         } %S",  --BICOLOR TRIBAND.  WHITE ALWAYS IN THE MIDDLE. ORDER ALIGNS WHITES & REDS.  
        "IVORY COAST  CÔTE D'IVOIRE  ORANGE   WHITE     GREEN   31M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c  82FF\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c449A00         } %S", 
        "    IRELAND  ÉIREANN        GREEN    WHITE    ORANGE    7M  [ Domh  Luan  Máir   Céad  Déar  Aoin  Sath]  {\\an3\\c     0\\fs28\\bord0}%a\\N{\\c629B16\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3E88FF         } %S",  --28~=55/2 FOR LENGTH 4.  OFFICIALLY Máirt & Aoine SHOULD BE LENGTH 5. BUT IT'S RISKY TO DO ANYTHING DIFFERENTLY. 
        "      ITALY  ITALIA         GREEN    WHITE       RED   59M  [ Dom   Lun   Mar    Mer   Gio   Ven   Sab ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c458C00\\fs55\\bord3}%I{\\cF0F5F4       } %M{\\c2A21CD         } %S",  --MEXICO SIMILAR BUT CHARGED. CATHOLIC, LIKE IRELAND.  Mar=TUESDAY IS THIRD, LIKE MARCH.  Mer ALSO THIRD (Wed).  Domino's ON SUNDAY!
        "         FRANCE             BLUE     WHITE       RED   68M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\cA45500\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3541EF         } %S",  --"dim." ALSO FRENCH (CAN USE DOTS).  ALL LOWERCASE WOULD IMPROVE SYMMETRY, BUT NOT THE DOT!
        "       PERU  PERÚ           RED      WHITE       RED   34M  [ Dom   Lun   Mar    Mié   Jue   Vie   Sáb ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c2310D9\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c2310D9         } %S",  --BICOLOR.  CANADA MIGHT BE SIMILAR BUT WITH REDUCED HRS & SECS fs.  
        "    AUSTRIA  ÖSTERREICH     RED    ◙ WHITE  ◙    RED    9M  [ Son   Mon   Die   -Mi-   Don   Fre   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c2E10C8\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c2E10C8       }\\N%S",  --BICOLOR.  HORIZONTAL TRIBAND (VERTICAL TAB).  LIKE A TAB FROM THE FLAG.  BLACK Day IS POSITIONED WITH BLACK BAR ON SCREEN-RIGHT.
        "    HUNGARY  MAGYARORSZÁG   RED    ◙ WHITE  ◙  GREEN   10M  [ Vas   Hét   Ked    Sze  -Cs-   Pén   Szo ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c3929CE\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c507047       }\\N%S",
        " LUXEMBOURG  LËTZEBUERG     RED    ◙ WHITE  ◙   CYAN   <1M  [ Son   Mon   Die   -Mi-   Don   Fre   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c4033EF\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\cE0A300       }\\N%S",
        "NETHERLANDS  NEDERLAND      RED    ◙ WHITE  ◙   BLUE   18M  [ Zon   Maa   Din    Woe   Don   Vri   Zat ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c251DAD\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c85471E       }\\N%S",  --PARAGUAY & CROATIA SIMILAR BUT CHARGED.  YUGOSLAVIA WAS CHARGED REVERSE.  AbDays SHOULD BE LENGTH 2, BUT 3'S BETTER.
        "      Yemen  اليمن           ‎اRED    ◙ WHITE  ◙  BLACK   34M  [‎-أحد-‎  ‎اثنن‎  ‎-ثلاث-‎  ‎ربعا‎   ‎خميس  ‎جمعة‎ ‎-سبت-‎]  {\\an3\\c     0\\fs28\\bord0}%a\\N{\\c2611CE\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c     0\\bord1}\\N%S",  --LRM=LEFT_TO_RIGHT_MARK='‎'='\xE2\x80\x8E'  ALM (ARABIC LETTER MARK) GOES THE OTHER WAY!  ا="a" FROM اليمن="alyaman" ALSO FOR ALIGNMENT.  YEMEN REPRESENTS ARABIA, SOUTH OF SAUDI.  ARABIC & HEBREW ARE RIGHT-TO-LEFT.  AbDays SHOULD BE 1 LETTER EACH. THESE ARE PROPERLY SPACED FOR COURIER NEW BOLD.  TO VERIFY, COPY/PASTE THE LOT INTO GOOGLE TRANSLATE.
        "      SIERRA LEONE          GREEN  ◙ WHITE  ◙   BLUE    9M  [ Sun   Mon   Tue    Wed   Thu   Fri   Sat ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c3AB51E\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\cC67200       }\\N%S",
        "          GABON             GREEN  ◙ YELLOW ◙   BLUE    2M  [ Dim   Lun   Mar    Mer   Jeu   Ven   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c609E00\\fs55\\bord3}%I{\\c16D1FC     }\\N%M{\\cC4753A       }\\N%S",
        "         BOLIVIA            RED    ◙ YELLOW ◙  GREEN   12M  [ Dom   Lun   Mar    Mié   Jue   Vie   Sáb ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c1C29DA\\fs55\\bord3}%I{\\c  E4F4     }\\N%M{\\c337A00       }\\N%S",
        "        MAURITIUS       RED◙BLUE   ◙ YELLOW ◙  GREEN    1M  [ Dim   Lin   Mar    Mer  -Ze-   Van   Sam ]  {\\an3\\c3624EB\\fs37\\bord2}%a\\N{\\c6D1A13\\fs55\\bord3}%I{\\c  D6FF     }\\N%M{\\c50A600       }\\N%S",  --QUAD-COLOR QUAD-BAND.  ISLANDS NEAR MADAGASCAR.  
        "    ARMENIA  ՀԱՅԱՍՏԱՆ       RED    ◙  BLUE  ◙ ORANGE    3M  [ Կրկ   Երկ   Երք    Չրք   Հնգ   Ուր   Շբթ ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c1200D9\\fs55\\bord3}%I{\\cA03300     }\\N%M{\\c00A8F2       }\\N%S",  --FAILS ON ANDROID (7 & 11).  LOWERCASE BIGGER THAN UPPERCASE! 
        "     RUSSIA  РОССИЯ         WHITE  ◙  BLUE  ◙    RED  147M  [ Вос   Пон   Вто    Сре   Чет   Пят   Суб ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\cFFFFFF\\fs55\\bord3}%I{\\cA73600     }\\N%M{\\c1827D6       }\\N%S",  --SLOVENIA SIMILAR, BUT CHARGED. SERBIA IS CHARGED REVERSE.  THE COLORS DICTATE THE MEANING OF THE LETTERS.  AbDays SHOULD BE 2 LETTERS.
        "   BULGARIA  БЪЛГАРИЯ       WHITE  ◙ GREEN  ◙    RED    6M  [ Вос   Пон   Вто    Сре   Чет   Пят   Суб ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\cFFFFFF\\fs55\\bord3}%I{\\c  9900     }\\N%M{\\c    CC       }\\N%S",
        "  LITHUANIA  LIETUVA        YELLOW ◙ GREEN  ◙    RED    3M  [ Sek   Pir   Ant    Tre   Ket   Pen  -Št- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c13B9FD\\fs55\\bord3}%I{\\c446A00     }\\N%M{\\c2D27C1       }\\N%S",  --AbDays SHOULD BE 2 LETTERS.
        "    ESTONIA  EESTI          BLUE   ◙ BLACK  ◙  WHITE    1M  [ Püha  Esma  Teis   Kolm  Nelj  Reed  Laup]  {\\an3\\c     0\\fs28\\bord0}%a\\N{\\cCE7200\\fs55\\bord3}%I{\\c   0\\bord1}\\N%M{\\cFFFFFF\\bord3}\\N%S",  --OFFICIALLY AbDays SHOULD BE 1 LETTER.  P=SUNDAY BUT IT'S ALSO LIKE PM IN LATIN.  
        "    GERMANY  DEUTSCHLAND    BLACK  ◙  RED   ◙   GOLD   85M  [ Son   Mon   Die   -Mi-   Don   Fre   Sam ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c     0\\fs55\\bord1}%I{\\c  FF\\bord3}\\N%M{\\c  CCFF       }\\N%S",  --AbDays SHOULD BE 2 LETTERS.  SOMETIMES THE THIRD LETTER IS INVALID, BY COMPARISON TO FRENCH.
     -- "          Wedge             BIG    : MEDium : Little  tiny                                                 {\\an3                                    \\fs70\\bord2}{}%I{\\fs42          }:%M{\\fs25 }:%S{\\fs15} %a",  --''  RATIO=.6  DIAGONAL PATTERN.  MY FAV.
----    STYLE CODES: \\,N,an#,fs#,bord#,c######,fscx## = \,NEWLINE,ALIGNMENT-NUMPAD,FONT-SIZE(p),BORDER(p),COLOR,FONTSCALEX(%)  (DEFAULT an0=an7=TOPLEFT)    MORE: alpha##,b1,shad#,be1,i1,u1,s1,fn*,fr##,fscy## = TRANSPARENCY,BOLD,SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEY(%)  EXAMPLES: USE {\\alpha80} FOR TRANSPARENCY. USE {\\fscx130} FOR +30% IN HORIZONTAL.  A TRANSPARENT clock CAN BE BIGGER. be ACTS LIKE SEMI-BOLD.  
    },
    params = '{N=0,pid}',  --DECLARATION OF PARAMETERS.  N=0 is_controller.  N=1 IS FIRST-CHILD & PROVIDES FEEDBACK.  PARENT PROCESS-ID DETERMINES txtfile THE CHILDREN READ FROM.  ALTERNATIVE IS TO DEFINE ENVIRONMENTAL VARIABLE/S FOR CHILDREN, BUT o.params IS SIMPLER.
}
o,p,m,timers = options,{},{},{}      --TABLES.  p=PROPERTIES  m={map,path}=MEMORY  timers={mute,auto,os_sync,osd}
require 'mp.options'.read_options(o) --mp=MEDIA_PLAYER  ALL options WELL-DEFINED & COMPULSORY.

for  opt in ('seek_limit resync_delay params'):gmatch('[^ ]+')                            --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME LUA VERSION, BUILT DIFFERENT).
do o[opt]      = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end --string→number/table: '1+1'→2  load INVALID ON MPV.APP. 
for  property in ('pid audio-device scripts audio-device-list'):gmatch('[^ ]+')           --nil number string LISTS
do p[property] = mp.get_property_native(property) end
command_prefix = o.suppress_osd  and 'no-osd'    or ''
label,N        = mp.get_script_name(),o.params.N  --label=aspeed  FILENAME MUSTN'T HAVE SPACES, BUT ITS DIRECTORY CAN.  N ABBREVIATES CHILD# (0, 1, OR MORE COME IN PAIRS).
for _,opt in pairs(N==0 and o.options or o.options_children)
do command     = ('%s%s set %s;'):format(command or '',command_prefix,opt) end
command        = command and mp.command (command) --ALL SETS IN 1.  

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR txtfile.
    D = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  (MIN MAX MIN MAX)  ENFORCES speed LIMIT.
math.randomseed(p.pid)  --OTHERWISE CHILD TEMPO MAY BE SAME OR PREDICTABLE.

clocks,abdays,LOCALES,txt = {},{},{},{}  --INITIALIZE LISTS. LOCALES IS LIST OF SUB-TABLES, FOR LOTE. NEVER USED BY CHILDREN (UNLESS THEY ALSO HAVE A clock).  txt FOR property_handler.
p['script-opts'] = mp.get_property('script-opts')        --string FOR SPAWNING MAY BE BLANK.  ytdl_hook POTENTIALLY UNSAFE & ONLY EVER DECLARED ONCE (IN TASK MANAGER).  
o.timeouts.quit  = (o.timeouts.quit  or o.timeouts[1] or 10)+0 --DEFAULT=10  SECONDS  +0 CONVERTS→number
o.timeouts.pause = (o.timeouts.pause or o.timeouts[2] or  5)+0 --DEFAULT= 5 
directory        = mp.command_native({'expand-path',(require 'mp.utils'.split_path(p.scripts[1]))}) --command_native EXPANDS '~/', REQUIRED BY io.open.  BRACKETS CAPTURE FIRST RETURN.  ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
                         
for abday in ('Sun Mon Tue Wed Thu Fri Sat'):gmatch('[^ ]+') do table.insert(abdays,abday) end    --DEFAULT=English
abdays                   = (o.clocks.no_locales or o.clocks.DIRECTIVES_OVERRIDE) and {} or abdays --OVERRIDES.  EVERYTHING PERTAINING TO abdays BECOMES A NULL-OP.
for  _,clock in pairs(o.clocks) 
do  if     type(clock)   == 'string' --STRINGS ONLY.  SPLITTING THE STRINGS IN HALVES OR THIRDS WOULD BE MORE COMPLICATED IN options.
    then LOCALE,clock    = {},clock: gsub('◙','\\N')         --◙ LOOKS BETTER THAN \N (UP TO END-USER).  LOCALE HAS ABDAYS AS KEYS.
        table.insert(clocks, (clock: gsub('[^{]*','',1)))    --EXTRA BRACKETS CAPTURE FIRST gsub RETURN.  '*' MAY ELIMINATE NOTHING BEFORE LEADING {.  ONCE ONLY.  
        gmatch           =   (clock: gmatch('%[.*%]')() or ''):gmatch('[^%[ %]]+')  --ABDAY ITERATOR. '.*' MEANS LONGEST MATCH OR NOTHING.  "[]" ARE MAGIC.
        for _,abday in pairs(abdays) 
        do LOCALE[abday] = (gmatch() or abday):gsub('%-%-','‎ ‎'):gsub('%-','{\\fscx50}‎ ‎{\\fscx100}') end --LOCALE OR DEFAULT.  "-" IS MAGIC, WORTH HALF-SPACE.  BUT EACH SPACE HAS LRM ON EITHER SIDE FOR PROPER ALIGNMENT.
        table.insert(LOCALES,LOCALE) end end  

if o.clocks.DIRECTIVES_OVERRIDE  
then clocks            = {''}           --ONLY 1.
    for N              = 0,128          --LOOP OVER ALL POSSIBLE BYTECODE FROM 0→0x80.
    do char            = string.char(N) --A,a = 0x41,0x61 = 65,97  
       DIRECTIVE       =   '%'..char
       invalid         = os.date(DIRECTIVE):sub(1,1)=='%'  --os.date RETURNS %char IF INVALID (SKIP). 
       clocks[1]       = clocks[1]..(invalid and ''   or (char=='a' and '\n' or '')..('%%%s="%s"  '):format(DIRECTIVE,DIRECTIVE)) end end  --NEWLINE @a.
clocks                 = (o.clocks.duration  or 0)==0 and {} or clocks  --duration=nil/0 MEANS clock=nil.
if N==0 then clock     = clocks[1] and mp.create_osd_overlay('ass-events')  --ass-events IS THE ONLY VALID OPTION.  AT LEAST 1 CLOCK OR nil.  COULD ALSO SET res_x & res_y FOR BETTER THAN 720p FONT QUALITY.
    o.auto_delay,devices,script = .5,{p['audio-device']},('%s/%s.lua'):format(directory,label)  --CONTROLLER auto_delay EXISTS ONLY TO STOP timeout.  devices=LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device).  "wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).  "/" FOR WINDOWS & UNIX. .lua COULD BE .js FOR JAVASCRIPT.  
    
    for _,index in pairs(o.extra_devices_index_list)  --ESTABLISHES devices WHICH ACTIVATE (IF mpv).  DUPLICATES ALLOWED.  WOULDN'T MAKE SENSE FOR CHILDREN.
    do insert_name     = p['audio-device-list'][index] and table.insert(devices,p['audio-device-list'][index].name) end
    for _,command in pairs(o.mpv)                                                                              --CONTROLLER command LOOP. 
    do  mpv            =     mpv or mp.command_native({'subprocess',command}).error_string~='init' and command end --error_string=init IF INCORRECT.  BREAKS ON FIRST CORRECT command.  subprocess RETURNS NATIVELY INTO LUA, SO IS MORE ELEGANT THAN run IN THIS CASE.
    for N,audio_device in pairs(mpv and devices or {}) do for mutelr in ('mutel muter'):gmatch('[^ ]+')   --ONLY IF mpv.  DON'T LAUNCH ON PRIMARY device CHANNEL. 
        do script_opts = (N>1 or mutelr~=o.mutelr) and ('%s-mutelr=%s,%s-params="{N=%d,pid=%d}",%s'):format(label,mutelr,label,N,p.pid,p['script-opts']) --PREFIX label-.  FIRST-BORN IS SPECIAL.  mutelr & audio-device VARY.  CHILDREN WITH 2 MOUTHS MAY BE MUTED LEFT OR RIGHT. BUT INTERNAL PC SPEAKERS SHOULD COUNT AS ONLY 1.
            run_mpv    = script_opts and mp.commandv('run',mpv,'--idle','--audio-device='..audio_device,'--script='..script,'--script-opts='..script_opts) end end end  --CHILD SPAWN.  commandv FOR SYMBOLS.  ALSO LAUNCH ON JPEG, FOR playlist-next.  idle MUST BE SET IN ADVANCE.
txtpath                = ('%s/%s-pid%d.txt'):format(directory,label,o.params.pid or p.pid)  --txtfile INSTEAD OF PIPES.
m.map                  = (N>0 or mpv) and 1 or 0  --graph SWITCH.  0,1 = OFF,ON  ON MEANS mutelr.  CHILDREN ALWAYS ON.  NEVER MUTE WITHOUT CHILDREN.


graph=('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d'):format(o.filterchain,o.mutelr)

----lavfi         = [graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT. 
----stereotools   = ...:mutel:muter DEFAULT=...:0:0  (BOOLS)  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED STEREO FOR RELIABILITY. ALSO MUTES EITHER SIDE. FFMPEG-v4 INCOMPATIBLE WITH softclip.
----dynaudnorm    = ...:g:p:m       DEFAULT=...:31:.95:10  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). A 2 STAGE PROCESS MIGHT BE POSSIBLE (SMALL g → BIG g).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. IT'S USED SEVERAL TIMES SIMULTANEOUSLY: EACH SPEAKER + VARIOUS GRAPHICS (lavfi-complex).  IT CAN BE TESTED WITH VARIOUS FILTERS BEFORE IT.
----astats        = length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT WAS BASIS FOR 10 HOUR SYNC. TESTED @OVER 1 BILLION. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. MPV-v0.38 CAN SYNC ON ITS OWN WITHOUT astats (BUT NOT v0.36).
----astreamselect = inputs:map      IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH. SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.
----anull           PLACEHOLDER.
----asplit          [ao]→[0][1]=[no-mutelr][mutelr]


function file_loaded()  --ALSO @seek.
    if map_restart == m.map then return end --PREVENTS UNNECESSARY REPLACEMENTS.
    map_restart     = m.map                 --map@playback-restart
    mp.commandv('af','pre',('@%s:lavfi=[%s]'):format(label,graph):format(m.map))  --graph INSERTION.  commandv FOR BYTECODE.  
end
mp.register_event('file-loaded',file_loaded)  --RISKY TO INSERT GRAPH SOONER ON OLD FFMPEG.
mp.register_event('seek'       ,file_loaded) 
mp.register_event('shutdown'   ,function()os.remove(txtpath)end)

function playback_restart() 
    os_sync()
    for N            = 1,4 do mp.add_timeout(2^N,os_sync) end  --RESYNC ON EXPONENTIAL TIMEOUTS, DUE TO HDD LAG. 0 2 4 8 16 SECONDS.
    initial_time_pos = nil --FOR OLD MPV, RESET SAMPLE COUNT.
    apply_astreamselect()  --SPECIAL CASE: FOR TOGGLE DURING seeking, BUT AFTER seek (ALREADY RELOADED).
end  
mp.register_event('playback-restart',playback_restart)

function apply_astreamselect(map)  --@playback-restart, @on_toggle & @property_handler.
    map       = map or (N~=0 or not OFF and mpv and txt.seeking=='no') and 1 or 0  --DEDUCE INTENDED map.  CHILDREN ALWAYS MUTED.  1 INVALID WITHOUT CHILDREN.  ALWAYS UNMUTE WHEN FIRST-BORN IS seeking.
    if m.map == map then return end
    m.map     = map
    mp.command(('af-command %s map %d %s'):format(label,m.map,target or ''))  --target ACQUIRED @samples_time.
end

function on_toggle()  --@key_binding & @double_mute.  INSTA-TOGGLE (SWITCH). CHILDREN MAINTAIN SYNC WHEN OFF.  MUST TOGGLE FOR JPEG TOO!
    OFF         = not OFF             --INSTANT UNMUTE IN txtfile.
    mp.add_timeout(   OFF and .4 or 0,function() txt.mute=OFF end)  --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command!  ALTERNATIVE GRAPH REPLACEMENT INTERRUPTS PLAYBACK.  A FUTURE VERSION SHOULD REMOVE THIS, & NEVER USE astreamselect. volume SHOULD RESPOND FASTER.
    
    apply_astreamselect()
    clock_update() --INSTA-clock_update.
end
for key in o.key_bindings: gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_aspeed_'..key,on_toggle)  end 

function clock_update()  --@os_sync & @on_toggle.
    clock_remove = clock and OFF and clock:remove()  --clock OFF SWITCH.  COULD BE MADE SMOOTH BY VARYING {\\alpha##} IN clock.data.
    if OFF  or not clock then return end
    
    timers.osd:resume()  --KILLED @os_sync.
    clock_index   = round((os.time()+o.clocks.offset+1)/o.clocks.duration)%#clocks+1 or 1  --BTWN 1 & #clocks.  SMOOTH TRANSITIONS BTWN STYLES SEEMS TOO DIFFICULT.  THE TIMEFROM1970 IS NEEDED JUST TO DECIDE WHICH STYLE! MPV MIGHT HAVE THE SAME CLOCK STYLE SIMULTANEOUSLY ALL OVER THE EARTH, REGARDLESS OF TIMEZONE OR DST, FOR THE SAME o.clocks.
    clock   .data = os.date(clocks[clock_index]):gsub('{}0','{}')  --REMOVE LEADING 0 AFTER "{}" NULL-OP STYLE CODE.
    for _,abday in pairs(abdays) 
    do clock.data = clock.data: gsub(abday,LOCALES[clock_index][abday]) end
    clock:update()
end
timers.osd=mp.add_periodic_timer(1,clock_update) --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS USUALLY IRRELEVANT TO AUDIO.  LOSES 6→20 MILLISECONDS/MINUTE (@TICK) WITHOUT resync.  oneshot & pcall TIMERS ARE WORSE.
clock_update()                                   --INSTANT clock.

function os_sync()  --@property_handler & @playback-restart.  RUN 10ms LOOP UNTIL SYSTEM CLOCK TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC CHILDREN. 
    if not time1 then timers.os_sync:resume()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH). 
        time1 = os.time()  
        return end
    sync_time = os.time()  --INTEGER SECONDS FROM 1970, @EXACT TICK OF CLOCK.
    
    if sync_time>time1 then mp2os_time,time1 = sync_time-mp.get_time(),nil  --",nil" REQUIRED (RARELY).  mp2os_time=os_time_relative_to_mp_clock  IS THE CONSTANT TO ADD TO MPV CLOCK TO GET TIMEFROM1970 TO WITHIN 10ms.  WARNING: os.clock WORKS EQUALLY WELL ON WINDOWS, BUT NOT UNIX+VIRTUALBOX (CPU TIME DIFFERENT).  mp.get_time()=os.clock()+CONSTANT  (WITHIN HALF A MILLISECOND.)  
        timers.os_sync:kill()
        timers.osd    :kill()  --SYNC clock TICK TO SYSTEM.  
        clock_update() end
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)

function property_handler(property,val) --ALSO @timers.auto  CONTROLLER WRITES TO txtfile, & CHILDREN READ FROM IT.  ONLY EVER pcall, FOR RELIABLE INSTANT write & SIMULTANEOUS io.remove.
    p[property or ''] = val                          --p['']=nil  DUE TO IDLER.
    a_id              = p['current-tracks/audio/id'] --aid=false WHEN LOCKED, BUT a_id=1.  lavfi-complex COMBINES MULTIPLE STREAMS.  
    
    if not mp2os_time            or  property=='speed' and set_speed     --4 return CONDITIONS.  1) AWAIT SYNC.  2) set_speed OBSERVATION ENDS HERE. 
        or N >0 and     property and property~='af-metadata/'..label     --3) CHILD OBSERVATION ENDS HERE, EXCEPT ON astats TRIGGER. CONTROLLER PROCEEDS.
        or N==0 and not property and a_id and not (p.pause or p.seeking) --4) CONTROLLER IDLER  ENDS HERE, UNLESS PAUSED/seeking OR JPEG. IT DOES write OBSERVATIONS.  seeking SAVES YOUTUBE LOAD.  A COMMON ISSUE WITH MANY DIRECT LINKS TO 1 function IS DOUBLE-NEGATIVE RETURNS.
    then return end 
    
    mp_time,p['time-pos'] = mp.get_time(),mp.get_property_number('time-pos')
    os_time          = mp2os_time+mp_time  --os_time=TIMEFROM1970  PRECISE TO 10ms.
    samples_time     =  property=='af-metadata/'..label  and val['lavfi.astats.Overall.Number_of_samples']/p['audio-params/samplerate']  --ALWAYS A HALF INTEGER, OR nil.  TIME=sample#/samplerate  (SOURCE SAMPLERATE) 
    target           = target or samples_time and (mp.command(('af-command %s map %d astreamselect'):format(label,m.map)) and 'astreamselect' or '')  --NEW MPV OR OLD. v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  TARGETED COMMANDS WERE INTRODUCED WITH time-pos BUGFIX.  astreamselect ONLY WORKS AFTER samples_time.
    resync           = (property=='frame-drop-count'     or  sync_time and os_time-sync_time>o.resync_delay) and os_sync() --ON_LAG & EVERY MINUTE.
    initial_time_pos =  property~='frame-drop-count'     and initial_time_pos or target=='' and samples_time and samples_time>20 and p['time-pos']-samples_time --FOR OLD MPV.  EXCESSIVE LAG RESETS SAMPLE COUNT.  v0.36 CAN'T SYNC WITHOUT astats. BOTH MP4 & MP3 LAGGED BEHIND THE CHILDREN. time-pos, playback-time & audio-pts WORKED WELL OVER 1 MINUTE, BUT NOT 1 HOUR.  SAMPLE COUNT STABILIZES WITHIN 20s (YOUTUBE+lavfi-complex). IT'S ALWAYS A HALF-INTEGER @MEASUREMENT.  initial_time_pos=initial_time_pos_relative_to_samples_time  THIS # STAYS THE SAME FOR THE NEXT 10 HOURS. 
    p['time-pos']    = initial_time_pos and samples_time and initial_time_pos+samples_time  or p['time-pos'] or 0  --0 DURING YOUTUBE LOAD TO STOP timeout.  OLD MPV USES NEW METRIC WHOSE CHANGE IS BASED ON astats (METRIC SWITCH). 
    txtfile          = io.open(txtpath) --MODES 'r' OR 'r+'.  ALTERNATIVE io.lines RAISES ERROR.  CONTROLLER READS TOO, FOR FEEDBACK. 
    if txtfile       
    then lines       = txtfile: lines() --ITERATOR RETURNS 0 OR 7 LINES, AS function. 
        txt.path     =          lines() --LINE1=path  SOMETIMES BLANK.
        for line in (txt.path and 'aid volume speed os_time time_pos seeking' or ''):gmatch('[^ ]+')  --LINES 2→7, IF LINE1.
        do txt[line] =          lines():gsub('\r','')   end --\r (RETURN BYTE) ENDS ALL LINES, ON WINDOWS.
        txtfile:                close()                 end --NEEDED FOR win32 os.remove@shutdown (DEPENDS ON BUILD.)
    if  N           == 0 
    then osd_message = samples_time        and not OFF  and o.metadata_osd and mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    ')) --TAB EACH STAT (TOO MANY LINES).
        speed        = samples_time        and not OFF  and loadstring('return '..mp.command_native({'expand-text',o.speed}))() or p.speed                  --TRIGGERED ON samples_time, EVERY HALF-SECOND.  TOGGLE APPLIES.
        double_mute  = (property=='mute'   or property=='current-tracks/audio/selected')  and m.map and (not timers.mute:is_enabled() and (timers.mute:resume() or 1) or on_toggle())  --ANDROID MUTES BY DE-SELECTING CURRENT-TRACK.  m.map AWAITS file-loaded.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).
        txt.volume   = (txt.mute or p.mute or not a_id) and 0 or p.volume --OFF-SWITCH & mute.  AUDIO STREAM ITSELF MAY CYCLE ON & OFF WITH A KEYBIND, WITH SMOOTH PLAYBACK.
        txt.speed    = (p.pause  or p.seeking         ) and 0 or speed    --seeking→pause MIGHT FIX A YOUTUBE STARTING GLITCH.  
        
        txt.path   ,txt.aid      = p.path or ''       , a_id or 'no'              --BLANK & no @load-script.
        txt.os_time,txt.time_pos = round(os_time,.001), round(p['time-pos'],.001) --ms PRECISION.
        apply_astreamselect() end  --BUGFIX FOR SLOW FIRST-CHILD, AUTO-DEDUCES map.  LONG YOUTUBE VIDEOS TEND TO GLITCH.  ALL FAMILY MEMBERS HAVE 2 MOUTHS - THE PARENT UNMUTES ONE OF ITS OWN IF THE FIRST-BORN IS SLOW.  FOR TESTING, GIVE CHILD1 ITS OWN VIDEO & THEN MAKE IT seek. 
    
    seeking          = p.seeking    and 'yes'   or 'no'                              --boolean→string
    write            = N==0 and mpv or N==1     and txtfile and txt.seeking~=seeking --txtfile=nil @end-file  COULD ALSO PROVIDE FEEDBACK (write-BACK) @shutdown. (OPTIONAL.)  FEEDBACK REQUIRED DUE TO LACK OF MULTI-STREAMING.
    txt.seeking      = N==1         and seeking or txt.seeking or 'no'               --LINE7 OF txtfile CONTROLLED BY FIRST-BORN.  IT GETS 1/7.  INITIALIZED AS no.  CONTROLLER seeking SETS txt.speed=0.
    if   write         --ANY PLAYER (FAMILY MEMBER) CAN write. 
    then write       = ''
        for line in ('path aid volume speed os_time time_pos seeking'):gmatch('[^ ]+') 
        do write     = write..txt[line]..'\n' end
        txtfile      = io.open(txtpath,'w') --MODES w OR w+=ERASE+WRITE.  MPV.APP REQUIRES txtfile BE WELL-DEFINED.
        txtfile: write(write) --CONTROLLER REPORT.  PRECAUTION: NO ARBITRARY COMMANDS OR SETS (property NAMES). A set COULD HOOK AN UNSAFE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.
        txtfile: close() end  --EITHER flush() OR close().
    
    txt.os_time     = txt.os_time  or os_time  --INITIALIZE TIME_OF_WRITE=txt.os_time. CHILDREN ALL quit IF txtfile NEVER COMES INTO EXISTENCE.
    time_from_write =     os_time-txt.os_time  --Δ INVALID ON MPV.APP.
    set_speed       = N==0 and p.speed~=speed  
    set_pause       = (time_from_write>o.timeouts.pause or not txtfile) and N>0  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.  THIS MAY TRIP ACCIDENTALLY?
    command         =   
                          set_speed                       and ('%s set speed %s'):format(command_prefix,speed)  --CONTROLLER TITULAR COMMAND.
                      or  time_from_write>o.timeouts.quit and     'quit'  --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout.  txtfile DOESN'T ORDER A quit BECAUSE A timeout IS STILL NEEDED ANYWAY, FOR THE OCCASIONAL FAILURE TO READ "quit" FAST ENOUGH.
                      or  set_pause                       and     'set pause yes'
    command         = command and mp.command(command)
    if N           == 0 or not (txtfile and txt.path) then return end --CHILDREN BELOW, UNLESS BLANK txtfile (EITHER pause OR NOTHING).
    target_pos      = txt.time_pos+time_from_write*txt.speed          --=Δtime_pos=Δos_time*speed
    time_gained     = p['time-pos']-target_pos  
    seek            = math.abs(time_gained)>o.seek_limit and (target~='' or samples_time)      --REQUIRE NEW MPV OR ELSE ACCURATE samples_time.
    time_gained     = seek and 0 or time_gained                                                --seek→(time_gained=0)
    speed           = (time_from_write>o.timeouts.pause or txt.aid=='no') and 0                --0 MEANS pause.  CHILDREN ALWAYS START PAUSED.
                      or clip( txt.speed*(1-time_gained/.5)                                    --time_gained→0 OVER NEXT .5 SECONDS (MEASURED IN time-pos, THE astats UPDATE TIME). 
                              *(1+math.random(-o.max_random_percent,o.max_random_percent)/100) --random BOUNDS [.9,1.1] MAYBE SHOULD BE [.91,1.1]=[1/1.1,1.1].  1% SKEWED TOWARDS SLOWING IT DOWN EXCESSIVELY.
                              ,txt.speed/o.max_speed_ratio,txt.speed*o.max_speed_ratio)        --speed LIMIT RELATIVE TO CONTROLLER.  15% EXTRA WHEN USER UNPAUSES (FOR CHILDREN TO CATCH UP).
    txt.pause       = speed>0 and 'no' or 'yes' --INFERRED.
    set_speed       = speed>0 and (target~='' or samples_time)                                 --REQUIRE NEW MPV OR ELSE ACCURATE samples_time.
    set_pause       = speed>0     ==p.pause
    set_volume      = txt.volume+0~=p.volume
    set_aid         = txt.aid     ~='no' and txt.aid+0~=a_id  --txt.aid EITHER no OR #.  no FOR JPEG.  NEVER set no, OR ELSE YOUTUBE TAKES AN EXTRA SECOND TO LOAD (~WRONG).
    command         = ''
                      ..(set_aid       and ('%s set  aid    %s;'        ):format(command_prefix,txt.aid   ) or '')
                      ..(set_volume    and ('%s set  volume %s;'        ):format(command_prefix,txt.volume) or '')
                      ..(set_pause     and ('   set  pause  %s;'        ):format(               txt.pause ) or '')
                      ..(set_speed     and ('%s set  speed  %s;'        ):format(command_prefix,speed     ) or '')
                      ..(seek          and ('   seek %s absolute exact;'):format(               target_pos) or '')  --absolute MORE RELIABLE.  SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN ACCELERATE ITS SPEED).
    loadfile        = txt.path~=m.path and mp.commandv('loadfile',txt.path)  --commandv FOR FILENAMES.  YOUTUBE ALSO.  MAY BE BLANK @load-script.  FLAGS INCOMPATIBLE WITH MPV-v0.34.  
    command         =  command~=''     and mp.command (command)
    m.path          = txt.path  --MEMORIZE PRIOR path.  THIS IS A RELOAD-BLOCKER.  JPEG IS ONLY EVER INSTA-LOADED ONCE, OR ELSE CHILD LOGS ERRORS INDEFINITELY.
end
for property in ('current-tracks/audio/selected mute pause seeking speed frame-drop-count volume audio-params/samplerate current-tracks/audio/id path af-metadata/'..label):gmatch('[^ ]+')  --nil BOOLEANS NUMBERS string table.  INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall.  samplerate MAY DEPEND ON lavfi-complex.  
    do mp.observe_property(property,'native'         ,function(property,val) pcall(property_handler,property,val)  end) end --TRIGGERS INSTANTLY.  astats TRIGGERS EVERY HALF A SECOND, ON playback-restart, frame-drop-count & shutdown.
timers.auto         = mp.add_periodic_timer(o.auto_delay         ,function() pcall(property_handler             )  end)     --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.  SHOULD ALWAYS BE RUNNING FOR RELIABILITY.
timers.mute         = mp.add_periodic_timer(o.double_mute_timeout,function()                                       end)     --mute TIMER TIMES.
timers.mute.oneshot = 1
timers.mute:kill()


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----PLATFORMS  windows linux darwin(Lua 5.1) android(Lua 5.2) ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-7-x86.  ANDROID HAS NO CHILD, NO ytdl & NO COURIER NEW.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----A FUTURE SMOOTH TOGGLE COULD WORK USING volume & amix INSTEAD OF astreamselect (BAD DESIGN CHOICE).  THERE COULD BE ANOTHER LINE FOR SMOOTH TOGGLE (SMOOTH-MUTE USING t-DEPENDENT af-command).
----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----autospeed.lua IS A DIFFERENT SCRIPT INTENDED FOR VIDEO speed, NOT AUDIO.  o.speed CAME LATER.
----IT'D BE MORE ELEGANT TO SOMEHOW MULTI-STREAM YOUTUBE. THAT'D REMOVE FEEDBACK FROM FIRST-BORN.
----FOR CHILD ON ANDROID (SECOND INSTANCE) SOMEONE COULD PUBLISH mpv-android2 (is.xyz.mpv2).  ANDROID APPS ARE SINGLETONS, BUT PUBLISHING A CLONE IS FEASIBLE IF THERE'S DEMAND.  (LISTENING TO MUSIC ON PHONE IS LIKE MONO...)
----FOR SURROUND SOUND THE CONTROLLER COULD SWITCH THROUGH ALL DEVICES INSTANTLY TO COUNT CHANNELS.  THERE'S A RISK OF RIGHT CHANNEL ON BACK-LEFT, ETC.  CODING FOR A SURROUND SOUND SOURCE SIGNAL IS MORE COMPLICATED.  
----THIS IS LIKE 2 SCRIPTS IN 1.  A SEPARATE clock.lua COULD ALSO INCLUDE AN ALARM.  RESYNCING THE EXACT TICK EVERY MINUTE USES 0% CPU.  
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY (REQUIRING sudo) MAY BE LIKE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET. I WROTE A PIPE VERSION BUT PREFER txtfile.  INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----volume   = volume:...:eval  DEFAULT=1:...:once  POSSIBLE TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.  COULD BE USED FOR SMOOTH TOGGLE.
----loudnorm = I:LRA:TP         DEFAULT=-24:7:-2.  INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----acompressor       SMPLAYER DEFAULT NORMALIZER.
----firequalizer  OLD SMPLAYER DEFAULT NORMALIZER.

----ALTERNATIVE STYLES.  NORMALLY DUTCH,ARABIC,RUSSIAN,LITHUANIAN,ESTONIAN,GERMAN  SHOULD HAVE  2,1,2,2,1,2 LETTER AbDays.  BOTH INDIA & CHINA ARE CHARGED.  COLOMBIA MIGHT BE POSSIBLE ({\\fscy200}%I{\\fscy100}).  MISSISSIPPI STATE FLAG IS CHARGED (1 MISSISSIPPI | 2 MISSISSIPPI | 3 MISSISSIPPI).  AN UKRAINIAN/POLISH STYLE MIGHT REQUIRE A CODE WHICH CROPS DIGITS (LIKE \fscy BUT \fcry=FONT-CROP-Y).  CONCEIVABLY ADVERTISEMENTS COULD FIT INSIDE EACH DIGIT OF A CLOCK.
        -- "NETHERLANDS  NEDERLAND      RED    ◙ WHITE  ◙   BLUE   18M  [ -Zo-  -Ma-  -Di-   -Wo-  -Do-  -Vr-  -Za- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c251DAD\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c85471E       }\\N%S",  --PARAGUAY & CROATIA SIMILAR BUT CHARGED.  YUGOSLAVIA WAS CHARGED REVERSE.  Zon MAY HAVE 3 LETTERS?
        -- "      Yemen  اليمن           ‎اRED    ◙ WHITE  ◙  BLACK   34M  [--ح-- ‎--ن-- ‎--ث-- ‎--ر-- ‎--خ-- ‎--ج-- ‎--س--]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c2611CE\\fs55\\bord3}%I{\\cFFFFFF     }\\N%M{\\c     0\\bord1}\\N%S",  --LRM=LEFT_TO_RIGHT_MARK='‎'='\xE2\x80\x8E'  ALM (ARABIC LETTER MARK) GOES THE OTHER WAY!  ا="a" FROM اليمن="alyaman" ALSO FOR ALIGNMENT.  YEMEN REPRESENTS ARABIA, SOUTH OF SAUDI.  ARABIC & HEBREW ARE RIGHT-TO-LEFT.
        -- "     RUSSIA  РОССИЯ         WHITE  ◙  BLUE  ◙    RED  147M  [ -Вс-  -Пн-  -Вт-   -Ср-  -Чт-  -Пт-  -Сб- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\cFFFFFF\\fs55\\bord3}%I{\\cA73600     }\\N%M{\\c1827D6       }\\N%S",
        -- "  LITHUANIA  LIETUVA        YELLOW ◙ GREEN  ◙    RED    3M  [ -Sk-  -Pr-  -An-   -Tr-  -Kt-  -Pn-  -Št- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c13B9FD\\fs55\\bord3}%I{\\c446A00     }\\N%M{\\c2D27C1       }\\N%S",
        -- "    ESTONIA  EESTI          BLUE   ◙ BLACK  ◙  WHITE    1M  [--P-- --E-- --T--  --K-- --N-- --R-- --L-- ]  {\\an3\\c     0\\fs28\\bord0}%a\\N{\\cCE7200\\fs55\\bord3}%I{\\c   0\\bord1}\\N%M{\\cFFFFFF\\bord3}\\N%S", 
        -- "    GERMANY  DEUTSCHLAND    BLACK  ◙  RED   ◙   GOLD   85M  [ -So-  -Mo-  -Di-   -Mi-  -Do-  -Fr-  -Sa- ]  {\\an3\\c     0\\fs37\\bord0}%a\\N{\\c     0\\fs55\\bord1}%I{\\c  FF\\bord3}\\N%M{\\c  CCFF       }\\N%S",
        
