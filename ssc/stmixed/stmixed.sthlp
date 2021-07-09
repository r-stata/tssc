{smcl}
{* *! version 1.0.0 2012}{...}
{vieweralsosee "stmixed postestimation" "help stmixed postestimation"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{vieweralsosee "strcs" "help strcs"}{...}
{viewerjumpto "Syntax" "stmixed##syntax"}{...}
{viewerjumpto "Description" "stmixed##description"}{...}
{viewerjumpto "Options" "stmixed##options"}{...}
{viewerjumpto "Remarks" "stmixed##remarks"}{...}
{viewerjumpto "Examples" "stmixed##examples"}{...}
{viewerjumpto "Reference" "stmixed##reference"}{...}
{title:Title}

{p2colset 5 16 17 2}{...}
{synopt :{cmd:stmixed} {hline 2}}Multilevel mixed effects survival analysis
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:stmixed} [{it:fe_equation}] {cmd:||} {it:re_equation} [{cmd:||} {it:re_equation} ...]
        [{cmd:,} {it:{help stmixed##options_table:options}}]

{p 4 4 2}
    where the syntax of {it:fe_equation} is

{p 12 24 2}
        [{varlist}] {ifin}

{p 4 4 2}
    and the syntax of {it:re_equation} for random coefficients and intercept is

{p 12 24 2}
        {it:{help varname:levelvar}}{cmd::} [{varlist}]
                [{cmd:,} {it:{help xtmixed##re_options:re_options}}]

{p 4 4 2}
    {it:levelvar} is a variable identifying the group structure for the random
    effects at that level.{p_end}

{synoptset 29 tabbed}{...}
{marker re_options}{...}
{synopthdr :re_options}
{synoptline}
{syntab:Model}
{synopt :{opt noc:onstant}}suppress constant term from the random-effects equation{p_end}
{synoptline}

{synoptset 29 tabbed}{...}
{marker options_table}{...}
{synopthdr :options}
{synoptline}
{syntab:Model}
{synopt:{cmdab:d:istribution(}{cmdab:e:xponential)}}exponential survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:gom:pertz)}}Gompertz survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:w:eibull)}}Weibull survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:rp)}}Royston-Parmar survival model{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:rcs)}}restricted cubic splines on the log hazard scale{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:user)}}a user-defined survival model; see {it:{help stmixed##user:user functions}}{p_end}
{synopt:{cmdab:df(#)}}degrees of freedom for baseline hazard function with {bf:d(fpm)} or {bf:d(rcs)}{p_end}
{synopt:{opt knots(numlist)}}knot locations for baseline hazard with {bf:d(fpm)} or {bf:d(rcs)}{p_end}
{synopt:{opt tvc(varlist)}}varlist of time-dependent effects{p_end}
{synopt:{opt dft:vc(df_list)}}degrees of freedom for each time-dependent effect's spline function{p_end}
{synopt:{opt knotst:vc(numlist)}}knot locations for time-dependent effects' spline function{p_end}
{synopt :{opt noc:onstant}}suppress constant term from the fixed-effects equation{p_end}
{synopt :{opt bh:azard(varname)}}expected mortality rate; invokes a relative survival model{p_end}
{synopt :{opth cov:ariance(stmixed##vartype:vartype_list)}}variance-covariance structure of the random effects at each level{p_end}

{syntab:Integration}
{synopt :{cmdab:intm:ethod(}{it:{help stmixed##intmethod:intmethod}}{cmd:)}}integration method{p_end}
{synopt :{opt intp:oints(#)}}set the number of integration points{p_end}
{synopt :{cmdab:adapt:opts(}{it:{help stmixed##adaptopts:adaptopts}}{cmd:)}}options for adaptive quadrature{p_end}

{syntab:Estimation}
{synopt :{cmd:from(}{it:{help merlin_estimation##matname:matname}}{cmd:)}}specify starting values{p_end}
{synopt :{cmdab:restartv:alues(}{it:{help merlin_estimation##svlist:sv_list}}{cmd:)}}specify starting values for specific random effect variances{p_end}
{synopt :{cmdab:apstartv:alues(#)}}specify the starting value for all ancilary parameters; see details{p_end}
{synopt :{cmd:zeros}}specify all initial values set to {cmd:0}; see details{p_end}
{synopt:{it:{help stmixed##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{synoptset 29 tabbed}{...}
{marker user}{...}
{synopthdr:user functions}
{synoptline}
{synopt :{opt llfunction(fnc_name)}}Mata function name which returns the observation-level log likelihood contribution{p_end}
{synopt :{opt loghfunction(fnc_name)}}Mata function name which returns the observation-level log hazard function{p_end}
{synopt :{opt hfunction(fnc_name)}}Mata function name which returns the observation-level hazard function{p_end}
{synopt :{opt chfunction(fnc_name)}}Mata function name which returns the observation-level cumulative hazard function{p_end}
{synopt :{opt nap(#)}}number of ancillary parameters to estimate{p_end}
{synoptline}
{p2colreset}{...}
{pstd}See {helpb merlin_user:merlin user-defined functions}.

{synoptset 29 tabbed}{...}
{marker vartype}{...}
{synopthdr :vartype}
{synoptline}
{synopt :{opt ind:ependent}}one variance parameter per random effect, 
all covariances zero; the default unless a factor variable is specified{p_end}
{synopt :{opt ex:changeable}}equal variances for random effects, 
and one common pairwise covariance{p_end}
{synopt :{opt id:entity}}equal variances for random effects, all 
covariances zero; the default for factor variables{p_end}
{synopt :{opt un:structured}}all variances and covariances distinctly 
estimated{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 29 tabbed}{...}
{marker intmethod}{...}
{synopthdr :intmethod}
{synoptline}
{synopt :{opt mv:aghermite}}mean-variance adaptive Gauss-Hermite quadrature;
the default{p_end}
{synopt :{opt gh:ermite}}nonadaptive Gauss-Hermite quadrature{p_end}
{synopt :{opt mc:arlo}}Monte-Carlo integration using Halton sequences or anti-thetic sampling; see details{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 29 tabbed}{...}
{marker adaptopts}{...}
{synopthdr :adaptopts}
{synoptline}
{synopt: [{cmd:{ul:no}}]{opt lo:g}}whether to display the iteration log
for each numerical integral calculation{p_end}
{synopt: {opt iterate(#)}}number of iterations to update integration points; default {cmd:1001}{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 29 tabbed}{...}
{synopthdr :Reporting}
{synoptline}
{synopt:{opt showmerlin}}display the {helpb merlin} syntax used to fit the model{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stmixed}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
Weights are not currently supported.{p_end}
{p 4 6 2}
Factor variables are not currently supported.{p_end}


{title:Description}

{pstd}
{cmd:stmixed} fits multilevel survival models including standard parametric distributions, 
flexible spline-based approaches (such as Royston-Parmar and the log hazard equivalent) 
and allows the user to specify their own hazard function. Simple or complex time-dependent effects can be included, 
with the addition of expected mortality for a relative survival model, and allowing for left-truncation/delayed entry. 
{it:t}-distributed random effects can also be used instead of the default Gaussian.
{p_end}

{pstd}
See {helpb stmixed postestimation} for a variety of predictions and residuals that can be 
calculated following a model fit.
{p_end}

{phang}
{cmd:stmixed} is part of the {helpb merlin} family.


{title:Options}

{dlgtab:Model}

{phang}
{opt noconstant} suppresses the constant (intercept) term and may be specified for the fixed effects equation and for the random effects equations.
{p_end}

{phang}
{opt distribution(string)} specifies the survival distribution.

{pmore}
{cmd:distribution(exponential)} fits an exponential survival model.

{pmore}
{cmd:distribution(weibull)} fits a Weibull survival model.

{pmore}
{cmd:distribution(gompertz)} fits a Gompertz survival model.

{pmore}
{cmd:distribution(rp)} fits a Royston-Parmar survival model. This is a highly flexible fully parametric 
alternative to the Cox model, modelled on the log cumulative hazard scale using restricted cubic splines. 

{pmore}
{cmd:distribution(rcs)} fits a log hazard scale flexible parametric survival model. This is a highly flexible 
fully parametric alternative to the Cox model, modelled on the log hazard scale using restricted cubic splines. 

{pmore}
{cmd:distribution(user)} specify a user-defined survival model; see options below and 
{helpb merlin_user:merlin user-defined functions}.

{phang}
{opt df(#)} specifies the degrees of freedom for the restricted cubic spline function used for the baseline 
function under a {cmd:rp} or {cmd:rcs} survival model. {it:#} must be between 1 and 10, but usually a value 
between 1 and 5 is sufficient. 
The {cmd:knots()} option 
is not applicable if the {cmd:df()} option is specified. The knots are placed at the following centiles of 
the distribution of the 
uncensored log survival times:

        {hline 60}
        df  knots        Centile positions
        {hline 60}
         1    0    (no knots)
         2    1    50
         3    2    33 67
         4    3    25 50 75
         5    4    20 40 60 80
         6    5    17 33 50 67 83
         7    6    14 29 43 57 71 86
         8    7    12.5 25 37.5 50 62.5 75 87.5
         9    8    11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9
        10    9    10 20 30 40 50 60 70 80 90     
        {hline 60}
        
{pmore}
Note that these are {it:interior knots} and there are also boundary knots
placed at the minimum and maximum of the distribution of uncensored survival
times. 

{phang}
{opt knots(numlist)} specifies knot locations for the baseline distribution function under a 
{cmd:rp} or {cmd:rcs} survival model, as opposed to the default 
locations set by {cmd:df()}. Note that the locations of the knots are placed on the standard time scale. 
However, the scale used by the restricted cubic spline 
function is always log time. Default knot positions are determined by the {cmd:df()} option.

{phang}
{opt tvc(varlist)} gives the name of the variables that have time-varying coefficients.
Time-dependent effects are fitted using restricted cubic splines. The degrees of freedom are 
specified using the {opt dftvc()} option. 

{phang}
{opt dftvc(df_list)} gives the degrees of freedom for time-dependent effects
in {it:df_list}. The potential degrees of freedom are listed under the
{opt df()} option. With 1 degree of freedom a linear effect of log time is fitted.
If there is more than one time-dependent effect and different degress of freedom
are requested for each time-dependent effect then the following syntax applies:

{phang}
{opt knotstvc(knotslist)} defines numlist {it:knotslist} as the location
of the interior knots for time-dependent effects. 

{phang}
{opt bhazard(varname)} specifies the variable which contains the expected mortality rate, which invokes a 
relative survival model.

{phang}{opt covariance(vartype_list)}, where each {it:vartype} is

{phang3}
{cmd:diagonal}{c |}{cmd:exchangeable}{c |}{cmd:identity}{c |}{cmd:unstructured}

{pmore}
specifies the structure of the covariance
matrix for the random effects. An {cmd:diagonal} covariance structure allows a distinct
variance for each random effect within a random-effects equation and 
assumes that all covariances are zero.  {cmd:exchangeable} covariances
have common variances and one common pairwise covariance.  {cmd:identity}
is short for "multiple of the identity"; that is, all variances are equal
and all covariances are zero.  {cmd:unstructured} allows for
all variances and covariances to be distinct.  If an equation consists of
{it:p} random-effects terms, the {cmd:unstructured} covariance matrix will have
{it:p}({it:p}+1)/2 unique parameters.

{pmore}
{cmd:covariance(diagonal)} is the default.

{dlgtab:Integration}

{phang}
{opt intmethod(intmethod)},
{opt intpoints(#)}, and
{opt adaptopts(adaptopts)}
        affect how integration for the latent variables is numerically
        calculated.

{pmore}
        {opt intmethod(intmethod)} specifies the method and defaults
        to {cmd:intmethod(mvaghermite)}.  The current implementation uses mean-variance adaptive quadrature 
		at the highest level, and non-adaptive at lower levels. Sometimes it is useful to fall back
        on the less computationally intensive and less accurate
        {cmd:intmethod(ghermite)} and then perhaps use one of the other more accurate
        methods.  

{pmore}
        {cmd:intmethod(mcarlo)} tells {cmd:merlin} to use Monte-Carlo integration, which either uses Halton 
		sequences with normally-distributed random effects, or anti-thetic random draws with {it:t}-distributed 
		random effects.

{pmore}
        {opt intpoints(#)} specifies the number of integration points
        to use and defaults to {cmd:intpoints(7)} with {cmd:intmethod(mvaghermite)} or {cmd:intmethod(ghermite)}, 
		and {cmd:intpoints(150)} with {cmd:intmethod(mcarlo)}.  Increasing the number
        increases accuracy but also increases computational time.
        Computational time is roughly proportional to the number specified.

{pmore}
        {opt adaptopts(adaptopts)} affects the adaptive part of
        adaptive quadrature (another term for numerical integration) and
        thus is relevant only for {cmd:intmethod(mvaghermite)}.

{pmore}
        {cmd:adaptopts()} defaults to
        {cmd:adaptopts(nolog iterate(1001))}.

{pmore}
[{cmd:no}]{cmd:log}
        specifies whether iteration logs are shown each
        time a numerical integral is calculated.

{pmore}
{cmd:iterate(#)} specifies the number of iterations to update the 
		integration points, which will include updating prior to iteration {cmd:0} in 
		the maximisation process.

{dlgtab:Estimation}

{phang}
{opt from(matname)} allows you to specify starting values.

{phang}
{opt restartvalues(sv_list)} allows you to specify starting values for specific random effect variances. See 
{helpb merlin_estimation:merlin estimation} for further details.

{phang}
{opt apstartvalues(#)} allows you to specify a starting value for all ancillary parameters, i.e those defined by 
using the {cmd:nap()} option. 

{phang}
{opt zeros} tells {cmd:merlin} to use {cmd:0} for all parameters starting values, rather than fit the fixed effect model. Both {cmd:restartvalues()} 
and {cmd:apstartvalues()} can be used with {cmd:zeros}.

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems.

{dlgtab:Reporting}

{phang}
{opt showmerlin} displays the {cmd:merlin} syntax used to fit the model.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.


{title:Example 1}

{pstd}This is a simulated example dataset representing a multi-centre trial scenario, with 100 centres and each centre recuiting 60 patients, resulting in 
6000 observations. Two covariates were collected, a binary covariate {bf:x1} (coded 0/1), and a continuous covariate, {bf:x2}, within the range [0,1].{p_end}

{pstd}Load dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stmixed_example1":. use http://fmwww.bc.edu/repec/bocode/s/stmixed_example1}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stime, f(event=1)":. stset stime, f(event=1)}{p_end}

{pstd}We fit a mixed effect survival model, with a random intercept and Weibull distribution, adjusting for fixed effects of {bf:x1} and {bf:x2}.{p_end}
{phang}{stata "stmixed x1 x2 || centre: , dist(weibull)":. stmixed x1 x2 || centre: , dist(weibull)}{p_end}


{title:Example 2}

{pstd}This is a simulated example dataset representing an individual patient data meta-analysis, with 15 trials and each trial recuiting 200 patients, resulting in 
3000 observations. We are interested in the pooled treatment effect, accounting for heterogeneity between trials.{p_end}

{pstd}Load dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stmixed_example2":. use http://fmwww.bc.edu/repec/bocode/s/stmixed_example2}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stime, f(event=1)":. stset stime, f(event=1)}{p_end}

{pstd}Create dummy variables for trial membership:{p_end}
{phang}{stata "tab trial, gen(trialvar)":. tab trial, gen(trialvar)}{p_end}

{pstd}We fit a flexible parametric model with 3 degress of freedom for the baseline, proportional trial effects with trial = 1 as the reference, 
and a random treatment effect.{p_end}
{phang}{stata "stmixed treat trialvar2-trialvar15 || trial: treat, nocons dist(rp) df(3)":. stmixed treat trialvar2-trialvar15 || trial: treat, nocons dist(rp) df(3)}{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Biostatistics Research Group{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}Leicester, UK{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
{cmd:Crowther MJ}, Riley RD, Staessen JA, Wang J, Gueyffier F, Lambert PC. Individual patient data meta-analysis of survival data using Poisson regression models. {it:BMC Med Res Methodol} 2012;{bf:12}:34.
{p_end}

{phang}
{cmd:Crowther MJ}, Look MP, Riley RD. Multilevel mixed effects parametric survival models using adaptive Gauss-Hermite quadrature with application to recurrent events and IPD meta-analysis. {it:Statistics in Medicine} 2014;(In Press).
{p_end}

{phang}
{cmd:Crowther MJ}. Extended multivariate generalised linear and non-linear mixed effect models. 2017; {it:Under review}.
{p_end}


