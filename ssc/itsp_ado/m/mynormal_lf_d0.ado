
*! mynormal_lf_d0 v1.0.0  CFBaum 11aug2008
program mynormal_lf_d0
        version 10.1
        args todo b lnf
        tempvar mu 
        tempname lnsigma
        mleval `mu' = `b', eq(1)
        mleval `lnsigma' = `b', eq(2) scalar
        quietly {
                mlsum `lnf' = ln( normalden($ML_y1,`mu', exp(`lnsigma')) )
        }
end
