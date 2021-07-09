{smcl}
{* 9jul2016}{...}
{cmd:help ceqefext} (beta version; please report bugs) {right:Rodrigo Aranda}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqefextend} {hline 2} Computes effectiveness indicators for CEQ extended income concepts for the "E14. Effectiveness" sheets of the CEQ Master Workbook 2016

{title:Syntax}

{p 8 11 2}
    {cmd:ceqefext} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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

{syntab:Income group cut-offs}
{synopt :{opth cut1(real)}}Upper bound income for ultra-poor; default is $1.25 PPP per day{p_end}
{synopt :{opth cut2(real)}}Upper bound income for extreme poor; default is $2.50 PPP per day{p_end}
{synopt :{opth cut3(real)}}Upper bound income for moderate poor; default is $4 PPP per day{p_end}
{synopt :{opth cut4(real)}}Upper bound income for vulnerable; default is $10 PPP per day{p_end}
{synopt :{opth cut5(real)}}Upper bound income for middle class; default is $50 PPP per day{p_end}
    
{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E14.m Effectiveness"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E14.m+p Effectiveness"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E14.n Effectiveness"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E14.g Effectiveness"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E14.t Effectiveness"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E14.d Effectiveness"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E14.c Effectiveness"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E14.f Effectiveness"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Required commands}

{title:Description}

{pstd} 
{cmd:ceqefext} calculates the CEQ effectiveness indicators. Indicators include spending effectiveness and impact
effectiveness indicators for Gini, headcount index, poverty gap, and squared poverty gap for a number of poverty lines. 
The effectiveness indicators of fiscal interventions are compared with respect to market income, market income + pensions, 
net market income, gross income, and disposable income. For this reason fiscal interventions are necessary for ceqefext 
to run, if they are excluded from the command there will be an error. With the fiscal intervention options, total taxes 
and total benefits are used to estimate the impact effeectivness from one income concept to another.

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
benefits by {opth health(varlist)}, educaiton benefits by {opth educ:ation(varlist)}, and other public 
in-kind benefits by {opth other:public(varlist)}. Tax and contribution variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax and contribution 
variables. For user fees that should be subtracted out of health and education benefits, the gross 
benefits should be specified by a set of variables (e.g., gross primary education benefits, gross 
secondary education benefits, etc.), and another variable with user fees, stored as negative values, 
should also be included in the {opth health(varlist)} or {opth educ:ation(varlist)} option. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
Poverty lines in PPP dollars per day can be set using the {opth pl1(real)}, {opth pl2(real)}, and 
{opth pl3(real)} options; the defaults for these are the commonly-used $1.25, $2.50, and $4 PPP 
poverty lines. For example, to change the lowest poverty line from $1.25 PPP per day to $1.90 PPP per 
day, specify {cmd:pl1(1.90)}. Poverty lines in local currency can be entered using the {opth nationale:xtremepl(string)}, 
{opth nationalm:oderatepl(string)}, {opth othere:xtremepl(string)}, {opth otherm:oderatepl(string)} 
options. Local currency poverty lines can be entered as real numbers (for poverty lines that are fixed 
for the entire population) or variable names (for poverty lines that vary, for example across space), 
and should be in the same units as the income concept variables (preferably local currency units per 
year). 
Poverty lines are used for poverty results; for results by income group, the cut-offs of these groups 
can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are 
ultra-poor ($0 to $1.25 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor 
($1.25 to $2.50 PPP per day), moderate poor ($2.50 to $4 PPP per day), vulnerable ($4 to $10 PPP per 
day), middle class ($10 to $50 PPP per day) and wealthy ($50 and more PPP per day). For example, specify {cmd:cut1(1.90)} to 
change the first cut-off to $1.90 PPP per day (which would cause the lowest group to range from $0 to 
$1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second 
cut-off is maintained--to range from $1.90 to $2.50 PPP).

{pstd}
{cmd: ceqefext} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
using {help svyset} since {cmd:ceqefext} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
Results are automatically exported to the CEQ Master Workbook Output Tables if {cmd:using} {it:filename} 
is specifed in the command, where {it:filename} is the Master Workbook. By default, 
{cmd:ceqefext}} prints to the sheets titled "E14.X Effectiveness" where X indicates the income 
concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the 
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)}, 
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options,
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqefext} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. 

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqefext [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health user_fees) 	education(daycare preschool primary secondary tertiary user_fees) 	ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)	othere(`pl70') otherm(`pl140') open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqefext [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health user_fees) 	education(daycare preschool primary secondary tertiary user_fees) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)	othere(`pl70') otherm(`pl140') open}{p_end}

{title:Saved results}

Pending

{title:Authors}

{p 4 4 2}Rodrigo Aranda, Tulane University, raranda@tulane.edu
{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}

