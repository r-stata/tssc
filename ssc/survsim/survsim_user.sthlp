{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "survsim" "help survsim"}{...}
{vieweralsosee "survsim parametric" "help survsim parametric"}{...}
{vieweralsosee "survsim model" "help survsim model"}{...}
{vieweralsosee "survsim msm" "help survsim msm"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "galahad" "help galahad"}{...}
{viewerjumpto "Syntax" "survsim user##syntax"}{...}
{viewerjumpto "Description" "survsim user##description"}{...}
{viewerjumpto "Options" "survsim user##options"}{...}
{viewerjumpto "Examples" "survsim user##examples"}{...}
{title:Title}

{p2colset 5 16 16 2}{...}
{p2col :{cmd:survsim} {hline 2}}Simulate survival data from a parametric distribution, 
a user-defined distribution, from a fitted {helpb merlin} model, from a cause-specific 
hazards competing risks model, or from a general multi-state model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax for simulating survival times from a user-defined distribution:

{phang2}
{cmd: survsim} {it:newvarname1} {it:newvarname2} {cmd:,} {opt maxt:ime(#|varname)} [{help survsim user##options:{it:options}}]

{phang}
See {helpb survsim:help survsim} for more on simulating survival times in other settings.


{synoptset 36 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt logh:azard(string)}}user-defined log baseline hazard function; see details{p_end}
{synopt:{opt h:azard(string)}}user-defined baseline hazard function; see details{p_end}
{synopt:{opt logch:azard(string)}}user-defined log cumulative baseline hazard function; see details{p_end}
{synopt:{opt ch:azard(string)}}user-defined baseline cumulative hazard function; see details{p_end}
{synopt:{opt cov:ariates(varname # [# ...] ...)}}baseline covariates{p_end}
{synopt:{opt tde(varname # [# ...] ...)}}time-dependent effects{p_end}
{synopt:{opt tdefunc:tion(string)}}function of time to interact with covariates specified in {bf:tde()}; see details{p_end}
{synopt:{opt maxt:ime(#|varname)}}right censoring time(s); either a common number or a {varname}{p_end}
{synopt:{opt lt:runcated(#|varname)}}left truncation time(s) (delayed entry); either a common number or a {varname}{p_end}
{synopt:{opt nodes(#)}}number of Gauss-Legendre quadrature nodes, default 30{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{helpb survsim} simulates survival data from a parametric distribution, a user-defined distribution, from a fitted 
{helpb merlin} model, from a cause-specific hazards competing risks model, or from a Markov multi-state model. 
This help file centres on the user-defined distribution setting.
{p_end} 
{pstd}
Survival times can be simulated from bespoke, user-defined [log] [cumulative] hazard functions. The function must be specified 
in Mata code (using colon operators), with survival times generated using a combination of numerical integration and root 
finding techniques. Baseline covariates can be included, with specified associated log hazard ratios. Time-dependent effects 
can also be specified with a user-defined function of time. See {help survsim user##paper2:Crowther and Lambert (2013)} for more 
details.
{p_end}

{pstd}
{it:newvarname1} specifies the new variable name to contain the generated survival times. {it:newvarname2} specifies the 
new variable name to contain the generated event indicator. 
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt loghazard(string)} is the user-defined log hazard function. The function can include:{p_end} 
{synoptset 15 notes}{...}
{synopt:{cmd:{t}}} which denotes the main timescale, measured on the time since starting state, {cmd:startstate()}, 
timescale (which may be {cmd:ltruncated()}){p_end}
{synopt:{cmd:varname}} which denotes a variable in your dataset{p_end}
{synopt:{cmd:+-*/^}} standard Mata mathematical operators, using colon notation i.e. {cmd:2 :* {t}}, see 
{helpb help [M-2] op_colon}. Colon operators must be used as behind the scenes, {cmd:{t}} gets replaced by an 
{cmd:_N} x {cmd:nodes()} matrix when numerically integrating the hazard function.{p_end}
{synopt:{it:mata_function}} any Mata function, e.g. {cmd:log()} and {cmd:exp()}{p_end}
{p2colreset}{...}

{phang2}See {help survsim user##examples:examples} below.

{phang}{opt hazard(string)} is the user-defined baseline hazard function. See {cmd:loghazard()} for more details, and 
{help survsim user##examples:examples} below.{p_end}

{phang}{opt logchazard(string)} is the user-defined log cumulative baseline hazard function. See {cmd:loghazard()} for 
more details, and {help survsim user##examples:examples} below.{p_end}

{phang}{opt chazard(string)} is the user-defined baseline cumulative hazard function. See {cmd:loghazard()} for more 
details, and {help survsim user##examples:examples} below.{p_end}

{phang}{opt covariates(varname # [# ...] ...)} defines baseline covariates to be included in the linear predictor of the 
survival model, along with the value of the corresponding coefficient. For example, a treatent variable coded 0/1 can be 
included, with a log hazard ratio of 0.5, by {cmd:covariates(treat 0.5)}. Variable {cmd:treat} must be in the dataset before 
{cmd:survsim} is called. If {cmd:chazard()} or {cmd:logchazard()} are used, then {cmd:covariates()} effects are additive 
on the log cumulative hazard scale.{p_end}

{phang}{opt tde(varname # [# ...] ...)} creates non-proportional hazards by interacting covariates with a function of time, 
defined by {cmd:tdefunction()}, on the appropriate log hazard or log cumulative hazard scale. Values should be entered as 
{cmd:tde(trt 0.5)}, for example. Multiple time-dependent effects can be specified, but they will all 
be interacted with the same {cmd:tdefunction()}. To circumvent this, you can directly specify them in your user function.

{phang}{opt tdefunction(string)} defines the function of time to which covariates specified in {cmd:tde()} are interacted 
with, to create time-dependent effects. The default is {cmd:{t}}, i.e. linear time. 
The function can include:{p_end} 
{synoptset 15 notes}{...}
{synopt:{cmd:{t}}} which denotes the main timescale, measured on the time since starting state, {cmd:startstate()}, 
timescale (which may be {cmd:ltruncated()}){p_end}
{synopt:{cmd:+-*/^}} standard Mata mathematical operators, using colon notation i.e. {cmd:2 :* {t}}, see 
{helpb help [M-2] op_colon}. Colon operators must be used as behind the scenes, {cmd:{t}} gets replaced by an 
{cmd:_N} x {cmd:nodes()} matrix when numerically integrating the hazard function.{p_end}
{synopt:{it:mata_function}} any Mata function, e.g. {cmd:log()} and {cmd:exp()}{p_end}
{p2colreset}{...}


{phang}{opt maxtime(#|varname)} specifies the right censoring time(s). Either a common maximum follow-up time {cmd:#} can be 
specified for all observations, or observation specific censoring times can be specified by using a {varname}. {p_end}

{phang}{opt ltruncated(#|varname)} specifies the left truncated/delayed entry time(s). Either a common time {cmd:#} can be 
specified for all observations, or observation specific left truncation times can be specified by using a {varname}. {p_end}

{phang}{opt nodes(#)} defines the number of Gauss-Legendre quadrature points used to evaluate the cumulative hazard function 
when {cmd:loghazard()} or {cmd:hazard()} is specified. To simulate survival times from such a function, a combination 
of numerical integration and root-finding is used. The default is {cmd:nodes(30)}.{p_end}


{title:Remarks}

{pstd}When simulating from a user-defined {cmd:loghazard()} or {cmd:hazard()} function, numerical integration is used to 
evaluate the cumulative hazard function, within iterations of Brent's univariate root finder. As with all model frameworks 
which use numerical integration, it is important to assess the stability of the simulated survival times with an increasing 
number of integration points, through use of the {cmd:nodes()} option. Any {cmd:survsim} call that requires Brent's method 
is executed under a tolerance of 0, to ensure accurracy of the simulated survival times. {p_end}

{pstd}Always {helpb set seed}, to ensure reproducibility.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Simulate 1000 observations and generate a binary treatment group:{p_end}
{phang}{cmd:. set obs 1000}{p_end}
{phang}{cmd:. gen trt = rbinomial(1,0.5)}{p_end}

{pstd}Generate times from user-defined log hazard function:{p_end}
{phang}{cmd:. survsim stime1 died1, loghazard(-1 :+ 0.02:*{t} :- 0.03:*{t}:^2 :+ 0.005:*{t}:^3) maxtime(1.5)}{p_end}

{pstd}Generate times from user-defined log hazard function with diminishing treatment effect:{p_end}
{phang}{cmd:. survsim stime2 died2, loghazard(-1 :+ 0.02:*{t} :- 0.03:*{t}:^2 :+ 0.005:*{t}:^3) covariates(trt -0.5) tde(trt 0.03) maxtime(1.5)}{p_end}

{pstd}Generate survival times from a joint longitudinal-survival model:{p_end}
{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 1000}{p_end}
{phang}{cmd:. gen trt = rbinomial(1,0.5)}{p_end}
{phang}{cmd:. gen age = rnormal(65,12)}{p_end}
{pstd}Define the association between the biomarker and survival{p_end}
{phang}{cmd:. local alpha = 0.25}{p_end}
{pstd}Generate the random intercept and random slopes for the longitudinal submodel{p_end}
{phang}{cmd:. gen b0 = rnormal(0,1)}{p_end}
{phang}{cmd:. gen b1 = rnormal(1,0.5)}{p_end}
{pstd}Generate survival times from an exponential baseline hazard{p_end}
{phang}{cmd:. survsim st1 event, loghazard(`=log(0.1)' :+ `alpha' :* (b0 :+ b1 :* {t})) maxtime(5) covariates(trt -0.5 age 0.02)}{p_end}
{pstd}Generate observed biomarker values at times 0, 1, 2, 3 , 4 years{p_end}
{phang}{cmd:. gen id = _n}{p_end}
{phang}{cmd:. expand 5}{p_end}
{phang}{cmd:. bys id: gen meastime = _n-1}{p_end}
{pstd}Remove observations after event or censoring time{p_end}
{phang}{cmd:. bys id: drop if meastime >= st1}{p_end}
{pstd}Generate observed biomarker values incorporating measurement error{p_end}
{phang}{cmd:. gen response = b0 + b1*meastime + rnormal(0,0.5)}{p_end}

{pstd}For more examples please see {help survsim user##paper2:Crowther and Lambert (2013)}.{p_end}


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

