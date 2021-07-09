{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "survsim" "help survsim"}{...}
{vieweralsosee "survsim user" "help survsim user"}{...}
{vieweralsosee "survsim model" "help survsim model"}{...}
{vieweralsosee "survsim msm" "help survsim msm"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "galahad" "help galahad"}{...}
{viewerjumpto "Syntax" "survsim parametric##syntax"}{...}
{viewerjumpto "Description" "survsim parametric##description"}{...}
{viewerjumpto "Options" "survsim parametric##options"}{...}
{viewerjumpto "Examples" "survsim parametric##examples"}{...}
{title:Title}

{p2colset 5 16 16 2}{...}
{p2col :{cmd:survsim} {hline 2}}Simulate survival data from a parametric distribution, 
a user-defined distribution, from a fitted {helpb merlin} model, from a cause-specific 
hazards competing risks model, or from a general multi-state model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax for simulating survival times from a parametric distribution:

{phang2}
{cmd: survsim} {it:newvarname1} [{it:newvarname2}] {cmd:,} {opt distribution(string)} [{help survsim parametric##options:{it:options}}]

{phang}
See {helpb survsim:help survsim} for more on simulating survival times in other settings.


{synoptset 36 tabbed}{...}
{marker options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:d:istribution(}{cmdab:e:xponential)}}exponential survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:gom:pertz)}}Gompertz survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:w:eibull)}}Weibull survival distribution{p_end}
{synopt:{opt l:ambdas(numlist)}}scale parameters{p_end}
{synopt:{opt g:ammas(numlist)}}shape parameters{p_end}
{synopt:{opt cov:ariates(varname # [# ...] ...)}}baseline covariates{p_end}
{synopt:{opt tde(varname # [# ...] ...)}}time-dependent effects{p_end}
{synopt:{opt maxt:ime(#|varname)}}right censoring time(s); either a common number or a {varname}{p_end}
{synopt:{opt lt:runcated(#|varname)}}left truncation time(s) (delayed entry); either a common number or a {varname}{p_end}

{syntab:2-component mixture}
{synopt:{opt mix:ture}}simulate survival times from a 2-component mixture model{p_end}
{synopt:{opt pm:ix(real)}}mixture parameter, default is 0.5{p_end}
{synopt:{opt nodes(#)}}number of Gauss-Legendre quadrature nodes, default 30; see details{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{helpb survsim} simulates survival data from a parametric distribution, a user-defined distribution, from a fitted 
{helpb merlin} model, from a cause-specific hazards competing risks model, or from a Markov multi-state model. 
This help file centres on the parametric distribution setting.
{p_end} 
{pstd}
Survival times can be simulated from standard parametric distributions including the exponential, Gompertz and Weibull, 
and 2-component mixtures of them. Baseline covariates can be included, with specified associated log hazard ratios. 
Non-proportional hazards can also be included with all models; under an exponential or Weibull model covariates are interacted 
with log time, under a Gompertz model covariates are interacted with time. See 
{help survsim parametric##paper1:Crowther and Lambert (2012)} for more details.
{p_end}

{pstd}
{it:newvarname1} specifies the new variable name to contain the generated survival times. {it:newvarname2} is required when 
the {cmd:maxtime()} option is specified which defines the time(s) of right censoring. 
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt distribution}({it:string}) specifies the parametric survival distribution to use, including {cmd:exponential}, 
{cmd:gompertz} or {cmd:weibull}.{p_end}

{phang}{opt lambdas(numlist)} defines the scale parameters in the exponential/Weibull/Gompertz distribution(s). The number of 
values required depends on the model choice. Default is a single number corresponding to a standard parametric distribution. 
Under a {cmd:mixture} model 2 values are required.{p_end}

{phang}{opt gammas(numlist)} defines the shape parameters of the Weibull/Gompertz parametric distribution(s). Number of 
entries must be equal to that of {cmd:lambdas}.{p_end}

{phang}{opt covariates(varname # ...)} defines baseline covariates to be included in the linear predictor of the 
survival model, along with the value of the corresponding coefficient. For example, a treatent variable coded 0/1 can be 
included, with a log hazard ratio of 0.5, by {cmd:covariates(treat 0.5)}. Variable {cmd:treat} must be in the dataset before 
{cmd:survsim} is called. {p_end}

{phang}{opt tde(varname # ...)} creates non-proportional hazards by interacting covariates with log time for an 
exponential or Weibull model, or time under a Gompertz model or mixture model. Values should be entered as 
{cmd:tde(trt 0.5)}, for example. Multiple time-dependent effects can be specified, but they will all be interacted with 
the same function of time.

{phang}{opt maxtime(#|varname)} specifies the right censoring time(s). Either a common maximum follow-up time {cmd:#} can be 
specified for all observations, or observation specific censoring times can be specified by using a {varname}. {p_end}

{phang}{opt ltruncated(#|varname)} specifies the left truncated/delayed entry time(s). Either a common time {cmd:#} can be 
specified for all observations, or observation specific left truncation times can be specified by using a {varname}. {p_end}

{dlgtab:Mixture model}

{phang}{opt mixture} specifies that survival times are simulated from a 2-component mixture model, with mixture component 
distributions defined by {cmd:distribution()}. {cmd:lambdas()} and {cmd:gammas()} must be of length 2.{p_end}

{phang}{opt pmix(#)} defines the mixture parameter. Default is 0.5.{p_end}

{phang}{opt nodes(#)} defines the number of Gauss-Legendre quadrature points used to evaluate the cumulative hazard function 
when {cmd:mixture} {it:and} {cmd:tde()} are specified together. To simulate survival times from such a mixture model, a combination 
of numerical integration and root-finding is used. The default is {cmd:nodes(30)}. {p_end}


{title:Remarks}

{pstd}
When simulating from a {cmd:mixture} model, covariate effects are additive on the log hazard scale, and are applied to the overall 
hazard function, rather than each mixture component.
{p_end}

{pstd}When simulating from a {cmd:mixture} model with time-dependent effects, numerical integration is used to evaluate the 
cumulative hazard function, within iterations of Brent's univariate root finder. As with all model frameworks which use 
numerical integration, it is important to assess the stability of the simulated survival times with an increasing number 
of integration points, through use of the {cmd:nodes()} option. Any {cmd:survsim} call that requires Brent's method is 
executed under a tolerance of 1e-08, to ensure accurracy of the simulated survival times. {p_end}

{pstd}Always {helpb set seed}, to ensure reproducibility.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Generate times from a Weibull model including a binary treatment variable, with log hazard ratio = -0.5, and censoring 
after 5 years:{p_end}
{phang}{stata "set obs 1000":. set obs 1000}{p_end}
{phang}{stata "gen trt = rbinomial(1,0.5)":. gen trt = rbinomial(1,0.5)}{p_end}
{phang}{stata "survsim stime1 died1, distribution(weibull) lambdas(0.1) gammas(1.5) covariates(trt -0.5) maxtime(5)":. survsim stime1 died1, distribution(weibull) lambdas(0.1) gammas(1.5) covariates(trt -0.5) maxtime(5)}{p_end}
{phang}{stata "stset stime1, failure(died1 = 1)":. stset stime1, failure(died1 = 1)}{p_end}
{phang}{stata "streg trt, distribution(weibull) nohr":. streg trt, distribution(weibull) nohr}{p_end}

{pstd}Generate times from a Gompertz model:{p_end}
{phang}{stata "survsim stime2, distribution(gompertz) lambdas(0.1) gammas(0.05)":. survsim stime2, distribution(gompertz) lambdas(0.1) gammas(0.05)}{p_end}

{pstd}Generate times from a 2-component mixture Weibull model:{p_end}
{phang}{stata "survsim stime3 died3, mixture distribution(weibull) lambdas(0.1 0.05) gammas(1 1.5) pmix(0.5) maxtime(5)":. survsim stime3 died3, mixture distribution(weibull) lambdas(0.1 0.05) gammas(1 1.5) pmix(0.5) maxtime(5)}{p_end}

{pstd}Generate times from a Weibull model with diminishing treatment effect:{p_end}
{phang}{stata "survsim stime4, distribution(weibull) lambdas(0.1) gammas(1.5) covariates(trt -0.5) tde(trt 0.05)":. survsim stime5, distribution(weibull) lambdas(0.1) gammas(1.5) covariates(trt -0.5) tde(trt 0.05)}{p_end}

{pstd}For more examples please see {help survsim parametric##paper2:Crowther and Lambert (2013)}.{p_end}


{title:Author}

{pstd}{cmd:Michael J. Crowther}{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}Please report any errors you may find.{p_end}


{title:References}

{phang}Bender R, Augustin T and Blettner M. Generating survival times to simulate Cox proportional hazards models. {it:Statistics in Medicine} 2005;24:1713-1723.{p_end}

{marker paper1}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://www.stata-journal.com/article.html?article=st0275":Simulating complex survival data.}{it: The Stata Journal} 2012;12(4):674-687.{p_end}

{marker paper2}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.5823/abstract":Simulating biologically plausible complex survival data.} {it:Statistics in Medicine} 2013;32(23):4118-4134.{p_end}

{phang}Jann, B. 2005. moremata: Stata module (Mata) to provide various functions. Available from http://ideas.repec.org/c/boc/bocode/s455001.html.{p_end}

