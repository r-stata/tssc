********************************************************************************
* Define Program
********************************************************************************
capture program drop screen 
program screen
	version 11.0

********************************************************************************
* Define Syntax
********************************************************************************
syntax varlist(numeric) [if] [in], [Type(string)] /*
						*/[Lower(numlist max=1 >=0 <=100) Upper(numlist max=1 >=0 <=100) /*
						*/Iter(numlist max=1) Second(varlist numeric) /*
						*/Gen(numlist max=1 >=1 <=3)] 
	
marksample touse, novarlist
	
********************************************************************************
* Define Error
********************************************************************************
if "`type'"=="" {
	dis as err "Syntax error: type() must be specified"
	exit 197
	}
if "`lower'"=="" & "`upper'"=="" {
	dis as err "Syntax error: lower() and/or upper() must be specified"
	exit 197
	}
if "`type'"!="sd" & "`type'"!="per" & "`type'"!="iqr" {
	di as err "Syntax error: type() incorrectly specified; specify either sd, per, or iqr"
	exit 198
	}
if "`iter'"!="" & "`type'"!="sd" {
	di as err "Syntax error: iter() is only an option for type(sd)"
	exit 198	
	}
if "`second'"!="" {
	scalar n=wordcount("`varlist'")
	if n>1 {
	di as err "Syntax error: varlist cannot contain more than 1 variable when option second() is specified"
	exit 198	
	}
	}
********************************************************************************
* Begin Loop
********************************************************************************
quietly foreach vjxzty in `varlist' {

********************************************************************************
* Percentiles 
********************************************************************************
if "`type'"=="per" {
	local j : word count `upper'
	if `j'>0 {
	local nupper = 100 - `upper'
	}
	tempvar lqyggizx
	tempvar uvhjmsdf
	gen `lqyggizx' = "`lower'"
	gen `uvhjmsdf' = "`upper'"
	replace `lqyggizx' = subinstr(`lqyggizx',".","_",.)
	replace `uvhjmsdf' = subinstr(`uvhjmsdf',".","_",.)
	local lqyggizx = `lqyggizx'
	local uvhjmsdf = `uvhjmsdf'
		capture confirm variable screen`lqyggizx'per`uvhjmsdf'_`vjxzty'
			if !_rc {
			di as err "Error: variable screen`lqyggizx'per`uvhjmsdf'_`vjxzty' already exists; rename or drop from data set"
			exit 198
			}
	
		/* screen */
		if "`lower'"!="" & "`upper'"!="" { // both limits
			centile `vjxzty' if `touse', centile(`lower' `nupper')  	
			gen screen`lqyggizx'per`uvhjmsdf'_`vjxzty' = (`vjxzty'<r(c_1) | `vjxzty'>r(c_2)) if `touse' & `vjxzty'!=.
			replace screen`lqyggizx'per`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .
			lab var screen`lqyggizx'per`uvhjmsdf'_`vjxzty' "Screen `vjxzty': lower `lower'%/upper `upper'%"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
			centile `vjxzty' if `touse', centile(`lower' `nupper')  			
			gen screen`lqyggizx'per`uvhjmsdf'_`vjxzty' =  `vjxzty'<r(c_1)                    if `touse' & `vjxzty'!=. 
			replace screen`lqyggizx'per`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .
			lab var screen`lqyggizx'per`uvhjmsdf'_`vjxzty' "Screen `vjxzty': lower `lower'%"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
			centile `vjxzty' if `touse', centile(`lower' `nupper')  	
			gen screen`lqyggizx'per`uvhjmsdf'_`vjxzty' =  `vjxzty'>r(c_1)  				  	 if `touse' & `vjxzty'!=.
			replace screen`lqyggizx'per`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .			
			lab var screen`lqyggizx'per`uvhjmsdf'_`vjxzty' "Screen `vjxzty': upper `upper'%"
		}
		
		/* gen */
		if "`gen'"!="" {
			capture confirm variable `vjxzty'_gen`gen'
			if !_rc {
				di as err "Error: variable `vjxzty'_gen`gen' already exists; rename or drop from data set"
				drop screen`lqyggizx'per`uvhjmsdf'_`vjxzty'
				exit 198
			}	
			
			clonevar `vjxzty'_gen`gen' = `vjxzty'
		
			if "`gen'"=="1" & (("`lower'"!="" & "`upper'"!="") | ("`lower'"!="" & "`upper'"=="")) {
				centile `vjxzty'_gen`gen' if `touse' & screen`lqyggizx'per`uvhjmsdf'_`vjxzty'==0, centile(0 100)	
					replace `vjxzty'_gen`gen' = r(c_1) if `vjxzty'_gen`gen' <r(c_1) & `touse' & `vjxzty'!=.
					replace `vjxzty'_gen`gen' = r(c_2) if `vjxzty'_gen`gen' >r(c_2) & `touse' & `vjxzty'!=. 
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with tail end [`lower'`type'`upper']"
				}
			if "`gen'"=="2" {
				su `vjxzty'_gen`gen' if (screen`lqyggizx'per`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'per`uvhjmsdf'_`vjxzty'==.) & `touse'
					replace `vjxzty'_gen`gen' = r(mean) if screen`lqyggizx'per`uvhjmsdf'_`vjxzty' == 1 & `touse' & `vjxzty'!=.
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.					
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with mean [`lower'`type'`upper']"
				}
			if "`gen'"=="3" {
					replace `vjxzty'_gen`gen' = . if screen`lqyggizx'per`uvhjmsdf'_`vjxzty' == 1 & `touse'
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with missing values [`lower'`type'`upper']"
				}
			}
	
		/* second level screening */
		if "`second'"!="" {
			tokenize `second'
			local c: word count `second'
				forval k=1/`c' {
					capture confirm variable screen`lqyggizx'per`uvhjmsdf'_sl``k''
						if !_rc {
						di as err "Error: variable screen`lqyggizx'per`uvhjmsdf'_sl``k'' already exists; rename or drop from data set"
						drop screen`lqyggizx'per`uvhjmsdf'_`vjxzty'
						cap drop `vjxzty'_gen`gen'
						exit 198
						}
						
			centile ``k'' if (screen`lqyggizx'per`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'per`uvhjmsdf'_`vjxzty'==.) & `touse', centile(`lower' `nupper')
			
			if "`lower'"!="" & "`upper'"!="" { // both limits
				gen screen`lqyggizx'per`uvhjmsdf'_sl``k'' = (``k''<r(c_1) | ``k''>r(c_2)) if `touse'  & ``k''!=. 
				replace screen`lqyggizx'per`uvhjmsdf'_sl``k'' = . if ``k'' == .
				lab var screen`lqyggizx'per`uvhjmsdf'_sl``k'' "Screen ``k'': lower `lower'%/upper `upper'%; second level"
			}
			if "`lower'"!="" & "`upper'"=="" { // only lower limit
				gen screen`lqyggizx'per`uvhjmsdf'_sl``k'' =  ``k''<r(c_1)                 if `touse'  & ``k''!=. 
				replace screen`lqyggizx'per`uvhjmsdf'_sl``k'' = . if ``k'' == .
				lab var screen`lqyggizx'per`uvhjmsdf'_sl``k'' "Screen ``k'': lower `lower'%; second level"
			}
			if "`lower'"=="" & "`upper'"!="" { // only upper limit
				gen screen`lqyggizx'per`uvhjmsdf'_sl``k'' =  ``k''>r(c_1)                 if `touse'  & ``k''!=. 
				replace screen`lqyggizx'per`uvhjmsdf'_sl``k'' = . if ``k'' == .				
				lab var screen`lqyggizx'per`uvhjmsdf'_sl``k'' "Screen ``k'': upper `upper'%; second level"
			}
				}	
		}
} 

********************************************************************************
* Standard Deviations 
********************************************************************************
if "`type'"=="sd" & "`iter'"=="" {
	tempvar lqyggizx
	tempvar uvhjmsdf
	gen `lqyggizx' = "`lower'"
	gen `uvhjmsdf' = "`upper'"
	replace `lqyggizx' = subinstr(`lqyggizx',".","_",.)
	replace `uvhjmsdf' = subinstr(`uvhjmsdf',".","_",.)
	local lqyggizx = `lqyggizx'
	local uvhjmsdf = `uvhjmsdf'
		capture confirm variable screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'
			if !_rc {
			di as err "Error: variable screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' already exists; rename or drop from data set"
			exit 198
			}

		/* screen */
		if "`lower'"!="" & "`upper'"!="" { // both limits
		sum `vjxzty' if `touse'
		gen screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = (`vjxzty'>r(mean)+(r(sd)*`upper')) | (`vjxzty'<r(mean)-(r(sd)*`lower'))   if `touse' & `vjxzty'!=.
		replace screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .		
		lab var screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' "Screen `vjxzty': -`lower'SD/+`upper'SD"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
		sum `vjxzty' if `touse'
		gen screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = (`vjxzty'<r(mean)-(r(sd)*`lower')) 									 if `touse' & `vjxzty'!=.
		replace screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .				
		lab var screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' "Screen `vjxzty': -`lower'SD"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
		sum `vjxzty' if `touse'
		gen screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = (`vjxzty'>r(mean)+(r(sd)*`upper')) 									 if `touse' & `vjxzty'!=.
		replace screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' = . if `vjxzty' == .		
		lab var screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' "Screen `vjxzty': +`upper'SD"
		}
		
		/* gen */
		if "`gen'"!="" {
			capture confirm variable `vjxzty'_gen`gen'
			if !_rc {
				di as err "Error: variable `vjxzty'_gen`gen' already exists; rename or drop from data set"
				drop screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'
				exit 198
			}	
			
			clonevar `vjxzty'_gen`gen' = `vjxzty'
		
			if "`gen'"=="1" {
				centile `vjxzty'_gen`gen' if screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' == 0 & `touse', centile(0 100)
					replace `vjxzty'_gen`gen' = r(c_1) if `vjxzty'_gen`gen' <r(c_1) & `touse' & `vjxzty'!=.
					replace `vjxzty'_gen`gen' = r(c_2) if `vjxzty'_gen`gen' >r(c_2) & `touse' & `vjxzty'!=.
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with tail end [`lower'`type'`upper']"
				}
			if "`gen'"=="2" {
				su `vjxzty'_gen`gen' if screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' == 0 & `touse'
					replace `vjxzty'_gen`gen' = r(mean) if screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' == 1 & `touse' & `vjxzty'!=.
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.				
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with mean [`lower'`type'`upper']"
				}
			if "`gen'"=="3" {
					replace `vjxzty'_gen`gen' = . if screen`lqyggizx'sd`uvhjmsdf'_`vjxzty' == 1 & `touse'
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with missing values [`lower'`type'`upper']"
				}
			}

		/* second level screening */
		if "`second'"!="" {
			tokenize `second'
			local c: word count `second'
				forval k=1/`c' {
					capture confirm variable screen`lqyggizx'sd`uvhjmsdf'_sl``k''
						if !_rc {
						di as err "Error: variable screen`lqyggizx'sd`uvhjmsdf'_sl``k'' already exists; rename or drop from data set"
						drop screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'
						cap drop `vjxzty'_gen`gen'
						exit 198
						}
					
		if "`lower'"!="" & "`upper'"!="" { // both limits
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==.) & `touse'
			gen screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = (``k''>r(mean)+(r(sd)*`upper')) | (``k''<r(mean)-(r(sd)*`lower')) if `touse' & ``k''!=.
			replace screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = . if ``k'' == .							
			lab var screen`lqyggizx'sd`uvhjmsdf'_sl``k'' "Screen ``k'': -`lower'SD/+`upper'SD; second level"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==.) & `touse' 
			gen screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = (``k''<r(mean)-(r(sd)*`lower')) if `touse'  & ``k''!=.
			replace screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = . if ``k'' == .							
			lab var screen`lqyggizx'sd`uvhjmsdf'_sl``k'' "Screen ``k'': -`lower'SD; second level"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'_`vjxzty'==.) & `touse' 
			gen screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = (``k''>r(mean)+(r(sd)*`upper')) 									if `touse' & ``k''!=.
			replace screen`lqyggizx'sd`uvhjmsdf'_sl``k'' = . if ``k'' == .										
			lab var screen`lqyggizx'sd`uvhjmsdf'_sl``k'' "Screen ``k'': -`lower'SD; second level"
		}			
				}
		}
	}

********************************************************************************
* Standard Deviation Multiple Iterations
********************************************************************************
if "`type'"=="sd" & "`iter'"!="" {
	tempvar lqyggizx
	tempvar uvhjmsdf
	gen `lqyggizx' = "`lower'"
	gen `uvhjmsdf' = "`upper'"
	replace `lqyggizx' = subinstr(`lqyggizx',".","_",.)
	replace `uvhjmsdf' = subinstr(`uvhjmsdf',".","_",.)
	local lqyggizx = `lqyggizx'
	local uvhjmsdf = `uvhjmsdf'
		capture confirm variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'
			if !_rc {
			di as err "Error: variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' already exists; rename or drop from data set"
			exit 198
			}
			
		gen screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=.
	
		/* screen */	
		if "`lower'"!="" & "`upper'"!="" { // both limits
		forvalues q = 1/`iter' {
			sum `vjxzty' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' = (`vjxzty'>r(mean)+(r(sd)*`upper')) | (`vjxzty'<r(mean)-(r(sd)*`lower')) if `touse' & `vjxzty'!=.
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
		}
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' "Screen `vjxzty': -`lower'SD/+`upper'SD; `iter' iterations"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
		forvalues q = 1/`iter' {
			sum `vjxzty' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' = (`vjxzty'<r(mean)-(r(sd)*`lower')) 									if `touse' & `vjxzty'!=.
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
		}
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' "Screen `vjxzty': -`lower'SD; `iter' iterations"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
		forvalues q = 1/`iter' {
			sum `vjxzty' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' = (`vjxzty'>r(mean)+(r(sd)*`upper')) 									if `touse' & `vjxzty'!=.
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
		}
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'=. if `vjxzty'==.
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' "Screen `vjxzty': +`upper'SD; `iter' iterations"
		}
		
		/* gen */
		if "`gen'"!="" {
			capture confirm variable `vjxzty'_gen`gen'
			if !_rc {
				di as err "Error: variable `vjxzty'_gen`gen' already exists; rename or drop from data set"
				drop screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'
				exit 198
			}	
			
			clonevar `vjxzty'_gen`gen' = `vjxzty'
		
			if "`gen'"=="1" {
				centile `vjxzty'_gen`gen' if screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' == 0 & `touse', centile(0 100)
					replace `vjxzty'_gen`gen' = r(c_1) if `vjxzty'_gen`gen' <r(c_1) & `touse'
					replace `vjxzty'_gen`gen' = r(c_2) if `vjxzty'_gen`gen' >r(c_2) & `touse' 
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with tail end [`lower'`type'`upper']"
				}
			if "`gen'"=="2" {
				su `vjxzty'_gen`gen' if screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' == 0 & `touse'
					replace `vjxzty'_gen`gen' = r(mean) if screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' == 1 & `touse'
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with mean [`lower'`type'`upper']"
				}
			if "`gen'"=="3" {
					replace `vjxzty'_gen`gen' = . if screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' == 1 & `touse'
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with missing values [`lower'`type'`upper']"
				}
			}

		/* second level screening */
		if "`second'"!="" {
			tokenize `second'
			local c: word count `second'
				forval k=1/`c' {
					capture confirm variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''
						if !_rc {
						di as err "Error: variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' already exists; rename or drop from data set"
						drop screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'
						cap drop `vjxzty'_gen`gen'
						exit 198
						}
			
		gen screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''=.

		if "`lower'"!="" & "`upper'"!="" { // both limits
		forvalues q = 1/`iter' {
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==.) & (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' = (``k''>r(mean)+(r(sd)*`upper')) | (``k''<r(mean)-(r(sd)*`lower')) if `touse' & ``k''!=.
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''=. if ``k''==.
		}
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' "Screen ``k'': -`lower'SD/+`upper'SD; `iter' iterations; second level"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
		forvalues q = 1/`iter' {
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==.) & (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' = (``k''<r(mean)-(r(sd)*`lower')) 									if `touse' & ``k''!=.
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''=. if ``k''==.
		}
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' "Screen ``k'': -`lower'SD; `iter' iterations; second level"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
		forvalues q = 1/`iter' {
			sum ``k'' if (screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''==.) & (screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==0 | screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'==.) & `touse'
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' = (``k''>r(mean)+(r(sd)*`upper')) 									if `touse' & ``k''!=. 
			replace screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k''=. if ``k''==.
		}
			lab var screen`lqyggizx'sd`uvhjmsdf'i`iter'_sl``k'' "Screen ``k'': +`upper'SD; `iter' iterations; second level"
		}
		
		
				}
		}
}

********************************************************************************
* IQR
********************************************************************************		
if "`type'"=="iqr"  {
	tempvar lqyggizx
	tempvar uvhjmsdf
	gen `lqyggizx' = "`lower'"
	gen `uvhjmsdf' = "`upper'"
	replace `lqyggizx' = subinstr(`lqyggizx',".","_",.)
	replace `uvhjmsdf' = subinstr(`uvhjmsdf',".","_",.)
	local lqyggizx = `lqyggizx'
	local uvhjmsdf = `uvhjmsdf'
		capture confirm variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty'
			if !_rc {
			di as err "Error: variable screen`lqyggizx'sd`uvhjmsdf'i`iter'_`vjxzty' already exists; rename or drop from data set"
			exit 198
			}

		su `vjxzty' if `touse', d 
		
		/* screen */
		if "`lower'"!="" & "`upper'"!="" { // both limits
		local U_innerfence = r(p75) + `upper'*(r(p75) - r(p25))
		local L_innerfence = r(p25) - `lower'*(r(p75) - r(p25))
		gen screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' = (`vjxzty' > `U_innerfence' | `vjxzty' < `L_innerfence') if `touse'
		replace screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'=. if `vjxzty'==.
		lab var screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' "Screen `vjxzty': IQR fence factor [`lower':`upper']"
		}
		if "`lower'"!="" & "`upper'"=="" { // only lower limit
		local L_innerfence = r(p25) - `lower'*(r(p75) - r(p25))		
		gen screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' = (`vjxzty' < `L_innerfence') 						     if `touse'
		replace screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'=. if `vjxzty'==.
		lab var screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' "Screen `vjxzty': IQR lower fence factor [`lower']"
		}
		if  "`lower'"=="" & "`upper'"!="" { // only upper limit
		local U_innerfence = r(p75) + `upper'*(r(p75) - r(p25))
		gen screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' = (`vjxzty' >`U_innerfence') 						     if `touse'
		replace screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'=. if `vjxzty'==.
		lab var screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' "Screen `vjxzty': IQR upper fence factor [`upper']"
		}
		
		/* gen */
		if "`gen'"!="" {
			capture confirm variable `vjxzty'_gen`gen'
			if !_rc {
				di as err "Error: variable `vjxzty'_gen`gen' already exists; rename or drop from data set"
				drop screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'
				exit 198
			}	
			
			clonevar `vjxzty'_gen`gen' = `vjxzty'
		
			if "`gen'"=="1" {
				centile `vjxzty'_gen`gen' if screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' == 0 & `touse', centile(0 100)
					replace `vjxzty'_gen`gen' = r(c_1) if `vjxzty'_gen`gen' <r(c_1) & `touse'
					replace `vjxzty'_gen`gen' = r(c_2) if `vjxzty'_gen`gen' >r(c_2) & `touse' 
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: var lab `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with tail end [`lower'`type'`upper']"
				}
			if "`gen'"=="2" {
				su `vjxzty'_gen`gen' if screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' == 0 & `touse', d
					replace `vjxzty'_gen`gen' = r(p50) if screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' == 1 & `touse'
					replace `vjxzty'_gen`gen'=. if `vjxzty'==.
					local l: var lab `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with median [`lower'`type'`upper']"
				}
			if "`gen'"=="3" {
					replace `vjxzty'_gen`gen' = . if screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty' == 1 & `touse'
					local l: variable label `vjxzty'
					lab var `vjxzty'_gen`gen' "`l'; replaced screened with missing values [`lower'`type'`upper']"
				}				
			}

		/* second level screening */
		if "`second'"!="" {
			tokenize `second'
			local c: word count `second'
				forval k=1/`c' {
					capture confirm variable screen`lqyggizx'iqr`uvhjmsdf'_sl``k''
						if !_rc {
						di as err "Error: variable screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' already exists; rename or drop from data set"
						drop screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'
						cap drop `vjxzty'_gen`gen'
						exit 198
						}
			
			su ``k'' if (screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'==0 | screen`lqyggizx'iqr`uvhjmsdf'_`vjxzty'==.) & `touse', d 
				cap local U_innerfence = r(p75) + `upper'*(r(p75) - r(p25))
				cap local L_innerfence = r(p25) - `lower'*(r(p75) - r(p25))

			/* screen */
			if "`lower'"!="" & "`upper'"!="" { // both limits
				gen screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' = (``k'' > `U_innerfence' | ``k'' < `L_innerfence')   if `touse' & ``k''!=.
				replace screen`lqyggizx'iqr`uvhjmsdf'_sl``k''=. if ``k''==.
				lab var screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' "Screen ``k'': IQR fence factor [`lower':`upper']; second level"
			}
			if "`lower'"!="" & "`upper'"=="" { // only lower limit
				gen screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' = (``k'' < `L_innerfence') 							if `touse' & ``k''!=.
				replace screen`lqyggizx'iqr`uvhjmsdf'_sl``k''=. if ``k''==.	
				lab var screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' "Screen ``k'': IQR lower fence factor [`lower']; second level"
			}
			if  "`lower'"=="" & "`upper'"!="" { // only upper limit
				gen screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' = (``k'' >`U_innerfence')  							if `touse' & ``k''!=.
				replace screen`lqyggizx'iqr`uvhjmsdf'_sl``k''=. if ``k''==.
				lab var screen`lqyggizx'iqr`uvhjmsdf'_sl``k'' "Screen ``k'': IQR upper fence factor [`upper']; second level"
			}
		
				}	
		}
} 

}

end 
