{smcl}
{* *! 05jun2011}{...}
{cmd:help conddens}
{hline}

{title:Title}


{title:Estimation of a conditional density to correct for measurement error and missing values}


{title:Syntax}

{p 8 17 2}
{cmdab:conddens}
{it:true}
[{it:observed}]
[{it:predictors}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Basic Syntax}
{synopt:{opt mod:el(string)}}parametric family used for measurement error and optionally non-response{p_end}
{synopt:{opt mv:ars(varlist)}}list of variables used to predict the true value if the observed value is missing. Default is constants only.{p_end}
{synopt:{opt mass:point}}adds a mass point at true=observed to the specified model{p_end}
{synopt:{opt modelo:pts(string)}}options passed to {cmd: ml model}{p_end}
{synopt:{opt max:opts(string)}}options passed to {cmd: ml maximize}{p_end}
{synopt:{opt i:nit(string)}}starting values passed to {cmd: ml init}{p_end}
{synopt:{opt sea:rch(string)}}controls {cmd: ml search} or switches it off{p_end}
{synopt:{opt eqn:ames(string)}}equation names for parameter equations{p_end}
{synopt:{opt cmp:lot}}runs a nonparametric regression of {it:true} on the predicted conditional mean.{p_end}
{synopt:{opt cmpo:pts(string)}}passes options {it:string} to {cmd:lpoly} if {opt cmp:lot} is specified.{p_end}
{synopt:{opt mac:rokeep}}prevents program from dropping macros{p_end}

{syntab:Advanced Syntax}
{synopt:{opt likp:rog(name)}}name of program that evaluates the likelihood function for {cmd: ml}. Default is {cmd: condmix}{p_end}
{synopt:{opt pred:ict(string)}}string of 0s and 1s specifying whether parameters are functions of the data{p_end}
{synopt:{opt mpf:unc(string)}}name of the link function for the mass point, if different from Probit{p_end}
{synopt:{opt mixp:ar(string)}}vector specifying the number of input arguments for the functions in the measurement error part of the likelihood function.{p_end}
{synopt:{opt mixt:ransf(string)}}specifies parameter transformations of constants for measurement error in {opt lik:prog}{p_end}
{synopt:{opt mixl:ik(string)}}likelihood function for measurement error passed to {cmd: condmix}{p_end}
{synopt:{opt mixa:rgs(string)}}parameter names for measurement error used in {cmd: condmix}{p_end}
{synopt:{opt mixf:unc(string)}}vector of pointers to functions that generate random draws from the mixture components{p_end}
{synopt:{opt wgtt:rfunc(pointer)}}pointer to function used to transform weights of mixture components for measurement error in {cmd: condmix}{p_end}
{synopt:{opt nrf:unc(pointer)}}pointers to the functions used in the conditional density for missing values{p_end}
{synopt:{opt nrp:ar(string)}}vector specifying the number of input arguments for the functions in the non-response part of the likelihood function.{p_end}
{synopt:{opt nrt:ransf(string)}}specifies parameter transformations of constants for missing values in {opt lik:prog}{p_end}
{synopt:{opt nrl:ik(string)}}likelihood function for missing values passed to {cmd: condmix}{p_end}
{synopt:{opt nra:rgs(string)}}parameter names for missing values used in {cmd: condmix}{p_end}
{synopt:{opt nrwgtt:rfunc(pointer)}}pointer to function used to transform weights of mixture components for missing values in {cmd: condmix}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{hi:fweight}s, {hi:aweight}s, {hi:iweight}s, and {hi:pweight}s are allowed; see {help weight}. Technically, the program should work with {cmd: bootstrap} and {cmd: svy}, 
but I have not tested the results beyond very basic cases.{p_end}

{title:Description}

{pstd}
{cmd:conddens} estimates flexible parametric densities of a true variable conditional on its observed value (which can be missin) and other predictors. The command can be used 
on a validation dataset and the resulting parameter estimates can be passed to a program like {cmd: cddens} in order to obtain consistent estimates if the true values are not available. 
Please see the papers in the {help conddens##ref:References} below for more details on the method and how it can be used. {p_end}

{title:Options}
{pstd}
The basic syntax allows estimation of several parametric models. The advanced syntax can be used to override some default features of these models or to specify more complex models. {p_end}

{dlgtab:Basic Syntax}

{phang}
{opt mod:el(string)} can be used to specify several parametric models for measurement error and missing values. Can contain one or two of the following options, where the first specifies the model for 
measurement error and the second specifies the model for missing values. The options are: {break}
{hi: normal:} normal density with mean as a function of the data{break}
{hi: ltrnorm, rtrnorm, trnorm:} truncated normal distributions (left, right and both sides).{break}
{hi: mixnorm:} mixture of two normal densities with means as functions of the data{break}
{hi: mixltrnorm, mixrtrnorm, mixtrnorm:} 2 component mixtures of truncated normal distributions (left, right and both sides).{break}	
{hi: exp:} exponential density with location parameter (constrained to be >=min(true)) and lambda as a function of the data{break}
{hi: mixexp:} mixture of two exponential densities with location parameters (one constrained to be >=min(true)) and lambda as functions of the data{break}
{hi: weibull:} weibull density with location parameter (constrained to be >=min(true)), scale parameter is a function of the data{break}
{hi: mixweibull} mixture of two weibull densities with location parameters (one constrained to be >=min(true)), scale parameters are a function of the data{break}
{hi: t:} generalized t-distribution with scale and location parameter, mean is a function of the data, df is constrained to be >=1{break}
{hi: mixt:} mixture of two generalized t-distributions with scale and location parameters, means are a function of the data, df is constrained to be >=1{break}
{hi: mixweit:} mixture of a weibull distribution with location parameter and a generalized t-distribution with scale and location parameter{break}
{break}
{hi: Notes:}{break}
1. {opt mod:el()} can only be specified if the likelihood program is {cmd: condmix}.{break}
2. {opt pred:ict()} can be used with {opt mod:el()} to change which parameters are predicted by the data. {opt eqn:ames()} can be used to change the default equation names, {opt mod:el()} overrides all other advanced options.

{phang}
{opt mv:ars(varlist)} can be used to specify a list of variables that predicts the true value if the observed value is missing. The default is to use constants only for the parameters in the model for missing values.

{phang}
{opt mass:point} allows the conditional density to have a masspoint where the true value is equal to the observed value (correct reporting). The masspoint is a function of the data using 
a Probit transformation, i.e. P(true=obs)=normal(Xb), where b is estimated from the data.

{phang}
{opt modelo:pts(string)} can be used to pass any other options to {cmd: ml model}. Options should be entered just as they would be entered after the comma in the {cmd: ml model} statement.

{phang}
{opt max:opts(string)} can be used to pass any other options to {cmd: ml maximize}. Options should be entered just as they would be entered after the comma in the {cmd: ml maximize} statement.

{phang}
{opt i:nit(string)} can be used to pass starting values to {cmd: ml} using {cmd: ml init}. Options should be entered as they would be entered after the comma in the {cmd: ml init} statement. Using a format 
different from {it:equation:par=value} should work, but may cause problems with the default initial values. If the starting values are stored as a matrix in memory, use {hi:init(}matrix {it:matname, initoptions}{hi:)} 
Using {opt init(random)} switches off the default starting values and lets {cmd: ml search} determine them randomly. See {help conddens##start:Starting Values} for more details.

{phang}
{opt sea:rch(string)}{it:string} can be a number to run {cmd: ml search} that many times to find starting values or "off" to switch {cmd: ml search} off.

{phang}
{opt eqn:ames(string)} can be used to specify equation names in {cmd: ml} and should contain a string with one entry for each equation (specifying only some names may cause problems).

{phang}
{opt cmp:lot} performs a misspecification test of the conditional mean function against semiparametric alternatives by running a non-parametric (local polynomial) regression of the true variable on its estimated
conditional mean. Horowitz and Haerdle (1994) describe this idea and derive a formal test using Kernel regression, {opt cmplot} only plots the nonparametric fit with confidence intervals against a 45-degree-line.
Departures from the 45-degree-line indicate misspecification of the conditional mean. Note that the nonparametric regression uses the {cmd:lpoly} command (see {help lpoly} for details), so it only accepts 
{hi:fweights} and {hi:aweights}, ignoring other weights if specified. {opt cmpo:pts(str)} passes {it:str} as options to lpoly. Note further that local polynomial regressions tend to show erratic behaviour in the tails of the distribution. The option currently only works
with the basic syntax. 

{phang}
{opt mac:rokeep} prevents {cmd: conddens} from dropping the internal macros at the end. Can be useful if you want to run postestimation commands.

{dlgtab:Advanced Syntax}

{phang}
{opt likp:rog(name)} makes {cmd: ml} use program {it: name} instead of the default {cmd: condmix} to evaluate the likelihood function. See the documentation for {cmd: ml} to see the requirements such a program has to
meet. 

{phang}
{opt pred:ict(string)} specifies which parameters of the conditional distribution are functions of the data and which are constants. Should be a string of 0s and 1s of the same length as the parameter vector of the 
conditional distribution. A parameter is predicted by the variables in {it: varlist} ({opt mvars} for missing values) if the corresponding entry is 1 and is set to a constant if it is zero. See 
the remark below ({help conddens##pred:Variables Predicting Parameters}) for further details on which variables predict parameters. The ordering of the parameters is {break}
[{it:masspoint parameters}] [{it:parameters for missing values}] {it: parameters for measurement error}. {break}
If the density for missing values or measurement error is a mixture, it is assumed that the first component contains no weight (its weight is 1-sum of other weights) and the weight is always the last parameter of each component. I.e.: {break}
{it: parameters for first component}, [{it:parameters for second component, weight of second component, parameters for third component, weigth of third component,...}]

{phang}
{opt mpf:unc(string)} Can be used to use a different link function for the mass point, e.g. the inverse logit function. Needs to be specified as the name of the function, not as a pointer, e.g. mpfunc(invlogit).

{phang}
{opt mixp:ar(string)} String of numbers specifying the number of input arguments each component of the mixture for measurement error requires. It is assumed that each entry of {opt mixpar} except for the first one is
followed by a weight. mixpar will be repeated to make the number of arguments match the length of the parameter vector returned by {cmd:ml} if possible. For example, the normal density requires two inputs (mean and 
variance), so if the conditional distribution is normal, use {opt mixpar(2)}. A mixture of two normals can be specified by {opt mixpar(2,2)} or {opt mixpar(2)}, a mixture of a normal and a 3-parameter t distribution
requires {opt mixpar(2,3)}.

{phang}
{opt mixt:ransf(string)} In many cases, it is convenient to use parameter transformations in the likelihood functions, e.g. to estimate the log of the variance of a normal distribution in order to make sure
the variance is positive. In order for other programs to use the output of conddens, they have to be supplied with information to undo these transformations and obtain the real parameter. {opt mixt:ransf()} can 
be used to implement this. Each transformation requires three entries in {opt mixt:ransf()}: the first gives the position of the function in {opt mixf:unc()}, the second the position of the parameter in that function
and the third contains either a pointer to the transformation function or a number (which is added to the parameter). E.g. to take the inverse logit of the second argument of the first function in {opt mixf:unc()}, use
{break}{opt mixtransf(1,2,&invlogit())}{break}
To implement multiple transformations, simply add more entries to the list, e.g. to additionally add 5.13 to the first parameter of the second function in {opt mixf:unc()}, use {break}
{opt mixtransf(1,2,&invlogit(),2,1,5.13)}{break}
The same parameter can be transformed multiple times with transformations implemented in the order they appear in {opt mixt:ransf()}. Entries are repeated if entries in {opt mixpar()} are repeated.
For parameters that are constants, {opt mixt:ransf()} will attempt to transform the parameter before output is displayed and stored. If a parameter is transformed already, this is indicated by a "t" 
in the first column of the output table. The untransformed parameters and the original variance matrix are saved in e(b_o) and e(V_o). Entries for which the parameter could not be transformed are 
saved in e(mixtransf) and can be used by other programs.

{phang}
{opt mixl:ik(string)} Can be used to specify the measurement error part of the likelihood function in {cmd: condmix} manually. Requires the arguments to be used to be specified in {opt mixa:rgs()}. These arguments
have to appear as locals in {opt mixl:ik()}, all locals (and globals) in {opt mixl:ik()} have to be preceeded by "\" (e.g. \`par1') to make sure they are not evaluated before being passed to the program. See 
{help ml} for further details on how to specify likelihood functions.

{phang}
{opt mixa:rgs(string)} Needed if the measurement error part of the likelihood function is specified manually using {opt mixl:ik()}. Should contain a list of the arguments used in the likelihood function. E.g. if
the likelihood function is maximized with respect to parameters callen "mean" and "variance", use {opt mixargs(mean variance)}.

{phang}
{opt mixf:unc(string)} Can be used to specify pointers to functions that take random draws from the mixture components of the conditional density if the advanced syntax is used. Currently, this is only passed 
on to other programs in a macro and not actually needed unless you need it stored in a macro.

{phang}
{opt wgtt:rfunc(pointer)} It is often convenient to estimate a transformation of the weights in order to make sure they stay within [0,1]. {opt wgtt:rfunc()} is needed to undo this transformation or to enable other
programs to do this (if weights are not constants). Note that the same transformation is applied to all weights, so contrary to {opt mixtransf(string)}, {opt wgtt:rfunc()} should only contain the pointer to the 
function that transforms the weights (e.g. {opt wgttrfunc(&invlogit())}.

{phang}
{opt nrf:unc(pointer)} Analog of {opt mixf:unc()} for missing values, see there for details. Contrary to {opt mixf:unc()}, {opt nrf:unc()} is not repeated, so it always needs to contain as many entries as there
are components in the mixture for non-response.

{phang}
{opt nrp:ar(string)} Analog of {opt mixp:ar()} for missing values, see there for details. Contrary to {opt mixp:ar()}, {opt nrp:ar()} is not repeated, so it always needs to contain as many entries as there
are components in the mixture for non-response.

{phang}
{opt nrt:ransf(string)} Analog of {opt mixt:ransf()} for missing values, see there for details. Like with the options above, entries are not repeated, so all transformations have to be specified.

{phang}
{opt nrl:ik(string)} Analog of {opt mixl:ik()} for missing values, see there for details. Allows manual specification of the likelihood part for missing values if {cmd: condmix} is used as the likelihood program.

{phang}
{opt nra:rgs(string)} Analog of {opt mixa:rgs()} for missing values, see there for details.

{phang}
{opt nrwgtt:rfunc(pointer)} Analog of {opt wgtt:rfunc()} for missing values, see there for details. 

{title:Remarks}
{marker remarks}
{pstd}
{hi:Required options and defaults}{break}
Usually, you will only need to specify {opt model()}, which overrides all other options except for {opt predict} and {opt eqnames}. 
{opt predict} is required if any part of the model is changed from the default in {opt model}. You can leave out {opt model()} if 
you specify the model with the advanced syntax. Things will usually default to a normal or a mixture of normals if you fail to 
specify required options. I have not worked with the advanced syntax a lot so far and there are many ways to specify it. So if you 
use it, please carefully check that what you get is right and let me know in case anything goes wrong.

{pstd}
{marker pred}
{hi:Variables predicting parameters}{break}
{cmd: conddens} uses all variables except for the first variable (true value) as predictors for the mass point and all parameters for which predict==1 of the measurement error model. Similarly, all 
variables in {opt mvars()} are used as predictors for all parameters of the non-response model that are not constants. If some variables are to be excluded from some parameter equations, this can
be done by defining constraints that set them to zero and passing them to {cmd: ml} using {opt modelopts()}. See {help ml} for more information on how to do this.

{pstd}
{marker transf}
{hi:Transformations}{break}
For computational reasons, it is often desirable to estimate transformations of some parameters (such as the log of a variance to constrain it to be positive). Such transformations need to be undone
in order to use the conditional density to correct other models and can be specified using {opt mixtransf()}, {opt nrtransf()}, {opt wgttrfunc()} and {opt nrwgttrfunc()}. Whenever possible, {cmd: conddens}
implements these transformations for the parameter, the gradient and its enttries in the covariance matrix (using the delta method). No confidence intervals, t-statistics and p-values are displayed for
transformed parameters and they are marked by a "t" at the beginning of the line in the output. The untransformed parameter vector and covariance matrix are saved in e(b_o) and e(V_o). If {cmd: conddens} cannot
perform a transformation that is specified, it saves it in e(mixtransf), e(nrtransf), e(wgttrfunc) or e(nrwgttrfunc).

{pstd}
{marker start}
{hi:Starting Values}{break}
{cmd: conddens} chooses starting values for (mixtures of) t and normal distributions by running regressions, but for all other distributions currently only sets the starting values of the weights to 0.5 if a 
mixture is specified using {opt model()}. {cmd: ml} does a random search, but a lack of decent starting values may prevent or slow down convergence, so if possible, it is a good idea to supply initial values 
using {opt init()}. If convergence fails, the values of the last iteration can be displayed using {cmd: ml report}. Using starting values from a regression for the components of a mixture may not be a good idea
if the components are dissimilar. In such cases starting values should be provided manually (overriding the defaults) or {opt init(random)} can be used to have {cmd:ml search} pick random starting values.

{pstd}
{hi:Other}{break}
If you find any mistakes or have any suggestions for improvements, please send me an email to {browse "mailto:mittag@uchicago.edu":mittag@uchicago.edu}. Feel free to use, change or mutilate this program
for private purpose, but please don't steal it, give due credit. 

{title:Examples}
{hi:Basic Syntax}
{pstd}Mixture of two normal distributions with mass point{p_end}
{phang2}{cmd:. conddens true_inc obs_inc race age gender, model(mixnorm) mass}

{pstd}Mixture of two t-distributions for measurement error and two normal distributions for missing values{p_end}
{phang2}{cmd:. conddens true_inc obs_inc race age gender, model(mixt mixnorm) mvars(race age gender)}

{title:Saved results}

{pstd}
{cmd:conddens} saves all results of {cmd: ml} in {cmd:e()}, see {help ml} and {help maximize} for details. If {opt cmplot} is specified, it also saves the results of {cmd: lpoly} in {cmd:e()}, see {help lpoly} for details.
In addition to these results, {cmd: conddens} saves the following in {cmd:e()}:


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(min)}}smallest value of the observed variable used to estimate the conditional density.{p_end}
{synopt:{cmd:e(max)}}largest value of the observed variable used to estimate the conditional density.{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:conddens}{p_end}
{synopt:{cmd:e(obs)}}name of variable that contains the observed values{p_end}
{synopt:{cmd:e(pred)}}names of predictor variables for measurement error{p_end}
{synopt:{cmd:e(mvars)}}names of predictor variables for non-response{p_end}
{synopt:{cmd:e(mixfunc)}}vector of pointers to functions used in measurement error part of likelihood{p_end}
{synopt:{cmd:e(mixtransf)}}string of parameter transformations for measurement error parameters that have not yet been transformed. See {help conddens##transf:Transformations} for further details.{p_end}
{synopt:{cmd:e(wgttrfunc)}}pointer to function that implements the transformation of the weights for measurement error if they have not yet been transformed.{p_end}
{synopt:{cmd:e(nrfunc)}}vector of pointers to functions used in non-response part of likelihood{p_end}
{synopt:{cmd:e(nrtransf)}}string of parameter transformations for non-response parameters if they have not yet been transformed. See {help conddens##transf:Transformations} for further details.{p_end}
{synopt:{cmd:e(wgttrfunc)}}pointer to function that implements the transformation of the weights for non-response if they have not yet been transformed.{p_end}
{synopt:{cmd:e(mpfunc)}}pointer to function used to transform mass point into probability.{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector after parameter transformations have been implemented{p_end}
{synopt:{cmd:e(b_o)}}original coefficient vector returned by {cmd: ml}{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators after parameter transformations have been implemented{p_end}
{synopt:{cmd:e(V_o)}}original variance-covariance matrix of the estimators returned by {cmd: ml}{p_end}
{synopt:{cmd:e(gradient)}}gradient vector after parameter transformations have been implemented{p_end}
{synopt:{cmd:e(predict)}}Entries of this vector equal 0 if the corresponding parameter of the conditional density is a constant and 1 if it is a function of the variables in {it:varlist} or {opt mvars()}{p_end}
{synopt:{cmd:e(predictors)}}Vector specifying how many parameters of the output vector belong to each equation (i.e. predict each parameter). Same length as {cmd: e(predict)}, but
gives the number of parameters rather than 0/1.{p_end}
{synopt:{cmd:e(mixpar)}}Vector of the number of parameters for the functions of the measurement error part of the likelihood.{p_end}
{synopt:{cmd:e(nrpar)}}Vector of the number of parameters for the functions of the non-response part of the likelihood.{p_end}

{p2colreset}{...}

{title:References}
{marker ref}
{phang}Horowitz, J.L. and W. Haerdle 1994. "Testing a Parametric Model against a Semiparametric Alternative." {it:Econometric Theory.} 10: p. 821-848.{p_end}
{phang}Mittag, N. 2013. "A Method of Correcting for Misreporting Applied to the Food Stamp Program." {it:Unpublished Manuscript}{p_end}
{phang}Mittag, N. 2013. "Imputations: Benefits, Risks and a Method for Missing Data." {it:Unpublished Manuscript}{p_end}

{title:Author}
Nikolas Mittag, University of Chicago
mittag@uchicago.edu
