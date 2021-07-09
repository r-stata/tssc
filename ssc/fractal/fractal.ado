*! version 1.0 P.MILLAR 22Jul2012 
*! version 1.1 P.MILLAR 02Aug2012 added probabilistic shapes 
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005-2008 Paul Millar

program define fractal, rclass byable(recall)
  version 12.0
  syntax [anything] , [HShape(numlist sort min=3) VShape(numlist min=3) HRange(numlist sort min=2) VRange(numlist sort min=2) ITer(integer 1) KEEPVars SAVEGraph HSHAPE2(numlist sort min=3) VSHAPE2 (numlist min=3) PROB2(real 0) HSHAPE3(numlist sort min=3) VSHAPE3(numlist min=3) PROB3(real 0) ] 

tempvar x y

if `iter' <1 {
  di as error "Number of iterations must be at least 1"
  exit
  }

/* default Hrange and Vrange */
if "`hrange'" == "" {
  local hrange="0 100"
  }
if "`vrange'" == "" {
  local vrange="0 100"
  }

/* ----------------------------------------- */
/* deal with the probabilities of each shape */
/* ----------------------------------------- */
local nshapes=1
local sprob2=0
if "`prob2'" != "" {
  local sprob2=`prob2'
  if `sprob2' <0 | `sprob2' > 1 {
    di as error "PROB2 must be between 0 and 1"
    exit
    }
  local nshapes =`nshapes' + 1
  }
local sprob3=0
if "`prob3'" != "" {
  local sprob3=`prob3'
  if `sprob3' <0 | `sprob3' > 1 {
    di as error "PROB3 must be between 0 and 1"
    exit
    }
  local nshapes =`nshapes' + 1
  }
local prob23=`sprob2' + `sprob3'
if `prob23' > 1 {
  di as error "The sum of PROB2 and PROB3 must be less than 1"
  exit
  }
local sprob1=1-`prob23'
local plevel1=`sprob1'
local plevel2=`plevel1'+`sprob2'
local plevel3=`plevel2'+`sprob3'


/* find number of horizontal points (initial shape) */
tokenize `hshape'
local word="`1'"
local nhpoints=1
while "`word'" !="" {
  local hpoint`nhpoints'="`word'"
  local nhpoints=`nhpoints'+1
  local word="``nhpoints'+1'"
  }
local nhpoints=`nhpoints'-1
if `nhpoints' < 2 {
  di as error "No shape specified"
  exit
  }

/* find number of vertical points (initial shape) */
tokenize `vshape'
local word="`1'"
local nvpoints=1
while "`word'" !="" {
  local vpoint`nvpoints'="`word'"
  local nvpoints=`nvpoints'+1
  local word="``nvpoints'+1'"
  }
local nvpoints=`nvpoints'-1
local nsegs=`nvpoints'-1
/* standardize vertical scale */
forvalues i=1/`nvpoints' {
  local vpoint`i'=`vpoint`i''/`vpoint`nvpoints''
  }

if `nhpoints' != `nvpoints' {
 di as error "Number of points in the horizontal shape must be the same as the number of points in the vertical shape"
 exit
 }

local nsegs1=`nsegs'
local nh1points=`nhpoints'
forvalues i=1/`nh1points' {
  local h1point`i'=`hpoint`i''
  local v1point`i'=`vpoint`i''
  }


/* --------------- */
/* process shape 2 */
/* --------------- */
tokenize `hshape2'
local word="`1'"
local nh2points=1
while "`word'" !="" {
  local h2point`nh2points'="`word'"
  local nh2points=`nh2points'+1
  local word="``nh2points'+1'"
  }
local nh2points=`nh2points'-1
tokenize `vshape2'
local word="`1'"
local nv2points=1
while "`word'" !="" {
  local v2point`nv2points'="`word'"
  local nv2points=`nv2points'+1
  local word="``nv2points'+1'"
  }
local nv2points=`nv2points'-1
local nsegs2=`nv2points'-1
/* standardize vertical scale */
forvalues i=1/`nv2points' {
  local v2point`i'=`v2point`i''/`v2point`nv2points''
  }

/* --------------- */
/* process shape 3 */
/* --------------- */
tokenize `hshape3'
local word="`1'"
local nh3points=1
while "`word'" !="" {
  local h3point`nh3points'="`word'"
  local nh3points=`nh3points'+1
  local word="``nh3points'+1'"
  }
local nh3points=`nh3points'-1
tokenize `vshape3'
local word="`1'"
local nv3points=1
while "`word'" !="" {
  local v3point`nv3points'="`word'"
  local nv3points=`nv3points'+1
  local word="``nv3points'+1'"
  }
local nv3points=`nv3points'-1
local nsegs3=`nv3points'-1
forvalues i=1/`nv3points' {
  local v3point`i'=`v3point`i''/`v3point`nv3points''
  }


/* decode the Hrange (same for all shapes) */
tokenize `hrange'
local hmin="`1'"
local hmax="`2'"
local hlength=`hmax' - `hmin'

/* decode the Vrange */
tokenize `vrange'
local vmin="`1'"
local vmax="`2'"
local vlength=`vmax' - `vmin'

qui gen `x'=.
qui gen `y'=.


/* ------------------------------------------------------------ */
/* make sure there are enough cases to cover all the iterations */
/* ------------------------------------------------------------ */
local maxpoints=0
forvalues i=1/`nshapes' {
  if `nh`i'points' > `maxpoints' {
    local maxpoints=`nh`i'points'
    }
  }
local newobs=((`maxpoints'-1)^(`iter'))+1
local oldobs=_N
// di "maxpoints=`maxpoints', newobs=`newobs', oldobs=`oldobs'"
if `newobs' > _N {
  qui set obs `newobs'
  }

/* --------------- */
/* first iteration */
/* --------------- */
local nsegs=`nhpoints'-1
local xlength=`hlength'
local ylength=`vlength'

forvalues i=1/`nhpoints' {
 qui replace `x'=`hmin' + `hpoint`i'' * `xlength' in `i'
 qui replace `y'=`vmin' + `vpoint`i'' * `ylength' in `i'
 }

/* save the results of first iteration if asked to do so */
if "`keepvars'"=="keepvars" {
  capture qui gen _frctlx1=.
  if _rc !=0 {
    qui drop _frctlx1
    qui gen _frctlx1=.
    }
  capture qui gen _frctly1=.
  if _rc != 0 {
    qui drop _frctly1
    qui gen _frctly1=.
    }
  qui replace _frctlx1=`x'
  qui replace _frctly1=`y'
  }

if "`savegraph'" == "savegraph" {
  line `y' `x', ytitle("Y") xtitle("X")
  qui graph save _frctl1,replace
  }
local i=`nsegs'+1

/* -------------------------------- */
/* second and subsequent iterations */
/* -------------------------------- */
forvalues iter8=2/`iter' {
   local nsegs= `i'-1
// di "--------->iter8=`iter8', nsegs=`nsegs', i=`i'"


  forvalues seg=1/`nsegs' {
// di "=====>iter8=`iter8', seg=`seg'"
    local j=`seg'
    local k=`seg'+1
    local curxmin=`x' in `j'
    local curxmax=`x' in `k'
    local curxlength=`curxmax' - `curxmin'
    local curymin=`y' in `j'
    local curymax=`y' in `k'
    local curylength=`curymax' - `curymin'
// di "      curxmin=`curxmin', curxmax=`curxmax', curxlength=`curxlength'"
// di "      curymin=`curymin', curymax=`curymax', curylength=`curylength'"

/* choose the shape to insert */
    local rand=runiform()
    if `rand' < `plevel1' {
      local shapeno = 1
      }
    else if `rand' < `plevel2' {
      local shapeno = 2
      }
    else {
      local shapeno = 3
      }
 
// di "rand=`rand', plevel1=`plevel1', plevel2=`plevel2', plevel3=`plevel3', shape=`shapeno'

    local ncalcs=`nh`shapeno'points'-1
    forvalues point=2/`ncalcs' {
      local i=`i' +1
//      local newx=`curxmin' + `h`shapeno'point`point'' * `curxlength'
//      local newy=`curymin' + `v`shapeno'point`point'' * `curylength'
// di "      i=`i', newx=`newx', newy=`newy'"
      qui replace `x'=`curxmin' + `h`shapeno'point`point'' * `curxlength' in `i'
      qui replace `y'=`curymin' + `v`shapeno'point`point'' * `curylength' in `i'
      }
    }

  sort `x'

/* save the results of this iteration if asked to do so */
  if "`keepvars'"=="keepvars" {
    capture qui gen _frctlx`iter8'=`x'
    if _rc!=0 {
      qui drop _frctlx`iter8'
      qui gen  _frctlx`iter8'=`x'
      }
    capture qui gen _frctly`iter8'=`y'
    if _rc!=0 {
      qui drop _frctly`iter8'
      qui gen  _frctly`iter8'=`y'
      }
    }

  if "`savegraph'" == "savegraph" {
    line `y' `x' , ytitle("Y") xtitle("X")
    qui graph save _frctl`iter8', replace
    }

  local nsegs=(`nh`shapeno'points'-1)*`nsegs'
// di "      end of loop, nsegs=`nsegs'"
  }
/* end of loop */


capture qui gen _frctlx=`x'
if _rc !=0 {
  qui drop _frctlx
  qui gen _frctlx=`x'
  }
qui label var _frctlx "X values of fractal"

capture qui gen _frctly=`y'
if _rc != 0 {
  qui drop _frctly
  qui gen _frctly=`y'
  }
qui label var _frctly "Y values of fractal"

/* ---------------------------- */
/* Remove unneeded observations */
/* ---------------------------- */
qui summ _frctlx
local curobs=r(N)
local bign=_N
if `curobs' < _N {
  if `oldobs' > `curobs' {
    qui drop in `oldobs'/`bign'
    }
  else {
    qui drop in `curobs'/`bign'
    }
  }

di " "
di as result "Fractal generated with `iter' iterations"
if "`savegraph'" == "savegraph" {
  di "To display list of graphs type -graph dir-"
  }
di " "

end


