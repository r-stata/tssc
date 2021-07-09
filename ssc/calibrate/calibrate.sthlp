{smcl}
{* *! version 1.5  11Feb2011}{...}
{cmd:help calibrate}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi: calibrate} {hline 2}}Calibrates survey datasets to population totals{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:calibrate},
{cmdab:mar:ginals}({it:varlist}) {cmdab:popt:ot}({it:matrix}) {cmdab:ent:rywt}({it:varname}) {cmdab:exit:wt}({it:varname}) [{it:options}] 

{p} {cmd: calibrate} takes a sampling weight and converts it to a calibration weight. The variables being calibrated to are listed
in {it:marginals}, and the population totals used in the calibration are in a row matrix {it:poptot}.

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{pstd}{it:Required}{p_end}
{synopt :{cmdab:ent:rywt(}{it:varname}{cmd:)}}the entry weight (selection weight){p_end}
{synopt :{cmdab:exit:wt(}{it:varname}{cmd:)}}the exit (calibrated) weight{p_end}
{synopt :{cmdab:mar:ginals(}{it:varlist}{cmd:)}}variables used for calibration{p_end}
{synopt :{cmdab:popt:ot(}{it:matrix}{cmd:)}}row matrix of population totals{p_end}

{pstd}{it:Options}{p_end}
{synopt :{cmdab:meth:od(}{it:method}{cmd:)}}specifies the calibration method{p_end}
{synopt :{cmdab:qv:ar(}{it:varname}{cmd:)}}scaling variable (default equals 1){p_end}
{synopt :{cmdab:pri:nt(}{it:print}{cmd:)}}controls the amount of printing{p_end}
{synopt :{cmdab:graph:s(}{it:graphs}{cmd:)}}controls the graphs produced{p_end}
{synopt :{cmd:outc(}{it:varname}{cmd:)}}binary variable used for method {it:nonresp} to indicate response{p_end}
{synopt :{cmdab:samp:vars(}{it:varlist}{cmd:)}}additional variables used for the non-response methods{p_end}
{synopt :{cmdab:tol:erance(}{it:real}{cmd:)}}tolerance used in the iterative methods ({it:logistic} and {it:blinear}){p_end}
{synopt :{cmd:maxit(}{it:real}{cmd:)}}maximum number of iterations used in the iterative methods ({it:logistic} and {it:blinear}){p_end}
{synopt :{cmdab:lb:ound(}{it:real}{cmd:)}}minmum value of the ratio {it:exitwt} to {it:entrywt} for method {it:blinear}{p_end}
{synopt :{cmdab:ub:ound(}{it:real}{cmd:)}}maximum value of the ratio {it:exitwt} to {it:entrywt} for method {it:blinear}{p_end}
{synoptline}


{title:Description}

{pstd} {opt calibrate} calibrates survey datasets to external totals. Seven possible methods are available. The {it:linear} and {it:logistic}
methods are the equivalent to Methods 1 and 2 of Deville and S{c a:}rndal (1992).  The bounded linear method ({it:blinear}) is an iterative method that uses the linear
method while also constraining the ratio of the exit weight to the entry weight to be between specified limits (c.f. Singh and Mohl, 1996). 
The non-response methods ({it:nrSS}, {it:nr2A}, {it:nr2B} and {it:nr2C}) assume the dataset contains both responders and non-responders. 
They calibrate the responders to population-level information on the variables in {it:marginals},
while using information about the selected sample on the variables in {it:sampvars}. Method {it:nrSS} is the single-step procedure in
Chapter 8 of S{c a:}rndal and Lundstr{c o:}m (2005). Methods {it:nr2A} and {it:nr2B} are their two-step procedures
with one difference: the intermediate weights obtained after the first step have any negative weights set to zero. Method {it:nr2C} is related to the
other two-step methods. Details of method {it:nr2C} are available on request. 


{pstd} In the special case where the calibration variables are all categorical and the scaling variable is a constant, the logistic method is equivalent to raking (Demming and Stephan, 1940). This case can
also be dealt with using the {it:maxentropy} program.

{pstd} {it:entrywt} is the selection weight of the individual case. It will usually be the reciprocal of the selection probability.
If it has been scaled (for example to sum to the sample size) it will usually be advisable to rescale it to sum to the population size.
The weight {it:exitwt} will be generated (or replaced if it already exits). The population totals are held in the row matrix {it:poptot}. The calibration
variables ({it:marginals}) should be numeric. Categorical variables will usually need to be converted to indicator variables.

{title:Options}

{phang}
{cmdab:meth:od(}{it:method}{cmd:)} specifies the calibration method. {it:linear} is the default. Other methods are {it:logistic},
{it:blinear}, or the non-response methods: {it:nrSS}, {it:nr2A}, {it:nr2B} and {it:nr2C}. 

{phang}
{cmdab:qv:ar(}{it:varname}{cmd:)} is related to the importance of the observation. See (Deville and S{c a:}rndal, 1992) for further details.
When using one of the non-response methods, it is usually advisable to use the default value of {it:qvar}.

{phang}
{cmdab:pri:nt(}{it:print}{cmd:)} controls the amount of printing. Options are  {it:none} (the default), {it:final} (which summarises the final weights)
and {it:all} (which summarises the weights after each iteration). When the method is {it:linear} or {it:nonresp} the options {it:final} and {it:all} are equivalent. 

{phang}
{cmdab:graph:s(}{it:graphs}{cmd:)} controls the number of graphs produced. Options are {it:none} (the default), {it:final}
(which produces a histogram of the exit weight) and {it:all}. The option {it:all} produces two additional graphs: a scatterplot of the exit weight against the
entry weight, and a histogram either of the ratio of the exit weight to the entry weight (for methods {it:linear}, {it:blinear} or {it:nonresp}) or of the
logarithm of the ratio of the exit weight to the entry weight (for method {it:logistic}). 


{phang}
{cmd:outc(}{it:varname}{cmd:)} is a binary variable equal to 1 if the case corresponds to a responder and 0 otherwise.
This is required when a non-response method is used and is ignored otherwise.

{phang}
{cmdab:samp:vars(}{it:varlist}{cmd:)} is a list of variables that are available on the complete sample, both responders and non-reponders.
This is required when a non-response method is used and is ignored otherwise. Variables in {it:marginals} should not be included in {it:sampvars}.

{phang}
{cmdab:tol:erance(}{it:real}{cmd:)} specifies the tolerance for the iterative methods.

{phang}
{cmd:maxit(}{it:real}{cmd:)} specifies the maximum number of iterations to be used by the iterative methods. The default is 15.

{phang}
{cmdab:lb:ound(}{it:real}{cmd:)} Puts a lower bound on the ratio {it:exitwt} to {it:entrywt} for method {it:blinear}. The default is 0.2.

{phang}
{cmdab:ub:ound(}{it:real}{cmd:)} Puts an upper bound on the ratio {it:exitwt} to {it:entrywt} for method {it:blinear}. The default is 5.



{title:Warnings and problems}

{pstd} Calibration can result in negative weights. If this happens {cmd:calibrate} will give a warning. (Note that
the method {it:logistic} ensures that calibration weights are positive). It will also give a warning if the calibration matrix is found to be singular.
This is usually a consequence of collinearity among the marginal variables and the solution is usually to re-calibrate after omitting variables. 

{pstd} Note also that there is no guarantee that a solution to the calibration equations exits. 

{pstd} It is also worth noting that the method {cmd:calibrate} uses to solve the calibration equations involves calculating the inverse of a matrix using the command {it:invsym}.
This limits the number of calibration constraints that can be used to the maximum size of the matrix.
There could also be some problems if the problem is almost singular.

{pstd} A further problem might occur when using the logistic method. This method uses Newton-Raphson to solve the calibration equations,
and might fail to converge, especially if the initial estimate is not close to the solution. The initial estimate {cmd:calibrate} uses is calculated
from the selection weights. Newton-Raphson might fail if the selection weights have been scaled (for example to sum to the sample size).
Rescaling them to sum to the population size will sometimes be a solution.


{title:Examples}

{pstd} To calibrate the {cmd:multistage} dataset. The population consists of 8,000,000 high school seniors. Assume it is known that it is 50% male and 50% female,
and contains 7,000,000 white seniors.

{phang2}{cmd:. use http://www.stata-press.com/data/r9/multistage}{p_end}

{pstd} Convert the categorical variables {cmd:sex} and {cmd:race} into binary indicator variables.

{phang2}{cmd:. tab sex, gen(isex)}{p_end}
{phang2}{cmd:. tab race, gen(irace)}{p_end}

{pstd} Make a row matrix of popultaion totals (male, female, white).

{phang2}{cmd:. matrix M=[4000000, 4000000, 7000000]}{p_end}

{pstd} An example of linear calibration creating an exit weight called wt1:

{phang2}{cmd:. calibrate  , marginals(isex1 isex2 irace1) poptot(M) entrywt(sampwgt) exitwt(wt1)}{p_end}

{pstd} An example of linear calibration with additional printing:

{phang2}{cmd:. calibrate  , marginals(isex1 isex2 irace1) poptot(M) entrywt(sampwgt) exitwt(wt1)   print(all) graphs(all)}{p_end}

{pstd} To check that the weighted sex and race distributions are correct:

{phang2}{cmd:. tab sex [iweight=wt1]}{p_end}
{phang2}{cmd:. tab race [iweight=wt1]}{p_end}

{pstd} It is possible to calibrate to continuous variables. Suppose it is also known that the average weight is 160lbs (so the total weight is 1,280,000,000lbs).

{phang2}{cmd:. matrix M=[4000000, 4000000, 7000000, 1280000000]}{p_end}

{pstd} Linear, logistic or bounded linear calibration can be used. An example of logistic (with printing turned on) is:

{phang2}{cmd:. calibrate  , marginals(isex1 isex2 irace1 weight) poptot(M) entrywt(sampwgt) exitwt(wt2) method(logistic) print(all)}{p_end}

{pstd} Checks:

{phang2}{cmd:. tab sex [iweight=wt2]}{p_end}
{phang2}{cmd:. tab race [iweight=wt2]}{p_end}
{phang2}{cmd:. summ weight [iweight=wt2]}{p_end}


{title:Saved results}

{pstd}
{cmd:calibrate} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(mean)}}mean exit weight{p_end}
{synopt:{cmd:r(min)}}minimum exit weight{p_end}
{synopt:{cmd:r(max)}}maximum exit weight{p_end}
{synopt:{cmd:r(entdeff)}}approximate design effect (one plus the coefficient of variation) of the entry weights{p_end}
{synopt:{cmd:r(exitdeff)}}approximate design effect (one plus the coefficient of variation) of the exit weights{p_end}
{synopt:{cmd:r(sclmin)}}minimum exit weight after re-scaling to have a mean of one{p_end}
{synopt:{cmd:r(sclmax)}}maximum exit weight after re-scaling to have a mean of one{p_end}
{synopt:{cmd:r(sclsd)}}standard deviation of exit weights after re-scaling to have a mean of one{p_end}


{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(Bhat)}}coefficients of the variables in {it:marginals} used in the equation calculating the exit weight{p_end}


{title:Also see}

Calibration can be thought of as a generalisation of post-stratification. The program {cmd:calibest} generalises Stata's post-stratification
estimation commands.


{title:References}

{phang}
Deming, W. E., and F. F. Stephan.  1940.  On a least squares adjustment of a
sample frequency table when the expected marginal totals are known.
{it:Annals of Mathematical Statistics} 11: 427-444.

{phang}
Deville, J.-C., and C.-E. S{c a:}rndal.  1992.  Calibration estimators in
survey sampling.  {it:Journal of the American Statistical Association} 87:
376-382.

{phang}
S{c a:}rndal, C.-E., and S. Lundstr{c o:}m.  2005.  {it Estimation in Surveys with Nonresponse}
New York, Wiley.

{phang}
Singh, A., C. and C. A. Mohl.  1996. Understanding calibration estimators
in survey sampling {it:Survey Methodology} 22: 107-115.
Chichester, UK: Wiley.


{title:Author}

{pstd}John D'Souza{p_end}
{pstd}National Centre for Social Research{p_end}
{pstd}London, England, UK{p_end}
{pstd}John.D'Souza@natcen.ac.uk{p_end}



