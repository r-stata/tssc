*! Timothy Neal -- 10/09/15
*! This is the first public version of xtkr, used to conduct Keane-Runkle regressions on dynamic panel data sets (N >> T). 
*! If there are any questions, issues, or comparatibility problems with this procedure, please email timothy.neal@unsw.edu.au. 
program define xtkr, eclass prop(xt)
	version 11
	
	*! Parses ivregress syntax 
	_iv_parse `0'
	local Y `s(lhs)'
	local endo `s(endog)'
	local Xs `s(exog)'
	local instr `s(inst)'
	local 0 `s(zero)'

	syntax [if] [in] [, NOCONS TDUM] 

	qui {	
	*! Mark the sample that is usable, identify the panel and time variable, and calculate other panel statistics.
	marksample touse
	xtset
	local ivar `r(panelvar)'
	local tvar `r(timevar)'
	tempname is t m
	quie levels `ivar' if `touse', local(ids)
	local is=wordcount("`ids'")
	tempvar constant e e2 samplevar
	local Yname = "`Y'"
	if "`nocons'" == "" {
		local names = "`Xs' `endo' constant"
		local instrlist = "`Xs' constant `instr'"
	}
	else {
		local names = "`Xs' `endo'"
		local instrlist = "`Xs' `instr'"
	}
	
	*! Time-demean the data (if specified)
	if "`tdum'" != "" {
		local i = 1
		foreach x in `Y' `Xs' `endo' `instr' {
			tempvar td`i' hold timemeans		
			local `i' += 1
			gen `hold' = `x'
			bysort `tvar': egen `timemeans' = mean(`hold')
			sort `ivar' `tvar'
			qui gen `td`i'' = `hold' - `timemeans'
			drop `timemeans'
			drop `hold'
			local demeanlist "`demeanlist' `td`i''"
		}
 		
		*! Understand the number of variables in each
		local numxs = wordcount("`Xs'")
		local numendo = wordcount("`endo'")
		local numinstr = wordcount("`instr'")
			
		*! Replace original variable macros with time-demeaned versions
		tokenize `demeanlist'
		local Y = "`1'"
		local i = 1
		if `numxs' > 0 {
			local Xs ""
			forvalues j = 1/`numxs' {
				local i = `i' + 1
				local Xs "`Xs' ``i''"
			}
		}
		if `numendo' > 0 {
			local endo ""
			forvalues j = 1/`numendo' {
				local i = `i' + 1
				local endo "`endo' ``i''"
			}
		}		
		if `numinstr' > 0 {
			local instr ""
			forvalues j = 1/`numinstr' {
				local i = `i' + 1
				local instr "`instr' ``i''"
			}
		}		
	}
	
	*! Set up a list of all variables that will need to be transformed
	local transformvarlist "`transformvarlist' `Y' `Xs' `endo'" 
	if "`nocons'" == "" {
		gen `constant' = 1
		local transformvarlist "`transformvarlist' `constant'"
	}
	*! Do an initial 2SLS regression on the data to get the residuals.
	if "`nocons'" == "" {
		ivregress 2sls `Y' `Xs' `constant' (`endo' = `instr') if `touse', nocons
	}
	else {
		ivregress 2sls `Y' `Xs' (`endo' = `instr') if `touse', nocons
	}

	*! Prepare the data for the mata command
	local krnum = wordcount("`transformvarlist'")
	predict double `e' if e(sample), resid
	local t = e(N)/`is'
	gen `samplevar' = 0
	replace `samplevar' = 1 if e(sample)

	*! Generate new vars to hold the transformed variables 
	local l = 0
	foreach v of local transformvarlist {
		local l = `l' + 1
		tempvar kr_`l'
		qui gen `kr_`l'' = .
		local krvars "`krvars' `kr_`l''"
	}

	*! Run Mata command for the transformation
	mata: krtransform("`transformvarlist'", "`krvars'", "`e'", "`samplevar'", `t', `is', `krnum')

	*! 2SLS on transformed variables to get the beta coefficients
	tokenize `krvars'
	local krY `1'
	mac shift
	local krX `*'
	if "`nocons'" == "" {
		ivregress 2sls `krY' (`krX' = `instr' `Xs' `constant') if `touse', nocons
	}
	else {
		ivregress 2sls `krY' (`krX' = `instr' `Xs') if `touse', nocons
	}

	*! Standard error and t-statistic calculation
	predict double `e2' if e(sample), resid
	local Obs = e(N)
	mata: varcorrect("`e2'")

	*! Put column and row labels on the result matrices
	matrix b = e(b)
	matrix colnames b = `names'
	matrix rownames V = `names'
	matrix colnames V = `names'

	*! Display results
	noi {
		di _newline
		di in gr "Keane-Runkle (1992) Regression"
		di in gr "Number of Obs: `Obs'" _col(37) "Number of Panel Units: `is'"
		ereturn post b V, depname("`Yname'") obs(`Obs') esample(`samplevar')
		noi ereturn display
		di in gr "Instruments: `instrlist'"
		if ("`tdum'" != "") di in gr "Data has been time-demeaned."
	}
}

*! Mata functions:
*! 'krtransform' takes the dependent variable, exogenous variables, and endogenous variables and applies the Keane-Runkle transformation (panel forward factorisation).
*! 'varcorrect' corrects the variance-covariance matrix from the second 2sls
end

mata:
void krtransform(string scalar varlist, string scalar newvarlist, string scalar residuals, string scalar touse, real scalar T, real scalar N, real scalar M)
{
	real vector e, ehold, temphold
	real matrix eshape1, cmom, sigmat, vars, varshold, Phat, Qhat
	
	st_view(e, ., tokens(residuals), touse)
	st_view(vars, ., tokens(varlist), touse)
	st_view(newvars, ., tokens(newvarlist), touse)
	ehold = e
	eshape1 = colshape(ehold, T)	
	cmom = cross(eshape1, eshape1)
	
 	sigmat = cmom / N
	Phat = cholesky(invsym(sigmat))
	
	Qhat = I(N) # Phat
	
	for (i = 1; i<= M; i++) {
		temphold = vars[.,i]
		newvars[.,i] = cross(Qhat,temphold)
	}
}

void varcorrect(string scalar residuals)
{
	real scalar Var
	real vector e
	real matrix V, Vadj
	
	V = st_matrix("e(V)")	
	st_view(e, ., tokens(residuals))
	Var = variance(e)
	Vadj = V / Var
	st_matrix("V",Vadj)
}
end
