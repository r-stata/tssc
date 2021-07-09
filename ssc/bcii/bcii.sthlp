{smcl}
{* 31-05-2009}{...}
{cmd:help bcii} and {cmd:help bcib} {right:Version 1.1 31-05-2009}

{hline}

{title:Title}

{p2colset 5 13 13 2}{...}
{p2col:{hi:bcii} {hline 2}}Calculates the number needed to treat (NNT) and confidence intervals for patients improving (comparison between intervention and control group in a randomised controlled trial){p_end}
{p2col:{hi:bcib} {hline 2}}Calculates NNT and confidence intervals for patients benefiting (either improvements gained or deteriorations prevented) in a randomised controlled trial{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:bcii}
{it:#a #b #c #d}
[{cmd:,} {it:options}]

{p 8 17 2}
{cmdab:bcib}
{it:#a #b #c #d #e #f #g #h}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l:evel(#)}}set confidence level; default is prevailing setting (see {help creturn}){p_end}
{p2colreset}{...}
{p 4 6 2}


{title:Descriptions}

{pstd}
{cmd:bcii} estimates absolute risk reduction and number needed to treat for  for the difference between the proportion of improving patients in the intervention group and the proportion of improving patients
in the control group. It uses a method that is considered to have superior coverage properties to the conventional Wald 
method for calculating confidence intervals (Newcombe's Method 10); this may be important when reciprocally transforming absolute risk reductions to obtain  numbers needed to treat (NNTs) as described by 
Bender, 2001. 
estimates NNTs for benefit; the difference between the proportion of improving patients minus the proportion of deteriorating patients in the intervention group and the proportion of improving patients minus 
the proportion of deteriorating patients in the control group. Newcombe's method 10 has been modified to incorporate these extra variance terms as described by Froud et al, 2009.

{title:Options}

{dlgtab:Main}

{phang}
{cmd:level} set confidence level; it must lie between 0.1 and 99.9%, inclusive; default is the Stata 
{help level} setting.

{title:Remarks}

{pstd}
{cmd:bcii} calculates confidence intervals for the NNT by reciprocal transformation of risk difference confidence intervals,  from differences between two independent proportions (patients improving in the treatment 
group and in the control group)using Newcombe's Method 10. The confidence intervals are considered to have better coverage
than the conventional Wald confidence interval and are less prone to aberrations following reciprocal transformation to NNT limits.

{pstd}
The sequence of {it:#a}, {it:#b}, {it:#c} and {it:#d} in {cmd:bcii} come from a contingency table of 'improvements' x group (see {help epitab}). The additional 
{it:#a}, {it:#b}, {it:#c} and {it:#d} in {cmd:bcib} come from a similar table of 'deteriorations' (see {help epitab}).



{title:Examples}

{phang}{cmd:. bcii 82 62 143 194}

{phang}{cmd:. bcii 82 62 143 194, level(90)}

{phang}{cmd:. bcib 82 62 143 194 5 12 220 243}


{title:References}

{pstd}
R. Froud, S. Eldridge, R.Lall, M.Underwood, Estimating NNT from continuous outcomes in randomised controlled trials: Methodological challenges and worked example using data 
from the UK Back Pain Exercise and Manipulation (BEAM) trial ISRCTN32683578. {it:BMC Health Services Research} {bf:2009 IN PRESS}.

{pstd}
R. Bender, Calculating confidence intervals for the Number Needed to Treat {it:Controlled clinical trials} {bf:22}{c -}102-110, 2001.


{pstd}
R. G. Newcombe, Interval estimation for the difference between independent proportions: 
comparison of eleven methods. {it:Statistics in Medicine} {bf:17}:873{c -}90, 1998.


{title:Acknowledgements}

{pstd}
Code for calculating Wilson intervals of the individual proportions (used in calculation of 
Newcombe's Method 10 confidence intervals) is adapted from {cmd:rdcii} by Joseph Coveney, who adapted code from {cmd:ciwi} by Nicholas J. Cox. Thanks to my colleagues, 
S. Eldridge, R.Lall, and  M.Underwood for their help and comments on the modifications to Newcombe's Method 10, and to Gordon Guyatt, Thomas Kottke, and Kamshwar Prasad, for their very useful comments
on the accompanying paper; and to Mandy Hildebrandt and Michal Vaillant for their comments on an earlier version of the paper. 


{title:Author}

{pstd}
Robert Froud r.j.froud@qmul.ac.uk


{title:Also see}

{psee}
Manual:  {bf:[ST] epitab}

{psee}
Online:  {helpb epitab}, {helpb ci}
