program define maforest

version 7.0
preserve

#delimit ;
syntax varlist(min=2 max=2 numeric) [if] [in],
     [XMIN(real 0.0) XMAX(real 0.0) sortby(varlist) 
     xtics(numlist ascending) ci(real 1)
     col1(string) col2(string) col1lbl(string) col2lbl(string)
     xlabel(string) logxaxis font(string) mean(string)
     leftside(string) rightside(string)];
#delimit cr

tokenize `varlist'
marksample touse
qui keep if `touse'

if `"`sortby'"'!="" {
     qui sort `sortby'
     }

di `ci'
di "here1"
/* create confidence intervals */
tempvar ylci yuci _w _v z
if `ci'==1 {
di "here2"
qui g `ylci' = `1' - 1.959964 * `2'
qui g `yuci' = `1' + 1.959964 * `2'
}
else if `ci'!=1 {
scalar `z' = invnorm(1 - (1-`ci')/2)
di `z'
qui g `ylci' = `1' - `z' * `2'
qui g `yuci' = `1' + `z' * `2'
}

/* allow user to specify xaxis tics */
local i 0
foreach tck of local xtics {
     local i = `i' + 1
     if `i'==1 & `xmin'>`tck' {local xmin = `tck'}
     if `tck'>`xmax' {local xmax = `tck'}
     }

/* reset xmin and xmax if data exceeds specified range */
qui summ `3', meanonly
if r(min)<`xmin'|`xmin'==0 {local xmin=_result(5)}
qui summ `4', meanonly
if r(max)>`xmax'|`xmax'==0 {local xmax=_result(6)}

* center of forest plot and units */
local uline = 8000/((`xmax'-`xmin')/2)
local cline = 23800 - (`xmax'+`xmin')*.5*`uline'

gph open

/* font size */
if      "`font'"=="large" {
      local fheight = 550
      local fwidth  = 250
      }
else if "`font'"=="medium" {
      local fheight = 450
      local fwidth  = 210
      }
else if "`font'"=="small"  {
      local fheight = 360
      local fwidth  = 175
      }
else if "`font'"=="tiny"  {
      local fheight = 250 
      local fwidth  = 122
      }
else {
      local fheight = 360
      local fwidth  = 175
      }
gph font `fheight' `fwidth'

/* first line of forest plot and distance between lines */
local j = 740 + `fheight'
local lineh = int(`fheight' * 1.05)
/* size of diamond */
local dsize = int(.55*`lineh')

/* header of forest plot */
local textp = `cline'-1000
gph text 350 `textp' 0  1 `leftside'
local textp = `cline'+1000
gph text 350 `textp' 0 -1 `rightside'
gph text 350 600   0 -1 `col1lbl'
gph text 350 12800   0 1 `col2lbl'
//gph line 595 600 595 31800    

/* body of forest plot */
tempname _les _ues _es _col1 _col2
local i 1
while `i' <= _N {
     local _col1   = `col1'[`i']
     local _col2   = `col2'[`i']
     local _les = `cline' + `ylci'[`i']*`uline'
     local _ues = `cline' + `yuci'[`i']*`uline' 
     local  _es = `cline' + `1'[`i']*`uline'
     if "`col1'"!="" {gph text `j'   600 0 -1 `_col1'}
     if "`col2'"!="" {gph text `j' 12800 0  1 `_col2'}
     local k = `j' - .45*`lineh'
     gph line `k' `_les' `k' `_ues'
     gph point `k' `_es' `dsize' 5
     local i = `i' + 1 
     local j = `j' + int(`lineh'*2)
}

if "`mean'"!="" {
     qui masum `1', se(`2') model("`mean'")
     local k = `j' - 50
     gph text `j' 1000 0 -1 Randm Effects Mean
     local _les = `cline' + r(lci)*`uline' 
     local _ues = `cline' + r(uci)*`uline'
     local _es  = `cline' + r(mean)*`uline'
     gph line `k' `_les' `k' `_ues'
     gph pen 3
     gph point `k' `_es' `dsize' 5
     gph pen 1
}
          
/* vertical line at zero run height of forest plot */
local j = `j'+200
gph line 595 `cline' `j' `cline'

/* x-axis tic marks */

/* xtic1 and xtic2 set the height of the tic marks */
local xtic1 = `j'
local j     = `j'+1000
local xtic2 = `j'-700

local i = round(`xmin',.01)  /* minimum x-axis value */
local k = `cline'+`uline'*`i' /* start location for x-axis */

if "`logxaxis'"=="logxaxis" {
  if `xunits'==1 & (`xmax'-`xmin')>15 {local `xunits' = (`xmax'-`xmin')/12}
  if "`xtics'"=="" {
     while `k'< 32000 {
         local tcknum = round(exp(`tck'),.1)
         gph text `j'     `k' 0 0 `tcknum'
         gph line `xtic1' `k' `xtic2' `k'
         local i = round(`i' + `xunits',.01)
         local k = `cline'+`uline'*`i'
     }
  }
  else {
     foreach tck of local xtics {
         local k = `cline'+`uline'*`tck'
         local tcknum = round(exp(`tck'),.1)
         gph text `j'     `k' 0 0 `tcknum'
         gph line `xtic1' `k' `xtic2' `k'
      }
  }
}
else {
  if `xunits'==1 & (`xmax'-`xmin')>15 {local `xunits' = (`xmax'-`xmin')/12}
  if "`xtics'"=="" {
     while `k'< 32000 {
         gph text `j'     `k' 0 0 `i'
         gph line `xtic1' `k' `xtic2' `k'
         local i = round(`i' + `xunits',.01)
         local k = `cline'+`uline'*`i'
     }
  }
  else {
     foreach tck of local xtics {
         local k = `cline'+`uline'*`tck'
         gph text `j'     `k' 0 0 `tck'
         gph line `xtic1' `k' `xtic2' `k'
      }
  }
}

/* x-axis label */
local j = `j' + 700
if `"`xlabel'"'=="" {local xlabel = "Effect Size"}
gph text `j' `cline' 0 0 `xlabel'

gph close

end
