{smcl}
{* 16oct2016}{...}
{cmd:help ceqhhchar} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqhhchar} {hline 2} Mean and median household-level sociodemographic characteristics for the "E22. GroupSociodemoCharac" sheets of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqhhchar} {varlist} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E22.m GroupSociodemoCharac"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E22.m+p GroupSociodemoCharac"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E22.n GroupSociodemoCharac"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E22.g GroupSociodemoCharac"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E22.t GroupSociodemoCharac"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E22.d GroupSociodemoCharac"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E22.c GroupSociodemoCharac"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E22.f GroupSociodemoCharac"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Required commands}

{pstd} 
{cmd:ceqhhchar} requires installation of {cmd:quantiles} (Osorio, 2007) and {cmd:sgini} (Van Kerm, 2009). To install, {stata ssc install quantiles:ssc install quantiles} and {stata "net install sgini, from(http://medim.ceps.lu/stata)"}.

{title:Description}

{pstd} 
{cmd:ceqhhchar} calculates 
mean and median household-level sociodemographic characteristics (i.e., for 
variables defined at the household level such as "age of household head", 
"access to piped water", or "number of rooms"), as well as their standard deviation.
In addition, it calculates the mean of these variables by income decile, group, centile, and bin.
The sociodemographic characteristic variables are supplied in {varlist}.

{pstd}
The data set can be either at the household or individual level, but if it is at the
individual level make sure that for each individual the variables are equal
 for all members of the household. (For example, for age of household head, 
define a variable "age of household head" that equals the age of the head for all 
members in that head's household; using a variable "age" in an individual-level data 
set would not be correct for the household-level sociodemographic characteristics.)

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
For results by income group, the cut-offs of these groups 
can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are 
ultra-poor (less than $1.25 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor 
($1.25 to $2.50 PPP per day), moderate poor ($2.50 to $4 PPP per day), vulnerable ($4 to $10 PPP per 
day), middle class ($10 to $50 PPP per day) and wealthy ($50 and more PPP per day). For example, specify {cmd:cut1(1.90)} to 
change the first cut-off to $1.90 PPP per day (which would cause the lowest group to become less than 
$1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second 
cut-off is maintained--to range from $1.90 to $2.50 PPP).

{pstd}
Each fiscal interventions sheet using the ranking from one of the CEQ core income concepts, which 
include market income, market income plus pensions, net market income, gross income, taxable income, 
disposable income, consumable income, and final income. The variables for these income concepts, which 
should be expressed in local currency units (preferably {bf:per year} for ease of comparison with 
totals from national accounts), are indicated using the {opth m:arket(varname)}, 
{opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 

{pstd}
{cmd: ceqhhchar} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using 
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered 
using {help svyset} since {cmd:ceqhhchar} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqhhchar} does not allow income concept variables to have missing 
values: if a household has 0 income for an income concept, the household should have 0 rather than a missing value. 
If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Negative incomes are allowed in {cmd: ceqhhchar}, but a warning is issued for each core income concept that 
has negative values. This is because 
various measures are no longer well-behaved when negative values are included (for example, the Gini coefficient, 
concentration coefficient, or squared poverty gap can exceed 1, and other desirable properties of these measures 
when incomes are non-negative no longer hold when negative values are allowed).

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqhhchar} prints to the sheets titled "E22.X GroupSociodemoCharac" where X indicates the 
income concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the 
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)}, 
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options, 
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqhhchar} can be automatically opened if the {opt open} 
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
{phang} {cmd:. ceqhhchar [pw=w] age_head water_access number_rooms using C:/MWB2016_E22.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqhhchar [pw=w] age_head water_access number_rooms using C:/MWB2016_E22.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Osorio, R. 2007. "{bf:quantiles}: Stata module to categorize by quantiles." Boston
College Department of Economics Statistical Software Components S456856.{p_end}

