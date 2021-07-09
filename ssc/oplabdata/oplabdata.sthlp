{smcl}
{* *! version 1.0  17oct2017}{...}
{vieweralsosee "oplabdata" "help oplabdata"}{...}
{viewerjumpto "Syntax" "oplabdata##syntax"}{...}
{viewerjumpto "Description" "oplabdata##description"}{...}
{viewerjumpto "Options" "oplabdata##options"}{...}
{viewerjumpto "Examples" "oplabdata##examples"}{...}
{viewerjumpto "Author" "oplabdata##author"}{...}
{title:Title}

{pstd}
{hi:oplabdata} {hline 2} Quickly load data from the Equality of Opportunity Project


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:oplabdata}{cmd:,} [{it:options}]


{synoptset 35 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{cmdab:paper(string)}}Project to load data from{p_end}
{synopt :{cmdab:table(integer)}}Online data table to load {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:oplabdata} makes it easy to browse and load data from the Equality of Opportunity Project.

{pstd}
Simply type {cmd:oplabdata} to display an interactive menu of available projects.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}{opt paper(string)} Specifies the name of the paper from which to load data. If this is not specified, a list of papers will be provided. 

{phang}{opt table(integer)} Specifies the online data table corresponding to the paper() you wish to load. If this is not specified, a list of online data tables corresponding to paper() will be loaded.


{marker examples}{...}
{title:Examples}

{pstd}Display data for all projects.{p_end}
{phang2}. {stata oplabdata}{p_end}

{pstd}Display data for the College Mobility Report Cards project.{p_end}
{phang2}. {stata oplabdata, paper(mrc)}{p_end}

{pstd}Load Online Data Table 1 from the College Mobility Report Cards project.{p_end}
{phang2}. {stata oplabdata, paper(mrc) table(1)}{p_end}

{marker author}{...}
{title:Author}

Michael Droste
thedroste@gmail.com
