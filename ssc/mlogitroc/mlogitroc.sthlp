{smcl}
{* *! version 1.2.3  28sep2010}{...}
{cmd:help mlogitroc}
{hline}
 
{title:Title}

{p2colset 5 19 21 2}{...}
{bf: mlogitroc}  - Multiclass ROC Curves and AUC from Multinomial Logistic Regression
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{bf:mlogitroc} {bf:classvar}  {bf:var1}  {bf:var2}  {bf:...}  {bf:var{it:p}}  [{it:if ...}] 

{pstd}

{title:Description}

{pstd}
{cmd:mlogitroc} generates multiclass ROC curves for classification accuracy based on multinomial logistic regression using mlogit.  The algorithm begins by running 
mlogit {it:B}=100 times using bootstrapped records for each run while the original class labels are intact.  Class prediction is then performed 
for records not sampled during bootstrapping, and accuracy for the left out records is determined as the fraction of correct class membership predictions.  This results in {it:B}=100 realizations of the accuracy for the alternative distribution.
Next, {it:B}=100 mlogit runs are made again, but this time after shuffling class labels of all records prior to modeling, which results in {it:B}=100 realizations of null accuracy.  Smoothed probability distributions 
are obtained for the {it:B}=100 alternative and null accuracy values using kernel density estimation (KDE, Gaussian kernel) to obtain 100 smoothed realizations for alternative and null accuracy.  The false positive rate (FPR), 
true positive rate (TPR), and area under the curve (AUC) are determined from the smooth pdfs derived from KDE.  Twoway scatter plots of the smoothed pdfs are constructed, 
followed by plotting the ROC curve.  

{pstd}
The default number of maximum iterations for reaching convergence is 20, which should be adequate for most runs.  A smaller value of maxiter=20 
helps terminate an mlogit run that will not converge - which may be common when using shuffled class labels to generate null accuracy values.  

{pstd}
{bf: Note:} This algorithm was not designed for stepwise modeling, and assumes that the user(s) pre-select the informative input variables prior to modeling.

{title:Input variables}

{pstd}
{cmd:classvar} must contain positive integer-based class labels such as 1,2,...,{it:C}, where {it:C} is the total number of classes.
 
{pstd}
{cmd:var1 var2 ... } {bf:var{it:p}} are the {it:p} independent variables.  

{title:Examples}

    {hline}
{phang2}{cmd:. mlogitroc y x1 x2 x3}{p_end}
{phang2}{cmd:. mlogitroc outcome age gender treatment1yes2n0}{p_end}
{phang2}{cmd:. mlogitroc class celltype time concentration heattemp}{p_end}
{phang2}{cmd:. mlogitroc cluster weight bmi gene1exp gene2exp}{p_end}
{phang2}{cmd:. mlogitroc outcome age treatment1yes2n0 if gender==2}{p_end}
{phang2}{cmd:. mlogitroc cluster weight bmi gene1exp gene2exp if age>40}{p_end}
    {hline}


{title:References}

{pstd}
This algorithm for multiclass ROC curve generation was introduced and used for the following papers:

{pstd}
Peterson, L.E., Hoogeveen, R.C., Pownall, H.J., Morrisett, J.D. Classification Analysis of Surface-enhanced Laser Desorption/Ionization Mass Spectral Serum Profiles for Prostate Cancer. 
International Joint Conference on Neural Networks (IJCNN06), July 2006.  
IEEE Press, Piscataway(NJ), 2006.

{pstd}
Peterson, L.E., Coleman, M.A. Machine learning-based receiver operating characteristic (ROC) curves for crisp and fuzzy classification of DNA microarrays in cancer research. Int. J. of Approximate Reasoning. 47: 17-36, 2008.

{title:Also see}

{psee}
{space 2}Help:  {manhelp mlogit R}, {manhelp kdensity R}, {manhelp summarize R}, {manhelp twoway G}
{p_end}
