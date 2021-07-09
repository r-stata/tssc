{smcl}
{* *! version 0.1.0  ?????2017}{...}
{vieweralsosee "merlin model description options" "help merlin_models"}{...}
{vieweralsosee "merlin estimation options" "help merlin_estimation"}{...}
{vieweralsosee "merlin reporting options" "help merlin_reporting"}{...}
{vieweralsosee "merlin postestimation" "help merlin_postestimation"}{...}
{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{helpb merlin} {hline 2}}Command syntax for model specification{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:merlin} ({it:model1}) [({it:model2})] [...] [, {bf:covariance()}]

{pstd}
where the syntax of a {it:model} is

{p 8 12 2}
[{depvar}] [{it:component1}] [{it:component2}] [...] {ifin} [, {it:{help merlin_models##model_options:model_options}}]

{pmore}
where the syntax of a {it:component} is

{pmore2}
{it:element1}[{bf:#}{it:element2}][{bf:#}{it:element3}][...][@{it:real}]

{pmore2}
and each {it:elementn} can take one of the forms described in {it:{help merlin_models##elements:element}}, 
with {it:@{it:real}} described in {it:{help merlin_models##elements_details:elements details}}.


{synoptset 25}{...}
{marker model_options}{...}
{synopthdr:model_options}
{synoptline}
{synopt :{cmd: family({it:{help merlin_models##family:family}})}}distributional family{p_end}
{synopt :{opth timevar(varname)}}time variable{p_end}
{synopt :{opt nocons:tant}}omit the constant term{p_end}
{synopt :{opt nap(#)}}number of ancillary parameters to estimate{p_end}
{synoptline}

{synoptset 25}{...}
{marker family}{...}
{synopthdr:family}
{synoptline}
{synopt :{opt gau:ssian}}Gaussian (normal){p_end}
{synopt :{opt bern:oulli}}Bernoulli{p_end}
{synopt :{opt bet:a}}beta{p_end}
{synopt :{opt p:oisson}}Poisson{p_end}
{synopt :{opt nb:inomial}}negative binomial with mean dispersion{p_end}
{synopt :{opt ol:ogit}}ordinal response with logit link{p_end}
{synopt :{opt op:robit}}ordinal response with probit link{p_end}
{synopt :{opt gam:ma}}gamma distribution{p_end}
{synopt :{opt lq:uantile}{cmd: [, }{opt q:uantile(#)}{cmd:]}}linear quantile model with asymmetric Laplace distribution{p_end}
{synopt :{opt e:xponential}{cmd: [, {it:{help merlin_models##survival:survival}}]}}exponential{p_end}
{synopt :{opt go:mpertz}{cmd: [, {it:{help merlin_models##survival:survival}}]}}Gompertz{p_end}
{synopt :{cmd: rp [, {it:{help merlin_models##survival:survival}} {it:{help merlin_models##rpopts:rpopts}}]}}Royston-Parmar model on the log cumulative hazard scale{p_end}
{synopt :{cmd: loghazard [, {it:{help merlin_models##survival:survival}}]}}general log hazard model{p_end}
{synopt :{cmd: logchazard [, {it:{help merlin_models##survival:survival}}]}}general log cumulative hazard model{p_end}
{synopt :{opt w:eibull}{cmd: [, {it:{help merlin_models##survival:survival}}]}}Weibull{p_end}
{synopt :{cmd: user [, {it:{help merlin_models##user:user}} {it:{help merlin_models##survival:survival}}]}}user-defined{p_end}
{synopt :{opt null}}does not contribute to the log-likelihood; see details{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker survival}{...}
{synopthdr:survival}
{synoptline}
{synopt :{opth fail:ure(varname)}}indicator for failure event{p_end}
{synopt :{opth li:nterval(varname)}}lower interval time for interval censored observations{p_end}
{synopt :{opth lt:runcated(varname)}}entry time for left-truncated/delayed-entry model{p_end}
{synopt :{opth bh:azard(varname)}}expected mortality rate at event times, invokes a relative survival model{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker rpopts}{...}
{synopthdr:rpopts - family(rp)}
{synoptline}
{synopt :{opth df(#)}}degrees of freedom for the baseline log cumulative hazard function{p_end}
{synopt :{opt knots(knots_list)}}knot locations for the baseline log cumulative hazard function - includes 
boundary knots, should be in increasing order.{p_end}
{synopt :{opt scale(scale)}}which scale to fit the model on; only {cmd:scale(hazard)} is currently supported, meaning the log cumulative hazard scale{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker user}{...}
{synopthdr:user}
{synoptline}
{synopt :{opt llfunction(fnc_name)}}Mata function name which returns the observation-level log likelihood contribution{p_end}
{synopt :{opt loghfunction(fnc_name)}}Mata function name which returns the observation-level log hazard function{p_end}
{synopt :{opt hfunction(fnc_name)}}Mata function name which returns the observation-level hazard function{p_end}
{synopt :{opt chfunction(fnc_name)}}Mata function name which returns the observation-level cumulative hazard function{p_end}
{synoptline}
{p2colreset}{...}
{pstd}See {helpb merlin_user:merlin user-defined functions}.


{synoptset 25}{...}
{marker elements}{...}
{synopthdr:element}
{synoptline}
{synopt :{opt {varname}}}a variable in the dataset{p_end}
{synopt :{bf:M}#{cmd:[}{it:levelvar...}{cmd:]}}a random effect at the specified level; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{cmd: fp(}{it:varname}, {help merlin_models##fpopts:{it:fp_opts}}{cmd:)}}a fractional polynomial function of {it:varname}{p_end}
{synopt :{cmd: rcs(}{it:varname}, {help merlin_models##rcs_opts:{it:rcs_opts}}{cmd:)}}a restricted cubic spline function of {it:varname}{p_end}
{synopt :{cmd: bs(}{it:varname}, {help merlin_models##bsopts:{it:bs_opts}}{cmd:)}}a {it:B}-spline function of {it:varname}{p_end}
{synopt :{opt mf(function_name)}}a user-defined Mata function; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt EV[{depvar}|#]}}expected value of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt dEV[{depvar}|#]}}d/dt of expected value of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt d2EV[{depvar}|#]}}d2/dt2 of expected value of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt iEV[{depvar}|#]}}integral w.r.t time of the expected value of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt XB[{depvar}|#]}}expected value of the complex predictor of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt dXB[{depvar}|#]}}d/dt of the expected value of the complex predictor of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt d2XB[{depvar}|#]}}d2/dt2 of the expected value of the complex predictor of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synopt :{opt iXB[{depvar}|#]}}integral w.r.t time of the expected value of the complex predictor of another outcome; see {it:{help merlin_models##elements_details:{it:details}}}{p_end}
{synoptline}
{pstd}More detailed descriptions can be found in {it:{help merlin_models##elements_details:{bf:elements details}}}

{synoptset 25}{...}
{marker fpopts}{...}
{synopthdr:fp_opts}
{synoptline}
{synopt :{opth pow:ers(#)}}powers of the fractional polynomial; up to 2 degress can be used{p_end}
{synopt :{opth off:set(varname)}}to add before the fractional polynomial is calculated{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker rcs_opts}{...}
{synopthdr:rcs_opts}
{synoptline}
{synopt :{opth df(#)}}degrees of freedom for the spline function; see details{p_end}
{synopt :{opt knots(knots_list)}}knot locations for the spline function, including boundary knots{p_end}
{synopt :{opt orthog}}use Gram-Schmidt orthogonalisation on the spline variables{p_end}
{synopt :{opt event}}when using {cmd:df()}, calculate internal knot locations based on centiles of the observations that had an event (i.e. for survival models){p_end}
{synopt :{opt log}}calculate splines of the log of {it:varname}, rather than {it:varname}{p_end}
{synopt :{opth off:set(varname)}}to add before the spline function is calculated{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker bsopts}{...}
{synopthdr:bs_opts}
{synoptline}
{synopt :{opth order(#)}}order of the {it:B}-spline function; see details{p_end}
{synopt :{opth degree(#)}}degree of the {it:B}-spline function; see details{p_end}
{synopt :{opth df(#)}}degrees of freedom for the spline function; see details{p_end}
{synopt :{opt knots(knots_list)}}internal knot locations for the spline function{p_end}
{synopt :{opt bknots(knots_list)}}boundary knot locations for the spline function{p_end}
{synopt :{opt event}}when using {cmd:df()}, calculate knot locations based on centiles of the observations that had an event (i.e. for survival models){p_end}
{synopt :{opt log}}calculate splines of the log of {it:varname}, rather than {it:varname}{p_end}
{synopt :{opt int:ercept}}include the intercept basis function{p_end}
{synopt :{opth off:set(varname)}}to add before the spline function is calculated{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The command syntax of {cmd:merlin} is fully specified by the {it:models} and the {bf:covariance()} option. 

{pstd}
For full details and many tutorials, take a look at the accompanying website: 
{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}{cmd: family({it:{help merlin_models##family:family}})} distributional family{p_end}

{phang}{opth timevar(varname)} specifies the variable which represents time, and which will be used in conjunction with 
elements. If you are modelling time-dependent effects in a survival analysis, for example, then {cmd:timevar()} should 
match the response variable. 

{phang}{opt noconstant} suppresses the constant (intercept) term in the extended linear predictor.

{phang}{opt nap(#)} specifies any ancillary parameters to be estimated. To be used in conjunction with a {cmd:family(user)} model, 
or an {cmd:mf()} element, to be able the user to estimate any additional parameters required.


{marker elements_details}{...}
{dlgtab:Elements}

{phang}Elements are the fundamental flexibility of {helpb merlin}. Each {it:component} can have any number of {it:elements}. 
Elements within the same {it:component} are split using a {cmd:#}. Each {it:element} can be one of the following:

{phang2}{opt {varname}} a variable in the dataset. Any of Stata's {cmd:.} notation is not currently supported.

{phang2}{bf:M}#{cmd:[}{it:levelvar...}{cmd:]} a random effect at the specified level.

{p 12 12 2}{bf:M}# defines a random effect, which must begin with {cmd:M}, and be followed by a positive integer

{p 12 12 2}{it:levelvar} defines the cluster variables, for example, {cmd:M1[level1]} defines a random effect called {cmd:M1} 
at {cmd:level1}, and {cmd:M2[level1>level2]} defines a random effect called {cmd:M2} at {cmd:level2} which is nested within {cmd:level1}.
{* {phang2}{cmd: {f(&t)}} a user-defined function of time {bf:&t}. The function must be written in Mata code using colon {cmd::} notation }
{* (for element by element operations), and enclosed within braces {cmd:{}}. {cmd:timevar()} is also required.}

{phang2}{cmd:fp(}{it:varname}, {help merlin_models##fpopts:{it:fp_opts}}{cmd:)} specifies a fractional polynomial function of {it:varname}. {it:fp_opts} includes:

{phang3}{opt powers(numlist)} can be any within the following 
{-2, -1, -0.5, 0, 0.5, 1, 2, 3}. Fractional polynomials of degree 1 and 2 are allowed.

{phang3}{opt offset(varname)} defines an offset to be added to the {cmd:fp()} variable prior to the fractional polynomial being derived.

{phang2}{cmd:rcs(}{it:varname}, {help merlin_models##rcsopts:{it:rcs_opts}}{cmd:)} a restricted cubic spline function of {it:varname}, where {it:rcs_opts} are:

{p 12 16 2}{cmd:df(#)} specifies the degrees of freedom for the spline function. Boundary knots are assumed to be the min and max of 
the {it:varname}. Internal knots are placed at equally spaced centiles.

{p 12 16 2}{cmd:knots(numlist)} specifies the knot locations, which includes the boundary knots. Must be in ascending order.

{p 12 16 2}{cmd:log} use splines of log {it:varname} rather than {it:varname}, the default.

{p 12 16 2}{cmd:orthog} orthogonalise the spline terms.

{p 12 16 2}{cmd:event} can be used in combination with {cmd:df()} and specifies that the internal knots are calculated 
based on centiles of event times. Only valid when the {cmd:family()} is a survival model.

{phang3}{opt offset(varname)} defines an offset to be added to the {cmd:rcs()} variable prior to the spline function being derived.

{phang2}{cmd:bs(}{it:varname}, {help merlin_models##bsopts:{it:bs_opts}}{cmd:)} a {it:B}-spline function of {it:varname}, where {it:bs_opts} are:

{p 12 16 2}{cmd:order(#)} specifies the order of the spline function. 

{p 12 16 2}{cmd:degree(#)} specifies the degree of the spline function. 

{p 12 16 2}{cmd:df(#)} specifies the degrees of freedom (not strictly speaking) for the spline function, which allows you to specify 
internal knots at equally spaced centiles, instead of using {cmd:knots}. {cmd:df()} is consistent with {cmd:rcs()} elements in how internal knots 
are chosen.

{p 12 16 2}{cmd:knots(numlist)} specifies the internal knot locations. Must be in ascending order.

{p 12 16 2}{cmd:bknots(numlist)} specifies the lower and upper boundary knot locations. 
Must be in ascending order. Default is the minimum and maximum of {it:varname}.

{p 12 16 2}{cmd:log} use splines of log {it:varname} rather than {it:varname}, the default.

{p 12 16 2}{cmd:intercept} includes the intercept basis function, which by default is not included.

{p 12 16 2}{cmd:event} can be used in combination with {cmd:df()} and specifies that the internal knots are calculated 
based on centiles of event times. Only valid when the {cmd:family()} is a survival model.

{phang3}{opt offset(varname)} defines an offset to be added to the {cmd:rcs()} variable prior to the spline function being derived.

{phang2}{opt mf(function_name)} a user-defined Mata function. It should be defined as follows:

{p 12 16 2}
{it: real matrix} function_name(gml , {it:real colvector} t)
{p_end}
{p 12 16 2}
{
{p_end}
{p 16 20 2}
{it:some code}
{p_end}
{p 12 16 2}
}
{p_end}

{p 12 12 2}Any of the utility functions can be used, which gives the user complete flexibility. 
See {helpb merlin_user:merlin user-defined functions} for further details on writing a Mata function 
compatible with {helpb merlin}.{p_end}

{phang2}{opt EV[{depvar}|#]} expected value of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}.

{phang2}{opt dEV[{depvar}|#]} d/dt of expected value of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The derivative is calculated using numerical differentiation.

{phang2}{opt d2EV[{depvar}|#]} d2/dt2 of expected value of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The second derivative is calculated using numerical differentiation.

{phang2}{opt iEV[{depvar}|#]} integral w.r.t time of the expected value of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The integral is calculated using numerical integration.

{phang2}{opt XB[{depvar}|#]} expected value of the main complex predictor of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}.

{phang2}{opt dXB[{depvar}|#]} d/dt of expected value of the main complex predictor of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The derivative is calculated using numerical differentiation.

{phang2}{opt d2XB[{depvar}|#]} d2/dt2 of expected value of the main complex predictor of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The second derivative is calculated using numerical differentiation.

{phang2}{opt iXB[{depvar}|#]} integral w.r.t time of the expected value of the main complex predictor of a model (other than the current one). Use the appropriate {depvar} to refer to 
the desired model, or the model number # can be used (which may be needed if the model being referenced has {cmd:family(null)}. 
May also require {cmd:timevar()}. The integral is calculated using numerical integration.

{phang2}{bf:@}{it:real} specifies a constraint to be applied to all elements of the component. This is generally used in combination with random 
effects, i.e to specify a random intercept, one would type {cmd:M1[id]@1}, which would constrain the coefficient of the random effect 
{cmd:M1} to be 1. Without the {cmd:@1}, {cmd:merlin} would attempt to estimate a coefficient.


{dlgtab:Familys}

{phang}{opt family(family)} specifies the distributional family. The inbuilt distributions listed above are self explanatory. 
Some special cases include

{phang2}{cmd: family(lquantile [, quantile(#)])} specifies a linear quantile model utilising the asymmetric Laplace distribution for the particular {cmd:quantile(#)}, 
where {cmd:#} must be between 0 and 1. The default is {cmd:quantile(0.5)}. In my experience, these models are very difficult to fit reliably. 
I recommend you explore different integration techniques through {cmd:intmethod()}, along with increasing {cmd:intpoints()}, 
and most importantly vary your starting values with {cmd:from()}.

{phang2}{cmd: family(user, {it:{help merlin_models##user:user}})} which can take the following forms

{p 12 12 2}{cmd: family(user, llfunction(}{it:fnc_name}{cmd:))} defines a Mata function which returns the observation level log 
likelihood contribution of a user-defined distributional model. 

{p 12 12 2}{cmd: family(user, hfunction(}{it:fnc_name}{cmd:))} specifies a user-defined survival model, by defining a Mata 
function which returns the observation-level hazard function. The cumulative hazard is calculated using numerical 
quadrature, which means our cumulative hazard need not have a closed-form solution, such as when using splines of fractional 
polynomials to model the baseline log hazard function.

{p 12 12 2}{cmd: family(user, hfunction(}{it:fnc_name}{cmd:)} {cmd:chfunction(}{it:fnc_name}{cmd:))} specifies a user-defined 
survival model, by defining Mata functions which return the observation-level hazard and cumulative hazard functions.

{p 12 12 2}
See {helpb merlin_user:merlin user-defined functions} for further details on writing a Mata function compatible with {helpb merlin}.

{phang2}{cmd:family(null)} tells {cmd: merlin} that theres is no {depvar} in the {it:extended_lin_pred}, and that 
this {it:model} does not contribute to the log likelihood. It is a convenient way of specifying a further extended linear 
predictor for use within one (or more) distributional model(s). 


{dlgtab:Survival}

{phang}{opth failure(varname)} specifies the censoring/failure event. Should be coded 0 for right-censored observations, 
1 for exactly observed events, or 2 for interval-censored observations.

{phang}{opth linterval(varname)} specifies the lower interval for interval censored observations. The upper interval 
should be specified in the response variable for the model. Observations that are right censored or events should 
be coded as missing.

{phang}{opth ltruncated(varname)} specifies the time at which observations become at risk of the event. Allows 
fitting a delayed-entry survival model. If there are random effects in the associated survival model, then 
the likelihood is calculated by dividing through by the marginal survival function at the entry times, which results 
in a second set of numerical integration.

{phang}{opth bhazard(varname)} invokes a relative survival model, by specifying the expected mortality (event) rate in the reference population at the observed event times.


{dlgtab:Royston-Parmar options}

{phang}{opt df(#)} degrees of freedom for the baseline log cumulative hazard function, i.e. number of restricted cubic 
spline terms. Internal knots are placed at centiles of the event times. Boundary knots are placed at the minimum and maximum event times.

{phang}{opt knots(knots_list)} defines the knot locations for the spline functions used to model the baseline 
log cumulative hazard function. Must include boundary knots. Knots should be specified in increasing order.


{title:Examples}

{phang}
For detailed examples, see {bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.


{title:Author}

{p 5 12 2}
{bf:Michael J. Crowther}{p_end}
{p 5 12 2}
Biostatistics Research Group{p_end}
{p 5 12 2}
Department of Health Sciences{p_end}
{p 5 12 2}
University of Leicester{p_end}
{p 5 12 2}
michael.crowther@le.ac.uk{p_end}


{title:References}

{p 5 12 2}
Crowther MJ. Extended multivariate generalised linear and non-linear mixed effect models. 2017; {it:Submitted}.{p_end}

