*! version 1.1.6 11-Aug-03 mg
*
* ROSENBAUM BOUNDS ON TREATMENT EFFECT ESTIMATES
* CF. ROSENBAUM (2002, chap. 4)
*
* rbound <delta-var>, gamma(numlist) alpha(real .95) acc(integer 6) dots
* gives Rosenbaum bounds on TE delta = r(T)-r(C) in matched T-C pairs
* for selected gamma at alpha significance level, gamma=1 will be displayed by default
* acc accuracy level (no of digits, ideally 4-8), use sigonly to comment out iteratively detemined d / CI estimates
*

cap program drop rbounds
program define rbounds, rclass
	version 7

	if ~replay() {
		syntax varname [if/], Gamma(numlist >=1 sort) [acc(int 6) Alpha(real .95) dots sigonly exact]
		tokenize `gamma'
		if `1'~=1 {
			local gamma = "1 `gamma'"
		}
		preserve
		if "`if'"~="" {
			qui keep if `if'
		}
		qui drop if `varlist'==.
		keep `varlist'

		qui summ `varlist'
		local nobs = r(N)
		local ate = r(mean)
		tempname outmat
		local j = 0
		matrix `outmat' = J(1,7,0)
		matrix colnames `outmat' = gamma sig+ sig- t-hat+ t-hat- CI+ CI-
		foreach i of numlist `gamma' {
			local j = `j' + 1
			if rowsof(`outmat')<`j' {
				matrix `outmat' = `outmat' \ J(1,7,0)
			}
			if "`dots'"~="" {
				di "`i': ..." _c
			}
			matrix `outmat'[`j',1] = `i'
			/* significance levels */
			srktst_ex `varlist', g(`i')
			matrix `outmat'[`j',2] = 1-normprob((sign(`ate')*r(srktstp)))
			matrix `outmat'[`j',3] = 1-normprob((sign(`ate')*r(srktstm)))
			if "`dots'"~="" {
				di "s" _c
			}

			if "`sigonly'"=="" {
				/* range of Hodges-Lehmann point estimates */
				if "`exact'"=="" {
					rblspt `varlist', g(`i') acc(`acc')
				}
				else rblspt `varlist', g(`i') acc(`acc') exact
				matrix `outmat'[`j',4] = r(thatu)
				matrix `outmat'[`j',5] = r(thatl)
				if "`dots'"~="" {
					di "p" _c
				}
	
				/* confidence interval estimates */
				if "`exact'"=="" {
					rblsci `varlist', g(`i') a(`alpha') acc(`acc')
				}
				else rblsci `varlist', g(`i') a(`alpha') acc(`acc')
				if r(ciu)~=. {
					matrix `outmat'[`j',6] = r(ciu)
					matrix `outmat'[`j',7] = r(cil)
				}
				else {
					matrix `outmat'[`j',6] = -99
					matrix `outmat'[`j',7] = +99
				}
				if "`dots'"~="" {
					di "c"
				}
			}
		}
		restore
	}
	else {
		tempname outmat
		matrix `outmat' = r(outmat)
		local nobs = r(N)
		local varlist = r(rvar)
		local alpha = r(alpha)
	}

	di
	di in green "Rosenbaum bounds for " in yellow "`varlist'" in green " (N = " in yellow `nobs' in green " matched pairs)"
	di
	
	di in green "Gamma           sig+      sig-    t-hat+    t-hat-       CI+       CI-"
	di in green "----------------------------------------------------------------------"
	local k = rowsof(`outmat')
	forval i = 1 (1) `k' {
		di in yellow %5.3g `outmat'[`i',1] "       " _c
		forval j = 2 (1) 7 {
			di in yellow %8.6g `outmat'[`i',`j'] "  " _c
		}
		di
	}

	di
	di in green "* gamma  - log odds of differential assignment due to unobserved factors"
	di in green "  sig+   - upper bound significance level"
	di in green "  sig-   - lower bound significance level"
	di in green "  t-hat+ - upper bound Hodges-Lehmann point estimate"
	di in green "  t-hat- - lower bound Hodges-Lehmann point estimate"
	di in green "  CI+    - upper bound confidence interval (a=" in yellow %5.3g `alpha' in green ")"
	di in green "  CI-    - lower bound confidence interval (a=" in yellow %5.3g `alpha' in green ")"

	return matrix outmat `outmat'
	return scalar N = `nobs'
	return scalar alpha = `alpha'
	return local rvar "`varlist'"

end

cap program drop rbrksm
program define rbrksm, rclass
	/* Wilcoxon rank sum test, Eq. (4.9), p. 112 */
	version 7
	syntax varname [, Gamma(real 1)]
	qui {
		tempvar rksum rksump rksumm rksumvp rksumvm avar psm psp
		gen `psp' = cond(`varlist'==0,0,`gamma'/(1+`gamma'))
		gen `psm' = cond(`varlist'==0,0,1/(1+`gamma'))
		gen double `avar' = abs(`varlist')
		egen double `rksum' = rank(`avar')
		gen double `rksump' = `rksum'*`psp'
		gen double `rksumvp' = (`rksum'^2)*`psp'*(1-`psp')
		summ `rksump'
		return scalar etplus = r(sum)
		summ `rksumvp'
		return scalar vtplus = r(sum)
		gen double `rksumm' = `rksum'*`psm'
		gen double `rksumvm' = (`rksum'^2)*`psm'*(1-`psm')
		summ `rksumm'
		return scalar etminus = r(sum)
		summ `rksumvm'
		return scalar vtminus = r(sum)
	}
end

cap program drop rbrktst
program define rbrktst, rclass
	/* Wilcoxon rank sum test, adjusted egen track ranking i.e. sum S = sum R */
	version 7
	syntax varname
	qui {
		tempvar avar rkvar
		gen `avar' = abs(`varlist')
		egen double `rkvar' = rank(`avar')
		summ `rkvar' if `varlist'>0
		return scalar rksum = r(sum)
	}
end

cap program drop srktst
program define srktst, rclass
	/* Wilcoxon rank sum test */
	version 7
	syntax varname [, Gamma(real 1)]
	qui {
		rbrktst `varlist'
		local et = r(rksum)
		summ `varlist'
		local nobs = r(N)
		local etp = `gamma'/(1+`gamma')*`nobs'*(`nobs'+1)/2
		local etm = 1/(1+`gamma')*`nobs'*(`nobs'+1)/2
		local etv = (`gamma'/(1+`gamma'))*(1-(`gamma'/(1+`gamma')))*`nobs'*(`nobs'+1)*(2*`nobs'+1)/6
		local srktst1  = (`et'-`etp')/sqrt(`etv')
		local srktst2  = (`et'-`etm')/sqrt(`etv')
	}
	return scalar srktstp = `srktst1'
	return scalar srktstm = `srktst2'
end

cap program drop srktst_ex
program define srktst_ex, rclass
	/* Wilcoxon rank sum test */
	version 7
	syntax varname [, Gamma(real 1)]
	qui {
		rbrktst `varlist'
		local et = r(rksum)
		rbrksm `varlist', g(`gamma')
		local etp = r(etplus)
		local etm = r(etminus)
		local etv = r(vtplus)
		local srktst1  = (`et'-`etp')/sqrt(`etv')
		local srktst2  = (`et'-`etm')/sqrt(`etv')
	}
	return scalar srktstp = `srktst1'
	return scalar srktstm = `srktst2'
end

cap program drop rblspt
program define rblspt, rclass
	/* line search, Hodges-Lehmann point estimates */
	version 7
	syntax varname [, Gamma(real 1) acc(integer 6) exact]
	qui {
		local psp = `gamma'/(1+`gamma')
		local psm = 1/(1+`gamma')
		summ `varlist'
		local nobs = r(N)
		local ate = cond(r(mean)~=0,round(r(mean)*100000,1)/100000,uniform())
		if "`exact'"=="" {
			local etplus = `gamma'/(1+`gamma')*`nobs'*(`nobs'+1)/2
			local etminus = 1/(1+`gamma')*`nobs'*(`nobs'+1)/2
			local vart = (`gamma'/(1+`gamma'))*(1-(`gamma'/(1+`gamma')))*`nobs'*(`nobs'+1)*(2*`nobs'+1)/6
		}
		else {
			rbrksm `varlist', gamma(`gamma')
			local etplus = round(r(etplus)*100000,1)/100000
			local etminus = round(r(etminus)*100000,1)/100000
			local vart = r(vtplus)
		}
		tempvar cresp
		rbrktst `varlist'
		local etptst1 = r(rksum)

		/* upper bound gamma */
			/* fix search boundaries, start from that=0+uniform(), steps of TE */
			local thatc = 0
			gen double `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
			rbrktst `cresp'
			local etptst = r(rksum)
			if `etptst'==`etplus' {
				local thatc = `thatc' - `ate'/3
			}
			while `etptst'==`etplus' {
				local thatc = `thatc' - `ate'
				replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
				rbrktst `cresp'
				local etptst = r(rksum)
			}
			local j = 0
			while `j'==0 {
				if (`etptst'>`etplus' & sign(`ate')==1) | (`etptst'<`etplus' & sign(`ate')==-1) {
					local tmin = `thatc'
					local ettmin = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' + `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
						if (`etptst'<`etplus' & sign(`ate')==1) | (`etptst'>`etplus' & sign(`ate')==-1) {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if (`etptst'<`etplus' & sign(`ate')==1) | (`etptst'>`etplus' & sign(`ate')==-1) {
					local tmax = `thatc'
					local ettmax = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' - `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
						if (`etptst'>`etplus' & sign(`ate')==1) | (`etptst'<`etplus' & sign(`ate')==-1) {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if `etptst'==`etplus' {
					if "`tmax'"~="" | "`tmin'"~="" {
						if "`tmax'"~="" & "`tmin'"=="" {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}
						else {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}
						local j = 1
					}
					else {
						local thatc = `thatc' + `ate'/2
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
					}
				}
			}

			/* line search up/down */
			/* narrowing boundaries until E(T+) = E(T) at one boundary */
			if `k'~=1 {
				local k1 = 0
				while abs(`tmax'-`tmin')>(1/10^`acc') & `k1'==0 {
					local thatc = (`tmax'+`tmin')/2
					replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
					rbrktst `cresp'
					local etptst = r(rksum)
					if (`etptst'<`etplus' & sign(`ate')==1) | (`etptst'>`etplus' & sign(`ate')==-1) {
						local tmax = `thatc'
						local ettmax = `etptst'
					}
					else if (`etptst'>`etplus' & sign(`ate')==1) | (`etptst'<`etplus' & sign(`ate')==-1) {
						local tmin = `thatc'
						local ettmin = `etptst'
					}
					else if `etptst'==`etplus' & abs(`tmax'-`tmin')<=(1/10^`acc') {
						local k1 = 1
					}
					else if `etptst'==`etplus' & abs(`tmax'-`tmin')>(1/10^`acc') {
						/* search towards tmax */
						local rftmax = `tmax'
						local rftmin = `thatc'
						local rfeftmax = `ettmax'
						local rfeftmin = `etplus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							rbrktst `cresp'
							local rfetptst = r(rksum)
							if (`rfetptst'<`rfeftmin' & sign(`ate')==1) | (`rfetptst'>`rfeftmin' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>=`rfeftmin' & sign(`ate')==1) | (`rfetptst'<=`rfeftmin' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmax = (`rftmax'+`rftmin')/2
						/* search towards tmin */
						local rftmin = `tmin'
						local rftmax = `thatc'
						local rfeftmin = `ettmin'
						local rfeftmax = `etplus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							rbrktst `cresp'
							local rfetptst = r(rksum)
							if (`rfetptst'<=`rfeftmax' & sign(`ate')==1) | (`rfetptst'>=`rfeftmax' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>`rfeftmax' & sign(`ate')==1) | (`rfetptst'<`rfeftmax' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmin = (`rftmax'+`rftmin')/2
						local k1 = 1
					}
				}
			}
		return scalar thatu = (`tmax'+`tmin')/2

		/* lower bound gamma */
			/* fix search boundaries, start from that=0, steps of TE */
			local thatc = 0
			replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
			rbrktst `cresp'
			local etptst = r(rksum)
			if `etptst'==`etminus' {
				local thatc = `thatc' - `ate'/3
			}
			while `etptst'==`etminus' {
				local thatc = `thatc' - `ate'
				replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
				rbrktst `cresp'
				local etptst = r(rksum)
			}
			local j = 0
			while `j'==0 {
				if (`etptst'>`etminus' & sign(`ate')==1) | (`etptst'<`etminus' & sign(`ate')==-1) {
					local tmin = `thatc'
					local ettmin = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' + `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
						if (`etptst'<`etminus' & sign(`ate')==1) | (`etptst'>`etminus' & sign(`ate')==-1) {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if (`etptst'<`etminus' & sign(`ate')==1) | (`etptst'>`etminus' & sign(`ate')==-1) {
					local tmax = `thatc'
					local ettmax = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' - `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
						if (`etptst'>`etminus' & sign(`ate')==1) | (`etptst'<`etminus' & sign(`ate')==-1) {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if `etptst'==`etminus' {
					if "`tmax'"~="" | "`tmin'"~="" {
						if "`tmax'"~="" & "`tmin'"=="" {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}
						else {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}
						local j = 1
					}
					else {
						local thatc = `thatc' + `ate'/2
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						rbrktst `cresp'
						local etptst = r(rksum)
					}
				}
			}

			/* line search up/down */
			/* narrowing boundaries until E(T+) = E(T) at one boundary */
			if `k'~=1 {
				local k1 = 0
				while abs(`tmax'-`tmin')>(1/10^`acc') & `k1'==0 {
					local thatc = (`tmax'+`tmin')/2
					replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
					rbrktst `cresp'
					local etptst = r(rksum)
					if (`etptst'<`etminus' & sign(`ate')==1) | (`etptst'>`etminus' & sign(`ate')==-1) {
						local tmax = `thatc'
						local ettmax = `etptst'
					}
					else if (`etptst'>`etminus' & sign(`ate')==1) | (`etptst'<`etminus' & sign(`ate')==-1) {
						local tmin = `thatc'
						local ettmin = `etptst'
					}
					else if `etptst'==`etminus' & abs(`tmax'-`tmin')<=(1/10^`acc') {
						local k1 = 1
					}
					else if `etptst'==`etminus' & abs(`tmax'-`tmin')>(1/10^`acc') {
						/* search towards tmax */
						local rftmax = `tmax'
						local rftmin = `thatc'
						local rfeftmax = `ettmax'
						local rfeftmin = `etminus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							rbrktst `cresp'
							local rfetptst = r(rksum)
							if (`rfetptst'<`rfeftmin' & sign(`ate')==1) | (`rfetptst'>`rfeftmin' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>=`rfeftmin' & sign(`ate')==1) | (`rfetptst'<=`rfeftmin' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmax = (`rftmax'+`rftmin')/2
						/* search towards tmin */
						local rftmin = `tmin'
						local rftmax = `thatc'
						local rfeftmin = `ettmin'
						local rfeftmax = `etminus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							rbrktst `cresp'
							local rfetptst = r(rksum)
							if (`rfetptst'<=`rfeftmax' & sign(`ate')==1) | (`rfetptst'>=`rfeftmax' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>`rfeftmax' & sign(`ate')==1) | (`rfetptst'<`rfeftmax' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmin = (`rftmax'+`rftmin')/2
						local k1 = 1
					}
				}
			}
		return scalar thatl = (`tmax'+`tmin')/2
	}
end			

cap program drop rblsci
program define rblsci, rclass
	/* line search, CI interval estimates */
	version 7
	syntax varname [, Gamma(real 1) Alpha(real .95) acc(integer 6) exact]
	qui {
		local psp = `gamma'/(1+`gamma')
		local psm = 1/(1+`gamma')
		summ `varlist'
		local nobs = r(N)
		local ate = round(r(mean)*100000,1)/100000
		tempvar cresp
		if "`exact'"=="" {
			srktst `varlist', g(`gamma')
		}
		else srktst_ex `varlist', g(`gamma')
		local etptst1 = r(srktstp)
		local etptst2 = r(srktstm)
		/* upper bound gamma */
			/* fix search boundaries, start from that=0, steps of TE */
			local thatc = 0
			gen double `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
			if "`exact'"=="" {
				srktst `cresp', g(`gamma')
			}
			else srktst_ex `cresp', g(`gamma')
			local etptst = r(srktstp)
			local m = 0
			local j = 0
			while `j'==0 {
				if (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
					local tmin = `thatc'
					local ettmin = `etptst'
					local k = 0
					while `k'==0 & `m'<100 {
						local m = `m' + 1
						local thatc = `thatc' + `m'*`ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstp)
						if (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
					local tmax = `thatc'
					local ettmax = `etptst'
					local k = 0
					while `k'==0 & `m'<100 {
						local m = `m' + 1
						local thatc = `thatc' - `m'*`ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstp)
						if (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if `etptst'==invnorm(1-(1-`alpha')/2) {
					if "`tmax'"~="" | "`tmin'"~="" {
						if "`tmax'"~="" & "`tmin'"=="" {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}
						else {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}
						local j = 1
					}
					else {
						local thatc = `thatc' + `ate'/2
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstp)
					}
				}
			}

			if `m'<100 {

			/* line search up/down */
			/* narrowing boundaries until E(T+) = E(T) at one boundary */
			if `k'~=1 {
				local k1 = 0
				while abs(`tmax'-`tmin')>(1/10^`acc') & `k1'==0 {
					local thatc = (`tmax'+`tmin')/2
					replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
					if "`exact'"=="" {
						srktst `cresp', g(`gamma')
					}
					else srktst_ex `cresp', g(`gamma')
					local etptst = r(srktstp)
					if (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
						local tmax = `thatc'
						local ettmax = `etptst'
					}
					else if (`etptst'>invnorm(1-(1-`alpha')/2) & sign(`ate')==1) | (`etptst'<invnorm(1-(1-`alpha')/2) & sign(`ate')==-1) {
						local tmin = `thatc'
						local ettmin = `etptst'
					}
					else if `etptst'==invnorm(1-(1-`alpha')/2) & abs(`tmax'-`tmin')<=(1/10^`acc') {
						local k1 = 1
					}
					else if `etptst'==invnorm(1-(1-`alpha')/2) & abs(`tmax'-`tmin')>(1/10^`acc') {
						/* search towards tmax */
						local rftmax = `tmax'
						local rftmin = `thatc'
						local rfeftmax = `ettmax'
						local rfeftmin = `etplus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							if "`exact'"=="" {
								srktst `cresp', g(`gamma')
							}
							else srktst_ex `cresp', g(`gamma')
							local rfetptst = r(srktstp)
							if (`rfetptst'<`rfeftmin' & sign(`ate')==1) | (`rfetptst'>`rfeftmin' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>=`rfeftmin' & sign(`ate')==1) | (`rfetptst'<=`rfeftmin' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmax = (`rftmax'+`rftmin')/2
						/* search towards tmin */
						local rftmin = `tmin'
						local rftmax = `thatc'
						local rfeftmin = `ettmin'
						local rfeftmax = `etplus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							if "`exact'"=="" {
								srktst `cresp', g(`gamma')
							}
							else srktst_ex `cresp', g(`gamma')
							local rfetptst = r(srktstp)
							if (`rfetptst'<=`rfeftmax' & sign(`ate')==1) | (`rfetptst'>=`rfeftmax' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>`rfeftmax' & sign(`ate')==1) | (`rfetptst'<`rfeftmax' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmin = (`rftmax'+`rftmin')/2
						local k1 = 1
					}
				}
			}
		return scalar ciu = (`tmax'+`tmin')/2

		/* lower bound gamma */
			/* fix search boundaries, start from that=0, steps of TE */
			local thatc = 0
			replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
			if "`exact'"=="" {
				srktst `cresp', g(`gamma')
			}
			else srktst_ex `cresp', g(`gamma')
			local etptst = r(srktstm)
			local j = 0
			while `j'==0 {
				if (`etptst'>invnorm((1-`alpha')/2)  & sign(`ate')==1) | (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==-1) {
					local tmin = `thatc'
					local ettmin = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' + `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstm)
						if (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm((1-`alpha')/2) & sign(`ate')==-1) {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm((1-`alpha')/2) & sign(`ate')==-1) {
					local tmax = `thatc'
					local ettmax = `etptst'
					local k = 0
					while `k'==0 {
						local thatc = `thatc' - `ate'
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstm)
						if (`etptst'>invnorm((1-`alpha')/2) & sign(`ate')==1) | (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==-1) {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}						
					}
					local k = 0
					local j = 1
				}
				else if `etptst'==invnorm((1-`alpha')/2) {
					if "`tmax'"~="" | "`tmin'"~="" {
						if "`tmax'"~="" & "`tmin'"=="" {
							local tmin = `thatc'
							local ettmin = `etptst'
							local k = 1
						}
						else {
							local tmax = `thatc'
							local ettmax = `etptst'
							local k = 1
						}
						local j = 1
					}
					else {
						local thatc = `thatc' + `ate'/2
						replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
						if "`exact'"=="" {
							srktst `cresp', g(`gamma')
						}
						else srktst_ex `cresp', g(`gamma')
						local etptst = r(srktstm)
					}
				}
			}

			/* line search up/down */
			/* narrowing boundaries until E(T+) = E(T) at one boundary */
			if `k'~=1 {
				local k1 = 0
				while abs(`tmax'-`tmin')>(1/10^`acc') & `k1'==0 {
					local thatc = (`tmax'+`tmin')/2
					replace `cresp' = round((`varlist'-`thatc')*10000000,1)/10000000
					if "`exact'"=="" {
						srktst `cresp', g(`gamma')
					}
					else srktst_ex `cresp', g(`gamma')
					local etptst = r(srktstm)
					if (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==1) | (`etptst'>invnorm((1-`alpha')/2) & sign(`ate')==-1) {
						local tmax = `thatc'
						local ettmax = `etptst'
					}
					else if (`etptst'>invnorm((1-`alpha')/2) & sign(`ate')==1) | (`etptst'<invnorm((1-`alpha')/2) & sign(`ate')==-1) {
						local tmin = `thatc'
						local ettmin = `etptst'
					}
					else if `etptst'==invnorm((1-`alpha')/2) & abs(`tmax'-`tmin')<=(1/10^`acc') {
						local k1 = 1
					}
					else if `etptst'==invnorm((1-`alpha')/2) & abs(`tmax'-`tmin')>(1/10^`acc') {
						/* search towards tmax */
						local rftmax = `tmax'
						local rftmin = `thatc'
						local rfeftmax = `ettmax'
						local rfeftmin = `etminus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							if "`exact'"=="" {
								srktst `cresp', g(`gamma')
							}
							else srktst_ex `cresp', g(`gamma')
							local rfetptst = r(srktstm)
							if (`rfetptst'<`rfeftmin' & sign(`ate')==1) | (`rfetptst'>`rfeftmin' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>=`rfeftmin' & sign(`ate')==1) | (`rfetptst'<=`rfeftmin' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmax = (`rftmax'+`rftmin')/2
						/* search towards tmin */
						local rftmin = `tmin'
						local rftmax = `thatc'
						local rfeftmin = `ettmin'
						local rfeftmax = `etminus'
						while abs(`rftmax'-`rftmin')>(1/10^`acc') {
							local rfthatc = (`rftmax'+`rftmin')/2
							replace `cresp' = round((`varlist'-`rfthatc')*10000000,1)/10000000
							if "`exact'"=="" {
								srktst `cresp', g(`gamma')
							}
							else srktst_ex `cresp', g(`gamma')
							local rfetptst = r(srktstm)
							if (`rfetptst'<=`rfeftmax' & sign(`ate')==1) | (`rfetptst'>=`rfeftmax' & sign(`ate')==-1) {
								local rftmax = `rfthatc'
								local rfettmax = `rfetptst'
							}
							else if (`rfetptst'>`rfeftmax' & sign(`ate')==1) | (`rfetptst'<`rfeftmax' & sign(`ate')==-1) {
								local rftmin = `rfthatc'
								local rfettmin = `rfetptst'
							}
						}
						local tmin = (`rftmax'+`rftmin')/2
						local k1 = 1
					}
				}
			}
		return scalar cil = (`tmax'+`tmin')/2
			}

	}
end			


