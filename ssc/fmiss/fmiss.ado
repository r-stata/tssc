capture program drop fmiss
*!version 1.0 27nov2012 -  F. Wendelspiess Chavez Juarez
program define fmiss
version 9.2
syntax [varlist] [if] [in] [,Detail Percentage Level(real 0.1)]

// If no varlist specified, include all variables
if("`varlist'"==""){
	`varlist'="*"
	}
marksample touse, novarlist
preserve
qui:count if `touse'
local samplesize=r(N)

qui: keep if `touse'
egen _missing=rowmiss(`varlist')		// generates a variable with the number of missings in the observation
gen _anymissing=_missing>0				// Dummy for any missing
qui: count if _anymissing==0
local nonmissing=r(N)
local nonmissingrel=round(100*`nonmissing'/`samplesize',0.1)

local maxmissing=0
foreach var of local varlist{

	loc type: type `var'
	local type=substr("`type'",1,3)
	if("`type'"=="str"){ 									
		gen _M`var'=(`var'=="" & _missing==1)		// generates a dummy taking the value of one if it's a unique missing
		qui: count if `var'=="" 					// count how many missings there are
	}
	else{
		gen _M`var'=(`var'==. & _missing==1)		// generates a dummy taking the value of one if it's a unique missing
		qui: count if `var'==. 						// count how many missings there are
		}
	local AM`var'=r(N)								// store it
	qui: count if _M`var'==1 						// count how many unique missing there are
	local TM`var'=r(N)								// store it
	if(`maxmissing'<`TM`var''){
		local maxmissing=`TM`var''					// identify the highest number of unique missings
		}
		
	// check if these unique missing change the other variables significantly
		if("`detail'"=="detail"){
		local `var'_pmin=1.000
		foreach var2 of varlist `varlist'{
			
			loc type: type `var2'
			local type=substr("`type'",1,3)
			qui:sum  _M`var'
		if("`var2'"!="`var'" & "`type'"!="str" & r(mean)>0){
			
			// Perform the t-test of the whole sample against the sample when loosing the unique missings
			qui:sum `var2' 
			local m1=r(mean)
			local s1=r(sd)
			local n1=r(N)
			
			qui:sum `var2' if _M`var'==0
			local m2=r(mean)
			local s2=r(sd)
			local n2=r(N)
			
			local s=sqrt(`s1'^2 / `n1' + `s2'^2/`n2')
			local t=(`m1'-`m2')/`s'
			
			local df=min(`n1',`n2')
			local p=2*ttail(`df',abs(`t'))
			
			local `var'_pmin=min(``var'_pmin',`p')
			if(`p'<=`level'){
				local `var'_affected="``var'_affected' `var2'"
				} //end if

			} //end if really do t-test
		}	// end loop through var2
		} // end if detail
	
	//noisily display "done!"
	
	// Convert in percentages if option selected
	if("`percentage'"=="percentage"){
		local AM`var'=round(100*`AM`var''/`samplesize',0.01)
		local AM`var'="`AM`var''%"
		local TM`var'=round(100*`TM`var''/`samplesize',0.01)
		local TM`var'="`TM`var''%"
		}
	} //end loop through all variables
	if(`maxmissing'>0){		// in case of finding missings, display the results
	
	
	
// START THE OUTPUT	
	local width=50
if("`detail'"=="detail"){
	local width=75
	}
di as text ""	
di as text "Analysis of missing variables in the dataset"
di as text " Total sample size: " _col(35) as result "`samplesize'"
di as text " Sample without any missing:" _col(35) as result "`nonmissing' (" %4.2f `nonmissingrel' "%)"
di as text "{hline `width'}"
di in smcl  _col(29) "{help fmiss##descunique:Unique}"
di as text _continue "Variable     "  
di in smcl _col(16) _continue "{help fmiss##descmissing:Missings}"
di in smcl _col(27) _continue "{help fmiss##descunique:missings}"
if("`detail'"=="detail"){
	di in smcl _col(40) "{help fmiss##descsigchange:Significant change in}"
}
else{
	di " "
	}
di as text "{hline `width'}"
foreach var of local varlist {

di as text _continue abbrev("`var'",12) 
di as result _continue _col(15) %9s "  `AM`var''"
di as result _continue _col(26)  %9s  "`TM`var''"

if("`detail'"=="detail"){


	if("``var'_affected'"=="" & ``var'_pmin'<1.00){
		di as text _col(40) _continue "--- (Smallest pvalue: "
		di as result %6.3f ``var'_pmin' as text ")"
		}
	else if("``var'_affected'"==""){
		di as text _col(40)  "---"
		}
		else{
	foreach aff of local `var'_affected{
		di as result   _col(40)  "`aff'"
		}
		} //end if detail
	}
	else{
		di " "
	
	}
	
}

	di as text "{hline `width'}"

di as result "See {help fmiss:help file} for details on the exact definition of columns"


}
else{	// else: no missings found: display this
di as error "----- >  No missing values detected"
}
restore
end
