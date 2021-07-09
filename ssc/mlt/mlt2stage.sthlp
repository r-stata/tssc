{smcl}
{* 26Dec2012}{...}
{hline}
help {cmd:mlt2stage} {right: {browse "mailto:moehring@wiso.uni-koeln.de": Katja Moehring} and {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Produces two-stage (or slopes as outcomes) results for linear and logistic regression models (beta version)}

{p 4}Syntax

{p 8 14}{cmd:mlt2stage  yvar xvar(s) [if] [weight]} 
 {cmd:, l2id(varname)} 
[ {cmd:drop} ]
[ {cmd:logit} ] 
[ {cmd:taboff} ]

{p 4 4} {cmd:mlt2stage} is part of the {helpb mlt:mlt} (multilevel tools) package.


{title:Description}

{p 4 4} {cmd:mlt2stage} is an easy way to produce two-stage results. 
It calculates separate linear or logit regression models on {cmd:yvar} for each level2-unit {cmd:l2id(varname)}, displays the results as table and stores the coefficients of the independent variables ({cmd:xvar(s)}).
The {cmd:logit} option allows calculating logistic regression models.

{p 4 4} {cmd:mlt2stage} can be used together with {helpb mltl2scatter:mltl2scatter} to produce two-stage plots of the estimated single country regression coefficients  
of a lower-level variable over a higher-level variable. See Mood (2010) for the comparison of logit models based on different samples.

{p 4 4} {cmd:mlt2stage} allows to specify a weight for the units at the lower level.
 {cmd:aweights}, {cmd:fweights} and {cmd:iweights} are allowed. See the help for
{helpb regress: regress} and {helpb logit: logit}  to read how these weights are treated.


{title:Options}

{p 4 8} {cmd:drop} coefficients are not stored, {cmd:mlt2stage} only produces an output table.  

{p 4 8} {cmd:logit} calculates logistic instead of linear regression models. 

{p 4 8} {cmd:taboff} no output table is shown, {cmd:mlt2stage} only stores the coefficients. This option is recommended if a large number of xvars is specified. 


{title:Examples}


{p 4 4} {ul: A simple two-stage plot}{p_end}

{p 4 8} Load data set (ISSP 2006){p_end}
{p 4 8} {cmd:. webuse redistribution.dta}{p_end}

{p 4 8} Regress "Support for income redistribution" on age and sex {p_end}
{p 4 8} {cmd:. mlt2stage gr_incdiff age sex, l2id(Country)}{p_end}

{p 4 4} Scatter plot showing the association between the (age- and sex-adjusted) level of support for redistribution and economic inequality (gini){p_end}
{p 4 8} {cmd:. mltl2scatter cons_gr_incdiff gini, l2id(Country) labels qfit}{p_end}


{p 4 4} {ul: Using mlt2stage for a graphic inspection of a multilevel model with cross-level interactions}{p_end}

{p 4 8} Load data set (ISSP 2006){p_end}
{p 4 8} {cmd:. net get mlt}{p_end}
{p 4 8} {cmd:. use redistribution.dta}{p_end}

{p 4 8} A multilevel regression of "Support for income redistribution" on income, age, gender and economic inequality (gini) {p_end}
{p 4 8} {cmd:. xtmixed gr_incdiff incperc age sex gini ia_gini_incperc || Country: incperc, mle var cov(un)}{p_end}

{p 8 8} The model gives a significant interaction effect between the country-level variable economic inequality (gini) and the individual-level variable income (cross-level interaction).
The model suggests that the negative effect of income becomes weaker if inequality is higher. Is this a robust result? Let's use mlt2stage!

{p 4 8} Regress "Support for income redistribution" on all individual-level variables (income, age and sex) {p_end}
{p 4 8} {cmd:. mlt2stage gr_incdiff incperc age sex, l2id(Country)}{p_end}

{p 4 4} Scatter plot showing the association between the slope of income and the country-level variable economic inequality (gini){p_end}
{p 4 8} {cmd:. mltl2scatter coef_gr_incdiff_incperc gini, l2id(Country) labels qfit}{p_end}

{p 8 8} By plotting the estimated slopes of income against the country-level variable we can visualize the interaction effect.
It seems that there is a particular country which is responsible for the positive interaction effect estimated in the multilevel model.
This country is Chile (Country == 152).

{p 4 4} Scatter plot showing the association between the slope of income and the country-level variable economic inequality, Chile excluded (gini){p_end}
{p 4 8} {cmd:. mltl2scatter coef_gr_incdiff_incperc gini if Country != 152, l2id(Country) labels qfit}{p_end}

{p 4 8} Re-estimate the multilevel regression without Chile {p_end}
{p 4 8} {cmd:. xtmixed gr_incdiff incperc age sex gini ia_gini_incperc || Country: incperc if Country != 152, mle var cov(un)}{p_end}

{p 8 8} The interaction effect is no longer significant. It was actually due to one particular Country. 

{title:References}

{p 4 8} ISSP (2006): International Social Survey Programme - Role of Government IV, GESIS StudyNo: ZA4700, Edition 1.0, doi:10.4232/1.4700.  

{p 4 8} Carina Mood (2010): “Logistic Regression: Why We Cannot Do What We Think We Can Do, and What We Can Do About It.” {it:European Sociological Review} 26 (1): 67-82. 


{title:Authors}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, {browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.


{title:Also see}

{p 4 8}  {helpb mlt: mlt}, {helpb mltrsq: mltrsq}, {helpb mltl2scatter: mltl2scatter}, {helpb mltcooksd: mltcooksd}, {helpb mltshowm: mltshowm}
