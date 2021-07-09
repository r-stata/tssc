*!1.0 iGini Decomposition
*!The igini1 ado computes a decomposition of the Gini index into individual
*!components and further decompose each individual Gini (iGini) component
*!into a between-group and a within-group component of the overall Gini
*!The individual components sum up to the overall Gini index.
*!Tim F. Liao, Center for Advanced Studies in the Behaviorial Sciences
*!& University of Illinois, May 2018-July 2019 
program define igini1, byable(recall) rclass

version 8.1 
syntax varname(numeric) [aweight fweight] [if] [in] ///
  [, BYg(varname numeric)]

local y0 "`varlist'"
qui gen id=_n

gen G=`byg'
qui egen T=total(G)
 if T==_N {
  qui gen t0=1
  qui replace t0=2 if id>round(_N/2)
  local byg t0
  }
  
tempvar w0 y1 g1 w1 igb igw G  
    
 qui count if `y0'<0 
  if r(N) > 0 {
   di " "
   di as error "`y0' has `r(N)' values < 0." _c
   di as error " Make sure these cases are meaningful or omit them."
   exit 459
   }

if "`weight'" == "" gen byte `w0' = 1
  else gen `w0' `exp'

marksample touse
  if "`byg'" != "" markout `touse' 

qui count if `touse'
if r(N) == 0 error 2000

lab var `touse' "All Obs"
lab def `touse' 1 " "
lab val `touse' `touse'

if "`byg'" != "" {
  capture levelsof `byg' if `touse' , local(grp)
  qui if _rc levels `byg' if `touse' , local(grp)
  foreach x of local grp {
 	if int(`x') != `x' | (`x' < 0) { 
   	  di as error "`byg' contains non-integer or negative values"
	  exit 459
	  }
	}
  }

set more off

egen group = group(`byg')
su group, meanonly
gen quant2 = .
quietly forval i = 1/`r(max)' {
  xtile work = `y0' if group == `i' [aweight=`w0'], nq(2)
  replace quant2 = work if group==`i'
  drop work
  }
drop group

quietly {
	sum `y0' [aw = `w0'] if `touse', meanonly
	local sy = r(sum)
	local sw = r(sum_w)
	local N=_N
	if (`touse') {
*	egen `N'=count(`y0')
	local C=2*`sw'*`sy'
	tempname res
mata: one=J(1,`N',1)
set more off
*** compute decomposition and output results line by line
postfile `res' ID Group iGinib iGiniw quant2 using "file.dta", replace
forvalues i = 1/`N' {
	mata: iGb=J(`N',1,0)
	mata: iGw=J(`N',1,0)
  forvalues j = 1/`N' {
	if `byg'[`i']~=`byg'[`j'] {
	local t `w0'[`i']*`w0'[`j']*abs(`y0'[`i']-`y0'[`j'])/`C'
	mat A =`t'
	mata: iGb[`j']=st_matrix("A")
	}
	if `byg'[`i']==`byg'[`j'] {
	local t `w0'[`i']*`w0'[`j']*abs(`y0'[`i']-`y0'[`j'])/`C'
	mat A =`t'
	mata: iGw[`j']=st_matrix("A")
	}
    }
	mata: iGinib=one*iGb
	mata: iGiniw=one*iGw
	mata: st_matrix("iGinib",iGinib)
	mata: st_matrix("iGiniw",iGiniw)
	mat B =`id'[`i']
	mat C =`byg'[`i']
	mat D = quant2[`i']
	post `res' (B[1,1]) (C[1,1]) (iGinib[1,1]) (iGiniw[1,1]) (D[1,1])
	}
postclose `res'
use "file.dta", clear
gen double iGini=iGinib+iGiniw
order ID Group iGini iGinib iGiniw quant2
*** compute overall Gini decomposition
	egen `igb'=sum(iGinib)
	egen `igw'=sum(iGiniw)
	egen `G'=sum(iGini)
	} // end if block
	return scalar Gini = `G'[1]
	return scalar Gini_between = `igb'[1]
	return scalar Gini_within = `igw'[1]
    } // end quietly block

end
