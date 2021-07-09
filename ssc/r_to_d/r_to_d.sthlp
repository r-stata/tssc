{smcl}
{* *! version 1.0.0 03Sep2020}{...}

{title:Title}

{p2colset 5 15 16 2}{...}
{p2col:{hi:r_to_d} {hline 2}} Conversion of Pearson's r to Cohen's d  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}

{p 8 14 2}
{cmd:r_to_d}
{it: #r}
{cmd:,}
{opt sx(#)}
{opt d:elta(#)}
{opt n(#)}
[
{opt ns(#)}
{opt kno:wn}
{opt lev:el(#)}
]


{pstd}
The {it:r} coefficient must be a value between -1.0 and 1.0  



{synoptset 16 tabbed}{...}
{synopthdr:options}
{synoptline}
{p2coldent:* {opt sx(#)}}sample standard deviation of X{p_end}
{p2coldent:* {opt d:elta(#)}}contrast in X for which to compute Cohen's d, specified in raw units of X (not standard deviations){p_end}
{p2coldent:* {opt n(#)}}sample size used to estimate r{p_end}
{synopt:{opt ns(#)}}sample size used to estimate sx, if different from N{p_end}
{synopt:{opt kno:wn}}sx is known rather than estimated; the default assumes sx is estimated (which will almost always be the case){p_end}
{synopt:{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p 4 6 2}* {opt sx, delta} and {opt n} are required.{p_end}



{title:Description}

{pstd}
{opt r_to_d} converts Pearson's r (computed with a continuous X and Y) to Cohen's d for use in meta-analysis using the formula by Mathur and VanderWeele (2019). 
The resulting Cohen's d represents the estimated increase in standardized Y that is associated with a delta-unit increase in X. 

{pstd}
{cmd: r_to_d} is an immediate command; see {helpb immed}.



{title:Options}

{p 4 8 2}
{cmd:sx(}{it:#}{cmd:)} specifies the standard deviation of X; {cmd: sx() is required}.

{p 4 8 2}
{cmd:delta(}{it:#}{cmd:)} contrast in X for which to compute Cohen's d, specified in raw units of X (not standard deviations); {cmd: delta() is required}.

{p 4 8 2}
{cmd:n(}{it:#}{cmd:)} sample size used to estimate {it:r}; {cmd: n() is required}.

{p 4 8 2}
{cmd:ns(}{it:#}{cmd:)} sample size used to estimate sx, if different from N.

{p 4 8 2}
{cmd:known} specifies that sx is known rather than estimated; the default assumes sx is estimated (which will almost always be the case).

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for confidence intervals. The default is {cmd:level(95)}. 



{title:Examples}

{pmore}d for a 1-unit vs. a 2-unit increase in X{p_end}
{pmore2}{bf:{stata "r_to_d 0.5, sx(2) delta(1) n(100)": . r_to_d 0.5, sx(2) delta(1) n(100)}} {p_end}
{pmore2}{bf:{stata "r_to_d 0.5, sx(2) delta(2) n(100)": . r_to_d 0.5, sx(2) delta(2) n(100)}} {p_end}

{pmore} d when sx is estimated in the same vs. a smaller sample (point estimate will be the same, but inference will be a little less precise in second case){p_end}
{pmore2}{bf:{stata "r_to_d -0.3, sx(2) delta(2) n(300) ns(300)": . r_to_d -0.3, sx(2) delta(2) n(300) ns(300)}} {p_end}
{pmore2}{bf:{stata "r_to_d -0.3, sx(2) delta(2) n(300) ns(30)": . r_to_d -0.3, sx(2) delta(2) n(300) ns(30)}} {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:esizereg} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(r)}}{it:r} coefficient{p_end}
{synopt:{cmd:r(sx)}}standard deviation of X{p_end}
{synopt:{cmd:r(n)}}sample size used to estimate {it:r}{p_end}
{synopt:{cmd:r(d)}}Cohen's d{p_end}
{synopt:{cmd:r(se)}}standard error of the Cohen's d estimate{p_end}
{synopt:{cmd:r(lb_d)}}lower confidence bound for Cohen's d{p_end}
{synopt:{cmd:r(ub_d)}}upper confidence bound for Cohen's d{p_end}
{p2colreset}{...}

{pstd}
{cmd:esizereg} also stores the following local macros, making them accessible for later use:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:d}}Cohen's d{p_end}
{synopt:{cmd:se}}standard error of the Cohen's d estimate{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Cohen, J. (1988).  {it: Statistical Power Analysis for the Behavioral Sciences}. 2nd ed.  Hillsdale, NJ: Erlbaum.{p_end}

{p 4 8 2}
Mathur, M. B. and T. J. VanderWeele. 2019. A simple, interpretable conversion from Pearson's correlation to Cohen's d for meta-analysis. 
{it:Epidemiology} 31(2): e16-e18.



{marker citation}{title:Citation of {cmd:r_to_d}}

{p 4 8 2}{cmd:r_to_d} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2020). r_to_d: Stata module for converting Pearson's r to Cohen's d. {p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb esize} {p_end}

