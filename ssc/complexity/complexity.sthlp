{smcl}
{* *! version 3.0  29Jan2020}{...}
{title:Title}

{pstd}

{p2colset 9 18 22 2}{...}
{p2col :{cmd:complexity} {hline 2} Computes Complexity indexes similar to Hidalgo et al. ECI/PCI indexes. Only requires a Matrix of Individuals' Revealed Comparative Advantages over a set of Nodes (see Haussman & Hidalgo, 2012).}
Three alternative methodologies are available. By default, the eigenvalue method is followed as detailed at the {browse "https://oec.world/fr/resources/methodology/": OEC methodology} webpage. 
The alternative methods are the inital Method of Reflection (MR, Hidalgo & Hausmann, 2009), and the Fitness index (Tacchela et al, 2012).
For generalization purposes, we refer to individuals (rather than countries), and nodes (from any network rather than products from the product space).
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab: complexity}
{cmd:,}
{opt m:atrix()}
[{opt s:ource()}
{opt met:hode()}
{opt iter:ations()}
{opt p:rojection()}
{opt t:ranspose}
{opt x:var}




{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt m:atrix()}  {it:Required}}  Name (or path) of Matrix of Revealed Comparative Advantage of individuals (rows) in nodes (columns). Binary (=1 if RCA>1) or continuous RCA matrices are allowed.

{synopt:{opt s:ource()}} Indicates the matrix file type of the RCA matrix source. Can be {cmd: matrix} for a matrix stored in Stata or {cmd: mata} for a mata matrix (default). 
Can also be (but not recommended) {cmd:dta} for a matrix stored in a .dta file (with {ul:no other variables than RCAs}).
If {cmd: dta} is specified, then {cmd: matrix()} should indicate the path to the .dta file. If {cmd: matrix} or {cmd: mata} are specified, {cmd: matrix()} should indicate the matrix name.

{synopt:{opt met:hod()}} Indicates the algorithm followed. Can be {cmd:eigenvalue} (default if empty).
Alternative methods are {cmd:mr} to follow instead the Method of Reflection as in {browse "https://www.pnas.org/content/106/26/10570.short":Hidalgo & Hausmann, 2009},
 or {cmd:fitness} to follow the Fitness Complexity Method as detailed in {browse "https://www.nature.com/articles/srep00723":Tacchella et al.(2012)}

{synopt:{opt iter:ations}} Sets the number of iterations to run the Method of Reflection. If reached, the optimal level of iteration (i.e. when the final ranking doesn't vary anymore) is chosen. Iterations must be of even order.
 
{synopt:{opt p:rojection()}} Indicates which complexity index to return. {cmd: indiv} would return the individuals' complexity (e.g. countries ECI), while {cmd:nodes} returns the nodes' complexity (e.g. product PCI). 
In any case both are computed. If none are indicated, individuals' complexity is returned by default.

{synopt:{opt t:ranspose}} Transpose initial matrix if individuals were in columns and nodes in rows.

{synopt:{opt x:var}} Doesn't return a Stata variable (only Stata and mata matrices are stored).



{title:Stored result}
{cmd: complexity} saves the following in {cmd:r()}:

Vectors
{cmd:  r(Complexity_individual)} Column vector of Individuals' complexity values
{cmd:  r(Complexity_node)} Column vector of nodes' complexity values
{cmd:  r(Diversity)} Column vector of Individuals' diversity (nb of nodes with RCA>=1 for each indiv)
{cmd:  r(Ubiquity)} Column vector of nodes' Ubiquity (nb of individuals with RCA>=1 in this node)

The same vectors are stored in Mata, respectively under the names:
{cmd: comp_i}
{cmd: comp_n}
{cmd: Diversity}
{cmd: Ubiquity}

if the {cmd: fitness} method is specified the vectors returned are 
{cmd:  r(fitness_individual)} Column vector of Individuals' complexity values
{cmd:  r(fitness_node)} Column vector of nodes' complexity values
and respective mata vectors are
{cmd: fitness_i}
{cmd: fitness_n}


{marker examples}{...}
{title:Examples}

To compute complexity index on a real set of data, please see this link:
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1517977-new-on-ssc-complexity-computes-complexity-indexes-similar-to-eci-pci": This Statalist thread}

Otherwise, on random example values:

{phang}{cmd:. mata mat=(0.1,0.2,3,1.2 \ 0.5, 1, 1.5 , 1 \ 2.1 , 0 , 5, 0.5)}{p_end}
{phang}{cmd:. mata st_matrix("Smat", mat)}{p_end}

{phang}{cmd:. complexity, source(matrix) mat(Smat)}{p_end}
{phang}{cmd:. complexity,  mat(mat) pro(nodes)}{p_end}
{phang}{cmd:. complexity,  mat(mat) method(mr)}{p_end}



{marker Notes}{...}
{title:Notes}
Requires moremata (available on SSC) package to run.
Also note that the Eigenvector method is susceptible to crash as Mata faces some issue with computing Eigensystems of large matrices of very small elements
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/mata/1532997-missing-eigenvalues-and-eigenvector": this Statalist thread}

{marker References}{...}
{title:References}
On the Method of Reflection for ECI/PCI indexes: {browse "https://www.pnas.org/content/106/26/10570.short":Hidalgo & Hausmann, 2009}
On the Eigenvector Method for ECI/PCI indexes: {browse "https://oec.world/fr/resources/methodology/": OEC methodology}
On the Fitness index: {browse "https://www.nature.com/articles/srep00723":Tacchella et al.(2012)}


{marker Author}{...}
{title:Author}
Charlie Joyez, Université Côte d'Azur, France
charlie.joyez@univ-cotedazur.fr

{marker Acknowledgment}{...}
{title:Acknowledgment}
This program benefited from fruitful discussions with Mauricio Vargas.




