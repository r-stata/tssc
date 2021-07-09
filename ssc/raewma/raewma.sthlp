{smcl}
{* *!1.0.0  Brent Mcsharry brent@focused-light.net 14Jan2014}{...}
{cmd:help rasprt}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:raewma} {hline 2}}Plot a Risk adjusted exponentially weighted moving average chart{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:rasprt}
{outcomevar sequencevar}
{ifin}
, {Predicted(varname)}
{STartest}
[{it:options}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt:{opt SMooth(#)}} The smoothing parameter (denoted by lambda). Default 0.01 {p_end}
{synopt:{opt Alpha1(#)}} First threshold line. Default 0.05 {p_end}
{synopt:{opt Alpha2(#)}} Second threshold line. Default 0.01 {p_end}
{synopt:{opt XLABEL(rule_or_values)}} major ticks plus labels{p_end}
{synopt:{opt YTITLE(axis_title)}} see {help axis_title_options}{p_end}
{synopt:{opt YLABEL(rule_or_values)}} major ticks plus labels. see {help axis_label_options}{p_end}
{synopt:{opt LEGEND([contents] [location])}} see {help legend_option}{p_end}
{synopt:{opt RESolution(#)}} The point at which the exponential weighting is rounded down to 0. Default 0.0000125 {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:raewma} plots a smothed, risk adjusted eqponentially weighted moving average over sequential records.
{p_end}

{pstd}
{cmd:outcomevar} The actual outcome being benchmarked. Must be binary.
{p_end}
{pstd}
{cmd:sequencevar} A variable denoting in what order each subject has entered the analysis.
{p_end}
{pstd}
{cmd:Predicted} The predicted value for the outcome under investigation.
{p_end}
{pstd}
{cmd:STartest} The y value to begin the plot - A guess at the (unadjusted) proportion of outcomes expected, seen previously or seen elsewhere. See {it:examples}.
{p_end}

{dlgtab:Main}

{title:Options}

{phang}
{opt SMooth} The smoothing parameter. Cook, Duke and Hart suggest: "Our experience with RA monitoring in intensive care is that a choice of [a smoothing parameter] between 0.005 and 0.020 is needed so the distributions of the observed and predicted EWMA plots are comparable"[1].
{p_end}

{phang}
{opt RESolution}
This should rarely need to be changed.
Older observations receive exponentially less weight. In order to minimise computational expense in larger data sets, much earlier observations have a weighting of 0 applied. 
The value entered assumes a constant predicted outcome for each case, and represents the inverse of the total number of pixels or dots required to create a noticable deflection. 
For instance, the default value of 0.0000125 has been chosen as this is roughly the resolution of 1 dot on a 2400 DPI printer at A1 size (33.1 inches high in landscape).
Assign a value of 0 to calculate the exponential weighting for all values in the dataset.
{p_end}

{title:Authors}

{p 4 4 2}Brent McSharry, Starship Children's Hospital, Auckland New Zealand -
brentm@adhb.govt.nz
{p_end}

{title:Examples}
{hline}
{pstd}Setup{p_end}
{phang2}. {stata webuse cancer}{p_end}
{phang2}. {stata gen int study_entry_sequence=_n}{p_end}
{phang2} assuming co-efficients from a (fictional) validated benchmarking model - intercept -3.6, age 0.12 per year, coeficient for drug2 -3.5 and drug 3 -3.2 {p_end}
{phang2}. {stata gen double predicted_death=invlogit(-3.6+ 0.12*age -3.5*(drug==2) -3.2*(drug==3))}{p_end}
{phang2} Creating another fictional benchmarking model - in this case more outcomes are occuring than would be predicted {p_end}
{phang2}. {stata gen double xs_pred_death=invlogit(-5.6+ 0.12*age -5*(drug==2) -3.2*(drug==3))}{p_end}
{pstd}Plot{p_end}
{phang2} {it:note}: Assuming that the published unadjusted mortality for a person with a cancer of this type is around 35%
{p_end}
{phang2}. {stata raewma died study_entry_sequence, pr(predicted_death) start(0.35)}{p_end}
{phang2}. {stata raewma died study_entry_sequence, pr(xs_pred_death) start(0.35)}{p_end}

{hline}
{title:Also see}
{psee} [1] Aticle: {it:BMJ Qual Saf} 2011 20: 469-474 
{browse "http://qualitysafety.bmj.com/content/20/6/469.full.pdf+html":Exponentially weighted moving average charts to compare observed and expected values for monitoring risk-adjusted hospital indicators}
{p_end}
{psee} [2] Aticle: {it:Critical Care and Resuscitation} 2008; Volume 10, Number 3: pp. 239-251 
{browse "http://cicm.org.au/journal/2008/september/ccr_10_3_010908_239_Cook.pdf":Review of the application of risk-adjusted charts to analyse mortality outcomes in critical care}{p_end}
