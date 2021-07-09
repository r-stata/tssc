****nonparmde*************************************************************************
****Version 1.0.0
****07Dec2012                                           
****Joel Middleton (New York University) & John Ternovski (Analyst Institute)                                               
****joel.middleton@gmail.com               johnt1@gmail.com
**************************************************************************************
        
    
version 11
program define nonparmde , eclass
	syntax varlist(default=none) , mtreatment(numlist max=1) mcontrol(numlist max=1) [n(varlist max=1) kx(numlist) averages power(real 0.8) ci(real 0.95) crossfold(string asis) avgclustersize(real 0)] 
	
*********error-catching
	if wordcount("`varlist'")!=(1+wordcount("`kx'")) & "`kx'"!="" {
		disp as error "Error: The total number of kx inputs must correspond to an equivelent number of covariate variables."
		exit
	}
	if `mtreatment'<1 | `mcontrol'<1 {
		disp as error "Error: Both mtreatment and mcontrol must be greater or equal to one 1."
		exit
	}
	if "`averages'"!="" & "`n'"=="" {
		disp as error "Error: If clusters averages is specified you must define the n option."
		exit
	}
	if "`n'"=="" & "`avgclustersize'"=="0" {
		disp as error "Error: If n is not specified you must specify the average cluster size." 
		exit
	}
	if "`crossfold'"!="" {
		local error=0
		cap confirm integer number `crossfold'
		local error=_rc
		if "`error'"!="0" {
			cap confirm var `crossfold'
			local error=_rc
		}
	
		if "`error'"!="0" {
			disp as error "The cutoff variable in the crossfold option is not correctly specified!"
			exit
		}
	}	
	

********setting relevant ereturns to missing
	ereturn scalar Vht = .
	ereturn scalar Vrajcovars = .
	
*********parsing variable list to local macros
	tokenize `varlist'
	
	******checking if all variables look like averages if averages is specified
	local len=wordcount("`*'")
	if "`averages'"!="" {
		forval xx=1/`len' {
			if "``xx''"!="`n'" {
			qui sum ``xx'' 
			if (r(min)<0 | r(max)>1) {
				disp as error "Warning: You specified cluster averages, but ``xx'' looks like a cluster total!"
				}
			}
		}
	} 
	******checking if all variables look like totals if cluster averages is not specified
	if "`averages'"=="" {
		forval xx=1/`len' {
			cap assert ``xx''==int(``xx'')
			if _rc {
			disp as error "Warning: Since you did not specify cluster averages, all variables must be cluster totals, but ``xx'' looks like a cluster average!"
			}
		}
	} 
	
*********variable cleanup
	local y `1'
	macro shift
	local cvrs = "`*'"
*********manipulating prior DV if averages
	tempvar Y_total
	qui sum `y'
	if "`averages'"!="" {
		gen `Y_total'=`n' * `y'
	}
	else {
		gen `Y_total' = `y'
	}
*********manipulating covariates
	if "`*'"!="" {
	local len=wordcount("`*'")
		forval xx=1/`len' {
			tempvar X_total_`xx'
			qui summ ``xx''
			if "`averages'"!="" & "``xx''"!="`n'" {
				gen `X_total_`xx''=`n' * ``xx''
				local covariate_names `covariate_names' `X_total_`xx''
			}
			else {
				gen `X_total_`xx'' = ``xx''
				local covariate_names `covariate_names' `X_total_`xx''
			}
		}
	}	
**********getting the unadjusted Horvitz-Thompson MDE
	local M = `mtreatment' + `mcontrol' 	
	if "`n'"!="" {	
		qui sum `n' 
		local N = `M'*r(mean)
	}
	if "`n'"=="" {
		local N = `avgclustersize'*`M'
	}

	qui summarize `Y_total'
	local Y_tot_sigma = r(sd)^2
	local clust_count= r(N)
	local V_HT = ((`M'^2)/`N')^2 * `Y_tot_sigma' /((`M'-1)*`mtreatment'*`mcontrol')
	ereturn scalar Vht = `V_HT'	
	local z_score=invnormal(`power') + invnormal(`ci'/2+.5)

	
**********getting the Raj MDE (Cluster Size and Covariate Adjustment)	
	if "`*'"!="" | "`kx'"!="" {
	tempvar U_total 
	gen `U_total'=`Y_total'		
		forval xx=1/`len' {
	*getting kx from data
			if "`kx'"=="" {
				if "`crossfold'"=="" {					
					qui reg `Y_total' `covariate_names'
					local kx=_b[`X_total_`xx'']
				}
				if "`crossfold'"!="" {
					xvalols `Y_total' `covariate_names', cutoff(`crossfold')
						if e(output`xx')==. {
							exit
						}
					local kx=e(output`xx')
				}
				quietly summarize `X_total_`xx'' 
				quietly replace `U_total' = `U_total' - `kx' * (`X_total_`xx''-r(mean))
				local kx=""
			}
			if "`kx'"!="" {			
				tokenize `kx'
				quietly summarize `X_total_`xx'' 
				quietly replace `U_total' = `U_total' - ``xx'' * (`X_total_`xx''-r(mean))
			}
			
		}
		quietly summarize `U_total'
		local U_tot_sigma = r(sd)^2
		local V_Raj_covars = ((`M'^2)/`N')^2 * `U_tot_sigma' /((`M'-1)*`mtreatment'*`mcontrol')
		ereturn scalar Vrajcovars = `V_Raj_covars'
	}

	
	if ("`avgclustersize'"=="0"){
		local avgclustersize = `N'/`M'
	}
	
	display ""
	display in green "Clusters on file: " _continue  
	display in yellow "`clust_count'" 
	display in green "Design clusters: " _continue 
	display in yellow "`mtreatment'" _continue
	display in green " treatment, " _continue
	display in yellow "`mcontrol'" _continue 
	display in green " control" 
	display in green "Avg. cluster size: " _continue 
	display in yellow "`avgclustersize'" _continue 
	display in green "      Design N: " _continue
	display in yellow "`N'"
	display in green "Power: " _continue
	display in yellow "`power'" _continue
	display in green "       CI: " _continue
	display in yellow "`ci'"

	display ""
	display in green "Horvitz-Thompson"
	display in green "Unadjusted MDE: " _continue
	display in yellow sqrt(`V_HT')*`z_score'

	
	if "`*'"!="" { 
		display ""
		if ("`crossfold'"=="" & "`kx'"=="") {
			local method = "Regression"
		}
		if("`crossfold'"!=""){
			local method = "Crossfold regression"
		}
		if("`kx'"!=""){
			local method = "User specified kx"
		}
		display in green "Raj adjustments: " _continue 
		display in yellow "`cvrs'     " _continue 
		display in green "Method: " _continue
		display in yellow "`method'"
		display in green "Adjusted MDE: " _continue
		display in yellow `z_score'*sqrt(`V_Raj_covars')
	}
	disp ""

	
end
***
