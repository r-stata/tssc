*!Author: P. Wilner Jeanty
*!Date: December 18, 2009                                                   
program define spmlreg_error
	version 11.0
	args lnf $spmlreg_ARGS
	tempvar L1 L2
	qui gen double `L1'=`lambda'*spmlreg_eigv 
	qui gen double `L2'=`lambda'*wy_`e(depvar)'
	forv i=1/$spmlreg_nv {
        	tempvar X`i' XX`i'
        	qui gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spmlreg_matols)''
        	local LIST1 "`LIST1'`X`i''-"
        	qui gen double `XX`i''=`lambda'*`beta`i''*spmlreg_wx`i' 
        	local LIST2 "`LIST2'`XX`i''+"
	}
	qui replace `lnf'=ln(1-`L1')-0.5*ln(2*_pi)-0.5*ln(`sigma'^2)-  ///
                (0.5/(`sigma'^2))*((`e(depvar)' -`L2'-`LIST1' ///
               `beta0'+`LIST2'`lambda'*`beta0')^2) if $ML_samp==1

end



