{smcl}
{* *! version 1.0.0  ?????2018}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{viewerjumpto "Syntax" "merlin_postestimation##syntax"}{...}
{viewerjumpto "Description" "merlin_postestimation##description"}{...}
{viewerjumpto "Options" "merlin_postestimation##options"}{...}
{viewerjumpto "Remarks" "merlin_postestimation##remarks"}{...}
{viewerjumpto "Examples" "merlin_postestimation##examples"}{...}

{marker syntax}{...}
{title:Syntax for predict}

{pstd}
Syntax for predictions following a {helpb merlin:merlin} model

{p 8 16 2}
{cmd:predict}
{it:newvarname}
{ifin} [{cmd:,}
{it:{help merlin_postestimation##statistic:statistic}}
{it:{help merlin_postestimation##opts_table:options}}]


{phang}
The default is to make predictions based only on the fixed portion of the 
model.  

{marker statistic}{...}
{synoptset 22 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt :{opt mu}}expected value of {depvar}; the default{p_end}
{synopt :{opt eta}}expected value of complex predictor{p_end}
{synopt :{opt surv:ival}}survivor function{p_end}
{synopt :{opt cif}}cumulative incidence function{p_end}
{synopt :{opt h:azard}}hazard function{p_end}
{synopt :{opt ch:azard}}cumulative hazard function{p_end}
{synopt :{opt rmst}}restricted mean survival time, within (0,{it:t}]{p_end}
{synopt :{opt timel:ost}}time lost due to an event, within (0,{it:t}]{p_end}
{synopt :{opt totaltimel:ost}}total time lost due to all events, within (0,{it:t}]{p_end}
{synopt :{opt mudiff:erence}}differences in expected values of {depvar}{p_end}
{synopt :{opt etadiff:erence}}differences in expected value of complex predictor{p_end}
{synopt :{opt hdiff:erence}}differences in hazard functions{p_end}
{synopt :{opt sdiff:erence}}differences in survival functions{p_end}
{synopt :{opt cifdiff:erence}}differences in cimulative incidence functions{p_end}
{synopt :{opt rmstdiff:erence}}differences in restricted mean survival functions{p_end}
{synoptline}

{marker opts_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt :{opt fixedonly}}compute {it:statistic} based only on the fixed portion of the model; the default{p_end}
{synopt :{opt marginal}}compute {it:statistic} marginally with respect to the latent variables{p_end}
{synopt :{cmd:outcome(}{it:#}{cmd:)}}specify observed response variable (default 1){p_end}
{synopt :{opt causes(numlist)}}specify which {cmd:merlin} submodels contribute to the {it:statistic}{p_end}
{synopt :{opt at(at_spec)}}specify covariate values for prediction{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{cmd:timevar(}{varname}{cmd:)}}calculate predictions at specified time-points{p_end}
{synopt :{opt at1(at_spec)}}specify covariate values for first contrast{p_end}
{synopt :{opt at2(at_spec)}}specify covariate values for second contrast{p_end}

{syntab :Integration}
{synopt :{opt intp:oints(#)}}use
        {it:#} integration points to compute marginal predictions {p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:predict} is a standard postestimation command of Stata.
This entry concerns use of {cmd:predict} after {cmd:merlin}.

{pstd}
{cmd:predict} after {cmd:merlin} creates new variables containing
observation-by-observation values of estimated observed response variables,
linear predictions of observed response variables, or other such functions.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:mu}, the default, calculates the expected value of the outcomes.

{phang} 
{cmd:eta} calculates the fitted linear prediction.

{phang} 
{cmd:survival} calculates the survival function. If you have fitted a competing risks model, then this will represent 
cause-specific survival.

{phang} 
{cmd:cif} calculates the cumulative incidence function at time {it:t}, where {it:t} is the time at which predictions are made. 
In a single event survival model, this is 1 - survival. 
In a competing risks {cmd:merlin} model, all survival models in the fitted {cmd:merlin} model are assumed to 
be cause-specific event time models contributing to the calculation. If this is not the case, you can tell {cmd:predict} which 
of the models are cause-specific hazard models by using the {cmd:causes()} option. 

{phang} 
{cmd:hazard} calculates the hazard function at time {it:t}, where {it:t} is the time at which predictions are made. 

{phang}
{cmd:chazard} calculates the cumulative hazard function at time {it:t}, where {it:t} is the time at which predictions are made. 

{phang} 
{cmd:rmst} calculates the restricted mean survival time, which is the integral of the survival function within the interval 
(0,{it:t}], where {it:t} is the time at which predictions are made. If multiple survival 
models have been specified in your {cmd:merlin} model, then it will assume all of them are cause-specific competing risks models, 
and include them in the calculation. If this is not the case, you can override which models are included by using the {cmd:causes()} 
option. {cmd:rmst} = {it:t} - {cmd:totaltimelost}.

{phang} 
{cmd:timelost} calculates the time lost due to a particular event occuring, within the interval (0,{it:t}]. 
In a single event survival model, this is the integral of the {cmd:cif} between (0,{it:t}].
If multple survival models are specified in the {cmd:merlin} model then by default all are assumed to be cause-specific 
event time models contributing to the calculation. This can be overridden using the {cmd:causes()} option.

{phang} 
{cmd:totaltimelost} calculates the total time lost due to any event occuring, within the interval (0,{it:t}]. 
In a single event survival model, this is the integral of the {cmd:cif} between (0,{it:t}], and will be equivalent 
to {cmd:timelost}. If multiple survival models are specified in the {cmd:merlin} model then by default all are 
assumed to be cause-specific event time models contributing to the calculation. This can be overridden using 
the {cmd:causes()} option. {cmd:totaltimelost} is the sum of the {cmd:timelost} due to all causes.

{phang} 
{cmd:mudifference} calculates the difference in the expected value of the outcomes, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang} 
{cmd:etadifference} calculates the difference in the expected value of the complex predictor, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang} 
{cmd:hdifference} calculates the difference in hazard function at time {it:t}, where {it:t} is the time at which predictions are made, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang} 
{cmd:sdifference} calculates the difference in survival function at time {it:t}, where {it:t} is the time at which predictions are made, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang} 
{cmd:cifdifference} calculates the difference in cumulative incidence function at time {it:t}, where {it:t} is the time at which predictions are made, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang} 
{cmd:rmstdifference} calculates the difference in restricted mean survival time at time {it:t}, where {it:t} is the time at which predictions are made, 
across the covariate patterns specified in {cmd:at1()} and {cmd:at2()}. 

{phang}
{cmd:causes(numlist)} is for use when calculating predictions from a competing risks {cmd:merlin} model. By default, 
{cmd:cif}, {cmd:rmst}, {cmd:timelost} and {cmd:totaltimelost} assume that all survival models included in the {cmd:merlin} 
model are cause-specific hazard models contributing to the calculation. If this is not the case, then you can specify which 
models (indexed using the order they appear in your {cmd:merlin} model, e.g. {cmd:causes(1 2)}), by using the {cmd:causes()} 
option.

{phang}
{cmd:fixedonly} specifies that the predicted {it:statistic} be computed
based only on the fixed portion of the model. This is the default.

{phang}
{cmd:marginal} specifies that the predicted {it:statistic} be computed
marginally with respect to the latent variables.

{phang2}
Although this is not the default, marginal predictions are often very useful
in applied analysis.  They produce what are commonly called
population-averaged estimates. 

{phang2}
For models with continuous latent variables, the {it:statistic} is calculated
by integrating the prediction function with respect to all the latent
variables over their entire support.

{phang}
{cmd:outcome(}{it:#}{cmd:)} specifies that predictions for
outcome {it:#} be calculated.

{phang}
{cmd:ci} specifies that confidence intervals are calculated for the predicted {it:statistic}. They will 
stored in {it:newvarname_lci} and {it:newvarname_uci}.

{phang}
{cmd:timevar(}{varname}{cmd:)}calculate predictions at specified time-points. 
For survival models, the default is to calculate predictions at the response times. 
For a {cmd:merlin} model where a {cmd:timevar()} was specified, then the default will use the original 
{cmd:timevar()}. This option overides it.{p_end}

{dlgtab:Integration}

{phang}
{opt intpoints(#)} specifies the number of integration points used to
compute marginal predictions; the default is the value from estimation.


{marker remarks}{...}
{title:Remarks}

{pstd}
Out-of-sample prediction is allowed for all {cmd:predict} options.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data, clear}{p_end}

{pstd}Linear mixed effects model with {cmd:merlin}{p_end}
{phang2}{cmd:. merlin (logb time age trt time#M1[id]@1 M2[id]@1, family(gaussian))}{p_end}

{pstd}Predict the expected value of {cmd:logb} marginalised over the random effects{p_end}
{phang2}{cmd:. predict ev1, eta marginal}{p_end}

