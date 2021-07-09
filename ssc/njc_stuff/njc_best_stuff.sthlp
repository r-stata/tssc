{smcl}
{hline}
index of NJC's best Stata stuff (version 1 July 2020)  
{hline}

{title:Description} 

{p 4 4 2}This is a list of what I regard as my best Stata packages or commands
that are in the public domain.  If a help file is not accessible to you, use
{help search} to find out where the files are. The help files carry details on
people who kindly reported bugs or made useful suggestions. A fuller list is
available at {help njc_stuff:NJC stuff}. 


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


{title:Packages, mostly on SSC} 

{title:General graphics commands} 

{space 4}{help aaplot}              scatter plot with linear and/or quadratic fit, automatically annotated
{space 4}{help binsm}               bin smoothing and summary on scatter plots
{space 4}{help catplot}             plots of categorical data
{space 4}{help ciplot}              plots of confidence intervals 
{space 4}{help combineplot}         combine similar plots for different variables 
{space 4}{help corrtable}           correlation matrix as graphical table
{space 4}{help crossplot}           scatter (twoway) plots for each y vs each x 
{space 4}{help cycleplot}           cycle plots (seasonal subseries plots)
{space 4}{help depthplot}           plot variable(s) with depth as vertical axis
{space 4}{help designplot}          graphical summary of response given one or more factors 
{space 4}{help diagsm}              diagonal smoothing 
{space 4}{help distplot}            distribution function plots 
{space 4}{help domdiag}             dominance diagrams 
{space 4}{help doublesm}            double smoothing 
{space 4}{help dpplot}              density probability plots
{space 4}{help eofplot}             plot coefficients or loadings after PCA or factor analysis
{space 4}{help eqprhistogram}       equal probability histograms 
{space 4}{help fabplot}             plots for each subset, rest of data as backdrop 
{space 4}{help favplots}            formatted added-variable plot(s)
{space 4}{help fractileplot}        smoothing with distribution function predictors
{space 4}{help kaplansky}           graph examples of distributions of varying kurtosis 
{space 4}{help linkplot}            linked scatter plots 
{space 4}{help localp}              kernel-weighted local polynomial smoothing 
{space 4}{help missingplot}         plot showing patterns of missing values in a dataset
{space 4}{help mlowess}             lowess smoothing with multiple predictors 
{space 4}{help modeldiag}           model diagnostics after regression-type commands 
{space 4}{help multidot}            multiple panel dot charts and similar 
{space 4}{help multiline}           multiple panel line plots 
{space 4}{help multqplot}           multiple quantile plots 
{space 4}{help mylabels}            axis labels or ticks on specified scales 
{space 4}{help niceloglabels}       nice axis labels for logarithmic scales
{space 4}{help pairplot}            plots of paired observations
{space 4}{help parplot}             parallel coordinates plots   
{space 4}{help pdplot}              Pareto dot plots 
{space 4}{help polarsm}             polar smoothing 
{space 4}{help ppplot}              P-P plots 
{space 4}{help qplot}               quantile plots
{space 4}{help rcspline}            restricted cubic spline smoothing
{space 4}{help sdline}              SD line (reduced major axis)
{space 4}{help sepscatter}          scatter plots separated by a third variable 
{space 4}{help skewplot}            skewness plots
{space 4}{help sliceplot}           time series or other plot in slices 
{space 4}{help sparkline}           sparkline-type plots 
{space 4}{help spineplot}           spine plots for two-way categorical data 
{space 4}{help statplot}            plots of summary statistics 
{space 4}{help stemplot}            stem-and-leaf plots 
{space 4}{help stripplot}           strip plots 
{space 4}{help subsetplot}          plots for subsets, rest of the data as backdrop 
{space 4}{help tabplot}             one-, two- and three-way bar charts for tables  
{space 4}{help transplot}           plots for trying out transformations 
{space 4}{help triplot}             triangular plots 
{space 4}{help trimplot}            plots of trimmed means 
{space 4}{help zmap}                binned scatter maps

{title:Distribution fitting and plotting}

{space 4}qenv                generate quantile envelopes for quantile-quantile plots ({help qenvnormal}, {help qenvgamma}, etc.)
{space 4}{help betafit}             beta distribution            
{space 4}{help pbeta} 
{space 4}{help qbeta} 
{space 4}{help dirifit}             Dirichlet distribution 
{space 4}{help pexp}                exponential distribution 
{space 4}{help qexp} 
{space 4}{help gammafit}            gamma distribution
{space 4}{help pgamma}
{space 4}{help qgamma} 
{space 4}{help gumbelfit}           Gumbel distribution
{space 4}{help pgumbel}
{space 4}{help qgumbel}
{space 4}{help invgammafit}         inverse gamma distribution
{space 4}{help pinvgamma} 
{space 4}{help qinvgamma} 
{space 4}{help invgaussfit}         inverse Gaussian distribution
{space 4}{help pinvgauss} 
{space 4}{help qinvgauss} 
{space 4}{help weibullfit}          Weibull distribution 
{space 4}{help pweibull}     
{space 4}{help qweibull}
{space 4}{help diagplots2:qpfit}               Dagum, generalized beta (second kind), 
{space 4}                    lognormal, Singh-Maddala distributions

{title:Other statistics} 

{space 4}{help bkrosenblatt}        Blum, Kiefer and Rosenblatt test of bivariate independence
{space 4}{help circular}            circular statistics 
{space 4}{help concord}             concordance correlation
{space 4}{help corrci}, {help corrcii}     correlation with z-based confidence intervals
{space 4}{help cpcorr}              correlations for each row vs each column variable
{space 4}{help diptest}             dip statistic to test for unimodality
{space 4}{help entropyetc}          entropy and related measures for categories
{space 4}{help extremes}            list extreme values  
{space 4}{help firstdigit}          first digits of numeric variables
{space 4}{help glmcorr}             correlation and RMS error for GLMs
{space 4}{help group1d}             grouping or clustering in one dimension
{space 4}{help hdquantile}          Harrell-Davis estimator of quantiles
{space 4}{help hsmode}              half-sample modes
{space 4}{help iquantile}           interpolated quantiles 
{space 4}{help lmoments}            L-moments and derived statistics 
{space 4}{help lvalues}             letter value calculation
{space 4}{help modes}               tabulation of modes 
{space 4}{help moments}             moment-based statistics
{space 4}{help nruns}               number of runs compared with random shuffles
{space 4}{help omninorm}            omnibus test for univariate or multivariate normality 
{space 4}{help pcacoefsave}         save results of PCA to new dataset 
{space 4}{help qsbayes}, {help qsbayesi}   quasi-Bayes smoothing of categorical frequencies 
{space 4}{help rangerun}            run commands on observations within range
{space 4}{help rangestat}           generate statistics using observations within range
{space 4}{help shorth}              descriptive statistics based on shortest halves
{space 4}tab_chi             {help chitest}, {help chitesti}, {help tabm}, {help tabsplit} especially
{space 4}{help tkdensity}           kernel density estimation, calculation on transformed scale
{space 4}{help transint}            transformations help 
{space 4}{help trimmean}            trimmed means as descriptive statistics 

{title:Data management and programming}

{space 4}{help charlist}            list characters present in string variables
{space 4}{help dataex}              generate formatted data example for Statalist
{space 4}{help distinct}            display number of distinct values of variables 
{space 4}{help egenmore}            extension to generate (more extras) 
{space 4}{help fedit}               find and edit text file from within Stata
{space 4}{help findname}            list variables matching name patterns or other properties
{space 4}{help fixsort}             sort variables and align in sorted order 
{space 4}{help fs}                  show names of files in compact form
{space 4}{help groups}              list group frequencies    
{space 4}{help labmask}             values or value labels of one variable as value labels of another
{space 4}{help longshape}           reshape to long (limited alternative)
{space 4}{help mipolate}            interpolate missing values
{space 4}{help missings}            utilities for managing missing values
{space 4}{help moss}                multiple occurrences of substrings 
{space 4}{help multencode}          encode multiple string variables into numeric
{space 4}{help numdate}             generate numeric date-time variable
{space 4}{help panelthin}           observations for thinned panel dataset
{space 4}{help personage}           people's ages or daily date differences
{space 4}{help rowranks}            row ranks of a set of variables 
{space 4}{help rowsort}             row sort a set of variables 
{space 4}{help seqvar}              assign integer numlists to variables
{space 4}{help tabcount}            tabulate frequencies 
{space 4}{help tsegen}              invoke egen using tsvarlist as argument
{space 4}{help tsspell}             identification of spells in time series
{space 4}{help tuples}              selecting all possible tuples from a list 
{space 4}{help xtpatternvar}        generate variable describing panel patterns


{title:Collaborators} 

{p 4 4 2} 
{bind:C.F. Baum,} 
{bind:M. Blasnik,} 
{bind:E.A. Booth,}
{bind:A. Brady,} 
{bind:J. Brogger,} 
{bind:M.L. Buis,} 
{bind:R. Ferrer,} 
{bind:R. Goldstein,} 
{bind:W. Gould,} 
{bind:J.P. Gray,} 
{bind:R.G. Gutierrez,} 
{bind:S.P. Jenkins,}
{bind:S. Juul,}
{bind:P. van Kerm,} 
{bind:D. Klein,}
{bind:U. Kohler,} 
{bind:G. Longton,} 
{bind:J.N. Luchman,} 
{bind:S. Merryman,} 
{bind:R. Picard,} 
{bind:B. Rising,} 
{bind:G. Rossman,} 
{bind:P. Royston,} 
{bind:I.H. Salgado-Ugarte,} 
{bind:P. Sasieni,} 
{bind:M. Shimizu,} 
{bind:N. Smeeton,} 
{bind:T.J. Steichen,} 
{bind:S. Stillman,} 
{bind:T. Taniuchi,} 
{bind:A. Tobias,} 
{bind:Z. Wang,} 
{bind:J. Weesie,} 
{bind:J.B. Wernow,} 
{bind:V. Wiggins,} 
{bind:D.E. Williams,} 
{bind:N. Winter,} 
{bind:F. Wolfe} 
and those contributing to the text editors FAQ


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
         n.j.cox@durham.ac.uk 

