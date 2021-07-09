*!Author: P. Wilner Jeanty
*!Date: January 17, 2010
program define spmlreg_sac
	version 11.0
	args lnf $spmlreg_ARGS
	tempvar L0 L1 L2 L3 rhowy 
	if $spmlreg_w1==0 {
		qui gen double `rhowy'=`rho'*wy_`e(depvar)'  
		qui gen double `L0'=`rho'*spmlreg_eigv 
		qui gen double `L3'= `rho'*`lambda'*spmlreg_w2w2y 
	}
	else {
		qui gen double `rhowy'=`rho'*spmlreg_w1y  
		qui gen double `L0'=`rho'*spmlreg_eigv1 
		qui gen double `L3'= `rho'*`lambda'*spmlreg_w2w1y 
	} 
	qui gen double `L1'=`lambda'*spmlreg_eigv 
	qui gen double `L2'=`lambda'*wy_`e(depvar)'
	forv i=1/$spmlreg_nv {
        	tempvar X`i' XX`i'
        	qui gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spmlreg_matols)''
        	local LIST1 "`LIST1'`X`i''-"
        	qui gen double `XX`i''=`lambda'*`beta`i''*spmlreg_wx`i' 
        	local LIST2 "`LIST2'`XX`i''+"
	}
	qui replace `lnf'=ln(1-`L0') + ln(1-`L1')-0.5*ln(2*_pi)-0.5*ln(`sigma'^2)-  ///
                (0.5/(`sigma'^2))*((`e(depvar)' -`rhowy' - `L2' + `L3' -`LIST1'   ///
                `beta0'+`LIST2'`lambda'*`beta0')^2) if $ML_samp==1

end

