{smcl}
{* *! version 0.6  4April2020}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:ebct} {hline 2} This ado-package estimates Entropy Balancing weights for continuous treatments (Tübbicke, 2020). The routine minimizes the deviation of weights from uniform or user-specified base weights while adhering to zero correlation and normalization constraints. Resulting weights can be used for the estimation of dose-response functions.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:ebct}
{varlist}
[if]
[in]
{cmd:,}
{cmdab:treatvar}{cmd:(}{it:varname}{cmd:)}
[{cmdab:basew}{cmd:(}{it:varname}{cmd:)}]
[{cmdab:samplew}{cmd:(}{it:varname}{cmd:)}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt varlist}} specifies the covariates to be balanced.{p_end}
{synopt:{opt treatvar}} specifies the continuous treatment variable.{p_end}
{synopt:{opt basew}} optional, specifies base weights q. Default: q=1/N.{p_end}
{synopt:{opt samplew}} optional, specifies sampling weights used to generate balancing targets.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:factor variables } are not allowed.{p_end}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ebct} implements Entropy Balancing for Continuous Treatments (Tübbicke, 2020). Estimated weights retain means of covariates and the treatment variable while removing Pearson correlations between covariates and the treatment. EBCT weights can be used in subsequent (non-parametric) regression analysis.  

{pstd}
Estimated weights are automatically saved in a new variable called _weight. In case this variable already exists in the dataset, it will be over-written without warning. The package also provides some summary statistics on the resulting balancing quality via a (weighted) regression
of the treatment T on the covariates X. Reported are the regression R-squared, the overall F-statistic of the excludability of all covariates
and the corresponding p-value before and after balancing. For convencience of the user, these statistics are stored in r(balance). Non-convergence of the algorithm or imperfect balance after running the EBCT command hints towards numerical difficulties due to high correlations between covariates. If this is the case, re-specification of covariates is advised.


{marker examples}{...}
{title:Example}

{pstd}
 As a hypothetical example, one may use the Dahejia/Wahba (1999) dataset, estimating balancing weights for real earnings in 1975 using 
(the highly correlated) real earnings in 1974 and other variables as covariates:

{cmd:. use "http://users.nber.org/~rdehejia/data/nsw_dw.dta",clear}

{cmd:. ebct re74 nodegree married hispanic black education age, treatvar(re75)}

Estimating balancing weights. This may take a while...

Iteration 0:   f(p) =  4.996e-15  (not concave)
Iteration 1:   f(p) =  .13572217  
Iteration 2:   f(p) =  .17370094  
Iteration 3:   f(p) =   .2405584  
Iteration 4:   f(p) =   .2421594  
Iteration 5:   f(p) =  .24216313  
Iteration 6:   f(p) =  .24216313  

#######################################
Summary statistics on balancing quality
#######################################

Results from a (weighted) regression of the treatment variable on covariates X:

------------------------------------------------------------
                 |    R-squared   F-statistic       p-value 
-----------------+------------------------------------------
before balancing |        0.473        56.086         0.000 
 after balancing |        0.000         0.000         1.000 
------------------------------------------------------------


{marker references}{...}
{title:References}


{phang}
Dehejia, R.H and Wahba, S. (1999), "Causal Effects in Non-Experimental Studies: Re-Evaluating the Evaluation of Training Programmes", 
{it:Journal of the American Statistical Association 94}, 1053-1062.

{phang}
Tübbicke, S. (2020). {it:Entropy Balancing for Continuous Treatments}. arXiv:2001.06281 [econ.EM]. 


{title:Author}

{pstd}Stefan Tübbicke{p_end}
{pstd}University of Potsdam{p_end}
{pstd}Potsdam, Germany{p_end}
{pstd}{browse "mailto:stefan.tuebbicke@uni-potsdam.de":stefan.tuebbicke@uni-potsdam.de}{p_end}




