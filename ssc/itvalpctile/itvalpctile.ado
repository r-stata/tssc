////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Beresteanu, A. & Sasaki, Y. (2020): Quantile Regression with
//            Interval Data. Econometric Reviews, forthcoming.
//
// Use it when you have interval-valued data (consisting of lower and upper 
// bounds) and want to compute set percentiles with their confidence sets.
////////////////////////////////////////////////////////////////////////////////
program define itvalpctile, rclass
    version 14.2
 
    syntax varlist(min=2 max=2 numeric) [if] [in] [,cover(real 0.95) pl(real 10) ph(real 90) np(real 9) conditional(varname numeric) location(real 999999)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
 	if "`conditional'" == "" {
		mata: estimate_setp("`depvar'", "`cnames'", `pl', `ph', `np', "`touse'", `cover') 
	}
	
	if "`conditional'" != "" {
		tempvar x
		gen `x' = `conditional'
		mata: estimate_conditional_setp("`depvar'", "`cnames'", "`x'", `pl', `ph', `np', "`touse'", `cover', `location') 
	}
end

		
	
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Kernel Function
void kernel(u, kout){
	kout = 1 :* ( -1 :< u ) :* ( u :< 1 )
}
//////////////////////////////////////////////////////////////////////////////// 
// Unconditional
void estimate_setp( string scalar yv,      string scalar xv,
					real scalar q_low, 	   real scalar q_high, 	   	real scalar q_num,
					string scalar touse,   real scalar cover) 
{
	printf("\n{hline 78}\n")
	printf("Executing:  Beresteanu, A. & Sasaki, Y. (2020): Quantile Regression with\n")
	printf("            Interval Data. Econometric Reviews, forthcoming.\n")
	printf("{hline 78}\n")
 
    yl     = st_data(., yv, touse)
    yh     = st_data(., xv, touse)
    n      = rows(yl)
	original_n = n
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high:/100 - q_low:/100) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low:/100
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate interval quantiles	
	lower = sort(yl,1)[trunc(n:*qlist)]
	upper = sort(yh,1)[trunc(n:*qlist)]
	
	////////////////////////////////////////////////////////////////////////////
	// Confidence Sets
	real matrix kout1, kout2
	conf_lower = lower
	conf_upper = upper
	h1 = 1.06 * variance(yl)^0.5 / n^0.2
	h2 = 1.06 * variance(yh)^0.5 / n^0.2
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		kernel( (yl :- lower[idx]) :/ h1, kout1 )
		kernel( (yh :- upper[idx]) :/ h2, kout2 )
		fa = sum( kout1 ) / (n * h1)
		fb = sum( kout2 ) / (n * h2)
		Fab = mean( yl :<= lower[idx] :& yh :<= upper[idx] )
		Sigma11 = qlist[idx] * (1-qlist[idx]) / fa^2
		Sigma12 = (Fab - qlist[idx]^2) / (fa * fb)
		Sigma22 = qlist[idx] * (1-qlist[idx]) / fb^2
		
		scale = invnormal(1 - (1 - cover) / 2)
		conf_lower[idx] = lower[idx] - scale * ( Sigma11 / n )^0.5
		conf_upper[idx] = upper[idx] + scale * ( Sigma22 / n )^0.5
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Number of observations:                                        n = %f\n", original_n)
	printf(  "{hline 78}\n")
	printf(  "Percent       [  Percentile Itervals  ]       [  %2.0f%% Confidence Sets  ]\n",100*cover)
	printf(  "{hline 71}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("    %3.0f       [%10.4f   %10.4f]       [%10.4f   %10.4f]\n",qlist[idx]*100,lower[idx],upper[idx],conf_lower[idx],conf_upper[idx])
	}
	printf(  "{hline 78}\n")
}
//////////////////////////////////////////////////////////////////////////////// 
// Conditional
void estimate_conditional_setp( string scalar yv,      string scalar xv,		string scalar xx,
								real scalar q_low, 	   real scalar q_high, 	   	real scalar q_num,
								string scalar touse,   real scalar cover,		real scalar location) 
{
	printf("\n{hline 78}\n")
	printf("Executing:  Beresteanu, A. & Sasaki, Y. (2020): Quantile Regression with\n")
	printf("            Interval Data. Econometric Reviews, Special Issue in Honor of\n")
	printf("            Cheng Hsiao, forthcoming.\n")
	printf("{hline 78}\n")
 
    yl     = st_data(., yv, touse)
    yh     = st_data(., xv, touse)
	x      = st_data(., xx, touse)
    n      = rows(yl)
	original_n = n
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high:/100 - q_low:/100) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low:/100
	
	////////////////////////////////////////////////////////////////////////////
	// Find local observations	
	if( location == 999999 ){
	    location = mean(x)
	}
	h = 1.06 * variance(x)^0.5 / n^0.2
	yl = select(yl, abs( x :- location ) :<= h)
	yh = select(yh, abs( x :- location ) :<= h)
    n      = rows(yl)
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate interval quantiles	
	lower = sort(yl,1)[trunc(n:*qlist)]
	upper = sort(yh,1)[trunc(n:*qlist)]
	
	////////////////////////////////////////////////////////////////////////////
	// Confidence Sets
	real matrix kout1, kout2
	conf_lower = lower
	conf_upper = upper
	h1 = 1.06 * variance(yl)^0.5 / n^0.2
	h2 = 1.06 * variance(yh)^0.5 / n^0.2
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		kernel( (yl :- lower[idx]) :/ h1, kout1 )
		kernel( (yh :- upper[idx]) :/ h2, kout2 )
		fa = sum( kout1 ) / (n * h1)
		fb = sum( kout2 ) / (n * h2)
		Fab = mean( yl :<= lower[idx] :& yh :<= upper[idx] )
		Sigma11 = qlist[idx] * (1-qlist[idx]) / fa^2
		Sigma12 = (Fab - qlist[idx]^2) / (fa * fb)
		Sigma22 = qlist[idx] * (1-qlist[idx]) / fb^2
		
		scale = invnormal(1 - (1 - cover) / 2)
		conf_lower[idx] = lower[idx] - scale * ( Sigma11 / n )^0.5
		conf_upper[idx] = upper[idx] + scale * ( Sigma22 / n )^0.5
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Number of observations:                                        n = %f\n", original_n)
	printf(  "Localition of the conditioning variable:                       x = %f\n", location)
	printf(  "{hline 78}\n")
	printf(  "Percent       [  Percentile Itervals  ]       [  %2.0f%% Confidence Sets  ]\n",100*cover)
	printf(  "{hline 71}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("    %3.0f       [%10.4f   %10.4f]       [%10.4f   %10.4f]\n",qlist[idx]*100,lower[idx],upper[idx],conf_lower[idx],conf_upper[idx])
	}
	printf(  "{hline 78}\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
