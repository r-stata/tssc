*! 1.3.1 Anders Alexandersson 20030211                
program define ellip7, rclass sortpreserve
	version 7.0
	if _caller() <= 6 {
		ellip6 `0'
		exit
	}
	syntax varlist(min=1 max=2 numeric) [if] [in] [, COEFS MEANS  /*
	*/ Level(int $S_level) NPoints(integer 400) Pool(int -1)      /*
	*/ Constant(str) CONNect(str) SYmbol(str) Generate(str)       /*
	*/ Add(varlist min=2 max=2 numeric) B2title(str) L1title(str) /*
	*/ T1title(str) T2title(str) YFormat XFormat YFormat2(str) /*
	*/ XFormat2(str) SAving(str) EVR(real 1) NOGRaph REPLACE /*
        */ BY(varname) Need(str) *]		
	* parse generate(str) 
	if "`generate'" ~= "" {
		local wc : word count `generate'
		if `wc' ~= 2 {
			di as err "exactly TWO variables required in generate()"
			exit 198
		}
		tokenize `generate'
		args new1 new2
		if "`replace'" ~= "" {
			capture drop `new1' `new2'
		} 
		confirm new var `new1'
		confirm new var `new2'
		marksample touse, novarlist	/* include missing obs */
	}
        else {
		marksample touse		/* exclude missing obs */
	}
	* parse constant(str)
	if "`constant'" ~= "" {
		local wc : word count `constant'
		if `wc' >= 3 {
			di as err "max TWO arguments allowed in constant()"
			exit 198
		}
		tokenize "`constant'"
		args stat p
		confirm names `stat'
		if "`p'" ~= "" {
			confirm number `p'
		}
	}

	* set common defaults
	if "`nograph'" ~= "" {
		local graph ""
	}
	else {
		local graph "graph"
	}
	local symbol = cond("`symbol'"=="", "......", "`symbol'")
	local symbol "symbol(`symbol')"
	local connect = cond("`connect'"=="", "llllll", "`connect'")
	local connect "connect(`connect')"
	if "`saving'" ~= "" {
		local saving "saving(`saving')"
	} 
	set textsize 125
	if `"`t1title'"' == `""' {
		local t1title `" "'
	}        
	if `"`t2title'"' == `""' {
		local t2title `" "'
	}

	* check for errors
	if "`generate'" ~= "" & "`by'" ~= "" { 
		di as err "may not combine options generate() and by()"
		exit 198
	}
	if `level' < 10 | `level' > 99 {
		di as err `"level(`level') invalid"'
		di as text "level() must be an integer between 10 and 99"
		exit 198
	}
	if `npoints' < 20 | `npoints' > 9999 {
		di as err `"npoints(`npoints') invalid"'
		di as text "npoints() must be an integer between 20 and 9999"
		exit 198
	}
	if `evr' < 0 | `evr' > 10^36 {
		di as err `"evr(`evr') invalid"' 
		di as text "evr() must be a floating-point number between " /*
		*/ "0 and 10^36"
		exit 198
	}
	if "`means'" ~= "" & "`coefs'" ~= "" {
		di as err "may not specify both means and coefs"
		exit 198
	}
	if "`yformat'" ~= "" & `"`yformat2'"' ~= "" { 
		di as err "may not specify both yformat and yformat()"
		exit 198  
	}
	if `"`yformat2'"' ~= "" {
		capt local tmp : display `yformat2' 1
		if _rc {
			di as err `"invalid %fmt in yformat(`yformat2')"'
			exit 120
		}
	}
	if "`xformat'" ~= "" & `"`xformat2'"' ~= "" { 
		di as err "may not specify both xformat and xformat()"
		exit 198  
	}
	if `"`xformat2'"' ~= "" {
		capt local tmp : display `xformat2' 1
		if _rc {
			di as err `"invalid %fmt in xformat(`xformat2')"'
			exit 120
		}
	} 
	if "`constant'" == "sd" & `level' ~= $S_level {     
		di as err "may not specify both constant(sd) and level()"
		exit 198
	}
	if "`constant'" == "sq" & `level' ~= $S_level {     
		di as err "may not specify both constant(sq) and level()"
		exit 198
	}
	if "`pool'" ~= "-1" {
		ChkPool "`pool'" "`add'" "`if'" "`in'" "`graph'"
	}

	* define macros, and tokenize              
	tempvar t new1 new2 yy xx id tmpy tmpx iwt  
	tempname n f F r a b c xbar ybar s_x s_y x_a y_a A B m1 m2 /*
	*/ var_y var_x cov_xy C D lambda1 lambda2
	tempfile new tmp
	local old_N = _N 
	if "`generate'" ~= "" {
		tokenize `generate'
		args new1 new2
	}
	if "`add'" ~= "" {
		tokenize `add'                                     
		args old1 old2
	}
	if "`constant'" ~= "" {
		tokenize `constant'
		args stat p
	}
	tokenize "`varlist'" 
	args y x

	* set centering-specific defaults
	if "`coefs'" == "coefs" {
		if "`e(cmd)'" ~= "regress" {
			exit 198
			* exit 301
		}
		if "`x'" == "" {                                    
			local x "_cons"                                 
		}
		else {                                       
			local x "`2'" 
			if "`e(depvar)'" == "`x'" | "`e(depvar)'" == "`y'" {
				di as err "`e(depvar)' is not independent variable"
				exit 111
			}
		}
		if "`l1title'" == "" {
			local l1title "Estimated `y'"
		}
		if "`b2title'" == "" {
			local b2title "Estimated `x'"
		}
	}
	else {
		local ylab : variable label `y'
		local xlab : variable label `x'
		if "`l1title'" == "" {
			if "`ylab'" == "" {
				local l1title "`y'"
			}
			else {
				local l1title "`ylab'"
			}
		}
		if "`b2title'" == "" {
			if "`xlab'" == "" {
				local b2title "`x'"
			}
			else {
				local b2title "`xlab'"
			}
		}
	}

	if "`by'" == "" {
		* calculate centering-specific basic ingredients
		if "`coefs'" == "coefs" {
			local ybar "_b[`y']"
			local s_y "_se[`y']"
			local var_y "_se[`y']^2"
			local xbar "_b[`x']"
			local s_x "_se[`x']"
			local var_x "_se[`x']^2"
			qui cor if `touse', _coef
			scalar `n' = e(N)
		}
		else {
			qui summarize `y' if `touse'
			scalar `ybar' = r(mean)     
			scalar `s_y' = r(sd)
			scalar `var_y' = r(Var)
			qui summarize `x' if `touse'
			scalar `xbar' = r(mean)
			scalar `s_x' = r(sd)
			scalar `var_x' = r(Var)
			qui corr `y' `x' if `touse'
			scalar `n' = r(N)
		}
		scalar `r' = r(rho)
		scalar `cov_xy' = `r' * `s_x' * `s_y'

		* calculate c in subroutine, and then amplitudes of arcs x and y
		DoCons "`p'" `n' `level' "`stat'" "`coefs'"
		scalar `c' = r(c)
		scalar `x_a' = `s_x' * sqrt(`c') 
		scalar `y_a' = `s_y' * sqrt(`c')

		* bring back data, calculate ellipse, and return results
		preserve
		qui range `t' 0 2*_pi `npoints'				/* change data */
		qui gen `new2' = `xbar' + `x_a' * cos(`t')                   
 		qui gen `new1' = `ybar' + `y_a' * cos(`t' + acos(`r'))
		qui summarize `new1'
		ret scalar min_y = r(min)	/* min of y */
		ret scalar max_y = r(max)	/* max of y */
		qui summarize `new2'
		ret scalar min_x = r(min)	/* min of x */
		ret scalar max_x = r(max)	/* max of x */

		* create macros for readabaility: ylist, xlist
		if "`generate'" == "" {
			if "`add'" == "" {
				local ylist "`new1'"
				local xlist "`new2'" 
			}
			else {
				stack `new1' `new2' `old1' `old2', into(`yy' `xx') clear
				qui gen `new1' = `yy' if _stack==1  /* (obs 001-400) */
				qui gen `old1' = `yy' if _stack==2  /* (obs 401-800) */
				keep `new1' `old1' `xx'             /*    >= 800 obs */
				local ylist "`new1' `old1'"
				local xlist "`xx'" 
			}
		}
		else {							/* gen() */
			if "`add'" == "" {
				local ylist "`new1'"
				local xlist "`new2'" 
			}
			else {						/* add() */
				qui save "`new'" /* save dataset to allow damage */
				stack `new1' `new2' `old1' `old2', into(`yy' `xx') clear
				qui gen `new1' = `yy' if _stack==1 /* (obs 001-400) */
				qui gen `old1' = `yy' if _stack==2 /* (obs 401-800) */
				keep `new1' `old1' `xx'            /*    >= 800 obs */
				if "`pool'" == "-1" {                        
					local ylist "`new1' `old1'"
					local xlist "`xx'"
				}
				else {					/* pool() */
					qui gen long `id' = _n
					sort `id'
					local ylist "`new1' `old1'"
					local xlist "`xx'"
					qui save "`tmp'"		/* save tmp dataset */
				}
			}
		}

		* format ylist and xlist
		if `"`yformat2'"' ~= "" {      
			format `ylist' `yformat2'   
		}
		else format `ylist' %9.0g /* includes fy */
		if `"`xformat2'"' ~= "" {
			format `xlist' `xformat2'
		}
		else format `xlist' %9.0g /* includes fx */

		* graph ellipse
		if "`generate'" ~= "" & "`add'" ~= "" & "`pool'" ~= "-1" {
			* retrieve tmp dataset, and create fractionally pooled datasets
			use "`tmp'", clear
			* get rhs-variables (excluding _cons)
			tempname b
			mat `b' = e(b)
			local rhs : colnames(`b')
			local rhs : subinstr local rhs "_cons" "", word
			forvalues i = 0/`pool' {
				restore, preserve /* N >= 400 */
				qui gen double `iwt' = 1 if `touse'==1
				qui replace `iwt' = [`i']/`pool' if `touse'==0
				
				* bugfix in v1.3.1: `rhs' = iv1 iv2 ...
				qui reg `e(depvar)' `rhs' [iw=`iwt'], /*
				*/ level(`level') noheader
				qui gen `tmpy' = `ybar'                      
				qui gen `tmpx' = `xbar'
				qui keep `iwt' `tmpy' `tmpx'
				qui keep in l/l       
				tempfile wt`i'
				qui save "`wt`i''" 
			}

			* append into one file which contains the locus curve
			use "`wt0'", clear
			forvalues i = 1/`pool' { 
				append using "`wt`i''"
			}
                         
			* save locus curve, and merge with tmp dataset
			qui gen long `id' = _n
			sort `id'                     
			qui save "`wt`pool''", replace

			* return matrix for locus curve, as in -corrgram-
			tempname IWT YVAR XVAR 
			mkmat `iwt', matrix(`IWT')
			mkmat `tmpy', matrix(`YVAR')
			mkmat `tmpx', matrix(`XVAR') 
			mat colnames `IWT' = iwt
			mat colnames `YVAR' = "`y'"
			mat colnames `XVAR' = "`x'"
			ret matrix IWT `IWT'
			ret matrix YVAR `YVAR'
			ret matrix XVAR `XVAR'
			merge `id' using "`tmp'"

			* use the -gr20- STB-34 package within gph
			gph open, `saving'
			* pen() option in graph is invalid in gphdt -> r(198)
			gra `ylist' `xlist', `connect' `symbol' /*
			*/ t1("`t1title'") t2("`t2title'") /*
			*/ b2("`b2title'") l1("`l1title'") `options'
			gphsave
			local end = `pool' + 1
			local y_b = `tmpy' in 1/1			/*  b(y;_) */
			local y_bp = `tmpy' in `end'/`end'		/* bp(y;_) */
			local x_b = `tmpx' in 1/1			/*  b(_;x) */
			local x_bp = `tmpx' in `end'/`end'		/* bp(_;x) */
			gphdt text `y_b' `x_b' 0 1 b			/* b text */
			gphdt text `y_bp' `x_bp' 0 1 bp			/* bp text */
			qui gphdt vline `tmpy' `tmpx' in 1/`end'	/* var line */ 
			qui gphdt vpoint `tmpy' `tmpx' in 1/`end'	/* var pts */
			gph close                       
			qui keep if `iwt' ~= .
			rename `iwt' iweight          
			rename `tmpy' `y'
			di						/* display table */
			di as text "The Fractionally Pooled Estimates"
			di as text "(i.e., the dots in the locus curve):"
			if "`x'" == "_cons" {
				rename `tmpx' constant			/* _cons is system variable */
				tabdisp iweight, cell(`y' constant) center        
			}
			else {
				rename `tmpx' `x'
				tabdisp iweight, cell(`y' `x') center
			}
		}
		else {  /* NOT pool() */
			if "`graph'" ~= "" {
				gra `ylist' `xlist', by(`by') `connect' `symbol'  /*
				*/ t1("`t1title'") t2("`t2title'")  /*
				*/ b2("`b2title'") l1("`l1title'") `saving' `options'
			}
		}
		* make sure that dataset is not damaged
		if "`generate'" ~= "" & "`add'" ~= "" {
			use "`new'", clear
		}

		* all went well, keep any generated vars 
		if "`generate'" ~= "" {
			if _N > `old_N' {
				di as text "obs was `old_N', now " _N
			}
			restore, not
		}
	}
	else { /* by() */
		preserve
		tempvar Y id
		tempname byname
		local by "`by'"
        	tempvar group
        	sort `touse' `by'
        	qui by `touse' `by': gen byte `group' = _n == 1 if `touse'
        	qui replace `group' = sum(`group')
        	local max = `group'[_N]
		qui range `t' 0 2*_pi `npoints'			/* 400 obs */
		qui tab `by', matrow(`byname')
		svmat `byname', name(`id') /* 0,1,2,... */

		* create yvars and xvars (ellipse variables for each group)
		tempvar subuse
		qui gen byte `subuse' = .
		* get rhs-variables (excluding _cons)
		tempname b
		mat `b' = e(b)
		local rhs : colnames(`b')
		local rhs : subinstr local rhs "_cons" "", word

		forvalues i = 1/`max' {
			if "`coefs'" == "coefs" {	/* bugfix in v 1.3.1 */
				* -reg ...by()- remembers only last estimates
				qui replace `subuse' = `touse' & `group' == `i'
				qui reg `e(depvar)' `rhs' if `subuse'
				local ybar "_b[`y']"
				local s_y "_se[`y']"
				local var_y "_se[`y']^2"
				local xbar "_b[`x']"
				local s_x "_se[`x']"
				local var_x "_se[`x']^2"
				qui cor if `touse', _coef
				scalar `n' = e(N)			
			}
			else {
				qui summarize `y' if `group' == `i'
				scalar `ybar' = r(mean)     
				scalar `s_y' = r(sd)
				scalar `var_y' = r(Var)
				qui summarize `x' if `group' == `i'
				scalar `xbar' = r(mean)
				scalar `s_x' = r(sd)
				scalar `var_x' = r(Var)
				qui corr `y' `x' if `group' == `i'	
				scalar `n' = r(N)
			}			
				
			scalar `r' = r(rho)
			scalar `cov_xy' = `r' * `s_x' * `s_y'
			* calculate c in subroutine, and then amplitudes of arcs x and y
			DoCons "`p'" `n' `level' "`stat'" "`coefs'"
			scalar `c' = r(c)
			scalar `x_a' = `s_x' * sqrt(`c') 
			scalar `y_a' = `s_y' * sqrt(`c')
			tempvar ynew`i' xnew`i'
			gen `ynew`i'' = `ybar' + `y_a' * cos(`t' + acos(`r'))
			gen `xnew`i'' = `xbar' + `x_a' * cos(`t')
			
			* return min_x and min_y?
			qui summarize `ynew`i''
			ret scalar min_y = r(min)	/* min of y */
			ret scalar max_y = r(max)	/* max of y */
			qui summarize `xnew`i''
			ret scalar min_x = r(min)	/* min of x */
			ret scalar max_x = r(max)	/* max of x */
			local stargs "`stargs' `ynew`i'' `xnew`i'' `id' `by'"
		}


		* default titles: if no varlab, use varnam
		local bylab : variable label `by'
		if "`title'" == "" {
			if "`bylab'" == "" {
				local title "`by'"
			}
			else {
				local title "`bylab'"
			}
		}

		* stack does not allow into (_cons )
		if "`x'" == "_cons" {
			tempvar z
			gen `z' = 1
			stack `stargs', into (`Y' `z' `id' `by') wide clear	
			local x "`z'"
		}
		else {
			stack `stargs', into (`Y' `x' `id' `by') wide clear
		}
		forvalues i = 1/`max' {
			tempvar sy_`i'
			qui gen `sy_`i'' = `Y' if _stack==`i'
			local ylist "`ylist' `sy_`i''"
			qui replace _stack = `id'[`i'] if _stack==`i'
		}
		local xlist "`x'"
		drop `by'
		rename _stack `by'
		sort `by'
		gra `ylist' `xlist', by(`by') `connect' `symbol' /*
		*/ l1("`l1title'") t1("`t2title'") /*
		*/ b2("`b2title'") b1(Graphs by "`title'") `saving' `options'
	}
	* calculate scalars to be returned
	scalar `A' = `var_y' - `evr' * `var_x'
	scalar `B' = `cov_xy'
	scalar `m1' = (`A' + sqrt((`A')^2 + 4*`evr' * (`B')^2)) / (2 * `B')
	scalar `C' = `var_y' + `var_x' 
	scalar `D' = ((`C'^2) - 4*(`var_y' * `var_x' - `cov_xy'^2))^.5
	scalar `lambda1' = (`C' + `D') / 2
	scalar `lambda2' = `C' - `lambda1'  /* or: (`C' - `D') / 2 */

	* save results as scalars in r()
	ret scalar a = (1 / `lambda1')^-.5 * sqrt(`c')	/* l of semi-major */
	ret scalar b = (1 / `lambda2')^-.5 * sqrt(`c')	/* l of semi-minor */ 
	ret scalar c       = `c'		/* boundary constant */
	ret scalar r       = `r'		/* correlation coefficient */
	ret scalar m1      = `m1'		/* slope of major axis */
	ret scalar m2      = - 1 / `m1'		/* slope of minor axis */
	ret scalar lambda1 = `lambda1'		/* first eigenvalue of inverse V */
	ret scalar lambda2 = `lambda2'		/* second eigenvalue of inverse V */
	ret scalar mean_y  = `ybar'		/* mean of y */   
	ret scalar s_y     = `s_y'		/* standard error of y */    
	ret scalar mean_x  = `xbar'		/* mean of x */    
	ret scalar s_x     = `s_x'		/* standard error of x */
end

program define ChkPool, rclass
        args pool add if in graph
	capture which gphdt
	if _rc ~= 0 {
		di in re "pool() must have gphdt.ado installed"
		exit _rc
	} 
	capture which gphsave
	if _rc ~= 0 {
		di in re "pool() must have gphsave.ado installed"
		exit _rc
	}
	if "`add'" == "" {                     
		di as err "pool() must be used with add()"
		exit 198
	}
	if "`if'" == "" & "`in'" == "" {
		di as err "must use pool() with [if exp] or [in range]"
		exit 198
	} 
	if "`graph'" == "" {
		di as err "may not specify both nograph and pool()"
		exit 198
	}
	if `pool' < 1 | `pool' > 100 {
		di as err `"pool(`pool') invalid"'
		di as text "pool() must be an integer between 1 and 100"
		exit 198
	}
	capture confirm new variable _merge
	if _rc ~= 0 {
		di as err "drop _merge before running ellip with pool()"
		exit _rc
	}
end

program define DoCons, rclass	/* returns r(c) */
	args p n level stat coefs
	tempname Fadj F c Chi T2
	local means_d `"("`stat'" == "" & "`coefs'" ~= "coefs")"'
	local coefs_d `"("`stat'" == "" & "`coefs'" == "coefs")"'
	* calculate p
	if "`stat'" == "sd" | (`means_d') {
		if "`p'" == "" { local p = "4" }
		else { local p = (`p')^2 }
	}
	else if "`stat'" == "sq" {
		if "`p'" == "" { local p = "4" }
		else { local p = `p' }
	}
	else {
		if "`p'" == "" { local p = "2" }
		else { local p = "`p'" }
	}

	* calculate c
	if "`stat'" == "fadj" {
		scalar `Fadj' = invfprob(2,(`n'-`p'),(100-`level')/100)
		ret scalar c = (2 * `Fadj')
	}
	else if "`stat'" == "f" | `coefs_d' {
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		ret scalar c = (2 * `F')
	}
	else if "`stat'" == "chisq" {
		ret scalar c = invchi2tail(2,(100-`level')/100) /* v7 */
	}
	else if "`stat'" == "chisqn" {         
		scalar `Chi' = invchi2tail(2,(100-`level')/100) /* v7 */
		ret scalar c = (`Chi' / `n')
	}
	else if "`stat'" == "tsq" | "`stat'" == "hotel" {         
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		scalar `T2' = `p' * (`n'-1) / (`n'-`p') * `F'
		ret scalar c = `T2'
	}
	else if "`stat'" == "tsqn" | "`stat'" == "hoteln" {         
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		scalar `T2' = `p' * (`n'-1) / (`n'-`p') * `F'
		ret scalar c = (`T2' / `n')
	}
	else if "`stat'" == "ptsq" | "`stat'" == "photel" {         
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		scalar `T2' = `p' * (`n'-1) / (`n'-`p') * `F'
		ret scalar c = (`T2' * (`n' + 1) / `n')
	}
	else if "`stat'" == "sd" | "`stat'" == "sq" | (`means_d') {
		ret scalar c = `p'
	}
end
exit

HISTORY
1.3.1 Anders Alexandersson 10feb2003			SSC Archive
       - Bug fixes of ellip7:
       1. coefs by()- would give the results for -means by()-;
         this is fixed in ellip7 (N/A for ellip6 and ellip5)
       2. -coefs by()- failed to return results; this is fixed 
       3. -pool()- would unly use 2 independent variables in reg;
         this is fixed in ellip7 but not in ellip6 (no bug in ellip5)
       - replaces version 1.3.0 with same requirements
1.3.0 Anders Alexandersson 16jan2003			(outdated)
       - new nograph and c(sq) option; fixed by() option for means
       - requires Stata 7, gphdt for pool
1.2.0 Anders Alexandersson 16jan2003                    SSC Archive
       - fixes several minor bugs such as some r() in 1.1.0  
       - is tested to reproduce 20+ published confidence ellipses
       - allows more options in c()
       - uses more modular code and calls -graph- less times
       - replaces version 1.1.0 with same requirements
1.1.0 Anders Alexandersson 12nov2001                    (outdated)
       - allows centering around means and more types of ellipses
       - requires Stata 6, gphdt for pool()
       - version 1.0.0 renamed into ellip_5.ado
1.0.0 Anders Alexandersson 7aug1998                     STB-46: gr32
       - graphs confidence ellipses around regression coefficients
       - requires Stata 5, gphdt for pool(), parsoptp
