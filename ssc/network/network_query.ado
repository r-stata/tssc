/*
*! version 1.1 # Ian White # 27may2015
14mar2015
	corrected outputting for augmented format
version 1.0 # Ian White # 9Sep2014 
version 0.8 # Ian White # 31jul2014
    trtnames option lists only the treatment names
version 0.5 # Ian White # 27jan2014
*/
prog def network_query

// check saved network parameters
if mi("`_dta[network_allthings]'") {
	di as error "Data are not in network format"
	exit 459
}
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}

syntax, [Trtnames]

if !mi("`trtnames'") {
    local trtcodes `ref' `trtlistnoref'
    local trtcodes : list sort trtcodes
    local first 1
    foreach trtcode in `trtcodes' {
        if !`first'  di as result ", " _c
        di as result `"`trtcode' = `trtname`trtcode''"' _c
        if "`trtcode'" == "`ref'" di as result " (ref)" _c
        local first 0
    }
    di
}
else foreach thing in `allthings' {
    local `thing' : char _dta[network_`thing']
    if "`format'"=="standard"  & inlist("`thing'","stderr","t1","t2") continue
    if "`format'"=="augmented" & inlist("`thing'","stderr","contrast","trtdiff","t1","t2") continue
    if "`format'"=="pairs"     & inlist("`thing'","S") continue
	if "``thing''" != "N/A" & "`thing'" != "allthings" {
        di _col(10) as text "`thing'" _col(34) _c
        if inlist("`thing'","consistency_estimates", "inconsistency_estimates") & !mi("``thing''") {
            di "{stata estimates replay ``thing'':``thing''}"
        }
        else di as result "``thing''"
    }
}
end
