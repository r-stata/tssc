{smcl}
{* *! version 1.0.0 25jun2014}{...}
{cmd:help cmi_test}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:cmi_test} {hline 2}}Implement the conditional moment inequality test proposed by Andrews and Shi(2013) {p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmdab:cmi_test}
    ({it:cmi vars})
	({it:cme vars})
	{it:indepvars}
	{ifin}
	[{cmd:,}
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

{p}{cmd:cmi_test} implements the conditional moment inequality testing procedure proposed in Andrews and Shi(2013) for general moment inequality models with a finite number of conditional moment restrictions and a finite-dimensional parameter. 
Specifically, it tests the null hypothesis: {bf:E}[{it:cmi vars}|{it:indepvars}]>=0 and {bf:E}[{it:cme vars}|{it:indepvars}]=0.
The command allows {it:cmi vars} or {it:cme vars} to be empty. 

{p} {cmd:cmi_test} uses countable hypercubes as the collection of instrumental functions.  
When the dimension of {it:indepvars} is greater than 3, the number of cubes may be too large which cuases long computation time. 
The command allows an alternative method for high dimensional independent variables. The user can select the hd option to opt for this method. 
This option implements the method described in the last paragraph of Section 9 of Anrews and Shi(2013). 


{title:Options}

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
{cmd:cmi_test} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(stat)}}test statistic{p_end}
{synopt:{cmd:r(pval)}}p-value{p_end}
{synopt:{cmd:r(cv01)}}critical value for the 1% sigficiance level{p_end}
{synopt:{cmd:r(cv05)}}critical value for the 5% sigficiance level{p_end}
{synopt:{cmd:r(cv10)}}critical value for the 10% sigficiance level{p_end}
{synopt:{cmd:r(kappa)}}tuning parameter kappa_n{p_end}
{synopt:{cmd:r(B)}}tuning parameter B_n{p_end}
{synopt:{cmd:r(epsilon)}}tuning parameter epsilon{p_end}
{synopt:{cmd:r(rep_cv)}}repetitions for critical values{p_end}
{synopt:{cmd:r(a_obs)}}average number of observations in the smallest cubes{p_end}
{synopt:{cmd:r(r_n)}}index for minimum side-edge lengths {p_end}
{synopt:{cmd:r(ncube)}}number of cubes{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:cmi_test}{p_end}
{synopt:{cmd:r(title)}}"Conditional Moment Inequalities Test"{p_end}
{synopt:{cmd:r(m_ineq)}}varlist for conditional moment inequalities, if any{p_end}
{synopt:{cmd:r(m_eq)}}varlist for conditional moment equalities, if any{p_end}
{synopt:{cmd:r(x)}}varlist for regressors {p_end}

{p2colreset}{...}

{title:Examples} 
Consider a missing data example. 
Let Y be the logarithm of the potential wage after college enrollment. 
The variable Y is observed only for those who actually did enroll in a college (D=1). 
Suppose that the parameter of interest (theta_0) is the cumulative distribution function Y evaluated at log(20). 
Then, the parameter satisfies

E[1(Y<=log(20),D = 1) + 1(D = 0) - theta_0|X1,X2] >=0
E[theta_0 - 1(Y<= log(20), D = 1)|X1,X2] >=0

The command carries out inference on theta_0 using a cross-sectional sample of (Y,D). 

First, open the data set. 

{stata clear all}

{stata use cmitest.dta , clear}

Then, construct the bounds. 

{stata gen lbound = ( Y < log(20) ) * D}
{stata gen ubound = ( Y < log(20) ) * D + 1 - D}

Then, create two conditional moment inequalities. 
 
{stata gen CMI1 = 0.5 - lbound} 
{stata gen CMI2 = ubound - 0.5}

Then, the command is used to test the null hypothesis H_0: theta_0 = 0.5. 

{stata cmi_test (CMI1 CMI2) () X1 X2}

Use the Kolmogorov-Smirnov type statistic: 

{stata cmi_test (CMI1 CMI2) () X1 X2, ks}

Use Max function and the bootstrap critival value:

{stata cmi_test (CMI1 CMI2) () X1 X2, sfunc(3) boot}



{title:References}

{marker AS2013}{...}
{phang}
Andrews, D., and X. Shi. 2013. Inference based on conditional moment inequalities. 
{it:Econometrica}, Vol.81, No. 2, 609-666. 
