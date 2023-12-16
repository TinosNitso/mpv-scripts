----lavfi-complex SCRIPT WHICH LIMITS fps & size (TO SCREEN); LOOPS JPEG; & OVERLAYS STEREO FREQUENCY SPECTRUM + volume BARS (AUDIO VISUALS) ONTO MP4, MP3 (RAW & COVER ART), WITH DOUBLE-mute TOGGLE.     
----ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY SINE WAVES CAN BE ADDED FOR CALIBRATION & DECORATION. MOVES & ROTATES WITH TIME.  CHANGING TRACKS IN SMPLAYER MAY REQUIRE STOP & PLAY (aid vid LOCK BUG, BUT CAN SWITCH ONCE).
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH IS A PROBLEM ON MACOS. RUNS SLOW IN VIRTUALBOX, BUT FINE IN NATIVE LINUX (LIVE USB, DEBIAN-MATE). WORKS OK WITH ytdl (YOUTUBE).

options={ --ALL OPTIONAL & MAY BE REMOVED. TO REMOVE A COMPONENT SET ITS alpha TO 0 (freqs, volume, grid & feet).
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. SLOW, SO REMOVE FOR OTHER GRAPHS TO INSTA-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute (m&m DOUBLE-TAP).
    key_bindings         ='F1',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER. f=FULLSCREEN NOT FREQS, o=OSD, C=autocrop. V FOR VOLUME? s=SCREENSHOT NOT SPECTRUM. 'F1 F2' FOR 2 KEYS.
    
    bottom_scale=.5,     --REMOVE FOR NO BOTTOM HALF (vflip).      SOME FUTURE VERSION MIGHT SUPPORT BL & BR CHANNELS FOR BOTTOM.
    -- bottom_only =true,--REMOVES TOP HALF. ALSO REMOVE bottom_scale FOR NULL OVERRIDE (NO SPECTRAL overlay).
    
    period=18/25, --DEFAULT=1 SECOND. SET TO 0 FOR STATIONARY. USE fps RATIO (E.G. 18/25→83BPM, BEATS PER MINUTE). UNLIKE A MASK, MOTION MAY NOT BE PERIODIC - ENSEMBLE MAY FREELY FLOAT AROUND. (IF 0, "n/%s"→"0" GSUBS OCCUR, ETC). 
    fps   =   25, --DEFAULT=25 FRAMES PER SECOND. SCRIPT LIMITS fps & scale. 
    
    -- colormix='gb=.4:bb=0',     --UNCOMMENT FOR RED/GREEN, INSTEAD OF RED/BLUE (DEFAULT). ADDS 10% TOTAL CPU USAGE (CAN CHECK TASK MANAGER). aa FOR TRANSPARENCY. BLUE ALREADY HAS GREEN gb=.3.    GREY='rr=.7:gr=.7:br=.7:rb=.3:bb=.3'.  BLUE, DARKBLUE & BLACK ARE COMPATIBLE WITH cropdetect (autocrop). RED FOR LIPS. RED & BLUE FOR MAGENTA feet.
    rotate =           'PI/16*sin(2*PI*n/%s)*mod(floor(n/%s)\\,2)',             --%s=fps*period  DEFAULT=0 RADIANS CLOCKWISE. MAY DEPEND ON TIME t & FRAME # n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle. 
    zoompan= '1+.19*(1-cos(2*PI*(in/%s-.2)))*mod(floor(in/%s-.2)\\,2):0:0',     --DEFAULT=1:0:0=zoom:x:y  %s=fps*period  in=INPUT-FRAME-NUMBER=on  BEFORE A SCOOTING RIGHT, IT MAY rotate.  19% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS.
    overlay='(W-w)/2:H*(.75+.05*(1-cos(2*PI*n/%s))*mod(floor(n/%s)+1\\,2))-h/2',--DEFAULT=(W-w)/2:(H-h)/2  %s=fps*period  mod ACTS AS ON/OFF SWITCH.   SPECTRUM y FROM SCREEN TOP (RATIO), BEFORE autocrop.     THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING. CONCEIVABLY A GAMEPAD COULD POSITION A complex. POSITIONING ON TOP OF BLACK BARS MAY DRAW ATTENTION TO THEM.
    
    -- dual_colormix='gb=.4:bb=0',  --UNCOMMENT FOR RED/GREEN DUAL. ADDS 5% CPU USAGE. gb IS CUMULATIVE. MAGENTA/GREEN='gb=.3:bb=0:br=.8:rr=.8'
    dual_alpha   =1.42,             --DEFAULT=1.5  alpha MULTIPLIER. MORE EFFICIENT THAN dual_colormix.
    dual_scale   ={.8,.8},          --RATIOS {WIDTH,HEIGHT}. REMOVE FOR NO DUAL. FULL BI-QUAD CONCEPT COMES FROM HOW RAW MP3 WORKS. IN A SYMPHONY A LITTLE DUAL COULD FLOAT TO VARIOUS INSTRUMENTS, VIOLINS ETC.  IT ALSO EMULATES THE "THIRD EYE", WHICH MIRRORS THE MOUTH.   IT'S ALSO POSSIBLE TO ADD A 3RD LITTLE COMPLEX ON TOP, LIKE PYRAMID. 
    dual_overlay ='(W-w)/2:(H-h)/2',--DEFAULT='(W-w)/2:(H-h)/2' (CENTERED). MAY DEPEND ON t & n, BUT CLEARER IF STATIONARY. IT CAN FLY AROUND, TOO.
    
    highpass=100, --DEFAULT=100 Hz APPLIES ONLY TO volume & freqs, NOT [ao] (AUDIO OUTPUT). DAMPENS SUB-BASS & DC, NEAR volume BAR. 100 Hz FOR BASS HEAVY TRACKS.
    gb      = .3, --DEFAULT= .3  RANGE [-2,2]  PERCENTAGE OF GREEN IN BLUE, BEFORE colormix. PROPERLY COMPLEMENTING RED REQUIRES SOME GREEN. BLUE+0%GREEN IS TOO DARK, ESPECIALLY IF COLOR-BLIND. MOST EFFICIENT CODE SHOULD START WITH CORRECT BLUE/RED SHADES, WITHOUT EXTRA colormix.
    width   =  1, --DEFAULT=  1  OVERALL PRIMARY width RATIO. <1 CAUSES zoompan TO CLIP.
    
    freqs_lead    =.24,      --DEFAULT=.08 SECONDS. LEAD TIME FOR SPECTRUM (TRIAL & ERROR). BACKDATES audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG. DEPENDS ON HUMAN ACOUSTIC/VISION INTERPRETATION TIME, & WHETHER VIEWER IS SQUINTING.
    freqs_resample=2010*1.05,--DEFAULT=2010*1.05 Hz. SAMPLE RATE (SAMPLES/SECOND), DOWN FROM 44100. CALIBRATED WITH 1kHz SIGNAL. 5% OF DATA IS CROPPED OFF, FOR NYQUIST. THESE 4 options ARE FOR CALIBRATION. THIS VERSION ONLY SUPPORTS LR-1kHz. A SINGER'S VOICE CAN GO OVER 1kHz. 
    LR_OVERLAP    =  2,      --DEFAULT=2 PIXELS (AFTER SCALING DOUBLE). MOVES RIGHT CHANNEL ON TOP OF LEFT, @CENTER=0Hz (DATA DRAG). 
    -- CALIBRATION={{100,1},{'200:1',2},{300,1},{'400:1',2},{500,1},{'600:1',2},{700,1},{'800:1',2},{900,1},{'1000:1',2}}, --{{frequency(Hz):beep_factor,volume},}  beep_factor OPTIONAL  sine WAVES FOR CALIBRATION.  THIS EXAMPLE BEEPS DOUBLE ON EVEN.   COULD HELP TEST NORMALIZERS, & DECORATE freqs.  SPECTRUM CALIBRATES VIA 3 NUMBERS: freqs_lead freqs_resample LR_OVERLAP   SYNCHRONY IS freqs_lead.
    
    freqs_alpha        =  .7, --DEFAULT= .7  RANGE [-2,2]  OPAQUENESS OF SPECTRAL DATA CURVE.    DUAL-complex MAY LOOK BETTER TRANSPARENT.
    freqs_fps          =25/2, --DEFAULT=25/2  25fps CAUSES LAG. freqs_clip_h ALSO IMPROVES PERFORMANCE.     BY HALVING grid_fps IT MIGHT BE POSSIBLE TO SPEAR-TIP EACH BATON.
    -- freqs_mode      ='bar',--DEFAULT='line'. CHOOSE line OR bar (OR dot). SET freqs_alpha=.25 FOR bar. GRAPH OPTIMIZED FOR line.
    freqs_win_size     = 512, --DEFAULT=512  INTEGER RANGE [128,2048]. APPROX # OF DATA POINTS. THINNER CURVE WITH SMALLER #. NEEDS AT LEAST 256 FOR PROPER CALIBRATION. TOO MANY DATA POINTS LOOK BAD. TOO MANY PIANO KEYS?
    freqs_win_func     ='parzen',--DEFAULT='parzen'  poisson cauchy flattop MAYBE OK, BUT THE OTHERS ARE UGLY: rect bartlett hanning hamming blackman welch bharris bnuttal bhann sine nuttall lanczos gauss tukey dolph        PARZEN WAS AN AMERICAN STATISTICIAN.
    freqs_averaging    =   2, --DEFAULT=  2  INTEGER, MIN 1. STEADIES SPECTRUM. SLOWS RESPONSE TO AUDIO. TRY 3 IF MORE freqs_fps. 
    freqs_magnification= 1.3, --DEFAULT=1.3  CURVE HEIGHT SCALE FACTOR. REDUCES CPU CONSUMPTION, BUT THE LIPS LOSE TRACTION.    L & R CHANNELS ARE LIKE A DUAL ALIEN MOUTH (LIKE HOW HUMANS ARE BIPEDAL).    TO INCREASE MAGNIFICATION A NEW FILTER IS NEEDED TO STOP EXCESSIVE SHARPNESS.
    freqs_clip_h       =  .3, --DEFAULT= .3  MINIMUM=grid_height (CAN'T CLIP LOWER THAN grid). REDUCES CPU USAGE BY CLIPPING CURVE (CROPS THE TOP OFF SHARP SIGNAL). THE NEED FOR CLIPPING, LOW fps & size PROVE THE CODE MAY BE SLOW.
    
    volume_alpha = .25, --DEFAULT=.25  RANGE [0,2]. 0 REMOVES BARS (feet REMAIN). OPAQUENESS OF volume BARS.    DUAL volume TAKES CENTER STAGE.
    volume_fade  =   0, --DEFAULT=  0  RANGE [0,1].
    -- volume_dm =   1, --UNCOMMENT FOR DISPLAYMAX LINES (RED). DEFAULT=0
    volume_width = .04, --DEFAULT=.04  RANGE (0,1]. WIDTH OF BAR RELATIVE TO VIDEO.
    volume_height= .15, --DEFAULT=.15  RANGE (0,1]. HEIGHT OF BAR (BEFORE STACKING feet), RELATIVE TO SCREEN. autocrop MAY MAGNIFY ITS SIZE.
    
    grid_height    = .1, --DEFAULT= .1  RANGE (0,1]. grid HEIGHT RELATIVE TO SCREEN, BEFORE STACKING feet.  grid TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS.
    grid_thickness =1/8, --DEFAULT= .1  RANGE (0,1], RELATIVE TO grid SPACING. APPROX AS THICK AS CURVE.
    grid_alpha     =  2, --DEFAULT=  2  RANGE [0,2]. (RATIO)  0 REMOVES grid & feet. alpha MULTIPLIES BY volume_alpha.
    feet_alpha     =  2, --DEFAULT=  1  RANGE [0,2]. 0 REMOVES feet. alpha MULTIPLIES BY volume_alpha, FOR PODS.
    feet_height    =.05, --DEFAULT=.05  RANGE [.01,1]. RELATIVE TO BARS. 
    feet_activation= .6, --DEFAULT= .6  RANGE [0,1), RELATIVE TO volume. feet BLINK ON/OFF WHEN volume PASSES THIS THRESHOLD (FROM MAX). THEY'RE ALL CROPPED @THIS HEIGHT, FROM TOP.
    SHOE_COLOR     ='WHITE@.25',--DEFAULT='BLACK@.25'  WHITE OR BLACK SHOES?   THERE CAN ALSO BE ANOTHER OPTION FOR grid_colormix (BLUE/RED OR RED/BLUE BARS?) RED OUTER BARS ARE BAD FOR cropdetect.
    
    format  ='yuv420p',  --DEFAULT='yuv420p'  FINAL format IMPROVES PERFORMANCE. 420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    -- scale={1680,1050},--DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX). scale OVERRIDE.  CONVERTS→CLOSEST MULTIPLES OF 4 (ceil).
    
    -- osd_on_toggle='Audio filters:\n%s\n\nVideo filters:\n%s\n\nlavfi-complex:\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICKING MUTE ENABLES CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
    io_write=' ',   --DEFAULT=''  (INPUT/OUTPUT)  io.write THIS @EVERY CHANGE IN lavfi-complex. PREVENTS EMBEDDED MPV FROM SNAPPING ON COVER ART. MPV MAY COMMUNICATE WITH ITS PARENT APP.
    config  ={
        'osd-font-size 16','osd-border-size 1','osd-scale-by-window no', --DEFAULTS 55,3,yes. TO FIT ALL MSG TEXT: 16p FOR ALL WINDOW SIZES.
        'keepaspect no','geometry 50%', --ONLY NEEDED IF MPV HAS ITS OWN WINDOW, OUTSIDE SMPLAYER. FREE aspect & 50% INITIAL DEFAULT SIZE.
        'force-window yes',  --NEEDED IN LINUX snap VIRTUALBOX, BY TRIAL & ERROR. force-window ENABLES INSTANT lavfi-complex @file-loaded. blend-tiles RUINS RAW-MP3 [vo].
        'vd-lavc-threads 0', --0=AUTO, vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO.
    },
}
o=options   --ABBREV.

for key,val in pairs({fps=25,period=1,overlay='(W-w)/2:(H-h)/2',dual_alpha=1.5,dual_overlay='(W-w)/2:(H-h)/2',rotate='0',zoompan='1:0:0',freqs_lead=.08,freqs_resample=2010*1.05,LR_OVERLAP=2,width=1,highpass=100,gb=.3,freqs_alpha=.7,freqs_fps=25/2,freqs_mode='line',freqs_win_size=512,freqs_win_func='parzen',freqs_averaging=2,freqs_magnification=1.3,freqs_clip_h=.3,volume_alpha=.25,volume_fade=0,volume_dm=0,volume_width=.04,volume_height=.15,grid_height=.1,grid_thickness=.1,grid_alpha=2,feet_alpha=1,feet_height=.05,feet_activation=.6,SHOE_COLOR='BLACK@.25',format='yuv420p',scale={},key_bindings='',toggle_on_double_mute=0,io_write='',config={}})
do if not o[key] then o[key]=val end end --ESTABLISH DEFAULTS. 

for _,option in pairs(o.config) do mp.command('no-osd set '..option) end --set config
if o.period==0 then for key in ('rotate zoompan overlay'):gmatch('%g+')  --NO TIME DEPENDENCE.
    do o[key]=o[key]:gsub('in/%%s','0'):gsub('on/%%s','0'):gsub('n/%%s','0'):gsub('t/%%s','0') end end    --OVERRIDE: THIS CODE ONLY GSUBS "t/%s" ETC (NOT FULLY GENERAL).

FP,CALIBRATION,ORIENTATION = o.fps*o.period,'','' --ABBREV. FP=FRAMES/PERIOD  CALIBRATION MIXES IN SINE WAVE LIST. ORIENTATION IS FOR TOP & BOTTOM.
for key in ('rotate zoompan overlay'):gmatch('%g+') do o[key]=o[key]:format(FP,FP,FP,FP,FP,FP,FP,FP) end  --%s=FRAMES/PERIOD

if o.CALIBRATION then N,CALIBRATION = 0,',[ao]'   --"," SEPERATES THE SINES FROM THE MIX. THE EMPTY table={} IS VALID.
    for M,sine in pairs(o.CALIBRATION) do N,CALIBRATION = M,(',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],M,CALIBRATION,M) end  --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).
    CALIBRATION=('anull[ao]%samix=%d:first,'):format(CALIBRATION,N+1) end   --N+1 STREAMS TO amix, STARTING WITH [a] RELABELLING. SINE WAVES ARE INFINITE DURATION.

ORIENTATION='pad=0:ih*2:0:0:BLACK@0'    --UPRIGHT. pad*2 FOR BOTTOM SIMPLIFIES CODE. 
if o.bottom_scale and o.bottom_scale>0 then BOTTOM=('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'):format(o.bottom_scale,o.bottom_scale) end --scale & pad FOR BOTTOM. PADDING SIMPLIFIES CODE.
if BOTTOM then ORIENTATION=('split[U],%s[D],[U][D]vstack'):format(BOTTOM) end  --[U],[D] = TOP,BOTTOM
if BOTTOM and o.bottom_only then ORIENTATION=BOTTOM..',pad=0:ih*2:0:oh-ih:BLACK@0' end   --bottom_only OVERRIDE. pad DOUBLE.
if o.colormix then ORIENTATION=('colorchannelmixer=%s,%s'):format(o.colormix,ORIENTATION) end --PRIMARY colormix. ADDS 10% CPU USAGE.

if not BOTTOM and o.bottom_only then ORIENTATION='' end --NULL OVERRIDE (fps LIMIT & JPEG loop ONLY).
function f(arg) return math.floor(arg*1e3)/1e3 end  --PRECISION LIMITER. GIVES MORE ELEGANT CODE ON FINAL display & INSPECTION. SIMPLER THAN USING STRINGS. DIVISION MAKES 1/1.5 INFINITE RECURRING.

lavfi=('[aid%%d]%sasplit[ao],stereotools,highpass=%s,dynaudnorm=500:5:1:100:0:0:1:1,asplit[af],showvolume=%s:0:128:8:%s:t=0:v=0:o=v:dm=%s:dmc=RED,colorchannelmixer=aa=%s:bg=1:gg=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(%s),lut=a=val*(%s):g=0,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lut=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aresample=%s,asetpts=PTS-(%s)/TB,apad,dynaudnorm=500:5:1:100:0:0:1:1,showfreqs=300x500:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw/1.05:ih*(%s):0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90):0:255*gt(val\\,90),scale=ceil(iw/4)*4:ceil(ih/4)*4,format=rgb32,split[L],colorchannelmixer=bb=0:aa=0:ar=%s[R],[L]colorchannelmixer=bb=0:aa=0:ab=%s:rb=1:rr=0,hflip[L],[grid][L]scale2ref=iw*2-(%s):ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w:0:endall,scale=ceil(iw/4)*4:ih,split=3[L][R],crop=iw/2[MIDDLE],[L]crop=iw/4:ih:0,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[L],[R]crop=iw/4:ih:iw-ow,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[R],[L][MIDDLE][R]hstack=3[vid],[vol][vid]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,split=3[C][T],setpts=PTS-STARTPTS[vo],[C]crop=1:1:0:0:1:1,format=ya16,lut=a=0[C],[C][vid]scale2ref,overlay,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[vo][vid]overlay=%s[vo],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[T],[T][vo]concat,trim=start_frame=1[vo]')
    :format(CALIBRATION,o.highpass,o.fps,o.volume_fade,o.volume_dm,o.volume_alpha,o.gb,o.feet_height,o.feet_activation,o.feet_alpha,o.SHOE_COLOR,o.gb,o.gb,o.grid_alpha,o.grid_thickness,o.grid_thickness,f(o.grid_height/o.freqs_clip_h),o.freqs_resample,o.freqs_lead,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,f(o.freqs_clip_h/o.freqs_magnification),o.freqs_alpha,o.freqs_alpha,o.LR_OVERLAP,o.gb,o.gb,o.gb,o.gb,o.volume_width,f(o.volume_height/o.freqs_clip_h),ORIENTATION,o.rotate,o.zoompan,o.fps,o.overlay)    --gb*7 TO PROPERLY INVERT WHITE SHOES RE. RED & BLUE. fps FOR volume, freqs & zoompan. feet_alpha REPEATS FOR INNER & OUTER [FEET]. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha REPEATS FOR L & R CHANNELS. 

----lavfi            =graph  LIBRARY-AUDIO-VIDEO-FILTER LIST. SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH LINE DUPLICATION ETC. lavfi-complex MAY COMBINE MANY [aid#] & [vid#] INPUTS. %% SUBS OCCUR LATER. A lavfi string IS LIKE DNA & CAN CREATE ANY CREATURE. SEE ffmpeg-filters MANUAL.  EACH FOOT HAS A STEREO IN IT, IN THIS VERSION. [feet0] IS THE CENTER-PIECE.  [T] & [C] CODES ALWAYS VALID, EVEN ON YOUTUBE & FOR MP4 SUBCLIPS WITH OFF STARTPTS. IMPOSSIBLE TO CORRECTLY ENTER NUMBERS LIKE time-pos OR audio-pts. CANVAS [C] IS FOR zoompan TO BE IN SYNC BTWN SPECTRA + automask. [C] SWITCHES audio→video TIMESTAMPS.
----trim,atrim       =...:start_frame:end_frame,start  YOUTUBE BUGFIX - ALWAYS TRIM THE STREAMS.  TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP. trim DOESN'T CHANGE PTS.
----split,asplit     =outputs  (DEFAULT 2)  CLONES audio,video. aid MAY BE KNOWN IN ADVANCE, BUT NOT NECESSARILY.
----setpts,asetpts   =expr  PRESENTATION TIMESTAMP.  FOR SYNC OF rotate,zoompan,position WITH OTHER GRAPHS (automask), EVEN FOR OFF-INITIAL TIMESTAMPS. AFTER SENDING STARTPTS→0, SUBTRACT 1 FRAME FROM TIMESTAMP FRAME [T], BECAUSE THAT TIME IS FOR WHATEVER FOLLOWS IT.   asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO. LAG MAY DEPEND ON averaging size rate ETC.  
----pad,apad         =w:h:x:y:color    BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih. MAY BE SLOW COMPARED TO scale (format CLASH?).  apad APPENDS SILENCE FOR SPECTRUM TO ANALYZE, OR THERE'S A CRASH @end-file.
----sine             =frequency:beep_factor  (Hz,BOOL) DEFAULT=440:0  CALIBRATION sine WAVES. beep IS EVERY SECOND.
----volume           =volume  (0→100) CALIBRATION sine VOLUMES. FORMS TRIPLE WITH sine & amix.
----amix             =inputs:duration  DEFAULT 2:longest  MIXES IN CALIBRATION audio. [a1][a2]...→[a]
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo.     PREFERRED ALTERNATIVE TO aformat.
----highpass         =frequency (Hz) DAMPENS SUB-BASS. ~50Hz IS POWER & REFRESH RATE.   UNFORTUNATELY afftfilt IS TOO BUGGY - IT WOULD ALLOW FINE TUNING SHARP VS. BLAND TONES.
----dynaudnorm   →s64=f:g:p:m:r:n:c:b  DEFAULTS 500:31:.95:10:0:1:0:0    FRAME(MILLISECONDS):GAUSSIAN_WIN_SIZE(ODD INTEGER):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:CORRECTION_DC(BOOL):BOUNDARY_MODE(BOOL,NO FADE)     DYNAMIC AUDIO NORMALIZER. b DISABLES FADE (NOT FOR SPECTRUM). IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g GIVES FASTER RESPONSE. f CAUSES BUG (BAD PERFORMANCE). RENORMALIZING FRAMES OPTIONAL, AFTER CHANGING STARTPTS. I USE dynaudnorm THRICE ALWAYS. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT THEY ARE WORSE. 
----showvolume[a]→[v]=rate:b:w:h:f:...:t:v:o = rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION    (DEFAULTS 25:1:400:20:0.95:t=1:v=1:o=h)   LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED.    THERE'S SOME MINOR BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----aresample         (Hz) DOWNSAMPLES TO ~2.1kHz (NYQUIST+5%). AN ALTERNATIVE IS aformat.   MORE OVERHEAD REDUCES RESOLUTION FOR THE ENTIRE SPECTRUM.
----showfreqs [a]→[v]=size:RATE:mode:ascale:fscale:win_size:win_func:overlap:averaging:colors  DEFAULTS 1024x512:25:bar:log:lin:2048:hanning:1:1   RATE CRASHES LINUX snap, SO THESE NEED TO BE SPELLED OUT FOR COMPATIBILITY. size SHOULD HAVE ASPECT ~300x500 FOR HEALTHY CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (E.G. 300x300 & 300x700 GIVE BAD CURVES). SEPARATING CHANNELS WITHOUT COLORS (cmode=separate) WOULD REQUIRE TWICE AS MANY PIXELS.
----colorchannelmixer=rr:...:aa   (RANGE -2→2, r g b a PAIRS) CONVERTS GREEN TO BLUE, RED TO BLUE, SEPARATES LEFT/RIGHT & LOWS/HIGHS, ETC.  SPECIAL BECAUSE IT COULD BE SLOW SO EXTRA CODE AVOIDS INSERTING IT. SOME FILTERS LIKE geq (GLOBAL EQUALIZER) ARE TOO POWERFUL & SLOW & CAN'T BE USED.
----crop             =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES [LOWS].
----lut,lutyuv       =...:a  LOOK-UP-TABLE,BRIGHTNESS-UV  lutyuv MORE EFFICIENT THAN lutrgb. CREATE TRANSPARENCY, & SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.  lutyuv CAN BLANK CANVAS.
----avgblur          =sizeX   (PIXELS)  AVERAGE BLUR. CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTH CURVE.
----fps              =fps:start_time   (FRAMES PER SECOND:SECONDS) LIMITS @file-loaded. ALSO FOR OLD MPV showfreqs. start_time INSTEAD OF setpts.
----scale,scale2ref  =width:height  DEFAULT iw:ih  SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.     TO-REFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume. CALIBRATES LR_OVERLAP.
----overlay          =x:y:eof_action  (DEFAULT 0:0:repeat)  endall DUE TO apad. OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON TIME t.     UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4. 
----hflip,vflip       FLIPS THE LEFT CHANNEL LEFT.  vflip FOR BOTTOM [D] (FOR DOWN).
----hstack,vstack    =inputs  COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES FEET.    FUTURE VERSION MIGHT ADD OR SUBTRACT MORE TICKS (E.G. TO 1.2kHz).      vstack FOR ORIENTATION & FEET.
----select           =expr  (EXPRESSION)  DISCARDS FRAMES IF 0.  OPTIONAL: FOR COMPATIBILITY WITH OLD MPV, select FOR [T].
----rotate           =angle:ow:oh:fillcolor  (RADIANS:PIXELS) ROTATES ORIENTATION clockWISE, DEPENDENT ON TIME t & FRAME n.
----zoompan          =zoom:x:y:d:s:fps   (z>=1) d=0 FRAMES DURATION-OUT PER FRAME-IN. MAY DEPEND ON in,on INPUT-NUMBER,OUTPUT-NUMBER    SLOW FILTER, LIKE geq.
----concat[T][vo]→[vo] CONCATENATE STARTING TIMESTAMP WHENEVER USER SEEKS. NEEDED TO SYNC WITH automask.
----format           =pix_fmts  (rgb32 rgb24 ya16 yuv420p ...)  CONVERSIONS MAY IMPROVE EFFICIENCY. FINALIZES format @GPU (CAN CHECK MPV LOG).
----setsar           =sar  IS THE FINISH. FINALIZES scale @GPU (CAN CHECK MPV LOG). ALSO STOPS EMBEDDED MPV SNAPPING (CAN VERIFY WITH DOUBLE-mute TOGGLE IN SMPLAYER). MACOS BUGFIX REQUIRES sar.

----loop             =loop:size  (loop>=-1 : size>0) PAIRS WITH fps FOR RAW JPEG, WHICH IS ITS OWN CASE-STUDY WITH ITS OWN FILTER (MOST ELEGANT).
----anull,anullsrc,anullsink  FOR NULL lavfi-complex. anull RE-LABELER FOR CALIBRATION & TOGGLE OFF. 

mp.set_property('lavfi-complex','anullsrc,anullsink')    --WARN OTHER SCRIPTS. CAN'T REFER TO [vid1] NOR [aid1], WHICH MAY NOT EXIST.
io.write(o.io_write)


function file_loaded(event)  --ALSO on_aid, on_vid, on_toggle, on_seek & ytdl.
    if OFF then return end  --BUG: CAN'T CHANGE TRACK WHEN OFF.
    image,aid,vid = false,mp.get_property_number('current-tracks/audio/id'),mp.get_property_number('current-tracks/video/id') --image=BOOL  'aid' & 'vid' MAYBE='auto', BUT id=nil OR INTEGER. 
    
    if event then new_aid,new_vid = nil,nil end --RESET NEW ID SWITCHES.
    if new_aid then aid=new_aid end --on_aid OVERRIDE.
    if new_vid then vid=new_vid end --on_vid OVERRIDE.
    
    for _,track in pairs(mp.get_property_native('track-list')) do if track.type=='video' and track.id==vid and track.image then image=true end end  --LOOP OVER ALL TRACKS TO CHECK IF vid IS image.
    if image and o.io_write=='' then o.io_write=' ' end --JPEG NEEDS io_write FIX OR IT SNAPS MORE OFTEN.
    mp.observe_property('lavfi-complex','string',function() io.write(o.io_write) end)
    
    W,H = o.scale[1],o.scale[2]  --scale OVERRIDE. 
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --LINUX & MACOS VIRTUALBOX.
    if not (W and H) then W,H = 1280,720 end --RAW MP3 LINUX & MACOS VIRTUALBOX (720p FALLBACK).
    W,H = math.ceil(W/4)*4,math.ceil(H/4)*4  --MULTIPLES OF 4 NECESSARY FOR PERFECT overlay. 
    
    complex,clip_h = nil,math.ceil(H*o.freqs_clip_h*2/4)*4 --complex=GRAPH SUBSTRING  clip_h=FINAL CLIP HEIGHT FOR TOP & PADDED BOTTOM (*2).
    if not aid then ORIENTATION='' end
    
    ----5 CASES. 1) JPEG & COVER ART (NO SPECTRUM)  2) MP4 LIMITS (NO SPECTRUM)  3) MP3  4) MP3+JPEG  5) MP4     INSPECT MPV LOG TO VERIFY CORRECT GPU OUTPUT IN EVERY CASE. INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. E.G. automask albumart ANIMATION.
    if             image then complex=('[vid%d]%%s,loop=-1:1,fps=%s:%s'):format(vid,o.fps,mp.get_property_number('time-pos')) end   --CASE 1: RAW JPEG. start_time FOR --start (JPEG seek).
    if vid and not image then complex=('[vid%d]fps=%s,%%s'):format(vid,o.fps) end   --CASES 2 & 5: NORMAL video. [vo] MAY BE SPECIFIED WITHOUT [ao].
    if complex then complex=complex:format('scale=%d:%d,setsar=1,format=%s'):format(W,H,o.format) end --CASES 1, 2 & 5. scale INSERT, ETC.
    
    if vid and ORIENTATION=='' then mp.set_property('lavfi-complex',complex..'[vo]') end    --set CASES 1 & 2
    if ORIENTATION=='' then if not complex then mp.set_property('lavfi-complex','') end  --REMOVE NULL complex. OTHER SCRIPTS CAN CHECK BACK WITHIN 50ms.
        return end --CASES 3,4,5 BELOW. complex VARIABLE MUST PRODUCE %%s=[vo] INSERT.

    if not vid then complex=                       ('[vid]split[vid],crop=1:1:0:0:1:1,lutyuv=0:128:128:0,scale=%d:%d,setsar=1,format=%s'):format(W,H,o.format) end --CASE 3: RAW MP3. BUILD [vo] FROM BLANK 1x1. scale BEFORE format.
    if   image then complex=('[vid%d]scale=%d:%d[vo],[vid]split[vid],crop=1:1:0:0:1:1,lutyuv=0:128:128:0[C],[C][vo]scale2ref,overlay,setsar=1,format=%s'):format(vid,W,H,o.format) end --CASE 4: MP3 COVER ART. format,setsar GO AFTER overlay ()!  FOR PROPER MOTION, [vo] GETS SANDWICHED BTWN CANVAS [C] & [vid] (SPECTRUM). 
    
    if o.dual_scale then complex=('%s[vo],[vid]split[vid]%%s,lut=a=val*(%s),scale=%d:%d[v2],[vo][v2]overlay=%s')
                           :format(complex,o.dual_alpha,math.ceil(W*o.dual_scale[1]/4)*4,math.ceil(clip_h*o.dual_scale[2]/4)*4,o.dual_overlay)   --[v2]=DUAL overlay   LABELS [vid1][vid2] ETC NOT ALLOWED (RESERVED).
        if o.dual_colormix then complex=complex:format(',colorchannelmixer='..o.dual_colormix) end end --ADDS 5% CPU USAGE.
    mp.set_property('lavfi-complex',lavfi:format(aid,complex:format(''),W*o.width,clip_h))    --CASES 3,4,5.  size FOR zoompan.  %s='' TERMINATES FORMATTING.
end 
mp.register_event('file-loaded',file_loaded)   --INSTANT LOAD OR EMBEDDED MPV SNAPS.
mp.register_event('seek',function() if mp.get_property_number('time-remaining')==0 then mp.command('stop') end end)   --BUGFIX FOR seek PASSED end-file. A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES PASSED end-file. THIS LINE IS SIMPLE SOLUTION.

function on_aid(_,aid)  --UNTESTED. ONLY GOOD FOR 1 SWITCH.
    if last_aid and last_aid~=aid then new_aid=1
        if          last_aid==1   then new_aid=2 end
        on_toggle()
        on_toggle() end
    last_aid=aid    --REMEMBER aid.
end
mp.observe_property('aid','number',on_aid)

function on_vid(_,vid)  --ONLY GOOD FOR 1 SWITCH IN vid, BTWN 1 & 2.
    if last_vid and last_vid~=vid then new_vid=1
        if          last_vid==1   then new_vid=2 end
        on_toggle() --BUGFIX: CAN SWITCH vid EVEN WHEN OFF. DOUBLE-toggle WORKS.
        on_toggle() end
    last_vid=vid    --REMEMBER vid.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded.

function on_toggle(mute)    --WON'T CHANGE vid OR aid WHEN TOGGLED OFF (BUG).
    if not W then return end --NOT loaded YET.
    if mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.
        return end
    
    OFF=not OFF --REMEMBER TOGGLE STATE.
    if not OFF then file_loaded()   --TOGGLE ON.    UNFORTUNATELY THIS SNAPS COVER ART IN SMPLAYER (EVERY TIME).
    elseif ORIENTATION~='' then complex=('[aid%d]anull[ao]'):format(aid) --TOGGLE OFF CASE 3: RAW audio. STILL FRAME SPECTRUM, audio PLAYS ON.  CASES 4 & 5 BUILD ON THIS.   CASES 1 & 2 DO NOTHING. OPEN TO INTERPRETATION: NO SPECTRUM, NO TOGGLE OFF.   1) JPEG. 2) MP4 LIMITS. 3) MP3 SPECTRUM. 4) MP3+JPEG. 5) MP4.
        if   image then complex=('%s,[vid%d]%%s,loop=-1:1,fps=%s:%s[vo]'):format(complex,vid,o.fps,mp.get_property_number('time-pos')) --CASE 4: COVER ART. NEED start_time FOR ZOOMING automask (E.G. CAN TOGGLE "F1" @30MINS). STILL USES APPROX 5% CPU TO INFINITE loop.    MACOS TAKES A STILL FRAME (DIFFERENT, BUT VALID).
        elseif vid then complex=('%s,[vid%d]fps=%s,%%s[vo]'):format(complex,vid,o.fps) end   --CASE 5. LIMIT [vo], WITH NO SPECTRUM.
        complex=complex:format('scale=%d:%d,format=%s,setsar=1'):format(W,H,o.format)
        mp.set_property('lavfi-complex',complex) end
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
for key in o.key_bindings:gmatch('%g+') do mp.add_key_binding(key, 'toggle_complex_'..key, on_toggle) end --MAYBE SHOULD BE 'toggle_spectrum_' BECAUSE THIS TOGGLE ONLY TURNS OFF/ON THE SPECTRUM.
mp.observe_property('mute', 'bool', on_toggle)

timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)  --double_mute timer CARRIES OVER TO NEXT FILE IN MPV PLAYLIST.
timer.oneshot=true
timer:kill() 


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS, LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB, & DESCRIPTION OF 5 CASES. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----VERBOSE MESSAGES MAY ALLOW CHANGING TRACK IN SMPLAYER (BUT UGLY). E.G.:   {"event" = "log-message", "level" = "v", "text" = "Set property: aid=2 -> 1    ", "prefix" = "cplayer"}
----MINOR BUG: COVER ART COLORS MAY BECOME MORE INTENSE WITH SPECTRAL OVERLAY. VERIFY USING TOGGLE. COLORMATRIX?

----ALTERNATIVE FILTERS:
----asettb       =tb    OPTIONAL TIMEBASE SPEC. MAY PROVIDE fps HINT TO FURTHER FILTERS.
----sendcmd       ISN'T CURRENTLY AVAILABLE IN MPV FOR lavfi-complex. NO INSTA-TOGGLE.
----afftfilt     =...:win_size:win_func:overlap  OPTIONAL     DEFAULTS 4096:hann:0.75  (AUDIO FAST FOURIER TRANSFORM FILTER) overlap<1 CAUSES BUG. ALONG WITH aeval ALLOWS PROCESSING SPECTRUM audio STREAM.
----loudnorm     =I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). CAUSED DEFECT REQUIRING apad.
----acompressor   SMPLAYER DEFAULT NORMALIZER. LOOKS BAD.
----shuffleplanes=map0:map1:map2:map3   DEFAULT 0:1:2:3  MAY NOT BE LINUX snap COMPATIBLE (MAY DEPEND ON colormatrix). SHUFFLES COLORS. ORDERED g:b:r:a (LIKE GreatBRitAin).
----extractplanes=planes    r+b→[R][L] (RED+BLUE)   REVERSED BECAUSE [L] GETS FLIPPED AROUND.
----alphamerge    [y][a]→[ya]  USES lum OF [a] AS alpha OF [ya]. PAIRS WITH split TO CONVERT BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey, colorchannelmixer & shuffleplanes.

----OPTION DUMP. FOR DEBUGGING TRY TOGGLE ALL THESE SIMULTANEOUSLY. SOMETIMES WHOLE LINES OF CODE CAN BE DELETED WITH THE CORRECT OPTION.
-- 'video-timing-offset 1','hr-seek-demuxer-offset 1','cache-pause-wait 0',
-- 'video-sync desync','vd-lavc-dropframe nonref','vd-lavc-skipframe nonref',   --none default nonref(SKIPnonref) bidir(SKIPBFRAMES) 
-- 'demuxer-lavf-buffersize 1e9','demuxer-max-bytes 1e9','stream-buffer-size 1e9','vd-queue-max-bytes 1e9','ad-queue-max-bytes 1e9','demuxer-max-back-bytes 1e9','audio-reversal-buffer 1e9','video-reversal-buffer 1e9','audio-buffer 1e9',
-- 'chapter-seek-threshold 1e9','vd-queue-max-samples 1e9','ad-queue-max-samples 1e9',
-- 'demuxer-backward-playback-step 1e9','cache-secs 1e9','demuxer-lavf-analyzeduration 1e9','vd-queue-max-secs 1e9','ad-queue-max-secs 1e9','demuxer-termination-timeout 1e9','demuxer-readahead-secs 1e9', 
-- 'video-backward-overlap 1e9','audio-backward-overlap 1e9','audio-backward-batch 1e9','video-backward-batch 1e9',
-- 'hr-seek always','index recreate','wayland-content-type none','background red','alpha blend',
-- 'hr-seek-framedrop yes','framedrop decoder+vo','access-references yes','ordered-chapters no','stop-playback-on-init-failure yes',
-- 'initial-audio-sync no','vd-queue-enable yes','ad-queue-enable yes','demuxer-seekable-cache yes','cache yes','demuxer-cache-wait no','cache-pause-initial no','cache-pause no',
-- 'keepaspect-window no','video-latency-hacks yes','demuxer-lavf-hacks yes','gapless-audio no','demuxer-donate-buffer yes','demuxer-thread yes','demuxer-seekable-cache yes','force-seekable yes','demuxer-lavf-linearize-timestamps no',

----ALTERNATIVE GRAPH EXAMPLES:
--EXTRACTPLANES LR MONOCHROME (NOT FASTER):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(CALIBRATION,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,o.freqs_resample,o.freqs_lead,o.highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_magnification,o.LR_OVERLAP,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,ORIENTATION,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 
--SHUFFLEPLANES: lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--512x1024       lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=512x1024:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,avgblur,lut=b=255*gt(val\\,80):r=255*gt(val\\,80):a=0,avgblur=2,lut=b=255*gt(val\\,110):r=255*gt(val\\,110),split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--128x256        lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=128x256:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,scale=iw*4:-1,avgblur,lut=b=255*gt(val\\,210):r=255*gt(val\\,210):a=0,avgblur=2,lut=b=255*gt(val\\,100):r=255*gt(val\\,100),split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--ONLY 1 AVGBLUR lavfi=('[aid%%d]asplit[ao],stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%%s:0:256:4:%s:t=0:v=0:o=v,lut=b=0:a=val*(%s),format=rgb32,shuffleplanes=1:0:2:3,split[BAR],crop=iw/4:ih*(%s),lut=b=0:a=255,pad=iw*2:ih+(ow-iw)/a/3:(ow-iw)/2:oh-ih:WHITE@.25,split,hstack[FEET],[BAR][FEET]vstack,split=3[volume][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:iw-ow,pad=iw+2:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-2:ih:0,pad=iw+2:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aresample=2100,asetpts=PTS+(%s)/TB,highpass=50,dynaudnorm=p=1:m=100:c=1:b=1,showfreqs=512x1024:%s:line:lin:lin:%s:parzen:1:%s:BLUE|RED,crop=iw/1.04-1:ih*(%s):0:ih-oh,avgblur,lut=b=255*gt(val\\,50):r=255*gt(val\\,50):a=0,split[R],hflip,format=rgb32,shuffleplanes=0:1:0:1,lut=a=val*(%s)[L];[R]format=rgb32,shuffleplanes=0:2:0:2,lut=a=val*(%s)[R],[GRID][R]scale2ref=iw*2-3:ih/(%s)[GRID][R],[GRID][R]overlay=W-w:H-h[GRID],[GRID][L]overlay=0:H-h,scale=ceil(iw/4)*4:ih,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,format=rgb32,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[overlay],[volume][overlay]scale2ref=floor(iw*%s/4)*4:ih*(%s)[volume][overlay],[overlay][volume]overlay=(W-w)/2:H-h%s[overlay],')
--CURVES OUTLINES USING SPLIT,ALPHAMERGE lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,split,alphamerge,lut=r=0:g=0:b=255*gt(val\\,90):a=255*gt(val\\,90)*(%s),format=rgb32[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--WITH MIDDLE FOOT: lavfi=('[aid%%d]atrim=%%s,asetpts=PTS-STARTPTS+(%%s)/TB,asplit[ao]%s,stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%s:0:%d:8:%s:t=0:v=0:o=v:dm=%s,colorchannelmixer=gg=%s:bg=1:aa=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(%s),colorchannelmixer=rb=1:gr=%s:br=1:rr=0:gg=0:bb=0:aa=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:BLACK@%s,split[FOOT],split,hstack[feet],[FOOT]colorchannelmixer=rb=1:br=1:rr=0:bb=0:aa=2,scale=iw*2:ih[FOOT],[vol][FOOT]vstack[vol],[BAR][feet]vstack,lut=a=val*(%s),split[grid-R],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[grid-L],[grid-R]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[grid-R],[grid-L][grid-R]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aformat=s16:%s,highpass=%s,apad,dynaudnorm=p=1:m=100:c=1:b=1,asetpts=PTS-(%s)/TB,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90):0:255*gt(val\\,90),format=rgb32,split[L],colorchannelmixer=bb=0:ar=%s:aa=0[R],[L]colorchannelmixer=bb=0:ab=%s:aa=0:rb=1:rr=0,hflip[L],[grid][R]scale2ref=iw*2-(%s):ih,overlay=W-w:0:endall[grid],[grid][L]overlay=0:0:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HI-R][LOWS],crop=iw/4:ih:0,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-L],[LOWS]crop=iw/2[LOWS],[HI-R]crop=iw/4:ih:iw-ow,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-R],[HI-L][LOWS][HI-R]hstack=3[vid],[vol][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,setpts=PTS-STARTPTS[vo],[vid]setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[vo][vid]overlay=%s,setpts=PTS+(%%s)/TB,format=%s,setsar=1[vo]'):format(CALIBRATION,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_dm,o.gb,o.volume_alpha,o.feet_height,o.feet_activation,o.gb,o.feet_alpha,o.feet_alpha/4,o.grid_alpha,o.grid_thickness,o.grid_thickness,f(o.grid_height/o.freqs_clip_h),o.freqs_resample,o.highpass,o.freqs_lead,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,f(o.freqs_clip_h/o.freqs_magnification),o.freqs_alpha,o.freqs_alpha,o.LR_OVERLAP,o.gb,o.gb,o.volume_width,f(o.volume_height/o.freqs_clip_h),ORIENTATION,o.rotate,o.zoompan,o.fps,o.overlay,o.format)    --fps FOR volume, freqs & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER [FEET]. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha REPEATS FOR L & R CHANNELS. 



