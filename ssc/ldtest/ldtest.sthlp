{smcl}
{* *! 1.0 17Oct2012}{...}
{cmd:help ldtest}
{hline}

{title:Title}

{p2colset 5 15 18 2}{...}
{p2col :{cmd: ldtest} {hline 2}}Consistent Nonparametric Tests of Lorenz Dominance with individual level data: Independent Random Sampling  {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ldtest}
{it:varnameX} {it: weightX}
{it:varnameY} {it: weightY}
{ifin}
[{cmd:,}
{cmdab:breps}{cmd:(}{it:bootreps}{cmd:) cvm lce }
]


{title:Description}

{pstd}
{cmd:ldtest} command applies the tests of Lorenz Dominance presented
in Barrett, Donald and Bhattacharya (2013).

{pstd} The tests are for the null hypothesis that distribution X Lorenz Dominates distribution Y. {p_end}
{pstd} More formally, the test is for  {p_end}
{phang2}H0: LC_x(p) >= LC_y(p) for all p, and {p_end}
{phang2}H1: LC_x(p) <  LC_y(p) for some p. {p_end}
{pstd}where p, the abscissa, is the set of empirical population quantiles {p_end}

{pstd} In terms of the command syntax, {it:varnameX} is the name of the X-variable, {it: weightX} is the name of the weight
variable for {it:varnameX}, {it:varnameY} is the name of the Y-variable and {it: weightY} is the corresponding weight for
{it:varnameY}. The null hypothesis is that the X-variable weakly Lorenz Dominates the Y-variable. {p_end}

{pstd} Two test statistics for the null of Lorenz dominance are constructed, and the corresponding {cmd: p-values} computed. {p_end}
{pstd}(i) Kolmogorov-Smirnov type test statistic based on the largest positive difference LC_(y)-LC_(x). This is
the default test statistic. {p_end}
{pstd}(ii) Cramer von Mises test statistic based on the integral of the postive difference of LC_(y)-LC_(x).{p_end}
{pstd} In addition,{p_end}
{pstd}(iii)the test statistic for the null of Lorenz curve equality, LC_x(p)=LC_y(p) for all p, based on the standard two-sample KS test,
is available as an option.{p_end}
{pstd}The empirical bootstrap is used to simulate the distribution of each test statistic and thereby calculate the
corresponding {cmd: p-values}. Intuitively, the test statistics are a (normalised) measure of the distance by
which is the null is violated. The {cmd:ldtest} command reports the test statistic, p-value and the 'distance'
measure underlying the test statistic.  {p_end}


{title:Options}

{phang}
{cmd:breps(}{it:bootreps}{cmd:)} specifies the number of bootstrap repetitions to be used in simulating the p-value for the tests.
The default is {it:bootreps=10}. {p_end}

{pstd}{cmd:cvm} specifies that the Cramer-von Mises test statistic be used. {p_end}

{pstd}{cmd:lce} specifies that the KS test of Lorenz Curve equality be used.  {p_end}


{title:Examples}

{pstd}Setup unweighted data {p_end}
{phang2}{cmd:. gen wgh10=1 if income10~=.} {p_end}
{phang2}{cmd:. gen wgh11=1 if income11~=.} {p_end}
{phang2}{cmd:. ldtest income10 wgh10 income11 wgh11, cvm}{p_end}
{phang2}{cmd:. ldtest income10 wgh10 income11 wgh11, lce}{p_end}
{phang2}{cmd:. ldtest income10 wgh10 income11 wgh11, breps(500) cvm }{p_end}

{pstd} Using weighted data{p_end}
{phang2}{cmd:. ldtest inc09 wgh09 inc03 wgh03}  {p_end}
{phang2} {cmd:. ldtest inc09 wgh09 inc03 wgh03, breps(1000)} {p_end}
{phang2} {cmd:. ldtest inc03 wgh03 inc09 wgh09, breps(1000)} {p_end}
{phang2} {cmd:. ldtest cons03 wgh03 cons09 wgh09, breps(2000)} {p_end}
{phang2} {cmd:. ldtest cons03 wgh03 cons09 wgh09, breps(2000) lce} {p_end}
{phang2} {cmd:. ldtest cons03 wgh03 cons09 wgh09, breps(2000) cvm} {p_end}

{title:Saved results}

{pstd}
{cmd:ldtest} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(KS)}}     Kolmogorov-Smirnov (KS) type test statistic  {p_end}
{synopt:{cmd:r(CvM)}}    Cramer - von Mises (CvM) or Integrated postive difference test statistic {p_end}
{synopt:{cmd:r(LCe)}}    KS Lorenz Curve Equality test statistic {p_end}
{synopt:{cmd:r(pKS)}}    p-value for the KS test statistic   {p_end}
{synopt:{cmd:r(pCvM)}}   p-value for the CvM test statistic   {p_end}
{synopt:{cmd:r(pLCe)}}   p-value for the LC equality test statistic   {p_end}
{synopt:{cmd:r(dKS)}}    Largest positive difference for the KS test statistic {p_end}
{synopt:{cmd:r(dCvM)}}   Integrated postive difference for the CvM test  {p_end}
{synopt:{cmd:r(LCe)}}    Largest absolute difference for the KS LCe test {p_end}


{title:Notes}

{pstd}{cmd:ldtest} is designed to be used with two independent samples of individual-level,
unit-record data.  The data are assumed to be weighted, with record weights corresponding
to the inverse probability of being in the sample. The test procedures, which are based on
the non-parametric estimation of the empirical Lorenz curves, are independent of the scale
of each weight variable (i.e. HOD 0 in the {it:weight} variables). If the data are a
simple random sample - equivalently, unweighted - this is easily handled by creating a weighting
variable which is the same constant value  (eg {it:weightx=1}) for all observations.

{pstd} If the samples are not independent but are matched-pairs, such as with panel data, then use
the {cmd: ldtestmp} command. The test procedures have been adapted to deal with panel dependence,
as explained in the cited reference. The empirical bootstrap procedure is modified for that
command to resample paired X-Y observations for a given observational unit, thereby replicating the dependence
structure.

{pstd} {cmd:ldtest} is a based on two independent samples. Typically the data set will
be individual records from two independent surveys appended together. The structure of the data
is such that for the set of 2009 records the values of the 2003 income and weight variables
are missing, and vice versa. For example, I want to test whether the 2009 distribution of individual
income Lorenz dominates the 2003 distribution of income. I have a sample of individual records drawn
from surveys in 2003 and 2009 which have been appended (stacked vertically) together. In the data
held in memory, the 2003 observations will have missing values for the 2009 variables, and the 2009
observations will have missing values for the 2003 variables.


{pstd} {cmd:ldtest} reports the run time in seconds. The run time is approximately linear in
{it:bootreps}. It is recommended that {cmd:ldtest} be used with a relatively low value for
{it:bootreps} (such as the default {it:bootreps=10}) to provide a guide the run time at higher
values. Then re-run {cmd:ldtest}  with {cmdab:breps}{cmd:(}{it:bootreps}{cmd:)} set to the
preferred value and you will have a good idea when the simulation and calculation will be completed.


{title:Authors}

{pstd} Garry Barrett, University of Sydney {p_end}
{pstd}garry.barrett@sydney.edu.au  {p_end}

{pstd} Stephen Donald, University of Texas at Austin {p_end}
{pstd}stephen.g.donald@gmail.com  {p_end}


{title:References}

{pstd} Barrett, G.F, S.G. Donald and D. Bhattacharya (2012) "Consistent Nonparametric Tests
for Lorenz Dominance" {it: Journal of Business and Economic Statistics}, forthcoming.
{p_end}



{title:Also see}

{psee}
Manual:  {manlink R inequality}

{psee}
Online:  {helpb ldtestmp} for testing with matched-pairs, or panel, data (if installed)
{p_end}
