{smcl}
{* *! 28sept2011}{...}
{cmd:help cddens}
{hline}

{title:Title}


{title:Density Estimation under Measurement Error using Auxiliary Information}


{title:Syntax}

{p 8 17 2}
{cmdab:cddens}
{it:observed}
[{it:predictors}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Basic Syntax}
{synopt:{opt cdf}}estimates the cdf instead of the pdf{p_end}
{synopt:{opt cdfv:ar(varlist)}}adds the cdf of each variable in {it:varlist} to the plot if {opt cdf} is specified{p_end}
{synopt:{opt par:ameters(matname)}}name of vector that contains the parameters of the conditional distribution. Required unless {opt model(auto)} is used.{p_end}
{synopt:{opt mod:el(string)}}parametric family of the conditional distribution used for measurement error and optionally non-response{p_end}
{synopt:{opt mv:ars(varlist)}}list of variables used to predict the true value if the observed value is missing. Default is constants only.{p_end}
{synopt:{opt mass:point}}needs to be specified if conditional density contains a mass point{p_end}
{synopt:{help cddens##diopts:{it:kdensity_options}}}options passed to {cmd: kdensity}/{cmd:line}{p_end}
{synopt:{opt d:raws(#)}}number of draws per observation used to integrate over conditional density. Default is 40.{p_end}
{synopt:{opt s:ave(filename [, varlist])}}save draws and variables {it:varlist} using {it:filename}{p_end}
{synopt:{opt t:name(varname)}}name of true, unobserved variable (used in density plot){p_end}
{synopt:{opt ks:mirnov(varname)}}Kolomogorov-Smirnov test whether simulated draws come from same distribution as {it:varname}{p_end}
{synopt:{opt ck:olmogorov(varname [,#])}}Conditional Kolmogorov test whether {it:varname} comes from the conditional distribution specified{p_end}
{syntab:Advanced Syntax}
{synopt:{opt pred:ictors(string)}}comma separated string that contains the number of predictors (incl. constant) for each parameter of the conditional density. 
Needs to be specified if {opt parameters()} does not contain equation names.{p_end}
{synopt:{opt mixf:unc(pointer)}}pointers to the functions used in the conditional density for measurement error.{p_end}
{synopt:{opt mixp:ar(string)}}vector specifying the number of input arguments for the functions in the measurement error part of the likelihood function.{p_end}
{synopt:{opt mixt:ransf(string)}}specifies parameter transformations for measurement error that need to be implemented before drawing from the conditional density.{p_end}
{synopt:{opt wgtt:rfunc(pointer)}}pointer to function used to transform weights of mixture components for measurement error{p_end}
{synopt:{opt mpf:unc(pointer)}}pointer to the function that transforms the mass point into a probability.{p_end}
{synopt:{opt nrf:unc(pointer)}}pointers to the functions used in the conditional density for missing values{p_end}
{synopt:{opt nrp:ar(string)}}vector specifying the number of input arguments for the functions in the non-response part of the likelihood function.{p_end}
{synopt:{opt nrt:ransf(string)}}specifies parameter transformations for missing values that need to be implemented before drawing from the conditional density.{p_end}
{synopt:{opt nrwgtt:rfunc(pointer)}}pointer to function used to transform weights of mixture components for missing values{p_end}

{synoptline}
{p2colreset}{...}
{pstd}
{hi:fweight}s, {hi:aweight}s and {hi:iweight}s are allowed; see {help weight}.{p_end}

{title:Description}

{pstd}
{cmd:cddens} consistently estimates the density of a variable that is only observed with error using parameter estimates of the conditional density of the true 
value given the observed value. Please see the papers in the {help cddens##ref:References} below for more details on the method and how it can be used. {p_end}

{title:Options}
{pstd}
The basic syntax can be used if the conditional distribution comes from (mixtures of) several common parametric distributions. 
The advanced syntax needs to be used if the parameter vector passed to {cmd: cddens} characterizes other densities.{p_end}

{dlgtab:Basic Syntax}

{phang}
{opt cdf} {it:or} {opt cdf(varlist)} makes the program estimate the cdf of the mismeasured variable instead of the pdf, adding any additional variables in {it:varlist} to the plot. If either is specified, 
additional options are passed to {help line} instead of kdensity.

{phang}
{opt par:ameters(matname)} needs to contain the name of the vector in memory in which the parameter estimates of the conditional distribution are stored. The ordering of the parameters in the vector needs
to be as follows: {break}
{it:[mass point parameters] [non-response parameters] measurement error parameters}{break}
If the model for non-response or measurement error contains mixtures of densities, it is assumed that the vector does not contain a weight for the first component 
(as it is implicitly denfined by the other weights) and the weight of each component is located after the parameters of the component, i.e.: {break}
{it:param for component 1, param for component 2, weight for component 2, param for component 3, weight for component 3, ...}{break}
If the vector has equation names, {cmd:cddens} can infer {opt predictors()} from these names, so it does not have to be specified. {opt parameters()} 
is required unless {opt model(auto)} is used.

{phang}
{opt mod:el(string)} can be used to specify several parametric models for measurement error and missing values. Can contain one or two of the following options, where the first specifies the model for 
measurement error and the second specifies the model for missing values. The options are: {break}
{hi: auto:} obtains all information from e(). To be used after {cmd:conddens}, does not require second entry for missing values.{break}
{hi: normal:} (mixture of) normal densities{break}
{hi: ltrnorm, rtrnorm, trnorm:} truncated normal distributions (left, right and both sides).{break}
{hi: mixltrnorm, mixrtrnorm, mixtrnorm:} 2 component mixtures of truncated normal distributions (left, right and both sides).{break}
{hi: exp:} (mixture of) exponential densities with location parameter{break}
{hi: weibull:} (mixture of) weibull densities with location parameter{break}
{hi: t:} (mixture of) generalized t-distribution(s) with scale and location parameter, df is constrained to be >=1{break}
{hi: mixweit:} mixture of a weibull distribution with location parameter and a generalized t-distribution with scale and location parameter{break}
{break}
{hi: Note:} {opt model()} does not set which parameters are predicted by the data and which are constants. If this information cannot be obtained from the equation and parameter names of {opt par:ameters()}, it
needs to be entered manually using {opt pred:ictors()}. See {help cddens##pred:predictors()} for more detail. {opt mod:el()} overrides all advanced options required by the specified model except for 
{opt pred:ictors}. Combining it with advanced options that are not required by the model (such as parameter transformations) should be done with caution.

{phang}
{opt mv:ars(varlist)} can be used to specify a list of variables that predicts the true value if the observed value is missing. The default is to use constants only for the parameters in the model for missing values.

{phang}
{opt mass:point} needs to be specified if the conditional density contains a mass point at {it:true}={it:observed} to inform program that the parameter vector contains parameters for a masspoint.

{phang}
{marker diopts}
{it:display_options} if any options not described here are specified, they will be passed to {cmd: kdensity} (or {cmd:line} if {opt cdf} is specified). See {help kdensity} and {help line} for more details on which options are allowed. 
One should be careful with options that depend on the sample size, since estimation is run on _N*d observations, while the actual sample size is _N (d being the number of simulated draws).

{phang}
{opt d:raws(#)} {cmd: cddens} uses random draws from the conditional density to integrate it out. {opt draws()} gives the number of draws per observation, the default is 40.

{phang}
{opt s:ave(filename [, varlist])} saves the random draws used to simulate the integral in {it:filename.dta} along with the variables in varlist and e(sample). The draws are saved as one column vector, repeating the original 
dataset as many times as specified in {opt draws()}: if the original dataset contains n observations, the saved dataset will contain d*n observations (even if not all n observations are used). However, except for
the simulated variable, all observations after the first n will be missing (they can be filled by repeating the first n observations d times). 

{phang}
{opt t:name(varname)} can be used to specify a variable name that will be used in the output for the latent true variable.

{phang}
{opt ks:mirnov(varname)} tests whether {it:varname} is a sample from the latent true variable by performing a two sample Kolmogorov-Smirnov test whether {it:varname} and the simulated sample from the true distribution 
are drawn from the same distribution. If weights are specified, ksmirnov2.ado needs to be installed or the test will be performed without weights.

{phang}
{opt ck:olmogorov(varname [,#])} performs a conditional Kolmogorov test (Andrews 1997) whether {it:varname} is a sample from the conditional distribution specified. The test is performed separately for observations
subject to measurement error and observations subject to non-response, so it produces two test statistics if a model for non-response is specified. If the optional {it:#} is specified, {it:#} bootstrap iterations
will be used to find the p-value(s) of the test statistic(s). Note that the p-value is calculated under the assumption of iid observations. The test currently only works with the basic syntax, to make it work with 
other models, you will need to add the conditional cdf to the .ado file.

{dlgtab:Advanced Syntax}

{phang}
{marker pred}
{opt pred:ictors(string)} specifies how many elements of the vector in {opt parameters()} belong to each parameter of the conditional distribution. E.g. if the first parameter of the conditional distribution is
predicted by 4 variables and a constant, the first entry of {opt predictors()} should be 5, it should be 1 if the first parameter is a constant. Consequently, the sum of the entries of {opt predictors()} should be
the same as the length of the parameter vector in {opt parameters()}. Required if the parameter vector does not contain equation names that allow {cmd:cddens} to infer this information.

{phang}
{opt mixf:unc(pointer)} should contain pointers to the functions used in the measurement error part of the conditional density (e.g. {opt mixffunc(&rgent() &rgent()} for a mixture of two generalized t-distributions.
{cmd:cddens} will use these pointers to make draws from the conditional density in order to integrate out the measurement error. Note that Stata does not allow pointers to functions that are built-in, so one has
to define a separate function for these. See {help cddens##pointers:Pointers to Functions} for more details. The functions specified in {opt mixf:unc()} are reused if the number specified does not match the length 
of the parameter vector.

{phang}
{opt mixp:ar(string)} String of numbers specifying the number of input arguments for each function in {opt mixfunc()}. It is assumed that each entry of {opt mixpar()} except for the first one is followed by a weight
in the parameter vector in {opt parameters()}. mixpar will be repeated to make the number of arguments match the length of the parameter vector if possible. For example, the normal density requires two inputs (mean and 
variance), so if the conditional distribution is normal, use {opt mixpar(2)}. A mixture of two normals can be specified by {opt mixpar(2,2)} or {opt mixpar(2)}, a mixture of a normal and a 3-parameter t distribution
requires {opt mixpar(2,3)}.

{phang}
{opt mixt:ransf(string)} {opt mixt:ransf()} can be used to transform parameters before they are used in the functions in {opt mixfunc()}. E.g. if the conditional distribution is normal with mean log(Xb), a 
log transformation for the first parameter needs to be specified. Each transformation requires three entries in {opt mixt:ransf()}: the first gives the position of the function in {opt mixf:unc()}, the second 
the position of the parameter in that function and the third contains either a pointer to the transformation function or a number (which is added to the parameter). E.g. to take the inverse logit of the second 
argument of the first function in {opt mixf:unc()}, use
{break}{opt mixtransf(1,2,&invlogit())}{break}
To implement multiple transformations, simply add more entries to the list, e.g. to additionally add 5.13 to the first parameter of the second function in {opt mixf:unc()}, use {break}
{opt mixtransf(1,2,&invlogit(),2,1,5.13)}{break}
The same parameter can be transformed multiple times with transformations implemented in the order they appear in {opt mixt:ransf()}. Entries are repeated if entries in {opt mixpar()} are repeated.

{phang}
{opt wgtt:rfunc(pointer)} Can be specified if the weights of the mixture distribution for measurement error need to be transformed. Note that the same transformation is applied to all weights, so contrary to 
{opt mixtransf(string)}, {opt wgtt:rfunc()} should only contain the pointer to the  function that transforms the weights (e.g. {opt wgttrfunc(&invlogit())}.

{phang}
{opt mpf:unc(pointer)} specifies pointer to the function that transforms the mass point into a probability, i.e. F() such that Pr({it:true}={it:observed})=F(Xb). The default is the Probit function (normal cdf).

{phang}
{opt nrf:unc(pointer)} Analog of {opt mixf:unc()} for missing values, see there for details. Contrary to {opt mixf:unc()}, {opt nrf:unc()} is not repeated, so it always needs to contain as many entries as there
are components in the mixture for non-response.

{phang}
{opt nrp:ar(string)} Analog of {opt mixp:ar()} for missing values, see there for details. Contrary to {opt mixp:ar()}, {opt nrp:ar()} is not repeated, so it always needs to contain as many entries as there
are components in the mixture for non-response.

{phang}
{opt nrt:ransf(string)} Analog of {opt mixt:ransf()} for missing values, see there for details. Like with the options above, entries are not repeated, so all transformations have to be specified.

{phang}
{opt nrwgtt:rfunc(pointer)} Analog of {opt wgtt:rfunc()} for missing values, see there for details. 

{title:Remarks}
{marker remarks}
{pstd}
{hi:Required options and defaults}{break}
Usually, you will need to specify {opt parameters()} and {opt model()}. If the vector in {opt parameters()} does not have equation names, you also need to provide {opt predictors()}. 
If you have just estimated the conditional density and the results are still stored in {cmd:e()}, {opt model(auto)} can be specified by itself.  You can leave out {opt model()} if 
you specify (at a minimum) {opt mixfunc()} and {opt mixpar()}. Things will usually default to a normal or a mixture of normals if you fail to specify required options. I have not 
worked with the advanced syntax a lot so far and there are many ways to specify it. So if you use it, please carefully check that what you get is right and let me know in case anything goes wrong.

{pstd}
{hi:Variables predicting parameters}{break}
{cmd: cddens} uses all variables in {it:observed predictors} as predictors for the mass point and all parameters for which predict!=1 of the measurement error model. Similarly, all 
variables in {opt mvars()} are used as predictors for all parameters of the non-response model that are not constants. If some variables are to be excluded from some parameter equations, the corresponding entry
in the parameter vector should be a zero, it should not be excluded from the vector.

{pstd}
{marker pointers}
{hi:Pointers to Functions}{break}
In order to integrate over the conditional distribution, {cmd: cddens} produces random draws from the conditional distribution for each observation. To do so, it needs to be supplied with pointers to the mata 
functions that generate random draws from the (components of) the conditional density. A pointer to a function is the mata name of the function prefixed with "&" and followed by "()", i.e. &invlogit() is a 
pointer to matas "invlogit" function. See {help m2_pointers##remarks4:Pointers} for more details. These pointers are automatically set with {opt model()}, but need to be supplied through {opt mixfunc()} and {opt nrfunc()} 
when using the advanced syntax. The functions should take as many inputs as specified in {opt mixpar()} and {opt nrpar()} and need to return vectors of random draws from the density that have the same length 
as the input vectors. Since Stata does not allow pointers to built in functions (such as {cmd:rt()}, {cmd:rnormal}, etc.), these have to be replaced by user defined functions. E.g. to use a standard t-distribution,
first define the function as follows in mata:
function mrt(df) return(rt(df))
and then run cddens with option {opt mixfunc(&mrt())}. The same applies to functions used for parameter transformations. The following random number functions are already defined in {cmd:cddens} because the
original functions are built-in functions:{break}
{hi: mrnormal}({it:a,b}): produces random draws from a normal density with mean {it:a} and sd {it:b}{break}
{hi: rexploc}({it:a,b}): produces random draws from an exponential density with location parameter {it:a} and scale parameter {it:b}.{break}
{hi: rweibloc}({it:a,b,c}): produces random draws from a weibull density with location parameter {it:a}, shape parameter {it:b} and scale parameter {it:c}{break}
{hi: rgent}({it:a,b,c}): produces random draws from a generalized t-distribution with location parameter {it:a}, scale parameter {it:b} and degrees of freedom {it:c} (constrained to be >=1){break}
{break}
The following transformation functions are also already defined:{break}
{hi: mabs}({it:a}): returns the absolute value of {it:a}{break}
{hi: mneg}({it:a}): returns the negative value of {it:a} (-1*abs({it:a})).{break}
{hi: mexp}({it:a}): returns e^{it:a}{break}

{pstd}
{hi:Other}{break}
If you find any mistakes or have any suggestions for improvements, please send me an email to {browse "mailto:mittag@uchicago.edu":mittag@uchicago.edu}. Feel free to use, change or mutilate this program
for private purpose, but please don't steal it, give due credit. 

{title:Examples}
{hi:Basic Syntax}
{pstd}Predicting a variable using {it:obs_inc race age gender} and parameters of a mixture of two normal distributions with mass point stored in matrix "par"{p_end}
{phang2}{cmd:. cddens obs_inc race age gender, parameters(par) model(mixnorm) mass}

{pstd}Predicting a variable using {it:obs_inc race age gender} and parameters of a mixture of two t-distributions with mass point for measurement error and a mixture of two normal distributions for 
non-response stored in matrix "par"{p_end}
{phang2}{cmd:. cddens obs_inc race age gender, parameters(par) model(mixt mixnorm) mvars(race age gender)}

{title:Saved results}

{pstd}
{cmd:cddens} saves all results of {cmd: kdensity} and {cmd: summarize, d} in {cmd:e()}, see {help kdensity} and {help summarize} for details. If {opt ksmirnov()} is specified, it will also save the results
of {cmd:ksmirnov}, see {help ksmirnov}. If {opt ckolmogorov} is used, it will additionally save

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(ck)}}Test Statistic for the conditional density of measurement error{p_end}
{synopt:{cmd:e(p_ck)}}bootstrapped p-value of the test statistic for measurement error (optional){p_end}
{synopt:{cmd:e(cknr)}}Test Statistic for the conditional density of non response{p_end}
{synopt:{cmd:e(p_cknr)}}bootstrapped p-value of the test statistic for non response (optional){p_end}
{synopt:{cmd:e(ck_bsi)}}number of bootstrap iterations used to calculate the p-values (optional){p_end}

{p2colreset}{...}

{title:References}
{marker ref}
{phang}Andrews,D.W.K. 1997. A Conditional Kolmogorov Test. {it:Econometrica.} 65(5): p. 1097-1128.{p_end}
{phang}Mittag, N. 2013. "A Method of Correcting for Misreporting Applied to the Food Stamp Program." {it:Unpublished Manuscript}{p_end}
{phang}Mittag, N. 2013. "Imputations: Benefits, Risks and a Method for Missing Data." {it:Unpublished Manuscript}{p_end}

{title:Author}
Nikolas Mittag, University of Chicago
mittag@uchicago.edu
