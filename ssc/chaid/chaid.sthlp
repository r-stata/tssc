{smcl}
{* *! version 2.1 Dec 16th, 2014 J. N. Luchman}{...}
{cmd:help chaid}
{hline}{...}

{title:Title}

{pstd}
Chi-square automated interaction detection (CHAID){p_end}

{title:Syntax}

{phang}
{cmd:chaid} {depvar} {ifin} {weight} [{cmd:,} {opt {ul on}minn{ul off}ode(integer)} {opt {ul on}mins{ul off}plit(integer)} 
{opt {ul on}uno{ul off}rdered(varlist)} {opt {ul on}ord{ul off}ered(varlist)} {opt {ul on}noi{ul off}sily} 
{opt {ul on}mis{ul off}sing} {opt {ul on}merga{ul off}lpha(pvalue)} {opt {ul on}respa{ul off}lpha(pvalue)}
{opt {ul on}splta{ul off}lpha(pvalue)} {opt {ul on}maxb{ul off}ranch(integer)} {opt {ul on}dvo{ul off}rdered}
{opt noadj} {opt nodisp} {opt {ul on}pred{ul off}icted} {opt {ul on}imp{ul off}ortance} {opt {ul on}xt{ul off}ile(varlist, xtile_opt)} 
{opt {ul on}p{ul off}ermute} {opt svy} {opt {ul on}ex{ul off}haust}]

{phang}
{cmd:fweights} are allowed; see {help weight}{p_end}

{title:Description}

{pstd}
{cmd:chaid} is a recursive partitioning algorithm that searches for an optimal decision tree structure based on 
the correspondence between the dependent/response variable and a set of independent/splitting variables.  {cmd:chaid} is part 
prediction, part clustering estimation command that seeks to reduce uncertainty about the values of/predict a response variable 
but simultaneously partitions the dataset into clusters of observations based on the set of splitting variables.  

{pstd}
The {cmd:chaid} algorithm cycles through 2 (or, optionally, 3) processes recursively.  First, {cmd:chaid} seeks to reduce overfitting the data
by optimally merging together categories/levels of a splitting variable {it:i}.  Without the optimal merging step, the splits {cmd:chaid} uncovers 
tend to be biased toward predictors with more categories.  In the merging step, {cmd:chaid} chooses a splitting variable {it:i} of the {it:p} total 
splitting variables and deciphers the total number of possible combinations {it:k} of 2 levels {it:j} of splitting variable {it:i} that are 
"mergable" according to the splitting variable type (for unordered splitting variables, all combinations of two levles are possible; for ordered 
splitting variables, only adjacent level value combinations are possible).  {cmd:chaid} then takes combination {it:j} and conducts a statistical 
association test (i.e., chi-square) using combination {it:j} (i.e., omitting all other combinations, using combination {it:j} as a dummy 
code/indicator) on the response variable to determine the probability (i.e., p-value) of the association between the response variable and the 
categories separated by combination {it:j} being 0. The process of obtaining p-values from a chi-square test continues for all {it:k} combinations 
of splitting variable {it:i}.  After all {it:k} combinations have obtained a p-value, {cmd:chaid} finds the combination {it:j} that has the highest 
p-value/weakest association with the response variable.  If the magnitude of the p-value is higher than a user-defined threshold, combination 
{it:j} are merged into a single category.  To add a little more detail, high p-values in the merging step indicate a high probability that the 
categories separated by combination {it:j} are independent of the response variable, would not likely produce a meaningful split, and can 
effectively be merged together.  After merging the categories with the highest p-value, {cmd:chaid} then begins again, deciphering, again for 
splitting variable {it:i}, the number of valid combinations {it:k} with the formerly separate categories now treated as a single category.  
The merging process continues for splitting variable {it:i} until the combination {it:j} with the highest p-value does not pass the user defined 
threshold for merging or there are 2 levels remaining in the optimally merged splitting variable.  When the p-value for combination {it:j} does 
not pass the thnreshold for merging, {cmd:chaid} remembers the optimal merging of levels associated with splitting variable {it:i} and moves to 
the next splitting variable. The optimal merging stage continues until all {it:p} splitting variables have an optimally merged structure.  
{cmd:chaid} then moves to step 2.

{pstd}
Following the merging step, chaid moves to the second, splitting step. {cmd:chaid} uses the optimally merged structure to decide which variable, 
if any, should be used to split the data into clusters/nodes.  For all {it:p} optimally merged splitting variables, {cmd:chaid} conducts a chi-square 
association test of that splitting variable {it:i} on the response variable and records the p-value.  Owing to the multiple comparisons, the 
p-value in the splitting step is Bonferroni adjusted according to splitting variable type.  After optaining all {it:p} adjusted p-values, 
{cmd:chaid} finds the smallest and, if the p-value threshold and other splitting criteria are met, the data are split into clusters/nodes based on 
the splitting variable with the smallest adjusted p-value.  Besides the p-value threshold, {cmd:chaid} imposes several other criteria on splits.
In particular, the clusters/nodes must be of a certian size.  For example, if the minimum cluster/node size is 100, and {cmd:chaid} finds a split 
in the data that would produce 3 clusters of size 175, 120, and 80 - the split will be prevented as one of the possible splits is smaller than the 
minimum.  When {cmd:chaid} finds a split that will be smaller than the minimum size, all the observations in the data associated with that potential 
split are removed from consideration of any remaining splits and the algorithm moves to other observations that are still "splitable".  If 
{cmd:chaid} produces a split in the data, or decides to move along to other splitable observations, it begins again at Step 1 and forgets the 
optimal merging it produced in the previous step.  Moreover, {cmd:chaid} now searches {bf:within} each cluster for another optimal merger set and 
potential split.  Thus, when a split occurs, all subsequent merging and splitting are contingent on previous splits and the dataset is "partitioned" 
conditional on the previous splits.

{pstd}
The {cmd:chaid} algorithm stops when a] the minimum cluster/node size is not met for potential splits across all clusters, b] the minimum cluster/node 
size is not met for splitting across all cluters (i.e., when {cmd:chaid} moves from Step 2 back to Step 1, the size of the cluster is below the 
minimum size allowed to attempt a split, c] the cluster/node is pure (i.e., composed of single value of response variable), d] the maximum number 
of branches/contingencies is met, and e] a cluster has a single value for each splitting variable (i.e., no splits possible).  
When the 5 criteria are met across all observations/clusters/nodes in the data, {cmd:chaid} stops and reports results.

{pstd}
Traditionally, a third step occurring during Step 1  above involving attempting to "re-split" a merged combination of the levels of a splitting 
variable is attempted.  Specifically, after a merger between combination {it:j} occurs, if combination {it:j} contains 3 or more levels of 
splitting variable {it:i}, {cmd:chaid} attempts a "Step 2-like" split in which {cmd:chaid} searches through all potential binary splits (i.e., 
splits into 2 categories) of the 3 or more optimally merged categories.  If the used-defined threshold is met, the split is carried out and the 
newly split set of levels is substituted into the merging levels set in Step 1.  The "re-split" step is implemented in {cmd:chaid} as an option 
(when {opt respalpha()} receives a positive probability value).  The re-splitting step is necessary to reach near optimal results, but can greatly 
increase run time and as Kass (1980) notes "In practice a merger is rarely split,..." (p. 121).  Hence, the user can choose to invoke or ignore 
this step.

{pstd}
The current implementation of {cmd:chaid} differs from the traditional use of contingency tables in that it uses logistic models to 
estimate chi-square values and, as such, may require somewhat larger sample sizes than do other implementations of {cmd:chaid} for the 
{cmd:ml} algorithm to converge.  The default estimation method for {cmd:chaid} is {help mlogit}.  The use of Stata's {cmd:ml} based commands 
greatly increases the flexibility of the kinds of data {cmd:chaid} can accomodate.  {cmd:chaid} also uses {help levelsof} to separate out levels 
of splitting and response variables.  Consequently, all splitting variables and the response variable must non-negative integers and, for the 
current implementation, must have fewer than 21 levels or unique values.

{pstd}
{cmd:chaid} generates, by default, a variable named {cmd:_CHAID} after finishing execution that indicates each observation's 
membership in a cluster as defined by {cmd:chaid}.  If you have a variable named {cmd:_CHAID} already in your dataset, {cmd:chaid} 
will overwrite it with the new value of {cmd:_CHAID} based on the current cluster membership.

{title:Display}

{pstd}
The decision tree structure is returned in two forms 1) as a matrix that is read from top-down, and 2) as a graph which shows the hierarchical 
structure of the {cmd:chaid} tree including the split contingencies.  For example consider the results from example #1 below (i.e., the below 
matrix is exactly what {cmd:chaid} reports):

{res}Chi-Square Automated Interaction Detection (CHAID) Tree Branching Results
{txt}{hline 80}

{col 20}1{col 34}2{col 48}3{col 62}4
{txt}{col 6}{c TLC}{hline 57}{c TRC}
{col 4}1{col 6}{c |}{col 11}{res}xtlength@1{col 25}xtlength@2{col 39}xtlength@2{col 53}xtlength@3{col 64}{txt}{c |}
{col 4}2{col 6}{c |}{res}{col 24}rep78@1 3 2{col 40}rep78@4 5{col 64}{txt}{c |}
{col 4}3{col 6}{c |}{res}{col 11}{res}Cluster #1{col 25}Cluster #2{col 39}Cluster #4{col 53}Cluster #3{col 64}{txt}{c |}
{txt}{col 6}{c BLC}{hline 57}{c BRC}

{pstd}
The results show that 4 clusters were uncovered from the data (the clusters are out of order due to the way in which the algorithm 
searches for splits) - each column represents a distinct cluster uncovered by {cmd:chaid}.  The first split is represented in the first 
row.  Each column in the first row has a variable name, an ampersat sign, and some valid values of the variable.  The variable name represents
the variable on which the first split occurred for the {cmd:chaid} algorithm - in this case the {help xtile}d length variable from the auto 
dataset.  The values following the ampersat signs refer to the values chosen through the optimal merging steps described above of the variable.  
In this case, all valid values were deemed by {cmd:chaid} to be different from one another and were not merged.  Thus, split #1 was on the lentile
variable into levels 1, 2, and 3.  The dataset was then partitioned based on that split and the remaining splits are then conditional on the first 
split.  All successful {cmd:chaid} runs will have a populated first row.

{pstd}
Notice that Clusters #2 and #4 have repeated values of xtlength@2.  This is because another split occurred within xtlength@2, but not for xtlength@1 
or xtlength@3 - which is why each only has an entry at the first row.  The split on xtlength@2 is represented in the second row for the rep78 
variable, splitting into optimally merged 1 3 2 and 4 5 groups.  Thus, given a observation was in xtlength category 2, one additional split was 
possible putting observations into rep78 1 3 and 2 versus 4 and 5.  The rows "lower" on the matrix are then response on the rows "higher"
in the matrix.  Furthermore, the number of rows represents the number of "branches" the decision tree has.  Finally, each column represents each 
cluster's unique "path" leading from the first split in row 1 to the final populated row of the column/cluster in question.

{pstd}
The graph that is returned by {cmd:chaid} can be cluttered with value labels.  If unreadable, consider using Stata's 
{help graph_editor:graph editor} to alter the size, angle, and location of the labels.  Currently, graph options are not available to alter the 
appearence of the graph using Stata syntax directly.

{marker options}{...}
{title:Options}

{phang}{opt minnode()} specifies the minimum number of observations allowed in a terminal cluster or "node."  If an 
optimally merged splitting varible passes to the point of splitting, but one or more of the clusters that would be created 
by the optimally merged splitting variable is below the {opt minnode()} value, the split will not be carried out. Thus, 
{opt minnode()} prevents {cmd:chaid} from carrying out Step 2. The default value for {opt minnode()} is 100.

{phang}{opt minsplit()} specifies the minimum number of observations across all levels of an optimally merged splitting 
variable to allow any split to occur, irrespective of how many observations would be in each of the final clusters.  Hence, 
previous to clustering, if a the number of observations does not meet the {opt minsplit()} minimum, no clustering will occur.  
{opt minsplit()} prevents {cmd:chaid} from executing Step 1.  The default value for {opt minsplit()} is 200.

{phang}{opt unordered()} treats the variable list included as "unordered."  The unordered treatment affects both how 
categories of the splitting variables are combined (i.e., any categories can be combined), and how final significance of 
the optimally merged splitting variable is computed (i.e., unordered Bonferroni adjustment).  Unordered predictors are 
the most time intensive splitting variables for which to discern an optimal merging, as all categories are potentially 
allowed to be merged. 

{phang}{opt ordered()} treats the variable list included as "ordered."  The ordered treatment affects both how 
categories of the splitting variables are combined (i.e., only adjacent categories can be combined), and how final 
significance of the optimally merged splitting variable is computed (i.e., ordered Bonferroni adjustment).  Ordered 
variables with {opt missing} invoked, when missing data are present, treat the missing category as a "floating" option 
and, consequently, adjusts the p-value for splitting based on the floating category as opposed to the usual ordered 
adjustment. 

{phang}{opt noisily} turns on the tracing of the command through split-related data management and estimation runs.  {opt noisly} 
can reassure the user that {cmd:chaid} is running or, can show the user the entire process of determining the splits arrived at by 
{cmd:chaid}.

{phang}{opt missing} allows missing data in the response and splitting variables to be treated as another category.  The 
missing option does not affect unordered splitting variables, but does result in all ordered indepdent variables with missing 
data, to have a "floating" missing data category.  Note that with the {opt dvordered} option that missing data on the response 
variable is not treated as another category but, rather, is treated as missing and marked out of the sample.  Missing data with 
ordered response variables must be imputed through some other means to be included in {cmd:chaid}.  The {cmd:missing} option 
can also result in missing (i.e., ".") as a predicted value when combined with {cmd:predicted}.

{phang}{opt mergalpha()} sets the alpha level at which an allowable pair of categories in an splitting variable can be 
merged in the merging step.  {opt mergalpha()} refers to the probability values the chi-square would take on that would 
{it:allow} a merge.  The default value is .95.  Thus, p-values that are among the middle 95% of the probability 
density for the chi-squqare distribution are merged.  In other words, predictors that pass the p > .05 threshold are 
allowed to be merged.

{phang}{opt respalpha()} sets the alpha level at which an already optimally merged set of 3 or more of an independnet variable's 
original categories will be allowed to de-couple into a binary split.  How the splitting variables are split depends, of course, 
on the splitting variable's type and whether the {opt missing} option is invoked.  {opt respalpha()} refers to the probability 
values the chi-square would take on that would {it:allow} a split.  The default setting for this option is to a negative value, which 
shuts this option off.  If the user chooses to invoke the {opt resplapha()} option, the value for this option must be smaller than 
the value of 1 - {opt mergalpha()}.

{phang}{opt spltalpha()} sets the adjusted alpha level at which an optimally merged predictor will be split following the 
merging step.  As compared to {opt mergalpha()}, {opt spltalpha()} works in the same way, save that small p-values will 
produce a split - just as small p-values are deemed to be statistically significant. The default value is .05.  Thus, 
predictors that pass the p < .05 threshold are allowed to be split.

{phang}{opt maxbranch()} sets the maximum number of "branches" on which the {cmd:chaid} tree is allowed to take.  In other words, 
{opt maxbranch()} sets a maximum in the number of splits on which a particular terminal cluster can be based.  The default 
value is for there to be {it:no} maximum in terms of the number of splits.  Any negative value will turn off 
{opt maxbranch()}.

{phang}{opt dvordered} changes the estimation procedure underlying {cmd:chaid} to be {help ologit} instead of the default 
{help mlogit}.  Hence, {opt dvordered} treats the response variable as being ordered.

{phang}{opt noadj} prevents {cmd:chaid} from Bonferroni adjusting the {opt spltalpha()} p-values to prevent potential Type I/"false positive" 
inferential error. {opt noadj} is useful in cases where the user desires to be more lenient in terms of uncovering 
relationships in the data. {opt noadj} is turned on by default when using {opt permute} as the Bonferroni adjustment is
intended to approximate exact/permutation p-values (see Kass, 1980).

{phang}{opt nodisp} prevents {cmd:chaid} from displaying the decision tree structure and graph produced by the algorithm.  

{phang}{opt predicted} produces a predicted value for the response variable for each cluster.  The predicted value is the mode of the response 
variable for that cluster.  When {opt predicted} is invoked, {cmd:chaid} produces a variable called {cmd:CHAID_predict} containing the predicted 
value by default.  Any variable named {cmd:CHAID_predict} in the dataset, including those from previous runs of {cmd:chaid}, will be overwritten.

{phang}{opt importance} produces a permutation importance matrix for rank ordering the splitting variables.  The permutation importance approach 
derives from the idea that if one randomly permutes the values of any one splitting variable there should be a decrease in fit if that splitting 
variable predicts the response variable.  Larger decreases in fit based on permutations of a splitting variable indicate that a splitting 
variable is better at predicting the response variable than smaller decreases in fit.  All fit scores are computed based on Cram{c e'}r's V 
(see {help tabulate_twoway:tabulate twoway}), which obtains perfect fit when all the clusters have a single value (i.e., are pure) or a similar 
metric when combined with {opt svy}.  The decreases in fit owing to permutation are normed out of 1 and displayed in the "raw" row of 
{cmd:e(importance)}.  Because it is possible to obtain negative decrements to fit (that is, increases in fit) due to permuting the values of a 
splitting variable, and due to the random nature of the permutation, the values in the "raw" row are not particularly meaningful and only the the 
second row, "rank", of {cmd:e(importance)} should be interpreted.  Note that {opt importance} creates a Mata matrix called "ifstmnts" that it uses 
to conduct the permutation importance computations that the user can access.

{phang}{opt xtile()} is a convenience command to take variables that are otherwise continuous, or ordered with many categories (i.e., counts), 
and generate a set of ordered categorical quantiles from those variables.  The variables created by {opt xtile()} are automatically considered 
as {opt ordered()} and are added to the dataset with the name "xt{it:varname}".  Any variables called "xt{it:varname}" already in the dataset will 
be overwritten when using {opt xtile()}.  The {opt xtile()} option allows the user specify the number of quantiles created as an option 
(i.e., {opt nquantiles(#)}) following a comma.  Not specifying the number of quantiles will result in 2 quantiles (i.e., the default 
for {cmd:xtile}).

{phang}{opt permute} changes the way in which p-values are computed for splitting and merging steps from the traditional large-sample approximation 
to a monte-carlo permutation test-based approach (see {help permute} for details).  Permutation tests are more approproate for smaller sample sizes 
(i.e., conditions under which large sample approximations will not hold) and tend to be more conservative than the large sample approximation and, 
thus, tend to produce fewer splits than the same model not using {opt permute}. {opt permute}, owing to its monte carlo-based approach, greatly 
increases {cmd:chaid}'s run time.  Permuation tests also do not require Bonferroni adjustment and thus imply {opt noadj}.  {opt permute} does not 
work with {opt svy} or {help weight}s.

{phang}{opt svy} incorporates {help svyset} complex survey design characterisitics into the p-value computation.  As with other {help svy} commands, 
the data must be {help svyset} previous to running {cmd:chaid}.  Option {opt svy} and {help weight}s cannot be used together.  Additionally, 
option {opt svy} and {opt permute} cannot be used together.

{phang}{opt exhaust} implements the exhaustive CHAID algorithm described by Biggs, de Ville, and Suen (1991).  The only difference between exhaustive 
and traditional CHAID is that exhaustive CHAID continues the merging step until only a 2 categories/a binary split remains.  Thus, exhaustive 
CHAID ignores {opt mergalpha()} and will continue to merge categories until 2 optimally merged categioies of the original set if categories of 
variable {it:i} remain.  Option {opt exhaust} also changes the way the Bonferroni adjustment is computed as the way it merges categories differs 
from the traditonal method.

{title:Remarks}

{phang}Because there is a component of randomness to the {cmd:chaid} results, the user should {help set seed} prior to using {cmd:chaid}.  
Additionally, {cmd:chaid} utilizes Mata and saves a string matrix there that the user can access post estimation.  One Mata matrix, called 
"CHAIDsplit", contains information used to create the {cmd:e(split#)} and {cmd:e(path#)} macros.  In some instances, most especially with complicated 
and large CHAID trees, the strings contained in some of the {cmd:e(path#)} macros will be truncated.  Users knowlegable of Mata can obtain such 
information from the "CHAIDsplit" Mata matrix.  To be specific, "CHAIDsplit" includes, in the first row, information regarding all the splits in 
the data.  The first column is a label, "splits", and each column thereafter corresponds to a split made in the data.  The labels are represented as 
"{it:varname value}" with no space between them.  Thus, the {it:rep78} variable from the auto dataset would have 5 labels: rep781, rep782, rep783, 
rep784, and rep785 - corresponding to all 5 levels of the rep78 variable. Merged categories are separated in the "splits" row by commas.  Thus, any 
labels not separated by a comma have been "optimally merged" by {cmd:chaid}.  The remaining rows correspond to the "path" represented by each cluster. 
Thus "path1" is the set of contingencies (or "and" logical statements that resulted in "Cluster #1", "path2" is the set of contingencies that 
resulted in "Cluster #2", etc... using the labels as outlined above (i.e., with "{it:varname value}" format).

{phang}As with other computationally intense programs (e.g., {stata findit gllamm}), collapsing the data over identical observations and 
using a {cmd:fweight} is a way to speed up estimation time for larger datasets.  Given that {cmd:chaid} requires categorical data, using the 
{help collapse} command is a particularly useful approach - but, again, will not work with {opt svy} or {opt permute}.

{phang}Due to numerical issues related to storage of very small p-values, {cmd:chaid} uses the Akaike information criterion (AIC; see {help estat}) 
to decide on splits when p-values are identical (i.e., when both are effectively 0 at ~10^-300). 

{title:Introductory examples}

#1: Basic CHAID analysis with altered {opt minsplit()} and {opt minnode()}
{phang}{cmd:set seed 1234567}{p_end}

{phang}{cmd:webuse auto}{p_end}

{phang}{cmd:chaid foreign, unordered(rep78) minnode(4) minsplit(10) xtile(length, n(3))}{p_end}

#2: Basic CHAID analysis as in #1 with permutation tests
{phang}{cmd:chaid foreign, unordered(rep78) minnode(4) minsplit(10) xtile(length, n(3)) permute}{p_end}

#3: Larger-scale CHAID with ordered response variable and permutation importance
{phang}{cmd:webuse nhanes2f, clear}{p_end}

{phang}{cmd:chaid health, dvordered unordered(region race) ordered(houssiz sizplace diabetes sex smsa heartatk) importance}{p_end}

#4: Larger-scale CHAID with ordered response variable; collapsed using fweight
{phang}{cmd:preserve}{p_end}

{phang}{cmd:generate byte fwgt = 1}{p_end}

{phang}{cmd:collapse (sum) fwgt, by(health region race houssiz sizplace diabetes sex smsa heartatk)}{p_end}

{phang}{cmd:chaid health [fweight = fwgt], dvordered unordered(region race) ordered(houssiz sizplace diabetes sex smsa heartatk)}{p_end}

{phang}{cmd:restore}{p_end}

#5: Exhaustive CHAID with complex survey design
{phang}{cmd:svyset psuid [pweight=finalwgt], strata(stratid)}{p_end}

{phang}{cmd:chaid health, dvordered unordered(region race) ordered(houssiz sizplace diabetes sex smsa heartatk) svy exhaust}{p_end}

{title:Saved results}

{phang}{cmd:chaid} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_clusters)}}number of clusters created by {cmd:chaid} and returned in {cmd:_CHAID} variable{p_end}
{synopt:{cmd:e(fit)}}purity of the clusters (extent to which each cluster has only a single value of the response variable); 
based on Cram{c e'}r's V{p_end}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:chaid}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(path#)}}displays the levels of each split leading to cluster #.  Each split is separated by semicolons.  
The splitting variable is first followed by an "at" sign (i.e., @) followed by the levels of the splitting variable that 
describes cluster # at that split{p_end}
{synopt:{cmd:e(split#)}}displays the #th split by {cmd:chaid}.  Splitting variable is displayed first followed 
by the optimal mergers of levels of the splitting variable.  Each merged set of splitting variable levels is separated 
by parentheses{p_end}
{synopt:{cmd:e(depvar)}}name of dependent/response variable{p_end}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:e(importance)}}permutation importance matrix{p_end}
{synopt:{cmd:e(sizes)}}sample size of each cluster{p_end}
{synopt:{cmd:e(branches)}}number of branches from the root node for each cluster{p_end}
{p2col 5 15 19 2: functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:References}

{p 4 8 2}Kass, G. V. (1980). An exploratory technique for investigating large quantities of categorical data. {it:Applied Statistics, 29, 2}, 119-127.{p_end}

{p 4 8 2}Biggs, D., de Ville, B., and Suen, E. (1991). A method of choosing multiway partitions for classification and decision trees. {it:Journal of Applied Statistics, 18}, 49-62.

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Behavioral Statistics Lead{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}

{title:Acknowledgements}

{phang}Thanks to Florian Zettelmeyer, Paul Bergmann, and Kimberly Wilson for bug reporting.  
Thanks also to Jonathan Mendelson and Luke Viera for comments on the functionality of and suggestions about features for {cmd:chaid}.

{title:Also see}

{psee}
{manhelp mlogit R}, {manhelp ologit R}, {manhelp levelsof R}, {manhelp tabulate_twoway R:tabulate twoway}, {manhelp svy R}, {manhelp permute R},
{manhelp xtile R}.
{p_end}
