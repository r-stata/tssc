prog ie_rate, eclass
  version 12.0 
// Dan Powers
// Dept. Sociology
// University of Texas at Austin
// 4/20/12  
// set matastrict on
// set matadebug on
// 2/2/14 added binomial logit option
if !replay() {
   syntax varlist(numeric) [if] [in] [fw pw iw aw] ///
                           [, SCAle(string) BINom(varname numeric) OFFset(varname numeric) EForm Level(integer `c(level)') LOGit]
   
   marksample touse // except for offset
	
	// deal with weights passed to nr_logit() and nr_loglin()
		
		local tempweight [`weight'`exp']
		gettoken w1 wv: tempweight, parse("=")
		gettoken wv wv: wv
		gettoken wv test: wv, parse("]")
        
		if "`weight'"=="" {
		tempvar wv
        gen double `wv' = 1
		}
	 
	 
	// process offset (set to zero if absent)
	
   	    if "`offset'"!="" {
		markout `touse' `offset'
		local offopt "offset(`offset')"
		if "`offvar'"=="" {
			local offvar "`offset'"
		}
	}
   	
		if "`offset'"=="" {
	    markout `touse'
		local offopt "offset(`offset')"
		if "`offvar'"=="" {
		tempvar offset zero
		qui gen double `zero' = 0
		
			local offvar  "`zero'"
		}
	}
	
// process binomial denominator (set to one if absent)
	
   	    if "`binom'"!="" {
		markout `touse' `binom'
		local binopt "binom(`binom')"
		if "`binden'"=="" {
			local binden "`binom'"
		}
	}
   	
		if "`binom'"=="" {
	    markout `touse'
		local binopt "binom(`binom')"
		if "`binden'"=="" {
		tempvar binom one
		qui gen double `one' = 1.0
		
			local binden  "`one'"
		}
	}
	// process scale if present (only deviance allowed)
	if `"`scale'"'=="dev" {
			local scale 1
		}
	if "`scale'"=="" {
			local scale 0
		}  
	   
// process logit option (default to loglinear if missing)
	 
	 
 gettoken y xvars: varlist
   
 
  
 if "`logit'"!="" {
 // probability model
 // get start values
 // check for zeros 
 tempname logitr 
 qui count if ( `y' < 0 ) & `touse'
	 if r(N) > 0 {
     di as txt "`r(N)' observations are less than 0, these will be ignored"
	   }
     qui replace `touse' = 0 if ( `y' < 0 ) 
     qui replace `y' = `y' + .5 if ( `y' == 0 ) 

// ignore offset for start
// response is empirical logit

 qui gen double `logitr' = log(`y'/`binden') - log( 1 - `y'/`binden') if `touse'
   
 qui ie_reg `logitr' `xvars' if `touse'  // fitting logit model 
 
 local vnames: colnames e(b)
 
 // call mata subroutine (logit)

 mata: m_nrlogit("`varlist'", "`touse'", "`offvar'", "`binden'", "`wv'", `scale')
 }
 
 if "`logit'"=="" {
 // rate model
 // get start values
 // check for zeros 
 tempname logr
 qui count if ( `y' < 0 ) & `touse'
	 if r(N) > 0 {
     di as txt "`r(N)' observations are less than 0, these will be ignored"
	   }
     qui replace `touse' = 0 if ( `y' < 0 ) 
     qui replace `y' = `y' + .5 if ( `y' == 0 ) 
 
 qui gen double `logr' = log(`y'/exp(`offvar')) if `touse'
 qui ie_reg `logr' `xvars' if `touse'    // fitting loglinear model
 
 local vnames: colnames e(b)
 
// call mata subroutine (loglinear)
 
 mata: m_nrloglin("`varlist'", "`touse'", "`offvar'", "`wv'", `scale')
 }
 
// return results from mata subroutines
 
  tempname b V 
  matrix `b' = r(b)'
  matrix `V' = r(V)
  
  
  local   N = r(N)  // number of cells 
  local   k = r(k)
  local  ll = r(ll)
  local  df = r(df_r)
 
matname `b' `xvars' _cons, c(.)
matname `V' `xvars' _cons

ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')
ereturn local depvar "`1'"  
ereturn scalar k   = `k'   // note: this is number of parameters
ereturn scalar ll  = `ll'  // note: this is deviance
ereturn scalar df = `df'   // residual df
ereturn local cmd = "ie_rate"
ereturn local cmdline `"`0'"'
}

else { // replay
    syntax [, Level(integer `c(level)') EForm]
	}
	
if "`e(cmd)'" != "ie_rate" error 301
if `level' < 10 | `level' > 99 {
   di as err "level() must be between 10 and 99 inclusive"
   exit 198
   }
  	
// extra display info    
 di as text "{hline 11}{c +}{hline 65}"
 di %10s as text "ie_rate Results"              as text %50s    "Number of cells =   "   as res %7.0f e(N)
 di %10s as text "               "              as text %50s    "Deviance        =   "   as res %-12.3f e(ll)
 di %10s as text "               "              as text %50s    "Parameters      =   "   as res %7.0f e(k)
 di %10s as text "               "              as text %50s    "Residual df     =   "   as res %7.0f e(df)
 
if "`eform'"=="" ereturn display, level(`level')
    else ereturn display, level(`level') eform("exp(b)")

end
 
//	
// Newton Raphson for logit fit 
//

capture mata mata drop m_nrlogit() 
version 10 
 mata: 
 void m_nrlogit(string scalar varlist, string scalar touse, string scalar offset, string scalar binom, string scalar wv, scalar scale)
   {
   real matrix g, M, X, H, I_negH, Q, QLQ
   real colvector y, mu, p, w, v, b_new, b_old, db, tol, one, off, bind, L, lamInv, iLam
   real scalar n, k, iter, dev
   
        M = X = y = one = bind = off = .
        st_view(M, ., tokens(varlist), touse)
        st_subview(y, M, ., 1)
        st_subview(X, M, ., (2\.))
        st_view(off, ., offset, touse) 
        st_view(bind, ., binom, touse)
	    st_view(w, ., wv, touse) 
        n = rows(X)
    b_old = st_matrix("e(b)")'
      one = J(n,1,1)
        X = (X,one)
        k = cols(X)
       iter = 0
        tol = J(k,1,1.e-8)
         db = J(k,1,1)
 
   while (abs(db) > tol) {
			p = invlogit(X*b_old :+ off) 
			mu = p :* bind
			v  = mu :* (1 :- p)
			g = X' * (w :* (y  :- mu))
			H = X' * (w :* (v  :*  X))
		symeigensystem(H,Q,L)
		lamInv = 1:/L
		lamInv[k] = 0
		iLam = diag(lamInv)
		QLQ = Q*iLam*Q'
      	I_negH = QLQ	
	     
		b_new = b_old :+ I_negH * g
		
		   db = b_new - b_old
		b_old = b_new
		 iter = iter + 1
		  dev = 2 * sum(w :* (y :* log(y:/mu) -  y :+ mu) )
		  if (scale == 1) I_negH = dev/(n - k + 1) * QLQ 
	  
		printf("iteration %g \n", iter)
		printf("deviance %g \n", dev)
		// if determinant is 0 Stata display chokes
     }

// returns for posting
 
	st_eclear()
	st_matrix("r(b)", b_new)
	st_matrix("r(V)", I_negH)
	st_numscalar("r(N)", n)
	st_numscalar("r(ll)", dev)
	st_numscalar("r(k)", k)
	st_numscalar("r(df_r)", n - k + 1)
 }

end

//	
// Newton Raphson for loglinear fit
//

capture mata mata drop m_nrloglin() 
version 10 
 mata: 
 void m_nrloglin(string scalar varlist, string scalar touse, string scalar offset, string scalar wv, scalar scale)
   {
   real matrix M, X, H, I_negH, Q, QLQ
   real colvector y, b_new, b_old, db, tol, one, off, L, lamInv, iLam
   real scalar n, k, iter, dev
   
        M = X = y = one = off = .
        st_view(M, ., tokens(varlist), touse)
        st_subview(y, M, ., 1)
        st_subview(X, M, ., (2\.))
        st_view(off, ., offset, touse) 
		st_view(w, ., wv, touse) 
        n = rows(X)
    b_old = st_matrix("e(b)")'
      one = J(n,1,1)
        X = (X,one)
        k = cols(X)
       iter = 0
        tol = J(k,1,1.e-8)
         db = J(k,1,1)
 
   while (abs(db) > tol) {
			mu = exp(X*b_old :+ off)
			g = X' * (w :* (y  :- mu))
			H = X' * (w :* (mu :* X))
		symeigensystem(H,Q,L)
		lamInv = 1:/L
		lamInv[k] = 0
		iLam = diag(lamInv)
		QLQ = Q*iLam*Q'
        I_negH = QLQ	
	      
		b_new = b_old :+ I_negH * g
		 
		   db = b_new - b_old
		b_old = b_new
		 iter = iter + 1
		  dev = 2 * sum(w :* (y :* log(y:/mu) -  y :+ mu) )
		  if (scale == 1) I_negH = dev/(n - k + 1) * QLQ 
	  
		printf("iteration %g \n", iter)
		printf("deviance %g \n", dev)
		// if determinant is 0 Stata display chokes
		
     }

// returns for posting
 
	st_eclear()
	st_matrix("r(b)", b_new)
	st_matrix("r(V)", I_negH)
	st_numscalar("r(N)", n)
	st_numscalar("r(ll)", dev)
	st_numscalar("r(k)", k)
	st_numscalar("r(df_r)", n - k + 1)
 }

end
 

