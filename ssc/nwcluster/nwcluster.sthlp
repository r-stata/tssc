{smcl}
{* *! version 1.0.0 22avr2016}{...}

{title:Title}

{p2colset 9 18 22 2}{...}
{p2col :nwcluster {hline 2} Calculates the clustering coefficient of a network's vertices following Onnela et al(2005, Phys. Rev. E) index for weigthed networks.}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab: nwcluster}
[{it:{help netname}}]
[{cmd:,}
{opt valued}
{opt direction()}
]



{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt val:ued}} Weighted clustering coefficient is calculated in addition to binary clustering coefficient 

{synopt:{opt dir:ection()}} Indicate {it:inward} or {it:outward} (default) degree direction for directed networks.


{synoptline}
{p2colreset}{...}



{title:Description}

{pstd}
Calculates the clustering coefficient of each nodes {it:i} in a {help netname:network} and
saves the result as a Stata variable {it : _clustering}. 

{pstd}
For weighted networks, if {bf:valued} option is specified, the weighted clustering coefficient {it:_wclustering} is calculated in addition.

{pstd}
For directed networks, the {it:inward} or {it:outward} direction should be specified in option {cmd: direction()}. If neither of them is specified, the outward direction is assumed by default.

{pstd}
The local clustering coefficient of a node {it:i} is defined as the share of network neighbors {it:N_i(g)} of {it:i} who are directly connected among themselves.
The weighted generalization corresponds to the one proposed by Onnela et al(2005, Phys. Rev. E).

{pstd}
{cmd:nwcluster} also returns the average clustering coefficient


{title:Examples}
	{cmd:. webnwuse glasgow, nwclear}
	{cmd:. nwcluster glasgow3, direction(outward)}
		
	{cmd:. webnwuse gang, nwclear}
	{cmd:. nwcluster gang_valued , valued}

{title:Saved results}
{pstd}{cmd:nwcluster} saves the following in {cmd:r()}:

{synoptset 14 tabbed}{...}
{p2col 5 20 30 2: Scalars}{p_end}
{synopt:{cmd:r(overall_cc)}} overall clustering coefficient {p_end}
{synopt:{cmd:r(avg_cc)}} average clustering coefficient {p_end}
{p2colreset}{...}

{pstd}{cmd:nwcluster, valued} saves the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 20 30 2: Scalars}{p_end}
{synopt:{cmd:r(overall_cc)}} overall clustering coefficient {p_end}
{synopt:{cmd:r(avg_cc)}} average clustering coefficient {p_end}
{synopt:{cmd:r(overall_wcc)}} weighted overall clustering coefficient {p_end}
{synopt:{cmd:r(avg_wcc)}} average overall clustering coefficient {p_end}
{p2colreset}{...}
	
	
{title:See also}
{pstd}
{search nw_wcc:nw_wcc} (SSC) computes another clustering coefficient for weighted networks, following Fagiolo (2007, Phys. Rev. E). The main differences is that for directed networks, {search nwcluster:nwcluster} (Onnela's index) either only focus on inward or outward edges; while {search nw_wcc:nw_wcc} (Fagiolo's index) identify different clustering patterns based on both inward and outward edges.


{pstd}
{cmd:nwcluster}  requires the {bf : nwcommands} package developed by Thomas Grund.

{pstd}

For do-files and ancillary files, see:

	{cmd:. net describe nwcommands-ado, from(http://www.nwcommands.org)}
	
For help files, see :

	{cmd:. net describe nwcommands-hlp, from(http://www.nwcommands.org)}

{title:Author}
Charlie Joyez, Paris-Dauphine University
charlie.joyez@dauphine.fr
	
	
{title: references}
Onnela, J. P., Saramäki, J., Kertész, J., & Kaski, K. (2005). Intensity and coherence of motifs in weighted complex networks. Physical Review E, 71(6), 065103.

Fagiolo, G. (2007). Clustering in complex directed networks. Physical Review E, 76(2), 026107
