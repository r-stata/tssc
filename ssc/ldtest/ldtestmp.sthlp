{smcl}
{* *! 1.0 17Oct2012}{...}
{cmd:help ldtestmp}
{hline}

{title:Title}

{p2colset 5 17 22 4}{...}
{p2col :{cmd: ldtestmp} {hline 2}}Consistent Nonparametric Tests of Lorenz Dominance with individual level data: Matched Pair (panel) Sampling{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ldtestmp}
{it:varnameX}
{it:varnameY} {it: weight}
{ifin}
[{cmd:,}
{cmdab:breps}{cmd:(}{it:bootreps}{cmd:) cvm lce }
]


{title:Description}

{pstd}
{cmd:ldtestmp} command applies the tests of Lorenz Dominance for Matched Pair Sampling schemes presented
in Barrett, Donald and Bhattacharya (2012).

{pstd} The tests are for the null hypothesis that distribution X Lorenz Dominates distribution Y. {p_end}
{pstd} More formally, the test is for  {p_end}
{phang2}H0: LC_x(p) >= LC_y(p) for all p, and {p_end}
{phang2}H1: LC_x(p) <  LC_y(p) for some p. {p_end}
{pstd}where p, the abscissa, is the set of empirical population quantiles {p_end}

{pstd} In terms of the command syntax, {it:varnameX} is the name of the X-variable,{it:varnameY} is the name of the Y-variable and
{it: weight} is the sampling weight for observation. This procedure assumes the sampling scheme is matched pairs - such as with panel
data - where the values of {it:varnameX} and {it:varnameY} are recorded for each observational unit.
The null hypothesis is that the X-variable weakly Lorenz Dominates the Y-variable. {p_end}

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
{phang2}{cmd:. gen wgh=1 if income10~=.&income11~=.} {p_end}
{phang2}{cmd:. ldtestmp income10 income11 wgh, cvm}{p_end}
{phang2}{cmd:. ldtestmp income10 income11 wgh, lce}{p_end}
{phang2}{cmd:. ldtestmp income10 income11 wgh, breps(500) cvm }{p_end}

{pstd} Using weighted data{p_end}
{phang2}{cmd:. ldtest inc09 wgh09 inc03 wgh03}  {p_end}
{phang2} {cmd:. ldtestmp inc09  inc03  wgh, breps(1000)} {p_end}
{phang2} {cmd:. ldtestmp inc03  inc09  wgh, breps(1000)} {p_end}
{phang2} {cmd:. ldtestmp cons03 cons09 wgh, breps(2000)} {p_end}
{phang2} {cmd:. ldtestmp cons03 cons09 wgh, breps(2000) lce} {p_end}
{phang2} {cmd:. ldtestmp cons03 cons09 wgh, breps(2000) cvm} {p_end}

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

{pstd}{cmd:ldtest} is designed to be used with a matched-pair sample of individual-level,
unit-record data. As explained in the cited reference, this procedure deals with panel dependence.
The empirical bootstrap procedure is modified to resample paired X-Y observations for a given
observational unit, thereby replicating the dependence structure.

{pstd} Typically the data are drawn from a panel or are clustered. For example, if I have a
panel survey of individuals tracked from 2003 to 2009 where I have income in each year, and a weight variable.
I want to test whether the 2009 distribution of individual income Lorenz dominates the 2003 distribution of income,
taking into account the dependence structure of the sample. Another example is an expenditure survey for 2010
where for each sampled household I have measures of disposable income and expenditure, and I want to test whether
the expenditure distribution Lorenz dominates the income distribution taking into account the dependence induced
by the paired income-expenditure observations.


{pstd}The data are assumed to be weighted, with record weights corresponding
to the inverse probability of an observational unit being in the sample. The test procedures, which
are based on the non-parametric estimation of the empirical Lorenz curves, are independent of the scale
of each weight variable (i.e. HOD 0 in the {it:weight} variables). If the data are unweighted -
this is easily handled by creating a weighting variable which is the same constant value
(eg {it:weightx=1}) for each observational unit.

{pstd} If the samples are not matched pairs but are independent (such as a pure cross-section) then use
the {cmd: ldtest} command.




{pstd} {cmd:ldtestmp} reports the run time in seconds. The run time is approximately linear in
{it:bootreps}. It is recommended that {cmd:ldtestmp} be used with a relatively low value for
{it:bootreps} (such as the default {it:bootreps=10}) to provide a guide the run time at higher
values. Then re-run {cmd:ldtestmp}  with {cmdab:breps}{cmd:(}{it:bootreps}{cmd:)} set to the
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
Online:  {helpb ldtest} for testing with independent random samples of data (if installed)
{p_end}
