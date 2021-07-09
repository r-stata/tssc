{smcl}
{* 26mar2010}{...}
{hline}
help for {hi:funnelperform}{right:(Brent McSharry, Silvia Forni, Rosa Gini)}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:funnelperform} }Funnel plot for institutional comparison{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 13 2}
{cmd:funnelperform} {it:outcome population_size identifier [std_dev]} {ifin} [{help weight:iweight}] {cmd:,} {opt cont:inuous/}{opt binom:ial/}{opt pois:son/}{opt gamma:/}{opt beta: }} [{opt smr}] [
	{it:options}] 

{synoptset 28 tabbed}{...}
{syntab :Variables}
{synopt :outcome}Y-axis such as standardised mortality ratio (SMR) or risk adjusted rate{p_end}
{synopt :population_size}X-axis such as the number of cases performed or number of expected failures{p_end}
{synopt :identifier}The identifier for each data point such as institution or surgeon name{p_end}

{syntab :iweight}
{synopt :iw={it:varname}}when using beta distribution & the x-axis is the expected number of failures, will weight confidence intervals by the size of the population at risk. See examples below.{p_end}

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Distribution (mandatory)}
{synopt :{opt cont:inuous }}normal  distribution{p_end}
{synopt :{opt binom:ial }}binomial distribution{p_end}
{synopt :{opt pois:son }}Poisson distribution{p_end}
{synopt :{opt gamma: }}gamma distribution{p_end}
{synopt :{opt beta: }}beta distribution{p_end}
{synopt :{opt smr}}values are indirectly standardised rates{p_end}

{syntab :Distribution parameters}
{synopt :{opt nowei:ght}}specify that target value and/or standard deviation of the target distribution must be computed from the data, 
but without using {it:pop} as weights {p_end}
{synopt :{opt ext_stand(num)}}specify target value as an external standard, instead of weighted mean of {it:value}{p_end}
{synopt :{opt ext_sd(num)}}specify standard deviation as an external value, instead of weighted mean of {it:sdvalue}{p_end}

{syntab :Contours}
{synopt :{opth c:ontours(numlist:numlist)}}specify significance levels (in percentage) of the contours to be plotted; default is 95.45% and 99.73% (2 & 3 standard deviations){p_end}
{synopt :{opt exac:t}}specify that contours are computed using an exact formula instead of the normal approximation (only valid for discrete distributions; implies Stata version 10.0){p_end}
{synopt :{opth contcol:or(colorstyle:color)}}specify colour of the contour lines if {opt shadedcontours} is not specified {p_end}
{synopt :{opt shadedc:ontours}}specify shaded, instead of black, contour lines {p_end}
{synopt :{opt solidc:ontours}}specify solid, instead of dashed, contour lines{p_end}
{synopt :{opt n: }}number of points connecting the the contour lines. Default is 100.{p_end}

{syntab :Constant}
{synopt :{opt const:ant(num)}}contains the multiplicative constant by which the 
indicators contained in {it:value} are multiplied on the y-axis, e.g. 100 if they are percentages{p_end}

{syntab :Legend}
{synopt :{opt legendcont:our}}specify that contours should be labeled with labels of the form "Sign. 95%" {p_end}
{synopt :{opt legendmor:e(options)}}specify any additional graph to be labeled; the {it:options} string must be contained in compound double quotes, e.g. `"3 "lower bound""'{p_end}
{synopt :{opt legend:options(options)}}specify any {helpb legend_options} {p_end}


{syntab :Marking options: principal scatter}
{synopt :{opth scattercol:or(colorstyle:color)}}colour of scatter points {p_end}
{synopt :{opt scatter:opts(options)}}other {helpb marker_options} and {helpb marker_label_options}{p_end}
{synopt :{opt unitlab:el(string)}}string to be used in the legend of the scatter points, instead of the variable label of {it:unit} or the string "Units" {p_end}
{synopt :{opt markall: }}specify that all scatter points should be labeled with the value label or, if there is no value label, with the actual value of the {it:unit} they represent{p_end}

{syntab :Marking options: contours}
{synopt :{opt markup: }}specify that points upper the countour at significance {opt markcontour} should be coloured in {opt markupcolor} and labeled with the label or value of the {it:unit} they represent{p_end}
{synopt :{opth markupcol:or(colorstyle:color)}}option of {opt markup} {p_end}
{synopt :{opt marklow: }}specify that points lower the countour at significance {opt markcontour} should be coloured in {opt marklowcolor} {p_end}
{synopt :{opth marklowcol:or(colorstyle:color)}}option of {opt marklow} {p_end}
{synopt :{opt markcon:tour(num)} }option of {opt markup} and/or {opt marklow}, the default is the first contour of the numlist in {opt contours(numlist)} - if {opt contours} is not specified, the default is significance 95%{p_end}
{synopt :{opt trunc0: }}truncate the confidence intervals at 0. Use when the y axis represents a rate or ratio for which a negatve number could not exist{p_end}

{syntab :Marking options: conditions}
{synopt :{opt markcond(condition)}}must contain a condition valid on the active dataset; specifies that points satisfying that condition should be coloured in {opt colormarkcond} with {helpb marker_options} and {helpb marker_label_options} contained in {opt optionsmarkcond} 
and that the legend of this scatter should be {opt legendmarkcond} {p_end}
{synopt :{opth colormark:cond(colorstyle:color)}}option of {opt markcond} {p_end}
{synopt :{opt labelcond: }}display individual unit identifiers for units satisfying the {opt markcond}. default is not to display individual unit identifiers{p_end}
{synopt :{opt legendmarkcond:(string)}}the string to print in the legend associated with the relevant {opt markcond} {p_end}
{synopt :{opt optionsmarkcond:(options)}}{helpb marker_options}.option of {opt markcond} {p_end}
{synopt :{opt markcond1:(condition)}... }up to 3 additional conditions might be specified of the form {opt markcond}{it:#}{opt (condition)}; specifies that points satisfying {opt markcond}{it:#}{opt (condition)} should be coloured in 
{opt colormarkcond}{it:#}{opt (color)} with the {helpb marker_options} contained in {opt optionsmarkcond}{it:#}{opt (options)} and that the legend of this condition grouping should display the string in {opt legendmarkcond}{it:#}{opt (string)} {p_end}

{syntab :Marking options: markunit}
{synopt :{opt marku:nits(# [# ...])}}list a set of values of {it:unit} whose scatter point must labeled; The value label or value itself is used as a label{p_end}
{synopt :{opt labelu:nits(v "d" [v "d"..])}}custom labels where v is the value and d is the display name{p_end}
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
{cmd: funnelperform} computes data and plots a funnel plot as defined by Spiegelhalter 2005. A scatter plot of an indicator values {it:value} is plotted against a measure of their precision {it:pop}, typically the sample size, together 
with a target line and control limits (contours), that narrow as the sample size gets bigger. The plot graphically tests whether each value of the indicator is extracted from a target distribution specified by the options. {p_end}

{pstd}funnelperform was forked off the user written command {cmd: funnelcompar} written by Silvia Forni & Rosa Gini, in order to address a few issues - namely 
a) if the program fails the data (both variables and number of observations) should be left untouched;
b) gama and beta distributions have been added;
c) exact methods are significantly more performant with smoother contour lines;
d) labeling of the data points handles string names and encoded (labeled) integers equally as well;
e) scatteroptions will accept {help marker_label_options} in order to make it easier to avoid overlapping labels;
f) a trunc0 option to prevent confidence intervals being displayed below 0, for instances where this would be impossible;
g) confidence intervals now default to 95.45 & 99.73 (2 & 3 std deviations);
h) fix const option so that y-axis labels change but graph appears the same;
i) add labelunits option allowing consistent syntax whether the identifier storage type is numeric or string
j) more examples including data are included in this help file;
{p_end}

{title:Target distribution and algorithm for parameter definition}

{pstd}
The user must specify a distribution among normal, binomial, beta, gamma or
Poisson, respectively with the appropriate option. The parameters of the target distribution (target value and standard deviation) are then defined. {p_end}
{pstd}
The target value is computed as a default as a weighted mean of {it:value} with weights {it:pop}. If the {opt noweight} option is specified it is computed as a simple mean. Finally, it might be specified by the user as an external value via 
the {opt ext_stand} option. {p_end}
{pstd}
If the distribution is binomial or Poisson with target value {it:t} then the standard deviation is obtained as the squared root of, respectively, {it:t(1-t)} and {it:t}. Only if the distribution is normal the standard deviation 
must be further estimated. As a default it is computed as a weighted mean of {it:sdvalue} with weights {it:pop}. If the {opt noweight} option is specified it is computed as a simple mean of {it:sdvalue}. Finally, it might be specified 
by the user as an external value via the {opt ext_sd} option.{p_end}
{pstd}
If the {opt smr} option is specified
then {opt poisson} or {opt gamma} or {opt beta} (in the case of a beta SMR, an iweight must also be specified) must be specified as well, and the target is assumed to be 1 (or the value specified
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

{pstd}Setup{p_end}
{phang2}Create individual patient data{p_end}
{phang2}. {stata clear}{p_end}
{phang2}. {stata set obs 2000}{p_end}
{phang2}. {stata gen unit = irecode(_n,50,150,300,500,750,1250)}{p_end}
{phang2}. {stata gen float risk_of_death = uniform()*.2}{p_end}
{phang2}. {stata gen byte died=uniform()+cond(unit==3,0.25,0.1)}{p_end} 
{phang2}Collapse patient data down by unit{p_end}
{phang2}. {stata collapse (sum) risk_of_death died (count) freq=died, by(unit)}{p_end}

{phang2}Create summary statistics{p_end}
{phang2}. {stata gen smr = died/ risk_of_death}{p_end}
{phang2}. {stata sum died, meanonly}{p_end}
{phang2}. {stata gen ramr = smr*r(sum)/2000}{p_end}
{phang2}. {stata label variable risk_of_death "predicted number of deaths"}{p_end}
{phang2}. {stata label variable freq "number of procedures"}{p_end}
{phang2}. {stata label variable ramr "risk adjusted mortality rate"}{p_end}
{phang2}. {stata gen byte mlabpos = _n}{p_end}
{phang2}. {stata gen byte group = mod(unit,3)}{p_end}
{phang2}. {stata label define tmplbl 1 "OS1"}{p_end}
{phang2}. {stata label values unit tmplbl}{p_end}

{pstd}Application{p_end}
{phang2}gamma distribution agains predicted number of deaths{p_end}
{phang2}. {stata funnelperform smr risk_of_death unit , gamma markup marklow smr}{p_end}
{phang2}beta distribution agains predicted number of deaths, weighted by total number of cases. When using this option, the contours can only have as many points as there are data points{p_end}
{phang2}. {stata funnelperform smr risk_of_death unit [iw= freq], beta smr markup markall}{p_end}
{phang2}beta distribution agains number of cases. const(100) displays risk adjusted mortality rate as a percentage on the y-axis{p_end}
{phang2}. {stata funnelperform ramr freq unit , beta markup marklow markall scatteropt(mlabv(mlabpos)) const(100) ytitle("risk adj mortality (%)")}{p_end}
{phang2}using the binomial distribution to calculate mean and standard deviation from the data points provided, then applying normal distribution confidence intervals.
The exact option would display binomial distribtion confidence intervals{p_end}
{phang2}. {stata funnelperform ramr freq unit, binomial markup marklow markall const(100)}{p_end}
{phang2}poisson confidence intervals. Display 95% & 99% conficence intervals, rather than 2 & 3 std deviation{p_end}
{phang2}. {stata funnelperform ramr freq unit, pois markup marklow markall exact const(100) contour(95 99)}{p_end}
{phang2}applying an externally derived reference line (1.0) and standard deviation, notmal distribution confidence intervals{p_end}
{phang2}. {stata funnelperform smr freq unit, cont markup markall ext_sd(3.9) ext_stand(1) trunc0 unitlabel("LHAs")}{p_end}
{phang2}Plot funnel of percentages and mark in blue a group of units and in green another group of units{p_end}
{phang2}. {stata funnelperform ramr freq unit, binomial const(100) markcond(group==0) legendmarkcond(Group 0) colormarkcond(blue) markcond1(group==1) labelcond1 legendmarkcond1(Group 1) colormarkcond1(green)}{p_end}
{phang2}Plot funnel of indirectly standardised rates, mark in green a single point labelled "Your hospital", display the command and save a dataset containing instructions for plotting the graph again{p_end}
{phang2}. {stata funnelperform smr risk_of_death unit, poisson smr labelunit(2 "Your hospital") markunit(4) display saving(for_funnel)}{p_end}

{phang2}And if the unit variable is of string data type{p_end}
{phang2}. {stata tostring unit, replace force}{p_end}
{phang2}. {stata replace unit="unit 2" if unit=="2"}{p_end}
{phang2}. {stata funnelperform smr risk_of_death unit, poisson smr labelunit(4 "Your unit" "unit 2" "Sister unit") markunit(5)}{p_end}

{title:Notes for those wanting to improve or help with this project}
{pstd}The project is hosted on github at {browse "https://github.com/mcshaz/funnelperform"}. Raising new issues and pull requests are always welcome. 
Please note that for tracing purposes it may be easier to comment out the capture statement and closing bracket. 
This capture block exists so that if the program encounters an error while calculating exact confidence intervals, the user is not faced with a different size data set than prior to the command. 
This capture statement will need to be uncommented prior to submitting a pull request.
Please also check that every example above produces a plot with the appropriate marker labels, marker colors, legend etc.{p_end}

{title:Updating Author}
Brent Mcharry, Starship Children's Hospital, Auckland, New Zealand
Email: {browse "mailto:brentm@adhb.govt.nz":brentm@adhb.govt.nz}

{title:Original Authors}
Silvia Forni, Rosa Gini, Agenzia regionale di sanità della Toscana, Italy.
Last Known Email: {browse "mailto:rosa.gini@arsanita.toscana.it":rosa.gini@arsanita.toscana.it}

{title:References}
{phang}
Spiegelhalter, DJ. Funnel plots for institutional comparison. {it:Qual. Saf. Health Care} 2002; 11:390-391.{p_end}
{phang}
Spiegelhalter, DJ. Funnel plots for comparing institutional performance. {it:Statist. Med.} 2005; 24:1185–1202.{p_end}


{title:Also see}

{psee}Silvia Forni, Rosa Gini. Funnel plots for institutional comparisons. {it:2009 UK Stata Users Group meeting}.  See the
{browse "http://www.stata.com/meeting/uk09/abstracts.html#gini":abstract} or the
{browse "http://repec.org/usug2009/Gini-Forni.pdf":presentation(pdf)}
{p_end}
{psee} {helpb confunnel} (Contour-enhanced funnel plots for meta-analysis).{p_end}
{psee} {helpb extfunnel} (graphical augmentations to the funnel plot to indicate the potential impact of a new study on an existing meta-analysis).{p_end}

