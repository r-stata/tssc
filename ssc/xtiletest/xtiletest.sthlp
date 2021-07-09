{smcl}
{* 21dec2015}{...}
{hline}
help for {hi:xtiletest}
{hline}

{title:Test equality of percentiles across groups of observations}

{p 8 14}{cmd:xtiletest}{it: varname} [{cmd:if} {it:exp}] [{cmd:in} {it:range}], 
{cmd:by(}{it:string}) {cmdab:xt:ile(}{it:numlist}) 

{title:Description}

{p}{cmd:xtiletest} computes specified percentiles of a variable, and tests them for equality 
across groups of observations. The test is based on Johnson et al. (2015), in which it is shown 
that the hypothesis of equality of percentiles across groups 
can be expressed as a standard Chi-squared goodness of fit test, as produced by Stata's 
{cmd:tabulate} command. Under the null that {it:m} specified percentiles are equal over {it:n} 
groups, the test statistic is distributed Chi-square with {it:(m-1)(n-1)} degrees of freedom.

{title:Options}

{p 0 4}{cmd:by}({it:string}) is a required option. It provides the name of the variable 
defining groups within {it:varname}. If multiple variables are to be considered as group 
identifiers, {cmd: egen group)} may be used to construct a single by-variable.

{p 0 4}{cmdab:xt:ile}({it:numlist}) is a required option. It must contain a number of 
integer values of percentiles to be computed for {\it:varname} and for each group within {it:varname}.
As in the {cmd:_pctile} command, these values must be in ascending order.

{title:Examples}

{p 8 12}{inp:.} {stata "webuse nlsw88 ":webuse nlsw88}

{p 8 12}{inp:.} {stata "xtiletest wage, by(union) xtile(25 50 75)":xtiletest wage, by(union) xtile(25 50 75)}

{p 8 12}{inp:.} {stata "xtiletest wage, by(union) xtile(20 40 60 80)":xtiletest wage, by(union) xtile(20 40 60 80)}

{p 8 12}{inp:.} {stata "xtiletest hours, by(married) xtile(25 50 75)":xtiletest hours, by(married) xtile(25 50 75)}

{p 8 12}{inp:.} {stata "xtiletest tenure if occupation<=3, by(occupation) xtile(25 50 75)":xtiletest tenure if occupation<=3, by(occupation) xtile(25 50 75)}

 
{title:Reference}

WD Johnson et al., Use of Pearson’s Chi-Square for Testing Equality of Percentile Profiles across Multiple Populations, Open Journal of Statistics, 2015, 5:412-420. DOI 10.4236/ojs.2015.55043 

{title:Author}

{p 0 4}Christopher F Baum, Boston College, USA{p_end}
{p 0 4}baum@bc.edu{p_end}


