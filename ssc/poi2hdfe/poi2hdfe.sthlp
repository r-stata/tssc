
{smcl}
{.-}
help for {cmd:poi2hdfe} {right:()}
{.-}
 
{title:Title}

poi2hdfe - Estimates a Poisson Regression Model with two high dimensional fixed effects.

{title:Syntax}

{p 8 15}
{cmd:poi2hdfe} {it:{help depvar}} [{it:{help indepvar}}] [{help if}] [{help in}] , {cmd:id1(}{it:{help varname}}{cmd:)} {cmd:id2(}{it:{help varname}}{cmd:)}
  [{it:options}]

{p}

{title:Description}

{p} 
This command allows for estimation of a Poisson regression model with two high 
dimensional fixed effects. The program requires "reghdfe" (by Sergio Correia) as it uses 
iteratively reweighted least squares (IRLS) to implement the estimation. Estimates are identical to
the maximum likelihood results. By default it calculates robust standard errors but it allows for clustered
standard errors. Estimation is much faster than in the older version. 

{title:Options}

{p 0 4}{cmd:tol1}{cmd:(}{it:float}{cmd:)} Specify the convergence criterion for estimation 
of the coefficients. Default is 1.000e-08.

{p 0 4}{cmd:tol2}{cmd:(}{it:float}{cmd:)} Specify the convergence criterion for intermediary {help reghdfe} estimation
. Default is 1.000e-08.

{p 0 4} {cmd:cluster(}{it:varname}{cmd:)} computes clustered standard errors.

{p 0 4} {cmd:fe1(}{it:new varname}{cmd:)} {cmd:fe2(}{it:new varname}{cmd:)}:
stores the estimates of the two fixed effects.

{p 0 4} {cmd:sample(}{it:new varname}{cmd:)} create an indicator variable for the sample used
for the estimation.

{p 0 4}{cmdab:verb:ose} gives more information during estimation.

{title:Examples}

Example 1:
Estimates a model with two high dimensional fixed effects.
Produces the same results as "poisson y x1 x2 i.id1 i.id2, robust" 

{p 8 16}{inp:. poi2hdfe y x1 x2, id1(id1) id2(id2)}{p_end}

Example2:
Estimates a model with two high dimensional fixed effects and stores the estimates
of the fixed effects in the variables ff1 and ff2.

{p 8 16}{inp:. poi2hdfe y x1 x2, id1(id1) id2(id2) fe1(ff1) fe2(ff2)}{p_end}

{title:More info}

To use this command you must previously install the {help reghdfe} command
by Sergio Correia. {help poi2hdfe} is simply a wrapper around {help reghdfe} and
could be easily modified to take advantage of the fuller capacities of {help reghdfe}.
The estimation technique is IRLS which is fast and produces the same results as maximum-likelihood.
To improve the speed of convergence you can decrease the tolerance levels - this will 
affect the precision of the estimates but will speed up computations.

{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 

{title:Acknowledgements}
This program takes advantage of the excellent package "reghdfe" by Sergio Correia. It also uses the "fastsum" routine created by
the same author.
{p}

{title:Author}

{p}
Paulo Guimaraes, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:pguimaraes2001@gmail.com":pguimaraes2001@gmail.com}

Your comments are welcome!

{title:References}

Paulo Guimaraes and Pedro Portugal. "A Simple Feasible Alternative Procedure to Estimate Models with 
High-Dimensional Fixed Effects", Stata Journal, 10(4), 628-649, 2010.

Octavio Figueiredo, Paulo Guimaraes and, Douglas Woodward "Industry Concentration, Distance Decay, and
Knowledge Spillovers: Following the Patent Paper Trail," Journal of Urban Economics, 89, 21-31, 2015.

Sergio Correia, 2014.
"REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects," Statistical Software Components
S457874, Boston College Department of Economics, revised 06 Aug 2016.

If you use this command in your research please cite the above papers.

