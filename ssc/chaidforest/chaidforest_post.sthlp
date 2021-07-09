{smcl}
{* *! version 1.0 Oct 12 2015 J. N. Luchman}{...}
{cmd:help chaidforest postestimation}
{hline}{...}

{title:Title}

{pstd}chaidforest postestimation -- Postestimation tools for chaidforest

{title:Description}

{pstd}The following postestimation commands are available after {cmd:chaidforest}:

{col 5}Command{col 24}Description
{col 5}{hline}
{col 5}{helpb chaidforest_post##predict:predict}{col 24}Obtain predictions across all CHAID trees
{col 5}{helpb chaidforest_post##prox:estat prox}{col 24}Obtain proximity matrix for estimation sample observations across all CHAID trees
{col 5}{helpb chaidforest_post##fit:estat fit}{col 24}Cluster/node purity overall fit metric across all CHAID trees
{col 5}{helpb chaidforest_post##import:estat import}{col 24}Splitting variables permutation importance metric
{col 5}{helpb chaidforest_post##gettree:estat gettree}{col 24}Obtain the results from a single CHAID tree from the forest
{col 5}{hline}

{pstd}The above postestimation commands require the chaidtree vector object "results" to be in memory in Mata.  {cmd:chaidforest} will have to 
be re-run if any command cannot find the results chaidtree vector object as all tree results are stored as instances of that class.

{marker predict}{...}
{title:Syntax for predict}

{col 9}{cmd:predict} {it:newvar} [, {it:predict_options}]

{col 5}{it:predict_options}{col 24}Description
{col 5}{hline}
{col 5}Forest-level
{col 7}{cmd:pr}{col 24}Empirical probabilities or observed proportions across all CHAID trees
{col 7}{cmd:mode}{col 24}Most likely or modal value across all CHAID trees
{col 5}CHAID tree-level
{col 7}{cmd:ctpr}{col 24}Empirical probabilities or observed proportions for any given CHAID tree
{col 7}{cmd:ctmode}{col 24}Most likely or modal value across for any given CHAID tree
{col 5}option
{col 7}{cmd:useboot}{col 24}Use bootstrap weights when computing empirical probabilities or modal value for each CHAID tree
{col 5}{hline}
{col 5}{cmd:pr} and {cmd:ctpr} are defaults, are always generated as {cmd:double}s, and the {it:newvar} is interpreted as a stub.
{col 5}{cmd:mode} is always generated as a {cmd:long}.
{col 5}All predictions are generated for the entire estimation sample.

{title:Options for predict}

{pstd}{cmd:pr}, the default forest-level prediction option, computes empirical probabilities for each category of the response variable.  
How the probabilities are computed depends on the data generated at the CHAID tree-level (discussed below in remarks).  Missing values 
are a valid category if {opt missing} was invoked in {cmd:chaidforest} producing a predictied probability of ".p" 
(i.e., {res}p{txt}redicted missing).  {cmd:pr} cannot be used with {cmd:mode}.

{pstd}{cmd:mode} is the category of the response variable which is deemed most likely or receives the most "votes" for an observation 
across all the CHAID trees.  As with the {opt pr} option, how the modal value is computed depends on how the data are generated at the 
CHAID tree-level (ties for most likely value are decided randomly).  Missing values are a valid prediction if {opt missing} was 
invoked in {cmd:chaidforest} producing a predicted ".p" (i.e., {res}p{txt}redicted missing).  {cmd:mode} cannot be used with {cmd:pr}.

{pstd}{cmd:ctpr}, the default CHAID tree-level prediction option, computes empirical probabilities for each category in the response variable for 
a specific CHAID tree.  Specifically, the clusters/nodes produced by each tree receive their own tabulation.  The proportion in each of the 
categories in the response variable are then assigned as predicted probabilities of being in each category to all the observations in that cluster.  
The empirical probabilities produced in the CHAID tree-level step are then aggregated across the forest by the forest-level commands for each 
observation.  Missing values will be incorporated at the CHAID tree-level if {opt missing} is specified. {cmd:ctpr} cannot be used 
with {cmd:ctmode}.

{pstd}{cmd:ctmode} is the category of the response variable which is deemed most likely or has the highest frequency for a cluster within a CHAID 
tree.  The process to obtain a most likely value mirrors that to obtain empirical probabilities except that only the most likely value 
is retained (ties for most likely value are decided randomly).  The most likely values produced in the CHAID tree-level step are 
then aggregated across the forest by the forest-level commands for each observation. Missing values will be incorporated at the 
CHAID tree-level if {opt missing} is specified. {cmd:ctmode} cannot be used with {cmd:ctpr}.

{pstd}{cmd:useboot} uses the bootstrap weights invoked to generate the CHAID trees to obtain empirical probabilities and most likely values 
at the CHAID tree-level.  Currently, the {opt useboot} option is experimental and will generally result in sub-optimal fit to the observed 
data.

{title:Remarks on predict}

{pstd}{cmd:chaidforest} always uses one option from both the "forest-level" and "CHAID tree-level" categories.  Thus 4 different types of predicted 
values are possible to obtain with {cmd:chaidforest}.  

{pstd}Arguably, the most nuanced and complete predictions are obtained from the default {cmd:pr}-{cmd:ctpr} combination where empirical 
probabilities for each category of the response variable are obtained for each observation in each CHAID tree and averaged across 
the entire forest to result in a single set of empirical probabilities for each category of the response variable for each observation.  
{cmd:chaidforest} version 1.0's default was more akin to a {cmd:pr}-{cmd:ctmode} approach where a single, modal predicted 
value was obtained for each observation in each CHAID tree.  Empirical probabilities for each obervation then represent the
proportion of each category of the response variable observed for each observation as aggregated across all CHAID trees in the forest.

{pstd}The forest-level mode options produce results more akin to those from other random forest implementations as only a single value is produced.  
The somewhat more nuanced {cmd:mode}-{cmd:ctpr} approach first obtains empirical probabilities of each category of the response variable for 
each observation from each CHAID tree and averages them across the entire forest.  The most likely value of the response variable for each 
observation is then determined and used as the predicted value.  By contrast, the {cmd:mode}-{cmd:ctmode} is the most simple approch to obtaining 
a predicted value, is the approach most commonly used by other random forest algorithms, and is the approach used by {cmd:chaidforest} version 
1.0 when using {opt mode}.  Here each CHAID tree supplies a predicted value for each observation.  The final predicted value is the 
category with the most votes or the highest frequency across all CHAID trees in the forest.

{marker prox}{...}
{title:Syntax for estat prox}

{col 9}{cmd:estat prox} [, {cmd:mata}]

{title:Options for estat prox}

{pstd}{cmd:mata} overrides default behavior saving the proximity (or more accurately dissimilarity) matrix to the {help ereturn}ed matrix 
list in favor of saving the proximity matrix computed by {opt estat prox} in Mata as a matrix named {res}prox{txt}.  Note that any Mata 
matrix named {res}prox{txt} will be overwritten.  The {opt mata} option is useful for large datasets.

{title:Saved results for estat prox}

{phang}{cmd:estat prox} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:e(prox)}}{it:N} x {it:N} matrix of dissimilarities between observations{p_end}

{title:Remarks for estat prox}

{pstd}The proximity matrix returned by {cmd:estat prox} represents a metric for assessing similarity between the observations as impled by the 
{cmd:chaidforest} results.  As such, the proximity matrix produces a matrix which can be used by {help mdsmat} and {help clustermat}.  The 
proximity matrix thus allows for clustering observations based on aggregated {cmd:chaidforest} model results which can facilitate interpretation 
of the results.

{pstd}{cmd:estat prox} proceeds by obtaining the proportion of CHAID trees in which each pair of observations falls into the same cluster.  
In the instance, that 2 observations are always in the same cluster in every tree in the forest, they would obtain a value of 1.  Conversely, 
2 observations which are never in the same cluster in every tree in the forest would obtain a value of 0.

{pstd}The proximity matrix is actually a dissimilarity matrix as the complement of each of the proportions (i.e., 1 - {it:proportion}) are used 
as the results in the proximity matrix.  All entries in the matrix are als square rooted to improve the performance of the matrix in other programs.

{marker fit}{...}
{title:Syntax for estat fit}

{col 9}{cmd:estat fit} [, {cmd:{ul on}ins{ul off}ample}]

{title:Options for estat fit}

{pstd}{cmd:insample} overrides the default resampling-based fit metric and instead uses the bootstrap weights that were used to estimate 
the {cmd:chaidforest} results.  Thus, the overall fit is based in fully in-sample weights for each CHAID tree.  If {opt proos()} was used in the 
base {cmd:chaidforest} command, only the observations sampled are used to compute the fit metric.  If {opt nosamp} was used in the base 
{cmd:chaidforest} command, all observations in the estimation sample are used.

{title:Saved results for estat fit}

{phang}{cmd:estat fit} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(fit)}}Cram{c e'}r's V-based fit metric{p_end}

{title:Remarks for estat fit}

{pstd}The fit metric returned is based on the average Cram{c e'}r's V from each CHAID tree across the entire forest.  By default, 
{cmd:estat fit} obtains a different bootstrap sample of observations than the original bootstrap sample that {cmd:chaidforest} 
used to estimate the CHAID tree, applies the cluster/node rules to the resampled data, and computes Cram{c e'}r's V using the 
new bootstrap sample.  Hence, the fit metric is not an out-of-sample fit metric, but mimics one as its a resample fit metric 
which will use some of the same observations as in the original bootstrap sample, but also some from out-of-sample, and has 
an entirely new set of bootstrap weights.  In both cases, the total sample used to compute fit will look different than the 
original and serves as a useful assessment of how well the results will hold up in replication.

{pstd}When using the {opt proos()} option in the base {cmd:chaidforest} command, the resample fit metric will mimic the original process, 
resampling the proportion desired without replacement.  The {opt nosamp} option in the base {cmd:chaidforest} command does not 
affect {cmd:estat fit} without the {opt insample} option.  The {opt insample} option will obtain the fit metric across all CHAID 
trees in the forest without resampling.  In the absence of the {opt insample} option, the fit metric will resample observations in each 
CHAID tree.

{marker import}{...}
{title:Syntax for estat import}

{col 9}{cmd:estat import} [, {cmd:{ul on}ins{ul off}ample}]

{title:Options for estat import}

{pstd}{cmd:insample} identical to the behavior in {cmd:estat fit} above.

{title:Saved results for estat import}

{phang}{cmd:estat import} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:e(import)}}matrix of permutation importance values based on Cram{c e'}r's V-based fit metric{p_end}

{title:Remarks for estat import}

{pstd}The permutation importance values are computed using the method outlined in {cmd:estat fit}.  The importance values differ from 
the traditional fit values in that for every splitting variable the data for that variable is randomly permuted or {help mf_sort:jumbled} 
for each CHAID tree - which is done before any resampling as is described in {cmd: estat fit}.  

{pstd}After permuting, the CHAID tree splitting rules are applied to the permuted data, and the fit metrics (the entries in the second 
row of {res}e(import){txt}) are conputed.  The fit metrics are then rank ordered (the first row of {res}e(import){txt}).  Splitting variables 
with smaller fit metrics are deemed more important as fit is reduced more when their values are permuted - thus, by implication, they 
contribute more to the fit metric.

{marker gettree}{...}
{title:Syntax for estat gettree}

{col 9}{cmd:estat gettree}, {opt {ul on}tr{ul off}ee(tree_number)} [{cmd:{ul on}gr{ul off}aph}]

{title:Options for estat gettree}

{pstd}{opt tree(tree_number)} a required option specifying the results from which tree should be pulled from the chaidtree object associated with 
the most recent {cmd:chaidforest} run.

{pstd}{cmd:graph} mimics {stata findit chaid:chaid}'s behavior in graphing and displaying the tree structure if the focal CHAID tree from the 
chaidtree object associated with the most recent {cmd:chaidforest} run.

{title:Saved results for estat gettree}

{phang}{cmd:estat gettree} saves the following results to {cmd: r()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:r(N_clusters)}}number of clusters created by {cmd:chaid} and returned in {cmd:_CHAID_{it:tree_number}} variable{p_end}
{synopt:{cmd:r(fit)}}purity of the clusters (extent to which each cluster has only a single value of the response variable); 
based on Cram{c e'}r's V{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:r(splitvars)}}displays splitting variables selected for use in the current CHAID tree{p_end}
{synopt:{cmd:r(path#)}}displays the levels of each split leading to cluster #.  Each split is separated by semicolons.  
The splitting variable is first followed by an "at" sign (i.e., @) followed by the levels of the splitting variable that 
describes cluster # at that split{p_end}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:r(sizes)}}sample size of each cluster{p_end}
{synopt:{cmd:r(branches)}}number of branches from the root node for each cluster{p_end}

{title:Remarks for estat gettree}

{pstd}Generates 2 variables associated with the CHAID tree {it:tree_number} in the forest.  The first {res}_CHAID_{it:tree_number}{txt} corresponds 
to cluster membership for each observation in the dataset for CHAID tree {it:tree_number}.

{pstd}The second variable {res}bwgt_{it:tree_number}{txt} is the bootstrap frequency weight obtained for CHAID tree {it:tree_number}.

{pstd}{cmd:estat gettree} is intended to "open up the black box" of the random forest algorithm to see individual trees' results.
