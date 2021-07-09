
* Version: October 2011
* Alejandro Lopez-Feldman
* Division de Economia
* Centro de Investigacion y docencia economicas, CIDE
* lopezfeldman@gmail.com


program singleb
	version 10.1
	if replay() {`"`e(cmd)'"' !="double") error 301
		Replay `0'
		}
		else Estimate `0'
end

program Estimate, eclass sortpreserve
	syntax varlist (min=2) [if] [in] [fweight pweight] [, Level(cilevel) noCONStant]
	
	if "`weight'" != " " { 
			local wgt "[`weight' `exp']"
	}
	
	marksample touse		
	gettoken lhs1 rhs0: varlist
	gettoken lhs2 rhs1: rhs0
	local lhs `lhs1' `lhs2' 
	
	ml model lf singleb_ll ///
	(Beta: `lhs' = `rhs1' , `constant' ) (Sigma:) ///
	 `wgt' if `touse', maximize
	
	ereturn local lhs1 `lhs1'
	ereturn local lhs2 `lhs2'

	ereturn local cmd singleb
	
	Replay, level(`level')
end

program Replay
	syntax  [, Level(cilevel)]
	ml display, level(`level')
	di _n as txt "Bid Variable:"  as res _col(33) e(lhs1) 
	di as txt "Response Dummy Variable:" as res _col(33) e(lhs2)
end
