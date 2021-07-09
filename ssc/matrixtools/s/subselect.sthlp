{smcl}
{* *! version 0.23}{...}
{viewerjumpto "Syntax" "subselect##syntax"}{...}
{viewerjumpto "Description" "subselect##description"}{...}
{viewerjumpto "Examples" "subselect##examples"}{...}
{viewerjumpto "Author" "subselect##author"}{...}
{title:Title}
{phang}
{bf:subselect} {hline 2} Mark all group ids that satisfy {help if} and {help in} 
conditions at least once

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:subselect}
varname
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gen:erate(name)}} Specify name of generated marker variable.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:subselect} generates a marker variable with name specified by option 
{opt gen:erate(name)}. The grouping variable is specified the varname argument.
The marker marks all group ids, where at least one row per group id satisfies 
the conditions in {help if} and {help in}.

{marker examples}{...}
{title:Examples}

{pstd}Example data:{p_end}
{phang}{stata `"use http://www.stata-press.com/data/r15/nlswork.dta, clear"'}{p_end}

{pstd}Mark all persons (idcode) that at some row in the dataset has been minor (age 18 or below):{p_end}
{phang}{stata `"subselect idcode if age <= 18, gen(age18)"'}{p_end}

{pstd}To see the generated variable for the first 2 person ids:{p_end}
{phang}{stata `"list idcode age age18 if idcode < 3, noobs sepby(idcode)"'}{p_end}
{pstd}Person with idcode 1 has age 18 at start and is marked whereas person
with idcode 2 do not age 18 at any time and hence is not marked.{p_end}

{pstd}Using {help sumat} to see unique number of persons at different ages:{p_end}
{phang}{stata `"sumat idcode, statistics(unique) rowby(age) decimals(0)"'}{p_end}

{pstd}To see unique number of persons who has been minor in the dataset at least once:{p_end}
{phang}{stata `"sumat idcode if age18, statistics(unique) rowby(age) decimals(0)"'}{p_end}
{pstd}By restricting the to persons who are minar at some age some of the 
higher ages are excluded.{p_end}

{pstd}To see unique number of persons who never has been minor in the dataset at different ages:{p_end}
{phang}{stata `"sumat idcode if !age18, statistics(unique) rowby(age) decimals(0)"'}{p_end}

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
