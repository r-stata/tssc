*! version 3.0.0 01dec2018 daniel klein
program mimrgns_estimate , eclass properties(mi)
    version 11.2 
    
    assert (`"${mimrgns__caller}"'=="mimrgns")
    
    local m = ${mimrgns__m} + 1
    global mimrgns__m : copy local m
    
    if (!${mimrgns__is_verbose}) local quietly quietly
    
    if (`"${mimrgns__using}"'!="") {
        `quietly' estimates use `"${mimrgns__using}"' , number(`m')
         quietly  estimates esample : if ${mimrgns__esample}
    }
    else {
        if (${mimrgns__is_verbose}) display _newline "{inp}. " ///
            `"${mimrgns__version} : `quietly' ${mimrgns__cmdline}{sf}"'
        ${mimrgns__version} : `quietly' ${mimrgns__cmdline}
    }
    
    if (${mimrgns__is_verbose}) display _newline "{inp}. " ///
        `"${mimrgns__version} : margins ${mimrgns__cmdline_margins}{sf}"'
    ${mimrgns__version} : margins ${mimrgns__cmdline_margins}
    
    foreach name in at b_vs V_vs error_vs {
        local rname r(`name')
        if ("``rname''"!="matrix") continue
        if (`m'>1) local expr = "mimrgns__`name' " ///
                    + cond("`name'"=="b_vs", "\", "+")
        matrix mimrgns__`name' = `expr' `rname'
    }
    
    if (`m'>1) exit
    
    _return hold ${mimrgns__rr}
end
exit

/* ---------------------------------------
3.0.0 01dec2018 rewrite using globals and matrices mimrgns__*
2.1.1 07apr2017 display command lines with option verbose
2.1.0 03nov2016 additionally collect r(at) matrix
2.0.0 28jun2016 support estimation results from ster-file
                verbose output if requested
                code polish
1.0.2 14mar2016 declare version 11 in subroutines 
                (never released)
1.0.1 02jul2015 better error message for invalid handle
1.0.0 02jul2015 first release on SSC
