*! mlr2sls version 11 - Last update: August 14, 2018 
*! Authors: Seojeong Lee (jay.lee@unsw.edu.au)
*!			Dandan Yu (dandan.yu@student.unsw.edu.au)
*!
*! NOTE
*! -mlr2sls- uses -ivreg2-.

program mlr2sls, eclass sortpreserve
    version 11
	
    local options "Level(cilevel)"

    if replay() {
    
	if "`e(cmd)'" != "mlr2sls" {
         error 301
    }
         syntax [, `options']
    }

	else {

	syntax anything(equalok) [if] [in] [, vce(string) `options']
	marksample touse
	
  * for the return of proper error messages
	
	qui ivreg2 `anything' `if' `in'
		
  * extract variables for calculation
  
    local depvar = `"`e(depvar)'"'
    local inexog = `"`e(inexog)'"'
	local exexog = `"`e(exexog)'"'
	local endo = `"`e(instd)'"'
  
  	local exog `inexog' `exexog'
	local cnames `endo' `inexog'
	
	markout `touse' `depvar' `exog' `cnames'
	
* allowing for four types of standard error
  ** multiple-LATEs-robust standard error (default)
  ** cluster-and-multiple-LATEs-robust standard error
  ** conventional heteroskedasticity robust standard error
  ** conventional cluster robust standard error

    _vce_parse, optlist(MLRobust CONVentional) argoptlist(CCLuster MLCRobust):, vce(`vce')
	local vce `r(vce)'

    if "`vce'" == "ccluster" | "`vce'" == "mlcrobust" {
        local case: word count `r(vceargs)'
	
        if `case' > 2 { //* allowing for at most cluster variables	
		   display as error "At most two cluster variables are allowed"
		   exit 198
	    } 
        else {
			local clustvar `r(vceargs)'
		    capture confirm numeric variable `clustvar'
            if _rc {
                display as error "Invalid vce() option"
                display as error "String variable is not allowed"
                exit 198
            }
			markout `touse' `clustvar'
        }	
    }
	
	tempname b V VA VB VAB N
	tempvar clustvarAB
	
  * calculation of estimated coefficients
    
	mata: beta("`depvar'", "`exog'", "`cnames'", "`touse'", "`b'", "`N'")	

  * calculation of multiple-LATEs-robust standard error
    
	if "`vce'" == "" | "`vce'" == "mlrobust" {
	    local vcetype "MLATE Robust"
        mata: mlrobust("`depvar'", "`exog'", "`cnames'", "`touse'", "`V'")
    }
	
  * calculation of cluster-and-multiple-LATEs-robust standard error
    
	if "`vce'" == "mlcrobust" {
        local vcetype "MLATE Cluster"
		if `case' == 1 { 
		    sort `clustvar'
		    mata: mlcrobust("`depvar'", "`exog'", "`cnames'", "`clustvar'", "`touse'", "`V'")
        }
		if `case' == 2 {
		    gettoken clustvarA clustvarB: clustvar
		    sort `clustvarA'
		    mata: mlcrobust("`depvar'", "`exog'", "`cnames'", "`clustvarA'", "`touse'", "`VA'")
		    sort `clustvarB'
		    mata: mlcrobust("`depvar'", "`exog'", "`cnames'", "`clustvarB'", "`touse'", "`VB'")
		    egen double `clustvarAB' = group(`clustvar')
			sort `clustvarAB'
			mata: mlcrobust("`depvar'", "`exog'", "`cnames'", "`clustvarAB'", "`touse'", "`VAB'")
		    matrix `V' = `VA' + `VB' - `VAB'
	    }
	}
	
  * calculation of conventional heteroskedasticity robust standard error
    
	if "`vce'" == "conventional" {
        local vcetype "Conv. Robust"
	    mata: conventional("`depvar'", "`exog'", "`cnames'", "`touse'", "`V'")
    }

  * calculation of conventional cluster robust standard error
    
	if "`vce'" == "ccluster" {
	    local vcetype "Conv. Cluster"
        if `case' == 1 { 
		    sort `clustvar'
		    mata: ccluster("`depvar'", "`exog'", "`cnames'", "`clustvar'", "`touse'", "`V'")
        }
		if `case' == 2 {
		    gettoken clustvarA clustvarB: clustvar
		    sort `clustvarA'
		    mata: ccluster("`depvar'", "`exog'", "`cnames'", "`clustvarA'", "`touse'", "`VA'")
		    sort `clustvarB'
		    mata: ccluster("`depvar'", "`exog'", "`cnames'", "`clustvarB'", "`touse'", "`VB'")
		    egen double `clustvarAB' = group(`clustvar')
			sort `clustvarAB'
			mata: ccluster("`depvar'", "`exog'", "`cnames'", "`clustvarAB'", "`touse'", "`VAB'")
		    matrix `V' = `VA' + `VB' - `VAB'
	    }
    }

  * return content

    ereturn clear
	
    local cnames `cnames' _cons
	
	matrix colnames `b' = `cnames' 
    matrix colnames `V' = `cnames'
    matrix rownames `V' = `cnames'
		
	ereturn post `b' `V', esample(`touse') buildfvinfo
	ereturn scalar N = `N'

	ereturn local title "Instrumental variables (2SLS) regression"
	ereturn local instd `endo'
	ereturn local insts `exog'
	ereturn local exogr `inexog'
	ereturn local depvar `depvar'
	ereturn local vcetype `vcetype'
	ereturn local clustvar `clustvar'
	ereturn local vce `vce'
	ereturn local cmd "mlr2sls"
	
    }

	display "Instrumental variables (2SLS) regression" _c
	di in gr _col(55) "Number of obs = " in ye %8.0f e(N)
	ereturn display, level(`level')
	display "Instrumented: " _col(15) e(instd)
	display "Instruments: " _col(15) e(insts)

end

* mata function for estimated coefficients

mata:

void beta( string scalar depvar,   string scalar exog,    ///
           string scalar cnames,   string scalar touse,   /// 
           string scalar bname,    string scalar nname )  
{
    real vector    y, b
    real matrix    X, Z, XpZ, ZpZ, Zpy 
    real scalar    n
	
    y = st_data(., depvar, touse)
    X = st_data(., cnames, touse)
    Z = st_data(., exog, touse)
    n = rows(X)
	
	X = X, J(n, 1, 1)
    Z = Z, J(n, 1, 1)
    	
    XpZ = quadcross(X, Z)
    ZpZ = quadcross(Z, Z)
    Zpy = quadcross(Z, y)

    b = invsym(XpZ*invsym(ZpZ)*(XpZ'))*XpZ*invsym(ZpZ)*Zpy

    st_matrix(bname, b')
    st_numscalar(nname, n)
}

end

* mata function for multiple-LATEs-robust standard error

mata:

void mlrobust( string scalar depvar,   string scalar exog,    ///
               string scalar cnames,   string scalar touse,   /// 
               string scalar Vname)
{
    real vector    y, b, e
    real matrix    X, Z, XpZ, ZpZ, Zpy, Zpe, H, M, V 
    real scalar    n, kx, kz
	
    y = st_data(., depvar, touse)
    X = st_data(., cnames, touse)
    Z = st_data(., exog, touse)
    n = rows(X)
    
	X = X, J(n, 1, 1)
    Z = Z, J(n, 1, 1)
    
    XpZ = quadcross(X, Z)
    ZpZ = quadcross(Z, Z)
    Zpy = quadcross(Z, y)

    b = invsym(XpZ*invsym(ZpZ)*(XpZ'))*XpZ*invsym(ZpZ)*Zpy
    e = y - X * b
    Zpe = quadcross(Z, e)

    H = XpZ * invsym(ZpZ) * (XpZ')

    kx = cols(X)
    kz = cols(Z)

    M = J(kx, kx, 0)
	
	for(i=1; i<=n; i++) {
    
	    Xi = X[i, .]
        Zi = Z[i, .]
        ei = e[i, .]
    
	    fi = XpZ*invsym(ZpZ)*(Zi'*ei-(1/n)*Zpe) + (Xi'*Zi-(1/n)*XpZ)*invsym(ZpZ)*Zpe + XpZ*invsym(ZpZ)*((1/n)*ZpZ-Zi'*Zi)*invsym(ZpZ)*Zpe

        M = M + fi*fi'
    
	}

    V = invsym(H) * M * invsym(H)
    st_matrix(Vname, V)
}

end

* mata function for cluster-and-multiple-LATEs-robust standard error

mata:

void mlcrobust( string scalar depvar,  string scalar exog,       ///
                string scalar cnames,  string scalar clustvar,   ///
			    string scalar touse,   string scalar Vname)
{
    real vector    y, b, e, id
    real matrix    X, Z, XpZ, ZpZ, Zpy, Zpe, H, M, info, V 
    real scalar    n, kx, kz, nc
	
    y = st_data(., depvar, touse)
    X = st_data(., cnames, touse)
    Z = st_data(., exog, touse)
    n = rows(X)
    
	X = X, J(n, 1, 1)
    Z = Z, J(n, 1, 1)
    
    XpZ = quadcross(X, Z)
    ZpZ = quadcross(Z, Z)
    Zpy = quadcross(Z, y)

    b = invsym(XpZ*invsym(ZpZ)*(XpZ'))*XpZ*invsym(ZpZ)*Zpy
    e = y - X * b
	Zpe = quadcross(Z, e)
	
    id = st_data(., clustvar, touse)
    info = panelsetup(id, 1)
    nc = rows(info)
	
	H = XpZ * invsym(ZpZ) * (XpZ')
    kx = cols(X)
    kz = cols(Z)
    
	M = J(kx, kx, 0)

    for(g=1; g<=nc; g++) {
    
	    Xg = panelsubmatrix(X, g, info)
        Zg = panelsubmatrix(Z, g, info)
        eg = panelsubmatrix(e, g, info)

   	    Mg = J(kx, kx, 0)
	    ncg = info[g,2]-info[g,1]+1
	
        for(i=1; i<=ncg; i++) {
    
	        Xi = Xg[i, .]
            Zi = Zg[i, .]
            ei = eg[i, .]
    
	        fi = XpZ*invsym(ZpZ)*(Zi'*ei-(1/n)*Zpe) + (Xi'*Zi-(1/n)*XpZ)*invsym(ZpZ)*Zpe + XpZ*invsym(ZpZ)*((1/n)*ZpZ-Zi'*Zi)*invsym(ZpZ)*Zpe
            Pi = J(kx, kx, 0)
		
		    for(j=1; j<=ncg; j++) {
			
			    Xj = Xg[j, .]
                Zj = Zg[j, .]
                ej = eg[j, .]
    
	            fj = XpZ*invsym(ZpZ)*(Zj'*ej-(1/n)*Zpe) + (Xj'*Zj-(1/n)*XpZ)*invsym(ZpZ)*Zpe + XpZ*invsym(ZpZ)*((1/n)*ZpZ-Zj'*Zj)*invsym(ZpZ)*Zpe
			
			    Pi = Pi + fi*fj'
	        }
				
	        Mg = Mg + Pi
         
	    }
		 
        M = M + Mg

    }

    V = invsym(H) * M * invsym(H)
    st_matrix(Vname, V)
}

end

* mata function for conventional heteroskedasticity robust standard error

mata:

void conventional( string scalar depvar,   string scalar exog,    ///
                   string scalar cnames,   string scalar touse,   /// 
                   string scalar Vname)
{
    real vector    y, b, e, e2
    real matrix    X, Z, XpZ, ZpZ, Zpy, H, M, V 
    real scalar    n
	
    y = st_data(., depvar, touse)
    X = st_data(., cnames, touse)
    Z = st_data(., exog, touse)
    n = rows(X)
    
	X = X, J(n, 1, 1)
    Z = Z, J(n, 1, 1)
    
    XpZ = quadcross(X, Z)
    ZpZ = quadcross(Z, Z)
    Zpy = quadcross(Z, y)

    b = invsym(XpZ*invsym(ZpZ)*(XpZ'))*XpZ*invsym(ZpZ)*Zpy
    e = y - X * b
    e2 = e :^ 2

    H = XpZ*invsym(ZpZ)*(XpZ')
    M = quadcross(Z, e2, Z)

    V = invsym(H)*XpZ*invsym(ZpZ)*M*invsym(ZpZ)*(XpZ')*invsym(H)
    st_matrix(Vname, V)
}

end

* mata function for conventional cluster robust standard error

mata:

void ccluster( string scalar depvar,  string scalar exog,       ///
               string scalar cnames,  string scalar clustvar,   ///
			   string scalar touse,   string scalar Vname)
{
    real vector    y, b, e, id
    real matrix    X, Z, XpZ, ZpZ, Zpy, H, M, info, V 
    real scalar    n, k, nc
	
    y = st_data(., depvar, touse)
    X = st_data(., cnames, touse)
    Z = st_data(., exog, touse)
    n = rows(X)
    
	X = X, J(n, 1, 1)
    Z = Z, J(n, 1, 1)
    
    XpZ = quadcross(X, Z)
    ZpZ = quadcross(Z, Z)
    Zpy = quadcross(Z, y)

    b = invsym(XpZ*invsym(ZpZ)*(XpZ'))*XpZ*invsym(ZpZ)*Zpy
    e = y - X * b
	
    id = st_data(., clustvar, touse)
    info = panelsetup(id, 1)
    nc = rows(info)
	
	H = XpZ*invsym(ZpZ)*(XpZ')
	k = cols(Z)
    M = J(k, k, 0)

    for(i=1; i<=nc; i++) {
        zi = panelsubmatrix(Z, i, info)
        ei = panelsubmatrix(e, i, info)
	    M = M + zi'*(ei*ei')*zi
    }

    V = invsym(H)*XpZ*invsym(ZpZ)*M*invsym(ZpZ)*(XpZ')*invsym(H)
    st_matrix(Vname, V)
}

end
