{smcl}
{* *! version 1.0.0 22avr2016}{...}

{title:Title}

{p2colset 9 18 22 2}{...}
{p2col :nwreciprocity {hline 2} Calculates reciprocity metrics for (weighted) directed networks}
{p2colreset}{...}


{title:Syntax}
Syntax 1
{p 8 17 2}
{cmdab: nwreciprocity}
[{cmd:,}
{opt net(netname)}
{opt loop(iter)}
{opt kdensity}
]

Syntax 2
{p 8 17 2}
{cmdab: nwreciprocity}
[{cmd:,}
{opt nodes()}
{opt density()}
{opt loop(iter)}
{opt kdensity}
]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt net(netname)}}  Network name

{synopt:{opt loop(iter)}}  Number of iterations for null model estimation, but default set to 1000

{synopt:{opt kdensity}} Displays the kernel density of estimated null models reciprocity.

{synopt:{opt nodes(#)}} Set the number of nodes of the null model to estimate

{synopt:{opt density(#)}} Set the density [0;1] of the null model to estimate

{synopt:{opt show}} Displays the iteration number


{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}

Syntax 1 (when {cmd:net()} is specified), {cmd:nwreciprocity()} returns the reciprocity coefficient of a given network, 
comparing the share of reciprocated ties of the empirical network to the average of random with same dimensions
(number of nodes, density, total weigth).


The {it:reciprocity coefficient} corresponds to a comparison of the {it:weighted reciprocity}
(the share of reciprocated weights over total edge's weight) with the average reciprocity of null models
 with same dimensions (number of nodes, density, total weigth). 

Following Squartini, T., Picciolo, F., Ruzzenenti, F., and Garlaschelli, D.
Reciprocity of weighted networks. 
{it:Scientific reports}, 3, 2013;
the reciprocity coefficient could be written as {it:rho = (r - r_null / (1-r_null) }
Where {it:r} is the real weighted reciprocity, and {it:r_null} the average weighted reciprocity of null models.

The reciprocity coefficient {it:rho} could be interpreted compared to zero :
{it:rho>0}: over-reciprocity of empirical network
{it:rho>0}: no reciprocity tendency.
{it:rho<0}: sub-reciprocity of empirical network

The number of iteration for the average of null models is set by {it: loop}

{pstd}

Syntax 2 (when {cmd:net()} is not specified), returns only the average reciprocated weights of null models with dimensions set in {it:nodes()}, {it:density()} and {it:weight()}.

{title:Saved results}

{pstd}{cmd: nwreciprocity} saves the following scalars in {cmd:r()}:

{pstd}

For syntax 1 and 2:

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: }{p_end}
{synopt:{cmd:r(mean_null)}} mean share of reciprocated ties from the random networks (weighted reciprocity){p_end}
{synopt:{cmd:r(density)}} network density (weighted reciprocity){p_end}
{synopt:{cmd:r(nodes)}} number of nodes in the networks {p_end}
{synopt:{cmd:r(loop)}} number of iterations for null model (weighted reciprocity){p_end}

{p2colreset}{...}

For syntax 1 only:

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: }{p_end}
{synopt:{cmd:r(mean_real)}} share of reciprocated ties from the empirical network (weighted reciprocity){p_end}
{synopt:{cmd:r(r_coeff)}}   reciprocity coefficient of the empirical network, compared to null models.{p_end}
{p2colreset}{...}


{title:Examples}

{pstd}
reciprocity of a given network and comparison to a null model :

	{cmd:. webnwuse klas12b, nwclear}
	{cmd:. nwkeep klas12b_wave2}
	{cmd:. nwreciprocity, net(klas12b_wave2) loop(50) kdensity}
	
{pstd}
average reciprocity of a null model :

	{cmd:. nwreciprocity, nodes(10) density(0.5) loop(50) show}
	
{title:Author}
Charlie Joyez, Paris-Dauphine University
charlie.joyez@dauphine.fr

{title:See also}
{pstd}
{cmd:nwreciprocity}  requires the {bf : nwcommands} package developed by Thomas Grund.

{pstd}

For do-files and ancillary files, see:

	{cmd:. net describe nwcommands-ado, from(http://www.nwcommands.org)}
	
For help files, see :

	{cmd:. net describe nwcommands-hlp, from(http://www.nwcommands.org)}

