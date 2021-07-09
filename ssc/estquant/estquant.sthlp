{smcl}
{* *! version 1.10 06 December 2017}{...}
{viewerjumpto "Syntax" "estquant##syntax"}{...}
{viewerjumpto "Description" "estquant##description"}{...}
{viewerjumpto "Options" "estquant##options"}{...}
{viewerjumpto "Remarks" "estquant##remarks"}{...}
{viewerjumpto "Examples" "estquant##examples"}{...}
{viewerjumpto "Author" "estquant##author"}{...}
{viewerjumpto "References" "estquant##references"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{bf:estquant} {hline 2}}Quantile approach by Combes et al. (2012){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:estquant} {varname} {ifin}, {cmd:cat({varname})} 
[{opt sh:ift} {opt di:lation} {opt tr:uncation} {opt initr(#)} {opt qrange(#)} {opt bvar:iable}{bf:([on|off])} 
{opt brep:lication(#)} {opt bsam:pling(#)} {opt strata} {opt maxit:eration(#)} {opt eps1(#)} {opt eps2(#)} 
{opt ci}{bf:([normal|bootstrap])} {opt l:evel(#)} ]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required Settings}
{synopt:{opth cat(varname)}} specifies the variable classifying the sample into two categories.
{p_end}
{syntab:Optional Settings}
{synopt:{opt sh:ift}} estimates the relative shift parameter {it:A}.
{p_end}
{synopt:{opt di:lation}} estimates the relative dilation parameter {it:D}.
{p_end}
{synopt:{opt tr:uncation}} estimates the relative truncation parameter {it:S}.
{p_end}
{synopt:{opt initr(#)}} specifies the initial value of the relative truncation parameter {it:S} for numerical optimization.
{p_end}
{synopt:{opt qrange(#)}} specifies the range of quantile function.
{p_end}
{synopt:{opt bvar:iable}{bf:([on|off])}} specifies whether the bootstrap uses variables prepared beforehand in the dataset.
{p_end}
{synopt:{opt brep:lication(#)}} specifies the number of the bootstrap replications.
{p_end}
{synopt:{opt bsam:pling(#)}} specifies the percentage of the sample size for bootstrap sampling.
{p_end}
{synopt:{opt strata}} fixes the number of observations in each category in each bootstrap replication.
{p_end}
{synopt:{opt maxit:eration(#)}} specifies the maximum number of iterations in numerical optimization.
{p_end}
{synopt:{opt eps1(#)}} specifies the convergence tolerance in numerical optimization.
{p_end}
{synopt:{opt eps2(#)}} specifies the convergence tolerance in numerical optimization.
{p_end}
{synopt:{opt ci}{bf:([normal|bootstrap])}} specifies types of confidence interval.
{p_end}
{synopt:{opt l:evel(#)}} specifies the level of the confidence interval.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
The {cmd: estquant} command implements the quantile approach suggested by Combes et al. (2012). 
{p_end}


{marker options}{...}
{title:Options}
{dlgtab:Required Settings}
{phang}
{opth cat(varname)} specifies the variable classifying the sample into two categories. 
This category variable must be binary, but it can take any values (e.g., 0 and 1 or 1 and 2). 
{p_end}

{dlgtab:Optional Settings}
{phang}
{opt sh:ift} estimates the relative shift parameter {it:A}. When this option is not specified, 
the relative shift parameter is constrained as {it:A} = 0.
{p_end}

{phang}
{opt di:lation} estimates the relative dilation parameter {it:D}. When this option is not 
specified, the relative dilation parameter is constrained as {it:D} = 1.
{p_end}

{phang}
{opt tr:uncation} estimates the relative truncation parameter {it:S}. When this option is not 
specified, the relative truncation parameter is constrained as {it:S} = 0.
{p_end}

{phang}
{opt initr(#)} specifies the initial value of the relative truncation parameter {it:S} for numerical optimization. In the default setting, the initial value is automatically selected by the grid search.
{p_end}

{phang}
{opt qrange(#)} specifies the range of quantile function. The quantile range [0,1] is 
divided into {it:#} ranges. The default value is 1,000.
{p_end}

{phang}
{opt bvar:iable}{bf:([on|off])} specifies whether the bootstrap uses variables prepared beforehand 
in the dataset. If this option is {bf:on}, then the bootstrap replications are conducted using the 
{varname} named in a sequential order at each iteration. If this option is {bf:off}, then the 
bootstrap replications are conducted by resampling {varname} at each iteration. The default 
setting is {bf:off}.
{p_end}

{phang}
{opt brep:lication(#)} specifies the number of the bootstrap replications. If this option 
takes the value of 0, the bootstrap replication is skipped and bootstrap standard errors 
are not calculated. If {opt bvar:iable}{bf:(on)} is specified, then the {opt brep:lication(#)} 
must be the last number of {varname} named in sequential order. The default value is 50.
{p_end}

{phang}
{opt bsam:pling(#)} specifies the percentage of the sample size for bootstrap sampling. The 
default value is 100(%), meaning that observations of the same sample size are drawn for 
bootstrap sampling. This option is ignored when is specified.
{p_end}

{phang}
{opt strata} fixes the number of observations in each category in each bootstrap replication. The {opt strata} option is not used in the default setting.
{p_end}

{phang}
{opt maxit:eration(#)} specifies the maximum number of iterations in numerical optimization. The 
default value is 1e+3.
{p_end}

{phang}
{opt eps1(#)} specifies the convergence tolerance in numerical optimization. The stopping rule 
of {opt eps1(#)} is shown in Kondo (2016). The default value is 1e-6.
{p_end}

{phang}
{opt eps2(#)} specifies the convergence tolerance in numerical optimization. The stopping rule 
of {opt eps2(#)} is shown in Kondo (2016). The default value is 1e-6. 
{p_end}

{phang}
{opt ci}{bf:([normal|bootstrap])} specifies types of confidence interval. The ci() option 
allows one to use the normal- and bootstrap-based confidence intervals. If bootstrap-based 
confidence interval is constructed, then a large number of bootstrap replications should be 
specified in the breplication(#) option. The default setting constructs the normal-based 
confidence interval.
{p_end}

{phang}
{opt l:evel(#)} specifies the level of the confidence interval. The default level is 95.0(%).
{p_end}


{marker examples}{...}
{title:Examples}

{phang}Basic command:{p_end}

{phang2}{cmd:. estquant} lntfp, cat(cat) sh di tr {p_end}

{phang}In the case in which truncation = 0, {opt tr:uncation} option is dropped as follows: {p_end}

{phang2}{cmd:. estquant} lntfp, cat(cat) sh di {p_end}

{marker author}{...}
{title:Author}

{pstd}Keisuke Kondo{p_end}
{pstd}Research Institute of Economy, Trade and Industry (RIETI). Tokyo, Japan.{p_end}
{pstd}(URL: https://sites.google.com/site/keisukekondokk/){p_end}


{marker references}{...}
{title:References}

{marker CDGPR2012}{...}
{phang}
Combes, P.P., G. Duranton, L. Gobillon, D. Puga, and S. Roux. (2012) "The productivity advantages of 
large cities: Distinguishing agglomeration from firm selection," {it:Econometrica} 80(6), pp. 2543-2594.
{p_end}

{marker K2017}{...}
{phang}
Kondo, K. (2017) "Quantile approach for distinguishing agglomeration from firm selection in Stata," RIETI TP 17-T-001.
{p_end}

