----AUTO ANIMATED MASK GENERATOR & MERGE SCRIPT, FOR VIDEO & IMAGES, IN MPV, WITH DOUBLE-mute TOGGLE. APPLIES ANY LIST OF FILTERS (lutyuv FORMULA) TO MASKED REGION, WITH MOVING POSITIONS, ROTATIONS & ZOOM. INVERTS/TOGGLES. FULLY PERIODIC FOR BEST RES & PERFORMANCE.    
----WORKS WITH JPG, PNG, GIF, BMP, MP3 COVER ART, MP4 ETC, IN SMPLAYER & MPV. .TIFF ONLY DISPLAYS 1 LAYER (BUG). NO WEBP, PDF OR TXT. START/TOGGLE SLOW DUE TO LACK OF BUFFERING. RAW JPEG & COVER ART USE 0% CPU. (COMBINE automask WITH autocomplex.lua FOR JPEG ANIME). CHANGING TRACKS (MP3 TAGS) SUPPORTED.
----lutyuv formula USES A QUARTIC REDUCTION + gauss CORRECTIONS (FOR BLACK-IS-BLACK & WHITE-IS-WHITE). A BIG-SCREEN NEGATIVE IS TOO BRIGHT, SO INSTEAD OF HALVING BRIGHTNESS A QUARTIC IS SHARPER. gauss SIZES ARE minval*2 SHIFTED 1.5. TUNING EACH # SEEMS TOO DIFFICULT - TOO MANY VIDEOS TO CHECK. IT'S A STATISTICAL PROBLEM - HIT & MISS. ONE IDEA IS TO VARY THE formula WITH TIMELINE SWITCHES.
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS (A BIBLE HAS NO SCROLLBAR). NO TITLE OR CLOCK BECAUSE drawtext NOT WORKING IN WINDOWS (directwrite OR EXTRA FONT FILE?).  THE MASK HELPS DETECT DEFECTS, LIKE HAIR ON A PASSPORT SCAN. THE LENS formula MAY AS WELL TAKE ON THE FORM OF A MASK. TO REPRODUCE AN automask, PPL CAN SIMPLY COPY/PASTE PLAIN TEXT .LUA SCRIPT, FROM WEB BROWSER TO VIRTUAL MACHINE, ETC, WITHOUT ANY GRAPHICS FILE.
local options={ --ALL OPTIONAL & MAY BE REMOVED (FOR SIMPLE NEGATION).      nil & false → DEFAULT VALUES    (BUT BLANK string ''=true).
    formula='lutyuv=minval+(maxval-minval)*((negval/maxval)^4*(1+1/6)+1/6*(2*gauss(negval/minval/2-1.5)-1*gauss(val/minval/1.5-1.5))/gauss(0))'   --negval/minval APPROX= (255-val)/(255-maxval)
                ..':128*(1+(val/128-1)/abs(val/128.01-1)^.25)'   --u & v USE A POWER LAW NON-LINEAR SATURATION. sqrt ("^.5") TOO POWERFUL, SO CAN DIVIDE BY "^.25". GREYSCALE IS CENTERED ON 128 NOT 127.5 (128 MEANS 0 IN POPULAR YUV COVERSION FORMULAS).     RUNNING THE SCRIPT TWICE (DOUBLE MASK) ADDS MORE COLOR (MYSTERY). 2 FILTERS MAY SHARE THE SAME LABEL IF THEY append INSTANTLY.
                ..':128*(1+(val/128-1)/abs(val/128.01-1)^.25)',  --sgn FUNCTION NOT LINUX snap COMPATIBLE, HENCE 128.01 ISSUE. THIS formula MOVES PERCENTAGE saturation INTO NON-LINEAR EXPONENT (uv INSTEAD OF rgb).
                
    period =19/25,  --DEFAULT=0 SECONDS (LEAD-FRAME ONLY). USE EXACT fps RATIO, BECAUSE zoompan USES "in" NOT "t". 19/25=79BPM (BEATS PER MINUTE). SHOULD MATCH OTHER SCRIPT/S, E.G. autocomplex (SYNCED EYES & MOUTH).  FOR BEST QUALITY (HD*2), ALL TIME DEPENDENCE IS PERIODIC.  UNFORTUNATELY A SLOW ANIMATION TAKE AGES TO LOAD (REDUCE RES_MULT).
    periods=2,      --DEFAULT=1, INTEGER. INFINITE loop OVER period*periods.  0 period OR periods FOR STATIC. E.G. INVERT BRIGHTNESS EVERY 3 PERIODS.       
    
    INVERT='1-between(t/%s\\,.45\\,1.45)',      --DEFAULT='0'. REMOVE FOR NO BLINKING. %s=period  TIMELINE SWITCH FOR INVERTER (BLINKING). THIS EXAMPLE BLINKS PERIODICALLY NEAR FULL SWING, LIKE A BASEBALL BAT HITTING A BALL @90% SWING. INVERTS INSIDE/OUTSIDE FILTERING. E.G. TO START OPPOSITE, USE "1-..."
    -- DISABLE='1-between(t/%s\\,.45\\,1.45)',  --DEFAULT='0'. %s=period  INVISIBILITY SWITCH (UNCOMMENT TO SEE).   TIMELINE SWITCH FOR MASK. A MORE POWERFUL CODE WOULD BE TO PLACE THIS *BEFORE* THE INVERTER, SO THE DISABLER ITSELF CAN BE INVERTED.
    
    SECTIONS=6,     --0 FOR BLINKING FULL SCREEN. DEFAULT COUNTS widths & heights. MAY LIMIT NUMBER OF DISCS (BEFORE FLIP & STACK). AUTO-GENERATES DISCS IF widths & heights ARE MISSING. ELLIPTICITY=0 BY DEFAULT.
    DUAL    =true,  --REMOVE FOR MONACLE. ENABLES LEFT→RIGHT FLIP. HALVES DISC_RES.    BINACLES FROM MONACLE split hflip hstack     
    -- SQUARE=true, --FOR RECTANGULAR SECTIONS, INSTEAD OF DISCS. 
    
    widths ='iw*1.1 ih',                --iw=INPUT-WIDTH oh=OUTPUT-HEIGHT. BASED ON SCREEN CANVAS. DEFAULT=CIRCLE/SQUARE(ELLIPTICITY=0)     REMOVE THESE 6 LINES TO AUTO-GENERATE DISCS.     WORK IN PROGRESS BECAUSE WE MAY WANT TO RANDOMIZE AUTO-MASK (NEW MASK FOR EVERY VIDEO).
    heights='ih/2.2 ih/2 ih ih/2 ih/8', --ih=INPUT-HEIGHT   EXACT POSITIONING IS TRIAL & ERROR (INITIAL oh=ih SLIGHTLY SHORT). PUPILS SHOULD BE CIRCLE WHEN SEEN THROUGH SPECTACLES. EYELIDS OVER PUPIL IS SQUINT, BUT OVER OUTER-PUPIL IS LAZY-EYE.  SECTIONS: 1=SPECTACLE,2=EYELID,3=EYE,4=PUPIL,5=NERVE
    x='-W/64*(s)       W/16 W/16*(c) W/32*(c)       W/64', --(c),(s) = (cos),(sin) WAVES IN t/period. overlay COORDS FROM CENTER=DEFAULT. W IS THE BIGGER DISC/CANVAS, & w IS THE DISC.  (t)=(time) (n)=(frame#) (p)→(period) (c)→(cos(2*PI*(t)/(p))) (s)→(sin(2*PI*(t)/(p))) (T)→((t)/(p))   %s=period=(p)
    y='-H*((c)/16+1/6) H/16 H/32*(s) H/32*((c)+1)/2 H/64', --DEFAULT CENTERS, DOWNWARD.  (c),(s) = (cos),(sin)  NEGATIVE MEANS UP.    %s=period
    crops='iw:ih*.8:0:ih-oh  iw*.99:ih:0',   --DEFAULT NO crop. SPECTACLE-TOP & RED-EYE CROPS. oh=OUTPUT-HEIGHT  crops GO BEFORE x & y. 
    
    rotations='PI/16*(s)*mod(floor((t)/%s)\\,2)  PI/32*(c)  -PI/64*(c)',        --%s=period (USE t NOT n). DEFAULT='0'. RADIANS CLOCKWISE. CROPS @t,n=0,0 SO USE cos TO AVOID CLIPPING.  PI/32=.1RADS=6° (QUITE A LOT)    SPECIFIES ROTATION OF EACH DISC, RELATIVE TO THE LAST, AFTER crop, EXCEPT THE FIRST (0TH) ROTATION WHICH APPLIES TO ENTIRE DUAL. INCREASE RES_SAFETY FOR BIGGER rotations.
    zoompan  ='1+.18*(1-cos(2*PI*(in)/%s))*mod(floor((in)/%s)\\,2):0:0',    --%s=FRAMES-PER-PERIOD=fps*period  (zoom:x:y)  in=INPUT FRAME #=on  mod IS AN ON/OFF SWITCH. DILATING PUPILS NOT CURRENTLY SUPPORTED.     18% FOR RIGHT PUPIL TO PASS SCREEN EDGE.
    
    RES_MULT  =2,       --DEFAULT=1. RESOLUTION MULTIPLIER (SAME FOR X & Y), BASED ON display. REDUCE FOR FASTER LOAD. HD*2 FOR SMOOTHER ROTATIONS @HD.
    RES_SAFETY=1.1,     --DEFAULT=1 (MINIMUM)   rotation RESOLUTION MULTIPLIER TO ENSURE ROTATIONS NEVER CLIP (SAME IN X & Y). @HD*2 THIS ADDS MANY BLACK (BLANK) PIXELS WHICH ARE DISCARDED.   E.G. REDUCE TO 1.01 (1%) FROM 1.1 (10%) TO SEE THE EFFECT OF CLIPPING.
    
    -- LEAD_T = 1/25,       --DEFAULT=0 SECONDS. LEAD TIME FOR SYNC OF MASK WITH OTHER FILTERS/GRAPHS. CAN LEAD IN FRONT OF OTHER GRAPHS.
    -- t=5/25, n=5,         --UNCOMMENT FOR STATIONARY SPECTACLES. SUBSTITUTIONS FOR (t) & (n)=(in). MAY CHOOSE A SPECIFIC TIME OF FAV. ANIME. DOESN'T APPLY TO INVERT & DISABLE.
    -- periods_skipped=1,   --DEFAULT=0, INTEGER. LEAD FRAME ONLY (NO TIME DEPENDENCE) FOR THESE STARTING PERIODS, PER loop. (A BIRD MAY ONLY FLAP ITS WINGS HALF THE TIME, BUT FASTER.) DOES NOT APPLY TO INVERT & DISABLE. SIMPLIFIES CODING ON/OFF MOVEMENT, WITHOUT PUTTING mod IN EVERY COORD, ETC.
    -- msg_on_toggle = 'af\n%s\n\nvf\n%s',  --SET TO '' TO CLEAR osd. CAN DISPLAY af & vf osd_message AFTER TOGGLE. %s=string.     THIS SCRIPT'S TOGGLE CAN DISPLAY ALL ACTIVE FILTERS.
    
    ----10 EXAMPLES: 0) NULL 1) BLINKING MONACLE  2) BINACLES  3) OSCILLATING VISOR  4) BUTTERFLY SWIM  5) DOUBLE-TWIRL & SKIP  6) FALLING DISCS  7) ELLIPTICAL VISOR  8) SCANNING VISOR (SIDEWAYS)  9) FALLING VISOR.         UNCOMMENT LINES TO ACTIVATE. USERS CAN ALSO COPY-PASTE PARTS OF THESE. nil IS SAFER THAN ''.
    -- SECTIONS=0,periods=0, --NULL OVERRIDE. CALIBRATE formula USING TOGGLE. MASK SLOWS DOWN TOGGLE.   CHECK A FEW THINGS: 1) BROWN SUN, NOT BLACK. 2) BRIGHT CLOTHING OF MARCHING ARMY (CREASES IN PANTS). 3) BROWN HAMMER & SICKLE.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,widths=nil,heights='ih',x=nil,y=nil,crops=nil,rotations=nil,   --FOR MONACLE UNCOMMENT THIS LINE.  ih SHORT OUT OF FEAR OF OVER-CROPPING DISCS. SQUARE=true FOR PERFECT SQUARE ON FINAL display.    SECTIONS>1 FOR CONCENTRIC CIRCLES. 
    -- zoompan=nil,SECTIONS=1,widths='iw*1.02',heights=nil,x=nil,y=nil,crops=nil,rotations=nil,   --BINACLES. 2% EXTRA FOR TOUCH.
    -- SECTIONS=1,DUAL=nil,crops=nil,rotations=nil,SQUARE=true, --VISOR OSCILLATING UP & DOWN.
    -- zoompan=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,y='-(H+h)*(t/%s-1/2) H/16 0 H/64 H/64',rotations='-PI/32*cos(2*PI*(t)) PI/32*cos(2*PI*(t)) -PI/64*cos(2*PI*(t))',     --BUTTERFLY SWIMMING UPWARDS EVERY 4 SECONDS, WHILE TWIRLING 1 ROUND-PER-SECOND. THE ROTATION IS OPPOSITE WHEN SWIMMING (VS TREADING). (t) FOR rotations.
    -- zoompan=nil,periods=3,periods_skipped=1,INVERT='gte(t\\,%s)',y='-H*((c)/16+1/16) H/16 H/32*(s) H/32*((c)+1)/2 H/64',    --2 TWIRLS & SKIP: INVERT OUTSIDE WHEN TWIRLING.
    -- zoompan=nil,SECTIONS=10,period=2,widths=nil,heights=nil,x=nil,y='(H+h)*(t/%s-1/2)',crops=nil,rotations=nil,     --FALLING CONCENTRIC DISCS @10 SECONDS. SET SQUARE=true FOR SQUARES.
    -- SECTIONS=1,DUAL=nil,widths='iw*2',x=nil,y='-H/8',crops=nil,   --DANCING VISOR: HORIZONTAL ELLIPSE. rotations WORK WELL WITH CURVES.
    -- SECTIONS=1,DUAL=nil,periods=1,period=4,RES_MULT=1,INVERT=nil,widths='iw/3',heights='ih',x='(W+w)*(t/%s-1/2)',y=nil,crops=nil,rotations=nil,SQUARE=true, --VERTICAL VISOR, SCANNING TIME 4 SECONDS.
    -- zoompan=nil,SECTIONS=1,DUAL=nil,periods=1,period=4,INVERT=nil,widths='iw',heights='ih/3',x=nil,y='(H+h)*(t/%s-1/2)',crops=nil,rotations=nil,SQUARE=true, --HORIZONTAL VISOR @4 SECONDS.
    
    fps   =25,              --DEFAULT=25 FRAMES PER SECOND. fps SHOULD MATCH OTHER SCRIPTS FOR SIMPLICITY (autocomplex). 
    format='yuv422p',       --DEFAULT='yuv422p'  FINAL format, FOR SMOOTH MASK TOGGLE. SMPLAYER MAY CONTROL THE FINAL OUTPUT TO GPU.  422p MEANS HALF COLOR WIDTH.  yuv422p yuv440p yuv444p ARE GOOD, BUT yuv420p rgb24 ETC DON'T ALWAYS WORK WITH SOME FILTERS.
    -- scale={1680,1050},   --NEEDED IN LINUX FOR PERFECT CIRCLES. ALSO STOPS EMBEDDED MPV SNAPPING (APPLY FINAL scale IN ADVANCE). DEFAULT=display SIZE (WINDOWS & MACOS), OR OTHERWISE LINUX IS [vo] SIZE. scale OVERRIDE USES NEAREST MULTIPLES OF 4 (ceil).
    
    key_bindings         ='F2', --DEFAULT='' (NO TOGGLE). CASE SENSITIVE. KEYBOARD TOGGLE WORKS IF MPV HAS ITS OWN WINDOW, BUT NOT BY DEFAULT IN SMPLAYER. 'F2 F3' FOR 2 KEYS. M IS MUTE. F1 MAY BE autocomplex, WHICH GOES BEFORE automask.  THIS TOGGLE SNAPS THE WINDOW, UNFORTUNATELY.
    toggle_on_double_mute=  .5, --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-mute TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE MUTE. NEGATE BY DOUBLE-CLICKING MUTE.
    
    config={
            'osd-font-size 16','osd-border-size 1','osd-scale-by-window no', --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
            'image-display-duration inf','keepaspect no','geometry 50%',     --STOPPING IMAGES CAUSES MPV TO SNAP. no-keepaspect (FREE aspect) & geometry ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER.
            'video-timing-offset 1','hwdec auto-copy','vd-lavc-threads 0',   --IMPROVED PERFORMANCE FOR LINUX .AppImage. DEFAULT offset=.05 SECONDS (RENDERING TIME). hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO). FINAL video-zoom CONTROLLED BY SMPLAYER→GPU.
           },       
}
local o,label = options,mp.get_script_name() --ABBREV. options, GRAPH label='automask' 

if o.DUAL then o.DUAL=2 end --1 OR 2.  CONVERT BOOL INTO NUMBER OF REFLECTIONS (+1).
for key,val in pairs(o) do if val=='' then o[key]=nil end end   --LUA INTERPRETS ''→true. BUT IT MAY MEAN DEFAULT FOR automask OPTIONS (0TH ROTATION MUST BE 0, ETC).

for key,val in pairs({formula='lutyuv=negval',periods=1,DUAL=1,INVERT='0',DISABLE='0',x='0',y='0',rotations='0',zoompan='1:0:0',RES_MULT=1,LEAD_T=0,fps=25,format='yuv422p',scale={},periods_skipped=0,key_bindings='',toggle_on_double_mute=0,config={}})
do if not o[key] then o[key]=val end end      --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command('no-osd set '..option) end    --APPLY config.
if mp.get_property('vid')=='no' then exit() end    --NO VIDEO→EXIT.

local p=o.period    --ABBREV.
if not p or p==0 or o.periods==0 then p,o.periods,o.INVERT,o.DISABLE = 1/o.fps,1,'0','0'   --OVERRIDE: NO TIME DEPENDENCE. p>0 & periods=1. (t) & (n) SUBS DON'T APPLY TO TIMELINE SWITCHES, SO BLINKING IS INDEPENDENT.
    for nt in ('n t'):gmatch('%g') do if not o[nt] then o[nt]=0 end end end     --SET SPECIFIC t OR n.
o.periods_skipped=math.min(o.periods_skipped,o.periods) --MAX-SKIP = periods

for key in ('INVERT DISABLE x y rotations'):gmatch('%g+') do o[key]=o[key]:format(p,p,p,p,p,p,p,p) end  --%s=p    BLINKER SWITCH, INVISIBILITY, POSITIONS & ROTATIONS.
local FP,W,H = o.fps*p,o.scale[1],o.scale[2] --FRAMES/PERIOD & scale OVERRIDE.
o.zoompan=o.zoompan:format(FP,FP,FP,FP,FP,FP,FP,FP) --%s=FP
if W and H then mp.command(('no-osd vf append @%s:lavfi=[scale=%s:%s,format=%s,setsar]'):format(label,W,H,o.format)) end  --OPTIONAL scale OVERRIDE: SNAP GRAPH STOPS EMBEDDED MPV SNAPPING.

for pTcs,SUB in pairs({p='%s',T='(t)/(%s)',c='cos(2*PI*(t)/(%s))',s='sin(2*PI*(t)/(%s))'}) do for xyr in ('x y rotations'):gmatch('%g+') do if o[xyr]   --period, SCALED TIME, COS & SIN SUBSTITUTIONS.
        then o[xyr]=o[xyr]:gsub('%('..pTcs..'%)',SUB:format(p)) end end end     --%s=period
for nt in ('n t'):gmatch('%g') do if o[nt] then for xyr in ('x y rotations'):gmatch('%g+') do if o[xyr]   --SUB IN SPECIFIC TIME OR FRAME#.
            then o[xyr]=o[xyr]:gsub('%('..nt..'%)','('..o[nt]..')') end end end end
if o.n then o.zoompan=o.zoompan:gsub('%(in%)','('..o.n..')'):gsub('%(on%)','('..o.n..')') end   --on=in (OUTPUT FRAME NUMBER)

local g={w='widths', h='heights', x='x', y='y', crops='crops', rots='rotations'} --g=GEOMETRY TABLE. CONVERT STRINGS INTO TABLES, INSIDE g.
for key,option in pairs(g) do g[key]={} --INITIALIZE w,h,x,y,...
    if o[option] then for opt in o[option]:gmatch('%g+') do table.insert(g[key],opt) end end end
if not g.rots[1] then g.rots[1]='0' end     --0TH ROTATION IS SPECIAL & MUST BE DEFINED.

if not o.SECTIONS then for _,__ in pairs(g.w) do N=_ end  --DETERMINE SECTIONS COUNT, IF NECESSARY, BEFORE AUTO-CENTERING ETC.
     for _,__ in pairs(g.h) do if _>N then N=_ end end
     o.SECTIONS=N end

if not o.SECTIONS or o.SECTIONS==0 then if o.INVERT=='0' and o.DISABLE=='0' then NULL_OVERRIDE=true end  --OPTIONAL, FASTER FOR formula CALIBRATION. APPLY OVERRIDE IF NO BLINKING OR DISABILITY.
    g.w,g.h,g.x,g.y,g.crops,g.rots,o.SECTIONS,o.DUAL,o.SQUARE,o.zoompan = {'0'},{'0'},{},{},{},{'0'},1,1,true,'1:0:0' end    --0=iw & ih. DEFAULT TO BLINKING FULL SCREEN NEGATIVE.

local blur,N,MASK = '',0,'%s' --blur INITIALIZES CIRCLE FROM SQUARE. N>=0 IS SECTION #. MASK IS GENERATED RECURSIVELY, FROM %s. rotate COUPLES WITH zoompan, AFTER DUAL.
if not o.SQUARE then blur=',avgblur,scale=iw*2:-1:bicubic,split[1],rotate=PI/4[2],[1][2]lut2=x*y/255,split[1],rotate=PI/8[2],[1][2]lut2=x*y/255' end  --DRAW CIRCLE BEFORE MASK. MAY USE INTERMEDIATE scale FOR 22.5° & 45° ROTATIONS. REMOVING THIS PRODUCES PERFECT SQUARES.

while N<o.SECTIONS do N=N+1 --MASK CONSTRUCTION, BEFORE DUAL.   FOR DILATING PUPILS THIS WOULD MOVE TO file_loaded (THERE'S A SCALABILITY ISSUE).
    if not g.w[N] and not g.h[N] then if N==1 then g.w[N]='iw'    --AUTO-GENERATOR. N=1 FULL-SIZE.
        else g.w[N]=('iw*%d/%d'):format(1+o.SECTIONS-N,2+o.SECTIONS-N) end end    ----EQUAL REDUCTION TO EVERY REMAINING SECTION.
    if not g.w[N] then g.w[N]='oh' end  --w & h MUST BE DEFINED. IF POSSIBLE GENERATE CIRLES/SQUARES ON FINAL DISPLAY.
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

local lavfi=('%%sscale=%%s:%%s,split=3[vo][T],%s[vf],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-(1/FRAME_RATE+%s)/TB,format=y8,split[T],setpts=0,crop=1:1,lut=0,split[0],pad=2:2,lut=255,pad=iw+2:ow:1:1:WHITE,pad=iw+2:ow:1:1:GRAY,pad=iw+2:ow:1:1%s[1],[0][T]scale2ref=oh*a/%d:ih*(%s)[0][T],[1][0]scale2ref=oh:ih*2.2:bicubic[1][0],[1]crop=iw/2.2:ow,lut=255*gt(val\\,74)[1],[1][0]scale2ref=%s:%s[1][0],[1]loop=%s:1%s[M],[M][T]scale2ref=oh*a:ih*(%s)[M][T],[M]loop=%d:2^14,loop=%s:1,rotate=%s:oh*iw/ih:ih/(%s),lut=val*gt(val\\,16),zoompan=%s:0:%%dx%%d:%s,negate=y:enable=%s,lut=0:enable=%s,loop=-1:2^14,setpts=PTS-(%s)/TB,select=gte(t\\,0)[M],[T][M]concat=unsafe=1,trim=start_frame=1[M],[vf][M]alphamerge[vf],[vo][vf]overlay=0:0:endall,%%ssetsar')
     :format(o.formula,o.LEAD_T,blur,o.DUAL,o.RES_MULT,g.w[1],g.h[1],p*o.fps-1,MASK,o.RES_SAFETY,o.periods-o.periods_skipped-1,p*o.periods_skipped*o.fps,g.rots[1],o.RES_SAFETY,o.zoompan,o.fps,o.INVERT,o.DISABLE,p*o.periods)    --RES_SAFETY REPEATS FOR rotate TO CROP DOWN ON THE MASK EXCESS. fps REPEATS WHEN LOOPING LEAD FRAME. p REPEATS FOR SELECTOR & LEAD-SKIP. 

----lavfi  =[graph] [vo]→[vo] LIBRARY-AUDIO-VIDEO-FILTER LIST. SELECT FILTER NAME TO HIGHLIGHT IT (NO WORD-WRAP). THEY MAY FORM PAIRS/TRIPLES. %% SUBSTITUTIONS OCCUR LATER. NO audio ALLOWED (vf append). RE-USING LABELS IS SIMPLER. [vo] IS VIDEO-OUT. [vf] IS FORMULA-FILTERED VIDEO. [T] IS TIME METADATA FRAME. [0] IS CANVAS. [1] & [2] ARE DISC INITIALIZATION (SUPERPOSITION): THEN [1][2]...[N] ARE DISCS. [M] IS MASK. 
----lutyuv,lut      FOR FORMATS yuv422p,y8  LOOK-UP-TABLE BRIGHTNESS-UV  DEFAULT val RANGE [0,255]. negval clipval RANGE [minval,maxval]  val MAY GO BELOW minval & ABOVE maxval (DEAD-ZONES ABOVE 0 & BELOW 255). negval IS CLIPPED. USE lutyuv NOT lut, FOR COLORS (lutrgb IS BUGGY/SLOW). u=v=128=GREYSCALE CORRESPOND TO 0 IN CONVERSION FORMULAE (SIGNED 8-BIT).        COMPUTES TABLE IN ADVANCE SO USES VERY LITTLE CPU. NOT A 1-1 FUNCTION (THAT MAY BE DULL). BROWN=BLACK ALSO DEPENDS ON WHETHER SOMEONE IS LOOKING UP AT AN LCD, OR DOWN.     
----fps    =fps     FRAMES PER SECOND LIMIT.
----split  =outputs   CLONES video.
----alphamerge  [vf][M]→[vf]  USES lum OF MASK [M] AS alpha OF [vf]. SIMPLER THAN TRIMMING maskedmerge. WITH split, CONVERTS BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey & colorchannelmixer.
----trim   =...:start_frame:end_frame  TRIMS TIMESTAMP FRAME [T] TO RESTORE ITS TIME, & PREP CANVAS. A trim DOESN'T CHANGE PTS.
----setpts =expr  ZEROES OUT TIME FOR THE CANVAS, REMOVES THE FIRST TWIRL (NOT SMOOTH) & IMPLEMENTS lead_frames AFTER INFINITE loop. SUBTRACT 1 FRAME FROM MONO-trim [T], FOR ITS TIME TO APPLY TO WHATEVER FOLLOWS IT.
----select =expr  DISCARDS FRAMES IF 0. BUGFIX FOR 1 FRAME trim. ALSO REMOVES THE FIRST periods, WHICH ARE CHOPPY ON FINAL OUTPUT (MAYBE A buffer ISSUE).
----loop   =loop:size  (LOOPS>=-1 : FRAMES/LOOP>0) -1 FOR JPEG. LOOPS INITIAL DISC FRAME FOR period. THEN LOOPS TWIRL FOR periods-SKIP, THEN LEAD FRAME FOR SKIP, & THEN REPEATS zoompan INFINITE. LOOPED FRAMES GO FIRST. 1 PERFECT MASK CAN BE DONE INSTANTLY, BUT THE INFINITE loop WITHOUT buffer CAUSES STARTUP LAG.
----concat =...:unsafe  [T][M]→[M]  INSERTS STARTING TIMESTAMP (WHENEVER USER SEEKS). TO MAKE ALL POSSIBLE CASES safe IS EASY BUT REQUIRES MORE CODE (setsar=1,keep_aspect=1 ETC).
----crop   =out_w:out_h:x:y:keep_aspect    DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0   SET keep_aspect=1 FOR SAFE concat OF VIDEO BUILT FROM 1x1.   OVER-CROPPING DISC (THE 2.2) MAY CAUSE GRIZZLE AFTER DISC ROTATIONS. LINUX snap DOESN'T ALLOW oh BEFORE COMPUTING IT (USE ow INSTEAD OF oh).
----pad    =w:h:x:y:color  PREPS 4x4/8x8 FOR avgblur, USING WHITE, GRAY & BLACK.   2x2/4x4 TOO SMALL. A LITTLE SQUARE IS LIKE A DISC WHO IS A LITTLE OFF & NEEDS A ROUND OF BLUR & SHARP.
----lut2    [1][2]→[1]  GEOMETRICALLY COMBINES [1][2] avgblur CLOUDS. A SIMPLE overlay WOULDN'T WORK (x*y/255 BEATS (x+y)/2). sqrt(x*y) ALSO DOESN'T WORK.
----avgblur (AVERAGE BLUR) PAIRS WITH scale. CONVERTS 4x4/8x8 SQUARE INTO BLURRED DISC. REMOVE FOR DIAGONAL-CUT RECTANGLES.   ALTERNATIVES INCLUDE gblur & boxblur.
----scale,scale2ref=width:height:flags   [1][vf]→[1][vf]  SCALES [1]→[1] USING DIMENSIONS OF [vf]. FORMS PAIR WITH overlay.  bicubic FOR LINUX snap COMPATIBILITY. ITS DEFAULT IS bilinear WHICH FAILS, BUT bicubic spline lanczos ARE ALL VALID. bicubic ALSO STANDARD ON LINUX, BUT NOT snap. CONVERT TO SCREEN SIZE BECAUSE OF zoompan. ONLY USE MULTIPLES OF 4 BECAUSE OF AN overlay BUG (OFF BY 1 FOR 1050p). PREPARES EACH DISC FROM THE LAST, & INITIALIZES 2048p DISC.     SCALES TO 2.2x BIG DISC, CALIBRATED WITH lut>74.  THE IDEA IS TO scale,crop A TINY SYMMETRIC BLUR TO HALF-10%, TO lut A DECENT CIRCLE. IN MS PAINT A PERFECT CIRCLE SHOULD INSCRIBE A MONACLE SCREENSHOT. SOMETIMES A SMOOTHER CIRCLE MAY BE MORE OBLONG.
----overlay=x:y:eof_action  [N-1][N]→[N-1]  (DEFAULT 0:0:repeat) endall ENDS MORE ABRUPTLY. MAY PAIR WITH scale2ref. THIS FILTER CAN BE OFF-BY-1 IF W OR H ISN'T DIVISIBLE BY 4.
----rotate =angle:ow:oh:fillcolor  (RADIANS:PIXELS CLOCKWISE) ROTATES EACH DISC, BEFORE FINAL scale2ref. PI/4 & PI/8 HELP PREPARE INITIAL DISC (MAY USE INTERMEDIATE scale, TOO). THE 0TH (DUAL zoompan) ROTATION IS SPECIAL.
----zoompan=zoom:x:y:d:s:fps  (z>=1) d=0 FRAMES DURATION-OUT PER FRAME-IN.
----format =pix_fmts   CONVERTS TO y8 (MOST EFFICIENT). ALSO NEEDED TO STOP EMBEDDED MPV SNAPPING ON TOGGLE (BY TRIAL & ERROR).
----setsar  IS THE FINISH (PAIRED WITH format). STOPS MPV SNAPPING ITS OWN WINDOW. (CAN VERIFY WITH mute TOGGLE IN SMPLAYER.)


if NULL_OVERRIDE then lavfi=o.formula end  --OVERRIDE FOR SPEED.

function file_loaded(_,seeking) --OVERLOADS FOR vid TRACK CHANGE - INITIAL SEEK. TRACK CHANGE IS LIKE A NEW FILE-LOAD.
    if seeking then return end   --NEW vid STILL seeking.
    mp.unobserve_property(file_loaded)
         
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end    --WINDOWS & MACOS.
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end   --USE [vo] SIZE.
    if not (W and H) then mp.add_timeout(1/o.fps,file_loaded)  --FALLBACK: RE-RUN & return IF [vo] ISN'T READY (LINUX snap).
        return end  
    W,H,fps,format = math.ceil(W/4)*4,math.ceil(H/4)*4,'',''     --BUGFIX: MULTIPLES OF 4 NECESSARY FOR PERFECT overlay. fps,format STRINGS EXIST BECAUSE COVER ART & RAW MP3.
    
    if     mp.get_property_number('current-tracks/video/id')  then format=('format=%s,'):format(o.format) end   --SHOULDN'T APPLY format TO NO vid.
    if not mp.get_property_bool('current-tracks/video/image') then    fps=('fps=%s,'   ):format(o.fps)   --SHOULDN'T APPLY fps TO image. THE GOAL IS TO USE 0% CPU.
    elseif not mp.get_property_number('time-remaining') and mp.get_property('lavfi-complex')=='' then unpause=not mp.get_property_bool('pause')  --pause ISN'T ALLOWED EXCEPT FOR RAW JPEG. OVERRIDE USES 0% OF CPU. autocrop USEFUL FOR MP3 IF IT USES 0% CPU. bbox WORKS BETTER THAN cropdetect (BUGGY). NO SMOOTHCROP. IMAGES MAY BE JPG, PNG, BMP, MP3. GIF IS not image. NO WEBP. TIFF TOP LAYER ONLY. 
        mp.command('no-osd set pause yes') end  --MASK NEEDS pause OR loop (autocomplex). unpause RETURNS pause STATE. RAW JPEG MAY REQUIRE AN UNPAUSED seek. complex IS FASTER, BUT CAN'T CHANGE TRACK LIKE THIS METHOD.
    
    mp.command(('no-osd vf append @%s:lavfi=[%s]'):format(label,lavfi):format(fps,W,H,W,H,format))     --INSERT GRAPH. IT GOES AFTER autocrop. W,H REPEAT FOR zoompan.
    if unpause then mp.command('no-osd set pause no') end
end
mp.register_event('file-loaded', file_loaded)    
mp.observe_property('current-tracks/video/id','number',function() if fps then mp.observe_property('seeking','bool',file_loaded) end end)  --m.x MEANS AFTER INITIALIZED. CHANGE OF VIDEO TRACK IS TREATED SAME AS LOADING A NEW FILE. AN MP3 IS LIKE A COLLECTION OF JPEG IMAGES (MP3TAG) WHICH NEED CROPPING (& HAVE RUNNING audio).

local timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)    --DOUBLE mute timer DEFINED BEFORE TOGGLE. IT CARRIES OVER TO NEXT video IN PLAYLIST.
timer.oneshot=true 
timer:kill()

function on_toggle(mute_observed)
    if mute_observed and not timer:is_enabled() then timer:resume() --DON'T TOGGLE UNLESS timer IS RUNNING.
        return end
    OFF = not OFF
    if OFF then mp.command(('no-osd vf append @%s:lavfi=[scale=%d:%d,%ssetsar]'):format(label,W,H,format))     --TOGGLE OFF. REPLACE MASK WITH SNAP GRAPH. THE SNAP GRAPH STOPS EMBEDDED MPV FROM SNAPPING.
    else file_loaded() end   --TOGGLE ON.
    if o.msg_on_toggle then mp.osd_message(o.msg_on_toggle:format(mp.get_property_osd('af'), mp.get_property_osd('vf')), 4) end  --OPTIONAL osd, 4 SECONDS.
end
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_mask_'..key, on_toggle) end
mp.observe_property('mute', 'bool', on_toggle)


----COMMENTS SECTION (CODE EXAMPLES). MPV CURRENTLY HAS A 10 HOUR BACKWARDS SEEK BUG (BUFFER ISSUE?). 
----drawtext=...:expansion:...:text    NOT WORKING IN WINDOWS, WITHOUT SPELLING OUT FULL PATHS TO SYSTEM FONT TYPE FILES.
----eq     =contrast:brightness:saturation  OPTIONAL EQUALIZER, MAY APPEND TO formula. ACCEPTS LIVE vf-command FROM SCRIPT. DEFAULT 1:0:1  RANGES [-2,2]:[-1,1]:[0,3]    CAN NEGATE, DARKEN & SATURATE. HOWEVER NON-LINEAR FORMULAS WORK BETTER.
----negate =components  (y=lum)  components AREN'T snap COMPATIBLE. DEFAULT formula.

--eq ONLY:          formula='eq=-1:-0.25:1.1',  
--50% DROP QUAD GAUSS formula='lutyuv=minval+.4*(negval-minval+128/gauss(0)*(1*gauss((255-val)/(255-maxval)/.9-1)-.6*gauss((255-val)/(255-maxval)/.9-2)-1*gauss(val/minval/.9-1)+.6*gauss(val/minval/.9-2))),eq=1.2:0:1.2',  -- .6=exp(-.5)    negval/minval APPROX (255-val)/(255-maxval)
--QUAD-GAUSS        formula='lutyuv=.75*(negval-minval)+minval+100/gauss(0)*(1*gauss((255-val)/(255-maxval)/2-1)-.6*gauss((255-val)/(255-maxval)/2-2)-1*gauss(val/minval/1.7-1)+.6*gauss(val/minval/1.7-2)),eq=saturation=1.1',  -- .6=exp(-.5)
--TRIPLE GAUSS      formula='lutyuv=.75*(negval-minval)+minval+(64*gauss((255-val)/(255-maxval)/1.7-1)-64*gauss(val/minval/1.5-1)+32*gauss(val/minval/1.5-2))/gauss(0),eq=saturation=1.1',  -- .6=exp(-.5)
--SINGLE SINE WAVE: formula='lutyuv=minval+.75*(negval-minval+8*minval*sin(2*PI*(negval/minval-1)/4)),eq=saturation=1.2',    --PERIOD=AMPLITUDE/2.
--2 SINE WAVES:     formula='lutyuv=minval+.75*(negval-minval)+4*minval*(sin(2*PI*(negval/minval-1)/4)*lt(negval/minval\\,2)+sin(2*PI*(negval-maxval)/minval/4)*lt((maxval-negval)/minval\\,4)),eq=saturation=1.2', 
--ASIN:             formula='lutyuv=minval+255*asin(negval/maxval)^.5/PI*2,eq=saturation=1.2', 
--ASIN ASIN         formula='lutyuv=255*asin(asin(negval/maxval)/PI*2)^.3/PI*2,eq=saturation=1.2', 
--SQRT+SQRT(1-X)    formula='lutyuv=.8*255*(lt(negval\\,128)*(negval/maxval)^.5+gte(negval\\,128)*(1-negval/maxval)^.5),eq=saturation=1.2', 
--SIGNED POWERS     formula='lutyuv=.8*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^abs(1-val/255/.5))),eq=saturation=1.1', 
--X^(1+X^2)         formula='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(1+(2*abs(1-val/255/.5))^2)),eq=saturation=1.1', 
--X^(3^(X^2))       formula='lutyuv=.75*128*(1+sgn(128-val)*abs(1-val/255/.5)^(3^(abs(1-val/255/.5)^2))),eq=saturation=1.1', 

--nullsrc EQUAL RAM  local lavfi=('fps=%s,scale=%%d:%%d,split[vo],%s[vf],nullsrc=s=2x2:r=%s:d=0.01,format=y8[1],[1][vo]scale2ref[1][vo],[1]split[1],crop=iw/%d:ih,pad=iw*(%s):ow/a,lut=0[0],[1]crop=2:2,lut=255,pad=iw+2:ow:1:1:WHITE,pad=iw+2:ow:1:1:GRAY,pad=iw+2:ow:1:1%s[1],[1][0]scale2ref=oh:ceil(ih*2.2/4)*4[1][0],[1]crop=%%d*(%s):ow,lut=255*gt(val\\,74)[1],[1][0]scale2ref=%s:%s[1][0],[1]loop=%s:1,negate=y,%s,format=y8[M],[M][vo]scale2ref=iw:-1[M][vo],[M]loop=%d:2^14,setpts=PTS-(%s)/TB,select=gte(t\\,0),loop=%s:1,negate=y:enable=%s,lut=0:enable=%s,zoompan=%s:d=0:s=%%dx%%d:%s,loop=-1:2^14,setpts=PTS+(%%s-(%s))/TB[M],[vf][M]alphamerge[vf],[vo][vf]overlay=0:0:endall,setsar'):format(o.fps,o.formula,o.fps,o.DUAL,o.RES_MULT,blur,o.RES_MULT,g.w[1],g.h[1],p*o.fps-1,MASK,o.periods-o.periods_skipped,p,p*o.periods_skipped*o.fps,o.INVERT,o.DISABLE,o.zoompan,o.fps,o.lead)    --period FOR loop (TWIRL) setpts (DISCARD FIRST) & select (SKIP).  UNFORTUNATELY A SLOW ANIMATION TAKE AGES TO LOAD (FOR SMOOTH INITIAL TWIRL IN HD).
    









