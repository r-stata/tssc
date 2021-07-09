{smcl}
{* *! version 1.4.4 15may2014}{...}
{viewerdialog "stns graph" "dialog stns_graph"}{...}
{vieweralsosee "[ST] stns graph" "mansection ST stnsgraph"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] stns" "help stns"}{...}
{vieweralsosee "[ST] stns list" "help stns_list"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] stset" "help stset"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] kdensity" "help kdensity"}{...}
{viewerjumpto "Syntax" "stns_graph##syntax"}{...}
{viewerjumpto "Description" "stns_graph##description"}{...}
{viewerjumpto "Options" "stns_graph##options"}{...}
{viewerjumpto "Examples" "stns_graph##examples"}{...}
{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{help stns graph:stns graph} {hline 2}}Graph the net survival and net cumulative hazard functions{p_end}
{p2colreset}{...}

{pstd}
{opt using}, {opt age()}, {opt period()}, and {opt rate()} are required to estimate the
 net survival function, net failure function, and net cumulative hazard function. When 
 the rate table is stratified, {opt strata()} is required to match the stratification 
 variables in the dataset and the rate table.
{p_end}

{pstd}
You must {cmd:stset} your data before using {cmd:stns}; see
{manhelp stset ST}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 21 2}{cmd:stns} {opt g:raph} {cmd:using {it:lifetable}} {ifin} [{cmd:,} {it:options}]

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt age:(varname=name)}}varname specifies the age variable in the dataset; name that in the ratetable{p_end}
{synopt :{opt period:(varname=name)}}varname specifies the survival time variable in the dataset; name that in the ratetable{p_end}
{synopt :{opt rate:(name)}}name specifies the rate variable in the ratetable{p_end}
{synopt :{opth st:rata(varlist)}}stratifies on different groups of {it:varlist}{p_end}

{synopt :{opth by(varlist)}}estimates and graph separate functions for each group formed by {it:varlist}{p_end}
{synopt :{opt ci}}shows pointwise confidence bands{p_end}

{syntab:Options}
{synopt :{opt sur:vival}}graphs net survival function; the default{p_end}
{synopt :{opt fail:ure}}graphs net failure function{p_end}
{synopt :{opt cumh:az}}graphs net cumulative hazard function{p_end}

{synopt :{opt sep:arate}}shows curves on separate graphs; default is to show
curves one on top of another{p_end}
{synopt :{opt l:evel(#)}}sets confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt per(#)}}units to be used in reported rates{p_end}
{synopt :{opt nosh:ow}}does not show st setting information{p_end}
{synopt :{opt tmi:n(#)}}shows graph for t >= {it:#}{p_end}
{synopt :{opt tma:x(#)}}shows graph for t <= {it:#}{p_end}
{synopt :{opt ymi:n(#)}}restricts range of values in the vertical axis of the graph to values <= {it:#}{p_end}
{synopt :{opt yma:x(#)}}restricts range of values in the vertical axis of the graph to values >= {it:#}{p_end}

{synopt :{opt atr:isk}}shows numbers at risk at beginning of each interval{p_end}
{synopt :{cmdab:out:file(}{it:{help filename}{cmd:)}}}saves the net survival function in the filename.dta database{p_end}
{synopt :{cmdab:cen:sored(}{opt s:ingle)}}show one hash mark at each censoring
       time, no matter what number is censored{p_end}
{synopt :{cmdab:cen:sored(}{opt n:umber)}}shows one hash mark at each censoring
        time and number censored above hash mark{p_end}
{synopt :{cmdab:cen:sored(}{opt m:ultiple)}}shows multiple hash marks for
	multiple censoring at the same time{p_end}
{synopt :{opth censo:pts(stns_graph##hash_options:hash_options)}}affects
        rendition of hash marks{p_end}

{syntab:At-risk table}
{synopt :{cmdab:riskt:able}}shows table of number at risk beneath graph{p_end}
{synopt :{opth riskt:able(stns_graph##risk_spec:risk_spec)}}shows customized table
of number at risk beneath graph{p_end}
{synopt :{opth atriskop:ts(marker_label_options)}}affects rendition of numbers at risk{p_end}

{syntab:Plot}
{synopt :{opth ploto:pts(cline_options)}}affects rendition of plotted lines{p_end}
{synopt :{cmdab:plot:}{ul:{it:#}}{cmd:opts(}{it:{help cline_options}}{cmd:)}}affects rendition of {it:#}th plotted line; may not be combined with {opt separate}{p_end}

{syntab:CI plot}
{synopt :{opth ciop:ts(area_options)}}affects rendition of confidence bands{p_end}
{synopt :{cmdab:ci:}{ul:{it:#}}{cmd:opts(}{it:{help area_options}}{cmd:)}}affects rendition of {it:#}th confidence band; may not be combined with {opt separate}{p_end}

{syntab:Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}adds other plots to the generated graph{p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall}
{synopt :{it:twoway_options}}any options documented in
      {manhelpi twoway_options G-3}{p_end}
{synopt :{opth byop:ts(by_option:byopts)}}how subgraphs are combined, labeled,
etc.{p_end}
{synoptline}

{marker risk_spec}{...}
{phang}
where {it:risk_spec} is 

{pmore2}
[{it:{help numlist}}][{cmd:,} {it:table_options}
       {opth group:(stns_graph##group:group)}]

{pmore}
{it:numlist} specifies the points at which the number at risk is to
be evaluated, {it:table_options} customizes the table of number at risk,
and {opt group(group)} specifies a specific group/row for {it:table_options}
to be applied.

{marker table_options}{...}
{synoptset 35 tabbed}{...}
{synopthdr:table_options}
{synoptline}
{syntab:Main}
{synopt:{it:{help axis_label_options}}}controls table by using axis labeling
	options; seldom used{p_end}
{synopt:{opt order}{hi:(}{it:{help stns_graph##order_spec:order_spec}}{hi:)}}selects which rows appear and their order{p_end}
{synopt:{opt rightt:itles}}places titles on right side of the table{p_end}
{synopt:{opt fail:events}}shows number failed in the at-risk table{p_end}
{synopt:{it:{help stns_graph##text_options:text_options}}}affects rendition of
	table elements and titles{p_end}

{syntab:Row titles}
{synopt:{opt rowt:itle}{cmd:(}[{it:text}][{cmd:,} {it:{help stns_graph##rtext_options:rtext_options}}]{cmd:)}}changes title for a row{p_end}

{syntab:Title}
{synopt:{opt title}{cmd:(}[{it:text}][{cmd:,} {it:{help stns_graph##ttext_options:ttext_options}}]{cmd:)}}changes
	overall table title{p_end}
{synoptline}

{marker order_spec}{...}
{phang}
where {it:order_spec} is{p_end}

{pmore}
{it:#} [{hi:"}{it:text}{hi:"} [{hi:"}{it:text}{hi:"} ...]] [...]

{marker text_options}{...}
{synoptset 35}{...}
{synopthdr:text_options}
{synoptline}
{synopt:{opth size(textsizestyle)}}size of text{p_end}
{synopt:{opth color(colorstyle)}}color of text{p_end}
{synopt:{opth justification(justificationstyle)}}text left-justified,
	centered, right-justified{p_end}
{synopt:{opth format(%fmt)}}format values per {bf:%}{it:fmt}{p_end}
{synopt:{opth topg:ap(relativesize)}}margin above rows{p_end}
{synopt:{opth bottomg:ap(relativesize)}}margin beneath rows{p_end}

{synopt:{opth style(textstyle)}}overall style of text{p_end}
{synoptline}
{p 4 6 2}{cmd:style()} does not appear in the dialog box.{p_end}

{marker rtext_options}{...}
{synoptset 35}{...}
{synopthdr:rtext_options}
{synoptline}
{synopt:{opth size(textsizestyle)}}size of text{p_end}
{synopt:{opth color(colorstyle)}}color of text{p_end}
{synopt:{opth justification(justificationstyle)}}text left-justified,
	centered, right-justified{p_end}
{synopt:{opt at(#)}}override x position of titles{p_end}
{synopt:{opth topg:ap(relativesize)}}margin above rows{p_end}

{synopt:{opth style(textstyle)}}overall style of text{p_end}
{synoptline}
{p 4 6 2}{cmd:style()} does not appear in the dialog box.{p_end}

{marker ttext_options}{...}
{synoptset 35}{...}
{synopthdr:ttext_options}
{synoptline}
{synopt:{opth size(textsizestyle)}}size of text{p_end}
{synopt:{opth color(colorstyle)}}color of text{p_end}
{synopt:{opth justification(justificationstyle)}}text left-justified,
	centered, right-justified{p_end}
{synopt:{opt at(#)}}override x position of titles{p_end}
{synopt:{opth topg:ap(relativesize)}}margin above rows{p_end}
{synopt:{opth bottomg:ap(relativesize)}}margin beneath rows{p_end}

{synopt:{opth style(textstyle)}}overall style of text{p_end}
{synoptline}
{p 4 6 2}{cmd:style()} does not appear in the dialog box.{p_end}

{marker group}{...}
{synoptset 35}{...}
{synopthdr:group}
{synoptline}
{synopt:{it:#rownum}}specifies group by row number in table{p_end}
{synopt:{it:value}}specifies group by value of group{p_end}
{synopt:{it:label}}specifies group by text of value label associated with
	group{p_end}
{synoptline}

{marker hash_options}{...}
{synoptset 35}{...}
{synopthdr:hash_options}
{synoptline}
{synopt:{it:{help line_options}}}changes look of dropped lines{p_end}
{synopt:{it:{help marker_label_options}}}adds marker labels; any options
documented in {manhelpi marker_label_options G-3}, except {cmd:mlabel()}{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
{opt risktable()} may be repeated and is merged-explicit group; 
see {help repeated options}.{p_end}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stns graph}; see
{manhelp stset ST}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stns graph} graphs the estimated net survival (failure) function or the
estimated net cumulative (integrated) hazard function. See {help stns:stns} 
for an introduction to this command and {manhelp sts_graph ST:sts graph} for 
details about graphical options.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt age}, {opt period}, {opt rate}, and {opt strata} are required to estimate
the net survival/failure function or net cumulative hazard stratified on 
variables in {it:varlist}.

{phang}
{opth by(varlist)}
estimates a separate function for each by-group and plots all the functions 
on one graph. By-groups are identified by equal values of the variables in
{it:varlist}.

{phang}
{opt ci} includes pointwise confidence bands. The default is not to produce
these bands.

{phang}
{opt survival}, {opt failure}, and {opt cumhaz} specify the function to 
graph.

{phang2}
{opt survival} specifies that the net survival function be plotted. This 
option is the default if a function is not specified.

{phang2}
{opt failure} specifies that the net failure function, 1 - S(t+0), be
plotted.

{phang2}
{opt cumhaz} specifies that the estimate of the net cumulative
hazard function be plotted.

{phang}
{opt separate} is meaningful only with {opt by()}; it requests that each 
group be placed on its own rather than one on top of the other. Sometimes 
curves have to be placed on separate graphs -- such as when you specify 
{opt ci} -- because otherwise it would be too confusing.


{dlgtab:Options}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for the
pointwise confidence interval around the net survival, net failure, or net cumulative
hazard function; see {manhelp level R}.

{phang}
{opt per(#)} specifies the units used to report the net survival or failure 
rates. For example, if the analysis time is in years, specifying {cmd:per(100)}
results in rates per 100 person-years.

{phang}
{opt noshow} prevents {cmd:stns graph} from showing the key st variables. This
option is seldom used because most people type {cmd:stset, show} or 
{cmd:stset, noshow} to set whether they want to see these variables mentioned
at the top of the output of every st command; see {manhelp stset ST}.

{phang}
{opt tmin(#)} specifies that the plotted curve be graphed only for t >=
{it:#}. This option does not affect the computation of the function graphed, it only affects 
the portion that is displayed.

{phang}
{opt tmax(#)} specifies that the plotted curve be graphed only for t <=
{it:#}. This option does not affect the computation of the function graphed, it only affects 
the portion that is displayed.

{phang}
{opt ymin(#)} specifies that the plotted curve be graphed only values on the vertical axis >=
{it:#}. This option does not affect the computation of the function graphed, it only affects 
the portion that is displayed.

{phang}
{opt ymax(#)} specifies that the plotted curve be graphed only values on the vertical axis <=
{it:#}. This option does not affect the computation of the function graphed, it only affects 
the portion that is displayed.


{phang}
{opt atrisk} specifies that the numbers at risk at the beginning of
each interval be shown on the plot. The numbers at risk are shown as
small numbers beneath the flat parts of the plotted function.

{phang}
{cmd:censored(single} | {cmd:number} | {cmd:multiple)} specifies that
hash marks be placed on the graph to indicate censored observations.

{phang2}
{cmd:censored(single)} places one hash mark at each censoring time, regardless
of the number of censorings at that time.

{phang2}
{cmd:censored(number)} places one hash mark at each censoring time and
displays the number of censorings about the hash mark.

{phang2}
{cmd:censored(multiple)} places multiple hash marks for multiple censorings
at the same time. For instance, if 3 observations are censored at time 5,
three hash marks are placed at time 5. {cmd:censored(multiple)} is intended for
use when there are few censored observations; if there are too many censored
observations, the graph can look bad. In such cases, we recommend that
{cmd:censored(number)} be used.

{phang}
{opt censopts(hash_options)} specifies options that affect how the hash marks
for censored observations are rendered; see {manhelpi line_options G-3}. When 
combined with {cmd:censored(number)}, {cmd:censopts()} also specifies how the 
count of censoring is rendered; see {manhelpi marker_label_options G-3},
except {cmd:mlabel()} is not allowed.


{dlgtab:At-risk table}

{phang}
{cmd:risktable}[{cmd:(}[{it:{help numlist}}][{cmd:,}
{it:{help stns_graph##table_opts_long:table_options}}]{cmd:)}] displays a 
table showing the number at risk beneath the plot. {opt risktable} may not 
be used with {opt separate}.

{phang}
{opt atriskopts(marker_label_options)} specifies options that affect how the
numbers at risk are rendered; see {manhelpi marker_label_options G-3}. This 
option implies the {opt atrisk} option.

{phang}
See {manhelp sts_graph ST:sts graph} for more details about these options.



{dlgtab:Plot, CI plot, Add plots, Y axis, X axis, Titles, Legend, Overall}

{phang}
See {manhelp sts_graph ST:sts graph} for details about these options.


{marker examples}{...}
{title:Example: Graphing the net cumulative hazard function}

{pstd}Setup{p_end}
{phang2}{cmd:. use rdata}{p_end}
{phang2}{cmd:. stset survtime, failure(cens==1) id(id)}

{pstd}Suppress showing st settings{p_end}
{phang2}{cmd:. stset, noshow}

{pstd}Graph the net survival function for the two categories of {cmd:sex}{p_end}
{phang2}{cmd:. stns graph using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex) by(sex)}

{pstd}Now graph the net cumulative hazard functions for the two categories of {cmd:sex}{p_end}
{phang2}{cmd:. stns graph, cumhaz by(sex)}


{title:Example: Adding an at-risk table}

{pstd}Graph the net survival functions for the two categories of {cmd:sex} in one
plot, including an at-risk table below the graph{p_end}
{phang2}{cmd:. stns graph, by(sex) risktable}

{pstd}Same as above, but put the legend inside the plot rather than below
it{p_end}
{phang2}{cmd:. stns graph, by(sex) risktable}
                   {cmd:legend(ring(0) position(2) rows(2))}

{pstd}Graph the net survival functions for the two categories of {cmd:sex} in one
plot, including an at-risk table below the graph and using the specified row
titles and order of rows for the at-risk table{p_end}
{phang2}{cmd:. stns graph, by(sex)}
                    {cmd:risktable(, order(1 "male" 2 "female"))}

{pstd}Same as above, but left-justify the row titles in the at-risk
table{p_end}
{phang2}{cmd:. stns graph, by(sex)}
                     {cmd:risktable(, order(1 "male" 2 "female")}
                     {cmd:rowtitle(, justification(left)))}

{pstd}Same as above, but align the table title with the rwo titles{p_end}
{phang2}{cmd:. stns graph, by(sex)}
                     {cmd:risktable(, order(1 "male" 2 "female")}
                     {cmd:rowtitle(, justification(left))}
					 {cmd:title(, at(rowtitle)))}{p_end}
