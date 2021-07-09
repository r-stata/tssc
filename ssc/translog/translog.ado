*! version 1.1  3Mar2017
* Kerry Du
cap program drop translog
program def translog,rclass
  syntax varlist(min=1) [,Time(varname) NORMalize Local(str)] 
            version 10.1 
            local newvarlist
			if "`normalize'"=="" {
					foreach v of local varlist {
						qui gen ln`v'=ln(`v')
						label var ln`v' "log(`v')"
						local newvarlist `newvarlist' ln`v' 
					 }
					
					local y `varlist'
					foreach v of local varlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=0.5*ln`v'*ln`v1'
							 label var ln`v'_ln`v1' "0.5 * ln`v' * ln`v1'"
							 local newvarlist `newvarlist' ln`v'_ln`v1'
					    }
					 }
					 
					if "`time'"!="" {
							qui egen _t=group(`time')
							label var _t  "time trend"
							local newvarlist `newvarlist' _t

							foreach v of local varlist {
								  qui gen _t_ln`v'=0.5*_t*ln`v'
								  label var _t_ln`v'  "0.5 * _t * ln`v'"
								  local newvarlist `newvarlist' _t_ln`v'
							   }
							qui gen _t_2=0.5*_t^2
					        label var _t_2 "0.5 * _t_square"
					        local newvarlist `newvarlist' _t_2
						}

					foreach v of local varlist {
							qui gen ln`v'_2=0.5*ln`v'*ln`v'
							label var ln`v'_2 "0.5 * ln`v'_square"
							local newvarlist `newvarlist' ln`v'_2 
						 }


					
			 }
			else {
				    disp as green "Note: Variables are normalized by their means respectively before taking log."
					foreach v of local varlist {
					    qui su `v'
						local vmean=r(mean)
						qui gen ln`v'=ln(`v'/`vmean')
						label var ln`v' "log(`v')"
						local newvarlist `newvarlist' ln`v'
						//qui gen ln`v'_2=0.5*ln`v'*ln`v'
						//label var ln`v'_2 "0.5 * ln`v'_square"
					 }
					 
					local y `varlist'
					foreach v of local varlist {
						gettoken x y: y
						foreach v1 of local y {
						  qui gen ln`v'_ln`v1'=0.5*ln`v'*ln`v1'
						  label var ln`v'_ln`v1' "0.5 * ln`v' * ln`v1'"
						  local newvarlist `newvarlist' ln`v'_ln`v1'
					    }
					 }
					 if "`time'"!="" {
					 	disp as green "Note: _t is the deviation from the mean."
						qui egen _t=group(`time')
						label var _t  "time trend"
						qui su _t
						local vmean=r(mean)
						qui replace _t=_t-`vmean'
						local newvarlist `newvarlist' _t


					 	foreach v of local varlist {
						   qui gen _t_ln`v'=0.5*_t*ln`v'
						   label var _t_ln`v'  "0.5 * _t * ln`v'"
						   local newvarlist `newvarlist' _t_ln`v'
							   
							}

						qui gen _t_2=0.5*_t^2
						label var _t_2 "0.5*_t_square"
						local newvarlist `newvarlist' _t_2

					   }

					foreach v of local varlist {
							qui gen ln`v'_2=0.5*ln`v'*ln`v'
							label var ln`v'_2 "0.5 * ln`v'_square"
							local newvarlist `newvarlist' ln`v'_2 
						}

					
			}
					
			return local xvar `newvarlist'		
			if "`local'" != "" {
				c_local `local' `newvarlist'
			 }
				
					
	end
