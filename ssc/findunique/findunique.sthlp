{smcl}
{* *! v13.0 5May2015 RM}
{viewerjumpto "Syntax" "findunique##syntax"}{...}
{viewerjumpto "Description" "findunique##description"}{...}
{viewerjumpto "Remarks" "findunique##remarks"}{...}
{viewerjumpto "Example" "findunique##example"}{...}
{viewerjumpto "Author" "findunique##author"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:findunique} {hline 2}}Unique Identifiers Finder{p_end}
{p2colreset}{...}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:findunique}
{varlist} {ifin}
[{cmd:,} {it:options}]


{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt sort:ing}}Sorts data according to the most concise rule (i.e. according to the most parsimonious unique identifier set of variables){p_end}
{synopt :{opt first}}Displays only the most parsimonious unique identifier set of variables{p_end}
{synopt :{opt ssc}}Installs the two components needed to run {opt findunique} (see {help findunique##remarks:remarks below}){p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt findunique} displays combinations of unique identifiers in a dataset.

{pstd}
This command allows the user to find a rule according to which each
single observation in a dataset is uniquely identifiable.
{opt findunique} displays all the possible sets of variables among those specified in {it:varlist} whose
combined values uniquely identify observations and shows them in order from
the most parsimonious to the set with the largest number of variables.{p_end}

{marker remarks}{...}
{title:Remarks}
{pstd}{opt findunique} requires two components: {opt tuples} (authors: Joseph N. Luchman and Nicholas J. Cox) and {opt unique} (authors: Michael Hills and Tony Brady). Find below useful links on the two components.{p_end}
{phang2}. {stata findit tuples}{p_end}
{phang2}. {stata findit unique}{p_end}
{phang2}. {stata ssc install tuples}{p_end}
{phang2}. {stata ssc install unique}{p_end}


{marker example}{...}
{title:Example}

{pstd}Load 1998 data on cross-country life expectancy.{p_end}
{phang2}. {stata sysuse lifeexp}{p_end}

{pstd}What are the set of variables that uniquely identify observations?{p_end}
{phang2}. {stata findunique lexp}{p_end}
{phang2}. {stata findunique lexp popgrowth}{p_end}
{phang2}. {stata findunique lexp popgrowth country}{p_end}
{phang2}. {stata findunique *}{p_end}
{phang2}. {stata findunique *, first}{p_end}

{pstd}Clearly, since this dataset is a cross-country snapshot at a fixed point in time, the most parsimonious set of unique identifiers includes only one variable: {it:country}. We can now sort data according to our preferred unique identifier. {p_end}

{phang2}. {stata findunique *, sort first}{p_end}

{marker author}{...}
{title:Author}

{pstd}Riccardo Marchingiglio{p_end}{...}
{pstd}riccardo.marchingiglio@kellogg.northwestern.edu{p_end}
