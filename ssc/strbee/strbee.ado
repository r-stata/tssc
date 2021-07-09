*! version 1.8.7   Ian White   12feb2018

/*************************** NOTES ********************************
version 1.8.7   12feb2018
	undocumented changes:
		allow kmgraph(show(#...)) to control which curves are graphed
		allow hr(x x) to control which curves are compared
			where x=fully|observed|untreated or abbreviation
version 1.8.6   17jan2018
	kmgraph() and zgraph() fixed to allow quotes
version 1.8.5   27mar2017
	no changes to code; small changes to help file; posted on SSC
version 1.8.4   22apr2016 (on website)
	kmgraph greatly expanded to improve patterns and colours
version 1.8.3   31mar2016 (on website)
	kmgraph(showall) shows all 6 graphs
	kmgraph(untreated) shows just the untreated counterfactual graphs
	fixed bug in hr, kmgraph and gen() options with ton()/toff() syntax
	experimental psimult() option
	corrected correction made in v1.8.1
version 1.8.2   24mar2016
    near-zero values of psi rounded to zero
        solves the "ITT P-value not found" problem which occurred e.g. with options psimin(-1) psimax(0) psistep(0.01) 
version 1.8.1   22mar2016 (on beta website)
    corrected error in ipe+weibull (used log HR not log TR)
version 1.8      6mar2014 (on beta website 16jun2015)
    new syntax using ton and/or toff
    suboptions to improve the recensoring such as ton(var, max0(1) min1(0.1))
		- these replace mincens
    more tests - all options for either -sts test- or -streg-
version 1.7.2   17dec2013
    minor changes to help file and documentation
version 1.7.1   1oct2013
    spots if current directory is not writeable & gives helpful error message
    also split parsing from data checking section
version 1.7   20-21sep2012
    Program crashed if no events after recensoring: now if no events it directly sets Z missing.
    Behaviour after Z=. in stages 1 and 2: before it shifted psi and entered an endless loop; now it moves to next stage
    New mincens option assumes that switching cannot occur before minimum observed switching times when computing the recensoring time as the minimum over all possible treatment history - potentially yields less recensoring
    Hr option:
        now uses strata() option if specified
        if counterfactual is very close to observed, they are set exactly equal - this makes unadjusted and adjusted HR agree exactly
    Trace & debug output improved 
    Renumbered stages
version 1.6   21may2012
    new strata() option
    adjvars and strata in output
    corrected bug that stopped test(cox) and test(other_sts_option) working
version 1.5.5   21may2012
version 1.5.4   7feb2012
    corrected level() option to allow level(99.9) etc.
version 1.5.3   31jan2012
    warns if xo0, xo1 options appear to have timevar eventvar instead of eventvar timevar
version 1.5.2   27jan2012
    corrected naming of gen() variables
    improved their description in the help file
version 1.5.1   31oct2011
    minor tidying up; help file up to date.
version 1.5     14oct2011
    savedta defaults to _strbee_savedta
    new replay ability (except after IPE)
    new zgraph option (graph still works)
    zgraph now uses up-to-date graphics; graph options updated; symbol replaced with msymbol
    kmgraph() and zgraph() now take (graph) options 
    results only tabulated in replay stage
    hr works at replay stage - risky as data mustn't have changed! 
    program separated into estimate (creates the "savedta" results file) and output (returns r())
version 1.4.1   30sep2011
    new ipestore option stores last regression under IPE
version 1.4 26aug2011
    trace option no longer saves data (can do the same with gen)
    data not changed in program - preserve only used when psi-Z results are loaded
    new hr option
    output made neater
    better behaviour with increasing Z vs psi graph - suggests back-to-front treatment
version 1.3.1 25aug2011
    upgrade to Stata 10
    psimin and psimax are pushed out to +/-10 if necessary
    preserve moved to top (handles program crash)
    new psistart() option with ipe
    general clean-up
    makeu subroutine used - now gen works
    corrected error with XO times > T
    corrected small bug: program could change type of _t
version 1.2.5 24aug2011
    added warning that ipe se & CI are too small
version 1.2.4 19may2011
    moved preserve from top so that gen() works - but not fully tested!
version 1.2.3 24mar2011
    allow adjustment for covariates using adjvars(varlist)
    postfile label is a tempname
    tidied up output a little
version 1.2.2  6aug2010
    correct sign of wilcoxon test
version 1.2.1 11dec2002
    correct label of Z in output data
version 1.2  9 May 2002
    upgrade to version 7
    gen() option
    maxiter(#) option for ipe
    correct results when Z=. at bounds
version 1.1   12feb2002 
    trace option outputs recensored events as well as subjects
    allow savedta(x,replace) even if x doesn't exist
    new option noci (useful with trace for rbeetrace.dta)
    store results in char() not globals
version 1.0   5 December 2000

Certification script: H:\trtchg\strbee\update2011\strbee_cscript.do

******************************************************************/

********************* WRAPPER PROGRAM **********************

* options without arguments get "run" as argument
program define strbee, 
version 10
syntax [anything] [if] [in] [using], [ZGRaph GRaph KMgraph debug HR *]
foreach opt in zgraph graph kmgraph hr {
    if `"``opt''"' != "" local options `opt'(run) `options'
}
local options `options' `debug'

if "`anything'"=="" local cmd Output `anything' `if' `in' `using', `options'
else local cmd Gestimate `anything' `if' `in', `options'

if "`debug'"=="debug" {
    if "`using'"=="" di as text "Estimation and output syntax"
    else di as text "Output syntax"
    di as input `"`cmd'"'
}
`cmd'
end

********************* START OF G-ESTIMATE PROGRAM **********************

program define Gestimate

********************* PARSING **********************
syntax varlist(max=1) [if] [in], [                   ///
    xo0(string) xo1(string) ton(string) toff(string) /// model options
    ENDstudy(varname) psimult(string)                /// alternative to xo*
    TEst(string) ADJvars(varlist) STrata(varlist)    /// estimator options
	ipe ipecens                                      /// estimator options
    psimin(real -10) psimax(real 10) psistep(real 0) /// search options
    tol(int 3) noci level(cilevel)                   /// search options
    trace psistart(real 0) maxiter(int 100)          /// search options
    SAVEdta(string) IPESTore(string)                 /// storage options
    debug noOUTput                                   /// undocumented options
    *]

local zcrit = invnorm(1-(100-`level')/200)
if "`strata'"!="" local strataopt strata(`strata')
local treat `varlist'
local Gestimateoptions `options'

* SORT OUT SAVE FILE
if "`savedta'"~="" {
    tokenize "`savedta'", parse(",")
    if "`3'"=="append" local append append
    else if "`3'"=="replace" local replace replace
    else if "`3'"~="" {
        di as error "savedta(`savedta') not allowed"
        exit 498
    }
    local savedta `1'
    tokenize "`savedta'", parse(".")
    if "`3'"=="" local savedta `1'.dta
    if "`append'"=="append" confirm file `savedta'
    else if "`replace'"=="replace" {
        cap confirm file `savedta'
        if _rc>0 {
            di as error "Warning: file `savedta' not found"
            local replace
        }
    }
}
else {
    local savedta _strbee_savedta
    cap confirm file `savedta'
    if _rc==0 local replace replace
}
local new = cond(mi("`append'`replace'"),"new","")
cap noi confirm `new' file `savedta'
if _rc==603 di as error "   (you may not have write-access to your current directory `c(pwd)')"
if _rc exit _rc

* PARSE TEST
if "`test'"=="" {
    if "`ipe'"=="" local test logrank
    else local test weibull
}
if "`test'"=="cox" local test stcox
parsetest, `test'
local test = r(test)
local testtype = r(testtype)
if "`ipe'"=="ipe" & !inlist("`test'","exponential","weibull") {
    di as error "Only test(exponential|weibull) is allowed with IPE option"
    exit 498
}
if "`testtype'"=="sts_test" & !mi("`adjvars'") {
    di as error "adjvars(`adjvars') ignored with test(`test')"
    local adjvars
}

* STORE METHODS
if "`ipe'"=="ipe" {
    local method Branson's IPE
    local search Branson's IPE
}
else {
    local method Robins-Tsiatis method
    if `psistep'==0 local search interval bisection
    else local search grid search
    local ipe noipe
}
if "`ipecens'"=="" local ipecens noipecens
if "`trace'"=="" local trace notrace

* CHECK VARIABLES EXIST
confirm var `treat' `endstudy' `xo0' `xo1'

* CHECK OTHER OPTIONS
if "`gen'"~="" confirm new var `gen' d`gen'
if `psistep' != 0 & `psistep' <= epsfloat() di as error "Warning: psistep is dangerously small"
if !mi("`psimult'") {
	cap assert `psimult'>=0 
	if _rc di as error "Error in psimult(`psimult') option: must be non-negative"
	if _rc exit 498
	cap assert !mi("`psimult'")
	if _rc di as error "Error in psimult(`psimult') option: must be non-missing"
	if _rc exit 498
	local psimultopt psimult(`psimult')
}

* WHICH SYNTAX - xo0() xo1() OR ton() toff()
if !mi("`ton'`toff'") & !mi("`xo0'`xo1'") {
    di as error "Error: can't combine xo0() xo1() with ton() toff()"
    exit 198
}
local tsyntax = !mi("`ton'`toff'") // 1 for ton toff, 0 for xo0 xo1

********************* CHECK DATA **********************

* CHECK ST DATA
st_is 2 analysis
cap assert _t0==0
if _rc>0 {
    di as error "Sorry, data must be stset with 1 record per subject and _t0=0"
    exit 498
}

* CHECK CENSORING
cap assert _d==1
if _rc>0 & "`endstudy'"=="" noi di as error "Warning: you have censored data - specify endstudy() to avoid bias"

************ END OF CHECKING SYNTAX AND DATA. START OF ANALYSIS ******************

preserve

* SET UP POSTFILE: TEMPORARILY STORE RESULTS IN `results'
tempfile results
tempname postname
if "`ipe'"=="ipe" local ipepostvars psise stage
qui postfile `postname' psi Z `ipepostvars' using `results', replace double

qui {

    * SELECT RECORDS
    tempvar touse
    mark `touse' `if' `in'
    markout `touse' `varlist'
    keep if `touse' & _st
    drop `touse'
    
    * CHECK TREATMENT VARIABLE
    summ `treat'
    local error = r(min)~=0|r(max)~=1
    count if `treat'~=0 & `treat'~=1
    if r(N)>0 | `error'==1 {
        di as error "`treat' is not a 0/1 variable"
        exit 498
    }

    * INITIALISE COUNTERFACTUALS
    tempvar t dt u du
    local type : type _t
    gen `type' `t' = _t      /* this is needed as `u' gets stset later */
    gen  byte `dt' = _d
    gen double `u' = .
    gen  byte `du' = .
    label var `t' "t"
    label var `dt' "dt"
    label var `u' "u, created by strbee"
    label var `du' "du, created by strbee"
    if "`endstudy'"!="" {
        tempvar recens 
        gen double `recens'=.
        label var `recens' "recensoring time, created by strbee"
    }
    else local endstudy .
    tempvar isrecens
    gen byte `isrecens'=.
    label var `isrecens' "whether recensored, created by strbee"

    * COUNT
    forvalues i = 0/1 {
        count if `treat'==`i'
        local n`i' = r(N)
        count if `treat'==`i' & _d
        local d`i' = r(N)
    }
    
    * IF XO SYNTAX: CHECK SWITCH VARIABLES AND CONVERT TO TON/TOFF
    tempvar toffvar tonvar 
    if `tsyntax'==0 {           // xo0 xo1 syntax 
        * CONVERT XO'S TO TON, TOFF
        maketonoff, t(`t') treat(`treat') toff(`toffvar') ton(`tonvar') xo0(`xo0') xo1(`xo1') 
    }
    else {                      // ton toff syntax
        local 0 `ton'
        syntax [anything], [max0(string) max1(string) min0(string) min1(string)]
        if !mi("`anything'") local tonexp `anything'
        foreach opt in max0 max1 min0 min1 {
            local ton`opt' ``opt''
        }
        local 0 `toff'
        syntax [anything], [max0(string) max1(string) min0(string) min1(string)]
        if !mi("`anything'") local toffexp `anything'
        foreach opt in max0 max1 min0 min1 {
            local toff`opt' ``opt''
        }
        if mi("`tonexp'") {
            if mi("`toffexp'") {
                di as error "Must specify tonexp or toffexp"
                exit 198
            }
            gen double `toffvar' = `toffexp'
            gen double `tonvar' = _t - `toffvar'
        }
        else {
            gen double `tonvar' = `tonexp'
            if !mi("`toffexp'") {
                cap assert abs(((`toffexp') + (`tonexp') - _t ) / _t) < epsfloat()
                if _rc di as error "`toffexp' and `tonexp' do not sum to _t"
                gen double `toffvar' = `toffexp'
            }
            else gen double `toffvar' = _t - `tonvar'
        }
    }

    * SUMMARISE SWITCHES
    count if `treat'==0 & `tonvar'>0
    local nxo0 = r(N)
    count if `treat'==1 & `toffvar'>0
    local nxo1 = r(N)

    * EFFICIENT RECENSORING OPTIONS: CASE OF NO SWITCH IN ONE ARM
    if `tsyntax'==0 {
        if mi("`xo0'") local tonmax0 0 // no xo in arm 0
        if mi("`xo1'") local toffmax1 0 // no xo in arm 1
    }
    else {
        cap assert `tonvar'==0 if `treat'==0
        if !_rc local tonmax0 0 // no xo in arm 0
        cap assert `toffvar'==0 if `treat'==1
        if !_rc local toffmax1 0 // no xo in arm 1
    }

    * EFFICIENT RECENSORING OPTIONS: USER-SPECIFIED
    foreach opt in toffmin0 toffmin1 tonmin0 tonmin1 {
        if !mi("``opt''") local recensopts `recensopts' `opt'(``opt'')
    }
    foreach opt in toffmax0 toffmax1 tonmax0 tonmax1 {
        if !mi("``opt''") local recensopts `recensopts' `opt'(``opt'')
    }
    * `recensopts' is passed to makeu

    * SET UP LOOP
    if (`psimin' >= `psimax') {
      di as error "psimin must be < psimax"
      exit 498
    }
    if `psistep' > 0 local stage 4      /* 4=grid-searching */
    else local stage 1                  /* 1=starting/looking for lower bound, 
                                           2=looking for upper bound, 
                                           3=found bounds and searching for solutions, 
                                           9=stop */
    if "`ipe'"=="ipe" local psi `psistart'  // IPE
    else if `psistep' == 0 local psi 0      // Bisection
    else local psi `psimin'                 // Grid search
    local estlo = .
    local esthi = .
    local lowlo = .
    local lowhi = .
    local upplo = .
    local upphi = .
    local iter 0
    local oldstage .

    noi di as text "Searching by `search'" _c
    if "`trace'"=="trace" & "`endstudy'"!="." { // PRINT TOTAL NUMBERS
        noi di _new as text "Total in arm 0/1: " _col(32) as result `n0' as text "/" as result `n1' as text " subjects" _c
        noi di as text " (" as result `d0' as text "/" as result `d1' as text " events)"
        foreach var in n0 n1 d0 d1 {
            local l`var' = length("``var''")
        }
    }
    else if "`trace'"=="trace" | "`debug'"=="debug" noi di
    
    ****** START LOOP ******
    
    while `stage' ~= 9 {
        local ++iter
        if "`trace'"=="trace" | "`debug'"=="debug" {
            if `stage'!=`oldstage' & "`ipe'"=="" noi di as text "Starting stage `stage'"
            noi di as text "psi = " as result %10.7g `psi' " " _c
        }
        local oldstage `stage'
        
        * GENERATE U, DU
        noi makeu, u(`u') du(`du') t(`t') dt(`dt') treat(`treat') psi(`psi') `psimultopt' ///
            toff(`toffvar') ton(`tonvar') `recensopts' `ipe' `ipecens' ///
            `trace' endstudy(`endstudy') isrecens(`isrecens')

        if "`trace'"=="trace" & "`endstudy'"!="." { // PRINT NUMBERS RECENSORED
            count if `isrecens' & `treat'==0
            noi di as text "  recensoring " as result %`ln0'.0f r(N) _c
            count if `isrecens' & `treat'==1
            noi di as text "/" as result %`ln1'.0f `r(N)' _c
            count if `dt'==1 & `isrecens'  & `treat'==0
            noi di as text " subjects (" as result %`ld0'.0f `r(N)' _c
            count if `dt'==1 & `isrecens'  & `treat'==1
            noi di as text "/" as result %`ld1'.0f `r(N)' as text " events)   " _c
        }

        * TEST
        count if `du'
        if r(N) {
            stset `u' `du'
            if "`testtype'"=="stcox" {
                stcox `treat' `adjvars', `strataopt'
                local psihat = _b[`treat']
                local Z = _b[`treat']/_se[`treat']
            }
            else if "`testtype'"=="streg"  {
                if inlist("`test'","exponential","weibull") local time time
                streg `treat' `adjvars', dist(`test') `time' `strataopt' 
                local psihat = -_b[`treat']
                if inlist("`test'","gompertz") local psihat = -`psihat' // gompertz is the only PH model
                local Z = `psihat'/_se[`treat']
            }
            else if "`testtype'"=="sts_test" {
                sts test `treat', mat(U V) `test' `strataopt'
                local Z = -U[1,1]/sqrt(V[1,1]) 
                if "`test'"=="logrank" local Z = -`Z' // logrank sign is wrong
            }
        }
        else local Z = .
        if "`trace'"=="trace" | "`debug'"=="debug" {
            if `Z'==. noi di as error "Z =    missing " _c
            else noi di as text "Z = " as result %10.7f `Z' " " _c
            if inlist("`test'","exponential","weibull","cox") {
                noi di _skip(3) as text "psi-hat= " as result %10.7f `psihat' _c
            }
        }
        else if `Z'==. noi di as error "Warning: Z=. at psi=`psi' " _c
        else noi di as text "." _continue
    
        * Post results, and finish IPE
        if "`ipe'"=="ipe" {
            if "`trace'"=="trace" | "`debug'"=="debug" noi di
            if abs(`psihat'-`psi') <= 10^(-`tol') {
                noi di as text "Convergence achieved with step < 10^-`tol'"
                local stage 9
            }
            local psi = `psihat'
            local psise = _se[`treat']
            if `iter'>=`maxiter' {
                di as error "`maxiter' iterations exceeded"
                local stage 9
            }
            post `postname' (`psi') (`Z') (_se[`treat']) (`stage')
            continue
        }
        else post `postname' (`psi') (`Z')

        * update results
        if `Z'<0   local esthi = min(`esthi',`psi')
        else local estlo = max(`estlo',`psi')
        if `Z'<-`zcrit' local upphi = min(`upphi',`psi')
        else      local upplo = max(`upplo',`psi')
        if `Z'<`zcrit' local lowhi = min(`lowhi',`psi')
        else     local lowlo = max(`lowlo',`psi')
        if "`debug'"=="debug" noi di as text ///
           " esthi=" `esthi' " estlo=`estlo' upphi=`upphi' upplo=`upplo'" ///
           " lowhi=`lowhi' lowlo=`lowlo' " _c
    
        * CHOOSE NEXT PSI
        if `psistep' == 0 {
            * interval bisection
            local estOK = (`esthi'-`estlo')<10^(-`tol') | `esthi'==. | `estlo'==.
            local hiOK  = (`upphi'-`upplo')<10^(-`tol') | `upphi'==. | `upplo'==.
            local lowOK = (`lowhi'-`lowlo')<10^(-`tol') | `lowhi'==. | `lowlo'==.
            if `stage' == 1 { // looking for psimin
                if `lowlo'==. & `psi'>`psimin' & `Z'!=. {
                    if "`debug'"=="debug" noi di as text "Extending psi range to left " _c
                    local psi = `psi'-1
                }
                else if `estlo'==. {
                    noi di as error "Failed to find a psi for which Z>=0 " _c
                    noi di as error "(this is often because there is more treatment in the control arm) " _c
                    local estOK 0
                    local stage 9
                }
                else {
                    local psi 1
                    local stage 2
                }
                if `Z'==. & ("`debug'"=="debug") di as error "Terminating stage 1 " _c
            }
            else if `stage' == 2 { // looking for psimax
                if `upphi'==. & `psi'<=`psimax'-1 & `Z'!=. {
                    if "`debug'"=="debug" noi di as text "Extending psi range to right " _c
                    local psi = `psi'+1
                }
                else {
                    local psi  = (`esthi'+`estlo')/2
                    local stage 3
                }
                if `Z'==. & ("`debug'"=="debug") di as error "Terminating stage 2" _c
            }
            else if ~`estOK' {
                if "`debug'"=="debug" noi di as text "Improving estimate " _c
                local psi  = (`esthi'+`estlo')/2
            }
            else if ~`hiOK' & "`ci'"~="noci" {
                if "`debug'"=="debug" noi di as text "Improving upper CL " _c
                local psi  = (`upphi'+`upplo')/2
            }
            else if ~`lowOK' & "`ci'"~="noci" {
                if "`debug'"=="debug" noi di as text "Improving lower CL " _c
                local psi  = (`lowhi'+`lowlo')/2
            }
            else {
                if "`debug'"=="debug" noi di as text _new "FINISH!!! " _c
                local stage 9
            }
        }                    /* END OF INTERVAL BISECTION LOOP */
        else {
          * grid search
          local psi = `psi' + `psistep'
          if abs(`psi')<epsfloat() local psi 0 // 24mar2016: avoids occasional "ITT P-value not found"
          if `psi'>`psimax'+epsfloat() local stage 9
          local estOK = !mi(`estlo',`esthi')
        }
        if "`trace'"=="trace" | "`debug'"=="debug" | `Z'==. noi di
    }
    postclose `postname'
    
    stset `t' `dt'
    
    if "`ipe'"=="ipe" {
        local psilow = `psi' - `zcrit'*`psise'
        local psiupp = `psi' + `zcrit'*`psise'
        if "`ipestore'"!="" est store `ipestore'
    }

} /* end of qui */

*** SORT OUT SAVE-DATA FILE
if "`append'"=="append" {
    * check method chars match
    qui use `savedta', clear
    if "`_dta[type]'" ~= "strbee" {
       di as error "Data `savedta' wasn't saved by strbee"
       exit 498
    }
    if "`_dta[method]'" ~= "`method'" {
       di as error "Can't append: `savedta' used method `_dta[method]'"
       exit 498
    }
    if "`_dta[test]'" ~= "`test'" {
       di as error "Can't append: `savedta' used test `_dta[test]'"
       exit 498
    }
    if "`_dta[treat]'" ~= "`treat'" {
       di as error "Can't append: `savedta' used treatment=`_dta[treat]'"
       exit 498
    }
    if "`_dta[xo0]'" ~= "`xo0'" {
       di as error "Can't append: `savedta' used xo0=`_dta[xo0]'"
       exit 498
    }
    if "`_dta[xo1]'" ~= "`xo1'" {
       di as error "Can't append: `savedta' used xo1=`_dta[xo10]'"
       exit 498
    }
    if "`_dta[endstudy]'" ~= "`endstudy'" {
       di as error "Can't append: `savedta' used endstudy=`_dta[endstudy]'"
       exit 498
    }
    noi di as text "Appending results from `savedta'"
    qui use `results', clear
    append using `savedta'
    local estOK .
    * check for duplicates
    sort psi
    di
    tempvar dup dupok
    gen byte `dup' = psi==psi[_n-1]
    gen byte `dupok' = `dup' & Z==Z[_n-1]
    qui count if `dupok'
    if r(N)>0 noi di as error r(N) " duplicate records deleted"
    qui drop if `dupok'
    qui count if `dup' & ~`dupok'
    if r(N)>0 noi di as error "Save file has duplicate psi with different Z"
    drop `dup' `dupok'
}
else use `results', clear

* copy estimation summaries from locals to characteristics
local charlist method test treat xo0 xo1 endstudy estOK n0 n1 d0 d1 nxo0 nxo1 ///
    adjvars strata recensopts tsyntax toffexp tonexp psimult
foreach char in charlist `charlist' {
    char _dta[`char'] ``char''
}
char _dta[type] strbee

di
noi save `savedta', replace
di

restore

********************* NOW CALL THE OUTPUT PROGRAM **********************
if "`output'"!="nooutput" {
    local cmd Output using `savedta', level(`level') `debug' `Gestimateoptions'
    if "`debug'"=="debug" di as input `"strbee.`cmd'"'
    `cmd'
}
end

********************* END OF G-ESTIMATE PROGRAM **********************



********************* START OF OUTPUT PROGRAM **********************

program define Output, rclass
syntax [using/], [list ZGRaph(string asis) psimin(real -10) psimax(real 10) /// output options 
    hr(string) KMgraph(string asis) gen(string)              /// output options
    GRaph(string asis)                            /// undocumented: equivalent to zgraph(string)
    level(cilevel) debug                     /// undocumented options
    ]

if "`using'"=="" {
    local using `r(savedta)'
    if "`using'"=="" {
        di as error "Please specify the 'using' file - no default found"
        exit 498
    }
}

if `"`graph'"'!="" & `"`zgraph'"'!="" {
    di as error "Can't have both graph and zgraph"
    exit 198
}
if `"`graph'"'!="" local zgraph `"`graph'"'

local zcrit = invnorm(1-(100-`level')/200)
local zcri = round(`zcrit',.01)

******************** LOAD RESULTS (Z vs PSI) ********************

preserve

if "`debug'"=="debug" noi di as text "Loading results file `using'"
use `using', clear
* copy estimation summaries from characteristics to locals
foreach char in `_dta[charlist]' {
    local `char' `_dta[`char']'
}
if "`method'"=="Branson's IPE" local ipe ipe
else if "`method'"!="Robins-Tsiatis method" exit 497
if !mi("`psimult'") {
	local psimultopt psimult(`psimult')
}

******************** HEADER FOR RESULTS ********************

* SET UP OUTPUT
local colb as result _col(24)
local col2 _col(17)
local col3 _col(31)
local col4 _col(42)
local col5 _col(54)
local line as text _dup(64) "{c -}"

* SUMMARY OF METHODS USED
di `line'
di as text "Estimating psi from accelerated life model"
di `line'
forvalues i = 0/1 {
    noi di as text "`treat'=`i' " `colb' `n`i'' as text " subjects, " _c
    noi di as text `colb' `d`i'' as text " events, " _c
    noi di as result `nxo`i'' as text " switches"
}

di as text "Method " `colb' "`method'"
di as text "Randomised group " `colb' "`treat'"
di as text "Test " `colb' "`test'"
di as text "   adjusted for " `colb' cond("`adjvars'"=="","-","`adjvars'")
di as text "   stratified by " `colb' cond("`strata'"=="","-","`strata'")
if `tsyntax'==0 {
    di as text "Switch in arm 0 " _c
    if "`xo0'"~="" di `colb' "`xo0'"
    else di `colb' "-"
    di as text "Switch in arm 1 " _c
    if "`xo1'"~="" di `colb' "`xo1'"
    else di `colb' "-"
}
else {
    if !mi("`tonexp'") di as text "Time on treatment" `colb' as result "`tonexp'"
    if !mi("`toffexp'") di as text "Time off treatment" `colb' as result "`toffexp'"
}
if !mi("`psimult'") di as text "Psi multiplier" `colb' "`psimult'"
di as text "Treatment variable " `colb' "`treat'"
di as text  "End of study variable " _c
if "`endstudy'"~="." di `colb' "`endstudy'" 
else di `colb' "none" 
di as text "Recensoring options" _c
if !mi("`recensopts'") di `colb' "`recensopts'"
else di `colb' "-" 
di as text "Results file " `colb' "`using'"

******************** COMPUTE RESULTS (EST, LOW, UPP, ZITT, PITT) ********************

local ZITT .
local PITT .
if "`ipe'"=="" {
    if "`list'"=="list" l psi Z, noobs
    sort psi
    qui results 0
    local est = r(est)
    local estlo = r(lo)
    local esthi = r(hi)
    qui results `zcrit'
    local low = r(est)
    local lowlo = r(lo)
    local lowhi = r(hi)
    qui results -`zcrit'
    local upp = r(est)
    local upplo = r(lo)
    local upphi = r(hi)
    qui summ Z if psi==0
    if r(N)==0 di as error "ITT P-value not found"
    else if r(N)>2 & r(sd)>0 di as error "Error: multiple ITT P-values found"
    else {
        local ZITT = r(mean)
        local PITT = chi2tail(1,(`ZITT')^2)
    }
    if `esthi'==.           noi di as error "No point estimate: Z(psi) > 0 at all points tested"
    else if `estlo'==.      noi di as error "No point estimate: Z(psi) < 0 at all points tested"
    if `estlo'==. | `esthi'==. {
        di as error "Check data / model or try a wider psi range"
        exit 498
    }
    if `esthi'<`estlo'      noi di as error "Z(psi) = 0 has multiple solutions"
    if `lowhi'==.           noi di as error "No lower CL: Z(psi) > `zcri' at all points tested"
    else if `lowlo'==.      noi di as error "No lower CL: Z(psi) < `zcri' at all points tested"
    else if `lowhi'<`lowlo' noi di as error "Z(psi) = `zcri' has multiple solutions"
    if `upphi'==.           noi di as error "No upper CL: Z(psi) > -`zcri' at all points tested"
    else if `upplo'==.      noi di as error "No upper CL: Z(psi) < -`zcri' at all points tested"
    else if `upphi'<`upplo' noi di as error "Z(psi) = -`zcri' has multiple solutions"
}
else {
    qui summ psi if stage==9
    assert r(N)==1
    local est = r(mean)
    qui summ psise if stage==9
    assert r(N)==1
    local estse = r(mean)
    local low = `est'-`zcrit'*`estse'
    local upp = `est'+`zcrit'*`estse'
}

*********************** RETURN RESULTS ********************

* must precede Z-graph and KM-graph which use -syntax-
return scalar psi    = `est'
return scalar psi_low = `low'
return scalar psi_upp = `upp'
return scalar Z_ITT = `ZITT'
return scalar P_ITT = `PITT'
return local savedta `using'
return local method `method'
return local adjvars `adjvars'
return local strata `strata'
forvalues i=0/1 {
    return scalar n`i' = `n`i''
    return scalar d`i' = `d`i''
    return scalar nxo`i' = `nxo`i''
}


*********************** Z-GRAPH RESULTS ********************

if "`ipe'"=="" & `"`zgraph'"'!=`""' {
    local 0 , `zgraph'
    syntax, [run TItle(passthru) YTItle(string) XLAbel(passthru) YLAbel(passthru) ///
        Connect(passthru) MSYMbol(passthru) XLIne(passthru) YLIne(passthru) *]
    sort psi
    label var Z "`test' test statistic"
    if `"`title'"'==`""' local title title(strbee results)
    if `"`ytitle'"'==`""' local ytitle `test' Z
    if `"`ylabel'"'==`""' local ylabel ylabel(-`zcri' 0 `zcri')
    if `"`connect'"'==`""' local connect connect(l)
    if `"`msymbol'"'==`""' local msymbol msymbol(p)
    if `"`xline'"'==`""' local xline xline(0, lcol(black))
    if `"`yline'"'==`""' local yline yline(-`zcrit' 0 `zcrit', lcol(black))
    scatter Z psi if psi>=`psimin' & psi<=`psimax', `connect' `msymbol' ///
        `xline' `yline' `xlabel' `ylabel' `title' ytitle(`ytitle') `options'
    qui count if psi<`psimin' & !mi(Z)
    if r(N) di as text "psimin(`psimin') option: " as result r(N) as text " points with psi < `psimin' have not been graphed"
    qui count if psi>`psimax' & !mi(Z)
    if r(N) di as text "psimax(`psimax') option: " as result r(N) as text " points with psi > `psimax' have not been graphed"
}

*********************** DISPLAY RESULTS ********************

if "`est'" ~= "" {
    di as text _new "Results for log acceleration ratio psi"
    local fmt as result %9.0g
    di `line'
    di as text               `col2' "psi"         `col3' "P-value" `col4' "[`level'% Conf. interval]"
    di `line'
    di as text "Best"        `col2' `fmt' `est'   `col3' %5.3f `PITT' `col4' `fmt' `low'   `col5' `fmt' `upp'
    if "`ipe'"!="ipe" {
        di as text "lower bound" `col2' `fmt' `estlo'                     `col4' `fmt' `lowlo' `col5' `fmt' `upplo'
        di as text "upper bound" `col2' `fmt' `esthi'                     `col4' `fmt' `lowhi' `col5' `fmt' `upphi'
    }
    di `line'
    if "`ipe'"=="ipe" {
        noi di as text "Warning: standard error and confidence interval do not allow for switch"
        noi di as text "Use bootstrap to get better standard error and confidence interval"
    }
}

********************* END OF Z-PSI ANALYSIS: RESTORE DATA ********************

restore

**************** POST-ESTIMATION OPTIONS: GEN, HR, KMGRAPH ***************

*** GENERATE U
if "`estOK'"!="0" {
    if ("`gen'"!="" | "`hr'"!="" | `"`kmgraph'"'!=`""') {
        tempvar u du
        qui gen double `u'=.
        qui gen byte `du'=.
        if "`endstudy'"!="." {
            tempvar cu
            qui gen `cu'=.
            label var `cu' "Recensoring time for `gen'"
            local ct `endstudy'
        }
        local psiround=string(`est',"%9.0g")
        label var `u' "Counterfactual untreated outcome for psi=`psiround'"
        if "`ipe'"=="ipe" label var `u' "Counterfactual ideal outcome for psi=`psiround'"
        label var `du' "Event indicator for `gen'"
		* recreate data: corrected for v1.8.3
		tempvar toffvar tonvar
		if `tsyntax'==0 {           // xo0 xo1 syntax 
			maketonoff, t(_t) treat(`treat') toff(`toffvar') ton(`tonvar') xo0(`xo0') xo1(`xo1') 
		}
		else if !mi("`tonexp'") {
			gen `tonvar' = `tonexp'
			gen `toffvar' = _t - `tonexp'
		}
		else if !mi("`toffexp'") {
			gen `tonvar' = _t - `toffexp'
			gen `toffvar' = `toffexp'
		}
        makeu, u(`u') du(`du') t(_t) dt(_d) treat(`treat') psi(`est') `psimultopt' ///
            toff(`toffvar') ton(`tonvar') `recensopts' ///
            `ipe' `ipecens'  endstudy(`endstudy') 
    }

    *** HR AND KM GRAPH
    if "`hr'" != "" | `"`kmgraph'"'!=`""' {
        * COMMON CODE
        preserve
		if !mi("`psimult'") {
			tempvar psimultvar
			gen double `psimultvar' = `psimult'
			local timespsimult *`psimultvar'
		}
        if "`ipe'"=="ipe" qui replace `u' = exp(`est'`timespsimult')*`u' if `treat'==1
        keep `u' `du' _t _d `treat' `adjvars' `strata' `psimultvar'
        tempvar u1 treat0 type
        rename `treat' `treat0'
        gen double `u1' = `u'*exp(-`est'`timespsimult')
        * correct rounding errors
        qui replace `u1'=_t if abs(_t/`u1'-1) <= epsdouble()
        qui replace `u' =_t if abs(_t/`u' -1) <= epsdouble()

        qui stack `treat0'  _t   _d  `adjvars' `strata' ///
                  `treat0' `u'  `du' `adjvars' `strata' ///
                  `treat0' `u1' `du' `adjvars' `strata', group(3) clear
        rename _stack `type'
        qui gen int `treat' = 10*(`type'-1)+`treat0'
        local name0  "0 observed"
		local name1  "1 observed"
        local name10 "0 untreated"
		local name11 "1 untreated"    
        local name20 "0 fully treated" 
		local name21 "1 fully treated"
        foreach val in 0 1 10 11 20 21 {
			label def treat2 `val' "`name`val''", add
		}
        label val `treat' treat2
        qui stset _t _d, noshow
        if "`debug'"=="debug" stsum, by(`treat')
        if "`hr'" != "" {
			* Output results: table header
            di _new as text "Hazard ratios derived from psi=" %9.0g `est'
            di `line'
            di `col2' "Haz. ratio" `col3' %5.3f "P-value" `col4' "[`level'% Conf. Interval]"
            di `line'

            if "`strata'"!="" local strataopt strata(`strata')
            
            * ITT analysis
            qui stcox `treat0' `adjvars' if `type'==1, `strataopt'
            local hritt = exp(_b[`treat0'])
            local hrittlow = exp(_b[`treat0']-`zcrit'*_se[`treat0'])
            local hrittupp = exp(_b[`treat0']+`zcrit'*_se[`treat0'])
            di as text "ITT" as result `col2' `hritt' `col3' %5.3f `PITT' `col4' `hrittlow' `col5' `hrittupp'

            * Adjusted analysis
            qui stcox `treat0' `adjvars' if inlist(`treat',10,21), `strataopt'
            cap local hradj = exp(_b[`treat0'])
            local seadj = _b[`treat0']/`ZITT'
            local hradjlow = exp(_b[`treat0']-`zcrit'*`seadj')
            local hradjupp = exp(_b[`treat0']+`zcrit'*`seadj')
            di as text "Adjusted*" as result `col2' `hradj' `col3' %5.3f `PITT' `col4' `hradjlow' `col5' `hradjupp'

            * No-treatment analysis
            qui stcox `treat0' `adjvars' if inlist(`treat',10,11), `strataopt'
            cap local hrnon = exp(_b[`treat0'])
            di as text "No treatment**" as result `col2' `hrnon' `col3' %5.3f . `col4' . `col5' .

            * Other requested analysis
            if "`hr'" != "run" {
				tokenize "`hr'"
				if "`1'"==substr("observed",1,length("`1'")) local one 1
				if "`1'"==substr("untreated",1,length("`1'")) local one 11
				if "`1'"==substr("fully",1,length("`1'")) local one 21
				if "`2'"==substr("observed",1,length("`2'")) local two 0
				if "`2'"==substr("untreated",1,length("`2'")) local two 10
				if "`2'"==substr("fully",1,length("`2'")) local two 20
				tempvar uservar
				qui gen `uservar' = `treat'==`one' if inlist(`treat',`one',`two')
				qui stcox `uservar' `adjvars' if inlist(`treat',`one',`two'), `strataopt'
				cap local hruser = exp(_b[`uservar'])
				local seuser = _b[`uservar']/`ZITT'
				local hruserlow = exp(_b[`uservar']-`zcrit'*`seuser')
				local hruserupp = exp(_b[`uservar']+`zcrit'*`seuser')
				di as text "User***" as result `col2' `hruser' `col3' %5.3f  `PITT' `col4' `hruserlow' `col5' `hruserupp'
				local note3 `""*** User-specified comparison: " as result "`treat'=`name`one''" as text " vs. " as result "`treat'=`name`two''""'
			}
		
			* Output results: table footer
            di `line'
            di as text "* test-based confidence interval"
            di as text "** check on estimation procedure: hazard ratio should be near 1" 
			if !mi(`"`note3'"') di as text `note3'
			di
            return scalar HR_ITT = `hritt'
            return scalar HR_ITT_low = `hrittlow'
            return scalar HR_ITT_upp = `hrittupp'
            return scalar HR_adj = `hradj'
            return scalar HR_adj_low = `hradjlow'
            return scalar HR_adj_upp = `hradjupp'
            return scalar HR_non = `hrnon'
            if "`hr'" != "run" {
				return scalar HR_user = `hruser'
				return scalar HR_user_low = `hruserlow'
				return scalar HR_user_upp = `hruserupp'
			}
        }

        if `"`kmgraph'"'!=`""' { // greatly expanded v1.8.4 to improve patterns and colours
            local 0 , `kmgraph'
            syntax, [run LPattern(string) LColor(string) SHOWAll UNTReated show(numlist) *]
			if !mi("`untreated'") { // new suboption v1.8.3 
				qui keep if inlist(`treat',10,11)
			}
			else if !mi("`show'") { // new suboption v1.8.7
				tempvar toshow
				gen `toshow' = 0
				foreach toshowval of numlist `show' {
					qui replace `toshow'=1 if `treat'==`toshowval'
				}
				qui drop if !`toshow'
			}
			else if mi("`showall'") { // new suboption v1.8.3 
				if `nxo0'==0 qui drop if inlist(`treat',10,20)
				if `nxo1'==0 qui drop if inlist(`treat',11,21)
			}

			local lpattern1 : word 1 of `lpattern'
			local lpattern2 : word 2 of `lpattern'
			if mi("`lpattern1'") local lpattern1 dash // for control arm
			if mi("`lpattern2'") local lpattern2 solid // for treatment arm
			else if "`lpattern2'"=="=" local lpattern2 `lpattern1'

			local lcolor1 : word 1 of `lcolor' 
			local lcolor2 : word 2 of `lcolor'
			local lcolor3 : word 3 of `lcolor'
			if mi("`lcolor1'") local lcolor1 black // for observed data
			if mi("`lcolor2'") local lcolor2 orange // for counterfactual untreated data
			else if "`lcolor2'"=="=" local lcolor2 `lcolor1'
			if mi("`lcolor3'") local lcolor3 blue // for counterfactual fully-treated data
			else if "`lcolor3'"=="=" local lcolor3 `lcolor2'

			qui levelsof `treat', local(trtlevels)
			local plotnum 0
			foreach trtlevel of local trtlevels {
				local ++plotnum
				local arm = substr("`trtlevel'",length("`trtlevel'"),1)
				local type = substr("`trtlevel'",length("`trtlevel'")-1,1)
				if `arm'==0 local lpattern `lpattern1'
				else if `arm'==1 local lpattern `lpattern2'
				if "`type'"=="" local lcolor `lcolor1'
				else if "`type'"=="1" local lcolor `lcolor2'
				else if "`type'"=="2" local lcolor `lcolor3'
				local plotopts `plotopts' plot`plotnum'opts(lpattern(`lpattern') lcolor(`lcolor'))
			}
			
			local graphcmd sts graph, by(`treat') note("Counterfactual for psi=`psiround'") `plotopts' `options'
			if "`debug'"=="debug" di as input `"`graphcmd'"'
			`graphcmd'
        }
        restore
    }

    *** SAVE U
    if "`gen'"!="" {
        rename `u' `gen'
        rename `du' d`gen'
        if "`endstudy'"!="." {
            rename `cu' c`gen'
            local cgenopt c`gen'
        }
        di as text "New variables `gen' d`gen' `cgenopt' created"
    }
}
end

**************** END OF MAIN PROGRAM ***************

program define results, rclass
local crit `1'
tempvar Zmiss
gen byte `Zmiss' = Z==.
sort `Zmiss' psi
summ psi if Z>=`crit' & Z~=.
local psilo = r(max)
summ psi if Z<=`crit'
local psihi = r(min)
tempvar est Zd Zdlag
if `psilo'~=. & `psihi'~=. {
    gen `Zd' = Z-`crit'
    gen `Zdlag' = Z[_n-1]-`crit'
    gen `est' = (psi-psi[_n-1]) * (max(`Zd',0)+max(`Zdlag',0)) / (abs(`Zd')+abs(`Zdlag'))
    replace `est' = psi in 1
    summ `est'
    local psiest = r(sum)
}
else local psiest = .
return scalar est = `psiest'
return scalar lo = `psilo'
return scalar hi = `psihi'
end

**************************************************************

prog def maketonoff
syntax, t(varname) treat(varname) toff(string) ton(string) [xo0(string) xo1(string)]
qui {
    gen double `ton'=cond(`treat',`t',0)
    forvalues i = 0/1 {
        if "`xo`i''"~="" {
            tokenize `xo`i''
            confirm var `1' `2'
            local z`i' `1'
            local dz`i' `2'
            if mi("`2'") local dz`i' 1
            count if mi(`z`i'') & `treat'==`i'
            if r(N)>0 noi di as error "Arm `treat'=`i': " as error r(N) as error " subjects have missing `z`i'' (treated as no switch)"
            count if `z`i''>_t & !mi(`z`i'') & `treat'==`i'
            if r(N)>0 noi di as error "Arm `treat'=`i': " as error r(N) as error " subjects have `z`i'' > _t (treated as no switch)"
            qui count if mi(`dz`i'') & `treat'==`i'
            if r(N) di as error "Warning: `dz`i'' has " r(N) " missing values in `treat'==`i' group"
            qui count if !inlist(`dz`i'',0,1) & !mi(`dz`i'') & `treat'==`i'
            if r(N) di as error _newline "Probable error: `dz`i'' has " r(N) ///
                " values other than 0/1 in `treat'==`i' group. " _newline ///
                "Have you specified xo`i'(eventvar timevar) instead of xo`i'(timevar eventvar)?"
            if `i'==0 replace `ton' = cond(`dz0', max(0,`t'-`z0'), 0) if `treat'==0
            if `i'==1 replace `ton' = cond(`dz1', min(`t',`z1'), `t') if `treat'==1
        }
    }
    gen double `toff'=`t'-`ton'
    assert `ton'>=0
    assert `toff'>=0
}
end

**************************************************************

program define makeu
syntax, u(string) du(string) t(varname) dt(varname) treat(varname) psi(real) ///
    toff(varname) ton(varname) ///
    [toffmin0(string) toffmin1(string) tonmin0(string) tonmin1(string) ///
    toffmax0(string) toffmax1(string) tonmax0(string) tonmax1(string) ///
    ipe ipecens trace endstudy(string) recens(varname) isrecens(varname) psimult(string) ]

qui {
	if !mi("`psimult'") local timespsimult *(`psimult')
	
    * COMPUTE UNTREATED EVENT TIME
    replace `u' = `toff' + exp(`psi'`timespsimult')*`ton'
    replace `du' = `dt'
    
    * CHECK TONMIN0() ETC. OPTIONS
    foreach onoff in on off {
        foreach i in 0 1 {
            if !mi("`t`onoff'min`i''") {
                cap assert `t`onoff'' >= `t`onoff'min`i'' if `treat'==`i'
                if _rc {
                    di as error _new "Error: some observations in `treat'==`i' have time `onoff' treatment < `t`onoff'min`i''"
                    exit 498
                }
            }
            if !mi("`t`onoff'max`i''") {
                cap assert `t`onoff'' <= `t`onoff'max`i'' if `treat'==`i'
                if _rc {
                    di as error _new "Error: some observations in `treat'==`i' have time `onoff' treatment > `t`onoff'max`i''"
                    exit 498
                }
            }
        }
    }

    * COMPUTE RECENSORING TIME
    if "`endstudy'"~="." {
        if "`recens '"=="" {
            tempvar recens
            gen double `recens'=.
        } 
        * recensoring by arm
        tempvar tstar
        gen double `tstar' = .
        forvalues i=0/1 {
            if `psi'>=0 { // `tstar' is minimum possible time on treatment up to `endstudy'
                replace `tstar' = 0 if `treat'==`i'
                if !mi("`tonmin`i''") replace `tstar' = max(`tstar', `tonmin`i'') if `treat'==`i'
                if !mi("`toffmax`i''") replace `tstar' = max(`tstar', `t' - (`toffmax`i'')) if `treat'==`i'
            }
            else if `psi'<0 { // `tstar' is maximum possible time on treatment up to `endstudy'
                replace `tstar' = `endstudy' if `treat'==`i'
                if !mi("`tonmax`i''") replace `tstar' = min(`tstar', `tonmax`i'') if `treat'==`i'
                if !mi("`toffmin`i''") replace `tstar' = min(`tstar', `endstudy' - (`toffmin`i'')) if `treat'==`i'
            }
        }
        replace `recens' = `tstar'*exp(`psi'`timespsimult') + (`endstudy' - `tstar')
    }

    * IPE: RETURN FULLY-TREATED (NOT NEVER-TREATED) EVENT TIME IN ARM 1 
    if "`ipe'"=="ipe" {
        foreach var in `u' `recens' {
            replace `var' = exp(-`psi'`timespsimult')*`var' if `treat'==1
        }
        if "`ipecens'"=="ipecens" replace `recens' = `endstudy'
    }

    * DO THE RECENSORING
    if "`endstudy'"~="." {
        if "`isrecens'"!="" replace `isrecens' = (`u'>`recens')
        replace `du' = 0 if `u'>`recens'
        replace `u' = `recens' if `u'>`recens'
    }
    else if "`isrecens'"!="" replace `isrecens' = 0
}

cap assert !mi(`u', `du')
if _rc {
    di as error "makeu, psi=`psi': missing data in u or du"
    summ `u' `du'
    exit 498
}

end

**************************************************************

prog def parsetest, rclass // parses test and classifies it
* stcox?
cap syntax, [STCox]
if !_rc {
    local testtype stcox
    local test `stcox'
}
* sts test?
cap syntax, [LOGRank WIlcoxon TWare Peto Fh(passthru)]
if !_rc {
    local testtype sts_test
    local test `logrank'`wilcoxon'`tware'`peto'`fh'
}
* streg?
cap syntax, [Exponential GOMpertz LOGLogistic LLogistic WEibull LOGNormal LNormal GAMma]
if !_rc {
    local testtype streg
    local test `exponential'`gompertz'`loglogistic'`llogistic'`weibull'`lognormal'`lnormal'`gamma'
}
if mi("`testtype'") {
    di as error "test(`test') not recognised"
    exit 198
}
return local test `test'
return local testtype `testtype'
end
