{smcl}
{* *! version 1.0.0 28feb2017}{...}
{title:Title}

{p2colset 5 18 21 2}{...}
{p2col :{hi:stcapture} {hline 2}}Estimate and store survival function(s) and hazard ratios in clinical trials{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:stcapture} [{it:trtvar}] {ifin} {cmd:,}
{it:required_options}
[{it:optional_options}]


{synoptset 16}{...}
{synopthdr :required_options}
{synoptline}
{synopt :{opt np:eriod(#)}}number of "periods" at ends of which survival probabilities are to be estimated{p_end}


{synopthdr :optional_options}
{synoptline}
{synopt :{opt df(#)}}degrees of freedom for baseline spline function in
flexible parametric survival model{p_end}
{synopt :{opt dftvc(#)}}degrees of freedom for spline function for
time-dependent treatment effect in flexible parametric model{p_end}
{synopt :{opt dp(#)}}decimal places of precision for storing estimated values{p_end}
{synopt :{opt sc:ale(scalename)}}scale on which the flexible parametric model is to be fitted{p_end}
{synopt :{opt ts:cale(#)}}scaling factor between units of analysis time and "periods"
(1 analysis-time unit = # periods){p_end}
{synoptline}
{p2colreset}{...}

{pstd}
Important note: Before {cmd:stcapture} can be used, {help stpm2} 
(Lambert and Royston 2009) must first
be installed from the Statistical Software Components (SSC) archive. See
{helpb ssc}.


{title:Description}

{pstd}
{cmd:stcapture} computes survival probabilities (and if {it:trtvar} is supplied)
time-dependent hazard ratios as estimated in a flexible parametric model fit
by {helpb stpm2} to the dataset in memory. The estimates and other relevant quantities
are stored in {cmd:r()} scalars and macros.

{pstd}
{cmd:stcapture} may be used as a preamble to the ART system of sample size and
power estimation in trials (Royston and Babiker 2002, Barthel, Royston and Babiker 2005,
Barthel, Babiker, Royston and Parmar 2006). ART is a tool to explore different
trial designs in the light of predefined survival probabilities and proportional
hazards or non-proportional hazards.The current version of the ART package
may be installed from the SSC archive using the command {cmd:ssc install art}.


{title:Options}

{phang}
{opt nperiod(#)} is not optional. The parameter {it:#} specifies the number of
"periods" at the end-points of which survival probabilities and hazard ratios
are to be estimated and output. Periods are integer numbers of time-intervals
whose length is determined by the reciprocal of {it:#} in the
{opt tscale(#)} option. Example: if analysis time in the dataset is in years
and {cmd:nperiod(12) tscale(4)} is specified, then each period is 1/4 year
= 3 months long and survival probabilities are estimated at
1/4, 2/4, ..., 12/4 = 3 years, i.e. at 3, 6, ..., 36 months.

{phang}
{opt df(#)} specifies the degrees of freedom for baseline spline function in
the flexible parametric survival model to be used to estimate survival
functions. Default {it:#} is 5.

{phang}
{opt dftvc(#)} specifies the degrees of freedom for spline function(s) for
time-dependent treatment effect(s) in the flexible parametric model. If {it:#}
is set to 1 or more, a time-dependent treatment effect is included, that is
increasingly complex as {it:#} increases. If {it:#} is set to 0 or less,
no time-dependency of the treatment effect is included, that is,
proportionality of the treatment effect(s) on the chosen scale is imposed.
For {opt scale(hazard)} models (the default), the result with {it:#} = 0 is a
proportional hazards model. Default {it:#} is 5, meaning a potentially complex
pattern of non-proportional hazards is fitted.

{phang}
{opt dp(#)} specifies the number of decimal places of accuracy required for
stored survival probabilities and hazard ratios. Default {it:#} is 3.

{phang}
{opt scale(scalename)} specifies the scale on which the flexible parametric model
is to be fitted. Default {it:scalename} is {cmd:hazard}.

{phang}
{opt tscale(#)} defines the scale factor between analysis-time units and
"periods" whereby one unit of analysis time equals # periods in length.
Example: if analysis time is in years {opt tscale(2)} is specified, each period
is one half a unit of analysis time (i.e. six months) in length. Note that
{it:#} may be 1, <1 or >1, but it is often 1, or >1 to "magnify" analysis time
and give greater detail of the survival function etc. Default {it:#} is 1.


{title:Examples}

{phang}. {stata webuse brcancer}{p_end}
{phang}. {stata "stset rectime, failure(censrec) scale(365.24)"}{p_end}
{phang}. {stata "stcapture hormon, nperiod(12) tscale(2) df(3) dftvc(1) dp(3)"}{p_end}
{phang}. {stata return list}{p_end}


{title:Stored}

{pstd}
In all cases, {opt stcapture} stores results in {cmd:r()}, as follows.

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(nperiod)}}number of periods used{p_end}
{synopt:{cmd:r(nobs)}}number of observations in estimation sample{p_end}
{synopt:{cmd:r(tscale)}}time-scale factor{p_end}
{synopt:{cmd:r(periods)}}list of integer periods used{p_end}
{p2colreset}{...}

{pstd}
In addition, if {it:trtvar} is not provided:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(surv)}}survival probabilities at end of each period in entire estimation sample{p_end}
{p2colreset}{...}

{pstd}
Alternatively in addition, if {it:trtvar} is provided, with arms (groups, levels)
implicitly coded 0 and 1, 0 denoting the control arm:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(surv0)}}survival probabilities in 'arm 0' at each time-point{p_end}
{synopt:{cmd:r(surv1)}}survival probabilities in 'arm 1' at each time-point{p_end}
{synopt:{cmd:r(hr)}}hazard ratios at each time-point{p_end}
{p2colreset}{...}


{title:References}

{phang}
P. Royston and A. Babiker. 2002. A menu-driven facility for complex sample size
calculation in randomised controlled trials with a survival or a binary outcome.
Stata Journal 2: 151-163.

{phang}
F.-M. S. Barthel, P. Royston and A. Babiker. 2005. A menu-driven facility for
complex sample size calculation in randomized controlled trials with a survival
or binary outcome: update. Stata Journal 5: 123-129.

{phang}
F.-M. S. Barthel, A. Babiker, P. Royston and M. K. B. Parmar. 2006.
Evaluation of sample size and power for multi-arm survival trials allowing for
non-uniform accrual, non-proportional hazards, loss to follow-up and cross-over.
Statistics in Medicine 25: 2521-2542.

{phang}
P. C. Lambert and P. Royston. 2009. Further development of flexible parametric
models for survival analysis. Stata Journal 9: 265-290.


{title:Author}

{pstd}
Patrick Royston{break}
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.

{pstd}Email: {browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Also see}

{psee}
Online:  help for {help stpm2}
{p_end}
