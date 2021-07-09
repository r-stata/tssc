/*
*! Ian White # 6apr2018
	aborts if #events out of range
	aborts if treatment names are longer than 32 characters 
		(which previously caused network map to fail)
version 1.4.1 # Ian White # 4apr2018
	bug fix: in wide format, existence of another variable with same stem caused failure
	default changed from augment(1E-3) to augment(1E-5)
version 1.3.1 # Ian White # 9oct2017
	better error message if summary statistic variables are string
version 1.2.5 # Ian White # 13mar2017
    final changes to network_components and help file
version 1.2.4 # Ian White # 23feb2017
    network_components and help file updated to match Howard Thom's paper
version 1.2.1 # Ian White # 6jul2015
    SMD changes:
        corrected variance to use eq (14) not (10) of White & Thomas (2005)
        new undocumented asymptotic option ignores all nu-based corrections 
    MD and SMD changes:
        new option sdpool(on|off) - default is on for SMD and off for MD
version 1.2.0 # Ian White # 3jul2015
    new nmiss option gives #missing - stored as new char, used by metamiss2
version 1.1.3 # Ian White # 11jun2015
    temporarily change emptycells so that compute_df works with many treatments
version 1.1 # Ian White # 8jun2015
8jun2015
    add hr option (for log rate ratio); "binomial" changed to "count"
15may2015
    bug fix: study-level variables were wrongly seen as arm-level variables
12mar2015
    nocodes option
version 1.1 # Ian White # 12mar2015
    added check of whether connected
    added count of df for inco & hetero
    augment options:
        augment, augmean, augsd become expressions (13mar2015)
        if not specified, augmean and augsd are now study-specific averages
        new augoverall option gives augmean and augsd as previous overall averages
        these are useful (a) for SMDs with very different SDs, and (b) when combining means with mean changes
    bug fix: _design used in error
        for mean difference, SEs were output instead of variances (13mar2015)
        default format is standard
version 1.0 # Ian White # 9Sep2014 
version 0.8 16jul2014
    treatments are always coded A, B, C (or AA... if >26 trts)
        treatment names are stored as characteristics trtnameA etc.
        if trtlist() is specified then A is first trt etc.
        otherwise trts are taken in alphabetical order
    reordered output
version 0.6 6jun2014
    also print augmented #obs, mean, [SD]
version 0.5 27jan2014
version 0.4 18dec2013
version 0.3 9may2013
	store names of d, n and has
version 0.2 12mar2013
version 0.1 8mar2013
nma version 0.1 30nov2012
*/

prog def network_setup
syntax anything [if] [in], [ ///
    STUDyvar(varname) TRTvar(varname) ARMVars(string) /// describe data 
    TRTList(string asis) alpha NUMcodes noCOdes /// how treatments are coded
    format(string) or rr rd hr zeroadd(real 0.5) md smd sdpool(string) /// how to setup
    ref(string) augment(string) augmean(string) augsd(string) AUGOverall /// augment options
    GENPrefix(string) GENSuffix(string) /// what-to-output options
    debug nmiss(name) ASYmptotic /// undocumented options
    ]

// PARSING
* raw data variables
tokenize "`anything'"
if "`2'"=="" | "`4'"!="" {
    di as error "Syntax: network setup events-stub total-stub ... or network setup mean-stub sd-stub n-stub ... "
    exit 498
}
if "`3'"=="" { // events-total
    local d `1'
    local n `2'
    local rawvars `d' `n' `nmiss'
    local outcome count
    if "`or'`rr'`rd'`hr'" == "" local or or
    foreach thing in md smd {
        if !mi("``thing''") di as error "Count data: `thing' ignored"
    }
}
else { // mean-SD-n
    local mean `1'
    local sd `2'
    local n `3'
    local rawvars `mean' `sd' `n' `nmiss'
    local outcome quantitative
    if "`md'`smd'" == "" local md md
    foreach thing in rd rr or hr {
        if !mi("``thing''") di as error "Quantitative data: `thing' ignored"
    }
}

* measure
if wordcount("`or' `rr' `rd' `hr'")>1 {
    di as error "Count data: please specify only one of or rr rd hr"
    exit 198
}
if wordcount("`md' `smd'")>1 {
    di as error "Quantitative data: please specify only one of md smd"
    exit 198
}
if "`or'"=="or" local measure "Log odds ratio"
if "`rr'"=="rr" local measure "Log risk ratio"
if "`rd'"=="rd" local measure "Risk difference"
if "`hr'"=="hr" local measure "Log hazard ratio"
if "`md'"=="md" local measure "Mean difference"
if "`smd'"=="smd" local measure "Standardised mean difference"
if mi("`sdpool'") local sdpool = cond(mi("`md'"),"on","off")
if !inlist("`sdpool'","on","off") {
    di as error "Syntax: sdpool(on|off)"
    exit 198
}

* names for variables
local names y S stderr trtdiff design contrast t1 t2 component // names to be read or defaulted
if mi("`genprefix'`gensuffix'") local genprefix _ // default
foreach name in `names' {
    local `name' `genprefix'`name'`gensuffix'
}

* target format
local targetformat `format'
local format
if mi("`targetformat'") local targetformat augmented
local ok 0
foreach arg in augmented standard pairs {
    if strpos("`arg'","`targetformat'")==1 {
        local targetformat `arg'
        local ok 1
    }
}
if !`ok' {
    di as error "Syntax: format(augmented|standard|pairs)"
    exit 198
}

* treatment list, if specified
cap numlist `"`trtlist'"'
if !_rc local trtlist `r(numlist)'

if "`debug'"=="" local ifdebugnoi qui

if mi("`trtvar'") & mi("`studyvar'") {
    di as error "Please specify trtvar() for long format, or studyvar() for wide format"
    exit 199
}

if "`codes'"=="nocodes" {
    if !mi("`numcodes'") di as error "Option numcodes will be ignored since nocodes is specified"
    if !mi("`alpha'") di as error "Option alpha will be ignored since nocodes is specified"
}

* output columns
local col1 _col(4) as text
local col1a _col(7) as text
local col2 _col(40) as result

// START PROCESSING DATA
preserve // matched by -restore, not- later when all has worked
marksample touse
qui keep if `touse'
drop `touse'

// IF DATA ARE IN LONG FORMAT: READ TREATMENT NAMES, DROP UNWANTED TREATMENTS, CODE TREATMENTS AND & CONVERT TO WIDE
if "`trtvar'"!="" {
    if !mi("`debug'") noi di as text "Data are in long format ..."
    local origfmt long
    cap confirm var `studyvar'
    if _rc {
        di as error "studyvar(varname) is required with trtvar(`trtvar')"
        exit 498
    }
    isid `studyvar' `trtvar'
    qui levelsof `trtvar', local(trtvarlevels)

	confirm numeric var `anything'  // 9oct2017

    * change `trtvar' to string
    cap confirm string var `trtvar'
    if _rc { // numeric
        * can't use -decode- as unlabelled trts become missing
        qui gen `trtvar'2 = ""
        foreach trtvarlevel in `trtvarlevels' {
            local thisname : label (`trtvar') `trtvarlevel'
            qui replace `trtvar'2 = "`thisname'" if `trtvar' == `trtvarlevel'
            local trtvarlevels2 `"`trtvarlevels2' `"`thisname'"'"'
        }
        drop `trtvar'
        rename `trtvar'2 `trtvar'
        local trtvarlevels `"`trtvarlevels2'"'
        if mi(`"`trtlist'"') & mi("`alpha'") local trtlist `"`trtvarlevels2'"' 
            * uses original treatment sort order 
    }

    * with trtlist(): check it contains valid treatments, and drop others
    if !mi(`"`trtlist'"') {
        local badtrts : list trtlist - trtvarlevels
        if !mi(`"`badtrts'"') {
            di as error `"Treatment(s) in trtlist() not found: `badtrts'"'
            exit 498
        }
        local droptrts : list trtvarlevels - trtlist
        foreach droptrt in `droptrts' {
            qui drop if `trtvar' == `"`droptrt'"'
        }
    }

    * without trtlist(): create it
    else qui levelsof `trtvar', local(trtlist)

    * code treatments
    local ntrts : word count `trtlist'
    local r 0
    tempvar trtcode
    qui gen `trtcode' = ""
    foreach trt in `trtlist' {
        if length("`trt'")>32 { // check added 6apr2018
			di as error "Treatment name exceeds the 32 character limit: `trt'"
			exit 498
		}
		local ++r
        if "`codes'"=="nocodes" { // don't code
            local thistrtcode = strtoname("`trt'",0)
        }
        else if mi("`numcodes'") { // code as letters
            if `ntrts'<=26 local thistrtcode = char(64+`r')
            else local thistrtcode = char(65+int((`r'-1)/26)) + char(65+mod(`r'-1,26))
        }
        else { // code as numbers 
            local thistrtcode = "0"*`=length("`ntrts'")-length("`r'")' + "`r'"
        }
        local trtcodes `trtcodes' `thistrtcode'
        local trtname`thistrtcode' `trt'
        local thistrtcode = strtoname(`"`thistrtcode'"',0)
        qui replace `trtcode' = `"`thistrtcode'"' if `trtvar' == `"`trt'"'
        `ifdebugnoi' di as text `"Treatment `trt' has code `thistrtcode'"'
    }
    drop `trtvar'

    * detect arm-level variables which vary within studies
    unab allvars : _all
    unab invars : `rawvars' `studyvar' `trtcode'
    local outvars : list allvars - invars
    sort `studyvar'
    foreach outvar in `outvars' {
        cap by `studyvar' : assert `outvar' == `outvar'[_n-1] | _n==1
        if _rc local probvars `probvars' `outvar'
    }
    if !mi("`probvars'") {
        if mi("`armvars'") {
            di as error "You have arm-level variables: `probvars'"
            di as error "Use option armvars(keep [varlist] | drop)"
            exit 498
        }
        else {
            gettoken action armvars : armvars
            local error 0
            if "`action'"=="drop" { // syntax: armvars(drop)
                if !mi("`armvars'") local error 1
            }
            else if "`action'"=="keep" {
                if mi("`armvars'") { // syntax: armvars(keep)
                    local othervars `probvars'
                    local probvars
                }
                else { // syntax: armvars(keep <varlist>)
                    if "`armvars'"=="_all" local armvars `probvars'
                    else unab armvars : `armvars'
                    local othervars : list probvars & armvars
                    local probvars : list probvars - armvars
                }
            }
            else local error 1
            if `error' {
                di as error "Syntax: armvars(keep [varlist] | drop)"
                exit 198
            }
            if !mi("`probvars'") {
                di as text "Dropping arm-level variables: " `col2' "`probvars'"
                drop `probvars'
            }
            if !mi("`othervars'") {
                di as text "Reshaping arm-level variables: " `col2' "`othervars'"
            }
        }
    }

    * reshape to wide
    `ifdebugnoi' di as text "(reshaping to wide format)"
    qui reshape wide `rawvars' `othervars', i(`studyvar') j(`trtcode') string

    * and label variables
    foreach trtcode in `trtcodes' {
        foreach rawvar in `rawvars' {
            label var `rawvar'`trtcode' `"`rawvar' for `trtname`trtcode''"'
        }
    }
}

// IF DATA ARE IN WIDE FORMAT: READ TREATMENT NAMES, DROP UNWANTED VARIABLES, AND CODE TREATMENTS 
else {
    if !mi("`debug'") noi di as text "Data are in wide format ..."
    if "`studyvar'"=="" {
        tempvar studyvar
        gen `studyvar'=_n
    }
    isid `studyvar'
    unab dlist0 : `n'*
    if "`dlist0'" == "`n'" {
        di as error "Wide format implied, but no variables `n'+prefix"
        exit 198
    }

    * identify treatments
    foreach nvar of varlist `n'* {
        if "`nvar'" != "`n'" {
            local missingvars
			local trt = substr("`nvar'",length("`n'")+1,.)
            foreach rawvar in `rawvars' {
                cap confirm var `rawvar'`trt'
                if _rc local missingvars `missingvars' `rawvar'`trt'
			}
			if !mi("`missingvars'") 	{
				noi di as text "Warning: ignoring variable" as result " `nvar' " ///
					as text "because variable(s) " as result "`missingvars'" as text " not found"
            }
			else local trtvarlevels `trtvarlevels' `trt'
		}
	}

    if !mi(`"`trtlist'"') { // treatments specified: just check
        foreach trt in `trtlist' {
            foreach var in `rawvars' {
                confirm numeric var `var'`trt' // numeric: 9oct2017
            }
        }
        local droptrts : list trtvarlevels - trtlist
        foreach droptrt in `droptrts' {
            foreach rawvar in `rawvars' {
                drop `rawvar'`droptrt'
            }
        }
    }
    else local trtlist `"`trtvarlevels'"'
    if mi(`"`trtlist'"') {
        di as error "Failed to find a list of treatments"
        exit 499
    }
    
    * code treatments
    local ntrts : word count `trtlist'
    local r 0
    foreach trtname in `trtlist' {
        local ++r
        if "`codes'"=="nocodes" { // don't code 
            local thistrtcode = strtoname("`trtname'",0)
        }
        else if mi("`numcodes'") { // code as letters
            if `ntrts'<=26 local thistrtcode = char(64+`r')
            else local thistrtcode = char(65+int((`r'-1)/26)) + char(65+mod(`r'-1,26))
        }
        else { // code as numbers 
            local thistrtcode = "0"*`=length("`ntrts'")-length("`r'")' + "`r'"
        }
        local trtcodes `trtcodes' `thistrtcode'
        local trtname`thistrtcode' `trtname'
        foreach rawvar in `rawvars' {
            confirm numeric var `rawvar'`trtname' // 9oct2017
			qui rename `rawvar'`trtname' `rawvar'`thistrtcode'
            label var `rawvar'`thistrtcode' `"`rawvar' for `trtname'"'
        }
        `ifdebugnoi' di as text `"Treatment `trtname' has code `thistrtcode'"'
    }
}

// Data now should be wide with vars `studyvar' `n'A, `n'B etc.
`ifdebugnoi' di as text "(data are now in common format)"

// Count valid studies
tempvar narms
gen `narms'=0
foreach trt in `trtcodes' {
    qui replace `narms'=`narms'+1 if !mi(`n'`trt')
    local nnames `nnames' `n'`trt'
}
qui count if `narms'<=1
local nstudiesdropped = r(N)
qui drop if `narms'<=1
summ `narms', meanonly
local maxarms = r(max)
qui count
local nstudies = r(N)

// Create design variables
qui gen `design' = ""
foreach trt in `trtcodes' {
    qui replace `design' = `design' + cond(mi(`design'),""," ") + "`trt'" if !mi(`n'`trt')
}
* and sort designs
forvalues i=1/`=_N' {
	local thisdesign = `design'[`i']
	local thisdesign : list sort thisdesign
	qui replace `design' = "`thisdesign'" in `i'
}

// Generate study components
network_components, design(`design') trtlist(`trtcodes') gen(`component')
assert !mi(`component')
local ncomponents = r(ncomponents)
if `ncomponents'==1 {
	drop `component'
	local component
}

// Identify overall reference treatment
if !mi(`"`ref'"') {
    foreach trtcode in `trtcodes' {
        if `"`ref'"' == `"`trtname`trtcode''"' local ref2 `trtcode'
    }
    if mi("`ref2'") {
        di as error `"ref(`ref'): treatment `ref' not found"'
        exit 198
    }
}
if mi(`"`ref2'"') local ref2 : word 1 of `trtcodes'
local ref `ref2'
local trtlistnoref : list trtcodes - ref

// OUTPUT - 1ST PART
if !mi(`"`droptrts'"') {
    di as text "Treatments dropped:" `col2' _c
    local i 0
    foreach droptrt in `droptrts' {
        if `i' di as result ", " _c
        di as result `"`droptrt'"' _c
        local ++i
    }
    di
}
di as text "Treatments used"
foreach trtcode in `trtcodes' {
    di as text `col1' "`trtcode'" _c
    if "`trtcode'"=="`ref'" di " (reference)" _c
    di as text ":" `col2' `"`trtname`trtcode''"'
}

di as text _new "Measure" `col2' "`measure'"
if !mi("`md'`smd'") di as text `col1' "Standard deviation pooling:" `col2' "`sdpool'"

di as text _new "Studies"
di as text `col1' "ID variable: " _c
if !mi("`studyvar'") di `col2' "`studyvar'"
else di `col2' "[none]"
if `nstudiesdropped' di `col1' "Number dropped:" `col2' "`nstudiesdropped'"
di `col1' "Number used: " `col2' `nstudies'

// add half if zero cells
if "`outcome'"=="count" {
    tempvar haszero
    gen `haszero' = 0
    foreach trt in `trtcodes' {
        qui replace `haszero' = 1 if !mi(`d'`trt') & (`d'`trt'==0 | `d'`trt'==`n'`trt')
    }
    qui count if `haszero'
    noi di `col1' "IDs with zero cells: " _c
    if r(N)>0 {
        qui levelsof `studyvar' if `haszero', local(haszerostudies)
        noi di `col2' `"`haszerostudies'"'
        noi di `col1' "- count added to all their cells: " `col2' `zeroadd'
        foreach trt in `trtcodes' {
            qui replace `d'`trt'=`d'`trt'+`zeroadd' if `haszero'
            if "`hr'"!="hr" qui replace `n'`trt'=`n'`trt'+2*`zeroadd' if `haszero'
        }
    }
    else noi di `col2' "[none]"
    drop `haszero'
}

// AUGMENT IF MISSING REF ARM

* choose augment settings if not specified
if mi("`augment'") local augment 0.00001
if "`outcome'"=="count" local augsd 0
local augmeanname `augmean'
local augsdname `augsd'
if mi("`augmean'","`augsd'") { // compute overall means [& SDs]
    tempvar nsum nmeansum nsdsum
    foreach var in nsum nmeansum nsdsum {
        qui gen ``var''=0
    }
    foreach trt in `trtcodes' {
        qui replace `nsum'=`nsum' + `n'`trt' if !mi(`n'`trt')
        if "`outcome'"=="count" {
            qui replace `nmeansum' = `nmeansum' + `d'`trt' if !mi(`n'`trt')
        }
        else if "`outcome'"=="quantitative" {
            qui replace `nmeansum' = `nmeansum' + `mean'`trt' * `n'`trt' if !mi(`n'`trt')
            qui replace `nsdsum' = `nsdsum' + `sd'`trt' * `n'`trt' if !mi(`n'`trt')
        }
    }
    if mi("`augmean'") { // and assign
        tempvar augmean
        gen `augmean' = `nmeansum'/`nsum'
        if !mi("`augoverall'") {
            qui summ `augmean' [fw=`nsum'], meanonly
            qui replace `augmean' = r(mean)
        }
        local augmeanname "study-specific mean"
    }
    if mi("`augsd'") { // and assign
        tempvar augsd
        gen `augsd' = `nsdsum'/`nsum'
        if !mi("`augoverall'") {
            qui summ `augsd' [fw=`nsum'], meanonly
            qui replace `augsd' = r(mean)
        }
        local augsdname "study-specific within-arms SD"
    }
    drop `nsum' `nmeansum' `nsdsum'
}

* check augment, augmean, augsd are valid expressions
tempvar temp
cap gen `temp'=`augment'
if _rc di as error "Error: augment(`augment') must be an expression"
cap replace `temp'=`augmean'
if _rc di as error "Error: augmean(`augmean') must be an expression"
cap replace `temp'=`augsd'
if _rc & "`outcome'"=="quantitative" di as error "Error: augsd(`augsd') must be an expression"
drop `temp'

tempvar augmented
gen `augmented' = mi(`n'`ref')
qui levelsof `studyvar' if mi(`n'`ref'), local(augmentstudies)
qui replace `n'`ref'=`augment' if `augmented'
if "`outcome'"=="count" qui replace `d'`ref'=(`augment')*(`augmean') if `augmented'
else if "`outcome'"=="quantitative" {
    qui replace `mean'`ref' = `augmean' if `augmented'
    qui replace `sd'`ref' = `augsd' if `augmented'
}
if !mi("`augmentstudies'") & "`targetformat'"=="augmented" {
    noi di `col1' "IDs with augmented reference arm: " `col2' `"`augmentstudies'"'
    noi di `col1' "- observations added:" `col2' "`augment'"
    noi di `col1' "- mean in augmented observations:" `col2' "`augmeanname'"
    if "`outcome'"=="quantitative" noi di `col1' "- SD in augmented observations:" `col2' "`augsdname'"
}

// COMPUTE CONTRASTS AND THEIR VARIANCES
if "`outcome'"=="count" {
    tempvar variance
    foreach trt in `trtcodes' { 
		// check added 6apr2018
		qui count if (`d'`trt'<0 | `d'`trt'>`n'`trt') & !mi(`d'`trt',`n'`trt') 
		if r(N) {
			di as error "Must have 0<#events<#total for treatment `trt'"
			exit 498
		}
		if "`or'"=="or" {
            qui gen double `y'_`trt' = log(`d'`trt'/(`n'`trt'-`d'`trt'))
            qui gen double `variance'`trt' = 1/`d'`trt'+1/(`n'`trt'-`d'`trt')
        }
        else if "`rr'"=="rr" {
            qui gen double `y'_`trt' = log(`d'`trt'/`n'`trt')
            qui gen double `variance'`trt' = 1/`d'`trt'-1/`n'`trt'
        }
        else if "`rd'"=="rd" {
            qui gen double `y'_`trt' = `d'`trt'/`n'`trt'
            qui gen double `variance'`trt' = `y'_`trt'*(1-`y'_`trt')/`n'`trt'
        }
        else if "`hr'"=="hr" {
            qui gen double `y'_`trt' = log(`d'`trt'/`n'`trt')
            qui gen double `variance'`trt' = 1/`d'`trt'
        }
    }
    foreach trt in `trtlistnoref' {
        qui replace `y'_`trt' = `y'_`trt' - `y'_`ref'
        label var `y'_`trt' "`measure' `trt' vs. `ref'"
        qui gen double `S'_`trt'_`trt' = `variance'`trt' + `variance'`ref'
        label var `S'_`trt'_`trt' "Variance of `y'_`trt'"
        foreach trt2 in `trtlistnoref' {
            if "`trt2'">"`trt'" {
                qui gen double `S'_`trt'_`trt2' = `variance'`ref' if !mi(`d'`trt') & !mi(`d'`trt2')
                label var `S'_`trt'_`trt2' "Covariance of `y'_`trt' and `y'_`trt2'"
            }
        }
        cap drop `S'_`trt'_`ref'
        cap drop `S'_`ref'_`trt'
    }
    foreach trt in `trtcodes' {
        drop `variance'`trt'
    }
    drop `y'_`ref'
}
else if "`outcome'"=="quantitative" {
    tempvar pooledsd pooleddf
    * find pooled SDs (across all arms)
    gen `pooledsd'=0
    gen `pooleddf'=0
    foreach trt in `trtcodes' {
        qui replace `pooledsd' = `pooledsd' + (`n'`trt'-1)*(`sd'`trt'^2) if !mi(`n'`trt')
        qui replace `pooleddf' = `pooleddf' + (`n'`trt'-1) if !mi(`n'`trt')
        if "`sdpool'"=="on" local newsd`trt' `pooledsd'
        else local newsd`trt' `sd'`trt'
    }
    qui replace `pooledsd' = sqrt(`pooledsd'/`pooleddf')
    * prepare for SMD
    if "`smd'"=="smd" {
        tempvar Jnu Knu 
        if "`asymptotic'"=="asymptotic" { // ignore finite-sample corrections
            gen `Jnu' = 1
            gen `Knu' = 0
        }
        else {
            gen `Jnu' = exp( lngamma(`pooleddf'/2) - 0.5*log(`pooleddf'/2) - lngamma((`pooleddf'-1)/2) )
            gen `Knu' = 1 - (`pooleddf'-2) / (`pooleddf' * `Jnu'^2)
        }
    }
    * estimate means and variances
    foreach trt in `trtlistnoref' {
        qui gen double `y'_`trt' = `mean'`trt' - `mean'`ref'
        if "`smd'"=="smd" qui replace `y'_`trt' = `y'_`trt' * `Jnu' / `pooledsd'
        label var `y'_`trt' "`measure' `trt' vs. `ref'"
        qui gen double `S'_`trt'_`trt' = (`newsd`trt'')^2/`n'`trt' + (`newsd`ref'')^2/`n'`ref'
        * correctly use equation (14) instead of (10) of White & Thomas 2005:
        if "`smd'"=="smd" qui replace `S'_`trt'_`trt' = `S'_`trt'_`trt'/`pooledsd'^2 + `y'_`trt'^2*`Knu'
        label var `S'_`trt'_`trt' "Variance of `y'_`trt'"
    }
    * estimate covariances
    foreach trt in `trtlistnoref' {
        foreach trt2 in `trtlistnoref' {
            if "`trt2'">"`trt'" {
                qui gen double `S'_`trt'_`trt2' = (`newsd`ref'')^2 * (1/`n'`ref') if !mi(`n'`trt') & !mi(`n'`trt2')
                * correctly use equation (14) instead of (10) of White & Thomas 2005:
                if "`smd'"=="smd" qui replace `S'_`trt'_`trt2' = `S'_`trt'_`trt2'/`pooledsd'^2 + `y'_`trt'*`y'_`trt2'*`Knu'
                label var `S'_`trt'_`trt2' "Covariance of `y'_`trt' and `y'_`trt2'"
            }
        }
        cap drop `S'_`trt'_`ref'
        cap drop `S'_`ref'_`trt'
    }
    * tidy up
    drop `pooledsd' `pooleddf' `Jnu' `Knu'
}
local opts
local dim = `ntrts' - 1

// FINISH
compute_df, nnames(`nnames') n(`n') studyvar(`studyvar') design(`design') // COMPUTE DF 
local df_inconsistency = r(df_inconsistency)
local df_heterogeneity = r(df_heterogeneity)

di as text _new "Network information" `col2' 
di as text `col1' "Components:" `col2' _c
if `ncomponents'==1 di as result "1 (connected)"
else di as error "`ncomponents' (disconnected)"
di as text `col1' "D.f. for inconsistency:" `col2' `df_inconsistency'
di as text `col1' "D.f. for heterogeneity:" `col2' `df_heterogeneity'

// STORE LOCALS AS CHARACTERISTICS
local format augmented
local allthings allthings studyvar design ref trtlistnoref 
foreach trtcode in `trtcodes' {
    local allthings `allthings' trtname`trtcode'
}
local allthings `allthings' maxarms measure outcome dim format
if "`outcome'"=="count" local allthings `allthings' d n nmiss
else if "`outcome'"=="quantitative" local allthings `allthings' mean sd n nmiss
local allthings `allthings' y S stderr contrast t1 t2 trtdiff component MNAR ///
    testcons_type testcons_stat testcons_df testcons_p ///
    metavars consistency_fitted inconsistency_fitted plot_location `trtnames' ///
    ncomponents df_inconsistency df_heterogeneity 
foreach thing in `allthings' {
    char _dta[network_`thing'] ``thing''
}


// CONVERT FORMAT IF NECESSARY - NB THIS MUST COME AFTER STORING CHARACTERISTICS
if "`targetformat'" != "augmented" {
    `ifdebugnoi' network convert `targetformat'
}
local format `targetformat'
*sort `studyvar'
restore, not

// OUTPUT - 2ND PART
di as text _new "Current data"
di as text `col1' "Data format:" `col2' "`format'"
di as text `col1' "Design variable: " `col2' "`design'"
if "`format'"=="augmented" {
    di as text `col1' "Estimate variables: " `col2' "`y'*"
    di as text `col1' "Variance variables: " `col2' "`S'*"
    di as text `col1' "Command to list the data:" `col2' _c
    di as text "{stata list `studyvar' `y'* `S'*, noo sepby(`design')}"
}
if "`format'"=="standard" {
    di as text `col1' "Estimate variables: " `col2' "`y'*"
    di as text `col1' "Variance variables: " `col2' "`S'*"
    di as text `col1' "Contrast variables: " `col2' "`contrast'*"
    di as text `col1' "Command to list the data:" `col2' _c
    di as text "{stata list `studyvar' `design' `contrast'* `y'* `S'*, noo sepby(`design')}"
}
if "`format'"=="pairs" {
    di as text `col1' "Estimate variable: " `col2' "`y'"
    di as text `col1' "Standard error variable: " `col2' "`stderr'"
    di as text `col1' "Contrast variable: " `col2' "`contrast'"
    di as text `col1' "Command to list the data:" `col2' _c
    di as text "{stata list `studyvar' `design' `contrast' `y'* `stderr'*, noo sepby(`design')}"
}
cap estimates drop consistency
cap estimates drop inconsistency
end


***************************************************************************************

prog def compute_df, rclass
* computes degrees of freedom for inconsistency & heterogeneity
syntax, nnames(varlist) n(string) studyvar(varname) design(varname)
preserve
* prepare data
keep `studyvar' `nnames' `design'
tempvar treat
qui reshape long `n', i(`studyvar') j(`treat') string
foreach var in studyvar treat design { // if string, convert to numeric 
	cap confirm string var ``var''
	if !_rc {
		tempvar `var'num
		encode ``var'', gen(``var'num')
		local `var' ``var'num'
	}
}	
* fit anova
local emptycells = c(emptycells)
set emptycells drop
qui anova `n' `studyvar' `treat' `treat'#`design' if !mi(`n') & `n'>=1
set emptycells `emptycells'
return scalar df_inconsistency = e(df_3)
return scalar df_heterogeneity = e(df_r)
end

***************************************************************************************
