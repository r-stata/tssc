{smcl}
{* *! version 1.0 15 Apr 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help collin (if installed)" "help collin"}{...}
{viewerjumpto "Syntax" "subsetByVIF##syntax"}{...}
{viewerjumpto "Description" "subsetByVIF##description"}{...}
{viewerjumpto "Options" "subsetByVIF##options"}{...}
{viewerjumpto "Remarks" "subsetByVIF##remarks"}{...}
{viewerjumpto "Examples" "subsetByVIF##examples"}{...}
{viewerjumpto "Alsosee" "table##video"}{...}{title:Title}
{phang}
{bf:subsetByVIF} {hline 2} Select a subset of covariates constrained by VIF

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:subsetByVIF}
[{varlist}]
[{help if}]
[{help in}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt vifl:ist(numlist descending  min=1)}} list of maximum variance inflation factors (VIFs) used to subset {it:varlist} {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:subsetByVIF} selects subsets of the covariates listed 
 in {it:varlist} such that each covariate 
 in a given subset has a VIF that is less than or equal 
 to a specified value given by viflist.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt vifl:ist(numlist descending  min=1)} specifies one or more maximum VIF values.  
These values must be in descending order, and must be greater than one. 
For each these maximum VIF values, the program identifies the largest 
possible subset of covariates such that each covariate in this subset 
has a VIF that is less than or equal to this maximum value. 
The default maximum VIF is 10.   {p_end}

{marker remarks}{...}
{title:Remarks}
{pstd}
 We are frequently faced with analyzing data sets in which the ratio of 
 covariates to patients is high. There are several approaches to analyzing 
 such data including penalized regression methods, k-fold cross-validation
 techniques, and bagging. A problem with any of these approaches is that, even 
 after the elimination of variables causing multi-collinearity, 
 the variance-covariance matrix of the remaining covariates is often 
 highly ill-conditioned. The subsetByVIF program reduces the number 
 of covariates to the largest subsample such that the maximum VIF for 
 each variable in the subsample is less than some value specified by 
 the user. These variables are selected without regard to the dependent 
 variable of interest, which should mitigate problems due to overfitting. 
 The use of this program should improve the convergence properties of 
 many methods of exploratory data analysis.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang}{cmd:. webuse auto}{p_end}

{pstd}subsetByVIF{p_end}
{phang}{cmd:. subsetByVIF price mpg weight length displacement gear_ratio foreign}{p_end}
{phang}{cmd:. subsetByVIF price mpg weight length displacement gear_ratio foreign, viflist(15 5)}{p_end}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(n_vif)}} number of maximum VIF values specified {p_end}

{synopt:{cmd:r(vifmax1)}} largest value of vifmax specified by the viflist option {p_end}
{synopt:{cmd:r(n1)}} number of variables in the subset of covariates with VIFs <= vifmax1 {p_end}
{synopt:{cmd:r(covlist1)}} local macro consisting of the names of the variables in the subset of covariates with VIFs <= vifmax1 {p_end}

{synopt:{cmd:r(vifmax2)}} second largest value of vifmax specified by the viflist option {p_end}
{synopt:{cmd:r(n2)}} number of variables in the subset of covariates with VIFs <= vifmax2 {p_end}
{synopt:{cmd:r(covlist2)}} local macro consisting of the names of the variables in the subset of covariates with VIFs <= vifmax2 {p_end}

{synopt:{cmd:.}} {p_end}
{synopt:{cmd:.}} {p_end}
{synopt:{cmd:.}} {p_end}

{title:Author}

{pstd}Dale Plummer{p_end}
{pstd}William D. Dupont{p_end}
{pstd}Department of Biostatistics{p_end}
{pstd}Vanderbilt University School of Medicine{p_end}
{pstd}Email {browse "mailto:william.dupont@vumc.org":william.dupont@vumc.org}{p_end}
{pstd}Email {browse "mailto:dale.plummer@vumc.org":dale.plummer@vumc.org}{p_end}


{marker Alsosee}{...}
{title:Also see}

{phang}collin.ado: A contributed program by Philip B. Ender that calculates the VIF for each variable in a set of covariates.{p_end}
{phang}Manual: {manhelp regress_postestimation R:regress_postestimation}{p_end}
{phang}On-line:  help for vif{p_end}

