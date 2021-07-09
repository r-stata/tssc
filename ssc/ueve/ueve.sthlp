{smcl}
{* *! version 1.0.1  10mar2009}{...}
{cmd:help ueve}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:[R] ueve} {hline 2}}Unbiased errors-in-variables estimator (UEVE), 
Errors-in-variables estimator (EVE) and Efficient Wald estimator (EWALD) regressions on grouped data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:ueve}
{depvar}
[{indepvars}]
{ifin}
{weight}
{cmd:,} 
{cmdab:gr:oup(}{it:groupvar}{cmd:)}
[{it:estimator}
{opt l:evel(#)}]


{synoptset 22}{...}
{p2coldent:{it:estimator}}description{p_end}
{synoptline}
{synopt:{opt ueve}}Unbiased errors-in-variables estimator (UEVE), the default{p_end}
{synopt:{opt eve}}Errors-in-variables estimator (EVE){p_end}
{synopt:{opt ewald}}Efficient Wald estimator (EWALD){p_end}
{synoptline}

{p 4 6 2}
{opt xi} is allowed; see {help prefix}.{p_end}
{p 4 6 2}
{cmd:pweight}s, {cmd:iweight}s, {cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}.{p_end}


{title:Description}

{pstd}
{cmd:ueve} fits a linear regression of {depvar} on {it:{help varlist:indepvars}}, 
using one of the three estimators for grouped data: Devereux (2007) errors-in-variables estimator
that is approximately unbiased (UEVE); Deaton (1985) errors-in-variables estimator (EVE) that was shown 
to be equivalent to Jackknife Instrumental Variable Estimator in Devereux (2007); 
and Efficient Wald estimator (EWALD) (Angrist 1991).
Input data should be in individual-level (not grouped) format, as the program uses them to compute estimates of 
variance of sampling errors necessary to correct the bias in the grouping estimator. Since the variance of the sampling 
errors is estimated using group-level sampling variances with ({it:groupsize-1}) in denominator, groups cannot have less 
than two observations. If any group has one observation in it, the program automatically drops such groups from estimation, 
and a warning message is displayed. Variance-covariance matrix of the estimator is calculated using formula following Deaton (1985).


{title:Options}

{dlgtab:Model}

{phang}
{cmd:group(}{it:{help varname:groupvar}})
specifies the name of the grouping variable. The data must be divided into a set of 
mutually exclusive and exhaustive groups indexed by {it:groupvar}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. egen grp=group(south smsa c_city industry)}{p_end}

{pstd}Fit UEVE regression in which observations are grouped by groups {cmd:grp}, which are allocated into mutually exclusive and exhaustive 
supersets indexed by categorical variables {cmd:south, smsa, c_city, industry}. {p_end}
{phang2}{cmd:. ueve  wage race married grade tenure, group(grp)}

{pstd}Fit EWALD regression.{p_end}
{phang2}{cmd:. ueve  wage race married grade tenure, group(grp) ewald}


{title:Saved results}

{pstd}
{cmd:ueve} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(G)}}number of groups{p_end}
{synopt:{cmd:e(r2)}}R-squared (defined using data grouped into means){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ueve}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indepvars)}}{it:indepvars}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker s_refs}{title:References}

{p 0 4}Angrist, Joshua D., 1991. "Grouped-data estimation and testing in simple labor-supply models," 
Journal of Econometrics, Elsevier, vol. 47(2-3), pages 243-266, February.

{p 0 4}Deaton, A. 1985. "Panel data from a time series of cross-sections," Journal of Econometrics, 30, 109-
126.

{p 0 4}Devereux, Paul J., 2007. "Improved Errors-in-Variables Estimators for Grouped 
Data," Journal of Business & Economic Statistics, American Statistical Association, vol. 25, pages 278-287, July. 


{title:Author}

	Aliaksandr Amialchuk, University of Toledo, USA
	aamialc@utnet.utoledo.edu


{title:Also see}

{psee}
Online:  
{manhelp eivreg R};{break}
{manhelp ivregress R};{break}
{manhelp regress R}
{p_end}
