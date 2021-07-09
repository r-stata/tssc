*! firthlogit_ll.ado Version 1.1 JRC 2015-07-17
program define firthlogit_ll
	version 13.1

	args todo b lnL
	tempvar xb mu se
	tempname I

	mleval `xb' = `b', eq(1)

	quietly {
		generate double `mu' = invlogit( `xb') if $ML_y1 == 1
		replace         `mu' = invlogit(-`xb') if $ML_y1 == 0
		mlsum `lnL' = ln(`mu')

		generate double `se' = sqrt(`mu' * (1 - `mu'))
		local mataccumlist
		local var_index 1
		foreach var of global firthlogitpredictors {
			if strpos("`var'", "b.") | strpos("`var'", "o.") continue
			tempvar x`var_index'
			generate double `x`var_index'' = `var' * `se'
			local mataccumlist `mataccumlist' `x`var_index''
			local ++var_index
		}
		matrix accum `I' = `mataccumlist' `se', noconstant
		scalar define `lnL' = `lnL' + ln(det(`I')) / 2
	}
end

