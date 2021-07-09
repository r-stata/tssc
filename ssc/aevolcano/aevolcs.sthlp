{smcl}
{* *! aevolcs version 1.0 18Dec2019}{...}
{cmd:help aevolcs}
{hline}

{title:Title}

{p2colset 5 14 18 2}{...}
{p2col :{cmd:aevolcs} {hline 2} Volcano plot for summary level adverse event data}{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:aevolcs} {varname} {cmd:,}  {opth n1(varname)} {opth n2(varname)} {opth tot1(varname)} {opth tot2(varname)} [{it:options}]


{phang}
{bf:aevolcs} requires summary data in long format with one row per event, where {varname} indicates the variable that contains the event name/identifier.
{varname}  may be a numeric or a string variable.

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt n1(varname)}}variable indicating the number of participants in the first treatment group with the event specified in {varname} (must be numeric){p_end}
{p2coldent:* {opt n2(varname)}}variable indicating the number of participants in the second treatment group with the event specified in {varname} (must be numeric){p_end}
{p2coldent:* {opt tot1(varname)}}variable indicating the total number of unique participants in the first treatment group (must be numeric){p_end}
{p2coldent:* {opt tot2(varname)}}variable indicating the total number of unique participants in the second treatment group (must be numeric){p_end}
{synopt:{cmdab: sav:ing(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}saves the dataset with the plotted event level summary data in {it:filename}{cmd:.dta}{p_end}
{synopt:{cmdab: graphsave(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}saves the plot in {it:filename}{cmd:.dta}{p_end}
{synopt:{opt clear}} if specified the newly created dataset is stored in memory. If {cmd:clear} not specified the original dataset is retained in memory.{p_end}

{synopt:{opt odds:ratio(#)}} option to plot odds ratios; {cmd:oddsratio(1)} plots the odds ratio and {cmd:oddsratio(0)} plots the risk difference, default is {cmd:oddsratio(0)}{p_end}
{synopt:{opt risk:ratio(#)}} option to plot risk ratios; {cmd:riskratio(1)} plots the risk ratio and {cmd:riskratio(0)} plots the risk difference, default is {cmd:riskratio(0)}{p_end}
{synopt:{opt pval:ue(#)}} option to use p-values from Pearson's chi-squared test; {cmd:pvalue(1)} uses Pearson's chi-squared p-values and {cmd:pvalue(0)} uses Fisher's exact p-values, default is {cmd:pvalue(0)}{p_end}
{synopt:{opt padj:(#)}} option to use the false discovery rate (FDR) p-value adjustment; {cmd:padj(1)} produces FDR adjusted p-values and {cmd:padj(0)} uses no adjustment, default is {cmd:padj(0)}. See {it:{help aefdr}} for full details{p_end}

{p2coldent:* {opt fdrhigher(varname)}}if {cmd:padj(1)} then {cmd:fdrhigher(varname)} required, where {varname} indicates the higher level or bodysystem event variable{p_end}
{p2coldent:* {opt fdrlower:(varname)}}if {cmd:padj(1)} then {cmd:fdrlower(varname)} required, where {varname} indicates the lower level or preferred term event variable{p_end}
{synopt:{opt fdr:val(#)}} indicates the alpha value the FDR adjustment is carried out on. The FDR procedure flags events with adjusted event and bodysystem p-values below this specified value (must be numeric), default is {cmd:fdrval(0.1)}{p_end}

{synopt:{opt labelyn(#)}}used to turn bubble labels on by specifying {cmd:labelyn(1)}; default is bubble label off {cmd:labelyn(0)}{p_end}
{synopt:{opt label(#)}} if {cmd:labelyn(1)} then {cmd:label} used to indicate p-value threshold below which bubbles will be labelled; default is {cmd:label(1)} so variables with log10(p-value)>1 will be labelled, 
			this equates to a p-value<0.1{p_end}
{synopt:{opt labelnum(#)}} used to specify if bubble labels required when {varname} numeric; default is {cmd:labelnum(0)} which indicates number labels not required,
			{cmd:labelnum(1)} labels assigned numeric values, {cmd:labelnum(2)} labels assigned label values{p_end}
{synopt:{cmd: labcol(}{it:{help colorstyle}})}label text colour; default is {cmd:labcol(black)}{p_end}
{synopt:{cmd: labcol1(}{it:{help colorstyle}})}label text colour for events where the risk is largest in the first treatment group; default {cmd:labcol1(black)}{p_end}
{synopt:{cmd: labcol2(}{it:{help colorstyle}})}label text colour for events where the risk is largest in the second treatment group; default {cmd:labcol2(black)}{p_end}
{synopt:{opt labang(#)}} label angle; default {cmd:labang(90)} to give vertical labels{p_end}
{synopt:{opt labang1(#)}} label angle for events where the risk is largest in the first treatment group; default {cmd:labang1(90)} to give vertical labels{p_end}
{synopt:{opt labang2(#)}} label angle for events where the risk is largest in the second treatment group; default {cmd:labang2(90)} to give vertical labels{p_end}
{synopt:{opt labpos(#)}} label position; default {cmd:labpos(12)} to give labels above the bubble{p_end}
{synopt:{opt labpos1(#)}}label position for events where the risk is largest in the first treatment group; default {cmd:labpos1(12)} to give labels above the bubble{p_end}
{synopt:{opt labpos2(#)}}label position for events where the risk is largest in the second treatment group; default {cmd:labpos2(12)} to give labels above the bubble{p_end}
{synopt:{opt labgap(#)}}gap between label and bubble; default {cmd:labgap(5)}{p_end}
{synopt:{opt labgap1(#)}}gap between label and bubble for events where the risk is largest in the first treatment group; default {cmd:labgap1(5)}{p_end}
{synopt:{opt labgap2(#)}}gap between label and bubble for events where the risk is largest in the second treatment group; default {cmd:labgap2(5)}{p_end}
{synopt:{opt xaxismin(#)}} allows user to extend the x-axis beyond the minimum plotted value; default is 0 so minimum value used{p_end}
{synopt:{opt xaxismax(#)}} allows user to extend the x-axis beyond the maximum plotted value; default is 0 so maximum value used{p_end}
{synopt:{opt yaxismin(#)}} allows user to extend the y-axis beyond the minimum value; default is 0 so minimum value used{p_end}
{synopt:{opt yaxismax(#)}} allows user to extend the y-axis beyond the maximum value; default is 0 so maximum value used{p_end}			
{synopt:{opt xaxisticks(#)}} allows user to specify how the x-axis ticks are spaced; default is 4{p_end}
{synopt:{opt yaxisticks(#)}} allows user to specify how the y-axis ticks are spaced; default is 4{p_end}
{synopt:{opt xaxisdp(#)}} allows the user to specify the unit x-axis values are rounded to; default is 0.1{p_end}
{synopt:{opt yaxisdp(#)}} allows the user to specify the unit y-axis values are rounded to; default is 0.1{p_end}
{synopt:{opt ylineyn(#)}} allows the user to specify if a horizontal line is plotted by specifying {cmd:ylineyn(1)}; default is {cmd:ylineyn(0)} which does not plot a line{p_end}
{synopt:{opt yline(numlist)}} allows the user to specify the y-axis value where the horizontal line is plotted if {cmd:ylineyn(1)}; default is {cmd:yline(1)} which equates to a p-value of 0.1, unless {cmd:padj(1)}{p_end}
{synopt:{cmd: ylinepat(}{it:{help linepattern}})} style of {cmd:yline()}; default is {cmd:ylinepat(dash)}{p_end}
{synopt:{cmd: ylinecol(}{it:{help colorstyle}})} colour of {cmd:yline()}; default is {cmd:ylinecol(bluishgrey)}{p_end}
{synopt:{opt ylinewidth(#)}} width of {cmd:yline()}; default is {cmd:ylinewidth(0.5)}{p_end}
{synopt:{cmd: mfcolor1(}{it:{help colorstyle}})} bubble fill colour for events where the risk is largest in the first treatment group; default is {cmd:mfcolor1(red)}{p_end}
{synopt:{cmd: mfcolor2(}{it:{help colorstyle}})} bubble fill colour for events where the risk is largest in the second treatment group; default is {cmd:mfcolor2(blue)}{p_end}
{synopt:{cmd: mfcolor(}{it:{help colorstyle}})} overall bubble fill colour; default is to assign unique colours dependent on direction of effect, {cmd:mfcolor1(red)} and {cmd:mfcolor2(blue)}{p_end}
{synopt:{cmd: mlcolor1(}{it:{help colorstyle}})} bubble outline colour for events where the risk is largest in the first treatment group; default is {cmd:mlcolor1(red)}{p_end}
{synopt:{cmd: mlcolor2(}{it:{help colorstyle}})} bubble outline colour for events where the risk is largest in the second treatment group; default is {cmd:mlcolor2(blue)}{p_end}
{synopt:{cmd: mlcolor(}{it:{help colorstyle}})} overall bubble outline colour; default is to assign unique colours dependent on direction of effect, {cmd:mlcolor1(red)} and {cmd:mlcolor2(blue)}{p_end}
{synopt:{opt legendyn(#)}} specify whether legend appears on the plot; {cmd:legendyn(#)} takes values 0 to indicate legend off or 1 to indicate legend on, default is {cmd:legendyn(0)}{p_end}
{synopt:{opt legend1(string)}}specify text to describe the first treatment group; if {cmd:legendyn(1)} and {cmd:legend1()} default text is {it:"Risk in Group 1"} when the risk difference or the risk ratio is plotted
		or {it:"Odds higher in Group 1"} when the odds ratio is plotted{p_end}
{synopt:{opt legend2(string)}}specify text to describe the second treatment group; if {cmd:legendyn(1)} and {cmd:legend2()} default text is {it:"Risk in Group 2"} when the risk difference or the risk ratio is plotted
		or {it:"Odds higher in Group 2"} when the odds ratio is plotted{p_end}
{synopt:{opt legendpos(#)}} legend position; if {cmd:legendyn(1)} default position is {cmd:legendpos(6)}{p_end}
{synopt:{opt legendcol(#)}} number of columns in legend; if {cmd:legendyn(1)} default is {cmd:legendcol(1)}{p_end}
{synopt:{opt legendrow(#)}} number of rows in legend; if {cmd:legendyn(1)} default is {cmd:legendrow(2)}{p_end}
{synopt:{cmd: grphcol(}{it:{help colorstyle}})}colour of the graph background; default is {cmd:grphcol(white)}{p_end}
{synopt:{cmd: plotcol(}{it:{help colorstyle}})}colour of the plot background; default is {cmd:plotcol(white)}{p_end}

{synoptline}
{p2colreset}{...}
{pstd}* {cmd:n1}, {cmd:n2}, {cmd:tot1} and {cmd:tot2} are
required.{p_end}
{p2colreset}{...}
{pstd}* if {cmd:padj(1)} then  {cmd: fdrhigher()} and {cmd: fdrlower()} are
required.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{cmd:aevolcs} creates a volcano plot for summary level adverse event data from a two-arm clinical trial, 
as proposed by {help aevolcs##R2013:Zink, Wolfinger, and Mann (2013)}. 
The volcano plot is a means of displaying the incidence of multiple adverse events simultaneously.
Each bubble represents an event, the size of which indicates total frequency of that event,
colour is used to indicate direction of treatment effect and colour saturation corresponds
to the statistical significance of the treatment effect.
The volcano plot can help to identify potential differences in the adverse event profile between treatment arms.


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
{cmdab:graphsave(}{it:{help filename}}[{cmd:, replace}]{cmd:)} saves the plot.  
A new filename is required unless {opt replace} is also specified.
{opt replace} allows the {it:filename} to be overwritten with a new plot. 

{phang}
{opt clear} if specified the newly created dataset is stored in memory. 
If {cmd:clear} not specified the original dataset is retained in memory.

{phang}
{opt oddsratio(#)} used to specify whether odds ratios are plotted instead of risk differences;
{cmd:oddsratio(0)} plots risk differences and {cmd:oddsratio(1)} plots odds ratios.
{cmd:oddsratio(#)} can only take values 0 or 1. The default is {cmd:oddsratio(0)}.
Only one of {cmd:oddsratio(#)} or {cmd:riskratio(#)} can be specified at a time.

{phang}
{opt riskratio(#)} used to specify whether risk ratios are plotted instead of risk differences;
{cmd:riskratio(0)} plots risk differences and {cmd:riskratio(1)} plots risk ratios.
{cmd:riskratio(#)} can only take values 0 or 1. The default is {cmd:riskratio(0)}.
Only one of {cmd:oddsratio(#)} or {cmd:riskratio(#)} can be specified at a time.

{phang}
{opt pvalue(#)} used to specify which test is used to calculate the p-value.
{cmd:pvalue(1)} calculates and plots Pearson's chi-squared p-values and {cmd:pvalue(0)} calculates and plots Fisher's exact p-values.
The default is {cmd:pvalue(0)}.

{phang}
{opt padj(#)} used to specify whether the false discovery rate (FDR) p-value adjustment as proposed by 
{help aevolcano##R2012:Mehrotra and Adewale (2012)} is used to flag events. {cmd:padj(1)} calculates the FDR adjusted p-values and
{cmd:padj(0)} does not calculate adjusted values. The default is {cmd:padj(0)}. {cmd:padj(1)} calls on {it:{help aefdr}} which creates a new dataset, 
{it:adjusted_pvalues}{cmd:.dta} containing summary level data including an adjusted p-value for each {it:fdrlower} event and {it:fdrhigher} event.
The new dataset, {it:adjusted_pvalues}{cmd:.dta} is saved to the current working directory. See {it:{help aefdr}} for full details.

{phang}
{opt fdrhigher(varname)} is required if {cmd:padj(1)}.  
{varname} is the variable that contains the higher level or bodysystem event terms. See {it:{help aefdr}} for full details.

{phang}
{opt fdrlower(varname)} is required if {cmd:padj(1)}. 
{varname} is the variable that contains the lower level or preferred term event names. See {it:{help aefdr}} for full details.

{phang}
{opt fdrval(#)} indicates the alpha value that the FDR adjustment is carried out on. 
Events with adjusted event (lower level) and bodysystem (higher level) p-values below this specified value are flagged.
Default value is 0.1. See {it:{help aefdr}} for full details.

{phang}
{opt labelyn(#)} used to turn bubble labels on by specifying {cmd:labelyn(1)}.
Default is bubble labels off {cmd:labelyn(0)}. {cmd:labelyn(#)} can only take values 0 or 1.
If {cmd:labelyn(1)} labels are on and variables with log10(p-value)>1 will be labelled as default.
Note if no variables have log10(p-value)>1 then no labels will appear even if {cmd:labelyn(1)}.

{phang}
{opt label(#)} if {cmd:labelyn(1)} then {cmd:label} used to indicate the value of p-values below which to label bubbles.
Default is {cmd:label(1)} which labels bubbles with log10(p-values)>1, which equates to 
labelling bubbles with a p-value<0.1.

{phang}
{opt labelnum(#)} used to specify if labels are required when {varname} is numeric.
Default is {cmd:labelnum(0)} which indicates number labels not required,
{cmd:labelnum(1)} used to indicate labels assigned numeric values,  and
{cmd:labelnum(2)} indicates labels assigned label values. {cmd:labelnum(#)} can only take values 0, 1 or 2.

{phang}	
{cmd: labcol(}{it:{help colorstyle}}) specifies an overall colour for label text if {cmd: labelyn(1)}.
{cmd:labcol()} must be one of Stata's {it:{help colorstyle}}; default is {cmd:labcol(black)}.

{phang}
{cmd: labcol1(}{it:{help colorstyle}}) specifies label text colour when the risk (RD, OR or RR) is largest
in the first treatment group when {cmd: labelyn(1)}. {cmd:labcol1()} must be one of Stata's {it:{help colorstyle}}; default {cmd:labcol1(black)}.
{cmd:labcol1()} and {cmd:labcol2()} can be used to differentiate the colour of bubble labels according to the direction 
of the treatment effect. 

{phang}
{cmd: labcol2(}{it:{help colorstyle}}) specifies label text colour when the risk (RD, OR or RR) is largest
in the second treatment group when {cmd: labelyn(1)}. {cmd:labcol2()} must be one of Stata's {it:{help colorstyle}}; default {cmd:labcol2(black)}.
{cmd:labcol1()} and {cmd:labcol2()} can be used to differentiate the colour of bubble labels according to the direction 
of the treatment effect. 

{phang}
{opt labang(#)} specifies the angle for labels. The default is {cmd:labang(90)} to give vertical labels.
{cmd:labang(#)} takes integer values only.

{phang}
{opt labang1(#)} specifies the angle for labels when the risk (RD, OR or RR) is largest in the first treatment group.
The default is {cmd:labang1(90)} to give vertical labels. {cmd:labang1(#)} takes integer values only.
{cmd:labang1(#)} and {cmd:labang2(#)} can be used to differentiate the angle of the labels according to the direction 
of the treatment effect. 

{phang}
{opt labang2(#)} specifies the angle for labels when the risk (RD, OR or RR) is largest in the second treatment group.
The default is {cmd:labang1(90)} to give vertical labels. {cmd:labang2(#)} takes integer values only.
{cmd:labang1(#)} and {cmd:labang2(#)} can be used to differentiate the angle of the labels according to the direction 
of the treatment effect. 

{phang}
{opt labpos(#)} specifies the label position. The default is {cmd:labpos(12)} 
which positions labels above the bubble. {cmd:labpos(#)} can only take integer values between 0 and 12, inclusive.

{phang}
{opt labpos1(#)} specifies the label position when the risk (RD, OR or RR) is largest in the first treatment group.
The default is {cmd:labpos1(12)} which positions labels above the bubble.
{cmd:labpos1(#)} and {cmd:labpos2(#)} can be used to differentiate the position of the bubble labels according to the direction 
of the treatment effect. {cmd:labpos1(#)} can only take integer values between 0 and 12, inclusive.

{phang}
{opt labpos2(#)} specifies the label position when the risk (RD, OR or RR) is largest in the second treatment group.
The default is {cmd:labpos2(12)} which positions labels above the bubble.
{cmd:labpos1(#)} and {cmd:labpos2(#)} can be used to differentiate the position of the bubble labels according to the direction 
of the treatment effect. {cmd:labpos2(#)} can only take integer values between 0 and 12, inclusive.

{phang}
{opt labgap(#)} specifies the size of the gap between the label and the bubble.
The default gap is {cmd:labgap(5)}. {cmd:labgap(#)} takes integer values only.

{phang}
{opt labgap1(#)} specifies the size of the gap between the label and the bubble when the risk (RD, OR or RR) is largest in the first treatment group.
The default gap is {cmd:labgap1(5)}. {cmd:labgap1(#)} takes integer values only.
{cmd:labgap1(#)} and {cmd:labgap2(#)} can be used to differentiate the 
size of the gap between the labels and bubble according to the direction of the treatment effect. 

{phang}
{opt labgap2(#)} specifies the size of the gap between the label and the bubble when the risk (RD, OR, or RR) is largest in the second treatment group.
The default gap is {cmd:labgap2(5)}. {cmd:labgap2(#)} takes integer values only.
{cmd:labgap1(#)} and {cmd:labgap2(#)} can be used to differentiate the 
size of the gap between the labels and bubble according to the direction of the treatment effect. 

{phang}
{opt xaxismin(#)} allows the user to add a value to the minimum value plotted to extend the x-axis. 
The default is 0 which plots the minimum value for the x-axis lower limit. 
Note that the # specified is added to the minimum value plotted to extend the x-axis.
The # specified is not the lower limit for the x-axis.

{phang}
{opt xaxismax(#)} allows the user to add a value to the maximum value plotted to extend the x-axis.
The default is 0 which plots the maximum value for the x-axis upper limit.
Note that the # specified is added to the maximum value plotted to extend the x-axis.
The # specified is not the upper limit for the x-axis.

{phang}
{opt yaxismin(#)} allows the user to add a value to the minimum value plotted to extend the y-axis. 
The default is 0 which plots the minimum value for the y-axis lower limit. 
Note that the # specified is added to the minimum value plotted to extend the y-axis.
The # specified is not the lower limit for the y-axis.

{phang}
{opt yaxismax(#)} allows the user to add a value to the maximum value plotted to extend the y-axis. 
The default is 0 which plots the maximum value for the y-axis upper limit.
Note that the # specified is added to the maximum value plotted to extend the y-axis.
The # specified is not the upper limit for the y-axis.

{phang}
{opt xaxisticks(#)} allows the user to specify how the x-axis ticks are spaced by 
dividing the range of the x-axis values by {cmd:xaxisticks(#)}.
The default is 4. 

{phang}
{opt yaxisticks(#)} allows the user to specify how the y-axis ticks are spaced by
dividing the range of the y-axis values by {cmd:yaxisticks(#)}. The default is 4.

{phang}
{opt xaxisdp(#)} allows the user to specify the units the x-axis values are rounded to. 
The default is 0.1 which rounds to 1 decimal place. 

{phang}
{opt yaxisdp(#)} allows the user to specify the units the y-axis values are rounded to. 
The default is 0.1 which rounds to 1 decimal place. 

{phang}
{opt ylineyn(#)} allows the user to specify if a horizontal line is included on the plot.
The default is {cmd:ylineyn(0)} which does not include a line on the plot. 

{phang}
{opt yline(numlist)} can be specified if {cmd:ylineyn(1)}. It allows the user to specify the y-line value for the horizontal line. 
The default is {cmd:yline(1)} which equates to a p-value of 0.1, unless {cmd:padj(1)} then {cmd:yline(#)} is plotted at the minimum adjusted p-value flagged by 
the {it:{help aefdr}} procedure and if no events flagged after adjustment the line is set at {cmd:yline(0)}.

{phang}
{cmd: ylinepat(}{it:{help linepattern}}) used to specify the style of {cmd:yline()}.
{cmd:ylinepat()} must be one of Stata's {it:{help linepattern}}; the default is {cmd:ylinepat(dash)}.

{phang}
{cmd: ylinecol(}{it:{help colorstyle}}) used to specify the colour of {cmd:yline()}.
{cmd:ylinecol()} must be one of Stata's {it:{help colorstyle}}; default is {cmd:ylinecol(bluishgray)}.

{phang}
{opt ylinewidth(#)} specifies the width of {cmd:yline()}. The default is {cmd:ylinewidth(0.5)}.

{phang}
{cmd: mfcolor1(}{it:{help colorstyle}}) specifies the bubble fill colour for events where the risk is largest in the first treatment group. 
{cmd:mfcolor1()} must be one of Stata's {it:{help colorstyle}}, the  default is {cmd:mfcolor1(red)}.

{phang}
{cmd: mfcolor2(}{it:{help colorstyle}}) specifies the bubble fill colour for events where the risk is largest in the second treatment group.
{cmd:mfcolor2()} must be one of Stata's {it:{help colorstyle}}, the default is {cmd:mfcolor2(blue)}.

{phang}
{cmd: mfcolor(}{it:{help colorstyle}}) specifies one colour for all bubbles.
Default is to assign unique treatment group colours using {cmd:mfcolor1(red)} and {cmd:mfcolor2(blue)}.

{phang}
{cmd: m1color1(}{it:{help colorstyle}}) specifies the bubble outline colour for events where the risk is largest in the first treatment group.  
{cmd:mlcolor1()} must be one of Stata's {it:{help colorstyle}}, the  default is {cmd:mlcolor1(red)}.

{phang}
{cmd: mlcolor2(}{it:{help colorstyle}}) specifies the bubble outline colour for events where the risk is largest in the second treatment group.  
{cmd:mlcolor2()} must be one of Stata's {it:{help colorstyle}}, the default is {cmd:mlcolor2(blue)}.

{phang}
{cmd: mlcolor(}{it:{help colorstyle}}) specifies one colour for all bubble outlines.
Default is to assign unique treatment group colours using {cmd:mlcolor1(red)} and {cmd:mlcolor2(blue)}.

{phang}
{opt legendyn(#)} specifies whether a legend appears on the plot.
{cmd:legendyn(#)} takes values 0 to indicate legend off or 1 to indicate legend on. 
The default is {cmd:legendyn(0)} so no legend included on the plot. {cmd:legendyn(#)} can only take values 0 or 1.

{phang}
{opt legend1(string)} allows the user to specify the text to describe the first treatment group.
If {cmd:legendyn(1)} and {cmd:legend1()} then the default text is {it:"Risk in Group 1"} when the risk difference or the risk ratio is plotted
or {it:"Odds higher in Group 1"} when the odds ratio is plotted.

{phang}
{opt legend2(string)} allows the user to specify the text to describe the second treatment group.
If {cmd:legendyn(1)} and {cmd:legend2()} then the default text is {it:"Risk in Group 2"} when the risk difference or the risk ratio is plotted
or {it:"Odds higher in Group 2"} when the odds ratio is plotted.

{phang}
{opt legendpos(#)} specifies the position of the legend. 
If {cmd:legendyn(1)} then the default position is {cmd:legendpos(6)}. 
{cmd:legendpos(#)} can only take integer values between 0 and 12, inclusive.

{phang}
{opt legendcol(#)} specifies the number of columns in the legend.
If {cmd:legendyn(1)} the default is {cmd:legendcol(1)}. 
{cmd:legendcol(#)} can only take integer values.
Use with {cmd:legendrow(#)} to change legend appearance.

{phang}
{opt legendrow(#)} specifies the number of rows in the legend. 
If {cmd:legendyn(1)} default is {cmd:legendrow(2)}.
{cmd:legendrow(#)} can only take integer values.
Use with {cmd:legendcol(#)} to change legend appearance.

{phang}
{cmd: grphcol(}{it:{help colorstyle}}) specifies the colour of the graph background.
{cmd:grphcol()} must be one of Stata's {it:{help colorstyle}}; the default is {cmd:grphcol(white)}.

{phang}
{cmd: plotcol(}{it:{help colorstyle}}) specifies the colour of the plot background.
{cmd:plotcol()} must be one of Stata's {it:{help colorstyle}}; default is {cmd:plotcol(white)}.


{marker remarks}{...}
{title:Remarks}

{phang2}{help aevolcs##general_remarks:General remarks}{p_end}

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
(4) The command will always process the lowest coded value first. For example:{break}
{opth n1(varname)} / {opth tot1(varname)} - {opth n2(varname)} / {opth tot2(varname)}

{pstd}
(5) If more than two treatment arms then users are recommended to present separate graphs for each pairwise comparison.

{pstd}
(6) Users can change label position, angle and gap from bubble but occasionally labels will still overlap with each other, 
in this scenario we advise users to switch labels off and insert labels manually or alternatively use a numeric variable and label with numbers.

{pstd}
(7) Labels are specified by choosing a log10(p-value) that should be exceeded e.g. log10(p-value)=1 equates to labelling events with p-values less than 0.1. 

{pstd}
(8) The command incorporates a correction (adds 0.5 events to each group) when fitting odds ratios or risk ratios if there are 0 events in one of the treatment groups.

{pstd}
(9) Odds ratios and risk ratios are plotted on the log scale to ensure symmetrical x-axis.
  
{pstd}
(10) If the {cmd:padj} option used then a new dataset, {it: adjusted_pvalues}{cmd:.dta} with one row per event containing summary level data is saved to current working directory.
{it: adjusted_pvalues}{cmd:.dta} includes a variable, {it: p2} containing the adjusted p-value for each event in {cmd:fdrlower}; 
a variable, {it: p2_bs} containing the adjusted p-value for each event in {cmd:fdrhigher}; and a variable, 
{it: flag} which equals 1 if events satisfy the p-value threshold specified in {cmd:fdrval}.

{pstd}
(11) If when running the program user receives error message {it: "postfile ae_volci already exists"} user needs to type {cmd: postclose ae_volci} before rerunning the command.
  
  
 {marker examples}{...}
{title:Examples}

{pstd}
Analysing an example dataset{p_end}
{phang2}{cmd:. use example_volcano_summ.dta}{p_end}

{pstd}
Volcano plot {p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2)}{p_end}
 
{pstd}
Volcano plot using the {cmd:ylineyn} option to include a horizontal line at the default value{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) ylineyn(1)}{p_end}

{pstd}
Volcano plot using the {cmd:ylineyn} option to include a horizontal line and the {cmd:yline} option to specify at which value(s) the line appears{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) ylineyn(1) yline(0.6 1.2)}{p_end}

{pstd}
Volcano plot using the {cmd: labelyn} option to include labels on the plot and the {cmd:yaxismax} to extend the y-axis{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) labelyn(1) yaxismax(0.3)}{p_end}

{pstd}
Volcano plot using the {cmd: labelyn} option to include labels on the plot and {cmd:label} to change p-value threshold at which labels appear{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) labelyn(1) label(0.8) yaxismax(0.3)}{p_end}

{pstd}
Volcano plot using the {cmd:labelyn} option to include labels on the plot and {cmd:labcol} to change the colour of the labels{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) labelyn(1) yaxismax(0.3) labcol(red)}{p_end}

{pstd}
Volcano plot using the {cmd:labelyn} option to include labels on the plot and {cmd:labcol1} and {cmd:labcol2} to change the 
colour of the labels according to direction of the treatment effect{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) labelyn(1) yaxismax(0.3) labcol1(green)  labcol2(red)}{p_end}

{pstd}
Volcano plot using the {cmd:mfcolor1} and {cmd:mfcolor2} options to change the colours of the bubbles 
 according to direction of treatment effect{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) mfcolor1(orange) mfcolor2(green)}{p_end}

{pstd}
Volcano plot using the {cmd:legendyn} option to include a legend on the plot{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) legendyn(1)}{p_end}

{pstd}
Volcano plot using the {cmd:legendyn} option to include a legend and {cmd:legend1} and {cmd:legend2} to change the legend labels{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) legendyn(1) legend1(Intervention) legend2(Placebo)}{p_end}

{pstd}
Volcano plot using the {cmd:oddsratio} option to plot the odds-ratio on the x-axis instead of the default risk-difference{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) oddsratio(1)}{p_end}

{pstd}
Volcano plot using the {cmd:riskratio} option to plot the risk-ratio on the x-axis instead of the default risk-difference{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) riskratio(1)}{p_end}

{pstd}
Volcano plot using the {cmd:pvalue} option to plot the p-values from the Chi-squared test instead of the default Fisher's exact test p-values{p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) pvalue(1)}{p_end} 

{pstd}
Volcano plot using the {cmd:padj} option to calculate the FDR adjusted p-values and {cmd:fdrval} to change the value at which events 
are flagged {p_end}
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) padj(1) fdrlower(ae_pt) fdrhigher(aebodsys) fdrval(0.05)}{p_end}

{pstd}
Saving the final graph with filename {it:volcano_example}{cmd:.gph}{p_end} 
{phang2}{cmd:. use example_volcano_summ.dta, clear}{p_end}
{phang2}{cmd:. aevolcs ae_pt, n1(event1) n2(event2) tot1(total1) tot2(total2) saving(volcano_example)}{p_end}


{title:Acknowledgments}

{pstd}
We thank Emily Day (Imperial College London), Jack Elkes (Imperial College London) and 
Giles Partington (Imperial College London) for their helpful comments on the program.

{marker references}{...}
{title:References}

{marker R2013}{...}
{phang}
Zink, R.C. , Wolfinger, R.D. and Mann, G. 2013. Summarizing the incidence of adverse events using volcano plots and time intervals. 
{it:Clinical Trials} 10: 398-406. doi:10.1177/1740774513485311

{marker R2012}{...}
{phang}
Mehrotra, D. V. and A. J. Adewale.  2012. Flagging clinical adverse experiences: Reducing false discoveries without materially compromising power for detecting true signals. 
{it:Statistics in Medicine} 31: 1918-1930. doi:10.1002/sim.5310

{title:Authors}

{pstd}
Rachel Phillips{break}
Imperial College London, UK{break}
r.phillips@imperial.ac.uk

{pstd}
Suzie Cro{break}
Imperial College London, UK{break}
