----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH SMOOTH DOUBLE-mute TOGGLE (m&m FOR MASK). COMES WITH A DOZEN MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, SPINNING TRIANGLE, & PENTAGON. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS CAN ALSO ANIMATE & FILTER SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT (WORKS ON JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME LIKE TETRIS, WHERE THE PIECES ARE LENSES. A GAMING CONSOLE COULD USE VIDEO-IN/OUT TO MASK ON-TOP.
----APPLIES FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE DECORATIVE.
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, MP4, WEBM & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG,MP4TAG) SUPPORTED. NO drawtext IN THIS mask. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv ALSO USE POWER LAW FOR 15% NON-LINEAR SATURATION (IN EXPONENT). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. IDEAL LENS ISN'T A TRUE NEGATER.

options                 = {  
    key_bindings        = 'Ctrl+M Ctrl+m M',  --CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER.  m=MUTE.  'ALT+M' COULD BE automask2.lua.  RAPID-TOGGLING MANY MASKS COULD BE LIKE PLAYING AN ORGAN. EACH KEY GETS ITS OWN LUA SCRIPT. BUT THERE COULD BE A SECOND KEYBIND FOR FAST toggle_duration, LIKE A PIANO PEDAL.
    double_mute_timeout =  .5  ,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). 0 IS INACTIVE.  TRIPLE-MUTE DOUBLES BACK.  SCRIPTS CAN BE SIMULTANEOUSLY TOGGLED USING DOUBLE-MUTE.  REQUIRES AUDIO IN SMPLAYER.
    toggle_duration     =  .4  ,  --SECONDS FOR MASK FADE (EQUALIZER). 0 FOR INSTA-TOGGLE.
    unpause_on_toggle   =  .12 ,  --SECONDS TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING.  0 TO DISABLE.  A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE. is1frame IRRELEVANT. 
    vf_command_t_delay  =  .12 ,  --SECONDS.  RAPID TOGGLING HAS ~.1s LAG DUE TO A FEW FRAMES WHICH AREN'T REDRAWN FAST ENOUGH.
    osd_on_toggle       =   0  ,  --MILLISECONDS.  SET TO 5000 TO INSPECT VERSIONS, FILTERGRAPHS, ETC.  0 IS INACTIVE.  1 CLEARS THE OSD.  -1 MEANS INFINITE.  DISPLAYS  _VERSION mpv-version ffmpeg-version libass-version platform current-vo media-title lavfi-complex af vf video-out-params.  HELPS WITH ANDROID.
    filterchain         = 'null,' --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING).   TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).  
    -- ..'convolution=0m=0 -1 0 -1 7 -1 0 -1 0:0rdiv=1/(7-4),'  --UNCOMMENT FOR 33% SHARPEN, USING A 3x3 MATRIX. INCREASE THE 7 & 7 FOR LESS%.  ALTERNATIVELY CAN SHARPEN COLORS ONLY (1m & 2m), INSTEAD OF BRIGHTNESS 0m.
       ..      'lutyuv=y=255*((1-val/255)^4*(1+.6*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/1.7-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.005*sin(2*PI*val/minval))'  --+.5% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH, BUT COULD ALSO CAUSE FACE WRINKLES. FORMS PART OF lutyuv GLOW-LENS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GRAYS).  1*gauss MAY MEAN 1 ROUND.  A SIMPLE NEGATIVE IS JUST negval.  USE (rand) TO RANDOMIZE.
       ..            ':u=128*(1+abs(val/128-1)^.85*clip(val-128\\,-1\\,1))'  --COLORS.  clip IS EQUIVALENT TO sgn, WHICH IS INVALID ON FFMPEG-v4.  LINEAR SATURATION (eq) OVER-SATURATES TOO EASILY.  SATURATING TRUE COLORS TENDS TO REVEAL THEIR PIGMENTS.
       ..            ':v=128*(1+abs(val/128-1)^.85*clip(val-128\\,-1\\,1))', --A DIFFERENT POWER FOR v MAY BE BETTER.  USE (rand) TO RANDOMIZE.
    fps_mask            =     30 , --FRAMES-PER-SECOND - BUT NOT FOR UNDERLYING STREAM.  0 MEANS 1/period (MINIMUM fpp=1).  REDUCE FOR MUCH FASTER LOAD/seek TIMES.  LARGE period MUST USE LESS fps_mask.  0 FOR MONACLE.  60fps UNDERLYING MAY MAKE MASK APPEAR CHOPPY.
    lead_time           = '-1/30', --SECONDS. +-LEAD TIME OF MASK RELATIVE TO OTHER GRAPHS. USE fps_mask RATIO (TRIAL & ERROR).
    period              = '22/30', --SECONDS.  0 FOR STATIONARY.  SHOULD USE fps_mask RATIO.  22/30=60/82 → 82 BPM (BEATS PER MINUTE).  SHOULD MATCH OTHER GRAPHS, LIKE lavfi-complex (SYNCED EYES & MOUTH).  MOST POP IS OVER 100BPM, BUT THIS MASK IS TOO BIG TO KEEP UP (LIKE A SUMO-WRESTLER).
    periods             =      2 , --INTEGER≥0.  INFINITE loop OVER period*periods.  SET period=0 OR periods=0 FOR STATIONARY.    
    periods_skipped     =      0 , --INTEGER≥0.  LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.)  DOESN'T APPLY TO negate_enable & lut0_enable. SIMPLIFIES ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY FORMULA.
    RES_MULT            =      2 , --RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER seeking (LOAD TIME).  DOESN'T APPLY TO FINAL zoompan.  RES_MULTIPLIER=RES_MULT/RES_SAFETY   HD*2 FOR SMOOTH EDGE rotations.  AT LEAST .6 FOR SIXTH SECTION.
    RES_SAFETY          =   1.15 , --≥1.  PREVENTS PRIMARY rotation FROM CLIPPING, BY DIMINISHING RES_MULT. SAME FOR X & Y.  REDUCE TO 1.1 TO SEE CLIPPING.  +10%+2% FOR iw*1.1 & W/64 (PRIMARY width & x). HOWEVER 1.12 ISN'T ENOUGH (1/.88=1.14?).  HALF EXCESS IS LOST IF DUAL. NEEDED FOR ~DUAL TOO.
    SECTIONS            =      6 , --DEFAULT=#scales.  0 FOR BLINKING FULL SCREEN.  LIMITS NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES IF scales ARE MISSING.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    DUAL                =   true , --REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
    gsubs_passes        =      4 , --# OF SUCCESSIVE gsubs.  THEY DEPEND ON EACH OTHER, IN A DAIZY-CHAIN.  (cos)→(c)→(r)→(fpp)  THEY EXIST DUE TO SECTIONAL REPETITION.
    gsubs               = {r='((n)/(fpp))',c='cos(2*PI*(r))',s='sin(2*PI*(r))',m='mod(floor(r)\\,2)',cos='(c)',sin='(s)',mod='(m)',t,n,on,fpp,rand} , --SUBSTITUTIONS.  ENCLOSING BRACKETS () ARE ADDED & REQUIRED, IN EFFECT.  fpp=fps_mask*period=FRAMES-PER-PERIOD IS DERIVED.  EXAMPLE: USE n=5 FOR STATIONARY SPECTACLES (FREEZE FRAME).  (t),(n),(on) = (TIME),(FRAME#),(FRAMEOUT#)  r=TIME/NUMBER-RATIO (t OR n AS RATIO BTWN 0 & periods). COULD BE RENAMED np (#PERIODS), BUT IT'S EQUIVALENT TO TIME.  (rand) IS A RANDOM # BTWN 0 & 1, FOR UNIQUE MASK @file-loaded (FINAL gsub).
    geq=            'lum=255*lt(hypot(X-W/2\\,Y-H/2)\\,W/2)',  --GENERIC-EQUATION=LUMINANCE.  SET 255 FOR SQUARES.  W=H FOR INITIAL SQUARE CANVAS.  lt,hypot = LESS-THAN,HYPOTENUSE   DRAWS [1] FRAME ONLY.  ARGUABLY EACH SECTION SHOULD HAVE ITS OWN geq (ANOTHER LONG string).
    scales              = '                iw*1.1:ih/2       iw*.6:ih*.5 oh:ih         oh:ih/2         oh:ih/8 ',  --iw,ih   = INPUT_WIDTH,INPUT_HEIGHT  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  REMOVE THIS & x & y TO AUTO-GENERATE SECTIONS.  PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING.
    x                   = '                -W/64*(s)         0           W/16*((c)+1)  W/32*(c)        W/64    ',  --(c),(s) = (cos),(sin) WAVES IN FRAME#. overlay COORDS FROM CENTER.                      W,w=BIG,LITTLE SECTIONS.
    y                   = '                -H*((c)/16+1/6)   H/16        H/32*(s)      H/32*((c)+1)/2  H/64    ',  --DEFAULT CENTERS.  DOWNWARD: NEGATIVE MEANS UP.  x & y AREN'T COMBINED DUE TO CENTERING. H,h=BIG,LITTLE SECTIONS.
    crops               = '                iw:ih*.8:0:ih-oh  iw*.98:ih:0   ',  --DEFAULT NO CROPS. NO TIME-DEPENDENCE ALLOWED.  SPECTACLE-TOP & RED-EYE CROPS. CLEARS MASK'S TOP & MIDDLE.  oh=OUTPUT-HEIGHT
    rotations           = ' PI/16*(s)*(m)  PI/32*(c)         PI/32*(c)     ',  --RADIANS CLOCKWISE.  0 FOR NO ROTATIONS.  (m)=(mod) 0,1 SWITCH  PI/32=.1RADS=6° (QUITE A LOT)  SPECIFIES ROTATION OF EACH SECTION, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.  A FUTURE VERSION COULD ALSO FILL THE 0TH LEVEL GAPS, ENABLING DUAL ASYMMETRY.
    zoompan=          'z=1+.2*(1-cos(2*PI*((r)-.2)))*mod(floor((r)-.2)\\,2)',  --USE 1 FOR NO ZOOMING .  (r)=("TIME"-RATIO BTWN 0 & periods).  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET IS LIKE A BASEBALL BAT'S ROTATIVE WIND UP.  REPLACE .2 WITH (rand) TO RANDOMIZE.
    negate_enable       = '1-between((r)\\,.5\\,1.5)',  --INVERTER     SWITCH.   USE 0 FOR NO BLINKING.  r BTWN 0 & periods.  TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). TO START OPPOSITE, USE "1-...". 
    lut0_enable         =                          0 ,  --INVISIBILITY SWITCH.   USE '1-between((r)\\,.5\\,1.5)' FOR INVISIBILITY.  TIMELINE SWITCH.  AN ALTERNATIVE CODE COULD PLACE THIS BEFORE THE INVERTER, SO INVISIBILITY ITSELF IS INVERTED.
    toggle_expr         =          '%s'    ,  --%s=string=LINEAR-IN-TIME-EXPRESSION  DOMAIN & RANGE BOTH [0,1].  FOR CUSTOMIZED TRANSITION BTWN BRIGHTNESSES.
    -- toggle_expr      = 'sin(PI/2*%s)'   ,  --UNCOMMENT FOR NON-LINEAR SINUSOIDAL TRANSITION (QUARTER-WAVE). LINEAR MAY BE SUPERIOR BECAUSE A SINE WAVE IS 57% FASTER @MAX GRADIENT (PI/2=1.57).
    osd_par_multiplier  =  1               ,  --DISPLAY-PAR=osd-par*osd_par_multiplier  osd-par=ON-SCREEN-DISPLAY-PIXEL-ASPECT-RATIO  CAN MEASURE display TO DETERMINE ITS TRUE par.  osd-par NEEDED TO DRAW PERFECT CIRCLES ON ANY WINDOW.  video-out-params/par ACTUALLY MEANS VIDEO-IN-2DISPLAY (par OF ORIGINAL FILM).  
    video_out_params    = {w,h,pixelformat},  --OVERRIDES.  DEFAULT w,h = display-width,display-height  OR  width,height.  EMBEDDED MPV MAY HAVE display-width=nil.  EXAMPLE: {w=1680,h=1050}  USING [vo] SCALE WOULD REQUIRE DELAYED TRIGGER & USE MORE CPU.  DEFAULT pixelformat=yuva420p OR yuv420p, DEPENDING.
    options             = {
        'keepaspect      no','geometry 50%',  --keepaspect=no FOR ANDROID. FREE-SIZE IF MPV HAS ITS OWN WINDOW.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.
        'vd-lavc-threads 0 ','hwdec    no ',  --VIDEO-DECODER-LIBRARY-AUDIO-VIDEO-threads OVERRIDES SMPLAYER OR ELSE MAY FAIL TESTING.  HARDWARE-DECODER BUGS OUT ON ANDROID.
        'osd-font-size   16',  --DEFAULT=55  MAY NOT FIT osd_on_toggle. 
    },
    ----13 EXAMPLES BELOW:  UNCOMMENT A LINE TO ACTIVATE IT.  ALL options CAN BE COMBINED ONTO 1 LINE (WITH TITLE), & COPIED. DON'T FORGET COMMAS!  MONACLE & PENTAGON ARE FAST. SPEED MAY BE AN ISSUE FOR SMARTPHONES.  INCREASE SECTIONS>1 FOR TELESCOPIC. 
    -- NO_MASK       , SECTIONS= 0,period=0,  --NULL OVERRIDE FOR FAST CALIBRATION.  LENS WITHOUT FRAME. TOGGLES STILL-FRAMES.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK.  2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS).  3) BROWN HAMMER & SICKLE.
    -- MONACLE       , SECTIONS= 1,DUAL=false,crops='',x='',y='',zoompan=1,scales='oh:ih'           ,rotations=0,fps_mask=0,RES_SAFETY=1, --INVERTING MONACLE.  geq=255, FOR SQUARE.  SECTIONS>1 FOR CONCENTRIC DISCS.  MONACLE MAY BE THE BEST OVERALL.  
    -- BINACLES      , SECTIONS= 1,           crops='',x='',y='',zoompan=1,scales='iw:ow'           ,
    -- PENTAGON_HOUSE, SECTIONS= 1,DUAL=false,crops='',x='',y='',zoompan=1,scales='oh:ih+2'         ,rotations=0,fps_mask=0,RES_SAFETY=1,RES_MULT=1,geq='255*lt(abs(X-W/2)\\,Y)',  --+2 TO REACH THE BOTTOM/TOP. WIDTH=SCREEN_HEIGHT. TRIANGLE_HEIGHT=HALF_SCREEN.  BOTH THIS & MONACLE CAN BE LOADED SIMULTANEOUSLY (CTRL+M & ALT+M keybinds), & MAY STILL LOAD FASTER THAN ANIMATION.  THE PENTAGON HAS PERFECT LR SYMMETRY, BUT IT MAY NOT APPEAR TO.
    -- SQUARES_SPIN  , SECTIONS= 8,DUAL=false,crops='',x='',y='',zoompan=1,scales='oh:ih/sqrt(2)'   ,rotations='2*PI*n/%s/4' ,geq= 255,  --DIAGONALS GRAZE TOP & BOTTOM OF SCREEN.  COULD ALSO OSCILLATE LEFT & RIGHT.
    -- TRIANGLE_SPIN , SECTIONS= 1,DUAL=false,crops='',x='',y='',zoompan=1,scales='oh:ih'           ,rotations='2*PI*n/%s/3' ,geq='255*lt(Y\\,H*3/4)*lt(abs(X-W/2)\\,Y/sqrt(3))',  --SPINNING EQUILATERAL TRIANGLE, GRAZING TOP & BOTTOM OF SCREEN.  HYPOTENUSE=87% OF HEIGHT (sqrt(3)/2) OF FULLSCREEN DISPLAY.  EQUIVALENT TO ISOSCELES SHRUNK TO 'ih*3/4'.
    -- BUTTERFLY_SWIM, periods = 1,period=3,negate_enable=0,y='-(H+h/2)*(n/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/32*cos(2*PI*(t))',RES_MULT=1,RES_SAFETY=1.3,  --UPWARDS EVERY 3 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND.  THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- TWIRLS2SKIP   , periods = 3,periods_skipped=1            ,zoompan=1,negate_enable='gte(n\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',  --DOUBLE-TWIRL & SKIP 
    -- DISCS_20_ZOOM , SECTIONS=10,           crops='',x='',y='',          scales='',negate_enable=0,  --10*ZOOMY CONCENTRIC DISCS.  geq=255  FOR SQUARES.
    -- VISOR_ELLIPSE , SECTIONS= 1,DUAL=false,crops='',x='',y='-H/8',      scales='iw*2:ih/2',  --DANCING ELLIPTICAL VISOR: HORIZONTAL.
    -- VISOR_VERTICAL, SECTIONS= 1,DUAL=false,crops='',geq=255  ,zoompan=1,scales='iw/4:ih'  ,rotations=0,periods=1,period=2,RES_MULT=.5,negate_enable=0,y='',x='(W+w)*(n/%s-1/2)',  --SCANNING @2 SECONDS SIDEWAYS.
    -- VISOR_HORIZONT, SECTIONS= 1,DUAL=false,crops='',geq=255  ,zoompan=1,scales='iw/1:ih/3',rotations=0,periods=1,period=2,RES_MULT=.5,negate_enable=0,x='',y='(H+h)*(n/%s-1/2)',  --FALLING  @2 SECONDS.  A THIRD TALL, INSTEAD OF A QUARTER.
    -- VISOR_BOUNCE  , SECTIONS= 1,DUAL=false,crops='',geq=255,rotations=0, --OSCILLATING VISOR.
    -- DIAMOND_EYES  , geq='255*lt(abs(X-W/2)+abs(Y-H/2)\\,W/2)',           --AN IMPROVED VERSION COULD GIVE EACH SECTION ITS OWN geq.  SPIKED EYES MAY ALSO BE POSSIBLE.
}
o,m,p,timers = options,{},{},{}      --TABLES.  p=PROPERTIES  m=MEMORY={graph,brightness,osd_par,time_pos}  timers={mute,pause}
require 'mp.options'.read_options(o) --mp=MEDIA-PLAYER  ALL options WELL-DEFINED & COMPULSORY.  

gp,label   = mp.get_property_native,mp.get_script_name()  --automask
for   opt in ('double_mute_timeout unpause_on_toggle fps_mask periods periods_skipped RES_SAFETY SECTIONS gsubs_passes'):gmatch('[^ ]+')  --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
do  o[opt] = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end  --string→number: '1+1'→2  load INVALID ON MPV.APP. 
for _,opt in pairs(o.options)
do command = ('%s no-osd set %s;'):format(command or '',opt) end
command    = command and mp.command(command) --ALL SETS IN 1.

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER.
    D = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
function clip(N,min,max) return N and min and max and math.min(math.max(N,min),max) end  --N,min,max ARE NUMBERS OR nil.  FFMPEG SUPPORTS clip BUT NOT LUA.  math.clip(#,min,max)=math.min(math.max(#,min),max)  FOR RAPID TOGGLE CORRECTIONS.
math.randomseed(mp.get_time())  --UNIQUE EACH LOAD.

no_mask                   = o.period..''=='0' or o.periods==0 --..'' CONVERTS→string.  POSSIBLE no_mask BECAUSE NO TIME DEPENDENCE (fpp=1). HOWEVER MAYBE SECTIONS>1
if no_mask then o.period,o.periods,o.fps_mask = 1,1,0 end     --periods=1.  period>0 CAN BE ANYTHING (fpp=1).
fps_eq,periods_looped     = math.max(25,o.fps_mask),math.max(0,o.periods-o.periods_skipped-1)  --TOGGLE USUALLY NEEDS ≥25fps.  periods_skipped=periods VALID (DISCARDS PRIMARY loop, EXCEPT FOR LEAD FRAME).
fpp                       = o.fps_mask>0 and loadstring(('return round(%s*%s)'):format(o.fps_mask,o.period))() or 1  --FRAMES-PER-PERIOD=number  loadstring EVALUATES round, AS DEFINED, TO DETERMINE number FROM string.  MAYBE SHOULD BE 1 FOR is1frame IN FUTURE VERSION.
frames_skipped,total_size = fpp*o.periods_skipped,fpp*o.periods 
o.fps_mask                = ('%s/(%s)'):format   (fpp,o.period) --number→string TO AVOID RECURRING DECIMALS.  DEFAULT 1 FRAME/PERIOD (fpp=1).
o.gsubs.fpp               = o.gsubs.fpp   or '('..fpp..')'
for   opt in ('filterchain scales x y rotations zoompan negate_enable lut0_enable'):gmatch('[^ ]+') --options WHICH NEED gsubs.  BLINKER SWITCH, INVISIBILITY, ETC.  filterchain (LENS) OPTIONAL. 
do  o[opt]                =   o[opt]..''
    for N                 = 1,o.gsubs_passes do for key,gsub in pairs(o.gsubs)            --gsubs DEPEND ON THE OTHERS.
        do o[opt]         =   o[opt]    :gsub('%('..key..'%)','('..gsub..')') end end end --() ARE MAGIC.
o.zoompan                 =   o.zoompan :gsub('%(n%)'        ,'(on)')                     --(n)→(on) FOR zoompan. SO (c),(s) gsubs ARE EFFECTIVE.
g                         = {scales='scales',x='x',y='y',crops='crops',rots='rotations',w='',h=''}  --g=GEOMETRY table. CONVERTS STRINGS→LISTS.  KEYS HAVE 1 SYLLABLE.  w,h DEDUCED FROM scales - THEY EXIST DUE TO ROUND-4 BUGFIX.
for key,opt in pairs(g) 
do g[key]                 = {}  --INITIALIZE w,h,x,y,...
   for opt_n in (o[opt] or ''):gmatch('[^ ]+') do table.insert(g[key],opt_n) end end
o.SECTIONS                = o.SECTIONS  or #g.scales     --COUNT SECTIONS, IF UNSPECIFIED.
no_mask                   = no_mask    and o.SECTIONS<=0 --mask MAY STILL BE NEEDED FOR SECTIONS.
if  o.SECTIONS           <= 0 then o.SECTIONS,o.geq,g.scales,g.crops,g.x,g.y,g.rots = 1,255,{'iw:ih'},{},{},{},{} end  --DEFAULT TO (BLINKING) FULL SCREEN NEGATIVE.  
g.scales[1]               = g.scales[1] or 'iw:ow'  --N=1 FULL-SIZE (SQUARE). THE GENERATOR FORMULA OTHERWISE REDUCES FROM CANVAS (THE BIGGER SECTION).  
for             N         = 1,o.SECTIONS 
do  g.scales   [N]        = g.scales[N] or ('iw*%d/%d:ow'):format(1+o.SECTIONS-N,2+o.SECTIONS-N)  --EQUAL REDUCTION TO EVERY REMAINING SECTION.  w & h WELL-DEFINED. h=ow FOR CIRLES/SQUARES ON FINAL DISPLAY.
    g.x[N],g.y [N]        = g.x     [N] or '',g.y[N] or ''  --x & y WELL-DEFINED.
    for key in (N==1 and 'scales x y'   or ''):gmatch('[^ ]+') do for WH in ('iw ih W H'):gmatch('[^ ]+') --N=1 ONLY
        do g[key][1]      = g[key][1]:gsub(WH,('(%s/%s)'):format(WH,o.RES_SAFETY)) end end                --RES_SAFETY IS JUST A DIMINISHED SCALE IN whxy: W→(W/1.15), ETC. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. x MAY DEPEND ON H, & y ON W, ETC.
    g.x[N],g.y [N]        = g.x[N]..'+(W-w)/2',g.y[N]..'+(H-h)/2' --AUTO-CENTER, OTHERWISE overlay SETS TOP-LEFT (0). THE W,H HERE NEVER GET DIMINISHED BY RES_SAFETY (TRUE CENTER).
    gmatch                = g.scales[N]:gmatch('[^:]+')
    g.w[N],g.h [N]        = gmatch(),   gmatch()     --w & h ARE SEPARATED DUE TO THE ROUND-4 overlay BUG.
    mask                  = (mask or '%s'):format(   ''
                                ..(N       > 1 and  (',split[%d],scale=floor((%s)/4)*4:floor((%s)/4)*4:eval=frame'):format(N-1,g.w[N],g.h[N])  --EACH SECTION (N>1) IS A SCALED NEGATIVE, RELATIVE TO [N-1].  floor MAKES LITTLE SECTIONS LOOK SHARPER, THAN round. USE MULTIPLES OF 4 DUE TO AN overlay BUG, OR ELSE FAILS PRECISION TESTING.  frame SCALING FOR DILATING PUPILS. BUT CLOSING THE EYELIDS MIGHT SHRINK THE PUPILS.
                                       ..(N==2 and   ',split,alphamerge' or '')  --N=2 INTRODUCES TRANSPARENCY. 
                                       ..            ',negate'                   --N>1 negate.
                                   or 'null')                                    --N=1=null 
                                ..'%s'                                           --mask RECURSIVELY GENERATED FROM %s. 
                                ..(g.crops[N  ] and                      ',crop='..g.crops[N]                 or '') 
                                ..(g.rots [N+1] and g.rots[N+1]~='0' and ',rotate=%s:max(iw\\,ih):ow:BLACK@0' or ''):format(g.rots[N+1])  --N+1 DUE TO DUAL (ZEROTH) ROTATION.  PADS SQUARE TO AVOID CLIPPING.
                                ..('[%d],[%d][%d]overlay=%s:%s'):format(N,N-1,N,g.x[N],g.y[N])  --crop, rotate & overlay.  
                            ) end 
mask                      = mask: format('')..',format=y8'  --%s='' TERMINATES FORMATTING. REMOVE alpha AFTER FINAL overlay.
                            ..(o.DUAL and ',crop=iw*(1+1/(%s))/2:ow/a:0,split[L],hflip[R],[L][R]hstack' or ''):format(o.RES_SAFETY)  --MAINTAIN ASPECT RATIO a WHEN CROPPING EXCESS OFF RIGHT. SUBTRACT HALF RES_SAFETY FROM RIGHT, & A QUARTER FROM TOP & A QUARTER FROM BOTTOM: w=iw-(iw-iw/RES_SAFETY)/2  FFMPEG COMPUTES string OR ELSE INFINITE RECURRING IN LUA. MAINTAINS aspect BY EQUAL PERCENTAGE crop IN w & h. SOME EXCESS RESOLUTION IS LOST TO MAINTAIN TRUE CENTER. 
o.RES_SAFETY              =    o.DUAL and 1+(o.RES_SAFETY-1)/2 or o.RES_SAFETY --RES_SAFETY NOW HALVED IF DUAL crop! (IN BOTH X & Y IT'S HALVED TOWARDS 1.)
o.DUAL                    =    o.DUAL and 2                    or 1            --boolean→number


graph = no_mask and o.filterchain or ( --NULL OVERRIDE FOR SAME-FRAME TOGGLE/FAST LOAD, OR...
    'scale=%%d:%%d,format=%%s,split=3[vo][t0],%s[vf],nullsrc=1x1:%s:0.001,format=y8,lut=0,split[0][1],[0][vo]scale2ref=floor(oh*a*(%%s)/%d/4)*4:floor(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq=%s,loop=%d:1[1],[0]loop=%d:1[0],[1][0]scale2ref=floor((%s)/4)*4:floor((%s)/4)*4:eval=frame[1][0],[1]%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%d:%d,loop=%d:1,rotate=%s:iw*oh/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:d=1:s=%%dx%%d:fps=%s,negate=enable=%s,lut=0:enable=%s,loop=-1:%d,setpts=PTS-%d/FRAME_RATE/TB[m],[t0]trim=end_frame=1,format=y8,setsar[t0],[t0][m]concat,trim=start_frame=1,setpts=PTS-(%s+1/(%s))/TB,fps=%s,eq=brightness=%%s:eval=frame[m],[vf][m]alphamerge[vf],[vo][vf]overlay=eof_action=endall,format=%%s'
):format(o.filterchain,o.fps_mask,o.DUAL,o.RES_MULT,o.geq,fpp-1,fpp-1,g.w[1],g.h[1],mask,o.RES_SAFETY,periods_looped,fpp,frames_skipped,g.rots[1] or 0,o.RES_SAFETY,o.zoompan,o.fps_mask,o.negate_enable,o.lut0_enable,total_size,total_size,o.lead_time,o.fps_mask,fps_eq)  --fps_mask REPEATS FOR nullsrc, zoompan & setpts.  RES_SAFETY REPEATS FOR mask EXCESS & THEN rotate CROPS IT OFF.  fpp REPEATS FOR [0],[1] INITIALIZATION & periods_loop.  total_size REPEATS FOR INFINITE LOOP & FIRST LOOP REMOVAL.

----lavfi           = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH  [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [t0]=STARTPTS-FRAME [0]=SEMI-CANVAS  [1][2]...[N] ARE SECTIONS.  SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. (%s) NEEDS BRACKETS FOR MATH. RE-USING LABELS IS SIMPLER.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER.  "\\,"→"," POSSIBLE USING INVERTED COMMAS.
----fps             = fps:start_time (SECONDS)  DEFAULT=25  IS THE START.  start_time FOR image --start (FREE TIMESTAMP).  ENSURES FRAME_RATE IS WELL-DEFINED FOR setpts.
----zoompan         = z:x:y:d:s:fps     (z>=1)  DEFAULT=1:0:0:...:hd720:25  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN.  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----nullsrc         = s:r:d                     DEFAULT=320x240:25:-1  (size:rate=FPS:duration=SECONDS)  GENERATES 1x1 ATOMIC FRAME. MOST RELIABLE OVER MPV-v0.34→v0.38. A SINGLE ATOM IS CLONED OVER BOTH SPACE & TIME, IN THIS DESIGN.
----scale,scale2ref = w:h                       DEFAULT=iw:ih  [0][vo]→[0][vo] 2REFERENCE SCALES [0] USING DIMENSIONS OF [vo].  PREPARES EACH SECTION FROM THE LAST, & SCALES 2display.  INPUT STREAM width,height CAN BE VARIABLE, SO ABSOLUTE CANVAS IS USED. scale CAN VARY, BUT NOT fps.
----crop            = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  IS FOR EACH SECTION, DUAL-EXCESS & PREPS THE 1x1 ATOM ON WHICH mask IS BASED. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
----rotate          = a:ow:oh:c  (RADIANS:p:p)  DEFAULT=0:iw:ih:BLACK  ROTATES CLOCKWISE, DUAL & EACH SECTION.  CAN ALSO SET bilinear.
----split           = outputs                   DEFAULT=2   CLONES VIDEO.
----setpts          = expr                      DEFAULT=PTS ZEROES OUT TIME FOR THE CANVAS, & IMPLEMENTS lead_time. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  ALSO SUBTRACTS FIRST TWIRL (CHOPPY LAG).
----lut,lutyuv      = c0,y:u:v         [0,255]  DEFAULT=val LOOK-UP-TABLE,BRIGHTNESS-UV  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MORE EFFICIENT THAN lutrgb. lut FOR INVISIBILITY SWITCH, & BUGFIX FOR OLD FFMPEG 0<BLACK<16.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----geq             = lum    (GENERIC EQUATION) DEFAULT=lum(X\\,Y)  SLOW EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE, WHICH CAN THEN BE RECYCLED INDEFINITELY.  st,ld = STORE,LOAD  FUNCTIONS MAY SPEED UP ITS DRAWING.  IT CAN ALSO ACT SMOOTHLY ON TINY VIDEO.  
----eq              = ...:brightness:...:eval   DEFAULT=...:0:...:init  RANGES  [-1,1]:{init,frame}  EQUALIZER IS FINISH ON [m].  TIME-DEPENDENT CONTROLLER FOR SMOOTH-TOGGLE.  MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD INTERFERE WITH ITS brightness.
----overlay         = x:y:eof_action  →yuva420p DEFAULT=0:0:repeat  SINKS [vf] & EACH SECTION [N].  FFMPEG-v6 BUG: OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING). MAYBE DUE TO COLOR HALF-PLANES (yuva420p).  HOWEVER W,H MAY NOT BE MULTIPLES OF 4.  CAN ALSO 'set end 100%' BUT THAT'S ANOTHER SUB-COMMAND & PERSISTS IN MPV PLAYLIST.  BY DEFAULT MPV LOOPS INDEFINITELY.
----trim            = ...:start_frame:end_frame DEFAULT start_frame=0  TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME.  CAN ALSO END MASK.
----convolution     = 0m:1m:2m:3m:0rdiv:...     5x5 & 7x7 ALSO SUPPORTED. FOR SHARPENING [vf].  CAN ALSO SHARPEN COLORS & CHANGE PERCENTAGES USING 0rdiv ETC.
----loop            = loop:size  ( >=-1 : >0 )  ENABLES INFINITE loop SWITCH ON JPEG. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----format          = pix_fmts                  IS THE FINISH ON [vo]. MAY BE BLANK.  {yuva420p,y8=gray,yuv420p}  overlay FORCES yuva420p, WHILE y8 IS PREFERRED WHENEVER POSSIBLE. ya8 (16-BIT) INCOMPATIBLE WITH rotate & overlay.  [t0] REQUIRES y8 IN FFMPEG-v4, TO shuffleplanes.
----setsar            SAMPLE ASPECT RATIO  IS WHAT MPV CALLS par, NOT sar.  FOR SAFE concat OF [t0], ZERO OUT ITS SAR, FOR SAR CONGRUENCE.  MASK TRUE ASPECT DOESN'T MATCH FILM - THE CIRCLES ARE ONLY CIRCLES IF aspect_none.  IT'S SAFER TO NOT MANUALLY FINALIZE [vo] DSIZE.
----null              PLACEHOLDER, IS THE START FOR BOTH filterchain & mask (LIKE A ZEROTH SECTION).
----negate            FOR INVERTER SWITCH, & EACH SECTION.
----hflip             PAIRS WITH hstack FOR DUAL.
----hstack            HORIZONTAL DUAL.
----concat            [t0][m]→[m]  SINKS [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek.
----alphamerge        IS THE FINISH ON [vf].  eof_action INVALID ON FFMPEG-v4.  ALSO CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. SIMPLER THAN ALTERNATIVES colorkey shuffleplanes colorchannelmixer.  maskedmerge IS TOO DIFFICULT TO USE (FAILS COLOR TESTING WITHOUT CAREFUL CODE, WHICH MAY NOT BE EFFICIENT)!


function file_loaded()  --ALSO @property_handler
    for  property in ('width height lavfi-complex'):gmatch('[^ ]+')  --NUMBERS string nil 
    do p[property]   = gp(property) end 
    v                = gp('current-tracks/video') or {}
    if not (v.id or p.width and p.height)  --return CONDITIONS REQUIRE EITHER track OR PARAMATERS.  OTHERWISE COULD SET W,H=2,2 BUT THAT'S MORE COMPLICATED DUE TO RELOAD REQUIREMENTS.  height=nil COULD OCCUR.
    then insta_pause = insta_pause and mp.set_property_bool('pause',nil) and nil  --UNPAUSE FOR AUDIO.
        return end  
    insta_pause      = insta_pause or not p.pause     and mp.set_property_bool('pause',1)     --IMPROVES RELIABILITY & PREVENTS EMBEDDED MPV FROM SNAPPING.
    alpha            = gp('video-params/alpha')       or  v.image                 or  not v.id --MPV REQUIRES EXTRA ~.1s TO DETECT alpha, SO GUESS FOR image & ~v.id.
    W                = o.video_out_params.w           or  gp('display-width' )    or  p.width   or  v['demux-w']  --OVERRIDE  OR  display  OR  PARAMETERS  OR  TRACK.  width=nil SOMETIMES @file-loaded.  FUTURE VERSION SHOULD USE W=osd-width IF FULLSCREEN & display-width=nil & osd-width>width, FOR ANDROID.
    H                = o.video_out_params.h           or  gp('display-height')    or  p.height  or  v['demux-h'] 
    format           = o.video_out_params.pixelformat or  gp('current-vo')=='shm' and 'yuv420p' or alpha and 'yuva420p' or 'yuv420p'  --OVERRIDE  OR  SHARED-MEMORY  OR  TRANSPARENT  OR  NORMAL.  FORCING yuv420p OR yuva420p IS MORE RELIABLE.  SMPLAYER.APP AUTOCONVERTS. MPV.APP COMPATIBLE WITH TRANSPARENCY.  overlay FORCES yuva420p, BUT alpha ON FILM MAY BE BAD FOR OTHER SCRIPTS.
    is1frame         = v.albumart and p['lavfi-complex']=='' or      no_mask  --albumart & NULL OVERRIDE ARE is1frame RELATIVE TO on_toggle.  MP4TAG & MP3TAG ARE BOTH albumart.  DON'T loop WITHOUT lavfi-complex.  FUTURE VERSION MIGHT ALSO INSERT fpp=1 FOR is1frame (SPEED-LOAD).
    loop             = v.image    and p['lavfi-complex']=='' and not no_mask  --ALSO REQUIRED FOR is1frame, FOR graph SIMPLICITY.
    vf_toggle        = is1frame   and OFF     --TOGGLE OFF INSTANTLY.  brightness FOR FURTHER TOGGLING.
    m.brightness     = is1frame   and 0 or -1 --FILM STARTS OFF.  IF STARTING OR seeking PAUSED, IT TAKES A FEW FRAMES FOR THE MASK TO APPEAR.
    m.osd_par        = osd_par
    m.graph          = graph: format(W,H,format,m.osd_par,W,H,m.brightness,format):gsub('%(rand%)','('..math.random()..')') --W,H REPEAT FOR scale & zoompan.  format REPEATS FOR EFFICIENCY.  A DIFFERENT VERSION COULD RE-RANDOMIZE @seek. AN automask CAN BE UNIQUE & VARY MORE EASILY THAN A .GIF.
    mp.commandv('vf','append',('@%s:lavfi=[%s]'):format(label,m.graph))                                                     --commandv FOR graph BYTECODE.  
    
    p['time-pos'],remove_loop = round(gp('time-pos'),.001),nil --start_time, NEAREST MILLISECOND.
    for _,vf in pairs(gp('vf'))            --CHECK FOR @loop.  COULD BE THERE DUE TO OTHER vid OR SCRIPT/S.  FETCH vf LAST.
    do remove_loop = remove_loop    or vf.label=='loop' end 
    command        = ''
                     ..(  vf_toggle and 'no-osd vf  toggle @%s;'                               or ''):format(label)
                     ..(remove_loop and 'no-osd vf  remove @loop;'                             or '')
                     ..(       loop and 'no-osd vf  pre    @loop:lavfi=[loop=-1:1,fps=%s:%s];' or ''):format(fps_eq,p['time-pos']) --ALL MASKS CAN REPLACE @loop. 
                     ..(insta_pause and        'set pause   no;'                               or '')
    command        = ''~=command    and mp.command(command)
    insta_pause    = nil
end
mp.register_event('file-loaded',file_loaded)
mp.register_event( 'start-file',function() insta_pause = not p.pause and mp.command('set pause yes;no-osd vf pre @loop:loop=-1:1;') end)  --INSTA-loop OF LEAD-FRAME IMPROVES RELIABILITY FOR JPEG (HOOKS IN TIMESTAMPS).  video-latency-hacks ALSO RESOLVES THIS ISSUE.
mp.register_event(   'end-file',function() v,W         = nil end)  --CLEAR SWITCHES.
mp.register_event(       'seek',function() on_seek     = loop and not is1frame and mp.command(('no-osd vf pre @loop:lavfi=[loop=-1:1,fps=%s:%s]'):format(fps_eq,round(gp('time-pos'),.001))) end)  --FOR JPEG PRECISE seeking: RESET STARTPTS.  PTS MAY GO NEGATIVE IF RELATIVE!  is1frame UNNECESSARY (OTHERWISE CAUSES INFINITE CYCLE IN VIRTUALBOX).  A FUTURE VERSION MIGHT USE A DIFFERENT TECHNIQUE, LIKE A NULL AUDIO STREAM.

function playback_restart()         --GRAPH STATE RESETS, UNLESS is1frame.
    m.brightness,p.seeking = -1,nil --FOR Dbrightness.  IRRELEVANT IF is1frame.  seeking OBSERVATIONS LAG THIS TRIGGER.
    apply_eq()                      --AFTER seeking.
end 
mp.register_event('playback-restart',playback_restart)      

function on_toggle()  --@key_binding & @property_handler.
    OFF             = not OFF 
    timers.pause:kill()                                                                      --THESE 4 LINES FOR RAPID-TOGGLING WHEN PAUSED.  RESET TIMER FOR NEW PAUSED TOGGLE.
    insta_unpause   = (insta_unpause  or p.pause and o.unpause_on_toggle>0 and not is1frame) --ALREADY insta_unpause OR IF PAUSED, UNLESS is1frame.  COULD ALSO BE MADE SILENT.  COULD ALSO CHECK IF NEAR end-file (NOT ENOUGH TIME).  
                      and (timers.pause:resume() or 1)                                         
    return_terminal = return_terminal or p.terminal  --terminal-GAP REQUIRED BY SMPLAYER-v24.5 OR ELSE IT GLITCHES.  MPV MAKES TOGGLING MASK AS QUICK AS TOUCH-TYPING. KEEP TAPPING M IN SMPLAYER, AS FAST AS POSSIBLE.
    command         = ''
                      ..(is1frame           and 'no-osd vf  toggle   @%s;' or (apply_eq() or 1) and ''):format(label)  --no_mask & albumart  OVERRIDE  OR ELSE NORMAL.  PRESERVES FILTER ORDER (BEFORE PADDING).  HOWEVER vf toggle SNAPS EMBEDDED MPV.
                      ..(insta_unpause      and 'no-osd set terminal no;set pause no;'          or  '')  
                      ..(o.osd_on_toggle~=0 and 'show-text                       "'
                          ..'_VERSION       = %s                                \n'  --Lua 5.1  5.2
                          ..'mpv-version    = ${mpv-version}                    \n'  --mpv 0.38.0  →  0.34.0
                          ..'ffmpeg-version = ${ffmpeg-version}                 \n'
                          ..'libass-version = ${libass-version}                 \n'
                          ..'media-title    = ${media-title}                  \n\n' 
                          ..'platform       = ${platform}                       \n'  --windows  linux  darwin     android     nil
                          ..'current-ao,current-vo = ${current-ao},${current-vo}\n'  --wasapi   pulse  coreaudio  audiotrack  nil  ,  gpu  gpu-next  direct3d  libmpv  shm
                          ..'lavfi-complex  = \n${lavfi-complex}              \n\n'
                          ..'Audio filters:   \n${af}                         \n\n'
                          ..'Video filters:   \n${vf}                         \n\n'
                          ..'video-out-params = \n${video-out-params}"         %d;' or ''
                      ):format(_VERSION,o.osd_on_toggle)
    command         = command~='' and mp.command(command) 
end
for key in o.key_bindings: gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_mask_'..key,on_toggle) end
timers.pause = mp.add_periodic_timer(o.unpause_on_toggle,function() insta_unpause,return_terminal = mp.command('set pause yes;'..(return_terminal and 'no-osd set terminal yes' or '')) and nil end)  --pause TIMER PAUSES, BUT MUST ALSO return_terminal.

function apply_eq(brightness)  --@on_toggle &  @playback-restart.  UTILITY SEPARATE FROM ITS TOGGLE. EQUALIZER ACTUALLY REQUIRES ITS OWN fps.
    p['time-pos']   = gp('time-pos') 
    brightness      = brightness or OFF and -1 or 0  --0,-1 = ON,OFF
    Dbrightness     = brightness-m.brightness                                                                      --Δ INVALID ON MPV.APP.
    if Dbrightness == 0 or is1frame or not (p['video-params'] and p['time-pos']) or p.seeking then return end      --return CONDITIONS.  Dbrightness PREVENTS EXCESSIVE vf-command (LAG).  is1frame USES GRAPH REPLACEMENT.  video-params REQUIRED FOR target ACQUISITION (PERMANENT OP).  time-pos=nil AFTER end-file, @playback-restart.  seeking INVALID.  
    time_pos        = p['time-pos'] + o.vf_command_t_delay                                                         --BUG: BACKWARDS-seek NEEDS MUCH LARGER vf_command_t_delay (.5s).  revert-seek TOO SLOW, BUT CAN RUN TIMER WHO CHECKS time-pos EVERY FEW SECONDS. 
    time_pos        = time_pos-(m.time_pos and clip(toggle_duration-(time_pos-m.time_pos),0,toggle_duration) or 0) --REMAINING_DURATION_OF_PRIOR_TOGGLE=LAST_DURATION-TIME_SINCE_LAST_TOGGLE  (SUBTRACT REMAINING_DURATION).  CAN clip THE TIME DIFFERENCE TO BTWN 0 & DURATION.  RAPID TOGGLING USES PRIOR DURATION - IT COULD BE 0 WHEN PAUSED.
    toggle_duration = insta_unpause  and 0 or o.toggle_duration 
    toggle_expr     = toggle_duration==0 and 1 or ('clip((t-%s)/(%s),0,1)'):format(time_pos,toggle_duration)
    toggle_expr     = o.toggle_expr: gsub('%%s',toggle_expr)  --NON-LINEAR clip. 
    target          = target or mp.command(('vf-command %s brightness %d eq'):format(label,m.brightness)) and 'eq' or ''  --NEW MPV OR OLD. v0.37.0+ SUPPORTS TARGETED COMMANDS.  command RETURNS true IF SUCCESSFUL. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THOSE CAN BE ANYTHING.  SCALERS DON'T UNDERSTAND brightness.  
    
    mp.command(('vf-command %s brightness %d+%d*(%s) %s'):format(label,m.brightness,Dbrightness,toggle_expr,target))  --PRIOR BRIGHTNESS + DIFFERENCE. 
    m.brightness,m.time_pos = brightness,time_pos  
end

function property_handler(property,val)
    p[property] =       val
    osd_par     =       property=='osd-par'                         and (val>0 and val or 1)*o.osd_par_multiplier or osd_par  --0,1 = AUTO,SQUARE  0@load-script, 0@file-loaded, & 1@playback-restart. MAYBE ~1 ON EXPENSIVE SYSTEM.  THEN zoompan SQUISHES THE CIRCLES INTO ELLIPSES, WHICH ARE THEN VIEWED AS PERFECT CIRCLES.
    double_mute =      (property=='mute' or property=='current-ao') and W      and (not timers.mute:is_enabled() and (timers.mute:resume() or 1) or on_toggle())  --current-ao=audiotrack/nil FOR ANDROID.  W STOPS FLIPPING ON RAW AUDIO (OPTIONAL).  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).  current-tracks/audio/selected & current-ao BOTH DO THE SAME THING, BUT current-ao DOESN'T FLIP @playlist-next.
    reload      = v and (nil    --5 CONDITIONS: @NEW-vo, @is1frame, @alpha, @image & @osd_par.
                    or  property=='video-params'                    and val    and (not W or is1frame or val.alpha and not alpha)  --NEW vo, OR Δalbumart, OR TRY SWITCH TO TRANSPARENCY.  is1frame MUST BE RE-DRAWN.  TRANSPARENCY TAKES TIME TO DETECT. DELAYED TRIGGER BAD!  SWITCHING BACK TO yuv420p UNNECESSARY.
                    or  property=='current-tracks/video/image'      and val    ~=v.image         --RELOAD IF SWITCHING BTWN MP4 & MP4TAG.  UNFORTUNATELY EMBEDDED MPV SNAPS.  albumart DISTINCTION IS IRRELEVANT. vid ALSO IRRELEVANT.
                    or  property=='osd-par'                         and osd_par~=m.osd_par and W --UNTESTED.
                  ) and file_loaded()
end 
for property in ('current-tracks/video/image mute seeking pause terminal osd-par current-ao video-params'):gmatch('[^ ]+')  --BOOLEANS number string table nil
do mp.observe_property(property,'native',property_handler) end

timers.mute         = mp.add_periodic_timer(o.double_mute_timeout,function()end)  --mute TIMER TIMES.
for _,timer in pairs(timers) 
do    timer.oneshot = 1  --ALL 1SHOT.
      timer:kill() end


----~300 LINES & ~7000 WORDS.  SPACE-COMMAS FOR SMARTPHONE.  
----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB.  CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----PLATFORMS  windows linux darwin(Lua 5.1) android(Lua 5.2) ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-7-x86. 
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----BUG: PERFECT CIRCLES AREN'T WORKING IN ANDROID, WITHOUT o.video_out_params. A FUTURE VERSION SHOULD USE osd-width,osd-height OR android-surface-size. BUT THIS COULD CAUSE STUTTERED RELOAD.
----FUTURE VERSION MAY HAVE IMPROVED ANDROID MECHANISM (SCREEN DOUBLE-TAP).
----FUTURE VERSION MAY HAVE MONACLE FOR ANDROID, BY DEFAULT (o.android).

----SCRIPT WRITTEN TO TRIGGER AN INPUT ERROR ON OLD MPV (<=0.36). MORE RELIABLE THAN VERSION NUMBERS. 
----EACH mask REQUIRES EXTRA ~450MB RAM.  CAN PREDICT 296MB=1680*1050*2^2*22*2/1024^2=display*RES_MULT^2*22FRAMES*2periods/1MB  
----A DIFFERENT VERSION COULD FADE OUT 1s NEAR end-file (FINALE).

----ALTERNATIVE FILTERS:
----drawtext      = ...:expansion:...:text  COULD WRITE TEXT AS MASK, LIKE ANIMATED CLOCK.
----colorkey      = color:similarity    DEFAULT=BLACK:...      MORE PRECISE THAN alphamerge.
----pad           = w:h:x:y:color       DEFAULT=0:0:0:0:BLACK  CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----select        = expr                DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED A MEMORY LEAK).
----shuffleplanes = map0:map1:map2:map3 DEFAULT=0:1:2:3  WAS THE FINISH ON [m].  REQUIRED FOR COLORS, OR ELSE maskedmerge ONLY AFFECTS BRIGHTNESS.
----lut2          = eof_action  [1][2]→[1]  CAN repeat OR endall ON [m] (INSTEAD OF trim_end).  CAN ALSO GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.
----shuffleplanes   ALTERNATIVE TO alphamerge.
----avgblur         (AVERAGE BLUR)  CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. LOOPED geq IS SUPERIOR.
----maskedmerge     [vo][vf][m]→[vo]  WAS THE FINISH.  BUT IT'S TOO DIFFICULT TO USE ON COLORED HALF-PLANES uv!  (y8→yuva444p, ETC). IT FAILS WITHOUT MORE FILTERS WHICH MAY NOT BE EFFICIENT.  ALSO DOESN'T SUPPORT eof_action.  HOWEVER DOESN'T NEED MULTIPLES OF 4. 

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

----BUG: DILATING SECTIONS NOT WORKING FOR N>1. overlay MIGHT BE TRYING TO COMPUTE COORDS USING init w,W,h,H.  zoompan IS SAFE.
----EXAMPLE, SECTIONS=1,DUAL=false,scales='oh:ih*(.5+.4*(s)) oh:ih/2',x='',y='',crops='',rotations='',zoompan='',

