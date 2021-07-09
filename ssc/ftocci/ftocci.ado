*! v 1.0 N.Orsini 2nov2009
  
capture program drop ftocci
program ftocci, rclass
version 8.2
syntax varlist (min=2) [if] [in] [,   ///
Format(string)    Level(integer $S_level)   ref(real 1) ///
GENerate(namelist max=3)  *  ]

// check level 

        if `level' < 10 | `level' > 99 {
                di in red "level() must be between 10 and 99 inclusive"
                exit 198
        }

        tempname levelci
        scalar `levelci' = `level' * 0.005 + 0.50

// get format 

if "`format'" == "" { 
        local fmt = "%3.2f"
}   
else {
        local fmt = "`format'"
}

// to use the option if/in  

        marksample touse 
	 
// check observation
 
        qui count if `touse'
        local nobs = r(N)

		if `nobs'== 0 {
						di in red "no observations"
                        exit  
                        }
		
		if inrange(`ref',1,`nobs') != 1 {
			di as err "`nobs' levels, choose an appropriate reference level"
			exit 198
		}
		
// check variables 

	tokenize `varlist'

	local nv : word count `varlist'

	tempvar rr lb ub id rrr sef vf se tagactualref

	if `nv' == 3 {
		qui gen double `rr' = `1' if `touse'
		qui gen double `sef' = (log(`3') - log(`2'))/(2*invnorm(`levelci')) if  `touse' 
	}
 
	if `nv' == 2 {
		qui gen double `rr' = `1' if `touse'
		qui gen double `sef' = `2' if `touse'
	}
	 
 // Get reference group
 
		tempvar seq 
		tempname refv
		
		sort `touse', stable
		qui by `touse' :  gen `seq' = _n if `touse'
		qui su `rr'  if `seq' == `ref', meanonly
		scalar `refv' = r(mean)

        // qui keep if `touse'
 
// Calculate the RR based on the referent group

qui gen double  `rrr' = (`rr') / ( `refv' )  if `touse'

// Back calculate conventional CI from FAR CI  

qui gen double `vf' =  `sef'^2 if  `touse' 

tempname vfref

qui su `vf'  if `seq' == `ref' & `touse' , meanonly
scalar `vfref' = r(mean)

qui gen double  `se' = sqrt( `vf' + `vfref' )   if `touse'

* CI

tempvar lbb ubb lb ub logrr

qui gen `logrr' = log(`rrr') if  `touse' 

qui gen double  `lbb' = exp( log(`rrr') - invnorm(`levelci') *`se'  )  if  `touse'
qui gen double  `ubb' = exp( log(`rrr') + invnorm(`levelci') *`se'  )  if  `touse'

qui replace `lbb' = 1 if `rrr' == 1 & `touse' 
qui replace `ubb' = 1 if `rrr' == 1 & `touse' 

// display results

format `fmt' `rrr' `lbb' `ubb'  

char `rrr'[varname] "RR"
char `lbb'[varname] "LB"
char `ubb'[varname] "UB"

l  `rrr' `lbb' `ubb'   if  `touse'  & `rrr' != . , clean subvarname noobs sep(0)

// Saved results covariances of adjusted estimates (variance of the referent log(RR))

qui su `vf' if `rr' == 1
return scalar avcov = r(mean)

// Save new variables containing the displayed results (logrr and std error)

	if "`generate'" != "" {

		local listvarnames "`rrr' `lbb' `ubb'" 
		local nnv : word count `generate' 
		tokenize `generate'

		forv i = 1/`nnv' {	
				qui gen double ``i'' = `: word `i' of `listvarnames'' if  `touse' 
		}
	}
	

end

