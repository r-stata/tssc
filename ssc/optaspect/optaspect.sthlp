{smcl}
{* *! version 1.0.0  11June2016}{...}
{vieweralsosee "[G2] twoway line" "help line"}{...}
{vieweralsosee "[G2] lowess" "help lowess"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "optaspect##syntax"}{...}
{viewerjumpto "Description" "optaspect##description"}{...}
{viewerjumpto "Options" "optaspect##options"}{...}
{viewerjumpto "Examples" "optaspect##examples"}{...}
{viewerjumpto "Saved results" "optaspect##results"}{...}
{viewerjumpto "References" "optaspect##references"}{...}
{viewerjumpto "Authors" "optaspect##authors"}{...}

{cmd:help optaspect}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:optaspect} {hline 2} Heuristic criteria for optimal aspect ratios in a two-variable line plot{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:optaspect} {it:yvar} {it:xvar}  {ifin}  {weight}
[, {opt sort} {opt cull:zero} {cmd:stackby(}{varname}{cmd:)} {opt y0 gor lor wlc} {opt iter:ate(#)} {opt tol:erance(#)}]


{synoptline}

{marker description}{...}
{title:Description}

{pstd}
The command {cmd:optaspect} calculates the optimal aspect ratio for a 
two-variable line graph using a number of heuristic criteria that are 
based on the principle of maximizing the contrast between the many line segments.
Line plots encode a series of slopes from adjoining 
coordinates with the purpose of revealing suggestive patterns in the sequential 
rates of change. The judged prevalence of patterns in the bivariate series 
and the degree of steepness in the rates of change is largely determined by 
the choice of aspect ratio that is imposed on the line plot. Choosing an 
appropriate aspect ratio is key in designing informative line plots.

{marker options}{...}
{title:Options}

{marker Method_options}{...}
{dlgtab:Method options}

{synopt :{opt sort}}orders the dataset on {it:xvar} in ascending order. 
{opt sort} is required for unordered data{p_end}

{synopt :{opt rank}}replaces {it:xvar} with a variable {it:t} that takes 
the values {it:t=1,2,...,n}{p_end}

{synopt :{opt cull:zero}}ignores zero slopes in the calculation of 
the optimal aspect ratios{p_end}

{synopt :{opt stackby(varname)}}specifies the calculation of average 
optimal aspect ratios over all categories of {it:varname}, on the basis 
that the line graph will be split-and-stacked by these categories{p_end}

{synopt :{opt y0}}specifies that the y-axis of the line graph will 
contain the baseline value of zero and that the aspect ratio should 
be adjusted accordingly.{p_end}

{synopt :{opt gor}}calculates the computationally expensive 
Global Orientation Resolution criterion (GOR){p_end}

{synopt :{opt lor}}calculates the Local Orientation Resolution criterion (LOR){p_end}

{synopt :{opt lor}}calculates the Weighted Local Curvature criterion (LOR){p_end}

{marker Iteration_options}{...}
{dlgtab:Iteration options}

{synopt :{opt iter:ate(#)}}specify the number of iterations for those criteria 
that require iterative optimization (AAO, WAAO, LOR, GOR, ARC). The default 
is {opt iterate(100)}. This option is rarely used{p_end}

{synopt :{opt tol:erance(#)}}specify the convergence tolerance for those criteria 
that require iterative optimization (AAO, WAAO, LOR, GOR, ARC). The default 
is {opt tolerance(1e-6)}. This option is rarely used{p_end}

{synoptline}

{marker examples}{...}
{title:Examples}

{pstd}Sunspot activity{p_end}
{phang2}{stata "webuse sunspot":. webuse sunspot.dta}{p_end}
{phang2}{stata "optaspect spot time":. optaspect spot time}{p_end}
{phang2}{stata "optaspect spot time if inrange(time,1749,1924), lor gor wlc cullzero":. optaspect spot time if inrange(time,1749,1924), lor gor cullzero}{p_end}

{pstd}Airline Passengers{p_end}
{phang2}{stata "webuse air2":. webuse air2}{p_end}
{phang2}{stata "optaspect air time, wlc":. optaspect air time}{p_end}
{phang2}{stata "optaspect air time, wlc cullzero rank":. optaspect air time, cullzero rank}{p_end}

{pstd}Gross national product{p_end}
{phang2}{stata "sysuse gnp96":. sysuse gnp96}{p_end}
{phang2}{stata "optaspect gnp96 date, wlc":. optaspect gnp96 date}{p_end}

{pstd}Price of cars versus mileage{p_end}
{phang2}{stata "sysuse auto":. sysuse auto}{p_end}
{phang2}{stata "generate ln_p = ln(price)":. generate ln_p = ln(price)}{p_end}
{phang2}{stata "generate ln_m = ln(mpg)":. generate ln_m = ln(mpg)}{p_end}
{phang2}{stata "lowess ln_p ln_m, generate(ln_p_sm)":. lowess ln_p ln_m, generate(ln_p_sm)}{p_end}
{phang2}{stata "optaspect ln_p_sm ln_m, sort":. optaspect ln_p_sm ln_m, sort}{p_end}

{pstd}S&P 500 daily return{p_end}
{phang2}{stata "sysuse sp500":. sysuse sp500}{p_end}
{phang2}{stata "generate ret = change[_n]/close[_n-1]":. generate ret = change[_n]/close[_n-1]}{p_end}
{phang2}{stata "quietly summarize ret":. quietly summarize ret}{p_end}
{phang2}{stata "generate abn_ret = ret - r(mean)":. generate abn_ret = ret - r(mean)}{p_end}
{phang2}{stata "generate quarter = quarter(date)":. generate quarter = quarter(date)}{p_end}
{phang2}{stata "optaspect abn_ret t, rank stackby(quarter)":. optaspect abn_ret t, rank stackby(quarter)}{p_end}

{pstd}Life expectancy{p_end}
{phang2}{stata "webuse uslifeexp":. webuse uslifeexp}{p_end}
{phang2}{stata "optaspect le year, sort cull wlc lor gor":. optaspect le year, sort cull wlc lor gor}{p_end}
{phang2}{stata "generate diff = le_wm - le_bm":. generate diff = le_wm - le_bm}{p_end}
{phang2}{stata "lowess diff year, generate(diff_sm)":. lowess diff year, generate(diff_sm)}{p_end}
{phang2}{stata "optaspect diff_sm year, y0":. optaspect diff_sm year, y0}{p_end}

{marker results}{...}
{title:Saved results}

{col 4}Scalars
{col 8}{cmd:r(mas)}{col 27}MAS aspect ratio
{col 8}{cmd:r(aas)}{col 27}AAS aspect ratio
{col 8}{cmd:r(waao)}{col 27}WAAO aspect ratio
{col 8}{cmd:r(aao)}{col 27}AAO aspect ratio
{col 8}{cmd:r(gor)}{col 27}GOR aspect ratio
{col 8}{cmd:r(lor)}{col 27}LOR aspect ratio
{col 8}{cmd:r(arc)}{col 27}ARC aspect ratio
{col 8}{cmd:r(rv)}{col 27}RV aspect ratio
{col 8}{cmd:r(wlc)}{col 27}WLC aspect ratio
{col 8}{cmd:r(n)}{col 27}Number of slopes in the data
{col 8}{cmd:r(cull)}{col 27}Number of zero slopes culled


{marker references}{...}
{title:Key references}

{p 4 6 2}Christodoulou, D. (20XX),
optaspect: Heuristic criteria for selecting an optimal aspect ratio in a two-variable line plot,
{it:The Stata Journal}, Volume vv, Number ii, pp. xx-xx.

{p 4 6 2}Cleveland, W. S., M. E. McGill, and R. McGill (1988),
The shape parameter of a two-variable graph,
{it:Journal of the American Statistical Association}, Volume 83, Number 402, pp. 289-300.

{p 4 6 2}Cleveland, W. S. (1993),
A Model for Studying Display Methods of Statistical Graphics,
{it:Journal of Computational and Graphical Statistics}, Volume 2, Number 4, pp. 323-343.

{p 4 6 2}Guha S. and W. S. Cleveland (2011),
Perceptual, mathematical, and statistical properties of judging functional dependence on visual displays,
{it:Technical report}, Purdue University Department of Statistics.

{p 4 6 2}Han, F., Y. Wang, J. Zhang, O. Deussen, and B. Chen (2016),
Mathematical Foundations of Arc Length-Based Aspect Ratio Selection,
{it:IEEE Pacific Visualization Symposium (PacificVis)}, pp. 9-15.

{p 4 6 2}Heer, J., and M. Agrawala (2006),
Multi-scale banking to 45,
{it:IEEE Transcations on Visualisation and Computer Graphics}, Volume 12, Number 5, pp. 701-708.

{p 4 6 2}Talbot, J., J. Gerth, and P. Hanrahan (2011),
Arc length-based aspect ratio selection,
{it:InfoVis Conference Proceedings}.

{p 4 6 2}Talbot, J., J. Gerth, and P. Hanrahan (2012),
A Model for Studying Display Methods of Statistical Graphics,
{it:InfoVis Conference Proceedings}.

{marker authors}{...}
{title:Author}

{phang}{browse "http://sydney.edu.au/business/research/meafa/":Demetris Christodoulou}{p_end}
{phang}MEAFA Research Group{p_end}
{phang}The University of Sydney Business School{p_end}
{phang}Sydney, NSW 2006{p_end}
{phang}Australia{p_end}
{phang}{browse "mailto:demetris.christodoulou@sydney.edu.au":demetris.christodoulou@sydney.edu.au}{p_end}

