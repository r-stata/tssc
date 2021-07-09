{smcl}
{* *! version 1.1.0 Tom Palmer 2sep2013}{...}
{cmd:help reffadjust}
{hline}

{title:Title}

{p 5}{bf:reffadjust} {hline 2} Introduction to random effects adjustment commands{p_end}


{marker description}{...}
{title:Description}

{pstd}The {cmd:reffadjust} package provides postestimation commands to perform adjustment of random effects estimates.

{pstd}
The reffadjust commands are

{p2colset 9 30 32 2}{...}
{p2col :{helpb reffadjustsim}}simulating from the distribution of random effect variances and covariances{p_end}
{p2col :{helpb reffadjust4nlcom}}regression coefficient formula to pass to {cmd:nlcom}{p_end}
{p2colreset}{...}

{pstd}Since multilevel models including random effects, such as those implemented in MLwiN (Rasbash et al 2009) and {cmd:mixed}/{cmd:xtmixed},
return estimates of the variances and covariances of the random effects and the corresponding variances and covariances of these estimates we can use these to estimate adjusted coefficients.

{pstd}The approach is described in more detail in Macdonald-Wallis et al. (2012) and Palmer et al. (in press).

{pstd}The commands run with estimates from {cmd:runmlwin} or chains from {cmd:runmlwin} by {cmd:mcmcsum} (Leckie and Charlton, 2011), {cmd:mixed}/{cmd:xtmixed}, {cmd:meqrlogit}/{cmd:xtmelogit}, and {cmd:meqrpoisson}/{cmd:xtmepoisson}.
Note that in Stata 13 the following commands were renamed; {cmd:xtmixed} became {cmd:mixed}, {cmd:xtmelogit} became {cmd:meqrlogit}, and {cmd:xtmepoisson} became {cmd:meqrpoisson}.


{marker references}{...}
{title:References}

{phang}Leckie G, Charlton C. 2011. {cmd:runmlwin}: Stata module for fitting multilevel models in the MLwiN software package. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/runmlwin/"}

{phang}Macdonald-Wallis CM, Lawlor DA, Palmer TM, Tilling K. 2012. Multivariate multilevel spline models for parallel growth processes: application to weight and mean arterial pressure in pregnancy. Statistics in Medicine, 31, 3147-3164.

{phang}Palmer TM, Macdonald-Wallis CM, Lawlor DA, Tilling K. Estimating adjusted associations between random effects from multilevel models: the reffadjust package. The Stata Journal. In press.

{phang}Rasbash J, Charlton C, Browne WJ, Healy M, Cameron B. 2009. MLwiN version 2.1. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/mlwin"}.


{marker authors}{...}
{title:Authors}

{phang}Tom Palmer, Division of Health Sciences, Warwick Medical School,
University of Warwick, UK.
 {browse "mailto:t.m.palmer@warwick.ac.uk":t.m.palmer@warwick.ac.uk}.{p_end}

{phang}Corrie Macdonald-Wallis, MRC and University of Bristol Integrative Epidemiology Unit,
School of Social and Community Medicine, University of Bristol, UK.
 {browse "mailto:c.macdonald-wallis@bristol.ac.uk":c.macdonald-wallis@bristol.ac.uk}.{p_end}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}We thank Chris Charlton and George Leckie (Centre for Multilevel Modelling, University of Bristol) for very helpful comments.


{title:Also see}

{psee}
{space 2}Help:  {helpb reffadjustsim}, {helpb reffadjust4nlcom}, {helpb runmlwin} (if installed), {helpb mcmcsum} (if installed), {helpb nlcom}, {helpb mixed},
{helpb xtmixed}, {helpb meqrlogit}, {helpb xtmelogit}, {helpb meqrpoisson}, {helpb xtmepoisson}
{p_end}
