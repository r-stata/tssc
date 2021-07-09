{smcl}
{* *! version 2.0  07nov2017}{...}
{* *! Doug Hemken}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "dyndoc" "help dyndoc"}{...}
{vieweralsosee "dyntext" "help dyntext"}{...}
{vieweralsosee "dynamic tags" "help dynamic tags"}{...}
{viewerjumpto "Syntax" "dyn2do##syntax"}{...}
{viewerjumpto "Description" "dyn2do##description"}{...}
{viewerjumpto "Options" "dyn2do##options"}{...}
{viewerjumpto "Remarks" "dyn2do##remarks"}{...}
{viewerjumpto "Examples" "dyn2do##examples"}{...}
{title:Title}

{phang}
{bf:dyn2do} Extract Stata commands from a dynamic document


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:dyn2do}
filename
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sav:ing(filename2)}}save extracted commands in {it:filename2}{p_end}
{synopt:{opt replace}}replace {it:filename2} if it already exists{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:dyn2do} Takes a dynamic document and extracts the Stata code.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt saving} {it: filename2} to save the code, the resulting do file {p_end}

{phang}
{opt replace} replace {it:filename2} if it already exists{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on the whatever statistic, see {bf:[R] intro}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. whatever mpg weight}{p_end}

{phang}{cmd:. whatever mpg weight, meanonly}{p_end}

{title:Author}

{p 4} Doug Hemken {p_end}
{p 4} Social Science Computing Cooperative{p_end}
{p 4} Univ of Wisc-Madison{p_end}
{p 4} {browse "mailto:dehemken@wisc.edu":dehemken@wisc.edu}{p_end}
{p 4} https://www.ssc.wisc.edu/~hemken/Stataworkshops{p_end}
{p 4} https://github.com/Hemken/dyn2do{p_end}
