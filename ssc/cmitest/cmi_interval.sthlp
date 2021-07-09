{smcl}
{* *! version 1.0.0 07sep2014}{...}
{cmd:help cmi_interval}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:cmi_intterval} {hline 2}}Constructing the confidence interval proposed by Andrews and Shi(2013) {p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmdab:cmi_interval}
    ({it:lower bound vars})
	({it:upper bound vars})
	{it:indepvars}
	{ifin}
	[{cmd:,}
	{cmdab:lev:el(}{it:real}{cmd:)}
	{cmd:deci(#)}
	{cmd:rnum(#)}
	{cmd:hd}
	{cmd:boot}
	{cmd:ks}
	{cmd:sfunc(#)}
	{cmdab:eps:ilon(}{it:real}{cmd:)}
	{cmd:kap(}{it:real}{cmd:)}
	{cmdab:b:n(}{it:real}{cmd:)}
	{cmd:rep(#)}
	{cmd:seed(#)}
	{cmd:simul} 
	] 
	
{title:Description}

{p}{cmd:cmi_interval} returns confidence intervals for an one-dimensional parameter bounded above and/or below by a finite number of conditional moments by inverting the testing procedure proposed in Andrews and Shi(2013). 
Specifically, the procedure tests the null hypothesis: {bf:E}[theta-{it:lower bound vars}|{it:indepvars}]>=0 and {bf:E}[{it:upper bound vars}-theta|{it:indepvars}]>=0 for scalar thetas to construct the interval.
A candidate number is in the interval if the reported p-value is greater than the given significant level: (1-{cmd:level}).  

{p} {cmd:cmi_interval} uses countable hypercubes as the collection of instrumental functions.  
When the dimension of {it:indepvars} is greater than 3, the number of cubes may be too large which cuases long computation time. 
The command allows an alternative method for high dimensional independent variables. The user can select the hd option to opt for this method. 
This option implements the method described in the last paragraph of Section 9 of Anrews and Shi(2013). 

{title:Options}

{phang}{opt level(real)} sets the confidence level 1-alpha where alpha is the nominal significance level; the default is 0.95. 

{phang}{opt deci(#)} sets the accuracy of the confidence interval bounds as measured by the number of digits after the decimal point. 

{phang}{opt rnum(#)} sets a scalar indicating the minimum side-edge lengths; default is the smallest interger which is greater than {cmd: r(N)}^(DX/2)/2, where DX is the dimension of {it:indepvars}.

{phang}{opt hd} uses alternative method for high dimensional independent variables. This option is designed for three or more covariates; see the description for details. 

{phang}{opt boot} lets the user turn on the bootstrap option. If this option is not used, the command computes the cirtical value based on a Gaussian asymptotic approximation. 

{phang}{opt ks} uses the Kolmogorov-Smirnov type statistic; default is the Cramer-von Mises type statistic. 

{phang}{opt sfunc(#)} sets the function S to specify the form of the test statistic. {cmd: sfunc(1)} yields the modified method of moments or Sum function and {cmd: sfunc(3)} yields the Max function; the default is {cmd: sfunc(1)}.

{phang}{opt epsilon(real)} sets the regularization parameter epsilon for the sample variances; the default is {cmd: epsilon(0.05)}.

{phang}{opt kap(real)} sets a tuning parameter in the data-dependent GMS function phi_n(g); see (4.9) of Andrews and Shi(2013) for details. the default is (0.3 * log({cmd:r(N)}))^(1/2).

{phang}{opt bn(real)} sets a tuning parameter in the data-dependent GMS function phi_n(g); see (4.10) of Andrews and Shi(2013) for details. the default is (0.4 * log({cmd:r(N)})/log(log({cmd:e(N)})))^(1/2).

{phang}{opt rep(#)} sets the number of repetitions for the critical value simulation; the default is {cmd: rep(5001)}.

{phang}{opt seed(#)} sets the seed number for the critical value simulations; the default is {cmd: seed(10000)}. 

{phang}{opt simul} lets the user choose to leave the seed number for the critical value simulations unset. This option should be turned on when the command is used inside a Monte Carlo simulation loop, so as not to interfere with the random number generation process set for the Monte Carlo simulation exercise. 

{title:Stored results}

{pstd}
{cmd:cmitest} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(lbound)}}estimated lower bound{p_end}
{synopt:{cmd:r(ubound)}}estimated upper bound{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(ncube)}}number of cubes{p_end}
{synopt:{cmd:r(kappa)}}tuning parameter kappa_n{p_end}
{synopt:{cmd:r(B)}}tuning parameter B_n{p_end}
{synopt:{cmd:r(epsilon)}}tuning parameter epsilon{p_end}
{synopt:{cmd:r(rep_cv)}}repetitions for critical values{p_end}
{synopt:{cmd:r(a_obs)}}average number of observations in the smallest cubes{p_end}
{synopt:{cmd:r(r_n)}}index for minimum side-edge lengths {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:cmi_interval}{p_end}
{synopt:{cmd:r(title)}}"Conditional Moment Inequalities Interval"{p_end}
{synopt:{cmd:r(lbvar)}}varlist for conditional moment inequalities for the lower bound, if any{p_end}
{synopt:{cmd:r(ubvar)}}varlist for conditional moment inequalities for the upper bound, if any{p_end}
{synopt:{cmd:r(x)}}varlist for regressors {p_end}

{p2colreset}{...}

{title:Examples} 
Consider a missing data example. 

Let Y be the logarithm of the potential wage after college enrollment. The variable Y is observed only for those who actually did enroll in a college (D=1). Suppose that the parameter of interest (theta_0) is the cumulative distribution function Y evaluated at log(20). Then, the parameter satisfies

E[1(Y<=log(20),D = 1) + 1(D = 0) - theta_0|X1,X2] >=0
E[theta_0 - 1(Y<= log(20), D = 1)|X1,X2] >=0

The command carries out inference on theta_0 using a cross-sectional sample of (Y,D) based on the these moment inequalities.

First, open the data set. 

{stata clear all}

{stata use cmitest.dta , clear}

Then, construct the bounds.  

{stata gen lbound = ( Y < log(20) ) * D}
{stata gen ubound = ( Y < log(20) ) * D + 1 - D}

Then, the command is used to return a confidence interval for the parameter of interest. 
 
{stata cmi_interval (lbound) (ubound) X1 X2}

Use Max function and compute 90% confidence interval: 

{stata cmi_interval (lbound) (ubound) X1 X2, sfunc(3) level(0.9)}

Use the lower bound alone and compute up to the second digit: 

{stata cmi_interval (lbound) ( ) X1 X2, deci(2)}


{title:References}

{marker AS2013}{...}
{phang}
Andrews, D., and X. Shi. 2013. Inference based on conditional moment inequalities. 
{it:Econometrica}, Vol.81, No. 2, 609-666. 
