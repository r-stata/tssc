{smcl}
{* *! version 1.0.0 05nov2017}{...}
{vieweralsosee "merlin model description options" "help merlin_models"}{...}
{vieweralsosee "merlin estimation options" "help merlin_estimation"}{...}
{vieweralsosee "merlin reporting options" "help merlin_reporting"}{...}
{vieweralsosee "merlin postestimation" "help merlin_postestimation"}{...}
{title:Title}

{p2colset 5 35 37 2}{...}
{p2col:{help merlin_reporting:{bf:merlin reporting options}} {hline 2}}Options affecting
reporting of results{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:merlin} {help merlin models:{it:models}} ...{cmd:,} ...
     {it:reporting_options}

{p 8 12 2}
{cmd:merlin,} {it:reporting_options}


{synoptset 19}{...}
{synopthdr:reporting_options}
{synoptline}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt coefl:egend}}display coefficient legend{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nohead:er}}do not display header above parameter table{p_end}
{synopt :{opt notable}}do not display parameter tables{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
These options control how {cmd:merlin} displays estimation results.


{marker options}{...}
{title:Options}

{phang}
{opt level(#)}; see {manlink R estimation options}.

{phang}
{opt coeflegend} displays the legend that reveals how to specify estimated
coefficients in {opt _b[]} notation, which you are sometimes required to
type in specifying postestimation commands.

{phang}
{opt nocnsreport} suppresses the display of the constraints.

{phang}
{opt noheader} suppresses the header above the parameter table, the display
that reports the final log-likelihood value, number of observations, etc.

{phang}
{opt notable} suppresses the parameter table.


{marker remarks}{...}
{title:Remarks}

{pstd}
Any of the above options may be specified when you fit the model or when you
redisplay results, which you do by specifying nothing but options after the
{cmd:merlin} command:

{phang2}{cmd:. merlin (...) (...), ...}{p_end}
{phang2}{it:(original output displayed)}

{phang2}{cmd:. merlin}{p_end}
{phang2}{it:(output redisplayed)}

{phang2}{cmd:. merlin, coeflegend}{p_end}
{phang2}{it:(coefficient-name table displayed)}

{phang2}{cmd:. merlin}{p_end}
{phang2}{it:(output redisplayed)}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data, clear}{p_end}
{phang2}{cmd:. merlin (logb time age trt time#M1[id]@1 M2[id]@1, family(gaussian))}{p_end}

{pstd}Display coefficient legend{p_end}
{phang2}{cmd:. merlin, coeflegend}{p_end}

{pstd}Obtain 90 percent confidence intervals{p_end}
{phang2}{cmd:. merlin, level(90)}{p_end}
