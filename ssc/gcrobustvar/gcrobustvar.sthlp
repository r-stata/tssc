{smcl}

{title:Title}
{phang}
{bf:gcrobustvar} {hline 2} Run the VAR-based Granger-causality Test in the Presence of Instabilities

{synoptline}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:gcrobustvar}
depvarlist
{cmd:,} pos(#,#)
[{it:options}]

{synopthdr}
{synoptline}
{synoptset 20 tabbed}{...}
{syntab:Main}
{synopt:{opt depvarlist}} It is a list of dependent variables, that is, all the variables in the VAR.This option is necessary for the program to run. {p_end}

{synopt:{opt pos(#,#)}} It is a numeric list (i.e. numlist in Stata) including two integers indicating the positions of the targeted dependent variable and restricted regressor respectively.
For example, if we are testing whether the second variable in the VAR Granger-causes the first variable in the VAR in the presence of instabilities, then we assign the numeric list as pos(1,2), where the first integer 1 refers to the position of the targeted dependent variable in the VAR and the second integer 2 refers to the position of the targeted restricted regressor in the VAR. This option is necessary for the program to run. {p_end}

{synopt:{opt nocons}} It suppresses the constant term. The default regression includes the constant term.{p_end }

{synopt:{opt horizon(#)}} It specifies the targeted horizon. The default, i.e. not specifying horizon(#), refers to a reduced-form VAR assuming homoskedastic idiosyncratic shocks. When horizon(h) (h >= 0) is specified, the command assumes heteroskedastic and serially correlated idiosyncratic shocks, and chooses the truncation lag used in the estimation of the long run variance. The truncation lag is automatically determined using Newey and West (1994) optimal lag-selection algorithm. Note that horizon(0) refers to a reduced-form VAR assuming heteroskedastic and serially correlated idiosyncratic shocks, and horizon(h) (h > 0) refers to the (h + 1)-step-ahead forecasting model. For example, in a one-year-ahead VAR Local Projection forecasting model with quarterly data, horizon(3) should be specified.{p_end }

{synopt:{opt lags(numlist)}} It is a numeric list that specifies the lags included in the VAR. The default is lags(1 2). This option takes a numlist and not simply an integer for the maximum lag. For example, lags(2) would include only the second lag in the model, whereas lags(1 2) would include both the first and second lags in the model. The shorthand to indicate the range follows numlist in Stata.{p_end }

{synopt:{opt trimming(level)}} It is the trimming parameter. As is standard in the structural break literature, the possible break dates are usually trimmed to exclude the beginning and end of the sample period. If we specify trimming(s), the range where we search for instabilities is set to be [sT, (1-s)T ], where T is the number of total periods. The default is trimming(0.15), which is recommended in the structural break literature and commonly used in practice.{p_end }

{synoptline}
{p2colreset}{...}

{title:References}
{pstd}Barbara Rossi (2005): Optimal tests for nested model selection with underlying parameter instability. Econometric theory, 21(5), pp.962-990.{p_end}

{title:Compatibility and known issues}
{p 8 8 8}

{pstd}The following are required to run the gcrobustvar program: {p_end}
{phang2} . The following files are required: gcrobustvar.ado chowgmmstar3.ado nyblomstar3.ado pvcalc.ado pvalue.mmat {p_end}
{phang2} . The matrices (pvap0opt[34,21], pvapiopt[34,21], pvnybopt[34,21], pvqlropt[34,21]) in pvalue.mmat need to be imported in advance. {p_end}
{phang2} . The gcrobustvar command uses the {help matsqrt} package. It can be found and installed in Stata by typing -findit matsqrt- in the command window. {p_end}


{pstd}The gcrobustvar command uses the {help gmm} package to estimate the coefficients and the variance matrix used in the test. It is hence sensitive to issues inherent to the {help gmm} command.{p_end}