{smcl}
{* *! version 1.0  14apr2016}{...}
{viewerdialog kdensity "dialog mkdensity"}{...}
{viewerjumpto "Reference" "kdensity##reference"}{...}
{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :mkdensity {hline 2}}Plots kernel densities of several variables (wrapper of the {help kdensity} command){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mkdensity} {varlist} {ifin}
[{it:{help mkdensity##weight:weight}}]
[{cmd:,} {it:options}]

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt: {opth k:ernel(mkdensity##kernel:kernel)}}specify kernel function;
            default is {cmd:kernel(epanechnikov)}{p_end}
{synopt :{opt bw:idth(#)}}half-width of kernel{p_end}
{synopt :{opth g:enerate(newvar_x newvar_d)}}store the estimation points in variables name stub {it:newvar_x} and the density estimates in variables name stub {it:newvar_d}{p_end}
{synopt :{opt n(#)}}estimate density using {it:#} points; default is min(N, 50){p_end}
{synopt :{opth over:(varname)}}display densities of each category of {it:varname} in one plot{p_end}
{synopt :{opth by:(varname)}}combine plots by categories of {it:varname} into one graph{p_end}
{synopt :{opt nogr:aph}}suppress graph{p_end}
{synopt :{opth xline:(value)}}vertical line at {it:value}{p_end}
{synopt :{opth save:(name)}}save graph into {it:name.png}{p_end}
{synopt :{opth title:(string)}}title of graph into {it:name.png}{p_end}
{synopt :{opt ycom:mon}}give {it:y} axes common scales when {opt by()} option is specified{p_end}
{synopt :{opt xcom:mon}}give {it:x} axes common scales when {opt by()} option is specified{p_end}
{synopt :{opt r:ows(#)} | {opt c:ols(#)}}display in # rows or # columns when {opt by()} option is specified{p_end}

{synoptline}

{synoptset 29}{...}
{marker kernel}{...}
{synopthdr :kernel}
{synoptline}
{synopt :{opt ep:anechnikov}}Epanechnikov kernel function; the default{p_end}
{synopt :{opt epan2}}alternative Epanechnikov kernel function{p_end}
{synopt :{opt bi:weight}}biweight kernel function{p_end}
{synopt :{opt cos:ine}}cosine trace kernel function{p_end}
{synopt :{opt gau:ssian}}Gaussian kernel function{p_end}
{synopt :{opt par:zen}}Parzen kernel function{p_end}
{synopt :{opt rec:tangle}}rectangle kernel function{p_end}
{synopt :{opt tri:angle}}triangle kernel function{p_end}
{synoptline}
{p2colreset}{...}

{marker weight}{...}
{pstd}
{cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed; see
{help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:mkdensity} produces kernel density estimates of several variables and 
graphs the result. As a default, it plots the densities of the given variables 
in one graph plot. It is also possible to handle panel data type structures 
using the over() and/or the by() options. {cmd:mkdensity} uses the 
{help kdensity} command to calculate the underlying densities.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth "kernel(mkdensity##kernel:kernel)"} specifies the kernel function for use
in calculating the kernel density estimate.  The default kernel is
the Epanechnikov kernel ({opt epanechnikov}).

{phang}
{opt bwidth(#)} specifies the half-width of the kernel, the width of the
density window around each point.  If {opt bwidth()} is not specified, the
"optimal" width is calculated and used; see {bind:{bf:[R] kdensity}}.  The
optimal width is the width that would minimize the mean integrated squared
error if the data were Gaussian and a Gaussian kernel were used, so it is not
optimal in any global sense.  In fact, for multimodal and highly skewed
densities, this width is usually too wide and oversmooths the
density ({help mkdensity##S1992:Silverman 1992}).

{phang}
{opth "generate(newvar:newvar_x newvar_d)"} stores the results of the
estimation.  For each variable in the main varlist, the variable with name 
starting with {it:newvar_x} will contain the points at which the densities are
estimated.  Similarly, the variables with the beginning stub {it:newvar_d} will 
contain the density estimates.

{phang}
{opt n(#)} specifies the number of points at which the density estimate is to
be evaluated.  The default is min(N,50), where N is the number of
observations in memory.

{phang}
{opth "over(varname)"} displays densities of each category of {it:varname} in 
one plot. For each variable in the main {it:varlist}, it calculates separate 
densities for the subsamples identified by the distinct values (categories) of 
{it:varname}. The option can be combined with the {opt by()} option.

{phang}
{opth "by(varname)"} displays densities of each category of {it:varname} in 
separate plots and combines these plots into one graph. For each variable in 
the main {it:varlist}, it calculates separate densities for the subsamples 
identified by the distinct values (categories) of {it:varname}. The option can 
be combined with the {opt over()} option.

{phang}
{opt nograph} suppresses the graph.  This option is often used 
with the {opt generate()} option.


{marker examples}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{stata "sysuse auto2, clear"}{p_end}

{pstd}Graph kernel density estimates for {cmd:length} and {cmd:displacement} 
with a vertical line at 200{p_end}
{phang2}{stata "mkdensity length displacement, xline(200)"}{p_end}

{pstd}Graph kernel density estimates for {cmd:price} (both domestic and 
foreign) in one plot{p_end}
{phang2}{stata "mkdensity price, over(foreign)"}{p_end}

{pstd}Graph kernel density estimates for domestic and foreign {cmd:price} 
by different plots of repair record, combined into one graph{p_end}
{phang2}{stata "mkdensity price, over(foreign) by(rep78)"}{p_end}

{pstd}Graph kernel density estimates for for domestic and foreign {cmd:price} 
and {cmd:weight}{p_end}
{phang2}{stata "mkdensity price weight, by(foreign)"}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mkdensity} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(bwidth)}}kernel bandwidth{p_end}
{synopt:{cmd:r(n)}}number of points at which the estimate was evaluated{p_end}
{synopt:{cmd:r(scale)}}density bin width{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(kernel)}}name of kernel{p_end}
{p2colreset}{...}


{title:Author}
{txt}
{pstd}Szabolcs Lorincz{p_end}
{pstd}szabolcs@gmail.com{p_end}

{marker reference}{...}
{title:Reference}

{marker S1992}{...}
{phang}
Silverman, B. W. 1992.
{it:Density Estimation for Statistics and Data Analysis}.
London: Chapman & Hall.
{p_end}
