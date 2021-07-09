{smcl}
{* *! version 1.0 12feb2016}{…}

{hline}

help {cmd:marhis} {right: {browse Enrique.Hernandez@EUI.eu: Enrique Hernández}}
{hline}

{title:Predictive margins and marginal effects plots with histogram in the back after regress, logit, xtmixed and mixed.}

{p 4}Syntax

{p 8 14}{cmd:marhis} 
{cmd: indepvar} 
[ {cmd:,} ]
[ {cmd:mar(}{it:varname}{cmd:)} ]
[ {cmd:cate(}{it:varname}{cmd:)} ]
[ {cmd:points(}#{cmd:)} ]
[ {cmd:percent} ]
[ {cmd:discrete} ]
[ {cmd:level(}#{cmd:)} ]
[ {cmd:label(}#{cmd:)} ]
[ {cmd:summaryno} ]
[ {cmd:confidenceno} ]
[ {cmd:atmeans} ]


{title:Description}

{p 4 4} Following some of the recommendations of Berry, Golder and Milton (2012) {cmd:marhis} generates predictive margins and marginal effects 
plots with a histogram summarizing the distribution of the variable on the x-axis in the back. {cmd:marhis} can be used after {cmd:regress}, {cmd:logit}, {cmd:xtmixed} or {cmd:mixed}. 

{p 4 4} {cmd:marhis} can be used to graph the adjusted predictions of any continuous variable in the model (A), to graph the results of an interaction 
between two continuous variables (B), or to graph the results of an interaction between a continuous and a categorical variable (C). Interactions must always be specified using factor 
variable notation in the regression model but not in the {cmd:marhis} command. 

{p 4 4} {cmd:marhis} does not require the user to run the {cmd:margins} command since the estimations of the marginal effects or marginal predictions are 
handled directly by {cmd:marhis} relying on the {cmd:margins} command. A summary of the {cmd:margins} specification used by {cmd:marhis} is presented to the user in the results window. 

{p 4 4} A) {bf:Plotting average adjusted predictions (AAPs) of the dependent variable across the range of any continuous independent variable included in the regression model}. The {cmd:marhis} command should 
be specified as follows: 

{p 4 8} {cmd:. marhis indepvar }{p_end}

{p 4 4} where {cmd:indepvar} is the continuous covariate to be placed on the x-axis and across which the average adjusted predictions of the dependent variable will be estimated. 
The range of {cmd: indepvar} is determined by the minimum and maximum value of {cmd: indepvar} for the cases included in the regression model. 
By default the graph includes a note summarizing the coefficient and t-statistic of the plotted variable. 

{p 4 4} B) {bf:Plotting an interaction between two continuous variables.} To plot the average marginal effects (AMEs) of one of the variables of the interactive term across the range of the second variable of the interactive 
term the option {cmd:mar(}{it:varname}{cmd:)} must be specified. Therefore, {cmd:marhis} should be specified as follows: 

{p 4 8} {cmd:. marhis indepvar , mar(}{it:varname}{cmd:)}{p_end} 

{p 4 4} where  {cmd:mar(}{it:varname}{cmd:)} is the term of the interaction for which the average marginal effects will be estimated and plotted across the range of the second term of the 
interaction {cmd:indepvar} which will be placed on the x-axis with a histogram summarizing its distribution in the back of the plot. By default the graph includes a note summarizing the coefficient 
and t-statistic of the plotted interaction. 
 

{p 4 4} C) {bf:Plotting an interaction between a continuous and a categorical variable.} To plot average adjusted predictions of the dependent variable for each of the categories of the categorical term of the 
interaction across the range of the continuous term of the interaction the option {cmd:cate(}{it:varname}{cmd:)} must be specified. Therefore, {cmd:marhis} should be specified as follows: 

{p 4 8} {cmd:. marhis indepvar , cate(}{it:varname}{cmd:)}{p_end} 

{p 4 4} where {cmd:cate(}{it:varname}{cmd:)} is the categorical term of the interaction and {cmd: indepvar} is the continuous term of the interaction. Average adjusted predictions of the dependent variable will be plotted
for each of the cattegories of {cmd:cate(}{it:varname}{cmd:)} across the range of the continous term of the interaction {cmd: indepvar}, which will be placed on the x-axis with a histogram summarizing its distribution in the 
back of the plot. The values of the categorical term of the interaction {cmd:cate(}{it:varname}{cmd:)} must always be labelled before using {cmd:marhis} (labels might be numeric). Only categorical 
variables with 5 or fewer categories are currently supported. 

{title:Options}

{p 4 8} {cmd:mar(}{it:varname}{cmd:)} plot marginal effect of the variable specified. Must be used to plot the results of an interaction between two continuous variables. 

{p 4 8} {cmd:cate(}{it:varname}{cmd:)} defines the categorical term of the interaction to be plotted. Must be used to plot the results of an interaction between a categorical and continuous variable. 

{p 4 8}  {cmd:points(}#{cmd:)} set the number of data points to be estimated by the {cmd:margins} command between the minimum and maximum value of the variable on the x-axis; default level is 15. Larger numbers increase the 
smoothness of the plotted results but increase computation time. 

{p 4 8} {cmd: percent} draw histogram of {cmd: indepvar} as percentages; default is density.  

{p 4 8} {cmd:discrete} specify that {cmd: indepvar} is discrete (only affects rendition of the histogram). 

{p 4 8}  {cmd:level(}#{cmd:)} set confidence interval level; default is level(95). 

{p 4 8} {cmd:label(}#{cmd:)} modify the number of labels (values) displayed on the x-axis between minimum and maximum value of {cmd: indepvar}; default is 4

{p 4 8}  {cmd:summaryno} suppresses the note with the summary of the coefficient of the variable or interactive term included in the graph. 

{p 4 8}  {cmd:confidenceno} suppresses the confidence intervals in the plotted results.

{p 4 8}  {cmd:atmeans} estimate margins at the means of covariates; by default average adjusted predictions or average marginal effects are estimated.


 {title:Examples}
 
{p 4 8} {cmd:. webuse nhanes2.dta}{p_end}

{p 4 4} A) Average adjusted predictions of having high blood pressure across the range of a continuous predictor (height in cm).
 
{p 4 8} {cmd:. logit highbp age weight height}{p_end}
{p 4 8} {cmd:. marhis height}{p_end}

{p 4 4} B) Interaction between two continuous variables (age and height) (dependent variable having high blood pressure). Average marginal effects of age across values of height. 

{p 4 8} {cmd:. logit highbp c.age##c.height weight}{p_end}
{p 4 8} {cmd:. marhis height, mar(age)}{p_end}

{p 4 4} C) Interaction between a continuous (age) and a categorical variable (sex). Average adjusted predictions of having high blood pressure for different categories of sex across values of age. 

{p 4 8} {cmd:. logit highbp c.age##i.sex weight height}{p_end}
{p 4 8} {cmd:. marhis age, cate(sex)}{p_end}


{title:References}

{p 4 6} Berry, W. D., Golder, M., & Milton, D. (2012). Improving tests of theories positing interaction. Journal of Politics, 74(3), 653-671.

{title:Acknowledgments}

{p 4 4} I would like to thank Macarena Ares, Albert Arcarons and Guillem Vidal for their useful comments and suggestions. I would also like to thank the 
statalist users who answered my questions and provided valuable suggestions. I would also like to acknowledge the use of the code to save 
labels in macros proposed by Matt Spittal in statalist.  


{title:Author}

{p 4 6} Enrique Hernández, SPS department, European University Institute. Please report bugs and suggestions to {browse Enrique.Hernandez@EUI.eu}
 







