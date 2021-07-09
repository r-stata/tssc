{smcl}
{* *! version 1.0.2  26aug2016}{...}
{findalias asfradohelp}{...}
{title:xtcdf}

{phang}
{bf:xtcdf} {hline 2} CD-test for cross-sectional dependence, see Pesaran (2004/2015).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: xtcdf}
{varlist}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtcdf} calculates the CD-test for cross-sectional dependence described in Pesaran (2004) and Pesaran (2015) for a {varlist} of any length.

{pstd}
The test can best be seen as an investigation of the mean correlation between panel units. The main insight of Pesaran (2004) is that a transformation of the sum of pairwise correlations
between panel units is standardnormally distrubuted. The null hypothesis is either strict cross-sectional independence (Pesaran, 2004) or weak cross-sectional dependence (Pesaran, 2015).

{pstd}
The test is suited for both balanced and unbalanced panels. In unbalanced panels, the command ignores combinations of panel units which have fewer than three joint observations
as correlations are not meaningful with two or fewer observations. A warning will be shown in the results table.

{pstd}
Assume we have a variable x, present in N panel units and up to T time periods (t). Then the statistic is calculated as follows:

{col 8} Standard deviation s_i = sqrt(1/(T_i-1) * sum(over t)(x_it - mean(x_it))^2)
{col 8} Correlation coeff r_ij = 1 / (T_i-1) * sum(over t)[(x_it - mean(x_it))/s_i * (x_jt - mean(x_jt))/s_j]
{col 8} Test statistic CD = sqrt(2/(N*(N-1)) * sum(over i and j)[sqrt(T_ij) * r_ij]

{pstd}
Under the null hypothesis of cross sectional independence / weak cross sectional dependence, the CD-statistic is distributed ~ N(0,1). Extreme values indicate there is some
(strong) correlation between panel units.


{marker remarks}{...}
{title:Remarks}

{pstd}
There are several other commands calculating this test. The first was {help xtcsd}, which was only usable as a post-estimation command. {help xtcd} generalised this to allowing any variable (list) to be analysed. {help xtcd2} added 
some useful features, e.g. histograms of the correlations and more postestimation possibilities. Initially, I did not publish this command on ssc, given that there were already so many other options. I decided to do so in the end because
this version is considerably faster than {help xtcd} and {help xtcd2} produced strange results (differing from xtcd) at the time of writing. Moreover, {help xtcd2} can only test one variable at a time.

{pstd}
The f-suffix stands for fast. This command is largely based on {help pwcorrf}, which is a faster way to calculate pairwise correlations than Stata's {help pwcorr}. It also has options to calculate correlations across panel units instead of 
across variables.

{pstd}
Any mistakes are my own.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse xtline1.dta, clear}{p_end}
{phang}{cmd:. gen x = rnormal()}{p_end}

{phang}{cmd:. xtreg calories x, fe}{p_end}
{phang}{cmd:. predict res, r}{p_end}
{phang}{cmd:. xtcdf calories res}{p_end}

{phang}{cmd:. sum day}{p_end}
{phang}{cmd:. replace calories = . if day < r(mean) & person == 1}{p_end}
{phang}{cmd:. replace calories = . if day >= r(mean) & person == 2}{p_end}
{phang}{cmd:. xtcdf calories}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtcdf} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(p)}}p values{p_end}
{synopt:{cmd:r(CD)}}values of the CD statistics{p_end}

{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pvalue{it:i})}}The p-values are also stored as scalars (often more convenient){p_end}
{synopt:{cmd:r(qp{it:i})}}Same for the cd-statistics{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{it:General diagnostic tests for cross section dependence in panels}, Pesaran, M. H., CESifo Working Paper No. 1229, 2004

{it:Testing Weak Cross-Sectional Dependence in Large Panels}, Pesaran, M. H., Econometric Reviews, 2015

{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 
