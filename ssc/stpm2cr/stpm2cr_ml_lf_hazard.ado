program stpm2cr_ml_lf_hazard
	version 13.1
	
	mata: st_local("causelist", causelist)
	mata: st_local("nCauses", nCauses)
	mata: st_local("events", events)
	foreach n in `causelist' {
		mata:  st_local("cause_`n'", cause_`n')
	}
	qui {
		foreach i in `causelist' {
			tempvar _d`i'
			gen `_d`i'' = 1 if `events' == `i'
			replace `_d`i'' = 0 if `events' != `i'
		}
	}
	
	local del_entry 0
	qui summ _t0 , meanonly
	if r(max)>0 {
		local del_entry = 1
	}
	
	if `del_entry' == 0 {
		forvalues i = 1/`=`nCauses'*2' {
			local glist `glist' g`i'
		}
	}
	else {
		forvalues i = 1/`=(`nCauses'*2)+`nCauses'' {
			local glist `glist' g`i'
		}
	}
	
	args todo b lnfj `glist' H 
	tempvar sumF prodDer
	
	local i
	local j 
	local k
	foreach n in `causelist' {													
		tempvar `cause_`n'' `cause_`n''_dxb ht_`n' st_`n' ft_`n' Ft_`n' D_`n' 
		
		local i = `i' + 1
		mleval ``cause_`n''' = `b', eq(`i')

		local j = `j' + 1
		local k = `j' + `nCauses'
		mleval ``cause_`n''_dxb' = `b', eq(`k')
		
	}
	
	local l = (`nCauses'*2)
	if `del_entry' == 1 {
		foreach n in `causelist' {
			tempvar `cause_`n''_xb0 `cause_`n''_Ft0 `cause_`n''_st0
			
			local l = `l' + 1
			mleval ``cause_`n''_xb0' = `b', eq(`l')
			gen double ``cause_`n''_Ft0' = cond(_t0>0,1-exp(-exp(``cause_`n''_xb0')),0)
			local Ft0 `Ft0' - ``cause_`n''_Ft0'
		}
		local sumFt0 (1 `Ft0')
		local delent -ln(1 `Ft0')  
	}
	
	foreach n in `causelist' {	
		gen double `ht_`n'' = ``cause_`n''_dxb'*exp(``cause_`n''')
		gen double `st_`n'' = exp(-exp(``cause_`n'''))
		gen double `Ft_`n'' = 1 - exp(-exp(``cause_`n'''))
		gen double `ft_`n'' = (`ht_`n'')*(`st_`n'')
		gen double `D_`n'' = exp(``cause_`n''')*exp(-exp(``cause_`n'''))
		local density `density' `_d`n''*(ln(`ft_`n'')) +
		
		local sumFt `sumFt' `Ft_`n'' -
		
	}

	local sum = substr("`sumFt'",1,length("`sumFt'") - 1)
	gen double `sumF' = 1 - `sum'
	
	
	qui replace `lnfj' = `density' (1 - _d)*ln(`sumF') `delent'
	
	
	if (`todo' == 0 | `lnfj' >=.) exit
	
	local i = 0
	foreach n in `causelist' {													
		local i = `i' + 1
		qui replace `g`i'' = `_d`n''*(1 - exp(``cause_`n''')) - (1 - _d)*((exp(``cause_`n''') * `st_`n'')) / (`sumF')
	}
	
	local j =  `nCauses' 
	foreach n in `causelist' {													
		local j = `j' + 1
		qui replace `g`j'' = `_d`n''/``cause_`n''_dxb'
	}
	
	local l = (`nCauses'*2)
	if `del_entry' == 1 {
		foreach n in `causelist' {
			local l = `l' + 1
			qui replace `g`l'' =  cond(_t0>0,(exp(``cause_`n''_xb0')*exp(-exp(``cause_`n''_xb0')))/(`sumFt0'),0)
		}
	}
	
	if (`todo' == 1 | `lnfj' >=.) exit
	
	if `del_entry' == 1 { 
		local loopN `=`nCauses' *3'
	}
	else {
		local loopN `=`nCauses' *2'
	}
	
	forvalues i = 1/`loopN' {
		local dList `dList' d`i'`i'
	}

	forvalues i = 1/`loopN' {
		forvalues j = 1/`loopN' {
			if `i' != `j' {
				local dList `dList' d`i'`j'
			}
		}
	}

	tempname `dList'
	
	local i = 0
	foreach n in `causelist' {													
		local i = `i' + 1
		mlmatsum `lnfj' `d`i'`i'' = -1*`_d`n''*(exp(``cause_`n''')) -  ( ((1 - _d)*exp(``cause_`n''')*`st_`n'') / (`sumF') ) + ( ((1 - _d)*(exp(``cause_`n''')^2)*`st_`n'') / (`sumF') ) - ( (((1 - _d)*(exp(``cause_`n''')^2)*(`st_`n'')^2)) / ((`sumF')^2) ) , eq(`i')
	}
	
	local j =  `nCauses' 
	foreach n in `causelist' {													
		local j = `j' + 1
		mlmatsum `lnfj' `d`j'`j'' =  -1*(`_d`n'' / (``cause_`n''_dxb')^2), eq(`j')
	}
	
	if `del_entry' == 1 { 
		local l = `nCauses'*2
		foreach n in `causelist' {													
			local l = `l' + 1
			mlmatsum `lnfj' `d`l'`l'' =  cond(_t0>0,(exp(``cause_`n''_xb0')*exp(-exp(``cause_`n''_xb0'))*(`sumFt0'*(1-exp(``cause_`n''_xb0'))+exp(``cause_`n''_xb0')*exp(-exp(``cause_`n''_xb0')))) / (`sumFt0')^2,0), eq(`l')
		}
		
		local c = `nCauses'*2
		forvalues i = `=(`nCauses'*2)+1'/`loopN' {
			local c1 = `i' - `nCauses'*2
			forvalues j = `=(`nCauses'*2)+1'/`loopN' {
				local c2 = `j' - `nCauses'*2
				if `i' != `j' {
					mlmatsum `lnfj' `d`i'`j'' = cond(_t0>0,(exp(``cause_`c1''_xb0')*exp(-exp(``cause_`c1''_xb0'))*exp(``cause_`c2''_xb0')*exp(-exp(``cause_`c2''_xb0')))/(`sumFt0')^2,0), eq(`i',`j')
				}
			}
		}
		
		forvalues i = `=(`nCauses'*2)+1'/`loopN' {
			forvalues j = 1/`=`nCauses'*2' {
				mlmatsum `lnfj' `d`i'`j'' = 0, eq(`i',`j')
			}
		}
		forvalues i = `=`nCauses'+1'/`=`nCauses'*2' {
			forvalues j = 1/`loopN' {
				if `i' != `j' {
					mlmatsum `lnfj' `d`i'`j'' = 0, eq(`i',`j')
				}
			}
		}
		
		
	}
	else {

		forvalues i = `=`nCauses'+1'/`loopN' {
			forvalues j = 1/`loopN' {
				if `i' != `j' {
					mlmatsum `lnfj' `d`i'`j'' = 0, eq(`i',`j')
				}
			}
		}
	
	}
	
	
	forvalues i = 1/`nCauses' {
		forvalues j = 1/`loopN' {
			if `i' != `j' & `j'<=`nCauses' {
				local prodC1 = word("`causelist'",`j')
				local prodC2 = word("`causelist'",`i')
				mlmatsum `lnfj' `d`i'`j'' = - ( ((1 - _d)*`D_`prodC1''*`D_`prodC2'') / ((`sumF')^2) ), eq(`i',`j')
			}
			if `i' != `j' & `j'>`nCauses' {
				mlmatsum `lnfj' `d`i'`j'' = 0, eq(`i',`j')
			}
		}
	}
	
	forvalues i = 1/`loopN' {
		forvalues j = 1/`loopN' {
			local d`i'List `d`i'List' `d`i'`j'',
		}
		local d`i'List = substr("`d`i'List'",1,length("`d`i'List'") - 1)
		if `i' != `loopN' {
			local mat_dList `mat_dList' `d`i'List' \
		}
		else {
			local mat_dList `mat_dList' `d`i'List'
		}
	}
		
	matrix `H' = (`mat_dList')

	
end

