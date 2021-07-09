{smcl}
{* *! version 2  DEC2013}{...}
{cmd:help piaacdes}  {right:also see:  {help piaactab} {help piaacreg} }
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:[R] piaacdes} } Basic statistics with PIAAC data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:piaacdes}
	{it:{help varlist}}
	{cmd: [if] [in],}  save(string) [, options]
	
	
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main options}

{synopt :{help prefix_saving_option:{bf:{ul:save}(}{it:filename}{bf:, ...)}}}save
	results to {it:filename}. You have to specify this option {p_end}

{syntab: Optional}
 
{synopt :{opt countryid(varname)}} Allows providing the name of a variable containing a list of countries for which you want to obtain results.
The list can be numeric or string with any possible values.
Missing categories will be omitted from calculations and average over all countries will be calculated.
When this option is not specified, CNTRYID or cntryid variable will be used as to identify countries and the OECD average will be calculated. {p_end}

{synopt :{opt vemethodn(varname numeric)}} Provides the name of the numeric variable specifying the jackknife variance estimation method for each country.
The variable can only contain values of 1 or 2. When this option is not specified, VEMETHODN or vemethodn variable will be used to identify jackknife method.
When this option is not specified, piaacdes will look for VEMETHODN or vemethodn variable to identify jackknife method. {p_end}

{synopt :{opt weight(varlist max=1) rep(varlist)}} Gives the main weight and a list of jackknife replication weights.
You don't have to specify these options if your dataset contains original weights spfwt0-spfwt80 or SPFWT0-SPFWT80. {p_end}

{synopt :{opt stats(string)}} Gives a list of statistics to be calculated. You can list any statistic calculated by -summarize-, e.g. stats(mean sd) will calculate mean and standard deviation.
If stats() and centile() are not specified, means will be calculated. {p_end}

{synopt :{opt centile(string)}} Gives percentiles to be calculated.
For example, centile(5 50 75) will result in calculating the 5th, median and the 75th percentile. {p_end}

{synopt :{opt pv(string)}} Gives a list of plausible values prefixes, e.g. use pv(pvlit) to calculate statistics for plausible value in literacy. {p_end}

{synopt :{opt over(varname)}} Specifies a categorical variable or plausible value for which you want to obtain statistics by each category.
The variable must be numerical with a sequence of integers denoting each category. 
For proficiency levels, specify the prefix of plausible values without ending numbers (e.g. pvlit, pvnum, pvpsl). {p_end}

{synopt :{opt round(int)}} Specifies how many decimal places you want to see in results tables. The default is 2. {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd:piaacdes} calculates basic statistics with PIAAC data for the given variables and plausible values listed in the pv() option.
The pv() option takes the prefix of plausible values variable without ending numbers (e.g. pvlit, pvnum, pvpsl).
Similarly, the prefix of plausible values can be specified in over() option.
In this case, the statistics will be calculated over proficiency levels.
Piaacdes saves results as html file that can be, for example, further edited in a spreadsheet application.
Piaacdes also returns results in Stata matrices. Type -return list- after executing the command.
{p_end}

{title:Example 1. Computation of statistics without involving plausible values.}

{pstd}
Computation of means, standard deviations, 25th and 75th centiles for the PIAAC index of readiness to learn (readiness) across countries.
Results are saved in the working directory in the file example1.html. Numbers are reported with 5 decimal points.
{p_end}

{phang2}{cmd:. piaacdes readytolearn, countryid(cntryid) stats(mean sd) centile(25 75) round(5) save(example1) }{p_end}

{pstd}
Results are also returned in matrices that can be further processed directly in Stata.
Type -return list- after running piaacdes to see the list of returned result matrices.{p_end}

{pstd}For example, to see the point estimates type:{p_end}
{phang2}{cmd:. mat list r(b_readytolearn)}{p_end}

{pstd}To see the standard errors type:{p_end}
{phang2}{cmd:. mat list r(se_readytolearn)}{p_end}


{title:Example 2. Computation of statistics with plausible values.}

{pstd}
Computation of means and specific percentiles for the PIAAC numeracy proficiency scale (pvnum) across countries.
Results are saved in the working directory in the file example2.html. Numbers are reported with 5 decimal points.
{p_end}

{phang2}{cmd:. piaacdes, countryid(cntryid) pv(pvnum) stats(mean) centile(5 10 25 50 75 90 95) round(5) save(example2)}{p_end}

{pstd}
Results are also saved in the return matrices. For more details see Example 1.{p_end}

{title:Example 3. Computation of statistics by categories.}

{pstd}
Computation of means and standard deviations for the PIAAC index of readiness to learn (readiness).
Results are reported separately for each country and by gender.
Numbers are reported with 2 decimal points.
{p_end}

{phang2}{cmd:. piaacdes readytolearn, countryid(cntryid) stats(mean sd) round(2) save(example3) over(gender_r)}{p_end}

{pstd}
Results are saved in the html file. Results are also saved in the separate return matrices for each over() category. 
For example, to see the matrix with the standard errors for the second over() category type:{p_end}
{phang2}{cmd:. mat list r(se_readytolearn_over2)}{p_end}

{title:Example 4. Computation of statistics over proficiency levels.}

{pstd}
Computation of means for the PIAAC index of readiness to learn (readiness) over the levels of problem solving proficiency.
OECD's proficiency thresholds are used to obtain results using the plausible values in problem solving (pvpsl*).
{p_end}

{phang2}{cmd:. piaacdes readytolearn, countryid(cntryid)  stats(mean) round(2) save(example4) over(pvpsl)}{p_end}

{pstd}
Results are saved in the html file. Results are also saved in the separate return matrices for each over() category. 
For example, to see the matrix with the point estimates for the fourth over() category type:{p_end}
{phang2}{cmd:. mat list r(b_readytolearn_over4)}{p_end}

{title:Also see}

{p 4 13 2}
Help for {helpb piaactab}, {helpb piaacreg} (if installed)
{p_end}

{title:Authors}

{pstd} Maciej Jakubowski, 
Faculty of Economic Sciences, Warsaw University {p_end}
{pstd} {browse "mailto:mjakubowski@uw.edu.pl":mjakubowski@uw.edu.pl} {p_end}

{pstd} Artur Pokropek, 
Educational Research Institute (IBE), Warsaw {p_end}
{pstd} {browse "mailto:artur.pokropek@gmail.com":artur.pokropek@gmail.com} {p_end}

{title:Version}

{pstd}Last updated 2012-12-25{p_end}

