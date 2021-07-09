program _sgtevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 lambda p q
	tempvar x v m mu
	qui gen double `mu' = 0
	qui gen double `x' = $ML_y1-`beta'
	qui gen double `v' = (`q'^(-1/`p'))/((3*(`lambda'^2)+1)*(exp(lngamma(3/`p') + lngamma(`q'-2/`p')-lngamma(3/`p'+`q'-2/`p'))/exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))-4*(`lambda'^2)*((exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))^(2)/((exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))^2)))^(1/2)
	if "${arch}" != "0" | "${garch}" != "0"{
		tempvar sigma
		qui gen double `sigma' = $insig^2 
		loc sigeq = "`a0'"
		local arch = $arch
		local garch = $garch
		loc max = `arch'
		if `garch' > `arch'{
			local max = `garch'
		}
		forvalues i = 1/`arch'{
			loc sigeq "`sigeq' + `a`i''*(`x'[_n-`i'])^2"
		}
		forvalues i = 1/`garch'{
			loc sigeq "`sigeq' + `b`i''*`sigma'[_n-`i']"
		} 
		qui replace `sigma' = `sigeq' if _n>`max'
		qui replace `sigma' = sqrt(abs(`sigma'))
	}
	qui gen double `m' = (2*`v'*`sigma'*`lambda'*`q'^(1/`p')*exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))/(exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))
	qui replace `lnf' = ln(`p') - ln(2)-ln(`v')-ln(`sigma')-(1/`p')*ln(`q')-(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q'))-(1/`p' + `q')*ln((((abs(`x' + `mu' + `m'))^(`p'))/(`q'*(`v'*`sigma')^(`p')*(`lambda'*sign(`x'-`mu'+`m')+1)^(`p')))+1)
end		
	

