program define rcod, rclass
	syntax varname (numeric) [if] [in] 
	marksample touse 
	qui{
		sum `varlist' if `touse', detail
		local median = r(p50)
		local s = r(N)
	}	
		if `median'==0 {
			di as err /*
			*/ "The median equals zero. No COD"
			exit 198
		}
		else {
			tempvar absl
			qui{		
			gen `absl'=abs((`varlist'-`median'))
			sum `absl' if `touse'
			local tabsl=r(sum)
			local dev= (`tabsl'/`s')*100 
			return scalar cod= `dev'/`median'
			}
		}
end
