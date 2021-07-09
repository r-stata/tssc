*! version 2.0.0  26apr2004 Anders Alexandersson 
program ellip, rclass sortpreserve
	version 8.2
	if _caller() < 8 {
		ellip7 `0'	// ellip7 is on SSC
		exit
	}
	syntax varlist(min=1 max=2 numeric)			///
		[if] [in] [,					///
		noGraph						///
		Generate(namelist min=2 max=2 local)		///
		REPLACE						///
		MEANS						///
		COEFS						///
		Level(int $S_level)				///
		Constant(string)				///
		EVR(real 1)					///
		From(numlist min=1 max=1 >=0 <=6.28318530718)	///
 		To(numlist   min=1 max=1 >=0 <=6.28318530718)	///
		Npoints(int 400)				///
		Pool(int -1)					///
		DIAMeter(real 1234567)				///
		OVERlay						///
		TOTAL						///
		FORMULA(namelist min=1 max=1)			///
		*						///
	]

	// parse graph options
	_get_gropts , graphopts(`options')			///
		grbyable total missing				///
		getbyallowed(TItle SUBTItle legend note)	///
		getallowed(dlopts plopts pcopts plot tlabel)
	local by "`s(varlist)'"
	local bytotal "`s(total)'"
	local bymissing "`s(missing)'"
	local bytitle `"`s(by_title)'"'
	local bysubtitle `"`s(by_subtitle)'"'
	local bynote `"`s(by_note)'"'			
	local bylegend `"`s(by_legend)'"'
	local byopts `"`bytotal' `s(byopts)'"'
	local dlopts `"`s(dlopts)'"'		// line_option in diameter()
	local plopts `"`s(plopts)'"'		// line_option in pool()
	local pcopts `"`s(pcopts)'"'		// connect_option in pool()
	local plot `"`s(plot)'"'		// plot(plot)
	local tlabel `"`s(tlabel)'"'		// label for total
	local options `"`s(graphopts)'"'
	_check4gropts dlopts, opt(`dlopts')	// dlopts, plopts, pcopts
	_check4gropts plopts, opt(`plopts')	// do not allow the options
	_check4gropts pcopts, opt(`pcopts')	// by() name() saving()
	
	// identify the sample
	marksample touse, strok		
	capture _nobs `touse', min(3)
	local N = r(N)
	local N0 = _N	 
	if "`bymissing'" == "" {
		markout `touse' `by', strok
	}
	
	// parse generate(ynewvar xnewvar), if specified 
	if "`generate'" != "" {
		if "`by'" != "" {	// (cf. option split in -glcurve-)
			di as err "may not combine options generate() and by()"
			exit 198
		}
		tokenize `generate'
		args new1 new2
		if "`replace'" != "" {
			capture drop `new1' `new2'
		}
		confirm name `new1'
		confirm new var `new1'
		confirm name `new2'
		confirm new var `new2'
	}	
	
	// temporary names, variables, files
	tempname m c grp ybar s_y var_y xbar s_x var_x n r cov_xy X2 X	///
		Fadj F Chi T2 x_a y_a C D m1 m2 lambda1	lambda2 a b	///
		min_y max_y min_x max_x xmin_y xmax_y ymin_x ymax_x
	tempvar t yvar xvar iwt y_bp x_bp ybar xbar id byvar
	tempfile main 
	
	// parse constant(stat [p] | m)	
	capture confirm number `constant'
	if _rc != 0 {	
		scalar `m' = .		
		if "`constant'" != "" {	// c(stat [p])
			local wc "wordcount("`constant'")"
			if `wc' >= 3 {
				di as err "max TWO arguments allowed in constant()"
				exit 198
			}
			tokenize "`constant'"
			args stat p
			if "`stat'" != "" {
				StatParse, `stat'
			}			
			if "`p'" != "" {
				confirm number `p'
				if `p' < 0 | `p' >= (`N' - 2) {
					di as err "`p' is an invalid # in c(statname [#])"
					exit 198
				}
			}	
		}			
	}
	else {
		scalar `m' = `constant'	
	}
	FormParse, `formula'	
	local formula "`s(formula)'"	// acosr rather than theta is default
	
	// error check remaining options
	tokenize "`varlist'" 
	args y x
	if "`coefs'" == "coefs" {
		if "`x'" == "" {
			local x "_cons"
		}
		if "`means'" == "means" {
			di as err "may not combine options coefs and means"
			exit 198
		}
		if "`by'" != "" {
			di as err "may not combine options coefs and by()"
			exit 198
		}
		if "`e(cmd)'" != "regress" {
			di as err "last estimation command must be regress"
			exit 498
		}
		if "`e(depvar)'" == "`y'" | "`e(depvar)'" == "`x'" {
			di as err "`e(depvar)' is not independent variable"
			exit 198
		}
		// get rhs-variables excluding _cons
		mat `b' = e(b)
		local rhs : colnames(`b')
		local rhs : subinstr local rhs "_cons" "", word			
	}
	else {
		if "`x'" == "" {
			di as err "option means (default) requires 2 variables"
			exit 198
		}	
	}
	if "`pool'" == "-1" {	// pool() is missing
		if `"`plopts'"' != "" {
			di as err "option plopts() requires option pool()"
			exit 198
		}
		if `"`pcopts'"' != "" {
			di as err "option pcopts() requires option pool()"
			exit 198
		}
	}
	else {			// pool is specified
		if "`if'" == "" & "`in'" == "" {
			di as err "option pool() requires [if exp] or [in range]"
			exit 198
		}
		if "`coefs'" != "coefs" {
			di as err "option pool() requires option coefs"
			exit 198
		}
		if `pool' < 1 | `pool' > 100 {
			di as err `"pool(`pool') is invalid"'
			di as txt "pool() must be an integer between 1 and 100"
			exit 198
		}
		capture confirm variable _merge
		if _rc == 0 {
			di as err "drop _merge before using option pool()"
			exit 110
		}	
		if "`diameter'" != "1234567" {
			di as err "may not combine options pool() and diameter()"
			exit 198
		}				
		if "`evr'" != "1" {
			di as err "may not combine options pool() and evr()"
			exit 198
		}										
	}
	if `level' < 10 | `level' > 99 {
		di as err `"level(`level') is invalid"'
		di as txt "level() must be an integer between 10 and 99"
		exit 198
	}
	if "`overlay'" != "" {
		if "`by'" == "" {
			di as err "option overlay requires option by()"
			exit 198
		}
		if "`bytotal'" != "" {
			di as err "may not combine options overlay and by(, total)"
			exit 198
		}	
	}
	if "`stat'" == "sd" & `level' != $S_level {     
		di as err "may not specify both constant(sd) and level(`level')"
		exit 198
	}
	if "`from'" == "" {
		local from = 0 
	}
	if "`to'" == "" {
		tempname to
		scalar `to' = 2 * _pi 
	}
	if `to' == `from' {
		di as err `"to(`to') is invalid"'
		di as txt `"to(`to') must differ from from(`from')"'
		exit 198
	}
	if `npoints' < 20 {
		di as err `"npoints(`npoints') is invalid"'
		di as txt "ellipse requires at least 20 ellipse points"
		exit 198
	}
	if (`evr' < 0) | (`evr' > 99999) {
		di as err `"evr(`evr') is invalid"' 
		di as txt "evr() must be a floating-point " ///
			"number between 0 and 99999"
		exit 198
	}
	if "`diameter'" == "1234567" {		// diameter() is missing
		if "`dlopts'" != "" {
			di as err "option dlopts() requires option diameter()"
			exit 198
		}
	}
	else {					// diameter() is specified
		if `diameter' < -999999 | `diameter' > 999999 {
			di as err `"diameter(`diameter') is invalid"'
			di as txt "diameter() must be a floating-point " ///
				"number between -999999 and 999999"
			exit 198
		}	
	}	
	if "`total'" != "" {
		if "`by'" == "" {
			di as err "option total requires option by()"
			exit 198
		}
	}

	// parsing is done
	preserve 
	if "`bymissing'" == "" {
		markout `touse' `by', strok
	}

	// generate grouping variable		 	
	if "`by'" != "" {
		if "`total'" != "" {
			foreach var of local by {
				qui egen `byvar' = group(`var'), label lname(`var')
				drop `var'
				rename `byvar' `var'
			}
			qui save  `"`main'"', replace
			foreach var of local by {
				sum `var' if `touse', mean
				local totnum = "`=r(max)+1'"
				qui replace `var' = `totnum' if `touse'
				local totlabel : value label `var'
				if "`totlabel'" == "" {
					local totlabel "total"
					label values `var' `totlabel'
				}
				if `"`tlabel'"' == "" {
					local tlabel "Total"
				}				
				label define `totlabel' `totnum' `"`tlabel'"', modify
			}
			qui append using `"`main'"'
		}		
		local wc "wordcount("`by'")"
		sort `touse' `by', stable
		qui by `touse' `by': gen int `grp'=1 if _n==1 & `touse'
		qui replace `grp'=sum(`grp') if `touse'
		local grpn = `grp'[_N]
		if `grpn' < 2 {
			di as err "by() variable takes on only one value"
			exit 198
		}			
	}
	else {
		local grpn=1
		qui gen `grp'=1
	}
	qui gen double `yvar' = .
	qui gen double `xvar' = .	
	qui save `"`main'"', replace
	 	
	// calculate ellipse datasets for each group
	forval i = 1/`grpn' {
		qui use  `"`main'"' if `grp' == `i', clear	
		if "`by'" != "" {
			capture _nobs `grp' if `touse', min(3)
			if _rc != 0 {
				di as err "each combination of varlist" ///
				" in by() must have 3 or more observations"
				contract `by'
				list
				exit 2001
			}			
		}
		
		// calculate basic ingredients	
		qui range `t' `from' `to' `npoints'
		set type double						
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
		if `r'==. {
			di as err "The correlation coefficient could not " ///
			"be calculated. (r==.)"	
			exit 459
		}	
		scalar `cov_xy' = `r' * `s_x' * `s_y'
				
		// calculate c, then calculate amplitudes of arcs x and y
		if `m' == . {			
			DoCons "`p'" `n' `level' "`stat'" "`coefs'"
			scalar `c' = r(c)
		}
		else {
			scalar `c' = `constant' 
		}		

		// calculate scalars
		tempvar n1 n2 n1_ey n2_ey m_y m_x
		tempname amin_y amax_y amin_x amax_x bmin_y bmax_y bmin_x bmax_x
		tempname n1_y n1_x n2_y n2_x n1max_y n1min_x n1max_x 
		tempname n2min_y n2min_x n2max_x Y2 Y a_evr C A B theta
		tempname Z2 Z mmax_y mmin_y mmax_x mmin_x e2 R L1 L2
		
		// McCartin(2003, 10): best (m1) and worst (m2) evr-reg slope	
		scalar `A' = `var_y' - `evr' * `var_x'
		scalar `m1' = (`A' + sqrt((`A')^2 + 4*`evr' * (`cov_xy')^2)) ///
			/ (2 * `cov_xy')
		scalar `m2'      = - `evr' / `m1'	

		// Batschelet (1981, 256-257, 264): eigenvalues of S and theta.
		// Longer than Sokal and Rohl (1995, 589) but also gives theta.
		scalar `A' = `var_y'	// reuse tempvar A
		scalar `B' = -`cov_xy'
		scalar `C' = `var_x'
		scalar `D' = (1 - (`r')^2) * `A' * `C' * `c'
		scalar `R' = ((`A' - `C')^2 + 4 * (`B')^2)^.5
		scalar `L1' = ((`A' + `C' - `R') / (2 * `D'))	// of S^-1
		scalar `L2' = ((`A' + `C' + `R') / (2 * `D'))	// of S^-1	
		scalar `lambda1' = 1 / (`L1' * `c')		// of S
		scalar `lambda2' = 1 / (`L2' * `c') 		// of S
		scalar `theta' = atan((2 * `B') / (`A' - `C' - `R')) //

		// Batschelet (1981, 253): intersection of line-ellipse		
		scalar `X2' = `D' * (`A' + 2*`B'*`m1' + `C'*(`m1')^2)^-1
		scalar `X' = (abs(`X2'))^.5	// for m1-ellipse intersections
		scalar `Y2' = `D' * (`A' + 2*`B'*`m2' + `C'*(`m2')^2)^-1
		scalar `Y' = (abs(`Y2'))^.5	// for m2-ellipse intersections

		if "`diameter'" != "1234567" {	// diameter() is specified
			scalar `m' = `diameter'
			scalar `Z2' = `D' * (`A' + 2*`B'*`m' + `C'*(`m')^2)^-1
			scalar `Z' = (abs(`Z2'))^.5	// for m intersections
			scalar `mmax_y' = `ybar' + abs(`m' * `Z')
			scalar `mmin_y' = `ybar' - abs(`m' * `Z')
			scalar `mmax_x' = `xbar' + `Z'
			scalar `mmin_x' = `xbar' - `Z'
			qui gen `m_y' = `mmin_y'			// (1)
			qui replace `m_y' = `mmax_y' in 2/2		// (2)
			if `m' >= 0 {			// non-negative line
				qui gen `m_x' = `mmin_x'		// (1)
				qui replace `m_x' = `mmax_x' in 2/2	// (2)
			}
			else {				// negative line
				qui gen `m_x' = `mmax_x'		// (1)
				qui replace `m_x' = `mmin_x' in 2/2	// (2)
			} 
			local diameter`i' "(line `m_y' `m_x', `dlopts')"
			local diametergraph "`diametergraph' `diameter`i'' "				
			ret scalar mmax_y = `ybar' + abs(`m' * `Z')
			ret scalar mmin_y = `ybar' - abs(`m' * `Z')
			ret scalar mmax_x = `xbar' + `Z'
			ret scalar mmin_x = `xbar' - `Z'
		}

		scalar `a_evr' = sqrt((`X')^2 + (`m1' * `X')^2) // Pythagorean
		scalar `n' = -1 / `m2'
		scalar `amax_y' = `ybar' + abs(`m1' * `X')
		scalar `amin_y' = `ybar' - abs(`m1' * `X')
		scalar `amax_x' = `xbar' + `X'
		scalar `amin_x' = `xbar' - `X'			
		scalar `b' = (1 / `lambda2')^-.5 * sqrt(`c')	// l of semi-minor
		scalar `a' = (1 / `lambda1')^-.5 * (`c')^.5	// l of semi-major
		scalar `e2' = 1 - ((2*`b') / (2*`a'))^2		// e^2	
		
		// calculate ellipse
		if "`formula'" == "theta" {
			qui replace `xvar' = `xbar' + `a' * cos(`theta') * ///
				cos(`t') - `b' * sin(`theta') * sin(`t')
			qui replace `yvar' = `ybar' + `a' * sin(`theta') * ///
				cos(`t') + `b' * cos(`theta') * sin(`t')
		}
		else {
			scalar `x_a' = `s_x' * sqrt(`c') 
			scalar `y_a' = `s_y' * sqrt(`c')		 
			qui replace `xvar' = `xbar' + `x_a' * cos(`t')
			qui replace `yvar' = `ybar' + `y_a' * cos(`t' + acos(`r'))
		}
			
		// get rid of any spurious lines between each ellipse
		if "`bytotal'" == "total" {
			qui expand 2 in l
			qui replace `yvar' = . in l/l
			qui replace `xvar' = . in l/l
		}
		
		// specify end points of ellipse
		qui summarize `yvar'		
		scalar `min_y' = r(min)
		scalar `max_y' = r(max) 		
		qui summarize `xvar'
		scalar `min_x' = r(min)
		scalar `max_x' = r(max)		
		qui summarize `yvar' if `xvar' == `min_x'
		scalar `xmin_y' = r(mean) // approx. amin_y if evr(large)
		qui summarize `yvar' if `xvar' == `max_x'
		scalar `xmax_y' = r(mean) // approx. amax_y if evr(large)
		qui summarize `xvar' if `yvar' == `min_y'
		scalar `ymin_x' = r(mean) // approx. amin_x if evr(0) 
		qui summarize `xvar' if `yvar' == `max_y'
		scalar `ymax_x' = r(mean) // approx. amax_x if evr(0)	
	
		// generate the normal lines n1 and n2 in intercept-slope form
		if `n' > 0 {	
			qui gen `n1' = `amin_y' + `n' * (`xvar' - `amin_x')
			qui gen `n2' = `amax_y' - `n' * (`amax_x' - `xvar')
		}
		if `n' < 0 {
			qui gen `n1' = `amin_y' + `n' * (`xvar' - `amax_x')
			qui gen `n2' = `amax_y' + `n' * (`xvar' - `amin_x')
		}
	
		// find y-value of 2nd intersection for n1
		qui gen `n1_ey' = (`n1' - `yvar')^2 ///
			if `yvar' > `amin_y' & `n1' > `amin_y'
		qui summarize `n1_ey'
		scalar `n1_y' = r(min)	
		qui summarize `yvar' if `n1_ey' == `n1_y' 
		scalar `n1max_y' = r(min)
	
		// find y-value of 2nd intersection for n2	
		qui gen `n2_ey' = (`n2' - `yvar')^2 ///
			if `yvar' < `amax_y' & `n2' < `amax_y'
		qui summarize `n2_ey'
		scalar `n2_y' = r(min)
		qui summarize `yvar' if `n2_ey' == `n2_y'
		scalar `n2min_y' = r(min)
	
		// find corresponding x-value for 2nd intersections
		qui summarize `xvar' if `yvar' == `n1max_y'
		if `r' > 0 {	
			scalar `n1max_x' = r(min)
			qui summarize `xvar' if `yvar' == `n2min_y'
			scalar `n2min_x' = r(min)
		}
		if `r' < 0 {
			scalar `n1min_x' = r(min)
			qui summarize `xvar' if `yvar' == `n2min_y'
			scalar `n2max_x' = r(min)
		}
				
		// create variable labels (for legend)
		if "`generate'" != "" {
			label var `yvar' "`new1'"
			label var `xvar' "`new2'"		
		}
		else {
			label var `yvar' "Confidence ellipse"
		}
		if "`by'" != "" {
			tempvar yvar`i' xvar`i'
			qui gen `yvar`i'' = `yvar'
			local j = 0
			foreach var of local by {
				qui replace `var' = `var'[1]
				if "`overlay'" != "" {
					cap confirm numeric var `var'
					if _rc {		// string variable
						local lbl`i' `"`=substr(`var'[`i'],1,20)'"'
					}
					else {			// numeric variable
						sum `var' if `touse', mean
						local lbl`i' `"`: label (`var') `=r(min)''"' 
					}
					local j = `j' + 1
					if `wc' == 1 | `j' == `wc' {
						local stlbl`i' "`stlbl`i''`lbl`i'' "
					}
					else {			// insert ","	
						local stlbl`i' "`stlbl`i''`lbl`i'', "
					}
				}
			}
			if "`overlay'" != "" {
				label var `yvar`i'' "`stlbl`i''"
				local stargs "`stargs' `yvar`i''"
			}
			tempfile grp`i'	
			qui save "`grp`i''"
		}				// end of by
	} 					// end of forval loop
	
	// create one dataset with the confidence ellipses
	if "`by'" != "" {
		qui use "`grp1'", clear	
		forval i = 2/`grpn' {
			qui append using "`grp`i''"
		}
	}	 	
	merge using `"`main'"', nolabel
	drop _merge

	// create macro for locus curve and full ellipse
	if "`pool'" != "-1" {
		label var `yvar' "best subset ellipse, b"
		local poolobs = (`pool'+1) // `=...'	
		qui gen double `iwt' = 1 if `touse' 
		qui gen double `y_bp' = .
		qui gen double `x_bp' = .
		tempvar ind est
		qui range `ind' 0 1 `poolobs'	
		_estimates hold `est', copy
		// [how-to allow estopts(regress_options) as in twoway lfit/qfit?]						
		forvalues i = 1/`poolobs' {
			qui replace `iwt' = `ind'[`i'] if !`touse' 			
			qui reg `e(depvar)' `rhs' [iw = `iwt'], ///
				level(`level') noheader
			matrix `b' = e(b)
			qui replace `y_bp' = `b'[1,1] in `i'/`i'
			qui replace `x_bp' = `b'[1,2] in `i'/`i'
			local i = `i' + 1
		}
		
		// create full ellipse [use overlay code for grp 2?]	
		scalar `n' = e(N)
		qui cor, _coef	// no "if touse"
		scalar `r' = r(rho)
		if `m' == . {	// c(#) was not specified
			DoCons "`p'" `n' `level' "`stat'" "`coefs'"
			scalar `c' = r(c)
		}
		else {		// c(#) was specified			
			scalar `c' = `constant'		
		}		
		scalar `x_a' = `s_x' * sqrt(`c')
		scalar `y_a' = `s_y' * sqrt(`c')
		tempvar xvar_bp yvar_bp
		qui gen `xvar_bp' = `xbar' + `x_a' * cos(`t')
		qui gen `yvar_bp' = `ybar' + `y_a' * cos(`t' + acos(`r'))

		local Poolgraph 		///
		(connected `y_bp' `x_bp', 	///
			yvarlabel("fractionally pooled curve") ///
			`pcopts')		/// connect_options in pool
		(line `yvar_bp' `xvar_bp',	///
			yvarlabel("pooled ellipse, bp") ///
			`plopts')		//  line_options in pool
		tempname IWT YVAR XVAR
		mkmat `ind', matrix(`IWT') nomiss
		mkmat `y_bp', matrix(`YVAR') nomiss		
		mkmat `x_bp', matrix(`XVAR') nomiss 
		mat colnames `IWT' = iwt
		mat colnames `YVAR' = "`y'"
		mat colnames `XVAR' = "`x'"
		ret matrix IWT `IWT'
		ret matrix YVAR `YVAR'
		ret matrix XVAR `XVAR'
	}

	// graph ellipse (if required)
	if "`graph'" == "" { 
		if `"`bytitle'"' == "" {
			local title title("Confidence ellipse")
		} 
		if `"`bysubtitle'"' == "" {
			if "`coefs'" != "coefs" {
				local subtitle subtitle("Means centered")
			}
			else local subtitle subtitle("Coefficient centered")
		}
		local yttl : var label `y'
		if `"`yttl'"' == "" {
			local yttl "`y'"
		}	
		if "`coefs'" == "coefs" & "`x'" == "_cons" {
			local xttl "constant"
		}
		else {
			local xttl : var label `x'
		}
		if `"`xttl'"' == "" {
			local xttl "`x'"
		}
		if "`coefs'" == "coefs" {
			local yttl "Estimated `yttl'"
			local xttl "Estimated `xttl'"
		}
		if `"`bynote'"' == "" {
			local cc = string(`c',"%8.4f")
			local note note(`"boundary constant = `=`cc'' "')
		}
		if `"`bylegend'"' == ""  &  `"`plot'"' == "" & "`pool'" == "-1" {
			local legend legend(nodraw)
		}
		
		// specified titles
		local titles 			///
			`title'			///
			`subtitle'		///
			`note'			///
			`legend'
		if `"`by'"' != "" {		
			if "`overlay'" == "" {	// overlay is not specified	
				local byopt by(	///
				`by',		///
				`bytitle'	///
				`bysubtitle'	///
				`bynote'	///
				`bylegend'	///
				`titles'	///
				`bymissing'	///
				`byopts'	///
				)
				local titles		
			}
			else {			// overlay is specified		
				local j = 0
				foreach var of local by {				
					local j = `j' + 1						
					local varlbl`j' : variable label `var'
					if "`varlbl`j''" == "" {
						local varlbl`j' "`var'"
					}
					if `wc' == 1 | `j' == `wc' {
						local stvarlbl "`stvarlbl'`varlbl`j''"
					}
					else {	// insert a ", "			
						local stvarlbl "`stvarlbl'`varlbl`j'', "
					}
				}
				if `"`bynote'"' == "" {
					local note "Graph overlaid by `stvarlbl'"
				}	
				local yvar "`stargs'"	
				local byopt ""	
			}
		}
		graph twoway				///
		(line `yvar' `xvar',			///
			`titles'			///
			ytitle(`"`yttl'"')		///
			xtitle(`"`xttl'"')		///
			`byopt'				///
			`options'			///
			cmissing(n)			/// separate ellipses
		)					///
		`Poolgraph' 				///
		`diametergraph'				/// reference line(s)
		|| `plot'
	}
	
	// save results	as scalars in r()
	if `r' > 0 {
		ret scalar n1max_x  = `n1max_x'		// max_x of n1
		ret scalar n2min_x  = `n2min_x'		// min_x of n2
	}
	if `r' < 0 {
		ret scalar n1min_x  = `n1min_x'		// min_x of n1
		ret scalar n2max_x  = `n2max_x'		// max_x of n2	
	}
	ret scalar n1max_y  = `n1max_y'			// max_y of n1
	ret scalar n2min_y  = `n2min_y'			// min_y of n2
	ret scalar r       = `r'		// correlation coefficient
	ret scalar e2 = `e2'			// eccentricity squared	
	ret scalar theta = `theta'		// rotation angle
	ret scalar c       = `c'		// boundary constant
	ret scalar b = (1 / `lambda2')^-.5 * sqrt(`c')	// l of semi-minor
	ret scalar a_evr = `a_evr'		// evr l of semi-major
	ret scalar a = (1 / `lambda1')^-.5 * (`c')^.5	// l of semi-major
	ret scalar n = `n'			// slope of the normal
	ret scalar evr = `evr'			// error variance ratio
	ret scalar m2      = `m2'		// slope of minor axis
	ret scalar m1      = `m1'		// slope of major axis
	ret scalar lambda2 = `lambda2'		// 2nd eigenvalue of inverse V
	ret scalar lambda1 = `lambda1'		// 1st eigenvalue of inverse V
	ret scalar s_y     = `s_y'			// standard error of y
	ret scalar bmax_y = `ybar' + abs(`m2' * `Y')	// y given max of b
	ret scalar bmin_y = `ybar' - abs(`m2' * `Y')	// y given min of b
	ret scalar amax_y = `ybar' + abs(`m1' * `X')	// y given max of a
	ret scalar amin_y = `ybar' - abs(`m1' * `X')	// y given min of a
	ret scalar xmax_y = `xmax_y'			// y given max of x	
	ret scalar xmin_y = `xmin_y'			// y given min of x
	ret scalar max_y = `max_y'			// max of y	
	ret scalar min_y = `min_y'			// min of y
	ret scalar mean_y  = `ybar'			// mean of y
	ret scalar s_x     = `s_x'		// standard error of x
	ret scalar bmax_x = `xbar' + `Y'	// x given max of b
	ret scalar bmin_x = `xbar' - `Y'	// x given min of b
	ret scalar amax_x = `xbar' + `X'	// x given max of b
	ret scalar amin_x = `xbar' - `X'	// x given min of b
	ret scalar ymax_x = `ymax_x'		// x given max of y
	ret scalar ymin_x = `ymin_x'		// x given min of y	
	ret scalar max_x = `max_x'		// max of x
	ret scalar min_x = `min_x'		// min of x	
	ret scalar mean_x  = `xbar'		// mean of x (appears first)

	// all went well, keep any generated vars
	if "`generate'" != "" {	
		rename `yvar' `new1'
		rename `xvar' `new2'
		restore, not
		if _N > `N0' {
			local N1 = _N
			di as txt "caution: _N was " as res `N0' ///
			   as txt ", _N now is " as res `N1'
		}
	} 	
	if "`pool'" != "-1" {
		_estimates unhold `est' // restore the original estimates
	}			
end

program DoCons, rclass	/* returns r(c) */
	args p n level stat coefs
	tempname Fadj F c Chi T2
	* calculate p
	local means_d `"("`stat'" == "" & "`coefs'" != "coefs")"'
	local coefs_d `"("`stat'" == "" & "`coefs'" == "coefs")"'
	if "`stat'" == "sd" | (`means_d') {
		if "`p'" == "" { 
				local p = "4"
		}
		else {
				local p = (`p')^2
		}
	}
	else {
		if "`p'" == "" {
				local p = "2"
		}
		else {
				local p = "`p'"
		}
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
	else if "`stat'" == "f_scheffe" {
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		ret scalar c = (`p' * `F')
	}
	else if "`stat'" == "chi2" {
		ret scalar c = invchi2tail(`p',(100-`level')/100)
	}
	else if "`stat'" == "chi2_n" {         
		scalar `Chi' = invchi2tail(`p',(100-`level')/100)
		ret scalar c = (`Chi' / `n')
	}
	else if "`stat'" == "pchi2_n" {         
		scalar `Chi' = invchi2tail(`p',(100-`level')/100)
		ret scalar c = (`Chi' / `n') * (`n' + 1)
	}	
	else if "`stat'" == "t2" {         
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		scalar `T2' = `p' * (`n'-1) / (`n'-`p') * `F'
		ret scalar c = (`T2' / `n')
	}
	else if "`stat'" == "pt2" {         
		scalar `F' = invfprob(`p',(`n'-`p'),(100-`level')/100)
		scalar `T2' = `p' * (`n'-1) / (`n'-`p') * `F'
		ret scalar c = (`T2' * (`n' + 1) / `n')
	}
	else if "`stat'" == "sd" | (`means_d') {
		ret scalar c = `p'
	}	
end

program FormParse, sclass
	sret clear
	syntax, [ACOSR THETA]
	if "`acosr'`theta'" == "" {
		sret local formula "acosr"
	}
	else {
		sret local formula "`acosr'`theta'"
	}
end


program StatParse
	syntax, [SD T2 PT2 CHI2 CHI2_n PCHI2_n F FADJ F_scheffe]
end

exit	



HISTORY
2.0.0 Anders Alexandersson ddmmm2004			SJ
	- ellip.ado updated and improved for Stata 8
1.3.1 Anders Alexandersson 10feb2003			SSC Archive
	- Bug fixes of ellip7.ado:
	1. coefs by()- would give the results for -means by()-;
	this is fixed in ellip7 (N/A for ellip6 and ellip5)
	2. -coefs by()- failed to return results; this is fixed 
	3. -pool()- would unly use 2 independent variables in reg;
	this is fixed in ellip7 but not in ellip6 (no bug in ellip5)
	- replaces version 1.3.0 with same requirements
1.3.0 Anders Alexandersson 16jan2003			(outdated)
	- ellip7.ado
	- new nograph and c(sq) option; fixed by() option for means
	- requires Stata 7, gphdt for pool
	- version 1.2.0 renamed into ellip6.ado
1.2.0 Anders Alexandersson 16jan2003                    SSC Archive
	- fixes several minor bugs such as some r() in 1.1.0  
	- is tested to reproduce 20+ published confidence ellipses
	- allows more options in c()
	- uses more modular code and calls -graph- less times
	- replaces version 1.1.0 with same requirements
	- version 1.0.0 renamed into ellip5.ado (20021128)
1.1.0 Anders Alexandersson 11nov2001                    (outdated)
	- allows centering around means and more types of ellipses
	- requires Stata 6, gphdt for pool()
	- version 1.0.0 renamed into ellip_5.ado
1.0.0 Anders Alexandersson 7aug1998                     STB-46: gr32	
	- graphs confidence ellipses around regression coefficients
	- requires Stata 5, gphdt for pool(), parsoptp
