*! version 1.0.9 21Feb2018 MLB
* accommodated changes in the names of cut of values in Stata 15
*
* version 1.0.8 21Okt2013 MLB
* fixed df when using factor variables
*
* version 1.0.7 14Okt2013 MLB
* added BIC and AIC
* fixed the saving() option
* fixed the way weights were used
*
* version 1.0.6 03May2013 MLB
* check whether full model is unestimatable due to perfect prediction
*
* version 1.0.5 16Apr2013 MLB
* constraints for baseline in factor variable notation allowed
*
* version 1.0.4 11Mar2013 MLB
* added the saving() option
*
* version 1.0.3 20Feb2013 MLB
* change asl to (k+1)/(B+1) instead of k/B
* base the mcci on the corresponding Beta distribution 
*
* version 1.0.2 10Jan2013 MLB
* disallowed constraints and offsets for the -ologit- model
* cleaned up the -matlist- display
* added the nodots option
*
* version 1.0.1 09Jan2013 MLB
* added the asl, reps, mcci options
*
* version 1.0.0 08Jan2013 MLB
*!
*! subroutines for the Wolfe-Gould test based on:
*!   -omodel- version 1.0.1  26Sep1997  Rory Wolfe and Bill Gould  STB-42 sg76 
*!
*! subroutines for the Brant test based on:
*!   -brant- version 1.6.0 3/29/01 by J. Scott Long and Jeremy Freese

program define oparallel, rclass
	local v = c(version)
	version 11	
	syntax , [score lr wald WOLFEgould brant asl ASL2(string) reps(integer 999)  ///
	BSample mcci MCCI2(numlist min=1 max=1 >=10.00 <=99.99) nodots noisily       ///
	SAving(string) nomatlist ic]
	
	// default is show all test everything
	if "`score'`lr'`wald'`wolfegould'`brant'" == "" {
		local score "score"
		local lr "lr"
		local wald "wald"
		local wolfegould "wolfegould"
		local brant "brant"
	}
	
	// -syntax- by default removes "no" from an option name, so noisily becomes isily.
	if "`isily'" == "" local qui "quietly"
	
	// reps() only makes sense in combination with asl or asl2
	if "`asl'`asl2'" == "" & `reps' != 999 {
		di as err "the reps() option can only be specified in combination with the asl option"
		exit 198
	}
	
	// mcci only makes sense in combination with asl or asl2
	if "`asl'`asl2'" == "" & "`mcci'`mcci2'" != "" {
		di as err "the mcci option can only be specified in combination with the asl option"
		exit 198
	}
	if "`mcci'`mcci2'" != "" {
		if "`mcci2'" == "" {
			local mcci2 = c(level)
		}
		local alph = (100-`mcci2')/200
	}
	
	// nodots only makes sense in combination with asl or asl2
	if "`asl'`asl2'" == "" & "`dots'" != "" {
		di as err "the nodots option can only be specified in combination with the asl option"
		exit 198
	}
	// bsample only makes sense in combination with asl or asl2
	if "`asl'`asl2'" == "" & "`bsample'" != "" {
		di as err "the bsample option can only be specified in combination with the asl option"
		exit 198
	}
	
	// parse asl2 option
	if "`asl2'" != "" {
		local valid "score lr wald wolfe wolfeg wolfego wolfegou wolfegoul wolfegould brant"
		local invalid : list asl2 - valid
		if "`invalid'" != "" {
			local are = cond(`: word count `invalid'' == 1, "is an", "are")
			local s   = cond(`: word count `invalid'' == 1, ""    , "s"  )
			di as result "`nonvalid' as err `are' invalid suboption`s' for the asl() option"
			exit 198
		}
		local test "score" 
		if `: list test in asl2' {
			local aslscore "score"
			if "`score'" == "" {
				local score "score"
			}
		}
		local test "lr" 
		if `: list test in asl2' {
			local asllr "asllr"
			if "`lr'" == "" {
				local lr "lr"
			}
		}
		local test "wald" 
		if `: list test in asl2' {
			local aslwald "wald"
			if "`wald'" == "" {
				local wald "wald"
			}
		}
		local test1 "wolfe"
		local test2 "wolfeg" 
		local test3 "wolfego"
		local test4 "wolfegou"
		local test5 "wolfegoul"
		local test6 "wolfegould"
		if (`: list test1 in asl2') | ///
		   (`: list test2 in asl2') | ///
		   (`: list test3 in asl2') | ///
		   (`: list test4 in asl2') | ///
		   (`: list test5 in asl2') | ///
		   (`: list test6 in asl2') {
			local aslwolfegould "wolfegould"
			if "`wolfegould'" == "" {
				local wolfegould "wolfegould"
			}
		}
		local test "brant" 
		if `: list test in asl2' {
			local aslbrant "brant"
			if "`brant'" == "" {
				local brant "brant"
			}
		}
	}
	
	// parse asl
	if "`asl'" != "" {
		if "`score'" != "" {
			local aslscore "score"
		}
		if "`lr'" != "" {
			local asllr "lr"
		}
		if "`wald'" != "" {
			local aslwald "wald"
		}
		if "`wolfegould'" != "" {
			local aslwolfegould "wolfegould"
		}
		if "`brant'" != "" {
			local aslbrant "brant"
		}
	}
	
	// parse the saving() option
	if "`asl'`asl2'" == "" & "`saving'" != "" {
		di as err "the saving() option can only be specified in combination with the asl option"
		exit 198
	}
	Parsesaving `saving'
	local filename `"`r(filename)'"'
	local replace   "`r(replace)'"
	local double    "`r(double)'"
	local every     "`r(every)'"
	
	// store and recover information from last -ologit- command
	tempname orig
	qui est store `orig'
	
	if "`e(cmd)'" != "ologit" {
		di as err "oparallel can only be used after ologit"
		exit 198
	}
	
	// I don't know how to implement these tests with linear constraints
	chkcns
	
	local y "`e(depvar)'"
	global S_m = `e(k_cat)' // store in global as it will be used in the likelihood evaluator program
	local mm1 = $S_m - 1
	if `mm1' == 1 {
		di as txt "with only two categories in the dependent variable -ologit- does not impose a parallel lines assumption"
		di as txt "therefore, there is nothing to test"
		exit
	}
	
	tempvar touse
	qui gen byte `touse' = e(sample)
	
	// stores the levels of `y' as returned by -ologit- in the matrix e(cat) in global $S_levs
	mata: ologitcat()
	
	// log likelihood and *ic of ologit
	tempname ll_c
	scalar `ll_c' = e(ll)
	if "`ic'" != "" {
		tempname ic_res
		matrix `ic_res' = J(2,3,.)
		matrix rownames `ic_res' = "AIC" "BIC"
		matrix colnames `ic_res' = "ologit" "gologit" "difference"
		
		matrix `ic_res'[1,1] = -2*e(ll) + 2*e(rank)
		matrix `ic_res'[2,1] = -2*e(ll) + e(rank)*ln(e(N))
	}
	
	// coefficients and variable names
	tempname b bx
	matrix `b' = e(b)
	matrix `bx' = `b'[1,"`y':"]
	local x : colnames `bx'
	tempname b0

	local df = (`mm1' - 1)*(`e(rank)' - `mm1')
	
	// only fweights allowed
	local weight "`e(wtype)'"
	local exp "`e(wexp)'"
	if "`weight'" != "" {
		if "`weight'" != "fweight" {
			di as err "`weight' not allowed"
			exit 101
		}
		tempvar wvar 
		qui gen double `wvar' `exp'
		local weight "[`weight'=`wvar']"
	}
	
	// matrix to store results
	tempname results
	
	// matrix of coefficients assuming -ologit- is correct
	forvalues i = 1/`mm1' {
		if `v' >=15{
			matrix `b0' = nullmat(`b0'), `bx', -1*[/]_b[cut`i']
		}
		else{
			matrix `b0' = nullmat(`b0'), `bx', -1*[cut`i']_b[_cons]
		}
		local temp: subinstr local x " " " eq`i':", all
		local coln `"`coln' eq`i':`temp' eq`i':_cons"'
	}
	matrix colnames `b0' = `coln'

	// check whether full model can be estimated
	// compute Wolfe-Gould and Brant statistics
	indep_binaries if `touse' `weight', bx(`bx') y(`y') mm1(`mm1') df(`df') qui(`qui') `wolfegould' `brant'
	if "`wolfegould'" != "" {
		matrix `results' = (r(wg), `df', r(p_wg))
		local rown "`rown' Wolfe_Gould"
		tempname wg p_wg 
		scalar `wg' = r(wg)
		scalar `p_wg' = r(p_wg)
	}
	if "`brant'" != "" {
		matrix `results' = nullmat(`results') \ (r(br), `df', r(p_br))
		local rown "`rown' Brant"	
		tempname br p_br
		scalar `br' = r(br)
		scalar `p_br' = r(p_br)
	}
	
	if "`score'`wald'`lr'`ic'" != "" {
		// build the -ml- command
		local eqs `"(eq1: `y' = `x')"'
		forvalues i = 2/`mm1' {
			local eqs `"`eqs' (eq`i':`x')"'
		}
	}
	
	if "`score'" != "" {
		// for the score test we don't need to maximize, 
		// just to compute the score and hessian under the null hypothesis
		qui ml model lf2 gologit3_lf2 `eqs' if `touse' `weight', init(`b0') iter(0) maximize
		tempname S s p_s
		matrix `S' = e(gradient)*e(V)*e(gradient)'
		scalar `s' = el(`S',1,1)
		scalar `p_s' = chi2tail(`df', `s')
		matrix `results' = nullmat(`results') \ (`s', `df', `p_s')
		local rown "`rown' score"
	}

	if "`lr'`wald'`aic'`bic'" != "" {
		// estimate unconstrained model
		`qui' ml model lf2 gologit3_lf2 `eqs' if `touse' `weight', maximize init(`b0') search(off) 
	}
	if "`lr'" != "" {
		tempname lrstat p_lr
		scalar `lrstat' = 2*(e(ll) - `ll_c')
		scalar `p_lr' = chi2tail(`df',`lrstat')
		matrix `results' = nullmat(`results') \ (`lrstat', `df', `p_lr')
		local rown "`rown' likelihood_ratio"
	}
	if "`wald'" != "" {
		tempname w p_w
		local eq "eq1"
		forvalues i = 2/`mm1' {
			local eq "`eq' = eq`i'"
		}
		local eq "[`eq']"
		qui test `eq':`x'
		scalar `w' = r(chi2)
		scalar `p_w' = r(p)
		matrix `results' = nullmat(`results') \ (`w', `df', `p_w')
		local rown "`rown' Wald"
	}
	if "`ic'" != "" {
		matrix `ic_res'[1,2] = -2*e(ll) + 2*e(rank)
		matrix `ic_res'[2,2] = -2*e(ll) + e(rank)*ln(e(N))
		matrix `ic_res'[1,3] = `ic_res'[1,1] - `ic_res'[1,2]
		matrix `ic_res'[2,3] = `ic_res'[2,1] - `ic_res'[2,2]
	}
	
	if "`asl'`asl2'" != "" {
		// predict probabilities to using in creating random samples under H0
		qui est restore `orig'
		
		forvalues i = 1/$S_m {
			tempvar pr`i'
			local prnames "`prnames' `pr`i''"
		}
		if "`bsample'" == "" {
			qui predict double `prnames' if `touse', pr
			forvalues i = 2/$S_m {
				local j = `i' - 1
				qui replace `pr`i'' = `pr`i'' + `pr`j'' if `touse'
			}
			local pr0 = 0
		}
		
		// prepare variables
		tempvar u l h ysim
		qui gen double `u'    = .
		qui gen int `ysim' = .

		// starting values
		local names : colfullnames `b'
		local names: subinstr local names "`y':" "`ysim':", all
		matrix colnames `b' = `names'
		
		if "`aslscore'" != "" {
			local countscore = 0
		}
		if "`aslwald'" != "" {
			local countwald = 0
		}
		if "`asllr'" != "" {
			local countlr = 0
		}
		if "`aslwolfegould'" != "" {
			local countwg = 0
		}
		if "`aslbrant'" != "" {
			local countb = 0
		}		
		local count = 0
		
		if "`wvar'`bsample'" != "" {
			qui preserve
		}
		if "`wvar'" != "" {
			qui expand `wvar'
		}
		if "`bsample'" != "" {
			tempfile data
			tempname b1
			qui save `data'
		}
		
		if "`dots'" == "" {
			_dots 0, title(Computing ASL) reps(`reps')
		}
		if `"`saving'"' != "" {
			tempname memhold pval
			if "`aslscore'" != "" {
				local poststats "`double' score_stat `double' score_p"
				local returnstats "(r(chi2_s)) (r(p_s))" 
			}
			if "`aslwald'" != "" {
				local poststats "`poststats' `double' Wald_stat `double' Wald_p"
				local returnstats "`returnstats' (r(chi2_w)) (r(p_w))"
			}
			if "`asllr'" != "" {
				local poststats "`poststats' `double' lr_stat `double' lr_p"
				local returnstats "`returnstats' (r(chi2_lr)) (r(p_lr))"
			}
			if "`aslwolfegould'" != "" {
				local poststats "`poststats' `double' WG_stat `double' WG_p"
				local returnstats "`returnstats' (r(chi2_wg)) (r(p_wg))"
			}
			if "`aslbrant'" != "" {
				local poststats "`poststats' `double' Brant_stat `double' Brant_p"
				local returnstats "`returnstats' (r(chi2_b)) (r(p_b))"
			}	
			postfile `memhold' `poststats' using `"`filename'"', `replace' `every'
		}
		forvalues rep = 1/`reps' {
			capture {
				if "`bsample'" != "" {
					use `data', clear
					bsample if `touse'
					replace `ysim' = `y'
					ologit `ysim' `x', from(`b')
					matrix `b1' = e(b)
					predict double `prnames', pr
					forvalues i = 2/$S_m {
						local j = `i' - 1
						replace `pr`i'' = `pr`i'' + `pr`j'' if `touse'
					}
					local pr0 = 0
				}
				replace `u'    = runiform()
				replace `ysim' = .
				forvalues i = 1/$S_m {
					local j = `i' - 1
					replace `ysim' = `i' if `u' > `pr`j'' & `u' < `pr`i'' & `touse'
				}
				ologit `ysim' `x', from(`=cond("`bsample'"== "", `b', `b1')')
				oparallel, `aslscore' `aslwald' `asllr' `aslwolfegould' `aslbrant' nomatlist
			}
			local count = `count' + (_rc==0)
			if _rc == 0 {
				if "`aslscore'"      != "" {
					local countscore = `countscore' + ( r(chi2_s)  > `s' )
				}
				if "`aslwald'"       != "" {
					local countwald  = `countwald'  + ( r(chi2_w)  > `w' )
				}
				if "`asllr'"         != "" {
					local countlr    = `countlr'    + ( r(chi2_lr)  > `lrstat' )
				}
				if "`aslwolfegould'" != "" {
					local countwg    = `countwg'    + ( r(chi2_wg) > `wg' )
				}
				if "`aslbrant'"      != "" {
					local countb     = `countb'     + ( r(chi2_b)  > `br' )
				}
			}
			if `"`saving'"' != "" {
				post `memhold' `returnstats'
			}
			if "`dots'" == "" {
				_dots `rep' `=_rc>0'
			}
		}
		
		if `"`saving'"' != "" {
			postclose `memhold'
		}
		
		if "`wvar'`bsample'" != "" {
			qui restore
		}
		
		tempname aslresults mcciresults

		// store Monte Carlo confidense intervals for the ASL in matrix mcciresults
		if "`mcci2'" != "" {
			if "`score'" != "" {
				if "`aslscore'" == "" {
					matrix `mcciresults' = .z, .z
				}
				else {
					local a = `countscore' + 1
					local b = `count' + 1 - `countscore'
					local lb = invibeta(`a', `b', `alph')
					local ub = invibetatail(`a', `b', `alph')
					matrix `mcciresults' = (`lb', `ub')
				}
			}
			if "`lr'" != "" {
				if "`asllr'" == "" {
					matrix `mcciresults' = nullmat(`mcciresults') \ (.z , .z)
				}
				else {
					local a = `countlr' + 1
					local b = `count' + 1 - `countlr'
					local lb = invibeta(`a', `b', `alph')
					local ub = invibetatail(`a', `b', `alph')
					matrix `mcciresults' = nullmat(`mcciresults') \ (`lb', `ub')
				}
			}
			if "`wald'" != "" {
				if "`aslwald'" == "" {
					matrix `mcciresults' = nullmat(`mcciresults') \ (.z , .z)
				}
				else {
					local a = `countw' + 1
					local b = `count' + 1 - `countw'
					local lb = invibeta(`a', `b', `alph')
					local ub = invibetatail(`a', `b', `alph')
					matrix `mcciresults' = nullmat(`mcciresults') \ (`lb', `ub')
				}
			}
			if "`wolfegould'" != "" {
				if "`aslwolfegould'" == "" {
					matrix `mcciresults' = nullmat(`mcciresults') \ (.z , .z)
				}
				else {
					local a = `countwg' + 1
					local b = `count' + 1 - `countwg'
					local lb = invibeta(`a', `b', `alph')
					local ub = invibetatail(`a', `b', `alph')
					matrix `mcciresults' = nullmat(`mcciresults') \ (`lb', `ub')
				}
			}
			if "`brant'" != "" {
				if "`aslbrant'" == "" {
					matrix `mcciresults' = nullmat(`mcciresults') \ (.z , .z)
				}
				else {
					local a = `countb' + 1
					local b = `count' + 1 - `countb'
					local lb = invibeta(`a', `b', `alph')
					local ub = invibetatail(`a', `b', `alph')
					matrix `mcciresults' = nullmat(`mcciresults') \ (`lb', `ub')					
				}
			}	
		}
		
		// store the ASL in matrix aslresults
		if "`score'" != "" {
			if "`aslscore'" == "" {
				local countscore = .z
			}
			else {
				local countscore = (`countscore'+1)/(`count'+1)
			}
			matrix `aslresults' = `countscore'
		}
		if "`lr'" != "" {
			if "`asllr'" == "" {
				local countlr = .z
			}
			else {
				local countlr = (`countlr'+1)/(`count'+1)
			}
			matrix `aslresults' = nullmat(`aslresults') \ `countlr'
		}
		if "`wald'" != "" {
			if "`aslwald'" == "" {
				local countwald = .z
			}
			else {
				local countwald = (`countwald'+1)/(`count'+1)
			}
			matrix `aslresults' = nullmat(`aslresults') \ `countwald'
		}
		if "`wolfegould'" != "" {
			if "`aslwolfegould'" == "" {
				local countwg = .z
			}
			else {
				local countwg = (`countwg'+1)/(`count'+1)
			}
			matrix `aslresults' = nullmat(`aslresults') \ `countwg'
		}
		if "`brant'" != "" {
			if "`aslbrant'" == "" {
				local countb = .z
			}
			else {
				local countb = (`countb'+1)/(`count'+1)
			}
			matrix `aslresults' = nullmat(`aslresults') \ `countb'
		}	
		
		// combine the result matrix with the aslresults matrix and optionally witht the mcciresults matrix
		matrix `results' = `results', `aslresults'
		if "`mcci2'" != "" {
			matrix `results' = `results', `mcciresults'
		}

	}
	
	// display results
	matrix colnames `results' = Chi2 df P>Chi2 `=cond("`asl'`asl2'"=="", "", "ASL")' `=cond("`mcci2'"=="", "", `""[`mcci2'%" "MC CI]""')'
	matrix rownames `results' = `rown'
	if "`matlist'" == "" {
		local rspec "&|"
		forvalues i = 1/`: word count `score' `wald' `lr' `wolfegould' `brant'' {
			local rspec "`rspec'&"
		}
		local cspec "& %16s | %6.0g  &  %5.0g & w6  %5.3f & "
		if "`asl'`asl2'" != "" {
			local cspec "`cspec' %5.3f &" 
		}
		if "`mcci2'" != "" {
			local cspec "`cspec' w6  %5.3f & w6 %5.3f &"

		}
		if `: word count `score' `wald' `lr' `wolfegould' `brant'' == 1 {
			local title "Test of the parallel regression assumption"
		}
		else {
			local title "Tests of the parallel regression assumption"
		}
		matlist `results', nodotz underscore rspec(`rspec') cspec(`cspec') title(`title')
		
		if "`ic'" != "" {
			di _n
			matlist `ic_res', format(%10.2f) title("Information criteria") tw(5)
		}
	}
	
	// return results
	return matrix results = `results'
	return scalar df = `df'
	if "`score'" != "" {
		return scalar chi2_s = `s'
		return scalar p_s = `p_s'
		if "`aslscore'" != "" {
			return scalar asl_s = `countscore'
		}
	}
	if "`wald'" != "" {
		return scalar chi2_w = `w'
		return scalar p_w = `p_w'
		if "`aslwald'" != "" {
			return scalar asl_w = `countwald'
		}
	}
	if "`lr'" != "" {
		return scalar chi2_lr = `lrstat'
		return scalar p_lr = `p_lr'
		if "`asllr'" != "" {
			return scalar asl_lr = `countlr'
		}
	}
	if "`wolfegould'" != "" {
		return scalar chi2_wg = `wg'
		return scalar p_wg = `p_wg'
		if "`aslwolfegould'" != "" {
			return scalar asl_wg = `countwg'
		}
	}
	if "`brant'" != "" {
		return scalar chi2_b = `br'
		return scalar p_b = `p_br'
		if "`aslbrant'" != "" {
			return scalar asl_b = `countb'
		}
	}
	if "`asl'`asl2'" != "" {
		return scalar reps = `count'
	}
	if "`ic'" != "" {
		return matrix ic = `ic_res'
	}
	qui est restore `orig'
end

// Parse the saving() option
program define Parsesaving, rclass 
	syntax [ anything(name=filename everything) ] [, replace DOUBle EVery(numlist min=1 max=1 integer > 0)]
	
	if `"`filename'"' == "" & "`replace'`double'" != "" {
		di as err "need to specify a file name when specifying the replace or the double option inside the saving() option"
		exit 198
	}
	if "`replace'" == "" & `"`filename'"' != "" {
		confirm new file `filename'
	}
	return local filename `filename'
	return local replace `replace'
	return local double `double'
	if "`every'" != "" {
		return local every "every(`every')"
	}
end

// check for constraints
program define chkcns
	capture confirm matrix e(Cns)
	if !_rc {
		tempname cns
		matrix `cns' = e(Cns)
		local k = colsof(`cns')
		local coln : colnames `cns'
		tokenize `coln'

		local problem = 0
		forvalues i = 1/`k' {
			if el(`cns',1,`i') == 1 {
				_ms_parse_parts ``i''
				if `r(omit)' == 0 local problem = 1
			}
		}
		if `problem' {
			di as err "oparallel cannot work with an ologit model with constraints"
			exit 198
		}
	}
	if "`e(offset)'" != "" {
		di as err "oparallel cannot work with an ologit model with an offset"
		exit 198
	}
end

program define indep_binaries, rclass
	syntax [if] [fw/], bx(name) y(name) mm1(integer) df(integer) [wolfegould brant qui(string) ] 
	
	marksample touse
	
	local x : colnames `bx'
	_ms_op_info `bx'
	local fvops = r(fvops)
	if `fvops' == 1 {
		// remove omitted variables
		foreach var of local x {
			_ms_parse_parts `var'
			if `r(omit)' == 0 {
				local rhs1 "`rhs1' `var'"
			}
		}
			
		// turn factor variables in "real" variables
		local j = 1
		foreach var of local rhs1 {
			tempvar var`j'
			qui gen double `var`j'' = `var'
			local rhs "`rhs' `var`j''"
			local j = `j' + 1
		}
	}

	// create the corresponding macros when no factor variables were used
	else {
		local j = 1
		foreach var of local x {
			local var`j' "`var'"
			local j = `j' + 1
		}
		local rhs "`x'"
	}

	// actual data preparation
	quietly { 
		tempvar cat id cut binary
		sort `touse' `y'
		by `touse' `y': gen `cat'=1 if _n==1 & `touse'
		replace `cat' =sum(`cat')
		replace `cat'=. if `touse'!=1
		preserve
		qui keep if `touse'
		qui keep `rhs' `cat' `exp'
		if "`weight'" != "" {
			expand `exp'
		}
			
		gen `id'=_n
		expand $S_m
		sort `id'
		by `id': gen `cut'=_n
		by `id': gen byte `binary' = (`cat'<=`cut')
			
		forvalues i = 1/`mm1' {
			tempvar cut`i'
			gen byte `cut`i'' = (`cut' == `i')
			local cuts "`cuts' `cut`i''"
		}
	
		forvalues i = 1/`mm1' {
			local j = 1
			foreach var of local rhs {
				tempname cut`i'Xvar`j' 
				gen double `cut`i'Xvar`j'' = `cut`i''*`var'
				local interact "`interact' `cut`i'Xvar`j''"
				local inter`i' "`inter`i'' `cut`i'Xvar`j''"
				local j = `j' + 1
			}
		}
	} // ends quietly

	// check if the full model can be estimated	
	qui _rmcoll `binary' `cuts' `interact' if `cut'!=$S_m, logit noconstant
	if r(k_omitted) > 0 {
		di as err "full model cannot be estimated due to perfect prediction"
		exit 198
	}
	
	if "`wolfegould'" != "" {
		tempname ll
		tempvar g1 p1 cateq ll1
		scalar `ll' = 0
		// ordered logit model fitted through independent binaries
		// version 5 because it is much quicker
		
		`qui' version 5: logit `binary' `cuts' `rhs' if `cut'!=$S_m, nocons
		quietly {
			predict double `g1'
			sort `id' `cut'
			gen double `p1'=`g1' if `cut'==1
			replace `p1'=`g1'-`g1'[_n-1] if `cut'!=1 & `cut'!=$S_m
			replace `p1'=1-`g1'[_n-1] if `cut'==$S_m
			gen `cateq'= `cat'==`cut'

			gen double `ll1' = sum(`cateq'*log(`p1'))
			scalar `ll' = `ll' + `ll1'[_N]
			drop `ll1' `g1' `p1'
		}
	}
	if "`wolfegould'`brant'" != "" {
		// generalised model fitted through independent binaries
		// version 5 because it is much quicker
		`qui' version 5: logit `binary' `cuts' `interact' if `cut'!= $S_m, nocons
	}
	if "`wolfegould'"!= "" {
		tempname gll wg 
		tempvar g2 p2 ll2
		scalar `gll' = 0
		quietly {
			predict double `g2'
			sort `id' `cut'
			gen double `p2'=`g2' if `cut'==1
			replace `p2'=`g2'-`g2'[_n-1] if `cut'!=1 & `cut'!=$S_m
			replace `p2'=1-`g2'[_n-1] if `cut'==$S_m
			gen double `ll2' = sum(`cateq'*log(`p2'))
			scalar `gll' =`gll'+`ll2'[_N]
			drop `ll2' `g2' `p2'
		}
		scalar `wg' = -2*(`ll' - (`gll'))
		return scalar wg = `wg'
		return scalar p_wg =  chi2tail(`df', `wg')
	}
	if "`brant'" != "" {
		tempname bu v
		matrix `bu' = e(b)
		matrix `bu' = `bu'[1, $S_m...]
		local k : word count `rhs'
		matrix `v' = e(V)
		forvalues i = 1/`mm1' {
			tempname vu`i'
			local f : word  1  of `inter`i''
			local l : word `k' of `inter`i''
			matrix `vu`i'' = `v'["`f'".."`l'", "`f'".."`l'"]
			local vs "`vs' `vu`i''"
		}
		tempvar cut$S_m
		gen byte `cut${S_m}' = (`cut' == $S_m)
		
		tempvar pr
		predict double `pr', pr
		forvalues i = 1/`mm1' {
			forvalues j = `=`i' + 1'/`mm1' {
				tempname vu`i'_`j'
				mata: comp_v("`vu`i'_`j''",`i', `j', "`rhs'")
			}
		}
			
		// define var(B) matrix
		forvalues i = 1/`mm1'{
			tempname row`i'
			forvalues i2 = 1/`mm1' {
				if `i'==`i2' { 
					mat `row`i'' = nullmat(`row`i''), `vu`i'' 
				}
				if `i'<`i2' { 
					mat `row`i'' = nullmat(`row`i'') , `vu`i'_`i2'' 
				}
				if `i'>`i2' { 
					mat `row`i'' = nullmat(`row`i'') , `vu`i2'_`i''' 
				}
			}
		}

		// combine matrices
		tempname varb
		forvalues i = 1/`mm1' {
			mat `varb' = nullmat(`varb') \ `row`i''
		}

		
		// create design matrix for wald test; make I, -I, and 0 matrices
		tempname id negid zero
		local nrhs : word count `rhs'
		local dim = `nrhs'	
		mat `id' = I(`dim')
		mat rownames `id' = `rhs'
		mat colnames `id' = `rhs'
		mat `negid' = -1*`id'
		mat rownames `negid' = `rhs'
		mat colnames `negid' = `rhs'
		mat `zero' = J(`dim', `dim', 0)
		mat rownames `zero' = `rhs'
		mat colnames `zero' = `rhs'
		
		
		// dummy matrix
		local i = 1
		forvalues i = 1/`=`mm1'-1' {
			tempname drow`i'
			forvalues i2 = 1/`mm1' {
				tempname feed
				if `i2'==1 { 
					mat `feed' = `id' 
				}
				else if `i2'-`i'==1 { 
					mat `feed' = `negid' 
				}
				else { 
					mat `feed' = `zero' 
				}
				mat `drow`i'' = nullmat(`drow`i'') , `feed'
		   }
		}

		* combine matrices
		tempname d
		forvalues i = 1/`=`mm1'-1' {
			mat `d' = nullmat(`d') \ `drow`i''
		}

		* terms of wald test
		tempname DB DBp step1 step2 iDvBDp
		matrix `bu' = `bu''
		mat `DB' = `d' * `bu'
		mat `DBp' = `DB''
		mat `step1' = `d'*`varb'
		mat `step2' = `step1' * (`d'')
		mat `iDvBDp' = inv(`step2')

		*** calculate wald stat
		tempname step1 brmat br 
		mat `step1' = `DBp' * `iDvBDp'
		mat `brmat' = `step1' * `DB'
		scalar `br' = `brmat'[1,1]
		return scalar br = `br'
		return scalar p_br = chi2tail(`df',`br')
	} // closes brant
	
	// undo data preparation for Wolfe-Gould and Brant
	qui restore
end
	
mata
void ologitcat() {
	string matrix cat
	string scalar catglobal
	
	cat = strofreal(st_matrix("e(cat)"))
	catglobal = invtokens(cat)
	st_global("S_levs",catglobal)
}
void comp_v(string scalar vname, real scalar i , real scalar j , string scalar rhs) {
	real vector p1, p2, w11, w12, w22
	real matrix X, V
	
	p1 = st_data(.,st_local("pr"),st_local("cut"+strofreal(i)))
	p2 = st_data(.,st_local("pr"),st_local("cut"+strofreal(j)))
	X = st_data(.,rhs, st_local("cut"+strofreal(i)))
	X = J(rows(X),1,1),X
	
	w11 = p1:-(p1:*p1)
	w22 = p2:-(p2:*p2)
	w12 = p1:-(p2:*p1)
	V = invsym(quadcross(X, w11, X))*quadcross(X,w12,X)*invsym(quadcross(X,w22,X))
	st_matrix(vname,V[|2,2\rows(V), cols(V)|])
}
end
