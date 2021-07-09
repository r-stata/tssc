{smcl}
{* 1feb2012}{...}
{cmd:help mmsel}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:mmsel} {hline 2}} Simulate (counterfactual) distributions from quantile regressions (w/optional sample selection correction){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt mmsel} {depvar} [{indepvars}] {if} 
   [{cmd:,} {it:options}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Main}
{synopt :{opt gr:oup(var)}} Group identification binary variable {p_end}
{synopt :{opt pooled/incgrp/group1}} Reference wage structure (see below){p_end}
{synopt :{opt percentile}} Print results for each percentile {p_end}
{synopt :{opt r:eps(#)}} Number of repetitions {p_end}
{synopt :{opt f:ilename(foo)}} Filename given to log files and graphs {p_end}

{syntab :Sample Selection (see below)}
{synopt :{opt grponlysel}} Single group for sample selection correction{p_end}
{synopt :{opt single(indepvars)}} Single index generation for sample selection correction (32bit only){p_end}
{synopt :{opt m:ethod(#)}} Method of estimation{p_end}
{synopt :{opt adj:ust(var)}} Single index generated power series variable{p_end}
{synopt :{opt con:straint(con)}} Reduced sample constraint{p_end}
{synopt :{opt red:uced(indepvars)}} Reduced model{p_end}

{title:Description}

{pstd}
{cmd:mmsel} Simulates (counterfactual) distributions from quantile regressions. Based on Machado and Mata (2005). An option to correct 
for sample selection has been added, using an adaptation of the procedure described in Albrecht et. al (2009). Multiple options 
available for different reference groups, following Oaxaca (1973), Blinder (1973) Oaxaca Ransom (1994) and Jann (2008). After 
simulation of conditional distributions, the differences between these distributions are decomposed and graphed into explained
and unexplained components. 

{pstd}
To keep working directory clean, the program creates four directories (tmp, results, logs, data) which contain all the files needed for troubleshooting and/or analysis.

{pstd}
WARNING - Depending on options selected, may take days to run - test using {cmd:sample 10} or other low number (uses 10% of sample). 

{pstd}
NOTE - This program requires a pid variable: a personal identification variable for each individual in the sample

{title:Options}

{dlgtab:Main}

{phang}{opt pooled/incgrp/group1} Reference wage structure: {p_end}

{phang}{opt pooled} Uses the pooled wage structure estimated from 
a model using the pooled sample (including both groups) (See Oaxaca & Ransom 1994) {p_end}

{phang}{opt incgrp} Uses the pooled wage structure (including the 
group binary variable) estimated from a model using the pooled sample
(including both groups) (See Jann(2008)){p_end}

{phang}{opt group1} Uses the wage structure of group for which that
group binary variable equals 1 estimated from a model using only that group's
sample. (If the group binary variable is coded as male=1 male and male=0 female, then selecting 
the group1 option will use as reference wage structure the male wage structure) (See Oaxaca (1973) & Blinder (1973)) {p_end}

{phang}{opt percentile} Using this option forces the module to provide a table with decomposition results for each percentile, 
rather than the default of every 5 percentiles {p_end}

{phang}{opt reps(#)} Number of repetitions used in the Machado & Mata counterfactual distribution simulations (default value: 200) {p_end}

{dlgtab:Sample Selection Correction}

{phang}{opt grponlysel} Single group for sample selection correction - Sample selection correction
only takes place for individuals where the group dummy is equal to zero (default is both groups are corrected for sample selection) {p_end}

{phang}{opt single(indepvars)} Single index generation for sample selection correction - This option launches the single
index generation process proposed by Ichimura (1993), as documented in Albrecht et. al (2009), prior to sample selection corrected
decompositions. It must ONLY be run on a full dataset that includes censored observations. The independent variables are
variables that are thought to affect whether an observation is censored or not. Following the single index generation process,
censored observations are dropped from the sample. Censored observations automatically identified by the option as those observations
where depvar (in the mmsel) is missing or equal to 0.{p_end}

{phang}{opt m:ethod(#)} (Only for testing purposes) Method of estimation - Whether method(1) 
or method(2) selected the same results should be generated (Default setting is method(2)).{p_end}

{phang}{opt adj:ust(var)} Single index generated power series variable - The variable predicted from a 
single index model applied to the whole working and non-working sample, needed for sample selection correction. 
The Inverse Mills Ratio can also be used although many assumptions must be relaxed for this to be a valid move.
NOTE: If the single() option is used, "var" MUST be replaced with "Ps1". If not, "var" should be a single index 
generated over the full censored and non-censored sample.{p_end}

{phang}{opt con:straint(con)} Reduced sample constraint - a constraint in Stata format with the aim of constraining 
the sample temporarily to a sample for which the probability of being in work is close to unity. This is a second-best solution 
to estimating the true constant of an earnings equation while correcting for sample selection across the earnings distribution {p_end}

{phang}{opt red:uced(indepvars)} Reduced model - List of independent variables without the variable(s) used for the sample constraint above. {p_end}

{title:Example without sample selection correction}

{phang2}{cmd:. mmsel y x1 x2 x3 x4, group(female) filename(foo) reps(100) pooled}{p_end}

{title:Example with sample selection correction}

{phang2}{cmd:. mmsel y x1 x2 x3 x4, group(female) grponlysel single(z1 z2 z3) filename(foo) reps(100) pooled adjust(Ps1) reduced(x1 x3) cons(x2=1&x4<56|x2=0&x4<24)}{p_end}

{title:References}

{phang} Albrecht, J van Vuuren, A and Vroman, S (2009). “Counterfactual distributions
with sample selection adjustments: Econometric theory and an application to
the Netherlands Labour Economics.” Labour Economics 16(4); 383-396.{p_end}

{phang} Blinder, A S (1973). “Wage Discrimination: Reduced Form and Structural Estimates.”
The Journal of Human Resources 8; 436–455.{p_end}

{phang} Ichimura, H (1993). “Semiparametric least squares (SLS) and weighted SLS estimation of
single index models.” Journal of Econometrics 58; 71–120.{p_end}

{phang} Jann, B (2008). “The Blinder–Oaxaca decomposition for linear regression models.”
Stata Journal 8(4); 453-479.{p_end}

{phang} Mata, J & Machado J A F, (2005). “Counterfactual decomposition of changes 
in wage distributions using quantile regression.” Journal of Applied Econometrics 20(4); 445-465.{p_end}

{phang} Oaxaca R L & Ransom M R (1994). “On discrimination and the decomposition of wage differentials.”
Journal of Econometrics, 61(1); 5-21.{p_end}

{phang} Oaxaca, R L (1973). “Male-Female Wage Differentials in Urban Labor Markets.”
International Economic Review, 14(3); 693-709.{p_end}

{title:Author}

{p 4 4 2} Sami Souabni, Swansea University, sami@souabni.com, who bears no responsibility for any errors.

{title:Acknowledgements}

{p 4 4 2} Single index generation based on publicly available original code by Aico van Vuuren (http://members.chello.nl/a.vuren1/Ado.exe), who bears no responsibility for any errors.

{p 4 4 2} Machado & Mata decomposition based on original code by Mark Bryan, ISER, University of Essex, who bears no responsibility for any errors.
