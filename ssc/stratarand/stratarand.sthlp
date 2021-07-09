{smcl}
{* 28oct2014}{...}
{cmd:help stratarand}{right:Version 0.2.0}
{hline}

{title:Title}

{pstd}
{hi:stratarand} {hline 2} This function performs stratified random assignment for equal and unequally sized treatment groups.  
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:stratarand} {cmd:, }
{opt gentreat:(treatvar)}
{opt strata:(strata)}
[{opt conditionsnumber:(num)}
{opt replace}
{opt group_percentages(num)}
{opt exact}]

{marker desc}{title:Description}

{pstd} {cmd:stratarand} -- This function randomly assigns observations to experimental groups for each stratum. Within each stratum, this function 
first randomly selects which experimental group to start the random assignment. Then, if the treatment groups are equally-sized, the random assignment
alternates through all possible treatment groups. If the treatments groups are not equally sized, the function assigns blocks of observations to a 
given treatment condition based on the percentage of observations. 

{pstd} {it}NOTE: This function will re-sort your dataset. Please set seed and set sortseed before this 
function is run to ensure replicability.{sf}

{marker opt}{title:Options}

{pstd} {opt gentreat:(treatvar)} what the resulting treatment variable should be called{p_end} 
{pstd} {opt replace} if a variable with the same name as {it:treatvar} already exists, it should be dropped and replaced with {it:treatvar} {p_end} 
{pstd} {opt strata:(strata)} name of the strata variable {p_end} 
{pstd} {opt conditionsnumber:(num)} number of conditions of equally sized treatment groups; either this option or {opt group_percentages(num)} must be specified {p_end} 
{pstd} {opt group_percentages(num)} the percentage of observations assigned to each treatment condition (e.g., .1 .4 .5); either this option or {opt conditionsnumber(num)} must be specified  {p_end} 
{pstd} {opt exact} this option is only relevant when {opt group_percentages(num)} is specified. Since percentages of observations may result in a rounding error, {opt exact} specifies that observations that  
did not receive a treatment assignment due to rounding error are randomly assigned to one of the remaining treatment conditions. This option is only useful when there is a large number of strata. {p_end} 


{marker ex}{title:Examples}

{pstd} {inp:. stratarand, gentreat(condition) strata(congressionaldistrict) group_percentages(.2 .3 .5)}{p_end}
{pstd} {inp:. stratarand, gentreat(condition) strata(congressionaldistrict) group_percentages(.2 .3 .5) exact replace}{p_end}
{pstd} {inp:. stratarand, gentreat(condition) strata(congressionaldistrict) conditionsnumber(3)}{p_end}


{title:Author}

{pstd}John Ternovski{p_end}
{pstd} S3 Lab{p_end}
{pstd} Harvard University{p_end}
{pstd} {browse "mailto:john_ternovski@hks.harvard.edu":john_ternovski@hks.harvard.edu}{p_end}
