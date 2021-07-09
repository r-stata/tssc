{smcl}
{* 18may2015}
{cmd:help clusterbs}{right:version:  1.1.0}
{hline}


{title:Title}

{p 4 8}{cmd:clusterbs}  -  Pairs cluster bootstrap-t program for calculating standard errors for linear and GLM models using clustered data.{p_end}


{title:Syntax}

{p 4 6 2}
{cmd:clusterbs}
{depvar}
{indepvars}
, cluster({varname}) [fe({it:string}) reps({it:integer}) seed({it:integer}) festruc({it:string})]


{title:Options}

{p 4 6 2}
- If specified, the {opt reps} option requires an integer for the number of bootstrap iterations that will be used to calculate the 
{it:t-statistics} and standard errors.  More iterations will yield more precise 
{it:p-values} for {it:t-statistics} and the standard errors will have more accuracy.  The default number of iterations is 1000.  For {it:p-values} with three digits of accuracy, specify {opt reps(5000)} or more.
{p_end}

{p 4 6 2}
- If specified, the {opt fe} option requires a string that equals (inside), (external), or (cluster). If {opt fe} is specified, then the program
uses the xt- prefix regression commands to generate fixed effects for the given variables.  
The specification (external) should be used for fixed effects that are not the same as or related to the clustering dimension.
The specification (inside) should be used for fixed effects that are given to sub-units inside of the clustering units.
The specification (cluster) should be used for fixed effects that are given to each of the clustering units themselves.
The (cluster) specification allows for one to include cluster-level fixed effects to remove the variation of the 
cluster means, thereby running a within cluster model.
These fixed effects are re-sampled with the bootstrapping for unique clusters in the bootstrap sample, even if the cluster 
was already drawn for the sample.  So, if the bootstrap sample draws cluster 1 twice, then the program will give each of these
draws of cluster 1 a new fixed effect.
When the specification (external) is given, one must specify the fixed effect indicator variable as a string in the option {opt festruc}.
When the specification (inside) is given, one must specify the indicator variable that is combined with the cluster dimension
to create the fixed effects.  For example, if the fixed effects are given to product-store combinations, and the cluster dimension
is the store, then one would specify the name of the product indicator variable in the option {opt festruc}.
{p_end}

{p 4 6 2}
- If the {opt fe} option is specified as (inside) or (external), the {opt festruc} option must be specified.  For (inside) fixed effects,
it should contain the name of the variable used to create the fixed effects inside of each 
cluster.  For example, if the fixed effects are given to product-store combinations, and the cluster dimension
is the store, then one would specify the name of the product indicator variable in the option {opt festruc}.
For (external) fixed effects, it should contain the name of the variable used to create the fixed effects.
{p_end}

{title:Notes}

{p 4 6 2}
- You must specify a clustering variable ({opt cluster()}).
{p_end}

{p 4 6 2}
- {cmd: clusterbs} does not work with random effects, instrumental variables, or time series models at this time.  The program currently does not accept weights or other options at this time.  Standard regression and glm models like logit are supported.
{p_end}

{p 4 6 2}
- The {it: p-value} is based on the empirical distribution of the absolute value of the {it: t-statistics}. It is given by the fraction of {it:t-statistics} from the bootstrap iterations above the initial {it:t-statistic}.  Therefore, the 
{it:p-value} comes from the symmetric pairs cluster bootstrap-t method, which assumes the symmetry of the {it:t-statistic} based on asymptotic theory.
{p_end}

{p 4 6 2}
- The confidence interval is based on the distribution of the the {it:t-statistics}.  It reports the 5th and 95th percentiles of the coefficients as calculated from the pairs cluster bootstrap-t
 procedure rather than from the bootstrap distribution
 of the parameter itself.  This ensures that they are pivotal statistics.
{p_end}

{p 4 6 2}
- The program does not post results into {helpb ereturn}.  Therefore, the variance-covariance matrix and parameter values cannot be retrieved post-estimation.  In fact, the model only uses a VCV for the initial calculation of the parameters,
 but not for the standard errors or other statistics.  
No postestimation statistics can be run on these models.
{p_end}


{title:Description}

{p 4 4 2}
{cmd: clusterbs} performs pairs bootstrapping by sampling observations (independent and dependent variables together)
 with replacement by cluster groups, similarly to {helpb bootstrap} with the {opt cluster()} option.  However, {cmd: clusterbs} bootstraps the pivotal
 {it:t-statistic} and uses the distribution of the {it:t-statistic} over the bootstrap samples for inference, while the {helpb bootstrap} command simply uses the variance of
 the parameter estimates across the bootstrap samples.  {cmd: clusterbs} is intended to use for obtaining
 accurate inference about the statistical significance of a parameter when the data is clustered with
 a small number of clusters, or a moderate number of clusters of uneven size. {p_end}

{p 4 4 2}
Because it is based on the pivotal {it:t-statistic}, 
{cmd: clusterbs} has better properties for statistical inference in clustered data than the {helpb bootstrap} command.  
Simulations in Esarey and Menger (forthcoming) show that the pairs cluster bootstrap-t procedure produces favorable power characteristics
 and the desired false positive rates even for a small number of clusters.  When the number of clusters
 is large (generally greater than 50 for clusters of balanced size), the cluster robust
 standard errors given by the {opt cluster} option are faster to calculate and may provide accurate inference.  However, when the number of clusters
 is small or they are of unbalanced sizes, the {opt cluster} option can produce
 misleading standard errors and {it:p-values} (see Cameron, Gelbach, and Miller 2008).
{p_end}


{title:Example}

{p 4 4 2}
As an example, we will use the nlsw88.dta dataset in Stata to estimate the effects of average hours worked, experience,
 and college education on wages, with clustering at the industry level.
{p_end}

{phang}{stata "webuse nlsw88"}{p_end}

{phang}{stata "regress wage hours ttl_exp collgrad, cluster(industry)"}{p_end}

{phang}{stata "clusterbs regress wage hours ttl_exp collgrad, cluster(industry)"}{p_end}

{phang}{stata "clusterbs regress wage hours ttl_exp collgrad, cluster(industry) fe(cluster)"}{p_end}

{phang}{stata "clusterbs regress wage hours ttl_exp collgrad, cluster(industry) reps(2000) seed(13932)"}{p_end}

{title:References}

{p 4 6 2}
- Esarey, Justin and Andrew Menger. Forthcoming.  Practical and Effective Approaches to Dealing with Clustered Data.{p_end}

{p 4 6 2}
- Cameron, A., J. Gelbach and D. Miller. 2008. Bootstrap-based improvements for inference with clustered errors. {it:Review of Economics and Statistics} 90(3): 414-427.{p_end}


{title:Author}

{p 4 4 2}Andrew Menger, Rice University, andrew.m.menger@rice.edu{p_end}



