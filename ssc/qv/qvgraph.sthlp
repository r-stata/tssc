{smcl}
{* *! version 1.0.1 27JUN2013}{...}

{title:Title}

{p2colset 8 19 24 5}{...}
{p2col :{bf:qvgraph} {hline 2}}Graph command for quasi variances{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax} 

{p 8 34 2}
{cmd:qvgraph}
{varlist} 
[,{opt options}]
{p_end}

	
{synoptset 40}{...}
{p2col:{it:options}}description{p_end}
{p2line 0 10}
{...}
{p2col:{opt ref(string)}}{...}name of reference category; {it:ref_grp} if not specified{p_end}
{p2col:{opt lev:el(#)}}{...}sets the confidence interval between 0-100; default is 95{p_end}
{p2col:{opt hori:zontal}}{...}horizontal orientation{p_end}
{p2col:{opt grpl:abel(# "label" [# "label" ...])}}{...}group labels{p_end}
{p2col:{opt mkl:abel}}{...}place labels at markers{p_end}
{p2col:{opt scat:teroption(scatter_options)}}{...}{it:{help scatter:scatter options}}{p_end}
{p2col:{opt rsp:ikeoption(rspike_options)}}{...}{it:{help twoway rspike:rspike options}}{p_end}
{p2col:{it:twoway_options}}{...}other {it:{help twoway_options:twoway options}}{p_end}
{p2col:{opt sav:ing(prefix[, replace])}}{...}save variables used in the graph{p_end}
{p2line 0 10}

{title:Description}

{p 4 4 2}
{cmd:qvgraph} uses quasi variances (Firth 2003) to plot the point and confidence interval estimates 
for effects of a multi-category variable. A fit model must exists before {cmd:qvgraph}.
{p_end}

{p 4 4 2}
The {it:varlist} accepts either the (n-1) dummy variables of a multi-category variable,
or its equivalent factor variable in the form of {it:i.group}. In both cases,
{it:varlist} has to be included in the previous estimation command.
{p_end}

{p 4 4 2}
{cmd:qvgraph} works by first running the {it:varlist} through {cmd:qv}, and then extracting the results 
to draw the graph. The graph combines a {help scatter:twoway scatter} graph that plots the point estimates 
as the markers, and a {help rpsike:twoway rspike} graph that plots the quasi standard errors as the spikes.
{p_end}


{title:Options}

{p 4 4 2}{it:{ul:Estimating quasi variances}}{p_end}

{p 4 4 2}
{opt ref(string)} names the reference category. If not specified, {it:ref_grp} is used.{p_end}

{p 4 4 2}
{opt lev:el(#)} specifies the level of confidence interval. It accepts numeric values between 0 and 100. The 
default is 95.
{p_end}


{p 4 4 2}{it:{ul:Labeling groups}}{p_end}

{p 4 4 2}
{opt grp:label()} assigns group labels by following these rules:
{p_end}

{p 5 8 2}
a) If this option is specified, the user-supplied labels are used. The syntax to specify labels is the same
as in {cmd: value define lblname}, which is # "label" [# "label" ...].
{p_end}

{p 5 8 2}
b) If the option is not specified and the {it:varlist} contains (n-1) dummy variables, the variable 
names become the value labels. In this case, specifying option ref() is recommended, or 
the program will use {it:ref_grp} to indicate the reference category.
{p_end}

{p 5 8 2}
c) If {opt grp:label()} is not specified and the {it:varlist} contains a factor variable, {cmd:qvgraph} 
first tries to apply the value labels of the factor variable. If the factor variable has no value 
labels, its numeric values are used.
{p_end}

{p 4 4 2}
{opt mkl:abel} places the group labels at the markers. If {opt mklabel} is not specified, {cmd:qvgraph} 
places the labels along the x or y axis.


{p 4 4 2}{it:{ul:Graph options}}{p_end}

{p 4 6 2}
{opt hori:zontal} sets the orientation horizontally. The default orientation is vertical.
{p_end}

{p 4 6 2}
{opt scat:teroption()} takes {help scatter:twoway scatter} options intended for the scatter plot. Use it to control 
the markers.
{p_end}

{p 4 6 2}
{opt rsp:ikeoption()} takes {help twoway rspike} options intended for the rspike graph. Use it to control 
the spikes.
{p_end}

{p 4 6 2}
{it:twoway options} intended for the combined graph should be specified seperately from {opt scatteroption()} 
and {opt rspikeoption()}. This may include controls for the axises, additional lines, and the graph region.
{p_end}

{p 4 6 2}
{opt sav:ing(prefix[, replace])} saves the variables used to plot the graph. This is designed for users who
prefer to build their graphs "from stratch". This option saves four variables with names starting with the
user-specified {it:prefix}:{p_end}
{col 8}a){it:prefix}_g: an indicator for the groups/categories
{col 8}b){it:prefix}_b: the point estimates
{col 8}c){it:prefix}_l: the qv-based lower bound
{col 8}d){it:prefix}_u: the qv-based upper bound

{p 6 6 2}{it:prefix} takes the first six specified characters.{p_end}
{p 6 6 2}{it:replace} is optional. Specifying {it:replace} directs the program to overwrite existing variables.{p_end}

{title:Examples}

{p 5 5 2}{bf: A) Effects of region on a state's death rate}{p_end}
{col 10}{cmd:. sysuse census, clear}
{col 10}{cmd:. gen dpop=death/pop*1000}
{col 10}{cmd:. gen NC=region==2}
{col 10}{cmd:. gen SO=region==3}
{col 10}{cmd:. gen WS=region==4}
{col 10}{cmd:. reg dpop NC SO WS medage}
	
{p 8 8 2} Example 1: dummy variables; horizontal; specified labels placed along the y axis{p_end}
{col 10}{cmd:. qvgraph NC SO WS, hori grplabel(1 Northeast 2 Northcentral 3 South 4 West)          ///}
{col 30}{cmd:rsp(lw(medium) lc(gs2))                                           ///}
{col 30}{cmd:xlab(-2(.5)1, labs(small)) xmtick(-2(.1)1)                        ///}
{col 30}{cmd:xtitle("Effect on death per 1,000 people", size(medsmall))        ///}
{col 30}{cmd:ylab(,val labs(small) nogrid angle(horizontal))                   ///}
{col 30}{cmd:ytitle("Region", size(medsmall)) scheme(s2mono)}
{col 30}{it:({stata "qv_example 1":click to run})}
	
{p 8 8 2} Example 2: dummy variables; horizontal orientation; specified labels placed at markers{p_end}
{col 10}{cmd:. qvgraph NC SO WS, hori grplabel(1 "Northeast" 2 "North central" 3 "South" 4 "West") ///}
{col 30}{cmd:mklab                                                             ///}
{col 30}{cmd:scat(msym(D D D D) mlabgap(2) mlabposition(12) mcolor(gs2))       ///}
{col 30}{cmd:rsp(lw(medium) lc(gs2))                                           ///}
{col 30}{cmd:xtitle("Effect on death per 1,000 people", size(medsmall))        ///}
{col 30}{cmd:scheme(s2gcolor) ylab(,nolab notick nogrid) yscale(r(.5(1)4.5))}
{col 30}{it:({stata "qv_example 2":click to run})}
	
{p 8 8 2} Example 3: dummy variables; vertical; unspecified labels placed along the x axis{p_end}
{col 10}{cmd:. qvgraph NC SO WS, ref(NE) scheme(s2mono)                                            ///}
{col 30}{cmd:rsp(lw(thick) lc(gs8))                                            ///}
{col 30}{cmd:ylab(-2(.5)1, labs(small) glp(dash) glc(gs8) glw(thin))           ///}
{col 30}{cmd:ymtick(-2(.1)1)                                                   ///}
{col 30}{cmd:ytitle("Effect on death per 1,000 people", size(medsmall))        ///}
{col 30}{cmd:xlab(,val labs(small)) xtitle("Region", size(medsmall))           ///}
{col 30}{cmd:xscale(r(.5(1)4.5))}
{col 30}{it:({stata "qv_example 3":click to run})}

{p 8 8 2} Example 4: factor variable; vertical; original value labels placed along the x axis{p_end}
{col 10}{cmd:. reg dpop i.region medage}
{col 10}{cmd:. qvgraph i.region, ytitle("Effect on death per 1,000 people", size(medsmall))         ///}
{col 30}{cmd:xscale(r(.5(1)4.5))}
{col 30}{it:({stata "qv_example 4":click to run})}
					   
{p 8 8 2} Example 5: factor variable; vertical; no value labels placed along the x axis; saves variables{p_end}
{col 10}{cmd:. label value region // strip value labels}
{col 10}{cmd:. qvgraph i.region, ytitle("Effect on death per 1,000 people", size(medsmall))         ///}
{col 30}{cmd:xscale(r(.5(1)4.5)) sav(A,replace)}
{col 30}{it:({stata "qv_example 5":click to run})}
	
	
{p 5 5 2}{bf: B)Effects of region on a country's population growth rate}{p_end}
{col 10}{cmd:. sysuse lifeexp,clear}
{col 10}{cmd:. gen lnlexp=ln(lexp)}
{col 10}{cmd:. reg popgrowth gnppc safewater ib2.region}
	
{p 8 8 2} Example 6: factor variable; vertical; specified labels with non-letter characters{p_end}
{col 10}{cmd:. qvgraph ib2.region, grplabel(1 "Europe/Cen. Asia" 2 "North America" 3 "South America") ///}
{col 32}{cmd:scat(mlabposition(5) mlabgap(2))                                   ///}
{col 32}{cmd:ytitle(Effects on annual % of population growth)                   ///}
{col 32}{cmd:xscale(range(.5 3.5)) xlab(, notick) scheme(sj)}
{col 32}{it:({stata "qv_example 6":click to run})}
	
{title:References}

{marker AP2009}{...}
{phang}
Firth, David. 2003. ¡§Overcoming the Reference Category Problem in the Presentation of Statistical Models.¡¨{it:Sociological Methodology} 33(1): pp 1¡V18.
{p_end}
