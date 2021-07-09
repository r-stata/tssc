
{smcl}
{* *! Version 1.1.0 by Francisco Perales & Reinhard Schunck 16-May-2017}{...}
{bf:help xthybrid}
{hline}


{title:Title}

    {bf:xthybrid} - Estimates hybrid and correlated random effect/Mundlak mixed effect models for linear and non-linear outcomes

{title:Syntax}

{p 8 12}{cmd:xthybrid} {depvar} {indepvars} {ifin} , clusterid({it:varname}) [{it:options}]


{it:options}		   	description
{hline}
Main
{synopt:{opt c:lusterid}{it:(varname})} specifies the cluster/grouping variable{p_end}
{synopt:{opt f:amily}{it:(type})} specifies the distribution of the outcome variable{p_end}
{synopt:{opt l:ink}{it:(type})} specifies the link function{p_end}
{synopt:{opt cre}} requests a correlated random effect model instead of a hybrid model{p_end}
{synopt:{opt n:onlinearities}{it:(type})} adds polynomial functions of the cluster means to the model{p_end}
{synopt:{opt random:slope}{it:(varlist})} requests random slopes on the random-effect and within-group coefficients of selected variables{p_end}
{synopt:{opt u:se}{it:(varlist})} splits between- and within-cluster effects only for selected explanatory variables{p_end}
{synopt:{opt perc:entage}{it:(#})} sets the minimum % within-cluster variance for explanatory variables to be considered cluster-varying{p_end}
{synopt:{opt te:st}} presents results of tests of the random effect assumption for separate model variables{p_end}
{synopt:{opt f:ull}} prints the full model output{p_end}
{synopt:{opt st:ats}{it:(list})} allows users to select which model summary statistics are reported{p_end}
{synopt:{opt se}} requests standard errors for the parameters on model variables{p_end}
{synopt:{opt t}} requests t-values for the parameters on model variables{p_end}
{synopt:{opt p}} requests p-values for the parameters on model variables{p_end}
{synopt:{opt star}} requests stars to denote statistically significant parameters on model variables{p_end}
{synopt:{opt vce}} specifies the type of standard error to be reported{p_end}
{synopt:{opt it:erations}} requests that the command is executed noisily{p_end}
{synopt:{opt keep:vars}} requests that any new variables created by the command are retained {p_end}
{synopt:{opt meglm:opts}{it:(list})} enables the user to request options from the {cmd:meglm} command{p_end}
{hline}


{title:Description}

{p 0 4}	{cmd:xthybrid} estimates linear and non-linear mixed effect regression models that split the effects of cluster-varying covariates on
the outcome variable into within-cluster and between-cluster effects (Schunck 2013, Schunck & Perales 2017). This is accomplished by: (i)
specifyng cluster-varying variables in {indepvars} as deviations from the cluster mean, and (ii) adding the cluster means of the original cluster-varying variables
to the model. In the linear case, this can be expressed as:

						Y{it:ij} = A + B{it:1}*Z{it:i} + B{it:2}*(X{it:ij}-X_bar{it:i}) + B{it:3}*X_bar{it:i} + u{it:i} + e{it:ij}

{p 4 4}	where B{it:2} captures the within-cluster effect of cluster-varying variables on Y{it:ij}, and B{it:3} captures the between-cluster effect of
cluster-varying variables on Y{it:ij}. This technique, discussed in Allison (2009), is related to the correlated random effect model originally
proposed by Mundlak (1978), also known as the Mundlak model. If no variables vary within clusters, {cmd:xthybrid} estimates a standard mixed effect
model and displays a warning. The between-cluster effects are given by the cluster-mean variables beginning with the prefix {cmd:B__} while
the within-cluster effects are given by the cluster-mean differenced variables beginning with the prefix {cmd:W__}. The prefix {cmd:R__} is used to
denote variables for which the coefficient is the 'standard' random effect coefficient. Model estimates are kept in Stata's background memory and
can be accessed via {cmd:estimates dir}.

{p 4 4}	The {cmd:xthybrid} routine is an expansion of the {cmd:mundlak} command, but unlike the latter it allows for non-linear models.
Specifically, {cmd:xthybrid} can fit any 2-level specification covered by Stata's native routine {cmd:meglm}.


{title:Options}
	
{p 0 4}	{cmdab:c:lusterid}{it:(variable}) specifies the variable in the dataset that will be used as the cluster/grouping variable (i.e. the Level 2 ID variable).

{p 0 4}	{cmdab:f:amily}{it:(type}) specifies the distribution of the outcome variable. This option supports the following family types: gaussian, bernoulli,
binomial, gamma, nbinomial, ordinal, and poisson. When {cmd:family} is not specified, 'gaussian' is used by default.

{p 0 4}	{cmdab:l:ink}{it:(type}) specifies the link function. This option supports the following link types: identity, log, logit, probit, and cloglog.
When {cmd:link} is not specified, 'identity' is used by default. Note that certain combinations of families and links are not possible. Linear models
equivalent to those estimated by {cmd:mundlak} can be fitted in {cmd:xthybrid} by specifyng the family as 'gaussian' and the link as 'identity'.
The same can be accomplished by not specifying either of these options (i.e. linear models are the default).

{p 0 4}{cmdab:cre} estimates the model without transforming the original explanatory variables into cluster-mean deviations. In practice, when this option
is used {cmd:xthybrid} estimates a correlated random effect model as described in Mundlak (1978) (i.e. the Mundlak model). In the linear case, this can be expressed as:
 
						Y{it:ij} = A + B{it:1}*Z{it:i} + B{it:2}*X{it:ij} + B{it:3}*X_bar{it:i} + v{it:ij}

{p 4 4}	where B{it:2} captures the within-cluster effect of cluster-varying variables on Y{it:ij}, and B{it:3} now captures the difference between the between-cluster
and within-cluster effects of cluster-varying variables on Y{it:ij}. The within-cluster effects are denoted by variables with the prefix {cmd:B__}, the differences between
the between-and within-cluster effects are denoted by variables with the prefix {cmd:D__}, and the random effects are denoted by variables with the prefix {cmd:R__}. 

{p 0 4}	{cmdab:n:onlinearities}{it:(type}) adds polynomial functions of the cluster means to the model. This option supports the following: quadratic, cubic, quartic.

{p 0 4}	{cmdab:random:slope}{it:(varlist}) requests that random slopes are estimated on the random-effect and within-group coefficients of selected variables. Users need
only specify the name of the original variable. Note that estimation of these random slope models can be time consuming.

{p 0 4}{cmdab:u:se}{it:(varlist}) specifies the variables for which between- and within-cluster effects will be displayed in the model. The default is to
use all the variables in {indepvars} which vary within clusters. If the variables specified in {cmd: use} do not vary within clusters, {cmd:xthybrid} will
display a warning.

{p 0 4}{cmdab:perc:entage}{it:(#}) suppresses the separation of between- and within-cluster effects of variables for which within-cluster
variance accounts for a percentage of the total variance lower than {it:#}. When {cmd:percentage} is not specified {cmd:xthybrid}
operates as if {it:#} was 0. If {cmd:use} is also specified, {cmd:xthybrid} will evaluate the percentage of the total variance 
which is within clusters for the variables set in this option.
 
{p 0 4}{cmdab:te:st} requests the results of tests of the random effect assumption for separate explanatory variables to be displayed. For the hybrid model,
these take the form: {it:_b[B__varname] = _b[W__varname]}. When the {cmd:cre} option is also specified, the tests take the form {it:_b[D__varname] = 0}.
When the {cmd: test} option is specified with the {cmd: nonlinearities} option, the results of tests of whether the nonlinear effects are equal to 0 are also shown.
 
{p 0 4}{cmdab:f:ull} requests the full regression output for the estimated model.
 
{p 0 4}{cmdab:st:ats} allows users to request a different set of model summary statistics. This can include any scalars from Stata's {cmd:meglm} routine.

{p 0 4}{cmdab:se} requests the standard errors for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:t} requests the t-values for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:p} requests the p-values for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:star} requests that stars be used to denote statistically significant parameters on model variables at the 95 (5%), 99 (1%) and 99.9 (0.1%) levels.
Specyfying the {cmdab:star} option overrules {cmd:se}, {cmd:p} and {cmd:t}. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:vce} specifies the type of standard error to be reported. This option supports the following error types: 'oim', 'robust' and 'cluster' {it:clustervar}.

{p 0 4}{cmdab:keep:vars} requests that any new variables created by the command are retained. The names for these new variables will begin with the prefix B__, W__ or R__.
Users will need to manually remove these variables from the data before executing {cmd:xthybrid} again.

{p 0 4}{cmdab:it:erations} requests that the command is executed noisily.

{p 0 4}{cmdab:meglm:opts}{it:(list}) enables the user to request additional options out of those available for the {cmd:meglm} command. Please note that not all
such options are compatible with {cmd:xthybrid} and that error messages produced by {cmd:meglm} will not be displayed.

{title:Examples}

{p 4 8}{inp:. webuse nlswork, clear}{p_end}

{p 4 8}{inp:. generate white = race==1 & race!=.}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(gaussian) link(identity)}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(gaussian) link(identity) cre}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) nonlinearities(cubic)}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) use(age)}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) percentage(45)}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) test}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) full}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) stats(N k df_m ll chi2 ll_c chi2_c df_c)}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) se t p}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) star}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) randomslope(age) star}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) randomslope(age) star iterations}{p_end}

{p 4 8}{inp:. xthybrid union age south white, clusterid(idcode) family(binomial) link(logit) randomslope(age) cre star}{p_end}

{title:Also see}

	Online: {manhelp meglm R}
	
	Online: MUNDLAK - Stata module to estimate random-effects regressions adding group-means of independent variables to the model
		{browse "https://ideas.repec.org/c/boc/bocode/s457601.html"}
		{inp:. ssc install mundlak}

		
{title:References}

 Allison, P. D. (2009) {it:"Fixed Effects Regression Models"} Thousand Oaks
 
 Mundlak, Y. (1978) "On the Pooling of Time Series and Cross-section Data" {it:Econometrica}, 46: 69-85
 
 Schunck, R. (2013). "Within and Between Estimates in Random Effects Models: Advantages and Drawbacks of Correlated Random Effects and Hybrid Models".
 {it:Stata Journal}, 13 (1): 65-76
 
 Schunck, R. & Perales, F. (2017). "Within- and Between-Cluster Effects in Generalized Linear Mixed Models: A Discussion of Approaches and the {it:xthybrid} Command".
 {it:Stata Journal} 17 (1): 89-115
 
{title:Authors}

{p 2 4}Francisco Perales{p_end}
{p 2 4}ARC Centre of Excellence for Children and Families over the Life Course{p_end}
{p 2 4}Institute for Social Science Research, The University of Queensland{p_end}
{p 2 4}f.perales@uq.edu.au{p_end}
	
{p 2 4}Reinhard Schunck{p_end}
{p 2 4}GESIS - Institute for the Social Sciences, Cologne, Germany{p_end}
{p 2 4}reinhard.schunck@gesis.org{p_end}
	
	                 
