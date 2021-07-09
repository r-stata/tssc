{smcl}
{* 23Aug2012/}
{cmd:help lclogit}{right:}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:lclogit} {hline 2}}Latent class logit model via EM algorithm{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:lclogit}
{depvar}
[{indepvars}] {ifin}{cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)}
{cmdab:id(}{varname}{cmd:)}
{cmdab:ncl:asses(}#{cmd:)}
[,	{cmdab:mem:bership(}{varlist}{cmd:)}
	{cmdab:conv:ergence(}#{cmd:)}
	{cmdab:iter:ate(#)}
	{cmdab:const:raints(}{it:Class#1 numlist}: {it:Class#2 numlist}: ...{cmd:)}
	{opt seed(#)}
	{opt no:log}]

{title:Description}

{pstd}
{cmd:lclogit} fits latent class conditional logit models through an Expectation-Maximisation algorithm proposed in Bhat (1997) and Train (2008). The data setup is the same as for {cmd:clogit}. 

{pstd}
Note: Maartin Buis's {cmd:fmlogit} ({stata findit fmlogit}) needs to be installed before {opth membership(varlist)} is used to let the class shares depend on the choice maker's characteristics. 

{title:Options for lclogit}

{phang}
{opth group(varname)} is required and specifies a numeric identifier variable for the choice situations.

{phang}
{opth id(varname)} is required and specifies a numeric identifier variable for the choice makers or agents. With cross section data users should specify the same variable for both {opth id(varname)} and {opth group(varname)}

{phang}
{opt nclasses(#)} specifies the number of latent classes used in the estimation. A minimum of 2 latent classes is required.

{phang}
{opth membership(varlist)} specifies indepedent variables to enter the fractional multinomial logit model of class membership.  These variables are assumed to be constant across alternatives and choice occasions for 
the same agent, age and household income being typical examples.

{phang}
{opt convergence(#)} specfies the tolerance for the log likelihood. When the proportional increase in the log likelihood over the last five iterations is less than the specified criterion, lclogit declares convergence. The default is 0.00001.

{phang}
{opt iterate(#)} specifies the number of maximum iterations. The default is 150.

{phang}
{opt seed(#)} sets the seed for pseudo uniform random numbers. The default is {cmd:c(seed)}. 

{p 8 8 2}
The starting values for the taste coefficients are obtained by splitting the sample into {opt nclasses()} different subsamples and estimating a {cmd:clogit} model for each of them. During this process, a pseudo uniform random number is generated for each agent to assign the agent into a particular subsample. As for the starting values for the class shares, {cmd:lclogit} uses equal shares, i.e. 1/{opt nclasses()}.

{phang}
{cmdab:constraints(}{it:Class#1 numlist}: {it:Class#2 numlist}: ...{cmd:)} specifies {help constraint}s to be imposed on the taste coefficients of the desginated classes. For instance, suppose that 
x1 and x2 are attributes included among {it:indepvars} and the user wishes to restrict the coefficient on x1 to zero for Class3 and Class4, and the coefficient on x2 to 2 for Class4. The relevant series 
of commands would look like: 

{p 8 8 2}
{cmd:constraint} 1 x1 = 0

{p 8 8 2}
{cmd:constraint} 2 x2 = 2

{p 8 8 2}
{cmd:lclogit} 
{depvar} 
{indepvars} 
{ifin} {cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)} 
{cmdab:id(}{varname}{cmd:)} 
{cmdab:constraints(}Class3 1: Class4 1 2{cmd:)}
{opt nclasses(8)}   

{phang}
{opt nolog} suppresses the display of an iteration log.  

{title:Example}

{pstd}
Consider the following example that contains the first rows from the data used in Huber and Train (2001). 
{cmd:pid} is the agent, {cmd:gid} the choice situation, {cmd:y} the dependent variable and {cmd: contract}, {cmd:local}, {cmd:wknown}, {cmd:tod} and {cmd:seasonal} are alternative-specific attributes:

{cmd}
     pid   gid     y      price   contract   local   wknown   tod   seasonal
      1     1      0        7        5         0       1       0       0
      1     1      0        9        1         1       0       0       0
      1     1      0        0        0         0       0       0       1
      1     1      1        0        5         0       1       1       0
      1     2      0        7        0         0       1       0       0
      1     2      0        9        5         0       1       0       0
      1     2      1        0        1         1       0       1       0
      1     2      0        0        5         0       0       0       1               {txt}

	  
{pstd}
{cmd:lclogit} can be particularly useful for the nonparametric estimation of mixing distributions. 
Indeed, when the number of latent classes increases, the true mixing distribution of the coefficients can be approximated nonparametrically.

{pstd}Latent class models have been estimated via gradient-based algorithms, such as Newton-Raphson or BHHH. However, the estimation through standard optimization techniques becomes difficult when the number of parameters increases.
In this case an EM procedure could help as it requires the repeated evaluation of a function that is far easier to maximize.

{pstd}Clearly, the first goal when dealing with latent class models is to determine the optimal number of latent classes. Train (2008) bases this decision on goodness-of-fit measures such as the AIC or the BIC. 
Here we show how to determine the optimal number of latent classes using {cmd:lclogit} and the BIC:

{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/t/traindata.dta, clear}{p_end}
{phang2}{cmd:2. forvalues c=2/11{c -(}}{p_end}
{phang2}{cmd:3.		lclogit y price contract local wknown tod seasonal, id(pid) gr(gid) ncl(`c')}{p_end}
{phang2}{cmd:4. 	scalar bic_`c'=e(bic)}{p_end}
{phang2}{cmd:5. {c )-}}{p_end}
{phang2}{cmd:6. forvalues c=2/11{c -(}}{p_end}
{phang2}{cmd:7.		display bic_`c'}{p_end}
{phang2}{cmd:8. {c )-}}{p_end}

{title:Saved results}

{pstd}
{cmd:lclogit} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of choice situations identifed by {cmd:group()}{p_end}
{synopt:{cmd:e(N_i)}}number of agents identifed by {cmd:id()}{p_end}
{synopt:{cmd:e(nclasses)}}number of latent classes{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(bic)}}Bayesian information criterion{p_end}
{synopt:{cmd:e(aic)}}Akaike information criterion{p_end}
{synopt:{cmd:e(caic)}}Consistent Akaike information criterion{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:lclogit}{p_end}
{synopt:{cmd:e(title)}}Model estimated via EM algorithm{p_end}
{synopt:{cmd:e(group)}}name of {cmd:group()} variable{p_end}
{synopt:{cmd:e(id)}}name of {cmd:id()} variable{p_end}
{synopt:{cmd:e(indepvars)}}names of independent variables in the choice model{p_end}
{synopt:{cmd:e(indepvars2)}}names of independent variables in the class membership model{p_end}
{synopt:{cmd:e(seed)}}pseudo random number seed{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of taste coefficients followed by class membership model coefficients{p_end}
{synopt:{cmd:e(B)}}matrix of taste coefficients{p_end}
{synopt:{cmd:e(P)}}vector of (estimation sample average) class shares{p_end}
{synopt:{cmd:e(PB)}}vector of weighted average choice model coefficients, where weights = class shares{p_end}
{synopt:{cmd:e(CB)}}(estimation sample average) covariance matrix of choice model coefficients{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{title:Reference}
{phang}Bhat, C., 1997. {it:An endogenous segmentation mode choice model with an application to intercity travel}. Transportation Science 31, 34-48.

{phang}Train, K., 2008. {it:EM Algorithms for Nonparametric Estimation of Mixing Distributions}. Journal of Choice Modelling 1 (1) 40-69.

{phang}Huber, J. and K. Train, 2001. {it:On the similarity of classical and bayesian estimates of individual mean partworths}, Marketing Letters 12, 259-269.

{title:Authors}

{pstd} This command was written by Daniele Pacifico and Hong Il Yoo. Comments and suggestions are welcome. {p_end}     
{pstd} Daniele Pacifico (daniele.pacifico@tesoro.it): Italian Department of the Treasury, Italy. {p_end} 
{pstd} Hong Il Yoo (h.i.yoo@durham.ac.uk): Durham University Business School, United Kingdom. {p_end} 

{title:Also see}

{psee}
Online:  {manhelp lclogit R}, {helpb lclogit postestimation}, {helpb fmlogit}{p_end}
