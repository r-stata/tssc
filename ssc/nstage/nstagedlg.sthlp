{smcl}
{* *! version 3.0.0 26sep2014}{...}
{cmd:help nstagedlg}{right: ({browse "http://www.stata-journal.com/article.html?article=st0175_1":SJ15-2: st0175_1})}
{hline}

{title:Overview}

{pstd}
The dialog box will help you to specify the design (sample size, rate of
patient accrual, and duration of accrual) of a multiarm, multistage trial
using an intermediate outcome (I outcome) at the intermediate stages and a
definitive or primary outcome (D outcome) at the final stage.  See Royston,
Parmar, and Qian (2003) and Royston et al. (2011) for details of the design
and some examples, and see Bratton, Choodari-Oskooei, and Royston (2015) for
further explanations of Stata-related aspects and details of algorithms used.

{pstd}
Additionally, the program can assist you in designing a conventional
(one-stage, parallel-group) randomized clinical trial with a survival-time
outcome.  To do this, you specify the {it:Design for one stage only} option.

{pstd}
The program can handle unequal allocation of patients to control and
experimental arms (but is limited to equal allocation to all experimental
arms).  The allocation ratio must be the same at all stages.

{pstd}
You can specify the time at which accrual is to cease.  If this time is not
specified, accrual is assumed to continue until enough events have accumulated
for the analysis to be done.  Otherwise, accrual ceases at the indicated time,
and the trial continues, while the required events are awaited in the patients
already recruited.

{pstd}
If the accrual period is too short, the design is infeasible and an error
message is issued.

{pstd}
The outputs from the program include the following:{p_end}

{pmore}
1. The numbers of patients and events in the control arm, accumulated across
the experimental arms and overall, at all stages.

{pmore}
2. The durations of each stage individually and overall, that is, the times
from randomization to the times expected to accrue the requisite numbers of
events.

{pmore}
3. The pairwise and familywise type I error rate and the overall power

{pstd}
In what follows, most of the defaults are provided for the purpose of
illustration.  They are not necessarily appropriate for your trial.


{title:Design parameter panel}

{phang}
{it:Total number of stages}. (default 1) The number of stages in the trial.  If
you enter 1, the trial will be treated as a conventional (one-stage) design,
and the parameters regarding intermediate stages will be ignored.

{phang}
{it: Allocation ratio}. (default 1) The number of patients allocated to each
experimental arm per patient allocated to the control arm.  This can be
fractional.  For example, 0.5 means that each experimental arm would receive
half as many patients as the control arm.

{phang}
{it: Time unit}. (default 1 year) The units of trial time.

{phang}
{it:Time of stopping accrual}. The time that patient accrual is to cease, in
the same units as used in the accrual rate.  If this time is not specified,
accrual is assumed to continue until enough events have accumulated for the
analysis to be carried out.

{phang}
{it:Show probabilities}. Checking this box displays a table of estimated
probabilities of 0, 1, ... experimental arms passing from one stage to the
next, under the null and alternative hypothesis.  To pass, an arm must have a
hazard ratio (HR) for I events less than the critical HR.  The latter quantity
is reported by the program as {it:Crit. HR}.  For example, the chance of at
least one arm passing under H0 is one minus the reported probability for zero
arms.

{phang}
{it: Calculate FWER}. Checking this box estimates and presents the familywise
error rate for the design specified.

{phang}
{it: Control the FWER}. Specifies that nstage should search for a design which 
strongly controls the FWER at the specified level.

{phang}
{it:Non-binding boundaries}. Checking this box assumes non-binding stopping 
boundaries for lack-of-benefit when the operating characteristics are estimated. 
If control of the FWER has been specified, non-binding boundaries are assumed to 
ensure strong control. This option has no impact when I and D differ, since non-
binding boundaries are assumed in this case by default.

{title:Operating characteristics panel}

{phang}
{it:Total accrual rate}. (default 200/time unit) The rates at which patients
are entered into the control arm and all experimental arms at each stage.  A
uniform rate of accrual is assumed at each stage.  Note that the time units
used here are arbitrary but typically will be years.  You must also specify
the other parameters involving time in the same units.  The default values are
for illustration only.

{phang}
{it:Number of recruiting arms}. (default 5) The number of arms in the trial,
that is, one control arm plus the number of experimental arms, at each stage.
Arms may be dropped at each intermediate stage but may not be added.  If you
enter 0 for the Stage 2 arms, the trial will be treated as a conventional
(one-stage) design, and the other parameters will be ignored.  Otherwise,
parameter values are required for each stage.  The default setting is for
illustration only.

{phang}
{it:Significance level (one-sided)}. (default .2) The one-sided Type 1 error
probability.  Specify alpha/2 if a 2-sided error probability is required (for
example, 0.025 for 2-sided alpha of 0.05).  The values at each intermediate
stage should differ and should be reduced with each successive stage.

{phang}
{it:Power}. (default .95) The required power for test of HR for I events at
the intermediate stages and test for D events at the final stage, considered
independently.  Values at each intermediate stage may differ.

{title:Intermediate outcome and primary outcome panels}

{phang}
{it:Survival probability} (default 0.5). The probability of no I event in
(0,t1] and the probability of no D event in (0,t2], respectively, where t1 and
t2 are the times specified in the {it:Survival time} edit box.

{phang}
{it:Survival time}. (default 1.5) The time to I event and to D event with
corresponding probabilities specified in the {it:Survival probability} edit
box.  The default values are for illustration only.

{phang}
{it:Hazard ratio under H0}. (default 1) The HR for experimental arms to the
control arm under the null hypothesis.  The value for the intermediate stages
is the HR for I events, and the value for the final stage is HR for D events.
Usually one but may be less than one.

{phang}
{it:Hazard ratio under H1}. (default 0.75, 0.75) Hazard ratio for experimental
group to control group under the alternative (alternate) hypothesis.  The value
for the intermediate stages is HR for I events, and the value for the final
stage is HR for D events.  Must be less than one.

{phang}
{it:Correlation between HRs on I and D outcomes}. This measures the strength
of association between the treatment effects on the I and D outcomes at a
fixed time point (for example, the end of the follow-up).  The correlation can
be estimated by applying bootstrap analysis to trial data similar to that
expected in the new trial.  We suggest a default value of 0.6 for this
parameter.  If you have no idea of the value, we suggest a sensitivity analysis
in the range [0.4, 0.8].  The correlation value affects only the overall
significance level and power of the design.  If you have only one outcome type,
the correlation is not required because the program knows how to calculate the
necessary correlation structure.

{phang}
{it:Efficacy stopping rules (one-sided)}. This option specifies the use of 
efficacy stopping boundaries at interim analyses, with the rule chosen from a 
drop-down menu. One p-value can be input for the Haybittle-Peto rule, with the 
default set at 0.0005. The overall alpha to be spent for the O'Brien-Fleming 
type rule is already defined by the final stage significance level in the 
operating characteristics panel. The custom rule allows the user to specify J-1 
p-values for each interim stage analysis, separated by spaces. These should be 
monotonically increasing.

{title:References}

{phang}
Bratton, D. J., B. Choodari-Oskooei, P. Royston. 2015. 
{browse "http://www.stata-journal.com/article.html?article=st0175_1":A menu-driven facility for sample-size calculation in multiarm multistage randomized controlled trials with time-to-event outcomes: Update}.
{it:Stata Journal} 15: 350-368.

{phang}
Barthel, F. M.-S., P. Royston, and M. K. B. Parmar. 2009.
{browse "http://www.stata-journal.com/article.html?article=st0175":A menu-driven facility for sample-size calculation in novel multiarm, multistage randomized controlled trials with a time-to-event outcome}.
{it:Stata Journal} 9: 505-523.

{phang}
Royston, P., F. M.-S. Barthel, M. K. B. Parmar, B. Choodari-Oskooei, and
V. Isham. 2011. Designs for clinical trials with time-to-event outcomes
based on stopping guidelines for lack of benefit. {it:Trials} 12: 81.

{phang}
Royston, P., M. K. B. Parmar, and W. Qian. 2003. Novel designs for multi-arm
clinical trials with survival outcomes with an application in ovarian cancer.
{it:Statistics in Medicine} 22: 2239-2256.


{title:Authors}

{pstd}
Patrick Royston{break}
MRC Clinical Trials Unit{break}
University College London{break}
London, UK{break}
j.royston@ucl.ac.uk

{pstd}
Daniel J. Bratton{break}
MRC Clinical Trials Unit{break}
University College London{break}
London, UK{break}
d.bratton@ucl.ac.uk

{pstd}
Babak Choodari-Oskooei{break}
MRC Clinical Trials Unit{break}
University College London{break}
London, UK{break}
b.choodari-oskooei@ucl.ac.uk

{pstd}
Alexandra Blenkinsop{break}
MRC Clinical Trials Unit{break}
University College London{break}
London, UK{break}
alexandra.blenkinsop.16@ucl.ac.uk

{pstd}
Friederike Maria-Sophie (Sophie) Barthel{break}
Independent consultant


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=st0175_1":st0175_1}{p_end}
                    {it:Stata Journal}, volume 9, number 4: {browse "http://www.stata-journal.com/article.html?article=st0175":st0175}

{p 7 14 2}Help:  {helpb nstage} (if installed){p_end}
