{smcl}
{* *! version 1.0.0 02mar2018} {...}
{cmd:help probat}
{hline}

{title:Title}

{p2colset 5 16 20 2}{...}
{p2col :{hi:probat} {hline 2}}calculates transition probabilities and other statistics after {help xtpdyn}{p_end}
{p2colreset}{...}


{title:Sintax}

{p 4 17 2}
{cmd:probat}, {cmd:stats[({it:atspec})]} | {cmdab:prd:istr}   
[{opt ma:rgins(margins_options)}] [{opt n:q(#)}] [{opt showf:req}] [{cmd:plot}] [keep]


{title:Description}

{p 4 4 2} 
{cmd:probat} is a postestimator command to be used after {help xtpdyn}.
Either {cmd:stats[({it:atspec})]} or {cmd:prdistr} option must be specified.

{p 4 4 2} 
If {cmd:stats[({it:atspec})]} is specified, {cmd:probat} computes ancillary statistics for the 
overall sample or for the profile specified in {it:atspec} within {cmd:stats({it:atspec})}. 

{p 4 4 2} 
If {cmd:prdistr} is specified, {cmd:probat} permits to capture the impact of 
genuine state dependence at different levels of unobserved heterogeneity.

{p 4 4 2} 
Note that probabilities are estimated using {help margins} and many 
{cmd: margins} options are allowed.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt stats(atspec)} defines the profile for which ancillary statistics are computed.
Ancillary statistics include entry Pr(1|0), exit Pr(0|1) and persistence Pr(1|1) probabilities, 
the proportion of time spent in Y=1, the mean duration of the event and the turnover rate.
If only {opt stats} is specified, {cmd:probat} provides ancillary statistics
for the overal sample. 
{cmd:stats[({it:atspec})]} may not be used with {cmd:prdistr}. 

{p 4 4 2} 
In option {opt stats(atspec)}, {it: atspec} is defined as   
{it:varname1=#} [{it:varname2=#} [...]]


{phang}
{opt prd:istr} computes predicted probabilities Pr(1|0) and Pr(1|1) at different 
levels of unobserved heterogeneity (UH). It distinguishes UH in two components: 
UHy attributable to the initial period of Y, and UHz attributable to the 
initial period and the within-unit averages of time-varying explanatory variables.
Therefore, {opt prdistr} evaluates the probabilities Pr(1|0) and Pr(1|1) at all
the levels of the 2 UH components jointly. The first component is captured by the 
levels of Yt0 (0/1). The second component is defined in terms of quantiles 
of the  UHz sample distribution computed on the basis of initial period 
and the within-unit averages of time-varying explanatory variables.
{opt prdistr} may not be used with {opt stats(atspec)}.


{dlgtab:stats[(atspec)] Suboptions}

{phang}
{opt ma:rgins(margins_options)} specifies options usually allowed with {cmd:margins}.
See {help margins##options_table}. 


{dlgtab:prdistr Suboptions}

{phang}
{opt n:q(#)} specifies the number of quantiles used to split the distribution of 
unobserved heterogeneity (UHz). {opt n:q()} can assume only the following values: 2, 3, 4, 5, 10.
Default is {opt n:q(5)}.

{phang}
{opt showf:req} shows frequancies for the outcome Y by Yt-1, Yt0 and UHz quantiles. 

{phang}
{opt plot} plots results of {cmd: prdistr}. 

{phang}
{opt keep} keeps the variables capturing the distribution of unobserved heterogeneity (UHz).

{phang}
{opt ma:rgins(margins_options)} specifies options usually allowed with {cmd:margins}.
See {help margins##options_table}. 


{marker results}{...}
{title:Stored results}

{pstd}
If {cmd:stats[({it:atspec})]} is specified {cmd:probat} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(entry_pr)}}entry probability Pr(1|0){p_end}
{synopt:{cmd:r(exit_pr)}}exit probability Pr(0|1){p_end}
{synopt:{cmd:r(prop_t)}}proportion of time spent in y=1{p_end}
{synopt:{cmd:r(meandur)}}mean duration{p_end}


{pstd}
If either {cmd:stats[({it:atspec})]} or {cmd:prdistr} is specified {cmd:probat} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(probest)}}matrix of predicted probabilities{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use poverty}{p_end}

{pstd}Dynaminc random-effects probit model with unobserved heterogeneity{p_end}
{phang2}{cmd:. xtpdyn poor black c.age i.edu i.emp i.marstat, uh(i.emp i.marstat age)}

{pstd}Ancillary statistics for the profile specified in {cmd:stats({it:atspec})}{p_end}
{phang2}{cmd:. probat, stats(edu=1)}

{pstd}Ancillary statistics for the overall sample and confidence level at 90%{p_end}
{phang2}{cmd:. probat, stats margins(level(90))}

{pstd}Predicted probabilites over unobserved heterogeneity, distinguishing UHz 
in 4 quartiles and plotting the resutls{p_end}
{phang2}{cmd:. probat, prdistr nq(4) plot}


{marker references}{...}
{title:References}

{p 4 8 2}
Boskin, M.J. and C.F. Nold 1975.
A Markov model of turnover in Aid for Families with Dependent Children.
{it:Journal of Human Resources} 10: 467{c -}481.

{p 4 8 2}
Cappellari, L. and S.P. Jankins 2009.
The dynamic of social assistance benefit receipt in Britain.
{it:ISER Working Paper Series}: 2009{c -}2029.

{p 4 8 2}
Immervoll, H., Jenkins S., and Königs, S. 2015.
Are Recipients of Social Assistance ‘Benefit Dependent’?: Concepts, 
Measurement and Results for Selected Countries
{it:OECD Social, Employment and Migration Working Papers, No. 162, OECD Publishing, Paris.}


{title:Authors}

{phang}Raffaele Grotti <raffaele.grotti@esri.ie>{p_end}
{phang}The Economic and Social Research Institute{p_end}
{phang}Whitaker Square{p_end}
{phang}Sir John Rogerson's Quay, Dublin 2{p_end}
{phang}Ireland{p_end}

{phang}Giorgio Cutuli <g.cutuli@unitn.it>{p_end}
{phang}Department of Sociology and Social Research{p_end}
{phang}University of Trento{p_end}
{phang}Via Verdi, 26-I-38122 Trento{p_end}
{phang}Italy{p_end}


{title:Also see}

{phang} {help xtpdyn} {help margins}

{p 4 4 2}
For further details on model implementation and a more detailed example see:

{p 4 8 2}
Grotti, R. and G. Cutuli 2018.
{browse "https://www.researchgate.net/publication/323524968_Estimating_dynamic_random_effects_probit_model_with_unobserved_heterogeneity_using_Stata":Estimating dynamic random effects probit model with unobserved heterogeneity using Stata}



