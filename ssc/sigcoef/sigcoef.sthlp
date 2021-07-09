{smcl}
{* 27Nov2003}{...}
{hline}
help for {hi:sigcoef} - 0.0.6 - 2010-01-20
{hline}

{title: Count significant coefficients from regression model}

{p 8 15 2}{cmd:sigcoef} {it:varlist} [if] [in] [{cmd:,}
{cmdab:r:eplace}
{cmdab:a:ppend}
{cmdab:l:evel(}{it:int $S_level}{cmd:)}
{cmdab:c:lear}
{cmdab:dvs:ame}
{cmdab:disp:lay}

{title: Descriptions}

This is a Stata program to count the number of significant coefficients for the same
variables (using same names) across models using z as test statistics (usually
using maximum likelihood estimation). This program is especially useful when 
you want to examine effects of same independent variables across a large number 
of sub-units (e.g, countries, schools, etc..)

Models using t statistics are also available for regress, areg, or survey 
regressions, but you can tweak the codes to add more. The counting is from 
the most recent sigcoef with the replace option to the one with the most 
recent append option. 

{title: Options}

{p 4 8 2}
{cmdab:r:eplace} sets all globals to 0, and start counting with the most recent
estimation. Either replace, append, or clear has to be issued.

{p 4 8 2}
{cmdab:a:ppend} adds one to the counters stored in globals if the current model has a 
significant coefficient for the same variable.

{p 4 8 2}
{cmdab:c:lear} clears out all globals created by this program.

{p 4 8 2}
{cmdab:l:evel()} specifies the width of confidence level, or the tolerance
level for significant coefficients to be counted.

{p 4 8 2}
{cmdab:dvs:ame} requests that the counting is valid only with the same dependent
variable between two most recent estimations.

{p 4 8 2}
{cmdab:disp:lay} displays counts from the most recent issuance of this command 
with a replacement option till the most recent issuance with an append option. 

{title: Globals}

{p 4 8 2}
posnum*: counts the positive number of significant coefficients for varialble * 
(here * represents variable name listed in varlist)

{p 4 8 2}
negnum*: counts the negative number of significant coefficients for varialble *
(here * represents variable name listed in varlist)

{p 4 8 2}
signum*: counts the significant number of coefficients for varialble *
(here * represents variable name listed in varlist)

{p 4 8 2}
poslhs*: lists the lhs variables with * as a rhs riable that is positively 
affecting this lhs variable.

{p 4 8 2}
neglhs*: lists the lhs variables with * as a rhs riable that is negatively
affects this lhs variable.

{title: Examples}

{p 4 8 2}
.logit register male inc educ 

{p 4 8 2}
.sigcoef inc educ, replace

{p 4 8 2}
.logit vote male inc educ

{p 4 8 2}
.sigcoef inc educ, append

{p 4 8 2}
.mac list incposnum incnegnum incsignum educposnum educnegnum educsignum

{hline}

{p 2 4 2}Authors: Jun Xu{p_end}
{p 11 4 2}{browse jxu.iweb.bsu.edu}{p_end}

