*! version 1.0.7     30oct2007     C F Baum / Fabian Bornhorst
*  Jukka Nyblom and Andrew Harvey, Tests of common stochastic trends, 
*  Econometric Theory, 16, 2000, 176-199 
*  1603 1.0.2: do not tab time values
*  1608 1.0.3: add vlags option for LRV
*  1614 1.0.4: add critical values 
*  1615 1.0.5: correct cv's for trend case from trend.do
*  1716 1.0.6: allow ts operators
*  7A30 1.0.7: correct definition of partial sum process

program define nharvey, rclass
	version 7.0
	syntax varname(ts) [if] [in] [ , Trend nolrv Vlags(numlist int >0) Lags(numlist int >0)]  

	qui tsset
	local id `r(panelvar)'
	local time `r(timevar)'

   	marksample touse
	markout `touse' `time'
	tsreport if `touse', report panel
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		error 198
	}
	qui xtsum `time' if `touse'
	local N `r(n)'
	scalar N = `N'
	local T `r(Tbar)'
	if int(`T')*`N' ~= r(N) {
		di in red "panel must be balanced"
		error 198
		}
	local tmin `r(min)'
	local tmax `r(max)'
* potential for adding deterministic lags per Kuo-Mikkola
	if "`lags'" ~= "" {
		di in gr _n "lags option not yet implemented"
		}
	tempname Vals out S C Sinv Slr ps Stat G StatLR
	tempvar xadj hold
	scalar case=1
	local det "constant"
	if "`trend'" ~= "" {
		local trend "`time'"
		scalar case=2
		local det "constant and trend"
		}
*	calculate demeaned (detrended) series for each unit
    qui tab `id' if `touse', matrow(`Vals') 
    local nvals = r(r)
    local i = 1
    while `i' <= `nvals' {
    	local val = `Vals'[`i',1]
    	local vals "`vals' `val'"
    	local i = `i' + 1
    	}
	qui gen double `xadj' = .
	foreach i of local vals {
    qui 	{ reg `varlist' `trend' if `id' == `i' & `touse'
			capt drop `hold'
			predict double `hold' if e(sample), r 
		 	replace `xadj' = `hold' if e(sample)
			} 
		}
* 	place each time period's obs into a matrix and accum outer product in S
* 	accum partial sums of the outer products in C
    mat `S' = J(`N',`N',0)
	mat `C' = J(`N',`N',0)
	mat `ps' = J(`N',1,0)
	local i = 1
	forv t = `tmin'/`tmax' {
		mkmat `xadj' if `time' == `t' & `touse', mat(x`i')
		mat `out' = x`i' * x`i''
		mat `ps' = `ps' + x`i'
		mat `S' = `S' + `out'
		mat `C' = `C' + `ps' * `ps''
		local i = `i' + 1
		}
	mat `Sinv' = syminv(`S'/`T')
	mat `C' = `C'/(`T'*`T')
	mat `Stat' = `Sinv'*`C'
	scalar stat = trace(`Stat')
	_getNH case N
	di in gr _n  "Nyblom-Harvey (2000) statistic for " in ye "`varlist'" in gr
	di in gr "Deterministics chosen : `det'"
	di in gr "H0: 0 common trends among the `N' series in the panel"
	if r(cv10)+r(cv5)+r(cv1) ~= 0 {
		di "Critical values for N=" _col(28) r(point) _col(41) "`r(pointa)'" /*
		*/ _n _col(21) "10% " %9.4f r(cv10) _col(40) "`r(cv10a)'" _n _col(21) " 5% " /*
		*/  %9.4f r(cv5) _col(40) "`r(cv5a)'" _n _col(21) " 1% " %9.4f r(cv1) _col(40) "`r(cv1a)'"
		}
	else {
		di _n "Critical values (N=`N') not currently available"
		}
	di in gr _n "Assuming IID RW errors : " _col(35) in ye %9.4f stat 
	return local depvar = "`varlist'"
	return local determ = "`det'"
	return scalar N = `N'
	return scalar T = `T'
	return scalar cv10 = r(cv10)
	return scalar cv05 = r(cv5)
	return scalar cv01 = r(cv1)
	return scalar statiid = stat
*		
	if "`lrv'" ~= "nolrv" {
* 	truncation for LR variance 
		local vm = int((`T')^0.25)
		if "`vlags'" ~= "" {
			local vm = "`vlags'"
			}
		foreach m of local vm {
			mat `Slr' = `S'/`T'
			forv tau=1/`m' {
* 	generate gamma matrix (autocovariance at lag tau)
				mat `G' = J(`N',`N',0)
				local j = `tau'+1
				forv t = `j'/`T' {
					local t2 = `t'-`tau'
					mat `out' = x`t'*x`t2''
					mat `G' = `G' + `out'
					}
				mat `G' = `G'/`T'
				local wt = 1 - `tau'/(`m'+1)
				mat `Slr' = `Slr' + `wt'*(`G'+`G'')
				}
			mat `Sinv' = syminv(`Slr')
			mat `StatLR' = `Sinv'*`C'
			scalar statLR = trace(`StatLR')
			di _n  in gr "With nonparametric adjustment " _n "for long-run variance (`m' lags) : " /*
			*/ _col(35) in ye %9.4f statLR	in gr
			return scalar statlr`m' = statLR

*			mat list `Slr',f(%9.2f)	
		}
	}
end

	program define _getNH, rclass
	args case N
* NH Table 1 for K=0, augmented by simulation of process (from notrend.do)
* NH Table 2 for K=0, corrected N3/.05, augmented by simulation of process (from trend.do)
	tempname ss msda
	mat `ss' = ( 2,3,4,5,6,7,8,9,10, 20, 30, 40, 50, 75, 100)
	if case == 1 {
	mat `msda' = (.60058341, .76777059, 1.0779651\  .83562562, .99305022, 1.3631488\ /*
N4 */ 1.0519414, 1.2406728, 1.5985288\ 1.2746461, 1.4810436, 1.9337011\ /*
N6 */ 1.480589, 1.6960411, 2.1368944\ 1.6628948, 1.8687141, 2.2639799\ /*
N8 */  1.8709768, 2.0687213, 2.520821\ 2.0885516, 2.3064409, 2.7324616\ /*
N10 */  2.2819458, 2.5332946, 3.1387626\ 4.1794342, 4.4957297, 5.1142304\ /*
N30 */  6.0307043, 6.411784, 7.1862559\ 7.8556687, 8.2642338, 9.0171679\ /*
N50 */ 9.5747748, 10.032142, 10.921293\ 14.016006, 14.601222, 15.69444\ /* 
N100 */ 18.358363, 19.009423, 20.245295 )
}
if case == 2 {
	mat `msda' = ( .211, .247, .329\ .296, .337, .428\ .377, .423, .521\ /*
	N5 */ .45689904,.50546891,.61175381\ /*
N6 */ .53604733,.58928234,.70007641\ .61224723,.66978341,.78877897\ /*
N8 */ .68965556,.74422497,.86855067\ .76732647,.83023337,.9558984\ /*
N10 */ .83706607,.90011154,1.0348889\  1.5798188,1.6650756,1.8425456\ /*
N30 */ 2.3010159,2.3997284,2.5905249\ 3.0120941,3.1291123,3.3440675\ /*
N50 */ 3.7237421,3.8499567,4.092442\ 5.4722909,5.6210538,5.9078715\ /*
N100 */ 7.214168,7.3748234,7.6861086 )
}

forv i=1/15 {
	if N <= `ss'[1,`i'] {
		return scalar cv10 = `msda'[`i',1]
		return scalar cv5 = `msda'[`i',2]
		return scalar cv1 = `msda'[`i',3]
		return scalar point = `ss'[1,`i']
			if N < `ss'[1,`i'] {
				scalar cv10a = int(10^4*`msda'[`i'-1,1])/10^4
				scalar cv5a = int(10^4*`msda'[`i'-1,2])/10^4
				scalar cv1a = int(10^4*`msda'[`i'-1,3])/10^4
				return local cv10a = cv10a
				return local cv5a = cv5a
				return local cv1a = cv1a
				return local pointa = `ss'[1,`i'-1]
				}
		continue , break
		}
	}
end

