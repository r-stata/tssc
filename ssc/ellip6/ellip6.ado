*! 1.2.0 Anders Alexandersson 20030116                
program define ellip6, rclass
	version 6.0
	if _caller() < 6 {
		ellip5 `0'
		exit
	}
	syntax varlist(min=1 max=2 numeric) [if] [in] [, COEFS MEANS  /*
	*/ Level(int $S_level) NPoints(integer 400) Pool(int -1)      /*
	*/ Constant(str) CONNect(str) SYmbol(str) Generate(str)       /*
	*/ Add(varlist min=2 max=2 numeric) B2title(str) L1title(str) /*
	*/ T1title(str) T2title(str) YForm XForm YForm2(str) NOGRaph /*
	*/ SAving(str) EVR(real 1) XForm2(str) REPLACE *]
		
	* parse string in g() and c() 
	if "`generat'" ~= "" {
		local wc : word count `generat'
		if `wc' ~= 2 {
			di in red "exactly TWO variables required in generate()"
			exit 198
		}
		tokenize `generat'
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

	local old_N = _N
	if "`constant'" ~= "" {
		local wc : word count `constant'
		if `wc' >= 3 {
			di in red "max TWO arguments allowed in constant()"
			exit 198
		}
		tokenize "`constant'"
		args stat p
		* confirm names `stat'   /* Stata 7 */
		confirm existence `stat'
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
	if "`connect'" ~= "" {
		local connect "connect(`connect')"
	}
	if "`symbol'" ~= "" {
		local symbol "symbol(`symbol')"
	}    
	if "`add'" ~= "" {                              
		if "`connect'" == "" {
			local connect "connect(ll)"
		}
		if "`symbol'" == "" {
			local symbol "symbol(..)"
		}     
	}
	else {
		if "`connect'" == "" {
			local connect "connect(l)"
		}
        	if "`symbol'" == "" {
			local symbol "symbol(.)"
		}    
	} 
	if "`saving'" ~= "" {
		local saving "saving(`saving')"
	} 
	set textsize 125
	if "`t1title'" == "" {
		local t1title " "
	}        
	if "`t2title'" == "" {
		local t2title " "
	}

	* check for errors
	if `level' < 10 | `level' > 99 {
		di in red `"level(`level') invalid"'
		di in blue "level() must be an integer between 10 and 99"
		exit 198
	}
	if `npoints' < 20 | `npoints' > 9999 {
		di in red `"npoints(`npoints') invalid"'
		di in blue "npoints() must be an integer between 20 and 9999"
		exit 198
	}
	if `evr' < 0 | `evr' > 10^36 {
		di in red `"evr(`evr') invalid"' 
		di in blue "evr() must be a floating-point number between " /*
		*/ "0 and 10^36"
		exit 198
	}
	if "`means'" ~= "" & "`coefs'" ~= "" {
		di in red "may not specify both means and coefs"
		exit 198
	} 
	if "`yform'" ~= "" & `"`yform2'"' ~= "" { 
		di in error "may not specify both yform and yform()"
		exit 198  
	}
	if `"`yform2'"' ~= "" {
		capt local tmp : display `yform2' 1
		if _rc {
			* di as err `"invalid %fmt in yform(`yform2')"'
			di in red `"invalid %fmt in yform(`yform2')"'
			exit 120
		}
	}
	if "`xform'" ~= "" & `"`xform2'"' ~= "" { 
		di in error "may not specify both xform and xform()"
		exit 198  
	}
	if `"`xform2'"' ~= "" {
		capt local tmp : display `xform2' 1
		if _rc {
			* di as err `"invalid %fmt in xform(`xform2')"'
			di in red `"invalid %fmt in xform(`xform2')"'
			exit 120
		}
	} 
	if "`constant'" == "sd" & `level' ~= $S_level {     
		di in red "may not specify both constant(sd) and level()"
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
	if "`generat'" ~= "" {
		tokenize `generat'
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

	* set centering-specific defaults, and calculate basic ingredients
	if "`coefs'" == "coefs" {
		if "`e(cmd)'" ~= "regress" {
			di in red "ellip ..., coefs must be used after regress"
			exit 198
		}
		if "`x'" == "" {                                    
			local x "_cons"                                 
		}
		else {                                       
			local x "`2'" 
			if "`e(depvar)'" == "`x'" {
				di in red "`e(depvar)' is not independent variable"
				exit 111
			}
		}
		if "`l1title'" == "" {
			local l1title "Estimated `y'"
		}
		if "`b2title'" == "" {
			local b2title "Estimated `x'"
		}
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
		if "`l1title'" == "" {
			local l1title "`y'"
		}
		if "`b2title'" == "" {
			local b2title "`x'"
		}
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
	if "`generat'" == "" {
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
	if `"`yform2'"' ~= "" {      
		format `ylist' `yform2'   
	}
	else format `ylist' %9.0g /* includes yf */
	if `"`xform2'"' ~= "" {
		format `xlist' `xform2'
	}
	else format `xlist' %9.0g /* includes xf */

	* graph ellipse
	if "`generat'" ~= "" & "`add'" ~= "" & "`pool'" ~= "-1" {
		* retrieve tmp dataset, and create fractionally pooled datasets
		use "`tmp'", clear
		local i = 0                        
		while `i' <= `pool' {
			restore, preserve /* N >= 400 */
			qui gen double `iwt' = 1 if `touse'==1
			qui replace `iwt' = [`i']/`pool' if `touse'==0
			qui reg `e(depvar)' `varlist' [iw=`iwt'], /*
			*/ level(`level') noheader
			qui gen `tmpy' = `ybar'                      
			qui gen `tmpx' = `xbar'
			qui keep `iwt' `tmpy' `tmpx'
			qui keep in l/l       
			tempfile wt`i'
			qui save "`wt`i''" 
			local i = `i' + 1 
		}

		* append into one file which contains the locus curve
		use "`wt0'", clear
		local i = 1 
		while `i' <= `pool' { 
			append using "`wt`i''"
			local i = `i' + 1
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
		di in gr "The Fractionally Pooled Estimates"
		di in gr "(i.e., the dots in the locus curve):"
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
			gra `ylist' `xlist', `connect' `symbol'  /*
			*/ t1("`t1title'") t2("`t2title'")  /*
			*/ b2("`b2title'") l1("`l1title'") `saving' `options'
		}
	}

	* make sure that dataset is not damaged
	if "`generat'" ~= "" & "`add'" ~= "" {
		use "`new'", clear
	}

	* all went well, keep any generated vars 
	if "`generat'" ~= "" {
		if _N > `old_N' {
			di in blu "obs was `old_N', now " _N
		}
		restore, not
	}
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
		di in red "pool() must be used with add()"
		exit 198
	}
	if "`if'" == "" & "`in'" == "" {
		di in red "must use pool() with [if exp] or [in range]"
		exit 198
	} 
	if "`graph'" == "" {
		di in red "may not specify both nograph and pool()"
		exit 198
	}
	if `pool' < 1 | `pool' > 100 {
		di in red `"pool(`pool') invalid"'
		di in blue "pool() must be an integer between 1 and 100"
		exit 198
	}
	capture confirm new variable _merge
	if _rc ~= 0 {
		di in red "drop _merge before running ellip with pool()"
		exit _rc
	}
end

program define DoCons, rclass	/* returns r(c) */
	args p n level stat coefs
	tempname Fadj F c Chi T2
	local means_d `"("`stat'" == "" & "`coefs'" ~= "coefs")"'
	local coefs_d `"("`stat'" == "" & "`coefs'" == "coefs")"'
	if "`stat'" ~= "sd" {
		if "`p'" == "" {
			local p "2"
		}
		else {
			local p "`p'"
		}
	}

	if "`stat'" == "fadj" {
		scalar `Fadj' = invfprob(2,(`n'-`p'),(100-`level')/100)
		ret scalar c = (2 * `Fadj')
	}
	else if "`stat'" == "f" | `coefs_d' {
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		ret scalar c = (2 * `F')
	}
	else if "`stat'" == "chisq" {
		ret scalar c = invchi(`p',(100-`level')/100) /* v6 */
	}
	else if "`stat'" == "chisqn" {         
		scalar `Chi' = invchi(`p',(100-`level')/100) /* v6 */
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
	else if "`stat'" == "sd" | `means_d' {         
		tempname c
		if "`p'" == "" {
			ret scalar c = 4	/* overall default */
		}
		else {
			ret scalar c = (`p')^2
		}
	}
end
exit

HISTORY
1.3.0 Anders Alexandersson 16jan2003                    SSC Archive 
       - ellip7 for Stata 7; see ellip7.ado and ellip7.hlp
1.2.0 Anders Alexandersson 16jan2003                    SSC Archive
       - fixes several minor bugs such as some r() in 1.1.0  
       - is tested to reproduce 20+ published confidence ellipses
       - allows more options in c()
       - uses more modular code and calls -graph- less times
       - ellip6 replaces version 1.1.0 with same requirements
1.1.0 Anders Alexandersson 12nov2001                    SSC Archive
       - allows centering around means and more types of ellipses
       - requires Stata 6, gphdt for pool()
       - version 1.0.0 renamed into ellip5.ado
1.0.0 Anders Alexandersson 7aug1998                     STB-46: gr32
       - graphs confidence ellipses around regression coefficients
       - requires Stata 5, gphdt for pool(), parsoptp
