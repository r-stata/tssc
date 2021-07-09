*! 1.2.0 RGG 23 February 2002
*! 1.1.0 NJC 16 February 2002 
*! 1.0.1 NJC 1 June 1999
program define nbfit, rclass
    version 6.0
    syntax varname(numeric) [if] [in] [fweight] [, Log ]
    marksample touse 
    if "`weight'" != "" { local exp "[w `exp']" }
    if "`log'" == "" { local qui "qui" }
    
    di _n in g "Fitting negative binomial distribution to `varlist'"
 
    `qui' nbreg `varlist' if `touse' `exp'
    su `touse' `exp', meanonly 
    local n = r(sum_w)
    tempname mean k p g3132 G C
    scalar `mean' = exp(_b[_cons])
    scalar `k' = exp(-_b[/lnalpha])
    scalar `p' = `mean' / (`mean' + `k')
    scalar `g3132' = `p' * `p' * exp(-_b[_cons]-_b[/lnalpha])

    matrix `G' = (`mean', 0 \ 0, -`k' \ `g3132', `g3132')
    matrix `C' = `G' * e(V) * `G''

    di _n in g "Parameter         Point Estimate       Standard Error"
    di in g _dup(53) "-" 
    di in g "m (mean)" _col(20) in y %12.5f `mean' /*
            */         _col(41) %12.5f sqrt(`C'[1,1])
    di in g "k"        _col(20) in y %12.5f `k'    /*
    	    */         _col(41) %12.5f sqrt(`C'[2,2]) 
    di in g "p"        _col(20) in y %12.5f `p'    /*
    	    */         _col(41) %12.5f sqrt(`C'[3,3])
    
    matrix rownames `C' = mean k p
    matrix colnames `C' = mean k p

    return matrix V  `C'
    return local n = `n'
    return local mean = `mean'
    return local k = `k'
    return local p = `p'
end

