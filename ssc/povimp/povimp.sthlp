{smcl}
{hline}
help for {cmd:povimp}
{right:Hai-Anh H. Dang}
{right:Minh C. Nguyen}
{hline}

{title:{cmd:povimp} - tool for poverty imputation}

{p 8 16 2}
{opt povimp} {depvar} {indepvars} {ifin} [{it:{help weight##weight:weight}}]
{cmd:,} by{cmd:(}{it:varname numeric}{cmd:)} from{cmd:(}{it:numlist max=1}{cmd:)} 
to{cmd:(}{it:numlist max=1}{cmd:)} method{cmd:(}{it:string}{cmd:)} [{it:options}]

{title:Description}

{p 4 4 2} Obtaining consistent estimates on poverty over time as well as monitoring poverty trends 
on a timely basis is essential for poverty reduction. However, these objectives are not readily 
achieved in practice when household consumption data are neither frequently collected, nor constructed 
using consistent and transparent criteria. The challenge can be broadly regarded as one involving 
missing data: consumption (or income) data are available in one period but in the next period(s) are 
either not available, or are not comparable. Dang, Lanjouw, and Serajuddin (2014) propose a framework 
that offers poverty imputation in these settings; {cmd:povimp} implements their poverty imputation procedures.
{p_end}

{p 4 4 2} This program is designed for datasets with two or more cross sectional survey round, where 
consumption data in the survey round of interest are missing but the control variables are non-missing. 
{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt by(varname)}specifies the variable that indicates the survey year (or round).

{phang}
{opt from(#)}specifies the survey year (or round) that has consumption data and 
that provides the underlying regression for imputation. The number for this base 
survey year takes one of the values specified in the variable used in the {opt by(varname)} 
option. For example, if the year variable has two values 2008 and 2010, either of 
which can be specified as a number to be used.

{phang}
{opt to(#)}specifies the survey year (or round) that has missing consumption data and needs 
to be imputed into. The number for this survey year takes one of the values specified in the 
variable used in the {opt by(varname)} option. For example, if the year variable has two values 2008 
and 2010, either of which can be specified as a number to be used.

{phang}
{opt method(string)}specifies the imputation method. Four methods are allowed.

{pmore} 
{cmd:normal}: using the linear regression (OLS) model with the distribution of the error terms assumed to be normal.

{pmore} 
{cmd:empirical}: using the linear regression (OLS) model with the empirical distribution of the error terms.

{pmore}
{cmd:probit}: using the probit regression model.

{pmore}
{cmd:logit}: using the logit regression model.

{phang}
{opt pline(varname)}specifies the variable that indicates the poverty line(s).
	
{dlgtab:Optional}

{phang}
{opt wt:stats(varname)} specifies the weight variable for the summary statistics. 
If left blank, unweighted estimates are provided. Note that weights should generally 
be used for the summary statistics unless the data are self-weighted, but unweighted 
estimates are an optional feature.  

{phang}
{opt cluster(varname)} specifies the cluster variable or the primary sampling unit. 

{phang}
{opt strata(varname)} specifies the strata variable.

{phang}
{opt decomp(relative or absolute)} specifies the consumption (or income) variable as the main variable that can be used in the decomposition 
of the changes in poverty between these two periods. This option is {cmd:only} specified when two survey 
rounds with consumption data are available. If this option is used, the poverty lines from {cmd:pline(varname)} will be used for both periods. One can 
use either suboption {cmd:relative} or {cmd:absolute} for the decomposition. The suboption {cmd:relative} shows the relative contributions
in percentage terms from the characteristics and estimated coefficients, while the suboption {cmd:absolute} shows the contributions in absolute terms instead.  

{phang}
{opt wald} specifies that the Wald (Chow) test result for the assumption of constant 
parameters in both survey years are shown. This option is {cmd:only} specified when two survey 
rounds with consumption data are available.

{phang}
{opt rep(#)} specifies the number of simulations. We recommend using 1,000 simulations or more for 
robust estimation of standard errors. If left blank, the default number of replication in Stata (50) 
is used. 

{phang}
{opt seed(#)} specifies the random seed number that can be used for replication of results. The default seed is 1234567.

{phang}
{opt nocons:tant} suppresses the constant term (intercept) in the model.
 
{title:Saved Results}

{cmd:povimp} returns results in {hi:e()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(cmdline)}}the code line used in the session {p_end}
{synopt:{cmd:e(N1)}}estimation sample in the first period, (from) {p_end}
{synopt:{cmd:e(N2)}}estimation sample in the second period, (to) {p_end}
{synopt:{cmd:e(pov_imp)}}poverty rates based on imputed data {p_end}
{synopt:{cmd:e(pov_var)}}variance of poverty rates based on imputed data {p_end}
{synopt:{cmd:e(p2_p21)}}difference of actual poverty rate of later period (to) and imputed poverty rate {p_end}
{synopt:{cmd:e(p21_p1)}}difference of imputed poverty rate and actual poverty rate of initial period (from) {p_end}
{synopt:{cmd:e(p21_p1)}}difference of imputed poverty rate and actual poverty rate of initial period (from) {p_end}
{synopt:{cmd:e(p)}}two-sided p-value {p_end}
{synopt:{cmd:e(F)}}F statistic {p_end}
{synopt:{cmd:e(df)}}test constraints degrees of freedom {p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom {p_end}

{title:Examples}

{pstd}1) Assume that consumption data are available in the 2008 survey round but are either missing 
or not comparably constructed in the 2010 survey round. We can impute poverty rate from survey year 
2008 into survey year 2010 using the normal linear regression model with the distribution of the 
error terms assumed to be normal, where the poverty line in 2008 is 40.
{p_end}

{phang2}{cmd:. gen pline= 40}{p_end}
{phang2}{cmd:. povimp y x1 x2 x3, by(year) from(2008) to(2010) pline(pline) cluster(psu) strata(district)  method(normal)}{p_end}

{pstd}2) Assume that consumption data are available in two survey rounds in 2005 and 2008. To help with 
model selection for imputation in a more recent year, we can decompose the change in poverty 
rates between survey year 2005 and survey year 2008 and show the Wald test result for the assumption of 
constant parameters in both survey years.{p_end}

{phang2}{cmd:. gen pline= 30 if year==2005}{p_end}
{phang2}{cmd:. replace pline= 50 if year=2008}{p_end}
{phang2}{cmd:. // y is available in both 2005 and 2008}{p_end}
{phang2}{cmd:. povimp y x1 x2 x3, by(year) from(2005) to(2008) pline(pline) decomp(relative) wald cluster(psu) strata(district)  method(probit)}{p_end}

{title:References}

{p 4 4 2} Dang, Hai-Anh H., Peter F. Lanjouw, and Umar Serajuddin. (2014). “Updating Poverty Estimates 
at Frequent Intervals in the Absence of Consumption Data: Methods and Illustration with Reference to a 
Middle-Income Country”, World Bank Policy Research Paper # 7043. Washington DC: The World Bank.
{p_end}

{title:Authors}
	{p 4 4 2}Hai-Anh H. Dang, Economist, World Bank, USA, hdang@worldbank.org{p_end}
	{p 4 4 2}Minh C. Nguyen, Economist, World Bank, USA, mnguyen3@worldbank.org{p_end}

{title:Thanks for citing povimp as follows}

{p 4 4 2}{cmd: povimp} is a user-written program that is freely distributed to the research community. {p_end}

{p 4 4 2}Please use the following citation:{p_end}
{p 4 4 2}Dang, Hai-Anh H. and Minh C. Nguyen. (2014). “{cmd:povimp}: Stata module to 
impute poverty in the absence of consumption data”. World Bank, Development Research Group, Poverty and Inequality Unit and Global Poverty Practice.
{p_end}

{title:Acknowledgements}
    {p 4 4 2}We would like to thank the UK Department of International Development for funding assistance through its Strategic Research Program. 
	All errors and ommissions are exclusively our responsibility.{p_end}
