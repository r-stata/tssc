{smcl}
{* version 1.0.0  10May2016}{...}
{title:Title}

{phang}
{bf:wald_mse} {hline 2} Calculate the maximum mean square error (MSE) of a point-estimator of the mean, from a random
sample with missing data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:wald_mse}
{it:command_name}
{cmd:,} {it:options}

{title:Description}

{p 4 4 2}
{bf:wald_mse} calculates the maximum MSE of a point-estimator of the mean of a bounded outcome, from a random sample with missing data. 
The MSE equals regret under square loss, so the maximum MSE is the maximum regret. In the case of bounded outcomes and no missing data, 
Hodges and Lehmann (1950) derive the estimator with smallest maximum MSE; that is, the minimax-regret estimator.
With missing data, the minimax-regret estimator has no known analytical expression and numerical computation appears intractable. 
{opt wald_mse} allows the user to compute the maximum MSE of any proposed estimator with a flexible specification of missing data. For an introduction
to these concepts, see Manski and Tabord-Meehan (2017). {p_end}

{title:Input}

{phang}
{opt command_name} specifies the name of the estimator to be used. It must be either a built-in estimator (for a list of the currently 
supported estimators, see the Built-in Estimators section below), or any user-specified e-class command that returns to e(b) (for more information about using user-defined commands, see the section Tips for User-Defined Estimators below).{p_end}

{phang}
{opt options} specifies various features of the computation. For a list of required and discretionary options, see the Options section below.{p_end}


{title:Output}

{p 4 6 2}
Returns the computed maximum MSE.{p_end}


{title:Options}

{phang}
{opt Required Options: }

{phang}
{opt samp_size(#)} specifies the size of the sample. This option must be specified.

{phang}
{opt dist(string)} specifies type of data being considered. The two options supported are {opt bernoulli} for binary {0,1} outcomes and {opt continuous} for continuous outcomes bounded in the unit interval. The continuous distributions used in 
the computations are beta distributions. This option must be specified.

{phang}
{opt Discretionary Options: }

{phang}
In what follows, z = 1 if an outcome y is observable and z = 0 if it is missing. P(y|z = 1) and P(y|z = 0) are the population distributions 
of observable and missing outcomes, while E(y|z = 1) and E(y|z = 0) are their respective means. P(z = 1) and P(z = 0) are the probabilities of response and nonresponse.

{phang}
Options to specify the data generating process: 

{phang}
{opt miss_l(#)} specifies a lower bound on the nonresponse probability P(z = 0). For example, setting miss_l(0.5) specifies that P(z = 0) >= 0.5. The default option is 0.
 
{phang}
{opt miss_r(#)} specifies an upper bound on the nonresponse probability P(z = 0). The default option is 1.

{phang}
{opt rdgp_l(#)} specifies a lower bound on the mean E(y|z = 1) of the observable outcomes. For example, setting rdgp_l(0.5) specifies that E(y| z = 1) >= 0.5. The default option is 0.

{phang}
{opt rdgp_r(#)} specifies an upper bound on the mean E(y|z = 1). The default option is 1.

{phang}
{opt mdgp_l(#)} specifies a lower bound on the mean E(y|z = 0) of the missing outcomes. The default option is 0.

{phang}
{opt mdgp_r(#)} specifies an upper bound on the mean E(y|z = 0). The default option is 1.

{phang}
{opt h_distance(#)} specifies an upper bound on the Hellinger distance between the distributions P(y|z = 1) and P(y|z = 0). For example, setting h_distance(0) forces the distribution of missing data and 
observable data to be identical, which is equivalent to making the assumption of missingness at random. The default option is 1, (equivalent to making no assumptions linking missing and observable data).

{phang}
{opt r_shape(#)} specifies the shape of the distribution of the observable data, when dist is set to be {opt continuous} (recall when dist is set to {opt continuous}, the distributions 
considered are beta distributions). If r_shape is set to 1, then only distributions whose modes are in the interior of the unit interval are considered. 
If r_shape is set to 2, then only distributions whose densities are "u-shaped" are considered. If r_shape is set to 0, then both types are considered. The default option is 0.

{phang}
{opt m_shape(#)} specifies the shape of the distribution of the missing data. See r_shape for details.

{phang}
{opt mon_select(#)} specifies whether or not to make a "monotone selection" type assumption: when mon_select is set to 1, only DGPs where E(y|z=0) >= E(y|z=1) are considered. When mon_select is set to 2, only DGPs where E(y|z=1) >= E(y|z=0) 
are considered. When mon_select is set to 0, both options are considered. The default option is 0.

{phang}
Options to specify the accuracy of the computation:

{phang}
{opt mc_iter(#)} specifies the number of Monte Carlo iterations used to compute the MSE of the estimator in repeated samples. The default option for built-in estimators is 3000, the default option for 
user-defined commands is 300.

{phang}
{opt grid(#)} specifies the number of grid-points used to generate the distributions. For example, if the outcome is binary and grid(6) is specified, the resulting grid of Bernoulli parameters for the distributions would be {0,0.2,0.4,0.6,0.8,1}. 
The default option for binary outcomes is 25, the default option for continuous outcomes is 5. 

{phang}
Additional options:

{phang}
{opt user_def} specifies whether or not the estimator being used is built-in or user-defined. Setting user_def specifies that the estimator to be used is user-defined.

{phang}
{opt true_beta} specifies whether or not certain continuous distributions should be approximated by bernoulli distributions. As explained in the Manski and Tabord-Meehan (2017), 
in general, specifying true_beta will slow down the program but may increase accuracy.

{title:Built-in Estimators}

{phang}
{opt mean} is simply the sample mean.

{phang}
{opt midmean} is an estimator that first estimates the identified interval under no assumptions on the missing data, and then selects the midpoint of the interval. See Dominitz and Manski (2016) for details.
  
{phang}
{opt MMRzero} is the minimax-regret estimator of the mean with no missing data, as derived in Hodges and Lehmann (1950).

{title:Examples}

{phang}Evaluating maximum MSE of the sample mean, for continuous outcomes, with a sample size of 20, and where the amount of missingness considered is between 0.2 and 0.8.{p_end}

{phang}{cmd:. wald_mse mean, samp_size(20) dist("continuous") miss_l(0.2) miss_r(0.8)}{p_end}

{phang}Evaluating maximum MSE of the midpoint mean estimator, for binary outcomes, with a sample size of 50, where the amount of missingness considered is between 0 and 0.5, and the Hellinger distance between distributions is at most 0.6.
{p_end}

{phang}{cmd:. wald_mse midmean, samp_size(50) dist("bernoulli") miss_l(0) miss_r(0.5) h_distance(0.6)}{p_end}


{title:Tips for User-Defined Estimators}

{phang}
{bf:wald_mse} allows the user to evaluate the maximum MSE of user-defined estimators of the mean, as long as they are e-class commands that return their result to e(b). User-defined estimators are in general much slower than built-in estimators, so by default 
{bf: wald_mse} will do the computations with less accuracy than with a built-in estimator. The option {opt user_def} must be specified when using user-defined estimators.
When evaluating a user-defined estimator, we recommend first running the computation with binary outcomes, since this will be much faster and frequently achieves maximum MSE.

{title:Stored Results}

{cmd:wald_mse} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Scalars:}
{synopt:{cmd:r(MSE)}}the computed maximum MSE{p_end}
{synopt:{cmd:r(rmeanval)}}the value of E(y|z=1) where maximum MSE is achieved{p_end}
{synopt:{cmd:r(mmeanval)}}the value of E(y|z=0) where maximum MSE is achieved {p_end}
{synopt:{cmd:r(missval)}}the value of P(z=0) where maximum MSE is achieved {p_end}
{synopt:{cmd:r(N)}}the specified sample size{p_end}
{synopt:{cmd:r(missr)}}the specified upper bound on P(z = 0){p_end}
{synopt:{cmd:r(missl)}}the specified lower bound on P(z = 0){p_end}
{synopt:{cmd:r(mdgpr)}}the specified upper bound on E(y|z = 0){p_end}
{synopt:{cmd:r(mdgpl)}}the specified lower bound on E(y|z = 0){p_end}
{synopt:{cmd:r(rdgpr)}}the specified upper bound on E(y|z = 1){p_end}
{synopt:{cmd:r(rdgpl)}}the specified lower bound on E(y|z = 1){p_end}
{synopt:{cmd:r(hd)}}the specified bound on Hellinger distance between P(y|z = 0) and P(y|z = 1){p_end}
{synopt:{cmd:r(mshape)}}the specified shape option for P(y|z = 0), if applicable{p_end}
{synopt:{cmd:r(rshape)}}the specified shape option for P(y|z = 1), if applicable{p_end}

{syntab:Macros:}
{synopt:{cmd:r(est)}}the estimator used{p_end}
{synopt:{cmd:r(cmd)}}the name of this command: {opt wald_mse}{p_end}
{synopt:{cmd:r(d)}}the specified distribution type{p_end}
{synoptline}


{title:References}


{p 4 6 2}
 - Dominitz, J. and Manski, C. (2016). More Data or Better Data? A Statistical Decision Problem. Manuscript.{p_end}

{p 4 6 2}
 - Hodges, E. and Lehmann, E. (1950). Some Problems in Minimax Point Estimation. Annals of Mathematical Statistics.{p_end}

{p 4 6 3}
- Manski, C. and Tabord-Meehan, M. (2017). wald_mse: Evaluating the Maximum MSE of Mean Estimates with Missing Data. Mansuscript.{p_end}


{title:Authors}

{p 4 4}Chuck Manski, Northwestern University, cfmanski@northwestern.edu{p_end}


{p 4 4}Max Tabord-Meehan, Northwestern University, mtabordmeehan@u.northwestern.edu
{p_end}


