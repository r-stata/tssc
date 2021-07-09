*! version 1.2 May 2015 E. Masset
/*trends in mortality rates over time subroutine*/
program syncmrates_3, rclass
version 13
syntax varlist(min=3 max=3) [iw pw] [if] [, trend(integer 0) testby(varlist max=1) t1(integer 1) t0(integer 61) plot(string) *]
cap postfile mypost month nmr lbnmr ubnmr pmr lbpmr ubpmr imr lbimr ubimr cmr lbcmr ubcmr u5mr lbu5mr ubu5mr using mrdata, replace /*post data in datafile syncmrates*/
forvalues j=0(1)`trend' {													/*caculate syncmrates up to n months from the interview*/
local doi="`1'" 
qui sum `doi' `if'															/*extract date of interview*/
local cmc=r(max)-`j'-(12*(1960-1900)+1) 									/*adjust DHS-CMC date to Stata date*/
local ttrend1=`t1'+`j'														/*final interval*/
local ttrend0=`t0'+`j'														/*baseline interval*/
bootstrap nmr=r(nmr) pmr=r(pmr) imr=r(imr) cmr=r(cmr) u5mr=r(u5mr), `options' seed(220307) force notable nowarn nodots noheader: syncmrates_1 `varlist' `if' [`weight' `exp'], t1(`ttrend1') t0(`ttrend0')
mat A=e(b)																	/*save rates as estimated matrices for extraction*/
mat B=e(ci_normal)															/*save lower and upper bounds as estimated matrices for extraction*/
post mypost (`cmc') (A[1,1]) (B[1,1]) (B[2,1]) (A[1,2]) (B[1,2]) (B[2,2]) (A[1,3]) (B[1,3]) (B[2,3]) (A[1,4]) (B[1,4]) (B[2,4]) (A[1,5]) (B[1,5]) (B[2,5])
}
postclose mypost
if "`plot'"~="" {															/*error messages for option plot*/
					capture assert "`plot'"=="nmr" | "`plot'"=="pmr" | "`plot'"=="imr" | "`plot'"=="cmr" | "`plot'"=="u5mr" 
					if _rc~=0 {
					di as error "plot must contain either nmr, pmr, imr, cmr, or u5mr"
					exit 198
					}
					preserve												/*plot mortality trend using plot option*/
					use mrdata, clear
					qui tsset month, monthly								/*tset the data and plot nicely*/
					twoway (tsrline lb`plot' ub`plot', recast(rarea) fcolor(gs14) lcolor(gs14)) (tsline `plot', lcolor(black) lpattern(solid)), ttitle(" ") scheme(s2mono) xlabel(, format("%tmm_cY")) legend(label(1 "95% CI")) yscale(range(0 0.2)) ylabel(0(0.02)0.2)
					restore
					}	
end 
