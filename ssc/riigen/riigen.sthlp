{smcl}
{* 21nov2013}{...}
{break}
{title:Title} 
{break}
{p 4 4 2} {help RIIGEN} - Stata module to generate Variables to Compute the Relative Index of Inequality {p_end}
{break}
{p 4 4 2} {p_end}
{title:Syntax} 
{break}
{p 4 4 2}{cmd:riigen} {help varlist} [{help if}] [{help in}] [{help weight}]
[ , {cmd: varprefix}({it:string}) {cmd:riiname}({it:string}) {cmd:replace}]{p_end}


{title:Description}

{p 4 4 2}
The relative index of inequality (RII) is a regression-based index of inequality regarding one outcome by levels of a determinant. Usually,
it summarizes the magnitude inequalities in health between socio-economic status (SES) groups. RII is useful because it takes into account 
the size of the population and the relative diadvantage experienced by different groups. The outcome is regressed on the proportion of the 
population that has a lower (or, alternatively, a higher) position in the hierarchy. It is particularly valuable when comparing effects of 
risk factors (independent variables) have different scales and/or group sizes. When using aggregated data and a linear regression model on
 Prevalences as Outcome, the RII-Variable can be used to calculate the absolute Slope Index of Inequality (SII, see example 3 below)

{p 4 4 2} 
{cmd:Calculation:}

{p 8 16 2} {cmd:1.} Rank cases on the determinant (by subgroup)

{p 8 16 2} {cmd:2.} For tied ranks and for categorical variables, assign the mean rank for all values

{p 8 16 2} {cmd:3.} Divide the (weighted) cumulative number of cases with rank or lower with the sample size (or if weighted, the population size), creating a value ranging from 0 to 1

{p 8 16 2} {cmd:4.} If contrast to high vs. low ({cmd:riiorder}({it:higher})) and not low vs. high ({cmd:riiorder}({it:lower})) is desired, reverse order by creating new value (= 1 - value).

{p 4 4 2}
{cmd:riigen} calculates new variables for a list of variables that allow to estimate the relative 
index of inequality in regression models. It is possible to calculate the RII for a subsample using 
{help if} and {help in}. The rii-Generator can also be used with {help by}. Weighting is permitted. Note: The extremes of the RII-Variable (0/1) are archived, if there is just one case in the lowest/highest category of the determinant.
 
{title:Options}

{p 4 16 2}{cmd: varprefix}()
Choose a new prefix for the generated variables. Default is {cmd: varprefix}("RII_"}).

{p 4 16 2}{cmd:riiname}()
Choose a new String that should be attached as suffix to the {help variable label} of the original 
variable as label for the generated variable. Default is {cmd:riiname}("(RII)").

{p 4 16 2}{cmd:riiorder}()
Change the sortorder of the generated RII. {cmd:riiorder}(higher) compares in refererence to the proportion in 
higher positions, {cmd:riiorder}(lower) (default setting), compares in refererence to the proportion in lower positions.

{p 4 16 2}{cmd:replace} Allow riigen to replace variables of name {it:RII_oldvar} if they already exist.

{title:Examples}

{p 2 8 2}1) Default usage{p_end}

{p 4 8 2}{inp:. sysuse auto  , clear}{p_end}

{p 4 8 2}{inp:. riigen length} {p_end}

{p 4 8 2}{inp:. poisson rep RII_length , nolog irr}  {p_end}

{p 2 8 2}2) Create RII for Subgroups{p_end}

{p 4 8 2}{inp:. webuse nhanes2.dta , clear}{p_end}
  
{p 4 8 2}{inp:. by race , sort: riigen agegrp [iw=finalwgt] , replace}{p_end}

{p 4 8 2}{inp:. svy: logit diabetes c.RII_agegrp##i.race , or nolog} {p_end}

{p 2 8 2}3) Use RII to generate the SII (Slope Index of Inequality){p_end}

{p 4 8 2}{inp:. webuse nhanes2.dta , clear} {p_end}

{p 4 8 2}{inp:. gen popsize = 1} {p_end}

{p 4 8 2}{inp:. collapse (mean) diabetes (sum) popsize [fw=round(finalwgt)] , by( sex agegrp)} {p_end}

{p 4 8 2}{inp:. gen popsize = 1} {p_end}

{p 4 8 2}{inp:. riigen agegrp [fw= popsize ] , varprefix(SII) riiname((SII))} {p_end}

{p 4 8 2}{inp:. reg diabetes i.sex c.SII} {p_end}

{title:References}

{p 8 16 2} Mackenbach JP, Kunst AE (1997) Measuring the magnitude of socio-economic inequalities in health: An overview of available measures illustrated with two examples from Europe. Social Science and Medicine 44 (6): 757-771

{p 8 16 2} Mackenbach JP, Stirbu I, Roskam A-JR et al. (2008) Socioeconomic Inequalities in Health in 22 European Countries. The New England Journal of Medicine 358 (23): 2468-2481

{title:Author}

{p 4 4 2}Dr. Lars E. Kroll, {browse "mailto:mail@lkroll.de": email} 

{title:Citation}

{p 4 4 2}{it: If you are using {help riigen} for a publication, please cite Mackenbach, Kunst (1997) and this ADO:}

{p 4 8 2} Kroll, LE (2013)  RIIGEN: Stata module to generate Variables to Compute the Relative Index of Inequality. Boston College Department of Economics, revised 21 Nov 2013.


{title:Also see}

{p 4 13 2}On-line:  help for {help by}, {help svyset}{p_end}
