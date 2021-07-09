{smcl}
{* *! version 1.0.6  10aug2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "pssbounds##syntax"}{...}
{viewerjumpto "Description" "pssbounds##description"}{...}
{viewerjumpto "Options" "pssbounds##options"}{...}
{viewerjumpto "Authors" "pssbounds##authors"}{...}
{viewerjumpto "Reference" "pssbounds##reference"}
{viewerjumpto "Citations" "pssbounds##citations"}
{viewerjumpto "Examples" "pssbounds##examples"}{...}
{viewerjumpto "Version" "pssbounds##version"}{...}

{title:Title}

{phang}
{bf:pssbounds} {hline 2} Pesaran, Shin and Smith (2001) test for cointegration.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pssbounds}{cmd:,}
{cmdab:obs:ervations(#)} {cmdab:fstat(#)} {cmdab:k(#)} [{it:tstat(#)} {it:case(#)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required options}

{synopt:{opt obs:ervations(#)}}number of observations{p_end}
{synopt:{opt fstat(#)}}value of f-statistic{p_end}
{synopt:{opt k(#)}}number of regressors{p_end}

{syntab:Additional options}
{synopt:{opt case(#)}}type of case{p_end}
{synopt:{opt tstat(#)}}value of t-statistic{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:pssbounds} displays the necessary critical values to conduct the Pesaran, Shin and Smith (2001) bounds test for cointegration. Critical values using the F-test are the default; users can also include the critical values of the t-test with the option: {cmd:tstat(#)}.

{pstd}
Users can find and download the most up-to-date version of {cmd:pssbounds} at:
 http://andyphilips.github.io/dynamac/.

{pstd}
As discussed in Philips (2018), the upper and lower bounds of the cointegration test are non-standard, and depend on the number of observations: {cmd:obs(#)}, the number of regressors appearing in levels: {cmd:k(#)}, and the restrictions (if any) placed on the intercept and trend: {cmd:case(#)}. Asymptotic critical values are provided by Pesaran, Shin, and Smith (2001), and small-sample critical values by Narayan (2005). The following five cases are possible: 1 (no intercept, no trend), 2 (restricted intercept, no trend), 3 (unrestricted intercept, no trend), 4 (unrestricted intercept, restricted trend), 5 (unrestricted intercept, unrestricted trend). See Pesaran, Shin and Smith (2001) for more details; Case 3 is the most common.
 
{pstd}
{cmd:pssbounds} assumes that you have already run the ARDL-bounds model, ensured white-noise residuals, and have obtained the statistic from an F-test on the restriction that all variables appearing in levels are jointly equal to zero, although {cmd:pssbounds} can be run as a post-estimation command when using the program {cmd:dynardl} (Jordan and Philips Forthcoming) The bounds test for cointegration has three possible outcomes. If the value of the F-statistic lies outside the I(0) critical value (or lower "bound"), the test fails to reject the null hypothesis and we may conclude that all regressors appearing in levels are in fact stationary. If the value of the F-statistic lies outside the I(1) critical value (upper "bound"), the test rejects the null hypothesis and we may conclude that cointegration exists. If the value of the F-statistic lies between the I(0) and I(1) critical values, the test is inconclusive.

{pstd}
{cmd:pssbounds} also provides the critical values of an additional t-test for cointegration using the option {cmd:tstat(#)}. It can be used to test the null hypothesis that the coefficient on the lagged dependent variable is equal to zero, although note that the upper and lower I(0)-I(1) bounds are exactly the opposite as for the F-test. No small-sample critical values are currently available for this test, and no values are available for cases 2 or 4. 

{marker options}{...}
{title:Options}

{dlgtab:Required Options}

{phang}
{opt obs:ervations(#)}
is the number of observations (i.e. length of the series) from the ARDL-bounds model. Since the critical values of the bounds test depend on the size of the sample, this option is required.

{phang}
{opt fstat(#)}
is the value of the F-statistic from the test that all variables appearing in levels are jointly equal to zero. This can be obtained by using {cmd:test}.

{phang}
{opt k(#)}
is the number of regressors appearing in levels in the ARDL-bounds model. Since the critical values of the bounds test depend on the number of regressors, this option is required.

{dlgtab:Additional Options}

{phang}
{opt case(#)}
identifies the type of case of the restrictions on the intercept and/or trend term. Case type can be given in Roman numerals (I,II,III,IV,V) or numerically (1,2,3,4,5). Since the critical values of the bounds test depend on the assumptions placed on the intercept and trend, this option is required.

{phang}
{opt tstat(#)}
is the value of the one-sided t-test that the coefficient on the lagged dependent variable is equal to zero. Only asymptotic critical values are currently available, and only for cases I, III, and V.


{marker authors}{...}
{title:Authors}

{pstd}
Soren Jordan {break}
Department of Political Science {break}
Auburn University  {break}
sorenjordanpols@gmail.com {p_end}

{pstd}
Andrew Q. Philips {break}
Department of Political Science {break}
University of Colorado Boulder {break}
andrew.philips@colorado.edu {p_end}

{marker reference}{...}
{title:Reference}

If you use pssbounds, please cite:

{phang}Jordan, Soren and Andrew Q. Philips. Forthcoming. "Cointegration testing and dynamic simulations of autoregressive distributed lag models". Stata Journal.{p_end}

and:

{phang}Philips, Andrew Q. 2018. "Have your cake and eat it too? Cointegration and dynamic inference from autoregressive distributed lag models." American Journal of Political Science: 62(1): 230-244.{p_end}

{marker citations}{...}
{title:Citations}

{phang}Narayan, Paresh Kumar. 2005. "The Saving and Investment Nexus for China: Evidence from Cointegration Tests." Applied Economics 37(17):1979-1990.

{phang}Pesaran, M Hashem, Yongcheol Shin and Richard J Smith. 2001. "Bounds testing approaches to the analysis of level relationships." Journal of Applied Econometrics 16(3):289-326.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}EXAMPLE 1{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse lutkepohl2}{p_end}
{phang2}{cmd:. tsset}{p_end}

{pstd}Run ARDL-bounds model{p_end}
{phang2}{cmd:. regress d.ln_inv l.ln_inv d.ln_inc l.ln_inc d.ln_consump l.ln_consump}{p_end}

{pstd}F-test on variables appearing in levels{p_end}
{phang2}{cmd:. test l.ln_inv l.ln_inc l.ln_consump}{p_end}

{pstd}Run bounds test{p_end}
{phang2}{cmd:. pssbounds, fstat(2.60) obs(91) case(3) k(2)}{p_end}
{pstd}Since the F-statistic is below the I(0) critical value even at the 10% level, we conclude there is no cointegration and all regressors in levels are stationary.{p_end}

{pstd}EXAMPLE 2{p_end}

{phang2}{cmd:. regress d.ln_inv l.ln_inv d.ln_inc d.ln_consump l.ln_consump, nocon}{p_end}

{pstd}F-test on variables appearing in levels, and obtain t-stat on lagged dependent variable (-2.73){p_end}
{phang2}{cmd:. test l.ln_inv l.ln_consump}{p_end}
 

{pstd}Run bounds test{p_end}
{phang2}{cmd:. pssbounds, fstat(3.83) obs(91) case(1) k(1) tstat(-2.73)}{p_end}
{pstd}The F-statistic is above the I(1) critical value at the 10% level, indicating cointegration. The t-statistic falls below the I(1) critical value at the 5% level, indicating cointegration.{p_end}

{phang} See Jordan and Philips (Forthcoming) for more examples and an in-depth discussion.{p_end}

{marker version}{...}
{title:Version}

version 1.0.6, Aug 10, 2018.

