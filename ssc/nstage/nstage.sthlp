{smcl}
{* 10Oct2013}{...}
{cmd:help nstage}{right: ({browse "http://www.stata-journal.com/article.html?article=st0175_1":SJ15-2: st0175_1})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:nstage} {hline 2}}Multiarm, multistage (MAMS) trial designs for time-to-event outcomes{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:nstage,}
{opt n:stage(#)}
{opt ac:crue(numlist)}
{opt al:pha(numlist)}
{opt o:mega(numlist)}
{opt ar:ms(numlist)}
{opt hr0(# [#])}
{opt hr1(# [#])}
{opt t(# [#])} [{it:options}]

{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt n:stage(#)}}{it:#} = J, the number of trial stages{p_end}
{p2coldent:* {opt ac:crue(numlist)}}overall accrual rate per unit of trial time in each stage{p_end}
{p2coldent:* {opt al:pha(numlist)}}one-sided alpha (type 1 error probability) for each stage{p_end}
{p2coldent:* {opt o:mega(numlist)}}power (one minus type 2 error probability) for each stage{p_end}
{p2coldent:* {opt ar:ms(numlist)}}number of arms recruiting at each stage (including control arm){p_end}
{p2coldent:* {opt hr0(# [#])}}target hazard ratio under H0 for the I outcome and D outcome{p_end}
{p2coldent:* {opt hr1(# [#])}}target hazard ratio under H1 for the I outcome and D outcome{p_end}
{p2coldent:* {opt t(# [#])}}time corresponding to survival probability in {cmd:s()} for an I event and a D event{p_end}
{synopt :{opt s(# [#])}}survival probability for an I event and a D event corresponding to survival time in {cmd:t()}{p_end}
{synopt :{opt ara:tio(#)}}allocation ratio (number of patients allocated to each experimental arm per control arm patient){p_end}
{synopt :{opt tu:nit(#)}}code for units of trial time{p_end}
{synopt :{opt ts:top(#)}}time at which recruitment is to cease{p_end}
{synopt :{opt pr:obs}}reports probabilities of the number of arms passing each stage under the global null hypothesis{p_end}
{synopt :{opt nof:wer}}suppress the calculation of the familywise error rate{p_end}
{synopt :{opt sim:corr(#)}}number of replicates in the simulations to estimate the correlation structure{p_end}
{synopt :{opt corr(#)}}correlation between treatment effects on I and D outcomes at a fixed time point or, if {cmd:simcorr()} is specified, the correlation between survival times on the I (excluding D) and D outcomes{p_end}
{synopt :{opt esb(string[,stop])}}assess for evidence of overwhelming efficacy at interim stages when lack-of-benefit assessments occur, with the efficacy stopping rule specified by the user{p_end}
{synopt :{opt nonbind:ing:}}assume non-binding stopping boundaries for lack-of-benefit{p_end}
{synopt :{opt fwer:control(#)}}search for a design which strongly controls the FWER at the specified level{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt nstage(#)}, {opt accrue(numlist)}, {opt alpha(numlist)}, {opt omega(numlist)}, {opt arms(numlist)}, {opt hr0(# [#])}, {opt hr1(# [#])}, and {opt t(# [#])} are required.


{title:Description}

{pstd}
{cmd:nstage} is intended to help specify the design (sample size, duration, or
overall operating characteristics) of a multiarm, multistage (MAMS) trial
using an intermediate outcome (I outcome) at the intermediate stages and a
definitive or primary outcome (D outcome) at the final stage.  See Royston et
al. (2011) for details of the design and some examples; see Barthel, Royston,
and Parmar (2009) and Bratton, Choodari-Oskooei, and Royston (2015) for
further explanations of Stata-related aspects and details of algorithms used.


{title:Options}

{phang}
{opt nstage(#)} specifies the number of trial stages, J.  {cmd:nstage()} is
required.

{phang}
{opt accrue(numlist)} specifies the rate per unit of trial time (see
{cmd:tunit()}) at which patients enter the trial during each stage.  The
patients are assumed to be allocated in the ratio (control arm:experimental
arm: ...) of 1:A:...:A, where A is the allocation ratio defined by
{cmd:aratio()}.  {cmd:accrue()} is required.

{phang}
{opt alpha(numlist)} specifies the one-sided significance level at each stage.
The arms are compared pairwise with control on the intermediate outcome for
the first J - 1 stages, whereas the comparison is on the primary outcome at
the Jth stage.  Significance levels should decrease with each stage.
{cmd:alpha()} is required.

{phang}
{opt omega(numlist)} specifies the power (one minus the type 2 error
probability) for each pairwise comparison at each stage.  {cmd:omega()} is
required.

{phang}
{opt arms(numlist)} specifies the number of arms assumed to be actively
recruiting patients at each stage.  The number at each stage cannot exceed the
number at the previous stage, because arms can only be "dropped" (not added).
For example, {cmd:arms(4 3 2)} would say that in a three-stage trial of four
arms, only three survived to the second stage, and only two survived to the
final stage.  {cmd:arms()} is required.

{phang}
{opt hr0(# [#])} specifies the hazard ratios under the null hypothesis for the
I outcome and D outcome, respectively.  Typically, these values are both 1.
{cmd:hr0()} is required.

{phang}
{opt hr1(# [#])} specifies the hazard ratios under the alternative hypothesis
for the I outcome and D outcome, respectively.  Typically, the size of the
targeted effect is larger for the I outcome than the D outcome.  {cmd:hr1()}
is required.

{phang}
{opt t(# [#])} defines the times corresponding to the survival probabilities
in {cmd:s()} for an I event and a D event, respectively.  If the default
values of 0.5 for {cmd:s()} are used, then the required values of {cmd:t()}
are the median survival times for each type of outcome.  Note that the
survival distribution for both types of events is assumed to be exponential.
{cmd:t()} is required.

{phang}
{opt s(# [#])} defines the survival probability for an I event and a D event,
respectively, that is, the probability of no event in intervals defined by
{cmd:t()}.  For example, {cmd:s(0.5 0.75)} would say that the survival
probability in the relevant interval was 0.5 for I outcomes and 0.75 for D
outcomes.  The default is {cmd:s(0.5 0.5)}.

{phang}
{opt aratio(#)} specifies the allocation ratio (number of patients allocated
to each experimental arm per control arm patient).  For example,
{cmd:aratio(0.5)} specifies that one patient is allocated to each experimental
arm for every two patients allocated to control.  The default is
{cmd:aratio(1)} (equal allocation to all arms).

{phang}
{opt tunit(#)} defines the code for units of trial time.  The codes are
{cmd:1} = one year, {cmd:2} = 6 months, {cmd:3} = one quarter (3 months),
{cmd:4} = one month, {cmd:5} = one week, {cmd:6} = one day, and {cmd:7} =
unspecified.  {cmd:tunit()} has no influence on the computations and is for
information only.  The default is {cmd:tunit(1)} (one year).

{phang}
{opt tstop(#)} defines the time at which recruitment is to cease.  To be valid
and to make sense in the context of the MAMS design, {it:#} must be a time
that falls within the final stage.  If it does not, an error will be reported.
The default is {cmd:tstop(0)}, meaning no ceasing of recruitment before the
end of the final stage.

{phang}
{cmd:probs} reports the probabilities of the numbers of arms passing each
stage of the trial under the global null hypothesis.

{phang}
{cmd:nofwer} suppresses the calculation of the maximum familywise error rate
of the trial (probability of making any type I error at the end of the trial
under any parameter configuration).

{phang}
{opt simcorr(#)} defines the number of replicates in the simulations to
estimate the between-stage correlation structure.  The estimated correlation
structure is used to compute the overall type I error rate and power of the
design.  At least 1,000 replicates are recommended.  If {cmd:simcorr()} is not
specified, the program uses the default correlation structure described by
Royston et al. (2011).  This option does not need to be specified if the I and
D outcomes are identical.

{phang}
{opt corr(#)} specifies either a) the correlation between hazard ratios on the
I and D outcomes at a fixed timepoint, such as the end of the trial; or b) if
{cmd:simcorr()} is specified, the correlation between survival times on the I
(excluding D) and D outcomes.  If a), the value of {it:#} can be estimated by
a bootstrap analysis of relevant previous trial data.  In both cases, the
default is {cmd:corr(0.6)} based on I = time to progression or death and D =
time to death in cancer.  Such a value is not necessarily appropriate in other
settings.  In the absence of knowledge, we suggest a sensitivity analysis for
{it:#} in the range [0.4, 0.8].  Note that this option affects only the
overall type I error rate and power of the design.  This option does not need
to be specified if the I and D outcomes are identical.

{phang}
{opt esb(string[,stop])} specifies that each interim stage is to be assessed against 
efficacy bounds. The efficacy stopping rules available are as follows. 
{cmd:hp[=#]} specifies the Haybittle-Peto stopping rule, with # the constant 
one-sided p-value for stages 1 to J-1 (default p=0.0005 if # unspecified.) 
{cmd:obf} specifies an O'Brien-Fleming-type stopping rule, which takes the final 
stage significance level for lack-of-benefit to generate efficacy bounds for 
each stage using an alpha-spending function (See Lan and DeMets, 1993).
{cmd:custom=#...#} specifies custom p-values for each interim stage. P-values 
must be one-sided and non-decreasing. When estimating the operating characteristics
of the design, the program assumes the trial continues with the remaining arms 
should any research arm cross the efficacy bound. However the option {cmd:stop} 
specifies that the trial should terminate recruitment to all research arms should 
any cross the efficacy bound at an interim stage.

{phang}
{opt nb} specifies that nstage should assume non-binding stopping boundaries for
lack-of-benefit when estimating the operating characteristics of the design. If 
unspecified nstage assumes the stopping boundaries are binding.

{phang}
{opt fwercontrol(#)} instructs nstage to perform an iterative search to identify 
the value of alpha at stage J which will control the FWER at the value # 
specified by the user. The output produced by nstage calculates the sample size 
and operating characteristics of the design which coontrols the FWER.

{phang}
{opt fwerreps(#)} indicates the number of replicates carried out by the simulation
procedure to calculate the FWER. The default is set to 250,000 for designs stopping
early for lack-of-benefit only and 1,000,000 for designs which also stop early 
for efficacy. Reducing the number of replicates will result in a faster procedure 
but at the cost of precision.


{title:Remarks}

{pstd}
A dialog box (see {helpb nstagemenu}) is provided to make specifying a MAMS
trial easier.  Use of the dialog box creates the necessary options and
arguments for {cmd:nstage}.

{pstd}
{cmd:nstage} reports the cumulative number of events in all the remaining
experimental arms at each stage.  The events are I events for the first J - 1
stages and D events for the final stage.  When arms are "dropped", as
determined by the {opt arms()} option, their events occurring after the stage
in which they were dropped are not counted in the number reported in the
columns headed {cmd:Overall} and {cmd:Exper.}.  Thus the number of D events
reported at the final stage is relevant to the treatment comparisons available
with the control arm for only the arms still active at this stage.  Arms that
have been dropped earlier do not contribute events.  If arms are dropped, the
number of I events may decrease over time.  The total number of patients
reported at each stage still includes those recruited to dropped experimental
arms, because such patients remain part of the trial (for example, they still
consume resources and must be followed up with in the same way as patients on
still-active arms).


{title:Examples}

{pstd}
Three-arm, three-stage design with identical I and D outcomes:{p_end}
{phang2}{bf:. {stata nstage, accrue(100 100 100) arms(3 3 2) alpha(0.4 0.2 0.025) hr0(1 1) hr1(0.75 0.75) omega(0.95 0.95 0.90) t(2 2) s(0.5 0.5) aratio(1) nstage(3) tunit(1)}}{p_end}

{pstd}
Six-arm, five-stage design with different I and D outcomes:{p_end}
{phang2}{bf:. {stata nstage, accrue(87 87 87 87 87) arms(6 6 5 4 3) alpha(0.5 0.25 0.1 0.05 0.025) hr0(1 1) hr1(0.75 0.75) omega(0.95 0.95 0.95 0.95 0.90) t(8 16) s(0.5 0.5) aratio(0.5) corr(0.5) nstage(5) tstop(27) tunit(3) simcorr(1000)}}{p_end}

{pstd}
Five-arm, four-stage design with different I and D outcomes, efficacy stopping boundaries specified, and the FWER to be controlled at 2.5%:{p_end}
{phang2}{bf:. {stata nstage, accrue(200 200 200 200) arms(5 4 3 2) alpha(0.5 0.25 0.1 0.025) hr0(1 1) hr1(0.75 0.75) omega(0.95 0.95 0.95 0.90) t(2 4) aratio(0.5) nstage(4) esb(hp) fwercontrol(0.025)}}{p_end}


{title:Stored results}

nstage stores the following in r():

Scalars:
           r(allomega) =  all-pair power
            r(fwomega) =  any-pair power
            r(pwomega) =  per-pair power
            r(se_fwer) =  SE(FWER)
         r(se_maxfwer) =  SE(Max FWER)
        r(mvnpmaxfwer) =  maximum FWER (analytically derived, no stopping for efficacy)
            r(maxfwer) =  maximum FWER (simulated, with stopping for efficacy if specified)
            r(se_fwer) =  SE(FWER)
               r(fwer) =  FWER
              r(alpha) =  PWER
       r(bindingomega) =  pairwise power under binding stopping boundaries (I!=D only)
        r(bindingpwer) =  PWER under binding stopping boundaries (I!=D only)
            r(omegaSj) =  stagewise power (stage j)
             r(eexpSj) =  expected events per experimental arm (stage j)
             r(etotSj) =  total expected events (stage j)
             r(nexpSj) =  expected patients per experimental arm (stage j)
             r(ntotSj) =  total expected patients (stage j)
                r(tSj) =  expected time of stage j analysis (in specified units)
                r(nSj) =  expected control arm patients (stage j)
            r(eSjstar) =  expected events in experimental arm (stage j)
                r(eSj) =  required events in control arm for analysis (stage j)
              r(eSjun) =  initial estimate of required events in control arm (stage j)
            r(deltaSj) =  critical HR for stopping for lack-of-benefit (stage j)
            r(deltaEj) =  critical HR for stopping for efficacy (stage j)
                 r(Ej) =  efficacy stopping boundary (stage j)
                 r(Dj) =  expected events on definitive outcome (stage j, I!=D only)


{title:References}

{phang}
Bratton, D. J., B. Choodari-Oskooei, P. Royston. 2015. 
{browse "http://www.stata-journal.com/article.html?article=st0176_1":A menu-driven facility for sample-size calculation in multiarm multistage randomized controlled trials with time-to-event outcomes: Update}.
{it:Stata Journal} 15: 350-368.

{phang}
Barthel, F. M.-S., P. Royston, and M. K. B. Parmar. 2009. 
{browse "http://www.stata-journal.com/article.html?article=st0175":A menu-driven facility for sample-size calculation in novel multiarm, multistage randomized controlled trials with a time-to-event outcome}.
{it:Stata Journal} 9: 505-523.

{phang}
Royston, P., F. M.-S. Barthel, M. K. B. Parmar, B. Choodari-Oskooei, and
V. Isham. 2011. Designs for clinical trials with time-to-event outcomes
based on stopping guidelines for lack of benefit. {it:Trials} 12: 81.


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

{pstd}Babak Choodari-Oskooei{break}
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

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=st0175_1":st0175_1},{break}
                    {it:Stata Journal}, volume 9, number 4: {browse "http://www.stata-journal.com/article.html?article=st0175":st0175}

{p 7 14 2}Help:  {helpb nstagemenu}, {helpb nstagedlg} (if installed){p_end}
