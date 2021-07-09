/* 10.0 AMC 02mar2016 */

program strmst2pw

	version 10

	syntax varlist (max=2 min=1), [rmtl]
	
	* store saved output from strmst2
	local esttype rmtlratio rmstratio rmstdiff
	foreach e of local esttype {
		matrix `e'adj = r(`e'adj)
		matrix `e'cov = r(`e'cov)
		}
	
	* confirm that strmst2 was run previously with the covariates option
	if el(matrix(rmstdiffadj),1,1)==. {
		disp as error "error: in order for strmst2pw to run, strmst2 must be run previously with the covariations option "
		exit 198
		}
	
	
	* determine whether pairwise comparisons are with the reference category for the model
	if wordcount("`varlist'")==1 {
		local refcompare = 1
		}
	else {
		local refcompare = 0
		}
		
	* parse the varlist if pairwise comparisons are not with the reference category for the model
	if `refcompare'==0 {
		local var1 = word("`varlist'", 1)
		local var2 = word("`varlist'", 2)
		}

		
	* store values of the comparison categories
	if `refcompare'==1 {
		local cat0 = r(reference)
		local cat1 = substr("`varlist'", length("`varlist'"), 1)
		}
	if `refcompare'==0 {
		local cat0 = substr("`var2'", length("`var2'"), 1)
		local cat1 = substr("`var1'", length("`var1'"), 1)
		}

	
	* if pairwise comarisons are with respect to reference category from the model, take results directly from saved results
	if `refcompare'==1 {
		* difference of RMST
		local diffe  = el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`varlist'"), 1)
		local difflb = el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`varlist'"), 5)
		local diffub = el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`varlist'"), 6)
		local diffp  = el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`varlist'"), 4)
		* ratios of RMST and RMTL
		local esttype rmst rmtl
		foreach e of local esttype {
			local exp`e'e  = el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`varlist'"), 5)
			local exp`e'lb = el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`varlist'"), 6)
			local exp`e'ub = el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`varlist'"), 7)
			local `e'p  = el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`varlist'"), 4)
			}
		}
	
	* otherwise, calculate pairwise differences
	local zscore = invnorm(1 - (100-$level)/2/100)
	if `refcompare'==0 {
		* difference of RMST
		local diffe = el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`var1'"), 1) - ///
					  el(matrix(rmstdiffadj),rownumb(matrix(rmstdiffadj),"`var2'"), 1)
		local variance = el(matrix(rmstdiffcov),rownumb(matrix(rmstdiffcov),"`var1'"), rownumb(matrix(rmstdiffcov),"`var1'")) - 	///
						 2*el(matrix(rmstdiffcov),rownumb(matrix(rmstdiffcov),"`var1'"), rownumb(matrix(rmstdiffcov),"`var2'")) + 	///
						 el(matrix(rmstdiffcov),rownumb(matrix(rmstdiffcov),"`var2'"), rownumb(matrix(rmstdiffcov),"`var2'"))
		local stderr = sqrt(`variance')
		local difflb = `diffe' - `zscore'*`stderr'
		local diffub = `diffe' + `zscore'*`stderr'		
		local diffp =  chi2tail(1,(`diffe' / `stderr')^2)
		* ratios of RMST and RMTL
		local esttype rmst rmtl
		foreach e of local esttype {
			local `e'e = el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`var1'"), 1) - ///
						 el(matrix(`e'ratioadj),rownumb(matrix(`e'ratioadj),"`var2'"), 1)
			local variance = el(matrix(`e'ratiocov),rownumb(matrix(`e'ratiocov),"`var1'"), rownumb(matrix(`e'ratiocov),"`var1'")) - 	///
							 2*el(matrix(`e'ratiocov),rownumb(matrix(`e'ratiocov),"`var1'"), rownumb(matrix(`e'ratiocov),"`var2'")) + 	///
							 el(matrix(`e'ratiocov),rownumb(matrix(`e'ratiocov),"`var2'"), rownumb(matrix(`e'ratiocov),"`var2'"))
			local stderr = sqrt(`variance')
			local `e'p =  chi2tail(1,(``e'e' / `stderr')^2)
			local exp`e'e = exp(``e'e')
			local exp`e'lb = exp(``e'e' - `zscore'*`stderr')
			local exp`e'ub = exp(``e'e' + `zscore'*`stderr')	
			}
		}

			* header
			di _n in gr "Summary of between-group contrast (adjusted for the covariates)"
			di in smcl in gr "{hline 21}{c TT}{hline 43}" _n "        " _col(22) "{c |}" ///
							 _col(25) "Estimate" _col(37) "[$level% Conf. Interval]" _col(60) "P>|z|"
			di in smcl in gr "{hline 21}{c +}{hline 43}"
			* Difference of RMST
			di in smcl in gr %11s "RMST (arm `cat1' - arm `cat0')" " {c |}" in ye ///
					 _col(26) %7.3f `diffe'		 ///
					 _col(38) %7.3f `difflb'		///
					 _col(49) %7.3f `diffub'		///
					 _col(60) %5.3f `diffp'
			* Ratio of RMST
			di in smcl in gr %11s "RMST (arm `cat1' / arm `cat0')" " {c |}" in ye ///
					 _col(26) %7.3f `exprmste'		 ///
					 _col(38) %7.3f `exprmstlb'		///
					 _col(49) %7.3f `exprmstub'		///
					 _col(60) %5.3f `rmstp'
			
		if "`rmtl'"=="rmtl" {
			* Ratio of RMTL
			di in smcl in gr %11s "RMTL (arm `cat1' / arm `cat0')" " {c |}" in ye ///
					 _col(26) %7.3f `exprmtle'		 ///
					 _col(38) %7.3f `exprmtllb'		///
					 _col(49) %7.3f `exprmtlub'		///
					 _col(60) %5.3f `rmtlp'
			}

			* trailer
			di in smcl in gr "{hline 21}{c BT}{hline 43}" 
	
	

end
