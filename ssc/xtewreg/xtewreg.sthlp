{smcl}
{* *! version 2.1  14jun2016}{...}
{cmd:help xtewreg}
{hline}

{title:Title}

{phang}
{bf:[XT] xtewreg} {hline 2} Erickson-Whited linear errors-in-variables panel regression with identification from higher order cumulants/moments


{title:Syntax}

{p 8 17 2}
{cmdab:xtewreg}
depvar misindepvars [indepvars]
{ifin}
{cmd:,}
{opt max:deg}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt max:deg}}Highest cumulant/moment order to use. Required{p_end}
{synopt:{opt mis:measured}}The number of mismeasured regressors{p_end}
{synopt:{opt meth:od}}Use high order cumulants (CML) or moments (MOM){p_end}
{synopt:{opt pan:method}}Which panel method to use{p_end}
{synopt:{opt bx:int}}Starting guess for the coefficients on misindepvars. Requires {opt meth:od}=MOM{p_end}
{synopt:{opt cent:mom}}Support centering moment conditions for bootstrap estimation of standard errors{p_end}
{synopt:{opt has:cons}}Indicate that indepvars already contains a constant variable{p_end}
{synopt:{opt no:cons}}Indicate that indepvars should not contain a constant variable - see warning below{p_end}
{synopt:{opt noprn}}Supress printing of results{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{dlgtab:Model}

{pstd}
{cmd:xtewreg} estimates a classical linear errors-in-variables model with arbitrarily many mismeasured regressors and perfectly measured regressors on panel data.
It uses information in the higher order cumulants/moments of the observable variables to identify the regression coefficient.

{pstd}
Yit = Xit*b + Zit*a + uit

{pstd}
xit = Xit + vit

{pstd}
In which Yit is the dependent variable, Xit is a vector of unobservable mismeasured regressors, Zit is a vector of perfectly measured regressors,
uit is the regression disturbance, xit are the proxies for Xit, and vit are the measurement errors.

{pstd}
This procedure implements the estimators from Erickson and Whited (2000, 2002) and Erickson, Jiang and Whited (2014).
Panel data can be analyzed by using either a clustered weighting matrix ({opt pan:method}=CLS, recommended) or a minimum distance procedure ({opt pan:method}=CMD),
in which estimates are attained for each cross section in the panel and then pooled using the classical minimum distance estimator for unbalanced panels in Erickson and Whited (2012).

{pstd}
As {cmd:xtewreg} requires de-meaned data (and does not compute fixed effects internally), the researcher must de-mean the data appropriately before using {cmd:xtewreg}.

{pstd}
{hi:Note:} The Erickson-Whited estimators are unidentified if the coefficients on the mismeasured regressors are equal to zero, or if the mismeasured regressors are normally distributed.


{dlgtab:Choosing maxdeg}

{pstd}
{cmd:xtewreg} does not provide a default value for maxdeg, the highest order of cumulants/moments to use.
This choice is left to the researcher and is an empirical choice.
Generally speaking, the more data one has, the higher the order one can use.
A reasonable starting value for applied work is {opt max:deg}=5, but the sensetivity of the estimates to different values of {opt max:deg} should be explored on a case by case basis.


{dlgtab:Description of MOM and CMD}

{pstd}
While {cmd:xtewreg} supports both high order cumulants (CML) and moments (MOM), using high order moments is not advised.
High order moments require a minimization procedure when computing the GMM objective, whereas the cumulants are linear and so have a closed-form minimum.
Thus, using high order moments adds a level of complexity absent from high order cumulant based estimation.
Similarly, {cmd:xtewreg} supports panel data using both clustered weighting matrices (CLS) and using classical minimum distance (CMD).
Using classical minimum distance is not advised due to the high computational cost invloved and the finite-sample properties of the estimator.
Both options are nevertheless provided for completeness and backward compatability.


{dlgtab:Additional statistics}

{pstd}
Like any regression estimator, the {cmd:xtewreg} command returns estimates of regression coefficients, standard errors, and the R2 of the regression, denoted here rho2.
Additionally, the command returns the R2 of each measurement equation, denoted tau2, which is an index of measurement quality.
This index ranges between zero and one, with zero indicating a worthless proxy and one indicating a perfect proxy.

{pstd}
The {cmd:xtewreg} command also provides the test of the overidentifying restrictions of the model (the Sargan-Hansen J-statistic).


{dlgtab:Technical considerations}

{pstd}
To prevent unneccesary computations, {cmd:xtewreg} saves the structure of a problem (the estimation equations associated with a given {opt maxdeg} and {opt mismeasured} between executions.
This is especially useful when using bootstrap, to avoid constructing the equations for every bootstrap iteration.

{pstd}
This procedure requires Stata 12 or higher.




{title:Options}

{phang}
{opt maxdeg} sets the highest order of cumulants/moments to use. The minimum value is 3, which corresponds to an exactly identified Geary (1942) estimator.
Very high values (above 8) are not advised, as the computational time for these models is exponential in maxdeg. See comment above regarding choosing maxdeg values.

{phang}
{opt mismeasured} declares the number of mismeasured regressors in the model. The defualt value is 1.
{cmd:xtewreg} uses this value to distinguish between misindepvars and indepvars.
The first <mismeasured> independant variables are taken to be misindepvars, and the rest are taken to be indepvars.

{phang}
{opt method} chooses whether to use high order cumulants (CML, the default) or high order moments (MOM). See comment above regarding the deprecation of high order moments.

{phang}
{opt panmethod} chooses whether to perform panel estimation by using clustered weighting matrices in the GMM (CLS, the default) or combine cross-sections using a minimum distance estimator (CMD).
See comment above regarding the deprecation of classical minimum distance estimators.

{phang}
{opt bxint} is a numlist of starting values for the coefficients on misindepvars. This option requires setting metod=MOM.
The high order moment estimators require numerical minimization of a nonlinear objective function and thus require starting values.
The default is to use both the OLS coefficients and the coefficients from maxdeg=3 as possible starting values.

{phang}
{opt centmom} is a directive supporting centering moment conditions for bootstrap estimation of standard errors.
The option takes one of the values [set, use, reset].
{opt centmom}=set saves the value of the moment conditions for the entire sample, and should be used before using the {cmd:bootstrap} command.
{opt centmom}=use should be specified when using {cmd:bootstrap} along with {cmd:xtewreg}.
{opt centmom}=reset resets the value of saved moment conditions, and is rarely used.

{phang}
{opt hascons} indicates that indepvar already contains a constant variable, and so a constant should not be added by the estimation procedure.

{phang}
{opt nocons} indicates that indepvars should not contain a constant variable. Using this option requires that all variables have zero mean.

{phang}
{opt noprn} disables printing of results table.


{title:Examples}

{phang}{cmd:. xtset gvkey}

{phang}{cmd:. xtewreg ik q , max(5)}

{phang}{cmd:. xtewreg ik q cfk oik, max(5) mis(2) cent(set) }

{phang}{cmd:. bootstrap : xtewreg ik q cfk oik, max(5) mis(2) cent(use) }


{title:Saved results}

{pstd}
{cmd:xtewreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(rho)}}estimate of rho^2{p_end}
{synopt:{cmd:e(SErho)}}standard error for rho^2{p_end}
{synopt:{cmd:e(Jstat)}}Sargan-Hansen J statistic for overidentifying restrictions{p_end}
{synopt:{cmd:e(Jval)}}p-value for Jstat{p_end}
{synopt:{cmd:e(dfree)}}degrees of freedom for Jstat{p_end}
{synopt:{cmd:e(obj)}}minimized value of the gmm objective function{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(bxint)}}numlist of initial guesses for beta{p_end}
{synopt:{cmd:e(method)}}method used for estimation (CML or MOM){p_end}
{synopt:{cmd:e(panmethod)}}panel method used for estimation (CMD or CLS){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}regression coeffiecients{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix for e(b){p_end}
{synopt:{cmd:e(serr)}}standard errors for e(b){p_end}
{synopt:{cmd:e(tau)}}estimates of tau^2, the proxy accuracy indices{p_end}
{synopt:{cmd:e(SEtau)}}standard errors for tau^2{p_end}
{synopt:{cmd:e(vcrhotau)}}variance-covariance matrix for rho and all of the tau^2{p_end}
{synopt:{cmd:e(w)}}the weighting matrix used in the gmm estimation{p_end}

{p2colreset}{...}


{title:References}

{phang}
Erickson, T. and T. M. Whited. 2000. Measurement error and the relationship between investment and q. {it:Journal of Political Economy} 108: 1027-1057.

{phang}
Erickson, T. and T. M. Whited. 2002. Two-step GMM estimation of the errors-in-variables model using high-order moments. {it:Econometric Theory} 18: 776-799.

{phang}
Erickson, T. and T. M. Whited. 2012. Treating measurement error in Tobin's q. {it:Review of Financial Studies} 25: 1286-1329

{phang}
Erickson, T. C. H. Jiang, and T. M. Whited. 2014. Minimum Distance Estimation of the Errors-in-Variables Model Using Linear Cumulant Equations. {it:Journal of Econometrics}, forthcoming.

{phang}
Geary, R. C., 1942. Inherent relations between random variables. {it:Proceedings of the Royal Irish Academy A} 47: 63-76.


{title:Remark}

{pstd}
This is version 2.1 of the xtewreg command. Please send bug reports and feature requests to robert.parham@simon.rochester.edu. Adapted to Stata by Robert Parham, based on code provided by Toni M. Whited.


{title:Also see}

{psee}
Help: {helpb xtset: [XT] xtset}
