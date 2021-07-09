{smcl}
{* *! version 2.0 29nov2014}{...} 

{cmd: help blp}
{hline}

{title:Title}

{p2colset 5 12 12 2}{...}
{p2col :{hi:blp} {hline 2}}Berry Levinsohn Pakes random coefficients logit estimator{p_end}
{p2colreset}{...}

{title:Syntax}

{p 4 12 2}
{cmdab: blp}
{it:depvar} [{it:{help varlist}}]{cmd:} [{it:{help if}}]{cmd:} [{it:{help in}}]{cmd:,}
{cmd:endog(}[{it:varlist_endog}]{it:=varlist_inst1}{cmd:)}
{cmd:stochastic(}{it:varname_s1=varlist_s1,varname_s2=varlist_s2,..}{cmd:)}
{cmd:markets(}{it:varname_m}{cmd:)}
[{cmd:optinst(}[{it:varlist_inst2}]{cmd:)}
{cmd:tolin(}{it:#}{cmd:)}
{cmd:tolout(}{it:#}{cmd:)}
{cmd:draws(}{it:#}{cmd:)}
{cmd:burn(}{it:#}{cmd:)}
{cmd:iter(}[{it:#}]{cmd:)}
{cmd:demofile(}{it:filename_d}{cmd:)}
{cmd:initsd(}{it:initvals}{cmd:)}
{cmd:initdemo(}{it:initvals_d}{cmd:)}
{cmd:elast(}{it:varname_e},{it:#},[{it:varname_p}]{cmd:)}
{cmd:robustweight}
{cmd:robust}
{cmd:random}
{cmd:noisily}
{cmd:nocons}]


{title:Description}

{pstd}{cmd:blp} estimates the random parameters logit demand model from product market shares. This uses the GMM-estimator proposed by Berry Levinsohn and Pakes(1995) and 
allows for endogenous prices and consumer heterogeneity in the valuation of product characteristics, that can be explained by variation in demographic variables. To 
reduce the bias and improve both the efficiency and stability of the estimator, {cmd:blp} provides an option to use the Chamberlain(1987) optimal instruments. 

{title:Options for blp}

{phang} 
{opt endog([varlist_endog]=varlist_inst1)} is required and identifies {it:varlist_endog} as any endogenous variables and {it:varlist_inst1} as the instruments 
for {it:varlist_endog} and the parameters in {opt stochastic}
 
{phang}
{opt stochastic(varname_s1=varlist_s1,varname_s2=varlist_s2,..)} is required and identifies {it: varname_s1}, {it: varname_s2},.. as product 
characteristics with random coefficients and {it: varlist_s1,varlist_s2,..} as demographic variables that appear in these equations. Random coefficients can only
be associated with variables that appear in {it: varlist} or {it:varlist_endog}. For a random-constant, it is necessary to generate and include a variable named {it: cons}.

{phang} 
{opt markets(varname_m)} identifies {it:varname_m} as the market variable in the data and in the demographic file {it: filename_d} if used.

{phang}
{opt optinst([varlist_inst2])} estimates the model using Chamberlain(1987) optimal instruments. For models that include endogenous regressors, {it: varlist_inst2} 
contains subsets or functions of {it: varlist_inst1} that appear in the linear (in parameters) conditional expectation of {it: varlist_endog}.

{phang}
{opt tolin(#)} specifies the tolerance level used to define convergence of the contraction mapping algorithm. The default is 10E-15.

{phang}
{opt tolout(#)} specifies the tolerance level used to define convergence of the GMM estimator. The default is 10E-12.

{phang}
{opt draws(#)} specifies the number of Halton draws used to approximate the market share integrals. The default is 200 and the Halton sequence is created from the first 
K-primes, where K denotes the number of stochastic coefficients.  

{phang}
{opt burn(#)} specifies the number of initial elements to drop when creating Halton sequences. The default is 15. This helps to reduce correlation between the sequences.

{phang}
{opt iter([#])} specifies the iterative instead of the two-step GMM estimator. It is available for {opt optinst()} or {opt robustweight} and estimation will continue
until the relative difference between estimates in successive iterations is below {opt tolout()}. Alternatively {it:#} specifies the number of iterations.

{phang}
{opt demofile(filename_d)} identifies {it:filename_d} as the path to the file that contains the random draws of the demographic variables for each market.

{phang}
{opt initsd(initvals)} identifies {it:initvals} as the starting values for the standard deviations of the random coefficients. These must be separated by a comma. The default
values are 0.5. 

{phang}
{opt initdemo(initvals_d)} identifies {it:initvals_d} as starting values for the coefficients on the demographic variables. The order will correspond to {it:varlist_s1,varlist_s2,..} 
and values must be separated by a comma. The default values are 0.5. 

{phang}
{opt elast(varname_e,#,[varname_p])}  provides the matrix of demand elasticities for a 1% increase in variable {it: varname_e}, in market-number {it:#}. These are 
available for {it: varname_s1},{it: varname_s2} etc only. An optional string variable {it: varname_p} can be specified to identify the products.

{phang}
{opt robustweight} specifies a weighting matrix in the GMM-estimator that is optimal when the errors are correlated between products and heteroskedastic across markets. This option cannot
be used when the number of instruments equals the number of parameters, or when specifying {opt optinst()} as the model is exactly identified.

{phang}
{opt robust} computes an estimate of the standard errors that are robust when the errors are correlated between products and heteroskedastic across markets.
The default assumes that the errors are iid.

{phang}
{opt random} specifies that pseudo-random draws be used to approximate the market-share integrals instead of those based on Halton sequences. Following Drukker and Gates(2006) it is 
suggested that this option is selected when the number of stochastic coefficients exceeds 10.

{phang}
{opt noisily} displays the iteration log during estimation. This indicates convergence of the contraction mapping by market and displays the
current values of the heterogeneity parameters and associated analytical gradients. 

{phang}
{opt nocons} estimates the model without the constant term in the mean utility.


{title:Remarks}

{pstd}{cmd:blp} requires the data to be in long form, where each market contains observations on product shares and characteristics. There is no requirement for products to be the same across markets.

{pstd}The number of Halton draws {it: #} in {cmd:draws(}{it:#}{cmd:)} is set to 200 by default, but the user should test the stability of the estimator for larger values. 

{pstd}If demographic variables are used, it is necessary for {it: filename_d} to contain an equal number of draws across markets (in long-form) and with the same market identifier {it: varname_m}. 
This number will override {it: #}. As Nevo(2000) points out, identification of the demographic coefficients requires variation in the distribution of demographic variables across markets.

{pstd}For models that include a random coefficient on the constant, Monte Carlo experiments indicate that it is very difficult to identify the standard deviation of this characteristic, in addition 
to the associated coefficients on the demographic variables.

{pstd}Simulation studies by Reynaert and Verboven (2014) and repeated using {cmd:blp}, report reductions in small-sample bias and improvements in the efficiency of the
GMM-estimator using optimal instruments. Furthermore, optimal instruments help to improve the stability of the estimator (less spikes at zero for the standard deviations of the random coefficients).


{title:Examples}

{title:Example 1: No demographic variables}

{pstd} In this example, consumers can select from J=10 alternatives excluding the outside good. Data is simulated for T=25 markets and utility is determined by a 
constant, a single product characteristic {it: x1} and price {it: p} which is endogenous. The supply side is characterized by perfect competition, where marginal 
costs are a linear function of the product characteristics and three exogenous cost drivers {it: w1},{it: w2} and {it: w3}. Heterogeneity is restricted to
the coefficient on {it: x1} which has a true mean valuation of 2 and a standard deviation of 1. The constant is set to 2 and the coefficient on price is -2.

    {title:Standard instruments}

{pstd} The model is initially estimated by generating the BLP-type instrument set. This contains the exogenous variables, their squares and interactions 
and the sums of the characteristics of other products. Construction of these instruments is set-out below.


{com}{sf}{ul off}
{pstd}{cmd:. use blp_nodemo,clear}{p_end}

{pstd}{cmd:. gen w12=w1^2}{p_end}

{pstd}{cmd:. gen w22=w2^2}{p_end}

{pstd}{cmd:. gen w32=w3^2}{p_end}

{pstd}{cmd:. gen x12=x1^2}{p_end}

{pstd}{cmd:. gen x1w1=x1*w1}{p_end}

{pstd}{cmd:. gen x1w2=x1*w2}{p_end}

{pstd}{cmd:. gen x1w3=x1*w3}{p_end}

{pstd}{cmd:. bysort mkt: egen x1s=sum(x1)}{p_end} 

{pstd}{cmd:. replace x1s=x1s-x1}{p_end}
{txt}(250 real changes made)

{pstd}{cmd:. blp s x1, stochastic(x1) endog(p=w1 w2 w3 w12 w22 w32 x12 x1w1 x1w2 x1w3 x1s) markets(mkt)}{p_end}
{res}{txt}Iteration 0:  f(p) = {res: 13.131515}
Iteration 1:  f(p) = {res: 13.087338}  (backed up)
Iteration 2:  f(p) = {res: 12.942222}
Iteration 3:  f(p) = {res:  12.94162}
Iteration 4:  f(p) = {res: 12.941619}

GMM estimator of BLP-model

GMM weight matrix: unadjusted{col 45}Number of obs {col 70}=  {res}250
{txt}{col 45}Number of markets{col 70}=  {res}25
{txt}{col 45}Number of Halton draws {col 70}=  {res}200
{txt}{hline 13}{c TT}{hline 64}
             {c |}      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
{hline 13}{c +}{hline 64}
{res}Mean utility {txt}{c |}
        cons {c |}  {res}  1.86419   .7076256     2.63   0.008     .4772692     3.25111
          {txt}x1 {c |}  {res} 2.411279   .5984685     4.03   0.000     1.238302    3.584256
           {txt}p {c |}  {res}-2.040571   .0486975   -41.90   0.000    -2.136016   -1.945125
{txt}{hline 13}{c +}{hline 64}
{res}x1           {txt}{c |}
          SD {c |}  {res} .7360524    .485933     1.51   0.130    -.2163588    1.688464
{txt}{hline 13}{c BT}{hline 64}



    {title:Optimal instruments}


{pstd} Prices are a linear function of cost-drivers {it: w1,w2,w3} and product characteristics {it: 1,x1}. Hence to estimate the model using 
optimal instruments, {opt optinst(z1,z2,z3)} is specified where {it: 1,x1} are included by default. 


{pstd}{cmd:. blp s x1, stochastic(x1) endog(p=w1 w2 w3 w12 w22 w32 x12 x1w1 x1w2 x1w3 x1s) markets(mkt) optinst(w1 w2 w3)}{p_end} 
{res}{txt}Iteration 0:  f(p) = {res: 13.131515}
Iteration 1:  f(p) = {res: 13.087338}  (backed up)
Iteration 2:  f(p) = {res: 12.942222}
Iteration 3:  f(p) = {res:  12.94162}
Iteration 4:  f(p) = {res: 12.941619}
{txt:Estimation iteration with optimal instruments: 1}

{txt}Iteration 0:  f(p) = {res: 2.8867191}  (not concave)
Iteration 1:  f(p) = {res: .34409293}
Iteration 2:  f(p) = {res: .00141696}
Iteration 3:  f(p) = {res: 6.520e-07}
Iteration 4:  f(p) = {res: 1.280e-13}
Iteration 5:  f(p) = {res: 3.733e-23}

GMM estimator of BLP-model

Instruments: Chamberlain optimal{col 45}Number of obs {col 70}=  {res}250
{txt}{col 45}Number of markets{col 70}=  {res}25
{txt}{col 45}Number of Halton draws {col 70}=  {res}200
{txt}{hline 13}{c TT}{hline 64}
             {c |}      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
{hline 13}{c +}{hline 64}
{res}Mean utility {txt}{c |}
        cons {c |}  {res} 2.133752   .4500017     4.74   0.000     1.251765    3.015739
          {txt}x1 {c |}  {res} 2.210469   .3285757     6.73   0.000     1.566472    2.854465
           {txt}p {c |}  {res} -2.05896    .044855   -45.90   0.000    -2.146874   -1.971046
{txt}{hline 13}{c +}{hline 64}
{res}x1           {txt}{c |}
          SD {c |}  {res} .9145327   .1882391     4.86   0.000     .5455907    1.283475
{txt}{hline 13}{c BT}{hline 64}


{pstd}The parameter estimates are now closer to the true values and with smaller standard errors compared with those estimated using the sub-optimal set.{p_end}


{title:Example 2: Demographic Data}

{pstd} This example extends the previous model to include a random coefficient on price {it: p}, with a standard deviation of 1 and two demographic variables 
{it: d1,d2} in the coefficient equation for {it: x1}. The marginal effects of {it: d1} and {it: d2} are both 1 and samples are drawn from independent normal
distributions. To permit parameter identification, the mean and variance are allowed to differ across markets. File {it: demodata.dta} contains 500 draws (per market)
selected at random from the simulated population of individuals used to construct the product shares. The model is estimated with optimal instruments and price
elasticities are reported for market {it: 1} by specifying {opt elast(p,1,product)}, where {it: product} is a string variable that contains product names to label the elasticity matrix.


{com}{sf}{ul off}
{pstd}{cmd:. use blp_demo,clear}{p_end}

{pstd}{cmd:. gen w12=w1^2}{p_end}

{pstd}{cmd:. gen w22=w2^2}{p_end}

{pstd}{cmd:. gen w32=w3^2}{p_end}

{pstd}{cmd:. gen x12=x1^2}{p_end}

{pstd}{cmd:. gen x1w1=x1*w1}{p_end}

{pstd}{cmd:. gen x1w2=x1*w2}{p_end}

{pstd}{cmd:. gen x1w3=x1*w3}{p_end}

{pstd}{cmd:. bysort mkt: egen x1s=sum(x1)}{p_end} 

{pstd}{cmd:. replace x1s=x1s-x1}{p_end}
{txt}(250 real changes made)

{com}{sf}{ul off}
{pstd}{cmd:. blp s x1, stochastic(x1=d1 d2,p) endog(p=w1 w2 w3 w12 w22 w32 x12 x1w1 x1w2 x1w3 x1s) markets(mkt) optinst(w1 w2 w3) demofile(demodata) initdemo(1,1) initsd(1,1) elast(p,1,product)}{p_end}

{res}{txt}number of draws set to number in demographic data file
draws per market is:  500
Initial values for included demographic-variables in stochastic coefficient equations

   d1  d2
x1  {res} 1   1
{txt} p  {res} .   .
{txt}Do you wish to continue?: 1=yes, 0=no?{com}. 1
{txt}estimation continuing
{res}{txt}Iteration 0:  f(p) = {res: 18.345114}  (not concave)
Iteration 1:  f(p) = {res: 11.518583}
Iteration 2:  f(p) = {res: 10.731243}
Iteration 3:  f(p) = {res: 10.709159}
Iteration 4:  f(p) = {res: 10.708926}
Iteration 5:  f(p) = {res: 10.708926}
{txt:Estimation iteration with optimal instruments: 1}
Iteration 0:  f(p) = {res:  1.325197}
Iteration 1:  f(p) = {res: .00047773}
Iteration 2:  f(p) = {res: 3.454e-09}
Iteration 3:  f(p) = {res: 4.583e-18}

GMM estimator of BLP-model

Instruments: Chamberlain optimal{col 45}Number of obs {col 70}=  {res}500
{txt}{col 45}Number of markets{col 70}=  {res}50
{txt}{col 45}Number of Halton draws {col 70}=  {res}500
{txt}{hline 13}{c TT}{hline 64}
             {c |}      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
{hline 13}{c +}{hline 64}
{res}Mean utility {txt}{c |}
        cons {c |}  {res} 1.562526   .4870916     3.21   0.001     .6078444    2.517208
          {txt}x1 {c |}  {res} 2.144829   .1669901    12.84   0.000     1.817535    2.472124
           {txt}p {c |}  {res}-1.938477   .1165748   -16.63   0.000     -2.16696   -1.709995
{txt}{hline 13}{c +}{hline 64}
{res}x1           {txt}{c |}
          d1 {c |}  {res} .9794679   .0728124    13.45   0.000     .8367581    1.122178
          {txt}d2 {c |}  {res} .9406059   .0740145    12.71   0.000     .7955401    1.085672
          {txt}SD {c |}  {res} .9448503    .204845     4.61   0.000     .5433616    1.346339
{txt}{hline 13}{c +}{hline 64}
{res}p            {txt}{c |}
          SD {c |}  {res} .9726345   .0751903    12.94   0.000     .8252641    1.120005
{txt}{hline 13}{c BT}{hline 64}




{pstd}The estimated marginal effects of {it: d1} and {it: d2} on the {it: x1} coefficient are approximately 0.98 and 0.94. To display the price elasticity matrix type:{p_end}.

{pstd}{cmd:. matrix list {opt e(elast)}}{p_end}

({it: only products 1 - 3 displayed})

{txt}e(elast)[10,10]
{txt}                   1% rise in p:
                           product1       product2       product3            
% change in: product1  {res}   -3.1977628      .65508214      .07305337      
{txt}             product2  {res}    1.1187173     -4.2095821       .0890736      
{txt}             product3  {res}    1.029381      .73495422     -4.7211944    
{txt}
 

{pstd} The {it: ij}-elements of the elasticity matrix represent (approximately) the %-change in the demand
for product {it: i}, following a 1% increase in the price of product {it: j}.{p_end}



{title:Author}
{txt}
{pstd}David Vincent{p_end}
{pstd}Deloitte Economic Consulting LLP{p_end}
{pstd}Athene Place, 66 Shoe Lane, London, EC4A 3BQ{p_end}
{pstd}davivincent@deloitte.co.uk{p_end}



{title:References} 

{phang}
Berry, S., J. Levinsohn, and A. Pakes, (1995), “Automobile Prices in Market Equilibrium,” {it: Econometrica}, 63, 4, 841-90.

{phang} 
Nevo, Aviv, (2000), “A Practitioner's Guide to Estimation of Random-Coefficients Logit Models of Demand,” {it: Journal of Economics & Management Strategy}.

{phang} 
Reynaert, M., and F. Verboven, (2014), “Improving the performance of random coefficients demand models: the role of optimal instruments”, {it: Journal of Econometrics}, 179, 83-98{p_end}
