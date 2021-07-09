
* Version: September 2013
* Alejandro Lopez-Feldman
* Division de Economia
* Centro de Investigacion y docencia economicas, CIDE
* lopezfeldman@gmail.com


program doubleb
	version 11
	if replay() {`"`e(cmd)'"' !="double") error 301
		Replay `0'
		}
		else Estimate `0'
end

program Estimate, eclass sortpreserve
	syntax varlist (min=4) [if] [in] [fweight pweight] [, Level(cilevel) noCONStant]
	
	if "`weight'" != " " { 
			local wgt "[`weight' `exp']"
	}
	
	marksample touse		
	gettoken lhs1 rhs0: varlist
	gettoken lhs2 rhs1: rhs0
	gettoken lhs3 rhs2: rhs1
	gettoken lhs4 rhs3: rhs2
	local lhs `lhs1' `lhs2' `lhs3' `lhs4' 

	tempvar check
	qui gen `check' = 1 if `touse'
	qui replace `check' = 0 if `lhs3'==0  & `lhs2'<`lhs1' & `touse'
	qui replace `check' = 0 if `lhs3'==1  & `lhs2'>`lhs1' & `touse'
	qui sum `check', meanonly

if r(mean)>0 {
			di as err "There is an inconsistency in at least one of your observations."  
			di as err "Check for situations where the response to the first question is yes but the second bid is lower than the first"  
			di as err "or for situations where the response to the first question is no but the second bid is higher than the first."  
			di as err "After solving this issue try the command again." 
			exit 498
		}	

	
	ml model lf doubleb_ll ///
	(Beta: `lhs' = `rhs3' , `constant' ) (Sigma:) ///
	 `wgt' if `touse', maximize
	
	ereturn local lhs1 `lhs1'
	ereturn local lhs2 `lhs2'
	ereturn local lhs3 `lhs3'
	ereturn local lhs4 `lhs4'

	ereturn local cmd doubleb
	
	Replay, level(`level')
end

program Replay
	syntax  [, Level(cilevel)]
	ml display, level(`level')
	di _n as txt "First-Bid Variable:"  as res _col(33) e(lhs1) 
	di as txt "Second-Bid Variable:" as res _col(33) e(lhs2)
	di as txt "First-Response Dummy Variable:" as res _col(33) e(lhs3)
	di  as txt "Second-Response Dummy Variable:" as res _col(33) e(lhs4)
end
