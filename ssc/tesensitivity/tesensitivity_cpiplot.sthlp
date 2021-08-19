{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "tesensitivity" "tesensitivity"}{...}
{viewerjumpto "Syntax" "tesensitivity_cpiplot##syntax"}{...}
{viewerjumpto "Description" "tesensitivity_cpiplot##description"}{...}
{viewerjumpto "Options" "tesensitivity_cpiplot##options"}{...}
{viewerjumpto "Remarks" "tesensitivity_cpiplot##remarks"}{...}
{viewerjumpto "Examples" "tesensitivity_cpiplot##examples"}{...}
{title:Title}

{phang}
{bf:tesensitivity cpiplot} {hline 2} plot results of conditional partial independence analysis

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tesensitivity} {cmd:cpiplot} [{it:estimates}]
[{cmd:,} 
{it:{help tesensitivity_cpiplot##display_options:display_options} {help tesensitivity_cpiplot##formatting_options:formatting_options}]}

{phang}
{it:estimates} is a list of stored results from calls to {cmd:tesensitivity cpi}
if this is not specified, the estimation results in memory are used.

{synoptset 37 tabbed}{...}
{marker display_options}{...}
{synopthdr:display_options}
{synoptline}
{synopt:{opt nobreakdown}}suppress horizontal line for the breakdown point{p_end}
{synopt:{opt creflines}}display a vertical line for maximum propensity score deviation associated with each covariate (see details){p_end}
{synoptline}
{p 4 6 2}
{it:display_options} control the elements of the graph to be included.

{marker formatting_options}{...}
{synopthdr:formatting_options}
{synoptline}
{synopt:{opt boundpatterns}({it:pattern_list})}specify line patterns for bound lines{p_end}
{synopt:{opt boundcolors}({it:color_list})}specify line colors for bound lines{p_end}
{p2col: {opt boundoptions}({it:{help connect_options}})}additional options for bound lines{p_end}
{p2col: {opt breakdownoptions}({it:{help added_line_options}})}additional options for breakdown analysis conclusion line{p_end}
{p2col: {opt legoptions}({it:{help legend_options}})}formatting options for legend{p_end}
{p2col: {opt noleg:end}}suppress legend{p_end}
{p2col: {it:{help twoway_options}}}formatting options for overall plot{p_end}
{synoptline}
{p 4 6 2}
{it:formatting_options} control the style of the graph.

{marker description}{...}
{title:Desciption}

{pstd}
{cmd:tesensitivity cpiplot} is a post estimation command that plots results
from a call to {cmd:{help tesensitivity_cpi:tesensitivity cpi}}. By default 
a plot is produced showing the upper and lower bounds of the statistic given 
in the last call against values of c-dependence ranging from 0 to 1.
Points in the grid of c-dependence values specified in the call to 
{cmd:{help tesensitivity_cpi:tesensitivity cpi}} are plotted with a linear 
interpolation between them. If multiple {cmd:estimates} are included, then bounds 
for all estimates are plotted on the same graph. The graph is produced using 
Stata's {cmd:graph twoway} command, and formatting can be controlled by passing
options to that command through the interface provided by this command.

{marker options}{...}
{title:Options}

{dlgtab:Display options}

{phang}
{cmd: nobreakdown} if this option is not chosen, a horizontal line is drawn at the
value of the breakdown analysis conclusion (e.g., ATE > 0). {it} Note: currently, if 
multiple  estimates are plotted, only the breakdown point conclusion 
for the last estimate is plotted. Therefore, it is recommended to only include the breakdown
line with multiple estimates when the same breakdown analysis conclusion is used for each
estimate.{sf} 

{phang}
{cmd: creflines} include vertical line for the maximum propensity score deviation
associated with each covariate. These are the calculated by 
{cmd: {help tesensitivity_cscale:tesensitivity cscale}, cmax}. See the help file
for that command for details on the interpretation of these lines. {it}Note: in order 
to use this option, {cmd:{help tesensitivity_cpi:tesensitivity cpi}} must have been called with the option 
{cmd: creference}. {sf}  

{dlgtab:Formatting options}

{phang}
{cmd: boundpatterns}({it:pattern_list}) bounds for each of the estimates are 
plotted using these patterns. {it:pattern_list} is a list of up to 8 {help linepatternstyle:linepatternstyles}
separated by spaces. If only one pattern is specified it is used for all 
estimates. 

{phang}
{cmd: boundcolors}({it:color_list}) bounds for each of the estimates are 
plotted using these colors. {it:color_list} is a list of up to 8 {help colorstyle:colorstyles}
separated by spaces. If only one pattern is specified it is used for all 
estimates.

{phang}
{cmd: boundoptions}({it:{help connect_options}}) bound lines for all estimates
are plotted with these options. Any options in {it:{help connect_options}}
may be included except for {cmd:lpattern} and {cmd:lcolor}.

{phang}
{cmd: breakdownoptions}({it:{help added_line_options}}) a horizontal line at the 
breakdown analysis conclusion is plotted with these display options. Any suboptions to 
{it:{help added_line_options}} may be included.

{phang}
{cmd: legoptions}({it:{help legend_options}}) by default, a legend is added to the
plot if multiple estimates are included or if the {cmd:creflines} is specified. 
This option can be used to control the formatting of the legend in either case.
Any {it:{help legend_options}} can be included except {cmd:order} or {cmd:label}.

{phang}
{cmd: nolegend} suppresses the legend.

{phang}
{cmd:{it:{help twoway_options}}} any additional {it:{help twoway_options}} to
Stata's {cmd:{help twoway}} command may be included except for {it:{help legend_options}}
 
{marker remarks}{...}
{title:Remarks}

{p 4 4 4}
See {help tesensitivity##further_information:here} for links to the articles 
this package is based on, more detailed documentation on the implementation in 
this package, and examples of its use.
 
{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse lalonde1986, clear}{p_end}
{pstd}Loads LaLonde (1986) dataset included with tesensitivity package.

{phang}{cmd:. qui tesensitivity cpi (re78 age education) (treat age education) if sample1, ate}{p_end}
{phang}{cmd:. qui estimates store ate_sample1}{p_end}
{phang}{cmd:. qui tesensitivity cpi (re78 age education) (treat age education) if sample3, ate}{p_end}
{phang}{cmd:. qui estimates store ate_sample3}{p_end}
{pstd} Calculates bounds of the ATE for two samples and stores them.

{phang}{cmd:. tesensitivity cpiplot ate_sample1 ate_sample3}{p_end}
{pstd} Produces a graph comparing the how the bounds on the ATE for the 
two samples vary with the level of c-dependence.

{phang} For more examples see this {browse "https://github.com/mattmasten/tesensitivity/blob/master/vignette/vignette.pdf":vignette}.
