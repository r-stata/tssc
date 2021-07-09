*! ajv.ado Version 1.1 2007-02-26 JRC
program define ajv
    version 9.2
    syntax [varname(numeric default=none)] [if] [in], Generate(name) ///
      DIstribution(string) GAmma(real) DElta(real) [Lambda(real 1) Xi(real 0) SEED(integer 0) n(integer 0)]

    capture assert inlist(upper("`distribution'"), "SN", "SL", "SU", "SB")
    if _rc {
        display in smcl as error "Distribution must be SN, SL, SU or SB (upper case, lower case or mixed case)"
        exit = 99
    }
    if (`delta' <= 0) {
        display in smcl as error "Delta must be strictly positive"
        exit = 99
    }
    if ((upper("`distribution'") == "SL") & !inlist(`lambda', -1, 1)) {
        display in smcl as error "Lambda must be -1 or 1 if distribution is SL"
        exit = 99
    }
    if ((upper("`distribution'") != "SL") & (`lambda' <= 0)) {
        display in smcl as error "Lambda must be strictly positive"
        exit = 99
    }

    if ("`varlist'" == "") {
        tempvar w snv
        if (`seed' != 0) {
            set seed `seed'
        }
        if (`n' == 0) {
            if (_N == 0) {
                display in smcl as error "Option {it:n()} must be set if dataset has zero observations."
                exit = 99
            }
        }
        else if (_N >= `n') {
            display in smcl as text "Dataset already has " _N " observations.  Option {it:n(`n')} ignored."
        }
        else {
            quietly set obs `n'
        }
        
        quietly generate double `snv' = invnorm(uniform()) // if `touse'
    }
    else {
        tempvar w
        local snv = "`varlist'"
    }

    marksample touse

    if (upper("`distribution'") == "SL") {
        generate double `generate' = `lambda' * exp((`lambda' * `snv' - `gamma') / `delta') + `xi' if `touse'
    }
    else if (upper("`distribution'") == "SU") {
        generate double `generate' = exp((`snv' - `gamma') /  `delta') if `touse'
        quietly {
            replace `generate' = (`generate' - 1 / `generate') / 2
            replace `generate' = `lambda' * `generate' + `xi'
        }
    }
    else if (upper("`distribution'") == "SB") {
        generate double `w' = (`snv' - `gamma') / `delta' if `touse'
        quietly {
            generate double `generate' = exp(-abs(`w'))
            replace `generate' = (1 - `generate') / (1 + `generate')
            replace `generate' = (`lambda' * (cond((`w' >= 0), abs(`generate'), -abs(`generate')) + 1)) / 2 + `xi'
        }
    }
    else {
        generate double `generate' = (`snv' - `gamma') / `delta' if `touse'
    }
end

/* ALGORITHM AS 100.1  APPL. STATIST. (1976) VOL.25, P.190  */
