*! xtdpdml.ado version 2.50 Richard Williams 07/06/2019
* Version history is at bottom of program
*
* Syntax:
* xtdpdml ystub xstub, inv(varlist) pre(prestub) other_options

program xtdpdml, eclass byable(recall)

	// Replay results if that is all that is requested. 

	if replay() {
			if "`e(semcmd)'" == "" & "`e(cmd)'" != "xxtdpdml" {
				display as error "xxtdpdml was not the last estimation command"
				exit 301
			}
			if _by() {
					display as error "You cannot use the by command " ///
							"when replaying xxtdpdml results"
					exit 190
			}
			*hilites will handle replaying results
			hilites `0'
			exit
	}


	* version will be later reset to 13.1 unless v12 is specified 
	version 12.1
	
	* If wide, we must temporarily reshape and xtset first. Otherwise
	* lag notation does not work correctly. wide files must have been
	* created by a reshape wide command on a long file that was xtset
	syntax anything, [wide tfix *]
	preserve
	if "`wide'" != "" {
		quietly reshape long
		* quietly xtset `_dta[_TSpanel]' `_dta[_TStvar]', delta(`_dta[TSdelta]')
	}
	* By default data are assumed to be xtset in long format
	* with both panelid and timevar and delta already specifed.
	* wide option can be specified if data are already in wide format

	capture xtset
	if _rc {
		display as error "Data need to be in long format and xtset with " 
		display as error "both panelvar and timevar."
		display as error ///
		"If data are already in wide format use the wide option."
		display as error "Job is terminating."
		exit
	}

	local ivar = r(panelvar)
	local jvar = r(timevar)
	if "`ivar'" == "." | "`jvar'" =="." {
		display as error "Data must be xtset with both panelvar and timevar"
		exit
	}
	local delta = r(tdelta)

	
	* Check to make sure time is coded correctly. Abort if it isn't and tfix not specified
	if (r(tmin) != 1 | r(tdelta)!= 1) & "`tfix'" == "" {
		display as error "Time variable and/or delta is not coded correctly"
		display as error "Time variable must start with 1 and be coded 1, 2, ..., T"
		display as error "delta (the period between observations) must equal 1."
		display as error "Recode time variable or fix delta and rerun or else use tfix option"
		exit
	}
	
	* Recode time if tfix is specified
	if "`tfix'" != "" {
		quietly replace `jvar' = 1 + (`jvar' - r(tmin))/r(tdelta)
		quietly xtset `ivar' `jvar', delta(1)
	}


	
	syntax varlist(ts min=1), /// 
	[T(integer -1)INV(varlist) PREdetermined(varlist ts ) ///
	wide STAYWide v12 v16 ///
	YLAGs(numlist >=0 integer sort) ///
	NOLOG fiml  prefix(string) semopts(string) DRYrun  ///
	errorinv ALPHAFREE ALPHAFREE2(numlist >=1 <=2 integer max=1) ///
	ITERate(integer 250) TECHnique(string) tsoff ///
	addx(string) YFREE YFREE2(numlist) XFREE XFREE2(varlist ts) ///
	SHOWcmd MPlus(string) LAVaan(string) SEMFile(string) STD STD2(varlist) gof ///
	re CONSTraints(string) HILites DETAILs constinv NOCSD tfix evars ///
	SKIPCFAtransform SKIPCONDitional STOre(name) ALTSTart ///
	TItle(string) METHod(name) vce(passthru) OTHERvars(varlist) ///
	DECimals(numlist integer >=0 <=8 max=1) SVY SVY2(string) *]

	* check for proper use of method option
	if "`fiml'" !="" & "`method'" != "" & "`method'" != "mlmv" {
		display as error "You cannot specify both fiml and method(`method')"
		display as error "Job is terminating."
		exit
	}
	if "`fiml'" != "" local method mlmv
	if "`method'" != "" local method method(`method')
	* adf does not work with method bhhh
	if "`method'" == "method(adf)" & "`technique'"== "" {
		local technique nr 25 bfgs 10
	}
	
	* Set the stub for the store option if not already specified
	if "`store'" == "" local store xxtdpdml
	
	* Set cformat if decimals is specified
	if "`decimals'" != "" local cformat cformat(%9.`decimals'f)
	
	* version 13.1 is the default unless v12 is specified. v12 may
	* eventually become the default
	if "`v12'"=="" version 13.1
	* Currently undocumented option to set version to 16
	* Not fully tested; may get around some bugs in 16 and/or use
	* newer features
	if "`v16'" !="" & c(stata_version) >= 16 version 16
	gettoken y xstrictlyexog: varlist
	local xpredetermined `predetermined'
	local xtimeinvariant `inv'
	local xtimevarying `xstrictlyexog' `xpredetermined'
	* Determine which Xs & Ys, if any, are to have free parameters
	if "`xfree'" != "" { 
		local xfree `xstrictlyexog' `xpredetermined' `xtimeinvariant'
		}
	if "`xfree2'" != "" local xfree `xfree2'
	if "`ylags'" == "" local ylags 1
	if "`yfree'" != "" { 
		local yfree `ylags'
	}
	if "`yfree2'" != "" local yfree `yfree2'
	* Some other defaults
	if "`technique'" == "" local technique nr 25 bhhh 25
	if "`constraints'" != "" local constraints(`constraints')
	* nocsd and constinv are aliases
	if "`nocsd'" !="" local constinv constinv
	if "`title'" =="" {
		local title Dynamic Panel Data Model using ML for outcome variable `y'
	}

	* skipcfatransform and skipconditional options only work in Stata 14.2
	* and later. They are ignored if used in used in earlier versions of Stata
	* Altstart is a shorthand for specifying both
	if "`altstart'" !="" {
		local skipcfatransform skipcfatransform
		local skipconditional skipconditional
	}
	if `c(stata_version)' < 14.2 {
		local skipcfatransform
		local skipconditional
	}
	
	* fiml is not valid with the following so it will be blanked out
	if "`vce'" == "vce(sbentler)" {
			local fiml
	}
	else if "`method'" == "method(adf)" {
			local fiml
	}

	
***************************************************************************
	/// Begin mplus code if mplus has been requested
	/// The model code will be generated first and then combined with
	/// other Mplus commands.
	if "`mplus'" != "" {
		tempvar mplout
		tempfile mplmodel
		capture file close `mplout'
		quietly file open `mplout' using `mplmodel', write text replace
	}	
***************************************************************************	
***************************************************************************
	/// Begin lavaan code if lavaan has been requested
	/// The model code will be generated first and then combined with
	/// other lavaan commands.

	if "`lavaan'" != "" {
		tempvar lavout
		tempfile lavmodel
		capture file close `lavout'
		quietly file open `lavout' using `lavmodel', write text replace
	}	
***************************************************************************	

	****** Determine maximum lag; vars to keep ******
	local xlagsmax = 0
	forval type = 1/2 {
		if `type' == 1 {
			local xtype `xstrictlyexog'
		}
		else {
			local xtype `xpredetermined'
		}
			foreach xvar of local xtype {
			local lag0 = strpos("`xvar'", ".")
			local lag1 = strpos("`xvar'", "L.")
			local lagn = substr("`xvar'", 2, 1)
			if `lag0' == 0 {
				* No lags
				local lag 0
				local varbase `xvar'
			}
			else if `lag1' != 0 {
				* Lag 1
				local lag 1
				local varbase = substr("`xvar'", 3, .)
			}
			else {
				* Lag > 1
				local dot = strpos("`xvar'", ".")
				local lengthnum = `dot' - 2
				local lag = substr("`xvar'", 2, `lengthnum')
				local varbase = substr("`xvar'", `dot'+1, .)
			}
			if `xlagsmax' < `lag' local xlagsmax = `lag'
			local baselabels `baselabels' `varbase'
			if `type' == 2  local prelabels `prelabels' `varbase'
		}
		local basenames: list uniq baselabels
		local prenames: list uniq prelabels
	}

		* default lags"

	local ylagsmax = word("`ylags'", wordcount("`ylags''"))
	local Tmin = 2 + max(`xlagsmax', `ylagsmax')	
	
	* default alphafree option
	if "`alphafree'" != "" local alphafree 2
	if "`alphafree2'" != "" local alphafree `alphafree2'

	

	if `t' != -1 & `t' < `Tmin' {
		display as error "T value is too small given the lags specified"
		display as error "For example if xlag = 2 then T must equal at least 4"
		display as error "Job is terminating."
		exit
	}
	
	if `t' >= `Tmin' local T `t'
	// display and maximization options
	_get_diopts diopts options, `options' `cformat'
	mlopts mlopts, `options'


	* Use T in data set unless user has overrided
	if "`T'" =="" local T = r(tmax)
	
	
	****** Get time and lags worked out ******

	if `T' < `Tmin' {
		display as error "T value is too small given the lags specified"
		display as error "For example if xlag = 2 then T must equal at least 4"
		exit
	}

	local Tstart = 1 + max(`xlagsmax', `ylagsmax')

	local Tmin3 = `T' - 3
	local Tmin2 = `T' - 2
	local Tmin1 = `T' - 1
	if "`addx'" !="" local addx (`addx')
	local scmd sem `addx'

	****** Generate Regression part of the command
	* Every equation has E, Alpha, and constant. So start with 3
	* and then add 1 for each variable in the equation
	local nvars = 0
	forval t = `Tstart'/`T' {
		local bnum = 0
		local lavnum
		local ybn
		local xbn
		local yused
		local xused
		* get all the desired Y lags. If yfree is not specified Y coefficients
		* Will be constrained to be equal with lags; otherwise free.
		foreach lag of local ylags {
			if `lag' > 0 {
				local ylag = `t' - `lag'
				* Check to see if this should be a freed parameter
				local btag
				local mpltag ^
				local lavtag "^+ "
				local yfreed 0
				if "`yfree'" != "" {
					local yfreed : list lag in yfree
				}
				if `yfreed' == 0 {
					local bnum = `bnum' + 1
					local lavnum c`bnum'
					local btag @b`bnum'
					local mpltag (`bnum')^
					local lavtag ^ + `lavnum'*
					
				}
				local ylist `ylist' `y'`ylag'
				local ybn `ybn' `y'`ylag'`btag'
				local mplyn `mplyn' `y'`ylag' `mpltag'
				local lavyn `lavyn' `lavtag'`y'`ylag'
				local yused `yused' `y'`ylag'
				if `t' == `Tstart' local nvars = `nvars' + 1
			}

		}
		* Get all the desired x lags
		forval type = 1/2 {
			if `type' == 1 {
				local xtype `xstrictlyexog'
			}
			else {
				local xtype `xpredetermined'
			}
			foreach xvar of local xtype {
				local lag0 = strpos("`xvar'", ".")
				local lag1 = strpos("`xvar'", "L.")
				local lagn = substr("`xvar'", 2, 1)
				if `lag0' == 0 {
					* No lags
					local xlag = `t'
					local varbase `xvar'`xlag'
				}
				else if `lag1' != 0 {
					* Lag 1
					local xlag = `t' - 1
					local varbase = substr("`xvar'", 3, .)
					local varbase `varbase'`xlag'
				}
				else {
					* Lag > 1
					local dot = strpos("`xvar'", ".")
					local lengthnum = `dot' - 2
					local lagn = substr("`xvar'", 2, `lengthnum')
					local xlag = `t' - `lagn'
					local varbase = substr("`xvar'", `dot'+1, .)
					local varbase `varbase'`xlag'
				}
				* Create covariances between Es and later predetermined Xs
				* Create a covar for each E with a higher numbered X
				* Must place this later in command so other options
				* don't override it!
				* This code is NOT executed if there are no predetermined
				forval Enum = `Tstart'/`T' {
					if `type' == 2 & `xlag' > `Enum' {
						*local covarE `covarE' `varbase'*(E`Enum')
						local ElistX `ElistX' E`Enum'
						local mlistX `mlistX' `y'`Enum'
					}
				}
				if `type' == 2 & "`ElistX'" != "" {
					local covarE `covarE' `varbase'*(`ElistX')
					local mplcovar `mplcovar' `varbase' `mlistX';
					local lavcovar `mplcovar'
					local ElistX
					local mlistX
				}
				
				* Check to see if this should be a freed parameter
				local btag
				local mpltag ^
				local lavtag "^+ "
				local xfreed 0
				if "`xfree'" != "" {
					local xfreed : list xvar in xfree
				}
				if `xfreed' == 0 {
					local bnum = `bnum' + 1
					local lavnum c`bnum'
					local btag @b`bnum'
					local mpltag (`bnum')^
					local lavtag ^ + `lavnum'*
				}

				local xused `xused' `varbase'
				local varbasempl `varbase'
				local varbaselav `varbase'
				local varbase `varbase'`btag'
				local varbasempl `varbasempl' `mpltag'
				local varbaselav `lavtag'`varbaselav' 
				///
				local xbn `xbn' `varbase'
				local mplxn `mplxn' `varbasempl'
				local lavxn `lavxn'`varbaselav' 
				if `t' == `Tstart' local nvars = `nvars' + 1
				}

			}
			foreach xvar of local xtimeinvariant {
				* Check to see if this should be a freed parameter
				local btag
				local mpltag ^
				local lavtag "^+ "
				local xfreed 0
				if "`xfree'" != "" {
					local xfreed : list xvar in xfree
				}
				if `xfreed' == 0 {
					local bnum = `bnum' + 1
					local lavnum c`bnum'
					local btag @b`bnum'
					local mpltag (`bnum')^
					local lavtag ^ + `lavnum'*
				}
				local xbn `xbn' `xvar'`btag'
				local mplxn `mplxn' `xvar' `mpltag'
				local lavxn `lavxn' `lavtag'`xvar'
				local xused `xused' `xvar'
				if `t' == `Tstart' local nvars = `nvars' + 1
			}
		

			* Create the E values for all but the last Y
			* but only if there are predetermined vars -
			* otherwise just stick with e.y
			* unless evars also specified
			local E
			if "`predetermined'" != "" | "`evars'" != ""{
				if `t' != `T' {
					local E E`t'@1
					local Elist `Elist' E`t'
					* Set e.y variances to 0 whenever E has replaced it
					local variance `variance' e.`y'`t'@0
				}
			}

		* Make Alpha either free or constrained
		if "`alphafree'" == "" {
			* Do not constrain Alpha coefficients to be equal (default)
			* Normalize by fixing all coefficients at 1; leave var(Alpha) free
			local Alpha Alpha@1
			local Alphavar var(Alpha)
		}
		else if "`alphafree'" == "1" {
			* Normalize by fixing first coefficient at 1; leave var(Alpha) free
			local Alphavar var(Alpha)
			if "`t'" == "`Tstart'" {
				local Alpha Alpha@1
			}
			else {
				local Alpha Alpha
			}
		}
		else if "`alphafree'" == "2" {
			* Normalize by fixing var(Alpha) at 1; leave all coefficients free
			local Alpha Alpha
			local Alphavar var(Alpha@1)
		}
		* Constrain constants to be equal. Can cause convergence problems
		local constant
		if "`constinv'" != "" local constant _cons@a1
		* Create sem regression commands
		local scmd `scmd' (`y'`t' <- `ybn' `xbn' `Alpha' `E' `constant')
		local usedvars `usedvars' `y'`t' `yused' `xused'
		local endogvars `endogvars' `y'`t'

		*************************************************************************
		/// Mplus - Write out model command one wave at a time
		if "`mplus'" != "" {
			file write `mplout' "     `y'`t' on " _n
			local mplyandx `mplyn' `mplxn'
			while "`mplyandx'" != "" {
				gettoken nextvar mplyandx: mplyandx, parse("^")
				if "`nextvar'" !="^" file write `mplout' "          `nextvar'"  _n
			}
			file write `mplout' "          ;"  _n
		}
		local mplxn
		local mplyn
		local mplyandx
		*************************************************************************
		*************************************************************************
		/// Lavaan - Write out model command one wave at a time
		if "`lavaan'" != "" {
			file write `lavout' "     `y'`t' ~ " _n
			local lavyandx `lavyn' `lavxn'
			while "`lavyandx'" != "" {
				gettoken nextvar lavyandx: lavyandx, parse("^")
				if "`nextvar'" !="^" file write `lavout' "          `nextvar'"  _n
			}
			file write `lavout' _n
		}
		local lavxn
		local lavyn
		local lavyandx
		*************************************************************************

	}
	local ylist: list uniq ylist
	local endogvars: list uniq endogvars
	local yexog: list ylist - endogvars



	****** Create the variance and covariance matrices ******
	* If re (random effects) is specified, Alpha not correlated with Xs
	* Alpha IS correlated with exogenous ys if any exist
	* The latter is a change from versions prior to 2.50 -- 
	* Example 4.3 in 2018 SJ paper is wrong.
	if "`re'" !="" {
		local covar `covar' Alpha*(_OEx)@0 
		if "`yexog'" !="" local covar `covar' Alpha*(`yexog')
	}
	* Otherwise set to 0 the covariance between Alpha and the time invariant predictors
	else if "`xtimeinvariant'" !="" {
		local covar `covar' Alpha*(`xtimeinvariant')@0
	}
	
	*** Next several commands only executed if E vars exist ***
	*
	* sets to 0 the covariances between the new error terms and all of 
	* the observed, exogenous variables ( _OEx).

	if "`Elist'" != "" {
		local variance var(`variance')
		local covar `covar' Alpha*(`Elist')@0
		local covar `covar' _OEx*(`Elist')@0
		* Set Error covariances at 0
		forval t = `Tstart'/ `Tmin2' {
			local Elater
			local tplus1 = `t' + 1
			forval tlater = `tplus1'/ `Tmin1' {
				local Elater `Elater' E`tlater'
			}
			local covar `covar' E`t'*(`Elater')@0
		}
	}
	
	****** Constrain error terms to be equal if so requested
	****** Approach taken depends on whether or not model has predet vars
	if "`errorinv'" != "" {
		if "`predetermined'" != "" | "`evars'" != ""{
			foreach E of local Elist {
				local equalerrors `equalerrors' `E'@v1
			}
			local equalerrors `equalerrors' e.`y'`T'@v1
			local equalerrors var(`equalerrors')
		}
		else {
			forval evar = `Tstart'/`T' {
				local equalerrors `equalerrors' e.`y'`evar'@v1
			}
			local equalerrors var(`equalerrors')
		}
	}

	****** Create the final covariance command, if there is one ******
	local covariances
	if "`covar'" != "" | "`covarE'" != "" local covariances cov(`covar' `covarE')
	
	****** Create the final sem command ******
	local scmd `prefix' `scmd', `variance' `Alphavar' `covariances' 
	local scmd `scmd' `semopts' `nolog' `mlopts' `diopts' 
	local scmd `scmd' `equalerrors' iterate(`iterate') technique(`technique')
	local scmd `scmd' noxconditional `constraints'
	local scmd `scmd' `skipcfatransform' `skipconditional' `method' `vce'
	* Show the command and/or create a sem do file if requested
	if "`showcmd'" !="" | "`semfile'" != "" {
		semout, longcmd(`scmd') `showcmd' semfile(`semfile')
	}
		
	****** Get data into wide format; execute command

	* Standardize selected variables if requested. 
	* Vars to be standardized while in long format. TS notation
	* is stripped out this way and each var is only included once.

	if "`std'" != "" {
		local allvars `y' `xstrictlyexog' `xpredetermined' `xtimeinvariant'
		tsrevar `allvars', list
		local std `=r(varlist)'
	}
	if "`std2'" != "" local std `std2'
	
	if "`std'" != "" {
		foreach var of local std {
			tempvar stdx
			quietly egen `stdx' = std(`var')
			quietly replace `var' = `stdx'
		}
	}

	* Set up for svy use if svy option is specified
	* Data must be svyset using time invariant vars
	* BETA -- Not officially supported yet
	if "`svy2'" != "" local svy svy `svy2'
	if "`svy'" != "" {
		local svyprefix `svy':
		quietly svyset
		local svyset svyset `=r(settings)'
		local svyvars `=r(wvar)' `=r(poststrata)' `=r(postweight)'
		local svyvars `svyvars' `=r(bsrweight)' `=r(brrweight)' `=r(jkrweight)' `=r(sdrweight)'
		forval j = 1/ `=r(stages)' {
			local svyvars `svyvars' `=r(su`j')' `=r(strata`j')' `=r(fpc`j')' `=r(weight`j')'
		} 
		local mdot .
		local othervars : list othervars | svyvars
		local othervars: list uniq othervars
		local othervars: list othervars - mdot
	}

	* Data are in long format; reshape to wide
	* First check for missing values on the xtset variables
	quietly count if missing(`ivar', `jvar')
	if r(N) > 0 {
		display
		display as error "Warning! " r(N) " records have missing values on `ivar' and/or `jvar'."
		display as error "Records with missing values on panelvar or timevar are deleted from the analysis."
		display as error "If you want them included you will need to first correct the missing values."
		display as error "Execution continues without the dropped records."
		display 
		quietly drop if missing(`ivar', `jvar')
	}
	keep `y' `basenames'  `xtimeinvariant' `ivar' `jvar' `othervars'
	
	* reshape is done quietly but errors will still cause program to abort
	quietly reshape wide `y' `basenames', i(`ivar') j(`jvar')

	* svyset the data if svy has been requested
	`svyset'
	
	* Drop missing panels unless fiml is being used
	if "`fiml'" =="" {
		tempvar mdcase
		egen `mdcase' = rowmiss(*)
		quietly drop if `mdcase' > 0
		quietly drop `mdcase'
	}

	

	****************************************************************************
	****** Mplus (if requested) ******

	* See if mplus has been requested. If so then generate the rest of the model
	* command code. Then xstata2mpl is called to generate the rest of the code
	* and merge all of the code into a single file and create the mplus data file.
	if "`mplus'" != "" {
		* Save bnum value so lavaan doesn't get off if it is called too
		local savenum `bnum'
		
		* Commas will be deleted from option
		local mplus = subinstr("`mplus'", ",", " ", .)
		gettoken mpljob moptions: mplus
		local mvarlist: list uniq usedvars
		local exogvars: list mvarlist - endogvars
		local alphacorr: list exogvars - xtimeinvariant
		
		* Next code checks for options that change MPlus estimation method
		if "`vce'" == "vce(robust)" {
			local estimator MLR
		}
		else if "`vce'" == "vce(sbentler)" {
			local estimator MLM
		}
		else if "`method'" == "method(adf)" {
			local estimator WLS
		}
		else local estimator ML

		* This sets up Alpha to load on the Y variables
		file write `mplout' _n
		if "`alphafree'" ! = "" {
			file write `mplout' "     ! Alpha loadings free to vary across time" _n
		}
		else {
			file write `mplout' "     ! Alpha loadings equal 1 for all times" _n
		}
		file write `mplout' "     Alpha by " _n "          "
		local fixedalpha @1
		local len = 0
		foreach endogvar of local endogvars {
			if `len' > 60 {
				file write `mplout' _n "          "
				local len = 0
			}
			file write `mplout' "`endogvar'`fixedalpha' "
			local len = `len' + length(" `endogvar'`fixedalpha'")
			if "`alphafree'" != "" local fixedalpha *
		}
		file write `mplout' ";" _n
		
		* Let Alpha load on exogenous vars, except time invariant.
		* If re option is specified alpha is uncorrelated with
		* exogenous vars. Time invariant vars also uncorrelated.
		* Otherwise free
		if "`re'" != "" {
			file write `mplout' "     ! Random Effects Model - Alpha uncorrelated with X Exogenous Vars" _n
		}
		else {
			file write `mplout' "     ! Fixed Effects Model - Alpha correlated with Time-Varying Exogenous Vars" _n
		}
		file write `mplout' "     Alpha with " _n "          "

		local len = 0
		foreach exogvar of local exogvars {
			local invvar: list exogvar & xtimeinvariant
			* Check if exog var is y exogenous. y exogenous are always correlated with alpha
			local exogisyexog: list yexog & exogvar
			if "`re'" != "" & "`exogisyexog'" ==""  {
				local corrfixed @0
			}
			else if "`invvar'" != "" {
				local corrfixed @0
			}
			else {
				local corrfixed *
			}
			
			if `len' > 60 {
				file write `mplout' _n "          "
				local len = 0
			}
			file write `mplout' "`exogvar'`corrfixed' "
			local len = `len' + length(" `exogvar'`corrfixed'")
		}
		file write `mplout' ";" _n

		
		* Code for the correlations between Ys and predetermined vars
		if "`mplcovar'" != "" {
			file write `mplout' "     ! Correlations between Ys and predetermined variables" _n
		}
		while "`mplcovar'" != "" {
			local len = 0
			gettoken nextpre mplcovar: mplcovar, parse(";")
			if "`nextpre'" != ";" {
				gettoken prevar nextpre: nextpre
				file write `mplout' "     `prevar' with"  _n "         "
				foreach varwith of local nextpre {
					if `len' > 60 {
						file write `mplout' _n "         "
						local len = 0
					}
					file write `mplout' " `varwith'"
				local len = `len' + length(" `varwith'")
				}
			file write `mplout' ";" _n
			}
		}
	
		* constinv/ nocsd option:
		if "`constinv'" != "" {
			file write `mplout' "     ! Constants constrained to be equal across waves" _n
			local bnum = `bnum' + 1
			foreach endogvar of local endogvars {
				file write `mplout' "     [`endogvar'] (`bnum')"  _n
			}
			file write `mplout' "     ;" _n
		}
		
		* Error variances invariant
		if "`errorinv'" != "" {
			file write `mplout' "     ! Error variances constrained to be equal across waves" _n
			local bnum = `bnum' + 1
			foreach endogvar of local endogvars {
				file write `mplout' "     `endogvar' (`bnum')"  _n
			}
			file write `mplout' "     ;" _n
		}
	

		/// Close the back end and reopen as read only
		file close `mplout'
		quietly file open `mplout' using `mplmodel', read text
		
		/// Call xstata2mplus now to generate front end of code and merge with back end
		xstata2mplus using `mpljob', use(`mvarlist') `moptions' /// 
			estimator(`estimator') `fiml' title(`title') mpljob(`mpljob') ///
			mplout(`mplout')

		* restore bnum in case lav is called too
		local bnum `savenum'
		
		display as text
		display as text "You can start mplus and open the file mpl_`mpljob'.inp." ///
			 " Some editing may be necessary." _n
	}
	
	****** End of Mplus code ******
	
	*************************************************************************
	****** lavaan (if requested) ******

	* See if lavaan has been requested. If so run xstata2lavaan to generate 
	* lavaan files. Options replace and missing can be specified.
	
	if "`lavaan'" != "" {
		* Commas will be deleted from option
		local lavaan = subinstr("`lavaan'", ",", " ", .)
		gettoken lavjob moptions: lavaan
		local mvarlist: list uniq usedvars
		local exogvars: list mvarlist - endogvars
		local alphacorr: list exogvars - xtimeinvariant
		
		* This sets up Alpha to load on the Y variables
		file write `lavout' _n
		if "`alphafree'" ! = "" {
			file write `lavout' "     # Alpha loadings free to vary across time" _n
		}
		else {
			file write `lavout' "     # Alpha loadings equal 1 for all times" _n
		}
		file write `lavout' "     Alpha =~ " _n "          "
		local fixedalpha + 1*
		local len = 0
		foreach endogvar of local endogvars {
			if `len' > 60 {
				file write `lavout' _n "          "
				local len = 0
			}
			file write `lavout' "`fixedalpha'`endogvar' "
			local len = `len' + length("`fixedalpha'`endogvar' ")
			if "`alphafree'" != "" local fixedalpha "+ "
		}
		file write `lavout' "" _n _n
		
		* Let Alpha load on exogenous vars, except time invariant.
		* If re option is specified alpha is uncorrelated with
		* exogenous vars. Time invariant vars also uncorrelated.
		* Otherwise free
		if "`re'" != "" {
			file write `lavout' "     # Random Effects Model - Alpha uncorrelated with X Exogenous Vars" _n
		}
		else {
			file write `lavout' "     # Fixed Effects Model - Alpha correlated with Time-Varying Exogenous Vars" _n
		}
		file write `lavout' "     Alpha ~~ " _n "          "

		local len = length("          ")
		foreach exogvar of local exogvars {
			local invvar: list exogvar & xtimeinvariant
			* Check if exog var is y exogenous. y exogenous are always correlated with alpha
			local exogisyexog: list yexog & exogvar
			if "`re'" != "" & "`exogisyexog'" ==""  {
				local corrfixed "+ 0*"
			}
			else if "`invvar'" != "" {
				local corrfixed "+ 0*"
			}
			else {
				local corrfixed " + "
			}
			
			if `len' > 60 {
				file write `lavout' _n "          "
				local len = length("          ")
			}
			file write `lavout' "`corrfixed'`exogvar' "
			local len = `len' + length(" `corrfixed'`exogvar'")
		}
		file write `lavout' "" _n _n

		
		* Code for the correlations between Ys and predetermined vars
		if "`lavcovar'" != "" {
			file write `lavout' "     # Correlations between Ys and predetermined variables" _n
		}
		while "`lavcovar'" != "" {
			local len = 0
			gettoken nextpre lavcovar: lavcovar, parse(";")
			if "`nextpre'" != ";" {
				gettoken prevar nextpre: nextpre
				file write `lavout' "     `prevar' ~~"  _n "         "
				foreach varwith of local nextpre {
					if `len' > 60 {
						file write `lavout' _n "         "
						local len = 0
					}
					file write `lavout' " + `varwith'"
				local len = `len' + length("+ `varwith'")
				}
			file write `lavout' "" _n _n
			}

		}
		
		* constinv/ nocsd option:
		if "`constinv'" != "" {
			file write `lavout' "     # Constants constrained to be equal across time" _n
			local bnum = `bnum' + 1
			local lavnum c`bnum'
			foreach endogvar of local endogvars {
				file write `lavout' "     `endogvar' ~ `lavnum'*1"   _n
			}
		}
		else {
			file write `lavout' "     # Constants free to vary across time" _n
			local bnum = `bnum' + 1
			foreach endogvar of local endogvars {
				file write `lavout' "     `endogvar' ~ 1"   _n
			}
		}
		file write `lavout' "     " _n _n
		
		* Error variances invariant or free
		if "`errorinv'" != "" {
			file write `lavout' "     # Error variances constrained to be equal across time" _n
			local bnum = `bnum' + 1
			local lavnum c`bnum'
			foreach endogvar of local endogvars {
				file write `lavout' "     `endogvar' ~~ `lavnum'*`endogvar'"  _n
			}
		}
		else {
			file write `lavout' "     # Error variances free to vary across time" _n
			foreach endogvar of local endogvars {
				file write `lavout' "     `endogvar' ~~ `endogvar'"  _n
			}
		}
		file write `lavout' "     " _n _n
	
		* Write out all the exogenous covariances. Lavaan is picky
		* about this!
		local lavexogvars `exogvars'
		local numexogvars: word count `lavexogvars'
		if `numexogvars' > 1 {
			file write `lavout' "     # Exogenous variable covariances" _n

			forval j= 2/`numexogvars' {
				gettoken lavexogvar lavexogvars: lavexogvars
				local len = 0
				file write `lavout' "     `lavexogvar' ~~"  _n "       "
				foreach varwith of local lavexogvars {
					if `len' > 60 {
						file write `lavout' _n "       "
						local len = 0
					}
					file write `lavout' " + `varwith'"
					local len = `len' + length("         + `lavexogvar'")
				}
			file write `lavout' "" _n _n
			}
		}

		/// Various checks that will affect the the fit command
		/// and results printed out
		
		/// Get gof measures if requested
		if "`gof'" != "" {
			local lavfit TRUE
		}
		else {
			local lavfit FALSE
		}
		
		/// Check for fiml or listwise
		if "`fiml'" != "" {
			local lavmissing fiml
		}
		else {
			local lavmissing default
		}

		///Check for options that change lavaan standard errors
		if "`vce'" == "vce(robust)" {
			local lavse robust
		}
		else local lavse default

		/// Check for method specified. 
		if "`method'" == "method(adf)" {
			local lavestimator WLS
		}
		else local lavestimator ML
		
		/// Satorra Bentler gets separate treatment
		/// Satorra Bentler doesn't work the same in lavaan
		/// All you get is a test and robust standard errors
		if "`vce'" == "vce(sbentler)" {
			local lavestimator MLM
		}
	
		/// Closing lavaan commands
		file write `lavout' _n
		file write `lavout' "     # End of lavaan sem specification" _n
		file write `lavout' "     '" _n _n
		
		/// fit command
		file write `lavout' "`lavjob'.results <- lavaan::sem(`lavjob'.model, " _n
		file write `lavout'	"   data = `lavjob'.datafile," _n
		file write `lavout'	`"   missing = "`lavmissing'","' _n
		file write `lavout'	`"   estimator = "`lavestimator'","' _n
		file write `lavout'	`"   se = "`lavse'","' _n
		file write `lavout' "   )" _n
		if "`vce'" == "vce(sbentler)" file write `lavout' ///
			"# NOTE: lavaan does not provide Satorra-Bentler standard errors." _n
		/// Print results	
		file write `lavout' "lavaan::summary(`lavjob'.results, fit.measures=`lavfit')" _n _n
	
		
		* Close the back end and reopen as read only
		file close `lavout'
		quietly file open `lavout' using `lavmodel', read text
		
		* Call xstata2lav now to generate front end of code and create data
		xstata2lavaan using `lavjob', `moptions' /// 
			title(`title') lavjob(`lavjob') ///
			lavout(`lavout')
		
		display as text
		display as text "You can start lavaan and open the file lav_`lavjob'.R." ///
			 " Some editing may be necessary." _n
	}
	
	****** End of lavaan code
	*************************************************************************


	****** Execute command if requested

	* Check to see if this is a dryrun, i.e. nothing is actually supposed to
	* be estimated
	if "`dryrun'" !="" {
		// Keep data in wide format if requested
		if "`staywide'" !="" {
			restore, not
			display
			display "Warning: You specified staywide. The original data have NOT been restored.
			display "Data are now in wide format. Even if it was originally"
			display "in wide format it may be restructured now. If you save the file"
			display "make sure you don't accidentally overwrite a file you want to keep."
		}
		display
		// ereturn values the user may want after a dryrun
		ereturn local semcmd `scmd'	
		ereturn scalar Tstart = `Tstart'
		ereturn scalar T = `T'
		ereturn local depvar `y'
		ereturn local title `title'
		ereturn local nvars `nvars'
		display "Warning: dryrun was requested - no actual estimation was done"
	exit
	}
		
	* Finally! Execute command
	if "`details'" =="" {
		quietly `svyprefix' `scmd'
	}
	else `svyprefix' `scmd'
	
	* Ereturn additional xxtdpdml values
	ereturn local semcmd `scmd'	
	ereturn scalar Tstart = `Tstart'
	ereturn scalar T = `T'
	ereturn scalar Nperiods = e(T) - e(Tstart) + 1
	ereturn local depvar `y'
	ereturn local nvars `nvars'
	ereturn local title `title'
	local free 0
	local anyfree `xfree' `yfree' `alphafree'
	if "`anyfree'" != "" local free 1
	ereturn scalar anyfree = `free'
	ereturn scalar N_g = e(N)
	ereturn local ylist `ylist'
	ereturn local endogvars `endogvars'
	ereturn local yexog `yexog'

	* Indicate whether or not the model includes fake error terms
	* This is necessary for hilites to know when counting parameters.
	if "`evars'" != "" | "`xpredetermined'" != "" {
		ereturn local evars Yes
	}
	else {
		ereturn local evars No
	}
	ereturn local xpredetermined `xpredetermined'
	
	ereturn local xtimeinvariant `xtimeinvariant'
	// Create BIC & AIC statistics, since they are computed incorrectly
	// in a hilites only file
	if e(ll) != . {
		quietly estat ic
		tempname icmatrix
		matrix `icmatrix' = r(S)
		ereturn scalar BIC = `icmatrix'[1,6]
		ereturn scalar AIC = `icmatrix'[1,5]
	}
	* test whether all coefficients besides constants = 0
	* This is like estat eqtest except if gives you a single test
	* for all equations rather than tests for each equation separately

	quietly test [#1]
	forval eqnum = 2/`=e(Nperiods)' {
		quietly test [#`eqnum'], a
	}
	ereturn scalar chi2_w = r(chi2)
	ereturn scalar df_w = r(df)
	ereturn scalar p_w = r(p)
	ereturn local hilitesonly No
	
	* Store results
	estimates title: Full Results: `=e(title)'
	estimates store `store'_f
	
	* Hilites printout
	hilites, `diopts' `tsoff' store(`store') `constinv'
	if "`gof'" !="" estat gof, stats(all)

	****** Final Cleanup ******
	* Restore data to long format unless staywide specified
	* or if dataset was already in wide format
	if "`staywide'" !="" {
		display
			display
			display "Warning: You specified staywide. The original data have NOT been restored.
			display "Data are now in wide format. Even if it was originally"
			display "in wide format it may be restructured now. If you save the file"
			display "make sure you don't accidentally overwrite a file you want to keep."
		restore, not
	}
end


*********************************************************************************

/// Copied and modified from UCLA's stata2mplus program. Written by Michael 
/// Mitchell and adapted with permission.
program define xstata2mplus
	version 12
	syntax [varlist] using/ , [ MIssing(int -9999) use(varlist) Replace /// 
		OUTput(string) Analysis(string) fiml estimator(string) TItle(string) ///
		mpljob(string) mplout(string)	]

	preserve 
	
	/// Create the data file first
  
	if ("`varlist'" != "") {
		keep `varlist'
	}

	if ("`varlist'" == "") {
		unab varlist : *
	}

	* convert char to numeric
	foreach var of local varlist {
		local vartype : type `var' 
		if (substr("`vartype'",1,3)=="str") {
			display "encoding `var'"
			tempvar tempenc
			encode `var', generate(`tempenc')
			drop `var'
		rename `tempenc' `var'
		}
	}

	foreach var of local varlist {
		quietly replace `var' = `missing' if `var' >= .
	}

	quietly outsheet using `"mpl_`using'.dat"' , comma nonames nolabel `replace'
	
	/// Now create front-end code

	tempvar outmpl
	capture file close `outmpl'

	quietly file open `outmpl' using `"mpl_`using'.inp"', write text `replace'

	file write `outmpl' "! Mplus code for mpl_`mpljob'.inp" _n
	file write `outmpl' "Title: " _n

	file write `outmpl' "  `title'" _n
  
	file write `outmpl' "Data:" _n
	file write `outmpl' "  File is mpl_`using'.dat ;" _n

	if "`fiml'" != "" {
		local mplmissing OFF
	}
	else {
		local mplmissing ON
	}
	file write `outmpl' "  Listwise = `mplmissing' ;" _n

	file write `outmpl' "Variable:" _n 
	file write `outmpl' "  Names are " _n "    " 
	local len = 0
	unab varlist : *
	foreach varname of local varlist {
		if `len' > 60 {
			file write `outmpl' _n "    " 
			local len = 0
		}
	local len = `len' + length(" `varname'") 
	file write `outmpl' " `varname'" 
	}
	file write `outmpl' ";" _n
  

	file write `outmpl' "  Missing are all (`missing') ; " _n

	if "`use'" != "" {
		file write `outmpl' "  Usevariables are" _n "    "
		local len = 0
		unab usevarlist : `use'
		foreach varname of local usevarlist {
			if `len' > 60 {
				file write `outmpl' _n "    " 
				local len = 0
			}
		local len = `len' + length(" `varname'") 
		file write `outmpl' " `varname'" 
		}
		file write `outmpl' ";" _n
	}
  
	// Analysis options
	
	// Write out default values first
	file write `outmpl' "Analysis:" _n
	file write `outmpl' "     Iterations = 1000;" _n
	file write `outmpl' "     Estimator = `estimator';" _n
	
	// Defaults will be overwritten by anything on the analysis option
	
	if "'analysis'" !="" {
		while "`analysis'" != "" {
			gettoken aoption analysis: analysis, parse(";")
			if "`aoption'" !=";" {
				file write `outmpl' "     `aoption';" _n
			}
		}
	}


	// Output options
	if "`output'" == "" {
		file write `outmpl' "Output:" _n
	}
	else {
		file write `outmpl' "Output:" _n
		while "`output'" != "" {
			gettoken outoption output: output, parse(";")
			if "`outoption'" !=";" {
				file write `outmpl' "     `outoption';" _n
			}
		}	
	}

	
	// Begin model command
	file write `outmpl' "Model:" _n
	
	// Now add model code created earlier
	file read `mplout' mplline
	while r(eof) == 0 {
		file write `outmpl' `"`mplline'"' _n
		file read `mplout' mplline
	}

	file close `outmpl'

	restore

end

********************************************************************************

*********************************************************************************

/// xstata2lavaan 

program define xstata2lavaan

	version 12
	syntax [varlist] using/ , [ Replace /// 
		TItle(string) lavjob(string) lavout(string)  * ]
		
	preserve

	/// Create the data first
	/// Save the wide file in Stata earlier format
	if `c(stata_version)' < 14 {
		quietly saveold lav_`using', `replace'
	}
	else {
	quietly saveold lav_`using', `replace' version(11)
	}
	
	/// Now create the front-end code

	quietly findfile lav_`using'.dta
	local outputfilename `=r(fn)'
	local outputfilename = subinstr("`outputfilename'", "\", "/", .)

	tempvar outlav
	capture file close `outlav'

	quietly file open `outlav' using lav_`using'.R, write text `replace'

	file write `outlav' "# Lavaan Code for lav_`lavjob'.R" _n
	file write `outlav' "library(haven)" _n
	file write `outlav' "library(lavaan)" _n
	file write `outlav' `"`lavjob'.datafile <- read_dta("`outputfilename'")"' _n
	file write `outlav' "`lavjob'.model <- '" _n
	file write `outlav' "     # `title'" _n _n
 
	// Begin model command
	file write `outlav' "     # Structural Equations" _n
	
	// Now add model code created earlier
	file read `lavout' lavline
	while r(eof) == 0 {
		file write `outlav' `"`lavline'"' _n
		file read `lavout' lavline
	}

	file close `outlav'
	
	

end

********************************************************************************
  
* Adapted from linewrap by Mead Over, Center for Global Development
* This routine formats the output from the sem command and/or
* creates a do file with the generated code
program semout
	syntax, longcmd(string) [showcmd semfile(string) ]
	local maxlength 60
	
	if "`semfile'" != "" {
		* Commas deleted
		local semfile = subinstr("`semfile'", ",", " ", .)
		gettoken semfile replace: semfile
		if "`replace'" == "r" local replace replace
		tempvar out
		capture file close `out'
		quietly file open `out' using `"`semfile'.do"', write text `replace'
		file write `out' "#delimit ;" _n
	}
	if "`showcmd'" !="" {
		display
		display as result "The generated sem command is"
		display
	}
	
	local line = 1
	local i = 0  // Character position in rest of the string
	local blnkpos = .  // Characters until next blank  
	local restofstr `longcmd'
	local lngthrest = length(`"`longcmd'"')  //  Total number of characters in the rest of the string
	while `i' < `lngthrest' & `blnkpos' > 0 {
		local blnkpos = strpos(substr(`"`restofstr'"',`i'+1,.)," ") 
		local i = `i' + `blnkpos'

		if `i' >= `maxlength' {
			if `i' - `blnkpos' > 0 {  
				local tmpstr = substr("`restofstr'", 1 ,`i' - `blnkpos' - 1)
				*return local line`line' = `"`tmpstr'"'

				if `line' > 1 local spaces "    "
				if "`showcmd'" != "" display "`spaces'" `"`tmpstr'"'
				if "`semfile'" != "" {
					file write `out' "`spaces'" `"`tmpstr'"' _n
				}
				local line = `line' + 1
				local restofstr = substr(`"`restofstr'"', `i' - `blnkpos' + 1 , .)
				local lngthrest = length("`restofstr'")  //  Number of characters left
				local blnkpos = strpos(substr(`"`restofstr'"',1,.)," ") 
				local i = 0
			}
			else {  // When a string of characters is longer than maxlength
				local tmpstr = substr("`restofstr'", 1 ,`blnkpos'-1)
				if "`showcmd'" != ""  {
					di as txt `ln'  as res `"`tmpstr'"'
				}
				if "`semfile'" != "" {
					file write `out' "`spaces'" `"`tmpstr'"' _n
				}
				local line = `line' + 1
				local restofstr = substr(`"`restofstr'"', `blnkpos' + 1 , .)
				local lngthrest = length("`restofstr'")  //  Number of characters left
				local blnkpos = strpos(substr(`"`restofstr'"',1,.)," ") 
				local i = 0				
			}
		}
	}
	else {  //  Rest of string fits in a single line
		local tmpstr `restofstr'
		*return local line`line' = `"`tmpstr'"'
		local spaces
		if `line' > 1 local spaces "    "
		if "`showcmd'" != "" {
			display "`spaces'" `"`tmpstr'"'
			display
		}
		if "`semfile'" != "" {
			file write `out' "`spaces'" `"`tmpstr'"' ";" _n
			file write `out' "#delimit cr" _n
			file close `out'
			display
			display "`semfile'.do contains the generated sem code"
			display
		}
		local nlines = `line'
	}
end

********************************************************************************

program hilites, eclass
	syntax , [tsoff store(name) DECimals(numlist integer >=0 <=8 max=1) constinv *]
	* First several steps can be skipped if this is already a hilites file
	local hilitesonly = e(hilitesonly)
	if "`hilitesonly'" == "No" {

		// Get our matrices set up
		local nvars = e(nvars)
		local y = e(depvar)
		local title = e(title)
		tempname bcopy vcopy b2 v2 hilites_b hilites_v
		mat `bcopy' = e(b)
		mat `vcopy' = e(V)
		local Tstart = e(Tstart)
		local T = e(T)
		local Nperiods = e(Nperiods)
		local inv `=e(xtimeinvariant)'
		local free = e(anyfree)
		
		// Compute the number of cells to be extracted for highlights
		// If no free, just take the first few cells for the indep vars
		// If free, number extracted depends on whether there are evars or not.
		// Extra vars will include Alpha, Constant, and perhaps E
		if `free' == 0 {
			local ncells = `nvars'
		}
		else if "`=e(evars)'" == "Yes" {
			local ncells = (`nvars' + 3) * `Nperiods' - 1
		}
		else if "`=e(evars)'" == "No" {
			local ncells = (`nvars' + 2) * `Nperiods'
		}		
		matrix `hilites_b' = `bcopy'[1, 1..`ncells']
		matrix `hilites_v' = `vcopy'[1..`ncells', 1..`ncells']
		
		// Rename rows and columns for hilite purposes if necessary conditions met
		if `free' == 0 & `Tstart' <= 9 & "`tsoff'" == ""{
			local varnames: colnames(`hilites_b')
			local newname

			foreach vname of local varnames {
				// Time invariant vars keep their current names
				local invvar: list inv & vname
				if "`invvar'" != "" {
					local newname `y':`vname'
				}
				// Otherwise rename using lag notation if appropriate
				else {
					local wave = substr("`vname'", strlen("`vname'"), 1)
					local xname = substr("`vname'", 1 , strlen("`vname'")-1)
					local lag = `Tstart' - `wave'
					if `lag' == 0 {
						local newname `y':`xname'
					}
					else {
						local newname `y':L`lag'.`xname'
				}
			}
			local newnames `newnames' `newname'	
		}	
			matrix colnames `hilites_b' = `newnames'
			matrix rownames `hilites_b' = `y'
			matrix rownames `hilites_v' = `newnames'
			matrix colnames `hilites_v' = `newnames'
		}
		ereturn matrix hilites_b =  `hilites_b', copy
		ereturn matrix hilites_v = `hilites_v', copy
		

		// We want these results stored with the highlights
		local N = e(N)
		local N_g = e(N_g)
		local converged = e(converged)
		local chi2_ms = e(chi2_ms)
		local df_ms = e(df_ms)
		local p_ms = e(p_ms)
		local T = e(T)
		local Tstart = e(Tstart)
		local BIC = e(BIC)
		local AIC = e(AIC)
		local depvar = e(depvar)
		local chi2_w = e(chi2_w)
		local df_w = e(df_w)
		local p_w = e(p_w)
		local title = e(title)
		local vce = e(vce)
		local vcetype = e(vcetype)
		
		tempname results
		_estimates hold `results', restore
		
		// We want these results stored with the highlights
		ereturn post `hilites_b' `hilites_v', obs(`N')
		ereturn scalar N = `N'
		ereturn scalar N_g = `N_g'
		ereturn scalar converged = `converged'
		ereturn scalar chi2_ms = `chi2_ms'
		ereturn scalar df_ms = `df_ms'
		ereturn scalar p_ms = `p_ms'
		ereturn scalar T = `T'
		ereturn scalar Tstart = `Tstart'
		ereturn scalar BIC = `BIC'
		ereturn scalar AIC = `AIC'
		ereturn local depvar `depvar'
		ereturn scalar chi2_w = `chi2_w'
		ereturn scalar df_w = `df_w'
		ereturn scalar p_w = `p_w'
		ereturn local title `title'
		ereturn local vce `vce'
		ereturn local vcetype `vcetype'

		ereturn local hilitesonly Yes
		ereturn local cmd xxtdpdml
		* Store the hilites only file if not already stored
		* local store will be empty if this is a replay
		if "`store'" != "" {
			estimates title: Highlights: `=e(title)'
			estimates store `store'_h
		}


	}

	// Now we will play or replay results
	* Set cformat if decimals is specified
	if "`decimals'" != "" local cformat cformat(%9.`decimals'f)
	_get_diopts diopts options, `options' `cformat'
	// Some display options work for sem but not hilites, so
	// delete them
	local illegaloptions nocnsreport
	local diopts: list diopts - illegaloptions

	// Display results
	display ""
	display as result "Highlights: `=e(title)'"

	ereturn display, `diopts'
	
	di as text "# of units = `=e(N)'. # of periods = `=e(T)'. " ///
		"First dependent variable is from period `=e(Tstart)'. "
		
	if "`constinv'" == "" {
		di as text "Constants are free to vary across time periods"
	}
	else display as text "Constants are invariant across time periods"
		
	if e(chi2_ms) != . {
		di as text "LR test of model vs. saturated: " ///
		"chi2(`=e(df_ms)')  = " %10.2f `=e(chi2_ms)' ", Prob > chi2 = " %7.4f `=e(p_ms)'
	}
	else di as text "Warning: LR test of model vs saturated could not be computed"
		
	if e(BIC) ! = . {
		di as text "IC Measures: BIC = " %10.2f `=e(BIC)' "  AIC = " %10.2f `=e(AIC)' "
	}
	else di as text "Warning: IC Measures BIC and AIC could not be computed"

	if e(chi2_w) ! = . {
		di as text "Wald test of all coeff = 0: " ///
		"chi2(`=e(df_w)') = " %10.2f `=e(chi2_w)' ", Prob > chi2 = " %7.4f `=e(p_w)'
	}
	else di as text "Warning: Wald test of all coeff = 0 could not be computed"
	
	if `=e(converged)' != 1 {
		di as error "Warning! Convergence not achieved"
	}
	
	// Restore original e(b), e(V) if necessary
	if "`hilitesonly'" == "No" _estimates unhold `results'			


end

* 2.50   fixed bug with re option. Alpha should load on exogenous y
*        even if re is specified. Example 4.3 in 2018 SJ paper is wrong.
*        Undocumented v16 option added -- May solve compatibility
*        problems with Stata 16 and/or use enhanced features.
* 2.20   lavaan option added. Mplus coding improved. Fixed bugs in
*        wide and staywide options. Added warning about not overwriting
*        files if you use staywide. Changed names of Mplus files.
*        Made listwise the default in Mplus unless fiml specified.
*        Lots of other little fixes and improvements.
*        Help file updated. Thanked Jacob Long for lavaan help.
* 2.12   Get mplus code correct for when vce(robust), vce(sbentler), and
*        method(adf) are specified.
*        method(adf) will change the estimation technique to avoid errors
*        unless user has specified own values for technique.
*        hilites output modified to indicate whether constants are
*        time-invariant or not.
*        Help file updated. Includes more references.
*        BETA Added othervars option to add time-invariant vars to the file, e.g.
*        for use with the cluster option. Not fully supported yet.
*        BETA code added to make it work with svy -- not fully supported yet.
* 2.11   added e(N_g) to ereturned results. Equals e(N) but useful
*        for comparing xtabond and xxtdpdml
* 2.10 - Support for replay and esttab added with hilites results.
*        store option added. default is xxtdpdml_f and xxtdpdml_h.
*        altstart added as shortcut for skipcfatransform skipconditional.
*        method() option added. vce() option added.
*        BIC and AIC statistics automatically stored, as are
*        some other stats generated by the program.
*        Added dec() option for number of decimals to display.
*        Fixed bug where highlights displayed extraneous info when
*        xfree or yfree was used.
*        Help file updated accordingly.
* 2.01 - Support for Stata 14.2 options skipcfatransform and
*        skipconditional added. Options are ignored in earlier 
*        versions of Stata. Some minor tweaks to help file.
* 2.00 - First official public release on SSC
* 1.87 - Minor tweaks to help file.
* 1.86 - Listwise option added for Mplus. Bollen and Brand
*        example & acknowledgments added to the help file.
* 1.85 - Improvement in the mplus command formatting and help.
*        Analysis and Output suboptions added to mplus.
*        Title option added.
* 1.81 - constinv, nocsd, and errorinv options now work in MPlus
* 1.80 - mplus option greatly improved. std and gof options added.
*        Help file modified accordingly.
* 1.70 - No changes in the program. Help file modified to discuss
*        postestimation commands like estat gof. fiml example added.
* 1.60 - Improved output for showcmd. semfile option lets you output
*        sem commands to a file.
* 1.55 - dryrun tweaked to ereturn e(semcmd) and other values the
*        user may want.
* 1.50 - Options dryrun and mplus added. Special topics section added 
*        to help. Discusses how to specify interactions with time
*        and offers suggestions for dealing with convergence problems.
*        Improved help for display options.
* 1.40 - Improved output for highlights. To get the old output back,
*        use the tsoff option. Only works when free options have not
*        been specified and lags do not exceed 9. (1.40 was never
*        officially released.)
* 1.30 - xxtdpdml now issues warning messages and/or aborts when there
*        are problems with reshape wide. This would occur if, say,
*        the inv option was not specified correctly.
* 1.25 - Fixed a bug that resulted in fatal errors if a record had
*        missing on either panelvar or timevar. Such records now
*        get deleted, a warning message gets issued, and execution
*        continues.
* 1.20 - Improved the coding of covariance options. Instead of a
*        bunch of cov() options being generated, just one big one
*        is. This avoids a "Too many options" error.
*        Added evars option if you want the Es even when no vars
*        are prededermined. This may be needed to replicate some
*        earlier results
* 1.10 - More efficient coding if no predetermined vars,
*        i.e. we use e.y instead of Es
* 1.01 - Help file tweaks
* 1.00 - tfix option added. Help file tweaked
* 0.90 - Error checks for time variable. nocsd is
*       alias for constinv. Minor help file changes
* 0.80 - First version with help file
