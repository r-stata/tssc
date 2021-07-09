{smcl}
{* 12oct2007}{...}
help for {cmd: help stcoxgof}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:stcoxgof} {hline 2}}Goodness-of-fit test and plot after a Cox model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:stcoxgof} [{cmd:,} {cmdab:gr:oup(}{it:#}{cmd:)} {cmd:mol(}{it:#}{cmd:)} {cmd:molat(}{it:numlist}{cmd:)} {cmd:mom(}{it:#}{cmd:)}
{cmd:momat(}{it:numlist}{cmd:)} {cmdab:poi:dis} {cmdab:ar:jas(}{it:#}{cmd:)} {cmd:separate} {it:twoway_options} ]
 
{synoptset 29 tabbed}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt gr:oup}}specify the number of quantiles of risk for Gronnesby and Borgan test{p_end}
{synopt :{opt mol}}specify the number of time intervals for Moreau, O'Quigley and Lellouch test{p_end}
{synopt :{opt molat}}specify the time intervals for Moreau, O'Quigley and Lellouch test{p_end}
{synopt :{opt mom}}specify the number of time intervals for Moreau, O'Quigley and Mesbah test{p_end}
{synopt :{opt momat}}specify the time intervals for Moreau, O'Quigley and Mesbah test{p_end}
{synopt :{opt poi:dis}}report probability of observed counts within each decile of risk according to Poisson distibution{p_end}

{syntab :Arjas like plots}
{synopt :{opt ar:jas}}specify the number of quantiles of risk for Arjas like plots.{p_end}
{synopt :{opt sep:arate}}separate plots for each qualntile of risk are shown.{p_end}
{synopt :{opth lineop:ts(cline_options)}}affect rendition of the line{p_end}

{syntab :Y-Axis, X-Axis, Saving, Scheme}
{synopt :{it:{help twoway_options}}}some of the options documented in 
{bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{p}{cmd:stcoxgof} is a post-estimation command testing the goodness of fit after a Cox model.
So you must use this command after {cmd:stcox}. To compute Gronnesby and Borgan test 
and to obtain Arjas like plots Martingale residuals must also be saved specifying
{cmd:stcox}'s {cmd:mgale()} option; see {help stcox}.{p_end}

{p}{cmd:stcoxgof} calls {cmd:scoretest_cox} to compute score test statistics. You can obtain this
command by {net "describe scoretest_cox,from(http://www.stata.com/users/icanette)":clicking here}.{p_end}

{p}When used without options or with the option {cmd:group(}{it:#}{cmd:)}, {cmd:stcoxgof} computes the added variable
version of Gronnesby and Borgan test by the Score statistic and Likelihood ratio statistic 
for the inclusion of design variables based on risk score.
Then a table presenting the observed and expected numbers of events in each quantile 
of risk is shown. According to May and Hosmer, z-score and two-tailed p-value from standard
normal distribution are also tabulated.{p_end}

{p}An added variables version of the Moreau, O'Quigley and Lellouch test can be computed 
specifying the {cmd:mol(}{it:#}{cmd:)} or the {cmd:molat(}{it:numlist}{cmd:)} option. 
In this case the Score statistic and Likelihood ratio statistic refer to the inclusion of design variables based on cross-products 
of indicator variables for risk score groups and time intervals.{p_end}

{p}Specifying {cmd:mom(}{it:#}{cmd:)} or the {cmd:momat(}{it:numlist}{cmd:)} option
an added variables version of the Moreau, O'Quigley and Mesbah test can be computed.
In this case the Score statistic and Likelihood ratio statistic refer to the inclusion of design variables
based on cross-products of the covariates included in the model and time intervals. 
Since several interactions terms can be created, it is not advisable to compute this test
when the model includes more than a few categorical covariates.{p_end}

{p}If {cmd:arjas(}{it:#}{cmd:)} option is given Arjas like plots by quantiles of risk are displayed.{p_end}


{title:Options}

{dlgtab:Main}

{p 4 8}{cmd:group(}{it:#}{cmd:)} specifies the number of groups based on risk score to be used to group
observed ed expected numbers of events. If not specified the optimal number of quantiles is 
computed according to the formula {it:int(max(2,min(10,`e(N_fail)'/40)))}. Indicator variables for each
risk score group are then added to the model to compute the Gronnesby and Borgan test.
Values allowed are from 2 to 10.{p_end}

{p 4 8}{cmd:mol(}{it:#}{cmd:)} specifies the number of time intervals by which the analysis time 
is partitioned. Then, cross-products of indicator variables for quantiles of risk 
and time intervals are formed and the Moreau, O'Quigley and Lellouch test computed.
Values allowed are from 2 to 10. The number of quantiles of risk can be specified using the 
{cmd:group(}{it:#}{cmd:)} option or the optimal number is determined according to the formula above.{p_end}

{p 4 8}{cmd:molat(}{it:numlist}{cmd:)} is an alternative way to partition the analysis time at the times
specified in the {it:numlist}. As the previous option, cross-products of indicator variables for quantiles of risk 
and time intervals are then formed the Moreau, O'Quigley and Lellouch test computed.{p_end}

{p 4 8}{cmd:mom(}{it:#}{cmd:)} specifies the number of time intervals by which the analysis time 
is partitioned. The time axis is divided such that each interval contains approximately the same number 
of events. Then cross-products of covariates included in the model and time intervals are formed and 
Moreau, O'Quigley and Mesbah test computed. Values allowed are from 2 to 10.{p_end}

{p 4 8}{cmd:momat(}{it:numlist}{cmd:)} is an alternative way to partition the analysis time at the times
specified in the {it:numlist}. As the previous option, cross-products of covariates included in the model and
time intervals are then formed and the Moreau, O'Quigley and Mesbah test computed.{p_end}

{p 4 8}{cmd:poidis} estimates the probability of observed counts within each decile of risk 
according to Poisson distibution with mean equal to the estimated expected number of counts.{p_end}


{dlgtab:Arjas like plot}

{p 4 8}{cmd:arjas(}{it:#}{cmd:)} specifies the number of quantiles of risk used to group the
data for Arjas like plots. Values allowed are from 2 to 10.{p_end}

{p 4 8}{cmd:separate} requests that for each quantile of risk a separate graph should be shown.{p_end}



{title:Examples}

{p 12 20}{inp: use "C:\Data\uis_gof", clear}{p_end}
{p 12 20}{inp: stset time, failure(cens)}{p_end}
{p 12 20}{inp: stcox age beck ndru_1 ndru_2 ivh_3 race treat site agesite racesite, mgale(m)}{p_end}
{p 12 20}{inp: stcoxgof}{p_end}
{p 12 20}{inp: stcoxgof,gr(5)}{p_end}
{p 12 20}{inp: stcoxgof,mol(4)}{p_end}
{p 12 20}{inp: stcoxgof,gr(5) mol(4)}{p_end}
{p 12 20}{inp: stcoxgof,gr(5) molat(84 170 376)}{p_end}
{p 12 20}{inp: stcoxgof,arjas(4) scheme(sj)}{p_end}
{p 12 20}{inp: stcox ivh_3 race treat}{p_end}
{p 12 20}{inp: stcoxgof,mom(4)}{p_end}
{p 12 20}{inp: stcoxgof,momat(170 354 535)}{p_end}

{p}Downloading ancillary files in one of your {cmd:`"`c(adopath)'"'} directory you can run this example.{p_end}

	  {it:({stata "stcoxgof_example uis_gof":click to run})}


{title:Remarks}

{p}Based on ideas similar to the Hosmer-Lemeshow test for logistic regression,
three goodness of fit tests for Cox proportional hazards model can be derived by adding
group indicator variables to the model and testing the hypothesis that the coefficients
of the group indicator variables are zero via score, likelihood ratio or Wald test.{p_end}

{p}The first is the Moreau, O'Quigley, and Lellouch (MOL) test obtained by partitioning in intervals the time axis
and grouping the individuals based on their risk score. Then, indicator variables are generated as 
cross products of time intervals with risk score groups and included in the model. The MOL test is an omnibus
test and should detect any violations of the PH model.{p_end}

{p} The second is the added variable version of test proposed by Moreau. O'Quigley, and Mesbah (MOM).
The time axis is partitoned in intervals and indicator variables are generated by cross products of time intervals
with each level of the covariates in the model. The MOM test is designed to specifically detect violations of the
proportional hazards assumption. The fact that we might need to use a large number of
added variables limits the use of the MOM test to the case of Cox models with just a few categorical covariates.{p_end}

{p}The third test is proposed by Gronnesby and Borgan. The idea is to divide the observations into groups 
based on their estimated risk score. Then, indicator variables for risk score groups are added to the model testing
whether their coefficients are zero. This test, like the MOL test, is an omnibus test but it is not appropriate
when time-varying covariates are included in the model.{p_end}

{p}Arjas like plots, as proposed by Hosmer and Lemeshow, compare observed and expected events in groups based on 
risk score.{p_end}



{title:Also see}

{p 1 10}Manual:  {hi:{bind:[S] st stcox}}{p_end}

{p 1 10}Online:  {help stcox postestimation}, {help stcox diagnostics}{p_end}



{title:References}

{p}S. May and D. W. Hosmer. Hosmer and Lemeshow type goodness-of-fit statistics for the Cox proportional hazards model. 
In: Advances in Survival Analysis: Handbook of Statistics Vol 23, edited by N. Balakrishnana and C. R. Rao, 
Amsterdam: Elsevier, North-Holland, 2004, p. 383-394.{p_end}

{p}D. W. Hosmer and S. Lemeshow. Applied survival analysis: Regression modeling of time to event data.
Wiley, New York, 1999, p. 225 - 230.{p_end}



{title:Authors}

{p}Enzo Coviello ({browse "mailto:enzo.coviello@alice.it":enzo.coviello@alice.it}){p_end}
{p}John Moran ({browse "mailto:john.moran@adelaide.edu.au":john.moran@adelaide.edu.au}){p_end}


{title:Aknowledgments}

{p}We are grateful to Isabel Canette for writing scoretest_cox and to Phil Ryan and coll. for their cooperation 
in checking the results of the tests.{p_end}
