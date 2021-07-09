
program define survsim_model
	version 14.2
	
	syntax newvarname(min=1 max=2), 										///
																			///
										Model(string)						///
										MAXTime(string)						///	-Maximum simulated time-
																			//
		
	local nvars : word count `varlist'
	local stime : word 1 of `varlist'
	local event : word 2 of `varlist'
			
	cap which merlin
	if _rc {
		display in yellow "You need to install the merlin package. This can be installed using,"
		display in yellow ". {stata ssc install merlin}"
		exit 198
	}
// 	cap which predictms
// 	if _rc {
// 		display in yellow "You need to install the multistate package. This can be installed using,"
// 		display in yellow ". {stata ssc install multistate}"
// 		exit 198
// 	}
		
	//====================================================================================================================//

		quietly {
			
			qui gen double `stime' = .
			cap drop _survsim_rc
			qui gen _survsim_rc = 0
			tempvar modtouse
			gen byte `modtouse' = 1
			local N = _N
					
			//make sure right censoring handled
			//-> gets replaced if less than row specific maxtime() afterwards
			tempvar tvar
			gen `tvar' = 0 in 1/2
			su `maxtime'
			replace `tvar' = `r(max)' in 2
					
			galahad , 	models(`model') 				///
						singleevent 					///
						survsim(`stime') 				///
						survsimtouse(`modtouse') 		///
						n(`N') 							///
						timevar(`tvar')					///
						transprob						//

		
		}
		
end
