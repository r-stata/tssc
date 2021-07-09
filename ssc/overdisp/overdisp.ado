*! version 1.0.0  17may2018
program define overdisp, eclass byable(onecall)
       version 15

        if _by() {
                local BY `"by `_byvars'`_byrc0':"'
        }
        
        `BY' _vce_parserun overdisp, noeqlist jkopts(eclass): `0'
        
        if "`s(exit)'" != "" {
                ereturn local cmdline `"overdisp `0'"'
                exit
        }

        if replay() {
                if `"`e(cmd)'"' != "overdisp" { 
                        error 301
                }
                else if _by() { 
                        error 190 
                }
                else {
                        Display `0'
                }
                exit
        }
        `vv' ///
        `BY' Estimate `0'
        ereturn local cmdline `"overdisp `0'"'
        
end

program define Estimate, eclass byable(recall)
	syntax varlist(numeric ts min=2 fv) [if] [in], [ Level(cilevel) * ]
	
	// indicator for [if] and [in] conditions
	
	marksample touse  
	
	// Parsing display options 
	
	_get_diopts diopts rest, `options'
	qui cap Display, `diopts' `rest'
	if _rc==198 {
                Display, `diopts' `rest'
        }
	
	// Getting depvar, indepvars, and  computing test 
	
	gettoken depvar indepvars: varlist
	tempname b V df
	mata: _overdisp_work("`depvar'", "`indepvars'", "`b'", "`V'", ///
	      "`df'", "`touse'")
	
	// Doing work to post results using coeftable 
	   
	quietly count if `touse'
	local N = r(N)
	matrix rownames `b' = uhat
	matrix colnames `b' = uhat
	matrix rownames `V' = uhat
	matrix colnames `V' = uhat

	local dff = `df' 
	ereturn post `b' `V', esample(`touse') obs(`N') 	///
		     depname(`depvar') dof(`dff') buildfvinfo
	
	ereturn local cmd "overdisp"
	Display, bmatrix(e(b)) vmatrix(e(V)) `rest' `diopts' level(`level')
end 

program define Display
        syntax [, bmatrix(passthru) vmatrix(passthru) *]

        _get_diopts diopts other, `options'
        local myopts `bmatrix' `vmatrix'
        
        if "`other'"!=""{
                display "{err}option `other' not allowed"
                exit 198
        }
	_coef_table_header, title(Overdispersion test (H0: equidispersion))
	_coef_table, `diopts' `myopts'
		
end

mata:
void _overdisp_work (
	string scalar yvar,		///
	string scalar xvars,		///
	string scalar beta,		///
	string scalar Var, 		///
	string scalar df,		///
	string scalar touse)
{
	real scalar n, cha, iter, k, tmle, pmle, n2, k2
	real vector y, b, u, sco, bold, bmle, ystar, b2, e2, s2
	real matrix X, hes, gradmatrix, Vmle, semle, V2, se2
	
	st_view(y=., ., yvar, touse)
	st_view(X=., ., tokens(xvars), touse)
	X = X, J(rows(X), 1, 1)
	b = invsym(X'X)*X'(ln(y+(y:==0)*0.1))
	n = rows(X)
	cha = 1
	iter = 1
	do {
	u = exp(X*b)
	sco = (X'(y-u))/n
	hes = -(X'(X:*u))/n
	bold = b
	b = bold + invsym(-hes)*sco
	cha = (bold-b)'(bold-b)/(b'b)
	iter = iter + 1
	} while (cha > 1e-16)
	bmle = b
	k = cols(X)
	gradmatrix = X:*(y-u)
	Vmle = invsym(-n*hes)*(gradmatrix'gradmatrix)*invsym(-n*hes)*(n/(n-k))
	semle = sqrt(diagonal(Vmle))
	tmle = bmle:/semle
	pmle = 2*ttail(n-k, abs(tmle))
	ystar=(((y-u):^2)-y):/(u)
	b2 = invsym(u'u)*u'ystar
	e2 = ystar - u*b2
	n2 = rows(u)
	k2 = cols(u)
	s2 = (e2'e2)/(n2-k2)
	V2 = s2*invsym(u'u)
	se2 = sqrt(diagonal(V2))
	st_matrix(beta, b2)
	st_matrix(Var, V2)
	st_numscalar(df, n2-k2)
}
end
