/*
*! version 1.1 # Ian White # 27may2015
    changes are all in mvmeta, not here
version 0.8 # 31jul2014 
    new rename option uses trtnames
version 0.7 # 11jul2014
version 0.6.1 # 6jun2014

e.g. network rank min, all seed(317) bar cumul rep(100) legend(row(1))
    bar(1,col(red)) bar(2,col(orange)) bar(3, col(yellow)) bar(4,col(green)) 
    bar(5,col(blue)) bar(6,col(navy)) bar(7,col(purple)) bar(8,col(black))
*/
prog def network_rank

// LOAD SAVED NETWORK PARAMETERS
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}
local hasx 0
forvalues r=1/7 {
	if !mi(e(xvars_`r')) local hasx 1
}

if "`format'"!="augmented" {
    di as error "Sorry, network rank is only available in augmented format"
    exit 198
}

syntax [anything] [if] [in], [zero id(varname) TRTCodes *]
if mi("`if'`in'") & "`e(network)'"=="consistency" & !`hasx' local in "in 1"
if mi("`id'") local id `studyvar'
local idopt id(`id')
if !inlist("`anything'", "min", "max") {
    di as error "Syntax: network rank min|max, ..."
    exit 198
}
if mi("`trtcodes'") { // name the treatments
    local trtcodelist `ref' `trtlistnoref'
    local trtcodelist : list sort trtcodelist
    foreach trtcode in `trtcodelist' {
        if !mi("`rename'") local rename `rename',
        local rename `rename' `trtcode' = `trtname`trtcode''
    }
}

local mvmetacmd mvmeta, noest pbest(`anything' `if' `in', zero `idopt' ///
    `options' stripprefix(`y'_) zeroname(`ref') rename(`rename'))
di as input `"Command is: `mvmetacmd'"'
`mvmetacmd'
global F9 `mvmetacmd'
di "mvmeta command is stored in F9"
end
