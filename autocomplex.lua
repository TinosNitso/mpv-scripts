----lavfi-complex SCRIPT WHICH LIMITS fps & scale; LOOPS albumart & IMAGES; & OVERLAYS STEREO FREQUENCY SPECTRUM + volume BARS (AUDIO VISUALS) ONTO MP4, AVI, MP3 (RAW & albumart), MP2, M4A, WAV, OGG, AC3, OPUS & YOUTUBE.  
----CAN USE DOUBLE-mute TO toggle. ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY sine_mix CAN BE ADDED FOR CALIBRATION & DECORATION. MOVES & ROTATES WITH TIME.  CHANGING TRACKS IN SMPLAYER MAY REQUIRE STOP & PLAY (aid=vid=no LOCK BUG).
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. 

o={ --options  ALL OPTIONAL & MAY BE REMOVED.   TO REMOVE AN INTERNAL COMPONENT SET ITS alpha TO 0 (freqs volume grid feet shoe).
    toggle_on_double_mute=.5,  --SECONDS TIMEOUT FOR DOUBLE-mute TOGGLE. SLOW, SO REMOVE FOR OTHER GRAPHS TO INSTA-TOGGLE. ALL LUA SCRIPTS CAN BE TOGGLED USING DOUBLE mute (m&m DOUBLE-TAP).
    key_bindings         ='F1',--CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  s=SCREENSHOT NOT SPECTRUM. f=FULLSCREEN NOT FREQS, o=OSD NOT OVERLAY, C=autocrop. v FOR VOLUME?  'F1 F2' FOR 2 KEYS.
    -- osd_on_toggle='Audio filters:\n%s\n\nVideo filters:\n%s\n\nlavfi-complex:\n%s', --DISPLAY ALL ACTIVE FILTERS on_toggle. DOUBLE-CLICK MUTE FOR FINAL CODE INSPECTION INSIDE SMPLAYER. %s=string. SET TO '' TO CLEAR osd.
    
    vflip_scale=.5,     --REMOVE FOR NO BOTTOM HALF. WIDTH=1.     SOME FUTURE VERSION MIGHT SUPPORT BL & BR CHANNELS FOR BOTTOM.
    -- vflip_only =true,--REMOVES TOP HALF. TOGGLE THESE 2 LINES FOR NULL OVERRIDE (NO SPECTRAL overlay).
    -- sine_mix={{100,1},{'200:1',2},{300,1},{'400:1',2},{500,1},{'600:1',2},{700,1},{'800:1',2},{900,1},{'1000:1',2}}, --{{frequency(Hz):beep_factor,volume},}  beep_factor OPTIONAL  sine WAVES FOR CALIBRATION MIX DIRECTLY INTO [ao].  THIS EXAMPLE BEEPS DOUBLE ON EVEN.   COULD ALSO HELP TEST NORMALIZERS, & DECORATE freqs.
    
    fps   =    30 , --DEFAULT=30 FRAMES PER SECOND FOR [vo]. SCRIPT ALSO LIMITS scale. 
    period='22/30', --DEFAULT= 1 SECOND. SET TO 0 FOR STATIONARY. USE fps RATIO. 22/30→82BPM, BEATS PER MINUTE. UNLIKE A MASK, MOTION MAY NOT BE PERIODIC - ENSEMBLE FREE TO RANDOMLY FLOAT AROUND. (IF 0, "n/%s"→"0" GSUBS OCCUR, ETC). 
    
    -- colormix='gb=.4:bb=0', --UNCOMMENT FOR RED/GREEN, INSTEAD OF RED/BLUE (DEFAULT). gb IS CUMULATIVE. ADDS ~10% NET CPU USAGE (CAN CHECK TASK MANAGER), EVEN AS A NULL-OP. aa FOR TRANSPARENCY.     GREY='rr=.7:gr=.7:br=.7:rb=.3:bb=.3'.  BLUE, DARKBLUE & BLACK ARE COMPATIBLE WITH cropdetect (autocrop). RED FOR LIPS. RED & BLUE FOR MAGENTA feet.   BLUE & WHITE STRIPES IS A DIFFERENT DESIGN, LIKE GREEK FLAG (NO RED).
    rotate =                 'PI/16*sin(2*PI*n/%s)*mod(floor(n/%s)\\,2)',        --%s=(period*volume_fps)  DEFAULT=0 RADIANS CLOCKWISE. MAY DEPEND ON TIME t & FRAME # n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle. 
    zoompan=        '1+.2*(1-cos(2*PI*(on/%s-.2)))*mod(floor(on/%s-.2)\\,2):0:0',--%s=(period*volume_fps)  zoom:x:y  DEFAULT=1:0:0  %s=volume_fps*period  in,on = INPUT,OUTPUT NUMBERS  BEFORE A SCOOTING RIGHT, IT MAY rotate (20% OFFSET).  20% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS.  on IS MORE FUNDAMENTAL THAN in (OUTPUT SYNC).
    overlay='(W-w)/2:H*(.75+.05*(1-cos(2*PI*n/%s))*mod(floor(n/%s)+1\\,2))-h/2', --%s=(period*fps)  FILM fps FOR overlay. DEFAULT=(W-w)/2:(H-h)/2  %s=volume_fps*period  mod ACTS AS ON/OFF SWITCH.   SPECTRUM y FROM SCREEN TOP (RATIO), BEFORE autocrop.     THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING. CONCEIVABLY A GAMEPAD COULD POSITION A complex. POSITIONING ON TOP OF BLACK BARS MAY DRAW ATTENTION TO THEM.
    
    -- dual_colormix='gb=.4:bb=0', --UNCOMMENT FOR RED/GREEN DUAL. ADDS 5% CPU USAGE. gb IS CUMULATIVE. MAGENTA/GREEN='gb=.3:bb=0:br=.8:rr=.8'
    dual_alpha  ='1/.7',             --DEFAULT=1.5  alpha MULTIPLIER. MORE EFFICIENT THAN dual_colormix.
    dual_scale  ={.75,.75},        --RATIOS {WIDTH,HEIGHT}. REMOVE FOR NO DUAL.  FULL BI-QUAD CONCEPT COMES FROM HOW RAW MP3 WORKS. IN A SYMPHONY A LITTLE DUAL COULD FLOAT TO VARIOUS INSTRUMENTS, VIOLINS ETC.  THIS DUAL USES THE SAME aid. IDEAL DESIGN MIGHT NEED A BOSS MIC/aid (SPECIAL DUAL).  IT'S ALSO POSSIBLE TO ADD A 3RD LITTLE COMPLEX ON TOP, LIKE PYRAMID. 
    dual_overlay='(W-w)/2:(H-h)/2',--DEFAULT='(W-w)/2:(H-h)/2' (CENTERED). MAY DEPEND ON n & t, BUT CLEARER IF STATIONARY. IT CAN FLY AROUND, TOO.  %s=(period*fps)
    
    highpass  =100, --DEFAULT=100 Hz  DAMPENS SUB-BASS & DC, NEAR volume BAR. 100 Hz FOR BASS HEAVY TRACKS. highpass & dynaudnorm APPLY ONLY TO VISUALS, NOT [ao].  afftfilt COULD ENABLE MULTIPLICATION BY FREQUENCY. A CHIRP IS MUCH LOUDER @DOUBLE FREQUENCY. highpass ISN'T THE RIGHT FILTER.
    dynaudnorm='500:5:1:100:0:1:0:1', --f:g:p:m:r:n:c:b  DEFAULT=500=500:31:.95:10:0:1:0:0  APPLIES TWICE, BEFORE & AFTER aresample & freqs_lead_t. SEE GRAPH SECTION FOR DETAILS.
    gb        = .3, --DEFAULT=.3  RANGE [-2,2]  GREEN IN BLUE RATIO, BEFORE colormix. PROPER COMPLEMENT OF RED REQUIRES SOME GREEN. BLUE+0*GREEN IS TOO DARK. COLOR-BLINDNESS MIGHT BE AN ISSUE. MOST EFFICIENT CODE SHOULD START WITH CORRECT BLUE/RED SHADES, WITHOUT EXTRA colormix.
    width     =  1, --DEFAULT= 1  OVERALL PRIMARY width RATIO. <1 CAUSES zoompan TO CLIP.
    
    freqs_lead_t       = .24, --DEFAULT=.08 SECONDS. LEAD TIME FOR SPECTRUM (TRIAL & ERROR). BACKDATES audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG. DEPENDS ON HUMAN VISION/ACOUSTIC INTERPRETATION TIME, & CONCENTRATION.
    freqs_fps          =25/2, --DEFAULT=25/2 30fps CAUSES FILM LAG/STUTTER. freqs_clip_h ALSO IMPROVES PERFORMANCE.  WORKS WELL ENOUGH WITH SLOW AUDIO.   
    freqs_fps_image    =  30, --DEFAULT=25   FOR RAW MP3 ALSO. CAN EASILY DOUBLE fps.  THIS SCRIPT WAS WRITTEN WITHOUT PROPRIETARY GRAPHICS DRIVERS, HENCE THE LIMITED freqs_fps.
    -- freqs_mode      ='bar',--DEFAULT='line'. CHOOSE line OR bar (OR dot). SET freqs_alpha=.25 FOR bar. GRAPH OPTIMIZED FOR line.
    freqs_win_size     = 512, --DEFAULT=512  INTEGER RANGE [128,2048]. APPROX # OF DATA POINTS. THINNER CURVE WITH SMALLER #. NEEDS AT LEAST 256 FOR PROPER CALIBRATION. TOO MANY DATA POINTS LOOK BAD. TOO MANY PIANO KEYS?
    freqs_win_func     ='parzen', --DEFAULT='parzen'  poisson cauchy flattop MAYBE OK, BUT THE OTHERS ARE UGLY: rect bartlett hanning hamming blackman welch bharris bnuttal bhann sine nuttall lanczos gauss tukey dolph        PARZEN WAS AN AMERICAN STATISTICIAN.
    freqs_averaging    =   2, --DEFAULT=  2  INTEGER, MIN 1. STEADIES SPECTRUM. SLOWS RESPONSE TO AUDIO. TRY 3 IF MORE freqs_fps. 
    freqs_magnification= 1.2, --DEFAULT=1.1  CURVE HEIGHT SCALE FACTOR. REDUCES CPU CONSUMPTION, BUT THE LIPS LOSE TRACTION.    L & R CHANNELS ARE LIKE A DUAL ALIEN MOUTH (LIKE HOW HUMANS ARE BIPEDAL). 
    freqs_clip_h       =  .3, --DEFAULT= .3  MINIMUM=grid_height (CAN'T CLIP LOWER THAN grid, DUE TO INVERSE CANVAS pad). REDUCES CPU USAGE BY CLIPPING CURVE - CROPS THE TOP OFF SHARP SIGNAL. THE NEED FOR CLIPPING, LOW fps & size PROVE THE CODE MAY BE SLOW.
    -- freqs_interpolation=true,--UNCOMMENT FOR INTERPOLATION (freqs_fade). ADDS ~7% CPU USAGE. FOR albumart REDUCE freqs_fps_image.  NICE EFFECT BUT LOOKS JITTERY & MAY CAUSE STUTTER @autocrop (WITHOUT DRIVERS).
    freqs_alpha        =  .7, --DEFAULT= .7  RANGE [-2,2]  OPAQUENESS OF SPECTRAL DATA CURVE.    DUAL-complex MAY LOOK BETTER TRANSPARENT.
    volume_fps         =  25, --DEFAULT= 25  PRIMARY overlay fps. STREAM MAYBE 60fps BUT NOT THE EXTRA VISUALS. WITHOUT PROPRIETARY DRIVERS TRY 25fps.
    volume_fade        =   0, --DEFAULT=  0  RANGE [0,1].
    -- volume_dm       =   1, --DEFAULT=  0  UNCOMMENT FOR DISPLAYMAX LINES (RED). 
    volume_alpha       = .25, --DEFAULT= .5  RANGE [0,2]. 0 REMOVES BARS (feet REMAIN). OPAQUENESS OF volume BARS.    DUAL volume TAKES CENTER STAGE.
    volume_width       = .04, --DEFAULT=.04  RANGE (0,1] RELATIVE TO width.
    volume_height      = .15, --DEFAULT=.15  RANGE (0,1] RELATIVE TO display, BEFORE STACKING feet. autocrop MAY MAGNIFY ITS SIZE.
    grid_thickness     = 1/8, --DEFAULT= .1  RANGE (0,1] RELATIVE TO grid SPACING. APPROX AS THICK AS CURVE.
    grid_height        =  .1, --DEFAULT= .1  RANGE (0,1] RELATIVE TO display, BEFORE STACKING feet.  grid TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS.
    grid_alpha         =   1, --DEFAULT=  1  RANGE [0,2] RELATIVE TO volume_alpha. 0 REMOVES grid & feet. alpha MULTIPLIER.
    feet_height        = .05, --DEFAULT=.05  RANGE [.01,1] RELATIVE TO grid (BARS). 
    feet_activation    =  .5, --DEFAULT= .5  RANGE [0,1) RELATIVE TO volume, FROM THE BOTTOM. feet BLINK ON/OFF WHEN volume PASSES THIS THRESHOLD.
    feet_lutrgb        ='128:0:255:val*4', --DEFAULT='128:0:255:val*2'  val*0 TO REMOVE feet. COLOR OF CENTRAL feet.
    shoe_color         ='BLACK@.5', --DEFAULT='BLACK'  @0 TO REMOVE.  THERE CAN ALSO BE ANOTHER OPTION FOR grid_colormix (BLUE/RED OR RED/BLUE BARS?) RED OUTER BARS ARE BAD FOR cropdetect.  ANOTHER ISSUE IS SPEAR-TIPPING OR BLURRING THE GRID ELEMENTS.
    
    -- scale={1680,1050},--DEFAULT=display (WINDOWS & MACOS), OR ELSE =video (LINUX).
    format ='yuv420p',   --DEFAULT=yuv420p  FINAL format IMPROVES PERFORMANCE. 420p REDUCES COLOR RESOLUTION TO HALF-WIDTH & HALF-HEIGHT.
    options=''           --'opt1 val1 opt2 val2 '... FREE FORM.  main.lua HAS io_write & options.
        ..' ytdl-format [ext!=webm] '  --webm INCOMPATIBLE WITH lavfi-complex.  EXAMPLE: https://youtu.be/ubvV498pyIM 
        ..' vd-lavc-threads 0  osd-font-size 16  geometry 50% ' --DEFAULT size 55p MAY NOT FIT lavfi-complex ON osd. geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  vd-lavc=VIDEO DECODER - LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER, OR ELSE MAY FAIL INSPECTION.
}
for opt,val in pairs({toggle_on_double_mute=0,key_bindings='',fps=25,period=1,rotate='0',zoompan='1:0:0',overlay='(W-w)/2:(H-h)/2',dual_alpha=1.5,dual_overlay='(W-w)/2:(H-h)/2',highpass=100,dynaudnorm=500,gb=.3,width=1,freqs_lead_t=.08,freqs_fps=25/2,freqs_fps_image=25,freqs_mode='line',freqs_win_size=512,freqs_win_func='parzen',freqs_averaging=2,freqs_magnification=1.1,freqs_clip_h=.3,freqs_alpha=.7,volume_fps=25,volume_fade=0,volume_dm=0,volume_alpha=.5,volume_width=.04,volume_height=.15,grid_thickness=.1,grid_height=.1,grid_alpha=1,feet_height=.05,feet_activation=.5,feet_lutrgb='128:0:255:val*2',shoe_color='BLACK',format='yuv420p',scale={},options=''})
do if not o[opt] then o[opt]=val end end --ESTABLISH DEFAULTS. 

opt,val,o.options = '','',o.options:gmatch('[^ ]+') --GLOBAL MATCH ITERATOR. [^ ] MEANS COMPLEMENT SET TO " ". + MEANS LONGEST (FULL WORD MATCHES). '%g+' (GLOBAL) IS INCOMPATIBLE WITH mpv.app WHICH USES AN OLD LUA VERSION. THE SYMBOL FOR EXCLUDING SPACES, TABS & NEWLINES CAME IN A NEWER VERSION.
while   val do mp.set_property(opt,val)   --('','') → NULL-SET
    opt,val = o.options(),o.options() end --nil @END
mp.set_property('script-opts','lavfi-complex=yes,'..mp.get_property('script-opts')) --TRAILING COMMA ALLOWED. WARN ALL SCRIPTS image WILL INFINITE loop INSIDE complex. A complex loop IS A MORE POWERFUL loop THAN OTHERWISE POSSIBLE.

if o.period==0 or o.period=='0' then for opt in ('rotate zoompan overlay dual_overlay'):gmatch('[^ ]+') --DON'T DIVIDE BY 0 BY REMOVING TIME DEPENDENCE.
    do for nt in ('in on n t')     :gmatch('[^ ]+') do o[opt]=o[opt]:gsub(nt..'/%%s','0') end end end   --in & on BEFORE n.  OVERRIDE: THIS CODE ONLY GSUBS "t/%s" ETC (NOT FULLY GENERAL).

for opt in ('rotate  zoompan     '):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.volume_fps)) end  --OPTIMIZE USING DIFFERENT fps FOR ANIMATION VS FINAL FILM overlay.
for opt in ('overlay dual_overlay'):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.       fps)) end

amix,vstack = '','pad=0:ih*2:0:0:BLACK@0'  --amix BUILDS sine_mix RECURSIVELY.  vstack IS TOP/BOTTOM. pad*2 FOR ABSENT TOP OR BOTTOM SIMPLIFIES CODE.
if o.sine_mix then N,amix = 0,',[ao]'   --"," SEPERATES THE SINES FROM THE MIX. THE EMPTY table={} IS VALID.
    for M,sine in pairs(o.sine_mix) do N,amix = M,(',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],M,amix,M) end  --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).
    amix=('anull[ao]%samix=%d:first,'):format(amix,N+1) end   --N+1 STREAMS TO amix, STARTING WITH [a] RELABELLING. SINE WAVES ARE INFINITE DURATION.

if o.vflip_scale and o.vflip_scale>0 then vflip=('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'):format(o.vflip_scale,o.vflip_scale) end --scale & pad FOR BOTTOM. PADDING SIMPLIFIES CODE.
if     vflip and o.vflip_only then vstack=vflip..',pad=0:ih*2:0:oh-ih:BLACK@0'  --vflip_only OVERRIDE. pad DOUBLE.
elseif vflip  then vstack=('split[U],%s[D],[U][D]vstack'):format(vflip) end  -- [U],[D] = TOP,BOTTOM
if o.colormix then vstack=('colorchannelmixer=%s,%s'):format(o.colormix,vstack) end --PREPEND colormix. ADDS 10% CPU USAGE.
if not vflip and o.vflip_only then vstack='' end   --NULL OVERRIDE (fps LIMIT & JPEG loop ONLY).

lavfi=('[aid%%d]%sasplit[ao],stereotools,highpass=%s,dynaudnorm=%s,asplit[af],showvolume=%s:0:128:8:%s:t=0:v=0:o=v:dm=%s:dmc=RED,colorchannelmixer=aa=%s:bg=1:gg=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aresample=2e3*1.05,asetpts=PTS-(%s)/TB,apad,dynaudnorm=%s,showfreqs=300x500:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%%s,crop=iw/1.05:ih*(%s):0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lutrgb=255*gt(val\\,90):0:255*gt(val\\,90),framerate=%%s,format=rgb32,split[R],shuffleplanes=0:0:1:1,lutrgb=a=val*(%s),hflip[L],[R]shuffleplanes=0:0:2:2,lutrgb=a=val*(%s)[R],[grid][L]scale2ref=iw*2-2:ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w:0:endall,scale=ceil(iw/4)*4:ceil(ih/4)*4,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,shuffleplanes=2:2:1:3,lutrgb=val:val*(%s)[LHI],[RHI]crop=iw/4:ih:iw-ow,shuffleplanes=2:2:1:3,lutrgb=val:val*(%s)[RHI],[LHI][MIDDLE][RHI]hstack=3[vid],[vol][vid]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,split[vo],crop=1:1:0:0:1:1,fps=%s,format=yuva420p,lutyuv=0:128:128:0,split[to],select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[t0],[to][vid]scale2ref,overlay,setpts=PTS-STARTPTS,format=yuva420p,rotate=%s:iw:ih:BLACK@0,zoompan=%s:1:%%dx%%d:%s[vid],[vo]setpts=PTS-STARTPTS[vo],[vo][vid]overlay=%s[vo],[t0][vo]scale2ref,concat,trim=start_frame=1[vo]')
    :format(amix,o.highpass,o.dynaudnorm,o.volume_fps,o.volume_fade,o.volume_dm,o.volume_alpha,o.gb,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.gb,o.gb,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.grid_height..'/'..o.freqs_clip_h,o.freqs_lead_t,o.dynaudnorm,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_clip_h..'/'..o.freqs_magnification,o.freqs_alpha,o.freqs_alpha,o.gb,o.gb,o.volume_width,o.volume_height..'/'..o.freqs_clip_h,vstack,o.volume_fps,o.rotate,o.zoompan,o.volume_fps,o.overlay)  --gb*7 TO PROPERLY INVERT WHITE SHOES RE. RED & BLUE. volume_fps FOR volume & TIME-STREAM zoompan INPUT. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha FOR L & R CHANNELS. 

----lavfi            =graph LIBRARY-AUDIO-VIDEO-FILTERGRAPH. SELECT FILTER NAME TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH LINEDUPLICATE ETC. lavfi-complex MAY COMBINE MANY [aid#] & [vid#] INPUTS. %% SUBS OCCUR LATER.  [vo]=VIDEO-OUT [ao]=AUDIO-OUT [af]=AUDIO-FREQS [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [L]=LEFT [R]=RIGHT [vol]=VOLUME [vid#]=VIDEO-IN [aid#]=AUDIO-IN.  A lavfi string IS LIKE DNA & CAN CREATE VARIOUS CREATURES. SEE ffmpeg-filters MANUAL.  EACH FOOT HAS A STEREO INSIDE IT. [feet0] (SHOES) ARE THE CENTER-PIECE.  [to] & [t0] CODES ALWAYS VALID, EVEN ON YOUTUBE & FOR MP4 SUBCLIPS WITH OFF TIMESTAMPS. IMPOSSIBLE TO CORRECTLY ENTER NUMBERS LIKE time-pos OR audio-pts. CANVAS [to] SWITCHES OUT audio→video TIMESTAMPS (IT'S ACTUALLY [time-vo]).
----format           =pix_fmts  (yuv420p yuva420p rgb32 rgb24)  CONVERSIONS IMPROVE EFFICIENCY (yuv BEATS rgb). FINALIZES format @GPU (VERIFY MPV LOG).
----fps              =fps:start_time   (FRAMES PER SECOND:SECONDS) LIMITS @file-loaded. ALSO FOR OLD MPV showfreqs. start_time FOR JPEG.   INCREASE FROM 25→30 fps IS ACTUALLY QUITE DIFFICULT TO CODE.
----highpass         =f:p  Hz:poles  DAMPENS SUB-BASS. ~50Hz IS POWER & REFRESH RATE.   UNFORTUNATELY afftfilt IS TOO BUGGY. highpass IS TECHNICALLY NEEDED FOR A DIFFERENT REASON.
----dynaudnorm →s64  =f:g:p:m:r:n:c:b=500:31:.95:10:0:1:0:0(DEFAULT) = FRAME(MILLISECONDS):GAUSSIAN_WIN_SIZE(ODD INTEGER):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:CORRECTION_DC(BOOL):BOUNDARY_MODE(BOOL,NO FADE)     DYNAMIC AUDIO NORMALIZER. b DISABLES FADE (NOT FOR SPECTRUM). IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g GIVES FASTER RESPONSE. RENORMALIZING OPTIONAL, AFTER aresample & asetpts. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. 
----colorchannelmixer=rr:...:aa   (RANGE -2→2, r g b a PAIRS) CONVERTS GREEN TO BLUE, RED TO BLUE, ETC.  SLOW - EXTRA CODE AVOIDS INSERTING IT. SOME FILTERS LIKE geq (GLOBAL EQUALIZER) ARE POWERFUL BUT SLOW SO CAN'T BE USED.
----hflip,vflip       FLIPS [L] LEFT.  vflip FOR BOTTOM [D] (FOR DOWN).
----rotate           =angle:ow:oh:fillcolor  (RADIANS:PIXELS) ROTATES vstack CLOCKWISE, DEPENDENT ON TIME t & FRAME n.
----zoompan          =z:x:y:d:s:fps   (z>=1) d=1 FRAMES DURATION-OUT PER FRAME-IN.  z:x:y MAY DEPEND ON in,on = INPUT-NUMBER,OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----sine             =frequency:beep_factor  (Hz,BOOL) DEFAULT=440:0  beep IS EVERY SECOND.  FOR sine_mix CALIBRATION.
----volume           =volume  (0→100) sine VOLUMES. FORMS TRIPLE WITH sine & amix.
----amix             =inputs:duration  DEFAULT 2:longest  MIXES IN SINES. [a1][a2]...→[ao]
----setpts,asetpts   =expr  PRESENTATION TIMESTAMP.  FOR SYNC OF rotate,zoompan,overlay WITH OTHER GRAPHS (automask), BY SENDING STARTPTS→0. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO.
----pad,apad         =w:h:x:y:color    BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih.  apad APPENDS SILENCE FOR SPECTRUM TO ANALYZE, OR THERE'S A CRASH @end-file.
----anull             RE-LABELER FOR amix & TOGGLE OFF.  IS THE START WITH sine_mix.
----loop             =loop:size  (loop>=-1 : size>0) PAIRS WITH fps FOR RAW JPEG, WHICH IS ITS OWN CASE-STUDY WITH ITS OWN FILTER (MOST ELEGANT).
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo.     PREFERRED ALTERNATIVE TO aformat.
----showvolume[a]→[v]=rate:b:w:h:f:...:t:v:o = rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION    (DEFAULTS 25:1:400:20:0.95:t=1:v=1:o=h)   LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED.    THERE'S SOME MINOR BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----aresample         (Hz) DOWNSAMPLES TO 2.1kHz (NYQUIST+5%). AN ALTERNATIVE IS aformat.
----showfreqs [a]→[v]=size:RATE:mode:ascale:fscale:win_size:win_func:overlap:averaging:colors  DEFAULTS 1024x512:25:bar:log:lin:2048:hanning:1:1   RATE CRASHES LINUX snap, SO THESE NEED TO BE SPELLED OUT FOR COMPATIBILITY. size SHOULD HAVE ASPECT ~300x500 FOR HEALTHY CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (300x300 & 300x700 GIVE OFF CURVES). SEPARATING CHANNELS WITHOUT COLORS (cmode=separate) WOULD REQUIRE TWICE AS MANY PIXELS.
----crop             =w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES [LOWS]. CROPS 5% OFF DATA.
----lutyuv,lutrgb    =y:u:v:a,r:g:b:a  LOOK-UP-TABLE,BRIGHTNESS-UV,RED-GREEN-BLUE  lutyuv IS MORE EFFICIENT THAN lutrgb. lut IS AMBIGUOUS (format CONVERSION?). CREATE TRANSPARENCY, & SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.  lutyuv CAN BLANK CANVAS.
----avgblur          =sizeX   (PIXELS)  AVERAGE BLUR. CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTH CURVE.
----framerate        =fps  ADDS 10% CPU USAGE. alpha CAUSES BUG. USE rgb24 BEFORE rgb32.
----shuffleplanes    =map0:map1:map2:map3  REDUCES NET CPU USAGE BY ~5% (ESSENTIAL, WITHOUT PROPER GRAPHICS DRIVERS). ORDERED g:b:r:a (LIKE GreatBRitAin). SHUFFLES WITHOUT MIXING. DEFAULT 0:1:2:3  LINUX snap COMPATIBILITY DEPENDS ON EXACT USAGE.  SWITCHES HIGHS FROM LOWS, & SEPARATES L & R CHANNELS.
----scale,scale2ref  =width:height  DEFAULT iw:ih  SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.     TO-REFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume.
----setsar           =sar  SAMPLE/PIXEL ASPECT RATIO.  FINALIZES scale @GPU (CAN CHECK MPV LOG). ALSO STOPS EMBEDDED MPV SNAPPING (CAN VERIFY WITH DOUBLE-mute TOGGLE IN SMPLAYER). MACOS BUGFIX REQUIRES sar.
----hstack,vstack    =inputs  COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES feet. FUTURE VERSION MIGHT ADD OR SUBTRACT MORE TICKS (1.1kHz, ETC).      vstack FOR FEET & TOP/BOTTOM.
----select           =expr  (EXPRESSION)  DISCARDS FRAMES IF 0.  BUGFIX FOR OLD MPV, select FOR [t0]. REDUCES RAM USAGE.  USING A 1x1 TIME-STREAM WORKS BETTER IN LINUX/MACOS.
----concat            [t0][vo]→[vo]   FINISHES [t0].  CONCATENATE STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. NEEDED TO SYNC WITH automask.
----overlay          =x:y:eof_action  FINISHES [to].  (DEFAULT 0:0:repeat)  endall DUE TO apad. OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON TIME t.     UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4. 
----split,asplit     =outputs  IS THE FINISH ON [ao].  DEFAULT=2
----trim             =...:start_frame:end_frame  IS THE FINISH ON [vo]. TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP. 


function file_loaded() --ALSO on_aid, on_vid, on_toggle & ytdl.
    image,aid,vid = false,mp.get_property_number('current-tracks/audio/id'),mp.get_property_number('current-tracks/video/id') --image=BOOL  'aid' & 'vid' MAYBE='auto', BUT id=nil OR INTEGER. 
    if aid and new_aid then aid=new_aid end --on_aid OVERRIDE.
    if vid and new_vid then vid=new_vid end --on_vid OVERRIDE. SHOULD CHECK IF vid IN CASE AUDIO-ONLY (& VICE VERSA). 
    if not aid then vstack=''   end --EQUIVALENT TO NO SPECTRUM.
    
    for _,track in pairs(mp.get_property_native('track-list')) do if track.type=='video' and track.id==vid then image,w,h,par,script_opts = track.image,track['demux-w'],track['demux-h'],track['demux-par'],mp.get_property_native('script-opts')  --LOOP OVER ALL TRACKS TO BE CERTAIN OF w, h & par.
            if not par then par=1 end  --PIXEL ASPECT RATIO MUST BE WELL-DEFINED. JPEG ASSUME 1. 
            if w and h then script_opts.aspect=w/h..''  --..'' CONVERTS→string. CHECK demux-w & h BECAUSE THEY MAY FAIL TO UPDATE WHEN SWITCHING vid, BTWN VIDEO & LEAD-FRAME. 
                mp.set_property_native('script-opts',script_opts) end  --REPORT ORIGINAL aspect TO ALL OTHER SCRIPTS. PROPER aspect IS DEPRACATED & video-aspect-override GLITCHES ON playlist-next.
            break end end 
    
    W,H = o.scale[1],o.scale[2]  --scale OVERRIDE.
    if not (W and H) then W,H = mp.get_property_number('display-width'),mp.get_property_number('display-height') end  --WINDOWS
    if not (W and H) then W,H = mp.get_property_number('video-params/w'),mp.get_property_number('video-params/h') end --LINUX & MACOS VIRTUALBOX.
    if not (W and H) then W,H = 1920,1080 end --RAW MP3 LINUX & MACOS VIRTUALBOX-SMPLAYER (1080p FALLBACK).
    
    complex,freqs_fps,clip_h = '',o.freqs_fps,math.ceil(H*o.freqs_clip_h*2/4)*4 --complex=%%s lavfi INSERT WHICH YIELDS [vo].  clip_h=FINAL CLIP HEIGHT FOR TOP & PADDED BOTTOM (*2).  MULTIPLES OF 4 FOR PERFECT overlay.
    ----5 CASES  1) image & albumart (NO SPECTRUM)  2) MP4 LIMITS (NO SPECTRUM)  3) MP3  4) albumart  5) MP4     INSPECT MPV LOG TO VERIFY EXACT [gpu] OUTPUT IN EVERY CASE. INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. EXAMPLE: automask albumart ANIMATION.
    if   image then complex=('[vid%d]%%s,loop=-1:1,fps=%s:%s'):format(vid,o.fps,mp.get_property_number('time-pos'))    --CASE 1: RAW JPEG. start_time FOR --start (JPEG seek). A complex loop IS MORE POWERFUL THAN NORMAL loop.
    elseif vid then complex=('[vid%d]fps=%s,%%s'):format(vid,o.fps) end   --CASES 2 & 5: NORMAL video. [vo] MAY BE SPECIFIED WITHOUT [ao].
    complex=complex:format('scale=%d:%d,setsar=%s,format=%s'):format(W,H,par,o.format)  --CASES 1, 2 & 5. %s=scale,... INSERT.
    if vstack=='' then if vid then mp.set_property('lavfi-complex',complex..'[vo]') end  --set CASES 1 & 2
        return end --set CASES 3,4,5 BELOW. 
    
    if image then complex=('[to],[vid%d]scale=%d:%d[vo],[to][vo]overlay'):format(vid,W,H) end --CASE 4: albumart  [to]=TIME-OUT UNDERLAY FOR PROPER MOTION.  [vid#] GETS SANDWICHED.
    if image or not vid then freqs_fps,complex = o.freqs_fps_image,('[vid]split[vid],crop=1:1:0:0:1:1,format=yuva420p,lutyuv=0:128:128:0,scale=%d:%d%s,setsar=1,format=%s,fps=%s'):format(W,H,complex,o.format,o.fps) end  --CASES 3 & 4. MP3 & albumart. USE [vid] INSTEAD OF [vid#] TO BUILD [to]. image IS SANDWICHED BTWN [to] & [vid].  scale BEFORE format,BY TRIAL & ERROR.
    
    if o.dual_scale then complex=('%s[vo],[vid]split[vid]%%s,format=yuva420p,lutyuv=a=val*(%s),scale=%d:%d[dual],[vo][dual]overlay=%s'):format(complex,o.dual_alpha,math.ceil(W*o.dual_scale[1]/4)*4,math.ceil(clip_h*o.dual_scale[2]/4)*4,o.dual_overlay)  -- [v2]=DUAL  LABELS [vid1][vid2] ETC NOT ALLOWED (RESERVED).
        if o.dual_colormix then complex=complex:format(',colorchannelmixer='..o.dual_colormix) end end --ADDS 5% CPU USAGE.
    
    framerate=freqs_fps  --INTERPOLATION MECHANISM. freqs_fps→volume_fps  MAY VARY on_vid.
    if o.freqs_interpolation then framerate=o.volume_fps end
    
    mp.set_property('lavfi-complex',lavfi:format(aid,freqs_fps,framerate,complex:format(''),W*o.width,clip_h))  --CASES 3,4,5.  size FOR zoompan.  %s='' TERMINATES FORMATTING.
    if OFF then OFF=false  --ALREADY OFF, FORCE TOGGLE. EXAMPLE: playlist-next WHEN OFF.
        on_toggle() end  
end 
mp.register_event('file-loaded',file_loaded)
mp.register_event('seek'    ,function() if mp.get_property_number('time-remaining')==0 then mp.command('playlist-next force') end end)  --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST.  BUGFIX FOR seek PASSED end-file. A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES PASSED end-file.
mp.register_event('end-file',function() last_brightness,last_aid,last_vid,new_aid,new_vid = nil,nil,nil,nil,nil end)  --CLEAR MEMORY FOR MPV PLAYLISTS (EXAMPLE: path=*.MP4)

function on_aid(_,aid)  --UNTESTED. ONLY GOOD FOR 1 SWITCH IN aid: 1→2 XOR N→1.
    if last_aid and last_aid~=aid then new_aid=1
        if                  last_aid==1   then new_aid=2 end
        file_loaded() end
    last_aid=aid    --REMEMBER aid.
end
mp.observe_property('aid','number',on_aid)

function on_vid(_,vid)  --ONLY GOOD FOR 1 SWITCH IN vid: 1→2 XOR N→1.  ALTERNATIVE stop & loadfile DOESN'T WORK.
    if last_vid and last_vid~=vid then new_vid=1  
        if                  last_vid==1   then new_vid=2 end
        file_loaded() end
    last_vid=vid    --REMEMBER vid.
end
mp.observe_property('vid','number',on_vid)  --TRIGGERS INSTANTLY & AFTER file-loaded. string WON'T WORK, BUT number DOES.

function on_toggle(mute)
    if not (W and H) then return end --NOT loaded YET.
    if mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.
        return end
    
    OFF=not OFF --REMEMBER TOGGLE STATE.
    if not OFF then file_loaded()   --TOGGLE ON.    UNFORTUNATELY THIS SNAPS albumart IN SMPLAYER (EVERY TIME).
    elseif vstack~='' then complex=('[aid%d]anull[ao]'):format(aid) --TOGGLE OFF CASE 3: RAW audio. CASES 4 & 5 BUILD ON THIS.   CASES 1 & 2 DO NOTHING. OPEN TO INTERPRETATION: NO SPECTRUM, NO TOGGLE OFF.   1) JPEG. 2) MP4 LIMITS. 3) MP3. 4) MP3+JPEG. 5) MP4.
        if   image    then complex=('%s,[vid%d]%%s,loop=-1:1,fps=%s:%s[vo]'):format(complex,vid,o.fps,mp.get_property_number('time-pos')) --CASE 4: albumart  NEED start_time FOR automask (CAN TOGGLE "F1" @30MINS). STILL USES APPROX 5% CPU TO INFINITE loop.    MACOS TAKES A STILL FRAME (DIFFERENT, BUT VALID).
        elseif vid    then complex=('%s,[vid%d]fps=%s,%%s[vo]'):format(complex,vid,o.fps) end   --CASE 5. LIMIT [vo], WITH NO SPECTRUM.
        complex=complex:format('scale=%d:%d,setsar=%s,format=%s'):format(W,H,par,o.format)
        mp.set_property('lavfi-complex',complex) end
    if o.osd_on_toggle then mp.osd_message(o.osd_on_toggle:format(mp.get_property_osd('af'),mp.get_property_osd('vf'),mp.get_property_osd('lavfi-complex')), 5) end  --OPTIONAL osd, 5 SECONDS.
end
for key in o.key_bindings:gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_complex_'..key, on_toggle) end --MAYBE SHOULD BE 'toggle_spectrum_' BECAUSE THIS TOGGLE ONLY TURNS OFF/ON THE SPECTRUM.
mp.observe_property('mute', 'bool', on_toggle)

timer=mp.add_periodic_timer(o.toggle_on_double_mute, function()end)  --timer CARRIES OVER IN MPV PLAYLIST.
timer.oneshot=true
timer:kill() 


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 5 CASES), LINE TOGGLES (options), MIDDLE (TECH SPECS), & END (MISC.). ALSO BLURBS ON WEB, & DESCRIPTION OF 5 CASES. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.36.0 (INCL. v3) v0.35.0 (.7z) v0.35.1 (.flatpak)  TESTED.
----FFmpeg v5.1.2(MACOS) v4.3.2(LINUX .AppImage) v6.0(LINUX) TESTED.
----WIN10 MACOS-11 LINUX-DEBIAN-MATE  (ALL 64-BIT)           TESTED. ALL SCRIPTS PASS snap+ytdl INSPECTION.  
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. 

----BUG: CAN'T CHANGE TRACK PROPERLY. VERBOSE MESSAGES MAY ENABLE IT. EXAMPLE: {"event" = "log-message", "level" = "v", "text" = "Set property: aid=2 -> 1    ", "prefix" = "cplayer"}
----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). FIX: CAN USE v23.6 (JUNE RELEASE) INSTEAD, OR GIVE MPV ITS OWN WINDOW. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 
----MINOR BUG: albumart COLORS CHANGE SLIGHTLY UNDER SPECTRAL OVERLAY. VERIFY USING TOGGLE. colormatrix? TRANSPARENCY CORRUPTS THE COLORS.

----ALTERNATIVE FILTERS:
----firequalizer  MAY BE NEEDED TO MODEL HUMAN EAR RESPONSE. CAN REPLACE highpass & MULTIPLY BY frequency. (A HIGH PITCHED CHIRP IS RELATIVELY DEAFENING TO HUMAN, AMPLITUDE THE SAME.)
----afftfilt     =real:imag:win_size:win_func:overlap  DEFAULT=1|1:1|1:4096:hann:0.75  (AUDIO FAST FOURIER TRANSFORM FILTER) overlap<1 CAUSES BUG. MAY ALSO HELP MODEL HUMAN EAR SENSITIVITY.
----sendcmd       NOT WORKING IN MPV. NO INSTA-TOGGLE?
----asettb       =tb    OPTIONAL TIMEBASE SPEC. MAY PROVIDE fps HINT TO FURTHER FILTERS.
----loudnorm     =I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). CAUSED DEFECT REQUIRING apad. LACKS f & g SETTINGS. SOUNDED OFF.
----acompressor   SMPLAYER DEFAULT NORMALIZER. LOOKS BAD.
----extractplanes=planes    r+b→[R][L] (RED+BLUE)   REVERSED BECAUSE [L] GETS FLIPPED AROUND.
----alphamerge    [y][a]→[ya]  USES lum OF [a] AS alpha OF [ya]. PAIRS WITH split TO CONVERT BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey, colorchannelmixer & shuffleplanes.

----ALTERNATIVE GRAPH EXAMPLE CODES:
--EXTRACTPLANES LR MONOCHROME (NOT FASTER):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,2010,o.freqs_lead_t,o.highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_magnification,2,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,vstack,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 
--SHUFFLEPLANES:    lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--NOSHUFFLEPLANES:  lavfi=('[aid%%d]%sasplit[ao],stereotools,highpass=%s,dynaudnorm=%s,asplit[af],showvolume=%s:0:128:8:%s:t=0:v=0:o=v:dm=%s:dmc=RED,colorchannelmixer=aa=%s:bg=1:gg=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aresample=2e3*1.05,asetpts=PTS-(%s)/TB,apad,dynaudnorm=%s,showfreqs=300x500:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw/1.05:ih*(%s):0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lutrgb=255*gt(val\\,90):0:255*gt(val\\,90),framerate=%s,format=rgb32,split[R],colorchannelmixer=bb=0:aa=0:ab=%s:rb=1:rr=0,hflip[L],[R]colorchannelmixer=bb=0:aa=0:ar=%s[R],[grid][L]scale2ref=iw*2-2:ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w:0:endall,scale=ceil(iw/4)*4:ih,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[LHI],[RHI]crop=iw/4:ih:iw-ow,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[RHI],[LHI][MIDDLE][RHI]hstack=3[vid],[vol][vid]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,split[vo],crop=1:1:0:0:1:1,fps=%s,format=yuva420p,lut=0:128:128:0,split[to],select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[t0],[to][vid]scale2ref,overlay,setpts=PTS-STARTPTS,format=yuva420p,rotate=%s:iw:ih:BLACK@0,zoompan=%s:1:%%dx%%d:%s[vid],[vo]setpts=PTS-STARTPTS[vo],[vo][vid]overlay=%s[vo],[t0][vo]scale2ref,concat,trim=start_frame=1[vo]'):format(amix,o.highpass,o.dynaudnorm,o.volume_fps,o.volume_fade,o.volume_dm,o.volume_alpha,o.gb,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.gb,o.gb,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.grid_height..'/'..o.freqs_clip_h,o.freqs_lead_t,o.dynaudnorm,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h..'/'..o.freqs_magnification,o.volume_fps,o.freqs_alpha,o.freqs_alpha,o.gb,o.gb,o.gb,o.gb,o.volume_width,o.volume_height..'/'..o.freqs_clip_h,vstack,o.volume_fps,o.rotate,o.zoompan,o.volume_fps,o.overlay)  --gb*7 TO PROPERLY INVERT WHITE SHOES RE. RED & BLUE. volume_fps FOR volume & TIME-STREAM zoompan INPUT. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha FOR L & R CHANNELS. 
--WITH MIDDLE FOOT: lavfi=('[aid%%d]atrim=%%s,asetpts=PTS-STARTPTS+(%%s)/TB,asplit[ao]%s,stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%s:0:%d:8:%s:t=0:v=0:o=v:dm=%s,colorchannelmixer=gg=%s:bg=1:aa=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(%s),colorchannelmixer=rb=1:gr=%s:br=1:rr=0:gg=0:bb=0:aa=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:BLACK@%s,split[FOOT],split,hstack[feet],[FOOT]colorchannelmixer=rb=1:br=1:rr=0:bb=0:aa=2,scale=iw*2:ih[FOOT],[vol][FOOT]vstack[vol],[BAR][feet]vstack,lut=a=val*(%s),split[grid-R],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[grid-L],[grid-R]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[grid-R],[grid-L][grid-R]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aformat=s16:%s,highpass=%s,apad,dynaudnorm=p=1:m=100:c=1:b=1,asetpts=PTS-(%s)/TB,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90):0:255*gt(val\\,90),format=rgb32,split[L],colorchannelmixer=bb=0:ar=%s:aa=0[R],[L]colorchannelmixer=bb=0:ab=%s:aa=0:rb=1:rr=0,hflip[L],[grid][R]scale2ref=iw*2-(%s):ih,overlay=W-w:0:endall[grid],[grid][L]overlay=0:0:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HI-R][LOWS],crop=iw/4:ih:0,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-L],[LOWS]crop=iw/2[LOWS],[HI-R]crop=iw/4:ih:iw-ow,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-R],[HI-L][LOWS][HI-R]hstack=3[vid],[vol][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,setpts=PTS-STARTPTS[vo],[vid]setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[vo][vid]overlay=%s,setpts=PTS+(%%s)/TB,format=%s,setsar=1[vo]'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_dm,o.gb,o.volume_alpha,o.feet_height,o.feet_activation,o.gb,o.feet_alpha,o.feet_alpha/4,o.grid_alpha,o.grid_thickness,o.grid_thickness,f(o.grid_height/o.freqs_clip_h),2010,o.highpass,o.freqs_lead_t,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,f(o.freqs_clip_h/o.freqs_magnification),o.freqs_alpha,o.freqs_alpha,2,o.gb,o.gb,o.volume_width,f(o.volume_height/o.freqs_clip_h),vstack,o.rotate,o.zoompan,o.fps,o.overlay,o.format)    --fps FOR volume, freqs & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER [FEET]. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha REPEATS FOR L & R CHANNELS. 
--CURVES OUTLINES USING SPLIT,ALPHAMERGE lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,split,alphamerge,lut=r=0:g=0:b=255*gt(val\\,90):a=255*gt(val\\,90)*(%s),format=rgb32[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')



