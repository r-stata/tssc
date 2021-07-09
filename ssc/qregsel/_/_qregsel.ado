*! version 1.2 09Sept2020
* Authors: Ercio Munoz & Mariel Siravegna 

/* Wrap file to implement copula-based sample selection model in quantile 
regression as suggested by Arellano and Bonhomme (2017). */

* qregselection wage educ age, quantile(.1 .5 .9) select(married children educ age) 
* mat grid = 1,1,1,1
* _qregsel wage educ  age, select(married children educ age) quantile(.1 .5 .9) copula(frank) rho(-7.6) egrid(grid) kendall(-.58) spearman(-.79)

cap program drop _qregsel
program define _qregsel, eclass sortpreserve
    version 16.0

    syntax varlist(numeric) [if] [in], SELect(string) quantile(string) ///
	[ copula(string) NOCONStant rho(string) egrid(string) ///
	kendall(string) spearman(string) rescale ]
    
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'

    fvexpand `indepvars' 
    local cnames `r(varlist)'
		
	tokenize `select', parse("=")
	if "`2'" != "=" {
		local x_s `select'
		tempvar y_s
		qui gen `y_s' = (`depvar'!=.)
	}
	else {
		local y_s `1'
		local x_s `3'
	}		
	capture unab x_s : `x_s'
	
	if ("`noconstant'"!="") local _constant , noconstant
	
	
********************************************************************************	
** Marking the sample to use (selected observations)
********************************************************************************	
	marksample touse
	markout `touse' `y_s' `x_s'
	tempvar touse1
	mark `touse1' if `y_s'==1
	markout `touse1' `depvar' `indepvars'
	qui replace `touse' = 0 if `touse1'==0 & `y_s'==1 
	
	
********************************************************************************
** Generate the propensity score and the instrument	
********************************************************************************	
	tempname pZ b N rank df_r it betas_taus grid
	tempvar copula_cdf
	mat `grid' = `egrid'
	qui: probit `y_s' `x_s'
	qui: predict `pZ'


********************************************************************************	
** Rescale the variables
********************************************************************************
	if "`rescale'"!="" {
	preserve
	foreach lname of local cnames {
		qui: sum `lname' if `touse'
		qui: replace `lname' = (`lname'-r(mean))/r(sd) if `touse'
		qui: replace `lname' = . if `touse'==0
	}
	}
	
	
********************************************************************************	
** Checking errors in the quantiles requested
********************************************************************************
tokenize `quantile'
local orig `1'
macro shift
if "`orig'" == "" {
	di in red "option quantile() required"
	exit 198
}
capture confirm number `orig'
if _rc {
	di "`orig' not a number"
	exit 198
}
if `orig' >= 1 {
	local orig = `orig'/100
}
if `orig'<=0 | `orig' >=1 {
	local orig = 100*`orig'
	di "`orig' out of range"
	exit 198
}
local quants = `orig'

while "`1'" != "" {
local orig `1'
macro shift
if "`orig'" == "" {
	di in red "option quantile() required"
	exit 198
}
capture confirm number `orig'
if _rc {
	di "`orig' not a number"
	exit 198
}
if `orig' >= 1 {
	local orig = `orig'/100
}
if  `orig' >=1 {
	local orig = 100*`orig'
	di "`orig' out of range"
	exit 198
}
if `orig'<=0 {
	di "`orig' out of range"
	exit 198
}
local quants = "`quants' `orig'"
}


********************************************************************************	
** Estimate rotated quantile regression using the selected rho
********************************************************************************
local count: word count `indepvars' 
if "`noconstant'" == "" {
	mat `betas_taus' = J(`count'+1,1,.)
}
else {
	mat `betas_taus' = J(`count',1,.)
}
foreach tau of local quants {

** Obtain copula
qui:	mata: copulafn("`pZ'",`rho',`tau',"`touse'","`copula_cdf'","`copula'")

** Rotated quantile regression
qui:	mata: mywork("`depvar'", "`cnames'", "`touse'", "`noconstant'", ///
	"`b'", "`N'", "`rank'", "`df_r'","`it'","`copula_cdf'")
qui: cap drop `copula_cdf'

local qtau = 100*`tau'
mat colnames `b' = "q`qtau'"
mat `betas_taus' = `betas_taus',`b'
}

mat `betas_taus' = `betas_taus'[1...,2...]
    if "`noconstant'" == "" {
    	local cnames `cnames' _cons
    }
matrix rownames `betas_taus' = `cnames'	


********************************************************************************	
** Rescale the variables
********************************************************************************
	if "`rescale'"!="" {
	    local rescale = "rescaled"
	restore
	}
	else {
	    local rescale = "non-rescaled"
	}

	
********************************************************************************	
** Generating the output
********************************************************************************	
	dis " "
	dis in green "Quantile selection model" ///
		_column (50) "Number of obs" _column(69) "=" _column(71) %8.0f in yellow `N'

    ereturn post , esample(`touse') buildfvinfo
	ereturn matrix grid    = `grid'
    ereturn matrix coefs   = `betas_taus'
    ereturn scalar N       = `N'
	ereturn scalar rank    = `rank'
    ereturn scalar df_r    = `df_r'
    ereturn scalar rho     = `rho'
	ereturn scalar kendall  = `kendall'
	ereturn scalar spearman = `spearman'
	ereturn local title   "Quantile selection model"
	ereturn local rescale "`rescale'"
	ereturn local predict "qregsel_p"
    ereturn local cmd     "qregsel"
	ereturn local select_eq "`select'"	
	ereturn local outcome_eq "`depvar' `indepvars'"
	ereturn local cmdline "qregsel `depvar' `indepvars', select(`select')"
	ereturn local indepvars "`cnames'"
	ereturn local depvar  "`depvar'"
	ereturn local copula "`copula'"

    ereturn display
	matlist e(coefs)
	
end

********************************************************************************	
** Auxiliary functions needed for the estimation
********************************************************************************
mata:

void copulafn( string scalar pscore, numeric vector rho,
			   numeric vector tau,	 string scalar touse,   
			   string scalar cdf,    string scalar name) 
{

    real matrix pZ1, G, vs, v1

    pZ1  = st_data(., pscore, touse)
	
	if (name=="gaussian") {
	vs = J(rows(pZ1),1,invnormal(tau))
	v1 = invnormal(pZ1)
	st_view(G, ., st_addvar("float", cdf),touse)
	G[.,.] = binormal(vs,v1,rho) :/ pZ1
	}
	else {
	st_view(G, ., st_addvar("float", cdf),touse)
	G[.,.] = -ln(1:+(exp(-rho*tau):-1):*(exp(-rho:*pZ1):-1):/(exp(-rho)-1)):/(rho:*pZ1)
	}
		
}

void mywork( string scalar depvar,  	string scalar indepvars, 
             string scalar touse,   	string scalar constant,  
			 string scalar bname,       string scalar nname,   
			 string scalar rname,       string scalar dfrname, 
			 string scalar itname, 		string scalar cdf) 
{
    real vector y, p
    real matrix X, u, a, b, A, x
    real scalar m, n, k, it

    y    = st_data(., depvar, touse)
    X    = st_data(., indepvars, touse)
 	p    = st_data(., cdf, touse) 
	
	M    = rows(X)
	N    = cols(X)
	
    if (constant == "") {
    X    = X,J(M,1,1)
    }
	k    = cols(X) 
	
	u    = J(M, 1, 1)
	a    = (1:-p):*u
	it=0
	  
	A = X'
	c = -y'
	b = X'*a
	x = a 
  
	beta = 0.9995
	small = 1e-5
	max_it = 50
	m = rows(A)
	n = cols(A)

// Generate initial feasible point 
	s = u - x  
	y = svsolve(A',c')'
	r = c - y * A
	r = mm_cond(r:==0,r:+0.001,r)  
	z = mm_cond(r:>0,r,0)
	w = z - r
	gap = c * x - y * b + w * u

// Start iterations
	it = 0
while (gap > small & it < max_it) {
    it++

// Compute affine step
    q = 1 :/ (z' :/ x + w' :/ s)
    r = z - w
    Q = SPMATbandedmake(diag(sqrt(q)),0,0)
    AQ = SPMATbandedmultfull(Q,0,0,A')'
	rhs = SPMATbandedmultfull(Q,0,0,r')
    dy = (svsolve(AQ',rhs))'
    dx = q :* (dy * A - r)'
    ds = -dx
    dz = -z :* (1 :+ dx :/ x)'
    dw = -w :* (1 :+ ds :/ s)'

// Compute maximum allowable step lengths
    fx = mm_cond(dx:<0,-x:/dx,1e20 :+ 0 :* x)
    fs = mm_cond(ds:<0,-s:/ds,1e20 :+ 0 :* s)
    fw = mm_cond(dw:<0,-w:/dw,1e20 :+ 0 :* w)
    fz = mm_cond(dz:<0,-z:/dz,1e20 :+ 0 :* z)
    fp = mm_cond(fx:<fs,fx,fs) 
	fd = mm_cond(fw:<fz,fw,fz)
	fp = mm_cond(min(beta * fp):<1,min(beta * fp),1) 
	fd = mm_cond(min(beta * fd):<1,min(beta * fd),1) 
	
if (mm_cond(fp:<fd,fp,fd) < 1) {
    
// Update mu
      mu = z * x + w * s
      g = (z + fd * dz) * (x + fp * dx) + (w + fd * dw) * (s + fp * ds)
      mu = mu * (g / mu) ^3 / ( 2 * n)

// Compute modified step
      dxdz = dx :* dz'
      dsdw = ds :* dw'
      xinv = 1 :/ x
      sinv = 1 :/ s
      xi = mu * (xinv - sinv)
	  rhs = rhs + SPMATbandedmultfull(Q,0,0,( dxdz - dsdw -xi ))
	  dy = (svsolve(AQ',rhs))'
      dx = q :* (A' * dy' + xi - r' -dxdz + dsdw)
      ds = -dx
      dz = mu * xinv' - z - xinv' :* z :* dx' - dxdz'
      dw = mu * sinv' - w - sinv' :* w :* ds' - dsdw'

// Compute maximum allowable step lengths
      fx = mm_cond(dx:<0,-x:/dx,1e20 :+ 0 :* x)
      fs = mm_cond(ds:<0,-s:/ds,1e20 :+ 0 :* s)
      fw = mm_cond(dw:<0,-w:/dw,1e20 :+ 0 :* w)
      fz = mm_cond(dz:<0,-z:/dz,1e20 :+ 0 :* z)
	  fp = mm_cond(fx:<fs,fx,fs) 
	  fd = mm_cond(fw:<fz,fw,fz)
	  fp = mm_cond(min(beta * fp):<1,min(beta * fp),1) 
	  fd = mm_cond(min(beta * fd):<1,min(beta * fd),1) 
}

// Take the step
    x = x + fp * dx
    s = s + fp * ds
    y = y + fd * dy
    w = w + fd * dw
    z = z + fd * dz
    gap = c * x - y * b + w * u
}
	
    st_matrix(bname, -y')
    st_numscalar(itname, it)
    st_numscalar(nname, M)
    st_numscalar(rname, k)
    st_numscalar(dfrname, M-k)
	
}

end
