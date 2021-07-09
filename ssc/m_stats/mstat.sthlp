{smcl}
{* *! version 10.1 22jul2010}
{cmd: help mstat , mtest}
{hline}

{title:Title}

{phang}
{bf:M statistics} {hline 2} 2 samples M statistics for spatial distribution analysis

{title:Syntax}

    2 samples M statistics

	{cmd:mstat} {cmd:,} x({it:varname}) y({it:varname}) g({it:varname}) [{it:options} {help mstat##graph_opt:{it:graphic_options}}]

 
    2 samples M statistics and Monte Carlo test

	{cmd:mtest} {cmd:,} x({it:varname}) y({it:varname}) g({it:varname}) [{it:options} {help mstat##graph_opt:{it:graphic_options}}]
	
	
{title:Options for {cmd:mstat}}
	
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt: * {cmdab:x(}{help varname:{it:varname}}{cmd:)}}x-coordinates{p_end}
{synopt: * {cmdab:y(}{help varname:{it:varname}}{cmd:)}}y-coordinates{p_end}
{synopt: * {cmdab:g(}{help varname:{it:varname}}{cmd:)}}group dummy variable{p_end}
{synopt:{opt bins(#)}}choose the number of bins to be used{p_end}
{synopt:{opt chi2}}returns the upper tail pvalue of the asymptotic chi2 distribution{p_end}
{synopt:{opt sc:atter}}plot the spatial distribution of two groups{p_end}
{synopt:{opt den:sity}}plot the Kernel density for the interpoint distances{p_end}
{synopt:{help mstat##graph_opt:{it:graphic_options}}}manipulate graphic output{p_end}

{synoptline}
{p 4 6 2}* Required option{p_end}

{title:Options for {cmd:mtest}}
	
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt: * {cmdab:x(}{help varname:{it:varname}}{cmd:)}}x-coordinates{p_end}
{synopt: * {cmdab:y(}{help varname:{it:varname}}{cmd:)}}y-coordinates{p_end}
{synopt: * {cmdab:g(}{help varname:{it:varname}}{cmd:)}}group dummy variable{p_end}
{synopt:{opt bins(#)}}choose the number of bins to be used{p_end}
{synopt:{opt iter(#)}}choose the number of Monte Carlo permutation in the test{p_end}
{synopt:{opt level(#)}}choose the level for the p-value confidence interval to be reported{p_end}
{synopt:{opt sc:atter}}plot the spatial distribution of two groups{p_end}
{synopt:{opt den:sity}}plot the Kernel density for the interpoint distances{p_end}
{synopt:{help mstat##graph_opt:{it:graphic_options}}}manipulate graphic output{p_end}
{synoptline}
{p 4 6 2}* Required option{p_end}



{title:Description}

{pstd} 
The dataset is required to have the following structure:

{center:	x-coord		y-coord		group}
{center:{hline 50}}
{center:	23.4		45.8		0}
{center:	26.4		41.3		1}
{center:	71.3		39.2		1}
{center:	55.0		42.8		0}
{center:	...		...		...}
{center:{hline 50}}

{title:{cmd:mstat}}
Computes the two samples observed M statistic using {it:k} bins (via option {opt bins(k)}).

{title:{cmd:mtest}}
Computes the two samples observed M statistic using {it:k} bins (via option {opt bins(k)}) and executes a Monte Carlo test 
permuting the group variable (option {opt g(varname)}) n times (via option {opt iter(n)}. It returns the upper tail 
p-value=#(M>=M0)/n and a corresponding l% confidence interval (via option {opt level(l)}).


{title:Required options for {cmd:mstat} and {cmd:mtest}}

{cmdab:x(}{help varname:{it:x-coord}}{cmd:)} variable containing the x-coordinate of the location
{cmdab:y(}{help varname:{it:y-coord}}{cmd:)} variable containing the y-coordinate of the location
{cmdab:g(}{help varname:{it:group}}{cmd:)} binary variable (0-1) indicating the group

{title:Options for {cmd:mstat}}

{cmdab:bins(}{it:#}{cmd:)} selects the number of bins. The number must be a positive integer, not larger than the number of distances in the dataset, 
that is (number of observations choose 2). The default is {opt bins(20)}.
For the theoretical implications refer to {it:Forsberg, L., Bonetti, M. and Pagano, M. 2009}.

{cmdab:chi2} displays and returns the pvalue for the asymptotic chi2 test (upper tail).

{cmdab:scatter} generates scatter plot of the two groups.

{cmdab:density} generates Kernel density of the interpoint distance distribution for the two groups.

{title:Options for {cmd:mtest}}

{cmdab:bins(}{it:#}{cmd:)} selects the number of bins. The number must be a positive integer, not larger than the number of distances in the dataset, 
that is (number of observations choose 2). The default is {opt bins(20)}.
For the theoretical implications refer to {it:White, F. L., Bonetti, M. and Pagano, M. 2009}.

{cmdab:iter(}{it:#}{cmd:)} set the number of random permutations of the group variable (option {opt g(varname)} to be performed for 
the Monte Carlo test. The default value is {opt iter(100)}.

{cmdab:level(}{it:#}{cmd:)} set the confidence level for the p-value's confidence interval. The default is {opt level(95)}.

{cmdab:scatter} generates a scatter plot of the two groups.

{cmdab:density} generates a Kernel density of the interpoint distance distribution for the two groups.


{marker graph_opt}{title:Graphic Options}

The graphic options are designed to manipulate the graphic output of the commands. 
The options are active only if the corresponding option ({cmdab:scatter} or {cmdab:density}) is specified.

Options when option {cmdab:scatter} is specified

{cmdab:scolor0(}{help colorstyle:{it:colorstyle}}{cmd:)} set the color for the marker of group 0.
{cmdab:scolor1(}{help colorstyle:{it:colorstyle}}{cmd:)} set the color for the marker of group 1.
{cmdab:smarker0(}{help symbolstyle:{it:marker symbol}}{cmd:)} set the symbol for the marker of group 0.
{cmdab:smarker1(}{help symbolstyle:{it:marker symbol}}{cmd:)} set the symbol for the marker of group 1.
{cmdab:ssize0(}{help markersizestyle:{it:marker size}}{cmd:)} set the size for the marker of group 0.
{cmdab:ssize1(}{help markersizestyle:{it:marker size}}{cmd:)} set the size for the marker of group 1.
{cmdab:slabel0(}{it:string}{cmd:)} input the label for group 0 in the legend, default: "Group 0".
{cmdab:slabel1(}{it:string}{cmd:)} input the label for group 1 in the legend, default: "Group 1".
{cmdab:stitle(}{it:string}{cmd:)} specifies the title for the scatter, default: "Spatial Distribution of the two groups".
{cmdab:sytitle(}{it:string}{cmd:)} specifies the title for the y axis, default is the name of the variable in option {cmdab:y(}{help varname:{it:y-coord}}{cmd:)}.
{cmdab:sxtitle(}{it:string}{cmd:)} specifies the title for the x axis, default is the name of the variable in option {cmdab:x(}{help varname:{it:x-coord}}{cmd:)}.

Options when option {cmdab:density} is specified

{cmdab:dcolor0(}{help colorstyle:{it:colorstyle}}{cmd:)} set the color for the line of the density of group 0.
{cmdab:dcolor1(}{help colorstyle:{it:colorstyle}}{cmd:)} set the color for the line of the density of group 1.
{cmdab:dpattern0(}{help linepatternstyle:{it:line pattern style}}{cmd:)} set the pattern style for the line of the density of group 0.
{cmdab:dpattern1(}{help linepatternstyle:{it:line pattern style}}{cmd:)} set the pattern style for the line of the density of group 1.
{cmdab:dwidth0(}{help linewidthstyle:{it:line width style}}{cmd:)} set the width for the line of the density of group 0.
{cmdab:dwidth1(}{help linewidthstyle:{it:line width style}}{cmd:)} set the width for the line of the density of group 1.
{cmdab:dlabel0(}{it:string}{cmd:)} input the label for group 0 in the legend, default: "Group 0".
{cmdab:dlabel1(}{it:string}{cmd:)} input the label for group 1 in the legend, default: "Group 1".
{cmdab:dtitle(}{it:string}{cmd:)} specifies the title for the Kernel density, default: "IDD Kernel Densities".


{title:Saved results}

{cmd:mstat} saves the following in {cmdab:r()}

Scalars
	{cmdab:r(M)}		observed M statistic
	{cmdab:r(p)}		chi-squared p-value (if option {opt chi2} is specified)
Matrices
	{cmdab:r(difF)}		difference between the ECDFs in the two groups
	{cmdab:r(Sinv)}		generalized inverse of the covariance matrix of {cmdab:r(difF)}
	{cmdab:r(d)}		cutoffs of the equiprobable bins

{cmd:mtest} saves the following in {cmdab:r()}

Scalars
	{cmdab:r(N)}		sample size

Matrices
	{cmdab:r(M)}		observed M statistic
	{cmdab:r(c)}		count when M>=M(obs) is true
	{cmdab:r(p)}		observed empirical p-value
	{cmdab:r(se)}		standard error of empirical p-value
	{cmdab:r(ci)}		exact binomial confidence interval of observed p-value
	{cmdab:r(reps)}		number of nonmissing results
	{cmdab:r(d)}		cutoffs of the equiprobable bins
	{cmdab:r(Sinv)}		generalized inverse of the covariance matrix


{title:Author}

{p 4} Pietro Tebaldi {p_end}
{p 4} Department of Biostatistics , Harvard School of Public Health {p_end}
{p 4} Bocconi University , Milan - Italy {p_end}
{p 4} {browse "mailto:pietro.tebaldi@studbocconi.it":pietro.tebaldi@studbocconi.it}


{title:References}

{p 4 8 2}Bonetti, M., and Pagano, M. The interpoint distance distribution as
a descriptor of point patterns, with an application to spatial disease clustering.
{it:Stat Med} 2005; 24(5):753-773.

{p 4 8 2}Forsberg, L., Bonetti, M. and Pagano, M. 2009. The choice of the number of bins for the M statistic.
{it:CSDA} 2009; 53(10):3640-3649.


{p 4 8 2}Manjourides, J., and Pagano, M. 2010. An interpoint distance based test for the
difference between two spatial distribution.
{it:Submitted}.

{p 4 8 2}Ozonoff, A. , Jeffery, C. , Manjourides, J. , White, L.F., and Pagano, M. 2007. Effect
of spatial resolution on cluster detection: a simulation study. {it:Int J Health Geogr} 2007; 52(6).

