{smcl}
{* 15aug2017}{...}
{cmd:help fi_fgp} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:fi_fgp} {hline 2} Calculates the measures of fiscal impoverishment and fiscal gains to the poor from Higgins and Lustig (2016).


{pstd}
Use {cmd:fi_fgp} with the {helpb fi_fgp graph} sub-command for graphing options.


{title:Syntax}

{p 8 11 2}
    {cmd:fi_fgp} varlist(min=2 max=2) {ifin} {weight}  [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}


{synopt :{opt z(real)}}Poverty line{p_end}
{syntab:Produce results}
{synopt :{opt head:count}}Produce results for FI and FGP headcounts{p_end}
{synopt :{opt tot:al}}Produce results for total FI and FGP{p_end}
{synopt :{opt per:capita}}Produce results for per capita FI and FGP{p_end}
{synopt :{opt norm:alized}}Produce results for per capita FI and FGP normalized by the poverty line{p_end}
{synopt :{opt kapp:a(real)}}Produce results for total FI and FGP scaled inputed real number{p_end}
{synopt :{opt norat:io}}Excludes FI to FGP ratio from being produced{p_end}
{synopt :{opt dec:omp}}Produces decomposition of FI and FGP{p_end}

{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency (the default){p_end}

{syntab:Level of Results}
{synopt :{opt hh:ouse}}Indicates if the data set is at the household level{p_end}
{synopt :{opt ind:ivid}}Indicates if the data set is at the individual level{p_end}
{synopt :{opt DISPLAYI:nd}}Returns results at individual level if data set is at household level{p_end}
{synopt :{opt hs:ize(varname)}}Number of members in the household
	(should be used when each observation in the data set is a household){p_end}

   


{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions
   
{synoptline}		
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 


{title:Description}

{pstd} 
{cmd:fi_fgp} calculates the measures of fiscal impoverishment (FI) and fiscal gains to the poor (FGP) 
derived in Higgins and Lustig (2016). The measures include FI and FGP headcounts (where the denominator is the total 
population); total FI and FGP (in dollars per day adjusted for purchasing power parity [PPP]); FI and 
FGP per capita (in PPP dollars per day), where k=1/|S| and S is the set of individuals in society with 
cardinality |S| (i.e. total FI or FGP is divided by the total population); normalized FI and FGP, 
where k = 1/(|S|z) and z is the poverty line (i.e., per capita FI or FGP as a proportion of the poverty 
line); FI and FGP scaled by some scalar kappa of the users choice. The ratio of fiscal impoverishment 
over fiscal gains for the poor (FI/FGP) is automatically displayed unless the user indicates otherwise
with the option {opt norat:io} or the user calls for {opt head:count}.

{pstd}
The poverty line in PPP dollars per day can be set using the {opth z(real)} option; the commonly-used poverty lines are $1.25, $2.50, and 
 $4 PPP. Local currency poverty lines can be entered as real numbers (for poverty lines that are fixed for the entire
 population) and should be in the same units as the income concept variables (preferably local currency units 
 per year). 

{pstd}
{cmd: fi_fgp} can convert local currency variables to PPP dollars, using the PPP conversion 
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
If the data set is at the household level (each observation is an household), the option {opth hh:ouse}
should be specified to indicate this to the program. In this scenario the variable with the size of each household 
should be specified in the {opth hs:ize(varname)} option. If the user wants the results to be returned at the
individual level they must specify the {opth displayi:nd} option, which will multiply the household sampling weights
with the household size. Therefore the user never needs to do this prior to running the programming. If the data set 
is at the individual level, this should be specified with the {opth ind:ivid} option. If this is called with the 
{opth displayi:nd} a warning will be produced.

{pstd}
By default, {cmd: fi_fgp} does not allow income concept or fiscal intervention variables to have missing 
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


{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual). Estimating the total FI and FGP.
Poverty line set to be 2.5 PPP $ per day.{p_end}
{phang} {cmd:. fi_fgp ym yc [pw=w] , z(2.5) individ total}{p_end}

{pstd}Household-level data (each observation is a household). Estimating thr normalized FI
and FGP. Poverty line set to be 1.25 PPP $ per day. {p_end}
{phang} {cmd:. fi_fgp ym yf [pw=w] , z(1.25) hhouse normalized hs(hhsize)}{p_end}

{pstd}Individual-level data (each observation is an individual). Estimating per capita FI and FGP 
with option to display the decomposition. Poverty line set to be 4 PPP $ per day.{p_end}
{phang} {cmd:. fi_fgp ymp yc [pw=w] , z(4) individ perc dec}{p_end}

{pstd}Household-level data (each observation is a household). Estimating FI and FGP headcounts
with the option to display the decomposition. Poverty line set to be 1.25 PPP $ per day. {p_end}
{phang} {cmd:. fi_fgp ym yf [pw=w] , z(1.25) hhouse head dec hs(hhsize)}{p_end}

{pstd}Individual-level data (each observation is an individual). Estimating FI and FGP per capita with the 
option to display the decomposition and omit the ratio FI/FGP. Poverty line set to be 4 PPP $ per day.{p_end}
{phang} {cmd:. fi_fgp ymp yc [pw=w] , z(4) per dec noratio}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, UC Berkeley, seanhiggins@berkeley.edu


{title:References}

{phang}
Higgins, Sean and Nora Lustig. 2016. {browse "http://www.sciencedirect.com/science/article/pii/S0304387816300220":"Can a Poverty-Reducing and Progressive Tax and Transfer System Hurt the Poor?"} Journal of Development Economics 122, 63-75.{p_end}


