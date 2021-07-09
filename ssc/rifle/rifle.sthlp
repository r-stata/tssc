{smcl}
{* version 1.0.0 11aug2017}{...}
{cmd:help rifle}
{hline}

{title:Title}

{phang}
{bf:rifle {hline 2} Randomization inference for leader effects }

{title:Syntax}

{p 8 17 2}
{cmd:rifle} {depvar} {leader period unit} {if} [{cmd:,} {cmd:rifle_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt permnum}}sets the number of permutations {p_end}
{synopt:{opt report}}controls reporting of permutation runs {p_end}
{synopt:{opt nograph}}suppresses the graph {p_end}
{synopt:{opt nostitch}}prevents data from being "stitched" across 
	periods with missing data{p_end}
{synopt:{opt saving}}saves permuted results to a new file {p_end}
{synopt:{opt growth}}converts depvar from levels to percent changes {p_end}
{synoptline}


{title:Description}

{pstd}{cmd:rifle} implements randomization inference for leader effects
as developed by Berry and Fowler (2017). It returns a table of results 
comparing the R-squared from the true data with the distribution of R-squareds 
from permuted data. It also generates a graph displaying the distribution 
of R-squareds under the null of no leader effects.

{pstd}{cmd:rifle} expects a panel data set organized by {input:unit} and {input:period}. 
{input:depvar} specifies an outcome variable of interest for each 
unit and period. {input:leader} is a variable containing the identity of the 
leader in each unit and period. {input:leader} and {input:unit} may be numeric or string
variable; {input:outcome} and {input:period} must be numeric variables. 


{title:Options}
{dlgtab:Main}

{phang}{opt permnum} specifies the number of permutations to be performed. 
The default is 100.

{phang}{opt nostitch} prevents {cmd:rifle} from "stitching" together data.
 By default, {cmd:rifle} stitches together dates for each unit by effectively
 dropping or ignoring missing time periods. to do so, {cmd:rifle} resets 
 period to one for the first period in each unit and subsequently
 numbers later periods. For instance, if a unit had data for 1945, 1946, 
 1947, and 1949, these would be labeled periods 1 through 4, even though
 1948 is missing. Stitching is advantageous when a few years are missing
 idiosyncartically. However, if there is a long gap between periods or
 some other reason not to comprate observations across missing 
 periods, {opt nostitch} turns off this behavior. When {opt nostitch} is 
 specified, leaders are shuffled only within contigious non-missing
 blocks of time.

{phang}{opt growth} asks the program to convert the outcome variable to
period-by-period proportionate changes. This is useful if the user wants to
analyze the outcome in growth rates rather than levels. The outcome is 
converted to changes before any stitching takes places, so {cmd:rifle}
will not compute changes across peiords with missing data. 
If {opt growth} is not
specified, the program assumes the user has already consturcted the outcome
variable as desired. Do not specify {opt growth} if the outcome variable is
already a growth variable.


{dlgtab:Reporting}

{phang}{opt report} controls reporting of the number of completed permutations. 
By default, the program issues a count of the number of completed 
permutations after every 10.

{phang}{opt nograph} spcifies that the graph not be produced.

{phang}{opt saving} provides the name of a file where the results of the 
regressions on the permuted data and the real data are stored. The file 
will contain the F-statistic, R-squared, and adjusted R-sqaured from each 
regression performed. This file might be useful for further analysis by 
the user.

{phang}{opt replace} specifies that the file named in {opt saving} 
be overwritten if a file by that name already exists.


{title:Remarks}
{pstd}
The {cmd:rifle} method is developed in Berry and Fowler (2017). The process
is as follows. First, the data are de-trended through a regression of
{input:depvar} on {input:period} indicators. The residuals from this 
regression subseuqently become the dependent variable. Next, the
residuals are regressed against a set of {input:leader} fixed effects.
The R-squared from this regression is a measure of the extent to which
leaders "explain" the outcome. Next, leaders are randomly shuffled within
units. That is, the order of the leaders is randomly permuted within 
each unit. If leaders
matter, the R-squared from the regression on the correct leader data should 
be higher than than R-squared from the permuted data. Permuting the data 
many times provides a distribution of R-squared values under the null
of no leadership effects. Finally, the R-squared from the real leader data
is compared with the null distribution of R-squareds and the resulting
p-value is computed.
 

{title:Examples}

{phang}
{cmd:rifle gdpgrowth leader year country, permnum(1000) report(50) saving(permuted) replace  }

{phang}
{cmd:rifle gdp leader year country, growth}


{title:Authors}
Christopher Berry and Anthony Fowler
The University of Chicago


{title: References}
Christopher Berry and Anthony Fowler.
"Leadership or Luck: ...", available on authors' web pages.
