{smcl}
{* *! version 1.1  18mar2014}{...}
{cmd:help radiusmatch} 
{hline}

{title:Syntax}

{p2colset 5 19 21 2}{...}
{p 4 16 2}
{opt radiusmatch} {it:treatvar} [{indepvars}] {ifin}
  {cmd:,} {opth out:come(varlist)} [{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Specification}
{synopt :{opth out:come(varlist)}}dependent variables{p_end}
{synopt :{opth p:score(varname)}}user-supplied propensity score{p_end}
{synopt :{opth mahal:anobis(varlist)}}additional matching variables{p_end}
{synopt :{opt ate}}estimate ATENT and ATE as well (Note: doubles computation 
time){p_end}

{syntab:Parameters for matching}
{synopt :{opt cqu:antile(#)}}defines the maximum distance as the {it:#} 
percentile of the distance distribution; default is {cmd:cquantile(90)}{p_end}
{synopt :{opt cpe:rcent(#)}}defines the radius in %-distance to largest 
one-to-one match (or a particular quantile); default is {cmd:cpercent(300)}{p_end}
{synopt :{opt score:weight(#)}}values larger than 1 give more weight to the 
propensity score in the mahalanobis metric; default is {cmd:scoreweight(5)}{p_end} 
{synopt :{opt mwe:ight(#)}}maximum share of weight in % of one observation 
compared to total weight; default is no restriction on maximum weight ({cmd:mweight(100)}){p_end}
{synopt :{opt logit}}uses logit instead of probit to estimate the propensity score{p_end}
{synopt :{opt index}}uses linear index instead of probability as propensity 
score{p_end}
{synopt :{opt noc:ommon}}common support is not enforced{p_end}
{synopt :{opt bc(#)}}0 for no bias correction, 1 for linear bias correction, 
2 for linear and logit bias correction; default is {cmd:bc(1)}{p_end}

{syntab:Bootstrap and standard errors}
{synopt :{opt knn}}uses nearest-neighbor matching algorithm to estimate the conditional variance{p_end}
{synopt :{opt boot:strap(#)}}number of bootstrap replications; default is 
{cmd:bootstrap(0)}{p_end}
{synopt :{opth cluster(varlist)}}variables identifying resampling clusters{p_end}
{synopt :{opth bfile(["]filename["])}}saves the results of all bootstrap replications{p_end}
{synopt :{opt not:stat}}avoids the calculation of analytical standard errors in bootstrap replications{p_end}

{syntab:Computation}
{synopt :{opt boost}}avoids loops when estimating the distances and increases computation speed.{p_end}

{synoptline}
{p 4 6 2}{it:indepvars} may contain factor variables; see {help fvvarlist}.
Weights are not allowed.{p_end}

{title:Description}

{pstd}
{cmd:radiusmatch} estimates average treatment effects (ATET, ATENT, ATE) of {it:treatvar} 
for a set of outcomes variables {it:outcome} using radius matching. {it:indepvars} are used to
compute the propensity score. {cmd:radiusmatch} is a one-to-many caliper matching algorithm as,
for example, discussed by Rosenbaum and Rubin (1985) and used by Dehejia and Wahba (1999, 2002).
Caliper or radius matching uses all comparison observations within a predefined distance around 
the propensity score or based on the Mahalanobis distance of the respective treated. 
This allows for higher precision than fixed nearest neighbour matching in regions in 
which many similar comparison observations are available. Also, it may lead to a smaller 
bias in regions where similar controls are sparse. In other words, instead of fixing 
M globally, M is determined in the local neighbourhood of each treated observation.{p_end}

{pstd}
This estimator was proposed by Lechner, Miquel, and Wunsch (2011) combines the features 
of caliper matching with additional predictors and linear or nonlinear regression 
adjustment. After the first step of distance-weighted caliper matching with predictors, 
this estimator uses the weights obtained from matching in a weighted linear or non-linear 
regression in order to remove any bias due to mismatches.{p_end}

{pstd}
For a detailed description of the estimator and information on the adequate 
choice of the matching parameters please refer to Huber, Lechner & Steinmayr (2012).
{p_end}

{pstd}
Syntax and output of {cmd:radiusmatch} are oriented towards the popular {cmd:psmatch2} command by 
Barbara Sianesi and Edwin Leuven. The variables created by {cmd:radiusmatch} can be used with the
{cmd:pstest} and {cmd:psgraph} commands to test for covariate imbalance and to graph the distribution of
the propensity score. Both commands can be downloaded from the SSC archive.{p_end}

{pstd}
Note that {cmd:radiusmatch} requires the installation of the {cmd:tknz} command:
{inp: . ssc install tknz, replace} {p_end} 

{pstd}{cmd:radiusmatch} creates a number of variables:{p_end}

{pmore}{bf:_treated} equals 0 for control observations and 1 for treatment observations.{p_end}
{pmore}{bf:_untreated} is 1 - _treated{p_end}
{pmore}{bf:_support} equals 1 if the observation is on the common support and 0 otherwise.{p_end}
{pmore}{bf:_pscore} is the estimated propensity score or a copy of the one provided by pscore().{p_end}
{pmore}{bf:_weightt} holds the estimated weights for the ATET{p_end}
{pmore}{bf:_weightut} holds the estimated weights for the ATENT{p_end}


{title:Options}

{dlgtab:Specification}

{phang}
{opth outcome(varlist)} specifies the outcome variables.

{phang}
{opth pscore(varname)} is optional and specifies a user-supplied propensity score. 

{phang}
{opth mahalanobis(varlist)} Additional covariates to be controlled for in addition to the  
propensity score. Under the default NULL, propensity score matching is performed. If not NULL, 
matching on the Mahalanobis distance defined by the propensity score and the 
additional covariates is performed.

{phang}
{opt ate} specifies that {cmd:radiusmatch} estimates the "ATET" (average treatment 
effect on the treated), the "ATENT" (average treatment effect on the nontreated),
and the "ATE" (average treatment effect). If {opt ate} is not specified, only the 
ATET is estimated. Note that this option approximately doubles computation time.

{dlgtab:Parameters for matching}

{phang}
{opt cpercent(#)} is the multiplier of the maximum distance in pair matching (or a particular
quantile, see {opt cquantile}) which defines the radius. Default is 300, 
i.e., the radius is equal to 300 percent of the maximum distance in pair matching (or a 
particular quantile).


{phang}
{opt cquantile(#)} is the quantile of the distances in pair matching to be used 
for the definition of the radius. Default is 90, i.e. the 0.9th quantile of the 
distances in pair matching are used. If {opt cquantile} is smaller or equal to 0 
or greater or equal 1, the maximum distance is chosen. The size of the radius obtained
is a combination of {opt cquantile} and {opt cpercent}. E.g., {opt cpercent}=300 
and {opt cquantile}=90 defines the radius as three times the 0.9th quantile of 
differences in pair matching.


{phang}
{opt mweight(#)} is the maximum relative weight an observation may receive based 
on inverse probability weighting by the propensity score. E.g., if mweight=5, 
the maximum weight is 5 percent (compared to the joint weight of all other observations).
The default is 100 (=100 percent), i.e., no restriction on the weight.


{phang}
{opt bc(#)} 0 for no bias correction, 1 for linear bias correction, 
2 for linear and logit bias correction. In either case, the outcome is regressed on 
the propensity score, its square, and the variables used to compute the
Mahalanobis distance within the counterfactual treatment state.

{phang}
{opt nocommon} specifies that no common support is imposed. The default is that common 
support is imposed). If support is imposed and {opt ate} is not specified, treated observations 
with propensity scores larger than the maximum propensity score among the 
nontreated are discarded. If {opt ate} is specified and common support is imposed, treated 
observations with propensity scores larger than the second largest propensity 
score among the nontreated are discarded from the sample. If commonsup=1 and 
estimand="ATENT", nontreated observations with propensity scores smaller than 
the minimum propensity score among the treated are discarded. For estimand="ATE"
common support is imposed for both the treated and the nontreated.



{phang}
{opt logit} specifies that logit is used for propensity score estimation instead 
of probit (probit is default).



{phang}
{opt index} specifies that matching is based on the index of the probit/logit estimation 
instead of the propensity score (matching on the propensity score is default).

{phang}
{opt scoreweight(#)} specifies the weight of the p-score in Mahalanobis distance matching. 
Default is 5, which implies that the p-score gets five times the weight of any of 
the additional covariates considered in Mahalanobis distance matching. A weight of 1
implies equal weighting of the p-score and additional covariates.

{dlgtab:Bootstrap and standard errors}

{phang}
{opt bootstrap(#)} specifies that the bootstrap should be used for inference.
The number in paranthesis specifies the number of bootstrap replications. 
For any positive integer of reps, bootstrap standard errors and p-values are
computed based on the specified number of bootstrap replications (recommended). p-values 
are computed by bootstrapping the t-statistic.
In the case that the probit cannot be estimated in one bootstrap replication,
the pscore estimated in the original sample is used. Note that in principle 
{cmd:radiusmatch} can also be used with the Stata {help bootstrap} command. However,
bootstrapping the t-statistic is not possible in this case. 



{phang}
{opth cluster(varlist)} specifies the variables that identify resampling clusters. 
If this option is specified, the sample drawn during each replication is a bootstrap sample of clusters.



{phang}
{opth bfile(["]filename["])} saves the estimated parameters and analytical standard errors 
of every bootstrap replication in "filename.dta". The first row contains the estimates
in the original sample. 



{phang}
{opt knn} specifies that a nearest neighbor matching algorithm is used for 
conditional variance estimation of the outcome given the matching weight 
under counterfactual treatment, which is required for estimating the 
standard error. Default is local constant kernel regression (based on the 
Epanechnikov kernel and the rule of thumb for bandwidth choice).

{phang}
{opt notstat} bootstraps the treatment effects directly instead of bootstrapping the t-statistic.
This option can considerable decrease computation time as it avoids estimating the conditional variance
in each bootstrap replication. However, the bootstrap has better properties when using the t-statistic.

{dlgtab:Computation}

{phang}
{opt boost} specifies that matrix operations should be used instead of loops wherever possible.
This reduces computational time by roughly one third but may cause problems in datasets with many
observations (on my computer > 30.000) when the operating system refuses to provide the memory needed.




{title:Examples:  radius matching without bootstrap}

{pstd}Radius matching based on the propensity score{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. radiusmatch union age i.race married hours tenure south smsa, out(wage)}{p_end}

{pstd}Radius matching based on Mahalanobis distance{p_end}
{phang2}{cmd:. radiusmatch union age i.race married hours tenure south smsa, out(wage) mahal(age) ate}{p_end}

{pstd}Radius matching with user supplied propensity score{p_end}
{phang2}{cmd:. probit union age i.race married hours tenure south smsa}{p_end}
{phang2}{cmd:. predict double pscore, index}{p_end}
{phang2}{cmd:. radiusmatch union, pscore(pscore) out(wage) index ate}{p_end}


{title:Examples:  radius matching with bootstrap}

{pstd}Radius matching based on Mahalanobis distance with bootstrapped inference{p_end}
{phang2}{cmd:. radiusmatch union age i.race married hours tenure south smsa, out(wage) mahal(age) boot(99) ate}{p_end}

{hline}

{title:Saved results}

{pstd}
{cmd:radiusmatch} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(radius)}}radius chosen based on one to one matching{p_end}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(atet)}}vector of ATETs for all outcomes{p_end}
{synopt:{cmd:r(atent)}}vector of ATENTs for all outcomes (if requested){p_end}
{synopt:{cmd:r(ate)}}vector of ATEs for all outcomes (if requested){p_end}
{synopt:{cmd:r(seatet)}}vector of asymptotic s.e. for ATET for all outcomes{p_end}
{synopt:{cmd:r(seatent)}}vector of asymptotic s.e. for ATENT for all outcomes (if requested){p_end}
{synopt:{cmd:r(seate)}}vector of asymptotic s.e. for ATE for all outcomes (if requested){p_end}
{synopt:{cmd:r(y0_atet)}}vector of Y0 (average outcome of comparison group) for ATET for all outcomes{p_end}
{synopt:{cmd:r(y0_atent)}}vector of Y0 for ATENT for all outcomes (if requested){p_end}
{synopt:{cmd:r(y0_ate)}}vector of Y0 for ATE for all outcomes (if requested){p_end}
{synopt:{cmd:r(y1_atet)}}vector of Y1 (average outcome of treated group) for ATET for all outcomes{p_end}
{synopt:{cmd:r(y1_atent)}}vector of Y1 for ATENT for all outcomes (if requested){p_end}
{synopt:{cmd:r(y1_ate)}}vector of Y1 for ATE for all outcomes (if requested){p_end}
{synopt:{cmd:r(b_seatet)}}vector of bootstrap s.e. for ATET for all outcomes{p_end}
{synopt:{cmd:r(b_seatent)}}vector of bootstrap s.e. for ATENT for all outcomes (if requested){p_end}
{synopt:{cmd:r(b_seate)}}vector of bootstrap s.e. for ATE for all outcomes (if requested){p_end}
{synopt:{cmd:r(b_patet)}}vector of bootstrap p-values for ATET for all outcomes{p_end}
{synopt:{cmd:r(b_patent)}}vector of bootstrap p-values for ATENT for all outcomes (if requested){p_end}
{synopt:{cmd:r(b_pate)}}vector of bootstrap p-values for ATE for all outcomes (if requested){p_end}

{hline}

{title:Thanks for citing radiusmatch as follows}

{phang}
Huber, M., M. Lechner, and A. Steinmayr. (2012). "Radius matching on the 
propensity score with bias adjustment: finite sample behaviour, tuning parameters 
and software implementation". University of St.Gallen, School of Economics and 
Political Science, Economics Working Paper Series No. 1226

{title:Disclaimer}

{phang}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER 
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE 
QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE 
DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER 
PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR 
DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES 
ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF 
SUCH DAMAGES.

{title:Further reading}

{phang}Dehejia, R. H., and S. Wahba (1999): "Causal Effects in Non-experimental 
Studies: Reevaluating the Evaluation of Training Programmes", 
{it:Journal of the American Statistical Association}, 94, 1053-1062.

{phang}Dehejia, R. H., and S. Wahba (2002): "Propensity Score- Matching Methods 
for Nonexperimental Causal Studies", {it:Review of Economics and Statistics}, 84, 151-161.

{phang}Huber, M., M. Lechner and C. Wunsch (2013): "The performance of estimators
based on the propensity score", {it:Journal of Econometrics}, 175(1), 1-21. 

{phang}Lechner, M., R. Miquel and C. Wunsch (2011): "Long-Run Effects of Public 
Sector Sponsored Training in West Germany", 
{it:Journal of the European Economic Association}, 9, 742-784.

{phang}Rosenbaum, P. R., and D. B. Rubin (1985): "Constructing a Control Group 
Using Multivariate Matched Sampling Methods that Incorporate the Propensity 
Score", {it:The American Statistician}, 39, 33-38.

{title:Authors}

{phang}
Martin Huber, University of St. Gallen.{p_end}

{phang}
Michael Lechner, University of St. Gallen.{p_end}

{phang}
Andreas Steinmayr, University of Chicago. If you observe any problems or if 
you have any comments or suggestions please contact
{browse asteinmayr@uchicago.edu}.

