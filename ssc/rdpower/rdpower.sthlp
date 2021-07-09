{smcl}

{* * ! version 0.8 2-21-2011}{...}
{cmd:help rdpower}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:rdpower} {hline 2}}Power calculations for random designs{p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:rdpower} {it:design_type}{cmd:,} es(#) [{it:options}]

{synoptset 26 tabbed}{...}
{syntab:where elements of {it:design_type} may be}

{synopt:{opt rd1}} A simple 1-level design whereby half of the subjects are 
assigned treatment and half are assigned control.  Sample size is n * 2. {p_end}

{synopt:{opt crd2}} A 2-level cluster randomized design where treatment is at level
2. Sample size is n * m * 2.  {p_end}

{synopt:{opt crd3}} A 3-level cluster randomized design where treatment is at level 
3.  Sample size is n * p * m * 2. {p_end}

{synopt:{opt rbd2}} A 2-level randomized block design where treatment is at level
1. Sample size is n * m * 2.  {p_end}

{synopt:{opt rbd3}} A 3-level randomized block design where treatment is at level
2. Sample size is n * p * m * 2. {p_end}

{title: Description}

{pstd}{cmd:rdpower} computes power for a variety of randomized
designs: a single level randomized design where there is no clustering, a two-level cluster 
randomized design where treatment is at level 2, a three-level cluster randomized design where
treatment is at level 2, a two-level block randomized design where treatment is at level 1,
and a three-level randomized block design where treatment is at level 2.  

IMPORTANT: For each design type, the options mean something different so be sure to take note 
of the definitions below.

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required for all designs}
{synopt:{opt es(#)}} A standardized effect size.{p_end}

{syntab:Optional for all designs}
{synopt:{opt alpha(#)}} The alpha for a two-tailed test.  Default is 0.05.{p_end}

{hline}

{syntab:Required for rd1}

{synopt:{opt n(#)}} The number of cases per treatment {p_end}

{hline}

{syntab:Required for crd2}

{synopt:{opt m(#)}} The number level-2 clusters per treatment. {p_end}

{synopt:{opt n(#)}} The number of cases per level-2 cluster. {p_end}

{synopt:{opt icc2(#)}} The level-2 intraclass correlation (ICC). If none is specified, 
an ICC of 0 is assumed, and the result is the same as rd1. {p_end}

{syntab:Required for crd2 when specifying covariates}

{synopt:{opt pre1(#)}} The proportion of level-1 variance explained (R-square) by 
level 2 covariates. {p_end}

{synopt:{opt pre2(#)}} The proportion of level-2 variance explained (R-square) by
level 2 covariates. {p_end}

{synopt:{opt l2vars(#)}} The number of level-2 covariates. {p_end}

{hline}

{syntab:Required for crd3}

{synopt:{opt m(#)}} The number level-3 clusters per treatment. {p_end}

{synopt:{opt p(#)}} The number level-2 clusters per level-3 cluster {p_end}

{synopt:{opt n(#)}} The number of cases per level-2 cluster. {p_end}

{synopt:{opt icc2(#)}} The level-2 intraclass correlation (ICC). {p_end}

{synopt:{opt icc3(#)}} The level-3 intraclass correlation (ICC). {p_end}

{syntab:Required for crd3 when specifying covariates}

{synopt:{opt pre1(#)}} The proportion of level-1 variance explained (R-square) by 
level-3 covariates. {p_end}

{synopt:{opt pre2(#)}} The proportion of level-2 variance explained (R-square) by
level-3 covariates. {p_end}

{synopt:{opt pre3(#)}} The proportion of level-3 variance explained (R-square) by
level-3 covariates. {p_end}

{synopt:{opt l3vars(#)}} The number of level-3 covariates. {p_end}

{hline}

{syntab:Required for rbd2}

{synopt:{opt m(#)}} The number level-2 clusters. {p_end}

{synopt:{opt n(#)}} The number of cases per treatment per level-2 cluster. {p_end}

{synopt:{opt icc2(#)}} The level-2 intraclass correlation (ICC). {p_end}

{synopt:{opt v(#)}}  The ratio of the variance in treatment effects across 
clusters to the total variance across clusters. {p_end}

{syntab:Required for rbd2 when specifying covariates}

{synopt:{opt pre1(#)}} The proportion of level-1 variance explained (R-square) by 
level 2 covariates. {p_end}

{synopt:{opt pre2(#)}} The proportion of level-2 variance in treatment effects explained (R-square) by
level 2 covariates. {p_end}

{synopt:{opt l2vars(#)}} The number of level-2 covariates. {p_end}

{hline}

{syntab:Required for rbd3}

{synopt:{opt m(#)}} The number level-3 clusters. {p_end}

{synopt:{opt p(#)}} The number level-2 clusters per treatment per level-3 cluster {p_end}

{synopt:{opt n(#)}} The number of cases per level-2 cluster. {p_end}

{synopt:{opt icc2(#)}} The level-2 intraclass correlation (ICC). {p_end}

{synopt:{opt icc3(#)}} The level-3 intraclass correlation (ICC). {p_end}

{synopt:{opt v(#)}}  The ratio of the variance in treatment effects across clusters to the total variance across clusters {p_end}

{syntab:Required for rbd3 when specifying covariates}

{synopt:{opt pre1(#)}} The proportion of level-1 variance explained (R-square) by 
level-3 covariates. {p_end}

{synopt:{opt pre2(#)}} The proportion of level-2 variance explained (R-square) by
level-3 covariates. {p_end}

{synopt:{opt pre3(#)}} The proportion of level-3 variance in the treatment effects explained (R-square) by
level-3 covariates. {p_end}

{synopt:{opt l3vars(#)}} The number of level-3 covariates. {p_end}

{hline}

{title:Examples}

{phang}For a single level design with 80 subjects per treatment group and an effect size of 0.40

{phang}{cmd:. rdpower rd1, es(.4) n(80)}{p_end}

{phang}For a two-level cluster randomized design with 8 clusters per treatment group, 50 subjects per cluster, an ICC of 0.2, and an effect size of 0.50.  Treatment is at level 2.

{phang}{cmd:. rdpower crd2, es(.5) n(50) m(8) icc2(.2)}{p_end}

{phang}For a two-level cluster randomized design with 8 clusters per treatment group, 50 subjects per cluster, an ICC of 0.2, an effect size of 0.50, with a single level-2 covariate that accounts for 20 percent of the variance at level 1 and 20 percent of the variance at level 2.  Treatment is at level 2.

{phang}{cmd:. rdpower crd2, es(.5) n(50) m(8) icc2(.2) pre1(.2) pre2(.2) l2vars(1)}{p_end}

{phang}For a three-level cluster randomized design with 8 level-3 clusters per treatment group, 2 level-2 clusters per level-3 cluster, 15 subjects per level-2 cluster, a level-2 ICC of 0.1, a level-3 icc of 0.20, and an effect size of 0.50.  Treatment is at level 3.

{phang}{cmd:. rdpower crd3, es(.5) n(15) p(2) m(8) icc2(.1) icc3(.2)}{p_end}

{phang}For a three-level cluster randomized design with 8 level-3 clusters per treatment group, 2 level-2 clusters per level-3 cluster, 15 subjects per level-2 cluster, a level-2 ICC of 0.1, a level-3 icc of 0.20, an effect size of 0.50, with a covariate at level 3 that accounts for 10 percent of the variance at level 1, 20 percent of the variance at level 2, and 25 percent of the variance at level 3.  Treatment is at level 3.

{phang}{cmd:. rdpower crd3, es(.5) n(15) p(2) m(8) icc2(.1) icc3(.2) pre1(.1) pre2(.2) pre3(.25) l3vars(1)}{p_end}

{phang}For a two-level randomized block design with 8 clusters, 50 subjects per treatment and control per cluster, an ICC of 0.2, an effect size of 0.50, and an estimated variance of the effect of 0.15.

{phang}{cmd:. rdpower rbd2, es(.5) n(50) m(8) icc2(.2) v(.15)}{p_end}

{phang}For a two-level randomized block design with 8 clusters, 50 subjects per treatment group per cluster, an ICC of 0.2, an effect size of 0.50, and an estimated variance ratio of 0.15, with a single level 2 covariate that accounts for 10 percent of the variation at level 1 and 20 percent of the variation in treatment effects at level 2.

{phang}{cmd:. rdpower rbd2, es(.5) n(50) m(8) icc2(.2) v(.15) pre1(.1) pre2(.2) l2vars(1)}{p_end}

{phang}For a three-level randomized block design with 8 level-3 clusters, 2 level-2 clusters per treatment, 15 subjects per level-2 cluster, a level-2 ICC of 0.1, a level-3 ICC of 0.2, an effect size of 0.50, and an estimated variance of the effect of 0.15.

{phang}{cmd:. rdpower rbd3, es(.5) n(15) p(2) m(8) icc2(.1) icc3(.2) v(.15)}{p_end}

{phang}For a three-level randomized block design with 8 level-3 clusters, 2 level-2 clusters per treatment, 15 subjects per level-2 cluster, a level-2 ICC of 0.1, a level-3 ICC of 0.2, an effect size of 0.50, an estimated variance ratio of 0.15, with a single level-3 covariate that accounts for 10 percent of the variation at level 1 and 20 percent of the variation at level 2, and 25 percent of the variance in the treatment effects at level 3.

{phang}{cmd:. rdpower rbd3, es(.5) n(15) p(2) m(8) icc2(.1) icc3(.2) v(.15) pre1(.1) pre2(.2) pre3(.25) l3vars(1)}{p_end}

{title:Saved results}

{pstd}
{cmd:rdpower} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(samplesize)}}calculated sample size{p_end}
{synopt:{cmd:r(n)}}n{p_end}
{synopt:{cmd:r(m)}}m{p_end}
{synopt:{cmd:r(p)}}p{p_end}
{synopt:{cmd:r(icc2)}}the specified level-2 ICC{p_end}
{synopt:{cmd:r(icc3)}}the specified level-3 ICC{p_end}
{synopt:{cmd:r(level2vars)}}the specified number of level-2 covariates{p_end}
{synopt:{cmd:r(level3vars)}}the specified number of level-3 covariates{p_end}
{synopt:{cmd:r(r2_level3)}}the specified proportion of explained varinace at level 3{p_end}
{synopt:{cmd:r(r2_level2)}}the specified proportion of explained varinace at level 2{p_end}
{synopt:{cmd:r(r2_level1)}}the specified proportion of explained varinace at level 1{p_end}
{synopt:{cmd:r(designeffect)}}the calculated design effect{p_end}
{synopt:{cmd:r(treatmentvariance)}}the specified variance of the treatment effect{p_end}
{synopt:{cmd:r(alpha)}}the alpha level{p_end}
{synopt:{cmd:r(effectsize)}}the specified effect size{p_end}
{synopt:{cmd:r(noncentral)}}the calculated non-centrality parameter of the non-cental t distribution{p_end}
{synopt:{cmd:r(critical)}}the critical t value{p_end}
{synopt:{cmd:r(power)}}the calcuated power{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(type)}}{cmd:design_type}{p_end}

{title:References}

{phang}
Hedges, Larry and Rhoads, Christopher. 2009. Statistical Power Analysis in Education Research (NCSER 2010-3006). Washington, DC: National Center for Special Education Research, Institute of Education Sciences, U.S. Department of Education.
{p_end}

{phang}
Konstantopoulos, Spyros. 2008. The Power of the Test for Treatment Effects in Three-Level Cluster Randomized Designs.  Journal of Research on Educational Effectiveness.  1:1, 66-88.
{p_end}

{phang}
Konstantopoulos, Spyros. 2008. The Power of the Test for Treatment Effects in Three-Level Block Randomized Designs.  Journal of Research on Educational Effectiveness.  1:4, 265-288.
{p_end}

