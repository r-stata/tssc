{smcl}
{* version 0.6  31aug2011}{...}
{hline}
{cmd:help for misspattern}{right:Ian White}
{hline}

{title:Title}

{phang}{bf:misspattern} {hline 2} Graph missing data pattern


{marker description}{...}
{title:Description}

{pstd}
{cmd:misspattern} creates a rectangular display of a data set, with the variables on the vertical axis and observations on the horizontal axis, filled in with two different colours to show observed and missing data. It can be used to assess the extent and pattern of missing data in a dataset.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:misspattern}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt novarsort}}Keeps variables in their order in the data set. Otherwise the variables are sorted from least missing at the top to most missing at the bottom.{p_end}
{synopt:{opt noidsort}}Keeps observations in their original order in the data set. Otherwise the observations are sorted from least missing at the left to most missing at the right.{p_end}
{synopt:{opt rev:erse}}reverses the order of the variables{p_end}
{synopt:{opt miss:color(string)}}specifies the shading used for missing values: default is black.{p_end}
{synopt:{opt obs:color(string)}}specifies the shading used for observed values: default is grey.{p_end}
{synopt:{opt clear}}clears the current data and loads the summary data into memory: this could be useful if you want to fine-tune the graph{p_end}
{synopt:{opt indivs:name(string)}}specifies how the graph refers to the records: default is "individuals".{p_end}
{synopt:{opt label}}labels the vertical axis using variable labels instead of variable names.{p_end}
{synopt:{cmd:varlabel(}{help cat_axis_label_options}{opt )}}allows options for the appearance of the variable names or labels. For example, varlabel(labsize(small) labcol(red)).{p_end}
{synopt:{opt graph_options}}are any other options allowed by {help graph hbar}.{p_end}
{synoptline}
{p2colreset}{...}



{marker remarks}{...}
{title:Remarks}

{pstd}
A monotone pattern is characterised by a "staircase" pattern with the missing values below and to the right of the observed values.

{pstd}
{cmd:misspattern} is implemented using {help graph hbar} with a set of bars of alternating colour.
The number of such bars used is output; it is usually fewer than the number of distinct patterns.
The code uses one option to define the colour of each bar: because Stata limits the number of options t0 70, the code fails with the message "too many options" if there are more than about 60 bars.
If this happens, try reducing the number of variables. (In the future I may find a way to eliminate a few observations so that the code works on the remainder.)


{marker examples}{...}
{title:Examples}

{phang}{cmd:. use UK500, clear}

{p 0 0 0}Summary of the whole data set:

{phang}{cmd:. misspattern}

{p 0 0 0}More detailed view, changing several options:

{phang}{cmd:. misspattern cprs* sat* if centre==3, misscol(red) obscol(blue) ytitle(,size(large)) varlabel(labsize(large)) legend(size(large))}


{title:See also}

{help mtable} -- table showing missing values
{help mscatter} -- scatterplot showing missing values
