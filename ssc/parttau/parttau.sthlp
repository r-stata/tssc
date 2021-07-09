{smcl}
{* *! version 1.0.1 01feb2010}{...}
{cmd:help parttau}
{hline}

{title:Title}

{phang}
{bf:parttau} {hline 2} Calculate Kendall's partial tau and confidence interval.


{title:Syntax}
{p 8 17 2}
{cmdab:parttau}
{varlist}
{ifin}
[{cmd:,}
{it:options}]

{pstd}
When {it:varlist} contains three or more variables, the first two are the primary variables, and all others confounders.
	When {it:varlist} contains two variables, the pairwise tau is calculated.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth c:luster(varname)}}treat data set as samples of clusters{p_end}
{synopt:{opt wcluster}}calculate the within-cluster partial and pairwise taus{p_end}
{synopt:{opth est:imate(varname)}}save jackknife estimates in given variable name{p_end}
{synopt:{opth trans:form(string)}}report the tau, SE, and confidence interval 
			in a transformed space; transformations are same as for {help somersd}; see below{p_end}
{synopt:{opt l:evel(#)}}specifies percent coverage for confidence interval{p_end}
{synopt:{opt run2}}forces calculation of pairwise tau when no confounder is given; see below{p_end}
{synopt:{opt show}}displays all pairwise taus between all given variables{p_end}
{synoptline}
{p2colreset}{...}


{title:Options}
{dlgtab:Main}

{phang}
{opt cluster(varname)} instructs the program that the data set should be treated as samples of clusters from a 
	population of clusters, and that the given variable specifies the clusters.  If {cmd:cluster} is specified 
	and the option {cmd:wcluster} is not specified, then the partial tau is calculated 	between clusters.

{phang}
{opt estimate(varname)} specifies that the jackknife estimates should be saved in variable {it:varname}.  If the 
	variable exists prior to calling this option, the variable is overwritten and a warning message given.  Otherwise
	a variable with the given name is created.

{phang}
{opt transform(name)} changes the ouput estimate, SE, and confidence interval to a transformed space. If specified, the
	confidence interval will be symmetric in the transformed space.   Allowed transformations are same as for {help somersd}: 
	{cmd: z}, {cmd:asin}, {cmd:rho}, {cmd:zrho}, {cmd:c}, though fewer aliases are allowed.  If calculating a partial 
	tau (i.e., using one or more confounder variables), and option {cmd:show} is specified, reported pairwise taus will 
	not be transformed.

{phang}
{opt level(#)} specifies the percent coverage of the confidence interval.

{phang}
{opt run2} forces calculation of pairwise tau.  {cmd:parttau} is primarily intended for calculating Kendall's partial tau between
	two variables with one or more confounders.  Thus, typically, three or more variables will be specified.  If two variables
	are specified, {cmd:parttau} will assume that the user wants to calculate the pairwise tau and will attempt to use {cmd:somersd}.
	If that program is not found, {cmd:parttau} will calculate the pairwise tau itself.  Using {cmd:run2} forces {cmd:parttau} to 
	calculate the pairwise tau; if {cmd:somersd} is installed, both will be used.
	
{phang}
{opt show} displays all pairwise taus between all given variables.  The pairwise taus are also saved in the matrix {bf:e(taus)}.

{title:Description}

{pstd}
{cmd:parttau} calculates Kendall's partial tau and confidence interval.  {cmd:parttau} can be used to calculate {it:pairwise} taus if 
	{help somersd} is not installed, or if the option {cmd:run2} is specified.  For repeated calculation of the pairwise
	tau, the user will probably find {cmd:somersd} preferable; it is faster and has more options.

{title:Authors}

{pstd}
James Fiedler, Universities Space Research Association{break}
Email: {browse "mailto:james.fiedler-1@nasa.gov":james.fiedler-1@nasa.gov}

{pstd}
Alan H. Feiveson, National Aeronautics and Space Administration{break}
Email: {browse "mailto:alan.h.feiveson@nasa.gov":alan.h.feiveson@nasa.gov}
