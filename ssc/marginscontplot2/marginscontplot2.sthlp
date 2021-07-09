{smcl}
{* *! version 1.3.0  04jan2018}{...}
{cmd:help marginscontplot2}{right: Patrick Royston}
{hline}


{title:Title}

{p2colset 5 25 27 2}{...}
{p2col :{hi:marginscontplot2} {hline 2}}Graph margins for continuous predictors{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{{cmd:marginscontplot2}|{hi:mcp2}}
{it:xvar1} [{cmd:(}{it:xvar1a} [{it:xvar1b} ...]{cmd:)}]
[{it:xvar2} [{cmd:(}{it:xvar2a} [{it:xvar2b} ...]{cmd:)}]
[, {it:options advanced_plot_options}
]


{synoptset 27}{...}
{marker marginscontplot2_options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt at(at_list)}}fix values of model covariates{p_end}
{synopt :{opt at1(at1_list)}}define plotting positions for {it:xvar1}{p_end}
{synopt :{opt at2(at2_list)}}define plotting positions for {it:xvar2}{p_end}
{synopt :{opt ci}}display pointwise confidence interval(s){p_end}
{synopt :{opt marg:opts(string)}}options for {cmd:margins}{p_end}
{synopt :{opt name(name [, replace])}}store graph to memory {p_end}
{synopt :{opt nograph}}suppress graph{p_end}
{synopt :{opt pre:fix(string)}}prefix names of created variables (margins and confidence intervals)
with {it:string} [relevant only with {opt saving()}]{p_end}
{synopt :{opt sav:ing(filename [, replace])}}save margins and confidence intervals to file{p_end}
{synopt :{opt sh:owmarginscmd}}show the {cmd:margins} command as issued{p_end}
{synopt :{opt var1(# | var1_spec)}}specifies transformed values of {it:xvar1} for plotting{p_end}
{synopt :{opt var2(# | var2_spec)}}specifies transformed values of {it:xvar2} for plotting{p_end}
{synoptline}

{synopthdr :advanced_plot_options}
{synoptline}
{synopt :{opt area:opts(area_options)}}options of {cmd:graph twoway area} for plots with {opt ci}{p_end}
{synopt :{opt comb:opts(combine_options)}}options of {cmd:graph combine} for plots with {opt ci} in more than one subgroup{p_end}
{synopt :{opt line:opts(line_options)}}options of {cmd:graph twoway line} to modify appearance of plotted line(s){p_end}
{synoptline}
{p2colreset}{...}

{phang}
You must have run an estimation command before using {cmd:marginscontplot2}.


{title:Description}

{pstd}
{cmd:marginscontplot2} provides a graph of the marginal effect of a continuous
predictor on the response variable in the most recently fitted
regression model. See Royston (2013) for details and examples; the paper is 
available at {ul:http://www.stata-journal.com/article.html?article=gr0056}.

{pstd}
When only {it:xvar1} is provided, the plot of marginal effects
is univariate at values of {it:xvar1} specified by the {opt at1()} or
{opt var1()} options. When both {it:xvar1} and {it:xvar2} are provided,
the plot of marginal effects is against values of {it:xvar1} specified
by the {opt at1()} or {opt var1()} options for fixed values of {it:xvar2}
specified by the {opt at2()} or {opt var2()} options. A line is plotted
for each specified value of {it:xvar2}.

{pstd}
{cmd:marginscontplot2} has the distinctive ability to plot marginal effects on
the original scale of {it:xvar1} or {it:xvar2}, even when the model includes
transformed values of {it:xvar1} or {it:xvar2} but does not include {it:xvar1}
or {it:xvar2} themselves. Such a situation arises in models involving simple
transformations such as logs and more complicated transformations such as
fractional polynomials or splines, for example, where non-linear
relationships with continuous predictors are to be approximated.
Transformed covariates are included in the model to achieve this.

{pstd}
{cmd:mcp2} is a synonym for {cmd:marginscontplot2} for those who prefer to
type less.


{title:Options}

{phang}
{opt at(at_list)} fixes values of model covariates other than {it:xvar1} and
{it:xvar2}. {it:at_list} has syntax {it:varname1} {cmd:=} {it:#}
[{it:varname2} {cmd:=} {it:#} ...]. By default, predictions for such
covariates are made at the observed values and averaged across observations. 

{phang}
{cmd:at1(}[{cmd:%}]{it:at1_list}{cmd:)} defines the plotting positions
for {it:xvar1} through the {it:numlist} {it:at1_list}. If the prefix {cmd:%}
is included, {it:at1_list} is interpreted as percentiles of the distribution
of {it:xvar1}. If {opt at1()} is omitted, all the observed values of {it:xvar1}
are used if feasible. Note that {it:xvar1} is always treated as the primary
plotting variable on the X-dimension.

{pmore}
An important technical issue is that if a transformation of {it:xvar1} is
applied such that the first transformed variable is in reverse order with
respect to the values of {it:xvar1}, the plotting values supplied in
{it:at1_list()} must also be reversed. Reversal is not necessary if the
first FP-transformed variable preserves the order of {it:xvar1}. Any FP
transformation whose first power is negative, e.g. FP2(-2, -2), reverses
the order.

{phang}
{cmd:at2(}[{cmd:%}]{it:at2_list}{cmd:)} defines the plotting positions
for {it:xvar2} through the {it:numlist} {it:at2_list}. If the prefix {cmd:%}
is included, {it:at2_list} is interpreted as percentiles of the distribution
of {it:xvar2}. If {opt at2()} is omitted, the observed values of {it:xvar2}
are used if feasible. Note that {it:xvar2} is always treated as the secondary,
'by-variable' for plotting purposes.

{pmore}
See also the technical issue concerned with order-reversing transformations
described under {opt at1()}. It also applies to {it:xvar2} and {it:at2_list}.

{phang}
{opt ci} displays pointwise confidence interval(s) for the fitted values
on the margins plot. For legibility, if more than one line is specified,
each line is plotted on a separate graph.

{pmore}
Note that when >1 line is specified, the individual graphs are
by default scaled differently in each subgroup defined by {it:xvar2}.
The axis values depend on the ranges of x and y values in each subgroup.
To produce the plot, {cmd:marginscontplot2} uses the Stata command
{cmd:graph combine}. You can force equal y-axis and/or x-axis
scaling across the graphs by using one of the options {cmd:combopts(ycommon)},
{cmd:combopts(xcommon)} or {cmd:combopts(ycommon xcommon)}. See also
{it:Advanced plot options}.

{phang}
{opt margopts(string)} supplies options to the {cmd:margins} command.
The option most likely to be needed is {cmd:predict(xb)}, which means
that predicted values and hence margins are on the scale of the linear
predictor. For example, in a logistic regression model, the default
predictions are of the event probabilities. Specifying
{cmd:margopts(predict(xb))} gives margins on the scale of the linear
predictor, i.e. the predicted log odds of an event.

{pmore}
Note that the margins are calculated with the default setting,
{opt asobserved}, for {cmd:margins}. See {helpb margins} for further
information.

{phang}
{cmd:name(}{it:name} [{cmd:, replace}]{cmd:)} stores the graph
of marginal effects in memory. See {helpb name option} for details.

{phang}
{opt nograph} suppresses the graph of marginal effects.

{phang}
{opt prefix(string)} prefixes the names of created variables containing
margins and confidence intervals with {it:string}. Applies only with the
{opt saving()} option, otherwise ignored. May be useful if you are saving
results for different models in order to compare margins graphically. 

{phang}
{cmd:saving(}{it:filename} [{cmd:, replace}]{cmd:)} saves the calculated
margins and their confidence intervals to a file ({it:filename}{cmd:.dta}).
This can be useful for fine-tuning the plot or tabulating the results.

{phang}
{opt showmarginscmd} displays the {cmd:margins} command that
{cmd:marginscontplot2} creates and issues to Stata, to do the
calculations necessary for constructing the plot. This information
can be helpful in fine-tuning the command or identifying problems.

{phang}
{opt var1(# | var1_spec)} specifies plotting values of {it:xvar1}.
If {opt var1(#)} is specified then {it:#} equally spaced values of
{it:xvar1} are used as plotting positions, encompassing the observed range
of {it:xvar1}. Alternatively, {it:var1_spec} may be used
to specify transformed plotting values of {it:xvar1}. The syntax of
{it:var1_spec} is {it:var1} [{cmd:(}{it:var1a} [{it:var1b} ... ]{cmd:)}].
{it:var1} is a variable holding user-specified plotting values of {it:xvar1}.
{it:var1a} is a variable holding transformed values of {it:var1}, and
similarly for {it:var1b} ... if required.

{pmore}
See also {it:Remarks}.

{phang}
{opt var2(# | var2_spec)} specifies plotting values of {it:xvar2}.
If {opt var2(#)} is specified then {it:#} equally spaced values of
{it:xvar2} are used as plotting positions, encompassing the observed range
of {it:xvar2}. Alternatively, {it:var2_spec} may be used
to specify transformed plotting values of {it:xvar2}. The syntax of
{it:var2_spec} is {it:var2} [{cmd:(}{it:var2a} [{it:var2b} ... ]{cmd:)}].
{it:var2} is a variable holding user-specified plotting values of {it:xvar2}.
{it:var2a} is a variable holding transformed values of {it:var2}, and
similarly for {it:var2b} ... if required.

{pmore}
See also {it:Remarks}.

{title:Advanced plot options}

{pstd}
{it:Remark}: {cmd:marginscontplot2} produces acceptable graphs with its default graph
option settings. This section is intended for people who wish to 'tweak'
the appearance of their graphs in a more detailed way.

{pstd}
Note that options {opt areaopts()} and {opt lineopts()}, described below,
may include general {it:graph twoway} options, for example {opt title()}
to change the graph title.

{phang}
{opt areaopts(area_options)} supplies options of {helpb graph twoway area} for
modifying the appearance of plots made including the {opt ci} option.
For example, suppose {it:xvar1} = {cmd:age} is a continuous covariate and
{it:xvar2} = {cmd:race} is a categoric variable with three levels. Imagine
we have fit the linear regression model

{phang2}{cmd:. regress map age i.race}

{pmore}
to a continuous outcome variable called {cmd:map}. The simplest command to
plot fitted values of {cmd:map} for {cmd:age} by {cmd:race}, with confidence
intervals, is

{phang2}{cmd:. marginscontplot2 age race, ci}

{pmore}
which would produce a combination of separate graphs depicting fitted values of
{cmd:age} together with a pointwise 95% confidence band in each subgroup
of {cmd:race}. Suppose we wish to change the default color of the two
boundary lines of the confidence intervals to cyan and make the lines dashed
rather than continuous. We can do this by including {it:area_options}
{cmd:lcolor(cyan)} and {cmd:lpattern(-)}:

{phang2}{cmd:. marginscontplot2 age race, ci areaopts(lcolor(cyan) lpattern(-))}
    
{pmore}
If we also wanted the central lines (i.e. the fitted values) to be colored
red, we could add in {cmd:lineopts()} the {helpb graph twoway line} option
{cmd:lcolor(red)}:

{phang2}{cmd:. marginscontplot2 age race, ci areaopts(lcolor(cyan) lpattern(-)) lineopts(lcolor(red))}
    
{pmore}
Note that we use the {cmd:lcolor()} option twice to pinpoint different
components of the graph. Now, {cmd:marginscontplot2} uses
{helpb graph combine} to produce the final graph from the individual graphs
for the different levels of {cmd:race}. As for any graph created by
{cmd:marginscontplot2}, to store the final graph in memory, we could include
the {opt name()} option:

{phang2}{cmd:. marginscontplot2 age race, ci areaopts(lcolor(cyan) lpattern(-)) lineopts(lcolor(red)) name(my_graph)}

{phang}
{opt combopts(combine_options)} only affects composite graphs as
described under {opt areaopts(area_options)}. {it:combine_options} are
options of {cmd:graph combine}. The most poplar such options are likely
to be {opt saving()}, {opt ycommon}, {opt xcommon}, and some of the
{it:title_options}. For example,

{phang2}{cmd:. marginscontplot2 age race, ci combopts(title(My graph) l1title(map) b2title(Age) saving(my_graph, replace))}

{phang}
{opt lineopts(line_options)} are options of {cmd:graph twoway line} which
modify the appearance of plotted line(s) of fitted values. See {helpb line options}
for details of what is available. Most popular are likely to be {opt lpattern()},
{opt lwidth()} and {opt lcolor()}. For example to change the fitted lines for the
three races in the example above to different line patterns in different colors,
we could enter

{phang2}{cmd:. marginscontplot2 age race, lineopts(lcolor(red cyan brown) lpattern(l - --))}


{title:Remarks}

{pstd}
The version of {opt var1()} with {it:var1_spec} is appropriate for use after
any covariate transformation is used in the model and you want a plot with the
original (untransformed) covariate on the horizontal axis. This includes simple
transformations such as logs and more complicated situations. For example the
model may involve a fractional polynomial model in {it:xvar1} using
{cmd:fracpoly}, {cmd:mfp} or {cmd:fp}. Alternatively, fractional polynomial
transformations of {it:xvar1} may be calculated using {cmd:fracgen} or
{cmd:fp generate}, and the required model fitted to the transformed variables
before applying {cmd:marginscontplot2}. The same facility is available for the
{opt var2()} option. It works in the same way but with {it:xvar2} instead of
{it:xvar1}.

{pstd}
{cmd:marginscontplot2} has been designed to handle quite high-dimensional cases,
i.e. where many margins must be estimated. Be aware, however, that the number of
margins is limited by the maximum matrix size; see {helpb matsize}. This can
be increased if necessary by using the {cmd:set matsize} {it:#} command.
{cmd:marginscontplot2} tells you the smallest value of {it:#} needed to
accommodate the case in question.


{title:Examples}

{pstd}Basic examples{p_end}
{phang2}{stata "sysuse auto, clear"}{p_end}
{phang2}{stata "regress mpg i.foreign weight"}{p_end}
{phang2}{stata "marginscontplot2 weight, name(my_graph)"}{p_end}
{phang2}{stata "marginscontplot2 weight, at1(2000(100)4500) ci"}{p_end}
{phang2}{stata "marginscontplot2 weight foreign, var1(20) at2(0 1)"}{p_end}
{phang2}{stata "marginscontplot2 weight foreign, var1(20) at2(0 1) ci combopts(ycommon imargin(small))"}{p_end}

{pstd}Example using a log-transformed covariate{p_end}
{phang2}{stata "gen logwt = log(weight)"}{p_end}
{phang2}{stata "regress mpg i.foreign c.logwt i.foreign#c.logwt"}{p_end}
{phang2}{stata "quietly summarize weight"}{p_end}
{phang2}{stata "range w1 r(min) r(max) 20"}{p_end}
{phang2}{stata "generate logw1 = log(w1)"}{p_end}
{phang2}{stata "marginscontplot2 weight (logwt), var1(w1 (logw1)) ci"}{p_end}

{pstd}Example using a fractional polynomial model{p_end}
{phang2}{stata "fracpoly: regress mpg weight foreign"}{p_end}
{phang2}{stata "marginscontplot2 weight (Iweig__1 Iweig__2) foreign, var1(20) ci"}{p_end}

{pstd}Example using the new {cmd:fp} fractional polynomial command{p_end}
{phang2}{stata "fp <weight>: regress mpg <weight> turn i.rep78"}{p_end}
{phang2}{stata "marginscontplot2 weight (weight_1 weight_2) rep78, at1(2000(500)5000)"}{p_end}
{phang2}{stata "marginscontplot2 weight (weight_1 weight_2) rep78, var1(20) ci"}{p_end}

{pstd}Do-it-yourself fractional polynomial example{p_end}
{phang2}{stata "fracgen weight -2 -2"}{p_end}
{phang2}{stata "quietly summarize weight"}{p_end}
{phang2}{stata "range w1 r(min) r(max) 20"}{p_end}
{phang2}{stata "generate w1a = (w1/1000)^-2"}{p_end}
{phang2}{stata "generate w1b = (w1/1000)^-2 * ln(w1/1000)"}{p_end}
{phang2}{stata "regress mpg i.foreign##c.(weight_1 weight_2)"}{p_end}
{phang2}{stata "marginscontplot2 weight (weight_1 weight_2), var1(w1 (w1a w1b)) ci"}{p_end}
{phang2}{stata "marginscontplot2 weight (weight_1 weight_2) foreign, var1(w1 (w1a w1b))"}{p_end}

{pstd}Simplified version of the above{p_end}
{phang2}{stata "fracgen w1 -2 -2"}{p_end}
{phang2}{stata "marginscontplot2 weight (weight_1 weight_2) foreign, var1(w1 (w1_1 w1_2))"}{p_end}


{title:Author}

{phang}Patrick Royston{p_end}
{phang}MRC Clinical Trials Unit at UCL{p_end}
{phang}London, UK{p_end}
{phang}j.royston@ucl.ac.uk{p_end}


{title:References}

{phang}
Royston, P. 2013. marginscontplot2: Plotting the marginal effects of continuous predictors.
{it:Stata Journal}, {cmd:13(3)}: 510-527.


{title:Also see}

{psee}
Manual:  {hi:[R] margins}, {hi: [R] marginsplot}, {hi:[R] fracpoly}, {hi:[R] mfp}{p_end}

{psee}
Online:  {helpb margins}, {helpb marginsplot}, {helpb mfp}, {helpb fracpoly}, {helpb fp}{p_end}
