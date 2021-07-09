{smcl}
{* *! version 1.0.0 13Jul2020}{...}
{cmd:help mivcausal}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:mivcausal } {hline 2}  A command for testing the hypothesis about the signs of the 2SLS weights}{p_end}


{title:Syntax}

{pstd}{cmd:mivcausal} 
	[({it:instd} = {it: instr1 instr2}) {it: indepvars}]
	{ifin}
	[{cmd:,}
	{cmdab:se:ed(#)}
	{cmdab:prec:ision(#)}
	{cmdab:mtd:raws(#)}
	{cmd:rsw}({it:reps = #})
	{cmd:vce}({it:vcetype})]


{title:Description}

{pstd}{cmd:mivcausal} is a command that tests the hypothesis about the signs of the two stage least squares (2SLS) weights. As described in proposition 5 of {browse "https://www.nber.org/papers/w25691":Mogstad, Torgovitsky and Walters (2020)}, the 2SLS estimand can be written as a positively-weighted average of LATEs under certain conditions. This module tests whether the weights are positive when there are two binary instruments and one binary treatment using the following tests:

	1. Bonferroni test
	2. Cox and Shi (2019) test (henceforth, CS test)
	3. Mintest
	4. Romano, Shaikh and Wolf (2014) test (henceforth, RSW test)
	5. Intersection-union test (henceforth, IUT)

{pstd}Please see appendix C of {browse "https://www.nber.org/papers/w25691":Mogstad, Torgovitsky and Walters (2020)} for more details.{p_end}

{pstd}In addition, {cmd:mivcausal} can be used as a post-estimation command after running {help ivregress:ivregress} with the 2sls estimator. In this case, users do not need to specify anything in [({it:instd} = {it: instr1 instr2}) {it: indepvars}]. Otherwise, users need to provide the treatment, two instruments and covariates (if any) in {it:instd}, {it: instr1 instr2} and {it: indepvars} respectively to run the tests. {p_end}

{title:Options}

{phang}
{opt seed} specifies the seed used to simulate the data in the Mintest and the starting seed used in the bootstrap procedure of the RSW test. The default is {cmd:seed(1)}.

{phang}
{opt precision} specifies the number of decimal places in the {it:p}-value. This has to be a positive integer. The default is {cmd:precision(3)}.

{phang}
{opt mtdraws} specifies the number of draws in the simulations for the Mintest. This has to be a positive integer. The default is {cmd:mtdraws(10000)}.

{phang}
{opt rsw} specifies whether the RSW test is applied and the number of bootstrap replications in the RSW test. By default, the RSW test is not applied because of longer computational time. To apply the RSW test, specify the option {cmd:rsw(reps = x)} where {cmd:x} is the number of bootstrap replications. This has to be a nonnegative integer. The option {cmd:rsw()} will run the RSW test with 1,000 bootstrap replications.

{phang}
{bf:vce(}{it:vcetype}{bf:)} specifies the type of standard error reported. Currently, the {cmd:mivcausal} command supports robust ({bf:robust}) or clustered standard errors ({bf:cluster(}{it:varlist}{bf:)}).

{marker remarks}{...}
{title:Remarks}

{pstd}If the binary treatment or instruments do not equal to either 0 or 1, the module will run the test by creating a temporary variable that assigns the larger value as 1 and the smaller value as 0.{p_end}

{marker example}{...}
{title:Examples}

{pstd}Consider the sample data with one covariate ({bf:X}), one binary treatment ({bf:D}), two binary instruments ({bf:Z1} and {bf:Z2}) and one outcome variable ({bf:Y}). The {cmd:mivcausal} command can be applied as follows:{p_end}

{phang2}
First, open the dataset.{p_end}
{phang3}
{bf:. {stata use mivcausal.dta}}

{pstd} {ul:{bf:mivcausal not as a post-estimation command}} {p_end}

{phang2}
The test can be run as follows:{p_end}
{phang3}
{bf:. {stata mivcausal (D = Z1 Z2) X, rsw(reps = 1000)}}

{phang2}
As described above, the RSW test will be skipped if the following command is run instead:{p_end}
{phang3}
{bf:. {stata mivcausal (D = Z1 Z2) X}}

{pstd} {ul:{bf:mivcausal as a post-estimation command}} {p_end}

{phang2}
First, run the 2SLS regression as follows:{p_end}
{phang3}
{bf:. {stata ivregress 2sls Y (D = Z1 Z2) X}}

{phang2}
Then, run the {cmd:mivcausal} command:{p_end}
{phang3}
{bf:. {stata mivcausal, rsw(reps = 1000)}}


{marker results}{...}
{title:Stored results}

After applying the {cmd:mivcausal} command, the followings are stored in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(pval_bon)}}{it:p}-value of the Bonferroni test{p_end}
{synopt:{cmd:r(pval_cs)}}{it:p}-value of the CS test{p_end}
{synopt:{cmd:r(pval_mint)}}{it:p}-value of the Mintest{p_end}
{synopt:{cmd:r(pval_rsw)}}{it:p}-value of the RSW test (if applicable){p_end}
{synopt:{cmd:r(pval_iut)}}{it:p}-value of the IUT{p_end}
{synopt:{cmd:r(seed)}}Seed used{p_end}
{synopt:{cmd:r(precision)}}Number of decimal places in the {it:p}-value{p_end}
{synopt:{cmd:r(mtdraws)}}Number of simulations in the Mintest{p_end}
{synopt:{cmd:r(rswreps)}}Number of bootstrap replications in the RSW test (if applicable){p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:mivcausal}{p_end}
{synopt:{cmd:r(title)}}Testing hypotheses about the signs of the 2SLS weights{p_end}
{synopt:{cmd:r(depvar)}}Name of dependent variable (if applicable){p_end}
{synopt:{cmd:r(instd)}}Instrumented variable(s){p_end}
{synopt:{cmd:r(exogr)}}Exogenous regressor(s) (if applicable){p_end}
{synopt:{cmd:r(insts)}}Instruments{p_end}
{synopt:{cmd:r(vce)}}{it:vcetype} specified in {bf:vce()}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}
{browse "https://github.com/conroylau/":Conroy Lau}{break}
University of Chicago{break}
Chicago, IL{break}
ccplau@uchicago.edu

{pstd}
{browse "https://a-torgovitsky.github.io/":Alexander Torgovitsky}{break}
University of Chicago{break}
Chicago, IL{break}
atorgovitsky@gmail.com

{marker references}{...}
{title:References}

{marker MTW2020}{...}
{phang}
Mogstad, M., A. Torgovitsky and C. R. Walters. 2020.
The Causal Interpretation of Two-Stage Least Squares with Multiple Instrumental Variables.
{it:Working paper}. {browse "https://www.nber.org/papers/w25691"}.

{marker CS2019}{...}
{phang}
Cox, G. and X. Shi. 2019.
A Simple Uniformly Valid Test for Inequalities.
{it:Working paper}. {browse "https://arxiv.org/abs/1907.06317"}.

{marker RSW2014}{...}
{phang}
Romano, J. P., A. M. Shaikh and M. Wolf. 2014.
A Practical Two-step Method for Testing Moment Inequalities.
{it:Econometrica}. 85(5):1979-2002.





