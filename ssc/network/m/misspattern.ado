*! v0.7.1  IRW  2jan2014

/************************************************************
v0.7.1  2jan2014
    clear option: graph command stored by -window push- not in F9
v0.7  25aug2011  
    nopreserve changed to clear & performance improved
v0.6  25aug2011  
    new varlabel() option allows any option for specifying the look of categorical axis labels - see help cat_axis_label_options
v0.5  16jun2011  new label option; var now numeric & labelled
For help file or SJ article:
    how to spot a monotone pattern (with example?)
    give example from DYD with secondary outcomes
        -misspattern APQ_0 LDQ_0 AUDIT_0 CORE_0- is neat
        -misspattern  total*- 
        -misspattern  APQ_* LDQ_* AUDIT_* CORE_*, novarsort- for more complex pattern
************************************************************/ 

prog def misspattern
* Display missing data patterns for a whole data set
version 10

// PARSE
syntax [varlist] [if] [in], [novarsort noidsort REVerse MISScolor(string) OBScolor(string) clear debug INDIVSname(string) label varlabel(string) *]
marksample touse, novarlist
if "`misscolor'"=="" local misscolor black
if "`obscolor'" =="" local obscolor gray
if "`indivsname'"=="" local indivsname individuals

// ANALYSE
preserve
* Keep relevant data
qui keep if `touse'
if "`varlist'"=="" local varlist _all
unab all : `varlist'
keep `varlist'
local nobs = _N

* Create missing value indicators
tempvar miss misssum one
tempname varlab
gen `misssum' = 0
local i 0
foreach var in `varlist' {
    local ++i
    if "`label'"=="label" local varlabel`i' : var label `var'
    if "`varlabel`i''"=="" local varlabel`i' `var'
    label def `varlab' `i' "`varlabel`i''", add
    gen `miss'`i' = mi(`var')
    qui replace `misssum' = `misssum' + mi(`var')
}
gen `one'=1

* Get individuals in chosen order
if "`idsort'"!="noidsort" {
    sort `misssum' `miss'*
    if "`debug'"=="debug" di "Before collapse 1"
    if "`debug'"=="debug" l
    qui collapse (sum) `one', by(`misssum' `miss'*)
    if "`debug'"=="debug" di "After collapse 1"
    if "`debug'"=="debug" l
    drop `misssum'
}
else keep `miss'* `one'

* Label and count patterns
gen pattern = _n // determines order of individuals
local npatterns = _N
di as result `npatterns' as text " patterns found"
order pattern `miss'* `one'
qui reshape long `miss', i(pattern) j(var) 
rename `miss' m
rename `one' count
sort var pattern
egen varmiss = sum(m*count), by(var)

* Add an initial non-missing pattern with count 0
* (so that first bar represents observed for all variables)
local n = _N
qui expand 2 if pattern==1
qui replace count = 0 if _n>`n'
qui replace pattern = 0 if _n>`n'
qui replace m = 0 if _n>`n'
sort var pattern

* Collapse into bars of same missingness
gen first = pattern==0 | m!=m[_n-1]
qui by var: gen bar = sum(first)
if "`debug'"=="debug" di "Before collapse 2"
if "`debug'"=="debug" l, sepby(var)
qui collapse (min) pattern (sum) count (mean) m varmiss, by(var bar)
rename pattern firstpattern // only for debugging
label val var `varlab'
if "`debug'"=="debug" di "After collapse 2"
if "`debug'"=="debug" l, sepby(var)

* Prepare bar colours
summ bar, meanonly
local nbars = r(max)
di as result `nbars' as text " bars used"
forvalues i=1/`nbars' {
    if mod(`i',2)==1 local baropt `baropt' bar(`i', col(`obscolor')) 
    if mod(`i',2)==0 local baropt `baropt' bar(`i', col(`misscolor'))
}

// DRAW GRAPH
if "`varsort'" != "novarsort" local sortopt sort(varmiss)
if "`varlabel'" != "" local varlabelopt label(`varlabel')
local graphcmd graph hbar (sum) count, ///
    over(bar) over(var, gap(0) `sortopt' `reverse' `varlabelopt') ///
    asyvars stack `baropt' ytitle(`nobs' `indivsname') ///
    legend(order(1 2) label(1 "Observed") label(2 "Missing")) ///
    `options' yscale(range(0 `nobs')) ylabel(none) outergap(0) 
capture noisily `graphcmd'
if _rc==1003 {
    di as error "Sorry - too many bars are needed: " _c
    if "`idsort'"=="noidsort" di as error "try without the noidsort option"
    else di as error "try using fewer variables"
}
if _rc exit _rc

// OPTIONALLY KEEP RESULTS IN MEMORY
if "`clear'" == "clear" {
    window push `graphcmd'
    di "Graphed data are in memory"
    di "Page-up to load graph command"
    restore, not
}

end
