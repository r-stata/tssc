program _stevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 lambda q
	tempvar x v m
	qui gen double `x' = $ML_y1 - (`beta')
	qui gen double `v' = (`q'^(-.5))/sqrt((3*`lambda'^2 + 1)*(1/(2*`q'-2)) - ((4*`lambda'^2)/(_pi))*(exp(lngamma(`q'-.5) - lngamma(`q'))^2))
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
	qui gen double `m' = (2*`v'*`sigma'*`lambda'*sqrt(`q') * exp(lngamma(`q'-.5)))/(sqrt(_pi)*exp(lngamma(`q'+.5)))
	qui replace `lnf' = lngamma(.5+`q') - ln(`v') - ln(`sigma') - .5*ln(_pi) - .5*ln(`q') - lngamma(`q') - (.5+`q')*ln((abs(`x' + `m')^2)/(`q'*(`v'*`sigma')^2 *(`lambda'*sign(`x'+`m')+1)^2) + 1)
end

