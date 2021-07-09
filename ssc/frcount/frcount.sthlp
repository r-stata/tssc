{smcl}
{* *! version 1.0.5  15Jun2010}{...}
{cmd: help frcount}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi: frcount} {hline 2}}Estimating fractional response model under the presence of count endogeneity and unobservable heterogeneity
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}
{opt frcount} {depvar} {indepvars} {ifin}{cmd:,} endog{cmd:(}{it:endogenous variable}{cmd:)} iv{cmd:(}{it:iv {varlist}}{cmd:)}
quad{cmd:(}{it:numeric}{cmd:)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt noc:onstant}}suppress constant term{p_end}
{synopt :{opt qmle}}estimates the model with Quasi-Maximum Likelihood Estimator (QMLE) method, this is default method{p_end}
{synopt :{opt nls}}estimates the model with Non-linear least square estimator (NSL) method{p_end}

{syntab:Average Partial Effects}
{synopt :{opth apevce(vcetype)}}reports Average Partial Effects (APE) for the countinous and count variables. The default option
is { opt robust}. {it:vcetype} may be {opt robust}{p_end}

{synoptline}
{p 4 6 2}
quad{cmd:(}{it:numeric}{cmd:)} defines the number of quadrature points using in approximating integrals with Adaptive Gauss Hermite method. The quadrature number depends on sample sizes, it could be 35 quadrature points or more. endog{cmd:(}{it:endogenous variable}{cmd:)} allows only for one count endogenous variable.{p_end}
{phang}

{title:Description}

{pstd}
{cmd:frcount} fits a fractional response model under the presence of count endogeneity and unobservable heterogeneity. The dependent variable
{it:y1} is a fractional response variable where 0<={it:y1}<=1. The endogenous variable {it:y2} is a count variable where it can be any numeric number.
The approach for this command is based on the chapter by Hoa Nguyen (2010) in {it:Advances in Econometrics}, Volume 26, Maximum Simulated Likelihood Methods and Applications,
edited by Carter Hill and Greene.

{pstd}
Consider the model using cross section data set:

{p 4 12 2}y1 = x1*b1 + x2*b2 + y2*b3 + eta1*a1 + e1

{pstd}
where

{p 4 12 2}y1 is the fractional response variable such as the passing rates, fractions of women employed in firms, etc.;{p_end}

{p 4 12 2}x1 and x2 are exogenous variables;{p_end}

{p 4 12 2}y2 is the count endogenous variable and we use a set of k instrument variables z1...zk for the endogenous variable;{p_end}

{p 4 12 2}a1 is unobservable heterogeneity variable which we do not observe;{p_end}

{p 4 12 2}e1 is the disturbance term;{p_end}

{pstd}
Estimation for -{cmd:frcount}- command was based on Quasi-Maximum Likelihood Estimator (QMLE) by default or by Non-linear Least Squares (NLS). Estimation procedure involves solving equations with no closed form solution, so we approximate some integrals in those equations
by using the Adaptive Gauss Hermite method. For details on the Adaptive Gauss Hermite method, please see mannual on -xtprobit-. The detailed procedure of this method was discussed in Hoa Nguyen (2010). The command provides regular outputs for an estimation command. In addition, the command provides output for Average Partial Effects of the all continuous and count variables, 
with changes in the count variable with values from 0 to 1, 1 to 2, and 2 to 3.

{pstd}
For more details of the estimation procedures and simulations for this command, -{cmd:frcount}-, please refer to Minh Nguyen and Hoa Nguyen (2010b).

{title:Return values}

{col 4}Scalars
{col 8}{cmd:e(n_quad)}{col 21}number of quadrature points
{col 8}{cmd:e(N)}{col 21}number of observations
{col 8}{cmd:e(cilevel)}{col 21}confidence interval level
{col 8}{cmd:e(converge)}{col 21}convergence or not
{col 8}{cmd:e(errcode)}{col 21}error code
{col 8}{cmd:e(llog)}{col 21}log-likelihood value
{col 8}{cmd:e(tol)}{col 21}convergence tolerance

{col 4}Macros
{col 8}{cmd:e(cmd)}{col 21}name of the command
{col 8}{cmd:e(cmdline)}{col 21}the full command typed
{col 8}{cmd:e(depvar)}{col 21}dependent variable 
{col 8}{cmd:e(endog)}{col 21}endogenous variable 
{col 8}{cmd:e(exog)}{col 21}exogenous variables (excluded)
{col 8}{cmd:e(iv)}{col 21}exogenous variables (included iv)
{col 8}{cmd:e(ivar)}{col 21}ID variable 
{col 8}{cmd:e(method)}{col 21}display estimation method 
{col 8}{cmd:e(properties)}{col 21}{cmd:b V ape Vape}
{col 8}{cmd:e(title)}{col 21}title of regression 
{col 8}{cmd:e(version)}{col 21}version of the command

{col 4}Matrices
{col 8}{cmd:e(b)}{col 21}estimated parameters
{col 8}{cmd:e(V)}{col 21}variance-covariance of estimated parameters
{col 8}{cmd:e(ape)}{col 21}estimated average partial effects
{col 8}{cmd:e(Vape)}{col 21}variance–covariance matrix of average partial effects

{title:Examples}

{phang}{title:Fractional response model with one instrument variable}{p_end}
{phang}{cmd:. use frcount_example.dta, clear}{p_end}
{phang}{cmd:. frcount y1 x1 x2, endog(y2) iv(iv) quad(35)}{p_end}
{phang}{cmd:. frcount y1 x1 x2, endog(y2) iv(iv) quad(35) nls}{p_end}
{phang}{cmd:. frcount y1 x1 x2, endog(y2) iv(iv) quad(35) qmle apevce(robust)}{p_end}

{title:References}
{p 4 8 2}Hoa Bao Nguyen. 2010.
Estimating fractional response model under the presence of count endogenous variable and unobservable heterogeneity. Forthcoming in {it:Advances in Econometrics}, Volume 26, Maximum Simulated Likelihood Methods and Applications, edited by Carter Hill and Greene.{p_end}
{p 4 8 2}Minh Cong Nguyen and Hoa Bao Nguyen. 2010b. Stata module: Estimation of fractional response model under the presence of count endogeneity. Working Paper.{p_end} 

{title:Acknowledgements}

{pstd}
We would like to thank Jeffrey Wooldridge, David Drukker, Jeffrey Pitblado, Isabel Canette, Carter Hill, and participants at the 2009 Stata DC Conference, Mid West Econometrics conference, 
and the 8th Annual Advances in Econometrics Conference at Louisiana State University for various comments and suggestion in developing the paper and the command.

{title:Authors}

{p 4}Hoa Bao Nguyen{p_end}
{p 4}Ph.D. Candidate{p_end}
{p 4}Economics Department{p_end}
{p 4}Michigan State University{p_end}
{p 4}East Lansing, MI{p_end}
{p 4}nguye147@msu.edu{p_end}

{p 4}Minh Cong Nguyen{p_end}
{p 4}Enterprise Analysis Unit{p_end}
{p 4}The World Bank, 2010{p_end}
{p 4}mnguyen3@worldbank.org{p_end}

{title:Version}

{p 4} This is version 1.0.5 released June 15, 2010.{p_end}
