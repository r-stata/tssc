{smcl}
{* *! version 1.0.2; February 09, 2013;  DE}{...}
{hi:help rel_clust}
{hline}

{title:Title}

{p 4 18 2}
{hi:rel_clust} -- relative clusterability and weighted variables for cluster analysis

{title:Syntax}

{phang}
   {cmd: rel_clust {varlist} {ifin} [, {it:options}]}

{p 8 15 2}

{synoptset 17 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}{p2colset 7 24 24 2}
{p2col:{opt su:ffix(suffix)}}generation of transformed variables of {it:varlist} adding {it:suffix} to
         their variable names (default transformation is {hi:vr_ratio}){p_end}
{p2col:{opt tr:ansf(arg)}}type of variable transformation (requires option {opt su:ffix}){p_end}
{p2col:{opt norc}}no output of "relative clusterability" indices{p_end}
{p2col:{opt replace}}replace existing variables requested by {opt su:ffix}{p_end}

{syntab:Sub ({it:arguments} of {opt tr:ansf})}
{synopt:{opt vr:_ratio}}variance-to-range ratio weighting (see Steinley & Brusco, 2008, p. 83f.) (default when using option {opt su:ffix}){p_end}
{synopt:{opt ra:nge}}range transformation [xij/range(xj)]{p_end}
{synopt:{opt z:_score}}z-score transformation [xij-(mean(xj))/sd(xj)]{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd} {cmd:rel_clust} computes indices of relative clusterability of {it:varlist} according
to Steinley and Brusco (2008) and optionally generates transformed or weighted variables for
use in {help cluster} analysis.

{pstd} {cmd:rel_clust} can be used to transform the variables of {it:varlist} by {it:z}-standardization, by
standardization by range, or by variance-to-range (VR) ratio weighting. The VR ratio weighting procedure
was designed specifically for cluster analysis: It reflects the degree of "clusterability" of the set of
variables used. According to Steinley and Brusco (2008), VR ratio weighting of variables together with their
proposed variable selection procedure clearly increases the ability of K-means cluster analysis to
accurately recover the true cluster structure.

{title:Options}

{dlgtab:Main}

{phang}
{opt su:ffix(suffix)} requests the generation of transformed variables. The names of the
new variables will be the original variable names with {it:suffix} added. Transformation to
variance-to-range ratio weighted variables is the default.

{phang}
{opt tr:ansf(arg)} specifies the type of transformation (only necessary if other than
variance-to-range ratio weighting is requested). Three transformations are possible
according to {hi:{it:arg}} (see below).

{phang}
{opt norc} requests not to show the table of "relative clusterability" per variable
in the results window.

{phang}
{opt replace} requests that the variables specified by using option {opt su:ffix} will
replace already existing variables.

{dlgtab:Sub (option transf)}

{phang}
{opt vr:_ratio} requests a transformation by variance-to-range ratio weighting of the original
variables (see Steinley & Brusco, 2008, p. 83f.) (default when using option {opt su:ffix}).

{phang}
{opt ra:nge} requests a range transformation [xij/range(xj)] of the original variables.

{phang}
{opt z:_score} requests a z-score transformation [xij-(mean(xj))/sd(xj)] of the original variables.


{title:Example}

{pstd}
The following commands replicate the results shown in Steinley & Brusco (2008) - as to
the "relative clusterability" indices see Table 7, p. 102 (x1 to x4), as to the variance
and range of the original and transformed variables see Table 6, p. 99:

{phang}. {stata webuse iris}{p_end}
{phang}. {stata tabstat seplen-petwid, s(v r) f(%5.2f)}{p_end}
{phang}. {stata rel_clust seplen-petwid, tr(z) su(_z1)}{p_end}
{phang}. {stata tabstat *z1, s(v r) f(%5.2f)}{p_end}
{phang}. {stata rel_clust seplen-petwid, tr(ra) su(_z2) norc}{p_end}
{phang}. {stata tabstat *z2, s(v r) f(%5.2f)}{p_end}
{phang}. {stata rel_clust seplen-petwid, su(_z3) norc}{p_end}
{phang}. {stata tabstat *z3, s(v r) f(%5.2f)}{p_end}


{title:Saved Results}

{pstd} {cmd:rel_clust} saves the following in {cmd:r()}: {p_end}

{synoptset 12 tabbed}{...}
{p2col 5 12 16 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of valid cases (listwise){p_end}

{synoptset 12 tabbed}{...}
{p2col 5 12 16 2: Macros}{p_end}
{synopt:{cmd:r(trans)}}type of transformation used (if requested by option {opt su:ffix}){p_end}
{synopt:{cmd:r(vars)}}list of variables used{p_end}

{synoptset 12 tabbed}{...}
{p2col 5 12 16 2: Matrices}{p_end}
{synopt:{cmd:r(RC)}}matrix of relative clusterability index per variable{p_end}


{title:References}

{phang}Steinley, D. & Brusco, M. J. (2008). {browse "http://www.tandfonline.com/doi/abs/10.1080/00273170701836695":A new variable weighting and selection procedure for K-means cluster analysis}. {it:Multivariate Behavioral Research},
 {it:43}, 77-108.{p_end}

{title:Also see}

{psee}
Help: {help cluster kmeans}{p_end}

{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
