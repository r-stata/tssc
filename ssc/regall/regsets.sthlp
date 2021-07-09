{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:regsets} {hline 2} Generates complete sets of variables for regression analysis 


{marker syntax}{...}
{title:Syntax}

{phang}
{bf:regsets :} [{varlist}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:regsets} uses combinatory calculus to calculate the number of combinations without repetitions of the set of variables 
listed in {varlist}. For example, a set of 3 variables A, B and C
can generate 3 combinations of 1 variable (A,B,C), 3 combinations of 2 variables 
(AB,BC,AC) and 1 combination of 3 variables(ABC) for a total of 7 combinations. The formula
used to calculate the number of possible combinations is 2^(n+1)-1 where n is the number of variables. 
This is a shortcut to quickly visualize all possible sets of regressors that can be used from an initial set of variables.    


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:regsets} is an input to {cmd:regall}. 
Use '&' to combine variables and tell the program to treat these variables as one. 

{marker author}{...}
{title:Author}

{pstd}
Paolo Verme, World Bank, pverme@worldbank.org

{marker aknowledgments}{...}
{title:Aknowledgments}

{pstd}
The author is grateful to Aziz Atamanov, Olivier Dupriez and Philippe Van Kerm for useful suggestions.

{marker examples}{...}
{title:Examples}

{phang}{cmd: sysuse auto, clear}{p_end}
{phang}{cmd: regsets: headroom price trunk}{p_end}
{phang}{cmd: regsets: headroom weight length&turn}{p_end}
