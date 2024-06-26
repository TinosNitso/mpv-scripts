----lavfi-complex SCRIPT WHICH OVERLAYS STEREO FREQUENCY SPECTRUM + VOLUME BARS (AUDIO VISUALS) ONTO MP4, AVI, 3GP, MP3 (RAW & albumart), MP2, M4A, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE. IT ALSO LOOPS albumart. 
----CAN USE DOUBLE-mute TO TOGGLE. ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY sine_mix CAN BE ADDED FOR CALIBRATION. COMPLEX MOVES & ROTATES WITH TIME.  
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS.  INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. EXAMPLE: automask.lua albumart ANIMATION.
----UNACCEPTABLE ON $20 USED SMARTPHONE, BUT FINE IN BLUESTACKS (DIFFERENT ANDROID BUILD).

options                 = {
    key_bindings        = 'Alt+C Alt+c F2',  --CASE SENSITIVE. DON'T WORK INSIDE SMPLAYER.  C=CROP (autocrop.lua) & CTRL+C=CLOCK (aspeed.lua). ALT+C AVAILABLE.
    double_mute_timeout =         0,  --SECONDS FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP).  0 IS INACTIVE.  REQUIRES AUDIO IN SMPLAYER.  INTERRUPTS PLAYBACK. DOESN'T TOGGLE af_chain!
    osd_on_toggle       =         0,  --MILLISECONDS.  SET TO 5000 TO INSPECT VERSIONS, FILTERGRAPHS, ETC.  0 IS INACTIVE.  1 CLEARS THE OSD.  -1 MEANS INFINITE.  DISPLAYS  _VERSION mpv-version ffmpeg-version libass-version platform current-vo media-title lavfi-complex af vf video-out-params.
    overlay_scale       = {  1,  1},  --RATIOS {WIDTH<=1,HEIGHT<=1}  CAN SHRINK PRIMARY_SCALE.  USES RECIPROCAL PADDING FOR SAFE zoompan.
    dual_scale          = {3/4,3/4},  --REMOVE FOR NO DUAL. RATIOS {WIDTH,HEIGHT} SHRINK DUAL.  3/4=(4/3)/(16/9) WHICH ALIGNS WITH ASPECT=4/3.  BI-QUAD CONCEPT COMES FROM HOW RAW MP3 WORKS (SELF-OVERLAY).  IN A SYMPHONY A LITTLE DUAL COULD FLOAT TO VARIOUS INSTRUMENTS, VIOLINS ETC.  THIS DUAL USES THE SAME aid.  MAYBE ALSO POSSIBLE TO ADD A 3RD LITTLE COMPLEX ON TOP, LIKE A CIRCULAR REMAP (THIRD-EYE). 
    vflip_only          =     false,  --true TO REMOVE TOP HALF. ALSO REMOVE vflip_scale_h FOR NULL OVERRIDE (NO overlay).
    vflip_scale_h       =        .5,  --REMOVE FOR NO BOTTOM HALF.  A DIFFERENT VERSION COULD SUPPORT BL & BR CHANNELS FOR BOTTOM.
    fps                 =       30 ,  --FRAMES PER SECOND FOR [vo].  30fps (+automask.lua) USES ~15% MORE CPU THAN 25fps. SCRIPT ALSO LIMITS scale. 
    period              =   '22/30',  --SECONDS.  USE fps RATIO.  20/30→90BPM (BEATS PER MINUTE). SET TO 0 FOR STATIONARY (~20% OFFSET DUE TO zoompan). UNLIKE A MASK, MOTION MAY NOT BE PERIODIC - COMPLEX FREE TO RANDOMLY FLOAT AROUND. IT ACTS LIKE A METRONOME.  (0 FORCES gsubs.r=0). 
    af_chain            = 'anull,dynaudnorm=g=3:p=1:m=1',  --AUDIO FILTERCHAIN FOR [ao]. CAN REPLACE anull WITH OTHER FILTERS, LIKE vibrato.  DYNAMIC AUDIO NORMALIZER BUFFERS OUTPUT, FIXING AN FFMPEG ERROR.  IT'S A NULL-OP & A DIFFERENT FILTER COULD ALSO WORK. THIS IS DETERMINISTIC FOR 10 HOURS.
    gsubs_passes        =        4 ,  --# OF SUCCESSIVE gsubs.  THEY DEPEND ON EACH OTHER, IN A DAIZY-CHAIN. LIKE (cos)→(c)→(r)→(fpp)  THEY DON'T APPLY TO filterchain.  THEY MAY HELP WITH MORE ADVANCED graph CHOREOGRAPHY.
    gsubs               = {r='((n)/(fpp))',c='cos(2*PI*(r))',s='sin(2*PI*(r))',m='mod(floor(r)\\,2)',cos='(c)',sin='(s)',mod='(m)',t,n,on,fpp,rand},  --SUBSTITUTIONS.  ENCLOSING BRACKETS () ARE ADDED & REQUIRED, IN EFFECT.  fpp=fps*period=FRAMES-PER-PERIOD IS DERIVED & DEPENDS ON FILTER.  EXAMPLE: USE n=5 FOR STATIONARY COMPLEX.  (t),(n),(on) = (TIME),(FRAME#),(FRAMEOUT#)  r=TIME/NUMBER-RATIO (t OR n AS RATIO).  (rand) IS A RANDOM # BTWN 0 & 1, UNIQUE @file-loaded.
    rotate              = 'a=PI/16*(s)*(m)',  --RADIANS CLOCKWISE.  0 FOR NO ROTATION.  (s),(m)=(sin),(mod)  MAY DEPEND ON TIME t & FRAME # n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle.  mod ACTS AS ON/OFF SWITCH. THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. 
    zoompan             = 'z=1+.2*(1-cos(2*PI*((r)-.2)))*mod(floor((r)-.2)\\,2)',  --USE 1 FOR NO ZOOMING.  (r)=RATIO=(on)/(fpp)  WHERE on=OUTPUT-FRAME-NUMBER.  BEFORE SCOOTING RIGHT, IT MAY rotate (20% OFFSET).  20% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS. 
    overlay             = 'x=(W-w)/2:y=H*(.75+.05*(1-(c))*(1-(m)))-h/2'         ,  --TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING. CONCEIVABLY A GAMEPAD COULD BE USED.  POSITIONING ATOP BLACK BARS MAY DRAW ATTENTION TO THEM (PPL COULD END UP STARING AT BLACK BARS).
    dual_overlay        = 'x=(W-w)/2:y=H*.50-h/2',  --CENTERED.  REPLACE .50 WITH .55 TO LOWER IT, OR WITH (rand) TO RANDOMIZE IT.  MAY DEPEND ON n & t - IT CAN FLY AROUND TOO.
    filterchain         = 'shuffleplanes=map0=1,lutrgb=g=val/4:a=val*.7',  --MIXES IN 25% GREEN-IN-BLUE RATIO, BECAUSE PURE BLUE IS TOO DARK. DROPS alpha BY 30%.  PLANES ORDERED LIKE GreatBRitAin (gbrap). COULD BE RENAMED overlay_vf_chain.  SHUFFLE + DILUTION MUCH MORE EFFICIENT THAN colorchannelmixer (+10% CPU).  BLUE, DARKBLUE & BLACK ARE COMPATIBLE WITH cropdetect (autocrop).  BLUE & WHITE STRIPES IS A DIFFERENT DESIGN, LIKE GREEK FLAG.  COLOR-BLINDNESS COULD BE AN ISSUE.
    dual_filterchain    =              'format=yuva420p,lutyuv=a=val/.7',  --APPLIES AFTER PRIMARY filterchain.  yuva420p MAY BE MORE OPTIMAL THAN RGB FORMATS (bgra gbrap) OR yuva444p.  USE 'null' FOR NULL-OP.
    -- filterchain      =   'shuffleplanes=1:0,lutrgb=g=val*.7:a=val*.7',  --UNCOMMENT FOR RED & DARKGREEN, INSTEAD OF RED & BLUE (DEFAULT). THIS EXAMPLE DROPS GREEN 30% BECAUSE IT'S TOO BRIGHT.
    -- dual_filterchain =            'shuffleplanes=1:0,lutrgb=a=val/.7',  --UNCOMMENT FOR RED &     GREEN DUAL.  EXAMPLE: TO SEESAW IT, APPEND ",rotate=a=PI/32*sin(PI*(arg)):c=BLACK@0"
    freqs_interpolation = false,  --true TO INTERPOLATE FROM freqs_fps→volume_fps.  ADDS ~7% CPU USAGE. HOWEVER CAN REDUCE fps FROM 30→25 TO SUBTRACT 15% CPU USAGE.   CAN REDUCE freqs_fps_albumart, TO INTERPOLATE FROM IT.  NICE LIGHTNING EFFECT BUT LOOKS JITTERY & FILM MAY STUTTER @autocrop.
    freqs_dynaudnorm    = 'g=5:p=1:m=100:b=1',  --DEFAULT=g=31:p=.95:m=10:b=0  THIS IS THE THIRD PASS. AFTER RESAMPLING TO 2.1kHz, & SHIFTING freqs_lead_time.  SPECTRUM SHOULD BE CLEAR EVEN FOR THE FAINTEST SOUNDS.
    freqs_opts          = 's=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2',  --EXTRA OPTIONS.  CAN ALSO SET overlap.  CAN'T CHANGE rate, fscale, colors & cmode (SEE graph SECTION).  INCREASE size FOR SHARPER CURVE (OR CHANGE ITS INTERNAL aspect).  mode={line,bar,dot}  win_func MAY ALSO BE poisson OR cauchy (PARZEN WAS AN AMERICAN STATISTICIAN).  win_size IS # OF DATA POINTS (LIKE TOO MANY PIANO KEYS).  FOR bar USE a=val*.25 IN filterchain.
    freqs_lead_time     =    .2,  --SECONDS.  +-LEAD TIME FOR SPECTRUM. SUBJECTIVE TRIAL & ERROR (.0 .1 .2 .3 .4 ?). BACKDATES audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG.  A CONDUCTOR'S BATON MAY MOVE AN EXTRA .1s BEFORE THE ORCHESTRA, OR IT'S LIKE HE'S TRYING TO KEEP UP.
    freqs_fps           =  25/2,  --FOR PERFECTLY SMOOTH FILM ON CHEAP CPU.  25fps MAY CAUSE FILM TO STUTTER (graph SUB-OPTIMAL). freqs_clip_h ALSO IMPROVES PERFORMANCE.  TRY averaging=3 FOR MORE fps.
    freqs_fps_albumart  =    25,  --FOR RAW MP3 ALSO. CAN EASILY DOUBLE freqs_fps.
    freqs_clip_h        =   .25,  --MINIMUM=grid_height (CAN'T CLIP LOWER THAN grid, DUE TO RECIPROCAL CANVAS PADDING).  REDUCES CPU USAGE BY CLIPPING CURVE - CROPS THE TOP OFF SHARP SIGNAL.
    freqs_scale_h       =   1.2,  --CURVE HEIGHT MAGNIFICATION.  REDUCES CPU CONSUMPTION (LESS DATA IN EFFECT). BUT THE LIPS LOSE TRACTION.  L & R CHANNELS FORM LIKE A DUAL MOUTH (LIKE HOW HUMANS ARE BIPEDAL).  freqs_alpha OPTION UNNECESSARY (EQUIVALENT TO A no_freqs OPTION).
    volume_af_chain     = 'highpass=f=250,dynaudnorm=g=5:p=1:m=100:b=1',  --ALSO APPLIES TO freqs (volume GOES FIRST IN THIS MODEL).  250Hz highpass CLARIFIES SPECTRUM.  firequalizer IS AN ALTERNATIVE.
    volume_opts         =     'f=0',  --DEFAULT=1 FOR FADE.  CAN ALSO ENTER EXTRA OPTIONS, LIKE dm & dmc FOR DISPLAY-MAX-LINES.  EXAMPLE: "dm=1:dmc=RED"
    volume_scale        = {.04,.15},  --RATIOS {WIDTH,HEIGHT} RELATIVE TO overlay_scale, BEFORE STACKING feet, & BEFORE autocrop.lua.
    volume_fps          =    25,  --PRIMARY ANIMATION fps. STREAM MAYBE 60fps BUT NOT THE EXTRA VISUALS.
    volume_alpha        =   .25,  --0 REMOVES BARS (feet REMAIN). OPAQUENESS OF volume BARS.  DUAL volume TAKES CENTER STAGE.
    grid_alpha          =     1,  --MULTIPLIER RELATIVE TO volume_alpha. 0 REMOVES grid & feet.
    grid_thickness      =   1/8,  --RATIO RELATIVE TO grid SPACING.  SLIGHTLY THICKER THAN CURVE.
    grid_height         =    .1,  --RATIO RELATIVE TO display, BEFORE STACKING feet.  grid TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS.
    feet_height         =   .05,  --RATIO>=.01 RELATIVE TO grid (BARS). 
    feet_activation     =    .5,  --RATIO RELATIVE TO volume, FROM THE BOTTOM.  feet BLINK ON/OFF WHEN volume PASSES THIS THRESHOLD.
    feet_lutrgb         = 'r=192:b=255:a=val/.25', --val*0 TO REMOVE.  COLOR OF CENTRAL feet.  RELATIVE TO volume_alpha.
    shoe_color          =              'BLACK@.5', --   @0 TO REMOVE.  A DIFFERENT VERSION COULD ALSO ADD o.grid_filterchain & o.grid_feet_lutrgb. (BLUE/RED OR RED/BLUE BARS?)  RED OUTER BARS SET OFF cropdetect.  
    sine_mix            = {}                     , --{{'f:b',volume},{f,volume},...,{'frequency(Hz):beep_factor',volume}}  b OPTIONAL (ONCE/SECOND).  sine WAVES FOR CALIBRATION MIX DIRECTLY INTO [ao].  BEEP ACTIVATES feet.  FUTURE VERSION SHOULD SUPPORT JPEG (CURRENTLY REQUIRES EXISTING AUDIO TO MIX WITH).
    -- sine_mix         = {{100,1},{'200:1',1.1},{300,1},{'400:1',1.1},{500,1},{'600:1',1.1},{700,1},{'800:1',1.1},{900,1},{'1000:1',1.1}},  --UNCOMMENT FOR 10 WAVES.  EVERY SECOND ONE BEEPS. THE 900Hz PEAK LINES UP, BUT THE SURROUNDING CURVE SKEWS ABOVE 900Hz.
    video_params        = {w,h,pixelformat},  --OVERRIDES.  DEFAULT pixelformat=yuva420p OR yuv420p, DEPENDING.  DEFAULT w,h = display-width,display-height OR width,height.  EMBEDDED MPV MAY HAVE display-width=nil.  EXAMPLE: {w=1680,h=1050}  
    options             = {
        'keepaspect      no','force-window yes','geometry 50%',  --no-keepaspect FOR ANDROID. FREE-SIZE IF MPV HAS ITS OWN WINDOW.  force-window PREVENTS MPV FROM VANISHING DURING TRACK CHANGES, & TOGGLING ON AUDIO, UNLESS ANDROID!  geometry APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.
        'vd-lavc-threads 0 ',  --VIDEO-DECODER-LIBRARY-AUDIO-VIDEO-threads OVERRIDES SMPLAYER OR ELSE MAY FAIL TESTING.  
        'osd-font-size   16',  --DEFAULT 55p MAY NOT FIT osd_on_toggle.  
    },
}
o,m,p,timers = options,{},{},{}           --TABLES.  m,p = MEMORY,PROPERTIES  timers={mute,seek} 
require 'mp.options'.read_options(o) --mp=MEDIA-PLAYER  ALL options WELL-DEFINED & COMPULSORY.

for   opt in ('double_mute_timeout vflip_scale_h freqs_clip_h gsubs_passes'):gmatch('[^ ]+') --gmatch=GLOBAL MATCH ITERATOR. '[^ ]+'='%g+' REPRESENTS LONGEST string EXCEPT SPACE.  %g (GLOBAL) PATTERN INVALID ON MPV.APP (SAME _VERSION, DIFFERENT BUILD).
do  o[opt] = type(o[opt])=='string' and loadstring('return '..o[opt])() or o[opt] end        --string→number: '1+1'→2  load INVALID ON MPV.APP. 
for _,opt in pairs(o.options)
do command = ('%s no-osd set %s;'):format(command or '',opt) end
command    = command and mp.command(command) --ALL SETS IN 1.
label      = mp.get_script_name()            --autocomplex

function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER, TO MULTIPLES OF 4.
    D = D or 1
    return N and math.floor(.5+N/D)*D  --FFMPEG SUPPORTS round, BUT NOT LUA.  math.round(N)=math.floor(.5+N)
end
math.randomseed(mp.get_time())

o.gsubs.r          = o.period..''=='0' and 0 or o.gsubs.r                                       --..'' CONVERTS→string.  OVERRIDE FOR NO TIME-DEPENDENCE PREVENTS DIVISION BY 0.  ONLY NEED APPLY TO (r).
for opt in ('rotate zoompan filterchain dual_filterchain overlay dual_overlay'):gmatch('[^ ]+') --options WHICH NEED gsubs.  filterchain OPTIONAL.
do          o[opt] = o[opt]..''
    for N          = 1,o.gsubs_passes do for key,gsub in pairs(o.gsubs)           --gsubs DEPEND ON EACH-OTHER.
        do  o[opt] = o[opt]    :gsub('%('..key..'%)', '('..gsub..')') end end end --() ARE MAGIC.  
for opt in ('rotate zoompan filterchain dual_filterchain'):gmatch('[^ ]+') 
do          o[opt] = o[opt]    :gsub('(fpp)',('(%s*%s)'  ):format(o.period,o.volume_fps)) end --ANIMATIONS ARE @volume_fps. OPTIMIZE USING DIFFERENT fps.  dual_filterchain IS LIKE rotate.  (fpp) SUBSTITUTION IS SPECIAL BECAUSE IT DEPENDS ON THE EXACT FILTER.
for opt in ('               overlay     dual_overlay    '):gmatch('[^ ]+')                    --OVERLAYS   ARE @STREAM fps.
do          o[opt] = o[opt]    :gsub('(fpp)',('(%s*%s)'  ):format(o.period,o.       fps)) end 
o.zoompan          = o.zoompan :gsub('%(n%)','(on)') --(n)→(on) FOR zoompan. SO (c),(s) gsubs ARE EFFECTIVE.
for N,sine in pairs(o.sine_mix)                      --EXTENDS o.af_chain INTO A SUBGRAPH, OR ELSE IT'S BLANK.  
do amix            = (',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],N,amix or ',[ao]',N) end --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).  "," SEPERATES THE SINES FROM THE MIX.
amix               = amix and ('[ao]%samix=%d:first')  :format(amix,#o.sine_mix+1) or ''                --MIXES [ao][a1][a2]...  SINE WAVES ARE INFINITE DURATION.  SINGLETON amix VALID, BUT I LEAVE IT OUT.
vflip              = o.vflip_scale_h and o.vflip_scale_h>0 
                     and    ('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'):format(o.vflip_scale_h,o.vflip_scale_h)  --scale & pad FOR BOTTOM. PADDING SIMPLIFIES CODE.
vstack             = not (not vflip and o.vflip_only) and o.filterchain..','..((  --PREPEND COLOR SHUFFLING, UNLESS NULL OVERRIDE.
                        not   vflip      and         'pad=0:ih*2:0:0:BLACK@0'     --TOP ONLY. pad*2 FOR ABSENT BOTTOM SIMPLIFIES CODE.
                        or  o.vflip_only and vflip..',pad=0:ih*2:0:oh-ih:BLACK@0' --BOTTOM ONLY, pad DOUBLE.  
                        or 'split[U],%s[D],[U][D]vstack'):format(vflip)           --BOTH  [U],[D] = UP,DOWN = TOP,BOTTOM  vstack IS TOP/BOTTOM.
                     )
o. volume_scale[2] =  o. volume_scale[2] or   o. volume_scale[1]  --BY DEFAULT SCALE_H=SCALE_W (scale[2]=scale[1])  volume_scale[2] overlay_scale[2] dual_scale[2]  MUST BE WELL-DEFINED.
o.overlay_scale[2] =  o.overlay_scale[2] or   o.overlay_scale[1] 
o.   dual_scale    =  o.   dual_scale    or  {}
o.   dual_scale[2] =  o.   dual_scale[1] and (o.   dual_scale[2] or o.   dual_scale[1])*o.freqs_clip_h*2  --CLIP HEIGHT FOR (PADDED) TOP & BOTTOM (*2). RATIO RELATIVE TO DISPLAY HEIGHT.
dual               = not o.dual_scale[1] and ''  --NO dual. OR ELSE dual BELOW.
                     or (',[ov]split[ov],%s[dual],[dual][vo]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[dual][vo],[vo][dual]overlay=%s[vo]'):format(o.dual_filterchain,o.dual_scale[1],o.dual_scale[2],o.dual_overlay)  --APPLY FILTERCHAIN FIRST BECAUSE [ov] IS ONLY 1200p, NOT 4K ACROSS LIKE [vo].


graph=('[aid%%d]%s%s,asplit[ao],stereotools,%s,apad,asplit[freqs],aformat=s16,showvolume=%s:0:128:8:t=0:v=0:o=v:%s,format=gbrap,shuffleplanes=1:0,lutrgb=g=0:a=val*(%s),split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:(ih-oh)*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],shuffleplanes=0:2:1[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih*(%s)/(%s):0:oh-ih:BLACK@0[grid],[freqs]aformat=s16:2100,asetpts=max(0\\,PTS-(%s)/TB),dynaudnorm=%s,aformat=s16,showfreqs=%s:colors=BLUE|RED:%%s,fps=%%s,crop=iw/1.05:ih*(%s)/(%s):0:ih-oh,format=gbrp,scale=iw*2:-1,avgblur=1:2^2+2^1,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2:2^2+2^1,lutrgb=r=255*gt(val\\,90):b=255*gt(val\\,90),framerate=%%s,format=gbrap,split[R],shuffleplanes=0:0:1:1,hflip[L],[R]shuffleplanes=0:0:2:2[R],[grid][L]scale2ref=iw*2-2:ih,overlay[grid+L],[grid+L][R]overlay=W-w,scale=ceil(iw/4)*4:ceil(ih/4)*4,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,shuffleplanes=0:2:1[LHI],[RHI]crop=iw/4:ih:iw-ow,shuffleplanes=0:2:1[RHI],[LHI][MIDDLE][RHI]hstack=3[ov],[vol][ov]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/(%s)/4)*4[vol][ov],[ov][vol]overlay=(W-w)/2:H-h,format=bgra,format=gbrap,%s[ov],%%sfps=%s,format=yuva420p,scale=%%d:%%d,format=yuva420p,split=3[vo][t0],crop=1:1:0:0:1:1,fps=%s,lutyuv=0:128:128:0[to]%s,[to][ov]scale2ref,overlay,setpts=PTS-STARTPTS,rotate=%s:c=BLACK@0,pad=iw/(%s):ih/(%s):(ow-iw)/2:(oh-ih)/2:BLACK@0,zoompan=%s:d=1:s=%%dx%%d:fps=%s[ov],[vo]setpts=PTS-STARTPTS[vo],[vo][ov]overlay=%s[vo],[t0]trim=end_frame=1[t0],[t0][vo]concat,trim=end=%%s:start_frame=1,fps=%s,setpts=PTS-1/FRAME_RATE/TB,format=%%s[vo]'
):format(o.af_chain,amix,o.volume_af_chain,o.volume_fps,o.volume_opts,o.volume_alpha,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.freqs_clip_h,o.grid_height,o.freqs_lead_time,o.freqs_dynaudnorm,o.freqs_opts,o.freqs_clip_h,o.freqs_scale_h,o.volume_scale[1],o.volume_scale[2],o.freqs_clip_h,vstack,o.fps,o.volume_fps,dual,o.rotate,o.overlay_scale[1],o.overlay_scale[2],o.zoompan,o.volume_fps,o.overlay,o.fps)  --volume_fps REPEATS FOR volume, TIME-STREAM [to] & zoompan.  fps REPEATS FOR [vo] & AFTER concat.  freqs_clip_h CROPS freqs & PADS volume & [grid].

----lavfi             LIBRARY-AUDIO-VIDEO-FILTERGRAPH:  [vid#]=VIDEO-IN [aid#]=AUDIO-IN [vo]=VIDEO-OUT [ao]=AUDIO-OUT [ov]=OVERLAY(SPECTRUM) [freqs]=AUDIO-FREQS [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [L]=LEFT [R]=RIGHT [vol]=VOLUME [grid]=VOL-BARS  ALSO [LGRID][RGRID][LHI][RHI].  SELECT FILTER NAME OR LABEL TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH LINEDUPLICATE ETC. lavfi-complex MAY COMBINE MANY [aid#] & [vid#] INPUTS. %% SUBS OCCUR LATER. (%s) BRACKETS FOR MATH.  A lavfi string IS LIKE DNA & CAN CREATE VARIOUS CREATURES. SEE FFMPEG-FILTERS MANUAL. A BRICK OF EQUATIONS DEFINE STRING INSERTS.  EACH FOOT HAS A STEREO INSIDE IT. [feet0] (SHOES) ARE THE CENTER-PIECE.  [to] & [t0] CODES ALWAYS VALID, EVEN ON YOUTUBE & FOR MP4 SUBCLIPS WITH OFF TIMESTAMPS. IMPOSSIBLE TO ALWAYS CORRECTLY ENTER NUMBERS LIKE time-pos OR audio-pts. CANVAS [to] SWITCHES OUT [ao]→[vo] TIMESTAMPS (IT'S ACTUALLY [time-vo]).
----showvolume      = r:b:w:h:f:...:t:v:o:...:dm:dmc                                       DEFAULT=25:1:400:20:0.95:...:t=1:v=1:o=h:...:dm=0:dmc=orange  →rgba  rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION:...:DISPLAYMAX:DISPLAYMAXCOLOR  LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED.  THERE'S SOME TINY BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----showfreqs       = size:rate:mode:ascale:fscale:win_size:win_func:...:averaging:colors  DEFAULT=1024x512:25:bar:log:lin:2048:hanning:...:1            →rgba  rate INCOMPATIBLE WITH FFMPEG-v4. size SHOULD HAVE ASPECT APPROX 3x5 FOR HEALTHY CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (300x300 & 300x700 ARE OFF).  win_size BTWN 256 & 2048.  cmode=separate WOULD REQUIRE TWICE AS MANY PIXELS.
----sine            = f:b                       DEFAULT=440:0=frequency:beep_factor (Hz,BOOL)  →s16  beep IS EVERY SECOND.  FOR sine_mix CALIBRATION.
----volume          = volume                    DEFAULT=1  RATIO. sine VOLUMES. FORMS TRIPLE WITH sine & amix.
----amix            = inputs:duration           DEFAULT=2:longest  MIXES IN SINES. [a1][a2]...→[ao]
----hstack,vstack   = inputs                    DEFAULT=2    COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES feet.  vstack FOR FEET & TOP/BOTTOM.
----split,asplit    = outputs                   DEFAULT=2    CLONE STREAMS.
----highpass        = f              (→floatp)  DEFAULT=3000 Hz  MAY BE BLANK.  firequalizer IS MORE GENERAL & COULD MULTIPLY BY FREQUENCY. A CHIRP MAY BECOME DEAFENING @DOUBLE FREQUENCY.
----setpts,asetpts  = expr                      DEFAULT=PTS  PRESENTATION TIMESTAMP, FOR SYNC OF rotate,zoompan,overlay WITH OTHER GRAPHS (automask), BY SENDING STARTPTS→0. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO.
----shuffleplanes   = map0:map1:map2:map3       DEFAULT=0:1:2:3  REDUCES CPU USAGE BY >5% COMPARED TO colorchannelmixer. ORDERED g:b:r:a (LIKE GreatBRitAin, WITH RED ON RIGHT). SHUFFLES WITHOUT MIXING.  FFMPEG-v4 COMPATIBILITY DEPENDS ON EXACT USAGE.  SWITCHES [vol] GREEN & BLUE, [feet] FROM [feet0], & COLORS HIGHS VS LOWS, & [L][R] CHANNELS.
----fps             = fps:start_time (SECONDS)  DEFAULT=25  LIMITS STREAM @file-loaded. ALSO FOR OLD MPV showfreqs. start_time FOR JPEG(TOGGLE OFF).  ALSO ENSURES FRAME_RATE IS WELL-DEFINED.
----framerate       = fps                       DEFAULT=50  alpha CAUSES BUG (gbrp NOT gbrap). NEGATIVE TIME ALSO CAUSES BUG. DOUBLING freqs_fps ADDS 10% CPU USAGE. 
----rotate          = a:ow:oh:c  (RADIANS:p:p)  DEFAULT=0:iw:ih:BLACK  ROTATES CLOCKWISE. MAY DEPEND ON n & t.
----zoompan         = z:x:y:d:s:fps     (z>=1)  DEFAULT=1:0:0:...:hd720:25  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN.  z:x:y MAY DEPEND ON  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING. SAFE AS NULL-OP.
----crop            = w:h:x:y:keep_aspect:exact DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES LOWS FROM [LHI] & [RHI]. CROPS 5% OFF DATA. FFMPEG-v4 REQUIRES ow INSTEAD OF oh (DEPENDING).
----pad,apad        = w:h:x:y:color,...         DEFAULT=0:0:0:0:BLACK  BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih. pad OUT BEFORE zoompan IN!  apad APPENDS SILENCE OR VISUALS HANG NEAR @end-file. AN ALTERNATIVE IS TO EXPAND TIMESTAMPS NEAR end-file, SET --end OR TRIM SHORT.  TESTED MPV-v0.38 ON 10 HOURS albumart+automask.lua.
----scale,scale2ref = w:h                       DEFAULT=iw:ih SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.  TOREFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume.  dst_format & flags=bilinear CAN ALSO BE SET.  
----overlay         = x:y          (→yuva420p)  DEFAULT=0:0   OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON t & n.  UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4. AN EVEN HALF PLANE WIDTH (MULTIPLE OF 4) MAY HAVE BEEN SIMPLER FOR FFMPEG TO OPTIMIZE.  
----lutyuv,lutrgb   = y:u:v:a,r:g:b:a           DEFAULT=val   LOOK-UP-TABLE-BRIGHTNESS-UV,RED-GREEN-BLUE  lutyuv CONVERTS gbrap→yuva444p. lutrgb CONVERTS yuva420p→argb. lutyuv IS MORE EFFICIENT THAN lutrgb DUE TO FORCED FORMATTING.  lut HAS A BUG WHERE MAYBE r=green BECAUSE IT ASSUMES r IS PLANE 0 FOR gbrap.  lutyuv CREATES TRANSPARENCY & CANVAS. lutrgb SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.  SERATED-RAZOR-CURVE IS ANOTHER IDEA.
----avgblur         = sizeX:planes AVERAGE BLUR DEFAULT=1:15  (INTEGER:<16)  sizeY=sizeX (PIXELS)  FOR gbrap planes=8(GREEN)+4(BLUE)+2(RED)+1(ALPHA)=2^3+2^2+2^1+2^0.  CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTHER CURVE.
----dynaudnorm      = ...:g:p:m:...:b           DEFAULT=...:31:.95:10:...:0  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:...:BOUNDARY_MODE{0,1}  IS THE START.  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  MAY BE BLANK.  b=NO_FADE (FADE NOT FOR SPECTRUM). IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g MAY GIVE FASTER RESPONSE. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. 
----trim            = ...:end:...:start_frame:end_frame  DEFAULT start_frame=0  TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP, & ENDS THE COMPLEX. IT'S THE MOST ACCURATE WAY TO end albumart (ASIDE FROM --end).
----loop            = loop:size  ( >=-1 : >0 )  LOOPS BOTH albumart & image (SEE TOGGLE).
----format,aformat  = pix_fmts,sample_fmts:sample_rates  {yuva420p,yuv420p,bgra,gbrp=rgb24,gbrap},s16:Hz  IS THE FINISH ON [vo] (TO REMOVE alpha). MAY BE BLANK.  gbrap (GreatBRitAin Planar) ASSUMED BY shuffleplanes & avgblur. REQUIRED IN FFMPEG-v4.2.  HOWEVER bgra (RGB BACKWARDS) ALSO REQUIRED FOR EFFICIENT SCALING FROM COLORED HALF-PLANES (SOLVES ERRORS). SO IT'S USED IN BTWN gbrap & yuva420p (FORCED BY overlay).  aformat REMOVES doublep PRECISION AFTER dynaudnorm, & DOWNSAMPLES TO 2.1kHz (NYQUIST+5%). 
----hflip,vflip       HORIZONTAL,VERTICAL  hflip FOR [L] LEFT.  vflip FOR BOTTOM [D] (DOWN).
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo.  ALTERNATIVE TO aformat.  softclip INCOMPATIBLE WITH FFMPEG-v4.
----setsar            SAMPLE ASPECT RATIO  IS WHAT MPV CALLS par, NOT sar.  FOR albumart SAFE concat OF [t0].  ZEROES OUT ITS SAR, FOR SAR CONGRUENCE. 
----concat            [t0][vo]→[vo]  FINISHES [t0].  CONCATENATE STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. NEEDED TO SYNC WITH automask.
----nullsrc,nullsink  WARNS OTHER SCRIPTS JPEG MAY loop @path_handler.  nullsink ALSO FOR ERROR DETECTION.


function file_loaded()  --ALSO @on_toggle & @timers.seek.
    p.start            = p.start and mp.set_property('start','none') and nil  --start DUE TO INSTA-stop @property_handler.  PERSISTS OTHERWISE.  ALTERNATIVELY CAN seek.  ANDROID STAYS OFF.
    for  property in ('current-tracks/audio/id display-width display-height width height duration platform video-params/alpha current-vo current-tracks/video'):gmatch('[^ ]+')  --nil NUMBERS STRINGS table
    do p[property]     = mp.get_property_native(property) end                                --FASTER THAN AWAITING OBSERVATION.
    a_id,v             = p['current-tracks/audio/id'],p['current-tracks/video'] or {}        --aid IS A SETTING FOR a_id.
    alpha              = p['video-params/alpha']     or v.image                 or  not v.id --MPV REQUIRES EXTRA ~.1s TO DETECT alpha, SO GUESS FOR image & ~v.id.
    W                  = o.video_params.w            or p['display-width' ]     or  p.width   or  v['demux-w']        or 1280      --OVERRIDE  OR  display  OR  PARAMETERS  OR  TRACK  OR  (FALLBACK FOR RAW MP3 IN VIRTUALBOX).  width=nil SOMETIMES @file-loaded.  FUTURE VERSION SHOULD USE W=osd-width IF FULLSCREEN & display-width=nil & osd-width>width, FOR ANDROID.
    H                  = o.video_params.h            or p['display-height']     or  p.height  or  v['demux-h']        or 720
    format             = o.video_params.pixelformat  or p['current-vo']=='shm'  and 'yuv420p' or alpha and 'yuva420p' or 'yuv420p' --OVERRIDE  OR  SHARED-MEMORY  OR  TRANSPARENT  OR  NORMAL.  FORCING yuv420p OR yuva420p IS MORE RELIABLE, ESPECIALLLY ON SMPLAYER.APP. MPV.APP COMPATIBLE WITH TRANSPARENCY.  overlay FORCES yuva420p, BUT alpha ON FILM TRIGGERS BUG/S IN OTHER SCRIPT/S.  lavfi-complex CAN'T DETECT WHETHER alpha EVER EXISTED WITHOUT A DELAYED TRIGGER, BUT THE .1s DELAY CAN CAUSE STUTTER/LAG.
    OFF                =     OFF or not a_id         or not vstack --FORCE OFF.
    osd_on_toggle      = not OFF and o.osd_on_toggle or 0          --ONLY IF ~ARTIFICIAL TOGGLE.
    if OFF then OFF    = nil  --FORCE TOGGLE OFF, IF OFF (WITHOUT osd).  ALSO COVERS OFF CASES. EXAMPLE: JPEG=OFF-albumart.  SOMETIMES A file-loaded CAN BE JUST A TOGGLE OFF.
         on_toggle()                                        
         osd_on_toggle = o.osd_on_toggle --RETURN PROPER VALUE.
         return end                      --ON BELOW.
    
    ov_w,ov_h,p.duration = round(W,4),round(H*o.freqs_clip_h*2,4),round(p.duration,.001) --PRIMARY OVERLAY SCALE (w & h). vstack*2 FACTOR (ALSO VALID IF TOP-ONLY).  duration NEAREST MILLISECOND.
    freqs_fps          = (v.image or not v.id) and o.freqs_fps_albumart or o.freqs_fps   --freqs_fps MAY VARY on_vid. SOME ANIMATIONS (LIKE FRACTALS) CAN BE DONE SMOOTHER ON albumart.
    framerate          = o.freqs_interpolation and o.volume_fps         or   freqs_fps   --INTERPOLATION: freqs_fps→volume_fps
    error_showfreqs    =     error_showfreqs   or  not freqs_rate and not mp.command(('no-osd af pre @%s:lavfi=[asplit[ao],showfreqs=rate=%s,nullsink]'):format(label,freqs_fps)) --~freqs_rate MEANS ONCE ONLY. command RETURNS true IF SUCCESSFUL.  ERROR ON FFMPEG-v4 (.AppImage)  FFMPEG-v4 OPERATES showfreqs @25fps (.AppImage & .snap). NEWER VERSIONS SUPPORT ANY fps.  NEW MPV MAY USE OLD FFMPEG COMPONENTS.  BUT ERROR MORE RELIABLE THAN VERSION NUMBERS BECAUSE THEY CAN BE ANYTHING.  THIS LINE ASSUMES AUDIO EXISTS, WHICH IS AN ISSUE FOR CASE 4.
    remove_filter      = not error_showfreqs   and not freqs_rate and     mp.command( 'no-osd af remove @'..label)                                                                --IF ABLE TO.
    freqs_rate         =     error_showfreqs   and '' or 'rate='..freqs_fps
    underlay           =   --3 ON CASES:  1) VIDEO  2) albumart  3) AUDIO-ONLY  albumart
                         v.id and not v.image  and ('[vid%d]'):format(v.id)  --CASE 1: NORMAL VIDEO.  USUALLY [vid1].
                         or           v.image  and ('[vid%d]scale=%d:%d,format=yuva420p,loop=-1:1[vo],[ov]split[ov],trim=end_frame=1,crop=1:1:0:0:1:1,format=yuva420p,scale=%d:%d,setsar[t0],[t0][vo]concat,trim=start_frame=1,'):format(v.id,W,H,W,H)  --CASE 2 (albumart) IS THE MOST COMPLICATED. albumart IS LOOPED, WITH ATOMIC TIMESTAMP FRAME [t0] PREPENDED & TRIMMED, TO SUPPORT PROPER seeking.  ALTERNATIVE IS TO INSERT time-pos @seek BUT THAT CAUSED SOME LAG.
                         or                         '[ov]split[ov],crop=1:1:0:0:1:1,lutyuv=0:128:128:0,'  --CASE 3  (RAW AUDIO)  underlay USES [ov] (SPECTRUM) INSTEAD OF [vid#], TO BUILD BLANK 1x1 WHO IS SCALED AS THOUGH IT'S A FILM.
                         or                         ''  --CASE 4 IS MISSING: ~a_id + o.sine_mix  IT NEEDS TOGGLE TOO, FOR sine_mix ON JPEG.  A VIDEO CAN HAVE AUDIO ADDED TO IT, LIKE AUDIO CAN HAVE VIDEO ADDED TO IT.
    m.graph            = graph: format(a_id,freqs_rate,freqs_fps,framerate,underlay,W,H,ov_w,ov_h,p.duration,format):gsub('%(rand%)',math.random())  --FUTURE VERSION CAN RE-RANDOMIZE @seek. 
    mp.set_property('lavfi-complex',m.graph)  --FOR graph BYTECODE.  
end 
mp.register_event('file-loaded',file_loaded)  
mp.register_event( 'start-file',     function() mp.set_property('lavfi-complex','nullsrc,nullsink') end)  --UNLOCK STREAMS. ALSO WARNS OTHER SCRIPTS THERE WILL BE A lavfi-complex.  PRIOR lavfi-complex MAY HANG IF [vid2] SUDDENLY DOESN'T EXIST.
mp.register_event(   'end-file',     function() W       = nil end)  --INSTA-BLOCK FUNCTIONS.
mp.register_event(       'seek',     function() on_seek = mp.get_property_number('time-remaining')==0 and mp.command('playlist-next force') or timers.seek:resume() end)  --SKIP-10 BUGFIX FOR seek PASSED end-file.  playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST.  A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES, PASSED end-file.
timers.seek=mp.add_periodic_timer(.5,function() reload  = start_time and math.abs(start_time-mp.get_property_number('time-pos'))>1 and file_loaded() end)  --FOR JPEG seeking.  TAKES <HALF A SECOND FOR ACCURATE time-pos.  IF STARTPTS CHANGES MORE THAN 1s IT SHOULD BE RESET (FOR OTHER SCRIPT/S).  A FUTURE VERSION COULD USE AUDIO TIME-STREAM INSTEAD.

function on_toggle()  --@key_binding, @property_handler & @file-loaded.  REMOVES THE SPECTRUM FROM THE lavfi-complex, OR ELSE RELOADS.  DOESN'T UNLOCK aid & vid.
    if not W then return end
    OFF          = not OFF  --OFF SWITCH.  
    start_time   =     OFF    and v.image     and round(mp.get_property_number('time-pos'),.001)
    toggle       =     OFF    and mp.set_property('lavfi-complex',             ''  --OFF
                   ..(a_id    and ('[aid%d]%s[ao]'):format(a_id,o.af_chain) or '') --PREPEND AUDIO.
                   ..(a_id    and v.id        and ','                       or '') --PREVENTS TRAILS  ',' & ';'  WHICH BUG OUT ON FFMPEG-v5.
                   ..(nil     
                      or v.id and not v.image and ('[vid%d]fps=%s,scale=%d:%d,format=%s[vo]'             ):format(v.id,o.fps,W,H,format)            --CASE 1: TOGGLE OFF MP4.  fps OPTIONAL, BUT scale & format PREVENT EMBEDDED MPV SNAPPING. 
                      or              v.image and ('[vid%d]scale=%d:%d,format=%s,loop=-1:1,fps=%s:%s[vo]'):format(v.id,      W,H,format,o.fps,start_time) --CASE 2: image. MORE GENERAL THAN albumart.  CAN USE ~25% CPU @FULLSCREEN.  NEED start_time FOR --start.  FFMPEG-v5 TAKES A STILL FRAME (DIFFERENT, BUT VALID).  UNFORTUNATELY SNAPS EMBEDDED MPV.
                      or                           '' --CASE 3 IS NOTHING BUT AUDIO. RAW audio STATIC SPECTRUM.  CAN CHECK MPV LOG FOR OUTPUT IN EACH CASE. 
                   )) or file_loaded() --OR ON
    OFF          = a_id and OFF        --FORGET OFF STATE IF RAW VIDEO (NO AUDIO).  OTHERWISE TRACK-2 IS OFF TOO.
    show_text    = osd_on_toggle~=0 and mp.command(('show-text       "'
                       ..'_VERSION       = %s                       \n'  --Lua 5.1  5.2
                       ..'mpv-version    = ${mpv-version}           \n'  --mpv 0.38.0  →  0.34.0
                       ..'ffmpeg-version = ${ffmpeg-version}        \n'
                       ..'libass-version = ${libass-version}        \n'
                       ..'platform       = ${platform}              \n'  --windows  linux  darwin  android  nil(v0.34.0)
                       ..'current-vo     = ${current-vo}            \n'  --gpu  gpu-next  direct3d  libmpv  shm
                       ..'media-title    = ${media-title}         \n\n' 
                       ..'lavfi-complex  = \n${lavfi-complex}     \n\n'
                       ..'Audio filters:   \n${af}                \n\n'
                       ..'Video filters:   \n${vf}                \n\n'
                       ..'video-out-params = \n${video-out-params}" %d'  --pixelformat...
                   ):format(_VERSION,osd_on_toggle))
end
for key in o.key_bindings: gmatch('[^ ]+') do mp.add_key_binding(key,'toggle_complex_'..key,on_toggle) end  --MAYBE COULD BE 'toggle_spectrum_'.

function property_handler(property,val)   
    if not W then return end  --PROCEED IF LOADED.
    double_mute =     property=='mute' and (not timers.mute:is_enabled()    and (timers.mute:resume()   or 1) or on_toggle())  --NOT FOR ANDROID.  SMPLAYER DOUBLE-MUTE WHILE seeking MAY FAIL (CANCELS ITSELF OUT).
    val         = not val and (  --val IMPLIES 1←→2 SWITCH UNNECESSARY. ~val IS A CONTRADICTION.  ONLY GOOD FOR SWITCHING BTWN 1 & 2 (BOTH aid & vid). 
                      property=='aid'  and a_id and ((p.platform=='android' and 'no') or (a_id==1 and 2 or 1)) --~a_id FOR JPEG.  PERMANENTLY DEACTIVATE FOR android MUTE (aid=no). HAPPENS TO WORK.
                  or  property=='vid'  and v.id and                                      (v.id==1 and 2 or 1)
                  )
    if not val then return end  --TRACK CHANGE BELOW.
    p.start     = mp.get_property('time-pos')
    
    mp.command((''  --UNLOCKS complex & INSTA-STOPS.  UNFORTUNATELY SNAPS EMBEDDED MPV (DIMENSIONS CHANGE). AN ANTI-SNAP GRAPH IS MORE CODE.
                ..'no-osd set lavfi-complex nullsrc,nullsink;'  --UNLOCK STREAMS.
                ..'no-osd set start                       %s;'  --UNLOCK STREAMS.
                ..'no-osd set %s                          %s;'  --set vid
                ..'       stop                 keep-playlist;'  --INSTA-stop.  ALTERNATIVES "video-reload" "rescan-external-files keep-selection" DON'T WORK IN THIS CASE. 
                ..'       playlist-play-index        current;'
    ):format(p.start,property,val))
end 
for property in ('mute aid vid'):gmatch('[^ ]+')  --nil boolean NUMBERS
do mp.observe_property(property,'native',property_handler) end

timers.mute=mp.add_periodic_timer(o.double_mute_timeout,function()end) 
for _,timer in pairs(timers)
do  timer.oneshot = 1  --ALL 1SHOT.
    timer:kill() end


----5 KINDS OF COMMENTS: THE TOP (INTRO), LINE EXPLANATIONS (& 3 CASES), LINE TOGGLES (options), MIDDLE (graph SPECS), & END. ALSO BLURBS ON WEB. CAPSLOCK MOSTLY FOR COMMENTARY & TEXTUAL CONTRAST.
----MPV  v0.38.0(.7z .exe v3 .apk)  v0.37.0(.app)  v0.36.0(.app .flatpak .snap)  v0.35.1(.AppImage)  v0.34.0(win32)  ALL TESTED. 
----FFMPEG  v6.1(.deb)  v6.0(.7z .exe .flatpak)  v5.1.4(mpv.app)  v5.1.2(SMPlayer.app)  v4.4.2(.snap)  v4.2.7(.AppImage)  ALL TESTED.  MPV-v0.36.0 IS BUILT WITH FFMPEG-v4, v5 & v6, SO ALL GRAPHS COVER 3 VERSIONS.
----PLATFORMS  windows linux darwin(Lua 5.1) android(Lua 5.2) ALL TESTED.  WIN-10 MACOS-11 LINUX-DEBIAN-MATE ANDROID-7-x86. 
----SMPLAYER-v24.5, RELEASES .7z .exe .dmg .AppImage .flatpak .snap win32  &  .deb-v23.12  ALL TESTED.

----BUG:   SOME YT VIDEOS GLITCH @START (PAUSING). EXAMPLE: https://YOUTU.BE/D22CenDEs40
----ISSUE: graph NEEDS TO BE OPTIMIZED SOMEHOW.
----SCRIPT WRITTEN TO TRIGGER A FFMPEG ERROR ON OLD FFMPEG (v4 & OLDER). MORE RELIABLE THAN VERSION NUMBERS. 
----A DIFFERENT DESIGN COULD COMPRESS 1→10kHz INTO AN ELEVENTH TICKMARK.  ALSO, AN UGLY INSTA-TOGGLE COULD WORK BY DUPLICATING THE VIDEO & THEN COMMANDING A CROPPER WHICH TAKES OUT THE TOP OR BOTTOM.

----ALTERNATIVE FILTERS:
----afftfilt          = real:imag:win_size:win_func:overlap  DEFAULT=1|1:1|1:4096:hann:0.75  (AUDIO FAST FOURIER TRANSFORM FILTER) overlap<1 CAUSES BUG. MAY HELP WITH o.volume_af_chain.
----select            = expr   EXPRESSION DISCARDS IF 0.     DEFAULT=1  MAY HELP WITH OLD MPV (PREVENTED MEMORY LEAK WHEN TRIMMING FOR [t0]).
----loudnorm          = I:LRA:TP  [-70,-5]:[1,20]:[-9,0]     DEFAULT=-24:7:-2  INTENSITY_TARGET:LOUDNESS_RANGE:TRUE_PEAK  CAUSED DEFECT REQUIRING apad. LACKS f & g SETTINGS. SOUNDED OFF.  OUTPUTS A BUFFERED STREAM.
----asettb            = tb    OPTIONAL TIMEBASE SPEC. MAY PROVIDE fps HINT TO FURTHER FILTERS.
----extractplanes     = planes    r+b→[R][L] (RED+BLUE)   REVERSED IF [L] GETS FLIPPED AROUND.  MAYBE MORE OPTIMAL.
----colorchannelmixer = rr:...:aa   (RANGE -2→2, r g b a PAIRS)  DEFAULT rr=1,rg=0,ETC.  INEFFICIENT LIKE geq SO AVOID.
----geq                 GENERIC EQUATION  IS TOO SLOW @25fps EXCEPT ON A SINGLE GRID ELEMENT OR LINE. MAY BE POSSIBLE TO USE IT TO REMAP ONTO CIRCLE OR SMILY/FROWNY FACE.
----firequalizer        MAY BE NEEDED TO MULTIPLY BY frequency.
----acompressor         DEFAULT SMPLAYER NORMALIZER. SOUNDED OFF.
----aresample           (Hz) DOWNSAMPLES TO 2.1kHz (NYQUIST+5%). AN ALTERNATIVE IS aformat.
----alphamerge          [y][a]→[ya]  USES lum OF [a] AS alpha OF [ya]. CAN PAIR WITH split TO CONVERT BLACK TO TRANSPARENCY. ALTERNATIVES INCLUDE colorkey, colorchannelmixer & shuffleplanes.

----ALTERNATIVE GRAPH EXAMPLE CODES:
----EXTRACTPLANES LR MONOCHROME (FASTER?):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,2010,o.freqs_lead_t,o.volume_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_scale_h,2,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,vstack,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 

----ov_w ESTIMATE = 300*2*2/1.05                           --*2 FOR INTERNAL SCALE, *2 FOR [L] & [R], /1.05 FOR NYQUIST.  zoompan REQUIRES RAW NUMBERS.  s=300x500 FROM showfreqs.
----ov_h ESTIMATE = 500*2*2/o.freqs_scale_h*o.freqs_clip_h --*2 FOR INTERNAL SCALE, *2 FOR vstack.  (/1.2*.25)
    
    