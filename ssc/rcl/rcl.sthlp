{smcl}
{* 07Aug2016}{...}
{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :rcl}Random coefficient logit models: estimation and simulation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:rcl} {it:sharevar} [{it:varlist_iexog}]
{cmd:[(}{it:varlist_endog}{cmd:=}{it:varlist_iv}{cmd:)]}
{cmd} {ifin}
{cmd:,} {opt market(marketvar)}
[{it:options}]


{synoptset 29 tabbed}{...}
{synopthdr:main variables}
{synoptline}
{synopt :{it:sharevar}}market share variable; compulsory to specify{p_end}
{synopt :{it:varlist_iexog}}exogenous product characteristics (to be included 
in the mean utility function){p_end}
{synopt :{it:varlist_endog}}endogenous product characteristics; if specified, 
the first variable is assumed to be the price variable; if not specified, 
price is assumed to be the first variable of {it:varlist_iexog}{p_end}
{synopt :{it:varlist_iv}}instrumental variables (excluded exogenous 
variables){p_end}


{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt market:(marketvar)}}{it:marketvar} is the indicator variable 
identifying markets; compulsory to specify{p_end}
{synopt :{opt rc:(varlist)}}variables with random coefficient in the BLP 
model{p_end}
{synopt :{opt nests:(varlist)}}indicator variables of nests, subnests, 
sub-subnests in the nested logit model, in this order{p_end}
{synopt :{opt msize:(varname)}}{it:varname} is the potential market size; if 
not specified, default is value 1 for all markets{p_end}
{synopt :{opt int:egrationmethod(string)}}method of integral simulation for the 
BLP model; may be {opt sparsegrid} (default) or {opt mc}{p_end}
{synopt :{opt itol(real)}}tolerance bound of inner loop iterations for the BLP 
model; default is 10e-12{p_end}
{synopt :{opt imaxiter(integer)}}maximum number of inner loop iterations for 
the BLP model; default is 2500{p_end}
{synopt :{opt acc:uracy(integer)}}accuray of sparse grid integration for the 
BLP model; default is 6{p_end}
{synopt :{opt draws(integer)}}number of draws in Monte Carlo integration for 
the BLP model; default is 500{p_end}
{synopt :{opt nodisp:lay}}suppress output printed on screen{p_end}

{syntab :Estimation}
{synopt :{it:method}}estimation method, may be {opt gmm2:s} (two-step GMM), 
{opt igmm} (iterated GMM), {opt cue} (CUE GMM), {opt tsls} (three-stage least 
squares, if {opt eqestimation is specified}); if no method is specified, 
two-stage least squares is used{p_end}
{synopt :{opt opt:imal}}use optimal instruments for estimation{p_end}
{synopt :{opt r:obust}}heteroscedasticity robust standard errors{p_end}
{synopt :{opt cluster:(varname)}}cluster robust standard errors with clustering 
on {it:varname}{p_end}
{synopt :{opt startp:arams(matrix)}}rowvector of starting values of random 
coefficients for the BLP model (if rc() is specified){p_end}
{synopt :{opt eqest:imation}}joint estimation of demand and pricing 
equation{p_end}
{synopt :{opt xp:(varlist)}}included exogenous variables in the pricing 
equation; default is {it: varlist_iexog} and polinomials of 
{it: varlist_iv}{p_end}
{synopt :{opt pi:nstruments(varlist)}}instruments (excluded exogenous 
variables) for the pricing equation; default is {it: varlist_iv}{p_end}
{synopt :{opt startp:arams(matrix)}}rowvector of starting values of random 
coefficients and price coefficient for the BLP model (if rc() or eqestimation 
is specified){p_end}
{synopt :{opt nocon:stant}}suppress constant term; default is to add constant 
to {it:varlist_iexog} if not collinear{p_end}
{synopt :{opt nocollin:}}suppress checks for collinearities and duplicate 
variables{p_end}

{syntab :Elasticities, merger simulation, marginal costs, SSNIP test}
{synopt :{opt elas:ticities(varname)}}calculate elasticites for product groups 
indicated by {it:varname}{p_end}
{synopt :{opt msimul:ation(varlist)}}perform merger simulation, firm variable 
for pre- and post-merger ownership is the first and second variable of 
{it:varlist}, respectively{p_end}
{synopt :{opt mc:(varname)}}user specified marginal costs; if not specified 
(default) model implied marginal costs are used{p_end}
{synopt :{opt onlymc:}}no merger simulation is performed, only the marginal 
costs implied by the pre-merger ownership are caclulated and saved into 
__mc{p_end}
{synopt :{opt cmce:}}calculate compensating marginal cost efficiencies, implied 
reduced marginal costs saved into __mce{p_end}
{synopt :{opt ssnip:(varlist)}}perform SSNIP test of product groups identified 
by the first variable of {it:varlist}, second variable gives the product 
ownership for implied marginal cost calculation{p_end}
{synopt :{opt vat:(varname)}}VAT rate contained in prices 
(between 0 and 1){p_end}

{syntab :Simulation without estimation}
{synopt :{opt noest:imation}}no estimation performed, required to specify for 
simulation without estimation{p_end}
{synopt :{opt alpha(real)}}negative of the mean coefficient on the price 
variable (>0){p_end}
{synopt :{opt sigmas(numlist)}}nested logit sigmas on nests, subnests, 
sub-subnests, in this order (0<=s_nest<=s_subnest<=s_subsubnest<1){p_end}
{synopt :{opt rcsigmas(numlist)}}random coefficients in the BLP model, in the 
same order as the variables in the option rc() (>0){p_end}
{synopt :{opt xb0:(varname)}}user specified non-price part of observed part of 
mean utility; not required to specify for simulation without estimation{p_end}
{synopt :{opt ksi:(varname)}}user specified unobserved part of mean utility; 
not required to specify for simulation without estimation{p_end}
{synoptline}



{title:Contents}
{p 2}{help rcl##s_description:Description}{p_end}
{p 2}{help rcl##s_main:Main options}{p_end}
{p 2}{help rcl##s_estimation:Estimation options}{p_end}
{p 2}{help rcl##s_elasticities:Elasticities, merger simulation, marginal costs, SSNIP test}{p_end}
{p 2}{help rcl##s_noest:Simulation without estimation}{p_end}
{p 2}{help rcl##s_remarks:Remarks}{p_end}
{p 2}{help rcl##s_examples:Examples}{p_end}
{p 2}{help rcl##s_stored:Stored results}{p_end}
{p 2}{help rcl##s_refs:References}{p_end}

{marker s_description}{title:Description}

{p}{cmd:rcl} estimates and simulates random coefficient logit models using 
product level data. The models covered include the random coefficient logit 
model of {help rcl##BLP1995:Berry, Levinsohn and Pakes (1995)} (BLP), nested 
logit models (with one, two or three nesting level), as well as the simple 
logit model. The command can perform estimation, merger simulation and 
calculation of various descriptives (elasticities -grouped or product-level-, 
diversion ratios, implied marginal costs, compensating marginal cost 
efficiencies). {cmd:rcl} can also use pre-defined parameter values and/or 
marginal cost data in these simulations. Hence, it can be used as a basis for 
estimation, counter-factual simulation and calibration work as well as for 
data simulation.

{p}{cmd:rcl} implements the estimation algorithm of Berry, Levinsohn and Pakes 
(1995) for their model, and uses {help ivreg2} for the linear nested and 
simple logit models. The standard model diagnostics of {cmd:ivreg2} are 
reported for each estimated model.

{p} Requirements. Stata 11 or higher. {help ivreg2} and {help ranktest} need to 
be installed. (If not, type {stata "ssc install ivreg2"} and 
{stata "ssc install ranktest"}.)

{marker s_options}{title:Options}

{marker s_main}{dlgtab:Main}

{phang} {opt market:(marketvar)}{it:marketvar} is the indicator variable 
identifying markets; compulsory to specify.

{phang} {opt rc:(varlist)} variables with random coefficient in the BLP model. 
If not specified, the assumed model is either a nested logit model (if 
the {opt nests()} option is specified) or a simple logit model.

{phang} {opt nests:(varlist)} indicator variables of nests, subnests, 
sub-subnests in the nested logit model (see, e.g., 
{help rcl##MF1981:McFadden (1981)}), in this order. If not specified, the 
assumed model is either a BLP model (if the {opt rc()} option is specified) or 
a simple logit model.

{phang} {opt msize:(varname)} {it:varname} is the potential market size; if not 
specified, default is value 1 for all markets. Note that the product market 
shares given by {it:sharevar} are meant to be calculated on the potential 
market. Hence, the potential market size variable sets the share of the outside 
good of the model.

{phang} {opt int:egrationmethod(string)} method of integral simulation for the 
BLP model. It may be {opt sparsegrid} (default) or {opt mc}. {opt sparsegrid} 
implies the Smolyak sparse grid integration as implemented for Stata by the 
{cmd:nwspgr} command of {help rcl##HW2007:Heiss and Winschel (2007)}. As shown 
by {help rcl##JS2011:Judd and Skrainka (2011)}, this method is superior to 
Monte Carlo integration in terms of both speed and accuracy. Setting {opt mc} 
for the option implies Monte Carlo integration, with 500 draws (if 
{opt draws()} is not set otherwise).

{phang} {opt itol(real)} tolerance bound of inner loop iterations for the 
BLP model; the default is 10e-12.

{phang} {opt imaxiter(integer)} maximum number of inner loop iterations for the 
BLP model; the default is 2500.

{phang} {opt acc:uracy(integer)} accuray of sparse grid integration for the 
BLP model; the default is 6.

{phang} {opt draws(integer)} number of draws in Monte Carlo integration for the 
BLP model; the default is 500.

{phang} {opt nodisp:lay} suppress output printed on screen.


{marker s_estimation}{dlgtab:Estimation}

{phang} {it:method} estimation method, may be {opt gmm2:s} (two-step GMM), 
{opt igmm} (iterated GMM), {opt cue} ("continuously updated GMM estimator", 
only for linear models: nested and simple logit), {opt tsls} (three-stage least 
squares, if {opt eqestimation is specified}); if no method is specified, 
two-stage least squares is used. The linear models are estimated by 
{cmd:ivreg2} (see also {help rcl##BSS2007:Baum et al 2007} and 
{help rcl##BSS2010:2010}). The estimation is linear due to the 
log-linearization method described by {help rcl##B1994:Berry (1994)}. In the 
case of the BLP model, however, the same log-linearization does not lead to a 
standard linear estimating equation. Hence, the nested fixed-point estimation 
algorithm of BLP, {help rcl##N2000:Nevo (2000)} and {help rcl##N2001:(2001)} 
is implemented.

{phang} {opt opt:imal} use optimal instruments for estimation. 
{help rcl##CH1987:Chamberlain (1987)} shows that in a general GMM estimation 
framework, the instrument set which minimizes the variance of the estimator, 
that is, the "optimal" instrument set, is a function of the data and the 
model's parameters. Hence, in general optimal instrumenting is not feasible as 
the optimal instruments are not known prior to estimation. (In some specific 
cases optimal instrumenting is feasible. For example, in a linear model, under 
homoscedasticity and some assumptions about the structure of the underlying 
economic model, the two-stage least squares estimator is optimal. For 
non-linear models like BLP, however, this is no longer true, not even for 
the case with homoscedastic error terms.) In practice, approximations of the 
optimal instruments are feasible. {cmd:rcl} implements the two-step procedure 
described by {help rcl##RV2014:Reynaert and Verboven (2014)} to calculate 
an approximation of the optimal instruments and to estimate the model. The 
authors show that the procedure improves the statistical reliability and 
precision of the estimates. In the first step of the procedure, the standard IV 
estimates of the parameters are calculated using the instrumental variables in 
{it:varlist_iv}. These first-step estimates are then used to calculate the 
optimal instruments. The second step is the estimation of the model with the 
optimal instruments.

{phang} {opt r:obust} heteroscedasticity robust standard errors.

{phang} {opt cluster:(varname)} cluster robust standard errors with clustering 
on {it:varname}.

{phang} {opt startp:arams(matrix)} rowvector of starting values of random 
coefficients for the BLP model (if rc() is specified).

{phang} {opt eqest:imation} joint estimation of demand and pricing equation. 
{help rcl##RV2014:Reynaert and Verboven (2014)} show that joint estimation of 
the demand and pricing equations might result in more accurate estimates than 
single equation demand estimation. The pricing equation is derived in the 
following way. Assuming Bertrand (price) competition, the optimal markups can 
be calculated as a function of the model's parameters and the demand function. 
Price is then modelled as a sum of the implied markup and the marginal cost. 
This latter is assumed to be a linear function of the "cost shifters" given by 
the the option {opt xp:(varlist)}. (If that latter option is not specified the 
cost shifters are given by {it:varlist_iexog} and polinomials of 
{it:varlist_iv}.) To calculate the implied Bertrand markups, a product 
ownership structure has to be given. The user can specify this by the 
{opt msimulation()} option. For example, if {it:firm} is the categorical 
variable describing which product is owned by which firm, specifying 
msimulation({it:firm}) will tell this to the command. If {opt msimulation()} is 
not specified it is assumed that each product is owned by a separate, 
single-product firm. Note that if {opt msimulation()} specifies only one 
variable no merger simulation is carried out. The implied markups and 
marginal costs, evaluated at the estimated parameters, are saved into the 
variables __mrkp and __mc, respectively.

{phang} {opt xp:(varlist)} included exogenous variables in the pricing 
equation; the default is {it: varlist_iexog} and polinomials of 
{it: varlist_iv}.

{phang} {opt pi:nstruments(varlist)} instruments (excluded exogenous variables) 
for the pricing equation when ; the default is {it: varlist_iv}.

{phang} {opt startp:arams(matrix)} rowvector of starting values of random 
coefficients and price coefficient for the BLP model (if rc() or eqestimation 
is specified).

{phang} {opt nocon:stant} suppress constant term; the default is to add a 
constant variable to {it:varlist_iexog} if it is not collinear.

{phang} {opt nocollin:} suppress checks for collinearities and duplicate 
variables.


{marker s_elasticities}{dlgtab:Elasticities, merger simulation, marginal costs, SSNIP test}

{phang} {opt elas:ticities(varname)} calculate elasticity and diversion ratio 
(square) matrices for product groups indicated by {it:varname}. The elements of 
the matrices are quantity weighted averages across markets. The dimension of 
the matrices is equal to the number of uniqe elements in {it:varname}. If 
{it:varname} is the product identifier the resulting matrices are just the 
product level elasticities and diversion ratios. If {it:varname} identifies 
groups of products the results are the aggregated elasticities. If {it:varname} 
is a constant variable the result is the aggrate demand elasticity. The 
elasticity and diversion ratio matrices are stored as "el" and "dr", 
respectively.

{phang} {opt msimul:ation(varlist)} perform merger simulation, pre- and 
post-merger ownership of products, that is, the indicator of independent firms 
is the first and second variable of {it:varlist}, respectively. Merger 
simulation amounts to calculating the new Bertrand price equilibrium when the 
ownership structure of products is changed. The simple and nested logit models 
are solved using simple fixed-point iterations. For the BLP model, iterations 
between a quasi Newton-algorithm on the sum of squared normalized first order 
conditions of the Bertrand equilibrium and a quasi Newton-algorithm on the sum 
of squared price prediction errors are used. For the simple and nested logit 
models, the implied (pre-merger) marginal costs can be calculated using 
closed-form analytical formulas. For the BLP model, numerical matrix inversion 
is used. These implied margins are used as default, but specifying the 
{opt mc()} option one can use other margins as well (this can be the case, for 
example, in some calibration or data simulation works). If the two variables 
given in {it:varlist} are the same, the current equilibrium is calculated 
(again, this can be of use, for example, when a dataset of equilibrium prices 
and shares is simulated given model parameters and marginal costs). Finally, 
note that when no merger simulation is needed but one still wants to calculate 
the implied Bertrand marginal costs and markups (for example, when joint 
demand/pricing estimation is performed, see option {opt eqestimation}, or when 
simply the {opt onlymc} option is specified), it is sufficient to specify only 
one element in {it:varlist} that gives the product ownership structure. 
(Moreover, in the case of the joint demand/pricing estimation the 
{opt msimulation(varlist)} option can be entirely omitted, implying the 
assumption that each product is owned by a separate, single-product firm.) 
The post-merger prices, shares and equilibrium first order conditions, as well 
as the implied (pre-merger) markups and marginal costs are saved into the 
variables __p_post, __s_post, __foc_post, __mrkp and __mc, respectively.

{phang} {opt mc:(varname)} user specified marginal costs; if not specified 
(default) the model implied marginal costs are used.

{phang} {opt onlymc:} no merger simulation is performed, only the marginal 
costs and markups implied by the pre-merger product ownership and Bertrand 
competition are caclulated and saved into __mc and __mrkp, respectively. The 
pre-merger product ownership structure is given by the first variable 
specified in the {opt msimulation(varlist)} option (and note that in this case 
it is sufficient to specify only one element in the {it:varlist}).

{phang} {opt cmce:} calculate compensating marginal cost efficiencies. These 
are the implied post-merger marginal costs at which the merger would have no 
price effect (the prices at the new, post-merger equilibrium would be the same 
as the pre-merger prices). Hence, these new marginal costs give an indication 
on the level of marginal cost savings needed to compensate for the merger 
induced loss of competition between the mergin parties. (See also 
{help rcl##W1996:Werden (1996)}). The efficient marginal costs are saved into 
__mce. The option can be combined with the {opt onlymc} option. The pre-merger 
product ownership structure is given by the first variable specified in the 
{opt msimulation(varlist)} option (and note that in this case it is sufficient 
to specify only one element in the {it:varlist}).

{phang} {opt ssnip:(varlist)} perform SSNIP test of product groups identified 
by the first variable of {it:varlist}, with the second variable identifying the 
product ownership for the implied marginal cost calculation. SSNIP stands for 
"Small but Significant Non-transitory Increase in Price". The implemented 
version of the SSNIP test calculates for each product group separately the 
implied % change in the total profit generated by the group's products when the 
prices of the group's products are subject to a "SSNIP", that is, they are 
increased by 1, 5 or 10% uniformly (while the price of all other products are 
kept unchanged). The test is a measure of the overall demand side 
substitutability of the product group in question (with products not in the 
group), with positive profit changes indicating relatively weaker 
substitutability. See also {help rcl##IL2011:Ivaldi and Lorincz (2011)} for 
more discussion. The results are stored in the matrix "ssnip".

{phang} {opt vat:(varname)} VAT rate contained in prices (between 0 and 1). No 
need to specify it if the price variable is net of VAT.


{marker s_noest}{dlgtab:Simulation without estimation}

{phang} {opt noest:imation} no estimation performed, required to specify for 
simulation without estimation. In the main part of the command, it is 
sufficient to specify only the share and price variables (in this order, these 
are used as starting points for the equilibrium simulation). From the options, 
the {opt market()} option is still needed. This mode of operation can be used 
to calculate elasticities ({opt elasticities()}); equilibrium prices, shares, 
implied marginal costs or compensating marginal cost efficiencies 
({opt msimulation()}, {opt onlymc}, {opt cmce}); or SSNIP tests 
({opt ssnip()}). The outcome variables and matrices are saved as before; in 
particular __s_post and __p_post are the calculated equilibrium's market shares 
and prices, respectively. The typical use can be to replicate some simulation 
results for an already estimated model; simulate a new price equilibrium with 
change in product qualities (see option {opt xb0()} below); simulate new 
equilibrium datasets for given parameters, marginal costs (using the {opt mc()} 
option) and/or characteristics; or some combinations of these cases. Note that 
for the {opt msimulation()} option it is sufficient to specify only one 
variable.

{phang} {opt alpha(real)} negative of the mean coefficient on the price 
variable (>0). If a negative value is given its absolute value is used. If no 
value is specified the mean price coefficient is estimated from a regression of 
the mean utility on the price and other characteristics (if specified).

{phang} {opt sigmas(numlist)} nested logit sigmas on nests, subnests, 
sub-subnests, in this order (0<=s_nest<=s_subnest<=s_subsubnest<1).

{phang} {opt rcsigmas(numlist)} random coefficients in the BLP model, in the 
same order as the variables in the option rc() (>0).

{phang} {opt xb0:(varname)} user specified non-price part of observed part of 
mean utility; not required to specify for simulation without estimation. The 
non-price part of the observed part of mean utility is the observed mean 
"quality" of the product. In some simulations, the question to be investigated 
is how the equilibrium prices and quantities change if the quality of (some or 
all) prodcuts change. The new quality levels can be given by the {opt xb0()} 
option. (The option can also be combined with the {opt ksi()} option, which 
gives the unobserved component of the mean utility, for example, from a 
previous estimation. If {opt ksi()} is not specified, the unobserved component 
is calculated as the remaining part of the mean utility after substracting xb0 
and the price utility component.

{phang} {opt ksi:(varname)} user specified unobserved part of mean utility; not 
required to specify for simulation without estimation.

{phang} {opt aelast:(numlist)} user specified value of aggregate elasticity. If 
specified the market size is adjusted so that the implied aggregate elasticity 
to be equal to the number given. The specified value can be positive or 
negative; the negative of its absolute value will be used. The implied market 
size is saved into the variable __msize.


{marker s_remarks}{title:Remarks}

{p} The Mata functions of {cmd:rcl} are compiled into the Mata library lrcl.mlib 
(downloaded automatically during installation into the ado/plus/l folder; for 
the location of the ado folders type {stata "sysdir"}). The source code of the 
functions can be found in the ancillary rcl_*.do do files. The the 
rcl_mlib_data_generation.do file reproduces the lrcl.mlib library from these do 
files. These files are downloaded into the current directory if {cmd:rcl} is 
installed by specifying the {opt all} option: "ssc install rcl, all replace". 
(The current directory's name is in c(pwd). Alternatively, the files can be 
directly downloaded from the IDEAS website.) The rcl_mlib_generation.do file 
compiles the lrcl library using the other do files. Note that the addresses 
might have to be changed depending on the files' location.

{p} The rcl_and_test_data_generation.do file reproduces the rcl_test_data.dta 
test dataset used in the examples below (and saves it into the 
ado/plus/r folder). Also, note that if {cmd:rcl} is installed from SSC ("ssc 
install rcl, all replace") the test dataset is downloaded from the website and 
saved into the current directory.

{p}{cmd:rcl} uses the {help ivreg2} command of 
{help rcl##BSS2007:Baum et al 2007} and {help rcl##BSS2010:2010} for the 
estimation of the linear nested and simple logit models. In addition, various 
auxiliary functions from {cmd:ivreg2} and {help ranktest} (of Kleibergen and 
Schaffer) are used separately for some calculations. All of these cases are 
indicated in the ado and do files. Also, {cmd:rcl} uses the {cmd:nwspgr} 
command of {help rcl##HW2007:Heiss and Winschel (2007)} for the sparse grid 
integration. The authors of these commands and functions are acknowledged and, 
of course, are not responsible for any mistake in or error of the {cmd:rcl} 
command.


{marker s_examples}{title:Examples}

{pstd}Setup: load test dataset into memory{p_end}
{phang2}{stata "use http://fmwww.bc.edu/repec/bocode/r/rcl_test_data.dta, clear"}{p_end}

{pstd}Estimation and simulation of a simple logit model{p_end}
{phang2}{stata "rcl share x1 (price = w* x1_* cc ccg), market(market) robust elasticities(firm) msimulation(firm firm_post)"}{p_end}

{pstd}Estimation and simulation of a one-level nested logit model 
(nest variable: g){p_end}
{phang2}{stata "rcl share x1 (price = w* x1_* cc ccg), market(market) nests(g) robust elasticities(firm) msimulation(firm firm_post)"}{p_end}

{pstd}Estimation and simulation of a BLP model (random coefficients on 
characteristic x1){p_end}
{phang2}{stata "rcl share x1 (price = w* x1_* cc ccg), market(market) rc(x1) robust elasticities(firm) msimulation(firm firm_post)"}{p_end}

{pstd}Merger simulation of a two-level nested logit model with pre-determined 
model coefficients (nest and subnest variables: g and h){p_end}
{phang2}{stata "rcl share price, market(market) nests(g h) noestimation alpha(-0.5) sigmas(0.5 0.7) msimulation(firm firm_post)"}{p_end}

{pstd}Simulation of equilibrium prices and shares from a three-level nested 
logit model with pre-determined model coefficients, marginal costs and 
"observed" non-price mean utility component (the equilibrium prices and shares 
are saved into the variables __p_post and __s_post){p_end}
{phang2}{stata "rcl share price, market(market) nests(g h k) noestimation alpha(-0.5) sigmas(0.5 0.7 0.9) elasticities(constant) msimulation(firm) mc(mc) xb(xb0)"}{p_end}

{marker s_stored}{title:Stored results}

{p}{cmd:rcl} stores the following results in {cmd:e()}:

Scalars
{col 4}{cmd:e(N)}{col 18}Number of observations
{col 4}{cmd:e(r2)}{col 18}R-squared (fit of mean utility)
{col 4}{cmd:e(r2_a)}{col 18}Adjusted R-squared
{col 4}{cmd:e(r2_d)}{col 18}R-squared of demand equation (fit of mean utility)
{col 4}{cmd:e(r2_p)}{col 18}R-squared of pricing equation
{col 4}{cmd:e(r2_a_d)}{col 18}Adjusted R-squared of demand equation (fit of mean utility)
{col 4}{cmd:e(r2_a_p)}{col 18}Adjusted R-squared of pricing equation
{col 4}{cmd:e(F)}{col 18}F statistic
{col 4}{cmd:e(N_clust)}{col 18}Number of clusters
{col 4}{cmd:e(j)}{col 18}Hansen J statistic
{col 4}{cmd:e(jp)}{col 18}p-value of Hansen J statistic
{col 4}{cmd:e(jdf)}{col 18}dof of Hansen J statistic = degree of overidentification = L-K
{col 4}{cmd:e(idstat)}{col 18}LM test statistic for underidentification (Anderson or Kleibergen-Paap)
{col 4}{cmd:e(idp)}{col 18}p-value of underidentification LM statistic
{col 4}{cmd:e(iddf)}{col 18}dof of underidentification LM statistic
{col 4}{cmd:e(widstat)}{col 18}F statistic for weak identification (Cragg-Donald or Kleibergen-Paap)

Macros
{col 4}{cmd:e(dmodel)}{col 18}Demand model (blp, logit, nlogit, nlogit2 or nlogit3)
{col 4}{cmd:e(title)}{col 18}Title
{col 4}{cmd:e(estimator name)}{col 18}Estimator name
{col 4}{cmd:e(vce)}{col 18}Type of variance-covariance estimator
{col 4}{cmd:e(share)}{col 18}Share variable
{col 4}{cmd:e(market)}{col 18}Market variable
{col 4}{cmd:e(exexog)}{col 18}List of excluded exogenous variables
{col 4}{cmd:e(iexog)}{col 18}List of included exogenous variables
{col 4}{cmd:e(endog)}{col 18}List of endogenous (right hand side) variables
{col 4}{cmd:e(dups)}{col 18}List of duplicate variables
{col 4}{cmd:e(collin)}{col 18}List of collinear variables

Matrices
{col 4}{cmd:e(b)}{col 18}Coefficient vector
{col 4}{cmd:e(V)}{col 18}Variance-covariance matrix of the estimators
{col 4}{cmd:e(el)}{col 18}Elasticity matrix
{col 4}{cmd:e(dr)}{col 18}Diversion ratio matrix
{col 4}{cmd:e(ssnip)}{col 18}Matrix with SSNIP-test results

Functions
{col 4}{cmd:e(sample)}{col 18}Marks estimation sample

Variables
{col 4}(Note that if the command needs any of these variables it will be generated or overwritten.)
{col 4}{cmd:__shat}{col 18}Implied pre-merger market shares (same as {it:sharevar})
{col 4}{cmd:__s_post}{col 18}Post-merger equilibrium market shares
{col 4}{cmd:__p_post}{col 18}Post-merger equilibrium prices
{col 4}{cmd:__foc_post}{col 18}Post-merger first order conditions of equilibrium
{col 4}{cmd:__delta}{col 18}Mean utilities
{col 4}{cmd:__xb0}{col 18}Non-price component of observed part of mean utility
{col 4}{cmd:__ksi}{col 18}Unobserved component of mean utility
{col 4}{cmd:__mc}{col 18}Implied marginal costs
{col 4}{cmd:__mrkp}{col 18}Implied markups
{col 4}{cmd:__mce}{col 18}Implied "efficient" marginal costs (if the {opt cmce} option is specified)
{col 4}{cmd:__msize}{col 18}Implied market size (if {opt the aelast()} option is specified)


{marker s_refs}{title:References}

{marker BSS2007}{...}
{phang} Baum, C. F., Schaffer, M.E., and Stillman, S., (2007): 
"Enhanced routines for instrumental variables/GMM estimation and testing," 
{it:The Stata Journal}, Vol. 7, No. 4, pp. 465-506.
{browse "http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html":http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html}.
Working paper version: Boston College Department of Economics Working Paper No. 667. 
{browse "http://ideas.repec.org/p/boc/bocoec/667.html":http://ideas.repec.org/p/boc/bocoec/667.html}.{p_end}

{marker BSS2010}{...}
{phang} Baum, C.F., Schaffer, M.E., Stillman, S., (2010): 
"ivreg2: Stata module for extended instrumental variables/2SLS, GMM and AC/HAC, LIML and k-class regression," 
{browse "http://ideas.repec.org/c/boc/bocode/s425401.html":http://ideas.repec.org/c/boc/bocode/s425401.html}{p_end}

{marker B1994}{...}
{phang} Berry, S. T., (1994): 
"Estimating Discrete-Choice Models of Product Differentiation," 
{it:Rand Journal of Economics}, 25(2), pp. 242-262.{p_end}

{marker BLP1995}{...}
{phang} Berry, S. T., J. Levinsohn, and A. Pakes, (1995): 
"Automobile Prices in Equilibrium," 
{it:Econometrica}, 63(4), pp. 841-890.{p_end}

{marker CH1987}{...}
{phang} Chamberlain, G., (1987): 
"Asymptotic efficiency in estimation with conditional moment restrictions," 
{it:Journal of Econometrics}, 34(3), pp. 305-334.{p_end}

{marker HW2007}{...}
{phang} Heiss, F., and Winschel, W., (2007): 
"Quadrature on sparse grids: Code to generate and readily evaluated nodes and weights," 
{browse "http://www.sparse-grids.de/":http://www.sparse-grids.de/}{p_end}

{marker IL2011}{...}
{phang} Ivaldi, M. and S. Lorincz, (2011): 
"Implementing Relevant Market Tests in Antitrust Policy: Application to Computer Servers," 
{it:Review of Law & Economics}, 7(1), pp. 29-71.{p_end}

{marker JS2011}{...}
{phang} Judd, K. L., and B. Skrainka, (2011): 
"High Performance Quadrature Rules: How Numerical Integration Affects a Popular Model of Product Differentiation," 
{it:CeMMAP working papers}, CWP03/11, Centre for Microdata Methods and Practice, Institute for Fiscal Studies.
{browse "http://www.cemmap.ac.uk/wps/cwp0311.pdf":http://www.cemmap.ac.uk/wps/cwp0311.pdf}{p_end}

{marker MF1981}{...}
{phang} McFadden, D., (1981): 
"Econometric Models of Probabilistic Choice," 
in C.F. Manski, D. McFadden (eds), {it:Structural Analysis of Discrete Data with Econometric Applications}, 
MIT Press, Cambridge, Massachusetts, pp. 198-272.{p_end}

{marker N2000}{...}
{phang} Nevo, A., (2000): 
"A Practitioner’s Guide to Estimation of Random-Coefficients Logit Models of Demand," 
{it:Journal of Economics & Management Strategy}, 9(4), pp. 513–548.{p_end}

{marker N2001}{...}
{phang} Nevo, A., (2001): 
"Measuring Market Power in the Ready-to-Eat Cereal Industry," 
{it:Econometrica}, 69(2), pp. 307-342.{p_end}

{marker RV2014}{...}
{phang} Reynaert, M. and F. Verboven, (2012): 
"Improving the Performance of Random Coefficients Demand Models: the Role of Optimal Instruments," 
{it:Journal of Econometrics}, 179(1), pp. 83-98.{p_end}

{marker W1996}{...}
{phang} Werden, G. J., (1996): 
"A Robust Test for Consumer Welfare Enhancing Mergers Among Sellers of Differentiated Products," 
{it:Journal of Industrial Economics}, 44, pp. 409-413.{p_end}

{marker s_author}{title:Author}
{txt}
{pstd}Szabolcs Lorincz{p_end}
{pstd}European Commission{p_end}
{pstd}szabolcs@gmail.com{p_end}
{pstd}Disclaimer: The views expressed are those of the author and cannot be 
regarded as stating an official position of the European Commission, or as an 
indication on what methodologies the European Commission would use or how it 
would assess them in any of its proceedings.{p_end}

