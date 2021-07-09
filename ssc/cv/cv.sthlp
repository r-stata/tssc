{smcl}
{* *! version 1.0 21nov2014}
{cmd:help cv}
{hline}

{title:Title}

{p2colset 5 10 15 20}{...}
{p2col :{hi:cv }{hline 1}}Coefficient of variation{p_end}
{p2colreset}{...}


{title:Description}

Coefficient of variation (CV) is the ratio of the standard deviation of residuals 
(Root MSE) to the sample mean of the dependent variable (Y-bar). The coefficient 
is then multiplied by 100 to express it in terms of a percentage. 

CV = (Root MSE/Y-bar) * 100  

CV can sometimes be used to judge the fit of a regression model as it assesses 
the variability around the regression line relative to the mean of the dependent
variable. The lower the CV, the closer the data points to the regression line. 
There is however no definite cutoff-values for CV to decide whether or not a model 
is a good fit. However, as a liberal guideline, I suggest that CV less than 33.3% 
be seen indicative of an acceptable model fit.        

CV is indeed a more useful measure to compare the model fit of alternative regression 
models. Although we still can use Root MSE to compare models, the advantage of CV 
is that it expresses the variability around the regresion line in unitless values.
Thus, we can, by examining CV, compare any two/more regression models. The model with 
the lowest CV will be favoured.

CV should not be used when the dependent variable includes negative values or has 
a mean of zero. 


KW: coefficient of variation 
KW: model fit


{title:Examples}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "reg price mpg foreign weight": . reg price mpg foreign weight}{p_end}
{phang}{stata "cv": . cv}{p_end}
 
{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "reg price mpg foreign weight length ": . reg price mpg foreign weight length}{p_end}
{phang}{stata "cv": . cv}{p_end} 
 
{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "gen price2=price-5000": . gen price2=price-5000}{p_end}
{phang}{stata "reg price2 mpg foreign weight length ": . reg price2 mpg foreign weight length}{p_end}
{phang}{stata "cv": . cv}{p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no

{title:Reference}
Dielman, T. E. (2005). Applied Regression Analysis - A Second Course in Business and 
Economic Statistics (4 ed.). Mason: Cengage.



  