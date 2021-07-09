*! version 0.17.1     Ian White   23nov2015
/***********************************************************************************************
HISTORY
version 0.17.1      23nov2015
    mse is output after relprec
    "statistic" -> "performance measure", "stat" -> "perfmeas"
version 0.17      20sep2013
    bug fix: format of b not used in output when data originally wide
    new transpose option for output: performance measures as columns, methods as rows
version 0.16.2      4apr2013
    mse uses bfmt not pctfmt
version 0.16.1      14nov2011
    bug fix: relprec works without true()
version 0.16        13sep2011
    bug fix: now works with method() and no true()
    corrected mcse for bias when true varies
version 0.15.1      13apr2011
    new mse option
version 0.14.1      24aug2010
    better error handling if called with no observations
version 0.14         7jun2010
    For SJ resubmission.
    byvar.ado included as subroutine
    changed to version 10
    dropped separate() option and restored sep() abbreviation
    incorporated listsepformat() into format()
    added abbreviate()
version 0.13.1 26may2010 - in wide format, unlabelled variables are listed by their name, not numbered; seprefix abbreviation lengthened to sepr() to avoid confusion with sep() - but what does the latter do?
version 0.13 8mar2010 - new listsep and listsepformat(bfmt pctfmt nfmt) options gives narrower & better formatted output; missing b <=> missing se; zero se changed to missing; better listing of problem observations
version 0.12 4mar2010 - much clearer error message if -byvar- not installed
version 0.11 23dec2009 - robust option; temporary byvar dropped from saving() file; keep before reshape means extra variables don't cause crash; ref(label) for long format; dflist() dropped; long() renamed methodvar(); only keeps variables that are needed (may leave problems if it crashes with clear option)
version 0.10 7sep2009 - df() updated to df(var) dflist(varlist) dfprefix(string) dfsuffix(string)
version 0.9 4sep2009 - renamed selist() as se()
version 0.8 12feb2009 - corrected error in resetting big values to missing; new nomemcheck option
version 0.7 8dec2009 - NEW SYNTAX simsum betalist, selist() [long(methodvar)]
version 0.6 13nov2008 - new options firstmethod() and refmethod() 
version 0.5 13jun2008 - works without by(); renamed simsum (was simoutwide)
version 0.4  6jun2008 - modelse(mean) computes mean rather than RMSE; modelse_mcse corrected
version 0.3 18feb2008 - clearer listing of funny obs; df() option
version 0.2 19nov2007 - wide option, outsheet option, mcse option, if & in

NOTES ON MSE
    MSE  = mean of (beta-true)^2
         = bias^2 + k*empse^2 where k = (bsims-1)/bsims
    MCSE = SD of (beta-true)^2 / sqrt(bsims)
          (no robust option needed)
***********************************************************************************************/

prog def simsum
version 10

syntax varlist [if] [in], ///
    [true(string) METHodvar(varname) id(varlist)                             /// main options
    SEPrefix(string) SESuffix(string) se(varlist)                            /// SE options
    graph noMEMcheck max(real 10) semax(real 100) dropbig nolistbig listmiss /// data checking options
    level(real $S_level) by(varlist) mcse robust ref(string)                 /// calculation options
    df(string) DFPrefix(string) DFSuffix(string) MODELSEMethod(string)       /// calculation options
    bsims sesims bias empse relprec mse modelse relerror cover power         /// performance measure options
    sepby(varlist) clear saving(string) ABbreviate(passthru)                 /// output options
    nolist listsep format(string) gen(string) TRANSpose                      /// output options
                                                                             /// undocumented options
    ]

// CHECK OPTIONS 

if "`modelsemethod'"=="" local modelsemethod rmse
if "`modelsemethod'"!="rmse" & "`modelsemethod'"!="mean" {
    di as error "Syntax: modelsemethod(rmse|mean)"
    exit 498
}

* SORT OUT BY
if "`by'"!="" {
    local byby by(`by')
    local byvar `by'
}
else {
    tempvar byvar
    gen `byvar'=0
}

* COUNT AND STORE BETA'S 
local i 0
foreach beta of varlist `varlist' {
    local ++i
    local beta`i' `beta'
    local betalist `betalist' `beta'
}
local m `i'

* SORT OUT SE'S
if "`seprefix'"!="" | "`sesuffix'"!="" {
    if "`se'"!="" {
        di as error "Can't specify se() with seprefix() or sesuffix()"
        exit 498
    }
    forvalues i=1/`m' {
        local se`i' `seprefix'`beta`i''`sesuffix'
        confirm var `se`i''
        local selist `selist' `se`i''
    }
}
else if "`se'"!="" {
    local i 0
    foreach sevar of varlist `se' {
        local ++i
        local se`i' `sevar'
        local selist `selist' `se`i''
    }
    if `i'<`m' {
        di as error "Fewer variables in se(`se') than in `betalist'"
        exit 498
    }
    if `i'>`m' {
        di as error "More variables in se(`se') than in `betalist'"
        exit 498
    }
}
else { // just working with beta's
    if "`sesims'`modelse'`relerror'`cover'`power'"!="" {
        di as error "Can't compute `sesims' `modelse' `relerror' `cover' `power' without standard errors"
        exit 498
    }
}   

* SORT OUT DF'S
if "`dfprefix'"!="" | "`dfsuffix'"!="" {
    if "`df'"!="" {
        di as error "Can't specify df() with dfprefix() or dfsuffix()"
        exit 498
    }
    forvalues i=1/`m' {
        local df`i' `dfprefix'`beta`i''`dfsuffix'
        confirm var `df`i''
        local dflist `dflist' `df`i''
    }
}
else if "`df'"!="" {
    cap confirm number `df'
    if !_rc local dftype number
    else {
        cap assert `df'==`df'
        if !_rc local dftype varname
        else {
            cap confirm var `df'
            if !_rc local dftype varlist
            else local dftype error
        }
    }
    if inlist("`dftype'","number","varname") {
        forvalues i=1/`m' {
            local df`i' `df'
        }
        if "`dftype'"=="varname" local dflist `df'
    }
    else if "`dftype'"=="varlist" {
        local i 0
        foreach dfvar of varlist `df' {
            local ++i
            local df`i' `dfvar'
            local dflist `dflist' `dfvar'
        }
        if `i'!=`m' local dftype error
    }
    if "`dftype'"=="error" {
        di as error "df must contain number, string or varlist of same length as estimates"
        exit 498
    }

}

* IF NO PERFORMANCE MEASURES SPECIFIED, USE ALL AVAILABLE 
if "`bsims'`sesims'`bias'`empse'`relprec'`mse'`modelse'`relerror'`cover'`power'"=="" {
    foreach perfmeas in bsims bias empse relprec mse {
        local `perfmeas' `perfmeas'
    }
    if "`se1'"!="" {
        foreach perfmeas in sesims modelse relerror cover power {
            local `perfmeas' `perfmeas'
        }
    }
    if "`true'"=="" {
        di as text "true() not specified: can't calculate bias, mse and coverage"
        local bias
        local cover
        local mse
    }
}
local output `bsims' `sesims' `bias' `empse' `relprec' `mse' `modelse' `relerror' `cover' `power'
if "`bias'`empse'`relprec'`mse'`modelse'`relerror'`cover'`power'"=="" & "`mcse'"=="mcse" {
    di as error "Only bsims and/or sesims specified - mcse ignored"
    local mcse
}

if "`methodvar'"!="" {
    if `m'>1 {
        di as error "Only one estimate variable allowed with long format"
        exit 498
    }
    if "`id'"=="" {
        di as error "id() is required with long format"
        exit 498
    }
}

if "`list'"=="nolist" & "`clear'"=="" & "`saving'"=="" {
    di as error "No output requested! Please specify clear or saving(), or don't specify nolist"
    exit 498
}

if "`gen'"=="" local gen perfmeas
cap confirm new variable `gen'num
local rc1=_rc
cap confirm new variable `gen'code
if _rc | `rc1' {
    di as error as smcl "{p}Variable `gen'num and/or `gen'code already exists. This is probably because the current data are -simsum- output. If this is what you want, use the gen() option.{p_end}"
    exit 498
}   

if "`memcheck'"!="nomemcheck" {
    qui desc, short
    if r(width)/r(widthmax)>0.45 {
        di as error "simsum is memory-hungry and can fail slowly if memory is more than 50% occupied."
        di as error as smcl "Please increase the memory using {help memory:set memory}, or use the nomemcheck option."
        exit 498
    }
}

// SET UP
marksample touse, novarlist
qui count if `touse'
if r(N)==0 {
    di in red "no observations"
    exit 2000
}

* check true is specified if bias or cover chosen
if "`bias'"=="bias" | "`mse'"=="mse" | "`cover'"=="cover" {
    if "`true'"=="" {
        di as error "true() must be specified when bias and/or cover is requested"
        exit 498
    }
    tempvar truevar
    qui gen `truevar' = `true'
    qui count if missing(`truevar') & `touse'
    if r(N)>0 {
        di as error "Missing values found for true value `true'"
        exit 498
    }
}

// START CALCULATION
preserve
qui keep if `touse'

// CONVERT FROM LONG FORMAT IF NECESSARY, EXTRACT METHOD LABELS AND FIND REFERENCE METHOD
if "`methodvar'"!="" {
    * DATA ARE LONG, CONVERTING TO WIDE
    local origformat long
    local betastub `betalist'
    qui levelsof `methodvar', local(methods)
    local label : val label `methodvar'
    local i 0
    foreach method in `methods' {
        local ++i
        local beta`i' `betalist'`method'
        local newbetalist `newbetalist' `betalist'`method'
        if "`selist'"!="" local se`i' `selist'`method'
        if "`selist'"!="" local newselist `newselist' `selist'`method'
        if "`dftype'"=="number" local df`i' `df'
        if "`dftype'"=="varname" local df`i' `dflist'`method'
        if "`label'"!="" local label`i' : label `label' `method'
        else local label`i' "`method'"
        if "`label`i''"=="`ref'" local refmethod `i'
    }
    local m `i'
    if "`refmethod'"=="" {
        if "`ref'"!="" {
            if "`label'"!="" local labelled "labelled "
            di as error "ref(`ref') is not one of the `labelled'values of `methodvar'"
            exit 498
        }
        else local refmethod 1
    }
    di as text "Reshaping data to wide format ..."
    keep `betalist' `selist' `dflist' `by' `byvar' `id' `methodvar' `touse' `truevar'
    cap confirm string var `methodvar'
    if _rc==0 local string string
    local bfmt0: format `betalist' // for later use
    qui reshape wide `betalist' `selist' `dflist', i(`by' `id') j(`methodvar') `string'
    local betalist `newbetalist'
    local selist `newselist'
}
else { // DATA ARE ALREADY WIDE
    local origformat wide
    forvalues i=1/`m' {
        local label`i' : var label `beta`i''
        if "`label`i''"=="" local label`i' "`beta`i''" /* corrected, v0.13.1 */
        if "`beta`i''"=="`ref'" local refmethod `i'
    }
    if "`refmethod'"=="" {
        if "`ref'"!="" {
            di as error "ref(`ref') is not one of the listed point estimates"
            exit 498
        }
        else local refmethod 1
    }
    keep `betalist' `selist' `dflist' `by' `byvar' `id' `touse' `truevar' 
}

// LIST MISSING/PROBLEM OBS
tempvar missing
gen `missing' = 0
forvalues i=1/`m' {
    qui replace `missing' = missing(`beta`i'') & `touse'
    if "`se`i''"!="" qui replace `missing' = 1 if missing(`se`i'') & `touse'
    if "`se`i''"!="" qui replace `missing' = 1 if `se`i''==0 & `touse'
    qui count if `missing'
    if r(N)>0 {
        if "`se`i''"!="" {
            qui replace `missing' = missing(`beta`i'') & missing(`se`i'') & `touse'
            qui count if `missing'
            if r(N)>0 {
                di as text _new "Warning: found " as result r(N) as text " observations with both `beta`i'' and `se`i'' missing" _c
                if "`listmiss'"=="listmiss" list `by' `id' `beta`i'' `se`i'' if `missing', sepby(`sepby')
                di as text "--> no action taken"
            }

            qui replace `missing' = !missing(`se`i'') & missing(`beta`i'') & `touse'
            qui count if `missing'
            if r(N)>0 {
                di as text _new "Warning: found " as result r(N) as text " observed values of `se`i'' with missing `beta`i''" _c
                if "`listmiss'"=="listmiss" list `by' `id' `beta`i'' `se`i'' if `missing', sepby(`sepby')
                qui replace `se`i'' = . if `missing'
                di as text "--> `se`i'' changed to missing"
            }

            qui replace `missing' = missing(`se`i'') & !missing(`beta`i'') & `touse'
            qui count if `missing'
            if r(N)>0 {
                di as text _new "Warning: found " as result r(N) as text " observed values of `beta`i'' with missing `se`i''" _c
                if "`listmiss'"=="listmiss" list `by' `id' `beta`i'' `se`i'' if `missing', sepby(`sepby')
                qui replace `beta`i'' = . if `missing'
                di as text "--> `beta`i'' changed to missing"
            }

            qui replace `missing' = (`se`i''==0) & `touse'
            qui count if `missing'
            if r(N)>0 {
                di as text _new "Warning: found " as result r(N) as text " zero values of `se`i''" _c
                if "`listmiss'"=="listmiss" list `by' `id' `beta`i'' `se`i'' if `missing', sepby(`sepby')
                qui replace `beta`i'' = . if `missing'
                qui replace `se`i'' = . if `missing'
                di as text "--> `beta`i'' and `se`i'' have been changed to missing values for these observations"
            }
        }
    }
}
drop `missing'

// CHECK FOR TOO-BIG OBS & OPTIONALLY LIST / DROP THEM
tempvar infb infse
gen `infb' = 0
gen `infse' = 0
local errorbig 0
forvalues i=1/`m' {
    qui summ `beta`i''
    qui replace `infb' = (abs(`beta`i''-r(mean))/r(sd) > `max') & !missing(`beta`i'')  
    if "`se`i''"!="" {
        qui summ `se`i''
        qui replace `infse' = (`se`i''/r(mean) > `semax') & !missing(`se`i'') 
    }
    qui count if `infb'
    local ninfb = r(N)
    qui count if `infse'
    local ninfse = r(N)
    if `ninfb'+`ninfse' > 0 {
        di as text _newline `"Warning: found "' as result `ninfb' as text `" observations with standardised `beta`i'' > `max'"' _c
        if "`se`i''"!="" di as text `" and "' as result `ninfse' as text `" observations with scaled `se`i'' > `semax'"' _c
        if "`listbig'"!="nolistbig" l `by' `id' `beta`i'' `se`i'' if `infb'|`infse', sepby(`sepby')
        if "`dropbig'"=="dropbig" {
            qui replace `beta`i'' = . if `infb'|`infse'
            if "`se`i''"!="" qui replace `se`i'' = . if `infb'|`infse'
            di as text `"--> `beta`i'' "' _c
            if "`se`i''"!="" di as text `"and `se`i'' "' _c
            di as text `"have been changed to missing values for these observations"'
        }
        else local errorbig 1
    }
}
if `errorbig' {
    di as error "Use dropbig option to drop these observations"
    if "`listbig'"=="nolistbig" di as error "Remove nolistbig option to list these observations"
    di as error "Use max() option to change acceptable limit of point estimates"
    if "`se'"!="" di as error "Use semax() option to change acceptable limit of standard errors"
    exit 498
}

// OPTIONAL DESCRIPTIVE GRAPH
if "`graph'"=="graph" {
    tempfile graph
    set graphics off
    forvalues i=1/`m' {
        cap gr7 `se`i'' `beta`i'', xla yla b2title("`beta`i''") l1title("`se`i''") t1title("`label`i''") saving(`graph'`i', replace) /*`byby'*/
        if !_rc local gphlist `gphlist' `graph'`i'
    }
    if "`selist'"=="" local title Point estimates by method
    else local title Std error vs. point estimate by method
    set graphics on
    gr7 using `gphlist', title(`title')
}

// PROCESS RESULTS PART 1: PREPARE FOR -COLLAPSE-
di as text _newline "Starting to process results ..."
if `level'<1 local level=`level'*100
if "`robust'"=="robust" & ("`relprec'"=="relprec" | "`relprec'"=="relprec" | "`relerror'"=="relerror") {
    forvalues i=1/`m' {
        tempvar betamean`i'
        egen `betamean`i'' = mean(`beta`i''), `byby'        
    }
}
forvalues i=1/`m' {
    if "`df`i''"!="" local crit`i' invttail(`df`i'',(1-`level'/100)/2)
    else             local crit`i' = -invnorm((1-`level'/100)/2)
    if "`dftype'"=="number" local crit`i' = `crit`i'' // for speed
    local collcount `collcount' bsims_`i'=`beta`i''
    if "`bias'"=="bias" {
        qui gen bias_`i' = `beta`i'' - `truevar'
        local collmean `collmean' bias_`i' 
        local collsd `collsd' biassd_`i' = bias_`i'
    }
    if "`relerror'"=="relerror" | "`modelse'"=="modelse" {
        qui gen var_`i'=`se`i''^2
    }
    if "`empse'"=="empse" | "`relerror'"=="relerror" | "`relprec'"=="relprec" | "`bias'"=="bias" {
        local collsd `collsd' empse_`i'=`beta`i''
    }
    if "`mse'"=="mse" {
        qui gen mse_`i' = (`beta`i'' - `truevar')^2
        local collmean `collmean' mse_`i'
        local collsd `collsd' msesd_`i'=mse_`i'
    }
    if "`relprec'"=="relprec" & `i'!=`refmethod' {
        qui byvar `byvar', r(rho N) gen unique: corr `beta`refmethod'' `beta`i''
        rename Rrho_ corr_`i'
        rename RN_ ncorr_`i'
        local collsum `collsum' corr_`i' ncorr_`i'
    }
    if "`modelse'"=="modelse" | "`relerror'"=="relerror" | "`sesims'"=="sesims" {
        local collcount `collcount' sesims_`i'=`se`i'' 
    }
    if "`modelse'"=="modelse" | "`relerror'"=="relerror" {
        local collmean `collmean' modelse_`i'=`se`i''
        local collmean `collmean' varmean_`i'=var_`i'
        local collsd `collsd' varsd_`i'=var_`i' 
        local collsd `collsd' modelsesd_`i'=`se`i''
    }
    if "`cover'"=="cover" | "`power'"=="power" {
        if "`cover'"=="cover" local collcount `collcount' bothsims_`i'=cover_`i'
        else local collcount `collcount' bothsims_`i'=power_`i'
    }
    if "`cover'"=="cover" {
        qui gen cover_`i' = 100*(abs(`beta`i''-`truevar')<(`crit`i'')*`se`i'') if !missing(`beta`i'') &   !missing(`se`i'') 
        local collmean `collmean' cover_`i' 
    }
    if "`power'"=="power" {
        qui gen power_`i' = 100*(abs(`beta`i'')>=(`crit`i'')*`se`i'') if !missing(`beta`i'') & !missing(`se`i'') 
        local collmean `collmean' power_`i' 
    }
    if "`robust'"=="robust" {
        if "`empse'"=="empse" {
            tempvar empseT`i' empseB`i' empseTT`i' empseBB`i' empseTB`i' 
            qui gen `empseT`i'' = (`beta`i''-`betamean`i'')^2
            qui gen `empseB`i'' = 1
            qui gen `empseTT`i'' = `empseT`i''^2
            qui gen `empseBB`i'' = `empseB`i''^2
            qui gen `empseTB`i'' = `empseT`i''*`empseB`i''
            local collsum `collsum' `empseT`i'' `empseB`i'' `empseTT`i'' `empseTB`i'' `empseBB`i''
        }
        if "`relprec'"=="relprec" {
            tempvar relprecT`i' relprecB`i' relprecTT`i' relprecBB`i' relprecTB`i' 
            qui gen `relprecT`i'' = (`beta`refmethod''-`betamean`refmethod'')^2
            qui gen `relprecB`i'' = (`beta`i''-`betamean`i'')^2
            qui gen `relprecTT`i'' = `relprecT`i''^2
            qui gen `relprecBB`i'' = `relprecB`i''^2
            qui gen `relprecTB`i'' = `relprecT`i''*`relprecB`i''
            local collsum `collsum' `relprecT`i'' `relprecB`i'' `relprecTT`i'' `relprecTB`i'' `relprecBB`i''
        }
        if "`relerror'"=="relerror" {
            tempvar relerrorT`i' relerrorB`i' relerrorTT`i' relerrorBB`i' relerrorTB`i' 
            qui gen `relerrorT`i'' = `se`i''^2
            qui gen `relerrorB`i'' = (`beta`i''-`betamean`i'')^2
            qui gen `relerrorTT`i'' = `relerrorT`i''^2
            qui gen `relerrorBB`i'' = `relerrorB`i''^2
            qui gen `relerrorTB`i'' = `relerrorT`i''*`relerrorB`i''
            local collsum `collsum' `relerrorT`i'' `relerrorB`i'' `relerrorTT`i'' `relerrorTB`i'' `relerrorBB`i''
        }
    }
}
if "`collmean'"!="" local collmean (mean) `collmean'
if "`collsd'"!="" local collsd (sd) `collsd'
if "`collcount'"!="" local collcount (count) `collcount'
if "`collsum'"!="" local collsum (sum) `collsum'

// PROCESS RESULTS PART 2: -COLLAPSE-
collapse `collmean' `collsd' `collcount' `collsum', by(`byvar')

// PROCESS RESULTS PART 3: AFTER -COLLAPSE-
forvalues i=1/`m' {
    qui gen k_`i' = bsims_`i'/(bsims_`i'-1)
    if "`bias'"=="bias" {
        qui gen bias_mcse_`i' = biassd_`i' / sqrt(bsims_`i')
    }
    if ("`empse'"=="empse"  | "`relerror'"=="relerror") & "`robust'"=="" {
        qui gen empse_mcse_`i' = empse_`i'/sqrt(2*(bsims_`i'-1))
    }
    else if ("`empse'"=="empse") & "`robust'"=="robust" {
        qui replace `empseTT`i''=`empseTT`i''*(k_`i'^2)
        qui replace `empseTB`i''=`empseTB`i''*k_`i'
        qui replace `empseT`i'' =`empseT`i'' *k_`i'
        qui gen empse_mcse_`i' = sqrt(k_`i') * sqrt(`empseTT`i'' -2*(`empseT`i''/`empseB`i'')*`empseTB`i'' +(`empseT`i''/`empseB`i'')^2*`empseBB`i'') / `empseB`i''
        qui replace empse_mcse_`i' = empse_mcse_`i' / (2*empse_`i')
    }
    if "`relprec'"=="relprec" {
        if `i'!=`refmethod' {
            qui gen relprec_`i' = 100 * ((empse_`refmethod'/empse_`i')^2-1)
            if "`robust'"=="" {
                qui gen relprec_mcse_`i' = 200 * (empse_`refmethod'/empse_`i')^2 * sqrt((1-(corr_`i')^2)/(ncorr_`i'-2))
            }
            else {
                qui gen relprec_mcse_`i' = 100 * sqrt(`relprecTT`i'' -2*(`relprecT`i''/`relprecB`i'')*`relprecTB`i'' +(`relprecT`i''/`relprecB`i'')^2*`relprecBB`i'') / `relprecB`i''
            }
        }
        else {
            qui gen relprec_`i' = .
            qui gen relprec_mcse_`i' = .
        }
    }
    if "`mse'"=="mse" {
        qui gen mse_mcse_`i' = msesd_`i' / sqrt(bsims_`i')
    }
    if "`modelse'"=="modelse" | "`relerror'"=="relerror" {
        if "`modelsemethod'"=="rmse" {
            qui replace modelse_`i' = sqrt(varmean_`i')
            qui gen modelse_mcse_`i' = varsd_`i' / sqrt(4 * sesims_`i' * varmean_`i') 
        }
        else if "`modelsemethod'"=="mean" {
            qui gen modelse_mcse_`i' = modelsesd_`i' / sqrt(sesims_`i')
        }
    }
    if "`relerror'"=="relerror" {
        qui gen relerror_`i' = 100*(modelse_`i'/empse_`i'-1)
        if "`robust'"=="" qui gen relerror_mcse_`i' = 100*(modelse_`i'/empse_`i') * sqrt((modelse_mcse_`i'/modelse_`i')^2 + (empse_mcse_`i'/empse_`i')^2 )
        else {
            qui gen relerror_mcse_`i' = sqrt(`relerrorTT`i'' -2*(`relerrorT`i''/`relerrorB`i'')*`relerrorTB`i'' +(`relerrorT`i''/`relerrorB`i'')^2*`relerrorBB`i'') / `relerrorB`i''
            qui replace relerror_mcse_`i' = relerror_mcse_`i' * 100 / (2*(1+relerror_`i'/100))
        }
    }
    if "`cover'"=="cover" {
        qui gen cover_mcse_`i' = sqrt(cover_`i'*(100-cover_`i')/bothsims_`i')
    }
    if "`power'"=="power" {
        qui gen power_mcse_`i' = sqrt(power_`i'*(100-power_`i')/bothsims_`i') 
    }
    cap drop varmean_`i' 
    cap drop varsd_`i'
}

// PREPARE FOR OUTPUT
local alpha=100-`level'
local bsimsname Non-missing point estimates
local sesimsname Non-missing standard errors
local biasname Bias in point estimate
local empsename Empirical standard error
local relprecname % gain in precision relative to method `label`refmethod''
local msename Mean squared error
if "`modelsemethod'" =="mean" local modelsename Mean model-based standard error `sebeta'
if "`modelsemethod'" =="rmse" local modelsename RMS model-based standard error `sebeta'
local relerrorname Relative % error in standard error
local covername Coverage of nominal `level'% confidence interval
local powername Power of `alpha'% level test

local keeplist `byvar'
foreach name in `output' {
    local domcse = "`mcse'"=="mcse" & "`name'"!="bsims" & "`name'"!="sesims"
    forvalues i=1/`m' {
        rename `name'_`i' method`i'`name'
        local keeplist `keeplist' method`i'`name'
        if `domcse' {
            rename `name'_mcse_`i' method`i'`name'_mcse
            local keeplist `keeplist' method`i'`name'_mcse
        }
    }
}
forvalues i=1/`m' {
    local methodlist `methodlist' method`i'
}
keep `keeplist'
qui reshape long `methodlist', i(`byvar') j(`gen'code) string
forvalues i=1/`m' {
    char method`i'[varname] "`label`i''"
    label var method`i' "`label`i''"
}
local i 0
qui gen mcse = .
qui gen `gen'num = .
foreach perfmeas in bsims sesims bias empse relprec mse modelse relerror cover power {
    local ++i
    qui replace mcse=0 if `gen'code=="`perfmeas'"
    qui replace mcse=1 if `gen'code=="`perfmeas'_mcse"
    qui replace `gen'code="`perfmeas'" if `gen'code=="`perfmeas'_mcse"
    qui replace `gen'num = `i' if `gen'code=="`perfmeas'" | `gen'code=="`perfmeas'_mcse"
    * label performance measures
    if "`perfmeas'"=="bsims" local label "Non-missing point estimates"
    if "`perfmeas'"=="sesims" local label "Non-missing standard errors"
    if "`perfmeas'"=="bias" local label "Bias in point estimate"
    if "`perfmeas'"=="empse" local label "Empirical standard error"
    if "`perfmeas'"=="relprec" local label "% gain in precision relative to method `label`refmethod''"
    if "`perfmeas'"=="mse" local label "Mean squared error"
    if "`perfmeas'"=="modelse" {
        if "`modelsemethod'" =="mean" local label "Mean model-based standard error"
        if "`modelsemethod'" =="rmse" local label "RMS model-based standard error"
    }
    if "`perfmeas'"=="relerror" local label "Relative % error in standard error"
    if "`perfmeas'"=="cover" local label "Coverage of nominal `level'% confidence interval"
    if "`perfmeas'"=="power" local label "Power of `alpha'% level test"
    label def `gen'num  `i' "`label'", add
    label val `gen'num `gen'num 
}
assert !mi(mcse)
foreach var in `methodlist' {
    rename `var' `var'_
    local methodlist2 `methodlist2' `var'_
}
qui reshape wide `methodlist2', i(`byvar' `gen'num) j(mcse)
local ids `gen'num `by'
local betas
forvalues i=1/`m' {
    rename method`i'_0 `beta`i''
    label var `beta`i'' "`label`i''"
    char `beta`i''[varname] "`label`i''"
    local betasnomcse `betasnomcse' `beta`i''
    local betas `betas' `beta`i''
    if "`mcse'"=="mcse" {
        rename method`i'_1 `beta`i''_mcse
        local betas `betas' `beta`i''_mcse
        label var `beta`i''_mcse "`label`i'' (MCse)"
        char `beta`i''_mcse[varname] "(MCse)"
    }
}
char `gen'num[varname] "Performance measure"
label var `gen'num "Performance measure"
label var `gen'code "Performance measure"
order `ids' `betas'
sort `gen'num `by'

// OUTPUT
tokenize `format'
local bfmt "`1'"
local pctfmt "`2'"
local nfmt "`3'"
if "`bfmt'"=="" {
    if mi("`methodvar'") local bfmt: format `beta1'
    else local bfmt `bfmt0'
}
if "`pctfmt'"=="" | "`pctfmt'"=="=" | "`pctfmt'"=="." local pctfmt `bfmt'
if "`nfmt'"=="" local nfmt %7.0f

if mi("`transpose'") {
    if "`list'"!="nolist" {
        if "`listsep'"=="" {
            qui format `betas' `bfmt' 
            list `ids' `betas', noo subvarname sepby(`gen'num `sepby') `abbreviate'
        }
        else {
            foreach perfmeas in `output' {
                di as text _new "``perfmeas'name'"
                local thisbetas = cond(inlist("`perfmeas'","bsims","sesims"), "betasnomcse", "betas")
                if inlist("`perfmeas'","bsims","sesims") local format `nfmt'
                else if inlist("`perfmeas'","bias","empse","modelse","mse") local format `bfmt'
                else local format `pctfmt'
                qui format `betas' `format' 
                list `by' ``thisbetas'' if `gen'code=="`perfmeas'", noo subvarname sepby(`gen'num `sepby') `abbreviate'
            }
        }
    }
    * format for output data set
    qui format `betas' `bfmt'
    char `gen'num[varname] 
}
else {
    di "Transposing results ..."
    drop `gen'num
    if "`origformat'"=="long" {
    }
    else if "`origformat'"=="wide" {
        foreach var of varlist `betas' {
            rename `var' b_`var'
        }
        local betastub b_            
    }
    else exit 499
    qui reshape long `betastub', i(`gen'code `by') j(method) string
    qui reshape wide `betastub', i(`by' method) j(`gen'code) string
    if "`mcse'"=="mcse" {
        gen type = cond(substr(method,length(method)-4,5)=="_mcse","mcse","est")
        qui replace method = substr(method,1,length(method)-5) if type=="mcse"
        local type type
        local sep2 method
    }
    sort `by' method `type'
    foreach varname of varlist `betastub'* {
    	local varname2 = substr("`varname'", 1+length("`betastub'"), .)
    	rename `varname' `varname2'
        label var `varname2'
    }
    cap format `bias' `empse' `mse' `modelse' `bfmt'
    cap format `relprec' `relerror' `cover' `power' `pctfmt'
    cap format `bsims' `sesims' `sesims' `nfmt'
    if "`list'"!="nolist" {
        l `by' method `type' `bsims' `sesims' `bias' `empse' `relprec' `mse' `modelse' `relerror' `cover' `power', sepby(`by' `sep2') noo
    }
}

// FINISH OFF
if "`saving'"!="" {
    if "`by'"=="" drop `byvar'
    save `saving'
}
if "`clear'"=="clear" {
    restore, not
    di as text "Results are now in memory."
}
end

********************** BYVAR (PATRICK ROYSTON) ********************************

* version 2.0.3 PR 03apr2007.
program define byvar, rclass sortpreserve
version 8

tokenize `"`0'"', parse(":")
if "`2'"!=":" {
    di as err "syntax error - maybe missing colon, or unmatched quotes somewhere"
    exit 198
}
local 0 `1'
mac shift 2 // skip the colon
local command `*'

syntax varlist [if] [in], [ E(str) R(str) B(str) SE(str) GRoup(str) GEnerate ///
 Tabulate REturn Missing Pause noLabel Unique SEParator(string) ]

if "`group'"!="" confirm new var `group'

if "`unique'"!="" & "`generate'"=="" {
    di as err "unique requires generate"
    exit 198
}

local bylist `varlist'

local s1 `e'
local L1 E
local s2 `r'
local L2 R
local s3 `b'
local L3 B
local s4 `se'
local L4 S
local tostore=`"`s1'`s2'`s3'`s4'"'!=""
if !`tostore' & "`generate'`return'`tabulate'"!="" {
    di as err "nothing to generate, return or tabulate"
    exit 198
}
if `tostore' & "`generate'`return'`tabulate'"=="" {
    di as txt "(tabulate assumed)"
    local tabulat tabulate
}

local tab="`tabulate'"!="" & `tostore'

* Extract multiple commands
local ncmd 0
if "`separator'"!="" local sep=substr("`separator'",1,1)
else local sep @
tokenize `"`command'"', parse("`sep'")
while `"`1'"'!="" {
    if `"`1'"'!="@" {
        local ++ncmd
        local command`ncmd' `1'
    }
    mac shift
}
forvalues i=1/`ncmd' {
    tokenize `"`command`i''"', parse(",")
    local cmd1 `1'
    mac shift
    local cmd2`i' `*'
    local pif=index(`"`cmd1'"', " if ")
    if `pif'>0 {
        local cmd11`i'=substr(`"`cmd1'"',1,`pif')
        local cmd12`i'=substr(`"`cmd1'"',`pif'+4,.)
        local ifalso`i' " & "
    }
    else local cmd11`i' `cmd1'
}

/* Number and count the groups  */
quietly {
/*
    Default is to exclude missing groups in bylist from analysis.
    Their corresponding group codes are set to missing and sorted to
    end of data.
*/
    tempvar grp first
    marksample touse, strok
    if "`missing'"=="" {
        markout `touse' `bylist', strok
        replace `touse'=. if `touse'==0
    }
    sort `touse' `bylist'
    by `touse' `bylist': gen byte `first'=1 if _n==1 & `touse'==1
    gen int `grp'=sum(`first') if `touse'==1
    drop `touse'
    sum `grp'
    local GRP=r(max)
    if `GRP'==0 noisily error 2000

    local itemlen 14
/*
    Extract group-defining values of bylist variables
    and store in macros
*/
    local nby : word count `bylist'
    if `tab' {
        noi di
        local dashes
    }
    tempvar index
    gen long `index'=.
    forvalues i=1/`GRP' {
        replace `index'=sum(_n*(`grp'==`i' & `first'==1))
        local j=`index'[_N]
        forvalues k=1/`nby' {
            local byvar`k' : word `k' of `bylist'
            local vallab: value label `byvar`k''
            local byval=`byvar`k''[`j']
            if "`vallab'"!="" & "`label'"!="nolabel" {
                local by`i'`k': label `vallab' `byval'
            }
            else local by`i'`k' `byval'
            if `i'==1 & `tab' {
                local dashes "`dashes'---------"
                noi di as txt %-9s "`byvar`k''" _c
            }
        }
    }
    drop `index'
}
if `tab' {
    di as txt " |" _c
    local dashes "`dashes'-+"
}
/*
    Parse and record items for storage
*/
forvalues j=1/4 {
    local i 1
    if `"`s`j''"'!="" {
        tokenize `"`s`j''"'
        * take care of embedded quotes
        local k 1
        while `"`1'"'!="" {
            local sk`k' `sk`k'' `1'
            * Count number of quotes in `1' - should be 2. Do not actually change `1' (discard `z').
            local z: subinstr local 1 `"""' "Q", all count(local nquote)    // "
            if `nquote'>0 & `nquote'!=2 {
                di as err "unmatched quotes in " `"`s`j''"'
                exit 198
            }
            local ++k
            mac shift
        }
        local l 1
        while `l'<`k' {
            * 1=item, [ 2="=", 3=description of item ], 4=null
            tokenize `"`sk`l''"', parse("=")
            local sk`l'
            if `"`4'"'!="" {
                di as err "invalid " `"`sk`l''"'
                exit 198
            }
            local st`j'`i' `1'
            if `"`3'"'=="" {
                if      `j'==1 local lab e(`1')
                else if `j'==2 local lab r(`1')
                else if `j'==3 local lab _b[`1']
                else if `j'==4 local lab _se[`1']
            }
            else {
                local lab=substr(`"`3'"',1,`itemlen'-1)
            }
            if "`generate'"!="" {
                mk_name `L`j'' `1' 6
                local `L`j''_`i' `s(name)'
                qui gen double ``L`j''_`i''=.
                lab var ``L`j''_`i'' `"`lab' by `bylist'"'
            }
            if `tab' {
                local dashes "`dashes'--------------"
                local skip=`itemlen'-length(`"`lab'"')
                di as txt _skip(`skip') `"`lab'"' _c
            }
            local ++i
            local ++l
        }
    }       
    local n`j'=`i'-1
}
if `tab' di _n as txt "`dashes'"

/* Perform calcs        */
if `tab' local show quietly
else local show noisily
tempname thing
forvalues i=1/`GRP' { // i indexes members of groups implied by bylist
    if !`tab' {
        di as txt _n "-> " _c
        forvalues k=1/`nby' {
            di as txt "`byvar`k''==`by`i'`k'' " _c
        }
        di
    }
    forvalues j=1/`ncmd' {
*di `"capture `show' `cmd11`j'' if `grp'==`i' `ifalso`j'' `cmd12`j'' `cmd2`j''"'
        capture `show' `cmd11`j'' if `grp'==`i' `ifalso`j'' `cmd12`j'' `cmd2`j''
        local rc=_rc
    }

    if "`pause'"!="" more

    if `tab' {
        forvalues k=1/`nby' {
            di as res %-9s substr("`by`i'`k''",1,8) _c
        }
        di as txt " |" _c
    }
    forvalues k=1/4 {   // k indexes the 4 types of thing to be stored
        if `n`k''>0 {
            forvalues l=1/`n`k'' { /* l indexes # of thing */
                
                if `rc'==0 {
                    if `k'==1   scalar `thing'=e(`st`k'`l'')
                    else if `k'==2  scalar `thing'=r(`st`k'`l'')
                    else if `k'==3  scalar `thing'=_b[`st`k'`l'']
                    else if `k'==4  scalar `thing'=_se[`st`k'`l'']
                }
                else scalar `thing'=.
                if "`generate'"!="" {
                    if "`unique'"=="" qui replace ``L`k''_`l''=`thing' if `grp'==`i'
                    else qui replace ``L`k''_`l''=`thing' if `grp'==`i' & `first'==1
                }
                if "`return'"!="" {
                    * gp refers to subgroup (level) of the byvar(s)
                    local r `L`k''`l'gp`i'
                    return scalar `r'=`thing'
                }
                if `tab' di _skip(4) as res %10.0g `thing' _c
            }
        }
    }
    if `tab' di
}
quietly if "`generate'"!="" {
    forvalues k=1/4 {           /* k indexes type of thing stored */
        if `n`k''>0 {
            forvalues i=1/`n`k'' { /* i indexes item in list of things */
                compress ``L`k''_`i''
                // if "`firstonly'"!="" bysort `grp': replace ``L`k''_`i''=. if _n>1
                return local `L`k''_`i' ``L`k''_`i''
            }
        }
    }
}
if "`group'"!="" {
    cap drop `group'
    rename `grp' `group'
    lab var `group' "group by `bylist'"
}
return scalar byvar_g=`GRP'
end

program define mk_name, sclass
/* meaning make_unique_name <letter> <suggested_name> <#_chars> */
    version 8
    args letter base numchar
    sret clear
    local name = substr("`letter'`base'",1,`numchar'+1)
    xi_mkun2 `name'_
end

program define xi_mkun2, sclass
version 8
/* meaning make_unique_name <suggested_name> */
    args name

    local totry "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local lentot=length("`totry'")
    local l 0
    local len = length("`name'")
    capture list `name'* in 1       /* try name out */
    while _rc==0 {
        if `l'==`lentot' {
            di as err "too many terms---limit is " `lentot'+1
            exit 499
        }
        local l=`l'+1
        local name = substr("`name'",1,`len'-1)+substr("`totry'",`l',1)
        capture list `name'* in 1
    }
    sret local name "`name'"
end

********************************************************************************************************
