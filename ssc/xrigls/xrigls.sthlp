{smcl}
{* 01aug2007}{...}
{cmd:help for xrigls}{right:Patrick Royston}
{hline}


{title:Reference Interval Estimation by Generalized Least Squares}


{title:Syntax}

{phang2}
{cmd:xrigls}
{it:yvar xvar}
{ifin}
[{cmd:,} {it:major_options} {it:minor_options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:major_options}}
{synopt :{opt al:pha(#)}}specifies significance level for testing between FP functions{p_end}
{synopt :{opt ce:ntile(# [# ...])}}defines the centiles of yvar|xvar{p_end}
{synopt :{opt cv}}models the S-curve as a coefficient of variation{p_end}
{synopt :{opt det:ail}}displays the final regression models{p_end}
{synopt :{cmd:fp(}[{cmd:m:}{it:term}] [{cmd:s:}{it:term}]{cmd:)}}specifies fractional polynomial models{p_end}
{syntab :{it:minor_options}}
{synopt :{cmdab:cova:rs(}[{cmd:m:}{it:vars}] [{cmd:s:}{it:vars}]{cmd:)}}includes
variables as predictors of the mean and/or SD curve{p_end}
{synopt :{opt cy:cles(#)}}determines the number of fitting cycles{p_end}
{synopt :{opt nogr:aph}}suppresses the graph of the results{p_end}
{synopt :{opt nolea:ve}}prevents the creation of new variables{p_end}
{synopt :{opt noti:dy}}preserves fractional polynomial transformations{p_end}
{synopt :{opt po:wers(powlist)}}defines powers for fractional polynomials{p_end}
{synopt :{cmdab:ro:pts(}[{cmd:m:}{it:mopts}] [{cmd:s:}{it:sopts}]{cmd:)}}determines regression options{p_end}
{synopt :{cmdab:sav:ing(}{it:filename}[{cmd:, replace}]{cmd:)}}saves the graph to a file{p_end}
{synopt :{opt se}}calculates standard errors of estimated centile curves{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
where {it:term} is of the form [{opt powers}] {it:#} [{it:#} ...]|{opt df} {it:#}.


{title:Description}

{pstd}
{opt xrigls} calculates reference intervals for {it:yvar} based on the {it:xvar}- (e.g. age-)
specific mean and standard deviation of {it:yvar}.  {it:yvar} is assumed to be Normally
distributed, conditional on {it:xvar}.


{title:Options}

{dlgtab:Major}

{phang}
{opt alpha(#)} specifies the significance level for testing between degrees of FP for
    the mean and SD curves. Default : 0.05.

{phang}
{opt centile(# [#...])} defines the required centiles of {it:yvar}|{it:xvar}.
Default is 3 and 97 (i.e. a 94% reference interval).

{phang}
{opt cv} models the S-curve as a coefficient of variation.

{phang}
{opt detail} displays the final regression models for the mean and SD curves.

{phang}
{cmd:fp(}[{cmd:m:}{it:term} [{cmd:, s:}{it:term}]{cmd:)
 specifies fractional polynomial models in {it:xvar} for
    the mean and SD curves. {it:term} is of form [{opt powers}] {it:#} [{it:#} ...]|{opt df} {it:#}.  
    The phrase {opt powers} is optional.  The powers should be separated by spaces, 
    for example {cmd:fp(m:powers 0 1, s:powers 2)}. If {opt powers} or {opt df} are not given 
    for any curve, the default is cmd:fp(m:df 4,s:df 2)}. {opt df} {it:#} specifies that the 
    degrees of freedom for the best-fitting FP model are to be at most {it:#} for 
    the curve in question.  The powers are then determined from the data.


{dlgtab:Minor}

{phang}
{cmd:covars(}[{cmd:m:}{it:vars} [{cmd:, s:}{it:vars}]{cmd:)
includes variables as predictors in the regression model for
the mean and/or SD (S) curves.

{phang}
{opt cycles(#)} determines the number of fitting cycles (fit mean, calculate absolute
    residuals, fit absolute residuals, recalculate weights, etc.).  The default
    value of {it:#} is 2: an initial (unweighted) fit for the mean is followed by an
    unweighted fit of the absolute residuals; weights are calculated, and one
    weighted fit for the mean, one weighted fit for the absolute residuals and
    a final weighted fit for the mean are carried out.  

{phang}
{opt nograph} suppresses a plot of {it:yvar} against {it:xvar} with fitted values and reference
    limits superimposed.  The default is to have the graph.

{phang}
{opt noleave} prevents the creation of new variables. The default ({opt leave}) causes new
    variables, appropriately labelled, containing the estimated mean, SD, Z-
    scores for {it:yvar} and also the centiles specified in {opt centile()}, to be created.

{phang}
{opt noselect} specifies that the degree of FP will be that specified in the {opt fp()}
    option. The default is to select a lower order FP if the likelihood ratio
    test has P-value {opt alpha()}.

{phang}
{opt notidy} preserves the variables created in the routine representing the
    fractional polynomials powers of the {it:xvar} used in the analysis.

{phang}
{opt powers(powlist)} specifies powers for FP models. Default {it:powlist}
is -2, -1,-0.5, 0, 0.5, 1, 2, 3 (0 meaning log).

{phang}
{cmd:ropts(}[{cmd:m:}{it:mopts}] [{cmd:,}] [{cmd:s:}{it:sopts}]{cmd:)}
determines the regression options for the mean
    and SD regression models.  Example: {cmd:ropt(m:nocons)} suppresses the constant
    for the mean curve.

{phang}
{cmd:saving(}{it:filename}[{cmd:, replace}] saves the graph to a file
(see {opt nograph}).

{phang}
{opt se} calculates the standard errors of the estimated centile curves.


{title:Remarks}

{pstd}
{it:yvar} is assumed to have a normal (Gaussian) distribution.  If a constant SD is
assumed, it is estimated by the residual mean square in the usual way.
Otherwise, the SD is estimated by regression of the absolute residuals on an FP in
{it:xvar}.  The SD's are the predicted values from this regression, multiplied by
the square root of pi/2 (i.e. 1.2533...).  Since the correct regression for
{it:yvar} should include weights proportional to the reciprocal of the squared SD,
the regression for {it:yvar} is repeated using weights equal to the squared
reciprocal of the fitted SDs. At each iteration, models of lower degree are also 
fitted. The FP with the lowest degree (k), for which the FP with degree k+1 
is not a significantly better fit, is selected. The selection criteria between
models may be specified.

{pstd}
{opt xrigls} displays the deviance (-2 * ln likelihood) for the entire model
(including weights derived from the fitted SD). In general, the lower the
deviance, the better the fit of the model. 


{title:Examples}

{phang}
{cmd:. sysuse auto}

{phang}
{cmd:. xrigls mpg weight, fp(m:1 3,s:2 2) centile(10 90) cycles(3)}

{pstd}
The FP model with powers (1,3) is used for the mean, and the FP model with
powers (2,2) for the SD.  Three cycles are performed. The results are saved in 
new variables. A graph of the resulting 10th, 50th and 90th centiles (or 80%
reference interval) is given.

{phang}
{cmd:. xrigls mpg weight, fp(m:df 2,s:df 2) noselect powers(1 2 3) cv}

{pstd}
The model for the mean of {opt mpg} is the best FP1 function of {opt weight},
and for the CV, the best degree-1 FP function of {opt weight}. The chosen powers
will be a subset of {1,2,3}. A graph of the resulting 94% reference interval 
and new variables are also given.

{phang}
{cmd:. xrigls mpg weight, alpha(0.1) fp(m:df 2,s:df 2)}

{pstd}
For both the mean and SD, a selection will be made between the best degree-1
FP function, linear and constant fits using a significance level of 10% in the
the likelihood-ratio tests.


{title:Stored Results}

{pstd}
{opt xrigls} is an R-class program and saves in the {opt r()} functions:

	{cmd:r(dev)}	deviance of final model
	{cmd:`r(mpow)'}	powers in final FP model for mean curve
	{cmd:`r(spow)'}	powers in final FP model for SD curve


{title:Authors}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London.{break}
pr@ctu.mrc.ac.uk

{pstd}
Eileen Wright, Macclesfield


{title:Also see}

{p 4 13 2}
On-line:  help for {help fracpoly}
