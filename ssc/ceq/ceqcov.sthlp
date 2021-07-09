{smcl}
{* 16nov2016}{...}
{cmd:help ceqcov} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqcov} {hline 2} Computes covariance of the CEQ core income concepts and fiscal interventions, for the "E15. Covariance" sheet of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqcov} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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

{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheet(string)}}Name of sheet to write results. Default is "E15. Covariance"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 


{title:Description}

{pstd} 
{cmd:ceqcov} calculates the covariance between core income concepts or fiscal 
interventions and fractional rank in the income distribution. These covariances
are useful because they are a building block of the calculation of the Gini coefficient
and concentration coefficients.

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
{opth health(varlist)}, educaiton benefits by {opth educ:ation(varlist)}, other public in-kind 
benefits by {opth other:public(varlist)}, health user fees by {opth userfeesh:ealth(varlist)},
education user fees by {opth userfeese:duc(varlist)}, and other public user fees by
{opth userfeeso:ther(varlist)}. Tax and contribution variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax and contribution 
variables. The same goes for user fees variables. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
The core income concepts include market income, market income plus pensions, net market income, gross 
income, taxable income, disposable income, consumable income, and final income. The variables for 
these income concepts, which should be expressed in local currency units (preferably {bf:per year} for 
ease of comparison with totals from national accounts), are indicated using the 
{opth m:arket(varname)}, {opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, 
{opth g:ross(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, 
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
There are two options for including information about weights and survey sample design so that the 
poverty estimates and p-values are calculated correctly. The sampling weight can be entered using 
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered 
using {help svyset} since {cmd:ceqcov} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqcov} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Negative incomes are allowed, but a warning is issued for each core income concept and fiscal intervention that 
has negative values (or positive values when a fiscal intervention is stored as negative values). This is because 
various measures are no longer well-behaved when negative values are included (for example, the Gini coefficient, 
concentration coefficient, or squared poverty gap can exceed 1, and other desirable properties of these measures 
when incomes are non-negative no longer hold when negative values are allowed).

{pstd}
Results are automatically exported to the CEQ Master Workbook if {cmd:using} 
{it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By default, 
{cmd:ceqcov} prints to a sheet titled "E1. Descriptive Statistics"; the user can override the sheet 
name using the {opt sheet(string)} option. Exporting directly to the Master Workbook requires Stata 13 
or newer. The Master Workbook populated with results from {cmd:ceqcov} can be automatically opened if 
the {opt open} option is specified (in this case, {it:filename} cannot have spaces). Results are also 
saved in matrices available from {cmd:return list}. 

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqcov [pw=w] using C:/MWB2016_E15.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary)  userfeeshealth(ufee_basichealth ufee_impatienthealth) userfeeseduc(ufee_daycare ufee_preschool ufee_primary)}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqcov [pw=w] using C:/MWB2016_E15.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) 	dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	health(basic_health preventative_health inpatient_health) 	education(daycare preschool primary secondary tertiary)  userfeeshealth(ufee_basichealth ufee_impatienthealth) userfeeseduc(ufee_daycare ufee_preschool ufee_primary)}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}

