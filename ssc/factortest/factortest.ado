*! version 1.0,  JPAzevedo, 18ago2006
* fix conformability error when number of variables exceeded 64 words
* version 0.5 (22 November 2003)   Joao Pedro Wagner de Azevedo
* version 0.1 (10 October  2003)


program define factortest, eclass

    version 7.0

    syntax varlist(min=2 numeric) [if] [in]

    marksample touse    // mark sample

quietly {
    tempname R sumR2 S Rinv PR sumPR2 anticorr

    *-> get variables

    matrix accum `R'= `varlist' if `touse', nocons dev
    
    matrix `R'=corr(`R')

    local p : word count `varlist'

    local n=r(N)

****************************************************
****   Bartlett's test for sphericity
****************************************************

local df=(1/2)*`p'*(`p'-1)

local chi2 = -[`n'-1-(1/6)*(2*`p'+5)]*ln(det(`R'))

local pval=chi2tail(`df', `chi2')

****************************************************
*** Kaiser-Meyer-Olkin Measure of Sampling Adequacy
****************************************************

forvalues i=1/`p'{
    forvalues j=`i'/`p'{
        mat def `R'[`i',`j']=0
    }
}

scalar `sumR2'=0
forvalues i=1/`p'{
    forvalues j=1/`p'{
        scalar `sumR2'= `sumR2'+(`R'[`i',`j'])^2
    }
}

matrix accum `R'= `varlist' if `touse', nocons dev
matrix `R'=corr(`R')
matrix `Rinv'=inv(`R')
forvalues i=1/`p'{
    forvalues j=1/`p'{
        if `i'!=`j' {
            mat `Rinv'[`i',`j'] =0
        }
    }
}

mat define `S'=J(`p',`p',0)
forvalues i=1/`p'{
    mat `S'[`i',`i']== (`Rinv'[`i',`i'])^(-0.5)
}

matrix `PR'=`S'*inv(`R')*`S'

forvalues i=1/`p'{
    forvalues j=`i'/`p'{
        mat def `PR'[`i',`j']=0
    }
}


scalar `sumPR2'=0
forvalues i=1/`p'{
    forvalues j=1/`p'{
        scalar `sumPR2'= `sumPR2'+(`PR'[`i',`j'])^2
    }
}

local kmo=`sumR2'/(`sumR2'+`sumPR2')

****************************************************
****   Output
****************************************************

noisily di _skip(4)
noisily di in g "Determinant of the correlation matrix
noisily di in g "Det                = " in y %9.3f det(`R')
noisily di _skip(1)
noisily di _skip(1)
noisily di in g "Bartlett test of sphericity"
noisily di _skip(4)
noisily di in g "Chi-square         = " in y _col(30) %9.3f `chi2'
noisily di in g "Degrees of freedom = " in y _col(30) %9.0f `df'
noisily di in g "p-value            = " in y _col(30) %9.3f `pval'
noisily di in g "H0: variables are not intercorrelated"
noisily di _skip(1)
noisily di _skip(1)
noisily di in gr "Kaiser-Meyer-Olkin Measure of Sampling Adequacy"
noisily di in gr "KMO               = "in y %9.3f `kmo'
noisily di _skip(1)
}

end
