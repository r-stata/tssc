{smcl}
{* 23Aug2012/}
{cmd:help lclogit postestimation}{right:}
{hline}

{title:Title}

{p2colset 5 32 35 2}{...}
{p2col :{hi:lclogit postestimation} {hline 2}}Postestimation tools for
lclogit{p_end}
{p2colreset}{...}

{title:Description}

{p 4 4 2}{helpb lclogit postestimation##lclogitpr:lclogitpr} predicts the probabilities of choice and class membership after {cmd:lclogit}.
{p2colreset}{...}

{p 4 4 2}{helpb lclogit postestimation##lclogitcov:lclogitcov} predicts the implied covariances of choice model coefficients after {cmd:lclogit}.
{p2colreset}{...}

{p 4 4 2}{helpb lclogit postestimation##lclogitml:lclogitml} passes active {cmd:lclogit} estimates to {cmd:gllamm}.
{p2colreset}{...}

{marker lclogitpr}{...}
{title:Syntax}

{p 8 15 2}
{cmd:lclogitpr} {dtype} {it:stubname} {ifin}
[,	{cmdab:cl:ass(}{it:{help numlist}}{cmd:)}
	{opt pr0}
	{opt pr}
	{opt up}
	{opt cp}
]

{title:Description}

{pstd}
{cmd:lclogitpr} predicts the probabilities of choosing each alternative in a choice situation (choice probabilities hereafter), the class shares or prior probabilities of class membership 
and the posterior probabilities of class membership. The predicted probabilities are stored in a set of variables named {it:stubname}# where # refers to the relevant class number; the only exception is the unconditional choice probability as it is stored in a varable named {it:stubname}. 

{pstd}The command assumes {opt pr} when no other option is specified. 

{title:Options for lclogitpr}

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
 
{marker lclogitcov}{...}
{title:Syntax}

{p 8 15 2}
{cmd:lclogitcov} {varlist} {ifin}
[,	{opt no:keep}
	{opt var:name(stubname)}
	{opt cov:name(stubname)}
	{opt mat:rix(name)}
]

{title:Description}

{pstd}
{cmd:lclogitcov} predicts the implied variances and covariances of choice model coefficients using {cmd:lclogit} or {cmd:lclogitml} estimates; see Hess et al. (2011) for details. They could be a useful tool for studying the underlying pattern of tastes. 

{pstd}
The defaulting setting stores the predicted variances in a set of variables named var_1, var_2, ... where var_k is the predicted variance of the coefficient on the kth variable 
listed in {it:varlist}, and the predicted covariances in cov_12, cov_13, ..., cov23, ... where cov_kj is the predicted covariance between the coefficients 
on the kth variable and the jth variable in {it:varlist}. 

{pstd} 
The averages of these variance and covariances across agents (as identified by id() in {cmd:lclogit}) in the prediction sample are reported as a covariance matrix at the end of {cmd:lclogitcov}'s execution.

{title:Options for lclogitcov}

{phang}
{opt nokeep} drops the predicted variances and covariances from the data set at the end of the command's execution. The average covariance matrix is still displayed.

{phang}
{opt varname(stubname)} requests the predicted variances to be stored as {it:stubname}1,{it:stubname}2,....

{phang}
{opt covname(stubname)} requests the predicted covariances to be stored as {it:stubname}12,{it:stubname}13,....

{phang}
{opt matrix(name)} stores the reported average covariance matrix in a Stata matrix called {it:name}. 

{marker lclogitml}{...}
{title:Syntax}

{p 8 15 2}
{cmd:lclogitml}
{ifin}
[,	{cmdab:iter:ate(}#{cmd:)}
	{cmdab:l:evel(}#{cmd:)}
	{opt nopo:st}
	{opt swit:ch}
	{it:compatible_gllamm_options}
]

{title:Description}

{pstd}
{cmd:lclogitml} is a wrapper for Sophia Rabe-Hesketh's {cmd:gllamm} ({stata findit gllamm}) which uses the {cmd:ml d0} method
to estimate generalised linear latent class and mixed models including the latent class conditional logit model. This post-estimation 
command passes active {cmd:lclogit} model specification and estimates to {cmd:gllamm}, and its primary usage mainly depends on how 
{opt iterate(#)} is specified; see below for details. 

{pstd}
The default setting relabels and transforms the {cmd: ereturn} results of {cmd: gllamm} in accordance with those of {cmd: lclogit}, before reporting and posting them. 
Users can exploit {cmd: lclogitpr} and {cmd: lclogitcov}, as well as Stata's usual post-estimation commands requiring the estimated 
covariance matrix such as {cmd: nlcom}. When {opt switch} is specified, the original {cmd: ereturn} results of {cmd: gllamm} are reported and posted; users gain access to 
{cmd:gllamm}'s post-estimation commands, but lose access to {cmd: lclogitpr} and {cmd: lclogitcov}.    

{pstd}
{cmd: lclogitml} can also be used as its own post-estimation command, for example to pass the currently active {cmd: lclogitml} results to {cmd: gllamm} for further NR iterations. 

{title:Options for lclogitml}

{phang}
{opt iterate(#)} specifies the maximum number of NR iterations for {cmd:gllamm}'s likelihood maximization process. The default is {opt iterate(0)} in which 
case the likelihood function and its derivatives are evaluated at the currently active estimates; this allows obtaining 
standard errors associated with the current estimates without {help boostrap}ping. 

{p 8 8 2}
With a non-zero argument, this option can implement a hybrid estimation strategy similar to 
(1997)'s. He executes a relatively small number of EM iterations to obtain intermediate estimates, and use them as
starting values for direct likelihood maximization via a quasi-Newton algorithm
until convergence, because the EM algorithm tends to slow down near the local maximum. Specifying a non-zero argument for
this option can also be a useful tool for checking whether {cmd: lclogit}
has declared convergence prematurely.    

{phang}
{opt level(#)} sets confidence level; default is {opt level(95)}. 

{phang}
{opt nopost} restores the currently active ereturn results at the end of the command's execution. 

{phang}
{opt switch} displays and posts the original {cmd: gllamm} estimation results, 
without relabeling and transforming them in accordance with the {cmd: lclogit} output.  

{phang} 
{it:compatible_gllamm_options} refer to {cmd:gllamm}'s estimation options which are compatible with the latent class logit model specification. See 
{help gllamm} for more information. 

{title:Saved results}

{pstd}
By default {cmd:lclogitml} saves the following in {cmd:e()}, in addition to the others listed for {cmd: lclogit} except {cmd:e(seed)}. When {opt nopost} is specified, the currently active 
{cmd: ereturn} results are restored at the end of the command's execution. When {opt switch} is specified, {cmd:lclogitml} saves the same set of results in {cmd:e()} as {cmd:gllamm}. 

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:lclogitml}{p_end}
{synopt:{cmd:e(title)}}Model estimated via GLLAMM{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{p2colreset}{...}

{title:Reference}
{phang}Bhat, C., 1997. {it:An endogenous segmentation mode choice model with an application to intercity travel}. Transportation Science 31, 34-48.

{phang}Hess, S., Ben-Akiva, M, Gopinath, D., and Walker, J. 2011. {it:Advantages of latent class over mixture of logit models}, mimeo, http://www.stephanehess.me.uk/papers/Hess_Ben-Akiva_Gopinath_Walker_May_2011.pdf.

{title:Authors}

{pstd} This command was written by Daniele Pacifico and Hong Il Yoo. Comments and suggestions are welcome. {p_end}     
{pstd} Daniele Pacifico (daniele.pacifico@tesoro.it): Italian Department of the Treasury, Italy. {p_end} 
{pstd} Hong Il Yoo (h.i.yoo@durham.ac.uk): Durham University Business School, United Kingdom. {p_end} 

{title:Also see}

{psee}
Online:  {manhelp lclogit R}, {helpb lclogit postestimation}, {helpb gllamm} {p_end}
