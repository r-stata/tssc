{smcl}
{*! version 2.0 04 April 2020}{...}
{cmd:help groupfunction}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:groupfunction} {hline 1}} Replaces several basic collapse functions (mean, sum, variance, standard deviation, first, max, min). The command is several orders of magnitude faster than collapse when summarizing multiple vectors on larger datasets.}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 23 2}
{opt groupfunction} [if] [in] [aw pw fw]  {cmd:,}
{opt by(varlist)}
{opt mean(varlist)}
{opt sum(varlist)}
{opt rawsum(varlist)}
{opt first(varlist)}
{opt min(varlist)}
{opt max(varlist)}
{opt count(varlist)}
{opt sd(varlist)}
{opt variance(varlist)}
{opt gini(varlist)}
{opt theil(varlist)}
{opt xtile(varlist)}
{opt nq(int)}
{opt missing}
{opt norestore}

{title:Description}

{pstd}
{cmd:groupfunction} Replaces several collapse functions (mean, sum, variance, first, max, min). The command is several orders of magnitude faster than collapse

{title:Options}

{phang}
{opt by(varlist)} Grouping for reporting estimates.

{phang}
{opt xtile(varlist)} Coupled with nq(), it creates variable with percentiles and adds it to the by() option.

{phang}
{opt nq(int)} Option only works when xtile() is specified. It indicates the number of quantiles.

{phang}
{opt mean(varlist)} Calculates means of specified variables.

{phang}
{opt sum(varlist)} Calculates total sum of specified variables. If weights are specified it will give population expanded total.

{phang}
{opt rawsum(varlist)} Calculates total sum of specified variables. If weights are specified it will ignore weights.

{phang}
{opt first(varlist)} Provides first observation by groups specified in by option. 

{phang}
{opt min(varlist)} Provides minimum value, by groups, of vectors specified.

{phang}
{opt max(varlist)} Provides maximum value, by groups, of vectors specified.

{phang}
{opt count(varlist)} Provides observation count, by groups, of vectors specified.

{phang}
{opt sd(varlist)} Calculates standard deviations of specified variables.

{phang}
{opt variance(varlist)} Calculates variance of specified variables.

{phang}
{opt gini(varlist)} Calculates Gini coefficient of specified variables.

{phang}
{opt theil(varlist)} Calculates Theil coefficient of specified variables.

{phang}
{opt missing} This option is only relevant for sum and rawsum. If an entire group in by() is missing for the sum/rawsum variable the output will be missing instead of zero.

{phang}
{opt norestore} Drops all non-relevant variables before calculations to improve memory management. 

{phang}
{opt slow} Use this option if you run into memory issues, it will get values one by one.

{phang}
{opt merge} Requests that values are not to be collapsed, it instead merges the new vectors to the dataset in memory.

{title:Example}
sysuse auto, clear
groupfunction [aw=weight], mean(price) min(weight) by(foreign)

{title:Example 2 (Time comparisons)}
clear all
set more off
set obs 300000

version 13
set seed 458267

gen regions = int(runiform()*20)

replace region = 1 if inrange(region,0,3)
replace region = 2 if inrange(region,4,5)


//Income per capita
forval z=1/200{
	gen x_`z' = region*runiform()*4000 + rnormal()*200
}


forval z=1/300{
	gen y`z' = runiform()*100 + (rnormal()*20)^2
}

gen weight = abs(rnormal())

//time collapse
preserve
timer on 1
collapse (mean) y* x_* [aw=w], by(region)
timer off 1
restore

//time fcollapse (Weights not supported)
preserve
timer on 2
fcollapse (mean) y* x_*, by(region)
timer off 2 
restore

//time groupfunction
preserve 
timer on 3
groupfunction [aw=weight], mean(y* x_*) by(region)
timer off 3
restore

timer list

{title:Authors}

{pstd}
Paul Corral{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
pcorralrodas@worldbank.org{p_end}

{pstd}
Minh C. Nguyen{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
pcorralrodas@worldbank.org{p_end}

{pstd}
Joao Pedro Azevedo{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
jazevedo@worldbank.org{p_end}


Raul Andrés Castañeda provided valuable suggestions for this command.

