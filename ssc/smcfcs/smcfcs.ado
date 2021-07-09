*! J Bartlett & T Morris
* For history, see end of this file.

capture program drop smcfcs
program define smcfcs,eclass
version 11.0
syntax anything(name=smstring), [REGress(varlist)] [LOGIt(varlist)] [poisson(varlist)] [nbreg(varlist)] [mlogit(varlist)] [ologit(varlist)] [time(varname)] [enter(varname)] [failure(varname)] [ITERations(integer 10)] [m(integer 5)] [rjlimit(integer 1000)] [passive(string)] [eq(string)] [rseed(string)] [chainonly] [savetrace(string)] [NOIsily] [by(varlist)] [clear] [exposure(varname)]

*check mi has not been set already
quietly mi query
if "`r(style)'" != "" {
  if "`r(M)'" == "0" | "`clear'" == "clear" {
    local miconv `r(style)'
    mi extract 0, clear
  }
  else {
    display as error "Data are already mi set and contain imputations."
    exit 0
  }
}

if "`rseed'"!="" {
	set seed `rseed'
}

*split smstring into component parts
tokenize `smstring'
local smcmd `1'
macro shift

*check that outcome regression command is one of those supported
if "`smcmd'"=="reg" {
	local smcmd = "regress"
}
if "`smcmd'"=="logit" {
	local smcmd = "logistic"
}
if (inlist("`smcmd'","stcox","logistic","regress","compet", "poisson")==0) {
		display as error "Specified substantive model regression command (`smcmd') not supported by smcfcs"
		exit 0
}

if ("`smcmd'"!="stcox") & ("`smcmd'"!="compet") {
		local smout `1'
		macro shift
}
local smcov `*'

if ("`smcmd'"=="compet") {
	if ("`failure'"=="") {
		display as error "For competing risks outcomes you must specify an integer valued failure type variable"
		exit 0
	}
	if ("`time'"=="") {
		display as error "For competing risks outcomes you must specify a time variable indicating time of failure (or censoring)"
		exit 0
	}
}

*ensure that all partially observed cts variables are floating point type
if "`regress'"!="" {
	foreach var of varlist `regress' {
		recast float `var'
	}
}

*smcov consists of either fully observed covariates, regular covariates, or passively imputed covariates
*here we check the covariates listed to make sure they are either fully observed, missing and
*is specified using one of the options (e.g. regress), or is defined within the passive option

*to do this we first need a list of the passively defined variables
local passiveparse `passive'
tokenize "`passiveparse'", parse("|")
local passivedef
while "`1'"!="" {
	if "`1'"=="|" {
		macro shift
	}
		else {
		local rest `*'
		local currentpassivedef "`1'"
		tokenize `currentpassivedef', parse("=")
		local passivedef `passivedef' `1'
		tokenize "`rest'" , parse("|")
		macro shift
	}
}

local partiallyObserved `regress' `logit' `poisson' `nbreg' `mlogit' `ologit'

local exit=0
local varcheck: subinstr local smcov "i." "", all
foreach var in `smcov' {
	local varminusidot : subinstr local var "i." "", all
	quietly misstable summ `varminusidot'
	if "`r(vartype)'" == "none" {
		local fullyObserved `fullyObserved' `var'
	}
	else {
		local inpartial: list varminusidot in partiallyObserved
		if "`inpartial'"=="0" {
			*check that the variable is defined in the passive option
			local inpassive: list varminusidot in passivedef
			if "`inpassive'"=="0" {
				display as error "Covariate (`var') must either be fully observed, included in one of the imputation model options, or be defined in a passive statement."
				local exit=1
			}
		}
	}
}
if `exit'==1 {
	exit
}


local allCovariates `partiallyObserved' `fullyObserved'

local catmiss `logit' `mlogit' `ologit'

*process custom equation specification, if any
if "`eq'" != "" {
	tokenize `eq', parse("|")
	local i = 1
	while "``i''" != "" {
		if "``i''" != "|" {
			*split by colon
			tokenize ``i'', parse(":")
			local depVar `1'
			local indVars `3'
			local `depVar'impModelPred `indVars'
		}
		local i = `i' + 1
		tokenize `eq', parse("|")
	}
}


*construct commands to fit covariate models
di as text _newline "Covariate models:"
foreach var of varlist `partiallyObserved' {

	if "``var'impModelPred'"=="" {
		local impModelPredictors : list allCovariates - var
		local origImpModelPredictors `impModelPredictors'
		*make categorical predictors i.
		foreach predictor of local origImpModelPredictors {
			local predictorcat: list predictor in catmiss
			if `predictorcat'==1 {
				local impModelPredictors: subinstr local impModelPredictors "`predictor'" "i.`predictor'"
			}
		}	
	} 
	else {
		local impModelPredictors ``var'impModelPred'
	}
	
	local `var'impModelPred `impModelPredictors'

	local covtype: list var in regress
	if `covtype'==1 {
				local `var'covariateModelFit reg `var' `impModelPredictors'
	}
	else {
		local covtype: list var in logit
		if `covtype'==1 {
			local covtype = 2
			local `var'covariateModelFit logistic `var' `impModelPredictors', coef
		}
		else {
			local covtype: list var in poisson
			if `covtype'==1 {
				local covtype = 3
				local `var'covariateModelFit poisson `var' `impModelPredictors'
			}
			else {
				local covtype: list var in nbreg
				if `covtype'==1 {
					local covtype = 4
					local `var'covariateModelFit nbreg `var' `impModelPredictors'
				}
				else {
					local covtype: list var in mlogit
					if `covtype'==1 {
						local covtype = 5
						quietly levelsof `var', local(levels)
						tokenize `levels'
						local `var'covariateModelFit mlogit `var' `impModelPredictors', baseoutcome(`1')
					}
					else {
						local covtype = 6
						local `var'covariateModelFit ologit `var' `impModelPredictors'
					}
				}
			}
		}
	}
	di as text "``var'covariateModelFit'"
}

local dipassive `passive'
tokenize "`dipassive'", parse("|")
local i = 1
if "``i''" != "" {
	di as text _newline "Your passive statement(s) say:"
}
while "``i''" != "" {
	if "``i''" != "|" {
		display as text `"``i''"'
	}
	local i = `i' + 1
}

if "`chainonly'"!="" {
	local m = 1
}

local quietnoisy quietly
if "`noisily'"!="" {
	local quietnoisy
}

tempvar bygr
if "`by'"!="" {
	egen `bygr' = group(`by'), label
	`quietnoisy' summ `bygr'
	local numgroups=r(max)
}
else {
	gen `bygr' = 1
	local numgroups 1
}

tempvar smcfcsid
gen `smcfcsid' = _n

`quietnoisy' forvalues groupnum = 1/`numgroups' {
	if "`by'"!="" {
		noisily display
		noisily display as text "Imputing for group defined by (`by') = " _continue
		local labelval: label `bygr' `groupnum'
		noisily display "`labelval'"
	}
	
	`quietnoisy' forvalues imputation = 1/`m' {
		preserve

		keep if `bygr'==`groupnum'
		
		*generate t0Index, to account for delayed entry/left truncation, if necessary
		if "`smcmd'"=="stcox" {
			`quietnoisy' stdescribe
			if (r(t0_max)>0) {
					`quietnoisy' di "Late entry survival data detected"
				mata: t0IndexGen("_t", "_t0")
			}
		}
		if "`smcmd'"=="compet" {
			if "`enter'"!="" {
				`quietnoisy' di "Late entry competing risks data"
				mata: t0IndexGen("`time'", "`enter'")
			}
		}

		*generate observation indicators
		foreach var of varlist `partiallyObserved' {
			tempvar `var'_r
			gen ``var'_r' = (`var'!=.)
		}

		*perform preliminary imputation of covariates by sampling from observed values, as in ice
		foreach var of varlist `partiallyObserved' {
			mata: imputePermute("`var'", "``var'_r'")
		}
		updatevars, passive(`passive')
		
		*if substantive model is linear or logistic, and there are missing values in outcome, perform preliminary by resampling observed values
		if (inlist("`smcmd'","logit","logistic","regress")==1) {
			misstable summ `smout'
			if "`r(vartype)'" != "none" {
				if `imputation' == 1 {
					noisily di ""
					noisily di "Missing values in outcome are being imputed using the assumed substantive/outcome model."
				}
				local outcomeMiss = 1
				tempvar `smout'_r
				gen ``smout'_r' = (`smout'!=.)
				
				`smcmd' `smout' `smcov'
				
				*preliminary improper imputation, based on fit to those with outcome observed
				if e(cmd)=="regress" {
					tempvar xb
					predict `xb', xb
					replace `smout' = `xb' + e(rmse)*rnormal() if ``smout'_r'==0
				}
				else {
					tempvar pr
					predict `pr', pr
					replace `smout' = (runiform()<`pr') if ``smout'_r'==0
				}
			}
			else {
				local outcomeMiss = 0
			}
		}
		
		gen _mj=0

		replace _mj = `imputation'
		forvalues cyclenum = 1(1)`iterations' {
			local tracestring
			foreach var of varlist `partiallyObserved' {
				*fit covariate model
				``var'covariateModelFit' 
				*impute missing covariate values
				mata: covImp("``var'_r'")
			}
			
			*if necessary, impute outcome
			if e(cmd)=="regress" | e(cmd)=="logistic" | e(cmd)=="logit" {
				if `outcomeMiss' == 1 {
					mata: outcomeImp("``smout'_r'")
				}		
			}
			
			if "`savetrace'"!="" {
				tempname b
				if "`smcmd'"=="compet" {
					*if competing risks outcome, modify e(b) so it contains parameters of all Cox models
					quietly summ `failure'
					local numFailures = r(max)
					forvalues i=1(1)`numFailures' {
						local existcoefnames : colnames b`i'
						local newcoefnames
						foreach var of local existcoefnames {
							local newcoefnames `newcoefnames' failure`i'_`var'
						}
						matrix colnames b`i' = `newcoefnames'
					}
					matrix `b'=b1
					forvalues i=2(1)`numFailures' {
						matrix `b'=`b',b`i'
					}
				}
				else {
					matrix `b'=e(b)
				}
				
				*first time, set up postfile
				if "`groupnum'"=="1" & "`imputation'"=="1" & "`cyclenum'"=="1" {
					local postfilestring imp iter
					local coefnames : colnames `b'
					local coefnames : subinstr local coefnames "." "", all
					local newcoefnames
					foreach name of local coefnames {
						local newcoefnames `newcoefnames' est`name'
					}
					local postfilestring `postfilestring' `newcoefnames'
					tempname tracefile
					postfile `tracefile' `postfilestring' using `savetrace', replace
				}
			
				*post iteration and current estimates of substantive model parameters
				local numparms = colsof(`b')
				local nextcoef = (`b'[1,1])
				local tracestring (`nextcoef')
				forvalues parm=2(1)`numparms' {
					local nextcoef = `b'[1,`parm']
					local tracestring `tracestring' (`nextcoef')
				}
				di "`tracestring'"
				post `tracefile' (`imputation') (`cyclenum') `tracestring'
			}
		}
		*save imputed dataset
		tempfile smcfcsimp_`groupnum'_`imputation'
		save `smcfcsimp_`groupnum'_`imputation''
		noisily _dots 1 0
	//  noisily display as text "Imputation " as result `imputation' as text " complete"
		restore
	}
}

if "`savetrace'"!="" {
	postclose `tracefile'
}

if "`chainonly'"!="" {
	di ""
	di "Chainonly option specified. No imputations produced."
	
	capture drop t0Index
	capture drop H0
}
else {
	*combine imputed datasets across by groups
	forvalues groupnum = 1/`numgroups' {
		forvalues imputation = 1(1)`m' {
			quietly append using `smcfcsimp_`groupnum'_`imputation''
		}
	}
	
	capture drop t0Index
	capture drop H0
	
	quietly replace _mj=0 if _mj==.
	quietly gen _mi=`smcfcsid'
	quietly sort _mj _mi

	display as result _newline `m' as text " imputations generated"

	*import into Stata's official mi commands and convert to user's favoured form
	noisily mi import ice, clear
	quietly mi register imputed `partiallyObserved'
	if "`passivedef'"!="" {
		quietly mi register passive `passivedef'
	}
	if "`outcomeMiss'"=="1" {
		quietly mi register imputed `smout'
	}
	if "`miconv'" != "" & "`miconv'" != "flong" {
		mi convert `miconv' , clear
	}

	if "`by'"=="" {
		display as text "Fitting substantive model to multiple imputations"
		if "`smcmd'"=="compet" {
			quietly summ `failure'
			local numFailures = r(max)
			forvalues i=1(1)`numFailures' {
				display as text "Cox model for cause `i'"
				mi stset `time', failure(`failure'==`i') enter(`enter')
				mi estimate: stcox `smcov'
			}
			*clear stset info, to avoid user not being clear which failure type is currently stset
			mi stset, clear
			display as text "The data are now not stset. To fit Cox models, you should use mi stset with the failure type of interest specified using the failure() option"
		}
		else {
			if "`smcmd'"=="compet" {
				local outcomeModelCommand stcox `smcov'
			}
			else if ("`smcmd'"=="poisson") & ("`exposure'"!="") {
				local outcomeModelCommand `smcmd' `smout' `smcov', exposure(`exposure')
			}
			else {
				local outcomeModelCommand `smcmd' `smout' `smcov'
			}
			mi estimate: `outcomeModelCommand'
		}
	}
	else {
		display as text "Since you imputed separately by groups, smcfcs has not fitted a model to the combined (across groups) imputations."
	}
}

end


capture program drop updatevars
program define updatevars
syntax [, passive(string)]
tokenize "`passive'", parse("|")
local i = 1
while "``i''" != "" {
	if "``i''" != "|" {
		replace ``i''
	}
	local i = `i' + 1
}
end

capture program drop postdraw_strip
program define postdraw_strip

	matrix smcfcsb = e(b)
	matrix smcfcsv = e(V)

	_ms_omit_info smcfcsb
	local cols = colsof(smcfcsb)
	matrix smcfcsnomit =  J(1,`cols',1) - r(omit)
end

mata:
mata clear

void postdraw() {

	stata("postdraw_strip")

	stripV = select(st_matrix("smcfcsv"),(st_matrix("smcfcsnomit")))
	stripV = select(stripV, (st_matrix("smcfcsnomit"))')

	stripB = select(st_matrix("smcfcsb"),(st_matrix("smcfcsnomit")))

	if (st_global("e(cmd)")=="regress") {
		sigmasq = st_numscalar("e(rmse)")^2
		df = st_numscalar("e(df_r)")
		newsigmasq = sigmasq*df/rchi2(1,1,df)
		st_numscalar("smcfcs_resvar", newsigmasq)
		stripV = (newsigmasq/sigmasq)*stripV
	}

	
	/*take draw*/
	newstripB = transposeonly( transposeonly(stripB) + cholesky(stripV) * rnormal(1,1,J(cols(stripB),1,0),J(cols(stripB),1,1)) )

	/*recombine*/
	b = st_matrix("e(b)")
	
	b[,select(1..length(st_matrix("smcfcsnomit")), st_matrix("smcfcsnomit"))] = newstripB
	
	st_matrix("smcfcsnewb",b)
	stata("ereturn repost b=smcfcsnewb")
}

void imputePermute(string scalar varName, string scalar obsIndicator)
{
	data = st_data(., varName)
	r = st_data(., obsIndicator)
	n = st_nobs()
	imputationNeeded = select(transposeonly(1..n),J(n,1,1)-r)
	observedValues = select(data,r)
	numObserved = rows(observedValues)
	for (j=1; j<=length(imputationNeeded); j++) {
		i = imputationNeeded[j]
		/* randomly sample from observed values */
		draw = observedValues[ceil(runiform(1,1)*numObserved)]
		data[i] = draw
	}
	st_store(., varName, data)
}

/*generates a Stata variable t0Index that is used to locate H0(_t0) in Cox models*/
void t0IndexGen(string scalar timeName, string scalar enterName)
{
	st_view(t, ., timeName)
	st_view(t0, ., enterName)
	n = st_nobs()
	
	loc = t, (1..n)'
	loc = sort(loc,1)
	(void) st_addvar("long", "t0Index")
	st_view(t0Index, ., "t0Index")
	
	for (i=1; i<=n; i++) {
		lastIndex = sum(loc[.,1] :<= J(n,1,t0[i]))
		if (lastIndex==0) {
			t0Index[i] = 0
		}
		else {
			t0Index[i] = loc[lastIndex,2]
		}
	}
}

void outcomeImp(string scalar missingnessIndicatorVarName)
{	
	/* fit substantive mode */
	smcmd = st_local("smcmd")
	smout = st_local("smout")
	smcov = st_local("smcov")

	/*fit substantive model to those with outcome observed only, since this should speed up convergence */
	outcomeModelCommand = smcmd + " " + smout + " " + smcov + " if " + missingnessIndicatorVarName + "==1"
	stata(outcomeModelCommand)
		
	outcomeModelCmd = st_global("e(cmd)")
	postdraw()
	
	if (outcomeModelCmd=="regress") {
		newsigmasq = st_numscalar("smcfcs_resvar")
	}

	/* calculate fitted values */
	stata("predict smcfcsxb, xb")
	st_view(xb, ., "smcfcsxb")
	
	if (outcomeModelCmd=="regress") {
		fittedMean = xb
	}
	else if ((outcomeModelCmd=="logit") | (outcomeModelCmd=="logistic")) {
		fittedMean = invlogit(xb)
	}
	
	n = st_nobs()
	st_view(r, ., missingnessIndicatorVarName)
	imputationNeeded = select(transposeonly(1..n),J(n,1,1)-r)
	st_view(outcomeVar, ., smout)
	if (outcomeModelCmd=="regress") {
		outcomeVar[imputationNeeded] = rnormal(1,1,fittedMean[imputationNeeded],newsigmasq^0.5)
	}
	else if ((outcomeModelCmd=="logit") | (outcomeModelCmd=="logistic")) {
		outcomeVar[imputationNeeded] = rbinomial(1,1,1, fittedMean[imputationNeeded])
	}
	
	st_dropvar("smcfcsxb")
}


void covImp(string scalar missingnessIndicatorVarName)
{
	r = st_data(., missingnessIndicatorVarName)
	rjLimit = strtoreal(st_local("rjlimit"))
	passive = st_local("passive")
	
	/* extract information from covariate model (which has just been fitted) */
	n = st_numscalar("e(N)")
	
	covariateModelCmd = st_global("e(cmd)")
	postdraw()
	newbeta = transposeonly(st_matrix("e(b)"))
		
	/* calculate fitted values */
	stata("predict smcfcsxb, xb")
	xb = st_data(., "smcfcsxb")
			
	if (covariateModelCmd=="regress") {
		fittedMean = xb
		newsigmasq = st_numscalar("smcfcs_resvar")
	}
	else if (covariateModelCmd=="logistic") {
		fittedMean = invlogit(xb)	
	}
	else if (covariateModelCmd=="poisson") {
		fittedMean = exp(xb)
	}
	else if (covariateModelCmd=="nbreg") {
		//alpha is the dispersion parameter
		alpha = exp(newbeta[rows(newbeta),1])
		fittedMean = exp(xb)
	}
	else if ((covariateModelCmd=="mlogit") | (covariateModelCmd=="ologit")) {
		if (covariateModelCmd=="mlogit") {
			numberOutcomes = st_numscalar("e(k_out)")
			catvarlevels = st_matrix("e(out)")
		}
		else {
			numberOutcomes = st_numscalar("e(k_cat)")
			catvarlevels = st_matrix("e(cat)")
		}
		mologitpredstr = "predict mologitprOutcomeNum, outcome(#OutcomeNum) pr"
		prOutVarstr = "mologitpr1"
		stata(subinstr(mologitpredstr, "OutcomeNum", "1"))
		for (i=2; i<=numberOutcomes; i++) {
			prOutVarstr = prOutVarstr , subinstr("mologitprx", "x", strofreal(i))
			stata(subinstr(mologitpredstr, "OutcomeNum", strofreal(i)))
		}
		fittedMean = st_data(., prOutVarstr)
		for (i=1; i<=numberOutcomes; i++) {
			st_dropvar(subinstr("mologitprOutcomeNum", "OutcomeNum", strofreal(i)))
		}
		//calculate running row sums (in built mata can't do this apparently)
		cumProbs = fittedMean
		for (i=2; i<=numberOutcomes; i++) {
			cumProbs[.,i] = cumProbs[.,i-1] + cumProbs[.,i]
		}
		//due to rounding errors last column sometimes slightly differs from 1, so set to 1
		cumProbs[.,numberOutcomes] = J(rows(cumProbs),1,1)
	}
	
	st_dropvar("smcfcsxb")
	
	/* fit substantive model */
	smcmd = st_local("smcmd")
	smout = st_local("smout")
	smcov = st_local("smcov")
	exposureTime = st_local("exposure")
	if (smcmd=="compet") {
		d = st_data(., st_local("failure"))
		numFailures = max(d)
		H0Mat = J(n,numFailures,0)
		/*fit model for each failure type*/
		for (i=1; i<=numFailures; i++) {
			stata("stset "+st_local("time")+", failure("+st_local("failure")+"=="+strofreal(i)+") enter("+st_local("enter")+")")
			stata("stcox "+smcov)
			postdraw()
			/*save posterior draw for calculating linear predictors later*/
			stata("matrix b"+strofreal(i)+"=e(b)")
			stata("predict H0, basechazard")
			H0Mat[,i] = st_data(., "H0")
			st_dropvar("H0")
			
			/*generate H0(_t0) for delayed entry, if needed*/
			if (_st_varindex("t0Index")!=.) {
				H0append = 0 \ H0Mat[,i]
				t0Index = 1 :+ st_data(., "t0Index")
				H0_t0 = H0append[t0Index]
				/*now we can replace H0 with H0(t)-H0(t0)*/
				H0Mat[,i] = H0Mat[,i] - H0_t0
			}
		}
	}
	else {
		if (smcmd=="stcox") {
			outcomeModelCommand = smcmd + " " + smcov
			stata(outcomeModelCommand)
			postdraw()
			stata("predict H0, basechazard")
			d = st_data(., "_d")
			t = st_data(., "_t")
			H0 = st_data(., "H0")
			st_dropvar("H0")
			
			/*generate H0(_t0) for delayed entry, if needed*/
			if (_st_varindex("t0Index")!=.) {
				H0append = 0 \ H0
				t0Index = 1 :+ st_data(., "t0Index")
				H0_t0 = H0append[t0Index]
				/*now we can replace H0 with H0(t)-H0(t0)*/
				H0 = H0 - H0_t0
			}
		}
		else {
			if ((smcmd=="poisson") & (exposureTime!="")) {
				outcomeModelCommand = smcmd + " " + smout + " " + smcov + ", exposure(" + exposureTime + ")"
			}
			else {
				outcomeModelCommand = smcmd + " " + smout + " " + smcov
			}
			stata(outcomeModelCommand)
			postdraw()
			y = st_data(., smout)
			if (smcmd=="regress") {
				outcomeModResVar = st_numscalar("smcfcs_resvar")
			}
		}
	}
	
	imputationNeeded = select(transposeonly(1..n),J(n,1,1)-r)
	
	stata("predict smcoutmodxb, xb")
	
	/*st_view(xMis, ., st_local("var"))
	st_view(outmodxb, ., "smcoutmodxb")*/
	
	if (smcmd=="compet") {
		outmodxbMat = J(n,numFailures,0)
	}

	if ((covariateModelCmd=="mlogit") | (covariateModelCmd=="ologit") | (covariateModelCmd=="logistic")) {
		/*we can sample directly in this case*/
		if (covariateModelCmd=="logistic") {
			numberOutcomes = 2
			fittedMean = (1:-fittedMean,fittedMean)
		}
		
		outcomeDensCovDens = J(length(imputationNeeded),numberOutcomes,0)
		for (xMisVal=1; xMisVal<=numberOutcomes; xMisVal++) {
			st_view(xMis, ., st_local("var"))
			if (covariateModelCmd=="logistic") {
				xMis[imputationNeeded] = J(length(imputationNeeded),1,xMisVal-1)
			}
			else {
				/*ologit or mlogit*/
				multdraw = J(length(imputationNeeded),1,xMisVal)
				recodedDraw = multdraw
				for (i=1; i<=length(catvarlevels); i++) {
					indices = select(range(1,length(imputationNeeded),1),multdraw:==i)
					if (length(indices)>0) {
						recodedDraw[indices] = J(length(indices),1,catvarlevels[i])
					}
				}
				xMis[imputationNeeded] = recodedDraw
			}
			if (passive!="") {
				stata(`"quietly updatevars, passive(""'+passive+`"")"')
			}
			
			if (smcmd=="compet") {
				for (i=1; i<=numFailures; i++) {
					stata("matrix tempmat=b"+strofreal(i))
					stata("ereturn repost b=tempmat")
					st_dropvar("smcoutmodxb")
					stata("predict smcoutmodxb, xb")
					st_view(outmodxb, ., "smcoutmodxb")
					outmodxbMat[,i] = outmodxb[.,.]
				}
			
				outcomeDens = exp(-H0Mat[imputationNeeded,1] :* exp(outmodxbMat[imputationNeeded,1])) :* exp(outmodxbMat[imputationNeeded,1]):^(d[imputationNeeded]:==1)
				for (i=2; i<=numFailures; i++) {
					outcomeDens = outcomeDens:* (exp(-H0Mat[imputationNeeded,i] :* exp(outmodxbMat[imputationNeeded,i])) :* exp(outmodxbMat[imputationNeeded,i]):^(d[imputationNeeded]:==i))
				}
			}
			else {
				st_dropvar("smcoutmodxb")
				stata("predict smcoutmodxb, xb")
				st_view(outmodxb, ., "smcoutmodxb")
				
				if (smcmd=="regress") {
					deviation = y[imputationNeeded] - outmodxb[imputationNeeded]
					outcomeDens = normalden(deviation:/(outcomeModResVar^0.5))/(outcomeModResVar^0.5)
				}
				else if (smcmd=="logistic") {
					prob = invlogit(outmodxb[imputationNeeded])
					ysub = y[imputationNeeded]
					outcomeDens = prob :* ysub + (J(length(imputationNeeded),1,1) :- prob) :* (J(length(imputationNeeded),1,1) :- ysub)
				}
				else if (smcmd=="poisson") {
					outcomeDens = poissonp(exp(outmodxb[imputationNeeded]),y[imputationNeeded])
				}
				else if (smcmd=="stcox") {
					outcomeDens = exp(-H0[imputationNeeded] :* exp(outmodxb[imputationNeeded])) :* (exp(outmodxb[imputationNeeded]):^d[imputationNeeded])
				}
			}
			outcomeDensCovDens[,xMisVal] = outcomeDens :* fittedMean[imputationNeeded,xMisVal]
		}
		
		directImpProbs = outcomeDensCovDens :/ rowsum(outcomeDensCovDens)
		st_view(xMis, ., st_local("var"))
		if (covariateModelCmd=="logistic") {
		
			directImpProbs = directImpProbs[.,2]
			/*ensure that probabilities are within Stata's specified limits*/
			directImpProbs = rowmax((directImpProbs,J(rows(directImpProbs),1,1e-8)))
			directImpProbs = rowmin((directImpProbs,J(rows(directImpProbs),1,1-1e-8)))
			xMis[imputationNeeded] = rbinomial(1,1,1, directImpProbs)
		}
		else {
			/*ologit or mlogit*/
			//take a draw from a multinomial distribution, coded 1:numberOutcomes
			cumProbs = directImpProbs
			for (i=2; i<=numberOutcomes; i++) {
				cumProbs[.,i] = cumProbs[.,i-1] + cumProbs[.,i]
			}
			multdraw = J(length(imputationNeeded),1,numberOutcomes+1) - rowsum(runiform(length(imputationNeeded),1) :< cumProbs)
			//now recode
			recodedDraw = multdraw
			for (i=1; i<=length(catvarlevels); i++) {
				indices = select(range(1,length(imputationNeeded),1),multdraw:==i)
				if (length(indices)>0) {
					recodedDraw[indices] = J(length(indices),1,catvarlevels[i])
				}
			}
			xMis[imputationNeeded] = recodedDraw
		}
		/*call passive to update based on new draw*/
		if (passive!="") {
			stata(`"quietly updatevars, passive(""'+passive+`"")"')
		}
	}
	else {
		j=1
		
		while ((length(imputationNeeded)>0) & (j<rjLimit)) {
			st_view(xMis, ., st_local("var"))
			if (covariateModelCmd=="regress") {
				xMis[imputationNeeded] = rnormal(1,1,fittedMean[imputationNeeded],newsigmasq^0.5)
			}
			else if (covariateModelCmd=="logistic") {
				xMis[imputationNeeded] = rbinomial(1,1,1, fittedMean[imputationNeeded])
			}
			else if (covariateModelCmd=="poisson") {
				xMis[imputationNeeded] = rpoisson(1,1, fittedMean[imputationNeeded])
			}
			else if (covariateModelCmd=="nbreg") {
				//for negative binomial, first generate draw of gamma random effect
				poissonMeans = rgamma(1,1,J(length(imputationNeeded),1,1/alpha),alpha:*fittedMean[imputationNeeded])
				//if a draw from the Gamma distribution is lower than Stata's rpoisson(m) lower limit for m (1e-6), missing values are generated
				//therefore perform a check to ensure means are not below Stata's rpoisson lower threshold, and set any which are, to the threshold
				poissonMeans = rowmax((J(length(imputationNeeded),1,1e-6),poissonMeans))
				xMis[imputationNeeded] = rpoisson(1,1, poissonMeans)
			}
			else if ((covariateModelCmd=="mlogit") | (covariateModelCmd=="ologit")) {
				//take a draw from a multinomial distribution, coded 1:numberOutcomes
				multdraw = J(length(imputationNeeded),1,numberOutcomes+1) - rowsum(runiform(length(imputationNeeded),1) :< cumProbs[imputationNeeded,.])
				//now recode
				recodedDraw = multdraw
				for (i=1; i<=length(catvarlevels); i++) {
					indices = select(range(1,length(imputationNeeded),1),multdraw:==i)
					if (length(indices)>0) {
						recodedDraw[indices] = J(length(indices),1,catvarlevels[i])
					}
				}
				xMis[imputationNeeded] = recodedDraw
			}
		
			if (passive!="") {
				stata(`"quietly updatevars, passive(""'+passive+`"")"')
			}
			
			uDraw = runiform(length(imputationNeeded),1)
			
			st_dropvar("smcoutmodxb")
			stata("predict smcoutmodxb, xb")
			st_view(outmodxb, ., "smcoutmodxb")
			
			if (smcmd=="regress") {
				deviation = y[imputationNeeded] - outmodxb[imputationNeeded]
				reject = log(uDraw) :> -(deviation:*deviation) :/ (2*J(length(imputationNeeded),1,outcomeModResVar))
			}
			else if (smcmd=="logistic") {
				prob = invlogit(outmodxb[imputationNeeded])
				ysub = y[imputationNeeded]
				prob = prob :* ysub + (J(length(imputationNeeded),1,1) :- prob) :* (J(length(imputationNeeded),1,1) :- ysub)
				reject = uDraw :> prob
			}
			else if (smcmd=="poisson") {
				prob = poissonp(exp(outmodxb[imputationNeeded]),y[imputationNeeded])
				reject = uDraw :> prob
			}
			else if (smcmd=="stcox") {
				s_t = exp(-H0[imputationNeeded] :* exp(outmodxb[imputationNeeded]))
				prob = exp(J(length(imputationNeeded),1,1) + outmodxb[imputationNeeded] - (H0[imputationNeeded] :* exp(outmodxb[imputationNeeded])) ) :* H0[imputationNeeded]
				prob = d[imputationNeeded]:*prob + (J(length(imputationNeeded),1,1)-d[imputationNeeded]):*s_t
				reject = uDraw :> prob
			}
			else if (smcmd=="compet") {
				for (i=1; i<=numFailures; i++) {
					stata("matrix tempmat=b"+strofreal(i))
					stata("ereturn repost b=tempmat")
					st_dropvar("smcoutmodxb")
					stata("predict smcoutmodxb, xb")
					st_view(outmodxb, ., "smcoutmodxb")
					outmodxbMat[,i] = outmodxb[.,.]
				}
				s_t = exp(-H0Mat[imputationNeeded,1] :* exp(outmodxbMat[imputationNeeded,1]))
				for (i=2; i<=numFailures; i++) {
					s_t = s_t :* exp(-H0Mat[imputationNeeded,i] :* exp(outmodxbMat[imputationNeeded,i]))
				}
				firstTerm = J(length(imputationNeeded),1,1)
				for (i=1; i<=numFailures; i++) {
					firstTerm = firstTerm :* (H0Mat[imputationNeeded,i]:*exp(1:+outmodxbMat[imputationNeeded,i])):^(d[imputationNeeded]:==i)
				}
				prob = firstTerm :* s_t
				reject = uDraw :> prob
			}
			imputationNeeded = select(imputationNeeded, reject)
			j = j + 1
			//length(imputationNeeded)
		}

		if (j>=rjLimit) {
			messagestring = `"noisily display as error "Warning" as text ": valid imputed values may not have been generated for imputationNeeded subject(s). You should probably increase the rejection sampling limit.""'
			stata(subinstr(messagestring, "imputationNeeded", strofreal(length(imputationNeeded))))
		}
	}
	
	st_dropvar("smcoutmodxb")
	
}


end

exit

History of smcfcs

08/02/2019  Fixed bug related to st_view in Mata that caused invalid results under Stata 15
16/05/2018  Added functionality for Poisson substantive models, with optional exposure time
28/05/2015  Added functionality for competing risks substantive models, with Cox model for each competing risk
20/05/2015  Changed savetrace behaviour so that it saved estimates of substantive model parameters, rather than
			means and SDs of imputed variables.
30/04/2015  Added code so that Cox model with delayed entry/left truncation is accommodated.
05/02/2015  Allowed use of data that are already -mi set-. Added a clear option so that if imputations already exist, smcfcs can clear them instead of exiting with an error.
07/01/2015  Changed use of Mata function selectindex so that Stata version 11 and 12 users can still use the command.
			Added check to ensure that dataset is not mi set when smcfcs is called.
05/12/2014  Fixed bug where i. dummies in substantive model for variables being imputed were not being updated in covImp since they're not defined by the user in a passive statement
			To resolve this, smcfcs now calls all regression commands without xi:, such that calls to predict properly update any internal dummy variables.
			Fixed bug in the direct sampling code added 31/10/2014 (needed to update passive variables after direct sampling)
			Fixed bug in direct sampling with linear outcome models caused by unexpected behaviour of normalden() function (which was due to previously having version 11.0 at top)
31/10/2014  Rejection sampling replaced by (faster) direct sampling for logistic, ologit and mlogit covariates
08/09/2014	Added by option to enable imputation separately by groups
			Modified syntax of command
			When imputation is completed, passive variables are registered as passive and imputed as imputed (previously all substantive model covariates were registered as imputed)
01/07/2014  Fixed bug in imputation of missing continuous outcomes
08/06/2014  Added ability to impute missing outcomes (regress and logistic models only)
15/07/2013  Mlogit and ologit imputation functionality added for unordered and ordered categorical variables
			Handling of i. factor variables added
21/06/2013	Chainonly and savetrace options added to allow for convergence checking
20/06/2013  Poisson and negative binomial imputation for count variables added
			rseed optiona added
01/06/2013  The requirement to write a program called updateDerivedVariables was replaced with the passive() option
            Various option names changed and shortened
            Mata rejection sampling code tuned to make it much shorter and neater
29/04/2013  Multiple chains are now used, rather than a single chain, to match ice and mi impute chained
29/10/2012  First version of smcfcs Released
20/12/2012  Changed name of command from congenialFCS to smcfcs
