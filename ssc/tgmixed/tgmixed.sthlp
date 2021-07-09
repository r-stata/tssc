{smcl}
{* 10jul2011}{...}
{hline}
help for {hi:tgmixed}
{hline}

{title:Perform Theil-Goldberger mixed estimation of regression equation}

{p 8 14}{cmd:tgmixed}{it: varlist} [{cmd:if} {it:exp}] [{cmd:in} {it:range}], 
{cmdab:pri:or(}{it:string}) [
{cmd:cov(}{it:string}) {cmdab:qui:etly}]

{p} {it:varlist} may not contain time-series operators nor factor variables; see help {help varlist}.

{title:Description}

{p}{cmd:tgmixed} estimates a regression equation subject to stochastic linear 
constraints, using the Theil-Goldberger (1961) mixed estimation technique. This estimator
is a generalization of {cmd:cnsreg}, which applies exact linear constraints to a regression
equation. In the Theil-Goldberger technique, the constraints hold with some degree of subjective
belief. The routine computes the Theil compatibility statistic (Theil, 1963) for the null
hypothesis that the sample and non-sample information are compatible. Under the null, this 
statistic is distributed Chi-squared, with degrees of freedom equal to the number of 
stochastic constraints.

{title:Options}

{p 0 4}{cmdab:pri:or}({it:string}) is a required option. It must contain triples of
{it:varname prior_value prior_se} where {it:varname} must be a regressor in the {it:varlist}. The
stochastic constraint indicates that this regressor has a {it:prior_value} and a {it:prior_se}. 
If multiple regressors have priors, each should be listed within the {it:prior()} option.
Note that at present {cmd:tgmixed} does not support stochastic constraints involving multiple
variables (e.g., adding-up or equality constraints).

{p 0 4}{cmd:cov}({it:string}) may be used to specify prior covariances between pairs of
coefficients included in the {it:prior()} option. 

{p 0 4}{cmd:quietly} may be used to suppress the listing of the unconstrained OLS regression
estimates.


{title:Saved results}

{p}{cmd:tgmixed} saves the following scalars:

{p 8 12}e(rmse) : the root mean squared error of the mixed estimates

{p 8 12}e(r2) : the R-squared of the mixed estimates

{p 8 12}e(N): the number of observations in the estimation sample

{p 8 12}e(df_r) : the number of degrees of freedom of the residual sum of squares

{p 8 12}e(compat) : the Theil compatibility statistic

{p 8 12}e(vrank) : the rank of the matrix of stochastic constraints

{p 8 12}e(pvalue) : the p-value of the compatibility statistic

{p 8 12}e(frac_sample) : the proportion of precision due to sample information

{p 8 12}e(frac_prior) : the proportion of precision due to prior information

{p}{cmd:tgmixed} saves the following macros:

{p 8 12}e(cmd) : tgmixed

{p 8 12}e(predict) : regres_p

{p 8 12}e(depvar) : the name of the dependent variable

{p 8 12}e(marginsok) : XB default

{p 8 12}e(cmdline) : the command line used for estimation

{p 8 12}e(prior) : the content of the prior() option

{p 8 12}e(properties) : b V

{p}{cmd:tgmixed} saves the following matrices:

{p 8 12}e(b) : the vector of mixed coefficient estimates

{p 8 12}e(V) : the VCE of mixed coefficient estimates

{p 8 12}e(Vprior) : the VCE of stochastic prior estimates

{p}{cmd:tgmixed} saves the following function:

{p 8 12}e(sample) : indicator for inclusion in the estimation sample

{title:References}

{p 8 12}Theil, H. and A.S. Goldberger, On pure and mixed statistical information in economics.
{it:International Economic Review}, 2:1, 65-78, 1961.

{p 8 12}Theil, H., On the Use of Incomplete Prior Information in Regression Analysis. 
{it:Journal of the American Statistical Association}, 58:302, 401-414, 1963.

{p 8 12}For more information, see the Stata Conference 2011 presentation at
http://econpapers.repec.org/paper/bocchic11/14.htm

{title:Example: reproduce textile example in Theil, 1963}

{p 8 12}{inp:.} {stata "use http://fmwww.bc.edu/ec-p/data/micro/theiltextile ":use http://fmwww.bc.edu/ec-p/data/micro/theiltextile}

{p 8 12}{inp:.} {stata "tgmixed lconsump lincome lprice, prior(lprice -0.7 0.15 lincome 1 0.15) cov(lprice lincome -0.01)":tgmixed lconsump lincome lprice, prior(lprice -0.7 0.15 lincome 1 0.15) cov(lprice lincome -0.01)}

{title:Acknowledgements}

{p 8 12}The Mata code for {cmd:tgmixed} includes a copy of Ben Jann's {cmd:mm_posof()} from 
his {it:moremata} package. 

{title:Author}

{p 0 4}Christopher F Baum, Boston College, USA{p_end}
{p 0 4}baum@bc.edu{p_end}


