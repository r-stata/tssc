{smcl}
{* 07dec2012}{...}
{cmd:help xvalols}{right:Version 1.0.0}
{hline}

{title:Title}

{pstd}
{hi:xvalols} {hline 2} Generates crossvalidated OLS regression coefficients.  
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:xvalols} {it:varlist} {cmd:, }
[{opt iter:(var or string)}]

{marker desc}{title:Description}

{pstd} {cmd:xvalols} crossvalidates an OLS regression over a pre-specified number of crossfolds. 

{marker opt}{title:Options}

{pstd} {it:varlist} name of the dependent variable (DV) variable, followed by the names of the independent variables {p_end} 
{pstd} {opt iter:(num)} number of crossfolds, or variable specifying crossfolds {p_end} 

{marker ex}{title:Examples}

{pstd} {inp:. xvalols y_avg x_avg, iter(10)}{p_end}

{pstd} {inp:. xvalols y_avg x_avg, iter(cutoff)}{p_end}

{marker res}{title:Saved Results}

{pstd}
{cmd:nonparmde} saves the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:e(output{it:x})}}A crossvalidated regression coefficient for variable number {it:x}.{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:e(crossfold_output)}}A table of crossfolds and corresponding crossvalidated values.{p_end}

{title:Authors}

{pstd}Joel Middleton{p_end}
{pstd} New York University{p_end}
{pstd} {browse "mailto:joel.middleton@gmail.com":joel.middleton@gmail.com}{p_end}

{pstd}John Ternovski{p_end}
{pstd} Analyst Institute{p_end}
{pstd} {browse "mailto:johnt1@gmail.com":johnt1@gmail.com}{p_end}

