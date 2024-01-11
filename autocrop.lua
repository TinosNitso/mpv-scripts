----FOR MPV & SMPLAYER. CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 albumart, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop.  .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA DOUBLE BLACK BARS TO MATCH STREAM), BUT NO SMOOTH-crop. BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua

o={  --options
    auto            =true,--IF false, CROPS OCCUR ONLY on_seek & on_toggle.
    auto_delay      = .5, --ORIGINAL DEFAULT=1 SECOND.  
    detect_limit    = 30, --ORIGINAL DEFAULT="24/255".  ONLY INTEGER COMPATIBLE WITH bbox (0→255). autocomplex SPECTRUM INTERFERES ON SIDES (ADD limit).
    detect_round    =  1, --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.
    detect_min_ratio=.25, --ORIGINAL DEFAULT=0.5.  =0 FOR JPEG (OVERRIDE).
    
    --ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. (JPEG NEEDS pause THOUGH.) SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    toggle_on_double_mute=.5,       --SECONDS TIMEOUT FOR DOUBLE-mute-TOGGLE. ONLY WORKS IN SMPLAYER IF THERE'S audio TO mute (CAN'T toggle ON RAW JPEG).
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). m IS mute (IN DVORAK TOO) SO CAN DOUBLE-PRESS m. m&m DOUBLE-TAP MAYBE OUGHT TO BE automask, BUT autocrop IS MORE FUNDAMENTAL.
    
    command_prefix    ='no-osd',--DEFAULT=''. CAN SUPPRESS osd, OR PERFORM COMMANDS AS async.
    detect_limit_image=32,      --INTEGER 0→255, FOR JPEG & albumart.
    detect_limits     ={        --detect_limit OVERRIDES. NOT CASE SENSITIVE. ['media-title']=detect_limit 
        ['We are army of people - Red Army Choir']=64,
        ['Eminem - Encore']=100,--REPLACE WITH media-title SUBSTRING, & ITS LIMIT.
    },
    detector      ='cropdetect=%s:%s:1:0',--DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'  %s=string SUBSTITUTIONS @file-loaded. reset>0.  CAN ALSO COMBINE MULTIPLE DETECTORS IN LIST (MORE CPU USAGE?).
    detector_image='bbox=%s',             --DEFAULT='bbox=%s'  %s=detect_limit_image OR OVERRIDE.
    
    MAINTAIN_CENTER    ={0,0},--{TOLERANCE_X,TOLERANCE_Y}. APPLIES TO video (NOT image). 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK (UNLESS is1frame). A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    TOLERANCE          =.05,  --DEFAULT=0. INSTANTANEOUS TOLERANCE. 0% FOR image. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME     = 10,  --DEFAULT=10 SECONDS. IRRELEVANT IF TOLERANCE=0.
    USE_INNER_RECTANGLE=true, --BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO   =true, --CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS. DEFAULT CANCELS EXCESSIVE crop.
    
    -- meta_osd=true, --DISPLAY ALL detector METADATA.
    -- msg_log =true, --MESSAGE TO MPV LOG. FILLS THE LOG.
    
    -- scale={1680,1050},  --DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX). CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS SOME ABSOLUTE scale IS USED. EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).  
    format ='yuv420p',     --DEFAULT=yuv420p  REMOVES alpha DUE TO cropdetect BAD PERFORMANCE BUG.  420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    options=''             --'opt1 val1 opt2 val2 ...' FREE FORM.  main.lua HAS io_write (NECESSARY) & MORE options.
        ..' geometry 50% ' --ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.
}
(require 'mp.options').read_options(o)    --OPTIONAL?

for opt,val in pairs({toggle_on_double_mute=0,key_bindings='C',command_prefix='',detect_limit_image=o.detect_limit,detect_limits={},detector='cropdetect=limit=%s:round=%s:reset=1:0',detector_image='bbox=%s',MAINTAIN_CENTER={},TOLERANCE=0,TOLERANCE_TIME=10,scale={},format='yuv420p',options=''})
do o[opt]=o[opt] or val end  --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('[^ ]+') --GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) DIDN'T EXIST IN AN OLD LUA VERSION, USED BY mpv.app ON MACOS.
while   val do mp.set_property(opt,val)   --('','') → NULL-SET
    opt,val = o.options(),o.options() end --nil @END

timers,m,label = {},{},mp.get_script_name() --m=MEMORY FOR METADATA & VARIABLE OPTIONS WHICH MAY VARY FROM TRACK TO TRACK.  COULD ALSO USE o2 INSTEAD OF m.  timers CARRY OVER TO NEXT FILE IN MPV PLAYLIST.
function file_loaded(event)  --ALSO on_toggle, on_vid & ytdl.
    if not mp.get_property_number('current-tracks/video/id') then return end   --RAW MP3 VISUALS MAY NOT NEED CROPPING.
    
    W,H = o.scale[1],o.scale[2]  --scale OVERRIDE. 
    if not W then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not W then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not W then mp.add_timeout(.05,file_loaded) --BUGFIX FOR EXCESSIVE LAG IN VIRTUALBOX-SMPLAYER-YOUTUBE. RE-RUN AFTER 50ms.
        return end
    
    par=mp.get_property_number('current-tracks/video/demux-par') or 1  --PIXEL ASPECT RATIO MUST BE WELL-DEFINED. JPEG ASSUME 1. get_property_number REMOVES TRAILING .000...
    for opt,val in pairs(o) do m[opt]=val end  --COPY ORIGINAL OPTIONS INTO MEMORY.
    complex_opt,media_title = mp.get_opt('lavfi-complex'),mp.get_property('media-title'):lower()  --media-title @file-loaded.
    complex_opt=complex_opt and complex_opt~='' and complex_opt~='no'  --A BLANK complex IS NOTHING. ASSUME OPT MEANS IMAGES ALREADY ON loop WHICH WORKS DIFFERENT WITH albumart.
    
    is1frame,loop = false,false  --loop=is_looper
    if not complex_opt and mp.get_property_bool('current-tracks/video/albumart') then is1frame,m.auto = true,false end  --albumart IS DIFFERENT TO image. REQUIRE GRAPH REPLACEMENT IF NO complex. NO auto BECAUSE audio GLITCHES.
    if mp.get_property_bool('current-tracks/video/image') then m.TOLERANCE,m.detector,m.detect_limit   = 0,o.detector_image,o.detect_limit_image --JPEG: bbox & 0 TOLERANCE.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio). GIF IS ~image. 
        if not complex_opt then loop,m.detect_min_ratio,m.MAINTAIN_CENTER = true,0,{}  --RAW JPEG CAN MOVE CENTER. loop NEEDED FOR RELIABILITY (GRAPH REPLACEMENTS CAUSE ERRORS IN MPV LOG).
            mp.command(o.command_prefix..' vf remove @loop') end end  --REMOVE ANY loop FILTER. 
    for title,limit in pairs(o.detect_limits) do if media_title:find(title:lower(),1,true) then m.detect_limit=limit end end   --detect_limit FINAL OVERRIDE.  1,true = STARTING_INDEX,EXACT_MATCH  NOT CASE SENSITIVE.
    m.detector=m.detector:format(m.detect_limit,o.detect_round)
    if event then mp.set_property_bool('pause',true) end  --INSTA-pause REQUIRED TO PREVENT EMBEDDED MPV FROM SNAPPING, BUT THIS COULD BE AN OPTION (BECAUSE IT ALWAYS UNPAUSES). ALSO REQUIRE io_write (main.lua).  GRAPHS CAN'T NECESSARILY BE INSERTED DURING PLAY, WITHOUT SNAPPING THE [gpu] OUTPUT. HOWEVER REPLACEMENT WORKS.
    
    mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad,setsar=%s]'):format(o.command_prefix,label,W,H,par))  --pad REPLACED on_toggle. IT SHOULD BE PERMANENT IN THEORY.
    mp.command(('%s vf pre @%s:lavfi=[format=%s,%s,crop=iw:ih:0:0:1:1]'):format(o.command_prefix,label,o.format,m.detector))
    if loop then mp.command(('%s vf pre @loop:loop=loop=-1:size=1'):format(o.command_prefix)) end  --OTHER SCRIPTS MUST CHECK loop LABEL OR NAME.
    
    ----lavfi     =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERCHAINS. USES 2 GRAPHS BECAUSE OTHERWISE "w" & "h" COMMANDS MAY BE AMBIGUOUS, WITHOUT INTERNAL LABELS. ALSO USES loop FILTER FOR JPEG.
    ----format    =pix_fmts  IS THE START.  BUGFIX FOR alpha CAUSING BAD PERFORMANCE. TO VERIFY BUG SET yuva420p OR rgb32.
    ----cropdetect=limit:round:reset:skip   DEFAULT=24/255:16:0  reset & skip BOTH MEASURED IN FRAMES. reset>0 COUNTS HOW MANY FRAMES PER DETECTION. LINUX .AppImage FAILS IF skip IS NAMED (INCOMPATIBLE).  alpha TRIGGERS BAD PERFORMANCE. 
    ----bbox      =min_val   (BOUNDING BOX) DEFAULT=16  REQUIRED FOR JPEG.  CAN ALSO ALWAYS COMBINE MULTIPLE DETECTORS IN 1 GRAPH FOR IMPROVED RELIABILITY, BUT UNNECESSARY & MAY INCREASE CPU USAGE.
    ----loop      =loop:size  (LOOPS>=-1:MAX_SIZE>0)  IS INDEPENDENT. INFINITE loop SWITCH FOR image (1fps). ALTERNATIVE TO GRAPH REPLACEMENT. COULD INCREASE TO 2fps (SLOW?). MORE RELIABLE WHEN USED WITH FURTHER GRAPHS WHICH WOULD INFINITE loop, LIKE automask. IT'S A RELIABILITY ISSUE: IN THEORY IT SHOULDN'T BE NECESSARY.
    ----crop      =w:h:x:y:keep_aspect:exact  IS THE CONTROLLER.  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale     =w:h  DEFAULTS iw:ih  USING [vo] scale WOULD CAUSE SNAPPING on_vid, SO CAN USE display INSTEAD. EITHER WINDOW SNAPS IN, OR ELSE video SNAPS OUT.
    ----pad       =w:h:x:y  FOR TOGGLE OFF. RETURN EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar    =sar  IS THE FINISH.  SAMPLE/PIXEL ASPECT RATIO. MUST ASSERT SAR. LINUX & MACOS YOUTUBE BUGFIX REQUIRE IT @END. ALSO STOPS EMBEDDED MPV SNAPPING on_vid. 


    if event then mp.set_property_bool('pause',false) end
    timers.auto_delay:resume()  --is1frame REQUIRES SMALL DELAY FOR INITIAL DETECTION (RELIABILITY ISSUE).
end
mp.register_event('file-loaded',function() mp.add_timeout(.05,file_loaded) end)  --timeout REQUIRED ON MACOS-VIRTUALBOX-SMPLAYER. OSTYPE=darwin20.0
mp.register_event('end-file',function() m={} end)  --FOR MPV PLAYLISTS (EXAMPLE: *.MP4). CLEAR MEMORY.

function on_vid(_,vid)  --AN MP3 MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS.
    if m.vid and m.vid~=vid then file_loaded() end
    m.vid=vid   --→MEMORY.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.   ALTERNATIVE: current-tracks/video/id

function on_seek()  --crop AGAIN DUE TO vf-command RESET, UNLESS is1frame (GEOMETRY ALREADY PERMANENT).
    if not is1frame then m.w=nil       --CAUSES RE-CROP VIA GEOMETRIC MEMORY RESET. 
        timers.auto_delay:resume() end --RE-DETECT, ON DELAY, IN CASE ~m.auto.
end 
mp.register_event('seek',on_seek)  

function on_toggle(mute)   --IT RETURNS BLACK BARS USING pad, WITHOUT EVER CHANGING [vo] scale.
    if not W then return --NOT loaded YET.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,m.w,m.time,aspect = not OFF,nil,nil,mp.get_opt('aspect')  --autocomplex MUST REPORT TRUE aspect BECAUSE lavfi-complex ARTIFICIALLY CHANGES video-params/aspect. video-dec-params/aspect FAILED TO WORK THE SAME WAY.
    if not OFF then file_loaded()  --TOGGLE ON.
    else if not aspect then aspect=mp.get_property_number('video-params/aspect') end  --TOGGLE OFF. aspect MUST BE WELL-DEFINED, BUT THE PROPERTY IS DEPRACATED.
        aspect_ratio=aspect/(W/H)   --RATIO=[vo]/display.  RETURN ORIGINAL aspect BY PADDING EITHER HORIZONTALLY OR VERTICALLY.
        mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad=%d:%d:(ow-iw)/2:(oh-ih)/2,setsar=%s]'):format(o.command_prefix,label,W*math.min(1,aspect_ratio),H/math.max(1,aspect_ratio),W,H,par))  --GRAPH REPLACEMENT DOESN'T CHANGE THEIR ORDER (NEVER remove). ADDS AN EXTRA PAIR OF BLACK BARS. WIDTH MULTIPLIES BUT HEIGHT DIVIDES, WHEN NECESSARY. vf-command MIGHT REQUIRE BREAKING UP THE GRAPH SO THAT scale & pad ARE SEPARATE.
        apply_crop({ x=0,y=0, w=m.max_w,h=m.max_h }) end --NULL crop (CAN INSERT max NUMBERS), OR ELSE remove. IS SLOW WITHOUT FRAME-STEPPING (DOUBLE GRAPH REPLACEMENT).
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute', 'bool', on_toggle)
timers.mute        =mp.add_periodic_timer(o.toggle_on_double_mute, function()end)  --double_mute timer
timers.mute.oneshot=true 
timers.mute:kill()

function detect_crop()     --MAIN function, ON LOOP.
    if OFF then return end --TOGGLED OFF. 

    meta,m.max_w,m.max_h = mp.get_property_native('vf-metadata/'..label),mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h')  -- Get the metadata.
    if not meta then if o.msg_log then mp.msg.error("No crop metadata.")    --Verify the existence of metadata. SOMETIMES IT'S {}, WHICH FAILS THE NEXT TEST.
                                       mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?") end
        return  
    elseif o.meta_osd then mp.osd_message(mp.get_property_osd('vf-metadata/'..label)) end  --DISPLAY COORDS FOR 1 SEC. THIS BUGS OUT IF ~meta.
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('[^ ]+') 
    do value=         meta['lavfi.cropdetect.'..key]      
       value=value or meta['lavfi.bbox.'      ..key]
       meta[key]=tonumber(value) end   --tonumber(nil)=nil (BUT 0+nil FAILS).
    if not (meta.w and meta.h and meta.x1 and meta.y1 and meta.x2 and meta.y2) then if o.msg_log then mp.msg.error("Got empty crop data.") end  --THIS CAN HAPPEN IF VID IS paused.   
         return  
    elseif not (meta.x and meta.y) then meta.x,meta.y = (meta.x1+meta.x2-meta.w)/2,(meta.y1+meta.y2-meta.h)/2 end     --bbox GIVES x1 & x2 BUT NOT x. CALCULATE x & y BY TAKING AVERAGE.
    
    if o.USE_INNER_RECTANGLE then xNEW,yNEW = math.max(meta.x1,meta.x2-meta.w,meta.x),math.max(meta.y1,meta.y2-meta.h,meta.y)
            meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
            meta.x ,meta.y  = xNEW,yNEW
            meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    if m.MAINTAIN_CENTER[1] then xNEW=math.min( meta.x , m.max_w-(meta.x+meta.w) )      --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
        wNEW=m.max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
        if wNEW-meta.w>wNEW*m.MAINTAIN_CENTER[1] then meta.x,meta.w = xNEW,wNEW end end
    if m.MAINTAIN_CENTER[2] then yNEW=math.min( meta.y , m.max_h-(meta.y+meta.h) )      --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
        hNEW=m.max_h-yNEW*2
        if hNEW-meta.h>hNEW*m.MAINTAIN_CENTER[2] then meta.y,meta.h = yNEW,hNEW end end --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
   
    min_w,min_h,time = m.max_w*m.detect_min_ratio,m.max_h*m.detect_min_ratio,mp.get_property_number('time-pos')
    if meta.w<min_w then if not o.USE_MIN_RATIO 
        then meta.w,meta.x = m.max_w,0    --NULL w
        else meta.w,meta.x = min_w,math.max(0,math.min(m.max_w-min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE w
    if meta.h<min_h then if not o.USE_MIN_RATIO 
        then meta.h,meta.y = m.max_h,0    --NULL h
        else meta.h,meta.y = min_h,math.max(0,math.min(m.max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE h

    if meta.w>m.max_w or meta.h>m.max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return  --IF w<0 IT'S LIKE A JPEG ERROR.
    elseif not (m.w and m.h and m.x and m.y) then m.w,m.h,m.x,m.y = m.max_w,m.max_h,0,0 end  --INITIALIZE 0TH crop AT BEGINNING.
    
    is_effective=(not m.time  --Verify if it is necessary to crop.            PROCEED IF INITIALIZING, OR JPEG.
        or math.abs(m.time-time)>o.TOLERANCE_TIME)            --PROCEED IF TIME CHANGES TOO MUCH,
            and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)                --UNLESS ALL COORDS EXACTLY THE SAME.
        or math.abs(meta.w-m.w)>m.w*m.TOLERANCE or math.abs(meta.h-m.h)>m.h*m.TOLERANCE --PROCEED IF OUTSIDE TOLERANCE.
        or math.abs(meta.x-m.x)>m.w*m.TOLERANCE or math.abs(meta.y-m.y)>m.h*m.TOLERANCE
    
    if is_effective  then apply_crop(meta) 
    elseif o.msg_log then mp.msg.info("No area detected for cropping.") end
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay,detect_crop)

function apply_crop(meta)
    for whxy in ('w h x y'):gmatch('[^ ]') do m[whxy]=meta[whxy]  --meta→m  MEMORY TRANSFER. 
        mp.command(('%s vf-command %s %s %d'):format(o.command_prefix,label,whxy,meta[whxy])) end  --UNPAUSED USES vf-command (MORE EFFICIENT).
    if is1frame or mp.get_property_bool('pause') and not m.time  --GRAPH REPLACEMENT. m.time IS A SWITCH USED TO PREVENT INFINITE seek CYCLE.
    then mp.command(('%s vf pre @%s:lavfi=[format=%s,%s,crop=%d:%d:%d:%d:1:1]'):format(o.command_prefix,label,o.format,m.detector,meta.w,meta.h,meta.x,meta.y)) end  --REPLACEMENT GRAPH FOR albumart WITHOUT complex. VERIFY BY TOGGLE "c" REPEATEDLY (WITH &) WITHOUT automask.

    m.time=time  --REMEMBER time OF crop.
    if not m.auto then timers.auto_delay:kill() end --kill auto timer AFTER SUCCESSFUL crop.
end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.37.0  v0.36.0 (.7z .exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED.  v0.36 PREFERRED.
----FFmpeg v6.0(.7z .exe .flatpak)  v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS ACTUALLY BUILT WITH FFmpeg v4, v5 & v6 (ALL 3), WHICH CHANGES HOW THE GRAPHS ARE WRITTEN (FOR COMPATIBILITY).
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----A FUTURE VERSION MIGHT BE ABLE TO CROP WITHOUT CHANGING ASPECT (EQUIVALENT TO AUTO-zoom). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT.
----SMPLAYER v23.12 TRIGGERS GRAPH RESET ON PAUSE. THAT'S ACTUALLY AN ADDED FEATURE WHICH RESETS THE CROP WHEN USER HITS SPACEBAR. v23.6 (JUNE RELEASE) & MPV ALONE DON'T RESET crop ON pause. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms.

----ALTERNATIVE FILTERS:
----split    CLONES video. UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.
----overlay =x:y DEFAULT=0:0 n=1@INSERTION (OFF)  UNNECESSARY. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.



