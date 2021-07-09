

*! mynormal_lf_d0_c1 v1.0.0  CFBaum 11aug2008
program mynormal_lf_d0_c1
        version 10.1
        args todo b lnf
        tempvar xb mu
        tempname a lnsigma
        mleval `a' = `b', eq(1) scalar
        mleval `xb' = `b', eq(2)
        mleval `lnsigma' = `b', eq(3) scalar
        quietly {
        		generate double `mu' = `xb' - exp(`a')* $x1        	
                mlsum `lnf' = ln( normalden($ML_y1,`mu', exp(`lnsigma')) )
        }
end
