{smcl}
{* *! version 1.3.0 02Feb2012}{...}
{hline}
{cmd:help stjm11} {right:also see: {helpb stjm11 postestimation}, {helpb stjmgraph}}
{hline}

{title:Title}

{p2colset 5 15 18 2}{...}
{p2col :{hi:stjm11} {hline 2}}Joint modelling of longitudinal and survival data{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: stjm11} {it:longdepvar} [{varlist}] {ifin} {cmd:,} {opt p:anel(varname)} {opth survm:odel(stjm11##survsubmodel:survsubmodel)} [{it:options}]


{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt p:anel(varname)}}panel identification variable{p_end}
{synopt:{opth survm:odel(stjm11##survsubmodel:survsubmodel)}}survival submodel{p_end}

{syntab:Longitudinal sub-model}
{synopt:{opt ffracp:oly(numlist)}}fixed powers of time{p_end}
{synopt:{opt rfracp:oly(numlist)}}fixed and random powers of time{p_end}
{synopt:{opt timeinterac:tion(varlist)}}covariates to interact with fixed time variables{p_end}
{synopt :{opth cov:ariance(stjm11##vartype:vartype)}}variance-covariance structure of the random effects{p_end}

{syntab:Survival sub-model}
{synopt:{opt survc:ov(varlist)}}fixed baseline covariates to be included in the survival submodel{p_end}
{synopt:{opt df(#)}}degrees of freedom for baseline hazard function{p_end}
{synopt:{opt knots(numlist)}}knot locations for baseline hazard function{p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of spline variables{p_end}

{syntab:Association}
{synopt:{opt noc:urrent}}association not based on the current value of longitudinal response{p_end}
{synopt:{opt derivassoc:iation}}association based on the first derivative (slope) of the longitudinal submodel{p_end}
{synopt:{opt intassoc:iation}}allow association to be based on the random intercept{p_end}
{synopt:{opt assoc:iation(numlist)}}allow association to be based on the random coefficient of a time variable{p_end}
{synopt:{opt assoccov:ariates(varlist)}}adjust the association parameter(s) by covariates{p_end}

{syntab:Maximisation}
{synopt:{opt gh(#)}}number of Gauss-Hermite quadrature points{p_end}
{synopt:{opt gk(#)}}number of Gauss-Kronrod quadrature points{p_end}
{synopt:{opt adaptit(#)}}the number of adaptive Gauss-Hermite quadrature iterations; default is 3{p_end}
{synopt:{opt nonadapt}}use non-adaptive Gauss-Hermite quadrature{p_end}
{synopt:{opt fulldata}}use all data in survival component maximisation, see details{p_end}
{synopt:{opt nulla:ssoc}}sets the initial values for association parameters to be zero{p_end}
{synopt :{it:{help stjm11##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{syntab:Reporting}
{synopt:{opt showinit:ial}}display output from initial value model fits{p_end}
{synopt:{opt var:iance}}show random-effects parameter estimates as variances-covariances{p_end}
{synopt:{opt showc:ons}}list constraints in output{p_end}
{synopt:{opt keepc:ons}}do not drop constraints used in ml routine{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{marker survsubmodel}{...}
{synopthdr :survsubmodel}
{synoptline}
{synopt :{opt e:xponential}}exponential survival submodel{p_end}
{synopt :{opt w:eibull}}Weibull survival submodel{p_end}
{synopt :{opt g:ompertz}}Gompertz survival submodel{p_end}
{synopt :{opt fpm}}flexible parametric survival submodel{p_end}
{synoptline}

{marker vartype}{...}
{synopthdr :vartype}
{synoptline}
{synopt :{opt ind:ependent}}one variance parameter per random effect, all covariances zero{p_end}
{synopt :{opt ex:changeable}}equal variances for random effects, and one common pairwise covariance{p_end}
{synopt :{opt id:entity}}equal variances for random effects, all covariances zero; the default for factor variables{p_end}
{synopt :{opt un:structured}}all variances and covariances distinctly estimated; the default{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
{it:longdepvar} specifies the longitudinal continuous response variable. {p_end}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stjm11}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
See {helpb stjm11 postestimation} for features available after estimation. {p_end}


{title:Description}

{pstd}
{cmd:stjm11} fits shared parameter joint models for longitudinal and survival data using maximum likelihood. A single continuous longitudinal response and a single survival outcome are allowed. 
A linear mixed effects model is used for the longitudinal submodel, which lets time be modelled using fixed and/or random fractional polynomials. Four choices are 
currently available for the survival submodel; the first being the flexible parametric survival model (see {help stpm2}), modelled on the log cumulative hazard scale. 
The remaining choices include the exponential, Weibull and Gompertz proportional hazard models. The association between the two processes can be induced via the default 
current value parameterisation, the first derivative of the longitudinal submodel, and/or a random coefficient such as the intercept. Adaptive Gauss-Hermite quadrature, 
coded in Mata, is used to evaluate the joint likelihood. Under an exponential/Weibull/Gompertz survival submodel, Gauss-Kronrod quadrature is used to evaluate the 
cumulative hazard. The dataset must be {cmd:stset} correctly into enter and exit times, using the enter option; see {manhelp stset ST}. {cmd:stjm11} uses {cmd:_t0} to 
denote measurement times. For example, below we have 3 patients with 2, 5 and 3 measurements each, respectively.{p_end}

		{hline 33}
		id    _t0    _t   _d    long_resp
		{hline 33}
		 1    0     0.2    0         0.93
		 1    0.2   0.7    0         1.32
		 2    0     0.5    0         1.15
		 2    0.5   1.2    0         1.67
		 2    1.2   1.6    0         1.92
		 2    1.6   1.9    0         2.65
		 2    1.9   2.6    1         3.15
		 3    0     2      0         0.25
		 3    2     2.3    0         0.21
		 3    2.3   2.4    1         0.31
		{hline 33}

{pstd} 
Delayed entry joint models can be fitted, allowing age to be used as the timescale. Delayed entry models may also be executed 
when the timescale is adjusted to allow fractional polynomials of time when {cmd:_t0} = 0.{p_end}


{title:Options}

{phang}
{opt panel(varname)} defines the panel identification variable. Each panel should be identified by a unique integer.

{phang}
{opt survmodel(survsubmodel)} specifies the survival submodel to be fit. 

{pmore}
{cmd:survmodel(fpm)} fits a flexible parametric survival submodel. This is a highly flexible fully parametric alternative to the Cox 
model, modelled on the log cumulative hazard scale using restricted cubic splines. For more details see {help stpm2}.

{pmore}
{cmd:survmodel(exponential)} fits an exponential survival submodel. This is modelled on the hazard scale. 

{pmore}
{cmd:survmodel(weibull)} fits a Weibull survival submodel. This is modelled on the hazard scale. 

{pmore}
{cmd:survmodel(gompertz)} fits a Gompertz survival submodel. This is modelled on the hazard scale. 

{dlgtab:Longitudinal sub-model}

{phang}
{opt ffracpoly(numlist)} specifies power transformations of the time variable, to be included in the longitudinal submodel 
as fixed covariates. _t0 is used as the time of measurements.

{phang}
{opt rfracpoly(numlist)} specifies power transformations of the time variable, to be included in the longitudinal submodel 
as fixed and random covariates. _t0 is used as the time of measurements.

{phang}
{opt timeinteraction(varlist)} covariates to interact with the fixed fractional polynomials of measurement time.

{phang}
{opt covariance(vartype)} specifies the variance-covariance structure of the random effects. 

{pmore}
{cmd:covariance(independent)} specifies a distinct variance for each random effect, with all covariances zero.

{pmore}
{cmd:covariance(exchangeable)} specifies equal variances for all random effects, and one common pairwise covariance. 

{pmore}
{cmd:covariance(identity)} specifies equal variances for all random effects, with all covariances zero. 

{pmore}
{cmd:covariance(unstructured)} specifies that all variances and covariances are distinctly estimated. 

{dlgtab:Survival sub-model}

{phang}
{opt survcov(varlist)} specifies covariates to be included in the survival submodel.

{phang}
{opt df(#)} specifies the degrees of freedom for the restricted cubic spline function used for the baseline function under a flexible 
parametric survival submodel. {it:#} must be between 1 and 10, but usually a value between 1 and 4 is sufficient, with 3 being the default. 
The {cmd:knots()} option is not applicable if the {cmd:df()} option is specified. The knots are placed at the following centiles of the 
distribution of the uncensored log survival times:

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
{opt knots(numlist)} specifies knot locations for the baseline distribution function under a flexible parametric survival submodel, as opposed 
to the default locations set by df(). Note that the locations of the knots are placed on the standard time scale.  However, the scale used by 
the restricted cubic spline function is always log time. Default knot positions are determined by the df() option.

{phang}
{cmd: noorthog} suppresses orthogonal transformation of spline variables under a flexible parametric survival submodel.

{dlgtab:Association}

{phang}
{opt nocurrent} specifies that the association between the survival and longitudinal submodels is not based on the current value. 
The default association is based on the current value of the longitudinal response.

{phang}
{opt derivassociation} specifies that the association between the survival and longitudinal submodels is based on the first derivative of 
the longitudinal submodel.

{phang}
{opt intassociation} specifies that the association between the survival and longitudinal submodels is based on the random intercept 
of the longitudinal submodel. 

{phang}
{opt association(numlist)} specifies that the association between the survival and longitudinal submodels is based on a random coefficient of
time fractional polynomials specified in {cmd:rfracpoly}.

{phang}
{opt assoccovariates(varlist)} covariates to include in the linear predictor of the association parameter(s). Under the default current value association, this corresponds to interacting the longitudinal submodel with covariates.

{dlgtab:Maximisation}

{phang}
{opt gh(#)} specifies the number of Gauss-Hermite quadrature nodes used to evaluate the integrals over the random effects. The defaults are 5 and 15 under adaptive and non-adaptive, respectively. 
Minimum number of quadrature points is 2.

{phang}
{opt gk(#)} specifies the number of Gauss-Kronrod quadrature nodes used to evaluate the cumulative hazard under an exponential/Weibull/Gompertz 
survival submodel. Two choices are available, namely 7 or 15, with the default 15.

{phang}
{opt adaptit(#)} defines the number of iterations of adaptive Gauss-Hermite quadrature to use in the maximisation process, with the default 3. 
Adaptive quadrature is implemented at the beginning of each full Newton-Raphson iteration.{p_end}

{phang}
{opt nonadapt} use non-adaptive Gauss-Hermite quadrature to evaluate the joint likelihood. This will generally require a much higher number of nodes, {cmd:gh}, 
to ensure accurate estimates and standard errors, resulting in much greater computation time.{p_end}

{phang}
{opt fulldata} forces {cmd:stjm11} to use all rows of data in the survival component of the likelihood. By default, {cmd:stjm11} assesses whether all covariates specified in 
{cmd:survcov()} are constant within panels, and if they are, only needs to use the first row of {cmd:_t0} and the final row of {cmd:_t} in the maximisation process 
providing considerable speed advantages.{p_end}

{phang}
{opt nullassoc} sets the initial value for association parameters to be zero. Use of the default initial values may in rare situations 
cause {cmd:stjm11} to display {it: initial values not feasible}; using this option solves this, however, convergence time is generally longer.{p_end}

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, {opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}. These options are seldom used, but the {opt difficult} option may be useful 
if there are convergence problems.

{dlgtab:Reporting}

{phang}
{opt showinitial} displays the output from the {help xtmixed} and {help stpm2} or {help streg} models fitted to obtain initial values for {cmd:stjm11}.

{phang}
{opt variance} show random-effects parameter estimates as variances-covariances{p_end}

{phang}
{opt showcons} displays the constraints used by {help stpm2} and {cmd:stjm11} for the derivatives of the spline function. This option is only valid 
under a flexible parametric survival submodel.

{phang}
{opt keepcons} prevents the constraints imposed by {cmd:stjm11} on the derivatives of the spline function when fitting delayed entry models being dropped. 
By default, the constraints are dropped. This option is only valid under a flexible parametric survival submodel.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.


{title:Remarks}

{pstd} 
1. A random intercept is always assumed in each {cmd:stjm11} call. 

{pstd}
2. Measurement time must be exclusively controlled through the options {cmd:ffracpoly}, {cmd:rfracpoly} and {cmd:timeinteraction}, and not included as 
fixed covariates in either submodel through [{it:varlist}] or {cmd:survcov(}{it:varlist}{cmd:)}.

{pstd}
3. As with all survival models with multiple-record {cmd:st} data, time-varying covariates can be included in each submodel.

{pstd}
4. Estimation is performed by maximum likelihood. Optimisation uses the default technique {cmd:nr}, meaning Stata's version of Newton-Raphson iterations.

{pstd} 
5. If convergence issues arise, try specifying the {cmd:nullassoc} option and/or increasing the number of Gauss-Hermite nodes, {cmd:gh}. Users may also wish to vary the number of adaptive quadrature iterations.

{pstd}
6. As with all models which use numerical integration, the number of quadrature nodes should be increased to establish the stability of the estimates.

{pstd}
7. Note that under a flexible parametric survival sub-model, if more than one random effect is specified then survival sub-model coefficients are interpreted as proportional 
cumulative hazard ratios. In this case the equivalency between proportional cumulative hazard ratios and proportional hazards ratios does not hold.{p_end}

{dlgtab:Intermittant missing data}

{pstd}
If intermittent missing data is present in any covariates, for example:{p_end}

		{hline 33}
		id    _t0    _t   _d    long_resp
		{hline 33}
		 1    0     0.2    0         0.93
		 1    0.2   0.7    0         1.32
		 2    0     0.5    0         1.15
		 2    0.5   1.2    0         .
		 2    1.2   1.6    0         .
		 2    1.6   1.9    0         2.65
		 2    1.9   2.6    1         3.15
		 3    0     2      0         0.25
		 3    2     2.3    0         0.21
		 3    2.3   2.4    1         0.31
		{hline 33}

{pstd}
then care must be taken to ensure the appropriate rows of data are included in the survival component of the joint likelihood. By default, {cmd:stjm} assesses
whether all covariates included in {cmd:survcov()} are constant within panels, and if they are, only has to use the first row of {cmd:_t0} and the final row of 
{cmd:_t} for the survival likelihood component. However, if they are not, or the {cmd:fulldata} option is used, then all rows are included, as with 
multiple-record {cmd:st} data. 
{p_end}

{pstd}
For example, if we were to use the {cmd:fulldata} option when analysing the data in the above Table, then patient 2's survival contribution would be missing between 
times {cmd:_t0 = 0.5} and {cmd:_t = 1.6}. However, the correct contribution would be made by using only the first row of {cmd:_t0} and final row of {cmd:_t}.
{p_end}

{pstd}
{cmd:stjm} displays a warning when this situation is detected. The simplest way of avoiding this is to remove any missing data before using {cmd:stset}.
{p_end}


{title:Example 1: Simulated dataset}

{pstd}Load simulated example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_example":. use http://fmwww.bc.edu/repec/bocode/s/stjm_example}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Explore the joint data with a joint plot:{p_end}
{phang}{stata "stjmgraph long_response, panel(id)":. stjmgraph long_response, panel(id)}{p_end}

{pstd}Joint model with a random intercept and fixed slope in the longitudinal submodel, a flexible parametric survival submodel with 3 degrees of freedom, 
and association based on the current value. No covariates in either submodel.{p_end}
{phang}{stata "stjm11 long_response, panel(id) survmodel(fpm) df(3) ffracpoly(1)":. stjm11 long_response, panel(id) survmodel(fpm) df(3) ffracpoly(1)}{p_end}

{pstd}Joint model with a random intercept and fixed slope in the longitudinal submodel, a Weibull survival submodel, adjusting for treatment in the survival submodel and the interaction between treatment 
and measurement time in the longitudinal submodel. Current value association.{p_end}
{phang}{stata "stjm11 long_response, panel(id) survmodel(weibull) ffracpoly(1) survcov(trt) timeinterac(trt)":. stjm11 long_response trt, panel(id) survmodel(weibull) ffracpoly(1) survcov(trt) timeinterac(trt)}{p_end}

{pstd}Joint model with a random intercept and random slope in the longitudinal submodel, a Weibull survival submodel, and adjusting for treatment in both submodels. 
Risk of event dependent on the current value and the first derivative of the longitudinal submodel.{p_end}
{phang}{stata "stjm11 long_response trt, panel(id) survmodel(weibull) rfracpoly(1) survcov(trt) derivassoc":. stjm11 long_response trt, panel(id) survmodel(weibull) rfracpoly(1) survcov(trt) derivassoc}{p_end}


{title:Example 2: Primary Biliary Cirrhosis dataset}

{pstd}This example dataset contains 1945 repeated measurements of serum bilirubin, from 312 patients with Primary Biliary Cirrhosis (PBC). Patients received treatment of D-penicillamine or placebo. 
In all analyses we use the log of serum bilirubin.{p_end}

{pstd}Load PBC dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data":. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Explore the joint data with a joint plot:{p_end}
{phang}{stata "stjmgraph logb, panel(id)":. stjmgraph logb, panel(id)}{p_end}

{pstd}Joint model with a random intercept and fixed slope in the longitudinal submodel, a Weibull survival submodel, 
and association based on the current value. We adjust for the interaction between treatment and fixed time in the longitudinal submodel, and treatment in the survival submodel.{p_end}
{phang}{stata "stjm11 logb, panel(id) survmodel(w) ffracpoly(1) timeinterac(trt) survcov(trt)":. stjm11 logb, panel(id) survmodel(w) ffracpoly(1) timeinterac(trt) survcov(trt)}{p_end}

{pstd}Joint model with a random intercept and random slope in the longitudinal submodel, a Weibull survival submodel, and association based on 
the current value. We adjust for the interaction between treatment and fixed time in the longitudinal submodel, and treatment in the survival 
submodel. We also adjust for the interaction between log serum bilirubin and treatment.{p_end}
{phang}{stata "stjm11 logb, panel(id) survmodel(w) rfracpoly(1) timeinterac(trt) survcov(trt) assoccov(trt)":. stjm11 logb, panel(id) survmodel(w) rfracpoly(1) timeinterac(trt) survcov(trt) assoccov(trt)}{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
Crowther, M. J. & Abrams, K. R. & Lambert, P. C. (2012). Flexible parametric joint modelling of longitudinal and survival data. (Under review).{p_end}

{phang}
Crowther, M. J. & Abrams, K. R. & Lambert, P. C. (2012). {browse "http://leicester.academia.edu/MichaelCrowther/Papers/1369569/Joint_modelling_of_longitudinal_and_survival_data":Joint modelling of longitudinal and survival data.} (Under review).
{p_end}

{phang}
Lambert, P. C. & Royston, P. {browse "http://www.stata-journal.com/article.html?article=st0165":Further development of flexible parametric models for survival analysis.} {it:The Stata Journal}, 2009, 9, 265-290.{p_end}

{phang}
Royston, P. & Altman, D. G. {browse "http://www.jstor.org/pss/2986270":Regression using fractional polynomials of continuous covariates: Parsimonious parametric modelling.} {it:JRSS Series C (Applied Statistics)}, 1994, 43, 429-467. {p_end}

{phang}
Wulfsohn, M. S. & Tsiatis, A. A. {browse "http://www.jstor.org/pss/2533118":A joint model for survival and longitudinal data measured with error.} {it:Biometrics}, 1997, 53, 330-339.{p_end}


{title:Also see}

{psee}
Online: {helpb stjm11 postestimation}, {helpb stjmgraph}, {helpb xtmixed}, {helpb streg}, {helpb stpm2} (if installed)
{p_end}
