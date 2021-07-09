{smcl}
{* *! version 1.5  5sep2011}{...}
{cmd:help mss} 

{hline}

{title:Title}

{p2colset 8 16 19 2}{...}
{p2col :{cmd: mss} {hline 2}}Heteroskedasticity test for quantile or OLS regressions{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}

{p 8 13 2}
{cmd:mss}  [,{varlist}] 

{phang}{cmd:mss} allows {cmd:fweight}s; see {help weight}.{p_end}



{title:Description}

{pstd}
{cmd:mss} computes the Machado-Santos Silva (2000) test for heteroskedasticity. This test is valid after quantile 
regression estimation and by default the test variables are the fitted values of the dependent variable and its squares
as in the "Special case of the White test"; see Wooldridge (2009, p. 276). Alternative sets of test variables can be 
specified with {it: varlist}. The test is also valid after OLS regressions (see Im, 2000, and Machado and Santos Silva, 
2000).


{title:Remarks}

{pstd}
{cmd: mss} was written by By J.A.F. Machado and J.M.C. Santos Silva and it is not an official Stata command. 
For further help and support, please contact jmcss@essex.ac.uk. Please notice that this software is provided 
as is, without warranty of any kind, express or implied, including but not limited to the warranties 
of merchantability, fitness for a particular purpose and noninfringement. In no event shall the author 
be liable for any claim, damages or other liability, whether in an action of contract, tort or 
otherwise, arising from, out of or in connection with the software or the use or other dealings in 
the software.



{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}MSS test after median regression{p_end}
{phang2}{cmd:. qreg price weight length foreign}{p_end}
{phang2}{cmd:. mss}{p_end}

{pstd}MSS test after 0.25 quantile regression using the regressors as test variables{p_end}
{phang2}{cmd:. qreg price weight length foreign, quantile(.25)}{p_end}
{phang2}{cmd:. mss weight length foreign}{p_end}

{pstd}MSS test after OLS regression {p_end}
{phang2}{cmd:. reg price weight length foreign}{p_end}
{phang2}{cmd:. mss}{p_end}

    {hline}


{title:Saved results}

{pstd}
{cmd:mss} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(mss_chi2)}}MSS test statistic{p_end}
{synopt:{cmd:r(mss_df)}}degrees of freedom of the MSS test{p_end}
{synopt:{cmd:r(mss_p)}}p-value of the MSS test{p_end}


{title:References}

{phang} Im, K.S. (2000), Robustifying the Glejser test of heteroskedasticity. Journal of Econometrics 
97(1), 179-188.{p_end} 
{phang} Machado, J.A.F. and Santos Silva, J.M.C. (2000), Glejser's Test Revisited, Journal of Econometrics, 
97(1), 189-202.{p_end} 
{phang} Wooldridge, J.M. (2009), Introductory Econometrics, 4th edition, Mason (OH): South Western.{p_end}


	

