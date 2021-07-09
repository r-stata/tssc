{smcl}
{hline}
{cmd:help mseffect}{...} 

{hline}

{title:Introduction}

{pstd}
{hi:mseffect} {hline 2} Estimate the mean effect size of (binary/multiple group) treatment on multiple outcomes.
 
{pstd}
This command is a part of the online appendix for Lavy et.al (2016) “Empowering Mothers and Enhancing Early Childhood Investment: Effect on Adults Outcomes and Children Cognitive and Non-Cognitive Skills”. It is designed to calculate the mean effect size on multiple outcome variables (summary index) with the advantage that we account for different weights, reversibility of outcome sign, multiple treatment groups and different types of robust standard errors.
The command can estimate the effect by taking account covariance of treatment effects using a seemingly uncorrelated regression; or direct estimate the effect using a linear regression with missing data imputation (at group means). 


{title:Cite this command}
{pstd}
This command is not the official Stata command. It is issued as a part of online appendix of Lavy et. al (2016). If you would like to use our command for the research, please cite it as such:

{pstd}
{browse "http://papers.nber.org/papers/w22963?utm_campaign=ntw&utm_medium=email&utm_source=ntw":Lavy, Victor, Giulia Lotti, and Zizhong Yan. “Empowering Mothers and Enhancing Early Childhood Investment: Effect on Adults Outcomes and Children Cognitive and Non-Cognitive Skills”. National Bureau of Economic Research, (2016): No. w22963. }

{title:Coded and maintained by}
 	{browse "http://zizhongyan.com":Zizhong Yan}
	Department of Economics, University of Warwick 
 {pstd}
Email {browse "mailto:helloyzz@gmail.com":helloyzz@gmail.com} if you observe any problems.

{title:Description}

{pstd}
When we estimate the average treatment effects on multiple outcomes, 
one may want to use a single statistic to present an aggregate measure of treatment effects. 
However, simply averaging the estimators for the treatment effect is not likely to produce a meaningful statistic 
since different outcomes may have different data scales and outcomes can be related to each other.
To address this concern, we follow the summary-index approach as in Kling, Liebman and Katz (2007). 
The summary index is a special case of the z-score and is identical to the mean effect size of treatment if there is no missing value.
This approach yields a single standardized normal estimator which indicates an aggregate impact of treatment on a class of outcomes.

{pstd}
In the regression specification (with or without covariates), the mean size effect can be acquired through a linear regression without considering the covariance of effects.
Alternatively, we can consider the covariance strucure and therefore adapt a seemingly uncorrelated regression (O'Brien, 1984; Kling, Liebman and Katz, 2007)
(For more details on the implementation, please refer to Lavy, Lotti and Yan (2016) and Kling, Liebman and Katz (2007))

{title:Syntax}

{phang2}
{cmd:mseffect}
		{it: outcome1 outcome2 ...} 
		{ifin} {weight}		,
		{cmd:treat}{cmd:(}{it:treatment}{cmd:)}
		{cmd:controls}{cmd:(}{it:varlist}{cmd:)}
		{cmd:reverse}{cmd:(}{it:outcomes}{cmd:)}
		{cmdab:nosur}
		{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}
		{cmdab:cl:uster}{cmd:(}{it:varname}{cmd:)} 
		{cmdab:de:tail}
		

{phang}
{opt iweight}s and {opt pweight}s are allowed;
see {help weight}.
{p_end}

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt: {cmd:treat}{cmd:(}{it:treatment}{cmd:)}}is required and asks users to specify the binary treatment variable(s). {p_end}
{synopt: {cmd:controls}{cmd:(}{it:varlist}{cmd:)}}allows to add control variables (do not include the treatment variable here) {p_end}
{synopt: {cmd:reverse}{cmd:(}{it:outcomes}{cmd:)}}allows to reverse signs of specific outcomes when calculating the mean effect size{p_end}
{synopt: {cmd:nosur}}is optional to fit the linear regression with missing data imputation (at group means). As a default, the command uses a seemingly uncorrelated regression model.

{synopt :{opth vce(vcetype)}}{it:vcetype}
	may be {opt oim}, {opt r:obust}, or {opt opg}{p_end}
{synopt :{opth cl:uster(varname)}}adjusts
	standard errors for intragroup correlation; implies {cmd:vce(robust)}{p_end}
 {synopt: {cmdab:de:tail}}displays more detailed output (e.g. seemingly uncorrelated regressions and effect size formulas) for the diagnostic purpose{p_end}
{synoptline} 

 
{title:Remarks} 

{pstd}The treatment has to be binary. In the presence of multiple treatment groups (e.g. treatment intensity), one could input multiple treatment dummies in the {cmd:treat} option

{pstd}Please only specify the treatment variable(s) using the {cmd:treat} option. Do not put it in the parentheses for {cmd:control} variables. 

{pstd}If the {cmd:nosur} option is not specified, the command, by default, uses a seemingly uncorrelated regression model to consider the covariance of treatment effects.

{pstd}The white type robust standard errors should be specified using {cmd:vce(robust)} option. 

{pstd}When sampling weights or robust standard errors are used, {cmd:mseffect} uses {cmd:ml} and {cmd:mysureg} to fit a seemingly uncorrelated regression model. The command installs these packages from Stata-press website automatically the first time of use. Or visit {browse "http://www.stata-press.com/data/ml3.html":http://www.stata-press.com/data/ml3.html} for manual installation.

{synoptline}


{marker examples}{...} 

{title:Examples 1: single treatment group}
We use an artificial dataset to illustrate the usage of this command. The data generating process of the artificial data can be found at: http://www2.warwick.ac.uk/fac/soc/economics/staff/zyan/mseffect_DGP.txt

{pstd}Setup{p_end}
{phang2}{cmd:. webuse set http://www2.warwick.ac.uk/fac/soc/economics/staff/zyan}{p_end}
{phang2}{cmd:. webuse Summary_index}{p_end}

{pstd}Estimate the mean effect of {it:Treatment}  on {it:Work Fulltime Hours} and {it: Ave_income}{p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income ,  treat(Treatment) controls( ) }{p_end}

{pstd}And with control variables {it:x1 x2} and {it: x3}{p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income ,  treat(Treatment) controls(x1 x2 x3) }{p_end}

{pstd}And reverse the signs of the outcomes {it: Fulltime} and {it: Ave_income}{p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income ,  treat(Treatment) controls(x1 x2 x3) reverse(Fulltime Ave_income) }{p_end}

{pstd}And with the white standard errors  {p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income ,  treat(Treatment) controls(x1 x2 x3) reverse(Fulltime Ave_income) vce(robust) }{p_end}

{pstd}And with the population weight {it: weight_eb} {p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income [pweight=weight_eb],  treat(Treatment) controls(x1 x2 x3) reverse(Fulltime Ave_income) vce(robust) }{p_end}

{pstd}And show more detailed output {p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income [pweight=weight_eb],  treat(Treatment) controls(x1 x2 x3) reverse(Fulltime Ave_income) vce(robust) details}{p_end}
 
{title:Examples 2: three treatment groups}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse set http://www2.warwick.ac.uk/fac/soc/economics/staff/zyan}{p_end}
{phang2}{cmd:. webuse Summary_index}{p_end}

{pstd}Estimate the mean effect of {it:Treat1, Treat2} and {it:Treat3} on {it:Work Fulltime Hours} and {it: Ave_income} with control variables {it:x1 x2} and {it: x3}{p_end}
{phang2}{cmd:. mseffect Work Fulltime Hours Ave_income ,  treat(Treat1 Treat2 Treat3) controls(x1 x2 x3) }{p_end}
 

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:mseffect} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...} 
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(beta)}}estimated mean effect size on the summary index{p_end}
{synopt:{cmd:r(variance)}}estimated variance of the mean effect size{p_end}
{synopt:{cmd:r(stderr)}}estimated standard error of the mean effect size{p_end}
{synopt:{cmd:r(up95)}}upper bound of the 95% confidence interval{p_end}
{synopt:{cmd:r(low95)}}lower bound of the 95% confidence interval{p_end}
{synopt:{cmd:r(p_value)}}p-value{p_end}
{synopt:{cmd:r(sig_level)}}asterisks for the level of statistic significance (* p < 0.1, ** p < 0.05, *** p < 0.01.){p_end}
 
 {pstd}
Suffixes "1, 2,...,N" on the returns indicate the returns of first, second,..., Nth treatment group respectively.
 

{title:Also see}

{psee}
Online: help for {helpb sureg}, {helpb ml} and {helpb mysureg} if installed.
{p_end}



{title:Bibliography and Sources}

{p 0 2}
Angrist, Joshua D., and Jorn-Steffen Pischke. Mostly harmless econometrics: An empiricist's companion. Princeton university press, (2008).
{p_end}

{p 0 2}
Gould, William, Jeffrey Pitblado, and William Sribney. "Maximum likelihood estimation with Stata." Stata Press (2006).
{p_end}

{p 0 2}
Kling, Jeffrey R., Jeffrey B. Liebman, and Lawrence F. Katz. "Experimental analysis of neighborhood effects." Econometrica 75.1 (2007): 83-119.
{p_end}

{p 0 2}
Lavy, Victor, Giulia Lotti, and Zizhong Yan. “Empowering Mothers and Enhancing Early Childhood Investment: Effect on Adults Outcomes and Children Cognitive and Non-Cognitive Skills”. National Bureau of Economic Research, (2016): No. w22963. 
{p_end}

{p 0 2}
O'Brien, Peter C. "Procedures for comparing samples with multiple endpoints." Biometrics (1984): 1079-1087.
{p_end}


