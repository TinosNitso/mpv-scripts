----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask.lua TOO. IT ALWAYS MAINTAINS PERFECT ASPECT (NO SCALING).

options={
    auto                   = true,  --IF REMOVED, CROPS OCCUR ONLY @on_toggle & @playback-restart (BUT ~@UNPAUSE). 
    auto_delay             =   .5,  --ORIGINALLY 4 SECONDS.  
    detect_limit           =   30,  --ORIGINALLY "24/255".  SET TO 0 FOR NO CROPPING.  CAN INCREASE FOR VARIOUS TRACKS.
    detect_round           =    1,  --ORIGINALLY 2.  cropdetect DEFAULT=16.
    detect_min_ratio       =  .25,  --ORIGINALLY 0.5.
    suppress_osd           = true,  --ORIGINALLY false.
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED.  SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
    key_bindings           = 'C     TAB',  --DEFAULT='C'. CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER. TOGGLE DOESN'T AFFECT start & end LIMITS.  
    key_bindings_pad       = 'Shift+TAB',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  INSTEAD OF "autopad.lua" THIS SCRIPT CAN TOGGLE PADDING.  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout    =         .5 ,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration        =         .4 ,  --SECONDS TO TOGGLE PADDING. REMOVE FOR INSTA-TOGGLE.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  IN SMPlayer.app MPV SHOULD HAVE ITS OWN WINDOW (OR ELSE window-id=nil).
    unpause_on_toggle      =         .12,  --DEFAULT=0 SECONDS.  REMOVE TO DISABLE UNPAUSE FOR PAUSED TOGGLE.  SOME FRAMES ARE ALREADY DRAWN IN ADVANCE. DOESN'T APPLY TO is1frame. 
    vf_command_t_delay     =         .12,  --DEFAULT=0 SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  IT'S NEARLY AS SLOW AS SENDING MESSAGES TO THE OPPOSITE END OF THE EARTH!  BACKWARDS-seeking ADDS HALF A SECOND.
    detect_min_ratio_image =         .1 ,  --OVERRIDE FOR JPEG.
    pad_scale_flags        =  'bilinear',  --DEFAULT bicubic  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  BUT THIS IS FOR THE PADDING DOWN-SCALER.  bicubic IS OVERRIDE FOR is1frame.  
    pad_color              =     'BLACK',  --DEFAULT BLACK.  TRANSPARENCY='BLACK@0'.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY, PINK & WHITE ARE ALSO NICE.  THIS COULD BE REPLACED WITH EXTRA x:y OPTIONS, LIKE WHETHER TO pad FROM THE CENTER OR TOP.
    -- pad_format          =  'yuva420p',  --FINAL pixelformat. UNCOMMENT FOR TRANSPARENT PADDING.
    msg_level              =     'fatal',  --{no,fatal,error,warn,info}.  ALL SCRIPTS CAN SET THEIR OWN msg-level.  TYPOS ARE OFTEN fatal.
    detector               = 'cropdetect=limit=%s:round=%s:reset=1',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1'  %s:%s = detect_limit:detect_round  reset>0.  SET TO 'bbox=%s' FOR bbox, WHICH IS FORCED FOR JPEG & alpha (TRANSPARENT VIDEO).
    TOLERANCE              = {.05,time=10},  --DEFAULT={0} (time IRRELEVANT).  INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    USE_INNER_RECTANGLE    =          true,  --AGGRESSIVE CROP-FLAG. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    keep_center            =         {0,0},  --{TOLERANCE_X,TOLERANCE_Y}  {0,0} MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS).  DOESN'T APPLY TO JPEG.  A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    -- USE_MIN_RATIO       =          true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.  DEFAULT NULLIFIES is_excessive.
    -- meta_osd            =          true,  --UNCOMMENT TO INSPECT VERSIONS, detector METADATA, ETC.  ALSO WHEN TOGGLED OFF.  DISPLAYS  _VERSION mpv-version ffmpeg-version libass-version platform current-vo media-title video-params/alpha max_w,max_h min_w,min_h vf-metadata/autocrop.
    -- toggle_expr         = '(1-cos(PI*%s))/2',  --DEFAULT=%s=LINEAR_IN_TIME_EXPRESSION  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION BTWN aspect RATIOS (HALF-WAVE). DOMAIN & RANGE BOTH [0,1].  A SINE WAVE IS 57% FASTER @MAX-SPEED, FOR SAME toggle_duration (PI/2=1.57). BUT ACCELERATION MAY BE A BAD THING!
    -- dimensions          =    {w=1680,h=1050},  --DEFAULT={w=display-width,h=display-height}  THESE ARE OUTPUT OVERRIDES.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW display-width @file-loaded, SO OVERRIDE IS REQUIRED. 
    options                = {
        '     geometry 50%',  --geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
        'osd-font-size 16 ','osd-font "COURIER NEW"','osd-bold yes',  --DEFAULTS 55,sans-serif,no  55p MAY NOT FIT GRAPHS ON osd.  MONOSPACE FONT PREFERRED.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS IS PROPRIETARY & INVALID ON MACOS.
    -- 
    },
    limits={  --NOT CASE SENSITIVE.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS.  STARTING & ENDING CREDITS ARE SIMPLER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ---- ["path-substring"]={start,end,detect_limit}={SECONDS,SECONDS<0,number} (OR nil).  detect_limit IS FINAL OVERRIDE.  start & end MAY ALSO BE PERCENTAGES.  CAN ALSO USE END OF YOUTUBE URL.  MATCHES ON FIRST find.  ARGUABLY A COMMA SHOULD LEAD EACH LINE.
         ["We are army of people - Red Army Choir"]={detect_limit=50}
        ,[  "День Победы."]={4,-13}                        --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ,["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7} --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        ,["Megadeth Sweating Bullets Official Music Video"]={0,-5}
        
    },
    keepaspect=false,  --FUTURE VERSION SHOULD BE ABLE TO MAINTAIN TRUE ASPECT @ALL TIMES.
}
o,p,m,timers = options,{},{},{}      --m,p = MEMORY,PROPERTIES   timers={mute,pause,auto_delay}
meta,aspects = {},{}                 --meta FOR detect_crop.    aspects={ON,OFF,restart} FOR PADDING.
require 'mp.options'.read_options(o) --mp=MEDIA-PLAYER

for   opt,val in pairs({key_bindings='C',key_bindings_pad='',double_mute_timeout=0,toggle_duration=0,unpause_on_toggle=0,vf_command_t_delay=0,pad_scale_flags='',pad_color='',detector='cropdetect=limit=%s:round=%s:reset=1',TOLERANCE={0},keep_center={},toggle_expr='%s',dimensions={},options={},limits={},})
do  o[opt]            = o[opt] or val end  --ESTABLISH DEFAULT OPTION VALUES.
for   opt in ('auto_delay double_mute_timeout unpause_on_toggle'):gmatch('[^ ]+')                --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON mpv.app (SAME LUA VERSION, BUILT DIFFERENT).
do  o[opt]            = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end --string→number: '1+1'→2  load INVALID ON mpv.app. 
command_prefix        = o.suppress_osd and 'no-osd' or ''
for _,opt in pairs(o.options)
do command            = ('%s%s set %s;'):format(command or '',command_prefix,opt) end
command               = command and mp.command(command) --ALL SETS IN 1.
label                 = mp.get_script_name() 
p['msg-level']        = mp.get_property_native('msg-level')
p['msg-level'][label] = o.msg_level                     --nil ALSO VALID.
mp.set_property_native('msg-level',p['msg-level'])      --ALL SCRIPTS CAN set THEIR OWN msg-level, AFTER OTHER o.options.

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR EVEN PADDING.
    D = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end  --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  FOR RAPID TOGGLE CORRECTIONS.

function property_handler(property,val)
    p[property] = val
    meta.max_w,meta.max_h,meta.min_w,meta.min_h,aspects.OFF = p.width,p.height  --FORCE RECOMPUTATION.
    double_mute =      property=='mute'                  and W   and (timers.mute:is_enabled() and on_toggle() or timers.mute:resume()) --W MEANS LOADED.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).
    re_pad      =      property=='osd-dimensions/aspect' and W2  and OFF2 and not is1frame     and apply_pad()  --CHANGING WINDOW SIZE!  OFF2 MEANS re_pad.  is1frame AUDIO WOULD GLITCH, SO MUST TOGGLE. ALSO FAILS WHEN PAUSED (MUST UNPAUSE OR FRAME-STEP). 
    reload      = ( nil  --3 POSSIBLE RELOADS:
                    or property=='vid'                   and val and           val~=m.vid     --RELOAD @vid# (CHANGE).  AN MP4TAG IS vid=2.  vid=false WHEN LOCKED.  EACH vid HAS DIFFERENT DIMENSIONS.  UNFORTUNATELY EMBEDDED MPV SNAPS EVERY TIME, DUE TO DELAYED TRIGGER.
                    or property=='video-params/alpha'    and val and detect_format=='yuv420p' --OLD MPV ONLY.  TRY SWITCH TO TRANSPARENCY. 
                    or property=='width'                 and val and not W                    --lavfi-complex MAY HAVE NEW VIDEO.
                  ) and v  and file_loaded()
    reload_pad  =   not W2 and W and p['video-params/aspect']    and (p['osd-dimensions/aspect'] or 0)>0 --W MEANS SHOULD LOAD. W2 (EVEN) MEANS LOADED PADDING.  osd_aspect=0 BEFORE MPV MEASURES ITS OWN WINDOW.  video-params/aspect=nil AFTER OSD LOADS @lavfi-complex.  BUT osd_aspect=nil AFTER VIDEO LOADS FOR vo=shm.
                    and load_pad()       --PADDING LOADS HERE.
    if property~= 'path' then return end --path_handler BELOW. COMBINES BOTH start-file & end-file.
    v,W,W2,limits = nil                  --v MEANS LOADED.  W,W2 MEAN CROPPER,PADDER ACTIVE. 
    val         = val and val:lower()    --NOT CASE SENSITIVE.  val IMPLIES start-file. 
    for key,o_limits in pairs(val and o.limits or {})                                 
    do limits   = limits or val:find(key:lower(),1,1) and o_limits end  --1,1 = STARTING_INDEX,EXACT_MATCH  TAKES FIRST MATCH.  ESTABLISH limits.
    limits      = limits or {} 
    set_start   = val and p.start =='none' and (limits[1] or limits.start ) or set_start and 'none'  --SET start & end IF NEEDED & OTHERWISE UNSET.  SIMPLER THAN seeking OR TRIMMING TIMESTAMPS. 
    set_end     = val and p['end']=='none' and (limits[2] or limits['end']) or set_end   and 'none'  
    insta_pause = val and not p.pause  --IMPROVES RELIABILITY & PREVENTS EMBEDDED MPV FROM SNAPPING.
    command     = ''
                  ..(insta_pause and '   set pause yes;'             or '') 
                  ..(val         and '%s vf  pre   @loop:loop=-1:1;' or ''):format(command_prefix          )  --INSTA-loop OF LEAD-FRAME IMPROVES RELIABILITY FOR JPEG (HOOKS IN TIMESTAMPS).  video-latency-hacks ALSO RESOLVES THIS ISSUE.
                  ..(set_start   and '%s set start %s;'              or ''):format(command_prefix,set_start)
                  ..(set_end     and '%s set end   %s;'              or ''):format(command_prefix,set_end  ) 
    command     = command~=''    and mp.command(command)  
    timers.auto_delay:kill()  --detect_crop WAITS FOR NEXT LOAD.
end 
for property in ('mute pause terminal vid width height video-params/alpha video-params/aspect osd-dimensions/aspect start end path'):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS
do mp.observe_property(property,'native',property_handler) end           --TRIGGER AFTER load-script.
timers.mute = mp.add_periodic_timer(o.double_mute_timeout,function()end) --mute TIMER TIMES.

function file_loaded()  --ALSO @property_handler.
    for  property in ('display-width display-height width height time-pos lavfi-complex video-params/alpha current-vo current-tracks/video msg-level'):gmatch('[^ ]+')  --NUMBERS STRINGS TABLES
    do p[property]   = mp.get_property_native(property) end    --FASTER THAN AWAITING OBSERVATION.
    v                = p['current-tracks/video']         or {} --WELL-DEFINED table.
    if not p.width then mp.msg.warn("autocrop only works for videos.")
        insta_pause  = insta_pause and mp.set_property_bool('pause',nil) and nil
        return end     --RAW AUDIO ENDS HERE.  THEN current-vo=nil  BUT MAYBE p.width=nil FOR current-vo=shm (MUST RELOAD LATER). 
    insta_pause      = insta_pause or not p.pause and mp.set_property_bool('pause',1)
    W                = o.dimensions.w or o.dimensions[1] or p['display-width' ] or p.width  --OVERRIDE  OR  display  OR  VIDEO   DIMENSIONS.
    H                = o.dimensions.h or o.dimensions[2] or p['display-height'] or p.height
    is1frame         = v.albumart   and p['lavfi-complex']==''                 --CHANGES @vid.  MP4TAG IS CONSIDERED albumart.  REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. 
    loop             = not is1frame and p['lavfi-complex']=='' and v.image 
    auto             = not is1frame           and o.auto                       --~auto FOR is1frame, OR AUDIO GLITCHES.
    keep_center      =    (is1frame or loop)  and {}          or o.keep_center --RAW JPEG CAN MOVE CENTER. 
    limit            = limits.detect_limit    or o.detect_limit
    detect_min_ratio =   v.image and o.detect_min_ratio_image or o.detect_min_ratio
    detector         = ((v.image or not v.id                  or p['video-params/alpha']) and 'bbox=%s' or o.detector):format(limit,o.detect_round)  --JPEG & alpha USE bbox.
    m.vid,p['time-pos'],is1frame_replaced,remove_loop = v.id,round(p['time-pos'],.001)                   --MEMORIZE v.id IN CASE IT CHANGES.  p.vid ISN'T THE SAME THING!  JPEG time-pos NEAREST MILLISECOND.  
    
    if not detect_format   then mp.set_property('msg-level','all=no')  --~detect_format MEANS ONCE ONLY, EVER.  BUT WAIT FOR file-loaded FOR OLD FFMPEG (IT BUGS OUT @load-script).
        error_format      = not mp.command(('%s vf pre @%s-scale:lavfi-format    '):format(command_prefix,label))  --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  MPV OFTEN BUILT WITH v4.2→v6.1.  v4 REQUIRES SPECIFYING format.  command RETURNS true IF SUCCESSFUL.  MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  @%s-scale FOR SIMPLICITY.
        o.toggle_duration =     mp.command(('%s vf pre @%s-scale:lavfi-scale=h=oh'):format(command_prefix,label))  --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2. 
                            and 0 or o.toggle_duration                     --h=oh MEANS NO STRETCHING (STUPID SCALER). OLD FFMPEG FAILS TO REPORT SELF-REFERENTIALITY (FALSE NEGATIVE). 
        mp.set_property_native('msg-level',p['msg-level']) end             --REPORTS TYPOS BELOW.
    detect_format  = p['current-vo']=='shm' and 'yuv420p'   or (p['video-params/alpha'] or v.image or not v.id) and 'yuva420p' or error_format and 'yuv420p' or ''  --DETECTOR PIXELFORMAT.  (SHARED MEMORY)  OR  (TRANSPARENT)  OR   (OLD FFMPEG)  OR  (NULL-OP).  FORCING yuv420p OR yuva420p IS MORE RELIABLE, ESPECIALLLY ON SMPlayer.app - IT AUTOCONVERTS. mpv.app COMPATIBLE WITH TRANSPARENCY.
    for _,vf in pairs(mp.get_property_native('vf')) 
    do remove_loop = remove_loop or vf.label=='loop' end --CHECK FOR @loop.  COULD ALSO BE THERE DUE TO OTHER SCRIPTS OR vid.  FETCH vf LAST. 
    
    
    command = (''
               ..                 '%s vf  pre    @%s-scale:lavfi=[scale=%d:%d,setsar=1];'                     --setsar=1 REQUIRED FOR RELIABILITY ON SMPlayer.app (INTERFERENCE).  SEPARATE GRAPH BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER (IN OUR OUT IS "SET IN STONE").
               ..                 '%s vf  pre    @%s-crop:crop=keep_aspect=1:exact=1;'                        --SEPARATE FOR RELIABILITY WITH alpha & OLD FFMPEG.  
               ..                 '%s vf  pre    @%s:lavfi=[format=%s,%s];'                                   --cropdetect OR bbox  CAN ALSO BE RE-ORDERED AFTER @loop. 
               ..(remove_loop and '%s vf  remove @loop;'                                               or ''):format(command_prefix)
               ..(       loop and '%s vf  pre    @loop:lavfi=[format=%s,loop=-1:1,fps=start_time=%s];' or '') --format IMPROVES alpha RELIABILITY.
               ..(insta_pause and '   set pause  no;'                                                  or '')
    ):format(command_prefix,label,W,H,command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,detect_format,p['time-pos'])
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d,%s = DECIMAL_INTEGER,string.  3 (OR 4) CHAINS + 2 FILTERS (FOR vf-command).
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                  IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = ...:start_time (SECONDS)  SETS STARTPTS FOR JPEG (--start).  JPEG SMOOTH PADDING.  USES CPU UNTIL USER PAUSES. 
    ----cropdetect = limit:round:reset         DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES.  reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip (DEFAULT=2) INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP.  alpha TRIGGERS BAD PERFORMANCE BUG.  SUPPORTS vf-command (limit).
    ----bbox       = min_val                   DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN COMBINE MULTIPLE DETECTORS IN 1 GRAPH.  SUPPORTS vf-command (min_val).
    ----crop       = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval        DEFAULT=iw:ih:bicubic:...:init  FFMPEG-v4.2 DOESN'T SUPPORT t-DEPENDENT SCALING.
    ----pad        = w:h:x:y:color   @load_pad DEFAULT=0:0:0:0:BLACK  0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW TO COLOR IN.
    ----setsar     = sar                       DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO=1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT RESOLUTION (PIXELS CAN HAVE ANY SHAPE).  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS AS GRAPH-ARMOR).  THIS IS LIKE 2 SCRIPTS COMBINED, & setsar=1 IS REPEATED THE SAME WAY, FOR RELIABILITY.
    
    
    mp.command(command)
    insta_pause=nil
    return true  --OPTIONAL.
end
mp.register_event('file-loaded',file_loaded)  --BEST TRIGGER.

function load_pad()  --@property_handler & @seek.  DELAYED TRIGGER BECAUSE MPV REQUIRES EXTRA ~.1s TO DETECT osd-dimensions/aspect>0, & PADDING APPENDS AFTER OTHER SCRIPT/S.  
    pad_format              = o.pad_format or detect_format     --OUTPUT PIXELFORMAT.  OVERRIDE  OR  DETECTOR.
    W2,H2                   = round(W,2),round(H,2)             --EVENS ONLY FOR PADDING.  W2 ALSO ACTS AS SECONDARY LOADED SWITCH.
    aspects.ON,m.osd_aspect = W2/H2,p['osd-dimensions/aspect']  --ON=NO PADDING, BY DEFINITION.  osd_aspect @INSERTION.
    aspects.OFF             = p['video-params/aspect'] * aspects.ON / p['osd-dimensions/aspect']                --TRUE ASPECT FORMULA. MULTIPLY INPUT BY RATIO OF display:osd ASPECTS.
    aspects.restart         = is1frame and not OFF2 and aspects.ON or aspects.OFF                               --DEFAULT GRAPH STATE IS OFF (PADDED), UNLESS is1frame.  HOWEVER aspects.OFF MAY CHANGE DEPENDING ON WINDOW SIZE.
    pad_iw,pad_ih           = round(math.min(W2,H2*aspects.restart),2),round(math.min(W2/aspects.restart,H2),2) --pad INPUT_WIDTH,INPUT_HEIGHT.
    command                 = (''
                               ..(not p.pause and 'set pause  yes;' or '')                                                                      --A SEPARATE INSTA-pause MORE RELIABLE.
                               ..              '%s vf  append @%s-pad-scale:scale=w=%d:h=%d:flags=%s:eval=frame;'                               --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON.
                               ..              '%s vf  append @%s-pad:lavfi=[format=%s,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s,scale=%d:%d,setsar=1];' --FINAL scale ALMOST ALWAYS NULL-OP, UNLESS W OR H ODD. 
                               ..(not p.pause and 'set pause  no ;' or '')
                              ):format(command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags,command_prefix,label,pad_format,W2,H2,o.pad_color,W,H)
    return mp.command(command)  --return OPTIONAL.
end 

function on_seek()
    if not W2 then return end 
    m.time_pos,p['time-pos'] = p['time-pos'],round(mp.get_property_number('time-pos'),.001)  --MEMORY INTERCHANGE.
    vf_command_t_delay =     auto and p['time-pos']<m.time_pos-1 and .5                      --DETECTS BACKWARDS-seek, WHICH REQUIRES t+.5s BY TRIAL & ERROR.  COULD ALSO BE MADE ANOTHER OPTION.  revert-seek SLOW & UNNECESSARY.
    loop               =     loop and mp.command(('%s vf pre @loop:lavfi=[format=%s,loop=-1:1,fps=start_time=%s]'):format(command_prefix,detect_format,p['time-pos']))  --RESET STARTPTS FOR JPEG seeking.  PTS MAY GO NEGATIVE!  is1frame SETS OF AN INDEFINITE CYCLE. MAYBE loop SHOULD NEVER APPLY TO is1frame.
    reload_pad         = not loop and m.osd_aspect~=p['osd-dimensions/aspect'] and load_pad() --IF WINDOW CHANGES SIZE, @%s-pad-scale SHOULD BE REPLACED, SINCE IT'S DEFAULT OFF STATE IS NOW DIFFERENT. CAN FULLY RELOAD.  BUT loop MESSES UP THE TIMESTAMPS.
end
mp.register_event('seek',on_seek)

function on_toggle()  --@key_binding & @property_handler.  TOGGLES BOTH crop & PADDING.  LIKE 2 SCRIPTS IN 1: BITE & STRETCH TECHNIQUE.
    if not W then return end
    OFF,m.time_pos = not OFF,nil --OFF SWITCH (FOR CROPS ONLY).  ~m.time_pos OVERRIDES TOLERANCE.
    detect_crop()                --DOES NOTHING IF OFF.
    
    if OFF then meta.x,meta.y,meta.w,meta.h = 0,0,meta.max_w,meta.max_h  --NULL CROP.
        apply_crop(meta) end
    return on_toggle_pad()
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end

function on_toggle_pad()       --@key_binding & @on_toggle.
    if not W2 then return end 
    timers.pause:kill()        --START AGAIN IF NEEDED.
    
    OFF2            = not OFF2 --LOGIC STATE OF PADDING. FULL-SCREEN=~OFF2.  EXACT NUMBERS CHANGE WITH DIMENSIONS, @vid.  OFF2 ARGUABLY THE WRONG WAY AROUND. 
    return_terminal = return_terminal or p.terminal  --THESE 4 LINES FOR RAPID-TOGGLING WHEN PAUSED.  terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING TABS AS QUICK AS TOUCH-TYPING.
    insta_unpause   = (insta_unpause  or p.pause and o.unpause_on_toggle>0 and not is1frame) --ALREADY TOGGLING OR IF PAUSED, UNLESS is1frame.  
                      and mp.command(command_prefix..' set terminal no;set pause no')        --COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
                      and (timers.pause:resume() or 1) 
    return apply_pad()
end
for key in o.key_bindings_pad:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_pad_'..key,on_toggle_pad) end

timers.pause        = mp.add_periodic_timer(o.unpause_on_toggle,function() insta_unpause,return_terminal = mp.command('set pause yes;'..(return_terminal and command_prefix..' set terminal yes' or '')) and nil end)  --pause TIMER PAUSES, BUT MUST ALSO return_terminal.
for _,timer in pairs(timers)
do    timer.oneshot = 1 end  --ALL ABOVE ARE 1SHOT.

function playback_restart()  --GRAPH STATES ARE RESET, UNLESS is1frame. 
    if not W2 or is1frame_replaced then return end --W2 MEANS LOADED PADDING.  is1frame ONCE ONLY. ITS FILTER REPLACEMENTS CAN TRIGGER INFINITE CYCLE.
    m.aspect,is1frame_replaced = aspects.restart,is1frame
    m.time_pos,m.w,m.h,m.x,m.y = nil  --FORCES ALL vf-COMMANDS.
    
    detect_crop() --STARTS auto_delay TIMER.
    apply_pad()   --IF PAUSED IT TAKES A FEW FRAMES TO TURN ON.
end
mp.register_event('playback-restart',playback_restart)

function apply_pad(aspect)  --@playback-restart, @property_handler, @on_toggle_pad & @on_toggle.  SIMPLER TO SEPARATE UTILITY FROM ITS TOGGLE.  STRETCHES BLACK BARS WITHOUT CHANGING [vo] scale. 
    if not p['video-params/aspect'] then return end  --nil WHEN TOGGLING lavfi-complex ON RAW MP3. (VIDEO VANISHES, BUT OSD STILL UPDATES.)
    aspects.OFF         = aspects.OFF          or p['video-params/aspect'] * aspects.ON / p['osd-dimensions/aspect']    --TRUE ASPECT FORMULA.  IT'S JUST WHATEVER THE INPUT IS, MULTIPLIED BY RATIO OF STARTING TO OSD ASPECT, BECAUSE OF HOW THE GRAPHS ARE SET.  THERE ARE ALSO OTHER EXPLANATION/S.  REAL ASPECT OF EACH PIXEL IS ASSUMED TO BE ACCOUNTED FOR IN osd-dimensions/aspect. demux-par IS ACCOUNTED FOR IN video-params/aspect.
    aspect              = aspect               or OFF2 and aspects.OFF    or aspects.ON
    pad_time            = mp.get_property_number('time-pos')+(vf_command_t_delay or o.vf_command_t_delay)               --DELAY OFTEN SET ELSEWHERE, FOR SPECIAL CASES. 
    pad_time            = pad_time-(m.pad_time and clip(toggle_duration-(pad_time-m.pad_time),0,toggle_duration) or 0)  --RAPID TOGGLING CORRECTION, ASSUMES LINEARITY.  REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.
    toggle_duration     = insta_unpause        and 0 or o.toggle_duration                                               --insta_unpause RESETS ITSELF TO nil.  COULD ALSO BE MADE 0 FOR LOOPING SHORT GIF (EACH ITERATION STRETCHES). ALSO PAUSED seeking COULD USE 0 VALUE.
    toggle_expr         = toggle_duration==0   and 1 or ('clip((t-%s)/(%s),0,1)'):format(pad_time,toggle_duration)      --A DIFFERENT VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    toggle_expr         = o.toggle_expr:gsub('%%s',toggle_expr)                                                         --NON-LINEAR clip.  [0,1] DOMAIN & RANGE.  0,1 = INITIAL,FINAL  TIME EXPRESSION FOR SMOOTH-PADDING.
    m.pad_iw,pad_iw,m.pad_ih,pad_ih = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.  STORING THEM PROPERLY IN MEMORY IS MORE CODE, SO DEDUCE FROM m.aspect.
    Dpad_iw,Dpad_ih     = pad_iw-m.pad_iw,pad_ih-m.pad_ih --DIFFERENCE VALUES.  Δ INVALID ON mpv.app.
    command             =  --PADS EITHER HORIZONTALLY OR VERTICALLY.
                          is1frame      and      ('%s vf append @%s-pad-scale:scale=w=%d:h=%d;'          ):format(command_prefix,label,pad_iw,pad_ih               )  --apply_crop insta_pause FIRST.  
                          or                ''
                          ..(Dpad_iw==0 and '' or '%s vf-command %s-pad-scale w round((%d+%d*(%s))/2)*2;'):format(command_prefix,label,m.pad_iw,Dpad_iw,toggle_expr)  --CHECK COMMAND NEEDED, FIRST.  FORCE IF error_format (OLD FFMPEG).
                          ..(Dpad_ih==0 and '' or '%s vf-command %s-pad-scale h round((%d+%d*(%s))/2)*2;'):format(command_prefix,label,m.pad_ih,Dpad_ih,toggle_expr)
    command             = command~=''   and mp.command(command) --COULD BE BLANK WHEN PRESERVING OFF2 STATE.
    m.aspect,m.pad_time,vf_command_t_delay = aspect,pad_time    --MEMORY TRANSFER FOR RAPID TOGGLING.
    return true
end 

function apply_crop(meta)  --@detect_crop & @on_toggle.
    if not meta.max_w then return end                      --OTHERWISE ERROR WHEN TOGGLING vid & autocrop, TOGETHER!
    is_excessive =     (meta.w<meta.min_w or meta.h<meta.min_h)
                   and (mp.msg.info('The area to be cropped is too large.'        ) or 1)
                   and (mp.msg.info('You might need to decrease detect_min_ratio.') or 1)
    
    if meta.w<meta.min_w then if not o.USE_MIN_RATIO 
         then meta.w,meta.x = meta.max_w,0           --NULLIFY
         else meta.w,meta.x = meta.min_w,clip(meta.x-(meta.min_w-meta.w)/2,0,meta.max_w-meta.min_w) end end  --MINIMIZE w & clip x.
    if meta.h<meta.min_h then if not o.USE_MIN_RATIO
         then meta.h,meta.y = meta.max_h,0           --NULLIFY                                                       
         else meta.h,meta.y = meta.min_h,clip(meta.y-(meta.min_h-meta.h)/2,0,meta.max_h-meta.min_h) end end  --MINIMIZE h & clip y.

    if not (m.w and m.h and m.x and m.y) then m.w,m.h,m.x,m.y = meta.max_w,meta.max_h,0,0 end --INITIALIZE 0TH crop AT BEGINNING FOR INITIAL CHECK.
    is_effective = (      --Verify if it is necessary to crop.
                    (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)                                  --REQUIRE CHANGE IN GEOMETRY.
                    and (not m.time_pos                                                                         --PROCEED IF INITIALIZING.
                         or  math.abs(meta.w-m.w)>m.w*o.TOLERANCE[1] or math.abs(meta.h-m.h)>m.h*o.TOLERANCE[1] --PROCEED IF OUTSIDE TOLERANCE.
                         or  math.abs(meta.x-m.x)>m.w*o.TOLERANCE[1] or math.abs(meta.y-m.y)>m.h*o.TOLERANCE[1]
                         or  math.abs(p['time-pos']-m.time_pos)>o.TOLERANCE.time+0                              --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.
                   ))
    if not is_effective then return end
    
    command   = is1frame           and  ''  --is1frame OVERRIDE
                    ..(p.pause     and  '' or '   set pause yes;') --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
                    ..(                       '%s vf  pre @%s-crop:lavfi=[crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1];'):format(command_prefix,label,meta.w,meta.h,meta.x,meta.y)  --lavfi ENABLES min EXPRESSION, WHICH SOLVES LOGGED ERROR @vid DUE TO DELAYED TRIGGER.
                    ..(p.pause     and  '' or '   set pause no ;')
                or                      ''  --NORMAL VIDEO.
                    ..(m.w==meta.w and  '' or '%s vf-command %s-crop w %d;'):format(command_prefix,label,meta.w)  --w=out_w  EXCESSIVE vf-command CAUSES LAG.  
                    ..(m.h==meta.h and  '' or '%s vf-command %s-crop h %d;'):format(command_prefix,label,meta.h)  --h=out_h 
                    ..(m.x==meta.x and  '' or '%s vf-command %s-crop x %d;'):format(command_prefix,label,meta.x)
                    ..(m.y==meta.y and  '' or '%s vf-command %s-crop y %d;'):format(command_prefix,label,meta.y)
    command   = command~=''        and mp.command(command)      --COULD BE BLANK @on_toggle.
    kill_auto = not auto           and timers.auto_delay:kill() --NO FURTHER DETECTIONS.
    
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,p['time-pos']  --meta→m  MEMORY TRANSFER. 
    return true  --OPTIONAL
end

function detect_crop()  --@timers.auto_delay, @playback-restart & @on_toggle.
    if not meta.max_w then return end                      --OTHERWISE ERROR WHEN TOGGLING vid.
    meta.min_w = meta.min_w or meta.max_w*detect_min_ratio --RECOMPUTE IF NEEDED.
    meta.min_h = meta.min_h or meta.max_h*detect_min_ratio
    show_text  = o.meta_osd and mp.command(('%s show-text                 "'
                     ..'_VERSION             = %s                        \n'  --Lua 5.1
                     ..'mpv-version          = ${mpv-version}            \n'  --mpv 0.38.0
                     ..'ffmpeg-version       = ${ffmpeg-version}         \n'  
                     ..'libass-version       = ${libass-version}         \n'  
                     ..'platform             = ${platform}               \n'  --windows  linux  darwin  
                     ..'current-vo           = ${current-vo}             \n'  --gpu  direct3d  libmpv  shm
                     ..'media-title          = ${media-title}            \n'  --MAYBE CONVENIENT.
                     ..'video-params/alpha   = ${video-params/alpha}     \n'  --(unavailable)  straight
                     ..'osd-width,osd-height = ${osd-width},${osd-height}\n' 
                     ..'   pad_iw,pad_ih     = %d,%d                     \n' 
                     ..'        W,H          = %d,%d                     \n'  --1680,1050
                     ..'    max_w,max_h      = %d,%d                     \n'  --1920,1080
                     ..'    min_w,min_h      = %d,%d                   \n\n'  --480,270
                     ..'vf-metadata/%s = \n${vf-metadata/%s}              "'            
                 ):format(command_prefix,_VERSION,pad_iw,pad_ih,W,H,meta.max_w,meta.max_h,meta.min_w,meta.min_h,label,label))
    
    timers.auto_delay:resume()  --~auto KEEPS CHECKING UNTIL apply_crop.
    if OFF then return end
    
    vf_metadata,p['time-pos'] = mp.get_property_native('vf-metadata/'..label ),mp.get_property_number('time-pos')  --Get the metadata.
    if not vf_metadata  --Verify the existence of metadata.
    then mp.msg.error('No crop metadata.'                                    )
         mp.msg.info ('Was the cropdetect filter successfully inserted?'     )
         mp.msg.info ('Does your version of FFmpeg support AVFrame metadata?')
         return end 
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do meta[key] = tonumber(vf_metadata['lavfi.cropdetect.'..key] or vf_metadata['lavfi.bbox.'..key]) end  --tonumber(nil)=nil (BUT 0+nil RAISES ERROR).
    for key in ('w h x1 y1 x2 y2    '):gmatch('[^ ]+') 
    do if not meta[key] then mp.msg.error('Got empty crop data.') 
            return end end
    
    meta.x = meta.x or (meta.x1+meta.x2-meta.w)/2  --bbox GIVES x1 & x2 BUT NOT x. TAKE AVERAGE.  SAME FOR y.
    meta.y = meta.y or (meta.y1+meta.y2-meta.h)/2 
    
    if o.USE_INNER_RECTANGLE 
    then xNEW  ,yNEW    = math.max(meta.x1,meta.x2-meta.w,meta.x       ),math.max(meta.y1,meta.y2-meta.h,meta.y       )
        meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y  = xNEW,yNEW
        meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    if keep_center[1] 
    then xNEW = math.min( meta.x , meta.max_w-(meta.x+meta.w) ) --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW = meta.max_w-xNEW*2                               --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*keep_center[1]                     --SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
         then meta.x,meta.w = xNEW,wNEW end end
    if keep_center[2] 
    then yNEW = math.min( meta.y , meta.max_h-(meta.y+meta.h) ) --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW = meta.max_h-yNEW*2                               --hNEW ALWAYS BIGGER THAN meta.h. 
         if hNEW-meta.h>hNEW*keep_center[2]  
         then meta.y,meta.h = yNEW,hNEW end end  
    return apply_crop(meta)  --return OPTIONAL.
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop) 
for _,timer in pairs(timers) do timer:kill() end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----A FUTURE VERSION SHOULD CROP WITHOUT CHANGING ASPECT (~EQUIVALENT TO AUTO-ZOOM). o.MAINTAIN_ASPECT. 
----MY LONGEST SCRIPT. IT'S LIKE 2.5 SCRIPTS IN 1 (autocrop, autopad & start/end PLAYLIST MANAGER). BUT A CROP IS A PAD-REMOVAL, SO THE FULL COMBO IS MORE INTUITIVE!

----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

