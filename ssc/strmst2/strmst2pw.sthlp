{smcl}
{* 02mar2016}{...}
{cmd:help strmst2pw} 
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:strmst2} {hline 2}}Postestimation command for strmst2 {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{marker syntax1}{...}
{cmd:strmst2pw} {it: indicator1}
[{cmd:,} {opt rmtl}]
{space 31}({help strmst2pw##Syntax1:Syntax 1})

{p 8 15 2}
{marker syntax2}{...}
{cmd:strmst2pw} {it: indicator1} {it:ReferenceIndicator}
[{cmd:,} {opt rmtl}]
{space 12}({help strmst2pw##Syntax2:Syntax 2})

{title:Description}

{pstd} {cmd:strmst2pw} is a postestimation command that may be of interest after
{cmd:strmst2} is run with the covariates option specified. {cmd:strmst2pw} 
summarizes pairwise comparisons for the previously
estimated model. Three kinds of between-group constrast metrics (i.e. the difference
in restricted mean survival time (RMST), the ratio of RMST and the ratio of the  
restricted mean time lost (RMTL)) are computed. 

{pin2}{marker Syntax1}
{help strmst2pw##syntax1:Syntax 1}: Pairwise comparisons are summarized for the group
identified by {it: indicator1} in reference to the group that was the reference
category in the previously estimated model.

{pin2}{marker Syntax2}
{help strmst2pw##syntax2:Syntax 2}: Pairwise comparisons are summarized for the group
identified by {it: indicator1} in reference to the group identified by {it: ReferenceIndicator}.

{title:Options}

{phang}{opt rmtl} Display between-group contrasts for the ratio of the restricted
mean time lost (RMTL), in addition to the metrics for the restricted mean survival time
(RMST). The default is to show between-group contrasts only for the RMST.

{title:Examples}

{pstd}Compare restricted mean survival time, specifying group 0 as the reference category: {p_end}
{p 8 14 2}{cmd:. strmst2 treatment, tau(10) covariates(age bili albumin) reference(0)}

{pstd}Pairwise comparison of group 1 versus group 0 (the reference in the previously estimated model): {p_end}
{p 8 14 2}{cmd:. strmst2pw _Iexarm_1}

{pstd}Pairwise comparison of group 1 versus group 2: {p_end}
{p 8 14 2}{cmd:. strmst2pw _Iexarm_1  _Iexarm_2}

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


