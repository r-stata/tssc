*! version 1.0.0 MLB 15Okt2009
*! Fitting of fractional multinomial logit by ML
*! Called by fmlogit.ado

program define fmlogit_d2

	version 8.2
      gettoken ref rest: (global) S_depvars
	local K : word count $S_depvars
	forvalues i = 1/`=`K'-1' {
		local glist "`glist' g`i'"
	}
	args todo b lnf g negH `glist'
	forvalues i = 2/`K' {
		tempvar xb`i'
		mleval `xb`i'' = `b', eq(`=`i'-1')
	}
	tempvar denom lj
	quietly {
		gen double `denom' = 1
		forvalues i = 2/`K' {
			replace `denom' = `denom' + exp(`xb`i'')
		}
		tempvar p1
		gen double `p1' = 1/`denom'
		gen double `lj' = $ML_y1 * ln(`p1') 
		forvalues i = 2/`K' {
			tempvar p`i' 
			gen double `p`i'' = exp(`xb`i'')/`denom'
			replace `lj' = `lj' + ${ML_y`i'} * ln(`p`i'') 
		}

		mlsum `lnf' = `lj'
		if ( `todo' == 0 | `lnf' >=. ) exit

		forvalues i = 2/`K' {
			local j = `i' -1
			tempname d`i'
			replace `g`j'' = (${ML_y`i'}) - `p`i''
			mlvecsum `lnf' `d`i'' = `g`j'', eq(`j')
		}
		matrix `g' = `d2' 
		forvalues i = 3/`K' {
			matrix `g' = `g', `d`i''
		}
		
		if ( `todo' == 1 | `lnf' >=. ) exit
		
		tempvar num
		gen double `num' = .
		forvalues i = 2/`K'{
			replace `num' = 1
			forvalues j = 2/`K' {
				if `j' != `i' replace `num' = `num' + exp(`xb`j'')
			}
			tempvar fd`i'`i'
			gen double `fd`i'`i'' = `p`i''*`num'/`denom'
		}
		forvalues i = 2/`K' {
			forvalues j = `=`i'+1'/`K' {
				tempvar fd`i'`j'
				gen double `fd`i'`j'' = -`p`i''*`p`j''
			}
		}
		forvalues i = 2/`K' {
			local l = `i' -1
			tempname d`l'`l'
			mlmatsum `lnf' `d`l'`l'' = `fd`i'`i'', eq(`l')
			forvalues j = `=`i'+1'/`K' {
				local m = `j' - 1
				tempname d`l'`m'
				mlmatsum `lnf' `d`l'`m'' = `fd`i'`j'', eq(`l',`m')
			}
		}

		tempname nH
		forvalues i = 1/`=`K'-1'{
			tempname r`i'
			forvalues j = 1/`=`K'-1'{
				local t = cond(`i'<`j', "'", "")
				local index "`=min(`i',`j')'`=max(`i',`j')'"
				matrix `r`i'' = nullmat(`r`i''), `d`index''`t'
			}
			matrix `nH' = nullmat(`nH') \ `r`i''
		}

		matrix `negH' = `nH'
	}
end


