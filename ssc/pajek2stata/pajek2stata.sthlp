{smcl}
{* *! version 1.0}
{cmd:help pajek2stata } 
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:pajek2stata }{hline 2}}Import network data in Pajek's .net format{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 29 2}
{cmd:pajek2stata }
using {it:fname}
{cmd:,}
{opt name(name)} [{opt clear replace}]


{title:Description}

{pstd} {cmd:pajek2stata} imports data stored in Pajek's ".net" format for
relational data. A .net file is an ASCII file consisting of  two parts.  The
first part contains information about the vertices in the network, in the
conventional observation-by-variable format.  The first column of the vertices
part must contain the identifiers for the vertices; optional additional columns
may contain vertex labels and other properties of the vertices. pajek2stata
stores this part into new Stata variables. By default, these variables are
named var1, var2..etc., because Pajek net files do not contain variable names.
The new variables are all stored as string variables, and can be converted
afterwards as needed.

{pstd}The second part of the file contains the data on relations between the
vertecis, i.e., the network. The network data may take three different formats:

{phang}{it: Matrix:} The data are stored as a square NxN adjacency matrix.

{phang}{it: Edges:} The data are stored as a {it:list} of {it:edges}, in which
every line in the data represents a relation between two vertices. The first
two values must contain the identifiers of the vertices; a third (optional)
value  may contain the value of the relation.

{phang}{it: Arcs:} The data are stored as a {it:list} of {it:arcs}, in which
every line in the data represents a directed a relation {it:from} one vertex
{it:to} another. The first two values must contain the identifiers of the
vertices; a third (optional) value  may contain the value of the relation.

{pstd} pajek2stata stores the relational part of the data as a matrix in Mata,
from where it may be analyzed further.

{pstd}Note: this version of pajek2stata can only handle simple .net files
containing not more than one network specification.  Pajek also supports .net
files with multiple network specifications for the same set of vertices. Future
versions of pajek2stata may be able to deal with such files. 


{title:Options}


{phang} {cmd: name()} is required: specifies the name of the Mata matrix in
which the relational data are to be stored.   

{phang} {cmd: clear} specifies that the memory is to be cleared before the data
are loaded. pajek2stata issues an error message if there are already data in
memory and "clear" is not specified.  

{phang} {cmd: replace} specifies that if the Mata matrix {it: name} already
exists, it is to be replaced. 




{title:Author}: Rense Corten, Department of Sociology/ICS, Utrecht Univesity. April 2010.

{title:Also see}

{psee}
Online: {manhelp mata R}
{phang}
Internet: {browse "http://pajek.imfm.si/doku.php": The official Pajek wiki}


