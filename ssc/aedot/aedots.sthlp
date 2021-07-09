{smcl}
{* *! aedots version 1.0 18Dec2019}{...}
{cmd:help aedots}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:aedots} {hline 2} Dot plot for summary level adverse event data}{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmdab:aedots} {varname} {cmd:,} {opth n1(varname)} {opth n2(varname)} {opth tot1(varname)} {opth tot2(varname)} [{it:options}]

{phang}
{bf:aedots} requires summary data in long format with one row per event, where {varname} indicates the variable that contains the event name/identifier.
 {varname}  may be a numeric or a string variable.

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt n1(varname)}}variable indicating the number of participants in the first treatment group with the event specified in {varname} (must be numeric){p_end}
{p2coldent:* {opt n2(varname)}}variable indicating the number of participants in the second treatment group with the event specified in {varname} (must be numeric){p_end}
{p2coldent:* {opt tot1(varname)}}variable indicating the total number of unique participants in the first treatment group (must be numeric){p_end}
{p2coldent:* {opt tot2(varname)}}variable indicating the total number of unique participants in the second treatment group (must be numeric){p_end}
{synopt:{cmdab: sav:ing(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}saves the dataset with event level summary data used for the plot in {it:filename}{cmd:.dta}{p_end}
{synopt:{cmdab: graphsave(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}saves the plot in {it:filename}{cmd:.gph}{p_end}
{synopt:{opt clear}} if specified the newly created dataset is stored in memory. Without {cmd:clear} the original dataset is retained in memory{p_end}

{synopt:{opt riskd:iff(#)}} specify whether relative risk or risk difference plotted; {cmd:riskdiff(0)} plots the relative risk and {cmd:riskdiff(1)} plots the risk difference, default is {cmd:riskdiff(0)}{p_end}

{synopt:{opt leftxtitle(string)}}title for the x-axis on the plot on the left; the default label is {it:"Percentage"}{p_end}
{synopt:{cmd: leftcolor1(}{it:{help colorstyle}})}marker colour for the first treatment group values on the plot on the left; default is {cmd:leftcolor1(blue)}{p_end}
{synopt:{opt leftcolsat1(#)}}marker colour saturation for the first treatment group values on the plot on the left; default is {cmd:leftcolsat1(50)}{p_end}
{synopt:{cmd: leftcolor2(}{it:{help colorstyle}})}marker colour for the second treatment group values on the plot on the left; default is {cmd:leftcolor2(red)}{p_end}
{synopt:{opt leftcolsat2(#)}}marker colour saturation for the second treatment group values on the plot on the left; default is {cmd:leftcolsat2(50)}{p_end}
{synopt:{cmd: leftsymb1(}{it:{help symbolstyle}})}marker symbol for the first treatment group values on the plot on the left; default symbol is {cmd:leftsymb1(circle)}{p_end}
{synopt:{cmd: leftsymb2(}{it:{help symbolstyle}})}marker symbol for the second treatment group values on the plot on the left; default symbol is  {cmd:leftsymb2(circle)}{p_end}
{synopt:{opt leftlabsize(#)}}size of labels on the y-axis for the plot on the left; default is {cmd:leftlabsize(1)}{p_end}
{synopt:{opt leftlabang(#)}}label angle on the y-axis for the plot on the left; default is {cmd:leftlabang(0)} to give horizontal labels{p_end}
{synopt:{opt leftlabel(string)}}used to override y-axis labels on the plot on the left. See {it:{help graph dot}} {cmd:relabel} for further details{p_end}

{synopt:{opt rightxline(#)}}vertical line position on the plot on the right; default is {cmd:rightxline(0)}{p_end}
{synopt:{cmd: rightxlinepat(}{it:{help linepattern}})}vertical line style on the plot on the right; default is {cmd:rightxlinepat(dash)}{p_end}
{synopt:{cmd: rightxlinecol(}{it:{help colorstyle}})}vertical line colour on the plot on the right; default is {cmd:rightxlinecol(bluishgray)}{p_end}
{synopt:{cmd: rightdcolor(}{it:{help colorstyle}})}horizontal grid line colour on the plot on the right; default is {cmd:rightdcolor(white)}{p_end}
{synopt:{cmd: rightdotcol(}{it:{help colorstyle}})}marker colour on the plot on the right; default is {cmd:rightdotcol(black)}{p_end}
{synopt:{opt rightdotsat(#)}}marker colour saturation on the plot on the right; default is {cmd:rightdotsat(60)}{p_end}
{synopt:{cmd: rightlincol(}{it:{help colorstyle}})}line colour of the confidence interval on the plot on the right; default is {cmd:rightlincol(black)}{p_end}
{synopt:{opt rightlinsat(#)}}colour saturation of the confidence interval on the plot on the right; default is {cmd:rightlinsat(60)}{p_end}

{synopt:{opt legendleftyn(#)}} specify whether legend appears on the plot on the left; {cmd:legendleftyn(#)} takes values 0 to indicate legend off or 1 to indicate legend on, default is {cmd:legendleftyn(1)}{p_end}
{synopt:{opt legendleft1(string)}}specify text for the legend to describe the first treatment group for the plot on the left; default text is {it:"Group 1"}{p_end}
{synopt:{opt legendleft2(string)}}specify text for the legend to describe the second treatment group for the plot on the left; default text is {it:"Group 2"}{p_end}
{synopt:{opt legendleftpos(#)}}specify position of the legend on the plot on the left; default is {cmd:legendleftpos(6)}{p_end}
{synopt:{opt legendleftcol(#)}}number of columns in the legend on the plot on the left; default is {cmd:legendleftcol(2)}{p_end}
{synopt:{opt legendleftrow(#)}}number of rows in the legend on the plot on the left; default is {cmd:legendleftrow(1)}{p_end}

{synopt:{opt legendrightyn(#)}} specify whether legend appears on the plot on the right; {cmd:legendrightyn(#)} takes values 0 to indicate legend off or 1  to indicate legend on, default is {cmd:legendrightyn(1)}{p_end}
{synopt:{opt legendright1(string)}}specify text to describe the point estimate in the legend on the plot on the right; default text is {it:"log10(Relative risk)"} if {cmd:riskdiff(0)} and {it:"Risk difference"} if {cmd:riskdiff(1)}{p_end}
{synopt:{opt legendright2(string)}}specify text to describe the 95% confidence interval in the legend on the plot on the right; default text is {it:"95% CI"}{p_end}
{synopt:{opt legendrightpos(#)}}specify position of the legend on the plot on the right; default is {cmd:legendrightpos(6)}{p_end}
{synopt:{opt legendrightcol(#)}}number of columns in the legend on the plot on the right; default is {cmd:legendrightcol(2)}{p_end}
{synopt:{opt legendrightrow(#)}}number of rows in the legend on the plot on the right; default is {cmd:legendrightrow(1)}{p_end}

{synopt:{opt bleftmargin(#)}}adds a margin of empty space to the bottom of the plot on the left; default is {cmd:bleftmargin(0)}. This can be used to help align the plots.{p_end}
{synopt:{opt tleftmargin(#)}}adds a margin of empty space to the top of the plot on the left; default is {cmd:tleftmargin(0)}. This can be used to help align the plots.{p_end}
{synopt:{opt aspectleft(#)}}sets the aspect of the plot on the left; default is {cmd:aspectleft(0)}. See {it:{help aspectratio}} for further details.{p_end}
{synopt:{opt brightmargin(#)}}adds a margin of empty space to the bottom of the plot on the right; default is {cmd:brightmargin(2)}. This can be used to help align the plots.{p_end}
{synopt:{opt trightmargin(#)}}adds a margin of empty space to the top of the plot on the right; default is {cmd:trightmargin(5)}. This can be used to help align the plots.{p_end}
{synopt:{opt aspectright(#)}}sets the aspect of the plot on the right; default is {cmd:aspectright(0)}. See {it:{help aspectratio}} for further details.{p_end}

{synopt:{opt title(string)}}specify an overall title for the plot{p_end}
{synopt:{opt subtitle(string)}}specify an overall subtitle for the plot{p_end}
{synopt:{cmd: grphcol(}{it:{help colorstyle}})}colour of the graph background; default is {cmd:grphcol(white)}{p_end}
{synopt:{cmd: plotcol(}{it:{help colorstyle}})}colour of the plot background; default is {cmd:plotcol(white)}{p_end}

{synoptline}
{p2colreset}{...}
{pstd}*   {cmd:n1}, {cmd:n2}, {cmd:tot1} and {cmd:tot2} are
required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:aedots} creates a dot plot for summary level adverse event data from a two-arm clinical trial, 
as proposed by {help aedots##R2008:Amit, Heiberger, and Lane (2008)}. 
The dot plot produces two graphs plotted adjacent to each other. The first plot on the left of the graph
displays the incidence of each event by treatment arm giving a visual summary of absolute differences. 
The second plot on the right of the graph displays either the relative risk with corresponding 95% 
confidence interval or the risk difference with  corresponding 95% confidence interval.
Events are ordered by largest positive difference through to largest negative difference.


{marker options}{...}
{title:Options}

{phang}
{opt n1(varname)} variable indicating the number of participants in the first treatment group with the event specified in {varname}.  
{cmd:n1(varname)} is required and must be a numeric variable.

{phang}
{opt n2(varname)} variable indicating the number of participants in the second treatment group with the event specified in {varname}.  
{cmd:n2(varname)} is required and must be a numeric variable.

{phang}
{opt tot1(varname)} variable indicating the total number of unique participants in the first treatment group.  
{cmd:tot1(varname)} is required and must be a numeric variable.

{phang}
{opt tot2(varname)} variable indicating the total number of unique participants in the second treatment group.  
{cmd:tot2(varname)} is required and must be a numeric variable.

{phang}
{cmdab:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)} saves the dataset
with the newly generated event level summary data. This data is used to produce the plot.  
A new filename is required unless {opt replace} is also specified.
{opt replace} allows the {it:filename} to be overwritten with new data. 

{phang}
{cmdab: graphsave(}{it:{help filename}}[{cmd:, replace}]{cmd:)} saves the plot in {it:filename}{cmd:.gph}.
A new filename is required unless {opt replace} is also specified.
{opt replace} allows the {it:filename} to be overwritten with new plot. 

{phang}
{opt clear} if specified the newly created dataset is stored in memory. 
If {cmd:clear} not specified the original dataset is retained in memory.

{phang}
{opt riskdiff(#)} specifies whether the relative risk and corresponding confidence
interval or risk difference and corresponding confidence interval will be plotted;
{cmd:riskdiff(0)} plots the relative risk and {cmd:riskdiff(1)} plots the risk difference.
{cmd:riskdiff(#)} can only take values 0 or 1. The default is {cmd:riskdiff(0)}.

{phang}
{opt leftxtitle(string)} specifies the title for the x-axis on the
plot on the left of the overall plot.
The default label is {it:"Percentage"}.

{phang}
{cmd:leftcolor1(}{it:{help colorstyle}}) specifies the marker colour for the first treatment group values
on the plot on the left of the overall plot.
{cmd:leftcolor1()} must be one of Stata's {it:{help colorstyle}}. The default marker colour is {cmd:leftcolor1(blue)}.

{phang}
{cmd:leftcolsat1(}{it:{help colorstyle}}) specifies the marker colour saturation for the first treatment group values
on the plot on the left of the overall plot.
{cmd:leftcolsat1(#)} accepts integer values between 0 and 100 inclusive. The default colour saturation value is {cmd:leftcolsat1(50)}.

{phang}
{cmd:leftcolor2(}{it:{help colorstyle}}) specifies the marker colour for the second treatment group values
on the plot on the left of the overall plot.
{cmd:leftcolor2()} must be one of Stata's {it:{help colorstyle}}. The default marker colour is {cmd:leftcolor2(red)}.

{phang}
{cmd:leftcolsat2(}{it:{help colorstyle}}) specifies the marker colour saturation for the second treatment group values
on the plot on the left of the overall plot. 
{cmd:leftcolsat2(#)} accepts integer values between 0 and 100 inclusive. The default value for colour saturation is {cmd:leftcolsat2(50)}.

{phang}
{cmd:leftsymb1(}{it:{help symbolstyle}}) specifies the marker symbol for the first treatment group values
on the plot on the left of the overall plot. 
{cmd:leftsymb1()} must be one of Stata's {it:{help symbolstyle}}. The default marker symbol is {cmd:leftsymb1(circle)}.

{phang}
{cmd:leftsymb2(}{it:{help symbolstyle}}) specifies the marker symbol for the second treatment group values
on the plot on the left of the overall plot. 
{cmd:leftsymb2()} must be one of Stata's {it:{help symbolstyle}}. Default marker symbol is  {cmd:leftsymb2(circle)}.

{phang}
{opt leftlabsize(#)} specifies the label size for event names on the y-axis on the plot
on the left of the overall plot. The default label size is {cmd:leftlabsize(1)}.

{phang}
{opt leftlabang(#)} specifies the label angle for event names on the y-axis on the plot
on the left of the overall plot. The default label angle is {cmd:leftlabang(0)} which provides horizontal labels.

{phang}
{opt leftlabel(string)} used to override y-axis labels on the plot on the left. 
See {it:{help graph dot}} {cmd:relabel} for further details. 
If this is not specified the labels default to the labels of {varname},
where {varname} indicates the variable that contains the event name/identifier.

{phang}
{opt rightxline(#)} specifies the position of the vertical line on the plot 
on the right of the overall plot.
The default line position {cmd:rightxline(0)}. {cmd:rightxline(#)} must be numeric.

{phang}
{cmd: rightxlinepat(}{it:{help linepattern}}) specifies the line style of the vertical line on the 
plot on the right of the overall plot.  
{cmd:rightxlinepat()} must be one of Stata's {it:{help linepattern}}. The default line pattern is {cmd:rightxlinepat(dash)}.

{phang}
{cmd: rightxlinecol(}{it:{help colorstyle}}) specifies the colour of the vertical line on the 
plot on the right of the overall plot. 
{cmd:rightxlinecol()} must be one of Stata's {it:{help colorstyle}}. The default line colour is {cmd:rightxlinecol(bluishgray)}.

{phang}
{cmd: rightdcolor(}{it:{help colorstyle}}) specifies the colour of the horizontal grid lines on the 
plot on the right of the overall plot. 
{cmd:rightdcolor()} must be one of Stata's {it:{help colorstyle}}. The default colour is {cmd:rightdcolor(white)}.

{phang}
{cmd: rightdotcol(}{it:{help colorstyle}}) specifies the marker colour on the 
plot on the right of the overall plot. 
{cmd:rightdotcol()} must be one of Stata's {it:{help colorstyle}}. The default colour is {cmd:rightdotcol(black)}.

{phang}
{opt rightdotsat(#)} specifies the marker colour saturation on the 
plot on the right of the overall plot. {cmd:rightdotsat(#)} accepts integer values between 0 and 100 inclusive.
The default colour saturation is {cmd:rightdotsat(60)}.

{phang}
{cmd: rightlincol(}{it:{help colorstyle}}) specifies the colour of the confidence interval on the 
plot on the right of the overall plot. 
{cmd:rightlincol()} must be one of Stata's {it:{help colorstyle}}. The default line colour is {cmd:rightlincol(black)}.

{phang}
{opt rightlinsat(#)} specifies the colour saturation of the confidence interval on the 
plot on the right of the overall plot. {cmd:rightlinsat(#)} accepts integer values between 0 and 100 inclusive.
The default colour saturation is {cmd:rightlinsat(60)}.

{phang}
{opt legendleftyn(#)} specifies whether the legend appears on the plot on the left of the overall plot.
{cmd:legendleftyn(0)} indicates legend off and {cmd:legendleftyn(1)} indicates legend on.
{cmd:legendleftyn(#)} can only take values 0 or 1. The default setting is {cmd:legendleftyn(1)}, legend on.

{phang}
{opt legendleft1(string)} specifies legend text to describe the first treatment group for the 
plot on the left of the overall plot. The default text is {it:"Group 1"}.

{phang}
{opt legendleft2(string)} specifies legend text to describe the second treatment group for the
plot on the left of the overall plot. The default text is {it:"Group 2"}.

{phang}
{opt legendleftpos(#)} specifies the position of the legend on the plot on the left of the overall plot.
{cmd:legendleftpos(#)} can take integer values between 1 to 12 inclusive. The default position is {cmd:legendleftpos(6)}.

{phang}
{opt legendleftcol(#)} specifies the number of columns in the legend on the plot on the left of the overall plot.
{cmd:legendleftcol(#)} can only take integer values. The default number of columns is {cmd:legendleftcol(2)}.
Use with {cmd:legendleftrow(#)} to change legend appearance.

{phang}
{opt legendleftrow(#)} specifies the number of rows in the legend on the plot on the left of the overall plot.
{cmd:legendleftrow(#)} can only take integer values. The default number of rows is {cmd:legendleftrow(1)}.
Use with {cmd:legendleftcol(#)} to change legend appearance.

{phang}
{opt legendrightyn(#)} specifies whether the legend appears on the plot on the right of the overall plot.
{cmd:legendrightyn(0)} indicates legend off and {cmd:legendrightyn(1)} indicates legend on. {cmd:legendrightyn(#)} can only take values 0 or 1.
The default is {cmd:legendrightyn(1)}, legend on.

{phang}
{opt legendright1(string)} specifies legend text for the point estimate on the plot on the right of the overall plot.
The default text is {it:"log10(Relative risk)"} if {cmd:riskdiff(0)} and {it:"Risk difference"} if {cmd:riskdiff(1)}. 

{phang}
{opt legendright2(string)} specifies the legend text for the confidence interval on the plot on the right of the overall plot.
The default text is {it:"95% CI"}.

{phang}
{opt legendrightpos(#)} specifies the position of the legend on the plot on the right of the overall plot.
{cmd:legendrightpos(#)} can take integer values between 1 to 12 inclusive. The default position is {cmd:legendrightpos(6)}. 

{phang}
{opt legendrightcol(#)} specifies the number of columns in the legend on the plot on the right of the overall plot.
{cmd:legendrightcol(#)} can only take integer values. The default number of columns is {cmd:legendrightcol(2)}.
Use with {cmd:legendrightrow(#)} to change legend appearance.

{phang}
{opt legendrightrow(#)} specifies the number of rows in the legend on the plot on the right of the overall plot.
{cmd:legendrightrow(#)} can only take integer values. The default number of rows is {cmd:legendrightrow(1)}.
Use with {cmd:legendrightcol(#)} to change legend appearance.

{phang}
{opt bleftmargin(#)} adds a margin of empty space to the bottom of the plot on the left;
default is {cmd:bleftmargin(0)}. This can be used to help align the combined plots.

{phang}
{opt tleftmargin(#)} adds a margin of empty space to the top of the plot on the left; 
default is {cmd:tleftmargin(0)}. This can be used to help align the combined plots.

{phang}
{opt aspectleft(#)} sets the aspect of the plot on the left; default is {cmd:aspectleft(0)}.
It is used to control the relationship between the height and width of a graph's plot region.
See {it:{help aspectratio}} for further details.

{phang}
{opt brightmargin(#)} adds a margin of empty space to the bottom of the plot on the right; 
default is {cmd:brightmargin(2)}. This can be used to help align the combined plots.

{phang}
{opt trightmargin(#)} adds a margin of empty space to the top of the plot on the right;
default is {cmd:trightmargin(5)}. This can be used to help align the combined plots.

{phang}
{opt aspectright(#)} sets the aspect of the plot on the right; default is {cmd:aspectright(0)}.
It is used to control the relationship between the height and width of a graph's plot region.
See {it:{help aspectratio}} for further details.

{phang}
{cmd: grphcol(}{it:{help colorstyle}}) specifies the colour of the graph background.
{cmd:grphcol()} must be one of Stata's {it:{help colorstyle}}, the default is {cmd:grphcol(white)}.

{phang}
{cmd: plotcol(}{it:{help colorstyle}}) specifies the colour of the plot background.
{cmd:plotcol()} must be one of Stata's {it:{help colorstyle}}, default is {cmd:plotcol(white)}.

{phang}
{opt title(string)} allows users to specify a title for the overall plot.

{phang}
{opt subtitle(string)} allows users to specify a subtitle for the overall plot.

{marker remarks}{...}
{title:Remarks}

{phang2}{help aedots##general_remarks:General remarks}{p_end}

{marker general_remarks}{...}
    {title:General remarks}

{pstd}
(1) Summary data are required in long format with one row per event.

{pstd}
(2) The command creates a new dataset with one row per event containing summary level data.
Once the command finishes running the new dataset is stored in memory if {cmd:clear} is specified and is 
saved in {it:filename}{cmd:.dta} if {cmd:saving()} is specified. If {cmd:clear} is 
not specified the original dataset is kept in memory.
  
{pstd}
(3) Graphs are saved to the users current working directory if {cmd:graphsave()} is specified.

{pstd}
(4) If 0 events experienced in either treatment group the command adds half an event to each group
(numerator and denominator) to calculate the relative risk, standard error
and 95% confidence interval. This does not affect the percentages presented and calculation of the risk difference.

{pstd}
(5) Calculation of 95% confidence interval uses the normal approximation.

{pstd}
(6) The command will always process the lowest coded value first. For example:{break}
{opth n1(varname)} / {opth tot1(varname)} - {opth n2(varname)} / {opth tot2(varname)}

{pstd}
(7) With a large number of events the plot can become incomprehensible,
therefore we advise users to split their data into groups of events and produce a separate plot for each group if necessary.

{pstd}
(8) If the dataset contains more than two treatment arms then we recommend users present separate graphs for each pairwise comparison.

{marker examples}{...}
{title:Examples}

{pstd}
Analysing an example dataset{p_end}
{phang2}{cmd:. use example_dot_summ.dta}{p_end}

{pstd}
Dot plot {p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2)}{p_end}

{pstd}
Dot plot using the {cmd:dotsymb1} option to change marker symbol for group 1 and the {cmd:legendleft1} and {cmd:legendleft2} options to change legend labels on the plot on the left{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) leftsymb1(triangle) legendleft1(Placebo) legendleft2(Intervention)}{p_end}

{pstd}
Dot plot using the {cmd: riskdiff} option to plot risk difference instead of relative risk{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) riskdiff(1)}{p_end}

{pstd}
Dot plot using the {cmd:leftlabsize} option to change the size of the event labels{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) leftlabsize(0.8)}{p_end}

{pstd}
Dot plot using the {cmd:rightxline} option to change the postion of the vertical line on the plot on the right{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) rightxline(1.5)}{p_end}

{pstd}
Dot plot using the {cmd:leftplot} option to change the left plot x-axis label{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) leftxtitle(%)} {p_end}

{pstd}
Dot plot using the {cmd:brightmargin} option to add space to the bottom and the {cmd:trightmargin} option to add space to the top of the plot on the right{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) brightmargin(2) trightmargin(2)}{p_end}

{pstd}
Dot plot using the {cmd:legendleftyn} option and the {cmd:legendrightyn} option to remove legends from both plots{p_end}
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) legendleftyn(0)  legendrightyn(0)}{p_end}

{pstd}
Saving the final graph with filename {it:dot_example}{cmd:.gph}{p_end} 
{phang2}{cmd:. use example_dot_summ.dta, clear}{p_end}
{phang2}{cmd:. aedots ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) graphsave(dot_example)}{p_end}


{title:Acknowledgments}

{pstd}

We thank Emily Day (Imperial College London), Jack Elkes (Imperial College London) and 
Giles Partington (Imperial College London) for their helpful comments on the program.


{marker references}{...}
{title:References}

{marker R2008}{...}
{phang}
Amit, O. , Heiberger, R. M. and Lane, P. W. 2008. Graphical approaches to the analysis of safety data from clinical trials. 
{it:Pharmaceut. Statist.} 7: 20-35. doi:10.1002/pst.254


{title:Authors}

{pstd}
Rachel Phillips{break}
Imperial College London, UK{break}
r.phillips@imperial.ac.uk

{pstd}
Suzie Cro{break}
Imperial College London, UK{break}
