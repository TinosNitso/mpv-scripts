----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH SMOOTH DOUBLE-mute TOGGLE (m&m FOR MASK). COMES WITH A DOZEN MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, SPINNING TRIANGLE, & PENTAGON. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS CAN ALSO ANIMATE & FILTER SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT (WORKS ON JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME LIKE TETRIS, WHERE THE PIECES ARE LENSES. A GAMING CONSOLE COULD USE VIDEO-IN/OUT TO MASK ON-TOP.
----APPLIES FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE DECORATIVE.
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, MP4, WEBM & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG,MP4TAG) SUPPORTED. NO drawtext IN THIS mask. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv USE POWER LAW FOR 20% NON-LINEAR SATURATION (IN EXPONENT). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. IDEAL LENS ISN'T A TRUE NEGATER.

options={  --ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATIVE).      nil & false → DEFAULT VALUES    (BUT '' MEANS true). 
    key_bindings        = 'Ctrl+M Ctrl+m M', --CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER.  m=MUTE.  'ALT+M' COULD BE automask2.lua.
    double_mute_timeout =   .5 ,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). TRIPLE MUTE DOUBLES BACK. SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration     =   .3 ,  --SECONDS TIME FOR mask FADE. REMOVE FOR INSTA-TOGGLE. 
    unpause_on_toggle   =   .12,  --SECONDS TIME TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.  REMOVE TO DISABLE. A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.
    vf_command_t_delay  =   .12,  --DEFAULT=0 SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.
    filterchain         = 'null,' --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING).   TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).
    -- ..'convolution=0m=0 -1 0 -1 7 -1 0 -1 0:0rdiv=1/(7-4),'  --UNCOMMENT FOR 33% SHARPEN, USING A 3x3 MATRIX. INCREASE 7 & 7 FOR LESS.  ALTERNATIVELY CAN SHARPEN COLORS ONLY (1m & 2m), INSTEAD OF BRIGHTNESS 0m.
       ..      'lutyuv=y=255*((1-val/255)^4*(1+.6*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/1.7-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.01*sin(2*PI*val/minval))'  --+1% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH, BUT ALSO CAUSES FACE WRINKLES. FORMS PART OF lutyuv GLOW-LENS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GRAYS).  1*gauss MAY MEAN 1 ROUND.
       ..            ':u=128*(1+abs(val/128-1)^.8*clip(val-128\\,-1\\,1))'  --u & v. clip IS EQUIVALENT TO sgn, WHICH IS INVALID ON FFMPEG-v4.  A DIFFERENT PERCENTAGE FOR v MAY BE BETTER.  LINEAR SATURATION (eq) OVER-SATURATES TOO EASILY. 
       ..            ':v=128*(1+abs(val/128-1)^.8*clip(val-128\\,-1\\,1))',
    fps_mask            =     30 ,  --DEFAULT=1/period → 1FRAME/period.  REDUCE OR REMOVE FOR MUCH FASTER LOAD/seeking TIMES, ESPECIALLY WITH LARGE period (SLOW ANIMATION).  DEFAULT GENERATES 1 FRAME/period ONLY, FOR FAST MONACLE.
    fps                 =     30 ,  --DEFAULT=30 FRAMES PER SECOND.  @50fps SMOOTHER THAN FILM.
    lead_time           = '-1/30',  --DEFAULT=0 SECONDS.  +-LEAD TIME OF mask RELATIVE TO OTHER GRAPHS. USE fps RATIO (TRIAL & ERROR).
    period              = '22/30',  --SECONDS. REMOVE FOR 1 FRAME ONLY PER PERIOD. SHOULD USE fps RATIO.  22/30=60/82 → 82 BPM (BEATS PER MINUTE).  SHOULD MATCH OTHER GRAPHS, LIKE lavfi-complex (SYNCED EYES & MOUTH).  MOST POP IS OVER 100BPM, BUT THIS MASK IS TOO BIG TO KEEP UP (LIKE A SUMO-WRESTLER).
    periods             =      2 ,  --DEFAULT=1 (INTEGER). INFINITE loop OVER period*periods.  period=0 OR periods=0 FOR STATIONARY.    
    -- periods_skipped  =      1 ,  --DEFAULT=0 (INTEGER). LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOESN'T APPLY TO negate_enable & lut0_enable. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY FORMULA.
    RES_MULT            =      2 ,  --DEFAULT=1  RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER seeking (LOAD TIME).  DOESN'T APPLY TO zoompan (TO SPEED UP LOAD). RES_MULTIPLIER=RES_MULT/RES_SAFETY   HD*2 FOR SMOOTH EDGE rotations.
    RES_SAFETY          =   1.15 ,  --DEFAULT=1 (MINIMUM)  DIMINISHES RES_MULT TO PREVENT FINAL rotation FROM CLIPPING. SAME FOR X & Y.  REDUCE TO 1.1 TO SEE CLIPPING.  +10%+2% FOR iw*1.1 & W/64 (PRIMARY width & x). HOWEVER 1.12 ISN'T ENOUGH (1/.88=1.14?).  HALF EXCESS IS LOST IF DUAL. NEEDED FOR ~DUAL TOO.
    SECTIONS            =      6 ,  --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS scales.  LIMITS NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES IF scales ARE MISSING. ELLIPTICITY=0 BY DEFAULT.  A DIFFERENT DESIGN COULD SPELL OUT EACH SECTION WITH ITS OWN geq, ETC.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    DUAL                =   true ,  --REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
    geq=            'lum=255*lt(hypot(X-W/2\\,Y-H/2)\\,W/2)',  --DEFAULT=255=LUMINANCE. REMOVE FOR SQUARES. W=H FOR INITIAL SQUARE CANVAS.  lt,hypot = LESS-THAN,HYPOTENUSE  GRAPHIC EQUALIZER CAN DRAW ANY SECTION SHAPE WITH FORMULA (LIKE ROUNDED RECTANGLES FOR PUPILS). DRAWS [1] FRAME ONLY. SIMPLE SHAPES CAN BE DRAWN USING INTEGERS.  
    scales              = '                iw*1.1:ih/2       iw*.6:ih*.5 oh:ih        oh:ih/2        oh:ih/8 ',  --iw,ih = INPUT_WIDTH,INPUT_HEIGHT  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  REMOVE THIS & x & y TO AUTO-GENERATE SECTIONS.  PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING.
    x                   = '                -W/64*(s)         0           W/16*((c)+1) W/32*(c)       W/64    ',  --(c),(s) = (cos),(sin) WAVES IN FRAME#. overlay COORDS FROM CENTER. W IS THE BIGGER PARENT SECTION, & w IS THE SECTION.  (n),(t),(c),(s),(m),(p),%s = (FRAME#),(TIME),(cos),(sin),(mod),(period),fpp  (c),(s),(m),%s = cos(2*PI*(n)/%s),sin(2*PI*(n)/%s),mod(floor((n)/%s)\\,2),fps_mask*period  fpp=FRAMES_PER_PERIOD
    y                   = '                -H*((c)/16+1/6)   H/16        H/32*(s)     H/32*((c)+1)/2 H/64    ',  --DEFAULT CENTERS.  DOWNWARD (NEGATIVE MEANS UP).  x & y SHOULDN'T BE COMBINED DUE TO CENTERING.
    crops               = '                iw:ih*.8:0:ih-oh  iw*.98:ih:0 ',  --DEFAULT NO CROPS. NO TIME-DEPENDENCE ALLOWED.  SPECTACLE-TOP & RED-EYE CROPS. CLEARS mask'S TOP & MIDDLE.  oh=OUTPUT-HEIGHT
    rotations           = ' PI/16*(s)*(m)  PI/32*(c)         PI/32*(c)   ',  --(m)=(mod) 0,1 SWITCH  DEFAULT='0' RADIANS CLOCKWISE. CENTERED ON BIGGER SECTION.  PI/32=.1RADS=6° (QUITE A LOT)  SPECIFIES ROTATION OF EACH SECTION, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.
    zoompan=          'z=1+.2*(1-cos(2*PI*((on)/%s-.2)))*mod(floor((on)/%s-.2)\\,2)',  --DEFAULT=1  %s = fpp=FRAMES/PERIOD  on=OUTPUT_FRAME_NUMBER (OUTPUT SHOULD SYNC).  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET, HENCE NO (c),(m) ABBREVIATIONS. IT'S LIKE A BASEBALL BAT'S ROTATIVE WIND UP.
    negate_enable       = '1-between(n/%s\\,.5\\,1.5)',  --DEFAULT=0. REMOVE FOR NO BLINKING.     n,%s = FRAME#,fpp  TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). TO START OPPOSITE, USE "1-...".  AN (r)=math.random(0,1) gsub IS NEEDED HERE (FUTURE VERSION).
    -- lut0_enable      = '1-between(n/%s\\,.7\\,1.7)',  --DEFAULT=0. UNCOMMENT FOR INVISIBILITY.   %s = fpp         TIMELINE SWITCH FOR mask.  AN ALTERNATIVE CODE COULD PLACE THIS BEFORE THE INVERTER, SO INVISIBILITY ITSELF IS INVERTED.
    
    
    ----13 EXAMPLES:  UNCOMMENT A LINE TO ACTIVATE IT.  ALL options CAN BE COMBINED ONTO 1 LINE (WITH TITLE), & COPIED. DON'T FORGET COMMAS!  MONACLE & PENTAGON ARE FAST.  INCREASE SECTIONS>1 FOR TELESCOPIC. 
    -- NO_MASK        , SECTIONS=0,periods=0,  --NULL OVERRIDE FOR FAST CALIBRATION.  LENS WITHOUT FRAME. STILL FRAMES TOGGLE WITHOUT FADE.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK.  2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS).  3) BROWN HAMMER & SICKLE.
    -- MONACLE        , SECTIONS=1,x=nil,y=nil,crops=nil,zoompan=nil,DUAL=nil,scales='oh:ih'        ,rotations=nil,fps_mask=nil, --INVERTING MONACLE.  geq=nil  FOR SQUARE.  SECTIONS>1 FOR CONCENTRIC DISCS.  MONACLE MAY BE THE BEST OVERALL.  
    -- BINACLES       , SECTIONS=1,x=nil,y=nil,crops=nil,zoompan=nil,         scales='iw:ow'        ,
    -- PENTAGON_HOUSE , SECTIONS=1,x=nil,y=nil,crops=nil,zoompan=nil,DUAL=nil,scales='oh:ih+2'      ,rotations=nil          ,geq='255*lt(abs(X-W/2)\\,Y)',fps_mask=nil,  --+2 TO REACH THE BOTTOM. WIDTH=SCREEN_HEIGHT. TRIANGLE_HEIGHT=HALF_SCREEN.  BOTH THIS & MONACLE CAN BE LOADED SIMULTANEOUSLY (CTRL+M & ALT+M keybinds), & MAY STILL LOAD FASTER THAN ANIMATION.  THE PENTAGON HAS PERFECT LR SYMMETRY, BUT IT MAY NOT APPEAR TO.
    -- SQUARES_SPIN   , SECTIONS=8,x=nil,y=nil,crops=nil,zoompan=nil,DUAL=nil,scales='oh:ih/sqrt(2)',rotations='2*PI*n/%s/4',geq=nil,  --DIAGONALS GRAZE TOP & BOTTOM OF SCREEN.  COULD ALSO OSCILLATE LEFT & RIGHT.
    -- TRIANGLE_SPIN  , SECTIONS=1,x=nil,y=nil,crops=nil,zoompan=nil,DUAL=nil,scales='oh:ih'        ,rotations='2*PI*n/%s/3',geq='255*lt(Y\\,H*3/4)*lt(abs(X-W/2)\\,Y/sqrt(3))',  --SPINNING EQUILATERAL TRIANGLE, GRAZING TOP & BOTTOM OF SCREEN.  HYPOTENUSE=87% OF HEIGHT (sqrt(3)/2) OF FULLSCREEN DISPLAY.  EQUIVALENT TO ISOSCELES SHRUNK TO 'ih*3/4'.
    -- DIAMOND_EYES   , geq='255*lt(abs(X-W/2)+abs(Y-H/2)\\,W/2)',  --SPIKED EYES MAY ALSO BE POSSIBLE.
    -- BUTTERFLY_SWIM , periods =1,period=3,RES_MULT=1,negate_enable=nil,y='-(H+h/2)*(n/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/32*cos(2*PI*(t))',RES_SAFETY=1.3,  --UPWARDS EVERY 3 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND.  THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- TWIRLS2SKIP    , periods =3,periods_skipped=1,zoompan=nil,negate_enable='gte(n\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',  --DOUBLE-TWIRL & SKIP 
    -- DISCS_20_ZOOM  , SECTIONS=10,        crops=nil,        scales=nil,x=nil,y=nil,negate_enable=nil,  --10*ZOOMY CONCENTRIC DISCS.  geq=nil  FOR SQUARES.
    -- VISOR_BOUNCE   , SECTIONS=1,DUAL=nil,crops=nil,geq=nil,rotations=nil,  --OSCILLATING VISOR.
    -- VISOR_ELLIPSE  , SECTIONS=1,DUAL=nil,crops=nil,        scales='iw*2:ih/2',x=nil,y='-H/8', --DANCING ELLIPTICAL VISOR: HORIZONTAL.
    -- VISOR_VERTICAL , SECTIONS=1,DUAL=nil,crops=nil,geq=nil,scales='iw/4:ih'  ,rotations=nil,periods=1,period=2,RES_MULT=.5,negate_enable=nil,y=nil,x='(W+w)*(n/%s-1/2)',zoompan=nil,  --SCANNING @2 SECONDS SIDEWAYS.
    -- VISOR_HORIZONT , SECTIONS=1,DUAL=nil,crops=nil,geq=nil,scales='iw/1:ih/3',rotations=nil,periods=1,period=2,RES_MULT=.5,negate_enable=nil,x=nil,y='(H+h)*(n/%s-1/2)',zoompan=nil,  --FALLING  @2 SECONDS.  A THIRD TALL, INSTEAD OF A QUARTER.
    

    -- t = '5/30', n = 5,  --UNCOMMENT FOR STATIONARY SPECTACLES (FREEZE FRAME). ONLY 1 OR THE OTHER IS NEEDED.  THESE ARE SUBSTITUTIONS FOR (t) & (n)=(on)=(in). BRACKETS ARE CLEARER.  IMPLIES fps_mask=nil.
    -- osd_on_toggle = 5,  --SECONDS. UNCOMMENT TO INSPECT VERSIONS, FILTERGRAPHS, ETC.  DISPLAYS  _VERSION mpv-version ffmpeg-version libass-version platform current-vo osd-par lavfi-complex af vf video-out-params  COULD BE MOVED TO main.lua.
    -- toggle_expr   = 'sin(PI/2*%s)',        --DEFAULT=%s=LINEAR_IN_TIME_EXPRESSION  UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION (QUARTER-WAVE). DOMAIN & RANGE BOTH [0,1].  LINEAR MAY BE SUPERIOR BECAUSE A SINE WAVE IS 57% FASTER @MAX GRADIENT (PI/2=1.57).
    -- dimensions    = {w=1680,h=1050,par=1}, --DEFAULT={w=display-width,h=display-height,par=osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO}  THESE ARE OUTPUT PARAMETERS.  MPV EMBEDDED IN VIRTUALBOX OR SMPLAYER MAY NOT KNOW DISPLAY w,h,par @file-loaded, SO OVERRIDE IS REQUIRED.  CAN MEASURE display TO DETERMINE par.
    mask_no_vid      = true, --mask ONTOP OF no-vid (PURE lavfi-complex). COULD SLOW DOWN ABSTRACT VISUALS.
    options          = {
        'vd-lavc-threads 0 ','   hwdec no      ','geometry 50%',  --vd-lavc=VIDEO_DECODER-LIBRARY_AUDIO_VIDEO. 0=AUTO OVERRIDES SMPLAYER OR ELSE MAY FAIL TESTING.  hwdec=HARDWARE_DECODER CAUSES BAD PERFORMANCE OR FAILURE.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.
        '  osd-font-size 16','osd-font Consolas',  --DEFAULT size 55p MAY NOT FIT automask2 ON osd.  MONOSPACE FONT PREFERRED.
    },
} 
o,label    = options,mp.get_script_name()  --label=automask  mp=MEDIA-PLAYER  read_options MIGHT BE NEEDED TO READ IN MONACLE/TRIANGLE SETTINGS FROM ELSEWHERE?
for   opt,val in pairs({toggle_duration=0,unpause_on_toggle=0,filterchain='lutyuv=negval',fps=30,periods=1,periods_skipped=0,RES_SAFETY=1,geq=255,rotations=0,zoompan=1,negate_enable=0,lut0_enable=0,dimensions={},})
do  o[opt] = o[opt] or val end  --ESTABLISH DEFAULT OPTION VALUES.
for   opt in ('double_mute_timeout unpause_on_toggle periods periods_skipped RES_SAFETY SECTIONS'):gmatch('[^ ]+')  --NUMBERS OR nil.  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON mpv.app (SAME LUA _VERSION, BUILT DIFFERENT).
do  o[opt] = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end  --'1+1'→2  load INVALID ON mpv.app. 
for _,opt in pairs(o.options or {})
do command = ('%s no-osd set %s;'):format(command or '',opt) end
command    = command and mp.command(command)  --ALL SETS IN 1.
function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER.
    D      = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end  --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  FOR RAPID TOGGLE CORRECTIONS.

no_mask                = (o.period or '0')..''=='0' or o.periods==0  --POSSIBLE no_mask BECAUSE NO TIME DEPENDENCE (fpp=1). HOWEVER MAYBE SECTIONS>1
if no_mask then o.fps_mask,o.period,o.periods = nil,1,1 end  --..'' CONVERTS→string.  periods=1.  period>0 CAN BE ANYTHING (fpp=1).
fpp                    = o.fps_mask and loadstring(('return round(%s*%s)'):format(o.fps_mask,o.period))() or 1  --FRAMES_PER_PERIOD=number  loadstring EVALUATES round, AS DEFINED, TO DETERMINE number FROM string.  MAYBE SHOULD BE 1 FOR is1frame IN FUTURE VERSION.
o.fps_mask             =                (  '%s/(%s)'):format(fpp,o.period  )  --SHOULD BE string TO AVOID RECURRING DECIMALS.  DEFAULT 1 FRAME/PERIOD (fpp=1).
o.n                    = o.n or o.t and ('(%s)*(%s)'):format(o.t,o.fps_mask) or no_mask and 0  --CAN DETERMINE n FROM t & VICE VERSA, USING fps_mask.
o.t                    = o.t or o.n and ('(%s)/(%s)'):format(o.n,o.fps_mask)
gsubs                  = {c='cos(2*PI*(n)/%%s)',s='sin(2*PI*(n)/%%s)',m='mod(floor((n)/%%s)\\,2)',p='('..o.period..')'}  --(c),(s),(m),(p) SUBSTITUTIONS.
for      opt in ('scales x y rotations zoompan negate_enable lut0_enable'):gmatch('[^ ]+')  --GEOMETRIC options WHICH NEED TO BE STRINGS & GSUBBED.
do  o   [opt]          = (o[opt] or '')..''  --string CONVERSION.
    for key,gsub in pairs(gsubs)  
    do o[opt]          = o[opt]:gsub('%('..key..'%)',gsub) end  --%s=FRAMES/PERIOD  () ARE MAGIC.  
    o   [opt]          = (o.n and  o[opt]:gsub('%(n%)' ,'('..o.n..')'):gsub('%(t%)' ,'('..o.t..')') or o[opt]):gsub('%%s',fpp) end  --%s=FRAMES/PERIOD  SUB IN SPECIFIC TIME OR FRAME#.  BLINKER SWITCH, INVISIBILITY, ETC.  BUT FIRST CHECK IF SPECIFIC TIME OR FRAME# SHOULD BE SUBSTITUTED
o.zoompan              =  o.zoompan:gsub('%(n%)','(on)')  --(on)=(in)=(n) 
o.zoompan              =  o.n and o.zoompan:gsub('%(in%)','(on)'):gsub('%(on%)','('..o.n..')') or o.zoompan  --on=in=n  IF o.n DEFINED.  (sin AMBIGUOUS WITHOUT (in).)
g                      = {scales='scales',x='x',y='y',crops='crops',rots='rotations',w='',h=''}  --g=GEOMETRY table. CONVERTS STRINGS→LISTS.
for key,opt in pairs(g) 
do g[key]              = {}  --INITIALIZE w,h,x,y,...
   for opt_n in (o[opt] or ''):gmatch('[^ ]+') do table.insert(g[key],opt_n) end end
o.SECTIONS             = o.SECTIONS or #g.scales  --COUNT SECTIONS, IF UNSPECIFIED.
no_mask                = no_mask and o.SECTIONS<=0  --mask MAY STILL BE NEEDED FOR SECTIONS.
if  o.SECTIONS        <= 0 then o.SECTIONS,o.geq,g.scales,g.crops,g.x,g.y,g.rots = 1,255,{'iw:ih'},{},{},{},{} end  --'0' MEANS FULL HEIGHT (OR ELSE IT HALVES).  DEFAULT TO (BLINKING) FULL SCREEN NEGATIVE.  
g.scales[1]            = g.scales[1] or 'iw:ow' --N=1 FULL-SIZE (SQUARE). THE GENERATOR FORMULA OTHERWISE REDUCES FROM CANVAS (THE BIGGER SECTION).  
for     N              = 1,o.SECTIONS 
do  g.scales[N]        = g.scales[N] or ('iw*%d/%d:ow'):format(1+o.SECTIONS-N,2+o.SECTIONS-N)  --EQUAL REDUCTION TO EVERY REMAINING SECTION.  w & h WELL-DEFINED. h=ow FOR CIRLES/SQUARES ON FINAL DISPLAY.
    g.x[N],g.y[N]      = g.x[N] or '',g.y[N] or ''  --x & y WELL-DEFINED.
    for whxy in (N==1 and 'scales x y' or ''):gmatch('[^ ]+') do for WH in ('iw ih W H'):gmatch('[^ ]+') 
        do g[whxy][1]  = g[whxy][1]:gsub(WH,('(%s/%s)'):format(WH,o.RES_SAFETY)) end end  --RES_SAFETY IS JUST A DIMINISHED SCALE IN whxy: W→(W/1.15), ETC. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. x MAY DEPEND ON H, & y ON W, ETC.
    g.x[N],g.y[N]      = g.x[N]..'+(W-w)/2',g.y[N]..'+(H-h)/2' --AUTO-CENTER, OTHERWISE overlay SETS TOP-LEFT (0). THE W,H HERE NEVER GET DIMINISHED BY RES_SAFETY (TRUE CENTER).
    gmatch             = g.scales[N]:gmatch('[^:]+')
    g.w[N],g.h[N]      = gmatch(),gmatch()   --w & h ARE SEPARATED DUE TO THE ROUND-4 overlay BUG.
    mask               = (mask or '%s'):format(''
                             ..(N==1     and 'null' or (',split[%d],scale=floor((%s)/4)*4:floor((%s)/4)*4:eval=frame'):format(N-1,g.w[N],g.h[N])  -- N=1=null.  EACH SECTION (N>1) IS A SCALED NEGATIVE, RELATIVE TO [N-1].  floor MAKES LITTLE SECTIONS LOOK SHARPER, THAN round. USE MULTIPLES OF 4 DUE TO AN overlay BUG, OR ELSE FAILS PRECISION TESTING.  frame SCALING FOR DILATING PUPILS. BUT CLOSING THE EYELIDS MIGHT SHRINK THE PUPILS.
                                 ..(N==2 and ',split,alphamerge' or '')  --N=2 INTRODUCES TRANSPARENCY. 
                                 ..          ',negate'                )  --N>1
                             ..'%s'  --mask GENERATED RECURSIVELY FROM %s. 
                             ..(g.crops[N]   and                      ',crop='..g.crops[N]                 or '') 
                             ..(g.rots [N+1] and g.rots[N+1]~='0' and ',rotate=%s:max(iw\\,ih):ow:BLACK@0' or ''):format(g.rots[N+1])   --N+1 DUE TO DUAL ROTATION.  PADS SQUARE TO AVOID CLIPPING.
                             ..('[%d],[%d][%d]overlay=%s:%s'):format(N,N-1,N,g.x[N],g.y[N])  --crop, rotate & overlay.  
                         ) end 
mask                   = mask:format('')..',format=y8'    --%s='' TERMINATES FORMATTING. REMOVE alpha AFTER FINAL overlay.
                         ..(o.DUAL and ',crop=iw*(1+1/(%s))/2:ow/a:0,split[L],hflip[R],[L][R]hstack' or ''):format(o.RES_SAFETY)  --MAINTAIN ASPECT RATIO a WHEN CROPPING EXCESS OFF RIGHT. SUBTRACT HALF RES_SAFETY FROM RIGHT, & A QUARTER FROM TOP & A QUARTER FROM BOTTOM: w=iw-(iw-iw/RES_SAFETY)/2  FFMPEG COMPUTES string OR ELSE INFINITE RECURRING IN LUA. MAINTAINS aspect BY EQUAL PERCENTAGE crop IN w & h. SOME EXCESS RESOLUTION IS LOST TO MAINTAIN TRUE CENTER. 
o.RES_SAFETY           =    o.DUAL and 1+(o.RES_SAFETY-1)/2 or o.RES_SAFETY  --RES_SAFETY NOW HALVED IF DUAL crop! (IN BOTH X & Y IT'S HALVED TOWARDS 1.)
o.DUAL                 =    o.DUAL and 2 or 1  --DUAL→2 OR 1 (boolean→number).
periods_loop           = math.max(0,o.periods-o.periods_skipped-1) --loop PRIMARY period THIS MUCH.  periods_skipped=periods VALID (DISCARDS PRIMARY loop, EXCEPT FOR LEAD FRAME).
m,p                    = {},{}  --MEMORY & PROPERTIES.
skip_loop,periods_size = fpp*o.periods_skipped,fpp*o.periods  --# OF EXTRA LEAD FRAMES, TOTAL # OF FRAMES.


graph=no_mask and o.filterchain or ( --NULL OVERRIDE FOR SAME-FRAME TOGGLE/FAST LOAD, OR...
      'fps=%s,scale=%%d:%%d,format=%%s,setsar=1,split=3[vo][t0],%s[vf],nullsrc=1x1:%s:0.001,format=y8,lut=0,split[0][1],[0][vo]scale2ref=floor(oh*a*(%%s)/%d/4)*4:floor(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq=%s,loop=%d:1[1],[0]loop=%d:1[0],[1][0]scale2ref=floor((%s)/4)*4:floor((%s)/4)*4:eval=frame[1][0],[1]%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%d:%d,loop=%d:1,rotate=%s:iw*oh/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:d=1:s=%%dx%%d:fps=%s,negate=enable=%s,lut=0:enable=%s,setsar=1,loop=-1:%d,setpts=PTS-%d/FRAME_RATE/TB[m],[t0]trim=end_frame=1,format=y8[t0],[t0][m]concat,trim=start_frame=1,fps=%s,setpts=PTS-(1/FRAME_RATE+%s)/TB,fps=%s,eq=brightness=%%s:eval=frame[m],[vf][m]alphamerge[vf],[vo][vf]overlay=eof_action=endall,format=%%s'
):format(o.fps,o.filterchain,o.fps_mask,o.DUAL,o.RES_MULT or 1,o.geq,fpp-1,fpp-1,g.w[1],g.h[1],mask,o.RES_SAFETY,periods_loop,fpp,skip_loop,g.rots[1] or 0,o.RES_SAFETY,o.zoompan,o.fps_mask,o.negate_enable,o.lut0_enable,periods_size,periods_size,o.fps_mask,o.lead_time or 0,o.fps)  --fps REPEATS FOR STREAM & eq.  fps_mask REPEATS FOR nullsrc, zoompan & AFTER concat.  RES_SAFETY REPEATS FOR mask EXCESS & THEN rotate CROPS IT OFF.  fpp REPEATS FOR [0],[1] INITIALIZATION & periods_loop.  periods_size REPEATS FOR INFINITE loop & FINAL SELECTOR.

----lavfi           = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH  [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [t0]=STARTPTS-FRAME [0]=SEMI-CANVAS  [1][2]...[N] ARE SECTIONS.  SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. (%s) NEEDS BRACKETS FOR MATH. NO audio ALLOWED. RE-USING LABELS IS SIMPLER.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER.  THIS CODE PROPERLY IMPLEMENTS RES_SAFETY, WITH PRECISION.  ALL INSTANCES OF "\\," CAN BE REPLACED USING INVERTED COMMAS.
----fps             = fps:start_time (SECONDS)  DEFAULT=25  IS THE START.  start_time FOR image --start (FREE TIMESTAMP).  CAN LIMIT [vo] TO 30fps.  ALSO ENSURES FRAME_RATE IS WELL-DEFINED.
----zoompan         = z:x:y:d:s:fps     (z>=1)  DEFAULT=1:0:0:...:hd720:25  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN. NEEDS setsar FOR SAFE concat.  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----nullsrc         = s:r:d                     DEFAULT=320x240:25:-1  (size:rate=FPS:duration=SECONDS)  GENERATES 1x1 ATOMIC FRAME. MOST RELIABLE OVER MPV-v0.34→v0.38. A SINGLE ATOM IS CLONED OVER BOTH SPACE & TIME, IN THIS DESIGN.
----scale,scale2ref = w:h                       DEFAULT=iw:ih  [0][vo]→[0][vo] 2REFERENCE SCALES [0] USING DIMENSIONS OF [vo].  PREPARES EACH SECTION FROM THE LAST, & SCALES 2display.  dst_format & flags=bilinear CAN ALSO BE SET.  
----crop            = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  IS FOR EACH SECTION, DUAL-EXCESS & PREPS THE 1x1 ATOM ON WHICH mask IS BASED. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
----rotate          = a:ow:oh:c  (RADIANS:p:p)  DEFAULT=0:iw:ih:BLACK  ROTATES CLOCKWISE, DUAL & EACH SECTION.  CAN ALSO SET bilinear.
----setsar          = sar  SAMPLE ASPECT RATIO  DEFAULT=0  FOR SAFE concat OF [t0] (sar CONGRUENCE).  1 FINALIZES OUTPUT DIMENSIONS. mask TRUE aspect DOESN'T MATCH FILM - THE CIRCLES ARE ONLY CIRCLES IF aspect_none.
----split           = outputs    CLONES VIDEO.  DEFAULT=2  
----setpts          = expr                      DEFAULT=PTS  ZEROES OUT TIME FOR THE CANVAS, & IMPLEMENTS lead_time. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  ALSO SUBTRACTS FIRST TWIRL (CHOPPY LAG).
----lut,lutyuv      = c0,y:u:v         [0,255]  DEFAULT=val  LOOK-UP-TABLE,BRIGHTNESS-UV  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MORE EFFICIENT THAN lutrgb. lut FOR INVISIBILITY SWITCH, & BUGFIX FOR OLD FFMPEG 0<BLACK<16.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----convolution     = 0m:1m:2m:3m:0rdiv:...     DEFAULT=0 0 0 0 1 0 0 0 0:0 0 0 0 1 0 0 0 0:0 0 0 0 1 0 0 0 0:0 0 0 0 1 0 0 0 0:1:...  5x5 & 7x7 ALSO SUPPORTED. FOR SHARPENING [vf].  CAN ALSO SHARPEN COLORS & CHANGE PERCENTAGES USING 0rdiv ETC.
----geq             = lum    GLOBAL EQUALIZER   DEFAULT=lum(X\\,Y)  SLOW EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE.  IN A NON-PERIODIC DESIGN ITS DRAWING/S CAN BE RECYCLED INDEFINITELY.  st,ld = STORE,LOAD  FUNCTIONS MAY IMPROVE PERFORMANCE.  IT CAN ALSO ACT SMOOTHLY ON TINY VIDEO.  
----eq              = ...:brightness:...:eval   DEFAULT=...:0:...:init  RANGES  [-1,1]:{init,frame}  EQUALIZER IS TIME-DEPENDENT CONTROLLER FOR SMOOTH-TOGGLE.  MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD INTERFERE WITH ITS brightness.
----overlay         = x:y:eof_action  →yuva420p DEFAULT=0:0:repeat  SINKS [vf] & EACH SECTION [N].  FFMPEG-v6 BUG: OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING). MAYBE DUE TO COLOR HALF-PLANES (yuva420p).  HOWEVER W,H MAY NOT BE MULTIPLES OF 4.  CAN ALSO 'set end 100%' BUT THAT'S ANOTHER SUB-COMMAND & PERSISTS IN MPV PLAYLIST.  BY DEFAULT MPV LOOPS INDEFINITELY.
----trim            = ...:start_frame:end_frame DEFAULT start_frame=0  TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME.  CAN ALSO END mask.
----loop            = loop:size  ( >=-1 : >0 ) ENABLES INFINITE loop SWITCH ON JPEG. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----format          = pix_fmts                 IS THE FINISH ON [vo]. MAY BE BLANK.  {yuva420p,y8=gray,yuv420p}  overlay FORCES yuva420p, WHILE y8 IS PREFERRED WHENEVER POSSIBLE. ya8 (16-BIT) INCOMPATIBLE WITH rotate & overlay.  [t0] REQUIRES y8 IN FFMPEG-v4, TO shuffleplanes.
----null              PLACEHOLDER, IS THE START FOR BOTH filterchain & mask (LIKE A 0TH SECTION).
----negate            FOR INVERTER SWITCH, & EACH SECTION.
----hflip             PAIRS WITH hstack FOR DUAL.
----hstack            HORIZONTAL DUAL.
----concat            [t0][m]→[m]  SINKS [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek.
----alphamerge        IS THE FINISH ON [vf].  eof_action INVALID ON FFMPEG-v4.  ALSO CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. SIMPLER THAN ALTERNATIVES colorkey shuffleplanes colorchannelmixer.  


function file_loaded() --ALSO @vid, @video-params & @osd-par.
    v,v_params             = mp.get_property_native('current-tracks/video'),mp.get_property_native('video-params')
    if not (v or v_params) or not (v or o.mask_no_vid) then return end  --RAW AUDIO (~w) ENDS HERE, & lavfi-complex MAY NOT NEED mask.
    v,v_params             = v or {},v_params or {}  --WELL-DEFINED type.
    W                      = o.dimensions.w or o.dimensions[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display=WINDOWS & MACOS) OR (LINUX=[vo] DIMENSIONS)  osd-dimensions=WINDOW SIZE, BUT THEN RESIZING THE WINDOW WOULD REPLACE THE WHOLE ANIMATION OR ELSE THE PUPILS WON'T BE PROPER CIRCLES.
    H                      = o.dimensions.h or o.dimensions[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h'] 
    format                 = (not  v.id or v_params.alpha) and 'yuva420p' or 'yuv420p' --FINAL pixelformat.  OLD FFMPEG REQUIRES IT SPECIFIED.  overlay FORCES yuva420p, BUT alpha TRIGGERS BUGS IN VARIOUS SCRIPTS.  
    remove_loop,m.vid      = false,v.id
    lavfi_complex,time_pos = mp.get_opt('lavfi-complex'),round(mp.get_property_number('time-pos'),.001)  --NEAREST MILLISECOND
    loop                   = v.image     and not lavfi_complex and not no_mask
    is1frame               = v.albumart  and not lavfi_complex or      no_mask --albumart & NULL OVERRIDE ARE is1frame RELATIVE TO on_toggle.  MP4TAG & MP3TAG ARE BOTH albumart. SPECIAL & DON'T loop WITHOUT lavfi-complex. CAN COMPARE .JPG TO .MP3. image MAY HAVE VF TIME-STREAM, BUT NOT albumart.
    brightness             = is1frame    and 0 or -1 --FILM STARTS OFF.
    vf_toggle              = is1frame    and OFF     --TOGGLE OFF INSTANTLY.  brightness ON (FOR FURTHER TOGGLING).
    insta_pause            = not p.pause and mp.set_property_bool('pause',true)  --PREVENTS EMBEDDED MPV FROM SNAPPING, & PREVENTS is1frame INTERFERENCE. 
    mp.commandv('vf','append',('@%s:lavfi=[%s]'):format(label,graph):format(W,H,format,par,W,H,brightness,format))  --W,H REPEAT FOR scale & zoompan.  format REPEATS FOR EFFICIENCY.  graph BYTECODE CAN USE DEDICATED commandv.  A FUTURE VERSION COULD INSERT fpp=1 FOR is1frame (SPEED-LOAD).
    
    for _,filter in pairs(mp.get_property_native('vf'))
    do remove_loop = remove_loop or filter.label=='loop' end  --remove @loop, AT CHANGE IN vid. COULD ALSO BE THERE DUE TO OTHER SCRIPTS.
    command        =       ''
        ..(vf_toggle   and 'no-osd vf  toggle @%s;'                               or ''):format(label)
        ..(remove_loop and 'no-osd vf  remove @loop;'                             or '')
        ..(loop        and 'no-osd vf  pre    @loop:lavfi=[loop=-1:1,fps=%s:%s];' or ''):format(o.fps,time_pos)  --ALL MASKS CAN REPLACE @loop.
        ..(insta_pause and        'set pause  no;'                                or '')  --UNPAUSE.
    command = command~='' and mp.command(command) --UNPAUSE &/OR loop.
end
mp.register_event  ('file-loaded'          ,file_loaded) 
mp.observe_property('vid'         ,'number',function(_,vid)  RELOAD = m.vid and vid and m.vid~=vid and file_loaded() end)  --RELOAD IF vid CHANGES. vid→nil IF LOCKED BY lavfi-complex.  UNFORTUNATELY THIS SNAPS EMBEDDED MPV EVERY TIME.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED mask (& HAVE RUNNING audio). 
mp.observe_property('video-params','native',function(     )  RELOAD = not W and                        file_loaded() end)  --DOUBLE-CHECK IF MUST LOAD FOR lavfi-complex.  TRIGGERS ~.1s AFTER file-loaded.
mp.register_event  ('end-file'             ,function(     )       W = nil end)  --W MEANS LOADED.  LOADED SWITCH SHOULD BE CLEARED @end-file.
mp.observe_property('pause'       ,'bool'  ,function(_,val) p.pause = val end)  --ALTERNATIVE TO get_property_bool.

function on_osd_par(_,osd_par)
    par    = o.dimensions.par or o.dimensions[3] or osd_par>0 and osd_par or 1  --OVERRIDE OR osd-par OR 1  ASSUME osd-par=SCREEN PIXEL ASPECT RATIO (THE REAL ASPECT OF EACH PIXEL).  IF THE DISPLAY PIXELS ARE WIDE THEN zoompan SQUISHES THE CIRCLES INTO ELLIPSES, WHICH ARE THEN VIEWED AS CIRCLES. BUT THE CIRCLES COULD SHEAR UNDER ROTATION (IMPERFECT).
    RELOAD = m.par and m.par~=par and file_loaded() --UNTESTED!  AN EXPENSIVE SYSTEM MAY HAVE osd-par~=1.  
    m.par  = par
end
mp.observe_property('osd-par','number',on_osd_par)  --0@file-loaded, 1@playback-restart.

function playback_restart() --GRAPH STATE RESETS, UNLESS is1frame. 
    if W and not is1frame and not OFF then osd_on_toggle,OFF = false,true  --W MEANS LOADED.  FORCE ON, WITHOUT osd.
         osd_on_toggle = on_toggle() or  o.osd_on_toggle end  --RETURN PROPER STATE.
end
mp.register_event('playback-restart',playback_restart)

function on_toggle(mute)  --ALSO @playback-restart
    start_timer     = W and mute and not timers.mute:is_enabled() and (timers.mute:resume() or true)  --W IS LOADED SWITCH.
    if start_timer or not W then return end --NO TOGGLE return CONDITIONS.
    m.brightness    = OFF and -1 or 0       --PRIOR brightness.  IRRELEVANT TO is1frame.
    OFF             = not OFF
    brightness      = OFF and -1 or 0       --TOGGLE:  -1,0 = OFF,ON
    Dbrightness     = brightness-m.brightness  --Δ INVALID ON mpv.app.
    time_pos        = mp.get_property_number('time-pos')+(o.vf_command_t_delay or 0)
    time_pos        = time_pos-(m.time_pos and clip(toggle_duration-(time_pos-m.time_pos),0,toggle_duration) or 0)  --REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  THE MOST ELEGANT FORM IS TO clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.  RAPID TOGGLING USES PRIOR DURATION - IT COULD BE 0 WHEN PAUSED.
    toggle_duration = p.pause              and 0 or o.toggle_duration
    toggle_expr     = toggle_duration==0   and 1 or ('clip((t-%s)/(%s),0,1)'):format(time_pos,toggle_duration)
    toggle_expr     = (o.toggle_expr or '%s'):gsub('%%s',toggle_expr)  --NON-LINEAR clip. 
    target          = target or mp.command(('vf-command %s brightness %d eq'):format(label,brightness)) and 'eq' or ''  --NEW MPV OR OLD. v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  SCALERS DON'T UNDERSTAND brightness.  
    insta_unpause   = p.pause       and not is1frame and o.unpause_on_toggle>0
    return_terminal = insta_unpause and (timers.pause:resume() or true) and mp.get_property_bool('terminal')  --STARTS TIMER.  THIS COULD ALSO DEFINE THE RE-pause COMMAND ITSELF.
    m.time_pos      = time_pos  
    
    mp.command(
        (  is1frame      and 'no-osd vf toggle @%s;' or 'vf-command %s brightness %d+%d*(%s) %s;'):format(label,m.brightness,Dbrightness,toggle_expr,target) --SIMPLE toggle OR ELSE PRIOR BRIGHTNESS + DIFFERENCE.  no_mask & albumart PRESERVE FILTER ORDER (BEFORE PADDING).
        ..(insta_unpause and 'no-osd set terminal no;set pause no;' or '')  --THEN insta_unpause IF NEEDED.
        ..(osd_on_toggle and 'show-text "'
            ..'_VERSION       = %s                   \n'  --Lua 5.1
            ..'mpv-version    = ${mpv-version}       \n'  --mpv 0.38.0
            ..'ffmpeg-version = ${ffmpeg-version}    \n'
            ..'libass-version = ${libass-version}    \n'
            ..'platform       = ${platform}          \n'  --windows
            ..'current-vo     = ${current-vo}        \n'  --gpu direct3d
            ..'osd-par        = ${osd-par}         \n\n'  --1
            ..'lavfi-complex  = \n${lavfi-complex} \n\n'
            ..'Audio filters:   \n${af}            \n\n'
            ..'Video filters:   \n${vf}            \n\n'
            ..'video-out-params=\n${video-out-params}";' or ''
    ):format(_VERSION))
end
for key in (o.key_bindings or ''):gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute','bool',on_toggle)  --SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).

timers    = {  --CARRY OVER IN MPV PLAYLIST.
    mute  = mp.add_periodic_timer(o.double_mute_timeout or 0,function()end), --mute TIMER TIMES.
    pause = mp.add_periodic_timer(o.unpause_on_toggle       ,function()mp.command('set pause yes;'..(return_terminal and 'no-osd set terminal yes;' or ''))end),  --pause TIMER PAUSES, BUT MUST ALSO return_terminal.
}
for _,timer in pairs(timers) do timer.oneshot=true
                                timer:kill() end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----EACH mask REQUIRES EXTRA ~450MB RAM.  CAN PREDICT 296MB=1680*1050*2^2*22*2/1024^2=display*RES_MULT^2*22FRAMES*2periods/1MB  
----A DIFFERENT VERSION COULD FADE OUT 1s NEAR end-file (FINALE).

----BUG: hwdec MAY CAUSE BAD PERFORMANCE OR ELSE BUG OUT. FFMPEG CAN'T CONVERT PROPERLY BTWN FORMATS INSIDE THE GRAPH/S.
----BUG: DILATING SECTIONS NOT WORKING FOR N>1. overlay MIGHT BE TRYING TO COMPUTE COORDS USING init w,W,h,H.  zoompan IS SAFE.

----ALTERNATIVE FILTERS:
----drawtext      = ...:expansion:...:text  COULD WRITE TEXT AS MASK, LIKE ANIMATED CLOCK.
----colorkey      = color:similarity    DEFAULT=BLACK:...      MORE PRECISE THAN alphamerge.
----pad           = w:h:x:y:color       DEFAULT=0:0:0:0:BLACK  CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----select        = expr                DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED A MEMORY LEAK).
----shuffleplanes = map0:map1:map2:map3 DEFAULT=0:1:2:3  WAS THE FINISH ON [m].  REQUIRED FOR COLORS, OR ELSE maskedmerge ONLY AFFECTS BRIGHTNESS.
----lut2          = eof_action  [1][2]→[1]  CAN repeat OR endall ON [m] (INSTEAD OF trim_end).  CAN ALSO GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.
----shuffleplanes   ALTERNATIVE TO alphamerge.
----avgblur         (AVERAGE BLUR)  CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. LOOPED geq IS SUPERIOR.
----maskedmerge     WAS THE FINISH ON [vo].  BUT IT'S TOO DIFFICULT TO USE FOR MASKING COLORED HALF-PLANES (uv)!  (y8→yuva444p, ETC). ALSO DOESN'T SUPPORT eof_action.  HOWEVER DOESN'T NEED MULTIPLES OF 4. 

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

----MONACLE_FAIL_IF_2_DILATING_SECTIONS  , SECTIONS=1,DUAL=nil,scales='oh:ih*(.5+.4*(s)) oh:ih/2',x=nil,y=nil,crops=nil,rotations=nil,zoompan=nil,

