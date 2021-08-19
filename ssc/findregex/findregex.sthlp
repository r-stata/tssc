{smcl}
{* *! version 1.0  07may2021}{...}
{title:findregex}

{phang}
{bf:findregex} {hline 2} Find variable names matching a regular expression pattern


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:findregex}
[{varlist}] , {cmd:re(}["]{it:pattern}["]{cmd:)} 
[{cmd:}{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Selection}
{synopt:{opt re(["]pattern["])}}regular expression pattern{p_end}

{syntab :Control}
{synopt:{opt se:nsitive}}performs case-sensitive pattern matching{p_end}
{synoptline}
{p2colreset}{...}

{phang}
{it:pattern} is a string containing a valid regular expression pattern and should be enclosed in quotes (see {helpb ustrregexm()}).


{marker description}{...}
{title:Description}

{pstd}
{cmd:findregex} lists variable names that match a regular expression based on the variables in the current frame. The variable names are listed back to the user. In addition, the matching list of variables is left behind in {opth s(varlist)}.

{pstd}
The default is to use all variable names in the current dataset. If {it:varlist} is provided, then the matching takes place on this subset.


{marker options}{...}
{title:Options}

{dlgtab:Selection}

{phang}
{opt re(["]pattern["])} a string containing the regular expression pattern and should be quoted.

{dlgtab:Control}

{phang}
{opt se:nsitive} performs case-sensitive pattern matching. The default is to perform case-insensitive pattern matching.


{marker examples}{...}
{title:Examples}

{pstd}
Search all variables, ignoring case, beginning with the letter "m".{p_end}
{phang2}{cmd:. findregex, re("^m")}{p_end}

{pstd}
Search all variables, respecting case, which contain either an "m" or "b" followed by one or two digits in the range of 1 to 4.{p_end}
{phang2}{cmd:. findregex, re("[bw][1-4]{1,2}") sensitive}{p_end}

{pstd}
Search all variables, ignoring case, which contains an American or British spelling of centre.{p_end}
{phang2}{cmd:. findregex, re("cent(re|er)")}{p_end}


{marker author}{...}
{title:Author}

{p 4 4 2}Leonardo Guizzetti{break}
London, Ontario{break}
leonardo.guizzetti@gmail.com{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
The idea to use regular expressions was inspired by a post on the Stata Forum. The creation of this command was encouraged by Nicholas J. Cox.
{p_end}


{marker "also see"}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 20, number 2: {browse "https://doi.org/10.1177/1536867X20931029":dm0048_4}

{p 5 14 2}
Manual:  {bf:{manlink D ds}}

{p 7 14 2}
Help:  {bf:{manhelp ds D}}, {helpb findname}
{p_end}
