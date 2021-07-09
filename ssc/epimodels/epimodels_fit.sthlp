{smcl}
{* *! version 1.1.0  29apr2020}{...}

{cmd:help epimodels}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epimodels fit} {hline 2} Estimation of parameters of epidemiological models from data.}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd: epimodels fit modelname,}
{it:options}

{pstd}
{cmd:Epimodels fit} allows to estimate the parameters of 
epidemiological models by fitting the model curves to the 
actual data. In the description below {opt modelname} is name 
of the model: SIR or SEIR; {opt param} is any of {it:beta} or 
{it:gamma} for SIR model, and {it:beta}, {it:gamma}, {it:sigma}, 
{it:mu}, or {it:nu} for SEIR model{p_end}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model parameters (optional)}
{synopt :{opt param(# | .)}} Known or unknown value of the corresponding 
parameter of the model{break}(default is missing if not specified).

{synopt :{opt param0(#)}} Starting value for the search{break}
(default is 0.5 if not specified).{break}

{syntab :Initial conditions (optional, assumed to be zero if not specified)}
{synopt :{opt susceptible(#)}}Number of susceptible individuals at t0{p_end}
{synopt :{opt exposed(#)}}Number of exposed individuals at t0 
(for SEIR model only){p_end}
{synopt :{opt infected(#)}}Number of infected individuals at t0{p_end}
{synopt :{opt recovered(#)}}Number of recovered individuals at t0{p_end}

{syntab :Levels (optional, but at least one must be specified)}
{synopt :{opt vsusceptible(var)}}Numeric variable indicating number of 
susceptible individuals at t{p_end}
{synopt :{opt vexposed(var)}}Numeric variable indicating number of 
exposed individuals at t (for SEIR model only){p_end}
{synopt :{opt vinfected(var)}}Numeric variable indicating number of 
infected individuals at t{p_end}
{synopt :{opt vrecovered(var)}}Numeric variable indicating number of 
recovered individuals at t{p_end}

{syntab :Other options}
{synopt :{opt format(%fmt)}}Specifies, which format should be used 
  to format the parameter estimates in the output{break} 
  (default is "%10.5f" if nothing is specified){p_end}


{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd: epimodels fit} estimates the parameters of epidemiological models 
searching for ones that provide the best fit of the model-based curves 
to the observed data. {p_end}

{pstd}
The supported models are: SIR and SEIR. Not every kind of disease/epidemics 
can be adequately described by these models. For example, the SIR model
implies that the susceptible population is declining (for any non-zero
value of beta and non-zero number of infected individuals) until it
reaches zero. This may or may not be true in your data. Sometimes it is
better to plot the time series that you have for observed levels before
performing the calibration. SEIR model is more flexible due to more
flexibility in parameters, but may be more complex to interpret or
formulate policy recommendations.{p_end}

{pstd}
More than one parameter of the model may be unknown. Indicate values 
of known parameters by specifying them like so: {it:beta(0.90)}. If the 
corresponding option is not specified or is specified as a 
missing value (.) that parameter will be estimated from data. 
For example, {it:gamma(.)}. A common situation is to exclude 
certain model effects, for example, if you know that there is no 
vaccination available or utilized for the disease, you can exclude 
the effect of vaccination from the SEIR model by specifying 
{it:nu(0.00)}. {p_end}

{pstd}
It is possible and common to specify multiple parameters as unknown, 
for example: {it:beta(.) gamma(.)}, in which case all of
them will be estimated from data.{p_end}

{pstd}
For every unknown parameter specify a starting value for the search, 
which is your best guess about this parameter. If such a starting 
value is not specified, the value 0.5 is taken as default. Specifying
starting values close or in the vicinity of the true ones helps the
search to converge.{p_end}

{pstd}
Initial conditions for the population must be specified in the same 
way how they are specified for the corresponding model, and default 
to zero if not specified. Total population may not be zero, hence 
at least one component must be non-zero in the initial conditions.{p_end}

{pstd}
Levels variables indicate the size of each group at a given time.
For example, {it:vinfected(zx75)} indicates that the number of infected 
individuals at time {it:t} is contained in variable {it:zx75}.{p_end}

{pstd}
Depending on the data availability you may have one or more 
variables reflecting the observed evolution of the corresponding 
levels. At least one is required, specifying more helps the model to
converge.{p_end}

{pstd}
Specifying initial conditions is important, since in the case 
where not all the level variables are known this allows establishing 
the total population size (which all these models maintain as constant).
{p_end}

{pstd}
The optimization is done by searching the values of the parameters of 
the model that minimize the deviation of the modelled data from the 
observed data (in the sense of sum of squared differences). Stata's 
built-in optimizer (in Mata) is used, which produces output during the
search indicating the progress made to improve the initial guess about
the values of the parameters. It may or may not converge, depending on
whether there is indeed a unique solution, or several, resulting in
similar quality of fit, and also on how appropriate is the selected
model for your data.{p_end}

{pstd}
Specify option {opt format(%fmt)} to provide a custom formatting of
estimates in the output report. The default format is %10.5f showing
5 decimal digits after comma.{p_end}


{title:Output}

    {hline}
{pstd}epimodels fit produces the report on the estimated values of the
model parameters, which may look like this for the SEIR model:{p_end}

                 SEIR model estimation
     ---------------------------------------------
            Parameter |    Value         Source   
     -----------------+---------------------------
             beta (β) |  0.903009       Estimated
            gamma (γ) |  0.200000       Estimated
            sigma (ς) |  0.102000       Estimated
               mu (μ) |  0.000000        Supplied
               nu (ν) |  0.000000        Supplied
     ---------------------------------------------

{pstd}The first column shows the parameter name, followed by the value. If the
value was estimated, the third column will indicate this with the word,
'Estimated'. If the value of the model parameter was supplied by the user, this
will be indicated with the word 'Supplied' in the third column.{p_end}

{pstd}Correspondingly, the output for the SIR model will have fewer parameters,
and similar interpretation.{p_end}
  
{pstd}As the optimizer searches for the improvement over the starting values
of the parameters, it reports its progress over the iterations. This may take
some time, and it usually takes more time for estimating a larger number of 
parameters.{p_end}


{title:Saved results}

    {hline}

{pstd}{cmd:epimodels fit} is an r-class command which saves the following 
into r():{p_end}	

{phang2}{it:r(param)} - numeric scalars with the final values of the 
parameter estimates. Final values is a combination of the estimated 
and supplied values (if any).{p_end}

{phang2}{it:r(modelcmd)} - name of the command for model simulation that 
corresponds to the estimated model.{p_end}

{phang2}{it:r(modelvars)} - names of the variables for population group sizes
if modelled with the abovementioned command.{p_end}

{phang2}{it:r(datavars)} - names of the variables for population group sizes
as present in the data.{p_end}

{phang2}{it:r(estimated)} - names of the model parameters that were estimated
from the data.{p_end}

{phang2}{it:r(iniconditions)} - all of the options corresponding to the 
initial conditions (including the implied zeroes) as a single string macro 
(useful if you need to graph the estimated model curves immediately after 
the estimation of the parameters).{p_end}

{phang2}{it:r(finparameters)} - all the final parameters of the model 
(estimated and supplied) as a single string macro (useful if you need 
to graph the estimated model curves immediately after the estimation 
of the parameters).{p_end}

{phang2}{it:r(finparamstr)} - all the final parameters of the model 
(estimated and supplied) as a single string macro with greek letters 
used for corresponding parameter names (useful if you need to display
the estimated parameter values on the graph immediately after the 
estimation).{p_end}

{pstd}
Note that both {it:r(modelvars)} and {it:r(datavars)} are specified in the 
same sequence. If a variable is not present in the data, its place is 
occupied by a missing value (.) in the {it:r(datavars)}. A variable 
name will never be a missing in the {it:r(modelvars)}.{p_end}

{title:Examples}

    {hline}
{pstd}Estimation{p_end}

{phang2}{cmd:. epimodels fit SIR , beta(0.9) gamma(.) susceptible(1000)} {break}
  {cmd:infected(50) vinfected(infpop) }{p_end}

{pstd}Perform an estimation of the parameter {it:gamma} of the SIR model for the 
population of 1050 individuals (=1000+50+0) of which 50 were infected and 
none were recovered on day zero, given that the infected population evolved
according to variable {it:infpop}.{p_end}

{phang2}{cmd:. epimodels fit SIR , beta(0.9) gamma(.) gamma0(0.65)} {break}
  {cmd:susceptible(1000) infected(50) vinfected(infpop) }{p_end}

{pstd}Same as above, but indicating that the search for best value of 
{it:gamma} should start from the value 0.65 instead of the default 0.5.{p_end}

{phang2}{cmd:. epimodels fit SIR , beta(.) gamma(.) gamma0(0.65)}{break}
  {cmd:susceptible(1000) infected(50) vinfected(infpop) }{p_end}

{pstd}Same as above, but both parameters {it:beta} and {it:gamma} must be 
estimated from the data.{p_end}

{phang2}{cmd:. epimodels fit SIR , gamma0(0.65) susceptible(1000)}{break}
  {cmd:infected(50) vinfected(infpop) vrecovered(recpop) }{p_end}

{pstd}Same as above, but search for the parameters that fit two series from 
the data: the infected population as contained in the variable {it: infpop} 
and recovered population as contained in the variable {it: recpop}.{p_end}

{phang2}{cmd:. epimodels fit SEIR , mu(0.00) nu(0.00) susceptible(1000)}{break}
  {cmd:infected(50) vinfected(infpop) vrecovered(recpop) }{p_end}

{pstd}Same as above, but estimate the three parameters of the SEIR model, 
namely: {it:beta}, {it:gamma}, {it:sigma}, by improving on the starting 
value of (0.5, 0.5, 0.5) by fitting two series (infected and recovered 
populations).{p_end}


{title:Authors}

{phang}
{it:Sergiy Radyakin}, The World Bank
{p_end}

{phang}
{it:Paolo Verme}, The World Bank
{p_end}

{title:Also see}

{psee}
Online: {browse "http://www.radyakin.org/stata/epimodels/": epimodels homepage}
{p_end}
