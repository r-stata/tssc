{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "predictms" "help predictms"}{...}
{vieweralsosee "msset" "help msset"}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{viewerjumpto "Syntax" "stms##syntax"}{...}
{viewerjumpto "Description" "stms##description"}{...}
{viewerjumpto "Options" "stms##options"}{...}
{viewerjumpto "Examples" "stms##examples"}{...}
{title:Title}

{p2colset 5 13 16 2}{...}
{p2col :{hi:stms} {hline 2}}Transition-specific multi-state modelling{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd: stms}  ({it:model1}) [({it:model2})] [...] 

{p 4 4 2}
where the syntax of {it:modeli} is

{p 12 24 2}
[{indepvars}] {ifin} [{cmd:,} {it:{help stms##model_options:model_options}}]

{p 4 4 2}
{it:depvar} specifies the longitudinal continuous response variable. {p_end}

{synoptset 29 tabbed}{...}
{marker model_options}{...}
{synopthdr:model_options}
{synoptline}
{syntab:Model}
{synopt :{opt model(exponential)}}exponential survival model{p_end}
{synopt :{opt model(weibull)}}Weibull survival model{p_end}
{synopt :{opt model(gompertz)}}Gompertz survival model{p_end}
{synopt :{opt model(llogistic)}}Gompertz survival model{p_end}
{synopt :{opt model(lnormal)}}Gompertz survival model{p_end}
{synopt :{opt model(ggamma)}}generalised gamma survival model{p_end}
{synopt :{opt model(fpm)}}flexible parametric survival model{p_end}

{syntab:FPM options}
{synopt:{it:{help stpm2:fpm_opts}}}additional options for use with {cmd:model(fpm)}; see {help stpm2}{p_end}

{syntab:Maximisation}
{synopt :{opt constraints(cons_list)}}list of constraints{p_end}
{synopt :{it:{help stjm##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{syntab:Reporting}
{synopt:{opt showc:ons}}list constraints in output{p_end}
{synopt:{opt keepc:ons}}do not drop constraints used in ml routine{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
You must {cmd:msset} and {cmd:stset} your data before using {cmd:stms}; see {helpb msset} and {manhelp stset ST}. {p_end}
{p 4 6 2}
See {helpb predictms} for features available after estimation. {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stms} fits joint transition-specific survival models, allowing each transition to have a different parametric model, 
yet maximised jointly to enable sharing of covariate effects across transitions. The order of {it:models} corresponds to the 
transition number from your transition matrix, used in {cmd:msset}.

{phang}
{cmd:stms} is part of the {cmd:multistate} package by Michael Crowther and Paul Lambert. Further 
details here: {bf:{browse "https://www.mjcrowther.co.uk/software/multistate":mjcrowther.co.uk/software/multistate}}
{p_end}


{marker examples}{...}
{title:Example 1}

{pstd}
This dataset contains information on 2982 patients with breast cancer. Baseline is defined as time of surgery, and patients can experience 
relapse, relapse then death, or death with no relapse. Time of relapse is stored in {cmd:rf}, with event indicator {cmd:rfi}, and time of death 
is stored in {cmd:os}, with event indicator {cmd:osi}.
{p_end}

{pstd}Load example dataset:{p_end}
{phang}{cmd:use http://fmwww.bc.edu/repec/bocode/m/multistate_example}{p_end}

{pstd}{cmd:msset} the data:{p_end}
{phang}{cmd:msset, id(pid) states(rfi osi) times(rf os)}{p_end}

{pstd}Store the transition matrix:{p_end}
{phang}{cmd:mat tmat = r(transmatrix)}{p_end}

{pstd}stset the data using the variables created by {cmd:msset}{p_end}
{phang}{cmd:stset _stop, enter(_start) failure(_status=1)}{p_end}

{pstd}Fit transition-specific models for transitions 1, 2 and 3, :{p_end}
{pstd}{cmd:stms (age sz2 sz3 nodes pr_1 hormon, model(fpm) df(3) scale(h)) ///}{p_end}
{p 9 9 2}{cmd:(age sz2 sz3 nodes pr_1 hormon, model(weib)) ///}{p_end}
{p 9 9 2}{cmd:     (age sz2 sz3 nodes pr_1 hormon, model(fpm) df(3) scale(h))}{p_end}

{pstd}Calculate transition probabilities for a patient with age 50:{p_end}
{phang}{cmd:predictms, transmatrix(tmat) at1(age 50)}{p_end}

{pstd}We could constrain the effect of age to be the same for transitions 1 and 3 as follows:{p_end}
{pstd}{cmd:constraint 1 [xb1][age]=[xb3][age]}{p_end}
{pstd}{cmd:stms (age sz2 sz3 nodes pr_1 hormon, model(fpm) df(3) scale(h)) ///}{p_end}
{p 9 9 2}{cmd:(age sz2 sz3 nodes pr_1 hormon, model(weib)) ///}{p_end}
{p 9 9 2}{cmd:     (age sz2 sz3 nodes pr_1 hormon, model(fpm) df(3) scale(h)) ///}{p_end}
{p 9 9 2}{cmd: , constraint(1)}{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
Crowther MJ, Lambert PC. Parametric multi-state survival models: flexible modelling allowing transition-specific distributions with 
application to estimating clinically useful measures of effect differences. {it: Statistics in Medicine} 2017;36(29):4719-4742.
{p_end}
