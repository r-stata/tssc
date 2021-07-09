{smcl}
{* *! version 2  DEC2013}{...}
{cmd:help piaactab} {right:also see:  {help piaacdes} {help piaacreg} }

{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:[R] piaactab} } Oneway and twoway tables with PIAAC data {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:piaactab}
	{it:{help varname}}
	{cmd: [if] [in],}  save(string) [, options]
	
	
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main options}

{synopt :{help prefix_saving_option:{bf:{ul:save}(}{it:filename}{bf:, ...)}}}save
	results to {it:filename}. You have to specify this option {p_end}

{syntab: Optional}

{synopt :{opt twoway}} Calculates cell percentages as in a twoway table (over both the main and the over() variable). {p_end}

{synopt :{opt fast}} Speeds up calculations by not reporting standard errors. {p_end}
 
{synopt :{opt countryid(varname)}} Allows providing the name of a variable containing a list of countries for which you want to obtain results.
The list can be numeric or string with any possible values.
Missing categories will be omitted from calculations and average over all countries will be calculated.
When this option is not specified, CNTRYID or cntryid variable will be used as to identify countries and the OECD average will be calculated. {p_end}

{synopt :{opt vemethodn(varname numeric)}} Provides the name of the numeric variable specifying the jackknife variance estimation method for each country.
The variable can only contain values of 1 or 2. When this option is not specified, VEMETHODN or vemethodn variable will be used to identify jackknife method.
When this option is not specified, piaactab will look for VEMETHODN or vemethodn variable to identify jackknife method. {p_end}

{synopt :{opt weight(varlist max=1) rep(varlist)}} Gives the main weight and a list of jackknife replication weights.
You don't have to specify these options if your dataset contains original weights spfwt0-spfwt80 or SPFWT0-SPFWT80. {p_end}

{synopt :{opt over(varname)}} Specifies a categorical variable or plausible value for which you want to obtain statistics by each category.
The variable must be numerical with a sequence of integers denoting each category. 
For proficiency levels, specify the prefix of plausible values without ending numbers (e.g. pvlit, pvnum, pvpsl). {p_end}

{synopt :{opt round(int)}} Specifies how many decimal places you want to see in results tables. The default is 2. {p_end}

{synopt :{opt missing}} With this option statistics for missing observations will be included as a separate category. {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd:piaactab} calculates cell percentages for a variable with PIAAC data.
To calculate percentages for proficiency levels, specify the prefix of plausible values variable without ending numbers (e.g. pvlit, pvnum, pvpsl).
Similarly, the prefix of plausible values can be specified in over() option.
In this case, the percentages will be calculated over proficiency levels.
Users can also use their own categorical variables based on plausible values.
Names of these variables should start with pv prefix and varname should include them with underscore instead of 1 to 10 numbers denoting each plausible variable.
For example, - piaactab pv_level, ... - will calculate statistics for variables pv1level to pv10level that are based on plausible values.
Similarly, own variables based on plausible values can be specified in over() option.
For example, over(pv_level) will calculate statistics over categories of pv1level-pv10level variables based on plausible values.
Piaactab saves results as html file that can be, for example, further edited in a spreadsheet application.
Piaactab also returns results in Stata matrices. Type -return list- after executing the command.
{p_end}

{title:Example 1. Calculation of the table without involving plausible values.}

{pstd}
Computation of the percentage of males and females by country with the appropriate standard errors:{p_end}

{phang2}{cmd:. piaactab gender_r, countryid(cntryid) round(5) save(example1) }{p_end}

{pstd}
Results are saved in the working directory in the file named example1.html.
Numbers are saved with 5 decimal points.
Results are also returned in matrices that can be further processed directly in Stata.
Type -return list- after running piaacreg to see the list of returned result matrices.{p_end}

{pstd}For example, to see the point estimates type:{p_end}
{phang2}{cmd:. mat list r(b)}{p_end}

{pstd}To see the standard errors type:{p_end}
{phang2}{cmd:. mat list r(se)}{p_end}

{title:Example 2. Calculation of the table involving plausible values.}

{pstd}
Computation of the percentage of respondents at each proficiency level in literacy with the appropriate standard errors.
Calculations are based on the OECD's thresholds using plausible values pvlit*. {p_end}

{phang2}{cmd:. piaactab pvlit, countryid(cntryid) round(5) save(example2)}{p_end}

{pstd}
Results are saved in the html file and in the return matrices. For more details see Example 1.{p_end}

{title:Example 3. Calculations by subgroups using the over() option}

{phang2}{cmd:. piaactab computerexperience, over(gender_r) countryid(cntryid) round(5) save(example3a)}{p_end}
{phang2}{cmd:. piaactab pvlit, over(gender_r) countryid(cntryid) round(5) save(example3b)}{p_end}
{phang2}{cmd:. piaactab gender_r, over(pvlit) countryid(cntryid) round(5) save(example3c)}{p_end}

{pstd}
Results are saved in the html file. Results are also saved in the separate return matrices for each over() category. 
For example, to see the matrix with the standard errors for the second over() category type:{p_end}
{phang2}{cmd:. mat list r(se_over2)}{p_end}


{title:Also see}

{p 4 13 2}
Help for {helpb piaacdes}, {helpb piaacreg} (if installed)
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
