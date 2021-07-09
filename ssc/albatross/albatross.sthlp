{smcl}
{* 13jan2017}
{* 13jun2017}{...}
{cmd:help albatross}
{hline}

{title:Albatross}

{phang}
{bf:albatross} {hline 2} Creates an albatross plot

{marker syntax}
{title:Syntax}
{p 8 12 2}
{cmd:albatross} 
[{varlist}]
{ifin}
{cmd:,}
{opt type(statistical_type)}
[{it:statistical_type_options}
{it:plot_options} 
{it:other_options}]

{p 12 12 2} 
where {it:varlist} has 3 variables in the order 

{p 12 12 2}
{it:number of participants; P value; effect direction}

{p 12 12 2}
All three variables must be specified, as well as {opt type()}

{synoptset 25 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt :{opt type(statistical_type)}} the type of statistical model; one of: {opt mean proportion correlation beta md smd rr or}{p_end}

{syntab:Statistical types}
{synopt :{opt mean}} comparison of a sample mean with a known population mean.
Requires one of: {opt sd(varname)} or {opt ssd(#)}{p_end}
{synopt :{opt proportion}} comparison of a sample proportion with a known population proportion. Optional: {opt sprop:ortion(#)}{p_end}
{synopt :{opt md}} mean difference - comparison of two sample means.
Requires one of: {opt sd(varname)}; {opt ssd(#)}; {opt sd1(varname)} and {opt sd2(varname)}; or {opt ssd1(#)} and {opt ssd2(#)}.
Optional: {opt r(varname)} and {opt sr(#)}{p_end}
{synopt :{opt smd}} standardized mean difference - standardized comparison of two sample means.
Optional: {opt r(varname)} and {opt sr(#)}{p_end}
{synopt :{opt correlation}} comparison of two continuous variables in one sample{p_end}
{synopt :{opt beta}} linear regression - comparison of two continuous variables in one sample{p_end}
{synopt :{opt or}} odds ratio - comparison of two groups with a binary exposure and outcome.
Requires one of: {opt base:line(varname)} or {opt sbase:line(#)}.
Optional: {opt r(varname)}, {opt sr(#)} and {opt or(varname)}{p_end}
{synopt :{opt rr}} risk ratio/relative risk - comparison of two groups with a binary exposuare and outcome.
Requires one of: {opt base:line(varname)} or {opt sbase:line(#)}.
Optional: {opt r(varname)}, {opt sr(#)} and {opt rr(varname)}{p_end}

{syntab:Statistical type options}
{synopt :{opt sprop:ortion(#)}} standardized proportion for contour generation{p_end}
{synopt :{opt sd(varname)}} variable of each study’s standard deviation of the exposure (whole study){p_end}
{synopt :{opt sd1(varname)}} variable of each study’s standard deviation of the exposure (group 1){p_end}
{synopt :{opt sd2(varname)}} variable of each study’s standard deviation of the exposure (group 2){p_end}
{synopt :{opt ssd(#)}} standardized standard deviation of the exposure (whole study) for contour generation{p_end}
{synopt :{opt ssd1(#)}} standardized standard deviation of the exposure (group 1) for contour generation{p_end}
{synopt :{opt ssd2(#)}} standardized standard deviation of the exposure (group 2) for contour generation{p_end}
{synopt :{opt r(varname)}} variable of each study’s group size ratio (case/control){p_end}
{synopt :{opt sr(#)}} standardized group size ratio (case/control) for contour generation{p_end}
{synopt :{opt base:line(varname)}} variable of each study’s baseline rate (proportion of group 2 with outcome){p_end}
{synopt :{opt sbase:line(#)}} standardized baseline rate (proportion of group 2 with outcome) for contour generation{p_end}
{synopt :{opt rr(varname)}} variable of each study’s relative risk (not required, can be estimated){p_end}
{synopt :{opt or(varname)}} variable of each study’s odds ratio (not required, can be estimated){p_end}

{syntab:Plot options}
{synopt :{opt con:tours(# # #)}} specify the effect size of 1-3 contours{p_end}
{synopt :{opt ti:tle(string)}} specify the title of the albatross plot{p_end}
{synopt :{opt sub:title(string)}} specify the subtitle of the albatross plot{p_end}
{synopt :{opt nogr:aph}} suppress creation of the plot{p_end}
{synopt :{opt nono:tes}} suppress notes on graph{p_end}
{synopt :{opt by(varname)}} specify a variable where different levels of {it:varname} are drawn with different markers.
Only one {it:varname} may be specified{p_end}
{synopt :{opt col:or}} makes the plot colored{p_end}
{synopt :{opt one:tailed}} displays the plot using one-tailed P values, with P values from 0 on the left to 1 on the right, with P = 0.5 as the null{p_end}

{syntab:Other options}
{synopt :{opt ad:just}} adjusts sample size to the effective sample size{p_end}
{synopt :{opt eff:ect}} creates a variable showing the estimated effect size of the study, given the total number of participants,
P value, statistical type and any other information available{p_end}
{synopt :{opt fish:ers}} displays the combined P value from Fisher's combined probability test{p_end}
{synopt :{opt stouf:fers}} displays the combined P value from Stouffer's Z score method{p_end}
{synopt :{opt ra:nge(varname)}} variable that specifies, with the P value, the range the P value could take, e.g. 0.05 < P < 1.
This will create a line for the study rather than a point{p_end}
{synopt :{opt tails(varname)}} variable stating whether the study P value is one-tailed or two-tailed; use 1 = one-tailed, 2 = two-tailed.
If the {opt one:tailed} option is specified, the two-tailed P values will be converted to one-tailed P values.
If not, the one-tailed P values will be converted to two-tailed P values.{p_end}

{synoptline}
{p2colreset}{...}

{title:Description}

{p 4 4 2}
The {cmd:albatross} command creates an albatross plot from studies with number of participants, P values and effect directions.
The plot shows a summary of studies when meta-analysis is not possible, with effect contours derived from the specified statistical method.
 
{p 4 4 2}
The command requires 3 variables to be declared in this order: {it:number of participants, P value} and {it:effect direction}.
Both the number of participants and P values must be larger than 0.
Negative effect directions are specified with a negative number (e.g. -1), positive effect directions with a positive number (e.g. 1).
The statistical type must be specified; some types require additional information to be specified, see {it:statistical types} above.
If using standardized variables ({opt ssd(#)}, {opt sr(#)} or {opt sbaseline(#)}) please ensure reasonable values are used;
contours may perform unexpectedly otherwise.

{p 4 4 2}
The number of participants can be adjusted to the effective sample size using the {cmd:adjust} option and additional information.
The magnitude of the effect can be calculated for all studies using the {cmd:effect} option; this is useful for comparison,
but will not necessarily be accurate (depending on the further information provided and the study itself).

{p 4 4 2}
Several variables are deleted and created by the program when it runs: _P_graph, _N_graph, _N_adjusted, _TOUSE, _EST_* and _ALBA_*.
If these variables are not renamed they will be overwritten.

{p 4 4 2}
A paper is forthcoming describing the {cmd:albatross} command and the equations required to calculate the effective sample size for each statistical type.
The main albatross plot paper has been published in the journal of Research Synthesis Methods (28 April 2017).

{p 4 4 2}
{cmd:albatross} requires Stata version 11 or later.

{title: Statistical Types}

{p 4 8 2}
{cmd:mean} - comparison of one sample mean with a known population mean.
This plot will not be informative unless the population means (i.e. the comparison means) of all studies are similar.
Requires one of: {opt sd(varname)} or {opt ssd(#)}.

{p 4 8 2}
{cmd:proportion} - comparison of one sample proportion with a known population proportion.
This plot will not be informative unless the population proportions (i.e. the comparison proportion) of all studies are similar.
Optional: {opt sprop:ortion(#)}.

{p 4 8 2}
{cmd:md} (mean difference) - comparison of the means of two samples.
Requires one of: {opt sd(varname)}; {opt ssd(#)}; {opt sd1(varname)} and {opt sd2(varname)}; or {opt ssd1(#)} and {opt ssd2(#)}.
Optional: {opt r(varname)} and {opt sr(#)}.

{p 4 8 2}
{cmd:smd} (standardized mean difference) - comparison of two sample means, standardized by dividing by the pooled standard deviation of the exposure.
Optional: {opt r(varname)} and {opt sr(#)}.

{p 4 8 2}
{cmd:correlation} - comparison of two continuous variables in one sample.
No required or optional {it:type_options}.

{p 4 8 2}
{cmd:beta} (linear regression) - comparison of two continuous variables in one sample.
Standardized univariable linear regression is equivalent to correlation.
No required or optional {it:type_options}.

{p 4 8 2}
{cmd:or} (odds ratio) - comparison of two groups with a binary exposure and outcome.
Requires one of: {opt base:line(varname)} or {opt sbase:line(#)}.
Optional: {opt r(varname)}, {opt sr(#)} and {opt or(varname)}.

{p 4 8 2}
{cmd:rr} (risk ratio/relative risk) - comparison of two groups with a binary exposure and outcome.
Requires one of: {opt base:line(varname)} or {opt sbase:line(#)}.
Optional: {opt r(varname)}, {opt sr(#)} and {opt rr(varname)}.

{title:Statistical Type Options}

{p 4 8 2}
{opt sd(varname)} or {opt ssd(#)}: at least one must be specified for {cmd:mean} and {cmd:md}.
For {cmd:md}, the standard deviation (SD) of both groups in each study are assumed to be equal.
If {opt sd(varname)} is specified alone, the contours will be drawn using the mean SD of the studies.
If {opt ssd(#)} is specified alone, the contours will be drawn using a SD of #.
If both {opt sd(varname)} and {opt ssd(#)} are specified, the contours will be drawn using a SD of #
and the number of participants will be adjusted to the effective sample size given a SD of # if {cmd:adjust} is specified.

{p 4 8 2}
{opt sd1(varname)} and {opt sd2(varname)}, or {opt ssd1(#)} and {opt ssd2(#)}: alternative to {opt sd(varname)} or {opt ssd(#)},
at least one pair must be specified.
The standard deviation (SD) of both groups (e.g. treatment and control) in each study are specified, useful when the SD is known to be different between groups.
If {opt sd1(varname)} and {opt sd2(varname)} are specified alone, the contours will be drawn using the mean SD of each group in the studies.
If {opt ssd1(#)} and {opt ssd2(#)} are specified alone, the contours will be drawn using the specified SDs.
If all options are specified, the contours will be drawn using the specified SDs and the number of participants will be adjusted to the effective sample size given a SD of # if {cmd:adjust} is specified.

{p 4 8 2}
{opt sprop:ortion(#)}: optional for {cmd:proportion}. 
If specified, the contours will be drawn using a population proportion of #, otherwise a proportion of 0.5 is assumed. 

{p 4 8 2}
{opt r(varname)} or {opt sr(#)}: optional for {cmd:md}, {cmd:smd}, {cmd:rr} and {cmd:or}.
The ratio of group sizes (r = n1/n2) can be specified, otherwise it will be assumed to be 1.
If {opt r(varname)} is specified alone, the contours will be drawn using a ratio of 1 and the number of participants will be adjusted to the effective sample size given a ratio of 1 if {cmd:adjust} is specified.
If {opt sr(#)} is specified alone, the contours will be drawn using a ratio of #.
If both {opt r(varname)} and {opt sr(#)} are specified,
the contours will be drawn using a ratio of # and the number of participants will be adjusted to the effective sample size given a ratio of # if {cmd:adjust} is specified.

{p 4 8 2}
{opt base:line(varname)} or {opt sbase:line(#)}: at least one must be specified for {cmd:rr} and {cmd:or}.
The baseline risk is the proportion of group 2 with the outcome.
If {opt base:line(varname)} is specified alone, the contours will be drawn using the mean baseline risk across all studies.
If {opt sbase:line(#)} is specified alone, the contours will be drawn using a baseline risk of #.
If {opt base:line(varname)} and or {opt sbase:line(#)} are specified,
the contours will be drawn using a baseline risk of # and the number of participants will be adjusted to the effective sample size given a baseline risk of # if {cmd:adjust} is specified.
The baseline risk should always be between 0 (no members of group 2 have the outcome) and 1 (all members of group 2 have the outcome).

{p 4 8 2}
{opt rr(varname)} and {opt or(varname)}: optional for {cmd:rr} and {cmd:or} respectively.
The risk ratio and odds ratio are required to calculate effective sample sizes (with the {cmd:adjust} option), but can be estimated if not specified.
If some ratios are known, the program will calculate estimates for only the unknown ratios. 

{title:Plot Options}

{p 4 8 2}
{opt con:tours(# # #)} specify the magnitude of 1-3 contours from smallest to largest, e.g. small, medium, large.
Contours for RRs and ORs are specified on the RR and OR scale i.e. 1 is null, less than 1 if a negative effect, more than 1 is a positive effect.
Negative contours (including RRs and ORs less than 1) and 4 or more contours are not allowed.
If contours are not specified, the program will automatically plot three contours.
Most contours are listed in the legend as +-{it:contour effect size}. 
As OR and RR effect sizes are always positive, the contours are listed as {it:left contour effect size}|{it:right contour effect size},
where {it:left contour effect size} = 1/{it:right contour effect size}, {it:right contour effect size} > 1,
and the contours appear on the left and right sides of the plot respectively.

{p 4 8 2}
{opt ti:tle(string)} and {opt sub:title(string)} specify the title and subtitle of the plot; no other graph options are allowed.
All title and subtitle suboptions are allowed, see {help title_options}.

{p 4 8 2}
{opt nogr:aph} suppresses creation of the plot; useful if effective sample sizes are desired without the graph.

{p 4 8 2}
{opt nono:tes} suppresses the default notes on any specifications of the effect contours (e.g. using a standard deviation of 2),
whether the effective sample size was used (adjusted data) and whether any data were restricted using {it:if} or {it:in}.

{p 4 8 2}
{opt by(varname)} specifies a variable where levels of {it:varname} are drawn with different markers. Only one {it:varname} may be specified.

{p 4 8 2}
{opt col:or} makes the plot colored.

{p 4 8 2}
{opt one:tailed} displays the plot using one-tailed P values i.e. P values from 0 on the left to 1 on the right, with P = 0.5 as the null.
P values are all assumed to be one-tailed if {opt one:tailed} is specified but {opt tails(varname)} is not specified.

{title:Other options}

{p 4 8 2}
{opt ad:just} adjusts sample size to the effective sample size; this requires additional information, such as {opt base:line(varname)}, {opt r(varname)} and {opt sd(varname)}.
This is especially useful for cohort studies where the baseline risk may be variable, or combinations of cohort and case-control studies.
The effective sample size can be further specified with the standardized options, such as {opt sr(#)} and {opt sbase:line(#)}.

{p 4 8 2}
{opt eff:ect} creates a variable showing the estimated effect size of each study, given the total number of participants, statistical type and any other information available.
This is an estimate and has no guarantee of accuracy; accuracy will be improved by specifying all optional variables, such as {opt sr(#)} and {opt sbase:line(#)}.

{p 4 8 2}
{opt fish:ers} calculates the combined P values from Fisher's combined probability method. The result is displayed in the main Stata window, not the albatross plot.
Fisher's combined probability method calculates a Chi squared test statistic with 2k degrees of freedom using the formula: 
-2*sum(ln(p)), where p is the P value for each study, and k is the total number of studies.

{p 4 8 2}
{opt stouf:fers} calculates the combined P values from Stouffer's Z score method. The result is displayed in the main Stata window, not the albatross plot.
Stouffer's Z score method calculates a Z score using the formula: 
sum(Z)/sqrt(k), where Z is the Z score for each study, and k is the total number of studies.

{p 4 8 2}
{opt ra:nge(varname)} specifies, with the P value, the upper and lower limits of the P value.
This will create a line for any study with a value for both P value and {opt ra:nge} rather than a point.
Useful for when the study P value has been written as P > X or P < X.
For P > 0.05 (or P = NS), the P value would be 0.05 and {opt ra:nge} would be 1; the study would be drawn as a line between P = 0.05 and P = 1 along y = N.
For P < X, it is suggested either the next significance level be used in {opt ra:nge}, or P = X should be used;
for example for P < 0.01, use P = 0.01 without any value in {opt ra:nge}, or specify the {opt ra:nge} value as 0.001.

{p 4 8 2}
{opt tails(varname)} is a variable stating whether the study P value is one-tailed or two-tailed; use 1 = one-tailed, 2 = two-tailed.

{title:Remarks on albatross}

{p 4 4 2}
The plot will automatically label axes to avoid cluttering. By default, all plots are drawn assuming two-sided P values.
If using one-sided P values, either specify the {opt one:tailed} or {opt tails} options, or convert to two-sided P values before using {cmd: albatross}.
Note that the plot will not automatically relabel the axes for N > 10,000,000 or P values < 10^-50.
The plots will struggle too far beyond these values.

{title:Stored}

{p 4 4 2}
By default, {cmd:albatross} adds the following new variables to the dataset: {p_end}

	{it:_TOUSE}		included studies are marked as 1, otherwise 0
	{it:_P_graph}		the P value plotted on the graph (transformed)
	{it:_N_graph}		the number of participants plotted on the graph (transformed)
	{it:_EST_[type]}	the estimated of the magnitude of effect (only with option {cmd:effect} specified)
	{it:_N_adjusted}	the effective sample size (transformed) (only with option {cmd:adjust} specified)

{p 4 4 2}	
These values can be used to create your own plot using transformed values of P and N. 

{title:Examples}

{p 4 4 2}
All examples use simulated data, created separately for each statistical type.
See {help albatross_examples} for the code used to create each simulation.

{title:Mean}

{p 4 4 2}
Basic albatross plot

{p 4 8 2}
{cmd:. albatross n p mean_dif, type(mean) sd(sd)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_mean_1":click to run})}

{p 4 4 2}
Use the standard deviation to adjust to the effective sample size

{p 4 8 2}
{cmd:. albatross n p mean_dif, type(mean) sd(sd) adjust}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_mean_2":click to run})}

{title:Proportion}

{p 4 4 2}
Basic albatross plot

{p 4 8 2}
{cmd:. albatross n p prop_dif, type(proportion)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_proportion_1":click to run})}

{p 4 4 2}
Plot specifying the proportion to be 0.15 in all contours

{p 4 8 2}
{cmd:. albatross n p prop_dif, type(proportion) spro(0.15)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_proportion_2":click to run})}

{title:Correlation coefficient} – equivalently, {title:beta}

{p 4 4 2}
Basic albatross plot

{p 4 8 2}
{cmd:. albatross n p corr, type(correlation)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_corr_1":click to run})}

{p 4 4 2}
Plot split by “large” and “small” in color

{p 4 8 2}
{cmd:. albatross n p corr, type(beta) by(by) color}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_corr_2":click to run})}

{title:Mean difference}

{p 4 4 2}
Basic albatross plot, assuming only the mean difference and standard deviation are known

{p 4 8 2}
{cmd:. albatross n p md, type(md) sd(sd)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_md_1":click to run})}

{p 4 4 2}
Use the standard deviation of both groups and proportion of cases to controls to estimate the effective sample sizes

{p 4 8 2}
{cmd:. albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_md_2":click to run})}

{p 4 4 2}
Manually change the contours to better fir the graph

{p 4 8 2}
{cmd:. albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust contours(0.2 0.4 0.6)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_md_3":click to run})}

{title:Standardized mean difference}

{p 4 4 2}
Basic albatross plot

{p 4 8 2}
{cmd:. albatross n p smd, type(smd)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_smd_1":click to run})}

{p 4 4 2}
Plot with range specified, so lines are produced for studies with P > 0.1

{p 4 8 2}
{cmd:. albatross n p smd, type(smd) range(range)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_smd_2":click to run})}

{p 4 4 2}
Plot with titles, range, two contours specified

{p 4 8 2}
{cmd:. albatross n p smd, type(smd) contours(0.5 1) range(range) title("When P values are inexact, data: generated", size(medium))}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_smd_3":click to run})}

{p 4 4 2}
Plot with titles, range and restricted to n > 250 in the first 10 studies	

{p 4 8 2}
{cmd:. albatross n p smd if n > 250 in 1/10, type(smd) contours(0.25 0.5 1) range(range) title("When P values are inexact (restricted), data simulated", size(small))}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_smd_4":click to run})}

{p 4 4 2}
No plot, but display Fisher's and Stouffer's combined P values	

{p 4 8 2}
{cmd:. albatross n p smd, type(smd) nograph fishers stouffers}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_smd_5":click to run})}

{title:Relative risks and odds ratios}

{p 4 4 2}
Basic albatross plot

{p 4 8 2}
{cmd:. albatross n p_rr e, type(rr) baseline(baseline)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_rr_1":click to run})}

{p 4 8 2}
{cmd:. albatross n p_or e, type(or) baseline(baseline)}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_or_1":click to run})}

{p 4 4 2}
Fully specified plot with estimated effective sample size

{p 4 8 2}
{cmd:. albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_rr_2":click to run})}

{p 4 8 2}
{cmd:. albatross n p_or e, type(or) baseline(baseline) r(r) adjust}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_or_2":click to run})}

{p 4 4 2}
Fully specified plot with estimated effective sample size, with standardized r and baseline specified, split into two variables and in color

{p 4 8 2}
{cmd:. albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_rr_3":click to run})}

{p 4 8 2}
{cmd:. albatross n p_or e, type(or) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color}
{p_end}
{p 12 12 2}
{it:({stata "albatross_examples albatross_example_or_3":click to run})}

{title:Authors}

{p 4 4 2}
Sean Harrison ({browse "mailto:sean.harrison@bristol.ac.uk":sean.harrison@bristol.ac.uk}). School of Social and Community Medicine, University of Bristol, Canynge Hall, Whiteladies Road, Bristol BS8 2PS, UK

{title:Version 2 update (June 2017)}

{p 4 4 2}
Updates: 1) the program can now calculate Fisher's and Stouffer's methods of combining P values; 2) minor issues with the examples were fixed, such as compatability issues with earlier versions of Stata;
help text has been slightly reworded in places; 4) plot markers are now blue in color plots when the by() option is not used, in line with normal Stata graphs. 

{title:Acknowledgements}

{p 4 4 2}
With thanks to Julian Higgins and Hayley Jones for all their help creating albatross plots.
Also with thanks to Grace Young for commenting on the help file.

{title:References}

{p 4 4 2}
Harrison, S., Jones, H.E., Martin, R.M., Lewis, S., Higgins, J.P.T.
The albatross plot: a novel graphical tool for presenting results of diversely reported studies in a systematic review. 
{it:Harrison S, Jones HE, Martin RM, Lewis SJ, Higgins JP. The albatross plot: a novel graphical tool for presenting results of diversely reported studies in a systematic review. Res Synth Methods. 2017}.

{p 4 4 2}
Harrison, S., Jones, H.E., Martin, R.M., Lewis, S., Higgins, J.P.T. 
The albatross plot program: a novel graphical tool for presenting results of diversely reported studies in a systematic review in Stata. 
{it:Currently Unpublished}.

