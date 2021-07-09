{smcl}
{* *! version 1.0.0  25sept2018}{...}
{vieweralsosee "[D] describe" "help describe"}{...}
{vieweralsosee "[D] ds" "help ds"}{...}
{vieweralsosee "findname" "help findname"}{...}
{viewerjumpto "Syntax" "lookfor2##syntax"}{...}
{viewerjumpto "Description" "lookfor2##description"}{...}
{viewerjumpto "Examples" "lookfor2##examples"}{...}
{viewerjumpto "Stored results" "lookfor2##results"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{cmd:lookfor2} {hline 2}}Search for string in variable names, variable 
labels, value labels, and notes{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:lookfor2} {it:{help strings:string}}
    [{it:{help strings:string}} [...]], [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nonote}}do not search the notes{p_end}
{synopt:{opt novall:ab}}do not search the value labels{p_end}
{synoptline}
{p2colreset}{...}
	

{marker description}{...}
{title:Description}

{pstd}
{cmd:lookfor2} helps you find variables by searching for 
{it:{help strings:string}} among all variable names, 
{help label:variable labels}, {help label:value labels}, and 
{help notes:notes} attached to variables.  If multiple {it:string}s are 
specified, {cmd:lookfor2} will search for each of them separately.  You may 
search for a phrase by enclosing {it:string} in double quotes.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. notes hours : per week}{p_end}

{pstd}Find all occurrences of {cmd:union} in variable names, notes, variable and 
value labels{p_end}
{phang2}{cmd:. lookfor2 union}{p_end}

{pstd}Find all occurrences of {cmd:single} in variable names, notes, variable 
and value labels{p_end}
{phang2}{cmd:. lookfor2 single}{p_end}

{pstd}Find all occurrences of {cmd:week} in variable names, notes, variable 
and value labels{p_end}

{phang2}{cmd:. lookfor2 week}{p_end}

{pstd}Find all occurrences of {cmd:week} in variable names, variable 
and value labels, but exclude notes{p_end}
{phang2}{cmd:. lookfor2 week, nonote}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:lookfor} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}the varlist of found variables{p_end}
{p2colreset}{...}
