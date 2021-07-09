{smcl}
{* *!version 0.1.0 13jul2012}{...}
{hline}
{cmd:help metasim}{right:also see:  {helpb metapow}, {helpb metapowplot}}
{hline}

{title:Title}

{p2colset 5 16 20 2}{...}
{p2col :{cmd:metasim} {hline 2}}Tool to simulate a new two-arm clinical trial(s) or diagnostic accuracy study(ies) using results from current meta-analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: metasim} {it:varlist} {cmd:,} {opt n:(#)} {opt es:(numlist)} {opt var:(numlist)} {opt type:(string)} [{it:options}]

{synoptset 17 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt:{opt n(#)}} number of patients in group 1 of the new study (see below) {p_end}
{synopt:{opt es(numlist)}} pooled estimate/s from current meta-analysis {p_end}
{synopt:{opt var(numlist)}} variance/s for {cmd:es} {p_end}
{synopt:{opt ty:pe(string)}} type of study being simulated {p_end}

{syntab :Optional}
{synopt:{opt meas:ure(string)}} outcome measure used in meta-analysis {p_end}
{synopt:{opt p(#)}} event rate or probability of being diseased dependent on ({it:type}) {p_end}
{synopt:{opt r(#)}} ratio of patients in two groups; treatment and control or diseased and healthy {p_end}
{synopt:{opt st:udies(#)}} number of new studies to be simulated {p_end}
{synopt:{opt mod:el(string)}} meta-analysis model used on pre-existing data {p_end}
{synopt:{opt tau:sq(numlist)}} between study variance in current meta-analysis {p_end}
{synopt:{opt dist(string)}} distribution of effect sizes used to simulate the new study from {p_end}
{synopt:{opt corr(#)}} correlation between sensitivity and specificity (diagnostic study only) {p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:metasim} simulates a specified number of new studies based on the estimate/s obtained from a pre-existing meta-analysis.
 The user should input a maximum of 6 variables. The program will then generate a new set of variables and save it in a file called 
 temppow within the working directory.


{title:Options}

{dlgtab:Main}

{phang}
{opt n(integer)} relates to the number of patients in the new study. If simulating a new clinical trial, then this specifies the number of patients 
in the control group. If simulating a new diagnostic accuracy study then {opt n} is the number of diseased patients when using sensitivity and 
specificity as the outcome measure of accuracy, or the number of positive test results if using the diagnostic odds ratio (DOR). {p_end}

{phang}
{opt es(numlist)} specifies the pooled estimate/s from the meta-analysis of existing studies. If using the odds ratio, the diagnostic odds ratio or 
relative risk then ln(OR), ln(DOR) or ln(RR) estimates need to be specified. If using sensitivity and specificity then logit(sensitivity) and 
logit(specificity) estimates need to be specified in that order. {p_end}
 
{phang}
{opt var(numlist)} specifies the variance/s for es. Need to specify two values if using sensitivity and specificity. {p_end}

{phang}
{opt type(clinical/diagnostic)} specifies the type of new study that the user would like to simulate; either a 2-arm clinical trial or a diagnostic test accuracy study. {p_end}

{dlgtab:Optional}

{phang}
{opt measure(or/rr/rd/nostandard/dor/ss)} specifies the outcome measure used in the meta-analysis to pool the results. The odds ratio ({it:or}), relative risk ({it:rr}), 
risk difference ({it:rd}) and unstandardised mean difference ({it:nostandard}) can only be used when simulating a new clinical study. The diagnostic odds ratio ({it:dor}) 
and sensitivity and specificity ({it:ss}) can only be used when simulating a new diagnostic accuracy study. The default for a clinical {opt type} study with 4 variables entered 
into the {it: varlist} is relative risk ({it:rr}, the default for a clinical {opt type} study with 6 variables entered into the {it: varlist} is unstandardised mean difference 
({it:nostandard} and the default for a diagnostic {opt type} study is sensitivity and specificity ({it:ss}).{p_end}

{phang}
{opt p(real)} if simulating a new clinical study then this is the estimated event rate in the control group in the new study. When simulating a new diagnostic study 
this is the estimated probability of being diseased given a positive result in the new study. When this option is not specified by the user, the program will 
calculate this value by averaging the probabilities across the studies included in the dataset memory. Note that {opt p} is only relevant in the diagnostic framework
when using the diagnostic odds ratio ({it: dor}) as the option in {opt measure}.  {p_end}

{phang}
{opt r(real)} is the ratio of patients in the control group to the treatment group when simulating a new clinical study. When simulating a new diagnostic accuracy 
study this is the ratio of diseased to healthy people if using sensitivity and specificity and the ratio of positive to negative results if using the DOR 
(default 1). {p_end}

{phang}
{opt studies(integer)} specifies the number of new studies to be simulated (default 1). 
When more than one are specified they are all assumed to have the same sample size. {p_end}

{phang}
{opt model(fixed/fixedi/random/randomi/bivariate)} defines the type of model used to meta-analyse the pre-existing data. The default is the fixed effect
 Mantel-Haenszel method ({it:fixed}) unless the outcome measure is the nonstandardised mean difference in which case the default is the inverse variance method ({it:fixedi}).
 The ({it:fixedi}) option specifies a fixed effect model using the inverse variance method.  The ({it:random}) 
 option uses the random effect DerSimonian & Laird method, taking the estimate for heterogeneity from the Mantel-Haenszel method. The ({it:randomi}) option 
 specifies a random effects model using the method of DerSimonian and Laird, with the estimate of heterogeneity being taken from the inverse-variance 
 fixed-effect model. All of the above options call on the {helpb metan} command within the program. The final option is the bivariate random effects 
 model ({it:bivariate}). This method calls on a combination of the {helpb metandi} and {helpb midas} commands. It may only be specified 
 when simulating a new diagnostic accuracy study. {p_end}
 
{phang}
{opt tausq(numlist)} is the measure of between study variance taken from the pre-existing meta-analysis (default 0). If the user specifies sensitivity and specificity
({it:ss}) as the measure then two values must be entered for tausq. {p_end}

{phang}
{opt dist(normal/t)} specifies the distribution of effect sizes used to sample a value from in order to simulate a new study(ies). 
The default for the ({it:random}) and ({it:randomi}) is a predictive distribution based on the t-distribution ({it:t}) allowing 
for heterogeneity between studies (and the uncertainty in the heterogeneity). 
The default for all other models is the ({it:normal}) distribution based on the mean and variance entered in {opt es} and {opt var}. {p_end}

{phang}
{opt corr(real)} is the correlation between the sensitivity and specificity (default 0). This option is only needed if the user chooses the bivariate model. {p_end}


{title:Examples}

{pstd}Simulating a new clinical trial with 100 patients in each group. The current fixed effect meta-analytic estimate of the pre-existing clinical trial has a pooled odds
ratio of 2 (variance 0.5).{p_end}

{phang}{cmd:. metasim e_trt ne_trt e_ctrl ne_ctrl, model(fixed) measure(or) es(2) var(0.5) n(100) type(clinical)}{p_end}


{pstd}Simulating a new clinical trial with 100 patients in the control group and 50 patients in the experimental treatment group. The current random effects meta-analytic
estimate of the pre-existing clinical trail has a pooled relative risk of 1.5 (variance 0.2).{p_end}

{phang}{cmd:. metasim e_trt ne_trt e_ctrl ne_ctrl, model(random) measure(rr) es(1.5) var(0.2) tausq(0.1) n(100) type(clinical) r(0.5)}{p_end}


{pstd}Simulating a new diagnostic test accuracy study assuming 80 patients in both the diseased group and the healthy group. A fixed effect meta-analysis of the pre-existing
diagnostic test studies has a pooled logit sensitivity of 1.2 (variance 0.1) and a pooled logit specificity of 1.7 (variance 0.15).{p_end}

{phang}{cmd:. metasim TP FP FN TN, model(fixed) measure(ss) es(1.2 1.7) var(0.1 0.15) n(100) type(diagnostic)}{p_end}


{pstd}Simulating a new diagnostic test accuracy study assuming 80 patients in both the diseased and the healthy group of the new study. 
A bivariate random effects meta-analysis of the pre-existing diagnostic test studies has a pooled logit sensitivity of 1.5 (variance 0.4) 
and a pooled logit specificity of 1.3 (variance 0.45).{p_end}

{phang}{cmd:. metasim TP FP FN TN, model(bivariate) measure(ss) es(1.5 1.3) var(0.4 0.45) n(80) type(diagnostic)}{p_end}


{title:Authors}

{pstd}Michael J. Crowther, University of Leicester, United Kingdom. Email: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{pstd}Sally R. Hinchliffe, University of Leicester, United Kingdom. Email: {browse "mailto:srh20@le.ac.uk":srh20@le.ac.uk}.{p_end}

{pstd}Alison Donald, University of Leicester, United Kingdom.

{pstd}Alex J. Sutton, University of Leicester, United Kingdom. Email: {browse "mailto:ajs22@le.ac.uk":ajs22@le.ac.uk}.{p_end}
 

{title:References}

{phang}Hinchliffe S, Crowther MJ, Phillips RS, Sutton AJ. Using meta-analysis to inform the design of subsequent studies of diagnostic test accuracy (Submitted) {p_end}

{phang}Ferreira ML, Herbert RD, Crowther MJ, Verhagen A, Sutton AJ. When is another clinical trial justified? (Submitted){p_end}

{phang}Sutton AJ, Cooper NJ, Jones DR, Lambert PC, Thompson JR, Abrams KR. Evidence-based sample size calculations based upon meta-analysis. {it:Statistics in Medicine} 2007; 26:2479-2500.{p_end}


{title:Also see}

{psee}
Online: {helpb metapow}, {helpb metapowplot}
{p_end}
