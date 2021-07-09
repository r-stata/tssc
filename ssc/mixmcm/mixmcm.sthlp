{smcl}
{* *! version 1.0.0 31.01.2018}{...}

{cmd:help mixmcm} {right:also see: {help mlogit}, {help fmlogit}}
{hline}

{title:Title}

{phang}
{bf:mixmcm} {hline 2} Estimation of finite mixture of Markov chain models by maximum likelihood (ML) and the Expectation-Maximization (EM) algorithm.


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:mixmcm}
{depvar}
[{indepvars}] {ifin} {weight}{cmd:,}
{cmdab:id(}{varname}{cmd:)}
{cmdab:time:var(}{varname}{cmd:)}
[{cmdab:nocons:tant}
{cmdab:entry(}{varlist}{cmd:)}
{cmdab:exit:code(}name{cmd:)}
{cmdab:nc:omponents(}{help mixmcm##nc.suboptions:{it:suboptions}}{cmd:)}
{cmdab:members:hip(}{varlist}{cmd:)}
{cmdab:emiter:ate(}{help mixmcm##em.suboptions:{it:suboptions}}{cmd:)}
{cmdab:const:raints(}{help mixmcm##const.list:{it:clist}}{cmd:)}]


{synoptset 40 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent :* {opth id(varname)}}numeric variable identifying agents{p_end}
{p2coldent :* {opth time:var(varname)}}numeric variable identifying time{p_end}
{synopt :{opt nocons:tant}}suppress constant term in the specification of transition probabilities {p_end}
{synopt :{opt entry}{cmd:(}{varlist}{cmd:)}}specify dependent and explanatory variables for entry probabilities{p_end}
{synopt :{opth exit:code(name)}}state indicating exits{p_end}
{synopt :{opt nc:omponents}{cmd:(}{help mixmcm##nc.suboptions:{it:ncomponents_suboptions}}{cmd:)}}specify options for the number of components{p_end}
{synopt :{opt members:hip}{cmd:(}{varlist}{cmd:)}}specify explanatory variables for component membership probabilities{p_end}
{synopt :{opt emiter:ate}{cmd:(}{help mixmcm##em.suboptions:{it:emiterate_suboptions}}{cmd:)}}specifiy options for EM algorithm iterations{p_end}
{synopt :{opt const:raints}{cmd:(}{help mixmcm##const.list:{it:clist}}{cmd:)}}specify constraints on transition probabilities{p_end}
{synoptline}
{p 4 6 2}
* Required options{p_end}
{p2coldent : {cmd:fweights} and {cmd:pweights} are allowed; see {help weight}. }
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:mixmcm} fits finite mixture of Markov chain models (MMCM) using conditional {help mlogit} via the EM algorithm. 
The command estimates the parameters of the transition probabilities of agents under the assumption of a finite mixture of homogeneous types in the population,  with 
each type following its own first-order Markovian process. That is, typically, agents are observed at several dates (or time periods) {it:t}={1...{it:T}} as located into a finite number of states (the modalities of {depvar}) 
{it:j}={0...{it:K}} (with {it:K}>=2). State {it:j=0} is arbitrarily chosen to indicate entry into or exit from the population. Each agent belongs to a specific homogeneous type {it:g}={1...{it:G}} (with {it:G}>=1). Agents' transitions from state 
{it:j}={0...{it:K}} to state {it:k}={0...{it:K}} are thus observed but the type that agents belong to are not. {cmd:mixmcm} estimates the parameters specific to each homogeneous type  
via the EM algorithm, treating the unobserved types of agents as missing information (see {help mixmcm##mcp.2004:Mclachlan and Peel, 2004}; {help mixmcm##mck.2007:Mclachlan and Krishman, 2007}). 
Transition probabilities may be specified as a function of explanatory variables ({it:indepvars}) through a multinomial logit specification. Type membership probabilities 
may also be expressed as a function of explanatory variables using the fractional multinomial logit specification. Otherwise, type membership probabilities are estimated non-parametrically (see {help mixmcm##scl.2017:Saint-Cyr, 2017}). 


{title:Options}

{phang}
{opth id(varname)} specifies the variable that identifies agents. {cmd:mixmcm} computes the probability of belonging to each specific homogeneous type for each id. {cmd:id()} is required.

{phang}
{opth timevar(varname)} specifies the numeric variable that identifies dates on (or time periods during) which transitions occur. {cmd: timevar()} is required.

{phang}
{opt noconstant} suppresses the constant term (or intercept) in the specification of transition probabilities. Specifying the {cmd:noconstant} option requires that at least one {it:indepvar} be specified. 

{phang}
{marker entry.suboptions}
{opt entry(varlist)} specifies the dependent and independent variables to enter the specification of entry probabilities. Specifying {cmd:entry()} requires that at least the dependent variable indicating the entry state be specified. 

{phang}
{opt exitcode(name)} indicates the modality of {it:depvar} which identifies the exit state. 

{phang}
{marker nc.suboptions}
{opt ncomponents([#1 #2, selcrit(name) graph(namelist, twoway_options) save(filename, replace detail) force])} specifies options for the number of (unobserved) homogeneous types. 

{pmore}
- {it:#1} and {it:#2} indicate the range for the number of components. If both {it:#1} and {it:#2} are specified, {cmd:mixmcm} will estimate {it:#1} -- {it:#2} MMCMs, starting from the model with {it:#1} component(s) to the model with {it:#2} components,
trying to identify the optimal number of components within this range based on the selection criterion specified in the sub-option {it:selcrit}(see below). Unless sub-option {it:force} is specified (see below), the estimation will stop automatically when the 
optimal number of components is found, and the results will solely be displayed for this optimal number of components. If only {it:#1} is specified, {cmd:mixmcm} will only estimate the parameters for this number of component(s), and the corresponding 
results will be displayed. A standard (homogeneous) Markov chain model will be estimated if the specified number of components is {it:#1}=1. If {cmd:ncomponents}  is not specified, a 2-component MMCM is estimated by default.

{pmore}
- {it:selcrit(name)} specifies the information criterion to be used to select the optimal number of components within the {it:#1} to {it:#2} range. The available information criteria are AIC, BIC, AIC3 or CAIC (the default). 
See {help mixmcm##ac.2003:Andrews and Currim, 2003} for a discussion on using information criteria to select the optimal number of components.

{pmore}
- {it:graph(namelist, twoway_options)} specifies that a graph for the information criteria in {it:namelist} be drawn for the number of components in the {it:#1} to {it:#2} range. The
{it:graph} option thus requires that at least one information criterion among AIC, BIC, CAIC, AIC3 be specified in {it:namelist}. Users can manage the graph using standard {help twoway_options} options.

{pmore}
- {it:save(filename, replace detail)} saves the information criteria for the numbers of components estimated within the {it:#1} to {it:#2} range in {it:filemane}. Specifying {it:replace} as a sub-option will overwrite an existing {it:filename}. 
If {it:detail} is specified, as a {it:save} sub-option, the resulting parameters for all the estimated numbers of components will also be jointly saved.

{pmore}
- {it:force} indicates that the models should be estimated for every number of components within the {it:#1} to {it:#2} range, even though the optimal number of components is found to be smaller than {it:#2} based on {it:selcrit}. 
Therefore, estimations will contnue until {it:#2} either way. 

{phang}
{marker members.suboptions}
{opt membership(varlist)} specifies independent variables to enter the specification of component-membership probabilities. These variables must be constant over time for each agent.
The parametric form for the mixing distribution is the {help fmlogit} which allows the dependent variable to lie between 0 and 1. Specifiying {cmd:membership()} requires that at least one explanatory variable be specified.
If {it:membership()} is not specified, component-membership probabilities will be estimated non-parametrically (see {help mixmcm##train.2008:Train, 2008)}.

{phang}
{marker em.suboptions}
{opt emiterate([lr(#1 #2, eps) sr(#1 #2) seed(numlist) emlog)])} specifies sub-options for the EM algorithm.  

{pmore}
- {it:lr(#1 #2, eps)} specifies the number of long-run EMs ({it:#1}) to be performed, the maximum number of iterations ({it:#2}) to be used for each long-run EM, and the convergence criterion ({it:eps}) to stop iterations, respectively.
 Defaults are 5 for {it:#1}, 100 for {it:#2} and 0.0000001 for {it:eps}. {it:eps} is the tolerance used in the log-likelihood maximization: {cmd:mixmcm} declares convergence when the proportional increase in the log-likelihood over two consecutive
 iterations is less than the specified {it:eps}. 

{pmore}
- {it:sr(#1 #2)} specifies the number of short-run EMs ({it:#1}) and the maximum number of iterations for each short-run EM. Defaults are 5 for {it:#1} and 5 for {it:#2}. 

{pmore}
- {it:seed(#)} sets the pseudo-uniform random number seed. Initial parameters for the EM estimation are randomly chosen using the same seed. The default is 123456. 
The seed is a local macro that does replace seeds that have been chosen by users out of the command.

{pmore}
- {it:emlog} displays the logs for the long-run EMs' iterations.

{phang}
{marker const.list}
{cmdab:constraints(}{it:clist}{cmd:)} lists the constraints that should be imposed on transition probabilities. 
Each constraint listed in {it:clist} must be specified as: {it:constraint} {it:# p_initialstate_finalstate = 0}, where # is the number that identifies the constraint.
For now, transition probabilities can only be constrained to 0, and this constraint applies across all components.

{title:Examples}

{pstd}
The following examples use the {bf:mixmcmdata.dta} database on French farms. The data are freely available online at {browse "http://agreste.agriculture.gouv.fr/_rica-france-microdonnees/article/rica-france-microdonnees":{it:RICA France micro-data}}. 
We restricted the sample to farms which were present in the database for at least two consecutive years. We also kept only a few variables and renamed them to use in our examples. The 10 first lines of the mixmcm.dta database are:

{cmd:	idnum	year	surplus	istock	  icap	  debtr	  crop	 corp	educ	young	category}
	 963    2000	36804    22896    76332    7.00      0      0      1       0     medium  
	 963    2001    28861    17895    76331    6.40      0      0      1       0     medium  
	 963    2002    30000    30194    76331    3.90      0      0      1       0     medium  
	 963    2003     5159        0    76331    4.10      0      0      1       0     medium  
	1525    2006    58895   202919   283939   14.60      1      1      1       0      large  
	1525    2007    51726   101807   283939   22.10      1      1      1       0     vlarge  
	1525    2008    54940   176367   283939   27.20      1      1      1       1     vlarge  
	1525    2009    51883   198033   283939   20.00      1      1      1       1     vlarge  
	1525    2010    88685   183816   283939   18.10      1      1      1       1     vlarge  
	1534    2006    90051   124877   110557   51.10      1      1      1       0     vlarge  

{pstd}
In the database, {cmd:idnum} and {cmd:year} are the farm identifier and the time variable, respectively. Variables {cmd:surplus}, {cmd:istock}, {cmd:icap} and {cmd:debtr} respectively are the Gross Operating
Surplus, initial stock and initial capital in Euros, and the debt ratio of the farm in percentage. The other (indicator) variables ({cmd:crop} = 1 if specialized in field crop production,
{cmd:corp} = 1 if corporate legal status, {cmd:educ} = 1 if farmer has higher education and {cmd:young} = 1 if farmer is under 41) were derived from original variables for our specific
examples. {cmd:category}, which will be used as {it:depvar} in {cmd:mixmcm}, was defined according to the original economic production potential {it:pbuce} variable and consists of three modalities,
namely {it:medium} ({it:pbuce} < 100000), {it:large} (with 100000 >= {it:pbuce} < 250000) and {it:vlarge} (with {it:pbuce} >= 250000).  

{phang}
1.  First, we fit a two-component model with explanatory variables for transition probabilities:

{pmore2}
{cmd:. use mixmcm.dta, clear}{p_end}
{pmore2}
{cmd:. mixmcm category surplus istock crop corp, id(idnum) time(year)}{p_end}

{phang}
2.  Second, we again fit a two-component model but also account for entry and exit and include explanatory variables for entry and type-membership probabilities, and add constraints on some transition probabilities.

{pmore2}
Identifying exits:{p_end} 
{pmore2}
We consider farms that leave the sample before the last year of the panel (2010) as exits. A new modality named `exit' is thus added to the {it:category} variable.

{pmore2}
{cmd:. by idnum: generate _last = _n == _N}{p_end}
{pmore2}
{cmd:. drop if _last != 1}{p_end}
{pmore2}
{cmd:. keep idnum year}{p_end}
{pmore2}
{cmd:. by idnum: replace year=year+1 if _n == _N}{p_end}
{pmore2}
{cmd:. append using "mixmcm.dta"}{p_end}
{pmore2}
{cmd:. sort idnum year}{p_end}
{pmore2}
{cmd:. replace category = "exit" if category == "" {p_end}

{pmore2}
Identifying entries:{p_end} 
{pmore2}
We now consider farms that enter the sample after the first year of the panel (2000) as entries. We thus generate a new variable named {it:entry_class} that 
collects the category in which farms are observed for the first time in the sample.

{pmore2}
{cmd:. by idnum: generate _first = _n == 1}{p_end}
{pmore2}
{cmd:. by idnum: generate str entry_class = "1" if _first == 1 & year != 2000}{p_end}
{pmore2}
{cmd:. levelsof category, local(catlevels)}{p_end}
{pmore2}
{cmd:. foreach cat of local catlevels {c -(}}{p_end}
{pmore2}
{cmd:2.   replace entry_class = "`cat'" if category == "`cat'" & entry_class == "1"}{p_end}
{pmore2}
{cmd:3.{c )-}}{p_end}
{pmore2}
{cmd:. replace entry_class= "." if entry_class == ""}{p_end}
{pmore2}
{cmd:. drop _first}{p_end}

{pmore2}
Computing the mean and mode of variables to enter the specification of type membership probabilities:{p_end}
{pmore2}
{cmd:. by idnum: egen double meandebtr = mean(debtr)}{p_end}
{pmore2}
{cmd:. foreach v in educ young {c -(}} {p_end}
{pmore2}
{cmd:2.   by idnum: egen double mode`v' = mode(`v')}{p_end}
{pmore2}
{cmd:3.   by idnum: replace mode`v' = `v'[_N] if mode`v' == .}{p_end}
{pmore2}
{cmd:4.{c )-}}{p_end}

{pmore2}
Specifying constraints on transition probabilities:{p_end}
{pmore2}
{cmd:. constraint 1 p_medium_vlarge = 0}{p_end}
{pmore2}
{cmd:. constraint 2 p_vlarge_medium = 0}{p_end}

{pmore2}
Model estimation:{p_end}
{pmore2}
{cmd:. mixmcm category surplus istock crop corp, id(idnum) time(year) exit(exit) entry(entry_class icap corp) members(meandebt modeeduc modeyoung) const(1 2)}


{phang}
3. Finally, we search for the optimal number of components between 1 and 5 based on the CAIC information criterion, produce a graph and save the results for every tested component number.

{pmore2}
{cmd:. mixmcm category surplus istock crop corp, id(idnum) time(year) nc(1 5, graph(aic bic caic aic3, title("Fig. 1") ytitle("Information criteria") xtitle("Number of components") xlabel(1(1)5) scheme(sj) saving(figure.eps, replace)) save(icbtable, replace detail) force) emiter(lr(3 200, 0.000001) sr(3 5)) exit(exit) entry(entry_class icap corp) members(meandebtr modeeduc modeyoung) const(1 2)}

{title:Stored results}

{pstd}{cmd:mixmcm} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_components)}} optimal number of homogeneous types{p_end}
{synopt:{cmd:e(min_components)}}minimum number of homogeneous types estimate{p_end}
{synopt:{cmd:e(max_components)}}maximum number of homogeneous types estimate{p_end}
{synopt:{cmd:e(ll)}}log-likelihood{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_id)}}number of agents identified by {cmd:id()}{p_end}
{synopt:{cmd:e(k)}}number of free parameters estimated{p_end}
{synopt:{cmd:e(aic)}}Akaike information criterion{p_end}
{synopt:{cmd:e(aic3)}}restricted Akaike information criterion{p_end}
{synopt:{cmd:e(bic)}}Bayesian information criterion{p_end}
{synopt:{cmd:e(caic)}}consistent Akaike information criterion{p_end}
{synopt:{cmd:e(converged)}}1 if the EM algorithm converged, 0 otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mixmcm} command name{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(cmdline)}}command line as it was written{p_end}
{synopt:{cmd:e(id)}}name of the {cmd:id()} variable{p_end}
{synopt:{cmd:e(depvar)}}name of the dependent variable{p_end}
{synopt:{cmd:e(states)}}modalities of the dependent variable{p_end}
{synopt:{cmd:e(exitcode)}}name of the exit state{p_end}
{synopt:{cmd:e(indepvars)}}independent variables for transition probabilities{p_end}
{synopt:{cmd:e(entry_var)}}name of the {cmd:entry()} variable{p_end}
{synopt:{cmd:e(entry_indepvars)}}independent variables for entry probabilities{p_end}
{synopt:{cmd:e(compvars)}}independent variables for component membership probabilities{p_end}
{synopt:{cmd:e(mpf)}}functional form of the mixing distribution{p_end}
{synopt:{cmd:e(selcrit)}}information criterion for the selection of the optimal number of components{p_end}
{synopt:{cmd:e(seed)}}pseudo-uniform randomnumber seed{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b_tpm)}}vector of coefficients for entry and transition probabilities {p_end}
{synopt:{cmd:e(V_tpm)}}covariance matrix of the coefficients for entry and transition probabilities{p_end}
{synopt:{cmd:e(b_proba)}}vector of coefficients for component membership probabilities{p_end}
{synopt:{cmd:e(V_tpm)}}covariance matrix of the coefficients for component membership coefficients{p_end}
{synopt:{cmd:e(pi)}}vector of component shares{p_end}
{synopt:{cmd:e(Cns_tpm)}}matrix of constraints{p_end}


{title:References}
{marker ac.2003}
{pstd}
Andrews, R. L., & Currim, I. S. (2003). A comparison of segment retention criteria for finite mixture logit models. {browse "http://www.jstor.org/stable/30038851":{it:Journal of Marketing Research}, 40(2), 235-243.}

{pstd}
{marker mck.2007}
McLachlan, G., & Krishnan, T. (2007). The EM algorithm and extensions (Vol. 382). John Wiley & Sons.

{pstd}
{marker mcp.2004}
McLachlan, G., & Peel, D. (2004). Finite mixture models. John Wiley & Sons.

{pstd}
{marker scl.2017}
Saint-Cyr, L. D. F. (2017). Accounting for unobserved farm heterogeneity in modelling structural change: evidence from France. UMR SMART-LERECO, AGROCAMPUS OUEST, INRA. PhD Disertation, 165 pages.

{pstd}
{marker train.2008}
Train, K. E. (2008). EM algorithms for nonparametric estimation of mixing distributions. {browse "http://www.sciencedirect.com/science/article/pii/S1755534513700228":{it:Journal of Choice Modelling}, 1(1), 40-69.}


{title:Authors}

{pstd}Legrand D.F. SAINT-CYR and Laurent PIET{p_end}
{pstd}{browse "https://www.rennes.inra.fr/smart_eng/":UMR SMART-LERECO -- AGROCAMPUS OUEST/INRA}{p_end}
{pstd}Rennes, France{p_end}
{pstd}legrand.saint-cyr@inra.fr{p_end}


