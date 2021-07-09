{smcl}
{* *! version 1.1 29january2019}{...}

{title:Title}

{phang}
{bf:pvw} Predictive value weighting for covariate misclassification in logistic regression (pvw)

{title:Syntax}

{p 8 15 2} {cmd:pvw} {varlist}, {opt casesens(real)} {opt contsens(real)} {opt casespec(real)} {opt contspec(real)} {opt outcome}({help varlist:varname})
[ {opt othercov}({help varlist:varlist}) {opt cohort} {opt reps(#)} {opt seed(#)} ]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :*{opt casesens(real)}}the assumed sensitivity in cases{p_end}
{synopt :*{opt contsens(real)}}the assumed sensitivity in controls{p_end}
{synopt :*{opt casespec(real)}}the assumed specificity in cases{p_end}
{synopt :*{opt contspec(real)}}the assumed specificity in controls{p_end}
{synopt :*{opt outcome}({help varlist:varname})}the binary outcome variable{p_end}
{synopt :{opt othercov}({help varlist:varlist})}the other covariates in the analysis model{p_end}
{synopt :{opt cohort}}specifies that bootstrap unstratified resampling be performed{p_end}
{synopt :{opt reps(#)}}how many bootstrap samples to perform{p_end}
{synopt :{opt seed(#)}}set the random number seed to the specified value{p_end}
{synoptline}
{p2coldent :*denotes a required option}{p_end}

{pstd}
{varlist} specifies the covariates in the model for the misclassified variable conditional on outcome and other variables.


{title:Description}

{pstd}
{cmd:pvw} implements the predictive value weighting approach for adjustment for covariate misclassification, as proposed by Lyles and Lin (2010). Using the 
notation of Lyles and Lin (2010), the main varlist lists the covariates in the model for the misclassified variable Z conditional on outcome Y and other variables C.
As noted by Lyles and Lin, correction specification of this model may require interactions between elements of (Y,C), and these can be passed in the varlist
using Stata's factor interaction notation ({help fvvarlist:fvvarlist}).

{pstd}
The {cmd:pvw} command performs predictive value weighting assuming the sensitivity and specificity values are known constants. 

{pstd}
The covariates of the analysis model of interest (except the unobserved misclasified variable X) are specified using the {opt othercov} option, which
can also include factor variables and interactions ({help fvvarlist:fvvarlist}).

{pstd}
P-values and confidence intervals are calculated by {cmd:pvw} using bootstrapping. The default is to perform stratified resampling in the two levels (0,1) of
the outcome, which is appropriate for a case-control design. For a cohort study, the {opt cohort} option should be specified, which instead performs
unstratified bootstrap resampling.

{marker examples}{...}
{title:Examples}

{pstd}Perform predictive value weighting on the low birthweight data, assuming that smoking is misclassified, with sensitivity and specificity assumed
to be 0.9 in low birthweight and normal birthweight observations.{p_end}

{phang2}{cmd:use http://www.stata-press.com/data/r13/lbw.dta, clear}{p_end}
{phang2}{cmd:pvw low age lwt i.race ptl ht ui, casesens(0.9) contsens(0.9) casespec(0.9) contspec(0.9) misclass(smoke) outcome(low) othercov(age lwt i.race ptl ht ui) cohort seed(5412)}{p_end}


{title:References}

{phang}R H Lyles and J Lin. {browse "http://dx.doi.org/10.1002/sim.3971":Sensitivity analysis for misclassification in logistic regression via likelihood methods and predictive value weighting}. Statistics in Medicine 2010; 29: 2297-2309{p_end}


{title:Author}

{pstd}Jonathan Bartlett, University of Bath, UK{break}
j.w.bartlett@bath.ac.uk{break}
{browse "http://thestatsgeek.com":thestatsgeek.com}	


