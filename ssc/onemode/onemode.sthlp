{smcl}
{* *! 17jun2014}{...}
{cmd:help onemode}
{hline}

{title:Title}

{phang}
{bf:onemode} {hline 2} Produce one-mode projections of a bipartite network


{title:Syntax}

{p 8 17 2}
{cmd:onemode}
{it:infilename}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Input/Output/Reporting}
{synopt:{opt row:id}}first column of {it:infilename} contains row ids{p_end}
{synopt:{opt col:umnid}}first row of {it:infilename} contains column ids{p_end}
{synopt:{opt trans:pose}}{it:infilename} contains agents in columns and artifacts in rows{p_end}
{synopt:{opt saveas(str)}}save output in {it:str}.csv{p_end}
{synopt:{opt prog:ress}}displays an approximate progress meter{p_end}

{syntab:Projection Methods}
{synopt:{opt method(str)}}specifies the projection method{p_end}
{synopt:{opt high:threshold(real)}}threshold for determining positive edges{p_end}
{synopt:{opt low:threshold(real)}}threshold for determining negative edges{p_end}
{synopt:{opt alpha(real)}}alpha-level used to determine edges' statistical significance{p_end}
{synopt:{opt reps(int)}}number of repetitions used in the SDSM method{p_end}
{synopt:{opt model(str)}}binary outcome model used in the SDSM method{p_end}
{synopt:{opt iterate(int)}}max iterations of the binary outcome model used in the SDSM method{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:onemode} constructs a one-mode projection of bipartite network data contained in {it:infilename}.
{it:infilename} must be a comma-delimited file in which cell Aij = 1 if agent {it:i} is linked to artifact {it:j}, and otherwise is 0.
Thus, agents are assumed to be arrayed as rows, and artifacts are arrayed as columns (use {opt transpose} is agents and artifacts are reversed).


{title:Options}

{dlgtab:Input/Output/Reporting}

{phang}
{opt rowid} specifies that the first column of {it:infilename} contains ids for the rows. These ids may be string or numeric.{p_end}

{phang}
{opt columnid} specifies that the first row of {it:infilename} contains ids for the columns. These ids may be string or numeric.{p_end}

{phang}
{opt transpose} specifies that agents are arrayed as columns, and artifacts are arrayed as rows in {it:infilename}. This command is useful if the number of artifacts exceeds the number of variables allowed by your version of Stata.{p_end}

{phang}
{opt saveas(str)} specifies that the one-mode projection, with agent ids (if present in {it:infilename}), be saved as {it:str}.csv in the working directory. If not specified, the projection will be saved as {it:method}.csv.{p_end}

{phang}
{opt progress} displays an approximate progress meter when using the more time-intensive {it:serrano} or {it:sdsm} projection methods.{p_end}

{dlgtab:Projection Methods}

{phang}
{opt method(standard | pearson | bonacich | nystuen | serrano | hyperg | sdsm)} specifies the method used to compute the one-mode projection (see below for details).
The default is {it:standard}.{p_end}

{phang}
{opt highthreshold(real)} and {opt lowthreshold(real)} automatically converts a valued one-mode projection into a binary or signed projection by applying a dichotimizing threshold to the edge weights,
when using the {it:standard} or {it:bonacich} projection methods.
If only {it:highthreshold} is specified, edges with weights above {it:highthreshold} are coded as 1 (present) and all others as 0 (absent).
If only {it:lowthreshold} is specified, edges with weights below {it:lowthreshold} are coded as -1 (negative) and all others as 0 (absent).
If both options are specified, edges with weights above {it:highthreshold} are coded as 1 (positive), edges with weights below {it:lowthreshold} are coded as -1 (negative), and all others are coded as 0 (absent).
If neither option is specified, raw edge weights are preserved in the output.{p_end}

{phang}
{opt alpha(real)} specifies the alpha-level used to assess the statistical significance of edge weights when using the {it:pearson}, {it:serrano}, {it:hyperg}, or {it:sdsm} projection methods.
The default is 0.05.{p_end}

{phang}
{opt reps(int)} specifies the number of monte-carlo repetitions used by the {it:sdsm} projection method.
The default is 1000.{p_end}

{phang}
{opt model(scobit | logit | probit | cloglog | optimal)} specifies the binary outcome model used by the {it:sdsm} projection method to generate random bipartite networks.
The default is {it:optimal}, which tests all four binary outcome models and selects the model which minimizes the root mean squared error (RMSE) between the observed and random bipartite network marginals.
However, this "optimization" approach requires extra time, and is based on only one test of each type of model, so should be used with caution.{p_end}

{phang}
{opt iterate(int)} specifies the maximum number of iterations performed by the binary outcome model used by the {it:sdsm} projection method; the default is 16,000.
In some cases, the binary outcome model will fail to converge and the program will stall.
However, model convergence is not often necessary to obtain reasonable probability estimates for the purposes of random bipartite network generation, and estimates obtained after just one iteration are often acceptable.
After the binary outcome model converges, or completes {it:int} iterations, two fit indices (R-squared and Root Mean Squared Error) are displayed. 
These indices compare the row/column degree sequences in the observed bipartite network and one random bipartite network.
Thus, they serve as a rough guide to how well the estimated probabilities generate an appropriate random bipartite network.{p_end}

{title:Brief Description of Projection Methods}

{pstd}
The seven projection methods available in {cmd:onemode} are reviewed in detail in:

{p 8 12 2}
Neal, Z. P. (2013). Identifying statistically significant edges in one-mode projections.
{it:Social Network Analysis and Mining, 3}, 915 Ð 924. ({browse "https://www.msu.edu/~zpneal/publications/neal-onemode.pdf":CLICK FOR PDF}){p_end}

{p 8 12 2}
Neal, Z. P. (In press). The backbone of bipartite networks: Inferring relationships from co-authorship, co-sponsorship, co-attendance and other co-behaviors.
{it:Social Networks}. ({browse "https://www.msu.edu/~zpneal/publications/neal-bipartite.pdf":CLICK FOR PDF}){p_end}

{pstd}
{cmd:standard} - Given a bipartite network A, the projection is defined as AA'.
Edge weights represent the number of artifacts shared by a pair of agents (e.g. the number of social events two people both attended, or the number of papers two people co-authored).
The {it:highthreshold} and {it:lowthreshold} options may be used with this method to obtain a binary or signed projection.

{pstd}
{cmd:pearson} - Projection edge weights are defined as the pearson correlation between a pair of actors' sets of artifacts.
When this method is used, the default is to output a signed network in which statistically significantly positive edge weights are coded 1 and statistically significantly negative edge weights are coded -1.
If the raw pearson correlations are desired instead, specify {it:alpha(0)}.

{pstd}
{cmd:bonacich} - Projection edge weights are defined using a normalization described by Bonacich, P. (1972). Technique for Analyzing Overlapping Memberships. {it:Sociological Methodology, 4}, 176-185.
The {it:highthreshold} and {it:lowthreshold} options may be used with this method to obtain a binary or signed projection.

{pstd}
{cmd:nystuen} - This method begins with a standard projection, but codes each agent's strongest edge as 1, and all others as 0, to obtain a (typically hierarchical) binary network.
This method was first described by Nystuen, J. D. & Dacey, M. F. (1961). A graph theory interpretation of nodal regions. {it: Papers and Proceedings of the Regional Science Association, 7}, 29-42.
It is sometimes also called Single Linkage Analysis.

{pstd}
{cmd:serrano} - This method begins with a standard projection, but then uses a statistical model to assess the significance of edge weights.
Edges deemed statistically significant at the specified {it:alpha} level are coded 1, and all others are coded 0.
The statistical model is described by Serrano, M. A., Boguna, M., & Vespignani, A. (2009). Extracting the multiscale backbone of complex weighted networks. {it:Proceedings of the National Academy of Sciences, 106}, 6483-6488.

{pstd}
{cmd:hyperg} - This method uses the hypergeometric distribution to assess the statistical significance of edge weights, conditioned on each agents' number of artifacts (i.e. row marginals in the bipartite network).
Edges deemed statistically significantly positive at the specified {it:alpha} level are coded 1, those deemed statistically significantly negative are coded -1, and all others are coded 0.

{pstd}
{cmd:sdsm} - The Stochastic Degree Sequence Model (SDSM) method uses a monte-carlo approach to assess the statistical significance of edge weights against a null model that is conditioned on each agents' number of artifacts 
{it:and} each artifact's number of agents (i.e. both row and column marginals in the bipartite network).
Edges deemed statistically significantly positive at the specified {it:alpha} level are coded 1, those deemed statistically significantly negative are coded -1, and all others are coded 0.
The {opt model} option specifies the binary outcome model used to generate random bipartite networks, while the {opt reps} option specifies the number of random bipartite networks that are generated and used to build the null model.

{title:Author}

Zachary Neal
Department of Psychology
Michigan State University
zpneal@msu.edu
