{smcl}
{* 01jun2020}{...}
{cmd:help remr}
{hline}

{title:Title}

{pstd} {cmd:remr} {hline 2} Robust error meta-regression method for dose–response meta-analysis



{title:Syntax}

{p 8 14 2} {cmd: remr} {it:varlist} {ifin}, {opt id(varname)} {opt cat:egory(varname)} [options]
	
{pstd} {it:varlist} should contain either three or four variables in the form of:

{pstd} Three variables:{p_end}
{p2col 9 52 44 2:{it:ES} {it:seES} {it:dose}} effect size, standard error, and dose{p_end}

{p 8 8} Ratio based effect estimates can be entered in this format after log transform.

{pstd} Four variables:{p_end}
{p2col 9 52 53 2:{it:cases} {it:no_cases} {it:total} {it:dose}} cell counts, total of cell counts, and dose from a contingency table row{p_end}

{p 8 8} Results will be presented with log transform for ratio based effect estimates unless {cmd:eform} is specified.

{pstd} In addition to {it:varlist}, {cmd:id} and {cmd:category} variables need to be specified.{p_end}
{p 6 8} - {cmd:id}({it:varname}) specifies the variable for study-specific indicator.{p_end}
{p 6 8} - {cmd:category}({it:varname}) specifies in ascending order (0, 1, 2 to {it:k}) the dose levels within a study. The lowest category level within a study has to be 0. 
This is required in lieu of the dose to enable adequate handling of the same doses repeated within study and missing data.{p_end}



{title:Description}

{pstd} {cmd:remr} performs dose-response meta-analysis using inverse variance weighted least squares (WLS) regression with cluster robust error variances. 
This approach is a special case of the one-stage generalised least squares for trend approach where the covariance need not be imputed from the data.
This method allows the model to include a non-zero intercept to absorb any bias that is not accounted for by the terms in the model but notably the intercept now becomes a coefficient rather than a constant given the use of WLS. 
Weights for the reference doses are imputed, these are equal to the maximum of the within study weights based on the inverse of the variance of the effect sizes in the study. 
This minimises the possible deviation of the regression intercept from the origin without having to force the regression model through the origin.
This method does not require knowledge of the correlation structure of the data within a study, 
because it stacks included effects as a cluster by study and uses the cluster-robust analysis to obtain a robust standard error, 
thus treating observations as independent across clusters but correlated within each cluster.



{title:Modules required}

{pstd} Users need to install {net sj 11-3 st0215_1:xblc} 



{title:Options}

{pstd} {cmd:center}({it:#}) specifies that data should be centered. The center starting value to be used for the data is defined by {it:#}.

{pstd} {cmd:startdose}({it:#1 #2}) is used to make starting doses comparable across studies. It will drop studies with starting values outside the interval {it:#1} to {it:#2}. 
It is not recommended to use a wide range to maintain homogeneity. The range {it:#1} - {it:#2} must contain the {it:#} in center({it:#}). Requires center({it:#}).

{pstd} {cmd:rcs}({it:#}) specifies the number of knots to be used for the restricted cubic spline. The minimum number of knots is 3. Knot values are automatically placed; see help {helpb mkspline}.

{pstd} {cmd:knots}({it:numlist}) specifies the exact location and number of the knots to be used for a restricted cubic spline. The values of these knots must be entered in ascending order.

{pstd} {cmd:reference}({it:#}) specifies the reference dose. When specified the {cmd:graph} and {cmd:table} are recomputed to display differences in predictions from the specified reference value. Requires {cmd:center}({it:#}).

{pstd} {cmd:or} specifies the effect size of interest as odds ratio when data is entered using the four variables syntax (default).

{pstd} {cmd:rr} specifies the effect size of interest as risk ratio when data is entered using the four variables syntax.

{pstd} {cmd:rd} specifies the effect size of interest as risk difference when data is entered using the four variables syntax.

{pstd} {cmd:eform} reports the exponential form of predictions. Must be used with the four variable input for ratio based estimates of effect if results on the natural scale are required.

{pstd} {cmd:table} provides the regression model output and values of doses.

{pstd} {cmd:nograph} suppresses the plot of point and interval estimates of the predictions against the doses.

{pstd} {cmd:bplot} plots the point and interval estimates against the doses and the study data points (bubble plot). {cmd:bplot} cannot be used when a {cmd:reference}({it:#}) has been specified.  



{title:Saved results}

{pstd} {cmd:remr} stores the following in r()

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(output)}} coordinates of point estimates and doses{p_end}
{synopt:{cmd:r(model)}} output table of the regression model{p_end}
{synopt:{cmd:r(doses)}} output table of the doses{p_end}



{title:Examples}

{pstd} The example is taken from Qin Liu  et al.  Comput Stat Data Anal 2009; 53, 4157–4167. https://doi.org/10.1016/j.csda.2009.05.001 {p_end}
{phang2} {cmd:. use http://nicolaorsini.altervista.org/data/bmi_rc, clear} {p_end}

{pstd}	Generate the category variable {p_end}
{phang2} {cmd:. sort id bmi} {p_end}
{phang2} {cmd:. bysort id: gen cat = _n-1} {p_end}

{pstd} Three variables entry - restricted cubic spline with three knots, center at 20, include studies with start doses between 18 to 22 {p_end}
{phang2} {cmd:. remr logor selogor bmi, id(id) cat(cat) rcs(3) center(20) start(18 22)  eform} {p_end}

{pstd} Four variables entry - restricted cubic spline with four knots at 19 24 27 33, center at 20, include studies with start doses between 18 to 22, and bubble plot {p_end}
{phang2} {cmd:. remr case control n bmi, id(id) cat(cat) knots(19 24 27 33) center(20) start(18 22)  bplot eform} {p_end}

{pstd} Testing for linearity (syntax is test __doses2 … __doses(k-1) where k is the number of knots {p_end}
{phang2} {cmd:. test __doses2 __doses3} {p_end}

{pstd} Four variables entry - linear dose response analysis {p_end}
{phang2} {cmd:. remr case control n bmi, id(id) cat(cat) center(20) start(18 22)  bplot eform}{p_end}



{title:Authors}

{pstd} Luis Furuya-Kanamori, Research School of Population Health, Australian National University, Australia {p_end}
{pstd} {browse "mailto:luis.furuya-kanamori@anu.edu.au?subject=REMR Stata enquiry":luis.furuya-kanamori@anu.edu.au} {p_end}
	
{pstd} Chang Xu, Department of Population Medicine, College of Medicine, Qatar University, Qatar

{pstd} Suhail AR Doi, Department of Population Medicine, College of Medicine, Qatar University, Qatar


	
{title:Reference}

{pstd} Xu C, Doi SAR. 2018. The robust error meta-regression method for dose–response meta-analysis. Int J Evid Based Healthc 16:138-144



{title:Funding}

{pstd} This work was supported by Program Grant #NPRP10-0129-170274 from the Qatar National Research Fund (a member of Qatar Foundation). The findings herein reflect the work and are solely the responsibility of the authors.
{pstd} LFK was supported by an Australian National Health and Medical Research Council Fellowship (APP1158469).
