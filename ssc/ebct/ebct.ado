*! version 0.6 04April2020 University of Potsdam, Stefan Tübbicke
*! email: stefan.tuebbicke@uni-potsdam.de

cap program drop ebct
program define ebct, rclass

version 13.0
syntax varlist [if] [in] , treatvar(varname) [basew(varname)] [samplew(varname)]

if "`varlist'"=="" di as error "Error: varlist needs to be specified"
if "`treatvar'"=="" di as error "Error: treatvar needs to be specified"

/*Obtain initial measures of covariate balance and mark estimation sample*/
tempvar r2_u F_u p_u sampleind baseweight sampleweight

if "`samplew'"==""{
qui gen `sampleweight'=1 `if' `in'
}

else qui gen `sampleweight'=`samplew'  `if' `in'

if "`basew'"==""{
qui gen `baseweight'=1 `if' `in'
}

else qui gen `baseweight'=`basew' `if' `in'



qui reg `treatvar' `varlist' `if' `in' [aw=`sampleweight']
scalar `r2_u'=e(r2)
scalar `F_u'=e(F)
scalar `p_u'=1-F(e(df_m),e(df_r),e(F))

qui gen `sampleind'=(e(sample)==1 & `baseweight'!=.)

/*remove colinear variables from varlist*/
_rmcoll `varlist' if `sampleind', forcedrop
local varlist "`r(varlist)'"

cap drop _weight

*estimate EBCT weights
di as text ""
di as text "Estimating balancing weights. This may take a while..."
di as text ""

mata: m_ebct("`treatvar'", "`varlist'", "`sampleind'", "`baseweight'", "`sampleweight'")

/*Obtain post-weighting balance statistics and print table*/

label var _weight "EBCT weights"

tempvar r2_w F_w p_w obs
qui reg `treatvar' `varlist' [aw=_weight]
scalar `r2_w'=e(r2)
scalar `F_w'=e(F)
scalar `p_w'=1-F(e(df_m),e(df_r),e(F))
scalar `obs'=e(N)

mat balance=(`r2_u',`F_u', `p_u' \ `r2_w',`F_w', `p_w')
mat colnames balance = R-squared F-statistic p-value
mat rownames balance = "before balancing" "after balancing"

/*print table*/
di as text ""
di as text "#######################################"
di as text "Summary statistics on balancing quality"
di as text "#######################################"

matlist balance, rowtitle("") border(rows)  twidth(16) format(%12.3f) nodotz title("Results from a (weighted) regression of the treatment variable on covariates X:")

return matrix balance=balance
return local cmdname="ebct"
return scalar N=`obs'

end


/*define mata functions*/
capture mata mata drop ebcteval()
capture mata mata drop m_ebct()

mata:

	/*define evaluator function*/
	void ebcteval(real scalar todo, real vector b, real scalar N, real matrix GT, real vector Q1, val, grad, hess)
		{   
		real vector  W, eGb
		real scalar meaneGb
	
		/*compute weights for given parameter vector b*/
		eGb=Q1:*exp(GT*b')
		sumeGb=sum(eGb)
	
		W=eGb/sumeGb

		/*compute objective function for given parameter vector b*/	
		val=-log(sumeGb)
	
		/*compute gradient for given parameter vector b*/
		grad=-cross(W,GT)
		}
		
void m_ebct(string scalar treatvar, string scalar varlist, string scalar sampleind, string scalar baseweight, string scalar sampleweight)
{

	/*Obtain matrices from Stata*/
	T=.
	st_view(T, ., tokens(treatvar), sampleind)

	X=.
	st_view(X, ., tokens(varlist), sampleind)
	
	Q1=.
	st_view(Q1, ., tokens(baseweight), sampleind)
	
	Q1=Q1/sum(Q1)
	
	Q2=.
	st_view(Q2, ., tokens(sampleweight), sampleind)
	
	Q2=Q2/sum(Q2)
	
	/*Save number of obs*/
	N=rows(T)
	
	/*Normalize T and X to mean zero*/
	T0=T-J(N,1,N*mean(Q2:*T))
	
	X0=X-cross(J(cols(X),N,1),diag(N*mean(Q2:*X)))

	/*Save (transposed) G Matrix*/
	GT=(T0,X0,diag(T0)*X0)

	/*Initialize optimization*/
	S  = optimize_init()

	/*Feed in scalars/matrices*/
	optimize_init_argument(S, 1, N)
	optimize_init_argument(S, 2, GT)
	optimize_init_argument(S, 3, Q1)

	/*Set ebcteval as relevant evaluator function*/
	optimize_init_evaluator(S, &ebcteval())

	/*Choose type GF1*/
	optimize_init_evaluatortype(S, "gf1")
	
	/*Choose optimization technique*/
	optimize_init_technique(S,"nr")
	
	/*Choose optimization technique*/
	optimize_init_singularHmethod(S, "hybrid")

	/*Start at b=0*/
	optimize_init_params(S, J(1, 2*cols(X)+1, 0))

	/*Run optimization and save parameter vector as b_opt*/
	b_opt = optimize(S)

	/*Generate weight vector with optimal parameters b_opt*/
	W=Q1:*exp(GT*b_opt')/sum(Q1:*exp(GT*b_opt'))

	/*Generate _weight variable in Stata*/
	(void) st_addvar("double", "_weight")
	
	/*Fill _weight variable with final weights*/
	st_store(., "_weight", sampleind, W)
}
end





