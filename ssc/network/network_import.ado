/*
*! Ian White # 6apr2018
	new measure() option
version 1.1 # Ian White # 27may2015
11may2015
    import also from augmented format
    restructured to do this
version 1.0 # Ian White # 9Sep2014 
version 0.8 # 31jul2014
    _design is in sorted order
version 0.7 # Ian White # 11jul2014
version 0.6 # Ian White # 6jun2014
version 0.5 # Ian White # 27jan2014

NB networkplot takes treatments in alphabetical order
*/

program define network_import

// PARSE

* main parse, to identify syntax errors and store options
syntax [if] [in], STUDyvar(varname) [TReat(varlist min=2 max=2) EFFect(name) ///
	STDErr(varname) VARiance(name) ref(string) ///
	MEAsure(string) trtlist(string) GENPrefix(string) GENSuffix(string) mult(real 1000)]

* is it pairs format?
cap syntax [if] [in], STUDyvar(varname) TReat(varlist min=2 max=2) ///
	EFFect(varname) STDErr(varname) [*]
if !_rc local from pairs

else {
	* is it augmented format?
	cap syntax [if] [in], STUDyvar(varname) EFFect(name) ///
		VARiance(name) ref(string) [*]
	if !_rc local from augmented
}

if mi("`from'") {
    di as error "Please specify the option set corresponding to your current data format:" 
    di _col(5) "pairs format:     treat(), effect() and stderr()"
    di _col(5) "augmented format: effect(), variance() and ref()"
    exit 198
}

di as text "Importing from " as result "`from'" as text " format"

if mi("`measure'") local measure (unidentified measure)

// END OF PARSING

if "`from'"=="pairs" {

    marksample touse

    tokenize "`treat'"
    local t1 `1'
    local t2 `2'

    * names for variables
    local y `effect'
    local names S trtdiff design contrast component // names to be read or defaulted, as in network_setup
    if mi("`genprefix'`gensuffix'") local genprefix _ // default
    foreach name in `names' {
        local `name' `genprefix'`name'`gensuffix'
    }
    
    // Convert treatment variables to string
    cap confirm numeric var `t1'
    local numeric = _rc==0
    cap confirm numeric var `t2'
    if `numeric' != (_rc==0) {
        di as error "`t1' and `t2' must be both numeric or both string"
        exit 198
    }
    if `numeric' {
        gen `t1'char = string(`t1')
        gen `t2'char = string(`t2')
        order `t1'char `t2'char, after(`t1')
        drop `t1' `t2'
        rename `t1'char `t1'
        rename `t2'char `t2'
        tempvar length
        gen `length'=max(length(`t1'),length(`t2'))
        summ `length', meanonly
        replace `t1' = "0"*(r(max)-length(`t1')) + `t1' if length(`t1')==1
        replace `t2' = "0"*(r(max)-length(`t2')) + `t2' if length(`t2')==1
        di "Converted `t1' and `t2' to string"
    }

    // Identify treatments
    qui levelsof `t1', local(t1list) clean
    qui levelsof `t2', local(t2list) clean
    local trtlist : list t1list | t2list
    local trtlist : list sort trtlist
    if mi("`ref'") local ref = word(`"`trtlist'"', 1)
    di `"Reference treatment: `ref'"'
    local trtlistnoref : list trtlist - ref
    local ntrts : word count `trtlist'
    di `"All treatments: `trtlist'"'

    tempvar row one nrows narms 

*    qui gen `y' = `effect' if `touse'
*    qui gen `stderr' = `stderrvar' if `touse'
    sort `studyvar'
    qui by `studyvar': gen `row'=_n if `touse'

    qui gen `one'=1 if `touse'
    qui egen `nrows' = count(`one') if `touse', by(`studyvar')
    qui gen `narms' = (1+sqrt(1+8*`nrows'))/2 if `touse'
    summ `narms', meanonly
    local maxarms = r(max)
    local maxdim = r(max)-1
    local dim 1

    qui gen `design'=""
    tempvar hasone hastrt
    foreach trt in `trtlist' {
    	qui gen `hasone' = (`t1'=="`trt'") | (`t2'=="`trt'") if `touse'
    	qui egen `hastrt' = max(`hasone') if `touse', by(`studyvar')
    	qui replace `design' = `design' + " `trt'" if `hastrt' & `touse'
    	drop `hasone' `hastrt'
    }
    * and sort designs
    forvalues i=1/`=_N' {
    	local thisdesign = `design'[`i']
    	local thisdesign : list sort thisdesign
    	qui replace `design' = "`thisdesign'" in `i'
    }

    qui gen `contrast' = `t2' + " - " + `t1' if `touse'

    // store as characteristics
    local format pairs

} // end of importing pairs data

else if "`from'"=="augmented" {
    * names for variables
    local y `effect'
    local S `variance'
    local names stderr trtdiff design contrast t1 t2 component // names to be read or defaulted, as in network_setup
    if mi("`genprefix'`gensuffix'") local genprefix _ // default
    foreach name in `names' {
        local `name' `genprefix'`name'`gensuffix'
    }
    
    // identify treatments, if not specified
    if mi("`trtlist'") {
        foreach var of varlist `effect'_* {
            local name = subinstr("`var'","`effect'_","",1)
            local trtlistnoref `trtlistnoref' `name'
        }
    }
    else foreach trt of local trtlist {
        if "`trt'"=="`ref'" continue
        confirm var `effect'_`trt'
        local trtlistnoref `trtlistnoref' `trt'
    }
    di "Found treatments: `ref' (ref) `trtlistnoref'"

    // create treatment name macros
    local dim 0
    foreach name in `ref' `trtlistnoref' {
        local trtname`name' `name'
        local trtnames `trtnames' trtname`name'
        local ++dim
    }

    // check we have the required `variance'* variables
    tempvar Smin 
    qui gen `Smin' = . // will hold the study min covariance - large value suggests augmented
    foreach trt1 in `trtlistnoref' {
        qui replace `Smin' = min(`Smin',`variance'_`trt1'_`trt1')
        foreach trt2 in `trtlistnoref' {
            local thiscov
            foreach possvar in `variance'_`trt1'_`trt2' `variance'_`trt2'_`trt1' {
                cap confirm var `possvar'
                if !_rc local thiscov `possvar'
            }
            if mi("`thiscov'") {
                di as error "Covariance of `effect'_`trt1' and `effect'_`trt2' not found"
                exit 498
            }
        }
    }
    summ `Smin', meanonly
    local Sminmin = r(min)

    // designs
    local trtlistsort `ref' `trtlistnoref'
    local trtlistsort : list sort trtlistsort
    qui gen `design'=""
    tempvar hastrt
    foreach trt in `trtlistsort' {
    	if "`trt'"!="`ref'" qui gen `hastrt' = !mi(`effect'_`trt')
        else qui gen `hastrt' = `Smin' < `mult'*`Sminmin'
    	qui replace `design' = `design' + " `trt'" if `hastrt'
        drop `hastrt'
    }

    // maxarms
    tempvar narms
    gen `narms' = wordcount(`design')
    summ `namrs', meanonly
    local maxarms = r(max)    
    
    // store as characteristics
    local y `effect'
    local S `variance'
    local format augmented

} // end of importing augmented data

// GENERATE STUDY COMPONENTS
network_components, design(`design') trtlist(`ref' `trtlistnoref') gen(`component')
assert !mi(`component')
local ncomponents = r(ncomponents)
if `ncomponents'==1 {
	drop `component'
	local component
}
else {
    di as error "Warning: network is disconnected (see variable _component)"
}

// FINISH OFF FOR ALL FORMATS
local allthings allthings studyvar design ref trtlistnoref maxarms measure dim format ///
    d n y S stderr contrast t1 t2 trtdiff testcons_type testcons_stat testcons_df testcons_p ///
    metavars consistency_fitted inconsistency_fitted plot_location
foreach thing in `allthings' {
    char _dta[network_`thing'] ``thing''
}

cap estimates drop consistency
cap estimates drop inconsistency 
end
