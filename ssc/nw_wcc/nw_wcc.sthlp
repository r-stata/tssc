{smcl}
{* *! version 1.0.0 15Feb2017}{...}

{title:Title}

{p2colset 9 18 22 2}{...}
{p2col :nw_wcc {hline 2} Calculates Weighted Clustering Coefficients (WCC) in Complex Direct Networks following Fagiolo, Phys. Rev. E (2007). }
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab: nw_wcc}
[{it:{help netname}}]
[{cmd:,}
{opt bin:ary}
{opt n:ormalize()}
{opt cyc:le}
{opt mid:dleman}
{opt i:n}
{opt o:ut}
{opt a:ll}
]



{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt bin:ary}} Computes Binary (non weighted) network's clustering coefficient. Otherwise, weighted clustering coefficients are computed by default.

{synopt:{opt n:ormalize()}} Normalizes edges weights in the range [0,1] to make clustering coefficients scale-invariant. Only {it:max} (default) or {it:sum} arguments are accepted.

{synopt:{opt cyc:le}} Cycle pattern ((A A A)_{ii}).  

{synopt:{opt mid:dleman}} Middleman pattern ((A A' A)_{ii}).  
 
{synopt:{opt i:n}} Inward pattern  ((A' A A)_{ii}).

{synopt:{opt o:ut}} Outward pattern ((A A A')_{ii}).

{synopt:{opt a:ll}} All(D) pattern, default   (((A + A')^3_{ii})/2) .  



{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:nw_wcc} calculates the clustering coefficient of each node {it:i} among a {help netname:network}, following the pattern indicated in option and
saves the result as a Stata variable specific to the pattern and the binary or weighted dimension. At least one pattern should be indicated, if not, the pattern {it:all} is the default.


{pstd}
By default, weights are not normalized as in Fagiolo, Phys. Rev. E (2007), because they are assumed to be in the range [0,1]. 
Without the normalized option, the clustering coefficients are not scale invariant.
The {it:normalize} option rescale all weights into a [0;1] range, and makes the clustering coefficient scale invariant. 
The default normalization procedure (also accessible by typing {it:normalized(max)}) divides all weights {it:(w)} by {it:max(w)} (See discussion in Saramaki et al. (2007)). 
Option {it:normalize(sum)} normalizes {it:(w)} by {it:Sum(w)}, where {it:Sum(w)} is the sum of all the network weights.


{pstd}
{cmd:nw_wcc} Also returns Overall and Average clustering coefficients, stored in local variables 


{title: saved results}
{pstd}
{cmd:nw_wcc} saves the following results in {cmd:r()}

{pstd}
Scalars

{pstd}
 {cmd:r(overall_wcc)}  overall clustering coefficient 
 
 {cmd:r(avg_wcc)}      Average clustering coefficient


 
 {title:Examples}
Middleman graph
{cmd:. mata M=(0,10,5\0,0,0\0,10,0)}
{cmd:. nwset , mat(M)}

{cmd:. nw_wcc, binary  in}
{cmd:. nw_wcc, binary  out}
{cmd:. nw_wcc, binary  mid}
{cmd:. nw_wcc, binary all}

{cmd:. nw_wcc,  n in}
{cmd:. nw_wcc,  n out}
{cmd:. nw_wcc,  n mid}
{cmd:. nw_wcc,  n all}

Cycle graph
{cmd:. mata C=(0,0,0.2\0.2,0,0\0,0.2,0)}
{cmd:. nwset , mat(C)}

{cmd:. nw_wcc,  cyc}
{cmd:. nw_wcc,  all}

{cmd:. nw_wcc,  n(sum) cyc}
{cmd:. nw_wcc,  n(sum) all}



{title:See also}
{pstd}
{search nwcluster:nwcluster} (SSC) computes another clustering coefficient for weighted networks, following Onnela et al(2005, Phys. Rev. E). The main differences is that for directed networks, {search nwcluster:nwcluster} (Onnela's index) either only focus on inward or outward edges; while {search nw_wcc:nw_wcc} (Fagiolo's index) identify different clustering patterns based on both inward and outward edges.

{pstd}
{cmd:nw_wcc}  requires the {bf : nwcommands} package developed by Thomas Grund.

{pstd}

For do-files and ancillary files, see:

	{cmd:. net describe nwcommands-ado, from(http://www.nwcommands.org)}
	
For help files, see :

	{cmd:. net describe nwcommands-hlp, from(http://www.nwcommands.org)}
}}


{title:Author}
Charlie Joyez, Paris-Dauphine University
charlie.joyez@dauphine.fr
	

{title : References}
{pstd}
Fagiolo, G. (2007). Clustering in complex directed networks. Physical Review E, 76(2), 026107

{pstd}
Saramäki, J., Kivelä, M., Onnela, J. P., Kaski, K., & Kertesz, J. (2007). Generalizations of the clustering coefficient to weighted complex networks. Physical Review E, 75(2), 027105.

{pstd}
Onnela, J. P., Saramäki, J., Kertész, J., & Kaski, K. (2005). Intensity and coherence of motifs in weighted complex networks. Physical Review E, 71(6), 065103.


{title:Note}
Developed with the kind approval and advice from G. Fagiolo, I remain of course the only responsible of any mistakes in the code.
