*! cic.ado
*! Changes-in-changes
*!
*! An implementation of:
*! Athey, S. & G. W. Imbens. "Identification and Inference in Nonlinear Difference-in-Differences Models."
*!     Econometrica, 74 (2), March 2006, pp. 431-497.
*! Based on Matlab code by S. Athey & G. W. Imbens, published on S. Athey's website
*!
*! Stata code by Keith Kranker



program cic, properties(mi svyb) eclass byable(onecall)
	version 11.2
	if replay() {
		if ("`e(cmd)'"!="cic") error 301
		if _by()               error 190
		else Replay `0'
		exit
	}
	if _by() local BY `"by `_byvars'`_byrc0':"'
	`BY' Estimate `0'
	ereturn local cmdline `"cic `0'"'
 	ereturn local cmd     "cic"
	ereturn local title   "Changes in Changes (CIC) Model"
end


program define Estimate, eclass byable(recall)
	version 11.2

	// choice of estimator
	gettoken estimator 0 : 0
	if missing("`estimator'") {
		local estimator = "all"
	}
	cap assert inlist("`estimator'","continuous","dci","bounds","all","check")
	if _rc {
		di as error "Select one of the following estimators: continuous, dci, bounds, or all."
		error 198
	}

	// parse arguments
	syntax varlist(default=none min=3 numeric fv) [if] [in] [fweight iweight aweight]  ///
		[, at(numlist min=1 >=0 <=100 sort) ///
		Vce(passthru) ///
		did ///
		CONtinuous dci LOWer UPPer all ///
		UNTreated ///
		ROUnd(real 0) ///
		level(passthru) noTABle noHeader noLegend * ] // Reporting options
	marksample touse  // note that rows are dropped for (1) if/in (2) zero weight (3) missing data (and other reasons, see "help mark")
	_get_diopts diopts, `options'
	local diopts `diopts' `table' `header' `legend'
	_rmcoll `varlist' [`weight'`exp'] if `touse', expand
	local varlist `r(varlist)'

	// first three variables need to be y, treat, and post
	gettoken y     varlist : varlist
	gettoken treat varlist : varlist
	gettoken post  varlist : varlist

	// default percentiles
	if mi(`"`at'"') local at "10 20 30 40 50 60 70 80 90"

	// parse vce()
	if mi(`"`vce'"') local vce vce(none)
	cic_vce_parse, `vce'
	local vce     = r(vce)
	local bsreps  = r(bsreps)
	local bssize  = r(bssize)
	local dots    = r(dots)
	if !missing(r(bsopts)) local bsopts = r(bsopts)
	if !missing(r(saving)) local saving = r(saving)
	local sepercentile = (r(sepercentile)==1)
	if ("`vce'"=="bootstrap" & `bssize'!=0 & !inlist("`wgtvar'","iweight","pweight","aweight")) {
		di as err "vce(`vce', size(`size')) is only allowed with iweight , pweight , and aweight. With unweighted samples, you could generate a variable equal to one and use it as an iweight."
		error 101
	}

	// prep to handle weights
	if !missing("`weight'") {
		tempvar wgtvar
		gen `wgtvar'`exp' if `touse'
		summ `wgtvar' if `touse', meanonly
		local haswgt = 1
	}
	else local haswgt = 0
	if inlist("`weight'","iweight")  {
		if ("`vce'"=="bootstrap" & `bssize'==0) {
			local bssize = r(sum)
			di as txt "(When bootstrapping standard errors with iweights, the sub-option vce(bootstrap, size(`=round(`bssize',.001)')) was used by default, where `=round(`bssize',.001)' is the sum of the iweights.)"
		}
		local wtexp_caller = `", "`wgtvar'", `bssize' "'
		local n=round(r(sum))
		if ("`vce'"=="delta") {
			di as err "vce(delta) is not allowed with `weight's."
			error 101
		}
	}
	else if inlist("`weight'","aweight","pweight") {
		qui replace `wgtvar' = `wgtvar' / r(mean)
		if ("`vce'"!="none" & "`weight'"=="pweight") {
			di as err "vce(`vce') is not allowed with `weight's."
			error 101
		}
		qui count if `touse'
		local n=r(N)
		if ("`vce'"=="bootstrap" & `bssize'==0) {
			local bssize = r(N)
			di as txt "(When bootstrapping standard errors with aweights and pweights, the weights are normalized to mean=1 and the sub-option vce(bootstrap, size(`bssize')) sub-option was used by default, where `bssize' is the number of observations.)"
		}
	}
	else if inlist("`weight'","fweight") {
		// fweight
		local wtexp_caller = `", "`wgtvar'", `bssize' "' // fweight
		local n=r(sum)
		cap assert `wgtvar'==round(`wgtvar')
		if _rc error 401
	}
	else {
		// no weights
		qui count if `touse'
		local n=r(N)
	}

	// adjust y for covariates (OLS regression)
	// always run DID regression if control variables present
	local runDID  = (("`did'"=="did") | (`: list sizeof varlist'!=0))

	// For `untreated' option, flip sign of `treat'
	if "`untreated'"=="untreated" {
		tempvar untreat
		gen `untreat' = (`treat'==0) if `touse'
		unab treat_or_untreat : `untreat'
		local tot = 0
	}
	else {
		unab treat_or_untreat : `treat'
		local tot = 1
	}

	// implement mata CIC routine
	// function has no arguments. Mata will access Stata local macros.
	ereturn clear
	tempname mata_b mata_V
	mata: cic_caller()

	// post results to ereturn
	di as txt _n "Changes in Changes (CIC) Model"
	if (`bsreps'>0 & !mi(`bsreps')) {
		// option - save bs reps into a specified file (`saving' contains ", replace" if it was provided)
		if !mi(`"`saving'"') copy `bstempfile' `saving'

		// post boostrapped estimates with standard errors using bstat
		`=cond(`sepercentile',"quietly","")' /// quietly if need to call sepercentile
		bstat  using `bstempfile', stat( `mata_b' ) `bsopts' `diopts' `level'

		if ( `sepercentile' ) {
			if (e(level)!=95) {
				ereturn display
				di as error "-sepercentile- sub-option only works with level(95).  Standard errors displayed above are from Stata's default method of producing standard errors."
				error 198
			}
			if `bsreps' < 1000 nois di as error "Warning: More bootstrap repetitions might be needed with the -sepercentile- bootstrapping sub-option.."
			tempname ci_se
			mata : bs_se( "e(ci_percentile)", "`ci_se'" )
			ereturn repost V = `ci_se'
			ereturn display
		}
	}
	else if ("`vce'"=="delta") {
		// otherwise just use ereturn to get pretty estimates table
		di as txt _col(49) "Number of obs      =" as res %8.0fc = e(N)
		ereturn post `mata_b' `mata_V' [`weight'`exp'], depname(`y') obs(`n') esample(`touse') dof(`=`n'-colsof(`mata_b')') `level'
		ereturn display
	}
	else {
		// otherwise just use ereturn to get pretty estimates table
		di as txt _col(49) "Number of obs      =" as res %8.0fc = e(N)
		ereturn post `mata_b' [`weight'`exp'], depname(`y') obs(`n') esample(`touse') dof(`=`n'-colsof(`mata_b')') `level'
		ereturn display
	}

	if (`: list sizeof varlist'!=0 | `runDID') {
		ereturn scalar k_eq =  5
		ereturn local  eqnames continuous discrete_ci dci_lower_bnd dci_upper_bnd did
	}
	else {
	 	ereturn scalar k_eq =  4
		ereturn local  eqnames continuous discrete_ci dci_lower_bnd dci_upper_bnd
	}
	if "`untreated'"=="" ereturn local footnote "Effect of Treatment on the Treated Group"
	else                 ereturn local footnote "Effect of Treatment on the Untreated Group"
	di as txt e(footnote)
	if `runDID'                                         di as txt "Traditional DID model" as res " [did], [did_model]" as txt =cond(`tot',""," (`untreat' == 1 - `treat')")
	if `runDID'                                         di as txt "Quantile DID model" as res " [qdid]"
	if inlist("`estimator'","all","continuous","check") di as txt "Continuous CIC model" as res " [continuous]"
	if inlist("`estimator'","all","dci")                di as txt "Discrete CIC model (under the conditional independence assumption)" as res " [discrete_ci]"
	if inlist("`estimator'","all","bounds")             di as txt "Lower bound for the discrete CIC model (without conditional independence)" as res " [dci_lower_bnd]"
	if inlist("`estimator'","all","bounds")             di as txt "Upper bound for the discrete CIC model (without conditional independence)" as res " [dci_upper_bnd]"

	ereturn local depvar    "`y'"
 	ereturn local vce       "`vce'"
 	ereturn local estimator "`estimator'"

end // end of cic program definition


// subroutine to replay estimates
program Replay
	syntax [, notable noHeader  noRULES OR GROUPED *]
	_get_diopts diopts, `options'
	local diopts `diopts' `table' `header' `legend'
	_prefix_display, `diopts' `table' `header' `legend'
	di as txt "(" e(footnote) ")"
end

// subroutine to parse the vce() option
// this section is similar in function to the "_vce_parse" command, except that I set default values for reps() and strata()
program define cic_vce_parse, rclass
	version 11.2
	syntax , vce(string asis)
	_parse comma vce 0 : vce
	if  inlist( "`vce'","bootstra","bootstr","bootst","boots","boot","boo","bo","b") local vce "bootstrap"
	if  inlist( "`vce'","delt","del","de","d") local vce "delta"
	if  inlist( "`vce'","non","no","n") local vce "none"

	if ("`vce'"!="bootstrap") & !mi("`0'") {
		di as error "suboptions are not allowed with vce(`vce')"
		error 198
	}

	return local vce `vce'
	if ("`vce'"=="bootstrap") {
		syntax [, Reps(integer 200) size(real 0) SAving(string asis) NODots SEPercentile *]
		return scalar bsreps  = `reps'
		return scalar bssize = `size'
		return scalar dots  = ( "nodots"!="`dots'" )
		return scalar sepercentile = ( "sepercentile"=="`sepercentile'" )
		return local  saving  : copy local saving
		return local  bsopts  : copy local options
	}
	else if ("`vce'"=="delta") {
		return scalar bsreps  = -1
		return scalar dots    = 0
		return scalar bssize = 0
	}
	else if ("`vce'"=="none") {
		return scalar bsreps  = 0
		return scalar dots    = 0
		return scalar bssize = 0
	}
	else {
		di as error "Only vce(delta), vce(bootstrap [, subopts]), and vce(none) allowed."
		error 198
	}
end


/* * * * *  BEGIN MATA BLOCK * * * * */
version 11.2
mata:

// STRUCTURES FOR RETURNING RESULTS
struct cic_result {
	real rowvector con, dci, dscrt_low, dscrt_upp, se
}
struct did_result {
	pointer(real colvector) Y
	real colvector coef
	real scalar did
}


// CIC CALLER -- THIS FUNCTION READS STATA DATA INTO MATA AND CALLS THE MAIN CIC ROUTINE
void cic_caller()
{

	// Output: Output is returned to Stata through various st_*() functions.

	// Inputs:
	  string rowvector varlist
	  string scalar y_varname, touse_var, estimator, wgt_var, mata_b, mata_V
	  real scalar did, tot, bsreps, dots, round, haswgt, bssize
	  real rowvector at

	// Input #1.   Name of variables, in the following order:
	//         - dependent variable, `y'
	//         - treatment dummy (0/1 for control/treatment groups)
	//         - time period dummy (0/1 for pre/post periods)
	//         - (Optional) control variables
	varlist = (st_local("y") , st_local("treat_or_untreat") , st_local("post"), tokens(st_local("varlist")))
	y_varname = st_local("y")

	// Input #2.   Name of variable indicating which rows to include, `touse'
	touse_var = st_local("touse")

	// Input #3.   Name of local macro containing quantiles of interest, ranging from 0 to 100 percent (`at')
	at = strtoreal(tokens(st_local("at"))) / 100
	if (min(at)<0 | max(at)>1) _error( "at() must be between 0% and 100% (inclusive)." )

	// Input #4.   0/1 to estimate difference in difference (DID) and quantile DID model.  (always estimated if there are control variables)
	did = strtoreal(st_local("runDID"))

	// Input #5.   0/1 if estimates effect of treatment on the treated (=1) or effect of treatment on the untreated (=0)
	//               if untreated, you must provide a variable that =0 if treated and =1 if untreated
	//               setting tot==0 simply flips the sign of the cic() output
	tot = strtoreal(st_local("tot"))

	// Input #6.   String [all|continuous|dci|lower|upper] specifying whether you want all four estimators or just one of them
	estimator = st_local("estimator")

	// Input #7.   How to calculate standard errors:
	//         - if >1, bootstrapped standard errors and bsreps = number of bootstrap repetitions
	//         - if 0, no standard errors
	//         - if -1, standard error for conditional independence based on numerical differentiation
	bsreps = strtoreal(st_local("bsreps"))

	// Input #8.   0/1 to hide bootstrapping dots (=1 to show dots)
	dots = strtoreal(st_local("dots"))

	// Input #9.  Round y to the nearest ___.  (set =0 for no rounding).
	round = strtoreal(st_local("round"))

	// Input #10.  Name of variable with fweight or iweight
	haswgt = strtoreal(st_local("haswgt"))

	// Input #11 & #12.  Name of matrix to leave the coefficients and V-C matrix
	mata_b = st_local("mata_b")
	mata_V = st_local("mata_V")

	// (Optional) Input #12.  Name of variable with fweight or iweight (null if no weights)
	wgt_var = st_local("wgtvar")

	// (Optional) Input #13. Sample Size (This is only used if bootstrapping SEs with weights)
	// Set to 0 if using fweights or if there are no weights.
	// Provide population size for scaling i/p/aweights.
	bssize = strtoreal(st_local("bssize"))

	// Read y, treat and post into mata
	real colvector y, treat, post
	st_view(y    =.,.,varlist[1],touse_var)  // note that rows with missing data are already dropped by -marksample- in .ado file
	st_view(treat=.,.,varlist[2],touse_var)
	st_view(post =.,.,varlist[3],touse_var)
	if ((uniqrows(treat),uniqrows(post))!=(0,0\1,1)) {
		_error( "treat and post must be dummy variables equal to 0 and 1" )
	}
	real scalar N
	N = rows(y)

	// read control variables into mata (if need to run DID model)
	if (did) {
		real matrix rhs
		st_view(rhs =.,.,invtokens(varlist[2..length(varlist)]),touse_var)  // note that rows with missing data are already dropped by -marksample- in .ado file
	}

	// read weights into mata (if there are any)
	if (haswgt) {
		real colvector wgt
		st_view(wgt=.,.,wgt_var,touse_var)
	}
	else wgt=1

	// Results will be returned into a structures (defined above)
	struct cic_result scalar result
	struct did_result scalar didresult

	// DID regression
	// After this section, upper-case Y is now the dependent variable for
	// the cic() function. It is a pointer. It points to (lower case) y
	// or a (temporary) variable that is adjusted for covariates and/or rounded.
	pointer(real colvector) scalar Y
	Y = &y
	if (did) {
		didresult = did(y, rhs, wgt, round)
		swap(Y,didresult.Y)
	}
	else if (round!=0) Y = &round(y,round)

	// Permutation vectors identifying the four treat*post groups
	real colvector p00, p01, p10, p11
	st_select(p00=.,(1::N),(treat:==0 :& post:==0))
	st_select(p01=.,(1::N),(treat:==0 :& post:==1))
	st_select(p10=.,(1::N),(treat:==1 :& post:==0))
	st_select(p11=.,(1::N),(treat:==1 :& post:==1))

	// Number of observations
	real scalar N00, N01, N10, N11
	N00 = rows(p00);
	N01 = rows(p01)
	N10 = rows(p10)
	N11 = rows(p11)
	if (min((N00,N01,N10,N11))<1) _error( "One or more of the four treat*post groups is empty.")
	if (min((N00,N01,N10,N11))<2 & bsreps>0) _error( "One or more group has size less than 2. There will be no variation in bootstrap draws.")

	// Call the quantile DID routine
	if (did) {
		real rowvector qdid_result
		if (!haswgt) qdid_result=qdid((*Y)[p00],(*Y)[p01],(*Y)[p10],(*Y)[p11],at) // without weights
		else         qdid_result=qdid((*Y)[p00],(*Y)[p01],(*Y)[p10],(*Y)[p11],at,wgt[p00],wgt[p01],wgt[p10],wgt[p11]) // with weights
	}

	// Call the main CIC routine
	if (!haswgt) result=cic((*Y)[p00],(*Y)[p01],(*Y)[p10],(*Y)[p11],at,estimator) // without weights
	else         result=cic((*Y)[p00],(*Y)[p01],(*Y)[p10],(*Y)[p11],at,estimator,wgt[p00],wgt[p01],wgt[p10],wgt[p11]) // with weights

	// return results into a Stata matrix named `mata_b'
	if (did) {
		if (tot) st_matrix(mata_b,  (didresult.coef', didresult.did, qdid_result, result.con, result.dci, result.dscrt_low, result.dscrt_upp))
		else     st_matrix(mata_b,  (didresult.coef',-didresult.did,-qdid_result,-result.con,-result.dci,-result.dscrt_upp,-result.dscrt_low))
	}
	else {
		if (tot) st_matrix(mata_b,  (result.con,result.dci,result.dscrt_low,result.dscrt_upp))
		else     st_matrix(mata_b, -(result.con,result.dci,result.dscrt_upp,result.dscrt_low))
	}

	// matrix labels for `mata_b'
	string matrix ciclabels, didlabels, qdidlabels
	ciclabels=(J(cols(result.con),1,"continuous") \ J(cols(result.dci),1,"discrete_ci") \ J(cols(result.dscrt_low),1,"dci_lower_bnd") \ J(cols(result.dscrt_upp),1,"dci_upper_bnd") )
	if      (estimator=="all")        ciclabels=(ciclabels, J(4,1,strtoname(("mean" , ("q":+strofreal(at*100))))'))
	else if (estimator=="continuous") ciclabels=(ciclabels, J(1,1,strtoname(("mean" , ("q":+strofreal(at*100))))'))
	else if (estimator=="dci")        ciclabels=(ciclabels, J(1,1,strtoname(("mean" , ("q":+strofreal(at*100))))'))
	else if (estimator=="bounds")     ciclabels=(ciclabels, J(2,1,strtoname(("mean" , ("q":+strofreal(at*100))))'))
	else if (estimator=="check")      ciclabels=(ciclabels, J(4,1,strtoname(("mean" , ("q":+strofreal(at*100))))'))

	if (did) {
		if (cols(rhs)==2) didlabels = (J(rows(didresult.coef),1,"did_model"),( ( "0."+varlist[2]+"#0."+varlist[3]) \( "0."+varlist[2]+"#1."+varlist[3]) \( "1."+varlist[2]+"#0."+varlist[3]) \( "1."+varlist[2]+"#1."+varlist[3])))
		else              didlabels = (J(rows(didresult.coef),1,"did_model"),( ( "0."+varlist[2]+"#0."+varlist[3]) \( "0."+varlist[2]+"#1."+varlist[3]) \( "1."+varlist[2]+"#0."+varlist[3]) \( "1."+varlist[2]+"#1."+varlist[3]) \ varlist[4..length(varlist)]'))
		qdidlabels=(J(length(at),1,"qdid"),strtoname("q":+strofreal(at*100))')
		ciclabels = ( didlabels \ ( "did", "did" ) \ qdidlabels \ ciclabels )
	}
	st_matrixcolstripe(mata_b, ciclabels)
	st_matrixrowstripe(mata_b, J( rows(st_matrix(mata_b)), 1, ("", y_varname)) )
	st_local("cic_coleq"   ,invtokens(ciclabels[.,1]'))
	st_local("cic_colnames",invtokens(ciclabels[.,2]'))

	// return
	st_matrix("e(at)",at)
	st_numscalar( "e(N_strata)", 4)
	if (!haswgt) {
		st_numscalar( "e(N)"       , N)
		st_numscalar( "e(N00)"     , N00)
		st_numscalar( "e(N01)"     , N01)
		st_numscalar( "e(N10)"     , N10)
		st_numscalar( "e(N11)"     , N11)
	}
	else if (bssize) {
		st_numscalar( "e(N)"       , round(bssize))
		st_numscalar( "e(N_obs)"   , N)
	}
	else {
		st_numscalar( "e(N)"       , round(sum(wgt)))
		st_numscalar( "e(N_obs)"   , N)
	}
	st_numscalar( "e(N_support)",rows(uniqrows(*Y)))

	// Bootstrapping
	if (bsreps>0) {
		real scalar b
		real colvector bs_wgt
		struct did_result scalar bs_didresult
		struct cic_result scalar bs_cicresult
		real rowvector bs_qdidresult

		// pointer to y
		// a new pointer is needed for dependent variable since it might be adjusted for covariates with boostrap sample
		pointer(real colvector) scalar bs_Y
		bs_Y = Y

		// empty matrix to store results
		real matrix bsdata
		bsdata=J(bsreps,cols(st_matrix(mata_b)),.)

		// Before loop, extra setup needed for drawing a sample with unequal weights
		if (haswgt) {
			// weight variables with cumulative sum of the weights from each group
			real colvector cumsum00, cumsum01, cumsum10, cumsum11
			cumsum00 = quadrunningsum(wgt[p00])
			cumsum01 = quadrunningsum(wgt[p01])
			cumsum10 = quadrunningsum(wgt[p10])
			cumsum11 = quadrunningsum(wgt[p11])

			// scalars with population size for each group
			real scalar popsize00, popsize01, popsize10, popsize11
			if (bssize) {
				// With weights (other than frequency weights), use the fraction of bssize in the group (e.g., popsize00 = round(cumsum00[n00]/colsum(wgt)*bssize))
				// with iweghts, bssize==sum of the weights by default.
				// With pweights or aweights, sumwgt==bssize by default, so the sum of the weights is just the sum of the weights, rounded to the nearest integer
				real scalar sumwgt
				sumwgt = quadcolsum(wgt)
				popsize00 = round(cumsum00[N00]/sumwgt*bssize) // the number of obs. in each group is rounded to the nearest integer
				popsize01 = round(cumsum01[N01]/sumwgt*bssize)
				popsize10 = round(cumsum10[N10]/sumwgt*bssize)
				popsize11 = round(cumsum11[N11]/sumwgt*bssize)
			}
			else {
				// With frequency weights, this is the weighted number of individuals in the group (e.g., popsize00 = cumsum00[n00])
				popsize00 = cumsum00[N00]
				popsize01 = cumsum01[N01]
				popsize10 = cumsum10[N10]
				popsize11 = cumsum11[N11]
				if (round(popsize00)!=popsize00 | round(popsize01)!=popsize01 | round(popsize10)!=popsize10 | round(popsize11)!=popsize11) "When drawing bootstrap sample with frequency weights, non-integer fweights were found."
			}
			cumsum00 = cumsum00/cumsum00[N00] // normalize to sum to one within groups
			cumsum01 = cumsum01/cumsum01[N01]
			cumsum10 = cumsum10/cumsum10[N10]
			cumsum11 = cumsum11/cumsum11[N11]
			if (min((popsize00,popsize01,popsize10,popsize11))<2) "One or more groups has size <=1. There will be no variation in bootstrap draws."
		}

		// header for dots
		if (dots) {
			printf( "{txt}\nBootstrap replications ({res}%g{txt})\n", bsreps)
			display( "{txt}{hline 4}{c +}{hline 3} 1 " +
				"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
				"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
		}

		// Bootstrapping replications
		for(b=1; b<=bsreps; ++b) {

			if (haswgt | did) {
				// if estimating DID model or have a weighted sample, the bootstrap sample
				// is "drawn" by creating a new weight vector.
				if (!haswgt) bs_wgt = bs_draw_wgt(p00, p01, p10, p11, N00, N01, N10, N11)
				else         bs_wgt = bs_draw_wgt(p00, p01, p10, p11, N00, N01, N10, N11, cumsum00, cumsum01, cumsum10, cumsum11, popsize00, popsize01, popsize10, popsize11)

				// calculate DID and adjust for covariates w/ bootstrap sample
				if (did) {
					bs_didresult = did(y, rhs, bs_wgt, round)
					swap(bs_Y,bs_didresult.Y)
					bs_qdidresult = qdid((*bs_Y)[p00],(*bs_Y)[p01],(*bs_Y)[p10],(*bs_Y)[p11],at,bs_wgt[p00],bs_wgt[p01],bs_wgt[p10],bs_wgt[p11])
				}

				// call cic() with bootstrap sample
				bs_cicresult=cic((*bs_Y)[p00],(*bs_Y)[p01],(*bs_Y)[p10],(*bs_Y)[p11],at,estimator,bs_wgt[p00],bs_wgt[p01],bs_wgt[p10],bs_wgt[p11])
			}
			else {
				// in the simple case of no regression adjustment and no weights, simply
				// call cic() with a random draw of dependent variable
				bs_cicresult=cic(bs_draw_nowgt((*bs_Y)[p00]),bs_draw_nowgt((*bs_Y)[p01]),bs_draw_nowgt((*bs_Y)[p10]),bs_draw_nowgt((*bs_Y)[p11]),at,estimator)
			}

			// save estimates into a matrix with one row per bootstrap sample
			if (did) {
				if (tot==1) bsdata[b,.]  =  (bs_didresult.coef',bs_didresult.did,bs_qdidresult,bs_cicresult.con,bs_cicresult.dci,bs_cicresult.dscrt_low,bs_cicresult.dscrt_upp)
				else        bsdata[b,.]  = -(bs_didresult.coef',bs_didresult.did,bs_qdidresult,bs_cicresult.con,bs_cicresult.dci,bs_cicresult.dscrt_upp,bs_cicresult.dscrt_low)
			}
			else {
				if (tot==1) bsdata[b,.]  =  (bs_cicresult.con,bs_cicresult.dci,bs_cicresult.dscrt_low,bs_cicresult.dscrt_upp)
				else        bsdata[b,.]  = -(bs_cicresult.con,bs_cicresult.dci,bs_cicresult.dscrt_upp,bs_cicresult.dscrt_low)
			}

			// show dots
			if (dots) {
				if (missing(bsdata[b,.])) printf( "{err}x{txt}")
				else printf( ".")
				if (!mod(b,50)) printf( " %5.0f\n",b)
				else if (b==bsreps & mod(b-1,50)) display("") // end of dots
				displayflush()
			}
		} // end loop through bs iterations

		// save bootstrap iterations in a temporary .dta file (named `bstempfile')
		stata( "preserve" )
		  string rowvector bstempfile, bstempvars
		  // clear data (after preserve) and fill with bsdata matrix
		  st_dropvar(.)
		  st_addobs(rows(bsdata))
		  bstempvars=strtoname("_bs_":+strofreal(1::cols(bsdata)))'
		  st_store(.,st_addvar("double",bstempvars), bsdata)
		  // setup file for bstat command
		  st_global( "_dta[bs_version]" , "3")
		  if (!haswgt)      st_global( "_dta[N]", strofreal(N))
		  else if (bssize)  st_global( "_dta[N]", strofreal(bssize))
		  else              st_global( "_dta[N]", strofreal(round(sum(wgt))))
		  st_global( "_dta[N_strata]"   , "4")
		  st_global( "_dta[strata]"     , (varlist[2] + " " + varlist[1]))
		  st_global( "_dta[command]"    , "cic")
		  if (did) st_global( "_dta[k_eq]", "6")
		  else     st_global( "_dta[k_eq]", "4")
		  st_global( "_dta[k_extra]"    , "0")

		  for(b=1; b<=cols(bsdata); ++b) {
			if (did) {
				if (tot==1) st_global( (bstempvars[1,b]+"[observed]")  , strofreal( (didresult.coef',didresult.did,qdid_result,result.con,result.dci,result.dscrt_low,result.dscrt_upp)[1,b]))
				else        st_global( (bstempvars[1,b]+"[observed]")  , strofreal(-(didresult.coef',didresult.did,qdid_result,result.con,result.dci,result.dscrt_upp,result.dscrt_low)[1,b]))
			}
			else {
				if (tot==1) st_global( (bstempvars[1,b]+"[observed]")  , strofreal( (result.con,result.dci,result.dscrt_low,result.dscrt_upp)[1,b]))
				else        st_global( (bstempvars[1,b]+"[observed]")  , strofreal(-(result.con,result.dci,result.dscrt_upp,result.dscrt_low)[1,b]))
			}
			 st_global( (bstempvars[1,b]+"[expression]"), ( "["+ciclabels[b,1]+"]_b["+ciclabels[b,2]+"]"))
			 st_global( (bstempvars[1,b]+"[coleq]")     , ciclabels[b,1])
			 st_global( (bstempvars[1,b]+"[colname]")   , ciclabels[b,2])
			 st_global( (bstempvars[1,b]+"[is_eexp]")   , "1" )
		  }

		  // save as `bstempfile'
		  bstempfile=st_tempfilename()
		  st_local( "bstempfile",bstempfile)
		  stata(( "qui save " + bstempfile ))
		stata( "restore" )
	} // done bootstrapping

	else if (bsreps==-1) {

		// Standard errors calculated via the Delta Method
		real matrix V_delta
		V_delta = se_cic((*Y)[p00],(*Y)[p01],(*Y)[p10],(*Y)[p11],result)

		// turn from a 1x4 vector into a square matrix with the same number of columns as e(b), then post back into Stata
		V_delta  = (( V_delta[1], J(1,length(at),0), V_delta[2], J(1,length(at),0), V_delta[3], J(1,length(at),0), V_delta[4], J(1,length(at),0)))
		if (did) V_delta = (J(1,rows(didlabels)+1+rows(qdidlabels),0),V_delta)
		st_matrix(mata_V,diag(V_delta))
		st_matrixcolstripe(mata_V, ciclabels)
		st_matrixrowstripe(mata_V, ciclabels)
	}

} // end of cic_caller; everything is returned to Stata with st_*() commands.


// >>>>>>>>>>  check that column names and such are the same as the output in the example in the NOTE (below)

// CIC ROUTINE
struct cic_result scalar cic(real colvector Y00, real colvector Y01, real colvector Y10, real colvector Y11, real rowvector at, string scalar estimator, | real colvector W00, real colvector W01, real colvector W10, real colvector W11 )
{
	// Inputs:
	//   (1)-(4)  Four column vectors with dependent variable
	//             - Y00 is data for the control group in pre-period
	//             - Y01 is data for the control group in post period
	//             - Y10 is data for the treatment group in post period
	//             - Y11 is data for the treatment group in post period
	//   (5)      Vector with k>=1 quantiles of interest, ranging from 0 to 1 (you can set this to missing to skip)
	//   (6)      String = [all|continuous|dci|lower|upper] specifying whether you want all four estimators or just one of them
	//   (7)-(10) (Optional) Column with fweights or iweights for Y00, Y01, Y10, and Y11 (respectively)
	//
	// Output: One structure (cic_result) with four row vectors.
	//   Each vector has (1+k) elements. The first element is the mean, followed by k results (one for each quantile in -at-).
	//   (1) result.con       = CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9
	//   (2) result.dci       = CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29
	//   (3) result.dscrt_low = LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
	//   (4) result.dscrt_upp = UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
	//   Three of the four vectors will be void if option (6) is not "all"

	// Need all or none of args (7)-(10)
	if (args()!=6 & args()!=10) _error(( "cic() expected 6 or 10 arguments, but received " + strofreal(args()))) + " arguments"

	// Vector with support points for all four groups combined (YS) and the comparison-post group (YS01)
	real colvector YS, YS01
	YS01 = uniqrows(Y01)
	YS   = uniqrows(Y00\YS01\Y10\Y11)
	if (length(YS)<2) _error("The dependent variable is a constant")

	// Vector with CDF functions of the four treat*post groups (F00,F01,F10,F11)
	// Sample proportions (w/ or w/out weights)
	real colvector f00, f01, f10, f11
	f00=(args()==6 ? prob(Y00,YS) : prob(Y00,YS,W00))
	f01=(args()==6 ? prob(Y01,YS) : prob(Y01,YS,W01))
	f10=(args()==6 ? prob(Y10,YS) : prob(Y10,YS,W10))
	f11=(args()==6 ? prob(Y11,YS) : prob(Y11,YS,W11))
	// Results will be returned into a structure w/ 4 vectors for continuous, dci, lower, upper
	// Each vector has mean estimate in first column, plus one column for each element of "at"
	struct cic_result scalar result

	if (estimator=="all") {
		// Run all four estimators
		result = cic_all(f00,f01,f10,f11,YS,YS01,at)
	}
	else if (estimator=="continuous") {
		// Only run CIC estimator with continuous outcomes, equation 9
		result.con       = cic_con(f00,f01,f10,f11,YS,YS01,at)
	}
	else if (estimator=="dci") {
		// Only run CIC model with discrete outcomes (under the conditional independence assumption), equation 29
		result.dci       = cic_dci(f00,f01,f10,f11,YS,YS01,at)
	}
	else if (estimator=="bounds") {
		// Only run lower & upper bound estimates for discrete CIC model (without conditional independence), equation 25
		result.dscrt_low = cic_lower(f00,f01,f10,f11,YS,YS01,at)
		result.dscrt_upp = cic_upper(f00,f01,f10,f11,YS,YS01,at)
	}
	else if (estimator=="check") {
		// Undocumented option for testing purposes
		// Run cic_all and also the four separate functions, and check that they give the same results
		result          = cic_all(f00,f01,f10,f11,YS,YS01,at)
		struct cic_result scalar check
		check.con       = cic_con(f00,f01,f10,f11,YS,YS01,at)
		check.dci       = cic_dci(f00,f01,f10,f11,YS,YS01,at)
		check.dscrt_low = cic_lower(f00,f01,f10,f11,YS,YS01,at)
		check.dscrt_upp = cic_upper(f00,f01,f10,f11,YS,YS01,at)
		if (result.con==check.con
		  & result.dci==check.dci
		  & result.dscrt_low==check.dscrt_low
		  & result.dscrt_upp==check.dscrt_upp) "Elements are equal"
		else {
			"result.con";       result.con;
			"result.dci";       result.dci;
			"result.dscrt_low"; result.dscrt_low;
			"result.dscrt_upp"; result.dscrt_upp;
			"check.con";        check.con;
			"check.dci";        check.dci;
			"check.dscrt_low";  check.dscrt_low;
			"check.dscrt_upp";  check.dscrt_upp;
			_error( "Elements not equal")
		}
	}
	else {
		_error("Estimator (argument #6) must be one of the following: all, continuous, dci, lower, or upper}")
	}

	// DONE.  RETURN STRUCTURE W/ FOUR ROW VECTORS.
	return(result)
} // end of cic


// ALL FOUR ESTIMATORS
//   - CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9
//   - CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29
//   - LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
//   - UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
// The code in cic_all() is somewhat convoluted because I am calculating all four vectors simultaneously.
// It is faster than, but equivalent to, running cic_con(), cic_dci(), cic_lower(), and cic_upper() sequentially.

struct cic_result cic_all(real vector f00, real vector f01, real vector f10, real vector f11, real vector YS, real vector YS01, real vector at)
{
	real colvector F00, F01, F10, F11

	// Results will be returned into a structure w/ 4 vectors for con, dci, lower, upper
	// Each vector has mean estimate in first column, plus one column for each element of "at"
	struct cic_result scalar result

	// CDFs   (Because of rounding, sum of probabilities might be slightly different than one)
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// First, estimate the cdf of Y^N_11 using equation (9) in the paper.
	// Second, use that to calculate the average effect of the treatment.
	// For each y in the support of Y01, fill in FCO(y)=F_10(F^-1_00(F_01(y))).
	real vector FCO,FLB,FUB,FDCI,FDCI_weight
	real scalar i,F01y,F00invF01y,F00invbF01y,F00F00invF01y,F00F00invbF01y,cdfinv_at_i
	FCO=FDCI=FLB=FUB=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		F01y=cdf(YS01[i],F01,YS)
		F00invF01y=cdfinv(F01y,F00,YS)
		F00invbF01y=cdfinv_brckt(F01y,F00,YS)
		F00F00invF01y =cdf(F00invF01y,F00,YS)
		F00F00invbF01y=cdf(F00invbF01y,F00,YS)
		FCO[i]=FUB[i]=cdf(F00invF01y,F10,YS)
		FLB[i]=cdf(F00invbF01y,F10,YS)
		if ((F00F00invF01y-F00F00invbF01y)>epsilon(1)) FDCI_weight=(F01y-F00F00invbF01y)/(F00F00invF01y-F00F00invbF01y)
		else                                           FDCI_weight=0
		FDCI[i]=FLB[i]+(FUB[i]-FLB[i])*FDCI_weight
	}
	FCO[length(FCO)]=FDCI[length(FDCI)]=FLB[length(FLB)]=FUB[length(FUB)]=1   // =1 in last row

	// MEAN: CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9
	result.con=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FCO-(0 \ FCO[1..(length(YS01)-1)]))'*YS01 )

	// MEAN: CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29
	result.dci=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FDCI-(0 \ FDCI[1..(length(YS01)-1)]))'*YS01 )

	// MEAN: LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
	result.dscrt_low =( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FLB-(0 \ FLB[1..(length(YS01)-1)]))'*YS01 )

	// MEAN: UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
	result.dscrt_upp=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FUB-(0 \ FUB[1..(length(YS01)-1)]))'*YS01 )

	// QUANTILES (each loop adds a cell to the result.* vector for each quantile in at)
	if (!missing(at)) {
	  for(i=1; i<=length(at); ++i) {

		cdfinv_at_i = cdfinv(at[i], F11, YS)

		// CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9
		result.con       = (result.con      , ( cdfinv_at_i - cdfinv(at[i], FCO, YS01) ) )

		// CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29
		result.dci       = (result.dci      , ( cdfinv_at_i - cdfinv(at[i], FDCI, YS01) ) )

		// LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
		result.dscrt_low = (result.dscrt_low, ( cdfinv_at_i - cdfinv(at[i], FLB, YS01) ) )

		// UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
		result.dscrt_upp = (result.dscrt_upp, ( cdfinv_at_i - cdfinv(at[i], FUB, YS01) ) )
	  }
	}

	// DONE.  RETURN STRUCTURE W/ FOUR ROW VECTORS.
	return(result)
} // end of cic_all


// TRADITIONAL DIFFERENCES IN DIFFERENCES REGERSSION (OLS)
struct did_result scalar did(real colvector y, real matrix rhs, real colvector wgt, real scalar round)
{
	// Inputs:
	// (1) y, the dependent variable
	// (2) rhs, matrix of independent variables
	//      - first column is treat
	//      - second column is post
	//      - (optional) remaining columns are covariates
	// (3) wgt, a column vector of fweights or iweights (can set to scalar =1 for no weights)
	// (4) round, a scalar indicating the nearest unit for rounding Y (=0 for no rounding)
	//
	// Output: One structure (did_result) with:
	// 1. *Y, pointer to adjusted variable (pointing to either a temporary variable or input y itself)
	// 2. a vector with coefficients from the DID regression


	// Nx4 matrix with dummies indicating group membership to p00, p01, p10, p11 (respectively)
	real matrix D
	D = ( ((-rhs[.,1]:+1):*(-rhs[.,2]:+1)), ((-rhs[.,1]:+1):*(rhs[.,2])), ((rhs[.,1]):*(-rhs[.,2]:+1)), ((rhs[.,1]):*(rhs[.,2])))

	// OLS DID regression
	struct did_result scalar didresult
	if (cols(rhs)==2) didresult.coef = invsym(quadcross(D,wgt,D))*quadcross(D,wgt,y)
	else              didresult.coef = invsym(quadcross((D,rhs[.,3..cols(rhs)]),wgt,(D,rhs[.,3..cols(rhs)])))*quadcross((D,rhs[.,3..cols(rhs)]),wgt,y)

	// DIFF-IN-DIFF estimate
	didresult.did = didresult.coef[4] - didresult.coef[2] - didresult.coef[3] + didresult.coef[1]

	// Dependent variable (potentially adjusted for covariates or rounded)
	if (cols(rhs)>2) {
		// adjust for covariates
		//     yadj = y - X * _b[X]
		//          = D * _b[D] + resid    (yadj is also rounded if round!=0)
		//
		// notice that control variables are columns 3 to cols(rhs) of the matrix rhs,
		// but are in rows 5 to rows(didresult.coef) of the regression's independent variables
		// because the treat/post dummies (the first two variables in rhs) were turned
		// into four group dummies in the regression
		didresult.Y = &round( y - rhs[.,3..cols(rhs)]*didresult.coef[5..rows(didresult.coef),1] , round)
	}
	else if (round!=0) {
		// no covariaters but need to round y
		didresult.Y = &round(y,round)
	}
	else {
		// no covariaters or rounding, just point to input vector
		didresult.Y = &y
	}
	return(didresult)
}


// QUANTILE DID MODEL, EQUATION 22
real rowvector qdid(real colvector Y00, real colvector Y01, real colvector Y10, real colvector Y11, real rowvector at, | real colvector W00, real colvector W01, real colvector W10, real colvector W11 )
{
	// Inputs:
	//   (1)-(4) Four column vectors with dependent variable
	//            - Y00 is data for the control group in pre-period
	//            - Y01 is data for the control group in post period
	//            - Y10 is data for the treatment group in post period
	//            - Y11 is data for the treatment group in post period
	//   (5)     Vector with k>=1 quantiles of interest, ranging from 0 to 1
	//   (6)-(9) (Optional) Column with fweights or iweights for Y00, Y01, Y10, and Y11 (respectively)
	//
	// Output: Vector with (k) elements. (one for each quantile in -at-).
	real rowvector qdid; qdid = J(1,length(at),.)
	real scalar i

	// Need all or none of args (6)-(9)
	if (args()>5 & args()!=9) _error(( "Expected 5 or 9 arguements, but received " + strofreal(args())))

	if (args()==5) {
		// No weights
		for(i=1; i<=length(at); ++i) {
			qdid[i] = cumdfinv(Y11,at[i])-cumdfinv(Y10:+mean(Y01):-mean(Y00),at[i])
		}
	}
	else {
		// With weights
		for(i=1; i<=length(at); ++i) {
			qdid[i] = cumdfinv(Y11,at[1,i],W11)-cumdfinv(Y10:+mean(Y01,W01):-mean(Y00,W00),at[1,i],W10)
		}
	}
	return(qdid)
}


// SAMPLE PROPORTIONS
real vector prob(real vector Y, real vector YS, |real vector wgt)
{
	// given a vector Y and a vector of support points YS
	// this function calculates the sample proportions at each of the support points
	// wgt is an (optional) set of weights for the vector Y
	real scalar n
	n = length(YS)
	if (args()==3) {
		// with weight variable
		return(rowsum((abs((YS:-J(n,1,Y'))):<=epsilon(1)):*J(n,1,wgt')):/J(n,1,quadcolsum(wgt)))
	}
	else {
		// without weights
		return(rowsum(abs((YS:-J(n,1,Y'))):<=epsilon(1)):/length(Y))
	}
}


// CUMULATIVE DISTRIBUTION FUNCTION
real scalar cdf(real scalar y, real vector P, real vector YS)
{
	// given a cumulative distrubtion function (P) over the support points (YS),
	// returns the empirical cumulative distribution function at a scalar (y)
	if      (y< YS[1])          return(0)
	else if (y>=YS[length(YS)]) return(1)
	else                        return(P[colsum((YS:<=(y+epsilon(y))))])
}


// INVERSE OF CUMULATIVE DISTRIBUTION FUNCTION, EQUATION 8
real scalar cdfinv(real scalar p, real vector P, real vector YS)
{
	// given a cumulative distrubtion function (P) over the support points (YS),
	// returns the inverse of the empirical cumulative distribution function at probability p (0<p<1)
	return(YS[min((length(YS)\select((1::length(YS)),(P:>=(p-epsilon(p))))))])
}


// INVERSE OF CUMULATIVE DISTRIBUTION FUNCTION, ALTERNATIVE FOR discrete OUTCOMES, EQUATION 24
real scalar cdfinv_brckt(real scalar p, real vector P, real vector YS)
{
	// given a cumulative distribution function (P) over the support points (YS),
	// returns the inverse of the empirical cumulative distribution function at probability p (0<p<1)
	// but if equals -oo, it returns min(YS)-100*(1+max(YS)-YS(min)) = 101*min(YS)-100*max(YS)-100
	if (p>=(P[1]-epsilon(1))) {
		return(YS[max(select((1::length(YS)),(P:<=(p+epsilon(p)))))])
	}
	else {
		return(101*YS[1]-100*YS[length(YS)]-100)
	}
}


// EMPIRICAL DISTRIBUTION FUNCTION
real scalar cumdfinv(real colvector X, real scalar p, |real colvector wgt)
{
	// given a vector of observations (X),
	// returns the empirical distribution of X evaluated at a point (p).
	// optionally, the vector X can have weights (wgt)
	if      (p<=epsilon(p))   return(min(X))
	else if (p>=1-epsilon(1)) return(max(X))
	else if (args()==2) {
		// without weights
		real scalar r
		r = length(X)*p
		return(sort(X,1)[floor(r+1-epsilon(r)),1])

		// Note that floor(r+1-epsilon(r)) is smallest integer larger than length(X)*p
		// e.g., if length(X)=10, p=0.34 then floor(3.4+1-2.2e-16)=4
		//       if length(X)=10, p=0.30 then floor(3.0+1-2.2e-16)=3
	}
	else {
		// with weights
		real matrix xs, sum_wgt
		xs = sort((X,wgt),1)
		sum_wgt = runningsum(xs[.,2]) :/ colsum(xs[.,2])
		sum_wgt[rows(xs),1]=1 // force sum of weights to 1

		// return the observation from fist row where cumulative sum of wgt is larger than p
		return(xs[colmin(select((1::rows(xs)),(sum_wgt:>=p) )),1])
	}
}


// FOR BOOTSTRAPPING, DRAW RANDOM SAMPLE WITH REPLACEMENT
real colvector bs_draw_nowgt(real colvector x)
{
	// Input:  Vector we're drawing rows from
	// Output: Vector with a simple random sample
	// (This function is adequate when x is a vector,
	// and when it is a permutatin vector)
	return(x[ceil(runiform(rows(x),1):*rows(x)),1])
}


// FOR BOOTSTRAPPING, DRAW RANDOM SAMPLE WITH REPLACEMENT
real colvector bs_draw_wgt(real colvector      p00, real colvector      p01, real colvector      p10, real colvector      p11,
                           real scalar         N00, real scalar         N01, real scalar         N10, real scalar         N11,
                         | real colvector cumsum00, real colvector cumsum01, real colvector cumsum10, real colvector cumsum11,
                           real scalar   popsize00, real scalar   popsize01, real scalar   popsize10, real scalar   popsize11)
{
	// Case 1: Unweighted
	// Inputs: 1-4.   Four (4) permutation vectors identifying the rows of data belonging to each group
	//         5-8.   Four (4) scalars with the number of observations in each group (e.g., N00=rows(p00))
	// Output: A frequency weight vector
	//
	// Case 2: Freqency or Importance Weights (fweights or iweights)
	// Inputs: 1-8.   All the inputs provided in Case 1 (unweighted)
	//         9-12.  Four (4) weight variables with cumulative sum of the weights from each group, normalized to sum to one within groups (e.g., cumsum00 = quadrunningsum(wgt[p00]); cumsum00 = cumsum00/cumsum00[N00])
	//         13-16. Four (4) scalars with population size for each group.
	//                  - With frequency weights, this is the weighted number of individuals in the group (e.g., popsize00 = cumsum00[n00])
	//                  - With importance weights, use the fraction of bssize (e.g., popsize00 = round(cumsum00[N00]/colsum(wgt)*bssize))
	// Output: A weight vector that replaces the input vector in cic_caller (wgt)
	//
	// This specialzed program was written to minimize processing time for CIC bootstrapping.
	// The basic principle is that anything calculated more than once should be caclulated
	// just once in cic_caller(), leaving only the tasks needed for each draw.
	// Case 2 code was modeled on mm_upswr() in the moremata package (version 1.0.0 by Ben Jann).
	real colvector u, reweight
	real scalar i, j
	reweight=J(N00+N01+N10+N11,1,0)

	if (args()==8) {
		// no weights, just a simple random draw from each group

		// random draw of permutation vectors
		u  = ( p00[ceil(runiform(N00,1):*N00),1] \
		       p01[ceil(runiform(N01,1):*N01),1] \
			   p10[ceil(runiform(N10,1):*N10),1] \
			   p11[ceil(runiform(N11,1):*N11),1] )

		// count number of times each row was drawn
		for (i=1;i<=rows(u);i++) {
			reweight[u[i]] = reweight[u[i]]+1
		}
	} // end unweighted section

	else if (args()==16) {
		// fweights or iweights
		real colvector r

		// 1st group
		u = sort(runiform(popsize00,1),1)   // random draw
		r = J(N00,1,0)
		j=1
		for (i=1;i<=popsize00;i++) {
			while (u[i]>cumsum00[j]) j++    // use cumulative distribution to get counts
			r[j] = r[j]+1                   // r will contain the number of observations drawn for each row
		}
		reweight[p00] = r                   // return results for this group

		// 2nd group
		u = sort(runiform(popsize01,1),1)
		r = J(N01,1,0)
		j=1
		for (i=1;i<=popsize01;i++) {
			while (u[i]>cumsum01[j]) j++
			r[j] = r[j]+1
		}
		reweight[p01] = r

		// 3rd group
		u = sort(runiform(popsize10,1),1)
		r = J(N10,1,0)
		j=1
		for (i=1;i<=popsize10;i++) {
			while (u[i]>cumsum10[j]) j++
			r[j] = r[j]+1
		}
		reweight[p10] = r

		// 4th group
		u = sort(runiform(popsize11,1),1)
		r = J(N11,1,0)
		j=1
		for (i=1;i<=popsize11;i++) {
			while (u[i]>cumsum11[j]) j++
			r[j] = r[j]+1
		}
		reweight[p11] = r

	} // end weights section
	else _error( "Expecting 8 arguments (unweighted) or 16 arguments (weighted), but received " + strofreal(args()) )
	return(reweight)
}


// AFTER BSTAT STATA COMMAND, USE 95 PERCENTILES OF BOOTSTRAP ITERATIONS TO BACK-OUT STANDARD ERRORS
void bs_se( string scalar in_ci, string scalar out_V )
{
	// Inputs: 1. Vector with
	//         2. Stata matrix name for output
	// Output: Stata matrix with square of standard errors on diagonal, zero' off diagonal
	real vector bs_se
	bs_se = (1 /(2 * 1.96)) * (st_matrix(in_ci)[2,.] - st_matrix(in_ci)[1,.])
	st_matrix(out_V,diag(bs_se:*bs_se))
	st_matrixcolstripe(out_V,st_matrixcolstripe(in_ci))
	st_matrixrowstripe(out_V,st_matrixcolstripe(in_ci))
}


// Univariate density function
real scalar fden(real scalar y, real colvector Y, | real colvector wgt) {
	// 	this function estimates a univariate density function using kernel methods
	// 	the kernel function is the Epanechnikov kernel
	// 	the bandwidth is the optimal bandwith based on Silverman's rule of thumb
	//
	// 	INPUT
	// 	the input is an N vector of observations Y
	// 	and a scalar y where the density is to be estimated
	//  optionally, provide a frequency weight vector
	//     (for iweghts, wgt must be normalized to the number of observations, so that
	//      sum of weights = number of obserations)
	//
	// 	OUTPUT
	// the output is a scalar with the value of the estimated density

	real scalar h
	real colvector d, kd

	// Silverman optimal bandwidth
	if (args()==2) h=1.06*sqrt(variance(Y))*(length(Y)^(-.2))     // unweighted
	else           h=1.06*sqrt(variance(Y,wgt))*(sum(wgt)^(-.2))  // weighted

	// epanechnikov kernel
	d= abs((Y:-y):/h)
	kd=(d:<sqrt(5)):*(.75:-.15*d:^2)/sqrt(5)

	// return density
	if (args()==2) return(mean(kd/h))     // unweighted
	else           return(mean(kd/h,wgt)) // weighted
}


// CUMULATIVE DISTRIBUTION FUNCTION
real scalar cdf_bar(real scalar y, real vector P, real vector YS)
{
	// given a cumulative distrubtion function (P) over the support points (YS),
	// returns the probability that a random variable
	// is less than a scalar value y
	if      (y<YS[1]+epsilon(y))          return(0)
	else if (y>YS[length(YS)]+epsilon(y)) return(1)
	else                                  return(P[colsum((YS:<(y-epsilon(y))))])
}


// Standard Error for CIC ROUTINE
real rowvector se_cic(real colvector Y00, real colvector Y01, real colvector Y10, real colvector Y11, struct cic_result scalar result , | real colvector W00, real colvector W01, real colvector W10, real colvector W11 )
{
	// Inputs:
	//   (1)-(4) Four column vectors with dependent variable
	//            - Y00 is data for the control group in pre-period
	//            - Y01 is data for the control group in post period
	//            - Y10 is data for the treatment group in post period
	//            - Y11 is data for the treatment group in post period
	//   (5)     Vector with k>=1 quantiles of interest, ranging from 0 to 1
	//   (6)-(9) (Optional) Column with fweights or iweights for Y00, Y01, Y10, and Y11 (respectively)
	//
	// Output: One 1x4 vector
	//   (1) V[1,1] = StdError^2 FOR CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9
	//   (2) V[1,2] = StdError^2 FOR CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29
	//   (3) V[1,3] = StdError^2 FOR LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25
	//   (4) V[1,4] = StdError^2 FOR UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25

	// Need all or none of args (6)-(9)
	if (args()>5 & args()!=9) _error(( "Expected 5 or 9 arguements, but received " + strofreal(args())))

	// Vector with support points for all four groups combined (YS) and the comparison-post group (YS01)
	real colvector YS, YS00, YS01, YS10, YS11
	YS00 = uniqrows(Y00)
	YS01 = uniqrows(Y01)
	YS10 = uniqrows(Y10)
	YS11 = uniqrows(Y11)
	YS   = uniqrows(Y00\Y01\Y10\Y11)
	if (length(YS)<2) _error("The dependent variable is a constant")

	// Vector with CDF functions of the four treat*post groups (F00,F01,F10,F11)
	// CDFs (w/ and w/out weights declared)
	real colvector f00, f01, f10, f11, F00, F01, F10, F11
	if (args()==5) {
		// CDFs without weights
		f00=prob(Y00,YS)
		f01=prob(Y01,YS)
		f10=prob(Y10,YS)
		f11=prob(Y11,YS)
	}
	else {
		// Confirm weights are integers
		if (trunc(W00\W01\W10\W11)!=(W00\W01\W10\W11)) _error( "Only frequency weights are allowed with se_cic()." )
		// CDFs with weights
		f00=prob(Y00,YS,W00)
		f01=prob(Y01,YS,W01)
		f10=prob(Y10,YS,W10)
		f11=prob(Y11,YS,W11)
	}
	// because of rounding, sum of probabilities might be slightly different than one
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// Results will be returned into a 4x1 row vector (con, dci, lower, upper)
	real rowvector V
	V=J(1,4,.)

	// A. continuous estimator
	// A.0. preliminaries
	real colvector F00_10, F01invF00_10, f01F01invF00_10, P, PY00, PY01
	real scalar V00, V01, V10, V11, i
	F00_10=F01invF00_10=f01F01invF00_10=J(length(YS10),1,0)
	for(i=1; i<=length(YS10); ++i) {
		F00_10[i]=cdf(YS10[i],F00,YS)
		F01invF00_10[i]=cdfinv(F00_10[i],F01,YS)
		f01F01invF00_10[i]=fden(F01invF00_10[i],Y01)
	}
	// A.1. contribution of Y00
	P=J(length(YS00),1,0)
	for(i=1; i<=length(YS00); ++i) {
		PY00=((YS00[i]:<=YS10)-F00_10):/f01F01invF00_10
		P[i]=quadcross(PY00,select(f10,f10:>epsilon(1)))
	}
	V00=sum(P:^2:*select(f00,f00:>epsilon(1))):/length(Y00)
	// A.2. contribution of Y01
	P=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		PY01=-((cdf(YS01[i],F01,YS):<=F00_10):-F00_10):/f01F01invF00_10
		P[i]=quadcross(PY01,select(f10,f10:>epsilon(1)))
	}
	V01=sum((P:^2):*select(f01,f01:>epsilon(1))):/length(Y01)
	// A.3. contribution of Y10
	P=F01invF00_10:-quadcross(F01invF00_10,select(f10,f10:>epsilon(1)))
	V10=sum(P:^2:*select(f10,f10:>epsilon(1))):/length(Y10)
	// A.4. contribution of Y11
	P=YS11:-quadcross(YS,f11)
	V11=sum((P:^2):*select(f11,f11:>epsilon(1))):/length(Y11)
	// A.5 final result
	V[1]=V00+V01+V10+V11
	// "sqrt(V[1]) = "; sqrt(V[1])

	// B. dci standard error
	// numerical approximation to delta method
	// four parts to variance
	// B.0. setup
	real colvector der00,der01,der10,der11,I00,I01,I10,I11,tI00,tI01,tI10,tI11,f00c,f01c,f10c,f11c,k_bar,t,dy11
	real scalar    delta,max00,max01,max10,max11,der00_c,der01_c,der10_c,der11_c
	der00=der01=der10=der11=J(length(YS),1,0)
	t=(1::length(YS))
	delta=0.0000001

	// B.1. contribution of Y00
	I00=f00:>epsilon(1)
	tI00=select(t,I00)
	max00=max(tI00)
	V00=(diag(f00)-quadcross(f00',f00'))/length(Y00)
	V00[max00,.]=J(1,length(YS),0)
	V00[.,max00]=J(length(YS),1,0)
	for(i=1; i<=(sum(I00)-1); ++i) {
		f00c=f00
		f00c[tI00[i]]=f00c[tI00[i]]+delta
		f00c[max00]  =f00c[max00]-delta
		der00_c=cic_dci(f00c,f01,f10,f11,YS,YS01,.)
		der00[tI00[i]]=(der00_c-result.dci[1])/delta
	}
	V00=quadcross(der00,V00)*der00
	// B.2. Contribution of Y01
	I01=f01:>epsilon(1)
	tI01=select(t,I01)
	max01=max(tI01)
	V01=(diag(f01)-quadcross(f01',f01'))/length(Y01)
	V01[max01,.]=J(1,length(YS),0)
	V01[.,max01]=J(length(YS),1,0)
	for(i=1; i<=sum(I01)-1; ++i) {
		f01c=f01
		f01c[tI01[i]]=f01c[tI01[i]]+delta
		f01c[max01]=f01c[max01]-delta
		der01_c=cic_dci(f00,f01c,f10,f11,YS,YS01,.)
		der01[tI01[i]]=(der01_c-result.dci[1])/delta
	}
	V01=quadcross(der01,V01)*der01
	// B.3. Contribution of Y10
	I10=f10:>epsilon(1)
	tI10=select(t,I10)
	max10=max(tI10)
	V10=(diag(f10)-quadcross(f10',f10'))/length(Y10)
	V10[max10,.]=J(1,length(YS),0)
	V10[.,max10]=J(length(YS),1,0)
	for(i=1; i<=sum(I10)-1; ++i) {
		f10c=f10
		f10c[tI10[i]]=f10c[tI10[i]]+delta
		f10c[max10]=f10c[max10]-delta
		der10_c=cic_dci(f00,f01,f10c,f11,YS,YS01,.)
		der10[tI10[i]]=(der10_c-result.dci[1])/delta
	}
	V10=quadcross(der10,V10)*der10
	// B.4. Contribution of Y11
	I11=f11:>epsilon(1)
	tI11=select(t,I11)
	max11=max(tI11)
	V11=(diag(f11)-quadcross(f11',f11'))/length(Y11)
	V11[max11,.]=J(1,length(YS),0)
	V11[.,max11]=J(length(YS),1,0)
	for(i=1; i<=sum(I11)-1; ++i) {
		f11c=f11
		f11c[tI11[i]]=f11c[tI11[i]]+delta
		f11c[max11]=f11c[max11]-delta
		der11_c=cic_dci(f00,f01,f10,f11c,YS,YS01,.)
		der11[tI11[i]]=(der11_c-result.dci[1])/delta
	}
	V11=quadcross(der11,V11)*der11
	// B.5 components dci variance
	V[2]=V00+V01+V10+V11
	// "sqrt(V[2]) = "; sqrt(V[2])

	// C. lower bound standard error
	k_bar=J(length(YS10),1,0)
	for(i=1; i<=length(YS10); ++i) {
		k_bar[i]=cdfinv(cdf(YS10[i],F00,YS),F01,YS)
	}
	k_bar=k_bar:-quadcross(k_bar,select(f10,f10:>epsilon(1)))
	dy11 =YS11 :-quadcross(YS11, select(f11,f11:>epsilon(1)))
	V10=sum((k_bar:^2):*select(f10,f10:>epsilon(1)))/length(Y10)
	V11=sum((dy11 :*dy11) :*select(f11,f11:>epsilon(1)))/length(Y11)
	V[3] = V10+V11
	// "sqrt(V[3]) = "; sqrt(V[3])

	// D. upper bound standard error
	k_bar=J(length(YS10),1,0)
	for(i=1; i<=length(YS10); ++i) {
		k_bar[i]=cdfinv(cdf_bar(YS10[i],F00,YS),F01,YS)
	}
	k_bar=k_bar:-quadcross(k_bar,select(f10,f10:>epsilon(1)))
	dy11 =YS11 :-quadcross(YS11, select(f11,f11:>epsilon(1)))
	V10=sum((k_bar:^2):*select(f10,f10:>epsilon(1)))/length(Y10)
	V11=sum((dy11:^2) :*select(f11,f11:>epsilon(1)))/length(Y11)
	V[4] = V10+V11
	// "sqrt(V[4]) = "; sqrt(V[4])

	// DONE.  RETURN STRUCTURE W/ ROW VECTORS CONTAINING POINT ESTIMATES.
	return(V)
} // end of cic_se


// CIC ESTIMATOR WITH CONTINUOUS OUTCOMES, EQUATION 9 (ONLY)
real vector cic_con(real vector f00, real vector f01, real vector f10, real vector f11, real vector YS, real vector YS01, real vector at)
{
	// this function calculates the continuous outcomes CIC estimator
	// first estimate the cdf of Y^N_11 using equation (9) in the paper and
	// then use that to calculate the average effect of the treatment
	real vector FCO, est_con
	real scalar i, F01y, F00invF01y, F10F00invF01y
	real colvector F00, F01, F10, F11

	// CDFs   (Because of rounding, sum of probabilities might be slightly different than one)
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// for each y in the support of Y01, fill in FCO(y)=F_10(F^-1_00(F_01(y)))
	FCO=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		F01y=cdf(YS01[i],F01,YS)
		F00invF01y=cdfinv(F01y,F00,YS)
		F10F00invF01y=cdf(F00invF01y,F10,YS)
		FCO[i] = F10F00invF01y
	}
	FCO[length(FCO)]=1 // =1 at end

	// mean CIC estimate
	est_con=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FCO-(0 \ FCO[1..(length(YS01)-1)]))'*YS01 )

	// quantile CIC estimate
	if (!missing(at)) {
		for(i=1; i<=length(at); ++i) {
			est_con = (est_con , ( cdfinv(at[i], F11, YS) - cdfinv(at[i], FCO, YS01) ) )
		}
	}

	// matrix has mean estimate in first column, plus one column for each element of "at"
	return(est_con)
}


// CIC MODEL WITH DISCRETE OUTCOMES (UNDER THE CONDITIONAL INDEPENDENCE ASSUMPTION), EQUATION 29 (ONLY)
real vector cic_dci(real vector f00, real vector f01, real vector f10, real vector f11, real vector YS, real vector YS01, real vector at)
{
	// this function calculates the discrete outcomes CIC estimator
	// first estimate the cdf of Y^N_11 using equation (29) in the paper and
	// then use that to calculate the average effect of the treatment
	real vector FDCI, FUB, FLB, est_dci
	real scalar i,F01y,F00invF01y,F10F00invF01y,F00invbF01y,F10F00invbF01y,F00F00invF01y,F00F00invbF01y,FDCI_weight
	real colvector F00, F01, F10, F11

	// CDFs   (Because of rounding, sum of probabilities might be slightly different than one)
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// for each y in the support of Y01, fill in FCO(y)=F_10(F^-1_00(F_01(y)))
	FDCI=FUB=FLB=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		F01y=cdf(YS01[i],F01,YS)
		F00invF01y=cdfinv(F01y,F00,YS)
		F10F00invF01y=cdf(F00invF01y,F10,YS)
		F00invbF01y=cdfinv_brckt(F01y,F00,YS)
		F10F00invbF01y=cdf(F00invbF01y,F10,YS)
		F00F00invF01y =cdf(F00invF01y ,F00,YS)
		F00F00invbF01y=cdf(F00invbF01y,F00,YS)
		FLB[i]=F10F00invbF01y
		FUB[i]=F10F00invF01y
		if ((F00F00invF01y-F00F00invbF01y)>epsilon(1)) FDCI_weight=(F01y-F00F00invbF01y)/(F00F00invF01y-F00F00invbF01y)
		else                                           FDCI_weight=0
		FDCI[i]=FLB[i]+(FUB[i]-FLB[i])*FDCI_weight
	}
	FDCI[length(FDCI)]=1 // =1 at end

	// conditional independence estimate
	est_dci=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FDCI-(0 \ FDCI[1..(length(YS01)-1)]))'*YS01 )

	// quantile CIC estimate
	if (!missing(at)) {
		for(i=1; i<=length(at); ++i) {
			est_dci = (est_dci , ( cdfinv(at[i], F11, YS) - cdfinv(at[i], FDCI, YS01) ) )
		}
	}

	// matrix has mean estimate in first column, plus one column for each element of "at"
	return(est_dci)
}


// LOWER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25 (ONLY)
real vector cic_lower(real vector f00, real vector f01, real vector f10, real vector f11, real vector YS, real vector YS01, real vector at)
{
	// this function calculates the discrete outcomes CIC estimator
	// first estimate the cdf of Y^N_11 using equation (29) in the paper and
	// then use that to calculate the average effect of the treatment
	real vector FLB, est_lower
	real scalar i,F01y, F00invbF01y,F10F00invbF01y
	real colvector F00, F01, F10, F11

	// CDFs   (Because of rounding, sum of probabilities might be slightly different than one)
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// for each y in the support of Y01, fill in FCO(y)=F_10(F^-1_00(F_01(y)))
	FLB=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		F01y=cdf(YS01[i],F01,YS)
		F00invbF01y=cdfinv_brckt(F01y,F00,YS)
		F10F00invbF01y=cdf(F00invbF01y,F10,YS)
		FLB[i]=F10F00invbF01y;
	}
	FLB[length(FLB)]=1 // =1 at end

	// estimate
	est_lower=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FLB-(0 \ FLB[1..(length(YS01)-1)]))'*YS01 )

	// quantile CIC estimate
	if (!missing(at)) {
		for(i=1; i<=length(at); ++i) {
			est_lower = (est_lower , ( cdfinv(at[i], F11, YS) - cdfinv(at[i], FLB, YS01) ) )
		}
	}

	// matrix has mean estimate in first column, plus one column for each element of "at"
	return(est_lower)
}


// UPPER BOUND ESTIMATE OF DISCRETE CIC MODEL (WITHOUT CONDITIONAL INDEPENDENCE), EQUATION 25 (ONLY)
real vector cic_upper(real vector f00, real vector f01, real vector f10, real vector f11, real vector YS, real vector YS01, real vector at)
{
	// this function calculates the discrete outcomes CIC estimator
	// first estimate the cdf of Y^N_11 using equation (29) in the paper and
	// then use that to calculate the average effect of the treatment
	real vector FUB, est_upper
	real scalar i,F01y,F00invF01y,F10F00invF01y
	real colvector F00, F01, F10, F11

	// CDFs   (Because of rounding, sum of probabilities might be slightly different than one)
	F00=runningsum(f00); F00[length(F00)]=1
	F01=runningsum(f01); F01[length(F01)]=1
	F10=runningsum(f10); F10[length(F10)]=1
	F11=runningsum(f11); F11[length(F11)]=1

	// for each y in the support of Y01, fill in FCO(y)=F_10(F^-1_00(F_01(y)))
	FUB=J(length(YS01),1,0)
	for(i=1; i<=length(YS01); ++i) {
		F01y=cdf(YS01[i],F01,YS)
		F00invF01y=cdfinv(F01y,F00,YS)
		F10F00invF01y=cdf(F00invF01y,F10,YS)
		FUB[i]=F10F00invF01y;
	}
	FUB[length(FUB)]=1 // =1 at end

	// estimate
	est_upper=( (F11-(0 \ F11[1..(length(YS)-1)]))'*YS - (FUB-(0 \ FUB[1..(length(YS01)-1)]))'*YS01 )

	// quantile CIC estimate
	if (!missing(at)) {
		for(i=1; i<=length(at); ++i) {
			est_upper = (est_upper , ( cdfinv(at[i], F11, YS) - cdfinv(at[i], FUB, YS01) ) )
		}
	}

	// matrix has mean estimate in first column, plus one column for each element of "at"
	return(est_upper)
}


end
/* * * * *  END OF MATA BLOCK * * * * */
