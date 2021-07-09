{smcl}
{* *! version 1.0.1 29mar2011 Philip M Jones pjones8@uwo.ca}{...}
{cmd:help combine}
{hline}

{title:Title}

{p 4 11 2}
{bf:combine} {hline 2} A simple program to combine n, mean, and SD from two groups
according to the Cochrane-recommended formula (for meta-analyses).{p_end}

{title:Syntax}

{p 8 17 2}
{cmd:combine} n1 mean1 sd1 n2 mean2 sd2


{title:Description}

{pstd}
{opt combine} is meant to be used by analysts performing meta-analysis whereupon it is 
sometimes necessary to combine size, mean, and SD from two groups (for example, two intervention
groups). The Cochrane Collaboration provides a formula for this calculation in its handbook,
but it is cumbersome to perform using a calculator, or by hand.

{pstd}
{opt combine} allows this calculation to be done automatically.


{title:Details on Syntax}
{pstd}
Assume you have two groups:

Group A: n = 50, mean = 26.5, SD = 4.5
Group B: n = 50, mean = 32.9, SD = 5.8

You would type:

combine 50 26.5 4.5 50 32.9 5.8


To then combine a third group (n = 50, mean = 36.4, SD = 3.8), you would type:

combine r(n) r(mean) r(SD) 50 36.4 3.8


{title:Notes}
{pstd}
{it}For the purposes of the combined SD calculation, absolute
values of the means are used. This is to allow the correct calculation
of the combined mean between groups (for instance if one or both means
were negative values) whilst calculating the correct combined SD. (This
is specifically relevant in the equation for the combined SD that has
the specific portion "... -2M1M2 ...".) If absolute values of the means
were not used here, this term would be calculated incorrectly.

{title:References:}

{pstd}
1) Higgins JPT, Green S (editors). Cochrane Handbook for Systematic Reviews of Interventions
Version 5.1.0 [updated March 2011]. The Cochrane Collaboration, 2008.
Available from www.cochrane-handbook.org. The specific formula used is in Table 7.7.a.


{title:Saved results}

{pstd}
{cmd:combine} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 25 25 2: Scalars:}{p_end}

{synopt:{cmd:r(n)}}combined group size{p_end}
{synopt:{cmd:r(mean)}}combined mean{p_end}
{synopt:{cmd:r(SD)}}combined SD{p_end}
{p2colreset}{...}


{title:Author Information:}

{phang}Philip M Jones, MD FRCPC{p_end}
{phang}Department of Anesthesiology & Perioperative Medicine{p_end}
{phang}Faculty of Medicine & Dentistry{p_end}
{phang}University of Western Ontario{p_end}
{phang}London, Ontario, Canada{p_end}
{phang}pjones8@uwo.ca{p_end}

{title:Change Log:}


{phang2}{bf:1.0.2:} 19dec2017 - Updated to correct erroneous SDs when negative numbers were input for means. (Thanks Sam Kumar){p_end}

{phang2}{bf:1.0.1:} 29mar2011 - Updated to notify users about absolute value usage (see Notes) and
added syntax for combining a third group using the returned scalars.{p_end}

{phang2}{bf:1.0.0:} 28feb2011 - Initial version published.{p_end}
