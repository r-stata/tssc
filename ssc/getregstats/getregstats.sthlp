{smcl}
{* *! version 1.1.0 01may2019}{...}
{* *! version 1.0.0 28apr2019}{...}
{title:Title}

{p2colset 5 20 21 2}{...}
{p2col:{hi:getregstats} {hline 2}} Computes all values in a regression table when only the coefficient and one other statistic is available {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:getregstats}
{it: #b}
[{cmd:,}
{opt mod:el(string)}
{opt se(#)}
{opt df(#)}
{opt z:stat(#)}
{opt p:val(#)}
{opt l:cl(#)}
{opt u:cl(#)}
{opt lev:el(#)}
]

{pstd}
{it:#b} can be specified as a coefficient or exponentiated value (e.g. OR, HR, IRR)


{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt mod:el(string)}}specifies model type that produced the estimates. Choices are "lin", "exp", "or", "hr", "irr", "rr", or "rd"; default is {cmd:mod(lin)} {p_end}
{p2coldent:* {opt se(#)}}specifies the standard error of the estimate {p_end}
{synopt:{opt df(#)}}specifies the degrees of freedom if {it:#b} is t-distributed (e.g. when using {helpb regress} to produce estimates){p_end}
{p2coldent:* {opt z:stat(#)}}specifies the z-statistic (or t-statistic when used in conjunction with {cmd:df}){p_end}
{p2coldent:* {opt p:val(#)}}specifies the p-value{p_end}
{p2coldent:* {opt l:cl(#)}}specifies the lower confidence limit{p_end}
{p2coldent:* {opt u:cl(#)}}specifies the upper confidence limit{p_end}
{synopt:{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p 4 6 2}* one of these values must be specified.{p_end}



{title:Description}

{pstd}
{opt getregstats} computes all the statistics reported in a regression table when the user specifies the coefficient and one other statistic. 
This is useful in situations when a minimal amount of information is available, such as values reported in a journal article, or when
those statistics are not naturally provided by some other commands in Stata, such as {helpb csi}. 

{pstd}
{opt getregstats} is an immediate command, see {helpb immed}.



{title:Remarks}

{pstd}
Regression models produce either linear coefficients {it:(b)} or those coefficients transformed via exponentiation {it:exp(b)} 
(which are presented as odds ratios, hazard ratios, relative risks, etc.). As such, specifying {opt model(lin)} will produce
estimates from any model that produces linear coefficients, and specifying {opt model(exp)} will produce
estimates from any model that produces exponentiated coefficients. All other options in {opt model()} serve only to provide 
a more specific descriptor for the user-provided {it:(b)} or {it:exp(b)} value.



{title:Options}

{p 4 8 2}
{cmd:model(}{it:#}{cmd:)} specifies the model type that produced the estimates. {cmd: model()} choices are "lin","exp", "or", "hr", "irr", "rr", or "rd", 
which represent the following models, accordingly: linear, exponentiated, odds ratio, hazard ratio, incidence-rate ratio, risk ratio, risk difference; 
{cmd: default is mod(lin)}.

{p 4 8 2}
{cmd:se(}{it:#}{cmd:)} specifies the standard error of the estimate.

{p 4 8 2}
{cmd:df(}{it:#}{cmd:)} specifies the degrees of freedom if {it:#b} is t-distributed (e.g. when using {helpb regress} to compute estimates). 

{p 4 8 2}
{cmd:zstat(}{it:#}{cmd:)} specifies the z-statistic associated with the {it:#b}. However, when {cmd:df()} is specified, {cmd:zstat()} represents the t-statistic, 
and is reported in the table as such.

{p 4 8 2}
{cmd:pval(}{it:#}{cmd:)} specifies the p-value.

{p 4 8 2}
{cmd:lcl(}{it:#}{cmd:)} specifies the lower confidence limit.

{p 4 8 2}
{cmd:ucl(}{it:#}{cmd:)} specifies the upper confidence limit.

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.



{title:Examples: linear regression}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "sysuse auto": . sysuse auto}} {p_end}

{pmore}Fit a linear regression with {helpb regress}{p_end}
{pmore2}{bf:{stata "regress mpg foreign weight": . regress mpg foreign weight}} {p_end}

{pmore}Use {opt getregstats} to reproduce all estimates for {it:foreign}, specifying only {opt se()}. As {helpb regress} provides estimates assuming
the t-distribution, we also specify {opt df(71)} to reproduce these results. {p_end}
{pmore2}{bf:{stata "getregstats -1.6500291, se(1.0759941) df(71)": . getregstats -1.6500291, se(1.0759941) df(71)}} {p_end}

{pmore}Fit the same model using {helpb glm}, which assumes the z-distribution{p_end}
{pmore2}{bf:{stata "glm mpg foreign weight": . glm mpg foreign weight}} {p_end}

{pmore}Reproduce all estimates for {it:foreign}, specifying only {opt zstat()} (note that we do not specify {opt df()}). {p_end}
{pmore2}{bf:{stata "getregstats -1.6500291, z(-1.5334927)": . getregstats -1.6500291, z(-1.5334927)}} {p_end}

{pmore}Reproduce estimates for {it:foreign} after re-estimating model using {helpb regress} with {opt eform()} option. {p_end}
{pmore2}{bf:{stata "regress mpg foreign weight, eform(Exp. Coef.)": . regress mpg foreign weight, eform(Exp. Coef.)}} {p_end}
{pmore2}{bf:{stata "getregstats .1920443, se(.20663856) df(71) mod(exp)": . getregstats .1920443, se(.20663856) df(71) mod(exp)}} {p_end}


{title:Example: logistic regression}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "webuse lbw": . webuse lbw}} {p_end}

{pmore}Fit a logistic regression model with {helpb logistic}{p_end}
{pmore2}{bf:{stata "logistic low age lwt i.race smoke ptl ht ui": . logistic low age lwt i.race smoke ptl ht ui}} {p_end}

{pmore}Reproduce all estimates for {it:age}, specifying {opt p()}. We also specify that the model produces odds ratios. {p_end}
{pmore2}{bf:{stata "getregstats .97326361, p(.45718868) mod(or)": . getregstats .97326361, p(.45718868) mod(or)}} {p_end}

{pmore}Same as above, but specifying that the model produces exponentiated coefficients (produces exactly the same results). {p_end}
{pmore2}{bf:{stata "getregstats .97326361, p(.45718868) mod(exp)": . getregstats .97326361, p(.45718868) mod(exp)}} {p_end}

{pmore}Refit the logistic regression model, specifying now that the results be report as estimated coefficients.{p_end}
{pmore2}{bf:{stata "logistic low age lwt i.race smoke ptl ht ui, coef": . logistic low age lwt i.race smoke ptl ht ui, coef}} {p_end}

{pmore}Reproduce all estimates for {it:age}, specifying {opt p()}. We now specify that the model produces linear coefficients. {p_end}
{pmore2}{bf:{stata "getregstats -.0271003, p(.45718868) mod(lin)": . getregstats -.0271003, p(.45718868) mod(lin)}} {p_end}


{title:Example: Poisson regression}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "webuse dollhill3": . webuse dollhill3}} {p_end}

{pmore}Fit a Poisson regression model with incidence-rate ratios, using {helpb poisson}{p_end}
{pmore2}{bf:{stata "poisson deaths smokes i.agecat, exposure(pyears) irr": . poisson deaths smokes i.agecat, exposure(pyears) irr}} {p_end}

{pmore}Reproduce all estimates for {it:smokes}, specifying {opt lcl()}. We also specify that the model produces IRRs. {p_end}
{pmore2}{bf:{stata "getregstats 1.4255185, lcl(1.1549837) mod(irr)": . getregstats 1.4255185, lcl(1.1549837) mod(irr)}} {p_end}

{pmore}Refit the Poisson regression model with the results being report as estimated coefficients.{p_end}
{pmore2}{bf:{stata "poisson deaths smokes i.agecat, exposure(pyears)": . poisson deaths smokes i.agecat, exposure(pyears)}} {p_end}

{pmore}Reproduce all estimates for {it:smokes}, specifying {opt lcl()}. We now specify that the model produces linear coefficients. {p_end}
{pmore2}{bf:{stata "getregstats .3545356, lcl(.14408623) mod(lin)": . getregstats .3545356, lcl(.14408623) mod(lin)}} {p_end}


{title:Example: Cox regression}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "webuse drugtr": . webuse drugtr}} {p_end}

{pmore}Fit a Cox proportional hazards model, using {helpb stcox}{p_end}
{pmore2}{bf:{stata "stcox drug age": . stcox drug age}} {p_end}

{pmore}Reproduce all estimates for {it:drug}, specifying {opt ucl()}. We also specify that the model produces HRs. {p_end}
{pmore2}{bf:{stata "getregstats .10487721, ucl(.25576221) mod(hr)": . getregstats .10487721, ucl(.25576221) mod(hr)}} {p_end}

{pmore}Refit the Cox proportional hazards model with the results being report as estimated coefficients.{p_end}
{pmore2}{bf:{stata "stcox drug age, nohr": . stcox drug age, nohr}} {p_end}

{pmore}Reproduce all estimates for {it:drug}, specifying {opt ucl()}. We now specify that the model produces linear coefficients. {p_end}
{pmore2}{bf:{stata "getregstats -2.254965, ucl(-1.3635071) mod(lin)": . getregstats -2.254965, ucl(-1.3635071) mod(lin)}} {p_end}


{title:Examples: Tables for epidemiologists}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "webuse csxmpl": . webuse csxmpl}} {p_end}

{pmore}Calculate risk differences, risk ratios, etc., using {helpb cs}{p_end}
{pmore2}{bf:{stata "cs case exp [fw=pop], or woolf": . cs case exp [fw=pop], or woolf}} {p_end}

{pmore}Produce all estimates for the {opt risk difference}, specifying {opt lcl()}. We also specify that the model is an RD. {p_end}
{pmore2}{bf:{stata "getregstats -.4196429, lcl(-.7240828) mod(rd)": . getregstats -.4196429, lcl(-.7240828) mod(rd)}} {p_end}

{pmore}Produce all estimates for the {opt risk ratio}, specifying {opt lcl()}. We also specify that the model is an RR. {p_end}
{pmore2}{bf:{stata "getregstats .5104167, lcl(.2814332) mod(rr)": . getregstats .5104167, lcl(.2814332) mod(rr)}} {p_end}

{pmore}Produce all estimates for the {opt odds ratio}, specifying {opt lcl()}. We also specify that the model is an OR. {p_end}
{pmore2}{bf:{stata "getregstats .1296296, lcl(.0215685) mod(or)": . getregstats .1296296, lcl(.0215685) mod(or)}} {p_end}



{title:Stored results}

{pstd}
{cmd:getregstats} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(b)}}coefficient (or exponentiated coefficient) as entered by user{p_end}
{synopt:{cmd:r(se)}}standard error{p_end}
{synopt:{cmd:r(z)}}z or t statistic (depending on model){p_end}
{synopt:{cmd:r(pval)}}p-value{p_end}
{synopt:{cmd:r(lcl)}}lower confidence limit{p_end}
{synopt:{cmd:r(ucl)}}upper confidence limit{p_end}
{p2colreset}{...}



{marker citation}{title:Citation of {cmd:getregstats}}

{p 4 8 2}{cmd:getregstats} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). GETREGSTATS: Stata module for computing all values in a regression table when only the coefficient and one other statistic is available.
Statistical Software Components, Boston College Department of Economics.



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb regress}, {helpb glm}, {helpb poisson}, {helpb logistic}, {helpb binreg}, {helpb stcox}, {helpb cs} {p_end}

