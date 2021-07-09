*! version 1.0.1 DH 21Dec2004.
* Changes in 1.0.1 - name changed from kapci to kappci (conflict with Stata Journal program)
*                    bug fixed in formula for lower bound of Donner-Eliasziw interval (thanks to JMP de Souza)
program define kappci, rclass
    version 8.0
	syntax varlist(min=2) [if] [in] /*
	    */ [, POSitive(string asis) Level(integer $S_level) /*
		*/ Exact Wilson Agresti Jeffreys]
    tempvar touse
	mark `touse' `if' `in'
	qui count if `touse'
	if r(N) < 1 {
		error 2000
	}
    local nvars : word count `varlist'
    tokenize `varlist'
    forvalues i=1/`nvars' {
		cap assert missing(``i'') if `touse'
		if _rc==0 { // drop variables with all missing values
			di as text "note:  ``i'' contains all missing values; variable ignored"
		}
        else { // generate new variables identifying positive ratings
            tempvar pos`i'
            if `"`positive'"'!="" {
                qui gen byte `pos`i''=``i''==`positive' if !missing(``i'') & `touse'
            }
            else {
                confirm numeric var ``i''
                qui gen byte `pos`i''=``i''!=0 if !missing(``i'') & `touse'
            }
            local poslist "`poslist' `pos`i''"
        }
    }
	local npos : word count `poslist'
	if `npos'==0 {
		di as error _n "no rating variables remain"
		exit 498
	}
    if `npos'==1 {
        di as error _n "only one rating variable remains"
        exit 498
    }
    if `npos'==2 { // two raters
        * call -kap- and store returns
        qui kap `poslist'
        local kappa=r(kappa)
        local z=r(z)
        local pval=1-norm(`z')
        local prop_e=r(prop_e)
        local prop_o=r(prop_o)
        return add
        * calculate ci for observed agreement
        tempname tab2x2
       	qui tab2 `poslist', matcell(`tab2x2')
		local n1=`tab2x2'[1,1]
		local n2=`tab2x2'[1,2]+`tab2x2'[2,1]
		local n3=`tab2x2'[2,2]
		local N=`n1'+`n2'+`n3'
       	local p=(2*`n1'+`n2')/(2*`N')
        local agr=`n1'+`n3'
        qui cii `N' `agr', `exact' `wilson' `agresti' `jeffreys' level(`level')
        local prop_lb=r(lb)
        local prop_ub=r(ub)
        * calculate ci for kappa, following Donner & Eliasziw (1992)
		local chi1=invchi2tail(1,(100-`level')/100)
       	local y1=((`n2'-2*`N'*`p'*(1-`p'))^2+4*(`N'^2)*(`p'^2)*((1-`p')^2))/(4*`N'*(`p'^2)*((1-`p')^2)*(`chi1'+`N'))-1
		local y2=((`n2'^2)-4*`N'*`p'*(1-`p')*(1-4*`p'*(1-`p'))*`chi1')/(4*`N'*(`p'^2)*((1-`p')^2)*(`chi1'+`N'))-1
		local y3=(`n2'+(1-2*`p'*(1-`p'))*`chi1')/(`p'*(1-`p')*(`chi1'+`N'))-1
        local V=(`y3'^3)/27-(`y2'*`y3'-3*`y1')/6
		local W=(((`y3')^2)/9-`y2'/3)^(3/2)
        local theta=acos(`V'/`W')
        local lb=sqrt((1/9)*(`y3')^2-`y2'/3)*(cos((`theta'+2*_pi)/3)+sqrt(3)*sin((`theta'+2*_pi)/3))-`y3'/3
		local ub=2*sqrt((1/9)*(`y3')^2-`y2'/3)*(cos((`theta'+5*_pi)/3))-`y3'/3
        * output results
        if "`wilson'"!="" {
            local citext "{hline 6} Wilson {hline 6}"
        }
        else if "`agresti'"!="" {
            local citext "{hline 2} Agresti-Coull {hline 3}"
        }
        else if "`jeffreys'"!="" {
            local citext "{hline 5} Jeffreys {hline 5}"
        }
        else {
            local citext "{hline 2} Binomial Exact {hline 2}"
        }
        di as text _n " Expected    Observed   `citext'"
        di as text "Agreement   Agreement   [`level'% Conf. Interval]"
        di as text "{hline 44}"
        di as result %8.2f 100*`prop_e' "%   " %8.2f 100*`prop_o' "%   " /*
			*/ %8.2f 100*`prop_lb' "%  " %8.2f 100*`prop_ub' "%"
        di as text _n "  Kappa" _col(10) "[`level'% Conf. Interval]" _col(38) "Z" _col(44) "Prob>Z"
        di as text "{hline 49}"
        di as result %7.4f `kappa' _col(12) %7.4f `lb' _col(23) %7.4f `ub' /*
            */ _col(32) %7.2f `z' _col(43) %7.4f `pval'
        return scalar prop_ub=`prop_ub'
        return scalar prop_lb=`prop_lb'
		return scalar kappa_ub=`ub'
        return scalar kappa_lb=`lb'
    }
    else { // more than 2 raters
		* reformulate for -kappaci-
        tempvar pos neg m
        qui egen `pos'=rsum(`poslist') if `touse'
        qui egen `m'=robs(`poslist') if `touse'
        qui gen `neg'=`m'-`pos'
        kappaci `pos' `neg', level(`level')
		return add
    }
end
