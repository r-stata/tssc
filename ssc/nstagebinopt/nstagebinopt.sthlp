{smcl}
{* 09sept2014}{...}
{cmd:help for nstagebinopt}{right:MRC Clinical Trials Unit}
{hline}


{title:Admissible multi-arm, multi-stage (MAMS) trial designs for binary outcomes}


{title:Syntax}

{phang2}
{cmd:nstagebinopt,}
{it:required_options optional_options}


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:required}}
{synopt :{opt n:stage(#)}}{it:#} = {it:J}, the number of stages in the trial{p_end}
{synopt :{opt ar:ms(#)}}{it:#} = {it:K}+1, the number of arms at the start of the study (including control arm){p_end}
{synopt :{opt al:pha(#)}}overall type I error rate for each arm or for the trial as a whole (see {opt fwer}){p_end}
{synopt :{opt po:wer(#)}}overall pairwise power{p_end}
{synopt :{opt theta0(# [#])}}absolute risk difference under H0 for the I and D outcomes{p_end}
{synopt :{opt theta1(# [#])}}minimum target risk difference under H1 for the I and D outcomes{p_end}
{synopt :{opt c:trlp(# [#])}}control arm event rate for the I and D outcomes{p_end}
{synopt :{opt ara:tio(numlist)}}allocation ratios (number of patients allocated to each experimental arm per control arm patient) to consider in the search procedure{p_end}

{syntab :{it:required only if intermediate (I) and definitive (D) outcomes differ}}
{synopt :{opt ppv(#)}}positive predictive value P(D=1|I=1) for all arms in the trial{p_end}

{syntab :{it:optional}}
{synopt :{opt s:ave(filename)}}name of file in which to save the admissible designs{p_end}
{synopt :{opt fw:er}}specify that the familywise error rate of the trial should be controlled at the level specified in {opt alpha()}{p_end}
{synopt :{opt pi(#)}}minimum proportion of the maximum control arm sample size that should be recruited to the control in each stage{p_end}
{synopt :{opt p(numlist)}}define which alpha-functions should be used in the search procedure{p_end}
{synopt :{opt l:tfu(# [#])}}loss-to-follow-up rate for the I and D outcomes{p_end}
{synopt :{opt fu(#)}}length of follow-up period for the I outcome{p_end}
{synopt :{opt acc:rate(numlist)}}overall accrual rate in each stage{p_end}
{synopt :{opt acc(#)}}maximum deviation in alpha and power of feasible designs from values specified in {opt alpha()} and {opt power()} respectively{p_end}
{synopt :{opt plot}} plot the expected sample sizes used in the loss function for each admissible design

{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:nstagebinopt} searches for (K+1)-arm J-stage designs with binary intermediate (I) 
and definitive (D) outcomes which have the desired overall type I error rate and power
(feasible designs). The stagewise operating characteristics of feasible designs which minimise 
the Bayesian loss function (1-q)E(N|H0)+qE(N|HK) for some q between 0 and 1 are then reported. 
Here E(N|H0) is the expected sample size under the hypothesis that all arms in the study are 
ineffective and E(N|HK) is the expected sample size assuming all arms are effective. 



{title:Options}

{dlgtab:Required}

{phang}
{opt nstage(#)} specifies {it:J}, the number of stages in the trial.

{phang}
{opt arms(#)} specifies the total number of arms (including the control arm} at 
the start of the study.

{phang}
{opt alpha(#)} specifies the desired overall one-sided type I error rate of 
each pairwise comparison in the trial. If the {opt fwer} option is specified the value 
specified in {opt alpha()} is the desired familywise error rate of the study.

{phang}
{opt power(numlist)} specifies the overall power for each pairwise comparison
of the study.

{phang}
{opt theta0(# [#])} specifies the absolute difference in 
proportions under the null hypothesis for the I-outcome and D-outcome,
respectively. Typically these values are both 0. If I and D are the same
then only one value needs specifying.

{phang}
{opt theta1(# [#])} specifies the minimum target absolute difference in 
proportions under the alternative hypothesis for the I-outcome and 
D-outcome, respectively. Typically these values are either equal or the
target difference is smaller for the D-outcome. If I and D are the same
then only one value needs specifying.

{phang}
{opt ctrlp(# [#])} specifies the assumed control event rate for the
I-outcome and D-outcome, respectively. If I and D are the same
then only one value needs specifying.

{phang}
{opt aratio(numlist)} specifies the allocation ratios (number of patients allocated
to each experimental arm per control arm patient) that are to be considered in the
search procedure for admissible designs. Allocation ratios such as 1 (equal 
allocation to all arms) and/or 0.5 (1 patient allocated to each experimental arm
for every 2 patients allocated to control) are often used. Note that allocating
a higher proportion of patients to control can decrease sample size requirements 
if evaluating more than one experimental arm.



{dlgtab:Required only if I and D outcomes differ}

{phang}
{opt ppv(#)} specifies the positive predictive value,
that is, the probability of a patient experiencing the D-outcome given that
they have also experienced the I-outcome: P(D=1|I=1). This value is assumed 
to be the same for all arms in the study.



{dlgtab:Optional}

{phang}
{opt save(filename)} save the set of admissible designs in a dataset.

{phang}
{opt fwer} specify that the familywise error rate (FWER) should be controlled
at the level specified in {opt alpha()} rather than the type I error rate 
for each pairwise comparison. The familywise error rate is the probability 
of making at least one type I error (false positive) at the end of the trial.

{phang}
{opt pi(#)} specifies the minimum proportion of the maximum control arm sample size that 
should be recruited during each stage of the study. For instance, if the 
maximum control arm sample size is 500 and # = 0.1 then at least 50 patients will be  
recruited to the control arm during each stage. A higher value of # will increase the speed of 
the search procedure but may result in finding less efficient admissible designs. 
Default # is 0.1.

{phang}
{opt p(numlist)} defines which alpha-functions are to be used in the search procedure. Default 
{it: numlist} is 0, 0.25, 0.5 if I=D and 0, 0.25, 0.5, 0.75, 1 if I and D differ. 

{phang}
{opt ltfu(# [#])} specifies the loss-to-follow-up rate for the I outcome
and D outcome respectively. Typically the loss-to-follow-up rate is
larger for the D outcome than the I-outcome. If I and D are the same then only 
one value needs specifying. Default {it:#} is 0 (no loss-to-follow-up for either
outcome).

{phang}
{opt fu(#)} specifies the length of the follow-up period (in units of time) 
for the I outcome. The follow-up period on the D outcome should be the same 
or longer than that on the I outcome. If I and D are the same then only one 
value needs specifying. Default {it:#} is 0 (no follow-up period, i.e. outcomes 
observed immediately after randomisation).

{phang}
{opt accrate(numlist)} specifies the rate per unit of time 
at which patients enter the trial in each stage of the trial. Accrual rates should be on the 
same time-scale as used for {opt fu()}. This option only needs specifying 
if {opt fu()} is specified.

{phang}
{opt acc(#)} specifies the maximum deviation in overall alpha and power allowed in feasible 
designs from the desired values. Default # is 0.0005.

{phang}
{opt plot} produces a plot of the expected sample sizes under H0 and HK for each admissible design.



{title:Remarks}

{pstd}
{cmd:nstagebinopt} outputs the stagewise operating characteristics of admissible multi-arm multi-stage designs which minimise the loss function (1-q)E(N|H0)+qE(N|HK) for some q between 0 and 1. These design parameters can then be entered into the {opt nstagebin} program to see each design in more detail. 



{title:Examples}

{pstd}
Example in which a 4-arm 3-stage trial needs to be designed with overall pairwise type I error rate of 2.5% and overall pairwise power of 
90%. The I and D outcomes are identical and has a follow-up period of 1 month. The accrual rate is assumed to be 10 patients/month in each 
stage and the loss-to-follow-up rate is 10%. The minimum target difference under the alternative hypothesis is 15% and the control arm event rate is anticipated to be 40%. Only a 1:1 allocation ratio is to be considered.

{cmd:. nstagebinopt, nstage(3) arms(4) alpha(0.025) power(0.90)}
{cmd:                theta0(0) theta1(0.15) ctrlp(0.4) ltfu(0.1)}
{cmd:   	     fu(1) accrate(10 10 10) aratio(1)} 

{pstd}
Example in which a 6-arm 4-stage trial needs to be designed with 5% familywise error rate and 80% pairwise power. The I and D outcomes
differ and have minimum targeted treatment effects of 15% and 10% respectively. Follow-up on the I-outcome is 0.25 years (13 weeks) and the loss-to-follow-up rates are assumed to be 10% and 20% for I and D respectively. The positive predictive value is assumed to be 80% for each arm. A control:experimental allocation ratio of 2:1 is used. 

{cmd:. nstagebinopt, nstage(4) arms(6) alpha(0.05) power(0.8)}
{cmd:                theta0(0 0) theta1(0.15 0.1) ctrlp(0.7 0.6)}
{cmd:                fu(0.25 1) ltfu(0.1 0.2) aratio(0.5)}
{cmd:                ppv(0.8) accrate(200 200 300 600) fwer}                       


{title:Author}

{pstd}
Daniel Bratton, MRC Clinical Trials Unit at UCL, London.{break}
daniel.bratton@ucl.ac.uk


{title:References}

{phang}
Bratton DJ, Phillips PPJ, Parmar MKB. 2013. A multi-arm multi-stage clinical trial design for binary outcomes with application to tuberculosis. BMC Med Res Meth, 13:139. 


