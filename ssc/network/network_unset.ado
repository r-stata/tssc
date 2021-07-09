*! version 1.1 # Ian White # 27may2015
prog def network_unset

// drop any metavars
if !mi("`_dta[network_metavars]'") {
    foreach var in `_dta[network_metavars]' {
        cap drop `var'
    }
}

// delete network characteristics
foreach thing in `_dta[network_allthings]' {
    char _dta[network_`thing']
}
end

