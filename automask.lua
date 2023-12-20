----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV & SMPLAYER, WITH INSTANT DOUBLE-mute TOGGLE (m&m FOR MASK). IF PAUSED, INSTA-TOGGLE FRAME-STEPS TOO. COMES WITH 10 MORE EXAMPLES INCLUDING MONACLE, BINACLES, VISORS, ETC. MOVING POSITIONS, ROTATIONS & ZOOM. 2 MASKS ALSO POSSIBLE BY RENAMING A COPY OF THE SCRIPT. GENERATOR CAN MAKE MANY DIFFERENT MASKS, WITHOUT BEING AS SPECIFIC AS A .GIF (A GIF IS HARDER TO MAKE). USERS CAN COPY/PASTE PLAIN TEXT INSTEAD.
----APPLIES ANY LIST OF ffmpeg-filters TO MASKED REGION, WITH INVERSION & INVISIBILITY. filters HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE PURELY DECORATIVE. DILATING PUPILS NOT CURRENTLY SUPPORTED - COULD BREAK LINUX snap COMPATIBILITY. 
----WORKS WITH JPG, PNG, GIF, BMP, MP3 COVER ART, MP4 ETC, IN SMPLAYER & MPV (DRAG & DROP). albumart LEAD FRAME ONLY (WITHOUT autocomplex). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP, PDF OR TXT. WORKS WELL WITH YOUTUBE (ytdl). LOAD TIME SLOW (LACK OF BUFFERING). FULLY RE-BUILDS ON EVERY seek. CHANGING vid TRACKS (MP3TAG) SUPPORTED. NO FANCY TITLE (drawtext) OR CLOCK IN THIS SCRIPT. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). 
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS USE QUARTER POWER LAW FOR NON-LINEAR SATURATION. A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER. gauss SIZES ARE APPROX minval*1.5 SHIFTED 1.5x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. 

o={ --options  ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATIVE).      nil & false → DEFAULT VALUES    (BUT BLANK string ''=true).
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED BY DOUBLE mute.
    key_bindings         ='F2',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. m IS MUTE SO CAN DOUBLE-PRESS m FOR MASK. 'F2 F3' FOR 2 KEYS. F1 MAY BE autocomplex (SLOW toggle).
    
    filters='null,' --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING). TIMELINE SWITCHES ALSO POSSIBLE (FILTER1→FILTER2→ETC).
          ..'lutyuv=255*((1-val/255)^4*(1+.6*.2)+.2*(1.5*gauss((255-val)/(255-maxval)/2-1.5)-1*gauss(val/minval/1.5-1))/gauss(0)+.01*sin(2*PI*val/minval))'  -- +1% SINE WAVE ADDS RIPPLE TO CHANGING DEPTH. FORMS PART OF lutyuv GLOW-LENS.
                ..':128*(1+(val/128-1)/abs(val/128.01-1)^.2)'  --u & v USE A POWER LAW, NON-LINEAR SATURATION 20% (IN EXPONENT). GREYSCALE IS CENTERED ON 128 NOT 127.5 (128 MEANS 0 IN POPULAR YUV COVERSION FORMULAS).   autocomplex ALSO STRENGTHENS COLORS (BUG).
                ..':128*(1+(val/128-1)/abs(val/128.01-1)^.2)', --sgn FUNCTION NOT LINUX snap COMPATIBLE, HENCE 128.01 ISSUE. LOOK-UP-TABLE COMPUTES EVERYTHING @GRAPH INSERTION.
    
    fps    =   25, --DEFAULT=25 FRAMES PER SECOND. fps SHOULD MATCH OTHER SCRIPTS (autocomplex) FOR SIMPLICITY. 
    period =18/25, --DEFAULT=0 SECONDS (LEAD-FRAME ONLY). USE EXACT fps RATIO TO MATCH t & in. 18/25→83BPM (BEATS PER MINUTE). SHOULD MATCH OTHER SCRIPT/S, E.G. autocomplex (SYNCED EYES & MOUTH).  UNFORTUNATELY A SLOW ANIMATION IS SLOW TO LOAD (REDUCE RES_MULT).
    periods=    2, --DEFAULT=1, INTEGER. INFINITE loop OVER period*periods.  0 period OR periods FOR STATIC.    
    
    INVERT='1-between(t/%s\\,.5\\,1.5)',    --DEFAULT='0' (NO BLINKING). %s=period  TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE (BLINKER SWITCH). E.G. TO START OPPOSITE, USE "1-...". THIS ONE BLINKS NEAR BOTTOM.
    -- DISABLE='1-between(t/%s\\,.5\\,1.5)',--DEFAULT='0'. UNCOMMENT FOR INVISIBILITY. %s=period  TIMELINE SWITCH FOR MASK.     AN ALTERNATIVE CODE COULD PLACE THIS *BEFORE* THE INVERTER, SO INVISIBILITY ITSELF CAN BE INVERTED.
    
    -- SQUARE=true,      --UNCOMMENT FOR RECTANGULAR SECTIONS, INSTEAD OF DISCS.
    -- blur_enable=0,    --0 OR 1 (DEFAULT). IRRELEVANT IF SQUARE. UNCOMMENT FOR CUT-CORNERS. (WITHOUT avgblur THERE'S NOTHING CIRCULAR.)
    -- ROUND_SQUARE=true,--FOR ROUNDED SQUARES INSTEAD OF CIRCLES, UNLESS SQUARE OR blur_enable=0. ARGUABLY MORE NATURAL FOR RECTANGLE HEAD.
    
    SECTIONS=6,   --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights. MAY LIMIT NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.
    DUAL    =true,--REMOVE FOR LEFT-ONLY. ENABLES LEFT→RIGHT FLIP, & HALVES INITIAL iw (display CANVAS).
        
    widths ='iw*1.1    iw*.6', -- iw=INPUT-WIDTH  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)     REMOVE THESE 5 LINES TO AUTO-GENERATE DISCS. 
    heights='ih/2      ih*.5 ih           ih/2           ih/8', -- ih=INPUT-HEIGHT   EXACT POSITIONING IS TRIAL & ERROR. PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING, BUT ONLY COVERING OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    x='-W/64*(s)       0     W/16*(1+(c)) W/32*(c)       W/64', -- (c),(s) = (cos),(sin) WAVES IN TIME=t/period. overlay COORDS FROM CENTER. W IS THE BIGGER DISC/CANVAS, & w IS THE DISC.  (t)=(time) (n)=(frame#) (p)→(period) (c)→(cos(2*PI*(t)/(p))) (s)→(sin(2*PI*(t)/(p))) (T)→((t)/(p))   %s=period=(p) 
    y='-H*((c)/16+1/6) H/16  H/32*(s)     H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD (NEGATIVE MEANS UP).  (c),(s) = (cos),(sin)      %s=period
    crops='iw:ih*.8:0:ih-oh  iw*.98:ih:0',   --DEFAULT NO crop. SPECTACLE-TOP & RED-EYE CROPS CLEAR MASK'S TOP & MIDDLE. oh=OUTPUT-HEIGHT  crops GO BEFORE x & y. 
    
    rotations='PI/16*(s)*mod(floor((t)/%s)\\,2)  PI/32*(c)  -PI/64*(c)',       --(c),(s) = (cos),(sin)  %s=period (t NOT n). DEFAULT='0'. RADIANS CLOCKWISE.  PI/32=.1RADS=6° (QUITE A LOT)    SPECIFIES ROTATION OF EACH DISC, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL.
    zoompan  ='1+.2*(1-cos(2*PI*((in)/%s-.2)))*mod(floor((in)/%s-.2)\\,2):0:0',--%s=FRAMES-PER-PERIOD=fps*period  (zoom:x:y)  in=INPUTFRAMENUMBER=on=OUTPUT#  mod IS AN ON/OFF SWITCH.     20% zoom FOR RIGHT PUPIL TO PASS SCREEN EDGE. 20% PHASE OFFSET, LIKE A BASEBALL BAT'S ROTATIVE WIND UP.
    
    RES_MULT  =  2, --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER LOAD. HD*2 FOR SMOOTHER ROTATIONS @HD.
    RES_SAFETY=1.1, --DEFAULT=1 (MINIMUM)  rotation RESOLUTION MULTIPLIER TO ENSURE 0TH ROTATION NEVER CLIPS. SAME FOR X & Y. @HD*2 THIS ADDS MANY BLACK (BLANK) PIXELS WHICH ARE DISCARDED.   E.G. REDUCE TO 1.01 (1%) FROM 1.1 (10%) TO SEE THE EFFECT OF CLIPPING.
    
    -- lead_t=1/25,      --DEFAULT=0 SECONDS. +-LEAD TIME FOR SYNC OF MASK WITH OTHER FILTERS/GRAPHS.
    -- t=5/25, n=5,      --UNCOMMENT FOR STATIONARY SPECTACLES. SUBSTITUTIONS FOR (t) & (n)=(in). MAY CHOOSE A SPECIFIC TIME OF FAV. ANIME. DOESN'T APPLY TO INVERT & DISABLE.
    -- periods_skipped=1,--DEFAULT=0, INTEGER. LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS, PER loop. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOES NOT APPLY TO INVERT & DISABLE. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY COORD, ETC.
    -- scale={1680,1050},--NEEDED IN LINUX (VIRTUALBOX) FOR PERFECT CIRCLES ON FINAL display. DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX).  ROUNDS TO NEAREST MULTIPLES OF 4 (ceil).
    
    ----10 EXAMPLES: 0) NULL  1) BLINKING MONACLE/SQUARE  2) BINACLES  3) OSCILLATING VISOR  4) BUTTERFLY SWIM  5) DOUBLE-TWIRL & SKIP  6) 10*ZOOMY DISCS  7) ELLIPTICAL VISOR  8) SCANNING VISOR (SIDEWAYS)  9) FALLING VISOR.         UNCOMMENT LINES TO ACTIVATE. USERS CAN ALSO COPY-PASTE PARTS OF THESE.
    -- SECTIONS=0,periods=0, --NULL OVERRIDE. FAST CALIBRATING, USING TOGGLE.  CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y='H*.002',crops=nil,   --UNCOMMENT FOR MONACLE (ROTATING). FOR SQUARE, APPEND "rotations=nil,y=nil,SQUARE=true,"   DISC ih SHORT OUT OF FEAR OF OVER-CROPPING DISCS, & y OFF BY APPROX .2%. SECTIONS>1 FOR CONCENTRIC CIRCLES.
    -- zoompan=nil,SECTIONS=1,widths='iw*1.02',heights=nil,x=nil,y=nil,crops=nil,   --BINACLES. 2% EXTRA FOR TOUCH.
    -- SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,SQUARE=true, --VISOR OSCILLATING UP & DOWN.
    -- zoompan=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,y='-(H+h)*(t/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/64*cos(2*PI*(t))',     --BUTTERFLY SWIMMING UPWARDS EVERY 4 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND. THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). (t) FOR rotations.
    -- zoompan=nil,periods=3,periods_skipped=1,INVERT='gte(t\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',    --2 TWIRLS & SKIP: INVERT OUTSIDE WHEN TWIRLING.
    -- SECTIONS=10,INVERT=nil,widths='iw+1',heights=nil,x=nil,y=nil,crops=nil,     --CONCENTRIC DISCS. SET SQUARE=true FOR SQUARES (PROOF width IS OFF BY 1p).
    -- SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil,   --DANCING VISOR: HORIZONTAL ELLIPSE. rotations WORK WELL WITH CURVES.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,widths='iw/3',heights='ih',x='(W+w)*(t/%s-1/2)',y=nil,crops=nil,rotations=nil,SQUARE=true, --VERTICAL VISOR, SCANNING TIME 4 SECONDS.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,periods=1,period=4,INVERT=nil,widths='iw',heights='ih/3',x=nil,y='(H+h)*(t/%s-1/2)',crops=nil,rotations=nil,SQUARE=true,--HORIZONTAL VISOR FALLING @4 SECONDS.
    
    -- osd_on_toggle='Audio filters:\n%s\n\nVideo filters:\n%s\n\nlavfi-complex:\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICKING MUTE ENABLES CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
    io_write=' ',   --DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY CHANGE IN vf. STOPS EMBEDDED MPV FROM SNAPPING ON COVER ART. MPV COMMUNICATES WITH ITS PARENT APP.
    set     ={   --set OF FURTHER options.
        'osd-font-size 16','osd-border-size 1','osd-scale-by-window no', --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
        'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL DEFAULT SIZE.
        'image-display-duration inf','vd-lavc-threads 0',  --inf STOPS JPEG FROM SNAPPING MPV.  0=AUTO, vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO.
    },
}
if o.DUAL then o.DUAL=2 end --1 OR 2.  CONVERT BOOL INTO NUMBER OF REFLECTIONS (+1).
for key,val in pairs({toggle_on_double_mute=0,key_bindings='',filters='lutyuv=negval',fps=25,periods=1,DUAL=1,INVERT='0',DISABLE='0',blur_enable=1,x='0',y='0',rotations='0',zoompan='1:0:0',RES_MULT=1,RES_SAFETY=1,lead_t=0,periods_skipped=0,scale={},io_write='',set={}})
do if not o[key] then o[key]=val end end      --ESTABLISH DEFAULTS. 

for _,o in pairs(o.set) do o=o:gmatch('%g+')  --%g+=LONGEST GLOBAL MATCH TO SPACEBAR. RETURNS ITERATOR.
    mp.set_property(o(),o()) end

p=o.period --ABBREV.
if not p or p==0 or o.periods==0 then p,o.periods,o.INVERT,o.DISABLE = 1/o.fps,1,'0','0'   --OVERRIDE: NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('%g') do if not o[nt] then o[nt]=0 end end end     --SET SPECIFIC t OR n.
o.periods_skipped=math.min(o.periods_skipped,o.periods) --MAX-SKIP = periods

for key in ('INVERT DISABLE x y rotations'):gmatch('%g+') do o[key]=o[key]:format(p,p,p,p,p,p,p,p) end  --%s=p    BLINKER SWITCH, INVISIBILITY, POSITIONS & ROTATIONS.
FP=o.fps*p --FRAMES/PERIOD.
o.zoompan=o.zoompan:format(FP,FP,FP,FP,FP,FP,FP,FP) --%s=FP

for pTcs,SUB in pairs({p='%s',T='(t)/(%s)',c='cos(2*PI*(t)/(%s))',s='sin(2*PI*(t)/(%s))'}) do for xyr in ('x y rotations widths heights'):gmatch('%g+') do if o[xyr]   --period, SCALED TIME, cos & sin SUBSTITUTIONS.  widths heights OPTIONAL.
        then o[xyr]=o[xyr]:gsub('%('..pTcs..'%)',SUB:format(p)) end end end     --%s=period
for nt in ('n t'):gmatch('%g') do if o[nt] then for xyr in ('x y rotations'):gmatch('%g+') do if o[xyr]   --SUB IN SPECIFIC TIME OR FRAME#.
            then o[xyr]=o[xyr]:gsub('%('..nt..'%)','('..o[nt]..')') end end end end
if o.n then o.zoompan=o.zoompan:gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') end   --on=in=n

g={w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} -- g=GEOMETRY table. CONVERT STRINGS→LISTS, INSIDE g.
for key,option in pairs(g) do g[key]={} --INITIALIZE w,h,x,y,...
    if o[option] then for opt in o[option]:gmatch('%g+') do table.insert(g[key],opt) end end end
if not g.rots[1] then g.rots[1]='0' end     --0TH ROTATION IS SPECIAL & MUST BE DEFINED.

if not o.SECTIONS         then           N=0  --DETERMINE SECTIONS COUNT, IF NECESSARY.
    for M,_ in pairs(g.w) do             N=M end 
    for M,_ in pairs(g.h) do if M>N then N=M end end
    o.SECTIONS=N end
if o.SECTIONS==0 then if o.n and o.t then NULL_OVERRIDE=true end  --p=0 → SPECIFIC n & t (NULL_OVERRIDE).
    g.w,g.h,g.x,g.y,g.crops,g.rots,o.SECTIONS,o.DUAL,o.SQUARE,o.zoompan = {'0'},{'0'},{},{},{},{'0'},1,1,true,'1:0:0' end    --0→iw & ih. DEFAULT TO (BLINKING?) FULL SCREEN NEGATIVE.

N,rot_enable  = 0,1 --N>=0 IS SECTION #. rot_enable (1 OR 0) IS FOR avgblur ROTATIONS (FAT CIRCLE → CIRCLE).
if o.ROUND_SQUARE then rot_enable=0 end

DISC,mask,label = '','%s',mp.get_script_name()  --DISC CONVERTS SQUARE→CIRCLE. mask GENERATED RECURSIVELY FROM %s.  label='automask' 
if not o.SQUARE then DISC=(',avgblur=enable=%d,scale=iw*2:-1:bicubic,split[1],rotate=PI/4:enable=%d[2],[1][2]lut2=x*y/255,split[1],rotate=PI/8:enable=%d[2],[1][2]lut2=x*y/255'):format(o.blur_enable,rot_enable,rot_enable) end  --DRAW CIRCLE BEFORE mask. MAY USE INTERMEDIATE scale FOR 22.5° & 45° ROTATIONS. A THIRD PI/16 ROTATION MAY BE USED FOR SMOOTHER MONACLE.

while N<o.SECTIONS do N=N+1 --mask CONSTRUCTION, BEFORE DUAL.
    if not g.w[N] and not g.h[N] then if N==1 then g.w[N]='iw'    --AUTO-GENERATOR. N=1 FULL-SIZE.
        else g.w[N]=('iw*%d/%d'):format(1+o.SECTIONS-N,2+o.SECTIONS-N) end end    ----EQUAL REDUCTION TO EVERY REMAINING SECTION.
    if not g.w[N] then g.w[N]='oh' end  --w & h MUST BE DEFINED. SET w=h FOR CIRLES/SQUARES ON FINAL DISPLAY.
    if not g.h[N] then g.h[N]='ow' end

    for xy in ('x y'):gmatch('%g') do if not g[xy][N] then g[xy][N]='' end end --x & y MUST BE DEFINED.
    if N==1 then if o.DUAL==2 then g.x[1]=('%s+W*(%s-1)/2'):format(g.x[1],o.RES_SAFETY) end --TO ENSURE DUAL rotations ARE SAFE, SHIFT HALF-WAY THE DIFFERENCE TO THE RIGHT (ON THE LEFT MONACLE).
        for whxy in ('w h x y'):gmatch('%g') do for whWH in ('iw ih W H'):gmatch('%g+') do g[whxy][1]=g[whxy][1]:gsub(whWH,('(%s/(%s))'):format(whWH,o.RES_SAFETY)) end end end --MUST SCALE N=1 iw,ih,W,H BY SAFETY FACTOR. 0TH ROTATION GLITCH-FIX. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. PERFECTLY CIRCULAR PUPIL/S FOR BOTH BINACLES & MONACLE. x MAY DEPEND ON H, & y ON W, ETC.
    
    g.x[N]=g.x[N]..'+(W-w)/2' --AUTO-CENTER x & y BY DEFAULT, OTHERWISE overlay SETS TOP-LEFT (0).
    g.y[N]=g.y[N]..'+(H-h)/2'
    
    SECTION,pre_overlay = '',''  --SECTION FOR N>1. THEN (POSSIBLY) crop & rotate. 
    if g.crops[N] then pre_overlay=(',crop=%s'):format(g.crops[N]) end    --crop & rotate AFTER overlay (ACTUALLY DOES THE WHOLE LOT).
    if g.rots[N+1] and g.rots[N+1]~='0' then pre_overlay=('%s,rotate=%s:max(iw\\,ih):ow:BLACK@0'):format(pre_overlay,g.rots[N+1]) end   --PADS SQUARE SO AS TO AVOID CLIPPING.
    
    if N>1  then SECTION=(',split[%d],scale=floor((%s)/4)*4:floor((%s)/4)*4%%s,lut=255-val'):format(N-1,g.w[N],g.h[N]) end  --split N-1 & scale. %%s IS FOR N=2. FLOORED MULTIPLES OF 4 WORK BEST (2 MAY CAUSE overlay CENTERING BUG). lut WORKS IN LINUX snap, BUT NOT negate (snap DOESN'T SUPPORT ALL FILTERS).  scale=eval=frame FOR DILATING PUPILS, BUT BLINKING (N=2) WOULD SHRINK THE PUPILS?
    if N==2 then SECTION=SECTION:format(',split,alphamerge') end   --N=2 TRANSPARENCY →ya16.
    mask=mask:format('%s%%s%s[%d],[%d][%d]overlay=%s:%s'):format(SECTION:format(''),pre_overlay,N,N-1,N,g.x[N],g.y[N]) end   --crop rotate & overlay. SECTION='' FOR N=1 (overlay ON [0]).
mask=mask:format('')..',format=y8' --REMOVE alpha AFTER FINAL overlay. TERMINATOR %s=''. 
if o.DUAL==2 then mask=mask..',split[L],hflip[R],[L][R]hstack' end   --STARTING "," MAY BE MORE ELEGANT, TO MINIMIZE USE OF LABELS.

lavfi=('loop=%%s:1,fps=%s%%s,scale=%%d:%%d,setsar=1,split=3[to][vo],%s[vf],[to]crop=1:1:0:0:1:1,format=ya16,lut=a=0,split[to],select=lt(n\\,2),trim=end_frame=1,setpts=PTS-(%s)/TB,format=y8,split[t0],setpts=0,lut=0,split[0],pad=2:2,lut=255,pad=iw+2:ow:1:1:WHITE,pad=iw+2:ow:1:1:GRAY,pad=iw+2:ow:1:1%s[1],[0][vo]scale2ref=oh*a/%d:ih*(%s)[0][vo],[1][0]scale2ref=oh:ih*2.2:bicubic[1][0],[1]crop=iw/2.2:ow,lut=255*gt(val\\,74)[1],[1][0]scale2ref=%s:%s[1][0],[1]loop=%s:1%s[m],[m][vo]scale2ref=oh*a:ih*(%s)[m][vo],[m]loop=%d:2^14,loop=%s:1,rotate=%s:oh*iw/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:0:%%dx%%d:%s,setsar=1,lut=255-val:enable=%s,lut=0:enable=%s,loop=-1:2^14,setpts=PTS-(%s)/TB,select=gte(t\\,0),eq=1:%%d[m],[t0][m]scale2ref,concat,trim=start_frame=1[m],[m][to]overlay=0:0:endall[m],[vo][vf][m]maskedmerge')
    :format(o.fps,o.filters,o.lead_t,DISC,o.DUAL,o.RES_MULT,g.w[1],g.h[1],p*o.fps-1,mask,o.RES_SAFETY,o.periods-o.periods_skipped-1,p*o.periods_skipped*o.fps,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps,o.INVERT,o.DISABLE,p*o.periods)    --RES_SAFETY REPEATS FOR rotate TO CROP DOWN ON THE mask EXCESS. fps REPEATS WHEN LOOPING LEAD FRAME. p REPEATS FOR SELECTOR & LEAD-SKIP. 

----lavfi  =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH HIGHLIGHTING ETC. %% SUBSTITUTIONS OCCUR @file-loaded. NO audio ALLOWED. RE-USING LABELS IS SIMPLER. [vo]=VIDEO-OUT [vf]=VIDEO-FILTERED [m]=MASK [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [0]=CANVAS. [1] & [2] ARE DISC INITIALIZATION (SUPERPOSITION): THEN [1][2]...[N] ARE DISCS.  [t0] SIMPLIFIES MATH BTWN VARIOUS GRAPHS (ALL MUST SCOOT AROUND TOGETHER, ETC). [to] TIMESTREAM SHOULD USE alpha TO GO ON TOP.
----null    PLACEHOLDER.
----lutyuv,lut  BRIGHTNESS-UV  DEFAULT=val RANGE [0,255]  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MAY BE FASTER THAN lutrgb. lut FOR INVERT & DISABLE SWITCHES.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).        COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----fps    =fps:start_time  FRAMES_PER_SECOND:SECONDS  :start_time IS ONLY FOR JPEG (SETS STARTPTS).
----rotate =angle:ow:oh:fillcolor  (RADIANS:PIXELS CLOCKWISE) ROTATES EACH SECTION, BEFORE FINAL scale2ref. PI/4 & PI/8 HELP PREPARE INITIAL DISC (MAY USE INTERMEDIATE scale, TOO). THE 0TH (DUAL zoompan) ROTATION IS SPECIAL.
----zoompan=zoom:x:y:d:s:fps  (z>=1) d=0 FRAMES DURATION-OUT PER FRAME-IN. NEEDS setsar FOR SAFE concat.  zoompan MAY BE OPTIMAL FOR ZOOMING.
----loop   =loop:size  (LOOPS>=-1 : MAX_SIZE>0) -1 FOR image BUT NOT albumart. ALSO LOOPS INITIAL DISC FRAME FOR period. THEN LOOPS TWIRL FOR periods-SKIP, THEN LEAD FRAME FOR SKIP, & THEN REPEATS zoompan INFINITE. LOOPED FRAMES GO FIRST.
----scale,scale2ref=width:height:flags   [1][vf]→[1][vf]  2REFERENCE SCALES [1]→[1] USING DIMENSIONS OF [vf]. FORMS PAIR WITH overlay.  bicubic FOR LINUX snap COMPATIBILITY. ITS DEFAULT IS bilinear WHICH FAILS, BUT bicubic spline lanczos ARE ALL VALID. bicubic ALSO STANDARD ON LINUX, BUT NOT snap. CONVERT TO SCREEN SIZE BECAUSE OF zoompan. ONLY USE MULTIPLES OF 4 BECAUSE OF AN overlay BUG (OFF BY 1 FOR 1050p). PREPARES EACH DISC FROM THE LAST, & INITIALIZES 2048p DISC.     SCALES TO 2.2x BIG DISC, CALIBRATED WITH lut>74.  THE IDEA IS TO scale,crop A TINY SYMMETRIC BLUR TO HALF-10%, TO lut A DECENT CIRCLE. IN MS PAINT A PERFECT CIRCLE SHOULD INSCRIBE A MONACLE SCREENSHOT. SOMETIMES A SMOOTHER CIRCLE MAY BE MORE OBLONG. geq (GLOBAL EQUALIZER) IS TOO SLOW, BUT CAN DRAW ANY FORMULA - NOT JUST CIRCLES.
----setsar =sar  (ASPECT RATIO)  FOR SAFE concat OF [t0]. ALSO STOPS EMBEDDED MPV SNAPPING on_vid. MACOS BUGFIX REQUIRES sar.
----split  =outputs CLONES video. mask IS 3-WAY split. 
----alphamerge  [y][a]→[ya]  CONVERTS BLACK→TRANSPARENCY WHEN PAIRED WITH split. ALTERNATIVES INCLUDE colorkey colorchannelmixer shuffleplanes.
----lut2    [1][2]→[1]  LOOK-UP-TABLE*2  GEOMETRICALLY COMBINES [1][2] avgblur CLOUDS. A SIMPLE overlay WOULDN'T WORK (x*y/255 BEATS (x+y)/2). sqrt(x*y) ALSO DOESN'T WORK (TRIAL & ERROR).
----setpts =expr  ZEROES OUT TIME FOR THE CANVAS, REMOVES THE FIRST TWIRL (NOT SMOOTH) & IMPLEMENTS lead_t AFTER INFINITE loop. BY TRIAL & ERROR MUST NOT SUBTRACT 1/FRAME_RATE/TB FROM [t0] (MYSTERY).
----select =expr  EXPRESSION DISCARDS FRAMES IF 0. REMOVES THE FIRST periods, WHICH ARE CHOPPY ON FINAL OUTPUT (MAYBE A buffer ISSUE).  BUGFIX FOR OLD MPV, select FOR [t0]. REDUCES RAM USAGE.
----concat  [t0][m]→[m]  CONCATENATE STARTING TIMESTAMP WHENEVER USER SEEKS.
----crop   =w:h:x:y:keep_aspect:exact    DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0  OVER-CROPPING DISC (THE 2.2) MAY CAUSE GRIZZLE AFTER DISC ROTATIONS. LINUX snap DOESN'T ALLOW oh BEFORE COMPUTING IT (USE ow INSTEAD OF oh).
----format =pix_fmts  CONVERTS TO y8 & ya16, 8-BIT, BRIGHTNESS & OPAQUENESS, FOR EFFICIENCY.
----pad    =w:h:x:y:color  PREPS 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.   2x2/4x4 TOO SMALL. A LITTLE SQUARE IS LIKE A DISC WHO IS A LITTLE OFF & NEEDS A ROUND OF BLUR & SHARP.
----avgblur (AVERAGE BLUR) PAIRS WITH scale, TO SHARPEN A CIRCLE FROM BRIGHTNESS. ACTS ON 4x4/8x8 SQUARE. REMOVE FOR DIAGONAL-CUT RECTANGLES (enable=0). EXTRA options COULD BE ADDED FOR DIAGONAL CUT & OBLONG-CIRCLE, ETC.   ALTERNATIVES INCLUDE gblur & boxblur.
----overlay=x:y:eof_action  [N-1][N]→[N-1]  (DEFAULT 0:0:repeat) endall TRIMS [m]. MAY PAIR WITH scale2ref. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.
----eq     =contrast:brightness  DEFAULT=1:0  RANGES [-2,2]:[-1,1]  EQUALIZER FOR INSTA-TOGGLE. MAY ALSO BE USED IN filters, BUT TOGGLE WOULD BREAK ITS brightness (INTERFERENCE).
----trim   =...:start_frame:end_frame  IS THE FINISH FOR mask. TRIMS TIMESTAMP FRAME [t0] TO RESTORE ITS TIME, & PREP CANVAS. DOESN'T CHANGE PTS.
----maskedmerge  IS THE FINISH. OPTIMIZED COMPARED TO overlay. REDUCES NET CPU USAGE BY 3%. REQUIRES endall ON [m].

if NULL_OVERRIDE then lavfi,is1frame = o.filters,true end   --FAST LOAD. is1frame RELATIVE TO toggle.

function start_file()   --EMBEDDED MPV PLAYLISTS REQUIRE INSTA-pause BEFORE GRAPH INSERTION, TO AVOID SNAPPING.    'set geometry' ISN'T THE REASON.
    paused=false    --ALWAYS UNPAUSE @start-file→file-loaded.
    mp.set_property_bool('pause',true)  --BUG: INSTA-PAUSE NOT ALLOWED ON DARWIN (MACOS).
end
mp.register_event('start-file',start_file) 

function file_loaded(loaded) --ALSO on_vid & ytdl.
    if loaded then mp.add_timeout(.05,file_loaded) --BUGFIX FOR EXCESSIVE LAG IN VIRTUALBOX (MACOS & LINUX). ALSO WORKS IN WINDOWS. INSTA-pause LASTS 50ms.
        return end
    
    complex_opt,loop_opt = mp.get_opt('lavfi-complex'),mp.get_opt('loop')   --autocomplex & autocrop MAY INFINITE loop IMAGES, BEFORE automask.
    complex_opt,loop_opt = complex_opt and complex_opt~='' and complex_opt~='no',loop_opt and loop_opt~='0' and loop_opt~='no'
    if mp.get_property_bool('current-tracks/video/albumart') and not complex_opt then is1frame=true end   --is1frame RELATIVE TO toggle. albumart WITHOUT complex IS SPECIAL & DOESN'T loop. COMPARE .JPG TO .MP3.
    
    W,H = o.scale[1],o.scale[2]
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS & MACOS.
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --USE [vo] SIZE (LINUX).
    if not (W and H) then if not mp.get_property_number('current-tracks/video/id') and not complex_opt then mp.command('set pause no')    --RAW MP3 & NO complex → NO mask.
        else mp.add_timeout(.05,file_loaded) end  --LINUX FALLBACK: RE-RUN & return FOR DIMENSIONS. DUE TO EXCESSIVE LAG IN VIRTUALBOX.
        return end
    W,H = math.ceil(W/4)*4,math.ceil(H/4)*4 --BUGFIX: MULTIPLES OF 4 NECESSARY FOR PERFECT overlay.
    
    brightness,loop,start_time = -1,0,''   --LEAD FRAME OF FILM SHOULDN'T BE MASKED (JPEG OPPOSITE).
    if mp.get_property_bool('current-tracks/video/image') then brightness=0        --IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. 
        if not complex_opt then start_time=':'..mp.get_property_number('time-pos') --IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. 
            if not loop_opt then loop=-1    --ONLY INFINITE loop IF NO OTHER SCRIPT HAS. 
                mp.set_property('script-opts','loop=inf,'..mp.get_property('script-opts')) end end  --PREPEND NEW SCRIPT-OPT: WARNING image WILL INFINITE loop. TRAILING "," IS REMOVED.
        if o.io_write=='' then o.io_write=' ' end end --image NEEDS io FIX (CAN VERIFY SNAPS LESS OFTEN).
    mp.observe_property('vf','native',function() io.write(o.io_write) end)
    
    mp.command(('no-osd vf append @%s:lavfi=[%s]'):format(label,lavfi):format(loop,start_time,W,H,W,H,brightness))     --INSERT GRAPH. IT GOES AFTER autocrop. W,H REPEAT FOR zoompan.
    mp.set_property_bool('pause',paused)
    brightness=0    --0=ON @playback-restart
end
mp.register_event('file-loaded',file_loaded)

function playback_restart(playback_restart) --GRAPH RESETS ON seek.
    mp.command(('vf-command %s brightness %s'):format(label,brightness)) 
    if not is1frame and not (OFF and playback_restart) and mp.get_property_bool('pause') then N=0   --frame-step IF PAUSED & NOT is1frame & NOT AN OFF SEEK.
        while N<3 do N=N+1  --FRAMES ALREADY DRAWN IN ADVANCE. AN UNPAUSE→pause timer CAN ALSO BE USED.
            mp.command('frame-step') end end    --FASTER & SIMPLER THAN vf toggle WHEN PAUSED.
end
mp.register_event('playback-restart',playback_restart)

function on_vid(_,vid)  --RE-LOADS ON CHANGE IN vid. AN MP3 MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED MASK.
    if last_vid and last_vid~=vid then paused=mp.get_property_bool('pause')
        mp.set_property_bool('pause',true)
        file_loaded() 
        if OFF then OFF=false --FORCE RE-TOGGLE OFF, IF OFF.
            on_toggle() end end
    last_vid=vid    --REMEMBER vid.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.

function on_toggle(mute) 
    if not W then return end --NOT loaded YET.
    if mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE toggle.
        return end
        
    OFF,brightness = not OFF,-1-brightness  -- 0,-1 = ON,OFF
    if is1frame then mp.command('no-osd vf toggle @'..label)  --NULL_OVERRIDE & albumart. VERIFY USING "F2" TOGGLE, OR DOUBLE-mute. ALSO WORKS IN TANDEM WITH autocrop. 
    else playback_restart() end
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute', 'bool', on_toggle)

timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --double_mute timer CARRIES OVER IN MPV PLAYLIST.
timer.oneshot=true 
timer:kill()


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.  EXAMPLE: YOU CAN RENAME o.DISABLE→o.lut0_enable (PROPER LOWERCASE SWITCH NAME), BUT SOMETIMES CAPSLOCK IS BETTER.
----MPV v0.36.0 (INCL. v3) v0.35.0 (.7z) v0.35.1 (.flatpak)  HAVE BEEN FULLY TESTED.
----FFmpeg v5.1.2(MACOS) v4.3.2(LINUX .AppImage) v6.0(LINUX) HAVE BEEN FULLY TESTED.
----MASK REQUIRES EXTRA ~370MB RAM. 254MB=1680*1052*4*18*2/1e6=display*yuva*18FRAMES*2periods/1MB 

----ALTERNATIVE FILTERS:
----drawtext=...:expansion:...:text    NOT WORKING WITH WINDOWS directwrite, WITHOUT SPELLING OUT FULL PATHS TO SYSTEM FONT TYPE FILES.
----negate  =components  (y=lum)  FOR INVERT SWITCH. components MAY NOT BE LINUX snap COMPATIBLE.

--eq ONLY        filters='eq=-.5:0:1.1',  
--2 SINE WAVES   filters='lutyuv=minval+.75*(negval-minval)+4*minval*(sin(2*PI*(negval/minval-1)/4)*lt(negval/minval\\,2)+sin(2*PI*(negval-maxval)/minval/4)*lt((maxval-negval)/minval\\,4)),eq=saturation=1.2', 
--ASIN           filters='lutyuv=minval+255*asin(negval/maxval)^.5/PI*2,eq=saturation=1.2', 
--ASIN ASIN      filters='lutyuv=255*asin(asin(negval/maxval)/PI*2)^.3/PI*2,eq=saturation=1.2', 
--SQRT+SQRT(1-X) filters='lutyuv=.8*255*(lt(negval\\,128)*(negval/maxval)^.5+gte(negval\\,128)*(1-negval/maxval)^.5),eq=saturation=1.2', 
--SIGNED POWERS  filters='lutyuv=.8*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^abs(1-val/255/.5))),eq=saturation=1.1', 
--X^(1+X^2)      filters='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(1+(2*abs(1-val/255/.5))^2)),eq=saturation=1.1', 
--X^(3^(X^2))    filters='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^(abs(1-val/255/.5)^2))),eq=saturation=1.1', 
--50% DROP QUAD GAUSS filters='lutyuv=minval+.4*(negval-minval+128/gauss(0)*(1*gauss((255-val)/(255-maxval)/.9-1)-.6*gauss((255-val)/(255-maxval)/.9-2)-1*gauss(val/minval/.9-1)+.6*gauss(val/minval/.9-2))),eq=1.2:0:1.2',  -- .6=exp(-.5)    negval/minval APPROX (255-val)/(255-maxval)
--QUAD-GAUSS     filters='lutyuv=.75*(negval-minval)+minval+100/gauss(0)*(1*gauss((255-val)/(255-maxval)/2-1)-.6*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.7-1)+.6*gauss(val/minval/1.7-2)),eq=saturation=1.1',  -- .6=exp(-.5)
--TRIPLE GAUSS   filters='lutyuv=.75*(negval-minval)+minval+(64*gauss((255-val)/(255-maxval)/1.7-1)-64*gauss(val/minval/1.5-1)+32*gauss(val/minval/1.5-2))/gauss(0),eq=saturation=1.1',  -- .6=exp(-.5)



