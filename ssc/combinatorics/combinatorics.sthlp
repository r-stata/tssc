{smcl}
{* *! version 0.2 beta 27fev2015}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Compatibility issues" "examplehelpfile##comp"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:Combinatorics} {hline 2} This data mining program performs batch OLS estimation, out-of-sample validation and Leave-one-out cross-validation (LOOCV) on all the {it:2^n} models combined from a set of {it:n} candidate explanatory variables.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:combinatorics}
{depvar} {indepvars}  {ifin} {weight}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opth a:dd(varlist)}}Add this list of independent variables to all 2^n models{p_end}

{syntab:Reporting}
{synopt:{cmdab:s:aving(}{it:{help filename}}{it: [,noreplace]}{cmd:)}}Save the results in a file instead of replacing the current dataset.{p_end}
{synoptline}
{p 4 6 2}
{it:depvar}, {it:indepvars} and {it:varlist} may contain factor-variable operators (see {help fvvarlist}).{p_end}
{p 4 6 2}
{it:depvar}, {it:indepvars} and {it:varlist} may contain time-series operators (see {help tsvarlist}).{p_end}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, and {cmd:iweight}s are
allowed; see {help weight}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:combinatorics} evaluates the OLS explanatory performances and out-of-sample (OOS) predictive performances of all possible {it:2^n} models of a dependent variable that can be generated with a given set of {it:n} possible explanatory variables. 
This can be used in data mining in order to evaluate the distribution of predictors' coefficients and performances across the space of potential models. 
This can also be used as a benchmark tool in order to evaluate model selection and machine learning algorithms in natural datasets. 
Given the important risk of overfitting in high-dimensional feature selection problems, a model's performance is better approached by its cross-validation measure of fit, which is calculated here (see LOOCV measures below). 
Note that the number of possible models explodes with the number of possible explanatory variables and you would better limit yourself to 20 {it:indepvars} max ({it:i.e.}, 1,048,576 models). 
This command is a wrapper for {help tuples:tuples} and installs it automatically if necessary.{p_end}

{pstd}The resulting dataset contains {it:2^n} rows, one for each evaluated model. For each model are displayed the variables shown below.{p_end}
{pstd}Model's characteristics:{p_end}
{phang2}{it:i}: Identification number of the model.{p_end}
{phang2}{it:model}: (Only for Stata versions >=13) String variable containing the specification of the model, in a Stata-readable format.{p_end}
{phang2}{it:rank}: Rank of the model, {it:i.e.} the number of non-collinear explanatory variables (constant included).{p_end}
{phang2}{it:timer}: Time in seconds since the beginning of the program until the evaluation of this model.{p_end}
{pstd}Model's estimation results:{p_end}
{phang2}{it:n}: The sample size of the OLS estimation of this model.{p_end}
{phang2}{it:r2}: The explanatory performance of the model, as measured by the R-squared.{p_end}
{phang2}{it:[Coefficient's name]}: Vector of variables containing the model's coefficients, set to missing values if not estimated in this model.{p_end}
{phang2}{it:[Coefficient's name_SE]}: Vector of variables containing the model coefficients's standard errors, set to missing values if not estimated in this model.{p_end}
{pstd}Model's out-of-sample predictive performances:{p_end}
{phang2}{it:pseudor2}: Leave-one-out Cross-Validation (LOOCV) pseudo-R2, approximated from the hat matrix, calculated in the estimation subsample.{p_end}
{phang2}{it:rmse}: Root Mean Squared Error of prediction, calculated from the LOOCV procedure.{p_end}
{phang2}{it:oosn}: Sample size of the validation subsample, which is the complement subsample of the estimation subsample. Should be missing if no {ifin} options constrain the estimation subsample.{p_end}
{phang2}{it:oosr2}: Predictive performance of the model in the validation subsample, as measured by the squared of the correlation coefficient between predicted and actual dependent variable (pseudo-R2). 
Should be missing if no {ifin} options constrain the estimation subsample.{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opth a:dd(varlist)} Specifies a list of independent variables that will automatically be added in every one 
of the {it:2^n} models.

{dlgtab:Reporting}

{phang}
{cmdab:s:aving(}{it:{help filename}}{it: [,noreplace]}{cmd:)} Save the output in this .dta file instead of replacing the current dataset. 
Suboption {it: noreplace} forbids files to be overwritten. Default behavior is to overwrite any existing files.

{marker comp}{...}
{title:Issues}

{pstd}This program is still in beta.

{pstd}There is no interest for this program if your set of candidate independent variables is too large ({it:e.g.} greater than 20 variables). 
The program won't interrupt but the computation time doubles for every supplementary variable in {it:indepvars}. 
You should definitely run model selection algorithms that do not search exhaustively through the models space if you intend to do model selection with tons of potential explanatory variables.

{pstd}If you experience any trouble or bugs, please send me an e-mail at the address specified at the end of this page.


{marker examples}{...}
{title:Examples}

{pstd}Open the 1978 Automobile Dataset, and evaluate the 1,024 models of the cars' {it:price} obtained from combining all of their 10 characteristics:{p_end}
{phang2}. {stata sysuse auto,clear}{p_end}
{phang2}. {stata combinatorics price mpg i.rep78 headroom-foreign}{p_end}

{pstd}In the resulting dataset, plot the histogram of the 512 {it:mpg} coefficients obtained across all models:{p_end}
{phang2}. {stata hist mpg}{p_end}

{pstd}Plot the relationship between the models explanatory and predictive performances (R2 and LOOCV Pseudo-R2) against the complexity of the model (Rank):{p_end}
{phang2}. {stata twoway (scatter pseudor2 r2 rank,jitter(5 5))(lpolyci pseudor2 rank)(lpolyci r2 rank),xline(6)}{p_end}
{phang2}* The LOOCV Pseudo-R2 does not increases monotonically with model complexity (it reaches a local maximum at a rank of 6), signing a risk of overfitting and calling for parsimony in the model selection.{p_end}

{pstd}(The economist's bad practice:) Generate p-values for mpg coefficients and show the models of rank 6 whose significance is below 1% for these coefficients:{p_end}
{phang2}. {stata gen double mpg_p=ttail(n-rank,abs(mpg/mpg_se))*2}{p_end}
{phang2}. {stata list model pseudor2 if mpg_p<0.01 & rank==6}{p_end}
{phang2}* ("model" only shows for Stata 13 and above) Best model to predict {it:price} with a highly significant {it:mpg} coefficient is obtained with the model made of 
{it:mpg}, {it:headroom}, {it:trunk}, {it:gear_ratio}, and {it:foreign} (plus the constant).{p_end}

{title:Examples with out-of-sample validation}

{pstd}Open again the 1978 Automobile Dataset, and evaluate the same models as above, but this time on only 90% of the sample, chosen randomly:{p_end}
{phang2}. {stata sysuse auto,clear}{p_end}
{phang2}. {stata set seed 100}{p_end}
{phang2}. {stata gen double oos=(runiform()>0.9)}{p_end}
{phang2}. {stata combinatorics price mpg i.rep78 headroom-foreign if !oos}{p_end}

{pstd}The remaining 10% serve for "out-of-sample" (OOS) predictions: 
the predictions are made out of their estimation sample and tested against the actual values; 
the OOS Pseudo-R² is the squared of the correlation coefficient between OOS predicted and actual values. 
It can be used as a measure of predictive performance in the same way as the LOOCV Pseudo R²: {p_end}
{phang2}. {stata twoway (lpolyci r2 rank)(lpolyci pseudor2 rank)(lpolyci oosr2 rank)}{p_end}

{pstd}It is more easy to communicate results with OOS Pseudo-R² but LOOCV Pseudo-R² is a better procedure
as it does not require to spare observations and does not rely on the -arbitrary or random - choice of the validation sample and sample size. 
For instance, had we chose another validation sample, the OOS Pseudo-R² could have given a different conclusion but the LOOCV Pseudo R² would keep 
showing overfitting: {p_end}
{phang2}. {stata sysuse auto,clear}{p_end}
{phang2}. {stata set seed 200}{p_end}
{phang2}. {stata gen double oos=(runiform()>0.9)}{p_end}
{phang2}. {stata combinatorics price mpg i.rep78 headroom-foreign if !oos}{p_end}
{phang2}. {stata twoway (lpolyci r2 rank)(lpolyci pseudor2 rank)(lpolyci oosr2 rank)}{p_end}

{title:Examples with factor-variables and time-series operators}

{pstd}Open the S&P500 Dataset, and evaluate the models of a day's {it:price change} obtained from combining trade volume, price change, and/or price high, low and/or their interaction with values taken one and/or two 
days before (10 predictors): {p_end}
{phang2}. {stata sysuse sp500,clear}{p_end}
{phang2}. {stata tsset date,daily}{p_end}
{phang2}. {stata "combinatorics change L(1/2).(volume change high low c.high#c.low)":combinatorics change L(1/2).(volume change c.high##c.low)}{p_end}

{pstd}In the resulting dataset, look at the statistics of the models' explanatory power (R²) and predictive power (LOOCV Pseudo R²), both are extremely low:{p_end}
{phang2}. {stata summarize r2 pseudor2}{p_end}

{pstd}Looking at the relationship between explanatory and predictive powers as regards model's complexity, 
we see a high risk of overfitting (explanatory power increases with rank as predictive power decreases):{p_end}
{phang2}. {stata twoway (scatter pseudor2 r2 rank,jitter(5 5))(lpolyci pseudor2 rank)(lpolyci r2 rank)}{p_end}
{phang2}* The fact that the Pseudo-R² is so low that it attains negative values is theoretically possible.{p_end}

{title:Examples with adding a fixed explanatory variables set}

{pstd}We reload the previous dataset and run the same command, but this time we add for each of the models the daily {it:differences} in price changes from the second to the fourth days before:{p_end}
{phang2}. {stata sysuse sp500,clear}{p_end}
{phang2}. {stata tsset date,daily}{p_end}
{phang2}. {stata "combinatorics change L(1/2).(volume change high low c.high#c.low),add(D(2/4).change)":combinatorics change L(1/2).(volume change c.high##c.low),add(D(2/4).change)}{p_end}

{pstd}In the resulting dataset, the models' performances show cases of perfect collinearity between explanatory and dependent variables (R²=1):{p_end}
{phang2}. {stata summarize r2 pseudor2}{p_end}

{pstd}These collinear cases seem to appear when change is predicted by its second difference, plus twice its first lag minus its second lag:{p_end}
{phang2}. {stata format %10.0f D2_change-_constant}{p_end}
{phang2}. {stata summarize D2_change-_constant if r2==1, sep(0) format}{p_end}

{pstd}We can check that:{p_end}
{phang2}. {stata sysuse sp500,clear}{p_end}
{phang2}. {stata tsset date,daily}{p_end}
{phang2}. {stata reg change D2.change L1.change L2.change}{p_end}

{title:References}

{p 4 4 4 0} Hastie, Trevor, Robert Tibshirani, and Jerome Friedman. The Elements of Statistical Learning: 
Data Mining, Inference, and Prediction. Springer Science & Business Media, 2013. {p_end}

{p 4 4 4 0} Luchman, Joseph, Klein, Daniel and Cox, Nicholas, (2016), TUPLES: Stata module for selecting all possible tuples from a list, 
http://EconPapers.repec.org/RePEc:boc:bocode:s456797 {p_end}


{title:Author}

{p 4 4 4 0}Claire Vandendriessche{p_end}
{p 4 4 4 0}Paris School of Economics{p_end}
{p 4 4 4 0}claire.vandendriessche@psemail.eu{p_end}


