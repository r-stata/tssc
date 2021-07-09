{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat graph}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{cmd:spmat graph} {hline 2}}Draw an intensity plot of the
spatial-weighting matrix {bf:W} contained in an {bf:spmat} object
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:gr:aph} {it:objname} [{cmd:,} {it:options}]


{synoptset 33 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{p2col:{cmdab:bl:ocks(}[{cmd:(}{it:stat}{cmd:)}] {it:p}{cmd:)}}plot matrix in
    {it:p} x {it:p} blocks{p_end}

{syntab :Y axis, X axis, Titles, Legend, Overall}
{p2col:{it:{help twoway_options}}}any options other than {cmd:by()} documented
	in {bind:{bf:[G] {it:twoway_options}}}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}

{pstd}
{opt spmat graph} draws an intensity plot of the
spatial-weighting matrix {bf:W} contained in the {cmd:spmat} object
{it:objname}.  Zero elements are plotted in white; the remaining elements are
partitioned into 16 bins of equal length and assigned gray-scale colors
{cmd:gs0}-{cmd:gs15}; see {manhelpi colorstyle G}.


{title:Options}

{dlgtab:Main}

{phang}
{cmd:blocks()} divides the matrix into blocks of size {it:p} and plots
    block maximums.  To plot a statistic other than the default maximum,
    specify the optional {it:stat} argument. For example, to plot block
    medians, specify {cmd:blocks((p50)} {it:p}{cmd:)}.  The supported
    statistics include those returned by {cmd:summarize, detail}; see
    {helpb summarize} for a complete list.

{dlgtab:Y axis, X axis, Titles, Legend, Overall}

{phang}
{it:twoway_options} are any of the options documented in 
	{manhelpi twoway_options G}, excluding {opt by()}.
	These include options for titling the graph
	(see {manhelpi title_options G}) and 
	for saving the graph to disk (see {manhelpi saving_option G}).


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Plot the contiguity matrix contained in the spmat object {cmd:cobj}
in 5 x 5 blocks{p_end}
{phang2}{cmd:. spmat graph cobj, blocks(5)}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

