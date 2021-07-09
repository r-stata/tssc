
{smcl}
{* *! Version 1.1.0 by Francisco Perales 04-February-2013}{...}
{bf:help mundlak}
{hline}


{title:Title}

    {bf:mundlak} -  Estimates random-effects regressions adding group-means of independent variables to the model

{title:Syntax}

{p 8 12}{cmd:mundlak} {depvar} {indepvars} {ifin} [, {it:options}]


{it:options}		   description
{hline}
Main
 {cmdab:u:se}({varlist})      adds group-means of selected independent variables only
 {cmdab:perc:entage}{it:(#}) 	   sets the minimum percentage of total variance due to within-group variation required of an independent variable to be used
 {cmdab:nocomp:arison} 	   supresses the display of a comparison random-effects model with no added variables
 {cmdab:hyb:rid} 	   transforms the independent variables into group-mean deviations
 {cmdab:f:ull} 		   prints the full output for the estimated models
 {cmdab:st:ats}{it:(list})	   allows users to select the model statistics to be reported
 {cmdab:se} 	           asks for standard errors for the parameters on model variables to be reported
 {cmdab:t} 	           asks for p-values for the parameters on model variables to be reported
 {cmdab:p} 	           asks for t-values for the parameters on model variables to be reported
 {cmdab:k:eep} 	           asks for any variables created by the command to be kept in the dataset

{hline}


{title:Description}

{p 0 4}	{cmd:mundlak} estimates random-effects regression models ({cmd:xtreg, re}) adding group-means
 of variables in {indepvars} which vary within groups. This technique was proposed by Mundlak (1978)
 as a way to relax the assumption in the random-effects estimator that the observed variables are uncorrelated
 with the unobserved variables. Additionally, the degree of statistical significance of the estimated coefficients
 on the group means can be used to test whether such assumption holds for individual regressors. See also Chapter 10
 in Wooldridge (2010) and Chapter 11 in Greene (2011). The command {cmd:mundlak} requires the data to be {cmd:xtset}. If no
 variables vary within-groups, {cmd:mundlak} estimates the standard random-effects model with no additional
 variables and displays a warning message. The names of the added group-mean variables will begin with the prefix {cmd:mean__}
 followed by the original variable name. Note that the estimates from both the standard random-effects
 model and the Mundlak model are kept in Stata's background memory and can be accessed via {cmd:estimates dir}
 for further usage.

	Original random-effects model:		Y{it:ij} = A + B{it:1}*X{it:ij} + B{it:2}*Z{it:i} + v{it:ij}

	Mundlak model:				Y{it:ij} = A + B{it:1}*X{it:ij} + B{it:2}*Z{it:i} + B{it:3}*X_bar{it:i} + v{it:ij}


{title:Options}
	
{p 0 4}{cmdab:u:se}({varlist}) specifies the variables for which group-means will be added in the model. The
 default is to use all the variables within the provided list of independent variables which vary within groups,
 unless such variation is insufficient. The variables specified in this option do not need to be among those in
 {varlist}, although that would be most common. If the variables specified in this option do not vary within groups,
 {cmd:mundlak} will display an error message.

{p 0 4}{cmdab:perc:entage}{it:(#}) suppresses the inclusion in the model of group-means of variables for which within-group
 variance accounts for a percentage of the total variance lower than {it:#}. When {cmd:percentage}{it:(#})
 is not specified {cmd:mundlak} operates as if {it:#} was 0. However, note that when 0% of the total variance of a given
 variable is within-groups, the group-mean of such variable cannot be included in the regression due to collinearity.
 If {cmd:use} ({varlist}) is also specified, {cmd:mundlak} will evaluate the percentage of the total variance which is
 within-groups for the variables set in this option, and will only include their group-means in the Mundlak
 model if they satisfy the criteria in {cmd:percent}{it:(#}).

{p 0 4}{cmdab:nocomp:arison} prevents the display of results from the original random-effects model. By default,
 {cmd:mundlak} displays the results from both the original random-effects model and the Mundlak model which
 includes the additional independent variables.

{p 0 4}{cmdab:hyb:rid} transforms the original independent variables into group-mean deviations, in
 addition to adding their group-means as additional independent variables. In practice, when this option
 is used {cmd:mundlak} estimates a 'hybrid model' equivalent to that described in Chapter 2 of Allison (2009). This
 can be expressed as:
 
						Y{it:ij} = A + B{it:1}*(X{it:ij}-X_bar{it:i}) + B{it:2}*Z{it:i} + v{it:ij}
 
{p 0 4} The names for the added group-mean differenced variables will begin with the prefix {cmd:diff__} followed by the original variable name.
 
{p 0 4}{cmdab:f:ull} asks for the full regression output for both the original random-effects model and the
 Mundlak model to be displayed. When {cmd:full} is specified together with {cmd:nocomp} only the full output
 for the Mundlak model is displayed.
 
{p 0 4}{cmdab:st:ats} allows users to specify the model summary statistics to be reported. These can be any scalars from Stata's {cmd:xtreg, re} routine.

{p 0 4}{cmdab:se} asks for the standard errors for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:t} asks for the t-values for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:p} asks for the p-values for the parameters on model variables to be reported. Note that specifying the option {cmd:full} overcomes this.

{p 0 4}{cmdab:k:eep} asks for the new variables (i.e. group-means and group-mean deviations) to be kept in the dataset.


{title:Examples}

{p 4 8}{inp:. webuse nlswork, clear}{p_end}

{p 4 8}{inp:. xtset idcode year}{p_end}

{p 4 8}{inp:. mundlak ln_wage age south race}

{p 4 8}{inp:. mundlak ln_wage age south race, use(age)}

{p 4 8}{inp:. mundlak ln_wage age south race, percentage(45)}

{p 4 8}{inp:. mundlak ln_wage age south race, nocomparison}

{p 4 8}{inp:. mundlak ln_wage age south race, hybrid}

{p 4 8}{inp:. mundlak ln_wage age south race, full}

{p 4 8}{inp:. mundlak ln_wage age south race, stats(N N_g rho r2_o r2_w r2_b)}

{p 4 8}{inp:. mundlak ln_wage age south race, se t p}

{p 4 8}{inp:. mundlak ln_wage age south race, keep}

{p 4 8}{inp:. describe mean__*}


{title:Also see}

	Online: {manhelp xtreg R}


{title:References}
 
 
 Allison, P. D. (2009) {it:"Fixed-Effects Regression Models"} Thousand Oaks
 
 Greene, W. (2011) {it:"Econometric Analysis (7th edition)"} Prentice Hall
 
 Mundlak, Y. (1978) "On the Pooling of Time Series and Cross-section Data" {it:Econometrica}, 46: 69–85
 
 Wooldridge, J. M. (2010) {it:"Econometric Analysis of Cross Section and Panel Data (2nd edition)"} MIT Press
 
 
{title:Author}

    Francisco Perales
    School of Social Science
    The University of Queensland
    Brisbane
    QLD 4072
    Australia
    f.perales@uq.edu.au
	
	                 