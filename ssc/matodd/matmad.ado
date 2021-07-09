program def matmad
* maximum absolute difference between matrices
* matmad A B -- for matrices A, B
*! 1.0.0 NJC 5 July 1998
    version 5.0
    if "`1'" == "" | "`2'" == "" | "`3'" != "" {
        di in r "invalid syntax"
        exit 198
    }

    tempname D
    mat `D' = `1' - `2'

    local nr = rowsof(`D')
    local nc = colsof(`D')
    local max = abs(`D'[1,1])
    local i 1
    while `i' <= `nr' {
        local j = 1
        while `j' <= `nc' {
            local max = max(`max',abs(`D'[`i',`j']))
            local j = `j' + 1
        }
        local i = `i' + 1
    }
    global S_1 = `max'
    di $S_1
end
