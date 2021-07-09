{smcl}
{* 1.3.0 MLB 04Jun2012}{...}
{* 1.2.0 MLB 19Dec2011}{...}
{* 1.0.1 MLB 21Nov2011}{...}
{* 1.0.0 MLB 13Nov2011}{...}
help for {hi:margdistfit}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi: margdistfit} {hline 2}}Post-estimation command that compares 
the observed and theoretical marginal distributions.{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:margdistfit} {cmd:,} 
[
{c -(} {opt pp} | {opt qq} | {opt cumul} | 
 {opt hangr:oot}[{cmd:(}{help hangroot:hangroot_options}{cmd:)}] {c )-}
{opt sims(#)} {opt nopa:rsamp}
{cmd:obsopts(}{help twoway_scatter:scatter_options}{cmd:)}
{cmd:refopts(}{help twoway_line:line_options}{cmd:)}
{cmd:simopts(}{help twoway_line:line_options}{cmd:)}
{opt nosquare}
{opt e(#)}
]


{title:Description}

{pstd}
{cmd:margdistfit} is a post-estimation command for checking how well 
distributional assumptions of a regression model fit to the data. It does so
by comparing the marginal distribution implied by the regression model to the
distribution of the dependent variable. This comparison is done through either
a probability-probabilty plot, a quantile-quantile plot, a hanging rootogram, or a 
plot of the two cumulative distribution functions. 

{pstd}
The key concept in this command is the marginal distribution. Regression models 
assume a distribution for the dependent variable, and this distribution can be 
described in terms of a small number of parameters: e.g. the mean and the standard
deviation in case of the normal/Gaussian distribution. One or more of these 
distribution parameters, typically the mean, is allowed to differ from observation 
to observation depending on the values of the explanatory variables. As a 
consequence, the distribution of the explained variable implied by the model is a 
mixture distribution such that each observation has its own parameters. This is the 
marginal distribution.

{pstd}
To give an indication of how much deviation from the theoretical distribution is 
still legitimate, the graph will also show the distribution of several (by default 
20) simulated variables under the assumption that the regression model is true. By 
default, the simulations include both uncertainty due to uncertainty about the 
parameter estimates and uncertainty due to the fact that they are random draws from
a distribution. This is achieved by creating the simulated variables in two steps: 
first the parameters are drawn from their sampling distribution, and than the 
simulated variable is drawn given those parameters.

{pstd}
{cmd:margdistfit} may be used after estimating a model with {help regress}, {help poisson},
{help zip}, {help nbreg}, {help gnbreg}, {help zinb}, or {help betafit} (the latter is
available from {help ssc}).


{title:Options}

{phang}
{opt pp} specifies that a probability-probability plot is to be displayed. This 
graph is best for looking at the comparison of the theoretical and observed 
distribution in the middle of the distribution. It may not
be combined with {opt qq}, {opt cumul}, or {opt hangroot}.

{phang}
{opt qq} specifies that a quantile-quantile plot is to be displayed. This graph
is best for looking at the comparison of the theoretical and observed distribution
in the tails of the distribution. This is the default. It may not be combined with {opt pp}, 
{opt cumul}, or {opt hangroot}.

{phang}
{opt cumul} specifies that the observed and theoretical cumulative density functions
are to be graphed. It may not be combined with {opt pp}, {opt cumul}, or {opt hangroot}.   

{phang}
{opt hangr:oot}[{cmd:(}{help hangroot:hangroot_options}{cmd:)}] specifies that a 
hanging rootogram is used to compare the observed and theoretical distributions. This
requires that the {cmd:hangroot} package is installed, which is available from {help ssc}.
It may not be combined with {opt pp}, {opt qq}, or {opt cumul}.

{phang}
{opt sims(#)} specifies the number of simulated variables, the default is 20.

{phang}
{opt nopa:rsamp} specifies that the simulated variables should be drawn from the 
distribution with parameters based on the point estimates of the model and avoid
drawing the parameters from the sampling distribution.

{phang}
{cmd:obsopts(}{help twoway_scatter:scatter_options}{cmd:)} options governing how the
distribution of the observed variable looks.

{phang}
{cmd:refopts(}{help twoway_line:line_options}{cmd:)} options governing how the 
reference line looks.

{phang}
{cmd:simopts(}{help twoway_line:line_options}{cmd:)} options governing how the 
distributions of the simulated variable look.

{phang}
{opt nosquare} specifies that the graph is not forced to be square. By default the 
probability-probability and quantile-quantile plots are forced to be square as a 
perfect fit is represented by the 45 degree line. By forcing the graph to be square
the 45 degree line truely has an angle of 45 degrees. This option is not allowed
in combination with {opt cumul} or {opt hangroot}.

{phang}
{opt e(#)} specifies the maximal error used when approximating the quantile function
or cumulative density function. The quantile function is computed using the algorithm
discussed in (hoermann and leydold 2003). A similar algorithm is used to compute the
cumulative density function. The latter is strictly speaking not necessary, but it 
significantly speeds up the computation in medium to large datasets. With {opt pp} or
{opt cumul} it may be a number between 0 and 1e-3. The cumulative density function will be
directly computed instead of approximated when a number less than 1e-12 is specified.
With {opt qq} it may be a number between 1e-12 and 1e-3. The default is 
min(1e-6,10^-ceil(log10(N))), where N is the sample size.


{title:Examples}

{pstd}
A well fitting model:

{cmd}{...}
    sysuse nlsw88, clear
    gen lnw = ln(wage)
    reg lnw grade ttl_exp tenure union
    margdistfit, qq
{txt}{...}
{p 4 4 2}({stata "margdistfit_ex 1":click to run}){p_end}

{pstd}
A not so well fitting model. Note that linear regression is
typically quite robust against deviations from this assumption. However,
knowing that such deviations exist in your data and substantively 
understanding why they are there can add a lot "flesh" to the "bare bones"
of your model.

{cmd}{...}
    sysuse auto, clear
    reg price mpg foreign
    margdistfit, pp
{txt}{...}
{p 4 4 2}({stata "margdistfit_ex 2":click to run}){p_end}

{pstd}
An example created to illustrate that the marginal distribution
can look very different from what one may expect. I use {cmd:regress}, 
so I assume a normal distribution where the mean can change from 
observation to observation depending on the value of x. In this case 
the data was created such that we should see a distribution of y that 
has consists of two humps, one at -2 and the other at 2, which is 
indeed the case. 

{cmd}{...}
    preserve
    set seed 12345
    drop _all
    set obs 500
    gen x = runiform() < .5
    gen y = -2 + 4*x + rnormal()
    regress y x
    margdistfit, hangroot(jitter(5))
    restore
{txt}{...}
{p 4 4 2}({stata "margdistfit_ex 3":click to run}){p_end}

{pstd}
An example that can be used to compare the fit of several count models.{p_end}

{pstd}
The strange pattern in the last graph is due to the large sampling variability
in the inflation parameter, and by default the parameters are for each simulation
drawn from the sampling distribution. That way some of the samples are drawn from a 
distribution where the probability of a degenerate zero is 1 - that is, the
distribution reduces to a spike at 0 - while for the other samples that 
probability is 0 - that is, the distribution reduces to a negative binomial. This 
means that in essence the {cmd:zinb} model is not appropriate for this data.
{p_end}

{cmd}{...}
    preserve
    use http://www.stata-press.com/data/lf2/couart2,clear
    mkspline ment1 20 ment2 = ment
	  
    // this is just to ensure that graph names do not conflict
    // with any graph name you have open
    tempname poisson zip nb zinb
		
    poisson art fem mar kid5 phd ment1 ment2
    margdistfit, hangroot(susp notheor jitter(2)) title(poisson) name(`poisson')
		
    zip art fem mar kid5 phd ment1 ment2, inflate(_cons)
    margdistfit, hangroot(susp notheor jitter(2)) title(zip) name(`zip')
	  
    nbreg art fem mar kid5 phd ment1 ment2
    margdistfit, hangroot(susp notheor jitter(2)) title(nbreg) name(`nb')
		
    zinb art fem mar kid5 phd ment1 ment2, inflate(_cons)
    margdistfit, hangroot(susp notheor jitter(2)) title(zinb) name(`zinb')
		
    restore
{txt}{...}
{p 4 4 2}({stata "margdistfit_ex 4":click to run}){p_end}


{title:Author}

{p 4 4}
Maarten L. Buis{break}
Universitaet Tuebingen{break}
Institut fuer Soziologie{break}
maarten.buis@uni-tuebingen.de
{p_end}


{title:References}

{phang}
Hoermann, Wolfgang and Leydold, Josef. (2003). Continuous random 
variate generation by fast numerical inversion. 
{it:ACM Transactions on Modeling and Computer Simulation}, {cmd:13}(4): 347--362.


{title:Acknowledgement}
{pstd}
Garry Anderson, David Ashcraft, Ronan Conroy, Nick Cox and Austin Nichols (in alphabetical 
order) made several useful comments.


{title:Also see}

{psee}
Online: {helpb pnorm}, {helpb qnorm}

{psee}
If installed: {helpb hangroot}, {helpb qplot}, {helpb pbeta}, {helpb qbeta} 
{p_end}
