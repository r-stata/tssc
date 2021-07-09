{smcl}
{* *! version 1.2 Chao Wang 09/07/2018}{...}
{cmd:help medsurv}
{hline}

{title:Title}

{pstd}{hi:medsurv} {hline 2} Calculate the median survival time after Cox/Poisson
regression

{title:Syntax}

{pstd}{cmd:medsurv}{cmd:,} {opt id(varname)} {opt riskset(varname)}

{title:Description}

{pstd} This program calculates the median survival time after a Cox/Poisson model, and
stores the result in a new variable {it:medsurv} for each subject (where possible). A
Poisson model must be fitted before running this command (see below for an example).
For the motivation of fitting the Cox model as a Poisson model see   
"Cox regression as Poisson regression" in the Stata manual for Survival Analysis,
or Carstensen (2005). Also unlike {cmd:predict} after {cmd:streg} (at the time 
of writing, July 2018), the prediction from this program is not made from t = 0 conditional 
on constant covariates; therefore it can handle multiple-record-per-subject data 
with time-varying covariates, and produce distinct predicted median survival time for each subject.

{title:Options}

{pstd}{opt id(varname)} specifies the subject variable. {opt riskset(varname)} 
specifies the risk sets which can be generated from the {cmd:stsplit} (see below).

{title:Examples}

{phang}{stata "use http://www.stata-press.com/data/cggm3/hip2, clear": . use http://www.stata-press.com/data/cggm3/hip2, clear}{p_end}
{phang}{stata "stset": . stset}{p_end}
{phang}{stata "stsplit, at(failures) riskset(interval)": . stsplit, at(failures) riskset(interval)}{p_end}
{phang}{stata "generate time_exposed = _t - _t0": . generate time_exposed = _t - _t0}{p_end}
{phang}{stata "poisson _d ibn.interval protect age calcium, exposure(time_exposed) noconstant irr": . poisson _d ibn.interval protect age calcium, exposure(time_exposed) noconstant irr}{p_end}
{phang}{stata "medsurv, id(id) riskset(interval)": . medsurv, id(id) riskset(interval)}{p_end}

{title:Reference}

{pstd} Carstensen B. Demography and epidemiology: Practical use of the Lexis diagram in the computer age. Annual meeting of Finnish Statistical Society. 2005. Available from: https://biostat.ku.dk/reports/2006/rr-06-2.pdf

{title:Author}

{pstd}Chao Wang, BEng MSc DIC PhD, Senior Lecturer in Health & Social Care Statistic, Faculty of Health, Social Care and Education,
Kingston University and St George's, University of London, excelwang@gmail.com.

{pstd} Please cite this program if used in your research.
