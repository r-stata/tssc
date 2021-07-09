{smcl}
{* Copyright 2016 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16Jun2016}{...}
{cmd:help calinski}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{hi:calinski} {hline 2}}Calinski-Harabasz cluster stopping index from distance matrix{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:calinski} , DISTmat(string) IDvar(varname) [NGroups(integer 15) NAME(clname) GRaph *]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt:{opt dist:mat(matname)}} names the distance matrix{p_end}
{synopt:{opt id:var(varname)}} identifies the variable that links the sort-order of the distance matrix to the sort-order of the data{p_end}
{syntab:Optional}
{synopt:{opt ng:roups}} The number of cluster solutions to test (default 15){p_end}
{synopt:{opt name}} Name of cluster analysis to use{p_end}
{synopt:{opt gr:aph}} plot the index against cluster size{p_end}
{synopt:{it:twoway_options}}options allowed with {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:calinski} calculates the Calinski-Harabasz pseudo-F for
stopping rules in cluster analysis, from the pairwise distance matrix.
This is widely used to determine the optimum number of clusters. Stata's
default {helpb cluster stop} does the same calculation on the basis of the
original variables, but cannot operate on the distance matrix.
{cmd:calinski} is thus useful when the original variables are not
available, or when the distances are created other than as squared
Euclidean distances between variables (as is the case for instance with
sequence analysis). {p_end}

{pstd} {bf:NB:} Stata's built-in {cmd:clustermat stop, variables(...)}
does {it:not} estimate the CH pseudo-F on the distance matrix used by
{cmd:clustermat}. Rather, it creates a new temporary distance matrix
based on the variables listed in the {cmd:variables()} option. {p_end}

{pstd}{cmd:calinski} depends on {help discrepancy} which
can be installed from SSC:{p_end}

{phang}{cmd:. ssc install discrepancy}

{pstd}Returns:{p_end}
      
{phang}r(calinski_#)       Calinski-Harabasz pseudo-F for # groups{p_end}


{title:Remarks}

{pstd}While {cmd:cluster stop} and {cmd:clustermat stop} estimate the
CH pseudo-F by cumulating the sum of squares from ANOVAs of the original
variables on the cluster solution, and are therefore explicitly rooted in
a squared-Euclidean distance point of view, {cmd:calisnki} takes the
distances as they are found. If they are squared distances based on the
original variables, the results will be identical to {cmd:cluster stop}.
If they are squared Euclidean distances from another source, the
interpretation will be the same. If they are other sorts of differences
(e.g., non-Euclidean) the interpretation is not necessarily the same,
but can be understood to be analogous, in the same way as the
{cmd:discrepancy} partitioning of the distance matrix (described by
Studer et al 2011) is analogous to ANOVA.{p_end}

{pstd}Because the order of the data and the order of the distance matrix
must coincide, the dataset must be sorted by {opt id:var}. It is the
user's responsibility that this variable defines the correct order.{p_end}

{title:References}

{p 4 4 2} Milligan, G. W., and M. C. Cooper. 1985.  An examination of procedures for determining the number of clusters in a dataset. {it:Psychometrika} 50: 159-179. {p_end}
{p 4 4 2} M Studer, G Ritschard, A Gabadinho and NS Müller, Discrepancy analysis of state sequences, {it:Sociological Methods and Research}, 40(3):471-510 {p_end}


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. calinski, dist(distances) id(id) graph}{p_end}

{title:See Also}

{phang}{help cluster stop}{p_end}
{phang}{help dudahart}{p_end}
{phang}{help discrepancy}{p_end}
{phang}{help SADI}{p_end}
