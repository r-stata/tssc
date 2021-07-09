{smcl}
{* 1aug2005/10apr2006/15feb2007}{...}
{hline}
help for {hi:mbsens}
{hline}

{title:Help for  mbsens - Obtain the Rosenbaum bounds for using the results of matching}

{p 8 14}{cmd:mbsens} {it:treated} {it:strata} {it:outcomevar} {it:gamma_min} {it:gamma_increment} {it:gamma_max}

{title:Description}
{p}{cmd:mbsens} is used for calculating the binary sensitivity metric (gamma) using McNemar's statistic using the results of matching as the input. (Ref: Rosenbaum, Paul R(2002) Observational studies. Springer-Verlag). The input parameters are the counts of discordant pairs (wherein the control and treated observations vary with respect to the output). Note that discordant_count1 is always less than discordant_count2 and gamma_increment is a number like 0.01 (or 1 or 2) at which you would want gamma_min to be incremented to reach gamma_max.

 {title:Acknowledgements}
{p}This program is named mbsens and is written by Hemang C Subramanian and Eric Overby at the Georgia Institute of Technology.

{title:Limitations}
{p} This version of the program works well with k2k based matching only.
 
{title:Options}
{p 0 4}{cmd:treated} This is the name of the variable in the matched sample which indicates treatment. This variable takes a value of 0 or 1 ONLY.

{p 0 4}{cmd:strata} This is the name of the variable in the matched sample which indicates the count of strata, or identifier for each matched pair.

{p 0 4}{cmd:outcomevar} This is the name of the variable in the matched sample which indicates the outcome of the regression. This variable takes a value of 0 or 1 ONLY.

{p 0 4}{cmd:gamma_min} This is the start of Gamma's range.

{p 0 4}{cmd:gamma_increment} This is the increment at which Gamma would be modified.

{p 0 4}{cmd:gamma_max} This is the maximum value of Gamma.

{title:Examples}
{p 8 12}{it:mbsens treated cemresultmstrata  outputvar 1 1 6}

{title:Output}
Gamma Lower-Bound Upper-Bound
1        .0024      .0024
2        0      .963
3        0      1
4        0      1
5        0      1
6        0      1


{title:Author}
Hemang C Subramanian
hemang.subramanian@scheller.gatech.edu
Eric Overby 
eric.overby@scheller.gatech.edu
