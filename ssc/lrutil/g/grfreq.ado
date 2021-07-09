program define grfreq
*! 1.0.0 6 June 2000 Jan Brogger
	version 6.0
	syntax varlist (max=2 min=2 numeric) [if/] [, gropt(string) OUTcom(integer 1) noyaxis01]
	preserve

	quietly {
		tokenize "`varlist'"
		local outcomv "`1'"
		local strata "`2'"

		tempvar prev
		tempvar tot
		*tempvar freq_z
		capture confirm new variable freq_z
		if _rc ~= 0 {
			display ""
			exit 110
		}


		if "`if'"~="" {
			drop if !(`if') 
		}


		table `strata' `outcomv', col replace name(freq_z)

		sort `strata' `outcomv'
		gen `tot'=.
		by `strata': replace `tot'=freq_z[_N]

		gen `prev'=.
		replace `prev'=freq_z/`tot'

		label variable `prev' "Proportion of `outcomv'"

		if "`outcom'" ~= "" {
			drop if `outcomv' ~= `outcom'
		}
		else {
			*use the minimum of the outcome, e.g. 0 or 1
			
			drop if `outcomv'[_n] ~= `outcomv'[1]
		}

	} /*quietly */

	if "`yaxis01'" == "" {local yax "ylab(0(0.10)1)"}


	if index("`gropt'","t1")==0 & index("`gropt'","t2")==0{
		local t1 t1("Proportion or prevalence of `outcomv' by `strata'")
	}


	graph `prev' `strata' , c("l") `yax' `gropt' `t1'
	restore
end

