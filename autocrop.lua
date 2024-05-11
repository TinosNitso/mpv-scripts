----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-CROP.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask TOO.

options={
    auto                  = true,  --IF false, CROPS OCCUR ONLY on_toggle & @playback-restart. 
    auto_delay            =   .5,  --ORIGINALLY 4 SECONDS.  
    detect_limit          =   30,  --ORIGINALLY "24/255".  CAN INCREASE detect_limit FOR VARIOUS TRACKS, & lavfi-complex OVERLAY.
    detect_round          =    1,  --ORIGINALLY 2.  cropdetect DEFAULT=16.
    detect_min_ratio      =  .25,  --ORIGINALLY 0.5.
    suppress_osd          = true,  --ORIGINALLY false.
    -- ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED.  SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
    key_bindings          = 'C c SHIFT+TAB',  --DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  CAN HOLD IN SHIFT TO RAPID TOGGLE WITH TAB.  TOGGLE DOESN'T AFFECT start & end.  
    key_bindings_pad      = '          TAB',  --TOGGLE SMOOTH-PADDING ONLY (BLACK BAR TABS).  INSTEAD OF "autopad.lua" THIS SCRIPT CAN TOGGLE PADDING, TOO. 
    toggle_on_double_mute =    .5,  --SECONDS TIMEOUT FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration       =    .4,  --SECONDS TO TOGGLE PADDING. REMOVE FOR INSTA-TOGGLE.  STRETCHES OUT BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING. 
    unpause_on_toggle     =   .12,  --DEFAULT=.1 SECONDS.  SOME FRAMES ARE ALREADY DRAWN IN ADVANCE. DOESN'T APPLY TO is1frame. 
    TOLERANCE             = {.05,time=10},  --DEFAULT={0}.  INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    MAINTAIN_CENTER       = {0,0},  --{TOLERANCE_X,TOLERANCE_Y}  DOESN'T APPLY TO JPEG.  {0,0} MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    detector              = 'cropdetect=limit=%s:round=%s:reset=1',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1'  %s,%s = detect_limit,detect_round  reset>0.
    options_image         = {detector='bbox=min_val=%s',detect_limit=30,detect_min_ratio=.1},  --DEFAULT={detector='bbox=%s'}  OVERRIDES FOR IMAGES.   bbox ALSO ACTS AS alpha OVERRIDE. TRANSPARENT VIDEO CAUSES A cropdetect BUG.  
    USE_INNER_RECTANGLE   = true,  --AGGRESSIVE CROP-FLAG. BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS.  COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO      = true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS. DEFAULT IGNORES EXCESSIVE detect_crop.
    -- crop_no_vid        = true,  --crop ABSTRACT VISUALS TOO (PURE lavfi-complex).
    -- msg_log            = true,  --UNCOMMENT TO MESSAGE MPV LOG. FILLS THE LOG.
    -- meta_osd           =    1,  --SECONDS. UNCOMMENT TO DISPLAY ALL detector METADATA.
    -- format             =  'yuva420p',  --FINAL pixelformat. UNCOMMENT FOR TRANSPARENT PADDING.
    -- pad_color          =    'MAROON',  --DEFAULT BLACK. UNCOMMENT FOR MAROON BARS. 'BLACK@0' FOR TRANSPARENCY (ALSO SET format).  PURPLE, DARKGRAY & WHITE ARE ALSO NICE.  THIS COULD BE REPLACED WITH EXTRA x:y OPTIONS, LIKE WHETHER TO pad FROM THE CENTER OR TOP.
    -- toggle_clip        =    '(1-cos(PI*%s))/2',  --DEFAULT='%s'=LINEAR_IN_TIME  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION BTWN aspect RATIOS. DOMAIN & RANGE BOTH [0,1].  LINEAR MAY BE SUPERIOR BECAUSE A SINE WAVE IS 57% SLOWER (OR FASTER, FOR THE SAME toggle_duration). MAX GRADIENT PI/2=1.57.
    -- dimensions         = {w=1680,h=1050,par=1},  --DEFAULT={w=display-width,h=display-height,par=osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO}  THESE ARE OUTPUT PARAMETERS. THE TRUE ASPECT-TOGGLE ACCOUNTS FOR BOTH PAR_IN & PAR_OUT, VALID @FULLSCREEN.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW DISPLAY w,h,par @file-loaded, SO OVERRIDE IS REQUIRED.  CAN TAPE MEASURE LCD (OR PROJECTOR) SCREEN TO DETERMINE par.
    options               = ''  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.  main.lua HAS MORE options.
        ..'   osd-font-size=16  geometry=50%  image-display-duration=inf '  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  duration=inf FOR IMAGES.
    ,
    limits={  --NOT CASE SENSITIVE. DON'T FORGET COMMAS! CAN ALSO USE END OF YOUTUBE URL.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS. STARTING & ENDING CREDITS ARE EASIER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ----["path-substring"]={start,end,detect_limit}={SECONDS,SECONDS<0,number} (OR nil).  detect_limit IS FINAL OVERRIDE & MUST BE NAMED.  start & end MAY ALSO BE 'PERCENTAGES'.
        ["We are army of people - Red Army Choir"]={detect_limit=64},
        [  "День Победы."]={4,-13},                        --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7}, --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        ["Megadeth Sweating Bullets Official Music Video"]={0,-5},
        
    },
}
o=options  --ABBREV.
require 'mp.options'.read_options(o)  --OPTIONAL?

for opt,val in pairs( {key_bindings='C',key_bindings_pad='',toggle_on_double_mute=0,toggle_duration=0,unpause_on_toggle=.1,options_image={detector='bbox=%s'},MAINTAIN_CENTER={},TOLERANCE={0},detector='cropdetect=limit=%s:round=%s:reset=1',dimensions={},pad_color='',toggle_clip='%s',options='',limits={},} )
do o[opt] = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true  
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM. 
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not val then break    end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

command_prefix      = o.suppress_osd and 'no-osd' or ''
osd_par,label       = 1,mp.get_script_name()  --m=METADATA MEMORY.  label=autocrop 
m,aspects = {},{}
function start_file()  --ESTABLISH limits.
    p,limits        = {},{} --RE-INITIALIZE TABLES. p=PROPERTIES.
    for  property in ('path start end'):gmatch('[^ ]+') 
    do p[property]  = mp.get_property(property) end  --property CALLS.
    p.path          = (p.path):lower()  --NOT CASE SENSITIVE.  
    for key,val in pairs(o.limits) do if (p.path):find((key):lower(),1,1)  -- 1,1 = STARTING_INDEX,EXACT_MATCH  
        then limits = val  
            break end end
    limits[1]       = limits[1] or limits.start
    limits[2]       = limits[2] or limits['end']
    
    if limits[1] and ('none 0%'):find(p.start,1,1)          then mp.set_property('start',limits[1]) end  --SET start IF 0.  SIMPLER THAN seeking OR TRIMMING TIMESTAMPS.  ("%" IS MAGIC)
    if limits[2] and (p['end']=='none' or p['end']=='100%') then mp.set_property('end'  ,limits[2]) end   
end
mp.register_event('start-file',start_file)
mp.register_event('end-file',function() for property in ('start end'):gmatch('[^ ]+') do mp.set_property(property,p[property]) end end)  --FOR MPV PLAYLISTS, OR ELSE NEXT TRACK STARTS WRONG.

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function file_loaded() --ALSO @alpha, @vid & @osd-par. event@file-loaded.  MPV REQUIRES EXTRA .1s TO DETECT alpha & osd-par. 
    v        = mp.get_property_native('current-tracks/video') or {}
    v_params = mp.get_property_native('video-params') 
    
    if not v_params or not (v.id or o.crop_no_vid) then return end  --RAW AUDIO ENDS HERE, & lavfi-complex MAY NOT NEED CROPPING.
    if not W then  _,error_ffmpeg =    mp.command(('%s vf pre    @%s:lavfi-format'):format(command_prefix,label)) end  --~W MEANS ONCE ONLY.  OLD FFMPEG DETECTION. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING DURING TESTING. SO DETECT ERROR USING WHAT AMOUNTS TO A NULL-OP.
    if not W and not error_ffmpeg then mp.command(('%s vf remove @%s             '):format(command_prefix,label)) end  --ONLY remove IF ABLE TO.
    
    lavfi_complex,insta_pause = mp.get_opt('lavfi-complex'),not pause
    target           = error_ffmpeg and '' or target  --ERROR MEANS NO TARGET (OLD MPV).
    o.format         = o.format or error_ffmpeg  and 'yuv420p' or ''  --OVERRIDE  OR  OLD FFMPEG  OR  OUT=IN.
    par_out          = o.dimensions.par or osd_par
    par_ratio        = par_out/(v['demux-par'] or v_params.par or 1)  --PAR_OUT/PAR_IN  PAR_IN MAYBE SPECIFIED BY DEMUXER OR OTHERWISE (JPEG OR lavfi-complex-setsar/setdar) OR ELSE 1.
    aspect_in        = v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect  --TAKEN FROM EITHER DEMUXER OR OTHERWISE (JPEG & lavfi-complex).
    aspect           = aspect_in/par_ratio  --ABBREVIATE aspect=aspect_out.  DEFAULT GRAPH STATE IS OFF (PADDED).
    W                = o.dimensions.w or o.dimensions[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --OVERRIDE  OR  display  OR  VIDEO   DIMENSIONS. v_params DEPEND ON lavfi-complex.
    H                = o.dimensions.h or o.dimensions[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h']
    W2,H2            = round(W,2),round(H,2)  --EVEN DIMENSIONS ARE NEEDED, EXCEPT @FINISH.
    aspects          = {OFF=aspect,ON=W2/H2} --OFF OR ON(FULL-SCREEN).  A CROP-ON IS A PAD-OFF, BUT I'VE MADE ON=FULL-SCREEN.
    pad_iw,pad_ih    = round(math.min(W2,H2*aspect),2),round(math.min(W2/aspect,H2),2)  --pad INPUT_WIDTH,INPUT_HEIGHT.
    m                = {vid=v.id,toggle_duration=o.toggle_duration}  --RAPID TOGGLING REQUIRES MEMORY OF PRIOR DURATION. COULD BE 0 WHEN PAUSED (CAN VARY ON/OFF BTWN TOGGLES).
    detect_format    = error_ffmpeg and 'yuv420p' or ''  --OLD FFMPEG  OR  NULL-OP.  REMOVES alpha.
    detect_limit     = limits.detect_limit or v.image and o.options_image.detect_limit or o.detect_limit
    detect_min_ratio =   v.image      and o.options_image.detect_min_ratio or o.detect_min_ratio
    detector         = ((v.image  or v_params.alpha) and o.options_image.detector or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USE bbox.
    loop             =   v.image  and not lavfi_complex
    is1frame         = v.albumart and not lavfi_complex  --REQUIRE GRAPH REPLACEMENT IF albumart & ~complex. 
    MAINTAIN_CENTER  = loop and {}  or o.MAINTAIN_CENTER --RAW JPEG CAN MOVE CENTER. 
    auto             = not is1frame and o.auto  --~auto FOR is1frame.
    if insta_pause then mp.set_property_bool('pause',true) end  --PREVENTS EMBEDDED MPV FROM SNAPPING, & BUGFIX FOR is1frame.  HOWEVER lavfi-complex DOESN'T NEED IT.
    
    
    mp.command(('%s vf pre @%s-pad:lavfi=[format=%s,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s,scale=%d:%d,setsar=1]'):format(command_prefix,label,o.format,W2,H2,o.pad_color,W,H))  --FINAL scale ALMOST ALWAYS NULL-OP. W,H MAY BE ODD, BUT pad=ow:oh MUST BE EVEN.
    mp.command(('%s vf pre @%s-scale-down:scale=w=%d:h=%d:flags=bilinear:eval=frame'):format(command_prefix,label,pad_iw,pad_ih))  --PRE-pad DOWN-SCALER. NULL-OP (USUALLY), WHEN ON. 
    mp.command(('%s vf pre @%s-scale:scale=w=%d:h=%d'):format(command_prefix,label,W2,H2))  --REQUIRED BECAUSE INPUT OR OUTPUT SIZE SHOULD BE CONSTANT.  THIS ALSO SEPARATES crop & scale COMMANDS FOR OLD MPV.
    mp.command(('%s vf pre @%s:lavfi=[format=%s,%s,crop=iw:ih:0:0:1:1]'):format(command_prefix,label,detect_format,detector))   --MAIN GRAPH. 
    
    ----lavfi      = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS.  %d,%s = DECIMAL_INTEGER,string.  2 CHAINS + 2 SCALERS + JPEG-CHAIN, PLACED IN REVERSE ORDER. 
    ----loop       = loop:size  ( >=-1 : >0 )  IS THE START FOR IMAGES (1fps).
    ----fps        = fps:start_time  (SECONDS)  DEFAULT=25  start_time SETS STARTPTS FOR JPEG (--start).  THIS USES ~5% CPU UNTIL USER HITS PAUSE. FOR SMOOTH PADDING ON JPEG.
    ----format     = pix_fmts  IS THE START FOR VIDEO. USUALLY BLANK (NULL-OP).  BUGFIX FOR alpha ON OLD FFMPEG (.snap & .flatpak).  BUT IT ALSO ENABLES TRANSPARENT BLACK BARS (o.format).
    ----cropdetect = limit:round:reset  DEFAULT=24/255:16:0  round:reset ARE IN PIXELS:FRAMES. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION.  skip INCOMPATIBLE WITH FFMPEG-v4. CAN SET skip=0 FOR FASTER STARTUP (2 BY DEFAULT).  alpha TRIGGERS BAD PERFORMANCE BUG.
    ----bbox       = min_val  DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH, BUT THAT COMBINES DEFICITS.
    ----crop       = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale      = w:h:flags:...:eval  DEFAULT=iw:ih:bicubic:...:init  dst_format CAN ALSO BE SET (ALTERNATIVE TO format).  bilinear WAS ONCE DEFAULT IN OLD MPV & IS FASTER @frame DOWN-SCALING, BUT SHOULD BE AVOIDED.  REMOVE IT IF LAG ISN'T A CONCERN (COULD BE ANOTHER OPTION).
    ----pad        = w:h:x:y:color  DEFAULT=0:0:0:0:BLACK   0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar     = sar  DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO=1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT (IN REALITY OUTPUT IS DIFFERENT).  ALSO PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart. 
    
    for _,filter in pairs(mp.get_property_native('vf')) do if filter.label=='loop'
        then mp.command(command_prefix..' vf remove @loop')  --remove @loop, AT CHANGE IN vid. COULD ALSO BE THERE DUE TO OTHER SCRIPTS.  MPV REPORTS ERROR IF NOT PRESENT. ONLY CHECK AFTER INSERTING EVERYTHING ELSE.
            break end end 
    if loop then mp.command(('%s vf pre @loop:lavfi=[loop=-1:1,fps=25:%s]'):format(command_prefix,mp.get_property_number('time-pos'))) end
    
    
    if insta_pause then mp.set_property_bool('pause',false) end 
    on_toggle_pad()  --TOGGLE ON, BY DEFAULT.  COULD BE A PROBLEM FOR MPV PLAYLIST: OFF@end-file → ON@NEXT-TRACK.
    timers.auto_delay:resume()  --auto_delay (OR detect_seconds) NEEDED FOR INITIAL DETECTION (is1frame).
end
mp.register_event('file-loaded',file_loaded)
mp.observe_property('vid','number',function(_,vid) if vid and m.vid and m.vid~=vid then file_loaded() end end)  --RELOAD IF vid CHANGES. vid=nil IF LOCKED BY lavfi-complex.  UNFORTUNATELY EMBEDDED MPV SNAP EVERY TIME.  AN MP3 OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED CROPPING (& HAVE RUNNING audio). 
mp.observe_property('pause','bool',function(_,paused) pause=paused end)  --MORE EFFICIENT TO observe.

function playback_restart() --GRAPH STATES ARE RESET, UNLESS is1frame (GEOMETRY PERMANENT). 
    if not is1frame then m.w,m.h,m.x,m.y,m.aspect = nil,nil,nil,nil,nil  --FORCE ALL vf-COMMANDS.  is1frame WOULD SUFFER INFINITE LOOP: GRAPH REPLACEMENTS CAUSE playback-restart.
        toggle_duration = o.toggle_duration  --FORCE SMOOTH PADDING EVEN IF PAUSED. OTHERWISE IF nil & PAUSED WOULD INSTA-SNAP PADDING. 
        aspect          = aspect==aspects.ON and aspects.OFF or aspects.ON  --ON←→OFF  FORCE pad TOGGLE BACK TO CURRENT STATE.
        on_toggle_pad()
        detect_crop() end  --RESUMES TIMER.
end
mp.register_event('playback-restart',playback_restart)

function on_osd_par(_,par) --ASSUME osd-par=DISPLAY PIXEL ASPECT RATIO (THE REAL ASPECT OF EACH PIXEL).
    osd_par=par and par~=0 and par or 1
    if osd_par~=1 then file_loaded() end  --RELOAD @osd-par.
end
mp.observe_property('osd-par','number',on_osd_par)  --0@file-loaded, 1@playback-restart. BUT ON EXPENSIVE SYSTEM MAYBE ~1.

function on_v_params(_,v_params)  --video-params ALMOST NEVER CHANGE.
    if v_params
    then max_w,max_h = v_params.w,v_params.h
         par_ratio   = osd_par/(v['demux-par'] or v_params.par or 1)  --COULD CONCEIVABLY CHANGE.
         aspects.OFF = (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect)/par_ratio
         if v_params.alpha or aspect~=aspects.OFF and aspect~=aspects.ON 
         then file_loaded() end end  --RELOAD @alpha & IF aspect INVALID.
end 
mp.observe_property('video-params','native',on_v_params)  

function on_toggle(mute)      --TOGGLES BOTH crop & PADDING.
    if not aspect then return --NO TOGGLE FOR RAW AUDIO.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE TOGGLE.  
    else OFF,insta_unpause = not OFF,pause  --OFF SWITCH (FOR CROPS ONLY).  insta_unpause FOR o.unpause_on_toggle.
        if OFF then apply_crop({ x=0,y=0, w=max_w,h=max_h }) end --NULL crop, IF VIDEO.
        detect_crop()
        on_toggle_pad() end  --PADDING TOO.
end
for key in (o.key_bindings):gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function on_toggle_pad()  --PAD TOGGLE ONLY - NO CHANGE IN crop.  PADS BLACK BARS WITHOUT CHANGING [vo] scale. VALID @FULLSCREEN.  A DIFFERENT VERSION COULD USE osd-dimensions (ON-SCREEN-DISPLAY WINDOW SIZE).
    aspect            = aspect==aspects.ON and aspects.OFF or aspects.ON  --→ON IF nil.
    m.aspect          = m.aspect or aspects.OFF --ASSUME OFF IF nil.  GRAPH RESETS AFTER playback-restart.
    pad_time          = mp.get_property_number('time-pos')+.1  --RAPID TOGGLING SMOOTHER WITH +.1s.
    m.pad_time        = m.pad_time or pad_time  --INITIALIZE IF MEMORY BLANK.
    pad_time          = pad_time-math.max(0,m.toggle_duration-math.max(0,pad_time-m.pad_time))  --REMAINING_DURATION_OF_PRIOR_TOGGLE=DURATION-TIME_SINCE_LAST_TOGGLE    SUBTRACT REMAINING_DURATION, FOR CURRENT TOGGLE.  (UP → DOWN→UP.) 
    toggle_duration   = toggle_duration or pause and 0 or o.toggle_duration  --0 ON PAUSED TOGGLE.  NEW toggle_duration, UNLESS SET @playback-restart.
    clip              = ('clip((t-%s)/(%s),0,1)'):format(pad_time,toggle_duration) --duration=0 ALSO VALID (insta_unpause).  A FUTURE VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
    clip              = (o.toggle_clip):gsub('%%s',clip)    --NON-LINEAR clip.  [0,1] DOMAIN & RANGE.  TIME EXPRESSION FOR SMOOTH-PADDING.  0=INITIAL, 1=FINAL.  A SINE WAVE PROGRESSION.  
    m.pad_iw,pad_iw,m.pad_ih,pad_ih   = round(math.min(W2,H2*m.aspect),2),round(math.min(W2,H2*aspect),2),round(math.min(W2/m.aspect,H2),2),round(math.min(W2/aspect,H2),2)  --pad GRAPH WIDTHS & HEIGHTS: PRIOR(MEMORY)→TARGETS.
    m.aspect,m.pad_time               = aspect,pad_time     --MEMORY TRANSFER ENABLES DOUBLE-BACK (UP→DOWN).
    m.toggle_duration,toggle_duration = toggle_duration,nil --→nil TO HANDLE PAUSED @playback-restart.
    
    if is1frame then mp.command(('%s vf pre @%s-scale-down:scale=w=%d:h=%d'):format(command_prefix,label,pad_iw,pad_ih))
    else apply_pad()
        if error_ffmpeg then for N=1,8 do mp.add_timeout(2^N/100,apply_pad) end end  --OLD FFMPEG REQUIRES REPEATING apply_pad COMMANDS. BUT THAT CAUSES LAG.  CAN USE EXPONENTIAL TIMEOUTS (.02 .04 .08 .16 .32 .64 1.28 2.56)s, LIKE A SERIES OF DOUBLE-TAPS (FOR MACOS-VIRTUALBOX.)
        ----insta_unpause REQUIRED HERE.
    end
end
for key in (o.key_bindings_pad):gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_pad_'..key,on_toggle_pad) end

function apply_pad()  --TARGETED scale COMMANDS pad EITHER HORIZONTALLY OR VERTICALLY.  
    if error_ffmpeg or m.pad_iw~=pad_iw  --CHECK COMMAND NEEDED, FIRST.
    then mp.command(('%s vf-command %s-scale-down width  round((%d+%d*(%s))/2)*2'):format(command_prefix,label,m.pad_iw,pad_iw-m.pad_iw,clip)) end  --CLIPS BTWN PRIOR pad_iw & NEXT pad_iw.  FFMPEG SHOULD CALCULATE ONLY EVEN NUMBERS.
    if error_ffmpeg or m.pad_ih~=pad_ih
    then mp.command(('%s vf-command %s-scale-down height round((%d+%d*(%s))/2)*2'):format(command_prefix,label,m.pad_ih,pad_ih-m.pad_ih,clip)) end
end 

function detect_crop()  --FOR RAW AUDIO TOO.  USUALLY LOOPS EVERY HALF A SECOND.
    timers.auto_delay:resume()  --~auto KEEPS CHECKING UNTIL apply_crop.
    if OFF or not max_w  then return end  --AWAIT v_params.

    min_w,min_h   = max_w*detect_min_ratio,max_h*detect_min_ratio    --MAY VARY @vid.
    meta,time_pos = mp.get_property_native('vf-metadata/'..label),mp.get_property_native('time-pos')  --Get the metadata.  NEAREST MILLISECOND.  
    
    if not meta then if o.msg_log then mp.msg.error("No crop metadata.")    --Verify the existence of metadata.  HAPPENS RARELY IF seeking NEAR end-file. SOMETIMES IT'S {} WHEN PAUSED, WHICH FAILS THE NEXT TEST.
            mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?") end
        return  
    elseif o.meta_osd then mp.osd_message(mp.get_property_osd('vf-metadata/'..label),o.meta_osd) end  --DISPLAY COORDS FOR 1 SEC. THIS BUGS OUT IF ~meta.
    
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

timers={  --CARRY OVER IN MPV PLAYLIST. 
    auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop),
    mute      =mp.add_periodic_timer(o.toggle_on_double_mute,function()end),  --FOR on_toggle.
    pause     =mp.add_periodic_timer(o.unpause_on_toggle    ,function() mp.set_property_bool('pause',true) end),  --pause TIMER PAUSES.
}
timers.mute .oneshot=true
timers.pause.oneshot=true 
for _,timer in pairs(timers) do timer:kill() end

function apply_crop(meta) 
    if not target 
    then _,error_input = mp.command(('%s vf-command %s x 0 crop'):format(command_prefix,label)) end  --NULL-OP TO ACQUIRE TARGET. ERROR PRODUCED BY MPV NOT FFMPEG.
    target             = target or error_input and ''  or 'crop'  --OLD MPV OR NEW. MPV v0.37.0+ SUPPORTS TARGETED COMMANDS.
    if is1frame 
    then insta_pause   = not pause  --GRAPH REPLACEMENTS insta_pause DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
        if insta_pause then mp.set_property_bool('pause',true ) end
        mp.command(('%s vf pre @%s:lavfi=[format=%s,%s,crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1]'):format(command_prefix,label,detect_format,detector,meta.w,meta.h,meta.x,meta.y))  --detector NEEDED FOR TOGGLE.  min NEEDED FOR RARE BUG DUE TO INTERFERENCE FROM OTHER SCRIPT/S (meta.w>iw AT SOME POINT IN TIME).
        if insta_pause then mp.set_property_bool('pause',false) end       
    else for whxy in ('w h x y'):gmatch('[^ ]') do if m[whxy]~=meta[whxy]  --EXCESSIVE vf-command CAUSES LAG.  
            then mp.command(('%s vf-command %s %s %d %s'):format(command_prefix,label,whxy,meta[whxy],target)) end end
        if insta_unpause then mp.set_property_bool('pause',false)  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME). 
            timers.pause:resume() end end
    
    m.w,m.h,m.x,m.y          = meta.w,meta.h,meta.x,meta.y --meta→m  MEMORY TRANSFER. 
    m.time_pos,insta_unpause = time_pos,nil  --insta_unpause ONLY EVER ACTIVATED BY TOGGLE.
    if not auto then timers.auto_delay:kill() end 
end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0(.7z .exe v3) v0.37.0(.app) v0.36.0(.exe .app .flatpak .snap v3) v0.35.1(.AppImage)  ALL TESTED.
----FFMPEG v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS OFTEN BUILT WITH FFMPEG v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----A FUTURE VERSION MIGHT CROP WITHOUT CHANGING ASPECT (EQUIVALENT TO AUTO-zoom). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT.
----BUG: CAN'T UNPAUSE PAUSED JPEG IN SMPLAYER-v23.12. IT TRIGGERS GRAPH RESET ON PAUSE. THAT'S ACTUALLY AN ADDED FEATURE WHICH RESETS THE GRAPHS WHEN USER HITS SPACEBAR. v23.6 (JUNE RELEASE) & MPV ALONE DON'T RESET ON PAUSE. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" AFTER "set pause yes".

----ALTERNATIVE FILTERS:
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.

