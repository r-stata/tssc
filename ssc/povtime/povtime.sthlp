{smcl}
{* July 2013}{...}
{hline}
help for {hi:povtime}{right:Carlos Gradín (July, 2013)}
{hline}

{title:Poverty measures accounting for time in a balanced panel}


{p 8 17 2} {cmd:povtime} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] , {cmdab:y}{it:(y_stub)} {cmdab:z}{it:(z_stub)} {cmdab:t}{it:(#)} [ {cmdab:g:amma}{it:(# [# ...])}
 {cmdab:b:eta}{it:(# [# ...])} {cmdab:a:lpha}{it:(# [# ...])} {cmdab:non:normalized} {cmdab:th:ao}{it:(#)} 
{cmdab:gen}{it:(newvar)} {cmdab:dec:omp} {cmdab:f:ormat}{it:(%9.#f)}  ]


{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:iweights} are allowed; see {help weights}.


{title:Description}

{p 4 4 2} 
{cmd:povtime} computes aggregate intertemporal poverty measures (poverty accounting for time) in a balanced panel of individuals (with information on per-period income or expenditure (yt) and poverty lines (zt) for N individuals during T periods).

{p 4 4 2} 
The program computes the family of FGT-type poverty measures proposed in Gradín, Del Río, and Cantó (RIW, 2012) and some descriptive statistics. 
Other measures such as Foster (2007, 2009) and Bossert, D'Ambrosio and Chakravarty (JOEI, 2012) can be interpreted as particular cases of this general family (see options).

{p 4 4 2} 
The index first computes individual poverty indicators based on per-period normalized gaps of the form (yt-zt)/zt. 
For using non-normalized gaps (yt-zt), specify the option {cmdab:non:normalized}.

{p 8 8 2} 
Individual poverty indicators can be saved as new variables using {cmdab:gen}{it:(newvar)}. 
New variables {it:(newvar_i_j)} are created with subscripts standing for the value of gamma (i) and beta (j) used.
This could be useful to further analyze their distribution drawing kernel densities (see {help akdensity} if installed) 
or computing Intertemporal TIP curves (using {help glcurve} if installed).


{p 4 4 2} 
In a second step, the program aggregates individual intertemporal poverty indicators over the entire population in order to obtain a distribution-sensitive aggregate index of intertemporal poverty.

{p 4 4 2} 
By default, an individual is considered to be intertemporally poor if yt is below zt at least one period. 
For restricting intertemporally poor to be at least a given number of periods below the poverty line, use option {cmdab:th:ao}{it:(#)}, the default is {cmdab:th:ao}{it:(1)}



{title:Data requirements}

{p 4 4 2} 
The balanced panel of N individuals (or households) observed during T periods must be in wide form (see {help reshape}).
All observations must have the same number of periods, observations with missing values will not be used in calculations.

{p 4 4 2} 
Data must contain per-period measures of wellbeing (typically income or expenditure) indicated with {it:y_stub} and poverty lines indicated with {it:z_stub}.
Income and poverty line variables must be numerated from 1 to T (i.e.  {cmdab:y}{it:(y)} and {cmdab:z}{it:(z)} for respectively y1, y2, y3, ... and z1, z2, z3,... in the dataset). 


{title:Reporting}

{p 4 4 2} 
* Descriptive statistics:

{p 8 4 2} 
- % population ever poor (intertemporally poor)

{p 8 4 2} 
- Distribution of the number of periods below the poverty

{p 8 4 2} 
- Distribution of the number of poverty spells 

{p 8 4 2} 
- For intertemporally poor population: 

{p 12 4 2} 
Average number of periods below the poverty line

{p 12 4 2} 
Average number of poverty spells

{p 12 4 2} 
Average duration of poverty spells

{p 4 4 2} 
* Aggregate measure of intertemporal poverty P(y;z) for the specified values of the parameters:

{p 8 8 2} 
. gamma, capturing the sensitivity of individual poverty indicators to variability of per-period poverty gaps across time.


{p 8 8 2} 
. beta, capturing the sensitivity of individual intertemporal poverty indicators to the duration of poverty spells.


{p 8 8 2} 
. alpha, capturing the sensitivity of the aggregate intertemporal poverty index to inequality of individual poverty indicators among the poor.


{p 4 4 2} 
* If option {cmdab:dec:omp} is specified, the decomposition of the indices into poverty incidence, intensity and inequality among the poor, is also reported.


{title:Required Options}

{p 4 8 2} 
{cmdab:y}{it:(y_stub)} to indicate the set of variables yt containing per-period income or expenditure.

{p 4 8 2} 
{cmdab:z}{it:(z_stub)} to indicate the set of variables zt containing per-period poverty lines.

{p 4 8 2} 
{cmdab:t}{it:(#)} to indicate the number T of periods to be used in the analysis.



{title:Other Options}

{p 4 8 2} 
{cmdab:non:normalized} to use non-normalized per-period poverty gaps (yt-zt). By default, gaps are normalized dividing by the per-period poverty line, (yt-zt)/zt.

{p 4 8 2} 
{cmdab:th:ao}{it:(#)} to set a time cut-off, such that only those individuals with at least the specified number of periods below the poverty line will be considered as intertemproally poor. 
The default is {cmdab:th:ao}{it:(1)}, that is 1 period out of T.

{p 4 8 2} 
{cmdab:g:amma}{it:(# [# ...])} to indicate the integer values of gamma, the default is {cmdab:g:amma}{it:(0 1 2)}.

{p 4 8 2} 
{cmdab:b:eta}{it:(# [# ...])} to indicate the real values of beta, the default is {cmdab:b:eta}{it:(0 1)}.

{p 4 8 2} 
{cmdab:a:lpha}{it:(# [# ...])} to indicate the integer values of alpha, the default is {cmdab:a:lpha}{it:(0 1 2)}.


{p 8 8 2}
{cmdab:Notes}:

{p 8 4 2}
 Foster's (2007, 2009) measure is P(thao>=1;alpha=1;beta=0;gamma>=0).

{p 8 4 2}
Bossert et al.'s (2012) measure is P(thao=1;alpha=1;beta=1;gamma>=0) multiplied by T.

{p 4 8 2} 

{p 4 8 2} 
{cmdab:gen}{it:(newvar)} to create new variables containing individual poverty indicators, with subscripts _i_j indicating the parameters gamma=i and the jth beta used.

{p 4 8 2} 
{cmdab:dec:omp} to make the decompoistion of the index for each aplha into incidence, intensity and inequality among the poor. 
It also computes the variance of individual intertemporal poverty indicators (p) and the  coefficient of variation for 1-p in the case of alpha=2 and normalized gaps.

{p 4 8 2} 
{cmdab:f:ormat}{it:(%9.4f)} to change numeric format, %9.4f is the default.


{title:Saved results} 


{p 4 4 2} 
Matrices:

{p 8 8 2}
r(pov) : poverty indices (and decomposition if option  {cmdab:dec:omp} specified).

{p 8 8 2} 
r(dec2) : the special decomposition for alpha=2 (if option  {cmdab:dec:omp} specified).


{p 4 4 2} 
Scalars:

{p 8 8 2} 
r(everpoor) : proportion of intertemporally poor individuals

{p 8 8 2} 
r(npoor) : aveage number of poor periods (for those intertemporally poor)

{p 8 8 2} 
r(npovspells) : average nmber of poverty spells (for those intertemporally poor)

{p 8 8 2} 
r(meandur) : average duration of poverty spells (for those intertemporally poor)

{p 8 8 2} 
r(P_i_j_k) : aggregate intertemporal poverty measure P(y;z) for gamma=i, the jth beta, and alpha=k



{p 12 12 2} 
Note that while subscripts _i and _k, respectively indicate the value of gamma and alpha (which are all integers),
_j indicates the order of beta (not its value), given that beta can take non-integer values, for example, if beta=0, .5, 1, subscript _1 refers to beta=0, _2 to beta=.5, and _3 to beta=1.


{title:Inference}


{p 4 4 2} 
It is possible to obtain bootstrap standard errors with {cmd:povtime} using the returned scalars (see example below)


{title:Examples} 

{p 4 8 2}
. {stata use povtime.dta, clear }

{p 4 8 2}
. {stata desc}

{p 4 8 2}
Basic

{p 4 8 2}
. {stata povtime [aw=w] if country==1, y(y) z(z) t(6) }

{p 4 8 2}
Saved results

{p 4 8 2}
. {stata ret list}

{p 4 8 2}
Generating individual poverty indicators

{p 4 8 2}
. {stata povtime [aw=w] if country==1, y(y) z(z) t(6) gen(p)}

{p 4 8 2}
. {stata desc p*}

{p 4 8 2}
Computing Intertemporal TIP curve (gamma=2, beta==1) using {help glcurve} (it must be installed)

{p 4 8 2}
. {stata gen mp_2_2=-p_2_2}

{p 4 8 2}
. {stata glcurve p_2_2 [aw=w] if country==1, sort(mp_2_2)}

{p 4 8 2}
Estimating the density of indvidual poverty indicators for gamma=2 and the first requested beta (beta==0) using {help akdensity} (it must be installed) 

{p 4 8 2}
. {stata akdensity p_2_1 if country==1 & p_2_1>0 [aw=w] , at(p_2_1)}

{p 4 8 2}
Changing default values of the parameters (ex.: only those with at least 2 periods of poverty are considered intertemporally poor and then the gaps of those only poor once are made zero; other values of alpha, beta and gamma requested)

{p 4 8 2}
. {stata povtime [aw=w] if country==2, y(y) z(z) t(6) thao(2) gamma(0 1 2 3 4) beta(0 .25 .50 .75 1 2) alpha(1 2 3 4 5 6) }

{p 4 8 2}
Decomposition

{p 4 8 2}
. {stata povtime [aw=w] if country==1, y(y) z(z) t(6) decomp}

{p 4 8 2}
Bootstrapping P(y;z), exmaple for (gamma=2, beta=0, alpha=2), and (gamma=2, beta=1, alpha=2) [BC estimates]

	cap program drop pt
	program def pt
	 povtime [aw=w] if country==1, y(y) z(z) t(6)
	end
	bootstrap r(P_2_1_2) r(P_2_2_2) if country==1, reps(10): pt
	estat bootstrap

{title:Author}


{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break} 
36310 Vigo, Galicia, Spain.


{title:References}


{p 4 8 2}
Bossert, W., Chackravarty, S. and D’Ambrosio, C. (2012) Poverty and Time, Journal of Economic Inequality, 10(2): 145-162.

{p 4 8 2}
Foster, J.E. (2007) A class of chronic poverty measures, Working Paper No 07-W01, Department of Economics, Vanderbilt University.

{p 4 8 2}
Foster, J.E. (2009) A class of chronic poverty measures, in Poverty Dynamics: Interdisciplinary Perspectives, Addison, T., Hulme, D. and Kanbur, R. (Eds.), Chapter 3, Oxford University Press: Oxford.

{p 4 8 2}
Gradín, C, Del Río, C. and Cantó, O. (2012) Poverty accounting for time, Review of Income and Wealth, 58(2): 330-354.


{title:Also see}


{p 4 13 2}
{help glcurve} if installed, for TIP curves.

{p 4 8 2}
{help akdensity} and {help sumdist} if installed, for analysis of the distribution of individual poverty indices.

{p 4 8 2}
{help apoverty}, {help povdeco}, {help poverty} and {help sepov}  if installed, for measuring poverty in a cross-section of individuals.






