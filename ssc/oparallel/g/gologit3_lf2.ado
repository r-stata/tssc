*! version 1.0.1 15Jan2013 RW & MLB
*! version 1.0.0 07Jan2013 MLB
program define gologit3_lf2
	local mm1 = $S_m - 1
	forvalues i = 1/`mm1' {
		local g "`g' g`i'"
	}
	args todo b lnfj `g' H
	
	forvalues i = 1/`mm1' {
		tempvar theta`i'
		mleval `theta`i'' = `b', eq(`i')
	}
	quietly {
		replace `lnfj' = ln(invlogit(-`theta1')) if $ML_y1 == `: word 1 of $S_levs' & $ML_samp == 1
		forvalues  j = 2/`mm1'{
			local i = `j' - 1
			replace `lnfj' = ln(invlogit(-`theta`j'') - invlogit(-`theta`i'')) if $ML_y1 == `: word `j' of $S_levs' & $ML_samp == 1
		}
		replace `lnfj' = ln(invlogit(`theta`mm1'')) if $ML_y1 == `: word $S_m of $S_levs' & $ML_samp == 1
	}
	
	if (`todo'==0) exit
	quietly {
		replace `g1' = 0 if $ML_samp == 1
		replace `g1' = -invlogit(`theta1') if $ML_y1 == `: word 1 of $S_levs' & $ML_samp == 1
		replace `g1' = (invlogit(`theta1')*invlogit(-`theta1')) /  ///
		               (invlogit(-`theta2') - invlogit(-`theta1')) ///
					   if $ML_y1 == `: word 2 of $S_levs' & $ML_samp == 1
		
		forvalues j = 2/`=`mm1'-1' {
			local i = `j' - 1
			local k = `j' + 1
			replace `g`j'' = 0 if $ML_samp == 1
			replace `g`j'' = (-invlogit(`theta`j'')*invlogit(-`theta`j'')) / ///
			                  (invlogit(-`theta`j'') - invlogit(-`theta`i'')) ///
							  if $ML_y1 == `: word `j' of $S_levs' & $ML_samp == 1
			replace `g`j'' = ( invlogit(`theta`j'')*invlogit(-`theta`j'')) / ///
			                 (invlogit(-`theta`k'') - invlogit(-`theta`j'')) ///
							 if $ML_y1 == `: word `k' of $S_levs' & $ML_samp == 1
		}

		replace `g`mm1'' = 0 if $ML_samp == 1
		replace `g`mm1'' = (-invlogit(`theta`mm1'')*invlogit(-`theta`mm1'')) / ///
		                   (invlogit(-`theta`mm1'') - invlogit(-`theta`=`mm1'-1'')) ///
						   if $ML_y1 == `: word `mm1' of $S_levs' & $ML_samp == 1
		replace `g`mm1'' = invlogit(-`theta`mm1'') if $ML_y1 == `: word $S_m of $S_levs' & $ML_samp == 1
	}
	
	if (`todo'==1) exit
	
	tempvar temp
	forvalues i = 1/`mm1' {
		forvalues j = `i'/`mm1' {
			tempname d`i'`j'
		}
	}
	quietly {
		gen double `temp' = 0 if $ML_samp == 1
		replace `temp' = -invlogit(`theta1')*invlogit(-`theta1') if $ML_y1 == `: word 1 of $S_levs' & $ML_samp == 1
		replace `temp' = -exp(`theta1')*(exp(`theta2') + 1)*(exp(`theta2') + exp(2*`theta1')) / ///
						 ((exp(`theta1') + 1)^2*(exp(`theta2') - exp(`theta1'))^2) ///
						 if $ML_y1 == `: word 2 of $S_levs' & $ML_samp == 1
		mlmatsum `lnfj' `d11' = `temp' , eq(1)
		
		replace `temp' = 0 if $ML_samp == 1
		replace `temp' = exp(`theta1' + `theta2') / ( (exp(`theta2')-exp(`theta1'))^2 ) ///
						 if $ML_y1 == `: word 2 of $S_levs' & $ML_samp == 1
		mlmatsum `lnfj' `d12' = `temp', eq(1,2)
		forvalues i =  3/`mm1' {
			mlmatsum `lnfj' `d1`i'' = 0, eq(1,`i')
		}
		
		forvalues j = 2/`=`mm1'-1' {
			local i = `j' - 1
			local k = `j' + 1
			replace `temp' = 0 if $ML_samp == 1
			replace `temp' = -exp(`theta`j'')*(exp(`theta`i'')	 + 1)*(exp(`theta`i'') + exp(2*`theta`j'')) / ///
						     ((exp(`theta`j'') + 1)^2*(exp(`theta`j'') - exp(`theta`i''))^2) ///
			                 if $ML_y1 == `: word `j' of $S_levs' & $ML_samp == 1
			replace `temp' = -exp(`theta`j'')*(exp(`theta`k'')	 + 1)*(exp(`theta`k'') + exp(2*`theta`j'')) / ///
						     ((exp(`theta`j'') + 1)^2*(exp(`theta`k'') - exp(`theta`j''))^2) ///
			                 if $ML_y1 == `: word `k' of $S_levs' & $ML_samp == 1
			mlmatsum `lnfj' `d`j'`j'' = `temp', eq(`j')
			replace `temp' = 0 if $ML_samp == 1
			replace `temp' = exp(`theta`k'' + `theta`j'') / ( (exp(`theta`k'') - exp(`theta`j''))^2 ) ///
			                 if $ML_y1 == `: word `k' of $S_levs' & $ML_samp == 1
			mlmatsum `lnfj' `d`j'`k'' = `temp', eq(`j',`k')
			forvalues l = `=`j'+2' / `mm1' {
				mlmatsum `lnfj' `d`j'`l'' = 0, eq(`j',`l')
			}
		}
		replace `temp' = 0 if $ML_samp == 1
		local i = `mm1' - 1
		local j = `mm1'
		replace `temp' = -exp(`theta`j'')*(exp(`theta`i'')	 + 1)*(exp(`theta`i'') + exp(2*`theta`j'')) / ///
						     ((exp(`theta`j'') + 1)^2*(exp(`theta`j'') - exp(`theta`i''))^2) ///
			                 if $ML_y1 == `: word `mm1' of $S_levs' & $ML_samp == 1
		replace `temp' = - exp(`theta`mm1'')/((exp(`theta`mm1'')+1)^2) if $ML_y1 == `: word $S_m of $S_levs' & $ML_samp == 1
		mlmatsum `lnfj' `d`mm1'`mm1'' = `temp', eq(`mm1')
	}
	
    tempname nH
	forvalues i = 1/`mm1'{
        tempname r`i'
        forvalues j = 1/`mm1'{
            local t = cond(`i'<`j', "'", "")
            local index "`=min(`i',`j')'`=max(`i',`j')'"
            matrix `r`i'' = nullmat(`r`i''), `d`index''`t'
        }
        matrix `nH' = nullmat(`nH') \ `r`i''
    }
	matrix `H' = `nH'
end
