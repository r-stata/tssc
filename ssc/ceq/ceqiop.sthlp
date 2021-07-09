{smcl}
{* 26aug2015}{...}
{cmd:help ceqiop} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqiop} {hline 2} Estimates ex-ante inequality of opportunity by income concept for sheet "E4. Inequality of Opportunity" of the CEQ Master Workbook 2016

{title:Syntax}

{p 8 11 2}
    {cmd:ceqiop} {ifin} {weight} [{cmd:using} {it:filename}] {cmd:,} {opth gr:oupby(varlist)} [{it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opth groupb:y(varlist)}}Categorical variables that identify circumstances. 
(If each observation in the data set is a household, the variable should identify 
values for the household head.){p_end}

{syntab:Income concepts}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mp:luspensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth n:etmarket(varname)}}Net market income{p_end}
{synopt :{opth g:ross(varname)}}Gross income{p_end}
{synopt :{opth t:axable(varname)}}Taxable income{p_end}
{synopt :{opth d:isposable(varname)}}Disposable income{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
	(should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
	(should be used when each observation in the data set is an individual){p_end}
{synopt :{opth he:ad(string)}}Gives the condition identifying the household head
	(should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}

{synopt :{opth sheet(string)}}Name of sheet to write population matrices. Default is "E4. Inequality of Opportunity"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Required packages}

{pstd} 
{cmd:ceqiop} requires installation of {cmd:oppincidence} (Higgins, 2012), which is part of the CEQ Stata Package; to install, {stata ssc install ceq, replace:ssc install ceq, replace}.

{title:Description}

{pstd} 
{cmd:ceqiop} measures ex-ante inequality of opportunity for each of the CEQ core
income concepts, following the non-parametric method in Ferreira and Gignoux (2011). The core income concepts are indicated using the {opth m:arket(varname)}, 
{opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 
Circumstance sets are specified by
the variables in {opth groupb:y(varlist)}. For example, one circumstance set could be 
(female, black, parents were college graduates, urban): all individuals with those four traits are grouped together in 
one circumstance set. Circumstances are pre-determined factors that are not dependent on an 
individual’s effort, such as race, gender, and parents’ education or parents’ income. A smoothed income distribution 
is created by assigning each individual the mean income of the individuals in his or 
her circumstances set. Inequality (measured using mean log deviation) of the smoothed income distribution for each income 
concept gives the measure of inequality of opportunity in levels by income concept. 
This is labeled "In levels". Dividing the resulting measure by the 
mean log deviation for the actual income distribution measures the ratio of inequality
due to inequality of opportunity as opposed to inequality of effort. This is labeled "In ratios".

{pstd}
If the data set is at the individual level (each observation is an individual), the variable with the 
identification code of each household (i.e., it takes the same value for all members within a 
household) should be specified in the {opth hh:id(varname)} option; the {opth hs:ize(varname)} option 
should not be specified.
Furthermore, since the circumstance variables specified in {opth gr:oupby(varlist)}
could be defined at the individual level, for data sets at the individual level, the
condition identifying household heads must be specified. For example, if we have a
variable called {cmd:hh_status} that takes a value of 1 for the household head, 2
for the spouse, etc., we would specify {cmd:head(hh_status==1)}. If a variable name
is given rather than a condition, e.g. {cmd:head(hh_status)}, {cmd:ceqiop} assumes
that household heads are individuals for whom that variable is equal to 1.

{pstd}
If the data set is at the household level, the number of members in the 
household should be specified in {opth hs:ize(varname)}; the {opth hh:id(varname)} option should not be 
specified. Furthermore, the variables given in {opth gr:oupby(varlist)} should
be variables for the household head, e.g. a variable for gender would indicate the 
gender of the household head.
In either case (household or individual level data set), the weight used should be the household sampling weight and should {it:not} 
be multiplied by the number of members in the household since the program will do this multiplication 
automatically in the case of household-level data. 

{pstd}
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using  
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered 
using {help svyset} since {cmd:ceqiop} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option. 

{pstd}
By default, {cmd: ceqiop} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Negative incomes are allowed, but a warning is issued for each core income concept that 
has negative values (or positive values when a fiscal intervention is stored as negative values). This is because 
various measures are no longer well-behaved when negative values are included (for example, the Gini coefficient, 
concentration coefficient, or squared poverty gap can exceed 1, and other desirable properties of these measures 
when incomes are non-negative no longer hold when negative values are allowed).

{pstd}
Results are automatically exported to the CEQ Master Workbook Output Tables if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqiop} prints to a sheet titled "E4. Inequality of Opportunity"; the user can override the sheet name 
using the {opt sheet(string)} option. Exporting directly to the Master Workbook requires Stata 13 or 
newer. The Master Workbook populated with results from {cmd:ceqiop} can be automatically opened if the 
{opt open} option is specified (in this case, {it:filename} cannot have spaces). Results are also 
saved in matrices available from {cmd:return list}. To produce only a portion of the results, specify 
only a subset of the income concept options.

{title:Examples}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqiop [pw=w] using C:/MWB2016_E4.xlsx, groupby(sex race region) head(hh_status==1) hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf)open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqiop [pw=w] using C:/MWB2016_E4.xlsx, groupby(head_sex head_race head_region) hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) open}{p_end}

{title:Saved results}

{synopt:{cmd:r(levels)}}Mean log deviations (MLD) of smoothed distribution
    {p_end}
{synopt:{cmd:r(ratios)}}MLD of smoothed distribution over MLD of original distribution
    {p_end}

{title:Author}

{p 4 4 2}Sean Higgins, UC Berkeley, seanhiggins@berkeley.edu

{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}

{phang}
Ferreira, F. and J. Gignoux. 2011.
{browse "http://onlinelibrary.wiley.com/doi/10.1111/j.1475-4991.2011.00467.x/abstract":"The Measurement of Inequality of Opportunity: Theory and an Application to Latin America,"} {it:Review of Income and Wealth} 57, 622-657.{p_end}

