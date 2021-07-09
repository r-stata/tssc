{smcl}
{* *! version 0.1.0  ?????2017}{...}
{vieweralsosee "merlin model description options" "help merlin_models"}{...}
{vieweralsosee "merlin estimation options" "help merlin_estimation"}{...}
{vieweralsosee "merlin reporting options" "help merlin_reporting"}{...}
{vieweralsosee "merlin postestimation" "help merlin_postestimation"}{...}
{title:Title}

{p2colset 5 15 19 2}{...}
{p2col:{helpb merlin} {hline 2}}user-defined Mata functions{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
{it:Here I describe some of the advanced capabilities of }{cmd:merlin}{it:, and hence this is where it is easiest to go wrong. }
{it:If this is your first time writing a user-defined function with }{cmd:merlin}{it:, then please read the }
{helpb merlin_user##description:Description} {it:first.}

{pstd}
{it:The easiest way to learn the full capabilities is to work through some of the more complex examples, described at}
{bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.


{phang}
{ul:{bf:Utility functions}}

{phang2}{it:real matrix }{bf:merlin_util_depvar(}{it:{help merlin_user##gml:gml}}{bf:)}
returns the dependent variable(s) from the model. If the model is a survival model, with {opt failure(varname)} specified, then 
the returned matrix has a second column which contains the event indicator variable.

{phang2}{it:real matrix }{cmd:merlin_util_xzb(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the complex linear predictor from the model, 
i.e. the {cmd:XB[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details.

{phang2}{it:real matrix }{cmd:merlin_util_xzb_deriv(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the first derivative with respect to time, d/dt, of the complex linear predictor from the model, 
i.e. the {cmd:dXB[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details. It is calculated using numerical differentiation.

{phang2}{it:real matrix }{cmd:merlin_util_xzb_deriv2(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the second derivative with respect to time, d2/dt2, of the complex linear predictor from the model, 
i.e. the {cmd:d2XB[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details. It is calculated using numerical differentiation.

{phang2}{it:real matrix }{cmd:merlin_util_xzb_integ(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the integral with respect to time of the complex linear predictor from the model, 
i.e. the {cmd:iXB[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details.  It is calculated using numerical integration.

{phang2}{it:real matrix }{cmd:merlin_util_expval(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the expected value of the current model, i.e. the {cmd:EV[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details.

{phang2}{it:real matrix }{cmd:merlin_util_expval_deriv(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the first derivative with respect to time, d/dt, of the expected value of the current model, 
i.e. the {cmd:dEV[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details. It is calculated using numerical differentiation.

{phang2}{it:real matrix }{cmd:merlin_util_xzb_deriv2(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the second derivative with respect to time, d2/dt2, of the expected value of the current model, 
i.e. the {cmd:d2EV[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details. It is calculated using numerical differentiation.

{phang2}{it:real matrix }{cmd:merlin_util_xzb_integ(}{it:{help merlin_user##gml:gml}} [{it:, {help merlin_user##time:t}}]{bf:)} 
returns the integral with respect to time of the expected value of the current model, 
i.e. the {cmd:iEV[]} element type. If {it:t} is specified, it is evaluated at time points contained in {it:t}. See 
{helpb merlin_user##time:Passing time} for details.  It is calculated using numerical integration.

{phang2}{it:real scalar }{cmd:merlin_util_ap(}{it:{help merlin_user##gml:gml}, {it:i}}{bf:)} returns the {it:i}th ancillary 
parameter of the current model. Ancillary parameters are specified using the {cmd:nap(#)} option.

{phang2}{it:real scalar }{cmd:merlin_util_timevar(}{it:{help merlin_user##gml:gml}}{bf:)} returns the time variable
of the current model. This corresponds to what was specified in the associated {cmd:timevar()} option.

{marker model}{...}
{phang}
{ul:{bf:Indexing other models}}

{pstd}
All utility functions described above have a corresponding {cmd:*_mod()} function to do the same as {cmd:*}, but 
extract the information for another model. 
They can be used to build models which depend on other model's linear predictors, for example. 

{pstd}
Models are indexed by the order they are specified in the {cmd:merlin} command.


{marker gml}{...}
{phang}
{ul:{bf:Definition of gml}}

{pstd}
{it:gml}, if it is declared, should be declared transmorphic. {it:gml} holds the information about the {cmd:merlin} 
optimization problem. Think of it as an {it:M} object when writing an evaluator using {helpb moptimize}. 
You should not attempt to alter the contents of {it:gml}.


{marker time}{...}
{phang}
{ul:{bf:Passing time}}

{pstd}
If you are passing a user-written function to the {cmd:hfunction()} argument of {cmd:family(user,...)}, without 
specifying the {cmd:chfunction()}, then you must make sure that your function takes a second argument of time {it:t}. 
This must then be passed to any other utility functions which may depend on time, and also used as your time variable in the 
definition of your hazard function. This is because time will be numerically integrated over in the calculation of the 
cumulative hazard function, required in the log likelihood, so {cmd:merlin} {it:must} know everything that is dependent on time.


{marker description}{...}
{title:Description}

{pstd}
The ability to have user-defined log-likelihood, hazard or cumulative hazard functions, provides substantial flexibility in the models 
you can fit with {helpb merlin}. This functionality means you get the extended, complex linear predictor of an inbuilt {cmd:merlin} 
model, for free. You also have the entire library of {cmd:Mata} functions at your disposal, to write as simple or as complex a function 
as you so wish. You can then combine your new model with any of the inbuilt models within a multivariate framework, or indeed combine it 
with another user-defined model...the possibilities are endless.

{pstd}
For full worked examples, please visit {bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.


{title:Writing a merlin log-likelihood function}

{pstd}
The structure of a user-defined function, to pass to {bf:family(user, llfunction(}{it:functionname}{bf:)}} is as follows

{p 4 12 2}
{it: real matrix} functionname(gml)
{p_end}
{p 4 12 2}
{
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
{it:some code}
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
logl = {it:some more code}
{p_end}
{p 8 12 2}
return(logl)
{p_end}
{p 4 12 2}
}
{p_end}


{marker options}{...}
{title:Writing a merlin hazard function}

{pstd}
The first available structure of a user-defined function, to pass to {bf:family(user, hfunction(}{it:functionname}{bf:)}} is as follows

{p 4 12 2}
{it: real matrix} functionname(gml)
{p_end}
{p 4 12 2}
{
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
{it:some code}
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
haz = {it:some more code}
{p_end}
{p 8 12 2}
return(haz)
{p_end}
{p 4 12 2}
}
{p_end}

{pstd}
which assumes you have also specified the {cmd:chfunction()} option. If you haven't, then you need to use the second structure, as 
follows:

{p 4 12 2}
{it: real matrix} functionname(gml , {it:real colvector} t)
{p_end}
{p 4 12 2}
{
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
{it:some code}
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
haz = {it:some more code}
{p_end}
{p 8 12 2}
return(haz)
{p_end}
{p 4 12 2}
}
{p_end}


{marker options}{...}
{title:Writing a merlin cumulative hazard function}

{pstd}
The structure of a user-defined function, to pass to {bf:family(user, chfunction(}{it:functionname}{bf:)}} is as follows:

{p 4 12 2}
{it: real matrix} functionname(gml)
{p_end}
{p 4 12 2}
{
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
{it:some code}
{p_end}
{p 8 12 2}
...
{p_end}
{p 8 12 2}
chaz = {it:some more code}
{p_end}
{p 8 12 2}
return(chaz)
{p_end}
{p 4 12 2}
}
{p_end}


{title:Examples}

{phang2}
For detailed examples, see {bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.


{title:Author}

{p 5 12 2}
{bf:Michael J. Crowther}{p_end}
{p 5 12 2}
Biostatistics Research Group{p_end}
{p 5 12 2}
Department of Health Sciences{p_end}
{p 5 12 2}
University of Leicester{p_end}
{p 5 12 2}
michael.crowther@le.ac.uk{p_end}


{title:References}

{p 5 12 2}
Crowther MJ. Extended multivariate generalised linear and non-linear mixed effect models. 2017; {it:Submitted}.{p_end}

