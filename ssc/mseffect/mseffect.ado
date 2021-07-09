* VERSION v1.0.0 (The first formal release of the semantic version tag) 
* LAST REVISION: Zizhong Yan DEC 29, 2016
* Email: helloyzz@gmail.com 
program define mseffect, rclass
syntax varlist [if] [in] [iweight pweight]  [,treat(varlist) controls(varlist) reverse(varlist) VCE(passthru) CLuster(varname) NOsur Details TAble3] 
 	version 11.2
/* [> Initializations <] */ 
local varnum=0    
foreach var of varlist `varlist' {
	local varnum=`varnum'+1
}
local treatnum=0   
foreach var of varlist `treat' {
	local treatnum=`treatnum'+1
}
tempvar touse
qui g `touse'=0
qui replace `touse'=1 `if' `in'
if "`weight'" != "" { 
   tempvar wv
   qui gen double `wv' `exp'
   local w [`weight'=`wv']
   local Weight "Results are adjusted by the weighting variable `exp'"
   qui replace `touse'=0 if `wv'==0
}
/* [> Logical conditions <] */ 
tempvar cif
qui gen `cif'=0
foreach t of varlist `treat'{
	qui replace `cif'=1 if `t'==1
	* Consider missings in TREATMENT VARIABLES,
	qui replace `cif'=. if `t'==.
}
/* [> Treatment <] */ 
tokenize `treat'   // generate multiple treatment variables
local treats
forvalue t=1(1)`treatnum'{
	tempvar tif`t'
	qui gen double `tif`t''=(``t''==1) if !missing(``t'') 
	local treats `treats' `tif`t'' 
} 
tokenize `varlist'  
forvalue y=1(1)`varnum'{
	tempvar ``y''temp
	qui gen double ```y''temp'=``y''
}
/* [> Reverse signs <] */ 
if "`reverse'"!=""{
	foreach y of varlist `reverse' {
		tempvar `y'temp
		qui gen double ``y'temp'=-`y'
	}
}
/* [> Display intermediate results <] */ 
if "`details'" == "" { 
	local de "qui "  
}
/* [> Standard errors and the MLE package <] */
local SE "Std. Err."
if "`weight'" != ""  | "`VCE'" != ""  |  "`vce'" != "" { 
	capture which ml3 
	if _rc==111 {
		di in red "------------------------------------------------"
		di in ye "Installing MLE package from Stata-press website"
		di in ye "Please ensure your internet is connected......."
		di in red "------------------------------------------------"
		net from http://www.stata-press.com/data/gps/ml3/
		net install ml3_ado
		ml3_ado
	}
	local mle "my"  
	local SE "Robust SE"
}
/* [> Other options <] */ 
if "`weight'" != ""  { 
	local wloc "  [`weight'`exp']  "  
}  
forvalue y=1(1)`varnum'{   
	if "`nosur'"!=""{   // imputation by group means  
		qui sum ```y''temp' if `touse'==1&`cif'==0
		sca controlmean = r(mean)   
		qui sum ```y''temp' if `touse'==1&`cif'==1   
		sca treatmean = r(mean) 
		qui replace ```y''temp'=controlmean if ```y''temp'==.&`cif'==0&`touse'==1
		qui replace ```y''temp'=treatmean if ```y''temp'==.&`cif'==1&`touse'==1
	} 
	qui sum ```y''temp' if `cif'==0&`touse'==1   
	local mean_control`y' = r(mean)  
	local sd_control`y'=r(sd)  

	if "`weight'" != "" { 
		qui svyset [`weight'`exp']
		qui svy: mean ```y''temp' if `cif'==0&`touse'==1
		local sd_control`y'=sqrt(e(N) * el(e(V_srs),1,1))
		qui mat hahaha= r(table)
		local mean_control`y' =hahaha[1,1]
	}
	if "`nosur'"!=""{
		tempvar `y'y
		qui gen double ``y'y'=(```y''temp'-`mean_control`y'')/`sd_control`y''  if `touse'==1 	
	}
	if "`nosur'"==""{
		tempvar `y'y
		qui gen double ``y'y'= ```y''temp' 
	} 
} 
/* [> Not the SUR version <] */ 
if "`nosur'"!="" { 
	qui des
	local obs=r(N)
	preserve
		tempfile tf
		qui save `tf', replace  // by tempfile!!!
		forvalue y=2(1)`varnum'{         
			qui append using `tf'
		} 
		tempvar si
		qui gen `si'=.
		forvalue y=1(1)`varnum'{        
			local fromN=(`y'-1)*`obs'+1 
			local toN=`y'*`obs'
			qui replace `si'=``y'y' in `fromN'/`toN'
		} 
		*--------------------------------------------------
		* find the group means for the SI - for making the Table 3 in the Lavy, Lotti and Yan (2016) paper only
			if "`table3'"!="" {
				qui {
					sum `si' if `touse'==1 & `treat'==0
					return scalar mean_control = r(mean)
					return scalar sd_control = r(sd)
					sum `si' if `touse'==1 & `treat'==1
					return scalar mean_treat = r(mean)
					return scalar sd_treat = r(sd)
					sum `si' if `touse'==1  
					return scalar mean_si = r(mean)
					return scalar sd_si = r(sd)
				}
			}
		*--------------------------------------------------


		`de'reg `si' `treat' `controls'`wloc'  if `touse'==1 ,  `options' `cluster' `vce'
			 mat eB=e(b)
			 mat eV=e(V)
		forvalue t=1(1)`treatnum'{
			local beta`t'=eB[1,`t']
			local variance`t'=eV[`t',`t']
			local stderr`t'=sqrt(`variance`t'')
			local t`t' = `beta`t''/`stderr`t''
			local pp`t' = tprob(e(df_r),`t`t'') 
							global dstar`t' = cond(`pp`t''<=0.010,"***","") 
							if "${dstar`t'}"==""{
							global dstar`t' = cond(`pp`t''<=0.050,"**","") 
							}
							if "${dstar`t'}"==""{
							global dstar`t' = cond(`pp`t''<=0.100,"*"," ") 
							}	
			local up`t' = `beta`t'' + invttail(e(df_r),0.975)*`stderr`t''
			local low`t' = `beta`t'' + invttail(e(df_r),0.025)*`stderr`t''
				if `up`t''<`low`t''{
					local temp = `low`t''
					local low`t' = `up`t''
					local up`t' = `temp'
				}
			return scalar beta`t' = `beta`t''
			return scalar variance`t' = `variance`t''
			return scalar up95`t' = `up`t''
			return scalar low95`t' = `low`t''
			return scalar stderr`t' = `stderr`t''
			return scalar p_value`t'=`pp`t''
			return local sig_level`t' "${dstar`t'}"
		} 
		local tt "t" 
		return scalar N =`obs'
 	  
	restore
} //end of nosur 


/* [> SUR version <] */ 
if "`nosur'"=="" {
	forvalue y=1(1)`varnum'{
		local outcomes_`y'  (``y'y'  `treats' `controls')
	}
	local outcomes 
	forvalue y=1(1)`varnum'{
		local outcomes `outcomes' `outcomes_`y''  
	} 
	forvalue t=1(1)`treatnum'{
		if `t'==1{
			local dee = "`de'"
		}
		else { 
			local dee "qui "
		}
		`dee'`mle'sureg `outcomes'`wloc'  if `touse'==1 ,  `options' `cluster' `vce' 
		local nn "`tif`t'':  (1/`varnum')*(_b[`1y':`tif`t'']/(`sd_control1')) "
		forvalue y=2(1)`varnum'{
			local nn "`nn'+(1/`varnum')*(_b[``y'y':`tif`t'']/(`sd_control`y''))"
		}
		`de'nlcom (`nn') , post 
		mat bb=e(b)
		mat VV=e(V)
		mat n=e(N)
		local VV = VV[1,1]
		local stderr`t' =sqrt(`VV')
		local beta`t' = bb[1,1]
		local variance`t' = VV[1,1] 
		local t`t' = `beta`t''/`stderr`t'' 
		local up`t' = `beta`t'' + invnormal(0.975)*`stderr`t''
		local low`t' = `beta`t'' + invnormal(0.025)*`stderr`t''
		if `up`t''<`low`t''{
			local temp = `low`t''
		local low`t' = `up`t''
		local up`t' = `temp'
		}
	qui test `tif`t''
	local pp`t'=r(p)
					global dstar`t' = cond(`pp`t''<=0.010,"***","") 
					if "${dstar`t'}"==""{
					global dstar`t' = cond(`pp`t''<=0.050,"**","") 
					}
					if "${dstar`t'}"==""{
					global dstar`t' = cond(`pp`t''<=0.100,"*"," ") 
					}	
	return scalar beta`t' = `beta`t''
	return scalar variance`t' = `variance`t''
	return scalar up95`t' = `up`t''
	return scalar low95`t' = `low`t''
	return scalar stderr`t' = `stderr`t''
	return scalar p_value`t'=`pp`t''  
	return local sig_level`t'   "${dstar`t'}"  
} 
 	local tt "z"
	  
} //end   
 

/* [> Output the results <] */ 
tokenize `varlist' 
forvalue y=1(1)`varnum'{
	local yn`y':  variable label ``y''
	if "`yn`y''"==""{
		local yn`y' "``y''" 
	}
} 
tokenize `treat'
forvalue t=1(1)`treatnum'{
	local tn`t':  variable label ``t''
	if "`tn`t''"==""{
		local tn`t' "``t''" 
	}
} 
di in ye _newline(5) "********************************************************************************* "
di in ye	     "Algorithm to estimate the mean effect size of the treatment on multiple outcomes"
di in ye	     "********************************************************************************* "  
forvalue t=1(1)`treatnum'{
di in ye _newline(1) _column(1)  "Treatment Group: `tn`t'' "
di in gr  _column(1) " Mean Effect Size " _column(24) "`SE' "             _column(36)  " `tt' "                _column(42) " P>|`tt'|  "  _column(52) " [ 95% Conf. Interval ]  "  
di in ye  _column(1)  " "  %-8.7fc `beta`t'' "${dstar`t'} " _column(23) " "%-8.7fc `stderr`t'' "  " _column(35)  " "%-3.2fc `t`t'' " "    _column(42) " "%-4.3f `pp`t'' " "  _column(52) " "%-10.7fc `low`t'' "  "    _column(55) " "%-8.7fc `up`t'' "  "  
}
di in ye	_newline(1)     "********************************************************************************* " 
di in gr _column(1) "Based on following `varnum' outcomes:"
forvalue y=1(1)`varnum'{
di in ye    _column(15) "`yn`y''"
} 
di in ye  "********************************************************************************* " 
di in gr "Notes: "
di in ye    _column(3) "* p < 0.1, ** p < 0.05, *** p < 0.01. " 
di in ye    _column(3) "`Weight'"  
di in gr "Use the return list command to see saved results."
end
