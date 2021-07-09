{smcl}
{* *! version 1.0.5 21sept2019}
{bf:[XT] rho_xtregar} {hline 2}  rho of BFN in a fixed-effects or random-effects linear model with an AR(1) disturbance

{marker syntax}
{title:Syntax}

Fixed-effects (FE) model or Random-effects (RE) model
{hline}
{cmd:rho_xtregar} {depvar} [{indepvars}] [if] [using {it:filename}] [, approx approx_balanced approx_unbalanced nodisplay]  


options					Description
{hline}
{cmd:approx} 			Instead of rho_BFN, it computes the appropriate approximation, taking account whether the panel is balanced or unbalanced.
{cmd:approx_balanced}	(seldom used) Force the command to compute the approximation of rho_BFN appropriate to the balanced case.
{cmd:approx_unbalanced} (seldom used) Force the command to compute the approximation of rho_BFN appropriate to the unbalanced case.
{cmd:nodisplay} 		Do not display the message regarding the number of units with at least two successive observations.
{hline}
A panel variable and a time variable must be specified; use {cmd:xtset}.
Weights are not allowed

{marker description}
{title:Description}

{cmd:rho_xtregar} estimates the autoregressive parameter for cross-sectional time-series regression models 
when the disturbance term is first-order autoregressive. 
It generalizes to the unbalanced case the method exposed in {it:Bargava, Franzini and Narendranathan(1982)}. 
As such, it returns r(rho_BFN).
{cmd:rho_xtregar} can accommodate unbalanced panels whose observations are unequally spaced over time.

Remark:
{cmd:rho_xtregar} uses only on those individuals that have {bf:at least two successive observations.}
When such condition is too stringent, see for instance {it:Magnac, Pistolesi and Roux (2018)}.

Technical remarks:
{cmd:rho_xtregar} requires the user-written command: {cmd: moremata}. You can access it on ssc:
{cmd:.ssc install moremata, replace}
In very long panels (T>70), computation of rho_BFN may require an increase in maxvar (set it higher than T*T).


{marker examples}
{title:Example}

Setup:           
	{cmd:. webuse grunfeld}
	{cmd:. xtset company time}
Estimation of rho:
	{cmd:. rho_xtregar invest mvalue kstock}
	{cmd:. local rhoBFN = r(rho_BFN)}
Fixed-effects model:
	{cmd:. xtregar invest mvalue kstock, fe rhof(`rhoBFN')}
Comparison with {cmd:xtregar}:
	{cmd:. xtregar invest mvalue kstock, fe}
	{cmd:. dis "rho_BFN = " `rhoBFN' " ;  rho_xtregar = " `e(rho_ar)'}

To make a Monte-Carlo simulation:
{cmd:. scalar the_rho = e(rho_ar) }
{cmd:. scalar the_sigma_eta = e(sigma_e) }
{cmd:. scalar the_sigma_c_i = e(sigma_u) }
{cmd:. scalar the_sigma_epsilon = the_sigma_eta / sqrt(1-the_rho*the_rho) }
{cmd:. matrix the_sd = (the_sigma_eta,the_sigma_epsilon,the_sigma_c_i) }
{cmd:. 	gen rho_emp = 0 }
{cmd:. 	gen rho_emp2 = 0 }
{cmd:. set seed 89	 }
{cmd:. 	forvalues i = 1/10 {c -(}  }
{cmd:. 		drawnorm eta epsilon0 c_i, means(0,0,0) sds(the_sd) }
{cmd:. 	 bysort company: gen epsilon= epsilon0 if _n==1  }
{cmd:. 	 bysort company: replace epsilon=eta + the_rho * epsilon[_n-1] if _n>1 }
{cmd:. 	 bysort company: replace c_i = c_i[1] }
{cmd:. 	gen y = c_i + epsilon }
{cmd:. 		xtregar y, fe  }
{cmd:. 			replace rho_emp = e(rho_ar) if _n==`i'		 }
{cmd:. 		rho_xtregar y }
{cmd:. 			replace rho_emp2 = r(rho_BFN) if _n==`i'	 }	
{cmd:. 		drop epsilon epsilon epsilon0 y eta c_i }
{cmd:. 	{c )-} }
{cmd:. 	keep if _n<=10 }
{cmd:. 	collapse (mean)rho_emp rho_emp2  }
{cmd:. 	 display "true value: " the_rho "; xtregar gives: " rho_emp[1] " ; rho_xtregar gives: " rho_emp2[1] }

{marker stored}
{title:Stored results}

{cmd: rho_xtregar} stores the following in {cmd: r() :}

Scalars
{cmd: r(rho_BFN)}		rho of BFN (or its approximation when an option is supplied)


{marker formula}
{title:Formula}

Let d_p define the generalisation of the Durbin-Watson statistic of Cazenave-Lacroutz and Vieu (2019):
and r_d = (1-d_p/2)

rho_BFN is defined by:  rho_d = g_N(rho_BFN)
with g_N:r-> $1 -  \frac{(1-r) \sum_{i=1}^N \frac{K_i}{1+K_i}}{N -  \sum_{i=1}^N \frac{1}{n_i^2} \sum_{j,k=1}^{n_i} r^{|t_{ij} - t_{ik}|}}$
where: $K_i =  \sum_{j=2}^{n_i} \mathbb{1}_{t_{ij} - t_{ij-1} = 1} $

rho_BFN_approx_balanced is defined by:
rho_BFN_approx_balanced = rho_d / (2-T)
In a balanced panel, its bias converges towards zero (when T -> infinity) in $1/T^2$. Suggested for fast computations when T is large (e.g. T=10).

rho_BFN_approx_unbalanced is defined by:
rho_BFN_approx_unbalanced = $\frac{\frac{1}{N} \sum_{i}^N \frac{K_i}{1+K_i}-1+\rho_d}{\frac{1}{N} \sum_{i}^N \frac{K_i}{1+K_i}}$
It should not be used in balanced panels, as its bias converges towards zero much slower than rho_BFN_balanced (in $1/T$).

{marker references}
{title:References}

Bhargava, A., L. Franzini, and W. Narendranathan. 1982. Serial correlation and the fixed effects
        model. {it:Review of Economic Studies} 49: 533-549.

Magnac, T., Pistolesi, N., & Roux, S. 2018. Post-Schooling Human Capital Investments and the Life Cycle of Earnings. {it:Journal of Political Economy}, 126(3), 1219-1249.

Cazenave-Lacroutz, A. and V. Lin. 2019. rho_xtregar: a new command to improve the estimation of rho in AR(1) panels.
 {it:Mimeo}.
 
 {title:Authors}

{p 4} Alexandre Cazenave-Lacroutz and Vieu Lin {p_end}
{p 4} Centre de Recherche en Economie et en Statistiques (Crest) et Institut National de la Statistique et des Etudes Economiques (Insee){p_end}
{p 4} {browse "mailto:alexandre.cazenave-lacroutz@polytechnique.org":alexandre.cazenave-lacroutz@polytechnique.org}{p_end}
{p 4} https://sites.google.com/view/acazenave-lacroutz/english{p_end}
{p 4} https://github.com/ACL90/rho_xtregar{p_end}
 