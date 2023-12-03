----lavfi-complex SCRIPT WHICH LIMITS fps & size (TO SCREEN); LOOPS JPEG; & OVERLAYS STEREO FREQUENCY SPECTRUM + volume BARS (AUDIO VISUALS) ONTO MP4, MP3 (RAW & COVER ART), WITH DOUBLE-mute TOGGLE (SLOW).     
----ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY SINE WAVES CAN BE ADDED FOR CALIBRATION & DECORATION. MOVES & ROTATES WITH TIME.  CHANGING TRACKS IN SMPLAYER REQUIRES STOP & PLAY (aid vid LOCK BUG).
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS. RUNS SLOW IN VIRTUALBOX, BUT FINE IN NATIVE LINUX (LIVE USB, DEBIAN-MATE). YOUTUBE (ytdl) UNTESTED (E.G. PLAYING GUITAR LIVE).

options={ --ALL OPTIONAL & MAY BE REMOVED. TO REMOVE A COMPONENT SET ITS alpha TO 0 (freqs, volume & feet).
    top_scale   = 1, --REMOVE FOR NO TOP HALF. RANGE [0,1]. SCALES HEIGHT OF TOP HALF.
    bottom_scale=.5, --REMOVE FOR NO BOTTOM HALF (vflip). RANGE [0,1].   FUTURE VERSION COULD SUPPORT SURROUND SOUND FOR BOTTOM HALF.
    dual_scale  =.9, --REMOVE FOR NO STATIONARY SECOND complex. POSITION CENTERED. IT CAN BE READ MORE EASILY.
    -- final_colormix='gb=1:bb=0',--UNCOMMENT FOR RED & GREEN, INSTEAD OF RED & BLUE (DEFAULT). PREDATOR-GREY='rr=.75:gr=.75:br=.75:rb=.25:gb=.25:bb=.25'.  BLUE, DARKBLUE & BLACK HIGHS ARE COMPATIBLE WITH cropdetect (autocrop), BUT RED TIPS MAY INTERFERE WHEN SIDE-BARS AREN'T PERFECT BLACK. RED LIPS MAKE SENSE. WHITE BATONS FOR TEETH IS AN ALTERNATIVE.
    
    fps   =   25, --DEFAULT=25 FRAMES PER SECOND. SCRIPT LIMITS fps & scale. 
    period=19/25, --DEFAULT=1 SECOND. SET TO 0 FOR STATIONARY. USE EXACT fps RATIO (E.G. 19/25=79BPM, BEATS PER MINUTE). UNLIKE A MASK, MOTION MAY NOT BE PERIODIC. ENSEMBLE MAY FREELY FLOAT AROUND. (IF 0 "n/%s"→"0" GSUBS OCCUR ETC). 
    
    position=    '.75+.05*(1-cos(2*PI*n/%s))*mod(floor(n/%s)+1\\,2)',      --%s=fps*period  DEFAULT=.5, (0=TOP, 1=BOTTOM). MAY DEPEND ON TIME t & FRAME # n. mod ACTS AS ON/OFF SWITCH.   SPECTRUM POSITION FROM SCREEN TOP (RATIO), BEFORE autocrop.   THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING.  THE IDEAL COMPLEX COULD BE POSITIONED BY GAMEPAD CONTROLLER, BUT NOT THIS ONE.
    rotate  =          'PI/16*sin(2*PI*n/%s)*mod(floor(n/%s)\\,2)',        --%s=fps*period  DEFAULT=0 RADIANS CLOCKWISE. MAY DEPEND ON t & n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle. 
    zoompan ='1+.19*(1-cos(2*PI*(in/%s-.2)))*mod(floor(in/%s-.2)\\,2):0:0',--%s=fps*period  in=INPUT-FRAME-NUMBER  zoom:x:y=1:0:0 BY DEFAULT (MINIMUM).  BEFORE A HOVERCRAFT SCOOTS RIGHT IT MAY ROTATE, HENCE 20% DELAY.  19% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS. REMOVE THIS LINE TO STOP THE SPECTRUM SCOOTING AROUND. A STILL SPECTRUM MAY DRAW MORE ATTENTION.
    
    freqs_lead         =  .24, --DEFAULT=.08 SECONDS. LEAD TIME FOR SPECTRUM (TRIAL & ERROR). BACKDATE audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG. CAN CHECK AGAINST DRUM BEAT. DEPENDS MORE ON HUMAN AUDIO/VIDEO INTERPRETATION TIME.
    freqs_sr           = 2010, --DEFAULT=2010 Hz. SAMPLE RATE (SAMPLES/SECOND), DOWN FROM 44100. CALIBRATED WITH 1kHz SIGNAL. THESE 3 options ARE FOR CALIBRATION. THIS VERSION ONLY SUPPORTS LR-1kHz. A SINGER'S VOICE CAN PRIMARILY GO OVER 1kHz...
    LR_OVERLAP         =    2, --DEFAULT=2 PIXELS. CALIBRATES SPECTRUM BY MOVING RIGHT & LEFT CHANNELS ON TOP OF EACH OTHER, @CENTER (DATA DRAG). 
    -- CALIBRATION={{100,1},{'200:1',2},{300,1},{'400:1',2},{500,1},{'600:1',2},{700,1},{'800:1',2},{900,1},{'1000:1',2}}, --{{frequency(Hz):beep_factor,volume},}  beep_factor=OPTIONAL  sine WAVES FOR CALIBRATION.  THIS EXAMPLE BEEPS DOUBLE ON EVEN.   COULD HELP TEST NORMALIZERS, & DECORATE freqs.  SPECTRUM CALIBRATES VIA 3 NUMBERS: freqs_lead freqs_sr LR_OVERLAP   SYNCHRONY IS freqs_lead.
    
    freqs_highpass     =  100,   --DEFAULT=100 Hz. DAMPENS SUB-BASS & DC, NEAR volume BAR.
    freqs_alpha        =    1,   --DEFAULT=  1, RANGE [0,1]. OPAQUENESS OF SPECTRAL DATA CURVE.
    freqs_fps          = 25/2,   --DEFAULT=25/2. 25fps MAY CAUSE LAG. THIS & freqs_clip_h HELP WITH PERFORMANCE.
    -- freqs_mode      ='bar',   --DEFAULT='line'. CHOOSE line OR bar (OR dot). SET freqs_alpha=.25 FOR bar. GRAPH OPTIMIZED FOR line.
    freqs_win_size     =  512,   --DEFAULT=512, INTEGER RANGE [128,2048]. APPROX # OF DATA POINTS. THINNER CURVE WITH SMALLER #. NEEDS AT LEAST 256 FOR PROPER CALIBRATION. TOO MANY DATA POINTS LOOK BAD.
    freqs_win_func     ='parzen',--DEFAULT='parzen'. poisson cauchy flattop MAYBE OK, BUT THE OTHERS ARE UGLY: rect bartlett hanning hamming blackman welch bharris bnuttal bhann sine nuttall lanczos gauss tukey dolph
    freqs_averaging    =    2,   --DEFAULT=  2. INTEGER, MIN 1. STEADIES SPECTRUM. SLOWS RESPONSE TO AUDIO. TRY 3 IF MORE freqs_fps. 
    freqs_magnification=  1.3,   --DEFAULT=1.3. INCREASES CURVE HEIGHT. REDUCES CPU CONSUMPTION, BUT THE LIPS LOSE TRACTION. L & R CHANNELS ARE LIKE A DUAL ALIEN MOUTH (LIKE HOW HUMANS ARE BIPEDAL).    TO INCREASE MAGNIFICATION A NEW FILTER IS NEEDED TO STOP EXCESSIVE SHARPNESS.
    freqs_clip_h       =  1/3,   --DEFAULT= .5. MINIMUM=grid_height (CAN'T CLIP LOWER THAN GRID). REDUCES CPU USAGE BY CLIPPING CURVE (CROPS THE TOP OFF SHARP SIGNAL). THE NEED FOR CLIPPING, LOW fps & size PROVE THE CODE MAY BE SLOW.
    volume_alpha       =   .5,   --DEFAULT= .5, RANGE [0,1]. SET TO 0 TO REMOVE BARS (FEET REMAIN). OPAQUENESS OF VOLUME BARS. 
    volume_fade        =    0,   --DEFAULT=  0, RANGE [0,1].
    -- volume_dm       =    1,   --DEFAULT=  0 (NO DISPLAYMAX LINES). ALSO SET volume_alpha=1 (& pause) TO SEE THESE.
    volume_width       =  .04,   --DEFAULT=.04, RANGE (0,1]. WIDTH OF BAR RELATIVE TO VIDEO.
    volume_height      =  .15,   --DEFAULT= .2, RANGE (0,1]. HEIGHT OF BAR (BEFORE STACKING FEET), RELATIVE TO SCREEN. autocrop MAY MAGNIFY ITS SIZE, BY ACCIDENT. MOVING THE BAR UPWARD WOULD TAKE CENTER STAGE (THE NOSE MIGHT BE DEAD-CENTER).
    grid_height        =   .1,   --DEFAULT=.15, RANGE (0,1]. GRID HEIGHT RELATIVE TO SCREEN, BEFORE STACKING FEET.  GRID TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS (freqs).
    grid_thickness     =  .15,   --DEFAULT= .1, RANGE (0,1], RELATIVE TO GRID SPACING. APPROX AS THICK AS CURVE.
    feet_alpha         =    1,   --DEFAULT=  1, RANGE [0,1]. SET TO 0 TO REMOVE FEET (I.E. INVISIBLE). alpha MULTIPLIER.
    feet_height        =  .05,   --DEFAULT=.05, RANGE [.01,1]. RELATIVE TO BARS.  FEET (INNER) LIGHT UP @MAX VOLUME.
    
    max_hours=5,          --DISABLE SPECTRUM IF MP4 OR MP3 LONGER THAN THIS AMOUNT. 0% CPU USAGE FOR 10 HOUR MP3 MAYBE REQUIRED. 
    format   ='yuv420p',  --DEFAULT='yuv420p'  FINAL format IMPROVES PERFORMANCE. 420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    -- scale ={1680,1050},--DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX). scale OVERRIDE.  USES CLOSEST MULTIPLES OF 4 (ceil).
    
    key_bindings         ='F1',--DEFAULT='' (NO TOGGLE). CASE SENSITIVE. f=FULLSCREEN NOT FREQS, o=OSD, C=autocrop. V FOR VOLUME? s=SCREENSHOT NOT SPECTRUM. 'F1 F2' FOR 2 KEYS.  key_bindings DON'T WORK INSIDE SMPLAYER.
    toggle_on_double_mute=.5,  --DEFAULT=0 SECONDS (NO TOGGLE). TIMEOUT FOR DOUBLE-MUTE-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute (m&m DOUBLE-TAP).
    -- osd_on_toggle     ='af\n%s\n\nvf\n%s\n\nlavfi-complex\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICKING MUTE ENABLES CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
    
    io_write=' ',   --DEFAULT=''  (INPUT/OUTPUT) io.write THIS @EVERY CHANGE IN lavfi-complex. STOPS EMBEDDED MPV FROM SNAPPING ON COVER ART. MPV MAY COMMUNICATE WITH ITS PARENT APP.
    config  ={
              'keepaspect no','geometry 50%',       --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL SIZE.
              'force-window yes','alpha blend',     --NEEDED FOR LINUX snap VIRTUALBOX, BY TRIAL & ERROR. force-window ENABLES INSTANT lavfi-complex @file-loaded. blend-tiles RUINS RAW-MP3 [vo].
              'hwdec auto-copy','vd-lavc-threads 0',--IMPROVED PERFORMANCE FOR LINUX VIRTUALBOX.  hwdec=HARDWARE DECODER. vd-lavc=VIDEO DECODER-LIBRARY AUDIO VIDEO CORES (0=AUTO).
              'video-timing-offset 1', --DEFAULT offset=.05 SECONDS ALSO WORKS.
             },
}
o=options   --ABBREV. options.

for key,val in pairs({volume_height=.2,grid_height=.15,period=1,position='.5',rotate='0',zoompan='1:0:0',freqs_lead=.08,freqs_sr=2010,LR_OVERLAP=2,freqs_highpass=100,freqs_alpha=1,freqs_fps=25/2,freqs_mode='line',freqs_win_size=512,freqs_win_func='parzen',freqs_averaging=2,freqs_magnification=1.3,freqs_clip_h=.5,volume_alpha=.5,volume_fade=0,volume_dm=0,volume_width=.04,grid_thickness=.1,feet_alpha=1,feet_height=.05,fps=25,format='yuv420p',scale={},key_bindings='',toggle_on_double_mute=0,io_write='',config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command('no-osd set '..option) end    --APPLY config BEFORE scripts.
if mp.get_property('vid')=='no' then exit() end    --NO VIDEO→EXIT.

if o.period==0 then for key in ('position rotate zoompan'):gmatch('%g+')    --NO TIME DEPENDENCE.
    do o[key]=o[key]:gsub('in/%%s','0'):gsub('on/%%s','0'):gsub('n/%%s','0'):gsub('t/%%s','0') end end    --OVERRIDE: THIS CODE ONLY GSUBS "t/%s" ETC (NOT FULLY GENERAL).

FP,CALIBRATION,ORIENTATION = o.fps*o.period,'','' --ABBREV. FP=FRAMES/PERIOD  CALIBRATION MIXES IN SINE WAVE LIST. ORIENTATION IS FOR TOP & BOTTOM.
for key in ('position rotate zoompan'):gmatch('%g+') do o[key]=o[key]:format(FP,FP,FP,FP,FP,FP,FP,FP) end  --%s=FRAMES/PERIOD

if o.CALIBRATION then N,CALIBRATION = 0,',[a]'   --"," SEPERATES THE SINES FROM THE MIX. THE EMPTY SET IS VALID.
    for M,sine in pairs(o.CALIBRATION) do N,CALIBRATION = M,(',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],M,CALIBRATION,M) end  --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).
    CALIBRATION=('[a]%samix=%d:first'):format(CALIBRATION,N+1) end   --SINE WAVES ARE INFINITE DURATION. SEPARATE TO [ao], BUT COULD EASILY BE MIXED IN.

if o.top_scale    and o.top_scale   ~=0 and o.top_scale   ~='0'
then TOP   =(      'scale=iw:ih*(%s),pad=0:ih/(%s):0:oh-ih:BLACK@0'):format(o.top_scale   ,o.top_scale   ) end     --scale & pad BACK FOR TOP. PADDING SIMPLIFIES CODE.
if o.bottom_scale and o.bottom_scale~=0 and o.bottom_scale~='0'
then BOTTOM=('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'    ):format(o.bottom_scale,o.bottom_scale) end

if TOP              then ORIENTATION=TOP   ..',pad=0:ih*2:0:0:BLACK@0'     end   --UPRIGHT. PAD DOUBLE SIMPLIFIES CODE.   A DIFFERENT VERSION COULD CONCEIVABLY MAKE THE LIPS SMILE OR FROWN BY VSTACKING THE CURVES SEPARATELY & ROTATING L & R OPPOSITELY. 
if         BOTTOM   then ORIENTATION=BOTTOM..',pad=0:ih*2:0:oh-ih:BLACK@0' end   --UPSIDE DOWN. PAD DOUBLE.
if TOP and BOTTOM   then ORIENTATION=('split[D],%s[U],[D]%s[D],[U][D]vstack'):format(TOP,BOTTOM) end  --TOP,BOTTOM = [U],[D]

if o.final_colormix then ORIENTATION=('colorchannelmixer=%s,%s'):format(o.final_colormix,ORIENTATION) end   --MIX BEFORE vstack.
if o.DUAL then o.DUAL=('colorchannelmixer=%s,%s'):format(o.final_colormix,ORIENTATION) end   --MIX BEFORE vstack.
function f(arg) return math.floor(arg*1e3)/1e3 end  --PRECISION LIMITER FOR DIVISION. GIVES MORE ELEGANT CODE ON FINAL display & INSPECTION. SIMPLER THAN USING STRINGS.

lavfi=('[aid%%d]asplit[ao]%s,stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%s:0:%d:8:%s:t=0:v=0:o=v:dm=%s,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lutrgb=255*gt(val\\,90):0:255*gt(val\\,90),format=rgb32,split[L],colorchannelmixer=br=1:ar=%s:rr=0:bb=0:aa=0[R],[L]colorchannelmixer=ab=%s:rr=0:aa=0,hflip[L],[GRID][R]scale2ref=iw*2-(%s):ih,overlay=W-w:0:endall[GRID],[GRID][L]overlay=0:0:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,format=yuva420p[vid],%%s,split[T],setpts=PTS-STARTPTS[vo],[vid]setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[vo][vid]overlay=0:H*(%s)-h/2[vo],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[T],[T][vo]concat,trim=start_frame=1,format=%s,setsar=1[vo]')
    :format(CALIBRATION,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_dm,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,f(o.grid_height/o.freqs_clip_h),o.freqs_sr,o.freqs_lead,o.freqs_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,f(o.freqs_clip_h/o.freqs_magnification),o.freqs_alpha,o.freqs_alpha,o.LR_OVERLAP,o.volume_width,f(o.volume_height/o.freqs_clip_h),ORIENTATION,o.rotate,o.zoompan,o.fps,o.position,o.format)    --fps FOR volume, freqs & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 

----lavfi            =graph  (SPECTRUM) LIBRARY-AUDIO-VIDEO-FILTER LIST. SELECT FILTER NAME TO HIGHLIGHT IT (NO WORD-WRAP). SOME PAIR UP. lavfi-complex MAY COMBINE MANY audio & video INPUTS. %% SUBS OCCUR LATER. A lavfi string IS LIKE DNA & CAN CREATE ANY CREATURE. SEE ffmpeg-filters MANUAL.  TIMESTAMP FRAME [T] CODE EXISTS JUST TO SYNC THE MOVING SPECTRUM WITH OTHER GRAPHS, LIKE automask. [T] CODE VALID EVEN FOR SUB-CLIPS WITH OFF TIMESTAMPS (IMPOSSIBLE TO MANUALLY ENTER CORRECT NUMBERS, LIKE time-pos).
----split,asplit     =outputs  (DEFAULT 2)  CLONES audio,video. aid MAY BE KNOWN IN ADVANCE, BUT NOT NECESSARILY.
----format,aformat   =pix_fmts,sample_fmts:sample_rates     format CONVERTS BTWN rgb32 rgb24 yuva420p (MORE EFFICIENT?).    aformat CONVERTS TO STEREO, FROM MONO & SURROUND (FOR VISUALS). DOWNSAMPLES TO APPROX 2kHz (NYQUIST). s16 NOT u8.
----pad,apad         =w:h:x:y:color    BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih. MAY BE SLOW COMPARED TO scale (format CLASH?).  apad APPENDS SILENCE FOR SPECTRUM TO ANALYZE, OR THERE'S A CRASH @end-file.
----sine             =frequency:beep_factor  (Hz,BOOL) DEFAULT=440:0  GENERATES sine WAVES FOR CALIBRATION. beep IS EVERY SECOND.
----volume           =volume    (0→100) ADJUSTS sine WAVE VOLUMES (FOR DECORATIONS). FORMS TRIPLE WITH sine & amix.
----amix             =inputs:duration    DEFAULT 2:longest  MIXES IN CALIBRATION audio.
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo. CAN USE aformat (ALTERNATIVE) BUT THAT MAYBE NOT AS GOOD.
----dynaudnorm       =...:p:m:...:c:b → s64  DEFAULTS .95:10:0:0    PEAK TARGET [0,1] : MAX GAIN [1,100] : CORRECTION (DC,0Hz) BOOL : BOUNDARY MODE (NO FADE) BOOL    DYNAMIC AUDIO NORMALIZER. NORMALIZES & RENORMALIZES. b DISABLES FADE, WHICH IS BAD FOR SPECTRUM.  ALTERNATIVES INCLUDE loudnorm & acompressor.
----showvolume       =rate:b:w:h:f:...:t:v:o = rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION  [a]→[v]  (DEFAULTS 25:1:400:20:0.95:t=1:v=1:o=h)   LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED. THERE'S A dm OPTION WHICH LOOKS GOOD, TOO.    THERE'S SOME MINOR BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----highpass         =frequency (Hz) DAMPENS SUB-BASS. ~50Hz IS POWER & REFRESH RATE. MAY RE-NORMALIZE AFTERWARD. UNFORTUNATELY afftfilt IS TOO BUGGY - IT WOULD ALLOW FINE TUNING SHARP VS. BLAND TONES.
----showfreqs        =size:RATE:mode:ascale:fscale:win_size:win_func:overlap:averaging:colors  [a]→[v]  DEFAULTS 1024x512:25:bar:log:lin:2048:hanning:1:1   RATE CRASHES LINUX snap, SO THESE NEED TO BE SPELLED OUT FOR COMPATIBILITY. ASPECT SHOULD BE APPROX .5 FOR SHARPEST CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (E.G. 256x512 NOT 256x256 NOR 256x1024). 256x512 SCALED UP LOOKS BETTER THAN 512x1024 (TRIAL & ERROR). SEPARATING CHANNELS WITHOUT COLORS (cmode=separate) WOULD REQUIRE TWICE AS MANY PIXELS.
----colorchannelmixer=rr:...:aa   (RANGE -2→2, r g b a PAIRS) CONVERTS GREEN TO BLUE, RED TO BLUE, SEPARATES LEFT/RIGHT & LOWS/HIGHS.  INSTEAD OF rgb32 & shuffleplanes, MAYBE IT COULD MIX yuva444p.
----crop             =out_w:out_h:x:y:keep_aspect:exact    CENTERS BY DEFAULT. ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES [LOWS] (MULTIPLE OF 8 REQUIRED FOR iw).
----lut,lutyuv,lutrgb=y,y:u:v:a,r:g:b:a  lutrgb IS SLOW COMPARED TO lutyuv.  u=v=128 FOR GREYSCALE (YUV CONVERSION FORMULAS USE 128→0).  LOOK-UP-TABLE,BRIGHTNESS-UV,RED-GREEN-BLUE.  CREATE TRANSPARENCY, & SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.
----avgblur          =sizeX   (PIXELS)  AVERAGE BLUR. CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTH CURVE.
----fps              =fps:start_time   (FRAMES PER SECOND:SECONDS) LIMITS @file-loaded. ALSO FOR OLD MPV showfreqs. start_time INSTEAD OF setpts.
----scale,scale2ref  =width:height  DEFAULT iw:ih  SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.     TO-REFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume. CALIBRATES LR_OVERLAP.
----overlay          =x:y:eof_action  (DEFAULT 0:0:repeat)  endall DUE TO apad. OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON TIME t.     UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4. 
----hflip,vflip       FLIPS THE LEFT CHANNEL LEFT.  vflip FOR BOTTOM [D] (FOR DOWN).
----hstack,vstack    =inputs  COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES FEET.    FUTURE VERSION MIGHT ADD OR SUBTRACT MORE TICKS (E.G. TO 1.2kHz).      vstack FOR ORIENTATION & FEET.
----select           =expr  (EXPRESSION)  DISCARDS FRAMES IF 0.  OPTIONAL: FOR COMPATIBILITY WITH OLD MPV MUST select FOR [T].
----trim             =...:start_frame:end_frame  TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP. trim DOESN'T CHANGE PTS.
----setpts,asetpts   =expr  PRESENTATION TIMESTAMP EXPRESSION.  FOR SYNC OF rotate,zoompan,position WITH OTHER GRAPHS (automask), EVEN FOR OFF-INITIAL TIMESTAMPS. AFTER SENDING STARTPTS→0, SUBTRACT 1 FRAME FROM TIMESTAMP FRAME [T], BECAUSE THAT TIME IS FOR WHATEVER FOLLOWS IT.   asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO. LAG MAY DEPEND ON averaging size rate ETC.  
----rotate           =angle:ow:oh:fillcolor  (RADIANS:PIXELS) ROTATES ORIENTATION clockWISE, DEPENDENT ON TIME t & FRAME n.
----zoompan          =zoom:x:y:d:s:fps   (z>=1) d=0 FRAMES DURATION-OUT PER FRAME-IN. MAY DEPEND ON in,on INPUT-NUMBER,OUTPUT-NUMBER    SLOW FILTER, LIKE geq.
----concat            [T][vid]→[vid]  CONCATENATE RESETS STARTPTS USING 1 FRAME. NEEDED TO SYNC WITH automask.
----setsar           =sar IS THE FINISH. STOPS EMBEDDED MPV SNAPPING (CAN VERIFY WITH DOUBLE-mute TOGGLE IN SMPLAYER). MACOS BUGFIX REQUIRES sar.

----loop             =loop:size  (loop>=-1 : size>0) PAIRS WITH fps FOR RAW JPEG, WHICH IS ITS OWN CASE-STUDY WITH ITS OWN FILTER (MOST ELEGANT).
----anull,anullsrc,anullsink    FOR NULL lavfi-complex. anull FOR TOGGLE OFF. 

mp.set_property('lavfi-complex','anullsrc,anullsink')    --WARN OTHER SCRIPTS. CAN'T REFER TO [vid1] NOR [aid1], WHICH MAY NOT EXIST.
io.write(o.io_write)

function file_loaded()
    W,H = o.scale[1],o.scale[2]  --scale OVERRIDE. 
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end    --WINDOWS
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end   --LINUX & MACOS VIRTUALBOX.
    if not (W and H) then W,H = 1024,512 end   --RAW MP3 LINUX & MACOS VIRTUALBOX.
    W,H = math.ceil(W/4)*4,math.ceil(H/4)*4     --MULTIPLES OF 4 NECESSARY FOR PERFECT overlay. 
    scale=('scale=%d:%d,setsar=1,format=%s'):format(W,H,o.format)   --FOR EVERY CASE.
    
    ----5 CASES. 1) JPEG. 2) MP4 LIMITS. 3) MP3  4) MP3+JPEG  5) MP4     INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. E.G. autocrop JPEG USES MORE CPU IF COMBINED WITH autocomplex, FOR THE BLACK-BAR-STRETCH.
    complex,aid,vid,image,duration = nil,mp.get_property_number('current-tracks/audio/id'),mp.get_property_number('current-tracks/video/id'),mp.get_property_bool('current-tracks/video/image'),mp.get_property_number('duration')  --id IS nil OR INTEGER. MULTIPLES OF 4 ONLY.
    if vid and o.max_hours and duration and duration>o.max_hours*60*60 then ORIENTATION='' end  --5 HOURS → NO SPECTRUM.
    
    if image and o.io_write=='' then o.io_write=' ' end --JPEG NEEDS io_write FIX OR IT SNAPS MORE OFTEN.
    mp.observe_property('lavfi-complex','string',function() io.write(o.io_write) end)
    
    if not aid and image                     then complex=('[vid%d]%s,loop=-1:1,fps=%s:%s[vo]'):format(vid,scale,o.fps,mp.get_property_number('time-pos')) end   --CASE 1: RAW JPEG. start_time FOR --start (JPEG seek).
    if vid and not image and ORIENTATION=='' then complex=('[vid%d]fps=%s,%s[vo]'):format(vid,o.fps,scale) end   --CASE 2: LIMITS ONLY. [vo] MAY BE SPECIFIED WITHOUT [ao].
    
    if complex then mp.set_property('lavfi-complex',complex) end    --set CASES 1 & 2.
    if not aid or ORIENTATION=='' then if not complex then mp.set_property('lavfi-complex','') end  --NULLIFY NULL complex. OTHER SCRIPTS CAN CHECK BACK WITHIN 50ms.
        return end --CASES 3,4,5 BELOW. complex VARIABLE MUST PRODUCE %%s=[vo] INSERT.

    if           not vid then o.dual_scale=nil  --NO dual_scale FOR RAW MP3. IT USES ITSELF AS [vo].
                              complex=('[vid]split[vid],%s'):format(scale) end    --CASE 3: RAW MP3 DOUBLE-SPECTRUM (STILL & MOVING).
    if     image and vid then complex=('[vid%d]%s[vo],[vid]split[vid],crop=1:1:0:0:1:1[C],[C][vo]scale2ref,overlay'):format(vid,scale) end    --CASE 4: MP3 COVER ART.   FOR PROPER MOTION, [vo] GETS SANDWICHED BTWN CANVAS [C] & [vid] (SPECTRUM).
    if not image and vid then complex=('[vid%d]fps=%s,%s'):format(vid,o.fps,scale) end --CASE 5: NORMAL video. LIMIT fps & scale.
    
    clip_h=H*o.freqs_clip_h*2   --AMPLITUDE CLIP.
    if o.dual_scale then complex=complex..('[vo],[vid]split[vid],scale=%d:%d[v2],[vo][v2]overlay=(W-w)/2:(H-h)/2'):format(W*o.dual_scale,clip_h*o.dual_scale) end  --[v2]=DUAL overlay  [vid1],[vid2] ETC NOT USUALLY ALLOWED.
    mp.set_property('lavfi-complex',lavfi:format(aid,complex,W,clip_h))    --CASES 3, 4 & 5. aid TO asplit. W,H FOR zoompan (FINAL CLIP HEIGHT FOR PADDED TOP & BOTTOM). mp.set_property IS MORE POWERFUL THAN mp.command (LIKE mp.commandv).
end 
mp.register_event('file-loaded', file_loaded)    
mp.register_event('seek', function() if 0==mp.get_property_number('time-remaining') then mp.command('stop') end end)    --BUGFIX FOR seek PASSED end-file. A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES PASSED end-file. THIS LINE MAYBE SIMPLER THAN RE-CODING THE complex ITSELF (INFINITE apad FAILS, MAYBE A BUFFER ISSUE). 

timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)  --CREATE DOUBLE-mute timer.
timer.oneshot=true
timer:kill()    --CARRIES OVER TO NEXT FILE IN PLAYLIST.

function on_toggle(mute)
    if mute=='mute' and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.
        return end
    
    OFF=not OFF    --REMEMBERS TOGGLE STATE.
    if not OFF then file_loaded()   --TOGGLE ON.    UNFORTUNATELY THIS SNAPS COVER ART IN SMPLAYER (EVERY TIME).
    else aid,vid,image = mp.get_property_number('current-tracks/audio/id'),mp.get_property_number('current-tracks/video/id'),mp.get_property_bool('current-tracks/video/image')  --TOGGLE OFF, BELOW. id IS nil OR INTEGER.
        if not aid or ORIENTATION=='' then return end --CASES 1,2: DO NOTHING. OPEN TO INTERPRETATION: NO SPECTRUM, NO TOGGLE OFF.  5 CASES. 1) JPEG. 2) MP4 LIMITS. 3) MP3 SPECTRUM. 4) MP3+JPEG. 5) MP4.
        
        complex=('[aid%d]anull[ao]'):format(aid)    --CASE 3: RAW audio. STILL FRAME SPECTRUM, audio PLAYS ON. CASES 4 & 5 BUILD ON THIS.
        if             image then complex=('%s,[vid%d]%s,loop=-1:1,fps=%s:%s[vo]'):format(complex,vid,scale,o.fps,mp.get_property_number('time-pos')) end   --CASE 4: COVER ART. NEED start_time FOR ZOOMING automask (E.G. CAN TOGGLE "F1" @30MINS). STILL USES APPROX 5% CPU TO INFINITE loop. 
        if vid and not image then complex=('%s,[vid%d]fps=%s,%s[vo]'):format(complex,vid,o.fps,scale) end   --LIMIT [vo], WITH NO SPECTRUM.
        mp.set_property('lavfi-complex',complex) end
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
mp.observe_property('mute', 'bool', on_toggle)
for key in (o.key_bindings):gmatch('%g+') do mp.add_key_binding(key, 'toggle_complex_'..key, on_toggle) end --MAYBE SHOULD BE 'toggle_spectrum_' BECAUSE THIS TOGGLE ONLY TURNS OFF/ON THE SPECTRUM.


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY. 
----VERBOSE MESSAGES ALLOW CHANGING TRACK IN SMPLAYER (BUT UGLY). E.G.:   {"event" = "log-message", "level" = "v", "text" = "Set property: aid=2 -> 1    ", "prefix" = "cplayer"}
 
----ALTERNATIVE FILTERS:
----sendcmd       ISN'T CURRENTLY AVAILABLE IN MPV FOR lavfi-complex. NO INSTA-TOGGLE.
----afftfilt     =...:win_size:win_func:overlap  OPTIONAL     DEFAULTS 4096:hann:0.75  (AUDIO FAST FOURIER TRANSFORM FILTER) overlap<1 CAUSES BUG. ALONG WITH aeval ALLOWS PROCESSING audio.
----acompressor   SMPLAYER DEFAULT NORMALIZER. CAUSES BAD PERFORMANCE.
----loudnorm     =I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). CAUSED BUG REQUIRING apad.
----aresample     (Hz) DOWNSAMPLES TO ~2.1kHz (NYQUIST+5%). AN ALTERNATIVE IS aformat.   MORE OVERHEAD REDUCES RESOLUTION FOR THE ENTIRE SPECTRUM.
----shuffleplanes=map0:map1:map2:map3   DEFAULT 0:1:2:3  MAY NOT BE LINUX snap COMPATIBLE (MAY DEPEND ON colormatrix). SHUFFLES COLORS. ORDERED g:b:r:a (LIKE GreatBRitAin).
----extractplanes=planes    r+b→[R][L] (RED+BLUE)   REVERSED BECAUSE [L] GETS FLIPPED AROUND.
----alphamerge    [y][a]→[ya]  USES lum OF [a] AS alpha OF [ya]. PAIRS WITH split TO CONVERT BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey, colorchannelmixer & shuffleplanes.

----OPTION DUMP. FOR DEBUGGING CAN TRY TOGGLE ALL THESE SIMULTANEOUSLY. SOMETIMES LINES OF CODE CAN BE DELETED WITH THE CORRECT OPTION.
-- 'hr-seek-demuxer-offset 1','cache-pause-wait 0',
-- 'video-sync desync','vd-lavc-dropframe nonref','vd-lavc-skipframe nonref',   --none default nonref(SKIPnonref) bidir(SKIPBFRAMES) 
-- 'demuxer-lavf-buffersize 1e9','demuxer-max-bytes 1e9','stream-buffer-size 1e9','vd-queue-max-bytes 1e9','ad-queue-max-bytes 1e9','demuxer-max-back-bytes 1e9','audio-reversal-buffer 1e9','video-reversal-buffer 1e9','audio-buffer 1e9',
-- 'chapter-seek-threshold 1e9','vd-queue-max-samples 1e9','ad-queue-max-samples 1e9',
-- 'demuxer-backward-playback-step 1e9','cache-secs 1e9','demuxer-lavf-analyzeduration 1e9','vd-queue-max-secs 1e9','ad-queue-max-secs 1e9','demuxer-termination-timeout 1e9','demuxer-readahead-secs 1e9', 
-- 'video-backward-overlap 1e9','audio-backward-overlap 1e9','audio-backward-batch 1e9','video-backward-batch 1e9',
-- 'hr-seek always','index recreate','wayland-content-type none','background red',
-- 'hr-seek-framedrop yes','framedrop decoder+vo','access-references yes','ordered-chapters no','stop-playback-on-init-failure yes',
-- 'initial-audio-sync yes','vd-queue-enable yes','ad-queue-enable yes','demuxer-seekable-cache yes','cache yes','demuxer-cache-wait no','cache-pause-initial no','cache-pause no',
-- 'keepaspect-window no','video-latency-hacks yes','demuxer-lavf-hacks yes','gapless-audio yes','demuxer-donate-buffer yes','demuxer-thread yes','demuxer-seekable-cache yes','force-seekable yes','demuxer-lavf-linearize-timestamps no',


--EXTRACTPLANES LR MONOCHROME (NOT FASTER):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(CALIBRATION,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,o.freqs_sr,o.freqs_lead,o.freqs_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_magnification,o.LR_OVERLAP,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,ORIENTATION,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 
--SHUFFLEPLANES: lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--512x1024       lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=512x1024:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,avgblur,lut=b=255*gt(val\\,80):r=255*gt(val\\,80):a=0,avgblur=2,lut=b=255*gt(val\\,110):r=255*gt(val\\,110),split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--128x256        lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=128x256:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,scale=iw*4:-1,avgblur,lut=b=255*gt(val\\,210):r=255*gt(val\\,210):a=0,avgblur=2,lut=b=255*gt(val\\,100):r=255*gt(val\\,100),split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--ONLY 1 AVGBLUR lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=512x1024:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,avgblur,lut=b=255*gt(val\\,50):r=255*gt(val\\,50):a=0,split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--CURVES OUTLINES USING SPLIT,ALPHAMERGE lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,split,alphamerge,lut=r=0:g=0:b=255*gt(val\\,90):a=255*gt(val\\,90)*(%s),format=rgb32[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--REMOVING ZOOMPAN NO BETTER:            lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lutrgb=255*gt(val\\,90):0:255*gt(val\\,90),format=rgb32,split[L],colorchannelmixer=br=1:ar=%s:rr=0:bb=0:aa=0[R],[L]colorchannelmixer=ab=%s:rr=0:aa=0,hflip[L],[GRID][R]scale2ref=iw*2-(%s):ih,overlay=W-w:0:endall[GRID],[GRID][L]overlay=0:0:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,scale=%%d*(%s):%%d*(%s):eval=frame,crop=%%d:%%d:0:0[vid],%%s,split[T],setpts=PTS-STARTPTS[vo],[vo][vid]overlay=0:H*(%s)-h/2[vo],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[T],[T][vo]concat,trim=start_frame=1,setsar=1[vo]'):format(CALIBRATION,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,o.freqs_sr,o.freqs_lead,o.freqs_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_magnification,o.freqs_alpha,o.freqs_alpha,o.LR_OVERLAP,o.volume_width,o.volume_height/o.freqs_clip_h,ORIENTATION,o.rotate,o.zoompan,o.zoompan,o.position)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 



