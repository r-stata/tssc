*! Chris Larkin, version 1.0.3
*! Chris Larkin, version 1.0.2
*! Nick Cox, version 1.0.1

capture program drop ereplace
program define ereplace, byable(onecall) sortpreserve
        version 6, missing
		
        local cvers = _caller()

        gettoken type 0 : 0, parse(" =(")
        gettoken name 0 : 0, parse(" =(")

        if `"`name'"'=="=" {
                local name `"`type'"'
                local type : set type
        }
        else {
                gettoken eqsign 0 : 0, parse(" =(")
                if `"`eqsign'"' != "=" {
                        error 198
                }
        }

        confirm variable `name'

        gettoken fcn 0 : 0, parse(" =(")
        gettoken args 0 : 0, parse(" ,") match(par)
        capture qui findfile _g`fcn'.ado
        if (`"`r(fn)'"' == "") {
                di as error "unknown egen function `fcn'()"
                exit 133
        }
        if `"`par'"' != "(" {
                exit 198
        }
        if `"`args'"' == "_all" {
                version 7.0, missing
                unab args : _all
                local args : subinstr local args "`_sortindex'"  "", all word
                version 6.0, missing
        }

        syntax [if] [in] [, *]
		marksample touse
        if _by() {
                local byopt "by(`_byvars')"
                local cma ","
        }
        else if `"`options'"' != "" {
                local cma ","
        }
        tempvar dummy
        global EGEN_Varname `name'
        version 7.0, missing
        global EGEN_SVarname `_sortindex'
        version 6.0, missing
        if ("`fcn'" == "mode") {
                local vv : display "version " string(`cvers') ", missing:"
        }
        capture noisily `vv' _g`fcn' `type' `dummy' = (`args') if `touse' /*
                */ `cma' `byopt' `options'
        global EGEN_SVarname
        global EGEN_Varname
        if _rc { exit _rc }
        quietly count if missing(`dummy')
        if r(N) {
                local s = cond(r(N)>1,"s","")
                di in bl "(" r(N) " missing value`s' generated)"
        }
        replace `name' = `dummy' if `touse'
end
