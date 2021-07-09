{smcl}
{* 12jan2018}{...}
{cmd:help fpimpov}{right:version:  1.0.0}
{hline}

{title:Title}

{p 4 8}{cmd:fpimpov}  -  Financial protection in health: impoverishing health spending{p_end}


{title:Description}

{p 4 4 2}
{opt fpimpov} computes the incidence of 'impoverishing' health spending, i.e. the % of households who are pushed below the poverty line by out-of-pocket health spending. This is calculated by comparing the poverty headcount (the % of households who are poor) with household total consumption including (i.e. gross of) and excluding (i.e. net of) household out-of-pocket spending on health. {opt fpimpov} also computes the concentration index of impoverishing spending, and (optionally) the incidence of impoverishing spending for each quintile of total expenditure. The measures are derived in Wagstaff and van Doorslaer (2003). {p_end}


{title:Syntax}

{p 4 6 2}
{cmd:fpimpov} , totexp({varname}) hexp({varname}) pline({varlist}) hhsize({varname}) [hhweight({varname})] [{opt q:uintile}] [{opt e:xport}] 


{title:Main arguments}

{p 4 6 2}
- totexp({varname}) indicates the variable measuring total household expenditure or consumption gross of out-of-pocket health spending. Note: the variable should be the total for the household, {ul:not} the per capita amount. {p_end}

{p 4 6 2}
- hexp({varname}) indicates the variable measuring total household out-of-pocket health spending. Note: the variable should also be the total for the household, {ul:not} the per capita amount. {p_end}

{p 4 6 2}
- pline({varlist}) is a variable or a list of variables (separated by a space) indicating the (per capita) poverty line(s), e.g. pline(PL1 PL2). Note: the poverty line(s) should be in per capita terms, and refer to the same time period as the consumption and expenditure data (e.g. per annum, per month, or per day). {p_end}

{p 4 6 2}
- hhsize({varname}) indicates the variable measuring household size. {p_end}


{title:Options}

{p 4 6 2}
- hhweight({varname}) indicates the household weight. {p_end}

{p 4 6 2}
- The {opt hhweight} option causes {opt fpimpov} to use (household) weights.{p_end}

{p 4 6 2}
- The {opt q:uintile} option causes {opt fpimpov} to compute the incidence of impoverishing payments for each quintile of total expenditure.{p_end}

{p 4 6 2}
- The {opt e:xport} option causes {opt fpimpov} to save the computed results to a Stata dataset and Excel file. The files are called IMPOVoutput.dta and IMPOVoutput.xls. To specify the directory where the files get written to, use the {opt cd} command. By default, the files get saved to the current directory. To display the current directory, use the {opt pwd} command. {p_end}


{title:Examples}

{p 4 6 2}
fpimpov , totexp(hh_expd) hexp(hh_hexpd) pline(PL1) hhsize(hh_size) {p_end}
{p 4 6 2}
fpimpov , totexp(hh_expd) hexp(hh_hexpd) pline(PL1) hhsize(hh_size) hhweight(hh_sampleweight) {p_end}
{p 4 6 2}
fpimpov , totexp(hh_expd) hexp(hh_hexpd) pline(PL1 PL2 PL3) hhsize(hh_size) hhweight(hh_sampleweight) {p_end}
{p 4 6 2}
fpimpov , totexp(hh_expd) hexp(hh_hexpd) pline(PL1 PL2 PL3) hhsize(hh_size) hhweight(hh_sampleweight) quintile {p_end}
{p 4 6 2}
fpimpov , totexp(hh_expd) hexp(hh_hexpd) pline(PL1 PL2 PL3) hhsize(hh_size) hhweight(hh_sampleweight) quintile export {p_end}


{title:Notes}

{p 4 6 2}
- Some authors use income rather than consumption or expenditure when assessing impoverishment. This is easily handled by specifying the name of the income variable in totexp({varname}). The variable should be gross of out-of-pocket payments, i.e. payments should not have been subtracted from income. {p_end}


{title:Return values}

{col 5}{cmd:r(PL1)}{col 24}Poverty line #1, similarly for other poverty lines
{col 5}{cmd:r(impov_pop_PL1)}{col 24}% of households impoverished by health spending using poverty line #1, similarly for other poverty lines 
{col 5}{cmd:r(CI_PL1)}{col 24}Concentration index for impoverishing spending using poverty line #1, similarly for other poverty lines 
{col 5}{cmd:r(CIse_PL1)}{col 24}Std error for concentration index for impoverishing spending using poverty line #1, similarly for other poverty lines 
{col 5}{cmd:r(CIpv_PL1)}{col 24}Prob value for concentration index for impoverishing spending using poverty line #1, similarly for other poverty lines 

{col 5}{cmd:r(impov_q1_PL1)}{col 24}% of households in poorest quintile impoverished by health spending using poverty line #1, similarly for other poverty lines and quintiles 


{title:Reference}

{p 4 6 2}
- Wagstaff, A. and E. van Doorslaer (2003). "Catastrophe and impoverishment in paying for health care: with applications to Vietnam 1993-1998." {it:Health Economics} 12(11): 921-934.{p_end}


{title:Acknowledgements}

{p 4 6 2}{cmd:fpimpov} makes use of two user-written Stata programs: {cmd:conindex} written by Owen O'Donnell, Stephen O'Neill, Tom Van Ourti and Brendan Walsh, and {cmd:tknz} written by David C. Elliott and Nick Cox. {p_end}


{title:See also}

{p 4 6 2}{cmd:fpcata} which computes the incidence of catastrophic out-of-pocket spending on health. Help: {help fpcata} if installed. {p_end}


{title:Authors}

{p 4 4 2}Patrick Hoang-Vu Eozenou (peozenou@worldbank.org), World Bank, Washington DC.{p_end}
{p 4 4 2}Adam Wagstaff (awagstaff@worldbank.org), World Bank, Washington DC.{p_end}


