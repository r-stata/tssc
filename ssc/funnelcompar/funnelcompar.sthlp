{smcl}
{* 26mar2010}{...}
{hline}
help for {hi:funnelcompar}{right:(Silvia Forni, Rosa Gini)}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:funnelcompar} }Funnel plot for institutional comparison{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 13 2}
{cmd:funnelcompar} {it:value pop  unit [sdvalue]} {ifin}  {cmd:,} {opt cont:inuous/}{opt binom:ial/}{opt pois:son} [{opt smr}] [
{it:options}] 

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Distribution (mandatory)}
{synopt :{opt cont:inuous}}normal  distribution{p_end}
{synopt :{opt binom:ial}}binomial distribution{p_end}
{synopt :{opt pois:son}}Poisson distribution{p_end}
{synopt :{opt smr}}values are indirectly standardised rates{p_end}

{syntab :Distribution parameters}
{synopt :{opt nowei:ght}}specify that target value and/or standard deviation of the target distribution must be computed from the data, 
but without using {it:pop} as weights {p_end}
{synopt :{opt ext_stand(num)}}specify target value as an external standard, instead of weighted mean of {it:value}{p_end}
{synopt :{opt ext_sd(num)}}specify standard deviation as an external value, instead of weighted mean of {it:sdvalue}{p_end}

{syntab :Contours}
{synopt :{opth c:ontours(numlist:numlist)}} specify significance levels (in percentage) of the contours to be plotted; default is 5% and 0.2%, that is c(5 .2) {p_end} 
{synopt :{opt exac:t}} specify that contours are computed using an exact formula instead of the normal approximation (only valid for 
discrete distributions; implies Stata version 10.0){p_end}
{synopt :{opth contcol:or(colorstyle:color)}}specify colour of the contour lines if {opt shadedcontours} is not specified {p_end}
{synopt :{opt shadedc:ontours}} specify shaded, instead of black, contour lines {p_end}
{synopt :{opt solidc:ontours}} specify solid, instead of dashed, contour lines{p_end}

{syntab :Constant}
{synopt :{opt const:ant(num)}}contains the multiplicative constant by which the 
indicators contained in {it:value} are multiplied, e.g. 100 if they are percentages{p_end}

{syntab :Legend}
{synopt :{opt legendcont:our}}specify that contours should be labeled with labels of the form "Sign. 5%" {p_end} 
{synopt :{opt legendmor:e(options)}}specify any additional graph to be labeled; the {it:options} string must be contained in compound double quotes, e.g. `"3 "lower bound""'{p_end} 
{synopt :{opt legend:options(options)}}specify any {helpb legend_options} {p_end} 


{syntab :Marking options: principal scatter}
{synopt :{opth scattercol:or(colorstyle:color)}}colour of scatter points {p_end}
{synopt :{opt scatter:opts(options)}}other {helpb marker_options} {p_end}
{synopt :{opt unitlab:el(string)}}string to be used in the legend of the scatter points, instead of the variable label of {it:unit} or the string "Units" {p_end}
{synopt :{opt markall} }specify that all scatter points should be labeled with the value label or, if there is no value label, with the actual value of the {it:unit} they represent{p_end}


{syntab :Marking options: contours}
{synopt :{opt markup} }specify that points upper the countour at significance {opt markcontour} should be coloured in {opt markupcolor} and labeled with the label or value of the {it:unit} they represent{p_end}
{synopt :{opth markupcol:or(colorstyle:color)}}option of {opt markup} {p_end}
{synopt :{opt marklow} } specify that points lower the countour at significance {opt markcontour} should be coloured in {opt marklowcolor} {p_end}
{synopt :{opth marklowcol:or(colorstyle:color)}}option of {opt marklow} {p_end}
{synopt :{opt markcon:tour(num)} } option of {opt markup} and/or {opt marklow}, the default is the first contour of the numlist in {opt contours(numlist)} - if {opt contours} is not specified, the default is significance 5%{p_end}

{syntab :Marking options: conditions}
{synopt :{opt markcond(condition)}}must contain a condition valid on the active dataset; specifies that points satisfying that condition  should be coloured in {opt colormarkcond} with {helpb marker_options} contained in {opt optionsmarkcond} 
and that the legend of this scatter should be {opt legendmarkcond} {p_end}
{synopt :{opth colormark:cond(colorstyle:color)}}option of {opt markcond} {p_end}
{synopt :{opt legendmarkcond(string)}}option of {opt markcond} {p_end}
{synopt :{opt optionsmarkcond(options)}}option of {opt markcond} {p_end}
{synopt :{opt markcond1(condition)}... }up to 5 conditions might be specified of the form {opt markcond}{it:i}{opt (condition)}; specifies that points satisfying {opt markcond}{it:i}{opt (string)}  should be coloured in 
{opt colormarkcond}{it:i}{opt (color)} with {helpb marker_options} contained in {opt optionsmarkcond}{it:i}{opt (options)} and that the legend of this scatter should be {opt legendmarkcond}{it:i}{opt (string)} {p_end}

{syntab :Marking options: markunit}
{synopt :{opt marku:nits(# "text" [# ["text"] ...])}}list a set of values of {it:unit} whose scatter point must labeled; if a string is specified after a value, then that string is used to label the unit corresponding to that value, 
otherwise value label or value itself is used{p_end}
{synopt :{opth markcol:or(colorstyle:color)}}specify the colour of the units{p_end}
{synopt :{opt marktextop:tions(options)}}specify any {helpb added_text_options}; default is {it:placement(ne)}  {p_end}

{syntab :Other graph options}
{synopt :{opt vert:ical}}plot a vertical funnel plot instead of a horizontal one{p_end}
{synopt :{opth linecol:or(colorstyle:color)}}specify the colour of the target line{p_end}
{synopt :{opt extra:plot(plot)}}specify additional plots to overlay the funnel plot{p_end}
{synopt :{opt tit:le(string)}}specify {helpb title_options}{p_end}
{synopt :{opt {y|x}tit:le(string)}}specify axis title, see {helpb axis_options}{p_end}
{synopt :{opt aspect:ratio(options)}}specify aspectratio, see {helpb aspect_option}{p_end}
{synopt :{opt twoway:opts(options)}}specify additional {helpb twoway_options} possibly overriding other default or specified options (e.g. legending options){p_end}

{syntab :Programming options}
{synopt :{opt display:command}}show the command that generates the graph{p_end}
{synopt :{opt sav:ing(filename)}}save a dta file ready for funnel generation with the command displayed by {opt displaycommand}, with target value and other information saved as dataset characteristics{p_end}
{synopt :{opt nodra:w}}avoid plotting the graph{p_end}


{synoptline}
{p2colreset}{...}
{pstd}
{it:value} contains the values of the indicator; 
{it:pop} contains the denominators of the indicator or,
if {opt smr} is specified, the expected number of events; {it:unit} contains an identifier of the
units (e.g. institutions) whose indicator values are to be compared with a target value; 
{it:sdvalue} is optionally specified in case the {opt continuous} option 
is also specified, and contains the standard deviations of the indicator values.
{p_end}


{title:Description}

{pstd}
{cmd: funnelcompar} computes data and plots a funnel plot as defined by Spiegelhalter 2005. A scatter plot of an indicator values {it:value} is plotted against a measure of their precision {it:pop}, tipically the sample size, together 
with a target line and control limits (contours), that narrow as the sample size gets bigger. The plot graphically tests whether each value of the indicator is extracted from a target distribution specified by the options. {p_end}

{title:Target distribution and algorithm for parameter definition}

{pstd}
The user must specify a distribution among normal, binomial or
Poisson, respectively with the options {opt continuous}, {opt binomial} or {opt poisson}. The parameters of the target distribution (target value and standard deviation) are then defined. {p_end}
{pstd}
The target value is computed as a default as a weighted mean of {it:value} with weights {it:pop}. If the {opt noweight} option is specified it is computed as a simple mean. Finally, it might be specified by the user as an external value via 
the {opt ext_stand} option. {p_end}
{pstd}
If the distribution is binomial or Poisson with target value {it:t} then the standard deviation is obtained as the squared root of, respectively, {it:t(1-t)} and {it:t}. Only if the distribution is normal the standard deviation 
must be further estimated. As a default it is computed as a weighted mean of {it:sdvalue} with weights {it:pop}. If the {opt noweight} option is specified it is computed as a simple mean of {it:sdvalue}. Finally, it might be specified 
by the user as an external value via the {opt ext_sd} option.{p_end}
{pstd}
If the {opt smr} option is specified
then {opt poisson} must be specified as well, and the target is assumed to be 1 (or the value specified
in the {opt constant} option).{p_end}

{title:Contours}

{pstd}
Plotting the default contours of the funnel plot corresponds to testing if the value of the indicator differ 2 or 3 standard deviations from the target value, as recommended by standard Statistical Process Control principles. Other 
significance values can be chosen with the {opt contours()} option.
{p_end}
{pstd}
If the distribution is discrete (i.e. binomial or Poisson) the {opt exact} option specifies that the contours are plotted with an exact formula, that produces slightly different contours for small values of the indicator. As 
a default the normal approximation is used.{p_end}


{title:Examples}

{pstd}Plot funnel of percentages, specify an external target and specify the legend of the units{p_end}
{phang}{cmd:. funnelcompar  measure pop unit, binom const(100) ext_stand(23) unitlabel("LHAs")}{p_end}

{pstd}Plot funnel of percentages and mark in blue a group of units and in green another group of units{p_end}
{phang}{cmd:. funnelcompar  measure pop unit, binomial const(100) markcond(group==3) legendmarkcond(Group 3) colormarkcond(blue) markcond1(group==5) legendmarkcond1(Group 5) colormarkcond1(green)}{p_end}

{pstd}Plot funnel of indirectly standardised rates, mark in green a single point labelled "Your hospital", display the command and save a dataset containing instructions for plotting the graph again{p_end}
{phang}{cmd:. funnelcompar smr expected hospital, poisson smr  markunit(37 "Your hospital")  display saving(for_funnel)}
{break}
{p_end}

{pstd}Plot funnel of means and label units that fail the test at 0.02% significance{p_end}
{phang}{cmd:. funnelcompar mean pop unit sd, continuous markup marklow markcontour(.2)}
{break}
{p_end}

{title:Authors}

Silvia Forni, Rosa Gini, Agenzia regionale di sanità della Toscana, Italy.
Email: {browse "mailto:rosa.gini@arsanita.toscana.it":rosa.gini@arsanita.toscana.it}

{title:References}

{phang}
Spiegelhalter, DJ. Funnel plots for institutional comparison. {it:Qual. Saf. Health Care} 2002; 11:390-391.{p_end}

{phang}
Spiegelhalter, DJ. Funnel plots for comparing institutional performance. {it:Statist. Med.} 2005; 24:1185–1202.{p_end}


{title:Also see}

{psee}
Silvia Forni, Rosa Gini. Funnel plots for institutional comparisons. {it:2009 UK Stata Users Group meeting.} {browse "http://www.stata.com/meeting/uk09/abstracts.html#gini":abstract} 
{browse "http://ideas.repec.org/s/boc/usug09.html":presentation} 

{psee}
Online:  {helpb confunnel} (if installed)
{p_end}





