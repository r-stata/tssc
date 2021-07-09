{smcl}
{* Last revised Feb 15, 2013}{...}
{hline}
help for {hi:ccmpre} {right:Michael Lacy}
{hline}

{title:PRE Measures for Cultural Consensus Models}

{title:Syntax} 
{p 8 16 2}
{cmd:ccmpre} {varlist}  {ifin}, {cmd:key}({it:name}) {cmd:COMPetence}({it:name}) [{cmd:base}({it:string})]     

{title:Description}

{pstd} {cmd:ccmpre} calculates proportional reduction in error (Goodman and Kruskal 1954) measures
for Cultural Consensus Models (CCM) (Romney et al. 1986). These 0/1 normed measures summarize the extent to which the responses to items
analyzed with a CCM can be predicted better by using the key and the competence scores from the CCM
results than they can be by prediction using various marginal guessing models.  Lacy and Snodgrass (2013) developed and described these measures.  {cmd:ccmpre} is a post-estimation 
routine, as it requires key and competence scores from a preceding CCM analysis, as well as the
response data on which that CCM was estimated.

{title:Arguments and Options}

{pstd} Notation: N = number of subjects, K = number of variables, L = number 
of response categories for each variable. 

{pstd}
{varlist} gives the variables on which the CCM was calculated.  These variables must be coded with consecutive 
integers, starting at 1 up to L.  

{pstd}{bf:key }: A Stata matrix of dimension K X L giving the answer probabilities for each 
of the K questions and L response categories. {bf:key[k,l]} must contain the probability 
for the lth category on the kth question. If the user has key that just gives the right answer,
this matrix should be coded using 1 for the correct answer category, 0 for each of
the others. Indexing of the questions must confirm to the order used in the {varlist} 
given to {cmd:ccmpre}, and indexing of the answers must go from 1, ..., L.

{pstd}{bf:{ul:comp}etence}: A Stata matrix of dimension N X 1 giving the competence score of each
subject in the analysis.  Subjects should be indexed as they would appear in the data file
if subjects not selected by {ifin} had actually been dropped before analysis.

{pstd}{bf:base}: Requests the form of guessing used for the base ("Rule 1")
prediction for the proportional reduction in error measure. Possible options are
U, T, or I, referring respectively to predicting 1) each category with uniform (1/number of categories) 
probability; 2) based on the total marginal distribution of each response category; 
and 3) based on each individual's marginal distribution of response categories


{title:Returned results}

{pstd}Following conventional PRE usage,"1" and "2" refer to predictions made using the "base"(1) prediction and model(2) prediction rules.

{cmd:ccmpre} saves the following in {cmd:r()}:

{title:Scalars}

{synopt:{cmd:r(PRE)}} The PRE measure {p_end}
{synopt:{cmd:r(E1)}} Total prediction errors under the base prediction rule {p_end}
{synopt:{cmd:r(E2)}} Total prediction errors under the model prediction rule {p_end}
{synopt:{cmd:r(N)}} Size of the estimation sample {p_end}

{title: Matrices} 

{synopt:{cmd:r(E1Item)}} A K X 1 matrix giving the base prediction error for each item {p_end}
{synopt:{cmd:r(E2Item)}} A K X 1 matrix giving the model prediction error for each item {p_end}


{title: Macros}

{synopt:{cmd:r(basemodel)}} Indicates which base model was chosen. {p_end}


{title:Examples}

{cmd:. ccmpre x1-x10, key(Z) competence(D) base(U)} 
{cmd:. ccmpre x1-x10, key(Z) competence(D) // default to base(U)} 

{title:References}

{phang}Goodman, Leo A., and William H. Kruskal. 1954. “Measures of Association for Coss Classifications.” 
Journal of the American Statistical Association 49(268):732–64. {p_end}

{phang} Lacy, Michael G. and Jeffrey G. Snodgrass. 2013. "Analyzing Cultural 
Consensus with 'Proportional Reduction of Error' (PRE): Beyond the Eigenvalue 
Ratio."  Under review, Field Methods. {p_end}

{phang}Romney, A. Kimball, Susan C. Weller, and William H. Batchelder. 1986. “Culture 
as Consensus: A Theory of Culture and Informant Accuracy.” American Anthropologist 
88(2): 313–338. {p_end}


{title:Author}

{phang}Michael G. Lacy{p_end}
{phang}Department of Sociology{p_end}
{phang}Colorado State University{p_end}
{phang}Fort Collins, CO 80523 USA{p_end}
{phang}Michael.Lacy@colostate.edu{p_end}
