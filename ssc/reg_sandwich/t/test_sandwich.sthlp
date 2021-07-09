{smcl}
{* *! version 1.0.0  12sep2016}{...}

{title:Title}

{phang}
{bf:test_sandwich} {hline 2} Computes Wald-type tests of parameters estimated by {help reg_sandwich}, using a bias-reduced linearization estimator and small-sample corrections to the test statistic and reference distribution.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: test_sandwich}
{varlist}
[{cmd:,} {it:cons}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt cons}} includes the constant term{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:test_sandwich} uses the supporting mata function
test_sandwich_ftests.mo{p_end}
{p 4 6 2}
{it:* please note that {cmd:test_sandwich} uses the mata workspace for intermediate calculations.}
{it:This can potentially cause conflict with existing matrices. This affects matrices named }
{it:sq_Omega_Ftest, C_Ftest, D_Ftest, Omega_Ftest, V, b, evals, evecs, matrix_Ftest, z_Ftest }
{it:and names of the form X*, PP*, P*_relevant, where * can be any real integer.}{p_end}

{p 4 6 2}
see also {help reg_sandwich}{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:test_sandwich} is a post-estimation command to be run after {help reg_sandwich}. 
It computes a small-sample corrected Wald test of parameters included in {varlist}, using the same sample and weights as in the {it:reg_sandwich} estimation. The variance-covariance matrix of the parameters is based on on a version of the bias-reduced linearization estimator proposed by Bell and McCaffrey (2002) and further developed by Tipton and Pustejovsky (2015) and Pustejovsky and Tipton (2016). The small sample corrections, termed the "approximate Hotelling's T-squared test" by Pustejovsky and Tipton (2016), involve adjustments to both the Wald test statistic and to the reference distribution. The reference distribution is a multiple of an F distribution with numerator degrees of freedom equal to the number of parameter restrictions and denominator degrees of freedom approximated based on a working model for the variance structure.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt cons} includes the constant term in the F-test.

{marker remarks}{...}
{title:Remarks}

{pstd}
Parameters included in {varlist} need to have been estimated by {it:reg_sandwich}.



{marker examples}{...}
{title:Examples}
{phang}{cmd:. use http://masteringmetrics.com/wp-content/uploads/2015/01/deaths.dta}{p_end}
{phang}{cmd:. keep if dtype == 2 & agegr == 2} {p_end}
{phang}{cmd:. xi: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year, cluster(state) absorb(state)}{p_end}
{phang}{cmd:. test_sandwich legal beertaxa}{p_end}


{title:Saved results}
{pstd}
{cmd:test_sandwich} saves the following in {cmd:e()}:
{synoptset 20 tabbed}{...}
{p_end}
{synopt:{cmd:e(F_stat)}} F statistic{p_end}
{synopt:{cmd:e(F_df1)}} degrees of freedom from the numerator{p_end}
{synopt:{cmd:e(F_df1)}} degrees of freedom from the denominator{p_end}
{synopt:{cmd:e(F_pvalue)}} p-value of the F statistic{p_end}
{synopt:{cmd:e(F_eta)}} {it:eta} computed for the F statistic{p_end}

{title:Citation}
{phang}
{cmd:test_sandwich} is not an official Stata command. It is a free contribution to the research community, like a paper.
Please cite it as such:{p_end}

{phang}
Tyszler, M., Pustejovsky, J. E., & Tipton, E. 2017. REG_SANDWICH: Stata module to compute cluster-robust (sandwich) variance estimators with small-sample corrections for linear regression, Statistical Software Components S458352, Boston College Department of Economics. URL: {browse "https://ideas.repec.org/c/boc/bocode/s458352.html"}
{p_end}

{title:Authors}
{phang} Marcelo Tyszler. Sustainable Economic Development and Gender, Royal Tropical Institute, Netherlands. {browse "mailto:m.tyszler@kit.nl":m.tyszler@kit.nl} {p_end}

{phang} James E. Pustejovsky {bf:{it: (Package maintainer)}}. Department of Education Psychology, University of Texas at Austin. {browse "mailto:pusto@austin.utexas.edu":pusto@austin.utexas.edu}{p_end}

{phang} Elizabeth Tipton. Department of Human Development, Teachers College, Columbia University. {browse "mailto:tipton@tc.columbia.edu":tipton@tc.columbia.edu} {p_end}


{title:References}
{phang}
Pustejovsky, James E. & Elizabeth Tipton (2016). 
Small sample methods for cluster-robust variance estimation and hypothesis testing in fixed effects models. 
Journal of Business and Economic Statistics. In Press. DOI: 10.1080/07350015.2016.1247004
{p_end}

{phang}
Elizabeth Tipton and James E. Pustejovsky, 2015. Small-sample adjustments for tests of moderators and model fit 
using robust variance estimation in meta-regression. Journal of Educational and Behavioral Statistics December 2015 vol. 40 no. 6 604-634. 
DOI: 10.3102/1076998615606099
{p_end}

{phang}
Bell, R. M., & McCaffrey, D. F. (2002). Bias reduction in standard errors for linear regression with multi-stage samples. 
Survey Methodology, 28(2), 169–181. 
Retrieved from {browse "http://www.statcan.gc.ca/pub/12-001-x/2002002/article/9058-eng.pdf"}
{p_end}


