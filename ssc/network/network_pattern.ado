/*
*! version 1.1 # Ian White # 27may2015
version 0.8 # 31jul2014
    sort trts by code (not name)
    code option renamed trtcodes
* version 0.7 # Ian White # 11jul2014
* version 0.5 # Ian White # 27jan2014
*/
prog def network_pattern
version 12
syntax [if] [in], [TRTCodes *]
marksample touse
// Load saved network parameters
if mi("`_dta[network_allthings]'") {
	di as error "Data are not in network format"
	exit 459
}
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
local trtlist `ref' `trtlistnoref'
local trtlist : list sort trtlist
foreach trt in `trtlist' {
    tempvar obs`trt'
	qui gen `obs`trt''=1 if strpos(" "+`design'+" "," `trt' ")>0 & `touse'
	if mi("`trtcodes'") label var `obs`trt'' `"`trtname`trt''"'
    else label var `obs`trt'' "`trt'"
    local varlist `varlist' `obs`trt'' 
}

qui misspattern `varlist' if `touse', label indivsname(studies) novarsort `options'
end

