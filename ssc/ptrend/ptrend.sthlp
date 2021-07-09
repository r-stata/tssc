{smcl}
{* *! version 1.1.3 26oct2014}{...}
{cmd:help ptrend}
{hline}


{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{hi:ptrend}, {hi:ptrendi} {hline 2}}Trend analysis for proportions{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:ptrend} {it:rvar} {it:nrvar} {it:xvar}

{phang2}
{cmd:ptrendi} {it:r1} {it:nr1} {it:x1} {cmd:\} {it:r2} {it:nr2} {it:x2}
{cmd:\} {it:r3} {it:nr3} {it:x3} [ {cmd:\} {it:r4} {it:nr4} {it:x4} ... ]


{title:Description}

{pstd}
{cmd:ptrend} calculates a chi-square statistic for the trend (regression) of {it:pvar}
on {it:xvar}, where {it:pvar} is the proportion {it:rvar}/({it:rvar} + {it:nrvar}). A variable called
{cmd:_prop}, containing the values of {it:pvar}, is left behind by {cmd:ptrend}.
{cmd:ptrend} also gives a chi-square test for departure from the trend line.

{pstd}
{cmd:ptrendi} does the same analysis on user-entered data; the proportions are now
{it:p1} = {it:r1}/({it:r1} + {it:nr1}), {it:p2} = {it:r2}/({it:r2} + {it:nr2}), ....

{pstd}
{cmd:ptrendi} is an "immediate" command; see [U] immediate.


{title:Options}

{phang}None.


{title:Examples}

{phang}. ptrend r nr x{p_end}
{phang}. ptrend yes no shoesize{p_end}
{phang}. ptrendi 24 1355 1 \ 35 603 2 \ 21 192 3 \ 30 224 4{p_end}


{title:Stored}

{pstd}
{cmd:ptrend} and {cmd:ptrendi} store in {cmd:r()}:

	scalar {cmd:r(slope)}       Regression slope
	scalar {cmd:r(se)}          Standard error of slope
	scalar {cmd:r(chi2trend)}   Chisquare for trend
	scalar {cmd:r(chi2overall)} Pearson chisquare for the contingency table
	scalar {cmd:r(chi2dep)}     Chisquare for departure from linear trend
	scalar {cmd:r(dfdep)}       Degrees of freedom for r(chi2dep)}
	scalar {cmd:r(Pdep)}        P-value for departure from linear trend


{title:Author}

{pstd}
Patrick Royston{break}
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.

{pstd}Email: {browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Also see}

{psee}
Online:  help for {help tabulate}
{p_end}
