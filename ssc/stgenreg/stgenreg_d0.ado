*! version 0.6.0 04jan2013 MJC

program define stgenreg_d0
	version 11.2
    args todo b lnf
	tempvar logh ch

	forvalues i = 1/$np {
		local ind : word `i' of $mlevalid
		if `ind'==0 {
			tempname xb`i'
			mleval `xb`i'' = `b', eq(`i') scalar
			mata: p`i' = st_numscalar("`xb`i''")
			local pnames "`pnames' ,p`i'"
		}
		else {
			tempvar xb`i'
			mleval `xb`i'' = `b', eq(`i')
			mata: p`i' = st_data(.,"`xb`i''",touse)
			local test : word `i' of $tdeind
			if `test'==1 {
				tempname p`i'coefmat
				local eqname : word `i' of $eq_names
				matrix `p`i'coefmat' = $ML_b[1,"`eqname':"]
				local pcoefnames "`pcoefnames' ,st_matrix("`p`i'coefmat'")"
			}
			local pnames "`pnames' ,p`i'"
		}
	}
	
	qui gen double `logh' = .
	mata: logh = $mataloghazard1
	mata: st_store(.,"`logh'",touse,logh)

	if "$bhazvar"=="" {
		local lnht `logh' + ln(_t)				// log hazard function (standard model)
	}
	else {
		local lnht ln($bhazvar + exp(`logh'))	// log hazard function (rel surv model)
	}
	
	qui gen double `ch' = .	
	mata: cumhaz("`ch'",touse,knewnodes1,kweights1,nnodes1 `pnames' `pcoefnames' $arraynames)
	
	qui mlsum `lnf' = _d*(`lnht') - `ch'
	
end



mata:
	mata set matastrict off
	void cumhaz(	string scalar chvar,
					string scalar touse,
					numeric matrix knewnodes1,
					numeric matrix kweights1,
					real scalar nnodes1
					$matasyntax
					$coefficientmats
					$arraysyntax) 
{

	st_view(cumhaz=.,.,chvar,touse)
	cumhazard = J(rows(knewnodes1),1,0)

	for(j=1;j<=nnodes1;j++) {
		cumhazard = cumhazard :+ kweights1[,j]:*($mataloghazard21)
	}
	cumhaz[,]=cumhazard
}
end
