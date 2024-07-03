----ADD CLOCK TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. CLOCK TICKS WITH SYSTEM, & MAY BE COLORED & STYLED, ON SMARTPHONE TOO. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PATH, AID & LAG APPLY TO ALL CHILDREN. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER. A SMALLER STEREO ADDS MORE TREBLE (BIG CHEAP STEREOS HAVE TOO MUCH BASS).  USB→3.5mm SOUND CARDS COST AS LITTLE AS $3 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES 2*mpv.exe IN TASK MANAGER (2*2% CPU, + 50MB RAM).  EVERY SPEAKER BOX (EXCEPT PRIMARY) GETS ITS OWN YOUTUBE STREAM, ETC. ALSO FULLY WORKS IN VIRTUALBOX. 
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.

options                      = {             
    key_bindings             = 'Ctrl+C F1',  --CASE SENSITIVE (Ctrl+Shift+c). DON'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO filterchain.  C IS autocrop.lua, NOT CLOCK.  Ctrl+c BREAKS.
    double_mute_timeout      = .5 , --SECONDS FOR DOUBLE-MUTE-TOGGLE (m&m DOUBLE-TAP).  0 MEANS INACTIVE.  TRIPLE-MUTE DOUBLES BACK.  SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE-MUTE.  REQUIRES AUDIO IN SMPLAYER.
    extra_devices_index_list = {} , --TRY {3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS.  1=auto  2=NORMAL DEVICE.  EITHER 1 OR 2 OVERLAPS ECHO-STYLE (AVOID).  EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS & STREAM.  INTERNAL PC SPEAKERS USUALLY COUNT AS 2.
    speed                    =      '${speed}'                             ,  --EXPRESSION FOR DYNAMIC speed CONTROL, set EVERY HALF-SECOND.  CAN USE ANY MPV PROPERTY (LIKE ${percent-pos}) IN ANY LUA FORMULA.  '${speed}' IS A NULL-OP.  TOGGLES WITH DOUBLE-mute & VALID ON ANDROID!
    -- speed                 =      '${speed}<1.2 and ${speed}+.01 or 1'   ,  --UNCOMMENT TO CYCLE speed BTWN 1 & 1.2 OVER 10s.  PRESS BACKSPACE TO RESET BACK TO 1.  REPLACE 1.2 & 1 FOR DIFFERENT BOUNDS.
    -- speed                 = 'clip(${speed}+math.random(-1,1)/100,1,1.2)',  --UNCOMMENT TO RANDOMIZE VIDEO speed, USING A BOUNDED RANDOM WALK.  -1%,+0%,+1% EVERY HALF-SECOND, RECURSIVELY. +2% TO ADD DRIFT.
    suppress_osd             = true , --REMOVE TO VERIFY speed.  APPLIES ALSO TO CHILDREN.
    mpv                      = {      --LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE.  REMOVE THEM FOR NO CHILDREN OVERRIDE (clocks, filterchain & speed ONLY).  NO CHILDREN ON ANDROID.  A COMMAND MAY NOT BE A PATH.  FIRST MATCH SPAWNS ALL CHILDREN.  
        "mpv"                                          ,  --LINUX & SMPLAYER (WINDOWS)
        "./mpv"                                        ,  --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv"     ,  --     mpv.app     (MAY BE CASE-SENSITIVE.)
        "/Applications/SMPlayer.app/Contents/MacOS/mpv",  --SMPlayer.app     (USING TERMINAL.)
    },
    filterchain        = 'anull,dynaudnorm=g=5:p=1:m=100',  --DEFAULT=g=31:p=.95:m=10=DYNAMIC-AUDIO-NORMALIZER.  GRAPH COMMENTARY HAS MORE DETAILS.  CAN REPLACE anull WITH EXTRA FILTERS, LIKE vibrato highpass aresample.  VALID ON ANDROID.
    resync_delay       =      30 , --SECONDS. RESYNC WITH THIS DELAY.  CPU TIME GOES OFF WITH RANDOM LAG.  TOO DIFFICULT TO DETECT LAG FOR ALL PLAYERS. 
    os_sync_delay      =     .01 , --SECONDS. PRECISION FOR SYNC TO os.time. A perodic_timer CHECKS SYSTEM clock EVERY 10 MILLISECONDS (FOR THE NEXT TICK).  WIN10 CMD "TIME 0>NUL" GIVES 10ms ACCURATE SYSTEM TIME.
    timeouts           = {quit=15,pause=5},  --CHILDREN ONLY.  DEFAULT={10,5} SECONDS   quit OR pause IF CONTROLLER BREAKS FOR THIS LONG.  THEY pause INSTANTLY ON STOP.  COULD BE RENAMED child_timeouts.  {quit,MUTE} MIGHT BE MORE ELEGANT, BUT I PREFER {quit,pause}.
    seek_limit         =     .5  , --SECONDS.  CHILDREN ONLY.  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit. seek CAUSES AUDIO TO SKIP. (SKIP VS JERK.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    auto_delay         =     .25 , --SECONDS.  CHILDREN ONLY.  RESPONSE TIME. THEY CHECK txtfile THIS OFTEN.
    max_speed_ratio    =    1.15 , --          CHILDREN ONLY.  speed IS BOUNDED BY [txt.speed/max,txt.speed*max]  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    max_random_percent =      10 , --          CHILDREN ONLY.  DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND.  EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L/R DRIFT, DUE TO LAG & HALF SECOND RANDOM WALKS BTWN SPEEDS.
    mutelr             = 'mutel' , --mutel/muter  CONTROLLER ONLY.  PRIMARY CHANNEL HAS NORMAL SYNC TO VIDEO.  HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    metadata_osd       =  false  , --true FOR audio STATISTICS (astats METADATA).  CONTROLLER ONLY.  SHOULD BE REMOVED IN FUTURE VERSION. MPV-v0.37+ SYNC PROPERLY WITHOUT IT. (IT WAS NECESSARY FOR OLD MPV.)
    options            = {         --CONTROLLER ONLY.
        'image-display-duration inf',  --DEFAULT=1  BUT inf FOR JPEG clock.
        'osd-scale-by-window    no ','osd-font "COURIER NEW"','osd-bold yes',  --DEFAULT=yes,sans-serif,no  osd-scale CAUSES ABDAY MISALIGNMENT.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS IS PROPRIETARY & INVALID ON MACOS.  FONTS INVALID ON ANDROID.
        -- 'osd-border-color   0/.5', --DEFAULT=#FF000000  UNCOMMENT FOR TRANSPARENT CLOCK FONT OUTLINE.  RED=1/0/0/1, BLUE=0/0/1/1, ETC
    },
    options_children = {
        'vid       no       ','vo        null       ','osc      no ','ytdl-format ba/best',  --VIDEO-ID(DEFAULT=auto) & ON-SCREEN-CONTROLLER(DEFAULT=yes)  no REDUCES CPU CONSUMPTION.  VIDEO-OUT=null BLOCKS NEW WINDOWS SOMETIMES.  ba=bestaudio  /best FOR RUMBLE.  REMOVE THIS LINE TO SEE ALL CHILDREN. THIS SCRIPT OVERRIDES ANY ATTEMPT TO CONTROL THEM.
        'sid       no       ','keep-open yes        ','geometry 25%',  --no SUBTITLE-ID.  keep-open MORE EFFICIENT THAN RELOADING.  geometry LIMITS CHILDREN.
        'msg-level all=error','priority  abovenormal',  --DEFAULTS all=status,normal.  BY DEFAULT SMPLAYER LOGS ALL speed CHANGES VIA CHILD terminal.  priority ONLY VALID ON WINDOWS.  
        -- 'audio-pitch-correction       no         ',  --DEFAULT=yes  UNCOMMENT FOR CHIPMUNK MODE (NO scaletempo# FILTER). WORKS OK WITH SPEECH & COMICAL MUSIC.  REDUCES CPU CONSUMPTION BY 5%=5*1%.  ACTIVE INDEPENDENT TEMPO SCALING FOR SEVERAL SPEAKERS USES CPU.
    },
    options_android = {
        'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',  --NO ARMENIAN. 🙁
    },
    clocks       = {   --TOGGLE LINES TO INCLUDE/EXCLUDE VARIOUS STYLES FROM THE LIST.  REPETITION VALID.  A SIMPLE LIST OF STRINGS IS EASY TO RE-ORDER & DUPLICATE, LIKE REPEATING Yemen FOR THE ARABIC.
        duration = 2 , --SECONDS, INTEGER.  0/nil MEANS NO CLOCK.  TIME PER CLOCK STYLE THROUGHOUT CYCLE.  STYLE TICKS OVER EVERY SECOND SECOND. (ON THE DOUBLE.)
        offset   = 0 , --SECONDS, INTEGER.  CHANGE STYLE ON EVENS OR ODDS? 0=EVEN.  ALL SMPLAYER INSTANCES HAVE SAME CLOCK @SAME TIME.
        -- no_locales          = true,  --UNCOMMENT FOR English ONLY.  UPPERCASE & LOWERCASE CAN BE DONE MANUALLY USING NOTEPAD++.  EACH CLOCK CAN DICTATE ITS OWN AbDays.
        -- DIRECTIVES_OVERRIDE = true,  --UNCOMMENT TO DISPLAY ALL os.date DIRECTIVE CODES & THEIR CURRENT VALUES (SPECIAL CLOCK). MAY DEPEND ON LUA VERSION.  EXAMPLES: %I,%M,%S,%a,%p,%H,%n = HRS(12),MINS,SECS,Day,A/PM,HRS,RETURN  %n=♪=\r & \\N=◙.  ♪ RETURNS TO TOP-LEFT, FOR NEW ALIGNMENT.
----    "         COUNTRY              HOUR     MINUTE   SECOND  POPULATION  [            AbDays             -=HALF_SPACE ]  {\\STYLE OVERRIDES}          \\N              ↓↓(CLOCK SIZE)                 %DIRECTIVES            ",  --"{" REQUIRED, & EVERYTHING BEFORE IT IS REMOVED.  {} ALONE REMOVES LEADING 0 FOLLOWING IT.  AbDays (ABBREVIATED DAYS) START WITH Sun FOR ARABIC/ARMENIAN, BUT Mon FOR EUROPE.  AbDays CAN BE REPLACED WITH ANYTHING. 1 LOTE CAN BE COPIED OVER ALL THE OTHERS.  https://lh.2XLIBRE.NET/locales FOR LOCALES. ALL AbDays ARE VERIFIED INDIVIDUALLY USING GOOGLE TRANSLATE.  HALF-SPACE IS BECAUSE CENTERING IS OFTEN 1-OFF, LIKE 2 ON 3, 3 ON 4, ETC, & AN EXTRA LETTER IS INVALID.  7 LETTERS MAY MEAN Sun→Sat, BUT EACH LETTER ON ITS OWN IS MEANINGLESS. HENCE SEMI-ABBREVIATED ABDAYS (SEMI-AbDays) ARE MORE VALID.  FOR VERTICAL SPELLING, USE Sun→S◙u◙n.
        "    BELGIUM  BELGIË           BLACK    YELLOW      RED         12M  [ zon   -Ma-  -Di-  -Wo-   don  -Vr-   -Za-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c     0\\fs55\\bord1}%I{\\c24DAFD\\bord3} %M{\\c4033EF       } %S",  --fs37=fs55*2/3 FOR LENGTH 3.  BLACK PRIMARY (THIN BORDER), LIKE GERMANY.  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  CAN RECITE COUNTRIES (BELGIUM CAPITAL).  %S ARE THE CORNERSTONE (ANCHOR).  CAN USE ":" OR " " BTWN DIGITS.  %a COULD GO ONTOP OF MINUTES INSTEAD OF SECONDS.  
        "    ROMANIA  ROMÂNIA          BLUE     YELLOW      RED         19M  [ dum    lun   mar   mer   joi   vin    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c7F2B00\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE       } %S",  --marţi,viner=Tue,Fri  ROMANIAN: mar,vin=apple,wine=AMBIGUOUS.  MOLDOVA & ANDORRA SIMILAR COLORS, BUT CHARGED.  
        "       CHAD  TCHAD            BLUE      GOLD       RED         19M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c642600\\fs55\\bord3}%I{\\c  CBFE       } %M{\\c300CC6       } %S",  --GOLD IS SLIGHTLY DARKER THAN YELLOW, & HAS LESS GREEN THAN ORANGE.  ORANGE HAS EVEN LESS GREEN.  BLUE=00 FOR BOTH.  IDEAL COLOR LIST MIXES AFRO & EURO FLAGS. 
        "          MALI                GREEN    YELLOW      RED         21M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c3AB514\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE       } %S",  --SENEGAL SIMILAR BUT CHARGED.  
        "     GUINEA  GUINÉE           RED      YELLOW    GREEN         14M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2611CE\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c609400       } %S",  --RED IS RIGHT, EXCEPT FOR GUINEA!
        "         NIGERIA              GREEN    WHITE     GREEN        231M  [ sun    mon   tue   wed   thu   fri    sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c  8000\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c  8000       } %S",  --BICOLOR TRIBAND.  WHITE ALWAYS IN THE MIDDLE. ORDER ALIGNS WHITES & REDS.  
        "IVORY COAST  CÔTE D'IVOIRE    ORANGE   WHITE     GREEN         31M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c  82FF\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c449A00       } %S",  
        "    IRELAND  ÉIREANN          GREEN    WHITE    ORANGE          5M  [ sun    mon   tue   wed   thu   fri    sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c629B16\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3E88FF       } %S",  --IRELAND REPRESENTS BRITAIN, LIKE HOW YEMEN REPRESENTS ARABIA.
        "      ITALY  ITALIA           GREEN    WHITE       RED         59M  [ dom    lun   mar   mer   gio   ven    sab  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c458C00\\fs55\\bord3}%I{\\cF0F5F4       } %M{\\c2A21CD       } %S",  --MEXICO SIMILAR BUT CHARGED. CATHOLIC, LIKE IRELAND.  Mar=TUESDAY IS THIRD, LIKE MARCH.  Mer ALSO THIRD (Wed).  domino's ON SUNDAY!
        "         FRANCE               BLUE     WHITE       RED         68M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cA45500\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3541EF       } %S",  --mard,mercr,jeudi=Tue,Wed,Thu  mer,jeu=sea,game=AMBIGUOUS. THURSDAY=GAMEDAY.  LENGTH 3 BY COMPARISON TO ITALIAN.  LOWERCASE IMPROVES SYMMETRY. WHAT'S CAPITAL ARE THE COLORS UNDERLYING THE SPELL.
        "       PERU  PERÚ             RED      WHITE       RED         34M  [ dom    lun   mar   mié   jue   vie    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2310D9\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c2310D9       } %S",  --BICOLOR.  marts=Tuesday. mar(SPANISH)=Море(RUSSIAN)=sea=AMBIGUOUS.  CANADA MIGHT BE SIMILAR BUT WITH REDUCED HRS & SECS fs.  vie=Fri(5)
        "    AUSTRIA  ÖSTERREICH       RED    ◙ WHITE  ◙    RED          9M  [-So-   -Mo-  -Di-  -Mi-   don  -Fr-   -Sa-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2E10C8\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c2E10C8       }◙%S",  --BICOLOR.  HORIZONTAL TRIBAND (VERTICAL TAB).  LIKE A TAB FROM THE FLAG.  BLACK Day IS POSITIONED WITH BLACK BAR ON SCREEN-RIGHT. 
        "    HUNGARY  MAGYARORSZÁG     RED    ◙ WHITE  ◙  GREEN         10M  [ vasr   htfő -ked- -sze-  Cstö  pétk  -sot- ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c3929CE\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c507047       }◙%S",  --Cstö        CAPITALIZED.  vasárn=Sun (6 LETTERS NEEDED).  
        " LUXEMBOURG  LËTZEBUERG       RED    ◙ WHITE  ◙   CYAN         <1M  [-Son- --Mo--  dëns  Mëtw  Donn -fre- --Sa-- ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c4033EF\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\cE0A300       }◙%S",  --Mëtw & Donn CAPITALIZED.
        "NETHERLANDS  NEDERLAND        RED    ◙ WHITE  ◙   BLUE         18M  [ zon   -Ma-  -Di-  -Wo-   don  -Vr-   -Za-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c251DAD\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c85471E       }◙%S",  --Zo=AMBIGUOUS.  PARAGUAY & CROATIA SIMILAR BUT CHARGED.  YUGOSLAVIA WAS CHARGED REVERSE.  
        "      Yemen  ‎اليمن‎             اRED    ◙ WHITE  ◙  BLACK         34M  [ ‎الأحد‎   ‎الاثن‎  ‎ثلاثء‎  ‎أربعء‎  ‎خميس‎  ‎جمعة‎  ‎-سبت-‎ ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c2611CE\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c     0\\bord1}◙%S",  --fs28=fs55/2 FOR LENGTH 4.  USUALLY AbDays ARE LENGTH 1.  LRM=LEFT_TO_RIGHT_MARK='‎'='\xE2\x80\x8E' IS ON EITHER SIDE OF ARABIC WORDS.  ALM (ARABIC LETTER MARK) GOES THE OTHER WAY!  YEMEN REPRESENTS ARABIA, SOUTH OF SAUDI.  ARABIC & HEBREW ARE RIGHT-TO-LEFT & ARE ALLOWED A LEFT-TAIL.  THESE ARE PROPERLY SPACED FOR COURIER NEW BOLD.  SUNDAY=1DAY=‎الأحد‎.  1=ا="a" FOR ALIGNMENT (‎اليمن‎="alyaman").
        "      SIERRA LEONE            GREEN  ◙ WHITE  ◙   BLUE          9M  [ sun    mon   tue   wed   thu   fri    sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c3AB51E\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\cC67200       }◙%S", 
        "          GABON               GREEN  ◙ YELLOW ◙   BLUE          2M  [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c609E00\\fs55\\bord3}%I{\\c16D1FC       }◙%M{\\cC4753A       }◙%S", 
        "         BOLIVIA              RED    ◙ YELLOW ◙  GREEN         12M  [ dom    lun   mar   mié   jue   vie    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c1C29DA\\fs55\\bord3}%I{\\c  E4F4       }◙%M{\\c337A00       }◙%S",  
        "        MAURITIUS       RED ◙ BLUE   ◙ YELLOW ◙  GREEN          1M  [ dim    lin   mar   mer  -Ze-   van    sam  ]  {\\an3\\c3624EB\\fs37\\bord2}%a◙{\\c6D1A13\\fs55\\bord3}%I{\\c  D6FF       }◙%M{\\c50A600       }◙%S",  --MORISYEN: QUAD-COLOR QUAD-BAND.  ISLANDS NEAR MADAGASCAR.  
        "    ARMENIA  ՀԱՅԱՍՏԱՆ         RED    ◙  BLUE  ◙ ORANGE          3M  [-Կիր-  -Երկ-  Երքթ -Չրք-  Հնգթ -ւրբ-  -շբթ- ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c1200D9\\fs55\\bord3}%I{\\cA03300       }◙%M{\\c  A8F2       }◙%S",  --UPPERCASE SOMETIMES REQUIRED.
        "     RUSSIA  РОССИЯ           WHITE  ◙  BLUE  ◙    RED        147M  [-Вс-   -Пн-   втр  -Ср-  -Чт-  -Пт-   -Сб-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cFFFFFF\\fs55\\bord3}%I{\\cA73600       }◙%M{\\c1827D6       }◙%S",  --LENGTH 3 WORKS BETTER SOMETIMES.  SLOVENIA SIMILAR, BUT CHARGED. SERBIA IS CHARGED REVERSE.  THE COLORS DICTATE THE MEANING OF THE LETTERS.  Ч~=4  
        "   BULGARIA  БЪЛГАРИЯ         WHITE  ◙ GREEN  ◙    RED          6M  [-Нд-   -Пн-  -Вт-  -Ср-  -Чт-   пет   -Сб-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cFFFFFF\\fs55\\bord3}%I{\\c  9900       }◙%M{\\c    CC       }◙%S",
        "  LITHUANIA  LIETUVA          YELLOW ◙ GREEN  ◙    RED          3M  [ sekm   Pirm  antr  tred -ket-  penk   šetd ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c13B9FD\\fs55\\bord3}%I{\\c446A00       }◙%M{\\c2D27C1       }◙%S",  --Pirm CAPITALIZED.           USUALLY AbDays ARE LENGTH 2.  antrd=Tue(5 LETTERS NEEDED).  COUNTS FROM Mon (3DAY,5DAY = Wed,Fri).
        "    ESTONIA  EESTI            BLUE   ◙ BLACK  ◙  WHITE          1M  [ pühap  esmas teisp kolmp nelja reede  laupä]  {\\an3\\c     0\\fs22\\bord0}%a◙{\\cCE7200\\fs55\\bord3}%I{\\c     0\\bord1}◙%M{\\cFFFFFF\\bord3}◙%S",  --fs22=fs55*2/5 FOR LENGTH 5. USUALLY AbDays ARE LENGTH 1.  neljap=Thu  nelja=4=AMBIGUOUS  (THURSDAY=4DAY)
        "    GERMANY  DEUTSCHLAND      BLACK  ◙  RED   ◙   GOLD         85M  [-So-   -Mo-  -Di-  -Mi-   don  -Fr-   -Sa-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c     0\\fs55\\bord1}%I{\\c    FF\\bord3}◙%M{\\c  CCFF       }◙%S",  --Donstg=Thu  Do=AMBIGUOUS(Di?).
     -- "          Wedge               BIG    : MEDium : Little   tiny                                                       {\\an3       \\fs70\\bord2}{}%I{          \\fs42      }:%M{\\fs25          }:%S{\\fs15          } %a",  --RATIO=.6  DIAGONAL PATTERN.  MY FAV.
----STYLE CODES: \\,N,an#,fs#,bord#,c######,fscx## = \,NEWLINE,ALIGNMENT-NUMPAD,FONT-SIZE(p),BORDER(p),COLOR,FONTSCALEX(%)  (DEFAULT an0=an7=TOPLEFT)    MORE: alpha##,b1,shad#,be1,i1,u1,s1,fn*,fr##,fscy## = TRANSPARENCY,BOLD,SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTNAME,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEY(%)  EXAMPLES: USE {\\alpha80} FOR TRANSPARENCY. USE {\\fscx130} FOR +30% IN HORIZONTAL.  A TRANSPARENT clock CAN BE BIGGER. be ACTS LIKE SEMI-BOLD.  
    },  
    params = '{N=0,pid}',  --DECLARATION OF PARAMETERS.  N=0 is_controller.  N=1 IS FIRST-CHILD & PROVIDES FEEDBACK.  PARENT PROCESS-ID DETERMINES txtfile THE CHILDREN READ FROM.  ALTERNATIVE IS TO DEFINE ENVIRONMENTAL VARIABLE/S FOR CHILDREN, BUT o.params IS SIMPLER.
}
o,p,m,timers = options,{},{},{}      --TABLES.  p=PROPERTIES  m=MEMORY={map,graph,path}  timers={mute,auto,os_sync,osd}
require 'mp.options'.read_options(o) --mp=MEDIA_PLAYER  ALL options WELL-DEFINED & COMPULSORY.

gp,label       = mp.get_property_native,mp.get_script_name()        --aspeed FILENAME MUSTN'T HAVE SPACES, BUT ITS DIRECTORY CAN.
for  property in ('pid platform audio-device-list'):gmatch('[^ ]+') --number string LIST nil.  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME LUA _VERSION, BUILT DIFFERENT).
do p[property] = gp(property) end
for  opt in ('seek_limit resync_delay params'):gmatch('[^ ]+')
do o[opt]      = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end --string→number/table: '1+1'→2  load INVALID ON MPV.APP. 
command_prefix = o.suppress_osd  and 'no-osd'    or ''
N              = o.params.N  --N ABBREVIATES CHILD# (0, 1, OR MORE COME IN PAIRS).
for _,opt in pairs(N==0 and o.options or o.options_children)
do  command    = ('%s%s set %s;'):format(command or '',command_prefix,opt) end
for _,opt in pairs(p.platform=='android' and o.options_android or {})
do  command    = ('%s%s set %s;'):format(command or '',command_prefix,opt) end
command        = command and mp.command (command) --ALL SETS IN 1.  

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR txtfile.
    D = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  (MIN MAX MIN MAX)  ENFORCES speed LIMIT.
math.randomseed(p.pid)  --OTHERWISE CHILD TEMPO MAY BE SAME OR PREDICTABLE.

abdays,txt,clocks,LOCALES = {},{},{},{}  --TABLES & LISTS.  LOCALES IS LIST OF SUB-TABLES, FOR LOTE. NEVER USED BY CHILDREN (UNLESS THEY ALSO HAVE A clock).  txt FOR property_handler.
o.timeouts.quit  = (o.timeouts.quit  or o.timeouts[1] or 10)+0 --DEFAULT=10  SECONDS  +0 CONVERTS→number
o.timeouts.pause = (o.timeouts.pause or o.timeouts[2] or  5)+0 --DEFAULT= 5 
directory        = mp.command_native({'expand-path',(require 'mp.utils'.split_path(gp('scripts')[1]))}) --command_native EXPANDS '~/', REQUIRED BY io.open.  BRACKETS CAPTURE FIRST RETURN.  ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
                         
for abday in ('Sun Mon Tue Wed Thu Fri Sat'):gmatch('[^ ]+') do table.insert(abdays,abday) end     --MORE RIGOROUS CODE COULD ALSO insert  Su Mo Tu We Th Fr Sa  OR SET  abdays[abday: sub(1,2)..'%l*'] = abday.  %a COULD BE LENGTH 2.
abdays                    = (o.clocks.no_locales or o.clocks.DIRECTIVES_OVERRIDE) and {} or abdays --OVERRIDES.  EVERYTHING PERTAINING TO abdays BECOMES A NULL-OP.
for  _,clock in pairs(o.clocks) 
do if type(clock)        == 'string' --STRINGS ONLY.  SPLITTING THE STRINGS IN HALVES OR THIRDS (IN options) WOULD BE MORE COMPLICATED.
    then clock            = (p.platform=='android' and clock: find('ր',1,1) and clock: gsub('%%a','') or clock) --1,1=init,plain  NO-ARMENIAN OVERRIDE FOR ANDROID. BACK-TO-FRONT-ETA DOESN'T EXIST.  ARMENIA GOOD, ARMENIAN BAD.
                            :gsub('◙','\\N'):gsub('♪','%%n')                                                    --◙,♪=\N,%n ARE BETTER FORM.  %n=\r (\r INVALID).  ♪ RETURNS TO TOP-LEFT.  
         LOCALE,gmatch    = {},(clock: gmatch('%[.*%]')() or ''):gmatch('[^%[ %]]+') --LOCALE HAS ABDAYS AS KEYS.  ABDAY ITERATOR.  '.*' MEANS LONGEST MATCH OR NOTHING.  "[]" ARE MAGIC.
         for _,abday in pairs(abdays) 
         do LOCALE[abday] = (gmatch() or abday):gsub('%-%-','‎ ‎'):gsub('%-','{\\fscx50}‎ ‎{\\fscx100}') end --LOCALE OR DEFAULT.  "-" IS MAGIC, WORTH HALF-SPACE.  EACH SPACE HAS LRM ON EITHER SIDE FOR PROPER ALIGNMENT.
         
         table.insert(clocks ,(clock: gsub('[^{]*','',1)) )  --'*' MAY ELIMINATE NOTHING BEFORE LEADING {.  ONCE ONLY.  EXTRA BRACKETS CAPTURE THE FIRST RETURN.
         table.insert(LOCALES,LOCALE) end end  

if o.clocks.DIRECTIVES_OVERRIDE  
then clocks            = {''}           --ONLY 1.
    for N              = 0,128          --LOOP OVER ALL POSSIBLE BYTECODE FROM 0→0x80.
    do char            = string.char(N) --A,a = 0x41,0x61 = 65,97  
       DIRECTIVE       =   '%'..char
       invalid         = os.date(DIRECTIVE):sub(1,1)=='%'  --os.date RETURNS %char IF INVALID (SKIP). 
       clocks[1]       = clocks[1]..(invalid and ''   or (char=='a' and '\n' or '')..('%%%s="%s"  '):format(DIRECTIVE,DIRECTIVE)) end end  --NEWLINE @a.
clocks                 = (o.clocks.duration  or 0)==0 and {} or clocks     --duration=nil/0 MEANS clock=nil.
if N==0 then clock     = clocks[1] and mp.create_osd_overlay('ass-events') --ass-events IS THE ONLY VALID OPTION.  AT LEAST 1 CLOCK OR nil.  COULD ALSO SET res_x & res_y FOR BETTER THAN 720p FONT QUALITY.
    p['script-opts']   = mp.get_property('script-opts')                    --string FOR SPAWNING, MAY BE BLANK.  ytdl_hook POTENTIALLY UNSAFE & ONLY EVER DECLARED ONCE (IN TASK MANAGER).  
    o.auto_delay,devices,script = .5,{gp('audio-device')},('%s/%s.lua'):format(directory,label)  --CONTROLLER auto_delay EXISTS ONLY TO STOP timeout.  devices=LIST OF audio-devices WHICH WILL ACTIVATE (STARTING WITH EXISTING device).  "wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).  "/" FOR WINDOWS & UNIX. .lua COULD BE .js FOR JAVASCRIPT.  
    
    for _,index in pairs(o.extra_devices_index_list)  --ESTABLISHES devices WHICH ACTIVATE (IF mpv).  DUPLICATES ALLOWED.  WOULDN'T MAKE SENSE FOR CHILDREN.
    do insert_device   = p['audio-device-list'][index] and table.insert(devices,p['audio-device-list'][index].name) end
    for _,command in pairs(o.mpv)  --CONTROLLER command LOOP. 
    do  mpv            =     mpv or mp.command_native({'subprocess',command}).error_string~='init' and command end --error_string=init IF INCORRECT.  BREAKS ON FIRST CORRECT command.  subprocess RETURNS NATIVELY INTO LUA, SO IS MORE ELEGANT THAN run IN THIS CASE.
    for N,audio_device in pairs(mpv and devices or {}) do for mutelr in ('mutel muter'):gmatch('[^ ]+')            --ONLY IF mpv. 
        do script_opts = not (N==1 and mutelr==o.mutelr) and ('%s-mutelr=%s,%s-params="{N=%d,pid=%d}",%s'):format(label,mutelr,label,N,p.pid,p['script-opts'])         --ONLY IF NOT PRIMARY CHANNEL.  script-opts PREFIX label-.  mutelr & audio-device VARY.  CHILDREN WITH 2 MOUTHS MAY BE MUTED LEFT OR RIGHT. INTERNAL PC SPEAKERS COUNT AS 2.
            run_mpv    = script_opts and mp.commandv('run',mpv,'--idle','--audio-device='..audio_device,'--script='..script,'--script-opts='..script_opts) end end end --CHILD SPAWN.  commandv FOR SYMBOLS.  idle MUST BE SET IN ADVANCE.
txtpath                = ('%s/%s-pid%d.txt'):format(directory,label,o.params.pid or p.pid)  --txtfile INSTEAD OF PIPES.
m.map                  = (N~=0 or mpv) and 1 or 0  --graph SWITCH.  0,1 = OFF,ON  ON MEANS mutelr.  CHILDREN ALWAYS ON.  NEVER MUTE WITHOUT CHILDREN.


graph=('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d'):format(o.filterchain,o.mutelr)

----lavfi         = [graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT. 
----stereotools   = ...:mutel:muter DEFAULT=...:0:0  (BOOLS)  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED STEREO FOR RELIABILITY. ALSO MUTES EITHER SIDE. FFMPEG-v4 INCOMPATIBLE WITH softclip.
----dynaudnorm    = ...:g:p:m       DEFAULT=...:31:.95:10  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. IT'S USED SEVERAL TIMES SIMULTANEOUSLY: EACH SPEAKER + VARIOUS GRAPHICS (lavfi-complex).  IT CAN BE TESTED WITH VARIOUS FILTERS BEFORE IT.
----astats        = length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT WAS BASIS FOR 10 HOUR SYNC. TESTED @OVER 1 BILLION. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. MPV-v0.38 CAN SYNC ON ITS OWN WITHOUT astats (BUT NOT v0.36).
----astreamselect = inputs:map      IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH. SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.
----anull           PLACEHOLDER.
----asplit          [ao]→[0][1]=[no-mutelr][mutelr]


function file_loaded()  --ALSO @seek.
    m.path          = nil                                            --UNBLOCKS RELOADING FAILED YOUTUBE.
    if map_restart == m.map then return end                          --PREVENT UNNECESSARY REPLACEMENTS.
    map_restart,m.graph = m.map,graph :format(m.map)                 --map@playback-restart
    mp.commandv('af','pre',('@%s:lavfi=[%s]'):format(label,m.graph)) --graph INSERTION.  commandv FOR BYTECODE.  
end
mp.register_event('file-loaded',file_loaded)
mp.register_event('seek'       ,file_loaded)  --GRAPH STATE RESETS.

function playback_restart() 
    playback_restarted,p.seeking,initial_time_pos = true,nil  --FOR OLD MPV, RESET SAMPLE COUNT.  playback_restarted UNBLOCKS double_mute.
    apply_astreamselect()  --AFTER seeking.
    
    os_sync()
    for N = 1,4 do mp.add_timeout(2^N,os_sync) end --RESYNC ON EXPONENTIAL TIMEOUTS, DUE TO HDD LAG. 0 2 4 8 16 SECONDS.
end
mp.register_event('playback-restart',   playback_restart) 
mp.register_event('end-file',function() playback_restarted=nil end)  --INSTA-BLOCK double_mute.
mp.register_event('shutdown',function() os.remove(txtpath)     end)  --NO RECYCLE BIN. DELETED EVEN IF CONTROLLER BUGS OUT. 

function apply_astreamselect(map)  --@playback-restart, @on_toggle & @property_handler.
    map       = map or not OFF and mpv and txt.seeking~='yes' and 1 or 0 --DEDUCE INTENDED map.  1=MUTED INVALID WITHOUT CHILDREN.  ALWAYS UNMUTE WHEN FIRST-BORN IS seeking.
    if m.map == map or N~=0 or p.seeking then return end                 --return CONDITIONS.  EXCESSIVE COMMANDS CAUSE LAG.  CHILDREN ALWAYS MUTED.  af-command FAILS WHEN seeking (audio-params=nil?).  
    m.map     = map
    mp.command(('af-command %s map %d %s'):format(label,m.map,target or ''))  --target ACQUIRED @samples_time.  
end

function on_toggle()  --@key_binding & @double_mute.  INSTA-TOGGLE (SWITCH). CHILDREN MAINTAIN SYNC WHEN OFF.  MUST TOGGLE FOR JPEG TOO!
    OFF = not OFF     --INSTANT UNMUTE IN txtfile.
    mp.add_timeout(OFF and .4 or 0,function() txt.mute=OFF end)  --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command!  ALTERNATIVE GRAPH REPLACEMENT INTERRUPTS PLAYBACK.  A FUTURE VERSION SHOULD REMOVE THIS, & NEVER USE astreamselect. volume SHOULD RESPOND FASTER.
    
    apply_astreamselect()
    clock_update()  --INSTA-clock_update.
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
    p[property or ''] = val             --p['']=nil  DUE TO IDLER.
    a_id              = p['current-tracks/audio/id'] --aid=false WHEN LOCKED, BUT a_id=1.  lavfi-complex COMBINES MULTIPLE STREAMS.  
    
    if not mp2os_time            or  property=='speed' and set_speed     --4 return CONDITIONS.  1) AWAIT SYNC.  2) set_speed OBSERVATION ENDS HERE. 
        or N >0 and     property and property~='af-metadata/'..label     --3) CHILD OBSERVATION ENDS HERE, EXCEPT ON astats TRIGGER. CONTROLLER PROCEEDS.
        or N==0 and not property and a_id and not (p.pause or p.seeking) --4) CONTROLLER IDLER  ENDS HERE, UNLESS PAUSED/seeking OR JPEG. IT DOES write OBSERVATIONS.  seeking SAVES YOUTUBE LOAD.  AN ISSUE WITH MANY DIRECT LINKS TO 1 function IS DOUBLE-NEGATIVE RETURNS.
    then return end 
    
    mp_time,p['time-pos'] = mp.get_time(),gp('time-pos')
    os_time          =  mp2os_time+mp_time  --os_time=TIMEFROM1970  PRECISE TO 10ms.
    samples_time     =  property=='af-metadata/'..label   and val['lavfi.astats.Overall.Number_of_samples']/p['audio-params/samplerate']  --ALWAYS A HALF INTEGER, OR nil.  TIME=sample#/samplerate  (SOURCE SAMPLERATE) 
    target           =  target  or samples_time           and (mp.command(('af-command %s map %d astreamselect'):format(label,m.map)) and 'astreamselect' or '')  --NEW MPV OR OLD. v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  TARGETED COMMANDS WERE INTRODUCED WITH time-pos BUGFIX.  astreamselect ONLY WORKS AFTER samples_time.
    resync           = (property=='frame-drop-count'      or  os_time-sync_time>o.resync_delay) and os_sync() --ON_LAG & EVERY MINUTE.  ON_LAG SHOULD PROBABLY MULTI-RESYNC (LINK TO playback_restart).
    initial_time_pos =  property~='frame-drop-count'      and initial_time_pos or target=='' and samples_time and samples_time>20 and p['time-pos']-samples_time  --FOR OLD MPV.  EXCESSIVE LAG RESETS SAMPLE COUNT.  v0.36 CAN'T SYNC WITHOUT astats. BOTH MP4 & MP3 LAGGED BEHIND THE CHILDREN. time-pos, playback-time & audio-pts WORKED WELL OVER 1 MINUTE, BUT NOT 1 HOUR.  SAMPLE COUNT STABILIZES WITHIN 20s (YOUTUBE+lavfi-complex). IT'S ALWAYS A HALF-INTEGER @MEASUREMENT.  initial_time_pos=initial_time_pos_relative_to_samples_time  THIS # STAYS THE SAME FOR THE NEXT 10 HOURS. 
    p['time-pos']    =  initial_time_pos and samples_time and initial_time_pos+samples_time  or p['time-pos'] or 0  --0 DURING YOUTUBE LOAD TO STOP timeout.  OLD MPV USES ALT-METRIC WHOSE CHANGE IS BASED ON astats (METRIC SWITCH). 
    txtfile          = io.open(txtpath) --MODES 'r' OR 'r+'.  ALTERNATIVE io.lines RAISES ERROR.  CONTROLLER READS TOO, FOR FEEDBACK. 
    if txtfile       
    then lines       = txtfile: lines() --ITERATOR RETURNS 0 OR 7 LINES, AS function. 
        txt.path     =          lines() --LINE1=path  SOMETIMES BLANK.
        for line in (txt.path and 'aid volume speed os_time time_pos seeking' or ''):gmatch('[^ ]+')  --LINES 2→7, IF LINE1.
        do txt[line] =          lines()   end 
        txtfile:                close() --NEEDED FOR win32 os.remove@shutdown (DEPENDS ON BUILD.)
        apply_astreamselect() end       --BUGFIX FOR SLOW FIRST-CHILD, AUTO-DEDUCES map.  LONG YOUTUBE VIDEOS TEND TO GLITCH.  ALL FAMILY MEMBERS HAVE 2 MOUTHS - THE PARENT UNMUTES ONE OF ITS OWN IF THE FIRST-BORN IS SLOW.  FOR TESTING, GIVE CHILD1 ITS OWN VIDEO & THEN MAKE IT seek. 
    
    seeking          = (p.seeking or not a_id)   and 'yes'   or 'no'                  --IF THE CHILD HASN'T LOADED, PARENT MUST UNMUTE.  ~a_id MAY SOLVE RARE BUGS.
    write            = N==0 and mpv     or  N==1 and txtfile and txt.seeking~=seeking --N=0,1 MAY write.  txtfile=nil @end-file  COULD ALSO PROVIDE FEEDBACK (write-BACK) @shutdown (OPTIONAL).  FIRST-BORN FEEDBACK INITIALLY LAGS IF txtfile IS INACCESSIBLE DUE TO EXCESSIVE LAG.
    txt.seeking      = N==1 and seeking or  txt.seeking      or  'no'                 --LINE7 OF txtfile CONTROLLED BY FIRST-BORN.  INITIALIZED AS no.  CONTROLLER seeking SETS txt.speed=0.
    if  N           == 0 
    then osd_message = samples_time        and not OFF  and o.metadata_osd and mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    ')) --TAB EACH STAT (TOO MANY LINES).
        speed        = samples_time        and not OFF  and loadstring('return '..mp.command_native({'expand-text',o.speed}))() or p.speed                  --TRIGGERED ON samples_time, EVERY HALF-SECOND.  TOGGLE APPLIES.
        double_mute  = (property=='mute'   or property=='current-ao') and playback_restarted and (not timers.mute:is_enabled() and (timers.mute:resume() or 1) or on_toggle())  --current-ao=audiotrack/nil FOR ANDROID.  ~playback_restarted BLOCKS IT BTWN TRACKS.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  current-tracks/audio/selected & current-ao BOTH DO THE SAME THING, BUT current-ao DOESN'T FLIP @playlist-next.
        txt.volume   = (txt.mute or p.mute or not a_id) and 0 or p.volume --OFF-SWITCH & mute.  AUDIO STREAM ITSELF MAY CYCLE ON & OFF WITH A KEYBIND, WITH SMOOTH PLAYBACK.
        txt.speed    = (p.pause  or p.seeking         ) and 0 or speed    --seeking→pause MIGHT FIX A YOUTUBE STARTING GLITCH.  
        txt.path   ,txt.aid      =  p.path or ''      , a_id or 'no'                  --BLANK & no @load-script.
        txt.os_time,txt.time_pos = round(os_time,.001), round(p['time-pos'],.001) end --ms PRECISION.
        
    if   write         --ANY PLAYER (FAMILY MEMBER) CAN write. 
    then write       = ''
        for line in ('path aid volume speed os_time time_pos seeking'):gmatch('[^ ]+') 
        do write     = write..txt[line]..'\n' end
        txtfile      = io.open(txtpath,'w') --MODES w OR w+=ERASE+WRITE.  MPV.APP REQUIRES txtfile BE WELL-DEFINED.
        txtfile: write(write) --CONTROLLER REPORT.  PRECAUTION: NO ARBITRARY COMMANDS OR SETS (property NAMES). A set COULD HOOK AN UNSAFE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.
        txtfile: close() end  --EITHER flush() OR close().
    
    txt.os_time     = txt.os_time  or os_time  --INITIALIZE TIME_OF_WRITE=txt.os_time. CHILDREN ALL quit IF txtfile NEVER COMES INTO EXISTENCE.
    time_from_write =     os_time-txt.os_time  --Δos_time  Δ INVALID ON MPV.APP.
    set_speed       = N==0 and p.speed~=speed  
    set_pause       = (time_from_write>o.timeouts.pause or not txtfile) and N>0  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.  THIS MAY TRIP ACCIDENTALLY?
    command         =   
                          set_speed                       and ('%s set speed %s'):format(command_prefix,speed)  --CONTROLLER TITULAR COMMAND.
                      or  time_from_write>o.timeouts.quit and     'quit'  --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout.  txtfile DOESN'T ORDER A quit BECAUSE A timeout IS STILL NEEDED ANYWAY, FOR THE OCCASIONAL FAILURE TO READ "quit" FAST ENOUGH.
                      or  set_pause                       and     'set pause yes'
    command         = command and mp.command(command)
    if N           == 0 or not (txtfile and txt.path) then return end --CHILDREN BELOW, UNLESS BLANK txtfile (EITHER pause OR NOTHING).  BLANK path @load-script.  
    target_pos      = txt.time_pos+time_from_write*txt.speed          --Δtime_pos=Δos_time*speed
    time_gained     = p['time-pos']-target_pos  
    seek            = math.abs(time_gained)>o.seek_limit and (target~='' or samples_time)      --REQUIRE NEW MPV OR ELSE ACCURATE samples_time.
    time_gained     = seek and 0 or time_gained                                                --seek→(time_gained=0)
    speed           = (time_from_write>o.timeouts.pause or txt.aid=='no') and 0                --0 MEANS pause.  CHILDREN ALWAYS START PAUSED.  aid=no POSSIBLE.
                      or clip( txt.speed*(1-time_gained/.5)                                    --time_gained→0 OVER NEXT .5 SECONDS (MEASURED IN time-pos, THE astats UPDATE TIME). 
                              *(1+math.random(-o.max_random_percent,o.max_random_percent)/100) --random BOUNDS [.9,1.1] MAYBE SHOULD BE [.91,1.1]=[1/1.1,1.1].  1% SKEWED TOWARDS SLOWING IT DOWN EXCESSIVELY.
                              ,txt.speed/o.max_speed_ratio,txt.speed*o.max_speed_ratio)        --speed LIMIT RELATIVE TO CONTROLLER.  15% EXTRA WHEN USER UNPAUSES (FOR CHILDREN TO CATCH UP).
    txt.pause       = speed>0 and 'no' or 'yes' --INFERRED.
    set_speed       = speed>0 and (target~='' or samples_time)  --REQUIRE NEW MPV OR ELSE ACCURATE samples_time.
    set_pause       = speed>0     ==p.pause
    set_volume      = txt.volume+0~=p.volume
    set_aid         = txt.aid     ~='no' and txt.aid+0~=a_id  --txt.aid EITHER no OR #.  no FOR JPEG.  NEVER set no, OR ELSE YOUTUBE TAKES AN EXTRA SECOND TO LOAD (~WRONG).
    command         = ''
                      ..(set_aid       and ('%s set  aid    %s;'        ):format(command_prefix,txt.aid   ) or '')
                      ..(set_volume    and ('%s set  volume %s;'        ):format(command_prefix,txt.volume) or '')
                      ..(set_pause     and ('   set  pause  %s;'        ):format(               txt.pause ) or '')
                      ..(set_speed     and ('%s set  speed  %s;'        ):format(command_prefix,speed     ) or '')
                      ..(seek          and ('   seek %s absolute exact;'):format(               target_pos) or '')  --absolute MORE RELIABLE.  SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN ACCELERATE ITS SPEED).
    loadfile        = txt.path~=m.path and txt.path~=p.path and mp.commandv('loadfile',txt.path)  --commandv FOR FILENAMES.  FLAGS INCOMPATIBLE WITH MPV-v0.34.  RARELY, YOUTUBE MUST RELOAD. m.path BLOCKS JPEG.
    command         = command ~=''                          and mp.command (command)
    m.path          = txt.path  --BLOCK RELOAD, THEN UNBLOCK LATER (IF ~JPEG).
end
for property in ('mute pause seeking speed volume frame-drop-count audio-params/samplerate current-tracks/audio/id current-ao path af-metadata/'..label):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS table nil.  INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall. volume NOT WORKING ON ANDROID.  samplerate MAY DEPEND ON lavfi-complex.  
    do mp.observe_property(property,'native'         ,function(property,val) pcall(property_handler,property,val)  end) end --TRIGGERS INSTANTLY.  astats TRIGGERS EVERY HALF A SECOND, ON playback-restart, frame-drop-count & shutdown.
timers.auto         = mp.add_periodic_timer(o.auto_delay         ,function() pcall(property_handler             )  end)     --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.  SHOULD ALWAYS BE RUNNING FOR RELIABILITY.
timers.mute         = mp.add_periodic_timer(o.double_mute_timeout,function()                                       end)     --mute TIMER TIMES. 1SHOT.
timers.mute.oneshot = 1
timers.mute:kill()


----~300 LINES & ~7000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  
----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----PLATFORMS  windows linux darwin(Lua 5.1) android(Lua 5.2) ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-7-x86.  ANDROID HAS NO CHILD, NO ytdl & NO COURIER NEW.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----BUG: astreamselect af-command CAUSES A double_mute COMBO-BUG WHEN COMBINED WITH autocrop.lua+is1frame(albumart).  MPV FAST-FORWARDS A FEW SECONDS (GLITCH).  REPLACING astreamselect COULD FIX IT.
----FUTURE VERSION MAY HAVE IMPROVED ANDROID MECHANISM (SCREEN DOUBLE-TAP).
----FUTURE VERSION COULD REPLACE astreamselect WITH volume & amix.  astreamselect WAS A BAD DESIGN CHOICE, BUT ENABLES MORE COMPLEX INSTA-SWITCHES.
----FUTURE VERSION MAY HAVE SMOOTH TOGGLE. txtfile COULD HAVE ANOTHER LINE FOR SMOOTH TOGGLE (SMOOTH-MUTE USING t-DEPENDENT af-command).
----FOR CHILD ON ANDROID (N=1, SECOND INSTANCE) SOMEONE COULD PUBLISH mpv-android2 (is.xyz.mpv2).  ANDROID APPS ARE SINGLETONS, BUT PUBLISHING A CLONE IS FEASIBLE.  (LISTENING TO MUSIC ON PHONE IS LIKE MONO, USUALLY.)  A MORE DIFFICULT BUT ELEGANT SOLUTION WOULD BE TO TRANSFORM mpv-android INTO A CONTAINER FOR MULTIPLE AUDIO-ONLY INSTANCES (A NEW spawn COMMAND).
----FOR SURROUND SOUND, THE CONTROLLER COULD INSTA-SWITCH THROUGH ALL DEVICES TO COUNT CHANNELS.  THERE'S A RISK OF RIGHT CHANNEL ON BACK-LEFT, ETC.  CODING FOR A SURROUND SOUND SOURCE SIGNAL IS MORE COMPLICATED. 

----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----autospeed.lua IS A DIFFERENT SCRIPT INTENDED FOR PERFECTING VIDEO speed, NOT AUDIO.  o.speed CAME LATER ON.
----THIS IS LIKE 2 SCRIPTS IN 1.  A SEPARATE clock.lua COULD ALSO INCLUDE AN ALARM.  RESYNCING THE EXACT TICK EVERY MINUTE USES 0% CPU.  
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY (REQUIRING sudo) MAY BE LIKE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET.  INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----volume   = volume:...:eval  DEFAULT=1:...:once  POSSIBLE TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.  COULD BE USED FOR SMOOTH TOGGLE.
----loudnorm = I:LRA:TP         DEFAULT=-24:7:-2.  INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----acompressor       SMPLAYER DEFAULT NORMALIZER.
----firequalizer  OLD SMPLAYER DEFAULT NORMALIZER.

----ALTERNATIVE AbDays.  BOTH INDIA & CHINA ARE CHARGED.  COLOMBIA MIGHT BE POSSIBLE ({\\fscy200}%I{\\fscy100}).  MISSISSIPPI STATE FLAG IS CHARGED (1 MISSISSIPPI | 2 MISSISSIPPI | 3 MISSISSIPPI).  AN UKRAINIAN/POLISH STYLE MIGHT REQUIRE A CODE WHICH CROPS DIGITS (LIKE \fscy BUT \fcry=FONT-CROP-Y).  CONCEIVABLY ADVERTISEMENTS COULD FIT INSIDE EACH DIGIT OF A CLOCK.
        -- "    IRELAND  ÉIREANN       [ -Su-  -Mo-  -Tu-   -We-  -Th-  -Fr-  -Sa-  ]",  --LENGTH 2 WORKS BETTER ON CALENDAR, BUT NOT CLOCK.
        -- "    IRELAND  ÉIREANN       [  Domh  Luan  Márt   Céad  Déar  Aoin  Sath ]",  --Máirt & Aoine SHOULD BE LENGTH 5.  IRISH IS TOO MUCH.
        -- "    HUNGARY  MAGYARORSZÁG  [--v-- --h-- --k--    sze  -cs- --p--   szo  ]",
        -- "      Yemen  ‎اليمن‎          ‎ا[‎--ح--‎ ‎--ن--‎ ‎--ث--‎ ‎--ر--‎ ‎--خ--‎ ‎--ج--‎ ‎--س--‎ ]",  --LENGTH 1 WORKS ON CALENDAR, BUT NOT CLOCK.
        -- "    ARMENIA  ՀԱՅԱՍՏԱՆ      [  Կրկ   Երկ   Երք    Չրք   Հնգ   Ուր   Շբթ  ]",  --2XLIBRE.NET DISAGREES WITH GOOGLE.  երկշթ,հինգթ=Tue,Thu  (5 LETTERS REQUIRED.)
        -- "    ARMENIA  ՀԱՅԱՍՏԱՆ      [  կիրակ երկշթ երեքթ  չորշթ հինգթ ուրբթ շաբաթ]",  --WITH 5 LETTERS, IT'S LIKE DECIDING BTWN Sunda & Sundy. AS MANY LETTERS AS THERE ARE FINGERS ON SOMEONE'S HAND.
        -- "     RUSSIA  РОССИЯ        [  Вск   Пон   Втр    Сре   Чтв   Пят   Сбт  ]",  --USUALLY AbDays ARE LENGTH 2.  
        -- "  LITHUANIA  LIETUVA       [ -Sk-  -Pr-  -An-   -Tr-  -Kt-  -Pn-  -Št-  ]",
        -- "    ESTONIA  EESTI         [--P-- --E-- --T--  --K-- --N-- --R-- --L--  ]",  --P=SUNDAY BUT IT'S ALSO LIKE PM IN LATIN. (WORKS IN CALENDAR.)
        
