program define matewop
*! 1.0.0  NJC 24 August 1998
    version 5.0
    parse "`*'", parse(" ,")
    if "`3'" == "" | "`3'" == "," {
        di in r "invalid syntax"
        exit 198
    }

    matchk `1'
    local A "`1'"
    matchk `2'
    local B "`2'"
    matcfa `A' `B'
    local nr = rowsof(matrix(`A'))
    local nc = colsof(matrix(`A'))
    local C "`3'"
    mac shift 3
    local options "Format(str) Operator(str)"
    parse "`*'"
    if "`operato'" == "" {
        di in r "operator() option required"
        exit 198
    }

    tempname D
    mat `D' = J(`nr',`nc',1)
    local i 1
    while `i' <= `nr' {
        local j 1
        while `j' <= `nc' {
            local val = `A'[`i',`j'] `operato' `B'[`i',`j']
            if `val' == . {
                di in r "matrix would have missing values"
                exit 504
            }
            mat `D'[`i',`j'] = `val' 
            local j = `j' + 1
        }
        local i = `i' + 1
    }

    if "`format'" == "" { local format "%9.2f" }
    mat `C' = `D' /* allows overwriting of either `A' or `B' */
    mat li `C', format(`format')
end
