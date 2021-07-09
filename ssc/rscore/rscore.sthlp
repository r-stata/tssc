{smcl}
{* 30aug2011}{...}
{cmd:help rscore}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:rscore}{hline 1}}Estimation of responsiveness scores{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:rscore}
{it:outcome} 
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help rscore##modeltype:modeltype}}{cmd:)}
{cmd:rs_name}{cmd:(}{it:stub}{cmd:)}
[{cmd:factors}{cmd:(}{it:varlist_f}{cmd:)}
{cmd:xlist}{cmd:(}{it:varlist_c}{cmd:)}
{cmd:graph}{cmd:(}{it:#}{cmd:)}
{cmd:radar}{cmd:(}{it:numlist}{cmd:)}
{cmd:id_string}{cmd:(}{it:varname}{cmd:)}
{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}
{cmd:save_graph1}{cmd:(}{it:filename}{cmd:)}
{cmd:save_graph2}{cmd:(}{it:filename}{cmd:)}]

{pstd}{cmd:fweight}s, {cmd:pweight}s, {cmd:iweight}s are allowed;
see {help weight}.



{title:Description}

{pstd} {cmd:rscore} computes unit-specific responsiveness scores using an iterated Random-Coefficient-Regression (RCR). 
The basic econometrics of this model can be found in Wooldridge (2002, pp. 638-642). 
The model estimated by {cmd:rscore} considers a regression of a response variable y, i.e. ({it:outcome}), 
on a series of factors (or regressors) x, i.e. {it:varlist}, by assuming a different reaction (or "responsiveness") 
of each unit to each factor contained in x. {cmd:rscore} allows for: (i) ranking units according to the 
level of the responsiveness score obtained; (ii) detecting factors that are more influential in driving unit performance; 
(iii) studying, more in general, the distribution (heterogeneity) of factor responsiveness scores across units. 


     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help rscore##modeltype:modeltype}}{cmd:)} specifies the model
to be estimated, where {it:modeltype} must be one of the following
models: "ols", "fe", "re". It is always required to specify one model.   


{phang} {cmd:rs_name}{cmd:(}{it:stub}{cmd:)} specifes the name the user wants to give to the responsiveness scores
variables generate by rscore. RS variables are thus named as: {it:stub}1, {it:stub}2, {it:stub}3,
... and so forth.

{phang} {cmd:factors}{cmd:(}{it:varlist_f}{cmd:)} specifies that factor variables have to be included
among the regressors. It is optional for both models.

{phang} {cmd:xlist}{cmd:(}{it:varlist_c}{cmd:)} specifies that control variables (which are not factors) 
have to be included among the regressors. It is optional for both models.


{phang} {cmd:graph}{cmd:(}{it:#}{cmd:)} provides a combined graph of the densities of the responsiveness scores. The
number # defines the width of the graph's x-axis. The user can set a proper # for providing a good rendering of the graph.


{phang} {cmd:radar}{cmd:(}{it:numlist}{cmd:)} provides a radar plot of the responsiveness scores for the units specifed
in numlist. Notice that, in order to run this option, the user must specify the {cmd:id_string}{cmd:(}{it:varname}{cmd:)}
option.


{phang} {cmd:id_string}{cmd:(}{it:varname}{cmd:)} requests to specify a string variable as identifer of each observation. 
This is compulsory if the user wishes to provide a radar plot of the responsiveness scores.

{phang} {cmd:vce}{cmd:(}{it:vcetype}{cmd:)}: allows to choose {it:vcetype} as either {it:robust}, or {it:cluster clustvar}.


{phang} {cmd:save_graph1}{cmd:(}{it:filename}{cmd:)} allows to save the graph generate by the option {cmd:graph}{cmd:(}{it:#}{cmd:)}
in the user specifed filename.

{phang} {cmd:save_graph2}{cmd:(}{it:filename}{cmd:)} allows to save the graph generate by the option {cmd:radar}{cmd:(}{it:numlist}{cmd:)}
in the user specifed filename.


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt ols}}regression estimated by ordinary least squares (OLS){p_end}
{p2coldent : {opt fe}}panel data fixed-effect regression (FE){p_end}
{p2coldent : {opt re}}panel data random-effect regression (RE){p_end}
{synoptline}


{pstd}
{cmd:rscore} returns goodness-of-fit statistics - i.e. R-squared - for each estimated factor regression, by storing them
in the following scalars: {bf:e(R1)}, ..., {bf:e(RQ)}. Further, {cmd:rscore} provides the average R-squared - i.e the overall goodness-of-fit of the model - 
stored in the scalar {bf:e(R)}.

{pstd}
{cmd:rscore} creates a number of variables:

{pmore}
{inp:{it:stub}j} is the responsiveness scores variable related to the {it:j}-th variable of {it:varlist}. 
They are as many as the variables considered in {it:varlist}.


{title:Remarks}
	 
{pstd} Please, before running this program, remember to have the most recent up-to-date version installed.


{title:Examples}

{inp:. rscore y x1 x2 x3 , rs_name(RS) model(ols) factor(f1 f2)}
{inp:. rscore y x1 x2 x3 , rs_name(RS) model(fe)  factor(f1 f2) xlist(x4 x5)}

   
{title:Reference}

{phang}
Wooldridge, J. M. 2002. {it: Econometric Analysis of Cross Section and Panel Data}.
The MIT Press, Cambridge.
{p_end}

{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb ivregress}
{p_end}
