*! ovbd.ado Version 1.0 2007-02-27 JRC
program define ovbd
    version 9.2
    syntax [newvarlist], Means(name) Corr(name) n(integer) [STub(string) SEED(integer 0) Verbose] clear
*
    tempname A B C
*
    capture assert rowsof(`means') == 1
    if _rc {
        display in smcl as error "Means must be a column vector."
        exit = 99
    }
    local Columns = colsof(`means')
    capture assert ((colsof(`corr') == `Columns') & (rowsof(`corr') == `Columns'))
    if _rc {
        display in smcl as error "Correlation matrix must have same number of rows and columns as columns of Means vector."
        exit = 99
    }
    capture assert ("`varlist'" != "")
    if _rc {
        capture assert  ("`stub'" != "")
        if _rc {
            display in smcl as error "Either {it:newvarlist} or {it:stub()} must be specified."
            exit = 99
        }
        else {
            forvalues i = 1/`Columns' {
                local varlist `varlist' `stub'`i'
            }
        }
    }
    else { // STub() will be ignored if newvarlist is specified
        capture assert (`: word count `varlist'' == `Columns')
        if _rc {
            display in smcl as error "Number of new variables must equal number of columns in mean vector."
            exit = 99
        }
    }
*
    drop _all
    macro drop S_1
    if (`seed' != 0) {
            set seed `seed'
        }
    if ("`verbose'" != "") {
        local verbose noisily
    }
*
    matrix define `A' = J(1, `Columns', .)
    forvalues i = 1/`Columns' {
        matrix define `A'[1,`i'] = invnormal(`means'[1,`i'])
    }
    matrix define `C' = J(`Columns', `Columns', 1)
    forvalues i = 2/`Columns' {
        forvalues j = 1/`=`i'-1' {
            scalar define `B' = (sqrt(`means'[1,`i'] * (1 - `means'[1,`i']) * ///
              (`means'[1,`j']) * (1 - `means'[1,`j']))) * abs(`corr'[`i',`j']) + `means'[1,`i'] * `means'[1,`j']
            capture `verbose' ridder binormal(`A'[1,`i'], `A'[1,`j'], X) = `B' from 0.001 to 0.999
            if _rc {
                macro drop S_1
                display in smcl as error "Root not found."
                exit = 99
            }
            matrix define `C'[`i',`j'] = $S_1 * sign(`corr'[`i',`j'])
            matrix define `C'[`j',`i'] = `C'[`i',`j'] // use -drawnorm-'s compact storage option to avoid this
            macro drop S_1
        }
    }
    drawnorm `varlist', double corr(`C') n(`n') clear
    forvalues i = 1/`Columns' {
        local a : word `i' of `varlist'
        quietly replace `a' = (`a' <= `A'[1,`i'])
    }
    quietly compress `varlist'
end
