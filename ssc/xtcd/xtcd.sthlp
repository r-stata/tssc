
{smcl}
{* *! version 1.0.0 5Feb2011}{...}
{cmd:help xtcd}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtcd} {hline 2} Investigating Variable/Residual Cross-Section Dependence
{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:xtcd} {varlist} {ifin} [{cmd:,} {cmd:resid} {cmd:off}]


{title:Description}

{p 4 4 2}{cmd:xtcd} implements the Pesaran (2004) CD test for cross-section dependence in panel time-series data.
The routine performs {it:the same CD test} as the {cmd:xtcsd {it:varname}, pesaran} command by De Hoyos and Sarafidis (2006) 
but (i) allows for multiple variable series to be tested at the same time and (ii) is {it:not} a post-estimation command: {cmd:xtcd} can be applied to variable series (e.g. pre-estimation 
analysis of cross-section dependence in the data) as well as to residuals, provided these have been previously 
computed as a separate variable series (see example below).


{p 4 4 2}{cmdab:Background:}

{p 4 4 2}Cross-section dependence in macro panel data has received a lot of attention in the emerging panel 
time series literature over the past decade (for an introduction to panel time series see Eberhardt, 2009). 
This type of correlation may arise from globally common shocks with heterogeneous impact across countries, 
such as the oil crises in the 1970s or the global financial
crisis from 2007 onwards. Alternatively it can be the result of local spillover effects between countries or 
regions. For a detailed discussion of the topic within cross-country empirics see Eberhardt and Teal (2011). 
For a survey and application of existing cross-section dependence tests refer to Moscone and Tosetti (2009).


{p 4 4 2}{cmdab:Empirical Implementation:}

{p 4 4 2}The Pesaran CD-test employs the correlation-coefficients between the time-series for each panel member. 
In the example dataset for N=128 countries, for instance, this would be the 128 x 127 correlations between 
country i and all other countries, for i=1 to N-1. Referring to these estimated correlation coefficient between 
the time-series for country i and j as rho*_ij the Pesaran CD statistic is then computed as

{col 8}CD = sqrt[2/(N(N-1))] * [SUM_(i=1 to N-1) SUM_(j=i+1 to N) sqrt(T_ij rho*_ij)]

{p 4 4 2}where T_ij is the number of observations for which the correlation coefficient was computed. Since macro 
panel data is frequently unbalanced we only present the above equation appropriate for both balanced and 
unbalanced panels. Under the null hypothesis of cross-section independence the above statistics is distributed 
standard normal for T_ij>3 and N sufficiently large. The test is robust to nonstationarity (the spuriousness would 
show up in the averaging), parameter heterogeneity or structural breaks and was shown to perform well even in small 
samples. 


{title:Options}

{p 4 4 2}{cmd:resid} identifies the data series tested as residuals. This leads to a small transformation in the data series 
to allow for unbalancedness in the panel: imagine a panel which includes one group for which only 20 time-series 
observations are available, whereas for another group this number amounts to 40. If these are residual series from 
group-specific regressions, as is often the case in panel time series empirics, then the residuals will have been 
minimised over the time horizon, i.e. in the above example the residuals in the samples with T_1=20 and T_2=40 will 
average to zero (or close to zero) respectively. Imagine now that these two time series only overlap for T_12=10 years, 
since T_1 starts earlier than T_2 and the latter obviously stretches much more into the present than the former. In 
order to avoid distortions arising from the residuals for the two samples over the T_12 time horizon not to average to 
zero we first compute the deviations of each residual series from the time-series mean over the T_12 horizon before 
computing the correlation coefficient. {it:Note:} this option only makes a difference if the residuals are from a 
heterogeneous panel model (see example). The computations presently take somewhat longer than for the standard approach.

{p 4 4 2}{cmd:off} turns off the output table. 


{title:Return values}

{col 4}Scalars
{col 8}{cmd:r(N_g)}{col 27}Number of panel members

{col 4}Matrices
{col 8}{cmd:r(nobs)}{col 27}Total number of obs used in the correlations (N x (N-1) x T_ij)
{col 8}{cmd:r(avgcorr)}{col 27}Averaged correlation coefficient
{col 8}{cmd:r(abscorr)}{col 27}Averaged absolute correlation coefficient
{col 8}{cmd:r(pesaran)}{col 27}Pesaran CD-statistic
{col 8}{cmd:r(numb_coeff)}{col 27}Number of correlations computed 
{col 8}{cmd:r(avg_obs)}{col 27}Average number of observations for each correlation

{col 4}Macros
{col 8}{cmd:r(varname)}{col 27}Name(s) of variable or residual series tested


{title:Example}

{p 0 0 2}Download FAO production {browse "https://sites.google.com/site/medevecon/publications-and-working-papers/agridata.zip?attredirects=0":data} 
for the agriculture sector in 128 countries (1961-2002, unbalanced). See Eberhardt and Teal (2010) for more details on data construction and deflation.

{p 0 0 2}Variables used in illustration: ly log value-added per worker, ltr log tractors per worker, 
llive log livestock per worker, lf log fertilizer per worker, ln log land per worker 
(all with reference to the agricultural sector). Note that the dataset is very large, such that it would be advisable to 
increase the memory and matsize {it:before} loading the data.

{p 4 8 0}{stata "clear": .clear}{p_end}
{p 4 8 0}{stata "set mem 100m": .set mem 100m}{p_end}
{p 4 8 0}{stata "set matsize 8000": .set matsize 8000}

{p 0 4 2}Once the dataset is loaded into the program, set the panel dimensions: time variable - year, country identifier - clist2{p_end}
{p 4 8 2}{stata "tsset clist2 year": .tsset clist2 year}

{p 0 4 2}Investigate cross-section dependence in log agricultural value-added per worker{p_end}
{p 4 8 2}{stata "xtcd ly": .xtcd ly}

{p 0 4 2}Investigate cross-section dependence in all production function variables{p_end}
{p 4 8 2}{stata "xtcd ly ltr llive lf ln": .xtcd ly ltr llive lf ln}

{p 0 4 2}Compute the residuals from an OLS production function with time fixed effects and test the residuals 
for cross-section dependence.{p_end}
{p 4 8 2}{stata "xi: reg ly ltr llive lf ln i.year": .xi: reg ly ltr llive lf ln i.year}{p_end}
{p 4 8 2}{stata "predict ols_res if e(sample), res": .predict ols_res if e(sample), res}{p_end}
{p 4 8 2}{stata "xtcd ols_res, resid": .xtcd ols_res, resid}{p_end}

{p 0 4 2}Compute the residuals from a heterogeneous parameter production function using the Pesaran & Smith (1995) Mean Group
estimator ({help xtmg} if installed) with a country-specific linear trend. Then test the residuals for cross-section independence{p_end}
{p 4 8 2}{stata "xtmg ly ltr llive lf ln, trend robust res(mg_res)": .xtmg ly ltr llive lf ln, trend robust res(mg_res)}{p_end}
{p 4 8 2}{stata "xtcd mg_res, resid": .xtcd mg_res, resid}{p_end}

{p 0 4 2}Compute the residuals from a heterogeneous parameter production function using the Pesaran (2006) CCE Mean Group
estimator ({help xtmg} if installed) and then test the residuals{p_end}
{p 4 8 2}{stata "xtmg ly ltr llive lf ln, cce robust res(cce_res)": .xtmg ly ltr llive lf ln, cce robust res(cce_res)}{p_end}
{p 4 8 2}{stata "xtcd cce_res, resid": .xtcd cce_res, resid}


{title:References}

{p 0 4 2}Eberhardt, Markus (2009) 'Nonstationary Panel Econometrics and Common Factor Models: An Introductory 
Reader', unpublished mimeo, available from {browse "https://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Eberhardt, Markus and Francis Teal (2011) 'Econometrics for Grumblers: A New Look at the Literature 
on Cross-Country Growth Empirics', {it:Journal of Economic Surveys}, Vol.25(1), pp.109–155.

{p 0 4 2}Eberhardt, Markus and Francis Teal (2010) 'Mangos in the Tundra? Spatial Heterogeneity in 
Agricultural Productivity Analysis', Centre for the Study of African Economies, University of Oxford,
unpublished working paper, available {browse "http://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Moscone, Francesco and Elisa Tosetti (2009) 'A Review And Comparison Of Tests Of Cross-Section 
Independence In Panels', {it:Journal of Economic Surveys}, Vol. 23(3), pp.528-561.

{p 0 4 2}Pesaran, M. Hashem (2004) General Diagnostic Tests for Cross Section Dependence in Panels'
IZA Discussion Paper No. 1240.

{p 0 4 2}Pesaran, M. Hashem (2006) 'Estimation and inference in large heterogeneous panels with a multifactor 
error structure.' {it:Econometrica}, Vol. 74(4): pp.967-1012.


{title:Acknowledgements and Disclaimer}

{p 0 0 2}This routine builds to a {it:very} large extent on the existing code for the Pesaran (2004) CD test 
({help xtcsd}) by De Hoyos and Sarafidis (2006). Users should refer to their help 
file for more details and acknowledge these authors. Any errors are of course my own.


{title:Author}

{browse "http://sites.google.com/site/medevecon":Markus Eberhardt}
Centre for the Study of African Economies
Department of Economics
University of Oxford
Manor Road, Oxford OX1 3UQ
{browse "mailto:markus.eberhardt@economics.ox.ac.uk":markus.eberhardt@economics.ox.ac.uk} 


{title:Also see}

Online: help for {help xtcsd} (if installed), {help xtmg} (if installed)
