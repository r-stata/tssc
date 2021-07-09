*! mixlcov 1.1.0 25Jun2015
*! author arh

program define mixlcov
	version 9.2
	syntax [, sd post iter(integer 100)]

	if ("`e(cmd)'" != "mixlogit" & "`e(cmd)'" != "mixlogitwtp") error 301

	local nllocal
	local krnd = e(krnd)

	if ("`sd'" == "") {
		forvalues i = 1(1)`krnd' {
			forvalues j = `i'(1)`krnd' {
				forvalues k = 1(1)`i' {
					if (`i'==1) {
						local nllocal `nllocal' (v`j'`i': [l`j'`k']_b[_cons]*[l`i'`k']_b[_cons])
					}
					else {
						if (`k'==1) local nllocal `nllocal' (v`j'`i': [l`j'`k']_b[_cons]*[l`i'`k']_b[_cons] +
						if (`k'!=1 & `k'!=`i') local nllocal `nllocal' [l`j'`k']_b[_cons]*[l`i'`k']_b[_cons] +
						if (`k'==`i') local nllocal `nllocal' [l`j'`k']_b[_cons]*[l`i'`k']_b[_cons])
					}
				}
			}
		}
		nlcom `nllocal', iter(`iter') `post'
	}

	if ("`sd'" != "") {
		forvalues i = 1(1)`krnd' {
			forvalues k = 1(1)`i' {
				local n = `i' + e(kfix)
				local name :  word `n' of `e(indepvars)'
				if (`i'==1) {
					local nllocal `nllocal' (`name': sqrt([l`i'`k']_b[_cons]*[l`i'`k']_b[_cons]))
				}
				else {
					if (`k'==1) local nllocal `nllocal' (`name': sqrt([l`i'`k']_b[_cons]*[l`i'`k']_b[_cons] +
					if (`k'!=1 & `k'!=`i') local nllocal `nllocal' [l`i'`k']_b[_cons]*[l`i'`k']_b[_cons] +
					if (`k'==`i') local nllocal `nllocal' [l`i'`k']_b[_cons]*[l`i'`k']_b[_cons]))
				}
			}
		}
		nlcom `nllocal', iter(`iter') `post'
	}
end
