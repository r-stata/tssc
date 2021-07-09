{smcl}
{cmd:help mtefeplot}{r})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{cmd:mtefeplot} {hline 2}}Plot MTE graphs from {cmd:mtefe} estimates{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 11 2}
{cmd:mtefeplot} [namelist] {cmd:,} [{it:options}]

{synoptset 25}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt cropfigure(numlist)}}crops the confidence bands at the min and max specified in {it:numlist}{p_end}
{synopt:{opt mem:ory}}specifies that the estimates be restored from memory rather than disk{p_end}
{synopt:{opt normalci}}uses normal-based confidence interval rather than percentile-based for bootstrapped estimates. {p_end}
{synopt:{opt folder(string)}}uses estimates saved in the subfolder {it:string}{p_end}
{synopt:{opt names(namelist)}}names the plots in the legend using the names in {it:namelist}{p_end}
{synopt:{opt graph_opts(string)}} add twoway options to the graph, see {helpb twoway_options}{p_end}
{synopt:{opt legendtitle(string)}}uses the title {it:string} for the legend{p_end}
{synopt:{opt level(#)}}plots a #% confidence interval. Default: 95%{p_end}
{synopt:{opt late}}plots the MTE for the compliers and the LATE weights{p_end}
{synopt:{opt att}}plots the MTE for the treated and the ATT weights{p_end}
{synopt:{opt atut}}plots the MTE for the untreated and the ATUT weights{p_end}
{synopt:{opt prte}}plots the MTE for the policy compliers and the PRTE weights{p_end}
{synopt:{opt mprte1}}plots the weights for the Marginal Policy Relevant Treatment Effect 1{p_end}
{synopt:{opt mprte2}}plots the weights for the Marginal Policy Relevant Treatment Effect 2{p_end}
{synopt:{opt mprte3}}plots the weights for the Marginal Policy Relevant Treatment Effect 3{p_end}
{synopt:{opt sep:arate}}plots the estimated outcomes separately for the treated and untreated state{p_end}
{synopt:{opt trims:upport}}only plots the MTE for unobserved resistance between the two values in trimsupport{p_end}
{synopt:{opt points}}use scatter rather than line plots for the MTE(s), useful when support is limited.{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mtefeplot} plots the marginal treatment effects from previously stored or 
saved estimates from {cmd:mtefe}.

{pstd}
If {it:namelist} is empty or contains one name and neither options {cmd:late}, 
{cmd:att}, {cmd:atut} or {cmd:prte} is specified, {cmd:mtefeplot} will plot a 
standard Marginal Treatment effects plot of the stored or saved estimate. If 
it contains estimates of the standard errors, confidence bands are included. 
Graph includes a plot of the average treatment effect for reference. If 
{it:namelist} is empty, estimates from memory is used.{p_end}

{pstd}
If {it:namelist} is empty or contains one name, {cmd:separate} is specified and 
no treatment parameter options are specified, {cmd:mtefeplot} will plot the 
outcomes in the treated and untreated state separately together with the MTE 
curve. Average treatment effect is plotted for reference.{p_end}

{pstd}
If {it:namelist} contains more than two names, {cmd:mtefeplot} plots several MTE
 plots in the same graphs with no confidence bands. {p_end}

{pstd}
If {it:namelist} is empty or contains one name, and either {cmd:late}, {cmd:att}
 ,{cmd:atut}, {cmd:prte}, {cmd:mprte1}, {cmd:mprte2} or {cmd:mprte3} is specified, 
 {cmd:mtefeplot} plots treatment parameter graphs. These contain a) the MTE for 
 the particular treatment effect requested, b) the estimated weights over the 
 U_d distribution for the requested treatment effect parameter and c) the point 
 estimate of the treatment effect labeled at the left axis. In addition, the main
 MTE graph and the average treatment effect is plotted for reference. If 
 {cmd:late} is specified, the regular 2SLS estimate is also dotted for reference.
 If {it:namelist} is empty, estimates from memory is used. More than two treatment
 effect parameters specified at the same time will clutter the figure, and is not
 recommended.{p_end}

{pstd}
More than two names in {it:namelist} and either treatment parameter option or 
the {cmd:separate} option gives an error.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Generate some data and estimate MTE{p_end}
{phang2}{cmd:. mtefe_gendata} {p_end}
{phang2}{cmd:. mtefe lwage exp exp2 (col=distCol)} {p_end}
{phang2}{cmd:. est sto normal} {p_end}
{phang2}{cmd:. mtefe lwage exp exp2 (col=distCol), separate pol(2)} {p_end}
{phang2}{cmd:. est sto polynomial} {p_end}
{phang2}{cmd:. est save myfolder/polynomial} {p_end}
{phang2}{cmd:. mtefe lwage exp exp2 (col=distCol), semiparametric gridponts(100)} {p_end}
{phang2}{cmd:. est sto semipar} {p_end}

{pstd}
Standard MTE plot of the estimate in memory{p_end}
{phang2}{cmd:. mtefeplot}{p_end}

{pstd}
Plots of three different saved MTE estimates in the same graph{p_end}
{phang2}{cmd:. mtefeplot normal polynomial semipar, memory legendtitle("Specification") names("Normal" "Polynomial" "Semiparametric")}{p_end}

{pstd}
Plot of the estimated local average treatment effect and weights{p_end}
{phang2}{cmd:. mtefeplot normal, mem late}{p_end}

{pstd}
Plot of the estimated ATT and ATUT with weights{p_end}
{phang2}{cmd:. mtefeplot polynomial, mem att atut}{p_end}

{pstd}
Plot of outcomes in the treated and untreated state of an estimate saved in "myfolder"{p_end}
{phang2}{cmd:. mtefeplot polynomial, folder(myfolder) separate}{p_end}

{marker Author}{...}
{title:Author}

{pstd}Martin Eckhoff Andresen{p_end}
{pstd}University of Oslo & Statistics Norway{p_end}
{pstd}Oslo, NO{p_end}
{pstd}martin.eckhoff.andresen@gmail.com{p_end}

{marker also_see}{...}
{title:Also see}
{p 7 14 2}  Main help file for {helpb mtefe}
