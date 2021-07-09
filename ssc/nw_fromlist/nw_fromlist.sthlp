{smcl}
{* *! version 1.0.0 12jun2017}{...}

{title:Title}

{p2colset 9 18 22 2}{...}
{p2col :nw_fromlist {hline 2} Build a network from a list (long data)}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab: nw_fromlist}
[{it:{help netname}}]
[{cmd:,}
{opt node()}
{opt id()}
{opt direction()}
{opt binary}
{opt normalize}
]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt node(varname)}} Indicate the node variable. Required

{synopt:{opt id(varname)}} Indicate Individual variable (if the network is the sum of individual networks) .

{synopt:{opt dir:ection(varname)}} Indicate the order variable of linkages for directed networks .

{synopt:{opt norm:alize}} Build a normalized network (max weight=1).

{synopt:{opt bin:ary}} Build a binary network (all edges' weights set to 1.

{synoptline}
{p2colreset}{...}



{title:Description}

{pstd}
Builds a network from a list (long data) of individuals position on nodes. Returns the squared (weighted) adjacency matrix of nodes.
Previous dataset is deleted.

{pstd}
By default, it computes weighted non-normalized networks, as the sum of individual on each edge. 

{pstd}
A directed network might be specified if the positions follow a sequential order, with the option {cmd:directed({it:order})}.

{pstd}
{cmd:nwcluster} also returns the number of nodes and of individuals composing the network.

{pstd}
This is the alorithm to build French multinational enteprises' network from the list of foreign affiliates in Joyez (2017) {it:On The Topological Structure of Multinationals Network}, Phys.A(473C)

{title:Examples}
*Countries network by enterprises
nwclear
input byte ent str4 iso3 float(year var4) str1 var5
1 "AUT" 1 5 "a"
1 "USA" 2 5 "a"
2 "USA" 1 5 "a"
2 "GBR"  1 5 "a"
3 "GBR"  2 5 "a"
3 "FRA" 2 5 "a"
3 "ESP" 1 5 "a"
4 "ESP" 1 5 "a"
4 "ITA" 1 5 "a"
4 "USA" 2 5 "a"
4 "USA" 3 5 "a"
. "USA" 3 . ""
4  ""   3 . ""
end
{cmd:. nw_fromlist test,node(iso3) id(ent)}
{cmd:. nwplot }

*Countries network by enterprises through time
nwclear
input byte ent str4 iso3 float(year var4) str1 var5
1 "AUT" 1 5 "a"
1 "USA" 2 5 "a"
2 "USA" 1 5 "a"
2 "GBR"  1 5 "a"
3 "GBR"  2 5 "a"
3 "FRA" 2 5 "a"
3 "ESP" 1 5 "a"
4 "ESP" 1 5 "a"
4 "ITA" 1 5 "a"
4 "USA" 2 5 "a"
4 "USA" 3 5 "a"
. "USA" 3 . ""
4  ""   3 . ""
end
{cmd:. nw_fromlist test,node(iso3) id(ent) direction(year)}
{cmd:. nwplot }


*Firms network by countries
nwclear
input byte ent str4 iso3 float(year var4) str1 var5
1 "AUT" 1 5 "a"
1 "USA" 2 5 "a"
2 "USA" 1 5 "a"
2 "GBR"  1 5 "a"
3 "GBR"  2 5 "a"
3 "FRA" 2 5 "a"
3 "ESP" 1 5 "a"
4 "ESP" 1 5 "a"
4 "ITA" 1 5 "a"
4 "USA" 2 5 "a"
4 "USA" 3 5 "a"
. "USA" 3 . ""
4  ""   3 . ""
end
{cmd:. nw_fromlist test,node(ent) id(iso3)}
{cmd:. nwplot }


{title:Saved results}
{pstd}{cmd:nw_fromlist} saves the following in {cmd:r()}:

{synoptset 14 tabbed}{...}
{p2col 5 20 30 2: Scalars}{p_end}
{synopt:{cmd:r(nb_node)}} Number of nodes {p_end}
{synopt:{cmd:r(nb_id)}} Number of indviduals' networks {p_end}
{p2colreset}{...}

{pstd}{cmd:nw_fromlist} also saves the adjacency matrix in a Mata matrix {it:M}:
{cmd:. mata M }

{title:See also}	
{pstd}
{cmd:nw_fromlist}  requires the {bf : nwcommands} package developed by Thomas Grund.

{pstd}

For do-files and ancillary files, see:

	{cmd:. net describe nwcommands-ado, from(http://www.nwcommands.org)}
	}
For help files, see :

	{cmd:. net describe nwcommands-hlp, from(http://www.nwcommands.org)}
	}


{title:Author}
Charlie Joyez, Paris-Dauphine University
charlie.joyez@dauphine.fr
