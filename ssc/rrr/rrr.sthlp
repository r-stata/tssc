{smcl}
{* 	*! version 1.0  3Dec2020}{...}
{cmd:help rrr} 
{hline}

{title:Title}

{p2colset 5 12 16 2}{...}
{p2col :{hi:rrr} {hline 2}}Reduced rank regression{p_end}
{p2colreset}{...}


{title:Syntax}
{p 8 16 2}{cmd:rrr} {it:depvars} {ifin}, x({it:indepvars}) [{cmdab:r:ank(#)} {cmdab:no:std} {cmdab:save:var} {cmdab:load:ings}]

{p 4 4 2}{it:depvars} refers to the list of dependent variables (at lease two variables);
{it:indepvars} refers to the list of independent variables (at least two variables). Put a space between two variable names.


{title:Description}

{pstd}
{cmd:rrr} executes the reduced rank regression, a multivariate linear regression with the function of dimension reduction. 
This command is based on the PCA of the OLS predicted vaules for dependent variables. 
It generates the retained factor scores (i.e., linear combinations of independent variables) from reduced rank regression and saves them as new variables in the dataset.


{title:Options}

{phang}
{cmdab:r:ank(#)} specifies the retained number of factors (i.e., linear combinations of independent variables) from reduced rank regression. 
The number should be a non-zero integer no larger than the number of dependent variables. 
The default value is the number of dependent variables.

{phang}
{cmdab:no:std} specifies that during the program execution, the raw {it:depvars} and {it:indepvars} do not need to be standardised (i.e., centering and scaling) before fitting the model.
With this option, no standardised variables will be generated and saved.

{phang}
{cmdab:save:var} specifies that the standardised variables (where appropriate) and predicted value of dependent variables (by OLS) generated during the program execution are saved as new variables.

{phang}
{cmdab:load:ings} specifies that the factor loadings (i.e., coefficients of (standardised) independent variables) of each retained factor are displayed.


{title:Remarks}

{pstd}
The factor scores ({it:f1-fn}) generated with this {cmd:rrr} command are equivalent to those ({it:xscores}) of the PLS procedure in SAS (proc pls data=data method=RRR); f(i)=k*xscore(i), where k is a constant. 
Similarly, the factor loadings generated with the {cmdab:load:ings} option are equivalent to the SAS output (Model Effect Weights).
The proportions of variations of {it:depvars} and {it:indepvars} explained by each factor score are the same as the SAS output.


{title:Example: Generating dietary patterns.}

{pstd}Extract one dietary pattern of food intake for the prediction of systolic and diastolic blood pressure{p_end}
{tab}{cmd:. rrr sbp dbp, x(rice wheat meat eggs fresh_veg fresh_fruit) rank(1)}


{title:Author}

{pstd}
Bang Zheng, Department of Epidemiology & Biostatistics, School of Public Health, Peking University, China; School of Public Health, Imperial College London, UK.
(zhengbang@bjmu.edu.cn)

{pstd}
Canqing Yu, Department of Epidemiology & Biostatistics, School of Public Health, Peking University, China.
(yucanqing@pku.edu.cn)


{title:References}

{phang}
Izenman A. Reduced-rank regression for the multivariate linear model. Journal of Multivariate Analysis,1975,5:248-264.

{phang}
van der Merwe A, Zidek J. Multivariate regression analysis and canonical variates. The Canadian Journal of Statistics,1980,8:27-39.

{phang}
Hoffmann K, Schulze MB, Schienkiewitz A, Nothlings U, Boeing H. Application of a new statistical method to derive dietary patterns in nutritional epidemiology. American Journal of Epidemiology,2004,159(10):935-944.

{phang}
Anderson TW, Rubin H. Estimation of the parameters of a single equation in a complete system of stochastic equations. Annals of Mathematical Statistics,1949,20:46-63.

{phang}
Anderson TW. Estimating linear restrictions on regression coefficients for multivariate normal distributions. Annals of Mathematical Statistics,1951,22:327-351.

{phang}
SAS/STAT 13.1 User's Guide: The PLS Procedure. {browse "https://support.sas.com/documentation/onlinedoc/stat/131/pls.pdf"}
