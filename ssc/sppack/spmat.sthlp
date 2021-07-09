{smcl}
{* *! version 1.0.4  24jan2012}{...}
{cmd:help spmat}{right:also see:  {helpb spreg}  }
{right:{helpb spivreg}}
{hline}


{title:Title}

{p2colset 5 14 16 2}{...}
{p2col:{hi:spmat} {hline 2}}Create and manage spatial-weighting matrix objects
({cmd:spmat} objects){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {it:subcommand} {it:...} [{cmd:,} {it:...}] 


{synoptset 12}{...}
{synopthdr:subcommand}
{synoptline}
{synopt:{helpb spmat_contiguity:contiguity}}create an {cmd:spmat} object containing a contiguity
	matrix {bf:W}{p_end}
{synopt:{helpb spmat_idistance:idistance}}create an {cmd:spmat} object containing an
	inverse-distance matrix {bf:W}{p_end}

{synopt:{helpb spmat_summarize:summarize}}summarize an {cmd:spmat} object{p_end}
{synopt:{helpb spmat_note:note}}manipulate a note attached to an {cmd:spmat} object{p_end}
{synopt:{helpb spmat_graph:graph}}draw an intensity plot of {bf:W}{p_end}
{synopt:{helpb spmat_lag:lag}}create a spatially lagged variable{p_end}
{synopt:{helpb spmat_eigenvalues:eigenvalues}}add eigenvalues of {bf:W} to an {cmd:spmat} object{p_end}
{synopt:{helpb spmat_drop:drop}}drop an {cmd:spmat} object from memory{p_end}

{synopt:{helpb spmat_save:save}}save an {cmd:spmat} object to disk in Stata's native format{p_end}
{synopt:{helpb spmat_export:export}}save an {cmd:spmat} object to disk as a text file{p_end}
{synopt:{helpb spmat_getmatrix:getmatrix}}copy a matrix from an {cmd:spmat} object to a Mata matrix{p_end}
	
{synopt:{helpb spmat_use:use}}create an {cmd:spmat} object from a file created by
	{cmd:spmat save}{p_end}
{synopt:{helpb spmat_import:import}}create an {cmd:spmat} object from a text file{p_end}
{synopt:{helpb spmat_dta:dta}}create an {cmd:spmat} object from a Stata dataset{p_end}
{synopt:{helpb spmat_putmatrix:putmatrix}}put a Mata matrix into an {cmd:spmat} object{p_end}

{synopt:{helpb spmat_permute:permute}}permute rows and columns of {bf:W}{p_end}
{synopt:{helpb spmat_tobanded:tobanded}}transform an {it:n} x {it:n} {bf:W} into a
banded {it:b} x {it:n} {bf:W}{p_end}
{synoptline}


{title:Description}

{pstd}
Spatial-weighting matrices are used to model interactions between spatial
units in a dataset.  {opt spmat} is a collection of commands for creating,
importing, manipulating, and saving spatial-weighting matrices.

{pstd}
Spatial-weighting matrices are stored in spatial-weighting matrix objects
({cmd:spmat} objects).  {cmd:spmat} objects contain additional information
about the data used in constructing spatial-weighting matrices.  {cmd:spmat}
objects are used in fitting spatial models; see {help spreg}, {help spivreg}
(if installed).

{pstd}
These commands are documented in Drukker, Peng, Prucha, and Raciborski
(2011) which can be downloaded from 
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spmat_2011.pdf"}.


{title:References}

{phang}Drukker, D. M., H. Peng, I. R. Prucha, and R. Raciborski. 2011.
Creating and managing spatial-weighting matrices using the spmat command.
Working paper, The University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spmat_2011.pdf"}.


{title:Authors}

{phang}
David Drukker, StataCorp, College Station, TX.
{browse "mailto:ddrukker@stata.com":ddrukker@stata.com}.

{phang}
Hua Peng, StataCorp, College Station, TX.
{browse "mailto:hpeng@stata.com":hpeng@stata.com}.

{phang}
Ingmar Prucha, Department of Economics, University of Maryland, College Park, MD.
{browse "mailto:prucha@econ.umd.edu":prucha@econ.umd.edu}.

{phang}
Rafal Raciborski, StataCorp, College Station, TX.
{browse "mailto:rraciborski@stata.com":rraciborski@stata.com}.


{title:Also see}

{psee}Online:  {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

