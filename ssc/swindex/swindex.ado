/*
authors[Benjamin Schwab, Sarah Janzen, Nicholas Magnan, William Thompson]
institute[Kansas State University, Kansas State University, University of Georgia, IDInsight]
email[benschwab@ksu.edu]
*/

program define swindex, rclass
version 14
syntax varlist(min=1 numeric) [if] [in][, Generate(name) replace FLip(varlist) NORMby(varname) NOREscale FULLRescale NOStd Numvars(name) Displayw]
	
	marksample touse, novarlist
		gsort -`touse'
	local vnum : list sizeof local(varlist)
	local vnum=`vnum'+1

	*tokenize `varlist'
	loc nfv: list varlist - flip
		foreach v of loc flip {
			tempvar tf`v'
			qui gen double `tf`v''=-`v'
			loc fvs `tf`v'' `fvs'
		}	
	loc subs `nfv' `fvs'	

*#Give error if you do not specify either replace or generate
if "`replace'"=="" {
	if "`generate'"=="" {
		di as error "Error: You must specify either generate or replace"
	}
}

*# give error if variable name in generate is invalid
if "`replace'"=="" {
	confirm new var `generate'
}


*#Name of the 'control' group or sample selection variable: default is full
loc cvar "control"
if "`normby'"!="" {
	loc cvar "`normby'"
	
	
*#Check to make sure the normby variable is binary
	cap assert `normby'==0 | `normby'==1 | `normby'==. if `touse'
		if _rc!=0 {
			di as error "Control variable is not binary"
			exit 198
		}
	}
 

	*eliminate control if NOStd option is chosen
			if "`nostd'"!="" {
			loc cvar ""
				if "`normby'"!="" {
					di as error "You cannot specify nostd if normby is also specified"
					exit 198
				}
			*Give a warning that nostd is not recommended
			di as text "Warning: The nostd option is not recommended, as the components of varlist are not normalized prior to calculation of the index.  Proceed with caution."  
			}


*Check if there are collinnear or non-varying variables in the index that will cause the index calculation to fail when the normby option is specified
	quietly {
	*Check for variables in varlist that are missing for all values, which will cause the index calculation to fail.
		loc mvs
		foreach x in `varlist' {
			su `x' if `touse'
			if r(N)==0 {
				loc mvs `bvs' `x'
				}
			}
			if "`mvs'"!="" {
				di as error "Warning: The standardized index cannot be calculated because the following variables have all missing values: `mvs'"
				exit 198
			}
			
if "`nostd'"=="" {
	if "`normby'"!="" {
		_rmcollright `varlist' `normby' if `touse'
			loc dv=r(dropped)
			if "`dv'"=="`normby'" {
				di as error "Warning: The standardized index cannot be calculated because one or more of the variables in varlist is perfectly collinear with the normby() standardization variable"
			exit 198	
			}
		}
			loc bvs ""
		foreach x in `varlist' {
			su `x' if `touse'
			if r(sd)==0 {
				loc bvs `bvs' `x'
				}
			}
			if "`bvs'"!="" {
				di as error "Warning: The standardized index cannot be calculated because the following variables are constant: `bvs'"
				exit 198
				}
				
			
		}
		*If fullrescale is also invoked along with normby, warn the user that the index has been normed to the full sample even though the weights have been calculated based on a normalization to a subsample
		if "`fullrescale'"!="" {
			di as error "Warning: Your index is normalized to the full sample even though the weighting procedure standardized the outcomes based on a subsample."
			}
		
	}


*#Subtract the full sample mean or just control group
loc cif ""
if "`normby'"!="" {
	loc cif "& `cvar'==1"
}

*#Standardize by the control variable only, but rescale to full sample 
loc nif `cif'

*#Default is to not rescale to the full sample if nostd is invoked
if "`fullrescale'"!="" {
	loc nif ""
}
	
*#Set the matrix for weight calculation
loc coorv "variance"

**CALCULATIONS STEP 1: MEANS & SDs
*#Give temporary variable names to calculate the means & SDs
	foreach h in `subs' {
		tempvar `h'_mean `h'_sd `h'_n `h'_w
		qui gen ``h'_mean' = .
		qui gen ``h'_sd' = .
		qui	gen ``h'_n' = .
			if "`nostd'"=="" {
			*~~~Methodology~~~~~*
				*the cif local contains the "if control=1" limiter if normby is specified
			qui sum `h' if `touse' `cif'
			qui replace ``h'_sd' = r(sd) if `touse' 
				qui	sum `h' if `touse' `cif' 
			*~~~~~~~~~~~~~~~~~~~~*
			
			qui replace ``h'_mean' = r(mean) if `touse'
			
				qui replace ``h'_n' = ((`h'-``h'_mean')/``h'_sd')  if `touse'
			}
			if "`nostd'"!="" {
				qui replace ``h'_n'=`h' if `touse'
			}
			
			qui gen ``h'_w' = . 
		
			*drop `h'_mean `h'_sd

	}

**CALCULATION STEP 2: WEIGHTS
*Enter variables into mata to make weights
forvalues i = 1(1)`vnum'{ 
	tempvar si`i'
	gen `si`i''= 0 if `touse'
}

local n = 0
loc gvt ""
foreach h in `subs' {
	local n = `n'+1
	qui replace `si`n'' = ``h'_n' if `touse'
	loc gvt "`gvt' `si`n''"
}


mata: st_view(x=0,.,tokens("`gvt'"),"`touse'") 

mata: vx = `coorv'(x)
mata: vx=editmissing(vx,0) 
mata: ivx = invsym(vx)
mata: w_vec = rowsum(ivx)
mata: st_matrix("WT",w_vec)
mat wt=WT
return matrix wt=WT


**CALCULATION STEP 3: Calculate weighted averages

*create the variable
if "`replace'"!="" {
	cap confirm new var `generate'
	if !_rc {
		qui gen double `generate'=0 if `touse'
		di "Note: `generate' not found in existing data, so has been created"
	}
	else {
		qui replace `generate'=0 if `touse'
	}
}
else {
qui gen double `generate'=0 if `touse'
}

tempvar sum_weight
qui gen double `sum_weight' = 0 if `touse'


qui summ `generate' if `touse'
local obs = r(N)
local n = 0
foreach h in `subs' {
	local n = `n'+ 1
	mata: ``h'_w' = J(`obs',1,w_vec[`n',1])
	mata: st_store(1::`obs',"``h'_w'",``h'_w')
	}

foreach h in `subs' {
qui	replace `sum_weight' = `sum_weight' + ``h'_w' if  ``h'_n' !=.
qui	replace `generate' = `generate' + ``h'_n'*``h'_w'  if  ``h'_n' !=.
}
	
qui replace `generate' = `generate' / `sum_weight' 
qui replace `generate' = . if `generate'  == 0

**storing the numweight variable
if "`numvars'"!="" {
qui	egen `numvars'=rownonmiss(`varlist') if `touse'
	}

*# Store matrix of weights 
	*scaled weights
	mata : st_matrix("sum", colsum(st_matrix("wt")))
		scalar s=sum[1,1]
		mat prow=wt/s
		mat pw=prow
	return matrix pw=prow
	
	*raw weights
	mat aw=wt'
		mat colnames aw=`varlist'
		mat rownames aw=Weights


**RESCALE
*Default is not to rescale when nostd is invoked
loc nz=0
if "`nostd'"!="" & "`fullrescale'"=="" {
	loc nz=1 
}
if "`norescale'"=="" & `nz'!=1 {
	qui summ `generate' if `touse' `nif'
	qui replace `generate' = (`generate' - r(mean))/r(sd) if `touse'
}


*Display weights
if "`displayw'"!="" {

di _col(1) as txt "Weights"


loc i=1
foreach v of local varlist {
	scalar vw`i'=pw[`i',1]
                di _col( 1) as input %12s abbrev("`v'", 15) _c
				di _col(20) as result vw`i' _c
			    display "{txt}"


	loc i=`i'+1
            }                    
}
end


*********END PROGRAM**************
