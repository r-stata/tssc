{smcl}
{* *! brmunid v11.3 A.Bigoni 8jul2019}{...}
{cmd: help brmunid}
{hline}

{title:Title}
{p2colset 5 18 20 2}
{p2col:{hi:brmunid} {hline 2}}Standardizes geocodes for Brazilian municipalities
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:brmunid }{varname} [{cmd:,}{cmd:sixtoseven}]

{title: Description}

{pstd}{cmd:brmunid} standardizes geocodes for Brazilian municipalities. Before
2006 the Brazilian government used to assign a geocode with an additional digit
for error detection. In 2006 the system was abandoned and geocodes have only 6 
digits ever since. When applied, the program creates a new variable with
standardizes geocodes with only six digits. When the option sixtoseven is
selected the program performs the opposite procedure and adds the extra digit.

{title:Author}

{phang} Alessandro Bigoni, USP - School of Public Health, Department of Epidemiology{break}
alebigoni@usp.br{p_end} 
