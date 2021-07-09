{smcl}
{* 3/4/2016}{...}
{cmd:help ceqrace}{beta version; please report bugs} {right:Rodrigo Aranda}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqrace} {hline 2} Produces results tables for Ethno Racial Master Workbook under Commitment to Equity (CEQ) framework{p_end}

{title:Syntax}

{p 8 11 2}
    {cmd:ceqrace} using({it:filename}) {weight} {ifin} [{cmd:,}table({it:name}) {it:options}] {break}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{cmd:Tables}}
{synopt:{cmd:f3}} Ethno-Racial Populations{p_end}
{synopt:{cmd:f5}} Population Composition{p_end}										
{synopt:{cmd:f6}} Income Distribution{p_end}									
{synopt:{cmd:f7}} Summary Poverty Rates{p_end}							
{synopt:{cmd:f8}} Summary Poverty Gap Rates{p_end}						
{synopt:{cmd:f9}} Summary Poverty Gap Squared Rates{p_end}						
{synopt:{cmd:f10}} Summary Inequality Indicators{p_end}				
{synopt:{cmd:f11}} Mean Incomes{p_end}							
{synopt:{cmd:f12}} Incidence by Decile{p_end}										
{synopt:{cmd:f13}} Incidence by Socioeconomic Group{p_end}										
{synopt:{cmd:f16}} Fiscal Profile{p_end}											
{synopt:{cmd:f17}} Coverage Rates (Totals){p_end}											
{synopt:{cmd:f18}} Coverage Rates (Targets){p_end}										
{synopt:{cmd:f20}} Mobility Matrices{p_end}											
{synopt:{cmd:f21}} Education (populations){p_end}											
{synopt:{cmd:f23}} Educational Probability{p_end}												
{synopt:{cmd:f24}} Infrastructure Access{p_end}											
{synopt:{cmd:f25}} Theil Disaggregation	{p_end}										
{synopt:{cmd:f26}} Inequality of Opportunity{p_end}											
{synopt:{cmd:f27}} Significance{p_end}										
{synopt :{opt open}}Automatically open CEQ Ethno Racial Master Workbook with new results added{p_end}

{syntab:{cmd:Ethno-Racial groups}}

{synopt :{opth race1(varname)}}Indigenous Population{p_end}
{synopt :{opth race2(varname)}}White/Non-Ethnic Population{p_end}
{synopt :{opth race3(varname)}}African Descendant Population{p_end}
{synopt :{opth race4(varname)}}Other Races/Ethnicities{p_end}
{synopt :{opth race5(varname)}}Non-Responses{p_end}

{syntab:{cmd:Income Concepts}}
{synopt :{opth o:riginal(varname)}}Original income{p_end}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mplusp:ensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth n:etmarket(varname)}}Net market income{p_end}
{synopt :{opth g:ross(varname)}}Gross income{p_end}
{synopt :{opth taxab:le(varname)}}Taxable income{p_end}
{synopt :{opth d:isposable(varname)}}Disposable income{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:{cmd:Tax and Transfer Concepts}}
{synopt :{opth dtax:(varname)}}Direct Taxes{p_end}
{synopt :{opth cont:rib(varname)}}Contributions{p_end}
{synopt :{opth conyp:ensions(varname)}}Contributory Pensions{p_end}
{synopt :{opth contp:ensions(varname)}}Contributions to Pensions{p_end} 
{synopt :{opth nonc:ontrib(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth flagcct:(varname)}}Flagship CCT{p_end}
{synopt :{opth otran:sfers(varname)}}Other Direct Transfers{p_end}
{synopt :{opth isub:sidies(varname)}}Indirect Subsidies{p_end}
{synopt :{opth itax:(varname)}}Indirect Taxes{p_end}
{synopt :{opth ike:duc(varname)}}In-kind Education{p_end}
{synopt :{opth ikh:ealth(varname)}}In-kind Health{p_end}
{synopt :{opth hu:rban(varname)}}Housing and Urban{p_end}

{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency (the default){p_end}

{syntab:Poverty lines}
{synopt :{opth next:reme(string)}}National Extreme Poverty Line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth nmod:erate(string)}}National Moderate Poverty Line in same units as income variables (can be a scalar or {varname}){p_end}

{syntab:Income group cut-offs}
{synopt :{opth cut1(real)}}Upper bound income for ultra-poor; default is $1.25 PPP per day{p_end}
{synopt :{opth cut2(real)}}Upper bound income for extreme poor; default is $2.50 PPP per day{p_end}
{synopt :{opth cut3(real)}}Upper bound income for moderate poor; default is $4 PPP per day{p_end}
{synopt :{opth cut4(real)}}Upper bound income for vulnerable; default is $10 PPP per day{p_end}
{synopt :{opth cut5(real)}}Upper bound income for middle class; default is $50 PPP per day{p_end}

{syntab:{cmd:Coverage}}
{synopt :{opth cct:(varname)}}Conditional Cash Transfers{p_end}
{synopt :{opth nonc:ontrib(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth pens:ions(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth unem:ploy(varname)}}Unemployment Benefits {p_end}
{synopt :{opth foodt:ransfers(varname)}}Food Transfers{p_end}
{synopt :{opth otran:sfers(varname)}}Other Direct Transfers{p_end}
{synopt :{opth health(varname)}}Health{p_end}
{synopt :{opth pen:sions(varname)}}Pensions{p_end}
{synopt :{opth sch:olarships(varname)}}Scholarships{p_end}
{synopt :{opth tarcct(varname)}}Conditional Cash Transfers Target Population{p_end}
{synopt :{opth tarncp(varname)}}Non Contributory Pensions Target Population{p_end}
{synopt :{opth tarpen(varname)}}Pensions Target Population{p_end}

{syntab:{cmd:Education}}
{synopt :{opth age:(varname)}}Age{p_end}
{synopt :{opth edpre:(varname)}}Pre-School{p_end}
{synopt :{opth redpre:(varname)}}Pre-School Age Range (1 if is in range){p_end}
{synopt :{opth edpri:(varname)}}Primary School{p_end}
{synopt :{opth redpri:(varname)}}Primary School Age Range (1 if is in range){p_end}
{synopt :{opth edsec:(varname)}}Secondary School {p_end}
{synopt :{opth redsec:(varname)}}Secondary School Age Range (1 if is in range){p_end}
{synopt :{opth edter:(varname)}}Terciary School {p_end}
{synopt :{opth redter:(varname)}}Terciary School Age Range (1 if is in range) {p_end}
{synopt :{opth edpub:lic(varname)}}Public School {p_end}
{synopt :{opth edpriv:ate(varname)}}Private School {p_end}
{synopt :{opth attend:(varname)}}Attends School {p_end}


{syntab:{cmd:Infrastructure Access (Dichotomous Variables)}}
{synopt :{opth water:(varname)}}Water{p_end}
{synopt :{opth electricity:(varname)}}Electricity{p_end}
{synopt :{opth walls:(varname)}}Walls{p_end}
{synopt :{opth floors:(varname)}}Floors{p_end}
{synopt :{opth roof:(varname)}}Roof{p_end}
{synopt :{opth sewage:(varname)}}Sewage{p_end}
{synopt :{opth roads:(varname)}}Roads{p_end}
		   
{syntab:{cmd:Household}}
{synopt :{opth hhe:ad(varname)}}Household head identifier {p_end}
{synopt :{opth hhid:(varname)}}Household ID {p_end}
				
{syntab:{cmd:Circumstance}}
{synopt :{opth gender(varname)}}Gender{p_end}
{synopt :{opth ur:ban(varname)}}Urban Identifier{p_end}
{synopt :{opth edpar:(varname)}}Parent's Education {p_end}

{syntab:{cmd:Survey Information}}
{synopt :{opth hs:ize(varname)}}Number of members in the household{p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling designs); can also be set using {help svyet:svyset}{p_end}
   	
{hline}

{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Description}
{pstd}
{cmd:ceqrace} Produces results by race or ethnicity based on Commitment to Equity (CEQ) framework, the 20 tables of the Ethno-racial Workbook can be estimated separately and saved in the Excel file specified in {it:using(filename)}.
{p_end}
{pstd} 
The variables given by {opth race(varname)} must be dummy variables that identify different races or groups in the intended order where up to five variables are allowed, and the ordering in the Ethno-racial Workbook is taken as reference.
{p_end}
{pstd} 
This program uses the {cmd:table({it:name})} option to identify which table to generate and uses the {cmd:putexcel} command to export to Excel. Options vary depending on the table that is being exported (for more information see below in section {cmd:Tables and Examples}.
{p_end}
{pstd} 
This program uses the following built in programs from DASP {cmd: digini}, {cmd: dientropy} and {cmd: dinineq}. It uses {cmd: ineqdeco} and {cmd: ceq} as well.
{p_end}
{pstd}
{cmd:All monetary values must be in per capita monthly LCU.}
{p_end}
{pstd}
Poverty lines are used for poverty results; for results by income group, the cut-offs of these groups can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are ultra-poor ($0 to $1.25 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor ($1.25 to $2.50 PPP per day), moderate poor ($2.50 to $4 PPP per day), vulnerable ($4 to $10 PPP per day), middle class ($10 to $50 PPP per day) and wealthy ($50 and more PPP per day). For example, specify {cmd:cut1(1.90)} to change the first cut-off to $1.90 PPP per day (which would cause the lowest group to range from $0 to $1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second cut-off is maintained--to range from $1.90 to $2.50 PPP).
{p_end}
{pstd}
{cmd: ceqrace} automatically converts local currency variables to PPP dollars, using the PPP conversion 
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
{p_end}
{hline}

{title:Tables and examples}
{syntab:{cmd:F3.-  Ethno-Racial Populations}}	Variables in {varlist}, and [{weight}] are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace  [pw=weight] using CEQ_Ethno_Racial_Workbook.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f3) }{p_end}
 
{syntab:{cmd:F5.- Population Composition}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f5) o(y_m) d(y_d) hhid(hhid) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F6.- Distribution}} Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f6) o(y_m) d(y_d) hhid(hhid) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F7.- Poverty}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f7) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F8.- Poverty Gap}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f8) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F9.- Poverty Gap Squared}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f9) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F10.- Inequality}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)} are required..
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f10) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f)} {p_end}

{syntab:{cmd:F11.- Mean Income}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) table(f11)m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f)} {p_end}

{syntab:{cmd:F12.- Incidence (Decile)}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, 
{opth dtax:(varname)}, {opth cont:ributions(varname)}, {opth contp:ensions(varname)}, {opth contyp:ensions(varname)}, {opth nonc:ontributory(varname)}, {opth flagcct:(varname)}, {opth otran:sfers(varname)}, {opth isub:sidies(varname)}, {opth itax:(varname)}, {opth ike:ducation(varname)},
{opth ikh:ealth(varname)}, {opth hu:rban(varname)},  {opth hhid(varname)}, are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f12) o(y_m) m(y_m) contp(contp) conyp(conyp) mplusp(y_mp) dtax(dtax) n(y_nm) nonc(nonc) flagcct(fcct) otran(otran) g(y_g) taxab(y_taxab) d(y_d) isub(isub) itax(itax) c(y_c) ike(ik_e) ikh(ik_h) hu(hu) f(y_f) hhid(hhid)}{p_end}

{syntab:{cmd:F13.- Incidence (income groups)}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, 
{opth dtax:(varname)}, {opth cont:ributions(varname)}, {opth contp:ensions(varname)}, {opth contyp:ensions(varname)}, {opth nonc:ontributory(varname)}, {opth flagcct:(varname)}, {opth otran:sfers(varname)}, {opth isub:sidies(varname)}, {opth itax:(varname)}, {opth ike:ducation(varname)},
{opth ikh:ealth(varname)}, {opth hu:rban(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f13) o(y_m) m(y_m) contp(contp) contyp(contyp) mplusp(y_mp) dtax(dtax) n(y_nm) nonc(nonc) flagcct(fcct) otran(otran) g(y_g) taxab(y_taxab) d(y_d) isub(isub) itax(itax) c(y_c) ike(ik_e) ikh(ik_h) hu(hu) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F16.-  Fiscal Profile}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth age(varname)}, {opth pens:ions(varname)}, {opth hhe(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f16) o(y_m) d(y_d) c(y_c) pens(pensions) hhe(hhe_id) hhid(hh_id)        ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F17.- Coverage (Total)}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth cct:(varname)}, {opth nonc:ontrib(varname)}, {opth unem:ploy(varname)}, {opth foodt:ransf(varname)}, {opth otran:sfers(varname)}, 
{opth hea:lth(varname)},  {opth pensions(varname)},  {opth hhe(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f17) o(y_m) cct(cct) nonc(nonc) unem(unemployment) foodt(f_tran) otran(o_tran) hea(health) pen(pensions) hhe(hhe_id) hhid(hh_id) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F18.- Coverage (target)}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth cct:(varname)}, {opth nonc:ontrib(varname)}, {opth pen:sions(varname)},  {opth hhe(varname)}, {opth hhid(varname)},  {opth tarcct(varname)}, {opth tarncp(varname)}, {opth tarpen(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f18) o(y_m) cct(cct) nonc(nonc) pen(pensions) hhe(hhe_id) hhid(hh_id)        tarncp(tncp) tarcct(tcct) tarpen(tpen) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F20.- Mobility}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f20) o(y_m) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F21.- Education (populations)}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth edpre:(varname)}, {opth edpri:(varname)}, {opth edsec:(varname)}, 
{opth edter:(varname)}, {opth redpre:(varname)}, {opth redpri:(varname)}, {opth redsec:(varname)}, {opth redter:(varname)}, {opth edpub:lic(varname)}, {opth edpriv:ate(varname)}, and {opth attend:(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f21) o(y_m) edpre(ed_pre) edpri(ed_pri) edsec(ed_sec) edter(ed_ter)        attend(attendschool) redpre(red_pre) redpri(red_pri) redsec(red_sec) redter(red_ter) hhe(id_hhead) hhid(id_hh) edpriv(private) edpub(public)}{p_end}

{syntab:{cmd:F23.- Educational Probability}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth edpre:(varname)}, {opth edpri:(varname)}, {opth edsec:(varname)}, 
{opth edter:(varname)}, {opth redpre:(varname)}, {opth redpri:(varname)}, {opth redsec:(varname)}, {opth redter:(varname)}, {opth attend:(varname)}, {opth hhid:(varname)}, and {opth hhe:ad(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f23) o(y_m) edpre(ed_pre) edpri(ed_pri) edsec(ed_sec) edter(ed_ter)        attend(attendschool) redpre(red_pre) redpri(red_pri) redsec(red_sec) redter(red_ter) hhid(id_hh) hhe(id_hhead) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F24.- Infraestructure Access}}	Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth hhid:(varname)}, {opth hhe:ad(varname)}, {opth water:(varname)}, {opth electricity:(varname)}, {opth walls:(varname)},
{opth floors:(varname)}, {opth roof:(varname)}, {opth sewage:(varname)}, {opth roads:(varname)},and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f24) o(y_m) hhid(id_hh) hhe(id_hhead) water(water) electricity(elect)        walls(walls) floors(floors) roof(roof) sewage(sewage) roads(roads) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F25.- Theil Decomposition}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, 
{opth gender(varname)}, {opth ur:ban(varname)}, and {opth edpar:(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f25) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) gender(sex) urban(rururb) edpar(parentsed)}{p_end}

{syntab:{cmd:F26.- Inequality of Opportunity}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)},  
 {opth gender(varname)}, {opth ur:ban(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f26) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) gender(sex) urban(rururb)}{p_end}

{syntab:{cmd:F27.- Significance}}	Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth psu(varname)}, {opth s:trata(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f27) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c)        f(y_f) psu(upm) strata(strata) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}



{hline}
{p 4 4 2}

{title:Author}

{p 4 4 2}Rodrigo Aranda, Tulane University, raranda@tulane.edu

{title:References}

{pstd}Commitment to Equity (CEQ) Handbook, which describes the income concepts and contents of CEQ Master Workbook:{p_end}
{phang2}
{browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." CEQ Working Paper 1.}{p_end}

{pstd}Commitment to Equity {browse "http://www.commitmentoequity.org":website}{p_end}

{pstd}Fiscal Policy and the Ethno-racial Divide in Bolivia, Brazil, Guatemala and Uruguay (Working document) {p_end}
{hline}
