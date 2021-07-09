*! 1.4.1 NJC 5apr2020 
*! 1.4.0 NJC 14mar2019 
* 1.3.1 NJC 14jul2017 
* 1.3.0 NJC 3jul2017 
* 1.2.0 NJC 8mar2017 
* 1.1.0 NJC 2oct2016 
* 1.0.0 NJC 5sept2016 
program multiline 
    version 11
    syntax varlist(numeric) [if] [in] ///
    [, by(str asis) mylabels(str asis) MISSing SEParate *] 
    
    quietly { 
        if "`missing'" != "" marksample touse, novarlist 
        else marksample touse 

        count if `touse' 
        if r(N) == 0 exit 2000 

        preserve 
        keep if `touse' 
        drop `touse' 
    
        gettoken yvar rest : varlist 
        local J = 0 
        while "`yvar'" != "" { 
            local ++J 
            local lbl`J' : var label `yvar' 
            if `"`lbl`J''"' == "" local lbl`J' "`yvar'" 
            local last "`yvar'" 
            gettoken yvar rest : rest    
        } 

        local xvar "`last'" 
        local yvar : list varlist - xvar 

        capture tsset 
        if "`r(panelvar)'" != "" local panelvar "`r(panelvar)'" 

        foreach v of local yvar { 
            local call `call' `v' `panelvar' `xvar' 
        }

        tempname y
        tempfile mydo 
        local label : value label `xvar'  
        label save `label' using "`mydo'" 
        stack `call', into(`y' `panelvar' `xvar') clear 
        do "`mydo'" 
        if "`label'" != "" { 
            label val `xvar' `label' 
        } 

        local Jm1 = `J' - 1 
        if `"`mylabels'"' != "" { 
            tokenize `mylabels' 
            forval j = 1/`Jm1' { 
                label def _stack `j' `"``j''"', add 
            } 
        } 
        else forval j = 1/`Jm1' { 
            label def _stack `j' `"`lbl`j''"', add 
        } 
        label val _stack _stack 
    } 

    sort `panelvar' `xvar' 
    label var `xvar'  `"`lbl`J''"'

    if `"`by'"' == "" local by "cols(1)"  
    else { 
        local found 0 
        foreach opt in c co col cols { 
            if strpos(`"`by'"', "`opt'(") { 
                local found 1 
                continue, break 
            } 
        }
        if !`found' local by `"`by' cols(1)"' 
    }  

    quietly    if "`separate'" != "" { 
        separate `y', by(_stack) veryshortlabel 
        local y `r(varlist)' 
    } 
        
    line `y' `xvar', by(_stack, yrescale note("") `by') ///
    ytitle("") yla(, ang(h)) c(L) ///
    subtitle(, pos(9) bcolor(none) nobexpand place(e)) `options' 
end

