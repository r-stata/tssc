{smcl}
{* *! version 1.0.0 ?????2012}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{vieweralsosee "msset" "help msset"}{...}
{viewerjumpto "Syntax" "predictms##syntax"}{...}
{viewerjumpto "Description" "predictms##description"}{...}
{viewerjumpto "Options" "predictms##options"}{...}
{viewerjumpto "Examples" "predictms##examples"}{...}
{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{hi:predictms} {hline 2}}predictions from a multi-state survival model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd: predictms} {cmd:,} {opt transmatrix(varname)} [{it:options}]


{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth transm:atrix(matname)}}transition matrix{p_end}
{synopt:{opth models(namelist)}}list of estimates stored for # transition{p_end}
{synopt:{opt reset}}use clock-reset approach{p_end}
{synopt:{opth from(numlist)}}starting state(s) for predictions{p_end}
{synopt:{opth obs(#)}}number of time points to calculate predictions at between {cmd:mint()} and {cmd:maxt()}{p_end}
{synopt:{opth mint(#)}}minimum time at which to calculate predictions{p_end}
{synopt:{opth maxt(#)}}maximum time at which to calculate predictions{p_end}
{synopt:{opth time:var(varname)}}time points at which to calculate predictions{p_end}
{synopt:{opth exit(#)}}time that observations exit the model, for fixed horizon predictions{p_end}
{synopt:{opth n(#)}}sample size of simulated dataset{p_end}
{synopt:{opt aj}}use the Aalen-Johansen estimator for transition probabilities; see below{p_end}
{synopt:{opth m(#)}}number of simulation repetitions for calculating confidence intervals{p_end}
{synopt:{opt ci}}calculate confidence intervals of predictions{p_end}
{synopt:{opt perc:entile}}calculate confidence intervals using percentiles{p_end}
{synopt:{opth seed(#)}}set the simulation seed{p_end}
{synopt:{opth l:evel(#)}}calculate confidence intervals at specific level, default is 95{p_end}
{synopt:{opt los}}calculate length of stay{p_end}
{synopt:{opt visit}}probability of ever visiting each state{p_end}
{synopt:{opt graph}}produce stacked transition probability graphs{p_end}
{synopt:{opth graphopts(options)}}pass options to twoway{p_end}
{synopt:{opt at#(at_list)}}calculate predictions (and contrasts) at covariate patterns{p_end}
{synopt:{opth atref:erence(#)}}specifies the reference prediction for {cmd:difference} and {cmd:ratio} contrasts{p_end}
{synopt:{opt diff:erence}}calculate differences between predictions{p_end}
{synopt:{opt ratio}}calculate ratios of predictions{p_end}
{synopt:{opt surv:ival}}standard single outcome survival analysis - the simplest multi-state model{p_end}
{synopt:{opt cr}}competing risks model{p_end}
{synopt:{opt tscale2(numlist)}}transition models on a second timescale{p_end}
{synopt:{opt time2(numlist)}}time to add to main timescale{p_end}
{synopt:{opt stand:ardise}}calculates standardised predictions{p_end}
{synopt:{cmd: {ul:userf}unction(}{it:func_name}{cmd:)}}user-defined Mata function for bespoke predictions{p_end}
{synopt:{opt userl:ink(string)}}link function used in calculation of confidence intervals for {cmd:userfunction()}; default {cmd:identity}{p_end}
{synopt:{opt out:sample}}for out of sample predictions; see below.{p_end}
{synopt:{opt novcv(numlist)}}transition models that should be assumed are not estimated with uncertainty; see details{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:predictms} calculates a variety of predictions from a multi-state survival model, including 
transition probabilities, length of stay (restricted mean survival times in each state), the probability of ever visiting 
each state and more. Predictions are made 
at user-specified covariate patterns. Differences and ratios of predictions across covariate patterns can also be calculated. 
Standardised (population-averaged) predictions can be obtained. Confidence intervals for all quantities are available. 
Simulation or the Aalen-Johansen estimator are used to calculate all quantities. User-defined predictions can also be calculated by providing a user-written 
Mata function, to provide complete flexibility.
{p_end}

{pstd}
Survival model fitting commands supported include {cmd:stpm2}, {cmd:strcs}, {cmd:stms}, and all those in {cmd:streg}.
{p_end}

{pstd}
The user (usually) must provide the transition matrix used in the fitted model, through the {bf:transmatrix()} option.
Default predictions assume all subjects start in state {bf:_from = 1}, at time {bf:_start = mint()}.
{p_end}

{pstd}
{cmd:predictms} creates the following variables:
{p_end}

{phang2}
	{bf:_time}            times at which all predictions are calculated
	
{phang2}
{bf:_prob_at{it:i}_{it:a}_{it:b}}       transition probability for {cmd:at{it:i}()} (from state {it:a} to state {it:b})

{phang2}
	{bf:_prob_at{it:i}_{it:a}_{it:b}_lci}   lower confidence interval of transition probability for {cmd:at{it:i}()} (from state {it:a} to state {it:b})
	
{phang2}
	{bf:_prob_at#_{it:a}_{it:b}_uci}   upper confidence interval of transition probability for {cmd:at{it:i}()} (from state {it:a} to state {it:b})

{pstd}	
If {cmd:los} is requested, then {cmd:predictms} also creates the following variables:
{p_end}

{phang2}
{bf:_los_at{it:i}_{it:a}_{it:b}}       length of stay in state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})

{phang2}
	{bf:_los_at{it:i}_{it:a}_{it:b}_lci}   lower confidence interval of the length of stay in state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})
	
{phang2}
	{bf:_los_at{it:i}_{it:a}_{it:b}_uci}   upper confidence interval of the length of stay in state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})
	
{pstd}	
If {cmd:visit} is requested, then {cmd:predictms} also creates the following variables:
{p_end}

{phang2}
{bf:_visit_at{it:i}_{it:a}_{it:b}}       probability of ever visiting state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})

{phang2}
	{bf:_visit_at{it:i}_{it:a}_{it:b}_lci}   lower confidence interval of the probability of ever visiting state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})
	
{phang2}
	{bf:_visit_at{it:i}_{it:a}_{it:b}_uci}   upper confidence interval of the probability of ever visiting state {it:b} for {cmd:at{it:i}()} (given they started from state {it:a})
	
{pstd}	
If a {cmd:userfunction()} is provided, then {cmd:predictms} also creates the following variables:
{p_end}

{phang2}
	{bf:_user_at{it:i}_{it:a}_{it:b}}       returned values for column {it:b} of the user-function for {cmd:at{it:i}()} (given they started from state {it:a})

{phang2}
	{bf:_user_at{it:i}_{it:a}_{it:b}_lci}   lower confidence interval of the returned values for column {it:b} of the user-function for {cmd:at{it:i}()} (given they started from state {it:a})
	
{phang2}
	{bf:_user_at{it:i}_{it:a}_{it:b}_uci}   upper confidence interval of the returned values for column {it:b} of the user-function for {cmd:at{it:i}()} (given they started from state {it:a})
	
{pstd}	
If a {cmd:difference} is requested, then {cmd:predictms} also creates some or all of the following variables:
{p_end}

{phang2}
{bf:_diff_prob_at{it:i}_{it:a}_{it:b}} difference in transition probabilities between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:_diff_los_at{it:i}_{it:a}_{it:b}} difference in length of stay between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:_diff_user_at{it:i}_{it:a}_{it:b}} difference in the user-function between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:*_lci} and {bf:*_uci} are returned as appropriate.

{pstd}	
If a {cmd:ratio} is requested, then {cmd:predictms} also creates some or all of the following variables:
{p_end}

{phang2}
{bf:_ratio_prob_at{it:i}_{it:a}_{it:b}} ratio in transition probabilities between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:_ratio_los_at{it:i}_{it:a}_{it:b}} ratio in length of stay between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:_ratio_user_at{it:i}_{it:a}_{it:b}}	ratio in the user-function between {cmd:at{it:i}()} and that specified in the reference {cmd:at{it:j}()}

{phang2}
{bf:*_lci} and {bf:*_uci} are returned as appropriate.
	
{pstd}
All appropriate combinations of {it:a} and {it:b} are returned. {cmd:predictms} first drops any variables it may have calculated 
from a previous call (e.g. {cmd:_prob_*}).

{pstd}
Factor variables must not be used in fitted models. When using {cmd:predictms} after fitting a stacked data model 
(i.e. without the {cmd:models()} syntax, you must create your own dummy variables by specifying them in the 
{bf:covariates()} option of {bf:msset}, or by making sure they end in {bf:_trans#}.

{phang}
{cmd:predictms} is part of the {cmd:multistate} package by Michael Crowther and Paul Lambert. Further 
details here: {bf:{browse "https://www.mjcrowther.co.uk/software/multistate":mjcrowther.co.uk/software/multistate}}
{p_end}
	

{marker options}{...}
{title:Options}

{phang}
{opt transmatrix(matname)} specifies the transition matrix which governs the multi-state model 
that was fitted. Transitions must be numbered as an increasing sequence 
of integers from 1,...,K, from left to right, top to bottom of the matrix. Reversible transitions are allowed. 
If obtaining predictions after a model fitted to the stacked data created by {cmd:msset}, this this transition 
matrix must be the same as that used/produced by {cmd:msset}.

{phang}
{opt models(namelist)} specifies the names of the {cmd:estimates store} objects containing the estimates of the model fitted for transition 1, 2, 3, ..., for example,

{phang2}
{cmd: predictms} {cmd:,} {opt transmatrix(tmat)} {opt models(m1 m2 m3)}

{phang2}
When {bf:models()} is not specified, it is assumed a model has been fitted to the stacked data created by {bf:msset}.

{phang}
{opt reset} use the clock-reset approach, i.e. a semi-Markov model, in the simulation framework when calculating 
predictions. Default is clock-forward using delayed entry.

{phang}
{opt from(numlist)} define the starting state for all observations, default is state 1. 
Multiple starting states can be defined, which will calculate all possible predictions for each starting state.

{phang}
{opt obs(#)} the number of time points at which to calculate predictions, equally spaced between {cmd:mint()} and {cmd:maxt()}, 
with a default of 100 when using simulation, and 500 when using {cmd:aj}.

{phang}
{opt mint(#)} minimum time at which to calculate predictions, and at which patients become at risk, with a default of {cmd:mint(0)}. 
If {cmd:timevar()} is not specified, then a default time variable will be created, using {cmd:mint()}, {cmd:maxt()} and {cmd:obs()}.

{phang}
{opt maxt(#)} maximum time at which to calculate predictions. If {cmd:timevar()} is not specified, then a default time variable will 
be created, using {cmd:mint()}, {cmd:maxt()} and {cmd:obs()}.

{phang}
{opt timevar(varname)} variable which contains time points at which to calculate predictions, which overrides the default. The minimum time 
in your time variable will be taken as the time at which patients become at risk.

{phang}
{opt exit(#)} defines the time that observations exit the model, for fixed horizon predictions.

{phang}
{opt n(#)} samples size of each simulated dataset, default is 100,000 unless {cmd:ci} is specified, then it is 10,000. 
Accuracy increases the higher the sample.

{phang}
{opt aj} uses the Aalen-Johansen estimator of the transition-probabilities, which assumes piecewise constant transition rates 
between prediction time points, and hence more time points are recommended (e.g. {cmd:obs(100)}) for greater accuracy, when 
calculating predictions. {cmd:aj} is currently only implemented for Markov models and so can't currently be used with 
a {cmd:reset} model. It can also only be used in conjunction with the {cmd:models()} framework. The {cmd:aj} method is 
substantially faster than the equivalent simulation approach. When {cmd:ci} is 
requested, the same parametric bootstrap method is used, as when using the default simulation approach.

{phang}
{opt m(#)} number of simulation repetitions for calculating confidence intervals; default is {cmd:m(200)}. We recommend 
using an increasing number to check a sufficiently large {cmd:m()} has been used.

{phang}
{opt ci} calculate confidence intervals of predictions. Default method uses normal approximation of simulated repetitions to calculate the standard error.

{phang}
{opt percentile} calculate confidence intervals based on centiles of the predictions across the {cmd:m(#)} sets, instead of the default normal based calculation.

{phang}
{opt seed(#)} sets the simulation seed.

{phang}
{opt level(#)} confidence interval level, default {cmd:level(95)}.

{phang}
{opt los} calculate length of stay in each state, i.e. restricted mean survival time for each transient state. If {cmd:aj} has been used 
then length of stay is calculated using numerical integration of the transition probabilities, and we recommend at least {cmd:obs(500)} 
is used in your {cmd:timevar()}.

{phang}
{opt visit} calculate the probability of ever visiting each state within the time interval defined from {cmd:mint()} and the prediction time. 

{phang}
{opt graph} produce stacked transition probability plots.

{phang}
{opt graphopts(twoway_options)} pass options to the {cmd:twoway} command when using the {cmd:graph} option.

{phang}
{opt at#(vn # ...)} calculates predictions at specified covariate patterns, e.g. {cmd:at1(female 1 age 55)}. 
Specifying multiple {cmd:at#()}s means only one call of {cmd:predictms} has to be made to calculate many predictions. 
Any covariates not specified in {cmd:at#()} are set to 0.

{phang}
{opt atreference(#)} specifies the reference {cmd:at#()} for calculating prediction contrasts. Default is {cmd:atref(1)}, meaning 
the each prediction is contrasted to that calculated using {cmd:at1()}.

{phang}
{opt difference} calculate the difference between predictions, specified with the {cmd:at#()} options. 
See {cmd:atreference()}.

{phang}
{opt ratio} calculate the ratio of the predictions, specified with {cmd:at#()}.

{phang}
{opt survival} indicates that you have fitted a standard single event survival analysis model. This corresponds to a transition matrix of
 (.,1\.,.). {bf:transmatrix()} does not need to be specified. All predictions from {bf:predictms} are valid.

{phang}
{opt cr} indicates that you have fitted a competing risks model, and is a useful way of avoiding having to specify a 
{bf:transmatrix()}. For use with {cmd:models()}, as the number of competing risks corresponds to the number of model objects. 
All predictions from {bf:predictms} are valid.

{phang}
{opt tscale2(numlist)} specifies any transition models (using the same index as specified in {cmd:transmatrix()}), which 
are modelled on a secondary timescale, enabling transition-specific timescales (Weibull et al. {it:In Prep.}). This can be used 
for example when modelling age as the timescale for some transitions, and time since diagnosis for others. 

{phang}
{opt time2(numlist)} specifies the value to be added to the main timescale at entry, for each of the transition models specified in 
{cmd:tscale2()}. If age is the second timescale, then this would be age at baseline. Each element of {cmd:time2()} corresponds to each 
{cmd:at#()}. If only one {cmd:time2()} is specified then it will be assumed for all {cmd:at#()}s.

{phang}
{opt standardise} calculates standardised (population-averaged) predictions, averaging over the observed covariate distributions. Any covariates 
not specified in the {cmd:at#()} statements are standardised over. See Gran et al. (2015).

{phang}
{opt userfunction(func_name)} defines a Mata function which returns a {it: real matrix}, to calculate user-defined quantities. The function 
must be of the form:

{p 8 12 2}
{it: real matrix} func_name(S)
{p_end}
{p 8 12 2}
{
{p_end}
{p 12 12 2}
...
{p_end}
{p 12 12 2}
{it:some code}
{p_end}
{p 12 12 2}
...
{p_end}
{p 12 12 2}
pred = {it:some more code}
{p_end}
{p 12 12 2}
return(pred)
{p_end}
{p 8 12 2}
}
{p_end}

{phang2}
where S is a transmorphic object which should not be changed. It is passed to utility functions, which give access to the 
transition probabilites and/or length of stays, for example:

{p 8 12 2}
{it: real matrix} func_name(S)
{p_end}
{p 8 12 2}
{
{p_end}
{p 12 12 2}
p1 = ms_user_prob(S,1)
{p_end}
{p 12 12 2}
p2 = ms_user_prob(S,2)
{p_end}
{p 12 12 2}
p3 = ms_user_prob(S,3)
{p_end}
{p 12 12 2}
pred = p1,p2,p3
{p_end}
{p 12 12 2}
return(pred)
{p_end}
{p 8 12 2}
}
{p_end}

{phang2}
which would give us our transition probabilities for each state. Length of stays are accessed using {cmd:ms_user_los()} in the same way, 
but the {cmd:los} option must also be specified.

{phang}
{opt userlink(link_name)} specifies the link function used when calculating confidence intervals with the normal approximation 
applied to the {cmd:userfunction()}. Options include {cmd:log}, {cmd:logit}, and the default {cmd:identity}. The link function is applied, 
and the mean and standard error are then calculated on the transformed scale to calculate confidence intervals, and then transformed back. This ensures 
all predictions are within the desired range (e.g. 0 and 1 for probabilities).

{phang}
{opt outsample} specifies predictions are being made out of sample, which suppresses checks that variables specified in {cmd:at#()}s 
are in your current dataset. This is of use when transition {cmd:models()} come from different datasets. As this suppresses some error checks, users 
should be extra careful when specifying their {cmd:at#()}s.

{phang}
{opt novcv(numlist)} specifies transitions that, when calculating confidence intervals on predictions (using {cmd:ci}), 
are assumed to be estimated free of uncertainty, i.e. draws will not be made from the multivariate normal centred on the 
parameter estimates and with VCV the estimated VCV from that transition, but will use the estimated vector every time. 


{marker examples}{...}
{title:Example 1:}

{pstd}
This dataset contains information on 2982 patients with breast cancer. Baseline is defined as time of surgery, and patients can experience 
relapse, relapse then death, or death with no relapse. Time of relapse is stored in {cmd:rf}, with event indicator {cmd:rfi}, and time of death 
is stored in {cmd:os}, with event indicator {cmd:osi}.
{p_end}

{pstd}Load example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/m/multistate_example":. use http://fmwww.bc.edu/repec/bocode/m/multistate_example}{p_end}

{pstd}{cmd:msset} the data:{p_end}
{phang}{stata "msset, id(pid) states(rfi osi) times(rf os)":. msset, id(pid) states(rfi osi) times(rf os)}{p_end}

{pstd}Store the transition matrix:{p_end}
{phang}{stata "mat tmat = r(transmatrix)":. mat tmat = r(transmatrix)}{p_end}

{pstd}stset the data using the variables created by {cmd:msset}{p_end}
{phang}{stata "stset _stop, enter(_start) failure(_status=1)":. stset _stop, enter(_start) failure(_status=1)}{p_end}

{pstd}Fit a Weibull model, allowing a separate baseline (stratified), but the same effect of age across transitions, assuming transition 1 as the reference:{p_end}
{phang}{stata "streg age _trans2 _trans3, dist(weibull) ancillary(_trans2 _trans3)":. streg age _trans2 _trans3, dist(weibull) ancillary(_trans2 _trans3)}{p_end}

{pstd}Calculate transition probabilities for a patient with age 50:{p_end}
{phang}{stata "predictms, transmatrix(tmat) at1(age 50)":. predictms, transmatrix(tmat) at1(age 50)}{p_end}

{pstd}Alternatively, we fit separate Weibull models, also allowing transition specific age effects:{p_end}

{phang}{stata "streg age if _trans1==1, dist(weibull)":. streg age if _trans1==1, dist(weibull)}{p_end}
{phang}{stata "estimates store m1":. estimate store m1}{p_end}

{phang}{stata "streg age if _trans2==1, dist(weibull)":. streg age if _trans2==1, dist(weibull)}{p_end}
{phang}{stata "estimates store m2":. estimate store m2}{p_end}

{phang}{stata "streg age if _trans3==1, dist(weibull)":. streg age if _trans3==1, dist(weibull)}{p_end}
{phang}{stata "estimates store m3":. estimate store m3}{p_end}

{pstd}Calculate transition probabilities for a patient with age 50:{p_end}
{phang}{stata "predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50)":. predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50)}{p_end}

{pstd}Calculate transition probabilities and length of stay for a patient with age 50:{p_end}
{phang}{stata "predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) los":. predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) los}{p_end}

{pstd}Calculate the difference in transition probabilities for a patient with age 60 compared to a patient aged 50:{p_end}
{phang}{stata "predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) difference":. predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) difference}{p_end}

{pstd}Calculate the ratio of transition probabilities for a patient with age 60 compared to a patient aged 50:{p_end}
{phang}{stata "predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) ratio":. predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) ratio}{p_end}

{pstd}Calculate differences and ratios of length of stay and transition probabilities for a patient with age 60 compared to a patient aged 50, with confidence intervals:{p_end}
{phang}{stata "predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) los diff ratio ci":. predictms, transmatrix(tmat) models(m1 m2 m3) at1(age 50) at2(age 60) los diff ratio ci}{p_end}


{title:Authors}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{pstd}Paul C. Lambert{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}Department of Medical Epidemiology and Biostatistics{p_end}
{pstd}Karolinska Institutet{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:Acknowledgments}

{pstd}
Part of this work was funded by Michael Crowther's MRC-NIHR Methodology Research Panel Grant (MR/P015433/1).
{p_end}


{title:References}

{phang}
Crowther MJ, Lambert PC. Parametric multi-state survival models: flexible modelling allowing transition-specific distributions with 
application to estimating clinically useful measures of effect differences. {it: Statistics in Medicine} 2017;36(29):4719-4742.
{p_end}

{phang}
Gran JM, Lie SA, Øyeflaten I, Borgan Ø, Aalen OO. Causal inference in multi-state models--sickness absence and work for 
1145 participants after work rehabilitation. {it:BMC Public Health} 2015;15:1-16.
{p_end}

{phang}
de Wreede LC, Fiocco M, Putter H. mstate: An R Package for the Analysis of Competing Risks and Multi-State Models. 
{it:Journal of Statistical Software} 2011;38:1-30.
{p_end}

{phang}
Putter H, Fiocco M, Geskus RB. Tutorial in biostatistics: competing risks and multi-state models. 
{it:Statistics in Medicine} 2007;26:2389-2430.
{p_end}

{phang}
Weibull CE, Lambert PC, Eloranta S, Dickman PW, Crowther MJ. Multi-state relative survival analysis 
incorporating transition-specific timescales. {it: In Prep.}
{p_end}


