{smcl}
{title:sdist}

{phang}
{bf:sdist} {hline 2} Simulate the central limit theorem


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sdist}
[{cmd:,} {it:samples(#) obs(#) type(string) par1(#) par2(#) round(#) histplot saveplot1(string) saveplot2(string) repplot combine lcolor(string) fcolor(string) bckg(string) nlcolor(string) nlwidth(#) nlpattern(string) dots}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:}
{synopt:{opt samples(#)}}The number of random variables to generate. Default is 200. {p_end}
{synopt:{opt obs(#)}}The number of observations per sample. Default is 500.{p_end}
{synopt:{opt type(string)}}The type of distribution from which the random samples should be drawn. The default is type(uniform), which generates random samples from a rectangular uniform distribution. Normal and Poisson distributions are also available, indicated by {cmd:type(normal)} and {cmd:type(poisson)}, respectively. The distributions are created through calls to Stata’s random number generators (StataCorp n.d.1).{p_end}
{synopt:{opt par1(#)}}The first parameter to be specified depending on the distribution selected in {cmd:type()}. Since the default {cmd:type()} is the rectangular distribution, the default is the  lower end of the [a,b) interval. The samples are generated through the {cmd:runiform()} function so the default for  is 0, but this can be changed. If {cmd:type(normal)} is selected, this parameter is the mean, with a default of 0. This parameter does not specify anything if {cmd:type(poisson)} is selected; use {cmd:par2(#)} to specify the mean of the Poisson distribution instead.{p_end}
{synopt:{opt par2(#)}}The second parameter to be specified depending on the distribution selected in {cmd:type()}. Since the default {cmd:type()} is the rectangular distribution, the default is the  higher end of the [a,b) interval. The samples are generated through the {cmd:runiform()} function so the default for  is (an approximation of) 1, but this can be changed. If {cmd:type(normal)} is selected, this parameter is the standard deviation, with a default of 1. If {cmd:type(poisson)} is selected, this parameter is the mean, also with a default of 0.{p_end}
{synopt:{opt round(#)}}the decimal point to which the estimates should be rounded. The default is 0.001.{p_end}
{synopt:{opt histplot}}Indicates whether or not histograms of the two frequency distributions should be plotted. The plots are generated through the {cmd:histogram} command (StataCorp n.d.2). Defaults to no histogram.{p_end}
{synopt:{opt saveplot1(string)}}Indicates whether the first histogram should be saved and the name for the plot. Defaults to plot1.gph if {cmd:repplot} is specified but not {cmd:saveplot1()}. Ignored if {cmd:histplot} is not specified. The default is to not save the plot.{p_end}
{synopt:{opt saveplot2(string)}}Serves the same purpose as {cmd:saveplot1()}, but with reference to the second histogram. Defaults to plot2.gph if {cmd:repplot} is specified but not {cmd:saveplot2()}. Ignored if {cmd:histplot} is not specified. The default is to not save the plot.{p_end}
{synopt:{opt repplot}}Specifies whether or not the saved histograms should replace existing saved histograms in the same directory with the same name. {cmd:repplot} will default to saving both plots if neither {cmd:saveplot1()} nor {cmd:saveplot2()} is specified, using plot1.gph and plot2.gph as the file names, respectively. The default is to not replace plots.{p_end}
{synopt:{opt combine}}Indicates whether or not the two histograms should be stacked to form a third plot. This is a call to the {cmd:graph combine} function (StataCorp n.d.4). Both histograms have to be saved in order for the graphs to be combined, either by specifying both {cmd:saveplot1()} and {cmd:saveplot2()} simultaneously or by specifying {cmd:repplot} without either saveplot options (though {cmd:repplot} can still be used in conjunction with both {cmd:saveplot1()} and {cmd:saveplot2()} if both are specified). Requiring that both {cmd:saveplot1()} and {cmd:saveplot2()} or {cmd:repplot} only be specified prevents the program from erroneously stacking histograms from different simulations. The default is to not stack the plots.{p_end}
{synopt:{opt lcolor}}Indicates the outline color of the histogram bars. This is a call to the {cmd:histogram} function (StataCorp n.d.2). The default is black.{p_end}
{synopt:{opt fcolor}}Indicates the interior color of the histogram bars. This is a call to the {cmd:histogram} function (StataCorp n.d.2). The default is gs6.{p_end}
{synopt:{opt bckg}}Indicates the color of the graph region background. This is a call to the {cmd:graphregion(fcolor())} argument within the {cmd:histogram} command (StataCorp n.d.3). The default is white.{p_end}
{synopt:{opt nlcolor}}Indicates the color of the normal curve line. This is a call to the {cmd:normopts(lcolor())} argument within the {cmd:histogram} command (StataCorp n.d.2). The default is black.{p_end}
{synopt:{opt nlwidth}}Indicates the thickness of the normal curve line. This is a call to the {cmd:normopts(lwidth())} argument within the {cmd:histogram} command (StataCorp n.d.2). The default is .5.{p_end}
{synopt:{opt nlpattern}}Indicates the pattern of the normal curve line. This is a call to the {cmd:normopts(lpattern())} argument within the {cmd:histogram} command (StataCorp n.d.2). The default is solid.{p_end}
{synopt:{opt dots}}Indicates whether or not the program should show simulation progress using the {cmd:_dots} function. The default is no dots.{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sdist} simulates the central limit theorem by generating a matrix of randomly generated normal or non-normal variables and comparing the true sampling distribution standard deviation to the standard error from the first randomly-generated sample. The user also has the option of plotting the empirical sampling distribution of sample means, the first random variable distribution, and a stacked visualization of the two distributions. 

{marker remarks}{...}
{title:Remarks}

{pstd}
For more detailed information on the random number generators in Stata, see {bf:[FN] Random-number functions}.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sdist}{p_end}

{phang}{cmd:. sdist, samples(300) obs(400) round(.0001)}{p_end}

{phang}{cmd:. sdist, samples(400) obs(400) type(poisson) dots}{p_end}

{marker references}{...}
{title:References}

{phang}StataCorp. N.d.1. Random-number functions. College Station, TX: StataCorp LP. Accessed September 26, 2017 (https://www.stata.com/manuals13/m-5runiform.pdf).{p_end}
{phang}StataCorp. N.d.2. histogram -- Histograms for continuous and categorical variables. College Station, TX: StataCorp LP. Accessed September 26, 2017 (https://www.stata.com/manuals13/rhistogram.pdf).{p_end}
{phang}StataCorp. N.d.3. region_options -- Options for shading and outlining regions are controlling graph size. College Station, TX: StataCorp LP. Accessed September 26, 2017 (https://www.stata.com/manuals13/g-3region_options.pdf).{p_end}
{phang}StataCorp. N.d.4. graph combine -- Combine multiple graphs. College Station, TX: StataCorp LP. Accessed September 26, 2017 (https://www.stata.com/manuals13/g-2graphcombine.pdf).{p_end}

{marker author}{...}
{title:Author}

Marshall A. Taylor, Department of Sociology, University of Notre Dame
mtaylo15@nd.edu