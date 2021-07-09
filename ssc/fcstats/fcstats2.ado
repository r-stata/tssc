*! version 1.0.0  14jul2018  CFBaum
// based on fcstats.ado 1.0.0
prog drop _all
program define fcstats2, rclass
        version 13
        syntax varlist(numeric ts min=2 max=10) [if] [in] [, GRAPH *]
        marksample touse
        _ts tvar panelvar `if' `in', onepanel
        markout `touse' `tvar'
        su `touse', mean
        if `r(N)' == 0 {
                error 2000
        }
        qui tsset
        
 		
		tempvar actual en rmse mae mape tu num den 
		tempname rmse1 mae1 mape1 tu1 
		tempname rmse2 mae2 mape2 tu2 
		tempname rmse3 mae3 mape3 tu3 
		tempname rmse4 mae4 mape4 tu4 
		tempname rmse5 mae5 mape5 tu5 
		tempname rmse6 mae6 mape6 tu6 
		tempname rmse7 mae7 mape7 tu7 
		tempname rmse8 mae8 mape8 tu8 
		tempname rmse9 mae9 mape9 tu9 

        tokenize `varlist'
        loc actual `1'
        loc fc1 `2'
        loc fc2 `3'
		loc fc3 `4'
		loc fc4 `5'
        loc fc5 `6'
		loc fc6 `7'
		loc fc7 `8'
        loc fc8 `9'
		loc fc9 `10'

        markout `touse' `act' `fc1' `fc2' `fc3' `fc4' `fc5' `fc6' `fc7' `fc8' `fc9'
        forv j=1/9 {
			if "`fc`j''" != "" {
				loc nf = `j'
			}
		}

        g  `en' = _n * `touse'  
        su `en', mean
        loc mx = r(max)
		mat fcs = J(4,`nf',.)
		mat rownames fcs = RMSE MAE MAPE "Theil U"
		loc cn
        qui {
			forv j=1/`nf' {
			    loc cn "`cn' `fc`j''"
				su `fc`j'' if `touse', mean
				capt drop `rmse' 
				g double `rmse' = sum((`fc`j'' - `actual')^2) if `touse'
				sca `rmse`j'' = sqrt(`rmse'[`mx'] / `r(N)')
				mat fcs[1,`j'] = `rmse`j''
				capt drop `mae'
				g double `mae' = sum(abs(`fc`j'' -`actual')) if `touse'
				sca `mae`j'' = `mae'[`mx'] / `r(N)'
				mat fcs[2,`j'] = `mae`j''
				capt drop `mape'
				g double `mape' = sum(abs(`fc`j'' -`actual') / `actual') if `touse'
				sca `mape`j'' = `mape'[`mx'] / `r(N)'
				mat fcs[3,`j'] = `mape`j''
				capt drop `num'
				g double `num' = sum(((`fc`j'' - `actual') / L.`actual')^2) if `touse'
				capt drop `den'
				g double `den' = sum((D.`actual' / L.`actual')^2) if `touse'
				sca `tu`j'' = sqrt(`num'[`mx'] / `den'[`mx'])
				mat fcs[4,`j'] = `tu`j''
			}
			mat colnames fcs = `cn'
		}
/*
		forv j=1/`nf' {
			    di as res _n "Forecast accuracy statistics for `actual', N = `r(N)'"
        
                di _n _col(15) "`fc`j''"  
                di    "RMSE  " _col(15) `rmse`j'' 
                di    "MAE   " _col(15) `mae`j'' 
                di    "MAPE  " _col(15) `mape`j'' 
                di    "Theil's U " _col(15) `tu`j''
		}
*/		
		matlist fcs, twidth(7) format(%9.4f) title("Forecast accuracy statistics for `actual', N = `r(N)'")
		return matrix fcs = fcs
		return local fcvars `cn'
		return scalar N       =  `r(N)'
        return local actual   = "`actual'"
      
        if "`graph'" != "" {
//                loc leg legend(rows(1) size(small) label(1 "`actual'") label(2 "`forecast'")
//                if "`forecast2'" != "" {
//                        loc leg `leg' label(3 "`forecast2'")
//              }
                tsline `actual' `fc1' `fc2' `fc3' `fc4' `fc5' `fc6' `fc7' `fc8' `fc9' ///
					if `touse', ylab(,angle(0)) `options'
        }

end

