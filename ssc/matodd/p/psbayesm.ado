program define psbayesm
*! 1.0.0 NJC 20 July 1998
    version 5.0
    parse "`*'", parse(" ,")
    matchk `1'
    local X "`1'"
    mac shift

    capture matchk `1'
    if _rc {
        tempname P
        local nr = rowsof(matrix(`X'))
        local nc = colsof(matrix(`X'))
        local const = 1 / (`nr' * `nc')
        mat `P' = J(`nr',`nc',`const')
    }
    else {
        local P "`1'"
        matcfa `X' `P'
        mac shift
    }

    local options "Prob Format(string) Matrix(string) *"
    parse "`*'"

    qui {
        tempname Sum Sq Diffsq PB
        matsum `X', a(`Sum')
        local N = `Sum'[1,1]
        matsum `P', a(`Sum')
        local Psum = `Sum'[1,1]
        if abs(`Psum' - 1) > 0.01 {
            di in r "prior probabilities sum to " `Psum'
            exit 198
        }
        matewm `X' `X' `Sq'
        matsum `Sq', a(`Sum')
        local sumsq = `Sum'[1,1]
        mat `Diffsq' = `N' * `P'
        mat `Diffsq' = `X' - `Diffsq'
        matewm `Diffsq' `Diffsq' `Diffsq'
        matsum `Diffsq', a(`Sum')
        local sumd2 = `Sum'[1,1]
        local K = (`N'^2 - `sumsq') / `sumd2'
        mat `PB' = `K' * `P'
        mat `PB' = `X' + `PB'
        local const = 1 / (`N' + `K')
        mat `PB' = `const' * `PB'
        if "`prob'" == "" { mat `PB' = `N' * `PB' }
    }

    local rn : rownames(`X')
    local cn : colnames(`X')
    mat rownames `PB' = `rn'
    mat colnames `PB' = `cn'
    di _n in g "Pseudo-Bayes estimates"
    if "`format'" == "" { local format "%9.1f" }
    mat li `PB', f(`format') noheader
    if "`matrix'" != "" { mat `matrix' = `PB' }

    global S_1 = `N'
    global S_2 = `K'
end
