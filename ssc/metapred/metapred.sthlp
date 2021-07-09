{smcl}
{* *! version 1.0.0 23Aug2020}{...}

{title:Title}

{p2colset 5 17 18 2}{...}
{p2col:{hi:metapred} {hline 2}} Outlier and influence diagnostics for meta-analysis {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 19 2}
{cmd:metapred} {newvar} {ifin} [{cmd:,} {it:statistic}]


{pstd}
Before using {cmd:metapred}, a model must first be estimated using {helpb meta_regress:meta regress}


{marker statistic}{...}
{synoptset 19 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt :{opt rsta:ndard}}Standardized residuals{p_end}
{p2coldent:* {opt rstu:dent}}Studentized (jackknifed) residuals{p_end}
{p2coldent:* {opt dfi:ts}}DFITS{p_end}
{synopt :{opt c:ooksd}}Cook's distance{p_end}
{p2coldent:* {opt w:elsch}}Welsch distance{p_end}
{p2coldent:* {opt cov:ratio}}COVRATIO{p_end}
{p2coldent:* {opth dfb:eta(varname)}}DFBETA for {it:varname}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}Unstarred statistics are available both in and out of sample; 
{cmd:type predict ... if e(sample) ...} if wanted only for the estimation
sample.  Starred statistics are calculated only for the estimation sample,
even when {cmd:if} {cmd:e(sample)} is not specified.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{opt metapred} extends the currently available post-estimation predictions for {helpb meta_regress:meta regress} 
to include standardized residuals, studentized residuals, DFITS, Cook's distance, Welsch distance, and covariate ratio (see Viechtbauer 
and Cheung [2010] for a comprehensive discussion of post-estimation statistics following meta-regression).

{pstd}
Standardized residuals and studentized residuals produced by {opt metapred}  
correspond to those produced by the R package 
METAFOR ({browse "http://www.metafor-project.org/doku.php"}).

{pstd} 
DFITS produced by {opt metapred} are identical to those produced by METAFOR when using fixed-effects regression ({opt metapred} 
currently does not implement the adjustment for random-effects models as suggested in Viechtbauer and Cheung [2010]).

{pstd}
{opt metapred} computes the Cook's distance statistic, covariate ratio and DFBETA according to the formulas used for post estimation following {helpb regress} 
(see {mansection R regresspostestimationMethodsandformulas:Methods and formulas}). As such, the resulting estimates are consistent
with those produced by "predict" following {helpb regress}, but are not consistent with estimates computed in METAFOR.

{pstd}
{opt metapred} offers the Welsch distance metric which is not offered in METAFOR. 

{pstd}
See the Stata Manual entry under {mansection R regresspostestimationPredictions:regression post-estimation predictions} for how to interpret these statistics following
regression. The interpretation following meta regression is the same.  



{title:Options}

{dlgtab:Main}


{phang}
{opt rstandard} calculates the standardized residuals.

{phang}
{opt rstudent} calculates the Studentized (jackknifed) residuals.

{phang}
{opt dfits} calculates DFITS (Welsch and Kuh 1977)
and attempts to summarize the information in the leverage versus 
residual-squared plot into one statistic.  The calculation is 
automatically restricted to the estimation
subsample.

{phang}
{opt cooksd} calculates the Cook's D influence statistic (Cook 1977).

{phang}
{opt welsch} calculates Welsch distance (Welsch 1982) and is a variation on
{opt dfits}.  The calculation is automatically restricted to the estimation
subsample.

{phang}
{opt covratio} covratio calculates COVRATIO (Belsley, Kuh, and Welsch 1980), a measure of the influence 
of the jth observation based on considering the effect on the variance-covariance matrix of the estimates.  
The calculation is automatically restricted to the estimation subsample.

{phang}
{opth dfbeta(varname)} calculates the DFBETA for {it:varname}, the difference
between the regression coefficient when the jth observation is included and
excluded, said difference being scaled by the estimated standard error of the
coefficient.  {it:varname} must have been included among the regressors in the
previously fitted model.  The calculation is automatically restricted to the
estimation subsample.



{title:Examples}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "webuse bcgset, clear":. webuse bcgset, clear}{p_end}

{pstd}Use {help meta_esize:meta esize} to compute effect sizes for the log risk-ratio using a random effects(REML) model {p_end}
{p 4 8 2}{stata "meta esize npost nnegt nposc nnegc, esize(lnrratio) studylabel(studylbl)": . meta esize npost nnegt nposc nnegc, esize(lnrratio) studylabel(studylbl)}{p_end}

{pstd}Use {help meta_regress:meta regress} to estimate the effect of latitute on the effect estimates {p_end}
{p 4 8 2}{stata "meta regress latitude": . meta regress latitude}{p_end}

{pstd}Standardized residuals {p_end}
{p 4 8 2}{stata "metapred esta, rstandard":. metapred esta, rstandard}{p_end}

{pstd}Studentized residuals {p_end}
{p 4 8 2}{stata "metapred estu, rstudent":. metapred estu, rstudent}{p_end}

{pstd}DFITS influence measure{p_end}
{p 4 8 2}{stata "metapred dfits, dfits":. metapred dfits, dfits}{p_end}

{pstd}Cook's distance{p_end}
{p 4 8 2}{stata "metapred cooksd, cooksd":. metapred cooksd, cooksd}{p_end}

{pstd}Welsch distance{p_end}
{p 4 8 2}{stata "metapred wd, welsch":. metapred wd, welsch}{p_end}

{pstd}COVRATIO influence measure{p_end}
{p 4 8 2}{stata "metapred covr, covratio":. metapred covr, covratio}{p_end}

{pstd}DFBETAs influence measure{p_end}
{p 4 8 2}{stata "metapred dfor, dfbeta(latitude)":. metapred dfor, dfbeta(latitude)}{p_end}



{title:Acknowledgments}

{p 4 4 2}
I thank John Moran for advocating that I write this package.


{title:References}

{p 4 8 2}
Belsley, D. A., E. Kuh, and R. E. Welsch. 1980. {it:Regression Diagnostics: Identifying Influential Data and Sources of Collinearity}.  New York: Wiley.

{p 4 8 2}
Cook, R. D. 1977. Detection of influential observations in linear regression. {it:Technometrics} 19: 15-18.

{p 4 8 2}
Viechtbauer, W. and M. W. L. Cheung.  2010. Outlier and influence diagnostics for meta‐analysis. {it:Research synthesis methods} 1(2): 112-125.

{p 4 8 2}
Welsch, R. E. 1982. Influence functions and regression diagnostics. In {it:Modern Data Analysis}, ed. R. L. Launer and A. F. Siegel, 149-169.  New York: Academic Press.

{p 4 8 2}
Welsch, R. E., and E. Kuh. 1977.  Linear Regression Diagnostics.  Technical Report 923-77, Massachusetts Institute of Technology, Cambridge, MA.



{marker citation}{title:Citation of {cmd:metapred}}

{p 4 8 2}{cmd:metapred} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2020). METAPRED: Stata module for computing outlier and influence diagnostics for meta-analysis.{p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb meta}, {helpb meta_regress:meta regress}, {helpb regress_postestimation:regress postestimation}, {helpb metafrag} (if installed) {p_end}

