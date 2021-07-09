{smcl}
{* 04mar2017}{...}
{cmd:help ceqeduc} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqeduc} {hline 2} Computes educational enrollment rates for the "E20. Edu Enrollment Rates" sheets of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqeduc} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Education enrollment}
{synopt :{opth pre:school(varname)}}Dummy variable =1 if attends preschool{p_end}
{synopt :{opth pri:mary(varname)}}Dummy variable =1 if attends primary{p_end}
{synopt :{opth sec:ondary(varname)}}Dummy variable =1 if attends secondary{p_end}
{synopt :{opth ter:tiary(varname)}}Dummy variable =1 if attends tertiary{p_end}
{synopt :{opth preschoolage(varname)}}Dummy variable =1 if preschool age{p_end}
{synopt :{opth primaryage(varname)}}Dummy variable =1 if primary age{p_end}
{synopt :{opth secondaryage(varname)}}Dummy variable =1 if secondary age{p_end}
{synopt :{opth tertiaryage(varname)}}Dummy variable =1 if tertiary age{p_end}
{synopt :{opth pub:lic(varlist)}}Variable =0 if attends private, =1 if attends public, missing if does not attend school{p_end}

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
{synopt :{opth sheet(string)}}Name of sheet to write results. Default is "E20. Edu Enrollment Rates"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Description}

{pstd} 
{cmd:ceqeduc} calculates education enrollment rates, including both net and gross 
enrollment rates by income group. These indicators are calculated at four levels of
education: preschool, primary, secondary, and tertiary. The data set must be at 
the individual level, and should include dummy variables equal to one if the individual
attended a particular level of education (these are supplied in the {opth pre:school(varname)}, {opth pri:mary(varname)}, {opth sec:ondary(varname)}, 
{opth ter:tiary(varname)} options), and dummy variables equal to one if the individual's
age corresponds to the target age cohort for that level of education (these are 
supplied in the {opth preschoolage(varname)}, {opth primaryage(varname)},
 {opth secondaryage(varname)}, 
{opth tertiaryage(varname)} options). Finally, the {opth pub:lic(varname)} option 
is used to indicate if the individual attends public school (equal to 1), private 
school (equal to 0), or does not attend school (missing value).

{pstd} 
Income groups are defined by each of the 
core income concepts, which 
include market income, market income plus pensions, net market income, gross income, taxable income, 
disposable income, consumable income, and final income. The variables for these income concepts, which 
should be expressed in local currency units (preferably {bf:per year} for ease of comparison with 
totals from national accounts), are indicated using the {opth m:arket(varname)}, 
{opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, 
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options. 

{pstd}
The income variables should be expressed in household per capita or per adult equivalent 
terms, regardless of whether the data set being used is at the household or individual level. Hence, they should 
have the same per-person amount for each member within a household when using individual-level data.

{pstd}
The income group cut-offs of these groups 
can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are 
ultra-poor (less than $1.25 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor 
($1.25 to $2.50 PPP per day), moderate poor ($2.50 to $4 PPP per day), vulnerable ($4 to $10 PPP per 
day), middle class ($10 to $50 PPP per day) and wealthy ($50 and more PPP per day). For example, specify {cmd:cut1(1.90)} to 
change the first cut-off to $1.90 PPP per day (which would cause the lowest group to become less than 
$1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second 
cut-off is maintained--to range from $1.90 to $2.50 PPP).

{pstd}
{cmd: ceqeduc} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
using {help svyset} since {cmd:ceqeduc} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqeduc} prints to the sheet titled "E20. Edu Enrollment Rates"; the user can override the sheet name using the 
{opt sheet(string)} option.
Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqeduc} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. To produce only a portion of the results, specify only a 
subset of the income concept options or use {opt nod:ecile}, {opt nog:roup}, {opt noc:entile}, or 
{opt nob:in}.

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{phang} {cmd:. ceqeduc [pw=w] using C:/MWB2016_E20.xlsx, preschool(attends_pre) primary(attends_prim) secondary(attends_sec)  ///}{p_end}
{phang} {cmd:. tertiary(attends_ter) preschoolage(age_pre) primaryage(age_prim) secondaryage(age_sec) tertiaryage(age_ter) public(attends_pub) ///}{p_end}
{phang} {cmd:. psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Osorio, R. 2007. "{bf:quantiles}: Stata module to categorize by quantiles." Boston
College Department of Economics Statistical Software Components S456856.{p_end}

