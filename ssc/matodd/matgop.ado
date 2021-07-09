program define matgop
* C[i,j] = A[i,1] operator B[1,j], A column vector, B row vector
*! 1.0.0  NJC 17 July 1998
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
    local nrA = rowsof(matrix(`A'))
    local ncB = colsof(matrix(`B'))
    local ncA = colsof(matrix(`A'))
    local nrB = rowsof(matrix(`B'))
    if `ncA' > 1 | `nrB' > 1 {
        di in r "arguments must be column vector and row vector"
        exit 198
    }

    local C "`3'"
    mat `C' = J(`nrA',`ncB',1)
    mac shift 3
    local options "Format(str) Operator(str)"
    parse "`*'"
    if "`operato'" == "" {
        di in r "operator( ) option required"
        exit 198
    }
    tempname val
    local i 1
    while `i' <= `nrA' {
        local j 1
        while `j' <= `ncB' {
            scalar `val' = `A'[`i',1] `operato' `B'[1,`j']
            mat `C'[`i',`j'] = `val'
            local j = `j' + 1
        }
        local i = `i' + 1
    }

    if "`format'" == "" { local format "%9.2f" }
    mat li `C', format(`format')
end
