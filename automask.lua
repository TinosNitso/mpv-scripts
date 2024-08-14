----NO-WORD-WRAP FOR THIS SCRIPT.  AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH SMOOTH DOUBLE-mute TOGGLE (m&m FOR MASK). COMES WITH A DOZEN MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, SPINNING TRIANGLE, & PENTAGON. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS CAN ALSO ANIMATE & FILTER SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT (WORKS ON JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME LIKE TETRIS, WHERE THE PIECES ARE LENSES. A GAMING CONSOLE COULD USE VIDEO-IN/OUT TO MASK ON-TOP.
----APPLIES FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE DECORATIVE.
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, MP4, WEBM & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG,MP4TAG) SUPPORTED.
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv ALSO USE POWER LAW FOR NON-LINEAR SATURATION. A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. IDEAL LENS ISN'T A TRUE NEGATER.

options                 = {  
    key_bindings        = 'Ctrl+M Ctrl+m Alt+M Alt+m M',  --CASE SENSITIVE. THESE DON'T WORK INSIDE SMPLAYER.  m=MUTE.  RAPID-TOGGLING MANY MASKS COULD BE LIKE PLAYING AN ORGAN. EACH KEY GETS ITS OWN LUA SCRIPT.
    double_mute_timeout = .5  ,  --SECONDS FOR DOUBLE-MUTE-TOGGLE        (m&m DOUBLE-TAP).  SET TO 0 TO DISABLE.                    IDEAL FOR SMPLAYER.      REQUIRES AUDIO IN SMPLAYER (OR ELSE USE j&j).  VARIOUS SCRIPT/S CAN BE SIMULTANEOUSLY TOGGLED USING THESE 3 MECHANISMS. 
    double_aid_timeout  = .5  ,  --SECONDS FOR DOUBLE-AUDIO-ID-TOGGLE    (#&# DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  ANDROID MUTES USING aid. REQUIRES AUDIO. 
    double_sid_timeout  = .5  ,  --SECONDS FOR DOUBLE-SUBTITLE-ID-TOGGLE (j&j DOUBLE-TAP).  SET TO 0 TO DISABLE.  BAD FOR YOUTUBE.  IDEAL FOR SMARTPHONE.    REQUIRES sid.
    unpause_on_toggle   = .12 ,  --SECONDS TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.      SET TO 0 TO DISABLE.  A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE. is1frame IRRELEVANT. 
    toggle_t_delay      = .12 ,  --SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.  COULD BE RENAMED vf_command_t_delay.  
    toggle_duration     = .4  ,  --SECONDS FOR MASK FADE (EQUALIZER). 0 FOR INSTA-TOGGLE.  MEASURED IN time-pos.                COULD BE RENAMED fadeduration.
    toggle_expr         = 'x' ,  --(expr)=LINEAR-IN-TIME-EXPRESSION  DOMAIN & RANGE BOTH [0,1].  FOR CUSTOMIZED TRANSITION BTWN BRIGHTNESSES.  EXAMPLE='sin(PI/2*(expr))',  FOR NON-LINEAR SINUSOIDAL TRANSITION (QUARTER-WAVE).  A SINE WAVE IS 57% FASTER @MAX-SPEED (PI/2=1.57), FOR SAME DURATION, HENCE TOO FAST.
    toggle_command      = ''  ,  --EXECUTES on_toggle, UNLESS BLANK.  CAN DISPLAY ${media-title} ${mpv-version} ${ffmpeg-version} ${libass-version} ${platform} ${current-ao} ${current-vo} ${af} ${vf} ${lavfi-complex} ${osd-dimensions} ${video-out-params}.  'show-text ""' CLEARS THE OSD.  
    filterchain         = ''  ..
           'convolution =   enable = 0:0m=0 -1 0 -1 7 -1 0 -1 0:0rdiv=1/(7-4),'..  --SET enable=1 FOR 33% SHARPEN, USING A 3x3 MATRIX.  WORKS WELL WITH NATURE, BUT NOT ABSTRACT VISUALS.  INCREASE THE 7 & 7 FOR LESS%.  ALTERNATIVELY CAN SHARPEN COLORS ONLY (1m & 2m), INSTEAD OF BRIGHTNESS 0m.  
           'eq          =   enable = 0:contrast=1.1:saturation=1:gamma=1.1:gamma_r=1:gamma_g=1:gamma_b=1.1:gamma_weight=.9:eval=frame,'..  --SET enable=1 FOR EQUALIZER.  EXTRA contrast, ETC, BUT brightness IS RESERVED FOR TOGGLE.  frame MODE REQUIRED.
           'lutyuv      = \'enable = 1:'..
                           'y      = 255*((1-val/255)^4*(1+.6*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/1.7-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.005*sin(2*PI*val/minval)):'..  --y=LUMINANCE.  +.5% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH, BUT COULD ALSO CAUSE FACE WRINKLES. FORMS PART OF lutyuv GLOW-LENS.  \' FOR SYMBOLS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GRAYS).  1*gauss MAY MEAN 1 ROUND.  A SIMPLE NEGATIVE IS JUST negval.  CAN USE (random) TO RANDOMIZE.
                           'u      = 128*(1+abs(val/128-1)^.9*clip(val-128,-1,1))+4*lt(val,192):   '..  --u~=BLUE*2.  lt FOR LIMITED-TINT.  10% NON-LINEAR SATURATION.  EYES CAN ADJUST TO TINTED LENSES, BUT FILM MAY ALREADY BE TINTED.  clip IS EQUIVALENT TO sgn, WHICH IS INVALID ON FFMPEG-v4.  LINEAR saturation OVER-SATURATES TOO EASILY. 
                           'v      = 128*(1+abs(val/128-1)^.9*clip(val-128,-1,1))              :\','..  --v~=RED *2.  SUBTRACT FROM BOTH u & v FOR GREEN-TINT.  SAFER TO USE ONLY lutyuv. lutrgb CAN INCREASE LAG (EVEN IF IT'S CODED PERFECTLY). 
           'null           '   ,  --CAN REPLACE null WITH ANOTHER FILTER, LIKE pp (POSTPROCESSING).   TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).
    fps                 = 30   ,  --FRAMES-PER-SECOND FOR UNDERLYING STREAM.  MASK LOOKS CHOPPY IF PRODUCED @30fps BUT DISPLAYED @25fps.
    fps_mask            = 30   ,  --0 IMPLIES 1/period (MINIMUM fpp=1).  REDUCE FOR MUCH FASTER LOAD/seek TIMES.  LARGE period MUST USE LESS fps_mask.  SET TO 0 FOR MONACLE.
    lead_time           = '0'  ,  --SECONDS.    +-LEAD TIME OF MASK RELATIVE TO OTHER GRAPH/S.  TRIAL & ERROR.  MORE ELEGANT THAN SHIFTING THE (n) gsub.
    period              = '.5' ,  --SECONDS.    SET TO 0 FOR STATIONARY.  SUPERPERIOD=period*periods.  IF periods_skipped>0 THEN period IS ACTUALLY subperiod. 
    periods             = 2    ,  --INTEGER≥0,  PER SUPERPERIOD.  INFINITE loop OVER period*periods*superperiods. STATIONARY IF 0.  COULD BE RENAMED superperiod_size. 
    superperiods        = 2    ,  --INTEGER≥0.  THESE OPTIONS IMPROVE EFFICIENCY & SIMPLIFY COMPLICATED GRAPHS/MATH.   STATIONARY IF 0.
    periods_skipped     = 1    ,  --INTEGER≥0,  PER SUPERPERIOD.  CAUSES period ITSELF TO BECOME A "subperiod" (SMALLER/FASTER).  LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS. DOESN'T APPLY TO negate_enable & lut0_enable.  ANOTHER IDEA IS periods_reflected (PERIODS WHO MOVE OPPOSITE, USING 0% CPU).
    res_multiplier      = 1.2  ,  --SAME FOR X & Y. RESOLUTION MULTIPLIER BASED ON display. REDUCE FOR FASTER seeking (LOAD TIME).  DOESN'T APPLY TO FINAL zoompan.  HD*2 FOR SMOOTH EDGE rotations.  AT LEAST .6 FOR SIXTH SECTION.
    res_safety          = 0    ,  --RATIO≥0, RELATIVE TO res_multiplier.  PREVENTS PRIMARY DUAL rotation FROM CLIPPING, BY DIMINISHING res_multiplier (MORE MASK EXISTS THAN IS SEEN). SAME FOR X & Y.  HALF EXCESS IS LOST IF DUAL.
    SECTIONS            = 1    ,  --DEFAULT=#scales.  SET TO 10 FOR TELESCOPIC TRIANGLES.  SET TO 0 FOR BLINKING FULL SCREEN.  AUTO-GENERATES IF scales ARE MISSING.  LIMITS NUMBER OF SECTIONS (BEFORE FLIP & STACK). TOO MANY SECTIONS CHOPS FILM TOO MUCH.  COULD BE RENAMED splits, LIKE negate_enable WAS CALLED "INVERT" (CAPSLOCK CAN BE CLEARER).
    DUAL                = true ,  --DOUBLES SECTIONS.  REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
    gsubs               = {np='((n)/(fpp))',c='cos(2*PI*(np))',s='sin(2*PI*(np))',m='mod(floor(np),2)',cos='(c)',sin='(s)',mod='(m)',t,n,on,random,['#']=7,},  --SUBSTITUTIONS.  ENCLOSING BRACKETS () ARE ADDED & REQUIRED, IN EFFECT.  (fpp)=(fps_mask*period)=(FRAMES-PER-PERIOD) IS DERIVED.  EXAMPLE: USE n=5 FOR STATIONARY SPECTACLES (FREEZE FRAME).  (t),(n),(on) = (TIME),(FRAME#),(FRAMEOUT#)  (np)=(FRAME#, OR TIME, AS A RATIO TO PERIOD, BTWN 0 & periods*superperiods).  (random) IS A RANDOM # BTWN 0 & 1, FOR UNIQUE MASK @file-loaded & @RELOAD (FINAL gsub).  (fpp), LIKE fps, COULD ALSO BE NAMED (npp).  (#) IS FOR SHARPNESS OF convolution, BUT NOT CURRENTLY WORKING (MUST REMOVE BRACKETS).
    gsubs_passes        = 4    ,  --# OF SUCCESSIVE gsubs.  THEY DEPEND ON EACH OTHER, IN A DAIZY-CHAIN.  (cos)→(c)→(np)→(fpp).
    geq=           'lum = 255*lt(Y,H*3/4)*lt(abs(X-W/2),Y/sqrt(3))',  --GENERIC-EQUATION=LUMINANCE.  SET TO 255 FOR SQUARES.  W=H FOR INITIAL SQUARE CANVAS.  lt,abs,hypot = LESS-THAN,ABSOLUTE-VALUE,HYPOTENUSE   DRAWS [1] FRAME ONLY.  EQUIVALENT TO ISOSCELES SHRUNK TO 'ih*3/4'.  ARGUABLY EACH SECTION SHOULD HAVE ITS OWN geq (A LONG string).   DUAL TRIANGLES COULD START VERTICALLY INSTEAD, OR THEY NEVER ACTUALLY TOUCH! THEY'RE LIKE METAPHYSICAL ROTORS. LEFT CENTRIX IS @1/4=(1/4+1/3*3/4)/2.  THESE OCCUPY 25% OF 1080p SCREEN-SPACE.  25%=9/64*16/9=(.5*(W/2*3/4)^2*2/(W^2/a))  16:10 PC SCREENS ARE ONLY 22.5%=9/64*1.6  INSTEAD OF A QUARTER.  
    scales              = '  min(iw,ih):ow'        ,  --iw,ih=INPUT_WIDTH,INPUT_HEIGHT.  AUTO-GENERATES IF ABSENT.  min(iw,ih)=iw(PORTRAIT),ih(LANDSCAPE).  BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  
    x                   = '  (W-w)/2      '        ,  --overlay COORDS FROM CENTER.                    W,w=BIG,LITTLE SECTIONS.  TRIANGLES SHIFTED (ON PANORAMA) SO THEY GRAZE EACH OTHER.  "o.overlays" (COMBINED o.x & o.y) WOULD INSTEAD BE MEASURED FROM TOP-LEFT (LESS ELEGANT).
    y                   = '               '        ,  --DEFAULT CENTERS. DOWNWARD: NEGATIVE MEANS UP.  H,h=BIG,LITTLE SECTIONS.  
    crops               = '               '        ,  --'ow:oh:x:y ...'  NO TIME-DEPENDENCE ALLOWED.  
    rotations           = '0 -2*PI*(np)/3 '        ,  --RADIANS CLOCKWISE.  THE 0 IS FOR COMBINED DUAL.  OPPOSING SPIN: NEGATIVE rotate DUE TO LEFT BEING PRIMARY (BY CONVENTION).  "/3" FOR TERNARY-ROTATION, TRIPLES THE PERIOD.  CAN APPEND ":hypot(iw,ih):ow" TO PAD SQUARE SO AS TO PREVENT CLIPPING.  SPECIFIES rotate OF EACH SECTION>0, RELATIVE TO THE LAST, AFTER crop.  mod 0/1 SWITCH COULD BE USED TO FLICK BACK ANTI-CLOCKWISE.  PYRAMIDS ARGUABLY BETTER WITHOUT ANY ORBIT/TWIRL OR ACCELERATION.
    zoompan             = ''                       ,  --BLANK MEANS NO zoompan.  EXAMPLE: SET TO '1+(s)*(m)*.2' FOR 20% ON/OFF.  VALID ONLY WITHIN A SUPERPERIOD, FOR EFFICIENCY.
    negate_enable       = 'between((np),1.25,3.25)',  --INVERTER     TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH).  SET TO 0 FOR NO BLINKING.  TRIANGLES INVERT WHEN THEIR TIPS TOUCH.  TO START OPPOSITE, USE '1-between(...)'.  USE (random) TO RANDOMIZE.  between IS INCLUSIVE.
    lut0_enable         = '0'                      ,  --INVISIBILITY TIMELINE SWITCH.  COPY DOWN negate_enable FOR INVISIBILITY.  AN ALTERNATIVE COULD PLACE THIS BEFORE THE INVERTER, SO INVISIBILITY ITSELF IS INVERTED.
    osd_par_multiplier  = 1                ,  --NEEDED FOR NON-NATIVE SCREEN-RESOLUTIONS (& PERFECT EQUILATERAL TRIANGLES).  DISPLAY-PAR=osd-par*osd_par_multiplier.  osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO.  CAN MEASURE display TO DETERMINE ITS TRUE par.  video-out-params/par ACTUALLY MEANS VIDEO-IN-2DISPLAY (par OF ORIGINAL FILM).  
    video_out_params    = {w,h,pixelformat},  --OVERRIDES {number/string}.  DEFAULT pixelformat='yuva420p'/'yuv420p', DEPENDING.  DEFAULT w=display-width.  BUT THAT'S nil FOR LINUX SMPLAYER (CAN SET {w=1680,h=1050}).  CAN SET {h=960,w=444} TO TEST SMARTPHONE PORTRAIT.
    options             = {
        'keepaspect    no','geometry            50%',  --keepaspect=no FOR ANDROID. FREE-SIZE IF MPV HAS ITS OWN WINDOW.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.
        'hwdec         no','vd-lavc-threads     0  ',  --HARDWARE-DECODER MAY PERFORM BADLY, & BUGS OUT ON ANDROID.  VIDEO-DECODER-LIBRARY-AUDIO-VIDEO-threads OVERRIDES SMPLAYER OR ELSE MAY FAIL TESTING.  
        'sub           no','sub-create-cc-track yes',  --DEFAULTS=auto,no.  SUBTITLE CLOSED-CAPTIONS CREATE BLANK TRACK FOR double_sid_timeout (BEST TOGGLE).  JPEG VALID, BUT NOT RAW MP3.  UNFORTUNATELY YOUTUBE USUALLY BUGS OUT UNLESS sub=no.  sid=1 LATER @playback-restart. 
    },
    windows = {}, linux = {}, darwin = {},  --OPTIONAL platform OVERRIDES.
    android = {
       BINACLES             ;             period='.8',superperiods=1           ,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)',  --SMARTN12-LANDSCAPE HAS DISPLAY-ASPECT=2.2.  x='' SEPARATES THE BINACLES.  AREA%=71%=2*πH^2/a=2*π.5^2/2.2=π/2/2.2 (FOR SMARTPHONE).
    }, 
    
    ----14 MORE EXAMPLES    ; UNCOMMENT A LINE TO ACTIVATE IT.  ALL options CAN BE COMBINED ONTO 1 LINE (WITH TITLE;) & COPIED. DON'T FORGET COMMAS (BUT DOUBLE ,, IS FATAL)!  MONACLE, BINACLES & PENTAGON ARE FAST, FOR SMARTPHONE.  INCREASE SECTIONS>1 FOR TELESCOPIC.  DEFAULT CONFIG IS PYRAMIDS WHO CLICK OVER.  THESE EXAMPLES HELP CHECK LUA-SCRIPT IS VALID.  A GUI COULD ADD MANY MORE GEOMETRIES USING --script-opts, WITH ICONS FOR MONACLE, PENTAGON, PYRAMIDS, ETC.
    -- no_mask              ; SECTIONS=0 ,period='0' ,  --NULL OVERRIDE FOR LENS CALIBRATION.  LENS WITHOUT FRAME. TOGGLES STILL-FRAMES.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK.  2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS).  3) BROWN HAMMER & SICKLE.
    -- MONACLE              ;             period='.8',superperiods=1,DUAL=false,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)',  --eq MEANS EQUAL.  INVERTING MONACLE @75 BPM (60/.8 BEATS-PER-MINUTE).  "geq='255'," FOR SQUARE.
    -- BINACLES             ;             period='.8',superperiods=1           ,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)', 
    -- BINACLES_x20         ; SECTIONS=10,period='.8',superperiods=1           ,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)', 
    -- PENTAGON_HOUSE       ;             period='.8',superperiods=1,DUAL=false,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(abs(X-W/2),Y)'          ,  --WIDTH=display-height (IN LANDSCAPE-MODE).  TRIANGLE-HEIGHT=display-height/2  BOTH THIS & MONACLE CAN BE SPEED-LOADED SIMULTANEOUSLY (M/N KEYBINDS).  THE PENTAGON HAS PERFECT LR SYMMETRY, BUT IT MAY NOT APPEAR TO.  A PENTAGON COUNTS AS BOTH TRIANGLE & SQUARE, BUT WITHOUT SPIN!
    -- VISOR_H_ELLIPSE      ; y='-H/8'   ,period='.8',superperiods=1,DUAL=false,negate_enable='eq(n,0)',fps_mask=0,x='',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)'    ,scales='iw*2:ih/2',                --THIS EXAMPLE & ABOVE SPEED-LOAD (FOR SMARTPHONE).  HORIZONTAL VISOR.
    -- SPINNING_TRIANGLE    ;                                        DUAL=false,negate_enable='lt((np),2)'        ,x=''                                         ,rotations='0  2*PI*(np)/3'       , --CLOCKWISE SPINNING EQUILATERAL TRIANGLE, TOUCHING TOP & BOTTOM OF display.  INVERTS @TOP.  HYPOTENUSE=87%H=sqrt(3)/2*H.
    -- DOUBLE_TRUMPETS      ;                                                   negate_enable=  'between((np),1.7,3.7)'                                         ,rotations='0 -2*PI*((np)/3+.176)', --THE PYRAMIDS CAN BECOME TRUMPETS @THIS ANGLE.  PERFECT automask ACTUALLY DEPENDS ON path/media-title.
    -- SPINNING_SQUARES     ; SECTIONS=5                            ,DUAL=false                                   ,x='',geq='255',scales='min(iw,ih)/sqrt(2):ow',rotations='0  2*PI*(np)/4:ceil(hypot(iw,ih)/4)*4:ow',  --CORNERS GRAZE TOP & BOTTOM OF SCREEN.  "/4" FOR QUARTER-ROTATION, QUADRUPLES THE PERIOD.  5 SECTIONS, LIKE 5 FINGERS, WITH THE THUMB IN THE MIDDLE.  ROTATER PADS USING PYTHAGORAS & CEIL-4 TO PREVENT CORNER-CLIPPING.  A VARIATION COULD ALSO SLING LEFT & RIGHT.  
    -- SPINNING_SQUARES_DUAL; SECTIONS=5                                       ,negate_enable='  between((np),1.5,3.5)',geq='255',scales='min(iw,ih)/sqrt(2):ow',rotations='0 -2*PI*(np)/4:ceil(hypot(iw,ih)/4)*4:ow',  --LR-REFLECTED TWIRLS.  INVERSION @TIP-TOUCH.
    -- HEAD_BANGING_MASK    ; SECTIONS=6 ,period='.8',superperiods=1           ,negate_enable='1-between((np), .5,1.5)',geq='255*lt(hypot(X-W/2,Y-H/2),W/2)'          ,periods_skipped=0,res_safety=.15,crops='iw:ih*.8:0:ih-oh iw*.98:ih:0',scales='iw*1.1:ih/2 iw*.6:ih*.5 oh:ih oh:ih/2 oh:ih/8',zoompan='1+.2*(1-cos(2*PI*((np)-.2)))*mod(floor((np)-.2),2)',x='-W/64*(s) 0 W/16*((c)+1) W/32*(c) W/64',y='-H*((c)/16+1/6) H/16 H/32*(s) H/32*((c)+1)/2 H/64',rotations= 'PI/16*(s)*(m) PI/32*(c):iw:iw PI/32*(c)',  --OLD DEFAULT, BUT TRIANGLES ARE BETTER!  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.  SPECTACLE-TOP & RED-EYE ARE CROPPED.  PI/32=.1RADS=6° (QUITE A LOT)  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET IS LIKE A BASEBALL BAT'S ROTATIVE WIND UP.  REDUCE res_safety TO .1 TO SEE CLIPPING.   
    -- MASK_BUTTERFLY_SWIM  ; SECTIONS=6 ,period='3' ,superperiods=1           ,negate_enable='0'                      ,geq='255*lt(hypot(X-W/2,Y-H/2),W/2)',periods=1,periods_skipped=0,res_safety=.3 ,crops='iw:ih*.8:0:ih-oh iw*.98:ih:0',scales='iw*1.1:ih/2 iw*.6:ih*.5 oh:ih oh:ih/2 oh:ih/8',zoompan='1+.2*(1-cos(2*PI*((np)-.2)))*mod(floor((np)-.2),2)',x='-W/64*(s) 0 W/16*((c)+1) W/32*(c) W/64',y='-(H+h/2)*((np)-1/2) H/16 0    H/64           H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)):iw:iw -PI/32*cos(2*PI*(t))',  --SWIMS UPWARDS EVERY 3 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND.  THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- MASK_2TWIRLS_SKIP    ; SECTIONS=6 ,period='.8',superperiods=1           ,negate_enable='gte((np),1)'            ,geq='255*lt(hypot(X-W/2,Y-H/2),W/2)',periods=3,                  res_safety=.15,crops='iw:ih*.8:0:ih-oh iw*.98:ih:0',scales='iw*1.1:ih/2 iw*.6:ih*.5 oh:ih oh:ih/2 oh:ih/8',                                                             x='-W/64*(s) 0 W/16*((c)+1) W/32*(c) W/64',y='-H*((c)/16+1/6) H/16 H/32*(s) H/32*((c)+1)/2 H/64',rotations='PI/16*(s)*(m) PI/32*(c):iw:iw PI/32*(c)' ,  --DOUBLE-TWIRL & SKIP.
    -- VISOR_H_FALLING      ;             period='2' ,superperiods=1,DUAL=false,negate_enable='0',rotations='0'        ,geq='255',scales='iw:ih/3'          ,periods=1,periods_skipped=0,y='(H+h)*((np)-1/2)',res_multiplier=.5,  --FALLING  @2 SECONDS.  ONE-THIRD TALL, INSTEAD OF A QUARTER.
    -- VISOR_V_SCANNING     ;             period='2' ,superperiods=1,DUAL=false,negate_enable='0',rotations='0'        ,geq='255',scales='iw/4:ih'          ,periods=1,periods_skipped=0,x='(W+w)*((np)-1/2)',res_multiplier=.5,  --SCANNING @2 SECONDS SIDEWAYS.  A FUTURE VERSION COULD PLACE VISOR SIMULTANEOUSLY ON EITHER SIDE OF SCREEN USING A MUCH LARGER res_safety (INVERSION).

}

o,p,m,timers           = {},{},{},{} --o,p,m=options,PROPERTIES,MEMORY  timers={mute,aid,sid,playback_restarted,re_pause}  playback_restarted BLOCKS THE PRIOR 3.
g,android_surface_size = {},{}       --g=GEOMETRY table. CONVERTS STRINGS→LISTS.  android_surface_size={w,h}.
abs,max,min,random     = math.abs,math.max,math.min,math.random  --ALSO @clip & @pexpand. 
math.randomseed(os.time()+mp.get_time())  --os,mp=OPERATING-SYSTEM,MEDIA-PLAYER.  os.time()=INTEGER SECONDS FROM 1970.  mp.get_time()=μs IS MORE RANDOM THAN os.clock()=ms.  os.getenv('RANDOM')=nil

function clip(N,MIN,MAX) return N and MIN and MAX and min(max(N,MIN),MAX) end  --@apply_eq.  NUMBERS/nil.  FFMPEG SUPPORTS clip, BUT NOT LUA.  min max MIN MAX.
function round(N,D)  --ALSO @file_loaded.  NUMBERS/STRINGS/nil.  FFMPEG SUPPORTS round, BUT NOT LUA.  ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1).
    D = D or 1
    return N and math.floor(.5+N/D)*D  --round(N)=math.floor(.5+N)
end

function pexpand(arg)  --ALSO @pexpand_to_string, @show & @apply_eq.  PROTECTED PROPERTY EXPANSION.  '${speed}+2'=3.  COULD BE RENAMED ppexpand.
    if type(arg)~='string' then return arg end
    pcode, pval  = pcall(loadstring('return '..mp.command_native({'expand-text',arg}))) --''→nil.  load INVALID ON MPV.APP.  PROTECTED-CALL.
    if pcode then return pval end                                                       --OTHERWISE pcode,pval=false,string.
end

function  gp(property)  --ALSO @file_loaded & @apply_eq.  GET-PROPERTY.
    p       [property]=mp.get_property_native(property)
    return p[property]
end

p  .platform  = gp('platform') or os.getenv('OS') and 'windows' or 'linux' --platform=nil FOR OLD MPV.  OS=Windows_NT/nil.  SMPLAYER STILL RELEASED WITH OLD MPV.
o[p.platform] = {}                                                         --DEFAULT={}
for  opt,val in pairs(options) 
do o[opt]     = val end               --CLONE
require 'mp.options'.read_options(o)  --yes/no=true/false BUT OTHER TYPES DON'T AUTO-CAST.
for  opt,val in pairs(o) do if type(options[opt])~='string' then o[opt]=pexpand(val) end end  --NATIVES PREFERRED, EXCEPT FOR GRAPH INSERTS.  

for _,opt in pairs(o[p.platform].options or {}) do table.insert(o.options,opt) end  --platform OVERRIDE APPENDS TO o.options.
for _,opt in pairs(o.options)                                                                   
do command           = ('%s no-osd set %s;'):format(command or '',opt) end  --ALL SETS IN 1.
command              = command and mp.command(command)  
for opt,val in pairs(o[p.platform])  
do o[opt]            = val end               --platform OVERRIDE. 
utils                = require 'mp.utils'    --@pexpand_to_string
label                = mp.get_script_name()  --automask
v                    = gp('time-pos') and {} --FILE ALREADY LOADED.
no_mask              = o.period..''=='0' or o.periods==0 or o.superperiods==0 --..'' CONVERTS→string.  POSSIBLE no_mask BECAUSE NO TIME DEPENDENCE (fpp=1). HOWEVER MAYBE SECTIONS>1
if no_mask then o.periods,o.superperiods,o.period,o.fps_mask = 1,1,'1',0 end  --period>0 CAN BE ANYTHING (fpp=1).
periods_looped       = max(0,o.periods-o.periods_skipped-1)                   --periods_skipped=periods VALID (DISCARDS PRIMARY loop, EXCEPT FOR LEAD FRAME).
fpp                  = max(1,pexpand(('round(%s*%s)'):format(o.fps_mask,o.period))) --FRAMES-PER-      PERIOD.  round DETERMINES number FROM string.  FUTURE VERSION MIGHT ALSO SET 1 FOR is1frame.
fpsp,frames_skipped  = fpp *o.periods,fpp*o.periods_skipped                         --FRAMES-PER-SUPER-PERIOD. 
frames_total         = fpsp*o.superperiods
o.fps_mask           = ('%s/(%s)'): format(fpp,o.period)  --number→string TO AVOID RECURRING DECIMALS.  DEFAULT 1 FRAME/PERIOD (fpp=1).
o.gsubs.fpp          = o.gsubs.fpp or '('..fpp..')'
for   opt in ('filterchain scales x y rotations zoompan negate_enable lut0_enable'):gmatch('[^ ]+') --options WHICH NEED gsubs.  BLINKER SWITCH, INVISIBILITY, ETC.  filterchain (LENS) OPTIONAL.  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
do  o[opt]           =   o[opt]..''
    for N            = 1,o.gsubs_passes do for key,gsub in pairs(o.gsubs)            --gsubs DEPEND EACH-OTHER.
        do o[opt]    =   o[opt]    :gsub('%('..key..'%)','('..gsub..')') end end end --() ARE MAGIC.  INSTEAD OF RECURRING DECIMALS, THERE ARE RECURRING BRACKETS.
for  key,opt in pairs({scales='scales',x='x',y='y',crops='crops',rots='rotations',w='',h=''})
do g[key]            = {}  --INITIALIZE w,h,x,y,...  LISTS.  KEYS HAVE 1 SYLLABLE.  w,h DEDUCED FROM scales - THEY EXIST DUE TO ROUND-4 BUGFIX.
   for opt_n in (o[opt] or '')   : gmatch('[^ ]+') do table.insert(g[key],opt_n) end end
o    .SECTIONS       =             o.SECTIONS or #g.scales --COUNT SECTIONS, IF UNSPECIFIED.
no_mask              = no_mask and o.SECTIONS<=0           --mask MAY STILL BE NEEDED FOR SECTIONS.
if  o.SECTIONS      <= 0 then      o.SECTIONS,o.geq,g.scales,g.crops,g.x,g.y,g.rots = 1,'255',{'iw:ih'},{},{},{},{} end  --DEFAULT TO (BLINKING) FULL SCREEN NEGATIVE.  
for             N    = 1,          o.SECTIONS 
do  g.scales   [N]   = g.scales[N] or ('min(iw,ih)*%d/%d:ow'):format(1+o.SECTIONS-N,1+o.SECTIONS-N+(N>1 and 1 or 0))  --GENERATOR FORMULA.  N=1 FULL-SIZE (SQUARE).  EQUAL REDUCTION TO EVERY REMAINING SECTION.  h=ow SETS SQUARE ON FINAL DISPLAY.
    g.x[N],g.y [N]   = g.x     [N] or '',g.y[N] or ''  --x & y WELL-DEFINED.
    for key in   (N == 1 and 'scales x y' or ''):gmatch('[^ ]+') do for WH in ('iw ih W H'):gmatch('[^ ]+')  --N=1 ONLY
        do g[key][1] = g[key][1]:gsub(WH,('(%s/(1+%s))'):format(WH,o.res_safety)) end end  --res_safety IS JUST A DIMINISHED SCALE IN whxy: W→(W/1.15), ETC. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. x MAY DEPEND ON H, & y ON W, ETC.
    g.x[N],g.y [N]   = g.x[N]..'+(W-w)/2',g.y[N]..'+(H-h)/2' --AUTO-CENTER, OTHERWISE overlay SETS TOP-LEFT (0). THE W,H HERE NEVER GET DIMINISHED BY res_safety (TRUE CENTER).
    gmatch           = g.scales[N]:gmatch('[^:x]+')          --w & h ARE SEPARATED DUE TO FLOOR-4 BUGFIX.
    g.w[N],g.h [N]   = gmatch(),   gmatch()
    g.rots   [N+1]   = g.rots[N+1]~='0'     and g.rots[N+1] --NILLIFY 0.  [N+1] FOR SECTION-[N] DUE TO DUAL (ZEROTH) ROTATION.  
    mask             = (mask or 'null%s'):format(''         --null FOR N=1, BUT INSTEAD IT COULD BE 'split,alphamerge' INSTEAD OF N=2.
                           ..(    N> 1      and (",split[%d],scale='floor((%s)/4)*4:floor((%s)/4)*4:eval=frame'"):format(N-1,g.w[N],g.h[N])  --EACH SECTION (N>1) IS A SCALED NEGATIVE, RELATIVE TO [N-1].  floor MAKES LITTLE SECTIONS LOOK SHARPER, THAN round. USE MULTIPLES OF 4 DUE TO AN overlay BUG, OR ELSE FAILS PRECISION TESTING.  frame SCALING FOR DILATING PUPILS. BUT CLOSING THE EYELIDS MIGHT SHRINK THE PUPILS.
                               ..(N==2      and  ',split,alphamerge'  or '') --N=2 INTRODUCES TRANSPARENCY.
                               ..                ',negate'            or '')
                           ..                    '%s'  --mask RECURSIVELY GENERATES USING %s. 
                           ..(g.crops[N  ]  and  ",crop='%s'"                                     or ''):format(g.crops[N]  )  --crop, rotate & overlay.  
                           ..(g.rots [N+1]  and  ",rotate='%s:c=BLACK@0'" or ''):format(g.rots [N+1])  
                           ..(               "[%d],[%d][%d]overlay='%s:%s'"                            ):format(N,N-1,N,g.x[N],g.y[N])
                       ) end 
mask                 = mask: format('')..',format=y8'  --%s='' TERMINATES FORMATTING. REMOVE alpha AFTER FINAL overlay.
                       ..(o.DUAL and ',crop=iw*(1+1/(1+%s))/2:ow/a:0,split[L],hflip[R],[L][R]hstack' or ''):format(o.res_safety)  --MAINTAIN ASPECT RATIO a WHEN CROPPING EXCESS OFF RIGHT. SUBTRACT HALF res_safety FROM RIGHT, & A QUARTER FROM TOP & A QUARTER FROM BOTTOM: w=iw-(iw-iw/res_safety)/2  FFMPEG COMPUTES string OR ELSE INFINITE RECURRING IN LUA. MAINTAINS aspect BY EQUAL PERCENTAGE crop IN w & h. SOME EXCESS RESOLUTION IS LOST TO MAINTAIN TRUE CENTER. 
o.res_safety         =    o.DUAL and o.res_safety/2 or o.res_safety --res_safety NOW HALVED IF DUAL crop! (IN BOTH X & Y IT'S HALVED TOWARDS 1.)
o.DUAL               =    o.DUAL and 2              or 1            --boolean→number
rotate               = (g.rots[1] or '0')=='0' 
                       and (',crop  =    iw/(1+%s):ih*ow/iw'                      ):format(          o.res_safety)
                       or  (",rotate='%s:iw/(1+%s):ih*ow/iw',lut='val*gt(val,16)'"):format(g.rots[1],o.res_safety)  --OPT-IN BECAUSE IT REDUCES PERFORMANCE (TESTED 100+ NULL-OPS).  lut IS BUGFIX FOR OLD FFMPEG 0<BLACK<16.  IT'S MORE EFFICIENT TO crop INSIDE rotate.
zoompan              = ((o.zoompan or '')=='' and ',scale=%%d:%%d' 
                                   or ",zoompan='%s:d=1:s=%%dx%%d:fps=%s'"):format(o.zoompan,o.fps_mask):gsub('%(n%)','(on)')  --OPT-IN BECAUSE IT REDUCES PERFORMANCE (TESTED 100+ NULL-OPS).  (n)→(on) FOR zoompan.  


graph = no_mask and o.filterchain or ( --NULL OVERRIDE FOR SAME-FRAME TOGGLE/FAST LOAD, OR...
    "fps=%s,scale=%%d:%%d,format=%%s,split=3[vo][t0],%s[vf],nullsrc=1x1:%s:0.001,format=y8,lut=0,split[0][1],[0][vo]scale2ref=floor(oh*a*(%%s)/%d/4)*4:floor(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq='%s',loop=%d:1[1],[0]loop=%d:1[0],[1][0]scale2ref='floor((%s)/4)*4:floor((%s)/4)*4:eval=frame'[1][0],[1]%s[mask],[mask][vo]scale2ref=oh*a:ih*(1+%s)[mask][vo],[mask]loop=%d:%d,loop=%d:1%s%%s,loop=%d:%d,negate=enable='%s',lut=0:enable='%s',loop=-1:%d,trim=start_frame=%d,setpts=PTS-STARTPTS[mask],[t0]trim=end_frame=1,format=y8,setsar[t0],[t0][mask]concat,trim=start_frame=1,setpts='PTS-(%s+1/(%s))/TB',fps=%s,eq=brightness=%%s:eval=frame[mask],[vf][mask]alphamerge[vf],[vo][vf]overlay=eof_action=endall,format=%%s"
):format(o.fps,o.filterchain,o.fps_mask,o.DUAL,o.res_multiplier,o.geq,fpp-1,fpp-1,g.w[1],g.h[1],mask,o.res_safety,periods_looped,fpp,frames_skipped,rotate,o.superperiods,fpsp,o.negate_enable,o.lut0_enable,frames_total,fpsp,o.lead_time,o.fps_mask,o.fps)  --fps_mask REPEATS FOR nullsrc, zoompan & setpts.  fps REPEATS FOR [vo] & eq.  res_safety REPEATS FOR mask EXCESS & THEN rotate CROPS IT OFF.  fpp REPEATS FOR [0],[1] INITIALIZATION & periods_looped.  fpsp REPEATS FOR SUPERPERIOD GENERATION, & FIRST SUPERPERIOD REMOVAL.

----lavfi           = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH  [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [t0]=STARTPTS-FRAME [0]=SEMI-CANVAS  [1][2]...[N] ARE SECTIONS → [mask].  SELECT FILTER NAME TO HIGHLIGHT IT.  SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING & LINEDUPLICATE, ETC.  %% SUBS OCCUR LATER.  (%s) FOR MATH.  '%s' BLOCKS STRINGS FROM SPLITTING.  RE-USING LABELS IS SIMPLER.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER.  
----eq              = contrast:brightness:saturation:gamma:gamma_r:gamma_g:gamma_b:gamma_weight:eval:...:enable  DEFAULT=1:0:1:1:1:1:1:1:init  RANGES [-2,2]:[-1,1]:[0,3]:[.1,10]:[.1,10]:[.1,10]:[.1,10]:[0,1]:{init,frame}  EQUALIZER IS FINISH ON [m].  TIME-DEPENDENT CONTROLLER FOR SMOOTH-TOGGLE.  MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD INTERFERE WITH ITS brightness.  frame MODE NULL-OP USES NON-TRIVIAL CPU!
----convolution     = 0m:1m:2m:3m:0rdiv:1rdiv:2rdiv:3rdiv:...:enable  MATRICES ARE 3x3, 5x5 OR 7x7.  FOR SHARPENING [vf].  CAN ALSO SHARPEN COLORS & CHANGE PERCENTAGES USING 0rdiv:1rdiv:... ETC.  SHARPENING A FILM CAN BE DONE IN MANY DIFFERENT WAYS - THIS USES VERY LITTLE CPU.
----fps             = fps:start_time (SECONDS)  DEFAULT=25            IS THE START.  start_time FOR image --start (FREE TIMESTAMP).  IMPLEMENTS o.fps.
----zoompan         = z:x:y:d:s:fps     (z>=1)  DEFAULT=1:0:0:...:hd720:25  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN.  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----nullsrc         = s:r:d                     DEFAULT=320x240:25:-1 (size:rate:duration = PxP:FPS:SECONDS)  GENERATES 1x1 ATOMIC FRAME. MOST RELIABLE OVER MPV-v0.34→v0.38. A SINGLE ATOM IS CLONED OVER BOTH SPACE & TIME, IN THIS DESIGN.
----scale,scale2ref = w:h                       DEFAULT=iw:ih         [0][vo]→[0][vo] 2REFERENCE SCALES [0] USING DIMENSIONS OF [vo].  NULL-OP USES NO CPU.  PREPARES EACH SECTION FROM THE LAST, & SCALES 2display.  INPUT STREAM width,height CAN BE VARIABLE, SO ABSOLUTE CANVAS IS USED. scale CAN VARY, BUT NOT fps.
----crop            = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  CROPS EACH SECTION, & DUAL-EXCESS.       NULL-OP USES NO CPU.  FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
----rotate          = a:ow:oh:c  (RADIANS:p:p)  DEFAULT=0:iw:ih:BLACK ROTATES CLOCKWISE.  THE DUAL & EACH SECTION.  CAN ALSO SET bilinear.  IT HAS pad BUILT IN.
----split           = outputs                   DEFAULT=2             CLONES VIDEO.
----setpts          = expr                      DEFAULT=PTS           ZEROES OUT TIME FOR THE CANVAS. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  
----lut,lutyuv      = c0,y:u:v         [0,255]  DEFAULT=val           LOOK-UP-TABLE,BRIGHTNESS-UV  GRAY=126:128:128  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MORE EFFICIENT THAN lutrgb. lut FOR INVISIBILITY SWITCH.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----geq             = lum    (GENERIC EQUATION) DEFAULT='lum(X,Y)'    SLOW EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE, WHICH CAN THEN BE RECYCLED INDEFINITELY.  st,ld = STORE,LOAD  FUNCTIONS MAY SPEED UP ITS DRAWING.  IT CAN ALSO ACT SMOOTHLY ON TINY VIDEO.  
----overlay         = x:y:eof_action  →yuva420p DEFAULT=0:0:repeat    FINISHES [vf] & EACH SECTION [N].  FFMPEG-v6 BUG: OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING). MAYBE DUE TO COLOR HALF-PLANES (yuva420p).  HOWEVER W,H MAY NOT BE MULTIPLES OF 4.  CAN ALSO 'set end 100%' BUT THAT'S ANOTHER SUB-COMMAND & PERSISTS IN MPV PLAYLIST.  BY DEFAULT MPV LOOPS INDEFINITELY.
----trim            = ...:start_frame:end_frame DEFAULT start_frame=0 TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME.  ALSO SUBTRACTS FIRST TWIRL/S (CHOPPY LAG).  CAN ALSO END MASK.  
----loop            = loop:size  ( >=-1 : >0 )  ENABLES INFINITE loop SWITCH ON JPEG. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----format          = pix_fmts                  IS THE FINISH ON [vo]. MAY BE BLANK.  {yuva420p,y8=gray,yuv420p}  overlay FORCES yuva420p, WHILE y8 IS PREFERRED WHENEVER POSSIBLE. ya8 (16-BIT) INCOMPATIBLE WITH rotate & overlay.  [t0] REQUIRES y8 IN FFMPEG-v4, TO shuffleplanes.
----setsar            SAMPLE ASPECT RATIO;  IS WHAT MPV CALLS par, NOT sar.  FOR SAFE concat OF [t0]. ZEROES OUT ITS SAR, FOR SAR CONGRUENCE.  MASK TRUE ASPECT DOESN'T MATCH FILM - THE CIRCLES ARE ONLY CIRCLES IF aspect_none.  IT'S SAFER TO NOT USE THIS ON [vo] DSIZE.
----null              PLACEHOLDER IN filterchain, & STARTS OFF mask AS ZEROTH SECTION.  NULL-OP USES NO CPU.  
----negate            FOR INVERTER SWITCH, & EACH SECTION.
----hflip             PAIRS WITH hstack FOR DUAL.
----hstack            HORIZONTAL DUAL.
----concat            [t0][m]→[m] FINISHES [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek.
----alphamerge        IS THE FINISH ON [vf].  eof_action INVALID ON FFMPEG-v4.  ALSO CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. SIMPLER THAN ALTERNATIVES colorkey shuffleplanes colorchannelmixer.  maskedmerge IS TOO DIFFICULT TO USE (FAILS COLOR TESTING WITHOUT CAREFUL CODE, WHICH MAY NOT BE EFFICIENT)!


function file_loaded()  --ALSO @seek & @property_handler.
    v   = gp('current-tracks/video') or  {}
    ow  = o.video_out_params.w       or  gp('display-width' ) or android_surface_size.w or gp('width' ) or v['demux-w']  --number/string.  OVERRIDE  OR  display  OR  android  OR  PARAMETERS  OR  TRACK.  width=nil SOMETIMES @file-loaded, & MAY CONTINUOUSLY VARY DUE TO lavfi-complex, & MAY BE MUCH LARGER THAN display SINCE MEMORY IS CHEAP.
    oh  = o.video_out_params.h       or  gp('display-height') or android_surface_size.h or gp('height') or v['demux-h']
    if not (ow and oh and gp('current-vo')) then return end --return CONDITIONS REQUIRE DIMENSIONS & vo.  
    W,H = ow,oh                                             --W ACTS AS LOADED SWITCH.
    mp.command(''
               ..(not p.pause and 'set pause yes;' or '')  --FIRST INSTA-pause & scale TO PREVENT EMBEDDED MPV FROM SNAPPING.  ALSO IMPROVES JPEG RELIABILITY.  format MIGHT ALSO HELP (ANTI-SNAP GRAPH).
               ..(   'no-osd vf append @%s:scale=%d:%d;'):format(label,W,H)
    )
    
    alpha          = gp('video-params/alpha') 
    format         = o.video_out_params.pixelformat or p['current-vo']=='shm' and 'yuv420p' or alpha and 'yuva420p' or 'yuv420p'  --OVERRIDE  OR  SHARED-MEMORY  OR  TRANSPARENT  OR  NORMAL.  FORCING yuv420p OR yuva420p IS MORE RELIABLE.  MPV.APP COMPATIBLE WITH TRANSPARENCY, BUT NOT SMPLAYER.APP.  overlay FORCES yuva420p.  alpha BAD FOR FILM.
    loop           = v.image         and gp('lavfi-complex')=='' and not no_mask --ALSO REQUIRED FOR is1frame, FOR graph SIMPLICITY.
    is1frame       = v.albumart      and  p['lavfi-complex']=='' or      no_mask --albumart & NULL OVERRIDE ARE is1frame RELATIVE TO on_toggle.  MP4TAG & MP3TAG ARE BOTH albumart.  DON'T loop WITHOUT lavfi-complex.  FUTURE VERSION MIGHT ALSO INSERT fpp=1 FOR is1frame (SPEED-LOAD).
    m.brightness   = is1frame        and  0                      or      -1      --FILM STARTS OFF.  IF STARTING OR seeking PAUSED, IT TAKES A FEW FRAMES FOR THE MASK TO APPEAR.
    vf_toggle_OFF  = is1frame        and OFF                                     --TOGGLE OFF INSTANTLY.  brightness NEEDED FOR FURTHER TOGGLING.
    start_time     = loop            and round(gp('time-pos'),.001)              --NEAREST MILLISECOND.
    m['osd-par']   = gp('osd-par')>0 and p['osd-par'] or 1 --0,1=AUTO,SQUARE.  0@load-script, 0@file-loaded, 1@playback-restart, & 1@NON-NATIVE RES (FAIL).  MAYBE ~1 ON SOME SYSTEM.  zoompan SQUISHES THE CIRCLES INTO ELLIPSES, WHICH ARE THEN VIEWED AS PERFECT CIRCLES.
    osd_par        = m ['osd-par']*      o. osd_par_multiplier
    m.zoompan      = zoompan: format(W,H)                                   --OPT-IN.
    m.graph        = graph  : format(W,H,format,osd_par,m.zoompan,m.brightness,format):gsub('%(random%)','('..random()..')')  --format REPEATS FOR EFFICIENCY.  "m." MEANS MEMORIZED VALUE, WHEREAS graph IS A WILDCARD SCHEMATIC.
    remove_loop    = is_filter_present('loop')  --@loop MAY BE THERE DUE TO OTHER vid OR SCRIPT.
    command        = ''
                       ..(remove_loop and 'no-osd vf  remove @loop;'                             or '')
                       ..(       loop and "no-osd vf  pre    @loop:lavfi=[loop=-1:1,fps=%s:%s];" or ''):format(o.fps,start_time)  --ALL MASKS CAN REPLACE @loop.  FUTURE VERSION COULD SEPARATE THIS FROM file-loaded.
    command        = command~=''      and mp.command(command)
    mp.commandv('vf','append',('@%s:lavfi=[%s]'):format(label,m.graph))  --commandv FOR BYTECODE.  
    command        = ''
                       ..(vf_toggle_OFF and 'no-osd vf  toggle @%s;' or ''):format(label)
                       ..(not p.pause   and        'set pause  no ;' or '')
    command        = command~=''        and mp.command(command)
end

function re_pause()  --@TIMER & @cleanup.  AFTER insta_unpause ONLY.
    if not insta_unpause then return end
    mp.command('set pause yes;'..(return_terminal and 'no-osd set terminal yes;' or ''))  --ALSO return_terminal.
    insta_unpause,return_terminal = nil
end
timers.re_pause = mp.add_periodic_timer(o.unpause_on_toggle,re_pause)

function on_toggle()  --@script-message, @script-binding & @property_handler.  A DIFFERENT IDEA IS TO RANDOMLY TOGGLE EVERY FEW SECONDS, IN AUTO.
    timers.re_pause:kill()  --THESE 4 LINES FOR RAPID-TOGGLING WHEN PAUSED.  RESET TIMER FOR NEW PAUSED TOGGLE.
    timers.re_pause:resume()
    insta_unpause   = (insta_unpause  or p.pause    and o.unpause_on_toggle>0 and not is1frame)  --ALREADY insta_unpause OR IF PAUSED, UNLESS is1frame.  COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
    return_terminal = return_terminal or p.terminal and insta_unpause  --terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING TABS AS QUICK AS TOUCH-TYPING. EXAMPLE: KEEP TAPPING M IN SMPLAYER, AS FAST AS POSSIBLE.
    OFF             = not OFF 
    command         = ''
                      ..(is1frame      and 'no-osd vf  toggle   @%s;' or (apply_eq() or 1) and ''):format(label)  --no_mask & albumart  OVERRIDE  OR ELSE NORMAL.  PRESERVES FILTER ORDER (BEFORE PADDING).  UNFORTUNATELY is1frame ALWAYS SNAPS EMBEDDED MPV.
                      ..(insta_unpause and 'no-osd set terminal no ;set pause no;'   or        '')
                      ..o.toggle_command
    command         = command~='' and mp.command(command) 
end
for key in o.key_bindings: gmatch('[^ ]+') 
do mp.add_key_binding(key,label..'_'..key,on_toggle) end 
mp   .add_key_binding(nil,label          ,on_toggle)     --UNMAPPED binding.  label DIFFERENTIATES automask2.lua.

function apply_eq(brightness,toggle_duration,toggle_t_delay,toggle_expr)  --@script-message, @on_toggle & @playback-restart.  UTILITY SEPARATE FROM ITS TOGGLE.
    brightness      = pexpand(brightness)  or OFF and -1 or 0 --0,-1=ON,OFF  NEW brightness.  NATIVIZE ARGUMENTS.
    Dbrightness     = brightness-m.brightness                       --Δ INVALID ON MPV.APP (NO-GREEK).
    if Dbrightness == 0 and not vf_observed or is1frame or not (W and gp('time-pos')) or gp('seeking') then return end  --return CONDITIONS.  is1frame USES GRAPH REPLACEMENT.  video-params REQUIRED FOR target ACQUISITION (PERMANENT OP).  time-pos=nil AFTER end-file, @playback-restart.  gp('seeking') FOR JPEG+lavfi-complex.
    OFF,vf_observed = brightness<-.9,nil  --OFF IF FAINT.
    toggle_duration = insta_unpause and 0 or pexpand(toggle_duration) or o.toggle_duration     
    time_pos        = p['time-pos'] +       (pexpand(toggle_t_delay ) or o.toggle_t_delay)  --BACKWARDS-seek NEEDS MUCH LARGER toggle_t_delay (BUG).  revert-seek TOO SLOW, BUT CAN RUN TIMER WHO CHECKS time-pos EVERY FEW SECONDS. 
    time_pos        =    time_pos-(m.time_pos and clip(m.toggle_duration-(time_pos-m.time_pos),0,toggle_duration) or 0)  --PERFECT CORRECTION ASSUMES LINEARITY.  REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & CURRENT-DURATION.  RAPID TOGGLING USES PRIOR DURATION.
    x               =  toggle_duration==0     and 1 or ('clip((t-%s)/(%s),0,1)'):format(time_pos,toggle_duration) --[0,1] DOMAIN & RANGE.  0,1=INITIAL,FINAL.  number/string.  x IS WHATEVER GOES INTO A GRAPHICS CALCULATOR.
    toggle_expr     = (toggle_expr or o.toggle_expr):gsub('x',x)                                                  --NON-LINEAR clip. 
    target          =  target      or mp.command(('vf-command %s brightness -1 eq'):format(label)) and 'eq' or '' --NEW MPV OR OLD.  v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  SCALERS DON'T UNDERSTAND brightness.  

    mp.command(("vf-command %s brightness '%s+%s*(%s)' %s"):format(label,m.brightness,Dbrightness,toggle_expr,target))  --PRIOR brightness + DIFFERENCE. 
    m.brightness,m.time_pos,m.toggle_duration = brightness,time_pos,toggle_duration
end

function   event_handler (event)
    event               = event.event
    if     event       == 'start-file'  then mp.command('no-osd vf pre @loop:lavfi-loop=-1:1')  --INSTA-loop OF LEAD-FRAME IMPROVES JPEG RELIABILITY (HOOKS IN TIMESTAMPS).  video-latency-hacks ALSO RESOLVES THIS ISSUE.  INSTA-pause HERE FOR JPEG IS BETTER EXCEPT IT BLOCKS USER-pause DURING LOAD IN SMPLAYER.
    elseif event       == 'end-file'    then v,W,playback_restarted = nil  --CLEAR SWITCHES.
    elseif event       == 'file-loaded' then file_loaded()
    elseif event       == 'seek'        
    then   unload       = gp('current-vo')=='null'           and remove_filter() --ANDROID MINIMIZES USING current-vo=null.  THAT CAN BE INEFFICIENT BECAUSE MASK IS GENERATED & THEN NULLIFIED.  nil GOOD, 'null' BAD!  OLD MPV MAY FAIL TO TRIGGER seek, WHICH COMPLICATES property_handler.
           reload       =  p['current-vo']~='null' and not W and file_loaded()   --RELOAD @NEW-vo, & @ANDROID-RESTORE.  vo,v=gpu,nil IN STANDALONE MODE.
           reloop       =   loop                   and abs  (gp('time-pos')-start_time)>1 
           start_time   = reloop                   and round( p['time-pos'],.001) or start_time
           reloop       = reloop                   and mp.command(('no-osd vf pre @loop:lavfi=[loop=-1:1,fps=%s:%s]'):format(o.fps,start_time)) --JPEG PRECISE seeking: RESET STARTPTS.  PTS MAY GO NEGATIVE!  MAYBE A NULL AUDIO STREAM COULD BE SIMPLER.  IMPRECISE seek TRIGGERS playlist-next OR playlist-prev.
    else   m.brightness = -1  --playback-restart: GRAPH STATE RESETS, UNLESS is1frame.  brightness IRRELEVANT IF is1frame.  
           apply_eq() 
           timers.playback_restarted:resume() end  --UNBLOCKS DOUBLE-TAPS.  
end 
for event in ('start-file end-file file-loaded seek playback-restart'):gmatch('[^ ]+') 
do mp.register_event(event,event_handler) end
timers.playback_restarted = mp.add_periodic_timer(.01,function() playback_restarted = true end)  --playback-restart CAN TRIGGER BEFORE aid, BY LIKE 1ms, FOR albumart.

function property_handler(property,val)
    p   [property]           = val
    if   property           == 'android-surface-size' and val
    then gmatch              = val: gmatch('[^x]+')  --'960x444'=SMARTN12-LANDSCAPE.  nil=WINDOWS.  display MAY MEAN SOMETHING ELSE TO A SMARTPHONE.
        android_surface_size = {w = gmatch(),h = gmatch()} end
    ow                       = o.video_out_params.w or p['display-width' ] or android_surface_size.w  or p.width  --NEW CANVAS SIZE.
    oh                       = o.video_out_params.h or p['display-height'] or android_surface_size.h  or p.height
    for key in ('mute aid sid'):gmatch('[^ ]+')  --DOUBLE-TAPS.     W MEANS ALREADY LOADED.
    do toggle                =        property==key                  and W and playback_restarted and (not timers[key]:is_enabled() and (timers[key]:resume() or 1) or on_toggle()) end 
    vf_observed              =        property=='vf'  --vf-command-OVERRIDE.  vf CAN RESET GRAPH STATES, BUT WITHOUT TRIGGERING playback-restart!
    re_equalize              =        property=='vf'                 and W and apply_eq()
    reload                   = v and (nil     --5 RELOADS: @osd-par, @vid, @lavfi-complex, @alpha & @WxH.
                                 or   property=='osd-par'            and val~=m['osd-par']
                                 or   property=='vid'                and val           and val~=v.id --SNAPS EMBEDDED MPV.  
                                 or   property=='lavfi-complex'      and val~=''       and loop      --remove_loop
                                 or   property=='video-params/alpha' and val~=alpha    and val~=nil  --nil@end-file.  TRANSPARENCY TAKES TIME TO DETECT.
                                 or   W and (ow~=W or oh~=H)         and not (not p.fs and p.platform=='android')  --NEW CANVAS! RELOAD UNLESS HALF-SCREEN-ANDROID (IT'S SPECIAL).  SMARTPHONE ROTATION MAY DEPEND ON BUILD.  W BLOCKS null RELOAD.
    ) and file_loaded()
end 
for property in ('fs pause terminal mute aid sid vid osd-par display-width display-height width height video-params/alpha android-surface-size lavfi-complex vf'):gmatch('[^ ]+')  --BOOLEANS NUMBERS STRINGS table
do mp.observe_property(property,'native',property_handler) end

for          property in ('mute aid sid'):gmatch('[^ ]+')  --NULL-OP DOUBLE-TAPS.  current-tracks/audio/selected(double_ao_timeout) & current-tracks/sub/selected(double_sub_timeout) ARE STRONGER ALT-CONDITIONS REQUIRING OFF/ON, AS OPPOSED TO ID#.  current-ao ALSO DOES WHAT current-tracks/audio/selected DOES, BUT SAFER @playlist-next.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  
do    timers[property] = mp.add_periodic_timer(o[('double_%s_timeout'):format(property)],function()end) end
for _,timer in pairs(timers) 
do    timer.oneshot    = 1 --ALL 1SHOT.
      timer:kill() end     --FOR OLD MPV. IT CAN'T START timers DISABLED.

function is_filter_present(label) for _,vf in pairs(gp('vf')) do if vf.label==label then return true end end end  --@file_loaded & @remove_filter.
function remove_filter(label)  --@cleanup & @seek.
    W,playback_restarted = nil
    return is_filter_present(label) and mp.command('no-osd vf remove @'..label)  --@loop MAY NOT BE REMOVED.
end

function pexpand_to_string(string)  --@pprint & @show.  RETURNS string/nil, UNLIKE pexpand.
    val = pexpand(string)
    return type(val)=='string' and val or val and utils.to_string(val)
end 

function show(string,duration)  --@script-message. 
    string = pexpand_to_string(string)
    return string and mp.osd_message(string,pexpand(duration))
end

function cleanup() --@script-message.  ENABLES SCRIPT-RELOAD WITH NEW script-opts.
    re_pause()     --CHECKS IF insta_unpause.
    remove_filter(label)
    exit()
end 

function set(script_opt,val)  --@script-message.  DOESN'T RELOAD DEPENDENT FUNCTIONS.
    o[script_opt]=type(o[script_opt])=='string' and val or pexpand(val)  --NATIVE TYPECAST.
end

function callstring(string) loadstring(string)()             end  --@script-message.  CAN REPLACE ANY OTHER.
function pprint    (string) print(pexpand_to_string(string)) end  --@script-message.  PROTECTED PRINT. 
function exit      (      ) mp.keep_running = false          end  --@script-message & @cleanup.  false FLAG EXIT: COMBINES remove_key_binding, unregister_event, unregister_script_message, unobserve_property & timers.*:kill().
for message,fn in pairs({loadstring=callstring,print=pprint,show=show,exit=exit,quit=cleanup,set=set,toggle=on_toggle,apply_eq=apply_eq})  --SCRIPT CONTROLS. 
do mp.register_script_message(message,fn) end

----SCRIPT-COMMANDS & EXAMPLES:
----script-binding             automask
----script-message-to automask loadstring <string>
----script-message             loadstring math.randomseed(365)
----script-message             print      <string>
----script-message             print      m
----script-message             show       <string>        <duration>
----script-message             show       m               10*random()
----script-message             set        <script_opt>    <val>
----script-message             set        toggle_duration .3
----script-message-to automask exit
----script-message-to automask quit
----script-message-to automask toggle
----script-message-to automask apply_eq   <brightness> <toggle_duration> <toggle_t_delay> <toggle_expr>
----script-message-to automask apply_eq   -1           random()          .12             sin(PI/2*x)

----APP VERSIONS:
----MPV      : v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)    ALL TESTED. 
----FFMPEG   : v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV IS STILL OFTEN BUILT WITH 3 VERSIONS OF FFMPEG: v4, v5 & v6.
----PLATFORMS: windows  linux  darwin  android  ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-11.  WON'T OPEN JPEG ON ANDROID.
----LUA      : v5.1     v5.2  TESTED.
----SMPLAYER : v24.5, RELEASES .7z .exe .dmg .flatpak .snap .AppImage win32  &  .deb-v23.12  ALL TESTED.

----lutyuv CONVERSION FORMULAS:  
----gauss(val)         = exp(-val^2/2)/sqrt(2*PI)
----126:128:128(y:u:v) = 128:128:128(r:g:b)
----Δy,Δu,Δv,Δ(u+v)    ≈ Δ(r+g+b),2Δb,2Δr,-Δg 
---- R, G, B           ≈     Y+1.14V      ,     Y-.395U-.581V,    Y+2.032U    ≈ r,g,b                  (UNTESTED)
---- Y, U, V           ≈ .299R+.587G+.114B,-.147R-.289G+.436B,.615R-.515G-.1B ≈ y,(u-128)*2,(v-128)*2  (UNTESTED)
----    U, V           ≈                          .492(B-Y)  ,.877(R-Y)                                (UNTESTED)


----~400 LINES & ~8000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END (CONSOLE COMMANDS). ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----FUTURE VERSION COULD  COMBINE DOUBLE-TAPS INTO o.doubletap_property_binds & o.doubletap_timeout.
----FUTURE VERSION SHOULD MOVE o.toggle_command TO main.lua.  IT COULD ALSO OPERATE DOUBLE-TAPS.
----FUTURE VERSION SHOULD SET π=PI FOR o.toggle_expr, & IT SHOULD BE RENAMED.
----FUTURE VERSION SHOULD REPLACE (random) WITH $RANDOM/%RANDOM%.  COULD ALSO REPLACE (GSUB)→$GSUB ($SIGN NOTATION IS MORE ELEGANT).  (n)=n BUT ALSO $n=n (BRACKETS SEEMED MORE INTUITIVE TO BEGIN WITH.)  COULD AT LEAST REMOVE DOUBLE-RECURRING BRACKETS: ((%w+))→(%w+).  $# ALSO REQUIRED (BRACKETS ACTUALLY DON'T WORK FOR SHARPNESS).
----FUTURE VERSION SHOULD RESPOND TO CHANGING script-opts (function on_update).
----FUTURE VERSION SHOULD USE lavfi-complex FOR LOOPING JPEG, BUT THAT RESTRICTS TRACK-CHANGES.
----FUTURE VERSION SHOULD HAVE o.key_bindings_alt WITH ALTERNATIVE o.toggle_duration & o.toggle_expr.  ALT+M IS LIKE A PIANO PEDAL ON A STRING.
----FUTURE VERSION MIGHT  USE FILM-DIMENSIONS INSTEAD OF DISPLAY.  IF THE FILM SMOOTHLY VARIES ASPECT, THE TRIANGLES SHOULD TUNE TO EQUILATERAL @TRUE aspect.
----FUTURE VERSION MIGHT  HAVE A REGULAR POLYGON FORMULA.  COULD GENERATE SPINNING PENTAGON OR DODECAGON.  SOME gsubs CAN BE RECURSIVELY GENERATED IN SCRIPT, SUCH AS FOR 100-SIDED POLYGON.  SCANNING VISORS COULD ALSO BE IMPROVED.  A PARABOLIC REFLECTOR IS NEEDED.
----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----EACH automask REQUIRES EXTRA ~220MB RAM.  CAN PREDICT 145MB=1680*1050*1.2^2*30*.5*2*2/1024^2=display*o.res_multiplier^2*30fps*2periods*2superperiods/1KiB^2 

----ALTERNATIVE FILTERS:
----drawtext      = ...:expansion:...:text  COULD WRITE TEXT AS MASK, LIKE ANIMATED CLOCK.
----colorkey      = color:similarity    DEFAULT=BLACK:...      MORE PRECISE THAN alphamerge.
----pad           = w:h:x:y:color       DEFAULT=0:0:0:0:BLACK  CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----select        = expr                DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED A MEMORY LEAK).
----lut2          = eof_action  [1][2]→[1]  CAN repeat OR endall ON [m] (INSTEAD OF trim_end).  CAN ALSO GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.
----shuffleplanes = map0:map1:map2:map3 DEFAULT=0:1:2:3  WAS THE FINISH ON [m].  REQUIRED FOR COLORS, OR ELSE maskedmerge ONLY AFFECTS BRIGHTNESS.
----maskedmerge     [vo][vf][m]→[vo]  WAS THE FINISH.  BUT IT'S TOO DIFFICULT TO USE ON COLORED HALF-PLANES uv!  (y8→yuva444p, ETC). IT FAILS WITHOUT ANOTHER FILTER WHICH MAY NOT BE DONE EFFICIENTLY.  ALSO DOESN'T SUPPORT eof_action.  HOWEVER DOESN'T NEED MULTIPLES OF 4. 
----avgblur         (AVERAGE BLUR)  CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. LOOPED geq IS SUPERIOR.

----DODGY EXAMPLES:
-- DILATING_SECTIONS; SECTIONS=1,x='',y='', crops='',zoompan='1',scales='iw*(.5+.4*(s)):ow oh:ih/2' ,rotations='0',  --BUG: DILATING SECTIONS NOT WORKING FOR SECTIONS>1. overlay MIGHT BE TRYING TO COMPUTE COORDS USING init w,W,h,H.  zoompan IS SAFE.
-- DIAMOND_SECTIONS ; geq='255*lt(abs(X-W/2)+abs(Y-H/2),W/2)',  --TECHNICALLY A DIAMOND IS OBLONG.  AN IMPROVED VERSION COULD GIVE EACH SECTION ITS OWN geq.  SPIKED EYES MAY ALSO BE POSSIBLE.

----ALTERNATIVE FILTERCHAINS:
----eq ONLY        filterchain='eq=-.5:0:1.1',  
----2 SINE WAVES   filterchain='lutyuv=minval+.75*(negval-minval)+4*minval*(sin(2*PI*(negval/minval-1)/4)*lt(negval/minval\\,2)+sin(2*PI*(negval-maxval)/minval/4)*lt((maxval-negval)/minval\\,4)),eq=saturation=1.2', 
----ASIN           filterchain='lutyuv=minval+255*asin(negval/maxval)^.5/PI*2,eq=saturation=1.2', 
----ASIN ASIN      filterchain='lutyuv=255*asin(asin(negval/maxval)/PI*2)^.3/PI*2,eq=saturation=1.2', 
----SQRT+SQRT(1-X) filterchain='lutyuv=.8*255*(lt(negval\\,128)*(negval/maxval)^.5+gte(negval\\,128)*(1-negval/maxval)^.5),eq=saturation=1.2', 
----SIGNED POWERS  filterchain='lutyuv=.8*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^abs(1-val/255/.5))),eq=saturation=1.1', 
----X^(1+X^2)      filterchain='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(1+(2*abs(1-val/255/.5))^2)),eq=saturation=1.1', 
----X^(3^(X^2))    filterchain='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^(abs(1-val/255/.5)^2))),eq=saturation=1.1', 
----QUAD-GAUSS     filterchain='lutyuv=.75*(negval-minval)+minval+100/gauss(0)*(1*gauss((255-val)/(255-maxval)/2-1)-.6*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.7-1)+.6*gauss(val/minval/1.7-2)),eq=saturation=1.1',  -- .6=exp(-.5)
----TRIPLE GAUSS   filterchain='lutyuv=.75*(negval-minval)+minval+(64*gauss((255-val)/(255-maxval)/1.7-1)-64*gauss(val/minval/1.5-1)+32*gauss(val/minval/1.5-2))/gauss(0),eq=saturation=1.1',  -- .6=exp(-.5)

