*! Date    : 12 Jan 2005
*! Version : 1.33
*! Author  : Adrian Mander
*! Email   : adrian.p.mander@gsk.com

program define surface7
preserve
version 7.0
local varlist "ex min(3) max(3)"
local options "SAVING(string) Box(string) EYE(string) ROUND(int 5) LABELRND(real 0.01) ORIENT(string) XLABel(string) YLABel(string) ZLAB(string) NOWIRE XTITLE(string) YTITLE(string) ZTITLE(string)"
parse "`*'"
parse "`varlist'", parse(" ")

local x `1'
local y `2'
local z `3'

if "`xtitle'"=="" { local xtitle "X-axis" }
if "`ytitle'"=="" { local ytitle "Y-axis" }
if "`ztitle'"=="" { local ztitle "Z-axis" }

if "`orient'"=="" {
  local orient = "xyz"
}
else {
  if "`orient'"=="xyz" | "`orient'"=="xzy" | "`orient'"=="yxz" | "`orient'"=="yzx" | "`orient'"=="zxy" | "`orient'"=="zyx" { }
  else {
    di in red "orient must contain one of the following strings xyz, xzy, yxz, yzx,zxy,zyx"
    di in red "Re-setting orient to xyz"
    local orient = "xyz"
  }
}

/* Set up graph box variables

	leftx			rightx
topy	-------------------------
	|			|
	|			|
height	|			|
	|			|
	|			|
	|			|
boty	-------------------------
	<-	width		->
*/

global max_by=23063
global max_rx=32000

global topy=2000
global boty=21000
global leftx=3500
global rightx=30000
global width=$rightx-$leftx
global height=$boty-$topy

if "`box'" ~= "" {
  parse "`box'", parse(",")
  if(`1'<2000) {
    di "WARNING Bounding box wrong top y `1'<2000"
    exit(666)
  }
  if(`3'>21000) {
    di "WARNING Bounding box wrong bottom y `3'>21000"
    exit(666)
  }
  if(`5'<3500) {
    di "WARNING Bounding box wrong left x `5'<3500"
    exit(666)
  }
  if(`7'>30000) {
    di "WARNING Bounding box wrong right x `7'>30000"
    exit(666)
  }
  if(`1'>=`3' | `5'>=`7') {
    di "WARNING Bounding box wrong Is `1'>=`3'? OR is `5'>=`7'?"
    exit(666)
  }
  else {
    global topy=`1'
    global boty=`3'
    global leftx=`5'
    global rightx=`7'
    global width=$rightx-$leftx
    global height=$boty-$topy
  }
}

/* GET data in a square data set ready for drawing */

sq_dat `x' `y' `z', round(`round')

/*
 * Calculate all the x y z data lengths
 */

mat origin = J(1,2,0)
mat origin[1,1]=16000
mat origin[1,2]=12000

qui summ `y'
global dly = _result(5)
global dry = _result(6)
qui summ `x'
global dlx = _result(5)
global drx = _result(6)
qui summ `z'
global dlz = _result(5)
global drz = _result(6)

mat xdir = J(1,2,0)
mat ydir = J(1,2,0)
mat zdir = J(1,2,0)

/* Just initialise x/y/z dir matrices */

eyeball, orient(`orient')

global scalex = 1
global scaley = 1

chek_box 1

/* di "Scaling  $scaley  $scalex" */

if $scaley~=1 | $scalex ~= 1 {
  mat xdir[1,1] = $scalex*xdir[1,1]
  mat ydir[1,1] = $scalex*ydir[1,1]
  mat zdir[1,1] = $scalex*zdir[1,1]
  mat xdir[1,2] = $scaley*xdir[1,2]
  mat ydir[1,2] = $scaley*ydir[1,2]
  mat zdir[1,2] = $scaley*zdir[1,2]
}

chek_box 2

/*****************************************
 * Saving the file or not.
 * NB if file exists it is deleted!!
 *****************************************/

if ("`saving'"~="") {
  gph open, saving(`saving')
}
else { gph open }

draw_axe
global labrnd= `labelrnd'

lab_axe , xtitle(`xtitle') ytitle(`ytitle') ztitle(`ztitle')

gph pen 2

if "`nowire'"~="" {
  local i 1
  while `i' <= _N {
    draw_pt `x'[`i'] `y'[`i'] `z'[`i'] 
    local i=`i'+1
  }
}
else {
  if "`orient'"=="zxy" {
    draw_wis `x' `y' `z', orient(`orient')
  }
  else {
    draw_wis `x' `y' `z'
  }
}

gph close

restore
end

/* This works out the perspective.. used to be that you could change the eyeball position
 * to anywhere but it morphed the axes box 
 */

program define eyeball
local options "ORIENT(string) "
parse "`*'"

local string1 = substr("`orient'",-3,1)
local string2 = substr("`orient'",-2,1)
local string3 = substr("`orient'",-1,1)

mat `string1'dir[1,1] = 1
mat `string1'dir[1,2] =0
mat `string2'dir[1,1] = -0.5
mat `string2'dir[1,2] = 0.5
mat `string3'dir[1,1] = 0
mat `string3'dir[1,2] = -1

end

program define draw_axe

/* horizontal boxe lines */

gph pen 1
gph line $pt1y $pt1x $pt2y $pt2x
gph line $pt1y $pt1x $pt3y $pt3x
gph line $pt1y $pt1x $pt5y $pt5x
gph line $pt2y $pt2x $pt4y $pt4x
gph line $pt2y $pt2x $pt6y $pt6x
gph line $pt3y $pt3x $pt7y $pt7x
gph line $pt3y $pt3x $pt4y $pt4x
gph line $pt4y $pt4x $pt8y $pt8x
gph line $pt5y $pt5x $pt6y $pt6x
gph line $pt5y $pt5x $pt7y $pt7x
gph line $pt6y $pt6x $pt8y $pt8x
gph line $pt7y $pt7x $pt8y $pt8x

end

/* Translate the x y z to the 2-D dimension and plot that point */

program define draw_pt

local x1= origin[1,1] + (`1'-$dlx)*xdir[1,1] +(`2'-$dly)*ydir[1,1]
local y1 = origin[1,2] + (`2'-$dly)*ydir[1,2] + (`1'-$dlx)*xdir[1,2]
local x2 = `x1' + (`3'-$dlz)*zdir[1,1]
local y2 = `y1'+ (`3'-$dlz)*zdir[1,2]


gph line `y1' `x1' `y2' `x2'
gph point `y2' `x2' 150 4

end

/* Draw the wirefram translating the Z-axis to the 2-D image */

program define draw_wis
local varlist "ex min(3) max(3)"
local options "ORIENT(string) "
parse "`*'"
parse "`varlist'", parse(" ")

local x `1'
local y `2'
local z `3'

sort `x' `y'

tempvar yy1 yy2 xx1

gen `yy1' =0
gen `yy2'=0
qui gen `xx1' = 0

local i 1
while `i'<=rowsof(xlines) {

/* hold x and draw along y */
 
  qui replace `yy1' = cond(`x'[_n]==xlines[`i',1], origin[1,2] + (`y'[_n]-$dly)*ydir[1,2] + (`x'[_n]-$dlx)*xdir[1,2] +(`z'[_n]-$dlz)*zdir[1,2], 0)
  qui replace `xx1' = cond(`x'[_n]==xlines[`i',1], origin[1,1] + (`y'[_n]-$dly)*ydir[1,1] + (`x'[_n]-$dlx)*xdir[1,1]+(`z'[_n]-$dlz)*zdir[1,1], 0)
  gph vline `yy1' `xx1' if `yy1'~=0

  local i = `i'+1

}
local i 1
while `i'<=rowsof(ylines) {

/* hold x and draw along y */

  qui replace `yy1' = cond(`y'[_n]==ylines[`i',1], origin[1,2] + (`y'[_n]-$dly)*ydir[1,2] + (`x'[_n]-$dlx)*xdir[1,2] +(`z'[_n]-$dlz)*zdir[1,2], 0)
  qui replace `xx1' = cond(`y'[_n]==ylines[`i',1], origin[1,1] + (`y'[_n]-$dly)*ydir[1,1] + (`x'[_n]-$dlx)*xdir[1,1]+(`z'[_n]-$dlz)*zdir[1,1], 0)
  gph vline `yy1' `xx1' if `yy1'~=0

  local i = `i'+1
}

end

/************************************
 * To scale up the axes
 ************************************/

program define chek_box

/* need more options

 8 pts to a cube take 1 as origin

         3        4  
	 ________
	/	/
       /       /
      /       /
     ---------
    1        2

*/

local i 1
while `i'<9 {
  matrix pt`i' = J(1,2,0)
  local i=`i'+1
}

/* Fix lengths of x,y and z directions */

if "`1'"=="1" {
  local x1 = ($drx-$dlx)*xdir[1,1]
  local x2 = ($drx-$dlx)*xdir[1,2]
  local z1 = ($drz-$dlz)*zdir[1,1]
  local z2 = ($drz-$dlz)*zdir[1,2]
  local y1 = ($dry-$dly)*ydir[1,1]
  local y2 = ($dry-$dly)*ydir[1,2]
  if `x1'~=0 { mat xdir[1,1] = xdir[1,1]*abs(16000/`x1') }
  if `x2'~=0 { mat xdir[1,2] = xdir[1,2]*abs(11000/`x2') }
  if `y1'~=0 { mat ydir[1,1] = ydir[1,1]*abs(14000/`y1') }
  if `y2'~=0 { mat ydir[1,2] = ydir[1,2]*abs(10000/`y2') }
  if `z2'~=0 { mat zdir[1,2] = zdir[1,2]*abs(12000/`z2') }
  if `z1'~=0 { mat zdir[1,1] = zdir[1,1]*abs(15000/`z1') }
}

local x1 = ($drx-$dlx)*xdir[1,1]
local x2 = ($drx-$dlx)*xdir[1,2]
local z1 = ($drz-$dlz)*zdir[1,1]
local z2 = ($drz-$dlz)*zdir[1,2]
local y1 = ($dry-$dly)*ydir[1,1]
local y2 = ($dry-$dly)*ydir[1,2]

mat pt1[1,1]=origin[1,1]
mat pt1[1,2]=origin[1,2]
mat pt2[1,1]=origin[1,1]+ `x1' 
mat pt2[1,2]=origin[1,2]+ `x2'
mat pt3[1,1]=origin[1,1]+ `z1' 
mat pt3[1,2]=origin[1,2]+ `z2'
mat pt4[1,1]=origin[1,1]+ `z1'+ `x1' 
mat pt4[1,2]=origin[1,2]+ `z2'+ `x2' 
mat pt5[1,1]=origin[1,1]+ `y1'
mat pt5[1,2]=origin[1,2]+ `y2'
mat pt6[1,1]=origin[1,1]+ `x1' + `y1'
mat pt6[1,2]=origin[1,2]+ `x2' + `y2'
mat pt7[1,1]=origin[1,1]+ `z1' + `y1'
mat pt7[1,2]=origin[1,2]+ `z2' + `y2'
mat pt8[1,1]=origin[1,1]+ `z1' + `y1' + `x1'
mat pt8[1,2]=origin[1,2]+ `z2' + `y2' + `x2'

qui minax_8 1
global rbx= $S_max
global lbx = $S_min
qui minax_8 2
global tby= $S_min
global bby = $S_max

if "`1'"=="1" {
  local frame=4000
  global scalex = ($max_rx-`frame')/($rbx-$lbx)
  global scaley = ($max_by-`frame')/($bby-$tby)
  mat origin[1,1]=int((origin[1,1]-$lbx)*$scalex)+3*`frame'/4
  mat origin[1,2]=int((origin[1,2]-$tby)*$scaley)+`frame'/2
}

end

/************************************************
 * Label axes
 ************************************************/

program define lab_axe
syntax [varlist] [,XTITLE(string) YTITLE(string) ZTITLE(string)]
minax_9 

gph pen 1

/* X-Axis */
local labopt " xtitle(`xtitle') ytitle(`ytitle') ztitle(`ztitle')"

if xdir[1,2]== 0 { labxyz, dirx(x) `labopt' }
if ydir[1,2]== 0 { labxyz, dirx(y) `labopt' }
if zdir[1,2]== 0 { labxyz, dirx(z) `labopt' }

if xdir[1,1]== 0 {
  labxyz, dirz(x) `labopt'
  if xdir[1,2]~= 0 & xdir[1,1]~= 0{ labxyz, diry(x x) `labopt' }
  if ydir[1,2]~= 0 & ydir[1,1]~= 0{ labxyz, diry(x y) `labopt' }
  if zdir[1,2]~= 0 & zdir[1,1]~= 0{ labxyz, diry(x z)  `labopt'}
}
if ydir[1,1]== 0 {
  labxyz, dirz(y) `labopt'
  if xdir[1,2]~= 0 & xdir[1,1]~= 0{ labxyz, diry(y x)  `labopt'}
  if ydir[1,2]~= 0 & ydir[1,1]~= 0{ labxyz, diry(y y)  `labopt'}
  if zdir[1,2]~= 0 & zdir[1,1]~= 0{ labxyz, diry(y z)  `labopt'}
}
if zdir[1,1]== 0 {
  labxyz, dirz(z) `labopt'
  if xdir[1,2]~= 0 & xdir[1,1]~= 0{ labxyz, diry(z x) `labopt' }
  if ydir[1,2]~= 0 & ydir[1,1]~= 0{ labxyz, diry(z y) `labopt' }
  if zdir[1,2]~= 0 & zdir[1,1]~= 0{ labxyz, diry(z z) `labopt' }
}

end

/* Do the axis labelling */

program define labxyz
local options "DIRX(string) DIRZ(string) DIRY(string) XTITLE(string) YTITLE(string) ZTITLE(string)"
parse "`*'"


if "`dirx'"~="" {
  local dr = "dr`dirx'"
  local dl = "dl`dirx'"
  local y1 = pt$blcpt[1,2]+($`dr'-$`dl')*`dirx'dir[1,2] + 1000
  local x1 = pt$blcpt[1,1]+($`dr'-$`dl')*`dirx'dir[1,1]/2
/*  local text = "`dirx'-axis" */
   local text "``dirx'title'"

  gph text `y1' `x1' 0 0 `text'

  local sty = pt$blcpt[1,2]
  local stx = pt$blcpt[1,1]
  local endy = pt$blcpt[1,2]+($`dr'-$`dl')*`dirx'dir[1,2]
  local endx = pt$blcpt[1,1]+($`dr'-$`dl')*`dirx'dir[1,1]

  ticks, line(`sty' `stx' `endy' `endx') dirx(`dirx')
}
if "`dirz'"~="" {
  local dr = "dr`dirz'"
  local dl = "dl`dirz'"
  local y1 = pt$blcpt[1,2]+($`dr'-$`dl')*`dirz'dir[1,2]/2 + 1000
  local x1 = pt$blcpt[1,1]+($`dr'-$`dl')*`dirz'dir[1,1]- 1000
/*  local text = "`dirz'-axis"*/
  local text  "``dirz'title'"

  gph text `y1' `x1' 0 0 `text'
  local sty = pt$blcpt[1,2]
  local stx = pt$blcpt[1,1]
  local endy = pt$blcpt[1,2]+($`dr'-$`dl')*`dirz'dir[1,2]
  local endx = pt$blcpt[1,1]+($`dr'-$`dl')*`dirz'dir[1,1]

  ticks, line(`sty' `stx' `endy' `endx') dirz(`dirz')
}
if "`diry'"~="" {
  parse "`diry'", parse(" ")
  local dr1 = "dr`1'"
  local dl1 = "dl`1'"
  local dr2 = "dr`2'"
  local dl2 = "dl`2'"
  local y2 = pt$blcpt[1,2]+($`dr1'-$`dl1')*`1'dir[1,2]-($`dr2'-$`dl2')*`2'dir[1,2]/2-1000
  local x2 = pt$blcpt[1,1]+($`dr1'-$`dl1')*`1'dir[1,1]-($`dr2'-$`dl2')*`2'dir[1,1]/2-2000
/*  local text = "`2'-axis" */
  local text = "``2'title'"

  gph text `y2' `x2' 0 0 `text'

  local sty = pt$blcpt[1,2]+($`dr1'-$`dl1')*`1'dir[1,2]
  local stx = pt$blcpt[1,1]+($`dr1'-$`dl1')*`1'dir[1,1]
  local endy = pt$blcpt[1,2]+($`dr1'-$`dl1')*`1'dir[1,2]-($`dr2'-$`dl2')*`2'dir[1,2]
  local endx = pt$blcpt[1,1]+($`dr1'-$`dl1')*`1'dir[1,1]-($`dr2'-$`dl2')*`2'dir[1,1]

  ticks, line(`sty' `stx' `endy' `endx') diry(`2')
}	
end

/************************************************
 * Draw in all the ticks.....
 ************************************************/

program define ticks
local options "DIRX(string) DIRZ(string) DIRY(string) LINE(string)"
parse "`*'"

parse "`line'", parse(" ")

if "`dirx'"~="" {
  local dr = "dr`dirx'"
  local dl = "dl`dirx'"
  local y1 = `1'
  local x1 = `2'
  local y2 = `1'+300
  local text : di %9.3f $`dl'
  gph line `y1' `x1' `y2' `x1'
  local y2 =`y2'+700
  gph text `y2' `x1' 0 0 `text'
  local dr = "dr`dirx'"
  local dl = "dl`dirx'"
  local y1 = `3'
  local x1 = `4'
  local y2 = `3'+300
  local text : di %9.3f $`dr'
  gph line `y1' `x1' `y2' `x1'
  local y2 =`y2'+700
  gph text `y2' `x1' 0 0 `text'
}
if "`dirz'"~="" {
  local dr = "dr`dirz'"
  local dl = "dl`dirz'"
  local y1 = `1'
  local x1 = `2'
  local x2 = `2'-400
  local text :di %9.3f $`dl'
  gph line `y1' `x1' `y1' `x2'
  local x2 =`x2'-400
  gph text `y1' `x2' 0 1 `text'
  local dr = "dr`dirz'"
  local dl = "dl`dirz'"
  local y1 = `3'
  local x1 = `4'
  local x2 = `4'-400
  local text : di %9.3f $`dr'
  gph line `y1' `x1' `y1' `x2'
  local x2 =`x2'-400
  gph text `y1' `x2' 0 1 `text'
}
if "`diry'"~="" {
  local dr = "dr`diry'"
  local dl = "dl`diry'"
  local y1 = `1'
  local x1 = `2'
  local y2 = `1'-300
  local text : di %9.3f $`dr'
  gph line `y1' `x1' `y2' `x1'
  local y2 =`y2'-700
  gph text `y2' `x1' 0 0 `text'
  local dr = "dr`diry'"
  local dl = "dl`diry'"
  local y1 = `3'
  local x1 = `4'
  local y2 = `3'-300
  local text : di %9.3f $`dl'
  gph line `y1' `x1' `y2' `x1'
  local y2 =`y2'-600
  gph text `y2' `x1' 0 0 `text'
}


end

/************************************************
 * find the number of macros
 ************************************************/

program define macno

global macn=0
global last=0
local tmp_str ""
local tmp_str "`2'"
parse "`1'", parse("`2'")

while "`1'"~="" {
  while "`1'"=="`tmp_str'" {
    mac shift
    global last = $last+1
  }
  global macn = $macn+1
  mac shift
  global last= $last+1
}

end

/************************************************
 * This checks the state of the data and sees if 
 * it can fit it in a squarer grid.
 *
 ************************************************/

program define sq_dat
version 5.0
local varlist "ex min(3) max(3)"
local options "ROUND(int 5)"
parse "`*'"
parse "`varlist'", parse(" ")

tempname xx yy

local error 0
sort `1' 
cap unique `1'
if _rc==908 { 
  di in red "ERROR set matsize higher" 
  exit(908)
}
if _rc~=0 {
  di "problem with variable `1'"
  error _rc
}
if _rc==0 {
  mat xlines = resp
}
else {
  local error=_rc
}
sort `2'
cap unique `2'
if _rc==908 { 
  di in red "ERROR set matsize higher" 
  exit(908)
}
if _rc~=0 {
  di "problem with variable `2'"
  error _rc
}
if _rc==0 {
  mat ylines = resp
}
else {
  local error=_rc+`error'
}
sort `1' `2'

local manyx = sqrt(2*_N)
if rowsof(xlines)>`manyx' | `error'>0 {
  di in red "WARNING the x-variable contains too many unique values attempting to round"
  qui summ `1'
  local rnd = `round'*(_result(6)-_result(5))/_N
  qui gen `xx' = round(`1',`rnd')
  drop `1'
  rename `xx' `1'
  cap unique `1'
  if _rc==908 { 
    di in red "ERROR set matsize higher OR increase the round() value" 
    exit(908)
  }
  mat xlines = resp
}

local manyy = sqrt(2*_N)
if rowsof(ylines)>`manyy' | `error'>0 {
  di in red "WARNING the y-variable contains too many unique values attempting to round"
  qui summ `2'
  local rnd = `round'*(_result(6)-_result(5))/_N
  gen `yy' = round(`2',`rnd')
  drop `2'
  rename `yy' `2'
  cap unique `2'
  if _rc==908 { 
    di in red "ERROR set matsize higher OR increase the round() value" 
    exit(908)
  }
  mat ylines = resp
}

end

/************************************************
 * Take the 8 vertices of the cube and try and 
 * find the extremes in each direction.
 ************************************************/

program define minax_8
local ind `1'
local inde = mod(`ind',2)+1

local min = 99999999
local max = -99999999
local maxpti`ind' = 0
local minpti`ind' = 0

local i=1
while `i'<9 {
  if `min'>=pt`i'[1,`ind'] {
    if `min'==pt`i'[1,`ind'] {
      if pt`i'[1,`inde'] < pt`minpti`ind''[1,`inde'] &  `ind'==2 {
        local minpti`ind' = `i'
	local min=pt`i'[1,`ind']
      }
      if pt`i'[1,`inde'] < pt`minpti`ind''[1,`inde'] &  `ind'==1 {
        local minpti`ind' = `i'
        local min=pt`i'[1,`ind']
      }
    }
    if abs(`min'-pt`i'[1,`ind'])>0.0001 {
      local min=pt`i'[1,`ind']
      local minpti`ind' = `i'
    }
  }
	if `max'<=pt`i'[1,`ind'] {
		if `max'==pt`i'[1,`ind'] {
			if pt`i'[1,`inde'] < pt`maxpti`ind''[1,`inde'] {
				local maxpti`ind' = `i'
			}
		}
		else {
			local max=pt`i'[1,`ind']
			local maxpti`ind' = `i'
		}
	}
	if `ind'==1 {
		global pt`i'x = pt`i'[1,`ind']
	}
	else {
		global pt`i'y = pt`i'[1,`ind']
	}
local i=`i'+1
}

if `ind'==1 {
  global maxpti1 = `maxpti`ind''
  global minpti1 = `minpti`ind''
}
else {
  global maxpti2 = `maxpti`ind''
  global minpti2 = `minpti`ind''
}
global S_min=`min'
global S_max=`max'

end


/* Botttom left corner and work from there */

program define minax_9

local minx = pt1[1,1]
local minpt = 1

global blcpt =1

local i=2
while `i'<9 {

	if abs(`minx'-pt`i'[1,1])<0.00001 | `minx'> pt`i'[1,1]{
		if abs(`minx'-pt`i'[1,1])<0.00001 {
			if pt`i'[1,2] > pt`minpt'[1,2] {
				local minpt = `i'
				local minx=pt`i'[1,1]
			}
		}
		else {
			local minpt = `i'
			local minx=pt`i'[1,1]
		}
	}
local i=`i'+1
}

global blcpt = `minpt'

end

/************************************************
 * Take the 3 directions and try and 
 * find the extremes in each direction.
 ************************************************/

program define minax_3
local ind `1'

local min = 99999999
local max = -99999999
global maxdir`ind' = "q"
global mindir`ind' = "q"

local dir = "x"

local i=1

while `i'<=3 {
	local dr = "dr`dir'"
	local dl = "dl`dir'"
	if `min'>($`dr'-$`dl')*`dir'dir[1,`ind'] {
		local min = ($`dr'-$`dl')*`dir'dir[1,`ind']
		global mindir`ind' = "`dir'"
	}
	if `max'< ($`dr'-$`dl')*`dir'dir[1,`ind'] {
		local max = ($`dr'-$`dl')*`dir'dir[1,`ind']
		global maxdir`ind' = "`dir'"
	}

if "`dir'"=="x" {
	local dir = "y"
}
else {
	local dir = "z"
}
local i=`i'+1
}

end


program define unique
    version 5.0
    local varlist "req ex min(1) max(1)"
    parse "`*'"
    parse "`varlist'", parse(" ")
    local var `1'

preserve
sort `var'
qui by `var': keep if _n==1
global S_1=_N
qui drop if `var'==.
global S_2=_N
mkmat `var', matrix(resp)
restore

end


