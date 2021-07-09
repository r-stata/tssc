*! epresent v1.6 by Till Ittermann - latest update 2018-11-15

capture program drop epresent

program define epresent
version 13.0
syntax varlist(numeric fv) [if] [pweight], reg(string) center(string) output(string) [nq(real 10) tpoints(string) crange(real 0.001) plotres(string) ytitle(string) xtitle(string) xlabel(string) ylabel(string) format(string) regopt(string) title(string) legend(string)]
marksample touse

if "`output'" == "percentiles" {

if "`reg'" == "logistic" | "`reg'" == "poisson" | "`reg'" == "nbreg" | "`reg'" == "glm" {
tokenize `varlist'   
local outcome "`1'"
local exposuret "`2'"
local exposure "`3'"
macro shift 3
local covar "`*'"

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"

su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `outcome' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
tempvar sampler
g `sampler' = e(sample)

if e(Fp_fd1) <= 2 {
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp((_b[`1'] - 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `ub2' = exp((_b[`1'] + 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

if e(Fp_fd1) > 2 {
di _newline(1) _skip(4) "{bf} Test for significance"
testparm `1' `2'
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1') + _b[`2']*(`2')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp(_b[`1']*`1' + _b[`2']*`2' - 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `ub2' = exp(_b[`1']*`1' + _b[`2']*`2' + 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

qui _pctile `exposure' if `sampler' == 1, nq(`nq')
local nq2 = `nq' - 1

foreach n of numlist 1(1)`nq2'{
local p`n' = r(r`n')
}

tempvar tag

qui egen `tag' = tag(`exposure') if `sampler' == 1

di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"

sort `exposure'
foreach n of numlist 1(1)`nq2'{
tempvar close
qui g `close' = abs(`exposure' - `p`n'')
qui su `close'
qui su `exposure' if `close' == r(min)
list `exposure' `or' `lb' `ub' if `sampler' == 1 & `tag' == 1 & `exposure' == r(max), noheader clean noobs 
}

*format `or' `lb' `ub'  %9.1f
graph twoway (scatter `or' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) title(`title') ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `lb' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)) ///
             (scatter `ub' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)), legend(off) 
}	

if "`reg'" == "stcox" {

tokenize `varlist'   
local exposuret "`1'"
local exposure "`2'"
macro shift 2
local covar "`*'"

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"
su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
tempvar sampler
g `sampler' = e(sample)

if e(Fp_fd1) <= 2 {
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp((_b[`1'] - 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `ub2' = exp((_b[`1'] + 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

if e(Fp_fd1) > 2 {
di _newline(1) _skip(4) "{bf} Test for significance"
testparm `1' `2'
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1') + _b[`2']*(`2')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp(_b[`1']*`1' + _b[`2']*`2' - 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `ub2' = exp(_b[`1']*`1' + _b[`2']*`2' + 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

qui _pctile `exposure' if `sampler' == 1, nq(`nq')
local nq2 = `nq' - 1

foreach n of numlist 1(1)`nq2'{
local p`n' = r(r`n')
}

tempvar tag

qui egen `tag' = tag(`exposure') if `sampler' == 1

di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"

sort `exposure'
sort `exposure'
foreach n of numlist 1(1)`nq2'{
tempvar close
qui g `close' = abs(`exposure' - `p`n'')
qui su `close'
qui su `exposure' if `close' == r(min)
list `exposure' `or' `lb' `ub' if `sampler' == 1 & `tag' == 1 & `exposure' == r(max), noheader clean noobs 
}
								   
*format `or' `lb' `ub'  %9.1f
graph twoway (scatter `or' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `lb' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)) ///
             (scatter `ub' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)), legend(off) 
}	

if "`reg'" == "mlogit"  {	
tokenize `varlist'   
local outcome "`1'"
local exposuret "`2'"
local exposure "`3'"
macro shift 3
local covar "`*'"

qui ta `outcome'
local levels = r(r) - 1

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"

su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `outcome' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
local mfp "`1'"
local num: word count `t1'
local num2 = `num' + 1
tempvar sampler
g `sampler' = e(sample)
matrix eb = e(b)
matrix ev = e(V)
if e(Fp_fd1) <= 2 {
	foreach n of numlist 0(1)`levels' {
		tempvar or`n' lb`n' ub`n' lb2`n' ub2`n'
		qui g `or`n'' = exp(eb[1,1+`num2'*`n']*(`1')) if `touse'
		qui g `lb2`n'' = exp((eb[1,1+`num2'*`n'] - 1.96*sqrt(ev[1+`num2'*`n',1+`num2'*`n']))*(`1')) if `touse'
		qui g `ub2`n'' = exp((eb[1,1+`num2'*`n'] + 1.96*sqrt(ev[1+`num2'*`n',1+`num2'*`n']))*(`1')) if `touse'
		qui g `lb`n'' = `lb2`n''
		qui replace `lb`n'' = `ub2`n'' if `lb2`n'' > `or`n''
		qui g `ub`n'' = `ub2`n''
		qui replace `ub`n'' = `lb2`n'' if `ub2`n'' < `or`n''
		qui format `or`n'' `lb`n'' `ub`n''  %9.2f
		qui format `exposure' `format'
		}
}
if e(Fp_fd1) > 2 {
	di _newline(1) _skip(4) "{bf} Test for overall significance of all fractional polynomial terms"
	testparm `1' `2'
	foreach n of numlist 0(1)`levels' {
		tempvar or`n' lb`n' ub`n' lb2`n' ub2`n'
		qui g `or`n'' = exp(eb[1,1+`num2'*`n']*(`1') + eb[1,2+`num2'*`n']*(`2')) if `touse'
		qui g `lb2`n'' = exp(eb[1,1+`num2'*`n']*`1' + eb[1,2+`num2'*`n']*`2' - 1.96*(sqrt(ev[1+`num2'*`n',1+`num2'*`n']*`1'^2 + ev[2+`num2'*`n',2+`num2'*`n']*`2'^2 + 2*ev[1+`num2'*`n',2+`num2'*`n']*`1'*`2'))) if `touse'
		qui g `ub2`n'' = exp(eb[1,1+`num2'*`n']*`1' + eb[1,2+`num2'*`n']*`2' + 1.96*(sqrt(ev[1+`num2'*`n',1+`num2'*`n']*`1'^2 + ev[2+`num2'*`n',2+`num2'*`n']*`2'^2 + 2*ev[1+`num2'*`n',2+`num2'*`n']*`1'*`2'))) if `touse'
		qui g `lb`n'' = `lb2`n''
		qui replace `lb`n'' = `ub2`n'' if `lb2`n'' > `or`n''
		qui g `ub`n'' = `ub2`n''
		qui replace `ub`n'' = `lb2`n'' if `ub2`n'' < `or`n''
		qui format `or`n'' `lb`n'' `ub`n''  %9.2f
		qui format `exposure' `format'
		}
}

qui _pctile `exposure' if `sampler' == 1, nq(`nq')
local nq2 = `nq' - 1

foreach n of numlist 1(1)`nq2'{
local p`n' = r(r`n')
}

tempvar tag

qui egen `tag' = tag(`exposure') if `sampler' == 1

di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"

sort `exposure'

foreach n of numlist 0(1)`levels' {
	di _newline(3) _skip(4) "{bf} Outcome = `n'"
	di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"
	sort `exposure'
	foreach m of numlist 1(1)`nq2'{
    tempvar close
	qui g `close' = abs(`exposure' - `p`m'') if `sampler' == 1
	qui su `close'
	qui su `exposure' if `close' == r(min)
	list `exposure' `or`n'' `lb`n'' `ub`n'' if `sampler' == 1 & `tag' == 1 & (`exposure' == r(max)), noheader clean noobs 
	}
	*format `or`n'' %9.1f
								   }


if "`levels'" == "2" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2"))
			 }
if "`levels'" == "3" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3"))
			 }
if "`levels'" == "4" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 (scatter `or4' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(dknavy) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3") lab(5 "Outcome = 4"))
			 }
if "`levels'" == "5" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 (scatter `or4' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(dknavy) lwidth(medthick)) ///
			 (scatter `or5' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(green) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3") lab(5 "Outcome = 4") lab(6 "Outcome = 5"))
			 }
matrix drop eb
matrix drop ev
}
}

if "`output'" == "values" {
if "`reg'" == "logistic" | "`reg'" == "poisson" | "`reg'" == "nbreg" | "`reg'" == "glm" {
tokenize `varlist'   
local outcome "`1'"
local exposuret "`2'"
local exposure "`3'"
macro shift 3
local covar "`*'"

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"

su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `outcome' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
*tempvar sampler
*g `sampler' = e(sample)

if e(Fp_fd1) <= 2 {
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp((_b[`1'] - 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `ub2' = exp((_b[`1'] + 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

if e(Fp_fd1) > 2 {
di _newline(1) _skip(4) "{bf} Test for significance"
testparm `1' `2'
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1') + _b[`2']*(`2')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp(_b[`1']*`1' + _b[`2']*`2' - 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `ub2' = exp(_b[`1']*`1' + _b[`2']*`2' + 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

tempvar tag

qui egen `tag' = tag(`exposure')

di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"

sort `exposure'
foreach n of numlist `tpoints'{
tempvar close
qui g `close' = abs(`exposure' - `n')
qui su `close'
qui su `exposure' if `close' == r(min)
list `exposure' `or' `lb' `ub' if `touse' & `tag' == 1 & `exposure' == r(max), noheader clean noobs 
}

*format `or' `lb' `ub'  %9.1f
graph twoway (scatter `or' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) title(`title') ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `lb' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)) ///
             (scatter `ub' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)), legend(off) 
}	

if "`reg'" == "stcox" {

tokenize `varlist'   
local exposuret "`1'"
local exposure "`2'"
macro shift 2
local covar "`*'"

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"
su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
tempvar sampler
g `sampler' = e(sample)

if e(Fp_fd1) <= 2 {
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp((_b[`1'] - 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `ub2' = exp((_b[`1'] + 1.96*sqrt(ev[1,1]))*(`1')) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

if e(Fp_fd1) > 2 {
di _newline(1) _skip(4) "{bf} Test for significance"
testparm `1' `2'
tempvar or lb2 ub2 lb ub
qui g `or' = exp(_b[`1']*(`1') + _b[`2']*(`2')) if `touse'
qui matrix ev = e(V)
qui g `lb2' = exp(_b[`1']*`1' + _b[`2']*`2' - 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `ub2' = exp(_b[`1']*`1' + _b[`2']*`2' + 1.96*(sqrt(ev[1,1]*`1'^2 + ev[2,2]*`2'^2 + 2*ev[1,2]*`1'*`2'))) if `touse'
qui g `lb' = `lb2'
qui replace `lb' = `ub2' if `lb2' > `or'
qui g `ub' = `ub2'
qui replace `ub' = `lb2' if `ub2' < `or'
qui format `or' `lb' `ub'  %9.2f
qui format `exposure' `format'
matrix drop ev
}

tempvar tag

qui egen `tag' = tag(`exposure') if `sampler' == 1

di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"

sort `exposure'
foreach n of numlist `tpoints'{
tempvar close
qui g `close' = abs(`exposure' - `n') if `sampler' == 1
qui su `close'
qui su `exposure' if `close' == r(min)
list `exposure' `or' `lb' `ub' if `touse' & `tag' == 1 & `exposure' == r(max), noheader clean noobs 
}
								   
*format `or' `lb' `ub'  %9.1f
graph twoway (scatter `or' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `lb' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)) ///
             (scatter `ub' `exposure' `plotres', sort msymbol(i) connect(l) lpattern(dash) lwidth(medthick)), legend(off) 
}	

if "`reg'" == "mlogit"  {	
tokenize `varlist'   
local outcome "`1'"
local exposuret "`2'"
local exposure "`3'"
macro shift 3
local covar "`*'"

qui ta `outcome'
local levels = r(r) - 1

qui su `exposure'

di _newline(1) _skip(4) "{bf} Center @"

su `exposuret' if inrange(`exposure', `center' - `crange'*r(sd), `center' + `crange'*r(sd))
di _newline(2)
local center2 = r(mean)

xi: mfp `reg' `outcome' `exposuret' `covar' if `touse' [`weight' `exp'], center(`exposuret': `center2') `regopt'
local t1 = e(fp_fvl)
tokenize `t1'
local mfp "`1'"
local num: word count `t1'
local num2 = `num' + 1 
tempvar sampler
g `sampler' = e(sample)
matrix eb = e(b)
matrix ev = e(V)
if e(Fp_fd1) <= 2 {
	foreach n of numlist 0(1)`levels' {
		tempvar or`n' lb`n' ub`n' lb2`n' ub2`n'
		qui g `or`n'' = exp(eb[1,1+`num2'*`n']*(`1')) if `touse'
		qui g `lb2`n'' = exp((eb[1,1+`num2'*`n'] - 1.96*sqrt(ev[1+`num2'*`n',1+`num2'*`n']))*(`1')) if `touse'
		qui g `ub2`n'' = exp((eb[1,1+`num2'*`n'] + 1.96*sqrt(ev[1+`num2'*`n',1+`num2'*`n']))*(`1')) if `touse'
		qui g `lb`n'' = `lb2`n''
		qui replace `lb`n'' = `ub2`n'' if `lb2`n'' > `or`n''
		qui g `ub`n'' = `ub2`n''
		qui replace `ub`n'' = `lb2`n'' if `ub2`n'' < `or`n''
		qui format `or`n'' `lb`n'' `ub`n''  %9.2f
		qui format `exposure' `format'
		}
}
if e(Fp_fd1) > 2 {
	di _newline(1) _skip(4) "{bf} Test for overall significance of all fractional polynomial terms"
	testparm `1' `2'
	foreach n of numlist 0(1)`levels' {
		tempvar or`n' lb`n' ub`n' lb2`n' ub2`n'
		qui g `or`n'' = exp(eb[1,1+`num2'*`n']*(`1') + eb[1,2+`num2'*`n']*(`2')) if `touse'
		qui g `lb2`n'' = exp(eb[1,1+`num2'*`n']*`1' + eb[1,2+`num2'*`n']*`2' - 1.96*(sqrt(ev[1+`num2'*`n',1+`num2'*`n']*`1'^2 + ev[2+`num2'*`n',2+`num2'*`n']*`2'^2 + 2*ev[1+`num2'*`n',2+`num2'*`n']*`1'*`2'))) if `touse'
		qui g `ub2`n'' = exp(eb[1,1+`num2'*`n']*`1' + eb[1,2+`num2'*`n']*`2' + 1.96*(sqrt(ev[1+`num2'*`n',1+`num2'*`n']*`1'^2 + ev[2+`num2'*`n',2+`num2'*`n']*`2'^2 + 2*ev[1+`num2'*`n',2+`num2'*`n']*`1'*`2'))) if `touse'
		qui g `lb`n'' = `lb2`n''
		qui replace `lb`n'' = `ub2`n'' if `lb2`n'' > `or`n''
		qui g `ub`n'' = `ub2`n''
		qui replace `ub`n'' = `lb2`n'' if `ub2`n'' < `or`n''
		qui format `or`n'' `lb`n'' `ub`n''  %9.2f
		qui format `exposure' `format'
		}
}

tempvar tag

qui egen `tag' = tag(`exposure') if `sampler' == 1

sort `exposure'

foreach n of numlist 0(1)`levels' {
	di _newline(3) _skip(4) "{bf} Outcome = `n'"
	di _newline(3) _skip(4) "{bf} `exposure'" _skip(3) "{bf} Exp(Beta)" _skip(4) "{bf} LB" _skip(8) "{bf} UB"
	sort `exposure'
	foreach m of numlist `tpoints'{
	tempvar close
	qui g `close' = abs(`exposure' - `m') if `sampler' == 1
	qui su `close'
	qui su `exposure' if `close' == r(min)
	list `exposure' `or`n'' `lb`n'' `ub`n'' if `touse' & `tag' == 1 & (`exposure' == r(max)), noheader clean noobs 
	}
	*format `or`n'' %9.1f
								   }


if "`levels'" == "2" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2"))
			 }
if "`levels'" == "3" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3"))
			 }
if "`levels'" == "4" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 (scatter `or4' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(dknavy) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3") lab(5 "Outcome = 4"))
			 }
if "`levels'" == "5" {
graph twoway (scatter `or0' `exposure' `plotres', sort msymbol(i) connect(l) lwidth(medthick) ytitle(`ytitle') xtitle(`xtitle') xlabel(`xlabel') ylabel(`ylabel')) ///
             (scatter `or1' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(maroon) lwidth(medthick)) ///
             (scatter `or2' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(orange) lwidth(medthick)) ///
			 (scatter `or3' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(cranberry) lwidth(medthick)) ///
			 (scatter `or4' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(dknavy) lwidth(medthick)) ///
			 (scatter `or5' `exposure' `plotres', sort msymbol(i) connect(l) lcolor(green) lwidth(medthick)) ///
			 , legend(`legend' lab(1 "Outcome = 0") lab(2 "Outcome = 1") lab(3 "Outcome = 2") lab(4 "Outcome = 3") lab(5 "Outcome = 4") lab(6 "Outcome = 5"))
			 }
matrix drop eb
matrix drop ev
}
}
	 
end
