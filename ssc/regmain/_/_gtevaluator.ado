program _gtevaluator
version 12.0
	args lnf beta $sigma $t1 $g1 p q
	tempvar x v m mu b1 b2
	qui gen double `b1' = lngamma(1/`p') + lngamma(`q') - lngamma(1/`p' + `q')
	qui gen double `b2' = lngamma(3/`p') + lngamma(`q'-2/`p') - lngamma(3/`p' + `q' - 2/`p')
	qui gen double `mu' = 0
	qui gen double `x' = $ML_y1 - `beta'
	qui gen double `v' = `q'^(-1/`p') * (exp(`b1')/exp(`b2'))^(1/2)
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
	qui gen double `m' = ((abs(`x' - `mu')^`p')/(`q'*(`v'*`sigma')^`p') + 1)
	qui replace `lnf' = ln(`p') - ln(2) - 1.5*(`b1') + .5*(`b2') - ln(`sigma') - (1/`p' + `q')*ln(`m')
end

