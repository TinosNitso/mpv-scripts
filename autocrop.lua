----FOR MPV & SMPLAYER. SMOOTHLY CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 (COVER ART), & MP4. .TIFF ONE-LAYER ONLY. CAN CHANGE vid TRACK (MP3TAG) & crop. FOR RAW JPEG SMOOTH STRETCH NEEDS autocomplex LOOP.
----USE DOUBLE-mute TO TOGGLE. FRAME-STEPS WHEN PAUSED (ACTS AS A frame-step TOGGLE). CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH TOLERANCE VALUES. FULLY SUPPORTS cropdetect & bbox (ffmpeg-filters). 
----THIS VERSION USES A MAGNIFIED NEGATIVE overlay FOR SMOOTH crop (BUG WORKAROUND). MAY LAG IF IT MAGNIFIES 4xDISPLAY, BEFORE CROPPING DOWN TO IT. AS SMOOTH AS STRETCHING PARCHMENT. BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua

options = {
    auto            =true,--IF false, CROPS OCCUR ONLY on_seek & on_toggle.
    auto_delay      = .5, --ORIGINAL DEFAULT=1 SECOND.  
    detect_limit    = 32, --ORIGINAL DEFAULT="24/255".  ONLY INTEGER COMPATIBLE WITH bbox (0→255). autocomplex SPECTRUM INTERFERES ON SIDES (ADD limit).
    detect_round    =  2, --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.
    detect_min_ratio=.25, --ORIGINAL DEFAULT=0.5.
    
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    crop_time     =.5,      --DEFAULT=.5 SECONDS. TIME TO STRETCH OUT BLACK BARS, BY SMOOTHLY VARYING ASPECT. TOO FAST & IT HAS TOO MUCH ENERGY. ALSO TIME-STEP OF TOGGLE WHEN PAUSED.
    command_prefix='no-osd',--DEFAULT=''. CAN SUPPRESS osd.
    
    detect_limits ={        --NOT CASE SENSITIVE. detect_limit MAY VARY WITH media-title IF THE FOLLOWING SUBSTRINGS ARE FOUND. EXTRA ZOOM.
                    ['We are army of people - Red Army Choir']= 64,
                    [                       'L.A.D.Y G.A.G.A']=100, 
                   },
    
    MAINTAIN_CENTER_X=  0, --TOLERANCE, 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAY BE OK.
    MAINTAIN_CENTER_Y= .1, --TOLERANCE. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3.
    TOLERANCE        =.05, --DEFAULT=0%=JPEG. INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME   = 10, --DEFAULT=10 SECONDS. IRRELEVANT IF TOLERANCE=0.
    
    USE_INNER_RECTANGLE=true,--BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO   =true,--CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.
    time_needed        =2,   --DEFAULT=0 SECONDS. DO NOTHING IF THIS CLOSE TO VIDEO END. NEEDED FOR RELIABILITY.
    
    -- scale    ={1680,1050},--STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE).     CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS AN ABSOLUTE scale IS USED (SO I DON'T USE [vo]). EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).   DEFAULT scale=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    -- detectors='bbox=%s',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'. bbox IS JPEG OVERRIDE. MULTIPLE detectors='cropdetect=%s:%s:1:0,cropdetect=%s:%s:1:0' MAYBE FOR IMPROVED RELIABILITY.   %s=string SUBSTITUTION, FORMATTED @file-loaded. reset>0.
    -- meta_osd =true,       --DISPLAY ALL DETECTOR METADATA.
    -- msg_info =true,       --REPORT info MESSAGES TO MPV LOG. THEY FILL THE LOG, BUT MAY HELP WITH DEBUGGING.
    
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). m IS mute (IN DVORAK TOO) SO CAN DOUBLE-PRESS m. m&m DOUBLE-TAP MAYBE OUGHT TO BE automask, BUT autocrop IS MORE FUNDAMENTAL. key_bindings DON'T WORK INSIDE SMPLAYER. 
    toggle_on_double_mute=.5,       --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute-TOGGLE. IN SMPLAYER (OR ON SMARTPHONE) TOGGLE CROPPING BY MUTING, INSTEAD OF KEYBOARD SHORTCUT. ONLY WORKS IN SMPLAYER IF THERE'S AN aid TO mute (E.G. CAN'T TOGGLE ON RAW .JPG).
    
    io_write=' ',   --DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY CHANGE IN vf (VIDEO FILTERS). STOPS EMBEDDED MPV FROM SNAPPING ON COVER ART. MPV MAY COMMUNICATE WITH ITS PARENT APP.
    config  ={
              'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',  --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
              'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL SIZE.
              'image-display-duration inf','video-timing-offset 1', --inf STOPS IMAGES FROM SNAPPING MPV. DEFAULT offset=.05 SECONDS ALSO WORKS.
              'hwdec auto-copy','vd-lavc-threads 0', --IMPROVED PERFORMANCE FOR LINUX .AppImage.  hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
              'alpha blend', --BUGFIX FOR LINUX flatpak (blend-tiles BUG).
              
              'pause yes',  --THEN UNPAUSE @file-loaded. EMBEDDED MPV MAY SNAP IF IT ISN'T PAUSED BEFORE A GRAPH'S INSERTED.
             },       
}
o,label,timers,m = options,mp.get_script_name(),{},{} --ABBREV. options. label=autocrop   m=crop MEMORY

require 'mp.options'
read_options(o)    --OPTIONAL?

for key,val in pairs({command_prefix='',detect_limits={},TOLERANCE=0,TOLERANCE_TIME=10,time_needed=0,crop_time=.5,scale={},detectors='cropdetect=limit=%s:round=%s:reset=1:0',key_bindings='C',toggle_on_double_mute=0,io_write='',config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command(o.command_prefix..' set '..option) end   --APPLY config BEFORE scripts.
if mp.get_property('vid')=='no' then exit() end    --OPTIONAL: NO VIDEO→EXIT.

function file_loaded()
    if OFF or not mp.get_property_number('current-tracks/video/id') then mp.command('set pause no')   --DO NOTHING IF NO vid: unpause & return.
        return end   --OFF TOGGLE & NO vid → NO crop.
    
    W,H = o.scale[1],o.scale[2]
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not (W and H) then mp.add_timeout(.05,file_loaded)   --LINUX FALLBACK: RE-RUN & return. DUE TO EXCESSIVE LAG IN VIRTUALBOX.
        return end
    W,H = math.ceil(W/4)*4,math.ceil(H/4)*4   --MULTIPLES OF 4 WORK BETTER WITH overlay (FURTHER GRAPHS LIKE automask). MPV MAY SNAP INSIDE SMPLAYER ON ODD NUMBERED SIZES.
    
    l,r , MEDIA_TITLE,is1frame  =  o.detect_limit,o.detect_round , mp.get_property('media-title'):upper(),false --current-tracks PROPERTIES AWAIT file-loaded. 
    for title,detect_limit in pairs(o.detect_limits) do if MEDIA_TITLE:find(title:upper(),1,true)   --1 IS STARTING INDEX. true DISABLES MAGIC SYMBOLS LIKE '%s'.
        then l=detect_limit  --CHANGE detect_limit FOR DIFFICULT FILES. 
            break end end
    
    if mp.get_property_bool('current-tracks/video/image') then o.detectors,o.TOLERANCE = 'bbox=%s',0    --0 INSTANTANEOUS TOLERANCE (E.G. WHEN CHANGING vid ON MP3). IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (SEE MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).
        if mp.get_property('lavfi-complex')=='' then is1frame=true    --REQUIRE GRAPH REPLACEMENT (NO autocomplex LOOP).
            if o.io_write=='' then o.io_write=' ' end end end   --JPEG NEEDS io_write FIX.
    mp.observe_property('vf','native',function() io.write(o.io_write) end)
    o.detectors=o.detectors:format( l,r , l,r , l,r , l,r ) --CAN COMBINE A FEW DETECTORS, IN 1 GRAPH.
    
    mp.command(('%s vf pre @%s-crop:lavfi=[scale=%d:%d:eval=frame,crop=%d:%d:0:0:1:1,setsar=1]'):format(o.command_prefix,label,W,H,W,H))    --INSERT scale @INSERTION TO AVOID STARTING GLITCH ON LOW-RES video.
    mp.command(('%s vf pre @%s:lavfi=[noformat=yuva420p|yuva444p|rgb32|rgba|bgra,scale=ceil(iw/4)*4:ceil(ih/4)*4,%s,split,overlay]'):format(o.command_prefix,label,o.detectors))   --CENTRAL GRAPH. USES MOST CPU. BY TRIAL & ERROR NEEDS width & height INSTANTLY TO AVOID RARE STARTING GLITCH.
    
    ----lavfi     =[graph]  [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. THIS ONE ACHIEVES SMOOTH crop WITH A BUGGY crop FILTER, WHICH REQUIRES A SECOND GRAPH.
    ----cropdetect=limit:round:reset:skip  DEFAULT=24/255:16:0  LINUX .AppImage FAILS IF skip IS NAMED (INCOMPATIBLE).  alpha TRIGGERS BAD PERFORMANCE.
    ----bbox      =min_val  (BOUNDING BOX) DEFAULT=16  REQUIRED FOR JPEG.
    ----scale     =w:h:...:eval    n=0@INSERTION  DEFAULTS iw:ih:once  USING [vo] scale WOULD CAUSE SNAPPING on_vid, SO I PREFER display.
    ----noformat  =pix_fmts  BLOCKS alpha. cropdetect PERFORMS BADLY WITH TRANSPARENT INPUT (EVEN IF 100% OPAQUE). THERE'S A LONG LIST.  PROOF: REPLACE WITH format=yuva420p & IT CAUSES LAG.
    ----split      CLONES video. THIS IS A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS. THERE IS NO WORKAROUND FOR HAVING TO MAGNIFY UP FIRST, SO POOR PPL WITH CHEAP CPU MUST SUFFER LAG.
    ----overlay   =x:y DEFAULT=0:0 n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, WHICH IS WHY THE TRIVIAL PRE-scale EXISTS.
    ----crop      =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  HAS BUGS. vf-command CRASHES IT. WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. A BUGGY FILTER CAN HAVE ITS OWN GRAPH.
    ----setsar    =sar  IS THE FINISH. STOPS EMBEDDED MPV SNAPPING on_vid. MACOS BUGFIX REQUIRES sar (WINDOWS & LINUX DON'T). 
    
    
    mp.command('set pause no') --UNPAUSE.
    timers.auto_delay:resume() --SMALL DELAY FOR INITIAL DETECTION.
end
mp.register_event('file-loaded',file_loaded)

function on_vid(_,vid)  --AN MP3 MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS.
    if m.vid and m.vid~=vid then file_loaded() end
    m.vid=vid   --→MEMORY.
end
mp.observe_property('current-tracks/video/id','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.

function on_seek()  --SMOOTH crop ON seek (GRAPH STATE IS RESET).
    m.x,m.playtime_remaining = nil,nil  --DELETE ALL COORDS (m.x=nil RE-INITIALIZES).
    if not is1frame then timers.auto_delay:resume() end     --is1frame RE-SEEKS ON crop. NEEDED IN CASE NOT o.auto.
end
mp.register_event('seek',on_seek) 

function on_pause(_,paused) --BUGFIX FOR NEW DETECTION on_pause (apply_crop MUST STRETCH).
    if paused then timers.auto_delay:kill()
    else           timers.auto_delay:resume() end
end
mp.observe_property('pause', 'bool', on_pause)

timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --DOUBLE mute timer.
timers.mute.oneshot=true 

function on_toggle(mute)    --BOTH mute & key_binding.
    if mute=='mute' and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,m.playtime_remaining = not OFF,nil
    if not OFF then detect_crop()   --TOGGLE ON.
    else timers.auto_delay:kill()               --TOGGLE OFF. 
        apply_crop({ x=0,y=0, w=m.max_w,h=m.max_h }) end    --ANIMATE NULL crop. INSTANT DOUBLE-TOGGLE WOULD REQUIRE ANOTHER LINE TO MEMORIZE THESE COORDS, SO THEY DON'T HAVE TO BE RE-DETECTED.
end
mp.observe_property('mute', 'bool', on_toggle)  --mute timer NEEDED, TO ACTIVATE.
for key in (o.key_bindings):gmatch('%g+') do mp.add_key_binding(key, 'toggle_crop_'..key, on_toggle) end    --gmatch IS GLOBAL MATCH ITERATOR. %g+ IS LONGEST string EXCLUDING SPACE.

function detect_crop()
    if not o.auto then timers.auto_delay:kill() end    
    meta,playtime_remaining = mp.get_property_native('vf-metadata/'..label),mp.get_property_number('playtime-remaining')  -- Get the metadata.
    if OFF or playtime_remaining and playtime_remaining<o.time_needed then return end     --TOGGLED OFF OR NEAR END. playtime_remaining=nil FOR JPEG.
    
    if o.meta_osd then message=mp.get_property_osd('vf-metadata/'..label)
        if message then mp.osd_message(message) end end   --DISPLAY COORDS FOR 1 SEC. message=nil→FAIL
    
    if not meta then mp.msg.error("No crop metadata.")  --Verify the existence of metadata. SOMETIMES IT'S AN EMPTY table, WHICH FAILS THE NEXT TEST.
        if o.msg_info then mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?") end
        return end 
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('%g+') do value=meta['lavfi.cropdetect.'..key]      
        if not value then                               value=meta['lavfi.bbox.'      ..key] end  --bbox POSSIBLE.
        meta[key]=tonumber(value) end   --tonumber(nil)=nil (BUT 0+nil FAILS).
    
    if not (meta.w and meta.h and meta.x1 and meta.y1 and meta.x2 and meta.y2) then mp.msg.error("Got empty crop data.")   --THIS CAN HAPPEN IF VID IS PAUSED.   
         return end 
    
    if not meta.x or not meta.y then meta.x,meta.y = (meta.x1+meta.x2-meta.w)/2,(meta.y1+meta.y2-meta.h)/2 end     --bbox GIVES x1 & x2 BUT NOT x. CALCULATE x & y BY TAKING AVERAGE.
    if o.USE_INNER_RECTANGLE then xNEW,yNEW = math.max(meta.x1,meta.x2-meta.w,meta.x),math.max(meta.y1,meta.y2-meta.h,meta.y)
            meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
            meta.x ,meta.y  = xNEW,yNEW
            meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    m.max_w,m.max_h = math.ceil(mp.get_property_number('video-params/w')/4)*4,math.ceil(mp.get_property_number('video-params/h')/4)*4   --ACCOUNT FOR TRIVIAL PRE-scale.
    if o.MAINTAIN_CENTER_X then xNEW = math.min(meta.x, m.max_w-(meta.x+meta.w))  --KEEP HORIZONTAL CENTER, E.G. SO THAT BINOCULARS ARE CENTERED.    SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL.
        wNEW = m.max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
        if wNEW-meta.w>wNEW*o.MAINTAIN_CENTER_X then meta.x,meta.w = xNEW,wNEW end end
    if o.MAINTAIN_CENTER_Y then yNEW = math.min(meta.y, m.max_h-(meta.y+meta.h))     -- KEEP VERTICAL CENTERED, E.G. PORTRAITS WHERE FEET GET CROPPED OFF. 
        hNEW = m.max_h-yNEW*2
        if hNEW-meta.h > hNEW*o.MAINTAIN_CENTER_Y then meta.y,meta.h = yNEW,hNEW end end     --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
   
    min_w,min_h = m.max_w*o.detect_min_ratio,m.max_h*o.detect_min_ratio
    if meta.w<min_w then if not o.USE_MIN_RATIO then meta.w,meta.x = m.max_w,0    --NULL w
        else meta.w,meta.x = min_w,math.max(0,math.min(m.max_w-min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE w
    if meta.h<min_h then if not o.USE_MIN_RATIO then meta.h,meta.y = m.max_h,0    --NULL h
        else meta.h,meta.y = min_h,math.max(0,math.min(m.max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE h

    if meta.w>m.max_w or meta.h>m.max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return end   --IF w<0 IT'S LIKE A JPEG ERROR.
    if not m.x then m.x,m.y,m.w,m.h = 0,0,m.max_w,m.max_h end  --INITIALIZE 0TH crop AT BEGINNING.
    
    -- Verify if it is necessary to crop.
    is_effective=(not m.playtime_remaining  --PROCEED IF INITIALIZING.
        or math.abs(playtime_remaining-m.playtime_remaining)>o.TOLERANCE_TIME) --PROCEED IF TIME CHANGES TOO MUCH,
            and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)  --UNLESS ALL COORDS EXACTLY THE SAME.
        or math.abs(meta.w-m.w)>m.w*o.TOLERANCE or math.abs(meta.h-m.h)>m.h*o.TOLERANCE --CHECK meta IS EFFECTIVE AT CHANGING CURRENT GEOMETRY.
        or math.abs(meta.x-m.x)>m.w*o.TOLERANCE or math.abs(meta.y-m.y)>m.h*o.TOLERANCE
    
    if not is_effective then if o.msg_info then mp.msg.info("No area detected for cropping.") end
        return end
    
    m.playtime_remaining=playtime_remaining --→MEMORY.
    apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay, detect_crop)

function apply_crop(meta) 
    if is1frame then timers.auto_delay:kill()   --audio GLITCHES ON crop, SO kill timer.
        mp.command('set pause yes') --GRAPH REPLACEMENT REQUIRES INSTA-pause, DUE TO INTERFERENCE FROM OTHER GRAPHS.
        mp.command(('%s vf pre @%s-crop:lavfi=[%s,crop=%d:%d:%d:%d:1:1,scale=%d:%d,setsar=1]')   --REPLACEMENT GRAPH. VERIFY BY TOGGLE "c" REPEATEDLY (WITH &) WITHOUT autocomplex.  REMOVING ANY GRAPH COULD GET THEM IN THE WRONG ORDER ON vid CHANGE OR TOGGLE (2 GRAPHS + FILTER + automask CAN BE DIFFICULT TO ORDER). 
            :format(o.command_prefix,label,o.detectors,meta.w,meta.h,meta.x,meta.y,W,H))
        mp.command('set pause no') --image-display-duration=inf
        return end --video BELOW.
    
    s=('clip((t-%s)/(%s),0,1)'):format(mp.get_property_number('time-pos'),o.crop_time)  --ABBREV. TIME RATIO AS s=string.  clip BTWN 0 & 1.
    mp.command(('vf-command %s x                 -((1-%s)*%d+%s*%d)       '):format( label , s,m.x, s,meta.x   ))  --INITIAL→FINAL  (1-s)→s  COORD PAIRS. overlay THEN scale.
    mp.command(('vf-command %s y                 -((1-%s)*%d+%s*%d)       '):format( label , s,m.y, s,meta.y   ))
    mp.command(('vf-command %s-crop width  max(iw/((1-%s)*%d+%s*%d)*%d,%d)'):format( label , s,m.w, s,meta.w, W, W)) --w & h ARE AMBIGUOUS.
    mp.command(('vf-command %s-crop height max(ih/((1-%s)*%d+%s*%d)*%d,%d)'):format( label , s,m.h, s,meta.h, H, H))
    m.x,m.y,m.w,m.h = meta.x,meta.y,meta.w,meta.h   --meta→m  MEMORY TRANSFER. is1frame DOESN'T NEED IT.
    
    if mp.get_property_bool('pause') then mp.command('set pause no') --UNPAUSE FOR crop_time. SAFER THAN frame-step DUE TO DOUBLE-seek CAUSING UNPAUSE (MUST HAVE pause timer ANYWAY). WORKS ON ITS OWN BUT NOT FULLY WITH automask (LAG?).
        timers.pause:kill()
        timers.pause:resume() end
end
timers.pause=mp.add_periodic_timer(o.crop_time, function() mp.command('set pause yes') end) --pause timer PAUSES.
timers.pause.oneshot=true
for _,timer in pairs(timers) do timer:kill() end    --timers CARRY OVER TO NEXT FILE IN MPV PLAYLIST.



