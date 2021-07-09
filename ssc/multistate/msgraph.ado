*! version 1.0.0 09aug2016 MJC

/*
Graph utility for predictms to plot stacked transition probabilities
*/


program msgraph
	syntax	,	[									///
					FROM(numlist >0 asc int)		/// -starting state for predictions-
					ENTER(string)					///
					EXIT(string)					///
					NSTATES(string)					///
					timevar(varname)				///
					GEN(string)						///
													///
					cox								///
					*								///
				]

		if "`from'"=="" local from `r(from)'
		if "`nstates'"=="" local nstates = `r(Nstates)'
		if "`cox'"!="" {
			tempvar zeros
			gen byte `zeros' = 0
		}
		if "`gen'"=="" local stub _prob_at1
		else local stub `gen'
		
		cap numlist "`nstates'/1"
		local legorder `r(numlist)'
		
		foreach frm in `from' {
			tempvar plotvars1
			qui gen double `plotvars1' = `stub'_`frm'_1
			label var `plotvars1' "Prob. state=1"
			if "`cox'"=="" local plots`frm' `plots`frm'' (area `plotvars1' `timevar', base(0)) 
			else local plots`frm' `plots`frm'' (rarea `plotvars1' `zeros' `timevar', connect(stairstep)) 
			forvalues i=2/`nstates' {
				tempvar plotvars`i'
				qui gen double `plotvars`i'' = `plotvars`=`i'-1'' + `stub'_`frm'_`i'
				label var `plotvars`i'' "Prob. state=`i'"
				if "`cox'"=="" local plots`frm' (area `plotvars`i'' `timevar', base(0)) `plots`frm'' 
				else local plots`frm' (rarea `plotvars`i'' `zeros' `timevar', connect(stairstep)) `plots`frm'' 
			}				
			twoway `plots`frm'', ylabel(0(0.1)1, angle(h) format(%2.1f)) ///
				ytitle("Probability") plotregion(m(zero)) legend(order(`legorder')) /*note("From state=`frm' at {it:t}=`enter'")*/ `options'
		}
			
end


