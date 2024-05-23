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
    key_bindings        = 'C     Tab',  --DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. TOGGLE DOESN'T AFFECT start & end LIMITS.  
    key_bindings_pad    = 'Shift+Tab',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  INSTEAD OF "autopad.lua" THIS SCRIPT CAN TOGGLE PADDING.  CAN HOLD IN SHIFT TO RAPID TOGGLE.
    double_mute_timeout =         .5 ,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration     =         .4 ,  --SECONDS TO TOGGLE PADDING. REMOVE FOR INSTA-TOGGLE.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.  AN EXTRA fps OPTION COULD MAKE PADDING SMOOTHER THAN FILM ITSELF!
    unpause_on_toggle   =         .12,  --DEFAULT=0 SECONDS.  REMOVE TO DISABLE UNPAUSE FOR PAUSED TOGGLE.  SOME FRAMES ARE ALREADY DRAWN IN ADVANCE. DOESN'T APPLY TO is1frame. 
    vf_command_t_delay  =         .1 ,  --DEFAULT=0 SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO FRAMES ALREADY BEING DRAWN IN ADVANCE.
    pad_scale_flags     =  'bilinear',  --DEFAULT=bicubic  BUT bilinear WAS ONCE DEFAULT IN OLD FFMPEG & IS FASTER @frame DOWN-SCALING. bicubic IS BETTER QUALITY.  BUT THIS IS FOR THE PADDING DOWN-SCALER.
    pad_color           =     'BLACK',  --DEFAULT BLACK. 'BLACK@0' (& format) FOR TRANSPARENCY.  MAROON, PURPLE, DARKBLUE, DARKGREEN, DARKGRAY, PINK & WHITE ARE ALSO NICE.  THIS COULD BE REPLACED WITH EXTRA x:y OPTIONS, LIKE WHETHER TO pad FROM THE CENTER OR TOP.
    -- pad_format       =  'yuva420p',  --FINAL pixelformat. UNCOMMENT FOR TRANSPARENT PADDING.
    detector            = 'cropdetect=limit=%s:round=%s:reset=1',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1'  %s,%s = detect_limit,detect_round  reset>0.
    options_image       = {detector='bbox=min_val=%s',detect_limit=30,detect_min_ratio=.1},  --DEFAULT={detector='bbox=%s'}  OVERRIDES FOR IMAGES.   bbox ALSO ACTS AS alpha OVERRIDE. TRANSPARENT VIDEO CAUSES A cropdetect BUG. 
    TOLERANCE           = {.05,time=10},  --DEFAULT={0}.  INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO time=10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    MAINTAIN_CENTER     = {0,0}, --{TOLERANCE_X,TOLERANCE_Y}  DOESN'T APPLY TO JPEG.  {0,0} MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE = true,  --AGGRESSIVE CROP-FLAG. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO    = true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS. DEFAULT IGNORES EXCESSIVE detect_crop.
    -- crop_no_vid      = true,  --crop ABSTRACT VISUALS TOO (PURE lavfi-complex).
    -- msg_log          = true,  --UNCOMMENT TO MESSAGE MPV LOG. FILLS THE LOG.
    -- meta_osd         =    1,  --SECONDS. UNCOMMENT TO DISPLAY _VERSION mpv-version ffmpeg-version libass-version & ALL detector METADATA.
    -- toggle_expr      = '(1-cos(PI*%s))/2',    --DEFAULT=%s=LINEAR_IN_TIME  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION BTWN aspect RATIOS. DOMAIN & RANGE BOTH [0,1].  A SINE WAVE IS 57% FASTER @MAX-SPEED, FOR SAME toggle_duration (PI/2=1.57). BUT ACCELERATION MAY BE A BAD THING!
    -- dimensions       = {w=1680,h=1050,par=1}, --DEFAULT={w=display-width,h=display-height,par=osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO}  THESE ARE OUTPUT PARAMETERS. THE TRUE ASPECT-TOGGLE ACCOUNTS FOR BOTH PAR_IN & PAR_OUT, VALID @FULLSCREEN.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW DISPLAY w,h,par @file-loaded, SO OVERRIDE IS REQUIRED.  CAN MEASURE display TO DETERMINE par.
    options={
        'osd-font-size 16','geometry 50%',  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. 
    },
    limits={  --NOT CASE SENSITIVE. DON'T FORGET COMMAS! CAN ALSO USE END OF YOUTUBE URL.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS. STARTING & ENDING CREDITS ARE EASIER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ----["path-substring"]={start,end,detect_limit}={SECONDS,SECONDS<0,number} (OR nil).  detect_limit IS FINAL OVERRIDE & MUST BE NAMED.  start & end MAY ALSO BE 'PERCENTAGES'.
        ["Megadeth Sweating Bullets Official Music Video"]={0,-5},
        ["We are army of people - Red Army Choir"]={detect_limit=60},
        ["Конармейская Rote Reiterarmee"]={detect_limit=40},
        [  "День Победы."]={4,-13},                        --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7}, --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        
    },
}
require 'mp.options'.read_options(options)    --OPTIONAL?
o,label        = options,mp.get_script_name() --label=autocrop  mp=MEDIA-PLAYER
command_prefix = o.suppress_osd and 'no-osd' or ''
m,p,meta_name  = {},{},'vf-metadata/'..label --m=METADATA MEMORY  p=PROPERTIES  meta_name=PROPERTY_NAME OF METADATA.
for   opt,val in pairs( {key_bindings='C',toggle_duration=0,unpause_on_toggle=0,options_image={detector='bbox=%s'},TOLERANCE={0},detector='cropdetect=limit=%s:round=%s:reset=1',dimensions={},} )
do  o[opt]     = o[opt] or val end  --ESTABLISH DEFAULTS.
for   opt in ('auto_delay double_mute_timeout unpause_on_toggle meta_osd'):gmatch('[^ ]+')  --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA USED BY THE NEWEST mpv.app (SAME VERSION, BUILT DIFFERENT).
do o[opt]      = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end  --string→number: '1+1'→2  load INVALID ON mpv.app. 
for _,opt in pairs(o.options or {})
do command     = (' %s %s set %s; '):format(command or '',command_prefix,opt) end  --ALL SETS IN 1.
if command then mp.command(command) end

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER FOR EVEN PADDING.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function start_file()
    for  property in ('path start end'):gmatch('[^ ]+') 
    do p[property]  = mp.get_property(property) end  --property CALLS.
    limits,p.path   = {},p.path:lower()  --ESTABLISH limits, NOT CASE SENSITIVE.  
    for key,val in pairs(o.limits or {}) do if p.path:find(key:lower(),1,1)  -- 1,1 = STARTING_INDEX,EXACT_MATCH  
        then limits = val  
            break end end
    limits[1]       = limits[1] or limits.start
    limits[2]       = limits[2] or limits['end']
    command         =
        (limits[1] and ('none 0%'):find(p.start,1,1)          and '%s set start %s;' or ''):format(command_prefix,limits[1])..  --SET start IF 0.  SIMPLER THAN seeking OR TRIMMING TIMESTAMPS.  ("%" IS MAGIC)
        (limits[2] and (p['end']=='none' or p['end']=='100%') and '%s set end   %s;' or ''):format(command_prefix,limits[2])..
    ''
    if command~='' then mp.command(command) end
end
mp.register_event('start-file',start_file)

function end_file()
    W=nil  --W MEANS CROPPER ACTIVE. BUT NEXT FILE MAY NOT BE VIDEO.
    mp.command(('%s set start %s;%s set end %s;'):format(command_prefix,p.start,command_prefix,p['end']))
end 
mp.register_event('end-file',end_file)  --FOR MPV PLAYLISTS, OR ELSE NEXT TRACK STARTS WRONG.

function file_loaded() --ALSO @vid, @alpha & @osd-par.  MPV MAY REQUIRE EXTRA .1s TO DETECT alpha & osd-par. 
    v,v_params,msg_level = mp.get_property_native('current-tracks/video') or {},mp.get_property_native('video-params') or {},mp.get_property('msg-level')
    if not (v.id or v_params.w) or not (v.id or o.crop_no_vid) then return end --RAW AUDIO (~w) ENDS HERE, & lavfi-complex MAY NOT NEED CROPPING.
    
    if not detect_format then mp.set_property('msg-level','all=no')  --~detect_format MEANS ONCE ONLY.  OLD FFMPEG DETECTION. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING DURING TESTING.  
         _,error_scale  = mp.command(('%s vf pre @%s-scale:lavfi-scale=iw:oh'   ):format(command_prefix,label))     --fatal ERROR IN FFMPEG-v4.4+, BUT NOT v4.2 (.AppImage RELEASE).  SMOOTH-PADDING IMPOSSIBLE IN v4.2. OLD FFMPEG FAILS TO REPORT (FALSE NEGATIVE). MPV OFTEN BUILT WITH v4.2→v6.1.  ERROR RETURNS AREN'T COMBINED EASILY.
         _,error_format = mp.command(('%s vf pre @%s-scale:lavfi-format'        ):format(command_prefix,label)) end --      ERROR IN FFMPEG-v4   , BUT NOT v6   (.7z       RELEASE).  v4 REQUIRES FORCING COMMANDS, RESULTING IN LAG.
    
    lavfi_complex,command,insta_pause = mp.get_opt('lavfi-complex'),'',not p.pause  --command IS FOR POST-INSERTION.
    msg_level        = not W and msg_level~='all=no' and msg_level  --RETURNS NON-TRIVIAL msg-level ONCE ONLY.
    is1frame         = v.albumart and not lavfi_complex  --REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. MP4TAG TRACK 2 IS CONSIDERED albumart. is1frame TOGGLES WHEN USER SWITCHES TRACK.
    loop             = v.image    and not lavfi_complex
    auto             = not is1frame and o.auto  --~auto FOR is1frame.
    MAINTAIN_CENTER  = loop and {}  or o.MAINTAIN_CENTER or {}  --RAW JPEG CAN MOVE CENTER. 
    time_pos         = loop and round(mp.get_property_number('time-pos'),.001)  --NEAREST MILLISECOND.
    detect_format    = mp.get_property('vo'):find('shm') and 'yuv420p' or v_params.alpha and 'yuva420p' or error_format and 'yuv420p' or ''    --DETECTOR PIXELFORMAT.  ("shm,!"=SHARED MEMORY)  OR  (TRANSPARENT)  OR   (OLD FFMPEG)  OR  (NULL-OP).  FORCING yuv420p OR yuva420p IS MORE RELIABLE, ESPECIALLLY ON SMPlayer.app(shm) - IT AUTOCONVERTS. mpv.app DETECTS TRANSPARENCY OK, BUT NOT EMBEDDED shm.
    pad_format       = o.pad_format or detect_format  --OUTPUT PIXELFORMAT.  OVERRIDE  OR  DETECTOR.
    detect_limit     = limits.detect_limit or v.image and o.options_image.detect_limit     or o.detect_limit
    detect_min_ratio =   v.image                      and o.options_image.detect_min_ratio or o.detect_min_ratio
    detector         = ((v.image or v_params.alpha)   and o.options_image.detector or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USE bbox.
    m                = {vid=v.id,par=par,aspect=aspect,toggle_duration=o.toggle_duration}  --MEMORIZE vid & par IN CASE THEY CHANGE.  aspect IS TO PRESERVE PADDING STATE BTWN TRACKS (vid & PLAYLIST).  RAPID TOGGLING MAY REQUIRE MEMORY OF PRIOR DURATION - IT COULD BE 0 WHEN PAUSED (CAN VARY ON/OFF BTWN TOGGLES).
    W                = o.dimensions.w or o.dimensions[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --OVERRIDE  OR  display  OR  VIDEO   DIMENSIONS. v_params DEPEND ON lavfi-complex.
    H                = o.dimensions.h or o.dimensions[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h']
    W2,H2            = round(W,2),round(H,2)  --EVEN DIMENSIONS ARE NEEDED, EXCEPT @FINISH.
    aspect           = (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect)*(v['demux-par'] or v_params.par or 1)/par  --ABBREVIATE aspect=aspect_out.  DEFAULT GRAPH STATE IS ALWAYS OFF (PADDED). BUT STATE IS PRESERVED.
    aspects          = {OFF=aspect,ON=W2/H2}  --OFF OR ON(FULL-SCREEN).  A CROP-ON IS A PAD-OFF, BUT I'VE MADE ON=FULL-SCREEN=PAD-OFF.  THIS ASSUMES v['demux-w']/v['demux-h'] DOESN'T CHANGE, EXCEPT @vid (TRACK CHANGE). OTHERWISE COULD OBSERVE current-tracks/video INSTEAD OF JUST vid.
    pad_iw,pad_ih    = round(math.min(W2,H2*aspect),2),round(math.min(W2/aspect,H2),2)  --pad INPUT_WIDTH,INPUT_HEIGHT.
    
    mp.command((
        (msg_level   and "%s set msg-level '%s';" or ''):format(command_prefix,msg_level)..  --RETURNS msg-level.  MAY BE BLANK.
        (insta_pause and '%s set pause      yes;' or ''):format(command_prefix)          ..  --PREVENTS EMBEDDED MPV FROM SNAPPING, & is1frame  INTERFERENCE.  HOWEVER lavfi-complex DOESN'T NEED IT.
        '%s vf pre    @%s-scale:lavfi=[scale=%d:%d,setsar=1];'                           ..  --setsar REQUIRED FOR RELIABILITY ON SMPlayer.app (INTERFERENCE).  SEPARATE GRAPH BECAUSE INPUT OR OUTPUT DIMENSIONS SHOULD BE CONSTANT FOR EACH FILTER.
        '%s vf pre    @%s-crop:crop=keep_aspect=1:exact=1;'                              ..  --SEPARATE FOR RELIABILITY WITH OLD FFMPEG & PNG-alpha.  
        '%s vf pre    @%s:lavfi=[format=%s,%s];'                                         ..  --cropdetect OR bbox
        '%s vf append @%s-scale-pad:scale=w=%d:h=%d:flags=%s:eval=frame;'                ..  --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON.  PADDING SHOULD BE LAST. MORE RIGOROUS CODE COULD OBSERVE vf TO ENSURE IT.
        '%s vf append @%s-pad:lavfi=[format=%s,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s,scale=%d:%d,setsar=1];'..  --FINAL scale ALMOST ALWAYS NULL-OP. W,H MAY BE ODD.
    ''):format(command_prefix,label,W2,H2,command_prefix,label,command_prefix,label,detect_format,detector,command_prefix,label,pad_iw,pad_ih,o.pad_scale_flags or '',command_prefix,label,pad_format,W2,H2,o.pad_color or '',W,H)) 
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d,%s = DECIMAL_INTEGER,string.  3 CHAINS + 2 FILTERS (+JPEG CHAIN).  SEPARATE FILTERS IMPROVES RELIABILITY OVER FFMPEG VERSIONS & alpha.
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----format     = pix_fmts                  IS THE START FOR VIDEO. USUALLY NULL-OP.  BUGFIX FOR alpha ON OLD FFMPEG (.AppImage, ETC).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS.
    ----fps        = fps:start_time             DEFAULT=25  start_time (SECONDS) SETS STARTPTS FOR JPEG (--start).  THIS USES ~5% CPU UNTIL USER HITS PAUSE. FOR SMOOTH PADDING ON JPEG.
    ----cropdetect = limit:round:reset          DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP (2 BY DEFAULT).  alpha TRIGGERS BAD PERFORMANCE BUG.
    ----bbox       = min_val                    DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH, BUT THAT COMBINES DEFICITS.
    ----crop       = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:...:0   exact OPTIONAL.  keep_aspect REQUIRED TO STOP UNWANTED ERRORS IN MPV LOG.  WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval         DEFAULT=iw:ih:bicubic:...:init  dst_format CAN ALSO BE SET (ALTERNATIVE TO format). 
    ----pad        = w:h:x:y:color              DEFAULT=0:0:0:0:BLACK   0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar     = sar                        DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO=1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT (IN REALITY OUTPUT IS DIFFERENT).  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart.  FOR DEBUGGING CAN PLACE setsar=1 EVERYWHERE (ACTS AS ARMOR).  SINCE THIS IS LIKE 2 SCRIPTS IN 1, setsar=1 IS REPEATED.
    
    for _,filter in pairs(mp.get_property_native('vf')) do if filter.label=='loop'
        then command =  ('%s vf remove @loop;'):format(command_prefix) end end   --remove @loop, AT CHANGE IN vid. COULD ALSO BE THERE DUE TO OTHER SCRIPTS.  ONLY CHECK AFTER INSERTING EVERYTHING ELSE.
    command          =  command..
        (loop        and '%s vf  pre   @loop:lavfi=[format=%s,loop=-1:1,fps=25:%s];' or ''):format(command_prefix,detect_format,time_pos)..  --FORMATTING BEFORE loop PREVENTS EMBEDDED MPV FROM SNAPPING ON PNG (TRANSPARENCY). FORCING yuva420p MAY BE SAFER THAN ARBITRARY RGBA FORMATS.  fps=25 IS AN ISSUE FOR LEAD-FRAMES (MP4TAG).
        (insta_pause and '%s set pause no;'                                          or ''):format(command_prefix                       )..  --UNPAUSE.
    ''
    
    if command~='' then mp.command(command) end
    if not m.aspect or m.aspect==aspects.ON then on_toggle_pad() end  --TOGGLE ON IF NEEDED: PRESERVE pad STATE.
    timers.auto_delay:resume() --auto_delay (OR detect_seconds) NEEDED FOR INITIAL DETECTION (is1frame).
end
mp.register_event('file-loaded',file_loaded)
mp.observe_property('vid','number',function(_,vid) if vid and m.vid and m.vid~=vid then file_loaded() end end)  --RELOAD IF vid CHANGES. vid=nil IF LOCKED BY lavfi-complex.  UNFORTUNATELY EMBEDDED MPV SNAPS EVERY TIME.  AN MP3 OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED CROPPING (& HAVE RUNNING audio). 
mp.observe_property('pause'    ,'bool'  ,function(property,val) p[property]=val end)  --MORE EFFICIENT TO observe.

function playback_restart() --GRAPH STATES ARE RESET, UNLESS is1frame (GEOMETRY PERMANENT). 
    if W and not is1frame then m.w,m.h,m.x,m.y,m.aspect = nil,nil,nil,nil,nil  --W IMPLIES LOADED VIDEO. FORCE ALL vf-COMMANDS.  is1frame WOULD SUFFER INFINITE LOOP: GRAPH REPLACEMENTS CAUSE playback-restart. 
        toggle_duration = o.toggle_duration  --FORCE SMOOTH PADDING EVEN IF PAUSED (UNLESS error_scale). OTHERWISE IF nil & PAUSED WOULD INSTA-SNAP PADDING. 
        aspect          = aspect==aspects.ON and aspects.OFF or aspects.ON  --ON←→OFF  FORCE pad TOGGLE BACK TO CURRENT STATE.
        on_toggle_pad()
        detect_crop() end  --RESUMES TIMER.
end
mp.register_event('playback-restart',playback_restart)

function on_osd_par(_,osd_par)  --UNLESS OVERRIDE, ASSUME osd_par=SCREEN PIXEL ASPECT RATIO (THE REAL ASPECT OF EACH PIXEL ON TV OR PROJECTOR SCREEN).
    par=o.dimensions.par or o.dimensions[3] or osd_par>0 and osd_par or 1
    if m.par and m.par~=par then file_loaded() end  --RELOAD @osd-par.  UNTESTED!
end
mp.observe_property('osd-par','number',on_osd_par)  --0@LOAD & file-loaded, 1@playback-restart. BUT MAYBE ~1 ON EXPENSIVE SYSTEM.

function on_v_params(_,params)  --video-params ALMOST NEVER CHANGE.
    if params then max_w,max_h = params.w,params.h
         if params.alpha and not v_params.alpha then file_loaded() end end  --RELOAD @alpha IF NEEDED.
end 
mp.observe_property('video-params','native',on_v_params)  

function on_toggle(mute)  --TOGGLES BOTH crop & PADDING.
    if not W then return  --NO TOGGLE FOR RAW AUDIO.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume()  --START timer OR ELSE TOGGLE.  
    else OFF = not OFF  --OFF SWITCH (FOR CROPS ONLY).
        if OFF then apply_crop({ x=0,y=0, w=max_w,h=max_h }) end --NULL crop, IF VIDEO.
        detect_crop() 
        on_toggle_pad() end  --THIS TOGGLE OPERATES 2 TOGGLES: LIKE 2 SCRIPTS IN 1.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function on_toggle_pad()     --PAD TOGGLE ONLY - NO CHANGE IN crop.  PADS BLACK BARS WITHOUT CHANGING [vo] scale. VALID @FULLSCREEN.  A DIFFERENT VERSION COULD USE osd-dimensions (ON-SCREEN-DISPLAY WINDOW SIZE).  A FUTURE VERSION SHOULD SEPARATE apply_pad FROM on_toggle_pad (THIS function IS BOTH COMBINED).
    if not W then return end --~W MEANS INACTIVE.
    insta_unpause   = not is1frame and p.pause and o.unpause_on_toggle>0 --IF PAUSED, o.unpause_on_toggle.
    return_terminal = insta_unpause and mp.get_property_bool('terminal') --terminal GAP REQUIRED BY SMPLAYER-v24.5 OR IT GLITCHES.
    aspect          = aspect==aspects.ON and aspects.OFF or aspects.ON   --→ON IF nil.
    m.aspect        = m.aspect or aspects.OFF --ASSUME OFF IF nil.  GRAPH RESETS AFTER playback-restart.
    pad_time        = mp.get_property_number('time-pos')+(o.vf_command_t_delay or 0)
    m.pad_time      = m.pad_time or -1  --INITIALIZE IF MEMORY BLANK.  -1 MEANS NO RAPID-SUBTRACTION.
    pad_time        = pad_time-math.max(0,   m.toggle_duration-math.max(0,pad_time-m.pad_time))      --REMAINING_DURATION_OF_PRIOR_TOGGLE=DURATION-TIME_SINCE_LAST_TOGGLE    SUBTRACT REMAINING_DURATION, FOR CURRENT TOGGLE.  (UP → DOWN→UP.) 
    toggle_duration = not error_scale and 0 or toggle_duration or p.pause and 0 or o.toggle_duration --NEW toggle_duration, UNLESS SET @playback-restart.  IT MAY BE FORCED DUE TO DEFAULT PAD STATE.
    clip            = toggle_duration==0 and 1 or ('clip((t-%s)/(%s),0,1)'):format(pad_time,toggle_duration)  --A DIFFERENT VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    clip            = (o.toggle_expr or '%s'):gsub('%%s',clip) --NON-LINEAR clip.  [0,1] DOMAIN & RANGE.  TIME EXPRESSION FOR SMOOTH-PADDING.  0=INITIAL, 1=FINAL.  
    m.pad_iw,pad_iw,m.pad_ih,pad_ih = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.
    Dpad_iw,Dpad_ih = pad_iw-m.pad_iw,pad_ih-m.pad_ih  --DIFFERENCE VALUES.  Δ INVALID ON mpv.app (SAME LUA VERSION, BUT BUILT DIFFERENT).
    m.aspect,m.pad_time,m.toggle_duration,toggle_duration = aspect,pad_time,toggle_duration,nil  --MEMORY TRANSFER ENABLES DOUBLE-BACK (UP→DOWN).  toggle_duration→nil TO HANDLE PAUSED @playback-restart.
    
    vf_command=  --TARGETED scale COMMANDS pad EITHER HORIZONTALLY OR VERTICALLY.
        ((error_format or Dpad_iw~=0) and '%s vf-command %s-scale-pad w round((%d+%d*(%s))/2)*2;' or ''):format(command_prefix,label,m.pad_iw,Dpad_iw,clip)..  --CHECK COMMAND NEEDED, FIRST. FORCE IF ERROR.
        ((error_format or Dpad_ih~=0) and '%s vf-command %s-scale-pad h round((%d+%d*(%s))/2)*2;' or ''):format(command_prefix,label,m.pad_ih,Dpad_ih,clip)..
    ''
    command   =
        (is1frame      and '%s vf pre @%s-scale-pad:scale=w=%d:h=%d;' or vf_command):format(command_prefix,label,pad_iw,pad_ih)..
        (insta_unpause and '%s set terminal no;%s set pause no;'      or ''        ):format(command_prefix,command_prefix     )..  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
    ''
    
    if command~='' then mp.command(command) end
    if not is1frame and error_format and vf_command~='' then for N=1,9 
        do mp.add_timeout(2^N/100,function()mp.command(vf_command)end) end end  --OLD FFMPEG REQUIRES REPEATING vf_command. BUT THAT CAUSES LAG.  CAN USE EXPONENTIAL TIMEOUTS (.02 .04 .08 .16 .32 .64 1.28 2.56 5.12)s, LIKE A SERIES OF DOUBLE-TAPS (FOR MACOS-VIRTUALBOX.)  vf_command EXISTS BECAUSE loadstring DIDN'T WORK IN THIS CONTEXT IN SMPlayer.app.
    if insta_unpause then timers.pause:resume() end  --RE-PAUSER
end
for key in (o.key_bindings_pad or ''):gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_pad_'..key,on_toggle_pad) end

function detect_crop() 
    timers.auto_delay:resume()           --~auto KEEPS CHECKING UNTIL apply_crop.
    if OFF or not max_w  then return end --AWAIT v_params.

    min_w,min_h   = max_w*detect_min_ratio,max_h*detect_min_ratio  --MAY VARY @vid.
    meta,time_pos = mp.get_property_native(meta_name),mp.get_property_native('time-pos')  --Get the metadata.
    
    if not meta then if o.msg_log then mp.msg.error("No crop metadata.")    --Verify the existence of metadata.  HAPPENS RARELY IF seeking NEAR end-file. SOMETIMES IT'S {} WHEN PAUSED, WHICH FAILS THE NEXT TEST.
            mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?") end
        return  
    elseif o.meta_osd then for property in ('mpv-version ffmpeg-version libass-version '..meta_name):gmatch('[^ ]+') 
        do p[property]=mp.get_property_osd(property) end
        mp.osd_message((
            '_VERSION      =%s\n'..
            'mpv-version   =%s\n'..
            'ffmpeg-version=%s\n'..
            'libass-version=%s\n'..
            '%s=\n%s'            ..
        ''):format(_VERSION,p['mpv-version'],p['ffmpeg-version'],p['libass-version'],meta_name,p[meta_name]),o.meta_osd) end  --DISPLAY COORDS FOR 1 SEC. THIS BUGS OUT IF ~meta.
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do meta[key]=tonumber(meta['lavfi.cropdetect.'..key] or meta['lavfi.bbox.'..key]) end  --tonumber(nil)=nil (BUT 0+nil RAISES ERROR).
    for key in ('w h x1 y1 x2 y2    '):gmatch('[^ ]+') 
    do if not meta[key] then if o.msg_log then mp.msg.error("Got empty crop data.") end  
            return end end
    
    if not (meta.x and meta.y) 
    then meta.x,meta.y      = (meta.x1+meta.x2-meta.w)/2,(meta.y1+meta.y2-meta.h)/2 end  --bbox GIVES x1 & x2 BUT NOT x. CALCULATE x & y BY TAKING AVERAGE.
    if o.USE_INNER_RECTANGLE 
    then xNEW  ,yNEW        = math.max(meta.x1,meta.x2-meta.w,meta.x       ),math.max(meta.y1,meta.y2-meta.h,meta.y       )
        meta.x2,meta.y2     = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y      = xNEW,yNEW
        meta.w ,meta.h      = meta.x2-meta.x,meta.y2-meta.y end
    if MAINTAIN_CENTER[1] 
    then xNEW               = math.min( meta.x , max_w-(meta.x+meta.w) )  --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW               = max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*MAINTAIN_CENTER[1] 
         then meta.x,meta.w = xNEW,wNEW end end
    if MAINTAIN_CENTER[2] 
    then yNEW               = math.min( meta.y , max_h-(meta.y+meta.h) )  --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW               = max_h-yNEW*2
         if hNEW-meta.h>hNEW*MAINTAIN_CENTER[2]  --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
         then meta.y,meta.h = yNEW,hNEW end end  
    if meta.w<min_w then if not o.USE_MIN_RATIO 
         then meta.w,meta.x = max_w,0  --NULL w
         else meta.w,meta.x = min_w,math.max(0,math.min(max_w-min_w,meta.x-(min_w-meta.w)/2)) end end  --MINIMIZE w
    if meta.h<min_h then if not o.USE_MIN_RATIO                                                        
         then meta.h,meta.y = max_h,0  --NULL h                                                        
         else meta.h,meta.y = min_h,math.max(0,math.min(max_h-min_h,meta.y-(min_h-meta.h)/2)) end end  --MINIMIZE h

    if meta.w>max_w or meta.h>max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return  --IF w<0 IT'S LIKE A JPEG ERROR.
    elseif not (m.w and m.h and m.x and m.y) then m.w,m.h,m.x,m.y = max_w,max_h,0,0 end --INITIALIZE 0TH crop AT BEGINNING FOR INITIAL CHECK.
    
    is_effective=(meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y) and                 --REQUIRE CHANGE IN GEOMETRY.
        (not m.time_pos  --Verify if it is necessary to crop.                                     PROCEED IF INITIALIZING.
         or  math.abs(meta.w-m.w)>m.w*o.TOLERANCE[1] or math.abs(meta.h-m.h)>m.h*o.TOLERANCE[1] --PROCEED IF OUTSIDE TOLERANCE.
         or  math.abs(meta.x-m.x)>m.w*o.TOLERANCE[1] or math.abs(meta.y-m.y)>m.h*o.TOLERANCE[1]
         or  math.abs(time_pos-m.time_pos)>o.TOLERANCE.time+0)                                  --PROCEED IF TIME CHANGES TOO MUCH.  +0 CONVERTS→number.

    if is_effective  then apply_crop(meta) 
    elseif o.msg_log then mp.msg.info("No area detected for cropping.") end
end

function re_pause()  --pause AGAIN AFTER insta_unpause. BUT TERMINAL GAP COMPLICATES IT.
    mp.command(
                                    'set pause    yes;'       ..
        (return_terminal and 'no-osd set terminal yes;' or '')..
    '')
end 

timers         = {  --CARRY OVER IN MPV PLAYLIST. 
    auto_delay = mp.add_periodic_timer(o.auto_delay              ,detect_crop  ),
    mute       = mp.add_periodic_timer(o.double_mute_timeout or 0,function()end),  --mute TIMER TIMES.
    pause      = mp.add_periodic_timer(o.unpause_on_toggle       ,re_pause     ),  --pause TIMER PAUSES & RETURNS terminal.
}
timers.mute.oneshot,timers.pause.oneshot = 1,1
for _,timer in pairs(timers) do timer:kill() end

function apply_crop(meta) 
    command = 
        is1frame and (  --is1frame OVERRIDE
            '%s set pause yes;%s vf pre @%s-crop:lavfi=[crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1];'.. --insta_pause MORE RELIABLE DUE TO INTERFERENCE FROM OTHER SCRIPT/S.  min IS BUGFIX FOR RARE BUG ON MACOS (shm vo). meta.w>iw AT SOME POINT IN TIME. 
            (p.pause     and '' or '%s set pause no;'                                             ).. 
        ''):format(command_prefix,command_prefix,label,meta.w,meta.h,meta.x,meta.y,command_prefix) 
        or
            -- (m.w==meta.w and '' or '%s vf-command %s-crop w %d;'):format(command_prefix,label,meta.w)..  --w=out_w=width  EXCESSIVE vf-command CAUSES LAG.  SPELLING OUT ALL COORDINATES IN FULL MAY BE MORE VERSATILE OVER DIFFERENT SYSTEMS & BUILDS.
            -- (m.h==meta.h and '' or '%s vf-command %s-crop h %d;'):format(command_prefix,label,meta.h)..
            (m.w==meta.w and '' or '%s vf-command %s-crop w min(iw,%d);'):format(command_prefix,label,meta.w)..  --w=out_w=width  EXCESSIVE vf-command CAUSES LAG.  SPELLING OUT ALL COORDINATES IN FULL MAY BE MORE VERSATILE OVER DIFFERENT SYSTEMS & BUILDS.
            (m.h==meta.h and '' or '%s vf-command %s-crop h min(ih,%d);'):format(command_prefix,label,meta.h)..
            (m.x==meta.x and '' or '%s vf-command %s-crop x %d;'):format(command_prefix,label,meta.x)..
            (m.y==meta.y and '' or '%s vf-command %s-crop y %d;'):format(command_prefix,label,meta.y)..
        ''
    m.w,m.h,m.x,m.y,m.time_pos = meta.w,meta.h,meta.x,meta.y,time_pos  --meta→m  MEMORY TRANSFER. 
    
    if command~='' then mp.command(command) end
    if not auto then timers.auto_delay:kill() end 
end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----A FUTURE VERSION MIGHT CROP WITHOUT CHANGING ASPECT (~EQUIVALENT TO AUTO-ZOOM). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT.
----ALTERNATIVE FILTERS:
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, FOR yuv420p HALF-PLANES.
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.

