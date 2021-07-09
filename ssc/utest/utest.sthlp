{smcl}
{* version 1.2 04feb2019}{...}
{vieweralsosee "fieller" "fieller"}{...}
{hline}
help for {cmd:utest}{right:Version 1.2}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi: utest} {hline 2} Test for a U-shaped relationship}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:utest} x f(x)
[{cmd:,} {it:options}]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt mi:n(#)}}Use {it:#} as lower {p_end}
{synopt:{opt ma:x(#)}}Use {it:#} as upper {p_end}
{synopt:{opt q:uadratic}}Force quadratic specification{p_end}
{synopt:{opt i:nverse}}Force inverse specification{p_end}
{synopt:{opt f:ieller}}Include Fieller-interval of extreme point{p_end}
{synopt:{opt l:evel(#)}}Set confidence level for Fieller interval; default is
{cmd:level(95)}{p_end}
{synopt:{opt pre:fix(str)}}Variable names are prefixed by {it:str} in the saved results{p_end}
{synoptline}
{p2colreset}{...}



{title:Description}

{pstd}
{cmd:utest} provides the exact test of the presence of a U shaped (or
inverse U shaped) relationship on an interval. 

{pstd}
{cmd:utest} is used after estimation commands to test for the presence of
a U-shaped or
inverse U-shaped relationship between an explanatory variable and the outcome
variable on
a specific interval.

{pstd} The estimation must contain the level of the explanatory variable
(i.e. x)
and a non-linear term ,
either quadratic or inverse (i.e. f(x)). {cmd:utest} will determine which
of the two
is used
and report test results from the test of the hypothesis that the
relationship is
decreasing at the start of the interval and increasing at the end or vice
versa.

{pstd} The interval is by default taken as the data range, but can be
controlled by
setting the options {cmd:minimum(#)} and {cmd:maximum(#)}.

{pstd} A Fieller interval for the extreme point is also provided by the
option
{cmd:fieller}.
This interval is correct even for finite samples.

{pstd} Estimation commands that prefixes saved results by equation names can be 
handled with the prefix-option. This includes estimations on multi-equation
models (e.g. {cmd:mlogit}) and commands with additional saved results 
(e.g. {cmd:nbreg}).

{title:Remarks}

{pstd} For full details about the test, see J. T. Lind and H. Mehlum:
With or without U? The appropriate test for a U shaped relationship.
{it:Oxford Bulletin of Economics and Statistics} 72(1): 109-18 (2010).


{title:Examples}

   {cmd:. utest x xsquared}

   {cmd:. utest x xinv, min(.3) fieller }
   
   {cmd:. nbreg y x xsquared}
   {cmd:. utest x xsquared, prefix(y)}


{title:Stored results}   

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(t)}}t-value of U-test{p_end}
{synopt:{cmd:r(t)}}p-value of U-test{p_end}
{synopt:{cmd:r(x_l)}}Lower boundary of interval{p_end}
{synopt:{cmd:r(x_u)}}Upper boundary of interval{p_end}
{synopt:{cmd:r(s_l)}}Slope at lower boundary of interval{p_end}
{synopt:{cmd:r(s_u)}}Slope at upper boundary of interval{p_end}
{synopt:{cmd:r(t_l)}}t-value at lower boundary of interval{p_end}
{synopt:{cmd:r(t_u)}}t-value at upper boundary of interval{p_end}
{synopt:{cmd:r(extr)}}Extreme point{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(shape)}}Shape of the relationship{p_end}
{p2colreset}{...}



   
{title:Author}

{pstd}
Contact {browse "mailto:j.t.lind@econ.uio.no":Jo Thori Lind} or
{browse "mailto:halvor.mehlum@econ.uio.no":Halvor Mehlum} if you observe
problems.
{p_end}
