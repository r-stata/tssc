
{smcl}
{* *! version 1.0.1 7Feb2011}{...}
{cmd:help multipurt}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p 4 17 2}{cmd:multipurt} {hline 2} Running 1st and 2nd generation panel unit root tests for multiple variables and lags

{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:multipurt} {varname} {ifin} [{cmd:,} {cmd:lags(}{it:numlist}{cmd:)}]


{title:Description}

{p 4 4 2}{cmd:multipurt} runs the Maddala and Wu (1999) as well as the Pesaran (2007) panel unit root tests for multiple 
variables and lags. This is not a new command for these panel unit root tests but a convenient tool using the existing 
{help xtfisher} (if installed) and {help pescadf} (if installed) commands written by Scott Merryman and Piotr Lewandowski
respectively. The maximum number of variable or residual series to be tested is set to 9.

{p 4 4 2}The {cmd:multipurt} routine implements these two panel unit root tests building on Dickey-Fuller and Augmented 
Dickey-Fuller regressions for models with and without a trend term. 


{title:Details}

{p 4 4 2}The {cmd:Maddala and Wu (1999)} test assumes/allows for 
heterogeneity in the autoregressive coefficient of the Dickey-Fuller regression and ignores cross-section dependence in 
the data. Building on the Fisher-principle it constructs a chi-squared statistic, whereby the p-values of country-specific
(A)DF tests are transformed into logs and summed across panel members. Multiplied by -2 this sum is then distributed 
chi-squared with 2N degrees of freedom under the null of nonstationarity in all panel members/series. 

{p 4 4 2}The {cmd:Pesaran (2007)} CIPS test allows for assumes/allows for heterogeneity in the autoregressive coefficient of the 
Dickey-Fuller regression and 
allows for the presence of a single unobserved common factor with heterogeneous factor loadings in the data. The statistic 
is constructed from the results of panel-member-specific (A)DF regressions where cross-section averages of the dependent 
and independent variables (including the lagged differences to account for serial correlation) are included in the model (referred 
to as CADF regressions). The averaging of the group-specific results follows the procedure in the Im, Pesaran and Shin (2003) test. 
Under the null of nonstationarity the test statistic has a non-standard distribution.{p_end}

{p 4 4 2}The {cmd:pescadf} command used in this procedure will report an error message if there are gaps in 
the data. However, unless the number of observations missing in this fashion is large the Z-tbar test statistic can still be computed.


{title:Required options}

{pstd}{cmd:lags(}{it:numlist}{cmd:)} identifies the maximum number of lagged differences to be included in the group-specific 
Augmented Dickey Fuller regressions. The routine begins by omitting these augmentations (Dickey-Fuller regression: lags({it:0})), 
which are intended to capture the serial correlation in the data.


{title:Return values}

{col 4}Scalars
{col 8}{cmd:r(N_g)}{col 23}Number of panel groups
{col 8}{cmd:r(maxlags)}{col 23}Maximum number of lags to be included in the ADF regressions
{col 8}{cmd:r(N)}{col 23}Number of observations (evaluated before testing, i.e. does not 
{col 26}represent the number of observations in the DF and ADF regressions,
{col 26}which depends on lag-length selection)
{col 8}{cmd:r(avgobs)}{col 23}Average number of time series observations across panel members
{col 26}(same comment as above applies)

{col 4}Matrices
{col 8}{cmd:r(mw)}{col 23}Matrix containing the results for the Maddala and Wu (1999) test 
{col 26}without trend. The column order is as follows: # of lags,
{col 26}chi-sq statistic for variable 1, implied p-value for variable 1, 
{col 26}chi-sq statistic for variable 2, etc.
{col 8}{cmd:r(mw_trend)}{col 23}Matrix containing the results for the Maddala and Wu (1999) test 
{col 26}with trend. Same column order as above.
{col 8}{cmd:r(cips)}{col 23}Matrix containing the results for the Pesaran(2007) test 
{col 26}without trend. The column order is as follows: # of lags,
{col 26}Z-tbar statistic for variable 1, implied p-value for 
{col 26}variable 1, t-bar statistic for variable 1, Z-tbar statistic 
{col 26}for variable 2, etc.
{col 8}{cmd:r(cips_trend)}{col 23}Matrix containing the results for the Pesaran(2007) test 
{col 26}with trend. Same column order as above.

{col 4}Macros
{col 8}{cmd:r(varname)}{col 23}Names of variables or residual series tested


{title:Example}

{p 0 0 2}Download FAO production {browse "http://sites.google.com/site/medevecon/publications-and-working-papers/agri_stata9.zip":data} (zipped file) 
for the agriculture sector in 128 countries (1961-2002, unbalanced). See Eberhardt and Teal (2010) for details on data construction and deflation.
Cross-country growth empirics are reviewed in Eberhardt and Teal (2011).

{p 0 0 2}Variables used in illustration: ly log value-added per worker, ltr log tractors per worker, 
llive log livestock per worker, lf log fertilizer per worker, ln log land per worker 
(all with reference to the agricultural sector). Note that the dataset is quite large, such that it may be advisable (but not required) to 
increase the memory and matsize {it:before} loading the data (e.g. {stata "set mem 100m": .set mem 100m}, {stata "set matsize 8000": .set matsize 8000}). The 
routine also works with a much more modest memory and matsize allocation.

{p 0 4 2}Once the dataset is loaded into the program, set the panel dimensions: time variable - year, country identifier - clist2.{p_end}
{p 4 8 2}{stata "tsset clist2 year": .tsset clist2 year}

{p 0 4 2}Investigate stationarity in the production function variables. We limit the analysis to the first 20 countries (results for the full N=128 sample
-if !missing(clist2) & sample==1- can take several minutes to compute){p_end}
{p 4 8 2}{stata "multipurt ly ltr llive lf ln if clist2<21 & sample==1, lags(4)": .multipurt ly ltr llive lf ln if clist2<21 & sample==1, lags(4)}


{title:References}

{p 0 4 2}Eberhardt, Markus and Francis Teal (2011) 'Econometrics for Grumblers: A New Look at the Literature 
on Cross-Country Growth Empirics', {it:Journal of Economic Surveys}, Vol.25(1), pp.109–155.

{p 0 4 2}Eberhardt, Markus and Francis Teal (2010) 'Mangos in the Tundra? Spatial Heterogeneity in 
Agricultural Productivity Analysis', Centre for the Study of African Economies, University of Oxford,
unpublished working paper, available {browse "http://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Im, K, Hashem Pesaran and Yeongchol Shin (2003) 'Testing for unit roots in heterogeneous panels', 
{it:Journal of Econometrics}, Vol.115(1), pp.53-74.

{p 0 4 2}Maddala, G.S. and S. Wu (1999) 'A comparative study of unit root tests with panel data and a new simple test',
{it:Oxford Bulletin of Economics and Statistics}, Vol.61(Special Issue), pp.631-652.


{title:Acknowledgements and Disclaimer}

{p 0 0 2}This routine uses some clever practices for data handling taken from Damiaan Persyn's {help xtwest} (if installed) command. 
It furthermore employs the panel unit root tests implemented in Stata by Scott Merryman {help xtfisher} (if installed) and Piotr 
Lewandowski {help pescadf} (if installed) and also uses some of these authors' data handling routines. Users should refer to these help files for more details and acknowledge the authors of the 
commands. Thanks to Kit Baum for help and support. Any errors are of course my own.


{title:Author}

{browse "http://sites.google.com/site/medevecon":Markus Eberhardt}
Centre for the Study of African Economies
Department of Economics
University of Oxford
Manor Road, Oxford OX1 3UQ
{browse "mailto:markus.eberhardt@economics.ox.ac.uk":markus.eberhardt@economics.ox.ac.uk} 


{title:Also see}

{p 0 8 2}Online: help for {help xtfisher} (if installed), {help pescadf} (if installed),  {help ipshin} (if installed)

