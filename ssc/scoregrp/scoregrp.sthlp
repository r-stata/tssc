{smcl}
{* *!1 version 1.0.4 22apr2013}{...}
{cmd:help scoregrp}{...}
{hline}

{title: Title }

{p 4 8 2}
{bf:scoregrp -- a score test for equality of parameters across groups of observations}

{title:Syntax}

{p 8 15 2}
{cmdab:scoregrp:} 
[{indepvars}] 
{cmd:,} 
{bind:{cmdab:group:(}{varname}{cmd:)} [{it:options}]}

{title:Description}

{p 4 4 2}
{cmd:scoregrp} performs a score test for the equality of (a) parameter(s) across groups of observations.
It is a postestimation command and works after {cmd:poisson}, {cmd:logit}, {cmd:logistic}, {cmd:probit} and {cmd:regress}. 

{title:Options}

{p 4 8 2}{cmd:nocons} do not include the constant among the coefficients to test

{title:Examples}

Example1: Test for fixed effects after Poisson regression

{p 4 8 2}{cmd:. poisson y x1 x2}

{p 4 8 2}{cmd:. scoregrp , group(id)}

Example2: Test for difference in slopes across groups of observations

{p 4 8 2}{cmd:. regress y x1 x2}

{p 4 8 2}{cmd:. scoregrp x1, group(id) nocons}

Example3: Pearson Chi-square for binary data

{p 4 8 2}{cmd:. logit y}

{p 4 8 2}{cmd:. scoregrp , group(id)}

Example4: Test for difference in structure across groups

{p 4 8 2}{cmd:. probit y x1 x2}

{p 4 8 2}{cmd:. scoregrp x1 x2, group(id)}

{title:Acknowledgment}
This program makes use of the user written command {help matdelrc} written by Nicholas J. Cox.

{title:Reference}

If you use this program in your research cite:

Paulo Guimaraes. "A Score Test for Group Comparisons in Single-Index models", Stata Journal, forthcoming.

{title:Author}

Paulo Guimaraes, Universidade do Porto.

Email {browse "mailto:pguimaraes@fep.up.pt":pguimaraes@fep.up.pt} if you have any problems or questions.

