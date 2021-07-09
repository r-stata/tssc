{smcl}
{* 21aug2016}{...}
{cmd:help ceqmarg} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqmarg} {hline 2} Computes marginal contribution of fiscal interventions (taxes, transfers, and subsidies) to inequality and poverty for the "E13. Marg. Contrib." sheets of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqmarg} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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

{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency (the default){p_end}

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
	(should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
	(should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Poverty lines}
{synopt :{opth pl1(real)}}Lowest poverty line in $ PPP (default is $1.25){p_end}
{synopt :{opth pl2(real)}}Second lowest poverty line in $ PPP (default is $2.50){p_end}
{synopt :{opth pl3(real)}}Third lowest poverty line in $ PPP (default is $4){p_end}
{synopt :{opth nationale:xtremepl(string)}}National extreme poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth nationalm:oderatepl(string)}}National moderate poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth othere:xtremepl(string)}}Other extreme poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth otherm:oderatepl(string)}}Other moderate poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth prop:ortion(real)}}Relative poverty line as a proportion of median household income from 0 to 1 (default is 0.5){p_end}

{syntab:Missing and negative values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions{p_end}
{synopt :{opt negatives}}Produce all results even if negative values present{p_end}
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E11.m FiscalInterventions"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E11.m+p FiscalInterventions"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E11.n FiscalInterventions"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E11.g FiscalInterventions"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E11.t FiscalInterventions"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E11.d FiscalInterventions"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E11.c FiscalInterventions"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E11.f FiscalInterventions"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Required packages}

{pstd} 
{cmd:ceqmarg} requires installation of {cmd:quantiles} (Osorio, 2007); to install, {stata ssc install quantiles:ssc install quantiles}.

{title:Description}

{pstd} 
{cmd:ceqmarg} calculates the marginal contribution (MC) of each fiscal intervention
(each tax, transfer, and subsidy) to inequality and poverty. These measures
show how much the particular fiscal intervention decreases inequality and 
poverty. In addition to the MC to the redistributive effect 
(i.e., marginal contribution to inequality, measured by the Gini coefficient),
the sheet also shows the MC to vertical equity and to 
reranking, the two components of a change in inequality
that sum to the redistributive effect.
In addition, the derivative of the MC to redistributive
effect, vertical equity, and reranking with respect to the size of the 
intervention are calculated. These measures can be used, for example, to tell how much an
increase in the size of the program would change inequality (holding its
targeting constant), and compare across programs.
For poverty, the MC to the poverty headcount, poverty gap,
and squared poverty gap are calculated. 

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
{opth userfeeso:ther(varlist)}. Tax and contribution variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax and contribution 
variables. The same goes for user fees variables. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
Each sheet is the CEQ core income concepts with respect to which the marginal 
contribution is calculated. The exact calculation depends on whether the fiscal
intervention in question has already been accounted for in the income concept
being used. For example, for a direct transfer called Direct Transfer 1,
since market income does not include direct transfers, the MC of Direct Transfer
1 to redistributive effect with respect to market income (i.e. on sheet E13.m) 
equals the Gini of market income minus the Gini of "market income plus Direct Transfer 1". 
Disposable income does include direct transfers, so the MC of
Direct Transfer 1 to redistributive effect with respect to disposable income 
(i.e. on sheet E13.d) equals the Gini of "disposable income minus (without) 
Direct Transfer 1" minus the Gini of disposable income.

{pstd}
The CEQ core income concepts include
include market income, market income plus pensions, net market income, gross income, taxable income, 
disposable income, consumable income, and final income. The variables for these income concepts, which 
should be expressed in local currency units (preferably {bf:per year} for ease of comparison with 
totals from national accounts), are indicated using the {opth m:arket(varname)}, 
{opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 

{pstd}
{cmd: ceqmarg} automatically converts local currency variables to PPP dollars, using the PPP conversion 
factor given by {opth ppp(real)}, the consumer price index (CPI) of the year of PPP (e.g., 2005 or 
2011) given by {opth cpib:ase(real)}, and the CPI of the year of the household 
survey used in the analysis given by {opth cpis:urvey(real)}. The year of PPP, also called base year, 
refers to the year of the International Comparison Program (ICP) that is being used, e.g. 2005 or 2011. 
The survey year refers to the year of the household survey used in the analysis. If the year of PPP is 
2005, the PPP conversion factor should be the "2005 PPP conversion factor, private consumption (LCU per 
international $)" indicator from the World Bank's World Development Indicators (WDI). If the year of 
PPP is 2011, use the "PPP conversion factor, private consumption (LCU per international $)" indicator 
from WDI. The PPP conversion factor should convert from year of PPP to year of PPP. In other words, 
when extracting the PPP conversion factor, it is possible to select any year; DO NOT select the year of 
the survey, but rather the year that the ICP was conducted to compute PPP conversion factors (e.g., 
2005 or 2011). The base year (i.e., year of PPP) CPI, which can also be obtained from WDI, should match 
the base year chosen for the PPP conversion factor. The survey year CPI should match the year of the 
household survey. Finally, for the PPP conversion, the user can specify whether the original variables 
are in local currency units per day ({opt da:ily}), per month ({opt mo:nthly}), or per year 
({opt year:ly}, the default assumption).

{pstd}
Poverty lines in PPP dollars per day can be set using the {opth pl1(real)}, {opth pl2(real)}, and {opth pl3(real)} options; the defaults for 
these are the commonly-used $1.25, $2.50, and $4 PPP poverty lines. For example, to change the lowest poverty line from $1.25 PPP per day 
to $1.90 PPP per day, specify {cmd:pl1(1.90)}. Poverty lines in local currency can be entered using the {opth nationale:xtremepl(string)}, 
{opth nationalm:oderatepl(string)}, {opth othere:xtremepl(string)}, {opth otherm:oderatepl(string)} options. Local currency poverty lines can 
be entered as real numbers (for poverty lines that are fixed for the entire population) or variable names (for poverty lines that vary, for 
example across space), and should be in the same units as the income concept variables (preferably local currency units per year). The relative 
poverty line can be specfied as a proportion of median household income using {opth proportion(real)}, where {it:real} should be a proportion 
between 0 and 1. The default proportion is 0.5, i.e. 50% of household median income. For example, to change the relative poverty line from 50% to 
60% of median income (which is used by the OECD), specify {cmd:proportion(0.6)}.

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
using {help svyset} since {cmd:ceqmarg} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqmarg} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Negative incomes are allowed, but a warning is issued for each core income 
concept that has negative values and certain results that are not 
well-behaved in the presence of negative values are not produced. These 
measures include 
the Gini coefficient, concentration coefficient, or squared poverty gap, 
since they can exceed 1 in the presence of negative values.
To override this default and produce results for the measures that are 
poorly behaved in the presence of negative values, specify {opt: negatives}.

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqmarg} prints to the sheets titled "E13.X Marg. Contrib." where X indicates the 
income concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the 
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)}, 
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options, 
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqmarg} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. To produce only a portion of the results, specify only a 
subset of the income concept options or use {opt nod:ecile}, {opt nog:roup}, {opt noc:entile}, or 
{opt nob:in}.

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqmarg [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary) userfeeshealth(user_feesh) userfeeseduc(user_feesed)	ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqmarg [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary) userfeeshealth(user_feesh) userfeeseduc(user_feesed) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

For a description of the marginal contribution:
{phang}
Enami, Ali, Nora Lustig, and Rodrigo Aranda. 2017. “Analytical Foundations: Measuring the Redistributive Impact of Taxes and Transfers.” Chapter 2 in Nora Lustig (editor) Commitment to Equity Handbook. A Guide to Estimating the Impact of Fiscal Policy on Inequality and Poverty. Brookings Institution Press and CEQ Institute.

{phang}
Enami, Ali. 2017. “Measuring the Effectiveness of Taxes and Transfers in Fighting Poverty and Reducing Inequality in Iran.” Chapter 14 in Nora Lustig (editor) Commitment to Equity Handbook. A Guide to Estimating the Impact of Fiscal Policy on Inequality and Poverty. Brookings Institution Press and CEQ Institute.

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}

{phang}
Osorio, R. 2007. "{bf:quantiles}: Stata module to categorize by quantiles." Boston
College Department of Economics Statistical Software Components S456856.{p_end}

