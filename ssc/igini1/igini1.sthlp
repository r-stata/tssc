{smcl}
{* 24 July 2019}{...}
{hline}
help for {hi:igini1}{right:Tim F. Liao (July 2019)}
{hline}

{title:Gini index decomposition by individual and group}

{title:Syntax}

	{cmd:igini1} {it:varname} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
	[, {cmdab:by:g}{cmd:(}{it:groupvar}{cmd:)} ]

{p 4 4 2} {cmd:fweight}s and {cmd:aweight}s are allowed; see help {help weight}.

{title:Description}
{phang}

{p 4 4 2} 
{cmd:igini1} computes a refined Gini inequality index decomposition by decomposing the overall index into individual contributions to the Gini and further into the between-group and within-group components for each individual case. In addition to the main outcome variable, the by-group is typically required. Sampling weight is optional, and can be included as an {cmd:aweight}. The program {cmd:igini1} generates a new dataset of the same size as the input data, containing six variable: an id variable bearing the case number ordered in the same sequence as the original data, a group variable that records the group membership number, the iGini individual contributions to the Gini index, the iGini between-group component, the iGini within-group component, and a quantile variable reflecting the membership in either the lower or the upper half of the outcome variable distribution within each level of the group variable. The last quantile variable can be useful when used jointly with iGini components.

{title:Techical Details}
{phang}

{p 4 4 2} 
{cmd:igini1} computes a refined Gini inequality index. The relation between an individual iGini {it:g}_{it:i} component and the overall Gini idex {it:G} is

{p 4 4 2} 
{it:G} = {it:g}_1 + {it:g}_2 + ... + {it:g}_{it:N}

{p 4 4 2}
The relation between an individual iGini {it:g}_{it:i} component and its between and within subcomponents {it:g}_{it:ib} and {it:g}_{it:iw} is

{p 4 4 2}
{it:g}_{it:i} = {it:g}_{it:ib} + {it:g}_{it:iw}

{p 4 4 2}
{it:groupvar} must take on only positive integer values greater than 0 such as 1, 2, ..., G. 
To create such a variable from an existing variable, use the {help egen} function {cmd:group}. 
By default, observations with missing values on {it:groupvar} are excluded from calculations.

{p 4 4 2} 
{cmd:igini1} is computation-intensive. To surpass the upper limit of the number of cases in Stata, the ado uses Stata's Mata, and can handle as many cases as your system allows. Thus, computation time can be long if you have more than ten thousand cases. To speed up, you may consider using {cmd: Stata MP} or the ado {cmd:parallel}.

{title:Options}
{phang}

There is only one "{it:option}" implemented in the current version of {cmd:igini1}. It is required to run {cmd:igini1}.

{cmdab:by:g} {it:groupvar} requests iGini decomposition by social groups, with group membership specified by {it:groupvar}.


{title:Resulting data} 
{phang}

The iGini decomposition produces the following variables replacing the original
dataset: {it:ID}, {it:Group}, {it:iGini}, {it:iGinib}, and {it:iGiniw}, in that order.


{title:Saved results} 
{phang}

The saved internal results include the following:

{dlgtab:Scalars}
{phang}

    r(Gini)			The overall Gini index

    r(Gini_between)		between-group component of iGini

    r(Gini_within)		within-group component of iGini


{title:Computing iGini only} 
{phang}

In the rare instance, you may not have a reasonable grouping variable to use but still want compute iGini. In that event, you may generate a vector of 1s by {cmd:gen one=1} and use the constant {it:one} as the grouping variable. The program will simply slpit the sample into two groups, with the first half of the data get assigned a value of "1" and the second, a value of "2."


{title:Examples}


{p 4 8 2}{cmd:. igini1 y, by(Sex)}

{p 4 8 2}{cmd:. igini1 y [aw = weight], by(Race)}

{p 4 8 2}{cmd:. igini1 inc [aw = weight], byg(SexRace)}

{phang}
{it: For computing igini1 only without group-based decomposition}:

{p 4 8 2}{cmd:. gen one = 1}

{p 4 8 2}{cmd:. igini1 outcome [aw = weight], by(one)}


{title: Examples Using the Auto Dataset}


{p 4 8 2}{cmd:. use auto}

{p 4 8 2}{cmd:. gen origin = foreign + 1}

{p 4 8 2}{cmd:. igini1 mpg, by(origin)}


{title:Author}

{p 4 4 2}Tim F. Liao <tfliao@illinois.edu>{break}
Center for Advanced Studies in the Behaviorial Sciences & University of Illinois at Urbana-Champaign

{title:Acknowledgements}

{p 4 4 2}The author acknowledges the 2017-2018 fellowship support by the Center for Advanced Studies in the Behaviorial Sciences. Comments and suggestions will be welcome for debugging and updating {cmd:igini1}.


{title:References}

{p 4 8 2} 
Tim F. Liao. Forthcoming. 
"Individual Components of Three Inequality Measures for Analyzing Shapes of Inequality." 
{it:Sociological Methods & Research}
 : in press.