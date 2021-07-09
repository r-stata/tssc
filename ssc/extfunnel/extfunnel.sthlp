{smcl}
{* *! version 1.0.2 03jul2012 MJC }{...}
{hline}
{cmd:help extfunnel}{right: }
{hline}


{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:extfunnel} {hline 2}}Graphical augmentations to the funnel plot to illustrate potential impact of a new study on a meta-analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: extfunnel} {it:varname1} {it:varname2} {ifin} [{cmd:,} {it:options}]

{synoptset 34}{...}
{synopthdr}
{synoptline}
{synopt:{opt fixedi}}specifies a fixed effect model using the inverse variance method (default) {p_end}
{synopt:{opt randomi}}specifies a random effect model using the method of DerSimonian & Laird {p_end}
{synopt:{opt cp:oints(integer)}}the number of points to evaluate the contours; a greater value produces smoother contour plots {p_end}
{synopt:{opt null(real)}}value of the null hypothesis for effect estimate; default is 0 {p_end}
{synopt:{opt isq:uared(numlist max=5)}}I-squared contours {p_end}
{synopt:{opt tausq:uared(numlist max=5)}}tau-squared contours {p_end}
{synopt:{opt meas:ure(string)}}defines the target of inference which can be one of {cmd:lci}/{cmd:uci}/{cmd:ciwidth} {p_end}
{synopt:{opt loe(numlist max=2)}}defines the limits of clinical equivalence {p_end}
{synopt:{opt loel:ine}}displays the limits of clinical equivalence {p_end}
{synopt:{opt newstudyc:ontrol(integer)}}defines the number of patients in the control arm of a new trial {p_end}
{synopt:{opt newstudyt:reatment(integer)}}defines the number of patients in the treatment arm of a new trial {p_end}
{synopt:{opt or}}specifies that odds ratios should be used. Valid only when {cmd:newstudycontrol} and {cmd:newstudytreatment} are specified {p_end}
{synopt:{opt rr}}specifies that risk ratios should be used. Valid only when {cmd:newstudycontrol} and {cmd:newstudytreatment} are specified {p_end}
{synopt:{opt xrange(numlist)}}defines the range of effect estimates {p_end}
{synopt:{opt yrange(numlist)}}defines the range of standard errors {p_end}
{synopt:{opt sumd}}display summary diamond {p_end}
{synopt:{opt sumdp:osition(real)}}the vertical coordinate where the summary diamond is placed {p_end}
{synopt:{opt pred:iction}}display prediction interval {p_end}
{synopt:{opt nonull:line}}suppress display of line of no effect {p_end}
{synopt:{opt nopooled:line}}suppress display of pooled estimate line {p_end}
{synopt:{opt noshading}}suppress display of shaded regions {p_end}
{synopt:{opt noscat:ter}}suppress display of scatter of original study effects {p_end}
{synopt:{opt nometan}}suppress display of original meta-analysis results using {cmd:metan} {p_end}
{synopt:{opt label(string)}}pass label option to {cmd:metan} {p_end}
{synopt:{opt eform}}exponentiates the x-axis labels, valid only when input variables are log-transformed, e.g. log odds ratios {p_end}
{synopt:{cmdab:scheme(}{cmdab:g:rayscale)}}colour scheme is grayscale (default) {p_end}
{synopt:{cmdab:scheme(}{cmdab:c:olor)}}colour scheme is color {p_end}
{synopt:{opt add:plot(string)}}additional twoway plot {p_end}
{synopt:{opt level(real)}}statistical significance level; default is 5 {p_end}
{p2col: {help twoway_options}}pass options to the {cmd:twoway} plot {p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:extfunnel} creates graphical overlay augmentations to the funnel plot. The purpose of these overlays is to display the potential 
impact a new study would have on an existing meta-analysis, providing an indication of the robustness of the meta-analysis to 
the addition of new evidence. Thus, these extend the use of the funnel plot beyond assessments of publication biases. Two main graphical 
displays can be produced; i) statistical significance contours, which define regions of the funnel plot in which a new study would have 
to be located in order to change the statistical significance of the meta-analysis; and ii) heterogeneity contours, which show how a new study 
would affect the extent of heterogeneity in a given meta-analysis. extfunnel can also illustrate the impact a new study has on lower 
and upper confidence interval values, the confidence interval width of the pooled meta-analytic result, and overlays for the impact of a 
future study on, user defined, limits of clinical equivalence. Inverse variance weighted methods are implemented using both explicit formulae for 
contour lines, and a simulation approach optimised in Mata.{p_end}

{pstd}{it:varname1} is assumed to contain normally distributed effect estimates and {it:varname2} is 
assumed to contain standard errors of {it:varname1}.{p_end}


{title:Options}

{phang}{opt fixedi} specifies a fixed effect model using the inverse variance method. This is the default.{p_end}

{phang}{opt randomi} specifies a random effect model using the method of DerSimonian & Laird, with the estimate of 
heterogeneity being taken from the inverse-variance fixed-effect model.{p_end}

{phang}{opt cpoints(integer)} specifies the number of points to evaluate either the shaded statisticial significance contours 
and/or the heterogeneity contours. The default number for a fixed and random effect meta-analyses are 3500 and 100, respectively.  
When a random meta-analysis is invoked, the maximum number of contourpoints is 500. A larger number of {cmd:cpoints} results in a 
smoother graph, but takes longer to compute (see Remarks for more details).{p_end}

{phang}{opt null(real)} is the value of the null hypothesis for effect estimate; default is 0. When {cmd:measure} is specified 
this is the value which {cmd:lci}/{cmd:uci}/{cmd:ciwidth} is compared to. If {cmd:lci}/{cmd:uci} is specified the value of {cmd:null} is 
compared to lower/upper confidence interval value of the updated meta-analyses, and colour coded depending on whether the updated 
estimate is less than or more than the {cmd:null}. If {cmd:ciwidth} is specified then the width confidence interval of the updated 
meta-analyses are compared to the value define by {cmd:null}.{p_end}

{phang}{opt isquared(numlist)} Values that define the I-squared contours. Must be a numlist of maximum length
5 and should have elements in the range 0-100.{p_end}

{phang}{opt tausquared(numlist)} Values that define the Tau-squared contours. Must be a vector of maximum
length 4 and should have elements in the range 0-Inf.{p_end}

{phang}{opt measure(string)} defines the target of inference which can be one of {cmd:lci}/{cmd:uci}/{cmd:ciwidth}.{p_end}

{phang}{opt loe(numlist)} defines the limits of clinical equivalence. The default legend assumes a beneficial and detrimental effect in specific directions. 
The legend can be re-labelled using {cmd:legend(order(1 "text1" 2 "text2"...))}. For further details see Sutton et al. (2007).{p_end}

{phang}{opt loeline} displays the limits of clinical equivalence.{p_end}

{phang}{opt newstudycontrol(int)} defines the number of patients in the control arm of a new trial. {cmd:newstudytreatment} 
and {cmd:newstudycontrol} defined together produce a statistical significance contour graph, whereby each possible permutation 
of results is calculated and analysed within the appropriate meta-analysis model. Odds ratios and risk ratios are supported.{p_end}

{phang}{opt newstudytreatment(int)} defines the number of patients in the treatment arm of a new trial.{p_end}

{phang}{opt or} specifies that log odds ratios should be used, valid only when {cmd:newstudytreatment} and {cmd:newstudycontrol} 
are specified. This is the default. Alternatively, {cmd:rr} can be specified for risk ratios.{p_end}

{phang}{opt rr} specifies that log risk ratios should be used, valid only when {cmd:newstudytreatment} and {cmd:newstudycontrol} 
are specified.{p_end}

{phang}{opt xrange(numlist)} defines the range of effect estimates.{p_end}

{phang}{opt yrange(numlist)} defines the range of standard errors.{p_end}

{phang}{opt sumd} display the summary diamond.{p_end}

{phang}{opt sumdposition(real)} defines the vertical coordinate where the summary diamond is placed.{p_end}

{phang}{opt prediction} displays the prediction interval.{p_end}

{phang}{opt nonullline} suppresses the display of the vertical line of no effect.{p_end}

{phang}{opt nopooledline} suppresses the display of the vertical line at the pooled effect estimate.{p_end}

{phang}{opt noshading} suppresses the display of shaded regions.{p_end}

{phang}{opt noscatter} suppresses the display of the scatter of original study effects.{p_end}

{phang}{opt nometan} suppress display of original meta-analysis results using {cmd:metan}.{p_end}

{phang}{opt label([namevar=namevar], [yearvar=yearvar])} labels the data by its name, year or both. This is a {cmd:metan} option. Either or both option/s may be left blank. For the table 
display the overall length of the label is restricted to 20 characters. {p_end}

{phang}{opt eform} exponentiates the x-axis labels (valid only when the input variables are log transformed, 
e.g. log odds ratios or log risk ratios).{p_end}

{phang}{opt scheme}({it:string}) specifies the color scheme of the graph. Default is {cmd:grayscale}. Can also specify {cmd:color} which can be useful to distinguish areas when {cmd:loe} is specified. {p_end}

{phang}{opt addplot(string)} allows additional twoway plots to be overlayed on the {cmd: extfunnel} plot. {p_end}

{phang}{opt level(real)} defines the statistical significance level. Default is 95. {p_end}

{phang}{opt twoway_options} see {manhelpi twoway_options G}. {p_end}


{title:Remarks}

{pstd}{cmd:extfunnel} uses a simulation based process, optimised in Mata, to produce all statistical significance contour graphs, except when {cmd:fixedi} is used. This process can be slightly 
computationally intensive when {cmd:cpoints} is large (>100). We recommend that initial plots are built with the default {opt cp}(100), with final plots being produced using {opt cp}(500).
When {cmd:newstudycontrol} and {cmd:newstudytreatment} are used, {cmd:extfunnel} can be very computationally intensive as this form of display has not been optimised in Mata.{p_end}

{pstd}Return code 900 or macros overflow can occur when {cmd:cp} is large, this can be remedied by reducing {cmd:cp} slightly.{p_end}


{title:Examples}

{pstd}Fixed effect funnel plot with statistical significance contours.{p_end}
{phang}{cmd:. extfunnel logOR selogOR}{p_end}

{pstd}Random effect funnel plot with statistical significance contours, with summary diamond and a prediction interval displayed.{p_end}
{phang}{cmd:. extfunnel logOR selogOR, randomi sumd predict cp(500)}{p_end}

{pstd}Fixed effect funnel plot with statistical significance contours and I-squared contours.{p_end}
{phang}{cmd:. extfunnel logOR selogOR, isquared(25 35 50)}{p_end}

{pstd}Fixed effect funnel plot with statistical significance contours and tau-squared contours.{p_end}
{phang}{cmd:. extfunnel logOR selogOR, tausquared(0.5 1 1.5)}{p_end}

{pstd}Random effect funnel plot with user defined limits of clinical equivalence.{p_end}
{phang}{cmd:. extfunnel ES seES, randomi loe(-0.25 0.25) nometan sumd nopooledline loeline cp(400)}{p_end}


{title:Saved results}

{pstd}
{cmd:extfunnel} saves the following in {cmd:r()}:

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Matrices:}{p_end}
{synopt:{cmd:r(ESmat)}}Effect estimate values used to create the plot {p_end}
{synopt:{cmd:r(seESmat)}}Standard error values used to create the plot {p_end}
{synopt:{cmd:r(status)}}Status code for each combination of effect and standard error. {p_end}

{pstd}{cmd:r(status)} coding: For the stat. sig. plot; coded 0/1/2 i.e. non-sig/stat. sig greater than null/stat. sig. less than null. Coded 1 to 8 for limits of clinical equivalence, corresponding to default legend. {p_end}

{pstd}Note: Matrices are not returned under a fixedi statistical significance contour plot.{p_end}


{title:Authors}

{pstd}Michael J. Crowther, University of Leicester, United Kingdom. {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{pstd}Dean Langan, Clinical Trials Research Unit (CTRU), University of Leeds, United Kingdom. {browse "mailto:d.p.langan@leeds.ac.uk":d.p.langan@leeds.ac.uk}.{p_end}

{pstd}Alex J. Sutton, University of Leicester, United Kingdom. {browse "mailto:ajs22@le.ac.uk":ajs22@le.ac.uk}.{p_end}
 
{pstd}Thanks to Rob Herbert and Manuela Ferreira for invaluable suggestions for improvement and testing of the command. {p_end}
 
{phang}Please report any errors you may find.{p_end}


{title:References}

{phang}Crowther, M. J., Langan, D. and Sutton, A. J. Graphical augmentations to the funnel plot assess the impact of a new study on an existing meta-analysis: The extfunnel command. {it:The Stata Journal} 2012; (In Press). {p_end}

{phang}Langan, D., Higgins, J. P. T., Gregory, W. and Sutton, A. J. Graphical augmentations to the funnel plot assess the impact of additional evidence on a meta-analysis. {it:J. Clin. Epidemiology} 2012;65(5):511-9. {p_end}

{phang}Palmer, T. M., J. L. Peters, A. J. Sutton, and S. G. Moreno. Contour enhanced funnel plots for meta-analysis. {it:Stata Journal} 2008; 8: 242-254.{p_end}

{phang}Peters, J. L., A. J. Sutton, D. R. Jones, K. R. Abrams, and L. Rushton. Contour-enhanced meta-analysis funnel plots help distinguish publication bias from other causes of asymmetry. {it:Journal of Clinical Epidemiology} 2008; 61: 991-996. {p_end}

{phang}Sutton AJ, Cooper NJ, Jones DR, Lambert PC, Thompson JR, Abrams KR. Evidence-based sample size calculations based upon meta-analysis. {it:Statistics in Medicine} 2007; 26:2479-2500. {p_end}

{phang}Sutton AJ, Donegan S, Takwoingi Y, Garner P, Gamble C, Donald A. An encouraging assessment of methods to inform priorities for updating systematic reviews. {it:J. Clin. Epidemiol.} 2009; 62: 241–251. {p_end}

{phang}Sterne, J. A. C., and R. M. Harbord. Funnel plots in meta-analysis. {it:Stata Journal} 2004; 4: 127-141. {p_end}


{title:Also see}

{psee}
Online:  {helpb metan} (if installed)
{p_end}
