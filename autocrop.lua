----FOR MPV & SMPLAYER. CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 (COVER ART), & MP4. .TIFF ONE-LAYER ONLY. CAN CHANGE vid TRACK (MP3TAG) & crop.
----USE DOUBLE-mute TO TOGGLE. FRAME-STEPS WHEN PAUSED (ACTS AS A frame-step TOGGLE). CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH TOLERANCE VALUES. FULLY SUPPORTS cropdetect & bbox (ffmpeg-filters). 
----THIS VERSION HAS NO SMOOTH-CROP. AN INSTA-crop IS MORE EFFICIENT WHEN COMBINED WITH OTHER GRAPHS. WOLK WELL WITH ytdl (YOUTUBE). BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua

options={
    auto            =true,--IF false, CROPS OCCUR ONLY on_seek & on_toggle.
    auto_delay      = .5, --ORIGINAL DEFAULT=1 SECOND.  
    detect_limit    = 32, --ORIGINAL DEFAULT="24/255".  ONLY INTEGER COMPATIBLE WITH bbox (0→255). autocomplex SPECTRUM INTERFERES ON SIDES (ADD limit).
    detect_round    =  2, --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.
    detect_min_ratio=.25, --ORIGINAL DEFAULT=0.5.
    
    --ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. (JPEG NEEDS pause THOUGH.) SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    toggle_on_double_mute=.5,       --SECONDS TIMEOUT FOR DOUBLE-mute-TOGGLE. ONLY WORKS IN SMPLAYER IF THERE'S AN aid TO mute (E.G. CAN'T TOGGLE ON RAW JPEG).
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). m IS mute (IN DVORAK TOO) SO CAN DOUBLE-PRESS m. m&m DOUBLE-TAP MAYBE OUGHT TO BE automask, BUT autocrop IS MORE FUNDAMENTAL.
    
    command_prefix    ='no-osd', --DEFAULT=''. CAN SUPPRESS osd.
    detect_limit_image=64, --INTEGER 0→255, FOR JPEG & MP3 (bbox).
    detect_limits     ={   --detect_limit OVERRIDES. NOT CASE SENSITIVE. ['media-title']=detect_limit 
                        ['We are army of people - Red Army Choir']=64,
                        ['Eminem - Encore']=100,  --REPLACE WITH media-title SUBSTRING & ITS LIMIT.
                       },
    
    MAINTAIN_CENTER_X=  0, --TOLERANCE. 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK (UNLESS 1 FRAME ONLY).
    MAINTAIN_CENTER_Y=  0, --TOLERANCE. nil FOR is1frame. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (DARK FLOOR).
    TOLERANCE        =.05, --DEFAULT=0% (FOR image). INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME   = 10, --DEFAULT=10 SECONDS. IRRELEVANT IF TOLERANCE=0.
    
    USE_INNER_RECTANGLE=true,--BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    -- USE_MIN_RATIO   =true,--CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS.
    time_needed        =2,   --DEFAULT=0 SECONDS. DO NOTHING IF THIS CLOSE TO end-file. NEEDED FOR RELIABILITY.
    
    format='yuv420p',    --DEFAULT='yuv420p'  MUST REMOVE alpha DUE TO cropdetect BAD PERFORMANCE BUG.  420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    -- scale={1680,1050},--STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE).     CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS AN ABSOLUTE scale IS USED (SO I DON'T USE [vo]). EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).   DEFAULT scale=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    
    -- detector='bbox=%s',--DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'. bbox IS JPEG OVERRIDE. %s=string SUBSTITUTION, FORMATTED @file-loaded. reset>0.
    -- meta_osd =true,    --DISPLAY ALL detector METADATA.
    -- msg_info =true,    --REPORT info MESSAGES TO MPV LOG. THEY FILL THE LOG, BUT MAY HELP WITH DEBUGGING.
    
    io_write=' ',--DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY CHANGE IN vf (VIDEO FILTERS). STOPS EMBEDDED MPV FROM SNAPPING ON COVER ART. MPV MAY COMMUNICATE WITH ITS PARENT APP.
    config  ={
        'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',  --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
        'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL DEFAULT SIZE.
        'image-display-duration inf','vd-lavc-threads 0',    --inf STOPS JPEG FROM SNAPPING MPV.  0=AUTO, vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO.
    
    
    -- 'video-timing-offset 1','hr-seek-demuxer-offset 1','cache-pause-wait 0',
-- 'video-sync desync','vd-lavc-dropframe nonref','vd-lavc-skipframe nonref',   --none default nonref(SKIPnonref) bidir(SKIPBFRAMES) 
-- 'demuxer-lavf-buffersize 1e9','demuxer-max-bytes 1e9','stream-buffer-size 1e9','vd-queue-max-bytes 1e9','ad-queue-max-bytes 1e9','demuxer-max-back-bytes 1e9','audio-reversal-buffer 1e9','video-reversal-buffer 1e9','audio-buffer 1e9',
-- 'chapter-seek-threshold 1e9','vd-queue-max-samples 1e9','ad-queue-max-samples 1e9',
-- 'demuxer-backward-playback-step 1e9','cache-secs 1e9','demuxer-lavf-analyzeduration 1e9','vd-queue-max-secs 1e9','ad-queue-max-secs 1e9','demuxer-termination-timeout 1e9','demuxer-readahead-secs 1e9', 
-- 'video-backward-overlap 1e9','audio-backward-overlap 1e9','audio-backward-batch 1e9','video-backward-batch 1e9',
-- 'hr-seek always','index recreate','wayland-content-type none','background red','alpha blend',
-- 'hr-seek-framedrop yes','framedrop decoder+vo','access-references yes','ordered-chapters no','stop-playback-on-init-failure yes',
-- 'initial-audio-sync no','vd-queue-enable yes','ad-queue-enable yes','demuxer-seekable-cache yes','cache yes','demuxer-cache-wait no','cache-pause-initial no','cache-pause no',
-- 'keepaspect-window no','video-latency-hacks yes','demuxer-lavf-hacks yes','gapless-audio no','demuxer-donate-buffer yes','demuxer-thread yes','demuxer-seekable-cache yes','force-seekable yes','demuxer-lavf-linearize-timestamps no',

    
    },       
}
o,label,timers,m = options,mp.get_script_name(),{},{} --ABBREV. options. label=autocrop   m=crop MEMORY

require 'mp.options'
read_options(o)    --OPTIONAL?

for key,val in pairs({command_prefix='',detect_limit_image=o.detect_limit,detect_limits={},TOLERANCE=0,TOLERANCE_TIME=10,time_needed=0,detector='cropdetect=limit=%s:round=%s:reset=1:0',format='yuv420p',scale={},key_bindings='C',toggle_on_double_mute=0,io_write='',config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 
for _,option in pairs(o.config) do mp.command(o.command_prefix..' set '..option) end

function start_file()   --EMBEDDED MPV PLAYLISTS REQUIRE INSTA-pause BEFORE GRAPH INSERTION, TO AVOID SNAPPING.
    paused=false    --ALWAYS UNPAUSE @start-file→file-loaded.
    mp.command('set pause yes') 
    
end
mp.register_event('start-file',start_file) 

function file_loaded()  --ALSO STREAM.
    if OFF or not mp.get_property_number('current-tracks/video/id') then mp.command('set pause no')   --DO NOTHING IF NO vid OR OFF: unpause & return.
        return end   --OFF TOGGLE & NO vid → NO crop.
    
    W,H = o.scale[1],o.scale[2]
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not (W and H) then mp.add_timeout(.05,file_loaded)   --LINUX FALLBACK: RE-RUN & return. DUE TO EXCESSIVE LAG IN VIRTUALBOX.
        return end
    W,H = math.ceil(W/4)*4,math.ceil(H/4)*4   --MULTIPLES OF 4 WORK BETTER WITH overlay (FURTHER GRAPHS LIKE automask). MPV MAY SNAP INSIDE SMPLAYER ON ODD NUMBERED SIZES.
    
    is1frame,loop,MEDIA_TITLE = false,0,mp.get_property('media-title'):upper()
    detector,detect_limit = o.detector,o.detect_limit   --detect_limit MAY VARY, BUT NOT o.detect_limit
    if mp.get_property_bool('current-tracks/video/albumart') and mp.get_property('lavfi-complex')=='' then is1frame,o.auto = true,false end   --REQUIRE GRAPH REPLACEMENT (NO autocomplex LOOP). NO auto BECAUSE audio GLITCHES. albumart WITHOUT complex IS SPECIAL & DOESN'T loop.
    if mp.get_property_bool('current-tracks/video/image') then o.TOLERANCE,detector,detect_limit = 0,'bbox=%s',o.detect_limit_image --JPEG: bbox & 0 TOLERANCE (E.G. on_vid CHANGE). IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (SEE MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).
        if mp.get_property('lavfi-complex')=='' then loop,o.MAINTAIN_CENTER_X,o.MAINTAIN_CENTER_Y = -1,nil,nil end end --RAW JPEG CAN MOVE CENTER.
    if mp.get_property_bool('current-tracks/video/image') and o.io_write=='' then o.io_write=' ' end    --image NEEDS io FIX.
    mp.observe_property('vf','native',function() io.write(o.io_write) end)
    
    for title,limit in pairs(o.detect_limits) do if MEDIA_TITLE:find(title:upper(),1,true)  --1 IS STARTING INDEX. true MEANS EXACT MATCH.
        then detect_limit=limit end end --detect_limit FINAL OVERRIDE. 
    detector=detector:format(detect_limit,o.detect_round)
    
    mp.command(('%s vf pre @%s-scale:scale=w=%d:h=%d'):format(o.command_prefix,label,W,H)) --SEPARATE: "w" & "h" COMMANDS ARE AMBIGUOUS.
    mp.command(('%s vf pre @%s:lavfi=[setsar=1,format=%s,loop=%d:1,%s,crop=iw:ih:0:0:1:1]')
        :format(o.command_prefix,label,             o.format, loop,detector))
    
    ----lavfi     =[graph]  [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. REQUIRE 1 GRAPH + SEPARATE FILTER. LABELS REQUIRED FOR REPLACEMENT/COMMANDS.
    ----cropdetect=limit:round:reset:skip  DEFAULT=24/255:16:0  reset & skip BOTH MEASURED IN FRAMES. reset>0 COUNTS HOW MANY FRAMES PER DETECTION. LINUX .AppImage FAILS IF skip IS NAMED (INCOMPATIBLE).  alpha TRIGGERS BAD PERFORMANCE. CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH FOR IMPROVED RELIABILITY (LIKE pcall), BUT SHOULD BE UNNECESSARY.
    ----bbox      =min_val  (BOUNDING BOX) DEFAULT=16  REQUIRED FOR JPEG. AN INFINITE loop MAY NOT HAVE SUFFICIENT fps (0% CPU USAGE).
    ----setsar    =sar  STOPS EMBEDDED MPV SNAPPING on_vid. MACOS BUGFIX REQUIRES sar BEFORE crop (WINDOWS & LINUX DON'T). 
    ----format    =pix_fmts   BUGFIX FOR alpha CAUSING BAD PERFORMANCE, WITH cropdetect. SET TO yuva420p TO PROVE THERE'S A BUG.
    ----loop      =loop:size  (LOOPS>=-1 : FRAMES>0)  NEEDED FOR image IN MACOS. MOST RIGOROUS SOLUTION IS TO loop, INFINITE FOR TOGGLE. GRAPH REPLACEMENT CAUSED A BUG IN MACOS-CATALINA.
    ----crop      =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  CAN'T BE COMBINED WITH scale & vf-command ("w" & "h" AMBIGUOUS - NO SOLUTION). CURRENTLY HAS BUGS. WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale     =w:h  DEFAULTS iw:ih  IS THE FINISH. USING [vo] scale WOULD CAUSE SNAPPING on_vid, SO CAN USE display INSTEAD. EITHER WINDOW SNAPS IN, OR ELSE video SNAPS OUT.
    
    
    if not paused then mp.command('set pause no') end   --UNPAUSE.
    timers.auto_delay:resume() --SMALL DELAY FOR INITIAL DETECTION.
end
mp.register_event('file-loaded',file_loaded)
mp.set_property('script-opts','loop=-1,'..mp.get_property('script-opts')) --PREPEND NEW SCRIPT-OPT, FOR JPEG. TRAILING "," ALLOWED. WARNS automask NOT TO loop OVER LEAD FRAME.

function on_vid(_,vid)  --AN MP3 MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS.
    if m.vid and m.vid~=vid then paused=mp.get_property_bool('pause')
        mp.command('set pause yes') 
        file_loaded()  end  --UNFORTUNATELY EMBEDDED MPV SNAPS DUE TO CHANGING DIMENSIONS.
    m.vid=vid   --→MEMORY.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.   ALTERNATIVE: current-tracks/video/id

function on_seek()  --crop ON seek (GRAPH STATE IS RESET).
    m.x,m.playtime_remaining = nil,nil  --CLEAR MEMORY (m.x=nil → RE-INITIALIZES).
    if not is1frame then timers.auto_delay:resume() end     --is1frame RE-SEEKS ON crop. NEEDED IN CASE NOT o.auto.
end
mp.register_event('seek',on_seek) 

function on_pause(_,paused) --BUGFIX FOR NEW DETECTION on_pause (FRAME-STEPS).
    if paused then timers.auto_delay:kill()
    else           timers.auto_delay:resume() end
end
mp.observe_property('pause', 'bool', on_pause)

function on_toggle(mute)    --INSTA-TOGGLE (SWITCH), NOT PROPER FULL toggle.
    if not W then return end --NOT loaded YET.
    if mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,m.playtime_remaining = not OFF,nil
    if not OFF then detect_crop() --TOGGLE ON.
    else apply_crop({ x=0,y=0, w=m.max_w,h=m.max_h }) end    --TOGGLE OFF. NULL crop.
end
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_crop_'..key, on_toggle) end    --gmatch IS GLOBAL MATCH ITERATOR. %g+ IS LONGEST string EXCLUDING SPACE.
mp.observe_property('mute', 'bool', on_toggle)

timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --double_mute timer
timers.mute.oneshot=true 

function detect_crop()
    if OFF then return end     --TOGGLED OFF. 
    timers.auto_delay:resume()
    if not o.auto then timers.auto_delay:kill() end    
    
    if o.meta_osd then meta=mp.get_property_osd('vf-metadata/'..label)
        if meta then mp.osd_message(meta) end end   --DISPLAY COORDS FOR 1 SEC.
    
    meta=mp.get_property_native('vf-metadata/'..label)  -- Get the metadata.
    if not meta then if o.msg_info then mp.msg.error("No crop metadata.")    --Verify the existence of metadata. SOMETIMES IT'S {}, WHICH FAILS THE NEXT TEST.
                                        mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?") end
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
    
    m.max_w,m.max_h = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h')
    if o.MAINTAIN_CENTER_X then xNEW=math.min( meta.x , m.max_w-(meta.x+meta.w) )  --KEEP HORIZONTAL CENTER, E.G. SO THAT BINOCULARS ARE CENTERED.    SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL.
        wNEW=m.max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
        if wNEW-meta.w>wNEW*o.MAINTAIN_CENTER_X then meta.x,meta.w = xNEW,wNEW end end
    if o.MAINTAIN_CENTER_Y then yNEW=math.min( meta.y , m.max_h-(meta.y+meta.h) )     -- KEEP VERTICAL CENTERED, E.G. PORTRAITS WHERE FEET GET CROPPED OFF. 
        hNEW=m.max_h-yNEW*2
        if hNEW-meta.h>hNEW*o.MAINTAIN_CENTER_Y then meta.y,meta.h = yNEW,hNEW end end     --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
   
    min_w,min_h,playtime_remaining = m.max_w*o.detect_min_ratio,m.max_h*o.detect_min_ratio,mp.get_property_number('playtime-remaining')
    if meta.w<min_w then if not o.USE_MIN_RATIO then meta.w,meta.x = m.max_w,0    --NULL w
        else meta.w,meta.x = min_w,math.max(0,math.min(m.max_w-min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE w
    if meta.h<min_h then if not o.USE_MIN_RATIO then meta.h,meta.y = m.max_h,0    --NULL h
        else meta.h,meta.y = min_h,math.max(0,math.min(m.max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE h

    if meta.w>m.max_w or meta.h>m.max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then return end   --IF w<0 IT'S LIKE A JPEG ERROR.
    if not m.x then m.x,m.y,m.w,m.h = 0,0,m.max_w,m.max_h end  --INITIALIZE 0TH crop AT BEGINNING.
    
    is_effective=(not m.playtime_remaining  --Verify if it is necessary to crop.    PROCEED IF INITIALIZING, OR JPEG.
        or math.abs(playtime_remaining-m.playtime_remaining)>o.TOLERANCE_TIME) --PROCEED IF TIME CHANGES TOO MUCH,
            and (meta.w~=m.w or meta.h~=m.h or meta.x~=m.x or meta.y~=m.y)  --UNLESS ALL COORDS EXACTLY THE SAME.
        or math.abs(meta.w-m.w)>m.w*o.TOLERANCE or math.abs(meta.h-m.h)>m.h*o.TOLERANCE --CHECK meta IS EFFECTIVE AT CHANGING CURRENT GEOMETRY.
        or math.abs(meta.x-m.x)>m.w*o.TOLERANCE or math.abs(meta.y-m.y)>m.h*o.TOLERANCE
    
    if not is_effective then if o.msg_info then mp.msg.info("No area detected for cropping.") end
        return end
    apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay, function() pcall(detect_crop) end)  --pcall FOR MAIN timer MAY HAVE BETTER RELIABILITY.
for _,timer in pairs(timers) do timer:kill() end    --timers CARRY OVER TO NEXT FILE IN MPV PLAYLIST.

function apply_crop(meta) 
    mp.command(('vf-command %s w %d'):format(label,meta.w)) --ANY ORDER.
    mp.command(('vf-command %s h %d'):format(label,meta.h))
    mp.command(('vf-command %s x %d'):format(label,meta.x))
    mp.command(('vf-command %s y %d'):format(label,meta.y))
    m.x,m.y,m.w,m.h,m.playtime_remaining,paused = meta.x,meta.y,meta.w,meta.h,playtime_remaining,mp.get_property_bool('pause')    --meta→m  MEMORY TRANSFER. 
    
    if not is1frame then if paused then N=0   --vf-command BUGFIX FOR PAUSED MP4. frame-step IS SAFER THAN GRAPH REPLACEMENT DUE TO INTERFERENCE FROM OTHER GRAPHS (REPLACING ONE RESETS THEM ALL).
            while N<6 do                N=N+1  --6 REQUIRED FOR ytdl. SAME AS automask. FRAMES ALREADY DRAWN IN ADVANCE. AN UNPAUSE→pause timer CAN ALSO BE USED.
                mp.command('frame-step') end end
        return end --is1frame BELOW.

    mp.command('set pause yes') --GRAPH REPLACEMENT REQUIRES INSTA-pause, DUE TO INTERFERENCE FROM OTHER GRAPHS.
    mp.command(('%s vf pre @%s:lavfi=[setsar=1,format=%s,%s,crop=%d:%d:%d:%d:1:1]')    --REPLACEMENT GRAPH. VERIFY BY TOGGLE "c" REPEATEDLY (WITH &) WITHOUT automask.
        :format(o.command_prefix,label,o.format,detector,meta.w,meta.h,meta.x,meta.y))
    if not paused then mp.command('set pause no') end --image-display-duration=inf
end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----BUG: RAW JPEG ON MACOS → BLACK SCREEN. WORKS WITH autocomplex.

----ALTERNATIVE FILTERS:
----noformat=pix_fmts  FAILS TO BLOCK alpha. cropdetect PERFORMS BADLY WITH TRANSPARENT INPUT (EVEN IF 100% OPAQUE). THERE'S A LONG LIST.  PROOF: REPLACE WITH format=yuva420p & IT CAUSES LAG.
----split      CLONES video. UNNECESSARY. THIS IS A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS. THERE IS NO WORKAROUND FOR HAVING TO MAGNIFY UP FIRST, SO POOR PPL WITH CHEAP CPU MUST SUFFER LAG.
----overlay   =x:y DEFAULT=0:0 n=1@INSERTION (OFF)  UNNECESSARY. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.



