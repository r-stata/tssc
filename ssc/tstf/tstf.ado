*! v.1.0.1 21oct19 N.Orsini more flexibility on passing twoway options
*! v.1.0.0 5oct18 N.Orsini, Xing-Wu Zhou  

capture program drop tstf
program tstf, eclass   byable(onecall)
version 11

if _by() {
		local BY `"by `_byvars'`_byrc0':"'
}

`version' `BY' _vce_parserun tstf, mark(OFFset CLuster) : `0'

if "`s(exit)'" != "" {
		version 12: ereturn local cmdline `"tstf `0'"'
		exit
	}

if replay() {
		if ("`e(cmd)'"!="tstf")  error 301  
		Replay `0'
	}
else `version' `BY' Estimate `0'
end

capture program drop Estimate 
version 12, missing

program Estimate, eclass byable(recall)
	syntax varlist(min=1 max=2)  [if] [in]  ///
	    [,  Level(integer $S_level) ///
		ARIMA(numlist int min=3 max=3 >-1) ///	 
	    SARIMA(numlist int min=4 max=4 >-1)	///
		 pulse decay step smooth ///
	   INTdate(numlist int max=1) ///
	   Method(string) ///
	   pathr(string) Limit ///
	   Format(string) ///
	   TABulate GRData  GREffect  EForm  * ]
	   
    local cmdline : copy local 0

	marksample touse 
	
	// Get graph options 
	
   _get_gropts , graphopts(`options')
 	local options `"`s(graphopts)'"'

	 
	if "`intdate'" == "" {
		di _n as err "specify the intervention date"
		exit 198
	}
	 
	if "`pulse'" == "" & "`step'" == "" & "`decay'" == "" & "`smooth'" == "" {
		di _n as err "specify the type of transfer function"
		exit 198
	}
	local typetransf "`pulse' `step' `decay' `smooth'"
	local typetransf =  strtrim("`typetransf'")
	
if "`format'" == "" 	local format = "%3.2f"
	else local format = "`format'" 
	
// Check number of observations 

		quietly count if `touse'
		local nobs = r(N)
		if r(N)<4 { 
			di in red "insufficient observations"
			exit 2001
		}
		
// Check tsset

	capture quietly tsset
	local timevar "`r(timevar)'"
	if _rc != 0 {
		di as err _n "time variable not set; tsset the data"
		exit 198
	}
		
// Check ARIMA parameters

if "`arima'" != "" {
					local oarima `arima' 
					}
else {
	local arima `"1 0 0"'
	local oarima `"1 0 0"'
}
  
if "`sarima'" != "" {				
		local j = 1
		foreach k of numlist `sarima' {
				if `j' < 3 local osea1 "`osea1' `k' "
				if `j' == 3 local osea1 "`osea1' `k'"
				if `j' == 4 local osea2 "`k'"
				local j = `j' + 1
		}
}
else {
		local sarima `"0 0 0 1"'
		local osea1 "0 0 0"
		local osea2 "1"
}

// Remove collinear variables

	gettoken depv indepv : varlist		
	_rmcoll `indepv' [`weight'`exp'] 
	local indepv `r(varlist)' 

		// Check the optimization method 

	if "`method'" == "" local mopt "CSS-ML"
	else local mopt "`method'"
	
	if inlist("`mopt'", "CSS-ML", "ML", "CSS") != 1 {
			di as err `"`method'" not allowed"' 	
			exit 198
			}
			
// save a dataset in txt format

preserve  
quietly keep  if `touse' == 1
quietly keep `depv'  `indepv' `touse' `timevar'
    qui tsset  `timevar'
	local tmin  "`r(tmins)'"
	local tmax "`r(tmaxs)'"
	local dformat = "`r(tsfmt)'"
	
	// Check start intervention 
	
	local dsi : di `dformat' `intdate'
	tempname startint
	scalar `startint' = `intdate'

	// Generate the intervention indicator variable 

	
	tempvar intv
	
	if "`pulse'" != "" {
		gen `intv' = (`timevar'==`startint')
		local oint `"0,0"'
	}	
	
	if "`decay'" != "" {
		gen `intv' = (`timevar'==`startint')
		local oint `"1,0"'
	}	
	
	if "`step'" != "" {
		gen `intv' = (`timevar'>=`startint')
		local oint `"0,0"'
	}	
	
	if "`smooth'" != "" {
		gen `intv' = (`timevar'>=`startint')
		local oint `"1,0"'
	}	

	/*
 if "`ramppulse'" != "" | "`decay_rp'" != "" {
   		gen `intv' = (`timevar'==`startint')
		local oint `"1,0"'
		  

		 local np : word 1 of `oarima'
		 local nd : word 2 of `oarima'
		 local nq : word 3 of `oarima'
 
		 local nP : word 1 of `sarima'
		 local nD : word 2 of `sarima'
		 local nQ : word 3 of `sarima'

		if `nd'+`nD' == 0 local tot_nr_par = `np'+`nq'+`nP' + `nQ' + 1
		else local tot_nr_par = `np'+`nq'+`nP' + `nQ'  
		
		 forv i = 1/`tot_nr_par' {
			local passconstr "`passconstr' NA ,"
		 }
		 
		 if "`decay_rp'" != "" local passconstr "`passconstr' NA, NA, "
			local passconstr "`passconstr' 1 , NA "
			local passconstr "c(`passconstr')"

}
*/
		 local i = 1
		 foreach x of local oarima {
				if `i' < 3 local pass_arima "`pass_arima' `x',"
				if `i' == 3 local pass_arima "`pass_arima' `x'"
				local i = `i' + 1
		 }
		 
		  local i = 1
		 foreach x of local osea1 {
				if `i' < 3 local pass_sarima "`pass_sarima' `x',"
				if `i' == 3 local pass_sarima "`pass_sarima' `x'"
				local i = `i' + 1
		 }

	 
gen IVAR = `intv'

quietly saveold `"data_tstf"' , replace nolabel version(11)

		* Eventually erase previously created datasets
		quietly {
		capture rm `"_tstf_b.dta"'
		capture rm `"_tstf_V.dta"'
		capture rm `"_tstf_stats.dta"'
		}  
	 
 // make sure -rsource- is installed 

quietly capture which rsource
if _rc != 0 qui ssc install rsource
 
// create a file with the R syntax and get results
 
  	local cwd `c(pwd)'
  	if "`c(os)'" == "Windows" local cwd : subinstr local cwd "\" "/" , all  

	quietly {
    tempname cmdr
    file open 	`cmdr'  using "tstf_to_r.R",  write text replace all   
	file write  `cmdr'  `"setwd("`cwd'")"' _n 
	file write  `cmdr'  `"rm(list=ls())"' _n
	file write  `cmdr'  "library(stats)" _n	
	file write  `cmdr'  "library(foreign)"  _n
	file write  `cmdr'  "library(TSA)"  _n
	file write  `cmdr'  "library(car)"  _n
	file write  `cmdr'  "library(aod)"  _n
	file write  `cmdr'  `"mydata <- read.dta("data_tstf.dta")"' _n
    file write  `cmdr'   "datatstf <- data.frame(mydata)" _n
	file write  `cmdr'  `"fit.arimax <- arimax(datatstf[["`depv'"]], "' _n
	file write  `cmdr'  `"order=c(`pass_arima'), "' _n
	file write  `cmdr'  `"seasonal=list(order=c(`pass_sarima'), period=`osea2'), "' _n
	file write  `cmdr'  `"include.mean = TRUE, "' _n
	file write  `cmdr'  `"xtransf = datatstf[["IVAR"]], transfer=list(c(`oint')), "' _n
*	if "`decay_rp'" != ""  file write  `cmdr'  `"xtransf = cbind(datatstf[["IVAR"]], datatstf[["IVAR"]]) , transfer=list(c(`oint'),c(`oint')), "' _n
*	if "`ramppulse'" != "" | "`decay_rp'" != "" file write  `cmdr'  `"fixed= `passconstr', "' _n
	file write  `cmdr'  `"method = "`mopt'" ) "' _n
	file write  `cmdr'  `"beta = data.frame(names = attr(fit.arimax[["coef"]], "names"), beta = fit.arimax[["coef"]])"' _n
	file write  `cmdr'  `"varcov = data.frame(fit.arimax[["var.coef"]])"' _n
	file write  `cmdr'  `"stats = data.frame(sigma2 = fit.arimax[["sigma2"]], loglik = fit.arimax[["loglik"]], "' _n
	file write  `cmdr'  `"aic = fit.arimax[["aic"]])"' _n
	file write  `cmdr'  `"write.dta(beta, file = "`cwd'/_tstf_b.dta")"' _n
	file write  `cmdr'  `"write.dta(varcov, file = "`cwd'/_tstf_V.dta")"' _n
	file write  `cmdr'  `"write.dta(stats, file = "`cwd'/_tstf_stats.dta")"' _n
	file close  `cmdr' 

   if ("`pathr'" != "") rsource using "`cwd'/tstf_to_r.R" , noloutput  lsource roptions(--slave)  rpath(`"`pathr'"')
   else rsource using "`cwd'/tstf_to_r.R" , noloutput  lsource roptions(--slave) rpath("/usr/local/bin/R")
  }

tempname b V

//  Get b  
 
capture confirm file _tstf_b.dta
if _rc != 0 {
    	      di as err _n "the R script did not run, see what's wrong in the file tstf_to_r.R"
			  viewsource tstf_to_r.R
			  exit 198   
   		 }

	quietly use `"_tstf_b.dta"', clear
	 
	qui decode names, gen(snames)
	qui replace snames = "_cons" if snames == "intercept"
	qui replace snames = lower(snames)
	qui replace snames = regexr(snames,"-", "_") 
	qui replace snames = "omega" if snames == "t1_ma0" 
	qui replace snames = "delta" if snames == "t1_ar1" 

	*if "`ramppulse'" != "" qui drop if snames == "delta"
	/*
	if "`decay_rp'" != "" {
			qui replace snames = "gamma" if snames == "t2_ma0" 
			qui drop if snames == "t2_ar1"
	}
	*/
	
	qui count
	mat `b' = J(1, `r(N)', .)
	qui forv i = 1/`r(N)' {
		if (inlist(snames[`i'],"delta", "omega", "gamma")!= 1) local eqnames "`eqnames' ARIMA"
		else local eqnames "`eqnames' TRANSFER"
		mat `b'[1,`i'] = `=beta[`i']'
		local conams "`conams' `=snames[`i']'"
	} 

     mat colnames `b' = `conams'
	 mat coleq `b' = `eqnames'
     mat rownames `b' = `depv'
 
	 
//  Get V   
	
	quietly use `"_tstf_V.dta"', clear
	
	tempname V
	mkmat * , matrix(`V')
	mat rownames `V' = `conams'
	mat colnames `V' = `conams'
	mat coleq `V' = `eqnames'
	mat roweq `V' = `eqnames'
  
// Get additional statistics

	tempname sigma2 loglik aic
	quietly use `"_tstf_stats.dta"' , clear
	scalar `sigma2' = sigma2[1]
	scalar `loglik' = loglik[1]
	scalar `aic' = aic[1]

// Display results 
 	
 		qui use `"data_tstf.dta"' , clear
		
		if ("`tabulate'" != "") | ("`grdata'" != "") | ("`greffect'" != "")  {
				
				tempname E VE ebeta v_ebeta pe vse_eb
				tempvar vb vse_b vtime vp vlb vub

				/*
				if "`decay_rp'" != "" {
					mat `E' = `b'[1, "TRANSFER:delta".."TRANSFER:gamma"]
					mat `VE' = `V'["TRANSFER:delta".."TRANSFER:gamma", "TRANSFER:delta".."TRANSFER:gamma"]
				}
				
				if "`ramppulse'" != "" {
					mat `E' = `b'[1, "TRANSFER:omega"]
					mat `VE' = `V'["TRANSFER:omega", "TRANSFER:omega"]
				}
				*/
				if "`smooth'" != "" |  "`decay'" != "" {
					mat `E' = `b'[1, "TRANSFER:delta".."TRANSFER:omega"]
					mat `VE' = `V'["TRANSFER:delta".."TRANSFER:omega", "TRANSFER:delta".."TRANSFER:omega"]
				}

				if "`step'" != "" |  "`pulse'" != "" {
					mat `E' = `b'[1, "TRANSFER:omega"]
					mat `VE' = `V'["TRANSFER:omega", "TRANSFER:omega"]
				}
				
				qui gen double `vb' = .
				qui gen double `vse_b' = .
				qui gen double `vtime' = .

		 		// get the start of intervention
				
				tempvar k 
				qui gen `k' = `timevar' - `startint'
				
				if "`decay'" != "" {
				   * if |abs(delta)| > 1
					if abs(`E'[1,1]) > 1 {
						di as err "specify another transfer function"
						exit 198
					}
					
				}
				
				ereturn post `E' `VE'
				qui levelsof `k', local(levels)
				local j 1
				qui foreach t of local levels {						
						if (`t' >= 0) {
       					   if  "`pulse'" != ""  qui nlcom  _b[omega] 
       					   if  "`decay'" != ""  qui nlcom  _b[omega]*_b[delta]^`t'
						   if  "`smooth'" != "" qui nlcom  _b[omega]*(1-(_b[delta])^(`t'+1))/(1-_b[delta]) 
						   if "`step'" != ""    qui nlcom  _b[omega] 
						  * if "`ramppulse'" != "" qui nlcom  _b[omega] 
						  * if "`decay_rp'" != "" qui nlcom  (_b[omega]*_b[delta]^`t') + _b[gamma]
						   
						    mat `ebeta' = r(b)
							scalar `pe' = `ebeta'[1,1]
							mat `v_ebeta' = r(V)
							scalar `vse_eb'= sqrt(`v_ebeta'[1,1])
							qui replace `vtime' = `t' in `j'
							qui replace `vb' =  `pe' in `j'
							qui replace `vse_b' =  `vse_eb' in `j'
						}
						local j = `j' + 1
				}
				
       			if  "`pulse'" != ""  {
				            qui replace `vb' = 0 if `k' != 0
				            qui replace `vse_b' = 0 if `k' != 0
				}
				
				tempvar pred_ai
				qui gen double `pred_ai' = `depv' - `vb'
				
				qui replace `vb' = 0 if `vb' == . 
				
					qui gen `vlb' = (`vb'-invnorm(.975)*`vse_b')
					qui gen `vub' = (`vb'+invnorm(.975)*`vse_b')
					qui gen `vp' =  normal(-abs(`vb'/`vse_b'))*2
			
					char `vtime' [varname] "k" 
					char `vb' [varname] "Effect" 
					char `vlb' [varname] "LB" 
					char `vub' [varname] "UB" 
					char `vp' [varname] "P-value" 	
					
		  			
			if "`eform'" != "" {
					qui replace `vb' = exp(`vb')
					qui replace `vlb' = exp(`vlb')
					qui replace `vub' = exp(`vub')
					char `vb' [varname] "exp(Eff)" 

			}	 

			
			format   `vb' `vlb' `vub'  `format'
			format `vp' %4.3f
				
		}
		
  		ereturn post `b' `V', obs(`nobs')  depn(`depv') 
		ereturn repost, esample(`touse')

		ereturn local depvar "`depv'"

		ereturn local method "`mopt'"
		ereturn local cmdline `"tstf `cmdline'"'
		ereturn local cmd "tstf"
	    ereturn local depvar "`depv'"
		ereturn scalar ll = `loglik'
		ereturn scalar sigma2 = `sigma2'
		ereturn scalar aic = `aic'
		ereturn local tmax = "`tmax'"
		ereturn local tmin = "`tmin'"
		ereturn local dateint = "`dsi'"

		di _n in gr "ARIMA regression with a " as res "`typetransf'" in gr " transfer function"       _c
		di as txt _col(53) "No. of obs    = " as res %10.0g e(N)
		di as txt "Optimization = " as res "`e(method)'" 
		di  as txt "Log likelihood = " as res `e(ll)'
		di as txt "Sample = " as res "`e(tmin)' - `e(tmax)'" as txt "   Intervention starts = " as res  "`e(dateint)'"

ereturn display, level(`level')  

		if ("`tabulate'" != "")  {	
			
			di as txt _n  "Table of effects {it:k} units of time after intervention" 

			if "`pulse'" == "" list   `timevar' `vtime' `vb' `vlb' `vub' `vp' if `vtime' != . , clean  noobs  subvarname		
            else list   `timevar' `vtime' `vb' `vlb' `vub' `vp' if `vp' !=  ., clean  noobs  subvarname
		
		}
	
		if ("`greffect'" != "") {

			local passingytitle `"ytitle(Effect)"'

			if "`eform'" != "" {
					local passinglogscale `"yscale(log)"'
					local passingytitle `"ytitle(exp(Effect))"'
			 }

			 twoway ///
				(scatter `vb' `timevar'  , sort mc(black) ms(o) c(l) lp(dot)) , ///
				ylabel(#10, angle(horiz)) `passingytitle' ///
				legend(off) xline(`=`startint'' , lp(dash) lc(gs10) )  `passinglogscale'  plotregion(style(none)) ///
				`options'
		}
		
		
		if ("`grdata'" != "") {
		
		     if "`eform'" != "" {
					qui replace `pred_ai'  = exp(`pred_ai')
					qui replace `depv'  = exp(`depv')
					local passinglogscale "yscale(log)"
					local passingytitle `"ytitle(exp(`depv'))"'
			 }
			 
			
				twoway ///
				(scatter `depv' `timevar' if `intv' ==0 , sort mc(black) ms(o) c(l) lp(dot)) ///
				(scatter  `depv' `timevar' if `intv' ==1 , sort mc(black) ms(T) c(l) lp(dot)) ///		
				(scatter  `pred_ai'  `timevar' if `intv' ==1 & `pred_ai' != ., sort mc(gs10) ms(o) c(l) lp(dot)) ///
				,  xline(`=`startint'' , lp(dash) lc(gs10) ) ytitle(`passingytitle') ylabel(#10, angle(horiz))  ///
				 `passinglogscale'  `passingytitle' legend(off)  plotregion(style(none)) `options'
		}

end

capture program drop Replay
program Replay
	syntax [, Level(cilevel) ]
	ereturn display, level(`level')  
end

exit

use http://www.stats4life.se/data/quitline, clear
keep if inrange(time, mofd(mdy(1,1, 2001)), mofd(mdy(5, 31, 2005)))
tsset time, monthly
tstf lograte  , step int(`=mofd(mdy(9,1,2002))')  tabulate greffect


