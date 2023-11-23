----AUTO-CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 (COVER ART), & MP4. .TIFF ONE-LAYER ONLY. CAN CHANGE vid TRACK & crop. JPEG MAY WORK BETTER WITH autocomplex.lua (BUT WITH MORE CPU USAGE).
----THIS VERSION HAS DOUBLE-mute TOGGLE, & MAINTAINS CENTER IN HORIZONTAL/VERTICAL, WITH TOLERANCE VALUES. ALSO SUPPORTS MULTIPLE DETECTORS, & bbox.
----BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua
local options = {
    auto            =true,  --IF false, CROPS STILL OCCUR WHEN SEEKING, OR WITH KEYBOARD & DOUBLE-MUTE TOGGLES.
    auto_delay      =.5,    --ORIGINAL DEFAULT=1. LOWERING THIS MAY CROP TOO QUICKLY.
    detect_limit    =32/255,--ORIGINAL DEFAULT="24/255".  BASED ON 8-BITS (0→255).
    detect_round    =4,     --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.  USE MULTIPLES OF 4 AS FINAL scale OR ELSE EMBEDDED MPV SNAPS.
    detect_min_ratio=.25,   --ORIGINAL DEFAULT=0.5.
    detect_seconds  =.05,   --ORIGINAL DEFAULT=1. CAN BE 0 BUT WORKS BETTER AT LEAST 50ms (E.G. WHEN CROPPING PAUSED STILL FRAMES).
    
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN ACTION aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    command_prefix='no-osd',    --DEFAULT=''. CAN SUPPRESS osd.
    detect_limits ={   --NOT CASE SENSITIVE. detect_limit MAY VARY WITH media-title IF THE FOLLOWING SUBSTRINGS ARE FOUND.
                    ['We are army of people - Red Army Choir']=64,
                    [                       'L.A.D.Y G.A.G.A']=100,
                   },
    
    MAINTAIN_CENTER_X=0,    --TOLERANCE, 0 MEANS NEVER MOVE THE CENTER. ALLOW 25% MOVEMENT IN HORIZONTAL. MAINTAIN HORIZONTAL CENTER OF VIDEO.
    MAINTAIN_CENTER_Y=.25,  --TOLERANCE. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO AT MOST 1/3 TO BE SAVED.
    TOLERANCE_RATIO  =.05,  --DEFAULT=.02. crop INSTANTLY IF COORDS CHANGE BY MORE THAN 5%, OR ELSE EVERY 60 SECONDS. SO A BIG crop IS INSTANT, BUT NOT LITTLE CROPS.
    TOLERANCE_TIME   =60,   --DEFAULT=60 SECONDS. IRRELEVANT IF TOLERANCE_RATIO=0.
    
    min_crop           =true,   --CROP ALL THE WAY DOWN TO detect_min_ratio.
    USE_INNER_RECTANGLE=true,   --BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW X2-X1. 
    time_needed        =2,      --DEFAULT=0 SECONDS. DO NOTHING IF THIS CLOSE TO VIDEO END (NECESSARY), OR FOLLOWING pause (OPTIONAL).
    
    CROPFRAMES=8,   --DEFAULT=1 (NO SMOOTHCROP). CROPS/CROP FOR SMOOTHCROP, & SECONDS TO WAIT BTWN SUCCESSIVE CROPS FOR SMOOTH CROPPING.    vf-command IS TOO CHOPPY. MAY NEED TO USE buffer.
    crop_delay=.01, --REMOVE FOR NO SMOOTHCROP (COMBO LAG DUE TO OTHER SCRIPTS). TEST WITH DOUBLE-mute.
    
    -- detectors ='cropdetect=%s:%s:1:0,cropdetect=%s:%s:1:0',  --MULTIPLE detectors. DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'. 'bbox=%s' IS AUTO-JPEG OVERRIDE.   %s=string SUBSTITUTION, FORMATTED @file-loaded. EXTRA cropdetect OR bbox DETECTORS MAYBE NEEDED FOR RELIABILITY, ALL IN THE autocrop GRAPH. reset>0 FOR vf_command. skip=0 FOR JPEG. 
    -- meta_osd  =true,     --DISPLAY ALL DETECTOR METADATA.
    -- scale={1680,1050},   --STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE). CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS AN ABSOLUTE scale IS USED (SO I DON'T USE [vo]). EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).   DEFAULT scale=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    -- vf_command=true,     --EXPERIMENTAL. SHOULD WORK IN FUTURE, BUT TOO RISKY & CRASHES DEPENDING ON OTHER SCRIPTS. USES vf-command INSTEAD OF GRAPH REPLACEMENT.
    
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. J IS DVORAK FOR C (CROP), BUT IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). THESE DON'T WORK INSIDE SMPLAYER. 
    toggle_on_double_mute=.5,       --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute-TOGGLE. IN SMPLAYER (OR ON SMARTPHONE) TOGGLE CROPPING BY MUTING, INSTEAD OF KEYBOARD SHORTCUT. ONLY WORKS IF THERE'S AN aid TO mute (E.G. CAN'T TOGGLE ON RAW .JPG).
    
    config={
            'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',  --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
            'image-display-duration inf','keepaspect no','geometry 50%',      --STOPPING IMAGES CAUSES MPV TO SNAP. no-keepaspect (FREE aspect) & geometry ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER.
            'video-timing-offset 1','hwdec auto-copy','vd-lavc-threads 0',    --IMPROVED PERFORMANCE FOR LINUX .AppImage. DEFAULT offset=.05 SECONDS (RENDERING TIME). hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
            -- 'msg-level ffmpeg=fatal',    --FOR vf_command.
           },       
}
local o,label,timers = options,mp.get_script_name(),{} --ABBREV. options. label=autocrop

require 'mp.options'   --OPTIONAL
read_options(o)

for key,val in pairs({command_prefix='',detect_limits={},TOLERANCE_RATIO=.02,TOLERANCE_TIME=60,time_needed=0,scale={},detectors='cropdetect=limit=%s:round=%s:reset=1:0',key_bindings='C',toggle_on_double_mute=0,config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command(o.command_prefix..' set '..option) end   --APPLY config BEFORE scripts.
if mp.get_property('vid')=='no' then exit() end    --OPTIONAL: NO VIDEO→EXIT.
if not o.crop_delay or not o.CROPFRAMES or o.crop_delay<=0 or o.CROPFRAMES<=1 then o.crop_delay,o.CROPFRAMES = 1,1 end --DEFAULT: NO SMOOTH CROPPING.

local m={width=o.scale[1], height=o.scale[2]} --crop METADATA scale OVERRIDE.
if m.width and m.height then mp.command(('%s vf pre @%s:lavfi=[scale=%s:%s,setsar=1]'):format(o.command_prefix,label,m.width,m.height)) end  --OPTIONAL scale OVERRIDE: STOPS EMBEDDED MPV SNAPPING. scale,setsar DEFINE THE SNAP GRAPH (SAME LABEL).

function file_loaded(_,seeking) --OVERLOADS FOR vid TRACK CHANGE - INITIAL SEEK. TRACK CHANGE IS LIKE A NEW FILE-LOAD.
    if seeking then return end   --NEW vid STILL seeking.
    mp.unobserve_property(file_loaded)
    if not mp.get_property_number('current-tracks/video/id') then return end    --DO NOTHING: DIFFERENT format & POSITIONING FOR ABSTRACT MP3 VISUALS.
                                       
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not (m.width and m.height) then mp.add_timeout(.01,file_loaded)  --FALLBACK: RE-RUN & return IF [vo] ISN'T READY (LINUX snap). 
        return end  
    m.width,m.height = math.ceil(m.width/4)*4,math.ceil(m.height/4)*4     --MULTIPLES OF 4 WORK BETTER WITH overlay (FURTHER GRAPHS LIKE automask). MPV MAY SNAP INSIDE SMPLAYER ON ODD NUMBERED SIZES. autocrop CAN BUG OUT IF THERE IS NO width,height (LINUX snap RAW MP3).
    
    local  l,r , MEDIA_TITLE  =  o.detect_limit,o.detect_round , mp.get_property('media-title'):upper() --current-tracks PROPERTIES AWAIT file-loaded. 
    for title,detect_limit in pairs(o.detect_limits) do if MEDIA_TITLE:find(title:upper(),1,true)   --1 IS STARTING INDEX. true DISABLES MAGIC SYMBOLS LIKE '%s'.
        then l=detect_limit  --CHANGE detect_limit FOR DIFFICULT FILES. 
            break end end
    
    if mp.get_property_bool('current-tracks/video/image') then o.detectors,o.CROPFRAMES = 'bbox=%s',1    --JPEG OVERRIDE USING 0% OF CPU. autocrop USEFUL FOR MP3 IF IT USES 0% CPU. bbox WORKS BETTER THAN cropdetect (BUGGY). NO SMOOTHCROP. IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. 
        mp.unobserve_property(on_pause)
        if not mp.get_property_number('time-remaining') and mp.get_property('lavfi-complex')=='' then unpause=not mp.get_property_bool('pause')
            mp.command(o.command_prefix..' set pause yes') end end --crop ONLY WORKS ON AN image IF IT'S PAUSED OR LOOPING (autocomplex). unpause RETURNS pause STATE. complex IS FASTER, BUT CAN'T CHANGE TRACK LIKE THIS METHOD.
    o.detectors=o.detectors:format( l,r , l,r , l,r , l,r ) --CAN COMBINE A FEW DETECTORS, IN 1 GRAPH.
    
     lavfi=('%s,crop=%%s:%%s:%%s:%%s,scale=%d:%d,setsar=1')
        :format(o.detectors,          m.width,m.height  ) 
       
    ----lavfi     =[graph]  [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. %%s SUBS OCCUR LATER. EACH LUA MAY CONTROL A GRAPH (WHOSE string IS LIKE DNA).
    ----cropdetect=limit:round:reset:skip  [vo]→[vo]  DEFAULTS 24/255:16:0  skip CAN'T BE NAMED IN LINUX .AppImage.  DEPENDS CRITICALLY ON format. alpha TRIGGERS VERY BAD PERFORMANCE.
    ----bbox      =min_val  DEFAULT 16. REQUIRED FOR JPEG & COVER ART (BETTER PERFORMANCE).
    ----crop      =out_w:out_h:x:y  DEFAULT iw:ih:(iw-ow)/2:(ih-oh)/2  vf-command ONLY CHANGES 1 # AT A TIME (CHOPPY). WON'T CHANGE DIMENSIONS WITH time (SMOOTHCROP BUG).
    ----scale     =width:height DEFAULT=iw:ih   MULTIPLES OF 4 AVOID SNAPPING. (TEST ODD NUMBERED JPEGS.)   A scale2display FILTER IS UNAVAILABLE.
    ----setsar    =sar IS THE FINISH. MACOS BUGFIX REQUIRES sar (WINDOWS & LINUX DON'T). ALONG WITH scale, STOPS EMBEDDED MPV SNAPPING INTERNAL WINDOW. WHEN CHANGING vid (MP3TAG) IT SNAPS WITHOUT display scale ([vo] CHANGING).
    
    
    mp.command(('%s vf pre @%s:lavfi=[%s]'):format(o.command_prefix,label,lavfi)   --LINUX .AppImage MAY FAIL IF GRAPH IS INSERTED BEFORE file-loaded. DELAY CAN CAUSE EMBEDDED MPV TO SNAP.
                                           :format('iw','ih',0,0))
    
    detecting=false
    mp.observe_property('seeking', 'bool', detect_crop)  --observe_property TRIGGERS INSTANTLY (TO SEND INITIAL bool). HOWEVER IT TAKES TIME TO COMPLETE INITIAL seek (E.G. LARGE .PNG).
end
mp.register_event('file-loaded', file_loaded)
mp.observe_property('current-tracks/video/id','number',function() if m.x then mp.observe_property('seeking','bool',file_loaded) end end)  --m.x MEANS AFTER INITIALIZED. CHANGE OF VIDEO TRACK IS TREATED SAME AS LOADING A NEW FILE. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).

function on_toggle(mute_observed)
    if mute_observed and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,detecting,m.playtime_remaining = not OFF,false,nil
    if not OFF then detect_crop()    --TOGGLE ON.
    else for _,timer in pairs(timers) do timer:kill() end    --TOGGLE OFF. 
        apply_crop({x=0, y=0, out_w=m.max_w, out_h=m.max_h}) end  --CAN ANIMATE crop REMOVAL.
end
mp.observe_property('mute', 'bool', on_toggle)
for key in (o.key_bindings):gmatch('%g+') do mp.add_key_binding(key, 'toggle_crop_'..key, on_toggle) end

function on_pause() --OPTIONAL.     FOR SNAPPY PAUSING kill ALL timers & resume AFTER time_needed.
    if lavfi then for _,timer in pairs(timers) do timer:kill() end     --DO NOTHING IF NOT PLACED YET.
        detecting=false
        if not OFF then timers.pause:resume() end end
end
mp.observe_property('pause', 'bool', on_pause)  --OPTIONAL.

function detect_crop()
    if not timers.auto_delay then return end    --HAVEN'T LOADED YET.
    if o.auto then timers.auto_delay:kill()     --RESET auto TIMER.
        timers.auto_delay:resume() end    
    
    if detecting or mp.get_property_bool('seeking') then return end  --DO NOTHING IF ALREADY detecting OR seeking.
    detecting=true  --OPTIONAL SWITCH WHICH KEEPS TRACK OF WHETHER ALREADY detecting.
             
    local playtime_remaining=mp.get_property_number('playtime-remaining')   --JPEG=nil
    if OFF or playtime_remaining and (playtime_remaining==m.playtime_remaining or playtime_remaining<o.time_needed) then detecting=false    --TOGGLED OFF, ALREADY ANALYZED, NEAR video END.
        return end
    m.playtime_remaining=playtime_remaining   --REMEMBER THIS TIME IS ALREADY DONE.
    timers.detect_crop:resume() --Wait to gather metadata.
end

function detect_end()
    -- Get the metadata.
    local meta,params = mp.get_property_native('vf-metadata/'..label),mp.get_property_native('video-params')
    if not meta then detecting=false    --Verify the existence of metadata. SOMETIMES IT'S AN EMPTY table, WHICH FAILS THE NEXT TEST.
        mp.msg.error("No crop metadata.")
        mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?")
        return end 
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('%g+') do local value=meta['lavfi.cropdetect.'..key] --gmatch IS GLOBAL MATCH ITERATOR. %g+ IS LONGEST STRING TO SPACEBAR.
        if not value then value=meta['lavfi.bbox.'..key] end
        meta[key]=tonumber(value) end   --tonumber(nil)=nil
    
    if not (meta.w and meta.h and meta.x1 and meta.y1 and meta.x2 and meta.y2) then detecting=false  --THIS CAN HAPPEN IF VID IS PAUSED.
         mp.msg.error("Got empty crop data.")    
         mp.msg.info("You might need to increase detect_seconds.")
         return end 
    if o.meta_osd then mp.osd_message(mp.get_property_osd('vf-metadata/'..label)) end   --DISPLAY COORDS. 1 SECOND.

    if not meta.x or not meta.y then meta.x,meta.y = (meta.x1+meta.x2-meta.w)/2,(meta.y1+meta.y2-meta.h)/2 end     --bbox GIVES x1 & x2 BUT NOT x. CALCULATE x & y BY TAKING AVERAGE.
    if o.USE_INNER_RECTANGLE then local xNEW,yNEW = math.max(meta.x1,meta.x2-meta.w,meta.x),math.max(meta.y1,meta.y2-meta.h,meta.y)
            meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
            meta.x ,meta.y  = xNEW,yNEW
            meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    m.max_w,m.max_h = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h')
    if o.MAINTAIN_CENTER_X then local xNEW = math.min(meta.x, m.max_w-(meta.x+meta.w))  --KEEP HORIZONTAL CENTER, E.G. SO THAT BINOCULARS ARE CENTERED.    SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL.
        local wNEW = m.max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
        if wNEW-meta.w>wNEW*o.MAINTAIN_CENTER_X then meta.x,meta.w = xNEW,wNEW end end
    if o.MAINTAIN_CENTER_Y then local yNEW = math.min(meta.y, m.max_h-(meta.y+meta.h))     -- KEEP VERTICAL CENTERED, E.G. PORTRAITS WHERE FEET GET CROPPED OFF. 
        local hNEW = m.max_h-yNEW*2
        if hNEW-meta.h > hNEW*o.MAINTAIN_CENTER_Y then meta.y,meta.h = yNEW,hNEW end end     --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
   
    local min_w,min_h = m.max_w*o.detect_min_ratio,m.max_h*o.detect_min_ratio
    if meta.w<min_w then if not o.min_crop then meta.w,meta.x = m.max_w ,0    --NULLIFY crop out_w.
        else meta.w,meta.x = min_w,math.max(0,math.min(m.max_w -min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE out_w.
    if meta.h<min_h then if not o.min_crop then meta.h,meta.y = m.max_h,0    --NULLIFY crop out_h.
        else meta.h,meta.y = min_h,math.max(0,math.min(m.max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE out_h.

    if meta.w>m.max_w or meta.h>m.max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then detecting = false  ----IF w<0 IT'S LIKE A JPEG ERROR.
        return end 
    
    -- Verify if it is necessary to crop.
    meta.out_w,meta.out_h = meta.w,meta.h   --w,h → out_w,out_h 
    if not m.x then m.x,m.y,m.out_w,m.out_h = 0,0,m.max_w,m.max_h end    --INITIALIZE 0TH crop AT BEGINNING.
    local is_effective=not crop_playtime_remaining  --PROCEED IF NO playtime_remaining AT LAST crop.
            or math.abs(m.playtime_remaining-crop_playtime_remaining)>o.TOLERANCE_TIME --PROCEED IF TIME CHANGES TOO MUCH,
                and (meta.out_w~=m.out_w or meta.out_h~=m.out_h or meta.x~=m.x or meta.y~=m.y)  --UNLESS ALL COORDS EXACTLY THE SAME.
            or math.abs(meta.out_w-m.out_w)>m.out_w*o.TOLERANCE_RATIO or math.abs(meta.out_h-m.out_h)>m.out_h*o.TOLERANCE_RATIO --CHECK meta IS EFFECTIVE AT CHANGING CURRENT GEOMETRY.
            or math.abs(meta.x-m.x)>m.out_w*o.TOLERANCE_RATIO or math.abs(meta.y-m.y)>m.out_h*o.TOLERANCE_RATIO
    
    if not is_effective then detecting=false
        mp.msg.info("No area detected for cropping.") 
        return end
    
    crop_playtime_remaining,detecting = m.playtime_remaining,false
    apply_crop(meta)
end

function apply_crop(meta) 
    if meta then CROPFRAME=1   --meta MEANS NEW crop, OR IT'S ANIMATING NEXT FRAME.
        timers.SMOOTHCROP:kill()
        for key in ('x y out_w out_h'):gmatch('%g+') do m[key..'T']=meta[key] end    --TARGETS. REMEMBER COORDS FROM meta INPUT.
    else CROPFRAME=CROPFRAME+1 end
    for key in ('x y out_w out_h'):gmatch('%g+') do m[key]=m[key]+(m[key..'T']-m[key])/(1+o.CROPFRAMES-CROPFRAME) end    --LINEARIZE COORDS FOR SMOOTHCROP ANIMATION (crop vf-command TOO CHOPPY, THOUGH).
    
    if o.vf_command then for key in ('x y out_w out_h width height'):gmatch('%g+') do mp.command(('%s vf-command %s %s %s'):format(o.command_prefix,label,key,m[key])) end --x y FIRST, BY TRIAL & ERROR.
    else mp.command(('%s vf pre @%s:lavfi=[%s]'):format(o.command_prefix,label,lavfi)  --Apply crop. GRAPH REPLACEMENT. SAFER OPTION. SANDWICHED BTWN autocomplex & automask.
                                                :format(m.out_w,m.out_h,m.x,m.y)) end 

    if timers.auto_delay:is_enabled() then timers.auto_delay:kill()    --DELAY NEXT AUTO DETECTION, TO STEADY THE crop.
         timers.auto_delay:resume() end  
    if CROPFRAME<o.CROPFRAMES then timers.SMOOTHCROP:resume() end  --NEXT SMOOTHCROP.
    
    if mp.get_property_bool('current-tracks/video/image') then o.auto=false    --DISABLE timer AFTER SUCCESSFUL crop.
        timers.auto_delay:kill()
        mp.unobserve_property(detect_crop) end   --JPEG: DON'T OBSERVE FURTHER.
    if unpause then mp.command(o.command_prefix..' set pause no') end --RAW JPEG MAY REQUIRE AN UNPAUSED seek.
end

for keys,func in pairs({    --CREATE timers, FOLLOWING ALL FUNCTIONS. THEY CARRY OVER FROM video→video IN PLAYLIST. 
        ['auto_delay      auto_delay']=detect_crop, --['label' 'delay']=func,
        ['detect_crop detect_seconds']=detect_end,
        ['SMOOTHCROP      crop_delay']=apply_crop,
        ['pause          time_needed']=detect_crop,
        ['mute toggle_on_double_mute']=function()end,
    })
do keys=keys:gmatch('%g+')
   local label=keys()
   timers[label]=mp.add_periodic_timer(o[keys()], function() pcall(func) end)     --A pcall timer (PROTECTED CALL) MAY BE SAFER IF A FUNCTION MIGHT RETURN AN ERROR.
   timers[label]:kill()
   timers[label].oneshot=true end


----FORMATTING FOR cropdetect ACTUALLY REDUCES PERFORMANCE OF SMOOTHCROP.
----format    =pix_fmts yuv422p yuv440p yuv444p WORK IN MY JPEG TESTS. 422 HALVES COLOR-W, 440 HALVES COLOR-H. yuv420p rgb24 yuva420p rgb32 ALL FAIL.



