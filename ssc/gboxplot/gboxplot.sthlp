{smcl}
{* *! version 1.1.0  7Aug2014}{...}
{cmd:help gboxplot}{right: ({browse "http://www.stata-journal.com/article.html?article=st0533":SJ18-3: st0533})}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{cmd:gboxplot} {hline 2}}Box plot for skewed or heavy-tailed distributions{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:gboxplot} {varname} {ifin}
[{cmd:,} {opth out:lier(varname)}
{opt bdp(#)}
{opt perc:out(#)}
{opt nog:raph}
{opt delta(#)}]


{title:Description}

{pstd}
{cmd:gboxplot} creates the box plot for skewed or heavy-tailed
distributions.


{title:Options}

{phang}
{opt outlier(varname)} creates {it:varname} to identify individuals lying
outside the interval defined by the pivotal values.

{phang}
{opt bdp(#)} sets the desired breakdown point (as a percentage)
for the estimation of the parameters of the Tukey distribution. The default is
{cmd:bdp(10)}. The argument of {cmd:bdp()} can be set in the open interval
(0, 25).

{phang}
{opt percout(#)} sets the desired proportion (as a percentage)
of points outside the interval delimited by the generalized pivotal values in
the case of clean data. The default is {cmd:percout(0.7)}. The argument of
{cmd:percout()} can be set in the open interval (0, 25).

{phang}
{opt nograph} suppresses the display of the generalized box plot.

{phang}
{opt delta(#)} sets the shifting constant implied in the definition of
the values r_i in the preliminary transformation of the data. The default is
{cmd:delta(0.1)}.


{title:Example}

{pstd}Setup{p_end}
{phang2}. {stata "webuse auto"}{p_end}

{pstd}Creating the generalized box plot{p_end}
{phang2}. {stata "gboxplot price"}{p_end}


{title:Stored results}

{pstd}
{cmd:gboxplot} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(g)}}estimated skewness parameter of the Tukey g-and-h distribution{p_end}
{synopt:{cmd:e(h)}}estimated elongation parameter of the Tukey g-and-h distribution{p_end}
{synopt:{cmd:e(upperW)}}value of the right adjacent value (extremity of the right whisker){p_end}
{synopt:{cmd:e(lowerW)}}value of the left adjacent value (extremity of the left whisker){p_end}


{title:Authors}

{pstd}
Christopher Bruffaerts, Vincenzo Verardi, and Catherine Vermandele


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 3: {browse "http://www.stata-journal.com/article.html?article=st0533":st0533}{p_end}

{p 4 14 2}
Manual:  {manlink R graph box}{p_end}
