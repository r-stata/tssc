{smcl}
{* *! version 1.3  16Nov2015 James J Feigenbaum}{...}
{cmd:help jarowinkler}
{hline}

{title:Title}

{phang}
{cmd:jarowinkler} {hline 2} Calculate the Jaro-Winkler distance between two string variables.


{title:Syntax}

{p 8 17 2}
{cmd:jarowinkler}
{varname:1}
{varname:2}
[{cmd:,} {opth gen:erate(newvar)} {opth jaro:only(newvar)} {opth p:winkler(x)} ]


{title:Description}

{pstd}
{cmd:jarowinkler} calculates the distance between two string variables using the Jaro-Winkler distance metric. The distance metric is often used in record linkage to compare first or last names in different sources. 
Jaro-Winkler modifies the standard Jaro distance metric by putting extra weight on string differences at the start of the strings to be compared. The metric is scaled between 0 (not similar at all) and 1 (exact match). 

{pstd}
{cmd:jarowinkler} accepts two arguments, both of which must be string variables. Cases are standardized within the algorithm. 

{pstd}
The distance is returned as a new variable with default name {bf:jarowinkler}.

{pstd}
For more detail on the Jaro-Winkler method, see http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance and http://www.gabormelli.com/RKB/Jaro-Winkler_Distance_Function. 
Jaro-Winkler implementation based on code from http://cs.anu.edu.au/~Peter.Christen/Febrl/febrl-0.4.01/stringcmp.py and https://github.com/miguelvps/c/blob/master/jarowinkler.c.

{title:Options}

{phang}
{opth generate(newvar)} Create a new variable named {it:newvar} containing the Jaro-Winkler distance. If the {opt generate()} option is not used, a new variable will be created with default name {bf:jarowinkler}. {p_end}

{phang}
{opth jaroonly(newvar)} Create a new variable named {it:newvar} containing the Jaro distance. If the {opt jaroonly()} option is not used, nothing will be created. {p_end}

{phang}
{opth pwinkler(x)} A constant scaling factor for how much the score is adjusted upwards for having common prefixes. p should not exceed 0.25, otherwise the distance can become larger than 1. The default value is Winkler's standard value of 0.1.

{title:Examples}

{phang}{cmd:. sysuse census, clear} {p_end}
{phang}{cmd:. jarowinkler state state2 , gen(dist_jw)} {p_end}

{phang}{cmd:. sysuse census, clear} {p_end}
{phang}{cmd:. jarowinkler state state2 , gen(dist_jw) jaroonly(dist_jaro)} {p_end}
{phang}{cmd:. jarowinkler state state2 , gen(dist_jw2) pwinkler(0.2)} {p_end}

{title:Saved results}

{pstd}
{cmd:jarowinkler} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(jarowinkler)}}name of new Jaro Winkler string difference variable if created{p_end}
{synopt:{cmd:r(jaroonly)}}name of new Jaro string difference variable if created {p_end}

{p2colreset}{...}

{title:Acknowledgements}

{pstd} My thanks to a number of people for suggestions and bug-catching. Thanks to Adrian Sayers for suggesting the inclusion of Jaro distances and allowing the Jaro-Winkler scaling factor to vary. Thanks to Martin Goossen for alerting me to an error in the Stata 12 version of the code. Thanks to Alex Fouirnaies and Bruno Caprettini for alerting me to an issue in the calculation of distance for strings with no common characters. Thanks to Jacob Bor for alerting me to an issue when comparing single character strings. 

{title:Author}

{pstd} James Feigenbaum {p_end}
{pstd} Harvard University {p_end}
{pstd} jfeigenb@fas.harvard.edu {p_end}
{pstd} http://scholar.harvard.edu/jfeigenbaum {p_end}

{title:Also see}

{pstd}
{help strdist:strdist},
{help soundex:soundex}
