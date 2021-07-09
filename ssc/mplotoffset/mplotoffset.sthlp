{smcl}
{* *! version 1.0 11may2017 }{...}
{title:Title}

{p2colset 5 26 28 2}{...}
{p2col :{cmd:mplotoffset} {hline 2}}Marginsplot with offset plotting
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 21 2}{cmd:mplotoffset} {help marginsplot:{it:marginsplot_specification}} [{cmd:,} 
	{it:offset_options} {help marginsplot##options:{it:marginsplot_options}}]

{synoptset 37 tabbed}{...}
{synopthdr:offset_options}
{synoptline}
{synopt:{cmdab:off:set(}{it:number}{cmd:)}}amount to offset x-axis categories. The default is 0.05.{p_end}
{synopt :{cmdab:ovar(}{it:varname}{cmd:)}}Specify variable name to offset. Default is the variable that defines the plots.{p_end}
{synoptline}
{phang}
    {it:marginsplot_options} is the full set of options available for {help marginsplot:marginplot} command.

{marker description}{...}
{title:Description}

{pstd}
{cmd:mplotoffset} is a modified version of marginplot that offsets on the x-axis the multiple plots.  This can help to see clearly
	 the confidence intervals.
	 
{pstd}
This command is based on a slightly-modified version of the official Stata marginsplot.ado; it is based on the marginsplot version 1.1.1 (14mar2015).
	

{marker examples}{...}
{title:Examples}

{pstd}Combining results from multiple parallel models{p_end}
{phang2}. {stata sysuse auto}{p_end}

{phang2}. {stata reg mpg  i.rep78 i.foreign i.rep78#i.foreign}{p_end}
{phang2}. {stata margins rep78#foreign}{p_end}
{phang2}. {stata mplotoffset}{p_end}

{phang2}. {stata oprobit rep78 mpg price weight}{p_end}
{phang2}. {stata margins , at(mpg=(10(5)40))}{p_end}
{phang2}. {stata mplotoffset, offset(0.5) recast(scatter)}{p_end}


{marker author}{...}
{title:Author}

{phang2}Nicholas Winter, University of Virginia, USA{p_end}
{phang2}nwinter@virginia.edu{p_end}

