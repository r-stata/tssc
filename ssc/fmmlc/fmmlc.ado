*! version 1.0.1 Joerg Luedicke 09june2011

program fmmlc, rclass

	version 9.2

	syntax [, savec savep]

/*Checking if results from -fmm- are available*/
	if ("`e(cmd)'" != "fmm") {
		di as error "No -fmm- results found."
	exit 301
	}

/*Stuff from previous -fmm-*/
	tempname lnk nc pa lol
	local n=e(components)
	scalar `lnk'=ln(`n')
	scalar `nc'=e(N)
	scalar `pa'=e(k)
	scalar `lol'=e(ll)

/*Predicting posterior probabilities*/
	if "`savep'"=="savep" {
		forvalues i = 1(1)`n' {
			capture	ds _prob`i'_*
			local nvar : word count `r(varlist)'
			local v=`nvar'+1
			qui predict float _prob`i'_`v' if e(sample), post equation(component`i')
		}
	}
	forvalues i = 1(1)`n' {
		tempvar prob`i'
		qui predict float `prob`i'' if e(sample), post equation(component`i')
	}

/*Entropy*/
	tempvar temp
	tempname e ent
		mat `e'=J(1,`n', 0)
			forvalues i = 1(1)`n' {
				qui gen `temp'`i'=(log(`prob`i'')*(`prob`i''*-1))
				qui sum `temp'`i', meanonly
					if `i'==1{
						mat `e'[1,`i']=r(sum)
					}
					else {
						mat `e'[1,`i']=r(sum)+`e'[1,`i'-1]
					}
			}
		scalar `ent'=1-((`e'[1,`n'])/(`nc'*`lnk'))
	
/*Information criteria*/
	tempname aic bic sbic
		scalar `aic'=-2*`lol'+2*`pa'
		scalar `bic'=-2*`lol'+`pa'*ln(`nc')
		scalar `sbic'=-2*`lol'+`pa'*ln((`nc'+2)/24)

/*Class counts and proportions based on posterior probabilities*/
	if "`savep'"=="savep" {
		forvalues i=1(1)`n' {
			tempname co`i' pr`i'
			qui sum _prob`i'_`v', meanonly
			scalar `pr`i''=r(mean) 
			scalar `co`i''=r(mean)*r(N)
		}
	}
	else {
		forvalues i=1(1)`n' {
			tempname co`i' pr`i'
			qui sum `prob`i'', meanonly
			scalar `pr`i''=r(mean) 
			scalar `co`i''=r(mean)*r(N)
		}
	}

/*Most Likely Latent Class Membership*/
	tempvar class maxp
	tempname mem
		local k=`n'+1
		qui egen `maxp'=rowmax(`prob1' - `prob`n'')
			if "`savec'"=="savec" {
				capture	ds _class_*
				local nvar : word count `r(varlist)'
				local v=`nvar'+1
				qui gen int _class_`v'=.
				label var _class_`v' "Classification of subjects based on most likely LC membership"
					forvalues i = 1(1)`n' {
						qui replace _class_`v'=`i' if `prob`i''==`maxp' & !missing(`prob`i'')
						label define fmmcomp `i'"FMM Component `i'",  modify 
						label val _class_`v' fmmcomp
						}
			}

		mat `mem' = J(`k',2,0)
		qui gen `class'=.
			forvalues i = 1(1)`n' {
				qui replace `class'=`i' if `prob`i''==`maxp' & !missing(`prob`i'')
				qui cou if `class'==`i'
					mat `mem'[`i',1] = r(N)
					mat `mem'[`i',2] = (r(N)/`nc')*100	
			}
			mat `mem'[`k', 1] = `nc'
					
/*Average Latent Class Probabilities for Most Likely Latent Class Membership*/
	tempname means
	local m 0
		mat `means' = J(`n',`n',0)
			foreach v of varlist `prob1' - `prob`n'' {
				local ++m
					forvalues i = 1(1)`n' {
						qui sum `v' if `class'==`i', meanonly
						mat `means'[`i',`m'] = r(mean)
					}
			}

/*Output*/
	di
	di as txt "{hline 77}" 
	di as result "Final class counts and proportions based on estimated posterior probabilities"
	di
	di as txt _col(4) "Component" as txt _col(20) "Proportion" as txt _col(38) "Count"
	di as text "{hline 15}{c +}{hline 15}{c +}{hline 15}"
		forvalues i=1(1)`n' {
			di as txt _col(8) "`i'" _col(21) as result %6.3f `pr`i'' _col(32) as result %12.3f `co`i''
		}
	di as text "{hline 15}{c +}{hline 15}{c +}{hline 15}"
	di
	di("{hline 71}")  
	display as result "Classification of subjects based on most likely latent class membership"
	di
	di as txt _col(4) "Component" as txt _col(20) "Frequency" as txt _col(37) "Percent"
	di as text "{hline 15}{c +}{hline 15}{c +}{hline 15}"
		forvalues i = 1(1)`n' {
			di as txt _col(8) `i' _col(18) as result %9.0g `mem'[`i',1] _col(39) as result %5.2f `mem'[`i',2]
		}
	di as text "{hline 15}{c +}{hline 15}{c +}{hline 15}"
	di as txt _col(6) "Total" as result %9.0g  _col(18) `mem'[`k', 1] 	
	di 
	di("{txt}{hline 31}") 
	display as result "Average posterior probabilities"
	di
		local lsize=2+10*`n'
			di as txt _col(5) "Mean {...}"
				forvalues k = 1(1)`n' {
					local a=12+10*`k'
					di as txt _col(`a') "LC`k' {...}"
				}
	di
	di("{txt}{hline 12}{c |}{hline `lsize'}") 
		forvalues i = 1(1)`n' {
			di as txt _col(6) "p`i'     {c |} {...}"
				forvalues j = 1(1)`n' {
					local p=11+10*`j'
					di as res _col(`p') %4.3f `means'[`i',`j'] "{...}"
				}
			di
		}
	di("{txt}{hline 12}{c |}{hline `lsize'}") 			
	di 
	di
	di("{txt}{hline 33}") 
	di as result "Distinctiveness of latent classes"
	di("{txt}{hline 33}") 
	di as txt "Entropy:" _col(29) as result %4.3f `ent'
	di("{txt}{hline 33}") 
	di as txt ""
	di as txt ""
	di("{hline 38}") 
	di as result "Information criteria"
	di("{txt}{hline 38}")
	di as txt "AIC:" _col(27) as result %12.3f `aic'	
	di as txt "BIC:" _col(27) as result %12.3f `bic'
	di as txt "Sample size adjusted BIC:" _col(27) as result %12.3f `sbic'	
	di
	di as txt "# free parameters:" _col(27) as result %12.0f `pa'
	di as txt "Log likelihood:" _col(27) as result %12.3f `lol'
	di("{txt}{hline 38}")

/*Return scalars and matrices*/
	return  scalar entropy = `ent'
	return  scalar BIC2 = `sbic'
	return  scalar BIC = `bic'
	return  scalar AIC = `aic'
	return  mat app = `means'
	
end	
	
	

