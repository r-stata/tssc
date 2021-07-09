{smcl}
{* 9Oct2015}{...}
{hline}
help for {hi:rdecompose}
{hline}

{title:Title}

{p 2 4}
{cmd:rdecompose} implements the Gupta's rate decomposition method for aggregated data.

{title:Description}

{p 2 2}
The command reports the contribution of each specified variable to the aggregate value. The command keyword is {cmd:rdecompose}, and it should be immediately followed by the variable names of the factors contributing to the aggregate rates. The group indicator must also be included in the option {cmd:group}.

{title:Syntax}

{p 2 12}{cmd:rdecompose} {it:variables} [{cmd:if} {it:exp}]{cmd:,} 
{cmdab:group(}{it:variable}{cmd:)} [{cmdab:sum(}{it:variable}{cmd:)} 
detail reverse {cmdab:function(}{it:String}{cmd:)} {cmdab:transform(}{it:variable}{cmd:)} multi {cmdab:baseline(}{it:#}{cmd:)} ]


{title:Options}

{p 2 4}{cmd:variables} specifies the variables that contribute to the aggregated value.

{p 2 4}{cmd:group(}{it:variable}{cmd:)} specify the two populations (groups) that will be compared. The variable can be both in numeric format and string format.

{p 2 4}{cmd:sum(}{it:variable}{cmd:)} indicates that the population rate is an aggregated value summed over each distinct value of this variable or variables. (such as age or location)

{p 2 4}{cmd:function(}{it:string}{cmd:)} allows users to specify the function form as they wish. For instance, “ln(factor1+factor2)*exp(factor3)” can be used as a function. Most Stata supported functions can be used here. An error message will be display if the function form is invalid

{p 2 4}{cmd:detail} option will give a more detailed output when aggregation is required.

{p 2 4}{cmd:reverse} this option reserves the order of the population.

{p 2 4}{cmd:transform} This option converts the absolute numbers into proportions within the population.

{p 2 4}{cmd:multi}  this option indicates that there are more than 2 populations in the option “group”. Specifying this option will result in multiple comparisons against the baseline group.

{p 2 4}{cmd:baseline(}{it:#}{cmd:)} this option specify the baseline group value.

{title:Return Values}

{p 2 4}Scalar {cmd:e(N)} contains the number of observations used in the estimation

{p 2 4}Scalar {cmd:e(rate1)} contains the rate calculated for the first group

{p 2 4}Scalar {cmd:e(rate2)} contains the rate calculated for the second group

{p 2 4}Scalar {cmd:e(diff)} shows the total differences between two groups

{p 2 4}Macro {cmd:e(basegroup_value)} shows the baseline group value

{p 2 4}Matrix {cmd:e(b)} contains the total contributions for each factor

{title:Examples}

{p 2 8 2} {inp:rdecompose Marriage Contraception Abortion Lactation Fecundity , group(year)}

{p 2 8 2} {inp:rdecompose Size Rate , group( Parity ) transform( Size )}

{p 2 8 2} {inp:rdecompose age_structure CDM NCD Injuries , group(group) sum(age_group_i) func(age_structure*( CDM + NCD + Injuries ))}

{p 2 8 2} {inp:rdecompose prevalencerate population ageing exppercase healthpriceinflation, group(year) sum(disease_group agegroup)}

{title:Reference}

{p 4 8} Gupta, P. D. (1993). Standardization and decomposition of rates: A user's manual. US Department of Commerce, Economics and Statistics Administration, Bureau of the Census. 

{p 4 8} Li, J., & Kinfu, Y. (2015). rdecompose: Outcome decomposition for aggregate data. Paper presented at the Oceania Stata User Group Meeting, Canberra. 

{title:Contact}

{p 4 4} Jinjing Li, University of Canberra, Australia{break}
{browse "mailto:jinjing.li@canberra.edu.au"}
 
