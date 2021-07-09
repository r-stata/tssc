{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "lvr2plot" "help lvr2plot"}{...}
{vieweralsosee "lvr2dplot" "search lvr2dplot"}{...}
{viewerjumpto "Syntax" "lvr2plot2##syntax"}{...}
{viewerjumpto "Description" "lvr2plot2##description"}{...}
{viewerjumpto "Options" "lvr2plot2##options"}{...}
{viewerjumpto "Examples" "lvr2plot2##examples"}{...}
{title:Title}


{phang}
{bf:lvr2plot2} {hline 2} leverage-versus-squared-residual plot with Cook's D

{marker syntax}{...}
{title:Syntax for lvr2plot}

{p 8 20 2}
{cmd:lvr2plot} 
[{cmd:,} {it:lab}({varname}[, {it:all}]) *]

{synoptset 24 tabbed}{...}
{synopthdr:lvr2plot_options}
{synoptline}
{syntab:Label}
{synopt :{it:lab}( {varname} [, {it:all}] )}label points with the values of 
{it:varname}. by default only potential influential cases are labeled unless 
the {it:all} sub-option is specified.{p_end}

{syntab:Plot}
INCLUDE help gr_markopt

{syntab:Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the enerated graph{p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall}
{synopt :{it:twoway_options}}any options other than {opt by()}
   documented in {manhelpi twoway_options G-3}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description for lvr2plot2}

{pstd}
{opt lvr2plot2} is identical to {help lvr2plot}, in that it graphs a 
leverage-versus-squared-residual plot (a.k.a. L-R plot), except that 
{cmd:lvr2plot2} also lets the size of the symbols be proportional to Cook's D. 
This is also possible with the user written {cmd: lvr2dplot}, except that that
uses old (pre-Stata 8) graphs. Moreover, {cmd:lvr2plot2} makes it easier to 
label the data points.


{marker options}{...}
{title:Options for lvr2plot}

{dlgtab:Label}

{phang}
{it:lab}( {varname} [, {it:all}] ) label points with the values of 
{it:varname}. by default only potential influential cases are labeled unless 
the {it:all} sub-option is specified.

{dlgtab:Plot}

{phang}
{opt detail} displays detailed output of the calculation.

INCLUDE help gr_markoptf

{dlgtab:Add plots}

{phang}
{opt addplot(plot)} provides a way to add other plots to the generated graph.
See {manhelpi addplot_option G-3}.

{dlgtab:Y axis, X axis, Titles, Legend, Overall}

{phang}
{it:twoway_options} are any of the options documented in 
{manhelpi twoway_options G-3}, excluding {opt by()}.  These include options for
titling the graph (see {manhelpi title_options G-3}) and for saving the
graph to disk (see {manhelpi saving_option G-3}).


{marker examples}{...}
{title:Examples}

{cmd}
    sysuse auto
    reg price mpg weight i.foreign i.rep78
    lvr2plot2
    lvr2plot2, lab(make)
{txt}


{title:Author}

{pstd}Maarten L. Buis, University of Konstanz{break}
    maarten.buis@uni-konstanz.de
