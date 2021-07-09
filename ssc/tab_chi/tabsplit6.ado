program def tabsplit6, rclass 
*! NJC 1.3.0 17 July 2000 
* NJC 1.2.2 23 March 1999
* NJC 1.1.0 11 August 1998
* NJC 1.0.0 29 July 1998
    version 6.0
    syntax varname(string) [if] [in] [ , Punct(str) Sort Header(str) /* 
    */ Generate(str) GMAX(numlist int >0) ]

    if "`punct'" == "" { local punct " " }
    
    tempvar data newdata touse id nwords wordno word orig

    qui {
        gen str1 `data' = ""
        replace `data' = trim(`varlist') `if' `in'

        if "`punct'" == "no" {
            compress `data'
            local vartype: type `data'
            local len = substr("`vartype'",4,.)
            gen str1 `newdata' = ""

            local i = 1
            while `i' < `len' {
                replace `newdata' = /*
                 */ `newdata' + substr(`data',`i',1) + " "
                local i = `i' + 1
            }
            replace `data' = trim(`newdata' + substr(`data',`len',1))
            local punct " "
        }

        gen str1 `word' = ""
        gen int `nwords' = .

        mark `touse' `if' `in'
        markout `touse' `data', strok
        sort `touse'
        count if !`touse'
        local notuse = r(N)
        gen long `id' = _n
    }

    local i = 1 + `notuse'
    while `i' <= _N {
        local val = `data'[`i']
        if "`punct'" == " " { local j : word count `val' }
        else {
            local j 0
            parse "`val'", parse("`punct'")
            while "`1'" != "" {
                if index("`punct'","`1'") == 0 { local j = `j' + 1 }
                mac shift
            }
        }
        qui replace `nwords' = `j' in `i'
        local i = `i' + 1
    }

    qui nobreak {

        local N = _N
        expand `nwords'
        gen byte `orig' = - (_n <= `N') 
        sort `touse' `id' `orig' 
        by `touse' `id' : gen `wordno' = _n if `touse'

        if "`generat'" != "" {
            su `nwords', meanonly
            local max = r(max)
            if "`gmax'" != "" { local max = min(`max',`gmax') }
            local j = 1
            while `j' <= `max' {
                confirm new variable `generat'`j'
                local j = `j' + 1
            }
            local j = 1
            while `j' <= `max' {
                gen str1 `generat'`j' = ""
                local j = `j' + 1
            }
        }

        local i = 1 + `notuse'
        while `i' <= _N {
            local val = `data'[`i']
            local w = `nwords'[`i']
            if "`punct'" == " " {
                local j = 1
                local l = `i'
                while `j' <= `w' {
                    local k : word `j' of `val'
                    replace `word' = "`k'" in `i'
                    if "`generat'" != ""  {
                        if `j' <= `max' {
                            replace `generat'`j' = "`k'" in `l'
                        }
                    }
                    local i = `i' + 1
                    local j = `j' + 1
                }
            }
            else {
                parse "`val'", parse("`punct'")
                local j = 1
                local l = `i'
                while `j' <= `w' & "`1'" != "" {
                    if index("`punct'","`1'") == 0 {
                        replace `word' = trim("`1'") in `i'
                        if "`generat'" != "" {
                            if `j' <= `max' {
                                replace `generat'`j' = trim("`1'") in `l'
				local j = `j' + 1 
                            }
                        }
			local i = `i' + 1
		    }
		    mac shift 
                }
            }
        }

        if "`header'" == "" { local header "Parts" }
        label var `word' "`header'"
        noi tab`sort' `word'

        keep if `orig'

    } /* end of -nobreak- */ 

    if "`generat'" != "" { return local max = `max' }
end
