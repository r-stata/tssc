prog ie_reg, eclass
  version 10.0
//    set trace on
//	set matadebug on
    if !replay() {
   syntax varlist(numeric) [if] [in] [fw pw iw aw] [, IRr Level(integer `c(level)')]
   gettoken y xvars: varlist
   marksample touse
   
   // deal here with weights passed to ls_m()
		
		local tempweight [`weight'`exp']
		gettoken w1 wv: tempweight, parse("=")
		gettoken wv wv: wv
		gettoken wv test: wv, parse("]")
       
	    if "`weight'"=="" {
		tempvar wv
        gen `wv' = 1
		}
		
    mata: m_ls("`varlist'", "`touse'", "`wv'")
 
 // returned results from mata
 
  tempname b V
  matrix `b' = r(b)'
  matrix `V' = r(V)
  local   N = r(N)  // number of cells 
  local   k = r(k)
  local  ll = r(ll)
 
matname `b' `xvars' _cons, c(.)
matname `V' `xvars' _cons

ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')
ereturn local depvar "`1'"  
ereturn scalar k   = `k'   // note: this is number of parameters
ereturn scalar ll  = `ll'  // note: this is deviance
ereturn local cmd = "ie_reg"

}
else { // replay
    syntax [, Level(integer `c(level)') IRr]
	}
	
if "`e(cmd)'" != "ie_reg" error 301
if `level' < 10 | `level' > 99 {
   di as err "level() must be between 10 and 99 inclusive"
   exit 198
   }
  
  if "`irr'"!="" {
		local eopt "eform(IRR)"
		
	}
	
    
 di as text "{hline 11}{c +}{hline 65}"
 di %10s as text "ie_reg results "              as text %55s   "Number of cells = "   as res %-7.0f e(N)
 di %10s as text "               "              as text %55s   "           mse	= "   as res %-7.5f e(ll)
 di %10s as text "               "              as text %55s   "            df  = "   as res %-7.0f e(k)
 
 ereturn display, level(`level') `eopt'
 end
 
 
// ls solution
//
capture mata mata drop m_ls() 
version 10 
 mata: 
 void m_ls(string scalar varlist, string scalar touse, string scalar wv)
   {
   real matrix M, X, XpX, V_ls
   real colvector y, b_ls, one
   real scalar n, k, dev
 
        M = X = y = one = .
        st_view(M, ., tokens(varlist), touse)
        st_subview(y, M, ., 1)
        st_subview(X, M, ., (2\.))
		st_view(w, ., wv, touse) 
        n = rows(X)
      one = J(n,1,1)
        X = (X,one)
        k = cols(X)
		XpX = X' * (w :* X)
		b_ls = pinv(XpX) * X' * (w :* y)
		dev = sum(w :* ((y :- X*b_ls):^2))/(n - k + 2)
		V_ls = dev * pinv(XpX)

// returns for posting
 
	st_eclear()
	st_matrix("r(b)", b_ls)
	st_matrix("r(V)", V_ls)
	st_numscalar("r(N)", n)
	st_numscalar("r(ll)", dev)
	st_numscalar("r(k)", k)
 }

end
 
 
