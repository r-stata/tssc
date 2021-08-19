{smcl}
{* *! version 1.1.3  8apr2021}{...}
{viewerjumpto "Syntax" "hetsar##syntax"}{...}
{viewerjumpto "Description" "hetsar##description"}{...}
{viewerjumpto "Remarks" "hetsar##remarks"}{...}
{viewerjumpto "Examples" "hetsar##examples"}{...}
{viewerjumpto "Stored results" "hetsar##results"}{...}
{viewerjumpto "Reference" "hetsar##reference"}{...}
{* *! version 1.0.1  19feb2021}{...}
{* *! version 1.0.2  15jul2021}{...}
{* *! version 1.0.3  22jul2021}{...}

{cmd:help hetsar}{right:also see:  {help hetsar postestimation##hetsar postestimation:hetsar_postestimation}}
{hline}



{title:Title}

{p2colset 5 15 15 1}{...}
{p2col:{hi:hetsar} {hline 2}}Spatial autoregressive models with heterogeneous coefficients{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:hetsar} {depvar} [{indepvars}] {ifin},
wmatrix(name) [{it:{help hetsar##hetsaroptions:options}}]



{marker hetsaroptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:wmat:rix(}{it:name}{cmd:)}}specifies a spatial weights matrix used to create spatial lags of dependent and independent variables. Stata matrices, {help spmat} or {help spmatrix} objects are allowed.
{p_end}
{synopt :{opt det:ailed}}post to e(b) and e(V) the estimated unit-specific coefficients and corresponding VCV matrix.
{it: Default} is to post the mean group estimates (see Aquaro, Bailey and Pesaran, 2021 for more details) {p_end}
{synopt :{cmdab:ivarlag(}{it:durb_varlist})}specifies that the spatial lag of the independent variables in {it:durb_varlist} is included in the model.
{p_end}
{synopt :{cmdab:timelag(}{it:[y wy x wx]})}specifies a dynamic model.
If {cmd: timelag(y)} is specified the time lagged dependent variable is included in the model, then {cmd: timelag(y wy x wx)} implies a fully dynamic heterogeneous spatial Durbin model{p_end}
{synopt :{opt nocons:tant}}suppress unit-specific intercepts in the model{p_end}

{syntab:Reporting}
{synopt :{opt rob:ust}}Sandwich estimator of the VCV matrix. Only when {cmd: detailed} is specified{p_end}
{synopt :{cmdab:save(}{it:{help filename}[, replace]})}save the parameters vector and related standard errors to a csv file{p_end}

{syntab:Maximization}
{synopt :{it:{help hetsar##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
A panel and a time variable must be specified. Use {helpb xtset}.{p_end}
{p 4 6 2}
{it:indepvars} and {it: durb_varlist} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{help weights} and {help tsvarlist} are not allowed.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{cmd:hetsar} fits spatial panel data models with heterogeneous coefficients, with and without weakly exogenous regressors, subject to heteroskedastic errors. The estimation is performed via quasi maximum-likelihood.{p_end}
{pstd}See Aquaro, Bailey and Pesaran (2021) for more details on the properties of the QML estimator and the section {it:{help hetsar##remarks:Remarks}}.{p_end}


{dlgtab:Maximization}
{marker maximize_options}
{phang}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt from(init_specs)}, {opt tol:erance(#)},
{opt ltol:erance(#)}, {opt nrtol:erance(#)}; see {manhelp maximize R}.  These
options are seldom used.



{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:hetsar} performs a constrained minimization of the negative log-likelihood function of the model.{p_end}
{pstd} The parameters related to the spatial lag of the dependent variable (the rho_i{it:s}) are constrained in [-0.995, 0.995] using the hyperbolic tangent parametrization,
i.e. the evaluator reads {it:constr_rho_i=0.95*{exp(rho_i)-exp(-rho_i)}/{exp(rho_i)+exp(-rho_i)}}, while the {it:sigmasq} parameters are constrained in [0, +infty], i.e. {it:sigmasq}=exp(lnsigmasq).{p_end}
{pstd}
This is the only way to constrain parameters in Stata, i.e. hard-code a reparametrized evaluator. As a consequence, time series operators have been deliberately disallowed
and the {cmd:timelag()} option has been expliticitly designed to simplify the estimation of parameters in heterogeneous spatial autoregressive {cmd:dynamic} models.{p_end}
{pstd}
When the options {cmd:timelag(y)}, {cmd:timelag(wy)} or {cmd:timelag(y wy)} are specified, the parameters related to {it:l.y} and/or {it:l.wy} are indeed automatically constrained using
the hyperbolic tangent parametrization (notice that {it:l.x} and/or {it:l.Wx} are never constrained).
Users can avoid binding these two sets of parameters by specifying the undocumented {cmd:nodconstraints} option.{p_end}
{pstd}
All the remaining parameters are left unconstrained and, once estimation has been performed, all (reparametrized) parameters are automatically translated to the original metric and reported.{p_end}
{pstd}
The official Stata's commands convention is used for factor and time series variables (the latter when the {cmd:timelag()} option is specified).{p_end}
{pstd}
A {cmd:d1} evaluator is used for optimization (for more details see {help optimize}).
By default {cmd:hetsar} runs the BFGS optimization alhorithm (use the {cmd:technique()} option to change among the available algorithms).
Our Monte Carlo simulations show that a mix between Newton and BFGS methods works very well in complex models. {cmd:hetsar} has been tested from Stata 11.2 onwards.{p_end}



{marker examples}{...}
{title:Examples}

{pstd}(The following examples runs from Stata 14 onwards){p_end}

{pstd}Load and summarize the spatial weights matrix{p_end}
{phang2}{stata "spmat import w using https://raw.github.com/fbelotti/Stata/master/txt/Wrook_25.txt, replace noid normalize(row)":spmat import w using Wrook_25.txt, replace noid normalize(row)}{p_end}
{phang2}{stata "spmat summarize w"}{p_end}

{pstd}Load data and set-up the panel{p_end}
{phang2}{stata "import delimited https://raw.github.com/fbelotti/Stata/master/csv/hetsar_demo.csv, clear":import delimited hetsar_demo.csv, clear}{p_end}
{phang2}{stata "xtset id time"}{p_end}

{pstd}Estimate a SAR static model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w)"}{p_end}

{pstd}Estimate a Durbin static model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) ivarlag(x) technique(nr 3 bfgs 10)"}{p_end}

{pstd}Estimate a SAR dynamic model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) timelag(y wy) technique(nr 3 bfgs 10)"}{p_end}

{pstd}Estimate a Durbin dynamic model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) ivarlag(x) timelag(y wy x wx) technique(nr 3 bfgs 10)"}{p_end}

{pstd}Estimate a SAR static model and report estimated unit-specific coefficients{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) detailed technique(nr 3 bfgs 10)"}{p_end}

{pstd}Estimate a Durbin dynamic model, report mean-group estimates but save the unit-specific coefficients in a csv file{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) ivarlag(x) timelag(y wy x wx) technique(nr 3 bfgs 10) save(hetsar, replace)"}{p_end}

{pstd}Estimate a SAR static model using by passing starting values{p_end}
{pstd}(This example runs from Stata 15 onwards){p_end}

{pstd}1) Get an spmatrix object from a spmat object passing through mata{p_end}
{phang2}{stata "spmat getmatrix w w_mata"}{p_end}
{phang2}{stata "spset id"}{p_end}
{phang2}{stata "preserve"}{p_end}
{phang2}{stata "keep if time == 1"}{p_end}
{phang2}{stata "spmatrix spfrommata w_sp = w_mata _ID, replace"}{p_end}
{phang2}{stata "restore"}{p_end}

{pstd}2) Estimate a homogenous random-effects SAR static model{p_end}
{phang2}{stata "spxtregress y x, re dvarlag(w_sp)"}{p_end}

{pstd}3) Get a vector {cmd:theta0} of initial values exploiting mata{p_end}
{phang2}{stata "mat li e(b)"}{p_end}
{phang2}{stata "mata"}{p_end}
{phang2}{matacmd wy0 = rnormal(1,25,st_matrix("e(b)")[1,3],0.25)}{p_end}
{phang2}{matacmd _cons0 = rnormal(1,25,st_matrix("e(b)")[1,2],st_matrix("e(b)")[1,4])}{p_end}
{phang2}{matacmd x0 = rnormal(1,25,st_matrix("e(b)")[1,1],0.25)}{p_end}
{phang2}{matacmd sigmasq0 = rnormal(1,25,st_matrix("e(b)")[1,5],0.25)}{p_end}
{phang2}{matacmd st_matrix("theta0", (wy0,_cons0,x0,sigmasq0))}{p_end}
{phang2}{stata "end"}{p_end}

{pstd}4) Estimate a heterogenous SAR static model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) from(theta0)"}



{marker results}{...}
{title:Saved results}

{pstd}
{cmd:hetsar} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(mean_group)}}1 if mean group estimator, 0 otherwise{p_end}
{synopt:{cmd:e(k_mg)}}number of parameters (Mean group estimator){p_end}
{synopt:{cmd:e(dynamic)}}1 if dynamic model, 0 otherwise{p_end}
{synopt:{cmd:e(ll)}}negative log-likelihood{p_end}
{synopt:{cmd:e(converged)}}1 if the model converged, 0 otherwise{p_end}
{synopt:{cmd:e(rank)}}rank of the variance-covariance matrix{p_end}
{synopt:{cmd:e(iter)}}number of iterations{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:hetsar}{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}



{marker references}{...}
{title:References}

{phang}
Aquaro, M, Bailey, N and Pesaran, M.H., 2021
"Estimation and inference for spatial models with heterogeneous coefficients: An application to US house prices", Journal of Applied Econometrics, 36, pp. 18-44.



{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}



{title:Also see}

{psee}
Online: {help spxtregress}, {helpb xsmle} (if installed){p_end}
