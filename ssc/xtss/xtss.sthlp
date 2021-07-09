{smcl}
{* *! version 1.0.1  28sep2019}{...}
{title:Title}

{phang}
{bf:xtss} {hline 2} Maximum likelihood estimator of panel data (S,s) rule regression models



{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:xtss}
{depvar}
[{indepvars}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opth thold(varlist)}}include {it: varlist} in the threshold equations{p_end}
{synopt:{opt diff}}allow the thresholds to differ {p_end}
{synopt:{opt re}}include a random effect in the model for {depvar} {p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt display_options}}display options for the regression output{p_end}

{syntab:Integration}
{synopt:{opt int:points(#)}}use {it:#} quadrature points; 
	default is  {cmd:intpoints(12)}{p_end}

{syntab:Maximization}
{synopt:{opth initvals(numlist)}}set {it:numlist} as the initial values for the coefficients{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
A panel variable and a time variable must be specified using {help xtset}{p_end}



{marker description}{...}
{title:Description}

{pstd}
{cmd:xtss} estimates the parameters of a linear latent variable model, where the observed 
outcome remains unchanged from the previous period, if the difference relative to the current value of the latent variable 
is within stochastic (S,s) thresholds. The upper-S and lower-s thresholds are normally distributed 
and truncated at zero and can depend on time-varying covariates. This estimator is based on Fougere et 
al (2010) and Dhyne et al (2011) who study price rigidity.



{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opth thold(varlist)} allows the mean parameter mu(it) in the truncated normal distributions of the upper and lower (S,s) stochastic thresholds 
be a linear function of panel and time-varying variables in {it: varlist} (see remarks). A constant is always included.

{phang}
{opt diff} lets the upper and lower stochastic thresholds have different mean parameters. The default is they are the same.

{phang}
{opt re} requests that the latent variable model for {depvar} include a random effect on the constant to control for time-invariant unobserved heterogeneity.

{phang}
{opt noconstant} suppresses the constant term in the latent variable model for {depvar}.


{dlgtab:Reporting}

{phang}
{opt l:evel(#)}  specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)}.

{phang}
{it:display_options}:
{opt noci},
{opt nopv:alues}, 
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels},
{opt nofvlab:el},
{opt fvwrap(#)}
{opt fvwrapon(style)},
{opt cformat(%fmt)},
{opt pformat(%fmt)},
{opt sformat(%fmt)}, and
{opt nolstretch}; see {helpb estimation options##display_options:[R] estimation options}.

		
{dlgtab:Integration}

{phang}
{opt int:points(#)}  specifies the number of integration points {it:#} for the Gauss-Hermite quadrature method, which is used to 
integrate out the random effects when {cmd: re} is specified. The default is  {cmd:intpoints(12)}.
	

{dlgtab:Maximization}

{phang}
{opth initvals(numlist)} sets the initial values for the coefficients to be those in {it:numlist}. If this option is
not specified, the coefficients in the latent variable model are obtained by OLS or GLS and those in the threshold
mean equations by estimating a bivariate probit model.
	
	
	
{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:xtss} is appropriate when an outcome variable y(it) exhibits infrequent changes due to adjustmen costs and is revised to a frictionless 
latent outcome y(it)*, when the difference y(it)*-y(it-1)>S(it), or when y(it)*-y(it-1)<-s(it), where (S,s) are the upper and 
lower bound stochastic thresholds. When the difference is within the thresholds, the value remains unchanged from the previous period y(it)=y(it-1). 

{pstd}
The frictionless outcome model is: y(it)=x1(it)*b1+u(i)+e(it), where u(i)~iidn(0,sigma_u^2) is a random effect and e(it)~iidn(0,sigma_e^2) and 
where the thresholds have normal distributions truncated at zero: S(it)~N+(mu_upper(it),sigma_c^2) and s(it)~N+(mu_lower(it),sigma_c^2). 
{cmd:xtss} allows the mean parameters to depend on time-varying controls: mu_upper(it)=x2(it)*b2_upper and  mu_lower(it)=x2(it)*b2_lower, where x2 
can contain variables that are included in x1. 

{pstd}
This model has been used in the literature to explain firm-level prices, which are revised periodically and where the thresholds (S,s) 
 measure the extent to which changes are costly and represent nominal rigidity. 


{marker examples}{...}
{title:Examples}

{pstd}
The following examples use simulated data on quarterly prices for N=150 products between 2005Q1 and 2009Q4 setting sigma_e=sigma_c=sigma_u=0.1. The products
are produced by 3 manufacturers and frictionless prices are explained by observed material costs with a coefficient of 1, firm fixed effects and 
unobserved product random effects. Firms collude from 2007Q1 and this leads to a rise of 0.2 in the log-frictionless price, a 
reduction of -0.1 in the mean parameter of the upper threshold for a price rise and an increase of 0.1 in the mean parameter of the lower 
threshold for a price fall. 


{title:Symetric thresholds}

{pstd}
In this example, the thresholds are restricted to be symmetric and there are no random effects

{pstd}Setup{p_end}
{phang2}{cmd:. use stickyprices.dta}{p_end}

{pstd}Estimate the model{p_end}
{phang2}{cmd:. xtss ln_price i.firm ln_materials cartel, thold(cartel)}{p_end}


ML regression{col 49}Number of obs{col 67}= {res}     2,850
{txt}{col 49}Wald chi2({res}4{txt}){col 67}= {res}  44751.23
{txt}{col 49}Prob > chi2{col 67}= {res}    0.0000
{txt}Log likelihood  = {res}-1065.8609
{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 1}    ln_price{col 14}{c |}      Coef.{col 26}   Std. Err.{col 38}      z{col 46}   P>|z|{col 54}     [95% Con{col 67}f. Interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}Model        {txt}{c |}
{space 8}firm {c |}
{space 6}firm2  {c |}{col 14}{res}{space 2} 1.014183{col 26}{space 2} .0096412{col 37}{space 1}  105.19{col 46}{space 3}0.000{col 54}{space 4} .9952869{col 67}{space 3}  1.03308
{txt}{space 6}firm3  {c |}{col 14}{res}{space 2}  1.00762{col 26}{space 2} .0085368{col 37}{space 1}  118.03{col 46}{space 3}0.000{col 54}{space 4} .9908878{col 67}{space 3} 1.024351
{txt}{space 12} {c |}
ln_materials {c |}{col 14}{res}{space 2} .9902805{col 26}{space 2}  .035048{col 37}{space 1}   28.25{col 46}{space 3}0.000{col 54}{space 4} .9215876{col 67}{space 3} 1.058973
{txt}{space 6}cartel {c |}{col 14}{res}{space 2} .2310741{col 26}{space 2} .0362605{col 37}{space 1}    6.37{col 46}{space 3}0.000{col 54}{space 4} .1600048{col 67}{space 3} .3021433
{txt}{space 7}_cons {c |}{col 14}{res}{space 2} .9853571{col 26}{space 2} .0081766{col 37}{space 1}  120.51{col 46}{space 3}0.000{col 54}{space 4} .9693312{col 67}{space 3} 1.001383
{txt}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}Threshold    {txt}{c |}
{space 6}cartel {c |}{col 14}{res}{space 2} .0579821{col 26}{space 2} .0362217{col 37}{space 1}    1.60{col 46}{space 3}0.109{col 54}{space 4}-.0130112{col 67}{space 3} .1289754
{txt}{space 7}_cons {c |}{col 14}{res}{space 2} .0607266{col 26}{space 2} .0955651{col 37}{space 1}    0.64{col 46}{space 3}0.525{col 54}{space 4}-.1265775{col 67}{space 3} .2480307
{txt}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
  /lnsigma_c {c |}{col 14}{res}{space 2}-1.121018{col 26}{space 2} .1908363{col 37}{space 1}   -5.87{col 46}{space 3}0.000{col 54}{space 4}-1.495051{col 67}{space 3}-.7469861
{txt}  /lnsigma_e {c |}{col 14}{res}{space 2}-1.998873{col 26}{space 2} .0183306{col 37}{space 1} -109.05{col 46}{space 3}0.000{col 54}{space 4}  -2.0348{col 67}{space 3}-1.962946
{txt}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
     sigma_c {c |}{col 14}{res}{space 2} .3259477{col 26}{space 2} .0622027{col 54}{space 4} .2242372{col 67}{space 3} .4737924
{txt}     sigma_e {c |}{col 14}{res}{space 2} .1354879{col 26}{space 2} .0024836{col 54}{space 4} .1307066{col 67}{space 3} .1404441
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}




{title:Asymetric time-varying thresholds and random effects}

{pstd}
This example models the true DGP by allowing for asymmetric  thresholds and random effects

{phang2}{cmd:. xtss ln_price i.firm ln_materials cartel, thold(cartel) diff re}{p_end}


ML random effects regression{col 49}Number of obs{col 67}= {res}     2,850
{txt}{col 49}Wald chi2({res}4{txt}){col 67}= {res}  61668.13
{txt}{col 49}Prob > chi2{col 67}= {res}    0.0000
{txt}Log likelihood  = {res}-443.92154
{txt}{hline 16}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 1}       ln_price{col 17}{c |}      Coef.{col 29}   Std. Err.{col 41}      z{col 49}   P>|z|{col 57}     [95% Con{col 70}f. Interval]
{hline 16}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}Model           {txt}{c |}
{space 11}firm {c |}
{space 9}firm2  {c |}{col 17}{res}{space 2} .9753967{col 29}{space 2} .0144508{col 40}{space 1}   67.50{col 49}{space 3}0.000{col 57}{space 4} .9470736{col 70}{space 3}  1.00372
{txt}{space 9}firm3  {c |}{col 17}{res}{space 2} .9888122{col 29}{space 2} .0145501{col 40}{space 1}   67.96{col 49}{space 3}0.000{col 57}{space 4} .9602945{col 70}{space 3}  1.01733
{txt}{space 15} {c |}
{space 3}ln_materials {c |}{col 17}{res}{space 2} .9853875{col 29}{space 2} .0252269{col 40}{space 1}   39.06{col 49}{space 3}0.000{col 57}{space 4} .9359438{col 70}{space 3} 1.034831
{txt}{space 9}cartel {c |}{col 17}{res}{space 2} .2131089{col 29}{space 2} .0260973{col 40}{space 1}    8.17{col 49}{space 3}0.000{col 57}{space 4} .1619591{col 70}{space 3} .2642587
{txt}{space 10}_cons {c |}{col 17}{res}{space 2} 1.015173{col 29}{space 2} .0124511{col 40}{space 1}   81.53{col 49}{space 3}0.000{col 57}{space 4} .9907692{col 70}{space 3} 1.039577
{txt}{hline 16}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}Lower_threshold {txt}{c |}
{space 9}cartel {c |}{col 17}{res}{space 2} .0958017{col 29}{space 2} .0106609{col 40}{space 1}    8.99{col 49}{space 3}0.000{col 57}{space 4} .0749066{col 70}{space 3} .1166967
{txt}{space 10}_cons {c |}{col 17}{res}{space 2} .1918025{col 29}{space 2} .0082502{col 40}{space 1}   23.25{col 49}{space 3}0.000{col 57}{space 4} .1756324{col 70}{space 3} .2079726
{txt}{hline 16}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}Upper_threshold {txt}{c |}
{space 9}cartel {c |}{col 17}{res}{space 2}-.0800436{col 29}{space 2} .0122694{col 40}{space 1}   -6.52{col 49}{space 3}0.000{col 57}{space 4}-.1040912{col 70}{space 3}-.0559959
{txt}{space 10}_cons {c |}{col 17}{res}{space 2} .1924725{col 29}{space 2} .0081926{col 40}{space 1}   23.49{col 49}{space 3}0.000{col 57}{space 4} .1764152{col 70}{space 3} .2085298
{txt}{hline 16}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
     /lnsigma_c {c |}{col 17}{res}{space 2}-2.435955{col 29}{space 2} .0620125{col 40}{space 1}  -39.28{col 49}{space 3}0.000{col 57}{space 4}-2.557498{col 70}{space 3}-2.314413
{txt}     /lnsigma_e {c |}{col 17}{res}{space 2}-2.319026{col 29}{space 2} .0182523{col 40}{space 1} -127.05{col 49}{space 3}0.000{col 57}{space 4}  -2.3548{col 70}{space 3}-2.283253
{txt}     /lnsigma_u {c |}{col 17}{res}{space 2}   -2.292{col 29}{space 2} .0422122{col 40}{space 1}  -54.30{col 49}{space 3}0.000{col 57}{space 4}-2.374735{col 70}{space 3}-2.209266
{txt}{hline 16}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
        sigma_c {c |}{col 17}{res}{space 2} .0875141{col 29}{space 2}  .005427{col 57}{space 4} .0774984{col 70}{space 3} .0988242
{txt}        sigma_e {c |}{col 17}{res}{space 2} .0983693{col 29}{space 2} .0017955{col 57}{space 4} .0949125{col 70}{space 3} .1019521
{txt}        sigma_u {c |}{col 17}{res}{space 2} .1010641{col 29}{space 2} .0042661{col 57}{space 4} .0930392{col 70}{space 3} .1097812
{txt}{hline 16}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}





{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtss} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(k_aux)}}number of auxiliary parameters{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(n_quad)}}number of quadrature points{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtss}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting periods{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(chi2type)}}Wald type of model chi-squared test{p_end}
{synopt:{cmd:e(predict)}}program used to implement predict{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}



{title:Reference}

{phang}Dhyne, E., C. Fuss, M. Pesaran and P. Sevestre. 2011. 
Lumpy price adjustments. {it: Journal of Business and Economic Statistics}.

{phang}Fougere, D., E. Gautier, and H. L. Bihan. 2010. 
Restaurant prices and the minimum wage. {it: Journal of Money, Credit and Banking}.


{title:Author}

{phang}This command was written by David Vincent (davidwvincent@hotmail.com).
Comments and suggestions are welcome. {p_end}


