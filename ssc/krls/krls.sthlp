{smcl}
{* *! version 1.0 09sep2013}{...}

{cmd:help krls}
{hline}

{title:Title}

{p2colset 5 15 22 2}{...}
{p2col :{hi:krls} {hline 2}}Kernel-based Regularized Least Squares {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 18 2}
{cmdab:krls} [{it:{help varname:depvar}}] {it:{help varlist:covar}}
{ifin}
[{cmd:,}
{it:options}]


{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt deriv(string)}}save derivatives in current dataset with the specified prefix{p_end}
{synopt:{opt sderiv(filename)}}save derivatives in a named dataset{p_end}
{synopt:{opt graph}}generate histograms of the derivatives{p_end}
{synopt:{opt vcov}}save fitted variance-covariance matrix to memory{p_end}
{synopt:{opt svcov(filename)}}save fitted variance-covariance matrix in a named dataset{p_end}
{synopt:{opt keep(filename)}}saves the output table in a named dataset{p_end}

{syntab:Advanced}
{synopt:{opt lambda(real)}}manually set lambda; selected via optimization routine by default{p_end}
{synopt:{opt ltolerance(real)}}manually set tolerance for lambda optimization{p_end}
{synopt:{opt lowerbound(real)}}manually set lower bound for lambda search window{p_end}
{synopt:{opt sigma(real)}}manually set sigma; defaults to the number of variables specified in {help varlist:covar}{p_end}
{synopt:{opt suppress}}suppresses the calculation of derivatives and the output table{p_end}
{synopt:{opt quantile(numlist)}}allows the user to specify the quantiles displayed within the results table{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
  {it:{help varlist: covar}} is a {it:{help varlist}} that may include factor variables, see {help fvvarlist}.
  {p_end}


{title:Description}

{pstd}
{opt krls} implements Kernel-based Regularized Least Squares (KRLS), a machine learning method to fit multidimensional functions y = f(x) 
for regression and classification problems without relying on linearity or additivity assumptions. 
KRLS finds the best fitting function by minimizing the squared loss of a Tikhonov regularization problem, 
using Gaussian kernels as radial basis functions. For further details see Hainmueller and Hazlett (2013).{p_end}

{title:Required}

{phang}
{cmd:depvar} {it:{help varname}}  that specifies the dependent variable (continuous or binary). 
   
{phang}
{cmd:covar} {it:{help varlist}} that specifies the covariates (continuous or binary). At least one variable should be specified.

{title:Note}

{pstd}
The krls routine constructs a n x n matrix. Please ensure that your system has sufficient {it:{help memory}} before using the command on large datasets.

{title:Options}

{dlgtab:Main}

{phang}
{opt deriv(string)} saves a n x k matrix of pointwise derivatives from the Gaussian kernel into the current dataset. These derivatives describe the marginal effect of covariates at each datapoint. Appended with the prefix specified by the user.

{phang}
{opt sderiv(filename)} stores the matrix of pointwise derivatives in a new dataset specified by filename.dta

{phang}
{opt graph} generates histograms for the pointwise derivatives.

{phang}
{opt vcov} stores the n x n fitted variance-covariance matrix for fitted values in e(Vcov_y). By default this matrix is not stored in memory.

{phang}
{opt svcov(filename)} stores the fitted variance-covariance matrix in a new dataset specified by filename.dta

{phang}
{opt keep(filename)} stores the output table in a new dataset specified by filename.dta. 

{dlgtab:Advanced}

{phang}
{opt lambda(real)} allows the user to manually provide a value for lambda, which governs the tradeoff between model fit and complexity. 
By default, krls selects lambda by minimizing the sum of the squared leave-one-out (Loo) errors.

{phang}
{opt ltolerance(real)} overrides the default tolerance used in the optimization routine, allowing the user to increase or decrease the 
sensitivity of the lambda optimization. By default, convergence is achieved when the difference in the sum of squared leave-one-out (Loo) 
errors between the i and the i+1 iteration is less than n * 10^-3

{phang}
{opt lowerbound(real)} can be used to manually specify a lower bound for the labmda search window. By default, the lower bound is dynamically 
set according to eigenvalue size. Set this value to 0 for maximum sensitivity. 

{phang}
{opt suppress} instructs the routine to avoid calculating derivatives and suppress all output. This offers a speed increase when the user 
is primarily interested in attaining predicted values. 

{phang}
{opt quantile(numlist)} allows the user to manually specify the values displayed within the results table. By default, the 25th, 50th, and 75th percentiles of the pointwise derivatives are displayed. Users may input a minimum of 1 and a maximum of 3 quantiles. 

{title:Examples}

    Load example data
{p 4 8 2}{stata "use growthdata.dta":. use growthdata.dta}{p_end}

    Basic syntax
{p 4 8 2}{stata " krls growth yearsschool assassinations       ":. krls growth yearsschool assassinations}{p_end}
{p 4 8 2}{stata " krls growth yearsschool assassinations, deriv(myprefix)":. krls growth yearsschool assassinations, deriv(myprefix)}{p_end}
{p 4 8 2}{stata " krls growth yearsschool assassinations, graph":. krls growth yearsschool assassinations, graph}{p_end}	
	The command returns the average of the point-wise derivatives for continuous variables.
	
{p 4 8 2}{stata " gen yearsschool3 = (yearsschool>3)":. gen yearsschool3 = (yearsschool>3)}{p_end}
{p 4 8 2}{stata " krls growth rgdp60 tradeshare yearsschool3 assassinations":. krls growth rgdp60 tradeshare yearsschool3 assassinations}{p_end}
		
	As well as first differences for binary variables (marked with an asterix).

   Advanced syntax
{p 4 8 2}{stata " krls growth yearsschool assassinations, lambda(.8) sigma(3)":. krls growth yearsschool assassinations, lambda(.8) sigma(3)}{p_end}
{p 4 8 2}{stata " krls growth yearsschool assassinations, ltolerance(.01)":. krls growth yearsschool assassinations, ltolerance(.01)}{p_end}
{p 4 8 2}{stata " krls growth yearsschool assassinations, ltolerance(.001) lowerbound(0)":. krls growth yearsschool assassinations, ltolerance(.001) lowerbound(0)}{p_end}

	If you wish to adjust the sensitivity of the optimization routine or replicate an existing analysis, 
	use the advanced syntax to override or modify the lambda optimization routine.

   Viewing the Variance-Covariance Matrix
{p 4 8 2}{stata " krls growth yearsschool assassinations, vcov":. krls growth yearsschool assassinations, vcov}{p_end}
{p 4 8 2}{stata " matrix list e(Vcov_y)":. matrix list e(Vcov_y)}{p_end}

	In order to conserve memory, the fitted variance-covariance matrix is not saved by default.

   Adjusting the Results Table
{p 4 8 2}{stata " krls growth yearsschool assassinations, quantile(.1 .5 .9)":. krls growth yearsschool assassinations, quantile(.1 .5 .9)}{p_end}

   Viewing fitted values, standard errors, etc using {help predict}
   
{p 4 8 2}{stata " krls growth yearsschool assassinations":. krls growth yearsschool assassinations}{p_end}
{p 4 8 2}{stata " predict myname_fitted, fitted  ":. predict myname_fitted, fitted}{p_end}
{p 4 8 2}{stata " predict myname_se, se":. predict myname_se, se}{p_end} 
   Out of sample Prediction
{p 4 8 2}{stata " set seed 1":. set seed 1}{p_end}
{p 4 8 2}{stata " gen double u = runiform()":. gen double u = runiform()}{p_end}
{p 4 8 2}{stata " sort u":. sort u}{p_end}
{p 4 8 2}{stata " gen insample = 1":. gen insample = 1}{p_end}
{p 4 8 2}{stata " replace insample = 0 in 1/5":. replace insample = 0 in 1/5}{p_end}
{p 4 8 2}{stata " krls growth rgdp60 tradeshare yearsschool assassinations if insample==1":. krls growth rgdp60 tradeshare yearsschool assassinations if insample==1}{p_end}
{p 4 8 2}{stata " predict myname2_fitted, fitted":. predict myname2_fitted, fitted}{p_end}
{p 4 8 2}{stata " predict myname2_residuals, resid":. predict myname2_residuals, resid}{p_end}


{title:Saved results}

{p 4 8 2}
By default, {cmd:krls}  ereturns the following results, which can be displayed by typing {cmd: ereturn list} after 
{cmd:krls} is finished (also see {help ereturn}).

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(Looloss)}}  the sum of squared leave-out-one (LOO) error{p_end}
{synopt:{cmd:e(lambda)}}  the lambda value used (manual or selected via optimization){p_end}
{synopt:{cmd:e(R2)}}  the R squared of the final model{p_end}
{synopt:{cmd:e(sigma)}}  the sigma value used (manual or selected via optimization){p_end}
{synopt:{cmd:e(Effective_df)}}  the effective degrees of freedom{p_end}
{synopt:{cmd:e(tolerance)}}  the tolerance  (manual or selected via optimization){p_end}
{synopt:{cmd:e(lowerbound)}} the lowerbound (manual or selected via optimization){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end} 
{synopt:{cmd:e(cmd)}}  krls {p_end}
{synopt:{cmd:e(depvar)}}  the dependent variable{p_end}
{synopt:{cmd:e(indvar)}}  the independent variables{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end} 
{synopt:{cmd: e(b)}} pointwise derivatives or first differences {p_end}
{synopt:{cmd: e(Output)}} the full output table in matrix form {p_end}
{synopt:{cmd: e(Coeffs)}} krls coefficients; used in predict {p_end}
{synopt:{cmd: e(Vcov_c)}} the krls coefficient variance covariance matrix; used in predict {p_end}
{synopt:{cmd: e(Vcov_y)}} the variance covariance matrix for fitted values. {p_end}

{title:References}

{p 4 8 2}
Hainmueller, J & Hazlett, C, 2014. "Kernel Regularized Least Squares: Reducing Misspecification Bias with a Flexible and Interpretable Machine Learning Approach.” Political Analysis (Spring 2014) 22(2): 143-168.

{title:Authors}

      Jeremy Ferwerda, ferwerda@mit.edu
      MIT

      Jens Hainmueller, jhain@stanford.edu
      Stanford

      Chad Hazlett, chazlett@mit.edu
      UCLA
