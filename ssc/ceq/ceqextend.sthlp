{smcl}
{* 29sep2016}{...}
{cmd:help ceqextend} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqextend} {hline 2} Computes summary statistics and detailed information for CEQ extended income concepts by income decile, group, centile, and bin for the "E12. Extended Income Concepts" sheets of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqextend} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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

{syntab:Income group cut-offs}
{synopt :{opth cut1(real)}}Upper bound income for ultra-poor; default is $1.25 PPP per day{p_end}
{synopt :{opth cut2(real)}}Upper bound income for extreme poor; default is $2.50 PPP per day{p_end}
{synopt :{opth cut3(real)}}Upper bound income for moderate poor; default is $4 PPP per day{p_end}
{synopt :{opth cut4(real)}}Upper bound income for vulnerable; default is $10 PPP per day{p_end}
{synopt :{opth cut5(real)}}Upper bound income for middle class; default is $50 PPP per day{p_end}
   
{syntab:Produce subset of results}
{synopt :{opt nod:ecile}}Do not produce results by decile{p_end}
{synopt :{opt nog:roup}}Do not produce results by income group{p_end}
{synopt :{opt noc:entile}}Do not produce results by centile{p_end}
{synopt :{opt nob:in}}Do not produce results by bin{p_end}

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions

{syntab:Allow negative values}
{synopt :{opt negatives}}Allow indicators for income concepts and fiscal interventions with negative values to be produced
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E12.m Extended Income Concepts"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E12.m+p Extended Income Concepts"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E12.n Extended Income Concepts"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E12.g Extended Income Concepts"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E12.t Extended Income Concepts"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E12.d Extended Income Concepts"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E12.c Extended Income Concepts"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E12.f Extended Income Concepts"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}

{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Required commands}

{pstd} 
{cmd:ceqextend} requires installation of {cmd:quantiles} (Osorio, 2007) and {cmd:sgini} (Van Kerm, 2009). To install, {stata ssc install quantiles:ssc install quantiles} and {stata "net install sgini, from(http://medim.ceps.lu/stata)"}.

{title:Description}

{pstd} 
{cmd:ceqextend} calculates summary statistics and detailed information by decile, income group,
centile, and income bin for extended income concepts, created by adding and subtracting fiscal
interventions (taxes, transfers, and subsidies) to and from the CEQ core income concepts. In these
sheets, deciles, groups, centiles, and bins are defined anonymously. Summary statistics include the 
mean, median, standard deviation, Gini, absolute Gini, S-Gini with a variety of parameters, Theil, 
90/10, and headcount index, poverty gap, and squared poverty gap for a number of poverty lines. The 
detailed information of total income in local currency units (preferably per year) is available for each
extended income concept by income decile, group, centile, and bin.

{pstd}
The extended income concepts are created from the CEQ core income concepts, specified with the options 
{opth m:arket(varname)}, {opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)},
{opth c:onsumable(varname)}, and {opth f:inal(varname)}, and the fiscal interventions. Note that each 
fiscal intervention option takes a {varlist} that can (and often should) have greater than one 
variable: the variables provided should be as disaggregated as possible. For example, there might be 
survey questions about ten different direct cash transfer programs; each of these would be a variable, 
and all ten variables would be included with the {opth dtr:ansfers(varlist)} option. Contributory 
pensions are specified by {opth p:ensions(varlist)}, direct transfers by {opth dtr:ansfers(varlist)}, 
direct taxes (not including contributions) by {opth dtax:es(varlist)}}, contributions (including 
variables for both employer and employee contributions if applicable) by {opth co:ntribs(varlist)}, 
indirect subsidies by  {opth su:bsidies(varlist)}, indirect taxes by {opth indtax:es(varlist)}, health 
benefits by {opth health(varlist)}, educaiton benefits by {opth educ:ation(varlist)}, other public 
in-kind benefits by {opth other:public(varlist)}, health user fees by {opth userfeesh:ealth(varlist)},
education user fees by {opth userfeese:duc(varlist)}, and other public user fees by
{opth userfeeso:ther(varlist)}. Tax and contribution variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax and contribution 
variables. The same goes for user fees variables. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
Poverty lines in PPP dollars per day can be set using the {opth pl1(real)}, {opth pl2(real)}, and 
{opth pl3(real)} options; the defaults for these are the commonly-used $1.25, $2.50, and $4 PPP 
poverty lines. For example, to change the lowest poverty line from $1.25 PPP per day to $1.90 PPP per 
day, specify {cmd:pl1(1.90)}. Poverty lines in local currency can be entered using the {opth nationale:xtremepl(string)}, 
{opth nationalm:oderatepl(string)}, {opth othere:xtremepl(string)}, {opth otherm:oderatepl(string)} 
options. Local currency poverty lines can be entered as real numbers (for poverty lines that are fixed 
for the entire population) or variable names (for poverty lines that vary, for example across space), 
and should be in the same units as the income concept variables (preferably local currency units per 
year). The relative poverty line can be specfied as a proportion of median household income 
using {opth proportion(real)}, where {it:real} should be a proportion between 0 and 1. The default 
proportion is 0.5, i.e. 50% of household median income. For example, to change the relative poverty line from 50% to 
60% of median income (which is used by the OECD), specify {cmd:proportion(0.6)}.

{pstd}
Poverty lines are used for poverty results; for results by income group, the cut-offs of these groups 
can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are 
ultra-poor (less than $1.25 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor 
($1.25 to $2.50 PPP per day), moderate poor ($2.50 to $4 PPP per day), vulnerable ($4 to $10 PPP per 
day), middle class ($10 to $50 PPP per day) and wealthy ($50 and more PPP per day). For example, specify {cmd:cut1(1.90)} to 
change the first cut-off to $1.90 PPP per day (which would cause the lowest group to range from $0 to 
$1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second 
cut-off is maintained--to range from $1.90 to $2.50 PPP).

{pstd}
{cmd: ceqextend} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
using {help svyset} since {cmd:ceqextend} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqextend} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
By default, the Gini coefficient, Theil index, concentration coefficient, poverty gap or squared poverty gap 
are not produced when negative values are included for each core income concept or fiscal intervention in {cmd:ceqextend}. 
This is because these measures are no longer well-behaved when negative values are included (for example, these measures 
can exceed 1, and other desirable properties of these measures when incomes or fiscal interventions are non-negative no 
longer hold when negative values are allowed). For flexibility, however, the command includes a {opt negatives} option 
that allows for the calculation of all indicators.

{pstd}
Results are automatically exported to the CEQ Master Workbook if {cmd:using} {it:filename} 
is specifed in the command, where {it:filename} is the Master Workbook. By default, 
{cmd:ceqextend} prints to the sheets titled "E12.X Extended Income Concepts" where X indicates the income 
concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the 
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)}, 
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options,
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqextend} can be automatically opened if the {opt open} 
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
{phang} {cmd:. ceqextend [pw=w] using C:/MWB2016_E12.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary) userfeeshealth(ufee_basichealth ufee_impatienthealth) userfeeseduc(ufee_daycare ufee_preschool ufee_primary)	ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)	othere(`pl70') otherm(`pl140') open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqextend [pw=w] using C:/MWB2016_E12.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary) userfeeshealth(ufee_basichealth ufee_impatienthealth) userfeeseduc(ufee_daycare ufee_preschool ufee_primary) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)	othere(`pl70') otherm(`pl140') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org

{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}

{phang}
Osorio, R. 2007. "{bf:quantiles}: Stata module to categorize by quantiles." Boston
College Department of Economics Statistical Software Components S456856.{p_end}

{phang}
Van Kerm, P. 2009. "{bf:sgini}: Generalized Gini and concentration coefficients (with factor decomposition) in Stata." {browse "http://medim.ceps.lu/stata/sgini.pdf":medim.ceps.lu/stata/sgini.pdf}.{p_end}

