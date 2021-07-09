*! Date        : 28 Aug 2018
*! Version     : 1.14
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*! Description : Radar graphs

/*
16/04/07 v 1.02: allow line colours and patterns for the observations
20/5/08  v 1.03: Allow rlabels.. to vary the web
27/10/08 v 1.04: Allow missing values but need to implement a gap
23/4/09  v 1.05: Move to the BSU email, do line widths
1/9/09   v 1.06: Move to Stata 11
14/6/11  v 1.07:  set dp period to sort out a bug
1/12/16  v 1.08: Add a "spike" radial plot as well as axes width colour and pattern styles.
10/3/17  v 1.09: Add connected graph style and LS() for marker symbols
27/3/17  v 1.10: Add marker color option
  2Jan18 v 1.11: Add option to delete axes labels 
  5Jul18 v 1.12: Remove aspectratio(1) as some graphs are misshapen
 13Aug18 v 1.13: Added area in the radar line
 28Aug18 v 1.14: Added in maximum area of the polygon
FUTURE release should include, varying text on axes.
*/

/* 
START HELP FILE

title[Radar plots or Spider plots]

desc[
{cmd:radar} produces a radar plot from at least two variables. The first variable must always contain the label for the axes
and the second variable must be numeric. 

The axes of the radar plot will start at the top of the diagram and proceed in a clockwise direction. With the above dataset
the first axes will be labelled beer.

Missing values are included in the radar plot as gaps in the line joining observations.
This option is implemented using the {opt cmiss(n)} option of the twoway line graph, see help {help connect_options}.
]

opt[lc the string argument is a {help colorstyle}list and specifies the colors for the observations (not axes).]
opt[lp the string argument is a {help linepatternstyle}list and specifies the patterns for the observations (not axes).]
opt[lw the string argument is a {help linewidthstyle}list and specifies the line widths for the observations (not axes).]
opt[ms the string argument is a {help symbolstyle}list and specifies the marker symbols to use for observations BUT must be used in conjunction with the connected option (not axes).]
opt[mcolor the string argument is a {help symbolstyle}list and specifies the marker colors to use for observations BUT must be used in conjunction with the connected option (not axes).]
opt[axelc the string argument is a colorlist and specifies the colors for the axes.]
opt[axelp the string argument is a patternlist and specifies the patterns for the axes.]
opt[axelw the string argument is a linewidthlist and specifies the line widths for the axes.]
opt[axelaboff specifies that axes labels are removed.]
opt[labsize the string argument is a {help textsizestyle} and specifies the text size of the node labels (not axes).]
opt[radial specifies a variable to be plotted as spikes along the spokes of the plot.]
opt[connected specifies that rather than a line graph of observations but a connected line graph is drawn.]
opt[rlabel specifies the ticks and labels of the spokes.]
opt[* additional {help twoway_options} can be specified, for example titles() and notes(), but not every possible option is allowed.]

opt2[rlabel specifies the ticks and labels of the spokes. The default is to have 5 values displayed, note that the 
value that is the centre or smallest tick is suppressed but the value is included as a note below the graph. The note can
be overwritten by using the {hi: note()} option.
]

return[area_ is the return area of the radar plot, the name of variable will be in the return name e.g. area_weight]
return[maxarea is the returned maximum area of the radar polygon given the maximum and minimum values on the plot]

example[

The examples below highlight the use of the {hi:radar} plot on the Auto dataset. The only limitation
is the number of "spokes" hence the commands are limited to just the foreign cars. Technical note: the limitation on
the number of spokes is unknown because the limit is due to the size of macros being returned as
part of a rclass program. The aspect ratio should be set to 1 but occassionally Stata's scaling of the plotregion can give
skewed plots so the aspect() option can adjust any skew.

Click below to load dataset 

{stata sysuse auto}

Click below (after the dataset is loaded to see the distribution of weight for the foreign makes of car

{stata radar make weight if foreign, aspect(1)}

Click below to see the distribution of turn mpg and trunk for each foreign make of car.

{stata radar make turn mpg trunk if foreign, aspect(1)} {p_end}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) aspect(1)} {p_end}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lp(dash dot dash_dot) aspect(1)}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) r(0 12 14 18 50) aspect(1)}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) aspect(1)}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) aspect(1)}

{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) connected ms(D Oh S) labsize(*.5) aspect(1)}

There is no real advantage of a radar diagram compared to a scatter plot unless there was some sort of directional data.

To add extra spikes for trunk instead of the contour

{stata radar make turn mpg if foreign,radial(trunk) title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) aspect(1)}

If you want to remove the labels from the axes use the axelaboff option

{stata radar make turn mpg if foreign,radial(trunk) title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) axelaboff aspect(1)}

]

author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

seealso[

{pstd}
Other Graphic Commands I have written: {p_end}

{synoptset 27 }{...}
{synopt:{help batplot} (if installed)} {stata ssc install batplot}   (to install) {p_end}
{synopt:{help cdfplot} (if installed)} {stata ssc install cdfplot}   (to install) {p_end}
{synopt:{help contour} (if installed)}   {stata ssc install contour}     (to install) {p_end}
{synopt:{help drarea}  (if installed)}   {stata ssc install drarea}      (to install) {p_end}
{synopt:{help graphbinary} (if installed)}   {stata ssc install graphbinary} (to install) {p_end}
{synopt:{help metagraph} (if installed)}   {stata ssc install metagraph}   (to install) {p_end}
{synopt:{help palette_all} (if installed)}   {stata ssc install palette_all} (to install) {p_end}
{synopt:{help plotbeta} (if installed)}   {stata ssc install plotbeta}    (to install) {p_end}
{synopt:{help plotmatrix} (if installed)}   {stata ssc install plotmatrix}  (to install) {p_end}
{synopt:{help surface}  (if installed)}   {stata ssc install surface}     (to install) {p_end}
{synopt:{help trellis}  (if installed)}   {stata ssc install trellis}     (to install) {p_end}
{p2colreset}{...}

]

END HELP FILE 
*/

pr radar, rclass
version 11.0
preserve
syntax [varlist] [if] [in] [, LC(string) LP(string) LW(string)  MS(string) MColor(string) Rlabel(numlist) LABSIZE(string) RADIAL(varname) AXELABOFF AXELC(string) AXELW(string) AXELP(string) CONNECTED *]
if "`c(dp)'"=="comma" {
  di "{err} Warning you might need to type -set dp period- if a numlist message appears
}

local gopt "`options'"

/* Set up the defaults for line color, pattern, width  of the radar observations*/
if "`lc'"=="" local xopt ""
else local xopt "lc(`lc')"
if "`lp'"~="" local xopt "`xopt' lp(`lp')"
if "`lw'"~="" local xopt "`xopt' lw(`lw')"
if "`ms'"~="" local xopt "`xopt' ms(`ms')"
if "`mcolor'"~="" local xopt "`xopt' mc(`mcolor')"
if "`labsize'"~=""  local labsize "si(`labsize')"
else local labsize "si(*1)"

/* Set up defaults for the axes line color, pattern width */
if "`axelc'"=="" local axopt "lc(gs12)"
else local axopt "lc(`axelc')"
if "`axelp'"~="" local axopt "`axopt' lp(`axelp')"
if "`axelw'"~="" local axopt "`axopt' lw(`axelw')"
else local axopt "`axopt' lw(*.4)"

/* The simple way of doing if and in.. just delete and use preserve/restore*/
if "`if'"~="" keep `if'
if "`in'"~="" keep `in'

/* This part is looking for min and max data to get the range for the axes*/
local max -1000000000000000000
local min 1000000000000000000
local maxlevels 0

local i 0
local vlist ""
foreach v of local varlist {
  if `++i'==1 {
    local vlab "`v'"  /*isolate the spoke label variable*/
    cap confirm numeric variable `v'  /* Then find out how many levels if v is numeric or string*/
    if _rc==0 {
      qui count if `v'~=.
    }
    else {
      qui count if `v'~=""
    }
    local nlevels `r(N)'
    if `maxlevels' < `nlevels' local maxlevels `nlevels'
  }
  else {
    local vlist "`vlist' `v'"  /*This is used in drawobs*/
    qui su `v'
    if `r(max)'>`max' local max = `r(max)'
    if `r(min)'<`min' local min = `r(min)'
  }
}

/* just check if radial variable has bigger/smaller values than radar variables*/
foreach v of local radial {
    confirm numeric variable `v'
    qui su `v'
    if `r(max)'>`max' local max = `r(max)'
    if `r(min)'<`min' local min = `r(min)'
}

/* The automatic legend values  by variable name*/
local i 0
foreach v of local varlist  {
  if `i++'~=0 {
    local order "`order' `--i'"
    local l "`l' label(`i++' "`v'")"
  }
}
/* Adds in a legend for the radial variables */
if "`radial'"~="" {
foreach v of local radial  {
  if `i++'~=0 {
    local order "`order' `--i'"
    local l "`l' label(`i++' "`v'")"
  }
}
}
local legend "legend(order(`order') `l')"


/* Yes maxlevels is the number of spokes... */
if `maxlevels'>100 {
  di "{error}Warning: You have over 100 possible spokes"
  exit(198)
}

/* Having found min and max.. rlabel might change this as this is the user specified web */
if "`rlabel'"~="" {
  numlist "`rlabel'", sort
  local rlabel "`r(numlist)'"
  local rmax -10000000000000
  local rmin 1000000000000000
  foreach r of local rlabel {
    if `rmax'<`r' local rmax "`r'"
    if `rmin'>`r' local rmin "`r'"
  }
if `rmin'>`min' local rlabel "`min' `rlabel'"
if `rmax'<`max' local rlabel "`rlabel' `max'"
if `rmin'<`min' local min =`rmin'
if `rmax'>`max' local max =`rmax'
local axeopt ",rlabel(`rlabel')"
local axeoptnocom "rlabel(`rlabel')"
}
/* NOTE that the min and max variable are for the radial lines*/

/* DRAW the axes*/
/* some code to handle axes color pattern width */
if "`axeopt'"=="" local axepattern ", `axopt'"
else local axepattern " `axopt'"

_buildaxes `maxlevels' `max' `min' `axeopt' `axepattern'
local g "`r(g)'"
local wys "`r(wys)'"

/* DRAW the observed lines */
if "`vlist'"~="" {
  _drawobs `vlist' , maxlevels(`maxlevels') max(`max') min(`min') `xopt' `connected'
  local go "`r(gg)'"
  return local maxarea "`r(maxarea)'"
  foreach var of local vlist {
    return local area_`var' "`r(area`var')'"
  }
}

/* DRAW the radials... lines */
if "`radial'"~="" {
  /* will need to remove the first colors, patterns and widths from lc lw and lp*/
  local nvar: list sizeof vlist
  if "`lc'"~="" {
    local te: word `=`nvar'+1' of `lc'
    local xoptlcpw "lc(`te')"
  }
  if "`lw'"~="" {
    local te: word `=`nvar'+1' of `lw'
    local xoptlcpw "`xoptlcpw' lw(`te')"
  }
  if "`lp'"~="" {
    local te: word `=`nvar'+1' of `lp'
    local xoptlcpw "`xoptlcpw' lp(`te')"
  }
  _drawradial `radial' , maxlevels(`maxlevels') max(`max') min(`min') `xoptlcpw'  
  local go "`go' `r(g)'"
}

/* LABEL */
_labels `vlab' , maxlevels(`maxlevels') max(`max') min(`min') `labsize'
forv i=1/`maxlevels' {
  local gl `"`gl' `r(g`i')'"'
}

/* LABEL axes the number part note that axelaboff  says suppress the text label of the axes numbers*/
if "`axelaboff'"=="" {
  _labelaxes `vlab' , labs(`wys') maxlevels(`maxlevels') max(`max') min(`min') `axeoptnocom'
  local gaxe `"`r(g)'"'
}

/* CREATE GRAPH */

tw `go' `g' , `legend'  `gl' `gaxe' /*
*/ legend(on)  xscale(off) ysca(off) ylab(,nogrid) note(Center is at `min') `gopt' 

//aspectratio(1)
restore
end

/************************************
 *
 * This labels the axes 
 * labs contains the y coefficient
 *
 *************************************/

pr _labelaxes, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) labs(numlist) rlabel(numlist) ]

local minlist : di %6.4f `min'
local maxlist : di %6.4f `max'
local steplist : di %7.5f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

if "`rlabel'"~="" local numberlist "`rlabel'"
else local numberlist "`minlist'(`steplist')`maxlist'"

local i 1
foreach lab of numlist `numberlist' {

  local y: word `i' of `labs'
  local y=0.98*`y'
  local y: di %6.2f `y'

  if `i++'==1 continue

  if "`rlabel'"=="" local lab: di %6.0f `lab'
  local lababs: di %6.0f abs(`lab')
  local x: di %6.2f `lababs'*sin(_pi)
  local x = trim("`x'")
  local y = trim("`y'")
  local lab = trim("`lab'")

  local g `"`g' text(`y' `x' "`lab'",si(*.6) place(n))"' 
}
return local g `"`g'"'

end

/*****************************************************
 * Places the text at the end of the spokes
 *
 *****************************************************/

pr _labels, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) SI(string)]

local minlist : di %6.4f `min'
local maxlist : di %6.4f `max'
local steplist : di %7.5f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

forv i=1/`nspokes' {
  local angle = (`i'-1)*2*_pi/`nspokes'
  local p "c"
  if `angle'>0 & `angle'<4*_pi/4 local p "e"
  if `angle'>_pi & `angle'<2*_pi local p "w"
  local lab =`varlist'[`i']
  local y = (`max'-`min')*1.05*cos(`angle')
  local x = (`max'-`min')*1.05*sin(`angle')

  local g`i' `"text(`y' `x' "`lab'", si(`si') place(`p') ) "' 
}
forv i=1/`nspokes' {
  return local g`i'=`"`g`i''"'
}

end

/*****************************************************
 * This draws the observations 
 *
 *****************************************************/

pr _drawobs, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) LC(string) LP(string) LW(string) MS(string) MC(string) CONNECTED]

local minlist : di %6.4f `min'
local maxlist : di %6.4f `max'
local steplist : di %7.5f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

if "`connected'"~="" local line "connected"
else local line "line"

local n 1
foreach v of local varlist {
  local area`v' 0 /* initiate the area to be 0*/
  local maxarea 0 /* initiate max area*/
  qui gen obsy`n'=.
  qui gen obsx`n'=.
  forv i=1/`nspokes1' {
    local angle = (`i'-1)*2*_pi/`nspokes'
    local r = `v'[`i']
    qui replace obsy`n' = (`r'-`min')*cos(`angle') in `i'
    qui replace obsx`n' = (`r'-`min')*sin(`angle') in `i'
    if (`i'>1 & `i'<`nspokes1') {   /* this part does the area under the radar*/
      local baselength = `v'[`=`i'-1'] - `min'
      if (`nspokes'>3) local height = sin(2*_pi/`nspokes')*(`r'-`min')
      else local height = sin(_pi -2*_pi/`nspokes')*(`r'-`min')
      local area`v' = `area`v'' + `baselength'*`height'/2
      if (`nspokes'>3) local maxheight = sin(2*_pi/`nspokes')*(`max'-`min')
      else local maxheight = sin(_pi -2*_pi/`nspokes')*(`max'-`min')
      local maxarea = `maxarea' + (`max'-`min')*`maxheight'/2
    }
    if (`i'==1) { /* this is the very first area but going to the left i.e. to the last spoke*/
      local baselength = `v'[`nspokes']
      if (`nspokes'>3) local height = sin(2*_pi/`nspokes')*(`r'-`min')
      else local height = sin(_pi -2*_pi/`nspokes')*(`r'-`min')
      local area`v' = `area`v'' + (`baselength'-`min')*`height'/2
      if (`nspokes'>3) local maxheight = sin(2*_pi/`nspokes')*(`max'-`min')
      else local maxheight = sin(_pi -2*_pi/`nspokes')*(`max'-`min')
      local maxarea = `maxarea' + (`max'-`min')*`maxheight'/2
    }
  }
  return local area`v' "`area`v''"
  return local maxarea "`maxarea'"
  qui replace obsy`n' = obsy`n'[1] in `nspokes1'
  qui replace obsx`n' = obsx`n'[1] in `nspokes1'

  local xopt ", cmiss(n) lw(*1.2)"
  /* Sort out the colors if they exist */
  if "`lc'"~="" {
    local con: word `n' of `lc'
    if "`con'"~="" local xopt "`xopt' lc(`con')"
  }
  if "`lp'"~="" {
    local con: word `n' of `lp'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lp(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lp(`con')"
  }
   if "`lw'"~="" {
    local con: word `n' of `lw'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lw(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lw(`con')"
  }
  if "`ms'"~="" & "`connected'"~="" {
    local con: word `n' of `ms'
    if "`xopt'"=="" & "`con'"~="" local xopt ", ms(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' ms(`con')"
  }
  if "`mc'"~="" & "`connected'"~="" {
    local con: word `n' of `mc'
    if "`xopt'"=="" & "`con'"~="" local xopt ", mc(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' mc(`con')"
  }
  local g "`g' (`line' obsy`n' obsx`n'`xopt')"
  local xopt ""
  local `n++'
}
return local gg  "`g'"

end
/*****************************************************
 * This draws the observations as single spikes
 *
 *****************************************************/

pr _drawradial, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) LC(string) LP(string) LW(string)]

local minlist : di %6.4f `min'
local maxlist : di %6.4f `max'
local steplist : di %7.5f (`max'-`min')/5
local nspokes  `maxlevels'
local nspokes1=`nspokes'+1

qui set obs `=2*`nspokes'+2'


local n 1
foreach v of local varlist { /* v is the radial variable*/
  qui gen robsy`n'=.
  qui gen robsx`n'=.
  forv i=1/`nspokes1' {
    local angle = (`i'-1)*2*_pi/`nspokes'
    local r = `v'[`i']
    qui replace robsy`n' = (`r'-`min')*cos(`angle') in `=2*`i'-1'
    qui replace robsx`n' = (`r'-`min')*sin(`angle') in `=2*`i'-1'
    qui replace robsy`n' = 0*cos(`angle') in `=2*`i''
    qui replace robsx`n' = 0*sin(`angle') in `=2*`i''
  }
  qui replace robsy`n' = robsy`n'[1] in `=2*`nspokes'+1'
  qui replace robsx`n' = robsx`n'[1] in `=2*`nspokes'+1'

  local xopt ", cmiss(n) lw(*1.2)"
  /* Sort out the colors if they exist */
  if "`lc'"~="" {
    local con: word `n' of `lc'
    if "`con'"~="" local xopt "`xopt' lc(`con')"
  }
  if "`lp'"~="" {
    local con: word `n' of `lp'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lp(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lp(`con')"
  }
   if "`lw'"~="" {
    local con: word `n' of `lw'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lw(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lw(`con')"
  }
 local g "`g' (line robsy`n' robsx`n'`xopt')"
  local xopt ""
  local `n++'
}
return local g  "`g'"

end

/*****************************************************
 * Draw the axes lines 
 *
 *****************************************************/

pr _buildaxes, rclass
syntax [anything] [, rlabel(numlist) *]

local gopt "`options'"

/* This step gets the 3 arguments into some macros */
local i 1
foreach arg of local anything {
  if `i'==1 local nspokes "`arg'"
  if `i'==2 local max "`arg'" 
  if `i++'==3 local min "`arg'"
}
/* if there is a comma instead of decimal point leave it well alone */
if "`c(dp)'"=="comma" {
  local minlist "`min'"
  local maxlist "`max'"
  local steplist =(`max'-`min')/5

}
/* otherwise formatting the labels */
else {
  local minlist : di %6.4f `min'
  local maxlist : di %6.4f `max'
  local steplist : di %7.5f (`max'-`min')/5 /* default 5 weblines if rlabel not specified*/
}

local nspokes = `nspokes'
local nspokes1=`nspokes'+1

qui set obs `nspokes1'

qui gen wy=.
qui gen wx=.
qui gen wy0=0
qui gen wx0=0

/* Either use default steplist or use the rlabel */
local numberlist "`minlist'(`steplist')`maxlist' `maxlist'"  /* Add in maxlist as sometimes it is missed.. rounding problems*/
if "`rlabel'"~="" local numberlist "`rlabel'"

local n 1
foreach max of numlist `numberlist' {  /* looping over each level to draw the circular axes */
  qui gen ay`n'=.
  qui gen ax`n'=.
  forv i=1/`nspokes1' {                                            /* no spokes +1 to link them all together*/
    local angle = (`i'-1)*2*_pi/`nspokes'                          /*angle of each spoke position*/
    qui replace ay`n' = (`max'-`minlist')*cos(`angle') in `i'       /* max is the element of numberlist*/
    qui replace ax`n' = (`max'-`minlist')*sin(`angle') in `i'
    if `n'==1 & `i'~=`nspokes1' {
      qui replace wy = (`maxlist'-`minlist')*cos(`angle') in `i'     /* This is the maximum just to make sure it is drawn */
      qui replace wx = (`maxlist'-`minlist')*sin(`angle') in `i'
    }
  }
  qui su ay`n'
  local wys "`wys' `r(min)'"                               /* This looks like a check on the minimums for each y coord on graph data variable*/
  local g "`g' (line ay`n' ax`n', `gopt')"
  local `n++'
}
return local g "`g' (pcspike wy wx wy0 wx0, `gopt')"
return local wys  "`wys'"
end
