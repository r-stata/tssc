*! survwgt 1.2.4 06feb2018 NJGW
*
* 1.2.4	fixed -modify- option in (typical) case where by variable doesn't index -touse- categories 
* 1.2.3   fixed variable labelling with modify not to add "(raked)" repeatedly
* 1.2.2	added -modify- option to -rake- (and therefore -poststratify-) to allow adjustment for subset of observations
* 1.2.1   fixed crash when path to hadfile includes spaces
* 1.2.0	applied v1.1.0 changes to -nonresponse- routine
* 1.1.0	added "all", "pw", "rw" variable specification option to -rake-
*		fixed -create- routine to make tempvars; then create real vars at end.
*		fixed -rake- to generate via tempvars
*		fixed -rake- to update -svrset- if possible
*		fixed -rake- and -create- to label variables


program define survwgt
	version 7

	gettoken cmd 0 : 0, parse(" ,")
	local l = length(`"`cmd'"')

	if `"`cmd'"'==substr("create",1,max(2,`l')) { 		/* CReate */
		Create `0'
		exit
	}
	if `"`cmd'"'==substr("poststratify",1,max(4,`l')) { 	/* POSTstratify */
		PostStrat `0'
		exit
	}
	if `"`cmd'"' == "rake" {							/* RAKE */
		Rake `0'
		exit
	}
	if `"`cmd'"'==substr("nonresponse",1,max(4,`l')) { 	/* NONResponse */
		NonResponse `0'
		exit
	}
	di in red "unrecognized survwgt subcommand"
	exit 199

end	/* survwgt */


program define Create
	version 7

	gettoken wtype 0 : 0, parse(" ,")

	if "`wtype'"=="sizes" {					/* get matrix sizes and exit */
		syntax , [ HADFile(string) ]
		if "`hadfile'"=="" {
			FindFile "brr_hadamardmatrixfile.ado" hadfile
		}
		GetHad "`hadfile'" info
		exit
	}
	if "`wtype'"=="brr" | "`wtype'"=="jk2" | "`wtype'"=="jk1" | "`wtype'"=="jkn" {
		DoWgt `wtype' `0'
		exit
	}
	di as error "unrecognized replicate weight type"
	exit 199

end	/* Create */

program define DoWgt

	syntax anything(name=method) , PSU(varname) Weight(varname) 			/*
		*/		[	STEM(string)									/*
		*/			STRata(varname) Fay(real 0) Reps(int 0) noDots		/*
		*/			HADMat(string) HADFile(string) DOF(int -1)  ]

	local brr = "`method'"=="brr"
	local jk1 = "`method'"=="jk1"
	local jk2 = "`method'"=="jk2"
	local jkn = "`method'"=="jkn"

	if "`stem'"=="" {
		local stem `method'_
	}

	if `jkn' | `jk2' | `jk1' {	/* additional syntax restrictions */
		if `fay'!=0 {
			di as error "option fay() is not allowed with method `method'"
			exit 198
		}
		if "`hadmat'`hadfile'"!="" {
			di as error "options hadmat() and hadfile() are not allowed with method `method'"
			exit 198
		}
		if `reps'!=0 {
			di as error "option reps() is not allowed with method `method'"
			exit 198
		}
		if `jk1' {
			if "`strata'"!="" {
				di as error "option strata() is not allowed with method `method'"
				exit 198
			}
		}
	}
	if `jkn' | `brr' | `jk2' {
		if "`strata'"=="" {
			di as error "option strata() required with method `method'"
			exit 198
		}
	}


	if "`dots'"=="nodots" {
		local dots *
	}
	capture describe `stem'*
	if !_rc {
		di
		di "{txt}{p}Warning: variables named `stem'* already exist"
	}

	if `brr' {
		if `"`hadfile'"'=="" & `"`hadmat'"'=="" {
			FindFile "brr_hadamardmatrixfile.ado" hadfile
		}
	}

*Set up stcat and psucat to index strata and psus
	tempvar stcat psucat
	if `jk1' {
		qui egen int `stcat'=group(`psu')		/* for jk1, the PSUs are treated as "strata" */
		qui gen `psucat'=1					/* only one "psu" per "stratum" */
	}
	else {
		qui egen int `stcat'=group(`strata')				/* number strata 1,2,... */
		qui bysort `stcat' `psu': gen int `psucat'=1 if _n==1
		qui bysort `stcat' (`psu'): replace `psucat'=sum(`psucat')		/* generate 1,2... psu variable */
	}
	if `jkn' {
		tempvar grp
		qui egen int `grp' = group(`stcat' `psucat')
		sum `grp', meanonly
		local n_grp `r(max)'
	}
	sum `stcat', meanonly
	local n_strat `r(max)'


*get dimension for matrix (==number of replicates for all but jkn method)
	if `brr' {
		local dim = `n_strat' + 3 - mod(`n_strat'-1,4)	/* smallest multiple of four >= number of strata */
		if `reps'!=0 {
			if `reps'<`dim' {
				di "{txt}Warning: reps() specified as less than the number of strata"
			}
			if mod(`reps',4) {
				di "{error}reps() is not a multiple of four"
				exit 198
			}
			local dim `reps'
		}
	}
	else {	/* jk1, jk2, jkn */
		local dim = `n_strat'
	}


	if `dof'==-1 {
		if `jkn' {
			local dof = `n_grp' - `n_strat'
		}
		else {
			local dof=`n_strat' - `jk1'		/* For BRR and JK2 --> number of strata */
		}								/* for JK1 --> number of psus minus one */
	}


	* Check strata and create stratum dummies
	forval s=1/`n_strat' {
		if !`jk1' {
			cap assert `psucat'<2 if `stcat'==`s'
			if !_rc {
				di as err "stratum with only one PSU detected"
				error 460
			}
		}
		if !`jkn' {
			sum `psucat', meanonly
			if `r(max)'>2 {
				di as err "stratum with more than 2 PSUs detected"
				error 460
			}
		}
		tempvar str`s'							/* dummy variable for each stratum */
		qui gen byte `str`s''=(`stcat'==`s')
		local matlab "`matlab' `str`s''"			/* matrix label string, so -mat score- will */
											/* multiply out the matrices */
	}

	* create check and assemble list of variables
	if !`jkn' {
		forval s=1/`dim' {
			confirm new variable `stem'`s'
			local repvars "`repvars'`stem'`s' "
		}
	}
	else {	/* jkn */
		forval s=1/`n_grp' {
			confirm new variable `stem'`s'
			local repvars "`repvars'`stem'`s' "
		}
	}


*
* GET HADAMARD MATRIX for BRR
*
	if `brr' {
		`dots' di
		`dots' di "{txt}Obtaining hadamard matrix file..."

		if "`hadmat'"=="" {
			tempname hadmat
			GetHad "`hadfile'" `dim' /* `hadmat' */
			local dim = r(size)
			matrix `hadmat' = r(matrix)
		}
		else {
			tempname holdmat tempmat				/* in order to put back the user-provided matrix */
			local nc=colsof(`hadmat')
			local nr=rowsof(`hadmat')
			if !((`nr'==`nc') & (`nr'==`dim')) {
				di as error "Matrix `hadmat' must be `dim'X`dim'"
				exit 503
			}
			matrix `holdmat'=`hadmat'*`hadmat''
			mat `tempmat'=`nc'*I(`nc')
			local test=mreldif(`holdmat',`tempmat')
			if `test'!=0 {
				di as error "Warning: User-specified matrix is not a valid Hadamard matrix"
				di as error "Weights may not be balanced"
			}
			mat drop `tempmat'
			matrix `holdmat'=`hadmat'
		}

		matrix `hadmat'=`hadmat'*(1-`fay') + J(`dim',`dim',1)	/* convert (1),(-1) to (2-fay),(fay) */
		matrix `hadmat'=`hadmat'[....,1..`n_strat']			/* lop off extra columns (strata) */
	}
	else if `jk2' {
		tempname hadmat
		matrix `hadmat' = I(`dim')
		matrix `hadmat' = `hadmat' + J(`dim',`dim',1)	/* 2 for doubled psu, 1 for all others */
	}
	else if `jk1' {
		tempname hadmat
		local factor = `n_strat'/(`n_strat'-1)
		matrix `hadmat' = J(`dim',`dim',`factor') - (I(`dim')*`factor')	/* 0 for deleted "stratum"; factor for others */
	}
	else if `jkn' {
		tempname hadmat diagmat
		matrix `hadmat' = J(`dim',`dim',1) - I(`dim')
		forval i=1/`dim' {
			qui sum `psucat' if `stcat'==`i'
			local npsu_`i' = r(max)
			mat `diagmat' = nullmat(`diagmat') , (`npsu_`i''/(`npsu_`i''-1))
		}
		mat `diagmat'=diag(`diagmat')
		mat `hadmat' = `hadmat' + `diagmat'
	}

	matrix colnames `hadmat'=`matlab'					/* label with strata dummies, for -mat score- */

*
* GENERATE WEIGHTS
*

	`dots' di "{txt}Generating replicate weights" _c

	if !`jkn' {
		tempname mat1 flipmat
		matrix `flipmat' = J(1,`n_strat',2)
		forval rep=1/`dim' {
			tempvar newvar`rep'
			matrix `mat1'=`hadmat'[`rep',....]							/* get this replicate's row */
			qui matrix score double `newvar`rep''=`mat1' if `psucat'==1		/* create factors for PSU1 */
			if !`jk1' {
				matrix `mat1'=`flipmat'-`mat1'							/* flip matrix for PSU2 */
				qui matrix score `newvar`rep''=`mat1' if `psucat'==2, replace		/* create factors for PSU2 */
			}
			qui replace `newvar`rep''=`newvar`rep''*`weight'					/* multiple factors by base weight */
			qui compress `newvar`rep''
			`dots' di "." _c
		}
	}
	else {	/* jkn */
		tempname mat1
		local rep=1
		forval s=1/`n_strat' {
			mat `mat1' = `hadmat'[`s',....]		/* get this stratum's row */
			forval p=1/`npsu_`s'' {
				tempvar newvar`rep'
				qui matrix score `newvar`rep'' = `mat1'
				qui replace `newvar`rep'' = 0 if `stcat'==`s' & `psucat'==`p'
				qui replace `newvar`rep'' = `newvar`rep''*`weight'
				local rep=`rep'+1
				local psulist "`psulist'`npsu_`s'' "		/* assemble list of PSU sizes */
				`dots' di "." _c
			}
		}
		local dim=`n_grp'
	}


	* GENERATE THE REAL WEIGHTS

	forval i=1/`dim' {
		qui gen double `stem'`i' = `newvar`i''
		la var `stem'`i' "`method' replicate weight `i'"
	}
	qui compress

	`dots' di
	`dots' di

*
* Set characteristics
*

	char define _dta[svrpw]		"`weight'"
	char define _dta[svrfay]		"`fay'"
	char define _dta[svrrw] 		"`repvars'"
	char define _dta[svrmeth]	"`method'"
	char define _dta[svrdof]		"`dof'"
	char define _dta[svrpsun]	"`psulist'"

	di "{txt}Created weights and set {help svr} values:"
	svrset list

	if "`holdmat'"!="" {
		matrix `hadmat'=`holdmat'
	}

end  /* DoWgt_2 */


program define PostStrat
	version 7

	*This routine creates a single stratum identifier, does some error checking,
	*and then calls the -Rake- procedure across the one dimension.
	*This involves extra overhead, since only one rep is required, but
	*means there is less code to debug

	syntax anything(name=vspec) [if] [in] , /*
		*/ 		BY(varlist min=1 max=8) Totvar(varlist numeric max=1) /*
		*/ 		[ GENerate(passthru) stem(passthru) PREfix(passthru) replace noUPdate ]

	local ndim : word count `by'
	if `ndim' > 1 {					/* if >1 strat variable, create a single grouping variable */
		tempvar strlist
		qui egen `strlist' = group(`by')
	}
	else {							/* if 1 strat variable, just use it */
		local strlist `by'
	}

	capture bysort `strlist' : assert `totvar'==`totvar'[1] `if' `in'
	if _rc {
		di as error "Control total not constant within strata"
		exit 198
	}

	Rake `vspec' `if' `in' , by(`strlist') totvars(`totvar') /*
		*/		`generate' `stem' `prefix' `replace' `update' check(0)

end	/* PostStrat */

program define Rake
	version 7
	* version 1.0
	* NJGW 26 August 2002
	* Based on Nick Cox's mstdize.ado

	*THINGS TO DO:
	* Check for Zero cells and warn or exit
	* Check for deflated estimates [this could be OK if they are all deflated...think about this!

	syntax anything(name=vspec id="variable specification") [if] [in] , /*
		*/ 		BY(varlist min=1 max=8) Totvars(varlist numeric) /*
		*/ 		[ ATol(real 1e-3) RTol(real 1e-5) MAXRep(integer 10) /*
		*/ 		GENerate(string) stem(string) PREfix(string) replace modify /*
		*/		check(int 1) noUPdate ]

	local process=cond(`check',"raked","post-stratified")
	local startnum 1
	capture unab varlist : `vspec'
	if _rc {
		svr_get
		local w1 : word 1 of `vspec'
		local w2 : word 2 of `vspec'
		if "`vspec'"=="[all]" | ("`w1'"=="[rw]" & "`w2'"=="[pw]") | ("`w1'"=="[pw]" & "`w2'"=="[rw]") {
			local varlist `r(pw)' `r(rw)'
			local startnum 0
			local newpw "pw"
			local newrw "rw"
		}
		else if "`vspec'"=="[pw]" {
			local varlist `r(pw)'
			local startnum 0
			local newpw "pw"
		}
		else if "`vspec'"=="[rw]" {
			local varlist `r(rw)'
			local newrw "rw"
		}
		else {
			di as error "invalid variable specification"
			exit 198
		}
	}

	local nvar : word count `varlist'
	local ndim : word count `by'
	local ntot : word count `totvars'

	local ngen : word count `stem' `prefix' `replace' `modify'
	if "`generate'"!="" {
		local ngen=`ngen'+1
	}

	if `ngen'!=1 {
		di as error "{p}Must specify " cond(`ngen'==0,"","only ") "one of generate(), stem(), prefix(), replace, modify"
		exit 198
	}

	if "`generate'"!="" {
		local ng : word count `generate'
		if `ng'!=`nvar' {
			di as error "{p}number of generate() variables must equal number of variables to be processed"
			exit 198
		}
	}

	if `ndim'!=`ntot' {
		di as error "number of by() variables must equal number of totvars()"
		exit 198
	}

	tempvar guess pguess diff reld first
	marksample touse
	forval i=1/`ndim' {
		tempvar Tot`i'							/* current total for dim i*/
		qui gen double `Tot`i'' = .
		local by`i' : word `i' of `by'			/* index for dimension i */
		local tot`i' : word `i' of `totvars'		/* goal total for dim i*/
		
		if `check' {
			capture bysort `touse' `by`i'' : assert `tot`i''==`tot`i''[1] if `touse'
			if _rc {
				di as error "Control total `tot`i'' not constant within categories of dimension `by`i''"
				exit 198
			}
		}
	}

	qui {
		bysort `touse' `by1' : gen `first' = _n==1
		sum `tot1' if `touse' & `first', meanonly
		local sum1 = r(sum)

		forval j=2/`ndim' {
			bysort `touse' `by`j'' : replace `first' = _n==1
			sum `tot`j'' if `touse' & `first', meanonly
			local sum`j' = r(sum)
			local j1 = `j'-1
			forval k = 1/`j1' {
				local dif = abs(`sum`k'' - `sum`j'')

				*comparison is with the least stringent of the absolute and relative
				*    criteria.  However, the more stringent of the two relative
				*    comparisons is taken, in leiu of comparing k with j and then j with k
				if `dif' > max(`atol',min(`rtol'*`sum`k'',`rtol'*`sum`j'')) {
					di as error "totals across dimensions `k' and `j' are not equal"
					exit 199
				}
			}
		}


		foreach v in guess pguess diff reld {
			gen double ``v''=.
		}

		forval j=1/`nvar' {
			local curvar : word `j' of `varlist'

			replace `guess' = `curvar' if `touse'
			replace `pguess' = .
			forval i=1/`ndim' {
				replace `Tot`i'' = .
			}

			local amax .
			local rmax .
			local reps 0

			while (`amax' > `atol') & (`rmax' > `rtol') & (`reps' < `maxrep') {
				replace `pguess' = `guess' if `touse'
				replace `diff' = 0 if `touse'
				replace `reld' = 0 if `touse'
				forval i=1/`ndim' {
					bysort `touse' `by`i'' : replace `Tot`i'' = sum(`guess') if `touse'
					bysort `touse' `by`i'' : replace `Tot`i'' = `Tot`i''[_N] if `touse'

					replace `guess' = `guess' * `tot`i'' / `Tot`i'' if `touse'
					replace `diff' = max(`diff',abs(`Tot`i'' - `tot`i'')) if `touse'
					replace `reld' = max(`reld',`diff'/`tot`i'') if `touse'
						/*	for each obs, diff will be the largest absolute difference
							between a single control total and the new guess

							the max() ensures that the largest across the dimensions is retained

							reld will be the largest relative difference (ie, the difference
							over the relevant control total
						*/
				}
				su `diff' if `touse', meanonly
				local amax = r(max)
				su `reld' if `touse', meanonly
				local rmax = r(max)
				local reps =`reps'+1
			}
			local reason = (`amax' <= `atol') + 2*(`rmax' <= `rtol') + 4*(`reps' >= `maxrep')
						/*	1 = absolute tolerance
							2 = relative tolerance
							4 = maxreps
						*/
			if `reason'>=4 {
				noi di "{txt}Warning: variable `curvar' reached maximum"
				noi di "{txt}iterations before convergence."
			}

			tempvar tempvar`j'
			gen double `tempvar`j'' = `guess' if `touse'		/* new variables, as tempvars */

			if "`generate'" != "" {
				local gvar : word `j' of `generate'
			}
			else if "`stem'"!="" {
				local num = `j'-1+`startnum'
				local gvar `stem'`num'
			}
			else if "`prefix'"!="" {
				local gvar `prefix'`curvar'
			}
			else if "`replace'"!="" | "`modify'"!="" {
				local gvar `curvar'
			}
			if "`replace'"=="" & "`modify'"=="" {
				confirm new variable `gvar'
			}
			local newlist "`newlist' `gvar'"		/* list of variables to create */
		} /* cylcing thru vars */

		forval j=1/`nvar' {
			local old : word `j' of `varlist'
			local vlab : variable label `old'
			local new : word `j' of `newlist'
			if "`replace'"!="" {
				drop `new'
			}
			if "`modify'"=="" {
				gen double `new' = `tempvar`j'' if `touse'
			}
			else {
				// doing modify only on `touse' observations
				// 'new' is not actually new
				count if `tempvar`j''!=`new' & `touse'
				//noi di "`r(N)' replacements:"
				replace `new' = `tempvar`j'' if `touse'
				noi di `"{txt}Modified {res}`new'{txt} for [{res}`if'`in'{txt}]; {res}`r(N)'{txt} real changes made"'
			}
			if "`modify'"=="modify" {
				local vlab : subinstr local vlab " (`process')" "", all
			}
			la var `new' "`vlab' (`process')"
		}
		if "`update'"!="noupdate" & "`newpw'`newrw'"!="" {
			if "`newpw'"=="pw" {
				gettoken w newlist : newlist
				svrset set pw `w'
			}
			if "`newrw'"=="rw" {
				svrset set rw "`newlist'"
			}
			noi di
			noi di "{txt}SVR settings updated:"
			noi svrset list `newpw' `newrw'
		}
	}


end /* Rake */


program define NonResponse
	version 7

	* ADD OPTION TO SET MAXIMUM ADJUSTMENT!
	* FIX to check for non-zero weights, so that excluded strata are excluded -- as option???

	syntax anything(name=vspec id="variable specification") [if] [in] , /*
		*/		BY(varlist min=1 max=8) Respvar(varlist max=1 numeric) /*
		*/		[ GENerate(string) stem(string) PREfix(string) replace noUPdate MAXadj(real 10) ]

	marksample touse

	capture assert `respvar' == 0 | `respvar' == 1 | `respvar'==. if `touse'
	if _rc {
		di as error "Response variable must take on values 0 (for non-response),"
		di as error "1 (for response), or missing (to exclude from adjustment)"
		exit 198
	}

	local ndim : word count `by'
	if `ndim'>1 {
		tempvar strlist
		egen `strlist' = group(`by')
	}
	else {
		local strlist `by'
	}

	local startnum 1
	capture unab varlist : `vspec'
	if _rc {
		svr_get
		local w1 : word 1 of `vspec'
		local w2 : word 2 of `vspec'
		if "`vspec'"=="[all]" | ("`w1'"=="[rw]" & "`w2'"=="[pw]") | ("`w1'"=="[pw]" & "`w2'"=="[rw]") {
			local varlist `r(pw)' `r(rw)'
			local startnum 0
			local newpw "pw"
			local newrw "rw"
		}
		else if "`vspec'"=="[pw]" {
			local varlist `r(pw)'
			local startnum 0
			local newpw "pw"
		}
		else if "`vspec'"=="[rw]" {
			local varlist `r(rw)'
			local newrw "rw"
		}
		else {
			di as error "invalid variable specification"
			exit 198
		}
	}

	if "`generate'"!="" {
		local ngen : word count `generate'
		local nvar : word count `varlist'
		if `ngen'!=`nvar' {
			di as error "{p}number of generate() variables must equal number of variables to be processed"
			exit 198
		}
	}
	local process "adjusted for non-response"

	tempvar sumresp sumsamp rratio guess

	local nvar : word count `varlist'
	qui {
		forval i=1/`nvar' {

			local var : word `i' of `varlist'
			egen double `sumresp' = sum(`var'*(`respvar'==1)) if `touse' , by(`strlist')
			egen double `sumsamp' = sum(`var'*(`respvar'==1 | `respvar'==0)) if `touse' , by(`strlist')
			gen double `rratio' = `sumsamp' / `sumresp'
			tab `strlist' if `sumresp'==0
			if r(r) {
				di "{res}`r(r)'{txt} strat" cond(r(N)==1,"um","a") " have 0 total"
				di "respondent weight for `var';"
				di "{res}all weight set to zero for " cond(r(N)==1,"this cell","these cells")
				replace `rratio' = 0 if `rratio'==0
			}
			tab `strlist' if `sumsamp'==0
			if r(r) {
				di "{res}`r(r)'{txt} strat" cond(r(N)==1,"um","a") " have 0 total"
				di "sample weight; all weight set to missing for " cond(r(N)==1,"this cell","these cells")
				replace `rratio' = . if `sumsamp'==0
			}
			generate double `guess' = (`var' * min(`rratio',`maxadj')) * `respvar'
				/*	multiplying by respvar sets to zero for non-respondents, and sets to blank
					when respvar is blank
				*/


			tempvar tempvar`i'
			gen double `tempvar`i'' = `guess'		/* new variables, as tempvars */

			if "`generate'" != "" {
				local gvar : word `i' of `generate'
			}
			else if "`stem'"!="" {
				local num = `i'-1+`startnum'
				local gvar `stem'`num'
			}
			else if "`prefix'"!="" {
				local gvar `prefix'`curvar'
			}
			else if "`replace'"!="" {
				local gvar `curvar'
			}
			if "`replace'"=="" {
				confirm new variable `gvar'
			}
			local newlist "`newlist' `gvar'"		/* list of variables to create */

			drop `sumresp' `sumsamp' `rratio' `guess'

		} /* cylcing thru vars */

		forval j=1/`nvar' {
			local old : word `j' of `varlist'
			local vlab : variable label `old'
			local new : word `j' of `newlist'
			if "`replace'"!="" {
				drop `new'
			}
			gen double `new' = `tempvar`j''
			la var `new' "`vlab' (`process')"
		}
		if "`update'"!="noupdate" & "`newpw'`newrw'"!="" {
			if "`newpw'"=="pw" {
				gettoken w newlist : newlist
				svrset set pw `w'
			}
			if "`newrw'"=="rw" {
				svrset set rw "`newlist'"
			}
			noi di
			noi di "{txt}SVR settings updated:"
			noi svrset list `newpw' `newrw'
		}

	}

end	/* NonResponse */

program define GetHad, rclass
	version 7

	args bigfile sizewanted /* matnm */

	tempname f matnm
	local filever "brrhadmat 2.0.0"			/* current version of file */

	confirm file "`bigfile'"
	file open `f' using "`bigfile'", read binary

	file seek `f' 123

	file read `f' %15s signature


	if `"`signature'"'!="`filever'" {
		if substr(`"`signature'"',1,9)=="brrhadmat" {
			di as error "Matrix file is not `filever'"
			di as error "`bigfile' reports file type [`signature']"
			exit 610
		}
		else {
			di as error "`bigfile' is not valid Hadamard matrix file"
			exit 610
		}
	}

	tempname val nmat sz st

	file read `f' %1b `val'				/* set byte order as needed */
	local border=`val'
	file set `f' byteorder `border'

	file read `f' %2bu `nmat'			/* get number of matrices in file */
	local nm=`nmat'

	if substr("`sizewanted'",1,4)=="info" {
		forval i=1/`nm' {
			file read `f' %2bu `sz'
			file read `f' %4bu `st'
			local thesize=`sz'
			local sizes "`sizes'`thesize' "
		}
		di
		di "{txt}{p 5 5 10}Hadamard Matrices Available in {res}`bigfile'{txt}:"
		di "{res}{p 5 5 10}`sizes'"
		exit
	}

	forval i=1/`nm' {
		file read `f' %2bu `sz'
		file read `f' %4bu `st'
		*di "size: " `sz' "   Start: " `st'
		if `sz'>=`sizewanted' {
			local  tostart=`st'
			local sizewanted `sz'
			continue, break
		}
	}
	if "`tostart'"=="" {
		di as error "Matrix of size `sizewanted' or larger not in file"
		exit 198
	}

	local matsize : set matsize
	if `matsize'<`sizewanted'+1 {
		di as err "matsize must be at least " `sizewanted'+1 "to load matrix of size `sizewanted'"
		exit 908
	}

	file seek `f' `tostart'
	local n_el = `sizewanted'^2
	local n_line=`sizewanted'

	tempname rchar
	local n_char = `n_el'/8
	local c_line 1
	local c_e_ln 1
	tempname matl1

	forval i=1/`n_char' {

		file read `f' %1bu `rchar'
		DecBin `rchar'
		forval c_el=8(-1)1 {
			local el = (2*`s(b`c_el')')-1							/* convert 1/0 to +1/-1 */
			matrix `matl`c_line'' = nullmat(`matl`c_line''),`el'				/* build mat of +1/-1 */
			local c_e_ln=`c_e_ln'+1
			if `c_e_ln'>`n_line' {
				local c_e_ln 1
				mat `matnm'=nullmat(`matnm') \ `matl`c_line''
				local c_line=`c_line'+1
				tempname matl`c_line'
			}
		}

	}


	file close `f'

	tempname hhp test

	mat `hhp' = `matnm'*`matnm''
	mat `test' = `sizewanted'*I(`sizewanted')
	local diff = mreldif(`hhp',`test')
	if `diff' != 0 {
		matrix drop `matnm'
		di as error "Error with matrix that was read; `bigfile' may be corrupted"
		error 198
	}

	return local size=`sizewanted'
	return matrix matrix `matnm'

end /* GetHad */


program define FindFile

*TAKEN FROM icd9_ff.ado, version 1.0.1  30aug1999  STB-54: dm76

	version 6
	args fn clocal

	local sep : dirsep
	local ltr = substr(`"`fn'"',1,1)
	if `"`ltr'"' != "" {
		tokenize `"$S_ADO"', parse(" ;")
		while `"`1'"' != "" {
			if `"`1'"' != ";" {
				local realdir : sysdir `"`1'"'
				capture confirm file `"`realdir'`fn'"'
				if _rc==0 {
					c_local `clocal' `"`realdir'`fn'"'
					exit
				}
				capture confirm file `"`realdir'`ltr'`sep'`fn'"'
				if _rc==0 {
					c_local `clocal' `"`realdir'`ltr'`sep'`fn'"'
					exit
				}
			}
			mac shift
		}
	}
	di in red `"Hadamard matrix file not found"'
	exit 601
end /* FindFile */

program define DecBin, sclass
	*Program to convert decimal number to binary
	args dec
	sreturn clear
	sreturn local dec "`dec'"

	local t1 1
	local t2 2
	local t3 4
	local t4 8
	local t5 16
	local t6 32
	local t7 64
	local t8 128
	forval c=8(-1)1 {
		if `dec'>=`t`c'' {
			local b`c' 1
			local dec=`dec'-`t`c''
		}
		else {
			local b`c' 0
		}
		sreturn local b`c' "`b`c''"
	}

*	sreturn local bin "`b8'`b7'`b6'`b5'`b4'`b3'`b2'`b1'"
end /* DecBin */

exit

