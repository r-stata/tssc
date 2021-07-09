{smcl}
{* 22 May 2016}{...}
{hline}
help for {hi:theildeco}{right:Tim F. Liao, (June 2016)}
{hline}

{title:Refined Theil index decomposition by group and quantile}

{title:Syntax}

	{cmd:theildeco} {it:varname} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
	[, {cmdab:by:g}{cmd:(}{it:groupvar}{cmd:)} {cmdab:a:lpha}{cmd:(}{it:parameter}}
         {cmdab:m:ethod}{cmd:(}{it:parameter}} {cmdab:q:uant}{cmd:(}{it:parameter}} ]

{p 4 4 2} {cmd:fweight}s and {cmd:aweight}s are allowed; see help {help weight}.

{title:Description}
{phang}

{p 4 4 2} 
{cmd:theildeco} estimates a set of Theil inequality index decomposition by further 
decomposing the within-group component. Either Theil's first, or T, index or Theil's
second, or L, index decomposition can be requested. These two indexes were initially
presented by Theil (1967) and have been widely applied in the social and economic 
sciences. A further refinement of decomposing the within-group component is proposed
by Liao (2016a, 2016b). The refinement differentiates between shared versus different 
dispersion in the within-group component (method 0). Alternatively, inequality is decomposed 
by quantile first, and the between-group component of different quantiles can be contrasted. 
The user can choose the number of quantiles, such as 4 (quartiles), 5 (quintiles), or 10 
(deciles). This alternative method (method 1) is also discussed in Liao (2016a, 2016b). The 
user may simply prefer to contrast two percentiles, such as the top 10% versus the remaining 
90% (or method 2). The {cmd: method} option allows the user to choose any of the methods.


{p 4 4 2}
{it: varname} typically is an income variable recorded on the real scale though it can
be another continuous outcome variable. For computing Theil's L decomposition (when alpha is
set to 0), only values > 0 can be analyzed; for computing Theil's T decomposition (when 
alpha is set to 1), only values >= 0 can be analyzed. 

{p 4 4 2}
{it:groupvar} must take positive integer values only greater than 0 such as 1, 2, ..., G. 
To create such a variable from an existing variable, use the {help egen} function {cmd:group}. 
By default, observations with missing values on {it:groupvar} are excluded from calculations.

{p 4 4 2}
Bootstrapped standard errors for any of the scalar estimates can be readily obtained using 
{help bootstrap}. These include the usual decompositon components as well as the refined 
decomposition components and 2 times log ratios for contrasting between-group within-quantile 
components. However, {help bootstrap} may not work with sampling weights.


{title:Options}
{phang}
 
{opt byg} passes on the group variable to compute inequality decompositions by 
population group. This variable is required to obtain any Theil decomposition.

{opt alpha} sets the decomposition of Theil's L (alpha=0) or Theil's T (alpha=1, 
the default).

{opt method} requests for the calculation of decomposition the use of method 0, method 1 
(the default), or method 2. These methods are discussed earlier, with further details
presented in Liao (2016a, 2016b).

{opt quant} chooses number of quantiles to be used for method 1 (an integer) or 
percentile (a value between 1 and 100) to be used for method 2. The default is 5.


{title:Saved results} 

Depending on the method and quantile chosen, the saved results may include some or most
of the following:

{dlgtab:Scalars}
{phang}

    r(Theil)			Theil's index before decomposition

    r(between_T),		between-group component of Theil's index

    r(within_T),		within-group component of Theil's index

    r(between_Tq)		between-quantile component of Theil's index

    r(within_Tq)		within-quantile component of Theil's index

    r(TopMidlnR)		2 times log of the top-quantile between-group 
				to the mid-quantile between group ratio, a BIC-like 
				statistc

    r(BotMidlnR)		2 times log of the bottom-quantile between-group 
				to the mid-quantile between group ratio, a BIC-like
				statistc

    r(TopBotlnR)		2 times log of the top-quantile between-group 
				to the bottom-quantile between group ratio, a BIC-like
				statistc

{dlgtab:Matrices}
{phang}

    r(MeanY),			mean of outcome variable

    r(PopShare)			population share of each group g

    r(IncomeShare)		income (outcome) share of each group g

    r(GroupTheil)		group-specific Theil's index

    r(within_q_between)		between-group component of within-quantile decomposition

    r(within_q_within)		within-group component of within-quantile decomposition


{title:Examples}


{p 4 8 2}{cmd:. theildeco x, byg(sex)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex) a(0)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex) a(0) m(1)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex) a(0) m(1) q(4)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex) a(1) m(1) q(10)}

{p 4 8 2}{cmd:. theildeco x [aw = weight], byg(sex) a(1) m(2) q(90)}

{p 4 8 2}{cmd:. bootstrap r(TopMidlnR): theildeco x,byg(g) a(1) m(1) q(3)}


{title: Examples Using the Auto Dataset}


{p 4 8 2}{cmd:. use auto}

{p 4 8 2}{cmd:. gen origin = foreign + 1}

{p 4 8 2}{cmd:. theildeco mpg, byg(origin)}

{p 4 8 2}{cmd:. theildeco mpg, byg(origin) a(0) m(1) q(3)}

{p 4 8 2}{cmd:. theildeco mpg, byg(origin) a(1) m(2) q(50)}

{p 4 8 2}{cmd:. bootstrap r(TopBotlnR), reps(100): theildeco mpg, byg(origin) a(1) m(2) q(50)}


{title:Author}

{p 4 4 2}Tim F. Liao <tfliao@illinois.edu>{break}
University of Illinois at Urbana-Champaign

{title:Acknowledgements}

{p 4 4 2}The author acknowledges benefiting from viewing various existing Stata ado files. 
Comments and suggestions will be welcome for debugging and updating {cmd: theildeco}.


{title:References}

{p 4 8 2} 
Liao, T.F.2016a. 
Evaluating Distributional Differences in Income Inequality.
{it:Socius}
2: 1{c -}14. (http://srd.sagepub.com/content/2/2378023115627462.full.pdf+html)

{p 4 8 2} 
Liao, T.F.2016b. 
Evaluating Distributional Differences in Income Inequality with Sampling Weights.
{it:Socius}
2 (supplements): 1{c -}6. 
(http://srd.sagepub.com/content/suppl/2016/06/23/2.0.2378023115627462.DC1/SociusTFLiaoExtensions16.pdf)

{p 4 8 2}
Theil, H. 1967.
{it:Economics and Information Theory}. Amsterdam: North-Holland Publishing Company.


