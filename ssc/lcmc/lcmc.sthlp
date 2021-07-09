{smcl}
{* 06.05.2013}{...}
help {hi:lcmc}

{hline}

{title:Title}

{p 8 12 2} Latent class missing covariate model for continous main response, ordinal covariate with missing values, and informative selection

{title:Basic syntax}

{p 8 12 2}{cmd:lcmc} ({it:svar} = {it:varlist1}) ({it:yvar} = {it:varlist2}) ({it:mcvvar} = {it:varlist3}) [{cmd:if}
{it:exp}] [{cmd:in} {it:range}] {p_end} 

{title:Full syntax}

{p 8 12 2}{cmd:lcmc} ({it:svar} = {it:varlist1}) ({it:yvar} = {it:varlist2}) ({it:mcvvar} = {it:varlist3}) [{cmd:if}
{it:exp}] [{cmd:in} {it:range}] [{cmd:,} {cmd:rep(#)}  {cmdab:sc:ale}(#) {cmdab:hvec:tor}(# # #) {cmdab:meth:od}(#) 
 {cmdab:from}({it:matrixname})  {cmd:cluster}({it:clustvar}) 
 {cmdab:constr:aints}({it:clist}) {cmdab:thres:ctr} {cmdab:hb:ased} {cmdab:tr:ace} 
 {cmdab:eval:uate} {cmdab:rob:ust} {cmdab:iter:ate}(#) {cmd:mloptions}]{p_end} 

{p 0 0 2} The first equation defines the model for the selection dummy, the second equation defines the model for the main continous response, and the third equation definies the model for the missing ordinal covariate (see description). {p_end}

{marker options}{...}
{synopthdr:options}
{synoptline}
{p2coldent : {opt rep(#)} } Sets the number of random draws that will be used for calculating the simulated likelihood. The default value is 1600. {p_end}
{p2coldent : {opt scale(#)}} Sets the standard deviation of the error terms uy, ux, and us in equation 4 of Miranda & Rabe-Hesketh (2014). The default 
value is 0.2. {p_end}
{p2coldent : {opt hvec:tor(# # # #)}} Controls aspects of the simulation, all four numbers must be integers. Two random vectors of size N 
are needed to perform the simulation of the likelihood. These two vectors are chosen from a random NxQ matrix, Q>=2. The first number 
of {opt hvec} sets Q while the second and third numbers indicate which columns will be used to simulate the likelihood. Finally, the third 
number sets the number of rows -from the top row onwards- to be 
discarded from the chosen columns. For instance, {opt rep(500)} {opt hvec(2 1 2 100)} asks for a 500x2 random matrix, to take the 
first and second columns for the simulation of the likelihood and to discard 100 rows. The resulting 400x2 random matrix is 
used for simulating the likelihood. The default values are  {opt hvec(2 1 2 100)}.{p_end}
{p2coldent :  {cmdab:meth:od}(#)} Type of random draws to be used for simulating the likelihood. Option 1 indicates that Halton sequences shall be used. Option 2 indicates that a Hammersley set should be used. 
Finally, option 3 indicates that  pseudouniform random numbers should be used. The default value is 1.{p_end}
{p2coldent : {cmdab:from}({it:matname})} Specifies the matrix to be used for the initial values. The matrix may be obtained from a previous 
estimation command using e(b). This is useful if the model was first estimated constraining the thresholds to be 
cut1<cut2<...<cutg using the {opt thresctr} option.{p_end}
{p2coldent : {cmd:cluster}({it:clustvar})} Clustered sandwich estimator of the covariance matrix. This option must be used together with the the {opt habased} option. {p_end}
{p2coldent : {cmdab:constr:aints}({it:clist})} Specifies the linear constraints to be applied during estimation.  The
   default is to perform unconstrained estimation. Constraints are defined using the constraint command; see {help constraint}.{p_end} 
{p2coldent : {cmdab:thres:ctr}} Causes maximisation to be performed under the constraints cut1<cut2<...<cutg.{p_end}
{p2coldent : {cmdab:hb:ased}} Maximisation will be performed using analytical first derivatives and numerical second derivatives. {p_end}
{p2coldent : {cmdab:trace}} To show details including the parameter estimates at each iteration.{p_end}
{p2coldent : {cmdab:eval:uate}} Causes the program to simply evaluate the log-likelihood for values passed
   to it using the {opt from(matrix)} option and to calculate the corresponding standard errors.{p_end}
{p2coldent : {cmdab:rob:ust}} The Eicker-Huber-White (sandwich) estimator of the covariance matrix is reported. This option is  only valid when used together with the {opt habased} option.{p_end}
{p2coldent : {cmdab:iter:ate}(#)} Perform maximum of # iterations; default is iterate(16000).{p_end}
{p2coldent : {cmdab:mloptions}} Usual {help ml} {help maximize: maximize} options.{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{cmd:lcmc} fits a latent class model for a missing ordinal covariate, {it:mcv}, and a continuous main response, {it:y}, by 
Simulated Maximum Likelihood. For a proportion of the sample the missing covariate {it:mcv} is missing at random due to 
survey design because the relevant question was not asked by the survey, while for the remainder of the sample the 
relevant question was indeed asked or intended to be asked and the missing covariate is missing due to either 
unit or item non-response. There is a selection rule {it:s} that determines whether {it:mcv} is observed. 
For observations with {it:mcv} missing at random due to survey design we define {it:s = .} because we 
do not know if {it:mcv} would be observed had the relevant question been asked by the survey. For 
observations where the relevant question was asked, {it:mcv} is observed when {it: s = 1} and 
is missing when {it: s = 0}. Informative selection is allowed (i.e. the selection dummy, when not missing, can be a
function of unobservables that are correlated with y and/or mcv). {p_end}

{title:Important notes}

{p 4 4 2} lcmc assumes that the data is in the wide form (one record per individual). 

{p 4 4 2} The equation for the selection variable {it:svar} always comes first, then the equation for the 
main continous response {it:yvar}, and finally the equation for the missing ordinal covariate {it:mcvvar}. 
This order should be always observed. Otherwise the model will not be correctly estimated or it 
will produce an error message.{p_end}

{p 4 4 2} By default the model is fitted by the BHHH method, using analytical first derivatives and an outer product gradient (OPG) approximation of the covariance matrix. The {opt hbased} option modifies this default behaviour.{p_end}

{p 4 4 2} Simulations conducted by the authors show that using less than 1,600 Halton draws delivers slightly 
 underestimated standard errors and improve with more Halton draws. However, coverage of the confidence intervals 
 tends to be close to the nominal level even with 800 Halton draws.{p_end}

{title:Example}

{p 6 8 2} . lcmcsimul.dta {p_end}

{p 6 8 2} /* fit latent class missing covariate model with threshold constraints */ {p_end}
{p 6 8 2} . lcmc  (sel = x2 d1 d2 d3) (y = x3 d1 d2 d3) (ordx1 = x4 d1 d2 d3),  thresctr {p_end}
{p 6 8 2} . mat b0=e(b) {p_end}

{p 6 8 2} /* Fit the latent class missing covariate model with no constraints */{p_end}
{p 6 8 2} . lcmc (sel = x2 d1 d2 d3) (y = x3 d1 d2 d3) (ordx1 = x4 d1 d2 d3), from(b0) {p_end}

{title: Obtaining fitted values for the main response after lcmc}

{p 4 4 2} After estimation it is possible to get fitted values for the main response for all observations (i.e. for both those with missing and not missing ordinal covariate) using the lcmc_predict command:

{p 8 4 2}  lcmc_predict, rep(1600) hvec(2 1 2 100) {p_end}

{p 4 4 2} the fitted values are returned in a variable called {it: yhat}. Standard errors for {it: yhat} are also reported on variable {it: seyhat}. Finally, posterior probabilities that the missing ordinal covariate, {it: mcv}, takes on 
categories {it: 1, 2,...,G} given covariates, are reported in variables {it: P1, P2,...,PG}. These conditional probabilities are only calculated for observations for which {it: mcv} is missing.{p_end}

{title: Authors}

{p 4 13 2}
Alfonso Miranda (alfonso.miranda@cide.edu) and Sophia Rabe-Hesketh (sophiarh@berkeley.edu).{p_end}

{title: Conditions of use}

{p 4 4 2} {cmd: lcmc} is not an official Stata command and is an implementation of the methods discussed in Miranda and Rabe-Hesketh (2014). 
There is no warranty and the authors cannot accept any responsability for the use of this software. The entire risk as to the quality 
and performance is with you. Should the work prove defective, you assume the cost of all necessary servicing, repair, 
or correction. You may distribute a complete, unmodified copy of this sofware as you received it. No modification or partial 
copy is allowed. {bf:Software and main paper (JRSSA) should be cited together at all times}.{p_end}

{title: Suggested citation}

{p 4 13 2} Please cite as:{p_end}

{p 8 13 2} Miranda, A. 2013. lcmc: Stata module (Mata) to estimate a latent class missing covariate model for continous main response, 
ordinal covariate with missing values, and informative selection. Available at {browse "http://ideas.repec.org/e/pmi55.html"}.{p_end}

{p 8 13 2} Miranda, A. and Rabe-Hesketh, S. 2014. Missing ordinal covariate with informative selection.{it: Journal of the Royal Statistical Society Series A} 177 (1):?-?.{p_end}


{p 4 4 2} A copy of the paper is available from the author upon request.{p_end}

{title:Webpage}

{p 4 13 2}
{browse "http://ideas.repec.org/e/pmi55.html"}{p_end}


