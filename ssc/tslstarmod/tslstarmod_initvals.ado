*! version 1.0.1
*! The Initial Values Finder 
*! for the Command tslstarmod
*! Diallo Ibrahima Amadou
*! All comments are welcome, 18Sep2019



capture program drop tslstarmod_initvals
program tslstarmod_initvals, eclass sortpreserve 
	version 15.1
	syntax varlist(ts) [if] [in], thresv(varname numeric ts)    
	marksample touse
	markout `touse' `thresv'
	gettoken lhs rhs : varlist
	mata: _mz_createlstariv("`lhs'", "`rhs'", "`touse'", "`thresv'")
end



mata:



function mzlstariniteval(transmorphic M, real rowvector b, real colvector lnf)
{
	real colvector y1, regime1, regime2, lngamma, cpar, lnsigma, gammap, sigma, theta, lagy  
	y1      = moptimize_util_depvar(M, 1)
	regime1 = moptimize_util_xb(M, b, 1)
	regime2 = moptimize_util_xb(M, b, 2)
	lngamma = moptimize_util_xb(M, b, 3)
	cpar    = moptimize_util_xb(M, b, 4)
	lnsigma = moptimize_util_xb(M, b, 5)
    gammap  = exp(lngamma)
    sigma   = exp(lnsigma)
    lagy    = moptimize_util_userinfo(M, 1)
	theta  	= (1:+exp(-1:*gammap:*(lagy :- cpar))):^(-1)
	lnf = ln(normalden(y1,regime1 :+ theta:*(regime2),sigma))	
}



void _mz_createlstariv( string scalar first, string scalar rest, string scalar touse, string scalar threshold)
{
	real matrix x0, copx0
	real colvector y0, threshbles, copy0, copthreshbles 
	string rowvector lvx   
	string scalar lvy, thresvar
	real scalar mesptol
	
	lvy = tokens(first); lvx = tokens(rest); thresvar = tokens(threshold);   
	st_view(y0,., st_tsrevar(lvy), touse); st_view(x0,., st_tsrevar(lvx), touse); st_view(threshbles,., st_tsrevar(thresvar), touse); 
    copy0 = y0
	copx0 = x0
	copthreshbles = threshbles
	mesptol = 0.005
	M = moptimize_init()
	moptimize_init_evaluator(M, &mzlstariniteval())
	moptimize_init_depvar(M, 1, copy0)
	moptimize_init_eq_indepvars(M, 1, copx0)
	moptimize_init_eq_indepvars(M, 2, copx0)
	moptimize_init_eq_indepvars(M, 3, "")
	moptimize_init_eq_indepvars(M, 4, "")
	moptimize_init_eq_indepvars(M, 5, "")
	moptimize_init_which(M, "max")
	moptimize_init_evaluatortype(M, "lf")
	moptimize_init_technique(M, "nm")
	smdelta = J(1,5,50*mesptol)
	moptimize_init_nmsimplexdeltas(M, smdelta)
	moptimize_init_userinfo(M, 1, copthreshbles)
	moptimize_init_eq_name(M, 1, "Regime1")
	moptimize_init_eq_name(M, 2, "Regime2")
	moptimize_init_eq_name(M, 3, "lngamma")
	moptimize_init_eq_name(M, 4, "cpar")
	moptimize_init_eq_name(M, 5, "lnsigma")
	moptimize(M)
	moptimize_result_post(M)
	
}



end


