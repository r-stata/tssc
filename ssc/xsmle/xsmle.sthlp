{smcl}
{* *! version 0.99  27aug2012}{...}
{* *! version 1  20oct2012}{...}
{* *! version 1.0.3  21jan2012}{...}
{* *! version 1.0.4  18jun2013}{...}
{* *! version 1.0.5  21jun2016}{...}
{* *! version 1.0.6  27jun2016}{...}
{* *! version 1.0.7  7sep2016}{...}
{* *! version 1.1  12sep2016}{...}


{cmd:help xsmle}{right:also see:  {help xsmle postestimation##xsmle postestimation:xsmle_postestimation}}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col:{hi:xsmle} {hline 2}}Spatial Panel Data Models{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}
Spatial Autoregressive (SAR) model

{p 8 16 2}{cmd:xsmle} {depvar} [{indepvars}] {ifin} {weight}
, wmat(name) {cmdab:mod:el(sar)} [{it:{help xsmle##saroptions:SAR_options}}]

{phang}
Spatial Durbin (SDM) model

{p 8 16 2}{cmd:xsmle} {depvar} [{indepvars}] {ifin} {weight} 
, wmat(name) {cmdab:mod:el(sdm)} [{it:{help xsmle##sdmoptions:SDM_options}}]

{phang}
 Spatial Autocorrelation (SAC) model

{p 8 16 2}{cmd:xsmle} {depvar} [{indepvars}] {ifin} {weight} 
, wmat(name) emat(name) {cmdab:mod:el(sac)} [{it:{help xsmle##sacoptions:SAC_options}}]

{phang}
Spatial Error (SEM) model

{p 8 16 2}{cmd:xsmle} {depvar} [{indepvars}] {ifin} {weight} 
, emat(name) {cmdab:mod:el(sem)} [{it:{help xsmle##semoptions:SEM_options}}]

{phang}
Generalized Spatial Panel Random Effects (GSPRE) model

{p 8 16 2}{cmd:xsmle} {depvar} [{indepvars}] {ifin} {weight} 
, wmat(name) {cmdab:mod:el(gspre)} [emat(name) {it:{help xsmle##gspreoptions:GSPRE_options}}]

{marker saroptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :SAR_options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:wmat(}{opt name)}}specify the weight matrix for the spatial-autoregressive term{p_end}
{synopt :{opt re}}use the random effects estimator; the default{p_end}
{synopt :{opt fe}}use the fixed effects estimator{p_end}
{synopt :{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu])}specify fixed-effects type{p_end}

{syntab:SE/Robust}
{synopt :{cmdab:vce(}{it:{help xsmle##vce_options:vcetype}})}may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt dkraay} {it:#}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(cluster}{it: panelvar}{cmd:)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Other}
{synopt :{cmdab:dlag(}{it:{help xsmle##dlag_options:dlag}})} includes time lagged dependent variable, space-time lagged dependent variable or both in the model{p_end}
{synopt :{opt nocons:tant}}suppress the constant term in the model. Only for {cmd:re} estimator{p_end}
{synopt :{opt eff:ects}}computes direct, indirect and total effects and adds them to {cmd:e(b)}{p_end}
{synopt :{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)])} sets how the standard errors for the direct, indirect and total effects are computed {p_end}
{synopt :{cmdab:constr:aints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{cmdab:from(}{it:{help xsmle##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}
{synopt :{opt hausman}}performs the Hausman test. Allowed only for static models{p_end}


{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help xsmle##xsmle_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help xsmle##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{marker sdmoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :SDM_options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:wmat(}{opt name)}}specify the weight matrix for the spatial-autoregressive term{p_end}
{synopt :{cmdab:dmat(}{opt name)}}specify the weight matrix for the spatially lagged regressors; default is to use the {opt wmat()} matrix{p_end}
{synopt :{cmdab:durbin(}{varlist})}specify the regressors that have to be spatially lagged; default is to lag all independent variables in {it:varlist}{p_end}
{synopt :{opt re}}use the random effects estimator; the default{p_end}
{synopt :{opt fe}}use the fixed effects estimator{p_end}
{synopt :{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu])}specify fixed-effects type{p_end}

{syntab:SE/Robust}
{synopt :{cmdab:vce(}{it:{help xsmle##vce_options:vcetype}})}may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt dkraay} {it:#}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(cluster}{it: panelvar}{cmd:)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Other}
{synopt :{cmdab:dlag(}{it:{help xsmle##dlag_options:dlag}})} includes time lagged dependent variable, space-time lagged dependent variable or both in the model{p_end}
{synopt :{opt nocons:tant}}suppress the constant term in the model. Only for {cmd:re} estimator{p_end}
{synopt :{opt eff:ects}}computes direct, indirect and total effects and adds them to {cmd:e(b)}{p_end}
{synopt :{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)])} sets how the standard errors for the direct, indirect and total effects are computed {p_end}
{synopt :{cmdab:constr:aints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{cmdab:from(}{it:{help xsmle##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}
{synopt :{opt hausman}}performs the Hausman test. Allowed only for static models{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help xsmle##xsmle_display_options:display_options}}}control spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help xsmle##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{marker sacoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :SAC_options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:wmat(}{opt name)}}specify the weight matrix for the spatial-autoregressive term{p_end}
{synopt :{cmdab:emat(}{opt name)}}specify the weight matrix used in the spatial error term; default is to use the {opt wmat()} matrix{p_end}
{synopt :{opt fe}}use the fixed effects estimator{p_end}
{synopt :{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu])}specify fixed-effects type{p_end}

{syntab:SE/Robust}
{synopt :{cmdab:vce(}{it:{help xsmle##vce_options:vcetype}})}may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt dkraay} {it:#}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(cluster}{it: panelvar}{cmd:)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Other}
{synopt :{opt eff:ects}}computes direct, indirect and total effects and adds them to {cmd:e(b)}{p_end}
{synopt :{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)])} sets how the standard errors for the direct, indirect and total effects are computed {p_end}
{synopt :{cmdab:constr:aints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{cmdab:from(}{it:{help xsmle##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help xsmle##xsmle_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help xsmle##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{marker semoptions}{...}
{synoptset 29 tabbed}{...}
{synopthdr :SEM_options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:emat(}{opt name)}}specify the weight matrix used in the spatial error term{p_end}
{synopt :{opt re}}use the random effects estimator; the default{p_end}
{synopt :{opt fe}}use the fixed effects estimator{p_end}
{synopt :{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu])}specify fixed-effects type{p_end}

{syntab:SE/Robust}
{synopt :{cmdab:vce(}{it:{help xsmle##vce_options:vcetype}})}may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt dkraay} {it:#}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(cluster}{it: panelvar}{cmd:)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Other}
{synopt :{opt nocons:tant}}suppress the constant term in the model. Only for {cmd:re} estimator{p_end}
{synopt :{cmdab:constr:aints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{cmdab:from(}{it:{help xsmle##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}
{synopt :{opt hausman}}performs the Hausman test{p_end}


{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help xsmle##xsmle_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help xsmle##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{marker gspreoptions}{...}
{synoptset 29 tabbed}{...}
{synopthdr :GSPRE_options}
{synoptline}
{syntab:Model}
{synopt :{cmdab:wmat(}{opt name)}}specify the weight matrix used for the spatial random effect component. Either/both wmat() or emat() is/are required according to {opt error(#)}{p_end}
{synopt :{cmdab:emat(}{opt name)}}specify the weight matrix used for the spatial error component. Either/both wmat() or emat() is/are required{p_end}
{synopt :{opt re}}use the random effects estimator; the default{p_end}
{synopt :{cmdab:err:or(}{it:{help xsmle##xsmle_error_options:#}}{cmd:)}}define the spatial random effect error structure{p_end}

{syntab:SE/Robust}
{synopt :{cmdab:vce(}{it:{help xsmle##vce_options:vcetype}})}may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt dkraay} {it:#}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(cluster}{it: panelvar}{cmd:)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Other}
{synopt :{opt nocons:tant}}suppress the constant term in the model{p_end}
{synopt :{cmdab:constr:aints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{cmdab:from(}{it:{help xsmle##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help xsmle##xsmle_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help xsmle##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}

{marker type_options}{...}
{synoptset 39 tabbed}{...}
{synopthdr :Type options}
{synoptline}
{synopt :{opt ind}} for individual fixed effects {p_end}
{synopt :{opt time}} for time fixed effect{p_end}
{synopt :{opt both}} for both time and individual fixed effects{p_end}
{synoptline}
{synopt :{opt leeyu}}transforms the data according to Lee & Yu (JoE, 2010){p_end}
{synoptline}

{marker xsmle_error_options}{...}
{synoptset 39 tabbed}{...}
{synopthdr:Error options}
{synoptline}
{synopt :{cmd:error(1)}}for phi != lambda != 0 - the default{p_end}
{synopt :{cmd:error(2)}}for phi != 0, lambda == 0{p_end}
{synopt :{cmd:error(3)}}for phi == 0, lambda != 0, (equivalent to the SEM model){p_end}
{synopt :{cmd:error(4)}}for phi == lambda {p_end}
{synoptline}


{marker vceeffects}{...}
{synoptset 39 tabbed}{...}
{synopthdr:vce effects type}
{synoptline}
{synopt :{opt dm}}for Delta Method standard errors{p_end}
{synopt :{cmd:sim [,nsim(#)]}}for Monte Carlo standard errors (the default), using # replications (Lesage and Pace, 2009){p_end}
{synopt :{opt none}}for no standard errors {p_end}
{synoptline}


{marker dlag_options}{...}
{synoptset 39 tabbed}{...}
{synopthdr:dlag options}
{synoptline}
{synopt :{cmd:dlag(1)}} includes time lagged dependent variable in the model (tau*y_it-1){p_end}
{synopt :{cmd:dlag(2)}} includes space-time lagged dependent variable in the model (psi*W*y_it-1){p_end}
{synopt :{cmd:dlag(3)}}includes both time lagged and space-time lagged dependent variable in the model (tau*y_it-1 + psi*W*y_it-1)){p_end}
{synoptline}

{p2colreset}{...}

{p 4 6 2}
A panel and a time variable must be specified. Use {helpb xtset}.{p_end}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{opt aweight}s and {opt iweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}Weights must be constant within panel.{p_end}
{p 4 6 2}Multiple imputation is allowed; see {help mi}.{p_end}



{title: Description}

{pstd}
{cmd:xsmle} fits fixed or random effects spatial models for balanced panel data. See the {help mi} prefix command in order to use {cmd:xsmle} in the unbalanced case. Consider the following general specification for the spatial panel data model:

		y_it = tau*y_it-1 + psi*W*y_it-1 + rho*W*y_it + beta*X_it + D*Z_it*theta + a_i + gamma_t + v_it 
		v_it = lambda*E*v_it + u_it

{pstd}
where u_it is a normally distributed error term, W is the spatial matrix for the autoregressive component, D the spatial matrix for the spatially lagged independent variables, E the spatial matrix for the idiosyncratic error component. 
a_i is the individual fixed or random effect and gamma_t is the time effect.
{cmd:xsmle} fits the following nested models:

{pstd}
{cmd:i)} the SAR model with lagged dependent variable (theta=lambda=psi=0) 

		y_it = tau*y_it-1 + rho*W*y_it + beta*X_it + a_i + gamma_t + u_it 
{pstd}
{cmd:ii)} the SAR model with time and space lagged dependent variable (theta=lambda=tau=0) 

		y_it = psi*W*y_it-1 + rho*W*y_it + beta*X_it + a_i + gamma_t + u_it
		
{pstd}
{cmd:iii)} the full dynamic SAR model  (theta=lambda=0) 

		y_it = tau*y_it-1 + psi*W*y_it-1 + rho*W*y_it + beta*X_it + a_i + gamma_t + u_it 

{pstd}
{cmd:iv)} the classical SAR model  (theta=lambda=psi=tau=0) 

		y_it =  rho*W*y_it + beta*X_it + a_i + gamma_t + u_it 	
		
{pstd}
{cmd:v)} the SDM model with lagged dependent variable (lambda=psi=0)

		y_it = tau*y_it-1 + rho*W*y_it + beta*X_it + D*Z_it*theta + a_i + gamma_t + u_it 
		
{pstd}
{cmd:vi)} the SDM model with time and space lagged dependent variable (lambda=tau=0)

		y_it = tau*y_it-1 + rho*W*y_it + beta*X_it + D*Z_it*theta + a_i + gamma_t + u_it 
		
{pstd}
{cmd:vii)} the full dynamic SDM model  (lambda=0)

		y_it = tau*y_it-1 + psi*W*y_it-1 + rho*W*y_it + beta*X_it + D*Z_it*theta + a_i + gamma_t + u_it 
		
{pstd}
{cmd:viii)} the classical SDM model  (lambda=tau=psi=0)

		y_it = rho*W*y_it + beta*X_it + D*Z_it*theta + a_i + gamma_t + u_it		
		
{pstd}
{cmd:xsmle} allows to use a different weighting matrix for the spatially lagged dependent variable (W) and the spatially lagged regressors (D) together with a different sets of explanatory (X_it) and spatially lagged regressors (Z_it). 
The default is to use W=D and X_it=Z_it.

{pstd}
{cmd:ix)} the SAC model (theta=tau=psi=0) 

		y_it = rho*W*y_it + beta*X_it + a_i + gamma_t + v_it  
		v_it = lambda*E*v_it + u_it

{pstd}
for which {cmd:xsmle} allows to use a different weighting matrix for the spatially lagged dependent variable (W) and the error term (E). {* The default is to use W=E.}

{pstd}
{cmd:x)} the SEM model (rho=theta=tau=psi=0) 

		y_it = beta*X_it + a_i + gamma_t + v_it 
		v_it = lambda*E*v_it + u_it

{pstd}			
{cmd:xi)} the GSPRE model (rho=theta=tau=psi=0) 

		y_it = beta*X_it + a_i + v_it
		a_i = phi*W*a_i + mu_i
		v_it = lambda*E*v_it + u_it

{pstd}
where also the random effects have a spatial autoregressive form.



{title: Options for the Spatial Autoregressive (SAR) model}

{dlgtab:Model}

{phang}
{cmdab:wmat(}{opt name)} specifies the weight matrix for the spatial-autoregressive term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not. 

{phang}
{opt re} use the random effects estimator; the default.

{phang}
{opt fe} use the fixed effects estimator.

{phang}
{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu]) specifies fixed-effects type. May be {opt ind} for individual fixed effects effects, {opt time} for time fixed effects or {opt both} for time and individual fixed effects. 
Suboption {opt leeyu} transforms the data according to Lee & Yu (JoE, 2010).

{dlgtab:Other}

{phang}
{cmdab:dlag(}{it:{help xsmle##dlag_options:dlag}}) includes time lagged dependent variable, space-time lagged dependent variable or both in the model.

{phang}
{opt level(#)} sets confidence interval level; default is {cmd:level(95)}.

{phang}
{opt noconstant} suppresses the constant term in the model. Only for {cmd:re} estimator.

{phang}
{opt effects} computes direct, indirect and total effects and adds them to {cmd:e(b)}.

{phang}
{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)]) sets how the standard errors for the direct, indirect and total effects are computed. May be {opt dm} for Delta Method standard errors, {cmd:sim[,nsim(#)]} for Monte Carlo standard errors, where {opt nsim(#)} sets the number of simulations for the Lesage and Pace (2009) procedure, or {opt none} for no standard errors.

{phang}
{opt hausman} performs the robust Hausman test, automatically detecting the alternative estimator. The test is computed estimating the variance covariance matrix of the difference between {opt fe} and {opt re} estimators as in White (1982). Allowed only for static models.


{title: Options for the Spatial Durbin (SDM) model}

{dlgtab:Model}

{phang}
{cmdab:wmat(}{opt name)} specifies the weight matrix for the spatial-autoregressive term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not. 

{phang}
{cmdab:dmat(}{opt name)} specifies the weight matrix for the spatially lagged regressors; default is to use the matrix specified in {opt wmat()}. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not.

{phang}
{cmdab:durbin(}{varlist}) specifies the regressors that have to be spatially lagged; default is to lag all independent variables in {it:varlist}.

{phang}
{opt re} use the random effects estimator; the default.

{phang}
{opt fe} use the fixed effects estimator.

{phang}
{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu]) specifies fixed-effects type. May be {opt ind} for individual fixed effects, {opt time} for time fixed effects or {opt both} for time and individual fixed effects. 
Suboption {opt leeyu} transforms the data according to Lee & Yu (JoE, 2010).

{dlgtab:Other}

{phang}
{cmdab:dlag(}{it:{help xsmle##dlag_options:dlag}}) includes time lagged dependent variable, space-time lagged dependent variable or both in the model.

{phang}
{opt level(#)} sets confidence interval level; default is {cmd:level(95)}.

{phang}
{opt noconstant} suppresses the constant term in the model. Only for {cmd:re} estimator.

{phang}
{opt effects} computes direct, indirect and total effects and adds them to {cmd:e(b)}.

{phang}
{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)]) sets how the standard errors for the direct, indirect and total effects are computed. May be {opt dm} for Delta Method standard errors, {cmd:sim[,nsim(#)]} for Monte Carlo standard errors, where {opt nsim(#)} sets the number of simulations for the Lesage and Pace (2009) procedure, or {opt none} for no standard errors.

{phang}
{cmdab:constraints(}{it:{help estimation options##constraints():constraints}}{cmd:)} apply specified linear constraints.

{phang}
{opt hausman} performs the robust Hausman test, automatically detecting the alternative estimator. The test is computed estimating the variance covariance matrix of the difference between {opt fe} and {opt re} estimators as in White (1982). Allowed only for static models.


{title: Options for the Spatial Autocorrelation (SAC) model}

{dlgtab:Model}

{phang}
{cmdab:wmat(}{opt name)} specifies the weight matrix for the spatial-autoregressive term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not. 

{phang}
{cmdab:emat(}{opt name)} specifies the weight matrix for the spatial-error term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not.


{phang}
{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu]) specifies fixed-effects type. May be {opt ind} for individual fixed effects, {opt time} for time fixed effects or {opt both} for time and individual fixed effects. 
Suboption {opt leeyu} transforms the data according to Lee & Yu (JoE, 2010).

{dlgtab:Other}

{phang}
{opt level(#)} sets confidence interval level; default is {cmd:level(95)}.

{phang}
{opt effects} computes direct, indirect and total effects and adds them to {cmd:e(b)}. 

{phang}
{cmdab:vcee:ffects(}{it:{help xsmle##vceeffects:vcee_type}}[, nsim(#)]) sets how the standard errors for the direct, indirect and total effects are computed. May be {opt dm} for Delta Method standard errors, {cmd:sim[,nsim(#)]} for Monte Carlo standard errors, where {opt nsim(#)} sets the number of simulations for the Lesage and Pace (2009) procedure, or {opt none} for no standard errors.

{phang}
{cmdab:constraints(}{it:{help estimation options##constraints():constraints}}{cmd:)} apply specified linear constraints.


{title: Options for the Spatial Error (SEM) model}

{dlgtab:Model}

{phang}
{cmdab:emat(}{opt name)} specifies the weight matrix for the spatial-error term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not. 

{phang}
{opt re} use the random effects estimator; the default.

{phang}
{opt fe} use the fixed effects estimator.

{phang}
{cmdab:type(}{it:{help xsmle##type_options:type_options}}[, leeyu])} specifies fixed-effects type. May be {opt ind} for individual fixed effects, {opt time} for time fixed effects or {opt both} for time and individual fixed effects. 
Suboption {opt leeyu} transforms the data according to Lee & Yu (JoE, 2010).

{dlgtab:Other}

{phang}
{opt level(#)} sets confidence interval level; default is {cmd:level(95)}.

{phang}
{opt noconstant} suppresses the constant term in the model. Only for {cmd:re} estimator.

{phang}
{cmdab:constraints(}{it:{help estimation options##constraints():constraints}}{cmd:)} apply specified linear constraints.

{phang}
{opt hausman} performs the robust Hausman test, automatically detecting the alternative estimator. The test is computed estimating the variance covariance matrix of the difference between {opt fe} and {opt re} estimators as in White (1982).


{title: Options for the Generalized Spatial Panel Random Effects (GSPRE) model}

{dlgtab:Model}

{phang}
{cmdab:wmat(}{opt name)} specifies the weight matrix for the spatial random-effects. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not. 

{phang}
{cmdab:emat(}{opt name)} specifies the weight matrix for the spatial-error term. {opt name} can be a Stata matrix or a {helpb spmat:spmat} object. This matrix can be standardized or not.

{phang}
{opt err:or(#)} defines the random effect error structure. Error specification with # = 1..4 for combinations of the coefficients: rho1 for the random effect spatial error component the spatial panel error component and rho2 for the spatial error component


{dlgtab:Other}

{phang}
{opt level(#)} sets confidence interval level; default is {cmd:level(95)}.

{phang}
{opt noconstant} suppresses the constant term in the model. Only for {cmd:re} estimator.

{phang}
{cmdab:constraints(}{it:{help estimation options##constraints():constraints}}{cmd:)} apply specified linear constraints.





{title: Options or options' arguments common to all models}


{dlgtab:Starting values}
{marker from_maximize_option}
{phang}
{opt from()} specifies initial values for the coefficients.  
You can specify the initial values in one of three ways: by specifying the name of a
vector containing the initial values (e.g., {cmd:from(b0)}, where {cmd:b0} is a
properly labeled vector); by specifying coefficient names with the values
(e.g., {cmd:from(age=2.1 /sigma=7.4)}); or by specifying a list of values
(e.g., {cmd:from(2.1 7.4, copy)}). Poor values in {opt from()} may lead to convergence
problems.

{phang2}
{opt skip} specifies that any parameters found in the specified initialization
vector that are not also found in the model be ignored.  The default action is
to issue an error message.

{phang2}
{opt copy} specifies that the list of values or the initialization
vector be copied into the initial-value vector by position rather than
by name.


{dlgtab:Maximization}
{marker maximize_options}
{phang}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt from(init_specs)}, {opt tol:erance(#)},
{opt ltol:erance(#)}, {opt nrtol:erance(#)},
{opt nonrtol:erance}; see {manhelp maximize R}.  These
options are seldom used.


{dlgtab:Display}
{marker xsmle_display_options}{...}
{phang}
{it:display_options}:
{opt vsquish},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.


{dlgtab:Variance estimation}

{pstd}
This entry describes the arguments of {opt vce()} option. {cmd:vce()} specifies how to estimate the
variance-covariance matrix (VCE) corresponding to the parameter estimates.
The standard errors reported in the table of parameter estimates are the
square root of the variances (diagonal elements) of the VCE.


{synoptset 32}{...}
{marker vce_options}{...}
{synopt :{it:vcetype}}description{p_end}
{synoptline}
{synopt :Likelihood based}{p_end}
{synopt :{cmd:oim}}observed information matrix (OIM). see {help vcetype}{p_end}
{synopt :{cmd:opg}}outer product of the gradient (OPG) vectors{p_end}

{synopt :Sandwich estimators}{p_end}
{synopt :{cmdab:r:obust}} synonym for clustered sandwich estimator where {it:clustvar} is {it:panelvar}{p_end}
{synopt :{cmdab:cl:uster} {it:clustvar}}clustered sandwich estimator{p_end}
{synopt :{cmdab:dkraay} {it:#}}Driscoll-Kraay robust estimator. {it:#} is the maximum lag used in the calculation{p_end}
{synoptline}
{p2colreset}{...}
	
	
{title:Remarks}
{marker xsmle_remarks}{...}

{pstd}This version of {opt xsmle} does not allow the use of multiple weight matrices in {opt wmat()} or {opt emat()} (or {opt dmat()}). This means that the weight matrix is forced to be the same 
for each cross-section and {opt xsmle} will automatically replicate it for all time periods. Notice that the maximum dimension of a single Stata matrix depends on Stata's flavor: 40 x 40 (Small) 800 x 800 (IC) and 11,000 x 11,000 (SE or MP). 
In order to overcome this limitation, bigger matrices have to be specified as {helpb spmat:spmat} objects.{p_end}    
{pstd}When variance-covariance matrix is not positive definite and {opt vceeffects(sim)} has been specified, direct, indirect and total effects standard errors are computed using a modified positive definite matrix as in Rebonato and Jackel (2000).{p_end}

{pstd} We would like to thank Giovanni Millo and Gianfranco Piras for creating and sharing the spatial weights matrix used in all {cmd:xsmle} examples.{p_end}

	
{title:Examples}

{pstd}SAR model{p_end}
{phang2}{cmd: use http://www.econometrics.it/stata/data/xsmle/product.dta, clear} {p_end}
{phang2}{cmd: spmat use usaww using http://www.econometrics.it/stata/data/xsmle/usaww.spmat} {p_end}
{phang2}{cmd: gen lngsp = log(gsp)} {p_end}
{phang2}{cmd: gen lnpcap = log(pcap)} {p_end}
{phang2}{cmd: gen lnpc = log(pc)} {p_end}
{phang2}{cmd: gen lnemp = log(emp)} {p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp unemp, wmat(usaww)} {p_end}

{pstd}SDM model with selected spatially lagged regressors and direct+indirect effect {p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp, re model(sdm) wmat(usaww) durbin(lnpcap lnpc)}{p_end}

{pstd}SAC model{p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp, fe model(sac) wmat(usaww) emat(usaww)}{p_end}

{pstd}SEM model{p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp, re model(sem) emat(usaww)}{p_end}

{pstd}GSPRE model{p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp, model(gspre) error(1) wmat(usaww) emat(usaww)} {p_end}


{title:References}

{phang}
Lee L.-f., de Jong, R. and Yu J., 2008. 
Quasi-maximum likelihood estimators for spatial dynamic panel data with fixed effects when both n and T are large
Journal of Econometrics, 146, pp. 118-134.

{phang}
Lee L.-f., Yu J., 2010. 
Estimation of spatial autoregressive panel data models with fixed effects.
Journal of Econometrics, 154, pp. 165-185.

{phang}
Elhorst P., 2010. 
Spatial Panel Data Models.
Handbook of applied spatial analysis. Edited by Fisher, M.M., Getis, A..

{phang}
Cameron A. C., Gelbach J. B. and Miller D. L., 2011.
Robust Inference With Multiway Clustering.
Journal of Business & Economic Statistics, 29(2) pp.  238-249. 


{title:Saved results}

{pstd}
{cmd:xsmle} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(t_max)}}number of periods{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(converged)}}1 if the model converged, 0 otherwise{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(k_exp)}}number of ancillary parameters{p_end}
{synopt:{cmd:e(df_r)}}model residual degrees of freedom{p_end}
{synopt:{cmd:e(a_avg)}}mean of fixed-effects{p_end}
{synopt:{cmd:e(sigma_a)}}standard deviation of random-effects{p_end}
{synopt:{cmd:e(sigma_e)}}standard deviation of idiosyncratic errors{p_end}
{synopt:{cmd:e(rank)}}rank of the variance-covariance matrix{p_end}
{synopt:{cmd:e(k_eq)}}number of equations{p_end}
{synopt:{cmd:e(r2_w)}}R-squared within model{p_end}
{synopt:{cmd:e(r2)}}R-squared overall model{p_end}
{synopt:{cmd:e(r2_b)}}R-squared between model{p_end}
{synopt:{cmd:e(hau_chi2_df)}}Hausman test degrees of freedom{p_end}
{synopt:{cmd:e(hau_chi2_p)}}Hausman test degrees p-value{p_end}
{synopt:{cmd:e(hau_chi2)}}Hausman test statistic{p_end}



{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xsmle}{p_end}
{synopt:{cmd:e(transf_type)}}type of data transformation{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(dlag)}}time-lagged dependent variable{p_end}
{synopt:{cmd:e(dlag_type)}} type of dynamic model {p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(type)}}type of fixed effects{p_end}
{synopt:{cmd:e(effects)}} fixed or random effects {p_end}
{synopt:{cmd:e(model)}} estimated spatial model{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(rhsvar)}}names of independent variables{p_end}
{synopt:{cmd:e(drhsvar)}}names of spatially lagged independent variables{p_end}
{synopt:{cmd:e(nocons)}}equal to 1 if intercept is not included in the model{p_end}
{synopt:{cmd:e(w_spmat_obj)}}equal to 1 if wmat() matrix is a spmat object{p_end}
{synopt:{cmd:e(e_spmat_obj)}}equal to 1 if emat() matrix is a spmat object{p_end}
{synopt:{cmd:e(d_spmat_obj)}}equal to 1 if dmat() matrix is a spmat object{p_end}
{synopt:{cmd:e(wmatrix)}} name of the spatial weighting matrix wmat() {p_end}
{synopt:{cmd:e(ematrix)}} name of the spatial weighting matrix emat() {p_end}
{synopt:{cmd:e(dmatrix)}} name of the spatial weighting matrix dmat() {p_end}
{synopt:{cmd:e(marginsok)}} predictions allowed by margins  {p_end}
{synopt:{cmd:e(covariates)}} names of independent variables {p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of ml method{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(score)}}score matrix{p_end}
{synopt:{cmd:e(hessian)}}hessian matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log vector{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Gordon Hughes{p_end}
{pstd}University of Edinburgh{p_end}
{pstd}Edinburgh, UK{p_end}
{pstd}g.a.hughes@ed.ac.uk{p_end}

{pstd}Andrea Piano Mortari{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}andrea.piano.mortari@uniroma2.it{p_end}


{title:Also see}

{psee}
Online: {help xsmle postestimation##xsmle postestimation:xsmle_postestimation}, {helpb spreg}, {helpb spivreg},
               {helpb spmat}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}


