*! v.1.0.0 M.Bottai, N.Orsini 03feb15
*! v.1.0.0 M.Bottai, N.Orsini 09jun13

capture program drop laplacereg
program laplacereg, eclass properties(mi) byable(onecall)
version 10 

if _by() {
		local BY `"by `_byvars'`_byrc0':"'
}
	
`version' `BY' _vce_parserun laplacereg, mark(OFFset CLuster) : `0'

if "`s(exit)'" != "" {
		version 10: ereturn local cmdline `"laplacereg `0'"'
		exit
	}

if replay() {
		if ("`e(cmd)'"!="laplacereg")  error 301  
		Replay `0'
	}
else `version' `BY' Estimate `0'
end

capture program drop Estimate 
version 11, missing

program Estimate, eclass byable(recall)
	syntax varlist(fv)  [if] [in] [fw pw] ///
	[, Level(integer $S_level) ///
	   Quantiles(numlist) ///
	   Failure(string) ///
	   Reps(string) ///
	   TOLerance(real 1e-10) ///
	   MAXiter(integer 2000) /// 
	   SEED(string) ///
	   link(string) ///
	   sigma(varlist) coef ]
	   
	 	local fvops = "`s(fvops)'" == "true" | _caller() >= 11  
	   	if `fvops' {
		_get_diopts diopts options, `options'
		ret list
	}
	
    local cmdline : copy local 0
	marksample touse 

// Check weights

	tempvar wgt
	if "`weight'" == ""  {
 	    gen `wgt' = 1
	}
    else  {
    	local weights [`weight'`exp']
 	    gen `wgt' `exp'
	}
 
// Weights not allowed if bootstrap is specified 

	if "`weight'" != ""  {
 	    if "`reps'" != "" {
 	    	di as err "bootstrap not allowed with weights"
 	    	exit 198
 	   } 
	}

// Check the failure variable
		
		local nofailure = 0
		if "`failure'" == "" {
					tempname failure
					qui gen `failure' = 1 if `touse'
					local nofailure = 1
		}
		else {
				confirm variable `failure'
				confirm numeric variable `failure'
				qui replace `failure' = (`failure' != 0) if `touse'
		}

// Set the seed

			if "`seed'" != "" {
				set seed `seed'
			}
			local seed `c(seed)'
 
// Check specified quantiles 

		if "`quantiles'" == "" local quantiles = .5
 		
 		foreach i of local quantiles   {
 			local tempq "`i'"
  			if `tempq' >= 1 & `tempq' < 100 { 
						if `tempq' >= 1 & `tempq' < 10 { 
 						local tempq "0`tempq'"
 						}
 		    local tempq : subinstr local tempq "." "", all   
 		    local tempq ".`tempq'" 
 			}
 			
 			local newquantiles "`newquantiles' `tempq'"
			if (`tempq'<=0  | `tempq'>=1) {
						di as err "specified quantiles out of the range (0,1)"
						exit 198
			}
 		}
 		
 		local quantiles "`newquantiles'"
 		local quantiles : list uniq  quantiles
 		local quantiles:   list sort quantiles
   		 
		tempname quantlist
		local s = 1
 		local ml = 2
		foreach i of local quantiles   {
 			if (length("`i'")-1) > `ml' local ml = length("`i'")-1
 			if `s++' == 1 mat `quantlist' = `i'
			else mat `quantlist' = (`quantlist' , `i')
 		}
 				
		local newquantiles ""
 		foreach i of local quantiles   {
				local newquantiles "`newquantiles' `: di %`=`ml'+1'.`ml'f `i''" 
  		}
  		
        local quantiles `newquantiles' 
  				  					 			
// Check number of bootstrap replications 
// Set asymptotic variance estimator as default
 
 		if ("`reps'" == "") {
							local nreps = 0
		}
		else {
				if `reps'<2  {
						di  as err "specify more than 1 replication"
						exit  
				}
				local nreps = `reps'
		}
			
// Remove collinear variables

		gettoken depv indepv : varlist		
		_rmcoll `indepv' `weights' if `touse' 
		local indepv `r(varlist)'  
		
		local nx : word count `indepv'
 		local eqnames : subinstr local quantiles "0." "q", all   
 
// Make a copy of the original outcome
	tempvar outcome
	gen double `outcome' = `depv'

// Check link function

if ("`link'" != "") qui replace `outcome' = `link'(`outcome')

// Define labels for the regression coefficients for each quantile

	local nq : word count `quantiles'
	forv i = 1/`nq' {
		local pq : word `i' of `eqnames' 
		local conams "`conams' `indepv' _cons"
 		forv j = 1/`=`nx'+1' {
			local eqnams "`eqnams' `pq'"
		}
 	}   

// Get number of observations and failures

	qui su `wgt' if  `touse'		
	local nobs = r(sum)
	qui su `wgt' if `failure' == 1 & `touse' == 1
	local notcensored = r(sum)
	
if ("`weight'" == "pweight") {
	qui count if  `touse'		
	local nobs = r(N)
	qui count if `failure' == 1 & `touse' == 1
	local notcensored = r(N)
}

// Define the maximization algorithm 

	if (`notcensored' == `nobs') {
		local lfname "laplace_gs0"
	}
	else {
		local lfname "laplace_gs"
	}

// Check variable list for sigma. It applies only if failure is specified.
		
	if "`sigma'" == "" {
			local varsigma ""
	}
	else {
			_rmcoll `sigma' `weights' if `touse'
			local varsigma  `r(varlist)' 
	}
	if (`nofailure' == 1 & "`sigma'" != "") {
		* the option sigma() is ignored if the option failure() is not specified  
	    local varsigma "" 
	}

 

// Estimation and bootstrap confidence intervals
 
		mata: laplacereg("`outcome'", "`indepv'", "`failure'",  "`touse'", "`wgt'", "`quantlist'", `nreps', `maxiter', `tolerance',  &`lfname'(), "`varsigma'")
		tempname coefs VCE  
		mat `coefs' = _beta
		mat `VCE' = VCE_beta 

		mat colnames `coefs' = `conams'
		mat coleq `coefs' = `eqnams'
		mat rownames `VCE' = `conams'
		mat roweq `VCE' = `eqnams'
		mat colnames `VCE' = `conams'
		mat coleq `VCE' = `eqnams'

		ereturn post `coefs' `VCE', obs(`nobs')  depn(`depv') 	
		ereturn local qlist "`quantiles'"
		ereturn repost, esample(`touse')
		
		ereturn local depvar "`depv'"
		if (`nofailure' != 1) ereturn local failvar "`failure'"
		if "`reps'" != "" ereturn scalar reps = `reps'
		ereturn scalar N = `nobs'

		if (`nofailure' == 0) ereturn scalar  N_fail = `notcensored'
		ereturn scalar n_q = `nq'
		ereturn local eqnames "`eqnames'"

		if "`reps'" != "" ereturn local vcetype "Bootstrap"
		else ereturn local vcetype "Robust"
		ereturn local predict "sqreg_p"
		ereturn local cmdline `"laplacereg `cmdline'"'
		ereturn local cmd "laplacereg"

		if "`weight'" != "" {
			ereturn local wexp = "`exp'"
			ereturn local wtype = "`weight'" 
		}
	
		ereturn repost
 			
		di _n in gr "Laplace regression"  _col(50) "No. of subjects  = " in ye %10.0g e(N)
		
		if (`nofailure' != 1) di as text "" _col(50) in gr "No. of failures  = " in y %10.0f  e(N_fail) 
	
	   if ("`link'" == "" | "`coef'" != "") {
			Replay, level(`level')  
	   }
	   else {
			Replay, level(`level')  label("Perc. Ratio")
	   }
	   
end

capture program drop Replay
program Replay
	syntax [, Level(cilevel) label(string) ]
	ereturn display, level(`level') eform(`label') 
end


mata
mata clear
mata set matastrict off

real scalar laplace_lf(real rowvector p, real colvector y, real matrix X, real matrix XS, real colvector d, real colvector wgt, real scalar q)
{
	real scalar lf
	real colvector s , z
    s = exp(XS*p[1,(cols(X)+1)::(cols(X)+cols(XS))]')
    z = (y:-X*p[1,(1::cols(X))]'):/s
    lf = mean(((z:<=0):*(d:*((1:-q):*z:+log(q*(1-q):/s)) :+ (1:-d):*log(abs(1:-q:*exp((1:-q):*z))) ) + (z:>0):*( d :*(-q:*z:+log(q*(1-q):/s)) :+ (1:-d):*(-q:*z:+log(1-q)) )),wgt)
	return(lf)
}
 
real scalar laplace_lf0(real rowvector p, real colvector y, real matrix X, real colvector wgt, real scalar q)
{
	real scalar lf
	real colvector z
    z = (y:-X*p[1::cols(X)]')
    lf = mean(z:*(q:-(z:<=0)),wgt)
	return(lf)
}
 	
real matrix laplace_gs(real rowvector bi, real scalar maxiter, 
					   real scalar tol, real scalar step, real colvector y, real matrix X, real matrix XS,
					   real colvector d, real colvector wgt, real scalar q)
{  
	real rowvector b, nb, lb, ls  
	real scalar n, l, nl,  i , rf
	real colvector z, h, s
	real matrix tx
	b = bi	
	n = sum(wgt)
	tx = (wgt:*X)':/n
    txs = (wgt:*XS)':/n
	rf = .999 + (.999-.5)/999 - (.999-.5)/999*min((n,1000))
	l = laplace_lf(b, y, X, XS, d, wgt, q)	
	s = exp(XS*b[1,(cols(X)+1)::(cols(X)+cols(XS))]')
	z = (y:-X*b[1,1::cols(X)]'):/s
	h = (q:-(z:<=0):-(1:-d):*(z:<=0):*(q:-1):/(1:-q:*exp((1:-q):*z)))
	lb = tx*(h:/s)
	ls = txs*(z:*h:-d)
	for (i=1; i<=maxiter; i++) {
 	 	    nb = b :+ (lb', ls'):*step
			nl = laplace_lf(nb, y, X, XS, d, wgt, q)
 			if (nl>l-tol & nl!=.) {			
					if (abs(nl-l)<tol) return(nb)		
					b = nb
					l = nl
					s = exp(XS*b[1,(cols(X)+1)::(cols(b))]')
					z = (y:-X*b[1,1::cols(X)]'):/s
					h = (q:-(z:<=0):-(1:-d):*(z:<=0):*(q:-1):/(1:-q:*exp((1:-q):*z)))
					lb = tx*(h:/s)
					ls = txs*(z:*h:-d)
					step = step*1.25
			}
	    	else {
				 step = step*rf
			   }
 		}
	printf("{err:x}")
	displayflush()
 	return(b)


}
 

real matrix laplace_gs0(real rowvector bi, real scalar maxiter, 
					    real scalar tol, real scalar step, real colvector y, real matrix X, real matrix XS,
					    real colvector d, real colvector wgt, real scalar q)
{  
	real rowvector b, nb, lb
	real scalar n, l, nl, i, rf
	real matrix tx

	b = bi[1,1::cols(X)]
	tx = (wgt:*X)':/sum(wgt)
	rf = .999 + (.999-.5)/999 - (.999-.5)/999*min((n,1000))
	l = laplace_lf0(b, y, X, wgt, q)		
 	lb = (tx*(q:-(y:<=X*b')))'
		for (i=1; i<=maxiter; i++) {
	 	    nb = b :+ lb:*step
			nl = laplace_lf0(nb, y, X, wgt, q)	
			if (nl<l+tol & nl!=.) { 
					if (abs(nl-l)<tol) return((nb , J(1,cols(XS),0)))
					b = nb
					l = nl			
					lb = (tx*(q:-(y:<=X*b')) )'  
					step = step*1.25
			}
	    	else {	
				 step = step*rf
			   }		 
 		}
	printf("{err:x}")
	displayflush()
	return(b , J(1,cols(XS),0))
 }

real matrix laplacereg(string scalar depv, string matrix indepv, string scalar censored, 
                   string scalar touse, string scalar bwgt, string scalar qlist, 
                   real scalar boot, real scalar maxi, real scalar tol, pointer(real scalar function) scalar f, 
                   string matrix vsigma)
{
	real rowvector th, binit, beta, beta2, covlist, quantiles 
	real colvector  r, s,  y, d 
	real scalar 	step, i, j, ya, yb
	real matrix 	tb, X, XS

	covlist = st_varindex(tokens(indepv))
	st_view(y=., ., depv, touse)
	st_view(X=., ., covlist, touse)
    st_view(d=., ., censored, touse)
	slist = st_varindex(tokens(vsigma))
	st_view(XS=., ., slist, touse)
	yinit = y
    st_view(wgt=., ., bwgt, touse)

	// Rescale the dependent variable to avoid problems of overflow
	 ya = min(y)
     yb = (max(y)-min(y))/10
     y = (y:-ya):/yb
	
	// Transform the covariates (standardize)
	if (cols(X)>0) {
	meanX = mean(X, wgt)
	sdX = sqrt(diagonal(variance(X, wgt)))'
	Z = (X :- meanX):/sdX
	Z = (Z,J(rows(y),1,1)) 
	}
	else {
	Z = J(rows(y),1,1)
	}
 
	// Transform the covariates (standardize) for Sigma
	if (cols(XS)>0) {
	meanXS = mean(XS, wgt)
	sdXS = sqrt(diagonal(variance(XS, wgt)))'
	ZS = (XS :- meanXS):/sdXS
	ZS = (ZS,J(rows(y),1,1))
	}
	else {
	ZS = J(rows(y),1,1)
	}
 
    binit = ((invsym((wgt:*Z)'Z)*(wgt:*Z)'y)', J(1, cols(ZS), 0)) 
 	ostep = sqrt(variance(y, wgt))    
 	quantiles = st_matrix(qlist)
  
	th = J(1, (cols(quantiles)*(cols(Z)+cols(ZS))), .)	
 
	// Get point estimates 
	
	for (i=1; i<=cols(quantiles); i++) { 
		step = ostep
		th[1,((i-1)*(cols(Z)+cols(ZS))+1)::(i*(cols(Z)+cols(ZS)))] = (*f)(binit, maxi,  tol, step, y, Z, ZS, d, wgt, quantiles[1,i])
 	    beta = th[1,((i-1)*(cols(Z)+cols(ZS))+1)::(i*(cols(Z)+cols(ZS)))]
		beta = beta[1,1::cols(Z)]
 
     // back transform the betas because of transformed response
     
		 beta = beta[1,1::cols(Z)]:*yb :+ (J(1,cols(Z)-1,0),1):*ya
			  
	 // back transform the betas because of transformed covariates 

		 if (cols(X)>0) {
						   beta[1,cols(Z)] = beta[1,cols(Z)] - (beta[1, 1::cols(Z)-1]*(meanX:/sdX)')
						   beta[1, 1::cols(Z)-1] = beta[1, 1::cols(Z)-1]:/sdX
		  }
		  
		  	if (i==1)  beta2 = beta
			else beta2 = beta2, beta			
			 			
		// Get the asymptotic variance/covariance matrix and create a block-diagonal matrix 
 
		if (boot==0) {	
				
						beta = th[1,((i-1)*(cols(Z)+cols(ZS))+1)::(i*(cols(Z)+cols(ZS)))]
						BZ = beta[1,1::cols(Z)]
						BZS = beta[(cols(Z)+1)::(cols(Z)+cols(ZS))]
                        
						s = exp(ZS*BZS') 
	                    z = (y:-Z*BZ') :/ s
					    q = quantiles[1,i]
						 
				     	h = sqrt(variance(z,wgt))/log(sum(wgt)) 
						S = Z:*((q:-(z:<=0):-(1:-d):*(z:<=0):*(q:-1):/(1:-q:*exp((1:-q):*z)))):/s
				 
						z1 = z :+ h 
						z2 = z :- h
						
						K1 = (q:-(z1:<=0):-(1:-d):*(z1:<=0):*(q:-1):/(1:-q:*exp((1:-q):*z1))):/s
						K2 = (q:-(z2:<=0):-(1:-d):*(z2:<=0):*(q:-1):/(1:-q:*exp((1:-q):*z2))):/s
					 
						H = invsym(( (wgt:*Z)'*(Z:*(K1:-K2):/2:/h:/s)) )
						 
						VBV  =  H*(wgt:*S)'*S*H            
						VBVN = VBV:*yb^2

						if(cols(Z)>1) {
							VBVN = VBVN:/( (sdX, 1)'* (sdX, 1) )
							for (r=1; r<=(cols(Z)-1); r++) {                                                                    
											VBVN[cols(Z), cols(Z)] = VBVN[cols(Z), cols(Z)] + VBVN[r,r]*(meanX[1,r]^2) - 2*VBVN[cols(Z),r]*meanX[1,r]
											VBVN[cols(Z), r] = VBVN[cols(Z), r] - VBVN[r, r]*meanX[1,r]
											 VBVN[r, cols(Z)] = VBVN[cols(Z), r]  
							}             
						}

						for (k=1; k<=cols(VBVN); k++) { 
								for (h=1; h<=cols(VBVN); h++) { 
									if (VBVN[k,h] == .) VBVN[k,h]=0
								}					
						}
						
						_makesymmetric(VBVN)
						
						if (i==1) AV = VBVN
						else AV = blockdiag(AV, VBVN)
					 
		}
	
	}
	 
	// Get bootstrap confidence intervals
		tb = J(cols(quantiles)*(cols(Z)),boot, .)
 
		for (i=1; i<=boot; i++) {

			s = ceil(rows(y) * uniform(rows(y), 1))
 			bwgt =  wgt 
			
			// Rescale the dependent variable to avoid problems of overflow
			yab = min(yinit[s])
			ybb = (max(yinit[s])-yab)/10
			yboot = (yinit[s]:-yab):/ybb
 
			// Transform the covariates (standardize)
			if (cols(X)>0) {
			meanXb = mean(X[s,], bwgt)
			sdXb = sqrt(diagonal(variance(X[s,], bwgt)))'
			Z = (X[s,] :- meanXb):/sdXb
			Z = (Z,J(rows(s),1,1))
			}
			else {
			Z = J(rows(s),1,1)
			}
			 
			// Transform the covariates (standardize) for Sigma
			if (cols(XS)>0) {
			meanXSb = mean(XS[s,], bwgt)
			sdXSb = sqrt(diagonal(variance(XS[s,], bwgt)))'	 
			ZS = (XS[s,] :- meanXSb):/sdXSb
			ZS = (ZS,J(rows(s),1,1))
			}
			else {
			ZS = J(rows(s),1,1)
			}
			binitb = ((invsym(Z'Z)*Z'yboot)', J(1, cols(ZS), 0)) 
  			step = sqrt(variance(yboot, bwgt))  					 

			for (j=1; j<=cols(quantiles); j++) {
					 TB = (*f)(binitb, maxi,  tol, step, yboot, Z, ZS, d[s], bwgt, quantiles[1,j])	 
					 TB = TB[1,1::cols(Z)]:*ybb :+ (J(1,cols(Z)-1,0),1):*yab
 
						if (cols(X)>0) {	 
								   TB[1, cols(Z)]  = TB[1,cols(Z)] - (TB[1, 1::(cols(Z)-1)]*(meanXb:/sdXb)')
								   TB[1, 1::(cols(Z)-1)] = TB[1, 1::(cols(Z)-1)]:/sdXb
						}
						 
					 tb[((j-1)*(cols(Z))+1)::(j*(cols(Z))),i] = TB'
				 }
 	 
	              
 
					
			
		}
 
  
    st_matrix("_beta", beta2)
    if (boot!=0) st_matrix("VCE_beta", variance(tb'))
	else st_matrix("VCE_beta",  AV)
   
}

end

exit
 
// Example
clear   
set more off
set obs 1000
local q = .5
gen x1 = invnorm(uniform())
gen x2 = uniform() < .5
gen t = 30 + 5*x1 + 20*x2 + invnorm(uniform()) - invnorm(`q')
gen c = 30 + 5*x1 + 20*x2 + invnorm(uniform()) - invnorm(`q')
gen y = min(t, c)
gen d = t <= c
gen logy = log(y)
laplacereg logy x1 x2, f(d) q(`q')
est table , eform
laplacereg y x1 x2, f(d) q(`q') link(log)
laplacereg y x1 x2, f(d) q(`q') link(log) coef
lincom x1, eform



