*! version 2.0.2  31jan2005
/* Postestimation command of stcox, estat concordance, is called */
/* through stcstat.ado 						 */					
program define stcstat2, rclass /* [if exp] [in range] */
        version 8
        st_is 2 analysis
        syntax [if] [in] [, ALL noSHow]
        marksample touse
        if "`e(cmd)'" != "stpm2" {
        	error 301
        }
        tempvar h
        quietly {
                if "`all'"=="" {
                        local restriction "if e(sample)"
                }
                predict double `h' `restriction', xbnobaseline
                markout `touse' `h'
        }

        if `"`_dta[st_w]'"' != "" {
                di as err /*
		*/ "estat concordance may not be used with weighted data"
                exit 498
        }

        capture assert `_dta[st_t0]'==0 if `touse'
        if _rc {
                di as err /*
	        */ "estat concordance may not be used with late entry or "/*
		*/ "time-varying data"
                exit 498
        }

        if "`e(texp)'" != "" {
               	di as err /*
        	*/ "estat concordance may not be used with option tvc() "/*
		*/ "or time-varying data"
		exit 498
	}

	di
        di as txt _col(3) "Harrell's C concordance statistic"
        st_show `show'
        di

        local t : char _dta[st_t]
        local d : char _dta[st_d]

        tempvar Dv
        quietly {
                sort `touse' `h'
                count if `touse'
                local obs = r(N)
                capture assert e(sample)==`touse'
                if _rc { 
                        noi di as txt "{p 2}" _n /*
                        */  "(note: different samples used to fit" /*
                        */ " model and to calculate C statistic)" _n   /*
                        */ _n
                }

                local D 0
                local N 0   /* N = # as expected; on output we will call
                               N E */
                local T 0
                local i = _N - `obs' + 1
                while `i' < _N {
			local j = `i' + 1
                                                
                        gen byte `Dv' = `d'[`i'] & `d' in `j'/l

                        replace `Dv' = 2 /*
                        */ if (!`Dv') & `d'[`i'] & `t'[`i']<=`t' in `j'/l
                        replace `Dv' = 3 /* 
                        */ if (!`Dv') & `d' & `t'[`i']>=`t' in `j'/l
                        replace `Dv'=0 /*
                        */ if (abs(`t'-`t'[`i'])<1e-12)& (`Dv'==1) in `j'/l
                        
                        count if `Dv' in `j'/l
                        local D = `D' + r(N)

                        count if `Dv' & `h'[`i']==`h' in `j'/l
                        local T = `T' + r(N)

                        count if `Dv'==1 & `h'[`i']!=`h' & `t'[`i']>`t' /*
                                */ in `j'/l
                        local N = `N' + r(N)

                        count if `Dv'==3 & `h'[`i']!=`h' & `t'[`i']>=`t' /*
                                */ in `j'/l
                        local N = `N' + r(N)
                        
                        drop `Dv'
                        local i = `i' + 1
                }
        
        }
	
        di as txt _col(3) "Number of subjects (N)" _col(38) " = " as res /* 
                */ %8.0f `obs'
        di as txt _col(3) "Number of comparison pairs (P)" _col(38) " = " /*
                */ as res %8.0f `D'
        di as txt _col(3) "Number of orderings as expected (E)" _col(38) " = "/*
                */ as res %8.0f `N' /* sic */
        di as txt _col(3) "Number of tied predictions (T)" _col(38) " = "/*
 		*/ as res %8.0f `T'
        di

        ret scalar C = (`N'+`T'/2)/`D'
        tempname SomerD
        scalar `SomerD' = 2*(return(C)-0.5)

        di as txt _col(11) "Harrell's C = (E + T/2) / P" _col(38) " = " /*
               */ as res %8.4g return(C)
        di as txt _col(29) "Somers' D" _col(38) " = " /*
               */ as res %8.4g `SomerD'

        ret scalar D   = `SomerD'
	ret scalar n_T = `T'
        ret scalar n_E = `N'
	ret scalar n_P = `D'                
        ret scalar N   = `obs'
end
exit

