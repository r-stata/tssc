*! locpr 1.0.2 7 May 2008 austinnichols@gmail.com
* added option plot, and fixed stub, scatter, and nquantiles options
* locpr 1.0.1 20 Mar 2008 austinnichols@gmail.com
* added options nq, rarea, coptions, and loptions, and fixed name option
* locpr 1.0.0 26 Jan 2008 austinnichols@gmail.com
*! module to semi-parametrically estimate probability/proportion 
*! as a function of one other var and optionally compare to logit
prog locpr, sortpreserve
version 10.0
syntax varlist(min=2 max=2) [aw pw fw/] [if] [in] [, levels plot(string) /*
 */ name(string) Nquantiles(int 99) ENDpoints rarea(string) loptions(string) /*
 */ coptions(string) Stub(str) SCatter Logit lbw BWidth(real 0) Combine *]
marksample touse
tokenize `varlist'
tempvar y x b se ub lb 
if `"`name'"'=="" loc name "locpr"
if `"`rarea'"'=="" loc rarea "fc(gs14) lc(gs14)"
if `"`options'"'=="" loc options "leg(col(1))"
if strpos(`"`options'"',"leg")==0 loc options `"`options' leg(col(1))"'
if `"`loptions'"'=="" loc loptions "leg(col(1))"
if strpos(`"`loptions'"',"leg")==0 loc loptions `"`loptions' leg(col(1))"'
if "`exp'"!="" & "`weight'"=="aweight" loc wt="[aw=`exp']"
if "`exp'"!="" & "`weight'"=="pweight" {
 loc wt="[aw=`exp']"
 di as err "Warning: pweight treated as aweight for lpoly estimation."
 }
if "`exp'"!="" & "`weight'"=="fweight" loc wt="[fw=`exp']"
if "`scatter'"!="" loc sc "scatter `varlist'  if `touse' ||"
qui { 
 count if `touse'
 loc N=r(N)
 tempvar first
 bys `touse' `2' : g `first'=_n==1 if `touse'
 count if `first'==1
 loc nlev=r(N)
 if `nlev'==0 error 2000
 loc nq=`nquantiles'+1
 cap set obs `nq'
 g `x'=.
 _pctile `2' if `touse' `wt', nq(`nq')
 count if `first'==1 & (`2'>=r(r1) & `2'<=r(r`nquantiles'))
 if `nq'<r(N) & "`levels'"=="" {
  _pctile `2' if `touse' `wt', nq(`nq')
  forv i=1/`=`nq'-1' {
   replace `x'=r(r`i') in `i'
  }
 }
 else {
  if "`levels'"=="" {
   _pctile `2' if `touse' `wt', nq(`nq')
   levelsof `2' if `touse' & (`2'>=r(r1) & `2'<=r(r`nquantiles')), loc(levs)
   }
  else {
   levelsof `2' if `touse', loc(levs)
   }
  loc i=1
  foreach lev of local levs {
   replace `x'=`lev' in `i++'
  }
 }
 if `bwidth'==0 local bwidth
 else local bwidth="bw(`bwidth')"
 if "`lbw'"!="" {
  g `b'=.
  replace `b'=2*max(`x'-`x'[_n-1],`x'[_n+1]-`x')
  local bwidth="bw(`b')"
  }
 lpoly `1' `2' if `touse' `wt', deg(1) nogr `bwidth' gen(`y') at(`x') se(`se')
 g `ub'=invlogit(logit(`y')+1.96*`se'*abs(1/`y'-1/(1-`y')))
 g `lb'=invlogit(logit(`y')-1.96*`se'*abs(1/`y'-1/(1-`y')))
 la var `lb' "Lower"
 la var `ub' "Upper Limits of CI"
 la var `y'  "Local est. `: var label `1''"
 la var `x'  "`:var la `2'' "
 if "`logit'"!="" {
  tempvar xb lse p tmp llb lub
  if "`exp'"!="" & "`weight'"=="aweight" {
   loc wt="[pw=`exp']"
   di as err "Warning: aweight treated as pweight for logit estimation."
  }
  if "`exp'"!="" & "`weight'"=="pweight" loc wt="[pw=`exp']"
  if "`exp'"!="" & "`weight'"=="fweight" loc wt="[fw=`exp']"
  logit `1' `2' if `touse' `wt'
  ren `2' `tmp'
  ren `x' `2'
  predict `xb', xb
  predict `lse', stdp
  g `lub'=invlogit(`xb'+1.96*`lse')
  g `llb'=invlogit(`xb'-1.96*`lse')
  predict `p', p
  la var `p' "Logit prediction"
  la var `llb' "Lower"
  la var `lub' "Upper Limits of CI"
  ren `2' `x'
  ren `tmp' `2'
  tw rarea `llb' `lub' `x', `rarea' || `sc' line `p' `x', name(`name'logit, replace) `loptions' `plot'
 }
 tw rarea `lb' `ub' `x', `rarea' || `sc' line `y' `x', `options'  name(`name', replace) `plot'
 if "`combine'"!="" gr combine `name' `name'logit, ycommon nocopies name(`name'both, replace) `coptions'  `plot'
 if "`stub'"!="" {
  ren `y' `stub'y
  ren `x' `stub'x
  ren `lb' `stub'lb
  ren `ub' `stub'ub
  if "`logit'"!="" {
   ren `llb' `stub'llb
   ren `lub' `stub'ulb
   }
 }
}
end
 
