program define cluster3, rclass
	version 10.1
	syntax [, a(real 0.05) p(real 0.8) r3(real 0) r2(real 0) rxy(real 0) d(real 1) n3(integer 1) n2(integer 1) n1(integer 1) power mdes obs3 obs2 obs1]
		foreach x in r2 r3 rxy {
			if abs(``x'')>1 {
				di ""
				di "ERROR: condition -1<`x'<1 not met"
				di ""
				exit 499
			}
		}
		foreach x in a p {
			if ``x''>1 | ``x''<0 {
				di ""
				di "ERROR: condition 0<`x'<1 not met"
				di ""
				exit 499
			}
		}
		if `r2'<`r3' {
			di ""
			di "ERROR: ICC2 cannot be less than ICC3"
			di ""
			exit 499
		}
		if `n3'<1 | `n2'<1 | `n1'<1 {
		    di ""
			di "ERROR: n3, n2, n1 must be >=1"
			di ""
			exit 499
		}

		if "`power'"!="" {
			local  f = 1 + `n1'*(`n2'-1)*`r3' + (`n1'-1)*`r2'
			local  p = normal(`d'*sqrt(`n3'*`n2'*`n1'/(2*`f'*(1-`rxy'^2)))-invnormal(1-`a'/2))
		}
		
		if "`obs3'"!="" {
			local  f = 1 + `n1'*(`n2'-1)*`r3' + (`n1'-1)*`r2'
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local n3 = round((2*`f'*(1-(`rxy')^2)*`g'^2)/(`n2'*`n1'*`d'^2))
		}
		
		if "`obs2'"!="" {
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local n2 = round((2*(1+(`r2'-`r3')*`n1'-`r2')*(1-`rxy'^2)*`g'^2)/(`n1'*`n3'*(`d'^2)-2*`r3'*`n1'*(1-`rxy'^2)*`g'^2))
		}

		if "`obs1'"!="" {
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local n1 = round((2*(1-`r2')*(1-`rxy'^2)*`g'^2)/(`n2'*`n3'*`d'^2-2*((`n2'-1)*`r3'+`r2')*(1-`rxy'^2)*`g'^2))
		}
		
		if "`mdes'"!="" {
			local  f = 1 + `n1'*(`n2'-1)*`r3' + (`n1'-1)*`r2'
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local  d = `g'*sqrt((2*`f'*(1-`rxy'^2))/(`n2'*`n1'*`n3'))
		}

		if "`power'"=="" & "`mdes'"=="" & "`obs3'"=="" & "`obs2'"=="" & "`obs1'"=="" {
			di "ERROR: must use one of the following options; power, mdes, obs3, obs2, or obs1"
			exit 499
		}
		local N = 2*`n3'*`n2'*`n1'
		di in green "*****************************************************"
		di in green "Alpha =" as result %4.3f _col(40) `a'
		di in green ""
		di in green "Level-3 ICC =" as result %4.3f _col(40) `r3'
		di in green "Level-2 ICC =" as result %4.3f _col(40) `r2'
		di in green "Corr(x,y) =" as result %-4.3f _col(40) `rxy'
		di in green ""
		di in green "Power =" as result %4.3f _col(40) `p'
		di in green "Delta =" as result %4.3f _col(40) `d'
		di in green ""
		di in green "Level-3 clusters per group =" as result %12.0fc _col(30) `n3'
		di in green "Level-2 obs =" as result %12.0fc _col(30) `n2'
		di in green "Level-1 obs =" as result %12.0fc _col(30) `n1'
		di in green "Total obs =" as result %12.0fc _col(30) `N'
		di in green "*****************************************************"
		
		return local alpha = `a'
		return local rho3 = `r3'
		return local rho2 = `r2'
		return local rxy = `rxy'
		return local power = `p'
		return local delta = `d'
		return local obs3 = `n3'
		return local obs2 = `n2'
		return local obs1 = `n1'
		return local N = `N'
	end