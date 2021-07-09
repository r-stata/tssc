{smcl}
{* *! version 1.0  01nov2013}{...}
{viewerjumpto "Syntax" "zicen##syntax"}{...}
{viewerjumpto "Description" "zicen##description"}{...}
{viewerjumpto "Options" "zicen##options"}{...}
{viewerjumpto "Remarks" "zicen##remarks"}{...}
{viewerjumpto "Examples" "zicen##examples"}{...}

{title:Title}

{phang}
{bf:zicen} {hline 2} Estimates a finite mixture model made of a degenerate distribution with mass at 
zero and one or two censored (Tobit) normals.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:zicen} {depvar} [{indepvars}] {ifin},  {opt cl:asses(#)}[{cmd:}{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model main}
{synopt:{opt cl:asses(#)}}specify the number of classes (2 or 3){p_end}
{syntab:Model probability}
{synopt:{opt prob:ability(varlist)}}list of covariates to explain mixture probabilities (optional){p_end}
{syntab:Useful (optional) max options}
{synopt:{opt diff:icult}}uses a different stepping algorithm in non-concave regions{p_end}
{synopt:{opt init(values, copy)}}initial values for the coefficients (use with zicen0 rather than zicen){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed; see {manhelp maximize R} for more maximization options.{p_end}
{p 4 6 2}
{cmd:fweight}s are currently not allowed/tested.


{marker description}{...}
{title:Description}

{pstd}
{cmd:zicen}, for zero-inflated censored normals, estimates a finite mixture model made of a 
degenerate distribution with mass at zero and one or two censored (Tobit) normals. In general, the log-likelihood function of finite mixture models is difficult to maximize since it may contain multiple maxima and non-concave regions. The maximization option {opt difficult} should be used when the maximization log shows that the optimization algorithm has encountered a non-concave region and fails to converge. 

{pstd}
The deffault method for finding starting values has worked in many actual and simulated datasets. For difficult problems and to verify that the algorithm has converged to a global maximum, more than one set of starting values should be used. When supplying starting values, it is more effcient to use the auxiliary command {cmdab:zicen0}. {cmdab:zicen0} does not have a programmed algorithm for choosing starting values; otherwise, it is identical to {cmdab:zicen}. Without good starting values, it is possible that models will not converge.  

{marker post}{...}
{title:Postestimation syntax}

{p 8 17 2}
{cmdab:predict} {dtype} {newvar} {ifin} [{cmd:,} {opt eq:uation(name)} {opt pos:terior} {opt pr:ob} {opt ys:tar}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{synopt:{opt eq:uation(name)}}specifies for which class to obtain a prediction: eq1 or eq2{p_end}
{synopt:{opt pos:terior}}calculates the posterior probability of belonging to the class corresponding to equation(name) option. Note that posterior probabilities require that the outcome is observed.{p_end}
{synopt:{opt pr:ob}}calculates the estimated probability of belonging to the class corresponding to equation(name) option. Note that estimated probabilities do not use the outcome variable.{p_end}
{synopt:{opt ys:tar}}calculates censored predictions for the Tobit components. To obtain predicted values of the latent outcome, use only option {opt equation}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Note: If no option is specified, the prediction corresponds to the weighted expected value (sum of mean predictions by class weighted by estimated mixture 
probabilities).  

{marker lc}{...}
{title:Syntax for postestimation command zicenlc}

{p 8 17 2}
{cmdab:zicenlc} {newvar} {ifin} [{cmd:,} class prediction]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{synopt:{opt cla:ss}}based on the highest posterior probability, assings each observation to a class{p_end}
{synopt:{opt pre:diction}}calculates censored predicted values conditional on posterior class membership{p_end}
{synoptline}
{p2colreset}{...}

{marker remarks}{...}
{title:zicenlc}

{pstd}
{cmd:zicenlc} is provided for convenience as it calculates postestimation predictions and classifications that can be
done using {cmdab:predict} and additional coding. {cmdab:zicenlc} classifies observations into classes using the highest posterior 
probability of class membership. It also provides censored predictions conditional on class membership. {cmd:zicenlc} requieres the outcome variable to calculate posterior probabilities.  

{marker lc}{...}
{title:Syntax for postestimation command zicenec}

{p 8 17 2}
{cmdab:zicenec} {newvar} {ifin} [{cmd:,} class prediction]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{synopt:{opt cla:ss}}based on the highest estimated probability, assigns each observation to a class{p_end}
{synopt:{opt pre:diction}}calculates censored predicted values conditional on estimated class membership{p_end}
{synoptline}
{p2colreset}{...}

{marker remarks}{...}
{title:zicenec}

{pstd}
{cmd:zicenec} is similar to {cmdab:zicenlc} but instead of using posterior probabilities to classify observations into classes it uses the estimated probabilities. {cmd:zicenec} does not use the outcome to calculate predicted mixture probabilities. For models with constant mixture probabilities (i.e. models with no covariates explaining the mixture probabilities), all observations are classified into one class. {cmd:zicenec} is intented to be used after estimating models with non-constant mixture probabilities. If covariates do not produce enough variability in the mixture probabilities, all observations may be classified into the same class.    

{marker options}{...}
{title:Options for zicen}

{dlgtab:Main}

{phang}
{opt classes(#)} Can be either 2 or 3. If 2, a mixture model of a degenerate distribution with mass at zero and a censored
normal is estimated. If 3, another censored normal class is assumed.

{phang}
{opt probability(varlist)} specifies a list of predictors for the mixture probabilities. It accepts factor variable
syntax. 


{marker remarks}{...}
{title:Remarks}

{pstd}
For details about {cmdab:zicen} and some of its applications, see Marcelo Coca Perraillon M,Tina Shih, and Ronald Thisted (2014). Predicting the EQ-5D Preference Index from the SF-12 Health Survey: A Finite Mixture Approach (citation forthcoming). 

{marker examples}{...}
{title:Examples}

{phang}{cmd:. ssc desc zicen}{p_end}

{phang}{cmd:. net get zicen}{p_end}

{phang}{cmd:. use simudata.dta}{p_end}

{phang}{cmd:. zicen ymixed3c age, cl(3)}{p_end}

{phang}{cmd:. zicen ymixed3c age, prob(age) cl(3) diff}{p_end}

{phang}{cmd:. predict probpost1, pos eq(eq1)}{p_end}

{phang}{cmd:. predict probpost2, pos eq(eq2)}{p_end}

{phang}{cmd:. gen probpost0 = 1-probpost1-probpost2}{p_end}

{phang}{cmd:. predict pec1, eq(eq1) prob}{p_end}

{phang}{cmd:. predict pec2, eq(eq2) prob}{p_end}

{phang}{cmd:. gen pec0 = 1 - pec1 - pec2}{p_end}

{phang}{cmd:. sum probpost* pec*}{p_end}

{phang}{cmd:. predict yhat1, eq(eq1)}{p_end}

{phang}{cmd:. predict yhat1c, eq(eq1) ystar}{p_end}

{phang}{cmd:. sum yhat1 yhat1c}{p_end}

{phang}{cmd:. zicenlc yhat_class, pre}{p_end}

{phang}{cmd:. zicenlc pred_class, cla}{p_end}

{phang}{cmd:. zicenec yhat_class_ec, pred}{p_end}

{phang}{cmd:. zicenec pred_class_ec, cla}{p_end}

{phang}{cmd:. sum yhat_class yhat_class_ec}{p_end}

{phang}{cmd:. tab pred_class pred_class_ec, row}{p_end}

{phang}{cmd:. zicen ymixed3c age, cl(3) prob(age)}{p_end}

{phang}{cmd:. zicen ymixed3c age, cl(3) prob(age) diff technique(nr dfp bfgs)}{p_end}

{phang}{cmd:. zicen0 ymixed3c, cl(3) init(2.2 14.1 -.60 -.62 .23 1.6,copy) search(off)}{p_end}

















