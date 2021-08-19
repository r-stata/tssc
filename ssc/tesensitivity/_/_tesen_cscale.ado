// TODO: Sorting of output display

program _tesen_cscale, rclass

	// =========================================================================
	// 1. Temporary names
	// =========================================================================

	tempname alph matW ones zeros walpha p0w p1w p1w_k matW_k w_kalpha cbar_l Cmax ///
		 Cmax_CQTE Cmax_CATE Cmax_ATE Cmax_QTE ckpctile addckpctile ckvec ///
		 breakdown_ATE breakdown_CQTE_add breakdown_CQTE breakdown_CATE_add ///
		 breakdown_CATE breakdown_ATE breakdown_ATT breakdown_QTE

	// =========================================================================
	// 2. Parse input
	// =========================================================================

	syntax [anything] [if] [in],             /// 			 
	         [Quantiles(numlist)             ///
			 cmax                            ///
			 density                         ///
			 fullmodel] 
				
	if "`fullmodel'" != "" {
		tokenize `anything'
		local X `1' // treatment
		local W: list anything-X // a vector of observed covariates.
		fvrevar `W'
		local W `r(varlist)'
	}
	else {
		// TODO: this code parsing is copied from _tesen_cpi - would be better
		//       to have this in one place 
		if "`anything'" != ""{
			local Wsub `anything'
		}
			
		quietly estimates store temp
		local 0 `e(cmdline)'
		gettoken 0 : 0, parse(",")
		syntax anything [if] [in]
		
		// parse model specification
		_parse expand eqn op: anything
		gettoken ovar omvarlist : eqn_1
		gettoken tvar tmvarlist : eqn_2
		
		// check if covariates are the same for both models
		local covariates_equal : list omvarlist == tmvarlist
		if ~`covariates_equal'{
			local tmvarlist : list omvarlist|tmvarlist
		}
		
		// parse variables
		local Y `ovar'
		local X `tvar'
		fvrevar `tmvarlist' // this expands factor variables using temporary variables
		local W `r(varlist)'
	}
	
	// default if neither quantiles nor cmax selected
	if "`cmax'" == "" & "`quantiles'" == "" & "`density'" == ""{
		local cmax = "cmax"
		local quantiles .5 .75 .9
	}
	
	if "`Wsub'" == "" {
		local Wsub `W'
	}

	// final sample
	marksample touse
	markout `touse' `Y' `X' `W'
    qui count if `touse'
    local N = r(N)	 
	
	// check single plot for density
	local varlen : word count `Wsub'
	if "`density'" != "" & `varlen' > 1 {
		// TODO: get this right
		di as error "can only display one density..."
		exit 109
	}

	// dimensions
	qui count if `touse'
	local N = `r(N)'
	local K: word count `Wsub' // K = dimension(W)
	local Kall: word count `W' 

	// quantiles
	if "`quantiles'" != "" {
		foreach qt of numlist `quantiles' {
			local qts `"`qts' cksort[ceil (`N' * `qt'), 1], "'
		}
		local qts = substr("`qts'",1, strlen("`qts'") - 2)
	}
	
	// =========================================================================
	// 3. Calculate the c-dependence values of interest
	// =========================================================================
	
    qui logit `X' `W' if `touse', nolog
    
	// TODO: rewrite this so we don't have to just have these all in global mata
	//       memory
	qui putmata matW = (`W') matX = `X' if `touse', replace
    mata: matW = (matW, J(rows(matW),1,1)) // convert the covariates into matrix, add a column of all 1 to W
    mata: walpha = matW * st_matrix("e(b)")' //W * alpha'
    mata: p1w = invlogit(walpha) // estimation of P(X=1|W=w)
    mata: p0w = 1 :- p1w 
    mata: xw1 = (J(rows(matW), 1, 1), matW)
    mata: xw0 = (J(rows(matW), 1, 0), matW)
	
	// TODO: test this when there is only one covariate
    if `Kall' == 1 {   // if K = 1 then compare P(X=1|W=w) with P(X=1)
        qui summarize `X' if `touse' 
        scalar `p1w_k' = 1/r(N) *r(sum) // \hat{P(X=1)} = 1/N * \sum_{i=1}^N \mattbbm{1}(X_i = 1)
        mata: ckvector = abs(p1w :- st_numscalar("`p1w_k'"))
        mata: cbar = max(ckvector)
        mata: cksort = sort(ckvector, 1)
        if "`quantiles'" != "" { 
			mata: ckpctile = (`qts')
			mata: st_matrix("`ckpctile'", ckpctile)
		}
        mata: st_local("cbar", strofreal(cbar))

        matrix `cbar_l' = `cbar'

        if "`ckbar'" == "label" {
            local cbar `" `cbar' "c{subscript:`W'}" "' // the value of ckbar (with label)
        }
        else {
            local cbar `" `cbar' " " "'
        }

//         if "`saveall'" != "" {
//             mata: st_matrix("`ckvec'", ckvector)
//         }

        if "`density'" != "" {
            qui getmata ckdensity = cksort

            // kernel density estimate of N numbers
            kdensity ckdensity, name(ckdensity, replace) ///
                graphregion(color(white)) bgcolor(white) lcolor(black) ///
                ylabel(,nogrid angle(0)) title("") note("") ///
                xtitle("")
            
            drop ckdensity
        }
    }
	// if K > 1 compare the propensity score when leaving out each covariate 
    else { 
        local cbar
        forvalues k = 1(1)`K' {
            tokenize `Wsub'
            local Wk ``k'' // the kth component of W
            local W_k: list W - Wk // the remaining K-1 components
            qui logit `X' `W_k' if `touse', nolog
            qui putmata matW_k = (`W_k') matX = `X' if `touse', replace
			// convert the K-1 covariates into matrix, add a column of all 1 to W
            mata: matW_k = (matW_k, J(rows(matW_k),1,1)) 
            mata: w_kalpha = matW_k * st_matrix("e(b)")' //W_{-k} * alpha'
            mata: p1w_k = invlogit(w_kalpha) // estimation of P(W=1|W_{-K} = w_{-k})
            mata: ckvector = abs(p1w-p1w_k)
            mata: cbar = max(ckvector) // compute \bar{c_k}
            mata: st_local("addcbar", strofreal(cbar))
            matrix `cbar_l' = (nullmat(`cbar_l') \ `addcbar')

            mata: cksort = sort(ckvector,1) //sort in ascending order
            
			if "`quantiles'" != ""{
				mata: ckpctile = (`qts')
				mata: st_matrix("`addckpctile'", ckpctile)
				matrix `ckpctile' = (nullmat(`ckpctile') \ `addckpctile')
				mata: mata drop ckpctile
			}
			
            if "`ckbar'" == "label"{
                local cbar `"`cbar' `addcbar' "c{subscript:`Wk'}" "' // the value of cbar (with label on axis)
            }
            else {
                local cbar `"`cbar' `addcbar' " " "' // the value of cbar (no label)
            }

//             if "`saveall'" != "" {
// 			    mata: cvector = J(`N',`K',.)
//                 mata: cvector[.,`k'] = ckvector
//                 mata: st_matrix("`ckvec'", cvector)
// 				mata: mata drop cvector
//             }


            if "`density'" != "" {
                qui getmata cdensity`Wk' = cksort, force

                kdensity cdensity`Wk', name(cdependence`Wk', replace) ///
                    graphregion(color(white)) bgcolor(white) lcolor(black) ///
                    ylabel(,nogrid angle(0)) title("") note("") ///
                    xtitle("")
                
                drop cdensity`Wk'
            }
        }
    }
	
	// clean up mata memory
	mata: mata drop matW matX p1w p0w xw1 xw0 walpha
	mata: mata drop cksort matW_k w_kalpha p1w_k cbar ckvector
	
	// =========================================================================
	// 4. Return results
	// =========================================================================
	
	// restore the ereturn
	if "`fullmodel'" == ""{
		quietly estimates restore temp
		estimates drop temp
		
	}
	
	// save the quantiles of the leave-out-variable-k propensity score variations
	if "`quantiles'" != "" {
		matrix rowname `ckpctile' = `W'
		matrix colname `ckpctile' = `quantiles'	
		return matrix cquantiles `ckpctile'
	}
	// save the max c for each variable
	if "`cmax'" != ""{
		matrix rowname `cbar_l' = `W'
		matrix colname `cbar_l' = ckbar
		return matrix cmax `cbar_l' // save ckbar values for each covariates 
	}

//     // save the whole vector
// 	if "`ckvector'" != "" {
//         matrix colname `ckvec' = `W'
//         return matrix cvector `ckvec'
//     }
	
end
  
