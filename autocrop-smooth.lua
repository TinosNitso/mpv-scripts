----THIS VERSION HAS BOTH SMOOTH-CROP & PROPER aspect TOGGLE. BUT IT USES TOO MUCH CPU WHEN COMBINED WITH OTHER SCRIPTS.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask TOO.
----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop. CAN CROP RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO SMOOTH-TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----SMOOTH-CROPS USING A MAGNIFIED NEGATIVE overlay. AS SMOOTH AS STRETCHING PARCHMENT.

options={
    auto                  =true,  --IF false, CROPS OCCUR ONLY on_toggle & @playback-restart. 
    auto_delay            = .5,   --ORIGINALLY 4 SECONDS.  
    detect_limit          = 30,   --ORIGINALLY "24/255".  lavfi-complex OVERLAY MAY INTERFERE ON SIDES (CAN INCREASE detect_limit).
    detect_round          =  1,   --ORIGINALLY 2.  cropdetect DEFAULT=16.
    detect_min_ratio      =.25,   --ORIGINALLY 0.5.
    suppress_osd          =true,  --ORIGINALLY false.
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
    key_bindings          ='C c J j', --DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). m IS mute (IN DVORAK TOO) SO CAN DOUBLE-PRESS m. m&m DOUBLE-TAP MAYBE OUGHT TO BE automask, BUT autocrop IS MORE FUNDAMENTAL. TOGGLE DISABLES FINAL SUBTRACTION, TOO!
    toggle_on_double_mute = .5,   --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. ONLY WORKS IN SMPLAYER IF THERE'S audio TO mute (CAN'T toggle ON RAW JPEG).
    unpause_on_toggle     = .1,   --DEFAULT=.1 SECONDS UNPAUSE TO apply_crop, UNLESS is1frame. SILENT. MAY CAUSE REPEATED UNPAUSES IF GEOMETRY CHANGES OUTSIDE TOLERANCE. PAUSED vf-command REQUIRES SOME FRAME-STEPPING BECAUSE FRAMES ARE ALREADY DRAWN IN ADVANCE. STILL PERFORMS BETTER THAN GRAPH REPLACEMENT, DEPENDING.
    detect_limit_image    = 32,   --INTEGER 0→255, FOR JPEG & albumart.  ONLY INTEGERS FOR bbox. 
    detect_min_ratio_image=  0,   --OVERRIDE FOR image.
    TOLERANCE             =.05,   --DEFAULT=0. INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME        = 10,   --DEFAULT=10 SECONDS. IRRELEVANT IF TOLERANCE=0.
    MAINTAIN_CENTER       ={0,0}, --{TOLERANCE_X,TOLERANCE_Y}. APPLIES TO video (NOT image). 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK (UNLESS is1frame). A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE   =true,  --BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS. COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    detector              ='cropdetect=limit=%s:round=%s:reset=1:skip=0',--DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'  %s=string SUBSTITUTIONS. reset>0.
    detector_image        ='bbox=min_val=%s',  --DEFAULT='bbox=min_val=%s'  ALSO detector_alpha (FOR TRANSPARENT VIDEO).  %s=detect_limit_image OR OVERRIDE.  alpha CAUSES A cropdetect BUG.  
    -- meta_osd           =  1,   --SECONDS. UNCOMMENT TO DISPLAY ALL detector METADATA.
    -- USE_MIN_RATIO      =true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS. DEFAULT CANCELS EXCESSIVE crop.
    -- msg_log            =true,  --UNCOMMENT TO MESSAGE MPV LOG. FILLS THE LOG.
    -- crop_no_vid        =true,  --crop ABSTRACT VISUALS TOO. BY DEFAULT NO CROPPING PURE lavfi-complex, EXCEPT FOR TIME limits.
    -- scale              ={w=1680,h=1050}, --DEFAULT=display OR [vo]. EVEN NUMBERS ONLY FOR MPV v0.38.0.  ABSOLUTE scale SIMPLIFIES TRUE aspect TOGGLE (ONLY WORKS @scale).
    crop_time             =.5,    --DEFAULT=.5 SECONDS. TIME TO STRETCH OUT BLACK BARS, BY SMOOTHLY VARYING ASPECT. TOO FAST & IT HAS TOO MUCH ENERGY. ALSO TIME-STEP OF TOGGLE WHEN PAUSED.
    options               =' '  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.  main.lua HAS MORE options.
        ..'  osd-font-size=16 geometry=50% image-display-duration=inf'  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  duration=inf FOR IMAGES.
    ,
    limits={  --NOT CASE SENSITIVE. ＂：⧸  ⧹｜＂=":/ \|"  (DOUBLE-SPACE=SPACE)
      --["media-title"]={time_pos,time_remaining,detect_limit,find}={SECONDS,SECONDS,number,boolean}(OR nil).  TIMES ARE BOTH LOWER BOUNDS IN SECONDS. detect_limit IS FINAL OVERRIDE.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS, WHICH CAN BE DELETED. STARTING & ENDING CREDITS ARE EASIER TO CROP THAN INTERMISSION. INTERMISSION SUB-CLIPS WOULD BE ANOTHER LEVEL OF AUTO-seek. 
        ["Katyusha"]={4,4,find=false},  --find IMPLIES SUBSTRING SEARCH. ASSUMED true UNLESS false (nil MEANING true).  ANOTHER exact FLAG COULD BE CONFUSING BECAUSE ＂＂="" ETC. 
        ["We are army of people - Red Army Choir"]={detect_limit=64},
        [  "День Победы"]={4,13},                          --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7}, --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
    },
}
require 'mp.options'.read_options(options)  --OPTIONAL?
o         =options  --ABBREV.
for opt,val in pairs( {key_bindings='C',toggle_on_double_mute=0,unpause_on_toggle=.1,detect_limit_image=o.detect_limit,detector='cropdetect=limit=%s:round=%s:reset=1:skip=0',detector_image='bbox=min_val=%s',MAINTAIN_CENTER={},TOLERANCE=0,TOLERANCE_TIME=10,scale={},crop_time=.5,options='',limits={},} )
do o[opt] =o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options =(o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true 
do    opt =o.options()  
      find=opt  and (opt):find('=')  --RIGOROUS FREE-FORM. 
      val =find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
      opt =find and (opt):sub(0,find-1) or opt
      if not (opt and val) then break end
      mp.set_property(opt,val) end  --mp=MEDIA-PLAYER
command_prefix = o.suppress_osd and 'no-osd' or ''
o.detector     = mp.get_property('ffmpeg-version'):sub(0,2)=='4.' and o.detector:gsub(':skip=%d+','') or o.detector  --FFmpeg-v4 INCOMPATIBLE WITH skip.
m,label        = {},mp.get_script_name()  --m=METADATA MEMORY.  label=autocrop 

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil. PRECISION LIMITER BECAUSE overlay LACKS PRECISION BEYOND 4p. DUE TO yuva420p.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function file_loaded(event) --ALSO @alpha & @vid.  THAT IS TRANSPARENCY & TRACK-ID.  alpha=nil ASSUMED @file-loaded. MPV REQUIRES EXTRA .1s TO DETECT ALL video-params. 
    insta_pause = insta_pause or not pause  --PREVENTS EMBEDDED MPV FROM SNAPPING, & HELPS WITH IMAGES.  →nil@playback-restart.
    mp.set_property_bool('pause',true)
    v           = mp.get_property_native('current-tracks/video') or {}
    W           = o.scale.w or o.scale[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display) OR ([vo] DIMENSIONS)
    H           = o.scale.h or o.scale[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h']
    W,H         = round(W,2),round(H,2)  --MPV v0.37.0+ HAS ODD BUG.
    if W  --NOT RAW AUDIO.
    then aspect = OFF and (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect) or W/H  --SAME AS @apply_crop.
        mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:BLACK:frame,setsar=1]')  --THIS GRAPH GOES IN FIRST TO STOP EMBEDDED MPV SNAPPING.  IF OFF, PADS AN EXTRA PAIR OF BLACK BARS. SEPARATE FROM MAIN GRAPH FOR OLD MPV (AMBIGUOUS w & h COMMANDS).
            :format( command_prefix,label,round(math.min( W,H*aspect)),round(math.min(W/aspect,H)),W,H          )) end

    
    if event then limits,media_title = {},mp.get_property('media-title'):lower():gsub('[ ]+',' '):gsub('＂','"'):gsub('：',':'):gsub('⧸','/'):gsub('⧹','\\'):gsub('｜','|')  --event IMPLIES NEW FILE.  ＂：⧸  ⧹｜＂=":/ \|"  NOT CASE SENSITIVE.
        for title,params in pairs(o.limits) do title=(title)            :lower():gsub('[ ]+',' '):gsub('＂','"'):gsub('：',':'):gsub('⧸','/'):gsub('⧹','\\'):gsub('｜','|')
            if media_title==title or params.find~=false and (media_title):find(title,0,true)  -- 0,true = STARTING_INDEX,EXACT_MATCH  params ASSUMED TO BE table.  path/URL COULD ALSO BE SEARCHED.
            then limits={time_pos      =params.time_pos       or params[1],  
                         time_remaining=params.time_remaining or params[2],
                         detect_limit  =params.detect_limit   or params[3],  --FINAL OVERRIDE.
                    } end end end 
    if not OFF and limits.time_pos and mp.get_property_number('time-pos')<limits.time_pos+0   --+0 CONVERTS→number & IS EASIER TO READ THAN RE-ARRANGING INEQUALITIES.
    then mp.command(('%s seek %s absolute exact'):format(command_prefix,limits.time_pos)) end --ONLY seek FORWARDS. MORE RIGOROUS THAN SETTING time-pos DIRECTLY.  SEEKING IS MORE ELEGANT THAN TRIMMING TIMESTAMPS, FOR SPACETIME CROPPING. CROPS AUDIO TOO.
    timers.auto_delay:resume()  --FOR RAW AUDIO TOO.  is1frame REQUIRES SMALL DELAY FOR INITIAL DETECTION (RELIABILITY ISSUE).
    if not W or not (v.id or o.crop_no_vid) then if insta_pause then mp.set_property_bool('pause',false) end  --lavfi-complex MAY NOT NEED CROPPING. UNPAUSE RAW AUDIO.
        insta_pause=nil
        return end  
    
    detect_min_ratio=v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    is1frame        =v.image      and not mp.get_opt('lavfi-complex')  --REQUIRE GRAPH REPLACEMENT IF image & ~complex. 
    MAINTAIN_CENTER =is1frame     and {} or o.MAINTAIN_CENTER  --RAW JPEG CAN MOVE CENTER. GIF IS ~image. 
    auto            =not is1frame and o.auto   --NO auto FOR is1frame, BECAUSE audio GLITCHES ON GRAPH REPLACEMENT.
    m               ={vid=v.id,aspect=aspect}
    detect_limit    =limits.detect_limit or v.image and o.detect_limit_image or o.detect_limit
    detector        =((v.image or v_params.alpha) and o.detector_image or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USES bbox.
    
    
     mp.command(('%s vf pre @%s-crop:lavfi=[scale=%d:%d:eval=frame,crop=%d:%d:0:0:1:1]')  --CONSTANT crop, AFTER SCALED NEGATIVE overlay.
         :format( command_prefix,label,           W ,H,                 W ,H           ))
     mp.command(('%s vf pre @%s:lavfi=[scale=round(iw/4)*4:round(ih/4)*4,%s,split,overlay]')
         :format( command_prefix,label,                                  detector          ))
    
    ----lavfi     =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPHS.  %d,%s = DECIMAL_INTEGER,string.  3 GRAPHS FOR BACKWARDS COMPATIBILITY. MPV-v0.37.0+ NEEDS ONLY 1 OR 2.
    ----cropdetect=limit:round:reset:skip  DEFAULT=24/255:16:0  reset & skip BOTH MEASURED IN FRAMES, round IN PIXELS. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION. skip INCOMPATIBLE WITH ffmpeg-v4. alpha TRIGGERS BAD PERFORMANCE BUG.
    ----bbox      =min_val  DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH FOR IMPROVED RELIABILITY, BUT UNNECESSARY & MAY INCREASE CPU USAGE.
    ----crop      =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
    ----scale     =w:h      DEFAULT=iw:ih  USING [vo] scale WOULD CAUSE EMBEDDED MPV TO SNAP @vid, SO USE display INSTEAD. EITHER WINDOW SNAPS IN, OR ELSE video SNAPS OUT.
    ----pad       =w:h:x:y:color:eval  DEFAULT=0:0:0:0:BLACK:init  0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar    =sar      DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO. PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart. MACOS REQUIRES sar (SEE ERRORS IN LOG). SHOULD BE 1 I THINK.
    ----split      CLONES video. THIS IS A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS. THERE IS NO WORKAROUND FOR HAVING TO MAGNIFY UP FIRST, SO PPL WITH CHEAP CPU MUST SUFFER LAG.
    ----overlay   =x:y DEFAULT=0:0 n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.
    

    if insta_pause then mp.set_property_bool('pause',false) end  --& AGAIN @playback-restart FOR WHEN MULTIPLE SCRIPTS SIMULTANEOUSLY insta_pause.
end
mp.register_event('file-loaded',file_loaded)
mp.observe_property('vid','number',function(_,vid) if vid and m.vid and m.vid~=vid then file_loaded() end end)  --RELOAD IF vid CHANGES. vid=nil IF LOCKED BY lavfi-complex. m.vid VERIFIES ALREADY LOADED.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED CROPPING (& HAVE RUNNING audio). 

function playback_restart() --vf-command RESET, UNLESS is1frame (GEOMETRY PERMANENT). 
    if insta_pause then mp.set_property_bool('pause',false) end
    insta_pause                       = nil
    if not target then _,error_string = mp.command(('%s vf-command %s x 0 overlay'):format(command_prefix,label))  --NULL-OP TO ESTABLISH TARGETS.
                       target_overlay = error_string and '' or 'overlay'
                       target_scale   = error_string and '' or 'scale' end
    if W and not is1frame then paused,m.time_pos,time_pos = pause,nil,mp.get_property_number('time-pos')  --m.time_pos=nil FORCES is_effective.  time-pos FOR apply_crop.
        detect_crop()  --IN CASE ~auto.
        apply_scale()  --FOR TOGGLE OFF WHILST seeking. NEEDS PADDING. SMPLAYER DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute.
        if paused then apply_crop(m) end end  --paused REQUIRES FRAME-STEPS TO RE-ESTABLISH PADDING.
end 
mp.register_event('playback-restart',playback_restart)

function on_v_params(_,video_params)  --MORE EFFICIENT TO observe.
    v_params    = video_params or {}  --MAYBE nil@lavfi-complex.
    max_w,max_h = v_params.w,v_params.h
    if v_params.alpha then file_loaded() end  --RELOAD @alpha.
end 
mp.observe_property('video-params','native',on_v_params)  
mp.observe_property('pause','bool',function(_,paused) pause=paused end)  --MORE EFFICIENT TO observe.

function on_toggle(mute)  --PADS BLACK BARS WITHOUT EVER CHANGING [vo] scale.  A MORE RIGOROUS VERSION COULD USE osd-dimensions (WINDOW SIZE). THIS ONE IS TRUE @FULLSCREEN.
    if not timers.mute then return  --STILL LOADING.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE TOGGLE.  
    else OFF,m.time_pos,insta_unpause = not OFF,nil,pause  --OFF SWITCH. ~m.time_pos FORCES is_effective. paused FOR unpause_on_crop.
        if W and OFF then apply_crop({ x=0,y=0, w=max_w,h=max_h }) end --NULL crop. W MEANS NOT RAW AUDIO (CAN TOGGLE limits).
        detect_crop() end  --IN CASE ~auto.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function detect_crop()  --USUALLY LOOPS EVERY HALF A SECOND.  MUST ALSO DETECT CROP FOR PURE AUDIO @FINAL LIMIT.
    if OFF then return
    elseif limits.time_remaining and (mp.get_property_number('time-remaining') or 0)<limits.time_remaining+0 
    then mp.command(command_prefix..' playlist-next force')   --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST.  THIS IS A TIME-CROP (LIKE apply_crop). SAFER THAN RE-APPENDING trim & atrim FILTERS USING main.lua.
         return 
    elseif not max_w or not auto and m.time_pos then return end  --~auto ONLY CROPS ONCE (& AGAIN @on_toggle & @playback-restart).
    
    meta,time_pos = mp.get_property_native('vf-metadata/'..label),mp.get_property_number('time-pos')  -- Get the metadata.
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
    then xNEW  ,yNEW        = math.max(meta.x1,meta.x2-meta.w,meta.x),math.max(meta.y1,meta.y2-meta.h,meta.y)
        meta.x2,meta.y2     = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y      = xNEW,yNEW
        meta.w ,meta.h      = meta.x2-meta.x,meta.y2-meta.y end
    if MAINTAIN_CENTER[1] 
    then xNEW               =math.min( meta.x , max_w-(meta.x+meta.w) )  --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW               =max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*MAINTAIN_CENTER[1] 
         then meta.x,meta.w = xNEW,wNEW end end
    if MAINTAIN_CENTER[2] 
    then yNEW               =math.min( meta.y , max_h-(meta.y+meta.h) )  --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW               =max_h-yNEW*2
         if hNEW-meta.h>hNEW*MAINTAIN_CENTER[2] 
         then meta.y,meta.h = yNEW,hNEW end end  --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
    min_w,min_h             = max_w*detect_min_ratio,max_h*detect_min_ratio  --MAY VARY @vid.
    if meta.w<min_w then if not o.USE_MIN_RATIO 
         then meta.w,meta.x = max_w,0  --NULL w
         else meta.w,meta.x = min_w,math.max(0,math.min(max_w-min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE w
    if meta.h<min_h then if not o.USE_MIN_RATIO 
         then meta.h,meta.y = max_h,0  --NULL h
         else meta.h,meta.y = min_h,math.max(0,math.min(max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE h

    if meta.w>max_w or meta.h>max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return  --IF w<0 IT'S LIKE A JPEG ERROR.
    elseif not (m.w and m.h and m.x and m.y) then m.w,m.h,m.x,m.y = max_w,max_h,0,0 end  --INITIALIZE 0TH crop AT BEGINNING.
    
    is_effective=not m.time_pos  --Verify if it is necessary to crop.                     PROCEED IF INITIALIZING.
        or math.abs(m.time_pos-time_pos)>o.TOLERANCE_TIME+0                             --PROCEED IF TIME CHANGES TOO MUCH,
            and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)              --  UNLESS ALL COORDS EXACTLY THE SAME.
        or math.abs(meta.w-m.w)>m.w*o.TOLERANCE or math.abs(meta.h-m.h)>m.h*o.TOLERANCE --PROCEED IF OUTSIDE TOLERANCE.
        or math.abs(meta.x-m.x)>m.w*o.TOLERANCE or math.abs(meta.y-m.y)>m.h*o.TOLERANCE
    
    if  is_effective then apply_crop(meta) 
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

function apply_crop(meta)  --ALSO apply_scale (FOR PADDING BLACK BARS USING A SECOND GRAPH).  A crop CAN MAKE A WIDE-SCREEN PORTRAIT TALLER.
    v          =mp.get_property_native('current-tracks/video') or {}
    aspect     =OFF and (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect) or W/H  --OFF&(~image OR image) OR ON(FULL-SCREEN).
    if is1frame
    then paused=pause
        mp.set_property_bool('pause',true) --GRAPH REPLACEMENT. INSTA-pause IMPROVES RELIABILITY DUE TO INTERFERENCE FROM OTHER SCRIPTS.  MAY ALSO CHECK IF paused NEAR end-file (NOT ENOUGH TIME FOR unpause_on_crop). 
        mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:BLACK:frame,setsar=1]'):format(command_prefix,label,round(math.min(W,H*aspect)),round(math.min(W/aspect,H)),W,H))  
        mp.command(('%s vf pre @%s:lavfi=[%s,crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1]'):format(command_prefix,label,detector,meta.w,meta.h,meta.x,meta.y))  --detector OPTIONAL.
        mp.set_property_bool('pause',paused)
    else s=('clip((t-%s)/(%s),0,1)'):format(mp.get_property_number('time-pos'),o.crop_time)  --ABBREV. TIME RATIO AS s=string.  clip BTWN 0 & 1.
        mp.command(('%s vf-command %s x                 -((1-%s)*%d+%s*%d)        %s'):format(command_prefix,label , s,m.x, s,meta.x,       target_overlay))  --INITIAL→FINAL  (1-s)→s  COORD PAIRS. overlay THEN scale THEN pad.
        mp.command(('%s vf-command %s y                 -((1-%s)*%d+%s*%d)        %s'):format(command_prefix,label , s,m.y, s,meta.y,       target_overlay))
        mp.command(('%s vf-command %s-crop width  max(iw/((1-%s)*%d+%s*%d)*%d,%d) %s'):format(command_prefix,label , s,m.w, s,meta.w, W, W, target_scale  ))  --w & h ARE AMBIGUOUS IN OLD MPV, BUT NOT width & height.
        mp.command(('%s vf-command %s-crop height max(ih/((1-%s)*%d+%s*%d)*%d,%d) %s'):format(command_prefix,label , s,m.h, s,meta.h, H, H, target_scale  ))
        
        if m.aspect~=aspect then                apply_scale() 
        for N=3,6 do mp.add_timeout(2^N/1000,apply_scale) end end  --8 16 32 64 ms. EXPONENTIAL TIMEOUTS BECAUSE COMMANDS ARE DODGY.
        if insta_unpause then mp.set_property_bool('pause',false)  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.
        timers.pause:resume() end end
    m.w,m.h,m.x,m.y                   = meta.w,meta.h,meta.x,meta.y   --meta→m  MEMORY TRANSFER. 
    m.time_pos,m.aspect,insta_unpause = time_pos,aspect,nil
end

function apply_scale()  --vf-command DODGY BUT SHOULD STILL PERFORM SUPERIOR TO GRAPH REPLACEMENT. CAN BE USED TO MAINTAIN TRUE aspect. 
    mp.command(('%s vf-command %s-scale w %d %s'):format(command_prefix,label,round(math.min(W,H*aspect)),target_scale))  --PADS EITHER HORIZONTALLY OR VERTICALLY, IN EFFECT - BOUNDED BY W,H
    mp.command(('%s vf-command %s-scale h %d %s'):format(command_prefix,label,round(math.min(H,W/aspect)),target_scale))
end 


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.  DIFFICULT TO THINK OF PROPER lowercase NAMES FOR THINGS LIKE o.MAINTAIN_CENTER.
----MPV v0.38.0 (.7z .exe v3) v0.37.0 (.app) v0.36.0 (.exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED. 
----FFmpeg v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4 v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS OFTEN BUILT WITH FFmpeg v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----A FUTURE VERSION MIGHT BE ABLE TO CROP WITHOUT CHANGING ASPECT (EQUIVALENT TO AUTO-zoom). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT. MAINTAINING aspect ACTUALLY MEANS A VARIABLE scale FOR EACH crop, IN EFFECT.
----SMPLAYER v23.12 TRIGGERS GRAPH RESET ON PAUSE. THAT'S ACTUALLY AN ADDED FEATURE WHICH RESETS THE CROP WHEN USER HITS SPACEBAR. v23.6 (JUNE RELEASE) & MPV ALONE DON'T RESET crop ON pause. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms.

----ALTERNATIVE FILTERS:
----loop   =loop:size  (LOOPS>=-1:MAX_SIZE>0)  UNNECESSARY.  INFINITE loop SWITCH FOR image (1fps). ALTERNATIVE TO GRAPH REPLACEMENT. COULD INCREASE TO 2fps. MORE RELIABLE WHEN USED WITH FURTHER GRAPHS, LIKE automask.
----format =pix_fmts          POSSIBLE BUGFIX FOR alpha CAUSING BAD cropdetect PERFORMANCE.



