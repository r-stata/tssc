{smcl}
{* *! version 1.0.0  14may2013}{...}
{cmd:help pciplot}{right: Patrick Royston}
{hline}


{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:pciplot} {hline 2}}Plot pointwise confidence intervals{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:pciplot} {it:yvar} {{it:yvar_lci {it:yvar_uci}} | {it:se_yvar}} {it:xvar} {ifin} [, {it:options} ]


{synoptset 30}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt add:plot(plot)}}add other plots to the generated graph{p_end}
{synopt :{it:twoway_options}}options for {cmd:graph, twoway}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:pciplot} produces plots of pointwise confidence intervals for {it:yvar}
against a continuous variable, {it:xvar}. Either the s.e., {it:se_yvar}, of
{it:yvar} or the confidence limits, {it:yvar_lci} and {it:yvar_uci}, may be
supplied. The CIs are rendered as a shaded area and the relationship between
{it:yvar} and {it:xvar} is plotted as a line.


{title:Options}

{phang}
{opt addplot(plot)} provides a way to add other plots to the
generated graph. See {manhelpi addplot_option G-3}.

{phang}
{it:twoway_options} are any options appropriate to {cmd:graph, twoway}.


{title:Examples}

{phang}{cmd:. pciplot y y_se x, addplot(line x x, sort)}{p_end}
{phang}{cmd:. gen y_lci = y - 1.96 * y_se}{p_end}
{phang}{cmd:. gen y_uci = y + 1.96 * y_se}{p_end}
{phang}{cmd:. pciplot y y_lc y_uci x, yline(1) legend(off) saving(graph, replace)}{p_end}


{title:Author}

{phang}Patrick Royston{p_end}
{phang}MRC Clinical Trials Unit{p_end}
{phang}London, UK{p_end}
{phang}pr@ctu.mrc.ac.uk{p_end}


{title:Also see}

{psee}
Online:  {helpb graph_twoway}{p_end}
