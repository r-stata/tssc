
{smcl}
{* *! version 1.0.0 May2014}{...}
{cmd:help xtcsi}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtcsi} {hline 2} Investigating Residual Cross-Section Independence
{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:xtcsi} {depvar} {indepvars} {ifin} [{cmd:,} {cmd:trend} ]


{title:Description}

{p 4 4 2}{cmd:xtcsi} implements in balanced panel time-series data, error test for cross-section independence: i) the Breusch and Pagan (1980) LM test; 
ii) the Pesaran, Ullah and Yamagata (2008) bias-adjusted LM test; iii) the Pesaran (2004) CD test.

The null hypothesis is:

H0: Cov(uit,ujt) = 0 for all t and i!=j

{p 4 4 2}{cmdab:Background:}

{p 4 4 2}Cross-section dependence in macro panel data has received a lot of attention in the emerging panel 
time series literature over the past decade (for an introduction to panel time series see Eberhardt, 2009). 
This type of correlation may arise from globally common shocks with heterogeneous impact across countries, 
such as the oil crises in the 1970s or the global financial
crisis from 2007 onwards. Alternatively it can be the result of local spillover effects between countries or 
regions. For a detailed discussion of the topic within cross-country empirics see Eberhardt and Teal (2011). 
For a survey and application of existing cross-section dependence tests refer to Moscone and Tosetti (2009).


{title:Options}

{p 4 4 2}{cmd:trend} specifies a group-specific linear trend to be included in the regression model.

{title:Return values}

{col 4}Scalars
{col 8}{cmd:r(N_g)}{col 27}Number of panel members
{col 8}{cmd:r(lm)}{col 27}Breusch and Pagan (1980) LM test statistic
{col 8}{cmd:r(p_lm)}{col 27}p-value of chi-squared with N(N -1)/2 degrees of freedom
{col 8}{cmd:r(lm_adj)}{col 27}Pesaran, Ullah and Yamagata (2008) bias-adjusted LM test statistic
{col 8}{cmd:r(p_lm_adj)}{col 27}two-sided p-value of Normal(0,1)
{col 8}{cmd:r(lm_cd)}{col 27}Pesaran (2004) CD test statistic
{col 8}{cmd:r(p_lm_cd)}{col 27}two-sided p-value of Normal(0,1)

{title:Other packages needed}
{browse "https://ideas.repec.org/c/boc/bocode/s456713.html":matpwcorr}
{browse "https://ideas.repec.org/c/boc/bocode/s457238.html":xtmg}


{title:References}

{p 0 4 2}Pesaran, Ullah and Yamagata (2008). "A bias-adjusted LM test of error cross-section independence."
Econometrics Journal, volume 11, pp. 105–127.


{title:Acknowledgements}

{p 0 0 2}This routine was made with the helpful advice of Tamara Burdisso. Any errors are my own.


{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}

{title:Also see}

Online: help for {help xtcsd} (if installed), {help xtmg} (need to be installed)
