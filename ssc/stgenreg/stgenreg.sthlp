{smcl}
{* *! version 0.6.0 04jan2013}{...}
{hline}
{cmd:help stgenreg} {right:also see: {helpb stgenreg postestimation}}
{hline}

{title:Title}

{p2colset 5 17 35 2}{...}
{p2col :{cmd:stgenreg} {hline 2}}General parametric survival models{p_end}
{p2colreset}{...}

{title:Syntax}

{phang2}
{cmd: stgenreg} {ifin} [{cmd:,} {it:options}]


{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt loghaz:ard(string)}}user-defined log baseline hazard function{p_end}
{synopt :{opt haz:ard(string)}}user-defined baseline hazard function{p_end}
{synopt :{opt bhaz:ard(varname)}}invokes relative survival models, defining the expected hazard rate at the time of event{p_end}
{synopt :{opt eq_name(string)}}specify the components to include in the linear predictor of each parameter{p_end}

{syntab:Reporting}
{synopt :{opt showcomp:onent}}display each parsed component specified in {cmd:cov#}{p_end}
{synopt :{opt matalogh:azard}}display the log hazard function passed to Mata{p_end}
{synopt :{opt matak:eep}}do not drop data from Mata after fitting a model{p_end}
{synopt :{opt eform}}exponentiate coefficients of first {cmd:ml} equation}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{syntab:Maximization options}
{synopt :{opt nodes(#)}}number of quadrature nodes{p_end}
{synopt :{opt search(string)}}search option to pass to {cmd:ml}{p_end}
{synopt :{opt initmat(matrix_name)}}matrix of initial values to pass to {cmd:ml}{p_end}
{synopt :{opt copy}}parameters in the initial values matrix are entered by position{p_end}
{synopt :{opt skip}}any parameters found in initial values matrix but not in model are skipped{p_end}
{synopt :{opt nolog}}suppress display of log-likelihood iteration log{p_end}
{synopt :{it:{help stgenreg##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stgenreg}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}
{p 4 6 2}
Factor variables are not currently supported.{p_end}


{title:Description}

{pstd}
{cmd:stgenreg} fits parametric survival models using any user-defined [log] baseline hazard fuction. Gaussian quadrature is used to evaluate the cumulative 
hazard function and consequently the survival function allowing the estimation of a parametric survival model with almost any form. The [log] hazard function 
must be written in Mata code using colon operators. Each parameter defined in a [log] hazard function can include components, whereby each component can contain variables, 
user-defined functions of time, restricted cubic spline functions and/or fractional polynomial functions. Time-dependent effects can be included in any 
component. Relative survival models can also be fitted.{p_end}


{title:Options}

{dlgtab:Model}

{phang}
{opt loghazard(string)} is the user-defined log baseline hazard function. This must be written in Mata code using colon operators. 
Each parameter must be identified in square brackets, for example [xb]. Time must be entered as #t.

{phang}
{opt hazard(string)} is the user-defined baseline hazard function. This must be written in Mata code using colon operators.
Each parameter must be identified in square brackets, for example [xb]. Time must be entered as #t.

{phang}
{opt bhazard(varname)} defines the expected hazard rate at the time of event, used in relative survival or cure models. The timescale units used to generate 
this variable must be the same as the units of {cmd:_t}.

{phang}
{opt eq_name(string)} specifies the components to be included in the linear predictor of each parameter. Components must be split by {cmd:|}, for example, 
{cmd:eq_name({it:comp1} | {it:comp2} | {it:comp3})}. Each component can be one of the following:

{phang3}
{varlist} [,{cmd:nocons}]: the user may specify a standard variable list within a component section, with an optional {cmd:nocons} option

{phang3}
g(#t): where g() is any user defined function of #t written in Mata code, for example #t:^2

{phang3}
#rcs({it:options}): which creates restricted cubic splines of either log time or time. {it:options} include {cmd:df(#)}, the number of degrees of freedom,
{cmd:noorthog} which turns off the default orthogonalisation, {cmd:time}, which creates splines using time rather than log time, the default, and 
{cmd:offset(varname)}, which includes an offset variable. See {help rcsgen} for more details.

{phang3}
#fp({it:numlist} [,{cmd:offset(}{varname}{cmd:)}]): which creates fractional polynomials of time. If 0 is specified, log time is generated. If {cmd:offset()} is specified an 
offset variable is added to {cmd:_t} before generating the fractional polynomials.

{phang3}
{varname}:*f(#t): to include time-dependent effects, where f(#t) is one of #rcs(), #fp() or g().

{dlgtab:Reporting}

{phang}
{opt showcomponent} display each parsed component specified in the {cmd:eq_name} options. This is useful to check that {cmd:stgenreg} has correctly parsed 
the options.

{phang}
{opt mataloghazard} display the log hazard function passed to Mata. This is useful to check that {cmd:stgenreg} has correctly parsed the log hazard function. 

{phang}
{opt matakeep} do not drop the data from Mata following a model fit. By default, all data passed to Mata is dropped.

{phang}
{opt eform} exponentiate the coefficients of the first {cmd:ml} equation.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{dlgtab:Maximization}

{phang}
{opt nodes(#)} defines the number of Gauss-Legendre quadrature points used to evaluate the cumulative hazard function in the maximisation process. 
Must be an integer > 2, with default 15.

{phang}
{opt search(string)} search option to pass to {cmd:ml}.

{phang}
{opt initmat(matrix_name)} passes a matrix of initial values.

{phang}
{opt copy} pass initial values by position rather than name.

{phang}
{opt skip} any parameters found in the initial values matrix but not in model are skipped.

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems.


{title:Remark}

{pstd}Note: As with all models which use numerical integration, the stability of maximum likelihood estimates should be 
established by using an increasing number of quadrature nodes.{p_end}


{title:Example}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1) scale(365.25)"}{p_end}

{pstd}Weibull proportional hazards model{p_end}
{phang2}{stata "stgenreg, loghazard([ln_lambda] :+ [ln_gamma] :+ (exp([ln_gamma])-1):*log(#t)) ln_lambda(hormon)"}{p_end}

{pstd}Restricted cubic splines on the log hazard scale{p_end}
{phang2}{stata "stgenreg, loghazard([xb]) xb(hormon | #rcs(df(5)))"}{p_end}

{pstd}FP3 model{p_end}
{phang2}{stata "stgenreg, loghazard([xb]) xb(hormon | #fp(0 1 2))"}{p_end}

{pstd}Restricted cubic splines on the log hazard scale, with time-dependent effect{p_end}
{phang2}{stata "stgenreg, loghazard([xb]) xb(hormon | #rcs(df(5)) | hormon:*#rcs(df(3)))"}{p_end}

{title:Authors}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{pstd}Paul C. Lambert{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:paul.lambert@le.ac.uk":paul.lambert@le.ac.uk}{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{pstd}Crowther MJ and Lambert PC. stgenreg: A Stata package for general parametric survival analysis. {it: Journal of Statistical Software} 2013; (To Appear).{p_end}

{title:Also see}

{psee}
Online: {helpb stgenreg postestimation}
{p_end}
