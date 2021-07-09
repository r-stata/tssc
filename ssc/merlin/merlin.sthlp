{smcl}
{* *! version 0.1.0  ?????2017}{...}
{vieweralsosee "merlin model description options" "help merlin_models"}{...}
{vieweralsosee "merlin estimation options" "help merlin_estimation"}{...}
{vieweralsosee "merlin reporting options" "help merlin_reporting"}{...}
{vieweralsosee "merlin postestimation" "help merlin_postestimation"}{...}
{viewerjumpto "Syntax" "merlin##syntax"}{...}
{viewerjumpto "Description" "merlin##description"}{...}
{viewerjumpto "Options" "merlin##options"}{...}
{viewerjumpto "Examples" "merlin##examples"}{...}
{viewerjumpto "Stored results" "merlin##results"}{...}
{title:Title}

{p2colset 5 15 19 2}{...}
{p2col:{helpb merlin} {hline 2}}Mixed effects regression for linear, non-linear and user-defined models{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:merlin} {help merlin_models:{it:models}} {ifin}
[{cmd:,} {it:options}]

{pstd}
where
{it:models} are the model specifications; see {helpb merlin_models:merlin models}.{p_end}

{synoptset 30}{...}
{synopthdr:options}
{synoptline}
{synopt :{help merlin_model_options:{it:model_description_options}}}fully
define, along with {it:models}, the model to be fit{p_end}

{synopt :{help merlin_estimation:{it:estimation_options}}}method
used to obtain estimation results, including specifying initial values{p_end}

{synopt :{help merlin_reporting:{it:reporting_options}}}reporting
of estimation results{p_end}
{synoptline}
{p 4 6 2}
Also see {helpb merlin_postestimation:merlin postestimation} for features
available after estimation.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:merlin} fits mixed effects regression models for linear and non-linear outcomes
{browse "https://arxiv.org/abs/1710.02223":(Crowther 2017)}. Much of what {cmd:merlin} can do, 
can be done with {helpb gsem}. Much of what {cmd:merlin} can do, cannot be done with {helpb gsem}. 

{pstd}
For full details and many tutorials, take a look at the accompanying website: 
{bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}


{marker options}{...}
{title:Options}

{phang}
{it:model_description_options}
describe the model to be fit.  The model to be fit is fully specified by
{it:models} -- which appear immediately after {cmd:merlin} -- and the option 
{opt covariance()}.  See {helpb merlin_model_options:merlin model description options} and 
{helpb merlin_models:merlin model notation}.

{phang}
{it:estimation_options}
control how the estimation results are obtained.  These options control how
the standard errors (VCE) are obtained and control technical issues
such as choice of estimation method.  See 
{helpb merlin_estimation:merlin estimation options}.

{phang}
{it:reporting_options}
control how the results of estimation are displayed.  See 
{helpb merlin_reporting:merlin reporting options}.


{marker examples}{...}
{title:Examples}

{pstd}
These examples are intended for quick reference.  For detailed examples, see
{bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.


{title:Examples: Linear regression}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Use {cmd:regress} command{p_end}
{phang2}{cmd:. regress mpg weight foreign}{p_end}

{pstd}Replicate model with {cmd:merlin}{p_end}
{phang2}{cmd:. merlin (mpg weight foreign, family(gaussian))}{p_end}


{title:Examples: Logistic regression}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse gsem_lbw}{p_end}

{pstd}Use {cmd:logit} command{p_end}
{phang2}{cmd:. logit low age lwt smoke ptl ht ui}{p_end}

{pstd}Replicate model with {cmd:merlin}{p_end}
{phang2}{cmd:. merlin (low age lwt smoke ptl ht ui, family(bernoulli))}{p_end}


{title:Examples: Linear model with random intercept and slope}

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data, clear}{p_end}

{pstd}Use {cmd:mixed} command{p_end}
{phang2}{cmd:. mixed logb time age trt || id: time}{p_end}

{pstd}Replicate model with {cmd:merlin}{p_end}
{phang2}{cmd:. merlin (logb time age trt time#M1[id]@1 M2[id]@1, family(gaussian))}{p_end}


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
{bf:Crowther MJ}. Extended multivariate generalised linear and non-linear mixed effects models. 
{browse "https://arxiv.org/abs/1710.02223":https://arxiv.org/abs/1710.02223}
{p_end}

{p 5 12 2}
{bf:Crowther MJ}. merlin - a unified framework for data analysis and methods development in Stata. 
{browse "https://arxiv.org/abs/1806.01615":https://arxiv.org/abs/1806.01615}
{p_end}
