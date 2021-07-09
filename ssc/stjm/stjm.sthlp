{smcl}
{* *! version 2.1.0 29jul2013}{...}
{vieweralsosee "stjm postestimation" "help stjm postestimation"}{...}
{vieweralsosee "stjmgraph" "help stjmgraph"}{...}
{vieweralsosee "xtmixed" "help xtmixed"}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stgenreg" "help stgenreg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{vieweralsosee "stmix" "help stmix"}{...}
{viewerjumpto "Syntax" "stjm##syntax"}{...}
{viewerjumpto "Description" "stjm##description"}{...}
{viewerjumpto "Options" "stjm##options"}{...}
{viewerjumpto "Examples" "stjm##examples"}{...}
{title:Title}

{p2colset 5 13 16 2}{...}
{p2col :{hi:stjm} {hline 2}}Joint modelling of longitudinal and survival data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd: stjm} {it:longdepvar} [{varlist}] {ifin} {cmd:,} {opt p:anel(varname)} {opth survm:odel(stjm##survsubmodel:survsubmodel)} [{it:options}]

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt p:anel(varname)}}panel identification variable{p_end}
{synopt:{opth survm:odel(stjm##survsubmodel:survsubmodel)}}survival submodel{p_end}

{syntab:Longitudinal sub-model}
{synopt:{opt ffp(numlist)}}fixed powers of time{p_end}
{synopt:{opt rfp(numlist)}}fixed and random powers of time{p_end}
{synopt:{opt frcs(#)}}degrees of freedom for fixed splines of time{p_end}
{synopt:{opt rrcs(#)}}degrees of freedom for random splines of time{p_end}
{synopt:{opt timeinterac:tion(varlist)}}covariates to interact with fixed time variables{p_end}
{synopt :{opth cov:ariance(stjm##vartype:vartype)}}variance-covariance structure of the random effects{p_end}

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
{synopt:{opt nocoef:ficient}}do not include fixed coefficient when using {bf:intassociation} or {bf:association()}{p_end}

{syntab:Maximisation}
{synopt:{opt gh(#)}}number of Gauss-Hermite quadrature points{p_end}
{synopt:{opt gk(#)}}number of Gauss-Kronrod quadrature points{p_end}
{synopt:{opt gl(#)}}number of Gauss-Legendre quadrature points{p_end}
{synopt:{opt adaptit(#)}}the number of adaptive Gauss-Hermite quadrature iterations; default is 5{p_end}
{synopt:{opt showa:dapt}}display the adaptive quadrature sub-iterations{p_end}
{synopt:{opt atol(#)}}tolerance for the log-likelihood under the adaptive quadrature sub-iterations, default is 1.0E-05{p_end}
{synopt:{opt nonadapt}}use non-adaptive Gauss-Hermite quadrature{p_end}
{synopt:{opt fulldata}}use all data in survival component maximisation, see details{p_end}
{synopt:{opt nulla:ssoc}}sets the initial values for association parameters to be zero{p_end}
{synopt:{opt noxtem}}suppresses the default {cmd:emonly} option used in the {manhelp xtmixed XT} call for initial values{p_end}
{synopt :{it:{help stjm##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

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
{synopt :{opt rcs}}restricted cubic spline (log hazard scale) survival submodel{p_end}
{synopt :{opt fpm}}flexible parametric survival submodel{p_end}
{synopt :{opt weibw:eib}}Mixture Weibull-Weibull survival submodel{p_end}
{synopt :{opt weibe:xp}}Mixture Weibull-exponential survival submodel{p_end}
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
You must {cmd:stset} your data before using {cmd:stjm}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
See {helpb stjm postestimation} for features available after estimation. {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stjm} fits shared parameter joint models for longitudinal and survival data using maximum likelihood. A single continuous longitudinal response 
and a single survival outcome are allowed. A linear mixed effects model is used for the longitudinal submodel, which lets time be modelled 
using fixed and/or random polynomials or resticted cubic splines. Seven choices are currently available for the survival submodel, 
including the exponential, Weibull, Gompertz, 2-component mixture Weibull-Weibull, 2-component mixture Weibull-exponential proportional 
hazards models. Restricted cubic splines on the log hazard scale (see {help stgenreg}) is also available. Finally, the flexible parametric survival model (see {help stpm2}), 
modelled on the log cumulative hazard scale is also available. The association between the two processes can be induced via the default current value 
parameterisation, the first derivative of the longitudinal submodel (slope), and/or a random coefficient such as the intercept. Adaptive or non-adaptive 
Gauss-Hermite quadrature, coded in Mata, can be used to evaluate the joint likelihood. Under all survival submodels except the flexible parametric model, 
Gauss-Kronrod or Gauss-Legendre quadrature can be used to evaluate the cumulative hazard. The dataset must be stset correctly into enter and exit times, 
using the enter option; see {manhelp stset ST}. {cmd:stjm} uses {cmd:_t0} to denote measurement times. For example, below we have 3 patients with 2, 5 and 3 
measurements each, respectively.{p_end}

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


{marker options}{...}
{title:Options}

{phang}
{opt panel(varname)} defines the panel identification variable. Each panel should be identified by a unique integer.

{phang}
{opt survmodel(survsubmodel)} specifies the survival submodel to be fit. 

{pmore}
{cmd:survmodel(exponential)} fits an exponential survival submodel.

{pmore}
{cmd:survmodel(weibull)} fits a Weibull survival submodel.

{pmore}
{cmd:survmodel(gompertz)} fits a Gompertz survival submodel.

{pmore}
{cmd:survmodel(rcs)} fits a restricted cubic spline survival submodel, with log time expanded into spline basis. This is modelled on the log hazard scale. 

{pmore}
{cmd:survmodel(weibweib)} fits a 2-component mixture Weibull-Weibull survival submodel.

{pmore}
{cmd:survmodel(weibexp)} fits a 2-component mixture Weibull-exponential survival submodel.

{pmore}
{cmd:survmodel(fpm)} fits a flexible parametric survival submodel. This is a highly flexible fully parametric alternative to the Cox 
model, modelled on the log cumulative hazard scale using restricted cubic splines. For more details see {help stpm2}.

{dlgtab:Longitudinal sub-model}

{phang}
{opt ffp(numlist)} specifies power transformations of the time variable, to be included in the longitudinal submodel 
as fixed covariates. _t0 is used as the time of measurements. Values must be in {-5, -4, -3, -2, -1, -0.5, 0, 0.5, 1, 2, 3, 4, 5}.

{phang}
{opt rfp(numlist)} specifies power transformations of the time variable, to be included in the longitudinal submodel 
as fixed and random covariates. _t0 is used as the time of measurements. Values must be in {-5, -4, -3, -2, -1, -0.5, 0, 0.5, 1, 2, 3, 4, 5}.

{phang}
{opt frcs(#)} specifies the degrees of freedom of the time variable, expanding time into restricted cubic splines as fixed 
covariates. _t0 is used as the time of measurements. The default knot locations are described under {cmd:df()}.

{phang}
{opt rrcs(#)}  specifies the degrees of freedom of the time variable, expanding time into restricted cubic splines as random 
covariates. _t0 is used as the time of measurements. The default knot locations are described under {cmd:df()}.

{phang}
{opt timeinteraction(varlist)} covariates to interact with the fixed time components specified in {bf:ffp}/{bf:frcs}.

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
parametric survival submodel or a spline submodel on the log hazard scale. {it:#} must be between 1 and 10, but usually a value between 
1 and 4 is sufficient, with 3 being the default. The {cmd:knots()} option is not applicable if the {cmd:df()} option is specified. The 
knots are placed at the following centiles of the distribution of the uncensored log survival times:

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
{opt knots(numlist)} specifies knot locations for the baseline distribution function under a flexible parametric survival submodel, as opposed to the default locations set by df(). Note that the locations of the knots are placed on the standard time scale. 
However, the scale used by the restricted cubic spline function is always log time. Default knot positions are determined by the df() option.

{phang}
{cmd: noorthog} suppresses orthogonal transformation of spline variables under a flexible parametric survival submodel or a spline submodel on the log hazard scale.

{dlgtab:Association}

{phang}
{opt nocurrent} specifies that the association between the survival and longitudinal submodels is not based on the current value. 
The default association is based on the current value of the longitudinal response.

{phang}
{opt derivassociation} specifies that the association between the survival and longitudinal submodels is based on the first derivative of 
the longitudinal submodel.

{phang}
{opt intassociation} specifies that the association between the survival and longitudinal submodels is based on the random intercept 
of the longitudinal submodel. By default this includes the fixed intercept coefficient.

{phang}
{opt association(numlist)} specifies that the association between the survival and longitudinal submodels is based on a random coefficient of
time fractional polynomials specified in {cmd:rfracpoly}. By default this includes the fixed coefficient.

{phang}
{opt assoccovariates(varlist)} covariates to include in the linear predictor of the association parameter(s). Under the default current value association, this corresponds to interacting the longitudinal submodel with covariates.

{phang}
{opt nocoefficient} do not include the fixed coefficient when using {bf:intassociation} or {bf:association()}.

{dlgtab:Maximisation}

{phang}
{opt gh(#)} specifies the number of Gauss-Hermite quadrature nodes used to evaluate the integrals over the random effects. The defaults are 5 and 15 under adaptive and non-adaptive, respectively. 
Minimum number of quadrature points is 2.{p_end}

{phang}
{opt gk(#)} specifies the number of Gauss-Kronrod quadrature nodes used to evaluate the cumulative hazard under an exponential/Weibull/Gompertz 
survival submodel. Two choices are available, namely 7 or 15, with the default 15.{p_end}

{phang}
{opt gl(#)} specifies the number of Gauss-Legendre quadrature nodes used to evaluate the cumulative hazard under an exponential/Weibull/Gompertz 
survival submodel. This is an alternative to Gauss-Kronrod quadrature, where the user can specify any number of nodes >=5.{p_end}

{phang}
{opt adaptit(#)} defines the number of iterations of adaptive Gauss-Hermite quadrature to use in the maximisation process, with the default 5. 
Adaptive quadrature is implemented at the beginning of each full Newton-Raphson iteration.{p_end}

{phang}
{opt showadapt} display the log-likelihood values under the sub-iterations used to assess convergence of the adaptive quadrature 
implemented at the beginning of each full Newton-Raphson iteration.{p_end}

{phang}
{opt atol(#)} tolerance for the log-likelihood under adaptive quadrature sub-iterations, default is 1.0E-08.{p_end}

{phang}
{opt nonadapt} use non-adaptive Gauss-Hermite quadrature to evaluate the joint likelihood. This will generally require a much higher number of nodes, {cmd:gh}, 
to ensure accurate estimates and standard errors, resulting in much greater computation time.{p_end}

{phang}
{opt fulldata} forces {cmd:stjm} to use all rows of data in the survival component of the likelihood. By default, {cmd:stjm} assesses whether all covariates specified in 
{cmd:survcov()} are constant within panels, and if they are, only needs to use the first row of {cmd:_t0} and the final row of {cmd:_t} in the maximisation process 
providing considerable speed advantages.{p_end}

{phang}
{opt nullassoc} sets the initial value for association parameters to be zero. Use of the default initial values may in rare situations 
cause {cmd:stjm} to display {it: initial values not feasible}; using this option solves this, however, convergence time is generally longer.{p_end}

{phang}
{opt noxtem} suppresses the use of the {cmd:emonly} option in the {manhelp xtmixed XT} call uses to obtain initial values. By default, {cmd:emonly} is used which 
is often quicker and provides adequate starting values for the longitudinal component.{p_end}

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, {opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}. These options are seldom used, but the {opt difficult} option may be useful 
if there are convergence problems.

{dlgtab:Reporting}

{phang}
{opt showinitial} displays the output from the {manhelp xtmixed XT} and {manhelp streg ST}, {helpb stpm2} or {helpb stmix} models fitted to obtain initial values for {cmd:stjm}.

{phang}
{opt variance} show random-effects parameter estimates as variances-covariances{p_end}

{phang}
{opt showcons} displays the constraints used by {helpb stpm2} and {cmd:stjm} for the derivatives of the spline function. This option is only valid 
under a flexible parametric survival submodel.

{phang}
{opt keepcons} prevents the constraints imposed by {cmd:stjm} on the derivatives of the spline function when fitting delayed entry models being dropped. 
By default, the constraints are dropped. This option is only valid under a flexible parametric survival submodel.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.


{title:Remarks}

{pstd} 
1. A random intercept is always assumed in each {cmd:stjm} call. 

{pstd}
2. Measurement time must be exclusively controlled through the options {cmd:ffp()}, {cmd:rfp()}, {cmd:frcs()}, {cmd:rrcs()} and {cmd:timeinteraction()}, and not included as 
fixed covariates in either submodel through [{it:varlist}] or {cmd:survcov(}{it:varlist}{cmd:)}.

{pstd}
3. As with all survival models with multiple-record {cmd:st} data, time-varying covariates can be included in each submodel.

{pstd}
4. Estimation is performed by maximum likelihood. Optimisation uses the default technique {cmd:nr}, meaning Stata's version of Newton-Raphson iterations.

{pstd} 
5. If convergence issues arise, try specifying the {cmd:nullassoc} option and/or increasing the number of Gauss-Hermite nodes, {cmd:gh()}. Users may also wish to vary the number of adaptive quadrature iterations using {cmd:adaptit()}.

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


{marker examples}{...}
{title:Example 1: Simulated dataset}

{pstd}Load simulated example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_example":. use http://fmwww.bc.edu/repec/bocode/s/stjm_example}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Explore the joint data with a joint plot:{p_end}
{phang}{stata "stjmgraph long_response, panel(id)":. stjmgraph long_response, panel(id)}{p_end}

{pstd}Joint model with a random intercept and fixed slope in the longitudinal submodel, a flexible parametric survival submodel with 3 degrees of freedom, 
and association based on the current value. No covariates in either submodel.{p_end}
{phang}{stata "stjm long_response, panel(id) survmodel(fpm) df(3) ffp(1)":. stjm long_response, panel(id) survmodel(fpm) df(3) ffp(1)}{p_end}

{pstd}Joint model with a random intercept and fixed slope in the longitudinal submodel, a Weibull survival submodel, adjusting for treatment in the survival submodel and the interaction between treatment 
and measurement time in the longitudinal submodel. Current value association.{p_end}
{phang}{stata "stjm long_response, panel(id) survmodel(weibull) ffp(1) survcov(trt) timeinterac(trt)":. stjm long_response trt, panel(id) survmodel(weibull) ffp(1) survcov(trt) timeinterac(trt)}{p_end}

{pstd}Joint model with a random intercept and random slope in the longitudinal submodel, a Weibull survival submodel, and adjusting for treatment in both submodels. 
Risk of event dependent on the current value and the first derivative of the longitudinal submodel.{p_end}
{phang}{stata "stjm long_response trt, panel(id) survmodel(weibull) rfp(1) survcov(trt) derivassoc":. stjm long_response trt, panel(id) survmodel(weibull) rfp(1) survcov(trt) derivassoc}{p_end}


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
{phang}{stata "stjm logb, panel(id) survmodel(w) ffp(1) timeinterac(trt) survcov(trt)":. stjm logb, panel(id) survmodel(w) ffp(1) timeinterac(trt) survcov(trt)}{p_end}

{pstd}Joint model with a random intercept and random slope in the longitudinal submodel, a restricted cubic spline survival submodel with 3 degrees of freedom, 
and association based on the current value. We adjust for the interaction between treatment and fixed time in the longitudinal submodel, and treatment in the survival 
submodel. We also adjust for the interaction between log serum bilirubin and treatment.{p_end}
{phang}{stata "stjm logb, panel(id) survmodel(rcs) df(3) rfp(1) timeinterac(trt) survcov(trt) assoccov(trt)":. stjm logb, panel(id) survmodel(rcs) df(3) rfp(1) timeinterac(trt) survcov(trt) assoccov(trt)}{p_end}


{title:Example 3: Liver cirrhosis with repeated measures of prothrombin index}

{pstd}This example dataset contains 2968 repeated measurements of prothrombin index, from 488 patients with liver cirrhosis. Patients received treatment of prednisone or placebo.{p_end}

{pstd}Load dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_prothro":. use http://fmwww.bc.edu/repec/bocode/s/stjm_prothro}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Explore the joint data with a joint plot:{p_end}
{phang}{stata "stjmgraph pro, panel(id) lowess":. stjmgraph pro, panel(id) lowess}{p_end}

{pstd}Joint model with a random intercept and random slope in the longitudinal submodel, a mixture Weibull-exponential survival submodel, 
and association based on the current value. We adjust for treatment in the survival submodel.{p_end}
{phang}{stata "stjm pro, panel(id) survmodel(weibexp) rfp(1) survcov(trt)":. stjm pro, panel(id) survmodel(weibexp) rfp(1) survcov(trt)}{p_end}

{pstd}Joint model with a random intercept and fixed splines of time with 2 degrees of freedom in the longitudinal submodel, a mixture Weibull-Weibull survival submodel, and association based on 
the current value. We adjust for the interaction between treatment and fixed splines of time in the longitudinal submodel, and treatment in the survival 
submodel.{p_end}
{phang}{stata "stjm pro, panel(id) survmodel(weibweib) frcs(2) timeinterac(trt) survcov(trt)":. stjm pro, panel(id) survmodel(weibweib) frcs(2) timeinterac(trt) survcov(trt)}{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{pstd}Part of this work was conducted when MJC was on an internship at StataCorp. In particular, he would like to thank Yulia Marchenko, Jeff Pitblado, Alan Riley and Vince Wiggins.{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
Crowther MJ, Abrams KR and Lambert PC. {browse "http://dx.doi.org/10.1002/sim.5644":Flexible parametric joint modelling of longitudinal and survival data.}
 {it:Statistics in Medicine} 2012;31(30):4456-4471.{p_end}

{pstd}
Crowther MJ, Abrams KR and Lambert PC. {browse "http://www.stata-journal.com/article.html?article=st0289":Joint modelling of longitudinal and survival data.} 
{it:The Stata Journal} 2013;{bf:13}(1)165-184.
{p_end}

{phang}
Lambert PC and Royston P. {browse "http://www.stata-journal.com/article.html?article=st0165":Further development of flexible parametric models for survival analysis.} {it:The Stata Journal} 2009;9:265-290.{p_end}

{phang}
Rabe-Hesketh S, Skrondal A and Pickles A. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=st0005":Reliable estimation of generalized linear mixed models using adaptive quadrature.} {it:The Stata Journal} 2002;2:1-21.{p_end}

{phang}
Wulfsohn MS and Tsiatis AA. {browse "http://www.jstor.org/pss/2533118":A joint model for survival and longitudinal data measured with error.} {it:Biometrics} 1997;53:330-339.{p_end}

