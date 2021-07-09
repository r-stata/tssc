{smcl}
{hline}
index of NJC's Stata stuff (version 1 July 2020)
{hline}

{title:Description}

{p 4 4 2}This is a list of my Stata packages or commands that are in the public
domain. Most commonly you might want to search this file in the Viewer. If a
help file is not accessible to you, use {help search} to find out where the
files are. The help files carry details on people who kindly reported bugs or
made useful suggestions. What I regard as my best packages and commands are
listed thematically at {help njc_best_stuff:NJC best stuff}. 


{title:Contributor to official Stata commands}

{space 4}command             version added
{space 4}{hline 33} 
{space 4}
{space 4}{help dataex}              14.2, 15.1 update 
{space 4}{help clonevar}            8 update 
{space 4}{help tostring}            8 update 
{space 4}{help ci}                  8 update (advisor) 
{space 4}{help cumul}               8 update 
{space 4}{help ds}                  8 update 
{space 4}{help levels}              8 update ({help levelsof} in 9 up)   
{space 4}{help duplicates}          8 
{space 4}{help split}               8 
{space 4}{help ssc}                 7 update 
{space 4}{help findit}              7 update 
{space 4}{help destring}            7 
{space 4}{help egen}                7 
{space 4}{help contract}            6
{space 4}{help separate}            6 
{space 4}{help serrbar}             6 
{space 4}{help spikeplot}           6


{title:Packages} 

{space 4}OS means official Stata
{space 4}obs means obsolete
{space 4}pobs means partially obsolete
{space 4}sup means superseded
{space 4}psup means partially superseded
{space 4}+ means good
{space 4}judgements assume availability of Stata 15 

{space 4}{help aaplot}
{space 4}SSC (NJC)
{space 4}scatter plot with linear and/or quadratic fit, automatically annotated
{space 4}+ 

{space 4}{help acplot}
{space 4}SSC (NJC)
{space 4}autocorrelogram plots
{space 4}obs(OS ac)

{space 4}{help adjacent}
{space 4}SSC (NJC)
{space 4}list adjacent values of variables

{space 4}{help adotype}
{space 4}SSC (NJC)
{space 4}type ado file
{space 4}pobs(OS findfile)

{space 4}{help allpossible}
{space 4}SSC (NJC)
{space 4}fit all possible models with subsets of predictors

{space 4}{help archutil}
{space 4}ip29 stb52 (C.F. Baum, NJC)
{space 4}utilities for using SSC archive (1)
{space 4}obs(OS ssc)

{space 4}{help archutil}
{space 4}ip29_1 stb54 (NJC, C.F. Baum)
{space 4}utilities for using SSC archive (2)
{space 4}obs(OS ssc)

{space 4}{help asciiplot}
{space 4}SSC (M. Blasnik, S. Juul, NJC)
{space 4}graph ASCII character set in current graph font
{space 4}pobs(OS Unicode support) 

{space 4}{help avplot2}
{space 4}SSC (NJC)
{space 4}added variable plots
{space 4}sup(favplots)

{space 4}{help bandplot} 
{space 4}SSC (NJC) 
{space 4}plot summary statistics of responses for bands of predictors
{space 4}psup(designplot)

{space 4}{help barplot}
{space 4}SSC (NJC)
{space 4}bar plots
{space 4}obs(OS graph)

{space 4}{help barplot2}
{space 4}SSC (NJC)
{space 4}bar plots with optional error bars
{space 4}obs(OS graph)

{space 4}{help bcoeff}
{space 4}SSC (Z. Wang, NJC)
{space 4}save regression coefficients to new variable
{space 4}pobs(OS statsby)

{space 4}{help beamplot}
{space 4}SSC (NJC)
{space 4}horizontal dotplots using beams

{space 4}{help betafit}
{space 4}SSC (M.L. Buis, NJC, S.P. Jenkins)
{space 4}fit two-parameter beta distribution
{space 4}psup(OS betareg)

{space 4}{help bincoverage}
{space 4}www.stata.com/users/rgutierrez (R.G. Gutierrez, NJC)
{space 4}true coverage probabilities for binomial confidence intervals

{space 4}{help binsm}
{space 4}gr26 stb37 (NJC)
{space 4}bin smoothing and summary on scatter plots
{space 4}sup(SJ 6-1)

{space 4}{help binsm}
{space 4}gr26_1 sj6-1 (NJC)
{space 4}bin smoothing and summary on scatter plots (2)
{space 4}+

{space 4}{help biv}
{space 4}ip26 stb45 (NJC)
{space 4}bivariate results for each pair of variables in a list
{space 4}sup(makematrix)

{space 4}{help bkrosenblatt}
{space 4}SSC (NJC)
{space 4}Blum, Kiefer and Rosenblatt test of bivariate independence
{space 4}+

{space 4}{help blogit2}
{space 4}SSC (NJC)
{space 4}grouped data logit with support for {help in}
{space 4}obs(OS blogit)

{space 4}{help bsmplot}
{space 4}gr22 stb35 (NJC)
{space 4}binomial smoothing plots (1) 
{space 4}sup(SJ 4-4)

{space 4}{help bsmplot}
{space 4}gr22_1 sj4-4 (NJC)
{space 4}binomial smoothing plots (2)

{space 4}{help catenate}
{space 4}SSC (NJC)
{space 4}concatenate variables into string variable
{space 4}obs(OS egen)

{space 4}{help catplot}
{space 4}SSC (NJC)
{space 4}plots of frequencies, fractions or percents of categorical data
{space 4}+

{space 4}{help cbarplot}
{space 4}SSC (NJC)
{space 4}centred bar plots of absolute or relative frequencies 

{space 4}{help cfvars} 
{space 4}SSC (NJC)
{space 4}compare variable name lists in two data sets

{space 4}{help chaos}
{space 4}SSC (NJC)
{space 4}iterate a logistic difference equation

{space 4}{help charlist}
{space 4}SSC (NJC)
{space 4}list characters present in string variable
{space 4}+

{space 4}{help charutil}
{space 4}SSC (NJC)
{space 4}utilities for working with characteristics

{space 4}{help chplot}
{space 4}gr16_1 stb36 (NJC)
{space 4}convex hull plots

{space 4}{help cibplot}
{space 4}SSC (NJC)
{space 4}bar-on-bar plots of confidence intervals

{space 4}{help cihplot}
{space 4}SSC (NJC)
{space 4}horizontally labelled plots showing confidence intervals
{space 4}obs(ciplot)

{space 4}{help cij}
{space 4}SSC (NJC)
{space 4}binomial confidence intervals using Jeffreys prior
{space 4}pobs(OS ci)

{space 4}{help ciplot}
{space 4}SSC (NJC)
{space 4}plots of confidence intervals
{space 4}+

{space 4}{help cipolate}
{space 4}SSC (NJC)
{space 4}cubic interpolation
{space 4}sup(SSC mipolate)

{space 4}{help circstat}
{space 4}www.stata.com/users/njc (NJC)
{space 4}circular statistics (1) 
{space 4}sup(SSC circular)

{space 4}{help circstat}
{space 4}SSC (NJC)
{space 4}circular statistics (2)
{space 4}sup(SSC circular)

{space 4}{help circular}
{space 4}SSC (NJC)
{space 4}circular statistics (3; for Stata 8 up)
{space 4}+

{space 4}{help cistat}
{space 4}SSC (NJC)
{space 4}confidence intervals in matrix form

{space 4}{help civplot}
{space 4}SSC (NJC)
{space 4}plot confidence intervals vertically
{space 4}obs(ciplot)

{space 4}{help ciw}
{space 4}SSC (NJC)
{space 4}binomial confidence intervals using Wilson scores
{space 4}obs(OS ci)

{space 4}{help collfreq}
{space 4}dm59 stb44 (NJC)
{space 4}collapsing datasets to frequencies
{space 4}sup(OS contract)

{space 4}{help combineplot} 
{space 4}SSC (NJC)
{space 4}combine similar univariate or bivariate plots for different variables 
{space 4}+

{space 4}{help concord}
{space 4}sg84 stb43 (T.J. Steichen, NJC)
{space 4}concordance correlation (1)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}sg84_1 stb45 (T.J. Steichen, NJC)
{space 4}concordance correlation (2)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}sg84_2 stb54 (T.J. Steichen, NJC)
{space 4}concordance correlation (3)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}sg84_3 stb58 (T.J. Steichen, NJC)
{space 4}concordance correlation (4)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015 sj2-2 (T.J. Steichen, NJC)
{space 4}concordance correlation (5)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}SSC (T.J. Steichen, NJC)
{space 4}concordance correlation (6)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_1 sj4-4 (T.J. Steichen, NJC)
{space 4}concordance correlation (7)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_2 sj5-3 (T.J. Steichen, NJC)
{space 4}concordance correlation (8)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_3 sj6-2 (T.J. Steichen, NJC)
{space 4}concordance correlation (9)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_4 sj7-3 (T.J. Steichen, NJC)
{space 4}concordance correlation (10)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_5 sj8-4 (T.J. Steichen, NJC)
{space 4}concordance correlation (11)
{space 4}sup(SJ 10-4)

{space 4}{help concord}
{space 4}st0015_6 sj10-4 (T.J. Steichen, NJC)
{space 4}concordance correlation (12)
{space 4}+

{space 4}{help condraw}
{space 4}gr16_2 stb41 (J.P. Gray, NJC)
{space 4}convex hull plots

{space 4}{help copydesc}
{space 4}SSC (NJC)
{space 4}copy description of variable
{space 4}pobs(OS clonevar)

{space 4}{help corrci}, {help corrcii} 
{space 4}pr0041 sj8-3 (NJC) 
{space 4}correlation with z-based confidence intervals (1)  
{space 4}sup(SJ 17-3) 

{space 4}{help corrci}, {help corrcii} 
{space 4}pr0041_1 sj10-4 (NJC) 
{space 4}correlation with z-based confidence intervals (2) 
{space 4}sup(SJ 17-3

{space 4}{help corrci}, {help corrcii} 
{space 4}pr0041_2 sj17-3 (NJC) 
{space 4}correlation with z-based confidence intervals (3) 
{space 4}+

{space 4}{help corrtable} 
{space 4}SSC (NJC) 
{space 4}correlation matrix as graphical table 
{space 4}+

{space 4}{help countmatch}
{space 4}SSC (NJC)
{space 4}count matching values for one variable in another

{space 4}{help cp}
{space 4}ip27 stb45 (NJC)
{space 4}results for all possible combinations of arguments
{space 4}sup(cpr)/pobs(foreach, forval)

{space 4}{help cpcorr}
{space 4}SSC (NJC)
{space 4}correlations for each row vs each column variable
{space 4}+

{space 4}{help cpr}
{space 4}SSC (NJC)
{space 4}results for all possible combinations of arguments
{space 4}pobs(foreach, forval)

{space 4}{help cpyxplot}
{space 4}www.stata.com/users/njc (NJC)
{space 4}scatter plots for each y vs each x variable (1) 
{space 4}obs(crossplot)

{space 4}{help cpyxplot}
{space 4}SSC (NJC)
{space 4}scatter plots for each y vs each x variable (2) 
{space 4}obs(crossplot) 

{space 4}{help cquantile}
{space 4}SSC (NJC)
{space 4}generate corresponding quantiles

{space 4}{help crossplot}
{space 4}SSC (NJC) 
{space 4}scatter (or other twoway) plots for each y vs each x variable 
{space 4}+

{space 4}{help csipolate}
{space 4}SSC (NJC) 
{space 4}cubic spline interpolation 
{space 4}sup(SSC mipolate)

{space 4}{help ctabstat}
{space 4}SSC (NJC)
{space 4}table of summary statistics

{space 4}{help cycleplot}
{space 4}SSC (NJC)
{space 4}cycle plots (month plots or seasonal subseries plots)
{space 4}see also SJ 6-3

{space 4}{help cycleplot}, {help sliceplot}
{space 4}gr0025 sj6-3 (NJC)
{space 4}cycle plot, slice plot
{space 4}+

{space 4}{help dataex} 
{space 4}SSC (R. Picard, NJC) 
{space 4}generate a properly formatted data example for Statalist
{space 4}+

{space 4}{help dataex} 
{space 4}Stata 14.2+, 15.1+ (R. Picard, NJC) 
{space 4}generate a properly formatted data example for Statalist
{space 4}+

{space 4}{help depthplot}, {help wallplot} 
{space 4}SSC (NJC) 
{space 4}plot one or more variables with depth as vertical axis 
{space 4}+ 

{space 4}{help designplot}
{space 4}SSC (NJC) 
{space 4}graphical summary of response given one or more factors (1)  
{space 4}sup(SJ 19-3)

{space 4}{help designplot}
{space 4}gr0061 sj14-4 (NJC) 
{space 4}graphical summary of response given one or more factors (2) 
{space 4}sup(SJ 19-3) 

{space 4}{help designplot}
{space 4}gr0061_1 sj15-2 (NJC) 
{space 4}graphical summary of response given one or more factors (3) 
{space 4}sup(SJ 19-3) 

{space 4}{help designplot}
{space 4}gr0061_2 sj17-3 (NJC) 
{space 4}graphical summary of response given one or more factors (4) 
{space 4}sup(SJ 19-3)

{space 4}{help designplot}
{space 4}gr0061_3 sj19-3 (NJC) 
{space 4}graphical summary of response given one or more factors (5) 
{space 4}+

{space 4}{help destring}
{space 4}dm45 stb37 (NJC, W. Gould)
{space 4}change string variables to numeric (1)
{space 4}sup(OS destring)

{space 4}{help destring}
{space 4}dm45_1 stb49 (NJC)
{space 4}change string variables to numeric (2)
{space 4}sup(OS destring)

{space 4}{help destring}
{space 4}dm45_2 stb52 (NJC)
{space 4}change string variables to numeric (3)
{space 4}sup(OS destring)

{space 4}{help devnplot}
{space 4}SSC (NJC)
{space 4}deviation plots
{space 4}see now stripplot (SSC) for main idea 

{space 4}{help diagsm}, {help doublesm}, {help polarsm} 
{space 4}gr0021 sj5-4 (NJC)
{space 4}diagonal, double and polar smoothing
{space 4}sup(SJ 10-1) 

{space 4}{help diagsm}, {help doublesm}, {help polarsm} 
{space 4}gr0021_1 sj10-1 (NJC)
{space 4}diagonal, double and polar smoothing
{space 4}sup(SJ 15-4) 

{space 4}{help diagsm}, {help doublesm}, {help polarsm} 
{space 4}gr0021_2 sj15-4 (NJC)
{space 4}diagonal, double and polar smoothing
{space 4}+               

{space 4}{help diplot}
{space 4}SSC (NJC)
{space 4}double interval plot

{space 4}{help diptest} 
{space 4}SSC (NJC) 
{space 4}dip statistic to test for unimodality
{space 4}+

{space 4}{help dirifit}
{space 4}SSC (M.L. Buis, NJC, S.P. Jenkins)
{space 4}fit Dirichlet distribution
{space 4}+ 

{space 4}{help disjoint}
{space 4}SSC (NJC)
{space 4}demarcating disjoint spells

{space 4}{help dissim}
{space 4}SSC (NJC)
{space 4}dissimilarity index

{space 4}{help distinct}
{space 4}SSC (G. Longton, NJC)
{space 4}display number of distinct values of variables
{space 4}+ 

{space 4}{help distinct}
{space 4}dm0042 sj8-4 (G. Longton, NJC)
{space 4}display number of distinct values of variables
{space 4}sup(SJ 12-2) 

{space 4}{help distinct}
{space 4}dm0042_1 sj12-2 (G. Longton, NJC)
{space 4}display number of distinct values of variables
{space 4}sup(SJ 15-3) 

{space 4}{help distinct}
{space 4}dm0042_2 sj15-3 (G. Longton, NJC)
{space 4}display number of distinct values of variables
{space 4}+            

{space 4}{help distplot}
{space 4}SSC (NJC)
{space 4}distribution function plots (1) 
{space 4}sup(SJ 19-1)

{space 4}{help distplot}
{space 4}gr41 stb51 (NJC)
{space 4}distribution function plots (2) 
{space 4}sup(SJ 19-1)

{space 4}{help distplot}
{space 4}gr41_1 sj3-2 (NJC)
{space 4}distribution function plots (3)
{space 4}sup(SJ 19-1)

{space 4}{help distplot}
{space 4}gr41_2 sj3-4 (NJC)
{space 4}distribution function plots (4)
{space 4}sup(SJ 19-1)

{space 4}{help distplot}
{space 4}gr41_3 sj5-3 (NJC)
{space 4}distribution function plots (5)
{space 4}sup(SJ 19-1) 

{space 4}{help distplot}
{space 4}gr41_4 sj10-1 (NJC)
{space 4}distribution function plots (6)
{space 4}sup(SJ 19-1) 

{space 4}{help distplot}
{space 4}gr41_5 sj19-1 (NJC)
{space 4}distribution function plots (7)
{space 4}+            

{space 4}{help dlist}
{space 4}SSC (NJC)
{space 4}list with variable labels

{space 4}{help domdiag}
{space 4}SSC (NJC)
{space 4}dominance diagrams
{space 4}+

{space 4}{help doubmass}
{space 4}SSC (NJC)
{space 4}double mass plots

{space 4}{help dpplot}
{space 4}SSC (NJC)
{space 4}density probability plots
{space 4}sup(SJ 7-4)

{space 4}{help dpplot}
{space 4}gr0012 sj5-2 (NJC)
{space 4}density probability plots
{space 4}sup(SJ 7-4)

{space 4}{help dpplot}
{space 4}gr0012_1 sj7-4 (NJC)
{space 4}density probability plots
{space 4}+

{space 4}{help dropmiss}
{space 4}dm89 stb60 (NJC)
{space 4}dropping variables or observations with missing values
{space 4}sup(missings) 

{space 4}{help dropmiss}
{space 4}dm89_1 sj8-4 (NJC)
{space 4}dropping variables or observations with missing values
{space 4}sup(missings)

{space 4}{help dropmiss}
{space 4}dm89_2 sj15-4 (NJC)
{space 4}dropping variables or observations with missing values
{space 4}sup(missings)

{space 4}{help ds2}
{space 4}SSC (NJC)
{space 4}describe variables in memory (for Stata 6)
{space 4}sup(OS ds, findname)

{space 4}{help ds2}
{space 4}dm78 stb56 (NJC)
{space 4}describe variables in memory (for Stata 6)
{space 4}sup(OS ds, findname)

{space 4}{help ds2}
{space 4}dm78_1 stb60 (NJC)
{space 4}describe variables in memory (for Stata 7)
{space 4}sup(OS ds, findname)

{space 4}{help ds3}
{space 4}SSC (NJC)
{space 4}describe variables in memory (for Stata 7)
{space 4}sup(OS ds, findname)

{space 4}{help ds5}
{space 4}SSC (NJC)
{space 4}describe variables in memory (for Stata 5)
{space 4}sup(OS ds, findname)

{space 4}{help dummies}
{space 4}SSC (NJC)
{space 4}families of dummy variables
{space 4}obs(foreach)

{space 4}{help dummieslab}
{space 4}SSC (P. van Kerm, NJC)
{space 4}dummy variables using value labels

{space 4}{help dups}
{space 4}SSC (T.J. Steichen, NJC)
{space 4}identify and optionally remove duplicate observations (1)
{space 4}sup(OS duplicates)

{space 4}{help dups}
{space 4}dm53 stb41 (T.J. Steichen, NJC)
{space 4}identify and optionally remove duplicate observations (2)
{space 4}sup(OS duplicates)

{space 4}egen extensions
{space 4}dm70 stb50 (NJC)
{space 4}{help egen} extensions)
{space 4}pobs(OS egen)

{space 4}egen extensions
{space 4}dm70_1 stb57 (NJC)
{space 4}{help egen} extensions (update)
{space 4}pobs(OS egen)

{space 4}egen rank
{space 4}dm72 stb51 (NJC, R. Goldstein)
{space 4}alternative ranking procedures
{space 4}sup(OS egen)

{space 4}egen rank
{space 4}dm72_1 stb52 (NJC, R. Goldstein)
{space 4}alternative ranking procedures (update)
{space 4}sup(OS egen)

{space 4}{help egenmore}
{space 4}SSC (NJC, C.F. Baum, U. Kohler, S. Stillman, N. Winter)
{space 4}more {help egen} functions
{space 4}+

{space 4}{help egenodd}
{space 4}www.stata.com/users/njc (NJC)
{space 4}{help egen} extensions
{space 4}sup(STB 50, 57)

{space 4}{help entropyetc}
{space 4}SSC (NJC)
{space 4}entropy and related measures for categories
{space 4}+

{space 4}{help eofplot}
{space 4}SSC (NJC)
{space 4}plot coefficients or loadings after principal component or factor analysis
{space 4}+

{space 4}{help eqprhistogram}
{space 4}SSC (NJC)
{space 4}equal probability histograms
{space 4}+

{space 4}{help ewma}
{space 4}SSC (NJC)
{space 4}exponentially weighted moving average
{space 4}obs(OS tssmooth)

{space 4}{help examples}
{space 4}SSC (NJC)
{space 4}show examples from on-line help files

{space 4}{help expandby}
{space 4}SSC (NJC)
{space 4}duplicate observations by variable

{space 4}{help extremes}
{space 4}SSC (NJC)
{space 4}list extreme values of a variable
{space 4}+

{space 4}{help fabplot}
{space 4}SSC (NJC)
{space 4}plots for each subset, rest of data as backdrop 
{space 4}+

{space 4}{help favplots}
{space 4}SSC (NJC)
{space 4}formatted added-variable plot(s)
{space 4}+ 

{space 4}{help fbar}
{space 4}SSC (NJC)
{space 4}bar charts showing frequencies of categorical variables
{space 4}obs(OS graph, catplot)

{space 4}{help fedit}
{space 4}SSC (NJC)
{space 4}find and edit text file from within Stata
{space 4}+

{space 4}{help filei} 
{space 4}SSC (NJC) 
{space 4}write lines to end or beginning of text files

{space 4}{help findname}
{space 4}SSC (NJC)
{space 4}list variables matching name patterns or other properties
{space 4}sup(SJ 20-2)

{space 4}{help findname}
{space 4}dm0048 sj10-2 (NJC) 
{space 4}list variables matching name patterns or other properties
{space 4}sup(SJ 20-2)

{space 4}{help findname}
{space 4}dm0048_1 sj10-4 (NJC) 
{space 4}list variables matching name patterns or other properties
{space 4}sup(SJ 20-2)

{space 4}{help findname}
{space 4}dm0048_2 sj12-1 (NJC) 
{space 4}list variables matching name patterns or other properties
{space 4}sup(SJ 20-2) 

{space 4}{help findname}
{space 4}dm0048_3 sj15-2 (NJC) 
{space 4}list variables matching name patterns or other properties
{space 4}sup(SJ 20-2) 

{space 4}{help findname}
{space 4}dm0048_4 sj20-2 (NJC) 
{space 4}list variables matching name patterns or other properties
{space 4}+

{space 4}{help firstdigit}
{space 4}SSC (NJC)
{space 4}first digits of numeric variables
{space 4}+

{space 4}{help fixsort}
{space 4}SSC (NJC)
{space 4}sort and align variables, others fixed in position
{space 4}+

{space 4}{help flower}
{space 4}SSC (T.J. Steichen, NJC)
{space 4}sunflower plots
{space 4}obs(OS graph)

{space 4}{help fndmtch}
{space 4}SSC (NJC, D.E. Williams)
{space 4}find matching values

{space 4}{help fndmtch2}
{space 4}SSC (NJC)
{space 4}find matching values for one variable in another
{space 4}sup(SSC countmatch)

{space 4}{help fractileplot}
{space 4}SSC (NJC)
{space 4}smoothing with respect to distribution function predictors
{space 4}+

{space 4}{help fs}
{space 4}SSC (NJC)
{space 4}show names of files in compact form
{space 4}+

{space 4}{help fsx}
{space 4}SSC (G. Rossman, NJC)
{space 4}show names of files in compact form (Unix variant) 

{space 4}{help gammafit}
{space 4}SSC (NJC, S.P. Jenkins)
{space 4}fit two-parameter gamma distribution
{space 4}+

{space 4}{help genfreq}
{space 4}SSC (NJC)
{space 4}frequency distribution for a variable
{space 4}obs(OS graph)

{space 4}{help ghistcum}
{space 4}SSC (C.F. Baum, NJC)
{space 4}histograms with cumulative distribution
{space 4}obs(OS graph)

{space 4}{help glmcorr}
{space 4}SSC (NJC)
{space 4}correlation measure of predictive power for GLMs
{space 4}+

{space 4}{help group1d}
{space 4}SSC (NJC)
{space 4}grouping or clustering in one dimension
{space 4}+

{space 4}{help groups}
{space 4}SSC (NJC)
{space 4}list group frequencies (1)
{space 4}+

{space 4}{help groups}
{space 4}st0496 sj17-3  (NJC)
{space 4}list group frequencies (2) 
{space 4}sup(SJ 18-1) 

{space 4}{help groups}
{space 4}st0496_1 sj18-1  (NJC)
{space 4}list group frequencies (3)
{space 4}+

{space 4}{help gumbelfit}
{space 4}SSC (NJC, S.P. Jenkins)
{space 4}fit two-parameter Gumbel distribution
{space 4}+

{space 4}{help hansen2}
{space 4}SSC (NJC)
{space 4}Hansen's test for parameter instability

{space 4}{help hbar}
{space 4}SSC (NJC)
{space 4}horizontal bar charts
{space 4}obs(OS graph)

{space 4}{help hbox}
{space 4}SSC (NJC)
{space 4}horizontal box plots
{space 4}obs(OS graph)

{space 4}{help hdquantile}
{space 4}SSC (NJC)
{space 4}Harrell-Davis estimator of quantiles
{space 4}+

{space 4}{help histplot}
{space 4}SSC (NJC)
{space 4}histograms
{space 4}obs(OS graph)

{space 4}{help hlist}
{space 4}SSC (NJC)
{space 4}horizontally listing values

{space 4}{help hlpdir}
{space 4}SSC (NJC)
{space 4}find location(s) of help file
{space 4}pobs(OS findfile)

{space 4}{help hplot}
{space 4}SSC (NJC)
{space 4}horizontal plots
{space 4}obs(OS graph)

{space 4}{help hsmode}
{space 4}SSC (NJC)
{space 4}half-sample modes
{space 4}+

{space 4}{help ineq}
{space 4}SSC (NJC)
{space 4}measures of inequality
{space 4}pobs(SSC entropyetc) 

{space 4}{help invgammafit}
{space 4}SSC (NJC, S.P. Jenkins)
{space 4}fit two-parameter inverse gamma distribution
{space 4}+

{space 4}{help invgaussfit}
{space 4}SSC (NJC, S.P. Jenkins)
{space 4}fit two-parameter inverse Gaussian distribution
{space 4}+

{space 4}{help iquantile}
{space 4}SSC (NJC) 
{space 4}interpolated quantiles 
{space 4}+ 

{space 4}{help irrepro}
{space 4}SSC (NJC)
{space 4}simulation of irreproducible results

{space 4}{help isvar}
{space 4}SSC (NJC)
{space 4}filter names into variable names and others

{space 4}{help kaplansky}
{space 4}SSC (NJC)
{space 4}graph examples of distributions of varying kurtosis
{space 4}+

{space 4}{help kernreg2}
{space 4}SSC (NJC, I.H. Salgado-Ugarte, M. Shimizu, T. Taniuchi)
{space 4}kernel regression (Nadaraya-Watson estimator)
{space 4}obs(OS lpoly)

{space 4}{help keyplot}
{space 4}SSC (NJC)
{space 4}scatter plots with keys in user-chosen positions
{space 4}obs(OS graph)

{space 4}{help labellacking} 
{space 4}SSC (NJC, R. Picard) 
{space 4}report numeric variables with values lacking value labels

{space 4}{help labgen}
{space 4}SSC (NJC) 
{space 4}generate or replace variables with definitions copied to variable labels

{space 4}{help labmask}
{space 4}gr0034 sj8-2 (NJC) 
{space 4}values or value labels of one variable as value labels of another
{space 4}+

{space 4}{help labutil}
{space 4}SSC (NJC)
{space 4}managing value and variable labels

{space 4}{help lambda}
{space 4}SSC (NJC)
{space 4}Goodman and Kruskal's lambda measures for two-way tables

{space 4}{help levels}
{space 4}SSC (NJC)
{space 4}distinct levels of integer or string variable
{space 4}sup(OS levelsof)

{space 4}{help linkplot}
{space 4}SSC (NJC)
{space 4}linked (connected) scatter plots
{space 4}+ (note also OS pcarrow, etc.)

{space 4}{help listutil}
{space 4}SSC (NJC)
{space 4}manipulate lists of words
{space 4}pobs(OS foreach, forval, macrolists)

{space 4}{help ljs}
{space 4}SSC (NJC)
{space 4}left-justify string variables for printing
{space 4}obs(OS format)

{space 4}{help lmoments}
{space 4}SSC (NJC)
{space 4}L-moments and derived statistics
{space 4}+

{space 4}{help localp}
{space 4}SSC (NJC) 
{space 4}kernel-weighted local polynomial smoothing 
{space 4}+

{space 4}{help log2html}
{space 4}SSC (C.F. Baum, NJC, B. Rising)
{space 4}produce HTML log files

{space 4}{help longplot}
{space 4}SSC (Z. Wang, NJC)
{space 4}exploratory plots for longitudinal data
{space 4}pobs(linkplot, OS)

{space 4}{help longshape}
{space 4}SSC (NJC)
{space 4}reshape to long (limited alternative)
{space 4}+ 

{space 4}{help loopplot}
{space 4}SSC (NJC)
{space 4}scatter plots with loops

{space 4}{help lstack}
{space 4}SSC (NJC)
{space 4}{help stack} variables with labelled _stack

{space 4}{help lvalues}
{space 4}SSC (NJC)
{space 4}letter value calculation             
{space 4}sup(SJ 16-4)

{space 4}{help lvalues}
{space 4}st0465 sj16-4 (NJC)
{space 4}letter value calculation             
{space 4}+

{space 4}{help majority}
{space 4}SSC (NJC)
{space 4}majority calculations for real or hypothetical elections

{space 4}{help makematrix}
{space 4}SSC (NJC)
{space 4}make a matrix of results from other commands

{space 4}{help marker}
{space 4}SSC (NJC)
{space 4}generate indicator variable marking desired sample 

{space 4}{help markov}
{space 4}SSC (NJC)
{space 4}generate Markov probabilities
{space 4}pobs(OS xttrans, xttrans2)

{space 4}{help matmap}
{space 4}SSC (NJC)
{space 4}elementwise calculations for matrices
{space 4}pobs(OS Mata)

{space 4}matmore
{space 4}dm79 stb56 (NJC)
{space 4}yet more new matrix commands
{space 4}pobs(OS Mata)

{space 4}{help matodd}
{space 4}www.stata.com/users/njc (NJC)
{space 4}various matrix tasks
{space 4}pobs(OS Mata)

{space 4}{help matodd}
{space 4}dm69 stb50 (NJC)
{space 4}various matrix tasks
{space 4}pobs(OS Mata)

{space 4}{help matodd}
{space 4}SSC (NJC)
{space 4}various matrix tasks
{space 4}psup(STB 50); pobs(OS Mata)

{space 4}{help matrixof}
{space 4}SSC (NJC)
{space 4}matrix or vector of results for paired or single variables
{space 4}sup(makematrix)

{space 4}{help matvsort}
{space 4}SSC (NJC)
{space 4}sorting vectors or rows or columns of matrices
{space 4}pobs(OS Mata)

{space 4}{help mdensity}
{space 4}SSC (NJC)
{space 4}univariate kernel density estimation, for variables or groups

{space 4}{help mipolate}
{space 4}SSC (NJC) 
{space 4}interpolation of missing values 
{space 4}+ 

{space 4}{help missingplot}
{space 4}SSC (NJC)
{space 4}plot showing patterns of missing values in a dataset
{space 4}+

{space 4}{help missings} 
{space 4}SSC (NJC) 
{space 4}various utilities for managing missing values (1) 
{space 4}+ 

{space 4}{help missings} 
{space 4}dm0085 sj15-4  
{space 4}various utilities for managing missing values (2) 
{space 4}sup(SJ 17-3)

{space 4}{help missings} 
{space 4}dm0085_1 sj17-3  
{space 4}various utilities for managing missing values (3) 
{space 4}+ 

{space 4}{help mlowess}
{space 4}SSC (NJC)
{space 4}lowess smoothing with multiple predictors
{space 4}pobs(OS npregress}

{space 4}{help mnthplot}
{space 4}SSC (NJC)
{space 4}scatter plots for monthly data with repetition of data

{space 4}{help modeldiag}
{space 4}SSC (NJC)
{space 4}generate graphics after regression
{space 4}(also SJ 4-4)

{space 4}{help modeldiag}
{space 4}gr0009 sj4-4 (NJC)
{space 4}generate graphics after regression
{space 4}sup(SJ 10-1) 

{space 4}{help modeldiag}
{space 4}gr0009_1 sj10-1 (NJC)
{space 4}generate graphics after regression
{space 4}+

{space 4}{help modes}
{space 4}sg113 stb50 (NJC)
{space 4}tabulation of modes (1)
{space 4}sup(SJ 9-4)

{space 4}{help modes}
{space 4}sg113_1 sj3-2 (NJC)
{space 4}tabulation of modes (2)
{space 4}sup(SJ 9-4)

{space 4}{help modes}
{space 4}sg113_2 sj9-4 (NJC)
{space 4}tabulation of modes (3)
{space 4}+

{space 4}{help moments}
{space 4}SSC (NJC)
{space 4}moment-based statistics
{space 4}+

{space 4}{help moreobs}
{space 4}SSC (NJC)
{space 4}add observations to dataset

{space 4}{help moss}
{space 4}SSC (R. Picard, NJC)
{space 4}multiple occurrences of substrings 
{space 4}+

{space 4}{help movsumm}
{space 4}sg85 stb44 (NJC)
{space 4}moving summaries
{space 4}obs(OS rolling)

{space 4}{help mrunning}
{space 4}gr0017 sj5-3 (P. Royston, NJC)
{space 4}multivariable scatterplot smoother
{space 4}pobs(OS npregress)

{space 4}{help msplot}
{space 4}SSC (NJC)
{space 4}multiple median-spline plots

{space 4}{help mstdize}
{space 4}SSC (NJC)
{space 4}marginal standardization of two-way tables

{space 4}{help multencode} 
{space 4}SSC (NJC) 
{space 4}encode multiple string variables into numeric 
{space 4}+

{space 4}{help multidot}
{space 4}SSC (NJC)
{space 4}multiple panel dot charts and similar 
{space 4}+ 

{space 4}{help multiline}
{space 4}SSC (NJC)
{space 4}multiple panel line plots 
{space 4}+ 

{space 4}{help multqplot}
{space 4}gr0053 sj12-3 (NJC) 
{space 4}multiple quantile plots
{space 4}sup(SJ 19-3)

{space 4}{help multqplot}
{space 4}gr0053_1 sj19-3 (NJC) 
{space 4}multiple quantile plots
{space 4}+

{space 4}{help muxplot}
{space 4}SSC (NJC)
{space 4}scatter plots with y vs multiple x variables
{space 4}obs(OS graph)

{space 4}{help muxyplot}
{space 4}SSC (NJC)
{space 4}scatter plots with multiple x and y variables
{space 4}obs(OS graph)

{space 4}{help mvcorr}
{space 4}SSC (C.F. Baum, NJC)
{space 4}moving-window correlation or autocorrelation in time series
{space 4}pobs(OS rolling)

{space 4}{help mvsumm}
{space 4}SSC (C.F. Baum, NJC)
{space 4}moving-window descriptive statistics in time series
{space 4}pobs(OS rolling)

{space 4}{help mylabels}
{space 4}SSC (NJC, S. Merryman)
{space 4}axis labels or ticks on transformed scales
{space 4}+

{space 4}{help mypkg}
{space 4}SSC (NJC)
{space 4}inform on packages installed over net

{space 4}{help nbfit}
{space 4}SSC (NJC, R.G. Gutierrez)
{space 4}fitting negative binomial distribution by maximum likelihood

{space 4}{help nearest}
{space 4}SSC (NJC)
{space 4}calculate nearest neighbours from point coordinates

{space 4}{help nicedates}
{space 4}SSC (NJC)
{space 4}nice dates, especially for time series graphs

{space 4}{help niceloglabels}
{space 4}SSC (NJC)
{space 4}nice axis labels for logarithmic scales (1)
{space 4}+

{space 4}{help niceloglabels}
{space 4}gr0072 sj18-1 (NJC)
{space 4}nice axis labels for logarithmic scales (2)
{space 4}+

{space 4}{help nmissing}
{space 4}dm67 stb49 (NJC)
{space 4}numbers of missing and present values (1)
{space 4}sup(missings)

{space 4}{help nmissing}
{space 4}dm67_1 stb60 (NJC)
{space 4}numbers of missing and present values (2)
{space 4}sup(missings)

{space 4}{help nmissing}
{space 4}dm67_2 sj3-4 (NJC)
{space 4}numbers of missing and present values (3)
{space 4}sup(missings)

{space 4}{help nmissing}
{space 4}SSC (NJC)
{space 4}numbers of missing and present values (4)
{space 4}sup(missings) 

{space 4}{help nmissing}
{space 4}dm67_3 sj5-4 (NJC)
{space 4}numbers of missing and present values (5)
{space 4}sup(missings) 

{space 4}{help nmissing}
{space 4}dm67_4 sj15-4 (NJC)
{space 4}numbers of missing and present values (6)
{space 4}sup(missings) 

{space 4}{help nnipolate} 
{space 4}SSC (NJC) 
{space 4}nearest neighbour interpolation
{space 4}sup(SSC mipolate) 

{space 4}{help nruns}
{space 4}st0044_1 sj6-4 (N. Smeeton, NJC)
{space 4}number of runs compared with random shuffles
{space 4}+

{space 4}{help ntimeofday}, {help stimeofday}
{space 4}dm0018 sj6-1 (NJC)
{space 4}generate time of day variables
{space 4}pobs(OS dates and times)

{space 4}{help numdate}
{space 4}SSC (NJC) 
{space 4}generate numeric date-time variable
{space 4}+ 

{space 4}{help nvars} 
{space 4}SSC (NJC) 
{space 4}count number of variables
{space 4}obs(OS describe, c(k))

{space 4}{help omninorm}
{space 4}SSC (C.F. Baum, NJC) 
{space 4}omnibus test for univariate or multivariate normality
{space 4}+ (but cf. OS mvtest normality)

{space 4}{help onewplot}
{space 4}SSC (NJC)
{space 4}oneway plots (for Stata 6)
{space 4}sup(SSC stripplot)

{space 4}{help onewayplot}
{space 4}SSC (NJC)
{space 4}oneway plots (for Stata 8)
{space 4}sup(SSC stripplot)

{space 4}{help ordplot}
{space 4}SSC (NJC)
{space 4}cumulative distribution plots of ordinal variable
{space 4}sup(SSC distplot)

{space 4}{help outfix2}
{space 4}SSC (NJC)
{space 4}output formatted data
{space 4}obs(OS file)

{space 4}{help pairplot}
{space 4}SSC (NJC)
{space 4}paired observations plots
{space 4}+

{space 4}{help panelthin} 
{space 4}SSC (NJC) 
{space 4}identify observations for possible thinned panel dataset
{space 4}+

{space 4}{help parplot}
{space 4}SSC (NJC)
{space 4}parallel coordinates plots
{space 4}+

{space 4}{help pbeta}
{space 4}SSC (NJC)
{space 4}probability plots for data vs fitted beta distribution
{space 4}+

{space 4}{help pcacoefsave}         
{space 4}SSC (NJC) 
{space 4}save results of PCA to new dataset 
{space 4}+

{space 4}{help pchipolate} 
{space 4}SSC (NJC) 
{space 4}piecewise cubic Hermite interpolation
{space 4}sup(SSC mipolate)

{space 4}{help pdplot}
{space 4}SSC (NJC)
{space 4}Pareto dot plots
{space 4}+

{space 4}{help personage}
{space 4}SSC (NJC) 
{space 4}calculate people's ages or similar daily date differences
{space 4}+

{space 4}{help pexp}
{space 4}SSC (NJC)
{space 4}probability plots for data vs fitted exponential distribution
{space 4}+

{space 4}{help pgamma}
{space 4}SSC (NJC)
{space 4}probability plots for data vs fitted gamma distribution
{space 4}+

{space 4}{help pieplot}
{space 4}SSC (NJC) 
{space 4}plot pie charts of categorical frequencies 

{space 4}{help ppplot}
{space 4}SSC (NJC)
{space 4}P-P plots
{space 4}+

{space 4}{help psbayes}
{space 4}SSC (NJC)
{space 4}pseudo-Bayes smoothing of cell estimates
{space 4}sup(SJ qsbayes) 

{space 4}{help pwcorrw}
{space 4}SSC (NJC)
{space 4}print wide correlation matrix with significance indicators

{space 4}{help pweibull}
{space 4}SSC (NJC)
{space 4}probability plots for data vs fitted Weibull distribution
{space 4}+

{space 4}{help qbeta}
{space 4}SSC (NJC)
{space 4}quantile-quantile plots for data vs fitted beta distribution
{space 4}+

{space 4}qenv: {help qenvnormal}, {help qenvgamma}, etc. 
{space 4}SSC (M.L. Buis, NJC) 
{space 4}generate quantile envelopes for quantile-quantile plots
{space 4}+   

{space 4}{help qexp}
{space 4}SSC (NJC)
{space 4}quantile-quantile plots for data vs fitted exponential distribution
{space 4}+

{space 4}{help qgamma}
{space 4}SSC (NJC)
{space 4}quantile-quantile plots for data vs fitted gamma distribution
{space 4}+

{space 4}{help qlognorm}
{space 4}SSC (NJC)
{space 4}diagnostic plots for lognormal distribution
{space 4}sup(SSC qpfit) 

{space 4}{help diagplots2:qpfit}
{space 4}SSC (NJC)
{space 4}various quantile and probability plots for assessing distribution fit
{space 4}+

{space 4}{help qplot}
{space 4}gr42_2 sj4-1 (NJC)
{space 4}quantile plots, generalized (4)
{space 4}sup(SJ 19-3)

{space 4}{help qplot}
{space 4}gr42_3 sj5-3 (NJC)
{space 4}quantile plots, generalized (5)
{space 4}sup(SJ 19-3)

{space 4}{help qplot}
{space 4}gr42_4 sj6-4 (NJC)
{space 4}quantile plots, generalized (6) 
{space 4}sup(SJ 19-3)

{space 4}{help qplot}
{space 4}gr42_5 sj10-4 (NJC)
{space 4}quantile plots, generalized (7) 
{space 4}sup(SJ 19-3)         

{space 4}{help qplot}
{space 4}gr42_6 sj12-1 (NJC)
{space 4}quantile plots, generalized (8) 
{space 4}sup(SJ 19-3)         

{space 4}{help qplot}
{space 4}gr42_6 sj16-3 (NJC)
{space 4}quantile plots, generalized (9) 
{space 4}sup(SJ 19-3)

{space 4}{help qplot}
{space 4}gr42_7 sj19-3 (NJC)
{space 4}quantile plots, generalized (10) 
{space 4}+                    

{space 4}{help qqplot2}
{space 4}SSC (NJC)
{space 4}quantile-quantile plots
{space 4}obs(OS qqplot)

{space 4}{help qsbayes}, {help qsbayesi} 
{space 4}st0168 sj9-2 (NJC)
{space 4}quasi-Bayes smoothing 
{space 4}+

{space 4}{help quantil2}
{space 4}gr42 stb51 (NJC) 
{space 4}quantile plots, generalized (1)
{space 4}sup(SJ 12-1 qplot)

{space 4}{help quantil2}
{space 4}gr42_1 stb61 (NJC)
{space 4}quantile plots, generalized (2)
{space 4}sup(SJ 12-1 qplot)

{space 4}{help quantil2}
{space 4}SSC (NJC)
{space 4}quantile plots, generalized (3)
{space 4}sup(SJ 12-1 qplot)

{space 4}{help qweibull}
{space 4}SSC (NJC)
{space 4}quantile-quantile plots for data vs fitted Weibull distribution
{space 4}+

{space 4}{help rangerun} 
{space 4}SSC (R. Picard, NJC)
{space 4}run Stata commands on observations within range
{space 4}+

{space 4}{help rangestat} 
{space 4}SSC (R. Picard, NJC, R. Ferrer)
{space 4}generate statistics using observations within range
{space 4}+

{space 4}{help rcspline}
{space 4}SSC (NJC)
{space 4}restricted cubic spline smoothing
{space 4}+ 

{space 4}{help regresby}
{space 4}SSC (NJC)
{space 4}generate regression residuals by byvarlist
{space 4}pobs(OS foreach, forval)

{space 4}{help renames}
{space 4}SSC (NJC)
{space 4}rename variables
{space 4}sup(renvars, OS rename) 

{space 4}{help rensfix}
{space 4}dm83 stb59 (S.P. Jenkins, NJC)
{space 4}rename variables and change suffix
{space 4}sup(renvars, OS rename) 

{space 4}{help renvars}
{space 4}dm88 stb60 (NJC, J. Weesie)
{space 4}rename variables, multiply and systematically
{space 4}psup(OS rename)

{space 4}{help renvars}
{space 4}dm88_1 sj5-4 (NJC, J. Weesie)
{space 4}rename variables, multiply and systematically (2)
{space 4}psup(OS rename) 

{space 4}{help reorder}
{space 4}SSC (NJC)
{space 4}reorder variables in dataset, reversibly

{space 4}{help roman}
{space 4}SSC (NJC)
{space 4}handling Roman numerals and decimal equivalents
{space 4}sup(SJ 11-1) 

{space 4}{help roman}
{space 4}dm0053 sj11-1 (NJC) 
{space 4}handling Roman numerals and decimal equivalents

{space 4}{help romantoarabic}
{space 4}SSC (NJC)
{space 4}converting Roman numerals to arabic numbers
{space 4}sup(roman)

{space 4}{help rowranks}
{space 4}SSC (NJC)
{space 4}row ranks of a set of variables
{space 4}sup(SJ 9-1)

{space 4}{help rowranks} 
{space 4}pr0046 sj9-1 (NJC) 
{space 4}row ranks of a set of variables
{space 4}+

{space 4}{help rowsort}
{space 4}SSC (NJC)
{space 4}row sort a set of integer variables
{space 4}sup(SJ 9-1)

{space 4}{help rowsort} 
{space 4}pr0046 sj9-1 (NJC) 
{space 4}row sort a set of variables
{space 4}+

{space 4}{help running}
{space 4}sed9_2 sj5-2 (P. Sasieni, P. Royston, NJC)
{space 4}symmetric nearest neighbor linear smoothers
{space 4}sup(SSC) 

{space 4}{help running}
{space 4}SSC (P. Sasieni, P. Royston, NJC)
{space 4}symmetric nearest neighbor linear smoothers

{space 4}{help safedrop}
{space 4}SSC (NJC)
{space 4}{help drop} variables if and only if varnames specified in full

{space 4}{help savesome}
{space 4}SSC (NJC)
{space 4}{help save} subset of data

{space 4}{help sbplot}
{space 4}SSC (NJC)

{space 4}{help sbplot5}
{space 4}SSC (NJC)

{space 4}{help scat3}
{space 4}SSC (NJC)
{space 4}crude 3-dimensional graphics

{space 4}{help sdline}
{space 4}SSC (NJC)
{space 4}SD line (reduced major axis)
{space 4}+

{space 4}{help selectvars}
{space 4}SSC (NJC)
{space 4}selecting all possible n-tuples from a varlist
{space 4}sup(SSC tuples)

{space 4}{help sepscatter} 
{space 4}SSC (NJC) 
{space 4}scatter (or other twoway) plots separated by a third variable 
{space 4}+

{space 4}{help seq}
{space 4}dm44 stb37 (NJC)
{space 4}generate sequences of integers
{space 4}obs(OS egen)

{space 4}{help seq}
{space 4}SSC (NJC)
{space 4}generate sequences of integers
{space 4}obs(OS egen)

{space 4}{help seqvar}
{space 4}gr0034 sj8-2 (NJC) 
{space 4}assign integer numlists to variables
{space 4}+

{space 4}{help shorth}
{space 4}SSC (NJC)
{space 4}descriptive statistics based on shortest halves
{space 4}+

{space 4}{help showgph}
{space 4}SSC (J. Brogger, NJC)
{space 4}show graphs previously saved

{space 4}{help shownear}
{space 4}SSC (NJC)
{space 4}show nearby values of numeric variable

{space 4}Singh-Maddala etc.
{space 4}gr35 stb48 (NJC)
{space 4}plots for assessing Singh-Maddala and Dagum distributions
{space 4}sup(qpfit)

{space 4}{help skewplot}
{space 4}SSC (NJC)
{space 4}skewness plots
{space 4}+

{space 4}{help sliceplot}
{space 4}SSC (NJC)
{space 4}time series or other plot in slices
{space 4}see also SJ 6-3

{space 4}{help slideplot}
{space 4}SSC (NJC)
{space 4}sliding bar plots for frequencies or percents

{space 4}{help sparkline}
{space 4}SSC (NJC)
{space 4}sparkline-type plots 
{space 4}+ 

{space 4}{help sparl}
{space 4}SSC (NJC)
{space 4}scatter plots with y-x regression line
{space 4}pobs(OS graph); sup(aaplot) 

{space 4}{help spautoc}
{space 4}SSC (NJC)
{space 4}spatial autocorrelation (Moran and Geary measures)

{space 4}{help spell}
{space 4}SSC (NJC, R. Goldstein)
{space 4}identification of spells or runs of similar values
{space 4}pobs(tsspell)

{space 4}{help spikeplt}
{space 4}SSC (NJC, A. Brady)
{space 4}spike plots showing fine structure of the data (1)
{space 4}sup(OS spikeplot)

{space 4}{help spikeplt}
{space 4}gr25 stb36 (NJC, A. Brady)
{space 4}spike plots showing fine structure of the data (2)
{space 4}sup(OS spikeplot)

{space 4}{help spikeplt}
{space 4}gr25_1 stb40 (NJC, A. Brady)
{space 4}spike plots showing fine structure of the data (3)
{space 4}sup(OS spikeplot)

{space 4}{help spineplot}
{space 4}SSC (NJC)
{space 4}spine plots for two-way categorical data (1)  
{space 4}sup(SJ 16-2) 

{space 4}{help spineplot}
{space 4}gr0031 sj8-1 (NJC)
{space 4}spine plots for two-way categorical data (2)
{space 4}sup(SJ 16-2) 

{space 4}{help spineplot}
{space 4}gr0031_1 sj16-2 (NJC)
{space 4}spine plots for two-way categorical data (3) 
{space 4}+

{space 4}{help split}
{space 4}SSC (NJC)
{space 4}splitting string variables into parts
{space 4}sup(OS split)

{space 4}{help sqr}
{space 4}SSC (NJC)
{space 4}make graphs square, or any other shape
{space 4}obs(OS graph)

{space 4}{help sssplot}
{space 4}SSC (NJC)
{space 4}seasonal subseries plots
{space 4}sup(cycleplot)

{space 4}{help statplot}
{space 4}SSC (E.A. Booth, NJC) 
{space 4}plots of summary statistics 
{space 4}+

{space 4}{help statsmat}
{space 4}SSC (NJC, C.F. Baum)
{space 4}descriptive statistics in matrix

{space 4}{help stbget}
{space 4}SSC (NJC)
{space 4}get packages from {it:Stata Technical Bulletin} 

{space 4}{help stemplot}
{space 4}gr0028 sj7-3 (NJC) 
{space 4}stem-and-leaf plots
{space 4}+

{space 4}{help sto}
{space 4}SSC (NJC)
{space 4}toggle {help trace} switch
{space 4}obs(OS trace)

{space 4}{help storecmd}
{space 4}SSC (NJC)
{space 4}store and repeat commands using characteristics

{space 4}{help strgen}
{space 4}SSC (NJC)
{space 4}generate string variables without knowing string type
{space 4}obs(OS generate)

{space 4}{help stripplot}
{space 4}SSC (NJC)
{space 4}strip plots
{space 4}+

{space 4}{help strparse}
{space 4}SSC (M. Blasnik, NJC)
{space 4}parse string variables
{space 4}obs(OS split)

{space 4}{help stylerules}
{space 4}SSC (NJC)
{space 4}suggestions on programming style
{space 4}sup(see SJ 5: 560-566, 2005)

{space 4}{help subsetplot}
{space 4}SSC (NJC) 
{space 4}plots for each subset with rest of the data as backdrop 
{space 4}+

{space 4}{help summdate}
{space 4}SSC (NJC)
{space 4}summarizing date variable

{space 4}{help swapval}
{space 4}SSC (NJC)
{space 4}swapping values of two variables

{space 4}{help swor}
{space 4}dm86 stb59 (NJC)
{space 4}sampling without replacement (1)
{space 4}pobs(OS sample)

{space 4}{help swor}
{space 4}dm0086_1 sj5-1 (NJC)
{space 4}sampling without replacement (2)
{space 4}pobs(OS sample)

{space 4}{help sxpose}
{space 4}SSC (NJC)
{space 4}transpose string variable dataset

{space 4}{help t2way5}
{space 4}SSC (NJC)
{space 4}Tukey's two-way analysis by medians (update of {help t2way})

{space 4}{help tab2i}
{space 4}sg57 stb33 (NJC)
{space 4}immediate command for two-way tables
{space 4}sup(tab_chi)

{space 4}tab_chi
{space 4}www.stata.com/users/njc (NJC)
{space 4}tabulation and chi-square tasks (1) 
{space 4}sup(SSC)

{space 4}tab_chi
{space 4}SSC (NJC)
{space 4}tabulation and chi-square tasks (2) 
{space 4}+ (chitest/chitesti/tabsplit/tabm)

{space 4}{help taba}
{space 4}SSC (NJC)
{space 4}tabulation of frequencies

{space 4}{help tabcond}
{space 4}SSC (NJC)
{space 4}tabulate frequencies satisfying specified conditions

{space 4}{help tabcount}
{space 4}SSC (NJC)
{space 4}tabulate frequencies, with zeros explicit
{space 4}+

{space 4}{help tabexport}
{space 4}SSC (NJC)
{space 4}export tables of summary statistics to text files

{space 4}{help tabhbar}
{space 4}SSC (NJC)
{space 4}table of frequencies as horizontal bar chart
{space 4}obs(catplot)

{space 4}{help tabhplot}
{space 4}SSC (NJC)
{space 4}table of frequencies as horizontal plots
{space 4}obs(catplot)

{space 4}{help tablab}
{space 4}SSC (NJC)
{space 4}autocrosstabulate a variable
{space 4}pobs(OS numlabel) 

{space 4}{help tablepc}
{space 4}SSC (NJC)
{space 4}percent calculation prior to {help table}

{space 4}{help tableplot}
{space 4}SSC (NJC)
{space 4}graphical display in two-way table format

{space 4}{help tabmerge}
{space 4}SSC (NJC)
{space 4}tabulate report on {help merge}

{space 4}{help tabplot}
{space 4}gr0066 sj16-2 (NJC)
{space 4}one-, two- and three-way bar charts for tables (1) 
{space 4}sup(SSC)

{space 4}{help tabplot}
{space 4}gr0066_1 sj17-3 (NJC)
{space 4}one-, two- and three-way bar charts for tables (2)
{space 4}sup(SSC)

{space 4}{help tabplot}
{space 4}SSC (NJC)
{space 4}one-, two- and three-way bar charts for tables (3) 
{space 4}+ 

{space 4}{help tabplot}
{space 4}gr0066_2 sj20-3 (NJC)
{space 4}one-, two- and three-way bar charts for tables (4) 
{space 4}in press! 

{space 4}tails
{space 4}www.stata.com/meetings/6uk (NJC)
{space 4}plotting and fitting distributions with long or heavy tails

{space 4}{help textbarplot}
{space 4}SSC (NJC) 
{space 4}horizontal text and bar plot 
{space 4}use {help labmask} and {help seqvar} instead 

{space 4}text editors 
{space 4}{browse "http://fmwww.bc.edu/repec/bocode/t/textEditors.html":texteditors.html}
{space 4}some notes on text editors for Stata users

{space 4}{help tkdensity}
{space 4}SSC (NJC) 
{space 4}kernel density estimation, calculation on transformed scale
{space 4}+

{space 4}{help todate}
{space 4}SSC (NJC)
{space 4}generate date variables from run-together date variables
{space 4}psup(OS {help date()}), pobs(numdate) 

{space 4}{help tolower}
{space 4}SSC (NJC)
{space 4}rename variables with lower case names
{space 4}sup(renvars; OS rename)

{space 4}{help tomode}
{space 4}SSC (NJC, F. Wolfe)
{space 4}change values of a variable to mode(s)
{space 4}sup(STB 50, OS egen)

{space 4}{help topichlp}
{space 4}www.stata.com/users/njc (NJC)
{space 4}help files on various general topics
{space 4}sup(SSC)

{space 4}{help torats}
{space 4}SSC (C.F. Baum, NJC)
{space 4}facilitate transfer of data to RATS

{space 4}{help tostring}
{space 4}www.stata.com/users/jwernow (NJC, J.B. Wernow)
{space 4}change numeric variables to string
{space 4}sup(OS tostring)

{space 4}{help tostring}
{space 4}dm80 stb56 (NJC, J.B. Wernow)
{space 4}change numeric variables to string
{space 4}sup(OS tostring)

{space 4}{help tostring}
{space 4}dm80_1 stb57 (NJC, J.B. Wernow)
{space 4}change numeric variables to string (update)
{space 4}sup(OS tostring)

{space 4}{help tpvar}
{space 4}SSC (NJC)
{space 4}turning-point variable for graphics labelling
{space 4}obs(OS graph)

{space 4}{help transint}
{space 4}SSC (NJC)
{space 4}help files for transformations
{space 4}+

{space 4}transplot 
{space 4}SSC (NJC) 
{space 4}plots for trying out transformations 
{space 4}+ 

{space 4}{help trimmean}
{space 4}SSC, st0313 sj13-3 (NJC)
{space 4}trimmed means as descriptive statistics 
{space 4}+ 

{space 4}{help trimplot}
{space 4}SSC, st0313 sj13-3 (NJC)
{space 4}plots of trimmed means
{space 4}+ 

{space 4}{help triplot}
{space 4}SSC (NJC)
{space 4}triangular plots
{space 4}+

{space 4}{help tsegen}
{space 4}SSC (R. Picard, NJC)
{space 4}invoke an egen function using a tsvarlist as argument
{space 4}+

{space 4}{help tsgraph}
{space 4}SSC (NJC, C.F. Baum)
{space 4}time series line graphs
{space 4}obs(OS graph)

{space 4}{help tsspell}
{space 4}SSC (NJC)
{space 4}identification of spells or runs in time series
{space 4}+

{space 4}{help tuples}
{space 4}SSC (J.N. Luchman, D. Klein, NJC)
{space 4}selecting all possible tuples from a list
{space 4}+

{space 4}{help tuples8}
{space 4}SSC (J.N. Luchman, NJC)
{space 4}selecting all possible tuples from a list 
{space 4}Stata 8 or 9 only 

{space 4}{help univstat}
{space 4}www.stata.com/users/njc (NJC)
{space 4}summary statistics in matrix form (1)
{space 4}sup(SSC)

{space 4}{help univstat}
{space 4}SSC (NJC)
{space 4}summary statistics in matrix form (2)

{space 4}{help vallab}
{space 4}SSC (NJC)
{space 4}pack values and labels into a new string variable
{space 4}pobs(OS numlabel) 

{space 4}{help vallist}
{space 4}dm90 stb60 (NJC)
{space 4}listing distinct values of a variable
{space 4}sup(OS levelsof)

{space 4}{help variog}
{space 4}SSC (NJC)
{space 4}calculate and graph semi-variograms

{space 4}{help vbar}
{space 4}gr24 stb36 (NJC)
{space 4}vertical bar charts (1)
{space 4}obs(OS graph, catplot)

{space 4}{help vbar}
{space 4}gr24_1 stb40 (NJC)
{space 4}vertical bar charts (2)
{space 4}obs(OS graph, catplot)

{space 4}{help vclose}
{space 4}SSC (NJC)
{space 4}close viewer windows

{space 4}{help vplplot}
{space 4}paired data plots
{space 4}sup(pairplot)

{space 4}{help vreverse}
{space 4}SSC (NJC)
{space 4}reverse existing categorical variable

{space 4}{help wbull}
{space 4}SSC (NJC)
{space 4}fit Weibull distribution by maximum likelihood
{space 4}sup(weibullfit)

{space 4}{help weibullfit}
{space 4}SSC (NJC, S.P. Jenkins)
{space 4}fit two-parameter Weibull distribution
{space 4}+

{space 4}{help whitetst}
{space 4}SSC (C.F. Baum, NJC)
{space 4}tests for heteroskedasticity in regression error distribution
{space 4}sup(STB 55)

{space 4}{help whitetst}
{space 4}sg137 stb55 (C.F. Baum, NJC, V. Wiggins)
{space 4}tests for heteroskedasticity in regression error distribution
{space 4}psup(OS imtest)

{space 4}{help winsor}
{space 4}SSC (NJC)
{space 4}Winsorize a variable

{space 4}{help xcorplot}
{space 4}SSC (NJC, A. Tobias)
{space 4}calculate and graph cross-correlation function
{space 4}obs(OS xcorr)

{space 4}{help xtpattern}
{space 4}SSC (NJC)
{space 4}code showing pattern of {help xt} data

{space 4}{help xtpatternvar}
{space 4}SSC (NJC)
{space 4}generate variable describing panel patterns
{space 4}+

{space 4}{help xttrans2}
{space 4}SSC (NJC)
{space 4}tables of transition probabilities

{space 4}{help zmap}
{space 4}SSC (NJC)
{space 4}binned scatter maps 
{space 4}+


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
n.j.cox@durham.ac.uk


