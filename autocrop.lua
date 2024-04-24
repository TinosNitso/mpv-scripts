----FOR MPV & SMPLAYER. CROPS IN BOTH SPACE & TIME (SUB-CLIPS). CROP BLACKBARS OFF JPEG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, WEBM, MP4 & YOUTUBE. CAN CHANGE vid TRACK (MP3TAG) & crop. CAN CROP RAW AUDIO TO START & END limits. .TIFF 1-LAYER ONLY, NO WEBP OR PDF.
----USE DOUBLE-mute TO TOGGLE. CAN MAINTAIN CENTER IN HORIZONTAL/VERTICAL, WITH INSTANTANEOUS TOLERANCE VALUES. SUPPORTS BOTH cropdetect & bbox FFMPEG-FILTERS. 
----THIS VERSION HAS PROPER aspect TOGGLE (EXTRA DOUBLE BLACK BARS TO MATCH STREAM), BUT NO SMOOTH-crop. BASED ON https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua

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
    -- no_vid             =true,  --crop ABSTRACT VISUALS TOO. BY DEFAULT NO CROPPING PURE lavfi-complex, EXCEPT FOR TIME limits.  COULD BE RENAMED "crop_no_vid".
    -- scale              ={w=1680,h=1052}, --DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX). OVERRIDE FOR EXACT MULTIPLES OF 4. ABSOLUTE scale SIMPLIFIES TRUE aspect TOGGLE. THIS VERSION ONLY WORKS @scale.
    io_write              =' ', --DEFAULT=''  (INPUT/OUTPUT)  io.write THIS @vf, @vid & @file-loaded.  DISABLED FOR MACOS.  PREVENTS EMBEDDED MPV FROM SNAPPING INSIDE SMPLAYER (OR FIREFOX?) BY COMMUNICATING WITH ITS PARENT APP. NEEDED FOR IMAGES.  DEPRACATED FORMATS LIKE yuvj422p STILL SNAP (A format OVERRIDE OPTION WOULD FIX IT).
    options               =' '  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.  main.lua HAS io_write (NECESSARY) & MORE options.
        ..'  osd-font-size=16 geometry=50% image-display-duration=inf'  --DEFAULT size 55p MAY NOT FIT GRAPHS ON osd. geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW. inf FOR IMAGES.
    ,
    limits={  --["media-title"]={time_pos,time_remaining,detect_limit,find}={SECONDS,SECONDS,number,boolean}(OR nil),  SUBSTRING SEARCH NOT CASE SENSITIVE (＂：｜⧸⧹＂=":|/\").  TIMES ARE BOTH LOWER BOUNDS IN SECONDS. detect_limit IS FINAL OVERRIDE.  SPACETIME CROPPING IS AN ALTERNATIVE TO SUB-CLIPS. IT MEANS MP4 SUB-CLIP EXTRACTS CAN BE DELETED. EXCEPT DUAL SUB-CLIPS WOULD BE ANOTHER LEVEL OF AUTO-seek. STARTING & ENDING CREDITS ARE EASIER TO CROP THAN INTERMISSION.
        -- ["ECHELON"]={10,60},

        ["Katyusha"]={4,4,find=false},  --find MEANS SUBSTRING SEARCH.  find ASSUMED true UNLESS false. (nil MEANING true.)  AN EXTRA exact FLAG COULD BE CONFUSING BECAUSE ＂＂="" ETC. 
        ["Megadeth Sweating Bullets Official Music Video"]={0,5},
        ["We are army of people - Red Army Choir"]={detect_limit=64},
        ["Мы - армия народа ⧸ We are the army of the people (23 февраля 1919 - 2019)"]={13},
        ["＂Soldiers walked＂ - The Alexandrov Red Army Choir (1975)"]={0,27},
        ["＂Song of the Volga Boatmen＂ HQ - Leonid Kharitonov & The Red Army Choir (1965)"]={13},
        ["Red army choir - Echelon's song (Song for Voroshilov)"]={7,3},
        ["Red army choir - Echelon's song (original)"]={6},
        ["＂My Armiya Naroda, Sluzhit' Rossii＂ - Ensemble of the Russian West Military District"]   ={5,14},
        ["Warszawianka - 1970's Polish People's Army"]={0,2},
        ["Варшавянка ⧸ Warszawianka ⧸ Varshavianka (1905 - 1917)"]={0,6},
        ["Russian Patriotic Song： Farewell of Slavianka"]={12},
        ["День Победы"]={4,13},  --АБЧДЭФГХИЖКЛМНОП РСТУВ  ЙЗЕЁ ЫЮ Я Ц ШЩ ЬЪ
        ["＂Den' Pobedy!＂ - Soviet Victory Day Song"]={7},
        ["И вновь продолжается бой.Legendary Soviet Song.Z."]={0,6},
        ["＂If You'll be Lucky＂ - Soviet Naval Song - А Если Повезет (English Subtitles)"]={0,3},
        ["＂Polyushko Polye＂ - Soviet Patriotic Song"]={8,12},
        ["опурри на темы армейских песен Soviet Armed Forces Medley"]={17},
        ["[Eng CC] Soviet Armed Forces Medley Попурри на темы армейских песен [USSR Military Song]"]={0,2},
        ["Tri Tankista - Three Tank Crews - With Lyrics"]={10},
        ["Три Танкиста ｜ Tri Tankista (The Three Tankists)"]={0,17},
        ["Три танкиста"]={0,15,find=false},
        ["Песня Будённовской конной кавалерии РККА"]={11},
        ["Военные парады 1938 - 1940г. Москва. Красная площадь."]={6,5},
        ["＂Если завтра война, если завтра в поход＂ - Кинохроника"]={5},
        ["Sacred War ⧸⧸ Священная Война [Vinyl]"]={10,6},
        ["Экипаж  Одна семья"]={0,8},
        ["＂Конармейский марш. По военной дороге шёл в борьбе и тревоге＂ -  Кинохроника"]={5},
        ["Москва Майская"]={27,15},
    },
}
require 'mp.options'.read_options(options)  --OPTIONAL?
o         =options  --ABBREV.
o.io_write=mp.get_property('platform')~='darwin' and o.io_write  --BUGS OUT ON MACOS-11 SMPLAYER (SHARED MEMORY VIDEO OUTPUT, vo shm). 
for opt,val in pairs({key_bindings='C',toggle_on_double_mute=0,unpause_on_toggle=.1,detect_limit_image=o.detect_limit,detector='cropdetect=limit=%s:round=%s:reset=1:skip=0',detector_image='bbox=min_val=%s',MAINTAIN_CENTER={},TOLERANCE=0,TOLERANCE_TIME=10,scale={},io_write='',options='',limits={},})
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
o.detector     = mp.get_property('ffmpeg-version'):sub(0,2)=='4.' and o.detector:gsub(':skip=%d','') or o.detector  --FFmpeg-v4 INCOMPATIBLE WITH skip.
m,label        = {},mp.get_script_name()  --m=METADATA MEMORY.  label=autocrop 

function file_loaded(event) --ALSO @alpha, @par & @vid.  THAT IS TRANSPARENCY, PIXEL ASPECT RATIO & TRACK-ID.  GUESS & CHECK ARE USED ON alpha & par BECAUSE file-loaded IS A SUPERIOR TRIGGER. alpha=nil ASSUMED. MPV REQUIRES .1s TO DETECT ALL video-params. ALWAYS WAITING MAY CAUSE ANNOYING GLITCH.
    io.write(o.io_write)    --@TRIGGER & @vf. PREVENTS EMBEDDED MPV FROM SNAPPING ON TRACK CHANGES.
    if event then par,limits,media_title = nil,{},mp.get_property('media-title'):lower()  --par & limits TO BE DETERMINED. par MEANS NOT PURE AUDIO (no-vid).
        for title,params in pairs(o.limits) do title=(title):lower():gsub('＂','"'):gsub('：',':'):gsub('｜','|'):gsub('⧸','/'):gsub('⧹','\\')  --＂：｜⧸⧹＂=":|/\"  SOLVES THE CAPITAL COLON PROBLEM.
            if media_title==title or params.find~=false and (media_title):find(title,0,true)  -- 0,true = STARTING_INDEX,EXACT_MATCH  params ASSUMED TO BE table.  path/URL COULD ALSO BE SEARCHED.
            then limits={time_pos      =params.time_pos       or params[1],  
                         time_remaining=params.time_remaining or params[2],
                         detect_limit  =params.detect_limit   or params[3],  --FINAL OVERRIDE.
                } end end end 
    if not OFF and limits.time_pos and mp.get_property_number('time-pos')<limits.time_pos+0   --+0 CONVERTS→number & IS EASIER TO READ THAN RE-ARRANGING INEQUALITIES.
    then mp.command(('%s seek %s absolute exact'):format(command_prefix,limits.time_pos)) end --ONLY seek FORWARDS. MORE RIGOROUS THAN SETTING time-pos DIRECTLY.  SEEKING IS MORE ELEGANT THAN TRIMMING TIMESTAMPS, FOR SPACETIME CROPPING. CROPS AUDIO TOO.
    timers.auto_delay:resume()  --FOR RAW AUDIO TOO. is1frame REQUIRES SMALL DELAY FOR INITIAL DETECTION (RELIABILITY ISSUE).

    v               =mp.get_property_native('current-tracks/video') or {}
    if not (v.id or o.no_vid) then return end  --lavfi-complex MAY NOT NEED CROPPING.
    W               =o.scale.w or o.scale[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display=WINDOWS & MACOS) OR (LINUX=[vo] DIMENSIONS)
    H               =o.scale.h or o.scale[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h']
    par             =v_params.par or v['demux-par'] or 1  --ACTS AS LOADED SWITCH. GUESS & CHECK (@video-params).
    aspect          =not OFF      and W/H or v['demux-h'] and v['demux-w']/v['demux-h'] or v_params.aspect  --SAME AS @apply_crop.
    detect_min_ratio=v.image      and o.detect_min_ratio_image or o.detect_min_ratio
    is1frame        =v.image      and mp.get_property('lavfi-complex')==''  --REQUIRE GRAPH REPLACEMENT IF image & ~complex. 
    MAINTAIN_CENTER =is1frame     and {} or o.MAINTAIN_CENTER  --RAW JPEG CAN MOVE CENTER. GIF IS ~image. 
    auto            =not is1frame and o.auto   --NO auto FOR is1frame, BECAUSE audio GLITCHES ON GRAPH REPLACEMENT.
    m               ={vid=v.id,aspect=aspect}
    detect_limit    =limits.detect_limit or v.image and o.detect_limit_image or o.detect_limit
    detector        =((v.image or v_params.alpha) and o.detector_image or o.detector):format(detect_limit,o.detect_round)  --alpha & JPEG USES bbox.
    insta_pause     =insta_pause or not pause  --PREVENTS EMBEDDED MPV FROM SNAPPING.  →nil@playback-restart.
    if insta_pause then mp.set_property_bool('pause',true) end
    
    
    mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:BLACK:frame,setsar=%s]'):format(command_prefix,label,.5+math.min(W,H*aspect),.5+math.min(W/aspect,H),W,H,par))  --.5+ CONVERTS FLOOR TO ROUND.  IF OFF, PADS AN EXTRA PAIR OF BLACK BARS. 
    mp.command(('%s vf pre @%s-crop:lavfi=[crop=iw:ih:0:0:1:1]'):format(command_prefix,label))  --SEPARATE FROM scale OR ELSE w & h COMMANDS CAUSE ERROR REPORTS IN MPV-LOG. NO INTERNAL LABELS. crop WORKS BEST INSIDE A GRAPH BECAUSE IT SUPPORTS MORE MATH.
    mp.command(('%s vf pre @%s:%s'):format(command_prefix,label,detector))  --SEPARATE FROM crop DUE TO alpha BUG.
    
    ----lavfi     =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPHS.  %d,%s = DECIMAL_INTEGER,string. 
    ----cropdetect=limit:round:reset:skip  DEFAULT=24/255:16:0  reset & skip BOTH MEASURED IN FRAMES, round IN PIXELS. reset>0 COUNTS HOW MANY FRAMES PER COMPUTATION. skip INCOMPATIBLE WITH ffmpeg-v4. alpha TRIGGERS BUG.
    ----bbox      =min_val  DEFAULT=16  [0,255]  BOUNDING BOX REQUIRED FOR JPEG.  CAN ALSO ALWAYS COMBINE MULTIPLE DETECTORS IN 1 GRAPH FOR IMPROVED RELIABILITY, BUT UNNECESSARY & MAY INCREASE CPU USAGE.
    ----crop      =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   WON'T CHANGE DIMENSIONS WITH t OR n, NOR eval=frame NOR enable=1 (TIMELINE SWITCH). BUGS OUT IF w OR h IS TOO BIG. SAFER TO AVOID SMOOTH-CROPPING. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
    ----scale     =w:h      DEFAULT=iw:ih  USING [vo] scale WOULD CAUSE EMBEDDED MPV TO SNAP @vid, SO USE display INSTEAD. EITHER WINDOW SNAPS IN, OR ELSE video SNAPS OUT.
    ----pad       =w:h:x:y:color:eval  DEFAULT=0:0:0:0:BLACK:init  0 MAY MEAN iw OR ih. FOR TOGGLE OFF. RETURNS EXTRA BLACK BARS TO CORRECT aspect. MPV HAS A WINDOW SIZE TO COLOR IN.
    ----setsar    =sar      DEFAULT=0  IS THE FINISH.  SAMPLE(PIXEL) ASPECT RATIO. VIRTUALBOX-MACOS REQUIRES IT TO PREVENT EMBEDDED MPV FROM SNAPPING. SHOULD ASSERT SAR TO ENSURE CORRECT OUTPUT ON MACOS (UNFORTUNATELY). 
    

    if insta_pause then mp.set_property_bool('pause',false) end  --& AGAIN @playback-restart FOR WHEN MULTIPLE SCRIPTS SIMULTANEOUSLY insta_pause.
end
mp.register_event('file-loaded',file_loaded)
mp.observe_property('vid','number',function(_,vid) if vid and m.vid and m.vid~=vid then file_loaded() end end)  --RELOAD IF vid CHANGES. vid=nil IF LOCKED BY lavfi-complex. m.vid VERIFIES ALREADY LOADED.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED CROPPING (& HAVE RUNNING audio). 
mp.observe_property('vf' ,'native',function() io.write(o.io_write) end)  --TRIGGERS INSTANTLY AS WELL AS ON 3RD PARTY FILTER CHANGES. 

function playback_restart() --vf-command RESET, UNLESS is1frame (GEOMETRY PERMANENT). 
    if insta_pause then mp.set_property_bool('pause',false) end
    insta_pause=nil
    if is1frame==false then paused,m.time_pos,time_pos = pause,nil,mp.get_property_number('time-pos')  --is1frame=nil FOR RAW AUDIO. nil FORCES is_effective.  time-pos FOR apply_crop.
        detect_crop()  --IN CASE ~auto.
        apply_scale()  --FOR TOGGLE OFF WHILST seeking. NEEDS PADDING. SMPLAYER DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute.
        if paused then apply_crop(m) end end  --paused REQUIRES FRAME-STEPS TO RE-ESTABLISH PADDING.
end 
mp.register_event('playback-restart',playback_restart)

function on_v_params(_,video_params)  --MAYBE MORE EFFICIENT TO observe.
    v_params    = video_params or {}  --MAYBE nil@lavfi-complex.
    max_w,max_h = v_params.w,v_params.h
    if v_params.alpha or v_params.par and v_params.par~=par then file_loaded() end  --RELOAD @alpha & @par.  par=nil @end-file  IF A PARAM IS DEFINED & CHANGES → RELOAD.
end 
mp.observe_property('video-params','native',on_v_params)  

function on_pause(_,paused)  --MORE EFFICIENT TO observe.
    pause=paused
    if unpause_time then mp.set_property_bool('pause',false) end  --FORCES unpause_on_crop BECAUSE 50ms ISN'T ENOUGH. 
end 
mp.observe_property('pause','bool',on_pause)  

function on_toggle(mute)  --PADS BLACK BARS WITHOUT EVER CHANGING [vo] scale.  A MORE RIGOROUS VERSION COULD USE osd-dimensions (WINDOW SIZE). THIS ONE IS TRUE @FULLSCREEN.
    if not  timers.mute then return  --STILL LOADING.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE TOGGLE.  
    else OFF,m.time_pos,insta_unpause = not OFF,nil,pause  --OFF SWITCH. ~m.time_pos FORCES is_effective. paused FOR unpause_on_crop.
        if par and OFF then apply_crop({ x=0,y=0, w=max_w,h=max_h }) end --NULL crop. par MEANS NOT RAW AUDIO (CAN TOGGLE limits).
        detect_crop() end  --IN CASE ~auto.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_crop_'..key,on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function detect_crop()  --USUALLY LOOPS EVERY HALF A SECOND.  MUST ALSO DETECT CROP FOR PURE AUDIO @FINAL LIMIT.
    if OFF 
    then return
    elseif limits.time_remaining and (mp.get_property_number('time-remaining') or 0)<limits.time_remaining+0 
    then mp.command(command_prefix..' playlist-next force')   --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST.  THIS IS A TIME-CROP (TECHNICALLY apply_crop). SAFER THAN RE-APPENDING TRIM FILTERS USING main.lua.
         return 
    elseif not (max_w and max_h) or not auto and m.time_pos 
    then return end  --~auto ONLY CROPS ONCE (& AGAIN @on_toggle & @playback-restart).
    min_w,min_h   = max_w*detect_min_ratio,max_h*detect_min_ratio  --MAY VARY @vid.
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
    if not (meta.x and meta.y) then meta.x,meta.y = (meta.x1+meta.x2-meta.w)/2,(meta.y1+meta.y2-meta.h)/2 end  --bbox GIVES x1 & x2 BUT NOT x. CALCULATE x & y BY TAKING AVERAGE.
    
    if o.USE_INNER_RECTANGLE 
    then xNEW  ,yNEW    = math.max(meta.x1,meta.x2-meta.w,meta.x),math.max(meta.y1,meta.y2-meta.h,meta.y)
        meta.x2,meta.y2 = math.min(meta.x2,meta.x1+meta.w,meta.x+meta.w),math.min(meta.y2,meta.y1+meta.h,meta.y+meta.h)
        meta.x ,meta.y  = xNEW,yNEW
        meta.w ,meta.h  = meta.x2-meta.x,meta.y2-meta.y end
    
    if MAINTAIN_CENTER[1] 
    then xNEW   =math.min( meta.x , max_w-(meta.x+meta.w) )  --KEEP HORIZONTAL CENTER. EXAMPLE: lavfi-complex REMAINS CENTERED.  
         wNEW   =max_w-xNEW*2  --wNEW ALWAYS BIGGER THAN meta.w, & ALWAYS SUBTRACTS AN EVEN AMOUNT.
         if wNEW-meta.w>wNEW*MAINTAIN_CENTER[1] 
         then meta.x,meta.w = xNEW,wNEW end end
    if MAINTAIN_CENTER[2] 
    then yNEW   =math.min( meta.y , max_h-(meta.y+meta.h) )  --KEEP VERTICAL CENTERED. PREVENTS FEET BEING CROPPED OFF PORTRAITS. 
         hNEW   =max_h-yNEW*2
         if hNEW-meta.h>hNEW*MAINTAIN_CENTER[2] 
         then meta.y,meta.h = yNEW,hNEW end end  --hNEW ALWAYS BIGGER THAN meta.h. SYMMETRIZE UNLESS DEVIATION FROM CENTER IS SMALL (DEPENDS HOW BIG THE FEET ARE).
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
for _,timer in pairs(timers) do timer:kill() end  --SHOULD DELAY INITIAL DETECTION (detect_seconds=auto_delay)

function apply_crop(meta)  --ALSO apply_scale (FOR PADDING BLACK BARS USING A SECOND GRAPH).  A crop CAN MAKE A WIDE-SCREEN PORTRAIT TALLER.
    m.time_pos,m.w,m.h,m.x,m.y = time_pos,meta.w,meta.h,meta.x,meta.y   --meta→m  MEMORY TRANSFER. 
    v     =mp.get_property_native('current-tracks/video') or {}
    aspect=not OFF and W/H or v['demux-h'] and v['demux-w']/v['demux-h'] or v_params.aspect  --FULL-SCREEN(ON) OR OFF&(~image OR image).
    
    if is1frame then paused=pause
        mp.set_property_bool('pause',true) --GRAPH REPLACEMENT. INSTA-pause IMPROVES RELIABILITY DUE TO INTERFERENCE FROM OTHER SCRIPTS.  MAY ALSO CHECK IF paused NEAR end-file (NOT ENOUGH TIME FOR unpause_on_crop). 
        mp.command(('%s vf pre @%s-scale:lavfi=[scale=%d:%d,pad=%d:%d:(ow-iw)/2:(oh-ih)/2:BLACK:frame,setsar=%s]'):format(command_prefix,label,.5+math.min(W,H*aspect),.5+math.min(W/aspect,H),W,H,par))  
        mp.command(('%s vf pre @%s-crop:lavfi=[crop=min(iw\\,%d):min(ih\\,%d):%d:%d:1:1]'):format(command_prefix,label,m.w,m.h,m.x,m.y))
        mp.set_property_bool('pause',paused)  
    else for whxy in ('w h x y'):gmatch('[^ ]') do mp.command(('%s vf-command %s-crop %s %d'):format(command_prefix,label,whxy,m[whxy])) end  --vf-command MAY THROW ERROR IF is1frame. 
         if m.aspect~=aspect then                apply_scale() 
            for N=3,6 do mp.add_timeout(2^N/1000,apply_scale) end end  --8 16 32 64 ms. EXPONENTIAL TIMEOUTS BECAUSE COMMANDS ARE DODGY.
         if insta_unpause then mp.set_property_bool('pause',false)  --unpause_on_toggle, UNLESS is1frame. COULD ALSO BE MADE SILENT.
            timers.pause:resume() end end
    m.aspect,insta_unpause = aspect,nil  --paused SHOULD BE CLEARED.
end

function apply_scale()  --vf-command DODGY BUT SHOULD STILL PERFORM SUPERIOR TO GRAPH REPLACEMENT. CAN BE USED TO MAINTAIN TRUE aspect. 
    mp.command(('%s vf-command %s-scale w %d'):format(command_prefix,label,.5+math.min(W,H*aspect)))  --.5+ CONVERTS FLOOR TO ROUND.  PADS EITHER HORIZONTALLY OR VERTICALLY, IN EFFECT - BOUNDED BY W,H
    mp.command(('%s vf-command %s-scale h %d'):format(command_prefix,label,.5+math.min(H,W/aspect)))
end 


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.  DIFFICULT TO THINK OF PROPER lowercase NAMES FOR THINGS LIKE o.MAINTAIN_CENTER.
----MPV v0.38.0 (.7z .exe v3) v0.37.0 (.app?) v0.36.0 (.exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED. 
----FFmpeg v6.0(.7z .exe .flatpak)  v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS ACTUALLY BUILT WITH FFmpeg v4, v5 & v6 (ALL 3), WHICH CHANGES HOW THE GRAPHS ARE WRITTEN (FOR COMPATIBILITY).
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----A FUTURE VERSION MIGHT BE ABLE TO CROP WITHOUT CHANGING ASPECT (EQUIVALENT TO AUTO-zoom). o.MAINTAIN_ASPECT? WITH WIDE-SCREEN A PORTRAIT COULD BE TALLER, BUT NOT ULTRA-FAT. MAINTAINING aspect ACTUALLY MEANS A VARIABLE scale FOR EACH crop, IN EFFECT.
----SMPLAYER v23.12 TRIGGERS GRAPH RESET ON PAUSE. THAT'S ACTUALLY AN ADDED FEATURE WHICH RESETS THE CROP WHEN USER HITS SPACEBAR. v23.6 (JUNE RELEASE) & MPV ALONE DON'T RESET crop ON pause. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms.

----ALTERNATIVE FILTERS:
----loop   =loop:size  (LOOPS>=-1:MAX_SIZE>0)  IS THE START.  INFINITE loop SWITCH FOR image (1fps). ALTERNATIVE TO GRAPH REPLACEMENT. COULD INCREASE TO 2fps (SLOW?). MORE RELIABLE WHEN USED WITH FURTHER GRAPHS WHICH WOULD INFINITE loop, LIKE automask. IT'S A RELIABILITY ISSUE: IN THEORY IT SHOULDN'T BE NECESSARY.
----format =pix_fmts          UNNECESSARY.  BUGFIX FOR alpha CAUSING BAD cropdetect PERFORMANCE. TO VERIFY SET yuva420p OR gbrap.
----split   CLONES video.     UNNECESSARY. THIS CAN BE A WORKAROUND FOR crop BECAUSE IT ISN'T SMOOTH. WHAT'S SMOOTH IS A SCALED NEGATIVE overlay, WHICH IS THEN CROPPED FROM x,y = 0,0 CONSTANT COORDS.
----overlay=x:y  DEFAULT=0:0  UNNECESSARY.  n=1@INSERTION (OFF)  THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.



