{smcl}
{* *! version 1.0.0 07Jan2020}{...}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{hi:cta} {hline 2}} Classification Tree Analysis  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:cta} {cmd:}{it:classvar} {it:attributes} {ifin} 
{cmd:,} {opt pathc:ta(filepath)} 
[ {opt vers:ion(string)}
{opt sto:re(filepath)} 
{opt name(string)}
{opt iter(#)}
{opt cut:off(#)}
{opt stop(#)}
{opt cat(varlist)}
{opt usef:isher}
{opt loo(string)}
{opt wt(varname)}
{opt miss:ing(#)} 
{opt dir:ection(string)}
{opt nopriors}
{opt prune(#)}
{opt enum:erate}
{opt force:node(varname #)}
{opt skip:node(#)}
{opt max:level(#)}
{opt mind:enom(#)} ]

{pstd}
{it:classvar} must be binary; {it:attributes} may be binary, ordinal, nomimal, or continuous.


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt pathc:ta}{cmd:(}{it:filepath}{cmd:)}}specify the file path of the cta64.exe (or cta32.exe) file; {cmd: pathcta() is required}  {p_end}
{synopt:{opt vers:ion}{cmd:(}{it:string}{cmd:)}}specify the CTA version for the user's computer (options are cta32 and cta64)); default is {opt cta64}  {p_end}
{synopt:{opt sto:re}{cmd:(}{it:filepath}{cmd:)}}specify the file path to store all files and output generated by {cmd:cta}; default is the current working directory  {p_end}
{synopt:{opt name}{cmd:(}{it:string}{cmd:)}}provide name for all files produced; default is name of the {it:classvar} {p_end}
{synopt:{opt iter}{cmd:(}{it:#}{cmd:)}}perform # random permutations; default is {opt 1000}  {p_end}
{synopt:{opt cut:off}{cmd:(}{it:#}{cmd:)}}cutoff level for permutations; default is {opt 0.05}  {p_end}
{synopt:{opt stop}{cmd:(}{it:#}{cmd:)}}stopping rule for permutations; default is {opt 99.9}  {p_end}
{synopt:{opt cat}{cmd:(}{it:varlist}{cmd:)}}indicate which {it:attributes} should be treated as categorical variables {p_end}
{synopt:{opt usef:isher}}specify that all probability calculations for categorical variables be determined by Fisher’s exact test rather than permutation test {p_end}
{synopt:{opt loo}{cmd:(}{it:string}{cmd:)}}specify that leave-one-out (jackknife) analysis be performed; {cmd:loo} can be specified with no option or {cmd:loo(stable)} {p_end}
{synopt:{opt wt}{cmd:(}{it:varname}{cmd:)}}weight variable for use in weighted analyses {p_end}
{synopt:{opt miss:ing}{cmd:(}{it:#}{cmd:)}}integer value (positive or negative) indicating missing values {p_end}
{synopt:{opt dir:ection}{cmd:(}{it:string}{cmd:)}}compute one-sided {it:P}-values. "<" or "lt" indicates that the {it:classvar} values are ordered in the “less-than” direction. ">" or "gt" 
indicates the {it:classvar} values are ordered in the “greater-than” direction. The value list must contain both values of the {it:classvar} {p_end}
{synopt:{opt nopriors}}turn priors off; default is on {p_end}
{synopt:{opt prune}{cmd:(}{it:#}{cmd:)}}indicate the {it:P}-value with which to optimally prune the classification tree {p_end}
{synopt:{opt enum:erate}}specify that all combinations of attributes in the top three nodes will be evaluated. {opt prune()} must also be specified {p_end}
{synopt:{opt force:node}{cmd:(}{it:varname #}{cmd:)}}force CTA to insert the {it:attribute} at {it:node #} in the solution tree {p_end}
{synopt:{opt skip:node}{cmd:(}{it:#}{cmd:)}}specify that the {it:node #} will be empty of any attribute in the solution tree {p_end}
{synopt:{opt max:level}{cmd:(}{it:#}{cmd:)}}deepest level allowed in the solution tree{p_end}
{synopt:{opt mind:enom}{cmd:(}{it:#}{cmd:)}}specify the minimum denominator value for an attribute to be allowed in the solution tree{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:cta} is a wrapper program for the Classification Tree Analysis (CTA) software (Yarnold & Soltysik 2016). Therefore, 
CTA must be installed in order for the {cmd:cta} Stata package to work. CTA software is available at {browse "https://odajournal.com/resources/"}. 


{title:Remarks}

{pstd} 
In its simplest form, CTA is an optimal discriminant analysis {helpb oda:(ODA)} model (Yarnold & Soltysik 1991, 2005, 2016). ODA is a machine-learning algorithm that finds the 
cutpoint(s) on a continuous (ordered) attribute (variable) that maximally discriminates between two or more classes (e.g. treatment groups). The optimal cutpoint 
is determined by iterating through each value on the attribute and calculating the effect strength for sensitivity [ESS], which is the mean sensitivity 
amongst the classes, standardized to a 0 - 100% scale where 0 represents the discriminatory accuracy expected by chance, and 100% represents perfect 
discrimination. By definition, the maximally accurate predictive model uses the “optimal” cutpoint achieving the highest ESS. This model is further 
subjected to a non-parametric permutation test to assess the statistical validity of that cutpoint. Finally, generalizability of the model is assessed 
using leave-one-out cross-validation.

{pstd}
CTA models use one or more attributes to classify a sample of observations into two or more subgroups that are represented as model endpoints (these are called 
“terminal nodes” in alternative decision-tree methods). Subgroups are known as “sample strata” because the CTA model stratifies the sample into subgroups of 
observations that -- with respect to model attributes -- are homogeneous within and heterogeneous between strata (Yarnold & Soltysik 2016). The pruned CTA 
algorithm involves chained ODA models in which the initial (“root”) node represents the attribute achieving the highest ESS value for the entire sample, and 
additional nodes yielding greatest ESS are iteratively added at every step on all model branches while retaining statistical significance (defined by the {opt prune()} option). 
In contrast, the enumerated-optimal CTA algorithm explicitly evaluates all possible combinations of the first three nodes, which dominate the solution. 

{pstd}
See Soltysik & Yarnold (2010) for an excellent introduction to CTA models, and Yarnold & Soltysik (2016) for a comprehensive discussion. Additional 
references are provided below that detail the use of CTA for causal inferential problems.  


{title:Options}

{p 4 8 2}
{cmd:pathcta(}{it:filepath}{cmd:)} file path where the cta64.exe (or cta32.exe) is located on the user's computer (e.g. "C:\CTA\"). {cmd: pathcta() is required}.

{p 4 8 2}
{cmd:version(}{it:string}{cmd:)} specifies the CTA version for the user's computer (options are cta32 and cta64)). Default is {opt cta64}. 

{p 4 8 2}
{cmd:store(}{it:filepath}{cmd:)} file path to store all files and output generated by {cmd:cta} (e.g. "C:\CTA\output\"). Default is the current working directory.

{p 4 8 2}
{cmd:name(}{it:string}{cmd:)} provides a name for all files produced (extensions such as .csv, .out, .txt  will be added accordingly). Default is name of the {it:classvar}. 

{p 4 8 2}
{cmd:iter(}{it:#}{cmd:)} specifies the number of random permutations to perform. Default is {opt 1000} iterations.

{p 4 8 2}
{cmd:cutoff(}{it:#}{cmd:)} specifies the {it:P}-value cutoff level for stopping the permutation test if it can be reached before the iterations naturally end (and before 
the {opt stop} value is reached). Default is {opt 0.05}. 

{p 4 8 2}
{cmd:stop(}{it:#}{cmd:)} specifies the confidence level for the stopping the permuation test if it can be reached before the iterations naturally end (and before 
the {opt cutoff} value is reached). Default is {opt 99.9}.

{p 4 8 2}
{cmd:cat(}{it:varlist}{cmd:)} indicates which {it:attributes} should be treated as categorical variables. The default is to treat the {it:attributes} as continuous (ordered).

{p 4 8 2}
{cmd:usefisher} specifies that all probability calculations for categorical variables be determined by Fisher’s exact test rather than by permutation tests.
 
{p 4 8 2}
{cmd:loo(}{it:string}{cmd:)} specifies that leave-one-out analysis be performed for every attribute in the tree. {opt loo} can be specified alone, while {opt loo(stable)} 
allows only attributes with LOO ESS equal to the ESS for that attribute. In CTA, LOO is not available for weighted categorical problems (i.e. {cmd:loo} cannot be specified 
together with both {cmd:wt()} and {cmd:cat()}).

{p 4 8 2}
{cmd:wt(}{it:varname}{cmd:)} indicates the weight variable for use with weighted analyses. {cmd:wt()} cannot be the same variable specified as either the {it:classvar} 
or any of the {it:attributes}; CTA treats {cmd: weight()} as an importance weight (see {helpb weight}).

{p 4 8 2}
{cmd:missing(}{it:#}{cmd:)} is an integer value (positive or negative) indicating missing values. It is common in surveys to code missing values as 99, 999, 9999, -99, etc. 

{p 4 8 2}
{cmd:direction(}{it:string}{cmd:)} compute one-sided {it:P}-values. "<" or "lt" indicates that the {it:classvar} values are ordered in the “less-than” direction. ">" or "gt" 
indicates the {it:classvar} values are ordered in the “greater-than” direction. The value list must both values of the {it:classvar}, and each character must be separated 
with a space (e.g. "< 0 1" or "lt 0 1" or "> 1 0" or "gt 1 0"). By default, two-sided {it:P}-values are computed (i.e no directional hypothesis).

{p 4 8 2}
{cmd:nopriors} by default, CTA weights analyses by the reciprocal of sample class membership, in order to adjust for differences in class category sizes. {cmd:nopriors} is 
therefore recommended for balanced samples so that no unnecessary weighting will be employed.

{p 4 8 2}
{cmd:prune(}{it:#}{cmd:)} indicates the {it:P}-value with which to optimally prune the classification tree.
 
{p 4 8 2}
{cmd:enumerate} specifies that all combinations of attributes in the top three nodes will be evaluated. {opt prune()} must also be specified when {opt enumerate} is specified. 

{p 4 8 2}
{cmd:forcenode(}{it:varname #}{cmd:)} forces CTA to insert the {it:attribute} at {it:node #} in the solution tree. For example {opt forcenode(v1 1)} indicates that the variable 
v1 should be forced into the first node in the tree.

{p 4 8 2}
{cmd:skipnode(}{it:#}{cmd:)} specifies that the {it:node #} will be empty of any attribute in the solution tree.

{p 4 8 2}
{cmd:maxlevel(}{it:#}{cmd:)} deepest level allowed in the solution tree.

{p 4 8 2}
{cmd:mindenom(}{it:#}{cmd:)} specifies the minimum denominator value for an attribute to be allowed in the solution tree. To increase the likelihood of the model 
cross-generalizing when applied to a validity sample, model endpoints should represent at least 5% of the total sample. For example if the total sample size is 4000, 
then {opt mindenom(200)} may be a reasonable minimum value. 


{title:Examples}

{hline}
{pstd}
Setup{p_end}
{phang2}{cmd:. webuse cattaneo2, clear}{p_end}

{pstd}We assess whether CTA can distinguish between low and normal birthweights based on several attributes. We use the default 1000 permutations, 
specify that LOO analysis be conducted with the stable option, and stipulate that a pruned tree and enumerated tree also be generated  {p_end}

{phang2}{cmd:. cta lbweight mage fage mmarried msmoke fbaby foreign, pathcta("C:\CTA\") store("C:\CTA\output") cat(mmarried msmoke fbaby foreign) loo(stable) prune(0.05) enumerate} {p_end}

{pstd}Same as above but specify that Fisher's exact test be performed on categorical variables instead of permutation tests  {p_end}

{phang2}{cmd:. cta lbweight mage fage mmarried msmoke fbaby foreign, pathcta("C:\CTA\") store("C:\CTA\output") cat(mmarried msmoke fbaby foreign) loo(stable) prune(0.05) enumerate usefisher} {p_end}

{pstd}Same as above but specify that model endpoints must have a denominator of at least 250 (approximately 5% of the sample)  {p_end}

{phang2}{cmd:. cta lbweight mage fage mmarried msmoke fbaby foreign, pathcta("C:\CTA\") store("C:\CTA\output") cat(mmarried msmoke fbaby foreign) loo(stable) prune(0.05) enumerate usefisher mindenom(250)} {p_end}


{hline}
{p2colreset}{...}


{title:Stored results}

{pstd}
{cmd:cta} stores the following in {cmd:r()}, which can be displayed by typing {cmd: return list} after {cmd:cta} is finished. When {cmd: wt()} is specified, the stored values are weighted:

{synoptset 20 tabbed}{...}
{p2col 5 15 20 2: Scalars}{p_end}
{synopt:{cmd:r(ess_unpruned)}}ESS for the unpruned model{p_end}
{synopt:{cmd:r(ess_pruned)}}ESS for the pruned model (when the {opt pruned()} option is specified){p_end}
{synopt:{cmd:r(ess_enumerate)}}ESS for the enumerated model (when the {opt enumerate} option is specified){p_end}

{p2colreset}{...}


{title:References}

{p 4 8 2}
Soltysik RC, Yarnold PR. Automated CTA software: fundamental concepts and control commands. 
{it:Optimal Data Analysis} 2010;1:144-160.

{p 4 8 2}
Yarnold PR, Soltysik RC. Theoretical distributions of optima for univariate discrimination of random data. 
{it:Decision Sciences} 1991;22:739–752.

{p 4 8 2}
Yarnold PR, Soltysik RC. {it:Optimal Data Analysis: A Guidebook with Software for Windows.} Washington, DC: APA Books, 2005.

{p 4 8 2}
Yarnold PR, Soltysik RC. {it:Maximizing Predictive Accuracy.} Chicago, IL: ODA Books. DOI: 10.13140/RG.2.1.1368.3286, 2016.

{p 4 8 2}
Linden A, Yarnold PR. Using data mining techniques to characterize participation in observational studies. {it:Journal of Evaluation in Clinical Practice} 2016;22:839-847.

{p 4 8 2}
Linden A, Yarnold PR. Using classification tree analysis to generate propensity score weights. {it:Journal of Evaluation in Clinical Practice} 2017;23:703-712.

{p 4 8 2}
Linden A, Yarnold PR. Modeling time-to-event (survival) data using classification tree analysis. {it:Journal of Evaluation in Clinical Practice} 2017;23:1299-1308.

{p 4 8 2}
Linden A, Yarnold PR. Minimizing imbalances on patient characteristics between treatment groups in randomized trials using classification tree analysis. {it:Journal of Evaluation in Clinical Practice} 2017;23:1309-1315.

{p 4 8 2}
Linden A, Yarnold PR. Identifying causal mechanisms in health care interventions using classification tree analysis. {it:Journal of Evaluation in Clinical Practice} 2018;24:353-361.

{p 4 8 2}
Linden A, Yarnold PR. Estimating causal effects for survival (time-to-event) outcomes by combining classification tree analysis and propensity score weighting. {it:Journal of Evaluation in Clinical Practice} 2018;24:380-387.


{marker citation}{title:Citation of {cmd:cta}}

{p 4 8 2}{cmd:cta} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2020). CTA: Stata module for conducting Classification Tree Analysis. Statistical Software Components S458729, Boston College Department of Economics.{p_end}


{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}


{title:Acknowledgments} 

{p 4 4 2}
I wish to thank Paul R. Yarnold for reviewing {cmd:cta} and providing valuable comments.{p_end}
      

{title:Also see}

{p 4 8 2} Online: {helpb oda} (if installed), {helpb looclass} (if installed), {helpb kfoldclass} (if installed) {helpb classtabi} (if installed){p_end}

