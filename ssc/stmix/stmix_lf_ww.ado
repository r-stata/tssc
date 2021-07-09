*! version 1.0.1 13jul2012 MJC

program stmix_lf_ww
	version 11.2
	if "$xbeqn"=="yes" {
		local xbeqn xb
	}
	args lnf `xbeqn' p1 l1 g1 l2 g2
	tempvar pmix lambda1 gamma1 lambda2 gamma2 surv haz
qui {	
	gen double `pmix' 		= invlogit(`p1') 	if $ML_samp==1 
	gen double `lambda1' 	= exp(`l1') 		if $ML_samp==1 
	gen double `gamma1' 	= exp(`g1') 		if $ML_samp==1 
	gen double `lambda2' 	= exp(`l2') 		if $ML_samp==1 
	gen double `gamma2' 	= exp(`g2') 		if $ML_samp==1 
	
	local t _t
	local d _d
	local t0 _t0
	
	if "`xbeqn'"!="" {
		local xbcont exp(`xb')
	}
	else local xbcont 1
	
	gen double `surv' = (`pmix'*exp(-`lambda1'*`t'^`gamma1') + (1-`pmix')*exp(-`lambda2'*`t'^`gamma2') )^(`xbcont') 	if $ML_samp==1 
	gen double `haz' = 	(`t'*`xbcont'*(`lambda1'*`gamma1'*`pmix'*`t'^(`gamma1'-1)*exp(-`lambda1'*`t'^`gamma1') + `lambda2'*`gamma2'*(1-`pmix')*`t'^(`gamma2'-1)*exp(-`lambda2'*`t'^`gamma2') )/(`pmix'*exp(-`lambda1'*`t'^`gamma1') + (1-`pmix')*exp(-`lambda2'*`t'^`gamma2')))^`d' 	if $ML_samp==1 
	if $del_entry {
		local basesurv "- log((`pmix'*exp(-`lambda1'*`t0'^`gamma1') + (1-`pmix')*exp(-`lambda2'*`t0'^`gamma2') )^(`xbcont'))"
	}
	
	replace `lnf' = log(`surv'*`haz') `basesurv' 	if $ML_samp==1 
}

end

