{smcl}
{* 18may2015}
{cmd:help clustse}{right:version:  1.1.0}
{hline}


{title:Title}

{p 4 8}{cmd:clustse}  -  Program providing robust methods for calculating standard errors for linear and GLM models using 
clustered data, including the Cluster Adjusted T-Statistics (CATs) procedure.{p_end}


{title:Syntax}

{p 4 6 2}
{cmd:clustse}
{depvar}
{indepvars}
, cluster({varname}) 
[reps({it:integer}) seed({it:integer}) method({it:string}) force({it:string}) truncate({it:string}) fe({it:string}) festruc({it:string})]


{title:Options}

{hline}
{p 4 6 2}
Iterations: If specified, the {opt reps} option requires an integer for the number of bootstrap iterations that will be used to calculate the 
{it:t-statistics} and standard errors.  More iterations will yield more precise 
{it:p-values} for {it:t-statistics} and the standard errors will have more accuracy.  The default number of iterations is 1000.  For {it:p-values} with three digits of accuracy, specify {opt reps(10000)} or more.  
Note that this option only applies if {opt method(wild)} or {opt method(pairs)} 
are specified.  The maximum number of iterations for {opt method(wild)} depends on the version of Stata used--
 Stata IC and Small Stata can only run 400 iterations maximum due to the matrix size restrictions.  
{p_end}

{p 4 6 2}
Method: If specified, the {opt method} option requires a string that contains either "pairs" or "wild."  Specifying "pairs"
 for this option will cause the program to use the pairs cluster bootstrap-t procedure given by the program {helpb clusterbs}.  Specifying "wild" for this option will cause the program to used the wild cluster bootstrap
 procedure given by the program {helpb cgmwildboot}.  Note that "wild" only works for linear models (using {helpb regress}).  
{helpb cgmwildboot} was created by Judson Caskey and is available from his website at: {browse "https://sites.google.com/site/judsoncaskey/data"}.  
The default method for the program is the Cluster Adjusted T-Statistics (CATs) procedure provided in this program and described
 in Ibragimov and Muller (2010) and Esarey and Menger (forthcoming).
{p_end}

{p 4 6 2}
Forcing: If specified, the {opt force} requires a string that contains either "yes" or "no."  Specifying "yes" for this
 option will allow the CATs procedure to run, even if the model cannot be run in all the clusters or if variables are dropped in some clusters due to collinearity.
  Note that this option only applies for the CATs procedure (when {opt method} is not specified).  If a variable is dropped in multiple clusters,
the procedure may not be able to estimate a parameter for this variable.
{p_end}

{p 4 6 2}
Truncating: If specified, the {opt truncate} requires a string that contains either "yes" or "no."  Specifying "yes" for this
 option will drop clusters that have severely outlying estimates from the analysis.  The criteria for clusters' exclusion 
is that clusters must be within 6 times the inter-quartile range of the mean of the coefficient estimates.
Note that this option only applies for the CATs procedure (when {opt method} is not specified).
{p_end}

{p 4 6 2}
Fixed Effects: If specified, the {opt fe} allows for one dimension of fixed effects to be calculated in the model.  When the
CATs procedure (the default method) is used, specify "yes" for this option to use fixed effects.  This requires that you specify the
variable used to create the fixed effects in the {opt festruc}.  Note that specifying fixed effects for the cluster variable
is unnecessary and will not calculate, since the model effectively incorporates fixed effects for the cluster variable
already by calculating separate intercepts when the model runs inside of each cluster.
Also note that when specifying a fixed effects model, use the normal model name (like "regress") instead of the xt-prefixed
model name (like "xtreg").  The program will run the appropriate model for you.  Fixed effects can only be run with 
"regress", "logit", "poisson", and "nbreg".
The {opt method(wild)} will not work with the fixed effects option.  The {opt method(pairs)} will not work with fixed
effects through {cmd: clustse}.  To run fixed effects with the pairs cluster bootstrap-t procedure, you must run
program {cmd: clusterbs}.  For more information on using fixed effects with {opt method(pairs)}, see the {helpb clusterbs} help file.
{p_end}

{hline}


{title:Notes}

{p 4 6 2}
- You must specify a clustering variable ({opt cluster()}).
{p_end}

{p 4 6 2}
- {cmd: clustse} does not work with random effects or time series models at this time.
  The program currently does not accept weights or other options at this time.  Standard regression and glm models like logit are supported.
{p_end}

{p 4 6 2}
- The wild boostrap-t procedure implemented by the {opt method(wild)} option uses the program {helpb cgmwildboot} 
by Judson Caskey.  The maximum number of {opt reps()} that can be used with this procedure depends on the 
version of Stata being run.  Stata/IC and Small Stata can only use 400 iterations, while Stata/SE and 
Stata/MP can use up to 5500 iterations. 
{p_end}

{p 4 6 2}
{hilite: For the CATs procedure:}
{p_end}

{p 4 6 2}
- The standard errors returned by the CATs procedure are calculated from the distribution of parameter estimates
 across the models run in each cluster.  The {it:t-statistics}, {it:p-values}, and confidence intervals are calculated using these cluster-adjusted standard errors.
{p_end}

{p 4 6 2}
- The CATs procedure does not post accurate results into e().  Specifically, the variance-covariance matrix (VCV) is "fake,"
 where the variances correspond to the CATs estimates but the covariances are retained from the original pooled model.  Furthermore, the coefficients for the original pooled model are replaced with the average of the regression coefficients
 from each cluster.  Due to this, no post-estimation commands should be run on these models, as they will yield inaccurate results.
{p_end}

{p 4 6 2}
- The CATs procedure returns coefficients that are the average of the regression results within each cluster, and the standard errors and confidence intervals
 can only be proven to apply to these coefficient estimates.  Unless all clusters are of equal size, the original pooled model will return 
different parameter estimates from the average of the cluster estimates.  However, the
 {it:t-statistics} and {it:p-values} for statistical significance also apply to the original pooled model's coefficients 
(Ibragimov and Muller 2010).  Because of this, the program displays the original pooled model's coefficients following the regression table.
  Inference about statistical significance and confidence intervals should be made with caution regarding which coefficients they apply to.
{p_end}


{title:Description}

{p 4 4 2}
{cmd: clustse} performs three different procedures depending on the specified {opt method}.  The program defaults to the CATs procedure
 described in Ibragimov and Muller (2010) and Esarey and Menger (forthcoming).  If specified, or if the CATs procedure fails, the program will use the wild cluster bootstrap procedure given by {helpb cgmwildboot} or the pairs cluster
 bootstrap-t procedure given by {helpb clusterbs}.  {cmd: clustse} is intended to use for obtaining accurate inference
 about the statistical significance of a parameter when the data is clustered with a small number of clusters, or a moderate
 number of clusters of uneven size. {p_end}

{p 4 4 2}
The CATs procedure is based on the idea that the data of each cluster can be seen as a random draw from the total possible
 observations of the data.  The procedure runs the given model on the observations inside of each cluster and then draws statistical inference from the variance of the parameter estimates across all of the clusters.  This provides a way
 for the model to provide standard errors that are robust to clustering, even with a very small number of clusters.  
In order for the procedure to work, the model must be able to run in each cluster.  This means that each cluster must
 contain a reasonable number of observations with variance on the dependent and independent variables.  
Simulations by Esarey and Menger (forthcoming) show that this procedure has good power characteristics for detecting statistically significant
 relationships and has the desired false positive rate for data grouped in even just a few clusters.
{p_end}



{title:Example}

{p 4 4 2}
As an example, we will use the nlsw88.dta dataset in Stata to estimate the effects of average hours worked, experience,
 and college education on wages, with clustering at the industry level.  We will need to drop the 3 industries with the fewest
observations in order to make the CATs procedure work.
{p_end}

{phang}{stata "webuse nlsw88"}{p_end}

{phang}{stata "drop if (industry==1 | industry==2 | industry==3)"}{p_end}

{phang}{stata "regress wage hours ttl_exp collgrad, cluster(industry)"}{p_end}

{phang}{stata "clustse regress wage hours ttl_exp collgrad, cluster(industry)"}{p_end}

{phang}{stata "clustse regress wage hours ttl_exp collgrad, cluster(industry) force(yes)"}{p_end}

{phang}
{stata "clustse regress wage hours tenure ttl_exp collgrad, cluster(industry) method(wild) reps(400)"}
{p_end}

{phang}
{stata "clustse regress wage hours tenure ttl_exp collgrad, cluster(industry) method(pairs) reps(1000)"}
{p_end}

{title:References}
{p 4 6 2}
- Esarey, Justin and Andrew Menger. Forthcoming.  Practical and Effective Approaches to Dealing with Clustered Data.{p_end}

{p 4 6 2}
- Ibragimov, Rustam and Ulrich K. Muller. 2010. "t-Statistic Based Correlation and Heterogeneity Robust Inference." {it:Journal of Business and Economic Statistics} 28(4):453-468.{p_end}

{p 4 6 2}
- Cameron, A., J. Gelbach and D. Miller. 2008. Bootstrap-based improvements for inference with clustered errors. {it:Review of Economics and Statistics} 90(3): 414-427.{p_end}

{title:Author}

{p 4 4 2}Andrew Menger, Rice University, andrew.m.menger@rice.edu{p_end}

