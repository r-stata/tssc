{smcl}
{* *!version 1.1.0 20/03/2015}{...}
{cmd:help varmi}
{hline}

{title:Title}

{phang}
{bf:varmi} {hline 2} creates a dummy variable that takes 1 when all the variable in the varlist are missing
{p2colset 5 22 26 2}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:varmi} {varlist}, GENerate(varname) [LABel(namelist)]

{marker description}{...}
{title:Description}

{pstd}
The dummy variable takes the value 1 when all variables are missing 0 otherwise. Useful for analysis of attrition. You may also assign a label to the dummy variable using the label option. 


{marker examples}{...}
{title:Examples}

{phang} varmi outcome1 outcome2 outcome3 , gen(outcome_mi)




{title:Author}
{pstd}
Adrien Bouguen, Paris School of Economics, J-PAL Europe 
abouguen@povertyactionlab.org
 {p_end}

