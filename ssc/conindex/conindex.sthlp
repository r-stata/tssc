{smcl}
{hline}
help for {cmd:conindex} {right: Erasmus University Rotterdam & NUI Galway}
{hline}

{title:Calculation of rank-dependent inequality indices (Concentration Indices) for bounded and unbounded variables.}

{p 5 5 2}{cmd:conindex} [{it:varlist}] [{it:if}] [{it:in}]  [{cmd:fweight aweight pweight}] {cmd:,}
 {cmdab:RANKvar}{cmd:(}{it:varname}{cmd:)}
 [{cmdab:CLUSter}{cmd:(}{it:varname}{cmd:)}]
 [{cmdab:robust}]
 [{cmdab:truezero}] 
 [{cmdab:generalized}] 
 [{cmdab:v}{cmd:(}{it:#1}{cmd:)}]
 [{cmdab:beta}{cmd:(}{it:#1}{cmd:)}]
 [{cmdab:bounded}]
 [{cmdab:LIMits}{cmd:(}{it:#1 #2}{cmd:)}]
 [{cmdab:WAGstaff}]
 [{cmdab:ERReygers}]
 [{cmdab:graph}]
 [{cmdab:loud}] 
 [{cmdab:COMPare}{cmd:(}{it:varname}{cmd:)}]
 [{cmdab:KEEPrank}{cmd:(}{it:string}{cmd:)}]
 [{cmdab:svy}]
 
{title:Description}

{p 5 5 2}{it:conindex} computes a range of rank-dependent inequality indices, including the Gini coefficient, the concentration index, the generalized (Gini) concentration index, the modified concentration index, the Wagstaff and Erreygers normalised concentration indices for bounded variables, and the distributionally sensitive extended and symmetric concentration indices (and their generalized versions). O'Donnell et al. (2016) offer an accessible introduction to the various concentration indices that have been proposed to suit different measurement scales and normative positions. {it:conindex} is not an official Stata command. It is a free contribution to the research community. Please include a citation to O'Donnell et al. (2016) in your work.

{p 5 5 2} There is no default index. Options define the index to be computed. (Generalized) Lorenz and (generalized) concentration curves can be obtained using the graph option. The default axis labels can be replaced by using the xtitle({it:string}) and ytitle({it:string}) options. 

{p 5 5 2} For {ul on}{bf:unbounded} {ul off} variables (i.e. those with at least one infinite bound),the option {it:truezero} should be specified if the variable of interest is ratio-scale (or fixed) and has a zero lower limit, in which case the standard concentration index is calculated. If instead the variable of interest is cardinal (with the zero point fixed arbitrarily), then the theoretical lower limit must be specified using the {it:limits(#)} option where # is the minimum value. Note that one should not use the lowest value observed in the sample if this does not correspond to the theoretical lower bound. Specification of this option results in calculation of the modified concentration index.

{p 5 5 2} The generalized concentration index derives from specifying the option {it: generalized} in conjunction with the option {it: truezero}.
 
{p 5 5 2} For {ul on}{bf:bounded} {ul off} variables (i.e. those with both a finite lower and upper bound) the option {it:bounded} can be specified in conjunction with {it:limits(#1 #2)} where {it:#1} and {it:#2} denote theoretical minimum and maximum values of the variable of interest. The inequality indices are then calculated based on the standardised version of the variable of interest, {it:h*} ({it:h*=(h-#1)/(#2-#1)}, and hence will be scale invariant. 

{p 5 5 2} The normalised concentration indices proposed by Wagstaff (2005) and Erreygers (2009a) may be obtained by specifying the {it:wagstaff} and {it:erreygers} option respectively in conjunction with the {it:bounded} and {it:limits(#1 #2)} options.

{p 5 5 2} When a ranking variable is not provided using the {it:rankvar} option, {it:conindex} defaults to use {it:varname} to rank observations, leading to the calculation of uni-dimensional inequality indices (e.g. the Gini coefficient).

{p 5 5 2} The extended concentration index, which allows for alternative attitudes to inequality (Periera, 1998; Wagstaff, 2002), is computed with the addition of the options {it:truezero} and v{it:(#)}, where # is the distributional sensitivity parameter. With v{it:(2)} the extended concentration index is equivalent to the standard concentration index. 

{p 5 5 2} The symmetric concentration index, an alternative distributionally sensitive concentration index proposed by Erreygers et al. (2012), is obtained with the options {it:truezero} and {it:beta(#)}. With {it:beta(2)}, the symmetric concentration index is equivalent to the standard concentration index.

{p 5 5 2} The generalized version of the extended and symmetric concentration indices are obtained by combining the options v{it:(#)} and {it:beta(#)} with the options {it:truezero} and {it:generalized}.

{p 5 5 2} All indices are calculated using the so-called 'convenient covariance' approach (Kakwani, 1980; Jenkins, 1988; Kakwani et al, 1997). Robust and clustered corrected standard errors can be obtained with the usual options. Standard errors for the extended and symmetric indices are not calculated by the current version of {cmd:conindex}.

{p 5 5 2} The value of an index can be compared across groups, and the null of homogeneity tested, using the {it:compare} option. This option cannot be combined with the prefix {it:by varlist:}.

{p 5 5 2} The fractional rank may be preserved using the option {it:keeprank(string)} where {it: string} is the name given to the rank variable created.

{p 5 5 2} {it:conindex} can be used on data from complex survey designs by including the option {it:svy} if {it:svyset} has been used to identify the survey design characteristics prior to running {it:conindex}.


{title:Options}

{col 5} {it:rankvar}  {col 25} variable by which individuals are ranked. Must be at least an ordinal variable.

{col 5} {it:cluster(varname)} {col 25} requests clustered standard errors that allow for intragroup correlation.

{col 5} {it:robust} {col 25} requests Huber/White/sandwich standard errors.

{col 5} {it:truezero} {col 25} declares that the variable of interest is ratio scaled (or fixed), leading to computation of the standard concentration index.

{col 5} {it:generalized} {col 25} requests the generalized concentration (Gini) index measuring absolute inequality. This option can only be used in 
{col 25} conjunction with {it:truezero}.

{col 5} {it:v(#)} {col 25} requests the extended concentration index be computed. This option can only be used in conjunction with {it:truezero}. When {it:v(2)} 
{col 25} the standard concentration index is computed. If the options {it:v(#)}, {it:truezero} and {it:generalized} are specified, one obtains the  
{col 25} generalized extended concentration index. In the later case, {it:v(2)} leads to the Erreygers index.

{col 5} {it:beta(#)} {col 25} requests the symmetric concentration index be computed. This option can only be used in conjunction with {it:truezero}. When {it:beta(2)} 
{col 25} the standard concentration index is computed. If the options {it:beta(#)},  {it:truezero} and {it:generalized} are specified, one obtains the 
{col 25} generalized  symmetric concentration index. In the later case, {it:beta(2)} leads to the Erreygers index.

{col 5} {it:bounded} {col 25} specifies that the dependent variable is bounded. This option must be used in conjunction with the limits option.

{col 5} {it:limits(#1 #2)} {col 25} must be used to specify the theoretical minimum (#1) and maximum (#2) for bounded variables. If the options {it:bounded} and {it:truezero}
{col 25} are not specified then {it:limits(#1)} should be used to specify the minumum value to obtain the modified concentration index.

{col 5} {it:wagstaff} {col 25} in conjunction with {it:bounded} and {it:limits(#1 #2)} requests the Wagstaff Index.

{col 5} {it:erreygers} {col 25} in conjunction with {it:bounded} and {it:limits(#1 #2)} requests the Erreygers Index.

{col 5} {it:graph} {col 25} graph requests that a concentration curve be displayed. If no ranking variable is specified, a Lorenz curve is produced. In 
{col 25} conjunction with {it:generalized}, one obtains the generalized Lorenz or concentration curve. {cmd:conindex} draws the Lorenz and concentration curves 
{col 25} using the user-written {help lorenz} command by Ben Jahn. This must be installed prior to using the {it:graph} option. 

{col 5} {it:loud} {col 25} shows the output from the regression used to generate the inequality indices.

{col 5} {it:keeprank(string)} {col 25} creates a new variable which contains the fractional ranks, where {it:string} is the name of the variable to be created. When used 
{col 25} in conjunction with compare, the variable {it:string} will contain the fractional rank for the full sample and the suffix {it:k} is added to
{col 25} {it:string} to indicate the fractional rank for group {it:k}. 

{col 5} {it:compare(varname)} {col 25}computes indices specific to groups specified by varname. Two tests of the null of equality of the index values across groups are 
{col 25} produced: an F-test that is valid in small samples but requires an assumption of equal variances across groups and a z-test that  
{col 25} relaxes the assumption of equal variances but is valid only in large samples. If {it:varname} is binary, then only the F-test is given.

{col 5} {it:svy} {col 25}can be specified when using complex survey designs if {it:svyset} has been used to identify the survey design characteristics prior to running {it:conindex}.

{title:Measurement scales:}

{col 5} {it:Fixed}{col 15} requiring that the measurement scale is unique (or fixed) with the zero point corresponding to a situation of complete absence. 
{col 15} (Example: Visits to the hospital).

{col 5} {it:Ratio}{col 15} requiring that ratios between individuals have meaning with the zero point corresponding to a situation of complete absence, such that the 
{col 15} measurement scale is unique up to a proportional scaling factor. 
{col 15} (Example: Life Expectancy).

{col 5} {it:Cardinal}{col 15} requiring that differences between individuals make sense, but ratios do not, such that the zero point is fixed arbitrarily.
{col 15} (Example: Health Utility Index).

{col 5} {it:Ordinal}{col 15} requiring that it be possible to order individuals, but with the differences between individuals being meaningless. 
{col 15} (Example: Self Assessed Health).

{col 5} {it:Nominal}{col 15} implying that one can classify individuals without being able to order them. 
{col 15} (Example: Type of Illness).

{title:Saved Results}

{col 5} r(N){col 20} Number of observations
{col 5} r(Nunique){col 20} Number of unique observations for {it:rankvar}
{col 5} r(CI){col 20} Concentration index
{col 5} r(CIse){col 20} Standard error of concentration index
{col 5} r(SSE_unrestricted){col 20} Unrestricted sum of squared errors (with compare option)
{col 5} r(SSE_restricted){col 20} Restricted sum of squared errors (with compare option)
{col 5} r(F){col 20} F- statistic for joint hypothesis that concentration index is same for all groups (with compare option)
{col 5} r(CI0){col 20} Concentration index for group 0 (with compare option if only two groups)
{col 5} r(CI1){col 20} Concentration index for group 1 (with compare option if only two groups)
{col 5} r(CIse0){col 20} Standard error of concentration index for group 0 (with compare option if only two groups)
{col 5} r(CIse1){col 20} Standard error of concentration index for group 1 (with compare option if only two groups)
{col 5} r(Diff){col 20} Difference in concentration index between groups (with compare option if only two groups)
{col 5} r(Diffse){col 20} Standard error of difference in concentration index between groups (with compare option if only two groups)
{col 5} r(z){col 20} z- statistic for hypothesis that concentration index is same for both groups (with compare option if only two groups)



{title:Formulae} where N is the number of observations, Y represents income, Y_i is an individual's income, R_i is the deviation of the rank from the mean 
{col 9} (or median) rank, h_i is another variable of interest, mu_Y is the mean of Y, mu_h is the mean of h and the minimum and maximum of the variable 
{col 9} of interest are the scalars lowerlimit and upperlimit.

{col 5} {ul on}Gini Coefficient{ul off}  
{col 10}= 2/N^2*mu_Y * Sum[Y_i*R_i]
{col 10}{cmd: conindex Y , truezero}

{col 5} {ul on}Generalized Gini{ul off}  
{col 10}= 2/N^2 * Sum[Y_i*R_i]
{col 10}{cmd: conindex Y , truezero generalized}
	
{col 5} {ul on}Concentration index{ul off} 
{col 10}= 2/N^2*mu_h * Sum[h_i*R_i]
{col 10}{cmd:conindex h , rankvar(Y) truezero}
	
{col 5} {ul on}Generalized concentration index{ul off} 
{col 10}= 2/N^2 * Sum[h_i*R_i]
{col 10}{cmd:conindex h , rankvar(Y) truezero  generalized}

{col 5} {ul on}Modified concentration index{ul off} 
{col 10}= 2/(N^2(mu_h - min(h_i)) * Sum(h_i*R_i)
{col 10}{cmd:conindex h , rankvar(Y) limits(10)}

{col 5} {ul on}Extended concentration index{ul off} 
{col 10}= 1/mu_h * Sum[(1-v(1-R_i)^(v-1))/N] * h_i      v>1
{col 10}{cmd:conindex h, rankvar(Y) v(3) truezero}

{col 5} {ul on}Generalized extended concentration index{ul off} 
{col 10}= [v^(v/(v-1))]/(v-1) * Sum[(1-v(1-R_i)^(v-1))/N] * h_i      v>1
{col 10}{cmd:conindex h, rankvar(Y)  v(3) truezero generalized bounded limits(lowerlimit upperlimit)}

{col 5} {ul on}Symmetric concentration index{ul off} 
{col 10}= 1/mu_h * Sum{[beta2^(beta-2)[(R_i-1/2)^2]^((beta-2)/2) * (R_i-1/2)]/N}*h_i
{col 10}{cmd:conindex h, rankvar(Y) beta(3) truezero}

{col 5} {ul on}Generalized symmetric concentration index{ul off} 
{col 10}= 4 * Sum{[beta*2^(beta-2)[(R_i-1/2)^2]^((beta-2)/2) * (R_i-1/2)]/N}*h_i	
{col 10}{cmd:conindex h, rankvar(Y) beta(3) truezero generalized bounded limits(lowerlimit upperlimit)}

{col 5} {ul on}Wagstaff index{ul off} 
{col 10}= [2/N^2*mu_h * Sum[h_i*R_i]]/(1-mu_h)
{col 10}{cmd:conindex h , rankvar(Y) limits(lowerlimit upperlimit) bounded wagstaff}

{col 5} {ul on}Erreygers index{ul off} 
{col 10}= 4*mu_h*[2/N^2*mu_h * Sum[h_i*R_i]]
{col 10}{cmd:conindex h , rankvar(Y) limits(lowerlimit upperlimit) bounded erreygers}

{col 5} {ul on}Comparing standard concentration indices across groups{ul off} defined by the variable "group":
{col 5} Note: Other indices may be compared by specifying options as above.
{col 10}{cmd:conindex h, rankvar(Y) truezero compare(group)}

{col 5} {ul on}Concentration index for complex survey designs:{ul off} 
{col 10}{cmd:svyset [pw=weight], psu(psu_id) strata(strata_id)}
{col 10}{cmd:conindex h, rankvar(Y) truezero svy}


{title:Author}

{p 5 5 2} Owen O’Donnell, Erasmus School of Economics, Erasmus University Rotterdam, the Netherlands; Tinbergen Institute, the Netherlands; and University of Macedonia, Greece.

{p 5 5 2} Stephen O’Neill (corresponding author), Department of Health Services Research and Policy, London School of Hygiene and Tropical Medicine, UK. stephen.oneill@lshtm.ac.uk

{p 5 5 2} Tom Van Ourti, Erasmus School of Economics, Erasmus University Rotterdam, the Netherlands; Tinbergen Institute, the Netherlands.

{p 5 5 2} Brendan Walsh, HSR and Management, School of Health Sciences, and the City Health Economics Centre, City University London, UK.


{title:Also see}

{p 5 5 2} Online:   help for {help concindc}, {help glcurve}, {help concindexi}, {help concindexg}, {help ineqdeco}, {help inequal}, {help povdeco}, {help ineqerr}, {help lorenz} if installed. {p_end}

{title:References} 

{p 5 8 2} Erreygers, G., Clarke, P. & Van Ourti, T. 2012. "Mirror, mirror on the wall, who in this land is fairest of all?" Distributional sensitivity in the measurement of socioeconomic inequality in health. Journal of Health Economics 31, 257-270.

{p 5 8 2} Jenkins SP. 1988. Calculating income distribution indices from micro-data. National Tax Journal, 139-142.

{p 5 8 2} Kakwani NC. 1980. Income inequality and poverty: methods of estimation and policy applications. New York. Oxford University Press. 

{p 5 8 2} Kakwani, N., Wagstaff A., & van Doorslaer E. 1997. Socioeconomic inequalities in health: Measurement, computation, and statistical inference. Journal of Econometrics 77, 87-103.

{p 5 8 2} O'Donnell, O., O'Neill, S., Van Ourti, T. & Walsh, B. 2016. conindex: Estimation of concentration indices. The Stata Journal (Forthcoming).

{p 5 8 2} O'Donnell, O., van Doorslaer, E., Wagstaff, A. & Lindelow, M. 2008. Analyzing Health Equity Using Household Survey Data: A Guide to Techniques and Their Implementation. Washington, D.C: World Bank Institute.
