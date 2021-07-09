/*
*! Ian White # 4apr2018
	default changed from large(1E4) to large(1E5)
version 1.1 # Ian White # 8jun2015
8jun2015
    "binomial" changed to "count"
    minor bug fix: `large' was added multiple times; now added only once
27may2015: drops metavars (previously needed to save them for network forest)
version 0.8 # 31jul2014 
    failed with unsorted `design' - fixed
version 0.7 # 11jul2014
version 0.6 # 6jun2014
version 0.5 # 27jan2014
version 0.4 # 18dec2013
*/

prog def network_convert

// Load saved network parameters
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
local maxdim = `maxarms'-1
local oldref `ref'

// PARSE
syntax anything, [large(real 0) ref(string) noWarning]
local newformat `anything'
local oldformat `format'
if strpos("augmented","`newformat'")==1 local newformat augmented
if strpos("standard","`newformat'")==1 local newformat standard
if strpos("pairs","`newformat'")==1 local newformat pairs
if !inlist("`newformat'","augmented","standard","pairs") {
    di as error "Syntax: network convert augmented|standard|pairs"
    exit 198
}
if "`warning'"=="nowarning" local diaserror *
else local diaserror di as error

* large value for augmenting
if "`newformat'"=="augmented" {
    if `large'==0 local large 100000
}
else if `large'!=0 {
    `diaserror' "large(`large') ignored because we're not converting to augmented format"
}

* new reference treatment
if "`newformat'"!="augmented" & !mi("`ref'") {
    `diaserror' "ref(`ref') ignored because we're not converting to augmented format"
    local ref
}
if !mi("`ref'") {
    local ok : list ref in trtlistnoref
    if !`ok' {
        if "`ref'"!="`oldref'" {
            di as error "Invalid ref(`ref')"
            exit 198
        }
    }
    else { // update locals ref and trtlistnoref
        local trtlistnoref : list trtlistnoref - ref
        local trtlistnoref : list trtlistnoref | oldref
        local trtlistnoref : list sort trtlistnoref
        local newref `ref'
        local newreftext "with ref `ref' "
    }
}
else local ref `oldref'

if "`newformat'"=="`oldformat'" & mi("`newref'") {
    `diaserror' "Data are already in `newformat' format"
    exit
}

// CALL THE CONVERSION PROGRAM(S)
di as text "Converting `oldformat' to `newformat' `newreftext'..."
if "`oldformat'"=="standard" & "`newformat'"=="augmented" {
    std2aug `large' `newref'
}
else if "`oldformat'"=="augmented" & "`newformat'"=="pairs" {
    aug2pairs
}
else if "`oldformat'"=="pairs" & "`newformat'"=="standard" {
    pairs2std
}
else if "`oldformat'"=="augmented" & "`newformat'"=="standard" {
    aug2pairs
    pairs2std
}
else if "`oldformat'"=="standard" & "`newformat'"=="pairs" {
    std2aug `large'
    aug2pairs
}
else if "`oldformat'"=="pairs" & "`newformat'"=="augmented" {
    pairs2std
    std2aug `large' `newref'
}
else if "`oldformat'"=="augmented" & "`newformat'"=="augmented" {
    aug2pairs
    pairs2std
    std2aug `large' `newref'
}

// tidying up
if "`newformat'"=="pairs" {
	local dim 1
}
if "`newformat'"=="standard" {
	local dim = `maxarms'-1
}
if "`newformat'"=="augmented" {
	local dim = wordcount("`trtlistnoref'")
}
if !mi("`metavars'") drop `metavars'
local metavars

// update characteristics
local format `newformat'
foreach thing in `_dta[network_allthings]' {
    char _dta[network_`thing'] ``thing''
}
end

*************************** STANDARD TO augmented *****************************

prog def std2aug
local large `1'
local newref `2'
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
local maxdim = `maxarms'-1
tempvar has
foreach trt in `ref' `trtlistnoref' { // Create "has" indicators
    gen `has'`trt' = strpos(" "+`design'+" "," `trt' ")>0
    local droplist `droplist' `has'`trt'
}

* change ref
if !mi("`newref'") {
    local trtlistnoref : list trtlistnoref - newref
    local trtlistnoref : list trtlistnoref | ref
    local trtlistnoref : list sort trtlistnoref
    local ref `newref'
}

* treatment effects
foreach trt in `trtlistnoref' {
	qui gen double _`y'_`trt' = 0 if `has'`trt'
	forvalues r=1/`maxdim' {
		qui replace _`y'_`trt' = _`y'_`trt' + `y'_`r' if word(`design',`r'+1)=="`trt'"
    	qui replace _`y'_`trt' = _`y'_`trt' - `y'_`r' if word(`design',`r'+1)=="`ref'"
	}
	label var _`y'_`trt' "`measure'"
}

* variances
tempvar Sterm
gen double `Sterm'=0
foreach trt1 in `trtlistnoref' {
	foreach trt2 in `trtlistnoref' {
		if "`trt2'" < "`trt1'" continue
		qui gen double _`S'_`trt1'_`trt2' = 0 if `has'`trt1' & `has'`trt2'
		forvalues r1=1/`maxdim' {
			forvalues r2=1/`maxdim' {
				if `r2'>=`r1' qui replace `Sterm' = `S'_`r1'_`r2'
                else qui replace `Sterm' = `S'_`r2'_`r1'
				qui replace _`S'_`trt1'_`trt2' = _`S'_`trt1'_`trt2' + `Sterm' if word(`design',`r1'+1)=="`trt1'" & word(`design',`r2'+1)=="`trt2'"
				qui replace _`S'_`trt1'_`trt2' = _`S'_`trt1'_`trt2' - `Sterm' if word(`design',`r1'+1)=="`trt1'" & word(`design',`r2'+1)=="`ref'"
				qui replace _`S'_`trt1'_`trt2' = _`S'_`trt1'_`trt2' - `Sterm' if word(`design',`r1'+1)=="`ref'" & word(`design',`r2'+1)=="`trt2'"
				qui replace _`S'_`trt1'_`trt2' = _`S'_`trt1'_`trt2' + `Sterm' if word(`design',`r1'+1)=="`ref'" & word(`design',`r2'+1)=="`ref'"
			}
		}
		qui replace _`S'_`trt1'_`trt2' = _`S'_`trt1'_`trt2' + `large' if !`has'`ref'
	}
}

* raw (data) vars
if "`outcome'"=="count" local rawvars `d' `n'
else local rawvars `mean' `sd' `n'
foreach trt in `ref' `trtlistnoref' {
    foreach rawvar in `rawvars' {
    	qui gen _`rawvar'`trt' = .
    	forvalues r=0/`maxdim' {
    		qui replace _`rawvar'`trt' = `rawvar'`r' if word(`design',`r'+1)=="`trt'"
    	}
        order _`rawvar'`trt', before(`design')
    }
}

// TIDY UP
forvalues r1=1/`maxdim' {
	drop `y'_`r1'
	drop `contrast'_`r1'
	forvalues r2=`r1'/`maxdim' {
		drop `S'_`r1'_`r2'
	}
}
foreach trt1 in `trtlistnoref' {
	rename _`y'_`trt1' `y'_`trt1'
	foreach trt2 in `trtlistnoref' {
		cap rename _`S'_`trt1'_`trt2' `S'_`trt1'_`trt2'
	}
}
foreach rawvar in `rawvars' {
   	forvalues r=0/`maxdim' {
   		drop `rawvar'`r'
   	}
    foreach trt in `ref' `trtlistnoref' {
        rename _`rawvar'`trt' `rawvar'`trt'
    }
}

drop `droplist'
if !mi("`newref'") {
    char _dta[network_ref] `ref'
    char _dta[network_trtlistnoref] `trtlistnoref'
}
end

****************************** augmented TO PAIRS *****************************

prog def aug2pairs
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
tempvar narms
gen `narms' = wordcount(`design')
tempvar rep1 rep2
qui expand `narms'-1
sort `studyvar'
qui by `studyvar': gen `rep1' = _n
qui expand `narms'-`rep1'
sort `studyvar' `rep1'
qui by `studyvar' `rep1': gen `rep2' = `rep1'+_n
gen `t1' = word(`design',`rep1')
gen `t2' = word(`design',`rep2')
label var `t1' "Baseline treatment"
label var `t2' "Other treatment"
gen double _`y'=0
gen double `stderr'=0
foreach trt1 in `trtlistnoref' {
	qui replace _`y'=_`y'-`y'_`trt1' if `t1'=="`trt1'"
	qui replace _`y'=_`y'+`y'_`trt1' if `t2'=="`trt1'"
	qui replace `stderr'=`stderr'+`S'_`trt1'_`trt1' if `t1'=="`trt1'" | `t2'=="`trt1'"
	foreach trt2 in `trtlistnoref' {
		if "`trt2'"<="`trt1'" continue
		qui replace `stderr'=`stderr' - 2*`S'_`trt1'_`trt2' if `t1'=="`trt1'" & `t2'=="`trt2'"
	}
}

* raw (data) vars
if "`outcome'"=="count" local rawvars `d' `n'
else local rawvars `mean' `sd' `n'
forvalues j=1/2 {
    foreach rawvar in `rawvars' {
       qui gen _`rawvar'`j' = `rawvar'`ref' if 0 // right type, all missing
       order _`rawvar'`j', before(`design')
    }
}
foreach trt1 in `ref' `trtlistnoref' {
    foreach rawvar in `rawvars' {
        qui replace _`rawvar'1 = `rawvar'`trt1' if `t1'=="`trt1'"
        qui replace _`rawvar'2 = `rawvar'`trt1' if `t2'=="`trt1'"
    }
}

* tidy up
qui replace `stderr' = sqrt(`stderr')
gen `contrast' = `t2' + " - " + `t1'
label var _`y' "`measure'"
label var `stderr' "std error of `y'"
foreach trt in `trtlistnoref' {
	drop `y'_`trt'
	foreach trt2 in `trtlistnoref' {
		cap drop `S'_`trt'_`trt2'
	}
}
rename _`y' `y'
foreach rawvar in `rawvars' {
    foreach trt in `ref' `trtlistnoref' {
        drop `rawvar'`trt'
    }
    rename _`rawvar'1 `rawvar'1
    rename _`rawvar'2 `rawvar'2
}
end

************************ PAIRS TO STANDARD ****************************

prog def pairs2std
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
tempvar one row nrows narms base incbase reverse newcontrast trt1 trt2
* treatments compared, allowing them to be in non-alphabetic order
if !mi("`t1'`t2'") drop `t1' `t2'
gen `reverse' = word(`contrast',3)>word(`contrast',1)
qui gen `t1' = cond(`reverse', word(`contrast',1), word(`contrast',3))
qui gen `t2' = cond(`reverse', word(`contrast',3), word(`contrast',1))

sort `studyvar'
qui by `studyvar': gen `row'=_n

gen `one'=1
egen `nrows' = count(`one'), by(`studyvar')
gen `narms' = (1+sqrt(1+8*`nrows'))/2
* di "Number of studies by arms"
* tab `narms' if `row'==1
local maxdim = `maxarms'-1

qui gen `base' = `t1' if `row'==1
qui replace `base'=`base'[_n-1] if mi(`base')

* treatment effects
forvalues r=1/`maxdim' {
	qui gen double `y'_`r' = cond(`reverse',-`y',`y') if `t1'==word(`design',1) & `t2'==word(`design',`r'+1)
	local sumlist `sumlist' `y'_`r'
}
* variances
forvalues r=1/`maxdim' {
	qui gen double `S'_`r'_`r'=(`stderr'^2) if `t1'==word(`design',1) & `t2'==word(`design',`r'+1)
	forvalues s=`r'/`maxdim' {
		local sumlist `sumlist' `S'_`r'_`s'
		if `s'==`r' continue
		qui gen double `S'_`r'_`s'=.
		qui replace `S'_`r'_`s' = -0.5*(`stderr'^2) if `t1'==word(`design',`r'+1) & `t2'==word(`design',`s'+1) & `narms'>`s'
		qui replace `S'_`r'_`s' = 0.5*(`stderr'^2) if `t1'==word(`design',1) & `t2'==word(`design',`r'+1) & `narms'>`s'
		qui replace `S'_`r'_`s' = 0.5*(`stderr'^2) if `t1'==word(`design',1) & `t2'==word(`design',`s'+1) & `narms'>`s'
	}
}
* contrasts
forvalues r=1/`maxdim' {
	qui gen `contrast'_`r' = word(`design',`r'+1) + " - " + word(`design',1) if `narms'>`r'
}
* raw vars
if "`outcome'"=="count" local rawvars `d' `n'
else local rawvars `mean' `sd' `n'
forvalues r=0/`maxdim' {
    foreach rawvar in `rawvars' {
    	qui gen _`rawvar'`r' = `rawvar'1 if `t1'==word(`design',`r'+1)
    	qui replace _`rawvar'`r' = `rawvar'2 if `t2'==word(`design',`r'+1)
        local meanlist `meanlist' _`rawvar'`r'
        order _`rawvar'`r', before(`design')
    }
}

* finish off
foreach var in `meanlist' { // raw vars may be duplicated; get carried down
	qui by `studyvar': replace `var' = `var'[_n-1] if mi(`var')
}
foreach var in `sumlist' { // covariances in particular get summed
	qui by `studyvar': replace `var'=sum(`var')
}
forvalues r=1/`maxdim' {
	qui replace `y'_`r'=. if `narms'<=`r'
	forvalues s=`r'/`maxdim' {
		qui replace `S'_`r'_`s'=. if `narms'<=`s'
	}
}
qui keep if `row'==`nrows'
drop `y' `stderr' `contrast'
drop `t1' `t2'
foreach rawvar in `rawvars' {
    drop `rawvar'1 `rawvar'2
    forvalues r=0/`maxdim' {
        rename _`rawvar'`r' `rawvar'`r'
    }
}
end

**********************************************************************
