*! 	-powersim- version 1.0.1 JL 30August2013
*	Simulation-based power analysis for 
*	linear and generalized linear models


program define powersim, rclass

	version 11.2

	gettoken 0 after : 0, parse(":")
	gettoken colon cmd : after, parse(":")
	
	syntax [ using/ ] , 			///
	b(numlist) 						///
	POSition(integer)				///
	SAMPLEsize(numlist)				///
	Family(string)					///
	[ 								///
	nreps(integer 500) 				///
	Alpha(real 0.05) 				///
	null(real 0)					///
	SAVing(string)					///
	DRYrun							///
	DETail							///
	GENdata							///
	nobs(integer 10000)				///
	seed(string)					///
	expb							///
	inside							///
	nodots 							///
	SILent							///
	Link(string)					///
	cons(string)					///
	cov1(string)  					/// 
	cov2(string)					///
	cov3(string)					///
	block22(string)					///
	corr12(string)					///
	corr13(string)					///
	corr23(string)					///
	inter1(string)					///
	inter2(string)					///
	inter3(string)					///
	df(string)						///
	DOfile(string)					///
	maxiter(integer 200)			///
	ADDscalar(string)				///
	force							///
	]


	// Some initial checks
	cap scalar drop _bp 
	
	if "`cmd'" == "" & "`gendata'" == "" {
		di as err "Either specify analysis model or -gendata- option"
		exit 499
	}
	
	local nadd : word count "`addscalar'"
	if `nadd' > 1 {
		di as err "Only one scalar may be specified in -addscalar()-"
	}
	
	if "`silent'" != "" {
		local dots nodots 
	}
	
	if "`using'" != "" & "`link'" != "" {
		local nl "Note: link function defined in existing do-file; -link()- option ignored"
		di as txt "`nl'"
		local link
	}
	
	// Check saving
	if "`saving'" != "" {
		if strmatch("`saving'", "*,*") == 1 {
			local n1 = strpos("`saving'",",") - 1
			local n2 = strpos("`saving'",",") + 1
			local sav = trim(substr("`saving'",1,`n1'))
			local savrep = trim(substr("`saving'",`n2',.))
			if "`savrep'" != "" & "`savrep'" != "replace" {
				di as err "Check -saving()- option."
				exit 499
			}
			if "`savrep'" == "" {
				confirm new file "`sav'.dta"
			}
		}
		else {
			local sav = trim("`saving'")
			confirm new file "`sav'.dta"
		}
	}
	
	// Check created do-file
	if "`dofile'" != "" {
		if strmatch("`dofile'", "*,*") == 1 {
			local n1 = strpos("`dofile'",",") - 1
			local n2 = strpos("`dofile'",",") + 1
			local dof = trim(substr("`dofile'",1,`n1'))
			local dorep = trim(substr("`dofile'",`n2',.))
			if "`dorep'" != "" & "`dorep'" != "replace" {
				di as err "Check -dofile()- option."
				exit 499
			}
			if "`dorep'" == "" {
				confirm new file "`dof'.do"
			}
		}
		else {
			local dof = trim("`dofile'")
			confirm new file "`dof'.do"
		}
	}	
	
	// Check existing do-file
	if "`using'" != "" {
		local ex = trim("`using'")
		confirm file "`using'.do"
	}
	
	// Check numlists
	numlist "`samplesize'", ascending integer range(>0)
	local sa "`r(numlist)'"
	numlist "`b'", ascending
	local b1 "`r(numlist)'"
	
	// Total requested
	local nr = `: word count `sa''*`: word count `b1''*`nreps'

	// Dots
	local nodots `dots'
	local fam = lower("`family'")
	
	// Max iterations model
	if "`: word 1 of `cmd''" == "glm" {
		if strmatch("`cmd'", "*,*") == 1 {
			local cmd = "`cmd' iterate(`maxiter')"
		}
		else {
			local cmd = "`cmd' , iterate(`maxiter')"
		}
	}
	
	// Ensure outcome is named y
	if "`cmd'" != "" {
		local depvar : word 2 of `cmd'
		if "`depvar'" != "y" {
			di as err "Outcome variable must be named y"
			exit 499
		}
	}
	
	// interpret coefficients as exp(b)
	if `null' == 0 & "`expb'" != "" {
		local null 1
	}
	
	if "`expb'" != "" {
		local w 1
		local b2 `b1'
		foreach t of numlist `b1' {
			local ex`w' = log(`t')
			local bex `bex' `ex`w''			
			local ++w
		}
		local b1 `bex'
		
		if `null' <= 0 {
			di as err "Check H0 value"
			exit 499
		}
		if `null' > 0 local null = log(`null')
	}
		
	// Initial seed
	if "`seed'"!="" {
		set seed `seed'
	}
	local inis `=c(seed)'

	// Parse family, scale/ancillary params, and link
	local family = lower("`family'")
	local wcf : word count `family'
	
	if `wcf' > 2 {
		di as err "Check -family()- option, too many arguments"
		exit 499
	}
		
	if `wcf' == 1 {
		if inlist("`family'", "gaussian", "gamma", "nbinomial", "binomial") == 1 {
			local scan 1			
		}
		else if inlist("`family'", "igaussian") == 1 {
			local scan 0.25			
		}
	}
	else if `wcf' == 2 {
		local fam : word 1 of `family'
		local scan : word 2 of `family'
		if inlist("`fam'", "gaussian", "gamma", "nbinomial", "igaussian", "binomial") == 0 {
			di as err "Check -family()- option"
			exit 499
		}
		local family `fam'
 	}
		
	if inlist("`family'", "gaussian", "gamma", "nbinomial", ///
		"binomial", "poisson", "igaussian" ) == 0 {
		di as err "Check -family()- option, unknown family name"
		exit 499
	}
		
	// Create do-file for data generation
	if "`using'" == "" {
		_psimdat ,			///		
		family(`family')	///
		link(`link')		///
		nbalpha(`scan')		///
		cons(`cons')		///
		cov1(`cov1')  		/// 
		cov2(`cov2')		///
		cov3(`cov3')		///
		block22(`block22')	///
		corr12(`corr12')	///
		corr13(`corr13')	///
		corr23(`corr23')	///
		inter1(`inter1')	///
		inter2(`inter2')	///
		inter3(`inter3')	///
		dofile(`dofile')	///
		`expb'
		
		local using "`dof'"
		
	}

	// Generate dataset
	if "`gendata'" != "" {
	
		local bgen : word 1 of `b1'
	
		_gendat, 			///
		bp(`bgen')			///
		family(`fam')		///
		dofile(`using')		///
		obs(`nobs')			///
		seed(`seed')		///
		scan(`scan')		
		
		exit
	}
	
	// Dry run
	if "`dryrun'" != "" {
		preserve
			local bdry : word 1 of `b1'
			local depvar : word 2 of `cmd'
			scalar _bp = `bdry'
			clear
			
			local ndry : word 1 of `sa'
			
			qui set obs `ndry'
			
			if "`detail'" != "" {
				di as txt "{hline 78}"
				di
				di as res "powersim dry run:"
				di
				di as txt "do-file used for data generation:"
				di
				noi do "`using'"
			}
			else qui do "`using'"
			
			qui count if mi(xb) 
			if r(N) > 0 di as err "Warning: " as txt "missing values in xb"

			qui gen double `depvar' = xb
			
			if "`detail'" == "" {
				di as txt "{hline 78}"
				di
				di as res "powersim dry run:"
			}
			
			di
			di as txt "Data generating model: " as res "family(`fam' `scan') link(`link')"
			di as txt "Analysis model command: " as res trim("`cmd'")
			di
			
			local ecmd : word 1 of `cmd'
			if inlist("`ecmd'", "reg", "regr", "regre", "regres", "regress") == 1 {
				local ecmd = "regress"
			}
	
			if "`ecmd'" != "glm" & "`ecmd'" != "regress" {
				di as err "Note: " as txt "model specifics not available for commands other than -regress- or -glm-"
			}

			if "`ecmd'" == "glm" | "`ecmd'" == "regress" {
				
				qui `cmd'
				_dry
				
				di
				di as txt "Matrix e(b) from analysis model (check column position of effect of interest):"
				
				mat li e(b)
				di
				di as txt "Position specified in option position(#): " as res `position'
				di
				
				if "`fam'" == "gaussian" {
					di as txt "SD of Gaussian error: " as res `scan'
					di
				}
				else if "`fam'" == "nbinomial" {
					di as txt "Overdispersion parameter alpha: " as res `scan'
					di
				}
				else if "`fam'" == "gamma" {
					di as txt "Gamma scale parameter: " as res `scan'
					di
				}
				else if "`fam'" == "igaussian" {
					di as txt "Inverse Gaussian scale parameter: " as res `scan'
					di
				}
				else if "`fam'" == "binomial" {
					if `scan' == 1 {
						di as txt "Binomial, n of trials: " as res `scan' as txt " (Bernoulli)"
					}
					else di as txt "Binomial, n of trials: " as res `scan'
					di
				}
				di as txt "{hline 78}"
			}
		restore
		exit
	}
	
	// Passing stuff to _psim0
	_psim0, 			///
	b(`b1')  			///
	sample(`sa')		///
	nreps(`nreps') 		///
	alpha(`alpha')		///
	cmd(`cmd')			///
	using(`using')		///
	pos(`position')		///
	fam(`fam') 			///
	null(`null')		///
	scan(`scan') 		///
	add(`addscalar') `expb' `inside' `nodots' `silent' `force' df(`df')
	
	// Results
	label var nd "Iteration ID"
	label var b "Estimated coefficient b"
	label var se "Standard error of b"
	label var p "p-value"
	label var n "Sample size"
	label var c95 "95% CI coverage (1=covered)"
	label var power "1 = p < `alpha'"
	label var esize "Specified effect size"
	label var esize_id "Specified effect size (factor)"
	
	order nd esize esize_id n b se p power c95
	
	if "`addscalar'" != "" {
		label var `addscalar' "Added scalar e(`addscalar')"
	}
	
	if "`saving'" !="" {
		qui save `sav', `savrep'
	}
	
	tempname res
	preserve
		collapse (mean) power esize_id , by(esize n)
		mkmat _all, mat(`res')
	restore
		
	// Output
	di
	di as txt "{hline 77}"
	di
	di as txt "Power analysis simulations"
	di 
	di
	if "`expb'" != "" {
		di as txt "Effect sizes exp(b): " _col(23) as res "`b2'"
	}
	else di as txt "Effect sizes b: " _col(23) as res "`b1'"
	
	if "`expb'" != "" {
		di as txt "H0: " _col(23) as res "exp(b) = `=exp(`null')'"
	}
	else di as txt "H0: " _col(23) as res "b = `null'"
	
	di as txt "Sample sizes: " _col(23) as res "`sa'"
	di as txt "alpha: " _col(23) as res `alpha'	
	di as txt "N of replications*: " _col(23) as res `nreps'
	di
	di as txt "do-file used for data generation: " _col(31) as res "`using'"
	di as txt "Model command: " _col(35) as res trim("`cmd'")
	di
	di 
	di as txt "Power by sample and effect sizes:"
	
	qui cou if !mi(n) 
	local nmc = r(N)
	if `nmc' == 0 {
		di as err "No successful replications"
		exit
	}
	table n esize, c(mean power) format(%4.3f)
	di
	di as txt "Total N of requested  MC replications: " _col(31) as res `nr'
	di as txt "Total N of successful MC replications: " _col(31) as res `nmc'
	di
	di as txt "* per sample and effect size combination"
	di
	di as txt "{hline 77}"
	
	// Saved results
	return local iseed "`inis'"
	return local samples "`sa'"
	if "`expb'" != "" {
		return local effects "`b2'"
	}	
	else return local effects "`b1'"
	return local cmd "powersim"	
	return local model "`cmd'"
	return scalar alpha = `alpha'
	return scalar niter = `nreps'
	return mat power = `res'
	
	// Drop scalar
	scalar drop _bp
	
end

*----------------------------------------------

program define _psim0

	syntax , 						///
	b(numlist) 						///
	SAMPLEsize(numlist)				///
	nreps(integer) 					///
	alpha(real) 					///
	cmd(string)						///
	using(string) 					///
	pos(integer)					///
	fam(string)						///
	null(real)						///
	[ 								///
	scan(string) 					///
	add(string) 					///
	expb 							///
	inside 							///
	nodots 							///
	silent							///
	force							///
	df(string)						///
	]
	
		
	local a 1	
	local nodots `dots'

	foreach m of local b {

		scalar _bp = `m'
		local es : word `a' of `b'
		local es : display %4.3f `es'
		if "`expb'" != "" {
			local es : display %4.3f exp(`es')
			local eb1 "exp("
			local eb2 ")"
		}
		
		// Run simulations
		if "`silent'" == "" {
			di as txt "{break}{hline 77}" 
			di
			di as txt "Power simulations:"
			di
			di as txt "Model: " _col(21) as res "`cmd'"
			di as txt "Effect: " _col(21) as res "`eb1'b`eb2' = `es'"
			di as txt "alpha: " _col(21) as res "`alpha'"
			di
		}

		foreach s of local samplesize {
		
			if "`silent'" == "" {
				di as txt "{break}{hline 77}" 
				di
				di as txt "n of replications: " _col(21) as res `nreps'
				di as txt "sample size: " _col(21) as res `s'
			}

			_psim1 `s', b(`m') 		///
			nreps(`nreps') 			///
			alpha(`alpha')		 	///
			cmd(`cmd')				///
			using(`using')			///
			pos(`pos')				///
			fam(`fam')				/// 
			null(`null')			///
			scan(`scan') 			///
			add(`add') `expb' `inside' `nodots' `force' df(`df')
			
			tempfile simdat_`s'
			qui save `simdat_`s''

		}

		// Combine and process data (varying sample sizes)
		local c = 1
		foreach s of local samplesize {
			if `c'==1 {
				use `simdat_`s'', clear
			}
			else {
				append using `simdat_`s''
			}
			local ++c
		}
				
		local ms = subinstr("`m'", "." ,"_",1)
		local ms = subinstr("`ms'", "-" ,"neg",1)
		tempfile sim_result_`ms'
		if "`expb'" != "" {
			gen double esize = exp(`m')
		}
		else gen double esize = `m'
		gen byte esize_id = `a'
		qui save `sim_result_`ms''
		local ++a

	}
	
	// Combine and process data (varying effect sizes)
	local c = 1
	
	foreach bs of local b {
		local lab = "`bs'"
		local bs = subinstr("`bs'", "." ,"_",1)
		local bs = subinstr("`bs'", "-" ,"neg",1)
		
		if `c'==1 {
			use `sim_result_`bs'', clear
		}
		else {
			append using `sim_result_`bs'', nolabel
		}
		
		lab def eid `c' "`lab'", add
		lab val esize_id eid
		local ++c
	}
		
	tempfile sim_result_all
	qui save `sim_result_all'
	use `sim_result_all', clear

end

*----------------------------------------------

program define _psim1

	syntax anything(name=ndata), 	///
	b(string) 						///
	nreps(integer) 					///
	alpha(real) 					///
	cmd(string)						///
	using(string)					///
	pos(integer)					///
	fam(string)						///
	null(real)						///
	[ scan(string) add(string) expb inside nodots force df(string) ]
		

	local N `ndata'
	local M `nreps'

	local b1 `b'
	
	local dots = cond("`dots'" != "", "*", "_dots")
	
	*---------------------------
	// Generating predictor data 
	
	if "`inside'" == "" {
		clear
		qui set obs `N'
		qui do "`using'"
	}
	*---------------------------
	
	local add2 `add'
	tempvar nd b se p n c95 `add'
	
	// Parse model command
	local ecmd : word 1 of `cmd'
	
	if inlist("`ecmd'", "reg", "regr", "regre", "regres", "regress") == 1 {
		local ecmd = "regress"
	}
		
	if "`ecmd'" == "regress" & "`df'" == "" local df df_r
		
	if "`ecmd'" != "regress" & "`ecmd'" != "glm" & "`force'" == "" {
		di as err "command -`ecmd'- not explicitly supported;"
		di as err "use -force- option if you know what you are doing and"
		di as err "ensure that -powersim- properly picks up model results"
		exit 499
	}
	
	// Running simulations in Mata
	mata: sims()

	// Store results
	qui {
		gen double nd = `nd'
		gen double b = `b'
		gen double se = `se'
		gen double p = `p'
		gen double n = `n'
		gen byte c95 = `c95'
		gen byte power = p < `alpha' if !missing(p)
		
		if "`add2'" != "" {
			gen double `add2' = `add'
		}
	}

end

*----------------------------------------------

cap program drop _psimdat
program define _psimdat

	syntax  ,		///
	family(string)	///
	link(string)	///
	dofile(string)	///
	[				///
	cov1(string)  	/// 
	cov2(string)	///
	cov3(string)	///
	block22(string)	///
	nbalpha(string)	///
	cons(string)	///
	corr12(string)	///
	corr13(string)	///
	corr23(string)	///
	inter1(string)	///
	inter2(string)	///
	inter3(string)	///
	expb			///
	]

	
	// Saving/replacing do file, parsing
	if strmatch("`dofile'", "*,*") == 1 {
		local na1 = strpos("`dofile'",",") - 1
		local na2 = strpos("`dofile'",",") + 1
		local dof = trim(substr("`dofile'",1,`na1'))
		local replace = trim(substr("`dofile'",`na2',.))
	}
	else local dof = trim("`dofile'")
	
	// check link
	local wc : word count `link'
	if `wc' > 2 {
		di as err "Check link argument(s)"
		exit 499
	}
	else if `wc' == 1 & ("`: word 1 of `link''" == "power" | "`: word 1 of `link''" == "opower") {
		di as err "Check link argument(s)"
		exit 499
	}
	else if `wc' > 1 & ("`: word 1 of `link''" != "power" & "`: word 1 of `link''" != "opower") {
		di as err "Check link argument(s)"
		exit 499
	}
	else if `wc' == 2 & "`: word 1 of `link''" == "power" {
		local pow = real("`: word 2 of `link''")
		local link : word 1 of `link'
		if `pow' != 0 local power "^(1/`pow')"
		else if `pow' == 0 local link log
	}
	else if `wc' == 2 & "`: word 1 of `link''" == "opower" {
		local op = real("`: word 2 of `link''")
		local link : word 1 of `link'
		if `op' == 0 local link logit
	}	
	
	// Check cov order
	if ("`cov2'" != "" | "`cov3'" != "") & "`cov1'" == "" {
		di as err "Covariates out of order"
		exit 499
	}
	if ("`cov1'" != "" & "`cov3'" != "") & "`cov2'" == "" {
		di as err "Covariates out of order"
		exit 499
	}
	
	// check number of arguments in option
	forval i = 1/3 {
	
		local wc : word count `cov`i''
		
		if (`wc' < 4 | `wc' > 5) & `wc' != 0 {
			di as err "Check covariate arguments"
			exit 499
		}
		else if `wc' == 4 & ("`: word 3 of `cov`i'''" != "poisson" & "`: word 3 of `cov`i'''" != "binomial" & "`: word 3 of `cov`i'''" != "block" & "`: word 3 of `cov`i'''" != "chi2" & "`: word 3 of `cov`i'''" != "studentt") {
			di as err "Check covariate arguments"
			exit 499
		}
		else if `wc' == 5 & "`: word 3 of `cov`i'''" != "normal" & "`: word 3 of `cov`i'''" != "gamma" & "`: word 3 of `cov`i'''" != "beta" & "`: word 3 of `cov`i'''" != "nbinomial" & "`: word 3 of `cov`i'''" != "uniform" {
			di as err "Check covariate arguments"
			exit 499
		}
	}

	// check corr input
	if "`corr12'" != "" {
		if "`: word 3 of `cov1''" != "normal" | "`: word 3 of `cov2''" != "normal" {
			di as err "Correlated variables have to be normally distributed"
			exit 499
		}
	}
	if "`corr13'" != "" {	
		if "`: word 3 of `cov1''" != "normal" | "`: word 3 of `cov3''" != "normal" {
			di as err "Correlated variables have to be normally distributed"
			exit 499
		}
	}
	if "`corr23'" != "" {	
		if "`: word 3 of `cov2''" != "normal" | "`: word 3 of `cov3''" != "normal" {
			di as err "Correlated variables have to be normally distributed"
			exit 499
		}
	}

	// overdispersion parameter for link NB
	local alpha `nbalpha'
	
	// get covariate names

	forval i = 1/3 {
		local name`i' : word 1 of `cov`i''
		local name `name' `name`i''
	}

	*n of covariates
	local ncov : word count `name'

	// get covariate distribution
	forval i = 1/`ncov' {  

		local dist`i' : word 3 of `cov`i''
		
		if "`dist`i''" == "uniform" {
			local pgen`i' : word 4 of `cov`i''
			local pgen2`i' : word 5 of `cov`i''
			local gen`i' = "generate double `name`i'' = (`pgen2`i''-`pgen`i'')*runiform() + `pgen`i''"
		}
		else if "`dist`i''" == "binomial" {
			local pgen`i' : word 4 of `cov`i''
			local gen`i' = "generate byte `name`i'' = runiform() < `pgen`i''"
		}
		else if "`dist`i''" == "poisson" {
			local pgen`i' : word 4 of `cov`i''
			local gen`i' = "generate long `name`i'' = rpoisson(`pgen`i'')"
		}
		else if "`dist`i''" == "chi2" {
			local pgen`i' : word 4 of `cov`i''
			local gen`i' = "generate double `name`i'' = rchi2(`pgen`i'')"
		}		
		else if "`dist`i''" == "studentt" {
			local pgen`i' : word 4 of `cov`i''
			local gen`i' = "generate double `name`i'' = rt(`pgen`i'')"
		}
		else if "`dist`i''" == "gamma" {
			local pgen`i' : word 4 of `cov`i''
			local pgen2`i' : word 5 of `cov`i''
			local gen`i' = "generate double `name`i'' = rgamma(`pgen`i'', `pgen2`i'')"
		}
		else if "`dist`i''" == "beta" {
			local pgen`i' : word 4 of `cov`i''
			local pgen2`i' : word 5 of `cov`i''
			local gen`i' = "generate double `name`i'' = rbeta(`pgen`i'', `pgen2`i'')"
		}
		else if "`dist`i''" == "nbinomial" {
			local pgen`i' : word 4 of `cov`i''
			local pgen2`i' : word 5 of `cov`i''
			local gen`i' = "generate double `name`i'' = rnbinomial(`pgen`i'', `pgen2`i'')"
		}
		else if "`dist`i''" == "block" {
		
			local pgen`i' : word 4 of `cov`i''
			
			if inlist(`pgen`i'', 2, 3, 4) == 0 {
				di as err "Block design must be for 2, 3, or 4 groups"
				exit 499
			}
			
			if `pgen`i'' == 2 {
				local gen`i' = "generate int `name`i'' = mod(_n-1, 2) == 1"
			}	
			if `pgen`i'' == 3 {
				local gen`i' = "generate int `name`i'' = cond(mod(_n-1, 3) == 1, 1, cond(mod(_n-1, 3) == 0, 2, 3))"
			}
			if `pgen`i'' == 4 {
				local gen`i' = "generate int `name`i'' = cond(mod(_n-1, 4) == 1, 1, cond(mod(_n-1, 4) == 0, 2, cond(mod(_n-1, 2) == 0, 3, 4)))"
			}	
		}
	}
	
	* 2x2 block design		
	if "`block22'" != "" {
		local wc : word count `block22'	
		if `wc' != 4 & `wc' != 5 {
			di as err "Check -block22()- option"
			exit 499
		}
		tokenize `block22'
		local blgen1 = "generate byte `2' = mod(_n-1, 4) == 1 | mod(_n-1, 4) == 3"
		local blgen2 = "generate byte `4' = mod(_n-1, 4) == 2 | mod(_n-1, 4) == 3"
		if `wc'==4 {
			local bbm "+ `1'*`2' + `3'*`4'"
		}
		else {
			local bbm "+ `1'*`2' + `3'*`4' + `5'*`2'*`4'"
		}
	}

	// get effects b / exp(b)
	forval i = 1/`ncov' {
		local b`i' : word 2 of `cov`i''
		if "`expb'" != "" & "`b`i''" != "_bp" {
			local b`i' = log(`b`i'')
		}
	}

	// get interaction effects
	forval i = 1/3 {
		local bint`i' : word 1 of `inter`i''
		local xint`i' : word 2 of `inter`i''
		local plus = cond("`bint`i''"!="", "+", "")
		local prod = cond("`bint`i''"!="", "*", "")
		local bint " `bint' `plus' `bint`i''`prod'`xint`i''"
	}

	// constant
	if "`cons'" != "" {
		local cons " `cons' "
		local pl +
	}
	
	// get parameters for normal
	* means
	forval i=1/`ncov' {
		if inlist("`dist`i''", "normal", "poisson") == 1 {
			local m`i' : word 4 of `cov`i''
		}
	}
	* sds
	forval i=1/`ncov' {
		if inlist("`dist`i''", "normal") == 1 {
			local sd`i' : word 5 of `cov`i''
		}
	}		

	// create indexes 
	if "`corr12'" != "" | "`corr13'" != "" | "`corr23'" != "" {

		local idxa = cond("`corr12'" != "", "3", "")
		local idxb = cond("`corr13'" != "", "4", "")
		local idxc = cond("`corr23'" != "", "5", "")
		local plus1 = cond("`corr13'" != "", "+", "")
		local plus2 = cond("`corr23'" != "", "+", "")
		local idx = `idxa' `plus1' `idxb' `plus2' `idxc'
			
		if `idx' == 3 {
			local matm = "matrix __M=(`m1', `m2')"
			local mats = "matrix __SD=(`sd1', `sd2')"
			local cnames `name1' `name2'
			local not `name3'
			local notidx 3
		}
		else if `idx' == 4 {
			local matm = "matrix __M=(`m1', `m3')"
			local mats = "matrix __SD=(`sd1', `sd3')"
			local cnames `name1' `name3'
			local not `name2'
			local notidx 2
		}
		else if `idx' == 5 {
			local matm = "matrix __M=(`m2', `m3')"
			local mats = "matrix __SD=(`sd2', `sd3')"
			local cnames `name2' `name3'
			local not `name1'
			local notidx 1
		}
		else if `idx' >= 7 & `idx' <= 12 {
			local matm = "matrix __M=(`m1', `m2', `m3')"
			local mats = "matrix __SD=(`sd1', `sd2', `sd3')"
			local cnames `name1' `name2' `name3'
		}
			
		// get correlations
		local c1 `corr12'
		local c2 `corr13'
		local c3 `corr23'

		local cmat = "`c1' `c2' `c3'"
		local wc : word count `cmat'

		if `wc' == 3 {
			local matc = "matrix __C = (1, `c1', `c2', 1, `c3', 1)"
		}
		else if `wc' == 2 & `idx' == 7 {
			local matc = "matrix __C = (1, `c1', `c2', 1, 0, 1)"
		}
		else if `wc' == 2 & `idx' == 8 {
			local matc = "matrix __C = (1, `c1', 0, 1, `c3', 1)"
		}
		else if `wc' == 2 & `idx' == 9 {
			local matc = "matrix __C = (1, 0, `c2', 1, `c3', 1)"
		}
		else if `wc' == 1 & `idx' == 3 {
			local matc = "matrix __C = (1, `c1', 1)"
		}
		else if `wc' == 1 & `idx' == 4 {
			local matc = "matrix __C = (1, `c2', 1)"
		}
		else if `wc' == 1 & `idx' == 5 {
			local matc = "matrix __C = (1, `c3', 1)"
		}
	} 				   
					   
	// creating do-file
	tempname fh
	
	file open `fh' using `dof'.do, write `replace'

	*Variables
	file write `fh' "*---------------------------" _n
	file write `fh' "// Generating predictor data" _n
	file write `fh' _n

	if "`matm'" != "" file write `fh' "`matm'" _n
	if "`mats'" != "" file write `fh' "`mats'" _n
	if "`matc'" != "" file write `fh' "`matc'" _n
	if "`matc'" != "" file write `fh' _n

	if "`corr12'" != "" | "`corr13'" != "" | "`corr23'" != "" {
		file write `fh' "drawnorm " "`cnames'" " , ///" _n
		file write `fh' "means(__M) sds(__SD) corr(__C) ///" _n
		file write `fh' "cstorage(upper) forcepsd double" _n
		
		if `idx'==3 | `idx'==4 | `idx'==5 {
			if "`gen`notidx''" == "" & `ncov' > 2 {
				file write `fh' "generate double `not' = rnormal(`m`notidx'',`sd`notidx'')" _n
			}
		}
	}

	if "`corr12'" == "" & "`corr13'" == "" & "`corr23'" == "" {
		forval i=1/`ncov' {
			if "`gen`i''" == "" {
				file write `fh' "generate double `name`i'' = rnormal(`m`i'', `sd`i'')" _n
			}
		}
	}

	file write `fh' _n
	if "`gen1'" != "" file write `fh' "`gen1'" _n
	if "`gen2'" != "" file write `fh' "`gen2'" _n
	if "`gen3'" != "" file write `fh' "`gen3'" _n
	if "`blgen1'" != "" file write `fh' "`blgen1'" _n
	if "`blgen2'" != "" file write `fh' "`blgen2'" _n

	file write `fh' _n
	file write `fh' "*---------------------------" _n
	file write `fh' _n
	
	*Link mu
	if `ncov' > 0 {
		local n2 `pl' `b1'*`name1'
		forval i=2/`ncov' { 
			local n2 `n2' + `b`i''*`name`i'' 
		}
	}
	local n2 `n2' `bbm'

	file write `fh' "*-----------------------------------------" _n
	file write `fh' "// Link function with specified parameters" _n
	file write `fh' "*  link = `link' `pow'`op'" _n
	file write `fh' _n

	if "`link'" == "identity" {
		file write `fh' "`=itrim("generate double xb = `cons' `n2'`bint'")'" _n
	}
	else if "`link'" == "log" {
		file write `fh' "`=itrim("generate double xb = exp(`cons' `n2'`bint')")'" _n
	}
	else if "`link'" == "logit" {
		file write `fh' "`=itrim("generate double xb = 1 / (1 + exp(-(`cons' `n2'`bint')))")'" _n
	}
	else if "`link'" == "probit" {
		file write `fh' "`=itrim("generate double xb = normal(`cons' `n2'`bint')")'" _n
	}
	else if "`link'" == "cloglog" {
		file write `fh' "`=itrim("generate double xb = 1 - exp(-exp(`cons' `n2'`bint'))")'" _n
	}
	else if "`link'" == "power" {
		file write `fh' "`=itrim("generate double xb = (`cons' `n2'`bint')`power'")'" _n 
	}
	else if "`link'" == "opower" {
		file write `fh' "`=itrim("generate double xb = (1 + `op'*(`cons' `n2'`bint'))^(1/`op') / (1 + (1 + `op'*(`cons' `n2'`bint'))^(1/`op'))")'" _n
	}
	else if "`link'" == "nbinomial" {
		file write `fh' "`=itrim("generate double xb = 1 / (`nbalpha' * (exp( - (`cons' `n2'`bint')) - 1))")'" _n
	}
	else if "`link'" == "loglog" {
		file write `fh' "`=itrim("generate double xb = exp(-exp(`cons' `n2'`bint'))")'" _n
	}
	else if "`link'" == "logc" {
		file write `fh' "`=itrim("generate double xb = 1 - exp(`cons' `n2'`bint')")'" _n
	}
	
	file write `fh' _n
	file write `fh' "*-----------------------------------------" _n

	file close `fh'

end

*----------------------------------------------

program define _dry, eclass

	tempname b v

	mat `b' = e(b)
	mat `v' = e(V)*0

	ereturn post `b' `v', depname(y) 
	ereturn display

end

*----------------------------------------------

program define _gendat

	syntax ,			///
	bp(string)			///
	obs(integer)		///
	family(string)		///
	dofile(string)		///
	[ 					///
	scan(string)		///
	seed(string) 		///
	]
	
	clear
	qui set obs `obs'
	if "`seed'" != "" set seed `seed' 
	
	scalar _bp = `bp'

	qui do "`dofile'"
		
	qui cou if mi(xb)
	if r(N) > 0 {
		di
		di as err "Warning: " as txt "missing values in xb"
	}
		
	mata : _dgen()
	
	qui cou if mi(y)
	if r(N) > 0 {
		di
		di as err "Warning: " as txt "missing values in y"
	}
	
	label var y "Outcome variable"
	label var xb "Expected values of y (true)"
	qui ds y xb, not
	if "`r(varlist)'" != "" {
		foreach v of varlist `r(varlist)' {
			label var `v' "Predictor variable"
		}
	}

end

*----------------------------------------------

version 11.2
mata:

function sims()
{
	M = strtoreal(st_local("M"))
	pos = strtoreal(st_local("pos"))
	fam = st_local("fam")
	inside = st_local("inside")
	ecmd = st_local("ecmd")
	scan = strtoreal(st_local("scan"))
	btrue = strtoreal(st_local("b1"))
	null = strtoreal(st_local("null"))
	add = st_local("add")
	dfstr = st_local("df")
	
	if (dfstr != "") edf = "e("+dfstr+")"
	if (add != "") esc = "e("+add+")"
	if (add == "") pval = J(M,6,.)
	else pval = J(M,7,.)
	
	if (inside == "") {
		st_view(xb=., ., "xb")
	}
	
	stata(`"\`dots' 0"')
		
	for (i=1; i<=M; i++) {
	
		if (inside != "") {
			stata("clear")
			stata(`"qui set obs \`N'"')
			stata(`"qui do \`using'"', 1)
			st_view(xb=., ., "xb")
		}
		
		cn = colmissing(xb)
		if (cn > 0) {
			printf("\n")
			printf("Data generation produced missing values (in xb).\n")
			exit(error(499))
		}
		
		N = rows(xb) 
		
		y = _dgfam(xb, fam, N, scan)
				
		n = colmissing(y)
		if (n > 0) fail = i
		
		sd = sd(y)
		if (sd == 0) fail = i
		
		if (fail != i) {
			rc = _stata(`" \`cmd'"', 1)	 
			if (rc == 1) exit(error(1))
			else if (rc > 1) fail = i
			conv = st_numscalar("e(converged)")
		}
		
		if (i == 1 & add != "") {
			stata(`"local u = e(\`add') == ."')
			u = st_local("u")
			if (u == "1") {
				printf("\n")
				printf("Added scalar not available: %s\n", esc)
				exit(error(499))
			}	
		}

		if (fail != i & conv != 0) {
		
			mb = st_matrix("e(b)")
			mv = st_matrix("e(V)")
			
			if (dfstr != "") {
				stata(`"local dfcheck = e(\`df') < ."')
				if (strtoreal(st_local("dfcheck")) == 0) {
					printf("scalar not found: %s\n", edf)
					exit(error(499))
				}
				df = st_numscalar(edf)
			}
			
			b = mb[1,pos]
			se = sqrt(mv[pos,pos])
			bse = (b - null) / se /*  check validity for non-linear models */
			
			if (ecmd == "regress" | dfstr != "") {
				p = 2*ttail(df,abs(bse))
				c95 = abs(btrue - b) < abs(invttail(df, .975))*se	
			}
			else {
				p = 2*normal(-abs(bse))
				c95 = abs(btrue - b) < 1.959964*se
			}
			
			pval[i,1] = i
			pval[i,2] = b
			pval[i,3] = se
			pval[i,4] = p
			pval[i,5] = N
			pval[i,6] = c95
			
			if (add != "") {
				pval[i,7] = st_numscalar(esc)
			}
			
			st_local("iter", strofreal(i))
			stata(`"\`dots' \`iter' 0"')
			
		}
		
		else {
			st_local("iter", strofreal(i))
			stata(`"\`dots' \`iter' 1"')
		}
		
	}
	
	ndraw = pval[.,1]
	effect = pval[.,2]
	stde = pval[.,3]
	pv = pval[.,4]
	samp = pval[.,5]
	cover95 = pval[.,6]
	if (add != "") {
		escalar = pval[.,7] 
	}
	
	stata("qui clear")
	stata(`"qui set obs \`M'"')

	idx1=st_addvar("double", nd=st_tempname())
	idx2=st_addvar("double", b=st_tempname())
	idx3=st_addvar("double", se=st_tempname())
	idx4=st_addvar("double", p=st_tempname())
	idx5=st_addvar("double", n=st_tempname())
	idx6=st_addvar("double", c95=st_tempname())
	st_store((1,rows(ndraw)),idx1,ndraw)
	st_store((1,rows(effect)),idx2,effect)
	st_store((1,rows(stde)),idx3,stde)
	st_store((1,rows(pv)),idx4,pv)
	st_store((1,rows(samp)),idx5,samp)
	st_store((1,rows(cover95)),idx6,cover95)
	st_local("nd",nd)
	st_local("b",b)
	st_local("se",se)
	st_local("p",p)
	st_local("n",n)
	st_local("c95",c95)
	
	if (add != "") {
		idx7=st_addvar("double", add=st_tempname())
		st_store((1,rows(escalar)),idx7,escalar)
		st_local("add",add)
	}
}

function _dgen()
{
	fam = st_local("family")
	scan = strtoreal(st_local("scan"))
	st_view(xb=., ., "xb")
	N = rows(xb)
	y = _dgfam(xb, fam, N, scan)
}

function _dgfam(real colvector xb, string scalar fam, real scalar N, real scalar scan)
{
	if (fam == "gaussian") {
		y = gauss(xb, scan, N)
	}
	else if (fam == "poisson") {
		y = poiss(xb)
	}
	else if (fam == "binomial") {
		y = binom(xb, scan)
	}
	else if (fam == "nbinomial") {
		y = nbinom(xb, N, scan)
	}
	else if (fam == "gamma") {
		y = gam(xb, scan)
	}
	else if (fam == "igaussian") {
		y = igauss(xb, scan)
	}
	
	stata("cap drop y")
	
	(void) st_addvar("double","y")
	st_store(.,"y",y)
		
	return(y)
}

function gauss(real colvector x, real scalar et, real scalar N)
{
	e = rnormal(N,1,0,et)
	y = x :+ e
	return(y)
}

function poiss(real colvector x)
{
	y = rpoisson(1,1,x)
	return(y)
}

function gam(real colvector x, real scalar b)
{
	y = rgamma(1,1,x,b)
	return(y)
}

function binom(real colvector x, real scalar nt)
{
	y = rbinomial(1,1,nt,x)
	return(y)
}

function nbinom(real colvector x, real scalar N, real scalar a)
{
	ia = 1/a
	g = rgamma(N,1,ia,a)
	xg = x:*g
	y = rpoisson(1,1,xg)
	return(y)
}

function igauss(real colvector x, real scalar sigma)
{
	y = rig(x, sigma)
	return(y)
}

function sd(real colvector x)
{
	N = length(x)
	m = mean(x)
	x2 = (x :- m):^2
	sd = sqrt(sum(x2)/N)
	return(sd)
}

/*The following RNG is a translation of Joseph Hilbe's and Walter Linde-Zwirble's
-rndivgx- command from their -rnd- package (STB-28: sg44)*/
function rig(real colvector x, real scalar sigma)
{
	mu = x
	N = rows(x)
	s = sigma^2*mu[1]
	p = mu[1]*((sqrt(4+9*s^2)-(3*s))/2)
	sq = sqrt(s*mu[1]^2)

	maxx =	exp(-(p-mu[1])*(p-mu[1])/(2*p*mu[1]*s)) / sqrt(2*s*pi()*(p^3)/mu[1])

	rn1 = runiform(N,1)
	rn2 = runiform(N,1)
	ds = J(N,1,1)
	ts = J(N,1,1)
	em = J(N,1,-1)
	t = J(N,1,-1)
	y = J(N,1,-1)
	
	sum1 = sum(ds)
	i=1

	while (sum1 > 0) {
		y = sin(pi():*rn1):/cos(pi():*rn1)
		
		ix = select(1::rows(ds), ds:==1)
		em[ix] = sq*y[ix] :+ p
		
		ix1 = select(1::rows(ts), (0 :> em :& ds:==1))
		ts[ix1] = ts[ix1]:*0
		
		ix2 = select(1::rows(t), (ts :== 1 :& ds:==1))
		t[ix2] = 0.66:*(1:+y[ix2]:^2):*exp(-(em[ix2]:-mu[ix2]):^2 ///
		:/ (2:*em[ix2]:*mu[ix2]:*s)) :/ sqrt(2:*s:*pi():*(em[ix2]:^3):/mu[ix2]) :/ maxx 
		
		ix3 = select(1::rows(ds), (rn2 :< t :& ts :== 1 :& ds:==1))
		ds[ix3] = ds[ix3]:*0
					
		rn1 = runiform(N,1)
		rn2 = runiform(N,1)
		t = J(N,1,-1)
		ts = J(N,1,1)
		sum1 = sum(ds)
		i = i + 1
	}
	return(em)
}

end



