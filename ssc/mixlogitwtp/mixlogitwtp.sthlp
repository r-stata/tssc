{smcl}
{* 25Jun2015}{...}
{cmd:help mixlogitwtp}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:mixlogitwtp} {hline 2}}Mixed logit model in WTP space{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:mixlogitwtp}
{depvar}
[{indepvars}] {ifin} {cmd:,}
{opt gr:oup(varname)}
{opt price(varname)}
[{opt rand(varlist)}
 {opt id(varname)}
 {opt ln(#)}
 {opt corr}
 {opt nrep(#)}
 {opt burn(#)}
 {opt l:evel(#)}
 {opt const:raints(numlist)}
 {opt vce(vcetype)}
 {it:maximize_options}]


{p 8 15 2}
{cmd:mixlpred}
{newvar} {ifin}
[{cmd:,} {opt nrep(#)} {opt burn(#)}]


{p 8 15 2}
{cmd:mixlcov}
[{cmd:,}
{opt sd}]


{p 8 15 2}
{cmd:mixlbeta}
{varlist} {ifin}
{cmd:,} {opt sav:ing(filename)} [{opt replace} {opt nrep(#)} {opt burn(#)}]


{title:Description}

{pstd}
{cmd:mixlogitwtp} fits mixed logit models in willingness to pay (WTP) space by using maximum simulated 
likelihood (Train and Weeks, 2005; Scarpa et al., 2008; Hole and Kolstad, 2012). The command is based on 
{cmd:mixlogit} (Hole, 2007).

{pstd}
All of the {cmd:mixlogit} postestimation commands are available after {cmd:mixlogitwtp}:

{pstd}
{cmd:mixlpred} calculates predicted probabilities. The predictions are available
both in and out of sample; type {cmd:mixlpred} ... {cmd:if e(sample)} ... if
predictions are wanted for the estimation sample only.

{pstd}
{cmd:mixlcov} calculates the elements in the coefficient covariance matrix along
with their standard errors. This command is relevant only when the coefficients
are specified to be correlated; see the {opt corr} option below. {cmd:mixlcov} is
a wrapper for {cmd:nlcom} (see {manhelp nlcom R}).

{pstd}
{cmd:mixlbeta} calculates individual-level parameters corresponding to the variables in
the specified {it:varlist} using the method proposed by Revelt and Train (2000)
(see also Train, 2009, ch. 11). The individual-level parameters are stored in a data file
specified by the user. As with  {cmd:mixlpred} the predictions are available both in and
out of sample; type {cmd:mixlbeta} ... {cmd:if e(sample)} ... if predictions are wanted
for the estimation sample only.


{title:Options for mixlogitwtp}

{phang}
{opth group(varname)} is required and specifies a numeric identifier variable
for the choice occasions.

{phang}
{opth price(varname)} is required and specifies the price variable, or more generally
the variable whose coefficient is the denominator in the WTP expression. The coefficient 
on the price variable is assumed to be lognormally distributed. Since this implies that
the price coefficient is positive, the price variable must be multiplied by -1 before entering 
the model (see the examples below). Train and Weeks (2005) show that the price coefficient 
in WTP space models incorporates any differences in scale across respondents.

{phang}
{opth rand(varlist)} specifies the independent variables whose WTP coefficients 
are random. The random coefficients can be specified to be normally or lognormally 
distributed (see the {opt ln()} option).  The variables immediately following the 
dependent variable in the syntax are specified to have fixed WTP coefficients 
(see the examples below).

{phang}
{opth id(varname)} specifies a numeric identifier variable for the decision
makers.  This option should be specified only when each individual performs
several choices; i.e., the dataset is a panel.

{phang}
{opt ln(#)} specifies that the last {it:#} variables in {opt rand()} have
lognormally rather than normally distributed WTP coefficients.  The default is
{cmd:ln(0)}.

{phang}
{opt corr} specifies that the random coefficients are correlated. The default
is that they are independent. The {cmd:mixlcov} command can be used postestimation 
to obtain the elements in the variance-covariance matrix of the correlated coefficients
along with their standard errors. 

{phang}
{opt nrep(#)} specifies the number of draws used for the simulation. The default is {cmd:nrep(50)}.
It is recommended to run the command several times with an increasing number of draws in each run 
until the estimates stabilise. See Gu et al. (2013) for a discussion of computational issues in the 
context of the {cmd:gmnl} command, most of which are also relevant for {cmd:mixlogitwtp}. 

{phang}
{opt burn(#)} specifies the number of initial sequence elements to drop when
creating the Halton sequences. The default is {cmd:burn(15)}.   

{phang}
{opt level(#)}; see {help estimation options}.

{phang}
{opth constraints(numlist)}; see {help estimation options}.

{phang}
{opth vce(vcetype)}; {it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, or {opt opg}.

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt from(init_specs)}; see {help maximize}.


{title:Options for mixlpred}

{phang}
{opt nrep(#)} specifies the number of draws used for the simulation.
The default is {cmd:nrep(50)}.

{phang}
{opt burn(#)} specifies the number of initial sequence elements to drop when
creating the Halton sequences. The default is {cmd:burn(15)}. 


{title:Option for mixlcov}

{phang}
{opt sd} reports the standard deviations of the correlated coefficients instead
of the covariance matrix.


{title:Options for gmnlbeta}

{phang}
{opt sav:ing(filename)} save individual-level parameters to {it:filename}.

{phang}
{opt replace} overwrite {it:filename}.

{phang}
{opt nrep(#)} specifies the number of draws used for the simulation.
The default is {cmd:nrep(50)}.

{phang}
{opt burn(#)} specifies the number of initial sequence elements to drop when
creating the Halton sequences. The default is {cmd:burn(15)}.


{title:Examples}

{pstd}
The following examples use traindata.dta, which is described in Hole (2007).

{pstd}
{cmd:Example 1:} Fixed WTP coefficients for {cmd:contract},  {cmd:local} and  {cmd:wknown}, normally
distributed WTP coeficients for {cmd:tod} and {cmd:seasonal}.

{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/t/traindata.dta}{p_end}

{phang2}{cmd:. gen mprice = -price}{p_end}

{phang2}{cmd:. mixlogitwtp y contract local wknown, group(gid) id(pid) price(mprice) rand(tod seasonal) nrep(500)}{p_end}

{pstd}
Among other things the results show that the estimated WTP for a well-known company is 1.73 (cents per kilowatt-hour) and 
the mean WTP to avoid seasonal rates is 9.97 with an SD of 2.45.

{pstd}
As described above the price coefficient is assumed to have a log-normally distributed coefficient. The reported
estimates are the mean and SD for the log of the price coefficient. The mean and SD of the price coefficient
itself can be calculated using {cmd:nlcom} - see e.g. Hole (2007, p. 395) for the relevant formulas:

{phang2}{cmd:. nlcom (Mean_price: -exp([Mean]mprice + 0.5*[SD]mprice^2))}{p_end}
{phang2}{cmd:. nlcom (SD_price: exp([Mean]mprice + 0.5*[SD]mprice^2) * sqrt(exp([SD]mprice^2)-1))}{p_end}

{pstd}
Note that the mean has been multiplied by -1 to undo the sign change introduced in the estimation process.

{pstd}
{cmd:Example 2:} Normally distributed WTP coefficients for {cmd:contract},  {cmd:local} and  {cmd:wknown}, lognormally
distributed WTP coeficients for {cmd:tod} and {cmd:seasonal}.

{pstd}
Specifying a coefficient to be lognormally distributed implies that WTP is positive for all individuals, but negative 
WTPs can be accommodated by entering the attribute multiplied by -1 in the model:

{phang2}{cmd:. gen mtod = -tod}{p_end}

{phang2}{cmd:. gen mseasonal = -seasonal}{p_end}

{phang2}{cmd:. mixlogitwtp y, group(gid) id(pid) price(mprice) rand(contract local wknown mtod mseasonal) ln(2) nrep(500)}{p_end}

{pstd}
The reported mean and SD estimates for {cmd:tod} and {cmd:seasonal} are the mean and SD for the log of the WTP coefficients. 
The mean and SD of the WTP coefficients themselves can be calculated using {cmd:nlcom}, e.g.:

{phang2}{cmd:. nlcom (Mean_WTP_tod: -exp([Mean]mtod + 0.5*[SD]mtod^2))}{p_end}

{phang2}{cmd:. nlcom (SD_WTP_tod: exp([Mean]mtod + 0.5*[SD]mtod^2) * sqrt(exp([SD]mtod^2)-1))}{p_end}

{pstd}
Note that the mean has been multiplied by -1 to undo the sign change introduced in the estimation process.

{pstd}
{cmd:Example 3:} As example 1 but allowing the WTP coefficients for {cmd:tod} and {cmd:seasonal} to be correlated with
each other and with the price coefficient.

{phang2}{cmd:. mixlogitwtp y contract local wknown, group(gid) id(pid) price(mprice) rand(tod seasonal) nrep(500) corr}{p_end}

{pstd}
The final 6 coefficients are the estimated elements of the lower-triangular matrix L, where the covariance matrix for
the random coefficients is given by V = LL'.  The elements in the V matrix along with their standard errors can be obtained 
using {cmd:mixlcov}. 

{title:Note}

{pstd}
Mixed logit models in WTP space can also be estimated using the {cmd:gmnl} command (Gu et al., 2013), but {cmd:mixlogitwtp}
is more convenient for this purpose. The two commands will not in general give identical results (although they should be
similar) since {cmd:gmnl} uses pseudo-random draws instead of Halton draws for the scale coefficient (which can be interpreted as 
the price coefficient in WTP space models). In contrast {cmd:mixlogitwtp} uses Halton draws for all of the random coefficients. 
As the number of draws increases any differences should become smaller.


{title:References}

{phang}Gu Y, Hole AR, Knox S. 2013. Fitting the generalized multinomial logit model in Stata.
{it:The Stata Journal} 13: 382-397.

{phang}Hole AR. 2007. Fitting mixed logit models by using maximum simulated likelihood.
{it:The Stata Journal} 7: 388-401.

{phang}Hole AR, Kolstad JR. 2012. Mixed logit estimation of willingness to pay distributions: 
a comparison of models in preference and WTP space using data from a health-related choice 
experiment. {it:Empirical Economics} 42: 445-469.

{phang}Revelt D, Train K. 2000. Customer-specific taste parameters and mixed logit:
Households' choice of electricity supplier. Working Paper, Department of Economics,
University of California, Berkeley.

{phang}Scarpa R, Thiene M, Train K. 2008. Utility in willingness to pay space: A tool 
to address confounding random scale effects in destination choice to the Alps. 
{it:American Journal of Agricultural Economics} 90: 994-1010.

{phang}Train KE, Weeks M. 2005. Discrete choice models in preference space and willingness-to-pay 
space. In: Scarpa R, Alberini A (eds) Application of simulation methods in environmental and resource 
economics. Springer, Dordrecht, pp 1-16.

{phang}Train KE. 2009. {it:Discrete Choice Methods with Simulation}.
Cambridge: Cambridge University Press.

{title:Author}

{pstd}
Arne Risa Hole (a.r.hole@sheffield.ac.uk), Department of Economics, University of Sheffield. {p_end} 

{title:Acknowledgements}

{pstd}
Thanks to Kenneth Train for suggesting writing this command. {p_end}


{title:Also see}

{psee}
Manual:  {bf:[R] asclogit} {bf:[R] clogit}

{psee}
Online:  {manhelp asclogit R} {manhelp clogit R}{p_end}
