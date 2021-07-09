program _egb2evaluator
version 12.0
	args lnf beta $sigma $t1 $g1 delta p q
	tempvar x
	qui gen double `x' = $ML_y1 - (`beta')
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
	qui replace `lnf' =`p'*(`x' - `delta')/`sigma' - ln(abs(`sigma')) - lngamma(`p')-lngamma(`q') + lngamma(`p'+`q') - (`p' + `q')*ln(1 + exp((`x' - `delta')/`sigma'))
end	


