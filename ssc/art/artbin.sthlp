{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:artbin} {hline 2}}ART (Binary Outcomes) - Sample Size and Power{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmdab:artbin, }
{cmd:pr(}{it:#}1 ... {it:#}K{cmd:)}
[{cmd:,}
{it:options}
]

    
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt al:pha(#)}}significance level for testing treatment effect(s){p_end}
{synopt :{opt ar:atios(aratio_list)}}allocation ratio(s){p_end}
{synopt :{opt di:stant(#)}}calculations under distant alternative hypothesis{p_end}
{synopt :{opt do:ses(dose_list)}}doses for linear trend test{p_end}
{synopt :{opt n(#)}}total sample size{p_end}
{synopt :{opt ng:roups(#)}}number of treatment groups in trial{p_end}
{synopt :{opt ni(#)}}non-inferiority trial{p_end}
{synopt :{opt o:nesided(#)}}use one-sided significance level{p_end}
{synopt :{opt po:wer(#)}}power of trial{p_end}
{synopt :{opt tr:end}}specifies a linear trend test{p_end}
{synoptline}

{pstd}where

{pin}
{cmd:pr(}{it:#}1 ... {it:#}K{cmd:)} is required and {it:#}1, {it:#}2, ... , {it:#}K
specify the probabilities to be compared (see also {opt ngroups()}).
If {opt ngroups()} exceeds {it:#}K then the value of
each of the remaining unspecified {opt ngroups()} minus K proportions is taken
to be the mean of {it:#}1, {it:#}2, ... , {it:#}K.


{title:Description}

{pstd}
{cmd:artbin} estimates power or total sample size for tests comparing K
proportions. Power is calculated if {opt n()} is specified as a positive number,
otherwise total sample size is estimated.


{title:Options}

{phang}
{opt alpha(#)} specifies the significance level. By default two-sided
significance levels are assumed. The default {it:#} is 0.05.

{phang}
{opt aratios(aratio_list)} specifies the allocation ratio(s).
Suppose {it:aratio_list} has r items, {it:#}1,...,{it:#}r. The allocation
ratio for group k is {it:#}k, k = 1,...,r. If r is less than {opt groups()}
then the allocation ratio for group r+1, r+2, ... is taken as {it:#}r.
If {opt aratios()} is not specified, the default allocation ratios are all
1, i.e. equal group sizes are assumed.

{phang}
{opt condit} indicates a conditional test (fixed total number of events).

{phang}
{opt distant(#)} specifies calculations for the test of proportions under
distant or local alternative hypotheses. Default {it:#} is 0, meaning
local alternatives. Distant alternatives are specified by {opt distant(1)}.

{phang}
{opt doses(dose_list)} specifies doses for a dose-response (linear trend)
test. {cmd:doses(}{it:#}1 {it:#}2...{it:#}r{cmd:)} assigns doses for groups 1,...,r. 
If r is less than {opt ngroups()}, the dose is assumed equal to {it:#}r
for groups r+1, r+2, ... . The default is {cmd:dose(1 2 ... }{opt ngroups())},
which applies only when {opt trend} is specified and {opt dose()}
is not specified.

{phang}
{opt ngroups(#)} is the number of comparative groups. The default {it:#}
is the number of proportions specified by {opt pr()}.

{phang}
{opt n(#)} specifies that total sample size is to be
calculated if {it:#} = 0. Otherwise power is calculated for total
sample size = {it:#}. The default # is 0.

{phang}
{opt power(#)} specifies the study power. The default # is 0.8 if
{opt n()} > 0.

{phang}               
{opt trend} specifies a linear trend test. By default, dose levels for the test
of linear trend are taken to equal the group numbers (1, 2, ...).
To alter this, the doses may be specified by using the {opt doses()} option.
Default: {opt notrend}, meaning global comparison of treatment effects.


{title:Remarks}

{pstd}
{cmd:artbin} computes sample size/power for the (global/trend) unconditional
chisquare test or the conditional test based on the hypergeometric distribution
with Peto's one-step approximation to the odds ratio (OR). Sample size/power
is calculated in the unconditional case under either local or distant
alternatives. Under local alternatives (eg OR or 1/OR less than 2), {cmd:artbin} uses the
null covariance matrix under both null and alternative hypotheses. The
unconditional test with local alternatives is the usual Pearson chisquare test.
Local alternatives are assumed in the conditional case.


{title:Examples}

{pstd}1. Comparing two proportions p1 and p2 unconditionally:

{phang}{cmd:. artbin, pr(.25 .35)}

    or

{phang}{cmd:. artbin, pr(.25 .35) distant(0)}


{pstd}2. Comparing four groups conditionally with event probability .15 in the
    control group and max difference .1:

{phang}{cmd:. artbin, pr(.15 .25) ngroups(4) condit}


{pstd}3. Compute power for linear trend test in three groups:

{phang}{cmd:. artbin, pr(.15 .2 .25) ngroups(3) trend n(0)}


{pstd}4. Sample size for global chisquare test comparing three groups with unequal
     allocation:

{phang}{cmd:. artbin, pr(.15 .2 .25) ngroups(3) aratios(1 2 2)}


{title:Authors}

{pstd}Abdel Babiker, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:a.babiker@ucl.ac.uk":Ab Babiker}

{pstd}Friederike Maria-Sophie Barthel, formerly MRC Clinical Trials Unit{break}
{browse "mailto:sophie@fm-sbarthel.de":Sophie Barthel}

{pstd}Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:b.choodari-oskooei@ucl.ac.uk":Babak Oskooei}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Also see}

    Manual:  {hi:[R] sampsi}

{p 4 13 2}
Online:  help for {help artmenu}, {help artbin}, {help artbindlg}, {help artbindlg}
