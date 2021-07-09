{smcl}
{* 9jul2020}{...}
{hline}
help for {hi:multidensity}
{hline}

{title:Kernel density estimation for one or more variables or groups} 


{title:Syntax} 

{p 8 17 2}{cmd:multidensity} {cmdab:g:enerate} {it:varlist} {ifin}
{weight} [ {cmd:,} {it:generate_options} ] {space 4} 
({cmd:generate} syntax 1) 
 
{p 8 17 2}{cmd:multidensity} {cmdab:g:enerate} {it:varname} {ifin}
{weight} [ {cmd:,} {it:generate_options} ] {space 4} 
({cmd:generate} syntax 2) 

{p 8 17 2}{cmd:multidensity} {cmdab:s:uper} [ {cmd:,} {it:super_options}
] 

{p 8 17 2}{cmd:multidensity} {cmdab:j:uxta} [ {cmd:,} {it:juxta_options}
] 

{p 8 17 2}{cmd:multidensity} {cmdab:b:ystyle} [ {cmd:,}
{it:bystyle_options} ] 

{p 8 17 2}{cmd:multidensity} {cmd:clear} [ {cmd:,} {it:clear_options} ] 

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see {help weight}. 


{title:Description} 

{p 4 4 2}{cmd:multidensity} is a convenience command for creating and
plotting kernel estimates of probability density for one or (especially)
more variables or for one or (especially) more groups of a specified
variable. It is variously a wrapper for {help twoway__kdensity_gen} and
{help graph twoway}. 

{p 4 4 2}In addition to its more obvious use for probability density
estimates for different variables, or for different groups of a single
variable, {cmd:multidensity} is designed to accommodate tasks such as
exploring the effects of different kernel choices or different
bandwidths with the same data. {cmd:multidensity} is also unusual in
supporting estimates of probability density on various transformed
scales, back-transformed to be shown on the original scale. 

{p 4 4 2}{cmd:multidensity} hinges on {cmd:multidensity generate} for
generating new variables. Once those are in memory, you can draw
whatever graphs you want or even export the results beyond Stata.
However, {cmd:multidensity} offers three kinds of graphs through
subcommands:  

{p 8 8 2}{cmd:multidensity super} superimposes density traces in a
single panel. It is (often) better if you are looking at distributions
with similar magnitudes and identical units of measurement, or even the
same data analysed in different ways.  

{p 8 8 2}{cmd:multidensity juxta} draws separate graphs for each
variable and then uses {help graph combine} to produce a combined display
in which graphs are juxtaposed. It is (usually) better if you are
looking at distributions with very different magnitudes and/or units of
measurement. 

{p 8 8 2}{cmd:multidensity bystyle} is an alternative in which panels
are presented juxtaposed as if using a {help by_option} for different
groups of a single variable. That is not an illusion, as the dataset is
temporarily {help reshape}d to allow such a plot. The result can
sometimes look better than that from {cmd:multidensity juxta}. 

{p 4 4 2}Note that these subcommands, {cmd:super}, {cmd:juxta} and
{cmd:bystyle}, are unusual in not expecting (or even allowing) a
{it:varlist} to be specified. They depend on variables left in memory by
a previous {cmd:multidensity generate}. 

{p 4 4 2}It is very easy to get into a small mess and especially to
change your mind about what is a good idea, so {cmd:multidensity clear}
is a quick way to clear results out of the way, allowing a fresh start. 


{title:Options}

{it:Options of multidensity generate} 

{p 4 8 2}{opt fstub(string)} specifies a stub or prefix for names of
variables containing kernel estimates of probability density for each
specified variable. The default is {cmd:fstub(_density)}. Thus if 4
variables are specified in {it:varlist}, or 4 groups of values specified
by {it:varname} {cmd:, by(}{it:byvar}{cmd:)}, then by default density
estimates will be returned in new or replaced variables
{cmd:_density1-_density4}. 
 
{p 4 8 2}{opt xstub(string)} specifies a stub or prefix for names of
variables containing values on a grid approximating the range of each
specified variable, or a greater range. The default is {cmd:xstub(_x)}.
Thus if 4 variables or 4 groups are specified, by default grid values
will be returned in new variables {cmd:_x1-_x4}. Such values will be
equally spaced on the scale used for estimation. If estimates are
calculated on a transformed scale, grid values will be equally spaced on
that scale, but returned back-transformed to the original scale. 

{p 4 8 2}{opt by(byvar)} (allowed with one {it:varname} only: see
{cmd:generate} syntax 2 above) specifies the name of a grouping
variable. Density estimates will be produced separately for each
distinct value of {it:byvar}. String variables are allowed for
{it:byvar}. Missing values of {it:byvar} will be ignored unless the
{cmd:missing} option is also specified (see immediately below). 

{p 4 8 2}{opt miss:ing} (allowed with one {it:varname} only: see
{cmd:generate} syntax 2 above) specifies that missing values of
{it:byvar} be included in calculations for distinct values specified by
{cmd:by(}{it:byvar}{cmd:)}.  

{p 4 8 2}{opt n(#)} specifies the number of values to be included in
each grid for estimation of probability density. The default is
{cmd:min(_N, 100)}, where {cmd:_N} is the number of observations in the
entire dataset. If {cmd:n()} is specified to exceed {cmd:_N}, it is
reset to {cmd:_N} with a warning. 

{p 4 8 2}{opt min:imum(#)} specifies that the range of each grid be
extended to a minimum of {it:#} if (and only if) {it:#} is smaller than
the observed minimum. 
 
{p 4 8 2}{opt max:imum(#)} specifies that the range of each grid be
extended to a maximum of {it:#} if (and only if) {it:#} is larger than
the observed maximum. 
 
{p 4 8 2}{opt bw:idth(numlist)} specifies one or more bandwidths to
override the default chosen by {help twoway__kdensity_gen}. If one
bandwidth is specified, it is applied to all variables or groups of
values specified. If {cmd:trans()} is also specified, the bandwidth must
be on the transformed scale. That may require some experimentation or at
least some prior experience. 

{p 4 8 2}{opt k:ernel(kernel_list)} specifies one or more kernels to
override the default chosen by {help twoway__kdensity_gen}, which is
always the Epanechnikov kernel. If one kernel is specified, it is
applied to all variables or groups of values specified. 

{p 4 8 2}{opt trans(transformation_list)} specifies one or more
transformations to be applied as follows. Data will be transformed as
specified, probability density estimated on that scale,  and then
estimates will be back-transformed. For a monotone transformation
{it:T}({it:x}) the principle is that for densities {it:f} the estimate of
{it:f}({it:x})} is the estimate of {it:f}({it:T}({it:x})) 
multiplied by |{it:dT/dx}| = |{it:T'}({it:x})|.
For discussion and references, see Cox (2004, pp.76{c -}78). On cube
roots, see also Cox (2011). Allowed transformations are 

{p 8 8 2}{cmd:reciprocal} or {cmd:-1}, noting that all values must be
positive for this transformation to be applied; 

{p 8 8 2}{cmd:log} or {cmd:ln}, meaning natural logarithm, noting that
all values must be positive for this transformation to be applied;  

{p 8 8 2}{cmd:cube_root} or {cmd:1/3} (type without spaces), noting that
this is implemented for positive, zero and negative values alike; 

{p 8 8 2}{cmd:root} or {cmd:square_root} or {cmd:1/2} (type without
spaces}, noting that all values must be positive or zero for this
transformation;  

{p 8 8 2}{cmd:logit}, noting that all values must be strictly between 0
and 1 for this transformation; 

{p 8 8 2}{cmd:identity} or {it:@}, noting that this specification is
needed if (and only if) other transformations are used in the same
command. 

{p 4 8 2}{opt labelwith(specification)} controls the variable labels to
be used for grid variables. By default the variable label of the
original variable is used, or its variable name if no label is attached,
or the value label or value of the distinct group if {cmd:by()} is used.
None of these choices is a good idea if the same data are supplied, but
different kernels, bandwidths or transformations are to be used.
{cmd:labelwith()} allows any or all of {cmd:kernel}, {cmd:bwidth} or
{cmd:trans} to be specified (either in full or as any abbreviation, but
separated by spaces) to indicate use of such elements in variable labels. 

{p 4 8 2}{opt densitylabel(string)} specifies an alternative variable
label for all generated density variables. The default is {cmd:"Density"}. 

{it:Options of multidensity super}

{p 4 8 2}{cmd:fstub()} and {cmd:xstub()}: see above under 
{it:Options of multidensity generate}. 

{p 4 8 2}{opt recast(newplottype)} is flagged as a particularly useful
option. In practice, {cmd:recast(area)} is by far the most useful possibility,
so long as you are using Stata 15 up and can exploit the scope to tune
opacity or transparency. 

{p 4 8 2}{opt vert:ical} specifies that axes should be reversed so that
the variable in question is plotted vertically and its density is plotted
horizontally. One reason for doing that is if the variable is naturally
or conventionally regarded as vertical, say that it is an altitude,
elevation, height or depth, as may be encountered in the Earth or
environmental sciences or archaeology.  

{p 4 8 2}{opt optall(twoway_options)} is a catch-all for options to be
applied to all plotted curves or areas. 

{p 4 8 2}{opt opt1(twoway_options)} ... {opt opt20(twoway_options)}
specify particular options for the 1st density, ..., 20th density
plotted. For example if the 7th density plotted was especially
interesting or important, you might want to assign a special colour or
line thickness using {cmd:opt7()}. The number of 20 such options is
plucked out of the air as more than the number of densities that might
comfortably be distinguished. Any of these options overrides
{cmd:optall()} whenever that is practicable.  

{p 4 8 2}{cmd:addplot()}: see {help addplot_option}. 

{p 4 8 2}{it:twoway_options} are other options of {help twoway}. 

{it:Options of multidensity juxta} 

{p 4 8 2}{cmd:fstub()} and {cmd:xstub()}: see above under 
{it:Options of multidensity generate}. 

{p 4 8 2}{cmd:recast()}: see above under {it:Options of multidensity super}. 

{p 4 8 2}{cmd:vertical}: see above under {it:Options of multidensity super}.
 
{p 4 8 2}{cmd:optall()} and {cmd:opt1()} to {cmd:opt20()}: see above under 
{it:Options of multidensity super}. 

{p 4 8 2}{opt combine:opts()} are options of {help graph combine}. For
example, this is where to specify a name or filename for a saved graph. 

{p 4 8 2}{it:twoway_options} are other options of {help twoway}. 

{it:Options of multidensity bystyle}

{p 4 8 2}{cmd:fstub()} and {cmd:xstub()}: see above under 
{it:Options of multidensity generate}. 

{p 4 8 2}{cmd:recast()}: see above under {it:Options of multidensity super}. 

{p 4 8 2}{cmd:vertical}: see above under {it:Options of multidensity super}. 

{p 4 8 2}{cmd:byopts()} are options of {help by_option}. 

{p 4 8 2}{it:twoway_options} are other options of {help twoway}.
 
{it:Options of multidensity clear}

{p 4 8 2}{cmd:fstub()} and {cmd:xstub()}: see above under 
{it:Options of multidensity generate}. 


{title:Remarks}

{p 4 4 2}{cmd:multidensity} is indicative, not definitive. It encapsulates 
some mild prejudices on how its task is best done and does not purport to
address all possible uses of probability density estimates. In
particular, as {cmd:multidensity} tries to make it as easy as possible
to generate a bundle of variables for graphing, so also its attitude is
that such variables may be {cmd:replace}d on each use. The user can
easily protect result variables thought to be interesting or useful by
careful choice of variable names or a {help save} of the dataset. 

{p 4 4 2}If two or more of {cmd:kernel()}, {cmd:bwidth()} and
{cmd:trans()} are specified, choices are made in parallel, not
nested. Thus {cmd:kernel(biweight epan) bwidth(100 20)} produces two
plots, not four. 

{p 4 4 2}Density estimates are plotted if positive and not plotted if zero. 
This is not a bug. You are at liberty to disagree that it is a feature. 

{p 4 4 2}The use of transformations here is distinct from the often 
sound and sensible idea that a variable should be transformed and
analysed on that scale, period. 

{p 4 4 2}Wilke (2019) is articulate on the merits of plotting density
estimates as areas. My review at Amazon.com may be of interest:
{browse "https://www.amazon.com/gp/customer-reviews/R22MWD7RJ6QAFP":https://www.amazon.com/gp/customer-reviews/R22MWD7RJ6QAFP} 

{p 4 4 2}There are many helpful accounts of density estimation at
various technical levels. The books of Silverman (1986), Scott (1992,
2015) and Simonoff (1996) are especially useful. 


{title:Examples}

{p 4 8 2}{cmd:. set scheme s1color }{p_end}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. label var price "Price (USD)"}{p_end}

{p 4 8 2}{cmd:. multidensity gen price, by(foreign) min(0) max(18000)}{p_end}
{p 4 8 2}{cmd:. multidensity super, name(G1, replace)}{p_end}
{p 4 8 2}{cmd:. multidensity super, recast(area) opt1(lcolor(orange) color(orange%40)) opt2(lcolor(blue) color(blue%40)) title("Price (USD)") name(G2, replace)}{p_end}
{p 4 8 2}{cmd:. su _density1, meanonly }{p_end}
{p 4 8 2}{cmd:. local max = r(max)}{p_end}
{p 4 8 2}{cmd:. su _density2, meanonly }{p_end}
{p 4 8 2}{cmd:. local max = max(`max', r(max))}{p_end}
{p 4 8 2}{cmd:. gen where1 = -`max'/15 }{p_end}
{p 4 8 2}{cmd:. gen where0 = -`max'/30  }{p_end}
{p 4 8 2}{cmd:. local rugcode addplot(scatter where0 price if !foreign, ms(|) mc(orange) || scatter where1 price if foreign, ms(|) mc(blue))}{p_end}
{p 4 8 2}{cmd:. multidensity super, recast(area) opt1(lcolor(orange) color(orange%40)) opt2(lcolor(blue) color(blue%40)) title("Price (USD)") ytitle(Density) `rugcode' name(G3, replace) }{p_end}

{p 4 8 2}{cmd:. multidensity clear }{p_end}
{p 4 8 2}{cmd:. multidensity gen price, kernel(biweight) bw(400 600 800 1000) labelwith(bwidth)  }{p_end}
{p 4 8 2}{cmd:. multidensity super, title(Price (USD)) opt1(lp(dash)) opt3(lp(dash)) xla(4000(4000)16000)  name(G4, replace) }{p_end}
{p 4 8 2}{cmd:. multidensity bystyle, byopts(title(Price (USD)) note("biweight kernels, different bandwidth")) name(G5, replace)}{p_end}

{p 4 8 2}{cmd:. multidensity clear}{p_end}
{p 4 8 2}{cmd:. multidensity gen price, trans(identity root cube_root log)  labelwith(trans)}{p_end}
{p 4 8 2}{cmd:. multidensity bystyle, byopts(title(Price (USD)) note("transform, estimate and back-transform")) name(G6, replace)}{p_end}

{p 4 8 2}{cmd:. multidensity clear }{p_end}
{p 4 8 2}{cmd:. multidensity gen price weight mpg length}{p_end}
{p 4 8 2}{cmd:. multidensity juxta, combineopts(name(G7, replace))}{p_end}
{p 4 8 2}{cmd:. multidensity bystyle, name(G8, replace)}{p_end}
 

{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break}
n.j.cox@durham.ac.uk


{title:References} 

{p 4 8 2}
Cox, N.J. 2004. 
Graphing distributions. 
{it:Stata Journal} 2: 66{c -}88. See esp. pp.76{c -}78. 

{p 4 8 2}
Cox, N.J. 2011. 
Stata tip 96: Cube roots. 
{it:Stata Journal} 11: 149{c -}154. 

{p 4 8 2} 
Scott, D.W. 1992.  
{it:Multivariate Density Estimation: Theory, Practice, and Visualization.}
New York: John Wiley.

{p 4 8 2}
Scott, D.W. 2015.  
{it:Multivariate Density Estimation: Theory, Practice, and Visualization.}
Hoboken, NJ: John Wiley.

{p 4 8 2}
Silverman, B.W. 1986. 
{it:Density Estimation for Statistics and Data Analysis.}
London: Chapman and Hall. 
[British curiosum: author is Sir Bernard Silverman since 2018] 

{p 4 8 2}Simonoff, J.S. 1996. 
{it:Smoothing Methods in Statistics.} 
New York: Springer. 

{p 4 8 2}
Wilke, C.O. 2019. 
{it:Fundamentals of Data Visualization: A Primer on Making Informative and Compelling Figures.}
Sebastopol, CA: O'Reilly. 


{title:Also see} 

{p 4 4 2}
{help kdensity}, {help twoway kdensity}, {help twoway__kdensity_gen}  

