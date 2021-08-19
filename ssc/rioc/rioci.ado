*! version 1.0.0 26jan2021 daniel klein
program rioci
    version 11.2
    
    syntax anything(id = "integer") [ , noTab REPLACE * ]
    
    foreach x in a b c d {
        gettoken `x' anything : anything , parse(" \")
    }
    if ("`c'" == "\") {
        local c `d'
        gettoken d anything : anything
    }
    if (`"`anything'"' != "") error 198
    
    preserve
    
    quietly {
        tabi `a' `b' \ `c' `d' , replace
        replace row = 2 - row
        replace col = 2 - col
        rename row prediction
        rename col    outcome
        label variable prediction "Prediction"
        label variable    outcome    "Outcome"
    }
    
    if ("`tab'" != "notab") local tab tab
    rioc prediction outcome [fweight = pop] , `tab' `options'
    
    if ("`replace'" == "replace") local not , not
    restore `not'
end
exit
