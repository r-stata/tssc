{smcl}
{* *! version 1.0  10Dec2018}{...}
{cmd:help crtrees} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: crtrees} {hline 2} Classification and Regression Trees and Random Forests.}
{p2colreset}{...}

{title:Syntax}
	
{p 8 16 2}
{opt crtrees} {depvar} [{varlist}] {ifin} {cmd:,} [{it:options}]

{phang}
{it:varlist} is the list of splitting variables.{p_end}

{synoptset 20 tabbed}{...}

{synopthdr}
{synoptline}

{syntab: Model}
{synopt: {opt rfor:ests}} performs Random Forests{p_end}
{synopt: {opt class:ification}} grows tree(s) using Classification options{p_end}
{synopt: {opt gen:erate(newvar)}} new variable name for model predictions{p_end}
{synopt: {opt boot:straps(#)}} sets number of bootstrapped samples{p_end}
{synopt: {opt seed:(#)}} sets random-number seed; see {help seed}{p_end}
{synopt: {opt stop:(#)}} sets stopping criterion for growing the tree{p_end}

{syntab: Regression}
{synopt: {opt reg:ressors(varlist)}} {varlist} of regression controls{p_end}
{synopt: {opt nocon:stat}} suppress constant term{p_end}
{synopt: {opt level(#)}} sets confidence level as a percentage; default is level {it:95}{p_end}

{syntab: Classification}
{synopt: {opt imp:urity(string)}} name of impurity measure ("gini" or "entropy"){p_end}
{synopt: {opt pr:iors(string)}} name of existing stata matrix with prior class probabilities{p_end}
{synopt: {opt c:osts(string)}} name of existing stata matrix with costs of misclassification{p_end}
{synopt: {opt d:etail}} displays additional statistics for terminal nodes{p_end}

{syntab: CART}
{synopt: {opt lss:ize(#)}} sets the relative size of the learning sample{p_end}
{synopt: {opt ts:ample(newvar)}} new variable name for 0/1 identifier of test sample{p_end}
{synopt: {opt vcv(#)}} sets V-fold cross validation parameter{p_end}
{synopt: {opt rule:(#)}} sets SE rule for selecting the tree{p_end}
{synopt: {opt t:ree}} displays a text representation of the estimated tree{p_end}
{synopt: {opt st:_code}} displays Stata code to generate predictions

{syntab: Random Forests}
{synopt: {opt rsplit:ting(#)}} sets the relative size of the directions for splitting{p_end}
{synopt: {opt rsampl:ing(#)}} sets the relative sample size for each tree{p_end}
{synopt: {opt oob}} computes out-of-bag errors{p_end}
{synopt: {opt ij}} computes standard errors using the Infinitessimal Jacknife{p_end}
{synopt: {opt save:trees(string)}} name of file to save mata matrices of bootstrapped trees, their node criteria and coefficients{p_end}

{hline}

{p 4 4 2}
Model, Regression, and Classification options are shared by Classification and Regression Trees and Random Forests.
CART options are only available for Classification and Regression Trees algorithms.
Random Forests options are available only for the Random Forests algorithm.
All variables must be numeric.
Missing values are not allowed.
In Classification, {it:depvar} must be discrete (see {help datatype}).
Splitting variables can be cardinal or ordinal.
In Regression, splitting variables can simultaneously be regressors.
{opt by} is allowed; see {help prefix}.
Post-estimation command {cmd:predict} is allowed; see {help crtrees_p}{break}
{p_end}

{title:Description}

{pstd}
{cmd:crtrees} performs Classification Trees, Regression Trees (see Breiman et. al. 1984) and Random Forests (see Breiman 2001 & Scornet et.al. 2015).
Classification and Regression Trees consists of three algorithms: tree-growing, tree-pruning, and finding the honest tree.
The Random Forests algorithm is an ensemble method that implements tree-growing for many random subsets of the data and the splitting variables set.
Random Forests can be implemented both for classification and for regression applications.

{title:Options}

{dlgtab:Model}

{phang}
{opt rforests} specifies that Random Forests is to be performed. 
If {opt rforests} is not specified, Regression Trees (default) of Classification Trees (see {help crtrees##classification:classification} below) is performed.
Option {opt rforests} makes options {opt vcv}, {opt lssize}, and {opt rule} to be ignored.

{phang}
{marker classification}
{opt classification} specifies that trees must be grown using Classification options. 
The output variable {it:depvar} contains {it:J} classes or types. 
If {opt rforests} is not specified, then Classification Trees is performed.
If {opt classification} is not specified, trees are grown using Regression options.

{phang}
{opt generate(newvar)} new variable name for the predictions of the model. 
If {it:newvar} already exists, the command stops with an error message.
When {opt classification} is chosen, this option stores the class with the minimum misclassification cost (by default the highest estimated probability) in new variable {it:newvar}.
When Regression Trees is performed, this option stores the estimated expected value of {it:depvar} in new variable {it:newvar}.
This option is required if option {opt st_code} or option {opt rforests} is specified.
In the latter case two variables are created. 
The first variable, i.e. {it:newvar}, is the average expected value of {it:depvar} in Regression and the most popular class prediction of {it:depvar} in Classification.
The second variable ({it:newvar_sd} in Regression and {it:newvar_pm} in Classification) contains the standard error of the prediction in Regression and the misclassification cost (by default, this is the probability of misclassification) in Classification.

{phang}
{opt bootstraps}{cmd:(}{it:#}{cmd:)} sets the number of bootstrapped samples.
{it:#} is an integer number between 1 and 2,147,483,647.
This option is only available in Regression Trees and Random Forests.
Under Regression Trees, this is the number of random trees to estimate the standard error of the tree impurity measure of the largest tree.
Tree-growing is performed using the original sample. 
Bootstrapped samples are then used to obtain the estimate for the standard error of the impurity of the largest tree in the sequence (see  {help crtrees##impurity:impurity} below). 
If {opt bootstraps} is performed, no measures of accuracy for within-node estimates are reported.
{opt bootstraps} overrules options {opt lssize} and {opt vcv}.
Under Random Forests (both for Classification and for Regression), this is the number of random trees to be grown, and it is set to 1,000 by default.

{phang}
{opt seed}{cmd:(}{it:#}{cmd:)} sets the random-number seed (see {help seed}).
Partition, cross validation, and bootstrapping inherently introduce volatility in the results of {cmd:crtrees}. 
Therefore, setting the seed is necessary when results are to be replicated.

{phang}
{opt stop}{cmd:(}{it:#}{cmd:)} sets additional stopping criterion in the tree-growing algorithm. 
{it:#} is any positive integer greater than the number of regressors in Regression or 1 in Classification.
By default, the algorithm stops when there is no terminal node that can be split into two. 
This occurs in two situations.
First, when all splitting variables only have one single value in each terminal node.
Second, in Regression if there are not enough observations within each terminal node to carry out linear regression. 
To stop tree-growing before such extreme cases occur, option {opt stop} does not split any node with less than {it:#} observations.

{dlgtab:Regression}

{phang}
{opt regressors}{cmd:(}{it:varlist}{cmd:)} {varlist} of regression controls.
Splitting variables can simultaneously be included as regressors.
When there are no regressors, option {opt noconstant} is ignored as the model must include the constant.
All regressors must be numeric. 

{phang}
{opt noconstat} suppresses the constant term.

{phang}
{opt level}{cmd:(}{it:#}{cmd:)} sets confidence level as a percentage when the sample is partitioned into a test and a learning sample. 
The default is to show standard regression displays for each terminal node with 95 as default confidence level.
Standard errors are computed using within-node homoskedastic standard errors based on the test sample root mean square error.
Option {opt level} is ignored if options {opt rforests}, {opt bootstraps}, {opt vcv}, and/or {opt classification} are used.


{dlgtab:Classification}

{phang}
{marker impurity}
{opt impurity}{cmd:(}{it:string}{cmd:)} name of impurity measure ("gini" or "entropy"). 
The measure chosen is used to grow the tree.
Under Classification Trees, pruning the largest tree is implemented using a cost-complexity algorithm. 
This algorithm uses as the tree impurity measure the overall tree misclassification cost. 
The latter is again used to find the honest tree in the sequence of trees obtained after pruning the largest tree. 
When option {opt impurity} is not explicitly stated, the Gini measure is used. 
In Regression, the mean square error is used as impurity measure.

{phang}
{opt priors}{cmd:(}{it:string}{cmd:)} string containing the name of an existing stata matrix with prior class probabilities.
The matrix must be a column vector with as many elements as the number of classes in the learning sample. 
All elements in the column vector must be probabilities, i.e. they must be positive and sum up to unity.
Element j-th in the vector represents the prior probability of the j-th class in the population.
(Classes are sorted from the lowest to the highest class code. Hence the first class is the class with the lowest class code.) 
When option {opt prior} is not specified, learning-sample relative frequencies are used.

{phang}
{opt costs}{cmd:(}{it:string}{cmd:)} string containing the name of existing stata matrix with costs of classification.
The matrix must be square with zeros in the diagonal and positive values off the diagonal. 
Consider element {i,j}. This element represents the cost of classifying a case as of type i-th class when the true class type is the j-th.
(Classes are sorted from the lowest to the highest class code. Hence the first class is the class with the lowest class code.) 
When option {opt costs} is not specified, all elements off the diagonal are ones.

{phang}
{opt detail} displays additional statistics for terminal nodes.
The default behavior is to show:
{it:i}) the class assignament rule; 
{it:ii}) the misclassification cost (i.e., by default the estimated probability of misclassification);
and {it:iii}) the range of values for the splitting variables that define the population in the node.
When {opt detail} is used, estimated probabilities for each class are also reported.
Option {opt detail} is ignored if {opt classification} is not used or if option {opt rforests} is used.

{dlgtab:CART}

{phang}
{opt lssize}{cmd:(}{it:#}{cmd:)} sets the size of the learning sample relative to the overall sample; then {it:#} must be a number within the unit interval (0,1).
Default is lssize(0.5).
Under CART, {cmd:crtrees} by default partitions the sample into a learning and a test sample. 
The first two algorithms (tree-growing and tree-pruning) are performed using the learning sample. 
After pruning the tree, a sequence of nested trees is obtained. The test sample is then employed to choose one tree within the sequence. 
Partitioning into a learning and a test sample is arguably the best option to avoid over-fitting and obtaining consistent estimates of within-node estimates when the sample size is large.
The learning sample must be larger than 1 in Classification Trees and larger than the number of controls (including the constant if there is one) in Regression Trees. 
Measures of accuracy for within-node estimates are reported using both learning sample and test sample standard errors.
Option {opt lssize} is ignored if options {opt vcv}, {opt rforests} or {opt bootstraps} are used.

{phang}
{opt tsample(newvar)} new variable name for 0/1 identifier of test sample.
{it:newvar} cannot exist in the current dataset.
This option is only available when the sample is partitioned into a learning sample and a test sample.
After {cmd:crtrees}, function e(sample), that identifies the observations used in the command, is stored.
When the dataset is partitioned, e(sample) identifies observations that are either in the learning sample or in the test sample.
Option {opt tsample} allows to identify the observations from the test sample.

{phang}
{opt vcv}{cmd:(}{it:#}{cmd:)} sets the V-fold cross validation parameter.
{it:#} is a positive integer below 100.
When option {opt vcv} is used, the first two algorithms (tree-growing and tree-pruning) are performed using the original sample. 
Then the sample is randomly partitioned V times into a learning and a test sample, the latter being of 100/V percent relative size.
Partitioning is constrained so that each observation appears in only one of the V test samples.
For each of these subsamples, a sequence of trees are obtained. Averaging over all these sequences, impurity measures (and their standard errors) for the sequence of the original tree are computed (see {help crtrees##impurity:impurity} below).
If V-fold cross validation is performed, no measures of accuracy for within-node estimates are reported.
Option {opt vcv} overrules {opt lssize} and it is ignored if options {opt rforests} or {opt bootstraps} are used.

{phang}
{opt rule}{cmd:(}{it:#}{cmd:)} sets the Standard Error (SE) rule for selecting a single tree from the sequence of trees obtained after pruning, i.e. for selecting the honest tree.
{it:#} is a positive real number.
Default is rule(0).
When the sample is partitioned (either into a learning and a test sample or using V-fold cross validation), estimates for the impurity measure for each tree in the sequence and its standard error are obtained. 
Then, a tree in the sequence is chosen such that it minimizes the test-sample estimate of the tree overall impurity measure. Denote this tree by T_MIN. 
Option {opt rule} identifies the least complex tree in the sequence with impurity measure lower than that of T_MIN plus  {it:#} times the estimate of tree T_MIN's Standard Error. 
When the sample is bootstrapped, a bootstrap estimate of the standard error of the impurity measure of the largest tree in the sequence is obtained.
Option {opt rule} then identifies the least complex tree in the sequence with impurity measure lower than that of the largest tree plus {it:#} times its standard error bootstrap estimate. 
Option {opt rule} is ignored if option {opt rforests} is used.

{phang}
{opt tree} displays a simple text format representation of the tree. 
Each line represents a non-terminal node of the tree, gives the splitting rule, and identifies the children nodes. 
The growing-the-tree algorithm creates trees with the following numbering convention. 
The root node is node 1. If node 1 is split, the node child to the left is node 2, and the node child to the right is node 3.
Consider splitting now node {it:t} and assume that the tree already has {it:tn} nodes, with {it:tn}>={it:t}.
Then the node child to the left of node {it:t} is node {it:tn}+1 and the node child to the right of node {it:t} is node {it:tn}+2.

{phang}
{opt st_code} displays Stata code to generate predictions.
This option can only be used it option {opt generate} is used and it is ignored if option {opt rforests} is used.

{dlgtab:Random Forests}

{phang}
{opt rsplitting}{cmd:(}{it:#}{cmd:)} sets the relative size of the directions for splitting. 
Hence, it must be a real number between 0 and 1.
Default is rsplitting(0.33).
For example, if there are 10 splitting variables and we set rsplitting(0.5) then in each bootstrapped sample we wil grow a tree with only five of the original splitting variables. 
Option {opt rsplitting} is ignored if option {opt rforests} is not used.

{phang}
{opt rsampling}{cmd:(}{it:#}{cmd:)} sets the relative sampling size for each tree. 
Hence, it must be a number larger than 0 and equal or smaller than 1.
Default is rsampling(1). 
In this, case, resampling is done with replacement.
Otherwise, resampling is done without replacement.
Option {opt rsampling} is ignored if option {opt rforests} is not used.

{phang}
{opt oob} computes out-of-bag misclassification costs.
These are obtained using observations not included in their bootstrap sample.
When {opt oob} is not used, misclassification costs are computed using all observations. 
This option is only available under Classification.

{phang}
{opt ij} computes standard errors using the {it:Infinitessimal Jacknife}, also known as the {it:non-parametric delta method}.
Default is {it:Jacknife-after-Bootstrap} standard errors (Sexton & Laake, 2009; Efron, 2014).
This option is only available under Regression.

{phang}
{opt savetrees}{cmd:(}{it:string}{cmd:)} string containing the name of a file where to save mata matrices of bootstrapped trees and coefficients and criteria in nodes for each tree.
The file must not exist and the directory must be writable.
When option {opt savetrees} is not specified, {cmd:crtrees} will save the mata matrices in the current working directory in file {it: matatrees} if such a file does not already exists.
Three mata matrices are saved: {it:trees}, {it:criteria}, and {it:coefficients}. 
Matrix {it:trees} stacks vertically all bootstrapped trees (see {help crtrees##tree:e(tree)}).
Matrix {it:criteria} stacks vertically all node criteria (see {help crtrees##criteria:e(criteria)}).
Matrix {it:coefficients} stacks vertically all node coefficients (regression beta estimates in Regression and class probability estimates in Classification) from the bootstrapped trees.

{title:Remarks}

{p 4 4 2}

{pstd}
{cmd: crtrees} is an e-class ado. By default (under CART), it performs sequentially three algorithms: tree-growing, tree-pruning, and obtaining the honest tree. 
Under option {opt rforests} it performs tree-growing for random samples of data and subsets of splitting variables.

{pstd}
Tree-growing is a splitting algorithm that at each step searches for the split of a terminal node such that the overall impurity of the tree decreases the most. 
The algorithm stops when for each terminal node at least one of the following conditions holds: 
{it:i}) all observations in the node have the same value for all splitting variables; 
and {it:ii}) the number of observations is smaller than the minimum number, which is defined as the maximum number between the number of coefficients plus one or the number given in option {opt stop}.
Let T_MAX be the tree obtained after growing the tree.
Under option {opt rforests}, each tree T_MAX obtained when resampling is used to obtain average (Regression) and most popular (Classification) predictions of {it:depvar}.

{pstd}
Tree-pruning is an algorithm that obtains the sequence of subtrees of T_MAX that minimizes a cost-complexity function.
The cost-complexity function is defined as a tree impurity measure plus the complexity of the tree (i.e. the number of terminal nodes) multiplied by a weight {it:alpha}.
The larger {it:alpha} the more weight complexity is given in the algorithm and the simpler the optimal tree wil tend to be.
It can be shown that for each value {it:alpha} there is one tree that minimizes the cost complexity function and has the lowest complexity.
Let T({it:alpha}) denote the optimal subtree for a given {it:alpha}. 
Then the finite set of all trees T({it:alpha}) is a sequence of subtrees obtained by sequentially pruning T_MAX via a weakest-link algorithm.
Trees in the sequence do not neccessarily coincide with the sequence of trees grown when growing the tree.

{pstd}
Obtaining the honest tree means choosing one tree from the sequence after pruning. 
Obtaining the honest tree is a way to avoid the problem of overfitting.
It consists of two steps. 
In partition or V-fold cross validation, tree impurity measures and their standard errors are computed by means of alternative  test samples.
In the second step, the simplest tree in the sequence whose impurity estimate is not larger than a function of the impurity and standard error of the tree with lowest impurity is chosen.
Specifically, let R(T) be the tree impurity measure.
Then, optimal tree {bf:T} is the least complex tree in the sequence  T({it:alpha}) such that
R({bf:T}) <= R(T_MIN) + {it:rule x} SE(R(T_MIN)) 
where T_MIN is the tree in the sequence that minimizes R(T) in alternative samples.
In bootstrap, boostrapped samples are used to obtain a boostrapped standard error of the impurity measure of the largest tree T_MAX, SE(R_b(T_MAX)).
In the second stage, the least complex tree in the sequence with a tree impurity measure not larger than that of T_MAX plus {it:rule} times the standard error estimate is chosen.
Hence, when using the bootstrap optimal tree {bf:T} is the least complex tree in the sequence  T({it:alpha}) such that  
R({bf:T}) <= R(T_MAX) + {it:rule x} SE(R(T_MAX)).

{title:Examples}

{p 4 8 2}
{stata "sysuse auto, clear"}

{p 4 8 2} 
Regression Trees with partition, learning sample size 0.5, and 0 SE rule.
The model predicts within-node constant expectations:{p_end}

{p 8 16 2}{cmd:. crtrees price trunk weight length foreign gear_ratio, seed(12345)}{p_end}

{p 4 4 2} 
In next example, the model is a linear function of {it:weight} within each terminal node.
A node will not be further split if it contains less than 5 observations in learning sample, which is 60% of the original sample.
Individual model predictions are stored in new variable {it:y_hat}:{p_end}

{p 8 16 2}{cmd:. crtrees price trunk weight length foreign gear_ratio,reg(weight) stop(5) lssize(0.6) generate(y_hat) seed(12345)}{p_end}

{p 4 4 2}
Option {opt detail} results in standard regression displays for each terminal node:{p_end}

{p 8 16 2}{cmd:. crtrees price trunk weight length foreign gear_ratio, seed(12345) stop(5) reg(weight) lssize(0.6) detail}{p_end}

{p 4 4 2}
Classification Trees with V-fold cross validation so that in each partition 100/20=5 percent of the sample is allocated to the test sample:{p_end}

{p 8 16 2}{cmd:. crtrees foreign price mpg, class stop(5) vcv(20) seed(12345) detail}{p_end}

{p 4 4 2}
Option {opt tree} additionally displays a text representation of the optimal tree {bf:T}:{p_end}

{p 8 16 2}{cmd:. crtrees foreign price mpg, class stop(5) vcv(15) seed(12345) detail tree}{p_end}

{p 4 4 2} Using the SE {it:rule} usually simplifies the optimal tree:{p_end}
{p 8 16 2}{cmd:. crtrees foreign price mpg, class stop(5) vcv(15) rule(1) seed(12345) detail} {p_end} 

{p 4 4 2} Random Forests requires options {opt rforests}, {opt generate}, and {opt bootstraps}:{p_end}
{p 8 16 2}{cmd:. crtrees price trunk weight length foreign gear_ratio, rforests generate(p_hat) bootstraps(2500)} {p_end} 

{p 4 4 2} Subsampling and random selection of splitting variables is controlled with options {opt rsampling} and {opt rsplitting}:{p_end}
{p 8 16 2}{cmd:. crtrees price trunk weight length foreign gear_ratio, rforests generate(p_hat) bootstraps(2500) rsampling{0.8} rsplitting(0.6)} {p_end} 

{p 4 4 2} Out-of-bag misclassification costs are available with option {opt oob}:{p_end}
{p 8 16 2}{cmd:. crtrees foreign price mpg weight length, class stop(5) seed(12345) rforests generate(p_hat) rsplitting(.6) bootstraps(500) oob} {p_end} 



{title:Saved results}

{pstd}
{cmd:crtrees} for Regression Trees saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars}{p_end}

{synopt:{cmd:e(T)}}optimal tree complexity (i.e. number of terminal nodes){p_end}
{synopt:{cmd:e(N_ls)}}size of learning sample (only with partition){p_end}
{synopt:{cmd:e(N_ts)}}size of test sample (only with partition){p_end}
{synopt:{cmd:e(N)}}sample size (with V-fold cross validation and boostrap){p_end}
{synopt:{cmd:e(r2_ls)}}optimal tree R-squared using learning sample (only with partition){p_end}
{synopt:{cmd:e(r2_ts)}}optimal tree R-squared using test sample (only with partition){p_end}
{synopt:{cmd:e(r2)}}optimal tree R-squared with original sample (with V-fold cross validation and boostrap){p_end}
{synopt:{cmd:e(r2_cv)}}V-fold cross variation estimate of optimal tree R-squared{p_end}
{synopt:{cmd:e(lssize)}}Partition into Learning and Test Sample parameter (only with partition){p_end}
{synopt:{cmd:e(vcv)}}V-fold cross variation parameter (only with V-fold cross validation){p_end}
{synopt:{cmd:e(B)}}number of boostrap replications (only with bootstrap)){p_end}

{p2col 5 20 24 2: macros}{p_end}

{synopt:{cmd:e(cmd)}} string "crtrees"{p_end}
{synopt:{cmd:e(predict)}} string "crtrees_p"{p_end}
{synopt:{cmd:e(algorithm)}} string containing brief description of algorithm.
With partition into a learning and a test sample, if contains "CART: Regression with Learning and Test Sample".
With V-fold Cross Validation, if contains "CART: Regression with V-fold Cross Validation".
With Boostrap, if contains "CART: Regression with Bootstrap". {p_end}
{synopt:{cmd:e(depvar)}} string with {it:depvar} name{p_end}
{synopt:{cmd:e(splvar)}} string containing splitting variables (if there are any){p_end}
{synopt:{cmd:e(regvar)}} string containing regressors (only when option {opt regvar} used){p_end}
{synopt:{cmd:e(noconstant)}} (only when option {opt noconstant} used){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices}{p_end}

{synopt:{cmd:e(T_j)}} By rows, nodes of T_MAX.
Elements in the matrix identify left-child nodes.
For example, element (1,1) is the left-child node of node 1 (the root node) in T_MAX.
By columns, sequence of trees after pruning T_MAX. For example element (1,2) is the left child node of the root node in T_1.
Terminal nodes are identified by code 0. Pruned nodes are identified by code -1.{p_end}

{synopt:{cmd:e(R_T_j)}} By rows, sequence of trees.
By columns, under partition we have |T|,R_ls,R_ts, and RE(R_ts).
Under V-fold cross validation we have |T|, R, R^cv, and SE(R^cv). With boostrap, we have |T|, R, and SE_b(R(T_MAX)).{p_end}

{marker tree}
{synopt:{cmd:e(tree)}} By rows, nodes of the optimal tree. 
The first column identifies the node. 
The second column, the left child or 0 if the node is terminal.
The third column, the splitting variable used to do the splitting or 0 if the node is terminal.
For example, "3" in the third column means the third splitting variable included in e(splvar) is used to carry out the splitting at that node.
The fourth column represents the splitting criterion or 0 if node is terminal.
For example, suppose that in row 3 we have 6,12,3,26.
This means that all observations belonging to node 6 whose value for the third splitting variable is lower or equal than 26 must be further allocated to node 12.{p_end}

{marker criteria}
{synopt:{cmd:e(criteria)}} By rows, nodes of the optimal tree. 
By columns, min and max values observed in the node for each splitting variable.{p_end}

{synopt:{cmd:e(coefficients)}} By rows, nodes of the optimal tree. 
The first column is the node code.
The second column is the node's conditional average of {it:depvar}.
The next four columns are the learning and test sample estimates of the regression standard error, the learning sample number of observations and the R-squared.
The last columns are the regression beta estimates.{p_end}

{synopt:{cmd:e(Vs)}} By rows, nodes of the optimal tree. 
Each row contains the transpose of vech of the within-node learning-sample estimated variance-covariance matriz for the regression coefficients.
This is only available under partition into a learning and a test sample.
{p_end}

{p2col 5 20 24 2: functions}{p_end}

{synopt:{cmd:e(sample)}}variable identifier of using sample{p_end}


{pstd}
{cmd:crtrees} for Classification Trees saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars}{p_end}

{synopt:{cmd:e(T)}}optimal tree complexity (i.e. number of terminal nodes){p_end}
{synopt:{cmd:e(N_ls)}}size of learning sample (only with partition){p_end}
{synopt:{cmd:e(N_ts)}}size of test sample (only with partition){p_end}
{synopt:{cmd:e(N)}}sample size (only with V-fold cross validation){p_end}
{synopt:{cmd:e(R_T_ls)}}optimal tree impurity measure R with learning sample (only with partition){p_end}
{synopt:{cmd:e(R_T_ts)}}optimal tree impurity measure R with test sample (only with partition){p_end}
{synopt:{cmd:e(SE_R_T_ts)}}standard error for R with test sample (only with partition){p_end}
{synopt:{cmd:e(R_T)}}optimal tree impurity measure R with original sample (with V-fold cross validation){p_end}
{synopt:{cmd:e(R_T_cv)}}V-fold cross validation estimate of optimal tree impurity measure{p_end}
{synopt:{cmd:e(SE_R_cv)}}V-fold cross validation standard error of the optimal tree impurity measure{p_end}
{synopt:{cmd:e(lssize)}}Partition into Learning and Test Sample parameter (only with partition){p_end}
{synopt:{cmd:e(vcv)}}V-fold cross variation parameter (only with V-fold cross validation){p_end}

{p2col 5 20 24 2: macros}{p_end}

{synopt:{cmd:e(cmd)}} string "crtrees"{p_end}
{synopt:{cmd:e(predict)}} string "crtrees_p"{p_end}
{synopt:{cmd:e(algorithm)}} string containing brief description of algorithm.
With partition into a learning and a test sample, if contains "CART: Classification with Learning and Test Sample".
With V-fold Cross Validation, if contains "CART: Classification with V-fold Cross Validation".
With Boostrap, if contains "CART: Classification with Bootstrap". {p_end}
{synopt:{cmd:e(depvar)}} string with {it:depvar} name{p_end}
{synopt:{cmd:e(splvar)}} string containing splitting variables (if there are any){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices}{p_end}

{synopt:{cmd:e(classes)}} Row vector with the {it:J} class codes.{p_end}

{synopt:{cmd:e(T_j)}} As in Regression Trees{p_end}

{synopt:{cmd:e(R_T_j)}} By rows, sequence of trees.
By columns, under partition we have |T|,R_ls,R_ts, and RE(R_ts).
Under V-fold cross validation we have |T|, R, R^cv, and SE(R^cv){p_end}

{synopt:{cmd:e(tree)}} As in Regression Trees{p_end}

{synopt:{cmd:e(criteria)}} As in Regression Trees{p_end}

{synopt:{cmd:e(coefficients)}} By rows, the terminal nodes of the optimal tree.
 By columns, node's id code, node's class assignment, node's learning sample cost of misclassification, node's number of observations, and (in the last {it:J} columns) node's class probability estimates{p_end}

{p2col 5 20 24 2: functions}{p_end}

{synopt:{cmd:e(sample)}}variable identifier of using sample{p_end}


{pstd}
{cmd:crtrees} for Random Forests (Regression) saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars}{p_end}

{synopt:{cmd:e(N)}} sample size{p_end}
{synopt:{cmd:e(r2)}}R-squared defined as ESS/RSS{p_end}
{synopt:{cmd:e(B)}}number of boostrap replications{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macros}{p_end}

{synopt:{cmd:e(cmd)}} string "crtrees"{p_end}
{synopt:{cmd:e(predict)}} string "crtrees_p"{p_end}
{synopt:{cmd:e(matatrees)}} filename of file containing {it:trees}, {it:criteria}, and {it:coefficients}{p_end}
{synopt:{cmd:e(algorithm)}} string "Random Forest: Regression"{p_end}
{synopt:{cmd:e(depvar)}} string with {it:depvar} name{p_end}
{synopt:{cmd:e(splvar)}} string containing splitting variables (if there are any){p_end}
{synopt:{cmd:e(regvar)}} string containing regressors (only when option {opt regvar} used){p_end}
{synopt:{cmd:e(noconstant)}} (only when option {opt noconstant} used){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: functions}{p_end}

{synopt:{cmd:e(sample)}}variable identifier of using sample{p_end}


{pstd}
{cmd:crtrees} for Random Forests (Classification) saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars}{p_end}

{synopt:{cmd:e(Cost)}}average misclassification cost{p_end}
{synopt:{cmd:e(N)}} sample size{p_end}
{synopt:{cmd:e(B)}}number of boostrap replications{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macros}{p_end}

{synopt:{cmd:e(cmd)}} string "crtrees"{p_end}
{synopt:{cmd:e(predict)}} string "crtrees_p"{p_end}
{synopt:{cmd:e(matatrees)}} filename of file containing {it:trees}, {it:criteria}, and {it:coefficients}{p_end}
{synopt:{cmd:e(algorithm)}} string "Random Forest: Classification"{p_end}
{synopt:{cmd:e(depvar)}} string with {it:depvar} name{p_end}
{synopt:{cmd:e(splvar)}} string containing splitting variables (if there are any){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices}{p_end}

{synopt:{cmd:e(classes)}} Row vector with the {it:J} class codes.{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: functions}{p_end}

{synopt:{cmd:e(sample)}}variable identifier of using sample{p_end}




{title:Author}

{pstd}
{browse "http://www.eco.uc3m.es/%7Ericmora/":Ricardo Mora} {break}
{browse "mailto:ricmora@eco.uc3m.es":email:ricmora@eco.uc3m.es} {break}
Departament of Economics, Universidad Carlos III Madrid{break}
Madrid, Spain{break}


{title:References}

{phang}
Breiman, Leo ; Friedman, Jerome H ; Olshen, Richard A ; Stone, Charles J (1984).
{it: Classification and Regression Trees}.  
Monterey, CA : Wadsworth & Brooks/Cole Advanced Books & Software.

{phang}
Breiman, Leo (2001).
Random Forests, {it: Machine Learning}, Vol. 45, 5-32.

{phang}
Sexton, Joseph; Laake, Peter (2009).
Standard errors for bagged and random forest estimators, {it:Computational Statistics and Data Analysis}, Vol. 53, 801-811.

{phang}
Efron, Bradley (2014)
Estimation and accuracy after model selection, {it:Journal of the American Statistical Association}, 109:507, 991-1007.

{phang}
Scornet, Erwan; Biau, Gérard; Vert, Jean-Philippe (2015).
Consistency of random forests, {it:The Annals of Statistics}, Vol. 43, No. 4, 1710-1741.

{phang}Update: March - 2019{p_end}



