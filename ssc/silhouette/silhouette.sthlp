{smcl}
{* Copyright 2016 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16Jun2016}{...}
{cmd:help silhouette}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{hi:silhouette} {hline 2}}Silhouette width for cluster analysis, from distance matrices{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:silhouette} {it:varname} , DISTmat(string) IDvar(varname) [SILH(varname) *]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt:{opt dist:mat(matname)}} names the distance matrix{p_end}
{synopt:{opt id:var(varname)}} identifies the variable that links the sort-order of the distance matrix to the sort-order of the data{p_end}
{syntab:Optional}
{synopt:{opt silh(varname)}} a variable to which to save the silhouette widths{p_end}
{synopt:{it:twoway_options}} options allowed with {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:silhouette} calculates and graphs the silhouette width for
the cluster solution given by the grouping variable, using the pairwise
distance matrix given in the {it:distmat} option. {p_end}

{title:Remarks}


{pstd}Silhouette width is an indicator of cluster adequacy. It compares
for each case, the mean distance to other cases in the cluster in which
the case is, and the mean distance to the nearest neighbour
cluster. Silhouette widths less than zero indicate a case that fits poorly in its cluster. {p_end}

{pstd}The distance matrix can be generated from variables using the {cmd:matrix dissimilarity} command (see example).
However, if you have a pairwise distance matrix created otherwise (e.g., using sequence analysis) you can use that directly.
{p_end}

{pstd}Because the order of the data and the order of the distance matrix
must coincide, the dataset must be sorted by {opt id:var}. It is the
user's responsibility that this variable defines the correct order.{p_end}

{title:References}

{pstd}{browse "https://en.wikipedia.org/wiki/Silhouette_%28clustering%29":Wikipedia on "Silhouette_(clustering)"} {p_end}
{pstd}Peter J. Rousseeuw (1987). "Silhouettes: a Graphical Aid to the Interpretation and Validation of Cluster Analysis". Computational and Applied Mathematics 20: 53–65. doi:10.1016/0377-0427(87)90125-7. {p_end}

{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{pstd}Using NLSW88, clustering on variables:{p_end}

{phang}{cmd:. sysuse nlsw88}{p_end}
{phang}{cmd:. sort idcode}{p_end}
{phang}{cmd:. cluster wards ttl age wage}{p_end}
{phang}{cmd:. cluster gen g4=groups(4)}{p_end}
{phang}{cmd:. set matsize 3000}{p_end}
{phang}{cmd:. matrix dissim dist = ttl age wage, L2squared}{p_end}
{phang}{cmd:. silhouette g4, dist(dist) id(idcode)}{p_end}

{pstd}Using {help SADI} to generate a matrix of inter-sequence distances (an example of a non-standard way of generating distance matrices): {p_end}

{phang}{cmd:. sort id}{p_end}
{phang}{cmd:. oma m1-m40, subs(sm) indel(1.5) len(40) pwd(om1)}{p_end}
{phang}{cmd:. clustermat wards om1, add}{p_end}
{phang}{cmd:. cluster gen g8=groups(8)}{p_end}
{phang}{cmd:. silhouette g8, dist(om1) id(id)}{p_end}

{title:See Also}

{phang}{help cluster stop}{p_end}
{phang}{help calinski}{p_end}
{phang}{help dudahart}{p_end}
{phang}{help SADI}{p_end}
