----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH INSTANT DOUBLE-mute TOGGLE (m&m FOR MASK). IF PAUSED, INSTA-TOGGLE FRAME-STEPS TOO. COMES WITH 10 MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, ETC. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS ALSO ANIMATE SIMULTANEOUSLY BY RENAMING A COPY OF THE SCRIPT automask2.lua (WORKS WITH JPEG TOO). GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD. A DIFFERENT FORM OF MASK IS A GAME WHERE THE OBJECTS & CHARACTERS ARE LENSES ON TOP OF FILMS.
----APPLIES ANY FFMPEG FILTERCHAIN TO MASKED REGION, WITH INVERSION & INVISIBILITY. MASK MAY HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE PURELY DECORATIVE. DILATING PUPILS NOT CURRENTLY SUPPORTED - COULD BREAK LINUX snap COMPATIBILITY. 
----WORKS WELL WITH JPG, PNG, BMP, GIF, MP3 albumart, MP4, WEBM, AVI & YOUTUBE IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT lavfi-complex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP OR PDF. LOAD TIME SLOW (LACK OF BACKGROUND BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG) SUPPORTED. NO FANCY TITLE (drawtext) OR CLOCK IN THIS SCRIPT. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS uv USE POWER LAW FOR 20% NON-LINEAR SATURATION (IN EXPONENT). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER.  gauss SIZES ARE APPROX minval*1.5, SHIFTED 1x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. 

o={ --options  ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATIVE).      nil & false → DEFAULT VALUES    (BUT ''→true).
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED BY DOUBLE mute.
    key_bindings         ='F2',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m FOR MASK. 'F2 F3' FOR 2 KEYS. F1 MAY BE autocomplex (SLOW toggle).
    -- osd_on_toggle='Audio filters:\n%s\n\nVideo filters:\n%s\n\nlavfi-complex:\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICK MUTE FOR FINAL CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
    frame_steps_if_paused=3,   --DEFAULT=3, on_toggle. A FEW FRAMES ALREADY DRAWN IN ADVANCE. 
    
    filterchain='null,' --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING). TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).
              ..'lutyuv=255*((1-val/255)^4*(1+.5*.15)+.15*(2.5*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.5-1))/gauss(0)+.01*sin(2*PI*val/minval))'  --+1% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH. FORMS PART OF lutyuv GLOW-LENS.  15% DROP ON WHITE-IS-WHITE (TOO MUCH MIXES GREYS).
                    ..':128*(1+(val/128-1)/max(1\\,abs(val/128-1))^.2)'  --u & v. max PREVENTS /0. GREYSCALE IS CENTERED ON 128 NOT 127.5 (128 MEANS 0 IN POPULAR YUV COVERSION FORMULAS).   autocomplex.lua MAY ALSO STRENGTHEN COLORS (BUG).
                    ..':128*(1+(val/128-1)/max(1\\,abs(val/128-1))^.2)',
    
    fps    =   30, --DEFAULT=30 FRAMES PER SECOND.  @50fps mask IS SMOOTHER THAN FILM.
    period =22/30, --DEFAULT=0 SECONDS (LEAD-FRAME ONLY). USE EXACT fps RATIO TO MATCH t & in. 22/30→82BPM (BEATS PER MINUTE). SHOULD MATCH OTHER GRAPHS, LIKE lavfi-complex (SYNCED EYES & MOUTH).  UNFORTUNATELY A SLOW ANIMATION IS SLOW TO LOAD (CAN REDUCE RES_MULT).
    periods=    2, --DEFAULT=1, INTEGER. INFINITE loop OVER period*periods.  0 period OR periods FOR STATIC.    
    
    negate_enable='1-between(n/%s\\,.5\\,1.5)',  --DEFAULT='0'. REMOVE FOR NO BLINKING.  n,%s = FRAME#,period*fps    TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). TO START OPPOSITE, USE "1-...". THIS ONE BLINKS NEAR BOTTOM.
    -- lut0_enable='1-between(n/%s\\,.5\\,1.5)', --DEFAULT='0'. UNCOMMENT FOR INVISIBILITY. %s=period*fps  TIMELINE SWITCH FOR mask.     AN ALTERNATIVE CODE COULD PLACE THIS *BEFORE* THE INVERTER, SO INVISIBILITY ITSELF CAN BE INVERTED.
    geq='255*lt((X-W/2)^2+(Y-H/2)^2\\,(W/2)^2)', --DEFAULT=255. REMOVE FOR SQUARES. W=H FOR INITIAL SQUARE CANVAS. CAN DRAW ANY SECTION SHAPE WITH FORMULA (LIKE ROUNDED RECTANGLES FOR PUPILS). DRAWS [1] FRAME ONLY. SIMPLE SHAPES CAN BE DRAWN USING INTEGERS. DIAMONDS='255*lt(abs(X-W/2)+abs(Y-H/2)\\,W/2)' (SIMPLER THAN ROTATING SQUARES.)
    
    SECTIONS=6,   --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights. MAY LIMIT NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.
    DUAL    =true,--REMOVE FOR ONE SERIES OF SECTIONS, ONLY.  true ENABLES hstack WITH LEFT→RIGHT hflip, & HALVES INITIAL iw (display CANVAS).
        
    widths ='iw*1.1  iw*.6',                 --iw=INPUT-WIDTH  NO (n,t).  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)  NO TIME DEPENDENCE FOR THESE 3 LINES, FOR snap COMPATIBILITY. REMOVE THESE 5 LINES TO AUTO-GENERATE SECTIONS. 
    heights='ih/2    ih*.5  ih  ih/2  ih/8', --ih=INPUT-HEIGHT  EXACT POSITIONING IS TRIAL & ERROR. PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING, BUT ONLY COVERING OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    crops  ='iw:ih*.8:0:ih-oh  iw*.98:ih:0', --DEFAULT NO crop. NO n,t. SPECTACLE-TOP & RED-EYE CROPS, CLEAR MASK'S TOP & MIDDLE. oh=OUTPUT-HEIGHT
    
    x        ='-W/64*(s)       0     W/16*(1+(c)) W/32*(c)       W/64', --(c),(s) = (cos),(sin) WAVES IN TIME=t/period. overlay COORDS FROM CENTER. W IS THE BIGGER PARENT SECTION, & w IS THE SECTION.  (t)=(time) (n)=(frame#) (p)→period (c)→cos(2*PI*(t)/(p)) (s)→sin(2*PI*(t)/(p)) (m)→mod(floor((n)/%s)\\,2) %s→period*fps 
    y        ='-H*((c)/16+1/6) H/16  H/32*(s)     H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD (NEGATIVE MEANS UP).  (c),(s),(m),(p),%s = (cos),(sin),(mod),(period),period*fps
    rotations='PI/16*(s)*(m)  PI/32*(c)  PI/32*(c)',  --(m)=(mod) 0,1 SWITCH  DEFAULT='0' RADIANS CLOCKWISE. CENTERED ON BIGGER SECTION.  PI/32=.1RADS=6° (QUITE A LOT)  SPECIFIES ROTATION OF EACH SECTION, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.
    zoompan  ='1+.2*(1-cos(2*PI*((on)/%s-.2)))*mod(floor((on)/%s-.2)\\,2):0:0',--%s=period*fps  (zoom:x:y)  in,on = INPUT,OUTPUT NUMBERS. on MUST SYNC.  20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET, HENCE NO (c),(m) ABBREVIATIONS. IT'S LIKE A BASEBALL BAT'S ROTATIVE WIND UP.
    
    RES_MULT  =   2, --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER LOAD. DOESN'T APPLY TO zoompan (TO SPEED UP LOAD). RES_MULTIPLIER=RES_MULT/RES_SAFETY   HD*2 FOR SMOOTH EDGE rotations. AT LEAST .6 FOR SIXTH SECTION.
    RES_SAFETY=1.15, --DEFAULT=1 (MINIMUM)  DIMINISHES RES_MULT TO ENSURE DUAL ROTATION NEVER CLIPS. SAME FOR X & Y. +10%+2% FOR iw*1.1 & W/64 (PRIMARY width & x). HOWEVER 1.12 ISN'T STRICTLY ENOUGH. REDUCE TO 1.1 TO SEE CLIPPING.  
    
    lead_t='-1/30',      --DEFAULT=0 SECONDS. TRIAL & ERROR. +-LEAD TIME OF MASK RELATIVE TO OTHER GRAPHS.
    -- t=5/30, n=5,      --UNCOMMENT FOR STATIONARY SPECTACLES (FREEZE FRAME). SUBSTITUTIONS FOR (t) & (n)=(on)=(in). DOESN'T APPLY TO negate_enable & lut0_enable SWITCHES.
    -- periods_skipped=1,--DEFAULT=0, INTEGER. LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS, PER loop. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOESN'T APPLY TO negate_enable & lut0_enable. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY FORMULA.
    
    ----10 EXAMPLES: 0) NULL  1) BLINKING MONACLE/SQUARE  2) BINACLES  3) OSCILLATING VISOR  4) BUTTERFLY SWIM  5) DOUBLE-TWIRL & SKIP  6) 10*ZOOMY DISCS  7) ELLIPTICAL VISOR  8) SCANNING VISOR (SIDEWAYS)  9) FALLING VISOR.         UNCOMMENT LINES TO ACTIVATE. USERS CAN ALSO COPY-PASTE PARTS OF THESE.
    -- SECTIONS=0,periods=0, --NULL OVERRIDE. FAST CALIBRATION USING TOGGLE.  CAN CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y=nil,crops=nil,rotations=nil, --UNCOMMENT FOR MONACLE (ROTATING). FOR SQUARE, APPEND "geq=nil,"  SECTIONS>1 FOR CONCENTRIC CIRCLES.
    -- zoompan=nil,SECTIONS=1,widths='iw',heights=nil,x=nil,y=nil,crops=nil,  --BINACLES.
    -- SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,geq=nil, --VISOR OSCILLATING UP & DOWN.
    -- zoompan=nil,periods=1,period=4,RES_MULT=1,negate_enable=nil,y='-(H+h)*(n/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/32*cos(2*PI*(t))',     --BUTTERFLY SWIMMING UPWARDS EVERY 4 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND. THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). 
    -- zoompan=nil,periods=3,periods_skipped=1,negate_enable='gte(n\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',    --2 TWIRLS & SKIP: INVERT OUTSIDE WHEN TWIRLING.
    -- SECTIONS=10,negate_enable=nil,widths=nil,heights=nil,x=nil,y=nil,crops=nil,  --CONCENTRIC DISCS. SET geq=nil, FOR SQUARES.
    -- SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil,   --DANCING VISOR: HORIZONTAL ELLIPSE. rotations WORK WELL WITH CURVES.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,RES_MULT=1,negate_enable=nil,widths='iw/3',heights='ih',x='(W+w)*(n/%s-1/2)',y=nil,crops=nil,rotations=nil,geq=nil, --VERTICAL VISOR, SCANNING TIME 4 SECONDS.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,periods=1,period=4,negate_enable=nil,widths='iw',heights='ih/3',x=nil,y='(H+h)*(n/%s-1/2)',crops=nil,rotations=nil,geq=nil,--HORIZONTAL VISOR FALLING @4 SECONDS.
    
    -- scale={1680,1050},--NEEDED IN LINUX (VIRTUALBOX) FOR PERFECT CIRCLES ON FINAL display. DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX).
    format ='yuv420p',   --DEFAULT=yuv420p  NEEDED FOR CORRECT OUTPUT TO [gpu] IN MPV LOG. 420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    options=''           --'opt1 val1 opt2 val2 '... FREE FORM.  main.lua HAS io_write (NECESSARY) & FURTHER options.
        ..' vd-lavc-threads 0  geometry 50%  osd-font-size 16  ' --DEFAULT size 55p MAY NOT FIT automask2 ON osd.  geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER, OR ELSE MAY FAIL INSPECTION.
}
for opt,val in pairs({toggle_on_double_mute=0,key_bindings='',frame_steps_if_paused=3,filterchain='lutyuv=negval',fps=30,periods=1,negate_enable='0',lut0_enable='0',geq=255,x='0',y='0',rotations='0',zoompan='1:0:0',RES_MULT=1,RES_SAFETY=1,lead_t=0,periods_skipped=0,scale={},format ='yuv420p',options=''})
do o[opt]=o[opt] or val end  --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('[^ ]+') --GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) DIDN'T EXIST IN AN OLD LUA VERSION, USED BY mpv.app ON MACOS.
while   val do mp.set_property(opt,val)   --('','') → NULL-SET
    opt,val = o.options(),o.options() end --nil @END

if not o.period or o.period==0 or o.periods==0 then NULL_OVERRIDE,o.period,o.periods,o.negate_enable,o.lut0_enable = true,1/o.fps,1,'0','0'  --POSSIBLE OVERRIDE BECAUSE NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('[^ ]') do o[nt]=o[nt] or 0 end end --n & t MUST BE WELL-DEFINED FOR NO TIME-DEPENDENCE.

FP=o.fps*o.period  --ABBREV. FRAMES PER PERIOD. USES n INSTEAD OF t TO AVOID INFINITE RECURRING DECIMALS.
for csm,SUB in pairs({c='cos(2*PI*(n)/%%s)',s='sin(2*PI*(n)/%%s)',m='mod(floor((n)/%%s)\\,2)',p=o.period..''}) do for opt in ('x y rotations widths heights'):gmatch('[^ ]+')  --(c),(s),(m),(p) SUBSTITUTIONS. ''..CONVERTS→string.  widths heights OPTIONAL (FOR eval=frame→DILATING PUPILS).  
    do o[opt]=o[opt] and o[opt]:gsub('%('..csm..'%)',SUB) end end  --%s=FRAMES/PERIOD  () ARE SPECIAL TO gsub.

for opt in ('negate_enable lut0_enable x y rotations zoompan'):gmatch('[^ ]+') 
do o[opt]=o[opt]:gsub('%%s',FP) end  --%s=FRAMES/PERIOD  BLINKER SWITCH, INVISIBILITY, OVERLAYS, ROTATIONS & zoompan.

for nt in ('n t'):gmatch('[^ ]') do if o[nt] then for opt in ('x y rotations'):gmatch('[^ ]+')     --SUB IN SPECIFIC TIME OR FRAME#.
        do o[opt]=o[opt] and o[opt]:gsub('%('..nt..'%)','('..o[nt]..')') end end end
o.zoompan=o.n and o.zoompan:gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') or o.zoompan --on=in=n  IF o.n DEFINED.

g={w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} -- g=GEOMETRY table. CONVERTS STRINGS→LISTS.
for key,opt in pairs(g) do g[key]={} --INITIALIZE w,h,x,y,...
   if o[opt] then for o in o[opt]:gmatch('[^ ]+') do table.insert(g[key],o) end end end

o.SECTIONS=o.SECTIONS or math.max(#g.w,#g.h)  --COUNT SECTIONS, IF UNSPECIFIED.
if o.SECTIONS==0 then o.SECTIONS,geq,o.DUAL,g.w,g.h,g.crops,g.x,g.y,g.rots,o.zoompan = 1,255,false,{'0'},{'0'},{},{},{},{},'1:0:0'  --0→iw & ih. DEFAULT TO (BLINKING?) FULL SCREEN NEGATIVE (A BIG RECTANGLE).
else NULL_OVERRIDE=false end  --mask STATIONARY BUT NOT NULL.

mask     ='%s'  --mask AUTO-GENERATED RECURSIVELY FROM %s, BEFORE DUAL.
g.rots[1]=g.rots[1] or '0'  --DUAL ROTATION IS SPECIAL & MUST BE DEFINED.
g.w[1]   =g.w[1] or not g.h[1] and 'iw'  --N=1 FULL-SIZE. g.h DEDUCED FROM IT. THE GENERATOR FORMULA OTHERWISE REDUCES FROM CANVAS (BIGGER SECTION).

for N=1,o.SECTIONS do g.w[N]=g.w[N] or not g.h[N] and ('iw*%d/%d'):format(1+o.SECTIONS-N,2+o.SECTIONS-N)  --EQUAL REDUCTION TO EVERY REMAINING SECTION.
    
    g.w[N]=g.w[N] or 'oh' --w & h MUST BE WELL-DEFINED. SET h=w FOR CIRLES/SQUARES ON FINAL DISPLAY.
    g.h[N]=g.h[N] or 'ow'
    g.x[N]=g.x[N] or ''   --x & y MUST BE WELL-DEFINED.
    g.y[N]=g.y[N] or ''
    
    if N==1 then for whxy in ('w h x y'):gmatch('[^ ]') do for WH in ('iw ih W H'):gmatch('[^ ]+') 
            do g[whxy][1]=g[whxy][1]:gsub(WH,('(%s/%s)'):format(WH,o.RES_SAFETY)) end end end  --RES_SAFETY IMPLEMENTED HERE. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. PERFECTLY CIRCULAR PUPIL/S FOR BOTH BINACLES & MONACLE. x MAY DEPEND ON H, & y ON W, ETC.
    
    g.x[N]=g.x[N]..'+(W-w)/2'  --AUTO-CENTER, OTHERWISE overlay SETS TOP-LEFT (0). THE W,H HERE NEVER GET SCALED BY RES_SAFETY (TRUE CENTER).
    g.y[N]=g.y[N]..'+(H-h)/2'
    
    pre_overlay=g.crops[N] and ',crop='..g.crops[N] or ''  --crop & rotate AFTER overlay (ACTUALLY DOES THE WHOLE LOT).  STARTING "," MAY BE MORE ELEGANT.
    if g.rots[N+1] and g.rots[N+1]~='0' then pre_overlay=('%s,rotate=%s:max(iw\\,ih):ow:BLACK@0'):format(pre_overlay,g.rots[N+1]) end   --PADS SQUARE SO AS TO AVOID CLIPPING.
    
    SECTION=N> 1 and (',split[%d],scale=round((%s)/4)*4:round((%s)/4)*4%%s,negate'):format(N-1,g.w[N],g.h[N]) or ''  --split N-1 & scale. %%s IS FOR N=2. MUST USE MULTIPLES OF 4 DUE TO AN overlay BUG.  scale=eval=frame FOR DILATING PUPILS. BUT CLOSING THE EYELIDS MIGHT SHRINK THE PUPILS.
    SECTION=N==2 and SECTION:format(',split,alphamerge') or SECTION  --N=2 TRANSPARENT: →ya16.
    mask=mask:format('%s%%s%s[%d],[%d][%d]overlay=%s:%s'):format(SECTION:format(''),pre_overlay,N,N-1,N,g.x[N],g.y[N]) end   --crop rotate & overlay. SECTION='' FOR N=1 (overlay ON [0]).

mask=mask:format('')..',format=y8'..(o.DUAL and (',crop=iw*(1+1/(%s))/2:ih:0,split[L],hflip[R],[L][R]hstack'):format(o.RES_SAFETY) or '')  --TERMINATOR %s=''. REMOVE alpha AFTER FINAL overlay. SUBTRACT HALF RES_SAFETY FROM RIGHT: w=iw-(iw-iw/(%s))/2  FFMPEG COMPUTES string OR ELSE INFINITE RECURRING IN LUA. PRECISION TESTING: FOR BINACLES TO MEET @CENTER CAN SET g.w[1]=iw+2 (OFF BY 2) IN OPTIONS.
o.DUAL=o.DUAL and 2 or 1  --DUAL→2 OR 1 (boolean→number).
o.RES_SAFETY,o.periods_skipped = 1+(o.RES_SAFETY-1)/o.DUAL,math.min(o.periods_skipped,o.periods)  --MAX-SKIP=periods. RES_SAFETY NOW HALVED IF DUAL crop. HOWEVER ITS FURTHER USE IS UNNECESSARY (EXTRA PIXELS RESOLUTION WHICH ARE THEN DISCARDED). 

lavfi=('fps=%s%%s,scale=%%d:%%d,setsar=%%s,format=%s,split=3[to][vo],%s[vf],[to]crop=1:1:0:0:1:1,lut=a=0,split[to],select=lt(n\\,2),trim=end_frame=1,setpts=PTS-(1/FRAME_RATE+%s)/TB,format=y8,split[t0],setpts=0,lut=0,split[0][1],[0][vo]scale2ref=round(oh*a/%d/4)*4:round(ih*(%s)/4)*4[0][vo],[1][0]scale2ref=oh:ih[1][0],[1]geq=%s[1],[1][0]scale2ref=round((%s)/4)*4:round((%s)/4)*4[1][0],[0]loop=%s:1[0],[1]loop=%s:1%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%d:2^14,loop=%s:1,rotate=%s:oh*iw/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:1:%%dx%%d:%s,setsar=%%s,negate=enable=%s,lut=0:enable=%s,loop=-1:2^14,setpts=PTS-(%d)/FRAME_RATE/TB,select=gte(t\\,0),eq=1:%%s[m],[t0][m]scale2ref,concat,trim=start_frame=1[m],[m][to]overlay=0:0:endall[m],[vo][vf][m]maskedmerge')
    :format(o.fps,o.format,o.filterchain,o.lead_t,o.DUAL,o.RES_MULT,o.geq,g.w[1],g.h[1],FP-1,FP-1,mask,o.RES_SAFETY,o.periods-o.periods_skipped-1,FP*o.periods_skipped,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps,o.negate_enable,o.lut0_enable,FP*o.periods)  --RES_SAFETY FOR mask EXCESS & THEN rotate CROPS IT OFF. FP FOR [0],[1] INITIALIZATION, periods_skipped & FINAL SELECTOR. fps REPEATS FOR zoompan. 

----lavfi  =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTERGRAPH. SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. NO audio ALLOWED. RE-USING LABELS IS SIMPLER. [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [0]=CANVAS. [1][2]...[N] ARE SECTIONS.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS, SO THEY ALL SCOOT AROUND TOGETHER. [to] TIMESTREAM TERMINATES [m].  A DIFFERENT DESIGN COULD REMOVE THE FINAL TWIRLS FOR A STRONG FINISH (FINALE) BY MANIPULATING [to].  THIS EXACT CODE PROPERLY IMPLEMENTS RES_SAFETY, WITH PRECISION.
----fps    =fps:start_time  FRAMES_PER_SECOND:SECONDS  IS THE START.  :start_time IS ONLY FOR image (SETS STARTPTS FOR --start).
----null          PLACEHOLDER. 
----lutyuv,lut    LOOK-UP-TABLE-BRIGHTNESS-UV  DEFAULT=val RANGE [0,255]  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv FASTER THAN lutrgb. lut FOR INVISIBILITY SWITCH & TO DROP ROTATIONAL PADDING FROM BELOW 16 TO 0.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).  COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----format =pix_fmts   ALSO CONVERTS TO y8 (8-BIT BRIGHTNESS) FOR EFFICIENCY.
----crop   =w:h:x:y:keep_aspect:exact    DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  OVER-CROPPING DISC (THE 2.2) MAY CAUSE GRIZZLE AFTER DISC ROTATIONS. LINUX snap DOESN'T ALLOW oh BEFORE COMPUTING IT (USE ow INSTEAD OF oh).
----rotate =angle:ow:oh:fillcolor  (RADIANS:PIXELS CLOCKWISE) ROTATES EACH SECTION, BEFORE FINAL scale2ref. PI/4 & PI/8 HELP PREPARE INITIAL DISC (MAY USE INTERMEDIATE scale, TOO). THE 0TH (DUAL zoompan) ROTATION IS SPECIAL.
----zoompan=zoom:x:y:d:s:fps  (z>=1) d=1 FRAMES DURATION-OUT PER FRAME-IN. NEEDS setsar FOR SAFE concat.  zoompan OPTIMAL FOR ZOOMING.
----loop   =loop:size  (LOOPS>=-1:MAX_SIZE>0)  ENABLES INFINITE loop SWITCH ON JPEG, IN TANDEM WITH automask2. ALSO LOOPS INITIAL CANVAS [0] & DISC [1], FOR period (BOTH SEPARATE). THEN LOOPS TWIRL FOR periods-periods_skipped-1, THEN loop LEAD FRAME FOR periods_skipped, & THEN loop INFINITE. LOOPED FRAMES GO FIRST.
----scale,scale2ref=width:height  [0][vo]→[0][vo]  2REFERENCE SCALES [0]→[0] USING DIMENSIONS OF [vo]. WILL FAIL PRECISION TESTING WITHOUT MULTIPLES OF 4 (overlay BUG). PREPARES EACH SECTION FROM THE LAST, & SCALES 2display. 
----setsar =sar  SAMPLE/PIXEL ASPECT RATIO. FOR SAFE concat OF [t0]. ALSO STOPS EMBEDDED MPV SNAPPING on_vid. MACOS BUGFIX REQUIRES sar.
----split  =outputs CLONES video. mask IS 3-WAY split. 
----alphamerge  [y][a]→[ya]  CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. ALTERNATIVES INCLUDE colorkey colorchannelmixer shuffleplanes.
----setpts =expr  ZEROES OUT TIME FOR THE CANVAS, REMOVES THE FIRST TWIRL (NOT SMOOTH) & IMPLEMENTS lead_t (TRIAL & ERROR). SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].
----negate        FOR INVERTER SWITCH, & EACH SECTION.
----hflip         PAIRS WITH hstack FOR DUAL.
----hstack        FOR DUAL.
----select =expr  EXPRESSION DISCARDS FRAMES IF 0. REMOVES THE FIRST periods, WHICH ARE CHOPPY ON FINAL OUTPUT (MAYBE A buffer ISSUE).  BUGFIX FOR OLD MPV, select FOR [t0]. REDUCES RAM USAGE.
----geq    =lum   GLOBAL EQUALIZER IS SLOW, EXCEPT ON 1 FRAME. CAN DRAW ANY SHAPE.  EVEN IN A *NON*-PERIODIC DESIGN ITS DRAWING CAN BE RECYCLED INFINITELY.
----eq     =contrast:brightness  IS THE CONTROLLER.  DEFAULT=1:0  RANGES [-2:2]:[-1,1]  EQUALIZER FOR INSTA-TOGGLE. MAY ALSO BE USED IN filterchain, BUT TOGGLE WOULD BREAK ITS brightness (INTERFERENCE).
----concat  [t0][m]→[m]     FINISHES [t0].  CONCATENATES STARTING TIMESTAMP, ON INSERTION. OCCURS @seek.
----overlay=x:y:eof_action  FINISHES [to].  DEFAULT 0:0:repeat  endall TRIMS [m]. MAY PAIR WITH scale2ref. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4 (WILL FAIL PRECISION TESTING).
----trim   =...:start_frame:end_frame  IS THE FINISH ON [m].  TRIMS OFF TIMESTAMP FRAME [t0] FOR ITS TIME, & TO BUILD CANVAS.
----maskedmerge  IS THE FINISH ON [vo].  REDUCES NET CPU USAGE BY ~3% COMPARED TO overlay (25fps). ALSO DOESN'T NEED MULTIPLES OF 4. REQUIRES endall ON [m]. DOESN'T SUPPORT eof_action NOR shortest OPTIONS.


lavfi=NULL_OVERRIDE and o.filterchain or lavfi --NULL_OVERRIDE FOR FAST LOAD.

brightness,label = 0,mp.get_script_name() --brightness IS CONTROLLED on_toggle. 
function file_loaded(event)               --ALSO seek, on_vid & ytdl.
    if event and last_brightness==brightness then return end --CHECK brightness BEFORE REPLACING GRAPH. EACH REPLACEMENT TRIGGERS seek.
    
    W,H = o.scale[1],o.scale[2]  --scale OVERRIDE.
    if not W then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not W then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).
    if not W then mp.add_timeout(.05,file_loaded)  --EXCESSIVE LAG IN VIRTUALBOX-SMPLAYER-YOUTUBE. RE-RUN AFTER 50ms.
        return end
    
    par=mp.get_property_number('current-tracks/video/demux-par') or 1  --PIXEL ASPECT RATIO MUST BE WELL-DEFINED. JPEG ASSUME 1. 
    last_brightness,is1frame,loop,start_time = brightness,NULL_OVERRIDE,false,''  --start_time IS A JPEG fps ISSUE. loop (is_looper) DEPENDS ON file. NULL_OVERRIDE is1frame RELATIVE TO toggle. last_brightness DEFINED @GRAPH INSERTION.
    
    complex_opt=mp.get_opt('lavfi-complex')
    complex_opt=complex_opt~='' and complex_opt~='no' and complex_opt    --A BLANK complex IS NOTHING. ASSUME OPT MEANS IMAGES ALREADY ON loop, WHICH WORKS DIFFERENT WITH albumart (TIME-STREAM ISSUE).
    
    if not complex_opt then is1frame=is1frame or mp.get_property_bool('current-tracks/video/albumart') --albumart is1frame RELATIVE TO toggle. MP4TAG & MP3TAG ARE BOTH albumart. SPECIAL & DON'T loop WITHOUT lavfi-complex. CAN COMPARE .JPG TO .MP3.
        if mp.get_property_bool('current-tracks/video/image') then loop,start_time = true,':'..mp.get_property_number('time-pos')  --GIF IS ~image.  
            for _,filter in pairs(mp.get_property_native('vf')) do if filter.label=='loop' or filter.name=='loop' then loop=false  --SCRIPTS MUST CHECK LABELS & NAMES FOR loop.  automask.lua & automask2.lua MUST ANIMATE SIMULTANEOUSLY ON ANY JPEG.
                    break end end end end 
    if loop then mp.set_property_bool('pause',true) --INSTA-pause REQUIRED TO ESTABLISH INFINITE loop, IN SMPLAYER. THIS TECHNIQUE ADDS VARIETY, INSTEAD OF USING lavfi-complex (autocomplex.lua).
                 mp.command('no-osd vf pre @loop:loop=loop=-1:size=1') 
                 mp.set_property_bool('pause',false) end  
    mp.command(('no-osd vf append @%s:lavfi=[%s]'):format(label,lavfi):format(start_time,W,H,par,W,H,par,brightness))  --W,H FOR scale & zoompan. setsar=par BEFORE & AFTER zoompan.
    if OFF then OFF=false  --ALREADY OFF, FORCE TOGGLE. EXAMPLE: playlist-next WHEN OFF.
        on_toggle() end  
end
mp.register_event('file-loaded',file_loaded)
mp.register_event('seek'       ,file_loaded)  --GRAPH MAY RE-SET brightness ON seek.  
mp.register_event('end-file',function() last_brightness,last_vid = nil,nil end)  --CLEAR MEMORY FOR MPV PLAYLISTS (EXAMPLE: path=*.MP4)

function on_vid(_,vid)  --RE-LOADS ON CHANGE IN vid. AN MP3, MP2, ETC, MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED MASK.   HOWEVER FAILS TO ANIMATE ON MP4TAG (STILL FRAME) WITHOUT complex, BECAUSE THAT'S albumart.
    if last_vid and last_vid~=vid then file_loaded() end
    last_vid=vid  --REMEMBER vid.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.

function on_toggle(mute) 
    if not W then return  --NOT loaded YET.
    elseif mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE toggle.
        return end
        
    OFF,brightness = not OFF,-1-brightness  -- 0,-1 = ON,OFF
    if is1frame then mp.command('no-osd vf toggle @'..label)  --NULL_OVERRIDE & albumart. VERIFY USING "F2" TOGGLE, OR DOUBLE-mute. ALSO WORKS IN TANDEM WITH autocrop. 
    else             mp.command(('vf-command %s brightness %s'):format(label,brightness)) --INSTA-TOGGLE.
        if mp.get_property_bool('pause') then for N=1,o.frame_steps_if_paused do mp.command('frame-step') end --TRIGGERS pause PROPERTY. 
            mp.add_timeout(.05,function() mp.set_property_bool('pause',true) end) end end --SOMETIMES MPV UNPAUSES BY ACCIDENT AFTER FRAME-STEPPING.
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute', 'bool', on_toggle)

timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --timer CARRIES OVER IN MPV PLAYLIST.
timer.oneshot=true 
timer:kill()


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 10 EXAMPLES), LINE TOGGLES (OPTIONS), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.36.0 (.7z .exe .app .flatpak .snap v3) v0.35.1 (.AppImage) ALL TESTED.  v0.37.0 FAILED ON WINDOWS & GAVE UNACCEPTABLE PERFORMANCE ON MACOS-11. (v0.36 & OLDER ONLY.)
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.
----FFmpeg v6.0(.7z .exe .flatpak .snap)  v5.1.2 v5.1.3(.app)  v4.3.2(.AppImage)  ALL TESTED.
----WIN10 MACOS-11 LINUX-DEBIAN-MATE  (ALL 64-BIT)  ALL TESTED.

----EACH mask REQUIRES EXTRA ~370MB RAM. 310MB=1680*1050*4*22*2/1e6=display*yuva*22FRAMES*2periods/1MB 
----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). CAN GIVE MPV ITS OWN WINDOW OR USE v23.6 (JUNE RELEASE) INSTEAD. SMPLAYER NOW COUPLES seek 0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 

----ALTERNATIVE FILTERS:
----colorkey=color:similarity       MORE PRECISE THAN alphamerge.
----shuffleplanes                   MAY NOT BE snap COMPATIBLE.
----drawtext=...:expansion:...:text COULD MAKE DANCING CLOCK, BUT NOT WORKING WITH WINDOWS directwrite, WITHOUT SPELLING OUT FULL PATHS TO SYSTEM FONT TYPE FILES.
----pad     =w:h:x:y:color  CAN PREP A 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.
----avgblur (AVERAGE BLUR)  CAN SHARPEN A CIRCLE FROM BRIGHTNESS BY ACTING ON 4x4/8x8 SQUARE. ALTERNATIVES INCLUDE gblur & boxblur. geq IS BETTER.
----lut2  [1][2]→[1]        CAN GEOMETRICALLY COMBINE avgblur CLOUDS USING ANY FORMULA. x*y/255 BEATS (x+y)/2 & sqrt(x*y), BY TRIAL & ERROR IN MANY SITUATIONS.

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



