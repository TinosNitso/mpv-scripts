----NO-WORD-WRAP FOR THIS SCRIPT.  ADD CLOCK TO VIDEO & JPEG, WITH DOUBLE-MUTE TOGGLE, + AUDIO AUTO SPEED SCRIPT. CLOCK TICKS WITH SYSTEM, & MAY BE COLORED & STYLED, ON SMARTPHONE TOO. RANDOMIZES SIMULTANEOUS STEREOS IN MPV & SMPLAYER. LAUNCHES A NEW MPV FOR EVERY SPEAKER (EXCEPT ON 1 PRIMARY DEVICE CHANNEL). ADDS AMBIENCE WITH RANDOMIZATION. VOLUME, PAUSE, PLAY, SEEK, MUTE, SPEED, STOP, PATH, AID & LAG APPLY TO ALL CHILDREN. A .txt FILE IS USED INSTEAD OF PIPES.
----A STEREO COULD BE SET LOUDER IF ONE CHANNEL RANDOMLY SPEEDS UP & DOWN. A SECOND STEREO CAN BE DISJOINT FROM THE FIRST (EXTRA VOLUME).  WORKS WELL WITH MP4, MP3, MP2, M4A, AVI, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE.
----CURRENT VERSION TREATS ALL DEVICES AS STEREO. UN/PLUGGING USB STEREO REQUIRES RESTARTING SMPLAYER.  A SMALLER STEREO ADDS MORE TREBLE (BIG CHEAP STEREOS HAVE TOO MUCH BASS).  USB→3.5mm SOUND CARDS COST AS LITTLE AS $3 ON EBAY & CAN BE TAPED TO A CABLE. EACH NEW USB STEREO CREATES 2*mpv.exe IN TASK MANAGER (2*2% CPU, + 50MB RAM).  EVERY SPEAKER BOX (EXCEPT PRIMARY) GETS ITS OWN YOUTUBE STREAM, ETC. ALSO FULLY WORKS IN VIRTUALBOX. 
----IF THERE'S A BUG OR LAG IN SMPLAYER TRY Audio→Send audio to→Default audio device.  

options                      = {             
    key_bindings             = 'Ctrl+C Alt+C Alt+c',  --CASE SENSITIVE (CTRL+C=CTRL+SHIFT+c). THESE DON'T WORK INSIDE SMPLAYER.  TOGGLE APPLIES TO clocks & speed, BUT NOT TO filterchain.  C IS autocrop.lua, NOT CLOCK.  CTRL+c BREAKS.
    double_mute_timeout      =         .5 ,  --SECONDS FOR DOUBLE-MUTE-TOGGLE        (m&m DOUBLE-TAP).  SET TO 0 TO DISABLE.                    IDEAL FOR SMPLAYER.      REQUIRES AUDIO IN SMPLAYER (OR ELSE USE j&j).  VARIOUS SCRIPT/S CAN BE SIMULTANEOUSLY TOGGLED USING THESE 3 MECHANISMS. 
    double_aid_timeout       =         .5 ,  --SECONDS FOR DOUBLE-AUDIO-ID-TOGGLE    (#&# DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  ANDROID MUTES USING aid. REQUIRES AUDIO. 
    double_sid_timeout       =         .5 ,  --SECONDS FOR DOUBLE-SUBTITLE-ID-TOGGLE (j&j DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  IDEAL FOR SMARTPHONE.    REQUIRES sid (sub-create-cc-track FOR BLANK).
    extra_devices_index_list =         {} ,  --TRY {2,3,4} ETC TO ENABLE INTERNAL PC SPEAKERS OR MORE STEREOS.  1=auto  3=INTERNAL PC.  OVERLAP CAUSES INTERNAL ECHO (AVOID).  EACH CHANNEL FROM EACH device IS A SEPARATE PROCESS & STREAM.  INTERNAL PC SPEAKERS COUNT AS 2 (2 DOUBLE-MOUTHED CHILDREN).
    toggle_command           =         '' ,  --EXECUTES on_toggle, UNLESS BLANK.  'show-text ""' CLEARS THE OSD.  CAN DISPLAY ${media-title}, ${mpv-version}, ${ffmpeg-version}, ${libass-version}, ${platform}, ${current-ao}, ${af}, ${lavfi-complex}.  CAN ALSO 'show-text "'.._VERSION..'"'  OR  'set speed 1'.
    speed                    = '${speed}' ,  --EXPRESSION FOR DYNAMIC speed CONTROL, set EVERY HALF-SECOND.  CAN USE ANY MPV PROPERTY (LIKE ${percent-pos}) IN ANY LUA FORMULA.  '${speed}' IS A NULL-OP.  TOGGLES WITH DOUBLE-mute!
    -- speed                 = '     ${speed}<1.2 and ${speed}+.01 or 1    ',  --UNCOMMENT TO CYCLE speed BTWN 1 & 1.2 OVER 10s.  PRESS BACKSPACE TO RESET BACK TO 1.  REPLACE 1.2 & 1 FOR DIFFERENT BOUNDS.
    -- speed                 = 'clip(${speed}+math.random(-1,+1)/100,1,1.2)',  --UNCOMMENT TO RANDOMIZE VIDEO speed, USING A BOUNDED RANDOM WALK.  -1%,+0%,+1% EVERY HALF-SECOND, RECURSIVELY. +2% TO ADD DRIFT.
    suppress_osd             = true , --REMOVE TO VERIFY speed.
    mpv                      = {      --LIST ALL POSSIBLE mpv COMMANDS, IN ORDER OF PREFERENCE.  REMOVE THEM FOR NO CHILDREN OVERRIDE (clocks, filterchain & speed ONLY).  A COMMAND MAY NOT BE A PATH.  FIRST MATCH SPAWNS ALL CHILDREN.  NOT FOR ANDROID.  
        "mpv"                                          , --LINUX & SMPLAYER (WINDOWS)
        "./mpv"                                        , --        SMPLAYER (LINUX & MACOS)
        "/Applications/mpv.app/Contents/MacOS/mpv"     , --     mpv.app     (MAY BE CASE-SENSITIVE.)
        "/Applications/SMPlayer.app/Contents/MacOS/mpv", --SMPlayer.app     (USING TERMINAL.)
    },
    filterchain        = 'anull,dynaudnorm=g=5:p=1:m=100:b=1',  --DEFAULT=g=31:p=.95:m=10:b=0=DYNAMIC-AUDIO-NORMALIZER.  graph COMMENTARY HAS MORE DETAILS.  b=0 SOUNDS BAD WITH SMARTPHONE BACKGROUND TOGGLE.  CAN REPLACE anull WITH EXTRA FILTERS, LIKE vibrato highpass aresample.  (random) IS A RANDOM # BTWN 0 & 1, @file-loaded.
    mutelr             = 'mutel', --mutel/muter  CONTROLLER ONLY.  PRIMARY CHANNEL HAS NORMAL SYNC TO VIDEO.  HARDWARE USUALLY HAS A PRIMARY, BUT IT'S 50/50 (HEADPHONES OPPOSITE TO SPEAKERS).
    resync_delay       =     30 , --SECONDS.  RESYNC WITH THIS DELAY.  CPU TIME GOES OFF WITH RANDOM LAG.  TOO DIFFICULT TO DETECT LAG FOR ALL PLAYERS (WEBSITES CAUSE DESYNC). 
    os_sync_delay      =    .01 , --SECONDS.  PRECISION FOR SYNC TO os.time.  OPERATING SYSTEM TIME IS CHECKED EVERY 10ms FOR THE NEXT TICK.  WIN10 CMD "TIME 0>NUL" GIVES 10ms PRECISION.
    auto_delay         =    .25 , --SECONDS.  CHILDREN ONLY.  RESPONSE TIME.  THEY CHECK txtfile THIS OFTEN.
    seek_limit         =    .5  , --SECONDS.  CHILDREN ONLY.  SYNC BY seek INSTEAD OF speed, IF time_gained>seek_limit.  seek CAUSES AUDIO TO SKIP. (SKIP VS ACCELERATION.) IT'S LIKE TRYING TO SING FASTER TO CATCH UP TO THE OTHERS.
    quit_timeout       =     15 , --SECONDS.  CHILDREN ONLY.  quit IF CONTROLLER BREAKS FOR THIS LONG.  
    pause_timeout      =      5 , --SECONDS.  CHILDREN ONLY.  THEY pause INSTANTLY ON STOP, BUT NOT ON BREAK.
    max_speed_ratio    =   1.15 , --          CHILDREN ONLY.  speed IS BOUNDED BY [txt.speed/max,txt.speed*max]  1.15 SOUNDS OK, BUT MAYBE NOT 1.25.
    max_random_percent =     10 , --          CHILDREN ONLY.  DEVIATION FROM PROPER speed. UPDATES EVERY HALF A SECOND.  EXAMPLE: 10%*.5s=50 MILLISECONDS INTENTIONAL MAX DEVIATION, PER SPEAKER.  0% STILL CAUSES L/R DRIFT, DUE TO LAG & HALF SECOND RANDOM WALKS BTWN SPEEDS.
    metadata_osd       =  false , --true FOR audio STATISTICS (astats METADATA).  CONTROLLER ONLY.  SHOULD BE REMOVED IN FUTURE VERSION. MPV-v0.37+ SYNC PROPERLY WITHOUT IT. (IT WAS NECESSARY FOR OLD MPV.)
    options            = {        --CONTROLLER ONLY.  
        'sub                    no ','sub-create-cc-track yes',  --DEFAULTS=auto,no.  SUBTITLE CLOSED-CAPTIONS CREATE BLANK TRACK FOR double_sid_timeout (BEST TOGGLE).  JPEG VALID.  UNFORTUNATELY YOUTUBE USUALLY BUGS OUT UNLESS sub=no.  sid=1 LATER @playback-restart.
        'osd-scale-by-window    no ','osd-bold            yes','osd-font "COURIER NEW"',  --DEFAULTS=yes,no,sans-serif  osd-scale CAUSES ABDAY MISALIGNMENT.  COURIER NEW IS MONOSPACE & NEEDS bold (FANCY).
        'image-display-duration inf',  --DEFAULT=1  JPEG CLOCK USES inf.
        -- 'osd-border-color   0/.5',  --DEFAULT=#FF000000  UNCOMMENT FOR TRANSPARENT CLOCK FONT OUTLINE.  RED=1/0/0/1, BLUE=0/0/1/1, ETC
    },
    options_children  = {
        'vid no', 'sid no   ','vo       null       ','ytdl-format ba/best',  --DEFAULT VIDEO-ID,SUBTITLE-ID=auto.  no REDUCES CPU CONSUMPTION.  VIDEO-OUT=null BLOCKS NEW WINDOWS.  ba=bestaudio  /best FOR RUMBLE.  ytdl-raw-options CAN SET username & password (WITHOUT ANNOUNCING THEM IN TASK MANAGER).  REMOVE THIS LINE TO SEE ALL CHILDREN. THIS SCRIPT OVERRIDES ANY ATTEMPT TO CONTROL THEM.
        'keep-open     yes  ','geometry 25%        ', --keep-open MORE EFFICIENT THAN RELOADING (BACKWARDS-seek NEAR end-file).  geometry LIMITS CHILDREN.
        'msg-level all=error','priority abovenormal', --DEFAULTS all=status,normal.  BY DEFAULT SMPLAYER LOGS ALL speed CHANGES VIA CHILD terminal.  priority ONLY VALID ON WINDOWS.  
        -- 'audio-pitch-correction  no',              --DEFAULT  yes  UNCOMMENT FOR CHIPMUNK MODE (NO scaletempo# FILTER). WORKS OK WITH SPEECH & COMICAL MUSIC.  REDUCES CPU CONSUMPTION BY 5%=5*1%.  ACTIVE INDEPENDENT TEMPO SCALING FOR SEVERAL SPEAKERS USES CPU.
    },
    windows     = {}, linux = {}, darwin = {}, --CONTROLLER ONLY.  OPTIONAL platform OVERRIDES.
    android     = { 
        options = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',},  --options APPEND, NOT REPLACE. 
    },
    clocks                  = {      --TOGGLE LINES TO INCLUDE/EXCLUDE VARIOUS STYLES FROM THE LIST.  REPETITION VALID.  A SIMPLE LIST OF STRINGS IS EASY TO RE-ORDER & DUPLICATE, LIKE REPEATING Yemen FOR THE ARABIC.
        duration            = 2    , --SECONDS, INTEGER.  0/nil MEANS NO CLOCK.  TIME PER CLOCK STYLE THROUGHOUT CYCLE.  STYLE TICKS OVER EVERY SECOND SECOND. (ON THE DOUBLE.)
        offset              = 0    , --SECONDS, INTEGER. DEFAULT=0.  CHANGE STYLE ON EVENS OR ODDS? 0=EVEN.  ALL SMPLAYER INSTANCES HAVE SAME CLOCK @SAME TIME.
        DIRECTIVES_OVERRIDE = false, --SET true TO DISPLAY ALL os.date DIRECTIVE CODES & THEIR CURRENT VALUES (SPECIAL CLOCK). MAY DEPEND ON LUA VERSION.  EXAMPLES: %I,%M,%S,%a,%p,%H,%n = HRS(12),MINS,SECS,Day,A/PM,HRS,RETURN  

----    "         COUNTRY              HOUR     MINUTE   SECOND  POPULATION  [            AbDays             -=HALFSPACE  ]  {\\STYLE OVERRIDES}          \\N              ↓↓(CLOCK SIZE)                 %DIRECTIVES            ",  --"{" REQUIRED, & EVERYTHING BEFORE IT IS REMOVED.  {} ALONE REMOVES LEADING 0 FOLLOWING IT.  %n,\\N = ♪,◙ = \r,\n.  ♪ RETURNS TO TOP-LEFT, FOR NEW ALIGNMENT.  ABDAYS (ABBREVIATED-DAYS) START WITH Sun FOR ARABIC/ARMENIAN, BUT Mon FOR EUROPE.  AbDays CAN BE REPLACED WITH ANYTHING. 1 LOTE CAN BE COPIED OVER ALL THE OTHERS.  https://lh.2XLIBRE.NET/locales FOR LOCALES. ALL AbDays ARE VERIFIED INDIVIDUALLY USING GOOGLE TRANSLATE → ENGLISH/RUSSIAN.  HALF-SPACE IS BECAUSE CENTERING IS OFTEN 1-OFF, & AN EXTRA LETTER IS INVALID.  7 LETTERS MAY MEAN Sun→Sat, BUT EACH LETTER ON ITS OWN IS MEANINGLESS. HENCE SEMI-ABBREVIATED ABDAYS (SEMI-AbDays) ARE MORE VALID.  FOR VERTICAL SPELLING, USE Mon→M◙o◙n.  
        "    BELGIUM  BELGIË           BLACK    YELLOW      RED    12M       [ zon   -Ma-  -Di-  -Wo-   don   vri   -Za-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c     0\\fs55\\bord1}%I{\\c24DAFD\\bord3} %M{\\c4033EF       } %S",  --fs37=fs55*2/3 FOR LENGTH 3.  BLACK DIGITS REQUIRE THIN BORDER (bord1).  VERTICAL TRICOLOR (HORIZONTAL TAB). HEX ORDERED BGR.  CAN RECITE COUNTRIES, FROM CAPITAL BELGIUM.  %S ARE THE CORNERSTONE (ANCHOR).  CAN USE ":" OR " " BTWN DIGITS.  %a COULD GO ONTOP OF MINUTES INSTEAD OF SECONDS.  
        "    ROMANIA  ROMÂNIA          BLUE     YELLOW      RED    19M       [ dum    lun   mar   mer   joi   vin    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c7F2B00\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE       } %S",  --dumnc,marţi,viner=Sunday,Tue,Fri  ROMANIAN: dum,mar,vin=Sun,apple,wine=AMBIGUOUS.  MOLDOVA & ANDORRA SIMILAR COLORS (CHARGED).  
        "       CHAD  TCHAD            BLUE      GOLD       RED    19M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c642600\\fs55\\bord3}%I{\\c  CBFE       } %M{\\c300CC6       } %S",  --GOLD IS SLIGHTLY DARKER THAN YELLOW, & HAS LESS GREEN THAN ORANGE.  ORANGE HAS EVEN LESS GREEN.  BLUE=00 FOR BOTH.  IDEAL COLOR LIST MIXES AFRO & EURO FLAGS. 
        "          MALI                GREEN    YELLOW      RED    21M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c3AB514\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c2611CE       } %S",  --SENEGAL SIMILAR COLORS (CHARGED).  
        "     GUINEA  GUINÉE           RED      YELLOW    GREEN    14M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2611CE\\fs55\\bord3}%I{\\c16D1FC       } %M{\\c609400       } %S",  --RED IS RIGHT, EXCEPT FOR GUINEA!
        "         NIGERIA              GREEN    WHITE     GREEN   231M       [ sun    mon   tue   Wed   thu   fri    Sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c  8000\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c  8000       } %S",  --BICOLOR TRIBAND.  WHITE ALWAYS IN THE MIDDLE. ORDER ALIGNS WHITES & REDS.  
        "IVORY COAST  CÔTE D'IVOIRE    ORANGE   WHITE     GREEN    31M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c  82FF\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c449A00       } %S",  
        "    IRELAND  ÉIREANN          GREEN    WHITE    ORANGE     5M       [ sun    mon   tue   Wed   thu   fri    Sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c629B16\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3E88FF       } %S",  --Sun,wed,sat=AMBIGUOUS.  IRELAND REPRESENTS BRITAIN, LIKE HOW YEMEN REPRESENTS ARABIA.
        "      ITALY  ITALIA           GREEN    WHITE       RED    59M       [ dom    lun   mar   mer   gio   ven    sab  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c458C00\\fs55\\bord3}%I{\\cF0F5F4       } %M{\\c2A21CD       } %S",  --MEXICO SIMILAR COLORS (CHARGED). CATHOLIC, LIKE IRELAND.  Mar=TUESDAY IS THIRD, LIKE MARCH.  Mer ALSO THIRD (Wed).  domino's ON SUNDAY!
        "         FRANCE               BLUE     WHITE       RED    68M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cA45500\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c3541EF       } %S",  --mard,mercr,jeudi=Tue,Wed,Thu  mer,jeu=sea,game=AMBIGUOUS. THURSDAY=GAMEDAY.  Sam SEEMS AMBIGUOUS.  LENGTH 3 BY COMPARISON TO ITALIAN.  LOWERCASE IMPROVES SYMMETRY. WHAT'S CAPITAL ARE THE COLORS UNDERLYING THE SPELL.
        "       PERU  PERÚ             RED      WHITE       RED    34M       [ dom    lun   mar   mié   jue   vie    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2310D9\\fs55\\bord3}%I{\\cFFFFFF       } %M{\\c2310D9       } %S",  --BICOLOR.  marts=Tuesday. mar(SPANISH)=Море(RUSSIAN)=sea=AMBIGUOUS.  CANADA MIGHT BE SIMILAR BUT WITH REDUCED HRS & SECS fs.
        "    AUSTRIA  ÖSTERREICH       RED    ◙ WHITE  ◙    RED     9M       [ Son    mon  -Di-  -Mi-   don   fri   -Sa-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c2E10C8\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c2E10C8       }◙%S",  --BICOLOR.  HORIZONTAL TRIBAND (VERTICAL TAB).  LIKE A TAB FROM THE FLAG.  BLACK Day IS POSITIONED WITH BLACK BAR ON SCREEN-RIGHT. 
        "    HUNGARY  MAGYARORSZÁG     RED    ◙ WHITE  ◙  GREEN    10M       [ vasr   htfő -ked- -sze-  Cstö  pétk  -sot- ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c3929CE\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c507047       }◙%S",  --Cstö CAPITALIZED.  vasárn=Sunday (LENGTH 6 NEEDED).  
        " LUXEMBOURG  LËTZEBUERG       RED    ◙ WHITE  ◙   CYAN    <1M       [ Son    mon  -Dë-  -Më-   Don   fre   -Sa-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c4033EF\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\cE0A300       }◙%S",  --dëns,Mëtw,Donn=Tue,Wed,Thu (LENGTH 4 NEEDED.)  
        "NETHERLANDS  NEDERLAND        RED    ◙ WHITE  ◙   BLUE    18M       [ zon   -Ma-  -Di-  -Wo-   don   vri   -Za-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c251DAD\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c85471E       }◙%S",  --Zon,zat=Sun,AMBIGUOUS  PARAGUAY & CROATIA ARE (CHARGED) SIMILAR COLORS.  YUGOSLAVIA WAS CHARGED REVERSE.  Vr=5DAY  
        "      Yemen  ‎اليمن‎             اRED    ◙ WHITE  ◙  BLACK    34M       [ ‎الأحد‎   ‎الاثن‎  ‎ثلاثء‎  ‎أربعء‎  ‎خميس‎  ‎جمعة‎  ‎-سبت-‎ ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c2611CE\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\c     0\\bord1}◙%S",  --fs28=fs55/2 FOR LENGTH 4.  USUALLY AbDays ARE LENGTH 1.  LRM=LEFT_TO_RIGHT_MARK='‎'='\xE2\x80\x8E' IS ON EITHER SIDE OF ARABIC WORDS.  ALM (ARABIC LETTER MARK) GOES THE OTHER WAY!  YEMEN REPRESENTS ARABIA, SOUTH OF SAUDI.  ARABIC & HEBREW ARE RIGHT-TO-LEFT & ARE ALLOWED A LEFT-TAIL.  THESE ARE PROPERLY SPACED FOR COURIER NEW BOLD.  SUNDAY=1DAY=‎الأحد‎.  1=ا="a" FOR ALIGNMENT (‎اليمن‎="alyaman").
        "      SIERRA LEONE            GREEN  ◙ WHITE  ◙   BLUE     9M       [ sun    mon   tue   Wed   thu   fri    Sat  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c3AB51E\\fs55\\bord3}%I{\\cFFFFFF       }◙%M{\\cC67200       }◙%S", 
        "          GABON               GREEN  ◙ YELLOW ◙   BLUE     2M       [ dim    lun   mar   mer   jeu   ven    sam  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c609E00\\fs55\\bord3}%I{\\c16D1FC       }◙%M{\\cC4753A       }◙%S", 
        "         BOLIVIA              RED    ◙ YELLOW ◙  GREEN    12M       [ dom    lun   mar   mié   jue   vie    sáb  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c1C29DA\\fs55\\bord3}%I{\\c  E4F4       }◙%M{\\c337A00       }◙%S",  
        "        MAURITIUS       RED ◙ BLUE   ◙ YELLOW ◙  GREEN     1M       [ dim    lin   mar   mer  -ze-   van    sam  ]  {\\an3\\c3624EB\\fs37\\bord2}%a◙{\\c6D1A13\\fs55\\bord3}%I{\\c  D6FF       }◙%M{\\c50A600       }◙%S",  --MORISYEN: QUAD-COLOR QUAD-BAND.  ISLANDS NEAR MADAGASCAR.  
        "    ARMENIA  ՀԱՅԱՍՏԱՆ         RED    ◙  BLUE  ◙ ORANGE     3M       [-Կիր-  -Երկ-  Երքթ -Չրք-  Հնգթ -ւրբ-  -շբթ- ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c1200D9\\fs55\\bord3}%I{\\cA03300       }◙%M{\\c  A8F2       }◙%S",  --UPPERCASE SOMETIMES REQUIRED.  Կիր=Sun  2XLIBRE.NET DISAGREES WITH GOOGLE.  
        "     RUSSIA  РОССИЯ           WHITE  ◙  BLUE  ◙    RED   147M       [-Вс-   -Пн-  -вт-  -Ср-  -Чт-  -Пт-   -Сб-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cFFFFFF\\fs55\\bord3}%I{\\cA73600       }◙%M{\\c1827D6       }◙%S",  --Вт=W  Ч~=4  SLOVENIA HAS SIMILAR COLORS (CHARGED). SERBIA IS CHARGED REVERSE.  THE COLORS DICTATE THE MEANING OF THE LETTERS.  
        "   BULGARIA  БЪЛГАРИЯ         WHITE  ◙ GREEN  ◙    RED     6M       [-Нд-   -Пн-  -вт-  -Ср-  -Чт-  -Пт-   -Сб-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\cFFFFFF\\fs55\\bord3}%I{\\c  9900       }◙%M{\\c    CC       }◙%S", 
        "  LITHUANIA  LIETUVA          YELLOW ◙ GREEN  ◙    RED     3M       [ sekm   Pirm  antr  tred -ket-  penk   šetd ]  {\\an3\\c     0\\fs28\\bord0}%a◙{\\c13B9FD\\fs55\\bord3}%I{\\c446A00       }◙%M{\\c2D27C1       }◙%S",  --Pirm CAPITALIZED.           USUALLY AbDays ARE LENGTH 2.  antrd=Tue(LENGTH 5 NEEDED).  COUNTS FROM Mon (3DAY,5DAY = Wed,Fri).
        "    ESTONIA  EESTI            BLUE   ◙ BLACK  ◙  WHITE     1M       [ pühap  esmas teisp kolmp nelja reede  laupä]  {\\an3\\c     0\\fs22\\bord0}%a◙{\\cCE7200\\fs55\\bord3}%I{\\c     0\\bord1}◙%M{\\cFFFFFF\\bord3}◙%S",  --fs22=fs55*2/5 FOR LENGTH 5. USUALLY AbDays ARE LENGTH 1.  neljap=Thu  nelja=4=AMBIGUOUS  (THURSDAY=4DAY)  FUTURE VERSION MIGHT BE LENGTH 4, BECAUSE IT'S ESTONIAN...
        "    GERMANY  DEUTSCHLAND      BLACK  ◙  RED   ◙   GOLD    85M       [ Son    mon  -Di-  -Mi-   don   fri   -Sa-  ]  {\\an3\\c     0\\fs37\\bord0}%a◙{\\c     0\\fs55\\bord1}%I{\\c    FF\\bord3}◙%M{\\c  CCFF       }◙%S",  --Donstg=Thu  Do=AMBIGUOUS(Di?).
     -- "          Wedge               BIG    : MEDium : Little   tiny                                                       {\\an3       \\fs70\\bord2}{}%I{          \\fs42      }:%M{\\fs25          }:%S{\\fs15          } %a",  --RATIO=.6  DIAGONAL PATTERN.  MY FAV.
----STYLE CODES: \\,N,an#,fs#,bord#,c######,fscx##,alpha##,b1,fn* = \,NEWLINE,ALIGNMENT-NUMPAD,FONT-SIZE(p),BORDER(p),COLOR,FONTSCALEX(%),TRANSPARENCY,BOLD,FONTNAME  (DEFAULT an0=an7=TOPLEFT)    MORE: shad#,be1,i1,u1,s1,fr##,fscy## = SHADOW(p),BLUREDGES,ITALIC,UNDERLINE,STRIKEOUT,FONTROTATION(°ANTI-CLOCKWISE),FONTSCALEY(%)  EXAMPLES: USE {\\alpha80} FOR TRANSPARENCY. USE {\\fscx130} FOR +30% IN HORIZONTAL.  A TRANSPARENT clock CAN BE BIGGER. be ACTS LIKE SEMI-BOLD.  IDEAL LATIN/CYRILLIC FONTS (fn*) MAYBE DIFFERENT.

    },
    params = {N=0,pid},  --params DECLARATION.  N=0 is_controller.  N=1 IS FIRST-CHILD & PROVIDES FEEDBACK.  PARENT PROCESS-ID DETERMINES txtfile THE CHILDREN READ FROM.  ALTERNATIVE IS TO DEFINE ENVIRONMENTAL VARIABLE/S FOR CHILDREN, BUT o.params IS SIMPLER.
}
o,p,m,timers = {},{},{},{}                         --o,p=options,PROPERTIES  m=MEMORY={map,graph}  timers={mute,aid,sid,playback_restarted,auto,os_sync,osd}  playback_restarted BLOCKS THE PRIOR 3.
txt,devices,clocks,abdays,LOCALES = {},{},{},{},{} --txtfile IS WRITTEN FROM txt.  devices=LIST OF DEVICES WHICH WILL ACTIVATE, STARTING WITH EXISTING audio-device.  LOCALES IS LIST OF SUB-TABLES, FOR LOTE. NEVER USED BY CHILDREN (UNLESS THEY ALSO HAVE A clock TOO).  os.setlocale('RUSSIAN') LITERALLY BLUE-SCREENS (MPV HAS ITS OWN BSOD).

function typecast(arg)  --ALSO @script-message, @apply_astreamselect & @property_handler.  load INVALID ON MPV.APP.  THIS script-message CAN REPLACE ANY OTHER.
    return   type(arg)=='string' and loadstring('return '..arg)() or arg
end

function  gp(property)  --ALSO @property_handler.               GET-PROPERTY
    p       [property]=mp.get_property_native(property)  --mp=MEDIA-PLAYER
    return p[property]
end

function round(N,D)  --@property_handler & @clock_update.  N & D ARE number/string/nil.   FFMPEG SUPPORTS round, BUT NOT LUA.  ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1).
    D = D or 1
    return N and math.floor(.5+N/D)*D  --round(N)=math.floor(.5+N)
end

function clip(N,min,max)  --@property_handler.  N, min & max ARE number/nil.  FFMPEG SUPPORTS clip, BUT NOT LUA.
    return N and min and max and math.min(math.max(N,min),max)  --MIN MAX MIN MAX
end

math.randomseed(os.time()+mp.get_time()) --UNIQUE EACH LOAD.  os.time()=INTEGER SECONDS FROM 1970.  mp.get_time()=μs IS MORE RANDOM THAN os.clock()=ms.  os.getenv('RANDOM')=nil
random        = math.random              --MAY SIMPLIFY SCRIPT-MESSAGING.
p  .platform  = gp('platform') or os.getenv('OS') and 'windows' or 'linux' --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = {}                                                         --DEFAULT={}
for  opt,val in pairs(options) 
do o[opt]     = val end               --CLONE
require 'mp.options'.read_options(o)  --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.
for  opt,val in pairs(o)
do o[opt] = type(options[opt])~='string' and typecast(val) or val end  --NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  
N         = o.params.N  --N ABBREVIATES CHILD-PAIR# (0, 1, OR MORE COME IN PAIRS).

for _,opt in pairs(o[p.platform].options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(N==0  and o.options   or o.options_children)                                   
do  command    = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command        = command and mp.command (command)
for  opt,val in pairs(o[p.platform])  
do o[opt]      = val end              --platform OVERRIDE.
label          = mp.get_script_name() --aspeed FILENAME MUSTN'T HAVE SPACES, BUT ITS DIRECTORY CAN. 
command_prefix = o.suppress_osd  and 'no-osd' or ''

for abday in ('Sun Mon Tue Wed Thu Fri Sat'):gmatch('[^ ]+') do table.insert(abdays,abday) end --MORE RIGOROUS CODE COULD SET abdays[abday..'%l*']=abday.  LIKE Su,Sun,Sunday=Su,Su,Su.  FUTURE LUA COULD HAVE %a=Su OR %a=sun.  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string/nil, EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
for      _,clock in pairs(o.clocks) 
do if type(clock)        == 'string'                                                                        --STRINGS ONLY.  SPLITTING THE STRINGS IN HALVES OR THIRDS (IN options) WOULD BE MORE COMPLICATED.
    then   clock          = (p.platform=='android' and clock: find('ր') and clock: gsub('%%a','') or clock) --NO-ARMENIAN OVERRIDE FOR ANDROID.  η EXISTS BUT NOT BACK-TO-FRONT-η.  ARMENIA GOOD, ARMENIAN BAD.
                            :gsub('◙','\\N'):gsub('♪','%%n')                                                --◙,♪ = \N,%n  ARE PREFERRED. ♪ RETURNS TO TOP-LEFT.  
         LOCALE,gmatch    = {},(clock: gmatch('%[.*%]')() or ''):gmatch('[^%[ %]]+')                        --LOCALE HAS ABDAYS AS KEYS.  ABDAY ITERATOR.  '.' IS EVERYTHING.  '*' MEANS LONGEST MATCH OR NOTHING.  "[]()-" ARE MAGIC.
         for _,abday in pairs(abdays) 
         do LOCALE[abday] = (gmatch() or abday):gsub('%-%-','‎ ‎'):gsub('%-','{\\fscx50}‎ ‎{\\fscx100}') end --LOCALE OR DEFAULT.  "-"=HALF-SPACE.  EACH SPACE HAS LRM ON EITHER SIDE FOR PROPER ALIGNMENT.
         table.insert(clocks ,clock: gmatch('{.*')()) 
         table.insert(LOCALES,LOCALE) end end  

if o.clocks.DIRECTIVES_OVERRIDE  
then clocks,LOCALES  = {''},{{}}      --ONLY 1.  NO-LOCALES.
    for N            = 0,128          --LOOP OVER ALL POSSIBLE BYTECODE FROM 0→0x80.
    do char          = string.char(N) --A,a = 0x41,0x61 = 65,97  
       DIRECTIVE     =   '%'..char
       invalid       = os.date(DIRECTIVE):sub(1,1)=='%'  --os.date RETURNS %char IF INVALID (SKIP). 
       clocks[1]     =    clocks[1]..(invalid and '' or (char=='a' and '\n' or '')..('%%%s="%s"  '):format(DIRECTIVE,DIRECTIVE)) end end  --NEWLINE @a.
o.clocks.offset      =  o.clocks.offset   or 0                         --DEFAULT=0 s.
clocks               = (o.clocks.duration or 0)==0 and {} or clocks    --duration=nil/0 MEANS clock=nil.
directory            = require 'mp.utils'.split_path(gp('scripts')[1]) --ASSUME PRIMARY DIRECTORY IS split FROM WHATEVER THE USER ENTERED FIRST.  mp.get_script_directory() & mp.get_script_file() DON'T WORK THE SAME WAY.
__script             = ('--script=%s/%s.lua'):format(directory,label)  --"/" FOR WINDOWS & UNIX. .lua COULD BE .js FOR JAVASCRIPT.  
directory            = mp.command_native({'expand-path',directory})    --command_native EXPANDS '~/', REQUIRED BY io.open.
txtpath              = ('%s/%s-pid%d.txt'):format(directory,label,o.params.pid or gp('pid'))  --txtfile INSTEAD OF PIPES.
if N==0 then clock   = clocks[1] and mp.create_osd_overlay('ass-events')  --AT LEAST 1.  ass-events IS THE ONLY VALID OPTION.   COULD ALSO SET res_x & res_y FOR BETTER THAN 720p FONT QUALITY.
    o.auto_delay     = .5                                             --CONTROLLER auto_delay EXISTS ONLY TO STOP timeout. 
    p['script-opts'] = mp.get_property('script-opts')                 --string FOR SPAWNING; MAY BE BLANK.  ytdl_hook OPTS POTENTIALLY UNSAFE.  
    p['script-opts'] = p['script-opts']=='' and '' or p['script-opts']..','  --APPEND ','.  LEADING ',' DISALLOWED.  EXISTING opts GO FIRST.
    
    table.insert   (devices,   gp('audio-device'))   --"wasapi/" (WINDOWS AUDIO SESSION APP. PROGRAM. INTERFACE) OR "pulse/alsa" (LINUX) OR "coreaudio/" (MACOS).
    for _,index in pairs(o.extra_devices_index_list) --ESTABLISHES devices WHICH ACTIVATE (IF mpv).  DUPLICATES ALLOWED.  WOULDN'T MAKE SENSE FOR CHILDREN.
    do table.insert(devices, ( (p['audio-device-list'] or gp('audio-device-list')) [index] or {}).name ) end
    
    for _,command in pairs(o.mpv)  --CONTROLLER command LOOP. 
    do  mpv               = mpv or mp.command_native({'subprocess',command}).error_string~='init' and command end  --error_string=init IF INCORRECT.  BREAKS ON FIRST CORRECT command.  subprocess RETURNS NATIVELY INTO LUA, SO IS MORE ELEGANT THAN run IN THIS CASE.
    for N,audio_device in pairs(devices) 
    do  __audio_device    = audio_device~='auto' and '--audio-device='..audio_device or nil  --auto=nil
    for mutelr in ('mutel muter'):gmatch('[^ ]+') 
        do  __script_opts = mpv and not (N==1 and mutelr==o.mutelr) and ('--script-opts=%s%s-mutelr=%s,%s-params={N=%d;pid=%d}'):format(p['script-opts'],label,mutelr,label,N,p.pid)  --ONLY IF mpv & NOT PRIMARY CHANNEL.  mutelr & audio-device VARY.  CHILDREN WITH 2 MOUTHS MAY BE MUTED LEFT OR RIGHT.
            run_mpv       = __script_opts     and mp.command_native({'run',mpv,'--idle','--no-config',__script,__script_opts,__audio_device}) end end end  --CHILD SPAWN.  command_native FOR SYMBOLS/nil.  idle/config MUST BE SET IN ADVANCE.  --no-config BLOCKS DOUBLE-LOADING.


graph=('stereotools,astats=.5:1,%s,asplit[0],stereotools=%s=1[1],[0][1]astreamselect=2:%%d'):format(o.filterchain,o.mutelr)

----lavfi         = [graph] [ao]→[ao] LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  aspeed IS LIKE A MASK FOR audio, WHICH DISJOINTS IT. 
----stereotools   = ...:mutel:muter DEFAULT=...:0:0  (BOOLS)  IS THE START.  MAY BE SUPERIOR @CONVERSION→stereo FROM mono & SURROUND-SOUND. astats MAY NEED STEREO FOR RELIABILITY. ALSO MUTES EITHER SIDE. FFMPEG-v4 INCOMPATIBLE WITH softclip.
----dynaudnorm    = ...:g:p:m:...:b DEFAULT=...:31:.95:10:...:0  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:...:BOUNDARY_MODE[0/1]  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  b=NO_FADE. INSERTS BEFORE asplit DUE TO INSTA-TOGGLE FRAME-TIMING. IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31).  ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. IT'S USED SEVERAL TIMES SIMULTANEOUSLY: EACH SPEAKER + VARIOUS GRAPHICS (lavfi-complex).  IT CAN BE TESTED WITH VARIOUS FILTERS BEFORE IT.
----astats        = length:metadata (SECONDS:BOOL)  CONTINUAL SAMPLE COUNT WAS BASIS FOR 10 HOUR SYNC. TESTED @OVER 1 BILLION. ~0% CPU USAGE. ALL PRECEDING FILTERS MUST BE FULLY DETERMINISTIC OVER 10 HRS, BUT NOT FILTERS FOLLOWING. MPV-v0.38 CAN SYNC ON ITS OWN WITHOUT astats (BUT NOT v0.36).
----astreamselect = inputs:map      IS THE FINISH.  ENABLES INSTA-TOGGLE. "af-command" NOT "af toggle". DOUBLE REPLACING GRAPH OR FULL TOGGLE CAUSES CONTROLLER GLITCH. SHOULD BE PLACED LAST BECAUSE SOME FILTERS (dynaudnorm) DON'T INSTANTLY KNOW WHICH STREAM TO FILTER, BECAUSE THAT'S DETERMINED BY af-command (0 OR 1). ON=1 BY DEFAULT.
----anull           PLACEHOLDER.
----asplit          [ao]→[0][1]=[no-mutelr][mutelr]


function file_loaded()
    block_path,playback_restarted = true,not gp('seeking')  --playback_restarted UNBLOCKS DOUBLE-TAPS.
    for _,track in pairs(gp('track-list'))  
    do block_path   = block_path and track.type~='audio' end                          --CONTROLLER BLOCKS JPEG.  LOOP OVER ALL TRACKS TO CHECK AUDIO EXISTS.  THE CHILDREN *CAN'T* BLOCK JPEG - IT'S INDISTINGUISHABLE FROM FAILED YOUTUBE, & MUST KEEP RELOADING ASAP.
    m.map           = N~=0       and 1 or 0                                           --0,1=OFF,ON=NO-MUTE,MUTE  CHILDREN ALWAYS mutelr.
    m.graph         = graph: format(m.map):gsub('%(random%)','('..random()..')')
    mp.commandv('af','pre',('@%s:lavfi=[%s]'):format(label,m.graph))                  --commandv FOR BYTECODE.  
end

function apply_astreamselect(map)  --@playback-restart, @on_toggle & @property_handler.
    map    = typecast(map) or (N~=0 or not OFF and mpv and txt.seeking=='no') and 1 or 0 --DEDUCE INTENDED map.  1=MUTED INVALID WITHOUT CHILDREN, WHO ARE ALWAYS MUTE.  ALWAYS UNMUTE WHEN FIRST-BORN IS seeking.
    if map==m.map and not af_observed or gp('seeking') then return end  --return CONDITIONS.  EXCESSIVE af-COMMANDS CAUSE LAG. FAILS WHEN seeking (audio-params=nil?).  
    
    m .map,af_observed = map,nil 
    mp.command(('af-command %s map %d %s'):format(label,map,target or ''))  --target ACQUIRED @property_handler.  
end

function on_toggle()  --@script-message, @script-binding & @property_handler.  ALSO DURING YOUTUBE LOAD & FOR JPEG.  INSTA-TOGGLE (SWITCH). CHILDREN MAINTAIN SYNC WHEN OFF.
    OFF     = not OFF --INSTANT UNMUTE IN txtfile.  
    mp.add_timeout(OFF and .4 or 0,function() txt.mute=OFF end)  --DELAYED MUTE ON, OR ELSE LEFT CHANNEL CUTS OUT A TINY BIT.  txtfile IS TOO QUICK FOR af-command!  ALTERNATIVE GRAPH REPLACEMENT INTERRUPTS PLAYBACK.  A FUTURE VERSION SHOULD REMOVE THIS, & NEVER USE astreamselect. volume SHOULD RESPOND FASTER.
    
    clock_update()  --INSTA-clock_update.
    apply_astreamselect()
    
    resync  = not OFF              and os_sync()  --OPTIONAL
    command = o.toggle_command~='' and mp.command(command_prefix..' '..o.toggle_command)
end
for key in o.key_bindings: gmatch('[^ ]+') 
do binding_name = label..(binding_name and '_'..key or '')  --THE FIRST key IS SPECIAL.
    mp.add_key_binding(key,binding_name,on_toggle) end  

function clock_update()  --@os_sync & @on_toggle.
    clock_remove = clock and OFF and clock:remove()  --clock OFF SWITCH.  COULD BE MADE SMOOTH BY VARYING {\\alpha##} IN clock.data.
    if  OFF or not clock then return end
    abday,clock_index = os.date('%a'),round((os.time()+o.clocks.offset+1)/o.clocks.duration)%#clocks+1          --WHAT DAY IS IT?  INDEX BTWN 1 & #clocks.  SMOOTH TRANSITIONS BTWN STYLES SEEMS TOO DIFFICULT.  THE TIMEFROM1970 IS NEEDED JUST TO DECIDE WHICH STYLE! MPV MIGHT HAVE THE SAME CLOCK STYLE SIMULTANEOUSLY ALL OVER THE EARTH, REGARDLESS OF TIMEZONE OR DST, FOR THE SAME o.clocks.
    clock.data = os.date(clocks[clock_index]):gsub('{}0','{}'):gsub(abday,LOCALES[clock_index][abday] or abday) --REMOVE LEADING 0 AFTER "{}" NULL-OP STYLE CODE.
    clock:update()
end
timers.osd=mp.add_periodic_timer(1,clock_update) --THIS 1 MOSTLY DETERMINES THE EXACT TICK OF THE clock, WHICH IS USUALLY IRRELEVANT TO AUDIO.  LOSES 6→20 MILLISECONDS/MINUTE (@TICK) WITHOUT resync.  oneshot & pcall TIMERS ARE WORSE.
clock_update()                                   --INSTANT clock.  THIS REQUIRES SOME lavfi-complex TRICK.

function os_sync()  --@script-message, @property_handler & @playback-restart.  RUN 10ms LOOP UNTIL SYSTEM CLOCK TICKS. os.time() HAS 1s PRECISION WHICH MAY BE IMPROVED TO 10ms, TO SYNC CHILDREN. 
    if not time1 then timers.os_sync:resume()  --time1=nil IF NOT ALREADY SYNCING (ACTS AS SWITCH). 
        time1 = os.time()  
        return end
    sync_time = os.time()  --@EXACT TICK OF CLOCK.
    
    if sync_time>time1 then mp2os_time,time1 = sync_time-mp.get_time(),nil  --",nil" REQUIRED (RARELY).  mp2os_time=os_time_relative_to_mp_clock  IS THE CONSTANT TO ADD TO MPV CLOCK TO GET TIMEFROM1970 TO WITHIN 10ms.  WARNING: os.clock WORKS EQUALLY WELL ON WINDOWS, BUT NOT UNIX+VIRTUALBOX (CPU TIME DIFFERENT).  mp.get_time()=os.clock()+CONSTANT  (WITHIN HALF A MILLISECOND.)  
        timers.os_sync:kill()
        timers.osd    :kill()  --SYNC TICK TO SYSTEM.  
        timers.osd    :resume() 
        clock_update() end
end
timers.os_sync=mp.add_periodic_timer(o.os_sync_delay,os_sync)

function    event_handler(event)
    event = event.event
    if      event=='file-loaded' then file_loaded() 
    elseif  event=='end-file'    then playback_restarted,block_path = nil  --INSTA-BLOCKS TOGGLE-TIMERS.  ALSO COULD pause CHILDREN.  ~map_restart RE-RANDOMIZES.
    elseif  event=='shutdown'    then os.remove(txtpath) --NO RECYCLE BIN. DELETED EVEN IF CONTROLLER BUGS OUT. 
    else    timers.playback_restarted:resume()             --UNBLOCKS TOGGLE-TIMERS.
            initial_time_pos = nil                       --RESET SAMPLE COUNT FOR OLD MPV.
            m.map            = N~=0 and 1 or 0           --RESTART VALUE. 
            apply_astreamselect()  
            os_sync()
            for N = 1,4 do mp.add_timeout(2^N,os_sync) end end --RESYNC ON EXPONENTIAL TIMEOUTS, DUE TO HDD LAG. 0 2 4 8 16 SECONDS.
end 
for event in ('file-loaded end-file shutdown playback-restart'):gmatch('[^ ]+') 
do mp.register_event(event,event_handler) end
timers.playback_restarted = mp.add_periodic_timer(.01,function() playback_restarted = true end)  --playback-restart CAN TRIGGER BEFORE aid, BY LIKE 1ms, FOR albumart.

function property_handler(property,val) --ALSO @timers.auto.  txtfile INPUT/OUTPUT.  ONLY EVER pcall, FOR RELIABLE INSTANT write & SIMULTANEOUS io.remove.
    p[property or ''] = val             --p['']=nil  DUE TO IDLER.
    seeking           = (p.seeking or  not p['audio-params/samplerate'] or p.pause) and 'yes' or 'no' --COULD BE RENAMED not_playing_audio, OR STALLED.  IF FIRST-CHILD seeking/PAUSED, PARENT MUST UNMUTE.  ALSO samplerate=nil OCCURS AS YOUTUBE LOADS.  (AGGRESSIVELY UNMUTE.)  
    speed             =       N==0     and not (property or OFF or p.pause) and typecast(mp.command_native({'expand-text',o.speed})) or p.speed  --~property MEANS IDLER.  speed=p.speed UNLESS CONTROLLER SETS EVERY HALF-SECOND, UNLESS OFF OR PAUSED.  
    set_speed         = p.speed~=speed and mp.command(('%s set speed %s'):format(command_prefix,speed))  --CONTROLLER TITULAR command.
    samples_time      =           property=='af-metadata/'..label and val['lavfi.astats.Overall.Number_of_samples']/p['audio-params/samplerate']  --ALWAYS A HALF INTEGER, OR nil.  TIME=SAMPLE#/samplerate  (SOURCE SAMPLERATE) 
    af_observed       =           property=='af' or af_observed  --af-command-OVERRIDE.  af/vf OFTEN RESET GRAPH STATES, BUT WITHOUT TRIGGERING playback-restart!
    if not mp2os_time or          property=='af' or set_speed and property=='speed'  --5 return CONDITIONS.  1) AWAIT SYNC.  2) af_observed.  3) set_speed OBSERVATION ENDS HERE. 
        or N         == 0 and not property  and seeking=='no'    --4) CONTROLLER IDLER  ENDS HERE, UNLESS JPEG OR PAUSED/seeking. IT DOES write OBSERVATIONS.  seeking SAVES YOUTUBE LOAD.  AN ISSUE WITH MANY DIRECT LINKS TO 1 function IS COMPLICATED RETURNS.
        or N         ~= 0 and     property  and not samples_time --5) CHILD OBSERVATION ENDS HERE, EXCEPT ON astats TRIGGER. CONTROLLER PROCEEDS.
    then return end  
    os_time           =  mp2os_time+mp.get_time()  --TIMEFROM1970 PRECISE TO 10ms.
    target            =  target or seeking=='no'           and (mp.command(('af-command %s map %d astreamselect'):format(label,m.map)) and 'astreamselect' or '')  --NEW MPV OR OLD. v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  TARGETED COMMANDS WERE INTRODUCED WITH time-pos BUGFIX.  astreamselect ONLY WORKS AFTER samples_time.
    resync            = (property=='frame-drop-count'      or  os_time-sync_time>o.resync_delay) and os_sync() --ON_LAG & EVERY MINUTE.  ON_LAG COULD MULTI-RESYNC (LINK TO playback-restart).
    initial_time_pos  =  property~='frame-drop-count'      and initial_time_pos or target==''    and samples_time  and samples_time>20 and gp('time-pos')-samples_time  --FOR OLD MPV.  EXCESSIVE LAG RESETS SAMPLE COUNT.  v0.36 CAN'T SYNC WITHOUT astats. BOTH MP4 & MP3 LAGGED BEHIND THE CHILDREN. time-pos, playback-time & audio-pts WORKED WELL OVER 1 MINUTE, BUT NOT 1 HOUR.  SAMPLE COUNT STABILIZES WITHIN 20s (YOUTUBE+lavfi-complex). IT'S ALWAYS A HALF-INTEGER @MEASUREMENT.  initial_time_pos=initial_time_pos_relative_to_samples_time  THIS # STAYS THE SAME FOR THE NEXT 10 HOURS. 
    p['time-pos']     =  initial_time_pos and samples_time and initial_time_pos+samples_time     or gp('time-pos') or 0  --0 DURING YOUTUBE LOAD TO STOP timeout.  OLD MPV USES ALT-METRIC WHOSE CHANGE IS BASED ON astats (METRIC SWITCH). 
    txtfile           = io.open(txtpath)  --MODES r/r+ WORK.  ALTERNATIVE io.lines RAISES ERROR.  CONTROLLER READS TOO, FOR FEEDBACK. 
    if txtfile        
    then lines        = txtfile: lines()  --ITERATOR RETURNS 0 OR 7 LINES, AS function. 
        txt.path      =          lines()  --LINE1=path, SOMETIMES BLANK.  EXTRA \r BYTE IF NOTEPAD.EXE EDITS txtfile.
        for line in ('aid volume speed os_time time_pos seeking'):gmatch('[^ ]+')  --LINES 2→7.
        do txt[line]  = txt.path and lines() or txt[line] end 
        txtfile: close()          --NEEDED FOR win32 os.remove@shutdown (DEPENDS ON BUILD).
        apply_astreamselect() end --BUGFIX FOR SLOW FIRST-CHILD, AUTO-DEDUCES map.  LONG YOUTUBE VIDEO-seeking TENDS TO GLITCH.  ALL FAMILY MEMBERS HAVE 2 MOUTHS - THE PARENT UNMUTES ONE OF ITS OWN IF THE FIRST-BORN IS SLOW.  FOR TESTING, GIVE CHILD1 ITS OWN VIDEO & THEN MAKE IT seek. 
    
    if  N           == 0 then for key in ('mute aid sid'):gmatch('[^ ]+')            
        do toggle    = property== key and playback_restarted and (not timers[key]:is_enabled() and (timers[key]:resume() or 1) or on_toggle()) end 
        osd_message  = samples_time   and not OFF            and o.metadata_osd                and mp.osd_message(mp.get_property_osd('af-metadata/'..label):gsub('\n','    '))  --TAB EACH STAT (TOO MANY LINES), UNLESS OFF.
        txt.speed    = seeking=='yes' and   0     or speed    --seeking→pause FIXES PLAYLIST/YOUTUBE STARTING GLITCHES.
        txt.path     = not block_path and p.path  or ''       --BLANK @load-script & @JPEG.  ALWAYS RELAY path UNLESS block_path.  YOUTUBE SHOULD RELOAD FREELY & INSTANTLY, AFTER FAILURE.
        txt.aid      =                    p.aid   or 'no'     --no    @load-script.  aid=number/string/false  a_id=number/nil=current-tracks/audio/id UNNECESSARY.
        txt.volume   = (txt.mute or p.mute) and 0 or p.volume --OFF-SWITCH & mute.
        txt.os_time,txt.time_pos = round(os_time,.001),round(p['time-pos'],.001) end --ms PRECISION.
    if   mpv  and N == 0 or N==1 and txtfile and txt.seeking ~= seeking  --N=0,1 MAY write.  txtfile=nil AFTER shutdown.  FEEDBACK INITIALLY LAGS IF txtfile INACCESSIBLE.  N=1 COULD ALSO PROVIDE FEEDBACK @ITS shutdown.  
    then txt.seeking =      N==1 and seeking or  txt.seeking or seeking  --LINE7 OF txtfile CONTROLLED BY FIRST-BORN. ALL PLAYERS ARE DEAF & HEAR NOTHING.  CONTROLLER seeking SETS txt.speed=0.  
        write        = ''
        for line in ('path aid volume speed os_time time_pos seeking'):gmatch('[^ ]+') 
        do write     = write..txt[line]..'\n' end --NO RETURN BYTE \r.
        txtfile      = io.open(txtpath,'w')       --MODES w/w+ WORK.  MPV.APP REQUIRES txtfile BE WELL-DEFINED.
        txtfile: write(write)                     --A PRECAUTION: NO ARBITRARY COMMANDS OR SETS (property NAMES). A set COULD HOOK AN UNSAFE EXECUTABLE, SIMILAR TO PIPING TO A SOCKET. DIFFERENT LINES MIGHT REQUIRE SECURITY OVERRIDES.
        txtfile: close() end                      --EITHER flush() OR close().
    
    txt.os_time     = txt.os_time  or os_time        --INITIALIZE TIME_OF_WRITE=txt.os_time. CHILDREN ALL quit IF txtfile NEVER COMES INTO EXISTENCE.
    time_from_write =     os_time-txt.os_time        --Δos_time  Δ INVALID ON MPV.APP.
    quit            = time_from_write>o.quit_timeout --SOMETIMES txtpath IS INACCESSIBLE, SO AWAIT timeout.  txtfile DOESN'T ORDER A quit BECAUSE A TIMEOUT IS STILL NEEDED ANYWAY, IN CASE SOME OTHER CHILD REMOVES txtfile.
    set_pause       = time_from_write>o.pause_timeout or N~=0 and not txtfile  --EITHER CONTROLLER STOPPED OR FILE INACCESSIBLE.
    command         =                   nil
                      or quit           and  '   quit         '  
                      or set_pause      and  '   set pause yes'
    command         = command           and mp.command(command)
    if N           == 0 or not (txtfile and txt.path) then return end --CHILDREN BELOW.  BUT NOT IF BLANK txtfile (EITHER pause OR NOTHING).   
    target_pos      = txt.time_pos+time_from_write*txt.speed          --Δtime_pos=Δos_time*speed
    time_gained     = p['time-pos']-target_pos  
    accurate_time   = target~=''    or samples_time  --FLAG FOR seek/set_speed.  REQUIRE NEW MPV OR ELSE astats TRIGGER.
    seek            = math.abs(time_gained)>o.seek_limit and accurate_time      
    time_gained     = seek and 0    or time_gained                                        --seek→(time_gained=0)
    speed           =    (set_pause or txt.aid=='no' or txt.path=='') and 0               --0 MEANS pause.  CHILDREN ALWAYS START PAUSED.  BLANK path FOR JPEG. 
                      or clip(txt.speed*(1-time_gained/.5)                                --time_gained→0 OVER NEXT .5 SECONDS (MEASURED IN time-pos, THE astats UPDATE TIME). 
                              *(1+random(-o.max_random_percent,o.max_random_percent)/100) --random BOUNDS [.9,1.1] MAYBE SHOULD BE [.91,1.1]=[1/1.1,1.1].  1% SKEWED TOWARDS SLOWING IT DOWN EXCESSIVELY.
                              ,txt.speed/o.max_speed_ratio,txt.speed*o.max_speed_ratio)   --speed LIMIT RELATIVE TO CONTROLLER.  15% EXTRA WHEN USER UNPAUSES (FOR CHILDREN TO CATCH UP).
    set_volume      = txt.volume~= p.volume..'' 
    set_aid         = txt.aid   ~=(p.aid   or 'no')..''    and txt.aid~='no'  --..'' CONVERTS→string.  txt.aid=auto/no/#.  NEVER set no, OR ELSE YOUTUBE TAKES LONGER TO LOAD (~WRONG).  no FOR JPEG.  
    set_pause       = speed>0   == p.pause and (speed ==0  and 'yes' or 'no') --txt.pause INFERRED.
    set_speed       = speed>0              and accurate_time 
    command         = ''                   
                      ..(set_aid           and ('%s set  aid    %s;'        ):format(command_prefix,txt.aid   ) or '')
                      ..(set_volume        and ('%s set  volume %s;'        ):format(command_prefix,txt.volume) or '')
                      ..(set_pause         and ('   set  pause  %s;'        ):format(               set_pause ) or '')
                      ..(set_speed         and ('%s set  speed  %s;'        ):format(command_prefix,speed     ) or '')
                      ..(seek              and ('   seek %s absolute exact;'):format(               target_pos) or '')  --absolute MORE RELIABLE.  SYNC USING seek INSTEAD OF speed (BETTER TO SKIP THE TRACK THAN ACCELERATE ITS SPEED).
    loadfile        = txt.path~=''         and txt.path~=p.path and mp.commandv('loadfile',txt.path)  --commandv FOR FILENAMES.  FLAGS INCOMPATIBLE WITH MPV-v0.34.  RARELY, YOUTUBE MUST RELOAD.
    command         =  command~=''         and mp.command(command)
end
for property in ('pause seeking mute aid sid speed volume frame-drop-count audio-params/samplerate path af af-metadata/'..label):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS table.  INSTANT write TO txtfile. CASCADE @volume REQUIRES pcall. volume NOT WORKING ON ANDROID.  samplerate MAY DEPEND ON lavfi-complex.  
    do mp.observe_property(property,'native'    ,function(property,val) pcall(property_handler,property,val)  end) end --TRIGGERS INSTANTLY.  astats TRIGGERS EVERY HALF-SECOND, ON playback-restart, frame-drop-count & shutdown.
timers.auto = mp.add_periodic_timer(o.auto_delay,function(            ) pcall(property_handler             )  end)     --IDLER & RESPONSE TIMER. STARTS INSTANTLY TO STOP YOUTUBE TIMING OUT. TRIGGERS EVERY QUARTER/HALF SECOND.  SHOULD ALWAYS BE RUNNING FOR RELIABILITY.

for       property in ('mute aid sid'):gmatch('[^ ]+')  --1SHOT NULL-OP DOUBLE-TAPS.  current-tracks/audio/selected(double_ao_timeout) & current-tracks/sub/selected(double_sub_timeout) ARE STRONGER ALT-CONDITIONS REQUIRING OFF/ON, AS OPPOSED TO ID#.  current-ao ALSO DOES WHAT current-tracks/audio/selected DOES, BUT SAFER @playlist-next.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  
do timers[property]    = mp.add_periodic_timer(o[('double_%s_timeout'):format(property)],function()end) end
for key in ('mute aid sid playback_restarted'):gmatch('[^ ]+')  --1SHOTS
do timers[key].oneshot = 1 
   timers[key]:kill()    end  --FOR OLD MPV. IT CAN'T START timers DISABLED.

function remove_filter() --@cleanup
    for _,af in pairs(p.af) do af_remove = af.label==label and mp.command(('%s af remove @%s'):format(command_prefix,label)) end  --CHECK FIRST.
end

function cleanup()  --@script-message.  ENABLES SCRIPT-RELOAD WITH NEW script-opts.
    os.remove(txtpath)
    remove_filter() 
    set_speed       = p.speed~=1 and mp.command(command_prefix..' set speed 1')  --cleanup_speed=1
    mp.keep_running = false  --false FLAG EXIT: COMBINES overlay-remove, remove_key_binding, unregister_event, unregister_script_message, unobserve_property & timers.*:kill().
end 
for message,fn in pairs({cleanup=cleanup,loadstring=typecast,toggle=on_toggle,resync=os_sync})  --SCRIPT CONTROLS.
do mp.register_script_message(message,fn)  end
reload = gp('time-pos') and file_loaded()  --file-loaded: TRIGGER NOW.

----CONSOLE SCRIPT-COMMANDS & EXAMPLES:
----script-binding           aspeed
----script-message-to aspeed toggle
----script-message-to aspeed cleanup
----script-message-to aspeed loadstring <arg>
----script-message           loadstring "print(m and m.graph or _VERSION)"
----script-message           resync

----APP VERSIONS:
----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED.
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS:  windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  WON'T OPEN JPEG/YOUTUBE ON ANDROID.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.


----~400 LINES & ~7000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END (CONSOLE COMMANDS). ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----FUTURE VERSION SHOULD MOVE o.double_mute_timeout, o.double_aid_timeout, o.double_sid_timeout & o.toggle_command TO main.lua. ALL SCRIPTS SHOULD HAVE THESE, UNLESS main OPERATES ALL DOUBLE-TAPS.
----FUTURE VERSION SHOULD REPLACE (random) WITH $RANDOM/%RANDOM%.
----FUTURE VERSION SHOULD HAVE o.key_bindings_clock (on_toggle_clock), OR SEPARATE clock.lua.  RESYNCING THE EXACT TICK EVERY MINUTE USES 0% CPU.
----FUTURE VERSION SHOULD RESPOND TO CHANGING script-opts; function on_update.
----FUTURE VERSION SHOULD ONLY DECLARE ytdl_hook-* script-opts TO THE CHILDREN.  COULD BE OPTIONAL, LIKE o.suppress_script_opts. IT'S COMPLICATED.
----FUTURE VERSION SHOULD REMOVE astats FOR NEW MPV, SO o.speed IS SET EVERY HALF-SECOND IN REAL-TIME.
----FUTURE VERSION MAY REPLACE astreamselect WITH volume & amix.  astreamselect WAS A BAD DESIGN CHOICE.
----FUTURE VERSION MAY HAVE SMOOTH TOGGLE. txtfile COULD HAVE ANOTHER LINE FOR SMOOTH TOGGLE (SMOOTH-MUTE USING t-DEPENDENT af-command).
----A DIFFERENT VERSION COULD VARY extra_devices_index_list DURING PLAYBACK, WITH A NEW LINE IN txtfile.  A GUI COULD SMOOTHLY ACTIVATE A WHOLE NEW STEREO WITHOUT INTERRUPTING PLAYBACK.
----FOR SURROUND SOUND, THE CONTROLLER COULD INSTA-SWITCH THROUGH ALL DEVICES TO COUNT CHANNELS.  THERE'S A RISK OF RIGHT CHANNEL ON BACK-LEFT, ETC.  CODING FOR A SURROUND SOUND SOURCE SIGNAL IS MORE COMPLICATED. 
----BUG: astreamselect af-command CAUSES A DOUBLE-MUTE COMBO-BUG WHEN COMBINED WITH autocrop.lua+is1frame(albumart).  MPV FAST-FORWARDS A FEW SECONDS (GLITCH).  REPLACING astreamselect COULD FIX IT.

----ANDROID HAS o.clocks, o.speed & o.filterchain, BUT NO CHILD-SPAWN & NO YOUTUBE.  SOMEONE COULD PUBLISH A CLONE: mpv-android2 (is.xyz.mpv2).  ANDROID APPS ARE SINGLETONS.  (LISTENING TO SOME MUSIC ON PHONE IS LIKE MONO.)  A MORE DIFFICULT BUT ELEGANT SOLUTION WOULD BE TO TRANSFORM mpv-android INTO A CONTAINER FOR MULTIPLE AUDIO-ONLY INSTANCES (A NEW spawn COMMAND).
----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----autospeed.lua IS A DIFFERENT SCRIPT INTENDED FOR PERFECTING VIDEO speed, NOT AUDIO.  o.speed CAME LATER ON.
----REPLACING txtfile WITH PIPES IS EASY ON WINDOWS, BUT REQUIRES A DEPENDENCY ON LINUX. socat (sc) & netcat (nc) ARE POPULAR (socat MAY MEAN "SOCKET AT - ..."). input-ipc-server (INTER-PROCESS-COMMUNICATION) IS FOR PIPES. THE DEPENDENCY (REQUIRING sudo) MAY BE LIKE A SECURITY THREAT. A FUTURE MPV (OR LUA) VERSION MAY SUPPORT WRITING TO SOCKET (socat BUILT IN, OR lua-socket). WINDOWS CMD CAN ALREADY ECHO TO ANY SOCKET.  INSTALLING A DEPENDENCY IS LIKE PUTTING NEW WATER PIPES UNDER A HOUSE, FOR A TOY WATER FOUNTAIN.

----ALTERNATIVE FILTERS:
----volume   = volume:...:eval  DEFAULT=1:...:once  POSSIBLE TIMELINE SWITCH FOR CONTROLLER. startt=t@INSERTION.  COULD BE USED FOR SMOOTH TOGGLE.
----loudnorm = I:LRA:TP         DEFAULT=-24:7:-2.  INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS BUFFERED STREAM.
----acompressor       SMPLAYER DEFAULT NORMALIZER.
----firequalizer  OLD SMPLAYER DEFAULT NORMALIZER.

----ALTERNATIVE AbDays.  COLOMBIA MIGHT BE POSSIBLE ({\\fscy200}%I{\\fscy100}).  MISSISSIPPI STATE FLAG IS CHARGED (1 MISSISSIPPI | 2 MISSISSIPPI | 3 MISSISSIPPI).  AN UKRAINIAN/POLISH STYLE MIGHT REQUIRE A CODE WHICH CROPS DIGITS (LIKE \fscy BUT \fcry=FONT-CROP-Y).  CONCEIVABLY ADVERTISEMENTS COULD FIT INSIDE EACH DIGIT OF A CLOCK.
        -- "    IRELAND  ÉIREANN       [ -Su-   -Mo-  -Tu-   -We-  -Th-  -Fr-   -Sa-  ]",  --LENGTH 2 WORKS BETTER ON CALENDAR, BUT NOT CLOCK.
        -- "    IRELAND  ÉIREANN       [  Domh   Luan  Márt   Céad  Déar  Aoin   Sath ]",  --Máirt & Aoine SHOULD BE LENGTH 5.  IRISH IS TOO MUCH.
        -- "    HUNGARY  MAGYARORSZÁG  [--v--  --h-- --k--    sze  -cs- --p--    szo  ]",
        -- " LUXEMBOURG  LËTZEBUERG    [ -So-   -Mé-  -Dë-   -Më-  -Do-  -Fr-   -Sa-  ]",
        -- " LUXEMBOURG  LËTZEBUERG    [ -Son- --Mo--  dëns   Mëtw  Donn -fre- --Sa-- ]",  --Mëtw,Donn CAPITALIZED.
        -- "      Yemen  ‎اليمن‎          ‎ا[‎--ح--‎ ‎ --ن--‎ ‎--ث--‎ ‎--ر--‎ ‎--خ--‎ ‎--ج--‎ ‎ --س--‎ ]",  --LENGTH 1 WORKS ON CALENDAR, BUT NOT CLOCK.
        -- "    ARMENIA  ՀԱՅԱՍՏԱՆ      [  Կրկ    Երկ   Երք    Չրք   Հնգ   Ուր    Շբթ  ]",  --երկշթ,հինգթ=Tue,Thu  (LENGTH 5).
        -- "    ARMENIA  ՀԱՅԱՍՏԱՆ      [  կիրակ  երկշթ երեքթ  չորշթ հինգթ ուրբթ  շաբաթ]",  --5 LETTERS IS LIKE DECIDING BTWN Sunda & Sundy. AS MANY LETTERS AS THERE ARE FINGERS ON SOMEONE'S HAND.
        -- "     RUSSIA  РОССИЯ        [  Вск    Пон   Втр    Сре   Чтв   Пят    Сбт  ]", 
        -- "  LITHUANIA  LIETUVA       [ -Sk-   -Pr-  -An-   -Tr-  -Kt-  -Pn-   -Št-  ]",
        -- "    ESTONIA  EESTI         [--P--  --E-- --T--  --K-- --N-- --R--  --L--  ]",  --P=SUNDAY BUT IT'S ALSO LIKE PM IN LATIN.
        -- "    GERMANY  DEUTSCHLAND   [ -So-   -Mo-  -Di-   -Mi-  -Do-  -Fr-   -Sa-  ]",  
        -- "      CHINA  中国          ‎ا[  周日    周一  周二    周三   周四  周五    周六  ]",  --RED     ◙  RED  ◙   RED  (CHARGED)  1.4B  周=OPTIONAL
        -- "      INDIA  भारत                    ‎[‎    रवि          सोम     मंगल       बुध        गुरु      शुक्र        शनि    ‎ا]",  --SAFFRON ◙ WHITE ◙ GREEN  (CHARGED)  1.4B
        
