/* 
Estimation of Nonparametric instrumental variable (NPIV) models with shape restrictions

Version 1.3.0 3rd Aug 2018

This program estimates the nonparametric function g(x) and a vector of coefficients of a linear index γ in

Y = g(X) + Z'γ + e with E(e|W)=0

where Y is a scalar dependent variable ("depvar"), 
X is a scalar endogenous variable ("expvar"), 
Z is a vector of exogeneous covariats ("exovar"), and 
W is a scalar instrument ("inst").

Syntax:
npiv depvar expvar inst [exovar] [if] [in] [, power_exp(#) power_inst(#) num_exp(#) num_inst(#) pctile(#) polynomial increasing decreasing] 

where power_exp is the power of basis functions for x (defalut = 2),
power_inst is the power of basis functions for z (defalut = 3),
num_exp is the number of knots for x (defalut = 2),
num_inst is the number of knots for z (defalut = 3), 
pctile (default = 5) indicates the domain over which the NPIV sieve estimator is computed.
Given pctile(a), a to (1-a) percentiles of X are used in generating spline basis for X.
polonomial option gives the basis functions for power polynomials(default is bslpline).

# shape restrictions (bspline is used - power of bslpine for "expvar" is fixed to 2.
increasing option imposes a increasing shape restriction on function g(X).
decreasing option imposes a decreasing shape restriction on function g(X).

When polynomial is used, shape restrictions cannot be imposed.
(error message will come out)

Users can freely modify the power and the type of basis functions and the number of knots
when shape restrictions are not imposed.

If unspecified, the command runs on a default setting.

The bases used in the current regression are provided in Stata variable space.

bases for expvar : exv
bases for inst   : ins
bases for grid   : grd

If there exist previous results, those bases are renamed with suffix "_old".
*/

capture program drop npiv
program define npiv, eclass
		version 11
		
		// initializations
		syntax varlist(numeric fv) [if] [in] [, power_exp(integer 2) power_inst(integer 3) num_exp(integer 2) num_inst(integer 3) pctile(integer 5) POLYnomial INCreasing DECreasing]
		marksample touse
		
		// check whether 'bspline' command is installed
		capture which bspline
		local rc = _rc
		if (`rc') {
		display as error "{bf:npiv} requires bf:bspline}"
		exit 198
		}
		
		// generate temporary names to avoid any crash in Stata spaces
		tempvar b Y Yhat xlpct xupct 
		tempname exv_old ins_old grd_old
		
		// eliminate old (from the regression before the previous one) NPIV regression results if there is any
		capture drop exv_old*
		capture drop ins_old*
		capture drop grd_old*
		capture drop npest_old 
		capture drop grid_old
		
		// store previous bases to stata matrices
		capture mata : oldres_fn("exv*", "ins*", "grd*", "`exv_old'", "`ins_old'", "`grd_old'")
		
		// rename the previous estimation results
		capture rename npest npest_old 
		capture rename grid grid_old
		
		// drop the previous bases to run a new regression
		capture drop exv*
		capture drop ins*
		capture drop grd*
		
		
		// local macro assignments
		gettoken depvar varlist : varlist
		gettoken expvar varlist : varlist
		gettoken inst exovar : varlist
		gettoken exo1 : exovar
		
		local exovar `exovar'
		local powerx `power_exp'
		local powerz `power_inst'
		local numx = `num_exp' + 1
		local numz = `num_inst' + 1
		
		if "`polynomial'" == "polynomial" {
		local num_exp  = `power_exp' 
		local num_inst = `power_inst' 
		local numx     = `num_exp' + 1
		local numz     = `num_inst' + 1
		}
				
		local upctile = 100 - `pctile'
				
		quietly gen `Y' = `depvar' if `touse'
		
		quietly summarize `Y' if `touse'
		local N = r(N)
		
		//equidistance nodes (knots) are generated for x 
		quietly summarize `expvar'
		local xmin = r(min)
		local xmax = r(max)
		local x_distance = (`xmax' - `xmin')/(`numx' - 1 )
		local qtile = `pctile'/100
		local 1qtile = 1 - `pctile'/100
		
		display "Domain over which the estimator is computed: `qtile'-quantile of X to `1qtile'-quantile of X"
		
		//equidistance nodes (knots) are generated for z
		quietly summarize `inst'
		local zmin = r(min)
		local zmax = r(max)
		local z_distance = (`zmax' - `zmin')/(`numz' - 1)
        
		//fine grid for fitted value of g(X)
		quietly egen `xlpct' = pctile(`expvar'), p(`pctile')
		quietly egen `xupct' = pctile(`expvar'), p(`upctile')
		local gmin = `xlpct'
		local gmax = `xupct'
		mata : grid_fn(`gmin', `gmax', rows(st_data(., "`depvar'")))
		
		// generate bases for X and Z
	    // If the option "polynomial" is not typed, bspline is used.
		if "`polynomial'" == "" {
		local basis "B-spline"
		// check whether increasing option is used        
		if "`increasing'" == "increasing" {
		local shape "increasing"
		local power_exp = 2
		display "Basis for X: B-spline of order `power_exp'"
		display "Basis for Z: B-spline of order `power_inst'"
		display "Number of equally spaced knots for X: `num_exp'"
		display "Number of equally spaced knots for Z: `num_inst'"
		display "Shape restriction (increasing) is imposed"
				
		quietly bspline, xvar(grid) gen(grd) knots(`xmin'(`x_distance')`xmax') power(`power_exp') 
        quietly bspline if `touse', xvar(`expvar') gen(exv) knots(`xmin'(`x_distance')`xmax') power(`power_exp')
		quietly bspline if `touse', xvar(`inst') gen(ins) knots(`zmin'(`z_distance')`zmax') power(`powerz')
				
		mata : npiv_optimize("`Y'", "exv*", "ins*", "`b'", "`exo1'", "`exovar'", "`touse'", "`Yhat'")
		}
		
		// check whether decreasing option is used
		else if "`decreasing'" == "decreasing" {
		local shape "decreasing"
		local power_exp = 2
		display "Basis for X: B-spline of order `power_exp'"
		display "Basis for Z: B-spline of order `power_inst'"
		display "Number of equally spaced knots for X: `num_exp'"
		display "Number of equally spaced knots for Z: `num_inst'"
		display "Shape restriction (decreasing) is imposed"
		local power_exp = 2
		quietly bspline, xvar(grid) gen(grd) knots(`xmin'(`x_distance')`xmax') power(`power_exp') 
        quietly bspline if `touse', xvar(`expvar') gen(exv) knots(`xmin'(`x_distance')`xmax') power(`power_exp')
		quietly bspline if `touse', xvar(`inst') gen(ins) knots(`zmin'(`z_distance')`zmax') power(`powerz')
		
		mata : npiv_optimize_dec("`Y'", "exv*", "ins*", "`b'", "`exo1'", "`exovar'", "`touse'", "`Yhat'")
		}
		// procedure without shape restrictions
		else {
		local shape "no shape restriction"
		display "Basis for X: B-spline of order `power_exp'"
		display "Basis for Z: B-spline of order `power_inst'"
		display "Number of equally spaced knots for X: `num_exp'"
		display "Number of equally spaced knots for Z: `num_inst'"
		display "no shape restriction"
		quietly bspline, xvar(grid) gen(grd) knots(`xmin'(`x_distance')`xmax') power(`powerx') 
        quietly bspline if `touse', xvar(`expvar') gen(exv) knots(`xmin'(`x_distance')`xmax') power(`powerx')
		quietly bspline if `touse', xvar(`inst') gen(ins) knots(`zmin'(`z_distance')`zmax') power(`powerz')
		
		mata : npiv_estimation("`Y'", "exv*", "ins*", "`b'", "`exo1'", "`exovar'", "`touse'", "`Yhat'")
		}
		}
		
		// If polyspline is typed
        else {
		display "Basis for X: polynomial spline of order `power_exp'"
		display "Basis for Z: polynomial spline of order `power_inst'"
		display "no shape restriction"
		// check whether increasing option is used
		if("`increasing'" == "increasing"){
			display in red "shape restriction (increasing) not allowed"	
			error 498
		}
		
		// check whether decreasing option is used
		else if("`decreasing'" == "decreasing"){
			display in red "shape restriction (decreasing) not allowed"	
			error 498
		}
		
		else {
		local basis "polynomial"
		local shape "no shape restriction"
		quietly polyspline grid, gen(grd) refpts(`xmin'(`x_distance')`xmax') power(`powerx') 
        quietly polyspline `expvar' if `touse', gen(exv) refpts(`xmin'(`x_distance')`xmax') power(`powerx') 
		quietly polyspline `inst' if `touse', gen(ins) refpts(`zmin'(`z_distance')`zmax') power(`powerz') 

		mata : npiv_estimation("`Y'", "exv*", "ins*", "`b'", "`exo1'", "`exovar'", "`touse'", "`Yhat'")
		}
		}
		
		// convert the Stata matrices to Stata variable
		svmat `Yhat', name(npest)  // NPIV estimate on grid
		capture svmat `exv_old', name(exv_old) // old bases for expvar
		capture svmat `ins_old', name(ins_old) // old bases for inst
		capture svmat `grd_old', name(grd_old) // old bases for grid
		
		ereturn post `b'
		ereturn scalar N          = `N'
		ereturn scalar powerexp   = `power_exp'
		ereturn scalar powerinst  = `power_inst'
		ereturn scalar knotexp    = `num_exp'
		ereturn scalar knotinst   = `num_inst'
		ereturn scalar pct        = `pctile'
		ereturn scalar gmin       = `gmin'
		ereturn scalar gmax       = `gmax'
		ereturn scalar xmin       = `xmin'
		ereturn scalar xmax       = `xmax'
		ereturn scalar wmin       = `zmin'
		ereturn scalar wmax       = `zmax'
		
		ereturn local cmd "npiv" 
		ereturn local title "Nonparametric IV regression" 
		ereturn local depvar "`depvar'" 
		ereturn local expvar "`expvar'" 
		ereturn local inst "`inst'" 
		ereturn local exovar "`exovar'" 
		ereturn local basis "`basis'"
		ereturn local shape "`shape'" 
		
		rename npest1 npest
		
		label variable npest "NPIV fitted values"
		label variable grid  "Fine grid of expvar"
		capture label variable exv1 "Spline Bases evaluated at expvar"
		capture label variable ins1 "Spline Bases evaluated at inst"
		capture label variable grd1 "Spline Bases evaluated at grid points"
		capture label variable npest_old "Old NPIV fitted values"
		capture label variable grid_old  "Old Find grid of expvar"
		capture label variable exv_old1 "Old Spline Bases evaluated at expvar"
		capture label variable ins_old1 "Old Spline Bases evaluated at inst"
		capture label variable grd_old1 "Old Spline Bases evaluated at grid points"
				
end


// Define a Mata function computing NPIV estimates without shape restriction
mata:
void npiv_estimation(string scalar vname, string scalar basisname1, 
                     string scalar basisname2, string scalar bname,
					 string scalar ename1, string scalar ename2, string scalar touse,
					 string scalar estname1)

{
    real vector Y, b, Yhat
	real matrix P0, Q0, P, Q, W, MQ 
	// load bases from Stata variable space
	P0 		= st_data(., basisname1, 0)
	Q0 		= st_data(., basisname2, 0)
	
	if (_st_varindex(ename1) == .) P = P0;;
	if (_st_varindex(ename1) == .) Q = Q0;;
	if (_st_varindex(ename1) != .) st_view(W=., ., ename2, touse);;
	if (_st_varindex(ename1) != .) P = (P0, W);;
	if (_st_varindex(ename1) != .) Q = (Q0, tensor(Q0, W));;
		
	Y 		= st_data(., vname, 0)
	
	// compute the estimate by the closed form solution
	MQ 		= Q*invsym(Q'*Q)*Q'
	b  		= invsym(P'*MQ*P)*P'*MQ*Y
	GP      = st_data(., "grd*",0) // spline bases on fine grid points
	
	s		= cols(P0)
	bX		= b[1..s]
	Yhat 	= GP*bX //fitted value on fine grid
			
	// store the mata results into the Stata matrix space
	// st_matrix("bb", b)
	st_matrix(bname, b')
	st_matrix(estname1, Yhat)           
	}

// Define a Mata function computing NPIV estimates with increasing shape restriction
void npiv_optimize(string scalar vname, string scalar basisname1, 
                   string scalar basisname2, string scalar bname, 
				   string scalar ename1, string scalar ename2, string scalar touse,				   
				   string scalar estname1)
					 
{    	real vector Y, beta, Yhat
		real matrix P, Q
		real scalar n

		P0 		= st_data(., basisname1, 0)
		Q0 		= st_data(., basisname2, 0)
	
		if (_st_varindex(ename1) == .) P = P0;;
		if (_st_varindex(ename1) == .) Q = Q0;;
		if (_st_varindex(ename1) != .) st_view(W=., ., ename2, touse);;
		if (_st_varindex(ename1) != .) P = (P0, W);;
		if (_st_varindex(ename1) != .) Q = (Q0, tensor(Q0, W));;
				
		Y 		= st_data(., vname, 0)
 		n       = cols(P)
		np0     = cols(P0)
		
	    // optimisation routine for the minimisation problem
    	S 		= optimize_init()
		ival    = J(1, n, 1)

		optimize_init_argument(S, 1, P)
		optimize_init_argument(S, 2, P0)
		optimize_init_argument(S, 3, Q)
		optimize_init_argument(S, 4, Y)
        optimize_init_evaluator(S, &objfn())
		optimize_init_evaluatortype(S, "d2")
		optimize_init_params(S, ival)
		optimize_init_technique(S, "nr")
        optimize_init_which(S, "min")
		optimize_init_conv_ptol(S, 1e-5)
		optimize_init_conv_vtol(S, 1e-5)
		optimize_init_conv_ignorenrtol(S, "off")
		temp       = optimize(S) // parameter estimated by optimisation
     	beta       = J(1, n, 0)
		prebeta    = J(1, n, 0)
		beta[1]    = temp[1]
		prebeta[1] = temp[1]
		
		for (i = 2; i<=np0; i++) {
		   prebeta[i] = (temp[i])^2
		   beta[i] = sum(prebeta)
		   }
		
		for (i = (np0 + 1); i<=n; i++) {
		   beta[i] = temp[i]
		   }
		   
		bX		= beta[1..np0]
		GP      = st_data(., "grd*", 0) // spline bases on fine grid points
		Yhat 	= GP*bX' //fitted value on fine grid
		
		// store the mata results into the Stata matrix space
		st_matrix(bname, beta)
		st_matrix(estname1, Yhat)
}

// Define a Mata function computing NPIV estimates with decreasing shape restriction
void npiv_optimize_dec(string scalar vname, string scalar basisname1, 
                       string scalar basisname2, string scalar bname,
					   string scalar ename1, string scalar ename2, string scalar touse,
				       string scalar estname1)
					 
{    	real vector Y, beta, Yhat
		real matrix P, Q
		real scalar n

        P0 		= st_data(., basisname1, 0)
		Q0 		= st_data(., basisname2, 0)
	
		if (_st_varindex(ename1) == .) P = P0;;
		if (_st_varindex(ename1) == .) Q = Q0;;
		if (_st_varindex(ename1) != .) st_view(W=., ., ename2, touse);;
		if (_st_varindex(ename1) != .) P = (P0, W);;
		if (_st_varindex(ename1) != .) Q = (Q0, tensor(Q0, W));;
		
		Y 		= st_data(., vname, 0)
 		n       = cols(P)
		np0     = cols(P0)
		
	    // optimisation routine for the minimisation problem
    	S 		= optimize_init()
		ival    = J(1, n, 1)

		optimize_init_argument(S, 1, P)
		optimize_init_argument(S, 2, P0)
		optimize_init_argument(S, 3, Q)
		optimize_init_argument(S, 4, Y)
        optimize_init_evaluator(S, &objfn_dec())
		optimize_init_evaluatortype(S, "d2")
        optimize_init_params(S, ival)
		optimize_init_technique(S, "nr")
        optimize_init_which(S, "min")
		optimize_init_conv_ptol(S, 1e-5)
		optimize_init_conv_vtol(S, 1e-5)
		optimize_init_conv_ignorenrtol(S, "off")
		temp       = optimize(S) // parameter estimated by optimisation
     	beta       = J(1, n, 0)
		prebeta    = J(1, n, 0)
		beta[1]    = temp[1]
		prebeta[1] = temp[1]
		
		for (i = 2; i<=np0; i++) {
		   prebeta[i] = -(temp[i])^2
		   beta[i]    = sum(prebeta)
		   }
		   
		for (i = (np0 + 1); i<=n; i++) {
		   beta[i] = temp[i]
		}   
		   
		bX		= beta[1..np0]
		GP      = st_data(., "grd*", 0) // spline bases on fine grid points
		Yhat 	= GP*bX' //fitted value on fine grid
				
		// store the mata results into the Stata matrix space
		st_matrix(bname, beta)
		st_matrix(estname1, Yhat)
	}

// objective function for minimisation with increasing OPTION
void objfn(real scalar todo, real vector B, real matrix P, real matrix P0,  
           real matrix Q, real vector Y, val, grad, hess) 
		   
{		real matrix MQ 
		MQ      = Q*invsym(Q'*Q)*Q'
		n       = cols(P)
		np0     = cols(P0)
		n0      = n - np0
		bb      = J(1, n, 0)
		prebb   = J(1, n, 0)
		prebb[1]= B[1]
		bb[1]   = B[1]
		
		for (i = 2; i<=np0; i++) {
		   prebb[i] = (B:^2)[i]
		   bb[i]    = sum(prebb)
		   }
		for (i = (np0 + 1); i<=n; i++) {
		   bb[i] = B[i]
		   }
		   
		Gr1 = J(np0, np0, 1)
		for (i = 2; i<=np0; i++) {
		   Gr1[i,.] = 2*Gr1[i,.]*B[i]
		   }
		Gr1 = uppertriangle(Gr1)
		Gr2 = J(np0, n0, 0)
		Gr3 = J(n0, np0, 0)
		Gr4 = I(n0)
		if (np0 != n) Gr  = (Gr1, Gr2 \ Gr3, Gr4)   
		if (np0 == n) Gr  = Gr1
		
		H1 = J(n, n, 0)
		H1[2..np0, 2..np0] = uppertriangle(J((np0-1), (np0-1), 2))
		He1 = -2*diag(H1*(P'*MQ*Y))
		
		
		H21 = Gr
		H21[2..np0, 2..np0] = uppertriangle(J((np0-1), (np0-1), 2))
		H22 = 2*(H21*P'*MQ*P)
		
		He2 = J(n, n, 0)
		He2[1,.] = H22[1,.]*Gr'
		
		for (i = 2; i<=np0; i++) {
		   temp1 = Gr'*B[i]
		   temp1[.,i] = bb' + (Gr')[., i]*B[i]
		   He2[i,.] = H22[i,.]*temp1
		   }
		
		for (i = (np0 + 1); i<=n; i++) {
		   He2[i,.] = H22[i,.]*Gr'
		   }
								
		val = (Y - P*bb')'*MQ*(Y - P*bb')
		grad = -2*(Gr*P'*MQ*(Y - P*bb'))'
		hess = (He1+He2)
}

// objective function for minimisation with decreasing OPTION
void objfn_dec(real scalar todo, real vector B, real matrix P, real matrix P0,
               real matrix Q, real vector Y, val, grad, hess) 
		   
{		real matrix MQ 
		MQ      = Q*invsym(Q'*Q)*Q'
		n       = cols(P)
		np0     = cols(P0)
		n0      = n - np0
		bb      = J(1, n, 0)
		prebb   = J(1, n, 0)
		prebb[1]= B[1]
		bb[1]   = B[1]
		for (i = 2; i<=np0; i++) {
		   prebb[i] = -(B:^2)[i]
		   bb[i]    = sum(prebb)
		   }
		for (i = (np0 +1); i<=n; i++) {
		   bb[i] = B[i]
		   }
		   
		Gr1 = J(np0, np0, 1)
		for (i = 2; i<=np0; i++) {
		   Gr1[i,.] = -2*Gr1[i,.]*B[i]
		   }
		Gr1 = uppertriangle(Gr1)
		Gr2 = J(np0, n0, 0)
		Gr3 = J(n0, np0, 0)
		Gr4 = I(n0)
		if (np0 != n) Gr  = (Gr1, Gr2 \ Gr3, Gr4)   
		if (np0 == n) Gr  = Gr1
		   
		H1 = J(n, n, 0)
		H1[2..np0, 2..np0] = uppertriangle(J((np0-1), (np0-1), -2))
		He1 = -2*diag(H1*(P'*MQ*Y))
		
		
		H21 = Gr
		H21[2..np0, 2..np0] = uppertriangle(J((np0-1), (np0-1), -2))
		H22 = 2*(H21*P'*MQ*P)
		
		He2 = J(n, n, 0)
		He2[1,.] = H22[1,.]*Gr'
		
		for (i = 2; i<=np0; i++) {
		   temp1 = Gr'*B[i]
		   temp1[.,i] = bb' + (Gr')[., i]*B[i]
		   He2[i,.] = H22[i,.]*temp1
		   }
		
		for (i = (np0 + 1); i<=n; i++) {
		   He2[i,.] = H22[i,.]*Gr'
		   }
								
		val = (Y - P*bb')'*MQ*(Y - P*bb')
		grad = -2*(Gr*P'*MQ*(Y - P*bb'))'
		hess = (He1+He2)
}


// produce fine griod for fitted values
 void grid_fn(real scalar gmin, real scalar gmax, real vector var) 
 
 {
 grid = rangen(gmin, gmax, var)
 st_addvar("float", "grid")
 st_store(., "grid", grid)
 }
 
 // store old bases to Stata matrices
 void oldres_fn(string scalar basisname1, string scalar basisname2, string scalar basisname3,
 string scalar matname1, string scalar matname2, string scalar matname3) 
 
 {
 exv = st_data(., basisname1, 0)	
 ins = st_data(., basisname2, 0)	
 grd = st_data(., basisname3, 0)	
 
 st_matrix(matname1, exv)
 st_matrix(matname2, ins)
 st_matrix(matname3, grd)
 }
 
 
 // function for tensor product
 real matrix tensor(real matrix Q0, real matrix W)
 
 {
 n   = cols(Q0)
 QW1 = Q0[,1]:*W 
 for (i = 1; i<=n; i++) {
		   QW  = Q0[,i]:*W
		   QW1 = (QW1, QW)
		   }
 
 return(QW1)
 }
 
 end
