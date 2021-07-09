{smcl}
{* 6/8/2017}{...}
{hi:help mcib}
Version 5.1, June 14, 2019.
{hline}

{title:Title}

{pstd}{hi:mcib} {hline 2} Mean-constrained Integration over Brackets (MCIB) estimator for grouped income data. 
This program implements the method described in Jargowsky and Wheeler (2018), "Estimating Income Statistics From Grouped Data: 
Mean-Constrained Integration over Brackets."

{title:Syntax}
{p 8 16 2} {cmd:mcib} {count} {lower} {upper} {if}, Mean(mean)|TWOPoint [{it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt by:(idvar)}} Specifies id variable for units, e.g. metropolitan areas. 
{p_end}
{synopt :{opt uni:form(none|first|belowmed)}} Brackets in which to require uniform distribution. 
Allowable values are none, first (the default), belowmed (all brackets below median).
{p_end}
{synopt :{opt pare:to(top|toptwo|abovemed)}} Brackets in which to use Pareto distribution. 
Allowable values are top (the default), toptwo, or abovemed (all brackets above the meidan).
{p_end}
{synopt :{opt part:s(#)}} Number of parts to divide brackets for calculating Gini. 
Default is 5.
{p_end}
{synopt :{opt mina:lpha(#)}} Minimum value for alpha; default is 2. 
{p_end}

{synopt :{opt s:aving(filename)}} Save results to specified file. 
{p_end}
{synopt :{opt replace: }} Replace results dataset on disk if it already exists. 
{p_end}
{synopt :{opt l:ist}} Lists results on screen. Default if saving or keep is not specified.
{p_end}
{synopt :{opt keep: }} Discard original data (destructive) and keep results in memory.   
    {p_end} 
     
{title:Description}

{pstd} {cmd:mcib} implements the mean-constrained integration over brackets (MCIB) estimator 
described in Jargowsky and Wheeler (2018) to estimate the standard deviation and other 
parameters of an income distribution from summarized data in brackets or bins. Prior research 
typically used midpoints of the brackets and pareto extrapolation in the open-ended top bracket 
(Henson 1967; Cloutier 1988). Von Hippel et al. (2016) presented two improved methods: the Robust 
Pareto Midpoint Estimator (RPME) and the multimodel generalized beta estimator (MGBE). 
This method, MCIB, estimates integrals of the desired statistics over the income brackets. 
By default, the density of the lowest bracket is assumed to be uniform, 
the intermediate brackets are assumed to have a sloping linear desisty function, 
and the open-ended top bracket is assumed to follow a Pareto distribution.
Testing with PUMS data showed MCIB with the mean() option to be more accurate 
than all previous methods (see Jargowsky and Wheeler 2018). 

{pstd} The following 
statistics are estimated: variance, standard deviation, various percentiles, the coefficient of 
variation (cov), Gini, Theil, the ratio of P90/P10, the interquartile range, and the shares of 
income going to each income quintile. If the twopoint option is specified, the mean is also estimated,
at the expense of some accuracy on other statistics. Results are displayed, saved to a file, 
or kept in memory, replacing the original data, depending on the options specified. 

{pstd} {cmd:mcib} assumes that the data are "grouped" (a.k.a. binned, bracketed, interval-censored) 
 so that each row reports how many individuals or households have values in the interval (lower,upper).
 Grouped data are commonly used to summarize distributions of income or wealth 
 across individuals, families, and households.  
 
{title:Data Preparation}
 
{pstd}The data must be in one row per income bracket (aka bin) with a count variable
specifying the number of households (persons, etc.) in each bracket.   
The values representing the lower and upper bounds of the income brackets must also be 
specified. 
The mean income for the area should be specified if available in the mean() option;
doing so will greatly improve the accuracy of the estimates. If the mean is not available, 
specify the twopoint option (Cloutier 1988).
When there are multiple 
areas (e.g. metropolitan areas, states, nations), there must be an id variable as well, 
include it in the by() option.  

{pstd}Reshape can be used to put data in the proper format. For example, the data pumstest.dta has
one row per metropolitan area, and the counts of households by income brackets are in a series
of variables hhs1-hhs16.  The data in pumstest.dta look like this:

   metaread   meanhhy   tothhs    hhs1    hhs2  ...  hhs15   hhs16  
{result}Abilene, TX    55,815    49439    4359    3097  ...   1052    1238  
  Akron, OH    62,347   283246   25801   16915  ...   9899    8347  
     etc.
{text}
 {pstd} The following steps will reshape the data into metro/bin format and
 attach the minimum and maximum bin values:
 
{input} * First, create a temporary file with the bin amounts that will be used
tempfile amounts
input bin min max 
1 0 10000
2 10000 15000
3 15000 20000
4 20000 25000
5 25000 30000
6 30000 35000
7 35000 40000
8 40000 45000
9 45000 50000
10 50000 60000
11 60000 75000
12 75000 100000
13 100000 125000
14 125000 150000
15 150000 200000
16 200000 .
end
save `amounts'

* Now, load the test data 
use pumstest 

* Reshape the data to be in metro/bin observations
reshape long hhs, i(metaread) j(bin)
merge m:1 bin using `amounts'
assert _merge==3
drop _merge
{text} 
{pstd} The data are now in the correct format for use with {cmd:mcib}:

{input}list in 1/35,  noobs sepby(metaread)
{result}
  +----------------------------------------------------------------+
  |    metaread   bin   meanhhy   tothhs     hhs      min      max |
  |----------------------------------------------------------------|
  | Abilene, TX     1    55,815    49439    4359        0    10000 |
  | Abilene, TX     2    55,815    49439    3097    10000    15000 |
  |     ...(brackets 3-14 omitted)                                 |
  | Abilene, TX    15    55,815    49439    1052   150000   200000 |
  | Abilene, TX    16    55,815    49439    1238   200000        . |
  |----------------------------------------------------------------|
  |   Akron, OH     1    62,347   283246   25801        0    10000 |
  |   Akron, OH     2    62,347   283246   16915    10000    15000 |
  |     ...(brackets 3-14 omitted)                                 |
  |   Akron, OH    15    62,347   283246    9899   150000   200000 |
  |   Akron, OH    16    62,347   283246    8347   200000        . |
  |----------------------------------------------------------------|
  |  Albany, GA     1    50,871    45536    5967        0    10000 |
  |  Albany, GA     2    50,871    45536    3877    10000    15000 |
  |    ...etc.                                                     |
{text}	
{title:Examples}

{pstd}Basic use using defaults, saving results to results.dta

{p 8 16 2} {cmd:mcib hhs min max, mean(meanhhy) by(metaread) saving(results)}

{pstd}Use Pareto distribution in all brackets above median, keeping results in memory

{p 8 16 2} {cmd:mcib hhs min max, mean(meanhhy) by(metaread) pareto(abovemed) keep}

{pstd}Compute values for Los Angeles/Long Beach Metro only (4480), display results on screen.

{p 8 16 2} {cmd:mcib hhs min max if metaread==4480, mean(meanhhy) list}

{pstd}The last command produces the following output:

{text}Basic Descriptives
{result}
    ID           N     mean        var       sd  
     1   3,218,501   76,373   7.29e+09   85,354  
{text}
Important Percentiles
{result}
    ID      p5      p25      p50      p75       p95  
     1   7,144   26,052   53,451   96,505   213,380  
{text}
Deciles
{result}
    ID      p10      p20      p30      p40      p60      p70       p80       p90  
     1   12,584   21,395   31,162   41,524   67,415   85,075   110,274   155,904  
{text}
Inequality Measures
{result}
    ID     cov    gini   theil   rat9010        iqr  
     1   1.118   0.486   0.405    12.389   70453.38  
{text}
Income shares by quintiles
{result}
    ID   shrq1   shrq2    shrq3    shrq4    shrq5  
     1   3.123   8.172   14.083   22.606   52.016  
{text}

{pstd} If the mean of the data is not available, specify the twopoint option:

{p 8 16 2} {cmd: mcib hhs min max, twopoint by(metaread) }

{text}
{title:Estimation Details}

{pstd}See Jargowsky and Wheeler (2018), available at 
{browse "https://journals.sagepub.com/doi/full/10.1177/0081175018782579"}.

{title:Author}

{pstd}Paul A. Jargowsky, Rutgers University - Camden, paul.jargowsky@rutgers.edu

{title:References}

{p 4 8 2} Cloutier, Norman R. 1988. 
“Pareto Extrapolation Using Grouped Income Data.” 
Journal of Regional Science 28:415–19.

{p 4 8 2} Henson, Mary F. 1967. 
Trends in the Income of Families and Persons in the United States, 1947-1964. 
U. S. Dept. of Commerce, Bureau of the Census.

{p 4 8 2} von Hippel, P. T., Scarpino, S. V., & Holas, I. (2016). 
Robust estimation of inequality from binned incomes. 
Sociological Methodology, 46(1), 212-251. 
[also available as an arXiv working paper, 
{browse "http://arxiv.org/abs/1402.4061"}.]

{p 4 8 2} Jargowsky, Paul A. and Wheeler, Christopher A. 2018. "Estimating Income Statistics from Grouped Data:
Mean-Constrained Integration over Brackets."  Sociological Methodology 48(1): 337-374. 


