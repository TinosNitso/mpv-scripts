----CURRENTLY UNABLE TO CROP JPEG DIRECTLY WITHOUT autocomplex. THIS IS A RESULT OF NEVER REPLACING THE GRAPH (vf-command ONLY).
----SMOOTHLY AUTO-CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 (COVER ART), & MP4. .TIFF ONE-LAYER ONLY. CAN CHANGE vid TRACK & crop. JPEG MAY WORK BETTER WITH autocomplex.lua (BUT WITH MORE CPU USAGE).
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAINS CENTER IN HORIZONTAL/VERTICAL, WITH TOLERANCE VALUES. ALSO SUPPORTS MULTIPLE DETECTORS, & bbox. 
----THIS VERSION MAKES SMOOTH-CROPPING SMOOTHER USING A NEGATIVE overlay (crop BUG WORKAROUND). NOT PERFECT BECAUSE OF RE-split ON crop. BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua
local options = {
    auto            =true,--IF false, CROPS STILL OCCUR WHEN SEEKING & TOGGLE.
    auto_delay      = .5, --ORIGINAL DEFAULT=1.
    detect_limit    = 32, --ORIGINAL DEFAULT="24/255".  ONLY INTEGER COMPATIBLE WITH bbox (0→255). autocomplex OVERLAY MAY INTERFERE.
    detect_round    =  4, --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.
    detect_min_ratio=.25, --ORIGINAL DEFAULT=0.5.
    detect_seconds  =.05, --ORIGINAL DEFAULT=1. INTERMEDIATE DELAY BTWN INITIAL INSERTION & ANALYSIS.
    
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    crop_time     =.3,      --DEFAULT=.3 SECONDS. TIME PER SMOOTH-CROP (TO STRETCH OUT BLACK BARS). 
    crop_time     =.5,      --DEFAULT=.3 SECONDS. TIME PER SMOOTH-CROP (TO STRETCH OUT BLACK BARS). 
    command_prefix='no-osd',--DEFAULT=''. CAN SUPPRESS osd.
    
    detect_limits ={        --NOT CASE SENSITIVE. detect_limit MAY VARY WITH media-title IF THE FOLLOWING SUBSTRINGS ARE FOUND.
                    ['We are army of people - Red Army Choir']= 64,
                    [                       'L.A.D.Y G.A.G.A']=100,
                   },
    
    MAINTAIN_CENTER_X=  0, --TOLERANCE, 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS).
    MAINTAIN_CENTER_Y=.25, --TOLERANCE. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO AT MOST 1/3 TO BE SAVED.
    TOLERANCE_RATIO  =  0, --DEFAULT=.05. crop INSTANTLY IF COORDS CHANGE BY MORE THAN 2%, OR ELSE EVERY 60 SECONDS. SO A BIG crop IS INSTANT, BUT NOT LITTLE CROPS.
    TOLERANCE_TIME   = 60, --DEFAULT=60 SECONDS. IRRELEVANT IF TOLERANCE_RATIO=0.
    
    USE_INNER_RECTANGLE=true,--BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW X2-X1. 
    min_crop           =true,--CROP ALL THE WAY DOWN TO detect_min_ratio.
    time_needed        =2,   --DEFAULT=0 SECONDS. DO NOTHING IF THIS CLOSE TO VIDEO END (NECESSARY), OR FOLLOWING pause (OPTIONAL).
    
    -- scale    ={1680,1050},--STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE).     CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS AN ABSOLUTE scale IS USED (SO I DON'T USE [vo]). EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).   DEFAULT scale=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    -- meta_osd =true,       --DISPLAY ALL DETECTOR METADATA.
    -- detectors='bbox=%s',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'. bbox IS AUTO-JPEG OVERRIDE. MULTIPLE detectors: 'cropdetect=%s:%s:1:0,cropdetect=%s:%s:1:0' FOR IMPROVED RELIABILITY.   %s=string SUBSTITUTION, FORMATTED @file-loaded. reset>0 FOR vf_command. skip=0 FOR JPEG. 
    
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. J IS DVORAK FOR C (CROP), BUT IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). THESE DON'T WORK INSIDE SMPLAYER. 
    toggle_on_double_mute=.5,       --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute-TOGGLE. IN SMPLAYER (OR ON SMARTPHONE) TOGGLE CROPPING BY MUTING, INSTEAD OF KEYBOARD SHORTCUT. ONLY WORKS IF THERE'S AN aid TO mute (E.G. CAN'T TOGGLE ON RAW .JPG).
    
    config={
            'osd-font-size 16','osd-border-size 1','osd-scale-by-window no',  --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
            'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL SIZE.
            'image-display-duration inf','video-timing-offset 1', --STOPS IMAGES FROM SNAPPING MPV. DEFAULT offset=.05 SECONDS ALSO WORKS.
            'hwdec auto-copy','vd-lavc-threads 0',    --IMPROVED PERFORMANCE FOR LINUX .AppImage.  hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
            'alpha blend', --BUGFIX FOR LINUX flatpak, OR ELSE GRAPH CAN FORCE format AFTER NEGATIVE overlay.
           },       
}
local o,label,timers = options,mp.get_script_name(),{} --ABBREV. options. label=autocrop

require 'mp.options'   --OPTIONAL
read_options(o)

for key,val in pairs({command_prefix='',detect_limits={},TOLERANCE_RATIO=.05,TOLERANCE_TIME=60,time_needed=0,crop_time=.3,scale={},detectors='cropdetect=limit=%s:round=%s:reset=1:0',key_bindings='C',toggle_on_double_mute=0,config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command(o.command_prefix..' set '..option) end   --APPLY config BEFORE scripts.
if mp.get_property('vid')=='no' then exit() end    --OPTIONAL: NO VIDEO→EXIT.

local m={width=o.scale[1], height=o.scale[2]} --crop METADATA scale OVERRIDE.
if m.width and m.height then mp.command(('%s vf pre @%s2:lavfi=[scale=%s:%s,setsar=1]'):format(o.command_prefix,label,m.width,m.height)) end  --OPTIONAL scale OVERRIDE: STOPS EMBEDDED MPV SNAPPING. scale,setsar DEFINE THE SNAP GRAPH (SAME LABEL).

function file_loaded(_,seeking) 
    if seeking or OFF or not mp.get_property_number('current-tracks/video/id') then return end    --DO NOTHING UNTIL DONE seeking, TOGGLED BACK ON, OR IF video/id=nil. ABSTRACT MP3 VISUALS MAY HAVE alpha & cropdetect MAY PERFORM BADLY.
    
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not (m.width and m.height) then mp.add_timeout(.05,file_loaded)  --LINUX snap FALLBACK: RE-RUN & return IF [vo] ISN'T READY. 
        return end  
    m.width,m.height,detecting = math.ceil(m.width/4)*4,math.ceil(m.height/4)*4,false   --MULTIPLES OF 4 WORK BETTER WITH overlay (FURTHER GRAPHS LIKE automask). MPV MAY SNAP INSIDE SMPLAYER ON ODD NUMBERED SIZES. autocrop CAN BUG OUT IF THERE IS NO width,height (LINUX snap RAW MP3).
    
    local  l,r , MEDIA_TITLE  =  o.detect_limit,o.detect_round , mp.get_property('media-title'):upper() --current-tracks PROPERTIES AWAIT file-loaded. 
    for title,detect_limit in pairs(o.detect_limits) do if MEDIA_TITLE:find(title:upper(),1,true)   --1 IS STARTING INDEX. true DISABLES MAGIC SYMBOLS LIKE '%s'.
        then l=detect_limit  --CHANGE detect_limit FOR DIFFICULT FILES. 
            break end end
    
    if mp.get_property_bool('current-tracks/video/image') then o.detectors='bbox=%s'    --JPEG OVERRIDE. bbox SUPERIOR TO cropdetect (BUGGY ON MACOS). IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (SEE MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).
        if mp.get_property('lavfi-complex')=='' then unpause,timers.detect_crop.timeout = not mp.get_property_bool('pause'),math.max(1,o.detect_seconds) --JPEG MASK NEEDS pause OR loop FOR INSERTION. unpause RETURNS pause STATE. MAY REQUIRE A SECOND FOR HIGH RES (SLOW ON JPEG WITHOUT complex). 
            -- mp.command('no-osd set pause yes') 
            end end  
    o.detectors=o.detectors:format( l,r , l,r , l,r , l,r ) --CAN COMBINE A FEW DETECTORS, IN 1 GRAPH.
    
    -- mp.command(('%s vf pre @%s2:lavfi=[crop=min(iw\\,%d):min(ih\\,%d):0:0,scale=%d:%d,setsar=1]'):format(o.command_prefix,label,m.width,m.height,m.width,m.height))  --crop IS BUGGY & WILL BUG OUT IF w OR h IS TOO LITTLE. IT WILL ALSO BUG OUT IF YOU ATTEMPT TO command IT, OR EVALUATE FRAME-BY-FRAME.
    mp.command(('%s vf pre @%s2:lavfi=[crop=%d:%d:0:0,setsar=1]'):format(o.command_prefix,label,m.width,m.height,m.width,m.height))  --crop IS BUGGY & WILL BUG OUT IF w OR h IS TOO LITTLE. IT WILL ALSO BUG OUT IF YOU ATTEMPT TO command IT, OR EVALUATE FRAME-BY-FRAME.
    mp.command(('%s vf pre @%s:lavfi=[%s,split,overlay,scale=%d:%d:eval=frame]'):format(o.command_prefix,label,o.detectors,m.width,m.height))    --DON'T WAIT FOR vf-command OR THERE'S A STARTING GLITCH.
    -- mp.command(('%s vf pre @%s:lavfi=[fps=25,%s,split,overlay,scale=%d:%d:eval=frame]'):format(o.command_prefix,label,o.detectors,m.width,m.height))    --DON'T WAIT FOR vf-command OR THERE'S A STARTING GLITCH.
    
    ----lavfi     =[graph]  [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. %%s SUBS OCCUR LATER. EACH .LUA MAY CONTROL A GRAPH (WHOSE string IS LIKE DNA).  THIS ONE ACHIEVES SMOOTH crop WITH A BUGGY crop FILTER. TO FURTHER IMPROVE SMOOTHNESS EITHER vf-command OR MAYBE BUFFERING COULD BE USED.
    ----scale     =width:height:eval  DEFAULT=iw:ih:once  n=0 @INSERTION. USING [vo] scale WOULD CAUSE SNAPPING ON vid CHANGE, SO I PREFER display, BUT THAT REDUCES QUALITY. ALL COORDS RELATIVE TO display.
    ----cropdetect=limit:round:reset:skip  [vo]→[vo]  DEFAULT=24/255:16:0  LINUX .AppImage FAILS IF skip IS NAMED (INCOMPATIBLE).  DEPENDS CRITICALLY ON format. alpha TRIGGERS VERY BAD PERFORMANCE. HOWEVER PRE-FORMATTING REDUCES PERFORMANCE.
    ----bbox      =min_val  DEFAULT=16. REQUIRED FOR JPEG & COVER ART (BETTER PERFORMANCE).
    ----split      CLONES video. THIS IS A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.  A MORE OPTIMAL ALTERNATIVE IS ACTUALLY zoompan, BUT IT REQUIRES A MUCH MORE COMPLICATED TECHNIQUE WHERE A CONSTANT CANVAS IS USED, MUCH LARGER THAN THE display (NOT WORTH THE EFFORT BECAUSE crop ITSELF IS THE PROBLEM).
    ----overlay   =x:y  DEFAULT=0:0  n=1 @INSERTION (OFF). THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4. REQUIRES TRIVIAL PRE-scale.
    ----crop      =out_w:out_h:x:y  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2  vf-command ONLY CHANGES 1 # AT A TIME (CHOPPY). WON'T CHANGE DIMENSIONS WITH t OR n (SMOOTHCROP BUG). 
    ----setsar    =sar  IS THE FINISH. MACOS BUGFIX REQUIRES sar (WINDOWS & LINUX DON'T). ALONG WITH scale, STOPS EMBEDDED MPV SNAPPING INTERNAL WINDOW. WHEN CHANGING vid (MP3TAG) IT SNAPS IF USING [vo] scale.
    
    
    if unpause then mp.command('no-osd set pause no') end 
    detect_crop()
end
-- mp.observe_property('seeking','bool',file_loaded)   --TRIGGERS INSTANTLY, @seek, @playback-restart & @CHANGE OF vid TRACK.
mp.register_event('file-loaded', file_loaded)    


function on_toggle(mute_observed)   
    if mute_observed and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,detecting,m.playtime_remaining,crop_playtime_remaining = not OFF,false,nil,nil
    -- if not OFF then file_loaded()   --TOGGLE ON.
    if not OFF then detect_crop()   --TOGGLE ON.
    else for _,timer in pairs(timers) do timer:kill() end    --TOGGLE OFF. 
        apply_crop({x=0, y=0, out_w=m.max_w, out_h=m.max_h}) end  --ANIMATE crop REMOVAL. split STILL PRESENT - REMOVAL JUST MEANS RETURNING ORIGINAL aspect.  INSTANT DOUBLE-TOGGLE WOULD REQUIRE ANOTHER LINE TO MEMORIZE THESE COORDS, SO THEY DON'T HAVE TO BE RE-DETECTED.
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
    if o.meta_osd then mp.osd_message(mp.get_property_osd('vf-metadata/'..label)) end   --DISPLAY COORDS FOR 1 SEC.
    local meta=mp.get_property_native('vf-metadata/'..label)
    
    if not meta then detecting=false    --Verify the existence of metadata. SOMETIMES IT'S AN EMPTY table, WHICH FAILS THE NEXT TEST.
        mp.msg.error("No crop metadata.")
        mp.msg.info("Was the cropdetect filter successfully inserted?\nDoes your version of ffmpeg/libav support AVFrame metadata?")
        return end 
    
    for key in ('w h x1 y1 x2 y2 x y'):gmatch('%g+') do local value=meta['lavfi.cropdetect.'..key] --gmatch IS GLOBAL MATCH ITERATOR. %g+ IS LONGEST STRING TO SPACEBAR.
        if not value then value=meta['lavfi.bbox.'..key] end
        meta[key]=tonumber(value) end   --tonumber(nil)=nil (BUT 0+nil FAILS).
    
    if not (meta.w and meta.h and meta.x1 and meta.y1 and meta.x2 and meta.y2) then detecting=false  --THIS CAN HAPPEN IF VID IS PAUSED.
         mp.msg.error("Got empty crop data.")    
         mp.msg.info("You might need to increase detect_seconds.")
         return end 
    
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
    if unpause then mp.command('no-osd set pause yes') end  --PAUSED FOR JPEG (NO complex) OR THERE CAN BE A GLITCH.
    r=('(t-%s)/(%s)'):format(mp.get_property_number('time-pos'),o.crop_time)
    mp.command(('vf-command autocrop x -max(0,1-%s)*(%s)-min(1,%s)*(%s)'):format(r,m.x,r,meta.x))
    mp.command(('vf-command autocrop y -max(0,1-%s)*(%s)-min(1,%s)*(%s)'):format(r,m.y,r,meta.y))
    mp.command(('vf-command autocrop width  iw/(max(0,1-%s)*(%s)+min(1,%s)*(%s))*%d'):format(r,m.out_w,r,meta.out_w,m.width ))
    mp.command(('vf-command autocrop height ih/(max(0,1-%s)*(%s)+min(1,%s)*(%s))*%d'):format(r,m.out_h,r,meta.out_h,m.height))
    
    -- mp.command(('vf-command autocrop width  iw/(max(0,1-%s-.04)*(%s)+min(1,%s+.04)*(%s))*%d'):format(r,m.out_w,r,meta.out_w,m.width ))
    -- mp.command(('vf-command autocrop height ih/(max(0,1-%s-.04)*(%s)+min(1,%s+.04)*(%s))*%d'):format(r,m.out_h,r,meta.out_h,m.height))
    
    
    -- mp.command(('vf-command autocrop x -max(0,1-%s)*(%s)-min(1,%s)*(%s)'):format(r,m.x,r,meta.x))
    -- mp.command(('vf-command autocrop y -max(0,1-%s)*(%s)-min(1,%s)*(%s)'):format(r,m.y,r,meta.y))
    
    
    
    
    if unpause then mp.command('no-osd set pause no') end
    m.x,m.y,m.out_w,m.out_h = meta.x,meta.y,meta.out_w,meta.out_h   --meta→m  MEMORY TRANSFER
    if mp.get_property_bool('current-tracks/video/image') then o.auto=false    --0% CPU USAGE OVERRIDE FOR JPEG. DISABLE FURTHER DETECTIONS.
        mp.unobserve_property(detect_crop) end
end

for keys,func in pairs({    --CREATE timers, FOLLOWING ALL FUNCTIONS. THEY CARRY OVER FROM video→video IN MPV PLAYLIST. 
        ['auto_delay      auto_delay']=detect_crop, --['label delay']=func,
        ['pause          time_needed']=detect_crop,
        ['detect_crop detect_seconds']=detect_end,
        ['mute toggle_on_double_mute']=function()end,
    })
do keys=keys:gmatch('%g+')
   local label=keys()
   timers[label]=mp.add_periodic_timer(o[keys()], func)
   timers[label]:kill()
   timers[label].oneshot=true end


----COMMENT SECTION.
----format    =pix_fmts yuv422p yuv440p yuv444p WORK IN MY JPEG TESTS. 422 HALVES COLOR-W, 440 HALVES COLOR-H. yuv420p rgb24 yuva420p rgb32 ALL FAIL.
--DOUBLE SQRT SCALE: NOT BETTER.    lavfi=('scale=%s:%s,%s,split,overlay=-(%%s)*max(0\\,1-n/%d)-(%%s)*min(1\\,n/%d):-(%%s)*max(0\\,1-n/%d)-(%%s)*min(1\\,n/%d),scale=iw*sqrt(iw/(max(0\\,1-(n+1)/%d)*(%%s)+min(1\\,(n+1)/%d)*(%%s))):ih^2*(max(0\\,1-(n+1)/%d)/(%%s)+min(1\\,(n+1)/%d)/(%%s)):eval=frame,crop=%d:%d:0:0,scale=iw*sqrt(iw/(max(0\\,1-(n+1)/%d)*(%%s)+min(1\\,(n+1)/%d)*(%%s))):ih^2*(max(0\\,1-(n+1)/%d)/(%%s)+min(1\\,(n+1)/%d)/(%%s)):eval=frame,crop=%d:%d:0:0,setsar=1'):format(  m.width,m.height,  o.detectors,  o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,  m.width,m.height,  o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,  m.width,m.height  )  
--ZOOMPAN FAIL: BOTH IN&ON.   lavfi=('scale=%s:%s,%s,zoompan=1:(%%s)*max(0\\,1-on/%d)+(%%s)*min(1\\,on/%d):(%%s)*max(0\\,1-on/%d)+(%%s)*min(1\\,on/%d):1:%dx%d,scale=iw^2/(max(0\\,1-(n+1)/%d)*(%%s)+min(1\\,(n+1)/%d)*(%%s)):ih^2*(max(0\\,1-(n+1)/%d)/(%%s)+min(1\\,(n+1)/%d)/(%%s)):eval=frame,crop=%d:%d:0:0,setsar=1'):format(  m.width,m.height,  o.detectors,  o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,m.width,m.height,o.crop_frames,o.crop_frames,o.crop_frames,o.crop_frames,  m.width,m.height  )  



