{smcl}
{* 01sept2013}{...}
{cmd:help for nstagebin}{right:MRC Clinical Trials Unit}
{hline}


{title:Multi-arm, multi-stage (MAMS) trial designs for binary outcomes}


{title:Syntax}

{phang2}
{cmd:nstagebin,}
{it:required_options optional_options}


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:required}}
{synopt :{opt n:stage(#)}}{it:#} = {it:J}, the number of trial stages{p_end}
{synopt :{opt ac:crate(numlist)}}overall accrual rate in each stage{p_end}
{synopt :{opt al:pha(numlist)}}one-sided alpha (type 1 error probability) for each stage{p_end}
{synopt :{opt po:wer(numlist)}}power (one minus type 2 error probability) for each stage{p_end}
{synopt :{opt ar:ms(numlist)}}number of arms recruiting at each stage (including control arm){p_end}
{synopt :{opt theta0(# [#])}}target treatment effect under H0 for the I and D outcomes{p_end}
{synopt :{opt theta1(# [#])}}target treatment effect under H1 for the I and D outcomes{p_end}
{synopt :{opt c:trlp(# [#])}}control arm event rate for the I and D outcomes{p_end}


{syntab :{it:required only if intermediate (I) and definitive (D) outcomes differ}}
{synopt :{opt ppvc(#)}}positive predictive value for the control arm{p_end}
{synopt :{opt ppve(#)}}positive predictive value for each experimental arm{p_end}

{syntab :{it:optional}}
{synopt :{opt ara:tio(#)}}allocation ratio (number of patients allocated to each experimental arm per control arm patient){p_end}
{synopt :{opt f:u(# [#])}}length of follow-up period for the I and D outcomes{p_end}
{synopt :{opt ex:trat(#)}}delay between observing last required outcome for each analysis and next stage of the trial{p_end}
{synopt :{opt l:tfu(# [#])}}loss-to-follow-up rate for the I and D outcomes{p_end}
{synopt :{opt tunit(#)}}code for units of trial time{p_end}
{synopt :{opt probs}}reports probabilities of the number of arms reaching each stage{p_end}
{synopt :{opt ess}}reports the expected sample sizes{p_end}
{synopt :{opt nofwer}}suppress the calculation of the familywise error rate{p_end}


{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:nstagebin} specifies the design (sample size, 
duration and overall pairwise operating characteristics) of a multi-arm, 
multi-stage (MAMS) trial using a binary intermediate (I) outcome 
at the interim stages and a binary definitive (D) outcome 
at the final stage, both analysed using an absolute difference 
in proportions. See Bratton, Phillips & Parmar (2013) for a description
of the design and Royston, Barthel, Parmar, Oskooei & Isham (2011) for 
a description of a similar MAMS design for time-to-event outcomes.


{title:Options}

{dlgtab:Required}

{phang}
{opt nstage(#)} specifies {it:J}, the number of trial stages.

{phang}
{opt accrate(numlist)} specifies the rate per unit of time 
(see {opt tunit()}) at which patients enter the trial during each stage. 
The patients are assumed to be allocated in the ratio 
(control arm:experimental arm: ...) of 1:{it:p}:...:{it:p}, where {it:p} 
is the allocation ratio defined by {opt aratio()}.

{phang}
{opt alpha(numlist)} specifies the one-sided significance level at each
stage. For the first {it:J} - 1 stages each experimental arm is compared with the
control on the intermediate outcome, whereas at the {it:s}th stage the 
comparison is on the primary outcome. Experimental arms pass a particular
stage of the trial if their observed treatment effect is significant at the
corresponding pre-specified one-sided significance level.

{phang}
{opt power(numlist)} specifies the power (one minus the type 2 error
probability) for each pairwise comparison at each stage. See also {opt alpha()}.
 
{phang}
{opt arms(numlist)} specifies the number of arms assumed to be 
actively recruiting patients at each stage. The number at stage 2 and
subsequently cannot exceed the number at stage 1, since arms can only
be 'dropped' not added. For example, {cmd:arms(4 3 2)} would say that
in a 3-stage trial of 4 arms only 3 continued to the second stage and
2 to the final stage.

{phang}
{opt theta0(# [#])} specifies the target absolute difference in 
proportions under the null hypothesis for the I-outcome and D-outcome,
respectively. Typically these values are both 0. If I and D are the same
then only one value needs specifying.

{phang}
{opt theta1(# [#])} specifies the target absolute difference in 
proportions under the alternative hypothesis for the I-outcome and 
D-outcome, respectively. Typically these values are either equal or the
target difference is smaller for the D-outcome. If I and D are the same
then only one value needs specifying.

{phang}
{opt ctrlp(# [#])} specifies the assumed control event rate for the
I-outcome and D-outcome, respectively. If I and D are the same
then only one value needs specifying.


{dlgtab:Required only if I and D outcomes differ}

{phang}
{opt ppvc(#)} specifies the positive predictive value for the control arm,
that is, the probability of a patient experiencing the D-outcome given that
they have also experienced the I-outcome: P(D=1|I=1).

{phang}
{opt ppve(#)} specifies the positive predictive value for the experimental arms
(see also {opt ppvc()}).


{dlgtab:Optional}

{phang}
{opt aratio(#)} specifies the allocation ratio (number of patients allocated
to each experimental arm per control arm patient). Default {it:#} is 1 (equal
allocation to all arms).

{phang}
{opt fu(# [#])} specifies the length of the follow-up period (in units of time
- see {opt tunit()}) for the I-outcome and D-outcome, respectively. 
The follow-up period on the D-outcome should be the same or longer than that 
on the I-outcome. If I and D are the same then only one value needs specifying. 
Default {it:#} is 0 (no follow-up period for either outcome). 

{phang}
{opt extrat(#)} specifies the delay in units of trial time (see {opt tunit()}) 
between observing the final required outcome for an analysis and the beginning of 
the next stage. This delay incorporates time for data cleaning, analysis and the 
various committee meetings that are usually required. Default # is 0 (no delay).

{phang}
{opt ltfu(# [#])} specifies the loss-to-follow-up rate for the I-outcome
and D-outcome respectively. Typically the loss-to-follow-up rate is
larger for the D-outcome than the I-outcome. If I and D are the same then only 
one value needs specifying. Default {it:#} is 0 (no loss-to-follow-up for either
outcome).

{phang}
{opt tunit(#)} defines the code for units of trial time. The codes are 1 = one year, 2 = 6 months, 
3 = one quarter (3 months), 4 = one month, 5 = one week, 6 = one day, 7 = unspecified. {opt tunit()} 
has no influence on the computations and is for information only. Default {it:#} is 1 (one year).

{phang}
{opt probs} reports probabilties of the number of arms reaching stages 2,...,J of the trial
under the global null (no arms effective) and the global alternative (all arms effective) hypotheses.

{phang}
{opt ess} reports the expected sample size of the trial when either none or all of the experimental treatment arms are effective.

{phang}
{opt nofwer} suppresses the calculation of the maximum familywise error rate of the trial (probability of making at least one type I error at the end of the trial under the global null hypothesis)




{title:Remarks}

{pstd}
{cmd:nstagebin} reports the sample size required for each analysis and the cumulative number of patients allocated to each remaining treatment arm at the end of each stage. Also reported is the cumulative number of patients recruited to the trial at the end of each stage (including those patients allocated to arms dropped in previous stages).


{title:Examples}

{pstd}
Example of a 4-arm 3-stage trial where the I-outcome and D-outcome is the same and has a follow-up period of 1 month. The accrual rate is assumed to be 10 patients/month in each stage and the loss-to-follow-up rate is 10%. One-sided significance 
levels of 30%, 15% and 2.5% and powers of 95%, 95% and 90% are used in the 1st, 2nd and 3rd stages respectively. All four arms are assumed to continue to the second stage of the trial, and only two are assumed to continue to the final stage.

{cmd:. nstagebin, nstage(3) accrate(10 10 10) alpha(0.3 0.15 0.025)}
{cmd:             power(0.95 0.95 0.90) arms(4 4 2) theta0(0)}
{cmd:   	  theta1(0.15) ctrlp(0.8) fu(1) ltfu(0.1) tunit(4)} 

{pstd}
Example of a 6-arm 4-stage trial where the I-outcome and D-outcome differ and have target treatment effects of 15% and 10% respectively. Follow-up on the I-outcome is 0.25 years (13 weeks) and 1 year for the D-outcome and the loss-to-follow-up 
rates are assumed to be 10% and 20% respectively. The positive predictive value is assumed to be 80% for the control and experimental arms. A control:experimental allocation ratio of 2:1 is used.

{cmd:. nstagebin, nstage(4) accrate(200 200 300 600) alpha(0.5 0.25 0.1 0.05)}
{cmd:             power(0.95 0.95 0.95 0.90) arms(6 5 4 2) theta0(0 0)}
{cmd:             theta1(0.15 0.1) ctrlp(0.7 0.6) fu(0.25 1) ltfu(0.1 0.2)}
{cmd:             aratio(0.5) ppvc(0.8) ppve(0.8)}                       


{title:Author}

{pstd}
Daniel Bratton, MRC Clinical Trials Unit at UCL, London.{break}
daniel.bratton@ucl.ac.uk


{title:References}

{phang}
Bratton DJ, Phillips PPJ, Parmar MKB. 2013. A multi-arm multi-stage clinical trial design for binary outcomes with application to tuberculosis. BMC Med Res Meth, 13:139. 

{phang}
Royston P, Barthel FMS, Parmar MKB, Choodari-Oskooei B, Isham V. 2011. Designs for clinical trials with time-to-event outcomes based on stopping guidelines for lack of benefit. Trials, 12:81.

