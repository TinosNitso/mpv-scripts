----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits.  .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----DOUBLE-mute TOGGLES BOTH crop & PADDING, ON SMARTPHONE TOO. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask.lua TOO. IT ALWAYS MAINTAINS PERFECT ASPECT (NO SCALING).
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.  IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.

options                    = { 
    auto                   = true ,  --IF REMOVED, CROPS OCCUR ONLY @on_toggle & @playback-restart (BUT ~@UNPAUSE). 
    auto_delay             =   .5 ,  --ORIGINALLY 4 SECONDS.  
    detect_limit           =  '24',  --ORIGINALLY "24/255".  INTEGER FOR bbox (ALT-DETECTOR).  SET TO 0 FOR NO CROPPING.  CAN INCREASE FOR VARIOUS TRACKS.
    detect_round           =    1 ,  --ORIGINALLY 2.  DEFAULT=16.
    detect_min_ratio       =  .25 ,  --ORIGINALLY 0.5.
    suppress_osd           = true ,  --ORIGINALLY false.
    key_bindings           = 'C     TAB',  --DEFAULT='C'. CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER.  TOGGLE DOESN'T APPLY TO start & end LIMITS.  
    key_bindings_pad       = 'Shift+TAB',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout    =        .5  ,  --SECONDS FOR DOUBLE-MUTE-TOGGLE        (m&m DOUBLE-TAP).  SET TO 0 TO DISABLE.  BEST SMPLAYER TOGGLE.    REQUIRES AUDIO IN SMPLAYER.  VARIOUS SCRIPT/S CAN BE SIMULTANEOUSLY TOGGLED USING THESE 3 MECHANISMS.  TRIPLE-MUTE DOUBLES BACK.  
    double_aid_timeout     =        .5  ,  --SECONDS FOR DOUBLE-AUDIO-ID-TOGGLE    (#&# DOUBLE-TAP).  SET TO 0 TO DISABLE.  ANDROID MUTES USING aid. REQUIRES AUDIO. 
    double_sid_timeout     =        .5  ,  --SECONDS FOR DOUBLE-SUBTITLE-ID-TOGGLE (j&j DOUBLE-TAP).  SET TO 0 TO DISABLE.  BEST SMARTPHONE TOGGLE.  NEVER INTERRUPTS PLAYBACK OR AUDIO.  REQUIRES sid.
    toggle_duration        =        .5  ,  --SECONDS TO TOGGLE PADDING. 0 FOR INSTA-TOGGLE.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  SMPLAYER.APP CAN GIVE MPV ITS OWN WINDOW, OR ELSE window-id=nil (SO NO SIZING).  
    unpause_on_toggle      =        .12 ,  --SECONDS TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.      SET TO 0 TO DISABLE.  A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.  is1frame IRRELEVANT. 
    vf_command_t_delay     =        .12 ,  --SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  IT TAKES NEARLY AS LONG AS SENDING MESSAGES TO THE OPPOSITE SIDE OF THE EARTH!  BACKWARDS-seeking ADDS .5s.
    toggle_command         =         '' ,  --EXECUTES on_toggle, UNLESS BLANK.  'show-text ""' CLEARS THE OSD.  CAN DISPLAY ${vf} ${lavfi-complex} ${video-out-params}.
    toggle_expr            =   '(expr)' ,  --(expr)=LINEAR-IN-TIME-EXPRESSION  DOMAIN & RANGE BOTH [0,1].  FOR CUSTOMIZED TRANSITION BTWN aspect RATIOS.  EXAMPLE='(1-cos(PI*%s))/2', FOR NON-LINEAR SINUSOIDAL TRANSITION (HALF-WAVE).  A SINE WAVE IS 57% FASTER @MAX-SPEED (PI/2=1.57), HENCE TOO FAST.
    detector               = 'cropdetect=limit=%s:round=%s:reset=1',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1'  %s:%s=detect_limit:detect_round  reset>0.  SETS TO 'bbox=%s' FOR JPEG & alpha.
    detect_min_ratio_image =            .1 ,  --OVERRIDE FOR JPEG.
    TOLERANCE              = {.05,time=10} ,  --INSTANTANEOUS TOLERANCE.  {0} DEACTIVATES THIS.  5% BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS. A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    keep_center            =         {0,0} ,  --{TOLERANCE_X,TOLERANCE_Y}.  {} TO MOVE FREELY.  {0,0} MEANS NEVER MOVE (LIKE CROSSHAIRS).  DOESN'T APPLY TO JPEG.  A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE    =          true ,  --AGGRESSIVE CROPPING. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE COMPUTATION.  MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    apply_min_ratio        =         false ,  --true TO crop ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.  false NULLIFIES is_excessive.
    meta_osd               =         false ,  --true TO INSPECT VERSIONS, DETECTOR METADATA, ETC.  ALSO WHEN TOGGLED OFF.  DISPLAYS  media-title _VERSION mpv-version ffmpeg-version libass-version platform current-ao,current-vo video-params/alpha osd-width,osd-height pad_iw,pad_ih pad_ow,pad_oh max_w,max_h min_w,min_h w,h x,y vf-metadata/autocrop.
    pad_scale_flags        =    'bilinear' ,  --DEFAULT bicubic ('').  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  BUT THIS IS FOR THE PADDING DOWN-SCALER.  
    pad_color              =            '' ,  --DEFAULT BLACK   ('').  'BLACK@0'  FOR TRANSPARENCY.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY, PINK & WHITE ARE ALSO NICE.  THIS COULD BE REPLACED WITH EXTRA x:y OPTIONS, LIKE WHETHER TO pad FROM THE CENTER OR TOP.
    osd_par_multiplier     =       1       ,  --DISPLAY-PAR=osd-par*osd_par_multiplier  osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO  CAN MEASURE display TO DETERMINE ITS TRUE par.  video-out-params/par ACTUALLY MEANS VIDEO-IN-2DISPLAY (par OF ORIGINAL FILM)!  THE pad-TOGGLE USES THIS OVERRIDE ON EXOTIC DISPLAYS.
    video_out_params       =  {par=1,w,h,pixelformat},  --OVERRIDES.  DEFAULT par=1.  USE {par=1,pixelformat='yuva420p'} FOR TRANSPARENT PADDING.  THIS SCRIPT OVERRIDES FILM par USING ITS OWN MATH.  DEFAULT w=display-width  BUT THAT'S nil FOR LINUX SMPLAYER. THEN CAN SET {par=1,w=1680,h=1050}.  OVERRIDING par USES MORE CPU BY FAKING MEGAPIXELS. THE SOURCE STREAM par/sar COULD ALSO BE VARIABLE!
    options                =  {
        'msg-level     ffmpeg/demuxer=error,autocrop=fatal                  ',  --{no,fatal,error,warn,info}  TYPOS ARE OFTEN fatal.  USE script_name HERE.  OVERRIDES SMPLAYER, FOR SIMPLICITY.
        'keepaspect    no','keepaspect-window   no ','geometry 50%          ',  --keepaspect=no FOR ANDROID. keepaspect-window=no FOR MPV.APP.  FREE-SIZE IF MPV HAS ITS OWN WINDOW.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
        'osd-font-size 16','osd-bold            yes','osd-font "COURIER NEW"',  --DEFAULTS=55,no,sans-serif  55p MAY NOT FIT osd.  COURIER NEW NEEDS bold (FANCY).  CONSOLAS PROPRIETARY & INVALID ON MACOS.
        'sub           no','sub-create-cc-track yes',  --DEFAULTS=auto,no.  SUBTITLE CLOSED-CAPTIONS CREATE BLANK TRACK FOR double_sid_timeout (BEST TOGGLE).  JPEG VALID.  UNFORTUNATELY YOUTUBE USUALLY BUGS OUT UNLESS sub=no.  sid=1 LATER @playback-restart.  YOUTUBE cc TAKE TIME TO SHUFFLE.
        'hwdec         no',  --DEFAULT=no.  HARDWARE-DECODER MAY PERFORM BADLY, & BUGS OUT ON ANDROID.
    },
    windows               = {}, linux = {}, darwin = {},  --platform OVERRIDES.
    android               = {  
        unpause_on_toggle = .2, vf_command_t_delay = .2,                                    --MORE LAG.
        options           = {'osd-fonts-dir /system/fonts/','osd-font "DROID SANS MONO"',}, --options ARE SPECIAL & APPEND, NOT REPLACE.
    },
    limits                = {nil  --NOT CASE SENSITIVE.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS.  STARTING & ENDING CREDITS ARE SIMPLER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ----,["path-substring"]={start,end,detect_limit}={SECONDS,SECONDS,string/number} (OR nil).  detect_limit IS FINAL OVERRIDE.  start & end MAY ALSO BE PERCENTAGES.  CAN ALSO USE END OF YOUTUBE URL.  MATCHES ON FIRST find.  ARGUABLY A COMMA SHOULD LEAD EACH LINE.
        ,["We are army of people - Red Army Choir"]={detect_limit=50}
        ,[  "День Победы."]={4,-13}                        --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ,["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7} --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        ,["Megadeth Sweating Bullets Official Music Video"]={0,-5}
        
    },
}
o,p,m,timers = {},{},{},{} --o,p,m=options,PROPERTIES,MEMORY  timers={mute,aid,sid,playback_restart,pad,re_pause,auto_delay}  playback_restart BLOCKS THE PRIOR 3.
meta,aspects = {},{}       --meta=METADATA FOR detect_crop.  aspects={ON,OFF,restart,osd,video} FOR PADDING.  ON, OFF & restart ARE RELATIVE VALUES.  

function  gp(property)  --ALSO @start-file, @file-loaded, @seek, @apply_pad, @apply_scale, @apply_crop & @detect_crop.  GET PROPERTY.
    p       [property]=mp.get_property_native(property)  --mp=MEDIA-PLAYER
    return p[property]
end

function round(N,D)  --@file-loaded, @seek, @apply_pad & @apply_scale.  N & D ARE number/string/nil.   FFMPEG SUPPORTS round, BUT NOT LUA.  ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1).
    D = D or 1
    return N and math.floor(.5+N/D)*D  --round(N)=math.floor(.5+N)
end

function clip(N,min,max)  --@apply_scale.  N, min & max ARE number/nil.  FFMPEG SUPPORTS clip BUT NOT LUA.
    return N and min and max and math.min(math.max(N,min),max)  --MIN MAX MIN MAX
end

for  opt,val in pairs(options)  --TYPES CLONE.
do o[opt] = val end 
require 'mp.options'.read_options(o)  --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.
for  opt,val in pairs(o)
do o[opt]     = type(val)~=type(options[opt]) and loadstring('return '..val)() or val end  --NATIVE TYPECAST.  load INVALID ON MPV.APP.  NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  
p  .platform  =  gp('platform') or os.getenv('OS') and 'windows' or 'linux'  --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = o[p. platform ] or {}  --DEFAULT={}

for _,opt in pairs((o[p.platform] or {}).options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(o.options)                                                                   
do  command            = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command                = command and mp.command(command) 
for  opt,val in pairs(o[p.platform] or {})  --platform OVERRIDE.
do o[opt]              = val end  
label                  = mp.get_script_name()  --autocrop
command_prefix         = o.suppress_osd and 'no-osd' or ''
o.video_out_params.par = o.video_out_params.par or 1 --DEFAULT=1  

function start_file() 
    p.path,limits      = gp('path'):lower(),nil  --NOT CASE SENSITIVE.  
    for key,o_limits in pairs(o.limits)
    do  limits         =  limits    or p.path: find(key:lower(),1,1) and o_limits end  --1,1=init,plain  BREAKS ON FIRST find.  ESTABLISH limits.
    limits             =  limits    or {}  --limits REQUIRED @file-loaded. 
    set_start          = (gp('start')=='none' or set_start) and (limits.start  or limits[1]) or p.start ~='none' and set_start and 'none'  --ONLY set_start IF none, OR IF set_start FROM LAST-TRACK.  set→none IF set_start OR ~limits.  TRACK-2 SHOULDN'T INHERIT limits.  start/end SIMPLER THAN seeking OR TRIMMING TIMESTAMPS.  
    set_end            = (gp('end'  )=='none' or set_end  ) and (limits['end'] or limits[2]) or p['end']~='none' and set_end   and 'none'  
    
    mp.command(''
               ..(set_start and '%s set start %s;'        or ''):format(command_prefix,set_start)
               ..(set_end   and '%s set end   %s;'        or ''):format(command_prefix,set_end  ) 
               ..(              '%s vf  pre   @loop:loop=-1:1;'):format(command_prefix          )  --INSTA-loop OF LEAD-FRAME IMPROVES JPEG RELIABILITY (HOOKS IN TIMESTAMPS).  video-latency-hacks ALSO RESOLVES THIS ISSUE.  DON'T insta_pause DURING YOUTUBE LOAD.
    )
end 
mp.register_event('start-file',start_file)
mp.register_event(  'end-file',function() v,W,W2,playback_restarted=nil end)  --CLEAR SWITCHES. 

function file_loaded()  --ALSO @property_handler.  
    v =     gp('current-tracks/video'  ) or {}                                                    --{} FOR RAW AUDIO.
    if not (gp('width') and gp('height') or v.id) then mp.msg.warn("crop only works for videos.") --return CONDITIONS REQUIRE EITHER PARAMETERS OR track.  PARAMATERS OFTEN UNAVAILABLE, BUT SHOULD PROCEED WITHOUT STUTTER.  height=nil OCCURS RARELY UNDER EXCESSIVE LAG.
        return end
    
    gmatch               = (p['android-surface-size'] or ''):gmatch('[^x]+') --OBSERVED IN ADVANCE.  '','960x444'=WINDOWS,SMARTN12-LANDSCAPE
    android_surface_size = {w=gmatch(),h=gmatch()}                           --W,H MAY BE STRINGS! 
    W                    = o.video_out_params.w     or gp('display-width' ) or android_surface_size.w or p.width  or v['demux-w']  --OVERRIDE  OR  display  OR  android  OR  PARAMETERS  OR  TRACK.  width=nil SOMETIMES @file-loaded.  display MAY MEAN SOMETHING ELSE TO A SMARTPHONE.  THE CROPPING SCALER WORKS BEST IF IT SCALES TO AN ABSOLUTE CANVAS, PERMANENTLY. REPLACING IT CAUSES GLITCHES, WITH PNG/JPEG, BUT NECESSARY FOR SMARTPHONE.  p.width MAY BE VARIABLE DUE TO lavfi-complex.
    H                    = o.video_out_params.h     or gp('display-height') or android_surface_size.h or p.height or v['demux-h']
    alpha                = gp('video-params/alpha') or v.image              or not v.id  --MPV REQUIRES EXTRA ~.1s TO DETECT alpha, SO ASSUME FOR image & ~v.id.  IT'S BAD FOR FILM.
    limit                = limits.detect_limit      or o.detect_limit
    loop                 = v.image      and gp('lavfi-complex')=='' -- ALSO FOR is1frame, FOR SIMPLICITY.
    is1frame             = v.albumart   and  p['lavfi-complex']=='' -- CHANGES @vid.  MP4TAG IS CONSIDERED albumart.  REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. 
    auto                 = not is1frame and o.auto                  --~auto FOR is1frame, OR AUDIO GLITCHES.
    detect_min_ratio     = v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    keep_center          = loop         and {}                       or o.keep_center                            --RAW JPEG CAN MOVE CENTER. 
    detector             = (alpha       and 'bbox=%s'                or o.detector):format(limit,o.detect_round) --bbox FOR alpha (& JPEG).
    p['time-pos']        = round(gp('time-pos'),.001)                                                            --start_time FOR JPEG, NEAREST MILLISECOND.  
    
    if not detect_format then gp('msg-level')  --detect_format=nil MEANS ONCE ONLY, EVER.  @file-loaded BECAUSE OLD FFMPEG BUGS OUT SOONER.
        mp.set_property('msg-level','all=no')  
        error_format      = not mp.command(('%s vf pre @%s-scale:lavfi-format    '):format(command_prefix,label))  --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  MPV OFTEN BUILT WITH v4.2→v6.1.  v4 REQUIRES SPECIFYING format.  command RETURNS true IF SUCCESSFUL.  MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  @%s-scale FOR SIMPLICITY.
        o.toggle_duration =     mp.command(('%s vf pre @%s-scale:lavfi-scale=h=oh'):format(command_prefix,label))  --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2. 
                                and 0 or o.toggle_duration                 --h=oh MEANS NO STRETCHING (STUPID SCALER). OLD FFMPEG FAILS TO REPORT SELF-REFERENTIALITY (FALSE NEGATIVE). 
        mp.set_property_native('msg-level',p['msg-level']) end             --REPORTS TYPOS BELOW.
    detect_format = gp('current-vo')=='shm' and 'yuv420p' or error_format and (alpha and 'yuva420p' or 'yuv420p') or ''  --DETECTOR pixelformat  =  SHARED-MEMORY  OR  OLD-FFMPEG(alpha OR ~alpha)  OR  NULL-OP.  FORCING yuv420p OR yuva420p IS MORE RELIABLE. MPV.APP COMPATIBLE WITH TRANSPARENCY, BUT NOT SMPLAYER.APP.  
    insta_pause,remove_loop = not p.pause,nil --10ms insta_pause IMPROVES JPEG RELIABILITY, & PREVENTS EMBEDDED MPV FROM SNAPPING.
    for _,vf in pairs(gp('vf'))               --CHECK FOR @loop.  FETCH vf LAST.
    do remove_loop = remove_loop or vf.label=='loop' end   
    
    
    mp.command((''
                ..(insta_pause and '   set pause  yes;'                                       or '')
                ..                 '%s vf  pre    @%s-scale:lavfi=[scale=%d:%d,setsar=%s];' --setsar REQUIRED FOR SHARED-MEMORY PADDING.  SEPARATE GRAPH BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER. IN OR OUT MUST BE "SET IN STONE".  THIS LINE ESTABLISHES ITS ORDER & EXISTENCE.
                ..                 '%s vf  pre    @%s-crop:crop=keep_aspect=1:exact=1;'     --SEPARATE FOR RELIABILITY WITH alpha & OLD FFMPEG.  
                ..                 '%s vf  pre    @%s:lavfi=[format=%s,%s];'                --cropdetect OR bbox  CAN BE BEFORE/AFTER @loop.
                ..(remove_loop and '%s vf  remove @loop;'                                     or ''):format(command_prefix)
                ..(       loop and '%s vf  pre    @loop:lavfi=[loop=-1:1,fps=start_time=%s];' or '')  
    ):format(command_prefix,label,W,H,o.video_out_params.par,command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,p['time-pos']))
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d,%s = DECIMAL_INTEGER,string.  3 (OR 4) CHAINS + 2 FILTERS (FOR vf-command).
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                  IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = ...:start_time (SECONDS)  SETS STARTPTS FOR JPEG (--start).  JPEG SMOOTH PADDING.  USES CPU UNTIL USER PAUSES. 
    ----cropdetect = limit:round:reset         DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES.  reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip (DEFAULT=2) INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP.  alpha TRIGGERS BAD PERFORMANCE BUG.  SUPPORTS vf-command (limit).
    ----bbox       = min_val                   DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN COMBINE MULTIPLE DETECTORS IN 1 GRAPH.  SUPPORTS vf-command (min_val).
    ----crop       = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval        DEFAULT=iw:ih:bicubic:...:init  FFMPEG-v4.2 DOESN'T SUPPORT t-DEPENDENT SCALING.
    ----pad        = w:h:x:y:color             DEFAULT=0:0:0:0:BLACK  @apply_pad (BELOW)  0 MAY MEAN iw OR ih.  FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW TO COLOR IN.
    ----setsar     = sar                       DEFAULT=0  IS THE FINISH.  SAMPLE-ASPECT-RATIO=par  THIS ISN'T WHAT MPV-v0.38 CALLS sar! IT MAY BE RELATIVE (OR A MISNOMER).  FINALIZES OUTPUT DSIZE, OTHERWISE THE PIXELS CAN HAVE ANY SHAPE.  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS LIKE GRAPH-ARMOR).  THIS IS LIKE 2 SCRIPTS COMBINED, & setsar=1 IS REPEATED THE SAME WAY, FOR RELIABILITY. ALL OTHER SCRIPTS WORK FINE WITHOUT THIS!
    
    
    timers.pad:resume()  --PADDING LAST. 
end
mp.register_event('file-loaded',file_loaded)

function apply_pad()  --@timers.pad & @seek.  PADDING APPENDS AFTER OTHER SCRIPT/S.  ALL NUMBERS ARE NEEDED @file-loaded, TO PREVENT INITIAL STUTTER (SOME WRONG NUMBERS ARE OK).  FULL-SCREEN ASSUMED.  MPV REQUIRES EXTRA ~.1s TO DETECT osd-dimensions/aspect>0.
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
    m.video_aspect,m.osd_aspect,m.aspect = aspects.video,aspects.osd,nil                                 --FOR @seek.

    
    mp.command((''
                ..              '%s vf  append @%s-pad-scale:scale=w=%d:h=%d:flags=%s:eval=frame;'                                --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON.
                ..              '%s vf  append @%s-pad:lavfi=[format=%s,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s,scale=%d:%d,setsar=%s];' --FINAL scale ALMOST ALWAYS NULL-OP, UNLESS W OR H ODD (setsar=1). 
                ..(insta_pause and 'set pause  no ;' or '')
    ):format(command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags,command_prefix,label,format,W2,H2,o.pad_color,W,H,o.video_out_params.par))


    insta_pause    = nil
end 
timers.pad         = mp.add_periodic_timer(.01,apply_pad)  --WITHOUT A TIMEOUT THERE'S LIKE A 5% CHANCE SOME OTHER FILTER FILTERS THE PADDING.
timers.pad.oneshot = 1

function playback_restart()                            --FILTERS' STATES ARE RESET, UNLESS is1frame. 
    if is1frame and playback_restarted then return end --is1frame REPLACEMENTS CAN TRIGGER INFINITE CYCLE.
    m.time_pos,p.seeking = nil                         --FORCES vf-COMMANDS
    m.w,m.h,m.x,m.y,m.aspect = p.width,p.height,0,0    --restart MEMORY STATE.
    
    detect_crop()                    --AFTER seeking.  STARTS auto_delay TIMER.
    apply_scale()                    --IF PAUSED IT TAKES A FEW FRAMES TO TURN ON.
    timers.playback_restart:resume() --UNBLOCKS TOGGLE-TIMERS.
end
mp.register_event('playback-restart',playback_restart) 
timers.playback_restart = mp.add_periodic_timer(.01,function() playback_restarted=true end)  --playback-restart CAN TRIGGER BEFORE aid, BY LIKE 1ms, FOR albumart.

function on_seek()                              --DETECTS BACKWARDS-seek, & MAY REPLACE loop/pad, UNLESS is1frame.
    seek_time          = auto and p['time-pos'] --TIMER CHECKS time-pos.
    if is1frame or not gp('time-pos') then return end                   --time-pos=nil PASSED end-file.
    vf_command_t_delay = seek_time and p['time-pos']<seek_time-1 and .5 --DETECTS BACKWARDS-seek, WHICH REQUIRES t+.5s BY TRIAL & ERROR.  COULD ALSO BE MADE ANOTHER OPTION.  revert-seek SLOW & UNNECESSARY.
    loop               =      loop and    not is1frame           and mp.command(('%s vf pre @loop:lavfi=[loop=-1:1,fps=start_time=%s]'):format(command_prefix,round(p['time-pos'],.001)))  --JPEG PRECISE seeking: RESET STARTPTS.  PTS MAY GO NEGATIVE!  is1frame CAN SET OF A CYCLE.  A FUTURE VERSION MIGHT USE A DIFFERENT TECHNIQUE, LIKE NULL AUDIO STREAM.  ARGUABLY seek SHOULD playlist-next OR playlist-prev IN JPEG-PLAYLIST.
    replace_pad        =  not loop and W2 and p['video-params']  and not (m.osd_aspect==aspects.osd and m.video_aspect==aspects.video) and apply_pad() --W2=nil FOR RAW AUDIO.  video-params=nil IF TOGGLING vo.  IF WINDOW/video CHANGES SIZE, THE DOWN-SCALER SHOULD BE REPLACED, SINCE IT'S DEFAULT OFF STATE IS NOW DIFFERENT.  BUT loop MESSES UP TIMESTAMPS.  THERE'S A SPECIAL CASE WHERE THIS GETS IT WRONG: THE WINDOW RESIZES DURING seeking, BUT AFTER seek.
end
mp.register_event('seek',on_seek)

function on_toggle()  --@key_binding & @property_handler.  
    OFF,m.time_pos = not OFF,nil --OFF SWITCH (FOR CROPS ONLY).  m.time_pos→nil OVERRIDES TOLERANCE.
    detect_crop()                --DOES NOTHING IF OFF.
    
    if OFF then meta.x,meta.y,meta.w,meta.h = 0,0,p.width,p.height  --NULL CROP.
        apply_crop(meta) end
    on_toggle_pad() --TOGGLE BOTH crop & PADDING.  LIKE 2 SCRIPTS IN 1: BITE & STRETCH MECHANISM.
    command = o.toggle_command~='' and mp.command(command_prefix..' '..o.toggle_command)
end
for key in o.key_bindings: gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end  --'[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).

function on_toggle_pad()  --@key_binding & @on_toggle.
    OFF2            = not OFF2  --LOGIC STATE OF PADDING. FULL-SCREEN=~OFF2.  EXACT NUMBERS CHANGE WITH DIMENSIONS, @vid.  OFF2 ARGUABLY THE WRONG WAY AROUND. 
    timers.re_pause:kill()                                                                   --THESE 5 LINES FOR RAPID-TOGGLING WHEN PAUSED.  RESET TIMER FOR NEW PAUSED TOGGLE.
    return_terminal = return_terminal or p.terminal                                          --terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING TABS AS QUICK AS TOUCH-TYPING. EXAMPLE: KEEP TAPPING M IN SMPLAYER, AS FAST AS POSSIBLE.
    insta_unpause   = (insta_unpause  or p.pause and o.unpause_on_toggle>0 and not is1frame) --ALREADY insta_unpause OR IF PAUSED, UNLESS is1frame.  COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
                      and (timers.re_pause:resume() or 1)
                      and mp.command(command_prefix..' set terminal no;set pause no')
    apply_scale()
end
for key in o.key_bindings_pad: gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_pad_'..key,on_toggle_pad) end
timers.re_pause         = mp.add_periodic_timer(o.unpause_on_toggle,function() insta_unpause,return_terminal = mp.command('set pause yes;'..(return_terminal and command_prefix..' set terminal yes' or '')) and nil end)  --ALSO return_terminal.
timers.re_pause.oneshot = 1

function apply_scale(aspect)  --@playback-restart, @property_handler, & @on_toggle_pad/@on_toggle.  SIMPLER TO SEPARATE UTILITY FROM ITS TOGGLE.  COULD BE RENAMED apply_aspect.  STRETCHES BLACK BARS WITHOUT CHANGING vo DSIZE (DISPLAY SIZE). 
    if not (W2 and aspects.video and gp('time-pos')) or p.seeking then return end                      --W2=nil DURING TIMEOUT DEPENDING ON BUILD.  aspects.video=nil DURING complex TRACK-CHANGES.  time-pos=nil @playback-restart PASSED end-file.
    aspects.OFF     = aspects.OFF or aspects.video * aspects.ON / (aspects.osd * o.osd_par_multiplier) --TRUE ASPECT FORMULA.  IT'S JUST WHATEVER THE INPUT IS, MULTIPLIED BY RATIO OF STARTING TO OSD ASPECT, BECAUSE OF HOW THE GRAPHS ARE SET.  THERE ARE ALSO OTHER EXPLANATION/S.  REAL ASPECT OF EACH PIXEL (osd-par) IS ASSUMED TO BE ACCOUNTED FOR IN osd-dimensions/aspect. demux-par IS ACCOUNTED FOR IN video-params/aspect.
    aspect          = aspect      or OFF2  and aspects.OFF or aspects.ON
    m.aspect        = m.aspect    or aspects.restart                                                               --INITIALIZE PRIOR aspect.
    pad_time        = p['time-pos']  + (vf_command_t_delay or o.vf_command_t_delay)                                --DELAY SOMETIMES SET ELSEWHERE, FOR SPECIAL CASE/S.
    pad_time        = pad_time-(m.pad_time and clip(toggle_duration-(pad_time-m.pad_time),0,toggle_duration) or 0) --RAPID TOGGLING CORRECTION, ASSUMES LINEARITY.  REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.
    toggle_duration = insta_unpause        and   0   or o.toggle_duration  --insta_unpause RESETS ITSELF TO nil.  seeking WHILST PAUSED COULD ALSO USE 0 VALUE.
    toggle_expr     = toggle_duration==0   and '(1)' or ('(clip((t-%s)/(%s),0,1))'):format(pad_time,toggle_duration) --[0,1] DOMAIN & RANGE.  0,1=INITIAL,FINAL  TIME EXPRESSION FOR SMOOTH-PADDING.  A DIFFERENT VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    toggle_expr     = o.toggle_expr: gsub('%(expr%)',toggle_expr)                                                    --() ARE MAGIC.
                        
    
    m.pad_iw,pad_iw,m.pad_ih,pad_ih        = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.  STORING THEM PROPERLY IN MEMORY IS MORE CODE, SO DEDUCE FROM m.aspect.
    m.aspect,m.pad_time,vf_command_t_delay = aspect,pad_time,nil  --MEMORY TRANSFER FOR RAPID TOGGLING.
    Dpad_iw,Dpad_ih = pad_iw-m.pad_iw,pad_ih-m.pad_ih  --DIFFERENCE VALUES.  Δ INVALID ON MPV.APP.
    
    command =  --PADS EITHER HORIZONTALLY OR VERTICALLY.
                 is1frame   and   ('%s vf append @%s-pad-scale:scale=w=%d:h=%d:flags=%s:eval=frame;'):format(command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags)  --MAINTAIN frame IN CASE OF SWITCH FROM MP4TAG TO MP4.
              or                ''
              ..(Dpad_iw==0 and '' or 'vf-command %s-pad-scale w round((%d+%d*(%s))/2)*2;'):format(label,m.pad_iw,Dpad_iw,toggle_expr)  --CHECK COMMAND NEEDED, FIRST.  EVENS ONLY. 
              ..(Dpad_ih==0 and '' or 'vf-command %s-pad-scale h round((%d+%d*(%s))/2)*2;'):format(label,m.pad_ih,Dpad_ih,toggle_expr)
    command = command~=''   and mp.command(command)  --COULD BE BLANK WHEN PRESERVING OFF2 STATE.
end 

function apply_crop(meta)  --@detect_crop & @on_toggle.
    if not (meta.min_w and gp('time-pos')) then return end  --time-pos=nil PASSED end-file.  min_w @detect_crop.
    is_excessive  = (meta.w<meta.min_w or meta.h<meta.min_h)
                    and (mp.msg.info('The area to be cropped is too large.'        ) or 1)
                    and (mp.msg.info('You might need to decrease detect_min_ratio.') or 1)
    
    if meta.w<meta.min_w then if o.apply_min_ratio 
         then meta.w,meta.x = meta.min_w,clip(meta.x-(meta.min_w-meta.w)/2,0,meta.max_w-meta.min_w) --MINIMIZE w & clip x.
         else meta.w,meta.x = m.w,m.x end end                                                       --NULLIFY
    if meta.h<meta.min_h then if o.apply_min_ratio
         then meta.h,meta.y = meta.min_h,clip(meta.y-(meta.min_h-meta.h)/2,0,meta.max_h-meta.min_h) --MINIMIZE h & clip y.
         else meta.h,meta.y = m.h,m.y end end                                                       --NULLIFY
    
    is_effective = (1  --Verify if it is necessary to crop.
                    and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)             --REQUIRE CHANGE IN GEOMETRY.
                    and (nil
                         or not m.time_pos                                                     --PROCEED IF INITIALIZING.
                         or math.abs(meta.w-m.w)>wTOLERANCE or math.abs(meta.h-m.h)>hTOLERANCE --PROCEED IF OUTSIDE TOLERANCE.
                         or math.abs(meta.x-m.x)>wTOLERANCE or math.abs(meta.y-m.y)>hTOLERANCE
                         or math.abs(p['time-pos']-m.time_pos)>o.TOLERANCE.time+0              --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.
                   ))
    if not is_effective then return end        --WITHIN TOLERANCE.
    
    command      = is1frame           and  ''  --is1frame OVERRIDE
                       ..(p.pause     and  '' or '   set pause yes;')  --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
                       ..(                       '%s vf  pre @%s-crop:lavfi=[crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1];'):format(command_prefix,label,meta.w,meta.h,meta.x,meta.y)  --lavfi ENABLES min EXPRESSION, WHICH SOLVES INSTA-ERROR @vid DUE TO DELAYED RELOAD (DIMENSIONS CHANGE).
                       ..(p.pause     and  '' or '   set pause no ;')
                   or                      ''  --NORMAL VIDEO.
                       ..(m.w==meta.w and  '' or 'vf-command %s-crop w %d;'):format(label,meta.w)  --w=out_w  EXCESSIVE vf-command CAUSES LAG.  
                       ..(m.h==meta.h and  '' or 'vf-command %s-crop h %d;'):format(label,meta.h)  --h=out_h 
                       ..(m.x==meta.x and  '' or 'vf-command %s-crop x %d;'):format(label,meta.x)
                       ..(m.y==meta.y and  '' or 'vf-command %s-crop y %d;'):format(label,meta.y)
    command      = command~=''        and mp.command(command)              --COULD BE BLANK @on_toggle.
    kill_auto    = not auto           and timers.auto_delay:kill()         --NO FURTHER DETECTIONS.
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,p['time-pos'] --meta→m  MEMORY TRANSFER. 
    wTOLERANCE,hTOLERANCE = m.w*o.TOLERANCE[1],m.h*o.TOLERANCE[1]          --CHANGE @crop.
end

function detect_crop()  --@timers.auto_delay, @playback-restart & @on_toggle.
    timers.auto_delay:resume()                                        --~auto KEEPS CHECKING UNTIL apply_crop.
    if not (W2 and p.width and p.height) or p.seeking then return end --W2 FOR show-text.  width=nil IF TOGGLING vo.  
    if not meta.min_w 
    then   meta.min_w,meta.min_h = p.width*detect_min_ratio,p.height*detect_min_ratio end  --RESET @property_handler.
    meta       .max_w,meta.max_h = p.width                 ,p.height
    
    show_text   = o.meta_osd and mp.command(('show-text                      "'
                      ..'media-title           = ${media-title}             \n'  --ALSO metadata.
                      ..'_VERSION              = %s                         \n'  --Lua 5.1  5.2
                      ..'mpv-version           = ${mpv-version}             \n'  --mpv 0.38.0  →  0.34.0
                      ..'ffmpeg-version        = ${ffmpeg-version}          \n'  
                      ..'libass-version        = ${libass-version}          \n'  
                      ..'platform              = ${platform}                \n'  --nil  windows  linux  darwin     android     
                      ..'current-ao,current-vo = ${current-ao},${current-vo}\n'  --nil  wasapi   pulse  coreaudio  audiotrack  ,  gpu  gpu-next  direct3d  libmpv  shm
                      ..'video-params/alpha    = ${video-params/alpha}      \n'  --nil  straight
                      ..'osd-width,osd-height  = ${osd-width},${osd-height} \n'
                      ..'   pad_iw,pad_ih      = %d,%d                      \n'  --1680,944
                      ..'   pad_ow,pad_oh      = %d,%d                      \n'  --1680,1050
                      ..'    max_w,max_h       = ${width},${height}         \n'  --1920,1080
                      ..'    min_w,min_h       = %d,%d                      \n'  --480,270
                      ..'        w,h           = %d,%d                      \n'
                      ..'        x,y           = %d,%d                    \n\n'
                      ..'vf-metadata/%s = \n${vf-metadata/%s}                "'            
                  ):format(_VERSION,pad_iw,pad_ih,W2,H2,meta.min_w,meta.min_h,m.w,m.h,m.x,m.y,label,label))  --nil INVALID ON MPV.APP.
    if OFF then return end
    vf_metadata = gp('vf-metadata/'..label)                                  --Get the metadata.
    if not vf_metadata then mp.msg.error('No crop metadata.'               ) --Verify the existence of metadata.
        mp.msg.info('Was the cropdetect filter successfully inserted?'     )
        mp.msg.info('Does your version of FFmpeg support AVFrame metadata?') 
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

function property_handler(property,val)
    p[property] = val
    aspects.video,aspects.osd = (p['video-params'] or {}).aspect,p['osd-dimensions/aspect'] or 0  --video-params/aspect IS NEVER 0, BUT osd-dimensions/aspect CAN BE.  ON STATE IS CONSTANT.  
    meta.min_w,meta.min_h,aspects.OFF = nil  --FORCE RECOMPUTATIONS. 
    
    for key in ('mute aid sid'):gmatch('[^ ]+')  --DOUBLE-TAPS.  W BLOCKS RAW AUDIO.
    do toggle   =     property==key and playback_restarted   and W    and  (not timers[key]:is_enabled() and (timers[key]:resume() or 1) or on_toggle()) end  --W2 BLOCKS RAW AUDIO.  TOGGLERS AWAIT playback_restarted.
    rescale     =     property=='osd-dimensions/aspect'      and OFF2 and  apply_scale()  --CHANGING WINDOW SIZE!  NEW aspects REQUIRED FIRST.  WHEN PAUSED MUST FRAME-STEP OR UNPAUSE.  UNFORTUNATELY is1frame AUDIO GLITCHES (MORE RIGOROUS ALTERNATIVE COULD USE A NEW TIMER).
    reload      = (nil  --5 RELOAD CONDITIONS: @android-surface-size, @image, @NEW-vo, @is1frame & @alpha.
                   or property=='android-surface-size'       and W and p.fullscreen  --RELOAD @fullscreen ROTATION.
                   or property=='current-tracks/video/image' and W and val~=v.image  --RELOAD IF SWITCHING BTWN MP4 & MP4TAG.  UNFORTUNATELY EMBEDDED MPV SNAPS.  albumart DISTINCTION IS IRRELEVANT.
                   or property=='video-params'               and val and (not W or is1frame or val.alpha and not alpha)  --NEW vo, OR Δalbumart, OR TRY SWITCH TO TRANSPARENCY.  is1frame MUST BE RE-DRAWN.  TRANSPARENCY TAKES TIME TO DETECT, BUT DELAYED TRIGGERS ARE BAD.
    ) and file_loaded() 
end 
for property in ('current-tracks/video/image fullscreen seeking pause terminal mute aid sid width height osd-dimensions/aspect android-surface-size video-params'):gmatch('[^ ]+')  --BOOLEANS NUMBERS string table nil
do mp.observe_property(property,'native',property_handler) end  --TRIGGER AFTER load-script.

for key in ('mute aid sid'):gmatch('[^ ]+')  --1SHOT NULL-OP DOUBLE-TAPS.  double_pause_timeout=0 (p&p DOUBLE-TAP) ALSO SIMPLE TO IMPLEMENT.  current-tracks/audio/selected(double_ao_timeout) & current-tracks/sub/selected(double_sub_timeout) ARE STRONGER ALT-CONDITIONS REQUIRING OFF/ON, AS OPPOSED TO ID#.  current-ao ALSO DOES WHAT current-tracks/audio/selected DOES, BUT SAFER @playlist-next.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  
do  timers[key]         = mp.add_periodic_timer(o['double_'..key..'_timeout'], function()end ) 
    timers[key].oneshot = 1 end 
for _,timer in pairs(timers) do timer:kill() end


----~400 LINES & ~6000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED. 
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS:  windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  WON'T OPEN JPEG ON ANDROID.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----FUTURE VERSION SHOULD OPERATE 1fps IN is1frame MODE, FOR FRAME-BY-FRAME GIFs.  vf-command DOESN'T REDRAW CURRENT FRAME.  BUT AUDIO COULD GLITCH...
----FUTURE VERSION SHOULD BE CAPABLE OF SMOOTH-CROPPING BY REPLACING BLACK BARS WITH BLACK PADS, & THEN SMOOTH-UNPAD. BECAUSE SMOOTH-PADDING IS EASY.  EFFICIENT TRUE SMOOTH-crop IS IMPOSSIBLE WITH FFMPEG-v6.
----FUTURE VERSION SHOULD HAVE o.keep_aspect, TO MAINTAIN TRUE ASPECT @ALL TIMES.
----COULD BE RENAMED autocrop-mod.lua.  WITHOUT SCALING THIS SCRIPT WOULDN'T EXIST, SO autocropscale.lua MAKES SENSE. BUT IT HAS PADDING TOO!  MY LONGEST SCRIPT - LIKE 2.5 SCRIPTS IN 1 (autocrop, autopad & start/end PLAYLIST MANAGER).  A CROP IS A PAD-REMOVAL, SO THE FULL COMBO IS MORE INTUITIVE!
----RARE BUG: JPEG FAILS TO SCALE.

----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0   UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split        CLONES video. UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

