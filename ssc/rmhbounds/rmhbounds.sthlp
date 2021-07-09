{smcl}
{* July 2020} {...}
{hline}
help for {hi:rmhbounds} {right:Daniel Litwok (July 2020)}
{hline}

{title: Refined Mantel-Haenszel bounds to check sensitivity of estimated average treatment effects on the treated}

{p 8 17 2} {cmd:rmhbounds} {it:outcome} [{it:if}]
	{cmd:,} {cmd:gamma(} {it:numlist} {cmd:)}
	[{cmd:treated(} {it:newvar} {cmd:)}
	{cmd:weight(} {it:newvar} {cmd:)}
	{cmd:support(} {it:newvar} {cmd:)}
	{cmd:stratum(} {it:newvar} {cmd:)}
	stratamat]

{title:Description}

{p 4 4 2}
{cmd:rmhbounds} calculates Rosenbaum (2002) bounds for average treatment effects on the treated in the presence of unobserved heterogeneity (hidden bias) between treatment and control cases. {cmd:rmhbounds} refines {cmd:mhbounds} (see {stata "net sj 7-1 st0121"}) by removing the cap on the number of strata and replacing the large sample approximation for {it:E} and {it:V} with exact moments. The latter refinement improves performance of the command for strata with a small number of observations. 

{title:Options}

{p 4 4 2} {cmd:gamma(} {it:numlist} {cmd:)} is required and specifies the values of cap gamma for which to carry out the sensitivity analysis. Estimates at cap gamma = 1 (no heterogeneity) are included in the calculations by default.

{p 4 4 2} {cmd:treated(} {it:newvar} {cmd:)} specifies the name of the user-provided treatment variable. If no name is provided, {cmd:mhbounds} expects {cmd:_treated} from {cmd:psmatch} or {cmd:psmatch2}.

{p 4 4 2} {cmd:weight(} {it:newvar} {cmd:)} specifies the name of the user-provided variable containing the frequency with which the observation is used as a match. If no name is provided, {cmd:mhbounds} expects {cmd:_weight} from {cmd:psmatch} or {cmd:psmatch2}.

{p 4 4 2} {cmd:support(} {it:newvar} {cmd:)} specifies the name of the user-provided common support variable. If no name is provided, {cmd:mhbounds} expects {cmd:_support} from {cmd:psmatch} or {cmd:psmatch2}.

{p 4 4 2} {cmd:stratum(} {it:newvar} {cmd:)} specifies the name of the user-provided variable indivating strata.

{p 4 4 2} {cmd:stratamat,} combined with {cmd:stratum(} {it:newvar} {cmd:),} keeps in memory not only the matrix {cmd:outmat} containing the overall/combined test statistics but also the matrices {cmd:outmat_j} containing the strata-specific test statistics, j=1,...,#strata.

{title:Remarks}
{p 4 4 2} In some applications, the significance level on the bounds might fall first and then rise again. This is the case when gamma becomes so large that the esitmated average treatment effect on the treated changes sign and becomes significant.

{title:Example}
{p 4 4 2} Running {cmd:rmhbounds} after {cmd:cem}: 

use lalonde, clear

gen emp78=(re78>0)

cem age education (0 6.5 8.4 12.5 16.5) black married nodegree re74, treatment(treated)

gen support=(cem_weights>0)

keep if support==1

gen weight=1

rmhbounds emp78, gamma(1 (0.05) 2) treated(treated) weight(weight) support(support) stratum(cem_strata)

{title:References}
{p 4 8 2} Becker, S. O., & Caliendo, M. (2007). Sensitivity analysis for average treatment effects. {it:The Stata Journal, 7}(1), 71-83.

{p 4 8 2} Rosenbaum, P. R. (2002). {it:Observational Studies} 2nd ed. New York: Springer.

{title:Author}

{p 4 4 2} Daniel Litwok <daniel.litwok@gmail.com>

{title:Acknowledgements}

{p 4 4 2} Becker and Caliendo made available commands for sensitivity analysis; see Becker & Caliendo (2007). This package draws liberally from that work; note in particular the similarity of verbiage under headings Description, Options, and Remark.

{title:Also see}

{p 4 4 2} Online: {help mhbounds}, if installed














