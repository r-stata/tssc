{smcl}
{* *! version 2.0)}
{hline}
{cmd:help slopepower}{right: ({})}
{hline}
{vieweralsosee "[R] mixed" "help mixed"}{...}
{viewerjumpto "Syntax" "slopepower##syntax"}{...}
{viewerjumpto "Menu" "slopepower##menu"}{...}
{viewerjumpto "Description" "slopepower##description"}{...}
{viewerjumpto "Options" "slopepower##options"}{...}
{viewerjumpto "Examples" "slopepower##examples"}{...}
{viewerjumpto "Stored results" "slopepower##results"}{...}
{viewerjumpto "Authors" "slopepower##authors"}{...}

{title:Title}
{p2colset 5 20 20 2}{...}
{p2col :{hi:slopepower} {hline 2}}Sample size and power calculator for 
outcomes analysed using a slope (ie repeated measures across multiple timepoints). 
A linear mixed model is used on data in memory to obtain estimates for slopes 
and variances among people with (and possibly without) the condition of interest{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:slopepower}
        {it:{help depvar}}
		{ifin}
        {cmd:,}
        {opth subj:ect(varname)}
        {opth time(varname)}
        {opth sched:ule(numlist)}
        [{it:{help slopepower##options_table:options}}]


{synoptset 29 tabbed}{...}
{marker options}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Options for data in memory}
{p2coldent :* {opth subj:ect(varname)}}variable defining each subject{p_end}
{p2coldent :* {opth time(varname)}}variable defining the time of each measurement{p_end}
{synopt :{opt obs}}the data in memory are from an observational study. One of {opt obs} and {opt rct} must be specified{p_end}
{synopt :{opt nocont:rols}}the observational data in memory contain no healthy 
controls. Can only be used with the obs option{p_end}
{synopt :{opt rct}}the data in memory are from an RCT. One of {opt obs} and {opt rct} must be specified{p_end}
{synopt :{opth case:con(varname)}}variable defining if a person is a case or healthy control. Required if and only if observational data is used.{p_end}
{synopt : {opth tr:eat(varname)}}variable defining if a person received the intervention. Required if and only if RCT data is used{p_end}

{syntab :Options for future study}
{p2coldent :* {opth sched:ule(numlist)}}the visit times for the proposed study. 
Visit times are assumed to be in the same time units as the time variable in the dataset, 
unless scale is specified{p_end}
{synopt :{opth drop:outs(numlist)}}the proportion of dropouts at each visit. 
Must correspond to the schedule list{p_end}
{synopt :{opt sca:le(#)}}The ratio between the time and schedule timescales{p_end}
{synopt :{opt a:lpha(#)}}significance level; default is 0.05{p_end}
{synopt :{opt pow:er(#)}}power; default is 0.8, required to compute sample size{p_end}
{synopt :{opt n(#)}}total sample size; required to compute power{p_end}
{synopt :{opt eff:ectiveness(#)}}the target effectiveness of the treatment to be trialled; default is 0.25{p_end}
{synopt :{opt uset:rt}}use the observed effectiveness of the treatment. Can only be used with the {opt rct} option.{p_end}

{syntab :Model options}
{synopt :{opt iter:ate(#)}}the maximum number of iterations allowed in the {cmd:mixed} model{p_end}
{synopt :{opt nocontv:ar}}omit the random slope variance and covariance for healthy controls in the {cmd:mixed} model{p_end}

{synoptline}
{pstd}*these options are required.
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:slopepower} performs a sample size or power calculation for a proposed two-arm
parallel group randomised clinical trial (RCT) where the outcome of interest is a slope 
measured over time, and the treatment is hoped to alter this slope to be more 
similar to the slope of people without the condition. The calculations are based 
partly upon data the user has read into Stata’s memory and partly on user input.
A linear mixed model is run (using {helpb mixed}) on the data in memory to estimate 
a plausible treatment effect variance, and the slope in those who are untreated; 
the remaining parameters are specified by the user. The data should come from either 
an observational study or a similar clinical trial and contain repeated measurements of 
the outcome in long format (see {helpb reshape} for more details). The data in memory 
will not be altered by this command. 


{marker options}{...}
{title:Options}

{dlgtab:Options for data in memory}

{phang}
{opth subj:ect(varname)} is the unique identifier for participants in the 
user-supplied data

{phang}
{opth time(varname)} is the time variable of visits in the dataset. 
This can be in any units (eg days, months, years). It is assumed to be time since 
start of observation for each individual. If it is not (for instance if it is 
an actual calendar date) slopepower will issue a warning  and rescale it accordingly.

{phang}
{opt obs}, {opt nocont:rols} and {opt rct} tell Stata the nature of the data in 
memory. Exactly one of {opt obs} and {opt rct} must be specified. 
{opt nocont:rols} should be used with {opt obs} if all the subjects in 
your observational data have the condition of interest (i.e. the data contain no healthy controls).

{phang}
{opth case:control(varname)} specifies the variable used to identify cases in observational
data; it can only be used with {opt obs}. It must be a binary 0/1 variable, with 
the cases coded as 1.

{phang}
{opth tr:eat(varname)} specifies the treatment variable when you are using RCT data; it can 
only be specified with {opt rct}. It must be a binary 0/1 variable, with the 
experimental group coded as 1.

{dlgtab:Options for planned trial}

{phang}
{opth sched:ule(numlist)} specifies the visit times for the proposed trial. A baseline
 visit at time 0 is assumed; this list should describe subsequent visits, in 
 whole number units of time. The default is to use the same time unit as the 
 time variable in the dataset. To use a different timescale, specify how many {opt time} units make 
 one {opt schedule} unit in the scale option.

{phang}
{opth drop:outs(numlist)} specifies the estimated proportion of dropouts you 
expect at each study visit. It must correspond exactly to the schedule list. 
Each number in the list is a proportion between 0 and 1; this is the fraction of
subjects (of those who start the study) you estimate will fail to attend that 
visit. We follow the pattern mixture method of Dawson and Lagakos.

{phang}
{opt sca:le(#)} specifies the ratio between the time and visit timescales. 
For instance, if the time variable in your dataset is in days, and you wish to have visits 
annually for three years, you would specify scale(365) and schedule(1 2 3)

{phang}
{opt a:lpha(#)} sets the significance level (also known as Type I error rate) 
to be used in the planned study. The default is alpha(0.05).

{phang}
{opt pow:er(#)} sets the power for the planned study. The default is power(0.8).
This option is required to compute the sample size.

{phang}
{opt n(#)} specifies the total number of participants who will be in the trial. 
If an odd number is given, (n-1) will be used to allow equal numbers per arm.
Only one of {opt pow:er} and {opt n} may be specified. This option is required to compute the power.

{phang}
{opt eff:ectiveness(#)} and {opt uset:rt} specify the effect size you would like 
to be able to detect in the future trial. {opt eff:ectiveness} specifies this effect size as
a proportion of the difference between cases and healthy controls in the observational 
data in memory. If RCT data, or observational data with no healthy controls, are used
{opt eff:ectiveness} is a proportion of the difference towards a slope of 0. 
This must be a number between 0 and 1; the default value is 0.25. {opt uset:rt} 
specifies that, when RCT data is used, the planned study is targeting 
the same effect size as estimated from the previous data. You can only specify one of {opt eff:ectiveness} and 
{opt uset:rt}.

{dlgtab:Model options}

{phang}
{opt iter:ate(#)} is used as an option in the {cmd:mixed} command; see {helpb maximize}.

{phang}
{opt nocontv:ar} specifies that the mixed model should not estimate a random slopes 
variance parameter or the covariance between random slopes and intercepts for healthy controls.
This is only applicable when you are using observational data with healthy controls.
Ignoring this variance and covariance may help the model to converge.

{marker examples}{...}
{title:Examples}
    {hline}
    Setup
{phang2}{cmd:. webuse nlswork, clear}{p_end}

{pstd}Use observational data, with no healthy controls, to calculate power of a trial 
with N=4000, with 5% loss to follow-up expected at one year and two years, and 
10% at years three and five{p_end}
{phang2}{cmd:. slopepower ln_wage , subject(id) time(year) obs nocontrols schedule(1 2 3 5) dropouts (0.05 0.05 0.1 0.1) n(4000)}{p_end}

 {hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:slopepower} stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p2col 5 20 20 4: Scalars}{p_end}
{synopt:{cmd:r(subjects_in_model)}}number of subjects that were used in the mixed model{p_end}
{synopt:{cmd:r(obs_in_model)}}number of observations that were used in the mixed model{p_end}
{synopt:{cmd:r(alpha)}}Type I error rate (significance level) of the planned trial{p_end}
{synopt:{cmd:r(power)}}power of the planned trial{p_end}
{synopt:{cmd:r(fupvisits)}}specified number of follow up visits{p_end}
{synopt:{cmd:r(sampsize)}}total sample size{p_end}
{synopt:{cmd:r(effectiveness)}}specified target effectiveness of the proposed treatment{p_end}
{synopt:{cmd:r(tte)}}target treatment effect{p_end}
{synopt:{cmd:r(var_tte)}}variance of the target treatment effect for a hypothetical future two-person trial{p_end}
{synopt:{cmd:r(slope_cases)}}the observed slope in the cases (if calculated){p_end}
{synopt:{cmd:r(slope_controls)}}the observed slope in the healthy controls (if calculated){p_end}
{synopt:{cmd:r(slope_untreated)}}the observed slope in the control arm of the previous RCT (if calculated){p_end}
{synopt:{cmd:r(slope_treated)}}the observed slope in the experimental arm of the previous RCT (if calculated){p_end}

{synoptset 18 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}table of results{p_end}

{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Chris Frost, Michael G. Kenward, Nick C. Fox. Optimizing the design of clinical 
trials where the outcome is a rate. Can estimating a baseline rate in a run-in 
period increase efficiency? Statist. Med. 2008; 27:3717–3731 doi: 10.1002/sim.3280

{phang}
JD Dawson, SW Lagakos. Analyzing laboratory marker changes in AIDS clinical 
trials. J AIDS 1991;4:667-676 PMID: 2051307

{phang}
Dawson JD, Lagakos SW. Size and power of two-sample tests of repeated measures 
data. Biometrics 1993;49:1022-1032

{marker Authors}{...}
{title:Authors}
Stephen Nash, Katy Morgan, Amy Mulick
London School of Hygiene and Tropical Medicine
London, UK
katy.morgan@lshtm.ac.uk
