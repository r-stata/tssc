{smcl}
{* 12jan2018}{...}
{cmd:help fpcata}{right:version:  1.0.0}
{hline}

{title:Title}

{p 4 8}{cmd:fpcata}  -  Financial protection in health: catastrophic health spending{p_end}


{title:Description}

{p 4 4 2}
{opt fpcata} computes the incidence of 'catastrophic' health spending (the % of households spending in excess of a prespecified share of total household consumption) for each of a set of thresholds specified by the user, and the concentration index for catastrophic spending (and its prob value). {opt fpcata} also computes (optionally) the incidence of catastrophic spending for each quintile of total expenditure. The measures are derived in Wagstaff and van Doorslaer (2003). {p_end}


{title:Syntax}

{p 4 6 2}
{cmd:fpcata} , totexp({varname}) hexp({varname}) thresh({it:numlist}) [hhsize({varname})] [hhweight({varname})] [{opt q:uintile}] [{opt e:xport}] 


{title:Main arguments}

{p 4 6 2}
- totexp({varname}) indicates the variable measuring total household consumption gross of out-of-pocket health spending. Note: the variable should be the total for the household, not the per capita amount. {p_end}

{p 4 6 2}
- hexp({varname}) indicates the variable measuring total household out-of-pocket health spending. Note: the variable should also be the total for the household, not the per capita amount. {p_end}

{p 4 6 2}
- thresh({it:numlist}) is a list of thresholds (between 0 and 1) separated by a space, e.g. thresh(0.10 0.15). {p_end}


{title:Options}

{p 4 6 2}
- hhsize({varname}) indicates the variable measuring household size. Required if using the {opt hhweight} or {opt q:uintile} options. {p_end}

{p 4 6 2}
- hhweight({varname}) indicates the household weight. This option also requires the {opt hhsize} option. {p_end}

{p 4 6 2}
- The {opt q:uintile} option causes {opt fpcata} to compute the incidence of catastrophic payments for each quintile of total expenditure. This option also requires the {opt hhsize} option. {p_end}

{p 4 6 2}
- The {opt e:xport} option causes {opt fpcata} to save the computed results to a Stata dataset and Excel file. The files are called CATAoutput.dta and CATAoutput.xls. To specify the directory where the files get written to, use the {opt cd} command. By default, the files get saved to the current directory. To display the current directory, use the {opt pwd} command. {p_end}


{title:Examples}

{p 4 6 2}
fpcata , totexp(hh_expd) hexp(hh_hexpd) thresh(0.1) {p_end}
{p 4 6 2}
fpcata , totexp(hh_expd) hexp(hh_hexpd) thresh(0.1 0.25) hhsize(hh_size) hhweight(hh_sampleweight) {p_end}
{p 4 6 2}
fpcata , totexp(hh_expd) hexp(hh_hexpd) thresh(0.1) hhsize(hh_size) quintile {p_end}
{p 4 6 2}
fpcata , totexp(hh_expd) hexp(hh_hexpd) thresh(0.05 0.1 0.25) hhsize(hh_size) hhweight(hh_sampleweight) quintile {p_end}
{p 4 6 2}
fpcata , totexp(hh_expd) hexp(hh_hexpd) thresh(0.05 0.1 0.25) hhsize(hh_size) hhweight(hh_sampleweight) quintile export {p_end}


{title:Notes}

{p 4 6 2}
- Some authors use income rather than consumption or expenditure when assessing the incidence of catastrophic out-of-pocket spending. This is easily handled by specifying the name of the income variable in totexp({varname}). The variable should be gross of out-of-pocket payments, i.e. payments should not have been subtracted from income. {p_end} 
{p 4 6 2}
- Some authors prefer to define catastrophic spending in terms of health spending relative to {ul:nonfood} consumption rather than total consumption. This is easily handled by specifying the name of the nonfood consumption variable in totexp({varname}). The variable should be gross of out-of-pocket payments. {p_end}


{title:Return values}

{col 5}{cmd:r(CIpv_15)}{col 24}Prob value for concentration index for catastrophic spending at 15% threshold, similarly for other thresholds 
{col 5}{cmd:r(CIse_15)}{col 24}Std error for concentration index for catastrophic spending at 15% threshold, similarly for other thresholds 
{col 5}{cmd:r(CI_15)}{col 24}Concentration index for catastrophic spending at 15% threshold, similarly for other thresholds 
{col 5}{cmd:r(cata_pop_15)}{col 24}% of households spending more than 15% of consumption on health, similarly for other thresholds 

{col 5}{cmd:r(cata_q1_15)}{col 24}% of households in poorest quintile spending more than 15% of consumption on health, similarly for other thresholds and other quintiles 


{title:Reference}

{p 4 6 2}
- Wagstaff, A. and E. van Doorslaer (2003). "Catastrophe and impoverishment in paying for health care: with applications to Vietnam 1993-1998." {it:Health Economics} 12(11): 921-934.{p_end}


{title:Acknowledgements}

{p 4 6 2}{cmd:fpimpov} makes use of two user-written Stata programs: {cmd:conindex} written by Owen O'Donnell, Stephen O'Neill, Tom Van Ourti and Brendan Walsh, and {cmd:tknz} written by David C. Elliott and Nick Cox. {p_end}


{title:See also}

{p 4 6 2} {cmd:fpimpov} which computes the incidence of impoverishing out-of-pocket spending on health. Help: {help fpimpov} if installed. {p_end}

{title:Authors}

{p 4 4 2}Patrick Hoang-Vu Eozenou (peozenou@worldbank.org), World Bank, Washington DC.{p_end}
{p 4 4 2}Adam Wagstaff (awagstaff@worldbank.org), World Bank, Washington DC.{p_end}


