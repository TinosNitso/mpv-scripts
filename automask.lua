----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH INSTANT DOUBLE-mute TOGGLE (m&m FOR MASK). IF PAUSED, INSTA-TOGGLE FRAME-STEPS TOO. COMES WITH 10 MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, ETC. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS CAN ALSO ANIMATE & FILTER SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT (WORKS ON JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME WHERE THE OBJECTS & CHARACTERS ARE LENSES ON TOP OF FILMS, LIKE CHAMELEONS. A GAMING CONSOLE CAN USE VIDEO-IN/OUT TO MASK ON-TOP.
----APPLIES ANY FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE PURELY DECORATIVE. DILATING PUPILS NOT CURRENTLY SUPPORTED. 
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, AVI, 3GP, MP4, WEBM & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG) SUPPORTED. NO FANCY TITLE (drawtext) OR CLOCK IN THIS SCRIPT. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv USE POWER LAW FOR 20% NON-LINEAR SATURATION (IN EXPONENT). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. LINEAR SATURATION (eq) OVER-SATURATES TOO EASILY.

options={  --ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATIVE).      nil & false → DEFAULT VALUES    (BUT ''→true).
    key_bindings         ='F1', --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m FOR MASK. 'F1 F2' FOR 2 KEYS.
    toggle_on_double_mute=.5,   --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. LUA SCRIPTS CAN BE TOGGLED BY DOUBLE mute.
    toggle_fade          =.2,   --SECONDS FOR brightness CHANGE. REMOVE FOR INSTA-TOGGLE.  16 INCREMENTS ARE USED.
    unpause_on_toggle    =.1,   --DEFAULT=.1 SECONDS. PERIOD TO UNPAUSE FOR TOGGLE, LIKE FRAME-STEPPING. A FEW FRAMES ARE ALREADY DRAWN IN ADVANCE.
    -- osd_on_toggle     = 5,   --SECONDS. UNCOMMENT TO INSPECT VERSIONS, FILTERGRAPHS & PARAMETERS. 0 CLEARS THE osd INSTEAD. DISPLAYS mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params
    
    filterchain='null,' --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING). TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).  FOR SHARPEN CAN USE convolution=0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0  (3x3 MATRIX APPLIED TO 4 PLANES.)
              ..'lutyuv=255*((1-val/255)^4*(1+.5*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/1.7-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.01*sin(2*PI*val/minval))'  --+1% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH. FORMS PART OF lutyuv GLOW-LENS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GREYS).
                    ..':128*(1+(val/128-1)/abs(val/128.01-1)^.3)'  --u & v. 128.01 PREVENTS DIVISION BY 0. SOME FUNCTIONS LIKE sgn ONLY EXIST IN FFmpeg-v5+. GREYSCALE IS CENTERED ON 128 NOT 127.5 (128 MEANS 0 IN POPULAR YUV COVERSION FORMULAS). u & v WITH DIFFERENT PERCENTAGES MAYBE MORE OPTIMAL.  lavfi-complex MAY ALSO STRENGTHEN COLORS.
                    ..':128*(1+(val/128-1)/abs(val/128.01-1)^.3)',
    
    fps          =    30 ,  --DEFAULT=30 FRAMES PER SECOND.  @50fps mask IS SMOOTHER THAN FILM.
    period       = 22/30 ,  --DEFAULT= 0 SECONDS. REMOVE FOR LEAD-FRAME ONLY. USE fps RATIO TO MATCH TIME & FRAME#. 20/30=60/90 → 90BPM (BEATS PER MINUTE). SHOULD MATCH OTHER GRAPHS, LIKE lavfi-complex (SYNCED EYES & MOUTH).  UNFORTUNATELY A SLOW ANIMATION IS SLOW TO LOAD (CAN REDUCE RES_MULT). MOST POP IS OVER 100BPM.
    lead_t       ='-1/30',  --DEFAULT=0 SECONDS. +-LEAD TIME OF mask RELATIVE TO OTHER GRAPHS. USE fps RATIO (TRIAL & ERROR).
    periods      =     2 ,  --DEFAULT= 1 (INTEGER). INFINITE loop OVER period*periods.  period=0 OR periods=0 FOR STATIONARY.    
    -- periods_skipped=1 ,  --DEFAULT= 0 (INTEGER). LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS, PER loop. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOESN'T APPLY TO negate_enable & lut0_enable. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY FORMULA.
    SECTIONS     =     6 ,  --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights. MAY LIMIT NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.
    RES_MULT     =     2 ,  --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER seeking (LOAD TIME).  DOESN'T APPLY TO zoompan (TO SPEED UP LOAD). RES_MULTIPLIER=RES_MULT/RES_SAFETY   HD*2 FOR SMOOTH EDGE rotations. AT LEAST .6 FOR SIXTH SECTION.
    RES_SAFETY   =  1.15 ,  --DEFAULT=1 (MINIMUM)  DIMINISHES RES_MULT TO ENSURE FINAL rotation NEVER CLIPS. SAME FOR X & Y.  REDUCE TO 1.1 TO SEE CLIPPING.  +10%+2% FOR iw*1.1 & W/64 (PRIMARY width & x). HOWEVER 1.12 ISN'T ENOUGH (1/.88=1.14?).  HALF EXCESS IS LOST IF DUAL. NEEDED FOR ~DUAL TOO.
    DUAL         =   true,  --REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
    geq          ='255*lt(hypot(X-W/2\\,Y-H/2)\\,W/2)', --DEFAULT=255. REMOVE FOR SQUARES. W=H FOR INITIAL SQUARE CANVAS.  lt,hypot = LESS-THAN,HYPOTENUSE  GRAPHIC EQUALIZER CAN DRAW ANY SECTION SHAPE WITH FORMULA (LIKE ROUNDED RECTANGLES FOR PUPILS). DRAWS [1] FRAME ONLY. SIMPLE SHAPES CAN BE DRAWN USING INTEGERS. DIAMONDS='255*lt(abs(X-W/2)+abs(Y-H/2)\\,W/2)' (SIMPLER THAN ROTATING SQUARES.)  st & ld (W/2) MAY BE MORE EFFICIENT (INTERNAL VARIABLE).  WHAT'S THE FORMULA FOR PENTAGON EYES? 5 GRADIENTS DETERMINED BY atan.
    widths       ='iw*1.1          iw*.6',                 --iw=INPUT-WIDTH  NO (n,t).  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  NO TIME DEPENDENCE FOR THESE 3 LINES, FOR snap COMPATIBILITY. REMOVE THESE 5 LINES TO AUTO-GENERATE SECTIONS. 
    heights      ='ih/2            ih*.5 ih           ih/2           ih/8', --ih=INPUT-HEIGHT  EXACT POSITIONING IS TRIAL & ERROR. PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING, BUT ONLY COVERING OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    x            ='-W/64*(s)       0     W/16*(1+(c)) W/32*(c)       W/64', --(c),(s) = (cos),(sin) WAVES IN TIME=t/period. overlay COORDS FROM CENTER. W IS THE BIGGER PARENT SECTION, & w IS THE SECTION.  (t)=(time) (n)=(frame#) (p)→period (c)→cos(2*PI*(t)/(p)) (s)→sin(2*PI*(t)/(p)) (m)→mod(floor((n)/%s)\\,2) %s→period*fps 
    y            ='-H*((c)/16+1/6) H/16  H/32*(s)     H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD (NEGATIVE MEANS UP).  (c),(s),(m),(p),%s = (cos),(sin),(mod),(period),period*fps
    crops        ='iw:ih*.8:0:ih-oh  iw*.98:ih:0', --DEFAULT NO crop. NO n,t. SPECTACLE-TOP & RED-EYE CROPS, CLEAR MASK'S TOP & MIDDLE. oh=OUTPUT-HEIGHT
    rotations    ='PI/16*(s)*(m)  PI/32*(c)  PI/32*(c)',  --(m)=(mod) 0,1 SWITCH  DEFAULT='0' RADIANS CLOCKWISE. CENTERED ON BIGGER SECTION.  PI/32=.1RADS=6° (QUITE A LOT)  SPECIFIES ROTATION OF EACH SECTION, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.
    zoompan      ='1+.2*(1-cos(2*PI*((on)/%s-.2)))*mod(floor((on)/%s-.2)\\,2):0:0',--%s=period*fps  'zoom:x:y'  on=OUTPUT FRAME NUMBER (OUTPUT MUST SYNC).  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET, HENCE NO (c),(m) ABBREVIATIONS. IT'S LIKE A BASEBALL BAT'S ROTATIVE WIND UP.
    negate_enable='1-between(n/%s\\,.5\\,1.5)',  --DEFAULT='0'. REMOVE FOR NO BLINKING.  n,%s = FRAME#,period*fps    TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). TO START OPPOSITE, USE "1-...". THIS ONE BLINKS NEAR BOTTOM. 
    --lut0_enable='1-between(n/%s\\,.5\\,1.5)',  --DEFAULT='0'. UNCOMMENT FOR INVISIBILITY. %s=period*fps  TIMELINE SWITCH FOR mask.  AN ALTERNATIVE CODE COULD PLACE THIS *BEFORE* THE INVERTER, SO INVISIBILITY ITSELF CAN BE INVERTED.
    
    
    ----10 EXAMPLES: 0) NULL  1) BLINKING MONACLE/SQUARE  2) BINACLES  3) OSCILLATING VISOR  4) BUTTERFLY SWIM  5) DOUBLE-TWIRL & SKIP  6) 10*ZOOMY DISCS  7) ELLIPTICAL VISOR  8) SCANNING VISOR (SIDEWAYS)  9) FALLING VISOR.         UNCOMMENT LINES TO ACTIVATE. USERS CAN ALSO COPY-PASTE PARTS OF THESE.
    -- SECTIONS=0,periods=0, --NULL OVERRIDE. FAST CALIBRATION USING TOGGLE.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y=nil,crops=nil,rotations=nil,zoompan=nil, --UNCOMMENT FOR MONACLE. FOR SQUARE, APPEND "geq=nil,"  SECTIONS>1 FOR CONCENTRIC CIRCLES.
    -- SECTIONS=1,widths='iw',heights=nil,x=nil,y=nil,crops=nil,zoompan=nil,  --BINACLES.  GOOD FOR TESTING automask2.
    -- SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,geq=nil, --VISOR OSCILLATING UP & DOWN.
    -- periods=1,period=4,RES_MULT=1,negate_enable=nil,y='-(H+h)*(n/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/32*cos(2*PI*(t))',zoompan=nil,     --BUTTERFLY SWIMMING UPWARDS EVERY 4 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND. THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- periods=3,periods_skipped=1,negate_enable='gte(n\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',zoompan=nil,    --2 TWIRLS & SKIP: INVERT OUTSIDE WHEN TWIRLING.
    -- SECTIONS=10,negate_enable=nil,widths=nil,heights=nil,x=nil,y=nil,crops=nil,  --CONCENTRIC DISCS. SET geq=nil, FOR SQUARES.
    -- SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil,   --DANCING VISOR: HORIZONTAL ELLIPTICAL.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,RES_MULT=1,negate_enable=nil,widths='iw/3',heights='ih',x='(W+w)*(n/%s-1/2)',y=nil,crops=nil,rotations=nil,geq=nil, --VERTICAL VISOR, SCANNING TIME 4 SECONDS.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,negate_enable=nil,widths='iw',heights='ih/3',x=nil,y='(H+h)*(n/%s-1/2)',crops=nil,rotations=nil,zoompan=nil,geq=nil,--HORIZONTAL VISOR FALLING @4 SECONDS.
    
    
    -- t=5/30, n=5,            --UNCOMMENT FOR STATIONARY SPECTACLES (FREEZE FRAME). SUBSTITUTIONS FOR (t) & (n)=(on)=(in). DOESN'T APPLY TO negate_enable & lut0_enable SWITCHES.
    -- mask_no_vid=true,       --mask ONTOP OF no-vid (ABSTRACT VISUALS). BY DEFAULT NO mask FOR PURE lavfi-complex OR ELSE IT COULD SLOW IT DOWN.
    -- scale ={w=1680,h=1050}, --DEFAULT=display OR [vo]. EVEN NUMBERS ONLY FOR MPV v0.38.0.  scale OVERRIDE MAYBE NEEDED FOR PERFECT CIRCLES ON FINAL display. EXACT MULTIPLES OF 4 MAY IMPROVE PRECISION.
    options  =' '              --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.
           ..'    hwdec=no vd-lavc-threads=0 '  --HARDWARE DECODER (v0.36.0) IS BAD FOR automask, EVEN WITH hwdec=auto-copy & vo=direct3d. FORMATS d3d11 & nv12 ALSO FAIL.  vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER. 
           ..' geometry=50%  osd-font-size=16'  --DEFAULT size 55p MAY NOT FIT automask2 ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER, OR ELSE MAY FAIL INSPECTION.
    ,
}
o         =options  --ABBREV.
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,toggle_fade=0,unpause_on_toggle=.1,filterchain='lutyuv=negval',fps=30,periods=1,lead_t=0,periods_skipped=0,negate_enable='0',lut0_enable='0',geq=255,RES_MULT=1,RES_SAFETY=1,widths='',heights='',x='',y='',crops='',rotations='0',zoompan='1:0:0',scale={},options=''})
do o[opt] =o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options =(o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true 
do    opt =o.options()  
      find=opt  and (opt):find('=')  --RIGOROUS FREE-FORM.
      val =find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
      opt =find and (opt):sub(0,find-1) or opt
      if not (opt and val) then break end
      mp.set_property(opt,val) end  --mp=MEDIA-PLAYER

if not o.period or o.period==0 or o.periods==0 then NULL_OVERRIDE,o.period,o.periods,o.negate_enable,o.lut0_enable = true,1/o.fps,1,'0','0'  --POSSIBLE OVERRIDE BECAUSE NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('[^ ]') do o[nt]=o[nt] or 0 end end --n & t MUST BE WELL-DEFINED FOR NO TIME-DEPENDENCE.

for csm,SUB in pairs({c='cos(2*PI*(n)/%%s)',s='sin(2*PI*(n)/%%s)',m='mod(floor((n)/%%s)\\,2)',p=o.period..''}) do for opt in ('widths heights x y rotations'):gmatch('[^ ]+')  --(c),(s),(m),(p) SUBSTITUTIONS. ''..CONVERTS→string.  widths heights OPTIONAL (FOR eval=frame→DILATING PUPILS).  
    do o[opt]=o[opt]:gsub('%('..csm..'%)',SUB) end end  --%s=FRAMES/PERIOD  () ARE SPECIAL TO gsub.
FP           =o.fps*o.period  --ABBREV. FRAMES PER PERIOD. USES n INSTEAD OF t TO AVOID INFINITE RECURRING DECIMALS.
for opt in ('negate_enable lut0_enable x y rotations zoompan'):gmatch('[^ ]+') 
do     o[opt]=o[opt]:gsub('%%s',FP) end  --%s=FRAMES/PERIOD  BLINKER SWITCH, INVISIBILITY, OVERLAYS, ROTATIONS & zoompan.

for nt in ('n t'):gmatch('[^ ]') do if o[nt] then for opt in ('widths heights x y rotations'):gmatch('[^ ]+')     --SUB IN SPECIFIC TIME OR FRAME#.
        do o[opt]=o[opt]:gsub('%('..nt..'%)','('..o[nt]..')') end end end

o.zoompan=o.n and (o.zoompan):gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') or o.zoompan --on=in=n  IF o.n DEFINED.
g        ={w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} --g=GEOMETRY table. CONVERTS STRINGS→LISTS.
for key,opt in pairs(g) 
do g[key]={} --INITIALIZE w,h,x,y,...
   for o in o[opt]:gmatch('[^ ]+') do table.insert(g[key],o) end end

o.SECTIONS        = o.SECTIONS or math.max(#g.w,#g.h)  --COUNT SECTIONS, IF UNSPECIFIED.
if   o.SECTIONS+0<= 0 then o.SECTIONS,o.geq,g.w,g.h,g.crops,g.x,g.y,g.rots = 1,255,{},{'0'},{},{},{},{}  --+0 CONVERTS→number.  DEFAULT TO (BLINKING) FULL SCREEN NEGATIVE (A BIG RECTANGLE).
else NULL_OVERRIDE= false end  --mask NOT NULL.
mask              = '%s'  --mask AUTO-GENERATED RECURSIVELY FROM %s, BEFORE DUAL. 
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
o.DUAL            = o.DUAL and 2 or 1  --DUAL→2 OR 1 (boolean→number).
o.RES_SAFETY,o.periods_skipped = 1+(o.RES_SAFETY-1)/o.DUAL,math.min(o.periods_skipped,o.periods)  --MAX-SKIP=periods.  RES_SAFETY NOW HALVED IF DUAL crop! (IN BOTH X & Y IT'S HALVED→1.)


lavfi=('fps=%s%%s,scale=%%d:%%d,split=3[vo][t0],%s[vf],nullsrc=1x1:%s:0.001,format=y8,lut=0,split[0][1],[0][vo]scale2ref=floor(oh*a/%d/4)*4:floor(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq=%s[1],[1][0]scale2ref=floor((%s)/4)*4:floor((%s)/4)*4[1][0],[0]loop=%s:1[0],[1]format=yuva420p,loop=%s:1%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%s:%s,loop=%s:1,rotate=%s:iw*oh/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:1:%%dx%%d:%s,negate=enable=%s,lut=0:enable=%s,loop=-1:%d,eq=1:%%s,trim=start_frame=%d[m],[t0]trim=end_frame=1,setpts=PTS-(1/FRAME_RATE+%s)/TB,setsar[t0],[t0][m]concat,trim=start_frame=1%%s[m],[vo][vf][m]maskedmerge')
    :format(o.fps,o.filterchain,o.fps,o.DUAL,o.RES_MULT,o.geq,g.w[1],g.h[1],FP-1,FP-1,mask,o.RES_SAFETY,o.periods-o.periods_skipped-1,FP,FP*o.periods_skipped,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps,o.negate_enable,o.lut0_enable,FP*o.periods,FP*o.periods,o.lead_t)  --RES_SAFETY REPEATS FOR mask EXCESS & THEN rotate CROPS IT OFF.  FP REPEATS FOR [0],[1] INITIALIZATION, periods_skipped & FINAL SELECTOR.  fps REPEATS FOR nullsrc & zoompan. 

----lavfi           = [graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH  [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [t0]=STARTPTS-FRAME [0]=SEMI-CANVAS  [1][2]...[N] ARE SECTIONS.  SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. (%s) NEEDS BRACKETS FOR MATH. NO audio ALLOWED. RE-USING LABELS IS SIMPLER.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER.  THIS EXACT CODE PROPERLY IMPLEMENTS RES_SAFETY, WITH PRECISION. 
----fps             = fps:start_time  FRAMES_PER_SECOND:SECONDS  IS THE START.  :start_time IS ONLY FOR image. SETS STARTPTS FOR --start.  CAN LIMIT [vo] TO 25fps.
----null              PLACEHOLDER
----lut,lutyuv      = c0,y:u:v  DEFAULT=val  LOOK-UP-TABLE,BRIGHTNESS-UV  RANGE [0,255]  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MORE EFFICIENT THAN lutrgb. lut FOR INVISIBILITY SWITCH & TO DROP ROTATIONAL PADDING FROM BELOW 16 TO 0.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----geq             = lum   DEFAULT=lum(X\\,Y)  GLOBAL EQUALIZER IS SLOW, EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE.  EVEN IN A *NON*-PERIODIC DESIGN ITS DRAWING/S CAN BE RECYCLED INDEFINITELY.  st,ld = STORE,LOAD  FUNCTIONS MAY IMPROVE PERFORMANCE.  IT CAN ALSO ACT SMOOTHLY ON 1 PIXEL, OVER TIME.
----crop            = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  IS FOR EACH SECTION, DUAL-EXCESS & PREPS THE 1x1 ATOM ON WHICH mask IS BASED. FFmpeg-v4 REQUIRES ow INSTEAD OF oh.
----rotate          = angle:ow:oh:fillcolor  (RADIANS:PIXELS)  DEFAULT=0:iw:ih:BLACK  ROTATES CLOCKWISE, DUAL & EACH SECTION. USES bilinear INTERPOLATION, NOT BICUBIC, WHICH MIGHT BE WHY RES_MULT IS NEEDED.
----zoompan         = zoom:x:y:d:s:fps  (z>=1) d=1 FRAMES DURATION-OUT PER FRAME-IN. NEEDS setsar FOR SAFE concat.  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----negate            FOR INVERTER SWITCH, & EACH SECTION.
----scale,scale2ref = w:h      DEFAULT=iw:ih  [0][vo]→[0][vo] 2REFERENCE SCALES [0]→[0] USING DIMENSIONS OF [vo]. WILL FAIL PRECISION TESTING WITHOUT MULTIPLES OF 4 (overlay BUG). PREPARES EACH SECTION FROM THE LAST, & SCALES 2display.  THROWS ffmpeg NON-FATAL error IN MPV-LOG on_toggle (REFUSES brightness vf-command).
----nullsrc         = s:r:d  DEFAULT=320x240:25:-1  (size:rate=FPS:duration=SECONDS)  GENERATES RAW 1x1 ATOM, FOR MASK. MOST RELIABLE OVER MPV v0.35.0→v0.38.0
----loop            = loop:size  (LOOPS>=-1:size>0)  ENABLES INFINITE loop SWITCH ON JPEG. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----split           = outputs  DEFAULT=2  CLONES video. mask IS 3-WAY split. 
----alphamerge        CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. SIMPLER THAN ALTERNATIVES colorkey colorchannelmixer shuffleplanes.
----setpts          = expr  ZEROES OUT TIME FOR THE CANVAS, REMOVES THE FIRST TWIRL (NOT SMOOTH) & IMPLEMENTS lead_t (TRIAL & ERROR). SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].
----format          = pix_fmts  [yuva420p y8=gray]  SECTIONAL overlay FORCES yuva420p, WHILE y8 IS PREFERRED WHENEVER POSSIBLE. ya8 (16-BIT) INCOMPATIBLE WITH rotate & overlay.
----hflip             PAIRS WITH hstack FOR DUAL.
----hstack            FOR DUAL.
----eq              = contrast:brightness  DEFAULT=1:0  IS THE CONTROLLER.  RANGES [-2:2]:[-1,1]  EQUALIZER FOR INSTA-TOGGLE. MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD BREAK ITS brightness (INTERFERENCE).
----overlay         = x:y   DEFAULT=0:0  →yuva420p  FINISHES EACH SECTION [N].  BUG: OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING). MAYBE DUE TO COLOR HALF-PLANES.
----setsar                            SAMPLE(PIXEL) ASPECT RATIO. NEEDED FOR SAFE concat.
----concat            [t0][m]→[m]     FINISHES [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. PAIRS WITH scale2ref
----trim            = ...:end:...:start_frame:end_frame  IS THE FINISH ON [m].  TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME, & TO BUILD CANVAS. NO trim2ref. %%s INSERT IS SIMPLER THAN eof_action=endall.
----maskedmerge       IS THE FINISH ON [vo].  REDUCES NET CPU USAGE BY ~3% COMPARED TO overlay (25fps). ALSO DOESN'T NEED MULTIPLES OF 4. DOESN'T SUPPORT eof_action.


lavfi=NULL_OVERRIDE and o.filterchain or lavfi  --NULL_OVERRIDE FOR FAST LOAD.
m,brightness,label = {},0,mp.get_script_name()  --MEMORY FOR vid & brightness. label=automask

function round(N,D)  --N & D MAY BE NUMBERS, STRINGS OR nil. ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). PRECISION LIMITER FOR duration.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function file_loaded() --ALSO @seek, @vid & @on_toggle(is1frame).  
    v=mp.get_property_native('current-tracks/video') or {}  --nil FOR lavfi-complex.
    if not (v.id or o.mask_no_vid) then return         end  --lavfi-complex MAY NOT NEED mask.
    if loop then mp.command( 'no-osd vf remove @loop') end  --remove @loop, AT CHANGE IN vid.
    
    v_params    = mp.get_property_native('video-params') or {}  --nil FOR lavfi-complex.
    W           = o.scale.w or o.scale[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w']  --(scale OVERRIDE) OR (display=WINDOWS & MACOS) OR (LINUX=[vo] DIMENSIONS)  osd-dimensions=WINDOW SIZE, BUT THEN RESIZING THE WINDOW WOULD REPLACE THE WHOLE ANIMATION.
    H           = o.scale.h or o.scale[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h'] 
    W,H         = round(W,2),round(H,2)  --MPV v0.37.0+ HAS ODD BUG.
    lavfi_complex,duration = mp.get_opt('lavfi-complex'),round(mp.get_property_number('duration'),.001)  --NEAREST MILLISECOND. 0 FOR JPEG @playback-restart BUT nil@file-loaded. nil & 0 INTERCHANGE.
    trim_end    = duration and duration>0 and ':end='..duration+.1 or ''  --BY TRIAL & ERROR: +.1
    is1frame    = v.albumart and not lavfi_complex or NULL_OVERRIDE  --NULL_OVERRIDE & albumart ARE is1frame RELATIVE TO on_toggle.  MP4TAG & MP3TAG ARE BOTH albumart. SPECIAL & DON'T loop WITHOUT lavfi-complex. CAN COMPARE .JPG TO .MP3. image MAY HAVE VF TIME-STREAM, BUT NOT albumart.
    loop        = v.image    and not lavfi_complex  --GIF IS ~image. 
    start_time  = loop       and ':'..mp.get_property_number('time-pos') or ''     --JPEG WITH --start OPTION. 
    insta_pause = insta_pause or not pause  --PREVENTS EMBEDDED MPV FROM SNAPPING. →nil @playback-restart.
    m           = {vid=v.id,brightness=brightness}
    
    if is1frame and brightness==-1 then mp.command(('no-osd vf remove @%s'):format(label))  --SPECIAL CASES.
        return end
    if insta_pause then mp.set_property_bool('pause',true) end
    if loop then mp.command( 'no-osd vf pre    @loop:loop=loop=-1:size=1') end  --ALL MASKS CAN REPLACE @loop.
    mp.command(("no-osd vf append '@%s:lavfi=[%s]'"):format(label,lavfi):format(start_time,W,H,W,H,brightness,trim_end))  --W,H FOR scale & zoompan. "''" NEEDED FOR SPACEBARS IN filterchain.
    if insta_pause then mp.set_property_bool('pause',false) end  --& AGAIN @playback-restart FOR WHEN MULTIPLE SCRIPTS SIMULTANEOUSLY insta_pause.
end
mp.register_event('file-loaded',file_loaded) --RELOAD IF brightness CHANGES. EACH REPLACEMENT TRIGGERS ANOTHER seek. 
mp.register_event('seek'       ,function() if m.brightness~=brightness   then file_loaded() end end) --RELOAD IF brightness CHANGES. EACH REPLACEMENT TRIGGERS ANOTHER seek. 
mp.observe_property('vid','number',function(_,vid) if vid and m.vid~=vid then file_loaded() end end) --RELOAD IF vid CHANGES. vid→nil IF LOCKED BY lavfi-complex.  AN MP3, MP2, OGG OR WAV MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WITH DIFFERENT DIMENSIONS, WHICH NEED mask (& HAVE RUNNING audio). 
mp.observe_property('pause','bool',function(_,paused) pause=paused end)  --ALTERNATIVE TO get_property_bool.

function playback_restart()
    if insta_pause then mp.set_property_bool('pause',false) end
    insta_pause                       = nil
    if not target then _,error_string = mp.command(('vf-command %s brightness 0 eq'):format(label))  --NULL-OP AWAITS playback-restart.
                       target         = error_string and '' or                 'eq' end  --OLD MPV OR NEW. v0.37.0+ SUPPORTS TARGETED COMMANDS.
    if m.brightness~=brightness then mp.command(('vf-command %s brightness %d %s'):format(label,brightness,target)) end  --FOR TOGGLE OFF DURING seeking. SMPLAYER DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute.
end 
mp.register_event('playback-restart',playback_restart)

function on_toggle(mute)   
    if not timers.mute then return  --STILL LOADING.
    elseif mute and not timers.mute:is_enabled() then timers.mute:resume() --START timer OR ELSE toggle. 
        return end
    
    brightness,p = -1-brightness,{}     -- 0,-1 = ON,OFF  &  p IS PROPERTIES FOR osd_on_toggle.
    if is1frame  then file_loaded() --NULL_OVERRIDE & albumart.
    elseif pause then mp.command(('vf-command %s brightness %d %s'):format(label,brightness,target))
        mp.set_property_bool('pause',false)  --INSTA-UNPAUSE.  SHOULD CHECK time-remaining>.1s.  COULD ALSO BE MADE SILENT. 
        timers.pause:resume()
    else smooth_toggle() end  --SMOOTH TOGGLE SWITCH.
    if o.osd_on_toggle then for property in ('mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params'):gmatch('[^ ]+')
            do table.insert(p,mp.get_property_osd(property)) end
            mp.osd_message(('mpv-version: %s\nffmpeg-version: %s\nlibass-version: %s\nlavfi-complex: %s\n\nAudio filters: \n%s\n\nVideo filters: \n%s\n\nvideo-out-params: \n%s')  --LISTS CAN HAVE MORE LINES.
                           :format(p[1],p[2],p[3],p[4],p[5],p[6],p[7]),o.osd_on_toggle) end   --.flatpak LUA VERSION DOESN'T SUPPORT table.unpack(p).
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute','bool',on_toggle)

function smooth_toggle()  --A FUTURE VERSION COULD FADE OUT 1 SECOND NEAR end-file.
    count= count and count<16 and count+1 or 1
    if     count== 1 then timers.smooth_toggle:resume() 
    elseif count==16 then timers.smooth_toggle:kill  () end
    mp.command(('vf-command %s brightness %s %s'):format(label,-1-brightness+(brightness-(-1-brightness))*count/16,target))  --OLD MPV THROWS A BUNCH OF FFMPEG ERRORS IN THE LOG. scale DOESN'T UNDERSTAND brightness.
end 

timers={  --CARRY OVER IN MPV PLAYLIST.
    mute         =mp.add_periodic_timer(o.toggle_on_double_mute,function() end), --mute TIMER TIMES. 0s VALID.
    pause        =mp.add_periodic_timer(o.unpause_on_toggle    ,function() mp.set_property_bool('pause',true) end),  --pause TIMER PAUSES.
    smooth_toggle=mp.add_periodic_timer(o.toggle_fade/16       ,smooth_toggle),  --16-BIT.
}
timers.mute .oneshot=true
timers.pause.oneshot=true 
for _,timer in pairs(timers) do timer:kill() end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0 (.7z .exe v3) v0.37.0 (.app) v0.36.0 (.exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED. 
----FFmpeg v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4 v5.1.3(mpv.app)  v5.1.2 (SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS OFTEN BUILT WITH FFmpeg v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----EACH mask REQUIRES EXTRA ~370MB RAM. 310MB=1680*1050*4*22*2/1e6=display*yuva*22FRAMES*2periods/1MB 
----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). CAN GIVE MPV ITS OWN WINDOW OR USE v23.6 (JUNE RELEASE) INSTEAD. SMPLAYER NOW COUPLES seek 0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 

----ALTERNATIVE FILTERS:
----drawtext=...:expansion:...:text  COULD MAKE DANCING CLOCK, BUT NOT WORKING WITH WINDOWS directwrite, WITHOUT SPELLING OUT FULL PATHS TO SYSTEM FONT TYPE FILES.
----colorkey=color:similarity        MORE PRECISE THAN alphamerge.
----shuffleplanes  ALTERNATIVE TO alphamerge.
----streamselect   ALTERNATIVE CONTROLLER TO eq.
----pad     =w:h:x:y:color    CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----avgblur (AVERAGE BLUR)    CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. geq IS BETTER.
----lut2    =eof_action  [1][2]→[1]  CAN repeat OR endall ON [m] (INSTEAD OF trim_end).  CAN ALSO GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.
----select  = expr  DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED MEMORY LEAK WHEN TRIMMING FOR [t0]).

----ALTERNATIVE FILTERCHAINS:
--eq ONLY        filterchain='eq=-.5:0:1.1',  
--2 SINE WAVES   filterchain='lutyuv=minval+.75*(negval-minval)+4*minval*(sin(2*PI*(negval/minval-1)/4)*lt(negval/minval\\,2)+sin(2*PI*(negval-maxval)/minval/4)*lt((maxval-negval)/minval\\,4)),eq=saturation=1.2', 
--ASIN           filterchain='lutyuv=minval+255*asin(negval/maxval)^.5/PI*2,eq=saturation=1.2', 
--ASIN ASIN      filterchain='lutyuv=255*asin(asin(negval/maxval)/PI*2)^.3/PI*2,eq=saturation=1.2', 
--SQRT+SQRT(1-X) filterchain='lutyuv=.8*255*(lt(negval\\,128)*(negval/maxval)^.5+gte(negval\\,128)*(1-negval/maxval)^.5),eq=saturation=1.2', 
--SIGNED POWERS  filterchain='lutyuv=.8*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^abs(1-val/255/.5))),eq=saturation=1.1', 
--X^(1+X^2)      filterchain='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(1+(2*abs(1-val/255/.5))^2)),eq=saturation=1.1', 
--X^(3^(X^2))    filterchain='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^(abs(1-val/255/.5)^2))),eq=saturation=1.1', 
--QUAD-GAUSS     filterchain='lutyuv=.75*(negval-minval)+minval+100/gauss(0)*(1*gauss((255-val)/(255-maxval)/2-1)-.6*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.7-1)+.6*gauss(val/minval/1.7-2)),eq=saturation=1.1',  -- .6=exp(-.5)
--TRIPLE GAUSS   filterchain='lutyuv=.75*(negval-minval)+minval+(64*gauss((255-val)/(255-maxval)/1.7-1)-64*gauss(val/minval/1.5-1)+32*gauss(val/minval/1.5-2))/gauss(0),eq=saturation=1.1',  -- .6=exp(-.5)



