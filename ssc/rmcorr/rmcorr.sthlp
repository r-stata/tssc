{smcl}
{* *! version 1.0.0 12Jul2021}{...}
{title:Title}

{p2colset 5 15 16 2}{...}
{p2col:{hi:rmcorr} {hline 2}} Correlation for data with repeated measures {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:rmcorr}
{it: yvar}
{it: xvar}
{it: id}
{ifin}
[,
{opt l:evel(#)}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]


{pstd}
{it:yvar} is the dependent variable, {it:xvar} is the independent variable, and {it:id} is the subject's identifier


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]}produce a scatterplot of the {it:dvar} vs {it:xvar} combined with a linear fit for each subject's data{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{opt by} is allowed with {cmd:rmcorr}; see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt rmcorr} computes a correlation coefficient for data in which subjects have repeated measures (i.e. multiple observations), as proposed by Bland and Altman (1995). 
Additionally, confidence intervals are calculated by using Fisher's {it:z} transform (Gleason 1996). 
When the {opt figure} option is specified, a graph is generated that includes a scatterplot of each subject's observations and a linear fit through those points. 
This graph assists the user in visualizing the variation amongst subjects.  



{title:Options}

{p 4 8 2} 
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for
confidence intervals.  The default is {cmd:level(95)} or whatever is set by
{helpb set level}.

{p 4 8 2} 
{cmd:figure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}] produces a scatterplot of the {it:dvar} vs {it:xvar} 
combined with a linear fit for each subject's data.
Specifying {cmd:figure} without options uses the default graph settings.



{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use bland1995.dta}{p_end}

{pstd}Basic specification{p_end}
{phang2}{cmd:. rmcorr ph paco2 subject}{p_end}

{pstd}Add figure{p_end}
{phang2}{cmd:. rmcorr ph paco2 subject, fig}{p_end}

{pstd}Adjust the Y-axis scale on the figure{p_end}
{phang2}{cmd:. rmcorr ph paco2 subject, fig(ylabel(6(.5)7.5))}{p_end}

{pstd}Specify 99% confidence limits{p_end}
{phang2}{cmd:. rmcorr ph paco2 subject, level(99)}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rmcorr} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(obs)}}number of observations in estimation sample{p_end}
{synopt:{cmd:r(rho)}}correlation coefficient{p_end}
{synopt:{cmd:r(lb)}}lower confidence limit{p_end}
{synopt:{cmd:r(ub)}}upper confidence limit{p_end}
{synopt:{cmd:r(pval)}}{it:P}-value{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Bland, J. M. and D. G. Altman. 1995. Calculating correlation coefficients with repeated observations: part 1—correlation within subjects. {it:BMJ} 310: 446. {p_end}

{p 4 8 2}
Gleason, J. R. 1996. Inference about correlations using the Fisher z-transform. {it:Stata Technical Bulletin} 32: 13-18.{p_end}



{marker citation}{title:Citation of {cmd:rmcorr}}

{p 4 8 2}{cmd:rmcorr} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2021). RMCORR: Stata module to compute a correlation for data with repeated measures. {browse "https://ideas.repec.org/c/boc/bocode/s458971.html"}




{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb anova}, {helpb corr} {p_end}

