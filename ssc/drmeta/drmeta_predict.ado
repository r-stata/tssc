*! version 1.0 5sep2018

capture program drop drmeta_predict
program drmeta_predict, sortpreserve
version 13
syntax anything [, xb xbs FITted REFfects] 
if "`e(cmd)'"!="drmeta" error 301
 
	local liststudies "`e(id)'"		
    local typepredict "xb"
	 
	tempvar ids order
	tempname getb XO
	gen `order' = _n

	if "`xbs'" != "" local typepredict "xbs"
	if "`reffects'" != "" local typepredict "reffects"
    if "`fitted'" != "" local typepredict "fitted"

    gen `ids' =  `e(idname)'   
	
	local dn "`e(dm)'"
	foreach v of local dn {
		tempvar `v'c  
		bysort `e(idname)' (`e(se)'): gen ``v'c' = `v'-`v'[1]
		local vclist "`vclist' ``v'c' "
	}

	if "`typepredict'" == "xb" {
		qui gen `anything' = .  
		mat `getb' = e(b)
		mata: b = st_matrix("`getb'")
		qui putmata XO=(`vclist') , replace
		mata: fit = XO*b'
		getmata `anything' = fit, replace
		label var `anything' "Predicted values X_i*b using combined estimate"
	}
	
	if "`typepredict'" == "xbs" {
		qui gen `anything' = .  
		qui foreach s of numlist `e(id)' {
				 qui putmata  `order'  XOs=(`vclist')   if `ids' == `s', replace
			 	 mat `getb' = e(bs`s')
				 mata: bs = st_matrix("`getb'")
				 mata: fits = XOs*bs'
				 getmata  `anything' = fits , update id(`order')
		}
	   label var `anything' "Predicted values X_i*b_i using study-specific estimates"
	}
	
	if "`typepredict'" == "fitted" {
		qui gen `anything' = .  
		qui foreach s of numlist `e(id)' {
				 qui putmata  `order'  XOs=(`vclist')   if `ids' == `s', replace
			 	 mat `getb' = e(xbu`s')
				 mata: bs = st_matrix("`getb'")
				 mata: fits = XOs*bs'
				 getmata  `anything' = fits , update id(`order')
		}
		label var `anything' "Predicted values X_i*(b+u) using fixed plus random effects"
	}
	
	if "`typepredict'" == "reffects" {
	
			qui foreach v of varlist `e(dm)' {
					   gen `anything'_`v' = . 
					   label var `anything'_`v' "Predicted (BLUP) random effects (u) for `v'"
			}
			
			qui foreach s of numlist `e(id)' {
			    local j = 1
				qui foreach v of varlist `e(dm)' {
                     mat `getb' = e(blup`s')
				     replace `anything'_`v' = `getb'[1, `j++'] if `ids' == `s'
			}
		}
	}
	
end
