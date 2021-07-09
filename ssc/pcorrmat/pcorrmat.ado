capture program drop pcorrmat
program define pcorrmat, rclass byable(recall)
	*!1.1.0 MLB 13 Dec 2006 : added p-values
	*!1.0.0 MLB 26 Nov 2006 : originally posted on statalist
	version 8.2
	syntax varlist(min=2 ts) [if] [in] [aw fw], part(varlist ts) [SIG]
	marksample touse
	markout `touse' `part'
	local weight "[`weight'`exp']"
	local k : word count `varlist'
	tokenize `varlist'
	tempname partial pc t
	
	if "`sig'" == "" {
		matrix `partial' = J(`k',`k',1)
		forvalues i = 2/`k' {
			local end = `i' - 1
			forvalues j = 1/`end' {
				quietly regress ``i'' ``j'' `part' /* 
	                        */ if `touse' `weight'
				local NmK = e(df_r)
				quietly test ``j''
		                local s cond(_b[``j'']>0 , 1 , -1)
				matrix `partial'[`i',`j'] = /*
	                        */`s'*sqrt(r(F)/(r(F)+`NmK'))
				matrix `partial'[`j',`i'] =  /*
	                        */`s'*sqrt(r(F)/(r(F)+`NmK'))
			}
		}
		matrix rownames `partial' = `varlist'
		matrix colnames `partial' = `varlist'
	}

	else {
		local 2k = 2*`k'
		matrix `partial' = J(`2k',`k',.z)
		matrix `pc' = J(`k',`k',1)
		matrix `t' = J(`k',`k',.)

		forvalues i = 2/`k' {
			local end = `i' - 1
			forvalues j = 1/`end' {
				quietly regress ``i'' ``j'' `part' /* 
	                        */ if `touse' `weight'
				local NmK = e(df_r)
				quietly test ``j''
		                local s cond(_b[``j'']>0 , 1 , -1)
		                local rowcor = `i' + `i' - 1
		                local rowp = `i' + `i'
				matrix `partial'[`rowcor',`j'] = /*
	                        */`s'*sqrt(r(F)/(r(F)+`NmK'))
				matrix `partial'[`rowp',`j'] = /*
	                        */tprob(`NmK',sqrt(r(F)))
	                        
	                        matrix `pc'[`i',`j'] = /*
	                        */`s'*sqrt(r(F)/(r(F)+`NmK'))
				matrix `pc'[`j',`i'] =  /*
	                        */`s'*sqrt(r(F)/(r(F)+`NmK'))
	                        
	                        matrix `t'[`i',`j'] = /*
				*/sqrt(r(F))
				matrix `t'[`j',`i'] =  /*
	                        */sqrt(r(F))
			}
		}
		forvalues i = 1/`k'{
			local row = `i' + `i' - 1
			matrix `partial'[`row', `i'] = 1 
			local row = `i' + `i'
			matrix `partial'[`row',`i'] = 0
			local rownames "`rownames' ``i'' p"
		}
		
		matrix rownames `partial' = `rownames'
		matrix colnames `partial' = `varlist'
		matrix colnames `pc' = `varlist'
		matrix rownames `pc' = `varlist'
		matrix colnames `t' = `varlist'
		matrix rownames `t' = `varlist'
	}
	
	di as text "partial correlations controlled for " in yellow "`part'"
	matrix list `partial', noheader nodotz format(%9.3f)
	if "`sig'" == "" return matrix pcorr = `partial'
	else {
		return matrix pcorr = `pc'
		return matrix t = `t'
	}
	return scalar N = e(N)
	return scalar df = `NmK'
end
