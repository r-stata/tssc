{smcl}
{* 09Nov2019/}
{cmd:help lclogit2}{right:}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:lclogit2} {hline 2}}Enhanced module to estimate latent class logit models via EM algorithm{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:lclogit2}
{depvar}
[{it:{help varlist:varlist1}}] {ifin}{cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)}
{cmdab:rand(}{it:{help varlist:varlist2}}{cmd:)}
{opt ncl:asses(#)}
[,	{cmdab:id(}{varname}{cmd:)}
    {cmdab:mem:bership(}{it:{help varlist:varlist3}}{cmd:)}
	{cmdab:const:raints(}{it:{help numlist}}{cmd:)}		
	{opt seed(#)}
	{opt iter:ate(#)}	
	{opt ltol:erance(#)}
	{opt tol:erance(#)}
	{opt tolcheck}
	{opt no:log}]
	
{p 8 15 2}
{cmd:lclogitml2}
{depvar}
[{it:{help varlist:varlist1}}] {ifin}{cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)}
{cmdab:rand(}{it:{help varlist:varlist2}}{cmd:)}
{opt ncl:asses(#)}
[,	{cmdab:id(}{varname}{cmd:)}
    {cmdab:mem:bership(}{it:{help varlist:varlist3}}{cmd:)}
	{cmdab:const:raints(}{it:{help numlist}}{cmd:)}		
	{opt seed(#)}
	{opt from(init_specs)}
	{it:{help ml##ml_noninteract_descript:noninteractive_options}}]

{title:Description}

{pstd}
{cmd:lclogit2} is an enhanced version of {cmd:lclogit} (Pacifico and Yoo, 2013), and estimates latent class conditional logit models using the Expectation-Maximization (EM) algorithm of Bhat (1997). Like its predecessor, {cmd:lclogit2} produces maximum likelihood estimates without standard errors. To obtain standard errors, users may apply {help boostrap} as Train (2008) has proposed. 
Alternatively, users may pass {cmd:lclogit2} estimates as starting values to {cmd:lclogitml2}.

{pstd}
{cmd:lclogitml2} is a parallel command that estimates latent class conditional logit models using usual optimization methods for maximum likelihood estimation. See {help maximize}.
It can be used as a standalone estimation command. It can be also used as a tool to obtain standard errors associated with existing {cmd:lclogit2} estimates, as suggested above.

{pstd}
Both {cmd:lclogit2} and {cmd:lclogitml2} are supported by postestimation commands {helpb lclogitpr2}, {helpb lclogitcov2} and {helpb lclogitwtp2}. Before applying {cmd:lclogit2} with option {cmd:membership()}, Maartin Buis's {cmd:fmlogit} ({stata findit fmlogit}) must be installed.

{pstd}
Major differences between {cmd:lclogit2} and {cmd:lclogit} are as follows.

{p 8 8 2} 1. {cmd:lclogit2} can estimate the same model considerably faster as it uses {help Mata} to execute core algebraic operations. 

{p 8 8 2} 2. {cmd:lclogit2} allows a model to include both homogeneous coefficients that remain identical across classes and heterogeneous coefficients that vary across classes.
It assumes that {it:varlist1} have homogeneous coefficients and {it:varlist2} have heterogeneous coefficients. In contrast, {cmd:lclogit} assumes that all coefficients are heterogeneous.  

{p 8 8 2} 3. {cmd:lclogit2} can incorporate linear constraints, defined in the usual manner using Stata's {help constraint} command. 
The constraints may apply within a particular class, as well as across different classes. In contrast, {cmd:lclogit} can only incorporate within-class linear constraints, 
and has its own syntax requirements for how such constraints should be defined.  

{p 8 8 2} 4. {cmd:lclogitml2} is now a standalone estimation command. In contrast, {cmd:lclogitml} accompanying {cmd:lclogit} is simply a wrapper that passes
existing {cmd:lclogit} estimates to Sophia Rabe-Hesketh's {cmd:gllamm} ({stata findit gllamm}). This difference brings about several advantages. First, {cmd:lclogitml2} 
has been coded in {help Mata}, and can estimate latent class conditional logit models considerably faster than {cmd:gllamm}. Second, {cmd:lclogitml2} can directly incorporate 
the linear constraints defined for {cmd:lclogit2}. In comparison, to impose the same constraints in {cmd:lclogit} and {cmd:lclogitml} estimation runs, users must 
define a set of constraints to satisfy the syntax requirements of {cmd:lclogit}, and translate them into another set of constraints to satisfy that of {cmd:gllamm}. 
Third, {cmd:lclogitml2} is better suited to estimating a model with a large number of heterogeneous coefficients. Suppose that the model of interest includes C classes and 
{it:varlist2} includes K variables so that there are C * K heterogeneous coefficients. In {help ml model} parlance, {cmd:lclogitml2} will add C equations where each equation 
consists of K coefficients for a particular class. In contrast, {cmd:gllamm} will add C * K equations, where each equation's intercept corresponds to a particular coefficient.
When C * K is large, a call to {cmd:gllamm} via {cmd:lclogitml} may fail with an error message stating that some equation is not found, presumably because there is a limit on 
the number of equations that {cmd:gllamm} can add to a {cmd:ml model} statement. 

{p 8 8 2} 5. {cmd:lclogit2} and {cmd:lclogitml2} are supported by a new postestimation command, {help lclogitwtp2}, that calculates the willingness-to-pay (WTP) measures implied by the estimated latent class conditional logit model. The WTP measures are the main parameters of interest in many non-market valuation studies.

{title:Options for lclogit2}

{phang}
{opth group(varname)} is required and specifies a numeric identifier variable for choice situations.

{phang}
{cmdab:rand(}{it:{help varlist:varlist2}}{cmd:)} is required and specifies independent variables whose coefficients are allowed to vary across classes. 

{phang}
{opt nclasses(#)} is required and specifies the number of latent classes.

{phang}
{opth id(varname)} specifies a numeric identifier variable for individual choice makers. If left unspecified, {cmd:lclogit2} assumes that {opth group(.)} and {opth id(.)} are identical (i.e. each choice situation was for a different choice maker). 

{phang}
{cmdab:membership(}{it:{help varlist:varlist3}}{cmd:)} specifies indepedent variables to enter the fractional multinomial logit model of class membership. These variables are assumed to be constant within a choice choice maker across all alternatives and choice situations. 

{phang}
{opth constraints(numlist)} specifies the linear constraints to be applied during estimation. The constraints must have been defined using {help constraint}. 
Equation names for coefficients on {it:varlist1} and {it:varlist2} are Fix and Class`c' respectively, where `c' refers to a particular class number. 
For example, the coefficient on {it:varname} in {it:varlist1} is [Fix]{it:varname}, and the coefficient on {it:varname} in {it:varlist2} is [Class1]{it:varname} 
for Class 1, [Class2]{it:varname} for Class 2 and so on.          

{phang}
{opt seed(#)} sets the seed for pseudo uniform random numbers used in computing starting values. The default is {cmd:c(seed)}. 

{phang}
{opt iterate(#)} specifies the maximum number of iterations. The default is 1000.

{phang}
{opt ltolerance(#)} specfies the tolerance for the log likelihood. When the proportional increase in the log likelihood over the last five iterations is less than the specified value, {cmd:lclogit2} declares convergence. The default is 0.00001.

{phang}
{opt tolcheck} requests the use of an extra convergence criterion to reduce the chance of false declaration of convergence. If this option is used, {cmd:lclogit2} will declare convergence when 
(1) the relative change in the log likelihood over the last five iterations is smaller than {opt ltolerance(#)} AND (2) the relative difference in the coefficient vector over the last five iterations
is smaller than {opt tolerance(#)}. 

{phang}
{opt tolerance(#)} specifies the tolerance for the coefficient vector. The default is 0.0004.

{phang}
{opt nolog} suppresses the display of an iteration log.  

{title:Options for lclogitml2}

In addition to options that overlap with {cmd:lclogit2}, {cmd:lclogitml2} offers the following. 

{phang}
{opth from(init_specs)} requests the use of user-supplied initial values for the coefficients. 

{phang}
{it:{help ml##ml_noninteract_descript:noninteractive_options}} specifies other extra options for use with {cmd:ml model} in noninteractive mode.

{title:Examples}

{pstd}
Consider the Huber and Train (2001) data file that has been used in {cmd:lclogit} examples. In this data file, each choice maker identified by {cmd:pid} faces 
several choice situations identified by {cmd:gid}. 

{phang2}{cmd: use http://fmwww.bc.edu/repec/bocode/t/traindata.dta, clear}{p_end}
  
{pstd}Use {cmd:lclogit2} to estimate a 4-class model, assuming all choice model coefficients are heterogeneous. Then, pass the results as starting values to {cmd:lclogitml2}.

{phang2}{cmd:. lclogit2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4)}{p_end}
{phang2}{cmd:. matrix start = e(b)}{p_end}
{phang2}{cmd:. lclogitml2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) from(start)}{p_end}

{pstd}Type {cmd:lclogit2} to display active {cmd:lclogitml2} results in an {cmd:lclogit2}-style output table. 

{phang2}{cmd:. lclogitml2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) from(start)}{p_end}
{phang2}{cmd:. lclogit2}{p_end}

{pstd}Repeat the first example, assuming that the coefficients on price is homogeneous. 

{phang2}{cmd:. lclogit2 y price, rand(contract local wknown tod seasonal) id(pid) group(gid) nclasses(4)}{p_end}
{phang2}{cmd:. matrix start = e(b)}{p_end}
{phang2}{cmd:. lclogitml2 y price, rand(contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) from(start)}{p_end}

{pstd}Repeat the first example, under two constraints: (1) Class 1 and Class 3 have the same coefficient on {cmd:contract} and (2) in Class 2, the coefficient on {cmd:local} takes the value of zero.   

{phang2}{cmd:. constraint 1 [Class1]contract = [Class3]contract}{p_end}
{phang2}{cmd:. constraint 2 [Class2]local = 0}{p_end}
{phang2}{cmd:. lclogit2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) constraints(1 2)}{p_end}
{phang2}{cmd:. matrix start = e(b)}{p_end}
{phang2}{cmd:. lclogitml2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) constraints(1 2) from(start)}{p_end}

{pstd}Switch on {cmd:tolcheck} to check convergence of the EM algorithm more carefully.

{phang2}{cmd:. lclogit2 y, rand(price contract local wknown tod seasonal) id(pid) group(gid) nclasses(4) tolcheck}{p_end}

{title:Saved results}

{pstd}
{cmd:lclogit2} and {cmd:lclogitml2} save the following in {cmd:e()}: 

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of choice situations identifed by {cmd:group()}{p_end}
{synopt:{cmd:e(N_i)}}number of choice makers identifed by {cmd:id()}{p_end}
{synopt:{cmd:e(nclasses)}}number of latent classes{p_end}
{synopt:{cmd:e(k)}}number of coefficients{p_end}
{synopt:{cmd:e(k_fix)}}number of variables in {it:varlist1}{p_end}
{synopt:{cmd:e(k_rand)}}number of variables in {it:varlist2}{p_end}
{synopt:{cmd:e(k_share)}}number of variables in {it:varlist3}{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(bic)}}Bayesian information criterion{p_end}
{synopt:{cmd:e(aic)}}Akaike information criterion{p_end}
{synopt:{cmd:e(caic)}}Consistent Akaike information criterion{p_end}
{synopt:{cmd:e(converged)}}convergence criterion is satified (=1) or not (=0){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:lclogit2}{p_end}
{synopt:{cmd:e(title)}}Model estimated via EM algorithm{p_end}
{synopt:{cmd:e(group)}}name of {cmd:group()} variable{p_end}
{synopt:{cmd:e(id)}}name of {cmd:id()} variable{p_end}
{synopt:{cmd:e(depvar)}}name of variable {it:depvar}{p_end}
{synopt:{cmd:e(indepvars_fix)}}names of variables in {it:varlist1}{p_end}
{synopt:{cmd:e(indepvars_rand)}}names of variables in {it:varlist2}{p_end}
{synopt:{cmd:e(indepvars_share)}}names of variables in {it:varlist3}{p_end}
{synopt:{cmd:e(seed)}}pseudo random number seed{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector that collects all coefficients{p_end}
{synopt:{cmd:e(b_fix)}}vector of coefficients on {it:varlist1}{p_end}
{synopt:{cmd:e(b_rand)}}vector of coefficients on {it:varlist2}{p_end}
{synopt:{cmd:e(b_share)}}vector of coefficients on {it:varlist3}{p_end}
{synopt:{cmd:e(B)}}matrix of choice model coefficients{p_end}
{synopt:{cmd:e(CMB)}}matrix of class membership model coefficients{p_end}
{synopt:{cmd:e(P)}}vector of (estimation sample average) class shares{p_end}
{synopt:{cmd:e(PB)}}vector of weighted average choice model coefficients, where weights = class shares{p_end}
{synoptset 20 tabbed}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{title:Reference}
{phang}Bhat, C., 1997. An endogenous segmentation mode choice model with an application to intercity travel. {it:Transportation Science} 31, 34-48.

{phang}Huber, J. and K. Train, 2001. On the similarity of classical and bayesian estimates of individual mean partworths. {it:Marketing Letters} 12, 259-269.

{phang}Pacifico, D. and H. Yoo, 2013. {browse "https://www.stata-journal.com/article.html?article=st0312":lclogit: A Stata command for fitting latent-class conditional logit models via the expectation-maximization algorithm}. {it:Stata Journal} 13, 625-639.

{phang}Train, K., 2008. EM Algorithms for Nonparametric Estimation of Mixing Distributions. {it:Journal of Choice Modelling} 1 (1) 40-69.

{title:Author}

{pstd} Hong Il Yoo (h.i.yoo@durham.ac.uk): Durham University Business School, United Kingdom. {p_end} 

{title:Also see}

{psee}
Online:  {helpb lclogit2_postestimation}, {helpb lclogit} (if installed), {helpb fmlogit} (if installed), {helpb mixlogit} (if installed), {helpb gllamm} (if installed) {p_end}
