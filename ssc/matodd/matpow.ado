program def matpow
* power of square matrix
*! 1.0.0 NJC 20 July 1998
    version 5.0
    parse "`*'" , parse(" ,")
    if "`1'" == "" {
        di in r "invalid syntax"
        exit 198
    }
    matchk `1'
    local A "`1'"
    mac shift
    if "`1'" != "," & "`1'" != "" {
        local B "`1'"
        mac shift
    }
    else {
        di in r "invalid syntax"
        exit 198
    }
    local options "Power(str) TOLerance(real 1e-6) ITERate(int 100)"
    local options "`options' Format(str)"
    parse "`*'"

    if "`power'" == "" { local power = . }
    else confirm number `power'

    if `power' <= 0 | `toleran' < 0 | `iterate' < 1 {
        di in r "invalid syntax"
        exit 198
    }

    matcfm `A' `A'
    tempname C D
    mat `C' = `A'

    if `power' == . {
        local max .
        local i = 0
        while `max' > `toleran' {
            local i = `i' + 1
            if `i' > `iterate' {
                di in r "convergence not achieved"
                exit 430
            }
            mat `D' = `C'
            mat `C' = `C' * `A'
            qui matmad `C' `D'
            local max = $S_1
        }
    }
    else {
        local i = 1
        while `i' < `power' {
            mat `C' = `C' * `A'
            local i = `i' + 1
        }
    }

    if "`format'" == "" { local format "%9.3f" }
    mat `B' = `C'
    mat li `B', f(`format')
end
