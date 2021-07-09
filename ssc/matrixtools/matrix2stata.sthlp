{smcl}
{* *! version 0.23}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help svmat" "help svmat"}{...}
{vieweralsosee "Help sumat (Is installed with matprint" "help sumat"}{...}
{viewerjumpto "Syntax" "matrix2stata##syntax"}{...}
{viewerjumpto "Description" "matrix2stata##description"}{...}
{viewerjumpto "Examples" "matrix2stata##examples"}{...}
{viewerjumpto "Stored results" "matrix2stata##results"}{...}
{viewerjumpto "Author and support" "matrix2stata##author"}{...}
{title:Title}
{phang}
{bf:matrix2stata} {hline 2} converts roweq, rownames and content from a matrix into 
Stata variables

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:matrix2stata}
matrixname
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt c:lear}} This option perform the command {help clear:clear} before 
creating variables from the matrix.{p_end}
{synopt:{opt z:iprows}} Orders and merges roweq and rownames into one label 
column/variable.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:matrix2stata} converts roweq, rownames and content from a matrix into 
variables. This makes it eg possible to do graphs of the content of one or 
more matrices. The matrices might have been generated from {help sumat:sumat}.

{marker examples}{...}
{title:Examples}

{phang}{bf:To use as an alternative to {help collapse:collapse}}{p_end}

{phang}{stata `"sysuse auto, clear"'}{p_end}
{phang}{stata `"label define rep78 1 "1 repair" 2 "2 repairs" 3 "3 repairs" 4 "4 repairs" 5 "5 repairs""'}{p_end}
{phang}{stata `"label values rep78 rep78"'}{p_end}

{phang}Generate a matrix of means and CI of price, mpg, headroom, trunk, weight, 
turn and displacement by the values of rep78 (number of repairs):{p_end}

{phang}{stata `"sumat price mpg headroom trunk weight turn displacement, statistics(mean ci) rowby(rep78)"'}{p_end}

{phang}Send the matrix to the data editor and clear the current dataset:{p_end}

{phang}{stata `"matrix2stata r(sumat), clear"'}{p_end}


{phang}{bf:To use as a base for a CI plot}{p_end}

{phang}{stata `"sysuse auto, clear"'}{p_end}
{phang}{stata `"label define rep78 1 "1 repair" 2 "2 repairs" 3 "3 repairs" 4 "4 repairs" 5 "5 repairs""'}{p_end}
{phang}{stata `"label values rep78 rep78"'}{p_end}

{phang}Generate a matrix of mean and CI for price by rep78 (number of repairs) 
and foreign (Origin of the car):{p_end}

{phang}{stata `"sumat price  if foreign == "Foreign":origin, statistics(mean ci) rowby(rep78) roweq(Foreign) full"'}{p_end}
{phang}{stata `"matrix out = r(sumat)"'}{p_end}
{phang}{stata `"sumat price  if foreign == "Domestic":origin, statistics(mean ci) rowby(rep78) roweq(Domestic) full"'}{p_end}
{phang}{stata `"matrix out = out \ r(sumat)"'}{p_end}

{phang}Send the matrix to the data editor and prepare the matrix data for the 
CI plot:{p_end}

{phang}{stata `"matrix2stata out, clear"'}{p_end}
{phang}{stata `"strofnum out_names"'}{p_end}
{phang}{stata `"replace out_names = subinstr(out_names, ", Price", "",.)"'}{p_end}
{phang}{stata `"strtonum out_names"'}{p_end}
{phang}{stata `"generate lbl = string(out_mean, "%6.0f") + " (" + string(out_ci95__lb, "%6.0f") + "; " + string( out_ci95__ub, "%6.0f") + ")""'}{p_end}
{phang}{stata `"label variable out_eq "Origin""'}{p_end}
{phang}{stata `"label variable out_names "Repair record 1978""'}{p_end}

{phang}Make the CI plot without being limited to a subset of the 
functionality of twoway:{p_end}

{phang}{stata `"twoway (scatter out_names out_mean, mlabel(lbl) mlabsize(vsmall) mlabposition(12)) (rcap out_ci95__lb out_ci95__ub out_names, hor), yscale(range(.5 5.5)) ylabel(1(1)5, angle(zero) valuelabel) by(out_eq, legend(off) cols(1)) ytitle(Mean price and 95% CI)"'}{p_end}


{phang}{bf:CI plots can also be made using the ziprows option. First data is generate again}{p_end}

{phang}{stata `"sysuse auto, clear"'}{p_end}
{phang}{stata `"label define rep78 1 "1 repair" 2 "2 repairs" 3 "3 repairs" 4 "4 repairs" 5 "5 repairs""'}{p_end}
{phang}{stata `"label values rep78 rep78"'}{p_end}

{phang}Generate a matrix of mean and CI for price by rep78 (number of repairs) 
and foreign (Origin of the car):{p_end}

{phang}{stata `"sumat price  if foreign == "Foreign":origin, statistics(mean ci) rowby(rep78) roweq(Foreign) full"'}{p_end}
{phang}{stata `"matrix out = r(sumat)"'}{p_end}
{phang}{stata `"sumat price  if foreign == "Domestic":origin, statistics(mean ci) rowby(rep78) roweq(Domestic) full"'}{p_end}
{phang}{stata `"matrix out = out \ r(sumat)"'}{p_end}

{phang}Send the matrix to the data editor and prepare the matrix data for the 
CI plot using the ziprows option:{p_end}
{phang}{stata `"matrix2stata out, clear ziprows"'}{p_end}

{phang}Generate labels and the Ci plot:{p_end}
{phang}{stata `"generate lbl = string(out_mean, "%6.0f") + " (" + string(out_ci95__lb, "%6.0f") + "; " + string( out_ci95__ub, "%6.0f") + ")""'}{p_end}

{phang}{stata `"twoway 	(scatter out_roweqnames out_mean, mlabel(lbl) mlabsize(vsmall) mlabposition(12)) (rcap out_ci95__lb out_ci95__ub out_roweqnames, horizontal), ylabel(1(1)6 8(1)13, angle(zero) valuelabel) legend(off) ytitle(Mean price and 95% CI)"'}{p_end}



{marker results}{...}
{title:Stored results}
{pstd}
{cmd:matrix2stata} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: local}{p_end}
{synopt:{cmd:r(variable_names)}}The created variable names. If the matrix does 
not exist " " is returned.{p_end}

{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/matrix2stata/matrix2stata_demo/":To see more examples}


{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}
