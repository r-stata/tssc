{smcl}
{* 10.01.2012}{...}
help {hi:setpoisson}

{hline}

{title:Title}

{p 8 12 2} Selection Endogenous Treatment Poisson Model by MSL

{title:Basic syntax}

{p 8 12 2}{cmd:setpoisson} ({it:Tvar} = {it:varlist1}) ({it:Pvar} = {it:varlist2}) ({it:cvar} = {it:varlist3}) [{cmd:if}
{it:exp}] [{cmd:in} {it:range}]{cmd:,} {cmd:rep(#)} {break} {cmdab:hvec:tor}(# # #){p_end} 

{title:Full syntax}

{p 8 12 2}{cmd:setpoisson} ({it:Tvar} = {it:varlist1}) ({it:Pvar} = {it:varlist2}) ({it:cvar} = {it:varlist13}) [{cmd:if}
{it:exp}] [{cmd:in} {it:range}]{cmd:,} {cmd:rep(#)} {break} {cmdab:hvec:tor}(# # #) {cmdab:meth:od}(#) {cmd:cluster}({it:clustvar}) {cmdab:constr:aints}({it:clist}) {cmdab:tr:ace} {cmdab:rob:ust} {cmdab:hb:ased} {cmd:mloptions}{p_end} 

{marker options}{...}
{synopthdr:options}
{synoptline}
{p2coldent : {opt rep(#)}} Sets the number of random draws that will be used for calculating the simulated likelihood. {p_end}
{p2coldent : {opt hvec:tor(# # #)}} Controls aspects of the simulation, all three numbers must be integers. The first number sets the number of {bf:columns} that the vector of random draws will have. 
The second number picks one column. Finally, the third number sets the number of {bf:rows} -from the top row onwards- to be discarded from the chosen column. For instance, {opt rep(400)} {opt hvec(2 1 100)} asks for a 500x2 random vector, 
 to take the first column and to discard the 
first 100 rows. The resulting 400x1 vector is used for simulating the likelihood. {p_end}
{p2coldent :  {cmdab:meth:od}(#)} Type of random draws to be used for simulating the likelihood. Option 1 is the default and indicates that Halton sequences shall be used. Option 2 indicates that a Hammersley set should be used. 
Finally, option 3 indicates that  pseudouniform random numbers should be used. {p_end}
{p2coldent : {cmdab:rob:ust}} The Eicker-Huber-White (sandwich) estimator of the covariance matrix is reported. This option is  only valid when used together with the {opt habased} option.{p_end}
{p2coldent : {cmdab:hb:ased}} Maximisation will be performed using analytical first derivatives and numerical second derivatives. {p_end}
{p2coldent : {cmd:cluster}({it:clustvar})} Clustered sandwich estimator of the covariance matrix. This option must be used together with the the {opt habased} option. {p_end}
{p2coldent : {cmdab:constr:aints}({it:clist})} Specifies constraints in the usual way.{p_end}
{p2coldent : {cmdab:trace}} Trace.{p_end}
{p2coldent : {cmdab:mloptions}} Usual mloptions.{p_end}

{title:Description}

{p 4 4 2}
{cmd:setpoisson} fits a Selection Endogenous Treatment Poisson model for count data by Maximum Simulated Likelihood.{p_end}

{title:Important notes}

{p 4 4 2} The equation for the treatment variable {it:Tvar} always comes first, then the equation for the selection dummy {it:Pvar}, and finally the equation for the main count outcome variable {it:cvar}. This order should be always observed, 
otherwise the model will not be correctly estimated or it will produce an error message.

{p 4 4 2} By default the model is fitted by the BHHH method, using analytical first derivatives and an outer product gradient (OPG) approximation of the covariance matrix. The {opt hbased} option modifies this default behaviour.{p_end}

{p 4 4 2} Simulations conducted by the author show that using less than 1,000 delivers slightly underestimated standard errors and that the coverage of the parameters is below the advertised 95%. For these reasons I strongly recommend 
using at least 1,000 Halton draws to simulate the likelihood.{p_end}

{p 4 4 2} If Stata is stopped during maximisation for any reason you'll need to drop all macros that are created by petpoisson, otherwise you'll see an error message. In that instance type:{p_end} 
{p 8 4 2} . mac drop S_s* S_cat S_x* S_n* S_eqs S_e* S_r* S_i*{p_end}


{title:Examples}

{p 4 8 2} . use setpoisson_sdata.dta {p_end}

{p 4 8 2} . setpoisson (T = x1) (P = T x2) (count = T x3), rep(1600) hvec(1 1 100) {p_end}

{p 4 8 2} . setpoisson (T = x1) (P = T x2) (count = T x3), rep(1600) hvec(1 1 100) hbased {p_end}

{title:Marginal effects after estimation}

{p 4 8 2} /* At the mean of explanatory variables */ {p_end}
{p 4 8 2} . setpoisson_me [{cmd:if} {it:exp}] [{cmd:in} {it:exp}]  {p_end}

{p 4 8 2} /* MEs at the mode of explanatory variables */{p_end}
{p 4 8 2} . setpoisson_me, dmode {p_end}

{p 4 8 2} /* MEs at the # quantile of the linear predictor */{p_end}
{p 4 8 2} . setpoisson_me, XBQuantile(0.3)  {p_end}

{p 4 8 2} /* ME for T when count is 2 (v.g. mode of main count) */{p_end}
{p 4 8 2} . setpoisson_me, cmode(T 2)  {p_end}

{title: Author}

{p 4 13 2}
Alfonso Miranda (A.Miranda@ioe.ac.uk) as part of join work with Massimiliano Bratti.{p_end}

{title: Conditions of use}

{p 4 4 2} {cmd: setpoisson} is not an official Stata command and is an implementation of the methods discussed in Bratti and Miranda (2011). There is no warranty and the author cannot accept any responsability for the use of this software. 
The entire risk as to the quality and performance is with you. 
Should the work prove defective, you assume the cost of all necessary servicing, repair, or correction. You may distribute a complete, unmodified copy of this sofware as you received it. 
No modification or partial copy is allowed. Both the software and the main paper should be cited together.{p_end}

{title: Suggested citation}

{p 4 13 2} Please cite as:{p_end}

{p 8 13 2} Miranda, A. 2012. setpoisson: Stata module (Mata) to estimate a Selection Endogenous Treatment Poisson Model by MSLL. Available at {browse "http://ideas.repec.org/e/pmi55.html"}.{p_end}

{p 8 13 2} Bratti, M. and Miranda, A. 2011. Endogenous treatment effects for count data models with endogenous participation or sample selection.{it: Health Economics} 20 (9):1090-1109. Available at {break} 
{browse "http://onlinelibrary.wiley.com/doi/10.1002/hec.1764/abstract"}.{p_end}


{p 4 4 2} Sofware and paper should be cited together. A copy of the paper is available from the author upon request.{p_end}

{title:Webpage}

{p 4 13 2}
{browse "http://ideas.repec.org/e/pmi55.html"}{p_end}


