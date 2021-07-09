/******************************************************************************
*! version 3.2.0 # Ian White # 6apr2018
	links corrected to UCL website
	RELEASED TO UCL AND SSC
version 3.1.4  Ian White  11feb2016
    improvments in i2 option:
        clearer note where terms are dropped in computing CI
        first column is widened if necessary to fit varnames
version 3.1.3  Ian White  22jul2015
    observation number causing error is stored in $MVMETA_obserror (for Stephen K)
    check that matrix argument in bscov() is symmetric
    removed mvmeta_forest
version 3.1.2  Ian White  20jul2015
    bug fix: 
        Estimate calls mm1 not mm2 (hence i2 now works again)
        mvmeta_estimate labels e(ydata) using value labels, if id is numeric and labelled
    i2 with mm2 estimation reported mm1 results (hence discrepant tau^2 values)
        - now uses mm2 results
        - new ad hoc method for CI (see help file)
    identifying errors:
        mvmeta_mufromsigma reports errors using correct observation number or ID
        mvmeta_estimate quits after finding first error 
    improved use of exit codes:
        198: syntax error
        459: something that should be true of your data is not
        497: my programming error
        498: other statistical errors
version 3.1.1  Ian White  13jul2015
    bug fixes: 
        mvmeta_wt failed with missing data & wscorr(riley) - augmentation procedure fixed
        deleted last call to mvmeta_wt from Estimate
    new tutorial on getting the data in, minor changes to main tutorial
version 3.1  Ian White  1jul2015
    bug fixes:
        e(wscorr) wasn't returned hence Riley output wasn't printed differently
        randfix failed when e(V_fixed) not returned - now just ignored
        pbest now reports in data order (previously sorted string id)
        forest() now works when study names include spaces
    riley model now switches off: testsigma qscalar i2 randfix
    matrix mm (=mm2) is now default; mm1 calls componentwise mm
    NB bubble and forest are undocumented - for a future SJ paper
version 3.0.4  Ian White  16jun2015
    new fe suboption for suppress()
    fixed mvmeta_mufromsigma to respect riley method
        - was previously giving wrong answers for likelihood and fixed parameters
        - wscorr(riley) fixed now fails; previously it behaved like wscorr(0) fixed
version 3.0.3  Ian White  12jun2015
    bug fix: iterate() wasn't working
version 3.0.2  Ian White  9jun2015
    on external website
    problems when univariate or unstructured MM failed
        now captures problems sensibly
        better (shorter) warnings given
    no left-over matrices
version 3.0.1  Ian White  8jun2015
    on external website
25may2015
    fixed bug in pbest, saving()
14may2015
    bug fix in mvmeta_mufromsigma: bscov(equals) now returns correct [r]loglik 
    new meanrank suboption in pbest (and mcse corrected?)
v3.0.1 11may2015
    updated mvmeta.pkg
    bug fixes: 
        e(Q), e(Qa), e(Qb) always returned from mm method
        i2 option: now works for mm2 (same as mm)
        testsigma now works again (e(ll0) restored)
        ml options including iter now work
    options dropped: keepmat() corr()
    problems arising from uv estimation:
        new options: suppress([uv] [mm]) uviterate(default 20)
        commonparm => suppress(uv)
        REML fails with #obs = #parms, so (a) checks and issues warning, (b) captures uv failure
    mvmeta_bos renamed mvmeta_wt
    mvmeta_{estimate bubble wt forest} and bubble brought into this prog
    this version seems correct & stable
v3.0.0 25apr2015
programming changes:
    ynames no longer passed as a global - use ylist
    new e() matrices: ydata, Sdata, Xdata, b_fixed, V_fixed, b_uv, V_uv, wt
    24apr2015: ydata row names are <study> not <study>:estimate
    bos, bubble, randfix, forest - all updated
functionality changes:
    no id() option on Replay, only on pbest - NB pbest is prediction type (can be out of sample)

BUGS
    -mvmeta, i2- fails when estimated variance is 0 after -cov(propto M)- [e.g. H:\meta\incoherence\thrombolytics\mvmeta4.do]

TO DO
e(ll) etc. is inconsistent:
    reml & ml return e(ll) = maximum [restricted] loglik and e(ll0) = same for fixed-effect model
    mm returns nothing
    fixed returns e(ll0) = maximum loglik and e(rl0) = maximum restricted loglik
Forest - still needs a lot more work   
    weights on by default
    (Dan) default should either add univariate weights or suppress uv summary
    (Dan) how is prediction interval calculated?
    favours() - needs to be subgraph specific (for Berkey)
    nouv seems to leave a gap
    don't display those flagged as augmented
Bubble 
    Could plot against an EB estimate of the missing data???

PROGRAMMING NOTES
    This program uses method d0, not lf, because the REML log-likelihood does not have the required form as a sum of individual contributions.
    So I have to handle covariates through the program.
    -- could use lf for ML only

    The estimate and variance matrices must be numbered 1..`n'

    obs loops over 1/`N' (all obs);
    i loops over 1/`n' (obs in use);
    r, s loop over 1/`p' (outcome variables).
    
Programs are defined in this order:
    mvmeta
        Estimate
        Replay
        pbest
            drawbeta
        mvmeta_wt
        mvmeta_bubble
        bubble
        [mvmeta_forest]
        mvmeta_estimate 
            varcheck
        mvmeta_getdata
        mata selectpart()

WARNINGS
    mm method doesn't cope with augmented data sets (i.e. with large variances)

CERTIFICATION SCRIPTS
    H:\meta\mv\ado\mvmeta\mvmeta_cscript.do
    H:\meta\mv\regpaper\cscript.do - analyses as in SJ paper

OPTIONS REMOVED
    report

FUTURE PLANS
    lincom option?
    Kenward-Roger df for tests and \cint s?
    Compute empirical Bayes estimates?
    i2(white|cochran|jackson)??

******************************************************************************/

*=============================== MASTER PROGRAM ===============================

program define mvmeta
version 9 // originally written under Stata 9, but updates are only tested under Stata 12+
if replay() {
    if "`e(cmd)'" != "mvmeta" error 301
    Replay `0'
}
else Estimate `0'
end

*============================== ESTIMATE PROGRAM ==============================

program define Estimate, eclass

syntax [anything] [if] [in], ///
    [reml ml Fixed MM2 mm1 notrunc Vars(varlist) start(passthru) WSCORr(string) LONGParm EQuations(string) noCONStant BSCOVariance(string) COMMONparm /// Model options
    SUPPress(string) /// additional analysis options
    augment augquiet missest(real 0) missvar(real 1E4) /// Augmentation options - NOW UNDOCUMENTED
    maxse(real 5) psdcrit(passthru) noposdef mata no2pi TAULog /// Tuning options
    SHOWStart id(varname) /// Output options
    SHOWChol SHOWAll eform EFORM2(passthru) noUNCertainv print(passthru) dof(passthru) i2 i2fmt(passthru) ciscale(passthru) NCchi2 TESTsigma pbest(passthru) RANDFix RANDFix2(passthru) Qscalar cformat(passthru) pformat(passthru) sformat(passthru) WT WT2(passthru) BUbble BUbble2(passthru) /// Replay options
    Level(passthru) cholnames nolog quick debug noESTimates noJOINTCHeck noreplay mmfix constraints(passthru) COLLinear network(string) wscorrforce noWARNings UVITERate(int 20) ITERate(string) FORest FORest2(passthru) /// Undocumented options
    * /// ml options
    ]
* NB current 69 options is the limit!
global MVMETA_obserror  // new 21jul2015

****************** PARSE *****************
mlopts mlopts, `options'
* OUTCOMES AND VARIANCES
tokenize "`anything'"
local ystub `1'
local Sstub `2'
if "`Sstub'"=="" {
    di as error "Syntax: mvmeta estimate-stub variance-stub ..."
    exit 198
}

* COVARIATES (AND CONSTANT)
mac shift 2
if "`collinear'"=="" {
    _rmcoll `*', nocons
    local xvars `r(varlist)'
}
else local xvars `*'
local isregression = "`xvars'"!=""

* EQUATIONS
tokenize "`equations'", parse(",")
local neqs 0
while "`1'"!="" {
    gettoken eqy rest : 1, parse(":")
    gettoken colon eqx : rest, parse(":")
    if "`eqx'"!="" local isregression 1
    foreach thisy of varlist `eqy' {
        local ++neqs
        local eqy`neqs' `thisy'
        if "`eqx'"!="" unab eqx`neqs' : `eqx'
    }
    mac shift 2
}

* ESTIMATION METHOD
if wordcount("`reml' `ml' `fixed' `mm1' `mm2'") > 1 {
     di as error "Please specify only one of reml, ml, fixed, mm1, mm2"
     exit 198
}
local bsest `reml'`ml'`fixed'`mm1'`mm2'
if "`bsest'"== "" local bsest reml

* CHECK CORRELATIONS
if "`wscorr'"=="riley" {
    if inlist("`bsest'","mm1","mm2") {
        di as error "Sorry, we don't yet have a method of moments for Riley's overall correlation model."
        exit 498
    }
    local suppress `suppress' fe mm 
}
else if "`wscorr'"!="" {
    cap assert abs(`wscorr')<=1
    if _rc {
        di as error "Correlation (`wscorr') outside range [-1,1]."
        exit 459
    }
}
else if !mi("`wscorrforce'") {
    if mi("`warnings'") di as error "wscorrforce ignored - wscorr(#) not specified"
    local wscorrforce
}

* SHORT, LONG OR COMMON PARAMETERISATION
if "`commonparm'"=="commonparm" local parmtype common
else if "`longparm'"=="longparm" | "`xvars'"!="" | "`equations'"!="" | "`pbest'"!="" local parmtype long
else local parmtype short
if "`parmtype'"=="common" {
    local collinear collinear
    local suppress `suppress' uv
}

* notrunc not allowed without method mm -> move
if "`trunc'"=="notrunc" & !inlist("`bsest'","mm1","mm2","fixed") {
    if mi("`warnings'") di as error "notrunc option ignored with method `bsest'"
    local trunc
}

if "`debug'"=="" local ifdebug *
local ifdebugnoi = cond("`debug'"=="","qui","noi")
 
di as text "Note: using method " as result "`bsest'"

if !mi("`id'") local idopt id(`id')

foreach word of local suppress {
    if "`word'"=="uv" local suppressuv suppressuv
    if "`word'"=="mm" local suppressmm suppressmm
    if "`word'"=="fe" local suppressfe suppressfe
}

****************** IDENTIFY Y AND S VARIABLES TO USE, AND p *****************

if "`vars'"~="" local ylist0 `vars' /* change by SK to accomodate long variable list */
else local ylist0 `ystub'*
local p 0
cap desc `ylist0'
if _rc {
    di as error "No variables found starting with `ystub'"
    exit 459
}
foreach yvar of varlist `ylist0' {
    if index("`yvar'","`ystub'")!=1 {
        di as error "Variable `yvar' in vars() does not start with `ystub'"
        exit 198
    }
    local yend = substr("`yvar'",1+length("`ystub'"),.)
    if "`yend'"=="" {
        if mi("`warnings'") di as error "Warning: variable `yvar' not used (looking for variable names `ystub'+suffix)"
        continue
    }
    summ `yvar' `if' `in', meanonly
    if r(N)==0 {
        if mi("`warnings'") di as error "Warning: variable `yvar' not used (no non-missing values)"
        continue
    }
    * Found a valid yvar
    local ++p
    local yend_`p' `yend'
    local yvar_`p' `ystub'`yend'
    local yends `yends' `yend'
    local ylist `ylist' `ystub'`yend'
    cap confirm var `Sstub'`yend'`yend'
    if _rc {
        di as error "Variance `Sstub'`yend'`yend' not found for estimate `ystub'`yend'"
        exit 459
    }
*    code not needed because zero variances are checked for later (and returned with id)
*    cap assert `Sstub'`yend'`yend'>0
*    if _rc {
*        di as error "Variance `Sstub'`yend'`yend' must be >0"
*        exit 459
*    }
    * Now see if we have any covariates for it
    local xvars_`p' `xvars'
    forvalues eq=1/`neqs' {
        if "`yvar_`p''"=="`eqy`eq''" local xvars_`p' `xvars_`p'' `eqx`eq''
    }
    if `isregression' {
        di as text "Note: regressing " as result "`yvar_`p''" as text " on " _c
        if !mi("`xvars_`p''") di as result "`xvars_`p''"
        else di as result "(nothing)"
    }
    if "`collinear'"=="" & !mi("`xvars_`p''") {
        qui count if !mi(`yvar_`p'')
        if r(N)<=1 { // bug in _rmcoll - it fails with only 1 obs
            if mi("`constant'") local newxvars
            else local newxvars : word 1 of "`xvars_`p'"
        }
        else {
            _rmcoll `xvars_`p'' if !mi(`yvar_`p''), `constant'
            local newxvars = r(varlist)
            if "`newxvars'" == "." local newxvars
        }
        if "`xvars_`p''" != "`newxvars'" {
            if mi("`warnings'") {
                di as error _col(7) "Collinearity detected: now regressing `yvar_`p'' on " _c
                if !mi("`newxvars'") di "`newxvars'"
                else di "(nothing)"
            }
            local xvars_`p' `newxvars'
        }
    }
    if "`xvars_`p''"=="" & "`constant'"=="noconstant" {
        di as error "No covariates and no constant for outcome `p'"
        exit 498
    }
    * find yvar label
    local yvarlab : var label `yvar_`p''
    if mi("`yvarlab'") local yvarlab `yvar_`p''
    if mi(`"`ylabels'"') local ylabels `"`"`yvarlab'"'"'
    else local ylabels `"`ylabels' `"`yvarlab'"'"'
}

if `p'==0 {
    di as error "No variables found starting with `ystub'"
    exit 111
}

if !`isregression' {
    if `p'>1 local plural s
    di as text "Note: using variable`plural' " as result "`ylist'"
}

**************** SORT OUT COVARIANCE STRUCTURES  *******************
* (moved from end of parsing because it needs `p')

if "`bsest'"=="`fixed'" {
	if !mi("`bscovariance'") {
		di as error "fixed option used: bscovariance() ignored"
		local bscovariance
	}
	local jointcheck none
}
else {
	tempname sigma0
	if "`bscovariance'"=="" local bscovariance unstructured
	local sigma0exp = word("`bscovariance'",2)
	if substr("`bscovariance'",1,3)=="uns" {
        local bscovariance unstructured
    }
	else if substr("`bscovariance'",1,4)=="prop" {
		if "`sigma0exp'"=="" {
			di as error "Syntax: bscovariance(proportional matrix)"
			exit 198
		}
		mat `sigma0' = `sigma0exp'
		local bscovariance proportional
	}
	else if substr("`bscovariance'",1,2)=="eq" {
		if "`sigma0exp'"=="" {
			di as error "Syntax: bscovariance(equals matrix)"
			exit 198
		}
		mat `sigma0' = `sigma0exp'
		local bscovariance equals
	}
	else if substr("`bscovariance'",1,4)=="corr" {
		if "`sigma0exp'"=="" {
			di as error "Syntax: bscovariance(correlation matrix)"
			exit 198
		}
		mat `sigma0' = `sigma0exp'
		local bscovariance correlation
	}
	else if substr("`bscovariance'",1,4)=="exch" {
        local rho = word("`bscovariance'",2)
        cap confirm number `rho'
        if _rc {
            di as error "Syntax: bscovariance(exch #)"
            exit 198
        }
        if `rho'<-1 | `rho'>1 {
            di as error "Syntax: bscovariance(exch #) with -1<=#<=1"
            exit 198
        }
        local bscovariance proportional
        mat `sigma0' = (1-`rho')*I(`p')+`rho'*J(`p',`p',1)
        local sigma0exp `=1-`rho''*I(`p')+`=`rho''*J(`p',`p',1)
	}
	else {
		di as error "bscovariance(`bscovariance') not available"
		exit 198
	}
	if "`bscovariance'" != "unstructured" local jointcheck none
}

* check sigma0 matrices
if !mi("`sigma0exp'") {
	if rowsof(`sigma0')!=`p' | colsof(`sigma0')!=`p' {
		di as error "bscovariance() option: `sigma0exp' is not `p'x`p'"
		exit 198
	}
    if !issymmetric(`sigma0') {
        di as error "bscovariance() option: `sigma0exp' is not symmetrical"
		exit 198
	}
}

****************** ESTIMATION SAMPLE *****************

marksample touse
* 9dec2014 - only mark out if x=. and y!=.
tempvar hasyvalues hasxnoy
gen `hasyvalues'=0 // indicates any non-missing y-value
gen `hasxnoy' = 0 // indicates any missing x-value with non-missing y-value
forvalues r=1/`p' {
    foreach xvar in `xvars_`r'' {
		qui replace `hasxnoy' = 1 if mi(`xvar') & !mi(`yvar_`r'')
	}
    qui replace `hasyvalues' = 1 if !mi(`yvar_`r'')
}
qui count if `hasyvalues'==0 & `touse'
if r(N) {
    local observations = cond(r(N)>1,"observations","observation")
    local have = cond(r(N)>1,"have","has")
    if mi("`warnings'") di as error "Warning: " r(N) " `observations' `have' all outcomes missing, and `have' been dropped from analysis"
    qui replace `touse' = 0 if `hasyvalues'==0
}
qui count if `hasxnoy'==1 & `touse'
if r(N) {
    local observations = cond(r(N)>1,"observations","observation")
    local have = cond(r(N)>1,"have","has")
    if mi("`warnings'") di as error "Warning: " r(N) " `observations' `have' observed outcome and missing covariate, and `have' been dropped from analysis"
    qui replace `touse' = 0 if `hasxnoy'==1
}

qui count if `touse'
local n = r(N)
local N = _N
di as text "Note: " as result `n' as text " observations on " as result `p' as text " variables"

****************** CHECK VARIANCES *****************

if "`bscovariance'"=="unstructured" {
    forvalues r=1/`p' {
        forvalues s = `=`r'+1' / `p' {
            qui count if !missing(`yvar_`r'') & !missing(`yvar_`s'') & `touse'
            if r(N)<=1 {
                if r(N)==0 local problem have no jointly observed values
                if r(N)==1 local problem have only 1 jointly observed value
                if "`jointcheck'"=="" {
                    di as error "`yvar_`r'' and `yvar_`s'' `problem' - consider alternatives to bscov(unstructured)"
                    exit 459
                }
                else if mi("`warnings'") di as text "Warning: `yvar_`r'' and `yvar_`s'' `problem' - consider alternatives to bscov(unstructured)"
            }
        }
    }
}

**************** RUN SECONDARY ESTIMATIONS ***************

ereturn clear // Needed to drop any old e-results (since we don't always do -ereturn post-)
local optsforall `constant' `warnings' parmtype(`parmtype') `augment' missest(`missest') missvar(`missvar') `augquiet' `taulog' `debug' `trunc' `mmfix' `idopt' `mlopts'
forvalues r=1/`p' {
    if `r'>1 local xvarslist `xvarslist',
    if mi("`xvars_`r''") local xvarslist `xvarslist' . // missing is awkward
    else local xvarslist `xvarslist' `xvars_`r''
    local nxvars_`r' = wordcount(`"`xvars_`r''"') + ("`constant'"!="noconstant")
}

if "`estimates'"!="noestimates" {

    ******** RUN FIXED-EFFECT ESTIMATION *******
    if "`suppressfe'"!="suppressfe" {
        `ifdebug' di as input _new "Running fixed-effect estimation"
        `ifdebugnoi' mvmeta_estimate `ystub' `Sstub' if `touse', yends(`yends') xvarslist(`xvarslist') wscorr(`wscorr') `wscorrforce' bsest(fixed) `optsforall' 
        if r(success) {
            tempname b_fixed V_fixed
            mat `b_fixed' = r(b)
            mat `V_fixed' = r(V)
            local Qscalar_chi2 = r(Qscalar) 
            local Qscalar_df = r(Qscalardf)
            `ifdebug' di as input "Results of fixed-effect estimation:" _c
            `ifdebug' mat l `b_fixed', title(b_fixed)
            `ifdebug' mat l `V_fixed', title(V_fixed)
            if "`bsest'"=="reml" local ll0 = r(rl0)   // [re]ll for FE model - needed for testsigma option
            else if "`bsest'"=="ml" local ll0 = r(ll0)
        }
        else if mi("`warnings'") di as error "Fixed-effect estimation failed"
    }
    else `ifdebug' di as input _new "Estimation of fixed-effect model suppressed"

    ******** RUN UNIVARIATE ESTIMATIONS *******
    if "`suppressuv'"!="suppressuv" {
        tempname b_uv V_uv thisb thisV zeroV
        forvalues r=1/`p' {
            `ifdebug' di as input _new "Running univariate estimation for outcome `yvar_`r''"
            qui count if `touse' & !mi(`yvar_`r'')
            if r(N)==`nxvars_`r'' & "`bsest'"=="reml" & !mi("`debug'") di as error "Warning: univariate REML estimation may fail for outcome `yvar_`r'', since #obs= #parms"
            if "`bscovariance'"=="equals" {
                local sigma0uv = `sigma0'[`r',`r']
                local bscovopt bscovariance(equals) sigma0(`sigma0uv')
            }
            else local bscovopt bscovariance(unstructured)
            
            `ifdebugnoi' mvmeta_estimate `ystub' `Sstub' if `touse' & !mi(`yvar_`r''), yends(`yend_`r'') xvarslist(`xvars_`r'') bsest(`bsest') `bscovopt' `cholnames' `showstart' `optsforall' iterate(`uviterate')
            
            if r(success) {
                mat `thisb' = r(b)
                mat `thisb' = `thisb'[1,1..`nxvars_`r'']
                mat `thisV' = r(V)
                mat `thisV' = `thisV'[1..`nxvars_`r'',1..`nxvars_`r'']
            }
            else {
                local failedvars `failedvars' `yvar_`r''
                mat `thisb' = J(1,`nxvars_`r'',.)
                mat `thisV' = J(`nxvars_`r'',`nxvars_`r'',.)
                * name rows and cols
                local colnames 
                foreach thing in `xvars_`r'' {
                    local colnames `"`colnames' "`thing'""'
                }
                if mi("`constant'") local colnames `"`colnames' "_cons""'
                mat colnames `thisb' = `colnames'
                mat colnames `thisV' = `colnames'
                mat rownames `thisV' = `colnames'
                mat coleq `thisb' = "`yvar_`r''"
                mat coleq `thisV' = "`yvar_`r''"
                mat roweq `thisV' = "`yvar_`r''"
            }
            mat `b_uv' = nullmat(`b_uv'),`thisb'
            if `r'==1 mat `V_uv' = `thisV'
            else {
                mat `zeroV' = J(rowsof(`V_uv'),colsof(`thisV'),0)
                mat rownames `zeroV' = `: rowfullnames `V_uv''
                mat colnames `zeroV' = `: colfullnames `thisV''
                mat `V_uv' = (`V_uv', `zeroV' \ `zeroV'', `thisV')
            }
        }
        if !mi("`failedvars'") di as text "Warning: univariate estimation failed for outcomes " as result "`failedvars'"
        `ifdebug' di as input "Results of univariate estimations:" _c
        `ifdebug' mat l `b_uv', title(b_uv)
        `ifdebug' mat l `V_uv', title(V_uv)
    }
    else `ifdebug' di as input _new "Estimation of univariate models suppressed"

    ******** RUN UNSTRUCTURED-SIGMA MM FOR ALL METHODS, BECAUSE I^2 NEEDS IT *******
    if "`suppressmm'"!="suppressmm" {
        `ifdebug' di as input _new "Running unstructured-sigma mm"
        `ifdebugnoi' mvmeta_estimate `ystub' `Sstub' if `touse', yends(`yends') xvarslist(`xvarslist') wscorr(`wscorr') `wscorrforce' bsest(mm1) bscovariance(unstructured) `start' `cholnames' `showstart' `optsforall'
        if r(success) {
            tempname Q Qa Qb
            mat `Q' = r(Q)
            mat `Qa' = r(Qa)
            mat `Qb' = r(Qb)
            if inlist("`bsest'","ml","reml") & "`bscovariance'"=="unstructured" & mi("`start'") {
                tempname mmSigma
                mat `mmSigma' = r(Sigma)
                local start start(`mmSigma')
            }
        }
        else {
            if inlist("`bsest'","reml","ml") {
                di as text "Warning: unstructured-variance method of moments failed - I2 statistic is not available"
            }
            if "`bscovariance'"=="unstructured" & inlist("`bsest'","mm2") {
                di as error "Error: method of moments failed"
                exit 459
            }
        }
    }
    else `ifdebug' di as input _new "Estimation of unstructured-sigma method of moments suppressed"
}
else {
    di as text "Note: " as result "noestimates" as text " option - model not fitted"
    local bsest
}


**************** RUN MAIN ESTIMATION ***************

// - must be last, as mvmeta_estimate implies -ereturn clear-
// - this is run even with noestimates option, since it also writes data matrices
`ifdebug' di as input _new "Running main estimation"
mvmeta_estimate `ystub' `Sstub' if `touse', yends(`yends') xvarslist(`xvarslist') wscorr(`wscorr') `wscorrforce' bsest(`bsest') bscovariance(`bscovariance') sigma0(`sigma0') `start' `cholnames' `showstart' `optsforall' `estimates' sigma0exp(`sigma0exp') iterate(`iterate')

// ereturn the main answers
`ifdebug' di as input "Ereturning the main answers"
foreach scalar in `r(scalarlist)' {
    ereturn scalar `scalar' = r(`scalar')
}
tempname temp 
foreach matrix in `r(matrixlist)' {
    if inlist("`matrix'","b","V") continue // b and V have already been ereturned by ml
    mat `temp' = r(`matrix')
    ereturn matrix `matrix' = `temp'
}
foreach local in `r(locallist)' {
    ereturn local `local' = r(`local')
}

************ ERETURN DESCRIPTIONS AND TIDY UP ***************

foreach thing in parmtype bsest constant cholnames wscorr wscorrforce network id ystub Sstub ylabels {
    ereturn local `thing' `"``thing''"'
}
forvalues r=1/`p' {
    ereturn local xvars_`r' `xvars_`r''
}
ereturn local yvars "`ylist'"
if "`bsest'"=="fixed" ereturn local bscovariance "(none)"
else if "`sigma0exp'"=="" ereturn local bscovariance "`bscovariance'"
else ereturn local bscovariance "`bscovariance' `sigma0exp'"
ereturn local cmdline mvmeta `0'

foreach thing in ll0 Qscalar_chi2 Qscalar_df {
    if !mi("``thing''") ereturn scalar `thing' = ``thing''
}
ereturn scalar dims = `p'
if "`estimates'"=="noestimates" { // some things have been missed
    ereturn scalar N = `N'
}

foreach thing in Q Qa Qb b_fixed V_fixed b_uv V_uv _wt {
    if !mi("``thing''") ereturn matrix `thing' = ``thing''
}

// tidy up

ereturn local cmd "mvmeta"

if "`replay'"!="noreplay" & "`estimates'"!="noestimates" Replay, `showall' `eform' `eform2' `uncertainv' `print' `level' `dof' `i2' `i2fmt' `ciscale' `ncchi2' `estimates' `testsigma' `pbest' `randfix' `randfix2' `qscalar' `debug' `cformat' `pformat' `sformat' `forest' `forest2' `bubble' `bubble2' `wt' `wt2'

end

*========================== END OF ESTIMATE PROGRAM ===========================



*========================== START OF REPLAY PROGRAM ===========================

program define Replay
// PARSE
syntax, [SHOWChol SHOWAll eform EFORM2(string) noUNCertainv print(string) Level(cilevel) dof(string) i2 i2fmt(string) ciscale(string) NCchi2 noESTimates TESTsigma pbest(string) RANDFix RANDFix2(varlist) Qscalar debug cformat(passthru) pformat(passthru) sformat(passthru) WT WT2(string) FORest FORest2(string asis) BUbble BUbble2(string asis)]
if !mi("`debug'") di "Starting Replay program"

foreach bit in `print' {
    if "`bit'"=="bscov" local printbscov on
    else if "`bit'"=="bscorr" local printbscorr on
    else di as error "option `bit' ignored in print(`print')"
}
if !mi("`eform2'") local eform eform(`eform2')
else if !mi("`eform'") {
    if "`showall'"=="" local eform eform(exp(Coef))
    else local eform eform([exp](Coef))
} // eform2 can now be ignored
if index("`dof'","n") {
    local dof = subinstr("`dof'","n","e(N)",.)
    local dof = `dof'
}
if "`dof'"!="" local dofopt dof(`dof')

local p = e(dims)
local bsest = "`e(bsest)'"
local bscov = word("`e(bscovariance)'",1)
local neqs_mean = e(neqs_mean)
local neq neq(`neqs_mean') /*2013-03-06*/
if "`uncertainv'" == "nouncertainv" & inlist("`bsest'","fixed","mm1","mm2") {
    di as text "(option nouncertainv ignored with estimation method `bsest')"
    local uncertainv
}
if "`showall'"=="showall" {
    if "`uncertainv'" == "nouncertainv" {
        di as text "(option showall ignored with option nouncertainv)"
        local showall
    }
    else if e(neqs_aux)==0 {
        di as text "(option showall ignored - no auxiliary parameters)"
        local showall
    }
    else {
        local neqs_tot = e(neqs_mean) + e(neqs_aux)
        local neq neq(`neqs_tot')
    }
}
if "`e(parmtype)'"=="long" & "`eform'"!="" & "`showall'"=="showall" {
    di as text "(option eform ignored with option showall and parmtype long)"
    local eform
}
forvalues r=1/`p' {
    local yvar_`r' : word `r' of `e(yvars)'
}

local levelopt level(`level')
tempname b V V2 hold

if "`ciscale'"=="" local ciscale sd
local ciscale = lower("`ciscale'")
if "`ciscale'"=="sd" local ciscalename SD
else if "`ciscale'"=="logsd" local ciscalename log(SD)
else if "`ciscale'"=="logh" local ciscalename log(H)
if "`i2fmt'"=="" local i2fmt %6.0f

if "`debug'"=="" local ifdebug *

if "`showchol'"=="showchol" {
    di as text "Warning: showchol option has been renamed showall"
    local showall showall
}

if mi(e(bsest)) { // if nothing to display, don't display anything
    local estimates noestimates
    local wt
}
if "`e(wscorr)'"=="riley" {
    foreach opt in i2 qscalar testsigma randfix {
        if !mi("``opt''") di as error "Option `opt' is not available with wscorr(riley)"
        local `opt'
    }
}

// END OF PARSING

// PRINT TABLE OF RESULTS
if "`estimates'"!="noestimates" {
    // PRINT OUTPUT HEADER
    di as text _newline "Multivariate meta-analysis"
    di as text "Variance-covariance matrix = " as result e(bscovariance)
    di as text "Method = " as result "`bsest'" _c
    di _col(48) as text "Number of dimensions " _col(72) "=" as result %6.0f e(dims)
    if ("`bsest'"=="ml" ) di as text "Log likelihood = " as result e(ll) _c
    if ("`bsest'"=="reml" ) di as text "Restricted log likelihood = " as result e(ll) _c
    di _col(48) as text "Number of observations " _col(72) "=" %6.0f as result e(N)
    if "`dof'"!="" di _col(48) as text "Degrees of freedom " _col(72) "=" _col(72) %6.0f as result `dof'

    // PRINT ESTIMATES
    mat `b' = e(b)
    mat `V' = e(V)
    if ("`bsest'"=="ml" | "`bsest'"=="reml") & "`uncertainv'" == "nouncertainv" {
        mat `b' = `b'[1,1..`e(nparms_mean)']
        mat `V2' = invsym(`V')
        mat `V2' = `V2'[1..`e(nparms_mean)',1..`e(nparms_mean)']
        mat `V2' = invsym(`V2')
        _estimates hold `hold'
        ereturn post `b' `V2', `dofopt'
        *ereturn scalar k_eform = `neqs_mean'
        ereturn display, `eform' `levelopt' `cformat' `pformat' `sformat' // _coef_table fails here, not sure why
        di as text "Note: these standard errors ignore uncertainty in Sigma."
        _estimates unhold `hold' /* brings back the main results */
    }
    else {
        _estimates hold `hold', copy
        ereturn post `b' `V', `dofopt'
        *ereturn scalar k_eform = `neqs_mean'
        if "`eform'"!="" & "`showall'"=="showall" {
            // here, _coef_table is better than ereturn display because it only exponentiates the first e(k_eform) equations - but older versions don't work with e(cmd) unset
            cap _coef_table, `eform' `levelopt' `cformat' `pformat' `sformat' `neq'
            if _rc {
                di as error "_coef_table failed - you may be using a version older than 3.0.0"
                di as error "All parameters will be exponentiated"
                ereturn display, `eform' `levelopt' `cformat' `pformat' `sformat' `neq'
            }
            else {
                _coef_table, `eform' `levelopt' `cformat' `pformat' `sformat' `neq'
            }
            di as text "Variance parameters are not exponentiated"
        }
        else ereturn display, `eform' `levelopt' `cformat' `pformat' `sformat' `neq'
        _estimates unhold `hold' /* brings back the main results */
    }
    if "`e(parmtype)'"=="common" & `p'>1 {
        di as text "The above coefficients also apply to the following equations:"
        if "`e(constant)'"!="noconstant" local constantvar _cons
        forvalues r=2/`p' {
            di as result _col(5) "`yvar_`r''" as text ": `e(xvars_`r')' `constantvar'"
        }
    }
}

// PRINT SIGMA
if ("`estimates'"!="noestimates" | "`printbscov'`printbscorr'"!="") & "`bsest'"!="fixed" {
    if "`printbscov'`printbscorr'"=="" local printbscorr on
    if !mi("`printbscorr'") {
        tempname Corr SD all
        cap mat `Corr'=corr(e(Sigma))
        local bsprob = (_rc>0)
        cap mat `SD'=vecdiag(cholesky(diag(vecdiag(e(Sigma)))))'
        if _rc local bsprob 1
        else mat colnames `SD'="SD"
        if `bsprob' {
            di _newline "Warning: can't convert between-studies covariance matrix to correlation matrix" _c
*            di " (probably because one or more variances are zero or negative)" _c
            local printbscov on
            local printbscorr
        }
    }
    if "`printbscov'"=="on" {
       di as text _newline "Estimated between-studies covariance matrix Sigma:" _c
       mat l e(Sigma), noheader
    }
    if "`printbscorr'"=="on" {
        mat `all'=(`SD', `Corr')
        * set above-diag elements to missing
        forvalues r=1/`p' {
            local s0=`r'+2
            local s1=`p'+1
            forvalues s=`s0'/`s1' {
                mat `all'[`r',`s']=.
            }
        }
        if "`e(wscorr)'"=="riley" di as text _newline "Estimated between-studies SDs and OVERALL correlation matrix:" _c
        else di as text _newline "Estimated between-studies SDs and correlation matrix:" _c
        mat l `all', noheader
    }
}

// PRINT WEIGHTS AND BOS
if !mi("`wt'`wt2'") {
    if "`e(parmtype)'"=="common" di as error "Option wt() ignored - incompatible with commonparm"
    else mvmeta_wt, `wt2' `debug'
}

// PRINT I-SQUARED
if "`i2'"=="i2" {
    local error 0
    foreach mat in Q Qa Qb {
        cap confirm matrix e(`mat')
        local error = cond(_rc,1,`error')
    }
    if `error' di as error "Method of moments failed when mvmeta ran, so I^2 cannot be computed"
    else {
        // SET UP
        local z = invnorm((100+`level')/200)
        foreach mat in Q Qa Qb Sigma {
            tempname `mat'
            mat ``mat'' = e(`mat')
        }
        // COMPUTE TAU AND I^2, WITH CIs IF POSSIBLE
        forvalues r=1/`p' {
            local s2`r' = `Qa'[`r',`r']/`Qb'[`r',`r']
            if `s2`r''==. local s2problem yes
            if inlist("`bsest'", "fixed", "mm1", "mm2") {
                local thisQa = `Qa'[`r',`r']
                if "`bsest'"=="mm2" { // ad hoc method 16jul2015
                    local thisQ = `Qa'[`r',`r'] + `Qb'[`r',`r'] * `Sigma'[`r',`r'] 
                    local reconstructed `"reconstructed "'
                }
                else local thisQ = `Q'[`r',`r']
                cap heterogi `thisQ' `thisQa', `levelopt' `ncchi2'
                if _rc {
                    local i2est`r' = max(0,100*(1 - `thisQa'/`thisQ'))
                    local i2low`r' .
                    local i2upp`r' .
                    local heterogifailed yes
                }
                else {
                    local i2est`r' = 100*r(I2)
                    local meth = cond("`ncchi2'"=="ncchi2",2,1)
                    local i2low`r' = 100*r(lb_I2_M`meth')
                    local i2upp`r' = 100*r(ub_I2_M`meth')
                }
                // COMPUTE TAU
                foreach thing in est`r' low`r' upp`r' {
                    local bssd`thing' = sqrt( `i2`thing'' * `s2`r'' / (100 - `i2`thing'') )
                }
                local i2footnote "Note: I^2 computed from `reconstructed'Q matrix and its degrees of freedom"
                if "`heterogifailed'"=="yes" {
                    cap heterogi
                    if _rc==199 local heterogineeded yes
                }
            }
            else {
                // REML/ML: COMPUTE CIs FOR BETWEEN-STUDY SDs
                if "`bscov'"=="proportional" {
                    // -nlcom- only works if you express sqrt(a*tau^2) as sqrt(a)*tau
                    tokenize "`e(Sigma`r'`r')'", parse("*")
                    local number `1'
                    confirm number `1'
                    assert "`3'" == "([tau]_b[_cons])^2"
                    local tau sqrt(`number')*[tau]_b[_cons]
                    local tausq `e(Sigma`r'`r')'
                }
                else if "`bscov'"=="unstructured" {
                    local tausq `e(Sigma`r'`r')'
                    // DROP ANY ZERO TERMS
                    cap nlcom sqrt(`tausq')
                    if _rc {
                        tokenize "`tausq'", parse("+")
                        local tausqnew
                        local tausqdrop
                        while "`1'"!="" {
                            cap nlcom `1'
                            if !_rc {
                                if "`tausqnew'"!="" local tausqnew `tausqnew' +
                                local tausqnew `tausqnew' `1'
                            }
                            else {
                                if "`tausqdrop'"!="" local tausqdrop `tausqdrop' +
                                local tausqdrop `tausqdrop' `1'
                            }
                            mac shift 2
                        }
                        `ifdebug' di as text "Debug: term " as result "`tausqdrop'" as text " dropped in calculating i2 for `yvar_`r''"
                        if abs((`tausq')/(`tausqnew')-1) < 1E-5 {
                            * it's ok
                            local tausq `tausqnew'
                            local droppedterms yes
                            local droppedterm`r' " *"
                        }
                        else di as error "nlcom failed and couldn't be fixed"
                    }
                    local tau sqrt(`tausq')
                }
                else local tau sqrt(`e(Sigma`r'`r')')
                local tau`r' `tau' // for correlations later
                // HANDLE SCALES (PART 1)
                if "`ciscale'"=="logsd" local transform log(`tau')
                else if "`ciscale'"=="logh" local transform 0.5*log(1+(`tausq')/`s2`r'')
                else if "`ciscale'"=="sd" local transform `tau'
                cap nlcom `transform'
                if _rc | ("`bscov'"=="equals") {
                    local bssdest`r' = `tau'
                    local bssdlow`r' .
                    local bssdupp`r' .
                    local nlcomfails yes
                    if ("`bscov'"=="equals") local nlcomfails equals
                }
                else {
                    mat `b' = r(b)
                    mat `V' = r(V)
                    local bssdest`r' = `b'[1,1]
                    local bssdlow`r' = `b'[1,1] - `z' * sqrt(`V'[1,1])
                    local bssdupp`r' = `b'[1,1] + `z' * sqrt(`V'[1,1])
                    foreach thing in bssdest`r' bssdlow`r' bssdupp`r' {
                        // HANDLE SCALES (PART 2)
                        if "`ciscale'"=="logsd" local `thing' = exp(``thing'')
                        else if "`ciscale'"=="logh" {
                                if ``thing''<0 local `thing' 0
                                else local `thing' = sqrt(`s2`r''*(exp(2*``thing'')-1))
                        }
                        else if "`ciscale'"=="sd" {
                                if ``thing''<0 local `thing' 0
                                else local `thing' = ``thing''
                        }
                    }
                }
                // COMPUTE I^2
                foreach thing in est`r' low`r' upp`r' {
                    local i2`thing' = 100*(`bssd`thing'')^2 / ((`bssd`thing'')^2 + `s2`r'')
                }
                local cifootnote "Note: CIs computed on `ciscalename' scale"
                local i2footnote "Note: I^2 computed from estimated between-studies variance" ///
                   _new _skip(6) "and typical within-studies variances"
            }
        }
        
        * FOR OUTPUT
        local ylength 0
        forvalues r=1/`p' {
            local ylength = max(`ylength',length("`yvar_`r''"))
        }
        local ylength1 = max(`ylength',15)
        local col2 _col(`=`ylength1'+2')
        local col3 _col(`=`ylength1'+13')
        local col4 _col(`=`ylength1'+24')
        local col5 _col(`=`ylength1'+35')
        local col6 _col(`=`ylength1'+44')
        local col7 _col(`=`ylength1'+55')
        local line4 as text _dup(`=`ylength1'+34') "{c -}"
        local line5 as text _dup(`=`ylength1'+43') "{c -}"
        local line7 as text _dup(`=`ylength1'+63') "{c -}"

        // OUTPUT BETWEEN-STUDY SDs AND I^2, WITH CIs
        if "`e(cholnames)'"=="cholnames" di as error "Sorry, i2 option is not available with cholnames"
        di as text _newline "Approximate confidence intervals for between-studies SDs and I^2:"
        di `line7'
        di as text "Variable" `col2' " SD" `col3' "[`level'% Conf. Interval]" `col5' " I^2" `col6' "[`level'% Conf. Interval]" _new `line7'
        forvalues r=1/`p' {
            di as text "`yvar_`r''" as result `col2' `bssdest`r'' `col3' `bssdlow`r'' `col4' `bssdupp`r'' `col5' `i2fmt' `i2est`r'' `col6' `i2fmt' `i2low`r'' `col7' `i2fmt' `i2upp`r'' "`droppedterm`r''"
        }
        di `line7'
        if "`nlcomfails'"=="yes" di as text "-nlcom- failed to produce some estimates: this usually occurs when one or more basic variance parameters is zero"
        if "`nlcomfails'"=="equals" di as text "Note: CIs are not appropriate with bscovariance(equals)"
        di as text "`i2footnote'"
        if "`cifootnote'"!="" di as text "`cifootnote'"
        if "`heterogineeded'"=="yes" di as error "To get CIs, please install heterogi using {stata ssc install heterogi}"
        if "`s2problem'"=="yes" di as text "Note: one or more values of I^2 weren't computed because Qa and/or Qb was missing"
        if "`droppedterms'"=="yes" di as text "* CI for I^2 ignores zero variance components"

        // COMPUTE AND OUTPUT BETWEEN-STUDY CORRELATIONS, WITH CIs
        local ylength1 = max(2*`ylength'+4,15)
        local col2 _col(`=`ylength1'+2')
        local col3 _col(`=`ylength1'+13')
        local col4 _col(`=`ylength1'+24')
        local col5 _col(`=`ylength1'+35')
        local col6 _col(`=`ylength1'+44')
        local col7 _col(`=`ylength1'+55')
        local line4 as text _dup(`=`ylength1'+34') "{c -}"
        local line5 as text _dup(`=`ylength1'+43') "{c -}"
        local line7 as text _dup(`=`ylength1'+63') "{c -}"
        if inlist("`bsest'","reml","ml") & `p'>1 & "`bscov'"=="unstructured" {
            di as text _newline "Between-study correlations:" _newline `line4' _newline "Variables" `col2' "Correl." `col3' "[`level'% Conf. Interval]" _new `line4'
            forvalues r=1/`p' {
                local rplus1 = `r'+1
                local rminus1 = `r'-1
                forvalues s=1/`rminus1' {
                    local sdsd (`tau`r''*`tau`s'')
                    local covar (`e(Sigma`s'`r')')
                    if abs(`covar'/`sdsd')<1-1E-5 {
                        qui nlcom log( (`sdsd'+`covar') / (`sdsd'-`covar') )
                        mat `b' = r(b)
                        mat `V' = r(V)
                        local est = `b'[1,1]
                        local lower = `b'[1,1] - `z' * sqrt(`V'[1,1])
                        local upper = `b'[1,1] + `z' * sqrt(`V'[1,1])
                        foreach thing in est lower upper {
                            local `thing' = (exp(``thing'')-1) / (exp(``thing'')+1)
                        }
                    }
                    else {
                        local est = (`covar'/`sdsd')
                        local lower .
                        local upper .
                    }
                    di as text _col(1) "`yvar_`s'' & `yvar_`r''" as result `col2' `est' `col3' `lower' `col4' `upper'
              }
            }
            di `line4'
            di as text "Note: CI computed on log((1+corr)/(1-corr)) scale"
        }
    }
}

if "`testsigma'"=="testsigma" {
    if inlist("`bsest'","reml","ml") {
        local lrt = 2*(e(ll)-e(ll0))
        if abs(`lrt')<epsfloat() local lrt 0
        local df = e(nparms_aux)
        local pvalue = chi2tail(`df',`lrt')
        if `lrt'>0 local pvalue = `pvalue'/2
        di
        if "`bsest'"=="reml" di as text "Restricted likelihood " _c
        else di as text "Likelihood " _c
        di as text "ratio test for heterogeneity: LRT = " as result %6.2f `lrt' as text " (d.f. = " as result `df' as text ") P = " as result %5.3f `pvalue'
        if `lrt'>0 di as text "P-value halved: see {help j_chibar:help j_chibar}"
    }
    else {
        di _newline as error "testsigma option is only available with reml or ml estimation methods"
    }
}

if "`qscalar'"=="qscalar" {
    di _new as text "Scalar Q test for heterogeneity: Q = " as result %6.2f e(Qscalar_chi2) _c
    di as text " (d.f. = " as result e(Qscalar_df) _c
    di as text ") P = " as result %5.3f chi2tail(e(Qscalar_df),e(Qscalar_chi2))
}

if !mi("`randfix'`randfix2'") {
    cap confirm matrix e(V_fixed)
    local noVfixed = _rc>0
    if "`e(bsest)'"=="" {
        di as error "option randfix ignored - no estimation done"
    }
    else if "`e(bsest)'"=="fixed" {
        di as error "option randfix ignored - not appropriate with fixed-effect analysis"
    }
    else if `noVfixed' {
        di as error "option randfix ignored - mvmeta didn't estimate the fixed-effects model"
    }
    else {
        di _new as text "Multivariate R statistic:"
        di "Measures ratio of std errors in current vs. fixed-effect analysis"
        local yvars = e(yvars)
        if mi("`randfix2'") local randfix `yvars'
        else local randfix `randfix2'
        * check specified variables are part of e(yvars)
        local diff : list randfix - yvars
        if "`diff'"!="" {
            di as error "Variable(s) `diff' in randfix() are not outcome variables"
            exit 198
        }
        local nparms_mean = `e(nparms_mean)'
        tempname hold varfixed varrand select
        mat `varfixed' = e(V_fixed)
        mat `varfixed' = `varfixed'[1..`nparms_mean',1..`nparms_mean']
        mat `varrand' = e(V)
        mat `varrand' = `varrand'[1..`nparms_mean',1..`nparms_mean']

        // find appropriate subvariance matrix
        if "`e(parmtype)'"=="short" local rownames: rownames `varfixed'
        else if "`e(parmtype)'"=="long" local rownames: roweq `varfixed'
        else exit 497
        foreach varname of varlist `randfix' {
            local rownames : subinstr local rownames "`varname'" "1", all
        }
        foreach varname of varlist `yvars' {
            local rownames : subinstr local rownames "`varname'" "0", all
        }
        local rownames : subinstr local rownames " " ", ", all
        mat `select' = (`rownames')
        // calculate and output
        mata: selectpart("`select'","`varfixed'","`varfixed'")
        mata: selectpart("`select'","`varrand'","`varrand'")
        `ifdebug' mat l `varfixed', title(Variance-covariance under fixed-effect analysis)
        `ifdebug' mat l `varrand', title(Variance-covariance under current analysis)
        local dim = rowsof(`varfixed')
        local dimrand = rowsof(`varrand')
        if `dim' != `dimrand' {
            di as error "Dimensions of varfixed and varrand differ:"
            mat l `varfixed', title(Variance-covariance under fixed-effect analysis)
            mat l `varrand', title(Variance-covariance under current analysis)
            exit 459
        }
        local detfixed = sqrt(det(`varfixed'))
        local detrand = sqrt(det(`varrand'))
        local rstat = (`detrand'/`detfixed')^(1/`dim')
        local col 49
        local line as text _dup(78) "{c -}"
        di `line'
        di as text "Outcomes considered" _col(`col') as result "`randfix'"
        di as text "Number of parameters" _col(`col') as result `dim'
        di as text "Sqrt determinant of variance (`e(bsest)') " _col(`col') as result `detrand'
        di as text _col(30) "(fixed) " _col(`col') as result `detfixed'
        di as text "R statistic = ratio" _c
        if `dim'>1 di as text " ^ (1/" `dim' ")"_c
        di as text _col(`col') as result `rstat'
        di `line'
    }
}

*** PBEST
if "`pbest'"!="" {
    if "`e(parmtype)'"!="long" di as error ///
        "Sorry, pbest() is only available after running mvmeta with the longparm option"
    else pbest `pbest'
}

*** BUBBLE PLOT
if !missing(`"`bubble'`bubble2'"') {
    mvmeta_bubble, `bubble2' `debug'
}

*** FOREST PLOT
if !missing(`"`forest'`forest2'"') {
    * mvmeta_forest, `forest2' `debug'
    di as error "Sorry, forest plot is not yet available"
}

end

*=========================== END OF REPLAY PROGRAM ============================

*========================== START OF PBEST PROGRAM ============================

program define pbest
// Parse
syntax anything [if] [in], [ ///
    REPs(int 1000) zero gen(string) seed(int -1) format(string) /// documented
    id(varname) PREDict all saving(string) replace clear bar line /// documented
    CUMulative TABDISPoptions(string) mcse MEANrank /// documented
    zeroname(string) STRIPprefix(string) rename(string) /// undocumented
    title(passthru) note(passthru) *]
local minmax `anything'
if !inlist("`minmax'","min","max") {
    di as error "Syntax: pbest(min|max, [options])"
    exit 198
}
if `seed'!=-1 set seed `seed'
if mi("`zeroname'") local zeroname zero
marksample touse
if !mi("`line'") & mi("`all'") {
    di as text "Option line specified -> option all assumed"
    local all all
}
* parse id variable
if mi("`id'") & !mi(e(id)) {
    cap confirm var `e(id)'
    if !_rc local id `e(id)'
}
if mi("`id'") {
    tempvar id
    gen `id' = _n
    local idname _id
}
else {
    local idname `id'
}
cap isid `id'
if _rc {
    di as error "Error in pbest: variable `id' does not uniquely identify the observations
    exit 459
}
* also need a numeric id variable: changed v3.0.5 1jul2015
cap confirm numeric var `id'
if _rc {
    tempvar idnum
    sencode `id', gen(`idnum')
}
else local idnum `id'
if !mi("`meanrank'") local all all

forvalues r=1/`e(dims)' {
    foreach var in `e(xvars_`r')' {
        cap confirm var `var'
        if _rc {
            di as error "pbest: `var' not found"
            exit _rc
        }
        if _rc exit _rc
        cap assert !mi(`var') if `touse'
        if _rc==9 di as error "pbest: `var' must be non-missing `if' `in'"
        if _rc exit _rc
    }
}

* renaming
local i 0
while !mi("`rename'") {
    local ++i
    gettoken thisrename rename : rename, parse(",")
    gettoken renamein`i' renameout`i' : thisrename, parse("=")
    local renameout`i' : subinstr local renameout`i' "=" ""
    local renamein`i' = trim(subinstr("`renamein`i''", ",","",1))
    local renameout`i' = trim(subinstr("`renameout`i''", "=", "",1))
}
local renamen `i'

// retrieve stored results
local p = e(dims)
forvalues r=1/`p' {
    local yvar_`r' : word `r' of `e(yvars)'
}

// initialise counters
if mi("`clear'") tempvar pbest rank treat
else {
    local pbest _Pbest
    local rank _Rank
    local treat _Treat
}
tempvar best rbest pred mvn
local rmin = cond("`zero'"=="zero", 0, 1)
local smax = cond("`all'"=="all", `p' + ("`zero'"=="zero"), 1)
forvalues s=1/`smax' {
    forvalues r=`rmin'/`p' {
        qui gen `pbest'`r'_`s'=0 if `touse'
        if `r'>0 local thischarold = subinstr("`yvar_`r''","`stripprefix'","",1)
        else local thischarold `zeroname'
		local thischarnew
        forvalues i=1/`renamen' { // rename
            if "`thischarold'" == "`renamein`i''" local thischarnew `renameout`i''
        }
		if mi("`thischarnew'") local thischarnew `thischarold'
        if `s'==1 local trtlabel `trtlabel' `r' "`thischarnew'"
        if "`all'"=="all" local thischarnew `s':`thischarnew'
        char `pbest'`r'_`s'[varname] `thischarnew'
    }
}
tempname hold bstar b2 V2

// initialise save-file
if "`saving'" != "" {
    if substr("`saving'",length("`saving'")-3,.)!=".dta" local saving `saving'.dta
    if mi("`replace'") {
        noi confirm new file `saving'
    }
    qui levelsof `idnum' if `touse', local(idlevels)
    local rmin = cond("`zero'"=="zero",0,1)
    forvalues r=`rmin'/`p' {
        local postfilevars `postfilevars' pred`r'
    }
    tempname pbestpost
    postfile `pbestpost' `idname' rep `postfilevars' using `saving', `replace'
}

// do parametric bootstraps -> creates variables `pbest'*
forvalues rep=1/`reps' {
    drawbeta
    _estimates hold `hold', copy
    mat `bstar'=r(bstar)
    mat `b2' = `bstar'[1,1..`e(nparms_mean)']
    mat `V2'= invsym(e(V))
    mat `V2' = `V2'[1..`e(nparms_mean)',1..`e(nparms_mean)']
    mat `V2' = invsym(`V2')
    ereturn post `b2' `V2'
    if "`zero'"=="zero" gen `pred'0 = 0
    forvalues r=1/`p' {
        qui predict `pred'`r' if `touse', eq(`yvar_`r'')
        label var `pred'`r' "Prediction for outcome `r'"
    }
    _estimates unhold `hold'
    if "`predict'"=="predict" {
        * add random error with variance e(Sigma)
        drawnorm `mvn'_1 - `mvn'_`p', cov(e(Sigma))
        forvalues r=1/`p' {
            qui replace `pred'`r' = `pred'`r' + `mvn'_`r'[1] if `touse'
        }
        drop `mvn'_1-`mvn'_`p'
    }
    if "`saving'" != "" {
        foreach i in `idlevels' {
            local postexps (`i') (`rep')
            forvalues r = `rmin'/`p' {
                local postexp = `pred'`r'[`i']
                local postexps `postexps' (`postexp')
            }
            post `pbestpost' `postexps'
        }
    }
    forvalues s=1/`smax' {
        qui gen `best' = . // sth best value
        qui gen `rbest' = . // which value is sth best
        forvalues r=`rmin'/`p' {
            qui replace `rbest' = `r' if `pred'`r'==`minmax'(`pred'`r', `best') & `touse' & !mi(`pred'`r')
            qui replace `best' = `pred'`r' if `pred'`r'==`minmax'(`pred'`r', `best') & `touse' & !mi(`pred'`r')
        }
        forvalues r=`rmin'/`p' { // `pbest'`r'_`s' = whether rth trt is sth best
            qui replace `pbest'`r'_`s' = `pbest'`r'_`s'+100/`reps' if `rbest'==`r' & `touse'
            qui replace `pred'`r' = . if `rbest' ==`r'
        }
        drop `best' `rbest'
    }
    drop `pred'*
}

* Finish save file
if "`saving'" != "" postclose `pbestpost'

// OUTPUT
preserve

* header
di as text _new "Estimated probabilities (%) of each treatment being the best" _c
if `smax'>1 di " (and other ranks)" _c
di
di as text "- assuming the " as result "`minmax'imum" as text " parameter is the best"
di as text "- using " as result `reps' as text " draws" _c
if "`saving'" != "" di as text " (written to file " as result "`saving'" as text ")" _c
di
di "- allowing for parameter uncertainty" _c
if "`predict'"=="predict" di " and between-studies variation" _c

* reshape into a long data set
qui keep if `touse'
keep `idnum' `pbest'*
*if "`id'"=="" {
*    tempvar id
*    gen `id'=_n
*    label var `id' "id"
*}
qui count
local multid = r(N)>1
forvalues r=`rmin'/`p' {
    local pbestlist `pbestlist' `pbest'`r'
}
qui reshape long `pbestlist', i(`idnum') j(`rank') string
qui replace `rank' = substr(`rank',2,.) // removes initial "_"
qui destring `rank', replace
qui reshape long `pbest', i(`idnum' `rank') j(`treat')

* MC error
if !mi("`mcse'") {
    tempvar mcse
    gen `mcse' = sqrt(`pbest'*(100-`pbest')/`reps')
    local dispvars `pbest' `mcse'
    di as text _n "- figures are estimated probability (upper), Monte Carlo error (lower)" _c
}
else local dispvars `pbest'

* label variables and values
char `rank'[varname] Rank
char `treat'[varname] Treat
char `idnum'[varname] `idname'
char `pbest'[varname] Pbest
label var `rank' "Rank"
label var `treat' "Treatment"
label var `idnum' "`idname'"
label var `pbest' "Pbest"
label def `treat' `trtlabel'
label val `treat' `treat'
if "`format'"=="" local format %6.1f // best for table
format `pbest' `mcse' `format'
forvalues s=1/`smax' {
    if `s'==1 local text "Best"
    else if `s'==`smax' local text "Worst"
    else if `s'==2 local text `s'nd
    else if `s'==3 local text `s'rd
    else local text `s'th
    label def `rank' `s' "`text'", add
}
label val `rank' `rank'

* output mean rank & SUCRA
local recordtype _Recordtype
gen `recordtype' = 0
if !mi("`meanrank'") {
    sort `idnum' `treat' `rank'
    tempvar newrecord meanrank
    qui expand 2 if `rank'==`smax', gen(`newrecord')
    qui replace `rank'=`smax'+10 if `newrecord' // for meanrank
    qui replace `recordtype'=1 if `newrecord'
    drop `newrecord'
    qui expand 2 if `rank'==`smax', gen(`newrecord')
    qui replace `rank'=`smax'+11 if `newrecord' // for sucra
    qui replace `recordtype' = 2 if `newrecord' 
    drop `newrecord'
    label def `recordtype' 0 "Probability" 1 "Mean rank" 2 "SUCRA"
    label val `recordtype' `recordtype' 
    qui replace `pbest'=. if `recordtype' 
    sort `idnum' `treat' `rank'
    qui by `idnum' `treat': gen `meanrank' = sum(`rank'*`pbest')/sum(`pbest')
    qui replace `pbest' = `meanrank' if `recordtype'==1
    qui replace `pbest' = (`smax' - `meanrank') / (`smax' - 1) if `recordtype'==2
    label def `rank' `=`smax'+10' "MEAN RANK" `=`smax'+11' "SUCRA", add 
    if !mi("`mcse'") {
        tempvar meanrank2
        qui by `idnum' `treat': gen `meanrank2' = sum(`rank'^2*`pbest')/sum(`pbest')
        replace `mcse' = sqrt(`meanrank2' - `meanrank'^2)/sqrt(`reps') if `recordtype'
        replace `mcse' = `mcse' / (`smax' - 1) if `recordtype'==2
        drop `meanrank2'
    }
    // NB `smax' = #compared because meanrank option => all option
}

* tabulate
local byid by(`idnum') // could make this -if `multid'-?
if `smax'==1 local tabcmd tabdisp `idnum' `treat', c(`dispvars') `tabdispoptions'
else local tabcmd tabdisp `rank' `treat', `byid' c(`dispvars') `tabdispoptions'
`tabcmd'

// GRAPH
format `pbest' %6.0f // best for axis label
if !mi("`bar'") {
    if !mi("`cumulative'") local stack stack
    if `smax'>1 {
        local overrank over(`rank')
        local legendtitle title("Rank")
    }
    else local legendtitle title("Treatment")
    if `multid' local byid by(`idnum', `title' `note')
    else local byid `title' `note'
    local graphcmd graph bar `pbest', `overrank' over(`treat') `byid' asy ytitle("Probability (%)") `stack' legend(`legendtitle') `options'
}
else if !mi("`line'") {
    if `multid' di as error "Graphs for multiple records will be overlaid"
    if !mi("`cumulative'") {
        sort `idnum' `treat' `rank'
        local pbestcum `pbest'cum
        qui by `idnum' `treat': gen `pbestcum' = sum(`pbest') if !`recordtype' 
        local cumulative Cumulative
        local pbestvar `pbestcum'
    }
    else local pbestvar `pbest'
    if mi("`note'") local note note("")
    if !mi("`mcse'") { // I THINK THE MCSEs ARE WRONG WITH CUMULATIVE OPTION??
        if !mi("`cumulative'") qui replace `mcse' = `pbestcum' * (100-`pbestcum') / `reps' if !`recordtype'
        tempvar pbestlow pbestupp
        qui gen `pbestlow'=`pbestvar'-1.96*`mcse' if !`recordtype'
        qui gen `pbestupp'=`pbestvar'+1.96*`mcse' if !`recordtype'
        local rspike (rspike `pbestlow' `pbestupp' `rank' if !`recordtype', pstyle(p1))
    }
    local graphcmd twoway (line `pbestvar' `rank' if !`recordtype', c(L) pstyle(p1)) `rspike', by(`treat', `title' `note' imargin(medium) legend(off)) ytitle("`cumulative' Probability (%)") xlabel(minmax,val) `options'
    // imargin(medium) avoids "worst" of one column overlapping and "best" of next column
}
`graphcmd'

// FINISH OFF
if !mi("`clear'") { // keep variables in memory
    global F7 `tabcmd'
    di as text "Tabulate command is stored in F7"
    global F8 `graphcmd'
    di as text "Graph command is stored in F8"
    restore, not
    exit
}
else if "`gen'"!="" { // optionally generate variables
    restore
    forvalues s=1/`smax' {
        forvalues r=`rmin'/`p' {
            local rname = cond(`r'>0,"`yvar_`r''","zero")
            local sname = cond(`s'>1,"`s'","`minmax'")
            rename `pbest'`r'_`s' `gen'`sname'_`rname'
            label var `gen'`sname'_`rname' "`rname' has rank `sname'"
        }
    }
}
else drop `pbest'* // not needed?

end

*============================= END OF PBEST PROGRAM ============================

*========================== START OF DRAWBETA PROGRAM (for pbest) ==========================

program define drawbeta, rclass
syntax, [tweak(real 1E-12)]

tempname b V chol
matrix `b' = e(b)
matrix `V' = e(V)

local p = colsof(`b')
return scalar colsofb = colsof(`b')

capture matrix `chol' = cholesky(`V')
local rc = c(rc)
if `rc' == 506 {
    matrix `chol' = cholesky((`tweak' * trace(`V')/`p') * I(`p') + `V')
}
else if `rc' > 0 {
    di as err "Cholesky decomposition failed with error " `rc'
    exit `rc'
}

tempname e bstar
matrix `e' = J(1, `p', 0)
forvalues i = 1 / `p' {
    matrix `e'[1, `i'] = invnormal(uniform())
}
matrix `bstar' = `b' + `e' * `chol''
return matrix bstar = `bstar'

end

*=========================== END OF DRAWBETA PROGRAM ===========================

*=========================== START OF MVMETA_WT PROGRAM ===========================

program define mvmeta_wt

/*
v1.2 22apr2015
    uses e(V_uv)
    id() no longer allowed (taken from e(ydata))
v1.1.1 11mar2015
    bug fixes
        not sortpreserve (interferes with clear option)
        copes if 1st equation is empty
        mvmeta call to create matrices now has option -fixed- to avoid jointcheck returning error
v1.1 9feb2015
    no run option
    new syntax 
    results as variables or matrices
v1.0 3feb2015
    try to make it handle covariates
    drop abs
	matrices aren't left lying around
	made output sensible and agreeing as far as poss across methods

To do:

Note: previous -borrow- option reported (Vuv/Vmv-1)
	  cf here it correctly reports (1-Vmv/Vuv)

Requires: sencode [from SSC]

Note for mvmeta: this will be a weight option for mvmeta, because both wt and bos can be understood as sharing the weight between studies and between sources of information within studies. Syntax will be [nowt wt(suboptions)]. Default will be wt(sd) unless nowt is specified.
*/

// FIND ERETURNED RESULTS
local n = e(N)
local p = e(dims)
* find covariates
local hasx 0
local qsum0 0
forvalues r=1/`p' {
    local yvar_`r' : word `r' of `e(yvars)'
    local yvarsquoted `"`yvarsquoted' "`yvar_`r''""'
    local xvars_`r'=e(xvars_`r')
    if !mi(e(xvars_`r')) {
		local q`r' = wordcount(e(xvars_`r'))
		local hasx 1
        if !mi("`eqs'") local eqs `eqs',
        local eqs `eqs' `yvar_`r'':`xvars_`r''
	}
	else local q`r' 0
	if mi(e(constant)) local q`r' = `q`r'' + 1
    local qsum`r' = `qsum`=`r'-1'' + `q`r''
	* Outcome `r' has `q`r'' covariates - will be useful later
}
if !mi(e(constant)) local constant = e(constant)
	
// PARSE
syntax, [            ///
    SD RV DPC        /// the 3 methods, which can't be specified together
    DETails          /// to output a table of the full SD (SD method only) 
                     /// or of the separate SEs (RV method only)
    Format(passthru) /// format for all methods
    CLear            /// loads the data for the table into memory (SD method only)
    Keepmat(name)    /// to save the matrices (all methods - 3 matrices for SD, 1 for RV & DPC) 
    UNscaled         /// also unscaled details (SD method only)
    Wide             /// wide format (SD + details only)
    mat(name)        /// weights matrix to be saved: undocumented
    debug            /// undocumented
    ]
if !mi("`debug'") di as input "Running: mvmeta_wt `0'"
if wordcount("`sd' `rv' `dpc'")>1 {
    di as error "Please specify only one method out of: `sd' `rv' `dpc'"
    exit 198
}
if mi("`sd'`rv'`dpc'") local sd sd // SD is default
if !mi("`clear'") & (mi("`sd'") | mi("`details'")) di as error "mvmeta_wt: option clear ignored (only relevant with sd and details options)"
if !mi("`wide'") & (mi("`sd'") | mi("`details'")) di as error "mvmeta_wt: option wide ignored (only relevant with sd and details options)"
if !mi("`unscaled'") & mi("`sd'") di as error "mvmeta_wt: option unscaled ignored (only relevant with sd option)"
if mi("`format'") & !mi("`sd'`rv'") local format format(%6.1f)
if mi("`e(V_uv)'") & !mi("`rv'") {
    di as error "mvmeta_wt: option rv is not allowed since univariate results were not found"
    exit 459
}

tempname V XViX Z W w wV tot xpart total direct borrowed

// CREATE DATA MATRICES
tempname hold ymat Smat Xmat
mat `ymat' = e(ydata)
mat `Smat' = e(Sdata)
mat `Xmat' = e(Xdata)
forvalues i = 1/`n' {
    mat `ymat'`i'=`ymat'[`i',1...]
    local first = `p'*(`i'-1)+1
    local last = `p'*`i'
    mat `Smat'`i'=`Smat'[`first'..`last',1...]
    mat `Xmat'`i'=`Xmat'[`first'..`last',1...]'
    local studyname : rowname `ymat'`i'
    local studynames `"`studynames' `"`studyname'"'"'
}

// GENERAL CALCULATIONS
forvalues i=1/`n' {
    mat `V'`i' = `Smat'`i'
    * "augment" missing values
	local Vmax 0
	forvalues r=1/`p'{
		local Vmax = max(`Vmax',`V'`i'[`r',`r'])
	}
	forvalues r=1/`p'{
		forvalues s=1/`p'{
			if mi(`V'`i'[`r',`s']) mat `V'`i'[`r',`s'] = cond(`r'==`s',`Vmax'*1E6,0)
		}
	}
	if "`e(bsest)'"!="fixed" {
        mat `V'`i' = `V'`i' + e(Sigma)
        if "`e(wscorr)'"=="riley" {
    		mat `V'`i' = cholesky(diag(vecdiag(`V'`i')))
    		mat `V'`i' = `V'`i'*corr(e(Sigma))*`V'`i'
            * now need to re-set augmented off-diag elements to 0 for Riley method
        	forvalues r=1/`p'{
        		forvalues s=1/`p'{
                    if `s'==`r' continue
                    if mi(`Smat'`i'[`r',`r']) | mi(`Smat'`i'[`s',`s']) mat `V'`i'[`r',`s'] = 0
        		}
        	}
    	}
    }
if !mi("`debug'") mat l `V'`i', title(Total variance matrix for study `i')
	mat `XViX'`i' = `Xmat'`i' * invsym(`V'`i') * `Xmat'`i''
	if `i'==1 mat `XViX'sum = `XViX'`i'
	else 	  mat `XViX'sum = `XViX'sum + `XViX'`i'
}
mat `Z' = invsym(`XViX'sum)

// SCORE DECOMPOSITION METHOD: WEIGHTS, BoS, OPTIONAL DETAILS
if !mi("`sd'") { 
    forvalues i=1/`n' {
        forvalues r=1/`p' {
            local rprev = `r'-1
            local start = `qsum`rprev''+1
            local end = `qsum`r''
            local rbit `start'..`end'
        	mat `Z'part = `Z'[`rbit',1...]
        	mat `Z'part2 = `Z'[`rbit',`rbit']
            mat `xpart' = `Xmat'`i'[`rbit',`r']

            * total contribution
    		mat `total'_ir = vecdiag(`Z'part * `XViX'`i' * `Z'part')
            if `r'==1 mat `total'_i = `total'_ir
            else mat `total'_i = `total'_i , `total'_ir

            * direct contribution
            mat `direct'_ir = vecdiag(`Z'part2 * `xpart' * `xpart'' * `Z'part2 * (1 / `V'`i'[`r',`r']))
            if `r'==1 mat `direct'_i = `direct'_ir
            else mat `direct'_i = `direct'_i , `direct'_ir
    	}
        if `i'==1 mat `total' = `total'_i
        else mat `total' = `total' \ `total'_i
        if `i'==1 mat `direct' = `direct'_i
        else mat `direct' = `direct' \ `direct'_i
    }
    mat rownames `total' = `studynames'
    mat rownames `direct' = `studynames'
    mat `borrowed' = `total' - `direct'
    
    * now have: `direct', `borrowed' and `total' which are studies x parameters
    foreach source in total direct borrowed {
        if e(parmtype)=="short" {
            mat colnames ``source'' = `yvarsquoted'
            mat coleq ``source'' = "Overall"
        }
        mat ``source''_sum = J(1,`n',1) * ``source'' // row sum
        mat rownames ``source''_sum = "`=upper("`source'")'"
        mat ``source''_scaled = 100 * ``source'' * invsym(diag(`total'_sum)) 
        mat ``source''_scaled_sum = J(1,`n',1) * ``source''_scaled // row sum
        mat rownames ``source''_scaled_sum = "`=upper("`source'")'"
        if !mi("`keepmat'") {
            if mi("`unscaled'") mat `keepmat'`source' = ``source''_scaled
            else mat `keepmat'`source' = ``source''
        }
    }
    * now also have `direct'_sum, `borrowed'_sum and `total'_sum  which are 1 x parameters
    * and `direct'_scaled, `borrowed'_scaled and `total'_scaled which are studies x parameters

    * Main output: study weights and BoS
    mat `total'_scaled_withtotal = `total'_scaled \ `total'_scaled_sum \ `borrowed'_scaled_sum \ `direct'_scaled_sum
    di as text _n "Weights using score decomposition method" 
    di as text "Study weights and borrowing of strength (% of total for each parameter):" _c
    mat l `total'_scaled_withtotal, noheader `format'
    
    if !mi("`details'") { // now output as a data set
        if mi("`clear'") preserve
        qui {
            drop _all
            set obs `n'
*            gen id = ""
            gen id = _n /*1jul2015*/
            forvalues i=1/`n' {
                local studyname : word `i' of `studynames'
*                replace id = "`studyname'" in `i'
                label def id `i' "`studyname'", add /*1jul2015*/
            }
            label val id id /*1jul2015*/
            tempname onecol
            forvalues k=1/`qsum`p'' {
                foreach source in direct borrowed total {
                    mat `onecol' = ``source''[1...,`k']
                    svmat `onecol', names(`source'`k')
                    rename `source'`k'1 `source'`k'
                }
                local outcome`k' : coleq `onecol'
                local covariate`k' : colnames `onecol'
                local parameter`k' : colfullnames `onecol'
            }
            reshape long direct borrowed total, i(id) j(parm)
            local parmids outcome covariate parameter
            foreach parmid in `parmids' {
                gen `parmid' = ""
                forvalues k=1/`qsum`p'' {
                    replace `parmid' = "``parmid'`k''" if parm==`k'
                }
                sencode `parmid', replace
            }
            drop parm
            egen totsum = sum(total), by(parameter)
            foreach source in direct borrowed total {
                gen scaled`source'=100*`source'/totsum
                rename `source' unscaled`source'
            }
            drop totsum
            reshape long scaled unscaled, i(id `parmids') j(source) string
            * next 4 lines choose order "total, borrowed, direct"
            gen sourcenum = 1*(source=="total") + 2*(source=="borrowed") + 3*(source=="direct")
            replace source=upper(source)
            sencode source, gsort(sourcenum) replace
            drop sourcenum
        }
        local var = cond(mi("`unscaled'"),"scaled","unscaled")
        di as text _n "Details of `var' weights:" _c
        if !mi("`wide'") {
            local parmid
            qui tab outcome
            if r(r)>1 local parmid outcome
            qui tab covariate
            if r(r)>1 local parmid `parmid' covariate
            if "`parmid'" == "outcome covariate" local parmid parameter
            local cmd table id `parmid' source, c(sum `var') `format' row
        }
        if mi("`wide'") {
            local cmd table id covariate outcome, c(sum `var') by(source) `format' row
        }
        `cmd'
        if !mi("`clear'") {
            di as text "Tabulated data are now in memory. Press F9 to recall table command."
            global F9 `cmd'
            exit
        }
        restore
    }

    if !mi("`mat'") {
        mat `mat' = `total'_scaled
    }

}

// RELATIVE VARIANCES METHOD: BoS ONLY
if !mi("`rv'") { 
    tempname Vmv Vuv Vuvq rvmat all
	mat `Vmv' = e(V)
	mat `Vuv' = e(V_uv)
	mat `Vuv'=`Vuv'[1..`qsum`p'',1..`qsum`p'']
	local names : rowfullnames `Vuv', quoted

    foreach source in direct borrowed total {
        mat ``source''_sum  = J(1,`qsum`p'',.)
    	mat colnames ``source''_sum = `names'
        mat ``source''_scaled_sum = J(1,`qsum`p'',.)
        mat colnames ``source''_scaled_sum = `names'
        mat rownames ``source''_scaled_sum = "`=upper("`source'")'"
    }
	mat `rvmat' = J(3,`qsum`p'',.)
	mat `rvmat'_details = J(2,`qsum`p'',.)
	mat rownames `rvmat'_details = "Univariate" "Multivariate" 
    mat rownames `rvmat' = "TOTAL" "BORROWED" "DIRECT"
	forvalues i=1/`qsum`p'' {
		local vmv = `Vmv'[`i',`i']
		local vuv = `Vuv'[`i',`i']
		mat `rvmat'_details[1,`i'] = sqrt(`vuv')
		mat `rvmat'_details[2,`i'] = sqrt(`vmv')
		mat `rvmat'[1,`i'] = 1                      // total
		mat `rvmat'[2,`i'] = 1 - float(`vmv'/`vuv') // borrowed; float avoids tiny negative values
		mat `rvmat'[3,`i'] = `vmv'/`vuv'            // direct
	}
    mat `rvmat' = 100 * `rvmat'
	mat colnames `rvmat' = `names'
	mat colnames `rvmat'_details = `names'

    di as text _n "Weights using relative variances method" 
    di "Borrowing of strength (% of total for each parameter):" _c
    mat l `rvmat', noheader `format'
    if !mi("`details'") {
        di _n as text "Standard errors used in the relative variance method:" _c
        mat l `rvmat'_details, noheader 
    }
    if !mi("`keepmat'") {
        if !mi("`details'") mat `keepmat'se = `rvmat'_details
        mat `keepmat' = `rvmat'
    }
}

// COMPUTE DATA-POINT COEFFICIENTS
if !mi("`dpc'") {
    forvalues i=1/`n' {
    	mat `W'`i' = `Z' * `Xmat'`i' * invsym(`V'`i')
        local thisid : word `i' of `studynames'
    	mat coleq `W'`i' = `"`thisid'"'
    	if `i'==1 mat `W'=`W'`i''
    	else mat `W' = `W' \ `W'`i''
    }
    if e(parmtype)=="short" {
        mat colnames `W' = `yvarsquoted'
        mat coleq `W' = "Overall"
    }
    di as text _n "Weights using data-point coefficients method" 
    di as text "Coefficients for parameters by data points:" _c
    mat l `W', noheader `format'
    if !mi("`keepmat'") mat `keepmat' = `W'
}

end

*=========================== END OF MVMETA_WT PROGRAM ===========================

*=========================== START OF MVMETA_BUBBLE PROGRAM ===========================
/*
version 1.6 Ian White 22apr2015
    uses e(ydata) etc. not current data
    no id() option
24apr2015 - data construction outsourced to mvmeta_getdata    
version 1.5 Ian White 11feb2015
*/

program define mvmeta_bubble
// PARSE
syntax [anything], ///
    [Variables(string) noMv noUv STUDylabel(passthru) UVLABel(passthru) MVLABel(passthru) clear MLABel ///
    noESTimates debug * /// to be undocumented
    ]
if mi(e(bsest)) local estimates noestimates
* allows all bubble options 
if !mi("`debug'") di as input "Call: mvmeta_bubble `0'"
if !mi("`estimates'") {
    local uv nouv
    local mv nomv
    local wt
}
if mi("`variables'") {
    local variables = word(e(yvars),1)+" "+word(e(yvars),2)
    di as text _newline "Bubble option: no variables specified, displaying " as result word(e(yvars),1) as text " and " as result word(e(yvars),2)
}
cap unab variables : `variables'
tokenize "`variables'"
if mi("`2'") | !mi("`3'") {
    di as error "bubble: variables option must contain exactly two variables"
    exit 198
}
local y `1'
local x `2'
local yend = subinstr("`y'",e(ystub),"",1)
local xend = subinstr("`x'",e(ystub),"",1)

// check if there are covariates
local hasx 0
forvalues i = 1/`e(dims)' {
    if !mi("`e(xvars_`i')'") local hasx 1
}
if (`hasx' | e(parmtype)=="common") {
    if "`uv'"!="nouv" | "`mv'"!="nomv" {
        di as error "Sorry, bubble plot can't show summaries - last mvmeta run " _c
		if `hasx' di "had covariates"
        else if e(parmtype)=="common" di "used commonparm option"
		local mv nomv
        local uv nouv
    }
}

// LOAD DATA
if mi("`clear'") preserve
if mi("`clear'") tempvar type
else local type _type
mvmeta_getdata `y' `x', type(`type') corr `uv' `mv' `studylabel' `uvlabel' `mvlabel'
if !mi("`mlabel'") local mopts mopts(mlab(_id))
cap confirm variable corr_`y'_`x'
local corrvar = cond(_rc,"corr_`x'_`y'","corr_`y'_`x'")
bubble `y' `x' se_`y' se_`x' `corrvar', `mopts' group(`type') `debug' `clear' nowarnings `options'

if !mi("`debug'") di as input "Ending mvmeta_bubble"
end

*=========================== END OF MVMETA_BUBBLE PROGRAM ===========================

*=========================== START OF BUBBLE PROGRAM ===========================
/*
version 1.4.3 Ian White 5mar2015
    colby renamed group
    lpattern and lwidth can be specified by group
version 1.4.2 23dec2014 
	uses inbuilt color scheme via pstyle()
	colourbystudy renamed colby
version 1.4.1 26jun2014 - can detect mis-matched mean and sd
version 1.4 26mar2012 - COLOURBystudy option gives different colors!
version 1.3 26mar2012 - variables correctly saved with clear option
version 1.2 17jan2011 - treats missing values as known zeroes (or other value) - new options missval() and stagger()
version 1.1 14Sep2010 - plots 1st vs 2nd not vice versa
Simple usage:
    bubble ymean xmean ysd xsd corr
*/
program define bubble

// PARSE
syntax varlist(min=2 max=5) [if] [in], [pct(numlist) n(int 36) clear /// main options
    MISSval(string) STAGger(string) /// missing value options
    GRoup(varname) COLors(string) LPatterns(string) LWidths(string) /// by-group options
	MLABel(passthru) MSymbol(passthru) MSIZe(passthru) MSTYle(passthru) /// marker options
	LSTYle(passthru) /// line options
    noWARnings /// output options
    lopts(string) mopts(string) cov debug eform *] // graph options

if !mi("`debug'") di as input "Call: bubble `0'"
tokenize "`varlist'"
local ymean `1'
local xmean `2'

tempvar ysd xsd corr
qui {
    if mi("`3'") gen `ysd' = 1 if !mi(`ymean')
    else gen `ysd' = `3'
    if !mi("`cov'") replace `ysd' = sqrt(`ysd')
    if mi("`4'") gen `xsd' = 1 if !mi(`xmean')
    else gen `xsd' = `4'
    if !mi("`cov'") replace `xsd' = sqrt(`xsd')
    if mi("`5'") gen `corr' = 0 if !mi(`ymean',`xmean')
    else gen `corr' = `5'
    if !mi("`cov'") replace `corr' = `corr'/ (`xsd'*`ysd')
}
if !mi("`debug'") {
    di as text "Data to be plotted (ymean, xmean, ysd, xsd, corr):"
    l `ymean' `xmean' `ysd' `xsd' `corr'
}

// MISSING VALUES
tokenize "`missval'"
local xmissval = cond("`1'"!="","`1'","0")
local ymissval = cond("`2'"!="","`2'","`xmissval'")
tokenize "`stagger'"
local xstagger `1'
local ystagger = cond("`2'"!="","`2'","`1'")
if "`pct'"=="" local pct 50
if !mi("`group'") & mi("`msymbol'") local msymbol msymbol(S)
* bubble-specific options
if !mi("`colors'") forvalues i=1/`=wordcount("`colors'")' {
	if word("`colors'",`i')!="=" local col = word("`colors'",`i')
	if !inlist("`col'","",".") {
        local lcol`i' lcol(`col')
    	local mcol`i' mcol(`col')
    }
}
if !mi("`lpatterns'") forvalues i=1/`=wordcount("`lpatterns'")' {
	if word("`lpatterns'",`i')!="=" local lpatt = word("`lpatterns'",`i')
	if !inlist("`lpatt'","",".") local lpatt`i' lpatt(`lpatt')
}
if !mi("`lwidths'") forvalues i=1/`=wordcount("`lwidths'")' {
	if word("`lwidths'",`i')!="=" local lwid = word("`lwidths'",`i')
	if !inlist("`lwid'","",".") local lwid`i' lwid(`lwid')
}
* common options 
local lopts `lopts' `lstyle' 
local mopts `mopts' `mstyle' `mlabel' `msymbol' `msize'

// PRESERVE
if "`clear'"=="" {
    preserve
    tempvar x y
}
else {
    local x `xmean'
    local y `ymean'
}

// MISSING VALUES
qui drop if mi(`xmean') & mi(`ymean')
tempvar ismiss ismisssum
if mi("`warnings'") foreach z in x y { // warnings (picks up mis-matched mean and sd)
    qui count if mi(``z'mean') > mi(``z'sd')
    if r(N) di as error "Warning: `=r(N)' observations with missing ``z'mean' and non-missing ``z'sd'
    qui count if mi(``z'mean') < mi(``z'sd')
    if r(N) di as error "Warning: `=r(N)' observations with non-missing ``z'mean' and missing ``z'sd'
}
foreach z in x y {
    if "``z'stagger'"=="" {
        qui summ ``z'mean'
        local `z'stagger = (r(max)-r(min))/100
    }
    gen `ismiss' = mi(``z'mean')
    gen `ismisssum' = sum(`ismiss')
    qui count if `ismiss'
    if r(N)>0 {
        di as result r(N) as text " missing values found for ``z'mean' and displayed at " as result "``z'mean'=" ``z'missval'
        qui replace ``z'mean' = ``z'missval' + ``z'stagger'*(`ismisssum'-(r(N)+1)/2) if `ismiss'
        qui replace ``z'sd' = 0 if `ismiss'
        qui replace `corr' = 0 if `ismiss'
        local `z'ismiss yes
        if mi("`eform'") local options `options' `z'label(``z'missval' "Missing", add)
        else local options `options' `z'label(`=exp(``z'missval')' "Missing", add)
    }
    drop `ismiss' `ismisssum'
}

// EXPAND
marksample touse, novarlist
qui keep if `touse'
tempvar id z
gen `id'=_n
local nstudies=_N
local nplus1=`n'+2
qui expand `nplus1'
sort `id'
qui by `id': gen _theta = (_n-1)*2*_pi/`n' if _n<_N
// ADD CONTOUR VARIABLES
local ly : var label `ymean'
local lx : var label `xmean'
if "`ly'"=="" local ly `ymean'
if "`lx'"=="" local lx `xmean'
local i 0

if !mi("`group'") { 
    cap confirm numeric var `group'
    if _rc sencode `group', replace // convert to numeric
    qui levelsof `group', local(grouplevels)
}
local l 0
foreach p of numlist `pct' {
    local ++i
    local a = sqrt(-2*log(1-`p'/100))
    qui gen `y'`i' = `a'*sin(_theta)
    qui gen `x'`i' = `a'*cos(_theta)
    qui replace `x'`i' = (`corr')*`y'`i' - sqrt(1-(`corr')^2)*`x'`i'
    qui replace `x'`i'=`xmean'+`xsd'*`x'`i'
    qui replace `y'`i'=`ymean'+`ysd'*`y'`i'
    local s 0
    if !mi("`group'") {
        foreach level in `grouplevels' {
            local ++s
            local cond `group'==`level'
            local graphlist `graphlist' ///
                (line `y'`i' `x'`i' if `cond', pstyle(p`s') cmissing(n) `lcol`s'' `lpatt`s'' `lwid`s'' `lopts') ///
                (scatter `ymean' `xmean' if `cond' & _theta==0, pstyle(p`s') `mcol`s'' `mopts')
            local ++l
            if `i'==1 local legendorder `legendorder' `l'
            if `i'==1 local legendlabel `legendlabel' label(`l' "`:label (`group') `level''")
            local ++l
        }
    }
    else {
        local graphlist `graphlist' (line `y'`i' `x'`i', cmissing(n) `lopts' `lcol`i'' `lpatt`i'' `lwid`s'' `mcol`i'')
        local legend `legend' label(`i' "`p'%")
        local legendorder `legendorder' `i'
    }
    label var `y'`i' "`ly'"
    label var `x'`i' "`lx'"
}
if !mi("`group'") {
    local legendopt legend(order(`legendorder') `legendlabel')
    foreach p of numlist `pct' {
        local note `note' `p'%
    }
    local note note("Showing `note' confidence region(s)")
}
else {
	local i1=`i'+1
    local graphlist `graphlist' (scatter `ymean' `xmean', pstyle(p`i1') `mcol`i1'' `mopts')
    local legendopt legend(`legend' order(`legendorder') title("Probability"))
}
if !mi("`ylab'") local options ytitle(`"`ylab'"') `options'
if !mi("`xlab'") local options xtitle(`"`xlab'"') `options'

if !mi("`eform'") {
    foreach var of varlist `ymean' `xmean' `y'* `x'* {
        qui replace `var'=exp(`var')
    }
    local options `options' xscale(log) yscale(log)
}

// GRAPH
local command twoway `graphlist', `note' `legendopt' `options'
if "`clear'"=="clear" {
    global F9 `command'
    di as text "Bubble graph data loaded into memory"
    di as text "(command saved in F9)"
}
if !mi("`debug'") di as input `"`command'"'
`command'
if !mi("`debug'") di as input "Ending bubble"
end

*=========================== END OF BUBBLE PROGRAM ===========================

program define dicmd
noi di as input `"`0'"'
`0'
end

*=========================== START OF MVMETA_ESTIMATE PROGRAM ===========================

program define mvmeta_estimate, rclass // taken from mvmeta.ado, 2apr2015

*** PARSE

syntax namelist(min=2 max=2) if, yends(string) parmtype(string) missest(string) missvar(string) [bsest(string) xvarslist(string) bscovariance(string) wscorr(string) sigma0(string) start(string) noconstant wscorrforce nowarnings augment augquiet notrunc cholnames debug showstart mmfix taulog id(varname) noestimates ITERate(passthru) sigma0exp(string) *]
mlopts mlopts, `options' // iterate is parsed separately as it is changed in 2nd -ml- run
if mi("`debug'") local ifdebug *
`ifdebug' di as input "mvmeta_estimate `0'"
tokenize "`namelist'"
local ystub `1'
local Sstub `2'
local p = wordcount("`yends'")
marksample touse
if `p'>1 & mi("`xvarslist'") exit 497
tokenize `"`xvarslist'"', parse(",")
forvalues r=1/`p' {
    if "`1'"!="." local xvars_`r' `1' // . means missing
    if `r'<`p' & "`2'"!="," {
        di as error "mvmeta_estimate: error in xvarslist option"
        exit 497
    }
    mac shift 2
}
qui count if `touse'
local n = r(N)
local N = _N
if "`constant'" != "noconstant" {
    tempvar xcons
    gen `xcons' = 1
	local xconsname _cons
}
if "`estimates'"!="noestimates" & "`bsest'"=="" {
    di as error "mvmeta_estimate: bsest() required"
    exit 497
}

*** START OF CODE TAKEN FROM MVMETA.ADO

* COUNT FIXED PARAMETERS
local fixedparms 0
forvalues r=1/`p' {
    local yend_`r' = word("`yends'",`r')
    local yvar_`r' `ystub'`yend_`r''
    local ylist `ylist' `yvar_`r''
    local fixedparms`r' = wordcount("`xvars_`r'' `xconsname'")
    if "`parmtype'"=="common" & `fixedparms`r''!=`fixedparms1' {
        di as error "commonparm option: equations 1 and `r' may not have different numbers of variables"
        exit 198
    }
    local fixedparmsum = `fixedparmsum' + `fixedparms`r''
}
local fixedparms = cond("`parmtype'"=="common", `fixedparms1', `fixedparmsum')


****************** IDENTIFY COVARIANCE EXPRESSIONS *****************

tempvar covvar // stub for any covariance variables we have to create
local wscorrunused 0
local wscorrused 0
forvalues r=1/`p'{
    forvalues s = `r' / `p' {
        cap confirm var `Sstub'`yend_`r''`yend_`s'', exact
        local okrs = _rc==0
        cap confirm var `Sstub'`yend_`s''`yend_`r'', exact
        local oksr = _rc==0
        if `okrs' & (`s'==`r' | mi("`wscorrforce'")) local Svar_`r'_`s' `Sstub'`yend_`r''`yend_`s''
        else if `oksr' & (`s'==`r' | mi("`wscorrforce'")) local Svar_`r'_`s' `Sstub'`yend_`s''`yend_`r''
        else if "`wscorr'"=="riley" {
            qui gen `covvar'`r'`s' = 0 // just to satisfy the pos def check
            local Svar_`r'_`s' `covvar'`r'`s'
        }
        else if "`wscorr'"!="" {
            qui gen `covvar'`r'`s' = `wscorr'*sqrt(`Sstub'`yend_`r''`yend_`r''*`Sstub'`yend_`s''`yend_`s'') if `touse'
            local Svar_`r'_`s' `covvar'`r'`s'
        }
        else {
            di as error "Neither `Sstub'`yend_`r''`yend_`s'' nor `Sstub'`yend_`s''`yend_`r'' found, and wscorr() not specified"
            exit 459
        }
        if "`wscorr'"!="" & `s'!=`r' {
            if (`oksr'|`okrs') & mi("`wscorrforce'") local wscorrunused 1
            else local wscorrused 1
        }
    }
}
if "`wscorr'"=="riley" & mi("`warnings'") {
    di as text "Note: using Riley's overall correlation model" _c
    if `wscorrunused' di " (ignoring covariances)" _c
    di
}
else if "`wscorr'"!="" & mi("`warnings'") {
    if `wscorrused' & `wscorrunused' di as text "Warning: " as result "wscorr(`wscorr')" as text " used for only some covariances"
    if !`wscorrused' & `wscorrunused' di as text "Warning: wscorr(" as result "`wscorr'" as text ") not used"
    if `wscorrused' & !`wscorrunused' di as text "Note: wscorr(" as result "`wscorr'" as text ") used for all covariances"
}

************* CONVERT VARIABLES TO MATRICES *************

tempname xi ymat Smat Xmat
local i 0
tempname bottom

* set up id as char
tempvar idstring
if mi("`id'") gen `idstring' = strofreal(_n)
else {
    cap confirm string var `id'
    if !_rc gen `idstring' = `id' // string
    else {
        if !mi("`: value label `id''") decode `id', gen(`idstring')
        else gen `idstring' = strofreal(`id')
    }
}
            
forvalues obs=1/`N' {
    if `touse'[`obs'] {
        local ++i
        mat `ymat'`i'=J(1,`p',0)
        local thisid = `idstring'[`obs'] // 20jul2015
        local identifier_text = cond(mi("`id'"),"observation ","")
        local identifier_result = cond(mi("`id'"),"`obs'", "`id'=`thisid'")
        mat rownames `ymat'`i' = "`thisid'"
        mat colnames `ymat'`i' = `ylist'
        mat `Smat'`i'=J(`p',`p',0)
        mat rownames `Smat'`i' = `ylist'
        mat roweq `Smat'`i' = "Study `i'"
        mat colnames `Smat'`i' = `ylist'
        forvalues r=1/`p' {
            mat `ymat'`i'[1,`r'] = `yvar_`r''[`obs']
            forvalues s=`r'/`p' {
                * FILL MATRIX OF (CO)VARIANCES
                * detect errors
                local misscase = 1*missing(`yvar_`r''[`obs']) + 2*missing(`yvar_`s''[`obs'])
                local missdesc1 as result "`yvar_`r''" as text " is"
                local missdesc2 as result "`yvar_`s''" as text " is"
                local missdesc3 as result "`yvar_`r''" as text " and " as result "`yvar_`s''" as text " are"
                if !`misscase' & missing(`Svar_`r'_`s''[`obs']) {
                    if `r'==`s' di as error "Error at `identifier_text'`identifier_result': var(`yvar_`r'') is missing but `yvar_`r'' is non-missing"
                    else di as error "Error at `identifier_text'`identifier_result': cov(`yvar_`r'',`yvar_`s'') is missing but `yvar_`r'' and `yvar_`s'' are non-missing"
                    global MVMETA_obserror `obs'
                    exit 459
                }
                if `misscase' & !missing(`Svar_`r'_`s''[`obs']) {
                    if `s'>`r' & mi("`warnings'") & "`Svar_`r'_`s''"!="`covvar'`r'`s'" ///
                        & "`wscorr'"!="riley" ///
                        di as text "Warning at `identifier_text'" as result "`identifier_result'" ///
                            as text ": " `missdesc`misscase'' ///
                            as text " missing, so I'm ignoring non-missing " ///
                            as result "`Svar_`r'_`s''"
                    if `s'==`r' & mi("`warnings'") ///
                        di as text "Warning at `identifier_text'" as result "`identifier_result'" ///
                        as text ": " as result "`yvar_`r''" ///
                        as text " is missing, so I'm ignoring non-missing " ///
                        as result "`Svar_`r'_`r''"
                }
                local Svalue = `Svar_`r'_`s''[`obs']
                if `r'==`s' & `Svalue'==0 {
                    di as error "Error at `identifier_text'`identifier_result': zero variance in `Sstub'`yend_`r''`yend_`s''"
                    global MVMETA_obserror `obs'
                    exit 459
                }
                mat `Smat'`i'[`r',`s']=`Svalue'
                mat `Smat'`i'[`s',`r']=`Svalue'
            }
        }
        * create X matrices for reml
        local Xrownames
        forvalues j=1/`p' {
            mkmat `xvars_`j'' `xcons' in `obs', matrix(`xi')
            mat colnames `xi' = `xvars_`j'' `xconsname'
            mat coleq `xi' = "`yvar_`j''" 
            if `j'==1 {
                mat `Xmat'`i'=`xi''
            }
            else if "`parmtype'"!="common" {
                local Xmatrows = rowsof(`Xmat'`i')
                local Xmatcols = colsof(`Xmat'`i')
                mat `Xmat'`i' = (`Xmat'`i', J(`Xmatrows',1,0))
                mat `bottom' = (J(rowsof(`xi''),`Xmatcols',0), `xi'')
                mat roweq `bottom' = "`yvar_`j''" 
                mat rownames `bottom' = `xvars_`j'' `xconsname'
                mat `Xmat'`i' = (`Xmat'`i' \ `bottom')
            }
            else mat `Xmat'`i' = (`Xmat'`i', `xi'')
            mat coleq `Xmat'`i' = "Study `i'"
        }
        mat colnames `Xmat'`i' = `ylist'
    }
}

************* AUGMENT AND CHECK VARIANCES *************

local i 0
forvalues obs=1/`N' {
    if `touse'[`obs'] {
        local ++i
        local thisid = `idstring'[`obs'] // 20jul2015
        local identifier_text = cond(mi("`id'"),"observation ","")
        local identifier_result = cond(mi("`id'"),"`obs'", "`id'=`thisid'")
        // OPTIONALLY AUGMENT MISSING VALUES IN MATRICES
        local augmented 0
        if "`augment'"=="augment" {
            forvalues r=1/`p' {
                forvalues s=`r'/`p' {
                    if (missing(`ymat'`i'[1,`r']) | missing(`ymat'`i'[1,`s'])) {
                        if `s'==`r' {
                            qui summ `Svar_`r'_`s'' if `touse'
                            local Svalue = `missvar'*r(max)
                            mat `Smat'`i'[`r',`s'] = `Svalue'
                            if "`augquiet'"=="" di as text "Note at `identifier_text'" as result "`identifier_result'" as text ": setting var(" as result "`yvar_`r''" as text ") to " as result `Svalue' as text " because " as result "`yvar_`r''" as text " is missing"
                        }
                        else {
                            if "`augquiet'"=="" di as text "Note at `identifier_text'" as result "`identifier_result'" as text ": setting cov(" as result "`yvar_`r''" as text "," as result "`yvar_`s''" as text ") to " as result "0" as text " because " as result "`yvar_`r''" as text " or " as result "`yvar_`s''" as text " is missing"
                            mat `Smat'`i'[`r',`s']=0
                            mat `Smat'`i'[`s',`r']=0
                        }
                        local augmented 1
                    }
                }
                if missing(`ymat'`i'[1,`r']) {
                    if "`augquiet'"=="" di as text ""Note at `identifier_text'" as result "`identifier_result'" as text": setting missing " as result "`yvar_`r''" as text " to " as result "`missest'"
                    mat `ymat'`i'[1,`r'] = `missest'
                    local augmented 1
                }
            }
        }
        // CHECK VAR-COV MATRICES ARE POSITIVE DEFINITE
        if `p'>1 & !matmissing(`Smat'`i') {
            cap varcheck `Smat'`i', check(psd) `psdcrit'
            if _rc==506 {
                if `augmented' di as error _new "Augmented v" _c
                else di as error _new "V" _c
                di as error "ariance-covariance matrix not positive semi-definite at `identifier_text'`identifier_result'"
                mat l `Smat'`i' // for some reason this is not printing
                if "`posdef'"=="" {
                    global MVMETA_obserror `obs'
                    exit 459
                }
                else di as text "Proceeding in the hope that estimation will work..."
            }
            else if _rc {
                di as error "Error in varcheck code"
                exit _rc
            }
        }
    }
}

if "`estimates'"!="noestimates" {

************* SET UP GLOBALS *************

* needed in all subroutines including mvmeta_bscov_*.ado, mvmeta_mufromsigma.ado, mvmeta_lmata.ado
local things things ystub Sstub ymat Smat Xmat p n N xcons bsest ylist yends parmtype wscorr 2pi bscovariance sigma0 sigma0exp touse fixedparms quick taulog id
forvalues r=1/`p' {
    local things `things' yvar_`r' xvars_`r' 
    forvalues s=`r'/`p' {
        local things `things' Svar_`r'_`s'
    }
}
foreach thing in `things' {
    global MVMETA_`thing' ``thing''
}

******* START ESTIMATION *********
tempname Sigma
local nparms_aux 0
local neqs_aux 0

******* FIXED-EFFECT METHOD *******
if "`bsest'"=="fixed" {
    tempname yhat
    mat `Sigma' = J(`p',`p',0)
    mvmeta_mufromsigma, sigma(`Sigma') yhat(`yhat') makeq `debug' // cap noi removed, 21jul2015
    if !_rc {
        local rl0 = r(rl) // ll0 is ll for FE model - needed for testsigma option
        local ll0 = r(ll)
        local Qscalar = r(Qscalar)
        local Qscalardf = r(sum_p)-`fixedparms'
        local return_scalar rl0 ll0 Qscalar Qscalardf 
    }
    local success = !missing(`Qscalar')
}

******** KNOWN-SIGMA METHOD - NEEDED??? *******
else if "`bscovariance'"=="equals" {
    mvmeta_mufromsigma, sigma(`sigma0')
    if "`bsest'"=="reml" local ll = r(rl)
    if "`bsest'"=="ml" local ll = r(ll)
    matrix `Sigma' = `sigma0'
    local return_scalar ll
    local success = !matmissing(`Sigma')
}

******* METHOD OF MOMENTS *******
else if inlist("`bsest'", "mm1", "mm2") {
    mvmeta_bscov_`bscovariance' if `touse', `bsest' `cholnames' `trunc' `mmfix' `debug'
    local success = !matmissing(r(Sigma))
    if `success' {
        if r(negevals)>0 {
            local plural = cond(r(negevals)>1,"s","")
            local thesehave = cond(r(negevals)>1,"these have","this has")
            di as text _new "Note: Sigma has " as result r(negevals) as text " negative eigenvalue`plural'" _c
            if "`trunc'"=="" di as text " - `thesehave' been set to 0"
            else di as text _newline "Note: negative eigenvalue`plural' may lead to problems - if so, drop the notrunc option"
        }
        mat `Sigma' = r(Sigma)
        mvmeta_mufromsigma, sigma(`Sigma')
        `ifdebug' mat l `Sigma', title(MM: Sigma)
        * next 4 lines were previously only for mm2
        tempname Qa Qb Q
        matrix `Qa' = r(Qa)
        matrix `Qb' = r(Qb)
        matrix `Q' = r(Q)
    }
}

***************** REML / ML *****************
else if inlist("`bsest'","reml","ml") {
    if "`bscovariance'"!="equals" {
        ***************** HANDLE SPECIFED COVARIANCE STRUCTURE *****************
        tempname init
        mvmeta_bscov_`bscovariance' if `touse', setup start(`start') `cholnames' 
        matrix `init' = r(init)
        local eqlist2 `r(eqlist)'
        local nvarparms `r(nvarparms)'
        local neqs_aux = `r(neqs_aux)'

        ***************** OPTIONALLY DISPLAY STARTING VALUES FOR Sigma *****************
        if "`showstart'"=="showstart" {
            di as text _newline "Starting value for beta's:" _c
            mat l r(binit), noheader
            di as text _newline "Starting value for Sigma (between-studies variance):" _c
            mat l r(Sigma), noheader
            if !mi("`debug'") {
                di as text _newline "All starting values:" _c
                mat l `init', noheader
            }
        }

        ****************** CREATE MEAN EQUATIONS ******************
        if "`parmtype'"=="long" { /* one equation per mean: "long parameterisation" */
            forvalues r=1/`p' {
                local eqlist1 `eqlist1' (`yvar_`r'': `xvars_`r'', `constant')
            }
        }
        else if "`parmtype'"=="short" { /* one equation comprising all means */
            local eqlist1 (Overall_mean:
            forvalues r=1/`p' {
                local eqlist1 `eqlist1' `yvar_`r''
            }
            local eqlist1 `eqlist1', nocons)
        }
        else if "`parmtype'"=="common" { /* common equation for each means */
            local eqlist1 (`yvar_1': `xvars_1', `constant')
        }

        * MODIFICATION FOR QUICK METHOD
        if "`quick'"=="quick" matrix `init' = `init'[1,(`fixedparms'+1)...]
        else local eqlist1a `eqlist1'

        ****************** MAXIMISE *****************
        `ifdebug' di as text "*** starting to maximise ..."
          /* collinear option makes the short parameterisation work even when some b's are collinear */
          /* neq(`p') fails here, not sure why */
        local mlcommand ml model d0 mvmeta_lmata `eqlist1a' `eqlist2' if `touse', ///
            obs(`n') collinear init(`init', copy) maximize nooutput `mlopts' ///
            `iterate' nopreserve missing `log' `constraints'
        `ifdebug' di as input `"`mlcommand'"'
        `mlcommand'
        `ifdebug' di as text "*** maximisation is finished ..."
        **************** FINISH OFF FOR QUICK METHOD ***************
        if "`quick'"=="quick" {
            mvmeta_bscov_`bscovariance' if `touse', postfit `cholnames' 
            mat `Sigma'=r(Sigma)
            global MVMETA_quick // not needed?
            tempname varparms
            mat `init'=e(b)
            mvmeta_mufromsigma, sigma(`Sigma')
            `ifdebug' di as text "Results not allowing for uncertain Sigma..."
            `ifdebug' ereturn display, `cformat' `pformat' `sformat'
            mat `init'=(e(b),`init')
            `ifdebug' mat l `init', title(Starting values for 2nd -ml- run)
            `ifdebug' di as text "Estimating variance allowing for uncertain Sigma..."
            qui ml model d0 mvmeta_lmata `eqlist1' `eqlist2' if `touse', obs(`n') collinear init(`init') 
            maximize nooutput `mlopts' nopreserve missing `log' iterate(0) `constraints'
        }
        local success = e(converged)
    }
    ****************** COMPUTE Sigma *****************
    mvmeta_bscov_`bscovariance' if `touse', postfit `cholnames' 
    mat `Sigma'=r(Sigma)
    local nparms_aux = r(nparms_aux)
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local Sigma`s'`r' `r(Sigma`s'`r')'
        }
    }
    **************** ERETURN FOR BOTH METHODS ***************
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local return_local `return_local' Sigma`s'`r'
        }
    }
}

************ ERETURN RESULTS AND TIDY UP ***************

foreach thing in `things' {
    global MVMETA_`thing'
}

* nparms_* refers to numbers of parameters
* neqs_* refers to numbers of equations
tempname b V
mat `b'= e(b)
mat `V'= e(V)
local nparms_mean = colsof(`b') - `nparms_aux'
local neqs_mean = cond("`parmtype'"=="long",`p',1)
local k_eform = `neqs_mean' // system name picked up by _coef_table in Replay

} // noestimates resumes here

* make combined data matrices
tempname ydata Sdata Xdata
forvalues i=1/`n' {
    mat `ydata' = nullmat(`ydata') \ `ymat'`i'
    mat `Sdata' = nullmat(`Sdata') \ `Smat'`i'
    mat `Xdata' = nullmat(`Xdata') \ `Xmat'`i'' // NB transpose
}

local return_scalar `return_scalar' neqs_mean neqs_aux nparms_mean nparms_aux k_eform fixedparms success
foreach thing of local return_scalar {
    if "``thing''"!="" {
        return scalar `thing' = ``thing''
        local scalarlist `scalarlist' `thing'
    }
}
return local scalarlist `scalarlist'

local return_matrix Sigma Q Qa Qb b V ydata Sdata Xdata
foreach thing of local return_matrix {
    cap confirm matrix ``thing''
    if !_rc {
        return matrix `thing' = ``thing''
        local matrixlist `matrixlist' `thing'
    }
}
return local matrixlist `matrixlist'

foreach thing of local return_local {
    if "``thing''"!="" {
        return local `thing' ``thing''
        local locallist `locallist' `thing'
    }
}
return local locallist `locallist'

`ifdebug' di as input "End of mvmeta_estimate"
end

*=========================== END OF MVMETA_ESTIMATE PROGRAM ===========================

*====================== VARCHECK PROGRAM (FOR MVMETA_ESTIMATE) ========================

program define varcheck
syntax anything, [check(string) psdcrit(real 1E-8)]
_getcovcorr `anything'
if "`check'"!="" {
    tempname evecs evals
    mat symeigen `evecs' `evals' = `anything'
    local dim = colsof(`evals')
    local maxeigen = `evals'[1,1]
    local mineigen = `evals'[1,`dim']
    if "`check'"=="psd" {
        if `maxeigen'<=0 | `mineigen'/`maxeigen' < -`psdcrit' {
            di as error "`anything' is not positive semi-definite"
            exit 506
        }
    }
    else if "`check'"=="pd" {
        if `maxeigen'<=0 | `mineigen'/`maxeigen'<=0 {
            di as error "`anything' is not positive definite"
            exit 506
        }
    }
    else {
        di as error "varcheck: check(`check') invalid"
        exit 497
    }
}
end

*=========================== END OF VARCHECK PROGRAM ==========================

*=========================== START OF MVMETA_GETDATA PROGRAM ===========================

/*
Reads in data from e(ydata), e(Sdata)
Estimation results are appended and are flagged by variable `type'
Options nouv, nomv suppress this
*/
program define mvmeta_getdata
syntax namelist, type(name) [corr nouv nomv STUDylabel(string) UVLABel(string) MVLABel(string) wt]
if mi("`studylabel'") local studylabel "Studies"
if mi("`uvlabel'") local uvlabel "Pooled uv"
if mi("`mvlabel'") local mvlabel "Pooled mv"

drop _all
tempname ydata y Sdata S value 
mat `ydata' = e(ydata)
mat `Sdata' = e(Sdata)
if !mi("`wt'") {
    tempname wtdata
    mat `wtdata' = e(wt)
    mat coleq `wtdata' = ""
}
local newobs = e(N) + 2
qui set obs `newobs'
qui gen _id = ""
qui gen `type' = ""
foreach var in `namelist' {
    qui gen `var' = .
    qui gen se_`var' = .
    if !mi("`wt'") qui gen wt_`var' = .
    if !mi("`corr'") {
        foreach var2 in `namelist' {
            if "`var2'" <= "`var'" continue
            qui gen corr_`var'_`var2' = .
        }
    }
}
forvalues i=1/`newobs' {
    if `i'<=e(N) {
        local first = e(dims)*(`i'-1)+1
        local last = e(dims)*`i'
        mat `y' = `ydata'[`i',1...]
        local studyname : rowname `y'
        qui replace _id = "`studyname'" in `i'
        mat `S' = `Sdata'[`first'..`last',1...]
        mat roweq `S' = ""
        qui replace `type' = "`studylabel'" in `i'
    }
    if `i'==e(N)+1 { // uv estimate
        if !mi("`uv'") continue
        mat `y' = e(b_uv)
        mat `S' = e(V_uv)
        qui replace `type' = "`uvlabel'" in `i'
    }  
    if `i'==e(N)+2 { // mv estimate
        if !mi("`mv'") continue
        mat `y' = e(b)
        mat `S' = e(V)
        qui replace `type' = "`mvlabel'" in `i'
    }           
    if `i'>e(N) {
        mat coleq `y' = ""
        mat coleq `S' = ""
        mat roweq `S' = ""
    }
    foreach var in `namelist' {
        mat `value' = `y'[1,"`var'"]
        qui replace `var' = `value'[1,1] in `i'
        mat `value' = `S'["`var'","`var'"]
        qui replace se_`var' = sqrt(`value'[1,1]) in `i'
        if `i'<=e(N) & !mi("`wt'") {
            mat `value' = `wtdata'[`i',"`var'"] 
            qui replace wt_`var' = `value'[1,1] in `i'
        }
        if !mi("`corr'") {
            foreach var2 in `namelist' {
                if "`var2'">="`var'" continue
                mat `value' = `S'["`var'","`var2'"]
                qui replace corr_`var2'_`var' = `value'[1,1] / (se_`var'*se_`var2') in `i'
            }
        }
    }
}
if !mi("`mv'") qui drop if _n==e(N)+2
if !mi("`uv'") qui drop if _n==e(N)+1
    
end

*=========================== END OF MVMETA_GETDATA PROGRAM ===========================

*======================= START OF MATA ROUTINE FOR RANDFIX ====================
mata:
void selectpart(string scalar cname,
                string scalar Vinname,
                string scalar Voutname
)
{
    c=st_matrix(cname)
    V=st_matrix(Vinname)
    Vpart = select(V,c')
    Vpart = select(Vpart,c)
    st_matrix(Voutname,Vpart)
}
end
*======================= END OF MATA ROUTINE FOR RANDFIX ====================

/******************************************************************************

HISTORY OF VERSIONS 1 & 2
version 2.14  Ian White  1apr2015
    data, uv estimates and fixed estimates all returned as e()
version 2.13.1  Ian White  27mar2015
    removed noestimates from forest & bubble calls
version 2.13  Ian White  14mar2015
    randfix - improved re-call to mvmeta; without arguments defaults to all y's
    pbest - new mcse suboption; checks for non-missing covariates; add isid check;
		bug fix - rename() got confused if new names intersected with old names
    help file:
        specifies bscov(exch 0.5) as an option in the covariances list.
        now advises against -augment- option with wscorr()
        randfix, nowt and wt documented
    fixed bugs:
        with if/in, gave warning about dropping the observations not satisfying if/in
        eform option worked on replay but not on initial call
        improved error message "Error: yb and yc have no jointly observed values" in sparse NMA with bscov(uns)
    12mar2015: copes with only one observation and meta-regression
    13mar2015: bug fix in mvmeta_makecovs: if one name contains another, covariance is wrongly found
    13mar2015: equations(yvarlist:...) now allowed; printing of equations improved
	14mar2015: bscov(prop|eq|corr) checks correct dimension of matrix
version 2.12 10feb2015
    weights and bos automatically reported unless nowt specified [how to get formats in?]
    new id option: passed to wt() pbest() and forest()
    new option wt replaces old bos with suboptions:
        sd - score decomposition method (default) ) use
        rv - relative variance method ) one of
        dpc - data-point coefficients ) these
        details - more info for SD & RV
        clear - saves details (with sd details)
        format - for tables
        gen() - generates variables for weights (with sd)
        keepmat() - creates matrices
        id() - id for output
    smaller: recoded eform[()] using eform eform2()
    noestimates (replaces dryrun) allowed in Estimate: it proceeds to end but doesn't set e(bsest); Replay picks this up and suppresses estimates & weights.
version 2.11.3 2feb2015
    add row equation names to X matrices
version 2.11.2 22dec2014
    bos option is now a revised subroutine
		borrow option removed: now use bos(rv)
	keepmat for X: improved rowname for constant
	forest option also available as a subroutine
version 2.11.1 19dec2014
    wscorrforce option makes wscorr() override existing corrs
        (useful for mvmeta_runuv and mvmeta_forest)
version 2.11 9dec2014
    bug fixed - observations with missing covariates were deleted, even if outcome was also missing
    now also gives warning when observations are deleted due to missing covariates
version 2.10.1 8sep2014
    bscov(exch #) gives correct description from line 504
    new suboption: pbest(, tabdispoptions())
version 2.10.0 29jul2014
    rename suboption for pbest
version 2.9 10jun2014
    drops variables `y'* if no non-missing data
    new bscovariance(exch #) - designed for network meta where variables may be dropped
version 2.8.2 6jun2014
    bug fix in pbest
version 2.8.1 30may2014
    Commonparm note "The above coefficients also apply to the following equations" suppressed in only 1 equation
version 2.8 15may2014
    Changes to pbest:
        moved to separate program and restructured; new suboption clear
        implemented Aurelio Tobias' graphs: new suboptions bar, line, cum, graph_options
version 2.7.3 6feb2014
	bug fix - bos and borrow work together (NB new options need to be inserted carefully)
	bos works for incomplete data (by simple augmentation)
version 2.7.2 5feb2014
    bug fix - bos works after wscorr() - fixed by new e(wscorr) (replaces e(wscorrtype))
    bos corrected to work after wscorr(riley)
version 2.7.1 3feb2014 (on BSU website)
	fixed bug which limited length of e(xvars_*) if run in v12
version 2.7 27jan2014
    Changes to incorporate new bos option:
        bos has optional suboptions
    new dryrun option
version 2.6 3jan2014 (on BSU website)
    Changes for consistency with network.ado:
        pbest fails with parmtype=common: better error message
        new undocumented network option identifies calls from -network-
        new stripprefix and zeroname suboptions for pbest
    pbest(,reps(1000)) now default
version 2.5.6 20jul2013
    added standard options: cformat pformat sformat
version 2.5.5 21mar2013 - ON BSU WEBSITE
    Anna Chaimani's fix to bug that made pbest fail with >10 treatments
version 2.5.4 20mar2013 - ON BSU WEBSITE
    New saving() suboption on pbest
version 2.5.3 6mar2013
    Corrected showall again
version 2.5.2 28aug2012
    tries to continue even if fixed-effect method fails
version 2.5.1 2jul2012
    corrected small bug in pbest(,gen())
version 2.5 7jun2012
    Renamed ereturned parameters more systematically as nparms_* and neqs_*
    Corrected showall
    eform option disabled with showall and parmtype long - previously only the 1st eq was exponentiated.
        The problem here is that e(k_eform) must be set to get correct eform behaviour, but it is lost when Replay posts new estimation results, which it must do to use dof() option; and Replay isn't eclass so can't re-set e(k_eform)
version 2.4.2 1feb2012 - ON BSU WEBSITE
    "Warning: method of moments failed - I2 statistic not available" not now in red: it worried users unnecessarily
    Notes on variables not jointly observed now appear only for bscov(uns)
    Formatting of output notes improved
    Clearer error message if randfix() specifies variables that aren't outcome variables
    fixed bug making borrow fail if randfix() was also specified
version 2.4.1 13jan2012
    abbreviation common for commonparm
version 2.4 20dec2011
    new commonparm option which forces same coeffs in each equation
    mvmeta syntax unchanged but global storage changed:
        MVMETA_longparm is now conveyed by MVMETA_parmtype = long/short/common
version 2.3.4 20dec2011
    new constraints option for constrained maximisation
    new all option for pbest reports all ranks, not just the best
    new collinear option suppresses check for collinearity - use with care!
version 2.3.3 15nov2011
    new mm2 option (undocumented)
version 2.3.2 15jun2011
    new mmfix option sets unestimated off-diagonal Sigma terms to 0
version 2.3.1 15jun2011
    tidied up output: displays either yvarlist or regressions, not both
    fixed now implies nojointcheck
    jointcheck flags error/warning with 0/1 jointly observed value (was 0 only)
version 2.3.0 2jun2011
    same as version 2.3 but with borrow, randfix and qscalari removed
    PUBLISHED WITH SJ 2011;11:255--270
version 2.3 31may2011 - ON BSU WEBSITE
    corrected the constant terms in log L and log RL, as suggested by Antonio Gasparrini: affects L/RL (only) in models with missing outcomes and models with covariates
    i2: when a variance expression is shortened due to zero parameters in the cholesky decomposition, the shorter expression is now carried forward to compute the correlations (avoids failure)
version 2.2 6may2011
    pbest has new suboption predict, giving prediction (for new study) not estimation (of overall mean)
    clearer error when pbest is called after fitting with parmtype=short
    i2 refuses when e(Q) etc. weren't set
    no checks of jointly observed data with bscov(eq|prop)
    iterate(#) no longer fails with quick option
    new bscov(CORRelation <matrix>)
version 2.1.3 24mar2011 -borrow- output clarifies it compares squared std errors
version 2.1.2 10mar2011
    fixed bug in i2 without -heterogi-: negative i2 wasn't truncated.
    output tables widen to accommodate long variable names
    fixed bug in randfix: failed after if/in
version 2.1.1 8mar2011
    corrected borrow option with bscov(equals ..)
    testsigma now divides P-values by 2 if LRT>0.
    Should Sigma0 be stored??
version 2.1 26feb2011
    new options: Borrow Randfix(varlist) Qscalar
    eqnames in e(b) and e(V) after fixed/mm now match those after ml/reml
    dropped e(yends), e(xvars)
    new e(cmdline), e(ystub), e(Sstub), etc.
version 2.0.5 8mar2011
    same as version 2.1.1 but with borrow, randfix and qscalar removed - resubmitted to SJ
version 2.0.4 1feb2011
    added drawbeta.ado into this file
    mvmeta_mufromsigma gives useful error message with unidentified model
    collinearity check is now performed in the subset with observed outcome
version 2.0.3 19jan2011
    corrected minor bug in mvmeta_mufromsigma that truncated equation names if name lengths totalled >256 characeters
version 2.0.2 6dec2010 enabled ncchi2 option to pass to -heterogi-
version 2.0.1 i2 output changed from "yB/yC" to "yB & yC"
    testsigma option added
named version 2.0 14oct2010
version 1.10 14oct2010
    best renamed pbest
version 1.9 8sep2010
    -corr(riley) mm- now fails; previously ran as -corr(0) mm-
    MM moved to covariance files
    covariance files don't require p()
    corr() renamed as wscorr() (but undocumented corr() still works)
    bscov|bscorr changed to print(bscov|bscorr)
    covariance() renamed to bscovariance()
    e(Sigma11) etc. now includes zero terms, so se and i2 can give funny results
    new undocumented noestimates option (suppresses coeff table)
    se moved within i2 option, and table reformatted
    i2 option:
        tau^2 and I^2 have their CIs computed on the same scale
        new ciscale(SD|logSD|logH) option determines which scale this is
        new i2fmt option formats I^2
    new undocumented nojointcheck option suppresses check for jointly observed values
version 1.8.2 18aug2010
    fixed bug in Replay call that ignored nouncertainv on estimation run
version 1.8.1 2aug2010
    fixed bug in local ylist0 arising with long variable list (thanks to Stephen Kaptoge)
version 1.8 29jun2010
    CI for I2:
        reml/ml: improve by computing it on scale of log(H)=-0.5*log(1-I^2)
        fixed/mm: implemented by a call to -heterogi-
    CI for between-studies SD (on log scale) and correlation (on Fisher's transformation scale)
    undocumented quick option (re/ml): mu estimated from sigma using closed form expression within loglik routine, not as separate parameters
    tidied up se output
version 1.7.1 3jun2010
    drops any observations with all missing outcomes
version 1.7 27may2010
    Allow structured variance matrices: new option covariance() to echo -xtmixed- syntax. Can have:
        covariance(unstructured)
        covariance(proportional matrixname)
    New loglik and mufromsigma routines handle missing data
        - matrices are augmented only with new augment option
        - positive definite check now restricted to fully non-missing variance matrices
    Only uses mata routine for loglik
    Some improved error messages
    bscorr - correlations changed to . above diagonal
    Internal changes: new external files
        mvmeta1_mufromsigma.ado (now using mata)
        mvmeta1_covariance_unstructured.ado
        mvmeta1_covariance_proportional.ado
version 1.6.1 26mar2010
    _coef_table version 1.2.5 fails, 3.0.0 works. Changed to use _coef_table only when needed (i.e. withoptions eform and showchol) and to revert to -ereturn display- if necessary
version 1.6 4jan2010
    corr(riley) option
    NB this is the last version named mvmeta1
version 1.5.2 18nov2009
    missing option added to ml command - previously gave wrong results with missing estimates
version 1.5.1 18nov2009
    fixed se option again (!) - instead of ignoring terms < a fixed value, it ignores terms that make nlcom crash
    new undocumented selist option shows what se is calculating - may be useful for doing more extended nlcom
version 1.5 9oct2009
    extensively tidied up code
    nopreserve option on ml
    dof(string) option
    se option fixed
    new i2 option
    new mata option uses new mvmeta1_lmata.ado - 2-5 times faster?
version 1.4 29sep2009
    re-written as Estimate and Replay
    non-interactive -ml-
    allows all standard maximization options (via -mlopts-)
version 1.3 25-29sep2009 (Stephen K's suggestions)
    deleted -preserve- command at start of setup - e(sample) is now correct
    obs with incomplete covariates dropped
    corrected reml expression with unequal equations (eq() option)
    fixed bug that caused crash with long variable names (cholesky equation names could be over 32 characters): cholesky parameters are now named 11,12 etc unless new cholnames is used
version 1.2 11aug2009
    maximizeoptions() replaces trace difficult iterate()
version 1.1 10aug2009
    eform correctly implemented
    Ignores eform option if long parameterisation is used without covariates
    redisplays results if typed without arguments!
    output now occurs in same place in program for all methods (incl. redisplay)
    new noposdef option allows non-positive-semidefinite var/cov matrices
    criterion for pos semidef changed from min eval<0 to min/max<-1E-8 (can change with new psdcrit() option)
    allows separate regressions via equations() option
    the only maximize options allowed are difficult iterate()
version 1.0 12jun2009
    allows covariates in reml/ml
    new noconstant option
    start defaults to mm
    program no longer returns e(Mu)

/******************************************************************************

