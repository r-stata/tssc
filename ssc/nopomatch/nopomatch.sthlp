{smcl}
{* *! version 1.1.0 24may2010}
{cmd:help nopomatch}
{hline}

{title:Title}
{phang}
{bf:nopomatch} {hline 2} Decomposition of Nopo (2008)

{title:Syntax}
{p 8 17 2}
{cmdab:nopomatch}
{it:matchvar}
[{it:matchvar(s)}]
[if]
{cmd:,}
outcome({it:varname})
by({it:varname})
[{it:options}]

{title:Parameters}
{synoptset 30 tabbed}{...}
{synopt:{it: matchvar(s):}} list of variables used to match observations of the groups defined by {it:by()}.{p_end}
{synopt:{it: outcome:}} outcome for which the gap will be computed. (e.g.: wage){p_end}
{synopt:{it: by:}} dummy (0/1) that discriminates the sample to perform the computation of the gap. (e.g.: gender).{p_end}
{p2colreset}{...}

{synoptset 30 tabbed}{...}

{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sd}} computes standard error. {p_end}
{synopt:{opt replace}} deletes the _match and _supp variables previously created (if any).{p_end}
{synopt:{opt reportby(varname)}} split the results for different groups of observations.{p_end}
{synopt:{opt fact(factor-variable)}} specifies the use of frequency weights.{p_end}
{synopt:{opt filename(file-name)}} saves output in STATA file.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}
{pstd}
{cmd:nopomatch} {hline 2} module to decompose the gap in an outcome between two groups using matching, following the methodology developed by Nopo (2008). {cmd:nopomatch} performs the matching, 
computes the gap decomposition and provides the standard error of the unexplained component of the gap.

{title:Options}
{dlgtab:Main}
{phang}
{cmdab:sd} computes standard error of the unexplained components of the gap. Note that the usage of this option substancially increases significantly
the computation time.

{phang}
{cmdab:replace} deletes the _match and _supp variables previously created (if any).

{phang}
{cmdab:reportby}{cmd:(}{it:varname}{cmd:)} repeats the command for each group of observations of each category of {it:varname}.

{phang}
{cmdab:fact}{cmd:(}{it:varname}{cmd:)} specifies the use of a weighting factor variable (frequency weight) in the data.

{phang}
{cmdab:filename}{cmd:(}{it:string}{cmd:)} creates an output STATA file ({it:string.dta}) with the results of the decomposition.

{title:Output}
{pstd}

A typical output of the {cmd:nopomatch} module looks like this:

****************************************************
*****  Gap in {it:matchvar(s)} decomposition 
****************************************************
{synoptset 10 tabbed}
{synopt: D = # }is the total gap, the difference between averages in the outcome-variable of the comparing groups. It is 
expressed as a percentage of the average of outcome-variable for the group in which by-variable=0{p_end}
{synopt: D0= # }is the unexplained part of the gap.{p_end}
{synopt: DM= # }is the part of the gap that can be explained by the differences in characteristics between 
two groups of the individuals with by-variable=1, that are in and out of the common support of the variables defined by {it:match-variable(s)}{p_end}
{synopt: DF= # }is the part of the gap that can be explained by the differences in characteristics between 
two groups of the individuals with by-variable=0, that are in and out of the common support of the variables defined by {it:match-variable(s)}{p_end}
{synopt: DX= # }is the part of the gap that can be explained by differences in the distribution of characteristics 
of the two groups discriminated by by-variable in the common support of the variables defined by {it:match-variable(s)}{p_end}
****************************************************
{synopt: percM= # }is the percentage of the individuals with {it:by-variable}=1 that are in the common support of the variables defined by {it:match-variable(s)}{p_end}
{synopt: percF= # }is the percentage of the individuals with {it:by-variable}=0 that are in the common support of the variables defined by {it:match-variable(s)}{p_end}
****************************************************
{p2colreset}

Note that D = DO + DM + DF + DX. For technical details see Nopo (2008). 

{title:Examples}
{pstd}

{phang}{cmd:. nopomatch age education, outcome(wage) by(male)}

{phang}{cmd:. nopomatch age education, outcome(wage) by(male) fact(freqweight) sd replace filename(example1)}

{phang}{cmd:. nopomatch age education occupation sector, outcome(wage) by(male) fact(freqweight) reportby(education)}

{phang}{cmd:. nopomatch age education occupation sector, outcome(wage) by(male) sd replace fact(freqweight) reportby(firmsize) filename(example2)}


{title:References}
{pstd}

Nopo, H. 2008. Matching as a Tool to Decompose Wage Gaps {it:Review of Economics and Statistics}, 90(2): 290-299.

{title:Acknowledgements}
{pstd}

This code was built from previous versions developed by Sebastian Calónico and Luana Marques.

{title:Disclaimer}
{pstd}

This program is provided without warranty of any kind. The authors are not responsible for any cost derived by the usage of this program.

{title:Authors}
{pstd}

Atal, Juan Pablo; Hoyos, Alejandro and Hugo Nopo. If you observe any problems {browse "mailto:hugon@iadb.org"} 

