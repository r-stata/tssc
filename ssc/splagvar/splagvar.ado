*! Program to calculate spatially lagged variables, construct Moran scatter plot,
*! calculate Moran's I, create quasi-instruments 
*! Version 1.0.0
*! Date: 01-15-2009
*! Author: P. Wilner Jeanty
*! 1.0.1 April 2011: Option equation() added
prog define splagvar
	version 10.1
	syntax [varlist(default=none)] [if] [in], [ind(varlist) WName(str) WFrom(str) order(integer 1) ///
								plot(str) SAVing(str) title(str) Moran(str) replace ///
								seed(integer 042009) reps(integer 999) note(str) ///
								qvar(varlist numeric) qname(namelist) favor(str) EQUation(str)]
	marksample touse
	capture . mata: mata drop splagvar_* 
	if "`varlist'`ind'`qvar'"=="" {
		di 
		di as err " You must specify at least one of {varlist:1}, {cmd:ind(}{varlist:2}{cmd:)}, and {cmd:qvar(}{varlist:3}{cmd:)}"
		exit 198
	}
	if "`favor'"!="" & !inlist("`favor'", "space", "speed") {
		di as err " Option {bf:favor(`favor')} not allowed"
		exit 198
	}
	if "`varlist'`ind'"!="" & `:word count `wname' `wfrom''!=2 {
		di as err "Both {bf:wname()} and {bf:wfrom()} required when you specify {bf:varlist1} and/or {bf:ind(varlist2)}" 
		exit 198
	}
	if "`ind'"=="" & `order'>1 {
		di 
		di as err "Option {bf:order()} may only specified with {bf:ind()}"
		exit 198
	}
	if inlist(`order',1,2,3)==0 {
		di 
		di as err "Invalid number for the {bf:order()} option, please specify either 2 or 3."
		di as err "The default value is 1 when option {bf:ind()} is specified"
		exit 198
	}
	if "`wfrom'"!="" {
		if !inlist("`wfrom'", "Stata", "Mata") {
      		di 
            	di as err "Either Stata or Mata must be specified with option {bf:wfrom()}"
			exit 198
      	}	
		else mata: splagvar_TOMAT1="`wfrom'"
	}
	if "`varlist'"=="" & "`plot'`saving'`title'`moran'`note'"!="" { 
		di
		di as err ///
		"Options {bf:plot()}, {bf:saving()}, {bf:title()}, {bf:moran()}, {bf:note()}"
		di as err  "may not be specified when no variables are specified in {varlist:1}"
		exit 198
	}
	local eq ""
	if "`equation'"!="" {
		local eqq =real("`equation'")
		cap confirm integer number  `eqq' 
		if _rc {
			di
			di as err "Value provided for option equation() must be an integer (e.g., 1,2,3,...)"
			exit 198
		}
		if "`varlist'`ind'"=="" {
			di 
			di as err " Option equation() must be combined with at least one of {varlist:1} and {cmd:ind(}{varlist:2}{cmd:)}"
			exit 198
		}
		else local eq `equation'
	}	
	if "`varlist'"!="" {
		foreach var of local varlist {
		 	conf v `var'
			Confnewvar wy`eq'_`var' `replace' // by default created spatially lagged variables have wy_ as prefix
		}
		if "`plot'"!="" & `:list plot in varlist'!=1 {
			di
			di as err "Variable `plot' must from the following list: `varlist'"
			exit 198
		}
		if "`moran'"!="" & `:list moran in varlist'!=1 {
			di
			di as err "Variable `moran' must be one of the following: `varlist'"
			exit 198
		}
		if "`plot'"!="" & "`moran'"!="" {
			if "`plot'"!="`moran'" {
				di as err ///
				"The variable name specified with options {bf:plot()} and {bf:moran()} must be the same"
				exit 198 
			}
		}
		if "`plot'"=="" & "`title'`note'"!="" {
			di 
			di as err ///
			"Options {bf:title()} and {bf:note()} may not be specified when option {bf:plot()} is not specfied"
			exit 198
		}
	}
	if "`ind'"!=""  {
		foreach var of local ind {
			conf v `var'
			Confnewvar wx`eq'_`var' `replace' 
			if `order'==2 | `order'==3 {
				Confnewvar w2x`eq'_`var' `replace'
				if `order'==3 Confnewvar w3x`eq'_`var' `replace'  
			}
		}
	}
	if ("`qvar'"!="" & "`qname'"=="") | ("`qvar'"=="" & "`qname'"!="") {
		di
		di as err "Options {bf:qvar()} and {bf: qname()} must be combined"
		exit 198
	}
	if "`qvar'"!="" & "`qname'"!="" {
		if "`favor'"!="" {
			di as err "Option `favor' may not be combined with {bf:qvar()} and {bf:qname()}"
			exit 198
		}
		local nv: word count `qvar'
		confirm var `qvar'
		if `nv'!=`:word count `qname'' {
			di as err "{bf:qvar()} and {bf:qname()} must have the same number of variable names"
			exit 198
		}
	      foreach elt of local qname {
                  Confnewvar `elt' `replace'
            }
 		forvalue i=1/`nv' {
			local xv`i' : word `i' of `qvar'
			local xn`i' : word `i' of `qname'
			tempvar cum pctrank
			cumul `xv`i'' if `touse', gen(`cum')  // generate empirical cumulative distribution, no need to calculate rank or sort the data
			qui gen `pctrank'=`cum'*100 if `touse'
			gen `xn`i''=-1 if `touse'
			qui replace `xn`i''=0 if `pctrank'>33.333333 & `pctrank'<=66.666667 & `touse'
			qui replace `xn`i''=1 if `pctrank'>66.666667 & `touse'
		}
	}
	if "`favor'"=="" mata: mata set matafavor speed
	if "`favor'"=="speed" & c(matafavor)=="space" mata: mata set matafavor speed
	if "`favor'"=="space" & c(matafavor)=="speed" mata: mata set matafavor space	
	if "`varlist'"!="" | "`ind'"!="" {
		if "`ind'"!="" mata: splagvar_Ord=`order'
		cap drop weird_w* 
		mata: splagvar_lagmyvar("`varlist'", "`ind'", "`touse'")
	}
	if "`plot'"!="" | "`moran'"!="" {
		if "`plot'"!="" local morvar `plot'
		if "`moran'"!="" local morvar `moran'
		mata: splagvar_CalcMoran("`morvar'", "`touse'")
		if "`moran'"!="" {
			tempname morvec
			mat `morvec'=morstat
		}
		local I_obs=r(I)
		tempfile Randisave 		
		qui permute `morvar' moran=r(I), seed(`seed') reps(`reps') saving(`Randisave', replace) nodots nowarn: qui splagvar_randper `morvar'
		preserve
		use `Randisave', clear
		qui sum moran
		local mean_mor=r(mean)
		local sd_mor=r(sd)
		qui count if abs(moran)>= abs(`I_obs')
		local p_valR=(r(N)+1)/(`reps'+1)
		restore
	}
	* Renaming the variables
	if "`varlist'"!="" {
		local j=1
		foreach var of local varlist { 
			ren weird_wy`j' wy`eq'_`var'
			lab var wy`eq'_`var' "Spatially Lagged `var'"
			if `"`plot'"'!="" & "`plot'"=="`var'" {
				local pval=string(`p_valR',"%5.4f") 
				local I_Obs=string(`I_obs',"%5.4f")
				qui sum wy_`var'
				local mw`var'=r(mean)
				local sdw_`var'=r(sd)
				qui sum `var'
				local m`var'=r(mean)
				local sd`var'=r(sd)
				tempvar wvar lvar
				gen `wvar'=(wy_`var'-`mw`var'')/`sd`var'' if `touse'
				gen `lvar'=(`var'-`m`var'')/`sd`var'' if `touse'
				label var `wvar' "W`var'"
				SPplot `wvar' `lvar' if `touse', xyaxis(`var') savng(`saving') ftitle(`title')  ///
				stitle((Moran's I=`I_Obs' and P-value=`pval')) notes(`note') 
			}
			if "`moran'"!="" & "`moran'"=="`var'" {
				local lab1 "Moran's I"
				local lab2 "Mean     "
				local lab3 "Std dev  "
				local lab4 "Z-score  "
				local lab5 "P-value* "
				di
				di as txt "{bf:Moran's I Statistics Under Normal Approximation and Randomization Assumptions}"
				di
				di as txt "{hline 17}{c TT}{hline 41}"
				di as txt _col(1) "Statistics" _col(18) "{c |}" _col(21) "Normal Approximation" _col(46) "Randomization"   
				di as txt "{hline 17}{c +}{hline 41}"
				local i=1
				while `i'<=5 {
      				di as txt _col(1)  %16s "`lab`i''" _col(18) "{c |}"   /*
        				*/ as res _col(22) %8.4f `morvec'[`i',1]      /*
        				*/ as res _col(46) %8.4f `morvec'[`i',2]      
        				local i=`i'+1
				}
				di as txt "{hline 17}{c BT}{hline 41}"
				di as txt "*: Two-tailed test"
				di
				di as txt "Note: Under the random permutation procedure:
				di as txt " Mean = " as res %5.4f `mean_mor' as txt " and Standard deviation = " as res %7.4f `sd_mor'
			}		
			local j=`j'+1
		}
	}
	if "`ind'"!="" {
		local i=1
		foreach var of local ind { 
			ren weird_wx`i' wx`eq'_`var'
			lab var wx`eq'_`var' "First order spatially lagged `var'"
			if `order'==2 | `order'==3 {
				ren weird_w2x`i' w2x`eq'_`var'
				lab var w2x`eq'_`var' "Second order spatially lagged `var'"
				if `order'==3 {
					ren weird_w3x`i' w3x`eq'_`var'
					lab var w3x`eq'_`var' "Third order spatially lagged `var'"
				}
			}
			local i=`i'+1
		}
	}
	di
	noi di in y "Spatially lagged variable(s) calculated successfully and/or all requests processed."
	. mata: mata drop splagvar_* 
end
prog define SPplot
	version 10.1
	syntax varlist [if] [in], xyaxis(str) [savng(str) ftitle(str) stitle(str) notes(str)]
	gettoken x1 x2: varlist
	local sav ""
	local tit ""
	if "`savng'" != "" { 
		tokenize "`savng'", parse(",") 
		local savfile "`1'" 
		local subopts "`3'"             
		local sav saving(`savfile', `subopts')
	}
	if `"`ftitle'"'!="" local tit title(`ftitle')
	if "`stitle'"!="" local stit subtitle(`stitle')
	if "`notes'"!="" local not note(`notes')
	scatter `x1' `x2' || lfit `x1' `x2', `sav' `tit' `stit' subtitle(`stitle') xline(0) yline(0) ///
	ytitle("Spatially lagged `xyaxis'") xtitle(`xyaxis') `not'
end	
prog define Confnewvar
        version 10.1
        args varname replace
        loc confv confirm new var 
        cap `confv' `varname' 
        if _rc==110 {
			if "`replace'"!=""  drop `varname'
			else {
				di              
				`confv' `varname'
            }
        } 
end
 
