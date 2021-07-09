/* change log
2015-04-24: extraction of cluster variable from models fixed.
- more robust treatment of unidentified covariates
2015-08-26: word count more robust to very long lists
*/
program rhausman, rclass
	syntax [anything] [if] [in] [aw pw /] [, reps(integer 100) subset(string) ///
	bsdata(string) cluster detail]
	version 12
	
	*errors
	if wordcount("`anything'")!=2 {
		di as err "you must specify two models"
		exit 198
	}
	local e1 : word 1 of `anything'
	local e2 : word 2 of `anything'
	if "`e1'" == "`e2'" {
		di as err "the two models need to be different"
		exit 198
   	}
	
	if "`detail'"=="detail" 	loc hide ""
	else						loc hide "qui"
	
	*time stamp	
	loc t1=string(  clock("$S_DATE $S_TIME", "DMYhms"), "%14.0f"  )
	
	*model 1
	`hide' est res `e1'
	loc x1: colf e(b)
	*di "x1: `x1'"
	mat b1=e(b)'
	loc k1= rowsof(b1)
	loc cmd1 "`e(cmdline)'"
	loc dep "`e(depvar)'"
	gettoken (local) regcmd1 (local) regopt1: cmd1, p(,)

	*extract cluster variable if specified
	if "`cluster'"!="" {
		if "`e(clustvar)'"!="" 	loc clustvar "`e(clustvar)'"
		else 					loc clustvar "`e(ivar)'"
	}
	
	*produce error if factor variables are used
	if regexm("`regcmd1'","(.*)[#](.*)") | regexm("`regcmd1'","[ci]\.(.*)") {	
		di as err "Please avoid factor variables in your model."
		exit
	}
	
	*model 2
	`hide' est res `e2'
	loc cmd2 "`e(cmdline)'"
	mat b2=e(b)'
	loc k2= rowsof(b2)
	loc x2: colf e(b)
	`hide' di "x1: `x1'"
	`hide' di "x2: `x2'"
	
	*obtain union of variable lists
	loc x1: list x1 | x2

	*clean the x-list from prefixes
	loc length: word count `x1' 
	foreach v of loc x1 {
		if regexm("`v'","(.?)o[.](.*)") { // if omitted
		*di "`v'"
			loc vclean = regexr("`v'","(.*)o[.]","")
			loc xzero "`xzero' `vclean'"
		}
		else { // if variable not omitted
		loc vclean = regexr("`v'","(.*)[:]","") // drop equation name
		loc xclean "`xclean' `vclean'"
		}
	}
	
	* remove duplicates
	loc xclean: list uniq xclean
		
	*replace x-list with subset if specified
	if "`subset'"!="" {
	loc xclean: list xclean & subset
	}
	*exclude constant
	loc constant "_cons"
	`hide' di "xclean before: `xclean'"
	loc xclean: list xclean - constant
	`hide' di "xclean after: `xclean'"
	`hide' di "xzero: 	`xzero'"
	
	* remove duplicates
	loc xclean: list uniq xclean
	
	* exclude coefficients that are not identified (if not yet excluded)
	`hide' est res `e1'
	foreach v of loc xclean {
		cap di _b[`v']
		if !_rc {
			if (_b[`v']==0)	loc xclean: list xclean - v
		}
	}
	`hide' est res `e2'
	foreach w of loc xclean {
		cap di _b[`w']
		if !_rc {
			if _b[`w']==0	loc xclean: list xclean - w
		}
	}
	
	
	*extract cluster variable if not yet extracted in model 1
	if "`cluster'"!="" & "`clustvar'"=="" {
		if "`e(clustvar)'"!="" 	loc clustvar "`e(clustvar)'"
		else 					loc clustvar "`e(ivar)'"
	}
	if "`clustvar'"=="" {
		di as err "You must specify a cluster variable in your models " /*
		*/ "when using the 'cluster' option in rhausman"
		exit
	}

	*scalar names: bootstrapped coefficients
	foreach v of loc xclean {
		loc sim1 "`sim1' (b1_`v')"
		loc sim2 "`sim2' (b2_`v')"
	}
	`hide' di "`sim1' " _n "`sim2'"
	
	*for postfile: define coefficient names
	foreach v of loc xclean {
		loc b1names = "`b1names' b1_`v'"
		loc b2names = "`b2names' b2_`v'"
	}
	`hide' di "b1names: `b1names' "
	`hide' di "b2names: `b2names' "

	*--------------
	*start boostrap code
	cap postclose bootstr
	tempfile bootstr
	`hide' postfile bootstr `b1names' `b2names' using `bootstr', replace
	
	*iterate
	forv i=1/`reps' {
	
		preserve
		
		*resample
		if "`cluster'"=="" {
			bsample
		}
		else {
			cap drop `id'
			tempvar id 
			bsample, cluster(`clustvar') idcluster(`id')
			qui xtset `id'
		}
		*estimate model 1
		qui `cmd1'
		foreach v of loc xclean {
		sca b1_`v' = _b[`v']
		}
		mat b1=e(b)'
		*estimate model 2
		qui `cmd2'
		mat b2=e(b)'
		foreach v of loc xclean {
		sca b2_`v' = _b[`v']
		}
		
		*save bootstrapped coefficients in postfile
		post bootstr `sim1' `sim2'
		
		* forecast of computation time
		if (`i'==50 & `reps'>100) {
		loc t2=string(  clock("$S_DATE $S_TIME", "DMYhms"), "%14.0f"  )
		loc trem=(`reps'/50 - 1) * (`t2'-`t1')
		}
		*bootstrap dots
		if (`i'==1) {
		di as text "bootstrap in progress" 
		di as txt "{hline 4}{c +}{hline 3} 1 "	///
				  "{hline 3}{c +}{hline 3} 2 "	///
				  "{hline 3}{c +}{hline 3} 3 "	///
				  "{hline 3}{c +}{hline 3} 4 "	///
				  "{hline 3}{c +}{hline 3} 5 "		
		}
		loc round=`i'/50
		capture confirm integer number `round'
		if !_rc 			di in gr ". " `i'
		if  _rc				di in gr "." _c
		if (`i'==50 & `reps'>100) {
		di "(This bootstrap will approximately take another " ///
		floor(hours(`trem')) "h. " ///
		floor(minutes(`trem') - floor(hours(`trem'))*60 ) "min. " ///
		seconds(`trem') - floor(minutes(`trem'))*60 "sec.)"
		}
		
		restore
		
	}
	postclose bootstr
	*--------------	end of boostrap code

	
	*open file with bootstrapped coefficients
	preserve
	use `bootstr', clear

	*vector of differences in coefficients
	tempname bdif
	foreach v of loc xclean {
		qui est res `e1'
		sca b1_`v' = _b[`v']
		qui est res `e2'
		sca b2_`v' = _b[`v']
		mat `bdif'=nullmat(`bdif') , (b1_`v' - b2_`v')
	}
	`hide' matlist  `bdif'
	local df = colsof(`bdif')

	*generate bootstrapped differences in coefficients
	foreach v of loc xclean {
	g double d_`v'=b1_`v' - b2_`v'
	loc dbeta "`dbeta' d_`v'" 
	}
	
	*covariance matrix of bootstrapped differences
	qui cor `dbeta', cov
	mata:Vdif=st_matrix("r(C)")
	tempname Vdif 
	mat `Vdif' =r(C)
	
	*Hausman test statistic
	mata:bdif=st_matrix("`bdif'")
	//mata:bdif
	//mata:invsym(Vdif)
	mata:chi2 = bdif * invsym(Vdif) * bdif'
	tempname chi2 rank
	mata:st_numscalar("`chi2'",chi2)
	mata:st_numscalar("`rank'",rank(Vdif))
	`hide' di "chi2-statistic: " `chi2'
	`hide' di "df: " `df'
	`hide' di "rank: " `rank'
	`hide' di "pval: " chiprob(`rank',`chi2')

	`hide' mean `dbeta'
	tempname b_dif_boot
	mat `b_dif_boot' = e(b)

	*generate dataset
	if "`bsdata'"!=""  save `bsdata'
	
	restore

	*display results
	di as txt "{hline 80}"
	if "`cluster'"=="cluster" loc clu_label "Cluster-"
	di as res "`clu_label'Robust Hausman Test" 
	di as txt "(based on `reps' bootstrap repetitions)"  _n
	di as txt "{lalign 80:b1: obtained from `cmd1'}"
	di as txt "{lalign 80:b2: obtained from `cmd2'}"
	if "`subset'"!="" {
	di as txt "Included in the test: `xclean'"
	}
	if "`xzero'"!="" {
	di as text "Excluded (not identified, or only identified in one model): `xzero'"
	}


	di _n as txt "    Test:  Ho:  difference in coefficients not systematic"
	di _n as txt "{ralign 25:chi2({res:`=`df''})}" ///
	   " = (b1-b2)' * [V_bootstrapped(b1-b2)]^(-1) * (b1-b2)"

	di as txt _col(27) "=  " as res %10.2f `chi2' _n ///
	   as txt _col(17) "Prob>chi2 =  "               ///
	   as res %10.4f chiprob(`df', `chi2')

	if `rank'<`df' {
	di _n as res _col(5) "Warning: your covariance matrix is rank deficient. " ///
		"It may be that the number of bootstrap repetitions was smaller " ///
		"than the number of independent variables."
	}
	
	
	*return results in r()
	ret scalar p    	= chiprob(`df', `chi2')
	ret scalar df   	= `df'
	ret scalar rank   	= `rank'
	ret scalar chi2 	= `chi2'
	
	ret mat V_dif = `Vdif'
	ret mat b_dif_boot=`b_dif_boot'
	ret mat b_dif = `bdif'
	
	
end


