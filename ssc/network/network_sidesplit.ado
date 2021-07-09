/*
*! version 1.2.0 # Ian White # 3jul2015
    prints warning if MNAR has been set
version 1.1 # Ian White # 8jun2015
28may2015
    improved output table column widths
<26may2015
    checks for evidence in the indirect studies; revised help file explains why this isn't the same as checking for identification
11may2015
    new tau option
version 1.0 # Ian White # 9Sep2014 
version 0.6 # 6jun2014
    works for standard format
    fixed coding error for inco parameter
    drops metavars and records new ones
    reports direct and indirect estimates as well as difference 
    rclass; stores output as matrices
4oct2013
    istrt.ado stored here
*/

prog def network_sidesplit, rclass

// LOAD NETWORK CHARS
if mi("`_dta[network_allthings]'") {
	di as error "Data are not in network format"
	exit 459
}
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
if "`format'"=="pairs" {
    di as error "Sorry, network sidesplit currently only works for augmented or standard format"
    exit 498
}

// PARSE
syntax [anything] [if] [in], ///
    [double cformat(string) pformat(string) /// undocumented
    tau show * /// documented
    ]
if mi("`cformat'") local cformat `c(cformat)'
if mi("`cformat'") local cformat %9.0g
if mi("`pformat'") local pformat `c(pformat)'
if mi("`pformat'") local pformat %5.3f

if !mi("`MNAR'") di as error "Warning: data were computed under MNAR using options: " as error "`MNAR'"

marksample touse

// IF CALL IS -NETWORK SIDESPLIT ALL- THEN REPEATEDLY RE-CALL THIS PROGRAM 
if "`anything'"=="all" { 

    * Extra parsing
    if !mi("`show'") {
        di as error "network sidesplit all: show option ignored"
        local show
    }

    * Create "has" indicators
    foreach trt in `ref' `trtlistnoref' { 
        tempvar has`trt'
        qui gen `has`trt'' = strpos(" "+`design'+" "," `trt' ")>0 if `touse'
    }

    * Choose output column widths
    local place 1
    forvalues i=1/8 {
        if `i'==1 local width 8
        else if `i'<=7 local width = max(10, length(string(-1/3,"`cformat'"))+2) 
        else local width = max(5, length(string(-1/3,"`pformat'"))+2)
        local place = `place'+`width'
        local col`i' _col(`place')
    }   

    * Print output column header
    di as text _new "Side" `col1' "Direct" `col3' "Indirect" `col5' "Difference" _c
    if !mi("`tau'") di `col8' "tau"_c
    di
    di as text `col1' "Coef." `col2' "Std. Err." `col3' "Coef." `col4' "Std. Err." ///
       `col5' "Coef." `col6' "Std. Err." `col7' "P>|z|" 

    * Loop over pairs of treatments
    tempname b V ball Vall 
    local no_outside_evidence 0
    foreach side1 in `ref' `trtlistnoref' {
        foreach side2 in `ref' `trtlistnoref' {
            if "`side1'" == "`side2'" continue
            if mi("`double'") & "`side1'" > "`side2'" continue
            qui count if `has`side1'' & `has`side2'' & `touse'
            if r(N)==0 continue 
            * di as text _n "Splitting `side1' - `side2'" _c
            cap network sidesplit `side1' `side2' `if' `in', nof9 `options' 
            if inlist(_rc,1,198) error _rc
            if !r(outside_evidence) local no_outside_evidence 1
            if !_rc {
                mat `b' = r(b)
                mat `V' = r(V)
            }
            else {
                mat `b'=J(1,3,.)
                mat `V'=J(3,3,.)
            }
            * output results
            di as text "`side1' `side2'" _c
            if !r(outside_evidence) di " *" _c
            di as result ///
                `col1' `cformat' `b'[1,1] `col2' `cformat' sqrt(`V'[1,1]) ///
                `col3' `cformat' `b'[1,2] `col4' `cformat' sqrt(`V'[2,2]) ///
                `col5' `cformat' `b'[1,3] `col6' `cformat' sqrt(`V'[3,3]) ///
                `col7' `pformat' chi2tail(1,(`b'[1,3])^2/`V'[3,3]) _c
            if !mi("`tau'") {
                local tauvalue .
                cap local tauvalue = abs([tau]_cons)
                di `col8' `cformat' `tauvalue' _c
            }
            di
            * store results
            mat rownames `b' = "y"
            mat roweq `b' = "`side1'-`side2'"
            mat roweq `V' = "`side1'-`side2'"
            mat `ball' = (nullmat(`ball') \ `b')
            mat `Vall' = (nullmat(`Vall') \ `V')
          
        }
    }
    
    * Finish
    if `no_outside_evidence' di as text _new "* Warning: all the evidence about these contrasts comes from the trials which directly compare them." _new "See {help network_sidesplit##no_indirect_evidence:help file} for more information."
    return matrix b = `ball'
    return matrix V = `Vall'    
    exit
} // END OF CALL -NETWORK SIDESPLIT ALL-

// CALL IS -NETWORK SIDESPLIT TRT1 TRT2- 
syntax [anything] [if] [in], [show noSYmmetric tau /// documented
    Level(cilevel) nof9 bscov(passthru) /// trivial but undocumented
    * /// mvmeta options
    ]
tokenize "`anything'"
local side1 `1' // trt at start of split edge
local side2 `2' // trt at end of split edge
local error 0
if mi("`2'") | !mi("`3'") {
    di as error "Syntax: network sidesplit [all|trt1 trt2]"
    exit 198
}
istrt `side1'
istrt `side2'

if mi("`bscov'") local bscov bscov(exch 0.5)

// SET UP
preserve // -restore, not- later
cap drop `metavars' // drop previous derived variables
local metavars
tempvar has
foreach trt in `ref' `trtlistnoref' { // Create "has" indicators
    qui gen `has'`trt' = strpos(" "+`design'+" "," `trt' ")>0 if `touse'
    local droplist `droplist' `has'`trt'
}

// IS THERE EVIDENCE OUTSIDE THE DIRECT TRIALS?
/* ("Direct trial": one containing side1 and side2.)
With two-arm trials, this is the same as asking if there is indirect evidence. 
With multi-arm trials, the sidesplit model can estimate the indirect effect 
using the multi-arm direct trials (but not of course using their side1-side2 comparisons).
*/
network_components if !(`has'`side1' & `has'`side2')
local outside_evidence = r(ncomponents)==1 
if  !`outside_evidence' di as error "Warning: there is no evidence about the `side1'-`side2' contrast outside trials containing `side1' and `side2'"

// FORM SIDESPLIT MODEL
if "`format'"=="augmented" {
    local firsteq 1
    qui gen `trtdiff'one=1 if `touse'    
    qui gen `trtdiff'zero=0 if `touse'
    local metavars `metavars' `trtdiff'one `trtdiff'zero
    foreach trt in `trtlistnoref' { // build equation for outcome `trt'
        * consistency model        
        local eq`trt' `y'_`trt':
        foreach trt2 in `trtlistnoref' { // need one term for each treatment
            if `firsteq' {
                if "`trt2'"=="`trt'" qui gen  `trtdiff'`trt2'=1 if `touse'
                else                 qui gen  `trtdiff'`trt2'=0 if `touse'
                local metavars `metavars' `trtdiff'`trt2'
                local eq`trt' `eq`trt'' `trtdiff'`trt2'
                if "`trt2'"=="`side1'" local indirect `indirect' - [`y'_`trt']`trtdiff'`trt2'
                if "`trt2'"=="`side2'" local indirect `indirect' + [`y'_`trt']`trtdiff'`trt2'
            }
            else {
                if "`trt2'"=="`trt'" local eq`trt' `eq`trt'' `trtdiff'one
                else                 local eq`trt' `eq`trt'' `trtdiff'zero
            }
        }
        * side-splitting (inconsistency) term 
        if mi("`symmetric'") qui gen `trtdiff'inco`trt' =         /// new symmetric version
            0.5 * (("`side2'"=="`trt'") - ("`side2'"=="`ref'"))   /// `side2' is delta/2 more...
            - 0.5 * (("`side1'"=="`trt'") - ("`side1'"=="`ref'")) /// `side1' is delta/2 less...
            if `touse'
        else qui gen `trtdiff'inco`trt' =                         /// asymmetric version of Dias++10
            (("`side2'"=="`trt'") - ("`side2'"=="`ref'"))         /// `side2' is delta more...
            if `touse'
        qui replace `trtdiff'inco`trt' = `trtdiff'inco`trt' * `has'`side1' * `has'`side2' if `touse'
                                                            // ... in trials with side1 & side2
        if `firsteq' local diff [`y'_`trt']`trtdiff'inco`trt'
        local metavars `metavars' `trtdiff'inco`trt'
        local eq`trt' `eq`trt'' `trtdiff'inco`trt'
        * finish off
        if mi("`eqs'") local eqs `eq`trt''
        else           local eqs `eqs', `eq`trt''
        local firsteq 0
    }
}
else if "`format'"=="standard" { // taken from network_meta.ado
    tempvar thistrt base narms
    qui gen `thistrt' = ""
    qui gen `base' = word(`design',1) if `touse'
    local maxdim = `maxarms'-1
    qui gen `narms' = wordcount(`design') if `touse'
    forvalues r=1/`maxdim' {
        qui replace `thistrt' = word(`design',`r'+1) if `touse'
        * consistency model
        local eq`r' `y'_`r':
        foreach trt in `trtlistnoref' {
            qui gen `trtdiff'`r'`trt' = ("`trt'"==`thistrt') - ("`trt'"==`base') if `narms'>`r' & `touse'
            qui replace `trtdiff'`r'`trt' = 0 if `narms'<=`r' & `touse'
            local metavars `metavars' `trtdiff'`r'`trt'
            local eq`r' `eq`r'' `trtdiff'`r'`trt'
            * nlcom expressions
            if "`trt'"=="`side1'" & `r'==1 {      
                local indirect `indirect' - [`y'_`r']`trtdiff'`r'`trt'
            }
            if "`trt'"=="`side2'" & `r'==1 {      
                local indirect `indirect' + [`y'_`r']`trtdiff'`r'`trt'
            }
        }
        * side-splitting (inconsistency) term 
        if mi("`symmetric'") qui gen `trtdiff'inco`r' =        /// new symmetric version
            0.5 * (("`side2'"==`thistrt') - ("`side2'"==`base'))   /// `side2' is delta/2 more...
            - 0.5 * (("`side1'"==`thistrt') - ("`side1'"==`base')) /// `side1' is delta/2 less...
            if `touse'
        else qui gen `trtdiff'inco`r' =                        /// asymmetric version of Dias++10
            (("`side2'"==`thistrt') - ("`side2'"==`base'))     /// `side2' is delta more...
            if `touse'
        qui replace `trtdiff'inco`r' = `trtdiff'inco`r' * `has'`side1' * `has'`side2' if `touse'
                                                            // ... in trials with side1 & side2
        local metavars `metavars' `trtdiff'inco`r'
        local eq`r' `eq`r'' `trtdiff'inco`r'
        if `r'==1 local diff [`y'_`r']`trtdiff'inco`r'
        * finish off
        if mi("`eqs'") local eqs `eq`r''
        else           local eqs `eqs', `eq`r''
    }
}

local mvmetacmd mvmeta `y' `S' `if' `in', `bscov' `options' eq(`eqs') commonparm noconst network(sidesplit) suppress(uv mm)
if substr("`indirect'",1,1)=="+" local indirect : subinstr local indirect "+" ""
local direct `indirect' + `diff'

// FIT SIDESPLIT MODEL
if !mi("`show'") {
    di as text "(fitting model splitting side `side1' `side2')"
    di as input `"Command is: `mvmetacmd'"'
    `mvmetacmd'
    di as text _n "Results splitting `side1' `side2':" _c
}
else qui `mvmetacmd'

* lincom expressions
nlcom (direct:`direct') (indirect:`indirect') (difference:`diff'), noheader
if !mi("`tau'") {
    cap local tauvalue = abs([tau]_cons)
    if !_rc di as text "tau = " as result `tauvalue'
}
tempname b V
mat `b' = r(b)
mat `V' = r(V)
mat rowname `b' = "`measure'"

// FINISH OFF
drop `droplist'
char _dta[network_metavars] `metavars'
restore, not
return matrix b=`b'
return matrix V=`V'
return local side `side1' `side2'
return scalar outside_evidence = `outside_evidence'
if "`f9''"!="nof9" global F9 `mvmetacmd'
end

*==============================================================================

prog def istrt, rclass
* determines whether `1' is a valid treatment
if !mi("`2'") {
    di as error "istrt.ado: too many candidate treatments specified"
    exit 498
}
local test `1'
local istrt 0
foreach trt in `_dta[network_ref]' `_dta[network_trtlistnoref]' {
    if "`test'"=="`trt'" local istrt 1
}
if !`istrt' {
    di as error "`test' is not a valid treatment"
    exit 198
}
end

