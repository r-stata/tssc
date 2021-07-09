{smcl}

{title:[XT] xtprobitunbal}

{p 4 4 2}
Estimates Dynamic Correlated Random Effects Probit Models with Unbalanced Panels


{title:Syntax}

{p 8 8 2} {bf:xtprobitunbal} {depvar} {indepvars} {ifin}, {ul:means}var({varlist}) [{it:options}]


{col 5}{it:Option}{col 26}{it:Description}
{space 4}{hline 72}
{col 5}Subpanels
{col 5}{bf: } {bf:{ul:gen}subp({newvar})}{col 26}specify a variable name where the subpanel index
{col 5}{bf: }{col 26}{bf: } is stored
{col 5}{bf: } {bf:{ul:ind}ep}{col 26}if set, subpanels are defined {bf:only} by the initial
{col 5}{bf: }{col 26}{bf: } period
{col 5}{bf: }
{col 5}ML options
{col 5}{bf: } {bf:{ul:niter}at(#)}{col 26}use # number of iterations in each subpanel
{col 5}{bf: }{col 26}{bf: } correlated random effects probit;
{col 5}{bf: }{col 26}{bf: } default is  {bf:niterat(50)}
{col 5}{bf: } {bf:quatp(#)}{col 26}use # number of quadrature points in each subpanel
{col 5}{bf: }{col 26}{bf: }  correlated random effects probit;
{col 5}{bf: }{col 26}{bf: }  default is {bf:quatp(12)}
{space 4}{hline 72}
{p 4 4 2}
{it:depvar} and {it:indepvars} are mandatory and cannot contain factor variables.    {break}

{p 4 4 2}
By default, the lag of {it:depvar} is included as an additional explanatory variable of the model.

{p 4 4 2}
{it:meansvar(varlist)} should specify a list of variables the means of which are included in the reduced form for the initial condition equation.

{p 4 4 2}
After this command is run, users will typically use {helpb mgf_unbal} to obtain marginal effects.



{title:Description}

{p 4 4 2}
This command implements the method discussed in Albarran et al. (2019) to estimate dynamic correlated random effects probit models with unbalanced panels. 
A correlated random effect model is estimated for each subpanel and then the common parameters are recovered by minimum distance. This method is asymptotically equivalent to the maximum likelihood estimator, but reduces its computational burden. 



{title:Remarks}

{p 4 4 2}
The command {bf:xtprobitunbal} requires {helpb xtset} to be run in advance to declare the panel structure, using a panel variable (which identifies each individual) and, optionally, a time variable.

{p 4 4 2}
By default, a {bf:subpanel} is defined as each of the different time patterns in the data set, defined by the first and last time period in which an individual is observed; these patterns are shown by the command {helpb xtdescribe}. 
In this case, observations for which the first and final periods are the same belong to the same subpanel. 
Under this setting, the {bf:xtprobitunbal} command allows for the unbalancedness process to be correlated with the time-invariant unobserved heterogeneity. 

{p 4 4 2}
The command {bf:xtprobitunbal} can alternatively consider a subpanel to be defined only by the initial period; thus, individuals with the same initial period belongs to the same subpanel. 
If subpanels are defined in this manner, {bf:xtprobitunbal} estimates the econometric model under the underlying assumption that the unbalancedness is independent of the initial condition. See Albarran et al. (2019) for further technical details.

{p 4 4 2}
Note that the econometric method requires each subpanel to contain at least three time observations per individual and to have enough variation for the estimation of the correlated random effects model for each subpanel. 
These conditions also apply to the maximum likelihood estimator. 
If any of these requirements are not met in a given subpanel, this will be excluded in the first stage of the procedure. When this happens, the command output informs the user and the procedure continues with all the remaining valid subpanels.



{title:Examples}

{p 4 4 2}
	Setup: the examples bellow require the package to be installed with ancillary files

{p 4 4 2}
		{bf:. ssc install xtprobitunbal, all replace}

{p 4 4 2}
	Load the data

{p 4 4 2}
		{bf:. sysuse exportunbal}

    Estimate a model for the export dummy on its lag and four additional exogenous variables, with the mean of two of them included in the reduced form for the initial condition

{p 4 4 2}
		{bf:. xtprobitunbal export size trend med_skill age, meansvars(size med_skill)}

{p 4 4 2}
	Same model as above, but estimated assuming that the unbalancedness is independent of the initial condition.

{p 4 4 2}
		{bf:. xtprobitunbal export size trend med_skill age, meansvars(size med_skill) indep}



{title:Stored results}

{p 4 4 2}
{bf:xtprobitunbal} generates two variables:

{p 8 8 2} {bf:_touse_xtprobitunbal_} : this variable takes on value 1 if an observation in the dataset has been used in estimation, and 0 otherwise 

{p 8 8 2} {bf:_subpanel_xtprobitunbal_} : unless the user explicitly provide another variable name with the option {bf:gensubp(newvar)}, the subpanel index is stores in this variable. This index tells the subpanel to which each observation belongs.


{p 4 4 2}
{bf:xtprobitunbal} stores the following in {bf:e()}:

{p 4 4 2}{bf:Scalars:}

{p 8 8 2}  {bf:e(N)}     :  Total number of observations used in estimation    {break}

{p 8 8 2}  {bf:e(n_i)}   :  Number of individuals used in estimation    {break}

{p 8 8 2}  {bf:e(nsubp)} :  Number of subpanels included in estimation      {break}

{p 8 8 2}  {bf:e(llike)} :  log likelihood    {break}

{p 8 8 2}  {bf:e(maxSP0)}:  Maximum number of subpanels in the dataset    {break}

{p 4 4 2}{bf:Macros:}

{p 8 8 2}  {bf:    e(subpsN)} : String list of the number of subpanels used in estimation

{p 8 8 2}  {bf:     e(subps)} : Same as above, but each number is preceded by string "Subpanel_"

{p 8 8 2}  {bf: e(meansvars)} : Name of the variables the mean of which are included in the reduced form of the initial condition

{p 8 8 2}  {bf:  e(controls)} : Name of the exogenous control variables

{p 8 8 2}  {bf: e(subpn_var)} : Name of the variable that stores the subpanel index

{p 8 8 2}  {bf: e(touse_var)} : Name of the variable indicating if an observation has been used in estimation 

{p 8 8 2}  {bf:       e(cmd)} : {bf:xtprobitunbal}

{p 8 8 2}  {bf:e(properties)} : {bf:b} {bf:V}

{p 8 8 2}  {bf:    e(depvar)} : Name of the dependent variable


{p 4 4 2}{bf:Matrices:}

{p 8 8 2} {bf:     e(b)} :  coefficient vector of the common parameters 

{p 8 8 2} {bf:     e(V)} :  variance-covariance matrix of the estimates of the common parameters

{p 8 8 2} {bf:e(finalB)} :  coefficient vector with all the parameters in the model, i.e., common parameters and parameters in the reduced form of the initial condition for each subpanel

{p 8 8 2} {bf:e(finalV)} :  variance-covariance matrix of the estimates of all the parameters in the model



{title:Authors}

{p 4 4 2}
Pedro Albarran    {break}
Universidad de Alicante    {break}
{it:albarran@ua.es}    {break}


{p 4 4 2}
Raquel Carrasco    {break}
Universidad Carlos III de Madrid     {break}
{it:rcarras@eco.uc3m.es}


{p 4 4 2}
Jesus M. Carro    {break}
Universidad Carlos III de Madrid    {break}
{it:jcarro@eco.uc3m.es}    {break}



{title:License}

{p 4 4 2}
This code is licensed under GPLv3


{title:References}

{p 4 4 2}
Albarran, P., R. Carrasco and J. Carro. 2019.  {browse "https://onlinelibrary.wiley.com/doi/abs/10.1111/obes.12308":Estimation of Dynamic Nonlinear Random Effects Models with Unbalanced Panels}. {it:Oxford Bulletin of Economics and Statistics}, 81(6), 1424-1441.



