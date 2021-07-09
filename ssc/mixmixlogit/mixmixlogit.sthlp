{smcl}
{* version 1.0.0 21February2020}{...}
{cmd: help mixmixlogit}{right: ...}
{hline}

{title:Title}

{phang}
{bf:mixmixlogit} {hline 2} Mixed-Mixed Multinomial Logit Models (also known as Latent Class Mixed Logit or Mixture-of-Normals Logit).


{title:Syntax}

{p 4 4 2} {cmd:mixmixlogit} {depvar} {varlist} {ifin} {cmd:,} {opt id(varname)} {opt gr:oup(varname)} [{opt cl:asses(#)} {opt ccov(varlist)}  {opt from(string)} {opt log:normal(string)} {opt corr}
{opt nrep(#)} {opt burn(#)}  {opt grad:pick(string)} {opt const:raints(numlist)} {it:maximize_options}]{p_end}

{p 4 4 2}Items in [brackets] are optional, {depvar} contains the binary choice variable, and {varlist} contains any explanatory variables that vary by alternative and individual/time.{p_end}


{title:Description}

{pstd}
{cmd:mixmixlogit} is a Stata command that implements the mixed-mixed multinomial logit model (MM-MNL) for binary dependent variable data.
It generalises both 'mixed logit' and 'latent class logit' by allowing for multiple latent types in the underlying data that are each characterised
by a distribution of random parameters (as opposed to latent class logit, which assumes a homogeneous coefficient vector for each
latent type, and mixed logit that allows for a distribution of random parameters for a single type of consumer or agent).{p_end}

{p 4 4 2}It is based on the following utility equation:{p_end}

{p 4 4 2}U_{njt} = beta_{n} X_{njt} + e_{njt}{p_end}

{p 4 4 2}for person n = 1, 2, ..., N, choice alternative j = 1, 2, ..., J, and time period t = 1, 2, ..., T. U is the utility of alternative j at time t for 
person n, X is a vector of alternative-specific covariates (i.e. they must vary across alternatives in the choice set), and e is the idiosyncratic error component
that is assumed to be i.i.d. extreme value. beta_(n) is a person-specific vector of coefficients that is defined as:{p_end}

{p 4 4 2}beta_{n} ~ MVN(beta_s, Sigma_s) with probability w_{n,s} for s = 1, ..., S.{p_end}

{p 4 4 2}Accordingly, the vector beta_{n} is drawn from one of a number of multivariate normal distributions with a vector of means beta_(s) and standard deviations Sigma_(s). w_{n,s} 
determine the probability that the individual belongs to each latent type s.{p_end}

{p 4 4 2}This model was first considered in Keane and Wasi (2013) and Greene and Hensher (2013). Keane et al. (2020) apply the model to the Medicare Part D prescription drug insurance market among retired individuals in the 
United States, and relied on this code to estimate the coefficients and posterior probabilities. The data should be set up in Stata to have something like the following structure:{p_end}

{cmd}
    n	group	j	t	choice	x1	x2
    1	  1	1	1	  0	0	4
    1	  1	2	1	  0	6	3
    1	  1	3	1	  1	5	8
    1	  2	1	2	  0	3	0
    1	  2	2	2	  1	3	0
    1	  2	3	2	  0	1	1
    2	  3	1	1	  1	5	0
    2	  3	2	1	  0	2	3
    2	  3	3	1	  0	0	5
    2	  4	1	2	  0	5	2
    2	  4	2	2	  1	3	0
    2	  4	3	2	  0	8	1       {txt}


{p 4 4 2}There should be more than one x variable in the model. Cross-sectional choice data (i.e. does not feature more than one period) will
work with the code, but it is unlikely that the algorithm will converge to a solution. These type of models rely on repeated choice experiments across the same individuals
to accurately estimate the heterogeneity between latent types and within types.{p_end}

{p 4 4 2}Additionally, the code is able to model the latent type probabilities, w_{n,s}, as a logit (or ordered logit when there are three latent type) of individual-specific
covariates. The 'ccov' option allows the user to enter individual-specific covariates that may plausibly impact on their type assignment. For an application of this, see
Keane et. al. (2020) that allows for health conditions that affect cognition in retired individuals to increase their chance of belonging to more confused types of consumers of 
prescription drug insurance in the US. The paper also provides an illustration on how constraints can be used in these types of models to test economic theory.{p_end}

{p 4 4 2}Simulated choices can be computed post-estimation using the reported coefficients, standard deviations, and the posterior type probabilities. The command does not have an
option to generate the predicted choices as they must be simulated and require assumptions that are best left to the user to explicitly decide (since both type assignment and coefficient 
vectors are probabilistic in this model).{p_end}


{title:Options}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt id(varname)}}Required: {it:varname} is the variable that identifies each individual.{p_end}

{synopt:{opt gr:oup(varname)}}Required: {it:varname} is the variable that identifies each individual and time pair (i.e. each choice occasion). If using cross-sectional data, set group to be the same variable as id.{p_end}

{synopt:{opt cl:asses(#)}}Specifies the number of classes or latent types to estimate. Defaults to 2, and the maximum number allowed is 4.{p_end}

{synopt:{opt ccov(varlist)}}{it:varlist} contains individual-specific covariaties (e.g. income or gender) that may impact the probability of 
belonging to certain latent types. The coefficient to these variables, called gamma in the output, are positive if the covariate increases
the probability of belonging to latent types with a higher number, and vice versa if negative.{p_end}

{synopt:{opt from(matname)}}Inputs the starting values for the algorithm. If not specified, the command will run {cmd:lclogit} prior to estimation
and use the outputs as the starting values for the mean beta coefficients across types and the type probabilities. {it:matname} must be dimension 1xp, where p is the total number of parameters. Parameters are ordered as: 
mean beta vector for type 1, mean beta vector for type 2, ..., mean beta vector for type S, Std. Dev. vector for type 1, ..., Std. Dev. vector for type S, 
Gamma coefficient vector (if the ccov option is used), and the cut values for the type probabilities (there are one less cut values than the total number of latent types).{p_end}

{synopt:{opt log:normal(string)}}This option allows for some of the beta coefficients to have a lognormal distribution, as opposed to a normal distribution. These must be entered as a {it:numlist} string. For example,
if the coefficient to the fourth variable should have a positive lognormal distribution and the coefficient to the sixth variable should have a negative lognormal distribution, it must be entered as follows: "0 0 0 1 0 -1".{p_end}

{synopt:{opt corr}}Allows for random coefficients that are correlated across variables for each type. Note that this will increase the number of unknown parameters and also alter the required form of the initial values matrix.{p_end}

{synopt:{opt nrep(#)}}Specifies the number of shuffled Halton draws used for the simulation. The default is {cmd:nrep(50)}. I do not recommend a value below 30.{p_end}

{synopt:{opt burn(#)}}Specifies the number of initial sequence elements to drop when creating the shuffled Halton sequences. The default is {cmd:burn(15)}.{p_end}

{synopt:{opt constraints(numlist)}}See {help estimation options}.{p_end}

{phang}
  {it:    maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, {opt tr:ace}, {opt grad:ient}, {opt showstep}, {opt hess:ian}, {opt tol:erance(#)}, {opt ltol:erance(#)},
  {opt gtol:erance(#)}, {opt nrtol:erance(#)}; see {help maximize}.}{p_end}


{title:Examples}

{p 4 4 2}Download the following {browse "https://drive.google.com/open?id=1gFzVjZ4qKNCKvpUDSmYpv0gJTupb0ydg":do file}. Running that file after {cmd:mixmixlogit} is installed will generate a set of synthetic data that the command will then model. {p_end}

{p 4 4 2}An example of the syntax is as follows:{p_end}

{p 4 4 2}mixmixlogit choice X_1 X_2 X_3, ccov(Z_1 Z_2) group(groupvar) id(idvar) classes(2) nrep(30) gradient trace from(start){p_end}


{title:Saved results}

{p 4 4 2}Type {cmd:ereturn list} after estimation for a list of all macros, scalars, and matrices that are available, including the set of coefficient estimates and their standard errors.{p_end}


{title:References and Further Reading}

{p 4 4 2}Greene, W. and Hensher, D. (2013) "Revealing additional dimensions of preference heterogeneity in a latent class mixed multinomial logit model", Applied Economics, 45(13), p.1897-1902{p_end}

{p 4 4 2}Keane, M. and Wasi, N. (2013) "Comparing alternative models of heterogeneity in consumer choice behavior", Journal of Applied Econometrics, 28(6), p.1018-1045{p_end}

{p 4 4 2}Keane, M., J. Ketcham, N. Kuminoff, and T. Neal (2020) "Evaluating Consumers' Choices of Medicare Part D Plans: a study in behavioral welfare economics", Journal of Econometrics, Forthcoming, Available online 
{browse "https://www.nber.org/papers/w25652.pdf":here} {p_end}

{p 4 4 2}Train, K. (2002) {it:Discrete Choice Methods with Simulation}, Cambridge University Press, Available Online{p_end}


{title:Tips}

{p 4 4 2}Depending on the dataset and the structure of the model, getting Stata's ML algorithm to converge to a solution can be a challenge. If you are having trouble finding the optimal parameter values, there are several 
options available such as: specify the {opt difficult} option, simplify the model to the point that it is estimatable and then gradually expand it, and to use at least as many x variables as there are latent types in the model. 
If the dataset is very large and takes a long time to estimate, it may also be prudent to try and estimate models on subsamples of the data in order to find a feasible model specification 
in a faster manner before using the full dataset.{p_end}


{title:Attribution}

{p 4 4 2}If you use this code for your paper, please cite Keane et al. (2020).{p_end}


{title:Technical Support}

{p 4 4 2}This command is intended for users that have prior understanding of the fundamentals of multinomial logit models and maximum simulated likelihood. If you are having
trouble interpreting the results or understanding whether your dataset is appropriate for the model, Train (2002) is a fantastic resource for education in this area.
If there are errors that you believe originate from problems in the code and not in your dataset, please email the issue to timothy.neal@unsw.edu.au.{p_end}


{title:Acknowledgements}

{p 4 4 2}This command partly relied on the fantastic work of Arne Risa Hole who programmed the {cmd:mixlogit} user-written
command in Stata that allowed for multinomial mixed logit estimation.{p_end}


{title:Author}

{pstd}Timothy Neal{p_end}
{pstd}School of Economics{p_end}
{pstd}University of New South Wales{p_end}
{pstd}Sydney, Australia{p_end}
{pstd}{browse "mailto:timothy.neal@unsw.edu.au":timothy.neal@unsw.edu.au} {p_end}
{pstd}{browse "https://sites.google.com/site/tjrneal/stata-code":https://sites.google.com/site/tjrneal/stata-code} {p_end}


{title:Also see}

{psee}
{space 2}Online:  {helpb mixlogit}, {helpb asmixlogit}, {helpb clogit}, {helpb lclogit}
{p_end}
