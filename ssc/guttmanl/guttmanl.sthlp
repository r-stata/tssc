{smcl}
{cmd:help guttmanl}
{hline}

{title:Title}

{p 5}
{cmd:guttmanl} {hline 2} Guttman lower bound reliability coefficients


{title:Syntax}

{p 5 8 2}
Reliability coefficients for data

{p 8 18}
{cmd:guttmanl} {varlist} 
{ifin} {weight}
[{cmd:,} {it:options} ]


{p 5 8 2}
Reliability coefficients from covariance or correlation matrix

{p 8 18}
{cmd:guttmanl} {it:matname} 
[{cmd:,} {opt sd:s(matname2)} ]


{p 5 8 2}
where {it:varlist} is

{p 14 14 2}
[{cmd:(}]{it:varlist}[{cmd:)}]
[ [{cmd:||}] 
[{cmd:(}]{it:varlist}[{cmd:)}] ]

{p 5 8 2}
parentheses around {it:varlist} denote reversed
sign while {cmd:||} indicates split-halves

{p 5 8 2}
{it:matname} is a covariance (or correlation) matrix

{p 5 8 2}
{cmd:aweights} and {cmd:fweights} are allowed; see {help weight}.


{title:Description}

{pstd}
{cmd:guttmanl} computes lower bound reliability coefficients 
as proposed by Guttman (1945).

{pstd}
There are different ways to estimate the split-half reliability 
(lambda 4). As noted by Guttman (1945), any split will qualify 
as a lower bound to reliability. {cmd:guttmanl} considers all 
((2^n)/2 - 1) possible splits to find the maximal lambda 4. This 
is computationally intensive and might not be feasible with a 
large number of items. The {cmd:||} notation may be used to 
estimate lambda 4 for one specific split instead. 

{pstd}
{cmd:guttmanl} optionally applies the method proposed by Hunt 
and Bentler (2015) to estimate the split-half reliability. The 
authors suggest to use a random series of locally optimal lambda 
4 coefficients and then draw quantiles of interest from the 
resulting empirical distribution. This approach is feasible 
with a large number of items and provides less upwardly biased 
estimates in small samples.

{pstd}
Type {cmd:guttmanl} to replay previous results.


{title:Options}

{phang}
{cmd:{ul:l}ambda(}{it:numlist} [{cmd:, not}]{cmd:)} requests 
Guttman's lambda {it:numlist} (not) be estimated. By default 
all six coefficients are computed. The option may also be used 
to replay coefficients.

{phang}
{cmd:{ul:q}uantiles}[{cmd:(}[{it:numlist}] 
[{cmd:,} {it:quantiles_options}]{cmd:)}] 
estimates the {it:numlist} quantiles of lambda 4 from a series of 
locally optimal split-halves (cf. Hunt and Bentler 2015). If not 
specified, {it:numlist} defaults to 0.05 0.5 0.95. The 
{it:quantiles_options} are

{phang2}
{opt r:eps(#)} specifies the number of repetitions, i.e. the 
number of random split-halves. Default is 1,000.

{phang2}
{opt rseed(#)} sets the random-number seed. See {helpb set seed}.

{phang}
{opt a:sis} specifies that the sign (direction) of variables 
(items) be taken as is. Enclosing one or more variable names 
in {it:varlist} in parentheses implies {opt asis}. If not 
specified, the sign of variables is determined using 
{helpb factor:factormat}.  

{phang}
{opt c:asewise}|{opt pair:wise}|{opt em} are mutually exclusive 
and specify the treatment of missing values. 

{phang2}
{opt casewise} is 
the default and specifies only complete cases be used for 
calculations. {opt cw} is a synonym for {opt casewise}.

{phang2}
{opt pairwise} requests pairwise calculation of 
covariances. {cmd:pw} is a synonym for {opt pairwise}.

{phang2}
{opt em} obtains covariances from the EM algorithm used by 
{helpb mi impute mvn}. This approach is suggested for estimating 
reliability coefficients by Izquierdo and Pedrero (2014) and for 
factor analysis by Truxillo (2005). Specify {opt em(em_options)} 
to control the EM process.

{phang}
{opt min(#)} is used with {opt pairwise} or {opt em} to further 
restrict the sample. It includes only cases with at least {it:#} 
non-missing values in {it:varlist}. Default is {cmd:min(1)}, 
meaning all available cases are used.

{phang}
{opt s:td} performs calculations based on standardized 
(mean 0, variance 1) variables (items). 

{phang}
{opt sd:s(matname2)} is used with a correlation matrix as 
input. It may neither be specified with a covariance matrix 
nor with a {it:varlist}.


{title:Example}

{phang2}{cmd:. webuse automiss}{p_end}
{phang2}{cmd:. guttmanl price headroom rep78 trunk weight length turn displ}{p_end}
{phang2}{cmd:. guttmanl price headroom rep78 trunk weight length turn displ , pw std}{p_end}


{title:Saved results}

{pstd}
{cmd:guttmanl} saves the following in {cmd:r()}

{pstd}
Scalars{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:r(lambda}{it:#}{cmd:)}}Guttman's lambda {it:#}{p_end}
{synopt:{cmd:r(k)}}Number of items in the scale{p_end}
{synopt:{cmd:r(N)}}Number of observations
(not with {opt pairwise}){p_end}
{synopt:{cmd:r(reps)}}Number of repetitions
({opt quantiles} only){p_end}

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:guttmanl}{p_end}
{synopt:{cmd:r(varlist)}}variable names (unique){p_end}
{synopt:{cmd:r(signlist)}}sign of variables{p_end}
{synopt:{cmd:r(halves)}}split-half indicators for maximal lambda 4{p_end}
{synopt:{cmd:r(wtype)}}weight type{p_end}
{synopt:{cmd:r(wexp)}}weight expression{p_end}

{pstd}
Matrices{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:r(L4Q)}}lambda 4 quantiles ({opt quantiles} only)
{p_end}
{synopt:{cmd:r(C)}}covariance matrix{p_end}
{synopt:{cmd:r(N)}}pairwise number of observations
({opt pairwise} only){p_end}


{title:References}

{pstd}
Benton, T. (2015). An empirical assessment of Guttman's 
Lambda 4 reliability coefficient. In: Millsap, R. E., 
Bolt, D. M., van der Ark, L.A., Wang, W-C. (Eds.)
{it:Quantitative Psychology Research. The 78th Annual Meeting of the Psychometric}
{it:Society}. Springer: Cham Heidelberg New York Dordrecht London. pp.301–310.

{pstd}
Guttman, L. (1945). A BASIS FOR ANALYZING TEST-RETEST 
RELIABILITY. {it:Psychometrika}, 10(4), 255-282.

{pstd}
Hunt, T. (2013). Lambda4: Collection of Internal Consistency 
Reliability Coefficients. R package version 3.0. 
http://CRAN.R-project.org/package=Lambda4

{pstd}
Hunt, T.D., Bentler, P.M. (2015). Quantile Lower Bounds to 
Population Reliability Based on Locally Optimal Splits
Reliability Coefficients. {it:Psychometrika}, 80(1), 182-195.

{pstd}
Izquierdo, M.C., Pedrero, E.F. (2014). Estimating the 
reliability coefficient of tests in presence of missing 
values. {it:Psicothema}, 26(4), 516-523.

{pstd}
Truxillo, C. 2005. Maximum likelihood parameter estimation 
with incomplete data. Proceedings of the Thirtieth Annual 
SAS(r) Users Group International Conference. 
{browse "http://www2.sas.com/proceedings/sugi30/111-30.pdf":(pdf)}


{title:Acknowledgments}

{pstd}
The code used to find lambda 4 borrows from the R package 
Lambda4 (Hunt, 2013) and code provided by Benton (2015).

{pstd}
Some of the details in the code are borrowed from Joseph Coveney's 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1321890-guttman-s-lambda2-for-estimating-reliability-in-stata?p=1322050#post1322050":{bf:glambda2}}
(posted on Statalist).

{pstd}
A request from Paul van Kessel on 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1321890-guttman-s-lambda2-for-estimating-reliability-in-stata":Statalist}
stimulated this program.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb alpha}{p_end}

{psee}
if installed: {helpb mf_guttmanl:guttmanl()}
{p_end}
