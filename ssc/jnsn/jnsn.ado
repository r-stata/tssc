*! jnsn.ado Version 1.12 2007-01-16 JRC
program define jnsn, byable(recall)
    version 9.2
    syntax [varname(numeric)] [if] [in] [aweight fweight] [, Generate(name) * ]

    marksample touse
    quietly summarize `varlist' if `touse' `weight', detail
    display in smcl as text "Johnson's system of transformations"
    display in smcl _newline(1)
    display in smcl as text "Mean and moments for " "{bf:`varlist'}"
    display in smcl as text "    Mean = " as result %05.3f r(mean)
    display in smcl as text "Variance = " as result %05.3f r(Var)
    display in smcl as text "Skewness = " as result %05.3f r(skewness)
    display in smcl as text "Kurtosis = " as result %05.3f r(kurtosis)

    jnsni , mean(`r(mean)') sd(`r(sd)') skewness(`r(skewness)') kurtosis(`r(kurtosis)') called(1) `options'

    if "`generate'" ~= "" {
        if "`r(johnson_type)'" == "ST" {
            display in smcl as text "Johnson type is ST.  " as input "generate" as text " is ignored."
            exit
        }
        local formula (`varlist' - r(xi)) / r(lambda)
        if inlist("`r(johnson_type)'", "SL", "SU", "SB") {
            if "`r(johnson_type)'" == "SL" {
                local formula r(gamma) + r(delta) * ln(`formula')
            }
            else if "`r(johnson_type)'" == "SU" {
                local formula r(gamma) + r(delta) * ln(`formula' + sqrt((`formula') * (`formula') + 1))
            }
            else {
                local formula r(gamma) + r(delta) * ln((`formula') / (1 - `formula'))
            }
        }
        if _byindex() == 1 {
            quietly generate double `generate' = `formula' if `touse'
        }
        else {
            quietly replace `generate' = `formula' if `touse'
        }
    }
end
