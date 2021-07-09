// 1.0.1  JRF & AHF  01 FEB 2010
// Calculate Kendall's partial tau for an arbitrary number of confounders.

version 10.0
program define parttau, eclass sortpreserve

syntax varlist(numeric) [if] [in] [, CLuster(string) WCluster ///
			PC ESTimate(string) Level(cilevel) TRANSformation(string) ///
			SHOW Weight(string) RUN2 ]
marksample touse
	local vnum : word count `varlist'
			
	if `"`wcluster'"' == "" {
		local funtype = "bcluster"
	}
	else {
		local funtype = "wcluster"
	}
	if `"`transformation'"' == "" | `"`transformation'"' == "iden" {
		local transformation "identity"
		local transfText "None"
	}
	else if `"`transformation'"' == "sin" | `"`transformation'"' == "rho" {
		local transformation "rho"
		local transfText "Greiner's rho"
	}
	else if `"`transformation'"' == "arcsin" | `"`transformation'"' == "arsin" | `"`transformation'"' == "asin" {
		local transformation "asin"
		local transfText " Daniels' arcsine"
	}
	else if `"`transformation'"' == "z" {
		local transformation "z"
		local transfText "Fisher's z"
	}
	else if `"`transformation'"' == "zrho" {
		local transformation "zrho"
		local transfText "z-transform of Greiner's rho"
	}
	else if `"`transformation'"' == "c" {
		local transformation "c"
		local transfText "Harrell's c"
	}
	else {
		noi di ""
		noi di as error _column(4) "The given transformation does not match any of the offered transformations."
		noi di as error _column(4) "(Note that synonyms or truncations allowed in somersd might not be allowed here.)"
		exit
	}
		
	if `vnum' < 2 {
		noi di ""
		noi di _skip(4) as error "This command requires at least two variables."
		exit
	}
	else if `vnum' == 2 {
		local x : word 1 of `varlist'
		local y : word 2 of `varlist'
		qui replace `touse' = 0 if (`x' == . | `y' == . )
		qui count if `touse' == 1
		local N = r(N)
		
		capture somersd `x' `y' if `touse' != 0, taua level(`level') ///
					transf(`transformation') cluster(`cluster') funtype(`funtype')
		
		if _rc == 0 {			
			noi di ""
			noi di _skip(4) `"With just two variables, we'll run "somersd" with the "taua" option."'
			noi di ""
			
			somersd, level(`level')
		}
		else if `"`run2'"' != "" {
			local run2 = 1
		}
	}
	if `vnum' > 2 | `"`run2'"' != "" {
		unab variablelist : `varlist'
		tokenize `variablelist'

		qui count if `touse' == 1
		local N = r(N)

		local tistring ""
		local thetastring ""
		local numComps = comb(`vnum',2) + `vnum'
		forv i = 1(1)`numComps' {
			tempvar tiplus`i'
			qui gen `tiplus`i'' = .
			local tistring "`tistring'`tiplus`i'' "
			tempvar theta`i'
			qui gen `theta`i'' = .
			local thetastring "`thetastring'`theta`i'' "
		}
		if `"`cluster'"' == "" {
			tempvar clustertemp
			qui egen `clustertemp' = seq() if `touse'
			local nclusters = `N'
		}
		else {
			tempvar clustertemp
			qui egen `clustertemp' = group(`cluster') if `touse'
			qui summ `clustertemp'
			local nclusters = r(max)
		}
		sort `clustertemp'
		if `"`pc'"' == "" {
			local pc = 0
		}
		else {
			local pc = 1
		}
		if `"`estimate'"' == "" {
			tempvar estimate
			qui gen `estimate' = .
		}
		else {
			capture confirm variable `estimate'
			if _rc == 0 {
				noi di `"Note: the variable "`estimate'" already exists and is being replaced."'
			}
			else {
				qui gen `estimate' = .
			}
			qui replace `estimate' = .
			local estimate = "`estimate'"
		}
		if `"`level'"' != "" {
			local hival = 0.5 + `level' / 200
			local cifactor = invnormal(`hival')
		}
		else {
			local cifactor = 1.96
		}
		if `"`weight'"' == "" {
			tempvar weight
			qui gen `weight' = 1
			local weight "`weight'"
		}
		else {
			capture confirm numeric variable `weight'
			if _rc != 0 {
				noi di "{error}The given weight variable does not exist or is not numeric."
				exit
			}
			qui summ `weight'
			if r(min) < 0 {
				noi di "{error}Weights must be nonnegative."
			}
		}
		tempvar viplus
		qui gen `viplus' = .
		
		tempname pointEsts
		
		mata: main(`pc', "`clustertemp'", "`funtype'", `vnum', "`thetastring'", "`variablelist'", ///
					"`tistring'", "`viplus'", "`estimate'", "`weight'", "`transformation'", `cifactor', ///
					"`pointEsts'", "`touse'")

		matrix Sigma = J(`vnum',`vnum',.)
		local counter = 0
		forv i = 1(1)`vnum' {
			forv j = `i'(1)`vnum' {
				local counter = `counter' + 1
				matrix Sigma[`i',`j'] = taus[1,`counter']
				matrix Sigma[`j',`i'] = taus[1,`counter']
			}
		}
		matrix drop taus
			
		tempname primaryvars confounders
		local `primaryvars' = word("`variablelist'",1) + " " + word("`variablelist'",2)
		local `confounders' ""
		forv i=3(1)`vnum' {
			local `confounders' = "``confounders'' " + word("`variablelist'",`i')
		}
		
		noi di ""
		noi di "{text}Primary variables: {result}``primaryvars''"
		noi di "{text}Confounders: {result}``confounders''"
		noi di "{text}Transformation: {result}`transfText'"
		noi di "{text}No. of obs.: {result}`N'"
		if `"`cluster'"' != "" {
			noi di "{text}No. of clusters: {result}`nclusters'"
		}
		noi di ""
		
		if `"`show'"' != "" {
			noi di "{text}Pairwise taus:"
			noi di "{text}{hline 48}"
			noi di "{text}{col 3}#{col 10}Name{col 40}Estimate"
			noi di "{text}{hline 48}"
			forv i = 1(1)`vnum' {
				local name1 = word("`variablelist'",`i')
				local length1 = length("`name1'")
				local dilen1 = min(`length1' + 2,8)
				local name1 = substr("`name1'",1,`dilen1')
				forv j = `i'(1)`vnum' {
					local name2 = word("`variablelist'",`j')
					local length2 = length("`name2'")
					local dilen2 = min(`length2' + 2,8)
					local name2 = substr("`name2'",1,`dilen2')
					noi di "{text}{col 2}`i',`j'{col 10}tau( " ///
							%`dilen1's "`name1', " %`dilen2's "`name2' )" ///
							_column(39) %10.7f as result Sigma[`i',`j']
				}
			}
			noi di "{text}{hline 48}"
			noi di ""
			noi di "{text}Partial tau:"
		}
				
		local rows = rowsof(`pointEsts')
		
		noi di "{text}{hline 13}{c TT}{hline 67}"
		noi di "{col 14}{text}{c |}{text}{col 31}Jackknife"
		noi di "{text}Interval:{col 14}{text}{c |}{col 22}Coef.{col 31}Std. Err.{col 46}z{col 52}P>|z|{col 62}[95% Conf. Interval]"
		noi di "{text}{hline 13}{c +}{hline 67}"
		noi di "{text}   symmetric{col 14}{text}{c |}{col 17}{result}" %10.7f `pointEsts'[1,1] _column(30) %10.7f `pointEsts'[1,2]  ///
				_column(43) %5.2f `pointEsts'[1,1]/`pointEsts'[1,2] ///
				_column(52) %5.3f 2 * (1 - normal(abs(`pointEsts'[1,1]/`pointEsts'[1,2]))) ///
				_column(61) %8.6f `pointEsts'[1,3] "    " %8.6f `pointEsts'[1,4]
		if "`transformation'" != "identity" & "`transformation'" != "rho"  & `"`transformation'"' != "c" {
			noi di "{text}  asymmetric{col 14}{text}{c |}{col 17}{result}" %10.7f `pointEsts'[2,1] as result ///
						_column(61) %8.6f `pointEsts'[2,3] "    " %8.6f `pointEsts'[2,4]
		}
		noi di "{text}{hline 13}{c BT}{hline 67}"
		if `"`transformation'"' != "identity" {
			noi di ""
			if "`transformation'" == "rho" | "`transformation'" == "c" {
				noi di as text "Results for partial tau are in the transformed space."
			}
			else if "`transformation'" == "zrho" {
				noi di as text "1st line is in the transformed, zrho, space."
				noi di as text "2nd line is in the space of rho.
			}
			else {
				noi di as text "1st line is in the transformed space."
				noi di as text "2nd line is in the original space.
			}
		}
		noi di ""
		
		tempname colnames colsofb
		local `colnames' "tau"
		
		matrix V = (`pointEsts'[1,2]^2)
		matrix colnames V = "``colnames''"
		matrix rownames V = "``colnames''"
		matrix colnames b = "``colnames''"
		
		matrix rownames Sigma = `varlist'
		matrix colnames Sigma = `varlist'
		
		ereturn post b V, esample(`touse')
		ereturn matrix taus = Sigma
		
		ereturn scalar SE = `pointEsts'[1,2]
		ereturn scalar N = `N'
		ereturn scalar N_clust = `nclusters'
		
		ereturn local cluster_type = `"`funtype'"'
		ereturn local primaryvars = "``primaryvars''"
		ereturn local confounders = "``confounders''"
		ereturn local vcetype = "Jackknife"
		ereturn local transf = "`transformation'"
		ereturn local cmd = "npt"
	}
end

mata:
	void main(real scalar pc, string scalar clusterv, string scalar funtype, ///
				real scalar nvars, string scalar thetas, string scalar varnames, ///
				string scalar tipluses, string scalar viplusv, string scalar estimatev, ///
				string scalar weightv, string scalar transformation, real scalar cifactor, ///
				string scalar matname, string scalar tousev) 
	{
		st_view(cluster, ., clusterv, tousev)
		clpanel = panelsetup(cluster, 1)
		clstats = panelstats(clpanel)
		
		st_view(V, ., tokens(varnames), tousev)
		st_view(Ti, ., tokens(tipluses), tousev)
		st_view(Th, ., tokens(thetas), tousev)
		st_view(estimate, ., estimatev, tousev)
		st_view(weight, ., weightv, tousev)
		st_view(viplus, ., viplusv, tousev)
		
		numComps = comb(nvars,2) + nvars
		
		taus = J(1,numComps,.)
		
		viplus[.] = makeweight(weight)
		
		allphis = J(clstats[1],2 * (numComps + 1), .)
		
		counter = 0		
		for (i1 = 1; i1 <= nvars; i1++) {
			for (i2 = i1; i2 <= nvars; i2++) {
				counter = counter + 1
				st_subview(x, V, ., i1)
				st_subview(y, V, ., i2)
				st_subview(tiplus, Ti, ., counter)
				st_subview(thetaj, Th, ., counter)
				
				tiplus[.] = maketiplus(x, y)
				phis = makephi(cluster, tiplus, x, y, viplus, weight)
				if (nvars == 2) {
					colOne = 2 * counter - 1
					colTwo = 2 * counter
					allphis[., colOne::colTwo] = phis[.,1::2]
				}
				if (funtype == "bcluster") {
					taus[counter] = (colsum(phis[.,1]) - colsum(phis[.,2])) / (colsum(phis[.,3]) - colsum(phis[.,4]))
				}
				else if (funtype == "wcluster") {
					taus[counter] = colsum(phis[.,2]) / colsum(phis[.,4])
				}
				if (i1 == i2 & pc == 1) {
					for (i3 = 1; i3 <= clstats[1]; i3++) {
						thetaj[i3] = 1
					}
				}
				else {
					thetaj[1..clstats[1]] = makethetaj(phis, funtype)
				}
			}
		}
		st_matrix("taus",taus)
		if (nvars == 2) {
			allphis[.,7::8] = phis[.,3::4]
			influence = makeInfluence(allphis, funtype)
			dispersion = makeDispersion(influence, allphis, clstats[1], funtype, transformation)
			st_matrix("disp",dispersion)
			results = makeResults2by2(dispersion, taus, cifactor, transformation)
		}
		else {
			estimate[.] = makeSigma(Th, nvars)
			overallEst = makeSigma(taus, nvars)
			results = makeResults(overallEst, estimate, cifactor, transformation)
		}
		st_matrix(matname, results)
	}
	
	real colvector makeweight(real colvector weight)
	{
		nobs = rows(weight)

		viplus = J(nobs,1,.)
		for (i1 = 1; i1 <= nobs; i1++) {
			viplus[i1] = 0
			for (i2 = 1; i2 < i1; i2++) {
				viplus[i1] = viplus[i1] + 1
				viplus[i2] = viplus[i2] + 1
			}
		}
		return(viplus)
	}
	
	real colvector maketiplus(real colvector x, real colvector y)
	{
		nobs = rows(x)
		
		tiplus = J(nobs,1,.)
		for (i1 = 1; i1 <= nobs; i1++) {
			tiplus[i1] = 0
			x1 = x[i1]
			y1 = y[i1]
			for (i2 = 1; i2 < i1; i2++) {
				x2 = x[i2]
				y2 = y[i2]
				xsign = (x1 < x2) - (x2 < x1)
				ysign = (y1 < y2) - (y2 < y1)
				tiplus[i1] = tiplus[i1] + xsign * ysign
				tiplus[i2] = tiplus[i2] + xsign * ysign
			}
		}
		return(tiplus)
	}
	
	real matrix makephi(real colvector cluster, real colvector tiplus, ///
						real colvector x, real colvector y, ///
						real colvector viplus, real colvector weight)
	{
		clpanel = panelsetup(cluster, 1)
		clstats = panelstats(clpanel)
				
		phikk = J(clstats[1],1,.)
		phijplus = J(clstats[1],1,.)
		
		phiVkk = J(clstats[1],1,.)
		phiVjplus = J(clstats[1],1,.)
		
		phis = J(clstats[1],4,.)
				
		for (i1 = 1; i1 <= clstats[1]; i1++) {
			cl_tiplus = tiplus[clpanel[i1,1]..clpanel[i1,2]]
			cl_viplus = viplus[clpanel[i1,1]..clpanel[i1,2]]
			phijplus[i1] = colsum(cl_tiplus[.])
			phiVjplus[i1] = colsum(cl_viplus[.])
			
			cl_x = x[clpanel[i1,1]..clpanel[i1,2]]
			cl_y = y[clpanel[i1,1]..clpanel[i1,2]]
			wcl_tiplus = J(rows(cl_x), 1, .)
			wcl_tiplus[.] = maketiplus(cl_x, cl_y)
			
			cl_weight = weight[clpanel[i1,1]..clpanel[i1,2]]
			wcl_viplus = J(rows(cl_weight), 1, .)
			wcl_viplus[.] = makeweight(cl_weight)
			
			phikk[i1] = colsum(wcl_tiplus[.])
			phiVkk[i1] = colsum(wcl_viplus[.])
		}
		
		phis[.,1] = phijplus[.]
		phis[.,2] = phikk[.]
		phis[.,3] = phiVjplus[.]
		phis[.,4] = phiVkk[.]
				
		return(phis)
	}
	
	real colvector makethetaj(real matrix phis, string scalar funtype)
	{
		phikk = phis[.,2]
		phiVkk = phis[.,4]
		
		phikksum = colsum(phikk[.])
		phiVkksum = colsum(phiVkk[.])
		
		thetaj = J(rows(phis),1,.)
		if (funtype == "bcluster") {
			phijplus = phis[.,1]
			phiVjplus = phis[.,3]
			phiplusplus = colsum(phijplus[.])
			phiVplusplus = colsum(phiVjplus[.])
			for (i1 = 1; i1 <= rows(phis); i1++) {
				thetajNumer = (phiplusplus - phikksum) - 2 * (phijplus[i1] - phikk[i1])
				thetajDenom = (phiVplusplus - phiVkksum) - 2 * (phiVjplus[i1] - phiVkk[i1])
				thetaj[i1] = thetajNumer / thetajDenom
			}
		}
		else if (funtype == "wcluster") {
			for (i1 = 1; i1 <= rows(phis); i1++) {
				thetajNumer = (phikksum - phikk[i1])
				thetajDenom = (phiVkksum - phiVkk[i1]) 
				thetaj[i1] = thetajNumer / thetajDenom
			}
		}
		return(thetaj)
	}
	
	real colvector makeSigma(real matrix Th, real scalar nvars)
	{
		Sigma = J(nvars, nvars, .)
		estimate = J(rows(Th),1,.)

		for (i1 = 1; i1 <= rows(Th); i1++) {
			counter = 0
			for (i2 = 1; i2 <= nvars; i2++) {
				for (i3 = i2; i3 <= nvars; i3++) {
					counter = counter + 1
					Sigma[i2,i3] = Th[i1,counter]
					Sigma[i3,i2] = Th[i1,counter]
				}
			}
			if (nvars > 2) {
				Sigma11 = Sigma[1..2,1::2]
				Sigma12 = Sigma[1..2,3::nvars]
				Sigma21 = Sigma[3..nvars,1::2]
				Sigma22 = Sigma[3..nvars,3::nvars]
				invSigma22 = invsym(Sigma22)
				
				Sigma_11dot2 = Sigma11 - Sigma12 * invSigma22 * Sigma21
				estimate[i1] = Sigma_11dot2[1,2] / sqrt(Sigma_11dot2[1,1] * Sigma_11dot2[2,2])
			}
			else {
				estimate[i1] = Sigma[1,2]
			}
		}
		return(estimate)
	}
	
	real matrix makeInfluence(real matrix allPhis, string scalar funtype)
	{
		nrows = rows(allPhis)
		ncols = cols(allPhis)
		
		phiVkk = allPhis[., ncols]
		phiXkk = allPhis[., 2]
		phiYkk = allPhis[., 4]
		
		psiV = J(nrows,1,.)
		psiX = J(nrows,1,.)
		psiY = J(nrows,1,.)
		
		if (funtype == "bcluster") {
			phiVjplus = allPhis[., ncols - 1]
			phiVplusplus = colsum(allPhis[., ncols - 1])
			phiVkksum = colsum(allPhis[., ncols])
			phiXjplus = allPhis[., 1]
			phiXplusplus = colsum(allPhis[., 1])
			phiXkksum = colsum(allPhis[., 2])
			phiYjplus = allPhis[., 3]
			phiYplusplus = colsum(allPhis[., 3])
			phiYkksum = colsum(allPhis[., 4])
			for (i1 = 1; i1 <= nrows; i1++) {
				psiV[i1] = (phiVplusplus - phiVkksum) / (nrows - 1) ///
							- ((phiVplusplus - phiVkksum) - 2 * (phiVjplus[i1] - phiVkk[i1])) / (nrows - 2)
				psiX[i1] = (phiXplusplus - phiXkksum) / (nrows - 1) ///
							- ((phiXplusplus - phiXkksum) - 2 * (phiXjplus[i1] - phiXkk[i1])) / (nrows - 2)
				psiY[i1] = (phiYplusplus - phiYkksum) / (nrows - 1) ///
							- ((phiYplusplus - phiYkksum) - 2 * (phiYjplus[i1] - phiYkk[i1])) / (nrows - 2)
			}
		}
		if (funtype == "wcluster") {
			for (i1 = 1; i1 <= nrows; i1++) {
				psiV[i1] = phiVkk[i1]
				psiX[i1] = phiXkk[i1]
				psiY[i1] = phiYkk[i1]
			}
		}
		
		influence = J(nrows,3,.)
		influence[.,1] = psiV :- (colsum(psiV[.]) / nrows)
		influence[.,2] = psiX :- (colsum(psiX[.]) / nrows)
		influence[.,3] = psiY :- (colsum(psiY[.]) / nrows)
		
		return(influence)
	}
	
	real matrix makeDispersion(real matrix influence, real matrix allPhis, real scalar n_cl, ///
							   string scalar funtype, string scalar transformation)
	{
		if (funtype == "bcluster") {
			Txx = (colsum(allPhis[.,1]) - colsum(allPhis[.,2])) / (n_cl * (n_cl - 1))
			Txy = (colsum(allPhis[.,3]) - colsum(allPhis[.,4])) / (n_cl * (n_cl - 1))
			V = (colsum(allPhis[.,7]) - colsum(allPhis[.,8])) / (n_cl * (n_cl - 1))
		}
		if (funtype == "wcluster") {
			Txx = colsum(allPhis[.,2]) / n_cl
			Txy = colsum(allPhis[.,4]) / n_cl
			V = colsum(allPhis[.,8]) / n_cl
		}
		derivs = (- Txx / (V ^ 2), 1 / V, 0      \  ///
				  - Txy / (V ^ 2), 0    , 1 / V)
		dispersion = derivs * influence' * influence * derivs' / (n_cl * (n_cl - 1))
		
		return(dispersion)
	}
	
	real matrix makeResults2by2(real matrix dispersion, real matrix taus, ///
									real scalar cifactor, string scalar transformation)
	{
		tausApprox = J(1,cols(taus),.)
		for (i = 1; i <= cols(taus); i++) {
			if (taus[i] == 1) {
				tausApprox[i] = 0.999999
			}
			else if (taus[i] == -1) {
				tausApprox[i] = -0.999999
			}
			else {
				tausApprox[i] = taus[i]
			}
		}
		
		if (transformation == "identity") {
			zeta = tausApprox[2]
			lopt = zeta - cifactor * sqrt(dispersion[2,2])
			hipt = zeta + cifactor * sqrt(dispersion[2,2])
			returnMat = (zeta, sqrt(dispersion[2,2]), lopt, hipt)
		}
		else if (transformation == "z") {
			transDerivs = (1 / (1 - tausApprox[1]^2) , 0  \  ///
						   0, 1 / (1 - tausApprox[2]^2))
			transDispersion = transDerivs * dispersion * transDerivs
			zeta = atanh(tausApprox[2])
			slopt = zeta - cifactor * sqrt(transDispersion[2,2])
			shipt = zeta + cifactor * sqrt(transDispersion[2,2])
			alopt = tanh(zeta - cifactor * sqrt(transDispersion[2,2]))
			ahipt = tanh(zeta + cifactor * sqrt(transDispersion[2,2]))
			returnMat = (zeta, sqrt(transDispersion[2,2]), slopt, shipt \
						 taus[2], 						., alopt, ahipt)
		}
		else if (transformation == "asin") {
			transDerivs = (1 / ((1 - tausApprox[1]^2)^(1/2)), 0  \  ///
						   0, 1 / ((1 - tausApprox[2]^2)^(1/2)))
			transDispersion = transDerivs * dispersion * transDerivs
			zeta = asin(tausApprox[2])
			slopt = zeta - cifactor * sqrt(transDispersion[2,2])
			shipt = zeta + cifactor * sqrt(transDispersion[2,2])
			alopt = sin(zeta - cifactor * sqrt(transDispersion[2,2]))
			ahipt = sin(zeta + cifactor * sqrt(transDispersion[2,2]))
			returnMat = (zeta, sqrt(transDispersion[2,2]), slopt, shipt \
						 taus[2], 						., alopt, ahipt)
		}
		else if (transformation == "rho") {
			transDerivs = (pi() / 2 * cos(pi() * tausApprox[1] / 2), 0   \  ///
						   0, pi() / 2 * cos(pi() * tausApprox[2] / 2))
			transDispersion = transDerivs * dispersion * transDerivs
			zeta = sin(pi() / 2 * tausApprox[2])
			slopt = zeta - cifactor * sqrt(transDispersion[2,2])
			shipt = zeta + cifactor * sqrt(transDispersion[2,2])
			returnMat = (zeta, sqrt(transDispersion[2,2]), slopt, shipt)
		}
		else if (transformation == "zrho") {
			transDerivs = ( pi() / 2 * cos(pi() * tausApprox[1] / 2) / (1 - sin(pi() * tausApprox[1] / 2)^2), 0  \  ///
							0, pi() / 2 * cos(pi() * tausApprox[2] / 2) / (1 - sin(pi() * tausApprox[2] / 2 )^2))
			transDispersion = transDerivs * dispersion * transDerivs
			zeta = atanh(sin(pi() / 2 * tausApprox[2]))
			slopt = zeta - cifactor * sqrt(transDispersion[2,2])
			shipt = zeta + cifactor * sqrt(transDispersion[2,2])
			rho = sin(pi() / 2 * tausApprox[2])
			alopt = tanh(zeta - cifactor * sqrt(transDispersion[2,2]))
			ahipt = tanh(zeta + cifactor * sqrt(transDispersion[2,2]))
			returnMat = (zeta, sqrt(transDispersion[2,2]), slopt, shipt \ rho, ., alopt, ahipt)
		}
		else if (transformation == "c") {
			transDerivs = ( 1/2, 0  \  ///
							0, 1/2)
			transDispersion = transDerivs * dispersion * transDerivs
			zeta = (tausApprox[2] + 1) / 2
			slopt = zeta - cifactor * sqrt(transDispersion[2,2])
			shipt = zeta + cifactor * sqrt(transDispersion[2,2])
			returnMat = (zeta, sqrt(transDispersion[2,2]), slopt, shipt)
		}
		st_matrix("b",(zeta))
		return(returnMat)
	}
	
	real matrix makeResults(real scalar overallEst, real colvector estimate, ///
									real scalar cifactor, string scalar transformation)
	{
		if (abs(overallEst) - 1 <= 1e-6) {
			approxTau = 0.999999 * overallEst
		}
		numEsts = rows(estimate) - missing(estimate)
		jkEstimates =  (estimate :* (1 - numEsts)) :+ (numEsts * overallEst)
		jkVar = variance(jkEstimates) / numEsts
		if (transformation == "identity") {
			zeta = overallEst
			zetaVec = jkEstimates
			SE = sqrt(jkVar * 1)
			lopt = zeta - cifactor * SE
			hipt = zeta + cifactor * SE
			returnMat = (zeta, SE, lopt, hipt)
		}
		else if (transformation == "z") {
			zeta = atanh(overallEst)
			zetaVec = atanh(jkEstimates)
			SE = sqrt(jkVar * 1 / (1 - approxTau^2)^2)
			slopt = zeta - cifactor * SE
			shipt = zeta + cifactor * SE
			alopt = tanh(zeta - cifactor * SE)
			ahipt = tanh(zeta + cifactor * SE)
			returnMat = (zeta, SE, slopt, shipt \
						 overallEst, ., alopt, ahipt)
		}
		else if (transformation == "asin") {
			zeta = asin(overallEst)
			zetaVec = asin(jkEstimates)
			SE = sqrt(jkVar * 1 / (1 - approxTau^2))
			slopt = zeta - cifactor * SE
			shipt = zeta + cifactor * SE
			alopt = sin(zeta - cifactor * SE)
			ahipt = sin(zeta + cifactor * SE)
			returnMat = (zeta, SE, slopt, shipt \
						 overallEst, ., alopt, ahipt)
		}
		else if (transformation == "rho") {
			zeta = sin(overallEst * pi() / 2)
			zetaVec = sin(jkEstimates :* pi() / 2)
			SE = sqrt(jkVar * (pi() / 2 * cos(pi() / 2 * approxTau))^2)
			slopt = zeta - cifactor * SE
			shipt = zeta + cifactor * SE
			returnMat = (zeta, SE, slopt, shipt)
		}
		else if (transformation == "zrho") {
			zeta = atanh(sin(overallEst * pi() / 2))
			zetaVec = atanh(sin(jkEstimates :* pi() / 2))
			SE = sqrt(jkVar * (pi() / 2 * cos(pi() / 2 * approxTau) / (1 - (sin(pi() / 2 * approxTau))^2))^2)
			slopt = zeta - cifactor * SE
			shipt = zeta + cifactor * SE
			rho = sin(overallEst * pi() / 2)
			alopt = tanh(zeta - cifactor * SE)
			ahipt = tanh(zeta + cifactor * SE)
			returnMat = (zeta, SE, slopt, shipt \ rho, ., alopt, ahipt)
		}
		else if (transformation == "c") {
			zeta = (overallEst + 1) / 2
			zetaVec = (jkEstimates :+ 1) :/ 2
			SE = sqrt(jkVar / 4)
			slopt = zeta - cifactor * SE
			shipt = zeta + cifactor * SE
			returnMat = (zeta, SE, slopt, shipt)
		}
		st_matrix("b",(zeta))
		return(returnMat)
	}
end
