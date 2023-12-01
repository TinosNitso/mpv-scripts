----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV, WITH INSTANT DOUBLE-mute TOGGLE. APPLIES ANY LIST OF FILTERS (lutyuv FORMULA) TO MASKED REGION, WITH MOVING POSITIONS, ROTATIONS & ZOOM. INVERTS/TOGGLES. FULLY PERIODIC FOR BEST RES & PERFORMANCE. IT'S LIKE OPTOMETRY FOR TELEVISION, BUT SOME MASKS ARE PURELY DECORATIVE.
----WORKS WITH JPG, PNG, GIF, BMP, MP3 COVER ART, MP4 ETC, IN SMPLAYER & MPV (DRAG & DROP). .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP, PDF OR TXT. LOAD TIME SLOW DUE TO LACK OF BUFFERING. WITHOUT autocomplex (JPEG ANIME) A STILL FRAME USES 0% CPU. CHANGING vid TRACKS (MP3TAG) SUPPORTED.     
----FILTERS HELP DETECT DEFECTS, LIKE HAIR ON PASSPORT SCAN. THE LENS CAN TAKE ON THE FORM OF A MASK. NO FANCY TITLE OR CLOCK IN THIS SCRIPT. SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). TO REPRODUCE AN automask, SIMPLY COPY/PASTE PLAIN TEXT .LUA SCRIPT, FROM WEB BROWSER TO VIRTUAL MACHINE, ETC, WITHOUT ANY GRAPHICS FILE.    
----LENS lutyuv FORMULA USES A QUARTIC REDUCTION +- gauss CORRECTIONS FOR BLACK-IS-BLACK & WHITE-IS-WHITE. COLORS USE QUARTER POWER LAW FOR NON-LINEAR SATURATION. A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER. gauss SIZES ARE APPROX minval*2 SHIFTED 1.5x, BUT TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. 
local options={ --ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATION).      nil & false → DEFAULT VALUES    (BUT BLANK string ''=true).
    FILTERS='lutyuv=minval+(maxval-minval)*((negval/maxval)^4*(1+1/5)+1/5*(2*gauss((255-val)/(255-maxval)/1.5-2)-1*gauss(val/minval/1.5-1.5))/gauss(0))'   --negval/minval APPROX= (255-val)/(255-maxval)
                 ..':128*(1+(val/128-1)/abs(val/128.01-1)^.25)'   --u & v USE A POWER LAW NON-LINEAR SATURATION. sqrt ("^.5") TOO POWERFUL, SO CAN DIVIDE BY "^.25". GREYSCALE IS CENTERED ON 128 NOT 127.5 (128 MEANS 0 IN POPULAR YUV COVERSION FORMULAS).     RUNNING THE SCRIPT TWICE (DOUBLE MASK) ADDS MORE COLOR (MYSTERY).
                 ..':128*(1+(val/128-1)/abs(val/128.01-1)^.25)'   --sgn FUNCTION NOT LINUX snap COMPATIBLE, HENCE 128.01 ISSUE. THIS FILTERS MOVES PERCENTAGE saturation INTO NON-LINEAR EXPONENT (uv INSTEAD OF rgb).
         ..',null',                                               --CAN REPLACE null WITH OTHER FILTERS, LIKE pp (POSTPROCESSING). TIMELINE SWITCHES ALSO (FILTER1→FILTER2→ETC).
    
    fps    =   25, --DEFAULT=25 FRAMES PER SECOND. fps SHOULD MATCH OTHER SCRIPTS (autocomplex) FOR SIMPLICITY. 
    period =19/25, --DEFAULT=0 SECONDS (LEAD-FRAME ONLY). USE EXACT fps RATIO TO MATCH t & in. 19/25=79BPM (BEATS PER MINUTE). SHOULD MATCH OTHER SCRIPT/S, E.G. autocomplex (SYNCED EYES & MOUTH).  FOR BEST QUALITY (HD*2), ALL TIME DEPENDENCE IS PERIODIC.  UNFORTUNATELY A SLOW ANIMATION IS SLOW TO LOAD (REDUCE RES_MULT).
    periods=    2, --DEFAULT=1, INTEGER. INFINITE loop OVER period*periods.  0 period OR periods FOR STATIC. E.G. INVERT BRIGHTNESS EVERY 3 PERIODS.       
    
    INVERT='1-between(t/%s\\,.5\\,1.5)',    --DEFAULT='0' (NO BLINKING). %s=period  TIMELINE SWITCH FOR INVERTING INSIDE/OUTSIDE FILTERING (BLINKER SWITCH). E.G. TO START OPPOSITE, USE "1-...". THIS ONE BLINKS @BOTTOM.
    -- DISABLE='1-between(t/%s\\,.5\\,1.5)',--DEFAULT='0'. UNCOMMENT FOR INVISIBILITY. %s=period  TIMELINE SWITCH FOR MASK.     AN ALTERNATIVE CODE WOULD BE TO PLACE THIS *BEFORE* THE INVERTER, SO THE DISABLER ITSELF CAN BE INVERTED.
    
    SECTIONS=6,    --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights. MAY LIMIT NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.
    DUAL    =true, --REMOVE FOR LEFT-ONLY. ENABLES LEFT→RIGHT FLIP, & HALVES INITIAL iw (display CANVAS).
    -- SQUARE=true,--FOR RECTANGULAR SECTIONS, INSTEAD OF DISCS. 
    
    widths ='iw*1.1    iw*.6', --iw=INPUT-WIDTH  AUTO-GENERATES IF ABSENT. BASED ON display CANVAS. DEFAULT ELLIPTICITY=0 (CIRCLE/SQUARE)     REMOVE THESE 5 LINES TO AUTO-GENERATE DISCS. 
    heights='ih/2      ih*.5 ih          ih/2           ih/8', --ih=INPUT-HEIGHT   EXACT POSITIONING IS TRIAL & ERROR. PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS COVERING INNER PUPIL IS SQUINTING, BUT ONLY COVERING OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE,6=INNER-NERVE.
    x='-W/64*(s)       W/64 W/16*(1+(c)) W/32*(c)       W/64', --(c),(s) = (cos),(sin) WAVES IN t/period. overlay COORDS FROM CENTER=DEFAULT. W IS THE BIGGER DISC/CANVAS, & w IS THE DISC.  (t)=(time) (n)=(frame#) (p)→(period) (c)→(cos(2*PI*(t)/(p))) (s)→(sin(2*PI*(t)/(p))) (T)→((t)/(p))   %s=period=(p)
    y='-H*((c)/16+1/6) H/16 H/32*(s)     H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD (NEGATIVE MEANS UP).  (c),(s) = (cos),(sin)      %s=period
    crops='iw:ih*.8:0:ih-oh  iw*.98:ih:0',   --DEFAULT NO crop. SPECTACLE-TOP & RED-EYE CROPS CLEAR MASK'S TOP & MIDDLE. oh=OUTPUT-HEIGHT  crops GO BEFORE x & y. 
    
    rotations='PI/16*(s)*mod(floor((t)/%s)\\,2)  PI/32*(c)  -PI/64*(c)',       --%s=period (USE t NOT n). DEFAULT='0'. RADIANS CLOCKWISE. CROPS @t,n=0,0 SO USE cos TO AVOID CLIPPING.  PI/32=.1RADS=6° (QUITE A LOT)    SPECIFIES ROTATION OF EACH DISC, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL (& MAY NEED INCREASED RES_SAFETY).
    zoompan  ='1+.2*(1-cos(2*PI*((in)/%s-.2)))*mod(floor((in)/%s-.2)\\,2):0:0',--%s=FRAMES-PER-PERIOD=fps*period  (zoom:x:y)  in=INPUTFRAME#=on=OUTPUTNUMBER  mod IS AN ON/OFF SWITCH. DILATING PUPILS NOT CURRENTLY SUPPORTED.     20% FOR RIGHT PUPIL TO PASS SCREEN EDGE.
    
    RES_MULT  =  2, --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER LOAD. HD*2 FOR SMOOTHER ROTATIONS @HD.
    RES_SAFETY=1.1, --DEFAULT=1 (MINIMUM)   rotation RESOLUTION MULTIPLIER TO ENSURE ROTATIONS NEVER CLIP (SAME IN X & Y). @HD*2 THIS ADDS MANY BLACK (BLANK) PIXELS WHICH ARE DISCARDED.   E.G. REDUCE TO 1.01 (1%) FROM 1.1 (10%) TO SEE THE EFFECT OF CLIPPING.
    
    -- LEAD_T=1/25,      --DEFAULT=0 SECONDS. LEAD TIME FOR SYNC OF MASK WITH OTHER FILTERS/GRAPHS. CAN LEAD IN FRONT OF OTHER GRAPHS.
    -- t=5/25, n=5,      --UNCOMMENT FOR STATIONARY SPECTACLES. SUBSTITUTIONS FOR (t) & (n)=(in). MAY CHOOSE A SPECIFIC TIME OF FAV. ANIME. DOESN'T APPLY TO INVERT & DISABLE.
    -- periods_skipped=1,--DEFAULT=0, INTEGER. LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS, PER loop. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOES NOT APPLY TO INVERT & DISABLE. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY COORD, ETC.
    -- scale={1680,1050},--NEEDED IN LINUX FOR PERFECT CIRCLES ON FINAL display. DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX).  USES CLOSEST MULTIPLES OF 4 (ceil).
    
    ----10 EXAMPLES: 0) NULL 1) BLINKING MONACLE/SQUARE  2) BINACLES  3) OSCILLATING VISOR  4) BUTTERFLY SWIM  5) DOUBLE-TWIRL & SKIP  6) 10*ZOOMY DISCS  7) ELLIPTICAL VISOR  8) SCANNING VISOR (SIDEWAYS)  9) FALLING VISOR.         UNCOMMENT LINES TO ACTIVATE. USERS CAN ALSO COPY-PASTE PARTS OF THESE. nil IS SAFER THAN ''.
    -- SECTIONS=0,periods=0, --NULL OVERRIDE. CALIBRATE FILTERS USING TOGGLE.  CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y='H*.002',crops=nil,   --UNCOMMENT FOR MONACLE (ROTATING). FOR SQUARE, APPEND rotations=nil,y=nil,SQUARE=true,   DISC ih SHORT OUT OF FEAR OF OVER-CROPPING DISCS, & y OFF BY APPROX .2%. SECTIONS>1 FOR CONCENTRIC CIRCLES.
    -- zoompan=nil,SECTIONS=1,widths='iw*1.02',heights=nil,x=nil,y=nil,crops=nil,   --BINACLES. 2% EXTRA FOR TOUCH.
    -- SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,SQUARE=true, --VISOR OSCILLATING UP & DOWN.
    -- zoompan=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,y='-(H+h)*(t/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/64*cos(2*PI*(t))',     --BUTTERFLY SWIMMING UPWARDS EVERY 4 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND. THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). (t) FOR rotations.
    -- zoompan=nil,periods=3,periods_skipped=1,INVERT='gte(t\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',    --2 TWIRLS & SKIP: INVERT OUTSIDE WHEN TWIRLING.
    -- SECTIONS=10,INVERT=nil,widths='iw+1',heights=nil,x=nil,y=nil,crops=nil,     --CONCENTRIC DISCS. SET SQUARE=true FOR SQUARES (PROOF width IS OFF BY 1p).
    -- SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil,   --DANCING VISOR: HORIZONTAL ELLIPSE. rotations WORK WELL WITH CURVES.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,widths='iw/3',heights='ih',x='(W+w)*(t/%s-1/2)',y=nil,crops=nil,rotations=nil,SQUARE=true, --VERTICAL VISOR, SCANNING TIME 4 SECONDS.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,periods=1,period=4,INVERT=nil,widths='iw',heights='ih/3',x=nil,y='(H+h)*(t/%s-1/2)',crops=nil,rotations=nil,SQUARE=true, --HORIZONTAL VISOR @4 SECONDS.
    
    key_bindings         ='F2',--DEFAULT='' (NO TOGGLE). CASE SENSITIVE. M IS MUTE SO CAN DOUBLE-PRESS M FOR MASK. key_bindings DON'T WORK IN SMPLAYER. 'F2 F3' FOR 2 KEYS. F1 MAY BE autocomplex, WHICH GOES BEFORE automask.
    toggle_on_double_mute=.5,  --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED BY DOUBLE mute. M&M SHOULD BE THE MASK, BUT autocrop IS MORE FUNDAMENTAL.
    -- osd_on_toggle     ='af\n%s\n\nvf\n%s\n\nlavfi-complex?\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICKING MUTE ENABLES CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
   
    config={
            'osd-font-size 16','osd-border-size 1','osd-scale-by-window no', --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
            'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL SIZE.
            'image-display-duration inf','video-timing-offset 1', --STOPS IMAGES FROM SNAPPING MPV. DEFAULT offset=.05 SECONDS ALSO WORKS.
            'hwdec auto-copy','vd-lavc-threads 0',    --IMPROVED PERFORMANCE FOR LINUX .AppImage.  hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
            'pause yes',  --RETURNS INITIAL PAUSED STATE. EMBEDDED MPV MAY SNAP IF IT ISN'T PAUSED BEFORE A GRAPH'S INSERTED.
           },       
}
local o,label = options,mp.get_script_name() --ABBREV. options, GRAPH label='automask' 
local p,unpause = o.period,not mp.get_property_bool('pause') --ABBREV. & PAUSED STATE.

if o.DUAL then o.DUAL=2 end --1 OR 2.  CONVERT BOOL INTO NUMBER OF REFLECTIONS (+1).
for key,val in pairs(o) do if val=='' then o[key]=nil end end   --LUA INTERPRETS ''→true. BUT IT MAY MEAN DEFAULT FOR automask OPTIONS (0TH ROTATION MUST BE 0, ETC).

for key,val in pairs({FILTERS='lutyuv=negval',fps=25,periods=1,DUAL=1,INVERT='0',DISABLE='0',x='0',y='0',rotations='0',zoompan='1:0:0',RES_MULT=1,RES_SAFETY=1,LEAD_T=0,periods_skipped=0,scale={},key_bindings='',toggle_on_double_mute=0,config={}})
do if not o[key] then o[key]=val end end      --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command('no-osd set '..option) end    --APPLY config.
if mp.get_property('vid')=='no' then exit() end    --NO VIDEO→EXIT.

if not p or p==0 or o.periods==0 then p,o.periods,o.INVERT,o.DISABLE = 1/o.fps,1,'0','0'   --OVERRIDE: NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('%g') do if not o[nt] then o[nt]=0 end end end     --SET SPECIFIC t OR n.
o.periods_skipped=math.min(o.periods_skipped,o.periods) --MAX-SKIP = periods

for key in ('INVERT DISABLE x y rotations'):gmatch('%g+') do o[key]=o[key]:format(p,p,p,p,p,p,p,p) end  --%s=p    BLINKER SWITCH, INVISIBILITY, POSITIONS & ROTATIONS.
local FP=o.fps*p --FRAMES/PERIOD.
o.zoompan=o.zoompan:format(FP,FP,FP,FP,FP,FP,FP,FP) --%s=FP

for pTcs,SUB in pairs({p='%s',T='(t)/(%s)',c='cos(2*PI*(t)/(%s))',s='sin(2*PI*(t)/(%s))'}) do for xyr in ('x y rotations'):gmatch('%g+') do if o[xyr]   --period, SCALED TIME, COS & SIN SUBSTITUTIONS.
        then o[xyr]=o[xyr]:gsub('%('..pTcs..'%)',SUB:format(p)) end end end     --%s=period
for nt in ('n t'):gmatch('%g') do if o[nt] then for xyr in ('x y rotations'):gmatch('%g+') do if o[xyr]   --SUB IN SPECIFIC TIME OR FRAME#.
            then o[xyr]=o[xyr]:gsub('%('..nt..'%)','('..o[nt]..')') end end end end
if o.n then o.zoompan=o.zoompan:gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') end   --on=in (OUTPUT FRAME NUMBER)

local g={w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} --g=GEOMETRY TABLE. CONVERT STRINGS→TABLES, INSIDE g.
for key,option in pairs(g) do g[key]={} --INITIALIZE w,h,x,y,...
    if o[option] then for opt in o[option]:gmatch('%g+') do table.insert(g[key],opt) end end end
if not g.rots[1] then g.rots[1]='0' end     --0TH ROTATION IS SPECIAL & MUST BE DEFINED.

if not o.SECTIONS then for _,__ in pairs(g.w) do N=_ end  --DETERMINE SECTIONS COUNT, IF NECESSARY, BEFORE AUTO-CENTERING ETC.
     for _,__ in pairs(g.h) do if _>N then N=_ end end
     o.SECTIONS=N end
if not o.SECTIONS or o.SECTIONS==0 then g.w,g.h,g.x,g.y,g.crops,g.rots,o.SECTIONS,o.DUAL,o.SQUARE,o.zoompan = {'0'},{'0'},{},{},{},{'0'},1,1,true,'1:0:0' end    --0→iw & ih. DEFAULT TO (BLINKING?) FULL SCREEN NEGATIVE.

local blur,N,MASK = '',0,'%s' --blur INITIALIZES CIRCLE FROM SQUARE. N>=0 IS SECTION #. MASK IS GENERATED RECURSIVELY, FROM %s. rotate COUPLES WITH zoompan, AFTER DUAL.
if not o.SQUARE then blur=',avgblur,scale=iw*2:-1:bicubic,split[1],rotate=PI/4[2],[1][2]lut2=x*y/255,split[1],rotate=PI/8[2],[1][2]lut2=x*y/255' end  --DRAW CIRCLE BEFORE MASK. MAY USE INTERMEDIATE scale FOR 22.5° & 45° ROTATIONS. REMOVING THIS PRODUCES PERFECT SQUARES. A THIRD PI/16 ROTATION MAY BE USED FOR SMOOTHER MONACLE.

while N<o.SECTIONS do N=N+1 --MASK CONSTRUCTION, BEFORE DUAL.
    if not g.w[N] and not g.h[N] then if N==1 then g.w[N]='iw'    --AUTO-GENERATOR. N=1 FULL-SIZE.
        else g.w[N]=('iw*%d/%d'):format(1+o.SECTIONS-N,2+o.SECTIONS-N) end end    ----EQUAL REDUCTION TO EVERY REMAINING SECTION.
    if not g.w[N] then g.w[N]='oh' end  --w & h MUST BE DEFINED. SET w=h FOR CIRLES/SQUARES ON FINAL DISPLAY.
    if not g.h[N] then g.h[N]='ow' end

    for xy in ('x y'):gmatch('%g') do if not g[xy][N] then g[xy][N]='' end end --x & y MUST BE DEFINED.
    if N==1 then if o.DUAL==2 then g.x[1]=('%s+W*(%s-1)/2'):format(g.x[1],o.RES_SAFETY) end --TO ENSURE DUAL rotations ARE SAFE, SHIFT HALF-WAY THE DIFFERENCE TO THE RIGHT (ON THE LEFT MONACLE).
        for whxy in ('w h x y'):gmatch('%g') do for whWH in ('iw ih W H'):gmatch('%g+') do g[whxy][1]=g[whxy][1]:gsub(whWH,('(%s/(%s))'):format(whWH,o.RES_SAFETY)) end end end --MUST SCALE N=1 iw,ih,W,H BY SAFETY FACTOR. 0TH ROTATION GLITCH-FIX. ALL ROTATIONS WITHOUT SHEAR & WITHOUT CLIPPING. PERFECTLY CIRCULAR PUPIL/S FOR BOTH BINACLES & MONACLE. x MAY DEPEND ON H, & y ON W, ETC.
    
    g.x[N]=g.x[N]..'+(W-w)/2' --AUTO-CENTER x & y BY DEFAULT, OTHERWISE overlay SETS TOP-LEFT (0).
    g.y[N]=g.y[N]..'+(H-h)/2'
    
    local NEWDISC,pre_overlay = '',''  --NEWDISC FOR N>1. THEN (POSSIBLY) crop & rotate.  OPTIONAL *post_overlay* WOULD BE pad BLACK & zoompan FOR DILATING PUPILS, BUT THAT WOULD REQUIRE MOVING THIS CODE AFTER file-loaded TO INSERT NUMBERS. crops, rotations & POSITIONS ARE ALL PURE ALGEBRA, BUT NOT zoompan.
    if g.crops[N] then pre_overlay=(',crop=%s'):format(g.crops[N]) end    --crop & rotate AFTER overlay (ACTUALLY DOES THE WHOLE LOT).
    if g.rots[N+1] and g.rots[N+1]~='0' then pre_overlay=('%s,rotate=%s:max(iw\\,ih):ow:BLACK@0'):format(pre_overlay,g.rots[N+1]) end   --pad SQUARE SO AS TO AVOID CLIPPING.
    
    if N>1  then NEWDISC=(',split[%d],scale=floor((%s)/4)*4:floor((%s)/4)*4%%s,lut=255-val'):format(N-1,g.w[N],g.h[N]) end  --split N-1 & scale. %%s IS FOR N=2. FLOORED MULTIPLES OF 4 WORK BEST (2 MAY CAUSE overlay CENTERING BUG). lut WORKS IN LINUX snap, BUT NOT negate (snap DOESN'T SUPPORT ALL FILTERS).
    if N==2 then NEWDISC=NEWDISC:format(',split,alphamerge') end   --N=2 TRANSPARENCY →ya16.
    MASK=MASK:format('%s%%s%s[%d],[%d][%d]overlay=%s:%s'):format(NEWDISC:format(''),pre_overlay,N,N-1,N,g.x[N],g.y[N]) end   --NEWDISC crop rotate & overlay. NEWDISC='' FOR N=1 (overlay ON [0]).
MASK=MASK:format('')..',format=y8' --REMOVE alpha AFTER FINAL overlay. MASK TERMINATOR %s=''. 
if o.DUAL==2 then MASK=MASK..',split[L],hflip[R],[L][R]hstack' end   --STARTING "," MAY BE MORE ELEGANT, TO MINIMIZE USE OF LABELS.

local lavfi=('%%s,scale=%%s:%%s,split=3[vo][T],%s[vf],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-(1/FRAME_RATE+%s)/TB,format=y8,split[T],setpts=0,crop=1:1,lut=0,split[0],pad=2:2,lut=255,pad=iw+2:ow:1:1:WHITE,pad=iw+2:ow:1:1:GRAY,pad=iw+2:ow:1:1%s[1],[0][T]scale2ref=oh*a/%d:ih*(%s)[0][T],[1][0]scale2ref=oh:ih*2.2:bicubic[1][0],[1]crop=iw/2.2:ow,lut=255*gt(val\\,74)[1],[1][0]scale2ref=%s:%s[1][0],[1]loop=%s:1%s[M],[M][T]scale2ref=oh*a:ih*(%s)[M][T],[M]loop=%d:2^14,loop=%s:1,rotate=%s:oh*iw/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:0:%%dx%%d:%s,lut=255-val:enable=%s,lut=0:enable=%s,loop=-1:2^14,setpts=PTS-(%s)/TB,select=gte(t\\,0)[M],[T][M]concat=unsafe=1,trim=start_frame=1,eq[M],[vf][M]alphamerge[vf],[vo][vf]overlay=0:0:endall,setsar=1')
    :format(o.FILTERS,o.LEAD_T,blur,o.DUAL,o.RES_MULT,g.w[1],g.h[1],p*o.fps-1,MASK,o.RES_SAFETY,o.periods-o.periods_skipped-1,p*o.periods_skipped*o.fps,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps,o.INVERT,o.DISABLE,p*o.periods)    --RES_SAFETY REPEATS FOR rotate TO CROP DOWN ON THE MASK EXCESS. fps REPEATS WHEN LOOPING LEAD FRAME. p REPEATS FOR SELECTOR & LEAD-SKIP. 

----lavfi  =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST.  vo=VIDEO-OUT.  SELECT FILTER NAME TO HIGHLIGHT IT (NO WORD-WRAP). %% SUBSTITUTIONS OCCUR LATER. NO audio ALLOWED (vf append). RE-USING LABELS IS SIMPLER. [vo] IS VIDEO-OUT. [vf] IS FORMULA-FILTERED VIDEO. [T] IS TIME METADATA FRAME. [0] IS CANVAS. [1] & [2] ARE DISC INITIALIZATION (SUPERPOSITION): THEN [1][2]...[N] ARE DISCS. [M] IS MASK. 
----lutyuv,lut      BRIGHTNESS-UV  DEFAULT=val RANGE [0,255]  negval & clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES NEAR 0 & 255). lutyuv MAY BE FASTER THAN lutrgb. lut FOR INVERT & DISABLE SWITCHES.  u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAS (SIGNED 8-BIT).        COMPUTES TABLE IN ADVANCE SO EFFICIENT. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----lut2    [1][2]→[1]  LOOK-UP-TABLE*2  GEOMETRICALLY COMBINES [1][2] avgblur CLOUDS. A SIMPLE overlay WOULDN'T WORK (x*y/255 BEATS (x+y)/2). sqrt(x*y) ALSO DOESN'T WORK (TRIAL & ERROR).
----null    PLACEHOLDER.
----fps    =fps     FRAMES PER SECOND LIMIT.
----split  =outputs CLONES video. MASK IS BASED ON THE 3RD, [T].
----alphamerge  [vf][M]→[vf]  USES lum OF MASK [M] AS alpha OF [vf]. SIMPLER THAN TRIMMING maskedmerge. WITH split, CONVERTS BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey & colorchannelmixer.
----trim   =...:start_frame:end_frame  TRIMS TIMESTAMP FRAME [T] TO RESTORE ITS TIME, & PREP CANVAS. A trim DOESN'T CHANGE PTS.
----setpts =expr    ZEROES OUT TIME FOR THE CANVAS, REMOVES THE FIRST TWIRL (NOT SMOOTH) & IMPLEMENTS LEAD_T AFTER INFINITE loop. SUBTRACT 1 FRAME FROM TIME [T], FOR ITS TIME TO APPLY TO WHATEVER FOLLOWS IT.
----select =expr    EXPRESSION DISCARDS FRAMES IF 0. REMOVES THE FIRST periods, WHICH ARE CHOPPY ON FINAL OUTPUT (MAYBE A buffer ISSUE). OPTIONAL PAIRING WITH trim FOR COMPATIBILITY WITH OLD MPV (MUST select FOR ONLY START FRAME).
----loop   =loop:size  (LOOPS>=-1 : FRAMES/LOOP>0) -1 FOR JPEG. LOOPS INITIAL DISC FRAME FOR period. THEN LOOPS TWIRL FOR periods-SKIP, THEN LEAD FRAME FOR SKIP, & THEN REPEATS zoompan INFINITE. LOOPED FRAMES GO FIRST. 1 PERFECT MASK CAN BE DONE INSTANTLY, BUT THE INFINITE loop WITHOUT buffer CAUSES STARTUP LAG.
----concat =...:unsafe  [T][M]→[M]  CONCATENATE INSERTS STARTING TIMESTAMP (WHENEVER USER SEEKS). TO MAKE ALL POSSIBLE CASES safe IS EASY BUT REQUIRES MORE CODE (setsar=1,keep_aspect=1 ETC).
----crop   =out_w:out_h:x:y:keep_aspect    DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0   SET keep_aspect FOR SAFE concat OF VIDEO BUILT FROM 1x1.  OVER-CROPPING DISC (THE 2.2) MAY CAUSE GRIZZLE AFTER DISC ROTATIONS. LINUX snap DOESN'T ALLOW oh BEFORE COMPUTING IT (USE ow INSTEAD OF oh).
----pad    =w:h:x:y:color  PREPS 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.   2x2/4x4 TOO SMALL. A LITTLE SQUARE IS LIKE A DISC WHO IS A LITTLE OFF & NEEDS A ROUND OF BLUR & SHARP.
----avgblur (AVERAGE BLUR) PAIRS WITH scale, TO SHARPEN A CIRCLE FROM BRIGHTNESS. ACTS ON 4x4/8x8 SQUARE. REMOVE FOR DIAGONAL-CUT RECTANGLES.   ALTERNATIVES INCLUDE gblur & boxblur.
----scale,scale2ref=width:height:flags   [1][vf]→[1][vf]  2REFERENCE SCALES [1]→[1] USING DIMENSIONS OF [vf]. FORMS PAIR WITH overlay.  bicubic FOR LINUX snap COMPATIBILITY. ITS DEFAULT IS bilinear WHICH FAILS, BUT bicubic spline lanczos ARE ALL VALID. bicubic ALSO STANDARD ON LINUX, BUT NOT snap. CONVERT TO SCREEN SIZE BECAUSE OF zoompan. ONLY USE MULTIPLES OF 4 BECAUSE OF AN overlay BUG (OFF BY 1 FOR 1050p). PREPARES EACH DISC FROM THE LAST, & INITIALIZES 2048p DISC.     SCALES TO 2.2x BIG DISC, CALIBRATED WITH lut>74.  THE IDEA IS TO scale,crop A TINY SYMMETRIC BLUR TO HALF-10%, TO lut A DECENT CIRCLE. IN MS PAINT A PERFECT CIRCLE SHOULD INSCRIBE A MONACLE SCREENSHOT. SOMETIMES A SMOOTHER CIRCLE MAY BE MORE OBLONG. geq (GLOBAL EQUALIZER) IS TOO SLOW, BUT CAN DRAW ANY FORMULA - NOT JUST CIRCLES.
----overlay=x:y:eof_action  [N-1][N]→[N-1]  (DEFAULT 0:0:repeat) endall ENDS MORE ABRUPTLY. MAY PAIR WITH scale2ref. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.
----rotate =angle:ow:oh:fillcolor  (RADIANS:PIXELS CLOCKWISE) ROTATES EACH DISC, BEFORE FINAL scale2ref. PI/4 & PI/8 HELP PREPARE INITIAL DISC (MAY USE INTERMEDIATE scale, TOO). THE 0TH (DUAL zoompan) ROTATION IS SPECIAL.
----zoompan=zoom:x:y:d:s:fps  (z>=1) d=0 FRAMES DURATION-OUT PER FRAME-IN.
----eq     =...:brightness  DEFAULT 0  RANGE [-1,1]  EQUALIZER.  INSTANT SNAP-FREE TOGGLE ON & OFF, DIRECTLY FROM LUA. eq MAY ALSO BE USED IN FILTERS, BUT NOT ITS brightness - THAT'S STRICTLY FOR THE REMOTE CONTROL.
----format =pix_fmts   CONVERTS TO y8=8-BIT BRIGHTNESS (MOST EFFICIENT).
----setsar =sar  (ASPECT RATIO)  IS THE FINISH. STOPS EMBEDDED MPV SNAPPING WINDOW ON vid CHANGE. MACOS BUGFIX REQUIRES sar.


function file_loaded()
    W,H = o.scale[1],o.scale[2]
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end    --WINDOWS & MACOS.
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end   --USE [vo] SIZE (LINUX).
    if not (W and H) then mp.add_timeout(.05,file_loaded)   --LINUX FALLBACK: RE-RUN & return. DUE TO EXTREME LAG IN VIRTUALBOX.
        return end
    W,H,fps = math.ceil(W/4)*4,math.ceil(H/4)*4,'fps='..o.fps    --BUGFIX: MULTIPLES OF 4 NECESSARY FOR PERFECT overlay.
    
    if mp.get_property_bool('current-tracks/video/image') then fps='null' end --fps=null FOR 1 FRAME ONLY (is1frame). IF THERE'S A LOOPING complex, THE fps MUST (OTHERWISE) MATCH, FOR SYNCHRONY.  JPEG (NO loop) OVERRIDE USES 0% CPU. IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. 
    mp.command(('no-osd vf append @%s:lavfi=[%s]'):format(label,lavfi):format(fps,W,H,W,H))     --INSERT GRAPH. IT GOES AFTER autocrop. W,H REPEAT FOR zoompan.
    
    if unpause then mp.command('set pause no') end  --RETURN PAUSED STATE.
    unpause=false
end
mp.register_event('file-loaded',file_loaded)

function on_vid(_,vid)  --RE-LOADS IF CHANGE IN vid DETECTED. AN MP3 MAY BE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED MASK.
    if not OFF and last_vid and last_vid~=vid then file_loaded() end    --UNFORTUNATELY THIS SNAPS EMBEDDED MPV.
    last_vid=vid
end
mp.observe_property('current-tracks/video/id','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.

local timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --DOUBLE mute timer DEFINED BEFORE TOGGLE. IT CARRIES OVER TO NEXT video IN MPV PLAYLIST.
timer.oneshot=true 
timer:kill()

function on_toggle(mute)
    if mute=='mute' and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.
        return end  --TOGGLE BELOW.
        
    OFF,command = not OFF,('vf-command %s brightness '):format(label)  --vf-command SMOOTHLY TOGGLES automask DIRECTLY FROM LUA.   IDEAL POSITIONING SYSTEM MAYBE LIKE GAMEPAD→vf-command, BUT THIS automask ISN'T THAT GOOD.
    if not OFF then command=command..'0'      --ON  brightness=0 
    else            command=command..'-1' end --OFF brightness=-1 
    mp.observe_property('seeking','bool',function() mp.command(command) end)  --TRIGGERS INSTANTLY, & ON seeking BECAUSE THAT RESETS GRAPH STATE.

    if fps=='null' then mp.command('no-osd vf toggle @'..label) end --JPEG: VERIFY USING "F2" TOGGLE, OR DOUBLE-mute. ALSO WORKS IN TANDEM WITH autocrop. MPV SNAPS JPEG IF IT HAS ITS OWN WINDOW (A REPLACEMENT SNAP GRAPH WOULD REQUIRE AN EXTRA LINE OF CODE).
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
mp.observe_property('mute', 'bool', on_toggle)
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end



----COMMENTS SECTION (CODE EXAMPLES). MPV CURRENTLY HAS A 10 HOUR BACKWARDS SEEK BUG (BACKWARD BUFFER ISSUE?). 
----MASK REQUIRES EXTRA RAM 300MB. EG: 256MiB = 1680*1050*4*19*2/1024/1024 = display*yuva*19FRAMES*2periods/1KiB/1KiB   

----drawtext=...:expansion:...:text    NOT WORKING WITH WINDOWS directwrite, WITHOUT SPELLING OUT FULL PATHS TO SYSTEM FONT TYPE FILES.
----negate  =components  (y=lum)  FOR INVERT SWITCH. components MAY NOT BE LINUX snap COMPATIBLE.

--eq ONLY:          FILTERS='eq=-.5:0:1.1',  
--SINGLE SINE WAVE: FILTERS='lutyuv=minval+.75*(negval-minval+8*minval*sin(2*PI*(negval/minval-1)/4)),eq=saturation=1.2',    --PERIOD=AMPLITUDE/2.
--2 SINE WAVES:     FILTERS='lutyuv=minval+.75*(negval-minval)+4*minval*(sin(2*PI*(negval/minval-1)/4)*lt(negval/minval\\,2)+sin(2*PI*(negval-maxval)/minval/4)*lt((maxval-negval)/minval\\,4)),eq=saturation=1.2', 
--ASIN:             FILTERS='lutyuv=minval+255*asin(negval/maxval)^.5/PI*2,eq=saturation=1.2', 
--ASIN ASIN         FILTERS='lutyuv=255*asin(asin(negval/maxval)/PI*2)^.3/PI*2,eq=saturation=1.2', 
--SQRT+SQRT(1-X)    FILTERS='lutyuv=.8*255*(lt(negval\\,128)*(negval/maxval)^.5+gte(negval\\,128)*(1-negval/maxval)^.5),eq=saturation=1.2', 
--SIGNED POWERS     FILTERS='lutyuv=.8*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^abs(1-val/255/.5))),eq=saturation=1.1', 
--X^(1+X^2)         FILTERS='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(1+(2*abs(1-val/255/.5))^2)),eq=saturation=1.1', 
--X^(3^(X^2))       FILTERS='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^(abs(1-val/255/.5)^2))),eq=saturation=1.1', 
--50% DROP QUAD GAUSS FILTERS='lutyuv=minval+.4*(negval-minval+128/gauss(0)*(1*gauss((255-val)/(255-maxval)/.9-1)-.6*gauss((255-val)/(255-maxval)/.9-2)-1*gauss(val/minval/.9-1)+.6*gauss(val/minval/.9-2))),eq=1.2:0:1.2',  -- .6=exp(-.5)    negval/minval APPROX (255-val)/(255-maxval)
--QUAD-GAUSS        FILTERS='lutyuv=.75*(negval-minval)+minval+100/gauss(0)*(1*gauss((255-val)/(255-maxval)/2-1)-.6*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.7-1)+.6*gauss(val/minval/1.7-2)),eq=saturation=1.1',  -- .6=exp(-.5)
--TRIPLE GAUSS      FILTERS='lutyuv=.75*(negval-minval)+minval+(64*gauss((255-val)/(255-maxval)/1.7-1)-64*gauss(val/minval/1.5-1)+32*gauss(val/minval/1.5-2))/gauss(0),eq=saturation=1.1',  -- .6=exp(-.5)

--SNAP GRAPH ON SCRIPT LOAD? local lavfi='setsar=1'..o.format
-- if W and H then lavfi=('scale=%s:%s,%s'):format(W,H,lavfi) end  --OPTIONAL scale OVERRIDE: SNAP GRAPH STOPS EMBEDDED MPV SNAPPING.
-- mp.command(('no-osd vf append @%s:lavfi=[%s]'):format(label,lavfi))               --SAFEST TO PUT IN SNAP GRAPH TO COVER ALL CASES (JPEG ETC).



