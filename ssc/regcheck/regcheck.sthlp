{smcl}
{* *! version 1.0 01Dec2014}
{cmd:help regcheck}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:regcheck }{hline 1}}examines regression assumptions{p_end}
{p2colreset}{...}


{title:Description}

1) The assumption of homoskedasticity is examined using the Breusch-Pagan test 
(Gujarati, 2012, pp. 86-87). Since the Ho:homoskedastic residuals, p-value < 0.05 
would show that there is a heterokedasticity problem in the model. 

2) The assumption of no severe multicollinearity is examined using VIF (Variance
Inflation Factor)-values. A VIF value above 5.0 is used as a sign of severe 
multicollinearity in the model (Studenmund, 2006, p.271).

3) The assumption of normally-distributed residuals is examined using Shapiro-Wilk
W test. Since the Ho:residuals are normmally distributed, p-value < 0.01 would
indicate that residuals are not normally distributed. The reason why I propose
0.01 as a cutoff is that in almost every case, we reject the Ho at 0.05. Further,
Shapiro-Wilk W test is, like any other, sensitive to large sample sizes. I still
suggest that one additionnaly examines the residual plots.   

4) The assumption of correctly specified model is examined using the linktest (Stata
Manual, pp. 1041-1044). A statistically significant _hatsq (p < 0.05) would show a 
specification problem.

5) The assumption of appropriate functional form is examined using Ramsey's regression
specification error test (RESET) (Wooldridge, pp. 303-305). Since the Ho: appropriate 
functional form, p-value < 0.05 would indicate a functional form problem.

6) Influence is based on both leverage and the extent to which the observation is
an outlier. Cook's distance (D) is used to locate any influential observations. An
observation with D > 1 would often be considered  an influential case and should thus be 
removed from the analysis (Pardoe, 2006, p. 171).

KW: assumptions 
KW: diagnostics 
KW: regression

{title:Examples}

{phang}{stata "webuse nlsw88, clear": . webuse nlsw88, clear}{p_end}
{phang}{stata "reg wage hours ttl_exp age tenure": . reg wage hours ttl_exp age tenure }{p_end}
{phang}{stata "regcheck": . regcheck}{p_end}
 
{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "reg price mpg foreign weight length ": . reg price mpg foreign weight length}{p_end}
{phang}{stata "regcheck": . regcheck}{p_end} 
 

{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}

Gujarati, D. (2012). Econometrics by Example. Basingstoke/UK: Palgrave Macmillan.
Pardoe, I. (2006). Applied Regression Modeling - A Business Approach. New Jersey: Wiley.
Studenmund, A. H. (2006). Using Econometrics - A Practical Guide (5 ed.). London: Pearson.
Wooldridge, J. M. (2009). Introductory Econometrics - A Modern Approach (4 ed.). Canada: South-Western Cengage.
Stata Manual

  