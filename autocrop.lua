----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask TOO.

options={
    auto                = true,  --IF false, CROPS OCCUR ONLY on_toggle & @playback-restart. 
    auto_delay          =   .5,  --ORIGINALLY 4 SECONDS.  
    detect_limit        =   30,  --ORIGINALLY "24/255".  CAN INCREASE detect_limit FOR VARIOUS TRACKS, & lavfi-complex OVERLAY.
    detect_round        =    1,  --ORIGINALLY 2.  cropdetect DEFAULT=16.
    detect_min_ratio    =  .25,  --ORIGINALLY 0.5.
    suppress_osd        = true,  --ORIGINALLY false.
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED.  SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
    key_bindings        = 'C     Tab',  --DEFAULT='C'. CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER. TOGGLE DOESN'T AFFECT start & end LIMITS.  
    key_bindings_pad    = 'Shift+Tab',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  INSTEAD OF "autopad.lua" THIS SCRIPT CAN TOGGLE PADDING.  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout =         .5 ,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration     =         .4 ,  --SECONDS TO TOGGLE PADDING. REMOVE FOR INSTA-TOGGLE.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  AN EXTRA fps OPTION COULD MAKE PADDING SMOOTHER THAN FILM ITSELF!
    unpause_on_toggle   =         .12,  --DEFAULT=0 SECONDS.  REMOVE TO DISABLE UNPAUSE FOR PAUSED TOGGLE.  SOME FRAMES ARE ALREADY DRAWN IN ADVANCE. DOESN'T APPLY TO is1frame. 
    vf_command_t_delay  =         .12,  --DEFAULT=0 SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  IT'S NEARLY AS SLOW AS SENDING MESSAGES TO THE OPPOSITE END OF THE EARTH!
    pad_scale_flags     =  'bilinear',  --DEFAULT=bicubic  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  BUT THIS IS FOR THE PADDING DOWN-SCALER.
    pad_color           =     'BLACK',  --DEFAULT BLACK.  TRANSPARENCY='BLACK@0'.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY, PINK & WHITE ARE ALSO NICE.  THIS COULD BE REPLACED WITH EXTRA x:y OPTIONS, LIKE WHETHER TO pad FROM THE CENTER OR TOP.
    -- pad_format       =  'yuva420p',  --FINAL pixelformat. UNCOMMENT FOR TRANSPARENT PADDING.
    detector            = 'cropdetect=limit=%s:round=%s:reset=1',           --DEFAULT='cropdetect=limit=%s:round=%s:reset=1'  %s,%s = detect_limit,detect_round  reset>0.
    options_image       = {detector='bbox=min_val=%s',detect_min_ratio=.1}, --DEFAULT={detector='bbox=%s'}  OVERRIDES FOR IMAGES (detect_limit ALSO).   bbox ALSO ACTS AS alpha OVERRIDE. TRANSPARENT VIDEO CAUSES A cropdetect BUG. 
    TOLERANCE           = {.05,time=10},  --DEFAULT={0} (time IRRELEVANT).  INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    MAINTAIN_CENTER     = {0,0},  --{TOLERANCE_X,TOLERANCE_Y}  DOESN'T APPLY TO JPEG.  {0,0} MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE =  true,  --AGGRESSIVE CROP-FLAG. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO    =  true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.  DEFAULT IGNORES EXCESSIVE detect_crop.
    -- toggle_expr      =    '(1-cos(PI*%s))/2',  --DEFAULT=%s=LINEAR_IN_TIME_EXPRESSION  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION BTWN aspect RATIOS (HALF-WAVE). DOMAIN & RANGE BOTH [0,1].  A SINE WAVE IS 57% FASTER @MAX-SPEED, FOR SAME toggle_duration (PI/2=1.57). BUT ACCELERATION MAY BE A BAD THING!
    -- dimensions       = {w=1680,h=1050,par=1},  --DEFAULT={w=display-width,h=display-height,par=osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO}  THESE ARE OUTPUT PARAMETERS. THE TRUE ASPECT-TOGGLE ACCOUNTS FOR BOTH PAR_IN & PAR_OUT, VALID @FULLSCREEN.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW DISPLAY w,h,par @file-loaded, SO OVERRIDE IS REQUIRED.  CAN MEASURE display TO DETERMINE par.
    -- crop_no_vid      =    true, --crop ABSTRACT VISUALS TOO (PURE lavfi-complex).
    -- meta_osd         =  true,  --UNCOMMENT TO INSPECT VERSIONS, detector METADATA, ETC.  DISPLAYS  _VERSION mpv-version ffmpeg-version libass-version platform current-vo osd-par vf-metadata/autocrop
    msg_level           = 'error', --{no,error,warn,info}. DEFAULT no.  EACH SCRIPT CAN PREPEND ITS OWN msg-level TO ALL OTHERS.
    options             = {
        '     geometry 50%',  --geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
        'osd-font-size 16 ','osd-font Consolas',  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd.  MONOSPACE FONT PREFERRED.
    },
    limits={  --NOT CASE SENSITIVE.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS.  STARTING & ENDING CREDITS ARE SIMPLER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ----["path-substring"]={start,end,detect_limit}={SECONDS,SECONDS<0,number} (OR nil).  detect_limit IS FINAL OVERRIDE.  start & end MAY ALSO BE PERCENTAGES.  CAN ALSO USE END OF YOUTUBE URL.  MATCHES ON FIRST find.  ARGUABLY A COMMA SHOULD LEAD EACH LINE.
         ["We are army of people - Red Army Choir"]={detect_limit=50}
        ,[  "День Победы."]={4,-13}                        --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ,["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7} --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        ,["Megadeth Sweating Bullets Official Music Video"]={0,-5}
        
    },
}
require 'mp.options'.read_options(options)    --OPTIONAL?
o,label        = options,mp.get_script_name() --label=autocrop  mp=MEDIA-PLAYER
meta_name      = 'vf-metadata/'..label  --'vf-metadata/autocrop'
m,p            = {},{}  --m=METADATA MEMORY  p=PROPERTIES
command_prefix = o.suppress_osd and 'no-osd' or ''
for   opt,val in pairs({key_bindings='C',key_bindings_pad='',double_mute_timeout=0,toggle_duration=0,unpause_on_toggle=0,vf_command_t_delay=0,pad_scale_flags='',pad_color='',detector='cropdetect=limit=%s:round=%s:reset=1',options_image={detector='bbox=%s'},TOLERANCE={0},MAINTAIN_CENTER={},toggle_expr='%s',dimensions={},options={},limits={},})
do  o[opt]     = o[opt] or val end  --ESTABLISH DEFAULT OPTION VALUES.
for   opt in ('auto_delay double_mute_timeout unpause_on_toggle'):gmatch('[^ ]+')  --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON mpv.app (SAME LUA VERSION, BUILT DIFFERENT).
do  o[opt]     = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end  --string→number: '1+1'→2  load INVALID ON mpv.app. 
-- command        = o.msg_level and ('%s set msg-level %s=%s,${msg-level};'):format(command_prefix,label,o.msg_level)  --TRAILING , ALLOWED.
for _,opt in pairs(o.options)
do command     = ('%s%s set %s;'):format(command or '',command_prefix,opt) end
command        = command and mp.command(command)  --ALL SETS IN 1.
p['msg-level']        = mp.get_property_native('msg-level')
p['msg-level'][label] = o.msg_level
mp.set_property_native('msg-level',p['msg-level'])

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR EVEN PADDING.
    D          = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end  --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  FOR RAPID TOGGLE CORRECTIONS.


function start_file()
    for  property in ('path start end'):gmatch('[^ ]+') 
    do p[property] = mp.get_property(property) end  --property CALLS.
    limits,path    = nil,p.path:lower()  --ESTABLISH limits. NOT CASE SENSITIVE.  
    for key,val in pairs(o.limits) 
    do limits      = limits or path:find(key:lower(),1,1) and val end  --1,1 = STARTING_INDEX,EXACT_MATCH  USES FIRST MATCH.
    limits         = limits or {}
    limits[1]      = limits[1] or limits.start
    limits[2]      = limits[2] or limits['end']
    set_start      = limits[1] and ('none 0%'):find(p.start,1,1)  --SET start IF UNSET OR 0.  SIMPLER THAN seeking OR TRIMMING TIMESTAMPS.  ("%" IS MAGIC)
    set_end        = limits[2] and (p['end']=='none' or p['end']=='100%')
    command        =                  ''
                     ..(set_start and '%s set start %s;' or ''):format(command_prefix,limits[1])
                     ..(set_end   and '%s set end   %s;' or ''):format(command_prefix,limits[2])
    command        = command~='' and mp.command(command)
end
mp.register_event('start-file',start_file)

function end_file()    --FOR MPV PLAYLISTS, OR ELSE NEXT TRACK STARTS WRONG.
    W,command = nil,'' --W MEANS CROPPER ACTIVE. BUT NEXT FILE MAY BE ~vid.
                ..(set_start and '%s set start %s;' or ''):format(command_prefix,p.start )  --RETURN start & end TO ORIGINAL VALUES. THESE PERSIST.
                ..(set_end   and '%s set end   %s;' or ''):format(command_prefix,p['end'])
    command = command~='' and mp.command(command)
end 
mp.register_event('end-file',end_file)

function file_loaded()  --ALSO @vid, @video-params & @osd-par.  MPV REQUIRES EXTRA ~.1s TO DETECT alpha & osd-par. 
    for  property in ('msg-level current-vo display-width display-height time-pos current-tracks/video video-params vf'):gmatch('[^ ]+')  --STRINGS NUMBERS TABLES
    do p[property]            = mp.get_property_native(property) end  --FASTER THAN AWAITING OBSERVATION.
    v,v_params                = p['current-tracks/video'],p['video-params']
    is_video                  = v or v_params
    msg                       = not is_video and mp.msg.warn("autocrop only works for videos.")  --MAY TRIGGER PREMATURELY, BEFORE lavfi-complex.
    if not is_video or not v and not o.crop_no_vid then return end  --return CONDITIONS.  lavfi-complex MAY NOT NEED CROPPING.
    v,v_params                = v or {},v_params or {}  --WELL-DEFINED type.
    error_scale               = error_scale  or not detect_format and mp.set_property('msg-level','all=no')  --~detect_format MEANS ONCE ONLY (load-script SWITCH).  DETECT OLD FFMPEG. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  
                                and not mp.command(('%s vf pre @%s-scale:lavfi-scale=h=oh'):format(command_prefix,label)) --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2. OLD FFMPEG FAILS TO REPORT SELF-REFERENTIALITY (FALSE NEGATIVE). MPV OFTEN BUILT WITH v4.2→v6.1.  command RETURNS true IF SUCCESSFUL. THEY'RE BEST KEPT SEPARATED. 
    error_format              = error_format or not detect_format 
                                and not mp.command(('%s vf pre @%s-scale:lavfi-format'    ):format(command_prefix,label)) --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  "autocrop-scale" LABEL USED FOR SIMPLICITY.  v4 REQUIRES FORCING COMMANDS, RESULTING IN LAG. 
    set_msg_level             = not detect_format and mp.set_property_native('msg-level',p['msg-level'])  --MAY BE BLANK.  REPORT FURTHER ERRORS, IN CASE OF TYPOS BELOW.
    o.toggle_duration         = error_scale and o.toggle_duration or 0  --h=oh MEANS NO STRETCHING (STUPID SCALER).
    lavfi_complex             = mp.get_opt('lavfi-complex')
    is1frame                  = v.albumart and not lavfi_complex  --REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. MP4TAG TRACK 2 IS CONSIDERED albumart. is1frame TOGGLES WHEN USER SWITCHES TRACK.
    loop                      = v.image    and not lavfi_complex
    MAINTAIN_CENTER           = loop and {}  or o.MAINTAIN_CENTER  --RAW JPEG CAN MOVE CENTER. 
    auto                      = not is1frame and o.auto  --~auto FOR is1frame.
    detect_format             = p['current-vo']:find('shm') and 'yuv420p' or v_params.alpha and 'yuva420p' or error_format and 'yuv420p' or ''  --DETECTOR PIXELFORMAT.  (SHARED MEMORY)  OR  (TRANSPARENT)  OR   (OLD FFMPEG)  OR  (NULL-OP).  FORCING yuv420p OR yuva420p IS MORE RELIABLE, ESPECIALLLY ON SMPlayer.app(vo='shm,!') - IT AUTOCONVERTS. mpv.app DETECTS TRANSPARENCY OK, BUT NOT EMBEDDED shm.
    pad_format                = o.pad_format or detect_format  --OUTPUT PIXELFORMAT.  OVERRIDE  OR  DETECTOR.
    detect_limit              = limits.detect_limit or v.image  and o.options_image.detect_limit     or o.detect_limit
    detect_min_ratio          =                        v.image  and o.options_image.detect_min_ratio or o.detect_min_ratio
    detector                  =    ((v_params.alpha or v.image) and o.options_image.detector or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USE bbox.
    m                         = {vid=v.id,par=par}  --MEMORIZE v.id & par(OUT) IN CASE THEY CHANGE.  p.vid ISN'T THE SAME THING!
    W                         = o.dimensions.w or o.dimensions[1] or p['display-width' ] or v_params.w or v['demux-w']  --OVERRIDE  OR  display  OR  VIDEO   DIMENSIONS. v_params DEPEND ON lavfi-complex.
    H                         = o.dimensions.h or o.dimensions[2] or p['display-height'] or v_params.h or v['demux-h']
    aspect                    = (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect)*(v['demux-par'] or v_params.par or 1)/par  --ABBREVIATE aspect=aspect_out.  DEFAULT GRAPH STATE IS ALWAYS OFF (PADDED). BUT ON/OFF STATE IS PRESERVED BTWN TRACKS.
    W2,H2,time_pos            = round(W,2),round(H,2),round(p['time-pos'],.001)  --EVENS ONLY FOR PADDING.  JPEG time-pos NEAREST MILLISECOND.  FUTURE VERSION NEEDS TO RELOAD JPEG @seek (RESET STARTPTS).
    aspects                   = {OFF=aspect,ON=W2/H2}  --OFF OR ON(FULL-SCREEN).  2 PAD STATES.  A CROP-ON IS NO-PADDING, BUT INSTEAD  ON=FULL-SCREEN=PAD-OFF.  THIS ASSUMES v['demux-w']/v['demux-h'] DOESN'T CHANGE, EXCEPT @vid (TRACK CHANGE). OTHERWISE COULD OBSERVE current-tracks/video INSTEAD OF JUST vid.
    pad_iw,pad_ih             = round(math.min(W2,H2*aspect),2),round(math.min(W2/aspect,H2),2)  --pad INPUT_WIDTH,INPUT_HEIGHT.
    aspect                    = m.aspect~=aspects.OFF and aspects.ON or aspect  --ENFORCED @playback-restart.  TOGGLE ON IF NEEDED BUT PRESERVE pad STATE. 
    for _,filter in pairs(p.vf) --CHECK FOR @loop (DUE TO PRIOR image OR OTHER SCRIPTS).
    do remove_loop            = remove_loop or filter.label=='loop' end 
    playback_started,remove_loop,min_w,min_h = nil,nil,nil,nil  --SOME COMMANDS AWAIT playback_started. remove_loop IF NECESSARY @vid.  FORCE min_w,min_h RE-COMPUTATION.
    
    
    command         = (    ''
        ..(not p.pause and '%s set pause  yes;'                                                 or ''):format(command_prefix)  --PREVENTS EMBEDDED MPV FROM SNAPPING ON JPEG, & is1frame INTERFERENCE. 
        ..                 '%s vf  pre    @%s-scale:lavfi=[scale=%d:%d,setsar=1];'                     --setsar=1 REQUIRED FOR RELIABILITY ON SMPlayer.app (INTERFERENCE).  SEPARATE GRAPH BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER.  W,H NOT W2,H2.
        ..                 '%s vf  pre    @%s-crop:crop=keep_aspect=1:exact=1;'                        --SEPARATE FOR RELIABILITY WITH OLD FFMPEG & PNG-alpha.  
        ..                 '%s vf  pre    @%s:lavfi=[format=%s,%s];'                                   --cropdetect OR bbox
        ..(remove_loop and '%s vf  remove @loop;'                                               or ''):format(command_prefix)
        ..(loop        and '%s vf  pre    @loop:lavfi=[format=%s,loop=-1:1,fps=start_time=%s];' or '') --FORMATTING BEFORE loop PREVENTS EMBEDDED MPV FROM SNAPPING ON PNG (TRANSPARENCY). FORCING yuva420p MAY BE SAFER THAN ARBITRARY RGBA FORMATS.  fps=25 MAY BE AN ISSUE FOR LEAD-FRAMES (MP4TAG). 
        ..(not p.pause and '%s set pause  no;'                                                  or ''):format(command_prefix) --INSTANT UNPAUSE.
    ):format(command_prefix,label,W,H,command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,detect_format,time_pos)
    
    command_timeout = (    ''                                                                 --timeout ALLOWS OTHER SCRIPTS TO INSERT THEIR GRAPHS FIRST.
        ..                 '%s vf  append @%s-scale-pad:scale=w=%d:h=%d:flags=%s:eval=frame;' --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON.
        ..                 '%s vf  append @%s-pad:lavfi=[format=%s,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s,scale=%d:%d,setsar=1];' --FINAL scale ALMOST ALWAYS NULL-OP. W,H MAY BE ODD.
    ):format(command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags,command_prefix,label,pad_format,W2,H2,o.pad_color,W,H)
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d,%s = DECIMAL_INTEGER,string.  3 (OR 4) CHAINS + 2 FILTERS (FOR vf-command).  SEPARATE FILTERS IMPROVES RELIABILITY OVER FFMPEG VERSIONS & alpha.
    ----loop       = loop:size  ( >=-1 : >0 )   IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                   IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = fps:start_time             DEFAULT=25  start_time (SECONDS) SETS STARTPTS FOR JPEG (--start).  THIS USES ~5% CPU UNTIL USER HITS PAUSE. FOR SMOOTH PADDING ON JPEG.
    ----cropdetect = limit:round:reset          DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP (2 BY DEFAULT).  alpha TRIGGERS BAD PERFORMANCE BUG.
    ----bbox       = min_val                    DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH, BUT THAT COMBINES DEFICITS.
    ----crop       = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval         DEFAULT=iw:ih:bicubic:...:init  dst_format CAN ALSO BE SET (ALTERNATIVE TO format). 
    ----pad        = w:h:x:y:color              DEFAULT=0:0:0:0:BLACK   0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar     = sar                        DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO=1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT (IN REALITY OUTPUT IS DIFFERENT).  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS AS ARMOR).  THIS IS LIKE 2 SCRIPTS COMBINED, & setsar=1 IS REPEATED FOR RELIABILITY.
    
    
    mp.command(command)
    timers.command:resume() --vf append
    detect_crop()           --STARTS TIMER.
end
mp.register_event('file-loaded',file_loaded)

timers      = {  --CARRY OVER IN MPV PLAYLIST. 
    mute    = mp.add_periodic_timer(o.double_mute_timeout,function()end                           ),  --mute TIMER TIMES.
    command = mp.add_periodic_timer(0.01                 ,function()mp.command(command_timeout)end),  --vf append  0s ALSO SUFFICIENT.
}

function property_handler(property,val)
    p[property] = val
    toggle      =  property=='mute'         and on_toggle('mute')  --SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).
    par         =  property=='osd-par'      and (o.dimensions.par or o.dimensions[3] or val>0 and val or 1) or par  --0,1 = AUTO,SQUARE  0@load-script, 0@file-loaded, & 1@playback-restart. BUT MAYBE ~1 ON EXPENSIVE SYSTEM.  UNLESS OVERRIDE, ASSUME osd-par=SCREEN PIXEL ASPECT RATIO = ASPECT OF EACH PIXEL ON TV OR PROJECTOR SCREEN.
    reload      = (property=='vid'          and val and val~=m.vid or m.par~=par) and W and file_loaded()  --RELOAD @vid=# CHANGES, & @par(UNTESTED).  vid=false WHEN LOCKED BY lavfi-complex.  AN MP4TAG IS vid=2 & CAN BE CROPPED/PADDED TOO. MP3 TOO.  EACH vid HAS DIFFERENT DIMENSIONS.
    if             property=='video-params' and val  --video-params ALMOST NEVER CHANGE.  TRIGGERS ~.1s AFTER file-loaded, & nil@load-script.
    then max_w,max_h = val.w,val.h
         min_w,min_h = nil,nil
         reload = not W or val.alpha~=v_params.alpha and file_loaded() end  --RELOAD IF NEEDED @lavfi-complex OR @alpha.
end 
for property in ('pause seeking mute vid osd-par video-params'):gmatch('[^ ]+')  --MORE EFFICIENT TO observe.  BOOLEANS, NUMBERS & table
do mp.observe_property(property,'native',property_handler) end  --TRIGGER @load-script.

function playback_restart() --GRAPH STATES ARE RESET, UNLESS is1frame. 
    if not W or is1frame and playback_started then return end  --W MEANS CROPPER ACTIVE (PREVENTS GLITCH).  is1frame ONCE ONLY. ITS GRAPH REPLACEMENTS TRIGGER INFINITE LOOP.
    playback_started = true
    aspect           = aspect==aspects.ON and aspects.OFF or aspects.ON --ON←→OFF  FORCE pad TOGGLE BACK TO PROPER STATE.
    m.time_pos,m.w,m.h,m.x,m.y,m.aspect = nil,nil,nil,nil,nil,nil       --nil FORCES ALL vf-COMMANDS, IF NEEDED.
    detect_crop()   --RESUMES TIMER.
    on_toggle_pad() --is1frame PREFERS crop FIRST.
end
mp.register_event('playback-restart',playback_restart)

function on_toggle(mute)  --TOGGLES BOTH crop & PADDING.
    start_timer = W and mute and not timers.mute:is_enabled()  --W IS LOADED SWITCH.
    if not W or start_timer and (timers.mute:resume() or true) then return end --return CONDITIONS.
    
    OFF,m.time_pos = not OFF,nil         --OFF SWITCH (FOR CROPS ONLY).  ~m.time_pos OVERRIDES TOLERANCE.
    crop = OFF and apply_crop({ x=0,y=0, w=max_w,h=max_h }) or is1frame and timers.auto_delay:resume() or detect_crop()  --is1frame MAY NEED TO BE ON TIMEOUT FOR RELIABILITY.
    on_toggle_pad() --THIS TOGGLE OPERATES 2 TOGGLES: LIKE 2 SCRIPTS IN 1.  BITE & STRETCH TECHNIQUE.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end

function on_toggle_pad()  --@playback-restart, @on_toggle & @file-loaded.  TOGGLES PADDING ONLY.  STRETCHES BLACK BARS WITHOUT CHANGING [vo] scale. VALID @FULLSCREEN.  A DIFFERENT VERSION COULD USE osd-dimensions (TRUE WINDOW SIZE).  IT'S UNNECESSARY TO SEPARATE apply_pad FROM on_toggle_pad (THIS function IS BOTH COMBINED).
    insta_unpause   = p.pause            and not is1frame and m.aspect and o.unpause_on_toggle>0  --IF PAUSED, UNLESS TRIGGERED ON playback-restart (~m.aspect).
    return_terminal = insta_unpause      and mp.get_property_bool('terminal') --terminal GAP REQUIRED BY SMPLAYER-v24.5 OR IT GLITCHES.
    aspect          = aspect==aspects.ON and aspects.OFF or aspects.ON   --→ON IF nil.
    m.aspect        = m.aspect or aspects.OFF --ASSUME OFF IF nil.  GRAPH RESETS AFTER playback-restart.  aspect IS TO PRESERVE PADDING STATE BTWN TRACKS (vid & PLAYLIST), BEFORE ASSUMING OFF.  
    pad_time        = mp.get_property_number('time-pos')+o.vf_command_t_delay
    pad_time        = pad_time-(m.pad_time and clip(toggle_duration-(pad_time-m.pad_time),0,toggle_duration) or 0)  --REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  LUA DOESN'T SUPPORT math.clip(#,min,max)=math.min(math.max(#,min),max)  THE MOST ELEGANT FORM IS TO clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.
    toggle_duration = p.pause            and 0 or o.toggle_duration
    toggle_expr     = toggle_duration==0 and 1 or ('clip((t-%s)/(%s),0,1)'):format(pad_time,toggle_duration)  --A DIFFERENT VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    toggle_expr     = o.toggle_expr:gsub('%%s',toggle_expr) --NON-LINEAR clip.  [0,1] DOMAIN & RANGE.  TIME EXPRESSION FOR SMOOTH-PADDING.  0,1 = INITIAL,FINAL
    
    m.pad_iw,pad_iw,m.pad_ih,pad_ih = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.
    Dpad_iw,Dpad_ih     = pad_iw-m.pad_iw,pad_ih-m.pad_ih --DIFFERENCE VALUES.  Δ INVALID ON mpv.app.
    m.aspect,m.pad_time = aspect,pad_time                 --MEMORY TRANSFER FOR RAPID TOGGLING.
    command             =  --pad EITHER HORIZONTALLY OR VERTICALLY.
        is1frame             and ('%s vf append @%s-scale-pad:scale=w=%d:h=%d;'                ):format(command_prefix,label,pad_iw,pad_ih               )  --insta_pause MAY BE MORE RELIABLE (apply_crop GOES FIRST).
        or                        ''
            ..(Dpad_iw~=0    and  '%s vf-command %s-scale-pad w round((%d+%d*(%s))/2)*2;' or ''):format(command_prefix,label,m.pad_iw,Dpad_iw,toggle_expr)  --CHECK COMMAND NEEDED, FIRST.  FORCE IF error_format (OLD FFMPEG).
            ..(Dpad_ih~=0    and  '%s vf-command %s-scale-pad h round((%d+%d*(%s))/2)*2;' or ''):format(command_prefix,label,m.pad_ih,Dpad_ih,toggle_expr)
            ..(insta_unpause and  '%s set terminal no;%s set pause no;'                   or ''):format(command_prefix,command_prefix                    )  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
    
    command       = command~=''   and mp.command(command)   --CAN BE BLANK WHEN PRESERVING OFF STATE.
    insta_unpause = insta_unpause and timers.pause:resume() --REPAUSE
end
for key in o.key_bindings_pad:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_pad_'..key,on_toggle_pad) end
timers.pause     = mp.add_periodic_timer(o.unpause_on_toggle  ,function()mp.command('set pause yes;'..(return_terminal and 'no-osd set terminal yes;' or ''))end)  --pause TIMER PAUSES, BUT MUST ALSO return_terminal.
for _,timer in pairs(timers) 
do timer.oneshot = true end  --mute command pause  ALL ONESHOTS.

function detect_crop()  --@timers.auto_delay, @playback-restart & @on_toggle
    timers.auto_delay:resume()  --~auto KEEPS CHECKING UNTIL apply_crop.
    if OFF or not max_w or p.seeking then return end  --seeking→~meta  AWAIT video-params OBSERVATION.
    
    command = o.meta_osd and mp.command(('show-text "'
                  ..'_VERSION       = %s               \n'  --Lua 5.1
                  ..'mpv-version    = ${mpv-version}   \n'  --mpv 0.38.0
                  ..'ffmpeg-version = ${ffmpeg-version}\n'  
                  ..'libass-version = ${libass-version}\n'  
                  ..'platform       = ${platform}      \n'  --windows
                  ..'current-vo     = ${current-vo}    \n'  --gpu direct3d
                  ..'osd-par        = ${osd-par}     \n\n'  --1
                  ..            '%s = \n${%s}"           '            
              ):format(_VERSION,meta_name,meta_name))
    
    meta,time_pos = mp.get_property_native(meta_name),mp.get_property_native('time-pos')  --Get the metadata.
    if not meta  --Verify the existence of metadata.
    then mp.msg.error("No crop metadata."                                    )
         mp.msg.info ("Was the cropdetect filter successfully inserted?"     )
         mp.msg.info ("Does your version of FFmpeg support AVFrame metadata?")
         return end 
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do meta[key] = tonumber(meta['lavfi.cropdetect.'..key] or meta['lavfi.bbox.'..key]) end  --tonumber(nil)=nil (BUT 0+nil RAISES ERROR).
    for key in ('w h x1 y1 x2 y2    '):gmatch('[^ ]+') 
    do if not meta[key] then mp.msg.error("Got empty crop data.") 
            return end end
    
    meta.x                  = meta.x or (meta.x1+meta.x2-meta.w)/2  --FOR bbox. IT GIVES x1 & x2 BUT NOT x. TAKE AVERAGE.
    meta.y                  = meta.y or (meta.y1+meta.y2-meta.h)/2
    if o.USE_INNER_RECTANGLE 
    then xNEW  ,yNEW        = math.max(meta.x1,meta.x2-meta.w,meta.x       ),math.max(meta.y1,meta.y2-meta.h,meta.y       )
        meta.x2,meta.y2     = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y      = xNEW,yNEW
        meta.w ,meta.h      = meta.x2-meta.x,meta.y2-meta.y end
    if MAINTAIN_CENTER[1] 
    then xNEW               = math.min( meta.x , max_w-(meta.x+meta.w) )  --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW               = max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*MAINTAIN_CENTER[1]  --SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
         then meta.x,meta.w = xNEW,wNEW end end
    if MAINTAIN_CENTER[2] 
    then yNEW               = math.min( meta.y , max_h-(meta.y+meta.h) )  --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW               = max_h-yNEW*2  --hNEW ALWAYS BIGGER THAN meta.h. 
         if hNEW-meta.h>hNEW*MAINTAIN_CENTER[2]  
         then meta.y,meta.h = yNEW,hNEW end end  
    min_w                   = min_w or max_w*detect_min_ratio  --RECOMPUTE IF NEEDED.
    min_h                   = min_h or max_h*detect_min_ratio
    if meta.w<min_w then if not o.USE_MIN_RATIO 
         then meta.w,meta.x = max_w,0  --NULL w
         else meta.w,meta.x = min_w,clip(meta.x-(min_w-meta.w)/2,0,max_w-min_w) end end  --MINIMIZE w & clip x.
    if meta.h<min_h then if not o.USE_MIN_RATIO                                                        
         then meta.h,meta.y = max_h,0  --NULL h                                                        
         else meta.h,meta.y = min_h,clip(meta.y-(min_h-meta.h)/2,0,max_h-min_h) end end  --MINIMIZE h & clip y.

    if meta.w>max_w or meta.h>max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return  --w<0 IS LIKE A JPEG ERROR.
    elseif not (m.w and m.h and m.x and m.y) 
    then m.w,m.h,m.x,m.y = max_w,max_h,0,0 end --INITIALIZE 0TH crop AT BEGINNING FOR INITIAL CHECK.
    is_effective         = (                                                                     --Verify if it is necessary to crop.
        (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y) and                          --REQUIRE CHANGE IN GEOMETRY.
        (not m.time_pos                                                                         --PROCEED IF INITIALIZING.
         or  math.abs(meta.w-m.w)>m.w*o.TOLERANCE[1] or math.abs(meta.h-m.h)>m.h*o.TOLERANCE[1] --PROCEED IF OUTSIDE TOLERANCE.
         or  math.abs(meta.x-m.x)>m.w*o.TOLERANCE[1] or math.abs(meta.y-m.y)>m.h*o.TOLERANCE[1]
         or  math.abs(time_pos-m.time_pos)>o.TOLERANCE.time+0)                                  --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.
    ) and apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop)
for _,timer in pairs(timers) do timer:kill() end

function apply_crop(meta)  --@detect_crop
    command   = 
                is1frame and (         '' --is1frame OVERRIDE
                    ..(p.pause     and '' or '%s set pause yes;'          ):format(command_prefix             )  --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
                    ..(                      '%s vf  pre @%s-crop:crop=w=%d:h=%d:x=%d:y=%d:keep_aspect=1:exact=1;'):format(command_prefix,label,meta.w,meta.h,meta.x,meta.y)
                    ..(p.pause     and '' or '%s set pause no ;'          ):format(command_prefix             )
                ) or                   ''  --NORMAL VIDEO.
                    ..(m.w==meta.w and '' or '%s vf-command %s-crop w %d;'):format(command_prefix,label,meta.w)  --w=out_w=width  EXCESSIVE vf-command CAUSES LAG.  SPELLING OUT ALL COORDINATES MAY HELP.
                    ..(m.h==meta.h and '' or '%s vf-command %s-crop h %d;'):format(command_prefix,label,meta.h)
                    ..(m.x==meta.x and '' or '%s vf-command %s-crop x %d;'):format(command_prefix,label,meta.x)
                    ..(m.y==meta.y and '' or '%s vf-command %s-crop y %d;'):format(command_prefix,label,meta.y)
    command   = command~='' and mp.command(command)   --CAN BE BLANK IF INEFFECTIVE.
    kill_auto = not auto and timers.auto_delay:kill() --NO FURTHER DETECTIONS.
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,time_pos  --meta→m  MEMORY TRANSFER. 
end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----A FUTURE VERSION MIGHT CROP WITHOUT CHANGING ASPECT (~EQUIVALENT TO AUTO-ZOOM). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT.
----SCRIPT PROBABLY TOO LONG. IT'S LIKE 2.5 SCRIPTS IN 1 (autocrop, autopad & start/end PLAYLIST MANAGER).

----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

