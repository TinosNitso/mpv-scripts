----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH SMOOTH DOUBLE-mute TOGGLE (m&m FOR MASK). COMES WITH A DOZEN MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, SPINNING TRIANGLE, & PENTAGON. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS CAN ALSO ANIMATE & FILTER SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT (WORKS ON JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME LIKE TETRIS, WHERE THE PIECES ARE LENSES. A GAMING CONSOLE COULD USE VIDEO-IN/OUT TO MASK ON-TOP.
----APPLIES FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE PURELY DECORATIVE. DILATING PUPILS NOT CURRENTLY SUPPORTED. 
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, MP4, WEBM & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG,MP4TAG) SUPPORTED. NO drawtext IN THIS mask. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv USE POWER LAW FOR 30% NON-LINEAR SATURATION (IN EXPONENT). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. IDEAL LENS ISN'T A TRUE NEGATER.

options={  --ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATIVE).      nil & false → DEFAULT VALUES    (BUT '' MEANS true). 
    key_bindings          = 'Ctrl+M Ctrl+m M', --CASE SENSITIVE. m=MUTE. DOESN'T WORK INSIDE SMPLAYER.  'ALT+M' COULD BE automask2.lua.
    toggle_on_double_mute =  .5, --SECONDS TIMEOUT FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration       =  .3, --DEFAULT=0 SECONDS.  TIME FOR mask FADE. REMOVE FOR INSTA-TOGGLE. 
    unpause_on_toggle     = .12, --DEFAULT=0 SECONDS.  TIME TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.  REMOVE TO DISABLE. A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.
    filterchain= 'null,'         --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING). FOR SHARPEN CAN USE  convolution=0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0  (3x3 MATRIX APPLIED TO 4 PLANES.)  TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC). 
               ..'lutyuv=y=255*((1-val/255)^4*(1+.5*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/1.7-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.01*sin(2*PI*val/minval))'  --+1% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH, BUT ALSO CAUSES FACE WRINKLES. FORMS PART OF lutyuv GLOW-LENS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GRAYS).
                     ..':u=128*(1+abs(val/128-1)^.7*clip(val-128\\,-1\\,1))'  --u & v. clip IS EQUIVALENT TO sgn, BUT SUPPORTED BY FFMPEG-v4.  A DIFFERENT PERCENTAGE FOR v MAY BE OPTIMAL.  LINEAR SATURATION (eq) OVER-SATURATES TOO EASILY. 
                     ..':v=128*(1+abs(val/128-1)^.7*clip(val-128\\,-1\\,1))',
    fps_mask              =     30 ,  --DEFAULT=1/period → 1FRAME/period.  REDUCE OR REMOVE FOR MUCH FASTER LOAD/seeking TIMES.  DEFAULT GENERATES 1 FRAME ONLY, FOR FAST MONACLE.
    fps                   =     30 ,  --DEFAULT=30 FRAMES PER SECOND.  @50fps SMOOTHER THAN FILM.
    lead_time             = '-1/30',  --DEFAULT= 0 SECONDS. +-LEAD TIME OF mask RELATIVE TO OTHER GRAPHS. USE fps RATIO (TRIAL & ERROR).
    period                =  22/30 ,  --DEFAULT= 0 SECONDS. REMOVE FOR LEAD-FRAME ONLY. SHOULD USE fps RATIO.  22/30=60/82 → 82BPM (BEATS PER MINUTE).  SHOULD MATCH OTHER GRAPHS, LIKE lavfi-complex (SYNCED EYES & MOUTH).  UNFORTUNATELY A SLOW ANIMATION IS SLOW TO LOAD (CAN REDUCE RES_MULT). MOST POP IS OVER 100BPM, BUT THIS MASK IS TOO FAT TO KEEP UP (LIKE A SUMO-WRESTLER).
    periods               =      2 ,  --DEFAULT= 1 (INTEGER). INFINITE loop OVER period*periods.  period=0 OR periods=0 FOR STATIONARY.    
    -- periods_skipped    =      1 ,  --DEFAULT= 0 (INTEGER). LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOESN'T APPLY TO negate_enable & lut0_enable. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY FORMULA.
    RES_MULT              =      2 ,  --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER seeking (LOAD TIME).  DOESN'T APPLY TO zoompan (TO SPEED UP LOAD). RES_MULTIPLIER=RES_MULT/RES_SAFETY   HD*2 FOR SMOOTH EDGE rotations. AT LEAST .6 FOR SIXTH SECTION.
    RES_SAFETY            =   1.15 ,  --DEFAULT=1 (MINIMUM)  DIMINISHES RES_MULT TO ENSURE FINAL rotation NEVER CLIPS. SAME FOR X & Y.  REDUCE TO 1.1 TO SEE CLIPPING.  +10%+2% FOR iw*1.1 & W/64 (PRIMARY width & x). HOWEVER 1.12 ISN'T ENOUGH (1/.88=1.14?).  HALF EXCESS IS LOST IF DUAL. NEEDED FOR ~DUAL TOO.
    SECTIONS              =      6 ,  --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights.  LIMITS NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.  A DIFFERENT DESIGN COULD SPELL OUT EACH SECTION WITH ITS OWN geq, ETC.
    DUAL                  =   true ,  --REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
    geq=              'lum=255*lt(hypot(X-W/2\\,Y-H/2)\\,W/2)',  --DEFAULT=255=LUMINANCE. REMOVE FOR SQUARES. W=H FOR INITIAL SQUARE CANVAS.  lt,hypot = LESS-THAN,HYPOTENUSE  GRAPHIC EQUALIZER CAN DRAW ANY SECTION SHAPE WITH FORMULA (LIKE ROUNDED RECTANGLES FOR PUPILS). DRAWS [1] FRAME ONLY. SIMPLE SHAPES CAN BE DRAWN USING INTEGERS.  
    widths                = 'iw*1.1          iw*.6',  --iw=INPUT-WIDTH  NO (n,t).  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  NO TIME DEPENDENCE. REMOVE THESE 4 LINES TO AUTO-GENERATE SECTIONS. 
    heights               = 'ih/2            ih*.5 ih           ih/2           ih/8', --ih=INPUT-HEIGHT  EXACT POSITIONING IS TRIAL & ERROR. PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES, @ALL ANGLES. EYELIDS COVERING INNER PUPIL IS SQUINTING, BUT ONLY COVERING OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    x                     = '-W/64*(s)       0     W/16*(1+(c)) W/32*(c)       W/64', --(c),(s) = (cos),(sin) WAVES IN FRAME#. overlay COORDS FROM CENTER. W IS THE BIGGER PARENT SECTION, & w IS THE SECTION.  (n)=(frame#) (t)=(time) (p)→period (c)→cos(2*PI*(t)/(p)) (s)→sin(2*PI*(t)/(p)) (m)→mod(floor((n)/%s)\\,2) %s→period*fps
    y                     = '-H*((c)/16+1/6) H/16  H/32*(s)     H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD (NEGATIVE MEANS UP).  (c),(s),(m),(p),%s = (cos),(sin),(mod),(period),period*fps
    crops                 = 'iw:ih*.8:0:ih-oh  iw*.98:ih:0', --DEFAULT NO CROPS. NO TIME-DEPENDENCE ALLOWED.  SPECTACLE-TOP & RED-EYE CROPS. CLEARS mask'S TOP & MIDDLE.  oh=OUTPUT-HEIGHT
    rotations             = 'PI/16*(s)*(m)  PI/32*(c)  PI/32*(c)',  --(m)=(mod) 0,1 SWITCH  DEFAULT='0' RADIANS CLOCKWISE. CENTERED ON BIGGER SECTION.  PI/32=.1RADS=6° (QUITE A LOT)  SPECIFIES ROTATION OF EACH SECTION, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.
    zoompan=            'z=1+.2*(1-cos(2*PI*((on)/%s-.2)))*mod(floor((on)/%s-.2)\\,2)',  --DEFAULT=1  %s=period*fps  on=OUTPUT_FRAME_NUMBER (OUTPUT SHOULD SYNC).  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET, HENCE NO (c),(m) ABBREVIATIONS. IT'S LIKE A BASEBALL BAT'S ROTATIVE WIND UP.
    negate_enable         = '1-between(n/%s\\,.5\\,1.5)',  --DEFAULT=0. REMOVE FOR NO BLINKING.  n,%s = FRAME#,period*fps    TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). TO START OPPOSITE, USE "1-...".  A RANDOM # (r) gsub IS NEEDED HERE.
    -- lut0_enable        = '1-between(n/%s\\,.7\\,1.7)',  --DEFAULT=0. UNCOMMENT FOR INVISIBILITY. %s=period*fps  TIMELINE SWITCH FOR mask.  AN ALTERNATIVE CODE COULD PLACE THIS BEFORE THE INVERTER, SO INVISIBILITY ITSELF IS INVERTED.
    
    
    ----13 EXAMPLES:  UNCOMMENT A LINE TO ACTIVATE IT.  ALL options CAN BE COMBINED ONTO 1 LINE (WITH TITLE), & COPIED. DON'T FORGET COMMAS!
    -- NO_MASK        , SECTIONS=0,periods=0,  --NULL OVERRIDE FOR FAST CALIBRATION.  LENS WITHOUT FRAME. TOGGLE STILL FRAMES WITHOUT FADE.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- MONACLE        , SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y=nil,crops=nil,rotations=nil,zoompan=nil,fps_mask=nil, --INVERTING MONACLE.  geq=nil  FOR SQUARE.  SECTIONS>1 FOR CONCENTRIC DISCS.  EXACT POSITIONING IS TRIAL & ERROR.  MONACLE MAY BE THE BEST OVERALL.  BUT GRAPH MAY BE SLOW TO LOAD IT (NOT OPTIMIZED).
    -- BINACLES       , SECTIONS=1,widths='iw',heights=nil,x=nil,y=nil,crops=nil,zoompan=nil,
    -- PENTAGON_HOUSE , SECTIONS=1,DUAL=nil,widths=nil,heights='ih+2',x=nil,y=nil,crops=nil,rotations=nil,zoompan=nil,geq='255*lt(abs(X-W/2)\\,Y)',fps_mask=nil,  --+2 TO REACH THE BOTTOM. WIDTH=SCREEN_HEIGHT. TRIANGLE_HEIGHT=HALF_SCREEN.  BOTH THIS & MONACLE CAN BE LOADED SIMULTANEOUSLY (CTRL+M & ALT+M keybinds), & IT MAY LOAD FASTER THAN ANIMATION.  IT MAY BE POSSIBLE TO EXTEND THE HOUSE USING HALF-LUMINANCE.
    -- SQUARE_SPIN    , SECTIONS=1,DUAL=nil,widths=nil,heights='ih/sqrt(2)',x=nil,y=nil,crops=nil,rotations='2*PI*n/%s/4',zoompan=nil,geq=nil,  --DIAGONALS GRAZE TOP & BOTTOM OF SCREEN.  COULD ALSO OSCILLATE LEFT & RIGHT.
    -- TRIANGLE_SPIN  , SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y=nil,crops=nil,rotations='2*PI*n/%s/3',zoompan=nil,geq='255*lt(Y\\,H*3/4)*lt(abs(X-W/2)\\,Y/sqrt(3))',  --SPINNING EQUILATERAL TRIANGLE, GRAZING TOP & BOTTOM OF SCREEN.  HYPOTENUSE=87% OF HEIGHT (sqrt(3)/2) OF FULLSCREEN DISPLAY. 
    -- DIAMOND_EYES   , geq='255*lt(abs(X-W/2)+abs(Y-H/2)\\,W/2)',
    -- BUTTERFLY_SWIM , periods =1,period=3,RES_MULT=1,negate_enable=nil,y='-(H+h/2)*(n/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/32*cos(2*PI*(t))',RES_SAFETY=1.3,  --UPWARDS EVERY 3 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND.  THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- TWIRLx2_SKIP   , periods =3,periods_skipped=1,negate_enable='gte(n\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',zoompan=nil,  --DOUBLE-TWIRL & SKIP 
    -- DISCS_20_ZOOM  , SECTIONS=10,negate_enable=nil,widths=nil,heights=nil,x=nil,y=nil,crops=nil,  --10*ZOOMY CONCENTRIC DISCS.  geq=nil  FOR SQUARES.
    -- VISOR_BOUNCE   , SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,geq=nil,        --OSCILLATING VISOR.
    -- VISOR_ELLIPSE  , SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil, --DANCING ELLIPTICAL VISOR: HORIZONTAL.
    -- VISOR_VERTICAL , SECTIONS=1,DUAL=nil,periods=1,period=2,RES_MULT=nil,negate_enable=nil,widths='iw/4',heights='ih'  ,x='(W+w)*(n/%s-1/2)',y=nil,crops=nil,rotations=nil,zoompan=nil,geq=nil,  --SCANNING @2 SECONDS SIDEWAYS.
    -- VISOR_HORIZONT , SECTIONS=1,DUAL=nil,periods=1,period=2,RES_MULT=nil,negate_enable=nil,widths='iw'  ,heights='ih/3',y='(H+h)*(n/%s-1/2)',x=nil,crops=nil,rotations=nil,zoompan=nil,geq=nil,  --FALLING  @2 SECONDS.  A THIRD TALL, INSTEAD OF A QUARTER.
    
    
    -- n = 5,      t = 5/30,  --UNCOMMENT FOR STATIONARY SPECTACLES (FREEZE FRAME). SUBSTITUTIONS FOR (t) & (n)=(on)=(in).  BRACKETS ARE CLEARER.
    -- osd_on_toggle =    5,  --SECONDS. UNCOMMENT TO INSPECT VERSIONS, FILTERGRAPHS & PARAMETERS. 0 CLEARS THE osd INSTEAD. DISPLAYS mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params
    -- mask_no_vid   = true,  --mask ONTOP OF no-vid (PURE lavfi-complex). ABSTRACT VISUALS MAY BE OPTIMAL WITHOUT mask.
    -- toggle_clip   = 'sin(PI/2*%s)',  --DEFAULT='%s'=LINEAR_IN_TIME  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION (QUARTER-WAVE). DOMAIN & RANGE BOTH [0,1].  LINEAR MAY BE SUPERIOR BECAUSE A SINE WAVE IS 57% FASTER @MAX GRADIENT (PI/2=1.57).
    -- dimensions    = {w=1680,h=1050,par=1},  --DEFAULT={w=display-width,h=display-height,par=osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO}  THESE ARE OUTPUT PARAMETERS.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW DISPLAY w,h,par @file-loaded, SO OVERRIDE IS REQUIRED.  CAN MEASURE display TO DETERMINE par.
    options  =''  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.
           ..'    hwdec=no vd-lavc-threads=0  '  --HARDWARE DECODER (v0.36.0) WAS BAD FOR automask, EVEN WITH hwdec=auto-copy & vo=direct3d. FORMATS d3d11 & nv12 ALSO FAILED.  vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER OR ELSE MAY FAIL TESTING. 
           ..' geometry=50%  osd-font-size=16 '  --DEFAULT size 55p MAY NOT FIT automask2 ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO.
    ,
} 
o,label   = options,mp.get_script_name()  --label=automask  read_options MIGHT BE NEEDED TO SET MONACLE/TRIANGLE FROM ELSEWHERE?
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,toggle_duration=0,unpause_on_toggle=0,filterchain='lutyuv=negval',fps=30,periods=1,lead_time=0,periods_skipped=0,negate_enable=0,lut0_enable=0,geq=255,RES_MULT=1,RES_SAFETY=1,widths='',heights='',x='',y='',crops='',rotations=0,zoompan=1,toggle_clip='%s',dimensions={},options=''})
do o[opt] =  o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA USED BY mpv.app.  
while 1
do   opt  = o.options()  
     find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
     val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
     opt  = find and (opt):sub(0,find-1) or opt
     if not val then break    end
     mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER, TO MULTIPLES OF 4.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

if not o.period or o.period==0 or o.periods==0 then no_mask,o.period,o.periods,o.negate_enable,o.lut0_enable = true,1/o.fps,1,0,0  --POSSIBLE OVERRIDE BECAUSE NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('[^ ]') 
    do o[nt]      = o[nt] or 0 end end --n & t MUST BE WELL-DEFINED FOR NO TIME-DEPENDENCE.
g_opts            = 'widths heights x y rotations zoompan negate_enable lut0_enable'  --GEOMETRIC options WHICH NEED TO BE STRINGS & GSUBBED.
for opt in (g_opts):gmatch('[^ ]+') 
do         o[opt] = o[opt]..'' end  --string CONVERSION.  
for csm,SUB in pairs({c='cos(2*PI*(n)/%%s)',s='sin(2*PI*(n)/%%s)',m='mod(floor((n)/%%s)\\,2)',p=o.period}) do for opt in (g_opts):gmatch('[^ ]+')  --(c),(s),(m),(p) SUBSTITUTIONS.  zoompan WOULD NEED A SEPARATE LINE OF ITS OWN, TO BE RIGOROUS.  widths heights OPTIONAL (FOR eval=frame→DILATING PUPILS).  
    do o[opt]     = (o[opt]):gsub('%('..csm..'%)',SUB) end end  --%s=FRAMES/PERIOD  () ARE SPECIAL TO gsub.
o.fps_mask        = o.fps_mask or 1/o.period  --DEFAULT 1 FRAME/PERIOD (FP=1).  THIS CAUSES INFINITE RECURRING DECIMALS - NEEDS IMPROVEMENT.
FP                = round(o.fps_mask*o.period)  --ABBREV. FRAMES PER PERIOD. USES n INSTEAD OF t TO AVOID INFINITE RECURRING DECIMALS.
for opt in (g_opts):gmatch('[^ ]+') 
do         o[opt] = (o[opt]):gsub('%%s',FP) end  --%s=FRAMES/PERIOD  BLINKER SWITCH, INVISIBILITY, OVERLAYS, rotations & zoompan.
for nt in ('n t'):gmatch('[^ ]') do if o[nt] then for opt in (g_opts):gmatch('[^ ]+')  --SUB IN SPECIFIC TIME OR FRAME#.
        do o[opt] = o[opt]:gsub('%('..nt..'%)','('..o[nt]..')') end end end
o.zoompan         = o.n and (o.zoompan):gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') or o.zoompan --on=in=n  IF o.n DEFINED.
g                 = {w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} --g=GEOMETRY table. CONVERTS STRINGS→LISTS.
for key,opt in pairs(g) 
do g[key]         = {} --INITIALIZE w,h,x,y,...
   for o in o[opt]:gmatch('[^ ]+') do table.insert(g[key],o) end end
o.SECTIONS        = o.SECTIONS or math.max(#g.w,#g.h)  --COUNT SECTIONS, IF UNSPECIFIED.
if  o.SECTIONS+0 <= 0 then o.SECTIONS,o.geq,g.w,g.h,g.crops,g.x,g.y,g.rots = 1,255,{},{'0'},{},{},{},{}  --+0 CONVERTS→number.  DEFAULT TO (BLINKING) FULL SCREEN NEGATIVE (A BIG RECTANGLE).
else no_mask      = false end --mask NEEDED FOR SECTIONS.
mask              = '%s'      --mask AUTO-GENERATED RECURSIVELY FROM %s, BEFORE DUAL. 
g.rots [1]        = g.rots[1] or '0'  --DUAL ROTATION IS SPECIAL & MUST BE DEFINED.
g.w    [1]        = g.w   [1] or not g.h[1] and 'iw'  --N=1 FULL-SIZE. g.h DEDUCED FROM IT. THE GENERATOR FORMULA OTHERWISE REDUCES FROM CANVAS (BIGGER SECTION).
for     N         = 1,o.SECTIONS 
do  g.w[N]        = g.w[N]    or g.h[N] and 'oh' or ('iw*%d/%d'):format(1+o.SECTIONS-N,2+o.SECTIONS-N)  --EQUAL REDUCTION TO EVERY REMAINING SECTION.
    g.h[N]        = g.h[N]    or 'ow' --w & h WELL-DEFINED. SET h=w FOR CIRLES/SQUARES ON FINAL DISPLAY.
    g.x[N]        = g.x[N]    or ''   --x & y WELL-DEFINED.
    g.y[N]        = g.y[N]    or ''
    if N==1 then for whxy in ('w h x y'):gmatch('[^ ]') do for WH in ('iw ih W H'):gmatch('[^ ]+') 
            do g[whxy][1]=g[whxy][1]:gsub(WH,('(%s/%s)'):format(WH,o.RES_SAFETY)) end end end  --RES_SAFETY IS JUST A DIMINISHED scale IN whxy: W→(W/1.15), ETC. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. x MAY DEPEND ON H, & y ON W, ETC.
    g.x[N],g.y[N] = g.x[N]..'+(W-w)/2',g.y[N]..'+(H-h)/2' --AUTO-CENTER, OTHERWISE overlay SETS TOP-LEFT (0). THE W,H HERE NEVER GET DIMINISHED BY RES_SAFETY (TRUE CENTER).
    alphamerge    = N==2 and ',split,alphamerge' or ''    --N=2 TRANSPARENCY.
    scale_negate  = N==1 and '' or (',split[%d],scale=floor((%s)/4)*4:floor((%s)/4)*4%s,negate'):format(N-1,g.w[N],g.h[N],alphamerge)  --EACH SECTION (N>1) IS JUST A SCALED NEGATIVE, ON [N-1].  floor MAKES LITTLE SECTIONS LOOK SHARPER, THAN round. USE MULTIPLES OF 4 DUE TO AN overlay BUG, OR FAILS PRECISION TESTING.  scale=eval=frame FOR DILATING PUPILS. BUT CLOSING THE EYELIDS MIGHT SHRINK THE PUPILS.
    crop_rot      = g.crops[N]  and ',crop='..g.crops[N] or ''  --STARTING "," MAY BE MORE ELEGANT.
    crop_rot      = g.rots[N+1] and g.rots[N+1]~='0' and ('%s,rotate=%s:max(iw\\,ih):ow:BLACK@0'):format(crop_rot,g.rots[N+1]) or crop_rot  --PADS SQUARE SO AS TO AVOID CLIPPING.
    mask          = (mask):format('%s%%s%s[%d],[%d][%d]overlay=%s:%s'):format(scale_negate,crop_rot,N,N-1,N,g.x[N],g.y[N]) end   --crop rotate & overlay. 
mask              = (mask):format('')..',format=y8'..(o.DUAL and (',crop=iw*(1+1/(%s))/2:ow/a:0,split[L],hflip[R],[L][R]hstack'):format(o.RES_SAFETY) or '')  --%s='' TERMINATES FORMATTING. REMOVE alpha AFTER FINAL overlay. MAINTAIN ASPECT RATIO a WHEN CROPPING EXCESS OFF RIGHT. SUBTRACT HALF RES_SAFETY FROM RIGHT, & A QUARTER FROM TOP & A QUARTER FROM BOTTOM: w=iw-(iw-iw/RES_SAFETY)/2  FFMPEG COMPUTES string OR ELSE INFINITE RECURRING IN LUA. MAINTAINS aspect BY EQUAL PERCENTAGE crop IN w & h. SOME EXCESS RESOLUTION IS LOST TO MAINTAIN TRUE CENTER. 
o.RES_SAFETY      = o.DUAL and 1+(o.RES_SAFETY-1)/2 or o.RES_SAFETY  --RES_SAFETY NOW HALVED IF DUAL crop! (IN BOTH X & Y IT'S HALVED TOWARDS 1.)
o.DUAL            = o.DUAL and 2 or 1  --DUAL→2 OR 1 (boolean→number).
periods_loop      = math.max(0,o.periods-o.periods_skipped-1) --loop PRIMARY period THIS MUCH.  periods_skipped=periods VALID (DISCARDS PRIMARY loop, EXCEPT FOR LEAD FRAME).
skip_loop,periods_size = FP*o.periods_skipped,FP*o.periods    --# OF EXTRA LEAD FRAMES, TOTAL # OF FRAMES.

lavfi=('fps=%s,scale=%%d:%%d,setsar=1,split=3[vo][t0],%s[vf],nullsrc=1x1:%s:0.001,format=y8,lut=0,split[0][1],[0][vo]scale2ref=floor(oh*a*(%%s)/%d/4)*4:floor(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq=%s[1],[1][0]scale2ref=floor((%s)/4)*4:floor((%s)/4)*4[1][0],[0]loop=%s:1[0],[1]format=yuva420p,loop=%s:1%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%s:%s,loop=%s:1,rotate=%s:iw*oh/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:d=1:s=%%dx%%d:fps=%s,negate=enable=%s,lut=0:enable=%s,loop=-1:%d,trim=start_frame=%d[m],[t0]trim=end_frame=1,setpts=PTS-(1/FRAME_RATE+%s)/TB,setsar[t0],[t0][m]concat,trim=start_frame=1,fps=%s,eq=brightness=%%s:eval=frame[m],[vo][vf][m]maskedmerge')
      :format(o.fps,o.filterchain,o.fps_mask,o.DUAL,o.RES_MULT,o.geq,g.w[1],g.h[1],FP-1,FP-1,mask,o.RES_SAFETY,periods_loop,FP,skip_loop,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps_mask,o.negate_enable,o.lut0_enable,periods_size,periods_size,o.lead_time,o.fps)  --fps REPEATS FOR STREAM & eq.  fps_mask REPEATS FOR nullsrc & zoompan.  RES_SAFETY REPEATS FOR mask EXCESS & THEN rotate CROPS IT OFF.  FP REPEATS FOR [0],[1] INITIALIZATION, periods_skipped & FINAL SELECTOR.  

----lavfi           = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH  [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [t0]=STARTPTS-FRAME [0]=SEMI-CANVAS  [1][2]...[N] ARE SECTIONS.  SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. (%s) NEEDS BRACKETS FOR MATH. NO audio ALLOWED. RE-USING LABELS IS SIMPLER.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER.  THIS EXACT CODE PROPERLY IMPLEMENTS RES_SAFETY, WITH PRECISION. 
----fps             = fps:start_time (SECONDS)  DEFAULT=25  IS THE START.  start_time FOR image --start (FREE TIMESTAMP).  CAN LIMIT [vo] TO 30fps.
----scale,scale2ref = w:h                       DEFAULT=iw:ih  [0][vo]→[0][vo] 2REFERENCE SCALES [0] USING DIMENSIONS OF [vo].  PREPARES EACH SECTION FROM THE LAST, & SCALES 2display.  dst_format & flags=bilinear CAN ALSO BE SET.  
----setsar          = sar  SAMPLE ASPECT RATIO  DEFAULT=0  1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT (IN REALITY OUTPUT IS DIFFERENT).  ALSO FOR SAFE concat OF [t0].
----split           = outputs    CLONES VIDEO.  DEFAULT=2  
----lut,lutyuv      = c0,y:u:v         [0,255]  DEFAULT=val  LOOK-UP-TABLE,BRIGHTNESS-UV  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MORE EFFICIENT THAN lutrgb. lut FOR INVISIBILITY SWITCH & TO DROP ROTATIONAL PADDING FROM BELOW 16 TO 0.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----nullsrc         = s:r:d                     DEFAULT=320x240:25:-1  (size:rate=FPS:duration=SECONDS)  GENERATES 1x1 ATOMIC FRAME. MOST RELIABLE OVER MPV-v0.34→v0.38. A SINGLE ATOM IS CLONED OVER BOTH SPACE & TIME, IN THIS DESIGN.
----geq             = lum    GLOBAL EQUALIZER   DEFAULT=lum(X\\,Y)   SLOW EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE.  EVEN IN A *NON*-PERIODIC DESIGN ITS DRAWING/S CAN BE RECYCLED INDEFINITELY.  st,ld = STORE,LOAD  FUNCTIONS MAY IMPROVE PERFORMANCE.  IT CAN ALSO ACT SMOOTHLY ON TINY VIDEO.  THE FORMULA FOR REGULAR PENTAGON MAY BE LIKE 5 GRADIENTS DETERMINED BY atan. SPIKED EYES MAY BE POSSIBLE.
----crop            = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  IS FOR EACH SECTION, DUAL-EXCESS & PREPS THE 1x1 ATOM ON WHICH mask IS BASED. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
----rotate          = a:ow:oh:c  (RADIANS:p:p)  DEFAULT=0:iw:ih:BLACK  ROTATES CLOCKWISE, DUAL & EACH SECTION.  CAN ALSO SET bilinear.
----overlay         = x:y           →yuva420p   DEFAULT=0:0  FINISHES EACH SECTION [N].  BUG: OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING). MAYBE DUE TO COLOR HALF-PLANES (yuva420p).
----setpts          = expr                      DEFAULT=PTS  ZEROES OUT TIME FOR THE CANVAS, & IMPLEMENTS lead_time. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].
----eq              = ...:brightness:...:eval   DEFAULT=...:0:...:init  RANGES  [-1,1]:{init,frame}  EQUALIZER IS THE FINISH ON [m]. TIME-DEPENDENT CONTROLLER FOR SMOOTH-TOGGLE.  MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD INTERFERE WITH ITS brightness.
----zoompan         = z:x:y:d:s:fps     (z>=1)  DEFAULT=1:0:0:INFINITE:hd720:25  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN. NEEDS setsar FOR SAFE concat.  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----trim            = ...:start_frame:end_frame DEFAULT=...:0 TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME, &  REMOVES THE FIRST TWIRL (CHOPPY LAG).
----loop            = loop:size  ( >=-1 : >0 )      ENABLES INFINITE loop SWITCH ON JPEG. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----format          = pix_fmts  {yuva420p,y8=gray}  SECTIONAL overlay FORCES yuva420p, WHILE y8 IS PREFERRED WHENEVER POSSIBLE. ya8 (16-BIT) INCOMPATIBLE WITH rotate & overlay.
----null              PLACEHOLDER
----alphamerge        CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. SIMPLER THAN ALTERNATIVES colorkey colorchannelmixer shuffleplanes.
----negate            FOR INVERTER SWITCH, & EACH SECTION.
----hflip             PAIRS WITH hstack FOR DUAL.
----hstack            HORIZONTAL DUAL.
----concat            [t0][m]→[m]  FINISHES [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. PAIRS WITH scale2ref
----maskedmerge       IS THE FINISH ON [vo].  REDUCES NET CPU USAGE BY ~3% COMPARED TO overlay (25fps). ALSO DOESN'T NEED MULTIPLES OF 4. DOESN'T SUPPORT eof_action.


lavfi        = no_mask and o.filterchain or lavfi  --NULL OVERRIDE FOR FAST LOAD.
m,brightness = {},0  --m=MEMORY FOR vid & brightness.
function file_loaded() --ALSO @seek, @vid, @on_toggle(is1frame) & @osd-par.
    v        = mp.get_property_native('current-tracks/video') or {} 
    v_params = mp.get_property_native('video-params'        ) or {} 
    if not v_params.w or not (v.id or o.mask_no_vid) then return end  --RAW AUDIO ENDS HERE, & lavfi-complex MAY NOT NEED CROPPING.
    lavfi_complex,insta_pause = mp.get_opt('lavfi-complex'),not pause
    W        = o.dimensions.w or o.dimensions[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display=WINDOWS & MACOS) OR (LINUX=[vo] DIMENSIONS)  osd-dimensions=WINDOW SIZE, BUT THEN RESIZING THE WINDOW WOULD REPLACE THE WHOLE ANIMATION OR ELSE THE PUPILS WON'T BE PROPER CIRCLES.
    H        = o.dimensions.h or o.dimensions[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h'] 
    loop     = v.image    and not lavfi_complex and not no_mask
    is1frame = v.albumart and not lavfi_complex or      no_mask --albumart & NULL OVERRIDE ARE is1frame RELATIVE TO on_toggle.  MP4TAG & MP3TAG ARE BOTH albumart. SPECIAL & DON'T loop WITHOUT lavfi-complex. CAN COMPARE .JPG TO .MP3. image MAY HAVE VF TIME-STREAM, BUT NOT albumart.
    time_pos = loop and round(mp.get_property_number('time-pos'),.001)  --NEAREST MILLISECOND.
    if insta_pause then mp.set_property_bool('pause',1) end  --PREVENTS EMBEDDED MPV FROM SNAPPING, & is1frame INTERFERENCE.  MAYBE SHOULD USE A terminal GAP, TOO.
    
    if          is1frame and brightness==-1 and m.brightness==0
    then mp.command( 'no-osd vf remove  @'..label) --SPECIAL CASE: is1frame TOGGLE.
    elseif not (is1frame and brightness==-1)       --CHECK NOT ALREADY DISABLED is1frame (OCCURS DURING PLAYLIST: OFF→OFF).
    then mp.command(("no-osd vf append '@%s:lavfi=[%s]'"):format(label,lavfi):format(W,H,par,W,H,brightness)) end  --"''" FOR SPACEBARS IN filterchain. W,H REPEAT FOR scale & zoompan. 
    m={vid=v.id,brightness=brightness,par=par}  --MEMORY @INSERTION.
    
    for _,filter in pairs(mp.get_property_native('vf')) do if filter.label=='loop' 
        then mp    .command( 'no-osd vf remove @loop')  --remove @loop, AT CHANGE IN vid. COULD ALSO BE THERE DUE TO OTHER SCRIPTS.
            break end end
    if loop then mp.command(('no-osd vf pre    @loop:lavfi=[loop=-1:1,fps=%s:%s]'):format(o.fps,time_pos)) end  --ALL MASKS CAN REPLACE @loop.
    
    if (not v.image or v.albumart) and mp.get_property('end')=='none' then mp.set_property('end','100%') end  --ENDS mask. SIMPLER THAN TRIMMING ITS TIMESTAMPS, OR eof_action=endall. BUT NOT FOR JPEG (100%=0).  SAFE FOR MPV PLAYLIST: 100%→100%.
    if insta_pause then mp.set_property_bool('pause',false) end
end
mp.register_event('file-loaded'     ,file_loaded) --RELOAD IF brightness CHANGES. EACH REPLACEMENT TRIGGERS ANOTHER seek. 
mp.register_event('seek'            ,function() if m.brightness~=brightness           then file_loaded() end end) --RELOAD IF brightness CHANGES. EACH REPLACEMENT TRIGGERS ANOTHER seek, & IS SLOW. 
mp.observe_property('vid'  ,'number',function(_,vid) if m.vid and vid and m.vid~=vid  then file_loaded() end end) --RELOAD IF vid CHANGES. vid→nil IF LOCKED BY lavfi-complex.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED mask (& HAVE RUNNING audio). 
mp.register_event('playback-restart',function() if m.brightness~=brightness then mp.command(('vf-command %s brightness %d %s'):format(label,brightness,target)) end end)  --FOR TOGGLE DURING seeking, BUT AFTER seek (ALREADY RELOADED). NO SMOOTH-TOGGLE (POSSIBLE GLITCH).
mp.observe_property('pause','bool'  ,function(_,paused) pause=paused end)  --ALTERNATIVE TO get_property_bool.

function on_osd_par(_,osd_par)  --ASSUME osd-par=DISPLAY PIXEL ASPECT RATIO (THE REAL ASPECT OF EACH PIXEL).  IF THE DISPLAY PIXELS ARE WIDE THEN THE mask CIRCLES ARE ACTUALLY VERTICAL ELLIPSES, WHICH ARE THEN VIEWED AS PERFECT CIRCLES.
    par=o.dimensions.par or o.dimensions[3] or osd_par>0 and osd_par or 1
    if m.par and m.par~=par then file_loaded() end  --RELOAD @osd-par.  UNTESTED!  (AN EXPENSIVE SYSTEM MAY HAVE osd-par~=1.)
end
mp.observe_property('osd-par','number',on_osd_par)  --0@file-loaded, 1@playback-restart.

function on_toggle(mute)   
    if not v then return  --STILL LOADING.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE toggle. 
        return end
    
    if not target then _,error_input = mp.command(('vf-command %s brightness 0 eq'):format(label)) end  --NULL-OP.  OLD MPV REPORTS ERROR/S. scale DOESN'T UNDERSTAND brightness.
    target        = target or error_input and '' or 'eq'  --OLD MPV OR NEW. v0.37.0+ SUPPORTS TARGETED COMMANDS. BUT DON'T CHECK VERSION NUMBERS BECAUSE THEY CAN BE ANYTHING.
    p,brightness  = {},-1-brightness  -- 0,-1 = ON,OFF p=PROPERTIES LIST FOR osd_on_toggle.
    if is1frame then file_loaded()  --no_mask & albumart.
    else time_pos,Δbrightness = mp.get_property_number('time-pos')+.1,brightness-(-1-brightness)  --time+.1 BY TRIAL & ERROR. SHOULD BE AN OPTION IN FUTURE VERSION. 
         toggle_duration      = pause and 0 or o.toggle_duration 
         clip                 = toggle_duration==0 and 1 or ('clip((t-%s)/(%s),0,1)'):format(time_pos,toggle_duration)
         clip                 = (o.toggle_clip):gsub('%%s',clip)  --NON-LINEAR clip. 
         mp.command(('vf-command %s brightness %d+%d*(%s) %s'):format(label,-1-brightness,Δbrightness,clip,target))   --INITIAL BRIGHTNESS + DIFFERENCE. 
         if pause and o.unpause_on_toggle~=0 then mp.command('no-osd set terminal no;no-osd set pause no')  --unpause_on_toggle. COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  terminal GAP REQUIRED BY SMPLAYER-v24.5 OR IT GLITCHES. BUT SHOULD VERIFY FIRST THERE'S A terminal!
            timers.pause:resume() end end
    if o.osd_on_toggle then for property in ('mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params'):gmatch('[^ ]+')
            do table.insert(p,mp.get_property_osd(property)) end
            mp.osd_message(('mpv-version: %s\nffmpeg-version: %s\nlibass-version: %s\n\nlavfi-complex: %s\n\nAudio filters: \n%s\n\nVideo filters: \n%s\n\nvideo-out-params: \n%s') 
                           :format(p[1],p[2],p[3],p[4],p[5],p[6],p[7]),o.osd_on_toggle) end   --table.unpack(p) INCOMPATIBLE WITH .flatpak LUA VERSION.
end
for key in (o.key_bindings):gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute','bool',on_toggle)

timers    = {  --CARRY OVER IN MPV PLAYLIST.
    mute  = mp.add_periodic_timer(o.toggle_on_double_mute,function() end),  --mute TIMER TIMES. 0s VALID.
    pause = mp.add_periodic_timer(o.unpause_on_toggle    ,function() mp.command('no-osd set pause yes;no-osd set terminal yes') end),  --pause TIMER PAUSES & RETURNS terminal.  HOWEVER SHOULD FIRST CHECK THERE EVER WAS A terminal!
}
for _,timer in pairs(timers) do timer.oneshot=1
                                timer:kill() end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----EACH mask REQUIRES EXTRA ~450MB RAM.  CAN PREDICT 296MB=1680*1050*2^2*22*2/1024^2=display*RES_MULT^2*22FRAMES*2periods/1MB  
----A DIFFERENT VERSION COULD FADE OUT 1s NEAR end-file (FINALE).

----ALTERNATIVE FILTERS:
----drawtext = ...:expansion:...:text  COULD WRITE TEXT AS MASK, LIKE ANIMATED CLOCK.
----colorkey = color:similarity  MORE PRECISE THAN alphamerge.
----pad      = w:h:x:y:color     CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----lut2     = eof_action  [1][2]→[1]  CAN repeat OR endall ON [m] (INSTEAD OF trim_end).  CAN ALSO GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.
----select   = expr  DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED A MEMORY LEAK).
----shuffleplanes ALTERNATIVE TO alphamerge.
----avgblur       (AVERAGE BLUR)  CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. geq IS BETTER.

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

