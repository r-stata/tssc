// Hong Il Yoo (h.i.yoo@durham.ac.uk): 17/02/2020.
// Two-Way Clustered Standard Errors
// v1.0.2
// v1.0.1
program define vce2way, eclass 
	version 13.1
	syntax anything(id="command line" name=command_line) [if] [in] [fweight  aweight  pweight  iweight], CLuster(varlist min=2 max=2) [*]  
	// Define temporary objects
	tempname break b1 b2 b12 V1 V2 V12 V_2way V_2way_raw 
	tempvar cluster12
	
	// Split 2 varnames in `cluster' into `cluster1' and `cluster2'
	local cluster1: word 1 of `cluster'
	local cluster2: word 2 of `cluster'

	// Mark sample
	marksample touse
	markout `touse' `cluster', strok
	
	// Set up weight options
	if ("`weight'" != "") local weight [`weight' `exp']		
	
	quietly {
		// Step 1: cluster at `cluster1' and store covariance matrix
		`command_line' `weight' if `touse' `in', vce(cluster `cluster1') `options'
		matrix `b1' = e(b)
		matrix `V1' = e(V)
		local N_clust1 = e(N_clust)

		// Step 2: cluster at `cluster2' and store covariance matrix
		`command_line' `weight' if `touse' `in', vce(cluster `cluster2') `options'
		matrix `b2' = e(b)
		matrix `V2' = e(V)
		local N_clust2 = e(N_clust)
		
		// Step 3: cluster at intersection of `cluster1' & `cluster2' and store covariance matrix
		egen `cluster12' = group(`cluster1' `cluster2')
		`command_line' `weight' if `touse' `in', vce(cluster `cluster12') `options'
		matrix `b12' = e(b)
		matrix `V12' = e(V)		
		
		// Step 4: compute the two-way clustered covariance matrix 
		matrix `V_2way' = `V1' + `V2' - `V12'   
		
		// Step 5: check if all three coefficient vectors are the same; if not, break with error
		scalar `break' = max(mreldif(`b1', `b2'), mreldif(`b2', `b12'), mreldif(`b1', `b12'))
		if (`break' > 1e-4) {
			// NOTE: leave some margin of very small non-zero differences 
			di as red "One-way clustering in `cluster1', `cluster2' and their intersection results in different coefficient vectors."
			error 498
		}
		
		// Step 6. check V_2way is p.s.d.; if not, replace eigenvalues with zeroes and resconstruct
		mata {
			V_2way = st_matrix(st_local("V_2way"))
			symeigensystem(V_2way, EVEC = ., eval = .)
			if (min(eval) < 0) {
				eval = eval :* (eval :> 0) 
				st_matrix(st_local("V_2way_raw"), V_2way)
				st_matrix(st_local("V_2way"), EVEC*diag(eval)*EVEC')
				st_local("replace","yes")	
			}
		}
		
		// Final Step: add extra items to ereturn list and post two-way clustered covariance matrix
		ereturn local vce2way "yes"
		ereturn local clustvar "`cluster1' and `cluster2'"
		ereturn local clustvar1 "`cluster1'"
		ereturn local clustvar2 "`cluster2'"
		//ereturn local N_clust "`N_clust1' clusters in `cluster1' and `N_clust2' clusters in `cluster2'"   
		if (`=int(c(stata_version))' > 15) ereturn local N_clust = .
		else ereturn local N_clust "N_clust'i' reports the number of clusters in clustvar'i'"
		
		ereturn scalar N_clust1 = `N_clust1'
		ereturn scalar N_clust2 = `N_clust2'
		if ("`e(F)'" != "") ereturn scalar F = .
		if ("`e(chi2)'" != "") ereturn scalar chi2 = . 
		if ("`e(p)'" != "") ereturn scalar p = .		
		
		if ("`replace'" == "yes") ereturn matrix V_raw = `V_2way_raw'
		ereturn repost V=`V_2way' 
	} 
	
	// Display estimation results with two-way clustered standard errors
	if ("`e(cmd)'" != "") `e(cmd)'
	else estimates replay
	
	// Display any notes
	di as text "Notes:"
	di as text " 	As of June 2019, vce2way has been superseded by " as smcl `"{bf:{stata findit vcemway:vcemway}}"' as text "."
	di as text ""
	di as text "	Std. Err. adjusted for " as result `e(N_clust1)' as text " clusters in `e(clustvar1)', AND " ///
	   as result `e(N_clust2)' as text " clusters in `e(clustvar2)'."
	di as text ""
	di as text "	Ignore default Wald chi2(.) and Prob > chi2, or F(.,.) and Prob > F, results above."   
	di as text "	  If needed, use command -test- to compute the test statistic and p-value of interest."		
	if ("`replace'" == "yes") {
		di as text ""
		di as text "	The initial variance-covariance matrix, " as result "e(V_raw)" as text ", was not positive semi-definite." 
		di as text "	  The final matrix, " as result "e(V)" as text ", was computed by replacing negative eigenvalues with 0s."
	}
end 

exit
