{smcl}
{* *! version 1.2.0 22apr206}{...}

{title:Title}

{p2colset 9 18 22 2}{...}
{p2col :nwdisparity {hline 2} Calculates the disparity of a network's nodes }
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab: nwdisparity}
[{it:{help netname}}]
[{cmd:,}
{opt direction()}
]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt dir:ection()}} Indicate {it:inward} or {it:outward} (default) direction for directed networks.


{synoptline}
{p2colreset}{...}



{title:Description}

{pstd}
Calculates the disparity of a network nodes and saves the result as a Stata variable {it : _disparity}. 

{pstd}
The disparity measures the distribution of a node's strength over its various edges. For details see Barthélemy, Barrat, Pastor-Satorras and Vespignani, Characterization and modeling of weighted networks, {it:Physica A}, Volume 346, 2005.

{it:disparity (i) = Sum_j (w_ij / s_i)^2 }


      r(avg_disparity) =  .1776241021170453
                  r(N) =  54

{title:Saved results}
{pstd}{cmd:nwdisparity} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 30 2: Scalars}{p_end}
{synopt:{cmd:r(avg_disparity)}} Average of {it :_disparity}  {p_end}
{synopt:{cmd:r(N)}} number of observations (nodes) {p_end}
{p2colreset}{...}


{title:Examples}
	{cmd:. webnwuse klas12b, nwclear}
	{cmd:. nwdisparity klas12b_wave2, direction(outward)}
		
	{cmd:. webnwuse gang, nwclear}
	{cmd:. nwdisparity gang_valued}

{title:Author}
Charlie Joyez, Paris-Dauphine University
charlie.joyez@dauphine.fr

{title:See also}
{pstd}
{cmd:nwdisparity}  requires the {bf : nwcommands} package developed by Thomas Grund.

{pstd}

For do-files and ancillary files, see:

	{cmd:. net describe nwcommands-ado, from(http://www.nwcommands.org)}
	
For help files, see :

	{cmd:. net describe nwcommands-hlp, from(http://www.nwcommands.org)}

