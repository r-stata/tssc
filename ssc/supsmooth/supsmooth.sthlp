{smcl}
{* *! version 1.0.0  16june2015}{...}
{vieweralsosee "[G-2] graph" "help graph"}{...}
{vieweralsosee "[R] lowess" "help lowess"}{...}
{vieweralsosee "[R] lpoly" "help lpoly"}{...}
{viewerjumpto "Syntax" "supsmooth##syntax"}{...}
{viewerjumpto "Description" "supsmooth##description"}{...}
{viewerjumpto "Options" "supsmooth##options"}{...}
{viewerjumpto "Examples" "supsmooth##examples"}{...}
{viewerjumpto "Stored results" "supsmooth##results"}{...}
{viewerjumpto "References" "supsmooth##references"}{...}
{viewerjumpto "Author" "supsmooth##author"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:supsmooth} {hline 2}}Friedman's super smoother{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:supsmooth} {it:yvar} {it:xvar} {ifin}
[{it:{help supsmooth##weight:weight}}]
[{cmd:,} {it:options}]

{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Main}
{synopt:{opth bw:cv(numlist)}}bandwidths to be cross-validated; 
		default bandwidths are 0.05, 0.2, and 0.5 {p_end}
{synopt:{opt alg:orithm}({it:update}|{it:wfit})}specify algorithm; 
		default is {it:update}{p_end}
{synopt:{opt alpha(#)}}specify oversmoothing parameter; default is 
		{cmd:alpha(0)}, i.e., no oversmoothing{p_end}
{synopt:{opt tri:cube}}use tricube weights for local linear fits; 
		available only with {cmd:algorithm}({it:wfit}){p_end}
{synopt :{cmdab:gen:erate(}{it:{help newvar:newvar_s}} [, replace])}store
		smoothed points in {it:newvar_s}{p_end}
{synopt :{opt nogr:aph}}suppress graph{p_end}
{synopt :{opt nosc:atter}}suppress scatterplot only{p_end}

{syntab :Scatterplot}
INCLUDE help gr_markopt2

{syntab :Smoothed line}
{synopt :{opth lineop:ts(cline_options)}}affect rendition of the smoothed line{p_end}

{syntab :Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the generated graph{p_end}

{syntab :Y axis, X axis, Titles, Legend, Overall}
{synopt :{it:twoway_options}}any options other than {cmd:by()} documented in
      {manhelpi twoway_options G-3}{p_end}
{synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 4 6 2}
{cmd:aweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:supsmooth} performs adaptive bandwidth local linear regression
based on Friedman's super smoother algorithm;
adaptive bandwidth lowess smoothing is also available. {cmd:supsmooth}
smoothes {it:yvar} as a function of {it:xvar} and displays a 
graph of the smoothed values.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth bw:cv(numlist)} specifies the cross-validated bandwidths. Any number of
bandwidths can be specified, default bandwidths are 0.05, 0.2, and 0.5. 
Specifying only one bandwidth results in a fixed bandwidth local linear
regression; bandwidths need to be in the range (0,1). 

{phang}
{opt alg:orithm} specifies the algorithm; the default ({it:update})
is the updating algorithm proposed in 
{help supsmooth##references:Friedman (1984)}; the {it:wfit}
algorithm fits local linear models in each window and is therefore slower,
especially for larger samples; {it:wfit} is numerically more 
stable, potentially.

{phang}
{opt alpha(#)} specifies an oversmoothing parameter which
is biasing the smooth towards the largest bandwidth specified in {opt bwcv()};
the parameter needs to be in the range [0,10] where zero corresponds to no
oversmoothing, and 10 to the maximum oversmooth in which case the estimate
is the same as a fixed bandwidth smooth with the largest bandwidth
in {opt bwcv()}; defaults to alpha=0.

{phang}
{opt tri:cube} specifies that locally varying weights be used for the local 
linear regressions; specifying this option in combination with a list of
bandwidths results in an adaptive bandwidth lowess smoother; not available
with the updating algorithm.

{phang}
{cmd:{opt gen:erate}(}{it:{help newvar:newvar_s}} [, replace]{cmd:)} stores 
the smoothed values in {it: newvar_s}; optionally, existing variables may 
be replaced.

{phang}
{opt nogr:aph} suppresses drawing the graph of the estimated smooth.

{phang}
{opt nosc:atter} suppresses superimposing a scatterplot of the observed data
over the smooth.

{dlgtab:Scatterplot}

INCLUDE help gr_markoptf

{dlgtab:Smoothed line}

{phang}
{opt lineop:ts(cline_options)} affects the rendition of the smoothed
line; see {manhelpi cline_options G-3}.

{dlgtab:Add plots}

{phang}
{opt addplot(plot)} provides a way to add other plots to the generated graph;
see {manhelpi addplot_option G-3}.

{dlgtab:Y axis, X axis, Titles, Legend, Overall}

{phang}
{it:twoway_options} are any of the options documented in
{manhelpi twoway_options G-3}, excluding {opt by()}.
These include options for titling the
graph (see {manhelpi title_options G-3}) and for saving the graph to disk
(see {manhelpi saving_option G-3}).


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse motorcycle}{p_end}

{pstd}Original super smoother{p_end}
{phang2}{cmd:. supsmooth accel time}{p_end}

{pstd}Super smoother with finer grained bandwidth space{p_end}
{phang2}{cmd:. supsmooth accel time, bw(0.05(0.05)0.8)}{p_end}

{pstd}Adaptive bandwidth lowess smoothing{p_end}
{phang2}{cmd:. supsmooth accel time, bw(0.05(0.05)0.8) algorithm(wfit) tricube}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:supsmooth} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}sample size{p_end}
{synopt:{cmd:r(alpha)}}oversmoothing parameter{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}outcome variable{p_end}
{synopt:{cmd:r(indepvar)}}predictor variable{p_end}
{synopt:{cmd:r(wgt)}}type of weight{p_end}
{synopt:{cmd:r(wexp)}}weight expression{p_end}
{synopt:{cmd:r(algorithm)}}algorithm used{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(bw)}}bandwidths{p_end}

{p2colreset}{...}

{marker references}{...}
{title:References}
{pstd}
Friedman, Jerome H. (1984): A variable span smoother. Technical Report No. 5, 
Laboratory for Computational Statistics, Department of Statistics, 
Stanford University.

{marker author}{...}
{title:Author}
{pstd}Joerg Luedicke{p_end}
{pstd}StataCorp, College Station, TX{p_end}
{pstd}{browse "mailto:jluedicke@stata.com":jluedicke@stata.com}{p_end}
