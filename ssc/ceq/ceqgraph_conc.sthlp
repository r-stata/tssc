{smcl}
{* 04mar2017}{...}
{cmd:help ceqgraph conc} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqgraph conc} {hline 2} Graphs concentration curves of fiscal interventions, ranked by each core income concept.

{title:Syntax}

{p 8 11 2}
    {cmd:ceqgraph} {cmdab:conc} {ifin} {weight} [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mp:luspensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth n:etmarket(varname)}}Net market income{p_end}
{synopt :{opth g:ross(varname)}}Gross income{p_end}
{synopt :{opth t:axable(varname)}}Taxable income{p_end}
{synopt :{opth d:isposable(varname)}}Disposable income{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:Fiscal Interventions}
{synopt :{opth p:ensions(varlist)}}Contributory pension variables{p_end}
{synopt :{opth dtr:ansfers(varlist)}}Direct transfer variables{p_end}
{synopt :{opth dtax:es(varlist)}}Direct tax variables{p_end}
{synopt :{opth cont:ribs(varlist)}}Contribution variables{p_end}
{synopt :{opth su:bsidies(varlist)}}Subsidy variables{p_end}
{synopt :{opth indtax:es(varlist)}}Indirect tax variables{p_end}
{synopt :{opth health(varlist)}}Health variables{p_end}
{synopt :{opth educ:ation(varlist)}}Education variables{p_end}
{synopt :{opth other:public(varlist)}}Other public in-kind transfers{p_end}
{synopt :{opth userfeesh:ealth(varlist)}}Health user fees variables{p_end}
{synopt :{opth userfeese:duc(varlist)}}Education user fees variables{p_end}
{synopt :{opth userfeeso:ther(varlist)}}Other public user fees variables{p_end}

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
	(should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
	(should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions

{syntab:Graphing options}
{synopt :{opth scheme(string)}}Set the graph scheme ({stata help scheme}; default is "s1mono"){p_end}
{synopt :{opth path(string)}}The directory to save the graphs in{p_end}
{synopt :{opth graphname(string)}}The prefix of the saved graph names (default is "conc"){p_end}
{synopt :{it:{help twoway_options}}}Any options documented in
   {bind:{bf:[G] {it:twoway_options}}}{p_end}
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 14.1 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheet(string)}}Name of sheet to write results. Default is "E25. Concentration Curves"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}

{synoptline}	
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Description}

{pstd} 
{cmd:ceqgraph conc} graphs concentration curves of fiscal interventions, ranked by each core income concept. For legibility, separate graphs are 
produced for various categories of fiscal intervention, and a separate set of these 
graphs is produced for the income ranking corresponding to each of the core income 
concepts.

{pstd}
The core income concepts include market income, market income plus pensions, net market income, gross 
income, taxable income, disposable income, consumable income, and final income. The variables for 
these income concepts, which should be expressed in local currency units (preferably {bf:per year} for 
ease of comparison with totals from national accounts), are indicated using the 
{opth m:arket(varname)}, {opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, 
{opth g:ross(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 

{pstd}
The fiscal interventions are specified using fiscal intervention options. Note that each option takes 
a {varlist} that can (and often should) have greater than one variable: the variables provided should 
be as disaggregated as possible. For example, there might be survey questions about ten different 
direct cash transfer programs; each of these would be a variable, and all ten variables would be 
included with the {opth dtr:ansfers(varlist)} option. Contributory pensions are specified by 
{opth p:ensions(varlist)}, direct transfers by {opth dtr:ansfers(varlist)}, direct taxes (not 
including contributions) by {opth dtax:es(varlist)}}, contributions (including variables for both 
employer and employee contributions if applicable) by {opth co:ntribs(varlist)}, indirect subsidies 
by  {opth su:bsidies(varlist)}, indirect taxes by {opth indtax:es(varlist)}, health benefits by 
{opth health(varlist)}, educaiton benefits by {opth educ:ation(varlist)}, and other public in-kind 
benefits by {opth other:public(varlist)}, health user fees by {opth userfeesh:ealth(varlist)},
education user fees by {opth userfeese:duc(varlist)}, and other public user fees by
{opth userfeeso:ther(varlist)}. Tax, contribution and user fees variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax, contribution and user fees
variables. The {opth health(varlist)}, {opth educ:ation(varlist)} and {opth other:public(varlist)} options 
need to be specfied with fiscal intervention variable(s) that are net of user fee(s).
If any of these variables is negative for any households due to user fees exceeding gross benefits, the negative values should be truncated at 0. 
The user fee options are designed solely to separately analyze the distribution of usre fees and will not be used in calculating 
net health/education/other public transfers. See the example section for more detail. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
The income and fiscal intervention variables should be expressed in household per capita or per adult equivalent 
terms, regardless of whether the data set being used is at the household or individual level. Hence, they should 
have the same per-person amount for each member within a household when using individual-level data.

{pstd}
A separate set of graphs is produced for the income ranking corresponding to each
of the CEQ core income concepts, which 
include market income, market income plus pensions, net market income, gross income, taxable income, 
disposable income, consumable income, and final income. The variables for these income concepts are indicated using the {opth m:arket(varname)}, 
{opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 

{pstd}
If the data set is at the individual level (each observation is an individual), the variable with the 
identification code of each household (i.e., it takes the same value for all members within a 
household) should be specified in the {opth hh:id(varname)} option; the {opth hs:ize(varname)} option 
should not be specified. If the data set is at the household level, the number of members in the 
household should be specified in {opth hs:ize(varname)}; the {opth hh:id(varname)} option should not be 
specified. In either case, the weight used should be the household sampling weight and should {it:not} 
be multiplied by the number of members in the household since the program will do this multiplication 
automatically in the case of household-level data. 

{pstd}
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using 
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered 
using {help svyset} since {cmd:ceqgraph} automatically uses the information specified using 
{help svyset}. Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option 
and strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqgraph conc} does not allow income concept or fiscal intervention variables to have missing 
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
The resulting graphs from {cmd:ceqgraph conc} are saved as {bf:`graphname'_`category'_`y'.gph} 
where `graphname' is the prefix specified by {opth graphname(string)} (or "conc" by default),
`y' is a letter representing the income concept used to rank (m, p, n, g, t, d, c, or f),
and `category' is a category of fiscal interventions (direct_transfers, direct_taxes, 
indirect_subsidies, indirect_taxes, inkind, or summary). The final category, summary,
summarizes the curves for each of the above broad categories in a single graph.

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqgraph conc} prints to the sheets titled "E25. Concentration Curves"; the user can override the sheet names using the 
{opt sheet(string)}. Exporting directly to the Master Workbook requires Stata 14.1 or newer. The Master 
Workbook populated with results from {cmd:ceqgraph conc} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. 

{title:Examples}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqgraph conc [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) ///}{p_end}
{phang} {cmd:. c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax)}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqgraph conc [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) ///}{p_end}
{phang} {cmd:. c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax)}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}


