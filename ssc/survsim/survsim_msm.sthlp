{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "survsim" "help survsim"}{...}
{vieweralsosee "survsim parametric" "help survsim parametric"}{...}
{vieweralsosee "survsim user" "help survsim user"}{...}
{vieweralsosee "survsim model" "help survsim model"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "galahad" "help galahad"}{...}
{viewerjumpto "Syntax" "survsim msm##syntax"}{...}
{viewerjumpto "Description" "survsim msm##description"}{...}
{viewerjumpto "Options" "survsim msm##options"}{...}
{viewerjumpto "Examples" "survsim msm##examples"}{...}
{title:Title}

{p2colset 5 16 16 2}{...}
{p2col :{cmd:survsim} {hline 2}}Simulate survival data from a parametric distribution, 
a user-defined distribution, from a fitted {helpb merlin} model, from a cause-specific 
hazards competing risks model, or from a general multi-state model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax for simulating survival times from a multi-state model:

{phang2}
{cmd: survsim} {it:timestub} {it:statestub} {it:eventstub} {cmd:,} {cmd:hazard1(}{help survsim cr##hazard_options:{it:haz_options}}{cmd:)} 
{cmd:hazard2(}{help survsim cr##hazard_options:{it:haz_options}}{cmd:)} {opt maxt:ime(#|varname)} 
[{opt transmat:rix(name)} {cmd:hazard3(}{help survsim cr##hazard_options:{it:haz_options}}{cmd:)} 
{cmd: ...} {help survsim cr##commonopts:{it:options}}]


{synoptset 36 tabbed}{...}
{synopthdr:Transition-specific hazard options}
{synoptline}
{synopt:{cmdab:d:istribution(}{cmdab:e:xponential)}}exponential survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:gom:pertz)}}Gompertz survival distribution{p_end}
{synopt:{cmdab:d:istribution(}{cmdab:w:eibull)}}Weibull survival distribution{p_end}
{synopt:{opt l:ambda(#)}}scale parameter for exponential, Weibull or Gompertz{p_end}
{synopt:{opt g:amma(#)}}shape parameter for Weibull or Gompertz{p_end}
{synopt:{opt user(function)}}user-defined hazard function, written in Mata code; see details{p_end}
{synopt:{opt cov:ariates(varname # [# ...] ...)}}baseline covariates{p_end}
{synopt:{opt tde(varname # [# ...] ...)}}time-dependent effects{p_end}
{synopt:{opt tdefunc:tion(string)}}function of time to interact with covariates specified in {bf:tde()}; see details{p_end}
{synopt:{opt reset}}clock-reset timescale, i.e. the timescale is reset to zero on state entry{p_end}
{synoptline}

{synopthdr:Options}
{synoptline}
{synopt:{opt transmat:rix(name)}}a transition matrix defining possible transitions between states{p_end}
{synopt:{opt maxt:ime(#|varname)}}right censoring time(s); either a common number or a {varname}{p_end}
{synopt:{opt startstate(#|varname)}}starting state for observations; either a common number or a {varname}{p_end}
{synopt:{opt lt:runcated(#|varname)}}starting time for observations, i.e. left truncation time(s); either a common number or a {varname}{p_end}
{synopt:{opt nodes(#)}}number of Gauss-Legendre quadrature nodes, default {cmd:nodes(30)}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{helpb survsim} simulates survival data from a parametric distribution, a user-defined distribution, from a fitted 
{helpb merlin} model, from a cause-specific hazards competing risks model, or from a multi-state model. 
This help file centres on simulating from a competing risks or multi-state model, specified using transition-specific 
hazard functions.
{p_end}

{pstd}
Each transition-specific hazard function can be specified as a standard parametric model, such as the exponential, Weibull or 
Gompertz distributions, or a user-defined bespoke hazard function written in Mata code. Baseline covariates can be included 
in each transition-specific hazard, with specified associated log hazard ratios. Non-proportional hazards can also be included. 
Transition-specific hazard models can be as similar, or as different, as required. Up to 50 transition-specific hazard 
functions may be specified.
{p_end}

{pstd}
From each potential starting state, event times are simulated from the overall, total hazard function, using the method of 
{help survsim cr##paper3:Beyersmann et al. (2009)}, i.e. the sum of all the transition-specific hazards out of the starting 
state. This is implemented using a combination of numerical integration and root finding techniques using the algorithm 
developed in {help survsim cr##paper2:Crowther and Lambert (2013)}.
{p_end}

{pstd}
{it:timestub} specifies the new variable name stub to contain the generated survival times for each transition. 
{it:statestub} specifies the new variable name stub to contain the generated state identifiers, i.e which state each observation 
has transitioned to/is in, at the associated times. {it:eventstub} specifies the new variable name stub to contain the 
event indicators, i.e. whether an event or right-censoring occurred at the associated times. When observations have 
reached an absorbing state, or reached {cmd:maxtime()}, they will have missing observations in any further generated variables. 
When all observations have reached an absorbing state, or are right-censored, then the simulation will cease and the generated 
variables are returned.
{p_end}


{marker options}{...}
{marker hazard_options}{...}
{title:Transition-specific hazard options}

{phang}{opt distribution}({it:string}) specifies the parametric survival distribution to use, including {cmd:exponential}, 
{cmd:gompertz} or {cmd:weibull}.{p_end}

{phang}{opt lambda(#)} defines the scale parameter for a exponential/Weibull/Gompertz distribution(s).{p_end}

{phang}{opt gamma(#)} defines the shape parameter for a Weibull/Gompertz parametric distribution(s).{p_end}

{phang}{opt user(function)} defines a custom hazard function. The function can include:{p_end} 
{synoptset 15 notes}{...}
{synopt:{cmd:{t}}} which denotes the main timescale, measured on the time since starting state, {cmd:startstate()}, 
timescale (which may be {cmd:ltruncated()}){p_end}
{synopt:{cmd:{t0}}} which denotes the time of entry to the current state of the associated transition hazard, measured on the 
time since initial starting state timescale{p_end}
{synopt:{cmd:varname}} which denotes a variable in your dataset{p_end}
{synopt:{cmd:+-*/^}} standard Mata mathematical operators, using colon notation i.e. {cmd:2 :* {t}}, see 
{helpb help [M-2] op_colon}. Colon operators must be used as behind the scenes, {cmd:{t}} gets replaced by an 
{cmd:_N} x {cmd:nodes()} matrix when numerically integrating the transition hazard function.{p_end}
{synopt:{it:mata_function}} any Mata function, e.g. {cmd:log()} and {cmd:exp()}{p_end}
{p2colreset}{...}

{phang2}For example, {cmd:dist(weibull) lambda(0.1) gamma(1.2)} is equivalent to {cmd:user(0.1:*1.2:*{t}:^(1.2:-1))}{p_end}

{phang}{opt covariates(varname # ...)} defines baseline covariates to be included in the linear predictor of the 
transition-specific hazard function, along with the value of the corresponding coefficient. For example, a treatent variable coded 0/1 can be 
included, with a log hazard ratio of 0.5, by {cmd:covariates(treat 0.5)}. Variable {cmd:treat} must be in the dataset before 
{cmd:survsim} is called.{p_end}

{phang}{opt tde(varname # ...)} creates non-proportional hazards by interacting covariates with a function of time. 
Covariates are interacted with {cmd:tdefunction()}, on the log hazard scale. Values should be entered as {cmd:tde(trt 0.5)}, 
for example. Multiple time-dependent effects can be specified, but they will all be interacted with the same function of time.

{phang}{opt tdefunction(string)} defines the function of time to which covariates specified in {cmd:tde()} are interacted 
with, to create time-dependent effects in the transition-specific hazard function. The default is {cmd:{t}}, i.e. linear time. 
The function can include:{p_end} 
{synoptset 15 notes}{...}
{synopt:{cmd:{t}}} which denotes the main timescale, measured on the time since starting state, {cmd:startstate()}, 
timescale (which may be {cmd:ltruncated()}){p_end}
{synopt:{cmd:+-*/^}} standard Mata mathematical operators, using colon notation i.e. {cmd:2 :* {t}}, see 
{helpb help [M-2] op_colon}. Colon operators must be used as behind the scenes, {cmd:{t}} gets replaced by an 
{cmd:_N} x {cmd:nodes()} matrix when numerically integrating the transition hazard function.{p_end}
{synopt:{it:mata_function}} any Mata function, e.g. {cmd:log()} and {cmd:exp()}{p_end}
{p2colreset}{...}

{phang}{opt reset} specifies that this transition model is on a clock-reset timescale. The timescale is reset to 0 on entry, 
i.e. the timescale for this transition is measured on a time since state entry timescale, rather than the default 
clock-forward. If you specify a {cmd:user()} function with {cmd:reset}, then {cmd:survsim} will replace any occurences of 
{cmd:{t}} with {cmd:{t}-{t0}}, including those specified in {cmd:tdefunction()}.{p_end}


{marker commonopts}{...}
{title:Options}

{phang}
{opt transmatrix(matname)} specifies the transition matrix which governs the multi-state model. Transitions must be 
numbered as an increasing sequence of integers from 1,...,K, from left to right, top to bottom of the matrix. 
Reversible transitions are allowed. If {cmd:transmatrix()} is not specified, a competing risks model is assumed.{p_end}

{phang}{opt maxtime(#|varname)} specifies right censoring time(s). Either a common maximum follow-up time {cmd:#} can be 
specified for all observations, or observation specific censoring times can be specified by using a {varname}. {p_end}

{phang}{opt startstate(#|varname)} specifies the state(s) in which observations begin. Either a common state {cmd:#} can 
be specified for all observations, or observation specific starting states can be specified by using a {varname}. 
Default is {cmd:startstate(1)}.{p_end}

{phang}{opt ltruncated(#|varname)} specifies left truncated/delayed entry time(s), which is the time(s) at which observations 
start in the initial starting state(s). Either a common time {cmd:#} can be specified for all observations, or observation 
specific left truncation times can be specified by using a {varname}. Default is {cmd:ltruncated(0)}.{p_end}

{phang}{opt nodes(#)} defines the number of Gauss-Legendre quadrature points used to evaluate the total cumulative hazard 
function for each potential next transition. To simulate survival times from such a function, a combination of numerical 
integration and root-finding is used. The default is {cmd:nodes(30)}.{p_end}


{title:Remarks}

{pstd}When simulating multi-state event data using {helpb survsim}, numerical quadrature is used to calculate the total 
cumulative hazard function, within iterations of Brent's univariate root finder. As with all model frameworks 
which use numerical integration, it is important to assess the stability of the simulated survival times with an increasing 
number of quadrature nodes. Any {cmd:survsim} call that requires Brent's method is executed under a tolerance of 0, to 
ensure accurracy of the simulated survival times.{p_end}

{pstd}Note that even if {cmd:reset} transitions are used in the data-generating model, the returned simulated event times 
are still on the main timescale, time since initial {cmd:startstate()} (which could be {cmd:ltruncated()}).{p_end}

{pstd}Always {helpb set seed}, to ensure reproducibility.{p_end}


{marker examples}{...}
{title:Examples}

{phang}{ul:{bf:Example 1: Simulate from a competing risks model}}{p_end}

{pstd}
We'll simulate 1000 observations, and generate a binary treatment group indicator, remembering to {helpb set seed} first.
{p_end}

{cmd:    . set obs 1000}
{cmd:    . set seed 9865}
{cmd:    . gen trt = runiform()>0.5}

{pstd}
Simulate from a competing risk model with 2 competing events. The first cause-specific hazard has a Weibull distribution, 
with no covariates. The second cause-specific hazard model has an exponential distribution, with a beneficial treatment effect. 
Right censoring applied at 10 years.
{p_end}

{cmd:    . survsim time state event , hazard1(dist(weibull) lambda(0.1) gamma(1.2))                 ///}
{cmd:                                 hazard2(dist(exponential) lambda(0.01) covariates(trt -0.5))  ///}
{cmd:                                 maxtime(10)}
{cmd:    variables time0 to time1 created}
{cmd:    variables state0 to state1 created}
{cmd:    variables event1 to event1 created}


{phang}{ul:{bf:Example 2: Simulate from an illness-death model}}{p_end}

{pstd}
We first define the transition matrix for an illness-death model. It has three states:
{p_end}

{phang2}State 1 - A "healthy" state. Observations can move from state 1 to state 2 or 3.{p_end}
{phang2}State 2 - An intermediate "illness" state. Observations can come from state 1, and move on to state 3.{p_end}
{phang2}State 3 - An absorbing "death" state. Observations can come from state 1 or 2, but not leave.{p_end}

{pstd}
This gives us three potential transitions between states:
{p_end}

{phang2}Transition 1 - State 1 -> State 2{p_end}
{phang2}Transition 2 - State 1 -> State 3{p_end}
{phang2}Transition 3 - State 2 -> State 3{p_end}

{pstd}
which is defined by the following matrix:
{p_end}

{cmd:    . matrix tmat = (.,1,2\.,.,3\.,.,.)}

{pstd}
The key is to think of the column/row numbers as the states, and the elements of the matrix as the transition numbers. 
Any transitions indexed with a missing value {cmd:.} means that the transition between the row state and the column state 
is not possible. Let's make it obvious, sticking with our "healthy", "ill" and "dead" names for the states:
{p_end}

{cmd:    . mat colnames tmat = "healthy" "ill" "dead"}
{cmd:    . mat rownames tmat = "healthy" "ill" "dead"}
{cmd:    . mat list tmat}

{cmd:    tmat[3,3]}
{cmd:             healthy      ill     dead}
{cmd:    healthy        .        1        2}
{cmd:        ill        .        .        3}
{cmd:       dead        .        .        .}

{pstd}
Now we've defined the transition matrix, we can use {cmd:survsim} to simulate some data. We'll simulate 1000 observations, and 
generate a binary treatment group indicator, remembering to {helpb set seed} first.
{p_end}

{cmd:    . set obs 1000}
{cmd:    . set seed 9865}
{cmd:    . gen trt = runiform()>0.5}

{pstd}
The first transition-specific hazard has a user defined baseline hazard function, with a harmful treatment effect. 
The second transition-specific hazard model has a Weibull distribition, with a beneficial treatment effect. The 
third transition-specific hazard has a user-defined baseline hazard function, with an initially beneficial treatment 
effect that reduces linearly with respect to log time. Right censoring is applied at 3 years.
{p_end}

{cmd:    . survsim time state event, transmatrix(tmat)                                                          ///}
{cmd:                                hazard1(user(exp(-2 :+ 0.2:* log({t}) :+ 0.1:*{t})) covariates(trt 0.1))   ///}
{cmd:                                hazard2(dist(weibull) lambda(0.01) gamma(1.3) covariates(trt -0.5))        ///}
{cmd:                                hazard3(user(0.1 :* {t} :^ 1.5) covariates(trt -0.5) tde(trt 0.1)          ///}
{cmd:                                        tdefunction(log({t})))                                             ///}
{cmd:                                maxtime(3)}
{cmd:    variables time0 to time2 created}
{cmd:    variables state0 to state2 created}
{cmd:    variables event1 to event2 created}

{pstd}
{cmd:survsim} creates variables storing the times at which states were entered, with the associated state number, and whether 
an event or right-censoring occured. It begins by creating the {cmd:0} variables, which represents the time at which 
observatations entered the inital state, {cmd:time0}, and the associated state number, {cmd:state0}. As {cmd:ltruncated()} 
and {cmd:startstate()} were not specified, all observations are assumed to start in state 1 at time 0. Subsequent transitions 
are simulated until all observations have either entered an absorbing state, or are right-censored at their {cmd:maxtime()}. 
For simplicity, I will assume time is measured in years. We can see what {cmd:survsim} has created:
{p_end}

{cmd:    . list if inlist(_n,1,4,16,112)}

{cmd:          +----------------------------------------------------------------------------------+}
{cmd:          | trt   time0   state0       time1   state1   event1       time2   state2   event2 |}
{cmd:          |----------------------------------------------------------------------------------|}
{cmd:       1. |   0       0        1           3        1        0           .        .        . |}
{cmd:       4. |   1       0        1   .95636156        2        1           3        2        0 |}
{cmd:      16. |   0       0        1   1.0755764        2        1   2.4401409        3        1 |}
{cmd:     112. |   1       0        1   2.3290322        3        1           .        .        . |}
{cmd:          +----------------------------------------------------------------------------------+}

{pstd}
All observations start initially in state 1 at time 0, which are stored in {cmd:state0} and {cmd:time0}, respectively. Then,
{p_end}

{phang2}{cmd:Observation 1} is right-censored at 3 years, remaining in state 1{p_end}
{phang2}{cmd:Observation 4} moves to state 2 at 0.956 years, and is subsequently right-censored at 3 years, still in 
state 2{p_end}
{phang2}{cmd:Observation 16} moves to state 2 at 1.076 years, and then moves to state 3 at 2.440 years. Since state 3 
is an absorbing state, there are no further transitions.{p_end}
{phang2}{cmd:Observation 112} moves to state 3 at 2.329 years. Again, since state 3 is absorbing, there are no further 
transitions{p_end}


{title:Author}

{pstd}{cmd:Michael J. Crowther}{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}Please report any errors you may find.{p_end}


{title:References}

{phang}Bender R, Augustin T and Blettner M. Generating survival times to simulate Cox proportional hazards models. {it:Statistics in Medicine} 2005;24:1713-1723.{p_end}

{marker paper3}{...}
{phang}Beyersmann J, Latouche A, Buchholz A and Schumacher M. Simulating competing risks data in survival analysis. {it:Statistics in Medicine} 2009;28:956-971.{p_end}

{marker paper1}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://www.stata-journal.com/article.html?article=st0275":Simulating complex survival data.}{it: The Stata Journal} 2012;12(4):674-687.{p_end}

{marker paper2}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.5823/abstract":Simulating biologically plausible complex survival data.} {it:Statistics in Medicine} 2013;32(23):4118-4134.{p_end}

{phang}Jann, B. 2005. moremata: Stata module (Mata) to provide various functions. Available from http://ideas.repec.org/c/boc/bocode/s455001.html.{p_end}

