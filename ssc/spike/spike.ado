*! version 1.0          <200100217>          JP Azevedo

program define spike, rclass

    version 8

    syntax varlist(min=2) [if] [in] [fweight pweight] [,Robust]

    marksample touse

    tokenize `varlist'
    loc lhs1 "`1'"
    loc lhs2 "`2'"
    mac shift 2
    loc rhs "`*'"

    loc bid = word("`rhs'", 1)

    if ("`weight'" != "") {
        tempvar wvar
        qui gen double `wvar' `exp' if `touse'
        local weight "[`weight'=`wvar']"
    }


    ml model lf ml_spike (`lhs1' `lhs2' = `rhs', noconstant) /s `weight'  if `touse'  , `robust'   missing
    ml search
    ml maximize, difficult

    nlcom (A:1/(1+exp(_b[s:_cons])))  (wtp:1/(_b[eq1:`bid'])*log(1+exp(_b[s:_cons])))

    tempname a
    mat `a' = r(b)
	
    return scalar meanwtp = `a'[1,2]

end
