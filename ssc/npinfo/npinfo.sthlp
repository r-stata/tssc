{smcl}
{* *! version 1.0 18 June 2014}{...}
help for {cmd:npinfo}{right:version 1.0 (18 June 2014)}
{hline}


{title:Title}

{phang}
{bf:npinfo} {hline 2} Merge network-based nodal characteristics


{title:Table of contents}

	{help npinfo##syntax:Syntax}
	{help npinfo##description:Description}
	{help npinfo##options:Options}
	{help npinfo##remarks:Remarks}
	{help npinfo##example:Example}
	{help npinfo##author:Author}


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:npinfo} varlist, {it:options}
{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Obligatory}
{synopt:{opt id(variable)}}nodes' unique identifier{p_end}
{synopt:{opt npcov(varlist)}}nodal attributes{p_end}
{synopt:{opt replace}}overwrite data in memory{p_end}


{syntab:Optional}
{synopt:{opt dyads(varname)}}generates dyadic dataset (i.e., edgelist){p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}


{pstd}For outgoing-ties, denoted by {it:varlist}, {cmd:npinfo} eases adding the receiving nodes' information or characteristics. {cmd:npinfo} expects network data in wide-format.
An example should make this clearer. Suppose you surveyed classroom-based friendship networks using five nominations. {cmd:npinfo} now provides
a handy way to add friends' characteristics like sex, age, and so on. Additionally, this wide-format information can be turned into an edgelist.
{p_end}

{marker options}
{title:Options}

{dlgtab:Obligatory}

{phang}
{opt id(variable)} indicates the variable uniquely identifying each sending node.{p_end}

{phang}
{opt npcov(varlist)} provides the list of nodal attributes to be added to each receiving node. 
The number of new variables genereated is the number of variables spanning the network times the number of variables describing the nodal attributes.
New variables are named according to the scheme {it:networkvar}_{it:npcov}.{p_end}

{phang}
{opt replace} has to be specified as {cmd:npinfo} alters the data in memory.{p_end}


{dlgtab:Optional}

{phang}
{opt dyads(varname)} generates a dyadic dataset (i.e., edgelist). The number of new variables equals the number of variables describing the nodal attributes (as specified in {opt npcov(varlist)}).
New variables are named according to the scheme {it:varname}_{it:npcov}.{p_end}

{marker remarks}
{title:Remarks}

{pstd}
{cmd:npinfo} marks the source of missing information on nodal attributes. In case of item-nonresponse nodal covariates
exhibit a classical missing (i.e., "."). In case of unit-nonresponse nodal covariates exhibit ".a".{p_end}

{marker example}
{title:Example}

{pstd} Suppose you have a school-based friendship network with five nominations (friend1-friend5) and want to compute the proportion of students' female friends (sex; coded 0 = male and 1 = female).
You could use {cmd:npinfo} to prepare this computation and add friends' sex to each nominated friend. As the network contains five possible nominations, five new variables are generated.
They are named as a combination of the network variables (i.e., friend1, friend2, ...) and the nodal covariates (i.e., sex) resulting in friend1_sex, friend2_sex, ..., friend5_sex.{p_end}

{phang}{cmd:. npinfo friend1-friend5, id(id_student) npcov(sex)}{p_end}
{phang}{cmd:. egen female_share = rowmean(friend?_sex)}{p_end}

{marker author}
{title:Authors}

{pstd}{browse "mailto:sebastian.pink@uni-mannheim.de":Sebastian Pink}, University of Mannheim, Germany.
{p_end}



