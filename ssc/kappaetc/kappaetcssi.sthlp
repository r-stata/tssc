{smcl}
{cmd:help kappaetcssi}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{cmd:kappaetcssi} {hline 2}}Approximate sample-size estimation 
for agreement coefficients{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 19 2}
{cmd:kappaetcssi}
{it:E} 
[{it:prop_o}]
[{cmd:,} {it:options}]

{pstd}
where {it:E} is the desired error margin, that is, half the width of the 
confidence interval, and {it:prop_o} is the target observed proportion 
of agreement.

{synoptset 15}{...}
{synopthdr}
{synoptline}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level({ccl level})}{p_end}
{synopt:{cmd:cformat(}{it:{help format:{bf:%}fmt}}{cmd:)}}control display format{p_end}
{synopt:{opt noreturn}}do not return results{p_end}
{synopt:{opt nsubjects(#)}}specify size of subject universe{p_end}
{synopt:{opt largesample}}use standard normal distribution for standard error 
and error margin{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:kappaetcssi} estimates an approximate required sample size for agreement
coefficients so that the error margin (half the width of the confidence
interval) remains below a specified value.  See {help immed} for a general
description of immediate commands.

{pstd}
The command implements a simple convenient procedure outlined in Gwet (2014,
158-160).  Instead of deriving exact formulas for various specific agreement
coefficients, this procedure focuses on the observed proportion of agreement,
denoted {it:prop_o}.  For any two raters, the large-sample normal
approximation of its variance is {it:V} = {it:prop_o}(1-{it:prop_o})/{it:n},
and the associated error margin is {it:E} = {it:z}*{help sqrt}({it:V}), where
{it:z} is the negative of the ((1-{opt level(#)}/100)/2) quantile of the
normal distribution.  The optimal number of subjects is then {it:n} =
({it:z}^2*{it:V})/{it:E}^2.

{pstd}
{cmd:kappaetcssi} takes as arguments the desired error margin and, optionally,
the expected observed proportion of agreement.  The latter defaults to 0.5 if
not specified.  The command estimates the sample size that results in an error
margin less than or equal to the specified value.  It also estimates the large
sample standard error and error margin associated with the observed proportion
of agreement for sample size {it:n}.  Additionally, the standard error and
error margin for small samples based on the t distribution with {it:n}-1
degrees of freedom is reported.


{title:Options}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level({ccl level})}.

{phang}
{cmd:cformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format
coefficients, standard errors, and error margins.  The maximum format width is
8.

{phang}
{opt noreturn} does not return results in {cmd:r()}.

{phang}
{opt nsubjects(#)} specifies the size of the subject universe to be used for
the finite sample correction.  The default is {cmd:nsubjects(.)}, leading to a
sampling fraction of 0 that is assumed to be negligible.  This option affects
only the estimated standard error and error margin for small samples and is
seldom used.

{phang}
{opt largesample} specifies that the calculation of the error margin be based
on the standard normal distribution rather than the t distribution.  This
option affects only the error margin for small samples and is seldom used.


{title:Remarks}

{pstd}
The sample size that {cmd:kappaetcssi} reports is comparable with the results
obtained from {helpb power oneproportion} when power is set to 0.5.  For
example,

{phang2}
{cmd:. kappaetcssi 0.1}

{pstd}
gives the same result as

{phang2}
{cmd:. power oneproportion 0.5 0.6 , power(0.5)}
{p_end}


{title:Examples}

{pstd}
Estimate approximate required sample size for a maximum error margin of
0.2.{p_end}
{phang2}{cmd:. kappaetcssi 0.2}{p_end}


{pstd}
Do the same as above but set expected observed proportion of agreement to
0.8.{p_end}
{phang2}{cmd:. kappaetcssi 0.2 0.8}{p_end}


{title:Stored results}

{pstd}
{cmd:kappaetcssi} stores the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(E)}}desired error margin{p_end}
{synopt:{cmd:r(prop_o)}}observed proportion of agreement{p_end}
{synopt:{cmd:r(N_pop)}}population size (only with {opt nsubjects()}){p_end}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(se)}}standard error (normal approximation){p_end}
{synopt:{cmd:r(errmarg)}}error margin (normal approximation){p_end}
{synopt:{cmd:r(se_t)}}standard error (small sample){p_end}
{synopt:{cmd:r(errmarg_t)}}error margin (small sample){p_end}


{title:Reference}

{phang}
Gwet, K. L. 2014. {it:Handbook of Inter-Rater Reliability: The Definitive Guide to Measuring the Extent of Agreement Among Raters}. 4th ed.
Gaithersburg, MD: Advanced Analytics.


{title:Author}

{pstd}
Daniel Klein{break}
International Centre for Higher Education Research Kassel{break}
Kassel, Germany{break}
klein@incher.uni-kassel.de


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0544":st0544}{p_end}

{p 7 14 2}
Help: {manhelp kappa R}, {manhelp power PSS}, {helpb kapssi}, {helpb sskapp} (if installed){p_end}
