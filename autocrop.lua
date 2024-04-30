----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROPS BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 TAGS, AVI, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop ON THE FLY. CROPS RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA PAIR OF BLACK BARS), SMOOTH-pad, BUT NOT SMOOTH-crop.  BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua  BUT WITHOUT video-crop BECAUSE THAT CROPS automask TOO.

options={
    auto                  =true,  --IF false, CROPS OCCUR ONLY on_toggle & @playback-restart. 
    auto_delay            = .5,   --ORIGINALLY 4 SECONDS.  
    detect_limit          = 30,   --ORIGINALLY "24/255".  lavfi-complex OVERLAY MAY INTERFERE ON SIDES (CAN INCREASE detect_limit).
    detect_round          =  1,   --ORIGINALLY 2.  cropdetect DEFAULT=16.
    detect_min_ratio      =.25,   --ORIGINALLY 0.5.
    suppress_osd          =true,  --ORIGINALLY false.
    -- ----ALL THE FOLLOWING ARE OPTIONAL & MAY BE REMOVED. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.    IN SMPLAYER AN ADVANCED PREFERENCE IS TO RUN action=aspect_none (SET KEYBOARD SHORTCUT=Tab) FOR ALL FILES. IT HAS SOME FINAL GPU OVERRIDE.
    key_bindings          ='C c J j', --DEFAULT='C'. CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. C→J IN DVORAK, BUT J IS ALSO next_subtitle (& IN VLC IS dec_audio_delay). m IS mute (IN DVORAK TOO) SO CAN DOUBLE-PRESS m. m&m DOUBLE-TAP MAYBE OUGHT TO BE automask, BUT autocrop IS MORE FUNDAMENTAL. TOGGLE DISABLES FINAL SUBTRACTION, TOO!
    toggle_on_double_mute = .5,   --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. TRIPLE mute DOUBLES BACK.  DOESN'T WORK IN SMPLAYER ON JPEG (NO AUDIO TO MUTE).
    toggle_duration       = .5,   --DEFAULT=.5 SECONDS.  TIME TO STRETCH OUT EXTRA PAIR OF BLACK BARS, IF PLAYING.  SMOOTH-PADDING IS EASY, BUT NOT SMOOTH-CROPPING.
    unpause_on_toggle     =.11,   --DEFAULT=.1 SECONDS.  SOME FRAMES ARE ALREADY DRAWN IN ADVANCE. DOESN'T APPLY TO albumart. 
    detect_limit_image    = 32,   --INTEGER 0→255, FOR JPEG & albumart.  ONLY INTEGERS FOR bbox. 
    detect_min_ratio_image=  0,   --OVERRIDE FOR image.
    TOLERANCE             =.05,   --DEFAULT=0. INSTANTANEOUS TOLERANCE. WHAT PERCENTAGE BLACK BARS ARE TOLERATED FOR UP TO 10 SECONDS? A BIG crop IS INSTANT, BUT NOT LITTLE CROPS, OTHERWISE AN IMAGE MAY KEEP FIDGETING BY A PIXEL OR TWO.
    TOLERANCE_TIME        = 10,   --DEFAULT=10 SECONDS. IRRELEVANT IF TOLERANCE=0.
    MAINTAIN_CENTER       ={0,0}, --{TOLERANCE_X,TOLERANCE_Y}. APPLIES TO video (NOT image). 0 MEANS NEVER MOVE THE CENTER (LIKE CROSSHAIRS). A SINGLE BLACK BAR ON 1 SIDE MAYBE OK (UNLESS is1frame). A TRIBAR FLAG WITH BLACK ON TOP OR BOTTOM NEEDS RATIO<1/3. MOVEMENTS IN CENTER TEND TO BE SPURIOUS (LIKE A DARK FLOOR).
    USE_INNER_RECTANGLE   =true,  --BOTH cropdetect & bbox GENERATE UNNECESSARY x1 x2 y1 y2 NUMBERS, WHICH ENABLE THE INNER RECTANGLE (MORE AGGRESSIVE) crop. MAYBE FOR STATISTICAL REASONS. COMPUTE x1,x2 = max(x1,x2-w,x),min(x2,x1+w,x+w) ETC BY SYMMETRY, THEN SHRINK w TO THE NEW x2-x1. 
    pad_color             ='BLACK',  --DEFAULT='BLACK'
    detector              ='cropdetect=limit=%s:round=%s:reset=1:skip=0',--DEFAULT='cropdetect=limit=%s:round=%s:reset=1:0'  %s=string SUBSTITUTIONS. reset>0.
    detector_image        ='bbox=min_val=%s',  --DEFAULT='bbox=min_val=%s'  ALSO detector_alpha (FOR TRANSPARENT VIDEO).  %s=detect_limit_image OR OVERRIDE.  alpha CAUSES A cropdetect BUG.  
    -- meta_osd           =  1,   --SECONDS. UNCOMMENT TO DISPLAY ALL detector METADATA.
    -- USE_MIN_RATIO      =true,  --UNCOMMENT TO CROP ALL THE WAY DOWN TO detect_min_ratio. CAN BE SPURIOUS. DEFAULT CANCELS EXCESSIVE crop.
    -- msg_log            =true,  --UNCOMMENT TO MESSAGE MPV LOG. FILLS THE LOG.
    -- crop_no_vid        =true,  --SPATIALLY crop ABSTRACT VISUALS TOO. BY DEFAULT NO CROPPING PURE lavfi-complex, EXCEPT FOR TIME limits.
    -- scale              ={w=1680,h=1050}, --DEFAULT=display OR VIDEO. TRUE ASPECT TOGGLE ONLY WORKS @FULLSCREEN.  MACOS SMPLAYER (& .flatpak LINUX) REQUIRE THIS OPTION BECAUSE EMBEDDED MPV CAN'T DEDUCE FULLSCREEN DIMENSIONS @file-loaded.
    options               =' '  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.  main.lua HAS MORE options.
        ..'  osd-font-size=16 geometry=50% image-display-duration=inf'  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  duration=inf FOR IMAGES.
    ,
    limits={  --NOT CASE SENSITIVE. DON'T FORGET COMMAS!  CAN ALSO USE END OF YOUTUBE URL.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIP EXTRACTS. STARTING & ENDING CREDITS ARE EASIER TO CROP THAN INTERMISSION (INTERMEDIATE AUTO-seek). 
    ----["path-substring"]={time_pos,time_remaining,detect_limit}={SECONDS,SECONDS,number} (OR nil).  TIMES ARE BOTH LOWER BOUNDS IN SECONDS. detect_limit IS FINAL OVERRIDE.  
        ["We are army of people - Red Army Choir"]={detect_limit=64},
        [  "День Победы"]={4,13},                          --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7}, --ABČDEFGHIĴKLMNOP RSTUV  YZЕYoYYuYaTsŠŠčʹʺ
        ["Megadeth Sweating Bullets Official Music Video"]={0,5},
        ["Мы - армия народа ⧸ We are the army of the people (23 февраля 1919 - 2019)"]={13},
        ["＂Soldiers walked＂ - The Alexandrov Red Army Choir (1975)"]={0,27},
        ["＂Song of the Volga Boatmen＂ HQ - Leonid Kharitonov & The Red Army Choir (1965)"]={13},
        ["Red army choir - Echelon's song (Song for Voroshilov)"]={7,3},
        ["Red army choir - Echelon's song (original)"]={6},
        ["＂My Armiya Naroda, Sluzhit' Rossii＂ - Ensemble of the Russian West Military District"]   ={5,14},
        ["Варшавянка ⧸ Warszawianka ⧸ Varshavianka (1905 - 1917)"]={0,6},
        ["Russian Patriotic Song： Farewell of Slavianka"]={12},
        ["И вновь продолжается бой.Legendary Soviet Song.Z."]={0,6},
        ["＂Polyushko Polye＂ - Soviet Patriotic Song"]={8,12},
        ["опурри на темы армейских песен Soviet Armed Forces Medley"]={17},
        ["Tri Tankista - Three Tank Crews - With Lyrics"]={10},
        ["Три Танкиста ｜ Tri Tankista (The Three Tankists)"]={0,17},
        ["Три танкиста."]={0,15},
        ["Katyusha."]={4,4},
        ["Песня Будённовской конной кавалерии РККА"]={11},
        ["Военные парады 1938 - 1940г. Москва. Красная площадь."]={6,5},
        ["＂Если завтра война, если завтра в поход＂ - Кинохроника"]={5},
        ["Sacred War ⧸⧸ Священная Война [Vinyl]"]={10,6},
        ["Экипаж Одна семья"]={0,8}, 
        ["＂Конармейский марш. По военной дороге шёл в борьбе и тревоге＂ - Кинохроника"]={5},
        ["Москва Майская"]={27,15},
    },
}
o=options  --ABBREV.
require 'mp.options'.read_options(o)  --OPTIONAL?

for opt,val in pairs( {key_bindings='C',toggle_on_double_mute=0,toggle_duration=.5,unpause_on_toggle=.1,detect_limit_image=o.detect_limit,MAINTAIN_CENTER={},TOLERANCE=0,TOLERANCE_TIME=10,pad_color='BLACK',detector='cropdetect=limit=%s:round=%s:reset=1:skip=0',detector_image='bbox=min_val=%s',scale={},options='',limits={},} )
do o[opt] = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true  
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM. 
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not (opt and val) then break end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER
command_prefix = o.suppress_osd and 'no-osd' or ''
m,label        = {},mp.get_script_name()  --m=METADATA MEMORY.  label=autocrop 
ffmpeg_v,mpv_v,platform = mp.get_property('ffmpeg-version'):sub(0,2),mp.get_property('mpv-version'):gsub('mpv 0.',''):sub(0,3),mp.get_property('platform')  --FFMPEG  "4."  OR  "5."  OR  "6."  OR OTHER.  "mpv 36."  "mpv 37."  "mpv 38."  ETC.  OLD VERSIONS REQUIRE FORCING vf-COMMANDS, WHICH SLOWS DOWN THE ENGINE. 
o.detector     =    ffmpeg_v=='4.' and o.detector:gsub(':skip=%d+','') or o.detector  --v4 INCOMPATIBLE WITH skip.
repeat_pad     =    ffmpeg_v== '4.'     or ffmpeg_v== '5.'                    --OLD FFMPEG REQUIRES REPEATING apply_pad COMMANDS. BUT THAT CAUSES LAG.
                 or    mpv_v=='35.'     or platform=='linux' and mpv_v=='36.' --OLD MPV TOO, IN .flatpak.
                 or platform=='android' or platform=='freebsd'                --OTHER PLATFORMS HAVE A BETTER CHANCE WITH repeat_pad.

function start_file()  --ESTABLISH limits.
    limits,path = {},        mp.get_property('path'):lower()  --NOT CASE SENSITIVE.
    for key,val in pairs(o.limits) do   key   =(key):lower()
        if (path):find(key,1,true) then limits={
                time_pos      =val.time_pos       or val[1],  -- 1,true = STARTING_INDEX,EXACT_MATCH  val ASSUMED TO BE table. 
                time_remaining=val.time_remaining or val[2],
                detect_limit  =val.detect_limit   or val[3],  --FINAL OVERRIDE.
            } end end  
end
mp.register_event('start-file',start_file)

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function file_loaded() --ALSO @alpha & @vid.  THAT IS TRANSPARENCY & TRACK-ID.  alpha=nil ASSUMED @file-loaded.  MPV-v0.36 REQUIRES EXTRA .1s TO DETECT ALL video-params. 
    v       =mp.get_property_native('current-tracks/video') or {}
    v_params=mp.get_property_native('video-params')         or {}
    aspect  =v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect  --RAW STREAM aspect. DEFAULT GRAPH STATE IS OFF (PADDED).
    
    timers.auto_delay:resume()  --is1frame REQUIRES SMALL DELAY FOR INITIAL DETECTION (RELIABILITY ISSUE).
    if not OFF and limits.time_pos and mp.get_property_number('time-pos')<limits.time_pos+0   --+0 CONVERTS→number & IS EASIER TO READ THAN RE-ARRANGING INEQUALITIES.  JPEG>=0.
    then mp.command(('%s seek %s absolute exact'):format(command_prefix,limits.time_pos)) end --ONLY seek FORWARDS. MAYBE MORE RIGOROUS THAN SETTING time-pos DIRECTLY.  seeking IS MORE ELEGANT THAN TRIMMING TIMESTAMPS. 
    if not aspect or not (v.id or o.crop_no_vid) then return end  --RAW AUDIO ENDS HERE (~aspect).  lavfi-complex MAY NOT NEED CROPPING.  
    
    W                = o.scale.w or o.scale[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display) OR (VIDEO)  DIMENSIONS. 
    H                = o.scale.h or o.scale[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h']
    W,H              = round(W,2),round(H,2)  --MPV v0.37.0+ HAS ODD BUG.
    m,pad_iw,pad_ih  = {vid=v.id},round(math.min(W,H*aspect)),round(math.min(H,W/aspect))  --MEMORY FOR vid SWITCH, & pad GRAPH INSERTS (pad INPUT_WIDTH,INPUT_HEIGHT).
    detect_min_ratio = v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    is1frame         = v.image      and not mp.get_opt('lavfi-complex')  --REQUIRE GRAPH REPLACEMENT IF image & ~complex. 
    MAINTAIN_CENTER  = is1frame     and {} or o.MAINTAIN_CENTER  --RAW JPEG CAN MOVE CENTER. GIF IS ~image. 
    auto             = not is1frame and o.auto   --NO auto FOR is1frame.
    detect_limit     = limits.detect_limit or v.image and o.detect_limit_image or o.detect_limit
    detector         = ((v.image or v_params.alpha)   and o.detector_image or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USES bbox.
    insta_pause      = v.image and not pause  --HELPS WITH GRAPH INSERTION FOR IMAGES.  THERE CAN BE INTERFERENCE FROM OTHER SCRIPT/S.
    if insta_pause then mp.set_property_bool('pause',true) end
    
    
    mp.command(('%s vf pre @%s-pad:lavfi=[scale=%d:%d:eval=frame,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s:frame,setsar=1]'):format(command_prefix,label,pad_iw,pad_ih,W,H,o.pad_color))  --PADS AN EXTRA PAIR OF BLACK BARS.
    mp.command(('%s vf pre @%s-scale:scale=w=%d:h=%d'):format(command_prefix,label,W,H))  --INTERMEDIATE FILTER NEEDED TO PREVENT TOGGLE-ON GLITCH (SMOOTH-PADDING ISSUE). THE pad GRAPH HAS SAME SIZE INPUT & OUTPUT. OLD MPV THROWS ERRORS DUE TO AMBIGUOUS w & h COMMANDS IF crop & scale ARE COMBINED.
    mp.command(('%s vf pre @%s:lavfi=[%s,crop=iw:ih:0:0:1:1]'):format(command_prefix,label,detector))  --MAIN GRAPH.
    
    ----lavfi     =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPHS.  %d,%s = DECIMAL_INTEGER,string.  2 GRAPHS + FILTER FOR BACKWARDS COMPATIBILITY, PLACED IN REVERSE ORDER.
    ----cropdetect=limit:round:reset:skip  DEFAULT=24/255:16:0  round MEASURED IN IN PIXELS, reset & skip BOTH IN FRAMES. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION. skip INCOMPATIBLE WITH FFMPEG-v4. alpha TRIGGERS BAD PERFORMANCE BUG.
    ----bbox      =min_val  DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR image & alpha.  CAN ALSO COMBINE MULTIPLE DETECTORS IN 1 GRAPH, BUT THAT COMBINES DEFICITS.
    ----crop      =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING.
    ----scale     =w:h      DEFAULT=iw:ih  USING [vo] scale WOULD CAUSE EMBEDDED MPV TO SNAP @vid, SO USE display INSTEAD. EITHER WINDOW SNAPS IN, OR ELSE video SNAPS OUT.
    ----pad       =w:h:x:y:color:eval  DEFAULT=0:0:0:0:BLACK:init  0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar    =sar      DEFAULT=0  IS THE FINISH.  SAMPLE ASPECT RATIO. PREVENTS EMBEDDED MPV FROM SNAPPING ON albumart. MACOS REQUIRES sar (SEE ERRORS IN LOG). SHOULD BE 1 FOR OUTPUT I THINK.


    if insta_pause then mp.set_property_bool('pause',false) end 
end
mp.register_event('file-loaded',file_loaded)
mp.observe_property('vid','number',function(_,vid) if vid and m.vid and m.vid~=vid then file_loaded() end end)  --RELOAD IF vid CHANGES. vid=nil IF LOCKED BY lavfi-complex.  UNFORTUNATELY EMBEDDED MPV SNAP EVERY TIME.  AN MP3 OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED CROPPING (& HAVE RUNNING audio). 
mp.observe_property('pause','bool',function(_,paused) pause=paused end)  --MORE EFFICIENT TO observe.

function playback_restart() --vf-command RESET, UNLESS is1frame (GEOMETRY PERMANENT). 
    if not is1frame then m.w,m.h,m.x,m.y,m.aspect,m.time_pos = nil,nil,nil,nil,nil,nil  --FORCE ALL vf-commands, EVEN IF ~auto. 
        detect_crop() end  --IN CASE ~auto.
end 
mp.register_event('playback-restart',playback_restart)

function on_v_params(_,video_params)  --MORE EFFICIENT TO observe.
    v_params    = video_params or {}  --MAYBE nil@lavfi-complex.
    max_w,max_h = v_params.w,v_params.h
    if v_params.alpha then file_loaded() end  --RELOAD @alpha.
end 
mp.observe_property('video-params','native',on_v_params)  

function on_toggle(mute)  --PADS BLACK BARS WITHOUT CHANGING [vo] scale. VALID @FULLSCREEN.  A DIFFERENT VERSION COULD USE osd-dimensions (WINDOW SIZE).
    if not timers.mute then return  --STILL LOADING.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE TOGGLE.  
    else OFF,insta_unpause  = not OFF,pause  --OFF SWITCH. insta_unpause FOR o.unpause_on_toggle.
        m.time_pos,time_pos = nil,round(mp.get_property_number('time-pos'),.001)  --~m.time_pos FORCES is_effective.  time_pos FOR TOGGLE OFF clip.
        if aspect and OFF then apply_crop({ x=0,y=0, w=max_w,h=max_h }) end --NULL crop, IF VIDEO.
        detect_crop() end  --IN CASE ~auto.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function detect_crop()  --FOR RAW AUDIO TOO.  USUALLY LOOPS EVERY HALF A SECOND.
    if OFF or not auto and m.time_pos then return  --~auto ONLY CROPS ONCE & @on_toggle & @playback-restart.
    elseif limits.time_remaining and (mp.get_property_number('time-remaining') or 0)<limits.time_remaining+0 
    then mp.command(command_prefix..' playlist-next force')   --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST.  THIS IS A TIME-CROP (LIKE apply_crop). SAFER THAN RE-APPENDING trim & atrim FILTERS USING main.lua.
         return 
    elseif not max_w then return end  
    
    meta,time_pos = mp.get_property_native('vf-metadata/'..label),round(mp.get_property_number('time-pos'),.001)  --Get the metadata.  NEAREST MILLISECOND.  
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
        or math.abs(time_pos-m.time_pos)>o.TOLERANCE_TIME+0                             --PROCEED IF TIME CHANGES TOO MUCH.
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

function apply_crop(meta) 
    aspect  =OFF    and (v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect) or W/H  --OFF&(~image OR image) OR ON(FULL-SCREEN).
    m.aspect=m.aspect or v['demux-w'] and v['demux-w']/v['demux-h'] or v_params.aspect  --ASSUME OFF IF nil.  GRAPH RESETS AFTER playback-restart.
    m.pad_iw,pad_iw,m.pad_ih,pad_ih = round(math.min(W,H*m.aspect)),round(math.min(W,H*aspect)),round(math.min(W/m.aspect,H)),round(math.min(W/aspect,H))  --pad GRAPH WIDTHS & HEIGHTS: PRIOR→TARGETS.
    
    if is1frame then insta_pause=not pause  --GRAPH REPLACEMENTS. insta_pause DUE TO INTERFERENCE FROM OTHER SCRIPT/S.
        if insta_pause then mp.set_property_bool('pause',true ) end
        mp.command(('%s vf pre @%s-pad:lavfi=[scale=%d:%d:eval=frame,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:%s:frame,setsar=1]'):format(command_prefix,label,pad_iw,pad_ih,W,H,o.pad_color))
        mp.command(('%s vf pre @%s:lavfi=[%s,crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1]'):format(command_prefix,label,detector,meta.w,meta.h,meta.x,meta.y))  --detector NEEDED FOR TOGGLE. min NEEDED FOR RARE BUG, DUE TO INTERFERENCE FROM OTHER SCRIPT/S (iw<meta.w AT SOME POINT IN TIME).
        if insta_pause then mp.set_property_bool('pause',false) end       
    else if not target
        then _,error_string = mp.command(('%s vf-command %s x 0 crop'):format(command_prefix,label))  --NULL-OP TO ESTABLISH TARGETS.
             target         = error_string and '' or 'crop'      --OLD MPV OR NEW. MPV v0.37.0+ SUPPORTS TARGETED COMMANDS.
             target_scale   = error_string and '' or 'scale' end --FOR pad GRAPH.
        clip                = ('(1-cos(PI*clip((t-%s)/(%s),0,1)))/2'):format(time_pos,insta_unpause and 0 or o.toggle_duration)  --[0,1] DOMAIN & RANGE FOR (1-cos(PI*...))/2.  TIME EXPRESSION FOR SMOOTH-PADDING.  0=INITIAL, 1=FINAL.  A SINE WAVE PROGRESSION.  duration=0 ALSO VALID (insta_unpause).  A FUTURE VERSION COULD ALSO SUPPORT A BOUNCING OPTION (BOUNCING BLACK BARS).
        
        for whxy in ('w h x y'):gmatch('[^ ]') do if m[whxy]~=meta[whxy]  --EXCESSIVE vf-command CAUSES LAG.  
            then mp.command(('%s vf-command %s %s %d %s'):format(command_prefix,label,whxy,meta[whxy],target)) end end  --.flatpak & .snap CAN'T HANDLE alpha TRANSPARENCY FROM lavfi-complex (BAD BINARY GLITCHES).
        apply_pad()
        if repeat_pad then for N=1,8 do mp.add_timeout(2^N/100,apply_pad) end end  --vf-command ON EXPONENTIAL TIMEOUTS (.02 .04 .08 .16 .32 .64 1.28 2.56)s, LIKE A SERIES OF DOUBLE-TAPS.  OLD FFMPEG/MPV BUGFIX FOR LAGGY MACOS-VIRTUALBOX.
        
        if insta_unpause then mp.set_property_bool('pause',false)  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF insta_unpause NEAR end-file (NOT ENOUGH TIME). 
            timers.pause:resume() end end
    m.w,m.h,m.x,m.y                   = meta.w,meta.h,meta.x,meta.y   --meta→m  MEMORY TRANSFER. 
    m.time_pos,m.aspect,insta_unpause = time_pos,aspect,nil  --insta_unpause ONLY EVER ACTIVATED BY TOGGLE.
end

function apply_pad()  --TARGETED scale COMMANDS.  
    if m.pad_iw~=pad_iw then mp.command(('%s vf-command %s-pad width  %d+%d*%s %s'):format(command_prefix,label,m.pad_iw,pad_iw-m.pad_iw,clip,target_scale)) end  --PADS EITHER HORIZONTALLY OR VERTICALLY.  CLIPS BTWN PRIOR pad_iw & NEXT pad_iw.
    if m.pad_ih~=pad_ih then mp.command(('%s vf-command %s-pad height %d+%d*%s %s'):format(command_prefix,label,m.pad_ih,pad_ih-m.pad_ih,clip,target_scale)) end
end 


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0(.7z .exe v3) v0.37.0(.app) v0.36.0(.exe .app .flatpak .snap v3) v0.35.1(.AppImage)  ALL TESTED.
----FFMPEG v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS OFTEN BUILT WITH FFMPEG v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----A FUTURE VERSION MIGHT CROP WITHOUT CHANGING ASPECT (EQUIVALENT TO AUTO-zoom). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT.
----SMPLAYER v23.12 TRIGGERS GRAPH RESET ON PAUSE. THAT'S ACTUALLY AN ADDED FEATURE WHICH RESETS THE CROP WHEN USER HITS SPACEBAR. v23.6 (JUNE RELEASE) & MPV ALONE DON'T RESET crop ON pause. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms.
----ALTERNATIVE FILTERS:
----loop   =loop:size  (LOOPS>=-1:MAX_SIZE>0)  UNNECESSARY.  INFINITE loop SWITCH FOR image (1fps). ALTERNATIVE TO GRAPH REPLACEMENT. COULD INCREASE TO 2fps. MORE RELIABLE WHEN USED WITH FURTHER GRAPHS, LIKE automask.
----format =pix_fmts          POSSIBLE BUGFIX FOR alpha CAUSING BAD cropdetect PERFORMANCE.
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.



