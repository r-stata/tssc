program _snormalevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 lambda
	tempvar x v m
	qui gen double `x' = $ML_y1 - `beta'
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
	qui gen double `v' = sqrt((2*_pi)/(_pi - 8*`lambda'^2 + 3 * _pi*`lambda'^2))
	qui gen double `m' = 2*`v'*`sigma'*`lambda'/sqrt(_pi)
	qui replace `lnf' = -((`x' + `m')^2/(`v'*`sigma'*(1 + `lambda'*sign(`x' + `m')))^2) - ln(`v') - ln(`sigma') - .5*ln(_pi)
	
end

