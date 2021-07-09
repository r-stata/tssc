{smcl}
{* version 0.0.6 20november2015}{...}
{hline}
help for {melt}
{hline}

{title:Title}

{p 4 4 2}
{bf:melt} {hline 2} module to melt variables into a dataset containing aggregated data by variable


{title:Syntax}

{pstd}{cmd:melt} [{it:varlist}] {opt [weight]} [{cmd:,} {opt num:labels} {opt by(varlist)} {opt mo:reoff}] 


{title:Description}

{phang}Comparable with {it:summarize} melt generates aggregated data of all variables in the variable list. However, instead of displaying an output of all data the aggregated information become transfered into a new dataset. {p_end}


{title:Options}

{phang} {cmdab:by} groups over which stats are to be calculated.{p_end}
{phang} {cmdab:mo:reoff} by default the macro breaks to display a warning message; moreoff turns this behaviour off.{p_end}

{title:Author}

{pstd} Johannes N. Blumenberg{break}
University of Mainz (Germany){break} 
Department of Political Science{break} 
Empirical Political Research{break}
blumenberg@politik.uni-mainz.de{p_end}

