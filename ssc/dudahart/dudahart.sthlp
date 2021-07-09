{smcl}
{* Copyright 2016 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16Jun2016}{...}
{cmd:help dudahart}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{hi:dudahart} {hline 2}}Duda-Hart cluster stopping index from distance matrix{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:dudahart} , DISTmat(string) IDvar(varname) [NGroups(integer 15) NAME(clname) GRaph *]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt:{opt dist:mat(matname)}} names the distance matrix{p_end}
{synopt:{opt id:var(varname)}} identifies the variable that links the sort-order of the distance matrix to the sort-order of the data{p_end}
{syntab:Optional}
{synopt:{opt ng:roups}} The number of cluster solutions to test (default 15){p_end}
{synopt:{opt name}} Name of cluster analysis to use{p_end}
{synopt:{opt gr:aph}} If "both" plot the DH index and T-squared against cluster size, if "dh" the index only, if "dht" the T-squared only.{p_end}
{synopt:{it:twoway_options}}options allowed with {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:dudahart} calculates the Duda-Hart index for
stopping rules in cluster analysis, from the pairwise distance matrix.
This is widely used to determine the optimum number of clusters. Stata's
default {helpb cluster stop} does the same calculation on the basis of the
original variables, but cannot operate on the distance matrix.
{cmd:dudahart} is thus useful when the original variables are not
available, or when the distances are created other than as squared
Euclidean distances between variables (as is the case for instance with
sequence analysis). {p_end}

{pstd} {bf:NB:} Stata's built-in{cmd:clustermat stop, variables(...)
rule(duda)} does {it:not} estimate the DH index on the distance matrix
used by {cmd:clustermat}. Rather, it creates a new temporary distance
matrix based on the variables listed in the {cmd:variables()} option.
{p_end}

{pstd}Returns:{p_end}
      
{phang}r(duda_#)           Duda-Hart Je(2)/Je(1) value for # groups{p_end}
{phang}r(dudat2_#)         Duda-Hart pseudo-T-squared value for # groups{p_end}


{title:Remarks}

{pstd}While {cmd:cluster stop, rule(duda)} and {cmd:clustermat stop,
variables(...) rule(duda)} estimate the Duda-Hart index from the
original variables of the cluster solution, and are therefore explicitly
rooted in a squared-Euclidean distance point of view, {cmd:dudahart}
takes the distances as they are found. If they are squared distances
based on the original variables, the results will be identical to
{cmd:cluster stop}. If they are squared Euclidean distances from another
source, the interpretation will be the same. If there are other sorts of
differences (e.g., non-Euclidean) the interpretation is not necessarily
the same, but can be understood to be analogous, in the same way as the
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

{phang}{cmd:. dudahart, dist(distances) id(id) graph(dht)}{p_end}

{title:See Also}

{phang}{help cluster stop}{p_end}
{phang}{help silhouette}{p_end}
{phang}{help SADI}{p_end}
