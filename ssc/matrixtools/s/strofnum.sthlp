{smcl}
{* *! version 0.23}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "strtonum" "help strtonum"}{...}
{viewerjumpto "Syntax" "strofnum##syntax"}{...}
{viewerjumpto "Description" "strofnum##description"}{...}
{viewerjumpto "Examples" "strofnum##examples"}{...}
{title:Title}
{phang}
{bf:strofnum} {hline 2} transform a numeric variable to a string variable using
the value label if it exists. Otherwise the format is used.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:strofnum}
varlist(min=1)
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt k:eep}} Option for keeping the original numeric variables.
The original variable name is renamed with a __ prefix and placed after the new 
string variable{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:strofnum} transforms a numeric variable into a string variable with
based on the value label if it exists. Otherwise the attached format is used{p_end}
{pstd}
The variable label is copied to the new variable.

{marker examples}{...}
{title:Examples}

{phang}{stata `"sysuse auto, clear"'}{p_end}
{phang}{stata `"strofnum foreign"'}{p_end}

{phang}{stata `"sysuse auto, clear"'}{p_end}
{phang}{stata `"format %tdCCYY-NN-DD rep78"'}{p_end}
{phang}{stata `"strofnum foreign rep78, keep"'}{p_end}

{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}
