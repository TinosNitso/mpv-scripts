----lavfi-complex SCRIPT WHICH OVERLAYS STEREO FREQUENCY SPECTRUM + VOLUME BARS (AUDIO VISUALS) ONTO MP4, AVI, 3GP, MP3 (RAW & albumart), MP2, M4A, WAV, OGG, AC3, OPUS, WEBM & YOUTUBE. IT ALSO LOOPS albumart. 
----CAN USE DOUBLE-mute TO TOGGLE. ACCURATE 100Hz GRID (LEFT 1kHz TO RIGHT 1kHz). ARBITRARY sine_mix CAN BE ADDED FOR CALIBRATION. COMPLEX MOVES & ROTATES WITH TIME.  
----SCRIPT IMPOSSIBLE TO READ/EDIT WITH WORD WRAP, WHICH MAY BE A PROBLEM ON MACOS. 

options={  --ALL OPTIONAL & MAY BE REMOVED.  UNCOMMENT LINES TO ACTIVATE THEM.  TO REMOVE AN INTERNAL COMPONENT SET ITS alpha TO 0 (volume grid feet shoe).  A table OF EQUATIONS CAN BE HOLLOWED OUT TO FORM A BRICK.
    key_bindings       = 'ALT+C ALT+c',  --CASE SENSITIVE. DOESN'T WORK INSIDE SMPLAYER.  C=CROP (autocrop.lua) & CTRL+C=CLOCK (aspeed.lua). ALT+C AVAILABLE.
    -- toggle_on_double_mute =  .5,  --SECONDS TIMEOUT FOR DOUBLE-MUTE TOGGLE (m&m DOUBLE-TAP). REQUIRES AUDIO IN SMPLAYER.  INTERRUPTS PLAYBACK. DOESN'T TOGGLE dynaudnorm!
    overlay_scale      = {  1,  1},  --DEFAULT={1,1}  RATIOS {WIDTH<=1,HEIGHT<=1}  CAN SHRINK PRIMARY_SCALE.  USES RECIPROCAL PADDING FOR SAFE zoompan.
    dual_scale         = {3/4,3/4},  --REMOVE FOR NO DUAL. RATIOS {WIDTH,HEIGHT} SHRINK DUAL.  3/4=(4/3)/(16/9) WHICH ALIGNS WITH ASPECT=4/3.  BI-QUAD CONCEPT COMES FROM HOW RAW MP3 WORKS (SELF-OVERLAY).  IN A SYMPHONY A LITTLE DUAL COULD FLOAT TO VARIOUS INSTRUMENTS, VIOLINS ETC.  THIS DUAL USES THE SAME aid.  MAYBE ALSO POSSIBLE TO ADD A 3RD LITTLE COMPLEX ON TOP, LIKE A CIRCULAR REMAP (THIRD-EYE). 
    -- vflip_only      =      true,  --UNCOMMENT TO REMOVE TOP HALF. ALSO REMOVE vflip_scale_h FOR NULL OVERRIDE (NO overlay).
    vflip_scale_h      =        .5,  --REMOVE FOR NO BOTTOM HALF.  A DIFFERENT VERSION COULD SUPPORT BL & BR CHANNELS FOR BOTTOM.
    fps                =        30,  --DEFAULT=30  FRAMES PER SECOND FOR [vo].  30fps (+automask.lua) USES ~15% MORE CPU THAN 25fps. SCRIPT ALSO LIMITS scale. 
    period             =   '22/30',  --DEFAULT= 1 SECOND. USE fps RATIO. 20/30→90BPM (BEATS PER MINUTE). SET TO 0 FOR STATIONARY (~20% OFFSET DUE TO zoompan). UNLIKE A MASK, MOTION MAY NOT BE PERIODIC - COMPLEX FREE TO RANDOMLY FLOAT AROUND. IT ACTS LIKE A METRONOME.  (IF 0, "n/%s"→"0" GSUBS OCCUR, ETC). 
    af_chain           = 'anull,dynaudnorm=g=3:p=1:m=1',  --DEFAULT='anull'  AUDIO FILTERCHAIN FOR [ao]. CAN REPLACE anull WITH OTHER FILTERS, LIKE vibrato.  DYNAMIC AUDIO NORMALIZER BUFFERS OUTPUT, SOLVING AN FFMPEG ERROR.  A DIFFERENT FILTER COULD ALSO WORK. THIS IS DETERMINISTIC FOR 10 HOURS.
    rotate             =                    'a=PI/16*sin(2*PI*n/%s)*mod(floor(n/%s)\\,2)',        --%s=(period*volume_fps)  DEFAULT=0 RADIANS CLOCKWISE. MAY DEPEND ON TIME t & FRAME # n. PI/16=.2RADS=11°   MAY CLIP @LARGE angle. mod ACTS AS ON/OFF SWITCH. THIS EXAMPLE MOVES DOWN→UP→RIGHT→LEFT BY MODDING. 
    zoompan            =           'z=1+.2*(1-cos(2*PI*(on/%s-.2)))*mod(floor(on/%s-.2)\\,2)',    --%s=(period*volume_fps)  DEFAULT=1  on=OUTPUT FRAME NUMBER (OUTPUT MUST SYNC).  BEFORE SCOOTING RIGHT, IT MAY rotate (20% OFFSET).  20% zoom GETS MAGNIFIED BY autocrop, DEPENDING ON BLACK BARS. 
    overlay            = 'x=(W-w)/2:y=H*(.75+.05*(1-cos(2*PI*n/%s))*mod(floor(n/%s)+1\\,2))-h/2', --%s=(period*       fps)  DEFAULT=(W-w)/2:(H-h)/2  TIME-DEPENDENCE SHOULD MATCH OTHER SCRIPT/S, LIKE automask. A BIG-SCREEN TV HELPS WITH POSITIONING. CONCEIVABLY A GAMEPAD COULD BE USED.  POSITIONING ON TOP OF BLACK BARS MAY DRAW ATTENTION TO THEM (PPL COULD END UP SPENDING HRS STARING AT THE BLACK BARS ABOVE OR BELOW VIDEO).
    dual_overlay       = 'x=(W-w)/2:y=H*.5-h/2',  --DEFAULT='(W-w)/2:(H-h)/2' (CENTERED).  MAY DEPEND ON n & t (IT CAN FLY AROUND), BUT CLEARER IF STATIONARY. %s=(period*fps)  H*.55 FOR BELOW CENTER.
    filterchain        = 'shuffleplanes=map0=1,lutrgb=g=val/4:a=val*.7',  --DEFAULT='null'  MIXES IN 25% GREEN-IN-BLUE RATIO, BECAUSE PURE BLUE IS TOO DARK. DROPS alpha BY 30%.  PLANES ORDERED LIKE GreatBRitAin (gbrap). COULD BE RENAMED overlay_vf_chain.  SHUFFLE + DILUTION MUCH MORE EFFICIENT THAN colorchannelmixer (+10% CPU).  BLUE, DARKBLUE & BLACK ARE COMPATIBLE WITH cropdetect (autocrop).  BLUE & WHITE STRIPES IS A DIFFERENT DESIGN, LIKE GREEK FLAG.  COLOR-BLINDNESS COULD BE AN ISSUE.
    dual_filterchain   =           'format=yuva420p,lutyuv=a=val/.7',  --DEFAULT='null'  APPLIES AFTER PRIMARY filterchain.  yuva420p IS MORE OPTIMAL THAN RGB FORMATS (bgra OR gbrap).
    -- filterchain     = 'shuffleplanes=1:0,lutrgb=g=val/2:a=val*.7',  --UNCOMMENT FOR RED & DARKGREEN, INSTEAD OF RED & BLUE (DEFAULT). THIS EXAMPLE DROPS GREEN 50% BECAUSE IT'S TOO BRIGHT.
    -- dual_filterchain=         'shuffleplanes=1:0,lutrgb=a=val/.7',  --UNCOMMENT FOR RED & GREEN DUAL.  EXAMPLE: TO SEESAW IT, APPEND ",rotate=a=PI/32*sin(PI*n/%s):c=BLACK@0"
    -- freqs_interpolation=true, --UNCOMMENT TO INTERPOLATE FROM freqs_fps→volume_fps. ADDS ~7% CPU USAGE. HOWEVER CAN REDUCE fps FROM 30→25 TO SUBTRACT 15% CPU USAGE.   CAN REDUCE freqs_fps_albumart, TO INTERPOLATE FROM IT.  NICE LIGHTNING EFFECT BUT LOOKS JITTERY & FILM MAY STUTTER @autocrop.
    freqs_dynaudnorm   = 'g=5:p=1:m=100:b=1',  --DEFAULT='g=31:p=.95:m=10:b=0'  THIS IS THE THIRD PASS. AFTER RESAMPLING TO 2.1kHz, & SHIFTING freqs_lead_time.  SPECTRUM SHOULD BE CLEAR EVEN FOR THE FAINTEST SOUNDS.
    freqs_options      = 's=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2',  --DEFAULT='s=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2'  EXTRA OPTIONS.  CAN ALSO SET overlap.  CAN'T CHANGE rate, fscale, colors & cmode.  INCREASE size FOR SHARPER CURVE (OR CHANGE ITS INTERNAL aspect).  mode={line,bar,dot}  win_func MAY ALSO BE poisson OR cauchy (PARZEN WAS AN AMERICAN STATISTICIAN).  win_size IS # OF DATA POINTS (LIKE TOO MANY PIANO KEYS).  FOR bar USE a=val*.25 IN filterchain.
    freqs_lead_time    =    .2,  --DEFAULT= .1   SECONDS. +-LEAD TIME FOR SPECTRUM. SUBJECTIVE TRIAL & ERROR (.1 .2 .3 .4 ?). BACKDATES audio TIMESTAMPS. showfreqs HAS AT LEAST 1 FRAME LAG.  A CONDUCTOR'S BATON MAY MOVE AN EXTRA .1s BEFORE THE ORCHESTRA, OR IT'S LIKE HE'S TRYING TO KEEP UP.
    freqs_fps          =  25/2,  --DEFAULT=25/2 DOUBLING MAY CAUSE FILM TO STUTTER, IF TOO MANY GRAPHS ARE ACTIVE. freqs_clip_h ALSO IMPROVES PERFORMANCE.  TRY averaging=3 FOR MORE fps.
    freqs_fps_albumart =    25,  --DEFAULT= 25  FOR RAW MP3 ALSO. CAN EASILY DOUBLE freqs_fps.
    freqs_clip_h       =   .25,  --DEFAULT= .3  MINIMUM=grid_height (CAN'T CLIP LOWER THAN grid, DUE TO RECIPROCAL CANVAS PADDING).  REDUCES CPU USAGE BY CLIPPING CURVE - CROPS THE TOP OFF SHARP SIGNAL.
    freqs_scale_h      =   1.2,  --DEFAULT=1.1  CURVE HEIGHT MAGNIFICATION. REDUCES CPU CONSUMPTION, BUT THE LIPS LOSE TRACTION.  L & R CHANNELS FORM LIKE A DUAL MOUTH (LIKE HOW HUMANS ARE BIPEDAL).  freqs_alpha OPTION UNNECESSARY (EQUIVALENT TO A no_freqs OPTION).
    volume_af_chain    = 'highpass=f=300,dynaudnorm=g=5:p=1:m=100:b=1', --DEFAULT='anull'  ALSO APPLIES TO freqs (volume GOES FIRST IN THIS MODEL).  300Hz highpass CLARIFIES SPECTRUM.  firequalizer IS AN ALTERNATIVE.
    volume_options     = 'f=0',  --DEFAULT=  1  REMOVE FOR FADE.  CAN ALSO ENTER EXTRA options. EXAMPLE: "dm=1:dmc=RED" FOR DISPLAY-MAX-LINES.
    volume_fps         =    25,  --DEFAULT= 25  PRIMARY ANIMATION fps. STREAM MAYBE 60fps BUT NOT THE EXTRA VISUALS.
    volume_alpha       =   .25,  --DEFAULT= .5  SET 0 TO REMOVE BARS (feet REMAIN). OPAQUENESS OF volume BARS.  DUAL volume TAKES CENTER STAGE.
    volume_scale       = {.04,.15},  --DEFAULT={.04,.15}  RATIOS {WIDTH,HEIGHT} RELATIVE TO overlay_scale, BEFORE STACKING feet, & BEFORE autocrop.lua.
    grid_alpha         =     1,  --DEFAULT=  1  alpha MULTIPLIER RELATIVE TO volume_alpha. 0 REMOVES grid & feet.  .4/volume_alpha GIVES .4.
    grid_thickness     =   1/8,  --DEFAULT= .1  RATIO RELATIVE TO grid SPACING.  SLIGHTLY THICKER THAN CURVE.
    grid_height        =    .1,  --DEFAULT= .1  RATIO RELATIVE TO display, BEFORE STACKING feet.  grid TICKS ARE LIKE volume BATONS, OR TEETH BRACES FOR THE LIPS.
    feet_height        =   .05,  --DEFAULT=.05  RATIO>=.01 RELATIVE TO grid (BARS). 
    feet_activation    =    .5,  --DEFAULT= .5  RATIO RELATIVE TO volume, FROM THE BOTTOM.  feet BLINK ON/OFF WHEN volume PASSES THIS THRESHOLD.
    feet_lutrgb        = 'r=192:b=255:a=val/.25',  --DEFAULT='r=192:b=255:a=val*4'  val*0 TO REMOVE feet. COLOR OF CENTRAL feet. RELATIVE TO volume_alpha.
    shoe_color         =              'BLACK@.5',  --DEFAULT @1.  @0 TO REMOVE.  A DIFFERENT VERSION COULD ALSO ADD o.grid_filterchain & o.grid_feet_lutrgb. (BLUE/RED OR RED/BLUE BARS?)  RED OUTER BARS SET OFF cropdetect.  
    -- sine_mix        = {{100,.5},{'200:1',1},{300,.5},{'400:1',1},{500,.5},{'600:1',1},{700,.5},{'800:1',1},{900,.5},{'1000:1',1}}, --{{'frequency(Hz):beep_factor',volume},...}  beep_factor OPTIONAL.  sine WAVES FOR CALIBRATION MIX DIRECTLY INTO [ao]. THIS EXAMPLE BEEPS DOUBLE ON EVEN. BEEP ACTIVATES feet, & MAY HELP SET freqs_lead_time.  THE 900Hz PEAK LINES UP, BUT THE SURROUNDING CURVE SKEWED ABOVE 900Hz.
    -- scale           = {w=1680,h=1050},  --DEFAULT=display OR [vo].
    -- osd_on_toggle   = 5,  --SECONDS. UNCOMMENT TO INSPECT VERSIONS, FILTERGRAPHS & PARAMETERS. 0 CLEARS THE osd INSTEAD. DISPLAYS mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params
    options            = ''  --' opt1 val1  opt2=val2  --opt3=val3 '... FREE FORM.        
        ..' vd-lavc-threads=0 ' --VIDEO DECODER - LIBRARY AUDIO VIDEO.  0=AUTO  OVERRIDES SMPLAYER, OR ELSE MAY FAIL TESTING.
        ..'   osd-font-size=16  geometry=50%  force-window=yes '  --DEFAULT size 55p MAY NOT FIT osd_on_toggle. geometry ONLY APPLIES ONCE, IF MPV HAS ITS OWN WINDOW.  force-window PREVENTS MPV FROM VANISHING DURING TRACK CHANGES.
    ,
} 
o          = options  --ABBREV.
for opt,val in pairs({key_bindings='',toggle_on_double_mute=0,overlay_scale={1},fps=30,period=1,af_chain='anull',rotate=0,zoompan=1,overlay='(W-w)/2:(H-h)/2',dual_overlay='(W-w)/2:(H-h)/2',filterchain='null',dual_filterchain='null',dual_scale={},freqs_lead_time=.1,freqs_fps=25/2,freqs_fps_albumart=25,freqs_options='s=300x500:mode=line:ascale=lin:win_size=512:win_func=parzen:averaging=2',freqs_scale_h=1.1,freqs_clip_h=.3,freqs_dynaudnorm='',volume_af_chain='anull',volume_options='',volume_fps=25,volume_alpha=.5,volume_scale={.04,.15},grid_alpha=1,grid_thickness=.1,grid_height=.1,feet_height=.05,feet_activation=.5,feet_lutrgb='r=192:b=255:a=val/.25',shoe_color='',scale={},options=''})
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

for opt in ('rotate zoompan period'):gmatch('[^ ]+') do o[opt]=o[opt]..'' end  --..'' CONVERTS→string, BUT THESE MAY BE NUMBERS.
if o.period=='0' then for opt in ('rotate zoompan overlay dual_filterchain dual_overlay'):gmatch('[^ ]+') --DON'T DIVIDE BY 0 BY REMOVING TIME DEPENDENCE.
    do for nt in ('in on n t'):gmatch('[^ ]+') do o[opt]=o[opt]:gsub(nt..'/%%s',0) end end end     --in & on BEFORE n.  OVERRIDE: THIS CODE ONLY GSUBS "t/%s" ETC (NOT FULLY GENERAL).
for opt in ('rotate  dual_filterchain zoompan'):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.volume_fps)) end  --ANIMATIONS ARE @volume_fps. OPTIMIZE USING DIFFERENT fps.  dual_filterchain IS LIKE rotate.
for opt in ('overlay dual_overlay            '):gmatch('[^ ]+') do o[opt]=o[opt]:gsub('%%s',('(%s*%s)'):format(o.period,o.       fps)) end  --OVERLAYS ARE @STREAM fps.

amix         = o.sine_mix and ',[ao]' or ''  --EXTENDS o.af_chain INTO A SUBGRAPH, OR ELSE BLANK.  "," SEPERATES THE SINES FROM THE MIX.
if   amix   ~= ''
then for N,sine in pairs(o.sine_mix) 
     do amix = (',sine=%s,volume=%s[a%d]%s[a%d]'):format(sine[1],sine[2],N,amix,N) end  --RECURSIVELY GENERATE ALL sine WAVES (WITH THEIR volume).
     amix    = ('[ao]%samix=%d:first'):format(amix,#o.sine_mix+1) end     --MIXES [ao][a1][a2]...  SINE WAVES ARE INFINITE DURATION.  SINGLETON amix VALID, BUT I LEAVE IT OUT.
vflip        = o.vflip_scale_h and o.vflip_scale_h+0>0  --+0 CONVERTS→number. 
               and ('vflip,scale=iw:ih*(%s),pad=0:ih/(%s):0:0:BLACK@0'):format(o.vflip_scale_h,o.vflip_scale_h)  --scale & pad FOR BOTTOM. PADDING SIMPLIFIES CODE.
vstack       = not (not vflip and o.vflip_only) and o.filterchain..','      --PREPEND COLOR SHUFFLING, UNLESS NULL OVERRIDE.
               ..  (not vflip      and         'pad=0:ih*2:0:0:BLACK@0'     --TOP ONLY. pad*2 FOR ABSENT BOTTOM SIMPLIFIES CODE.
                   or o.vflip_only and vflip..',pad=0:ih*2:0:oh-ih:BLACK@0' --BOTTOM ONLY, pad DOUBLE.  
                   or ('split[U],%s[D],[U][D]vstack'):format(vflip))        --BOTH  [U],[D] = UP,DOWN = TOP,BOTTOM  vstack IS TOP/BOTTOM.
o. volume_scale[2] =  o. volume_scale[2] or o. volume_scale[1]  --volume_scale MUST BE WELL-DEFINED.
o.overlay_scale[2] =  o.overlay_scale[2] or o.overlay_scale[1]  --BY DEFAULT SCALE_H=SCALE_W
o.   dual_scale[2] =     o.dual_scale[1] and (o. dual_scale[2] or o.dual_scale[1])*o.freqs_clip_h*2  --CLIP HEIGHT FOR (PADDED) TOP & BOTTOM (*2). RELATIVE TO DISPLAY HEIGHT.
dual               = not o.dual_scale[1] and ''  --NO dual. OR ELSE dual BELOW.
                     or ('[vo],[ov]split[ov],%s[dual],[dual][vo]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/4)*4[dual][vo],[vo][dual]overlay=%s'):format(o.dual_filterchain,o.dual_scale[1],o.dual_scale[2],o.dual_overlay)  --APPLY FILTERCHAIN FIRST BECAUSE [ov] IS ONLY 1200p, NOT 4K ACROSS LIKE [vo].
    

lavfi=('[aid%%d]%s%s,asplit[ao],stereotools,%s,asplit[freqs],aformat=s16,showvolume=%s:0:128:8:t=0:v=0:o=v:%s,shuffleplanes=1:0,lutrgb=g=0:a=val*(%s),split=3[vol][BAR],crop=iw/2*3/4:ih*(%s):(iw-ow)/2:ih*(1-(%s)),lutrgb=%s,pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:%s,split,hstack,split[feet0],shuffleplanes=0:2:1[feet],[vol][feet0]vstack[vol],[BAR][feet]vstack,lutrgb=a=val*(%s),split[RGRID],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[RGRID]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih*(%s)/(%s):0:oh-ih:BLACK@0[grid],[freqs]apad,aformat=s16:2100,asetpts=max(0\\,PTS-(%s)/TB),dynaudnorm=%s,aformat=s16,showfreqs=%s:colors=BLUE|RED:%%s,fps=%%s,crop=iw/1.05:ih*(%s)/(%s):0:ih-oh,format=gbrp,scale=iw*2:-1,avgblur=1:2^2+2^1,lutrgb=255*gt(val\\,140):0:255*gt(val\\,140),avgblur=2:2^2+2^1,lutrgb=r=255*gt(val\\,90):b=255*gt(val\\,90),framerate=%%s,format=bgra,split[R],shuffleplanes=0:0:1:1,hflip[L],[R]shuffleplanes=0:0:2:2[R],[grid][L]scale2ref=iw*2-2:ih,overlay=0:0:endall[grid+L],[grid+L][R]overlay=W-w,scale=ceil(iw/4)*4:ceil(ih/4)*4,split=3[LHI][RHI],crop=iw/2[MIDDLE],[LHI]crop=iw/4:ih:0,shuffleplanes=0:2:1[LHI],[RHI]crop=iw/4:ih:iw-ow,shuffleplanes=0:2:1[RHI],[LHI][MIDDLE][RHI]hstack=3[ov],[vol][ov]scale2ref=round(iw*(%s)/4)*4:round(ih*(%s)/(%s)/4)*4[vol][ov],[ov][vol]overlay=(W-w)/2:H-h,format=bgra,%s[ov],%%sfps=%s,scale=%%d:%%d,format=yuva420p,setsar=1%s,split=3[vo][t0],crop=1:1:0:0:1:1,fps=%s,lutyuv=0:128:128:0[to],[to][ov]scale2ref,overlay,setpts=PTS-STARTPTS,rotate=%s:c=BLACK@0,pad=iw/(%s):ih/(%s):(ow-iw)/2:(oh-ih)/2:BLACK@0,zoompan=%s:d=1:s=%%dx%%d:fps=%s[ov],[vo]setpts=PTS-STARTPTS[vo],[vo][ov]overlay=%s[vo],[t0]trim=end_frame=1,setpts=PTS-1/FRAME_RATE/TB[t0],[t0][vo]concat,trim=start_frame=1:end=%%s,format=%%s[vo]')
      :format(o.af_chain,amix,o.volume_af_chain,o.volume_fps,o.volume_options,o.volume_alpha,o.feet_height,o.feet_activation,o.feet_lutrgb,o.shoe_color,o.grid_alpha,o.grid_thickness,o.grid_thickness,o.freqs_clip_h,o.grid_height,o.freqs_lead_time,o.freqs_dynaudnorm,o.freqs_options,o.freqs_clip_h,o.freqs_scale_h,o.volume_scale[1],o.volume_scale[2],o.freqs_clip_h,vstack,o.fps,dual,o.volume_fps,o.rotate,o.overlay_scale[1],o.overlay_scale[2],o.zoompan,o.volume_fps,o.overlay)  --volume_fps FOR volume, TIME-STREAM [to] & zoompan. freqs_clip_h CROPS freqs & PADS volume & [grid].

----lavfi           = graph LIBRARY-AUDIO-VIDEO-FILTERGRAPH.  [vid#]=VIDEO-IN [aid#]=AUDIO-IN [vo]=VIDEO-OUT [ao]=AUDIO-OUT [ov]=OVERLAY(SPECTRUM) [freqs]=AUDIO-FREQS [to]=TIME-OUT(1x1) [t0]=STARTPTS-FRAME [L]=LEFT [R]=RIGHT [vol]=VOLUME [grid]=VOL-BARS  ALSO [LGRID][RGRID][LHI][RHI].  SELECT FILTER NAME OR LABEL TO HIGHLIGHT IT. NO WORD-WRAP → SIDE-SCROLL PROGRAMMING, WITH LINEDUPLICATE ETC. lavfi-complex MAY COMBINE MANY [aid#] & [vid#] INPUTS. %% SUBS OCCUR LATER. (%s) BRACKETS FOR MATH.  A lavfi string IS LIKE DNA & CAN CREATE VARIOUS CREATURES. SEE FFMPEG-FILTERS MANUAL. A BRICK OF EQUATIONS DEFINE STRING INSERTS.  EACH FOOT HAS A STEREO INSIDE IT. [feet0] (SHOES) ARE THE CENTER-PIECE.  [to] & [t0] CODES ALWAYS VALID, EVEN ON YOUTUBE & FOR MP4 SUBCLIPS WITH OFF TIMESTAMPS. IMPOSSIBLE TO CORRECTLY ENTER NUMBERS LIKE time-pos OR audio-pts. CANVAS [to] SWITCHES OUT [ao]→[vo] TIMESTAMPS (IT'S ACTUALLY [time-vo]).
----dynaudnorm      = ...:g:p:m:...:b  DEFAULT=...:31:.95:10:...:0  ...:GAUSSIAN_WIN_SIZE(ODD>1):PEAK_TARGET[0,1]:MAX_GAIN[1,100]:...:BOUNDARY_MODE{0,1}  IS THE START.  DYNAMIC AUDIO NORMALIZER OUTPUTS A BUFFERED STREAM WITH TB=1/SAMPLE_RATE & FORMAT=doublep.  MAY BE BLANK.  b=NO_FADE (FADE NOT FOR SPECTRUM). IT MAY SLOW DOWN YOUTUBE, BY PRE-LOADING MANY FRAME-LENGTHS (g=31). LOWER g MAY GIVE FASTER RESPONSE. ALTERNATIVES INCLUDE loudnorm & acompressor, BUT dynaudnorm IS BEST. 
----sine            = frequency:beep_factor  →s16  (Hz,BOOL)  DEFAULT=440:0  beep IS EVERY SECOND.  FOR sine_mix CALIBRATION.
----volume          = volume  DEFAULT=1  RATIO. sine VOLUMES. FORMS TRIPLE WITH sine & amix.
----amix            = inputs:duration  DEFAULT=2:longest  MIXES IN SINES. [a1][a2]...→[ao]
----split,asplit    = outputs  DEFAULT=2  CLONES video/audio.
----highpass        = f  →floatp  DEFAULT=3000 Hz  MAY BE BLANK.  firequalizer IS MORE GENERAL & COULD MULTIPLY BY FREQUENCY. A CHIRP MAY BECOME DEAFENING @DOUBLE FREQUENCY.
----showvolume      = r:b:w:h:f:...:t:v:o:...:dm:dmc = rate:CHANNEL_GAP:LENGTH:THICKNESS/2:FADE:...:CHANNELVALUES:VOLUMEVALUES:ORIENTATION:...:DISPLAYMAX:DISPLAYMAXCOLOR →rgba    (DEFAULTS 25:1:400:20:0.95:t=1:v=1:o=h)   LENGTH MINIMUM ~100. t & v ARE TEXT & SHOULD BE DISABLED.  THERE'S SOME TINY BLACK LINE DEFECT, WHICH BLUE COVERS UP.
----setpts,asetpts  = expr  DEFAULT=PTS  PRESENTATION TIMESTAMP, FOR SYNC OF rotate,zoompan,overlay WITH OTHER GRAPHS (automask), BY SENDING STARTPTS→0. SHOULD SUBTRACT 1/FRAME_RATE/TB FROM [t0].  asetpts LEADS THE SPECTRUM BY BACKDATING AUDIO.
----pad,apad        = w:h:x:y:color,...  DEFAULT=0:0:0:0:BLACK  BUILDS GRID/RULER & FEET. 0 MAY MEAN iw OR ih. pad OUT BEFORE zoompan IN!  apad APPENDS SILENCE FOR showfreqs TO ANALYZE, OR IT HANGS NEAR @end-file. AN ALTERNATIVE IS TO EXPAND TIMESTAMPS NEAR end-file.
----showfreqs       = size:rate:mode:ascale:fscale:win_size:win_func:...:averaging:colors  →rgba  DEFAULT=1024x512:25:bar:log:lin:2048:hanning:...:1   RATE INCOMPATIBLE WITH FFMPEG-v4. size SHOULD HAVE ASPECT APPROX 3x5 FOR HEALTHY CURVE TO BE EQUALLY THICK IN HORIZONTAL & VERTICAL (300x300 & 300x700 ARE OFF).  win_size BTWN 256 & 2048.  cmode=separate WOULD REQUIRE TWICE AS MANY PIXELS.
----shuffleplanes   = map0:map1:map2:map3  DEFAULT=0:1:2:3  REDUCES NET CPU USAGE BY >5%. ORDERED g:b:r:a (LIKE GreatBRitAin, WITH RED ON RIGHT). SHUFFLES WITHOUT MIXING.  FFMPEG-v4 COMPATIBILITY DEPENDS ON EXACT USAGE.  SWITCHES [vol] GREEN & BLUE, [feet] FROM [feet0], & COLORS HIGHS VS LOWS, & [L][R] CHANNELS.
----fps             = fps:start_time  (SECONDS)  DEFAULT=25  LIMITS STREAM @file-loaded. ALSO FOR OLD MPV showfreqs. start_time FOR JPEG(TOGGLE OFF).
----loop            = loop:size  ( >=-1 : >0 )  LOOPS BOTH albumart & image (SEE TOGGLE).
----framerate       = fps  (DEFAULT=50)  alpha CAUSES BUG (gbrp NOT gbrap). NEGATIVE TIME ALSO CAUSES BUG. DOUBLING fps ADDS 10% CPU USAGE. 
----rotate          = a:ow:oh:c  (RADIANS:PIXELS:PIXELS:string) ROTATES CLOCKWISE. CAN DEPEND ON n & t.
----zoompan         = z:x:y:d:s:fps   (z>=1)  d=1 (OR 0) FRAMES DURATION-OUT PER FRAME-IN.  z:x:y MAY DEPEND ON  INPUT-NUMBER=in=on=OUTPUT-NUMBER  zoompan OPTIMAL FOR ZOOMING.
----crop            = w:h:x:y:keep_aspect:exact  DEFAULT=iw:ih:(iw-ow)/2:(ih-oh)/2:0:0   ZOOMS IN ON ascale & fscale. REMOVES MIDDLE TICK ON GRID. SEPARATES LOWS FROM [LHI] & [RHI]. CROPS 5% OFF DATA. FFMPEG-v4 REQUIRES ow INSTEAD OF oh (DEPENDING).
----lutyuv,lutrgb   = y:u:v:a,r:g:b:a  DEFAULT=val  LOOK-UP-TABLE-BRIGHTNESS-UV,RED-GREEN-BLUE  lutyuv CONVERTS gbrap→yuva444p. lutrgb CONVERTS yuva420p→argb. lutyuv IS MORE EFFICIENT THAN lutrgb DUE TO FORCED FORMATTING.  lut HAS A BUG WHERE MAYBE r=green BECAUSE IT ASSUMES r IS PLANE 0 FOR gbrap.  lutyuv CREATES TRANSPARENCY & CANVAS. lutrgb SELECTS CURVE FROM BLUR BRIGHTNESS. CURVE SMOOTHNESS & THICKNESS DOUBLE-CALIBRATED USING lutrgb>140 & 90.  SERATED-RAZOR-CURVE IS ANOTHER IDEA.
----avgblur         = sizeX:planes  DEFAULT=1:15  (INTEGERS,planes<16)  AVERAGE BLUR  sizeY=sizeX (PIXELS)  FOR gbrap planes=8(GREEN)+4(BLUE)+2(RED)+1(ALPHA)=2^3+2^2+2^1+2^0.  CONVERTS JAGGED CURVE INTO BLUR, WHOSE BRIGHTNESS GIVES SMOOTHER CURVE.
----overlay         = x:y:eof_action →yuva420p  DEFAULT=0:0:repeat  endall DUE TO apad. FORCES US TO USE yuva420p.  OVERLAYS DATA ON GRID & VOLUME ON-TOP. ALSO: 0Hz RIGHT ON TOP OF 0Hz LEFT (DATA-overlay INSTEAD OF hstack). MAY DEPEND ON t & n.  UNFORTUNATELY THIS FILTER HAS AN OFF BY 1 BUG IF W OR H ISN'T A MULTIPLE OF 4. AN EVEN HALF PLANE WIDTH (MULTIPLE OF 4) MAY HAVE BEEN SIMPLER FOR FFMPEG TO OPTIMIZE.  
----hstack,vstack   = inputs  DEFAULT=2  COMBINES THE VOLUMES INTO A 20 TICK STEREO RULER. ALSO COMBINES feet.  vstack FOR FEET & TOP/BOTTOM.
----setsar          = sar  DEFAULT=0  SAMPLE ASPECT RATIO=1 FINALIZES OUTPUT DIMENSIONS. OTHERWISE THE DIMENSIONS ARE ABSTRACT (IN REALITY OUTPUT IS DIFFERENT).  FOR albumart SAFE concat OF [t0].
----trim            = ...:start_frame:end_frame  TRIMS 1 FRAME OFF THE START FOR ITS TIMESTAMP.
----scale,scale2ref = w:h  DEFAULT=iw:ih  FINALIZES WHAT COULD BE ODD DISPLAY DIMENSIONS.  SCALES TO display FOR CLEARER SPECTRUM ON LOW-RES video. CAN ALSO OBTAIN SMOOTHER CURVE BY SCALING UP A SMALLER ONE.  TOREFERENCE [1][2]→[1][2] SCALES [1] USING DIMENSIONS OF [2]. ALSO SCALES volume.  dst_format & flags=bilinear CAN ALSO BE SET.  
----format,aformat  = pix_fmts,sample_fmts:sample_rates  {yuva420p,yuv420p,bgra,gbrp=rgb24},s16:Hz  IS THE FINISH (TO REMOVE alpha). MAY BE BLANK.  gbrap (GreatBRitAin Planar) ASSUMED BY shuffleplanes & avgblur.  HOWEVER bgra (RGB BACKWARDS) ALSO REQUIRED FOR EFFICIENT SCALING (CAN CHECK MPV-LOG).  BUT yuva420p FORCED BY overlay.  aformat REMOVES doublep PRECISION AFTER dynaudnorm, & DOWNSAMPLES TO 2.1kHz (NYQUIST+5%). 
----stereotools       CONVERTS MONO & SURROUND SOUND TO stereo.  ALTERNATIVE TO aformat.  softclip INCOMPATIBLE WITH FFMPEG-v4.
----hflip,vflip       FLIPS [L] LEFT.  vflip FOR BOTTOM [D] (DOWN).
----concat            [t0][vo]→[vo]  FINISHES [t0].  CONCATENATE STARTING TIMESTAMP, ON INSERTION. OCCURS @seek. NEEDED TO SYNC WITH automask.


function round(N,D)  --ROUND NUMBER N TO NEAREST MULTIPLE OF DIVISOR D (OR 1). N & D MAY ALSO BE STRINGS OR nil.  PRECISION LIMITER, TO MULTIPLES OF 4.
    D=D or 1
    return N and math.floor(.5+N/D)*D  --LUA DOESN'T SUPPORT math.round(N)=math.floor(.5+N)
end


function file_loaded()  --ALSO on_aid_vid & on_toggle{ON}.    THIS COULD BE REPLACED BY on_av_params. BUT THE .1s DELAY TO DETECT alpha RARELY CAUSES STUTTER/LAG @LOAD.
    p              = {} --RE-INITIALIZE PROPERTIES table.
    for  property in ('current-tracks/audio current-tracks/video video-params display-width display-height duration'):gmatch('[^ ]+') 
    do p[property] = mp.get_property_native(property) end  --get_property_native CAN TAKE ~13 MICROSECONDS, WHILE get_property_number TAKES ONLY ~5us. BUT TABLES CONTAIN MANY NUMBERS SO ARE MORE EFFICIENT.
    a              = p['current-tracks/audio'] or {}  --THESE ARE REFERENCES TO p SUB-TABLES, NOT COPIES.
    v              = p['current-tracks/video'] or {}
    v_params       = p['video-params'        ] or {}
    W              = o.scale.w or o.scale[1]   or p['display-width' ] or v_params.w or v['demux-w'] or 1280  --(scale OVERRIDE) OR (display) OR ([vo] DIMENSIONS) OR (FALLBACK FOR RAW MP3 IN VIRTUALBOX)
    H              = o.scale.h or o.scale[2]   or p['display-height'] or v_params.h or v['demux-h'] or 720
    ----W,H SHOULD MAINTAIN INPUT ASPECT IN NEXT VERSION. THE IDEA SHOULD BE TO SCALE DOWN 4K & ASPECT SHOULD BE UNCHANGED.  setsar=1 EITHER WAY THOUGH, OR IT COULD BE 1.01, ETC.
    OFF            = OFF       or not a.id     or not vstack  --~AUDIO OR ~vstack → OFF.
    if   OFF       
    then OFF       = false --FORCE TOGGLE OFF, IF OFF.
        on_toggle()  --COVERS OFF CASES. EXAMPLE: JPEG=OFF-albumart.  THE TOGGLE DOESN'T CLEAR lavfi-complex. IT ONLY CLEARS THE SPECTRUM & CPU USAGE. SOMETIMES A FILE-LOAD IS NOTHING BUT A TOGGLE OFF.
        return end   --ON BELOW. 
    if not ov_w then  _,error_ffmpeg =    mp.command('no-osd vf pre    @lavfi-format:lavfi-format')  end  --~ov_w MEANS ONCE ONLY.  OLD FFMPEG DETECTION. MORE RELIABLE THAN VERSION NUMBERS BECAUSE THEY CAN BE ANYTHING. SO DETECT ERROR USING NULL-OP.
    if not ov_w and not error_ffmpeg then mp.command('no-osd vf remove @lavfi-format') end  --ONLY remove IF ABLE TO.
    
    ov_w,ov_h  = round(W,4),round(H*o.freqs_clip_h*2,4)  --PRIMARY OVERLAY SCALE (w & h). vstack*2 FACTOR (ALSO VALID IF TOP-ONLY). CLEARER TO NAME EACH # (NAME EVERYTHING).
    freqs_fps  = (v.albumart or not v.id) and o.freqs_fps_albumart or o.freqs_fps  --freqs_fps MAY VARY on_vid. SOME ANIMATIONS (LIKE FRACTALS) CAN BE DONE SMOOTHER ON albumart.
    framerate  = o.freqs_interpolation and o.volume_fps or freqs_fps  --INTERPOLATION: freqs_fps→volume_fps
    freqs_rate = error_ffmpeg and '' or 'rate='..freqs_fps            --FFMPEG-v4 OPERATES showfreqs @25fps (.AppImage & .snap). LATER VERSIONS SUPPORT ANY fps.
    duration   = p.duration-.1  --SUBTRACT .1s, BY TRIAL & ERROR. SAFER THAN SETTING end PROPERTY.  TESTED MPV-v0.38 ON 10 HOURS albumart (HANGS NEAR end-file).  VALID EVEN IF NEGATIVE.
    format     = (not v.id or v_params.alpha) and (error_ffmpeg and 'yuva420p' or '') or 'yuv420p'  --AKA pixelformat. lavfi-complex CAN'T DETECT WHETHER alpha EVER EXISTED WITHOUT A DELAYED TRIGGER.  overlay FORCES yuva420p, BUT SHOULD REMOVE alpha BECAUSE ITS EXISTENCE MAY TRIGGER BUGS IN VARIOUS SCRIPTS.  OLD FFMPEG REQUIRES SPEC.
    complex    =  --3 CASES:  1) PROPER-VIDEO  2) albumart  3) AUDIO-ONLY    CAN CHECK MPV LOG TO VERIFY OUTPUT IN EVERY CASE. INSTEAD OF EVERY SCRIPT SETTING ITS OWN lavfi-complex, THEY MAY RELY ON THIS SCRIPT. EXAMPLE: automask.lua albumart ANIMATION.
                 v.id and not v.image and ('[vid%d]'):format(v.id)  --CASE 1: NORMAL video.  complex=lavfi INSERT WHICH YIELDS [vo].  
                 or v.id and ('[vid%d]scale=%d:%d,format=yuva420p,loop=-1:1[vo],[ov]split[ov],trim=end_frame=1,crop=1:1:0:0:1:1,format=yuva420p,scale=%d:%d,setsar[t0],[t0][vo]concat,trim=start_frame=1,'):format(v.id,W,H,W,H)  --CASE 2 (albumart) IS THE MOST COMPLICATED. albumart IS LOOPED, WITH ATOMIC TIMESTAMP FRAME [t0] PREPENDED & TRIMMED, TO SUPPORT PROPER seeking.  ALTERNATIVE IS TO INSERT time-pos @seek BUT THAT CAUSED SOME LAG.
                 or '[ov]split[ov],crop=1:1:0:0:1:1,format=yuva420p,lutyuv=0:128:128:0,'  --CASE 3  (RAW AUDIO)  UNDERLAY USES [ov] (SPECTRUM) INSTEAD OF [vid#], TO BUILD BLANK [vo].
    mp.set_property('lavfi-complex',(lavfi):format(a.id,freqs_rate,freqs_fps,framerate,complex,W,H,ov_w,ov_h,duration,format))  
end 
mp.register_event('file-loaded',file_loaded)
mp.register_event('seek',function() if (mp.get_property_number('time-remaining') or .2)<.2 then mp.command('playlist-next force') end end)  --playlist-next FOR MPV PLAYLIST. force FOR SMPLAYER PLAYLIST. .2 FOR seek PASSED end CORRECTION.  BUGFIX FOR seek PASSED end-file.  A CONVENIENT WAY TO SKIP NEXT TRACK IN SMPLAYER IS TO SKIP 10 MINUTES, PASSED end-file.

function on_toggle(mute)     --AN ALTERNATIVE (FULL) TOGGLE COULD stop keep-playlist & playlist-play-index current TO FULLY CLEAR lavfi-complex. BUT THAT SNAPS THE WINDOW & INTERRUPTS PLAYBACK, LIKE on_aid_vid. THIS TOGGLE JUST REMOVES THE SPECTRUM FROM THE lavfi-complex.
    if not timer then return --STILL LOADING.
    elseif mute and not timer:is_enabled() then timer:resume() --START timer OR ELSE TOGGLE.  DOUBLE-MUTE MAY FAIL TO OBSERVE EITHER mute IF seeking. IT CANCELS ITSELF OUT IN SMPLAYER.
        return end
    
    OFF = not OFF  --REMEMBER TOGGLE STATE.  
    if not OFF then file_loaded()  --TOGGLE ON. 
    else complex=v.id and not v.image and   (',[vid%d]fps=%s,scale=%d:%d[vo]'):format(v.id,o.fps,W,H) --CASE 1: TOGGLE OFF MP4. LIMIT [vo], WITH NO SPECTRUM.
                 or v.id  and  (',[vid%d]scale=%d:%d,loop=-1:1,fps=%s:%s[vo]'):format(v.id,W,H,o.fps,mp.get_property_number('time-pos'))  --CASE 2: image. MORE GENERAL THAN albumart. NO pixelformat TO PRESERVE TRANSPARENCY.  CAN USE ~25% CPU @FULLSCREEN.  NEED start_time FOR --start.  FFmpeg-v5 TAKES A STILL FRAME (DIFFERENT, BUT VALID).  UNFORTUNATELY SNAPS EMBEDDED MPV.
                 or ''  --CASE 3. RAW audio STATIC SPECTRUM.  CAN CHECK MPV LOG TO VERIFY OUTPUT IN EVERY CASE. 
         complex=a.id and ('[aid%d]%s[ao]%s'):format(a.id,o.af_chain,complex)  --PREPEND NORMALIZED AUDIO. CASE 3 IS NOTHING BUT AUDIO.
                 or complex:sub(2)  --REMOVE LEADING "," IF NO AUDIO (POSSIBLY CASES 1 & 2).  FFMPEG-v5 THROWS ERROR ON TRAILING ",".
         mp.set_property('lavfi-complex',complex) end
    if o.osd_on_toggle then p={}  --PROPERTIES LIST. CLEARING IT DOESN'T CLEAR v, DESPITE v IT BEING A REFERENCE TO A SUB-table.
        for property in ('mpv-version ffmpeg-version libass-version lavfi-complex af vf video-out-params'):gmatch('[^ ]+')
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
----A DIFFERENT DESIGN COULD COMPRESS 1→10kHz INTO AN ELEVENTH TICKMARK.

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
----EXTRACTPLANES LR MONOCHROME (FASTER?):   lavfi=('[aid%%d]asplit[ao]%s,aformat=s16:channel_layouts=stereo,dynaudnorm=p=1:m=100:c=1:b=1,asplit[af],aformat=s16,showvolume=%s:0:%s:8:%s:t=0:v=0:o=v,colorchannelmixer=gg=0:bg=1:aa=%s,split[BAR],crop=iw/2*3/4:ih*(%s),lut=a=255*(%s),pad=iw*4/3:ih+(ow-iw)/a:(ow-iw)/2:oh-ih:WHITE@%s,split,hstack[FEET],[BAR][FEET]vstack,split=3[VOL][BAR],crop=iw/2:ih:0,pad=iw/%s:0:0:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:iw-ow,pad=iw+4:0:0:0:BLACK@0[LGRID],[BAR]crop=iw/2:ih:iw/2,pad=iw/%s:0:ow-iw:0:BLACK@0,split=10,hstack=10,crop=iw-4:ih:0,pad=iw+4:0:ow-iw:0:BLACK@0[RGRID],[LGRID][RGRID]hstack,pad=0:ih/(%s):0:oh-ih:BLACK@0[GRID],[af]aformat=s16:%s,asetpts=PTS-(%s)/TB,apad,highpass=%s,dynaudnorm=p=1:m=100:c=1:b=1,aformat=s16,showfreqs=256x512:mode=%s:ascale=lin:fscale=lin:win_size=%s:win_func=parzen:averaging=%s:colors=BLUE|RED,fps=%s,crop=iw:ceil(ih*(%s)/4)*4:0:ih-oh,extractplanes=r+b[R],hflip,pad=iw*2-(%s):0:0:0:BLACK@0[L],[R]split,alphamerge[R],[L][R]overlay=W-w,format=y8,scale=iw*2:-1,avgblur,lut=255*gt(val\\,140),avgblur=2,lut=255*gt(val\\,90),format=ya16,colorchannelmixer=ab=%s:rr=0:gg=0:aa=0[freqs],[GRID][freqs]scale2ref,overlay=0:H-h:endall,scale=ceil(iw/8)*8:ceil(ih/4)*4,split=3[HIGHR][LOWS],crop=iw/4:ih:0[HIGHL],[LOWS]crop=iw/2,colorchannelmixer=rr=0:bb=0:rb=1:br=1[LOWS],[HIGHR]crop=iw/4:ih:iw-ow[HIGHR],[HIGHL][LOWS][HIGHR]hstack=3[vid],[VOL][vid]scale2ref=floor(iw*%s/4)*4:ih*(%s)[VOL][vid],[vid][VOL]overlay=(W-w)/2:H-h,%s,setpts=PTS-STARTPTS,rotate=%s:iw:ih:BLACK@0,zoompan=%s:0:%%dx%%d:%s'):format(amix,o.fps,math.max(100,1080*o.volume_height),o.volume_fade,o.volume_alpha,o.feet_height,o.feet_alpha,o.feet_alpha*.25,o.grid_thickness,o.grid_thickness,o.grid_height/o.freqs_clip_h,2010,o.freqs_lead_t,o.volume_highpass,o.freqs_mode,o.freqs_win_size,o.freqs_averaging,o.freqs_fps,o.freqs_clip_h/o.freqs_scale_h,2,o.freqs_alpha,o.volume_width,o.volume_height/o.freqs_clip_h,vstack,o.rotate,o.zoompan,o.fps)    --%s SUBS ('2+1'=3 ETC). fps FOR volume & zoompan. 1080p FOR APPROX RES OF volume. feet_alpha REPEATS FOR INNER & OUTER FEET. freqs_clip_h CROPS freqs & PADS volume & GRID. freqs_alpha REPEATS FOR L & R CHANNELS. 

---- WIDTH  ESTIMATE = 300*2*2/1.05                           --*2 FOR INTERNAL SCALE, *2 FOR [L] & [R], /1.05 FOR NYQUIST.  zoompan ALWAYS REQUIRES RAW NUMBERS.  s=300x500 FROM showfreqs.
---- HEIGHT ESTIMATE = 500*2*2/o.freqs_scale_h*o.freqs_clip_h --*2 FOR INTERNAL SCALE, *2 FOR vstack.  (/1.2*.25)
    
    