{smcl}
{* *! version 2.0 October 12, 2015 J. N. Luchman}{...}
{cmd:help chaidforest}
{hline}{...}

{title:Title}

{pstd}
Random forest ensemble classification based on chi-square automated interaction detection (CHAID) as base learner{p_end}

{title:Syntax}

{phang}
{cmd:chaidforest} {depvar} {ifin} {weight} [{cmd:,} {opt {ul on}nt{ul off}ree(integer)} {opt {ul on}nv{ul off}use(integer)} 
{opt {ul on}minn{ul off}ode(integer)} {opt {ul on}mins{ul off}plit(integer)} {opt {ul on}uno{ul off}rdered(varlist)} 
{opt {ul on}ord{ul off}ered(varlist)} {opt {ul on}noi{ul off}sily} {opt {ul on}mis{ul off}sing} {opt {ul on}a{ul off}lpha(pvalue)} 
{opt {ul on}dvo{ul off}rdered} {opt {ul on}xt{ul off}ile(varlist, xtile_opt)} {opt {ul on}pro{ul off}os(proportion)} {opt {ul on}nos{ul off}amp}

{phang}
{cmd:fweights} are allowed; see {help weight}.
See {help chaidforest_post:chaidforest postestimation} for features available after estimation.{p_end}

{title:Description}

{pstd}
{cmd:chaidforest} is an implementation of a random forest (Breiman, 2001) ensemble classification algorithm which is based on the idea that 
multiple, relatively less accurate classifiers, when combined, can produce more accurate predictions than a single more accurate classifier 
such as a {help logit}-based model - especially when considering out-of-sample predictions.

{pstd}
The {cmd:chaidforest} classifier uses the CHAID algorithm as its "base learner" (see {stata findit chaid} for details about the CHAID 
algorithm); which means that the {cmd:chaidforest} classifier is built as a "forest" of individual CHAID "trees."  After the forest of individual 
CHAID trees is "grown," predictions or observed probabilities for each observation can be obtained.  The multiple trees grown constitute the 
"forest" component of the random forest.  Traditionally, a classification and regression tree is used as the base learner for a random forest.  
As such, the {cmd:chaidforest} ensemble classifier can be expected to differ somewhat from other random forest classifiers and is similar in 
spirit to the {res}{it:cforest()}{txt} function in the R package 
{res}{it:{browse "http://cran.r-project.org/web/packages/party/party.pdf":party}}{txt}.

{pstd}
{cmd:chaidforest} proceeds by growing a number of trees set by the user.  By default, {cmd:chaidforest} randomly selects a subset of splitting 
variables (naturally, without replacement) and a subset of observations (optionally, with [the default] or without replacement) for each 
individual tree.  The random splitting variable and observation selection constitutes the "random" component of the random forest.

{pstd}
By combining many individual trees, with randomly selected splitting variables and observations, influential variables and observations have less 
impact on any individual tree.  In particular, less influence by specific splitting variables allows less influential variables to actually 
be used to split/partition the data variables in any given tree, increasing their representation in the final predictions and (potentially) 
enhancing out-of-sample prediction.  

{marker options}{...}
{title:Options}

{phang}{opt ntree()} specifies the number of individual trees {cmd:chaidforest} grows.  Using too few trees can result in some splitting variables 
or observations being omitted from the results (as they were never sampled).  The default number of trees is 100.

{phang}{opt nvuse()} specifies the number of candidate variables {cmd:chaidforest} will use for any single CHAID tree.  Indicating the total 
number of splitting variables stops the random sampling of variables as all variables will be used.  The default number of splitting variables 
is the (rounded) square root of the number of total splitting variables.

{phang}{opt minnode()} specifies the minimum number of observations allowed in a terminal cluster or "node" of an individual CHAID tree.  
See {stata findit chaid} for more details about the {opt minnode()} option.  The default value for {opt minnode()} is to use the value corresponding 
to .5% (rounded) of the total number of observations.

{phang}{opt minsplit()} specifies the minimum number of observations across all levels of an optimally merged splitting 
variable to allow any split to occur, irrespective of how many observations would be in each of the final clusters/nodes in an individual CHAID 
tree.  See {stata findit chaid} for more details about the {opt minsplit()} option.  The default value for {opt minsplit()} is to use the value 
corresponding to 1% (rounded) of the total number of observations.

{phang}{opt unordered()} treats the variable list included as "unordered."  The unordered treatment affects both how categories of the 
splitting variables are combined (i.e., any categories can be combined) in any individual CHAID tree.

{phang}{opt ordered()} treats the variable list included as "ordered."  The ordered treatment affects both how categories of the splitting 
variables are combined (i.e., only adjacent categories can be combined).  Ordered variables with {opt missing} invoked, when missing data 
are present, treat the missing category as a "floating" option which allows that category to be merged into any (set of) the other ordered 
categories in the CHAID trees.

{phang}{opt noisily} turns on the tracing of the command through split-related data management and estimation runs.  {opt noisly} 
can reassure the user that {cmd:chaidforest} is running or, can show the user the entire process of determining the splits arrived at by each
CHAID tree and the variable/observation selection process.

{phang}{opt missing} allows missing data in the response and splitting variables to be treated as another, independent category.  The 
missing option does not meaningfully affect unordered splitting variables, as the missing category is simply treated as another uncordered category. 
For ordered splitting and response variables with missing data, the {opt missing} option creates a "floating" missing data category.  
The {opt missing} option primarily affects ordered response variables which is allowed to have "partial" ordering in the Goodman association models 
underlying the estimation for each CHAID tree (i.e., all categories beside the missing data are ordered - the missing category has it's own 
"effect"). 

{pmore}The {cmd:missing} option can also result in missing (i.e., ".p", for {res}p{txt}redicted missing) as a predicted value and 
probability category.  Note that all missing values (i.e., ".", ".a", ".b", etc.) will be treated as a single category in the analysis.

{phang}{opt alpha()} sets the alpha level at which an optimally merged predictor will be split following the merging step in individual 
CHAID trees.  See {stata findit chaid} for more details about the {opt alpha()} option -  called {opt spltaplha()} in {cmd:chaid}.  The default 
value is .5.  Thus, splits that pass the p < .5 threshold are allowed to be split in the individual CHAID trees.

{phang}{opt dvordered} changes the treatment of the response variable from unordered (each "local" odds ratio allowed to be unique) to ordered 
(each "local" odds ratio forced to be the same) in the Goodman association models underlying the current implementation of each CHAID tree's 
estimation.  As was mentioned previously, missing data on the response variable allows the missing category to have a unique local odds 
ratio, and the rest of the categories to have the same odds ratio.

{phang}{opt xtile()} is a convenience command to take variables that are otherwise continuous, or ordered with many categories (i.e., counts), 
and generate a set of ordered categorical quantiles from those variables.  The variables created by {opt xtile()} are automatically considered 
as {opt ordered()} and are added to the dataset with the name "xt{it:varname}".  Any variables called "xt{it:varname}" already in the dataset will 
be overwritten when using {opt xtile()}.  The {opt xtile()} option allows the user specify the number of quantiles created as an option 
(i.e., {opt nquantiles(#)}) following a comma.  Not specifying the number of quantiles will result in 2 quantiles (i.e., a median split; the 
default for {cmd:xtile}).

{phang}{opt proos()} overrides the default random sampling with replacement (i.e., bootstrap sampling) to sampling without replacement.  
{opt proos()} indicates the proportion of the sample that is "out of sample" (i.e., "OOS") or not sampled.  It tends to be the case that bootstrap 
sampling obtains about 2/3rds of the observations (i.e., ~.3 is OOS) when the number of observations sampled is equal to the sample size (as is 
implemented by {cmd:chaidforest}).

{phang}{opt nosamp} overrides random sampling of observations (i.e., stops random sampling of or "bagging" observations).  All observations in the 
estimation sample will be in each CHAID tree.

{title:Remarks}

{pstd}{cmd:chaidforest} itself does not produce results but is rather a command used to "grow" the forest the results of which can subsequently be 
"harvested" through postestimation commands (see {help chaidforest_post: chaidforest postestimation}).  Reserving results presentation for the 
postestimation stage saves the user from having to wait for computation of statistics and other results in which they are not interested.

{pstd}As is implied by its name, there is an important element of randomness involved in growing the {cmd:chaidforest}.  The random components 
are comprised of the sampling splitting variables and observations from the pool of splitting variables and observations for each individual 
CHAID tree.  Due to the sampling, the user should {help set seed} prior to using {cmd:chaidforest} for reproducibility.  

{pstd}{cmd:chaidforest} makes extensive use of Ben Jann's {cmd:moremata} package (see {stata findit moremata}), which is required for 
running {cmd:chaidforest}.

{pstd}{cmd:chaidforest} is an almost fully Mata-based command which saves results to a "chaidtree" vector object called "results."  Thus, the 
results chaidtree object must remain in memory in Mata for the results to be accessed by postestimation commands.  Users will usually not be able 
to access these results directly unless they are familiar with Stata's {help class}es.  

{pstd}The CHAID algorithm used by each CHAID tree in {cmd:chaidforest} differs from that implemented by {cmd:chaid}.  In particular, 
{cmd:chaidforest} only uses the exhaustive CHAID algorithm (Biggs, et al., 1993).  Thus, all splits implemented by {cmd:chaidforest} are binary; 
there are no multi-way splits.  Similar to {cmd:chaid} only 20 levels of any splitting or response variable are allowed currently.  Splitting 
or response variables with > 20 levels will have to be manually collapsed before analysis.  Negative values of splitting and response 
variables are also not allowed and must be recoded (due to use of {help levelsof}).

{pstd}The CHAID algorithm used by each CHAID tree also uses Goodman (1979) association models to produce expected counts 
for chi-squares (i.e., as opposed to being based fully on {help ologit} or {help mlogit} models).  Goodman association models are loglinear models 
(i.e., Poisson regressions) modeling predicted/expected counts by "independent variables" in the row and column of a cross-classification.  
The expected counts produced by a traditional chi-square test can be obtained by treating the counts per cell as a 
dependent variable and the dummy-coded row/response and column/splitting variables as independent variables.  An ordered response or 
splitting variable changes the ordered variable to be treated as continuous in the loglinear model (as opposed to dummy coded).  
The Goodman models also allow for missing data on splitting or response variables irrespective of variable type (ordered 
or unordered) when {opt missing} is invoked - incorporated as a dummy code reflecting that missing level in the loglinear model.

{pstd}Due to numerical issues related to storage of very small p-values, {cmd:chaidforest} uses the Akaike information criterion 
(see {help estat:estat}) to decide on splits and the McFadden R-square metric (see {help maximize:maximize}) to decide on mergers 
when p-values are effectively identical (i.e., when both are effectively 0 at ~10^-300). 

{title:{cmd:chaidforest}'s Run Time}

{pstd}To manage expectations - the user should be warned that {cmd:chaidforest} is not a particularly fast command to execute compared to other 
random forest classifiers.  {cmd:chaidforest} was made to be user-friendly, to run entirely from standatd Stata syntax, and to run without the 
need for plugins (i.e., to C++) which would speed up the run time (see, for example, {stata findit boost}) but would require more of the user to 
implement.  

{pstd}The CHAID algorithm is "brute force" in how it merges categories.  CHAID's method is intended to be less biased than 
alternatives in terms of selecting splitting variables on which to split, but consequently can be time consuming.  Moreover, unlike single 
CHAID trees, trees in the {cmd:chaidforest} implementation are intended to be lenient in terms of size of tree growth.  In other 
words, {cmd:chaidforest} is allowed to grow very large individual trees to enhance classification.  Specifically, each CHAID tree 
differs from {cmd:chaid}'s implementation as each split is not Bonferroni corrected, each has high default splitting p-values 
(i.e., .5), always uses the exhaustive CHAID merging criterion which creates binary splits, and generally has small values for 
minimum splitting and node observation counts.  The foregoing characteristics allow for overfitting any individual tree, which 
is good (in the aggregate) for classificiation accuracy, but in combination with CHAID's brute force merging rules can make for 
long run times for any single forest. 

{pstd}{res}The recommended approach to speeding run time is to {help collapse} the data and use frequency weights.{txt}  Datasets 
with many observations slow down processing.  Thus, reducing the number of observations by collapsing across identical observations greatly 
speeds all computations with no loss of precision or effect on the results.

{pstd}Besides the number of observations, {cmd:chaidforest}'s run time is most dependent on the number of levels the splitting 
variables have - as all valid potential mergers of levels within a splitting variable are attempted for each split, for each tree.  
The number of potential mergers then (can) grow(s) geometrically with additional levels of splitting variables.  Generally, the 
number of levels per splitting variable affects runtime more for unordered (i.e., variables in {opt unordered()}) than ordered (i.e., 
variables in {opt ordered()}) variables.  Unordered variables attempt to merge all possible levels as compared to ordered variables 
which only try to merge adjacent levels resulting in differences in run time.  Note that {opt missing} also adds more levels 
to variables with missing data.  In light of the discussion above, one way to reduce run time is by manually merging levels of 
splitting variables.  Binary variables, for instance, require no merging.  In general, manually merging splitting variable 
categories (by the user or by using {opt xtile()}) can save a substantial amount of run time.  Users should, of course, 
carefully consider the effect of such mergers on the results as accuracy can be affected.

{pstd}{cmd:chaidforest}'s run time is also dependent on: {res}a]{txt} the number of trees grown (i.e., {opt ntree()}), 
{res}b]{txt} the number of splitting variables per tree (i.e., {opt nvuse()}), 
{res}c]{txt} the minimum size allowed to split and minimum node/cluster size (i.e., using {opt minsplit()} and {opt minnode()}), and 
{res}d]{txt} the probability value allowed to split (i.e., {opt alpha()}).

{pstd}Options {res}b]{txt}-{res}d]{txt} correspond to parameters which affect the  size of the trees grown and prediction accuracy 
for any one CHAID tree.  Small minimum split and node sizes allow for overfitting, as does large p-values, which although more time 
consuming, large individual CHAID trees will result in better classification accuracy which is favorable for accuracy in the aggregate.  
Additionally, more splitting variables allow for bigger possible trees (as well as longer run times), but fewer chances for 
moderately predictive splitting variables to improve accuracy.  The user is urged to use all 3 these options carefully as they can 
affect predictions.

{pstd}Option {res}a]{txt} corresponds to smoothing over the randomness of the any individual tree in the forest.  More trees take longer to run, 
but tend to produce better, more replicable, and more consistent results.  Thus, reducing the number of trees below the default is not generally 
recommended - but adding more trees, when feasible, is encouraged.

{title:Introductory examples}

#1: Basic random forest analysis with altered {opt minsplit()} and {opt minnode()} and very liberal {opt alpha()}
{phang}{cmd:clear all}

{phang}{cmd:set seed 1234567}

{phang}{cmd:webuse auto}

{phang}{cmd:chaidforest foreign, unordered(rep78) minnode(2) minsplit(5) xtile(length weight, nquantiles(3)) alpha(.8)}

#2: Basic random forest analysis as in #1 with specified out-of-bag proportion and sampling without replacement
{phang}{cmd:chaidforest foreign, unordered(rep78) minnode(2) minsplit(5) xtile(length weight, nquantiles(3)) proos(.25)}

#3: Large-scale random forest with ordered response variable and specified number of trees ({res}warning:{txt} can be time consuming)
{phang}{cmd:webuse nhanes2f, clear}

{phang}{cmd:chaidforest health, dvordered unordered(region race) ordered(diabetes sex smsa heartatk) xtile(houssiz sizplace, nquantiles(3))} 
{cmd:ntree(500)}

#3: Large-scale random forest as in #3, collapsed with frequency weight
{phang}{cmd:preserve}

{phang}{cmd:generate byte fwgt = 1}

{phang}{cmd:xtile xthoussiz = houssiz, nquantiles(3)}

{phang}{cmd:xtile xtsizplace = sizplace, nquantiles(3)}

{phang}{cmd:collapse (sum) fwgt, by(health region race xthoussiz xtsizplace diabetes sex smsa heartatk)}

{phang}{cmd:chaidforest health [fweight = fwgt], dvordered unordered(region race) ordered(xthoussiz xtsizplace diabetes sex smsa heartatk) ntree(500)}

{phang}{cmd:restore}

#4: Random forest without "bagging" observations (only randomly selects splitting variables)
{phang}{cmd:webuse sysdsn1, clear}{p_end}

{phang}{cmd:chaidforest insure, ordered(male nonwhite) unordered(site) xtile(age, nquantiles(2)) nosamp}{p_end}

#5: Random forest without random splitting variable selection (only "bags" observations)
{phang}{cmd:chaidforest insure, ordered(male nonwhite) unordered(site) xtile(age, nquantiles(2)) nvuse(4)}{p_end}

#6: Random forest incorporating missing data 
{phang}{cmd:chaidforest insure, ordered(male nonwhite) unordered(site) xtile(age, nquantiles(2)) missing}{p_end}

{title:Saved results}

{phang}{cmd:chaidforest} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(ntree)}}number of CHAID trees in the random forest{p_end}
{synopt:{cmd:e(nvuse)}}number of splitting variables used per CHAID tree{p_end}
{synopt:{cmd:e(N_tree)}}number of observations used per CHAID tree{p_end}
{synopt:{cmd:e(minsplit)}}minimum number of observations required for any CHAID tree to try to continue to make splits in the data{p_end}
{synopt:{cmd:e(minnode)}}minimum number of observations required for any CHAID tree to allow a node/cluster to actually be split{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:chaidforest}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(splitvars)}}list of splitting variable names{p_end}
{synopt:{cmd:e(depvar)}}name of dependent/response variable{p_end}
{p2col 5 15 19 2: functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:References}

{p 4 8 2}Breiman, L. (2001). Random forests. {it:Machine learning, 45(1)}, 5-32.

{p 4 8 2}Biggs, D., de Ville, B., and Suen, E. (1991). A method of choosing multiway partitions for classification and decision trees. {it:Journal of Applied Statistics, 18}, 49-62.

{p 4 8 2}Goodman, L. A. (1979). Simple models for the analysis of association in cross-classifications having ordered categories. {it:Journal of the American Statistical Association, 74(367)}, 537-552.

{p 4 8 2}Kass, G. V. (1980). An exploratory technique for investigating large quantities of categorical data. {it:Applied Statistics, 29, 2}, 119-127.

{p 4 8 2}Strobl, C., Malley, J., and Tutz, G. (2009). An Introduction to recursive partitioning: Rationale, application, and characteristics of classification and regression trees, bagging, and random forests. {it:Psychological Methods, 14(4)}, 323–348.

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Senior Scientist{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}

{title:Also see}

{psee}
{manhelp levelsof R}, {manhelp tabulate_twoway R:tabulate twoway}, {manhelp xtile R}, {manhelp poisson R}, {manhelp maximize R}, 
{manhelp estat R}, {manhelp collapse R}.
{p_end}
