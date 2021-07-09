{smcl}
{* *! version 1.2.1 22jul2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_forest##syntax"}{...}
{viewerjumpto "Description" "network_forest##description"}{...}
{viewerjumpto "Examples" "network_forest##examples"}{...}
{title:Title}

{phang}
{bf:network forest} {hline 2} Forest plot of network meta-analysis data and summaries


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network forest} {ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options controlling the summary treatment contrasts}
{synopt:{opt cons:istency(off)}} 
Omits the "pooled overall" summaries from the forest plot.{p_end}
{synopt:{opt inco:nsistency(off)}}
Omits the "pooled within design" summaries from the forest plot.{p_end}

{syntab:Options controlling output}
{synopt:{opt l:ist}}Data for the forest plot are listed.{p_end}
{synopt:{opt nogr:aph}}Forest plot is suppressed.{p_end}
{synopt:{opt clear}}Data for the forest plot are loaded into memory.
The forest plot command can then be recalled by pressing F9.
{p_end}

{syntab:Options controlling graph appearance}
{synopt:{opt col:ors(string)}}Three colours for the study-specific results, 
"pooled within design" results, and "pooled overall" results. 
Default is {cmd:colors(blue green red)}.{p_end}
{synopt:{opt contrasto:ptions(string)}}
Options for the text identifying the contrasts (e.g. "C vs. B"). 
Any {help scatter##marker_label_options:marker label options} are possible, 
e.g. {cmd:contrastoptions(mlabsize(large) mlabcolor(red))}.{p_end}
{synopt:{opt trtc:odes}}makes the display use the treatment codes rather than the full treatment names.{p_end}
{synopt:{opt contrastp:os(#)}}Value of the horizontal axis at which 
the text identifying the contrasts (e.g. "C vs. B") is centred.{p_end}
{synopt:{opt ncol:umns(#)}}Number of columns for display.
Default is determined so that rows per column is approximately 10 times number of columns.{p_end}
{synopt:{opt column:s(string)}}
How to assign contrasts to columns. 
{cmd:columns(xtile)} assigns contrasts to columns in order using {help xtile} 
and can lead to very unbalanced columns (i.e. much more forest in one column than another).
{cmd:columns(smart)} assigns contrasts to columns to optimise balance without 
keeping the logical order of the contrasts (so e.g. column 1 may contain "B vs A" and "D vs. A" 
while column 2 contains "C vs. A").
The default is {cmd:columns(smart)}.{p_end}
{synopt:{opt force}}Confidence intervals are truncated within the range implied by {cmd:xlabel()}.
Truncated confidence intervals are indicated by arrows. 
{cmd:force} is ignored if {cmd:xlabel()} is not specified.
{p_end}
{synopt:{opt dia:mond}}Summaries ("Pooled by design" and "Pooled overall") are displayed as diamonds.
This is useful for monochrome printing.
{p_end}
{synopt:{opt group}(design|type)}Within comparisons, the forest plot may be ordered by design 
(showing the summary for each design after the studies for that design)
or by type (showing all the studies then all the summaries). 
The default is {cmd:group(design)} if inconsistency results are shown 
and {cmd:group(type)} if inconsistency results are not shown.
{p_end}
{synopt:{opt eform}}The horizontal axis is labelled using the exponential of the values.
If you don't like the default axis title, you can change it using {cmd:xtitle()}.
{p_end}
{synopt:{it:graph_options}}Many other standard options for {help graph twoway}:
for example, {cmd:note(,col(red))} or {cmd:legend(pos(3) col(1))}.
{cmd:xlabel()} is useful to change the axis labelling - see {cmd:force} above.
{cmd:msize(}{help markersizestyle}{cmd:)} is useful to change the marker sizes 
- the default is {cmd:msize(*0.2)}, 
so try e.g. {cmd:msize(*0.15)} or {cmd:msize(*0.3)}.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network forest} draws a forest plot of network meta-analysis data.
For each contrast for which there is direct evidence
(i.e. which is estimated within one or more trials),
the forest plot displays:

{phang}(1) "Studies": each study contributing direct evidence, grouped by design 
(i.e. set of treatments in a study);

{phang}(2) "Pooled within designs": the pooled treatment effect in each design, 
estimated by the inconsistency model previously fitted using {help network meta:network meta inconsistency}
(omitted if the inconsistency model has not been fitted);
and

{phang}(3) "Pooled overall": the overall treatment effect, estimated by the consistency model 
previously fitted using {help network meta:network meta consistency}
(omitted if the consistency model has not been fitted).

{pstd}Each of (1), (2) and (3) is displayed as a point estimate and 95% confidence interval 
(or other confidence level determined by {help level:set level} or the {cmd:level(#)} option).
The marker representing each point estimate has size proportional 
to the inverse square of the standard error.
Because pooled estimates (2 and 3) allow for between-studies heterogeneity, 
they may have wider confidence intervals and smaller markers than study-specific estimates (1).
(2) and (3) come from matrices of fitted values stored by {help network meta:network meta}.


{marker examples}{...}
{title:Examples}

{pin}. {stata "network forest, xtitle(Log odds ratio and 95% CI) title(Thrombolytics network) contrastopt(mlabsize(small))"}


{p}{helpb network: Return to main help page for network}

