{smcl}
{* 07dec2012}{...}
{cmd:help regtable}{right:Version 3.0.0}
{hline}

{title:Title}

{pstd}
{hi:regtable} {hline 2} This command is designed to simplify visualizing subgroup analysis results from randomized experiments. 
The command outputs a table of conditional average treatment effects with corresponding standard errors across a subgroup variable. {p_end}


{marker syntax}{title:Syntax}

{p 8 16 2}
{cmd:regtable} {it: regtype} {it: depvar} {it: treatvar} {ifin}
{weight} 
{cmd:,}
{opt group:(groupvar)} [{opth vce(vcetype)}] [{opt covars:(varlist)}] [{opt file:(path)}] [{opt replace}]

{pstd} {it: regtype} type of regression (e.g., ols, logistic, poisson, etc.) {p_end} 
{pstd} {it: depvar} dependent variable {p_end} 
{pstd} {it:treatvar} treatment variable {p_end} 
{pstd} {opt group:(groupvar)} name of the subgroup variable {p_end} 
{pstd} {opt covars:(varlist)} list of control variables {p_end} 
{pstd} {opt file:(path)} directory and file name (if unspecified the resulting table is saved as `regtype'_`depvar'_`treatvar'_across_`groupvar'_table.csv in the working directory) {p_end} 
{pstd} {opt replace} replaces the file, if it already exists {p_end} 


{marker desc}{title:Description}

{pstd} {cmd:regtable} creates a csv output file of conditional average treatment effects and corresponding standard errors for each category of a subgroup variable.
The resulting file could then be used for the construction of subgroup analysis graphs using graphing and data visualization software outside of Stata.{p_end}  

{marker ex}{title:Examples}

{pstd} {inp:. regtable reg y x, group(gender)}{p_end}

{marker res}{title:Saved Results}
{pstd} The resulting table is saved in `regtype'_`depvar'_`treatvar'_across_`groupvar'_table.csv if the file option is left unspecified.{p_end}  

{title:Author}

{pstd}John Ternovski{p_end}
{pstd} Analyst Institute{p_end}
{pstd} {browse "mailto:johnt1@gmail.com":johnt1@gmail.com}{p_end}

