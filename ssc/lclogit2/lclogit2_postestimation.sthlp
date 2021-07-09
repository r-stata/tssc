{smcl}
{* 09Nov2019}
{cmd:help lclogit2 postestimation}{right:}
{hline}

{title:Title}

{p2colset 5 32 35 2}{...}
{p2col :{hi:lclogit2 postestimation} {hline 2}}Postestimation tools for
lclogit2 and lclogitml2{p_end}
{p2colreset}{...}

{title:Description}

{p 4 4 2}{helpb lclogit2 postestimation##lclogitpr2:lclogitpr2} predicts the probabilities of choice and class membership after {cmd:lclogit2} or {cmd:lclogitml2}.
{p2colreset}{...}

{p 4 4 2}{helpb lclogit2 postestimation##lclogitcov2:lclogitcov2} predicts the implied covariances of choice model coefficients after {cmd:lclogit2} or {cmd:lclogitml2}.
{p2colreset}{...}

{p 4 4 2}{helpb lclogit2 postestimation##lclogitwtp2:lclogitwtp2} derives the ratios of coefficients, often called the willingness-to-pay (WTP), after {cmd:lclogit2} or {cmd:lclogitml2}.
{p2colreset}{...}

{p 4 4 2}{it:Notes}: Both {cmd:lclogitpr2} and {cmd:lclogitcov2} offer the same functionalities as {cmd:lclogitpr} and {cmd:lclogitcov} of Pacifico and Yoo (2013), though internal codes have been revised.
The descriptions below borrow heavily from the help file for the latter two commands.  

{marker lclogitpr2}{...}
{title:Syntax for lclogitpr2}

{p 8 15 2}
{cmd:lclogitpr2} {dtype} {it:stubname} {ifin}
[,	{cmdab:cl:ass(}{it:{help numlist}}{cmd:)}
	{opt pr0}
	{opt pr}
	{opt up}
	{opt cp}
]

{title:Description for lclogitpr2}

{pstd}
{cmd:lclogitpr2} predicts the probabilities of choosing each alternative in a choice situation (choice probabilities hereafter), the class shares or prior probabilities of class membership 
and the posterior probabilities of class membership. The predicted probabilities are stored in a set of variables named {it:stubname}# where # refers to the relevant class number; the only exception is the unconditional choice probability as it is stored in a varable named {it:stubname}. 

{pstd}The command assumes {opt pr} when no other option is specified. 

{title:Options for lclogitpr2}

{phang}
{cmdab:class(}{it:numlist}{cmd:)} specifies the classes for which the probabilities are going to be predicted. The default setting assumes all classes.

{phang}
{opt pr0} predicts the unconditional choice probability, which equals the average of the class-specific choice probabilities weighted by the corresponding class shares. 

{phang}
{opt pr} predicts the unconditional choice probability and the choice probabilities conditional on being in particular classes. This is the default option when no other option is specified.   

{phang} 
{opt up} predicts the class shares or prior probabilities that the agent is in particular classes. They correspond to the class shares predicted by using the class memberhsip model coefficient estimates. 

{phang}
{opt cp} predicts the posterior probabilities that the agent is in particular classes taking into account her sequence of choices.
 
{marker lclogitcov2}{...}
{title:Syntax for lclogitcov2}

{p 8 15 2}
{cmd:lclogitcov2} {varlist} {ifin}
[,	{opt no:keep}
	{opt var:name(stubname)}
	{opt cov:name(stubname)}
	{opt mat:rix(name)}
]

{title:Description for lclogitcov2}

{pstd}
{cmd:lclogitcov2} predicts the implied variances and covariances of choice model coefficients using {cmd:lclogit2} or {cmd:lclogitml2} estimates. 
The underlying formula is equation (6) in Pacifico and Yoo (2013, p.627). {it:varlist} must be variables with heterogeneous coefficients, 
i.e. a subset or all of variables listed in option {cmd:rand()} of {cmd:lclogit2} or {cmd:lclogitml2}. 

{pstd}
The defaulting setting stores the predicted variances in a set of variables named var_1, var_2, ... where var_k is the predicted variance of the coefficient on the kth variable 
listed in {it:varlist}, and the predicted covariances in cov_12, cov_13, ..., cov23, ... where cov_kj is the predicted covariance between the coefficients 
on the kth variable and the jth variable in {it:varlist}. 

{pstd} 
The averages of these variance and covariances across agents (as identified by id() in {cmd:lclogit2} or {cmd:lclogitml2}) in the prediction sample are reported as a covariance matrix at the end of {cmd:lclogitcov2}'s execution.

{title:Options for lclogitcov2}

{phang}
{opt nokeep} drops the predicted variances and covariances from the data set at the end of the command's execution. The average covariance matrix is still displayed.

{phang}
{opt varname(stubname)} requests the predicted variances to be stored as {it:stubname}1,{it:stubname}2,....

{phang}
{opt covname(stubname)} requests the predicted covariances to be stored as {it:stubname}12,{it:stubname}13,....

{phang}
{opt matrix(name)} stores the reported average covariance matrix in a Stata matrix called {it:name}. 

{marker lclogitwtp2}{...}
{title:Syntax for lclogitwtp2}

{p 8 15 2}
{cmd:lclogitwtp2}, {cmdab:income(}{varname}{cmd:)}
[,	{opt nonlc:om}
	{it:{help nlcom:options_for_nlcom}}]
]

{p 8 15 2}
{cmd:lclogitwtp2}, {cmdab:cost(}{varname}{cmd:)}
[,	{opt nonlc:om}
	{it:{help nlcom:options_for_nlcom}}]
]

{title:Description for lclogitwtp2}

{pstd}
{cmd:lclogitwtp2} calculates the usual measures of willingness-to-pay (WTP), using active {cmd:lclogit2} or {cmd:lclogitml2} results for the choice model component 
(i.e. results that are unrelated to the membership function). The WTP measures will be reported in a default table formatted like an {cmd:lclogit2} output table. 
When {cmd:lclogitml2} results are active, {cmd:lclogitwtp2} will use {helpb nlcom} to derive standard errors and confidence intervals associated with the WTP measures; 
the {cmd:nlcom} results will be presented after the default output table.
 
{pstd}
To derive the WTP for an independent variable in the choice model, {cmd:lclogitwtp2} takes the ratio of the coefficient on that variable to the coefficient on {it:varname} in 
{cmdab:income(}{varname}{cmd:)}, or alternatively to -1 times the coefficient on {it:varname} in {cmdab:cost(}{varname}{cmd:)}. Provided that the choice model's index function 
is linear in {it:varname}, the denominator can be interpreted as the marginal utility of money, allowing the ratio to be interpreted as WTP. Both the numerator and denominator 
will use the coefficients estimated for the same class. 

{title:Options for lclogitwtp2}

{phang}
{cmdab:income(}{it:varname}{cmd:)} or {cmdab:cost(}{it:varname}{cmd:)} is required. The former option should be used when the coefficient on {it:varname} is positive and 
can be interpreted as the marginal utility of money. The latter option should be used when the coefficient on {it:varname} is negative and -1 times that coefficient 
can be interpreted as the marginal utility of money. 

{phang}
{opt nonlcom} requests the {cmd:nlcom} step to be skipped. This option is relevant only when {cmd:lclogitml2} results are active.

{phang}
{it:options_for_nlcom} specifies options to be applied when executing {cmd:nlcom}. See {helpb nlcom}. This option is relevant only when {cmd:lclogitml2} results are active.
Perhaps the most useful option is {cmd:post}, which stores the {cmd:nlcom} results in {cmd:e()}, allowing the researcher to use {helpb test} to carry out 
single and joint hypothesis tests on the WTP measures.

{title:Saved results for lclogitwtp2}

{pstd}
{cmd:lclogitwtp2} saves the following in {cmd:r()}: 

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(WTP_rand)}}WTP measures that vary across classes{p_end}
{synopt:{cmd:r(WTP_fix)}}WTP measures that do not vary across classes{p_end}

{title:Reference}

{phang}Pacifico, D. and H. Yoo, 2013. {browse "https://www.stata-journal.com/article.html?article=st0312":lclogit: A Stata command for fitting latent-class conditional logit models via the expectation-maximization algorithm}, Stata Journal 13, 625-639.

{title:Author}

{pstd} Hong Il Yoo (h.i.yoo@durham.ac.uk): Durham University Business School, United Kingdom. {p_end} 

{title:Also see}

{psee}
{helpb lclogit2}, {helpb lclogitml2}, {helpb nlcom}, {helpb lclogitpr} (if installed), {helpb lclogitcov} (if installed) {p_end}
