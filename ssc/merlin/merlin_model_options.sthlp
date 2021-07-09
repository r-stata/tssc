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

{p2colset 5 17 19 2}{...}
{p2col:{helpb merlin} {hline 2}}Extended multivariate generalised linear and non-linear mixed effects models{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:merlin} {it:{help merlin_models:models}} ...{cmd:,} ...
    {it:model_description_options}

{synoptset 28 tabbed}{...}
{synopthdr:model_description_options}
{synoptline}
{synopt:{opt family()}, ...}see {helpb merlin_models##family:merlin families}{p_end}
{synopt:{opt redist:ribution(redist_list)}}distribution of the random effects at each level{p_end}
{synopt:{opt df(numlist)}}degrees of freedom for the {it:t}-distribution(s){p_end}
{synopt:{opt cov:ariance()}}notation for treatment of covariances{p_end}
{synopt:{opt w:eights(varlist)}}specify weights; see details{p_end}
{synopt :{opt const:raints()}}specify constraints{p_end}
{synopt :{opt from()}}specify starting values{p_end}
{synopt :{opt nogen}}do not generate the component and element variables; see details{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{it:{help merlin_models:models}} and the options above describe the model to be fit by {cmd:merlin}.


{marker options}{...}
{title:Options}

{phang}
{cmd:family()} specifies the distribution, such as {cmd:family(poisson)}. See
      {helpb merlin_models##family:merlin family}.

{phang}
{opt redistribution(redist_list)} 

{phang2}{opt gaussian} specifies normally-distributed random effects

{phang2}{opt t} specifies {it:t}-distributed random effects

{p 8 8 2}For a 3-level model, we could specify a {it:t} distribution with {cmd:df(5)} at level 3, and normally distributed random effects 
at level 2 by using {cmd:redistribution(t gaussian) df(3)}.

{phang2}{opt df(numlist)} specifies the degrees of freedom for the {it:t}-distributed random effects
	  
{phang}
{opt covariance(struct_list)} specifies the covariance structure for the random effects at each level. The structures of the 
random effects should be defined in order from highest level to lowest. Available structures include

{phang2}{opt diag:onal} unique variances for each random effect, all covariances are 0; the default

{phang2}{opt iden:tity} all variances equal, all covariances are 0

{phang2}{opt un:structured} all variances and covariances uniquely estimated

{phang2}{opt ex:changeable} all variances equal, all covariances equal

{phang}
{opt weights(varlist)} specifies sample weights, applied multiplicatively to the likelihood at each level of the model. Multiple weight variables can be specified, 
but must be entered in the order of lowest (observation-level) to highest. Those at level > 1 can be repeated within clusters, 
but only a single value will be extracted, so they should be constant within clusters.

{phang}
{opt constraints()} specifies parameter constraints you wish to impose on your
model.

{phang}
{opt from()} specifies the starting values to be used in the optimization
process.

{phang}
{opt nogen} stops {cmd:merlin} from generating Stata variables, representing those created in the component and element 
specifications. By default, they are created and indexed by model, component and number.

{marker examples}{...}
{title:Examples}

{phang}
For detailed examples, see {bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data, clear}{p_end}

{pstd}Linear mixed effects model with unstructured variance-covariance structure{p_end}
{phang2}{cmd:. merlin (logb time age trt time#M1[id]@1 M2[id]@1, family(gaussian)), covariance(unstructured)}{p_end}


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
Crowther MJ. Extended multivariate generalised linear and non-linear mixed effect models. 2017; {it:Under review}.{p_end}


