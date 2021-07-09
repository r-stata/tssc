pr st2openbugsana, rclass
	vers 13
	
	syntax varlist ///
	[	, ///
		Thin(integer 1) ///
		Grbplot ///
		Nbins(integer 10) ///
		Savegraphs ///
		Wdpath(string) ///
		Prefix(string) ///
	]
	tempvar thinind
	if `thin' == 1 gen `thinind' =  1
	else gen `thinind' = mod(iteration, `thin')
	// deviance node not implicitly included
	tokenize `varlist'
	loc nvar: word count `varlist'
	qui su iteration
	loc iter1 = r(min)
	loc niter = r(max) - `iter1' + 1
	qui su chain
	loc nchains = r(max)
	if "`grbplot'" != "" & `nchains' == 1 di as err "Warning: the {it:grbplot} option doesn't make sense with only one chain"
	if "`grbplot'" != "" & `nchains' > 1 & mod(`niter', `nbins') != 0  { 
		di as err "Warning: the {it:nupdate} argument of {bf:stopenbugs} must be a multiple of {it:nbins}; {it:nbins} is reset to its default"
		loc nbins = 10
	}
	if "`wdpath'" == "" loc wdpath = "~"
	if "`prefix'" == "" di as err "Warning: you are using a log file whose name has no prefix; if the {it:CODA.dta} file does have one, this is probably an error"
	loc logfile = "`prefix'log.log"
	matrix pctiles = J(`nvar', 3, .)
	forv i = 1/`nvar' { 
		_pctile ``i'', p(2.5 50 97.5)
		matrix pctiles[`i', 1] = (r(r1), r(r2), r(r3))
	}
	mata: st2openbugsanamata("`varlist'", `nvar', `niter', `iter1', `nchains', "`grbplot'", "`nbins'", "`wdpath'", "`logfile'")
	// trace and density plots
	if "`grbplot'" != "" & `nchains' > 1 { 
		preserve
		matname GRBmatplot "node" "nstart" "CSRF", c(.) e
		svmat GRBmatplot, names(col)
		ret mat GRBmatplot GRBmatplot
	}
	forv i = 1/`nvar' { 
		loc lineplot line ``i'' iteration if chain==1 & `thinind'==1
		forv chain = 2/`nchains' {
			loc lineplot `lineplot' || line ``i'' iteration if chain==`chain' & `thinind'==1
		}		
		loc lower = pctiles[`i', 1]
		loc median = pctiles[`i', 2]
		loc upper = pctiles[`i', 3]
		loc lineplot `lineplot', nodraw yti(``i'') ylab(, nogrid) yli(`lower' `median' `upper', lsty(grid)) xtitle("iteration (thinning: `thin')") leg(off) name(line``i'', replace) 
		`lineplot'
		tw kdensity ``i'', xti(``i'') yti("density") nodraw name(dens``i'', replace)
		if "`savegraphs'" != "" {
			gr combine line``i'' dens``i'', cols(1) saving("`wdpath'/`prefix'``i''_trace.gph", replace) name(trace_``i'', replace)
			if "`grbplot'" != "" & `nchains' > 1 line CSRF nstart if node==`i', lp(solid dash) ti("``i''") xti("Starting iteration") yti("CSRF") ///
						leg(off) saving("`wdpath'/`prefix'``i''_GRB.gph", replace) name(GRB_``i'', replace)
		}
		else {
			gr combine line``i'' dens``i'', cols(1) name(trace_``i'', replace)
			if "`grbplot'" != "" & `nchains' > 1 line CSRF nstart if node==`i', lp(solid dash) ti("``i''") xti("Starting iteration") yti("CSRF") ///
						leg(off) name(GRB_``i'', replace)
		}
	}
	if "`grbplot'" != "" & `nchains' > 1 restore
	// saved results
	if `isDIC' {
		matname DIC "Dbar" "DIC" "pD", c(.) e
		ret mat DIC DIC
	}
	if `nchains' == 1 matname summarymat "mean" "sd" "MC_error" "2dot5%" "median" "97dot5%", c(.) e
	else matname summarymat "mean" "sd" "MC_error" "2dot5%" "median" "97dot5%" "CSRF", c(.) e
	ret mat summarymat summarymat
	ret sca niteration = `niter'
	ret sca nburnin = `iter1' - 1
	ret sca nchain = `nchains'
	ret loc varlist `varlist'
end

version 13
mata:

function st2openbugsanamata(varlist, nvar, niter, iter1, m, grbplot, nbin, wdpath, logfile) {
// GRB saves the value of the Gelman-Rubin diagnostic computed with all the iterations
	if (m > 1) GRB = GelmanRubinBrooks(varlist, nvar, niter/2, niter, niter, m)
	pctiles = st_matrix("pctiles")
	summary(varlist, nvar, niter, iter1, m, pctiles, GRB, wdpath, logfile)
	if (grbplot != "" & m > 1) GelmanRubinBrooksplot(varlist, nvar, niter, iter1, m, strtoreal(nbin))
}

function GelmanRubinBrooks(varlist, nvar, nstart, nend, niter, m) {	
	grb = J(nvar, 1, .)
	indices = vec(niter :* (0..(m-1)) :+ J(1, m, nstart::nend))
	n = nend - nstart + 1
	X = st_data(indices, varlist)
	grand_mean = mean(X)
	chain_mean = J(m, nvar, .)
	matrix_chain_mean = J(m * n, nvar, .)
	W_chain = J(m, nvar, .)
	for (j = 1; j <= nvar; j++) {
		for (i = 1; i <= m; i++) {
			temp1 = X[((n * (i-1) + 1)::(n * i)), j]
			chain_mean[i, j] = mean(temp1)
			temp2 = J(n, 1, chain_mean[i, j])
			matrix_chain_mean[((n*(i-1)+1)::(n*i)), j] = temp2
			W_chain[i, j] = sum((temp1 :- temp2):^2) / (n-1)
		}
	}
	B = colsum((chain_mean :- grand_mean):^2) :* n :/ (m-1)
	var_B = 2 :* B:^2 :/ (m - 1)
	df_B = m - 1
	W = mean(W_chain)
	var_W = colsum((W_chain :- W):^2) :/ (m-1)
	df_W = 2 :* W:^2 :/ var_W 
	cov_BW =  (n / m / (m -1)) :* (colsum((W_chain :- W) :* (chain_mean:^2 :- mean(chain_mean:^2))) :- 2 :* grand_mean :* colsum((W_chain :- W) :* (chain_mean :- grand_mean)))
	V = ((n-1) / n) :* W :+ ((m + 1) / m / n) :* B 
	var_V = (((m + 1) / m)^2 :* var_B :+ (n - 1)^2 :* var_W :+ (2*(m + 1) / m * (n - 1)) :* cov_BW):/ n^2
	df_V = 2 :* V:^2 :/ var_V
	R = V :/ W
	df_adj = (df_V :+ 3) :/ (df_V :+ 1)
	return(vec(sqrt(df_adj :* R)))
}

function summary(varlist, nvar, niter, iter1, m, pctiles, grb, wdpath, logfile) {
	// computations
	vecvarlist = tokens(varlist)
	if (m > 1) summarymat = J(nvar, 7, .)
	else summarymat = J(nvar, 6, .)
	sample = niter * m
	X = st_data(1::sample, varlist)
	means = mean(X)
	summarymat[. , 1] = means'
	summarymat[. , 2] = sqrt(diagonal(variance(X)))
	a = trunc(sqrt(niter))
	means_batch = J(a * m, nvar, .)
	for (i = 1; i <= m; i++) {
		for (j = 1; j <= a; j++) {
			means_batch[j + a * (i - 1), .] = mean(X[((1::a) :+ a :* (j - 1)) :+ (niter * (i - 1)), 1..nvar])
		}
	}
	summarymat[. , 3] = (sqrt((a / (a * m - 1) / sample) :* colsum((means_batch :- J(a * m, 1, means)):^2)))'
	summarymat[. , 4..6] = pctiles
	if (m > 1) summarymat[. , 7] = grb
	DIC = readDICpD(wdpath, logfile)
	nrowDIC = rows(DIC)
	if (nrowDIC == 0) st_local("isDIC", "0")
	else st_local("isDIC", "1")
	// printing
	printf("\n")
	printf("{txt}{space 1}Number of chains:\t\t\t\t\t{res}%g\n", m)
	printf("{txt}{space 1}Number of 'burn-in' iterations:\t\t\t{res}%g\n", iter1 - 1)
	printf("{txt}{space 1}Number of iterations by chain (after burn-in):\t\t{res}%g\n", niter)
	printf("\n")
	if(m == 1) {
		printf("{space 1}{hline 72}\n")
		printf("{space 7}node{space 6}mean{space 8}sd{space 2}MC error{space 6}2.5%%{space 4}median{space 5}97.5%%\n")
		printf("{space 1}{hline 72}\n")
		for (i = 1; i <= nvar; i++) {
			printf("{res}%11s%10.5g%10.5g%10.5g%10.5g%10.5g%10.5g\n", vecvarlist[i], summarymat[i, 1], summarymat[i, 2], summarymat[i, 3], summarymat[i, 4], summarymat[i, 5], summarymat[i, 6])
		}
		printf("{space 1}{hline 72}\n")
	}
	else {
		printf("{space 1}{hline 82}\n")
		printf("{space 7}node{space 6}mean{space 8}sd{space 2}MC error{space 6}2.5%%{space 4}median{space 5}97.5%%{space 6}CSRF\n")
		printf("{space 1}{hline 82}\n")
		for (i = 1; i <= nvar; i++) {
			printf("{res}%11s%10.5g%10.5g%10.5g%10.5g%10.5g%10.5g%10.5g\n", vecvarlist[i], summarymat[i, 1], summarymat[i, 2], summarymat[i, 3], summarymat[i, 4], summarymat[i, 5], summarymat[i, 6], summarymat[i, 7])
		}
		printf("{space 1}{hline 82}\n")
	}
	printf("\n")
	printf("{txt}{space 1}Deviance-related measures:\n")
	if (nrowDIC == 0) 
		printf("{txt}{space 1}Not available\n")
	else {
		printf("{space 1}{hline 42}\n")	
		printf("{res}{space 7}node{space 6}Dbar{space 6}DIC{space 8}pD{space 2}\n")
		printf("{space 1}{hline 42}\n")
		for (i = 1; i <= nrowDIC; i++) {
			if(i == nrowDIC) printf("{space 1}{dup 42:-}\n")	
			printf("{res}%11s%10.5g%10.5g%10.5g\n", DIC[i, 1], strtoreal(DIC[i, 2]), strtoreal(DIC[i, 3]), strtoreal(DIC[i, 4]))
		}
		printf("{space 1}{hline 42}\n")
	}
	printf("\n")
	// returned to Stata
	st_matrix("summarymat", summarymat)
	rowssummarymat = J(rows(summarymat), 2, "")
	rowssummarymat[, 2] = vecvarlist'
	st_matrixrowstripe("summarymat", rowssummarymat)
	if (nrowDIC > 0) {
		st_matrix("DIC", strtoreal(DIC[., 2..4]))
		rowsDIC = J(rows(DIC), 2, "")
		rowsDIC[, 2] = DIC[., 1]
		st_matrixrowstripe("DIC", rowsDIC)
	}
}

function readDICpD(wdpath, logfile) {
	file = invtokens((wdpath, "/", logfile), "")
	fh = fopen(file, "r")
	do {
		line = fget(fh) 
	} while (line != "Deviance information" & line != "can not calculate DIC for this model" ) 
	if (line == "Deviance information") {
		// skip line with names
		skip = fget(fh)
		position = ftell(fh)
	// count number of lines with deviance information
		counter = 0
		line = fget(fh)
		while (line != "CODA files written") {
			counter++
			line = fget(fh)
		} 
		fseek(fh, position, -1)
		result = J(counter, 4, "")
		for (i = 1; i <= counter; i++) {
			result[i, .] = (tokens(fget(fh), char(9)))[1, (1, 3, 7, 9)]
		}
	}
	else {
		result = J(0, 0, "")
	}
	fclose(fh)
	return(result)
}

function GelmanRubinBrooksplot(varlist, nvar, niter, iter1, m, nbin) {	
	nend = (1..nbin) :* (niter/nbin)
	nstart = trunc(nend :/ 2)
	GRBmatplot = J(nvar * nbin, 3, .)
	GRBmatplot[., 1] = vec(J(1, nbin, 1::nvar))
	GRBmatplot[., 2] = vec(J(nvar, 1, nstart :+ iter1 :- 1))
	for(i = 1; i <= nbin; i++) {		
		GRBmatplot[(1::nvar) :+ (nvar * (i-1)), 3] = GelmanRubinBrooks(varlist, nvar, nstart[i], nend[i], niter, m)
	}
	st_matrix("GRBmatplot", GRBmatplot)
}
end
