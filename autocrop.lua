----NO-WORD-WRAP FOR THIS SCRIPT.  FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO start/end limits.  .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----DOUBLE-mute TOGGLES BOTH crop & PADDING, ON SMARTPHONE TOO. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS.  IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
----THIS VERSION HAS SMOOTH auto_aspect (EXTRA BLACK OR COLORED DYNAMIC BARS), BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask.lua TOO. THAT ALWAYS MAINTAINS PERFECT ASPECT (NO SCALING).

options                 = { 
    auto                = true ,  --ALSO APPLIES TO auto_aspect.  IF REMOVED, A crop OCCURS @on_toggle & @playback-restart (BUT ~@UNPAUSE). 
    auto_delay          = .5   ,  --ORIGINALLY 4 SECONDS.  1s TOO SLOW.
    detect_limit        = '30' ,  --ORIGINALLY "24/255" (cropdetect DEFAULT).  INTEGER FOR bbox (DEFAULT=16).  SET TO 0 FOR NO CROPPING.  24 FAILS FOR "Honest Trailers | ", " | Four Corners" & OTHER YT VIDEOS.
    detect_round        = 1    ,  --ORIGINALLY 2.  DEFAULT=16.
    detect_min_ratio    = .3   ,  --ORIGINALLY 0.5.
    suppress_osd        = true ,  --ORIGINALLY false.
    key_bindings        = 'C     TAB',  --DEFAULT='C'. CASE SENSITIVE. THESE DON'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO limits & meta_osd.  
    key_bindings_aspect = 'Shift+TAB',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout = .5   ,  --SECONDS FOR DOUBLE-MUTE-TOGGLE        (m&m DOUBLE-TAP).  SET TO 0 TO DISABLE.                    IDEAL FOR SMPLAYER.      REQUIRES AUDIO IN SMPLAYER (OR ELSE USE j&j).  VARIOUS SCRIPT/S CAN BE SIMULTANEOUSLY TOGGLED USING THESE 3 MECHANISMS.  TRIPLE-MUTE DOUBLES BACK.  
    double_aid_timeout  = .5   ,  --SECONDS FOR DOUBLE-AUDIO-ID-TOGGLE    (#&# DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  ANDROID MUTES USING aid. REQUIRES AUDIO. 
    double_sid_timeout  = .5   ,  --SECONDS FOR DOUBLE-SUBTITLE-ID-TOGGLE (j&j DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  IDEAL FOR SMARTPHONE.    REQUIRES sid.
    unpause_on_toggle   = .12  ,  --SECONDS TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.      SET TO 0 TO DISABLE.  A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.  is1frame IRRELEVANT.
    toggle_t_delay      = .12  ,  --SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  IT TAKES NEARLY AS LONG AS MESSAGING THE OPPOSITE SIDE OF THE EARTH!  BACKWARDS-seeking ADDS .5s.
    toggle_duration     = .5   ,  --SECONDS TO STRETCH PADDING. SET TO 0 FOR INSTA-TOGGLE.  MEASURED IN time-pos.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  SMPLAYER.APP CAN GIVE MPV ITS OWN WINDOW (window-id=nil).  COULD BE RENAMED vf_command_t_delay.  
    toggle_expr         = 'sin(PI/2*x)^2'           ,  --x=LINEAR-IN-TIME-EXPRESSION  DOMAIN & RANGE BOTH [0,1].  HALF-WAVE=(QUARTER-WAVE)^2  FOR CUSTOMIZED TRANSITION BTWN aspect RATIOS.  TO CHECK ON DESMOS.COM/calculator ENTER sin(π/2*x)^2 WITH x BTWN 0 & 1.  NON-LINEAR SINUSOIDAL TRANSITION (HALF-WAVE) CONJOINS auto_aspect INTO A SERIES OF SINE WAVES.  A SINE WAVE IS 57% FASTER @MAX-SPEED (PI/2=1.57), SO ITS SLOWER: DURATION≥.5.
    toggle_command      = 'show-text ${media-title}',  --EXECUTES on_toggle, UNLESS BLANK.  CAN DISPLAY ${vf} ${lavfi-complex} ${video-out-params}. 'show-text ""' CLEARS THE OSD.  
    auto_delay_aspect   = 1    ,  --REDUCE FOR RANDOM_WALKER.
    gsubs_passes        = 4    ,  --# OF SUCCESSIVE gsubs.  5+ FOR STATISTICS.
    gsubs               = {                           --APPLY TO auto_aspect & script-message ARGUMENTS.  THESE EMULATE IN-SCRIPT ENVIRONMENTAL VARIABLES.
              ['$VIDA'] = '${video-params/aspect}'  , ['$OSDA'] = '${osd-dimensions/aspect}' , ['$A'   ] = 'm.aspect'       , ['$PA'  ] = 'm.prior_aspect' , --$VIDA IS TRUE VIDEO-ASPECT.  $OSDA MEANS FULLSCREEN IF fs.  $PA FOR MOMENTUM CONSERVATION.
              ['$max' ] = '  max($VIDA,$OSDA)'      , ['$min' ] = '  min($VIDA,$OSDA)'       ,  
              ['$MAX' ] = '($max*1.5 )   '          , ['$MIN' ] = '($min/1.5 )   '           , ['$mid' ] = '($max*$min)^.5' , ['$mean'] = '($max+$min)*.5' , --+50% & -33%.  COULD ALSO BE NAMED $EXT & $INF (EXTREMUM & INFIMUM).
              ['$MID' ] = '($MAX*$MIN)^.5'          , ['$MEAN'] = '($MAX+$MIN)*.5'           , 
    },
    
    ----9 EXAMPLES OF auto_aspect CONTROL.  UNCOMMENT A LINE TO ACTIVATE IT.  APPLIES IF DYNAMIC ASPECT-CONTROL IS TOGGLED ON, BUT ONLY IF auto, & NOT is1frame.  EACH EXAMPLE CAN OVERRIDE ALL PRIOR OPTIONS.  A LARGE FLUCTUATION NEEDS LONGER DELAY.  THESE SHOULD BE MOVED TO A NEW SCRIPT.  IT'S MUCH SIMPLER TO RE-COMMAND FFMPEG EVERY SECOND THAN TO GIVE IT 1 OR 2 MASSIVE COMMANDS.
       RANDOM_POWER        ; auto_aspect = '$MIN*($MAX/$MIN)^random()',  --NON-LINEAR DISTRIBUTION (POWER LAW).  NON-LINEAR≈LINEAR. PROOF: ENTER BOTH  1.1*(2.7/1.1)^x  &  1.1+(2.7-1.1)*x  WITH x BTWN 0 & 1, INTO DESMOS.COM/calculator.  AN ULTRA-WIDE WINDOW EXCEEDS $OSDA LESS OFTEN (LIKE TOSSING HEADS 20 TIMES IN A ROW).  
    -- VIDEO_ASPECT        ; auto_aspect = ''                         ,  --TRUE ASPECT.  ''='$VIDA' ARE THE SAME.  '$A' KILLS IT (OFF2 STATE).
    -- RANDOM_WALKER       ; auto_aspect = 'clip($A*($A/$PA)^.5*($MAX/$MIN)^(random()-.5),$MIN,$MAX)  ', auto_delay_aspect = .5, toggle_duration = .3,  --BOUNDED RECURSIVE RANDOM WALKER.  FASTER, MORE VICIOUS & USES MORE CPU.  ($A/$PA)^.5 GIVES IT √MOMENTUM. TOO MUCH MOMENTUM MAKES IT TOO DIFFICULT TO REVERSE DIRECTION.  POSSIBLY THE BEST, BUT ALSO THE MOST DIFFICULT TO CODE WELL: IT DEPENDS ON EXISTING POSITION, MOMENTUM & RANDOM-POWER.
    -- CYCLE_min_max       ; auto_aspect = '$A~=$max  and $max  or $min                               ',  --CYCLES BTWN $min & $max.  AT LEAST ONE OF THESE IS THE TRUE aspect, ASSUMING NO crop.
    -- CYCLE_HDTV_TV       ; auto_aspect = '$A~=16/9  and 16/9  or 4/3                                ',  --CYCLES BTWN HD & IPAD.  EXAMPLES HELP VERIFY SCRIPT IS VALID.
    -- RANDOM_N_FULLSCREEN ; auto_aspect = '$A~=$OSDA and $OSDA or $MIN*($MAX/$MIN)^random()          ',  --CYCLES BTWN FULLSCREEN & RANDOM-POWER.  THIS ONE GIVES FULLSCREEN 25% OF THE TIME, BUT I PREFER CUT DIAGONALS!
    -- UP_AND_ACROSS       ; auto_aspect = '$A==$MAX  and $OSDA or $A  ==$MIN and $MAX  or $MIN       ',  --ANTI-CLOCKWISE ON TOP-RIGHT.  RIGHT-HANDERS MIGHT ANCHOR THEIR VISION FROM TOP-RIGHT (LIKE ARABIC). BUT LIKE ENGLISH, COMPUTERS READ FROM TOP-LEFT.
    -- ACROSS_AND_DOWN     ; auto_aspect = '$A==$MAX  and $MIN  or $A  ==$MIN and $OSDA or $MAX       ',  --     CLOCKWISE ON TOP-LEFT.
    -- LEFT_RIGHT_DOWN_UP  ; auto_aspect = '$A~=$OSDA and $OSDA or $PA ==$MIN and $MAX  or $MIN       ',  --INTERMEDIATE CYCLE. CYCLES BTWN $MIN & $MAX PASSING THROUGH WINDOW-SIZE $OSDA.  
    -- LINEAR_DISTRIBUTION ; auto_aspect = '$MID+random()*((random(0,1)==0    and $MAX  or $MIN)-$MID)',  --$MID & 2 random NUMBERS ARE USED, SO $MEAN=$MID IN THIS CASE. (0,1) DETERMINES WHETHER TO ADD OR SUBTRACT (DIFFERENT GRADIENTS).  $MIN+($MAX-$MIN)*random() IS SKEWED WIDE-SCREEN BECAUSE $MEAN>$MID.
    
    start_aspect_off       =  false       ,  --APPLIES @apply_pad.  EXCEPT is1frame ALWAYS STARTS OFF2.  DETERMINES TOGGLE LOGIC-STATE OF auto_aspect CONTROL.
    apply_inner_rectangle  =  false       ,  --AGGRESSIVE CROPPING FLAG.  BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE COMPUTATION.  COMPUTES x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    meta_osd               =  false       ,  --SET TO true TO INSPECT VERSIONS, DETECTOR METADATA, ETC.  TOGGLES IRRELEVANT.  DISPLAYS  media-title _VERSION mpv-version ffmpeg-version libass-version platform current-ao,current-vo video-params/alpha osd-width,osd-height pad_iw,pad_ih pad_ow,pad_oh max_w,max_h min_w,min_h w:h:x:y vf-metadata/autocrop.
    detector               = 'cropdetect=limit=%s:round=%s:reset=1',  --%s:%s=detect_limit:detect_round.  reset>0.  OVERRIDES TO 'bbox=%s' FOR JPEG & alpha.
    detect_min_ratio_image = .1           ,  --OVERRIDE FOR JPEG.
    keep_center            = {0,0}        ,  --{TOLERANCE_X,TOLERANCE_Y}.  SET TO {}  TO MOVE FREELY.  {0,0} MEANS NEVER MOVE (LIKE CROSSHAIRS).  DOESN'T APPLY TO JPEG.  A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    TOLERANCE              = {.05,time=10},  --INSTANTANEOUS TOLERANCE.    SET TO {0} TO DEACTIVATE THIS.  5% BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS. A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    msg_level              = 'fatal'      ,  --{no,fatal,error,warn,info}.  TYPOS ARE OFTEN fatal.
    pad_scale_flags        = 'bilinear'   ,  --DEFAULT bicubic ('').  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  bilinear MAY ENABLE MORE FPS.
    pad_options            = 'x=(ow-iw)/2:y=(oh-ih)/2:color=BLACK@1',  --CAN SET color=WHITE FOR WHITE SMARTPHONE.  y=0 PADS ONLY THE BOTTOM.  @0 (+yuva420p) FOR TRANSPARENCY.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY & PINK ARE ALSO NICE. 
    framerate              = ''           ,  --DEFAULT=''=50 FPS.  REMOVE THIS TO REMOVE INTERPOLATION (SET TO nil).  INCOMPATIBLE WITH TRANSPARENCY (BUGFIX REMOVES IT).
    osd_par_multiplier     =       1      ,  --NEEDED FOR NON-NATIVE SCREEN-RESOLUTIONS.  DISPLAY-PAR=osd-par*osd_par_multiplier.  osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO.  CAN MEASURE display TO DETERMINE ITS TRUE par.  video-out-params/par ACTUALLY MEANS VIDEO-IN-2DISPLAY (par OF ORIGINAL FILM)!
    video_out_params       =  {par=1,w,h,pixelformat},  --OVERRIDES {number/string}.  DEFAULT par=1.  SET {par=1,pixelformat='yuva420p'} FOR TRANSPARENT PADDING.  THIS SCRIPT OVERRIDES FILM par USING ITS OWN MATH.  DEFAULT w=display-width.  BUT THAT'S nil FOR LINUX/MACOS SMPLAYER (CAN SET {par=1,w=1680,h=1050}).  OVERRIDING par USES MORE CPU BY COMPUTING PAD MEGAPIXEL/S.  THE SOURCE STREAM par/sar COULD ALSO BE VARIABLE!  par=2 MAKES NO DIFFERENCE.  MACOS SMPLAYER REQUIRES w,h (OR ELSE $osda=$vida).
    options                =  {
         'keepaspect    no','keepaspect-window   no ','geometry 50%          ',  --keepaspect=no FOR ANDROID. keepaspect-window=no FOR MPV.APP.  FREE-SIZE IF MPV HAS ITS OWN WINDOW.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
         'osd-font-size 16','osd-bold            yes','osd-font "COURIER NEW"',  --DEFAULTS=55,no,sans-serif  55p MAY NOT FIT osd.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS PROPRIETARY & INVALID ON MACOS.  
         'sub           no','sub-create-cc-track yes',  --DEFAULTS=auto,no.  SUBTITLE CLOSED-CAPTIONS CREATE BLANK TRACK FOR double_sid_timeout (BEST TOGGLE).  JPEG VALID.  UNFORTUNATELY YOUTUBE USUALLY BUGS OUT UNLESS sub=no.  sid=1 LATER @playback-restart.  YOUTUBE cc TAKE TIME TO SHUFFLE.
         'hwdec         no',  --DEFAULT=no.  HARDWARE-DECODER MAY PERFORM BADLY, & BUGS OUT ON ANDROID.
    },
    windows = {}, linux = {}, darwin = {},  --OPTIONAL platform OVERRIDES.
    android = {  
        start_aspect_off = true, auto_aspect = '',  --SMARTPHONE STARTS OFF2.  auto_aspect IS TOO MUCH CPU USAGE.
        options = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',}, --options APPEND, NOT REPLACE.  meta_osd PREFERS MONOSPACE FONT.
    },
    limits_gsub = {'[ ＂" ⧸/ ：: ⧹\\ ｜| ]+',' '},  --{pattern,repl} REPLACEMENTS APPLY TO SUBSTRING SEARCHES.  '  '=' ' LIKE MARKDOWN.  USING ONLY A SINGLE gsub IS MORE EFFICIENT THAN DOUBLE-LOOPING ＂→", ETC.
    limits      = {
    ----["path \n media-title SUBSTRING"]={start,end,detect_limit},  --{SECONDS,-SECONDS,string/number}, OR nil.  NOT CASE SENSITIVE.  start & end MAY BOTH BE NEGATIVE &/OR PERCENTAGES.  detect_limit IS FINAL OVERRIDE.  MATCHES ON FIRST find.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS.  THESE SHOULD BE MOVED TO A NEW SCRIPT.

        ["Alanis Morissette Ironic Official "]={4,-23},
        ["Aqua Barbie Girl Official Music Video"]={7,-11}, --AQUASCOPE.
        ["blink182 Feeling This Official Video"]={10,-5},  --HAIRCUT.
        ["Bryan Adams Summer Of 69 Official Music Video"]={0,-9}, 
        ["Evanescence Everybodys Fool Official HD Music Video"]={18}, --AD.
        [" Greentext Stories Thread"]={20},                           --GREETINGS AND BIENVENUE.
        ["Guns N Roses Sweet Child O Mine Official Music Video"]={0,-11},
        ["Iggy Azalea Fancy ft Charli XCX"]={0,-6},
        ["Iron Maiden The Trooper Official Video"]={0,-13},  --IN HONOR OF THE LIGHT BRIGADE (CRIMEAN WAR).
        ["Katy Perry This Is How We Do Official"]={0,-7},
        ["Linkin Park Dont Stay"]={detect_limit=40}, 
        ["Madonna Like A Prayer Official Video"]={12},
        ["Megadeth Sweating Bullets Official Music Video"]={0,-5},
        ["Midnight Oil Dreamworld"]={27},
        ["Neil Young Heart of Gold Live Harvest 50th Anniversary Edition Official Music Video"]={19,-15},
        ["ORPHANED LAND All Is One OFFICIAL VIDEO"]={0,-30},
        ["Rage Against The Machine Testify Official HD Video"]={0,-12},
        ["Red Hot Chili Peppers Cant Stop Official Music Video"]={0,-9},
        ["Santana Smooth Stereo ft Rob Thomas"]={15},
        ["Soft Cell Tainted Love Official Music Video"]={0,-5},
        ["Sum 41 Fatlip Official Music Video"]={19},
        ["Sum 41 Still Waiting Official Music Video"]={62,-4},    --THE SUMS.
        ["Sum 41 Walking Disaster Official Music Video"]={0,-10}, --ROBOT SALE.
        ["Taylor Swift Look What You Made Me Do"]={5,-39},        --14 SWIFTS.
        ["Weird Al Yankovic Amish Paradise Parody of Gangstas Paradise Official HD Video"]={0,-7,detect_limit=20},
        ["Weird Al Yankovic Fat Official HD Video"]={60+18},
        ["Weird Al Yankovic Like A Surgeon Official HD Video"]={41},
        
        [ "День Победы."]={4,-13},  --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ         
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7},
        ["Экипаж  Одна семья"]={0,-7},
        ["И вновь продолжается бой.Legendary Soviet Song."]={0,-6},
        ["Конармейская Rote Reiterarmee"]={detect_limit=40},
        ["Москва Майская."]={27,-14},
        ["＂My Armiya Naroda, Sluzhit' Rossii＂ - Ensemble of the Russian West Military District"]={5,-14},
        ["Мы - армия народа ⧸ We are the army of the people (23 февраля 1919 - 2019)"]={13},
        ["опурри на темы армейских песен Soviet Armed Forces Medley"]={17},
        ["Песня Будённовской конной кавалерии РККА"]={11},
        ["＂Polyushko Polye＂ - Soviet Patriotic Song"]={8,-12},
        ["Red army choir - Echelon's song (Song for Voroshilov)"]={7,-3},
        ["Red Army Choir - The March of the Defenders of Moscow (Марш защитников Москвы)"]={detect_limit=40},
        ["Russian Patriotic Song： Farewell of Slavianka"]={12},
        ["Sacred War ⧸⧸ Священная Война [Vinyl]"]={10,-6},
        ["＂Soldiers walked＂ - The Alexandrov Red Army Choir (1975)"]={0,-27},
        ["＂Song of the Volga Boatmen＂ HQ - Leonid Kharitonov & The Red Army Choir (1965)"]={13},
        ["Tri Tankista - Three Tank Crews - With Lyrics"]={10},
        ["Три Танкиста ｜ Tri Tankista (The Three Tankists)"]={0,-17},
        ["Три танкиста."]={0,-15},
        ["Варшавянка ⧸ Warszawianka ⧸ Varshavianka (1905 - 1917)"]={0,-6},
        ["Военные парады 1938 - 1940г. Москва. Красная площадь."]={6,-5},
        
        ["Michael Jackson Smooth Criminal Official Video"]={66.6},  --INTERMISSION AUTO-seek MISSING.
    },
}

o,p,m,timers                    = {},{},{},{} --o,p,m=options,PROPERTIES,MEMORY  timers ={mute,aid,sid,playback_restarted,re_pause,apply_pad,apply_framerate,auto_aspect,auto_delay}  playback_restarted BLOCKS THE PRIOR 3. 
android_surface_size,gsubs,meta = {},{},{}    --android_surface_size={w,h}.  gsubs REDUCES ALL gsubs_passes INTO JUST 1!  meta=METADATA FOR detect_crop.
abs,max,min,random              = math.abs,math.max,math.min,math.random  --@clip, @pexpand & @detect_crop.  m MEANS MEMORY NOT math.
math.randomseed(os.time()+mp.get_time())  --os,mp=OPERATING-SYSTEM,MEDIA-PLAYER.  os.time()=INTEGER SECONDS FROM 1970.  mp.get_time()=μs IS MORE RANDOM THAN os.clock()=ms.  os.getenv('RANDOM')=nil

function clip(N,MIN,MAX) return N and MIN and MAX and min(max(N,MIN),MAX) end  --@apply_scale.  NUMBERS/nil.  FFMPEG SUPPORTS clip, BUT NOT LUA.  min max MIN MAX.
function round(N,D)  --@file_loaded, @seek, @apply_pad & @apply_scale.  NUMBERS/STRINGS/nil.  FFMPEG SUPPORTS round, BUT NOT LUA.  ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1).
    D = D or 1
    return N and math.floor(.5+N/D)*D  --round(N)=math.floor(.5+N)
end

function  gp(property)  --ALSO @file_loaded, @seek, @apply_pad, @apply_scale, @apply_crop & @detect_crop.  GET-PROPERTY.
    p       [property]=mp.get_property_native(property)  
    return p[property]
end

function pexpand(arg)  --ALSO @pexpand_to_string, @show, @apply_pad, @apply_scale, @apply_crop & @detect_crop.  PROTECTED PROPERTY EXPANSION.  '${speed}+2'=3.  COULD BE RENAMED ppexpand.
    if type(arg)~='string' then return arg end
    for pattern,repl in pairs(gsubs) 
    do      arg  = arg: gsub(pattern,repl) end                                          --FULL EXPANSION REQUIRES $MIN, ETC.
    pcode, pval  = pcall(loadstring('return '..mp.command_native({'expand-text',arg}))) --''→nil.  load INVALID ON MPV.APP.  PROTECTED-CALL.
    if pcode then return pval end                                                        --OTHERWISE pcode,pval=false,string.
end

p  .platform  = gp('platform') or os.getenv('OS') and 'windows' or 'linux' --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = {}  --DEFAULT={}
for  opt,val in pairs(options) 
do o[opt]     = val end              --CLONE.  options PRESERVES TYPES.
require 'mp.options'.read_options(o) --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.
for    opt,val in pairs(o) do if type(options[opt])~='string' then o[opt] = pexpand(val)   end end  --NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  

for _,opt in pairs(o[p.platform].options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(o.options)                                                                   
do  command            = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command                = command and mp.command(command) 
for  opt,val in pairs(o[p.platform])
do o[opt]              = val end              --platform OVERRIDE.
utils                  = require 'mp.utils'   --@pexpand_to_string
label                  = mp.get_script_name() --autocrop
for pattern,repl in pairs(o.gsubs)            --o.gsubs MAY DEPEND EACH-OTHER. 
do  for N              = 1,o.gsubs_passes do for pattern2,repl2 in pairs(o.gsubs)      --gsubs={} IF gsubs_passes<1.  NO DAIZY-CHAIN IF gsubs_passes=1.
    do  gsubs[pattern] = (gsubs[pattern]  or pattern):gsub(pattern2,repl2) end end end --INITIALIZES N=1 TOO.
o.limits_gsub[1]       = o.limits_gsub[1] or o.limits_gsub.pattern or '' --DEFAULT=''
o.limits_gsub[2]       = o.limits_gsub[2] or o.limits_gsub.repl    or '' --DEFAULT REPLACEMENT=''
o.video_out_params.par = o.video_out_params.par or 1                     --DEFAULT=1  
command_prefix         = o.suppress_osd and 'no-osd' or ''
gp('msg-level')[label] = o.msg_level --SILENCES mp.msg.  msg-level=table.
mp.set_property_native('msg-level',p['msg-level']) 

function file_loaded()     --ALSO @event_handler & @property_handler.  
    start_time     = round(gp('time-pos'),.001) --NEAREST MILLISECOND FOR JPEG start_time. 
    if not v                                    --ONCE ONLY PER FILE (ON_EVENT).  RAW AUDIO TOO!
    then limits    = nil
        title      = (gp('path')..'\n'..gp('media-title'))         : gsub(o.limits_gsub[1],o.limits_gsub[2]):lower()  --NOT CASE SENSITIVE.  OFTEN media-title=path
        for key,o_limits in pairs(o.limits)
        do  limits = limits                     or  title: find(key: gsub(o.limits_gsub[1],o.limits_gsub[2]):lower(),1,1) and o_limits end  --1,1=init,plain  BREAKS ON FIRST find.  ESTABLISH limits.
        limits     = limits                     or  {}
        limit      = limits.detect_limit        or  o.detect_limit
        limits[1]  = limits[1]                  or  limits.start
        set_end    = limits[2]                  or  limits['end']  or set_end    and gp('end')~='none' and 'none' --none @playlist-next IF NEEDED.  TRACK-2 SHOULDN'T INHERIT end DUE TO PRIOR set_end.  set_end SIMPLER THAN TRIMMING TIMESTAMPS.  
        seek       = limits[1]                  and start_time<limits[1] and limits[1]  --SIMPLER THAN set start BECAUSE media-title UNKNOWN BEFORE file-loaded!
        command    = ''                         
                     ..(seek                    and '   seek    %s absolute exact;' or ''):format(seek)  --ALSO FOR JPEG.
                     ..(set_end                 and '%s set end %s;'                or ''):format(command_prefix,set_end) 
        command    = command~=''                and mp.command(command) end
    v              = gp('current-tracks/video') or  {}  --{} FOR AUDIO.
    ow             = o.video_out_params.w       or  gp('display-width' ) or android_surface_size.w or gp('width' ) or v['demux-w']  --number/string.  OVERRIDE  OR  display  OR  android  OR  PARAMETERS  OR  TRACK.  THE CROPPING SCALER WORKS BEST IF IT SCALES TO AN ABSOLUTE CANVAS, PERMANENTLY. REPLACING IT CAUSES GLITCHES, WITH PNG/JPEG, BUT NECESSARY FOR SMARTPHONE.  width=nil SOMETIMES @file-loaded, & MAY CONTINUOUSLY VARY DUE TO lavfi-complex, & MAY BE MUCH LARGER THAN display SINCE MEMORY IS CHEAP.
    oh             = o.video_out_params.h       or  gp('display-height') or android_surface_size.h or gp('height') or v['demux-h']
    if not (ow and oh and gp('current-vo')) then mp.msg.warn("crop only works for videos.")  --return CONDITIONS REQUIRE DIMENSIONS & vo.  PARAMATERS OFTEN UNAVAILABLE, BUT SHOULD PROCEED WITHOUT STUTTER. 
        return end
    
    W,H = ow,oh --W ACTS AS LOADED SWITCH.
    mp.command((''
                ..(not p.pause and 'set pause yes;' or '')               --INSTA-pause FIRST TO PREVENT EMBEDDED MPV FROM SNAPPING.  ALSO IMPROVES JPEG RELIABILITY.  BUT STILL SNAPS SOMETIMES FOR 5s MP4.
                .."%s vf pre @%s-scale:lavfi=[scale=%d:%d,setsar='%s'];" --setsar REQUIRED FOR SHARED-MEMORY PADDING.  ANTI-SNAP GRAPH IS SEPARATE BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER. IN/OUT MUST BE "SET IN STONE", OR ELSE.
    ):format(command_prefix,label,W,H,o.video_out_params.par))
    
    loop              = v.image      and gp('lavfi-complex')=='' --ALSO FOR is1frame, FOR SIMPLICITY. 
    is1frame          = v.albumart   and  p['lavfi-complex']=='' --CHANGES @vid.  MP4TAG IS CONSIDERED albumart.  REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. 
    auto              = not is1frame and o.auto                  --~auto FOR is1frame, OR AUDIO GLITCHES.
    detect_min_ratio  = v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    alpha             = gp('video-params/alpha') 
    detector          = ((alpha or v.image) and 'bbox=%s'            or o.detector):format(limit,o.detect_round)  --bbox FOR alpha & JPEG.
    is1frame_replaced = nil
    
    if not detect_format then gp('msg-level')  --detect_format=nil MEANS ONCE ONLY, EVER.  @file-loaded BECAUSE OLD FFMPEG BUGS OUT SOONER.
        mp.set_property         ('msg-level','all=no')  
        error_format = not mp.command(('%s vf pre @%s-crop:lavfi-format    '):format(command_prefix,label))  --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  MPV OFTEN BUILT WITH v4.2→v6.1.  v4 REQUIRES SPECIFYING format.  command RETURNS true IF SUCCESSFUL.  MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  @%s-crop FOR SIMPLICITY.
        error_scale  = not mp.command(('%s vf pre @%s-crop:lavfi-scale=h=oh'):format(command_prefix,label))  --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2, BUT MPV-v0.34 IS SMOOTH! 
        mp.set_property_native  ('msg-level',p['msg-level'])         --h=oh MEANS NO STRETCHING (STUPID SCALER).  THIS ERROR MEANS GOOD (NEW MPV)!  OLD FFMPEG FAILS TO REPORT SELF-REFERENTIALITY (FALSE NEGATIVE). 
        if not error_scale then o.start_aspect_off,o.auto_aspect = true,'' end end  --OLD FFMPEG LIKE SMARTPHONE (NO RANDOMIZATION).
    detect_format = p['current-vo']=='shm' and 'yuv420p' or error_format and (alpha and 'yuva420p' or 'yuv420p') or ''  --SHARED-MEMORY  OR  OLD-FFMPEG(alpha OR ~alpha)  OR  NULL-OP.  FORCING yuv420p OR yuva420p IS MORE RELIABLE. MPV.APP COMPATIBLE WITH TRANSPARENCY, BUT NOT SMPLAYER.APP.  alpha BAD FOR FILM.  .APPIMAGE FAILS @TRANSPARENCY.
    remove_loop   = is_filter_present('loop')  --@loop MAY BE THERE DUE TO OTHER vid OR SCRIPT.
    
    
    mp.command((''
                ..(remove_loop and '%s vf  remove @loop;' or ''):format(command_prefix)
                ..                 '%s vf  pre    @%s-crop:crop=keep_aspect=1:exact=1;' --SEPARATE FOR RELIABILITY WITH alpha & OLD FFMPEG.  
                ..                 '%s vf  pre    @%s:lavfi=[format=%s,%s];'            --cropdetect OR bbox  CAN BE BEFORE/AFTER @loop.
                ..(       loop and '%s vf  pre    @loop:lavfi=[loop=-1:1,fps=start_time=%s];' or '')  
                ..(not p.pause and '   set pause  no ;'   or '')
    ):format(command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,start_time))
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d=DECIMAL-INTEGER.  '%s' BLOCKS STRINGS FROM SPLITTING.  3 (OR 4) CHAINS + 3 FILTERS.
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                  IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = ...:start_time (SECONDS)  SETS STARTPTS FOR JPEG (--start).  JPEG SMOOTH PADDING.  USES CPU UNTIL USER PAUSES. 
    ----cropdetect = limit:round:reset         DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES.  reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip (DEFAULT=2) INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP.  alpha TRIGGERS BAD PERFORMANCE BUG.  image DODGY.
    ----bbox       = min_val                   DEFAULT=16  [0,255]  BOUNDING BOX USED FOR alpha & image.  CAN COMBINE MULTIPLE DETECTORS IN 1 GRAPH.
    ----crop       = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval        DEFAULT=iw:ih:bicubic:...:init  NULL-OP USES NO CPU.
    ----pad        = w:h:x:y:color             DEFAULT=0:0:0:0:BLACK  @apply_pad (BELOW)  0 MAY MEAN iw OR ih.  FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW TO COLOR IN.
    ----setsar     = sar                       DEFAULT=0              SAMPLE-ASPECT-RATIO=par  THIS ISN'T WHAT MPV CALLS sar! IT MAY BE RELATIVE (OR A MISNOMER).  FINALIZES OUTPUT DSIZE, OTHERWISE THE PIXELS CAN HAVE ANY SHAPE.  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS LIKE GRAPH-ARMOR).  THIS IS LIKE 2 SCRIPTS COMBINED, & setsar=1 IS REPEATED THE SAME WAY, FOR RELIABILITY. OTHER SCRIPTS WORK FINE WITHOUT THIS.
    ----framerate  = fps                       DEFAULT=50             IS THE FINISH.  FORCES alpha REMOVAL.  NEGATIVE TIME CAUSES BUG.  IT *CAN* OUTPUT VARIABLE fps BY COMBINING IT INSIDE A SPECIAL GRAPH.

    
    timers.apply_pad:resume()  --PADDING LAST. 
end

function apply_pad(pad_options,pixelformat,pad_scale_flags,par)  --@script-message & @file_loaded.  PADDING APPENDS AFTER OTHER SCRIPT/S.
    if not W then return end                           --W=nil DURING INSTA-stop FOR COMPLEX TRACK-CHANGE.
    pad_options       = pad_options     or o.pad_options
    m.pixelformat     = pixelformat     or o.video_out_params.pixelformat or detect_format  --OVERRIDE  OR  DETECTOR.
    pad_scale_flags   = pad_scale_flags or o.pad_scale_flags
    par               = par             or o.video_out_params.par
    OFF2              = is1frame        or o.start_aspect_off  --LOGIC STATE NEVER PRESERVED BTWN RELOADS.  MP4TAG OFF2 BUT NOT MP4!  COULD CHANGE IN FUTURE.
    W2,H2             = round(W,2),round(H,2)                  --W2 ACTS AS pad LOADED SWITCH.  EVENS ONLY FOR CENTERED PADDING! 
    m.pad_iw,m.pad_ih = W2,H2                                  --INITIALIZE FOR meta_osd.
    aspectOFF         = W2/H2                                  --THIS ISN'T ACTUALLY THE TRUE ASPECT RATIO, IT'S JUST A RELATIVE VALUE.  A TRUE aspect MUST INCORPORATE par.
    pad_time          = gp('time-pos')                         --BLOCKS RE-PADDING TOO QUICKLY.  
    remove_framerate  = is_filter_present(label..'-framerate') --COMMAND SWITCH.
    insta_pause       = not p.pause and loop                   --FOR PNG RELIABILITY.  CAUSES STUTTER ON FILM.
    
    mp.command((''
                ..(insta_pause      and '   set pause yes;'            or '')                                       
                ..(remove_framerate and '%s vf  remove @%s-framerate;' or ''):format(command_prefix,label)  --HAS A BUG WHICH REMOVES alpha.
                ..                      '%s vf  append @%s-pad-scale:scale=flags=%s:eval=frame;' 
                ..                      "%s vf  append @%s-pad:lavfi=[format=%s,pad='%d:%d:%s',scale=%d:%d,setsar='%s'];"  --FINAL scale IS NULL-OP, UNLESS W OR H ODD.  FOR VARIABLE fps PLACE framerate WITHIN THIS GRAPH. THIS CHANGES HOW IT DETECTS SCENE CHANGES. 
                ..(insta_pause      and '   set pause no ;'            or '')
        ):format(command_prefix,label,pad_scale_flags,command_prefix,label,m.pixelformat,W2,H2,pad_options,W,H,par))
    
    timers.apply_framerate:resume()
end 
timers.apply_pad = mp.add_periodic_timer(.01,apply_pad)  --WITHOUT A TIMEOUT THERE'S SOME CHANCE SOME OTHER FILTER FILTERS THE PADDING. 

function apply_framerate(framerate)  --@script-message & @apply_pad.  INTERPOLATES IF THERE'S NO TRANSPARENCY, OR @MESSAGE.  INTERPOLATION FILTERS THE PADDING.
    framerate = framerate or v.id and not (is1frame or gp('video-out-params/alpha') or gp('video-params/alpha') or gp('video-dec-params/alpha') or m.pixelformat: find('a')) and o.framerate
    return framerate and mp.command(('%s vf append @%s-framerate:framerate=%s'):format(command_prefix,label,framerate))
end
timers.apply_framerate = mp.add_periodic_timer(.01,apply_framerate)  --0-10ms NEEDED TO DETECT alpha.

function re_pause()  --@on_toggle_aspect & @cleanup.  
    if not insta_unpause then return end                                                           --insta_unpause ONLY.
    mp.command('set pause yes;'..(return_terminal and command_prefix..' set terminal yes;' or '')) --ALSO return_terminal.
    insta_unpause,return_terminal = nil
end
timers.re_pause = mp.add_periodic_timer(o.unpause_on_toggle,re_pause)  

function on_toggle()  --@script-message, @script-binding, & @property_handler.  
    OFF        = not OFF --OFF SWITCH (FOR CROPS ONLY).
    m.time_pos = nil     --OVERRIDES TOLERANCE.
    crop       = OFF                  and apply_crop({w=p.width,h=p.height,x=0,y=0}) or detect_crop()  --NULL CROP &/OR DETECTION RETURNS IF OFF.
    command    = o.toggle_command~='' and mp.command(command_prefix..' '..o.toggle_command)
end

function on_toggle_aspect() --@script-message, @script-binding & @property_handler.
    timers.re_pause:kill()  --THESE 5 LINES FOR RAPID-TOGGLING WHEN PAUSED.  RESET TIMER FOR NEW PAUSED TOGGLE.
    timers.re_pause:resume()
    insta_unpause   = (insta_unpause or p.pause and o.unpause_on_toggle>0 and not is1frame) --ALREADY insta_unpause OR IF PAUSED, UNLESS is1frame.  COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
                      and mp.command(command_prefix..' set terminal no;set pause no')
    return_terminal = return_terminal or p.terminal and insta_unpause  --terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING TABS AS QUICK AS TOUCH-TYPING. EXAMPLE: KEEP TAPPING M IN SMPLAYER, AS FAST AS POSSIBLE.
    OFF2            = not OFF2                --OFF2=LOGIC STATE OF PADDING.  FULL-SCREEN IS OFF2. 
    auto            = not is1frame and o.auto --RESET AFTER script-message.
    apply_scale()
end

for key in o.key_bindings       : gmatch('[^ ]+')  --'[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
do mp.add_key_binding(key,'toggle_crop_'  ..key,on_toggle       ) end  
mp   .add_key_binding(nil,'toggle_crop'        ,on_toggle       )  --UNMAPPED binding.
for key in o.key_bindings_aspect: gmatch('[^ ]+') 
do mp.add_key_binding(key,'toggle_aspect_'..key,on_toggle_aspect) end  
mp   .add_key_binding(nil,'toggle_aspect'      ,on_toggle_aspect)

function apply_scale(aspect,toggle_duration,toggle_t_delay,toggle_expr)  --@script-message, @playback-restart, @property_handler, & @on_toggle_aspect.  SIMPLER TO SEPARATE UTILITY FROM ITS TOGGLE.  COULD BE RENAMED apply_aspect.  STRETCHES BLACK BARS WITHOUT CHANGING vo DSIZE (DISPLAY SIZE). 
    if not (W2 and p['video-params/aspect'] and gp('time-pos')) or p.seeking then return  --W2=nil DURING TIMEOUT DEPENDING ON BUILD.  video-params/aspect=nil DURING complex TRACK-CHANGES.  time-pos=nil @playback-restart PASSED end-file.
    elseif auto then timers.auto_aspect:kill  ()  --RESET FOR WHEN WINDOW RESIZES.
                     timers.auto_aspect:resume() end 
    
    OFF2            = OFF2 and not aspect  --TURN ON2 @script-message.  auto OVERRIDES THIS. IN THAT CASE script-message set auto_aspect (FUTURE VERSION).
    aspect          = pexpand(aspect)  or p['video-params/aspect']
    toggle_duration = (not error_scale or insta_unpause) and 0 or pexpand(toggle_duration) or o.toggle_duration  --insta_unpause RESETS ITSELF TO nil.
    scale_time      = p['time-pos']+(pexpand(toggle_t_delay)   or backward_seek and .5     or o.toggle_t_delay)  --backward_seek REQUIRES t+.5s BY TRIAL & ERROR. COULD BE MADE ANOTHER OPTION.
    scale_time      = scale_time-(m.scale_time and clip(m.toggle_duration-(scale_time-m.scale_time),0,toggle_duration) or 0)  --RAPID TOGGLING CORRECTION. PERFECT CORRECTION ASSUMES LINEARITY.  REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & CURRENT-DURATION.  RAPID TOGGLING USES PRIOR DURATION.
    aspectR         = aspectOFF * (OFF2  and 1 or aspect / (p['osd-dimensions/aspect'] * o.osd_par_multiplier)) --RELATIVE ASPECT IS JUST A W/H MULTIPLIER & DOESN'T CORRESPOND TO TRUE par.  IT'S EITHER THE OFF VALUE, OR ELSE TRUE ASPECT FORMULA.  W/H*RATIO OF VIDEO:OSD  (RELATIVE TO W/H).  REAL ASPECT OF EACH PIXEL (osd-par) IS ASSUMED TO BE ACCOUNTED FOR IN osd-dimensions/aspect.  video-params/aspect ACCOUNTS FOR video-params/par (demux-par).  SHARED-MEMORY HAS THE PROBLEM video-params/aspect=osd-dimensions/aspect.  
    x               = toggle_duration==0 and 1 or ('clip((t-%s)/(%s),0,1)'):format(scale_time,toggle_duration)  --[0,1] DOMAIN & RANGE.  0,1=INITIAL,FINAL  TIME EXPRESSION FOR SMOOTH-PADDING.  x IS WHATEVER GOES INTO A GRAPHICS CALCULATOR.
    toggle_expr     = (toggle_expr             or o.toggle_expr):gsub('x',x)                                    --NON-LINEAR clip. 
    pad_iw , pad_ih = round(min(W2,H2*aspectR),2),round(min(W2/aspectR,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.
    Dpad_iw,Dpad_ih = pad_iw-m.pad_iw,pad_ih-m.pad_ih  --DIFFERENCE VALUES.  Δ INVALID ON MPV.APP (NO-GREEK).  WHEN BOTH VALUES ARE NON-0 THE FILM CUTS DIAGONAL.
    
    scale_w = vf_observed or Dpad_iw~=0  --vf CAN RESET GRAPH STATES, BUT WITHOUT TRIGGERING playback-restart!
    scale_h = vf_observed or Dpad_ih~=0
    command = nil            
              or    is1frame and ('%s vf append @%s-pad-scale:scale=w=%d:h=%d'):format(command_prefix,label,pad_iw,pad_ih)  --is1frame GLITCHES @WINDOW-RESIZE.
              or ''          
                 ..(scale_w  and     'vf-command %s-pad-scale w round((%d+%d*(%s))/2)*2;' or ''):format(label,m.pad_iw,Dpad_iw,toggle_expr)  --CHECK COMMAND NEEDED, FIRST.  EVENS ONLY. 
                 ..(scale_h  and     'vf-command %s-pad-scale h round((%d+%d*(%s))/2)*2;' or ''):format(label,m.pad_ih,Dpad_ih,toggle_expr)
    command = command~=''    and mp.command(command) 
    
    m.prior_aspect,m.aspect,m.pad_iw,m.pad_ih,m.scale_time,m.toggle_duration = m.aspect,aspect,pad_iw,pad_ih,scale_time,toggle_duration  --MEMORY TRANSFER.
    vf_observed,backward_seek = nil  --CLEAR SWITCHES FOR NEXT TIME.
end 

function auto_aspect()  --@apply_scale.
    return (not p.pause  or  abs(p['time-pos']-scale_time)>=o.auto_delay+o.toggle_t_delay) --2 RESCALE POSSIBILITIES:  EITHER PLAYING OR HAVE FRAME-STEPPED THE auto_delay+.1.
            and not OFF2 and auto and apply_scale(o.auto_aspect)                           --ONLY IF auto & ON2.  '' & ' ' BOTH CAST TO nil.
end
timers.auto_aspect=mp.add_periodic_timer(o.auto_delay_aspect,auto_aspect) 

function apply_crop(meta)  --@script-message, @detect_crop & @on_toggle.
    if not m.w or p.seeking then return end      --m.w AWAITS detect_crop.
    auto      = type   (meta)~='string' and auto --DISABLE auto @script-message.  RESETS @on_toggle.
    meta      = pexpand(meta)                    --meta='{w=100}' IS POSSIBLE, ETC.
    meta.w    = meta.w     or meta.x and p.width -2*meta.x or m.w or p.width  --ARG  OR  CENTERED  OR  PRIOR-VALUE  OR  FULL-width.
    meta.h    = meta.h     or meta.y and p.height-2*meta.y or m.h or p.height 
    meta.x    = meta.x     or           (p.width -  meta.w)/2  --ARG  OR  CENTERED
    meta.y    = meta.y     or           (p.height-  meta.h)/2
    command   = is1frame           and  ''  --is1frame OVERRIDE
                    ..(p.pause     and  '' or '   set pause yes;')  --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
                    ..(                       "%s vf  pre @%s-crop:lavfi=[crop='min(iw,%d):min(ih,%d):%d:%d:1:1'];"):format(command_prefix,label,meta.w,meta.h,meta.x,meta.y)  --lavfi ENABLES min EXPRESSION, WHICH SOLVES INSTA-ERROR @vid DUE TO DELAYED RELOAD (DIMENSIONS CHANGE).
                    ..(p.pause     and  '' or '   set pause no ;')
                or                      ''  --NORMAL VIDEO.
                    ..(m.w==meta.w and  '' or 'vf-command %s-crop w %d;'):format(label,meta.w)  --w=out_w  EXCESSIVE vf-command CAUSES LAG.  
                    ..(m.h==meta.h and  '' or 'vf-command %s-crop h %d;'):format(label,meta.h)  --h=out_h 
                    ..(m.x==meta.x and  '' or 'vf-command %s-crop x %d;'):format(label,meta.x)
                    ..(m.y==meta.y and  '' or 'vf-command %s-crop y %d;'):format(label,meta.y)
    command   = command~=''        and mp.command(command)      --COULD BE BLANK @on_toggle.
    kill_auto = not auto           and timers.auto_delay:kill() --NO FURTHER DETECTIONS.
    
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,p['time-pos'] --meta→m  MEMORY TRANSFER. 
    wTOLERANCE,hTOLERANCE = m.w*o.TOLERANCE[1],m.h*o.TOLERANCE[1]          --CHANGE @crop.
end

function detect_crop(keep_center,apply_inner_rectangle) --@script-message, @timers.auto_delay, @playback-restart & @on_toggle.
    timers.auto_delay:resume()                          --~auto KEEPS CHECKING UNTIL apply_crop.
    if not (W2 and p.width and p.height and gp('time-pos')) or p.seeking then return end  --W2 FOR show-text.  width=nil IF TOGGLING vo.  time-pos=nil PASSED end-file.  
    if not m.w 
    then   m.w,m.h,m.x,m.y       = p.width,p.height,0,0 end  --INITIALIZE PRIOR crop-STATE.  FOR show_text.
    if not meta.min_w 
    then   meta.min_w,meta.min_h = p.width*detect_min_ratio,p.height*detect_min_ratio end  --RESETS @property_handler.
    meta       .max_w,meta.max_h = p.width,p.height
    
    vf_metadata = gp('vf-metadata/'..label)  --Get the metadata.
    show_text   = o.meta_osd and mp.command(('show-text                        "'  
                       ..'media-title            = ${media-title}             \n'  --EXAMPLE VALUES:
                       ..'_VERSION               = %s                         \n'  --Lua 5.1  5.2
                       ..'mpv-version            = ${mpv-version}             \n'  --mpv 0.38.0  →  0.34.0
                       ..'ffmpeg-version         = ${ffmpeg-version}          \n'  
                       ..'libass-version         = ${libass-version}          \n'  
                       ..'platform               = ${platform}                \n'  --nil  windows  linux  darwin     android     
                       ..'current-ao,current-vo  = ${current-ao},${current-vo}\n'  --nil  wasapi   pulse  coreaudio  audiotrack  ,  gpu  gpu-next  direct3d  libmpv  shm
                       ..'video-params/alpha     = ${video-params/alpha}      \n'  --nil  straight
                       ..'   aspect,prior_aspect = %s,%s                      \n'  --840,525
                       ..'osd-width,osd-height   = ${osd-width},${osd-height} \n'  --840,525
                       ..'   pad_iw,pad_ih       = %d,%d                      \n'  --1680,944
                       ..'   pad_ow,pad_oh       = %d,%d                      \n'  --1680,1050
                       ..'    max_w,max_h        = ${width},${height}         \n'  --1920,1080
                       ..'    min_w,min_h        = %d,%d                      \n'  --480,270
                       ..'        w:h:x:y        = %d:%d:%d:%d              \n\n'  --1396:1066:263:7
                       ..'vf-metadata/%s = \n${vf-metadata/%s}                "'  --h<0 SOMETIMES.  EXAMPLE: ACDC BACK IN BLACK (TOO MUCH BLACK).
                   ):format(_VERSION,m.aspect or 0,m.prior_aspect or 0,m.pad_iw,m.pad_ih,W2,H2,meta.min_w,meta.min_h,m.w,m.h,m.x,m.y,label,label))  --nil INVALID ON MPV.APP.
    
    if     OFF             then return 
    elseif not vf_metadata then mp.msg.error('No crop metadata.'           ) --Verify the existence of metadata.
        mp.msg.info('Was the cropdetect filter successfully inserted?'     )
        mp.msg.info('Does your version of FFmpeg support AVFrame metadata?') 
        return end  
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do meta[key] = tonumber(vf_metadata['lavfi.cropdetect.'..key] or vf_metadata['lavfi.bbox.'..key]) end  --tonumber(nil)=nil (BUT 0+nil RAISES ERROR).
    for key in ('w h x1 y1 x2 y2    '):gmatch('[^ ]+') 
    do if not meta[key] then mp.msg.error('Got empty crop data.') 
            return end end
    
    meta.x       = meta.x            or (meta.x1+meta.x2-meta.w)/2  --bbox GIVES x1 & x2 BUT NOT x. TAKE AVERAGE.  SAME FOR y.
    meta.y       = meta.y            or (meta.y1+meta.y2-meta.h)/2 
    keep_center  = pexpand(keep_center) or loop and {} or o.keep_center  --RAW JPEG CAN MOVE CENTER. 
    is_excessive = meta.w<meta.min_w or meta.h<meta.min_h  --h<0 SOMETIMES.
    
    if is_excessive 
    then mp.msg.info('The area to be cropped is too large.'        )
         mp.msg.info('You might need to decrease detect_min_ratio.')
         return 
    elseif pexpand(apply_inner_rectangle) or o.apply_inner_rectangle 
    then xNEW  ,yNEW    = max(meta.x1,meta.x2-meta.w,meta.x       ),max(meta.y1,meta.y2-meta.h,meta.y       )
        meta.x2,meta.y2 = min(meta.x2,meta.x1+meta.w,meta.x+meta.w),min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y  = xNEW,yNEW
        meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    if keep_center[1] 
    then xNEW   = min(meta.x,p.width -(meta.x+meta.w)) --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW   = p.width- xNEW*2                      --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w> wNEW*keep_center[1] then meta.x,meta.w = xNEW,wNEW end end 
    if keep_center[2] 
    then yNEW   = min(meta.y,p.height-(meta.y+meta.h)) --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW   = p.height-yNEW*2                      --hNEW ALWAYS BIGGER THAN meta.h. 
         if hNEW-meta.h> hNEW*keep_center[2] then meta.y,meta.h = yNEW,hNEW end end  --SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
    
    is_effective = (true --Verify if it is necessary to crop.
                    and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)   --REQUIRE CHANGE IN GEOMETRY.
                    and (nil                                                         
                         or not m.time_pos or not auto                               --PROCEED IF INITIALIZING & @script-message.
                         or abs(meta.w-m.w)>wTOLERANCE or abs(meta.h-m.h)>hTOLERANCE --PROCEED IF OUTSIDE TOLERANCE.
                         or abs(meta.x-m.x)>wTOLERANCE or abs(meta.y-m.y)>hTOLERANCE
                         or abs(p['time-pos']-m.time_pos)>o.TOLERANCE.time+0         --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.
                   ))
    return is_effective and apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop) 

function   event_handler    (event)
    event                  = event.event
    if     event          == 'start-file'  then mp.command(command_prefix..' vf pre @loop:lavfi-loop=-1:1')  --INSTA-loop OF LEAD-FRAME IMPROVES JPEG RELIABILITY (HOOKS IN TIMESTAMPS).  lavfi-loop MAY BE BETTER.  video-latency-hacks ALSO RESOLVES THIS ISSUE.  LOADING-pause PREVENTS SNAPPING FOR JPEG BUT IT ALSO BLOCKS USER-pause DURING YT-LOAD IN SMPLAYER.
    elseif event          == 'end-file'    then v,W,W2,playback_restarted = nil --CLEAR SWITCHES.
    elseif event          == 'file-loaded' then file_loaded()   
    elseif event          == 'seek'        
    then   unload          =     gp('current-vo')=='null'           and remove_filters() --ANDROID MINIMIZES USING current-vo=null.  THAT CAN BE INEFFICIENT. nil GOOD, 'null' BAD.
           reload          =      p['current-vo']~='null' and not W and file_loaded()    --RELOAD @NEW-vo (ANDROID-RESTORE).  OLD MPV MAY FAIL TO TRIGGER seek, WHICH COMPLICATES property_handler.
           seek_time       =      p['time-pos'  ] 
           if is1frame or not (gp('time-pos') and W2) then return end                  --time-pos=nil PASSED end-file.
           backward_seek   = backward_seek or seek_time and p['time-pos']<seek_time-1 --IMPLIES LARGER toggle_t_delay.  revert-seek SLOW & UNNECESSARY.
           reloop          =   loop and abs  (p['time-pos']-start_time)> 1 
           start_time      = reloop and round(p['time-pos'],.001) or start_time
           reloop          = reloop and mp.command(('%s vf pre @loop:lavfi=[loop=-1:1,fps=start_time=%s]'):format(command_prefix,start_time))  --JPEG PRECISE seeking: RESET STARTPTS.  PTS MAY GO NEGATIVE!  MAYBE A NULL AUDIO STREAM COULD BE SIMPLER.  IMPRECISE seek TRIGGERS playlist-next OR playlist-prev.
    elseif not is1frame_replaced   --playback-restart: FILTERS' STATES ARE RESET, UNLESS is1frame.  
    then is1frame_replaced = is1frame
         m.pad_iw,m.pad_ih = W2,H2                                            --restart VALUES.
         m.aspect          = gp('osd-dimensions/aspect')*o.osd_par_multiplier --TARGET aspect IS THE WINDOW-SIZE.
         m.prior_aspect    = m.aspect                                         --NO MOMENTUM.
         m.w,m.h,m.x,m.y,m.time_pos,m.scale_time,p.seeking = nil --FORCES vf-COMMANDS.  THESE RE-INITIALIZE ELSEWHERE.  time_pos COULD BE RENAMED crop_time.
         
         apply_scale()
         detect_crop()    
         timers.playback_restarted:resume() end  --UNBLOCKS DOUBLE-TAPS.
end 
for event in ('start-file end-file file-loaded seek playback-restart'):gmatch('[^ ]+') 
do mp.register_event(event,event_handler) end
timers.playback_restarted = mp.add_periodic_timer(.01,function() playback_restarted=true end)  --playback-restart CAN TRIGGER BEFORE aid, BY LIKE 1ms, FOR albumart.

function property_handler(property,val)
    p   [property]           = val
    if   property           == 'android-surface-size' and val
    then gmatch              = val: gmatch('[^x]+')  --'960x444'=SMARTN12-LANDSCAPE.  nil=WINDOWS.  display MAY MEAN SOMETHING ELSE TO A SMARTPHONE.
        android_surface_size = {w = gmatch(),h = gmatch()} end
    meta.min_w,meta.min_h    = nil  --FORCE RECOMPUTATIONS.
    ow                       = o.video_out_params.w or p['display-width' ]  or android_surface_size.w or p.width  --NEW CANVAS SIZE.
    oh                       = o.video_out_params.h or p['display-height']  or android_surface_size.h or p.height
    for key in ('mute aid sid'):gmatch('[^ ]+')  --DOUBLE-TAPS.     W2 MEANS LOADED.
    do toggle                =        property==key             and W2            and playback_restarted and (not timers[key]:is_enabled() and (timers[key]:resume() or 1) or on_toggle() and nil or on_toggle_aspect()) end  --W2 BLOCKS RAW AUDIO.  TOGGLERS AWAIT playback_restarted.
    vf_observed              =        property=='vf'
    rescale                  =       (property=='osd-dimensions/aspect'     --2 RESCALES.  UNFORTUNATELY is1frame AUDIO GLITCHES.  THIS MAY INTERFERE WITH auto, FOR INSTANT RESPONSE.
                                 or   property=='vf')           and W2            and not OFF2 and apply_scale() 
    reload                   = v and (nil  --4 RELOADS: @vid, @lavfi-complex, @WxH & @alpha.  
                                 or   property=='vid'           and val           and val~=v.id              --SNAPS EMBEDDED MPV. 
                                 or   property=='lavfi-complex' and val~=''       and loop                   --remove_loop
                                 or   W and (ow~=W or oh~=H)    and not (not p.fs and p.platform=='android') --NEW CANVAS! RELOAD UNLESS HALF-SCREEN-ANDROID (IT'S SPECIAL).  SMARTPHONE ROTATION MAY DEPEND ON BUILD.
                                 or   alpha~=p['video-params/alpha']                                         --TRANSPARENCY TAKES TIME TO DETECT. 
    ) and file_loaded()
end 
for property in ('fs seeking pause terminal mute aid sid vid display-width display-height width height osd-dimensions/aspect video-params/aspect video-params/alpha android-surface-size lavfi-complex vf'):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS table
do mp.observe_property(property,'native',property_handler) end 

for   property in ('mute aid sid'):gmatch('[^ ]+')  --1SHOT NULL-OP DOUBLE-TAPS.  current-tracks/audio/selected(double_ao_timeout) & current-tracks/sub/selected(double_sub_timeout) ARE STRONGER ALT-CONDITIONS REQUIRING OFF/ON, AS OPPOSED TO ID#.  current-ao ALSO DOES WHAT current-tracks/audio/selected DOES, BUT SAFER @playlist-next.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  
do    timers[property]     = mp.add_periodic_timer(o[('double_%s_timeout'):format(property)],function()end) end
for _,timer in pairs(timers) 
do    timer.oneshot        = 1 --ALL 1SHOTS EXCEPT auto_delay & auto_aspect.
      timer:kill() end        --FOR OLD MPV. IT CAN'T START timers DISABLED.
timers.auto_delay .oneshot = false
timers.auto_aspect.oneshot = false

function is_filter_present(label) for _,vf in pairs(gp('vf')) do if vf.label==label then return true end end end  --@file_loaded & @remove_filters.
function remove_filters()  --@cleanup & @seek.
    command,W,W2,playback_restarted = '',nil
    for label in ('%s %s-crop %s-scale %s-pad-scale %s-pad %s-framerate'):gsub('%%s',label):gmatch('[^ ]+')  --% IS MAGIC.  CHECK FIRST.  @loop MAY NOT BE REMOVED.
    do  command = command..(is_filter_present(label) and '%s vf remove @%s;' or ''):format(command_prefix,label) end 
    command     = command~='' and mp.command(command) 
end

function apply_limit(detect_limit)  --@script-message.  
    limit = detect_limit
    mp.command(('vf-command %s limit %s;vf-command %s min_val %s;'):format(label,limit,label,limit))  --cropdetect;bbox
end 

function pexpand_to_string(string)  --@pprint & @show.  RETURNS string/nil, UNLIKE pexpand.
    val = pexpand(string)
    return type(val)=='string' and val or val and utils.to_string(val)
end 

function show(string,duration)  --@script-message. 
    string = pexpand_to_string(string)
    return string and mp.osd_message(string,pexpand(duration))
end

function cleanup()  --@script-message.  ENABLES SCRIPT-RELOAD WITH NEW script-opts.  SNAPS EMBEDDED MPV.
    set_end = set_end and mp.set_property('end','none') 
    re_pause()  --IF insta_unpause.
    remove_filters()
    exit()
end 

function set(script_opt,val)  --@script-message.  DOESN'T RELOAD DEPENDENT FUNCTIONS.
    o[script_opt]=type(o[script_opt])=='string' and val or pexpand(val)  --NATIVE TYPECAST.
end

function callstring(string) loadstring(string)()             end  --@script-message.  CAN REPLACE ANY OTHER.
function pprint    (string) print(pexpand_to_string(string)) end  --@script-message.  PROTECTED PRINT. 
function exit      (      ) mp.keep_running = false          end  --@script-message & @cleanup.  false FLAG EXIT: COMBINES remove_key_binding, unregister_event, unregister_script_message, unobserve_property & timers.*:kill().
for message,fn in pairs({loadstring=callstring,print=pprint,show=show,exit=exit,quit=cleanup,set=set,toggle=on_toggle,toggle_aspect=on_toggle_aspect,apply_limit=apply_limit,detect_crop=detect_crop,apply_crop=apply_crop,apply_pad=apply_pad,apply_aspect=apply_scale})  --SCRIPT CONTROLS.
do  mp.register_script_message(message,fn) end
reload = gp('time-pos') and file_loaded()  --FILE ALREADY LOADED: TRIGGER NOW.  SNAPS EMBEDDED MPV.

----SCRIPT-COMMANDS & EXAMPLES:
----script-binding             toggle_crop
----script-binding             toggle_aspect
----script-message-to autocrop loadstring <string>
----script-message             loadstring math.randomseed(365)
----script-message             print      <string>
----script-message             print      m
----script-message             show       <string>     <duration>
----script-message             show       m            10*random()
----script-message             set        <script_opt> <val>
----script-message             set        auto_aspect  "$a~=16/9 and 16/9 or 4/3"
----script-message-to autocrop exit
----script-message-to autocrop quit
----script-message-to autocrop toggle
----script-message             toggle_aspect
----script-message             apply_framerate <framerate>
----script-message             apply_framerate 60
----script-message             apply_limit     <detect_limit>
----script-message             apply_limit     10
----script-message             apply_crop      <meta>
----script-message             apply_crop      {w=1920*random(),h=1080*random()}
----script-message             detect_crop     <keep_center> <apply_inner_rectangle>
----script-message             detect_crop     {}            true
----script-message             apply_aspect    <aspect>                              <toggle_duration> <toggle_t_delay>  <toggle_expr>
----script-message             apply_aspect    ${video-params/aspect}*2^(random()-1) .5*random()       .12               x
----script-message             apply_pad       <pad_options>                         <pixelformat>     <pad_scale_flags> <par>
----script-message             apply_pad       (ow-iw)/2:(oh-ih)/2:WHITE             yuv420p           bicubic           1

----APP VERSIONS:
----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED. 
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS: windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  WON'T OPEN JPEG ON ANDROID.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.


----~600 LINES & ~8000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END (CONSOLE COMMANDS). ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----FUTURE VERSION COULD  COMBINE DOUBLE-TAPS INTO o.doubletap_property_binds & o.doubletap_timeout.
----FUTURE VERSION SHOULD MOVE o.toggle_command TO main.lua.  IT COULD ALSO OPERATE DOUBLE-TAPS.
----FUTURE VERSION SHOULD SET π=PI FOR o.toggle_expr, & IT SHOULD BE RENAMED.
----FUTURE VERSION SHOULD RESPOND TO CHANGING script-opts (function on_update).
----FUTURE VERSION SHOULD USE lavfi-complex FOR LOOPING JPEG, BUT THAT RESTRICTS TRACK-CHANGES.
----FUTURE VERSION SHOULD SYNC timers.auto_aspect WITH FILM-TIME.  THIS WOULD CHOREOGRAPH THE BLACK-BARS WITH automask.  INSTEAD OF SYNCING TO os.time, auto_aspect SHOULD SYNC TO time-pos!  THERE'S A FEW VERY DIFFERENT WAYS TO FIX THIS. 
----FUTURE VERSION SHOULD OPERATE 1fps EITHER AS is1frame MODE, OR SET MINIMUM fps=10; FOR FRAME-BY-FRAME GIFs.  vf-command DOESN'T REDRAW CURRENT FRAME.  BUT AUDIO COULD GLITCH.  THERE'S AT LEAST 3 WAYS OF CROPPING, INCLUDING video-crop.
----FUTURE VERSION SHOULD BE CAPABLE OF SMOOTH-CROPPING BY REPLACING BLACK BARS WITH BLACK PADS, & THEN SMOOTH-UNPAD. BECAUSE SMOOTH-PADDING IS EASY.  EFFICIENT TRUE SMOOTH-crop IS IMPOSSIBLE WITH FFMPEG-v6.
----FUTURE VERSION SHOULD HAVE o.keep_aspect, TO MAINTAIN TRUE ASPECT @ALL TIMES.
----FUTURE VERSION SHOULD MOVE o.limits TO A NEW SCRIPT limits.lua (OR track-list.lua?). THERE COULD BE A HUNDRED.  

----COULD BE RENAMED autocrop-mod.lua.  MY LONGEST SCRIPT - LIKE 3 SCRIPTS IN 1, +DOUBLE-TAPS. (autocrop, autopad.lua & limits.lua).  A CROP IS A PAD-REMOVAL, & A start/end IS A TIME-CROP, SO THE FULL 3xCOMBO IS MUCH MORE INTUITIVE!  SCRIPT-MESSAGES ENABLE CLEAN-SPLITTING, THOUGH.  o.framerate COULD EVEN BE A DIFFERENT SCRIPT, WHICH TAGS ON AFTER PADDING.
----BUG: apply_aspect & apply_pad SCRIPT-MESSAGES RESET aspect. USER seeking OVERRIDES THE INPUT. FUTURE VERSION SHOULD FIX THIS (BY MEMORIZING INPUT).

----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0   UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split        CLONES video. UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

