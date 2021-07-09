{smcl}
{* 17 July 2017/10may2019}{...}
{hline}
help for {hi:multidot}
{hline}

{title:Multiple panel dot charts}

{p 8 17 2}
{cmd:multidot} 
{it:yvars} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,}
{opt over(varname)} 
[
{opt sort(varlist)} 
{opt desc:ending} 
{opt miss:ing} 
{opt by(by_options)}
{opt recast(twoway_command)}
{c -(} 
{opt sep:arate}
| 
{opt sep:by(varname)}
{c )-} 
{cmd:savedata(}{it:filename} [{cmd:, replace}]{cmd:)}
{it:twoway_options} 
]  


{title:Description}

{p 4 4 2}
{cmd:multidot} plots two or more {it:yvars} for different levels of a
(numeric or string) identifier variable specified by the required
{cmd:over()} option.  Each {it:yvar} is by default plotted in a dot
chart in a separate panel using {help twoway scatter}. A common
application is to plot variables measured in different units and/or on
very different scales. 

{p 4 4 2}
{cmd:multidot} works with a temporarily restructured dataset in which
different {it:yvars} are {help stack}ed into one. The graph then is
based on use of {cmd:twoway, by()}. The original variable labels (or, if
labels are not defined, variable names) become the value labels of the
stacking variable. 

{p 4 4 2}
By default 

{p 8 8 2} 
The vertical axis shows rank, with low ranks at the bottom
and high ranks at the top. The order can be reversed using the
{cmd:descending} option. 

{p 8 8 2}
Rank is defined by the sort order
of {it:yvars}, so that ordering of values from top to bottom of the
display is in the first instance determined by the first variable
mentioned, with any ties broken in the usual way according to the values
of other variables.  The option {cmd:sort()} may be used to specify
another sort order.  

{p 4 4 2} 
The {cmd:recast()} option opens the door to using the same design for
other kinds of plots, for example bar charts. In each such case, the
command is based on some other {help twoway} plot.

{p 4 4 2}
Default options include 
{cmd:by(_stack, note("") xrescale subtitle(, fcolor(green*0.2) xtitle("") yla(, grid glw(vthin) glc(gs12) valuelabel ang(h) tl(0)))} for all cases; 
{cmd:ms(Oh) mc(dkgreen)} for default dot charts; 
and {cmd:horizontal barw(0.7) blcolor(dkgreen) bfcolor(none) base(0)} for bar
charts. 

{p 4 4 2}
It perhaps deserves emphasis that although plots produced by
{cmd:multidot} have much of the look and feel of those produced by 
{help graph dot} or {help graph hbar} they are produced entirely by 
{help twoway}. Talking of {it:yvars} is a nod to this hybrid flavour: 
as with {cmd:graph dot} and its siblings, the variables concerned are 
in essence regarded as outcomes or responses, even when they are plotted
horizontally. 


{title:Options}

{p 4 8 2}{cmd:over()} specifies an identifier variable defining distinct
or unique observations to be shown on the vertical axis. This is a
required option. 

{p 4 8 2}{cmd:sort()} specifies one or more variables defining the sort
order of observations in the graph. This option may be used to override
the default ordering, as when a user is perverse enough to prefer
alphabetical order by name or desires an idiosyncratic order defined by
a previously constructed variable.  

{p 4 8 2}{cmd:descending} reverses sort order on the vertical axis from
the default. 

{p 4 8 2}{cmd:missing} specifies that observations with some missing values on 
{it:yvars} be included in the sample. The default is to ignore 
observations with any missing values. 

{p 4 8 2}
{cmd:by()} specifies options of the {help by_option:by()} option.  Note
that {cmd:_stack} produced temporarily by the program is already wired
in as {it:varlist} for a {cmd:by()} option. 

{p 4 8 2} 
{cmd:recast()} specifies that the graph be recast to another
{cmd:twoway} type. See help on {help advanced_options:advanced options}. 

{p 4 8 2}
{cmd:separate} specifies that data in different panels for the various
{it:yvars} should be shown differently. There is then scope for
specifying different marker symbols, marker colours, and so forth. 

{p 4 8 2}
{cmd:sepby()} specifies that data be shown differently according to 
the distinct values of the variable named. There is then scope for
specifying different marker symbols, marker colours, and so forth. 

{p 8 8 2}{cmd:separate} and {cmd:sepby()} may not be combined. {cmd:sepby()}
option is not allowed with {cmd:recast()}. 

{p 4 8 2}{cmd:savedata()} specifies that data used to produce the graph be
saved as a separate dataset. The axis variables will be named {cmd:_y}
and {cmd:_rank}. {cmd:separate} or {cmd:sepby()} is ignored for this
purpose. 

{p 4 8 2}{it:twoway_options} are options of {help twoway}. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. multidot price mpg if foreign, over(make)}{p_end}
{p 4 8 2}{cmd:. multidot price mpg if foreign, over(make) recast(bar)}{p_end}
{p 4 8 2}{cmd:. multidot price mpg if foreign, over(make) recast(bar) desc}{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) recast(bar) desc by(row(1)) xla(, ang(v))}{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) recast(bar) desc by(row(1)) xla(, ang(v)) blcolor(blue)}{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) desc by(row(1)) xla(, ang(v)) recast(dropline) lw(thick) lc(orange_red) mc(orange_red) }{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) desc by(row(1)) xla(, ang(v)) recast(spike) lw(vthick)}{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) desc by(row(1)) xla(, ang(v)) recast(spike) lw(vthick) lc(orange_red*0.5)}{p_end}
{p 4 8 2}{cmd:. multidot price mpg weight if foreign, over(make) sort(make) desc by(row(1))   }{p_end}
{p 4 8 2}{cmd:. foreach v in mpg turn trunk headroom {c -(} }{p_end}
{p 4 8 2}{cmd:. 	local lbl`v' "`: var label `v''" }{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}

{p 4 8 2}{cmd:. collapse mpg turn trunk headroom, by(rep78) }{p_end}

{p 4 8 2}{cmd:. foreach v in mpg turn trunk headroom {c -(} }{p_end}
{p 4 8 2}{cmd:. 	label var `v' "`lbl`v''" }{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}

{p 4 8 2}{cmd:. multidot mpg turn trunk headroom, over(rep78) sort(rep78) desc by(row(1)) ms(O) }{p_end}
 
{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input str13 country budget active reservists}{p_end}
{p 4 8 2}{cmd:. "United States"     604.5   1347        865}{p_end}
{p 4 8 2}{cmd:. "India"              51.1   1395       1155}{p_end}
{p 4 8 2}{cmd:. "China"             145.0   2183        510}{p_end}
{p 4 8 2}{cmd:. "Malaysia"            4.2    109         52 }{p_end}
{p 4 8 2}{cmd:. "Singapore"          10.2     73        313}{p_end}
{p 4 8 2}{cmd:. "Vietnam"             4.0    482       5000}{p_end}
{p 4 8 2}{cmd:. "Indonesia"           8.2    396        400}{p_end}
{p 4 8 2}{cmd:. "Philippines"         2.5    125        131}{p_end}
{p 4 8 2}{cmd:. "Taiwan"              9.8    215       1657}{p_end}
{p 4 8 2}{cmd:. "S. Korea"           33.8    630       4500}{p_end}
{p 4 8 2}{cmd:. "Japan"              47.3    247         56}{p_end}
{p 4 8 2}{cmd:. "N. Korea"              .   1190        600}{p_end}
{p 4 8 2}{cmd:. "Australia"          24.2     58         21 }{p_end}
{p 4 8 2}{cmd:. end }{p_end}

{p 4 8 2}{cmd:. label var budget "Defence budget ($ billion)"}{p_end}
{p 4 8 2}{cmd:. label var active "Active forces ('000)"}{p_end}
{p 4 8 2}{cmd:. label var reservists "Reservists ('000)" }{p_end}
{p 4 8 2}{cmd:. note : "Source: The Economist, April 22 2017"}{p_end}
{p 4 8 2}{cmd:. note : "Their source: IISS, 2016"}{p_end}

{p 4 8 2}{cmd:. multidot b a r, over(c) by(row(1) compact) recast(hbar) subtitle(, size(medsmall)) ytitle("") missing bfcolor(eltgreen)}{p_end}

{p 4 8 2}{cmd:. multidot a r b, over(c) by(row(1) compact) recast(hbar) subtitle(, size(medsmall)) ytitle("") xla(#5, labsize(small)) missing bfcolor(eltgreen)}{p_end}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input float order str2 id float(area population HDI GDPpc area2 pop2 GDPpc2)}{p_end}
{p 4 8 2}{cmd:.  1 "BW" 35752 11023425 .953 44886 35.752 11.023425 44.886}{p_end}
{p 4 8 2}{cmd:.  2 "BY" 70552 12997204 .944 45810 70.552 12.997204  45.81}{p_end}
{p 4 8 2}{cmd:.  3 "BE"   892  3613495 .944 38032   .892  3.613495 38.032}{p_end}
{p 4 8 2}{cmd:.  4 "BB" 29479  2504040 .913 27675 29.479   2.50404 27.675}{p_end}
{p 4 8 2}{cmd:.  5 "HB"   419   681032 .952 49570   .419   .681032  49.57}{p_end}
{p 4 8 2}{cmd:.  6 "HH"   755  1830584 .977 64576   .755  1.830584 64.576}{p_end}
{p 4 8 2}{cmd:.  7 "HE" 21115  6243262 .947 44804 21.115  6.243262 44.804}{p_end}
{p 4 8 2}{cmd:.  8 "NI" 47609  7962775 .922 36164 47.609  7.962775 36.164}{p_end}
{p 4 8 2}{cmd:.  9 "MV" 23180  1611119 .908 26560  23.18  1.611119  26.56}{p_end}
{p 4 8 2}{cmd:. 10 "NW" 34085 17912134 .935 38645 34.085 17.912134 38.645}{p_end}
{p 4 8 2}{cmd:. 11 "RP" 19853  4073679 .924 35455 19.853  4.073679 35.455}{p_end}
{p 4 8 2}{cmd:. 12 "SL"  2569   994187 .926 35460  2.569   .994187  35.46}{p_end}
{p 4 8 2}{cmd:. 13 "SN" 18416  4081308 .926 29856 18.416  4.081308 29.856}{p_end}
{p 4 8 2}{cmd:. 14 "ST" 20446  2223081 .905 27221 20.446  2.223081 27.221}{p_end}
{p 4 8 2}{cmd:. 15 "SH" 15799  2889821 .917 32342 15.799  2.889821 32.342}{p_end}
{p 4 8 2}{cmd:. 16 "TH" 16172  2151205 .917 28747 16.172  2.151205 28.747}{p_end}
{p 4 8 2}{cmd:. end}{p_end}

{p 4 8 2}{cmd:. label var area "Area (km{sup:2})"}{p_end}
{p 4 8 2}{cmd:. label var population "Population 2017"}{p_end}
{p 4 8 2}{cmd:. label var HDI "Human Development Index 2017"}{p_end}
{p 4 8 2}{cmd:. label var GDPpc "GDP pc 2017 (Euro)"}{p_end}
{p 4 8 2}{cmd:. label var area2 "Area (000 km{sup:2})"}{p_end}
{p 4 8 2}{cmd:. label var pop2 "Population 2017 (m)"}{p_end}
{p 4 8 2}{cmd:. label var GDPpc2 "GDP pc 2017 (000 Euro)"}

{p 4 8 2}{cmd:. multidot HDI GDPpc2 , over(id) ytitle("") }{p_end}
{p 4 8 2}{cmd:. multidot HDI GDPpc2 , over(id) separate ms(O D) mc(orange blue) ytitle("")}

{p 4 8 2}{cmd:. gen isBY = id == "BY" }{p_end}
{p 4 8 2}{cmd:. multidot HDI GDPpc2 , over(id) sepby(isBY) ms(O D) mc(orange blue) ytitle("")}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, University of Durham, U.K.{break} 
        n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}A suggestion from Eric A. Booth on 
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1403429-multidot-available-on-ssc":Statalist} 
led to the {cmd:separate} and {cmd:sepby()} options. 


{title:Also see}

{p 4 13 2}On-line:  help for {help graph dot}, {help graph bar}                                   

