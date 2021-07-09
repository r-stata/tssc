{smcl}
{* *!1.0.0  Brent Mcsharry brent@focused-light.net 6Mar2011}{...}
{cmd:help boxpanel}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:boxpanel} {hline 2}}Box plots for panel data{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:boxpanel}
{yvar timecategoryvar}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt track:by(varname)}} track outliers by the specified variable. {p_end}
{synopt:{opt join:median}} draw a line detween the median values. {p_end}
{synopt:{opth barw(#)}} specify the width of the box plot. {p_end}
{synopt:{opt legendc:ols}} specify the number of columns in the legend describing outliers. Only relevant if a {opt trackby} variable is specified. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:boxpanel} creates a boxplot where the x variable represents a scalar time variable 
(each distinct value grouping each set of observations), such that the spacing between 
box plots relates to the time interval between each panel. 
{p_end}

{title:Options}

{dlgtab:Main}

{phang}
{opt trackby}. By specifying the subject id, outliers representing the same individual will 
have the same color scheme. When a subject remains an outlier over sequential time points,
a line will connect the markers for that particular subject.
{p_end}

{phang}
{opt joinmedian} Plot a line joining the median values over time.
{p_end}

{phang}
{opt barw} The width of the box. If ommitted, will be 50% of the minimum distance between
time categories.
{p_end}

{phang}
{opt legendcols} The number of colums to use when displaying the legend of outliers. Only relevant if a {opt trackby} variable is specified, otherwise no legend is displayed. Default value is 1.
{p_end}
{title:Remarks}

{pstd}
This command is designed to visually assess trends in the distribution of panel data over time. 
In contrast to the {cmd:graph box} command, the time variable (xvar), while denoting distinct sets of observations (according to time post enrollment), is also assumed 
to be scaled. This is particularly useful for assesing trends when panels of observations have been collected more intensively at certain times, such as when entering
a study, or after a point of treatment crossover.
{p_end}

{pstd}
Used with the {cmd:trackby} option, subjects with observations which are persistently outlying can be tracked over time.
{p_end}

{title:Authors}

{p 4 4 2}Brent McSharry, Starship Children's Hospital, Auckland New Zealand{break}
brentm@adhb.govt.nz
{p_end}

{title:Acknowledgment}
{pstd}the code borrows heavily from an article written by Nicholas J. Cox in the Stata Journal, along with a correction by Sheena Sullivan, published in statalist (See below).{p_end}

{title:Examples}
{hline}
{pstd}Setup{p_end}
{phang2}{stata "webuse epilepsy"}{p_end}
{phang2}{stata "replace visit=1 if abs(visit-.3) < 0.0001"}{p_end}
{pstd}Plot{p_end}
{phang2}{stata "boxpanel seizures  visit if treat, track(subject)"}{p_end}
{hline}
{title:Also see}

{psee}
{manhelp graph_box G}
{p_end}
{psee}
Article: {it:Stata Journal}, volume 9, number 3: {browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0039":gr0039}
{p_end}
{psee}
Article: {it:Stata List}, Subject: calculating the whiskers on a boxplot using -twoway- {browse "http://www.stata.com/statalist/archive/2013-03/msg00917.html":msg00917}
{p_end}