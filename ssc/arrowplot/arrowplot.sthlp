{smcl}
{* *! version 1.0.0 18 August 2014}{...}
{vieweralsosee "[G] graphics" "mansection G graphics"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "arrowplot##syntax"}{...}
{viewerjumpto "Description" "arrowplot##description"}{...}
{viewerjumpto "Options" "arrowplot##options"}{...}
{viewerjumpto "Examples" "arrowplot##examples"}{...}
{viewerjumpto "References" "arrowplot##references"}{...}


{hline}
help for {hi:arrowplot}
{hline}

{title:Title}

{p 8 20 2}
    {hi:arrowplot} {hline 2} Combined plot for graphing inter-group and intra-group trends

{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:arrowplot} {it:yvar} {it:xvar} {ifin} {weight}{cmd:,} groupvar{cmd:(}{it:varname}{cmd:)} [{it:{help arrowplot##options:options}}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmdab:line:size(}#{cmdab:)}}Sets the size of arrows for each intra-group trend.  If not specified, a default value is chosen based on the range of the y-axis.
{p_end}
{...}
{synopt :{cmdab:cont:rols(}{help varlist}{cmd:)}}Allows for additional independent variables to be included as controls in intra-group regression trends.
{p_end}
{...}
{synopt :{cmdab:groupname(}{help string}{cmd:)}}Changes "inter-group" in the graph legend to "inter-groupname" where groupname is specified by the user (eg "inter-country").
{p_end}
{...}
{synopt :{cmdab:regopts(}{help regress##options:regress options}{cmd:)}}Allows for any regression options such as clustering.
{p_end}
{...}
{synopt :{cmdab:gen:erate(}newvar{cmd:)}}Produces a new variable containing inter-group (conditional) correlations.
{p_end}
{...}
{synopt :{it:twoway_options}}Any options documented in  {manhelpi twoway_options G-3}{p_end}
{...}
{synoptline}
{p2colreset}

{marker description}{...}
{title:Description}

{p 6 6 2}
{hi:arrowplot} creates graphs showing inter-group and intra-group variation by overlaying arrows for intra-group (regression) trends on a scatter plot.  
This is similar to the well known Stevenson-Wolfers happiness graphs.  {hi:arrowplot} requires the definition of a {it:yvar} and {it:xvar} (plotted on
the y- and x-axis respectively), as well as the definition of a groupvar which is the group over which the plot should be made (for example: country,
region, industry).

{p 6 6 2}
{hi:arrowplot} allows for intra-group (regression) trends to be either unconditional, or conditional upon any number of independent control variables.  
Similarly, intra-group regression trends allow for weighting, and any other regression options permitted in Stata's {help regress} command.



{marker options}{...}
{title:Options}
 {p 6 6 2}
{cmdab:line:size(}#{cmdab:)} Defines the size of the arrows which plot the intra-group trends.  If not specified, arrows are defined to 
be the equivalent of 8 percent of the range of the y-axis of the plot.  If this option is used, the size should be expressed in terms of units of the
variable on the y-axis.

 {p 6 6 2}
{cmdab:cont:rols(}{help varlist}{cmd:)} Allows for intra-group (regression) trends to be conditional on additional independent variables.  This
option allows for {help fvvarlist:factor variables} and other {help varlist:wildcards}.

 {p 6 6 2}
{cmdab:groupname(}{help string}{cmd:)} Changes the legend on the plot to replace the general term 'intra-group', with 'intra-newname', where
newname should be passed as the argument to groupname.  For example, specifying {cmdab:groupname(}Country{cmd:)}, will result in a legend
which displays 'Intra-Country'.

 {p 6 6 2}
{cmdab:regopts(}{help regress##options:regress options}{cmd:)} Allows for any other {help regress:regression} options to be included when calculating
intra-group (conditional) regression trends.

 {p 6 6 2}
{cmdab:gen:erate(}newvar{cmd:)} Produces a new variable in the user's dataset.  This variable contains the intra-group regression trend for each
group.  The value of this variable is (necessarily) identical for each observation within a given group.

 {p 6 6 2}
{it:twoway_options} Allows for the inclusion of any additional {help twoway_options:graphing options} such as titles, axes, added lines, etc.



{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Plot inter- and intra-industry wage versus education using NLSW survey{break}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. gen ind="industry "}{p_end}
{phang2}{cmd:. egen industry=concat(ind ind_code)}{p_end}

{phang2}{cmd:. arrowplot ln_wage grade, groupvar(industry)}{p_end}

    {hline}

{pstd}Plotting inter- and intra-industry wage versus education conditonal on an individual's union status and tenure{p_end}

{phang2}{cmd:. arrowplot ln_wage grade, groupvar(industry) controls(union tenure)}{p_end}

    {hline}

{pstd}Plotting the same graph without missings, and with graph titles, labels, etc.{p_end}

{phang2}{cmd:. arrowplot ln_wage grade if ind_code!=., groupvar(industry) controls(union tenure) title(Education and Log Wage) subtitle(NLS 1968: Women 14-26) xtitle(Grade of Education) ytitle(Log Wage) scheme(s1color)}{p_end}

    {hline}

{marker references}{...}
{title:References}

{marker StevensonWolfers}{...}
{phang}
Betsey Stevenson & Justin Wolfers, 2008. 
{it: "Economic Growth and Subjective Well-Being: Reassessing the Easterlin Paradox"},
Brookings Papers on Economic Activity, Economic Studies Program, The Brookings Institution, vol. 39(1) (Spring), pages 1-102. 
{p_end}


{title:Acknowledgements}

    {p 4 4 2} Thanks to George Vega Yon for useful comments.


{title:Also see}

{psee}
Help:  {help plot}, {help twoway_pcarrow:pcarrow}, {help scatter}


{title:Author}

{pstd}
Damian Clarke, Department of Economics, University of Oxford. {browse "mailto:damian.clarke@economics.ox.ac.uk"}
{p_end}
