{smcl}
{* *! 01feb2011}{...}
{cmd:help twfe}
{hline}

{title:Title}


{title:Regressions with two-way fixed effects or match effects for large datasets}


{title:Syntax}

{p 8 17 2}
{cmdab:twfe}
{depvar}
[{indepvars}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt id:s(vname1 vname2)}}ID variables of fixed effects. Must include exactly two ID variables.{p_end}
{syntab:Optional}
{synopt:{opt m:atcheffect}}include match fixed effect{p_end}
{synopt:{opt c:luster(varlist)}}specify cluster variables for one- or two-way clustering{p_end}
{synopt:{opt replace}}replace data in memory by estimates of the fixed effects{p_end}
{synopt:{opt max:it(#)}}maximum number of iterations for the conjugate gradient algorithm; Default is 500.{p_end}
{synopt:{opt t:ol(#)}}set tolerance of cga; default is 1.0e-7{p_end}
{synopt:{opt v:erbose(#)}}controls how much detail cga displays{p_end}
{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opth ef:orm(strings:string)}}report exponentiated coefficients and label as {it:string}{p_end}
{synopt :{it:{help regress##display_options:display_options}}}control column formats, row spacing, line width, and display of omitted variables and base and empty cells{p_end}
{synopt :{opt nohe:ader}}suppress table header{p_end}
{synopt :{opt notab:le}}suppress coefficient header{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{cmd: predict} can be used after {cmd:twfe} with options xb,e,xbu and ue to predict the linear prediction with fixed effects (xbu) and without them (xbu) as well as residuals with fixed effects (ue)
and without them (e). Other functionality of {cmd:predict} may work, but I haven't tested it.{p_end}

{title:Description}

{pstd}
{cmd:twfe} fits a linear regression model of {depvar} on {indepvars} including fixed effects for the two units defined by {opt ids(varlist)}. 
If {opt m:atcheffect} is specified, fixed effects for the interaction of the two id variables are included. The estimates of the fixed effects are saved in new variables called "fe1" (for ID with more units)
and "fe2" (for ID with fewer units). If {opt m:atcheffect} is specified additional variables for the match id ("matchid"), the match fixed effect ("matchef") and the match duration ("mlength") are created.
If the dataset already contains variables with these names, the original variables are replaced.{break}
{cmd: twfe} is intended for estimation in large data sets, where constraints on memory and matsize make standard estimation difficult and time consuming. Instead of
solving (X'X)b=X'y by inverting X'X it solves the system by computing the slopes first, then using the conjugate gradient algorithm to compute the smaller set of fixed
effects and finally solving for the other fixed effects recursively. See {help twfe##remarks:Remarks} for further info.
{p_end}

{title:Options}

{dlgtab:Required}

{phang}
{opt id:s(varname1 varname2)} needs to contain the variable names for the identifiers of the two sets of fixed effects. It has to contain exactly two variables and they have to be numeric. The program always 
considers the unit that contains more fixed effects (i.e. individuals if there are more individuals than firms) as the first unit, regardless of the order they are specified in {opt id:s()}. Specifying the larger
one as the first variable will make it slightly faster.

{dlgtab:Optional}
{phang}
{opt m:atcheffect} runs the match fixed effect model instead of the two-way fixed effects model, i.e. in addition to the fixed effects specified by {opt id:s(varname1 varname2)} a fixed effect
for every unique combination of the two identifiers is included in the model.

{phang}
{opt c:luster(varlist)} calculates robust as well as one or two-way clustered standard errors using the method proposed in Cameron et al (2006). {it:varlist} should contain the variable names of 
the variables that define the clusters or "het" for heteroskedasticity robust standard errors. If it contains one variable name, one-way clustering is used. For two-way clustering, specify two 
variables. Optionally, a third variable (order matters) can be specified that identifies unique combinations of the first two clustering variables (i.e. a match id). If such a variable is available, 
it speeds up the execution because the program does not need to create this variable. Specifying three variables does {hi: not} do three-way clustering and specifying a variable that is not the 
interaction between the first two variables will lead to wrong results.

{phang}
{opt replace} By default, {cmd: twfe} saves the data in memory to disc as a temporaty file in order to preserve memory. After estimation, it merges the original data and the estimates of the fixed effects. 
Specifying {opt replace} skips the save and merge, so that the data in memory is replaced by a dataset that only contains the ID variables and the variables created by {cmd: twfe}. If the data in memory is large,
this can save time and disc space, but {hi: the data currently in memory is changed}. Additionally, e(sample) is not returned and {cmd:predict} will probably return erratic results.

{phang}
{opt max:it(#)} The program terminates unsuccessfully if the conjugate gradient algorithm has not converged within the number of iterations specified. The default is 500, 
see {help twfe##convergence:Convergence} for further details.

{phang}
{opt t:ol(#)} The conjugate gradient algorithm terminates successfully if the residual is smaller than the number specified. The default is 1.0e-7,
see {help twfe##convergence:Convergence} for further details.

{phang}
{opt v:erbose(#)} Controls how much detail the conjugate gradient algorithm displays. Can take values 0 (none) 1 (summary) or 2 (size of residual after every iteration).

{dlgtab:Reporting}

{phang}
{opt level(#)} controls levels for confidence intervals. See {helpb estimation options##level():[R] estimation options}.

{phang}
{opth eform:(strings:string)} specifies that the coefficient table be displayed in exponentiated form as
defined in {manhelp maximize R} and that {it:string} be used to label the
exponentiated coefficients in the table.

{marker display_options}{...}
{phang}{it:display_options}: see {helpb estimation options##display_options:[R] estimation options}. They should all work correctly, but I haven't checked all of them.

{phang}
{opt noheader} suppresses the display of the ANOVA table and summary statistics at the top of the output; only the coefficient table is displayed.

{phang}
{opt notable} suppresses display of the coefficient table.

{title:Remarks}{marker remarks}
{pstd}
{hi:Method}{break}
For a full description of the method, see my paper in the {help twfe##ref:References}. The algorithms employed for estimation of the two-way FE and the match effect model are a little different. 
However, both essentially proceed in three steps:{break}
1. Calculate the slope coefficients (by partial regression){break}
2. Set up a system of equations that is implied by the normal equations and is solved by the OLS estimates of the smaller set of fixed effects. Use the conjugate gradient algorithm to solve it.{break}
3. Calculate all other fixed efffects using the fact that residuals sum to zero.{break}
{break}
This procedure yields the exact OLS estimates of the slopes and all fixed effects if and only if the data matrix is of full rank. Contrary to the {cmd: regress} command, the program does not 
verify this. A key advantage of the method is the reduction in the size of the problem to solve by step 2. There are as many equations as there are fixed effects for the second id variable,
so it is important to use the right order. The gains in performance are larger the smaller the second set of fixed effects is compared to the first.

{pstd}
{hi:Identification}{break}
Identification conditions for the two-way fixed effects model are discussed in Abowd et al. 2002. For the match fixed effects model, see Woodcock 2008. The normalizations I impose to identify the
two-way fixed effects model are that the intercept is set to zero and the (unweighted) fixed effects for id2 sum to zero in every group. The additional normalizations imposed to identify the match fixed
effects is that the (duration weighted) match fixed effects sum to zero for every unit of the two ID variables. 

{pstd}
{hi:Convergence}{marker convergence}{break}
Occasionally, the conjugate gradient algorithm may fail to converge. If this happens, it may either be the case that the system of equations has no unique solution or it may not have found it within the 
given number of iterations and the specified tolerance. Most problems that have a solution should converge within 500 iterations, but the default tolerance may be quite low when dealing with really large problems.
On the other hand, the problem may not have a solution if some of the regressors are perfectly colinear. Generally, the algorithm has no problem with multiple groups (as defined in Abowd et al 2002). In such 
cases, the group mean of the fixed effects for id2 are set to zero. If there are units created by id2 that have no movers, this implied that their fixed effect is zero as well. However, if there are small 
groups, moving patterns can be such that there is no unique solution even though people are moving between units. The algorithm does not examine the group structure, so such groups have to be excluded 
manually in case convergens persistently fails. Amine Ouazad's a2group is a good program to examine the group structure of the data.

{pstd}
{hi:Memory} (Stata 11 or earlier){break}
Most of the computations are done in Mata and are thus not subject to Stata's memory limits. However, some calls to Stata are made and will not work if Stata has not been assigned enough memory to perform
them. If possible, do not set Stata's memory limit really close to the size of the dataset. If you do not have enough main memory to estimate the model, you may be able to speed up the program by using
"set virtual on".

{pstd}
{hi:Other}{break}
If you find any mistakes or have any suggestions for improvements, please send me an email to {browse "mailto:mittag@uchicago.edu":mittag@uchicago.edu}. Feel free to use, change or mutilate this program
for private purpose, but please don't steal it, give due credit. That being said, I learned a lot about writing code in Mata from Amine Ouazad's a2reg code and would like to thank her for making it
publicly available. I would also like to thank Kit Baum for several useful suggestions.

{title:Examples}
{pstd}Two-way fixed effects model with two-way clustered standard errors{p_end}
{phang2}{cmd:. twfe wage age experience, ids(individual_id firm_id) cluster(individual_id firm_id)}

{pstd}Match effects model with one-way clustered standard errors{p_end}
{phang2}{cmd:. twfe wage age experience, ids(individual_id firm_id) cluster(match_id) matcheffect}

{title:Saved results}

{pstd}
{cmd:twfe} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(df_e)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(ar2)}}adjusted R-squared{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(ncov)}}number of covariates{p_end}
{synopt:{cmd:e(n1)}}number of fixed effects created by larger group{p_end}
{synopt:{cmd:e(n2)}}number of fixed effects created by smaller group{p_end}
{synopt:{cmd:e(nm)}}number of matches (only with {opt m:atcheffect}){p_end}
{synopt:{cmd:e(F)}}F statistic of H0: all slopes and FEs are 0{p_end}
{synopt:{cmd:e(pval)}}p value of H0: all slopes and FEs are 0{p_end}
{synopt:{cmd:e(F_fe)}}F statistic of H0: all FEs are 0{p_end}
{synopt:{cmd:e(p_fe)}}p value of H0: all FEs are 0{p_end}
{synopt:{cmd:e(F_x)}}F statistic of H0: all slopes are 0{p_end}
{synopt:{cmd:e(p_x)}}p value of H0: all slopes are 0{p_end}
{synopt:{cmd:e(F_fe1)}}F statistic of H0: all FE by larger ID are 0 (not with {opt m:atcheffect}){p_end}
{synopt:{cmd:e(p_fe1)}}p value of H0: all FE by larger ID are 0 (not with {opt m:atcheffect}){p_end}
{synopt:{cmd:e(F_fe2)}}F statistic of H0: all FE by smaller ID are 0 (not with {opt m:atcheffect}){p_end}
{synopt:{cmd:e(p_fe2)}}p value of H0: all FE by smaller ID are 0 (not with {opt m:atcheffect}){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:twfe}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(model)}}twfe or match{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable(s){p_end}
{synopt:{cmd:e(unit1)}}name of identifier for larger set of fixed effects{p_end}
{synopt:{cmd:e(unit2)}}name of identifier for smaller set of fixed effects{p_end}
{synopt:{cmd:e(predict)}}Program used to implement predict{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(nomov)}}Identifies units in smaller ID that did not have any movers. Gives the positions of the units when unique values of smaller ID are sorted.{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}Marks estimation sample (not with {opt replace}{p_end}

{p2colreset}{...}

{title:References}{marker ref}

{phang}Abowd, J. M., R. H. Creecy, and F. Kramarz 2002. Computing person and firm effects using linked longitudinal employer-employee data. {it:Census Bureau Technical Paper TP-2002-06.}{p_end}
{phang}Cameron, C. A., J. B. Gelbach and D.L. Miller 2006. {it:Robust Inference With Multi-Way Clustering}. Mimeo.{p_end}
{phang}Mittag, N. 2012. {it:New methods to estimate models with large sets of fixed effects with an application to matched employer-employee data from Germany}. 
{browse "http://doku.iab.de/fdz/reporte/2012/MR_01-12_EN.pdf":FDZ-Methodenreport 02/2012}.{p_end}
{phang}Woodcock, S.D. 2008. {it:Match Effects}. Mimeo.{p_end}

{title:Author}
Nikolas Mittag, University of Chicago
mittag@uchicago.edu
