{smcl}
{* *! version 1  2018-07-27}{...}
{viewerjumpto "Syntax" "fuzzydid##syntax"}{...}
{viewerjumpto "Description" "fuzzydid##description"}{...}
{viewerjumpto "Options" "fuzzydid##options"}{...}
{viewerjumpto "Examples" "fuzzydid##examples"}{...}
{viewerjumpto "Saved results" "fuzzydid##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:fuzzydid} {hline 2} Estimation with Fuzzy Difference-in-Difference Designs.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:fuzzydid Y G T D} {ifin} 
[{cmd:,} 
{cmd:did} 
{cmd:tc}
{cmd:cic}
{cmd:lqte} 
{cmd:{ul:newc}ateg(}{it:numlist}{cmd:)}
{cmd:{ul:num}erator}
{cmd:{ul:part}ial}
{cmd:nose}
{cmd:{ul:cl}uster(}{it:varname}{cmd:)}
{cmd:breps(}{it:#}{cmd:)}
{cmd:{ul:eqt}est}
{cmd:{ul:cont}inuous(}{it:varlist}{cmd:)}
{cmd:{ul:quali}tative(}{it:varlist}{cmd:)}
{cmd:modelx(}{it:reg1 reg2 reg3}{cmd:)}
{cmd:sieves}
{cmd:{ul:sieveo}rder(}{it:#}{cmd:)}
{cmd:{ul:tag}obs}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:fuzzydid} computes estimators of local average and quantile treatement effects in fuzzy DID designs, following de Chaisemartin and D'Haultfoeuille (2018a). 
It also computes their standard errors and confidence intervals.{p_end}

{p 4 8}{cmd:Y} is the outcome variable.{p_end}

{p 4 8}{cmd:G} is the group variable(s). We refer to Section 4.2 of {browse "https://sites.google.com/site/clementdechaisemartin/statapaper_fuzzydid.pdf":de Chaisemartin et al. (2018b)} for more details on how to construct this/these variable(s).{p_end}

{p 4 8}{cmd:T} is the time period variable.{p_end}

{p 4 8}{cmd:D} is the treatment variable. It can be any ordered variable.

{p 0 0}A detailed introduction to this command is given in {browse "https://sites.google.com/site/clementdechaisemartin/statapaper_fuzzydid.pdf":de Chaisemartin et al. (2018b)}.{p_end}

{marker options}{...}
{title:Options}

{p 4 8}{cmd:did} computes the Wald-DID estimator.{p_end}

{p 4 8}{cmd:tc} computes the Wald-TC estimator.{p_end}

{p 4 8}{cmd:cic} computes the Wald-CIC estimator. This option can only be specified when no covariates are included in the estimation.{p_end}

{p 4 8}{cmd:lqte} computes the estimators of the LQTE for quantiles of order 5%, 10%,..., 95%. This option can only be specified when D, G, and T are 
binary, and no covariates are included in the estimation.{p_end}

{p 0 0} At least one of the four options above must be specified. If several of these options are specified, the command computes all the estimators requested by the user.

{p 4 8}{cmd:newcateg(}{it:numlist}{cmd:)} groups some values of the treatment together when estimating the Wald-TC and Wald-CIC. This option may be useful when the treatment takes a large number of values, 
as explained in Section 3.3 of {browse "https://sites.google.com/site/clementdechaisemartin/statapaper_fuzzydid.pdf":de Chaisemartin et al. (2018b)}. The user needs to specify the upper bound of 
each set of values of the treatment she wants to group. For instance, if {cmd:D} takes the values 0,1,2,3,4.5,7,8, and she wants to group together units with D in {0,1,2}, D in {3,4.5}, and D in {7,8}, she needs 
to write {cmd:newcateg(2 4.5 8)}.{p_end}

{p 4 8}{cmd:numerator} computes only the numerators of the Wald-DID, Wald-TC and Wald-CIC estimators. As explained in Section 3.3.3 in the supplement of de Chaisemartin and D'Haultfoeuille (2018a), this option 
is useful to conduct placebo tests of the assumptions underlying each estimator.{p_end}

{p 4 8}{cmd:partial} computes the bounds on the local average treatment effects in the absence of a "stable" control group. This option can only be specified when no covariates are included in the estimation.{p_end}

{p 4 8}{cmd:nose} computes only the estimators, not their standard errors.{p_end}

{p 4 8}{cmd:cluster(}{it:varname}{cmd:)} computes the standard errors of the estimators using a block bootstrap at the {it:varname} level. Only one clustering variable is allowed.{p_end}

{p 4 8}{cmd:breps(}{it:#}{cmd:)} specifies the number of bootstrap replications. The default is 50.{p_end}

{p 4 8}{cmd:eqtest} performs an equality test between the estimands, when the user specifies at least two of the {cmd:did}, {cmd:tc}, and {cmd:cic} options.{p_end}

{p 4 8}{cmd:tagobs} creates a new variable named {it:tagobs} which identifies the observations used by {cmd:fuzzydid}.{p_end}

{marker options}{...}
{title:Options specific to estimators with covariates}

{p 4 8}{cmd:continuous(}{it:varlist}{cmd:)} specifies the names of all the continuous covariates that need to be included in the estimation.{p_end}

{p 4 8}{cmd:qualitative(}{it:varlist}{cmd:)} specifies the names of all the qualitative covariates that need to be included in the estimation. For each variable, indicator variables are created for each value except one, and 
included as controls in the estimation.{p_end}

{p 4 8}{cmd:modelx(}{it:reg1 reg2 reg3}{cmd:)} specifies which parametric method should be used to estimate the conditional expectations in the Wald-DID or Wald-TC estimators with covariates. {it:reg1} specifies 
which method should be used to estimate E(Y_{gt}|X) and E(Y_{dgt}|X). {it:reg2} specifies which method should be used to estimate E(D_{gt}|X). When D is not binary, {it:reg3} specifies which method should be used 
to estimate P(D_{gt}=d|X) for all possible values of d. The possible methods are: {cmd:ols}, {cmd:logit}, and {cmd:probit}. For instance, if the user writes {cmd:modelx(ols logit logit)}, the command estimates 
E(Y_{gt}|X) and E(Y_{dgt}|X) by OLS, and E(D_{gt}|X) and P(D_{gt}=d|X) by a logistic regession. The {cmd:logit} and {cmd:probit} options can only be used with binary variables.{p_end}

{p 4 8}{cmd:sieves} indicates that the conditional expectations in the Wald-DID and Wald-TC with covariates should be estimated nonparametrically.{p_end}

{p 0 0}When covariates are included in the estimation, and neither {cmd:modelx} nor {cmd:sieves} is specified, the command estimates by default all conditional expectations by OLS.{p_end}

{p 4 8}{cmd:sieveorder(}{it:#}{cmd:)} specifies the order of the sieve basis, when the option {cmd:sieves} is used. It must be greater than or equal to 2, and the command does not allow for more than min(4800, n/5) 
basis functions, where n is the number of observations. If this option is not specified, the choice of the sieve order is done via 5-fold cross-validation with a mean squared error loss function.{p_end}


    {hline}

{marker examples}{...}
{title:Example: data from Gentzkow, Shapiro, and Sinkinson (2011)}
    
{p 4 8}{p_end}
{p 8 8}{cmd:. use turnout_dailies_1868-1928.dta}{p_end}

{p 4 8}{p_end}
{p 8 8}{cmd:. gen G1872=(fd_numdailies>0)-(fd_numdailies<0) if (year==1872)&fd_numdailies!=.&sample==1}{p_end}

{p 4 8}{p_end}
{p 8 8}{cmd:. sort cnty90 year}{p_end}

{p 4 8}{p_end}
{p 8 8}{cmd:. replace G1872=G1872[_n+1] if cnty90==cnty90[_n+1]&year==1868}{p_end}

{p 4 8}{p_end}
{p 8 8}{cmd:. fuzzydid pres_turnout G1872 year numdailies, did tc cic newcateg(0 1 2 45) breps(200) cluster(cnty90)}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}In what follows, let {it:k} denote the number of options specified among {cmd:did}, {cmd:tc} and {cmd:cic}. {cmd:fuzzydid} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(N)}} number of observations used in the estimation.{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b_LATE)}} a k x 1 matrix where each line corresponds to the value of one of the requested estimators.{p_end}

{synopt:{cmd:e(se_LATE)}} a k x 1 matrix where each line corresponds to the bootstrap standard errors associated to one of the requested estimators.{p_end}

{synopt:{cmd:e(ci_LATE)}} a k x 2 matrix whose columns respectively store the lower and upper bounds of the 95% confidence interval computed by percentile bootstrap for each requested estimator.{p_end}

{synopt:{cmd:e(b_LATE_eqtest)}} a "k choose 2" x 1 matrix which stores the value of the difference between each pair of requested estimators.{p_end}

{synopt:{cmd:e(se_LATE_eqtest)}} a "k choose 2" x 1 matrix which stores the bootstrap standard errors associated to the difference between each pair of requested estimators.{p_end}

{synopt:{cmd:e(ci_LATE_eqtest)}} a "k choose 2" x 2 matrix whose columns respectively store the lower and upper bounds of the 95% confidence interval computed by percentile bootstrap for the difference between each pair of requested estimators.{p_end}

{synopt:{cmd:e(b_LQTE)}} a 19 x 1 matrix which stores the value of the LQTE estimator at the 5th, 10th,...,95th percentile.{p_end}

{synopt:{cmd:e(se_LQTE)}} a 19 x 1 matrix which stores the bootstrap standard errors associated to the 19 LQTE estimators.{p_end}

{synopt:{cmd:e(ci_LATE)}} a 19 x 2 matrix whose columns respectively store the lower and upper bounds of the 95% confidence interval computed by percentile bootstrap for each LQTE estimator.{p_end}

{title:References}

{p 4 8}de Chaisemartin, C. and D'Haultfoeuille,X. 2018a. 
{browse "https://sites.google.com/site/clementdechaisemartin/fuzzy_did.pdf":Fuzzy Differences-in-Differences}. 
{it:Review of Economic Studies}, 85 (2): 999-1028.{p_end}

{p 4 8}de Chaisemartin, C. and D'Haultfoeuille, X. and Guyonvarch, Y. 2018b. 
{browse "https://sites.google.com/site/clementdechaisemartin/statapaper_fuzzydid.pdf":Fuzzy Differences-in-Differences with Stata}.
{it:Forthcoming in the Stata Journal}.{p_end}

{p 4 8}Gentzkow, M. and Shapiro, J. and Sinkinson, M. 2011. 
{browse "https://www.aeaweb.org/articles?id=10.1257/aer.101.7.2980":The Effect of Newspaper Entry and Exit on Electoral Politics}.
{it:American Economic Review 101.7 (2011): 2980-3018}.{p_end}

{title:Authors}

{p 4 8}Clément de Chaisemartin, University of California at Santa Barbara, Santa Barbara, California, USA.
{browse "mailto:clementdechaisemartin@ucsb.edu":clementdechaisemartin@ucsb.edu}.{p_end}

{p 4 8}Xavier D'Haultfoeuille, CREST, Palaiseau, France.
{browse "mailto:xavier.dhaultfoeuille@ensae.fr":xavier.dhaultfoeuille@ensae.fr}.{p_end}

{p 4 8}Yannick Guyonvarch, CREST, Palaiseau, France.
{browse "mailto:yannick.guyonvarch@ensae.fr":yannick.guyonvarch@ensae.fr}.{p_end}



