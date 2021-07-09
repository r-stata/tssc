*! tabstatmat collects matrices saved by tabstat into one matrix
*! Austin Nichols 1.4.4 25 Feb 2011 added support for apostrophe in by var label, can't use `=subinstr construct
* Austin Nichols 1.4.3 26 Nov 2007 added support for spaces in by var, replace with char(160)
* Austin Nichols 1.4.2 25 Nov 2007 added eq names, fixed conformability error
* Austin Nichols 1.4.1 16 Feb 2007 added safe option
* NJC 1.4.0 31 Jan 2007 fixed many rows bug
* NJC 1.3.0 13 Aug 2006
* NJC 1.2.0 1 Dec 2005
* NJC 1.1.3 21 Jan 2004
* NJC 1.1.2 20 Jan 2004
* NJC 1.1.1 17 Oct 2003
* NJC 1.0.0 16 Oct 2003
program tabstatmat 
    version 8

    if "`r(Stat1)'`r(StatTot)'`r(StatTotal)'" == "" { 
        di as err "no tabstat results in memory"
        exit 498 
    }   

    syntax name(name=matout) [, noTotal Safe]

    cap mat li `matout'
    if _rc==0 {
        if "`safe'"!="" {
            di as err `"matrix named "`matout'" already exists"'
            error 110
        }
    }     

    if "`r(Stat1)'" == "" { 
        // ignore -nototal- option 
        if "`r(StatTot)'" != "" { 
            mat `matout' = r(StatTot) 
        }
        else if "`r(StatTotal)'" != "" { 
            mat `matout' = r(StatTotal)
        }
        matrix list `matout' 
        exit 0 
    }   

    if "`r(name1)'" == "" {
        if "`r(StatTot)'`r(StatTotal)'" != "" {
            local noname 1
        }
        else {
            di as err ///
            "no {cmd:tabstat} results found: use {cmd:save} option?"
            exit 498
        }
    }
    else local noname 0

    // how many vectors?
    local I = 1
    while "`r(name`I')'" != "" {
        local ++I
    }
    local --I

    // total emitted?
    if "`total'" == "" {
        capture mat list r(StatTot)
        if _rc capture mat list r(StatTotal)
        local total = _rc == 0
    }
    else local total 0

    local J = `I' - cond(`total',0,1)

    // build up temporary matrix
    if "`r(name1)'" != "" local nrows = rowsof(r(Stat1))
    else local nrows = 0

    tempname tempmat

    if `nrows' == 1 {
        forval i = 1/`J' {
            matrix `tempmat' = nullmat(`tempmat') \ r(Stat`i')
			local tmpg=subinstr(`"`r(name`i')'"'," ","`:di _char(160)'",.)
            local names   `"`names' `"`tmpg'"'"'
            loc goodnames: subinstr local names " " "", all
        }
        if !`total' {
            matrix `tempmat' = nullmat(`tempmat') \ r(Stat`I')
			loc tmpg=subinstr(`"`r(name`I')'"'," ","`:di _char(160)'",.)
            local names `"`names' `"`tmpg'"'"'
        }
        else {
            if "`r(StatTot)'" != "" {
                matrix `tempmat' = `tempmat' \ r(StatTot)
            }
            else matrix `tempmat' = `tempmat' \ r(StatTotal)
            local names `"`names' Total"'
        }
    }
    else {
        forval i = 1/`J' {
            matrix `tempmat' = nullmat(`tempmat') \ (r(Stat`i'))'
            forval k = 1/`=colsof(r(Stat`i'))' {
			  local tmpg=subinstr(`"`r(name`i')'"'," ","`:di _char(160)'",.)
              local names   `"`names'  `"`tmpg'"'"'
              }
        }
        if !`total' {
            matrix `tempmat' = `tempmat' \ r(Stat`I')'
            forval k = 1/`=colsof(r(Stat`I'))' {
              local tmpg=subinstr(`"`r(name`I')'"'," ","`:di _char(160)'",.)
			  local names `"`names'  `"`tmpg'"'"'
              }
        }
        else {
            if "`r(StatTot)'" != "" {
                if colsof(r(StatTot)) > rowsof(r(StatTot)) & colsof(r(StatTot)) == colsof(`tempmat') {
                    matrix `tempmat' = `tempmat' \ r(StatTot)
                    forval k = 1/`=(rowsof(r(StatTot)))' {
                      local names `"`names' Total"'
                      }
                }
                else matrix `tempmat' = `tempmat' \ r(StatTot)'
                forval k = 1/`=(colsof(r(StatTot)))' {
                  local names `"`names' Total"'
                  }
            }
            else {
                if colsof(r(StatTotal)) > rowsof(r(StatTotal)) & colsof(r(StatTotal)) == colsof(`tempmat') {
                    matrix `tempmat' = `tempmat' \ r(StatTotal)
                    forval k = 1/`=(rowsof(r(StatTotal)))' {
                      local names `"`names' Total"'
                      }
                }
                else matrix `tempmat' = `tempmat' \ r(StatTotal)'
                forval k = 1/`=(colsof(r(StatTotal)))' {
                  local names `"`names' Total"'
                  }
            }
        }
    }


    loc r: rownames `tempmat'
    loc goodnames: subinstr local names ":" ";", all
    forv k=1/`=rowsof(`tempmat')' {
     gettoken f goodnames : goodnames
     loc newnames `"`newnames' `f':"'
     gettoken f r : r
     loc newnames `"`newnames'`f'"'
     }
    matrix roweq `tempmat' = `newnames'
    matrix `matout' = `tempmat' 
    matrix list `matout'
end
