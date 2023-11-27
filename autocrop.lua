----SMOOTHLY AUTO-CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 (COVER ART), & MP4. .TIFF ONE-LAYER ONLY. CAN CHANGE vid TRACK & crop. 
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAINS CENTER IN HORIZONTAL/VERTICAL, WITH TOLERANCE VALUES. ALSO SUPPORTS MULTIPLE DETECTORS, & bbox. 
----THIS VERSION MAKES SMOOTH-CROPPING SMOOTHER USING A NEGATIVE overlay (crop BUG WORKAROUND). MAY LAG IF IT SCALES 4xDISPLAY, BEFORE CROPPING DOWN TO IT. BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua
local options = {
    auto            =true,--IF false, CROPS STILL OCCUR WHEN SEEKING & TOGGLE.
    auto_delay      = .5, --ORIGINAL DEFAULT=1.
    detect_limit    = 32, --ORIGINAL DEFAULT="24/255".  ONLY INTEGER COMPATIBLE WITH bbox (0→255). autocomplex OVERLAY MAY INTERFERE.
    detect_round    =  2, --ORIGINAL DEFAULT=2, cropdetect DEFAULT=16.
    detect_min_ratio=.25, --ORIGINAL DEFAULT=0.5.
    
    ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES (IT HAS SOME FINAL GPU OVERRIDE).
    crop_time     =.5,      --DEFAULT=.5 SECONDS. TIME PER CROP TO STRETCH OUT BLACK BARS USING VARYING ASPECT. TOO FAST & IT HAS TOO MUCH ENERGY.
    command_prefix='no-osd',--DEFAULT=''. CAN SUPPRESS osd.
    
    detect_limits ={        --NOT CASE SENSITIVE. detect_limit MAY VARY WITH media-title IF THE FOLLOWING SUBSTRINGS ARE FOUND.
                    ['We are army of people - Red Army Choir']= 64,
                    [                       'L.A.D.Y G.A.G.A']=100,
                   },
    
    MAINTAIN_CENTER_X=  0, --TOLERANCE, 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). 1 BLACK BAR ON 1 SIDE MAY BE OK.
    MAINTAIN_CENTER_Y=.25, --TOLERANCE. A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO AT MOST 1/3 TO BE SAVED.
    TOLERANCE        =.02, --DEFAULT=.01 (1%). WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME   = 10, --DEFAULT=60 SECONDS. IRRELEVANT IF TOLERANCE=0.
    
    USE_INNER_RECTANGLE=true,--BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE crop). COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW X2-X1. 
    -- USE_MIN_RATIO   =true,--CROP ALL THE WAY DOWN TO detect_min_ratio.
    time_needed        =2,   --DEFAULT=0 SECONDS. DO NOTHING IF THIS CLOSE TO VIDEO END (NECESSARY FOR RELIABILITY), OR FOLLOWING pause (OPTIONAL).
    
    -- scale    ={1680,1050},--STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE).     CHANGING vid (MP3 TAGS) CAUSES EMBEDDED MPV TO SNAP UNLESS AN ABSOLUTE scale IS USED (SO I DON'T USE [vo]). EMBEDDING MPV CAUSES ANOTHER LAYER OF BLACK BARS (WINDOW SNAP).   DEFAULT scale=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    -- meta_osd =true,       --DISPLAY ALL DETECTOR METADATA.
    -- detectors='bbox=%s',  --DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'. bbox IS AUTO-JPEG OVERRIDE. MULTIPLE detectors: 'cropdetect=%s:%s:1:0,cropdetect=%s:%s:1:0' FOR IMPROVED RELIABILITY.   %s=string SUBSTITUTION, FORMATTED @file-loaded. reset>0 FOR vf_command. skip=0 FOR JPEG. 
    
    key_bindings         ='C c J j',--DEFAULT='C'. CASE SENSITIVE. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). THESE DON'T WORK INSIDE SMPLAYER. 
    toggle_on_double_mute=.5,       --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute-TOGGLE. IN SMPLAYER (OR ON SMARTPHONE) TOGGLE CROPPING BY MUTING, INSTEAD OF KEYBOARD SHORTCUT. ONLY WORKS IF THERE'S AN aid TO mute (E.G. CAN'T TOGGLE ON RAW .JPG).
    
    io_write=' ',   --DEFAULT=''  io.write (INPUT OUTPUT) THIS @EVERY CHANGE IN vf (VIDEO FILTERS). STOPS EMBEDDED MPV FROM SNAPPING ON COVER ART. IT'S AN EMBEDDING ISSUE.
    config  ={
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

for key,val in pairs({command_prefix='',detect_limits={},TOLERANCE=.01,TOLERANCE_TIME=60,time_needed=0,crop_time=.5,scale={},detectors='cropdetect=limit=%s:round=%s:reset=1:0',key_bindings='C',toggle_on_double_mute=0,io_write='',config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command(o.command_prefix..' set '..option) end   --APPLY config BEFORE scripts.
if mp.get_property('vid')=='no' then exit() end    --OPTIONAL: NO VIDEO→EXIT.

local m={width=o.scale[1], height=o.scale[2]} --crop METADATA MEMORY.
function file_loaded(_,seeking) 
    if seeking or OFF or not mp.get_property_number('current-tracks/video/id') then return end    --DO NOTHING UNTIL DONE seeking, TOGGLED BACK ON, OR IF video/id=nil. ABSTRACT MP3 VISUALS MAY HAVE alpha & cropdetect MAY PERFORM BADLY.
    
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (m.width and m.height) then m.width,m.height = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).  current-tracks/video/demux-w IS RAW TRACK WIDTH.
    if not (m.width and m.height) then mp.add_timeout(.05,file_loaded)  --LINUX snap FALLBACK: RE-RUN & return IF [vo] ISN'T READY. 
        return end  
    m.width,m.height,detecting = math.ceil(m.width/4)*4,math.ceil(m.height/4)*4,false   --MULTIPLES OF 4 WORK BETTER WITH overlay (FURTHER GRAPHS LIKE automask). MPV MAY SNAP INSIDE SMPLAYER ON ODD NUMBERED SIZES. autocrop CAN BUG OUT IF THERE IS NO width,height (LINUX snap RAW MP3).
    
    l,r , MEDIA_TITLE  =  o.detect_limit,o.detect_round , mp.get_property('media-title'):upper() --current-tracks PROPERTIES AWAIT file-loaded. 
    for title,detect_limit in pairs(o.detect_limits) do if MEDIA_TITLE:find(title:upper(),1,true)   --1 IS STARTING INDEX. true DISABLES MAGIC SYMBOLS LIKE '%s'.
        then l=detect_limit  --CHANGE detect_limit FOR DIFFICULT FILES. 
            break end end
    
    if mp.get_property_bool('current-tracks/video/image') then o.detectors='bbox=%s'
        if o.io_write=='' then o.io_write=' ' end  --JPEG NEEDS io_write FIX.
        if mp.get_property('lavfi-complex')=='' then is_1_frame=true   --JPEG OVERRIDE. IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (SEE MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).
            mp.command('set pause yes') end end --JPEG FRAME NEEDS pause FOR DETECTOR INSERTION. pause DOESN'T TRIGGER osd.
    mp.observe_property('vf','native',function() io.write(o.io_write) end)
    o.detectors=o.detectors:format( l,r , l,r , l,r , l,r ) --CAN COMBINE A FEW DETECTORS, IN 1 GRAPH.
    
    mp.command(('%s vf pre @%s-crop:lavfi=[scale=max(%d\\,iw):max(%d\\,ih),crop=%d:%d:0:0:1:1,setsar=1]'):format(o.command_prefix,label,m.width,m.height,m.width,m.height))
    mp.command(('%s vf pre @%s:lavfi=[%s,split,overlay,scale=%d:%d:eval=frame]'):format(o.command_prefix,label,o.detectors,m.width,m.height))   --CENTRAL GRAPH. USES MOST CPU. BY TRIAL & ERROR NEEDS width & height INSTANTLY TO AVOID SOME GLITCH.
    mp.command(('%s vf pre @%s-scale:scale=width=ceil(iw/4)*4:height=ceil(ih/4)*4'):format(o.command_prefix,label)) --TRIVIAL PRE-scale. 
    
    ----lavfi     =[graph]  [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. %%s SUBS OCCUR LATER. THIS ONE ACHIEVES SMOOTH crop WITH A BUGGY crop FILTER. IT HAS 2 GRAPHS + TRIVIAL PRE-scale. crop NEEDS ITS OWN GRAPH TO STOP EMBEDDED MPV SNAPPING COVER ART WHEN CHANGING vid (MP3TAG). IT MIGHT BE POSSIBLE TO COMBINE 3 INTO 2 BY MAKING THEM ALL HARDER TO UNDERSTAND.
    ----cropdetect=limit:round:reset:skip             DEFAULT=24/255:16:0  LINUX .AppImage FAILS IF skip IS NAMED (INCOMPATIBLE).  DEPENDS CRITICALLY ON format. alpha TRIGGERS VERY BAD PERFORMANCE. HOWEVER PRE-FORMATTING REDUCES PERFORMANCE.
    ----bbox      =min_val  (BOUNDING BOX)            DEFAULT=16  REQUIRED FOR JPEG & COVER ART. EVEN IF cropdetect WORKS SOMETIMES, IT WON'T WORK AS OFTEN AS bbox.
    ----split      CLONES video. THIS IS A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.
    ----overlay   =x:y           n=1@INSERTION (OFF)  DEFAULT=0:0  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4, WHICH IS WHY THE TRIVIAL PRE-scale EXISTS. IN THEORY autocrop SHOULD ONLY EVER USE A SINGLE GRAPH.
    ----scale     =width:height:...:eval  n=0@INSERTION   DEFAULTS iw:ih:once  TRIVIAL PRE-scale REQUIRED. USING [vo] scale WOULD CAUSE SNAPPING ON vid CHANGE, SO I PREFER display.     AN ALTERNATIVE TECHNIQUE USES zoompan, WHICH IS MORE OPTIMAL, BUT ALSO MORE COMPLICATED.
    ----crop      =out_w:out_h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  IS THE FINISH, FOLLOWING GRAPH. vf-command CRASHES IT (UNRELIABLE, ESPECIALLY IN GRAPH). WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. A BUGGY FILTER CAN BE SEPARATE FROM GRAPH.
    ----setsar    =sar  IS THE FINISH. MACOS BUGFIX REQUIRES sar (WINDOWS & LINUX DON'T). ALONG WITH scale, STOPS EMBEDDED MPV SNAPPING INTERNAL WINDOW.
    
    
    if is_1_frame then mp.command('set pause no') end 
    detect_crop()
end
mp.register_event('file-loaded', file_loaded)    
mp.register_event('seek',function() m.x=nil end) --RE-INITIALIZE @seek BY DELETING MEMORY. seeking WITH vf-command CAN CAUSE CRASH IF REPEATED RAPIDLY (BRUTE FORCE).
mp.observe_property('current-tracks/video/id','number',function() if MEDIA_TITLE then file_loaded() end end)    --MEDIA_TITLE MEANS ALREADY INITIALIZED. THEN TREAT ALL CHANGES IN vid AS THOUGH IT'S A NEW FILE (BUT WITH SAME ABSOLUTE scale).

timers.mute=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --DOUBLE mute timer. IT CARRIES OVER TO NEXT file IN MPV PLAYLIST.
timers.mute.oneshot=true 
function on_toggle(mute)    --OVERLOADS FOR mute & key_binding.
    if mute=='mute' and not timers.mute:is_enabled() then timers.mute:resume() --START timer ON SINGLE mute.
        return end
    
    OFF,detecting,m.playtime_remaining,crop_playtime_remaining = not OFF,false,nil,nil
    if not OFF then detect_crop()   --TOGGLE ON.
    else for _,timer in pairs(timers) do timer:kill()  end --TOGGLE OFF. 
        apply_crop({ x=0,y=0, out_w=m.max_w,out_h=m.max_h }) end --ANIMATE NULL crop. NUMBERS SOMETIMES REQUIRED FOR max_w (NOT 'iw'), ETC. DON'T BOTHER CHANGING GRAPH (COULD CAUSE BUG).  INSTANT DOUBLE-TOGGLE WOULD REQUIRE ANOTHER LINE TO MEMORIZE THESE COORDS, SO THEY DON'T HAVE TO BE RE-DETECTED.
end
mp.observe_property('mute', 'bool', on_toggle)  --mute timer NEEDED, TO ACTIVATE.
for key in (o.key_bindings):gmatch('%g+') do mp.add_key_binding(key, 'toggle_crop_'..key, on_toggle) end

function detect_crop()
    if o.auto then timers.auto_delay:kill()     --RESET auto TIMER.
                   timers.auto_delay:resume() end    
    
    if detecting or mp.get_property_bool('seeking') then return end  --DO NOTHING IF ALREADY detecting OR seeking.
    detecting=true  --OPTIONAL SWITCH WHICH KEEPS TRACK OF WHETHER ALREADY detecting.
             
    local playtime_remaining=mp.get_property_number('playtime-remaining')   --JPEG=nil
    if OFF or playtime_remaining and (playtime_remaining==m.playtime_remaining or playtime_remaining<o.time_needed) then detecting=false    --TOGGLED OFF, ALREADY ANALYZED, NEAR video END.
        return end
    m.playtime_remaining=playtime_remaining   --REMEMBER THIS TIME IS ALREADY DONE.
    
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
    
    m.max_w,m.max_h = math.ceil(mp.get_property_number('video-params/w')/4)*4,math.ceil(mp.get_property_number('video-params/h')/4)*4   --ACCOUNT FOR TRIVIAL PRE-scale.
    if o.MAINTAIN_CENTER_X then local xNEW = math.min(meta.x, m.max_w-(meta.x+meta.w))  --KEEP HORIZONTAL CENTER, E.G. SO THAT BINOCULARS ARE CENTERED.    SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL.
        local wNEW = m.max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
        if wNEW-meta.w>wNEW*o.MAINTAIN_CENTER_X then meta.x,meta.w = xNEW,wNEW end end
    if o.MAINTAIN_CENTER_Y then local yNEW = math.min(meta.y, m.max_h-(meta.y+meta.h))     -- KEEP VERTICAL CENTERED, E.G. PORTRAITS WHERE FEET GET CROPPED OFF. 
        local hNEW = m.max_h-yNEW*2
        if hNEW-meta.h > hNEW*o.MAINTAIN_CENTER_Y then meta.y,meta.h = yNEW,hNEW end end     --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
   
    local min_w,min_h = m.max_w*o.detect_min_ratio,m.max_h*o.detect_min_ratio
    if meta.w<min_w then if not o.USE_MIN_RATIO then meta.w,meta.x = m.max_w ,0    --NULLIFY crop out_w.
        else meta.w,meta.x = min_w,math.max(0,math.min(m.max_w-min_w,meta.x-(min_w-meta.w)/2)) end end --MINIMIZE out_w.
    if meta.h<min_h then if not o.USE_MIN_RATIO then meta.h,meta.y = m.max_h,0    --NULLIFY crop out_h.
        else meta.h,meta.y = min_h,math.max(0,math.min(m.max_h-min_h,meta.y-(min_h-meta.h)/2)) end end --MINIMIZE out_h.

    if meta.w>m.max_w or meta.h>m.max_h or meta.w<=0 or meta.h<=0 or meta.x2<=meta.x1 or meta.y2<=meta.y1 then detecting=false  ----IF w<0 IT'S LIKE A JPEG ERROR.
        return end 
    
    if not m.x then m.x,m.y,m.out_w,m.out_h = 0,0,m.max_w,m.max_h end  --INITIALIZE 0TH crop AT BEGINNING.
    meta.out_w,meta.out_h = meta.w,meta.h   --w,h → out_w,out_h 
    
    -- Verify if it is necessary to crop.
    local is_effective=not crop_playtime_remaining  --PROCEED IF NO playtime_remaining AT LAST crop.
            or math.abs(m.playtime_remaining-crop_playtime_remaining)>o.TOLERANCE_TIME --PROCEED IF TIME CHANGES TOO MUCH,
                and (meta.out_w~=m.out_w or meta.out_h~=m.out_h or meta.x~=m.x or meta.y~=m.y)  --UNLESS ALL COORDS EXACTLY THE SAME.
            or math.abs(meta.out_w-m.out_w)>m.out_w*o.TOLERANCE or math.abs(meta.out_h-m.out_h)>m.out_h*o.TOLERANCE --CHECK meta IS EFFECTIVE AT CHANGING CURRENT GEOMETRY.
            or math.abs(meta.x-m.x)>m.out_w*o.TOLERANCE or math.abs(meta.y-m.y)>m.out_h*o.TOLERANCE
    
    if not is_effective then detecting=false
        mp.msg.info("No area detected for cropping.") 
        return end
    
    crop_playtime_remaining,detecting = m.playtime_remaining,false
    apply_crop(meta)
end
timers.auto_delay=mp.add_periodic_timer(o.auto_delay, detect_crop)
for _,timer in pairs(timers) do timer:kill() end    --BOTH timers CARRY OVER TO NEXT FILE IN PLAYLIST.

function apply_crop(meta) 
    if is_1_frame then timers.auto_delay:kill()
        mp.command(('%s vf pre @%s:lavfi=[%s,crop=%d:%d:%d:%d:1:1,scale=%d:%d,setsar=1]')   --is_1_frame GETS ITS OWN GRAPH! A REPLACEMENT. TOGGLE WITH "C" TO VERIFY IT WORKS WITHOUT ANY complex.
            :format(o.command_prefix,label,o.detectors,meta.out_w,meta.out_h,meta.x,meta.y,m.width,m.height))
         return end --is_1_frame ENDS HERE.
    
    local s=('min(1,(t-%s)/(%s))'):format(mp.get_property_number('time-pos'),o.crop_time)  --ABBREV. TIME AS s=string.  CAN'T SHIFT .04s WITHOUT TRIGGERING RARE BUGS.
    mp.command(('vf-command %s x        -((1-%s)*(%s)+%s*(%s))   '):format(label,s,m.x,    s,meta.x             )) 
    mp.command(('vf-command %s y        -((1-%s)*(%s)+%s*(%s))   '):format(label,s,m.y,    s,meta.y             ))
    mp.command(('vf-command %s width  iw/((1-%s)*(%s)+%s*(%s))*%d'):format(label,s,m.out_w,s,meta.out_w,m.width ))
    mp.command(('vf-command %s height ih/((1-%s)*(%s)+%s*(%s))*%d'):format(label,s,m.out_h,s,meta.out_h,m.height))
    m.x,m.y,m.out_w,m.out_h = meta.x,meta.y,meta.out_w,meta.out_h   --meta→m  MEMORY TRANSFER. is_1_frame DOESN'T NEED IT.
end


----COMMENT SECTION.
----format    =pix_fmts yuv422p yuv440p yuv444p WORK IN MY JPEG TESTS. 422 HALVES COLOR-W, 440 HALVES COLOR-H. yuv420p rgb24 yuva420p rgb32 ALL FAIL.

--APPLY FINAL SCALE IN ADVANCE? if m.width and m.height then mp.command(('%s vf pre @%s-crop:lavfi=[scale=%d:%d,setsar=1]'):format(o.command_prefix,label,m.width,m.height,m.width,m.height)) end



