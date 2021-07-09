{smcl}
{* 04mar2017}{...}
{cmd:help ceqtarget} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqtarget} {hline 2} Computes indicators on coverage and leakages for fiscal 
interventions (taxes, transfers, and subsidies) by income group for the "E19. Coverage (Target)" sheets of the CEQ Master Workbook 2016 Section E

{title:Syntax}

{p 8 11 2}
    {cmd:ceqtarget} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

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

{syntab:Direct Beneficiary Markers}
{synopt :{opth recp:ensions(varlist)}}Contributory pension recipients{p_end}
{synopt :{opth recdtr:ansfers(varlist)}}Direct transfer recipients{p_end}
{synopt :{opth paydtax:es(varlist)}}Direct tax payers{p_end}
{synopt :{opth payco:ntribs(varlist)}}Contribution payers{p_end}
{synopt :{opth recsu:bsidies(varlist)}}Subsidy recipients{p_end}
{synopt :{opth payindtax:es(varlist)}}Indirect tax payers{p_end}
{synopt :{opth rechealth(varlist)}}Health recipients{p_end}
{synopt :{opth receduc:ation(varlist)}}Education recipients{p_end}
{synopt :{opth recother:public(varlist)}}Other public in-kind transfers{p_end}
{synopt :{opth payuserfeesh:ealth(varlist)}}Health user fees payers{p_end}
{synopt :{opth payuserfeese:duc(varlist)}}Education user fees payers{p_end}
{synopt :{opth payuserfeeso:ther(varlist)}}Other public user fees payers{p_end}

{syntab:Target Beneficiary Markers}
{synopt :{opth trecp:ensions(varlist)}}Contributory pension target recipients{p_end}
{synopt :{opth trecdtr:ansfers(varlist)}}Direct transfer target recipients{p_end}
{synopt :{opth tpaydtax:es(varlist)}}Direct tax target payers{p_end}
{synopt :{opth tpayco:ntribs(varlist)}}Contribution target payers{p_end}
{synopt :{opth trecsu:bsidies(varlist)}}Subsidy target recipients{p_end}
{synopt :{opth tpayindtax:es(varlist)}}Indirect tax target payers{p_end}
{synopt :{opth trechealth(varlist)}}Health target recipients{p_end}
{synopt :{opth treceduc:ation(varlist)}}Education target recipients{p_end}
{synopt :{opth trecother:public(varlist)}}Other public in-kind transfers{p_end}
{synopt :{opth tpayuserfeesh:ealth(varlist)}}Health user fees target payers{p_end}
{synopt :{opth tpayuserfeese:duc(varlist)}}Education user fees target payers{p_end}
{synopt :{opth tpayuserfeeso:ther(varlist)}}Other public user fees target payers{p_end}


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
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E18.m Coverage Tables"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E18.m+p Coverage Tables"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E18.n Coverage Tables"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E18.g Coverage Tables"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E18.t Coverage Tables"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E18.d Coverage Tables"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E18.c Coverage Tables"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E18.f Coverage Tables"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Description}

{pstd} 
{cmd:ceqtarget} calculates coverage and leakage indicators among target beneficiaries or payers by income group for 
fiscal interventions (taxes, transfers, and subsidies), 
where income groups are defined holding the income concept fixed within each sheet. Hence, 
{cmd:ceqtarget} produces one sheet for each of the CEQ core income concepts; the income concept 
defining the ranking of each sheet will be referred to in this help file as the ranking variable. 
The coverage and leakage indicators include total benefits by group, the distribution 
of benefits (what percent of benefits goes to each group), the number of direct beneficiaries
(i.e., the person who directly receives the transfer or directly pays the tax), the 
number of beneficiary 
households, the number of direct and indirect beneficiaries (i.e., members of 
beneficiary households), the distribution of beneficiary households and direct and 
indirect beneficiaries (what percent of beneficiaries belong to each group), coverage 
within each group (what percent of households or people in that group receive 
benefits), and mean benefits (per beneficiary household and per beneficiary).

{pstd}
The CEQ core income concepts include market income, market income plus pensions, net 
market income, gross income, taxable income, disposable income, consumable income, and final 
income. The variables for these income concepts, which should be expressed in local currency 
units (preferably {bf:per year} for ease of comparison with totals from national accounts), are 
indicated using the {opth m:arket(varname)}, {opth mp:luspensions(varname)}, 
{opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth t:axable(varname)}, 
{opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth c:onsumable(varname)}, 
and {opth f:inal(varname)} options. 

{pstd}
The income and fiscal intervention variables should be expressed in household per capita or per adult equivalent 
terms, regardless of whether the data set being used is at the household or individual level. Hence, they should 
have the same per-person amount for each member within a household when using individual-level data.

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
{opth health(varlist)}, education benefits by {opth educ:ation(varlist)}, and other public in-kind 
benefits by {opth other:public(varlist)}, health user fees by {opth userfeesh:ealth(varlist)},
education user fees by {opth userfeese:duc(varlist)}, and other public user fees by
{opth userfeeso:ther(varlist)}. Tax, contribution and user fees variables may be saved as 
either positive or negative values, as long as one is used consistently for all tax, contribution and user fees
variables. The {opth health(varlist)}, {opth educ:ation(varlist)} and {opth other:public(varlist)} options 
need to be specfied with fiscal intervention variable(s) that are net of user fee(s). The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.
If any of these variables is negative for any households due to user fees exceeding gross benefits, the negative values should be truncated at 0. 
The user fee options are designed solely to separately analyze the distribution of usre fees and will not be used in calculating 
net health/education/other public transfers. See the example section for more detail.

{pstd} 
Note that to estimate the number of direct beneficiaries
(i.e., the person who directly receives the transfer or directly pays the tax),
an additional piece of information is needed: which individuals in the household
directly received a particular transfer or directly paid a particular tax.
This information cannot be obtained from the fiscal interventions variables described
above, since those variables are already at the household per capita level, i.e., they
would be positive for all direct *and indirect* beneficiaries (other members of
the direct beneficiary's household). Thus, this command includes the "direct beneficiary
marker" options where, for each fiscal intervention variable given in the fiscal
intervention options, a variable identifying which individuals are direct beneficiaries
(or payers) of that fiscal intervention is given. 
These options are {opth recp:ensions(varlist)} for direct beneficiaries
of contributory pensions (where the "rec" prefix on the option is short for
"recipient"); {opth recdtr:ansfers(varlist)} for direct beneficiaries 
of direct transfers; 
{opth paydtax:es(varlist)} for direct payers of direct taxes;
{opth payco:ntribs(varlist)} for direct payers of contributions;
{opth recsu:bsidies(varlist)} for direct beneficiaries of subsidies;
{opth payindtax:es(varlist)} for direct payers of indirect taxes;
{opth receduc:ation(varlist)} for direct beneficiaries of education benefits;
{opth rechealth(varlist)} for direct beneficiaries of health benefits;
{opth recother:public(varlist)} for direct beneficiaries of other public benefits;
{opth payuserfeese:duc(varlist)} for direct payers of education user fees;
{opth payuserfeesh:ealth(varlist)} for direct payers of health user fees; and
{opth payuserfeeso:ther(varlist)} for direct payers of other user fees.

{pstd} 
Finally, variables marking the target beneficiaries or target payers are needed. These variables equal 1 for any individual who is eligible for a program or to pay a tax according to program rules or the stated target group; these variables are independent of whether the individual actually receives benefits.
These options are {opth trecp:ensions(varlist)} for target beneficiaries
of contributory pensions (where the "trec" prefix on the option is short for
"target recipient"); {opth trecdtr:ansfers(varlist)} for target beneficiaries 
of direct transfers; 
{opth tpaydtax:es(varlist)} for target payers of direct taxes;
{opth tpayco:ntribs(varlist)} for target payers of contributions;
{opth trecsu:bsidies(varlist)} for target beneficiaries of subsidies;
{opth tpayindtax:es(varlist)} for target payers of indirect taxes;
{opth treceduc:ation(varlist)} for target beneficiaries of education benefits;
{opth trechealth(varlist)} for target beneficiaries of health benefits;
{opth trecother:public(varlist)} for target beneficiaries of other public benefits;
{opth tpayuserfeese:duc(varlist)} for target payers of education user fees;
{opth tpayuserfeesh:ealth(varlist)} for target payers of health user fees; and
{opth tpayuserfeeso:ther(varlist)} for target payers of other user fees.

{pstd}
For a data set at the individual level,
the variables supplied to the direct beneficiary marker options should be 
dummy variables that equal 1 if
the individual is a direct beneficiary/payer and 0 otherwise.
For a data set at the household level, they should equal the number of household
members that are direct beneficiaries/payers.
For each category of fiscal intervention, the number of variables supplied to these 
options must be the same as the number of variables supplied to the corresponding
fiscal intervention variables, and they should be supplied in the same order.
For example, suppose the data set is at the individual level,
there are two levels of education: primary and secondary, 
and that household per capita benefits are included in {cmd:pc_primary} and 
{cmd:pc_secondary}, and
dummy variables identifying which individuals are the direct beneficiaries are 
{cmd:db_primary} and {cmd:db_secondary}. Then the fiscal intervention and direct beneficiary
marker options for education would be 
{cmd:educ(pc_primary pc_secondary) receduc(db_primary db_secondary)}.
For fiscal interventions for which the survey does not specify who is the direct
beneficiary (e.g., if a question only asks whether anyone in the household receives
benefits from a program), mark one member of the household (e.g. the head) as a direct beneficiary.

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
{cmd: ceqtarget} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
using {help svyset} since {cmd:ceqtarget} automatically uses the information specified using {help svyset}. 
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and 
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqtarget} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqtarget} prints to the sheets titled "E18.X Coverage Tables" where X indicates the 
income concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the 
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)}, 
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options, 
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master 
Workbook populated with results from {cmd:ceqtarget} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. 

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqtarget [pw=w] using C:/MWB2016_E18.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) ///}{p_end}
{phang} {cmd:. n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions) 	dtax(income_tax property_tax) 	cont(employee_contrib employer_contrib) ///}{p_end}
{phang} {cmd:. dtransfer(cct noncontrip_pens unemployment scholarships food_transfers) 	indtax(vat excise) 	subsidies(energy_subs) 	///}{p_end}
{phang} {cmd:. health(net_basic_health net_preventative_health net_inpatient_health) 	///}{p_end}
{phang} {cmd:. education(net_daycare net_preschool net_primary net_secondary net_tertiary)  ///}{p_end}
{phang} {cmd:. userfeeshealth(user_feesh) userfeeseduc(user_feesed)	recpens(db_pensions) 	paydtax(db_income_tax db_property_tax) 	///}{p_end}
{phang} {cmd:. paycont(db_employee_contrib db_employer_contrib) 	recdtransfer(db_cct db_noncontrip_pens db_unemployment db_scholarships db_food_transfers) ///}{p_end}
{phang} {cmd:. payindtax(db_vat db_excise) 	recsubsidies(db_energy_subs) 	rechealth(db_basic_health db_preventative_health db_inpatient_health) ///}{p_end}
{phang} {cmd:. receduc(db_daycare db_preschool db_primary db_secondary db_tertiary) payuserfeesh(db_user_feesh) payuserfeese(db_user_feesed) ///}{p_end}
{phang} {cmd:. trecpens(t_pensions) 	tpaydtax(t_income_tax t_property_tax) 	tpaycont(t_employee_contrib t_employer_contrib)  ///}{p_end}
{phang} {cmd:. trecdtransfer(t_cct t_noncontrip_pens t_unemployment t_scholarships t_food_transfers) 	tpayindtax(t_vat t_excise) 	///}{p_end}
{phang} {cmd:. trecsubsidies(t_energy_subs) 	trechealth(t_basic_health t_preventative_health t_inpatient_health) ///}{p_end}
{phang} {cmd:. treceduc(t_daycare t_preschool t_primary t_secondary t_tertiary) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}
