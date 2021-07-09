{smcl}
{cmd:help cluster3}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{hi:cluster3} {hline 2}}Determination of sample size, power, and minimum detectable effect size for three-level cluster randomized trials with continuous outcomes. {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}{cmd:cluster3} [{cmd:,} {it:options}]


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{cmd:power}}compute power{p_end}
{synopt :{cmd:mdes}}compute minimum detectable effect size{p_end}
{synopt :{cmd:obs3}}compute number of level-3 clusters{p_end}
{synopt :{cmd:obs2}}compute number of level-2 sub-clusters{p_end}
{synopt :{cmd:obs1}}compute number of level-1 observations{p_end}

{syntab:Options}
{synopt :{opt a(#)}}the significance level of the test; default is {cmd:a(0.05)}{p_end}
{synopt :{opt p(#)}}the power of the test; default is {cmd:p(0.8)}{p_end}
{synopt :{opt r3(#)}}the level-3 intraclass correlation coefficient; default is {cmd:r3(0)}{p_end}
{synopt :{opt r2(#)}}the level-2 intraclass correlation coefficient, within level-3; default sets r2=r3{p_end}
{synopt :{opt rxy(#)}}the correlation coefficient between the baseline covariate (x) and the outcome (y); default is {cmd:rxy(0)}{p_end}
{synopt :{opt d(#)}}the standardized effect size, delta (b/sd); default is {cmd:d(1)}{p_end}
{synopt :{opt n3(#)}}number of level-3 clusters in each arm; default is {cmd:n3(1)}{p_end}
{synopt :{opt n2(#)}}number of level-2 sub-clusters, per level-3 cluster; default is {cmd:n2(1)}{p_end}
{synopt :{opt n1(#)}}number of level-1 observations, per level-2 sub-cluster; default is {cmd:n1(1)}{p_end}

{synoptline}

{title:Description}

{pstd}{cmd:cluster3} The program ^cluster3^ conducts a generalized power analysis for three-level cluster-randomized trials with, or without, the inclusion of a baseline pretest/covariate.

{title:Updates}

{p 4 7 2}1.  Command updated to include power analysis with and without baseline covariate

{p 4 7 2}2.  Results interface updated to display baseline/covariate correlation.

{p 4 7 2}3.  Options updated to disallow negative sample size inputs for n3, n2, or n1.

{p 4 7 2}4.  Inputs and calculations are now saved as return scalars.

{title:Examples}

{p 5 8 2}1.  Determine power in a 3-level design with no covariates{p_end}
{phang2}{cmd:. cluster3, r3(0.2) r2(0.3) d(0.4) n3(50) n2(5) n1(15) power}

{p 5 8 2}2.  Determine power in a 3-level design with baseline covariate and correlation(x,y) of 0.6 {p_end}
{phang2}{cmd:. cluster3, r3(0.2) r2(0.3) rxy(0.6) d(0.4) n3(50) n2(5) n1(15) power}

{p 5 8 2}3.  Determine minimum detectable effect size in a 3-level design with no covariates {p_end}
{phang2}{cmd:. cluster3, r3(0.2) r2(0.3) p(0.9) n3(50) n2(5) n1(15) mdes}

{p 5 8 2}4.  Determine minimum detectable effect size in a 3-level design with baseline covariate and correlation(x,y) of 0.4 {p_end}
{phang2}{cmd:. cluster3, r3(0.2) r2(0.3) rxy(.4) p(0.9) n3(50) n2(5) n1(15) mdes}

{p 5 8 2}5.  Determine number of clusters in a 3-level design with no covariates{p_end}
{phang2}{cmd:. cluster3, n2(2) n1(12) d(0.25) r3(0.15) r2(0.25) obs3}

{p 5 8 2}6.  Determine number of clusters in a 3-level design with baseline covariate and correlation(x,y) of 0.8 {p_end}
{phang2}{cmd:. cluster3, n2(2) n1(12) d(0.25) r3(0.15) r2(0.25) rxy(0.8) obs3}

{p 5 8 2}7.  Determine number of sub-clusters in a 3-level design with no covariates{p_end}
{phang2}{cmd:. cluster3, n3(50) n1(12) d(0.25) r3(0.15) r2(0.25) obs2}

{p 5 8 2}8.  Determine number of sub-clusters in a 3-level design with baseline covariate and correlation(x,y) of 0.65 {p_end}
{phang2}{cmd:. cluster3, n3(50) n1(12) d(0.25) r3(0.15) r2(0.25) rxy(0.65) obs2}

{p 5 8 2}9.  Determine number of level-1 observations in a 3-level design with no covariates{p_end}
{phang2}{cmd:. cluster3, n3(50) n2(5) d(0.25) r3(0.15) r2(0.25) obs1}

{p 5 8 2}10.  Determine number of level-1 observations in a 3-level design with baseline covariate and correlation(x,y) of 0.65 {p_end}
{phang2}{cmd:. cluster3, n3(50) n2(5) d(0.25) r3(0.15) r2(0.25) rxy(0.65) obs1}

{title:Saved results}

{pstd}{cmd:cluster3} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(alpha)}}Alpha{p_end}
{synopt:{cmd:r(rho3)}}ICC at level-3{p_end}
{synopt:{cmd:r(rho2)}}ICC at level-2{p_end}
{synopt:{cmd:r(rxy)}}Correlation(x,y){p_end}
{synopt:{cmd:r(power)}}Power{p_end}
{synopt:{cmd:r(delta)}}Delta, detectable effect size{p_end}
{synopt:{cmd:r(obs3)}}Number of level-3 observations per treatment arm{p_end}
{synopt:{cmd:r(obs2)}}Number of level-2 observations{p_end}
{synopt:{cmd:r(obs1)}}Number of level-1 observations{p_end}
{synopt:{cmd:r(N)}}Total number of observations (T+C) {p_end}

{title:Author}

{pstd}Wael Moussa{p_end}
{pstd}FHI 360{p_end}
{pstd}Washington, DC{p_end}
{pstd}wmoussa@fhi360.org{p_end}

{title:References}

{pstd}Heo, M. and Leon, A.C., 2008. Statistical power and sample size requirements for three level hierarchical cluster randomized trials. Biometrics, 64(4), pp.1256-1262.{p_end}
{pstd}Bloom, H.S., Richburg-Hayes, L. and Black, A.R., 2007. Using covariates to improve precision: Empirical guidelines for studies that randomize schools to measure the impacts of educational interventions. Educational Evaluation and Policy Analysis, 29(1), pp.30-59.{p_end}

{title:Disclaimer}

{pstd}Any errors are the author's alone. Please email wmoussa@fhi360.org to report any issues.{p_end}

