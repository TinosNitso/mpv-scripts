----NO-WORD-WRAP FOR THIS SCRIPT.  FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits.  .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----DOUBLE-mute TOGGLES BOTH crop & PADDING, ON SMARTPHONE TOO. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS.  IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask.lua TOO. IT ALWAYS MAINTAINS PERFECT ASPECT (NO SCALING).

options                    = { 
    auto                   = true ,  --IF REMOVED, CROPS OCCUR ONLY @on_toggle & @playback-restart (BUT ~@UNPAUSE). 
    auto_delay             =   .5 ,  --ORIGINALLY 4 SECONDS.  
    detect_limit           =  '24',  --ORIGINALLY "24/255".  INTEGER FOR bbox.  SET TO 0 FOR NO CROPPING.  CAN INCREASE FOR VARIOUS TRACKS.
    detect_round           =    1 ,  --ORIGINALLY 2.  DEFAULT=16.
    detect_min_ratio       =  .25 ,  --ORIGINALLY 0.5.
    suppress_osd           = true ,  --ORIGINALLY false.
    key_bindings           = 'C     TAB',  --DEFAULT='C'. CASE SENSITIVE. THESE DON'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO start & end LIMITS.  
    key_bindings_pad       = 'Shift+TAB',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout    =     .5  ,  --SECONDS FOR DOUBLE-MUTE-TOGGLE        (m&m DOUBLE-TAP).  SET TO 0 TO DISABLE.                    IDEAL FOR SMPLAYER.      REQUIRES AUDIO IN SMPLAYER.  VARIOUS SCRIPT/S CAN BE SIMULTANEOUSLY TOGGLED USING THESE 3 MECHANISMS.  TRIPLE-MUTE DOUBLES BACK.  
    double_aid_timeout     =     .5  ,  --SECONDS FOR DOUBLE-AUDIO-ID-TOGGLE    (#&# DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  ANDROID MUTES USING aid. REQUIRES AUDIO. 
    double_sid_timeout     =     .5  ,  --SECONDS FOR DOUBLE-SUBTITLE-ID-TOGGLE (j&j DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  IDEAL FOR SMARTPHONE.    REQUIRES sid.  SHOULDN'T INTERRUPT PLAYBACK OR AUDIO.  
    unpause_on_toggle      =     .12 ,  --SECONDS TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.      SET TO 0 TO DISABLE.  A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.  is1frame IRRELEVANT.
    toggle_t_delay         =     .12 ,  --SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  IT TAKES NEARLY AS LONG AS MESSAGING THE OPPOSITE SIDE OF THE EARTH!  BACKWARDS-seeking ADDS .5s.
    toggle_duration        =     .4  ,  --SECONDS TO STRETCH PADDING. SET TO 0 FOR INSTA-TOGGLE.  MEASURED IN time-pos.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  SMPLAYER.APP CAN GIVE MPV ITS OWN WINDOW (window-id=nil).  COULD BE RENAMED vf_command_t_delay.  
    toggle_expr            = '(expr)',  --(expr)=LINEAR-IN-TIME-EXPRESSION  DOMAIN & RANGE BOTH [0,1].  FOR CUSTOMIZED TRANSITION BTWN aspect RATIOS.  EXAMPLE='(1-cos(PI*(expr)))/2', FOR NON-LINEAR SINUSOIDAL TRANSITION (HALF-WAVE). THIS RUBBER-BAND EFFECT WORKS BETTER WITH TRUE SMOOTH-CROPPING.  A SINE WAVE IS 57% FASTER @MAX-SPEED (PI/2=1.57), SO .5s DURATION INSTEAD OF .3s. 
    toggle_command         = 'show-text ${media-title}',  --EXECUTES on_toggle, UNLESS BLANK.  CAN DISPLAY ${vf} ${lavfi-complex} ${video-out-params}. 'show-text ""' CLEARS THE OSD.  
    detector               = 'cropdetect=limit=%s:round=%s:reset=1',  --%s:%s=detect_limit:detect_round.  reset>0.  SETS TO 'bbox=%s' FOR JPEG & alpha.
    detect_min_ratio_image =            .1 ,  --OVERRIDE FOR JPEG.
    TOLERANCE              = {.05,time=10} ,  --INSTANTANEOUS TOLERANCE.  {0} DEACTIVATES THIS.  5% BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS. A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    keep_center            =         {0,0} ,  --{TOLERANCE_X,TOLERANCE_Y}.  {} TO MOVE FREELY.  {0,0} MEANS NEVER MOVE (LIKE CROSSHAIRS).  DOESN'T APPLY TO JPEG.  A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE    =          true ,  --AGGRESSIVE CROPPING. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE COMPUTATION.  MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    apply_min_ratio        =         false ,  --SET TO true TO crop ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.  false NULLIFIES is_excessive.
    show_text              =         false ,  --SET TO true TO INSPECT VERSIONS, DETECTOR METADATA, ETC.  ALSO WHEN TOGGLED OFF.  DISPLAYS  media-title _VERSION mpv-version ffmpeg-version libass-version platform current-ao,current-vo video-params/alpha osd-width,osd-height pad_iw,pad_ih pad_ow,pad_oh max_w,max_h min_w,min_h w:h:x:y vf-metadata/autocrop.
    msg_level              =       'fatal' ,  --{no,fatal,error,warn,info}  TYPOS ARE OFTEN fatal.
    pad_scale_flags        =    'bilinear' ,  --DEFAULT bicubic ('').  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  BUT THIS IS FOR THE PADDING DOWN-SCALER.  
    pad_options            = 'x=(ow-iw)/2:y=(oh-ih)/2:color=BLACK@1',  --CAN SET color=WHITE FOR WHITE SMARTPHONE.  y=0 PADS ONLY THE BOTTOM.  BLACK@0 FOR TRANSPARENCY.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY & PINK ARE ALSO NICE. 
    osd_par_multiplier     =       1       ,  --DISPLAY-PAR=osd-par*osd_par_multiplier  osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO  CAN MEASURE display TO DETERMINE ITS TRUE par.  video-out-params/par ACTUALLY MEANS VIDEO-IN-2DISPLAY (par OF ORIGINAL FILM)!  THE pad-TOGGLE USES THIS OVERRIDE ON EXOTIC DISPLAYS.
    video_out_params       =  {par=1,w,h,pixelformat},  --OVERRIDES, {number/string}.  DEFAULT par=1.  SET {par=1,pixelformat='yuva420p'} FOR TRANSPARENT PADDING.  THIS SCRIPT OVERRIDES FILM par USING ITS OWN MATH.  DEFAULT w=display-width.  BUT THAT'S nil FOR LINUX SMPLAYER (CAN SET {par=1,w=1680,h=1050}).  OVERRIDING par USES MORE CPU BY COMPUTING MORE MEGAPIXEL/S.  THE SOURCE STREAM par/sar COULD ALSO BE VARIABLE!
    options                =  {
        'keepaspect    no','keepaspect-window   no ','geometry 50%          ',  --keepaspect=no FOR ANDROID. keepaspect-window=no FOR MPV.APP.  FREE-SIZE IF MPV HAS ITS OWN WINDOW.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
        'osd-font-size 16','osd-bold            yes','osd-font "COURIER NEW"',  --DEFAULTS=55,no,sans-serif  55p MAY NOT FIT osd.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS PROPRIETARY & INVALID ON MACOS.
        'sub           no','sub-create-cc-track yes',  --DEFAULTS=auto,no.  SUBTITLE CLOSED-CAPTIONS CREATE BLANK TRACK FOR double_sid_timeout (BEST TOGGLE).  JPEG VALID.  UNFORTUNATELY YOUTUBE USUALLY BUGS OUT UNLESS sub=no.  sid=1 LATER @playback-restart.  YOUTUBE cc TAKE TIME TO SHUFFLE.
        'hwdec         no',  --DEFAULT=no.  HARDWARE-DECODER MAY PERFORM BADLY, & BUGS OUT ON ANDROID.
    },
    windows      = {}, linux = {}, darwin = {},  --OPTIONAL: platform OVERRIDES.
    android      = {  
        options  = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',}, --options APPEND, NOT REPLACE.
    },
    limits       = { nil
    ----,["path/media-title SUBSTRING"]={start,end,detect_limit}={SECONDS,SECONDS,string/number} (OR nil).  NOT CASE SENSITIVE.  detect_limit IS FINAL OVERRIDE.  start & end MAY ALSO BE PERCENTAGES.  MATCHES ON FIRST find.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS.  STARTING & ENDING CREDITS ARE SIMPLER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
        ,["Honest Trailers | "]={detect_limit=30}
        ,["Megadeth Sweating Bullets Official Music Video"]={0,-5}
        ,[ "День Победы."]={4,-13}                         --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ,["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7} --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        
    },
}
o,p,m,timers = {},{},{},{} --o,p,m=options,PROPERTIES,MEMORY  timers={mute,aid,sid,playback_restart,pad,re_pause,auto_delay}  playback_restart BLOCKS THE PRIOR 3. 
meta,aspects = {},{}       --meta=METADATA FOR detect_crop.  aspects={ON,OFF,restart,osd,video} FOR PADDING.  ON, OFF & restart ARE RELATIVE VALUES.  

function  gp(property)  --ALSO @start-file, @file-loaded, @seek, @apply_pad, @apply_scale, @apply_crop & @detect_crop.  GET-PROPERTY.
    p       [property]=mp.get_property_native(property)  --mp=MEDIA-PLAYER
    return p[property]
end

function round(N,D)  --@file-loaded, @seek, @apply_pad & @apply_scale.  N & D ARE number/string/nil.   FFMPEG SUPPORTS round, BUT NOT LUA.  ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1).
    D = D or 1
    return N and math.floor(.5+N/D)*D  --round(N)=math.floor(.5+N)
end

function clip(N,min,max)  --@apply_scale.  N, min & max ARE number/nil.  FFMPEG SUPPORTS, clip BUT NOT LUA.
    return N and min and max and math.min(math.max(N,min),max)  --MIN MAX MIN MAX
end

p  .platform  = gp('platform') or os.getenv('OS') and 'windows' or 'linux' --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = {}                                                         --DEFAULT={}
for  opt,val in pairs(options) 
do o[opt]     = val end               --CLONE
require 'mp.options'.read_options(o)  --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.
for  opt,val in pairs(o)
do o[opt] = type(val)=='string' and type(options[opt])~='string' and loadstring('return '..val)() or val end  --NATIVE TYPECAST.  load INVALID ON MPV.APP.  NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  

for _,opt in pairs((o[p.platform] or {}).options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(o.options)                                                                   
do  command            = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command                = command and mp.command(command) 
for  opt,val in pairs(o[p.platform] or {})
do o[opt]              = val end               --platform OVERRIDE.
label                  = mp.get_script_name()  --autocrop
command_prefix         = o.suppress_osd and 'no-osd' or ''
o.video_out_params.par = o.video_out_params.par or 1 --DEFAULT=1  
gp('msg-level')[label] = o.msg_level                 --SILENCES mp.msg.  change-list INVALID (msg-level=table).
mp.set_property_native('msg-level',p['msg-level']) 
math.randomseed(os.time()+mp.get_time())    --UNIQUE EACH LOAD.  os.time()=INTEGER SECONDS FROM 1970.  mp.get_time()=μs IS MORE RANDOM THAN os.clock()=ms.  os.getenv('RANDOM')=nil

function file_loaded()  --ALSO @property_handler.  
    p['time-pos']     = round(gp('time-pos'),.001)                             --NEAREST MILLISECOND FOR JPEG start_time. 
    if not v                                                                    --ONCE ONLY PER FILE (ON_EVENT).  
    then title,limits = ( gp('path') .. '\n' .. gp('media-title') ):lower(),nil --NOT CASE SENSITIVE.  OFTEN media-title=path
        for key,o_limits in pairs(o.limits)
        do  limits    = limits        or title: find(key:lower(),1,1) and o_limits end  --1,1=init,plain  BREAKS ON FIRST find.  ESTABLISH limits.
        limits        = limits        or {}
        limits.start  = limits.start  or limits[1]
        set_end       = limits['end'] or limits[2] or set_end        and gp('end')~='none' and 'none' --none @playlist-next IF NEEDED.  TRACK-2 SHOULDN'T INHERIT end DUE TO PRIOR set_end.  set_end SIMPLER THAN TRIMMING TIMESTAMPS.  
        seek          = limits.start  and p['time-pos']<limits.start and limits.start                 --SIMPLER THAN set_start BECAUSE media-title UNKNOWN BEFORE file-loaded!
        command       = ''
                        ..(seek     and '   seek    %s absolute exact;' or ''):format(seek)  --ALSO FOR JPEG.
                        ..(set_end  and '%s set end %s;'                or ''):format(command_prefix,set_end) 
        command       = command~='' and mp.command(command) end
    v                 = gp('current-tracks/video') or {}                                           --{} FOR RAW AUDIO.
    if not (gp('width') and gp('height') or v.id) then mp.msg.warn("crop only works for videos.") --return CONDITIONS REQUIRE EITHER PARAMETERS OR track.  PARAMATERS OFTEN UNAVAILABLE, BUT SHOULD PROCEED WITHOUT STUTTER.  height=nil OCCURS RARELY UNDER EXCESSIVE LAG.  BELOW LOOKS LIKE A DIFFERENT function WHICH SHOULD BE SPLIT FROM file_loaded.
        return end
    
    gmatch                    = (gp('android-surface-size') or ''):gmatch('[^:x]+') 
    m['android-surface-size'] =   p['android-surface-size']  --'960x444'=SMARTN12-LANDSCAPE.  nil=WINDOWS.  display MAY MEAN SOMETHING ELSE TO A SMARTPHONE.  
    android_surface_size      = {w=gmatch(),h=gmatch()}                           
    W                         = o.video_out_params.w     or gp('display-width' ) or android_surface_size.w or p.width  or v['demux-w']  --number/string.  OVERRIDE  OR  display  OR  android  OR  PARAMETERS  OR  TRACK.  THE CROPPING SCALER WORKS BEST IF IT SCALES TO AN ABSOLUTE CANVAS, PERMANENTLY. REPLACING IT CAUSES GLITCHES, WITH PNG/JPEG, BUT NECESSARY FOR SMARTPHONE.  width=nil SOMETIMES @file-loaded, & MAY CONTINUOUSLY VARY DUE TO lavfi-complex, & MAY BE MUCH LARGER THAN display SINCE MEMORY IS CHEAP.
    H                         = o.video_out_params.h     or gp('display-height') or android_surface_size.h or p.height or v['demux-h']
    alpha                     = gp('video-params/alpha') or v.image              or not v.id  --MPV REQUIRES EXTRA ~.1s TO DETECT alpha, SO ASSUME FOR image & ~v.id.  IT'S BAD FOR FILM.
    limit                     = limits.detect_limit      or o.detect_limit
    loop                      = v.image      and gp('lavfi-complex')=='' -- ALSO FOR is1frame, FOR SIMPLICITY.
    is1frame                  = v.albumart   and  p['lavfi-complex']=='' -- CHANGES @vid.  MP4TAG IS CONSIDERED albumart.  REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. 
    auto                      = not is1frame and o.auto                  --~auto FOR is1frame, OR AUDIO GLITCHES.
    detect_min_ratio          = v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    keep_center               = loop         and {}                       or o.keep_center                            --RAW JPEG CAN MOVE CENTER. 
    detector                  = (alpha       and 'bbox=%s'                or o.detector):format(limit,o.detect_round) --bbox FOR alpha (& JPEG).
    insta_pause               = not p.pause  --10ms insta_pause IMPROVES JPEG RELIABILITY, & PREVENTS EMBEDDED MPV FROM SNAPPING.
    
    if not detect_format then gp('msg-level')  --detect_format=nil MEANS ONCE ONLY, EVER.  @file-loaded BECAUSE OLD FFMPEG BUGS OUT SOONER.
        mp.set_property('msg-level','all=no')  
        error_format      = not mp.command(('%s vf pre @%s-scale:lavfi-format    '):format(command_prefix,label))  --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  MPV OFTEN BUILT WITH v4.2→v6.1.  v4 REQUIRES SPECIFYING format.  command RETURNS true IF SUCCESSFUL.  MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  @%s-scale FOR SIMPLICITY.
        o.toggle_duration =     mp.command(('%s vf pre @%s-scale:lavfi-scale=h=oh'):format(command_prefix,label))  --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2. 
                                and 0 or o.toggle_duration                 --h=oh MEANS NO STRETCHING (STUPID SCALER). OLD FFMPEG FAILS TO REPORT SELF-REFERENTIALITY (FALSE NEGATIVE). 
        mp.set_property_native('msg-level',p['msg-level']) end             --REPORTS TYPOS BELOW.
    detect_format  = gp('current-vo')=='shm' and 'yuv420p' or error_format and (alpha and 'yuva420p' or 'yuv420p') or ''  --DETECTOR pixelformat  =  SHARED-MEMORY  OR  OLD-FFMPEG(alpha OR ~alpha)  OR  NULL-OP.  FORCING yuv420p OR yuva420p IS MORE RELIABLE. MPV.APP COMPATIBLE WITH TRANSPARENCY, BUT NOT SMPLAYER.APP.  
    remove_loop    = nil
    for _,vf in pairs(gp('vf'))   --CHECK FOR @loop. 
    do remove_loop = remove_loop or vf.label=='loop' end   
    
    
    mp.command((''
                ..(insta_pause and '   set pause  yes;'                                       or '')
                ..                 "%s vf  pre    @%s-scale:lavfi=[scale=%d:%d,setsar='%s'];" --setsar REQUIRED FOR SHARED-MEMORY PADDING.  SEPARATE GRAPH BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER. IN/OUT MUST BE "SET IN STONE", OR ELSE.  THIS LINE ESTABLISHES ITS ORDER & EXISTENCE.
                ..                 '%s vf  pre    @%s-crop:crop=keep_aspect=1:exact=1;'       --SEPARATE FOR RELIABILITY WITH alpha & OLD FFMPEG.  
                ..                 '%s vf  pre    @%s:lavfi=[format=%s,%s];'                  --cropdetect OR bbox  CAN BE BEFORE/AFTER @loop.
                ..(remove_loop and '%s vf  remove @loop;'                                     or ''):format(command_prefix)
                ..(       loop and '%s vf  pre    @loop:lavfi=[loop=-1:1,fps=start_time=%s];' or '')  
    ):format(command_prefix,label,W,H,o.video_out_params.par,command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,p['time-pos']))
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d=DECIMAL-INTEGER.  '%s' BLOCKS STRINGS FROM SPLITTING.  3 (OR 4) CHAINS + 2 FILTERS (FOR vf-command).
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                  IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = ...:start_time (SECONDS)  SETS STARTPTS FOR JPEG (--start).  JPEG SMOOTH PADDING.  USES CPU UNTIL USER PAUSES. 
    ----cropdetect = limit:round:reset         DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES.  reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip (DEFAULT=2) INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP.  alpha TRIGGERS BAD PERFORMANCE BUG.  SUPPORTS vf-command (limit).
    ----bbox       = min_val                   DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN COMBINE MULTIPLE DETECTORS IN 1 GRAPH.  SUPPORTS vf-command (min_val).
    ----crop       = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval        DEFAULT=iw:ih:bicubic:...:init  FFMPEG-v4.2 DOESN'T SUPPORT t-DEPENDENT SCALING.
    ----pad        = w:h:x:y:color             DEFAULT=0:0:0:0:BLACK  @apply_pad (BELOW)  0 MAY MEAN iw OR ih.  FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW TO COLOR IN.
    ----setsar     = sar                       DEFAULT=0  IS THE FINISH.  SAMPLE-ASPECT-RATIO=par  THIS ISN'T WHAT MPV-v0.38 CALLS sar! IT MAY BE RELATIVE (OR A MISNOMER).  FINALIZES OUTPUT DSIZE, OTHERWISE THE PIXELS CAN HAVE ANY SHAPE.  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS LIKE GRAPH-ARMOR).  THIS IS LIKE 2 SCRIPTS COMBINED, & setsar=1 IS REPEATED THE SAME WAY, FOR RELIABILITY. ALL OTHER SCRIPTS WORK FINE WITHOUT THIS!  THE 'sar' EXPRESSION COULD TECHNICALLY BE A MILE LONG...
    
    
    timers.pad:resume()  --PADDING LAST. 
end

function apply_pad   (pad_options,pad_scale_flags)  --@script-message, @timers.pad & @seek.  PADDING APPENDS AFTER OTHER SCRIPT/S.  ALL NUMBERS ARE NEEDED @file-loaded, TO PREVENT INITIAL STUTTER (SOME WRONG NUMBERS ARE OK).  FULL-SCREEN ASSUMED.  MPV REQUIRES EXTRA ~.1s TO DETECT osd-dimensions/aspect>0.
    pad_options     = pad_options                    or o.pad_options
    pad_scale_flags = pad_scale_flags                or o.pad_scale_flags
    v               = gp('current-tracks/video' )    or {}
    format          = o.video_out_params.pixelformat or detect_format --OVERRIDE  OR  DETECTOR.
    W2,H2           = round(W,2),round(H,2)                           --EVENS ONLY FOR PADDING. 
    aspects.ON      = W2/H2
    aspects.osd     = (gp('osd-dimensions/aspect') or 0)>0 and p['osd-dimensions/aspect'] or aspects.ON  --ASSUME FULL-SCREEN (osd=ON-STATE) IF NECESSARY.  osd-dimensions/aspect=0 @file-loaded, BUT >0 @seek.  MPV MAYBE HASN'T MEASURED ITS OWN WINDOW YET.
    aspects.video   = nil
                      or gp('video-params/aspect')                                                         --USUALLY nil.  DEPENDS ON demux-par.
                      or gp('width')  and gp('height') and p.width/p.height                                --~width HAS MAYBE 10% CHANCE, DUE TO LAG + lavfi-complex.  ~height HAS MAYBE 1% CHANCE.
                      or v['demux-w'] and v['demux-h'] and v['demux-w']/v['demux-h']*(v['demux-par'] or 1) --demux-par=nil OFTEN.  nil FOR MP4TAG.
                      or aspects.ON                                                                        --SHOULDN'T TRIGGER (MAYBE 1 IN A MILLION).
    aspects.OFF     = aspects.video * aspects.ON / (aspects.osd * o.osd_par_multiplier)
    aspects.restart = is1frame and not OFF2 and aspects.ON or aspects.OFF                                --DEFAULT GRAPH STATE IS OFF (PADDED), UNLESS is1frame.  HOWEVER aspects.OFF MAY CHANGE DEPENDING ON WINDOW SIZE.  playback-restart MAY TRIGGER WITHOUT reload_pad.
    pad_iw,pad_ih   = round(math.min(W2,H2*aspects.restart),2),round(math.min(W2/aspects.restart,H2),2)  --pad INPUT-WIDTH,INPUT-HEIGHT.
    m.video_aspect,m.osd_aspect,m.aspect = aspects.video,aspects.osd,nil                                 --number,number,number  FOR @seek.

    
    mp.command((''
                ..              '%s vf  append @%s-pad-scale:scale=w=%d:h=%d:flags=%s:eval=frame;'                --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON.
                ..              "%s vf  append @%s-pad:lavfi=[format=%s,pad='%d:%d:%s',scale=%d:%d,setsar='%s'];" --FINAL scale ALMOST ALWAYS NULL-OP, UNLESS W OR H ODD (setsar=1). 
                ..(insta_pause and 'set pause  no ;' or '')
    ):format(command_prefix,label,pad_iw,pad_ih,pad_scale_flags,command_prefix,label,format,W2,H2,pad_options,W,H,o.video_out_params.par))


    insta_pause = nil
end 
timers.pad = mp.add_periodic_timer(.01,apply_pad)  --WITHOUT A TIMEOUT THERE'S LIKE A 5% CHANCE SOME OTHER SCRIPT FILTER FILTERS THE PADDING.

function on_toggle()  --@script-message, @script-binding, & @property_handler.  
    OFF,m.time_pos = not OFF,nil --OFF SWITCH (FOR CROPS ONLY).  m.time_pos→nil OVERRIDES TOLERANCE.
    detect_crop()                --DOES NOTHING IF OFF.
    
    if OFF then meta.x,meta.y,meta.w,meta.h = 0,0,p.width,p.height  --NULL CROP.
        apply_crop(meta) end
    on_toggle_pad() --TOGGLE BOTH crop & PADDING.  LIKE 2 SCRIPTS IN 1: BITE & STRETCH MECHANISM.
    command = o.toggle_command~='' and mp.command(command_prefix..' '..o.toggle_command)
end

function re_pause()  --@TIMER & @cleanup.  AFTER insta_unpause ONLY.
    if not insta_unpause then return end
    mp.command('set pause yes;'..(return_terminal and command_prefix..' set terminal yes;' or ''))  --ALSO return_terminal.
    insta_unpause,return_terminal = nil
end
timers.re_pause = mp.add_periodic_timer(o.unpause_on_toggle,re_pause)  

function on_toggle_pad()   --@script-message, @script-binding & @on_toggle.
    timers.re_pause:kill() --THESE 5 LINES FOR RAPID-TOGGLING WHEN PAUSED.  RESET TIMER FOR NEW PAUSED TOGGLE.
    timers.re_pause:resume()
    insta_unpause   = (insta_unpause or p.pause and o.unpause_on_toggle>0 and not is1frame) --ALREADY insta_unpause OR IF PAUSED, UNLESS is1frame.  COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
                      and mp.command(command_prefix..' set terminal no;set pause no')
    return_terminal = return_terminal or p.terminal and insta_unpause  --terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING TABS AS QUICK AS TOUCH-TYPING. EXAMPLE: KEEP TAPPING M IN SMPLAYER, AS FAST AS POSSIBLE.
    OFF2            = not OFF2  --LOGIC STATE OF PADDING. FULL-SCREEN=~OFF2.  EXACT NUMBERS CHANGE WITH DIMENSIONS, @vid.  OFF2 ARGUABLY THE WRONG WAY AROUND. 
    apply_scale()
end

for key in o.key_bindings    : gmatch('[^ ]+') 
do binding_name = 'toggle_crop'..(binding_name and '_'..key or '')  --THE FIRST key, C, IS SPECIAL.  '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
    mp.add_key_binding(key,binding_name,on_toggle) end  
binding_name    = nil
for key in o.key_bindings_pad: gmatch('[^ ]+') 
do binding_name = 'toggle_pad' ..(binding_name and '_'..key or '')
    mp.add_key_binding(key,binding_name,on_toggle_pad) end  

function apply_scale(aspect)  --@script-message, @playback-restart, @property_handler, & @on_toggle_pad.  SIMPLER TO SEPARATE UTILITY FROM ITS TOGGLE.  COULD BE RENAMED apply_aspect.  STRETCHES BLACK BARS WITHOUT CHANGING vo DSIZE (DISPLAY SIZE). 
    if not      (W2 and aspects.video and gp('time-pos')) or p.seeking then return end                      --W2=nil DURING TIMEOUT DEPENDING ON BUILD.  aspects.video=nil DURING complex TRACK-CHANGES.  time-pos=nil @playback-restart PASSED end-file.
    aspects.OFF     =   aspects.OFF or aspects.video * aspects.ON / (aspects.osd * o.osd_par_multiplier) --TRUE ASPECT FORMULA.  IT'S JUST WHATEVER THE INPUT IS, MULTIPLIED BY RATIO OF STARTING TO OSD ASPECT, BECAUSE OF HOW THE GRAPHS ARE SET.  THERE ARE ALSO OTHER EXPLANATION/S.  REAL ASPECT OF EACH PIXEL (osd-par) IS ASSUMED TO BE ACCOUNTED FOR IN osd-dimensions/aspect. demux-par IS ACCOUNTED FOR IN video-params/aspect.
    aspect          =   aspect      or OFF2  and aspects.OFF or aspects.ON
    m.aspect        = m.aspect      or aspects.restart                                                               --INITIALIZE PRIOR aspect.
    pad_time        = p['time-pos']  + (toggle_t_delay or o.toggle_t_delay)                                --DELAY SOMETIMES SET ELSEWHERE, FOR SPECIAL CASE/S.
    pad_time        = pad_time-(m.pad_time and clip(toggle_duration-(pad_time-m.pad_time),0,toggle_duration) or 0) --RAPID TOGGLING CORRECTION, ASSUMES LINEARITY.  REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.
    toggle_duration = insta_unpause        and   0   or o.toggle_duration  --insta_unpause RESETS ITSELF TO nil.  seeking WHILST PAUSED COULD ALSO USE 0 VALUE.
    toggle_expr     = toggle_duration==0   and '(1)' or ('(clip((t-%s)/(%s),0,1))'):format(pad_time,toggle_duration) --[0,1] DOMAIN & RANGE.  0,1=INITIAL,FINAL  TIME EXPRESSION FOR SMOOTH-PADDING.  A DIFFERENT VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    toggle_expr     = o.toggle_expr: gsub('%(expr%)',toggle_expr)                                                    --() ARE MAGIC.
    
    m.pad_iw,pad_iw,m.pad_ih,pad_ih    = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.  STORING THEM PROPERLY IN MEMORY IS MORE CODE, SO DEDUCE FROM m.aspect.
    m.aspect,m.pad_time,toggle_t_delay = aspect,pad_time,nil --MEMORY TRANSFER FOR RAPID TOGGLING.
    Dpad_iw,Dpad_ih = pad_iw-m.pad_iw,pad_ih-m.pad_ih        --DIFFERENCE VALUES.  Δ INVALID ON MPV.APP.
    
    scale_w     = vf_observed or Dpad_iw~=0                  
    scale_h     = vf_observed or Dpad_ih~=0
    vf_observed = nil  
    command     = nil            
                  or is1frame   and ('%s vf append @%s-pad-scale:scale=w=%d:h=%d:flags=%s:eval=frame;'):format(command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags)  --MAINTAIN frame IN CASE OF SWITCH FROM MP4TAG TO MP4.
                  or ''
                     ..(scale_w and     'vf-command %s-pad-scale w round((%d+%d*(%s))/2)*2;' or ''):format(label,m.pad_iw,Dpad_iw,toggle_expr)  --CHECK COMMAND NEEDED, FIRST.  EVENS ONLY. 
                     ..(scale_h and     'vf-command %s-pad-scale h round((%d+%d*(%s))/2)*2;' or ''):format(label,m.pad_ih,Dpad_ih,toggle_expr)
    command     = command~=''   and mp.command(command)  --COULD BE BLANK WHEN PRESERVING OFF2 STATE.
end 

function apply_crop(meta)  --@script-message, @detect_crop & @on_toggle.
    meta         = type(meta)=='string' and loadstring('return '..meta)() or meta --NATIVE TYPECAST.
    for key in ('max_w max_h min_w min_h'):gmatch('[^ ]+')
    do meta[key] =  meta[key] or m[key]                end
    if not (meta.min_w and gp('time-pos')) then return end  --time-pos=nil PASSED end-file.  min_w@detect_crop.
    ---- meta.x  = ... FROM meta.w
    ---- meta.w  = ... FROM meta.x
    ---- meta.y  = ... FROM meta.h
    ---- meta.h  = ... FROM meta.y
    is_excessive = (meta.w<meta.min_w or meta.h<meta.min_h)
                   and (mp.msg.info('The area to be cropped is too large.'        ) or 1)
                   and (mp.msg.info('You might need to decrease detect_min_ratio.') or 1)
    
    if meta.w<meta.min_w then if o.apply_min_ratio 
         then meta.w,meta.x = meta.min_w,clip(meta.x-(meta.min_w-meta.w)/2,0,meta.max_w-meta.min_w) --MINIMIZE w & clip x.
         else meta.w,meta.x = m.w,m.x end end                                                       --NULLIFY
    if meta.h<meta.min_h then if o.apply_min_ratio
         then meta.h,meta.y = meta.min_h,clip(meta.y-(meta.min_h-meta.h)/2,0,meta.max_h-meta.min_h) --MINIMIZE h & clip y.
         else meta.h,meta.y = m.h,m.y end end                                                       --NULLIFY
    
    is_effective = (true --Verify if it is necessary to crop.
                    and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)             --REQUIRE CHANGE IN GEOMETRY.
                    and (nil
                         or not m.time_pos                                                     --PROCEED IF INITIALIZING.
                         or math.abs(meta.w-m.w)>wTOLERANCE or math.abs(meta.h-m.h)>hTOLERANCE --PROCEED IF OUTSIDE TOLERANCE.
                         or math.abs(meta.x-m.x)>wTOLERANCE or math.abs(meta.y-m.y)>hTOLERANCE
                         or math.abs(p['time-pos']-m.time_pos)>o.TOLERANCE.time+0              --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.
                   ))
    if not is_effective then return   end      --WITHIN TOLERANCE.
    
    command      = is1frame           and  ''  --is1frame OVERRIDE
                       ..(p.pause     and  '' or '   set pause yes;')  --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
                       ..(                       "%s vf  pre @%s-crop:lavfi=[crop='min(iw,%d):min(ih,%d):%d:%d:1:1'];"):format(command_prefix,label,meta.w,meta.h,meta.x,meta.y)  --lavfi ENABLES min EXPRESSION, WHICH SOLVES INSTA-ERROR @vid DUE TO DELAYED RELOAD (DIMENSIONS CHANGE).
                       ..(p.pause     and  '' or '   set pause no ;')
                   or                      ''  --NORMAL VIDEO.
                       ..(m.w==meta.w and  '' or 'vf-command %s-crop w %d;'):format(label,meta.w)  --w=out_w  EXCESSIVE vf-command CAUSES LAG.  
                       ..(m.h==meta.h and  '' or 'vf-command %s-crop h %d;'):format(label,meta.h)  --h=out_h 
                       ..(m.x==meta.x and  '' or 'vf-command %s-crop x %d;'):format(label,meta.x)
                       ..(m.y==meta.y and  '' or 'vf-command %s-crop y %d;'):format(label,meta.y)
    command      = command~=''        and mp.command(command)              --COULD BE BLANK @on_toggle.
    kill_auto    = not auto           and timers.auto_delay:kill()         --NO FURTHER DETECTIONS.
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,p['time-pos'] --number,number,number,number,number:  meta→m  MEMORY TRANSFER. 
    wTOLERANCE,hTOLERANCE = m.w*o.TOLERANCE[1],m.h*o.TOLERANCE[1]          --CHANGE @crop.
end

function detect_crop(show_text)  --@script-message, @timers.auto_delay, @playback-restart & @on_toggle.
    timers.auto_delay:resume()                                     --~auto KEEPS CHECKING UNTIL apply_crop.
    if not (W2 and p.width and p.height) or p.seeking then return  --W2 FOR show-text.  width=nil IF TOGGLING vo.  
    elseif not m.min_w 
    then       m.min_w,m.min_h = p.width*detect_min_ratio,p.height*detect_min_ratio end  --RESET @property_handler.
    m           .max_w,m.max_h = p.width                 ,p.height
    vf_metadata = gp('vf-metadata/'..label)                                  --Get the metadata.
    
    show_text = (show_text or o.show_text) and mp.command(('show-text      "'
                    ..'media-title           = ${media-title}             \n'  --ALSO metadata.
                    ..'_VERSION              = %s                         \n'  --Lua 5.1  5.2
                    ..'mpv-version           = ${mpv-version}             \n'  --mpv 0.38.0  →  0.34.0
                    ..'ffmpeg-version        = ${ffmpeg-version}          \n'  
                    ..'libass-version        = ${libass-version}          \n'  
                    ..'platform              = ${platform}                \n'  --nil  windows  linux  darwin     android     
                    ..'current-ao,current-vo = ${current-ao},${current-vo}\n'  --nil  wasapi   pulse  coreaudio  audiotrack  ,  gpu  gpu-next  direct3d  libmpv  shm
                    ..'video-params/alpha    = ${video-params/alpha}      \n'  --nil  straight
                    ..'osd-width,osd-height  = ${osd-width},${osd-height} \n'  --840,525
                    ..'   pad_iw,pad_ih      = %d,%d                      \n'  --1680,944
                    ..'   pad_ow,pad_oh      = %d,%d                      \n'  --1680,1050
                    ..'    max_w,max_h       = ${width},${height}         \n'  --1920,1080
                    ..'    min_w,min_h       = %d,%d                      \n'  --480,270
                    ..'        w:h:x:y       = %d:%d:%d:%d              \n\n'  --1396,1066,263,7
                    ..'vf-metadata/%s = \n${vf-metadata/%s}                "'            
                ):format(_VERSION,pad_iw,pad_ih,W2,H2,m.min_w,m.min_h,m.w,m.h,m.x,m.y,label,label))  --nil INVALID ON MPV.APP.
    if OFF then return 
    elseif not vf_metadata then mp.msg.error('No crop metadata.'           ) --Verify the existence of metadata.
        mp.msg.info('Was the cropdetect filter successfully inserted?'     )
        mp.msg.info('Does your version of FFmpeg support AVFrame metadata?') 
        return end  
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do meta[key] = tonumber(vf_metadata['lavfi.cropdetect.'..key] or vf_metadata['lavfi.bbox.'..key]) end  --tonumber(nil)=nil (BUT 0+nil RAISES ERROR).
    for key in ('w h x1 y1 x2 y2    '):gmatch('[^ ]+') 
    do if not meta[key] then mp.msg.error('Got empty crop data.')  --REQUIRE ALL KEYS EXCEPT x & y.
            return end end
    
    meta.x = meta.x or (meta.x1+meta.x2-meta.w)/2  --bbox GIVES x1 & x2 BUT NOT x. TAKE AVERAGE.  SAME FOR y.
    meta.y = meta.y or (meta.y1+meta.y2-meta.h)/2 
    
    if o.USE_INNER_RECTANGLE 
    then xNEW  ,yNEW    = math.max(meta.x1,meta.x2-meta.w,meta.x       ),math.max(meta.y1,meta.y2-meta.h,meta.y       )
        meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y  = xNEW,yNEW
        meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    if keep_center[1] 
    then xNEW = math.min( meta.x , p.width -(meta.x+meta.w) )                      --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW = p.width -xNEW*2                                                    --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*keep_center[1] then meta.x,meta.w = xNEW,wNEW end end --SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
    if keep_center[2] 
    then yNEW = math.min( meta.y , p.height-(meta.y+meta.h) ) --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW = p.height-yNEW*2                               --hNEW ALWAYS BIGGER THAN meta.h. 
         if hNEW-meta.h>hNEW*keep_center[2] then meta.y,meta.h = yNEW,hNEW end end  
    apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop) 

function    event_handler(event)
    event = event.event
    if      event=='start-file'  then mp.command(command_prefix..' vf pre @loop:loop=-1:1')  --INSTA-loop OF LEAD-FRAME IMPROVES JPEG RELIABILITY (HOOKS IN TIMESTAMPS).  video-latency-hacks ALSO RESOLVES THIS ISSUE.  DON'T insta_pause DURING YOUTUBE LOAD.
    elseif  event=='file-loaded' then file_loaded()   
    elseif  event=='end-file'    then v,W,W2,playback_restarted = nil  --CLEAR SWITCHES. 
    elseif  event=='seek'  --DETECT BACKWARDS-seek, & MAY REPLACE loop/pad, UNLESS is1frame.
    then seek_time         = auto and p['time-pos']                         --auto CHECKS time-pos.
        if is1frame or not gp('time-pos') then return end                   --time-pos=nil PASSED end-file.
        toggle_t_delay     = seek_time and p['time-pos']<seek_time-1 and .5 --DETECTS BACKWARDS-seek, WHICH REQUIRES t+.5s BY TRIAL & ERROR.  COULD ALSO BE MADE ANOTHER OPTION.  revert-seek SLOW & UNNECESSARY.
        loop               =      loop and    not is1frame           and mp.command(('%s vf pre @loop:lavfi=[loop=-1:1,fps=start_time=%s]'):format(command_prefix,round(p['time-pos'],.001)))  --JPEG PRECISE seeking: RESET STARTPTS.  PTS MAY GO NEGATIVE!  is1frame CAN SET OF A CYCLE.  A FUTURE VERSION MIGHT USE A DIFFERENT TECHNIQUE, LIKE NULL AUDIO STREAM.  ARGUABLY seek SHOULD playlist-next OR playlist-prev IN JPEG-PLAYLIST.
        replace_pad        =  not loop and W2 and p['video-params']  and not (m.osd_aspect==aspects.osd and m.video_aspect==aspects.video) and apply_pad() --W2=nil FOR RAW AUDIO.  video-params=nil IF TOGGLING vo.  IF WINDOW/video CHANGES SIZE, THE DOWN-SCALER SHOULD BE REPLACED, SINCE IT'S DEFAULT OFF STATE IS NOW DIFFERENT.  BUT loop MESSES UP TIMESTAMPS.  THERE'S A SPECIAL CASE WHERE THIS GETS IT WRONG: THE WINDOW RESIZES DURING seeking, BUT AFTER seek.
    else timers.playback_restart:resume()                    --UNBLOCKS DOUBLE-TAPS.
        if is1frame and playback_restarted then return end   --is1frame REPLACEMENTS CAN TRIGGER INFINITE CYCLE.  FILTERS' STATES ARE RESET, UNLESS is1frame. 
        m.time_pos,m.aspect,p.seeking = nil                  --FORCES vf-COMMANDS.
        m.w,m.h,m.x,m.y               = p.width,p.height,0,0 --restart MEMORY STATE.
        
        detect_crop()      --AFTER seeking.  STARTS timers.auto_delay.
        apply_scale()  end --IF PAUSED IT TAKES A FEW FRAMES TO TURN ON.
end 
for event in ('start-file file-loaded end-file seek playback-restart'):gmatch('[^ ]+') 
do mp.register_event(event,event_handler) end
timers.playback_restart = mp.add_periodic_timer(.01,function() playback_restarted=true end)  --playback-restart CAN TRIGGER BEFORE aid, BY LIKE 1ms, FOR albumart.

function property_handler(property,val)
    p[property] = val
    aspects.video,aspects.osd = (p['video-params'] or {}).aspect,p['osd-dimensions/aspect'] or 0  --video-params/aspect IS NEVER 0, BUT osd-dimensions/aspect CAN BE.  ON STATE IS CONSTANT.  
    meta.min_w,meta.min_h,aspects.OFF = nil     --FORCE RECOMPUTATIONS. 
    for key in ('mute aid sid'):gmatch('[^ ]+') --DOUBLE-TAPS.    W BLOCKS RAW AUDIO.
    do toggle   =      property==key and playback_restarted   and W     and  (not timers[key]:is_enabled() and (timers[key]:resume() or 1) or on_toggle()) end  --W2 BLOCKS RAW AUDIO.  TOGGLERS AWAIT playback_restarted.
    vf_observed =      property=='vf'                                                     --vf-command-OVERRIDE.  af/vf OFTEN RESET GRAPH STATES, BUT WITHOUT TRIGGERING playback-restart!
    rescale     = (    property=='osd-dimensions/aspect'      and OFF2                    --CHANGING WINDOW SIZE!  NEW aspects REQUIRED FIRST.  WHEN PAUSED MUST FRAME-STEP OR UNPAUSE.  UNFORTUNATELY is1frame AUDIO GLITCHES (MORE RIGOROUS ALTERNATIVE COULD USE A NEW TIMER).
                   or  property=='vf')                        and W2    and apply_scale() --2 RESCALE CONDITIONS!
    reload      = (nil  --6 RELOAD CONDITIONS: @android-surface-size, @fs, @current-vo, @image, @is1frame & @alpha.
                   or (property=='android-surface-size'  --RELOAD @fullscreen ROTATION.  LANDSCAPE/PORTRAIT.
                   or  property=='fs')                        and W     and p.fs        and p['android-surface-size']~=m['android-surface-size']  --window-maximized MEANS SOMETHING ELSE.
                   or  property=='current-vo'                 and not W and val~='null' and val and v               --RELOAD @NEW-vo, & ANDROID-RESTORE.  ANDROID NEEDS 3 LINES.  vo,v=gpu,nil IN STANDALONE MODE.
                   or  property=='current-tracks/video/image' and W     and val~= nil   and val ~=  v.image         --RELOAD IF SWITCHING BTWN MP4 & MP4TAG.  UNFORTUNATELY EMBEDDED MPV SNAPS.  albumart DISTINCTION IS IRRELEVANT.
                   or  property=='video-params'               and val   and (is1frame   or val.alpha and not alpha) --RELOAD @Δalbumart, OR TRY SWITCH TO TRANSPARENCY.  is1frame MUST BE RE-DRAWN.  TRANSPARENCY TAKES TIME TO DETECT.  SWITCHING BACK TO yuv420p UNNECESSARY.
    ) and file_loaded() 
end 
for property in ('current-tracks/video/image fs seeking pause terminal mute aid sid width height osd-dimensions/aspect android-surface-size current-vo video-params vf'):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS TABLES
do mp.observe_property(property,'native',property_handler) end  --TRIGGER AFTER load-script.

for          property in ('mute aid sid'):gmatch('[^ ]+')  --1SHOT NULL-OP DOUBLE-TAPS.  current-tracks/audio/selected(double_ao_timeout) & current-tracks/sub/selected(double_sub_timeout) ARE STRONGER ALT-CONDITIONS REQUIRING OFF/ON, AS OPPOSED TO ID#.  current-ao ALSO DOES WHAT current-tracks/audio/selected DOES, BUT SAFER @playlist-next.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  
do    timers[property]    = mp.add_periodic_timer(o[('double_%s_timeout'):format(property)],function()end) end
for _,timer in pairs(timers) 
do    timer.oneshot       = 1 --ALL 1SHOT EXCEPT auto_delay.
      timer:kill() end        --FOR OLD MPV. IT CAN'T START timers DISABLED.
timers.auto_delay.oneshot = false

function remove_filters() --@cleanup
    command    =  ''
    for label in ('%s %s-crop %s-scale %s-pad-scale %s-pad'):gsub('%%s',label):gmatch('[^ ]+')    --% IS MAGIC.  CHECK FIRST.  @loop MAY NOT BE REMOVED.
    do for _,vf in pairs(p.vf)
        do command = command..(vf.label==label and '%s vf remove @%s;' or ''):format(command_prefix,label) end end
    command        = command~='' and mp.command(command)
end

function cleanup() --@script-message.  ENABLES SCRIPT-RELOAD WITH NEW script-opts.
    re_pause()     --IF insta_unpause.
    remove_filters()
    remove_end      = set_end and mp.command(command_prefix..' set end none;') 
    mp.keep_running = false  --false FLAG EXIT: COMBINES remove_key_binding, unregister_event, unregister_script_message, unobserve_property & timers.*:kill().
end 
for message,fn in pairs({cleanup=cleanup,toggle=on_toggle,toggle_pad=on_toggle_pad,detect_crop=detect_crop,apply_crop=apply_crop,apply_pad=apply_pad,apply_aspect=apply_scale})  --SCRIPT CONTROLS.
do mp.register_script_message(message,fn) end

----CONSOLE/GUI COMMAND EXAMPLES:
----script-binding             toggle_crop
----script-binding             toggle_pad
----script-message-to autocrop toggle
----script-message             toggle_pad
----script-message-to autocrop cleanup
----script-message             detect_crop  <show_text>
----script-message             apply_pad    <pad_options>                        <pad_scale_flags>
----script-message             apply_pad     x=(ow-iw)/2:y=(oh-ih)/2:color=WHITE  bicubic
----script-message             apply_aspect <aspect>
----script-message             apply_aspect  2
----script-message             apply_crop   <meta>
----script-message             apply_crop   {w=1920,h=1080*math.random(),x=0,y=0}

----APP VERSIONS:
----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED. 
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS:  windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  WON'T OPEN JPEG ON ANDROID.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.


----~400 LINES & ~6000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END (CONSOLE COMMANDS). ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----FUTURE VERSION SHOULD MOVE o.double_mute_timeout, o.double_aid_timeout, o.double_sid_timeout & o.toggle_command TO main.lua. ALL SCRIPTS SHOULD HAVE THESE, UNLESS main OPERATES ALL DOUBLE-TAPS.
----FUTURE VERSION SHOULD RESPOND TO CHANGING script-opts; function on_update.
----FUTURE VERSION SHOULD OPERATE 1fps EITHER AS is1frame MODE, OR SET MINIMUM fps=10; FOR FRAME-BY-FRAME GIFs.  vf-command DOESN'T REDRAW CURRENT FRAME.  BUT AUDIO COULD GLITCH.  THERE'S AT LEAST 3 WAYS OF CROPPING, INCLUDING video-crop.
----FUTURE VERSION SHOULD BE CAPABLE OF SMOOTH-CROPPING BY REPLACING BLACK BARS WITH BLACK PADS, & THEN SMOOTH-UNPAD. BECAUSE SMOOTH-PADDING IS EASY.  EFFICIENT TRUE SMOOTH-crop IS IMPOSSIBLE WITH FFMPEG-v6.
----FUTURE VERSION SHOULD HAVE o.keep_aspect, TO MAINTAIN TRUE ASPECT @ALL TIMES.
----FUTURE VERSION MIGHT BREAK UP file_loaded.  MAYBE IT SHOULD ONLY ESTABLISH limits.

----COULD BE RENAMED autocrop-mod.lua.  MY LONGEST SCRIPT - LIKE 2.5 SCRIPTS IN 1 (autocrop, autopad & start/end PLAYLIST MANAGER).  A CROP IS A PAD-REMOVAL, SO THE FULL COMBO IS MORE INTUITIVE!
----     BUG: STUTTERS @file-loaded, WHEN COMBINED WITH automask.lua.
----RARE BUG: JPEG FAILS TO SCALE.

----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0   UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split        CLONES video. UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

