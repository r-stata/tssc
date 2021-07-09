{smcl}
{* 02mar2016}{...}
{cmd:help strmst2} 
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:strmst2} {hline 2}}Comparing restricted mean survival time{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:strmst2}
{it: groupvar}
{ifin}
[{cmd:,} {opt tau(#)} {opt covariates(varlist)} {opt level(#)} {opt reference(#)} {opt rmtl}]


{title:Description}

{pstd} {cmd:strmst2} performs k-sample comparisons using the restricted mean
survival time (RMST) as a summary measure of the survival time distribution.
The comparison will be performed by {it: groupvar}, where {it: groupvar} is a 
numeric categorical variable (with 0 typically indicating subjects in the control 
group and 1 typically indicating subjects in the active treatment group).
Three kinds of between-group constrast metrics (i.e. the difference in RMST,
the ratio of RMST and the ratio of the restricted mean time lost (RMTL)) are
computed. It performs an ANCOVA-type covariate adjustment as well as unadjusted
analyses for those measures. The command presumes that the data have been 
declared to be survival-time data using the {cmd:stset} command.  


{title:Options}

{phang}{opt tau(#)} A scalar value to specify the truncation time point 
for the RMST calculation. Tau needs to be smaller than the minimum of the 
largest observed time (either event or censor) in each of the groups. When
tau is not specified, the default value (i.e. the minimum of the largest
observed event time in each of the groups) is used.

{phang}{opt covariates(varlist)} This specifies covariates to be used for the
adjusted analyses. When covariates is not specified, unadjusted analyses are
performed. When covariates is specified, the ANOCVA-type adjusted analyses are
performed using those variables passed as covariates. This can be one variable
or more than one variable. 

{phang}{opt level(#)} set confidence level; default is level(95)

{phang}{opt reference(#)} set reference category; default is the smallest value

{phang}{opt rmtl} Display between-group contrasts for the ratio of the restricted
mean time lost (RMTL), in addition to the metrics for the restricted mean survival time
(RMST). The default is to show between-group contrasts only for the RMST.

{phang} {opt by} is allowed with {cmd:strmst2}; see {manhelp by D}.


{title:Examples}

{p 8 14 2}{cmd:. strmst2 treatment, tau(10)}


{p 8 14 2}{cmd:. strmst2 treatment, tau(10) covariates(age bili albumin)}

{p 8 14 2}{cmd:. strmst2 treatment, tau(10) covariates(age bili albumin) reference(2)}

{title:Authors}

{pstd}Angel Cronin{p_end}
{pstd}Dana-Farber Cancer Institute{p_end}
{pstd}angelm_cronin at dfci.harvard.edu{p_end}

{pstd}Lu Tian{p_end}
{pstd}Stanford University{p_end}
{pstd}lutian at stanford.edu{p_end}

{pstd}Hajime Uno{p_end}
{pstd}{p_end}
{pstd}Dana-Farber Cancer Institute{p_end}
{pstd}huno at jimmy.harvard.edu{p_end}

{title:Also see}

{p 4 14 2}Uno H, Claggett B, Tian L, Inoue E, Gallo P, Miyata T, Schrag D, 
Takeuchi M, Uyama Y, Zhao L, Skali H, Solomon S, Jacobus S, Hughes M, Packer M,
Wei LJ. Moving beyond the hazard ratio in quantifying the between-group
difference in survival analysis. Journal of clinical Oncology 2014, 32, 2380-2385. 

{p 4 14 2}Tian L, Zhao L, Wei LJ. Predicting the restricted mean event time with
the subject's baseline covariates in survival analysis. Biostatistics 2014, 15, 222-233. 


