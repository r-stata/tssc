{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:artmenu} {hline 2}}ART (Assessment of Resources for Trials) - Main dialog invoker{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:artmenu} {cmd:on} | {cmd:off}


{p 8 17 2}
{cmd:artmenu on} installs ART as a new item on the {cmd:User} menu.

{p 8 17 2}
{cmd:artmenu off} removes ART from the {cmd:User} menu.


{title:Description}

{pstd}
ART provides sample size and power calculations in potentially complex
randomised studies with a survival-time or a binary outcome. The ART system
(dialogs and associated ado-files) has the following flexible features:

{p 8 15 2}1. Any number of randomised groups from 2 upwards.

{p 8 15 2}2. Global or linear trend tests with arbitrary dose levels.

{p 8 15 2}3. Logrank test - unweighted or weighted (Tarone-Ware or Harrington-Fleming with
   any index).

{p 8 15 2}4. Binomial - conditonal and unconditional tests.
   
{p 8 15 2}5. Time-dependent rates of event, loss to follow-up and withdrawal from 
   allocated treatment (treatment change).
   
{p 8 15 2}6. Staggered patient entry

{p 8 15 2}7. Superiority or non-inferiority designs

{pstd}
The ART menu provides access to all these features. Alternatively, for
experienced users the underlying commands are available - see help on
{help artsurv} and {help artbin} for details. Execution from
the menu generates the underlying command in the Review and Stata Results
windows and may be used as an ad-hoc tutorial.

{pstd}
For suggestions on how
to document sample size calculations and how to deal with
designs in which several experimental arms are compared with
a single control arm, see Remarks.


{title:Remarks}

    {hi:Documenting sample size calculations}

{pstd}
It is clearly important to be able to document your sample size calculation 
for inspection at a later date. A simple way to do
this is as follows. Once you have a sample size calculation as you want it, open a log
file in Stata (through the main menu item File/Log/Begin...) and re-run the calculation,
either from the ART dialog or directly from the command line. When you have finished,
close the log file through the File/Log/Close menu item.

{pstd}
To print the log file, use Stata's {help print} command. For example, if you have
created a log file called {cmd:mylog.smcl}, you type {cmd:print mylog.smcl} to print it.
Stata automatically interprets the special {help SMCL} codes embedded in the file to
give readable results.

{pstd}
Alternatively, if you want to create a plain text log-file, select
filetype {cmd:Log (*.log)} in the File/Log/Begin Logging Stata Output dialog.
This has the advantage of being readable in a plain text editor.

{pstd}
To reproduce the sample size calculation in Stata, you can edit the log file in
a text editor and extract the sample command(s), which will begin with
either {cmd:artsurv} or {cmd:artbin}. With a plain text log-file, make sure you
remove the {cmd:> } line-continuation symbol and preceding carriage return.
Save the commands to a suitable {it:filename}{cmd:.do} and re-execute in
Stata by typing {cmd:do} {it:filename}. With a SMCL log file you will still
see the sample-size commands and you can edit the file to remove the junk
in the same way as for a plain text file, except that SMCL files do not
have line-continuation symbols.

    {hi:Multi-arm trials: Comparisons with a control arm}

{pstd}
When using ART to calculate sample size for trials with
more than 2 groups, the default assumption is a global comparison of 
all treatment groups simultaneously. (This is identical in concept to
the F-test for comparing groups in one-way analysis of variance.)
Often, one would prefer to compare each group with a single control
arm (usually designated group 1). A simple way to preserve
approximately the right overall
type 1 error probability, alpha, in such cases is by applying a Bonferroni
correction for multiple testing. With a 3-arm trial, for example, there
would be 2 comparisons with control, so each comparison should be
made using a significance level of alpha_star = alpha/2. The sample size would
be calculated in ART using a two-arm design with a type I error of 
alpha_star. Suppose this gave a sample size of n_star.
Assuming a 1:1:1 randomization (an allocation ratio of 1), the
desired total sample size, n, is obtained by multiplying n_star/2 by
3. In a K-arm trial, n = (n_star/2)*K.

{pstd}
The general solution for n in a K-arm trial with allocation ratio
r, that is where r times as many patients are to be randomized to
each experimental arm as the control arm, is as follows:

{p 8 8 2}
n = [n_star/(1+r)]*[1+(K-1)*r]

{pstd}
For example with r = 1.5 and K = 3 we would require

{p 8 8 2}
n = [n_star/(1+r)]*[1+(K-1)*r] = (n_star/2.5)*(1+2*1.5) = n_star*8/5

{pstd}
In reality such calculations are slightly conservative, i.e. give
slightly too many patients, or equivalently, slightly too much power
with the given number of patients. The reason is that since each
experimental arm is compared with the same control arm, the
estimated treatment effects are correlated. The correlation violates
the assumption of independence underlying the Bonferroni
correction. With equal allocation
the correlation is 0.5, but it varies if the allocation ratio
differs from 1. It is possible to calculate the correct overall
type 1 error in this situation - this requires tail areas of the
multivariate Normal distribution on K-1 variables. 
For example, with 3 arms, allocation ratio 1 and alpha = 5%,
the correct value of alpha_star is approximately 3%.


{title:Authors}

{pstd}Abdel Babiker, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:a.babiker@ucl.ac.uk":Ab Babiker}

{pstd}Friederike Maria-Sophie Barthel, formerly MRC Clinical Trials Unit{break}
{browse "mailto:sophie@fm-sbarthel.de":Sophie Barthel}

{pstd}Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:b.choodari-oskooei@ucl.ac.uk":Babak Oskooei}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:References}

{pstd}
The article listed first describes an earlier version of the ART system
for Stata 7 which uses the same underlying technology. The ART help
files detail the most recent enhancements and changes.

{phang}
Royston, P., and A. Babiker. 2002. A menu-driven facility for complex
sample size calculation in randomised controlled trials with a survival
or a binary outcome. Stata Journal 2: 151-163.

{phang}
Barthel, F.  M.-S., Royston, P., and A. Babiker. 2005. A menu-driven
facility for complex sample size calculation in randomized controlled
trials with a survival or binary outcome: update.
{it:Stata Journal} 5: 123-129.

{phang}
Barthel, F.  M.-S., Babiker, A., Royston, P., and M. K. B. Parmar. 2006.
Evaluation of sample size and power for multi-arm survival trials
allowing for non-uniform accrual, non-proportional hazards, loss to
follow-up and cross-over. {it:Statistics in Medicine} 25: 2521-2542.


{title:Also see}

    Manual:  {hi:[R] sampsi},  {hi:[R] stpower}

{p 4 13 2}
Online:  help for {help artsurv}, {help artbin}, {help artsurvdlg}, {help artbindlg}
