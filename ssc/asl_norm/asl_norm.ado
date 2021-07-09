*! version 1.0.3 14May2013 MLB
* compute the ASL as (k + 1) / (B + 1) instead of k/B, see the help-file for why
* base the MCCI on the corresponding beta distribution
* added the saving() option

*! version 1.0.2 22Jan2013 MLB
* removed -ksmirnov- as it is just too problematic
* added the separate skewness and kurtosis tests from -sktest-

*! version 1.0.1 21Jan2013 MLB
* Added tests from -mvtest normal-, -sktest-, -swilk-, -sfrancia-, and -ksmirnov-

*! version 1.0.0 20Jan2013 MLB
* published on Statalist:
* http://www.stata.com/statalist/archive/2013-01/msg00856.html
program define asl_norm, rclass
	version 11
	syntax varname [if] [in],         ///
    [                                 ///
	DHansen                           ///
	HZirkler                          ///
	MKUrtosis                         ///
	MSKEWness                         ///
	JBtest                            ///
	SKtest                            ///
	SKEWness                          /// 
	KUrtosis                          ///
	SWilk                             /// 
	SFrancia                          /// 
	all                               ///
	fast                              ///
    reps(numlist max=1 integer >0)    ///
    nodots                            ///
	SAving(string)                    ///  
    mcci(cilevel)                     ///
    ]

	marksample touse
	qui count if `touse'
	if r(N) == 0 exit 2000
	local n = r(N)
	
	// defaults
    if "`reps'" == "" {
        local reps = 1000
    }
	if "`all'" != "" {
		local jbtest "jbtest"
		local sktest "sktest"
		local skewness "skewness"
		local kurtosis "kurtosis"
		if `n' >= 4 & `n' <= 2000 local swilk "swilk"
		if `n' >= 5 & `n' <= 5000 local sfrancia "sfrancia"
		local dhansen "dhansen"
		local hzirkler "hzirkler"
		local mskewness "mskewness"
		local mkurtosis "mkurtosis"
	}
	if "`fast'" != "" {
		local jbtest "jbtest"
		local sktest "sktest"
		local skewness "skewness"
		local kurtosis "kurtosis"
		if `n' >= 4 & `n' <= 2000 local swilk "swilk"
		if `n' >= 5 & `n' <= 5000 local sfrancia "sfrancia"
		local dhansen "dhansen"
		local mkurtosis "mkurtosis"
	}

	if "`jbtest'`sktest'`skewness'`kurtosis'`swilk'`sfrancia'`dhansen'`hzirkler'`mkurtosis'`mskewness'" == "" {
		if `n' <= 2000 {
			local swilk "swilk"
		}
		else if `n' <= 5000 {
			local sfrancia "sfrancia"
		}
		else {
			local sktest "sktest"
		}
	}
	
	// checks
	if "`swilk'" != "" & ( `n' < 4 | `n' > 2000 ) {
		di as err "Shapiro-Wilk test only valid for 4<=n<=2000"
		exit 198
	}
	if "`sfrancia'" != "" & ( `n' < 5 | `n' > 5000 ) {
		di as err "Shapiro-Francia test only valid for 5<=n<=5000"
		exit 198
	}
	if "`sktest'" != "" & `n' < 8 {
		di as err "skewness kurtosis test only valid for n >= 8
	}
	
	// prepare the saving option
	if `"`saving'"' != "" {
		Parsesaving `saving'
		local filename `"`r(filename)'"'
		local replace   "`r(replace)'"
		local double    "`r(double)'"
		local every     "`r(every)'"
		
		local stats2save `dhansen' `hzirkler' `mkurtosis' `mskewness' `sfrancia' `swilk' `sktest' `skewness' `kurtosis' `jbtest'  
		local stats2save : list retokenize stats2save
		if "`double'" != "" {
			local stats2save : subinstr local stats2save " " " double ", all
			local stats2save "double " `stats2save'
		}
		tempname memhold pval
		postfile `memhold' `stats2save' using `"`filename'"', `replace' `every'
	}
	
	// preparation for simulation
	tempname  m sd alph
    tempvar x
	qui sum `varlist' if `touse'
	scalar `m'   = r(mean)
    scalar `sd'  = r(sd)
    qui gen `x' = .
    
	if "`dhansen'`hzirkler'`mkurtosis'`mskewness'" != "" {
		if "`mskewness'" != "" local stats "skewness"
		if "`mkurtosis'" != "" local stats "`stats' kurtosis"
		qui mvtest normality `varlist' if `touse' , stats(`dhansen' `hzirkler' `stats')
		if "`dhansen'" != "" {
			tempname dh dhp asl_dh count_dh lb_dh ub_dh
			scalar `dh' = r(chi2_dh)
			scalar `dhp' = r(p_dh)
			scalar `asl_dh' = 0
			scalar `count_dh' = 0
		}	
		if "`hzirkler'" != "" {
			tempname hz hzp asl_hz count_hz lb_hz ub_hz
			scalar `hz' =  r(z_hz)^2
			scalar `hzp' = r(p_hz)
			scalar `asl_hz' = 0
			scalar `count_hz' = 0
		}
		if "`mkurtosis'" != "" {
			tempname mku mkup asl_mku count_mku lb_mku ub_mku
			scalar `mku' = r(chi2_mkurt)
			scalar `mkup' = r(p_mkurt)
			scalar `asl_mku' = 0
			scalar `count_mku' = 0
		}
		if "`mskewness'" != "" {
			tempname mskew mskewp asl_mskew count_mskew lb_mskew ub_mskew
			scalar `mskew' = r(chi2_mskew)
			scalar `mskewp' = r(p_mskew)
			scalar `asl_mskew' = 0
			scalar `count_mskew' = 0
		}	
	}
	
    if "`sfrancia'" != "" {
		tempname sf sfp asl_sf count_sf lb_sf ub_sf
		if c(stata_version) >=12 {
			version 12: qui sfrancia `varlist' if `touse'
		}
		else {
			qui sfrancia `varlist' if `touse'
		}
		scalar `sf' = r(z)
		scalar `sfp' = r(p)
		scalar `asl_sf' = 0
		scalar `count_sf' = 0
	}
	if "`swilk'" != "" {
		tempname sw swp asl_sw count_sw lb_sw ub_sw
		qui swilk `varlist' if `touse'
		scalar `sw' = r(z)
		scalar `swp' = r(p)
		scalar `asl_sw' = 0
		scalar `count_sw' = 0
	}
	if "`sktest'`skewness'`kurtosis'" != "" {
		qui sktest `varlist' if `touse'
		if r(chi2) == . {
			qui sktest `varlist' if `touse' , noadjust
			local noadjust "noadjust"
		}
		if "`sktest'" != "" {
			tempname sk skp asl_sk count_sk lb_sk ub_sk
			scalar `sk' = r(chi2)
			scalar `skp' = r(P_chi2)
			scalar `asl_sk' = 0
			scalar `count_sk' = 0
		}
		if "`skewness'" != "" {
			tempname skew skewp asl_skew count_skew lb_skew ub_skew
			scalar `skew' = invchi2tail(1,r(P_skew))
			scalar `skewp' = r(P_skew)
			scalar `asl_skew' = 0
			scalar `count_skew' = 0
		}
		if "`kurtosis'" != "" {
			tempname ku kup asl_ku count_ku lb_ku ub_ku
			scalar `ku' = invchi2tail(1,r(P_kurt))
			scalar `kup' = r(P_kurt)
			scalar `asl_ku' = 0
			scalar `count_ku' = 0
		}
	}
	if "`jbtest'" != "" {
		tempname jb jbp asl_jb sim_jb count_jb lb_jb ub_jb
		qui sum `varlist' if `touse', detail
		scalar `jb'  = (r(N)/6) * ///
					   (r(skewness)^2 + 1/4*(r(kurtosis) - 3)^2)
		scalar `jbp' = chi2tail(2,`jb')
		scalar `asl_jb' = 0
		scalar `count_jb' = 0
	}

	// simulate
    if "`dots'" == "" {
        _dots 0, title(computing ASL) reps(`reps')
    }
    forvalues i = 1/`reps' {
		local problem = 0
		if `"`saving'"' != "" local savingstats ""
		qui replace `x' = rnormal(`m',`sd') if `touse'
		if "`dhansen'`hzirkler'`mkurtosis'`mskewness'" != "" {
			capture mvtest normality `x' if `touse' , stats(`dhansen' `hzirkler' `stats')
			local problem = `problem'*_rc
			if "`dhansen'" != "" {
				capture {
					scalar `asl_dh' = `asl_dh' + (r(chi2_dh) > `dh' & r(chi2_dh) < .)
					if `"`saving'"' != "" local savingstats (`r(chi2_dh)')
					assert r(chi2_dh) < .
					scalar `count_dh' = `count_dh' + 1
				}
				local problem = `problem'*_rc
			}
			if "`hzirkler'" != "" {
				capture {
					scalar `asl_hz' = `asl_hz' + (r(z_hz)^2 > `hz' & r(z_hz)^2 < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`=r(z_hz)^2')
					assert r(z_hz)^2 < .
					scalar `count_hz' = `count_hz' + 1
				}
				local problem = `problem'*_rc
			}
			if "`mkurtosis'" != "" {
				capture {
					scalar `asl_mku' = `asl_mku' + (r(chi2_mkurt) > `mku' & r(chi2_mkurt) < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`r(chi2_mkurt)')
					assert r(chi2_mkurt) < .
					scalar `count_mku' = `count_mku' + 1
				}
				local problem = `problem'*_rc
			}
			if "`mskewness'" != "" {
				capture {
					scalar `asl_mskew' = `asl_mskew' + (r(chi2_mskew) > `mskew' & r(chi2_mskew) < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`r(chi2_mskew)')
					assert r(chi2_mskew) < .
					scalar `count_mskew' = `count_mskew' + 1
				}
				local problem = `problem'*_rc
			}
		}
		if "`sfrancia'" != "" {
			capture {
				sfrancia `x' if `touse'
				scalar `asl_sf' = `asl_sf' + (r(z) > `sf' & r(z) < .)
				if `"`saving'"' != "" local savingstats `savingstats' (`r(z)')
				assert r(z) < .
				scalar `count_sf' = `count_sf' + 1
			}
			local problem = `problem'*_rc
		}
		if "`swilk'" != "" {
			capture {
				swilk `x' if `touse'
				scalar `asl_sw' = `asl_sw' + (r(z) > `sw' & r(z) < .)
				if `"`saving'"' != "" local savingstats `savingstats' (`r(z)')
				assert r(z) < .
				scalar `count_sw' = `count_sw' + 1
			}
			local problem = `problem'*_rc
		}
		if "`sktest'`skewness'`kurtosis'" !="" {
			capture sktest `x' if `touse', `noadjust'
			local problem = `problem'*_rc
			if "`sktest'" != "" {
				capture {
					scalar `asl_sk' = `asl_sk' + (r(chi2) > `sk' & r(chi2) < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`r(chi2)')
					assert r(chi2) < .
					scalar `count_sk' = `count_sk' + 1
				}
				local problem = `problem'*_rc
			}
			if "`skewness'" != "" {
				capture {
					scalar `asl_skew' = `asl_skew' + (invchi2tail(1,r(P_skew)) > `skew' & invchi2tail(1, r(P_skew)) < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`=invchi2tail(1, r(P_skew))')
					assert invchi2tail(1,r(P_skew)) < .
					scalar `count_skew' = `count_skew' + 1
				}
			}
			if "`kurtosis'" != "" {
				capture {
					scalar `asl_ku' = `asl_ku' + (invchi2tail(1,r(P_kurt)) > `ku' & invchi2tail(1,r(P_kurt)) < .)
					if `"`saving'"' != "" local savingstats `savingstats' (`=invchi2tail(1, r(P_kurt))')
					assert invchi2tail(1,r(P_kurt)) < .
					scalar `count_ku' = `count_ku' + 1			
				}
			}
		}
		if "`jbtest'" != "" {
			capture {
				sum `x' if `touse', detail
				scalar `sim_jb' = (r(N)/6) * ///
								  (r(skewness)^2 + 1/4*(r(kurtosis) - 3)^2)
				scalar `asl_jb' = `asl_jb' + (`sim_jb' > `jb' & `sim_jb' < .)
				if `"`saving'"' != "" local savingstats `savingstats' (`sim_jb')
				assert `sim_jb' < .
				scalar `count_jb' = `count_jb' + 1
			}
			local problem = `problem'*_rc
        }
        if "`dots'" == "" {
            _dots `i' `=`problem'>0'
        }
		if `"`saving'"' != "" post `memhold' `savingstats'
    }
	if `"`saving'"' != "" {
		postclose `memhold'
	}
	
	// display and return results
    scalar `alph' = (100-`mcci')/200
	local ndecimal = min(ceil(log10(`reps'+1)),4)
	local aslfmt "%`=`ndecimal'+2'.`ndecimal'f"
	
	if "`dhansen'" != "" {
		local a = `asl_dh' +1
		local b = `count_dh' + 1 - `asl_dh'
		scalar `lb_dh' = invibeta(`a', `b', `alph')
		scalar `ub_dh' = invibetatail(`a', `b', `alph')
		scalar `asl_dh' = (`asl_dh'+1)/(`count_dh'+1)
		di _n
		di as txt "Doornik-Hansen test statistic (chi2(2)):    " as result %-6.2f `dh'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `dhp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_dh'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_dh' as txt ", " as result `aslfmt' `ub_dh' as txt "]"

		return scalar ub_dh      = `ub_dh'
		return scalar lb_dh      = `lb_dh'
		return scalar N_dh       = `count_dh'
		return scalar p_asymp_dh = `dhp'
		return scalar asl_dh     = `asl_dh'
		return scalar dh         = `dh'
	}
	if "`hzirkler'" != "" {
		local a = `asl_hz' + 1
		local b = `count_hz' + 1 - `asl_hz'
		scalar `lb_hz' = invibeta(`a', `b', `alph')
		scalar `ub_hz' = invibetatail(`a', `b', `alph')
		scalar `asl_hz' = (`asl_hz'+1)/(`count_hz'+1)
		di _n
		di as txt "Henze-Zirkler test statistic (chi2(1)):     " as result %-6.2f `hz'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `hzp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_hz'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_hz' as txt ", " as result `aslfmt' `ub_hz' as txt "]"

		return scalar ub_hz      = `ub_hz'
		return scalar lb_hz      = `lb_hz'
		return scalar N_hz       = `count_hz'
		return scalar p_asymp_hz = `hzp'
		return scalar asl_hz     = `asl_hz'
		return scalar hz         = `hz'
	}
	if "`mkurtosis'" != "" {
		local a = `asl_mku' + 1
		local b = `count_mku' + 1 - `asl_mku'
		scalar `lb_mku' = invibeta(`a', `b', `alph')
		scalar `ub_mku' = invibetatail(`a', `b', `alph')
		scalar `asl_mku' = (`asl_mku'+1)/(`count_mku'+1)
		di _n
		di as txt "Mardia's kurtosis test statistic (chi2(1)): " as result %-6.2f `mku'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `mkup'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_mku'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_mku' as txt ", " as result `aslfmt' `ub_mku' as txt "]"

		return scalar ub_mku      = `ub_mku'
		return scalar lb_mku      = `lb_mku'
		return scalar N_mku       = `count_mku'
		return scalar p_asymp_mku = `mkup'
		return scalar asl_mku     = `asl_mku'
		return scalar mku         = `mku'
	}
	if "`mskewness'" != "" {
		local a = `asl_mskew' + 1
		local b = `count_mskew' + 1 - `asl_mskew'
		scalar `lb_mskew' = invibeta(`a', `b', `alph')
		scalar `ub_mskew' = invibetatail(`a', `b', `alph')
		scalar `asl_mskew' = (`asl_mskew'+1)/(`count_mskew'+1)
		di _n
		di as txt "Mardia's skewness test statistic (chi2(1)): " as result %-6.2f `mskew'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `mskewp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_mskew'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_mskew' as txt ", " as result `aslfmt' `ub_mskew' as txt "]"

		return scalar ub_mskew      = `ub_mskew'
		return scalar lb_mskew      = `lb_mskew'
		return scalar N_mskew       = `count_mskew'
		return scalar p_asymp_mskew = `mskewp'
		return scalar asl_mskew     = `asl_mskew'
		return scalar mskew         = `mskew'
	}
	if "`sfrancia'" != "" {
		local a = `asl_sf' + 1
		local b = `count_sf' + 1 - `asl_sf'
		scalar `lb_sf' = invibeta(`a', `b', `alph')
		scalar `ub_sf' = invibetatail(`a', `b', `alph')
		scalar `asl_sf' = (`asl_sf'+1)/(`count_sf'+1)
		di _n
		di as txt "Shapiro-Francia test statistic (z):         " as result %-6.2f `sf'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `sfp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_sf'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_sf' as txt ", " as result `aslfmt' `ub_sf' as txt "]"

		return scalar ub_sf      = `ub_sf'
		return scalar lb_sf      = `lb_sf'
		return scalar N_sf       = `count_sf'
		return scalar p_asymp_sf = `sfp'
		return scalar asl_sf     = `asl_sf'
		return scalar sf         = `sf'
	}
	if "`swilk'" != "" {
		local a = `asl_sw' + 1
		local b = `count_sw' + 1 - `asl_sw'
		scalar `lb_sw' = invibeta(`a', `b', `alph')
		scalar `ub_sw' = invibetatail(`a', `b', `alph')
		scalar `asl_sw' = (`asl_sw'+1)/(`count_sw'+1)
		di _n
		di as txt "Shapiro-Wilk test statistic (z):            " as result %-6.2f `sw'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `swp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_sw'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_sw' as txt ", " as result `aslfmt' `ub_sw' as txt "]"

		return scalar ub_sw      = `ub_sw'
		return scalar lb_sw      = `lb_sw'
		return scalar N_sw       = `count_sw'
		return scalar p_asymp_sw = `swp'
		return scalar asl_sw     = `asl_sw'
		return scalar sw         = `sw'
	}
	if "`sktest'" != "" {
		local a = `asl_sk' + 1
		local b = `count_sk' + 1 - `asl_sk'
		scalar `lb_sk' = invibeta(`a', `b', `alph')
		scalar `ub_sk' = invibetatail(`a', `b', `alph')
		scalar `asl_sk' = (`asl_sk'+1)/(`count_sk'+1)
		di _n
		di as txt "Skewness/Kurtosis test statistic (chi2(2)): " as result %-6.2f `sk'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `skp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_sk'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_sk' as txt ", " as result `aslfmt' `ub_sk' as txt "]"

		if "`noadjust'" != "" return local sk_noadjust "noadjust"
		return scalar ub_sk      = `ub_sk'
		return scalar lb_sk      = `lb_sk'
		return scalar N_sk       = `count_sk'
		return scalar p_asymp_sk = `skp'
		return scalar asl_sk     = `asl_sk'
		return scalar sk         = `sk'
	}
	if "`skewness'" != "" {
		local a = `asl_skew' + 1
		local b = `count_skew' + 1 - `asl_skew'
		scalar `lb_skew' = invibeta(`a', `b', `alph')
		scalar `ub_skew' = invibetatail(`a', `b', `alph')
		scalar `asl_skew' = (`asl_skew'+1)/(`count_skew'+1)
		di _n
		di as txt "Skewness test statistic (chi2(1)):          " as result %-6.2f `skew'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `skewp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_skew'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_skew' as txt ", " as result `aslfmt' `ub_skew' as txt "]"

		if "`noadjust'" != "" return local skew_noadjust "noadjust"
		return scalar ub_skew      = `ub_skew'
		return scalar lb_skew      = `lb_skew'
		return scalar N_skew       = `count_skew'
		return scalar p_asymp_skew = `skewp'
		return scalar asl_skew     = `asl_skew'
		return scalar skew         = `skew'
	}
	if "`kurtosis'" != "" {
		local a = `asl_ku' + 1
		local b = `count_ku' + 1 - `asl_ku'
		scalar `lb_ku' = invibeta(`a', `b', `alph')
		scalar `ub_ku' = invibetatail(`a', `b', `alph')
		scalar `asl_ku' = (`asl_ku'+1)/(`count_ku'+1)
		di _n
		di as txt "Kurtosis test statistic (chi2(1)):          " as result %-6.2f `ku'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `kup'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_ku'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_ku' as txt ", " as result `aslfmt' `ub_ku' as txt "]"

		if "`noadjust'" != "" return local ku_noadjust "noadjust"
		return scalar ub_ku      = `ub_ku'
		return scalar lb_ku      = `lb_ku'
		return scalar N_ku       = `count_ku'
		return scalar p_asymp_ku = `kup'
		return scalar asl_ku     = `asl_ku'
		return scalar ku         = `ku'
	}
	if "`jbtest'" != "" {
		local a = `asl_jb' + 1
		local b = `count_jb' + 1 - `asl_jb'
		scalar `lb_jb' = invibeta(`a', `b', `alph')
		scalar `ub_jb' = invibetatail(`a', `b', `alph')
		scalar `asl_jb' = (`asl_jb'+1)/(`count_jb'+1)
		di _n
		di as txt "Jarque-Bera test statistic (chi2(2)):       " as result %-6.2f `jb'
		di as txt "asymptotic p-value:                         " as result `aslfmt' `jbp'
		di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl_jb'
		di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
		di as result `aslfmt' `lb_jb' as txt ", " as result `aslfmt' `ub_jb' as txt "]"

		return scalar ub_jb      = `ub_jb'
		return scalar lb_jb      = `lb_jb'
		return scalar N_jb       = `count_jb'
		return scalar p_asymp_jb = `jbp'
		return scalar asl_jb     = `asl_jb'
		return scalar jb         = `jb'
	}
end

// Parse the saving() option
program define Parsesaving, rclass 
	syntax [ anything(name=filename everything) ] [, replace DOUBle EVery(numlist min=1 max=1 integer > 0)]
	
	if `"`filename'"' == "" & "`replace'`double'" != "" {
		di as err "need to specify a file name when specifying the replace or the double option inside the saving() option"
		exit 198
	}
	if "`replace'" == "" & `"`filename'"' != "" {
		confirm new file `filename'
	}
	return local filename `filename'
	return local replace `replace'
	return local double `double'
	if "`every'" != "" {
		return local every "every(`every')"
	}
end
