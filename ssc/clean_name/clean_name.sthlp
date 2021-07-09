{smcl}
{* *!version 1.2.0 5/13/2020}{...}
{cmd:help clean_name}
{hline}

{title:Title}



{title:Syntax}
{p 8 17 3}
{cmdab:clean_name}
 {varlist}  
{cmd:,} {it:options}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth case(upper|proper|lower)}} specify whether the variable should be returned with proper or upper case. By default, lower case variable is returned. {p_end} 
{synoptline}


{phang}
{bf:clean_name} {hline 2} Cleans string variables by removing all uncommun characters. 
{p2colset 5 22 26 2}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:clean_name} {varlist}
{cmd:,} {it:options}

{marker description}{...}
{title:Description}

{pstd}
{opt clean_name} removes blanks, accents, full stops, hyphens, apostrophes and all uncommon characters (eszet, tilde, cedille, space and invisible characters...) from string variables. By default, clean_names returns a cleaned lower case variable. Upper and proper case can be specified in option. clean_name is particularly useful to clean non consistent identifiers (such as first and last name, school name, region name... ), merge using string variables or identify duplicate values.

{marker examples}{...}
{title:Examples}

{phang} clean_name first_name first_name2, case(proper)




{title:Author}
{pstd}
Adrien Bouguen, Santa Clara University
 {p_end}

