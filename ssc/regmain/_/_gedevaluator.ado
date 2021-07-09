program _gedevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 p 
	tempvar x v 
	qui gen double `x' = $ML_y1 - `beta'
	qui gen double `v' = sqrt(exp(lngamma(1/`p') - lngamma(3/`p')))
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
	qui replace `lnf' = ln(`p') - (abs(`x')/(`v'*`sigma'))^(`p') - ln(2) - ln(`v') - ln(`sigma') - lngamma(1/`p')
end

