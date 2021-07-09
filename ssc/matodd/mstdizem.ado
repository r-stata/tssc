program define mstdizem
*! version 1.0.0 NJC 23 July 1998
    version 5.0
    parse "`*'", parse(" ,")
    if "`4'" == "" {
        di in r "invalid syntax"
        exit 198
    }
    matchk `1'
    local X "`1'"
    matchk `2'
    local rowtot "`2'"
    matchk `3'
    local coltot "`3'"
    local Y "`4'"
    if "`4'" == "" {
        di in r "invalid syntax"
        exit 198
    }
    mac shift 4
    local options "TOLerance(real 1e-3) Format(string)"
    parse "`*'"

    tempname oner onec sumrow sumcol guess pguess Rowtot Coltot r c
    tempname rowtotm coltotm

    qui {
        local nr = rowsof(matrix(`X'))
        local nc = colsof(matrix(`X'))
        mat `oner' = J(1,`nr',1)
        mat `onec' = J(`nc',1,1)
        mat `sumrow' = `oner' * `rowtot'
        mat `sumcol' = `coltot' * `onec'
        local diffsum = abs(`sumrow'[1,1] - `sumcol'[1,1])
        if `diffsum' > `toleran' {
            di in r "totals of rows and columns do not agree"
            exit 198
        }

        mat `guess' = `X'
        mat `rowtotm' = diag(`rowtot')
        mat `coltotm' = diag(`coltot')
        local max .
        local i = 0
        while `max' > `toleran' {
            local i = `i' + 1
            mat `pguess' = `guess'
            mat `Rowtot' = `guess' * `onec'
            mat `Rowtot' = diag(`Rowtot')
            mat `Rowtot' = inv(`Rowtot')
            mat `r' = `rowtotm' * `Rowtot'
            mat `guess' = `r' * `guess'
            mat `Coltot' = `oner' * `guess'
            mat `Coltot' = diag(`Coltot')
            mat `Coltot' = inv(`Coltot')
            mat `c' = `coltotm' * `Coltot'
            mat `guess' = `guess' * `c'
            matmad `pguess' `guess'
            local max = $S_1
        }
    }

    mat `Y' = `guess'
    if "`format'" == "" { local format "%9.2f" }
    mat li `Y', format(`format')

    global S_1 = `max'
    global S_2 = `i'

end

