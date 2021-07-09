program define matmps
*! 1.0.0  NJC 20 July 1998
    version 5.0
    parse "`*'", parse(" ")
    if "`3'" == "" | "`4'" != "" {
        di in r "invalid syntax"
        exit 198
    }

    tempname M

    capture matchk `1'
    if _rc == 0 { /* `1' is matrix => `2' should be number */
        confirm number `2'
        local nr = rowsof(matrix(`1'))
        local nc = colsof(matrix(`1'))
        mat `M' = J(`nr',`nc',`2')
        mat `3' = `1' + `M'
    }
    else { /* `1' should be number, `2' should be matrix */
        confirm number `1'
        matchk `2'
        local nr = rowsof(matrix(`2'))
        local nc = colsof(matrix(`2'))
        mat `M' = J(`nr',`nc',`1')
        mat `3' = `M' + `2'
    }
end
