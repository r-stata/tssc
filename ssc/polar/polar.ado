*! version 1.0  29may2014  Joseph Canner
/*
polar: plot polar coordinates
Usage: polar radius angle [if] [in] [, options]
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Version 1.0 May 29, 2014
*/

program polar
version 12.1

syntax varlist(min=2 max=2) [if] [in] [, DEGrees cc(numlist) ncc(string) SPokes(numlist) NSPokes(string) SCatteropts(string) *]

tokenize `varlist'
local radius `1'
local theta `2'

// Polar Grid Concentric Circles
qui summ `r' `if' `in'
local rmax=abs(r(max))
if "`cc'"!="" & "`ncc'"!="" {
   di as red "Can't use both cc and ncc options"
   exit
}
if "`cc'"=="" & "`ncc'"=="" {
   local ncc=3
}
if "`ncc'"!="" {
  local maxcc=`rmax'
  forvalues cc=1/`ncc' {
    local r=`cc'*`rmax'/`ncc'
	local rsq=`r'^2
    local semicircle1 `semicircle1' (function y =  sqrt(`rsq' - (x)^2), lc(gs8) range(-`r' `r'))
    local semicircle2 `semicircle2' (function y = -sqrt(`rsq' - (x)^2), lc(gs8) range(-`r' `r'))
  }  
}
if "`cc'"!="" {
  local maxcc=0
  foreach r of numlist `cc' {
    if `r'>`maxcc' {
	   local maxcc=`r'
	}
	local rsq=`r'^2
    local semicircle1 `semicircle1' (function y =  sqrt(`rsq' - (x)^2), lc(gs8) range(-`r' `r'))
    local semicircle2 `semicircle2' (function y = -sqrt(`rsq' - (x)^2), lc(gs8) range(-`r' `r'))
  }
}
// Polar Grid Spokes 
if "`spokes'"!="" & "`nspokes'"!="" {
   di as red "Can't use both spokes and nspokes options"
   exit
}
if "`spokes'"=="" & "`nspokes'"=="" {
   local nspokes=6
}
if "`nspokes'"!="" {
  forvalues sp=1/`nspokes' {
    local radsp=(`sp'-1)*_pi/`nspokes'
	if abs(cos(`radsp'))>1.00e-8 {
      local m=sin(`radsp')/cos(`radsp')
      local rg=abs((`rmax'+0.1)*cos(`radsp'))
//	  di "`sp' `theta' `m' `rg'"
	  local spokelines `spokelines' (function y=`m'*x, n(2) lc(gs8) range(-`rg' `rg')) 
	}
  }
}
if "`spokes'"!="" {
  foreach sp of numlist `spokes' {
    local radsp = 2*_pi*`sp'/360
	if abs(cos(`radsp'))>1.00e-8 {
      local m=sin(`radsp')/cos(`radsp')
      local rg=abs((`rmax'+0.1)*cos(`radsp'))
	  local spokelines `spokelines' (function y=`m'*x, n(2) lc(gs8) range(-`rg' `rg')) 
	}
  }
}

// Axes
if !strpos("`options'","xsc") & !strpos("`scatteropts'","xsc") {
   local xscale="xscale(range(-`rmax' `rmax'))"
}
if !strpos("`options'","ysc") & !strpos("`scatteropts'","ysc"){
   local yscale="yscale(range(-`rmax' `rmax'))"
}

tempvar x y 

if "`degrees'"=="" {
  gen `x'=`radius'*cos(`theta')
  gen `y'=`radius'*sin(`theta')
}
else {
  gen `x'=`radius'*cos(`theta'*2*_pi/360)
  gen `y'=`radius'*sin(`theta'*2*_pi/360)
}

twoway (scatter `y' `x', `xscale' `yscale' xtitle("") ytitle("") yline(0, lstyle(foreground)) xline(0, lstyle(foreground)) `scatteropts' ) ///
       `semicircle1' `semicircle2' ///
	   `spokelines' ///
	   `if' `in', aspect(1) legend(off) `options'
	   
end
