{smcl}
{hline}
{cmd:help hoishapley} {right:Alejandro Hoyos}
{hline}

{title:{cmd:hoishapley} - Shapley Decomposition of the Human Opportunity Index}

{p 4 8 2}
{cmd:hoishapley}
{it:{help depvar}}
[{cmd:{help if}}]
[{cmd:{help in}}]
[{cmd:{help weight}}]
[,
{cmd:shapley(}{it:varlist of circumstances or globals}{cmd:)}
{cmd:globals}
{cmd:shapleyc(}{it:list of categorical circumstances}{cmd:)}
{cmd:eliminate}
{cmd:fix}
{cmd:filehoi(}{it:filename}{cmd:)}
{cmd:format(}{it:xls or dta}{cmd:)}
{cmd:fileshapley(}{it:filename}{cmd:)}
{cmd:adjust1(}{it:[var[= #] ...]}{cmd:)}
{cmd:controls(}{it:varlist}{cmd:)}
{cmd:simulated}]{p_end}

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}

{title:Description}

{p 4 4 2}{cmd:hoishapley} computes the Shapley decomposition of the Human Opportunity Index (HOI), it includes the estimation of the basic statistics like Coverage
of Basic Opportunities (C), the Dissimilarity Index (D), and the Human Opportunity Index (HOI). The decomposition allows the identification of the marginal/average contribution
of each circumstance to inequality in access to opportunities.{p_end}

{title:Options}

{p 4 4 2}{cmd:shapley(}{it:varlist of circumstances or globals}{cmd:)} computes the Shapley decomposition of the HOI using the list of circumstances included in {it:varlist of circumstances or globals}. If the option {cmd:globals} is specified then {it:varlist of globals} must contain a list of globals previously defined which aggregate circumstances into broader categories.{p_end}

{p 4 4 2}{cmd:globals} indicates that the list included in {cmd:shapley(}{it:varlist of circumstances or globals}{cmd:)} is a list of globals previously defined by the user.{p_end}

{p 4 4 2}{cmd:shapleyc(}{it:list of categorical circumstances}{cmd:)} is used to add to the list of circumstances defined in {cmd:shapley( )} categorical variables such as region or ethnicity. For each categorical circumstance listed, a set of dummy variables for each category is created and by default the first category is omitted. This option should not be used with {cmd:globals}. {p_end}

{p 4 4 2}{cmd:eliminate} indicates that in each iteration of the Shapley decomposition procedure a new logit model is estimated using the circumstances included in the set of the specific iteration. This alternative provides the marginal contribution to the inequality index of adding a circumstance. The default.{p_end}

{p 4 4 2}{cmd:fix} is an alternative to {cmd:eliminate}. It indicates that in each iteration of the Shapley decomposition procedure, the full logit model specification is used adjusting to the mean the circumstances not included in the set of the specific iteration. This alternative provides the average contribution to the inequality index of adding a circumstance.{p_end}

{p 4 4 2}{cmd:filehoi(}{it:filename}{cmd:)} allows to save the basic statistics of the HOI and the contribution of each circumstance in an Excel or Stata file. The format is defined by the option {cmd:format}. Please only include a {it:filename} without extension. {p_end}

{p 4 4 2}{cmd:format(}{it:xls or dta}{cmd:)} specified the format of the file {cmd:filehoi}. The default format is Excel. {p_end}

{p 4 4 2}{cmd:fileshapley(}{it:filename}{cmd:)} allows to save the results of running all the iterations of the Shapley decomposition in a Stata dataset. Please only include a {it:filename} without extension. {p_end}

{p 4 4 2}{cmd:adjust1}{cmd:(}[var[= #] ...]{cmd:)} provides the specifications of the first adjusted predictions. The estimate is computed for each variables, setting the variables specified in [var[= #] ...] to their mean or to the specified number if the = # part is specified.
Variables used for the estimation but not included in adjust variable list are left at their current values, observation by observation.{p_end}

{p 4 4 2}{cmd:controls(}{it:list of variables}{cmd:)} the list of controls are used in the estimation of the logit model in each of the iterations but are not considered as sources of inequality. The controls are kept constant at the mean.{p_end}

{p 4 4 2}{cmd:simulated} allows to create hypothetical individuals with the characteristics defined in the {cmd:adjust1} option. This option does not force the coverage rate to be equal to the proportion of the sample with access to the opportunity. This option does not work with the {cmd:fix} option. {p_end}


{title:Output}

{p 4 4 2}{cmd:Human Opportunity Index (HOI)} Human Opportunity Index{p_end}

{p 4 4 2}{cmd:D-Index (D) } Dissimilarity Index{p_end}

{p 4 4 2}{cmd:Penalty } Difference between the coverage and the HOI{p_end}

{p 4 4 2}{cmd:Coverage (C)} Coverage of Basic Opportunities{p_end}
 
{p 4 4 2}{cmd:Contributions} share of the D-Index that is explained for each one of the circumstances. All the contributions add up to 100{p_end}

{title:Examples}

{p 4 4 2} Suppose you have a dataset with electricity {0-no access, 1-access}, male {0-female, 1-male}, male_head {0-female head, 1-male head}, eduyears_head {0,1,2,...,15}, siblings {0,1,2...,10}, log_income [0...1000], region {A, B, C, D, E}, location {Urban, Rural}, age {6,7,...,16}, year {2001, 2005, 2010}.{p_end}

{p 4 4 2} The following command will produce the HOI for electricity using male, male_head, eduyears_head, sibligns, and log_income as circumstances for children 6 to 16 in 2001 using the elimination method (the default).{p_end}

{p 8 12}{inp:. hoishapley electricity  [fw=sweight] if year==2001, shapley(male male_head eduyears_head sibligns log_income)}{p_end}

{p 4 4 2} The following command will produce the HOI for electricity using male, male_head, eduyears_head, sibligns, log_income, region, and location  as circumstances for children 10 to 14 in 2001 using the fix method.{p_end}

{p 8 12}{inp:. hoishapley electricity  [fw=sweight] if (age>=10 & age<=14) & year == 2001, shapley(male male_head eduyears_head sibligns log_income) shapleyc(region location) fix}{p_end}

{p 4 4 2} Alternatively, the previous result can be obtained by:{p_end}

{p 8 12}{inp:. tab region, gen(reg_)}{p_end}

{p 8 12}{inp:. tab location, gen(loc_)}{p_end}

{p 8 12}{inp:. hoishapley electricity  [fw=sweight] if (age>=10 & age<=14) & year == 2001, shapley(male male_head eduyears_head sibligns log_income reg_2 reg_3 reg_4 reg_5 loc_2) fix}{p_end}

{p 4 4 2} The following commands will produce the HOI for electricity using four dimensions: gender (male), parents (male_head, eduyears_head), family (sibligns, log_income), and geographic (region, location) for children 6 to 16 in 2001 using the elimination method (the default).{p_end}

{p 8 12}{inp:. global gender = "male"}{p_end}

{p 8 12}{inp:. global parents = "male_head eduyears_head"}{p_end}

{p 8 12}{inp:. global family = "sibligns log_income"}{p_end}

{p 8 12}{inp:. global geographic = "reg_2 reg_3 reg_4 reg_5 loc_2"}{p_end}

{p 8 12}{inp:. hoishapley electricity  [fw=sweight] year == 2001, shapley(gender parents family geographic) globals}{p_end}

{p 4 4 2} The following command will produce the HOI for electricity using male, male_head, eduyears_head, sibligns, and log_income for children 10 years old in 2001 using the elimination method (the default). But using the sample of children 6 to 16 years. The output will be saved in a Stata file called hoi_shapley_elec.dta{p_end}

{p 8 12}{inp:. hoishapley electricity  [fw=sweight] if year==2001, shapley(male male_head eduyears_head sibligns log_income) adjust1(edad=10) controls(edad) hoishapley(hoi_shapley_elec) format(dta) simulated}{p_end}


{title:Saved Results}

{p 4}{cmd:hoishapley} return results in r() format. Type {help return list} after estimation.{p_end}

{title:Thanks for citing hoishapley as follows}

{p 4 4 2}A. Hoyos, 2013.
"HOISHAPLEY: Stata module to decompose the Human Opportunity Index," Statistical Software Components, Boston College Department of Economics.{p_end}

    
{title:References}

{p 4 4 2} Alejandro Hoyos and Ambar Narayan, 2011. "Inequality of opportunities among children: how much does gender matter?" Background paper for the World Development Report 2012.
{browse "http://siteresources.worldbank.org/INTPOVERTY/Resources/Role_of_Gender_WDR_bground_June_27,_2011.pdf"}{p_end}

{p 4 4 2}Jose Molinas Vega, Ricardo Paes de Barros, Jaime Saavedra Chanduvi, et all, 2010. "Do Our Children Have a Chance? The 2010 Human Opportunity Report for Latin 
America and the Caribbean - Conference Edition", World Bank: Washington, DC.
{browse "http://www.worldbank.org/lacopportunity/"}{p_end}

{p 4 4 2}Ricardo Paes de Barros, Francisco H.G. Ferreira, Jose Molinas Vega, Jaime Saavedra Chanduvi, et all, 2008. "Measuring Inequality
of Opportunities in Latin America and the Caribbean", World Bank: Washington, DC.
{browse "http://siteresources.worldbank.org/LACEXT/Resources/258553-1222276310889/Book_HOI.pdf"}{p_end}

{p 4 4 2}Anthony F. Shorrocks, 2013. "Decomposition procedures for distributional analysis: a unified framework based on the Shapley value" The Journal of Economic Inequality
March 2013, Volume 11, Issue 1, pp 99-126.{p_end}


{title:Acknowledgements}
    {p 4 4 2}Numerous people have provided feedback and advice and the author is very grateful for their comments. In
    particular I would like to thank: Ambar Narayan, Jose R. Molinas Vega, Jaime Saavedra, Ricardo Paes de Barros, Javier Escobal, Carlos Rondon,  Sailesh Tiwari,  
    Shabana Mitra, Gabriel Facchini, João Pedro Azevedo, Oscar Eduardo Barriga, Carlos Eduardo Velez, Ana Luisa Gouvea Abras. The usual disclaimer
    applies.{p_end}

{title:Authors}

    Alejandro Hoyos
    ahoyossuarez@worldbank.org

{title:Remark}

{p 4 4 2}Please note that {cmd:hoishapley} uses the user written packages {help catenate} on its calculations. 
User's can download it from {help ssc}.{p_end}
