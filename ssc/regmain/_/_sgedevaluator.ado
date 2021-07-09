program _sgedevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 lambda p 
	tempvar x v m mu
	qui gen double `mu' = 0
	qui gen double `x' = $ML_y1 - `beta'
	qui gen double `v' = sqrt(_pi*exp(lngamma(1/`p'))/(_pi*(1+3*`lambda'^2)*exp(lngamma(3/`p'))-16^(1/`p')*`lambda'^2 * exp(lngamma(1/2 + 1/`p'))^2 * exp(lngamma(1/`p'))))
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
	qui gen double `m' = 2^(2/`p')*`v'*`sigma'*`lambda'*exp(lngamma(1/2+1/`p'))/sqrt(_pi)
	qui replace `lnf' = ln(`p') - (abs(`x' - `mu' + `m')/(`v'*`sigma'*(1+`lambda'*sign(`x'-`mu'+`m'))))^`p' - ln(2) - ln(`v') - ln(`sigma') - lngamma(1/`p')
	
end
		
