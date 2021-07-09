*! Program to apply Rubin's rule to estimation results from multiply-imputed datasets
*! Assumes that you have estimations results stored as `stub'1, `stub'2, etc. 
*! Version 1.0.1
capture program drop mirubin
capture mata: mata drop rubin()
program define mirubin, eclass

	version 12
	syntax , [stub(name) Imputations(numlist) force repost noSMALL ] 
	
	if "`stub'" == "" {
		if "`e(cmd)'" == "mirubin" {
			_coef_table			// for -est replay-
			exit
		}
		else {
			error 301
		}
	}
	
	if "`imputations'" == "" {
		local i = 0
		capture
		while _rc == 0 {
			local i=`i'+1
			capture est dir `stub'`i'
		}
		if `i' == 1 {
			di as err "Cannot find matrix {res:``type'stub'`i'}"
			exit 999
		}
		else local nimp = `i' - 1

		numlist "1/`nimp'"
		local imputations `r(numlist)'
	}
	
	local nlist `imputations'
	local nimp : word count `imputations'
	gettoken firstn otherns : imputations
	
	
	if "`force'" == "" {
		// Check if estimation results have the same e(N) and that e(b) and e(V) have the same colnames.
		// Check also if e(depvar) and e(cmd) the same across results
		// Check also whether e(converged) == 1 in all results.
		qui est restore `stub'`firstn'
		local colnames : colfullnames e(b)
		local n = e(N)
		local converged = e(converged)
		if `converged' == 0 {
			di as err "Results not converged in `stub'`firstn'"
			local error yes
		}
		local depvar `e(depvar)'
		local cmd `e(cmd)'
		foreach imp in `nlist' {
			qui est restore `stub'`imp'
			// Check colnames/rownames of e(b), e(V)
			foreach type in e(b) e(V) {
				local testcolnames : colfullnames `type'
				if "`testcolnames'" != "`colnames'" {
					di as err "The column names of `type' in `stub'`firstn' is:"
					di as res "`colnames'"
					di as err "but the column names of `type' in `stub'`imp' is:"
					di as res "`testcolnames'"
					local error yes
				}
			}
			// Check e(N)
			local testn = e(N)
			if `n' != `testn' {
				di as err "e(N) in `stub'`firstn' is: {res:`n'}"
				di as err "but e(N) in `stub'`imp' is:  {res:`testn'}"
				local error yes
			}
			// Check e(converged)
			local converged = e(converged)
			if `converged' == 0 {
				di as err "Results not converged in `stub'`imp'"
				local error yes
			}
			// Check e(depvar)
			local testdepvar `e(depvar)'
			if "`testdepvar'" != "`depvar'" {
				di as err "e(depvar) in `stub'`firstn' is:"
				di as res "`depvar'"
				di as err "but e(depvar) in `stub'`imp' is:"
				di as res "`testdepvar'"
				local error yes
			}
			// Check e(cmd)
			local testcmd `e(cmd)'
			if "`testcmd'" != "`cmd'" {
				di as err "e(cmd) in `stub'`firstn' is:"
				di as res "`cmd'"
				di as err "but e(cmd) in `stub'`imp' is:"
				di as res "`testcmd'"
				local error yes
			}
		}
		if "`error'" == "yes" exit 999
	}
	
	// Restore the first result (in case the repost option is specified)
	qui est restore `stub'`firstn'
	local colnames : colfullnames e(b)
	local n = e(N)
	local depvar `e(depvar)'
	local cmd `e(cmd)'

	// Clarify which results we've got
	di as txt "Estimations found:"
	local estnames `""`stub'`firstn'""'
	di as res"`stub'`firstn'"
	foreach imp in `otherns' {
		local estnames `"`estnames', "`stub'`imp'""'
		di as res "`stub'`imp'"
	}

	// Ok... Run mata: rubin()
	tempname bmat Vmat Bmat Wmat RVI df fmi re pise
	mata: rubin((`estnames'), "`bmat'", "`Vmat'", "`Bmat'", "`Wmat'", "`RVI'", "`df'", "`fmi'", "`re'", "`pise'");
	
	if "`colnames'" == "" local colnames : colfullnames e(b)
	// di "`colnames'"
	foreach mat in bmat Vmat Bmat Wmat RVI df fmi re pise {
		matrix colnames ``mat'' = `colnames'
	}
	foreach mat in Vmat Bmat Wmat {
		matrix rownames ``mat'' = `colnames'
	}
	
	// Save copy of bmat and Vmat
	tempname bmat2 Vmat2
	matrix `bmat2' = `bmat'
	matrix `Vmat2' = `Vmat'
	
	if "`repost'" == "repost" ereturn repost b = `bmat' V = `Vmat'
	else ereturn post `bmat' `Vmat' 
	// ereturn display

	
	ereturn matrix b_mi = `bmat2'
	ereturn matrix V_mi = `Vmat2'
	ereturn matrix B_mi = `Bmat'
	ereturn matrix W_mi = `Wmat'
	ereturn matrix rvi_mi = `RVI'
	ereturn matrix df_mi = `df'
	ereturn matrix fmi_mi = `fmi'
	ereturn matrix re_mi = `re'
	ereturn matrix pise_mi = `pise'
	
	ereturn local cmd mirubin
	ereturn local depvar `depvar'
	ereturn local mi mi

	_coef_table

end
	
mata: 
void rubin(string rowvector matnames, 
	string scalar bmatname, 
	string scalar Vmatname, 
	string scalar Bmatname, 
	string scalar Wmatname, 
	string scalar RVIname, 
	string scalar dfname, 
	string scalar fminame, 
	string scalar rename, 
	string scalar pisename) {
	n = length(matnames);
	for(i=1;i<=n;i++) {
		command = "qui est restore " + matnames[i]
		stata(command);
		b = st_matrix("e(b)"); V = st_matrix("e(V)");
		df_r = st_numscalar("e(df_r)")
		if (i==1) {
			_b = b; _V_within = V; _df_r = df_r;
		}
		else {
			_b = (_b \ b) ; _V_within = _V_within + V; _df_r = _df_r \ df_r;
		}
	}
	 _b_mean = colsum(_b) :/ n ; _V_within = _V_within :/ n
	 _b_centred = _b :- J(n, 1,1) * _b_mean
	 _V_between = _b_centred' * _b_centred :/ (n - 1)
	 VV = _V_within + (1 + 1/n) :* _V_between ; bb = _b_mean ;
	 st_matrix(bmatname, bb) ; st_matrix(Vmatname, VV) ;
	 st_matrix(Bmatname, _V_between) ; st_matrix(Wmatname, _V_within) ;

	// Calculate RVI: Relative Variance Increase
	B = diagonal(_V_between)'
	Ubar = diagonal(_V_within)'
	T = diagonal(VV)'
	RVI = B :/ Ubar :* (1 + 1/n)
	st_matrix(RVIname, RVI)
	
 	// Calculate Degree of freedom
	df = (n - 1) :* (1 :+ 1 :/ RVI):^2
	st_matrix(dfname, df)
	
	// FMI: Fraction of information due to nonresponse
	FMI = (RVI + 2 :/ (df :+ 3)) :/ (RVI :+ 1);
	st_matrix(fminame, FMI);
	
	// Relative efficiency (of M imputations vs. infinite)
	re = 1 :/ (1 :+ FMI :/ n)
	st_matrix(rename, re)
	
	// PISE: Percentage increase in Standard error
	pise = (sqrt(T :/ Ubar) :- 1) :* 100
	st_matrix(pisename, pise); 

	/* small sample */
	nosmall = st_local("small")
	_DF_R = min(_df_r);

	if (nosmall == "" & _DF_R < .) {
		// df 
		gamma = (1 + 1/n) :* B :/ T
		nuc = _DF_R * (_DF_R + 1) :* (1 :- gamma) :/ (_DF_R +3)
		df_small = 1:/(1 :/ df + 1 :/ nuc)
		st_matrix(dfname, df_small)
		
		// FMI
		numerator = (df_small :+1) :/ (df_small :+3) :* Ubar
		denom = (_DF_R +1) / (_DF_R + 3) :* T
		FMI_small = 1 :- numerator :/ denom
		st_matrix(fminame, FMI_small)
		
		// Relative efficiency
		re_small = 1 :/ (1 :+ FMI_small :/ n)
		st_matrix(rename, re_small)
		
	};
	
	
}
		
		
end
