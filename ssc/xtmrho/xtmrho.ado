* LEK
*! version 2.0.1  April 8, 2010 @ 16:27:10

program xtmrho , eclass
version 10.0
	capture : quietly :  estat group
	if _rc !=0 {
		di as error "No Multi-Level-Command specified"
		error 123
		}
	if _rc ==0  	{
		local ok =0
		if e(cmd)=="xtmixed" {
			eret scalar var_e     = exp(_b[lnsig_e:_cons])^2
			eret scalar var_sum   = e(var_e)
			local vkomp = e(k_rs) - 1
			local levels = colsof(e(N_g))

			foreach eb of numlist 1(1)`levels' {
				foreach num of numlist 1(1) `vkomp' {
					if `num' == 1 {
						eret scalar var_u`eb' = exp(_b[lns`eb'_1_1:_cons])^2
						}
					if `num' > 1 {
						capture eret scalar var_u`eb' = e(var_u`eb') + exp(_b[lns`eb'_1_`num':_cons])^2
						}
					}
				eret scalar var_sum   = e(var_sum)+e(var_u`eb')
				}
			di _n as text "Levels: " as result e(ivars) _n
			foreach eb of numlist 1(1)`levels' {
				eret scalar rho`eb'      = (e(var_u`eb'))/(e(var_sum))
				di as text "level " as result `eb' 
				di as text "Intraclass correlation  (ICC):  " as result "rho`eb'" as text " = " as result  %-7.5f e(rho`eb')
				di _n
				}
			local ok=1
			}
		
		if e(cmd)=="xtmelogit"  {
			local vkomp = e(k_rs) 
			local levels = colsof(e(N_g))
			eret scalar var_sum   =  (c(pi)^2)/3
			foreach eb of numlist 1(1)`levels' {
				foreach num of numlist 1(1) `vkomp' {
					if `num' == 1 {
						eret scalar var_u`eb' = exp(_b[lns`eb'_1_1:_cons])^2
						}
					if `num' > 1 {
						capture eret scalar var_u`eb' = e(var_u`eb') + exp(_b[lns`eb'_1_`num':_cons])^2
						}
					}
				eret scalar var_sum   = e(var_sum)+e(var_u`eb')
				}
			di _n as text "Levels: " as result e(ivars) 
			foreach eb of numlist 1(1)`levels' {
				eret scalar rho`eb'      = (e(var_u`eb'))/(e(var_sum))
				eret scalar mor`eb'      = exp(sqrt(2*e(var_u`eb'))*invnormal(0.75))
				di _n as text "level " as result `eb' as text ":"
				di as text "Intraclass correlation  (ICC):  " as result "rho`eb'" as text " = " as result  %-7.5f e(rho`eb')
				di as text "Median Odds Ratio (MOR):        " as result "mor`eb'" as text " = " as result  %-7.5f e(mor`eb')
				}
			local ok=1
			}
		
			if e(cmd)=="xtmepoisson"  {
			local vkomp = e(k_rs) 
			local levels = colsof(e(N_g))
			eret scalar var_sum   =  (c(pi)^2)/3
			foreach eb of numlist 1(1)`levels' {
				foreach num of numlist 1(1) `vkomp' {
					if `num' == 1 {
						eret scalar var_u`eb' = exp(_b[lns`eb'_1_1:_cons])^2
						}
					if `num' > 1 {
						capture eret scalar var_u`eb' = e(var_u`eb') + exp(_b[lns`eb'_1_`num':_cons])^2
						}
					}
				eret scalar var_sum   = e(var_sum)+e(var_u`eb')
				}
			di _n as text "Levels: " as result e(ivars) 
			foreach eb of numlist 1(1)`levels' {
				eret scalar mirr`eb'      = exp(sqrt(2*e(var_u`eb'))*invnormal(0.75))
				di  _n as text "level " as result `eb' as text ":"
				di as text "Median Incidence Rate Ratio (MIRR):        " as result "mirr`eb'" as text " = " as result  %-7.5f e(mirr`eb')
				}
			local ok=1
			} 
		}
end
