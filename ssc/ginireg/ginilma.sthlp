{smcl}
{* *! version 1.0.02  26jan2015}{...}
{cmd:help ginilma}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: ginilm} {hline 2}}Progam to graph Gini LMA and NLMA curves{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Single plot:

{p 8 14 2}
{cmd:ginilma}
{it:varlist}
[{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,} {cmd:nlma} }
{bind:{it:graph_options} ]}

{phang}
Multiple (twoway) plots:

{p 8 16 2}{cmd:ginilma} {bind:({it:varlist} [{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ {cmd:,} {cmd:nlma} {it:graph_options} ] )}{p_end}
{p 16}{bind:({it:varlist} [{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ {cmd:,} {cmd:nlma} {it:graph_options} ] )}{p_end}
{p 16}...{p_end}
{p 16}{bind:({it:varlist} [{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ {cmd:,} {cmd:nlma} {it:graph_options} ] )}{p_end}
{p 24}[ {cmd:,} {it:more_graph_options} ]{p_end}

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:nlma}}
report Normalized LMA graph instead of default LMA graph
{p_end}
{synopt:{it:graph_options}}
options to pass to underlying call to graph {cmd:line} command
{p_end}
{synopt:{it:more_graph_options}}
options to pass to underlying call to {cmd:twoway} command that combines the separate {cmd:line} graphs
{p_end}
{synoptline}
{p2colreset}{...}


{title:Contents}

{phang}{help ginilma##description:Description}{p_end}
{phang}{help ginilma##examples:Examples of usage}{p_end}
{phang}{help ginilma##references:References}{p_end}
{phang}{help ginilma##citation:Citation of ginilma}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt ginilma} is a routine for plotting the Gini LMA and NLMA curves.
The LMA curve is the Line of independence Minus the Absolute concentration;
the NLMA curve is the Normalized LMA curve.

{pstd}
The LMA curve enables us to see how the Gini covariance
(the numerator of the Gini regression coefficient) is composed.
The LMA curve is constructed of the difference between two Absolute Concentration Curves (ACCs).
One curve is the ACC constructed under the assumption of statistical independence between Y and X.
Hence, it is a straight line connecting (0,0) and (µ_y, 1),
where µ_y designates the mean of Y.
It is referred to as the "Line of Independence".
The second ACC is the actual concentration curve.
The LMA is the vertical difference between the two curves, hence, LMA_yx.

{pstd}
Formally, let g(x) = E{Y|X=x_p},
where P= F(x_p) and F is the cumulative distribution of X.
Then the derivative of the LMA with respect to X is  µ_y -g'(x_p). 
The area enclosed between the LMA curve and the horizontal axis is equal to the Gini covariance
(defined as Cov(Y, F(X)), where F(X) is the empirical CDF of X).

{pstd}
The LMA curve has the following properties:

{p 8 12 2}(a) If the curve is above (below) the horizontal axis,
the contribution of this section to the regression coefficient is positive (negative).{p_end}
{p 8 12 2}(b) If the curve intersects the horizontal axis,
then there is a monotonic increasing transformation of X
that can change the sign of the OLS regression coefficient
(but not the coefficient of Gini regression).{p_end}
{p 8 12 2}(c) If the curve is concave (convex, straight line),
then the local regression coefficient is decreasing (increasing, constant).{p_end}
{p 8 12 2}(d) Connect two points of the curve by a straight line.
Then one can view the area enclosed as the MA curve of truncated distribution.{p_end}

{pstd}
If we divide the LMA curve by cov(X, F(X)),
then the area between the curve and the horizontal axis is equal to the Gini regression coefficient.
This is referred to as the Normalized LMA or NLMA.

{pstd}
{opt ginilma} requires the user to a miniumum of two variables in {opt varlist}.
The last variable (X) specified is the variable on the horizontal axis (the empirical CDF);
the preceding variables (Ys) are plotted on the vertical axis vs. X.

{pstd}
For single plots, if more than one Y variable is specified
{opt ginilma} uses a single sample for the plot.
To plot the LMA or NLMA for two different data samples,
the multiple-plot syntax should be used.

{pstd}
{opt ginilma} works by using Stata's {help twoway} command,
either by a single call to {help twoway line},
or by using {help twoway} to combine muliple {help line} graphs.
Options can be passed to the separate calls to {help line}
and/or to the overall {help twoway} command.

{marker examples}{...}
{title:Examples}

{pstd}Load Mroz cross-sectional dataset on female labor force participation{p_end}

{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta"}{p_end}

{pstd}LMA curve of participation (inlf) vs. age{p_end}

{phang2}. {stata "ginilma inlf age"}{p_end}

{pstd}NLMA curve of participation vs. age{p_end}

{phang2}. {stata "ginilma inlf age, nlma"}{p_end}

{pstd}LMA curve of participation vs. age for women living in cities{p_end}

{phang2}. {stata "ginilma inlf age if city==1"}{p_end}

{pstd}LMA curve of participation vs. education{p_end}

{phang2}. {stata "ginilma inlf educ"}{p_end}

{pstd}Combined LMA curves for participation vs. age, urban vs. rural{p_end}

{phang2}. {stata `"ginilma (inlf age if city==1) (inlf age if city==0), title("Participation, urban/rural") ytitle(LMA)"'}{p_end}


{marker references}{...}
{title:References}

{phang}
Yitzhaki, Shlomo and Schechtman, E. 2013.
The Gini Methodology: A Primer on a Statistical Methodology.
Springer.
{p_end}

{phang}
Yitzhaki, Shlomo and Schechtman, E. 2012.
Identifying monotonic and non-monotonic relationships.
{browse "http://dx.doi.org/10.1016/j.econlet.2011.12.123":Economics Letters 116 (2012) 23–25}.
{p_end}



{marker citation}{...}
{title:Citation of ginilma}

{pstd}{opt ginilma} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Schaffer, M.E. 2015.
ginilma: Progam to graph Gini LMA and NLMA curves
{browse "http://ideas.repec.org/c/boc/bocode/XXX.html":http://ideas.repec.org/c/boc/bocode/XXX.html}{p_end}


{title:Author}

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 1 10}On-line: help for {helpb ginireg} (if installed){p_end}
