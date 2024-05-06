----lavfi-complex SCRIPT WHICH OVERLAYS STEREO FREQUENCY SPECTRUM + VOLUME BARS (AUDIO VISUALS) ONTO MP4, AVI, 3GP, MP3 (RAW & albumart), MP2, M4A, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE. IT ALSO LOOPS albumart. 
----CAN USE DOUBLE-mute TO TOGGLE. ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY sine_mix CAN BE ADDED FOR CALIBRATION. COMPLEX MOVES & ROTATES WITH TIME.  
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. 

options={  --ALL OPTIONAL & MAY BE REMOVED.  TO REMOVE AN INTERNAL COMPONENT SET ITS alpha TO 0 (freqs volume grid feet shoe).  A table OF EQUATIONS CAN BE HOLLOWED OUT TO FORM BRICKS, LIKE HOLLOW CLAY.
    key_bindings       =    'F2', --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  'F2 F3' FOR 2 KEYS.  C=AUTOCROP NOT COMPLEX. 
    -- toggle_on_double_mute= .5, --SECONDS TIMEOUT FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). REQUIRES AUDIO IN SMPLAYER.  INTERRUPTS PLAYBACK. DOESN'T TOGGLE dynaudnorm!
    -- osd_on_toggle   =       5, --SECONDS. UNCOMMENT TO INSPECT VERSIONS, FILTERGRAPHS & PARAMETERS. 0 CLEARS THE osd INSTEAD. DISPLAYS mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params
    -- vflip_only      =    true, --UNCOMMENT TO REMOVE TOP HALF. ALSO REMOVE vflip_scale FOR NULL OVERRIDE (NO overlay).
    vflip_scale        =      .5, --REMOVE FOR NO BOTTOM HALF.  A DIFFERENT VERSION COULD SUPPORT BL & BR CHANNELS FOR BOTTOM.
    width              =       1, --DEFAULT= 1  OVERALL PRIMARY width RATIO (scale). <1 CAUSES zoompan TO CLIP.  A FUTURE VERSION COULD FIX THIS.
    fps                =     30 , --DEFAULT=30  FRAMES PER SECOND FOR [vo].  30fps (+automask) USES ~15% MORE CPU THAN 25fps. SCRIPT ALSO LIMITS scale. 
    period             = '22/30', --DEFAULT= 1 SECOND. USE fps RATIO. 20/30→90BPM (BEATS PER MINUTE). SET TO 0 FOR STATIONARY (~20% OFF CENTER DUE TO zoompan EFFECT). UNLIKE A MASK, MOTION MAY NOT BE PERIODIC - SPECTRUM FREE TO RANDOMLY FLOAT AROUND. IT ACTS LIKE A METRONOME.  (IF 0, "n/%s"→"0" GSUBS OCCUR, ETC). 
    -- filterchain     = 'shuffleplanes=1:0:2:3,lutrgb=b=0', --DEFAULT='null'  UNCOMMENT FOR RED & GREEN, INSTEAD OF RED & BLUE (DEFAULT).  PREFERRED format=gbrap ORDERED LIKE GreatBRitAin Planar. COLOR-CHAIN shuffleplanes & lutrgb MUCH MORE EFFICIENT THAN colorchannelmixer (+10% CPU), BUT CAUSES WARNINGS IN MPV-LOG DUE TO LACK OF ACCELERATED format CONVERSION.  BLUE, DARKBLUE & BLACK ARE COMPATIBLE WITH cropdetect (autocrop).  BLUE & WHITE STRIPES IS A DIFFERENT DESIGN, LIKE GREEK FLAG (NO RED).
    rotate             = 'a=PI/16*sin(2*PI*n/%s)*mod(floor(n/%s)\\,2)',                           --%s=(period*volume_fps)  DEFAULT=0 RADIANS CLOCKWISE. MAY DEPEND ON TIME t & FRAME # n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle. mod ACTS AS ON/OFF SWITCH. THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. 
    zoompan            = 'z=1+.2*(1-cos(2*PI*(on/%s-.2)))*mod(floor(on/%s-.2)\\,2)',              --%s=(period*volume_fps)  DEFAULT=1  on=OUTPUT FRAME NUMBER (OUTPUT MUST SYNC).  BEFORE SCOOTING RIGHT, IT MAY rotate (20% OFFSET).  20% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS. 
    overlay            = 'x=(W-w)/2:y=H*(.75+.05*(1-cos(2*PI*n/%s))*mod(floor(n/%s)+1\\,2))-h/2', --%s=(period*       fps)              x:y  DEFAULT=(W-w)/2:(H-h)/2  STREAM fps FOR overlay.   TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING. CONCEIVABLY A GAMEPAD COULD POSITION A complex. POSITIONING ON TOP OF BLACK BARS MAY DRAW ATTENTION TO THEM (PPL COULD END UP SPENDING HRS STARING AT THE BLACK BARS ABOVE OR BELOW THE FILM).
    dual_overlay       = 'x=(W-w)/2:y=H*.5-h/2', --DEFAULT='(W-w)/2:(H-h)/2' (CENTERED).  MAY DEPEND ON n & t (IT CAN FLY AROUND), BUT CLEARER IF STATIONARY. %s=(period*fps)  H*.55 FOR BELOW CENTER.
    dual_filterchain   = 'lutyuv=a=val/.7', --DEFAULT='null'  APPLIES AFTER PRIMARY filterchain. a=alpha=OPAQUENESS  lutyuv IS OPTIMAL (lutrgb TRIGGERS WARNINGS, BUT STILL FAST).
    dual_scale         = {.75,.75},  --RATIOS {WIDTH,HEIGHT}. REMOVE FOR NO DUAL. HEIGHT_RATIO=WIDTH_RATIO BY DEFAULT.  FULL BI-QUAD CONCEPT COMES FROM HOW RAW MP3 WORKS.  IN A SYMPHONY A LITTLE DUAL COULD FLOAT TO VARIOUS INSTRUMENTS, VIOLINS ETC.  THIS DUAL USES THE SAME aid.  IT'S ALSO POSSIBLE TO ADD A 3RD LITTLE COMPLEX ON TOP, LIKE PYRAMID. A CIRCULAR REMAP COULD BE LIKE A THIRD-EYE. 
    -- dual_filterchain= 'shuffleplanes=1:0:2:3,lutrgb=b=0:a=val/.7',  --UNCOMMENT FOR RED & GREEN DUAL. COLOR-CHAIN EFFICIENT BUT MPV-LOG WARNS LACK OF ACCELERATED format CONVERSION.  colorchannelmixer IS LESS EFFICIENT BUT SUPPORTS ANY MIX (SHUFFLING & DILUTING PAINT BUCKETS IS MORE EFFICIENT THAN ARBITRARY MIXING).
    dynaudnorm         = 'g=3:p=1:m=1',  --DEFAULT='g=3:p=1:m=1'  DYNAMIC AUDIO NORMALIZER FOR OUTPUT AUDIO [ao].  NULL-OP BUFFERS THE AUDIO ITSELF, WHICH IS PROGRAMATICALLY SUPERIOR. SOLVES ERROR IN MPV-LOG.  A DIFFERENT FILTER COULD ALSO WORK. THIS IS DETERMINISTIC FOR 10 HOURS (AUDIO UNCHANGED).
    gb                 =   .25, --DEFAULT= .3  RANGE [-2,2]  GREEN IN BLUE RATIO. PROPER COMPLEMENT OF RED REQUIRES SOME GREEN. BLUE+0*GREEN IS TOO DARK. COLOR-BLINDNESS MIGHT ALSO BE AN ISSUE. MOST EFFICIENT CODE SHOULD START WITH CORRECT COLOR SHADES, WITHOUT EXTRA colorchannelmixer.
    -- freqs_interpolation= true, --UNCOMMENT TO INTERPOLATE, FROM freqs_fps→volume_fps. ADDS ~7% CPU USAGE. HOWEVER CAN REDUCE fps FROM 30→25 TO SUBTRACT 15% CPU USAGE.   CAN REDUCE freqs_fps_albumart, TO INTERPOLATE FROM IT.  NICE LIGHTNING EFFECT BUT LOOKS JITTERY & FILM MAY STUTTER @autocrop.
    freqs_lead_time    =    .2, --DEFAULT= .1  SECONDS. LEAD TIME FOR SPECTRUM. SUBJECTIVE TRIAL & ERROR (.1 .2 .3 .4 ?). BACKDATES audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG.  A CONDUCTOR'S BATON MAY MOVE AN EXTRA .1s BEFORE THE ORCHESTRA, OR IT'S LIKE HE'S TRYING TO KEEP UP.
    freqs_scale_h      =   1.2, --DEFAULT=1.1  CURVE HEIGHT MAGNIFICATION. REDUCES CPU CONSUMPTION, BUT THE LIPS LOSE TRACTION.  L & R CHANNELS FORM LIKE A DUAL MOUTH (LIKE HOW HUMANS ARE BIPEDAL). 
    freqs_clip_h       =    .3, --DEFAULT= .3  MINIMUM=grid_height (CAN'T CLIP LOWER THAN grid, DUE TO INVERSE CANVAS pad). REDUCES CPU USAGE BY CLIPPING CURVE - CROPS THE TOP OFF SHARP SIGNAL. THE NEED FOR CLIPPING, LOW fps & size PROVE THE CODE MAY BE SLOW.
    freqs_alpha        =    .7, --DEFAULT= .7  RANGE [-2,2]  OPAQUENESS OF SPECTRAL DATA CURVE.  TRY .25 FOR mode=bar.
    freqs_fps          =  25/2, --DEFAULT=25/2 DOUBLING MAY CAUSE FILM TO STUTTER, IF TOO MANY GRAPHS ARE ACTIVE. freqs_clip_h ALSO IMPROVES PERFORMANCE.  TRY averaging=3 FOR MORE fps.
    freqs_fps_albumart =  25  , --DEFAULT=25   FOR RAW MP3 ALSO. CAN EASILY DOUBLE freqs_fps.
    freqs_options      = 's=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2',  --DEFAULT='s=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2'  EXTRA OPTIONS.  CAN ALSO SET overlap.  CAN'T CHANGE rate, fscale, colors & cmode.  INCREASE size FOR SHARPER CURVE (OR CHANGE ITS INTERNAL aspect).  mode={line,bar,dot}  win_func MAY ALSO BE poisson OR cauchy (PARZEN WAS AN AMERICAN STATISTICIAN).  win_size IS # OF DATA POINTS (LIKE TOO MANY PIANO KEYS).  
    freqs_dynaudnorm   = 'g=5:p=1:m=100:b=1',  --DEFAULT='g=31:p=.95:m=10:b=0'  THIS PASS APPLIES AFTER volume_dynaudnorm, RESAMPLING TO 2.1kHz, & SHIFTING freqs_lead_time.
    volume_filterchain = 'highpass=f=300,dynaudnorm=g=5:p=1:m=100:b=1', --DEFAULT='anull'  APPLIES ALSO TO freqs (volume GOES FIRST IN THIS MODEL).  300Hz highpass CLARIFIES SPECTRUM.  firequalizer IS AN ALTERNATIVE.
    volume_options     = 'f=0', --DEFAULT=  1  REMOVE FOR FADE.  CAN ALSO ENTER EXTRA options. EXAMPLE: "dm=1:dmc=RED" FOR DISPLAY-MAX-LINES.
    volume_fps         =    25, --DEFAULT= 25  PRIMARY ANIMATION fps. STREAM MAYBE 60fps BUT NOT THE EXTRA VISUALS.
    volume_alpha       =   .25, --DEFAULT= .5  RANGE [0,2]  0 REMOVES BARS (feet REMAIN). OPAQUENESS OF volume BARS.  DUAL volume TAKES CENTER STAGE.
    volume_width       =   .04, --DEFAULT=.04  RANGE (0,1]  RELATIVE TO width.
    volume_height      =   .15, --DEFAULT=.15  RANGE (0,1]  RELATIVE TO display, BEFORE STACKING feet. autocrop MAY MAGNIFY ITS SIZE.
    grid_alpha         =     1, --DEFAULT=  1  RANGE [0,2]  RELATIVE TO volume_alpha. 0 REMOVES grid & feet. alpha MULTIPLIER.
    grid_thickness     =   1/8, --DEFAULT= .1  RANGE (0,1]  RELATIVE TO grid SPACING. APPROX AS THICK AS CURVE.
    grid_height        =    .1, --DEFAULT= .1  RANGE (0,1]  RELATIVE TO display, BEFORE STACKING feet.  grid TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS.
    feet_height        =   .05, --DEFAULT=.05  RANGE [.01,1]  RELATIVE TO grid (BARS). 
    feet_activation    =    .5, --DEFAULT= .5  RANGE [0,1)  RELATIVE TO volume, FROM THE BOTTOM. feet BLINK ON/OFF WHEN volume PASSES THIS THRESHOLD.
    feet_lutrgb        = 'r=150:b=255:a=val*4',  --DEFAULT='r=128:b=255:a=val*4'  val*0 TO REMOVE feet. COLOR OF CENTRAL feet. 
    shoe_color         =            'BLACK@.4',  --DEFAULT @1.  @0 TO REMOVE.  A DIFFERENT VERSION COULD ALSO ADD o.grid_filterchain & o.grid_feet_lutrgb. (BLUE/RED OR RED/BLUE BARS?)  RED OUTER BARS SET OFF cropdetect.  
    -- sine_mix        = {{100,.5},{'200:1',1},{300,.5},{'400:1',1},{500,.5},{'600:1',1},{700,.5},{'800:1',1},{900,.5},{'1000:1',1}}, --{{frequency(Hz):beep_factor,volume},}  beep_factor OPTIONAL.  sine WAVES FOR CALIBRATION MIX DIRECTLY INTO [ao]. THIS EXAMPLE BEEPS DOUBLE ON EVEN. BEEP ACTIVATES feet, & MAY HELP SET freqs_lead_time.  THE 900Hz PEAK LINES UP, BUT THE SURROUNDING CURVE SKEWED ABOVE 900Hz.
    -- scale           = {w=1680,h=1050},  --DEFAULT=display OR [vo]. EVEN NUMBERS ONLY FOR MPV-v0.38.0.
    options            = ''     --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.        
        ..' vd-lavc-threads=0' --VIDEO DECODER - LIBRARY AUDIO VIDEO. 0=AUTO OVERRIDES SMPLAYER, OR ELSE MAY FAIL TESTING.
        ..'   osd-font-size=16  geometry=50%  force-window=yes'  --DEFAULT size 55p MAY NOT FIT osd_on_toggle. geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  force-window PREVENTS MPV FROM VANISHING DURING TRACK CHANGES.
    ,
} 
o          = options  --ABBREV.
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,width=1,fps=30,period=1,filterchain='null',rotate=0,zoompan=1,overlay='(W-w)/2:(H-h)/2',dual_overlay='(W-w)/2:(H-h)/2',dual_filterchain='null',dual_scale={},gb=.3,dynaudnorm='g=3:p=1:m=1',freqs_lead_time=.1,freqs_fps=25/2,freqs_fps_albumart=25,freqs_options='s=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2',freqs_scale_h=1.1,freqs_clip_h=.3,freqs_alpha=.7,freqs_dynaudnorm='',volume_filterchain='anull',volume_options='',volume_fps=25,volume_alpha=.5,volume_width=.04,volume_height=.15,grid_alpha=1,grid_thickness=.1,grid_height=.1,feet_height=.05,feet_activation=.5,feet_lutrgb='r=128:b=255:a=val*4',shoe_color='',scale={},options=''})
do o[opt]  = o[opt] or val end  --ESTABLISH DEFAULTS. 
o.options  = (o.options):gsub('-%-','  '):gmatch('[^ ]+') --'-%-' MEANS "--".  gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE. %g (GLOBAL) PATTERN DOESN'T EXIST IN THE LUA VERSION CURRENTLY USED BY mpv.app ON MACOS.  
while true   
do    opt  = o.options()  
      find = opt  and (opt):find('=')  --RIGOROUS FREE-FORM. 
      val  = find and (opt):sub(  find+1) or o.options()  --SKIP+2 PASSED "=", OR ELSE NEXT gmatch.
      opt  = find and (opt):sub(0,find-1) or opt
      if not val then break    end
      mp.set_property(opt,val) end  --mp=MEDIA-PLAYER
mp.command('no-osd change-list script-opts append lavfi-complex=yes')  --WARN OTHER SCRIPTS IMAGES WILL loop.  OTHERWISE THEY MAY HAVE TO OBSERVE lavfi-complex. 

for opt in ('rotate zoompan period'):gmatch('[^ ]+') do o[opt]=o[opt]..'' end  --..'' CONVERTS→string.
if o.period=='0' then for opt in ('rotate zoompan overlay dual_overlay'):gmatch('[^ ]+') --DON'T DIVIDE BY 0 BY REMOVING TIME DEPENDENCE.
    do for nt in ('in on n t      '):gmatch('[^ ]+') do o[opt]=o[opt]:gsub(nt..'/%%s',0) end end end     --in & on BEFORE n.  OVERRIDE: THIS CODE ONLY GSUBS "t/%s" ETC (NOT FULLY GENERAL).
for opt in ('rotate  zoompan      '):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.volume_fps)) end  --ANIMATIONS ARE @volume_fps. OPTIMIZE USING DIFFERENT fps.
for opt in ('overlay dual_overlay '):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.       fps)) end  --OVERLAYS ARE @STREAM fps.

amix,p       = '',{}  --amix IMPLEMENTS o.sine_mix. p=PROPERTIES table.
if o.sine_mix 
then amix    = ',[ao]'  --"," SEPERATES THE SINES FROM THE MIX.
     for N,sine in pairs(o.sine_mix) 
     do amix = (',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],N,amix,N) end  --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).
     amix    = ('[ao]%samix=%d:first'):format(amix,#o.sine_mix+1) end     --amix [ao][a1][a2]...  SINE WAVES ARE INFINITE DURATION. EMPTY sine_mix VALID.
vflip        = o.vflip_scale and o.vflip_scale+0>0  --+0 CONVERTS→number. 
               and ('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'):format(o.vflip_scale,o.vflip_scale)  --scale & pad FOR BOTTOM. PADDING SIMPLIFIES CODE.
vstack       = not  vflip      and         'pad=0:ih*2:0:0:BLACK@0'       --TOP ONLY. pad*2 FOR ABSENT TOP OR BOTTOM SIMPLIFIES CODE.
               or o.vflip_only and vflip..',pad=0:ih*2:0:oh-ih:BLACK@0'   --BOTTOM ONLY, PADS DOUBLE.  
               or         ('split[U],%s[D],[U][D]vstack'):format(vflip)   --BOTH  [U],[D] = UP,DOWN = TOP,BOTTOM  vstack IS TOP/BOTTOM.
vstack       = (vflip or not o.vflip_only) and o.filterchain..','..vstack --PREPEND COLOR SHUFFLING/MIXING, UNLESS NULL OVERRIDE (CASES 1 OR 2: JPEG loop OR fps LIMIT).


lavfi=('[aid%%d]dynaudnorm=%s%s,asplit[ao],stereotools,%s,asplit[af],aformat=s16,showvolume=%s:0:128:8:t=0:v=0:o=v:%s,format=gbrap,shuffleplanes=0:0:2:3,lutrgb=g=val*(%s):a=val*(%s),split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],shuffleplanes=2:2:1:3,lutrgb=g=val*(%s)[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih*(%s)/(%s):0:oh-ih:BLACK@0[grid],[af]apad,aformat=s16:2100,asetpts=max(0\\,PTS-(%s)/TB),dynaudnorm=%s,aformat=s16,showfreqs=%s:colors=BLUE|RED:%%s,fps=%%s,crop=iw/1.05:ih*(%s)/(%s):0:ih-oh,format=gbrp,scale=iw*2:-1,avgblur=1:4+2,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2:4+2,lutrgb=r=255*gt(val\\,90):b=255*gt(val\\,90),framerate=%%s,format=gbrap,split[R],shuffleplanes=0:0:1:1,lutrgb=a=val*(%s),hflip[L],[R]shuffleplanes=0:0:2:2,lutrgb=a=val*(%s)[R],[grid][L]scale2ref=iw*2-2:ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w,scale=ceil(iw/4)*4:ceil(ih/4)*4,format=gbrap,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,shuffleplanes=2:2:1:3,lutrgb=g=val*(%s)[LHI],[RHI]crop=iw/4:ih:iw-ow,shuffleplanes=2:2:1:3,lutrgb=g=val*(%s)[RHI],[LHI][MIDDLE][RHI]hstack=3[vid],[vol][vid]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/(%s)/4)*4[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,split=3[vo][t0],crop=1:1:0:0:1:1,fps=%s,format=yuva420p,lutyuv=0:128:128:0[to],[to][vid]scale2ref,overlay,setpts=PTS-STARTPTS,rotate=%s:c=BLACK@0,zoompan=%s:d=1:s=%%dx%%d:fps=%s[vid],[vo]setpts=PTS-STARTPTS[vo],[vo][vid]overlay=%s[vo],[t0]trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[t0],[t0][vo]concat,trim=start_frame=1,format=%%s[vo]')
    :format(o.dynaudnorm,amix,o.volume_filterchain,o.volume_fps,o.volume_options,o.gb,o.volume_alpha,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.gb,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.freqs_clip_h,o.grid_height,o.freqs_lead_time,o.freqs_dynaudnorm,o.freqs_options,o.freqs_clip_h,o.freqs_scale_h,o.freqs_alpha,o.freqs_alpha,o.gb,o.gb,o.volume_width,o.volume_height,o.freqs_clip_h,vstack,o.volume_fps,o.rotate,o.zoompan,o.volume_fps,o.overlay)  --gb*4 TO BRIGHTEN BLUE IN [vol], [feet], [LHI] & [RHI]. volume_fps FOR volume, TIME-STREAM [to] & zoompan. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha FOR L & R CHANNELS. 

----lavfi           = graph LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  [vid#]=VIDEO-IN [aid#]=AUDIO-IN [vo]=VIDEO-OUT [ao]=AUDIO-OUT [vid]=SPECTRUM [af]=AUDIO-FREQS [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [L]=LEFT [R]=RIGHT [vol]=VOLUME [grid]=VOL-BARS.  SELECT FILTER NAME OR LABEL TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH LINEDUPLICATE ETC. lavfi-complex MAY COMBINE MANY [aid#] & [vid#] INPUTS. %% SUBS OCCUR LATER. (%s) BRACKETS FOR MATH.  A lavfi string IS LIKE DNA & CAN CREATE VARIOUS CREATURES. SEE FFMPEG-FILTERS MANUAL. A BRICK OF EQUATIONS DEFINE STRING INSERTS.  EACH FOOT HAS A STEREO INSIDE IT. [feet0] (SHOES) ARE THE CENTER-PIECE.  [to] & [t0] CODES ALWAYS VALID, EVEN ON YOUTUBE & FOR MP4 SUBCLIPS WITH OFF TIMESTAMPS. IMPOSSIBLE TO CORRECTLY ENTER NUMBERS LIKE time-pos OR audio-pts. CANVAS [to] SWITCHES OUT [ao]→[vo] TIMESTAMPS (IT'S ACTUALLY [time-vo]).
----dynaudnorm      = ...:g:p:m:...:b  DEFAULT=...:31:.95:10:...:0  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:...:BOUNDARY_MODE{0,1}  IS THE START.  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  MAY BE BLANK.  b=NO_FADE (FADE NOT FOR SPECTRUM). IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g MAY GIVE FASTER RESPONSE. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. 
----sine            = frequency:beep_factor  →s16  (Hz,BOOL)  DEFAULT=440:0  beep IS EVERY SECOND.  FOR sine_mix CALIBRATION.
----volume          = volume  DEFAULT=1  RATIO. sine VOLUMES. FORMS TRIPLE WITH sine & amix.
----amix            = inputs:duration  DEFAULT=2:longest  MIXES IN SINES. [a1][a2]...→[ao]
----split,asplit    = outputs  DEFAULT=2  CLONES video/audio.
----highpass        = f  →floatp  DEFAULT=3000 Hz  MAY BE BLANK.  firequalizer IS MORE GENERAL & COULD MULTIPLY BY FREQUENCY. A CHIRP MAY BECOME DEAFENING @DOUBLE FREQUENCY.
----showvolume      = r:b:w:h:f:...:t:v:o:...:dm:dmc = rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION:...:DISPLAYMAX:DISPLAYMAXCOLOR →rgba    (DEFAULTS 25:1:400:20:0.95:t=1:v=1:o=h)   LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED.  THERE'S SOME TINY BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----showfreqs       = size:rate:mode:ascale:fscale:win_size:win_func:...:averaging:colors  →rgba  DEFAULT=1024x512:25:bar:log:lin:2048:hanning:...:1   RATE INCOMPATIBLE WITH FFMPEG-v4. size SHOULD HAVE ASPECT APPROX 3x5 FOR HEALTHY CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (300x300 & 300x700 ARE OFF).  win_size BTWN 256 & 2048.  cmode=separate WOULD REQUIRE TWICE AS MANY PIXELS.
----shuffleplanes   = map0:map1:map2:map3  DEFAULT=0:1:2:3  REDUCES NET CPU USAGE BY >5%. ORDERED g:b:r:a (LIKE GreatBRitAin, WITH RED ON RIGHT). SHUFFLES WITHOUT MIXING.  FFMPEG-v4 COMPATIBILITY DEPENDS ON EXACT USAGE.  SWITCHES [vol] GREEN & BLUE, [feet] FROM [feet0], & COLORS HIGHS VS LOWS, & [L][R] CHANNELS.
----fps             = fps:start_time (SECONDS)  LIMITS STREAM @file-loaded. ALSO FOR OLD MPV showfreqs. start_time FOR JPEG=OFF.
----framerate       = fps  (DEFAULT=50)  alpha CAUSES BUG (gbrp NOT gbrap). NEGATIVE TIME ALSO CAUSES BUG. DOUBLING fps ADDS 10% CPU USAGE. 
----rotate          = a:ow:oh:c  (RADIANS:PIXELS:PIXELS:string) ROTATES CLOCKWISE, DEPENDING ON n & t.
----zoompan         = z:x:y:d:s:fps   (z>=1)  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN.  z:x:y MAY DEPEND ON  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----setpts,asetpts  = expr  DEFAULT=PTS  PRESENTATION TIMESTAMP, FOR SYNC OF rotate,zoompan,overlay WITH OTHER GRAPHS (automask), BY SENDING STARTPTS→0. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO.
----pad,apad        = w:h:x:y:color,...  DEFAULT=0:0:0:0:BLACK  BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih.  apad APPENDS SILENCE FOR SPECTRUM TO ANALYZE, OR THERE'S A CRASH @end-file. AN ALTERNATIVE IS TO EXPAND TIMESTAMPS NEAR end-file.
----loop            = loop:size  ( >=-1 : >0 ) PAIRS WITH fps FOR RAW JPEG, WHICH IS ITS OWN CASE-STUDY WITH ITS OWN FILTER (MOST ELEGANT).
----crop            = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES LOWS FROM [LHI] & [RHI]. CROPS 5% OFF DATA. FFMPEG-v4 REQUIRES ow INSTEAD OF oh (DEPENDING).
----lutyuv,lutrgb   = y:u:v:a,r:g:b:a  DEFAULT=val  LOOK-UP-TABLE-BRIGHTNESS-UV,RED-GREEN-BLUE  lutyuv CONVERTS gbrap→yuva444p. lutrgb CONVERTS yuva420p→argb. lutyuv IS MORE EFFICIENT THAN lutrgb DUE TO FORCED FORMATTING.  lut HAS A BUG WHERE MAYBE r=green BECAUSE IT ASSUMES r IS PLANE 0 FOR gbrap.  lutyuv CREATES TRANSPARENCY & CANVAS. lutrgb SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.  SERATED-RAZOR-CURVE IS ANOTHER IDEA.
----avgblur         = sizeX:planes  DEFAULT=1:15  (INTEGERS,planes<16)  AVERAGE BLUR  sizeY=sizeX (PIXELS)  FOR gbrap planes=8(GREEN)+4(BLUE)+2(RED)+1(ALPHA). IT'S MORE EFFICIENT TO SELECT COLORS BY INTEGERS 8,4,2. CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTHER CURVE.
----scale,scale2ref = w:h  DEFAULT=iw:ih  SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.     TO-REFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume.
----overlay         = x:y:eof_action →yuva420p  DEFAULT=0:0:repeat  endall DUE TO apad. FORCES US TO USE yuva420p, WHICH MIGHT BE WHY MULTIPLES OF 4 ARE NEEDED. AN EVEN WIDTH ISN'T GOOD ENOUGH BECAUSE THE COLOR PLANE WIDTH MAY BE ODD & NOT CENTERED PROPERLY (OPTIMIZATION ISSUE). OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON TIME t.  UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4.  IF COLOR RES IS A PROBLEM, A WORKAROUND IS TO USE A RES_MULTIPLIER=2 THEN HALVE yuv420p→yuv444p.
----hstack,vstack   = inputs  DEFAULT=2  COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES feet.  vstack FOR FEET & TOP/BOTTOM.
----trim            = ...:start_frame:end_frame  TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP.
----format,aformat  = pix_fmts,sample_fmts:sample_rates  (yuva420p yuv420p gbrap gbrp=rgb24),s16:Hz  IS THE FINISH (TO REMOVE alpha). MAY BE BLANK.  gbrap (GreatBRitAin Planar) ASSUMED BY shuffleplanes. yuva420p FORCED BY overlay.  aformat REMOVES doublep PRECISION AFTER dynaudnorm, & DOWNSAMPLES TO 2100Hz (NYQUIST+5%). 
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo.  ALTERNATIVE TO aformat.  softclip INCOMPATIBLE WITH FFMPEG-v4.
----hflip,vflip       FLIPS [L] LEFT.  vflip FOR BOTTOM [D] (DOWN).
----setsar            SAMPLE ASPECT RATIO. FOR albumart SAFE concat OF [t0].
----concat            [t0][vo]→[vo]  FINISHES [t0].  CONCATENATE STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. NEEDED TO SYNC WITH automask.


function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER, TO MULTIPLES OF 4.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end

function file_loaded()  --ALSO on_aid_vid & on_toggle{ON}.    THIS COULD BE REPLACED BY on_av_params. BUT THE .1s DELAY TO DETECT alpha CAUSES RANDOM STUTTER @LOAD.
    a        = mp.get_property_native('current-tracks/audio') or {}
    v        = mp.get_property_native('current-tracks/video') or {}  --mp.get_property_native TAKES ~13 MICROSECONDS, BUT mp.get_property_number TAKES ONLY ~5us. TABLES CONTAIN MANY NUMBERS SO ARE MORE EFFICIENT.
    v_params = mp.get_property_native('video-params'        ) or {}
    W        = o.scale.w or o.scale[1] or mp.get_property_number('display-width' ) or v_params.w or v['demux-w'] or 1920  --(scale OVERRIDE) OR (display) OR ([vo] DIMENSIONS) OR (FALLBACK FOR RAW MP3 IN VIRTUALBOX)
    H        = o.scale.h or o.scale[2] or mp.get_property_number('display-height') or v_params.h or v['demux-h'] or 1080
    OFF      = OFF or not a.id or not vstack  --NO AUDIO OR vstack → OFF.
    if   OFF 
    then OFF = false --FORCE TOGGLE OFF, IF OFF.
        on_toggle()  --COVERS OFF CASES. EXAMPLE: JPEG=OFF-albumart.  THE TOGGLE DOESN'T CLEAR lavfi-complex. IT ONLY CLEARS THE SPECTRUM & CPU USAGE. SOMETIMES A FILE-LOAD IS NOTHING BUT A TOGGLE OFF.
        return end   --ON BELOW. 
    if not error_ffmpeg then _,error_ffmpeg = mp.command('no-osd vf append @lavfi-format:lavfi-format')  end  --OLD FFMPEG DETECTION. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THEY CAN BE ANYTHING. SO DETECT ERROR USING NULL-OP.
    if not error_ffmpeg then                  mp.command('no-osd vf remove @lavfi-format') end
    
    clip_w,clip_h = round(W*o.width,4),round(H*o.freqs_clip_h*2,4)  --FINAL CLIP HEIGHT FOR (PADDED) TOP & BOTTOM (*2). CLEARER TO NAME EACH # (NAME EVERYTHING).
    dual_w     = o.dual_scale[1] and round(o.dual_scale[1]*W,4)
    dual_h     = dual_w and round((o.dual_scale[2] or o.dual_scale[1])*H*o.freqs_clip_h*2,4)  --DEFAULT: SCALE_Y=SCALE_X
    freqs_fps  = (v.albumart or not v.id) and o.freqs_fps_albumart or o.freqs_fps  --freqs_fps MAY VARY on_vid. SOME ANIMATIONS (LIKE FRACTALS) CAN BE DONE SMOOTHER ON albumart.
    framerate  = o.freqs_interpolation and o.volume_fps or freqs_fps  --INTERPOLATION: freqs_fps→volume_fps
    freqs_rate = error_ffmpeg and '' or 'rate='..freqs_fps  --FFMPEG-v4 OPERATES showfreqs @25fps (.AppImage & .snap). LATER VERSIONS SUPPORT ANY fps.
    format     = (not v.id or v_params.alpha) and (error_ffmpeg and 'yuva420p' or '') or 'yuv420p'  --AKA pixelformat. lavfi-complex CAN'T DETECT WHETHER alpha EVER EXISTED WITHOUT A DELAYED TRIGGER.  overlay FORCES yuva420p, BUT SHOULD REMOVE alpha BECAUSE ITS EXISTENCE MAY TRIGGER BUGS IN VARIOUS SCRIPTS.  OLD FFMPEG REQUIRES SPEC.
    p['end']   = mp.get_property('end') 
    complex    = (  --3 CASES:  1) PROPER-VIDEO  2) albumart  3) AUDIO-ONLY    CAN CHECK MPV LOG TO VERIFY OUTPUT IN EVERY CASE. INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. EXAMPLE: automask.lua albumart ANIMATION.
                  v.id and not v.image and ('[vid%d]fps=%s,scale=%d:%d'):format(v.id,o.fps,W,H)  --CASE 1: NORMAL video.  complex=lavfi INSERT WHICH YIELDS [vo].  
                  or v.id and ('[vid%d]scale=%d:%d,loop=-1:1[vo],[vid]split[vid],trim=end_frame=1,crop=1:1:0:0:1:1,scale=%d:%d,setsar[t0],[t0][vo]concat,trim=start_frame=1,fps=%s'):format(v.id,W,H,W,H,o.fps)  --CASE 2 (albumart) IS THE MOST COMPLICATED. albumart IS LOOPED, WITH ATOMIC TIMESTAMP FRAME [t0] PREPENDED & TRIMMED, TO SUPPORT PROPER seeking.  ALTERNATIVE IS TO INSERT time-pos @seek BUT THAT CAUSED SOME LAG.
                  or ('[vid]split[vid],crop=1:1:0:0:1:1,lutyuv=0:128:128:0,scale=%d:%d,fps=%s'  ):format(W,H,o.fps)  --CASE 3  (RAW AUDIO)  USES [vid] INSTEAD OF [vid#] TO BUILD BLANK [vo] UNDERLAY. [vid] IS THE SPECTRUM. 
                 ).. (dual_w and ('[vo],[vid]split[vid],%s,scale=%d:%d[dual],[vo][dual]overlay=%s'):format(o.dual_filterchain,dual_w,dual_h,o.dual_overlay)  --LABELS [vid1][vid2] ETC NOT ALLOWED (RESERVED). 
                      or '')  --NO dual.
    
    mp.set_property('lavfi-complex',(lavfi):format(a.id,freqs_rate,freqs_fps,framerate,complex,clip_w,clip_h,format))  
    if p['end']=='none' or p['end']=='100%' then mp.set_property('end',-.2) end  --SUBTRACT .2s, BY TRIAL & ERROR. ALTERNATIVE TO TRIMMING TIMESTAMPS IN lavfi-complex.  TESTED MPV-v0.38 ON 10 HOURS albumart. WITHOUT SUBTRACTION SMPLAYER HANGS NEAR end-file.
end 
mp.register_event('file-loaded',file_loaded)
mp.register_event('seek',function() if (mp.get_property_number('time-remaining') or .2)<.2 then mp.command('playlist-next force') end end)  --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST. .2 FOR seek PASSED end CORRECTION.  BUGFIX FOR seek PASSED end-file.  A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES, PASSED end-file.

function on_toggle(mute)     --AN ALTERNATIVE (FULL) TOGGLE COULD stop keep-playlist & playlist-play-index current TO FULLY CLEAR lavfi-complex. BUT THAT SNAPS THE WINDOW & INTERRUPTS PLAYBACK, LIKE on_aid_vid. THIS TOGGLE JUST REMOVES THE SPECTRUM FROM THE lavfi-complex.
    if not timer then return --STILL LOADING.
    elseif mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.  DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute IF seeking. IT CANCELS ITSELF OUT IN SMPLAYER.
        return end
    
    OFF,p = not OFF,{} --REMEMBER TOGGLE STATE & p=PROPERTIES.
    if not OFF then file_loaded()  --TOGGLE ON. 
    else complex=v.id and not v.image and   (',[vid%d]fps=%s,scale=%d:%d[vo]'):format(v.id,o.fps,W,H) --CASE 1: TOGGLE OFF MP4. LIMIT [vo], WITH NO SPECTRUM.
                 or v.id  and  (',[vid%d]scale=%d:%d,loop=-1:1,fps=%s:%s[vo]'):format(v.id,W,H,o.fps,mp.get_property_number('time-pos'))  --CASE 2: image. MORE GENERAL THAN albumart. NO pixelformat TO PRESERVE TRANSPARENCY.  CAN USE ~25% CPU @FULLSCREEN.  NEED start_time FOR --start.  FFmpeg-v5 TAKES A STILL FRAME (DIFFERENT, BUT VALID).  UNFORTUNATELY SNAPS EMBEDDED MPV.
                 or ''  --CASE 3. RAW audio STATIC SPECTRUM.  CAN CHECK MPV LOG TO VERIFY OUTPUT IN EVERY CASE. 
         complex=a.id and ('[aid%d]dynaudnorm=%s[ao]%s'):format(a.id,o.dynaudnorm,complex)  --PREPEND NORMALIZED AUDIO. CASE 3 IS NOTHING BUT AUDIO.
                 or complex:sub(2)  --REMOVE LEADING "," IF NO AUDIO (POSSIBLY CASES 1 & 2).  FFMPEG-v5 THROWS ERROR ON TRAILING ",".
         mp.set_property('lavfi-complex',complex) end
    if o.osd_on_toggle then for property in ('mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params'):gmatch('[^ ]+')
            do table.insert(p,mp.get_property_osd(property)) end
            mp.osd_message(('mpv-version: %s\nffmpeg-version: %s\nlibass-version: %s\n\nlavfi-complex: %s\n\nAudio filters: \n%s\n\nVideo filters: \n%s\n\nvideo-out-params: \n%s')  --LISTS CAN HAVE MORE LINES.
                    :format(p[1],p[2],p[3],p[4],p[5],p[6],p[7]),o.osd_on_toggle) end   --.flatpak LUA VERSION DOESN'T SUPPORT table.unpack(p).
end
for key in (o.key_bindings):gmatch('[^ ]+') do mp.add_key_binding(key, 'toggle_complex_'..key, on_toggle) end --MAYBE SHOULD BE 'toggle_spectrum_' BECAUSE THIS TOGGLE ONLY TURNS OFF/ON THE SPECTRUM.
mp.observe_property('mute','bool',on_toggle)

timer         = mp.add_periodic_timer(o.toggle_on_double_mute, function()end)  --CARRIES OVER IN MPV PLAYLIST.
timer.oneshot = true
timer:kill() 

function end_file()
    v=nil  --NILLIFY FOR on_aid_vid.
    mp.set_property('lavfi-complex','')  --UNLOCK aid & vid.  COULD ALSO DO THIS @SCRIPT-LOAD.
end 
mp.register_event('end-file',end_file)

function on_aid_vid(property,id)   --id=nil OR number.  ONLY GOOD FOR SWITCHING BTWN 1 & 2 (BOTH aid & vid). UNLOCKS lavfi-complex & RESTARTS @time-pos (LIKE A FULLY SLOW TOGGLE).  UNFORTUNATELY SNAPS EMBEDDED MPV (THE VIDEO DIMENSIONS CHANGE AS lavfi-complex UNLOCKS). AN ANTI-SNAP GRAPH IS MORE CODE.
    if not v or id then return end --~v BEFORE & AFTER file.  id IMPLIES 1←→2 SWITCH UNNECESSARY. ~id IS CONTRADICTION.
    aid=property=='aid' and (a.id==1 and 2 or 1)
    vid=property=='vid' and (v.id==1 and 2 or 1)
    
    mp.command('stop keep-playlist')
    end_file()  --REQUIRED.
    if aid then mp.set_property_number('aid',aid)   --SET AFTER stop, IF WELL-DEFINED.
    else        mp.set_property_number('vid',vid) end
    mp.set_property('start',mp.get_property('time-pos'))  --start=time-pos REQUIRED.
    mp.command('playlist-play-index current')  --FLAGS NOT ALLOWED (v0.36).  →file-loaded
end 
mp.observe_property('aid','number',on_aid_vid)  --UNTESTED
mp.observe_property('vid','number',on_aid_vid)  --  TESTED


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 3 CASES), LINE TOGGLES (options), MIDDLE (GRAPH SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV v0.38.0(.7z .exe v3) v0.37.0(.app) v0.36.0(.exe .app .flatpak .snap v3) v0.35.1(.AppImage)  ALL TESTED. 
----FFMPEG v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.3.2(.AppImage)  ALL TESTED. MPV-v0.36.0 IS OFTEN BUILT WITH FFMPEG v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----WIN-10 MACOS-11 LINUX-DEBIAN-MATE  ALL TESTED.
----SMPLAYER v23.12 v23.6, RELEASES .7z .exe .dmg .AppImage .flatpak .snap ALL TESTED. v23.6 MAYBE PREFERRED.

----BUG: SOME YT VIDEOS GLITCH @START (PAUSING). EXAMPLE: https://youtu.be/D22CenDEs40
----BUG: SMPLAYER v23.12 PAUSE TRIGGERS GRAPH RESET (LAG). FIX: CAN USE v23.6 (JUNE RELEASE) INSTEAD, OR GIVE MPV ITS OWN WINDOW. SMPLAYER NOW COUPLES A seek-0 WITH pause. "no-osd seek 0 relative exact" WITHIN 1ms OF "set pause yes". THEN paused TRIGGERS WITHIN A FEW ms. 
----A DIFFERENT VERSION COULD COMPRESS 1→10kHz INTO AN ELEVENTH TICKMARK.

----ALTERNATIVE FILTERS:
----colorchannelmixer=rr:...:aa   (RANGE -2→2, r g b a PAIRS)  DEFAULT rr=1,rg=0,ETC.  A BIT SLOW LIKE geq SO NOT USED BY DEFAULT.
----firequalizer      MAY BE NEEDED TO MODEL HUMAN EAR RESPONSE. CAN REPLACE highpass & MULTIPLY BY frequency. (A HIGH PITCHED CHIRP IS DEAFENING TO HUMAN, BUT SAME AMPLITUDE.)
----afftfilt         =real:imag:win_size:win_func:overlap  DEFAULT=1|1:1|1:4096:hann:0.75  (AUDIO FAST FOURIER TRANSFORM FILTER) overlap<1 CAUSES BUG. MAY ALSO HELP MODEL HUMAN EAR SENSITIVITY.
----geq               GLOBAL EQUALIZER IS TOO SLOW @25fps EXCEPT ON A SINGLE GRID ELEMENT OR LINE. MAYBE POSSIBLE TO USE IT TO REMAP ONTO CIRCLE OR SMILY/FROWNY FACE.
----asettb           =tb    OPTIONAL TIMEBASE SPEC. MAY PROVIDE fps HINT TO FURTHER FILTERS.
----select           =expr  DEFAULT=1  EXPRESSION DISCARDS FRAMES IF 0.  MAY HELP WITH OLD MPV (PREVENTED MEMORY LEAK WHEN TRIMMING FOR [t0]).
----loudnorm         =I:LRA:TP   DEFAULT -24:7:-2. INTENSITY TARGET (-70 TO -5) : LOUDNESS RANGE (1 TO 20) : TRUE PEAK (-9 TO 0). CAUSED DEFECT REQUIRING apad. LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM, NOT A RAW AUDIO STREAM.
----acompressor       SMPLAYER DEFAULT NORMALIZER. LOOKS BAD.
----aresample         (Hz) DOWNSAMPLES TO 2.1kHz (NYQUIST+5%). AN ALTERNATIVE IS aformat.
----extractplanes    =planes    r+b→[R][L] (RED+BLUE)   REVERSED IF [L] GETS FLIPPED AROUND.
----alphamerge        [y][a]→[ya]  USES lum OF [a] AS alpha OF [ya]. CAN PAIR WITH split TO CONVERT BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey, colorchannelmixer & shuffleplanes.

----ALTERNATIVE GRAPH EXAMPLE CODES:
--EXTRACTPLANES LR MONOCHROME (FASTER?):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,2010,o.freqs_lead_t,o.volume_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_scale_h,2,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,vstack,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 
--SHUFFLEPLANES:    lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')
--NOSHUFFLEPLANES:  lavfi=('[aid%%d]%sasplit[ao],stereotools,highpass=%s,dynaudnorm=%s,asplit[af],showvolume=%s:0:128:8:%s:t=0:v=0:o=v:dm=%s:dmc=RED,colorchannelmixer=aa=%s:bg=1:gg=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aresample=2e3*1.05,asetpts=PTS-(%s)/TB,apad,dynaudnorm=%s,showfreqs=300x500:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw/1.05:ih*(%s):0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lutrgb=255*gt(val\\,90):0:255*gt(val\\,90),framerate=%s,format=rgb32,split[R],colorchannelmixer=bb=0:aa=0:ab=%s:rb=1:rr=0,hflip[L],[R]colorchannelmixer=bb=0:aa=0:ar=%s[R],[grid][L]scale2ref=iw*2-2:ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w:0:endall,scale=ceil(iw/4)*4:ih,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[LHI],[RHI]crop=iw/4:ih:iw-ow,colorchannelmixer=rb=1:br=1:rr=0:bb=0:gb=-%s:gr=%s[RHI],[LHI][MIDDLE][RHI]hstack=3[vid],[vol][vid]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,split[vo],crop=1:1:0:0:1:1,fps=%s,format=yuva420p,lut=0:128:128:0,split[to],select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[t0],[to][vid]scale2ref,overlay,setpts=PTS-STARTPTS,format=yuva420p,rotate=%s:iw:ih:BLACK@0,zoompan=%s:1:%%dx%%d:%s[vid],[vo]setpts=PTS-STARTPTS[vo],[vo][vid]overlay=%s[vo],[t0][vo]scale2ref,concat,trim=start_frame=1[vo]'):format(amix,o.volume_highpass,o.dynaudnorm,o.volume_fps,o.volume_fade,o.volume_dm,o.volume_alpha,o.gb,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.gb,o.gb,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.grid_height..'/'..o.freqs_clip_h,o.freqs_lead_time,o.dynaudnorm,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h..'/'..o.freqs_scale_h,o.volume_fps,o.freqs_alpha,o.freqs_alpha,o.gb,o.gb,o.gb,o.gb,o.volume_width,o.volume_height..'/'..o.freqs_clip_h,vstack,o.volume_fps,o.rotate,o.zoompan,o.volume_fps,o.overlay)  --gb*7 TO PROPERLY INVERT WHITE SHOES RE. RED & BLUE. volume_fps FOR volume & TIME-STREAM zoompan INPUT. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha FOR L & R CHANNELS. 
--WITH MIDDLE FOOT: lavfi=('[aid%%d]atrim=%%s,asetpts=PTS-STARTPTS+(%%s)/TB,asplit[ao]%s,stereotools,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],showvolume=%s:0:%d:8:%s:t=0:v=0:o=v:dm=%s,colorchannelmixer=gg=%s:bg=1:aa=%s,split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(%s),colorchannelmixer=rb=1:gr=%s:br=1:rr=0:gg=0:bb=0:aa=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:BLACK@%s,split[FOOT],split,hstack[feet],[FOOT]colorchannelmixer=rb=1:br=1:rr=0:bb=0:aa=2,scale=iw*2:ih[FOOT],[vol][FOOT]vstack[vol],[BAR][feet]vstack,lut=a=val*(%s),split[grid-R],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[grid-L],[grid-R]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[grid-R],[grid-L][grid-R]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[grid],[af]aformat=s16:%s,highpass=%s,apad,dynaudnorm=p=1:m=100:c=1:b=1,asetpts=PTS-(%s)/TB,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=%s:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,format=rgb24,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90):0:255*gt(val\\,90),format=rgb32,split[L],colorchannelmixer=bb=0:ar=%s:aa=0[R],[L]colorchannelmixer=bb=0:ab=%s:aa=0:rb=1:rr=0,hflip[L],[grid][R]scale2ref=iw*2-(%s):ih,overlay=W-w:0:endall[grid],[grid][L]overlay=0:0:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HI-R][LOWS],crop=iw/4:ih:0,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-L],[LOWS]crop=iw/2[LOWS],[HI-R]crop=iw/4:ih:iw-ow,colorchannelmixer=rr=0:gg=0:bb=0:rb=1:gr=%s:br=1[HI-R],[HI-L][LOWS][HI-R]hstack=3[vid],[vol][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[vol][vid],[vid][vol]overlay=(W-w)/2:H-h,%s[vid],%%s,setpts=PTS-STARTPTS[vo],[vid]setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[vo][vid]overlay=%s,setpts=PTS+(%%s)/TB,format=%s,setsar=1[vo]'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_dm,o.gb,o.volume_alpha,o.feet_height,o.feet_activation,o.gb,o.feet_alpha,o.feet_alpha/4,o.grid_alpha,o.grid_thickness,o.grid_thickness,f(o.grid_height/o.freqs_clip_h),2010,o.volume_highpass,o.freqs_lead_time,o.freqs_mode,o.freqs_win_size,o.freqs_win_func,o.freqs_averaging,o.freqs_fps,f(o.freqs_clip_h/o.freqs_scale_h),o.freqs_alpha,o.freqs_alpha,2,o.gb,o.gb,o.volume_width,f(o.volume_height/o.freqs_clip_h),vstack,o.rotate,o.zoompan,o.fps,o.overlay,o.format)    --fps FOR volume, freqs & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER [FEET]. freqs_clip_h CROPS freqs & PADS volume & [grid]. freqs_alpha REPEATS FOR L & R CHANNELS. 
--CURVES OUTLINES USING SPLIT,ALPHAMERGE lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,split,alphamerge,lut=r=0:g=0:b=255*gt(val\\,90):a=255*gt(val\\,90)*(%s),format=rgb32[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,shuffleplanes=0:2:1:3[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,split[T],setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s[vid],[T]select=lt(n\\,2),trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB,crop=2:2[T],[T][vid]scale2ref,concat=unsafe=1,trim=start_frame=1')

